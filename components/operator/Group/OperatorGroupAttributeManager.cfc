<cfcomponent displayname="OperatorGroupAttributeManager" hint="Operator Group Attribute Manager" extends="components.Base">
	
  <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
  
	<cffunction name="init" returntype="components.operator.group.OperatorGroupAttributeManager" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getOperatorGroupAttributes" returntype="query" output="false">
		<cfargument name="groupLevelTypeId" type="numeric" required="false" default="0" />
		<cfargument name="bActive" type="numeric" required="false" default="-1" />
		
		<cfquery name="qGetOperatorsAttributes" datasource="#application.datasource#">
			SELECT	*
			FROM	Operator_Group_Level			
			WHERE	Operator_Group_Level.Deleted = 0
			
			<cfif arguments.groupLevelTypeId NEQ 0>
			AND		Operator_Group_Level.Operator_Group_Level_Type_ID = #arguments.groupLevelTypeId#<!------ <cfqueryparam value="#arguments.groupLevelTypeId#" cfsqltype="CF_SQL_INTEGER"> ----->
			</cfif>			
			<cfif arguments.bActive NEQ -1>
			AND		Operator_Group_Level.Active = <cfqueryparam value="#arguments.bActive#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
		</cfquery>
		
		<cfreturn qGetOperatorsAttributes />
		
	</cffunction>
	
  
<cffunction name="getOperatorGroupAttributesMultiple" returntype="query" output="false">
	<cfargument name="groupLevelTypeId" type="String" required="false" default="0" />
<!--- 		
	<cfargument name="groupLevelId" type="String" required="false" default="0" />
		<cfargument name="approvalLevelTypeId" type="numeric" required="false" default="0" /> --->
		<cfargument name="bActive" type="numeric" required="false" default="-1" />
		
		<cfquery name="qGetOperatorAttributes" datasource="#application.datasource#">
			SELECT	PGOC.*, OGL.*
			FROM	PG_Operator_Category PGOC
      INNER JOIN Operator_Group_Level OGL
      ON PGOC.PG_Type_ID = OGL.Operator_Group_Level_Type_ID
      WHERE	PGOC.Deleted = 0
      AND OGL.Deleted = 0 
       <!--- Do not Select planning groups if the appsetting is OFF./Anand Rao/10-Jan-2011--->
      <cfif NOT(appSettings.getPlanningGroups())>
       AND OGL.Is_PG = 0
      </cfif>
			<cfif arguments.groupLevelTypeId NEQ 0>
			AND		PGOC.PG_Operator_Category_ID in ('#Replace(arguments.groupLevelTypeId,",","','")#')
			</cfif>
<!--- 			<cfif arguments.approvalLevelTypeId NEQ 0>
			AND		ISNULL(Product_Group_Level.Approval_Group_Type, Product_Group_Level.Product_Group_Level_ID) = #arguments.approvalLevelTypeId#
			</cfif> --->
			
<!--- 		
			<cfif arguments.groupLevelId NEQ 0>
			AND		Product_Group_Attribute.Product_Group_Level_ID = #arguments.groupLevelId#
			</cfif> --->
			<cfif arguments.bActive NEQ -1>
			AND		PGOC.Active = #arguments.bActive#
			</cfif>
		</cfquery>
		
		<cfreturn qGetOperatorAttributes />
		
	</cffunction>     
  
	<cffunction name="getGroupAttributeInfo" output="true" returntype="struct">	
		<cfargument name="groupLevelTypeId" type="numeric" required="false" default="0" />
		
		<cfset qGetOperatorGroupLevel		= getOperatorGroupAttributes(groupLevelTypeId = arguments.groupLevelTypeId) />
		
		<cfset OperatorGroupAttributeInfo = StructNew() />
		<!------ Get the table infor form Operator group attributes ----->
		<cfif qGetOperatorGroupLevel.recordCount>			
			<cfset OperatorGroupAttributeInfo.groupLevelId			= qGetOperatorGroupLevel.Operator_Group_Level_ID>
			<cfset OperatorGroupAttributeInfo.tableName 				= qGetOperatorGroupLevel.Operator_Group_Attribute_Table />
			<cfset OperatorGroupAttributeInfo.IDField 				= qGetOperatorGroupLevel.Operator_Group_Attribute_ID_Field />
			<cfset OperatorGroupAttributeInfo.MasterIDField 			= qGetOperatorGroupLevel.Operator_Group_Attribute_Master_ID_Field />
			<cfset OperatorGroupAttributeInfo.NameField 				= qGetOperatorGroupLevel.Operator_Group_Attribute_Name_Field />
			<cfset OperatorGroupAttributeInfo.NumberField 				= qGetOperatorGroupLevel.Operator_Group_Attribute_Number_Field />
			<cfset OperatorGroupAttributeInfo.Label 					= getOperatorGroupLabel(arguments.groupLevelTypeId, qGetOperatorGroupLevel.Group_Level_Desc) />
			<cfset OperatorGroupAttributeInfo.groupLevelTypeId		= qGetOperatorGroupLevel.Operator_Group_Level_Type_ID />
		</cfif>	
		<cfreturn OperatorGroupAttributeInfo/>
	
	</cffunction>
	
	<cffunction name="getOperatorGroupValues" output="false" returntype="query">
		<cfargument name="OperatorGroupAttributeInfo" required="true" type="struct" />
		<cfargument name="businessSegmentId" required="false" type="numeric" default="0" />
		<cfargument name="groupId" required="false" default="0" />
		<cfargument name="cachedwithin" required="false" default="#CreateTimeSpan(0, 0, 0, 0)#" />
    <cfargument name="TemplateID" required="false" default = "0" />
		<cfargument name="ExcludeOprID" required="false" default = "0" />
		<cfargument name="IncludeIOPGFlag" required="false" default = "0" />
		
    
    <Cfif arguments.TemplateID NEQ 0>
    <!--- 
      if the Allow Filter is checked in the Customer filter screen then get data from the 
    Customer_Group_Template_Selection table else get all the values.
    --->
    
    
    </cfif>
		<!--- 
    select	* 
    from	customer_group_template_selection
