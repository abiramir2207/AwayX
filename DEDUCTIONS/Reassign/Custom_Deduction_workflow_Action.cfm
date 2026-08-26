<cfparam name="form.ReassignBy" default="0">
<cfparam name="form.updateClassification" default="0">
<cfparam name="form.updateAction" default="0">
<cfparam name="form.rdCommentsFlag" default="">

<cfif FORM.ReassignBy EQ 1 OR FORM.updateClassification EQ 1>
<!---UPDATE CLASSIFICATIONS--->
	<cfset useLakebaseForUpdateClassifications = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForUpdateClassifications>
		<cftry>
			<cfset application.oLakebase.updateRows("deductions",
				{ "deduction_id" = "in.(#FORM.Deduction_ID#)" },
				{ "dd_classification_id" = FORM.Classifications, "dd_resolution_code" = FORM.Reason_code }
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForUpdateClassifications = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUpdateClassifications>
		<CFQUERY NAME="UpdateClassifications" DATASOURCE="#Application.Datasource#">
			UPDATE Deductions
			SET DD_Classification_ID = '#FORM.Classifications#',DD_Resolution_Code='#FORM.Reason_code#'
			WHERE Deduction_ID IN  (<cfqueryparam value="#FORM.Deduction_ID#" cfsqltype="CF_SQL_VARCHAR" list="yes" /> )
		</CFQUERY>
	</cfif>
</cfif>

<!---UPDATE ACTION--->
<cfif FORM.ReassignBy EQ 2 OR FORM.updateAction EQ 1>
<cftransaction>
	<cfquery name="InsertDeductions" datasource="#application.datasource#">
		INSERT INTO DD_Ded_Actions(
			Deduction_ID,
			DD_Stage_ID,
			Action_Completed,
			Completed_By,
			Date_Completed,
			Comments,
			CommentsFlag
		)
		VALUES(
			'#FORM.Deduction_ID#',
			'#FORM.Actions#',
			'#FORM.Action_Completed#',
			'#request.AccessStructure.user_id#',
			#now()#,
			'#form.txtaComments#',
			#form.rdCommentsFlag#
		)
	</cfquery>

	<cfquery name="UpdateDeductions" datasource="#application.datasource#">
		UPDATE Deductions
		SET DD_Stage = #FORM.Actions#,
				DD_Ded_Action_ID = '#InsertDeductions.DD_Ded_Action_ID#'
		WHERE Deduction_ID = '#FORM.Deduction_ID#'
	</cfquery>
	<!---- add reminder ---->
	<cfset DeductionManager = CreateObject("component", "components.deduction.DeductionManager").init() />
	<cfset DeductionManager.loadDDStageInfo(FORM.Actions) />
	<cfset DeductionManager.loadDDActionInfo(InsertDeductions.DD_Ded_Action_ID) />
	<cfif DeductionManager.getDDStageIsAutoReminded() and DeductionManager.getDDStageAutoDefaultDays() gt 0>
		<cfset reminderMessage = "Auto Reminder - " & DeductionManager.getDDStageDescription() />
		<cfset insertReminderID = DeductionManager.addReminder(Deduction_ID,reminderMessage,dateAdd("d",DeductionManager.getDDStageAutoDefaultDays(),DeductionManager.getDDActionCompletedDate()),2) />
		<cfset DeductionManager.updateAction(InsertDeductions.DD_Ded_Action_ID,insertReminderID) />
	</cfif>
</cftransaction>
</cfif>

<CFSET UnSuccessful = "">	
<cfif form.ReassignBy>
<!--- REASSIGN DEDUCTIONS --->
<CFLOOP LIST="#FORM.Deduction_ID#" INDEX="DD_DedID">
	<cfset useLakebaseForGetDDDet = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForGetDDDet>
	<cftry>
		<cfset GetDDDet = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"deduction_id" = "eq.#DD_DedID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDDDet = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDDDet>
<CFQUERY NAME="GetDDDet" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Deductions WHERE Deduction_ID = '#DD_DedID#'
	</CFQUERY>
</cfif>
	
	<CFIF GetDDDet.Is_locked EQ 1 AND GetDDDet.Locked_By NEQ request.AccessStructure.User_ID>
		<CFSET UnSuccessful = "#UnSuccessful##DD_DedID#,">
	<CFELSE>
		<cfset useLakebaseForLockBeforeReassign = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForLockBeforeReassign>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{
				"deduction_id" = "eq.#DD_DedID#"
			},
			{
				"is_locked" = "1",
				"locked_by" = "#request.AccessStructure.User_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForLockBeforeReassign = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForLockBeforeReassign>
<CFQUERY NAME="LockBeforeReassign" DATASOURCE="#Application.Datasource#">
			UPDATE 	Deductions
			SET 	Is_Locked = 1,Locked_By = '#request.AccessStructure.User_ID#'
			WHERE 	Deduction_ID = '#DD_DedID#'
		</CFQUERY>
</cfif>

		<CFQUERY NAME="Store_Data" DATASOURCE="#Application.Datasource#">
			INSERT INTO		DD_Reassign (	Deduction_ID,
							From_Analyst,
							To_Analyst,
							By_Analyst)
			VALUES		(	'#DD_DedID#',
							<CFIF GetDDDet.Analyst_User_ID NEQ "">
							'#GetDDDet.Analyst_User_ID#',
							<CFELSE>
							NULL,
							</CFIF>
							'#FORM.To_Analyst#',
							'#request.AccessStructure.User_ID#'		)
		</CFQUERY>

		<CFQUERY NAME="Update_DD_Analyst" DATASOURCE="#Application.Datasource#">
			UPDATE 	Deductions
			SET 	Analyst_User_ID = 	'#FORM.To_Analyst#'
					<!--- IF the Deduction Status is New or Open and the Analyst is changing, then set the status back to new --->
					<cfif ListFindNoCase("1,2", GetDDDet.DD_Status) and trim(GetDDDet.Analyst_User_ID) neq trim('#FORM.To_Analyst#')>
					, DD_Status = 1
					</cfif>
			WHERE 	Deduction_ID = '#DD_DedID#' AND Deleted=0
		</CFQUERY>
		<CFIF DD_DedID NEQ FORM.URLDeduction_ID>
			<cfset useLakebaseForUnLock = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForUnLock>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{
				"deduction_id" = "eq.#DD_DedID#"
			},
			{
				"is_locked" = "0",
				"locked_by" = ""
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUnLock = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUnLock>
<CFQUERY NAME="UnLock" DATASOURCE="#Application.Datasource#">
				UPDATE 	Deductions
				SET 	Is_Locked = 0,Locked_By = ''
				WHERE 	Deduction_ID = '#DD_DedID#'
			</CFQUERY>
</cfif>
		</CFIF>
	</CFIF>
</CFLOOP>

<CFIF UnSuccessful NEQ "">
	<CFSET UnSuccessful = ListQualify(UnSuccessful,"'",",","All")>
	<CFQUERY NAME="Unavailable_Title" DATASOURCE="#Application.Datasource#">
		SELECT DD_DedID,SP_Number FROM Deductions WHERE Deduction_ID IN (#PreserveSingleQuotes(UnSuccessful)#)
	</CFQUERY>
	<CFSET UnSuccessfulItems = "">
	<CFOUTPUT QUERY="Unavailable_Title">
		<CFIF SP_Number NEQ "">
			<CFSET Split = #SP_Number#>
		<CFELSE>
			<CFSET Split = "000">
		</CFIF>
		<CFSET UnSuccessfulItems = "#UnSuccessfulItems# [ #TRIM(DD_DedID)# - #Split# ]">
	</CFOUTPUT>
</CFIF>
</cfif>
<CFIF UnSuccessful EQ "">
	<br><br><br><br>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><FONT COLOR="Red" SIZE="3"><B>Please wait while deductions are being reassigned...</B></FONT></TD>
		</TR>
	</TABLE>

	<SCRIPT language="JavaScript">
		function delayLocate(){
			window.parent.location = "/deductions/deduction.cfm?Deduction_ID=<CFOUTPUT>#FORM.URLDeduction_ID#</CFOUTPUT>";
		}
		window.setTimeout('delayLocate()', 3000);
	</SCRIPT>
<CFELSE>
	<SCRIPT language="JavaScript">
		function delayLocate(){
			window.location.href = "/deductions/inc_deduction_details.cfm?Deduction_ID=<CFOUTPUT>#FORM.URLDeduction_ID#</CFOUTPUT>";
		}
		var unSucc = "<CFOUTPUT>#UnSuccessfulItems#</CFOUTPUT>";
		alert("Deduction(s) " + unSucc + " can't be reassigned (These deductions are currently locked by someother user).");
		window.setTimeout('delayLocate()', 0);
	</SCRIPT>
</CFIF>