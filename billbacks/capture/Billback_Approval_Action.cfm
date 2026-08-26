<cfparam name="allowrelocate" default="1">

<CFIF FORM.Status_Value EQ 2>
    
    <cfquery name="UpdateStatus" datasource="#Application.Datasource#">
        UPDATE Billback
        SET 
            Billback_Status_ID = '#FORM.Status_Value#'
            <CFIF FORM.Status_Value EQ 2><!---- If changing status to RFA, update RFA user id and date ---->
            , BB_Request_Approval_User_ID = '#request.AccessStructure.User_ID#'
            , BB_Request_Approval_Date = GetDate()
            </CFIF>
            , BB_DisAgree = 0
        WHERE
            Billback_ID = '#FORM.Billback_ID#'
    </cfquery>



	<CFQUERY NAME="UpdateApprovablePositions" DATASOURCE="#Application.Datasource#">
		EXEC Populate_Billback_Approvable_Positions '#FORM.Billback_ID#'
	</CFQUERY>
	<CFQUERY NAME="AutoApprovalCheck" DATASOURCE="#Application.Datasource#">
		SELECT 	BB_Reference, Billback_Status_ID, BB_Amount,Auto_Approve_Amount,Auto_Approve_On,Auto_Approve_BB_Types,Auto_Approved_BB_Status, Billback_Payee_Type_ID,
				DateDiff(d, Billback.Created_Date, getDate()) as Billback_Age,
				Billback_Settings.Auto_Appr_Consider_Created_Date, Billback_Settings.Auto_Appr_Age
		FROM 	Billback 
		INNER JOIN Billback_Settings ON 1 = 1
		WHERE 	Billback_ID = '#FORM.Billback_ID#'
	</CFQUERY>
	
	<cfset BillbackSummaryManager = CreateObject("component", "components.Billback.BillbackSummaryManager") />
	<cfif BillbackSummaryManager.getBillbackAutoApproval(
			billbackId = FORM.Billback_ID,
			billbackAmount = AutoApprovalCheck.BB_Amount,
			billbackStatus = AutoApprovalCheck.Billback_Status_ID,
			billbackPayeeTypeId = AutoApprovalCheck.Billback_Payee_Type_ID,
			billbackAge = AutoApprovalCheck.Billback_Age,
			billbackReference = AutoApprovalCheck.BB_Reference)>
		<cfstoredproc procedure="BB_Auto_Approve" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Auto_Approval_Type" value = "1" null="no" />
			<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Billback_ID" value = "#FORM.Billback_ID#" null="no" />
		</cfstoredproc>	
	</cfif>
	
<!--- D38427 : Billback email notifications START --->
<cfquery name="statuscheck" datasource="#application.datasource#">
		select 	*
		from 	billback 
		where billback_id = '#form.billback_id#'
		and billback_status_id <=2
</cfquery>
<cfif statuscheck.recordcount>
		<cfset useLakebaseForemailevent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForemailevent>
	<cftry>
		<cfset emailevent = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "bb_agree_email,billback_rfa_agree_email_event"
			}), "bb_agree_email,billback_rfa_agree_email_event"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForemailevent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForemailevent>
<cfquery name="emailevent" datasource="#application.datasource#">
				select BB_Agree_Email,billback_rfa_agree_email_event
				from _application_Settings
		</cfquery>
</cfif>
			<cfif emailevent.BB_Agree_Email AND (emailevent.billback_rfa_agree_email_event EQ 1 OR emailevent.billback_rfa_agree_email_event EQ 3)>	
					<cfset AgreeEmailBillbackId = form.billback_id>
					<cfset AgreeEmailUserId = request.accessstructure.user_id>
					<cfinclude template="/billbacks/approval/send_agree_email.cfm">
			</cfif>
</cfif>
<!--- D38427 : Billback email notifications END --->		
	
</CFIF>

<cfquery name="Delete_Approved_Discounts" datasource="#application.datasource#">
DELETE FROM BB_Product_Discount
WHERE Billback_ID = '#FORM.Billback_ID#'
</cfquery>

<cfset local_bbid = FORM.Billback_ID>
<cfinclude template="bb_menu_stats.cfm">

<cfif allowrelocate EQ 1>
	<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js">
	<script>
		callfireEvent(window.parent.document,window.parent.summary_tab,'Click');
	</script>
</cfif>
