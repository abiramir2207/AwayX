<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\email_contacts.cfm
      Date:     June 15, 2016
      Author:   Milan Mushran
      Purpose:  Emailing external contacts.
	 NOTE: This code was copied from contacts.cfm and then modified.
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>Contacts</title>
<link rel="stylesheet" type="text/css" href="/common_files/main_style.css">
<link rel="stylesheet" type="text/css" href="/common_files/dataTable.css">
<cfinclude template="/common_files/jQuery.cfm">
<style>
.label {
  font-size: 9pt;
  font-weight: bold;
  color: navy;
}
.label2 {
  font-size: 8pt;
  font-weight: bold;
}
</style>
</head>
<body>
<CF_MessageWindow>

<!--- Below line of code is for testing only. If a query is changed on "LetterManager.cfc", then uncomment below code.
Before code deployment, comment below line again.
--->
<!---<cfset StructDelete(application,"oLetterManager")>--->

<cfscript>
	application.oController.getObject("mvc.Models.LetterManager");
</cfscript>

<cfset app_general_functions = CreateObject("component","components.general.General_Functions") />
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init()/>
<cfset appSettings = genSettingsManager.get()>

<cfparam name="URL.letter_ID" default="">
<cfparam name="program_id_list" default="">
<cfparam name="contractID" default="">
<cfparam name="reportType" default="">
<cfparam name="form.paidToList" default="">
<cfparam name="form.paid_to" default="">

<!--- Combine gets and posts into the request scope --->
<cfif isDefined("URL")>
  <cfset structAppend(request, URL, true)/>
</cfif>
<cfif isDefined("FORM")>
  <cfset structAppend(request, form, true)/>
</cfif>

<cfscript>
  main = StructNew();
  main.messageMaxLen = 1000;
  request.debug = false;
</cfscript>

<!---post back logic starts here--->
<cfif cgi.request_method eq "post" and StructKeyExists(request, "internals")>
	<cfset main.distributors = "">
	<cfset main.operators    = "">

	<!--- get distributorID/operatorID and their email addresses --->
	<cfloop collection="#form#" item="formItem">
		<!---ignore empty form items--->
		<cfif Len(form[formItem])>
			<!---combine all distributor checkboxes--->
			<cfif FindNocase("distributors", formItem) eq 1>
				<cfset main.distributors = main.distributors & form[formItem] & ",">
			</cfif>

			<!---combine all operator checkboxes--->
			<cfif FindNocase("operators", formItem) eq 1>
				<cfset main.operators = main.operators & form[formItem] & ",">
			</cfif>
		</cfif>
	</cfloop>

	<!--- (START) - EMAILING PROGRAM LETTERS --->
	<cfif reportType eq "ProgramLetters">
		<cfloop list="#url.letter_id#" index="letterID">
			<cfset variables.qGetLetterInfo = application.oLetterManager.getAllLetterInfo(letterID)>
			<cfinclude template="letters\email_letters.cfm">
		</cfloop>

		<H4>
		<cfoutput>
		<cfif url.letter_id neq "">
			<span style="font-size:12px;font-weight:bold;">
				<cfif listLen(url.letter_id, ',') GT 1>
					#listLen(url.letter_id,',')# letters emailed to selected recipients.
				<cfelse>
					#listLen(url.letter_id,',')# letter emailed to selected recipients.
				</cfif>
			</span>

			<br /><br />
		</cfif>
		</cfoutput>
		</H4>
	</cfif>
	<!--- (END) - EMAILING PROGRAM LETTERS --->

	<!--- (START) - EMAILING CLAIM RATES --->
	<!--- Dev Note: 69439 - When user wants to email just claim rates report OR claim rates report AND program letter in one email.
	In this case reportType is "ProgramClaimRatesReportAndLetters".
	Note: These are the steps:
	- User creates a "claim rate" report for a distributor.
	- User clicks on a link called "email cmail rates and letters".
	- User will only see the letter generated for that distributor
	- User wull select the letter and click on "email aditional contacts"
	- User will select the email id of the distributor and send the email.
	--->
	<cfif ListFindNoCase(reportType,'ProgramClaimRatesReport') OR ListFindNoCase(reportType,'ProgramClaimRatesReportAndLetters')>
		<cfinclude template="\ReportWriter\email_program_claim_rates.cfm">

		<H4>
			<span style="font-size:12px;font-weight:bold;">
				<cfif ListFindNoCase(reportType,'ProgramClaimRatesReportAndLetters')>
				claim rates document and letter emailed to selected recipients.
				<cfelse>
				claim rates document emailed to selected recipients.
				</cfif>
			</span>

			<br /><br />
		</H4>
	</cfif>
	<!--- (END) - EMAILING CLAIM RATES --->

	<cfoutput>
	<a href="javascript:window.close()">#application.util.string.actionLinkFormat("close window")#</a>
	</cfoutput>

	<cfabort>
