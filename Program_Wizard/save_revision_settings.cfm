
<cfparam name="Form.Template_ID" 	default="">

<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<cfset thisTemplateDiffVersionIdList = templateManager.getThisTemplateAllParentsID(Form.Template_ID) />
<cfset thisTemplateDiffVersionIdListCount = listLen(thisTemplateDiffVersionIdList) />

<cfif isNumeric(Form.Template_ID)>

	<cfquery name="qGetThisTemplateAllParentsID" datasource="#application.datasource#">
		IF OBJECT_ID('tempdb..##tmp_TemplateList') IS NOT NULL
		DROP TABLE ##tmp_TemplateList

		SELECT		PCP.Programcontrol_Panel_Options_ID
		INTO ##tmp_TemplateList
		FROM 		Program_Control_Panel_Options PCP_Latest
		INNER JOIN 	Program_Control_Panel_Options PCP
		ON PCP_Latest.First_Parent_ID = PCP.First_Parent_ID
		WHERE	 	PCP_Latest.Programcontrol_Panel_Options_ID = #FORM.Template_ID#
		AND 		PCP.Deleted = 0
	</cfquery>

	<cftransaction action="BEGIN">

		<cftry>
			<!------ set defaults ----->
			<cfparam name="Form.End_Date_Revision_Not_Eligibile" 	default="0">
			<cfparam name="Form.End_Date_Revision_Not_Eligibile_Days" 	default="">

			<!------ make sure the yes/no condition is in sync with text box value ----->
			<cfif Form.End_Date_Revision_Not_Eligibile eq 0>
				<cfset Form.End_Date_Revision_Not_Eligibile_Days = "" />
			</cfif>
			<cfif NOT isNumeric(Form.End_Date_Revision_Not_Eligibile_Days)>
				<cfset Form.End_Date_Revision_Not_Eligibile = 0 />
			</cfif>

			<!--- First set the deleted bit to one for all the entries in the table --->
			<CFQUERY NAME="Set_Deleted" DATASOURCE="#application.datasource#">
				UPDATE Template_Revision_Settings
				SET		Revision_Setting_Deleted = 1
				FROM Template_Revision_Settings
				INNER JOIN ##tmp_TemplateList TmpList
				ON  TmpList.Programcontrol_Panel_Options_ID = Template_Revision_Settings.Template_ID
			</CFQUERY>


			<!--- Then insert the latest settings... --->
			<CFQUERY NAME="Save_Data" DATASOURCE="#application.datasource#">
				INSERT INTO Template_Revision_Settings(
						Template_ID,
						Apply_to_All,
						Title_Changes,
						Date_Changes,
						Date_Changes_End,
						Require_Public_Notes_Changed,
						Require_Private_Notes_Changed,
						Products_Added,
						Products_Removed,
						Products_Rates_Changes,
						Products_UOM_Changes,
						Growth_Change_Target,
						Lump_Sum_Changed,
						Lump_Sum_Created,
						Lump_Sum_Removed,
						Distributors_Added,
						Distributors_Removed,
						Operators_Added,
						Operators_Removed,
						Revision_Setting_Created_By,
						Start_Date_Change,
						End_Date_Change,
						End_Date_Revision_Not_Eligibile,
						End_Date_Revision_Not_Eligibile_Days,
						Payment_Frequency_Changes,
						Claim_Mechanic_Changed
			      ,Currency_Change <!---77418 --->
					)
					<!------ Reto-save the revision settings to all previous versions of the template ----->
				SELECT
						ProgramControl_Panel_Options_ID,
						<cfqueryparam value="#Apply_to_All#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#Title_Changes#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#Date_Changes#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#Date_Changes_End#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#Require_Public_Notes_Changed#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#Require_Private_Notes_Changed#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#Products_Added#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#Products_Removed#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#Products_Rates_Changes#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#Products_UOM_Changes#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#Growth_Change_Target#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#Lump_Sum_Changed#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#Lump_Sum_Created#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#Lump_Sum_Removed#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#Distributors_Added#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#Distributors_Removed#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#Operators_Added#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#Operators_Removed#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#request.AccessStructure.user_id#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#Start_Date_Change#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#End_Date_Change#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#Form.End_Date_Revision_Not_Eligibile#" cfsqltype="cf_sql_bit">,
						<cfif IsNumeric(Form.End_Date_Revision_Not_Eligibile_Days)>#Form.End_Date_Revision_Not_Eligibile_Days#<cfelse>NULL</cfif>,
						<cfqueryparam value="#Form.Payment_Frequency_Changes#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#Form.Claim_Mechanic_Changed#" cfsqltype="cf_sql_integer">
						,<cfqueryparam value="#Form.Currency_Change#" cfsqltype="cf_sql_integer">			<!---77418 --->
				FROM 	Program_Control_Panel_Options
				WHERE 	ProgramControl_Panel_Options_ID
				IN 		(SELECT Programcontrol_Panel_Options_ID FROM ##tmp_TemplateList)
			</CFQUERY>

			<cfcatch>
				<cftransaction action="ROLLBACK" />
				<cfrethrow />
			</cfcatch>
		</cftry>

		<cftransaction action="COMMIT" />

	</cftransaction>


	<cfset url.id = Form.Template_ID>
	<cfset pageName = "revision_settings">

	<!------ Redirect to next page ----->
	<cfinclude template="Next_Page.cfm" />

</cfif>