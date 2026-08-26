<cfcomponent displayname="ProductGroupAttributeManager" hint="ProductGroup Attribute Manager" extends="components.Base">

	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
	<cffunction name="init" returntype="components.products.group.ProductGroupAttributeManager" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getProductGroupAttributes" returntype="query" output="false">
		<cfargument name="groupLevelId" type="numeric" required="false" default="0" />
		<cfargument name="groupLevelTypeId" type="numeric" required="false" default="0" />
		<cfargument name="approvalLevelTypeId" type="numeric" required="false" default="0" />
		<cfargument name="active" type="numeric" required="false" default="-1" />
		<cfargument name="includePG" type="numeric" required="false" default="1" />
		
		<cfquery name="qGetProductsAttributes" datasource="#application.datasource#">
			SELECT	Product_Group_Attribute.*, Product_Group_Level.*
			FROM	Product_Group_Attribute
			
			INNER JOIN Product_Group_Level
			ON		Product_Group_Level.Deleted = 0
			AND		Product_Group_Level.Product_Group_Level_ID = Product_Group_Attribute.Product_Group_Level_ID
       <!--- Do not Select planning groups if the appsetting is OFF./Anand Rao/10-Jan-2011 OR arguments.includePG EQ 0 --->
      <cfif NOT(appSettings.getPlanningGroups()) OR arguments.includePG eq 0>
       AND Product_Group_Level.Is_PG = 0
      </cfif>
			<cfif arguments.groupLevelTypeId NEQ 0>
			AND		Product_Group_Level.Product_Group_Level_Type = #arguments.groupLevelTypeId#
			</cfif>
			<cfif arguments.approvalLevelTypeId NEQ 0>
			AND		ISNULL(Product_Group_Level.Approval_Group_Type, Product_Group_Level.Product_Group_Level_ID) = #arguments.approvalLevelTypeId#
			</cfif>
			
			WHERE	Product_Group_Attribute.Deleted = 0
			<cfif arguments.groupLevelId NEQ 0>
			AND		Product_Group_Attribute.Product_Group_Level_ID = #arguments.groupLevelId#
			</cfif>
			<cfif arguments.active NEQ -1>
			AND		Product_Group_Attribute.Active = #arguments.active#
			</cfif>
		</cfquery>
		
		<cfreturn qGetProductsAttributes />
		
	</cffunction>
	
	<cffunction name="getProductGroupAttributeInfo" returntype="query" output="false">
		<cfargument name="groupLevelId" type="numeric" required="false" default="0" />
		
		<cfquery name="qGetProductsAttributes" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT	*
			FROM	Product_Group_Attribute
			
			WHERE	Product_Group_Attribute.Deleted = 0
			<cfif arguments.groupLevelId NEQ 0>
			AND		Product_Group_Attribute.Product_Group_Level_ID = <cfqueryparam value="#arguments.groupLevelId#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
		</cfquery>
		
		<cfreturn qGetProductsAttributes />
		
	</cffunction>
	
	<cffunction name="getProductGroupAttributeTableName" returntype="string" output="false">
		<cfargument name="groupLevelId" type="numeric" required="false" default="0" />
		
		<cfset qGetProductsAttributes = getProductGroupAttributeInfo(arguments.groupLevelId) />
		
		<cfreturn qGetProductsAttributes.Product_Group_Attribute_Table />
		
	</cffunction>
	
	<cffunction name="getProductGroupAttributeSearchSequenceFieldName" returntype="string" output="false">
		<cfargument name="groupLevelId" type="numeric" required="false" default="0" />
		
		<cfset qGetProductsAttributes = getProductGroupAttributeInfo(arguments.groupLevelId) />
		
		<cfreturn qGetProductsAttributes.Product_Group_Attribute_Search_Sequence_Field />
		
	</cffunction>
	
	<cffunction name="getGroupTypeInfo" output="false" returntype="struct">	
		<cfargument name="groupLevelId" type="numeric" required="false" default="0" />		
		<cfargument name="approvalLevelTypeId" type="numeric" required="false" default="0" />
		<cfargument name="groupLevelTypeId" type="numeric" required="false" default="0" />
		
		<cfset qGetProductGroupLevel		= getProductGroupAttributes(groupLevelId = arguments.groupLevelId, groupLevelTypeId = arguments.groupLevelTypeId, approvalLevelTypeId = arguments.approvalLevelTypeId) />
		<cfset productGroupType = StructNew() />
		<!------ Get the table infor form product group attributes ----->
		<cfif qGetProductGroupLevel.recordCount>			
			<cfset productGroupType.groupLevelId			= qGetProductGroupLevel.Product_Group_Level_ID>
			<cfset productGroupType.tableName 				= qGetProductGroupLevel.Product_Group_Attribute_Table />
			<cfset productGroupType.prodHierLevel			= qGetProductGroupLevel.Hierarchy_Level />
			<cfif productGroupType.prodHierLevel EQ "">
				<cfset productGroupType.prodHierLevel			= 0 />
			</cfif>
			<cfset productGroupType.IDField 				= qGetProductGroupLevel.Product_Group_Attribute_ID_Field />
			<cfset productGroupType.MasterIDField 			= qGetProductGroupLevel.Product_Group_Attribute_Master_ID_Field />
			<cfset productGroupType.NameField 				= qGetProductGroupLevel.Product_Group_Attribute_Name_Field />
			<cfset productGroupType.NumberField 			= qGetProductGroupLevel.Product_Group_Attribute_Number_Field />
			<cfset productGroupType.Label 					= getProductGroupLabel(qGetProductGroupLevel.Product_Group_Level_ID) />
			<cfset productGroupType.productGroupIDField		= qGetProductGroupLevel.Product_Group_Attribute_ID_Field />
			<cfset productGroupType.groupType				= qGetProductGroupLevel.Approval_Group_Type />
			<cfset productGroupType.groupLevelType			= qGetProductGroupLevel.Product_Group_Level_Type />
			<cfset productGroupType.programGroupsViewName	= qGetProductGroupLevel.Program_View_Name>
		</cfif>	
		<cfreturn productGroupType/>
	
	</cffunction>
	
	<cffunction name="getProductGroupValues" output="false" returntype="query">
		<cfargument name="productGroupType" required="true" type="struct">
		<cfargument name="groupList" required="false" type="string" default="">
		<cfargument name="restrictOnGroupList" required="false" type="numeric" default="0">
		<cfargument name="BusinessSegmentId" required="false" default="0">
		<cfargument name="excludeGroupList" required="false" type="string" default="">
		<cfargument name="cachedwithin" required="false" default="#CreateTimeSpan(0, 0, 0, 0)#" />
    	<cfargument name="TemplateID" required="false" default = "0" />		
    	<cfargument name="programID" required="false" default = "0" />		
		<cfargument name="ExcludeItemID" required="false" default = "0" />	
		<cfargument name="IncludeIOPGFlag" required="false" default = "0" />	
		<cfargument name="TemplateFiltersID" type="numeric" required="false" default="0" />
		
		<cfset productGroupType = arguments.productGroupType />
	
   <cfset bValExists = "0" />
    <cfif arguments.TemplateID NEQ 0>