</cfif>

<!--- If the request is from "claim rates" --->
<cfif IsDefined("request.program_id_list")>
	<cfset request.contractID = app_general_functions.listRemoveDupes(request.program_id_list,",")>
</cfif>

<cfset programIDList = app_general_functions.listRemoveDupes(program_id_list,",")>

<cfif reportType eq "ProgramLetters" OR ((ListFindNoCase(reportType,'ProgramClaimRatesReport') OR ListFindNoCase(reportType,'ProgramClaimRatesReportAndLetters')) AND Listlen(programIDList) eq 1)>
	<!---retrieve existing contacts--->
	<cfquery name="contacts" datasource="#application.datasource#">
		SELECT	CM.Contract_Number
				,CM.Contract_Title
				,Right(CM.Contract_Number, 7) as Partial_Contract_Number
				,CASE
									WHEN LEN(CM.revision_version) = 4 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 4)
									WHEN LEN(CM.revision_version) = 5 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 5)
									ELSE RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 3)
								END as Revision_Version
		FROM		Contract_Main CM
		WHERE	CM.Contract_Main_ID	=	<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.contractID#">
	</cfquery>

	<!---if no record is returned (this should not happen) bail out--->
	<cfif contacts.recordCount eq 0>
	  <cfabort>
	</cfif>
</cfif>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init()>
<cfset appSettings = genSettingsManager.get()>


<cfquery name="rsDistributors" datasource="#application.datasource#">
	if object_id('tempdb..##claimReportDistributors') is not null
	drop table ##claimReportDistributors

	create table ##claimReportDistributors (bsa_FoodService_Customers_Id uniqueIdentifier)

	<cfif ListFindNoCase(reportType,'ProgramClaimRatesReport') OR ListFindNoCase(reportType,'ProgramClaimRatesReportAndLetters')>
		<cfif form.paid_to eq "Distributor">
			<cfloop list="#form.paidToList#" index="distid">
				insert into ##claimReportDistributors (bsa_FoodService_Customers_Id) values ('#distid#')
			</cfloop>
		</cfif>
	</cfif>

<!---find distributor emails--->
  SELECT DISTINCT ec.Company_Code
			, cd.bsa_FoodService_Customers_Id
			, ec.eMail
			, ec.Last_Name
			, ec.First_Name
			, ec.Title
			, ec.Company_Name
	FROM <cfif reportType eq "ProgramLetters">
		Contract_Main cm
		INNER JOIN Contract_Distributors cd ON cm.Contract_Main_Id = cd.Contract_Main_Id
			AND cd.Deleted = 0
		<cfelseif ListFindNoCase(reportType,'ProgramClaimRatesReport') OR ListFindNoCase(reportType,'ProgramClaimRatesReportAndLetters')>
		##claimReportDistributors cd
		</cfif>
		INNER JOIN bsa_FoodService_Customers bfc ON bfc.bsa_FoodService_Customers_Id = cd.bsa_FoodService_Customers_Id
		INNER JOIN External_Contacts ec ON ec.Company_Code = bfc.Shr_Ship_To
			AND ec.Deleted = 0
			 AND ec.eMail > ''
		<cfif reportType eq "ProgramLetters">
		WHERE cm.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.contractID#">
		</cfif>
		<!---28345 do not select any rows when ext contact setting is not enabled--->
		<cfif appSettings.External_Contacts_Option eq 0> AND 0 = 1 </cfif>
	ORDER BY ec.First_Name, ec.Last_Name
</cfquery>


