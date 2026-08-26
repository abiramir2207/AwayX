<!----------------------------------------------------------------------------------
Name         :	PlannerSettingsManager.cfc
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	03/01/2016
Created By   : 	KAL
Description  : 	Manager for Planner Settings
---------------------------------------------------------------------------------->

<cfcomponent name="PlannerSettingsManager" displayname="PlannerSettingsManager" hint="Manager for Planner Settings">

	<!--- get the list of weekdays --->
	<cffunction name="getWeekDays" access="public" returntype="query" output="false" >
		<cfset qGetWeekDays = "" />
		<cfquery name="qGetWeekDays" datasource="#application.datasource#">
			SELECT Weekdays_Id, Weekday, Weekday_abbr
			FROM   Weekdays
		</cfquery>

		<cfreturn	qGetWeekDays />
	</cffunction>

	<cffunction name="getNUCTargets" access="public" returntype="query" output="false">
		<cfargument name="groupId" type="string" required="false" default="">
		<cfargument name="caller"  type="string" required="false" default="">

		<cfset local.qAttrData = getProductGroupTypeData()>

		<cfquery name="local.getNUCTargets" datasource="#application.datasource#">
			SELECT
			<cfif arguments.caller is "\settings\planners\nuc_targets\index.cfm">
				    PGA.#local.qAttrData.Product_Group_Attribute_Number_Field# AS Group_Number
				   ,PGA.#local.qAttrData.Product_Group_Attribute_Name_Field# AS Group_Desc
				   ,NUCT.Promoted_NUC
				   ,CASE WHEN NUCT.Promoted_NUC_UOM = 1 THEN 'CS'
						 WHEN NUCT.Promoted_NUC_UOM = 2 THEN 'LB'
						 WHEN NUCT.Promoted_NUC_UOM = 5 THEN 'EA'
					END AS Promoted_NUC_UOM
				   ,NUCT.Blended_NUC
				   ,CASE WHEN NUCT.Blended_NUC_UOM = 1 THEN 'CS'
						 WHEN NUCT.Blended_NUC_UOM = 2 THEN 'LB'
						 WHEN NUCT.Blended_NUC_UOM = 5 THEN 'EA'
					END AS Blended_NUC_UOM
				   ,NUCT.Case_count
				   ,NUCT.Target_Margin
				   ,PGA.#local.qAttrData.Product_Group_Attribute_Master_ID_Field# AS Group_GUID
			<cfelse>
					PGA.#local.qAttrData.Product_Group_Attribute_Number_Field# AS Group_Number
				   ,PGA.#local.qAttrData.Product_Group_Attribute_Name_Field# AS Group_Desc
				   ,NUCT.Promoted_NUC
				   ,NUCT.Promoted_NUC_UOM
				   ,NUCT.Blended_NUC
				   ,NUCT.Blended_NUC_UOM
				   ,NUCT.Case_count
				   ,NUCT.Target_Margin
				   ,NUCT.NUC_Targets_ID
				   ,PGA.#local.qAttrData.Product_Group_Attribute_Master_ID_Field# AS Group_GUID
			</cfif>
			FROM    #local.qAttrData.Product_Group_Attribute_Table# PGA
			LEFT JOIN NUC_Targets NUCT
					ON PGA.#local.qAttrData.Product_Group_Attribute_Master_ID_Field# = NUCT.Product_Group_ID
			WHERE   PGA.Deleted = 0
					<cfif trim(arguments.groupId) neq "">
						AND	PGA.#local.qAttrData.Product_Group_Attribute_Master_ID_Field# = '#arguments.groupId#'
					</cfif>
					<cfif local.qAttrData.Product_Group_Level_ID eq 9>
						AND PGA.Item IS NOT NULL
					</cfif>
			ORDER BY #local.qAttrData.Product_Group_Attribute_Name_Field#
		</cfquery>

		<cfreturn local.getNUCTargets />
	</cffunction>

	<cffunction name="getCalendarInfo" access="public" returntype="query" output="false" >
		<cfargument name="Planner_Calendar_Config_ID" type="string" required="false" default="0" />
        <cfargument name="Include_In_Planner"         type="string" required="false" default="0" />
		<cfquery name="qGetCalendarInfo" datasource="#application.datasource#">
			SELECT
				Planner_Calendar_Config_ID,
				Description,
				Cast(Sort_Order AS varchar(10)) as Sort_order,
				Include_In_Planner,
				Active,
				Deleted,
				Created_Date,
				Updated_Date,
				Updated_By
			FROM
				Planner_Calendar_Config
			WHERE
				Deleted = 0
			<cfif isDefined("arguments.Planner_Calendar_Config_ID") and arguments.Planner_Calendar_Config_ID neq 0>
					AND Planner_Calendar_Config_ID = #arguments.Planner_Calendar_Config_ID#
            </cfif>
            <cfif arguments.Include_In_Planner neq 0>
                AND Include_In_Planner = 1
            </cfif>
			ORDER BY
				cast(Sort_Order as int)
		</cfquery>
		<cfreturn	qGetCalendarInfo />
	</cffunction>

	<cffunction name="getPerfTypeInfo" access="public" returntype="query" output="false" >
		<cfargument name="type" type="string" required="false" default="active" />
		<cfargument name="perf_id" type="string" required="false" default="0" />

		<cfquery name="local.qGetPerfTypeInfo" datasource="#application.datasource#">
			SELECT *
			  FROM Planner_Perf_Types
			 WHERE Deleted = 0
					<cfif isDefined("arguments.type") and arguments.type eq "active">
						AND Active = 1
					<cfelseif isDefined("arguments.type") and arguments.type eq "inactive">
						AND Active = 0
					</cfif>
					<cfif isDefined("arguments.perf_id") and arguments.perf_id neq 0>
						AND Planner_Perf_Types_ID = #arguments.perf_id#
					</cfif>
				ORDER BY
					Sort_Order
		</cfquery>

		<cfreturn	local.qGetPerfTypeInfo />
	</cffunction>

	<cffunction name="getMaxSortOrder" access="public" returntype="query" output="false" >
		<cfquery name="qGetMaxPerfTypeInfo" datasource="#application.datasource#">
			SELECT 	Max(Sort_Order)	AS Max_Sort_Order
			FROM
				Planner_Perf_Types
		</cfquery>
		<cfreturn	qGetMaxPerfTypeInfo />
	</cffunction>

	<cffunction name="saveCalendarInfoSetting" access="public" returntype="void" output="no" hint="Save Calendar info settings based on form parameters.">

		<cfloop index = "idx" list = "#lsCalendarConfigIDs#">
			<cfif structKeyExists(form, "Sequence_#idx#")>
				<cfset sortOrder = Evaluate("FORM.Sequence_#idx#") />
			<cfelse>
				<cfset sortOrder = 1 />
			</cfif>
			<cfquery name="local.update" datasource="#application.datasource#">
				UPDATE Planner_Calendar_Config
					SET  Include_In_Planner = 	<cfif structKeyExists(form, "Include_#idx#")>1<cfelse>0</cfif>,
						 Sort_Order = #sortOrder#,
						 Updated_Date = GetDate(),
						 Updated_By = '#Request.AccessStructure.User_ID#'

				WHERE Planner_Calendar_Config_ID = #idx#
			</cfquery>
		</cfloop>

		<cfreturn />

	</cffunction>

	<cffunction name="getCustomerGroups" access="public" returntype="query" output="false" >
		<cfargument name="Planner_Retail_Customer_Groups_ID" type="string" required="false" default="0" />
		<cfquery name="qPlannerCustomerGroups" datasource="#application.datasource#">
			SELECT Planner_Retail_Customer_Groups_ID,
					Planning_Group_ID,
					Processed,
					Deleted,
					Created_Date,
					Created_By,
					Updated_Date,
					Updated_By
			FROM
				 Planner_Retail_Customer_Groups
			WHERE
				Deleted = 0
			<cfif isDefined("arguments.Planner_Retail_Customer_Groups_ID") and arguments.Planner_Retail_Customer_Groups_ID neq 0>
					AND Planner_Retail_Customer_Groups_ID = #arguments.Planner_Retail_Customer_Groups_ID#
				</cfif>
			ORDER BY
				Planner_Retail_Customer_Groups_ID
		</cfquery>
		<cfreturn	qPlannerCustomerGroups />
	</cffunction>


	<cffunction name="saveCustomerGroups" access="public" returntype="void" output="no" hint="Save Calendar info settings based on form parameters.">

		<cfif  isDefined("FORM.CustomerGroupChecked") AND FORM.CustomerGroupChecked NEQ "">
			<!--- Delete everything from the Planner_Retail_Customer_Groups table --->
			<cfquery name="local.delCustomerGroups" datasource="#application.datasource#">
				DELETE FROM Planner_Retail_Customer_Groups
			</cfquery>
			<!--- Update the Delete flags in the Log to keep track of who deleted the rows --->
			<cfquery name="local.delCustomerGroups_Log" datasource="#application.datasource#">
				UPDATE Planner_Retail_Customer_Groups_Log
				SET Deleted = 1,
					Deleted_Date = Getdate(),
					Deleted_by = '#Request.AccessStructure.User_ID#'
				WHERE
					Deleted = 0
			</cfquery>

			<cfloop index = "idx" list = "#FORM.CustomerGroupChecked#">
				<cfquery name="local.update" datasource="#application.datasource#">
					INSERT INTO Planner_Retail_Customer_Groups
					(
						Planning_Group_ID,
						Processed,
						Deleted,
						Created_Date,
						Created_By,
						Updated_Date,
						Updated_By
					)
					VALUES
					(
						'#idx#',
						0,
						0,
						Getdate(),
						'#Request.AccessStructure.User_ID#',
						Getdate(),
						'#Request.AccessStructure.User_ID#'
					)
				</cfquery>
				<cfquery name="local.update" datasource="#application.datasource#">
					INSERT INTO Planner_Retail_Customer_Groups_Log
					(
						Planning_Group_ID,
						Processed,
						Deleted,
						Created_Date,
						Created_By,
						Deleted_Date,
						Deleted_By
					)
					VALUES
					(
						'#idx#',
						0,
						0,
						Getdate(),
						'#Request.AccessStructure.User_ID#',
						Getdate(),
						'#Request.AccessStructure.User_ID#'
					)
				</cfquery>
			</cfloop>

			<cfstoredproc procedure="SP_Update_Retail_Customers" datasource="#application.datasource#" />

		</cfif>
		<cfreturn />

	</cffunction>

	<cffunction name="getProductGroupTypeData" access="public" returntype="query" output="false">

		<cfquery name="gGetAttData" datasource="#application.datasource#">
			SELECT	s.Value as Product_Group_Level_ID,
					LTRIM(RTRIM(pga.Product_Group_Attribute_Table)) AS Product_Group_Attribute_Table,
					LTRIM(RTRIM(pga.Product_Group_Attribute_Master_ID_Field)) AS Product_Group_Attribute_Master_ID_Field,
					LTRIM(RTRIM(pga.Product_Group_Attribute_Name_Field)) AS Product_Group_Attribute_Name_Field,
					LTRIM(RTRIM(pga.Product_Group_Attribute_Number_Field)) AS Product_Group_Attribute_Number_Field
			FROM	_settings s
					left join Product_Group_Attribute pga on pga.Product_Group_Level_ID = CASE WHEN ISNULL(s.Value, '') = '' THEN 11 ELSE s.Value END
			WHERE	s.Input_Name = 'Retail_Target_Product_Group'
		</cfquery>

		<cfif gGetAttData.Product_Group_Level_ID eq 9>
			<cfset gGetAttData.Product_Group_Attribute_Table = "BSA_Foodservice_Items_Master" />
			<cfset gGetAttData.Product_Group_Attribute_Master_ID_Field = "BSA_Foodservice_Items_Master_ID" />
			<cfset gGetAttData.Product_Group_Attribute_Name_Field = "Description" />
			<cfset gGetAttData.Product_Group_Attribute_Number_Field = "Item" />
		</cfif>

		<cfreturn gGetAttData />

	</cffunction>

	<cffunction name="getProductGroupLevel" access="public" returntype="query" output="false">

		<cfquery name="gGetAttName" datasource="#application.datasource#">
			SELECT	pgl.Group_Level_Desc
			FROM	_settings s
					inner join Product_Group_Level pgl on pgl.Product_Group_Level_ID = CASE WHEN ISNULL(s.Value, '') = '' THEN 11 ELSE s.Value END
			WHERE	s.Input_Name = 'Retail_Target_Product_Group'
		</cfquery>

		<cfreturn gGetAttName />

	</cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="getPlannerOutputSettings" access="public" returntype="query" output="no" hint="Returns planner output settings.">
  	<cfargument name="config_id" required="false" default="">

  	<cfquery name="local.query" datasource="#application.datasource#">
  		SELECT *,
  		       (SELECT COUNT(1)
  		          FROM Planner_Template
  		         WHERE Planner_Template.Planner_Output_Setting_Config_ID = Planner_Output_Setting.Config_ID
  		           AND Planner_Template.Deleted = 0) AS UsageCount
  		  FROM Planner_Output_Setting
  		 WHERE Deleted = 0
					<!--- If it is a newly created setting, get the details from the existing "default" record. --->
  		 			<cfif arguments.config_id eq "-1">
  		 			 AND default_setting = 1
  		 			<cfelseif val(arguments.config_id) neq 0>
  		 				AND Config_ID = <cfoutput>#arguments.config_id#</cfoutput>
  		 			</cfif>
  		       ORDER BY Config_Name
  	</cfquery>
    <cfreturn local.query>
  </cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="duplicatePlannerOutputSettingExists" access="remote" returnFormat="json" output="no">
		<cfargument name="config_id" required="true" type="numeric">
		<cfargument name="config_name" required="true" type="string">

		<cfscript>
			local.result = {};
		</cfscript>

		<cftry>
			<cfquery name="local.query" datasource="#application.datasource#">
				SELECT 1
					  FROM Planner_Output_Setting
				 WHERE Config_ID    <> <cfqueryparam cfsqltype="cf_sql_integer"      value="#arguments.config_id#">
				   AND Config_Name  =  <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.config_name#">
				   AND Deleted      =  0
			</cfquery>
			<cfcatch type="any">
				<!--- oops! error just occurred --->
				<cfset local.query = queryNew( 'foo' )>
			</cfcatch>
		</cftry>

		<cfset local.result.duplicateExists = (local.query.recordCount gt 0)>
		<cfreturn local.result>
	</cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="_sanitizeLabel" access="private" returntype="string" output="no" hint="Remove special characters that cause problems.">
  	<cfargument name="label" required="true">

		<cfreturn replaceNoCase( arguments.label, ",", "", "all" )>
  </cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="getPlannerOutputColumnList" access="public" returntype="array" output="no" hint="Returns the column list">

    <cfscript>
        vars = {};

        // For saved records column sequence will come from db. For new records default sequence will be based on below array order
        // if you need to change the default sequence change the columnOrder value
        // TO DO: make changes to this statement whenever Planner_Output_Setting schema is changed to add new columns
      vars.columns = [ {label="<cfoutput>#Application.PlannerPrgLabel#</cfoutput> Number", name="program_Number", columnOrder="0"}
                      ,{label="<cfoutput>#Application.PlannerPrgLabel#</cfoutput> Title", name="Program_Title", columnOrder="0"}
                      ,{label="Distributor ID", name="Distributor_ID", columnOrder="0"}
                      ,{label="Distributor Name", name="Distributor_Name", columnOrder="0"}
                      ,{label="Operator ID", name="Operator_ID", columnOrder="0"}
                      ,{label="Operator Name", name="Operator_Name", columnOrder="0"}
                      ,{label="Performance Start Date", name="Performance_Start_Date", columnOrder="0"}
                      ,{label="Performance End Date", name="Performance_End_Date", columnOrder="0"}
                      ,{label="Delivery Start Date", name="Delivery_Start_Date", columnOrder="0"}
                      ,{label="Delivery End Date", name="Delivery_End_Date", columnOrder="0"}
                      ,{label="Rebate <cfoutput>#Application.PlannerCompLabel#</cfoutput> Name", name="Rebate_Component_Name", columnOrder="0"}
                      ,{label="Item Number", name="Item_Number", columnOrder="0"}
                      ,{label="Item Name", name="Item_Name", columnOrder="0"}
                      ,{label="Rebate Rate", name="Rebate_Rate", columnOrder="0"}
                      ,{label="Rebate UOM", name="Rebate_UOM", columnOrder="0"}
                      ,{label="<cfoutput>#Application.PlannerLSLabel# #Application.PlannerCompLabel#</cfoutput> Name", name="Lump_Component_Name", columnOrder="0"}
                      ,{label="<cfoutput>#Application.PlannerLSLabel#</cfoutput> Amount", name="Lump_Sum_Amount", columnOrder="0"}
                      ,{label="Currency", name="Currency", columnOrder="0"}
                      ,{label="Everyday Price", name="Everyday_Price", columnOrder="0"}
                      ,{label="Merchandised Price", name="Merchandised_Price", columnOrder="0"}
                      ,{label="Retailer Margin", name="Retailer_Margin", columnOrder="0"}
                      ,{label="Retailer Profit", name="Retailer_Profit", columnOrder="0"}
                      ,{label="Distributor Product Number", name="Distributor_Product_Number", columnOrder="0"}
                      ,{label="Type Code ID", name="Type_Code_ID", columnOrder="0"}
                      ,{label="Type Code Desc", name="Type_Code_Desc", columnOrder="0"}
                      ,{label="Type Group ID", name="Type_Group_ID", columnOrder="0"}
                      ,{label="Type Group Desc", name="Type_Group_Desc", columnOrder="0"}
                      ,{label="Brand ID", name="Brand_ID", columnOrder="0"}
                      ,{label="Brand Desc", name="Brand_Desc", columnOrder="0"}
                      ,{label="Qbrand ID", name="Qbrand_ID", columnOrder="0"}
                      ,{label="Qbrand Desc", name="Qbrand_Desc", columnOrder="0"}
                      ,{label="Prod Var A ID", name="Prod_Var_A_ID", columnOrder="0"}
                      ,{label="Prod Var A Desc", name="Prod_Var_A_Desc", columnOrder="0"}
                      ,{label="Prod Var B ID", name="Prod_Var_B_ID", columnOrder="0"}
                      ,{label="Prod Var B Desc", name="Prod_Var_B_Desc", columnOrder="0"}
                      ,{label="Prod Var C ID", name="Prod_Var_C_ID", columnOrder="0"}
                      ,{label="Prod Var C Desc", name="Prod_Var_C_Desc", columnOrder="0"}
                      ,{label="Case Volume", name="Volume_CS", columnOrder="0"}
                      ,{label="Pound Volume", name="Volume_LB", columnOrder="0"}
                    ];

    </cfscript>

    <cfreturn vars.columns />

  </cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="savePlannerOutputConfig" access="public" returntype="void" output="no" hint="Save config settings based on form parameters.">
		<!--- If a default setting is being set, remove the previous default setting --->
		<cfif form.default_setting eq 1>
			<cfquery name="updSetting" datasource="#application.datasource#">
				UPDATE Planner_Output_Setting
				SET default_setting = 0
				WHERE default_setting = 1
			</cfquery>
		</cfif>

		<cfif val(form.config_ID) eq -1>
  		<cfquery name="local.query" datasource="#application.datasource#">
	  		INSERT INTO Planner_Output_Setting
	  					( Config_Name, Updated_By, Default_Setting )
	  		VALUES
	  		     (  <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.config_name#">
	  		       ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#">
				   ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.default_setting#"> )

	  		SELECT SCOPE_IDENTITY() AS Config_ID
  		</cfquery>
			<cfset form.config_ID = local.query.config_ID>
		</cfif>

        <cfset arColumnList = getPlannerOutputColumnList() />

		<cfquery name="local.update" datasource="#application.datasource#">
			 UPDATE      Planner_Output_Setting
	  		   SET       Updated_By  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#">
	  		      <cfif structKeyExists(form, "Config_Name")>    <!---Default setting would not have config_name due to its disabled status--->
                        ,Config_Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.config_name#">
	  		      </cfif>
	  		      <cfloop array="#arColumnList#" index="vars.column">
                        ,#vars.column.name#_Label = <cfqueryparam cfsqltype="cf_sql_varchar" value="#_sanitizeLabel(form["#vars.column.name#_Label"])#">
                        ,#vars.column.name#_Include = <cfif structKeyExists(form, "#vars.column.name#_Include")>1<cfelse>0</cfif>
                        ,#vars.column.name#_Sequence = <cfqueryparam cfsqltype="cf_sql_integer" value="#form["#vars.column.name#_Sequence"]#">
	  		      </cfloop>

                        ,By_Group = <cfqueryparam cfsqltype="cf_sql_bit" value="#form.By_Group#">
                        ,Default_Setting = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.default_setting#">

			  WHERE     Config_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.config_id#">
		</cfquery>

		<!---this statement is needed to take care of a scenario when users made no template selection--->
		<cfparam name="form.templates" default="">

		<cfquery name="local.update" datasource="#application.datasource#">
		   <!---remove previously assigned templates that are no longer selected--->
				UPDATE Planner_Template
				   SET Planner_Output_Setting_Config_ID = NULL
				 WHERE Planner_Output_Setting_Config_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.config_id#">
				   AND NOT Planner_Template_ID IN ( <cfqueryparam cfsqltype="cf_sql_integer" value="#form.templates#" list="true"> )
				   AND Deleted = 0

				<!---assign selected templates--->
				UPDATE Planner_Template
				   SET Planner_Output_Setting_Config_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.config_id#">
				 WHERE Planner_Template_ID IN ( <cfqueryparam cfsqltype="cf_sql_integer" value="#form.templates#" list="true"> )
				   AND Deleted = 0
		</cfquery>

  </cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="deletePlannerOutputConfig" access="public" returntype="void" output="no" hint="Delete claim rates setting.">
  	<cfargument name="config_id" required="false" default="">

  	<cfquery name="local.query" datasource="#application.datasource#">
  		 UPDATE Planner_Output_Setting
  		    SET Deleted = 1
  		        ,Updated_By = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#">
  		  WHERE Config_ID = <cfoutput>#arguments.config_id#</cfoutput>
  	</cfquery>
  </cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="getTemplates" access="public" returntype="query" output="no" hint="Returns template related claim rates settings.">
  	<cfargument name="Planner_Template_ID" required="false" default="">

  	<cfquery name="local.query" datasource="#application.datasource#">
  		SELECT DISTINCT
  		        Planner_Type
  		       ,Planner_Template_ID
  		       ,Planner_Description
  		       ,Planner_Output_Setting_Config_ID
  		 			<cfif val(arguments.Planner_Template_ID) neq 0>
  		       	,b.Config_Name
  		 			</cfif>
  		  FROM Planner_Template a
  		  LEFT JOIN Planner_Output_Setting b ON a.Planner_Output_Setting_Config_ID = b.Config_ID
  		 WHERE a.Deleted = 0
  		 			<cfif val(arguments.Planner_Template_ID) neq 0>
  		 				AND Planner_Template_ID = <cfoutput>#arguments.Planner_Template_ID#</cfoutput>
  		 			</cfif>
  		       ORDER BY a.Planner_Type
  	</cfquery>
    <cfreturn local.query>
  </cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

    <cffunction name="getScorecard_Settings" access="public" returntype="query" output="no" hint="Returns planner scorecard settings.">
        <cfquery name="local.query" datasource="#application.datasource#">
            SELECT pss.*
                   , u.name_first + ' ' + u.name_last AS Changed_By
              FROM Planner_Scorecard_Settings pss
              LEFT JOIN _Users u ON u.user_id = pss.updated_by
                   ORDER BY Sequence
        </cfquery>

      <cfreturn local.query>
    </cffunction>

	<!----------------------------------------------------------------------------------------------------------------------------------------------------->

    <cffunction name="setScorecard_Settings" access="public" output="no" hint="Saves planner scorecard settings.">
        <cfargument name="form" required="true" type="struct">

        <cfquery datasource="#application.datasource#">
            <cfoutput>
            <cfloop list="#arguments.form.all_ids#" item="local.id">
                UPDATE Planner_Scorecard_Settings
                   SET User_Label = RTRIM('#arguments.form[ "user_label_" & local.id ]#')
                       , Sequence = '#arguments.form[ "sequence_" & local.id ]#'
                       , Enabled = '#arguments.form[ "enabled_" & local.id ]#'
                       , Updated_Date = GETDATE()
					   , Updated_By = '#Request.AccessStructure.User_ID#'
                 WHERE Internal_ID = #local.id#
            </cfloop>
            </cfoutput>
        </cfquery>

    </cffunction>
</cfcomponent>