<!---     /* SELECT Group_Level_ID FROM Group_Template
         WHERE Template_ID =  #arguments.TemplateID#     */
 --->    
		<cfif arguments.programID >
			<cfquery name="GetContractInfo" datasource="#application.datasource#"> 
			   	SELECT Template_Filters_ID
	    		FROM Contract_Main
	    		WHERE Contract_Main_ID = '#arguments.programID#'  
     		</cfquery>
		</cfif>
      
      <cfquery name="qGetGroupTemplate" datasource="#application.datasource#">
        SELECT DISTINCT Group_Level_ID,Allow_In_Search,Allow_In_Group_Search,Allow_Filter 
		FROM Group_Template
        WHERE Template_ID =  #arguments.TemplateID# AND    
         	Active = 1 AND 
         	Deleted = 0 AND 
         	PG_Group_Type = 1
      </cfquery>
   
      <cfloop query="qGetGroupTemplate">
        <cfif qGetGroupTemplate.Group_Level_ID EQ productGroupType.GroupLevelID  AND qGetGroupTemplate.Allow_Filter EQ 1>
          <cfset bValExists = "1" />
        </cfif>
      </cfloop>
    </cfif>  
 
 
   <cfif arguments.TemplateID NEQ 0 AND qGetGroupTemplate.RecordCount GTE 1 AND bValExists EQ "1">
   
		<cfquery name="qGetProductGroupValues" datasource="#application.datasource#"><!--- cachedwithin="#arguments.cachedwithin#" --->
        <!--- SELECT	
                DMEMT.#productGroupType.NameField# As Group_Name, 
  					    DMEMT.#productGroupType.IDField# As Group_ID
  			FROM	Product_Group_Template_Selection  CGTS
        INNER JOIN #productGroupType.tableName#	DMEMT		
        ON CAST(DMEMT.#productGroupType.IDField# AS VARCHAR(50))   = 	CGTS.Distributor_Group_ID	
  			WHERE	 DMEMT.Deleted = 0
  			AND 	DMEMT.#productGroupType.NameField# IS NOT NULL
        AND   CGTS.Template_id = #arguments.TemplateID#
        AND   CGTS.Distributor_Group_level_ID = #productGroupType.GroupLevelTypeID#
        <cfif productGroupType.tableName EQ "PG_Customer_Category">
  			 AND CGTS.Distributor_Group_Level_ID =  #productGroupType.GroupLevelTypeID#
        <cfelse>  
          AND		Len(DMEMT.#productGroupType.NameField#) > 0
  			</cfif>
        <cfif arguments.businessSegmentId NEQ 0>
  			AND		DMEMT.#productGroupType.tableName#.Business_segment_id = '#arguments.businessSegmentId#'
  			</cfif>
  			<cfif arguments.groupId NEQ 0>
  			AND		DMEMT.#productGroupType.tableName#.#productGroupType.IDField# = '#arguments.groupId#'
  			</cfif>
  			Order By DMEMT.#productGroupType.NameField#  --->   
    
        	SELECT	DISTINCT LTrim(RTrim(PMEMT.#productGroupType.NameField#)) As Group_Name, 
					PMEMT.#productGroupType.IDField# As Group_ID,
					PMEMT.#productGroupType.NumberField# As Group_Number				
  			FROM	Product_Group_Template_Selection  PGTS
        	INNER JOIN #productGroupType.tableName#	PMEMT		
        	ON 		CAST(PMEMT.#productGroupType.IDField# AS VARCHAR(50))   = 	PGTS.Product_Group_ID	
  			WHERE	PMEMT.Deleted = 0
  			AND 	PMEMT.#productGroupType.NameField# IS NOT NULL
        	AND   	PGTS.Template_ID = #arguments.TemplateID#
        
			<cfif GetContractInfo.RecordCount GTE 1>
          	AND PGTS.Template_Filters_ID = #GetContractInfo.Template_Filters_ID#        
			</cfif>
        
			AND PGTS.Active = 1 
			AND PGTS.Deleted = 0
        
      <!---   AND   PGTS.Product_Group_level_ID = #productGroupType.GroupLevelTypeID#      --->
			<!--- 
				changed this to pg_type_ID to fix the issue where the items that were not in the Planning group
				was getting displayed (They were old items)
			--->
        <cfif productGroupType.tableName EQ "PG_Product_Category">
			 AND PMEMT.PG_Type_ID =  #productGroupType.GroupLevelID#
  		  	-- AND PGTS.Product_Group_Level_ID =  #productGroupType.GroupLevelID#
			AND PMEMT.Active = 1 AND PMEMT.Deleted = 0
			<cfif arguments.IncludeIOPGFlag	EQ "1">
			AND PMEMT.Include_In_Other_PG = 1
			</cfif>
       </cfif>               
         
        <!---   					<cfif productGroupType.prodHierLevel GT 0>
  					AND Product_Hierarchy_Level = #productGroupType.prodHierLevel#
  					</cfif> --->
			<cfif arguments.groupList NEQ "">
			AND PMEMT.#productGroupType.IDField# IN (#ListQualify(arguments.groupList, "'", ",")#)
			<cfelseif arguments.restrictOnGroupList>
			AND 1=2
			</cfif>
			<cfif arguments.ExcludeItemID NEQ "0" AND arguments.ExcludeItemID NEQ "">
			AND #productGroupType.IDField# NOT IN ('#arguments.ExcludeItemID#')
			</cfif>
			<cfif arguments.excludeGroupList NEQ "">
			AND PMEMT.#productGroupType.IDField# NOT IN (#ListQualify(arguments.excludeGroupList, "'", ",")#)
			</cfif>
  					<!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START--->
  					<cfif businessSegmentId neq "0" and businessSegmentId neq "">
  					AND	Business_Segment_Id IN (#arguments.businessSegmentId#)
  					</cfif>
  					<!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->
  			Order By Group_Name, Group_ID
        </cfquery>
    <cfelse>  
  		<cfquery name="qGetProductGroupValues" datasource="#application.datasource#" ><!--- cachedwithin="#arguments.cachedwithin#"--->
  			SELECT	LTrim(RTrim(#productGroupType.NameField#)) As Group_Name,
  					#productGroupType.IDField# As Group_ID,
						#productGroupType.NumberField# As Group_Number		
  			FROM	#productGroupType.tableName#					
  			WHERE	#productGroupType.tableName#.Deleted = 0
			 		<cfif productGroupType.tableName EQ "PG_Product_Category">
  			 		AND PG_Type_ID =  #productGroupType.GroupLevelID#
						AND Active = 1 AND Deleted = 0
						<cfif arguments.IncludeIOPGFlag	EQ "1">
						   AND Include_In_Other_PG = 1
						</cfif>
       		</cfif>     				
  					<cfif productGroupType.prodHierLevel GT 0>
  					AND Product_Hierarchy_Level = #productGroupType.prodHierLevel#
  					</cfif>
  					<cfif arguments.groupList NEQ "">
  					AND #productGroupType.IDField# IN (#ListQualify(arguments.groupList, "'", ",")#)
  					<cfelseif arguments.restrictOnGroupList>
  					AND 1=2
  					</cfif>
  					<cfif arguments.excludeGroupList NEQ "">
  					AND #productGroupType.IDField# NOT IN (#ListQualify(arguments.excludeGroupList, "'", ",")#)
  					</cfif>
						<cfif arguments.ExcludeItemID NEQ "0" AND arguments.ExcludeItemID NEQ "">
						AND #productGroupType.IDField# NOT IN ('#arguments.ExcludeItemID#')
						</cfif>
  					<cfif businessSegmentId neq "0" and businessSegmentId neq "" AND productGroupType.tableName NEQ "Product_Hierarchy">
  					AND	Business_Segment_Id in (#arguments.businessSegmentId#)
  					</cfif>			
					 AND LTrim(RTrim(#productGroupType.NumberField#)) != '' AND #productGroupType.NumberField# IS NOT NULL
					 AND LTrim(RTrim(#productGroupType.NumberField#)) != 'NONE'
  			Order By #productGroupType.NameField#
  		</cfquery>
    </cfif>
    	
		<cfreturn qGetProductGroupValues>
	
	</cffunction>
	
	
	<cffunction name="getProductGroupValuesExt" output="false" returntype="query">
		<cfargument name="productGroupType" required="true" type="struct">
		<cfargument name="arAllowLists" required="false" type="array" default="#ArrayNew(1)#">
		<cfargument name="businessSegmentId" required="false" type="numeric" default="0">
		<cfargument name="excludeGroupList" required="false" type="string" default="">
		<cfargument name="arGroupMembers" required="false" default="#ArrayNew(1)#" type="array" />
		<cfargument name="suppressGroups" required="false" default="0" />
		<cfargument name="IncludeDeleted" required="false" default="0" />
		<cfargument name="FirstParentID" type="string" required="true" />
		<cfargument name="setGroupTemplateSelectionOn" type="any" required="false" default="0" />
		<cfargument name="TemplateFiltersID" type="numeric" required="false" default="0" />
		<cfargument name="IncludeActiveOnly" required="false" default="1" />
        <cfargument name="plannerId" type="numeric" required="false" default="0" />
		
		<cfset productGroupType = arguments.productGroupType />
		<cfset arAllowListLen = ArrayLen(arguments.arAllowLists) />
		
		<cfset arGroupMembersLen = ArrayLen(arGroupMembers) />
		<cfset groupCombinationOn = 0 />
		<cfif arGroupMembersLen GT 0>
			<cfset groupCombinationOn = 1 />
		</cfif>
		
		<cfif groupCombinationOn>			

			<cfquery name="qGetProductGroupValues" datasource="#application.datasource#">
				SELECT	DISTINCT Group_Combination_Desc As Group_Level_Desc, 
						Group_Combination.Group_Combination_ID As Product_Group_ID,
						#productGroupType.groupLevelType# As Product_Group_Level_Type,						
						'' As Hierarchy_Level,
						'' As Parent_Hierarchy_ID,
						Group_Combination.Product_Count
						
				FROM	Group_Combination
				
				WHERE	Group_Combination.Deleted = 0
				AND 	Product_Hierarchy_Level = #productGroupType.prodHierLevel#
				
				<cfif arguments.suppressGroups>
				AND		Product_Count > 0
				</cfif>
				
				<cfloop index="counter" from="1" to="#arAllowListLen#">
					<cfif arguments.arAllowLists[counter] NEQ "">
					AND Group_Combination.Group_Combination_ID IN (#ListQualify(arguments.arAllowLists[counter], "'", ",")#)
					<cfelse>
					AND 1=2
					</cfif>
				</cfloop>
				
				<cfif arguments.excludeGroupList NEQ "">
				AND Group_Combination.Group_Combination_ID NOT IN (#ListQualify(arguments.excludeGroupList, "'", ",")#)
				</cfif>	
				
				<cfloop index="i" from="1" to="#arGroupMembersLen#">
				<cfset stGroupMember = arGroupMembers[i] />
				<cfif stGroupMember.groupId NEQ "" AND stGroupMember.groupId NEQ "0">
				AND	Group_Combination.Group_Combination_ID IN
				(
				SELECT 	DISTINCT Group_Combination.Group_Combination_ID
				FROM	Group_Combination
				INNER	JOIN Group_Combination_Detail
				ON		Group_Combination.Group_Combination_ID = Group_Combination_Detail.Group_Combination_ID
				WHERE	Group_Combination.Deleted = 0
				AND		Group_Combination.Product_Hierarchy_Level = #productGroupType.prodHierLevel#
				AND		Group_Combination_Detail.Member_Group_Level_ID = #stGroupMember.groupLevelId# 
				AND 	Group_Combination_Detail.Member_Group_ID = '#stGroupMember.groupId#'
				)
				</cfif>
				</cfloop>
									
				Order By Group_Combination_Desc
			</cfquery>
		<cfelse>
			<!---TSF - Label 11523: Check to make sure the productGroupType.IDField is in the Product_Customer_Group table while suppressing groups--->
			<cfquery name="qCheckGroupTypeIDField" datasource="#application.datasource#">
				SELECT	Table_Catalog 
				FROM	Information_Schema.Columns
				WHERE	Table_Name = 'BSA_Foodservice_Items_Master'                           <!---31238--->
				AND		Column_Name = '#productGroupType.IDField#'
			</cfquery>
			<!--- New query for Group_template--->	
			<cfquery name="qGetGroupTemplateFilter" datasource="#application.datasource#">
				SELECT Allow_Filter 
				FROM Group_Template 
				WHERE Template_ID = #arguments.FirstParentID#
					AND Group_Level_ID = #productGroupType.GroupLevelID#
					AND Deleted = 0 
					AND Active = 1
			</cfquery>
            
            <cfset bApplyPlannerTemplateFilter = 0 />
            <cfif arguments.plannerId>
                <cfset bApplyPlannerTemplateFilter = CreateObject("component", "mvc.Models.Planner.PlannerManager").tmp_planner_template_filter_products(arguments.plannerId) />
            </cfif>

			<cfquery name="qGetProductGroupValues" datasource="#application.datasource#">
				SELECT	DISTINCT #productGroupType.tableName#.#productGroupType.NameField# As Group_Level_Desc, 
						#productGroupType.tableName#.#productGroupType.IDField# As Product_Group_ID,
						#productGroupType.tableName#.#productGroupType.NumberField# As Group_ID,    <!---31360--->
						#productGroupType.groupLevelType# As Product_Group_Level_Type,
						<cfif productGroupType.prodHierLevel GT 0>
						Product_Hierarchy_Level As Hierarchy_Level,
						Parent_Product_Hierarchy_ID As Parent_Hierarchy_ID
						<cfelse>
						'' As Hierarchy_Level,
						'' As Parent_Hierarchy_ID
						</cfif>
						
				FROM	#productGroupType.tableName#
             
             <!--- CHECK FOR THE TEMPALTE IN FILTERS TABLES - ANAND RAO 01/04/2011 --->

	     		<cfif qGetGroupTemplateFilter.RecordCount NEQ 0 AND qGetGroupTemplateFilter.Allow_Filter EQ 1 AND arguments.setGroupTemplateSelectionOn EQ 1>
            	INNER JOIN Product_Group_Template_Selection PGTS ON PGTS.Product_Group_Level_ID = #productGroupType.GroupLevelID# AND PGTS.Active = 1 AND PGTS.Deleted = 0
							AND PGTS.Template_ID = #arguments.FirstParentID# AND
							CAST(#productGroupType.tableName#.#productGroupType.IDField# as varchar(50)) = PGTS.Product_Group_ID
             	</cfif> 
        
						<!---TSF - Label 11075: Check to see if there are any items for this group. If there are not then return nothing--->
						<cfif arguments.suppressGroups and qCheckGroupTypeIDField.RecordCount>
							INNER JOIN BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.#productGroupType.IDField# =  #productGroupType.tableName#.#productGroupType.IDField#
							AND BSA_Foodservice_Items_Master.Active_Code = 'A' 
							AND BSA_Foodservice_Items_Master.Item IS NOT NULL
							AND BSA_Foodservice_Items_Master.Deleted = 0

							INNER JOIN Product_Customer_Group ON Product_Customer_Group.Product_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID 
							<cfif isDefined("form.programId") and form.programId neq "0" and isNumeric(form.programId)>
								<cfif application.appsettingsget.getPopulate_180Day_From() eq 0><!--- Populate 180 day table from invoice ---->
									AND	EXISTS (
										SELECT 	1 
										FROM 	Contract_Distributors cd 
										WHERE 	cd.Contract_Main_ID = '#form.programId#'
										AND		cd.BSA_Foodservice_Customers_ID = Product_Customer_Group.Customer_ID
										AND		cd.Deleted = 0
									)
								</cfif>
							</cfif>
							<!--- ////////// Tim Ford - Label 29675:  Simplification of product group search //////////////////////////////
							If setGroupTemplateSelectionOn is on and we have a template parent id, then join on the 
							Product Group and Planning Group tables defined for this template to filter on its members in the where clause.
							///////////////////////////////////////////////////////////////////////////////////////////////////////////--->
							<cfif arguments.setGroupTemplateSelectionOn EQ 1 and len(trim(arguments.FirstParentID)) gt 0 and len(trim(arguments.FirstParentID)) neq 0>
								<!--- Get the product group attribute data from the getProductGroupAttributesGroupTemplate() function in this cfc --->
								<cfset qGetCoreTemplateFilter = getProductGroupAttributesGroupTemplate(active = 1, 
																										FirstParentID = arguments.FirstParentID, 
																										TemplateFiltersID = arguments.TemplateFiltersID) />
								<!---//////////////////////////////////////////////////////////////////////////////////////////////////////////////
								Loop over the query and join on the planning group tables if the attribute is a planning group and it has a filter,
								or join on the product group table if the product group has a filter 
								///////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
								<cfloop query="qGetCoreTemplateFilter">
									<cfif trim(qGetCoreTemplateFilter.Product_Group_Attribute_Table) neq trim(productGroupType.tableName) and qGetCoreTemplateFilter.Allow_Filter eq 1>
										<cfif qGetCoreTemplateFilter.Product_Group_Attribute_Table eq "PG_Product_Category">
											INNER JOIN PG_Product_Members AS PGPM_#qGetCoreTemplateFilter.Group_Level_ID# ON PGPM_#qGetCoreTemplateFilter.Group_Level_ID#.BSA_Foodservice_Items_Master_ID = Product_Customer_Group.Product_ID
											INNER JOIN PG_Product_Category AS PGPC_#qGetCoreTemplateFilter.Group_Level_ID# ON PGPC_#qGetCoreTemplateFilter.Group_Level_ID#.PG_Product_Category_ID = PGPM_#qGetCoreTemplateFilter.Group_Level_ID#.PG_Product_Category_ID
										<!---<cfelse>
											INNER JOIN #qGetCoreTemplateFilter.Product_Group_Attribute_Table# ON #qGetCoreTemplateFilter.Product_Group_Attribute_Table#.#Product_Group_Attribute_ID_Field# = Product_Customer_Group.#Product_Group_Attribute_ID_Field#
										--->
										</cfif>
									</cfif>
								</cfloop>
							</cfif>
							
						</cfif>				
				WHERE	<cfif arguments.IncludeDeleted eq 0>
						#productGroupType.tableName#.Deleted = 0
						<cfelse>
						<!--- When a group gets deleted, still show it when program is revised, as the revision should have
							 all of the original program's groups and items	 
						--->
						1 = 1
						</cfif>
				 		<cfif productGroupType.tableName EQ "PG_Product_Category">
						  AND #productGroupType.tableName#.PG_Type_ID =  #productGroupType.GroupLevelID#
						<cfif (arguments.IncludeActiveOnly EQ 1)>  
				  	  		AND #productGroupType.tableName#.Active = 1
						</cfif> 
					  
				    </cfif>  
                            
                    <cfif bApplyPlannerTemplateFilter>
                    AND     EXISTS (
                        SELECT  1
                        FROM    All_product_Group_Type_Members m
                        INNER JOIN ##tmp_planner_template_filter_products p
                        ON p.Product_ID = m.BSA_Foodservice_Items_Master_ID
                        WHERE   m.Product_Group_ID = #productGroupType.tableName#.#productGroupType.IDField#
                    )
                    </cfif>
            
           <!---  <cfif productGroupType.tableName EQ "PG_Product_Category">
  			      AND PGTS.Distributor_Group_Level_ID =  #productGroupType.GroupLevelTypeID#
            </cfif> --->
            
						<cfif productGroupType.prodHierLevel GT 0>
						AND
						Product_Hierarchy_Level = #productGroupType.prodHierLevel#
						</cfif>
						
						<cfloop index="counter" from="1" to="#arAllowListLen#">
							<cfif arguments.arAllowLists[counter] NEQ "">
							AND #productGroupType.tableName#.#productGroupType.IDField# IN (#ListQualify(arguments.arAllowLists[counter], "'", ",")#)
							<cfelse>
							AND 1=2
							</cfif>
						</cfloop>
						
						<cfif arguments.excludeGroupList NEQ "">
						AND #productGroupType.IDField# NOT IN (#ListQualify(arguments.excludeGroupList, "'", ",")#)
						</cfif>
						<cfif businessSegmentId>
						AND	#productGroupType.tableName#.Business_Segment_Id = <cfqueryparam value="#arguments.businessSegmentId#" cfsqltype="CF_SQL_INTEGER">
						</cfif> <!---29675 MARKER--->
						<!--- ///////////////////////////////// Tim Ford - Label 29675:  Simplification of product group search /////////////////////////////////////////////////////////
						If the qGetCoreTemplateFilter query is defined, then we know we have to filter on the Product Group and Planning Group members defined for the programs template.
						The qGetCoreTemplateFilter query gets created in the FROM statement of this query 
						/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
						<cfif isDefined("qGetCoreTemplateFilter")>
							<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
							Loop over the query and find the Product Group ID in the planning group if the attribute is a planning group and it has a filter,
							or find the Product Group ID in the product group if the product group has a filter.
							/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
							<cfloop query="qGetCoreTemplateFilter">
								<cfif trim(qGetCoreTemplateFilter.Product_Group_Attribute_Table) neq trim(productGroupType.tableName) and qGetCoreTemplateFilter.Allow_Filter eq 1>
									<cfif qGetCoreTemplateFilter.Product_Group_Attribute_Table eq "PG_Product_Category">
										AND PGPM_#qGetCoreTemplateFilter.Group_Level_ID#.PG_Product_Category_ID IN
										(
											SELECT	Product_Group_ID 
											FROM	Product_Group_Template_Selection 
											WHERE	Deleted = 0 
											AND		Active = 1 
											AND		PG_Flag = 1 
											AND		Template_ID = #qGetCoreTemplateFilter.Template_ID# 
											AND		Product_Group_Level_ID = #qGetCoreTemplateFilter.Group_Level_ID#
										)
									<cfelse>
										AND CAST(BSA_Foodservice_Items_Master.#Product_Group_Attribute_ID_Field# AS NVARCHAR(50)) IN
										(
											SELECT	Product_Group_ID 
											FROM	Product_Group_Template_Selection 
											WHERE	Deleted = 0 
											AND		Active = 1 
											AND		PG_Flag = 0
											AND		Template_ID = #qGetCoreTemplateFilter.Template_ID# 
										)
									</cfif>
								</cfif>
							</cfloop>
						</cfif>
            
				Order By #productGroupType.tableName#.#productGroupType.NameField#
			</cfquery>

		</cfif>
 
		<cfreturn qGetProductGroupValues>
	
	</cffunction>
	
	<cffunction name="getProductGroupValuesForItem" output="false" returntype="query">
		<cfargument name="productGroupType" required="true" type="struct">
		<cfargument name="productIDList" required="false" type="string" default="">
		
		<cfset productGroupType = arguments.productGroupType />
 
  <cfquery name = "qryProdGroupLevelPGCheck" datasource="#application.datasource#">
   SELECT * FROM Product_Group_Level PGL INNER JOIN Product_Group_Attribute PGA ON PGL.Product_Group_Level_ID =  PGA.Product_Group_Level_ID 
    WHERE PGL.is_PG = 1 AND PGL.Product_Group_Level_ID = #arguments.productGroupType.GroupLevelID#
  </cfquery>
  <cfif qryProdGroupLevelPGCheck.RecordCount GTE 1>
    <cfquery name="qGetProductGroupValuesForItem" datasource="#application.datasource#">
      SELECT DISTINCT 
      BSA_Foodservice_Items_Master_ID Product_ID, 
      PG_Product_Category_ID As Group_ID 
      FROM  PG_Product_Members WHERE 
      1=1 
      <cfif arguments.productIDList NEQ "">
			  AND  PG_Product_Category_ID in  (#ListQualify(arguments.productIDList, "'", ",")#)
			<cfelse>
			  AND	1 = 2
		  </cfif>				
 
    </cfquery>
  <cfelse>
    <cfquery name="qGetProductGroupValuesForItem" datasource="#application.datasource#">
		  SELECT	DISTINCT 
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID Product_ID,
					#productGroupType.MasterIDField# As Group_ID					
			FROM	BSA_Foodservice_Items_Master
			<!------ Hierarchy higher levels ----->
			WHERE	1 = 1
					<cfif arguments.productIDList NEQ "">
					AND BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID IN (#ListQualify(arguments.productIDList, "'", ",")#)
					<cfelse>
					AND	1 = 2
					</cfif>					 
		</cfquery>

		</cfif>
		<cfreturn qGetProductGroupValuesForItem>
	
	</cffunction>
	
	<cffunction name="getProductGroupLabel" returntype="string" output="false">
		<cfargument name="groupLevelId" type="numeric" required="false" default="0" />
		
		<cfset returnValue = "" />
		
		<cfif arguments.groupLevelId eq 1><!------ Business Segment ----->
		
			<cfset returnValue = CreateObject("component","components.settings.ApplicationSettingsManager").get().getbusiness_segment_label() />
			
		<cfelseif arguments.groupLevelId eq 8><!------ Type Group ----->

			<cfset returnValue = application.returned_customer_setting.type_group_label_singular />
		
		<cfelseif arguments.groupLevelId eq 11><!------ QBrand ----->
			
			<cfset returnValue = application.returned_customer_setting.q_brand_label_singular />
		
		<cfelseif arguments.groupLevelId eq 12><!------ Type Code ----->
			
			<cfset returnValue = application.returned_customer_setting.type_code_label_singular />
		
		<cfelse>
		
			<cfset qGetProductGroupAttributes = getProductGroupAttributes(groupLevelId = arguments.groupLevelId) />
			<cfset returnValue = qGetProductGroupAttributes.Group_Level_Desc />
			
		</cfif>
		
		<cfreturn returnValue />
		
	</cffunction>
	
	<cffunction name="getProductGroupLabelFromQuery" returntype="string" output="false">
		<cfargument name="groupLevelId" type="numeric" required="true" />
		<cfargument name="qAllProductGroupAttributes" type="query" required="true" />
		
		<cfset returnValue = "" />
		
		<cfif arguments.groupLevelId eq 1><!------ Business Segment ----->
		
			<cfset returnValue = CreateObject("component","components.settings.ApplicationSettingsManager").get().getbusiness_segment_label() />
			
		<cfelseif arguments.groupLevelId eq 8><!------ Type Group ----->

			<cfset returnValue = application.returned_customer_setting.type_group_label_singular />
		
		<cfelseif arguments.groupLevelId eq 11><!------ QBrand ----->
			
			<cfset returnValue = application.returned_customer_setting.q_brand_label_singular />
		
		<cfelseif arguments.groupLevelId eq 12><!------ Type Code ----->
			
			<cfset returnValue = application.returned_customer_setting.type_code_label_singular />
		
		<cfelse>
			<cfquery name="qGetProductGroupAttributes" datasource="#application.datasource#">
        <!--- /* select	Group_Level_Desc
				from	arguments.qAllProductGroupAttributes
				where	Product_Group_Level_ID = #arguments.groupLevelId# */ --->
        
        SELECT	Group_Level_Desc
				FROM Product_Group_Level
				WHERE Product_Group_Level_ID = #arguments.groupLevelId# 
        
			</cfquery>
     
			<cfset returnValue = qGetProductGroupAttributes.Group_Level_Desc />
			
		</cfif>
		
		<cfreturn returnValue />
		
	</cffunction>
	
	<cffunction name="getProductGroupSelectionStruct" output="false" returntype="struct">
	
		<cfargument name="groupLevelID" type="numeric" required="true" />
		<cfargument name="groupId" type="string" required="true" />
		<cfargument name="includeProductGroupType" type="boolean" required="true" />
		
		<cfset groupSelectionStruct = StructNew() />
		<cfset groupSelectionStruct.Product_Group_Level_ID 	= arguments.groupLevelID />
		<cfset groupSelectionStruct.Group_ID 				= arguments.groupId />
		<cfif arguments.includeProductGroupType>
			<cfif arguments.groupLevelID EQ "">
				<cfset arguments.groupLevelID = "0" />
			</cfif>
 			<cfset groupSelectionStruct.productGroupType 	= getGroupTypeInfo(groupLevelId=arguments.groupLevelID) />
		</cfif>		
			
		<cfreturn groupSelectionStruct />
		
	</cffunction>
	
	<cffunction name="getProductLevelSearchFilterOn" output="false" returntype="boolean" hint="1=business sgement,2=family,3=buying group,4=line of business">
		<cfargument name="qGetProductGroupAttributes" type="query" required="true" />
		<cfargument name="productGroupLevelType" type="numeric" required="true" />
	
		<cfset returnValue = 0 />
	
		<cfquery name="qGetProductLevelSearchOn" dbtype="query">
			SELECT	Search_Filter_On
			FROM	arguments.qGetProductGroupAttributes
			WHERE	Product_Group_Level_Type = <cfqueryparam value="#arguments.productGroupLevelType#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
		<cfif qGetProductLevelSearchOn.recordCount>
			<cfset returnValue = qGetProductLevelSearchOn.Search_Filter_On />
		</cfif>
		
		<cfreturn returnValue />
	
	</cffunction>
	
<!--- ************************************************************************************************ --->
  <!--- 
    After the Planning Groups and Filter changes are implemented these functions are used to populate
    the dropdowns in the search page.
  ---->
<!--- ************************************************************************************************ --->  
  
  	<cffunction name="getProductGroupAttributesGroupTemplate" returntype="query" output="false">
		<cfargument name="groupLevelId" type="numeric" required="false" default="0" />
		<cfargument name="groupLevelTypeId" type="numeric" required="false" default="0" />
		<cfargument name="approvalLevelTypeId" type="numeric" required="false" default="0" />
		<cfargument name="active" type="numeric" required="false" default="-1" />
    	<cfargument name="FirstParentID" type="numeric" required="false" default="0" />
		<cfargument name="TemplateFiltersID" type="numeric" required="false" default="0" />
		<cfargument name="ExcludeGroupLevelType" type="string" required="false" default="" />
		
    	<cfset bValExists = "0" />
    	<cfif arguments.FirstParentID NEQ 0>
    
			<!---  SELECT Group_Level_ID FROM Group_Template
		         WHERE Template_ID =  #arguments.FirstParentID#     
		 	--->
	     	<!--- NOT USED BELOW ??? MWS
		 	<cfquery name="qGetGroupTemplate" datasource="#application.datasource#">
		        SELECT DISTINCT 
		          GT.Group_Level_ID,
		          GT.Allow_In_Search,
		          GT.Allow_In_Group_Search,
		          GT.Allow_Filter,
				  GT.PG_Flag,
			  	  PGA.* 
		        FROM 
		        Group_Template GT
		        INNER JOIN Product_Group_Attribute PGA ON PGA.Product_Group_Level_ID = GT.Group_Level_ID
		        WHERE GT.Template_ID =  #arguments.FirstParentID#     
		         AND GT.Active = 1 
		         AND GT.Deleted = 0
		         AND GT.PG_Group_Type = 1
		         AND GT.Allow_In_Search = 1        
	      	</cfquery>--->
	    
	      <!--- <cfloop query="qGetGroupTemplate">
	        <cfif qGetGroupTemplate.Group_Level_ID EQ DistributorGroupAttributeInfo.GroupLevelTypeID>
	          <cfset bValExists = "1" />
	        </cfif>
	      </cfloop> --->
    	</cfif>
    
  		<!---  NOT USED ??? MWS
	  	<cfif (arguments.FirstParentID NEQ 0 AND isDefined("qGetGroupTemplate") AND qGetGroupTemplate.RecordCount GTE 1)>
	   		<cfset qGroupTypeInfo = this.getGroupTypeInfo(groupLevelTypeId = arguments.groupLevelTypeId) />  	
    	</cfif>--->
    
		<cfif (arguments.FirstParentID NEQ 0 AND arguments.FirstParentID NEQ -1)>
			<cfquery name="qGetProductsAttributes" datasource="#application.datasource#">
				SELECT	DISTINCT GT.Template_ID, 
					GT.Group_Level_ID, 
					GT.PG_Group_Type, 
					GT.Allow_In_Search,
			        GT.Allow_In_Group_Search, 
			        GT.Active, GT.Deleted,  
			        GT.PG_Flag, 
			        GT.Allow_Filter,
			        PGL.List_Order,
			        PGL.Group_Level_Desc,
			        PGA.*
				FROM	Group_Template GT
				<cfif isNumeric(arguments.TemplateFiltersID) AND arguments.TemplateFiltersID NEQ 0>
					INNER JOIN Product_Group_Template_Selection PGTS ON
						GT.Template_ID = PGTS.Template_ID AND
						GT.Group_level_Id = PGTS.Product_Group_Level_ID AND
						PGTS.Template_Filters_Id = #arguments.TemplateFiltersID#
				</cfif>
				INNER JOIN Product_Group_Attribute PGA ON 
					PGA.Product_Group_Level_ID = GT.Group_Level_ID
				LEFT JOIN Product_Group_Level PGL ON 
					PGL.Product_Group_Level_ID = GT.Group_Level_ID
				
				LEFT JOIN PG_Type PGT ON PGT.PG_Type_ID =  GT.Group_Level_ID					
				
				WHERE	GT.Deleted = 0 
			   	AND 	GT.PG_Group_Type = 1 
				AND 	(PGL.IS_PG = 0 OR PGT.Active = 1)
				<cfif arguments.Active NEQ -1>
					AND		GT.Active = <cfqueryparam value="#arguments.Active#" cfsqltype="CF_SQL_BIT">
				</cfif>			
				<cfif arguments.FirstParentID NEQ -1>
					AND 	GT.Template_ID = <cfqueryparam value="#arguments.FirstParentID#" cfsqltype="CF_SQL_INTEGER" />
				</cfif>
				<cfif arguments.ExcludeGroupLevelType neq "">
					AND PGL.Product_Group_Level_Type != '#arguments.ExcludeGroupLevelType#'
				</cfif>
				ORDER BY PGL.List_Order ASC
			</cfquery>
		<cfelse>
			<cfquery name="qGetProductsAttributes" datasource="#application.datasource#">
				SELECT DISTINCT 
						PGL.Product_Group_Level_ID AS Group_Level_ID,
						PGL.Group_Level_Desc, 
						PGL.Search_Filter_On AS Allow_In_Search,
						PGL.Is_PG as PG_Flag,
						0 as Allow_Filter,
						PGL.List_Order,
						PGA.*
				FROM	Product_Group_Level PGL
				INNER JOIN Product_Group_Attribute PGA 
				ON 		PGA.Product_Group_Level_ID = PGL.Product_Group_Level_ID 
				AND 	PGA.Deleted = 0
				WHERE	PGL.Deleted = 0 
				AND PGL.Active = 1
				AND PGL.Search_Filter_On = 1
				<cfif arguments.ExcludeGroupLevelType neq "">
					AND PGL.Product_Group_Level_Type != '#arguments.ExcludeGroupLevelType#'
				</cfif>
				ORDER BY PGL.List_Order ASC
			</cfquery>		
		</cfif>
    
		<cfreturn qGetProductsAttributes />
	</cffunction>
  

  <cffunction name="getProductLevelSearchFilterOnGroupTemplate" output="false" returntype="boolean" hint="1=business sgement,2=family,3=buying group,4=line of business">
		<cfargument name="qGetProductGroupAttributes" type="query" required="true" />
		<cfargument name="productGroupLevelType" type="numeric" required="true" />
		<cfset returnValue = 0 />
		<!--- Only run query of query if here is data --->
		<cfif qGetProductGroupAttributes.recordcount>
		    <cfquery name="qGetProductLevelSearchOn" dbtype="query">
					SELECT	Allow_In_Search
					FROM	arguments.qGetProductGroupAttributes
					WHERE	Group_Level_ID = <cfqueryparam value="#arguments.qGetProductGroupAttributes.Group_Level_ID#" cfsqltype="CF_SQL_INTEGER"><!--- #arguments.productGroupLevelType#  OR arguments.qGetProductGroupAttributes.Group_Level_ID --->
		    </cfquery>
		
			<cfif qGetProductLevelSearchOn.recordCount>
				<cfset returnValue = qGetProductLevelSearchOn.Allow_In_Search />
			</cfif>
		</cfif>
		<cfreturn returnValue />
	
	</cffunction>
	
	<!--- D42821: Add Group Number to Product Rebate Entry Screen --->
	
	<cffunction name="getProductGroupsForCreateList" output="false" returntype="query">
		<cfargument name="ProductGroupLevelTypes" required="true" type="string" default="">
		<cfargument name="PassedObject" required="true" type="array" default="">
 
 		<cfquery name="create_temp_table" datasource="#application.datasource#">
			IF object_id('tempdb..##ProductGroupList2') IS NOT NULL
			BEGIN	 
			     DROP TABLE ##ProductGroupList2
			END
			CREATE TABLE ##ProductGroupList2(
					[Group_Level_Desc] [varchar](max),
			  		[Product_Group_ID] [varchar](max),
			[Group_ID] [varchar](max),
			[Product_Group_Level_ID] [varchar](max),
			[Product_Group_Level_Type] [varchar](max),
			[Hierarchy_Level] [varchar](max),
			[Parent_Hierarchy_ID] [varchar](max)
				)
		</cfquery>	
		<cfloop index="j" from="1" to="#ArrayLen(arguments.PassedObject)#" step="1">
			<cfset singleItemToBeValidated = #arguments.PassedObject[j]# /> 
			<cfloop index = "i" list = "#arguments.ProductGroupLevelTypes#"  delimiters = ",">  
	 			<cfset productGroupType = this.getGroupTypeInfo(groupLevelTypeId = #i#) />
				<cfif (singleItemToBeValidated NEQ "")>
					<cfquery NAME="qryInsIntoTempTable" DATASOURCE="#application.datasource#">
						INSERT INTO ##ProductGroupList2
						SELECT	DISTINCT #productGroupType.tableName#.#productGroupType.NameField# As Group_Level_Desc, 
										 #productGroupType.tableName#.#productGroupType.IDField# As Product_Group_ID,
										 #productGroupType.tableName#.#productGroupType.NumberField# As Group_ID,
										 #productGroupType.groupLevelID# As Product_Group_Level_ID,  
										 #productGroupType.groupLevelType# As Product_Group_Level_Type,
			 							 '' As Hierarchy_Level,
										 '' As Parent_Hierarchy_ID
						FROM	#productGroupType.tableName#
						WHERE  (
							<cfif application.appSettingsget.getExact_List_Matching_On() IS 1>
								#productGroupType.tableName#.#productGroupType.NameField# = <cfqueryparam value="#trim(singleItemToBeValidated)#" cfsqltype="cf_sql_varchar"> OR 
							 	#productGroupType.tableName#.#productGroupType.NumberField# = <cfqueryparam value="#trim(singleItemToBeValidated)#" cfsqltype="cf_sql_varchar">				
							<cfelse>
								#productGroupType.tableName#.#productGroupType.NameField# LIKE <cfqueryparam value="%#trim(singleItemToBeValidated)#%" cfsqltype="cf_sql_varchar"> OR 
							 	#productGroupType.tableName#.#productGroupType.NumberField# LIKE <cfqueryparam value="%#trim(singleItemToBeValidated)#%" cfsqltype="cf_sql_varchar">						
							</cfif>)
							AND #productGroupType.tableName#.Deleted = 0
							<cfif (productGroupType.groupLevelType GTE 2000)>
								AND PG_Product_Category.PG_Type_ID = #productGroupType.groupLevelType#
							</cfif>
							-- select * from ##ProductGroupList2
					</CFQUERY>
					 
				</cfif>
		</cfloop>		
	</cfloop>
	<cfquery name="temptabledump" datasource="#application.datasource#">		
		SELECT 	tmp.Group_Level_Desc,
		  		tmp.Product_Group_ID,
				tmp.Group_ID,
				tmp.Product_Group_Level_ID,
				tmp.Product_Group_Level_Type,
				tmp.Hierarchy_Level,
				tmp.Parent_Hierarchy_ID,
				pgl.Group_Level_Desc  AS Parent_Group_Level_Desc
		 FROM ##ProductGroupList tmp
		 INNER JOIN Product_group_Level PGL ON PGL.Product_Group_Level_Type = tmp.Product_Group_Level_Type
	</cfquery>		
	<cfreturn temptabledump />
	</cffunction>
	
  
</cfcomponent>