<cfquery name="rsOperators" datasource="#application.datasource#">
	if object_id('tempdb..##claimReportOperators') is not null
	drop table ##claimReportOperators

	create table ##claimReportOperators (bsa_operator_Id int)

	<cfif ListFindNoCase(reportType,'ProgramClaimRatesReport') OR ListFindNoCase(reportType,'ProgramClaimRatesReportAndLetters')>
		<cfif form.paid_to eq "Operator">
			<cfloop list="#form.paidToList#" index="oprID">
				insert into ##claimReportOperators (bsa_operator_Id) values ('#oprID#')
			</cfloop>
		</cfif>
	</cfif>

<!---find operator emails--->
  SELECT DISTINCT ec.Company_Code
			, co.bsa_Operator_Id
			, ec.eMail
			, ec.Last_Name
			, ec.First_Name
			, ec.Title
			, ec.Company_Name
	FROM
		<cfif reportType eq "ProgramLetters">
		Contract_Main cm
		INNER JOIN Contract_Operators co ON cm.Contract_Main_Id = co.Contract_Main_Id
			AND co.Deleted = 0
		<cfelseif ListFindNoCase(reportType,'ProgramClaimRatesReport') OR ListFindNoCase(reportType,'ProgramClaimRatesReportAndLetters')>
		##claimReportOperators co
		</cfif>
		INNER JOIN bsa_Operator bo ON bo.bsa_Operator_Id = co.bsa_Operator_Id
		INNER JOIN External_Contacts ec ON ec.Company_Code = COALESCE( Cast( bo.Legacy_Id AS VARCHAR( 50 )), Cast( bo.bsa_Operator_Id AS VARCHAR( 50 )) )
			AND ec.Deleted = 0
			AND ec.eMail > ''
		<cfif reportType eq "ProgramLetters">
		WHERE cm.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.contractID#">
		</cfif>
		<!---28345 do not select any rows when ext contact setting is not enabled--->
		<cfif appSettings.External_Contacts_Option eq 0> AND 0 = 1 </cfif>
	ORDER BY ec.First_Name, ec.Last_Name
</cfquery>

<cfoutput>
<SPAN CLASS="title2">Contacts:</SPAN>
<hr align=left color=blue size=1>
<cfif reportType eq "ProgramLetters" OR ((ListFindNoCase(reportType,'ProgramClaimRatesReport') OR ListFindNoCase(reportType,'ProgramClaimRatesReportAndLetters')) AND Listlen(programIDList) eq 1)>
<table border=0 cellspacing=0 cellpadding=0 width=100%>
  <tr bgColor=##ffce84>
    <td noWrap align=left><FONT size=2>&nbsp;Program Number: <B>#contacts.Contract_Number#</B></FONT></td>
    <td noWrap align=right><FONT size=2>Description: <B>#contacts.Contract_Title#</B></FONT>&nbsp;</td>
  </tr>
</table>
</cfif>
<!---display the form--->
<form name="contacts" method="post">
<input type="hidden" name="Contract_Main_ID" value="#request.ContractID#">
<input type="hidden" name="mode" value="#request.mode#">
<input type="hidden" name="reportType" value="#reportType#">

<!--- If custom letter (Custom 1) app setting is ON --->
<!--- If there is only 1 letter (while emailing program letter) OR if the report type to email is "Claim rates report" for 1 program only. --->
<cfif appSettings.getlettersavailable() eq 2 AND ((reportType eq "ProgramLetters" AND listlen(url.letter_id) eq 1) OR ((ListFindNoCase(reportType,'ProgramClaimRatesReport') OR ListFindNoCase(reportType,'ProgramClaimRatesReportAndLetters')) AND Listlen(programIDList) eq 1))>
	<!--- If there is only 1 letter, get the "created_Date" of the letter as we need that
	as a part of the "subject". Having more than one letter may result in multiple "created_date".
	--->
	<cfif reportType eq "ProgramLetters" AND listlen(url.letter_id) eq 1>
		<cfquery name="qryLetters" datasource="#application.datasource#">
		SELECT	PL.Created_Date
		FROM		Program_Letters PL
		WHERE PL.Program_letters_ID =	<cfqueryparam cfsqltype="cf_sql_integer" value="#url.letter_id#">
		</cfquery>
		<cfset date_created = qryLetters.Created_Date>

	<!--- Since we do not save claim rates report details in the db, use "current date". --->
	<!--- If there is only 1 program,use the "current date" as we need that
	as a part of the "subject". Having more than one program will result in multiple "created_date".
	--->
	<cfelseif (ListFindNoCase(reportType,'ProgramClaimRatesReport') OR ListFindNoCase(reportType,'ProgramClaimRatesReportAndLetters')) AND Listlen(programIDList) eq 1>
		<cfset date_created = now()>
	</cfif>

		<cfset SubjectPrefix = "">
		<cfset subject = "">
		<!--- If custom letter (Custom 1) app setting is ON --->
		<cfif appSettings.getlettersavailable() eq 2>
			<cfset SubjectPrefix = "General Mills" & " ">
		<!---
		Letter Subject format:
		1000306 001[2 spaces] Program Title [2 spaces] Date/Timestamp
		--->
		<cfset subject =
				#SubjectPrefix# & contacts.Partial_Contract_Number
				& " "
				& contacts.Revision_Version
				& "  "
				& contacts.Contract_Title
				& "  "
				& dateformat(date_created,"mm_dd_yyyy")
				& "_"
				& timeformat(date_created,"hh_mm_sstt") />
		</cfif>
