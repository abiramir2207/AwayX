<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfsilent>
<!---

Evaluation Notes:
Modes: URL.Mode Sets the Eval Action of the Form.
0 = Read Only
1 = Agree
2 = Approve
3 = Reset to WIP
4 = Revise after Agreed
5 = RFA
6 = Approval Link clicked on Margin Page
7 = Agree from Old Approval Schemes
8 = Pending ERP Status
9 = Disagree
10 = Approve Negative Billback

--->


<cfparam name = "ParentFormName" default="">
<!--- <cfparam name="reject" default="0"> --->
<cfparam name="mode" default="0">
<cfparam name="edit" default="1">
<cfparam name="editRecord" default="0">
<cfparam name="Action" default="">
<!--- <cfparam name="NoteType" default="1"> --->
<cfparam name="PAGE_TITLE" default="Billback Business Consideration">
<cfparam name="frmWidth" default="">
<cfparam name="ProgramAgree" default="0">
<CFPARAM NAME="FORM.BBID" DEFAULT = "">
<CFPARAM NAME="FORM.FormSubmit" DEFAULT = "0">
<cfparam name="FORM.source" default="" />
<cfparam name="URL.source" default="" />
<cfparam name="FlexAppName" default="">
<cfparam name="URL.parentName" default="" />


<CFIF ISDefined("URL.BBID")>
	<CFSET FORM.BBID = URL.BBID>
</CFIF>

<cfif isdefined("form.mode")>
	<cfset mode = form.mode >
</cfif>

<cfif isdefined("URL.FormName") and URL.FormName NEQ "">
	<cfset ParentFormName = URL.FormName>
</cfif>

<cfif isdefined("URL.FlexAppName") and URL.FlexAppName NEQ "">
	<cfset FlexAppName = URL.FlexAppName>
</cfif>

<!---
<cfif isdefined("form.NoteType")>
	<cfset NoteType = form.NoteType >
</cfif>
 --->


<CFSWITCH expression="#mode#">
	<CFCASE value="1,7" delimiters=",">
		<cfset evalAction = 'AGREE'>
	</CFCASE>
	<CFCASE value="2,10">
		<cfset evalAction = 'APPROVE'>
	</CFCASE>
	<CFCASE value="3">
		<cfset evalAction = 'RESET TO WIP'>
	</CFCASE>
	<CFCASE value="4">
		<cfset evalAction = 'REVISE AFTER AGREED'>
	</CFCASE>
	<CFCASE value="5">
		<cfset evalAction = 'RFA'>
	</CFCASE>
	<CFCASE value="6">
		<cfset evalAction = 'APPROVE ACTION'>
	</CFCASE>
	<CFCASE value="8">
		<cfset evalAction = 'ERP RESEARCH'>
	</CFCASE>
	<CFCASE value="9">
		<cfset evalAction = 'DISAGREE'>
	</CFCASE>
	<CFCASE value="11">
		<cfset evalAction = 'REVERSE'>
	</CFCASE>
	<cfdefaultcase>
		<!--- Mode Not Passed to Template --->
	</cfdefaultcase>
</CFSWITCH>

<cfif mode EQ "0">
	<cfset evalAction = ''>
</cfif>

<!--- <CFINCLUDE TEMPLATE="/get_access_profile.cfm"> --->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<!--- Get Business Considerations Reminder Data --->
<cfinvoke component="components.settings.BusinessConsiderationsReminderBB" method="get" returnvariable="qBizConRemindersBB">
</cfsilent>

<!--- Decrypt Contract ID, Retrieve Contract_Number, and Get Evaluation Notes --->
<cfif isDefined("FORM.BBID")>
	<!--- <cfset useLakebaseForGetBBInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetBBInfo>
	<cftry>
		<cfset GetBBInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#cryp.value#",
				"select" = "contract_number,is_a_revision"
			}), "contract_number,is_a_revision"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBBInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBBInfo>
<cfquery name="GetBBInfo" datasource="#application.datasource#">
		select contract_number,Is_A_Revision from contract_main where contract_main_id = '#cryp.value#'
	</cfquery>
