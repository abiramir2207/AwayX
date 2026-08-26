<!---
Author: Clarence Morse
Evaluation Notes:
Modes: URL.Mode Sets the Eval Action of the Form.
File: evaluationNotes.cfm
Edited By: Brad Lee 10/31/08 [D17421]

0 = Read Only
1 = Agree
2 = Approve
3 = Reset to WIP
4 = Revise after Agreed
5 = RFA
6 = Approval Link clicked on Margin Page
7 = Agree from Old Approval Schemes
8 = Pending ERP Status
9 = Disgree link clicked on margin page when program is in RFA

Modified Date: Mar 1, 2006 : KAL
Extended the table to use it for Business Considerations Notes.
The Variable/Parameter 'NoteType' determines the type of the note.
So you need to pass this code to this page depending on the type of note.
1 = Evaluation Notes
2 = Business Considerations Notes
--->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfparam name="ParentFormName" default="">
<cfparam name="reject" default="0">
<cfparam name="mode" default="0">
<cfparam name="edit" default="1">
<cfparam name="editRecord" default="0">
<cfparam name="evalAction" default="">
<cfparam name="NoteType" default="1">
<cfparam name="PAGE_TITLE" default="Business Considerations">
<cfparam name="frmWidth" default="750px">
<cfparam name="ProgramAgree" default="0">
<!--- D11689: On Revision force Biz Considerations --->
<cfparam name="Force_BizCon" default="0">
<cfparam name="form.closeWindow" default="0">
<cfparam name="Disagreed" default="0">
<cfparam name="SuppressBusConsid" default="0">
<cfparam name="RFAafterReset" default="0">

<!--- 17257 RBL [begin] --->
<cfparam name="form.bFormSubmitted" type="boolean" default="0">
<cfparam name="form.bContinueApproval" type="boolean" default="0">
<cfparam name="form.notes" 			type="string" default="">
<!--- 17257 RBL [end] --->

<cfparam name="form.programAlertFlag" default="0" />

<cfif isdefined("form.mode")>
	<cfset mode = form.mode >
</cfif>

<cfif isdefined("URL.FormName") and URL.FormName NEQ "">
	<cfset ParentFormName = URL.FormName>
</cfif>

<cfif isdefined("form.NoteType")>
	<cfset NoteType = form.NoteType >
</cfif>

<!--- D11689: On Revision force Biz Considerations: Incase the user saves the note then we dont need to force --->
<cfif isdefined("form.Force_BizCon")>
	<cfset Force_BizCon = form.Force_BizCon >
</cfif>

<cfif NoteType EQ 2>
	<cfset PAGE_TITLE = "Business Considerations">
</cfif>

<CFSWITCH expression="#mode#">
	<CFCASE value="1,7" delimiters=",">
		<cfset evalAction = 'Agree'>
	</CFCASE>
	<CFCASE value="2">
		<cfset evalAction = 'Approve'>
	</CFCASE>
	<CFCASE value="3">
		<cfset evalAction = 'Reset to WIP'>
	</CFCASE>
	<CFCASE value="4">
		<cfset evalAction = 'Revise after Agreed'>
	</CFCASE>
	<CFCASE value="5">
		<cfset evalAction = 'RFA'>
	</CFCASE>
	<CFCASE value="6">
		<cfset evalAction = 'Approve Action'>
	</CFCASE>
	<CFCASE value="8">
		<cfset evalAction = 'ERP Research'>
	</CFCASE>
	<CFCASE value="9">
		<cfset evalAction = 'Disagree'>
	</CFCASE>
	<cfdefaultcase>
		<!--- Mode Not Passed to Template --->
	</cfdefaultcase>
</CFSWITCH>

<cfif reject EQ "1">
	<cfset evalAction = 'Reject'>
</cfif>

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<!--- Get Business Considerations Reminder Data --->
<cfinvoke component="components.settings.BusinessConsiderationsReminder" method="get" returnvariable="qBizConReminders">

<!--- In case no value is returned from above query --->
<cfif qBizConReminders.recordcount LT 1>
	<cfset business_considerations_reminders_on = 0>
<cfelse>
	<cfset business_considerations_reminders_on = qBizConReminders.business_considerations_reminders_on>
</cfif>


