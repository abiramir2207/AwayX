<cfparam name="form.I_Agree" default="1">

<cfquery name="saveAgree" datasource="#application.datasource#">
	INSERT INTO USDA_Agreement
	(User_ID, Operator_ID, Operator, Notes, User_Agrees)
	VALUES
	('#request.AccessStructure.user_id#', '#IAgreeOperator#', '#form.agree_Operator#', '#form.Notes#', '#form.I_Agree#')
</cfquery>


<cfset finalURL ="generate_report.cfm?operator=#form.agree_Operator#&report_number=#form.report_number#&final_destination=#form.final_destination#&Operator_ID=#Operator_ID#">

<cfif isdefined("form.programid")>
<cfset finalURL ="generate_report.cfm?operator=#form.agree_Operator#&report_number=#form.report_number#&final_destination=#form.final_destination#&programid=#form.programid#&Operator_ID=#Operator_ID#">

</cfif>

<cflocation url="#finalURL#">