</cfif>

<!---25704 - 2011-mar-15 added ext. contacts--->
<cfscript>
  // set readonly attribute based on the passing edit parameter
  if ( request.mode eq "view" )
    main.readonly = true;
  else
    main.readonly = false;
</cfscript>
<div style="margin:20 0 10 35">
<!--- If there is only 1 letter (while emaling program letter) OR if the report type to email is "Claim rates report", where the report is created for one program only. --->
<cfif appSettings.getlettersavailable() eq 2 AND ((reportType eq "ProgramLetters" AND listlen(url.letter_id) eq 1) OR ((ListFindNoCase(reportType,'ProgramClaimRatesReport') OR ListFindNoCase(reportType,'ProgramClaimRatesReportAndLetters')) AND Listlen(programIDList) eq 1))>
<span class="label">Subject:</span><br/><input type="text" name="SenderSubject" id="SenderSubject"  value="#Subject#" size="105" <cfif main.readonly>readonly="readonly"</cfif>> <br/>
<cfelse>
	<cfif ListFindNoCase(reportType,'ProgramClaimRatesReport') OR ListFindNoCase(reportType,'ProgramClaimRatesReportAndLetters')>
		<input type="hidden" name="SenderSubject" value="#Subject#">
	</cfif>
</cfif>
<span class="label">Email Message:</span><br/><textarea id="emailmessage" name="emailmessage" <cfif main.readonly>readonly="readonly"</cfif> cols=107 rows=5></textarea><br/>
</cfoutput>
<cf_emailRecipient
          intEmails_name  = "internals"
          <!---intEmails_value = #main.internals#--->
          intEmails_size  = "rows=7 cols=107"
          intEmails_label = '<span class="label">Internal Recipients:</span><font color="red"><br/><i>Type at least 2 letters to see suggestions for email addresses for users of the application. Use up/down <br/>arrow to browse, enter to select. Then continue typing to add more. Separating them with a semi-colon (;)</i></font>'
          include         = "internal"
          include_jQuery  = false
          readonly        = #main.readonly#
          >

<!--- (Start) - This is used for "claim rates". --->
<cfif ListFindNoCase(reportType,'ProgramClaimRatesReport') OR ListFindNoCase(reportType,'ProgramClaimRatesReportAndLetters')>
<cfoutput>
	<cfif StructKeyExists(form, 'clause')>
		<cfif form.clause neq "<pre></pre>">
			<div class="title2" style="margin-top:10px;">Clause</div>
			<hr color="orange">
			#replaceNoCase(replaceNoCase(form.clause,'<pre>',''),'</pre>','')#
			<input type="hidden" name="clause" value="#HTMLCodeFormat(form.clause)#">
		</cfif>
	</cfif>
		<input type="hidden" name="Attachments" value="#Attachments#">
		<input type="hidden" name="Program_ID_List" value="#Program_ID_List#">
		<input type="hidden" name="SenderAddress" value="#request.accessstructure.name_first# #request.accessstructure.name_last# <#request.accessstructure.user_email#>">
		<input type="hidden" name="SenderDate" value="#dateformat(now(), 'mmmmm d, yyyy')#">
