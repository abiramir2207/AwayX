<!----------------------------------------------------------------------------------
Name         :	Planner_Program_Action.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	03/08/2016
Created By   : 	Anand Rao
Description  : 	Page to maintain planner program
---------------------------------------------------------------------------------->

<cfparam name="FORM.Template_ID" 		default="">
<cfparam name="FORM.Budget" 			default="0">
<cfparam name="FORM.Marketing_Event" 	default="0">
<cfparam name="FORM.NUC_Target" 		default="0">
<cfparam name="FORM.Retailer_Unit_Cost" default="0">
<cfparam name="FORM.Merch_Unit_Price" 	default="0">
<cfparam name="FORM.Retailer_Margin" 	default="0">
<cfparam name="FORM.Planner_Perf_Types_ID" 	default="">

<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<cfset template = templateManager.get(FORM.Template_ID)>
<cfset templateProgramPlanner = templateManager.getTemplateProgramPlanner(Form.Template_ID) />
<cfset FirstParentID =  	template.getFirstParentID()>

<cftransaction action="BEGIN">
	<cftry>
			<!--- First set the deleted bit to one for all the entries in the table --->
<!--- 			<CFQUERY NAME="Set_Deleted" DATASOURCE="#application.datasource#">
				UPDATE	Template_Planner_Settings
				SET		Deleted = 1
				WHERE	First_Parent_ID  = (Select First_Parent_ID FROM Program_Control_Panel_Options where ProgramControl_Panel_Options_ID = '#FORM.Template_ID#')
			</CFQUERY> --->
<!--- 			<CFQUERY NAME="Set_Deleted" DATASOURCE="#application.datasource#">
				UPDATE	Template_Planner_Settings
				SET		Deleted = 1
				WHERE	First_Parent_ID  = (Select First_Parent_ID FROM Program_Control_Panel_Options where ProgramControl_Panel_Options_ID = '#FORM.Template_ID#')
			</CFQUERY>
 --->
		<cfif ((NOT isDefined("templateProgramPlanner")) OR templateProgramPlanner.RecordCount EQ 0)>
			<cfquery name="Save_Data" DATASOURCE="#application.datasource#">
				INSERT INTO Template_Planner_Settings
				(
						First_Parent_ID,
						Created_Date,
						Created_By,
						Budget,
						Marketing_Event,
						NUC_Target,
						Retailer_Unit_Cost,
						Merch_Unit_Price,
						Retailer_Margin
					)
				VALUES
				(
					'#FirstParentID#',
					GetDate(),
					'#request.AccessStructure.user_id#',
					<cfqueryparam value="#Form.Budget#" cfsqltype="cf_sql_bit">,
					<cfqueryparam value="#Form.Marketing_Event#" cfsqltype="cf_sql_bit">,
					<cfqueryparam value="#Form.NUC_Target#" cfsqltype="cf_sql_bit">,
					<cfqueryparam value="#Form.Retailer_Unit_Cost#" cfsqltype="cf_sql_bit">,
					<cfqueryparam value="#Form.Merch_Unit_Price#" cfsqltype="cf_sql_bit">,
					<cfqueryparam value="#Form.Retailer_Margin#" cfsqltype="cf_sql_bit">
				)
			</cfquery>
		<cfelse>
			<cfquery NAME="Set_Deleted" DATASOURCE="#application.datasource#">
				UPDATE	Template_Planner_Settings
				SET
					Updated_Date		= GetDate(),
					Updated_By			= '#request.AccessStructure.user_id#',
					Budget				= <cfqueryparam value="#Form.Budget#" cfsqltype="cf_sql_bit">,
					Marketing_Event		= <cfqueryparam value="#Form.Marketing_Event#" cfsqltype="cf_sql_bit">,
					NUC_Target			= <cfqueryparam value="#Form.NUC_Target#" cfsqltype="cf_sql_bit">,
					Retailer_Unit_Cost	= <cfqueryparam value="#Form.Retailer_Unit_Cost#" cfsqltype="cf_sql_bit">,
					Merch_Unit_Price	= <cfqueryparam value="#Form.Merch_Unit_Price#" cfsqltype="cf_sql_bit">,
					Retailer_Margin		= <cfqueryparam value="#Form.Retailer_Margin#" cfsqltype="cf_sql_bit">
				WHERE	First_Parent_ID  = (Select First_Parent_ID FROM Program_Control_Panel_Options where ProgramControl_Panel_Options_ID = '#FORM.Template_ID#')
			</cfquery>
		</cfif>


		<!---D107909 - Planner Program - display Perf Types from template
			Adding Planner Perf Types to Template settings
		--->
		<!---set any existing entries to Deleted = 1 --->
		<cfquery name="qDeletePerfTypes" DATASOURCE="#application.datasource#">
			UPDATE	Template_Planner_Settings_Perf_Types
			SET		Deleted = 1,
					Deleted_Date = getDate()
			WHERE	First_Parent_ID = <cfqueryparam value="#FirstParentID#" cfsqltype="cf_sql_integer">
			AND	Deleted = 0
		</cfquery>
		<!---Loop over selected entries and insert --->
		<cfloop list="#FORM.Planner_Perf_Types_ID#" index="idx">
			<cfquery name="qInsertPerfTypes" DATASOURCE="#application.datasource#">
				INSERT INTO	Template_Planner_Settings_Perf_Types
					(Planner_Perf_Types_ID, First_Parent_ID)
				VALUES
					(<cfqueryparam value="#idx#" cfsqltype="cf_sql_integer">, <cfqueryparam value="#FirstParentID#" cfsqltype="cf_sql_integer">)
			</cfquery>
		</cfloop>

			<cfcatch>
				<cftransaction action="ROLLBACK" />
				<cfrethrow />
			</cfcatch>
		</cftry>

		<cftransaction action="COMMIT" />

	</cftransaction>
	<cfset url.id = Form.Template_ID>
	<cfset pageName = "planner_program">
	<!------ Redirect to next page ----->
	<cfinclude template="Next_Page.cfm" />