</cfif> --->

	<cfif FORM.FormSubmit EQ 1>
		<cfif trim(form.notes) neq "">
			<!--- When a record is edited, update notes --->
			<cfif editRecord gt 0>
				<cfquery name="editSaveEvaluationNotes" datasource="#application.datasource#">
					UPDATE BB_Business_Consideration
					SET Notes = '#REReplaceNoCase(trim(form.notes),"\r","<br>","ALL")#'
					WHERE BB_Business_Consideration_ID = #editRecord#
				</cfquery>
				<!--- Reset "editRecord" back to 0 as update is complete. --->
				<cfset editRecord = 0>

			<cfelse>
			<cfquery name="postEvaluationNotes" datasource="#application.datasource#">
			/*
			-- DO NOT CHECK FOR DUPLICATE AND INSERT DUPLICATE AS REQUESTED
			IF NOT EXISTS (	select * from BB_Business_Consideration
							where Created_By = '#request.AccessStructure.User_ID#'
							AND Action = '#form.Action#'
							AND Notes = '#REReplaceNoCase(trim(form.notes),"\r","<br>","ALL")#'
							AND Billback_ID = '#form.BBID#')
			BEGIN */
				INSERT INTO BB_Business_Consideration(Billback_ID,Action,Notes,Created_By)
				VALUES('#form.BBID#','#form.Action#','#REReplaceNoCase(trim(form.notes),"\r","<br>","ALL")#','#request.AccessStructure.User_ID#')
			-- END
			</cfquery>
			</cfif>
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
  <cfset strSource            = "" />

  <cfif URL.source NEQ "">
    <cfset strSource = URL.source />
  <cfelseif FORM.source NEQ "">
    <cfset strSource = FORM.source />
  </cfif>

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
    <cfset sortByField = "_Users.Name_First"/>
    <cfset orderBy = "ASC" />
    <cfset sortOrderParamUser = "UD" />
    <cfset imgUser = "<img src='/Images/up_1.gif' border='0' />" />
  <cfelseif isDefined("URL.sortOrderParam") AND URL.sortOrderParam EQ "UD">
    <cfset sortByField = "_Users.Name_First"/>
    <cfset orderBy = "DESC" />
    <cfset sortOrderParamUser = "UA" />
    <cfset imgUser = "<img src='/Images/down_1.gif' border='0' />" />
  <cfelseif isDefined("URL.sortOrderParam") AND URL.sortOrderParam EQ "AA">
    <cfset sortByField = "Action"/>
    <cfset orderBy = "ASC" />
    <cfset sortOrderParamAction = "AD" />
    <cfset imgAction = "<img src='/Images/up_1.gif' border='0' />" />
  <cfelseif isDefined("URL.sortOrderParam") AND URL.sortOrderParam EQ "AD">
    <cfset sortByField = "Action"/>
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
 <cfif isdefined("URL.Action") and URL.Action NEQ "">
	 <cfset sortURL = sortURL & "Action="& URL.Action & "&" />
 </cfif>
 <cfif isdefined("URL.FormName") and URL.FormName NEQ "">
	 <cfset sortURL = sortURL & "FormName="& URL.FormName & "&" />
 </cfif>
 <cfif isDefined("URL.BBID")>
  <cfset sortURL = sortURL & "BBID=" & URL.BBID />
 <cfelseif isDefined("FORM.BBID")>
  <cfset sortURL = sortURL & "BBID=" & FORM.BBID />
 </cfif>
 <cfif (isDefined("URL.source") AND URL.source NEQ "")>
  <cfset sortURL = sortURL & "&source=" & URL.source />
 </cfif>
 <cfif (isDefined("URL.FlexAppName") AND URL.FlexAppName NEQ "")>
  <cfset sortURL = sortURL & "&FlexAppName=" & URL.FlexAppName />
 </cfif>

<!--- Query which gets the details of the record which needs to be updated. --->
<cfif editRecord gt 0>
	<cfset useLakebaseForGetBB_BusiConsi_Edit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_business_consideration")>
<cfif useLakebaseForGetBB_BusiConsi_Edit>
	<cftry>
		<cfset GetBB_BusiConsi_Edit = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_business_consideration", {
				"billback_id" = "eq.#FORM.BBID#",
				"bb_business_consideration_id" = "eq.#editRecord#",
				"select" = "bb_business_consideration_id,notes"
			}), "bb_business_consideration_id,notes"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBB_BusiConsi_Edit = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBB_BusiConsi_Edit>
<cfquery name="GetBB_BusiConsi_Edit" datasource="#application.datasource#">
		SELECT 	BB_Business_Consideration_ID, Notes
		FROM 	BB_Business_Consideration
		WHERE 	Billback_ID = '#FORM.BBID#'
		AND BB_Business_Consideration_ID = #editRecord#
	</cfquery>
