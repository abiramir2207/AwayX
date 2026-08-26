<cfparam name="form.I_Agree" default="1">

<cfset useLakebaseForsaveAgree = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("usda_agreement")>
<cfif useLakebaseForsaveAgree>
	<cftry>
		<cfset application.oLakebase.insertRow("usda_agreement", {
			"user_id" = "#request.AccessStructure.user_id#",
			"operator_id" = "#IAgreeOperator#",
			"operator" = "#form.agree_Operator#",
			"notes" = "#form.Notes#",
			"user_agrees" = "#form.I_Agree#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForsaveAgree = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsaveAgree>
<cfquery name="saveAgree" datasource="#application.datasource#">
	INSERT INTO USDA_Agreement
	(User_ID, Operator_ID, Operator, Notes, User_Agrees)
	VALUES
	('#request.AccessStructure.user_id#', '#IAgreeOperator#', '#form.agree_Operator#', '#form.Notes#', '#form.I_Agree#')
</cfquery>
</cfif>


<cfset finalURL ="generate_report.cfm?operator=#form.agree_Operator#&report_number=#form.report_number#&final_destination=#form.final_destination#&Operator_ID=#Operator_ID#">

<cfif isdefined("form.programid")>
<cfset finalURL ="generate_report.cfm?operator=#form.agree_Operator#&report_number=#form.report_number#&final_destination=#form.final_destination#&programid=#form.programid#&Operator_ID=#Operator_ID#">

</cfif>

<cflocation url="#finalURL#">