</cfoutput>
</cfif>
<!--- (End) - This is used for "claim rates". --->

<!---list distributors out when they exist --->
<cfif rsDistributors.recordCount>
  <div style="clear:both;margin:10 0 0 35">
  <div style="margin:0 0 7 0">
  <span class="label">Distributor Recipients:</span>
  <cfif main.readonly eq false>
    <span class="label2" style="margin-left:16px;"><input type="checkbox" id="alldistributors" OnClick="process_all('alldistributors', '.distributors')"> All distributor recipients</span>
  </cfif>
  </div>
  <cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [1, 3, 3, 3] )>
  <table class="recipients datagrid" style="table-layout:fixed;">
    <cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
      <cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
    </cfloop>
    <thead>
    <tr>
        <th>Check</th>
        <th>Name</th>
        <th>Company</th>
        <th>Title</th>
        <th>Email</th>
    </tr>
    </thead>
    <tbody>
    <cfoutput query="rsDistributors">
    <!---get checkbox value when it is checked--->
    <cfset main.recipientValue = RecipientVal(rsDistributors.Bsa_Foodservice_Customers_Id, rsDistributors.email)>
    <!---display checkbox & recipient info, checkbox name begins with 'distributors' & ends with current row number--->
    <tr>
      <td><input type="checkbox" name="distributors#rsDistributors.currentRow#" value="#main.recipientValue#"<cfif main.readonly>disabled</cfif> class="distributors"/></td>
      <td>#rsDistributors.first_name# #rsDistributors.last_name#</td>
      <td>#Left(Company_Name,40)#..</td>
      <td>#rsDistributors.title#</td>
      <td>#rsDistributors.email#</td>
    </tr></cfoutput>
    </tbody>
  </table>
  </div>
</cfif>

<!---list operators out when they exist --->
<cfif rsOperators.recordCount>
  <div style="margin:15 0 0 35">
    <div style="margin:0 0 7 0"><span class="label">Operator Recipients</span>
      <cfif main.readonly eq false>
        <span class="label2" style="margin-left:16px;"><input type="checkbox" name="alloperators" id="alloperators" onclick="process_all('alloperators', '.operators')"> All operator recipients</span>
      </cfif>
    </div>
  <cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [1, 3, 3, 3] )>
  <table class="recipients datagrid" style="table-layout:fixed;">
    <cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
      <cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
    </cfloop>
    <thead>
    <tr>
        <th>Check</th>
        <th>Name</th>
        <th>Company</th>
        <th>Title</th>
        <th>Email</th>
    </tr>
    </thead>
    <tbody>
    <cfoutput query="rsOperators">
    <!---get checkbox value when it is checked--->
    <cfset main.recipientValue = RecipientVal(rsOperators.Bsa_Operator_Id, rsOperators.email)>
    <!---display checkbox & recipient info, checkbox name begins with 'operators' & ends with current row number--->
    <tr>
      <td><input type="checkbox" name="operators#rsOperators.currentRow#" value="#main.recipientValue#" <cfif main.readonly>disabled</cfif> class="operators"/></td>
      <td>#rsOperators.first_name# #rsOperators.last_name#</td>
      <td>#Left(Company_Name,40)#..</td>
      <td>#rsOperators.title#</td>
      <td>#rsOperators.email#</td>
    </tr></cfoutput>
    </tbody>
  </table>
  </div>
</cfif>

<table style="margin:15 0 0 40" cellpadding="10">
	<tr>
	  <!---show save option if operating mode is not view--->
	  <cfif request.mode neq "view">
  		<td>
 	      <cfset button_caption = "send email">
  			<CF_button
  				button_name		=	"send_email"
  				button_caption=	#button_caption#
  				button_action	=	"send_email();"
  				button_type		=	"javascript_link"
  				button_width	=	"150"
  				button_color	=	"Navy"
  				button_tip		=	"Click here to send email..."
  				font_color		=	"White"
  				font_size		  =	"12"
  				font_weight		=	"bold">
  		</td>
		<cfoutput>
		<td>
			<a href="javascript:window.close()">#application.util.string.actionLinkFormat("close window")#</a>
		</td>
		</cfoutput>
	  </cfif>
	</tr>
</table>
</form>