<!--- Decrypt Contract ID, Retrieve Contract_Number, and Get Evaluation Notes --->
<cfif isDefined("url.CID")>
	<cf_cryp type="de" key="#request.key#" string="#URL.CID#">

	<cfquery name="qContractNumber" datasource="#application.datasource#">
		select contract_number,Is_A_Revision, ProgramType_ID, Reset_User_ID from contract_main where contract_main_id = '#cryp.value#'
	</cfquery>

	<!--- D11689: On Revision force Biz Considerations --->
	<cfset TemplateRevisionSettings = CreateObject("component", "components.programs.template.TemplateManager").getTemplateRevisionSettings(qContractNumber.ProgramType_ID) />

	<!-- D11689: Once a user enters a note dont force again. If form.bFormSubmitted is defined, it means the form was already submitted once, so dont force biz_con again -->
	<cfif TemplateRevisionSettings.Require_Private_Notes_Changed EQ 1 AND qContractNumber.Is_A_Revision EQ 1 AND mode EQ 5 AND NOT form.bFormSubmitted>
		<cfset Force_BizCon = 1 />
	<cfelseif appSettings.getBC_On_RFA_af_Reset() and qContractNumber.Reset_User_ID NEQ "" and mode EQ 5>
		<cfset Force_BizCon = 1 />
		<cfset RFAafterReset =1>
	<cfelseif (appSettings.getRequire_Business_Considerations_On_New_Programs() and qContractNumber.Is_A_Revision EQ "0" and (mode EQ 6 OR mode EQ 2))>
		<cfset Force_BizCon = 1 />
	<cfelse>
		<cfset Force_BizCon = 0 />
	</cfif>
	<cfif form.bFormSubmitted>
		<cfif len(trim(form.notes))>
        <!--- 17257 [begin] not needed?
		#REReplaceNoCase(trim(form.notes),"\r","<br>","ALL")#
		17257 [end] --->
        <!--- D17383 put it back in... '#reReplaceNoCase(trim(form.notes),"\r","<br>","ALL")#' --->
			<!--- When a record is edited, update notes --->
			<cfif editRecord gt 0>
				<cfquery name="editSaveEvaluationNotes" datasource="#application.datasource#">
					UPDATE contract_evaluation_notes
					SET Notes = '#reReplaceNoCase(trim(form.notes),"\r","<br>","ALL")#'
					WHERE contract_evaluation_notes_id = #editRecord#
				</cfquery>
				<!--- Reset "editRecord" back to 0 as update is complete. --->
				<cfset editRecord = 0>

			<cfelse>
			<cfquery name="postEvaluationNotes" datasource="#application.datasource#">
					IF NOT EXISTS (select * from contract_evaluation_notes where Entered_By = '#form.userName#' AND Eval_Action = '#form.evalAction#' AND Notes = '#trim(form.notes)#' AND Contract_Number = '#qContractNumber.Contract_Number#')
					BEGIN
						INSERT into contract_evaluation_notes (Entered_By, Eval_Action, Notes, Contract_Number, Contract_Notes_Type)
						VALUES('#form.userName#','#form.evalAction#','#reReplaceNoCase(trim(form.notes),"\r","<br>","ALL")#','#qContractNumber.Contract_Number#', '#NoteType#')
					END
			</cfquery>
			</cfif>
		</cfif>

		<!---Add the entry for Program Alert Message--->
		<cfif form.programAlertFlag eq 1>
			<cfset variables.oProgramAlertManagerSubmit = createObject("component", "components.settings.ProgramAlerts.ProgramAlertManager") />
			<cfset variables.oProgramAlertManagerSubmit.addProgramAlertMessage(form.programAlertMessage, qContractNumber.Contract_Number, request.AccessStructure.User_ID, cryp.value) />
		</cfif>

	</cfif>

  <!---
    22910/Anand Rao/29-Mar-10:
    Business Consideration sorting:
    1) Moved the code for the table to be at the bottom of the page
    2) Most recent one will be at the top by default
    3) Added the below code for doing the sorting on all columns
  --->
  <cfset sortByField          = "Created_Date" />
  <cfset orderBy              = "DESC" />
  <cfset sortOrderParam       = "" />
  <cfset sortOrderParamDate   = "DA"   />
  <cfset sortOrderParamUser   = "UD"   />
  <cfset sortOrderParamAction = "AD"   />
  <cfset sortOrderParamNotes  = "ND"   />
  <cfset imgDate              = ""/>
  <cfset imgUser              = "" />
  <cfset imgAction            = "" />
  <cfset imgNotes             = "" />

  <cfif isDefined("URL.sortOrderParam") AND URL.sortOrderParam EQ "DA">
    <cfset sortByField = "Created_Date"/>
    <cfset orderBy = "ASC" />
    <cfset sortOrderParamDate = "DD" />
    <cfset imgDate = "<img src='/Images/up_1.gif' border='0' />" />
  <cfelseif isDefined("URL.sortOrderParam") AND URL.sortOrderParam EQ "DD">
    <cfset sortByField = "Created_Date"/>
    <cfset orderBy = "DESC" />
    <cfset sortOrderParamDate = "DA" />
    <cfset imgDate = "<img src='/Images/down_1.gif' border='0' />" />
  <cfelseif isDefined("URL.sortOrderParam") AND URL.sortOrderParam EQ "UA">
    <cfset sortByField = "Entered_By"/>
    <cfset orderBy = "ASC" />
    <cfset sortOrderParamUser = "UD" />
    <cfset imgUser = "<img src='/Images/up_1.gif' border='0' />" />
  <cfelseif isDefined("URL.sortOrderParam") AND URL.sortOrderParam EQ "UD">
    <cfset sortByField = "Entered_By"/>
    <cfset orderBy = "DESC" />
    <cfset sortOrderParamUser = "UA" />
    <cfset imgUser = "<img src='/Images/down_1.gif' border='0' />" />
  <cfelseif isDefined("URL.sortOrderParam") AND URL.sortOrderParam EQ "AA">
    <cfset sortByField = "Eval_Action"/>
    <cfset orderBy = "ASC" />
    <cfset sortOrderParamAction = "AD" />
    <cfset imgAction = "<img src='/Images/up_1.gif' border='0' />" />
  <cfelseif isDefined("URL.sortOrderParam") AND URL.sortOrderParam EQ "AD">
    <cfset sortByField = "Eval_Action"/>
    <cfset orderBy = "DESC" />
    <cfset sortOrderParamAction = "AA" />
    <cfset imgAction = "<img src='/Images/down_1.gif' border='0' />" />
  <cfelseif isDefined("URL.sortOrderParam") AND URL.sortOrderParam EQ "NA">
    <cfset sortByField = "Notes"/>
    <cfset orderBy = "ASC" />
    <cfset sortOrderParamNotes = "ND" />
    <cfset imgNotes = "<img src='/Images/up_1.gif' border='0' />" />
  <cfelseif isDefined("URL.sortOrderParam") AND URL.sortOrderParam EQ "ND">
    <cfset sortByField = "Notes"/>
    <cfset orderBy = "DESC" />
    <cfset sortOrderParamNotes = "NA" />
    <cfset imgNotes = "<img src='/Images/down_1.gif' border='0' />" />
  </cfif>

 <cfset sortURL = application.HTTPVar & CGI.SERVER_NAME & CGI.SCRIPT_NAME & "?" />

 <cfif isdefined("URL.MODE") and URL.MODE NEQ "">
	 <cfset sortURL = sortURL & "MODE="& URL.MODE & "&" />
 </cfif>
 <cfif isdefined("URL.EDIT") and URL.EDIT NEQ "">
	 <cfset sortURL = sortURL & "EDIT="& URL.EDIT & "&" />
 </cfif>
 <cfif isdefined("URL.NoteType") and URL.NoteType NEQ "">
	 <cfset sortURL = sortURL & "NoteType="& URL.NoteType & "&" />
 </cfif>
 <cfif isdefined("URL.FormName") and URL.FormName NEQ "">
	 <cfset sortURL = sortURL & "FormName="& URL.FormName & "&" />
 </cfif>
 <cfif isDefined("URL.CID")>
  <cfset sortURL = sortURL & "CID=" & URL.CID />
 </cfif>

