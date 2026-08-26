<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Comments for action taken</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
<!--- Dev Note: 11462; Milan - The fixed_popup.js file is for keeping the popup windows fixed --->
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/fixed_popup.js"></SCRIPT>
	<script language="JavaScript">
		/* Add an action */
		function fnMarkAsComplete()
		{	
				frmComments.submit();	
		}
	
		/* Do not add an action */
		function fnMarkAsCancel(Deduction_ID) 
		{
			window.parent.location.href = "/deductions/deduction.cfm?deduction_ID="+Deduction_ID;
			self.close();
		}
	</script>
	
	<style type="text/css">
		.PageHeaders
		{
			font-family:Arial, Helvetica, sans-serif;
			font-size:12px;
			font-weight:bold
		}
	
	
	</style>
</head>

<body onload = "mytimer = setTimeout('fcsOnMe()', 25);">

<!---User profile--->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfset useLakebaseForDeductionsProfilesSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_profiles_settings")>
<cfif useLakebaseForDeductionsProfilesSettings>
	<cftry>
		<cfset DeductionsProfilesSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions_profiles_settings", {
				"select" = "dd_internal_notes,dd_access_level",
				"profiles_id" = "eq.#Get_Profile_Settings.Profiles_ID#"
			}),
			"dd_internal_notes,dd_access_level"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDeductionsProfilesSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionsProfilesSettings>
<cfquery name="DeductionsProfilesSettings" datasource="#application.datasource#">
SELECT DD_Internal_Notes, DD_ACCESS_LEVEL FROM Deductions_Profiles_Settings WHERE Profiles_ID = '#Get_Profile_Settings.Profiles_ID#'
</cfquery>
</cfif>