<cfif ListFindNoCase(reportType,'ProgramLetters') OR ListFindNoCase(reportType,'ProgramClaimRatesReportAndLetters')>
<hr style="margin-left:30px;">
<div style="font-weight:bold;font-size:14px;margin-bottom:10px; margin-left:30px;">
	ATTACHMENTS
</div>

	<table width="800" class="maintable" border="0" cellpadding="0" cellspacing="0" style="margin-left:0px;margin-left:30px;"">
		<cfoutput>
		<cfif ListFindNoCase(reportType,'ProgramClaimRatesReportAndLetters')>
		<tr>
			<td style="font-size:12px;" colspan="100%"><span style="font-weight:bold;color:red">NOTE: CLAIM RATES REPORT IS ATTACHED ALONG WITH THE BELOW LISTED LETTER</span></td>
		</tr>
		</cfif>
		<tr>
			<td style="font-size:14px;" bgcolor="##ffce84" colspan="100%"><b>#application.returned_customer_setting.operator_label_singular# Letters</b></td>
		</tr>
		<tr>
			<td width="250" style="font-size: 12px; font-weight:bold" wrap>#application.returned_customer_setting.operator_label_singular# Name</td>
			<td width="250" style="font-size: 12px; font-weight:bold" wrap>#application.returned_customer_setting.distributor_label_singular# Name</td>
			<td width="100" style="font-size: 12px; font-weight:bold">Date</td>
			<td width="200" nowrap style="font-size: 12px; font-weight:bold">Created By</td>
		</tr>
		</cfoutput>

	<cfloop list="#url.letter_id#" index="letterID">
	<cfset qLetterInfo = application.oLetterManager.getLetterInfo(letterID)>
		<cfif qLetterInfo.letter_type eq 1>
		<cfoutput>
		<tr>
			<td width="250">#qLetterInfo.operator_name#</td>
			<td width="250"><cfif qLetterInfo.Distributor_name eq "">&nbsp;</cfif>#qLetterInfo.Distributor_name#</td>
			<td width="100">#dateformat(qLetterInfo.created_date,"mm/dd/yyyy")#</td>
			<td width="200" nowrap>#qLetterInfo.user_name#<cfif findNoCase("system_generated",qLetterInfo.letter_name,1)>(S)</cfif></td>
		</tr>
		</cfoutput>
		</cfif>
	</cfloop>
	</table>

	<table width="800" class="maintable" border="0" cellpadding="0" cellspacing="0" style="margin-left:0px;margin-top:20px; margin-left:30px;"">
	<cfoutput>
		<tr>
			<td style="font-size:14px;" bgcolor="##ffce84" colspan="100%"><b>#application.returned_customer_setting.distributor_label_singular# Letters</b></td>
		</tr>
		<tr>
			<td width="250" style="font-size: 12px; font-weight:bold" wrap>#application.returned_customer_setting.distributor_label_singular# Name</td>
			<td width="250" style="font-size: 12px; font-weight:bold" wrap>#application.returned_customer_setting.operator_label_singular# Name</td>
			<td width="100" style="font-size: 12px; font-weight:bold">Date</td>
			<td width="200" nowrap style="font-size: 12px; font-weight:bold">Created By</td>
		</tr>
	</cfoutput>

	<cfloop list="#url.letter_id#" index="letterID">
	<cfset qLetterInfo = application.oLetterManager.getLetterInfo(letterID)>
		<cfif qLetterInfo.letter_type eq 2>
		<cfoutput>
		<tr>
			<td width="250">#qLetterInfo.Distributor_name#</td>
			<td width="250"><cfif qLetterInfo.operator_name eq "">&nbsp;</cfif>#qLetterInfo.operator_name#</td>
			<td width="100">#dateformat(qLetterInfo.created_date,"mm/dd/yyyy")#</td>
			<td width="200" nowrap>#qLetterInfo.user_name#<cfif findNoCase("system_generated",qLetterInfo.letter_name,1)>(S)</cfif></td>
		</tr>
		</cfoutput>
		</cfif>
	</cfloop>
	</table>

</cfif>

<cfinclude template="/common_files/dataTables.cfm">

<script language="javascript" src="/script/javascript/google/base.min.js"></script>
<script language="javascript" src="/script/javascript/google/string.min.js"></script>
<script language="javascript" src="/script/javascript/google/emailaddress.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