</cfif>
</cfif>
 <!--- Query which gets all the records. --->
	<cfquery name="GetBB_BusiConsi" datasource="#application.datasource#">
		SELECT BB_Business_Consideration_ID,Billback_ID,Notes,_Users.Name_First,
		_Users.Name_Last,Created_By,Created_Date,Action
		FROM 	BB_Business_Consideration
		INNER JOIN _Users ON _Users.User_ID = BB_Business_Consideration.Created_By
		WHERE 	Billback_ID = '#FORM.BBID#'
		ORDER BY #sortByField# #orderBy#
	</cfquery>

	<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js">

	<!---TSF - Label 11198: Don't display Business considerations if the application setting is on and there aren't any.--->
 	<cfif not GetBB_BusiConsi.RecordCount and appSettings.getSuppressBillbackBusinessConsiderations() and mode neq 0>
		<script>
			<cfif isdefined("ParentFormname") and ParentFormname NEQ "">
					<cfif edit eq 0>
							<cfif mode eq 2>
									window.opener.parent.bb_force_deviation = 1;
									callfireEvent(window.opener.parent.document,window.opener.parent.deviations_tab,'Click');
									window.opener.parent.bb_force_deviation = 0;
							<cfelseif mode eq 10>
									opener.location='/billbacks/capture/Approve_Negative_BB.cfm?BBID=<cfoutput>#form.BBID#</cfoutput>';
							</cfif>
							window.opener.disableApproveLink();
					<cfelse>
							<cfif (mode eq 9)>
									opener.location='/billbacks/common/BB_Reset2.cfm?Billback_ID=<cfoutput>#form.BBID#</cfoutput>&resetBillback=1&IsBillbackApproved=0&Disagree=1';
									window.opener.DisableDisagreeLink();
							<cfelseif (mode eq 3)>
									opener.location='/billbacks/common/BB_Reset2.cfm?Billback_ID=<cfoutput>#form.BBID#</cfoutput>&resetBillback=1&IsBillbackApproved=0&Disagree=0';
									window.opener.DisableDisagreeLink();
							<cfelse>
									opener.document.all.<CFOUTPUT>#ParentFormname#</CFOUTPUT>.submit();
							</cfif>
					</cfif>
			<!--- D43217 :: Disagreed to BB 1000978 and status did not change to WIP --->
			<cfelse>
				<CFOUTPUT>
							<cfif (mode eq 9)>
									<cfset Disagree=1>
							<cfelseif (mode eq 3)>
									<cfset Disagree= 0>
							</cfif>
							opener.location='/billbacks/common/BB_Reset2.cfm?Billback_ID=#form.BBID#&resetBillback=1&IsBillbackApproved=0&Disagree=#Disagree#';
				</CFOUTPUT>
			<!--- D43217 :: Disagreed to BB 1000978 and status did not change to WIP --->
			</cfif>
			window.close();
		</script>
	</cfif>
</cfif>