inner join Operator_Buying_Groups
on		Operator_Buying_Groups.Buying_Group_ID = customer_group_template_selection.Operator_group_ID
Where	customer_group_template_selection.Template_ID = 526
and		customer_group_template_selection.Operator_Group_level_ID =3
    --->
    
		<cfset OperatorGroupAttributeInfo = arguments.OperatorGroupAttributeInfo />
		
    <cfset bValExists = "0" />
    <cfif arguments.TemplateID NEQ 0>
      <cfquery name="qGetGroupTemplate" datasource="#application.datasource#">
         SELECT DISTINCT Group_Level_ID,Allow_In_Group_Search,Allow_Filter FROM Group_Template
         WHERE Template_ID =  #arguments.TemplateID#     
         AND Active = 1 
         AND Deleted = 0
         AND PG_Group_Type = 3
      </cfquery>
      <cfloop query="qGetGroupTemplate">
        <cfif qGetGroupTemplate.Group_Level_ID EQ OperatorGroupAttributeInfo.GroupLevelTypeID AND qGetGroupTemplate.Allow_Filter EQ 1>
          <cfset bValExists = "1" />
        </cfif>
      </cfloop>
    </cfif>
    
 
    <cfif arguments.TemplateID NEQ 0 AND qGetGroupTemplate.RecordCount GTE 1 AND bValExists EQ "1">
      <cfquery name="qGetOperatorGroupValues" datasource="#application.datasource#" ><!--- cachedwithin="#arguments.cachedwithin#" --->
        SELECT	DISTINCT
                DMEMT.#OperatorGroupAttributeInfo.NameField# As Group_Name, 
  					    DMEMT.#OperatorGroupAttributeInfo.IDField# As Group_ID,
								DMEMT.#OperatorGroupAttributeInfo.NumberField# As Group_Number
  			FROM	Operator_Group_Template_Selection  OGTS
        INNER JOIN #OperatorGroupAttributeInfo.tableName#	DMEMT		
        ON CAST(DMEMT.#OperatorGroupAttributeInfo.IDField# AS VARCHAR(50))   = 	OGTS.Operator_Group_ID	
  			WHERE	 DMEMT.Deleted = 0 
  			AND 	DMEMT.#OperatorGroupAttributeInfo.NameField# IS NOT NULL
        AND   OGTS.Template_id = #arguments.TemplateID#
        AND   OGTS.Operator_Group_level_ID = #OperatorGroupAttributeInfo.GroupLevelTypeID#
        AND OGTS.Active = 1 AND OGTS.Deleted = 0
        <cfif OperatorGroupAttributeInfo.tableName NEQ "PG_Operator_Category">
  			<!---  AND CGTS.Operator_Group_Level_ID =  #OperatorGroupAttributeInfo.GroupLevelTypeID#
        <cfelse>   --->
          AND		Len(DMEMT.#OperatorGroupAttributeInfo.NameField#) > 0
						<cfif arguments.IncludeIOPGFlag	EQ "1">
							AND DMEMT.Include_In_Other_PG = 1
						</cfif>
				</cfif>
        <cfif arguments.businessSegmentId NEQ 0>
  			AND		DMEMT.#OperatorGroupAttributeInfo.tableName#.Business_segment_id = '#arguments.businessSegmentId#'
  			</cfif>
  			<cfif arguments.groupId NEQ 0>
  				AND		DMEMT.#OperatorGroupAttributeInfo.tableName#.#OperatorGroupAttributeInfo.IDField# = '#arguments.groupId#'
  			</cfif>
 				<cfif arguments.ExcludeOprID NEQ 0>
					AND		DMEMT.#OperatorGroupAttributeInfo.tableName#.#OperatorGroupAttributeInfo.IDField# NOT IN ('#arguments.ExcludeOprID#')
				</cfif>	 
  			Order By DMEMT.#OperatorGroupAttributeInfo.NameField#    
      </cfquery>
 
     <cfelse>
    
      <cfquery name="qGetOperatorGroupValues" datasource="#application.datasource#" ><!--- cachedwithin="#arguments.cachedwithin#" --->
  			SELECT	DISTINCT
                #OperatorGroupAttributeInfo.NameField# As Group_Name, 
  					    #OperatorGroupAttributeInfo.IDField# As Group_ID,
								#OperatorGroupAttributeInfo.NumberField# As Group_Number								
  			FROM	#OperatorGroupAttributeInfo.tableName#			
  			WHERE	#OperatorGroupAttributeInfo.tableName#.Deleted = 0
  			AND 	#OperatorGroupAttributeInfo.NameField# IS NOT NULL
        
        <cfif OperatorGroupAttributeInfo.tableName EQ "PG_Operator_Category">
  			 AND PG_Type_ID =  #OperatorGroupAttributeInfo.GroupLevelTypeID#
         AND Active = 1 AND Deleted = 0
					<cfif arguments.IncludeIOPGFlag	EQ "1">
						AND Include_In_Other_PG = 1
					</cfif>
        <cfelse>  
          AND		Len(#OperatorGroupAttributeInfo.NameField#) > 0
  			</cfif>
 				<cfif arguments.ExcludeOprID NEQ 0>
				AND		#OperatorGroupAttributeInfo.tableName#.#OperatorGroupAttributeInfo.IDField# NOT IN ('#arguments.ExcludeOprID#')
				</cfif>		 
        <cfif arguments.businessSegmentId NEQ 0>
  			AND		#OperatorGroupAttributeInfo.tableName#.Business_segment_id = '#arguments.businessSegmentId#'
  			</cfif>
  			<cfif arguments.groupId NEQ 0>
  			AND		#OperatorGroupAttributeInfo.tableName#.#OperatorGroupAttributeInfo.IDField# = '#arguments.groupId#'
  			</cfif>
  			Order By #OperatorGroupAttributeInfo.NameField#
  		</cfquery>
		</cfif>
		
    
    
    <cfreturn qGetOperatorGroupValues>
	
	</cffunction>
	
	<cffunction name="getOperatorGroupLabel" returntype="string" output="false">
		<cfargument name="groupLevelTypeId" type="numeric" required="false" default="0" />
		<cfargument name="defaultOperatorGroupLabel" type="string" required="true" default="" />
		
		<cfset returnValue = "" />
		
		<cfif arguments.groupLevelTypeId eq 1><!------ Business Segment ----->
		
			<cfset returnValue = CreateObject("component","components.settings.ApplicationSettingsManager").get().getbusiness_segment_label() />
			
		<cfelseif arguments.groupLevelTypeId eq 2><!------ Family ----->

			<cfset returnValue = application.returned_customer_setting.family_name_label_singular />
		
		<cfelseif arguments.groupLevelTypeId eq 3><!------ Buying Group ----->
			
			<cfset returnValue = application.returned_customer_setting.buying_group_label_singular />
		
		<cfelseif arguments.groupLevelTypeId eq 4><!------ Line Of Business ----->
			
			<cfset returnValue = application.returned_customer_setting.lob_label_singular />
		
		<cfelseif arguments.groupLevelTypeId eq 5><!------ Cust ID ----->
			
			<cfset returnValue = application.returned_customer_setting.Customer_Id_Label />
		
		<cfelse>
		
			<cfif arguments.defaultOperatorGroupLabel NEQ "">
				<cfset returnValue = arguments.defaultOperatorGroupLabel />
			<cfelse>
				<cfset qGetOperatorGroupAttributes = getOperatorGroupAttributes(groupLevelTypeId = arguments.groupLevelTypeId) />
				<cfset returnValue = qGetOperatorGroupAttributes.Group_Level_Desc />
			</cfif>			
			
		</cfif>
		
		<cfreturn returnValue />
		
	</cffunction>
	
  
	<cffunction name="getOperatorGroups" output="false" returntype="query">
	
		<cfargument name="groupList" required="false" type="string" default="">
		
		<cfif this.approvalGroupType.tableName EQ "">
			<cfset this.getGroupTypeInfo() />
		</cfif>
	
		<cfset qGetApprovalGroups = this.productGroupAttributeManager.getProductGroupValues(this.approvalGroupType, arguments.groupList) />
		
		<cfreturn qGetApprovalGroups>
	
	</cffunction>
  
	<!--- <cffunction name="getGroupTypeInfo" output="false" returntype="struct">	
		<cfargument name="productGroupLevelId" type="numeric" required="false" default="0" />
		
		<cfif arguments.productGroupLevelId EQ 0><!------ If nothing is passed in, get the approval group type from customer settings ----->
			<cfset this.approvalGroupType.groupType			= application.returned_customer_setting.approval_on_type_code>
			
			<cfset this.approvalGroupType					= this.productGroupAttributeManager.getGroupTypeInfo(approvalLevelTypeId = this.approvalGroupType.groupType) />
		<cfelse>
			<cfset this.approvalGroupType					= this.productGroupAttributeManager.getGroupTypeInfo(groupLevelId = arguments.productGroupLevelId) />
		</cfif>
		
		<cfreturn this.approvalGroupType/>
	
	</cffunction>   --->
    
    
 
</cfcomponent>