<script>
$.fn.dataTableExt.afnSortData['dom-checkbox'] = function  ( oSettings, iColumn ) {
	var aData = [];
	$( 'td:eq('+iColumn+') input', oSettings.oApi._fnGetTrNodes(oSettings) ).each( function () {
		aData.push( this.checked==true ? "1" : "0" );
	} );
	return aData;
}
$('table.recipients').dataTable({
	 "bPaginate": false
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  ,"sScrollXInner": "100%"
  ,"sDom": "f"
  ,"sScrollY": "500px"	<!---limit datagrid to 500px in height--->
  ,"aaSorting": [[ 1, "asc" ]]
  ,"aoColumns": [   {"sSortDataType": "dom-checkbox" }
                  , {}
                  , {}
                  , {}
                ]
}).fnSetFilteringDelay();
// $(window).resize(function(){  $('table.recipients').fnAdjustColumnSizing(); });
function send_email() {
	bEmailError = 0;
	bSelectError = 0;
	bInternalEmailError = 0;
	bExternalEmailExists = 0;
	bErrorMsg = 'Either enter a email address for internal recipient OR select at least one external user to send the email to.';
	bInternalEmailInvalidErrorMsg = 'Please enter a valid email address.'

	/* If either distributor OR operator exist */
	if(document.getElementById('alldistributors') || document.getElementById('alloperators')){
		bExternalEmailExists = 1
	/* If none of the emtries are selected for emailing.  */
		if($('.distributors:checked').length == 0 && $('.operators:checked').length == 0){
			bSelectError = 1;
		}
	}

	if((goog.string.isEmpty(document.all.internals.value))) {
			bInternalEmailError = 1;
	}

	/* If the internal entered email is invalid */
	if ((!goog.string.isEmpty(document.all.internals.value)) && (!goog.format.EmailAddress.isValidAddress(document.all.internals.value)) ){
		bEmailError = 1;
	}

	/* If email is valid */
	if (bEmailError == 0
		&&
		(	/* If "External Email" option is ON AND the user has selected either an external user OR has entered email of an internal user */
			(bExternalEmailExists == 1) && (bSelectError == 0 || bInternalEmailError == 0)
			||
			/* If "External Email" option is OFF AND the user has not entered email of an internal user */
			(bExternalEmailExists == 0 && bInternalEmailError == 0)
		)
	)
	{
		contacts.submit();
	}
	else {
		if(bSelectError == 1 && bInternalEmailError == 1)
		{
			alert(bErrorMsg);
		}
		else if(bInternalEmailError == 1){
			alert(bInternalEmailInvalidErrorMsg)
		}
		else if(bEmailError){
			alert(bInternalEmailInvalidErrorMsg)
		}
	}
}

function process_all( elementID, checkClass ) {
	if($('#' + elementID).attr('checked') == 'checked')
	{
		$(checkClass).attr('checked',true)
	}
	else
	{
		$(checkClass).attr('checked',false)
	}
}

$('#emailmessage').keyup(function() {
  var len = this.value.length, maxlen = <cfoutput>#main.messageMaxLen#</cfoutput>;
  if (len >= maxlen)
    this.value = this.value.substring(0, maxlen);
  $('#charLeft').text(maxlen - len);
});
$('table.recipients tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
</script>

<cffunction name="RecipientHtml" output="false" returntype="string" hint="Returns the recipient name & email.">
  <cfargument name="first_name" type="string" required="true" hint="">
  <cfargument name="last_name"  type="string" required="true" hint="">
  <cfargument name="email"      type="string" required="true" hint="">

  <cfreturn trim(arguments.last_name & ' ' & trim(arguments.first_name) & ' (' & trim(arguments.email) & ')')>
</cffunction>

<cffunction name="RecipientVal" output="false" returntype="string" hint="Returns the recipient value when checked.">
  <cfargument name="id"    type="string" required="true" hint="">
  <cfargument name="email" type="string" required="true" hint="">

  <!---separate id and email with a vertical bar, the id is used to find distributor/operator info to be included
      in the letter--->
  <cfreturn trim(arguments.id) & '|' & trim(arguments.email)>
</cffunction>

</body>
</html>

