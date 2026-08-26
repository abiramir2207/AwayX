<cfcomponent hint="This class is only used for database access. It holds all the queries for Customer Groups">

	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

	<cffunction name="init" output="false">

		<cfreturn this />

	</cffunction>


  <cffunction name="getOperatorLevelsAll" output="false" returntype="query">
		<cfargument name="bActive" type="numeric" required="false" default="-1" />
		<cfargument name="allowList" type="string" required="false" default="" />
		<cfargument name="disAllowList" type="string" required="false" default="" />
  <cfquery name="qGetOperatorLevels" datasource="#application.datasource#">
			SELECT	Active, Operator_Group_Level_ID, Operator_Group_Level_Type_ID, Group_Level_Desc, Search_Sequence_Name,
					Operator_Group_Attribute_Master_ID_Field, Level_ID, Search_Filter_On,Is_PG
			FROM	Operator_Group_Level
			WHERE	Deleted = 0
			<cfif arguments.bActive NEQ -1>
			AND		Active = <cfqueryparam value="#arguments.bActive#" cfsqltype="CF_SQL_BIT">
			</cfif>
			<cfif arguments.allowList NEQ "">
			AND		Operator_Group_Level_Type_ID IN (<cfqueryparam value="#arguments.allowList#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfif>
			<cfif arguments.disAllowList NEQ "">
			AND		Operator_Group_Level_Type_ID NOT IN (<cfqueryparam value="#arguments.disAllowList#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfif>
			ORDER BY Group_Level_Desc ASC
		</cfquery>
  		<cfreturn qGetOperatorLevels />

	</cffunction>

	<cffunction name="getOperatorLevelsFilter" output="false" returntype="query">

		<cfargument name="bActive" type="numeric" required="false" default="-1" />
		<cfargument name="allowList" type="string" required="false" default="" />
		<cfargument name="disAllowList" type="string" required="false" default="" />
		<cfargument name="Template_ID" type ="numeric" required="false" default = "0" />

 		<cfquery name="qGetOperatorLevels" datasource="#application.datasource#">
			SELECT	DISTINCT
          OGL.Active,
          OGL.Operator_Group_Level_ID,
          OGL.Operator_Group_Level_Type_ID,
          OGL.Group_Level_Desc,
          OGL.Search_Sequence_Name,
          OGL.Operator_Group_Attribute_Master_ID_Field,
          OGL.Level_ID,
          OGL.Search_Filter_On,
          OGL.Is_PG
			FROM	Operator_Group_Level OGL
			<cfif arguments.Template_ID neq 0>
				INNER JOIN Group_Template  GT
				ON GT.Group_Level_ID  =  OGL.Operator_Group_Level_ID
				AND GT.PG_Group_Type = 3
				<!---    -- AND GT.Allow_In_Group_Search = 1
				-- AND GT.Allow_Filter = 1 --->
				LEFT JOIN PG_Type PGT
				ON PGT.PG_Type_ID =  GT.Group_Level_ID
			</cfif>
			WHERE		OGL.Deleted = 0
      <!--- Do not Select planning groups if the appsetting is OFF./Anand Rao/10-Jan-2011--->
			<cfif NOT(appSettings.getPlanningGroups())>
				AND OGL.Is_PG = 0
			<cfelse>
				<cfif arguments.Template_ID neq 0>
					AND (OGL.Is_PG = 0	OR (OGL.Is_PG = 1 AND PGT.Active = 1))
				</cfif>
			</cfif>

			<cfif arguments.bActive NEQ -1>
			AND		OGL.Active = <cfqueryparam value="#arguments.bActive#" cfsqltype="CF_SQL_BIT">
			</cfif>
			<cfif arguments.allowList NEQ "">
			AND		OGL.Operator_Group_Level_Type_ID IN (<cfqueryparam value="#arguments.allowList#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfif>
			<cfif arguments.disAllowList NEQ "">
			AND		OGL.Operator_Group_Level_Type_ID NOT IN (<cfqueryparam value="#arguments.disAllowList#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfif>
		</cfquery>

		<cfreturn qGetOperatorLevels />

	</cffunction>

	<cffunction name="getOperatorLevels" output="false" returntype="query">

		<cfargument name="bActive" type="numeric" required="false" default="-1" />
		<cfargument name="allowList" type="string" required="false" default="" />
		<cfargument name="disAllowList" type="string" required="false" default="" />
		<cfargument name="sCriteria" type="string" required="false" default="" />
		<cfargument name="FirstTemplateID"  type="numeric" required="false" default="0" />
		<!---
			sCriteria = FSearch - Field in search Only
			sCriteria = GSearch - Field in Group Search Only
			sCriteria = FGSearch - Field in search both Field Search and Group Search
			sCriteria = 0 - do not include criteria
		--->

 		<cfquery name="qGetOperatorLevels" datasource="#application.datasource#">
			SELECT	DISTINCT
				OGL.Active,
				OGL.Operator_Group_Level_ID,
				OGL.Operator_Group_Level_Type_ID,
				OGL.Group_Level_Desc,
				OGL.Search_Sequence_Name,
				OGL.Operator_Group_Attribute_Master_ID_Field,
				OGL.Level_ID,
				OGL.Search_Filter_On,
				OGL.Is_PG,
				GT.Allow_Filter
			FROM	Operator_Group_Level OGL
			INNER JOIN Group_Template  GT ON GT.Group_Level_ID  =  OGL.Operator_Group_Level_ID
				AND GT.PG_Group_Type = 3 AND GT.Deleted = 0

			<!---   /*  AND GT.Allow_Filter = 1 */ --->
			<cfif arguments.sCriteria EQ "FSearch">
			 	AND GT.Allow_In_Search = 1
			</cfif>
			<cfif arguments.sCriteria EQ "GSearch">
				AND GT.Allow_In_Group_Search = 1
			</cfif>
			<cfif arguments.sCriteria EQ "FGSearch">
			 	AND GT.Allow_In_Search = 1 AND GT.Allow_In_Group_Search = 1
			</cfif>
			<cfif isNumeric(arguments.FirstTemplateID) AND arguments.FirstTemplateID NEQ 0 >
				AND Template_ID = #arguments.FirstTemplateID#
			</cfif>
			LEFT JOIN PG_Type PGT ON PGT.PG_Type_ID =  GT.Group_Level_ID
			WHERE		OGL.Deleted = 0

			<!--- Do not Select planning groups if the appsetting is OFF./Anand Rao/10-Jan-2011--->
			<cfif NOT(appSettings.getPlanningGroups())>
				AND OGL.Is_PG = 0
			 <cfelse>
			   	AND (OGL.Is_PG = 0	OR (OGL.Is_PG = 1 AND OGL.Active = 1))
			</cfif>
			<cfif arguments.bActive NEQ -1>
				AND		OGL.Active = <cfqueryparam value="#arguments.bActive#" cfsqltype="CF_SQL_BIT">
			</cfif>
			<cfif arguments.allowList NEQ "">
				AND		OGL.Operator_Group_Level_Type_ID IN (<cfqueryparam value="#arguments.allowList#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfif>
			<cfif arguments.disAllowList NEQ "">
				AND		OGL.Operator_Group_Level_Type_ID NOT IN (<cfqueryparam value="#arguments.disAllowList#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfif>

		</cfquery>

		<cfreturn qGetOperatorLevels />

	</cffunction>

  <cffunction name="fnQryExistingOperatorData" output="false" returntype="query">
    <cfargument name="TemplateID"         required="true" type="numeric"  />
    <cfargument name="TemplateFiltersID"  required="true" type="numeric"  />
    <cfargument name="OperatorGroupLevelID"       required="true" type="numeric"  />
    <cfargument name="bActive"           required="false" type="numeric"  default="0" />

    <cfquery name="qGetExistingData" datasource="#application.datasource#">
      SELECT  Operator_Group_Template_Selection_ID,
              Template_ID,
              Operator_Group_Level_ID,
              Operator_Group_ID,
              Active,
              Deleted,
              Created_Date,
              Updated_Date,
              Created_By,
              Updated_BY,
              PG_Flag,
              Updated_From,
              Template_Filters_Id
      FROM    Operator_Group_Template_Selection
      WHERE   Template_ID = #arguments.TemplateID#
      AND     Template_Filters_ID = #arguments.TemplateFiltersID#
      AND     Operator_Group_Level_ID = #arguments.OperatorGroupLevelID#
      <cfif arguments.bActive EQ "1">
        AND Active = 1 AND Deleted = 0
      </cfif>
    </cfquery>
    <cfreturn qGetExistingData />
  </cffunction>


<cffunction name="fnSaveFilterDataOperator" output="false" returntype="string">
    <cfargument name="UserID"         required="true" type="string"  />
    <cfargument name="stForm"     required="true" default="" type="any" />
    <cfset returnValue = "0" />
    <!--- Update all the records to inactive before activating them again. --->
 <!---    <cftry> --->
    <cfquery name="qUpdateAllRecs" datasource="#application.datasource#">
      UPDATE Operator_Group_Template_Selection
      SET Active = 0,
          Deleted = 1,
          Updated_By = '#arguments.UserID#',
          Updated_Date = GetDate()
      WHERE   Template_ID = #arguments.stForm.TemplateID#
      AND     Template_Filters_ID = #arguments.stForm.TemplateFiltersID#
      AND     Operator_Group_Level_ID = #arguments.stForm.GroupLevelID#
    </cfquery>


   <cfset qGetExistingData = this.fnQryExistingOperatorData( TemplateID = arguments.stForm.TemplateID,
                                                             TemplateFiltersID = arguments.stForm.TemplateFiltersID,
                                                             OperatorGroupLevelID = arguments.stForm.GroupLevelID,
                                                             bActive = 0 ) />

    <cfloop index = "ID" list = "#arguments.stForm.FinalOprList#" >
      <cfset bRecExists = "0" />
      <!--- Loop through qGetExistingData only, if there is already Data for the Combination --->
      <cfif qGetExistingData.RecordCount GTE 1>
        <cfloop query="qGetExistingData">
          <cfif (ID EQ qGetExistingData.Operator_Group_ID)>
            <!--- record exist so update to active  = 1--->
            <cfset bRecExists = "1" />
            <cfquery name="qUpdateAllRecs" datasource="#application.datasource#">
              UPDATE Operator_Group_Template_Selection
              SET Active = 1,
                  Deleted = 0,
                  Updated_By = '#arguments.UserID#',
                  Updated_Date = GetDate(),
                  Updated_From = 'Template Page'
              WHERE   Template_ID = #arguments.stForm.TemplateID#
              AND     Template_Filters_ID = #arguments.stForm.TemplateFiltersID#
              AND     Operator_Group_Level_ID = #arguments.stForm.GroupLevelID#
              AND Operator_Group_ID = '#ID#'
            </cfquery>
          </cfif>
        </cfloop>
      </cfif>
      <cfif bRecExists EQ "0">

		<cfquery name="qryChkISPG" datasource="#application.datasource#">
          SELECT TOP 1 IS_PG  FROM
          Operator_Group_Level
          WHERE Operator_Group_Level_ID = #arguments.stForm.GroupLevelID#
        </cfquery>
        <cfquery name="qUpdateAllRecs" datasource="#application.datasource#">
          INSERT INTO Operator_Group_Template_Selection
          (
              Template_ID,
              Operator_Group_Level_ID,
              Operator_Group_ID,
              Active,
              Deleted,
              Created_Date,
              Created_By,
              PG_Flag,
              Updated_From,
              Template_Filters_Id
          )
          VALUES
          (
              #arguments.stForm.TemplateID#,
              #arguments.stForm.GroupLevelID#,
              '#ID#',
              1,
              0,
              GetDate(),
              '#arguments.UserID#',
              <cfif ((qryChkISPG.RecordCount EQ 1) AND (qryChkISPG.IS_PG EQ 1))>1<cfelse>0</cfif>,
              'Template Page',
               #arguments.stForm.TemplateFiltersID#
          )
      </cfquery>
    </cfif>
  </cfloop>
  <cfset returnValue = "1" />


     <cfreturn returnValue />
  </cffunction>


 <cffunction name="getOperatorLevelsGroupTemplate" output="false" returntype="query">

	  <cfargument name="bActive" type="numeric" required="false" default="-1" />
		<cfargument name="allowList" type="string" required="false" default="" />
		<cfargument name="disAllowList" type="string" required="false" default="" />
    <cfargument name="templateID" type="numeric" required="false" default="-1" />

		<cfquery name="qGetDistributorLevelsGroupTemplate" datasource="#application.datasource#">

      SELECT	GT.Group_Template_ID,GT.Template_ID,GT.Group_Level_ID,GT.PG_Group_Type,GT.Allow_In_Search,
              GT.Allow_In_Group_Search,GT.Active,GT.Deleted,GT.Created_Date,GT.Updated_Date,GT.Created_By,
              GT.Updated_BY,GT.PG_Flag,GT.Updated_From,GT.Allow_Filter
  			      ,OGL.*
			        ,Field_name = OGL.Group_level_desc_internal
      FROM	Group_Template GT
	   <cfif arguments.templateID NEQ -1>
		    LEFT JOIN PG_Type PGT ON PGT.PG_Type_ID = GT.Group_Level_ID
		</cfif>
	  		LEFT JOIN Operator_Group_Level OGL
			on OGL.Operator_Group_Level_ID = GT.Group_Level_ID
			WHERE	GT.Deleted = 0
      AND GT.PG_Group_Type = 3
     -- AND (Allow_In_Group_Search = 1  OR Allow_In_Search = 1)
			<cfif arguments.bActive NEQ -1>
			AND		GT.Active = <cfqueryparam value="#arguments.bActive#" cfsqltype="CF_SQL_BIT">
			</cfif>
			<cfif arguments.allowList NEQ "">
			AND		GT.Group_Level_ID IN (<cfqueryparam value="#arguments.allowList#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfif>
			<cfif arguments.disAllowList NEQ "">
			AND		GT.Group_Level_ID NOT IN (<cfqueryparam value="#arguments.disAllowList#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfif>
		<cfif NOT(appSettings.getPlanningGroups())>
			AND OGL.Is_PG = 0
	  	<cfelse>
			<cfif arguments.templateID NEQ -1>
				AND (OGL.Is_PG = 0	OR (OGL.Is_PG = 1 AND PGT.Active = 1))
			</cfif>
	  	</cfif>
      <cfif arguments.templateID NEQ -1>
      AND GT.Template_ID = <cfqueryparam value="#arguments.templateID#" cfsqltype="CF_SQL_INTEGER" />
      </cfif>


		</cfquery>
  	<cfreturn qGetDistributorLevelsGroupTemplate />

	</cffunction>
<!--- D31561: Operator Groups Search START--->
	<cffunction name="getOperatorsInGroup" output="false" returntype="query">
		<cfargument name="OperatorId" required="true" default="" />
		<cfset appSettings = application.appSettingsGet>
		<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ '1'>
			<cfquery name="qGetExistingData" datasource="#application.datasource#">
				select Operator_Name,
						COALESCE(Nullif(BSA_Operator.Legacy_ID,''), cast(BSA_Operator.BSA_Operator_ID as char(50))) AS Legacy_ID
				from BSA_OPerator where Operator_GPO_ID = '#arguments.OperatorId#'
				order by 	BSA_Operator.Operator_Name
			</cfquery>
		<cfelse>
			<cfquery name="qGetExistingData" datasource="#application.datasource#">
				select      BSA_Operator.Operator_Name,
			            	COALESCE(Nullif(BSA_Operator.Legacy_ID,''), cast(BSA_Operator.BSA_Operator_ID as char(50))) AS Legacy_ID
				from  		PG_Operator_Category
				inner join 	PG_Operator_Members
				on          PG_Operator_Members.PG_Operator_Category_ID = PG_Operator_Category.PG_Operator_Category_ID
				and         PG_Operator_Members.Deleted = 0
				and         PG_Operator_Members.Active = 1
				inner join 	BSA_Operator
				on          BSA_Operator.BSA_Operator_ID = PG_Operator_Members.BSA_Operator_ID
				where 		PG_Operator_Category.PG_Operator_Category_ID = '#arguments.OperatorId#'
				order by 	BSA_Operator.Operator_Name
			</cfquery>
		</cfif>
		<cfreturn qGetExistingData />
	</cffunction>

	<cffunction name="getOperatorsInProgram" output="false" returntype="query">
		<cfargument name="operatorGroupId" required="true" default="" />
		<cfargument name="programid" required="true" default="0" />
         <cfset appSettings = application.appSettingsGet>
		<cfset var qGetCustomers = "" />
		<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ '1'>
			<CFQUERY NAME="qGetCustomers" datasource="#application.datasource#">
				select Operator_Name,COALESCE(Nullif(BSA_Operator.Legacy_ID,''), cast(BSA_Operator.BSA_Operator_ID as char(50))) AS Legacy_ID
	            from  Contract_Operators
	            inner join BSA_Operator on
	                  BSA_Operator.BSA_Operator_id = Contract_Operators.BSA_Operator_id
	            where contract_main_id = '#arguments.programid#'
	            and Contract_Operators.deleted = 0
	            and Contract_Operators.is_group = 0
	            and Contract_Operators.Captured_From_Group = 1
				--and Contract_Operators.Operator_Group_ID_Int = '#arguments.operatorGroupId#'
				ORDER BY Operator_Name ASC
			</CFQUERY>
		<cfelse>
			<CFQUERY NAME="qGetCustomers" datasource="#application.datasource#">
				select Operator_Name,COALESCE(Nullif(BSA_Operator.Legacy_ID,''), cast(BSA_Operator.BSA_Operator_ID as char(50))) AS Legacy_ID
	            from  Contract_Operators
	            inner join BSA_Operator on
	                  BSA_Operator.BSA_Operator_id = Contract_Operators.BSA_Operator_id
	            where contract_main_id = '#arguments.programid#'
	            and Contract_Operators.deleted = 0
	            and Contract_Operators.is_group = 0
	            and Contract_Operators.Captured_From_Group = 1
				and Contract_Operators.Operator_Group_ID = '#arguments.operatorGroupId#'
				ORDER BY Operator_Name ASC
			</CFQUERY>
		</cfif>
		<cfreturn qGetCustomers>
	</cffunction>
<!--- D31561: Operator Groups Search END--->
<!---
	<cffunction name="getCustomerGroups" output="false" returntype="query">
	<cffunction name="getCustomersInGroup" output="false">
  <cffunction name="getDistributorLevelsAll" output="false" returntype="query">
	<cffunction name="getDistributorLevels" output="false" returntype="query">
  <cffunction name="getDistributorLevelActive" output="false" returntype="boolean" hint="1=business sgement,2=family,3=buying group,4=line of business">
  <cffunction name="getDistributorLevelSearchFilterOn" output="false" returntype="boolean" hint="1=business sgement,2=family,3=buying group,4=line of business">
	<cffunction name="getDistributorLevelsGroupTemplate" output="false" returntype="query">
  <cffunction name="getDistributorLevelActiveGroupTemplate" output="false" returntype="boolean" hint="1=business sgement,2=family,3=buying group,4=line of business">
  <cffunction name="getDistributorLevelSearchFilterOnGroupTemplate" output="false" returntype="boolean" hint="1=business sgement,2=family,3=buying group,4=line of business">
	<cffunction name="getCustomersInProgram" output="false">
	<cffunction name="getBrokerCustomers" output="false">
  <cffunction name="fnQryExistingCustomerData" output="false" returntype="query">
  <cffunction name="fnSaveFilterDataCustomer" output="false" returntype="string">
  --->
</cfcomponent>