<html>
<head>
	<title><cfoutput>#PAGE_TITLE#</cfoutput></title>
	<style type="text/css">
		div#msg55 p { font-size: 1.35em; margin:20px; padding:20px; background-color: #BDE5F8; letter-spacing:0.9px; }
		table {
				margin-right:10px;
				border-collapse:collapse;
				width:<cfoutput>#frmwidth#</cfoutput>;
				margin:0 auto;
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
		textarea { width:95%;
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
	<cfoutput>
	<script type="text/javascript" language="JavaScript">
	function ValidateForm()
	{
		
		//Notes = document.all.notes.value;
		// chromefix WR 56811 - Chrome / Billbacks / Edit business considerations 
		Notes = jQuery( "textarea[name=notes]" ).val()
		/* D112175 Required Note Pop-up in BB Business Considerations /Anand Rao/ 10-Dec-2021 
			-- commented out as the user has nothing to save, so close the BB consideration window
		*/
		 if (Notes.length == 0)
		{
			// alert("The submitted note is blank. Please enter a valid note.");
			window.close();
			return true;
		}		else  
		if (Notes.length > 4000)
		{
			alert("The submitted note exceeds the size limit. Please revise the note.");
			return false;
		}
		else
			//<!--- document.all.EvalForm.action = "evaluationnotes.cfm?CID=#URL.CID# "; --->
			document.all.BBBusiConsiForm.submit();
			return true;
	}

	function continueapproval(){
		window.opener.parent.bb_force_deviation = 1;
		window.opener.disableApproveLink();
		callfireEvent(window.opener.parent.document,window.opener.parent.deviations_tab,'Click');

		window.opener.parent.bb_force_deviation = 0;
		window.close();
	}

	function showProcessingMessage() {
		$('form[name=BBBusiConsiForm], table').hide();
		$("##msg55").append("<p>Processing changes, please wait...</p>");
	}
	function VerifyDisagree(mode)
	{
		if(window.confirm("This billback will be reset to work in progress.\n\nDo you want to proceed?") == 0)
		{
			return false;
		}
		else
		{
			showProcessingMessage();

			document.all.BBBusiConsiForm.submit();
			if (mode == 9)
			{
				opener.location='/billbacks/common/BB_Reset2.cfm?Billback_ID=<cfoutput>#BBID#&parentName=#url.parentName#</cfoutput>&resetBillback=1&IsBillbackApproved=0&Disagree=1';
			}
			else
			{
				opener.location='/billbacks/common/BB_Reset2.cfm?Billback_ID=<cfoutput>#BBID#&parentName=#url.parentName#</cfoutput>&resetBillback=1&IsBillbackApproved=0&Disagree=0';
			}
			/* If the function "DisableDisagreeLink" exists on the opener page. */
			if (typeof window.opener.DisableDisagreeLink == 'function') {
				window.opener.DisableDisagreeLink();
			}
			window.close();
		}
	}

	function VerifyDisagreeFlex(paramSource,mode)
	{
		if (paramSource == 'flexBB' || paramSource == 'FlexBB' || paramSource == 'AgGridBB' || paramSource == 'BBSettlement'){
        	if(window.confirm("This billback will be reset to work in progress.\n\nDo you want to proceed?") == 0){
				// Dev Note: Kal: 30645 - Disagree in deviation screen should reset BB to WIP : Call from the Flex App
				// When called from Flex BB Edit this page is a pop-up so close it, if cancelled.
				// window.location = "/flex/Billback/BillbackDevAppFX.cfm?bbid=#URL.BBID#&userID=#request.AccessStructure.User_ID#&source=#strSource#&caller=#strSource#";
				window.close();
    		}
    		else
    		{
				showProcessingMessage();
    			document.all.BBBusiConsiForm.submit();
    			// redirect to the Flex BB Screen;  &IsBillbackApproved=0
				if (mode == 9){
					window.location='/billbacks/common/BB_Reset2.cfm?Billback_ID=#BBID#&resetBillback=1&Disagree=1&FromFlex=1&FlexAppName=#FlexAppName#&parentName=#url.parentName#&paramSource=' + paramSource;
				}
				else{
					window.location='/billbacks/common/BB_Reset2.cfm?Billback_ID=#BBID#&resetBillback=1&Disagree=0&FromFlex=1&FlexAppName=#FlexAppName#&parentName=#url.parentName#&paramSource=' + paramSource;
				}
    	}
      }
		else if(paramSource == 'BBFlexScoreCard' || paramSource == 'BBAgGridScoreCard')
		{
			if(window.confirm("This billback will be reset to work in progress.\n\nDo you want to proceed?") == 0)
			{
				<cfif appSettings.get_Setting('BB_Deviation_Format') contains 'CF'>
				window.location = "/billbacks/Deviation/Deviation_Main.cfm?bbid=#URL.BBID#&source=#strSource#&caller=#strSource#";
				<cfelse>
				 window.location = "/flex/Billback/BillbackDevAppFX.cfm?bbid=#URL.BBID#&userID=#request.AccessStructure.User_ID#&source=#strSource#&caller=#strSource#";
				</cfif>
			}
			else
			{
				showProcessingMessage();
			    document.all.BBBusiConsiForm.submit();
				window.location='/billbacks/common/BB_Reset2.cfm?Billback_ID=#BBID#&resetBillback=1&Disagree=1';
			}
		}
	}

  function fnSortSubmit(actionURL)
  {
    document.all.BBBusiConsiForm.action = actionURL;
    document.all.BBBusiConsiForm.submit();
  }

	function Go_To_Negative_BB_Approval_Page()
	{
		opener.location='/billbacks/capture/Approve_Negative_BB.cfm?BBID=<cfoutput>#BBID#</cfoutput>'
		window.close();
	}

	function closeWindow()
	{
	//if (document.all.notes.value != "")
	// chromefix WR 56811 - Chrome / Billbacks / Edit business considerations 
	if (jQuery( "textarea[name=notes]" ).val() != "")
	var reply = confirm("This action will not save your notes.");if(reply ==1){window.close();}
	else
	window.close();
	}
	</script>
	</cfoutput>
</head>
<body>

<p align="left" class="header" style="display:inline"><cfoutput>#PAGE_TITLE#</cfoutput>:</p>
	<CFIF qBizConRemindersBB.RecordCount GT 0>
	<cfif qBizConRemindersBB.business_considerations_reminders_on>
		<HR><div class="heading" align="left">
			 <cfoutput>
			 	<span style="font-size:10pt;font-style:italic;"><b>Reminders:<b></span>
				#qBizConRemindersBB.business_considerations_reminders_txt#
			</cfoutput>
		</div>
	</cfif>
	</CFIF>
	<HR>


<cfif edit EQ 1>
<cfoutput>
	<div id="msg55"></div>
	<form name="BBBusiConsiForm" method="Post" action="BB_Business_Consideration.cfm?BBID=#FORM.BBID#">
	<table width="#frmWidth#" border="1">
	  <tr><th width="700px">ADD NOTE</th></tr>
	<tr><td width="700px"><b>ACTION:</b> #UCASE(Action)#</td></tr>
	<tr><td width="700px"><b>NOTES:</b><br>
	<textarea id="Notes" name="notes" width="#frmWidth#"><cfif editRecord gt 0>#trim(GetBB_BusiConsi_Edit.Notes)#</cfif></textarea>
	</td></tr>
	<tr>
		<td width="80%" align="center">
	
		<table width="80%" align="Center"><tr>
		<td  width="50%" align="center">
			<span style="font-weight:bold;color:red"> [ </span> <a href="##" OnClick="javascript:ValidateForm();return false">save note</a>	<span style="font-weight:bold;color:red"> ] </span>
		</td>
	
		<cfif mode EQ 8 OR mode EQ 4 or mode EQ 0>
			<td width="50%" align="center">&nbsp;&nbsp;&nbsp;&nbsp;
			<span style="font-weight:bold;color:red"> [ </span>
			<a href="##" OnClick="javascript:closeWindow()">close window</a>
			<span style="font-weight:bold;color:red"> ] </span>
			</td>
		<cfelse>
			<cfif mode EQ 1 or mode EQ 5 or mode EQ 3 or mode EQ 2 or mode EQ 8 or mode EQ 9 or mode eq 10>
				<td  width="50%" align="center">
					&nbsp;&nbsp;&nbsp;&nbsp;
					<span style="font-weight:bold;color:red"> [ </span>
						<cfif ((mode eq 9 AND strSource EQ "") OR (mode eq 3 AND strSource EQ ""))>
							<a href="##" OnClick="javascript:VerifyDisagree(<cfoutput>#mode#</cfoutput>);" id="lnkSubmit" title="Continue with '#evalAction#' and Close">close window<!--- save/continue ---></a>
						<cfelseif ((mode EQ 9 AND strSource NEQ "") OR (mode eq 3 AND strSource NEQ ""))>
							<a href="##" OnClick="javascript:VerifyDisagreeFlex('<cfoutput>#strSource#</cfoutput>',<cfoutput>#mode#</cfoutput>);" id="lnkSubmit" title="Continue with '#evalAction#' and Close">close window<!--- save/continue ---></a>
						<cfelse>
							<cfif FORM.formSubmit EQ 0>
								<a href="##" OnClick="javascript:submitform();" id="lnkSubmit">save/continue</a>
							<cfelse>
								<a href="##" OnClick="javascript:window.close();">close window</a>
							</cfif>
						</cfif>
					<span style="font-weight:bold;color:red"> ] </span>
				</td>
			</cfif>
			<!---
			<cfif mode EQ 2>
				<td  width="50%" align="center">
					&nbsp;&nbsp;&nbsp;&nbsp;
					<span style="font-weight:bold;color:red"> [ </span>
					<a href="##" OnClick="javascript:submitform();">continue</a>
					<span style="font-weight:bold;color:red"> ] </span>
				</td>
			</cfif>
			--->
		</cfif>
	
		</tr></table>
	
		<input type="hidden" name="FormSubmit" value="1">
		<input type="hidden" name="Action" value="#evalaction#">
		<input type="hidden" name="mode" value="#mode#">
		<input type="hidden" name="ParentFormName" value="#ParentFormName#">
		<input type="hidden" name="source" value="#strSource#" />
		<input type="hidden" name="FlexAppName" value="#FlexAppName#" />
		<input type="hidden" name="editRecord" value="#editRecord#">
	
		</td>
	</tr>

</table>
	</form>
</cfoutput>
</cfif>

<table width="#frmWidth#" border="1">
<tr>
  <cfoutput>
    <cfif (strSource EQ "" AND edit EQ 0)>
      <th width="90px">
        <a href="#sortURL#&sortOrderParam=#sortOrderParamDate#">DATE #imgDate#</a>
      </th>
      <th width="120px">
        <a href="#sortURL#&sortOrderParam=#sortOrderParamUser#">USERNAME #imgUser#</a><!--- sortURL#&sortOrderParam=#sortOrderParamUser --->
      </th>
      <th width="90px">
        <a href="#sortURL#&sortOrderParam=#sortOrderParamAction#">ACTION #imgAction#</a>
       </th>
      <th width="450px">
        <a href="#sortURL#&sortOrderParam=#sortOrderParamNotes#">NOTES #imgNotes#</a>
      </th>
    <cfelse>
      <th width="90px">
        <a href="##" onClick="javascript:fnSortSubmit('#sortURL#&sortOrderParam=#sortOrderParamDate#');">DATE #imgDate#</a>
      </th>
      <th width="120px">
        <a href="##" onClick="javascript:fnSortSubmit('#sortURL#&sortOrderParam=#sortOrderParamUser#');">USERNAME #imgUser#</a><!--- sortURL#&sortOrderParam=#sortOrderParamUser --->
      </th>
      <th width="90px">
        <a href="##" onClick="javascript:fnSortSubmit('#sortURL#&sortOrderParam=#sortOrderParamAction#');">ACTION #imgAction#</a>
       </th>
      <th width="450px" colspan="2">
        <a href="##"onClick="javascript:fnSortSubmit('#sortURL#&sortOrderParam=#sortOrderParamNotes#');">NOTES #imgNotes#</a>
      </th>
  </cfif>

  </cfoutput>
  </tr>
<cfif GetBB_BusiConsi.RecordCount GT 0>
<cfoutput query="GetBB_BusiConsi">
<tr><td width="90px">#DateFormat(GetBB_BusiConsi.Created_Date,'MM/DD/YYYY')#</td>
	<td width="120px">#GetBB_BusiConsi.Name_First# #GetBB_BusiConsi.Name_Last#</td>
	<td width="90px">#GetBB_BusiConsi.Action#</td>
	<td width="450px">#trim(GetBB_BusiConsi.Notes)#</td>
	<!--- Edit one's own business consideration. --->
	<cfif edit eq 1><td width="30px"><cfif GetBB_BusiConsi.Created_By eq request.accessStructure.User_ID><a href="BB_Business_Consideration.cfm?BBID=#FORM.BBID#&edit=1&editRecord=#GetBB_BusiConsi.BB_Business_Consideration_ID#">edit</a></cfif></td></cfif></tr>
</cfoutput>
<cfelse>
<tr><td colspan="4" class="norecords" align="center">No Matching Records Found</td></tr>
</cfif>
<cfif edit EQ 0>
	<tr><td colspan="4" align="center">
		<span style="font-weight:bold;color:red"> [ </span> <a href="##" OnClick="javascript:window.close();">close window</a>  <span style="font-weight:bold;color:red"> ] </span>
			<cfif mode EQ 2 OR mode EQ 10>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<span style="font-weight:bold;color:red"> [ </span> <cfif mode eq 2><a href="#" OnClick="javascript:continueapproval();return false">continue</a> <cfelseif mode eq 10><a href="#" OnClick="javascript:Go_To_Negative_BB_Approval_Page();return false">continue</a></cfif>  <span style="font-weight:bold;color:red"> ] </span>
			</cfif>
	</td></tr>
</cfif>
</table>

<cfinclude template="/common_files/jQuery.cfm">

<script>


function submitform()
{
	//disable link
	var lnk = document.getElementById('lnkSubmit');
		//lnk.onclick = null;
	    //do other stuff when a click happens
		ValidateForm();	
	 <cfif isdefined("ParentFormname") and ParentFormname NEQ "">
		if(opener.disablePageLinks)//if this function exists in the parent page it will get called, should exist in approval/payment.cfm file
		{
			opener.disablePageLinks();
		}
		opener.document.all.<CFOUTPUT>#ParentFormname#</CFOUTPUT>.submit();
	</cfif>
	// document.all.BBBusiConsiForm.submit();	
	//window.close();
}
function noSubmit(){
	alert('second');
}

</script>
</body>
</html>
