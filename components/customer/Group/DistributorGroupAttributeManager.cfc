<cfcomponent displayname="DistributorGroupAttributeManager" hint="Distrbutor Group Attribute Manager" extends="components.Base">

	<cffunction name="init" returntype="components.customer.group.DistributorGroupAttributeManager" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getDistributorGroupAttributes" returntype="query" output="false">
		<cfargument name="groupLevelTypeId" type="numeric" required="false" default="0" />
		<cfargument name="active" type="numeric" required="false" default="-1" />
		
		<cfquery name="qGetDistributorsAttributes" datasource="#application.datasource#">
			SELECT	*
			FROM	Distributor_Group_Level			
			WHERE	Distributor_Group_Level.Deleted = 0
			
			<cfif arguments.groupLevelTypeId NEQ 0>
			AND		Distributor_Group_Level.Distributor_Group_Level_Type_ID = #arguments.groupLevelTypeId#<!------ <cfqueryparam value="#arguments.groupLevelTypeId#" cfsqltype="CF_SQL_INTEGER"> ----->
			</cfif>			
			<cfif arguments.active NEQ -1>
			AND		Distributor_Group_Level.Active = <cfqueryparam value="#arguments.active#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
		</cfquery>
		
		<cfreturn qGetDistributorsAttributes />
		
	</cffunction>
	
	<cffunction name="getGroupAttributeInfo" output="true" returntype="struct">	
		<cfargument name="groupLevelTypeId" type="numeric" required="false" default="0" />
		
		<cfset qGetDistributorGroupLevel		= getDistributorGroupAttributes(groupLevelTypeId = arguments.groupLevelTypeId) />
		
		<cfset DistributorGroupAttributeInfo = StructNew() />
		<!------ Get the table infor form Distributor group attributes ----->
		<cfif qGetDistributorGroupLevel.recordCount>			
			<cfset DistributorGroupAttributeInfo.groupLevelId			= qGetDistributorGroupLevel.Distributor_Group_Level_ID>
			<cfset DistributorGroupAttributeInfo.tableName 				= qGetDistributorGroupLevel.Distributor_Group_Attribute_Table />
			<cfset DistributorGroupAttributeInfo.IDField 				= qGetDistributorGroupLevel.Distributor_Group_Attribute_ID_Field />
			<cfset DistributorGroupAttributeInfo.MasterIDField 			= qGetDistributorGroupLevel.Distributor_Group_Attribute_Master_ID_Field />
			<cfset DistributorGroupAttributeInfo.NameField 				= qGetDistributorGroupLevel.Distributor_Group_Attribute_Name_Field />
			<cfset DistributorGroupAttributeInfo.NumberField 			= qGetDistributorGroupLevel.Distributor_Group_Attribute_Number_Field />
			<cfset DistributorGroupAttributeInfo.Label 					= getDistributorGroupLabel(arguments.groupLevelTypeId, qGetDistributorGroupLevel.Group_Level_Desc) />
			<cfset DistributorGroupAttributeInfo.groupLevelTypeId		= qGetDistributorGroupLevel.Distributor_Group_Level_Type_ID />
		</cfif>	
		<cfreturn DistributorGroupAttributeInfo/>
	
	</cffunction>
	
	<cffunction name="getDistributorGroupValues" output="false" returntype="query">
		<cfargument name="DistributorGroupAttributeInfo" required="true" type="struct" />
		<cfargument name="BusinessSegmentId" required="false" default="0" />
		<cfargument name="groupId" required="false" default="0" />
		<cfargument name="cachedwithin" required="false" default="#CreateTimeSpan(0, 0, 0, 0)#" />
        <cfargument name="TemplateID" required="false" default = "0" />
		<cfargument name="ExcludeDistID" required="false" default = "0" />
		<cfargument name="IncludeIOPGFlag" required="false" default = "0" />		
		<cfargument name="TemplateFiltersID" type="numeric" required="false" default="0" />
    <!--- <Cfif arguments.TemplateID NEQ 0>
    <!--- 
      if the Allow Filter is checked in the Customer filter screen then get data from the 
    Customer_Group_Template_Selection table else get all the values.
    --->
    
    </cfif> --->
		<!--- 
    select	* 
    from	customer_group_template_selection