<!--- Query which gets the details of the record which needs to be updated. --->
<cfif editRecord gt 0>
	<cfquery name="qEvaluationNotesEdit" datasource="#application.datasource#">
			select 	Contract_Evaluation_Notes.Contract_Evaluation_Notes_ID,
				Contract_Evaluation_Notes.Notes
			from 	Contract_Evaluation_Notes
			where 	Contract_Evaluation_Notes.Contract_Number = '#qContractNumber.Contract_Number#'
			and Contract_Evaluation_Notes.Contract_Evaluation_Notes_ID = #editRecord#
	</cfquery>
</cfif>
 <!--- Query which gets all the records. --->
<cfquery name="qEvaluationNotes" datasource="#application.datasource#">
		select Contract_Evaluation_Notes.Contract_Evaluation_Notes_ID,
				Contract_Evaluation_Notes.Entered_By,
				Contract_Evaluation_Notes.Eval_Action,
				Contract_Evaluation_Notes.Notes,
				Contract_Evaluation_Notes.Created_Date,
				Contract_Evaluation_Notes.Contract_Notes_Type
		from 	Contract_Evaluation_Notes
		where 	Contract_Evaluation_Notes.Contract_Number = '#qContractNumber.Contract_Number#'
		<!--- Dev Note Ben removed below line so we diplay all notes available --->
		<!--- and 	Contract_Evaluation_Notes.Contract_Notes_Type = '#NoteType#' --->
		and		Contract_Evaluation_Notes.Deleted = 0
		order by #sortByField# #orderBy#
    -- this was ASC earlier
	</cfquery>

	<!--- 25710 show Business Considerations  regardless of  Suppress Business Considerations ON/OFF  --->
	<cfif mode NEQ 9 and Mode NEQ 3 and SuppressBusConsid NEQ 1 and NOT (appSettings.getBC_On_RFA_af_Reset() and qContractNumber.Reset_User_ID NEQ "" and mode EQ 5)>
	<!---TSF - Label 11516: Don't display Business considerations if the application setting is on and there aren't any.--->
	 <!--- Do not close the window if the app switch "Display Bus Cons on RFA after Reset" is ON and profram is being RFAed after being Reset --->
	 <cfif NOT qEvaluationNotes.recordCount and appSettings.getSuppressBusinessConsiderations()>

		<script>
			<cfif mode eq 2>
				opener.NewWindowTopLeft('/clause_library/clause_approval.cfm?CID=<cfoutput>#URL.CID#</cfoutput>','name','1150','600','Yes', 'Yes');
			<cfelseif mode eq 7>
				opener.location.href = "program_agree_action.cfm?CID=<cfoutput>#URL.CID#</cfoutput>&User_Id=<cfoutput>#request.AccessStructure.User_ID#</cfoutput>";
			<cfelseif ParentFormName EQ "MyForm" and reject EQ 1>
				opener.document.all.<cfoutput>#ParentFormName#</cfoutput>.action = "program_reject_action.cfm?CID=<cfoutput>#URL.CID#</cfoutput>&User_Id=<cfoutput>#URL.user_id#</cfoutput>";
				opener.document.all.<cfoutput>#ParentFormname#</cfoutput>.submit();
			<cfelse>
				<cfif ParentFormName NEQ "">
					if(opener.document.all.<cfoutput>#ParentFormname#</cfoutput>.ProgramAgree)
					{
						opener.document.all.<cfoutput>#ParentFormname#</cfoutput>.ProgramAgree.value = <cfoutput>#ProgramAgree#</cfoutput>;
					}
					opener.document.all.<cfoutput>#ParentFormname#</cfoutput>.submit();
				</cfif>
			</cfif>
			window.close();
		</script>
	 </cfif>
	</cfif>

	<cfif form.closeWindow eq 1>
		<script>
			window.close();
		</script>
	</cfif>

</cfif>

<html>
<head>
	<title><cfoutput>#PAGE_TITLE#</cfoutput></title>

	<style type="text/css">
		table {
				/*margin-right:10px;*/
				border-collapse:collapse;
				width:<cfoutput>#frmwidth#</cfoutput>
				}
		th 	  { font-size:9pt;
				color:#000000;
				font-weight:550;
				font-family:verdana;
				text-align:left;
				padding-left:5px;
				background-color:#FFCE84;
				}
		td 	  {	font-size:8pt;
				color:#000000;
				padding-left:5px;
				font-family:verdana;
				vertical-align:top;
				}
		pre	  {
				font-size:8pt;
				color:#000000;
				font-family:verdana;
			  }
		td.norecords  {	font-size:8pt;
						color:#770022;
						font-family:verdana;
						padding-left:5px;
						text-align:center;
						}
		.header { font-size:11pt;
				  font-weight:bold;
				  color:#000000;
				  font-family:verdana;
				  text-align:left;
				  width:<cfoutput>#frmWidth#</cfoutput>;
				  }
		textarea { width:725px;
				   height:75;
				   margin-top:5px;
				   margin-bottom:5px;
				   margin-right:10px;
				   margin-left:10px;
				   font-family:verdana;
				   }
		p.bodyheader 	{ font-size:10pt;
						  color:#22006F;
						  font-family:verdana;
						  font-weight:bold;
						  }
		/* Reminders */
		div.heading {font-size:12pt;font-family:verdana;}
		div.heading p {font-size:8pt;font-style:italic;font-family:verdana;margin:1px;margin-left:10px;padding:1px;font-weight:500;}
		div.heading ol {font-size:8pt;font-style:italic;font-family:verdana;font-weight:500;}
		div.heading ul {font-size:8pt;font-style:italic;font-family:verdana;font-weight:500;}
		div.heading span {font-weight:bold;font-size:10pt;}

		a	{ font-family:verdana;
			  font-size:10pt;
			  font-weight:700;
			  color:dark blue;
			  }
		.likelink	{ font-family:verdana;
					  font-size:9pt;
					  font-weight:700;
					  color:blue;
					  background-color:white;
					  }
	</style>

	<script SRC="/Script/javascript/string_functions.js?v=08182020"></script>

	<script type="text/javascript" language="JavaScript">

	function ValidateForm()
	{
		var msg = "";

		Force_BizCon = document.all.Force_BizCon.value;
		EvaluationNotes = trim(document.all.EvaluationNotes.value);

		if (EvaluationNotes.length == 0) {
			msg = "The submitted note is blank. Please enter a valid note.";
		}
		else if (EvaluationNotes.length > 4000) {
			msg = "The submitted note exceeds the size limit. Please revise the note.";
		}

		// return message
		return msg;
	}

	</script>

</head>
<body>
<cfinclude template="/common_files/programTranslate.cfm">    <!--- french translation --->

<p align="left" class="header" style="display:inline"><cfoutput>#PAGE_TITLE#</cfoutput>:</p>
	<cfif business_considerations_reminders_on>
		<HR><div class="heading" align="left">
			 <cfoutput>
			 	<span style="font-size:10pt;font-style:italic;"><b>Reminders:</b></span>
				#qBizConReminders.business_considerations_reminders_txt#
			</cfoutput>
		</div>
	</cfif>
	<HR>


<cfif edit EQ 1><cfoutput>

	<form name="EvalForm" method="Post" action="evaluationnotes.cfm?CID=#URL.CID#">
	<table width="#frmWidth#" align="center" border="1">
	<tr><th width="700px">Add Note</th></tr>
	<tr><td width="700px"><b>Action:</b> #application.util.string.fCase(evalAction)#</td></tr>
	<tr><td width="700px"><b>Notes:</b><br>
    <!--- 17257 [begin] --->
    <!--- D17383 took back out <cfif len(trim(form.notes))>#form.notes#</cfif> --->
	<textarea id="EvaluationNotes" name="notes" width="#frmWidth#"><cfif editRecord gt 0>#trim(qEvaluationNotesEdit.Notes)#</cfif></textarea>
    <!--- 17257 [end] --->
	</td></tr>

	<!--- Display Program Alerts if mode = 6, Program Alert application setting is on and there is a Program Alert for this Program Type --->
	<cfif mode eq 6 and appSettings.getProgramAlerts()>
		<!--- init the ProgramAlertManager --->
		<cfset variables.oProgramAlertManager = createObject("component", "components.settings.ProgramAlerts.ProgramAlertManager") />
		<!--- check to see if this program type has an alert --->
		<cfset variables.qGetThisProgramAlert = variables.oProgramAlertManager.getProgramAlertTemplate(qContractNumber.ProgramType_ID) />
		<cfif variables.qGetThisProgramAlert.RecordCount>
			<cfset variables.reminder = variables.oProgramAlertManager.getProgramAlertReminder().Reminder />
			<tr><td width="700px">&nbsp;</td></tr>
			<tr><th width="700px">PROGRAM ALERT</th></tr>
			<tr>
				<td width="700px"><b>REMINDER:</b> #variables.reminder#</td>
			</tr>
			<tr>
				<td width="700px">
					<input name="sendProgramAlert" type="checkbox" value="1" /> <b>Send Program Alerts</b>
				</td>
			</tr>
			<tr>
				<td width="700px"><b>MESSAGE:</b>
					<br>
					<textarea name="programAlertMessage" width="#frmWidth#"></textarea>
				</td>
			</tr>
			<input type="hidden" name="programAlertFlag" value="1">
		</cfif>
	</cfif>

	<tr>
	<td width="700px" align="center">
	<cfif Reject EQ 1 >
		<cfset wide = "100%" />
	<cfelseif (Reject NEQ 1) and (mode EQ 3) and form.bFormSubmitted>
		<cfset wide = "33%" />
	<cfelse>
		<cfset wide = "50%" />
	</cfif>

	<table width="680px" align="center" border="0">
		<tr>
		<cfif Reject NEQ 1 and mode NEQ 9 and RFAafterReset NEQ 1>
			<td  width="#wide#" align="center">
				<span style="font-weight:bold;color:red"> [ </span> <a href="##" OnClick="javascript:submitSave(this);return false;">save note</a>	<span style="font-weight:bold;color:red"> ] </span>
			</td>
		</cfif>
		<cfif (mode EQ 3) and form.bFormSubmitted>
			<td  width="#wide#" align="center">
				<!--- Dev Note: drachala; D28784: Close open window on reset  START
                Added/Changed: Added file location to UNLOCK the program--->
				<span style="font-weight:bold;color:red"> [ </span> <a href="/Common_Files/Contracts/UnLock_Contract.cfm?CID=#URL.CID#" OnClick="emailNote();">email note</a>	<span style="font-weight:bold;color:red"> ] </span>
			   <!--- End Dev Note: drachala; D28784: Close open window on reset  --->
			</td>
		</cfif>

		<cfif mode EQ 3 or mode EQ 4 or mode EQ 0>
			<td width="#wide#" align="center">
				<span style="font-weight:bold;color:red"> [ </span>
				<a href="##" OnClick="javascript:ValidateCloseWindow(this);">close window</a>
				<span style="font-weight:bold;color:red"> ] </span>
			</td>
		<cfelse>
			<cfif mode EQ 1 or mode EQ 5 or mode EQ 6 or mode EQ 7 or mode EQ 8 or mode EQ 9 or RFAafterReset EQ 1>
			<td  width="#wide#" align="center">
				&nbsp;&nbsp;&nbsp;&nbsp;
				<span style="font-weight:bold;color:red"> [ </span>
				<a href="##" OnClick="javascript:submitform(this);">save/continue</a>
				<span style="font-weight:bold;color:red"> ] </span>
			</td>
			</cfif>
			<cfif mode EQ 2>
			<td  width="#wide#" align="center">
				&nbsp;&nbsp;&nbsp;&nbsp;
				<span style="font-weight:bold;color:red"> [ </span>
				<a href="##" OnClick="javascript:continueapproval();return false">continue</a>
				<span style="font-weight:bold;color:red"> ] </span>
			</td>
			</cfif>
		</cfif>
		</tr>
	</table>
	<input type="hidden" name="Force_BizCon" value="#Force_BizCon#">
	<input type="hidden" name="bFormSubmitted" value="1">
	<input type="hidden" name="bContinueApproval" value="#FORM.bContinueApproval#">
	<input type="hidden" name="evalAction" value="#evalaction#">
	<input type="hidden" name="ProgramAgree" value="#ProgramAgree#">
	<input type="hidden" name="mode" value="#mode#">
	<input type="hidden" name="NoteType" value="#NoteType#">
	<input type="hidden" name="ParentFormName" value="#ParentFormName#">
	<input type="hidden" name="userName" value="#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#">
	<input type="hidden" name="closeWindow" value="0">
	<input type="hidden" name="editRecord" value="#editRecord#">
</td></tr></table>
	</form>
</cfoutput>
</cfif>



<table width="#frmWidth#" align="center" border=1>
<!---
	Dev Notes: D23984/Anand Rao/30-Jun-2010
	Business Consideration close button
--->
<cfif edit EQ 0>
	<tr><td colspan="4" align="center">
		<span style="font-weight:bold;color:red"> [ </span> <a href="##" OnClick="javascript:window.close();">close window</a>  <span style="font-weight:bold;color:red"> ] </span>
		<cfif NoteType EQ 2 and mode NEQ 0>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<span style="font-weight:bold;color:red"> [ </span> <a href="##" OnClick="javascript:continueapproval();return false">continue</a>  <span style="font-weight:bold;color:red"> ] </span>
		</cfif>
	</td></tr>
</cfif>
<tr>
  <cfoutput>
    <th width="90px">
      <a href="#sortURL#&sortOrderParam=#sortOrderParamDate#">Date #imgDate#</a>
    </th>
    <th width="120px">
      <a href="#sortURL#&sortOrderParam=#sortOrderParamUser#">User Name #imgUser#</a>
    </th>
    <th width="90px">
      <a href="#sortURL#&sortOrderParam=#sortOrderParamAction#">Action #imgAction#</a>
     </th>
    <th width="450px" colspan="2">
      <a href="#sortURL#&sortOrderParam=#sortOrderParamNotes#">Notes #imgNotes#</a>
    </th>
  </cfoutput>
</tr>
<cfif qEvaluationNotes.recordCount>
<cfoutput query="qEvaluationNotes">
<tr><td width="90px" style="padding-top: 10px;padding-bottom: 10px;">#dateFormat(qEvaluationNotes.Created_Date,'MM/DD/YYYY')#</td>
	<td width="120px" style="padding-top: 10px;padding-bottom: 10px;">#qEvaluationNotes.Entered_By#</td>
	<td width="90px" style="padding-top: 10px;padding-bottom: 10px;">#qEvaluationNotes.Eval_Action#</td>
	<td width="450px" style="padding-top: 10px;padding-bottom: 10px; padding-right: 5px;">#trim(qEvaluationNotes.Notes)#</td>
	<!--- Edit one's own business consideration. --->
	<cfif edit eq 1><td width="30px"><cfif qEvaluationNotes.Entered_By eq "#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#"><a href="evaluationNotes.cfm?CID=#URL.CID#&edit=1&editRecord=#qEvaluationNotes.Contract_Evaluation_Notes_ID#">edit</a></cfif></td></cfif></tr>
</cfoutput>
<cfelse>
<tr><td colspan="4" class="norecords" align="center">No Matching Records Found</td></tr>
</cfif>
<cfif edit EQ 0>
	<tr><td colspan="4" align="center">
		<span style="font-weight:bold;color:red"> [ </span> <a href="##" OnClick="javascript:window.close();">close window</a>  <span style="font-weight:bold;color:red"> ] </span>
		<cfif NoteType EQ 2 and mode NEQ 0>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<span style="font-weight:bold;color:red"> [ </span> <a href="##" OnClick="javascript:continueapproval();return false">continue</a>  <span style="font-weight:bold;color:red"> ] </span>
		</cfif>
	</td></tr>
</cfif>
</table>

<script>

function submitform(obj)
{
	var msg = "Submit in progress.";
	obj.onclick = function () {window.alert(msg);};

	Force_BizCon = document.all.Force_BizCon.value;
	EvaluationNotes = document.all.EvaluationNotes.value;

	<cfif isdefined("ParentFormname") and ParentFormname NEQ "">
		<cfif mode EQ 7> <!--- /* Agree from Old Approval Schemes */ --->
			opener.location.href = "program_agree_action.cfm?CID=<cfoutput>#URL.CID#</cfoutput>&User_Id=<cfoutput>#request.AccessStructure.User_ID#</cfoutput>";
		<cfelse>
			if(opener.document.all.<cfoutput>#ParentFormname#</cfoutput>.ProgramAgree){
				opener.document.all.<cfoutput>#ParentFormname#</cfoutput>.ProgramAgree.value = <cfoutput>#ProgramAgree#</cfoutput>;
			}
			<cfif  ParentFormName EQ "MyForm" and Disagreed EQ 1 and mode eq 9>
				opener.document.all.<cfoutput>#ParentFormname#</cfoutput>.Disagreed.value = 1;
				opener.document.all.<cfoutput>#ParentFormname#</cfoutput>.notes.value = this.document.all.notes.value;
				opener.document.all.<cfoutput>#ParentFormName#</cfoutput>.action = "contract_kickback_action.cfm?CID=<cfoutput>#URL.CID#</cfoutput>&Disagreed=1";
			</cfif>

			<cfif  ParentFormName EQ "MyForm" and reject EQ 1>
				opener.document.all.<cfoutput>#ParentFormname#</cfoutput>.notes.value = this.document.all.notes.value;
				opener.document.all.<cfoutput>#ParentFormname#</cfoutput>.mode.value = this.document.all.mode.value;
				opener.document.all.<cfoutput>#ParentFormname#</cfoutput>.evalAction.value = this.document.all.evalAction.value;
				opener.document.all.<cfoutput>#ParentFormname#</cfoutput>.NoteType.value = this.document.all.NoteType.value;
				opener.document.all.<cfoutput>#ParentFormname#</cfoutput>.Contract_Number.value = '<cfoutput>#qContractNumber.Contract_Number#</cfoutput>';
				opener.document.all.<cfoutput>#ParentFormname#</cfoutput>.userName.value = this.document.all.userName.value;
				opener.document.all.<cfoutput>#ParentFormName#</cfoutput>.action = "program_reject_action.cfm?CID=<cfoutput>#URL.CID#</cfoutput>&User_Id=<cfoutput>#URL.user_id#</cfoutput>";
			</cfif>

			// handle for program alerts
			if(document.all.EvalForm.sendProgramAlert)
			{
				var progrAlrtMsg = "";

				if(document.all.EvalForm.sendProgramAlert.checked)
				{
					strProgramAlertMessage = trim(document.all.EvalForm.programAlertMessage.value);
					if (strProgramAlertMessage.length == 0)
					{
						progrAlrtMsg = "Message is required when sending Program Alerts.";
					}
					else if (strProgramAlertMessage.length > 1200)
					{
						progrAlrtMsg = "Program Alerts cannot exceed 1200 characters.";
					}

				}

				if (progrAlrtMsg.length > 0)
				{
					alert(progrAlrtMsg);
					obj.onclick = function () {submitform(obj);};
					return false;
				}
			}
			if (Force_BizCon == 1 && (EvaluationNotes.length > 4000 || EvaluationNotes.length ==0)){
				msg = ValidateForm();
				if (msg.length > 0){
					alert(msg);
					obj.onclick = function () {submitform(obj);};
					return false;
				}
			}
			else{
				document.all.EvalForm.closeWindow.value = 1;
				document.all.EvalForm.submit();
				opener.document.all.<cfoutput>#ParentFormname#</cfoutput>.submit();
				return;
			}
		</cfif>
	</cfif>
	window.close();
}

function continueapproval()
{

	<cfif edit EQ 1>
	continueApproval = document.all.bContinueApproval.value;
	</cfif>
	<cfif ((Force_BizCon EQ 1) AND (FORM.bContinueApproval EQ 0))>
		Force_BizCon = document.all.Force_BizCon.value;
		EvaluationNotes = document.all.EvaluationNotes.value;
		// alert(Force_BizCon);
		if (Force_BizCon == 1 && (EvaluationNotes.length > 4000 || EvaluationNotes.length ==0)){
				msg = ValidateForm();
					if (msg.length > 0){
						alert(msg);
						// this.onclick = function () {submitform(this);};
						return false;
					}
		}
		else
		{
			document.all.bContinueApproval.value = "1";
			document.all.EvalForm.submit();
		}
	</cfif>
	<cfif edit EQ 1>
	document.all.bContinueApproval.value = 1;
	</cfif>
	<cfif appSettings.getpaymenthistoryon() and Get_Profile_Settings.payment_history_alert EQ 1 and qContractNumber.Is_A_Revision EQ 1>
	if(confirm("Review Settlement History"))
	{
	opener.NewWindowTopLeft('/common_files/contracts/view_contract_payment_history.cfm?ContractId=<cfoutput>#cryp.value#</cfoutput>&approval=1','paymenthistorywindow','1150','620','Yes', 'Yes');
	}
	else
	{
	opener.NewWindowTopLeft('/clause_library/clause_approval.cfm?CID=<cfoutput>#URL.CID#</cfoutput>','name','1500','925','Yes', 'Yes');
	}
	<cfelse>
	opener.NewWindowTopLeft('/clause_library/clause_approval.cfm?CID=<cfoutput>#URL.CID#</cfoutput>','name','1500','925','Yes', 'Yes');
	</cfif>
	window.close();
}

<!--- Dev Note: KAL; D16168: Changes due to note not saving sometimes when reset to WIP from RFA - NO REWRITE as the label says --->
function submitSave(obj)
{
	msg = ValidateForm();
	if (msg.length > 0){
		alert(msg);
	}
	else{
		document.all.EvalForm.submit();
	}
}

function emailNote()
{
	window.open('contract_email_create.cfm?PID=<cfoutput>#URL.CID#</cfoutput>&emailType=BusinessCon','name','880,600,Yes,Yes,resizable=yes');
	window.opener.close();//D28784: Close open window on reset: ADDED Opener close function to close main program window.
	window.close();
}

function ValidateCloseWindow(obj)
{
		EvaluationNotes = trim(document.all.EvaluationNotes.value);
		if (EvaluationNotes.length == 0) {
			window.close();
		}
		else{
			var reply = confirm('Your note will not be saved. Is that OK?');
			if(reply ==1){window.close();}
		}
}
</script>
</body>
</html>