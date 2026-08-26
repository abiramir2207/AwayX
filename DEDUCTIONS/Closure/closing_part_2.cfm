<!---User profile--->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<CFSET ApproveDD = 0>
<CFIF Get_Profile_Settings.DD_Approve_Amount EQ '*' OR FORM.Cleared_Amount LTE Get_Profile_Settings.DD_Approve_Amount>
	<CFSET ApproveDD = 1>
</CFIF>

<CFIF ApproveDD EQ 0>
<CFQUERY NAME="UpdateAgreeInfo" DATASOURCE="#Application.Datasource#">
	INSERT INTO DD_Agreed_Info 	(
									Deduction_ID
								,	User_ID
								,	Profile_ID
								,	User_Position_ID
								,	Authority_Sequence_ID
								,	Is_Agreed
								,	Profile_Approval_Amount
								,	Agreed_Amount)

	SELECT	<cfqueryparam value="#Deduction_ID#" cfsqltype="CF_SQL_VARCHAR">
				,	_Users.User_ID
				,	Profiles_ID
				,	User_Positions_ID
				,	ISNULL(Authority_Sequence_ID,0)
				,	1
				,	<cfqueryparam value="#Get_Profile_Settings.DD_Approve_Amount#" cfsqltype="CF_SQL_FLOAT">
				,	#FORM.Cleared_Amount#
	FROM 				_Users
	INNER JOIN 			User_Position_Holders
	ON User_Position_Holders.User_ID = _Users.User_ID
	AND User_Position_Holders.User_Positions_ID <> 0
	AND	User_Position_Holders.Deleted = 0
	WHERE	_Users.User_ID = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>

	<CFQUERY NAME="" DATASOURCE="#Application.Datasource#">
		UPDATE Deductions
		SET 	DD_Status = CASE WHEN DD_Status = 1 OR DD_Status = 2 THEN 3 ELSE DD_Status END
				,	DD_Resolution_Code = '#ReasonCode#'
				,	Cleared_Amount = '#form.Cleared_Amount#'
		WHERE	Deduction_ID = '#FORM.Deduction_ID#'
	</CFQUERY>

<cfset useLakebaseForUpdateApprovablePositions = application.oLakebase.isEnabled() AND application.oLakebase.isProcMigrated("Populate_Deduction_Approvable_Positions")>
<cfif useLakebaseForUpdateApprovablePositions>
	<cftry>
		<cfset application.oLakebase.callProcedure("Populate_Deduction_Approvable_Positions", { "deduction_id" = Deduction_ID })>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForUpdateApprovablePositions = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateApprovablePositions>
<CFQUERY NAME="UpdateApprovablePositions" DATASOURCE="#Application.Datasource#">
	EXEC Populate_Deduction_Approvable_Positions '#Deduction_ID#'
</CFQUERY>
</cfif>

<BR><BR><BR><BR><BR>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
	<TR>
		<TD><B><FONT COLOR="Red" SIZE="3">You have agreed to this deduction.</FONT></B></TD>
	</TR>
</TABLE>
<SCRIPT language="JavaScript">
	function delayLocate(){
		window.parent.location.href = "/deductions/deduction.cfm?Deduction_ID=<CFOUTPUT>#Deduction_ID#</CFOUTPUT>";
	}
	window.setTimeout('delayLocate()', 3000);
</SCRIPT>
<CFABORT>
</CFIF>

<cfset useLakebaseForDoesReasonNeedApproval = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reason_code")>
<cfif useLakebaseForDoesReasonNeedApproval>
	<cftry>
		<cfset DoesReasonNeedApproval = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_reason_code", {
				"select" = "need_approval,show_operator",
				"dd_reason_code_id" = "eq.#ReasonCode#"
			}),
			"need_approval,show_operator"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDoesReasonNeedApproval = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDoesReasonNeedApproval>
<cfquery name="DoesReasonNeedApproval" datasource="#application.datasource#">
	SELECT Need_Approval,Show_Operator
	FROM DD_Reason_Code
	WHERE DD_Reason_Code.DD_Reason_Code_ID = '#ReasonCode#'
</cfquery>
</cfif>

<cfset useLakebaseForWhoRebills = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_settings")>
<cfif useLakebaseForWhoRebills>
	<cftry>
		<cfset WhoRebills = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deduction_settings", {
				"select" = "rebill"
			}), "rebill"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForWhoRebills = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForWhoRebills>
<cfquery name="WhoRebills" datasource="#application.datasource#">
	SELECT Rebill
	FROM Deduction_Settings
</cfquery>
</cfif>

<cfset useLakebaseForGetDeductionInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForGetDeductionInfo>
	<cftry>
		<cfset GetDeductionInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"deduction_id" = "eq.#Deduction_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDeductionInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDeductionInfo>
<cfquery name="GetDeductionInfo" datasource="#application.datasource#">
	SELECT *
	FROM Deductions
	WHERE Deduction_ID = '#Deduction_ID#'
</cfquery>
</cfif>

<cfset useLakebaseForGetClosureInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForGetClosureInfo>
	<cftry>
		<cfset GetClosureInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"deduction_id" = "eq.#Deduction_ID#",
				"select" = "dd_closure_id,dd_closure_type,distributor_id,dd_amount"
			}), "dd_closure_id,dd_closure_type,distributor_id,dd_amount"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetClosureInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetClosureInfo>
<cfquery name="GetClosureInfo" datasource="#application.datasource#">
	SELECT DD_Closure_ID, DD_Closure_Type, Distributor_ID, DD_Amount
	FROM Deductions
	WHERE Deduction_ID = '#Deduction_ID#'
</cfquery>
</cfif>

<cfif ClosingAction IS "Rebill">
	<cfif WhoRebills.Rebill Is 2>
		<cfinclude template="/deductions/closure/send_rebill_letter.cfm">
		<cfabort>
	<cfelse>
		The process for sending rebilling through client mechanisms has not been established yet. Please contact the administrator to notify them that you are seeing this message.
	</cfif>
<cfelseif ClosingAction IS "Adjust">
	And here we include the adjustment<br>
	<cfinclude template="/deductions/closure/create_adjustment.cfm">
	<cfoutput>
		<script>
			window.parent.location.href = '/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#'
		</script>
	</cfoutput>
	<cfabort>
<cfelse>

</cfif>

<cfset DeductionManager = CreateObject("component", "components.deduction.DeductionManager").init() />
<cfif ! len(dd_classification_id)>
	<cfset dd_classification_id = 0>
</cfif>
<cfset DeductionManager.closeDeduction(Deduction_ID=#Deduction_ID#,ReasonCode=#ReasonCode#,Classification_ID=#dd_classification_id#)>

<cfoutput>
	<script>
		window.parent.location.href = '/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#&emailFax=1'
	</script>
</cfoutput>