<cfparam name="SubmitComments" default="">
<cfparam name="Action" default="">
<cfparam name="DD_Ded_Action_ID" default="">
<cfparam name="DD_Stage_ID" default="">
<cfparam name="selComments.Comments" default="">
<cfparam name="selComments.CommentsFlag" default="">
<cfparam name="UpdateAction" default="">
<cfparam name="Action_Completed" default="">

	<!--- Get the Description for the action --->
		<cfset useLakebaseForget_DD_Stage_Description = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_stage")>
		<cfif useLakebaseForget_DD_Stage_Description>
			<cftry>
				<cfset get_DD_Stage_Description = application.oLakebase.toQuery(
					application.oLakebase.selectRows("dd_stage", {
						"select" = "dd_stage_description",
						"dd_stage_id" = "eq.#DD_Stage_ID#",
						"deleted" = "eq.0"
					}),
					"dd_stage_description"
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForget_DD_Stage_Description = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForget_DD_Stage_Description>
		<cfquery name="get_DD_Stage_Description" datasource="#application.datasource#">
			SELECT DD_Stage_Description
			FROM DD_Stage
			WHERE DD_Stage_ID = '#DD_Stage_ID#'
			AND Deleted = 0
		</cfquery>
		</cfif>
	<!--- initialize the reminder components and create reminder once the action changes --->
		<CFSET DeductionManager = CreateObject("component", "components.deduction.DeductionManager").init() />  
	<cfif SubmitComments eq "Save action">
	<!--- Add an action --->
		<cfif UpdateAction eq "0" AND Action neq "Edit">
			<cftransaction>
				<cfquery name="InsertDeductions" datasource="#application.datasource#">
					INSERT INTO DD_Ded_Actions
					(
						Deduction_ID,
						DD_Stage_ID,
						Action_Completed,
						Completed_By,
						Date_Completed,
						Comments,
						CommentsFlag
						
					)
					VALUES
					(
						'#Deduction_ID#',
						'#DD_Stage_ID#',
						'#Action_Completed#',
						'#request.AccessStructure.user_id#',
						#now()#,
						'#form.txtaComments#',
						#form.rdCommentsFlag#
						
					)
				</cfquery>				
				
				<cfquery name="UpdateDeductions" datasource="#application.datasource#">
					UPDATE Deductions
					SET DD_Stage = #DD_Stage_ID#,
					DD_Ded_Action_ID = '#InsertDeductions.DD_Ded_Action_ID#'
					<!---
					TSF: No longer have to get DD_Ded_Action_ID because the InsertDeductions insert query above returns it.
					(SELECT TOP 1 DD_Ded_Action_ID FROM DD_Ded_Actions WHERE Deduction_ID = '#Deduction_ID#' AND 
										DD_Stage_ID = '#DD_Stage_ID#' AND Deleted = 0 ORDER BY Date_Completed DESC)
					--->
					WHERE Deduction_ID = '#Deduction_ID#'
				</cfquery>
				<!---- add reminder ---->
				<cfset DeductionManager.loadDDStageInfo(DD_Stage_ID) />
				 <cfset DeductionManager.loadDDActionInfo(InsertDeductions.DD_Ded_Action_ID) />
				<cfif DeductionManager.getDDStageIsAutoReminded() and DeductionManager.getDDStageAutoDefaultDays() gt 0>
 					<cfset reminderMessage = "Auto Reminder - " & DeductionManager.getDDStageDescription() />
 					<cfset insertReminderID = DeductionManager.addReminder(Deduction_ID,reminderMessage,dateAdd("d",DeductionManager.getDDStageAutoDefaultDays(),DeductionManager.getDDActionCompletedDate()),2) />				
					<cfset DeductionManager.updateAction(InsertDeductions.DD_Ded_Action_ID,insertReminderID) />	
				</cfif> 
			</cftransaction>
		</cfif>
			
	<!--- Update an action --->
			<cfif Action eq "Edit">
				<cftransaction>
					<cfquery name="UpdComments" datasource="#application.datasource#">
						UPDATE DD_Ded_Actions
						<cfif form.txtaComments neq "">
						SET Comments = '#form.txtaComments#'
						,CommentsFlag = '#form.rdCommentsFlag#'
						<cfelse>
						SET Comments = null
						,CommentsFlag = null
						</cfif>
						WHERE DD_Ded_Action_ID = '#DD_Ded_Action_ID#'
						AND Deleted = 0
					</cfquery>
			
					<cfquery name="UpdateDeductions" datasource="#application.datasource#">
						UPDATE Deductions
						SET DD_Stage = #DD_Stage_ID#
						WHERE Deduction_ID = '#Deduction_ID#'
					</cfquery>
				</cftransaction>
			</cfif>
	</cfif>
	
	<cfif SubmitComments eq "Save action">
		<script language="javascript">
		{
			opener.document.all.Refresh.submit();
			self.close();
			//window.parent.location.href = "/deductions/deduction.cfm?deduction_ID=<CFOUTPUT>#Deduction_ID#</CFOUTPUT>"
		}
		</script>
	</cfif>

	
	<!--- While viewing or editing a record --->
	<cfif UpdateAction eq "1" OR Action eq "Edit">
		<cfquery name="selComments" datasource="#application.datasource#">
			SELECT Comments,CommentsFlag 
			FROM DD_Ded_Actions
			WHERE DD_Ded_Action_ID = '#DD_Ded_Action_ID#'
			<cfif DeductionsProfilesSettings.DD_ACCESS_LEVEL LTE 1>
				AND CommentsFlag = 0			
			</cfif>
			AND Deleted = 0
		</cfquery>
	</cfif>
	
<cfset stDeductionLabels = createObject("component", "components.settings.Labels.Labels").init().GetDeductionLabelsStruct() />

<cfoutput>
	<form name="frmComments" action="action_comments.cfm" method="post">
		<table align="center" border="0">
			<tr>
				<td class="PageHeaders">
					<cfif UpdateAction eq "0">
						<cfif Action eq "Edit">
							<strong><font size="+1">Edit a Comment<br/><br/></font></strong>
						<cfelse>
							<strong><font size="+1">Add a Comment<br/><br/></font></strong>
						</cfif>
					</cfif>
				Current #stDeductionLabels["Action"]#: #get_DD_Stage_Description.DD_Stage_Description#
				 <cfif UpdateAction eq "1" AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
				 <a href="#cgi.SCRIPT_NAME#?Deduction_ID=#Deduction_ID#&DD_Ded_Action_ID=#DD_Ded_Action_ID#&DD_Stage_ID=#DD_Stage_ID#&UpdateAction=0&Action=Edit">&nbsp;<strong>[ edit ]</strong></a>
				 </cfif>
				</td>
			</tr>

			<tr>
				<td>
					<cfif UpdateAction eq "0">
					<textarea name="txtaComments" cols="55" rows="15" onPaste="javaScript: return textareaChecklength('500', this);"  onkeyPress="javaScript: return textareaChecklength('500', this);" onfocus="skipcycle=true" onblur="skipcycle=false">#selComments.Comments#</textarea>
					<cfelse>
				
						<cfif selComments.Comments eq "">No Comments
						<cfelse>#selComments.Comments#
						</cfif>
					</cfif>
				</td>
			</tr>
			<tr>
				<td> 
					<cfif UpdateAction eq "0">
					<input type="radio" name="rdCommentsFlag" value="0" <cfif selComments.CommentsFlag eq 0 OR selComments.CommentsFlag eq "">checked</cfif>>External
					<cfif DeductionsProfilesSettings.DD_Internal_Notes eq 1><input type="radio" name="rdCommentsFlag" value="1" <cfif selComments.CommentsFlag eq 1>checked</cfif>>Internal
				 </cfif>
				</cfif>	
				</td>
			</tr>
			<cfif UpdateAction eq "0">
			<tr>
				<td align="center">
				<a href="##" onClick="fnMarkAsComplete();"><strong>[ save #LCase(stDeductionLabels["Action"])# ]</strong></a>
				&nbsp;&nbsp;&nbsp;
				<a href="##" onClick="fnMarkAsCancel('#Deduction_ID#');"><strong>[ cancel #LCase(stDeductionLabels["Action"])# ]</strong></a>
				</td>
			</tr>
			<cfelse>
			<cfif DeductionsProfilesSettings.DD_Internal_Notes eq 1>
				<tr>
					<td><cfif selComments.CommentsFlag eq 0><b>Note:</b> This is a External Note<cfelseif selComments.CommentsFlag eq 1>
					<b>Note:</b> This is an Internal Note
						</cfif>
					</td>
				</tr>
			</cfif>
			</cfif>

</table>
		<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
		<input type="hidden" name="DD_Ded_Action_ID" value="#DD_Ded_Action_ID#">
		<input type="hidden" name="UpdateAction" value="#UpdateAction#">
		<input type="hidden" name="SubmitComments" value="Save Action">
		<input type="hidden" name="Action_Completed" value="1">
		<input type="hidden" name="DD_Stage_ID" value="#DD_Stage_ID#">
		<input type="hidden" name="Action" value="#Action#">
	</form>
</cfoutput>
</body>
</html>