inner join Distributor_Buying_Groups
on		Distributor_Buying_Groups.Buying_Group_ID = customer_group_template_selection.Distributor_group_ID
Where	customer_group_template_selection.Template_ID = 526
and		customer_group_template_selection.Distributor_Group_level_ID =3
    --->
    
		<cfset DistributorGroupAttributeInfo = arguments.DistributorGroupAttributeInfo />
		 
    <cfset bValExists = "0" />
    <cfif arguments.TemplateID NEQ 0>
      <cfquery name="qGetGroupTemplate" datasource="#application.datasource#">
         SELECT DISTINCT Group_Level_ID,Allow_In_Group_Search,Allow_Filter 
		 FROM Group_Template
         WHERE Template_ID =  #arguments.TemplateID#     
         AND Active = 1 
         AND Deleted = 0
         AND PG_Group_Type = 2
      </cfquery>
      <cfloop query="qGetGroupTemplate">
        <cfif qGetGroupTemplate.Group_Level_ID EQ DistributorGroupAttributeInfo.GroupLevelTypeID AND qGetGroupTemplate.Allow_Filter EQ 1>
          <cfset bValExists = "1" />
        </cfif>
      </cfloop>
    </cfif>
    
 
    <cfif arguments.TemplateID NEQ 0 AND qGetGroupTemplate.RecordCount GTE 1 AND bValExists EQ "1">
      <cfquery name="qGetDistributorGroupValues" datasource="#application.datasource#" ><!--- cachedwithin="#arguments.cachedwithin#" --->
        SELECT	DISTINCT
                DMEMT.#DistributorGroupAttributeInfo.NameField# As Group_Name, 
  				DMEMT.#DistributorGroupAttributeInfo.IDField# As Group_ID,
				DMEMT.#DistributorGroupAttributeInfo.NumberField# As Group_Number
  		FROM	Customer_Group_Template_Selection  CGTS
        INNER JOIN #DistributorGroupAttributeInfo.tableName#	DMEMT		
        ON CAST(DMEMT.#DistributorGroupAttributeInfo.IDField# AS VARCHAR(50))   = 	CGTS.Distributor_Group_ID	
  		WHERE	 DMEMT.Deleted = 0 
  		AND 	DMEMT.#DistributorGroupAttributeInfo.NameField# IS NOT NULL
        AND   	CGTS.Template_id = #arguments.TemplateID#
        AND  	CGTS.Distributor_Group_level_ID = #DistributorGroupAttributeInfo.GroupLevelTypeID#
        AND 	CGTS.Active = 1 
		AND 	CGTS.Deleted = 0
        <cfif DistributorGroupAttributeInfo.tableName NEQ "PG_Customer_Category">
  			<!---  AND CGTS.Distributor_Group_Level_ID =  #DistributorGroupAttributeInfo.GroupLevelTypeID#
        <cfelse>   --->
        AND		Len(DMEMT.#DistributorGroupAttributeInfo.NameField#) > 0
					<cfif arguments.IncludeIOPGFlag	EQ "1">
		AND    DMEMT.Include_In_Other_PG = 1
					</cfif>
  			</cfif>
        			<cfif arguments.businessSegmentId neq "0" and arguments.businessSegmentId neq "">
  		AND		DMEMT.Business_segment_id IN (#arguments.businessSegmentId#)
  					</cfif>
  					<cfif arguments.groupId NEQ 0>
  		AND		DMEMT.#DistributorGroupAttributeInfo.IDField# = '#arguments.groupId#'
  					</cfif>
					<cfif arguments.ExcludeDistID NEQ 0>
						<!--- D31968 : Planning Groups - App Error Revising Plan Grps START --->
		AND		CAST(DMEMT.#DistributorGroupAttributeInfo.IDField# AS VARCHAR(50)) NOT IN ('#arguments.ExcludeDistID#')
						<!--- D31968 : Planning Groups - App Error Revising Plan Grps END --->
					</cfif>
		<cfif arguments.TemplateFiltersID NEQ 0 and isNumeric(arguments.TemplateFiltersID)>
			AND CGTS.Template_Filters_Id = <cfqueryparam value="#arguments.TemplateFiltersID#" cfsqltype="CF_SQL_INTEGER">
		</cfif>
  		Order By DMEMT.#DistributorGroupAttributeInfo.NameField#    
      </cfquery>
      <!--- if --->
  
    <cfelse>
    
		<cfif (DistributorGroupAttributeInfo.tableName NEQ "PG_Customer_Category")>
			<cfset cachedVar = arguments.cachedwithin />
		<cfelse>
			<cfset cachedVar = CreateTimeSpan(0,0,0,0)> />
		</cfif>
		
		<cfif application.appSettingsGet.getPositionFieldsFilterOnProgramSegment() EQ 0 AND (DistributorGroupAttributeInfo.tableName EQ "Service_Zones" OR DistributorGroupAttributeInfo.tableName EQ "Service_Regions" OR DistributorGroupAttributeInfo.tableName EQ "Service_Markets")>
			<cfset arguments.businessSegmentId = 0 />
		</cfif>
		
		<cfquery name="qGetDistributorGroupValues" datasource="#application.datasource#"  cachedwithin= "#cachedVar#" >
			SELECT	DISTINCT
					tbl.#DistributorGroupAttributeInfo.NameField# As Group_Name, 
					tbl.#DistributorGroupAttributeInfo.IDField# As Group_ID,
					tbl.#DistributorGroupAttributeInfo.NumberField# As Group_Number
			FROM	#DistributorGroupAttributeInfo.tableName# tbl	
		<cfif application.appsettingsget.getSuppressGroupsZeroItems() AND application.appSettingsget.get_Setting('GPO_One_Page_Program_Creation') EQ 0>
			<cfif DistributorGroupAttributeInfo.tableName EQ "PG_Customer_Category">
				INNER JOIN PG_Customer_Members m
				ON		m.PG_Customer_Category_ID = tbl.PG_Customer_Category_ID
				AND	m.Deleted = 0
				INNER JOIN BSA_Foodservice_Customers BSA
				ON 	BSA.BSA_Foodservice_Customers_ID = m.BSA_Foodservice_Customers_ID
				AND     BSA.Ship_To != 'Group'
				AND     BSA.Active_Code = 'A'
				AND     BSA.Deleted = 0
			<cfelse>
				<cfif DistributorGroupAttributeInfo.tableName EQ "Service_Markets">
					<cfif (application.appSettingsGet.getDistributorMultiPosition() eq 0)>
						INNER JOIN BSA_foodservice_Brokers b ON b.Service_market_ID = tbl.Service_Market_ID
						INNER JOIN BSA_Foodservice_Customers BSA
						ON       BSA.BSA_foodservice_Brokers_ID = b.BSA_foodservice_Brokers_ID
					<cfelse>
						INNER JOIN Market_Distributor md ON md.Service_market_ID = tbl.Service_Market_ID and md.Deleted = 0
						INNER JOIN BSA_Foodservice_Customers BSA
						ON       BSA.BSA_Foodservice_Customers_ID = md.Distributor_ID
					</cfif>
				<cfelseif DistributorGroupAttributeInfo.tableName EQ "Service_Regions">
					<cfif (application.appSettingsGet.getDistributorMultiPosition() eq 0)>
						INNER JOIN Service_Markets m ON m.Service_Region_ID = tbl.Service_Region_ID
						INNER JOIN BSA_foodservice_Brokers b ON b.Service_market_ID = m.Service_Market_ID
						INNER JOIN BSA_Foodservice_Customers BSA
						ON       BSA.BSA_foodservice_Brokers_ID = b.BSA_foodservice_Brokers_ID
					<cfelse>
						INNER JOIN Service_Markets m ON m.Service_Region_ID = tbl.Service_Region_ID
						INNER JOIN Market_Distributor md ON md.Service_market_ID = m.Service_Market_ID and md.Deleted = 0
						INNER JOIN BSA_Foodservice_Customers BSA
						ON       BSA.BSA_Foodservice_Customers_ID = md.Distributor_ID
					</cfif>
				<cfelseif DistributorGroupAttributeInfo.tableName EQ "Service_Zones">
					<cfif (application.appSettingsGet.getDistributorMultiPosition() eq 0)>
						INNER JOIN Service_Regions r ON r.Service_Zone_ID = tbl.Service_Zone_ID
						INNER JOIN Service_Markets m ON m.Service_Region_ID = r.Service_Region_ID
						INNER JOIN BSA_foodservice_Brokers b ON b.Service_market_ID = m.Service_Market_ID
						INNER JOIN BSA_Foodservice_Customers BSA
						ON       BSA.BSA_foodservice_Brokers_ID = b.BSA_foodservice_Brokers_ID
					<cfelse>
						INNER JOIN Service_Regions r ON r.Service_Zone_ID = tbl.Service_Zone_ID
						INNER JOIN Service_Markets m ON m.Service_Region_ID = r.Service_Region_ID
						INNER JOIN Market_Distributor md ON md.Service_market_ID = m.Service_Market_ID and md.Deleted = 0
						INNER JOIN BSA_Foodservice_Customers BSA
						ON       BSA.BSA_Foodservice_Customers_ID = md.Distributor_ID
					</cfif>
				<cfelse>
					INNER JOIN BSA_Foodservice_Customers BSA
					ON 	BSA.#DistributorGroupAttributeInfo.MasterIDField# = tbl.#DistributorGroupAttributeInfo.IDField#
				</cfif>	
				AND     BSA.Ship_To != 'Group'
				AND     BSA.Active_Code = 'A'
				AND     BSA.Deleted = 0
			</cfif>
		</cfif>
			WHERE	 tbl.Deleted = 0
			AND 	tbl.#DistributorGroupAttributeInfo.NameField# IS NOT NULL
		<cfif DistributorGroupAttributeInfo.tableName EQ "PG_Customer_Category">
			AND tbl.PG_Type_ID =  #DistributorGroupAttributeInfo.GroupLevelTypeID#
			AND tbl.Active = 1 
			AND tbl.Deleted = 0
			<cfif arguments.IncludeIOPGFlag	EQ "1">
			AND tbl.Include_In_Other_PG = 1
			</cfif>
		<cfelse>  
			AND Len(tbl.#DistributorGroupAttributeInfo.NameField#) > 0
		</cfif>
		<cfif arguments.ExcludeDistID NEQ 0>
			<!--- D31968 : Planning Groups - App Error Revising Plan Grps START --->
			AND CAST(tbl.#DistributorGroupAttributeInfo.IDField# AS VARCHAR(50)) NOT IN ('#arguments.ExcludeDistID#')
			<!--- D31968 : Planning Groups - App Error Revising Plan Grps END --->
		</cfif>
		<cfif arguments.businessSegmentId neq "0" and arguments.businessSegmentId neq "">
			AND tbl.Business_segment_id IN (#arguments.businessSegmentId#)
		</cfif>
		<cfif arguments.groupId NEQ 0>
			AND tbl.#DistributorGroupAttributeInfo.IDField# = '#arguments.groupId#'
		</cfif>
			Order By tbl.#DistributorGroupAttributeInfo.NameField#
		</cfquery>
		</cfif>
    <cfreturn qGetDistributorGroupValues>
	
	</cffunction>
	
	<cffunction name="getDistributorGroupLabel" returntype="string" output="false">
		<cfargument name="groupLevelTypeId" type="numeric" required="false" default="0" />
		<cfargument name="defaultDistributorGroupLabel" type="string" required="true" default="" />
		
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
		
			<cfif arguments.defaultDistributorGroupLabel NEQ "">
				<cfset returnValue = arguments.defaultDistributorGroupLabel />
			<cfelse>
				<cfset qGetDistributorGroupAttributes = getDistributorGroupAttributes(groupLevelTypeId = arguments.groupLevelTypeId) />
				<cfset returnValue = qGetDistributorGroupAttributes.Group_Level_Desc />
			</cfif>			
			
		</cfif>
		
		<cfreturn returnValue />
		
	</cffunction>
	
</cfcomponent>