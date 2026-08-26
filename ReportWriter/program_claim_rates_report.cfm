<!DOCTYPE HTML>
<html lang="en">
<head>
	<cfparam name="form.report_type" default="1">
	<cfif structKeyExists(url, "report_type") and url.report_type neq "">
			<cfset form.report_type = url.report_type>
	</cfif>

	<cfset ReportName = "Claim Rates">
	<cfset FileName = "Claim-Rates">

	<cfif form.report_type EQ "2">
		<cfset ReportName = "Pricing">
		<cfset FileName = "Pricing-Report">
	</cfif>

	<cfoutput><title>Generate Program #ReportName# Report</title></cfoutput>

	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<link rel="stylesheet" href="/styles/jQueryUI_18/smoothness/jquery-ui-1.8.22.custom.css" type="text/css" />
	<link rel="stylesheet" type="text/css" href="/common_files/feedback.css">
	<cfset datatables.version = "1.9.1">
	<cfset jQueryUI.version   = "1.8.23">
	<cfinclude template="/common_files/jQuery.cfm">
	<cfinclude template="/common_files/dataTables.cfm">
	<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

	<style>
		h2 {
			background-color: #FFCE84;
			height: 26px;
			line-height: 26px;
			border-top:1px solid black;
			border-bottom:1px solid black;
			padding-left: 7px;
			font-size: 1.5em;
		}
		label {
			font-weight: bold;
			font-size: 1.0em;
		}
		#eDate {
			margin-left: 0px;
			margin-bottom: 10px;
		}
		#actions {
			margin: 7px 0 7px 0;
		}
		#please01 {
			/*font-weight: bold;*/
			font-size: 1.1em;
			margin: 10px 0 10px 0;
		}
		#datagrid thead tr th {
			text-align: left;
		}

		input[type="radio"]{ vertical-align:bottom;}
		.center { text-align:center; }
		.center a { margin:20px; }
		div#eDate a { margin-left: 20px; }
	</style>
</head>

<cfparam name="form.command" default="init">
<cfparam name="url.command" default="#form.command#">
<cfparam name="form.paidToList" default="">
<cfparam name="form.EffectiveDate" default="#dateFormat(now(), 'mm/dd/yyyy')#">
<cfparam name="url.filePath" default="init">
<cfparam name="url.FileName" default="init">
<cfparam name="ReportName" default="">
<cfparam name="windowStatus" default="0">
<cfparam name="FromFlex" default="0">
<cfparam name="form.paid_to" default="">
<cfparam Name="form.program_id_list" default="">
<cfparam Name="Operator_List" default="">

<!--- Operator Search return values to form field Operator_List --->
<cfif len(Operator_List)> <cfset form.paidToList = Operator_List /> </cfif>


<!------------------------------------------------------------------------------------------------------------------------------------------------------>
<body <cfif url.command eq "showFromFile" or url.command eq "generateReport">onfocus='checkVar()'</cfif>>

<!--- initialise cfc --->
<cfset objProgramClaimRatesReport = CreateObject("component", "components.programs.ProgramClaimRatesReport").init() />
<cfset DistributorManager = CreateObject("component", "components.customer.DistributorManager").init() />
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init()/>
<cfset appSettings = genSettingsManager.get()>

<!--- We get 'program_id' from the left nav when from a program otherwise from the program selection --->
<cfset program_id_list = "" />
<cfif isDefined("url.program_id")>
	<cfset program_id_list = url.program_id />
<cfelseif isDefined("form.program_id_list")>
	<cfset program_id_list = form.program_id_list />
</cfif>

<cfif program_id_list neq "">
	<cfquery name="paidToCheck" datasource="#application.datasource#">
		SELECT Component_Paid_To
		FROM dbo.Program_Rebates_Component
		WHERE Program_ID IN (#program_id_list#)

		UNION

		SELECT Fixed_Component_Paid_to
		FROM dbo.Program_Fixed_Component
		WHERE Program_ID IN (#program_id_list#)

		UNION

		SELECT Component_Paid_To
		FROM dbo.Program_Lump_Sums
		WHERE Program_ID IN (#program_id_list#)
	</cfquery>
</cfif>

<cfoutput>
<!------------------------------------------------------------------------------------------------------------------------------------------------------>
<cfif url.command eq "showFromFile">
	<cfif url.filePath neq "" and url.FileName neq "">
		<cfheader name="Content-Disposition" value="attachment; filename=#url.FileName#">
		<!--- <cfcontent type="text/plain"  file="#Application.Doc_Path#\#url.filePath#"> --->
		<cfcontent type="text/plain"  file="#application.stMVCAppInfo.applicationPath#\#url.filePath#">
	</cfif>

<!------------------------------------------------------------------------------------------------------------------------------------------------------>
<cfelseif url.command eq "generateReport">
	<form name="frm">
		<input type="hidden" name="winStatus" value="0">
	</form>

	<cfset qProgramClaimRatesReport = objProgramClaimRatesReport.getProgramClaimRatesReport(
																				 programIDList = program_id_list
																				,distributorIDList = form.paidToList
																				,EffectiveDate = form.EffectiveDate
																				,ReportType = form.report_type
																				,pays_to = (form.paid_to eq 'Operator' ? 2 : 1)
																				,report_config_id = form.report_config_id,
																				IncludeInActive = form.includeInactive
																				 ) />

	<cfset form.program_id_list = application.util.string.listDeDuplicates( form.program_id_list )>

	<cfif listLen(form.program_id_list) eq 1>
		<cfquery name="variables.program" datasource="#application.datasource#">
			SELECT cm.contract_number, cm.revision_version, cm.Contract_Status_Type_IDX,pcpo.operator_letters_required,
					pcpo.distributor_letters_required
				FROM Contract_Main cm
				INNER JOIN Program_control_panel_options pcpo
			ON cm.programType_ID = pcpo.Programcontrol_panel_options_ID
			WHERE cm.contract_main_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#listFirst(form.program_id_list)#">
		</cfquery>
		<cfset programClaimRateReportFileName = "#FileName#-#variables.program.contract_number#-#numberFormat(variables.program.revision_version,'000')#.csv" />
	<cfelse>
		<cfset programClaimRateReportFileName = "#FileName#-#DateFormat(Now(), "mmddyyyy")#-#timeFormat(now(),"hhmmss")#.csv" />
	</cfif>
	<cfif ListLen(program_id_list) eq 1>
		<cfset programClaimRateReportFileName = "#FileName#-#qProgramClaimRatesReport.PROGRAM_NUMBER#.csv" />
	</cfif>

	<cfsavecontent variable="sProgramClaimRateReportContent">
		<cfif form.report_type eq 1>
			<cfinclude template="program_claim_rates_report_display.cfm">
		<cfelseif form.report_type eq 2>
			<cfinclude template="program_pricing_report_display.cfm">
		</cfif>
	</cfsavecontent>

	<cfset subFolderName="program_claim_rates_report" />
	<CF_Writing_Email_Attachment
			Naming_Format="#programClaimRateReportFileName#"
			File_Extension="csv"
			Relative_Path="\Temp_Files\Program\"
			Output_Content="#sProgramClaimRateReportContent#"
			addNewLine="No"
			folder_name="#subFolderName#"
			Return_File_Name="sProgramClaimRateReportFilePath"
			Return_Letter_Name="sProgramClaimRateReportFileName"
			 />
  <cfoutput><h2>#ReportName# Report</h2></cfoutput>
	<br><br>
	<div class="success">Program #ReportName# report has been generated.</div>
	<div class="info">
	If a distributor and/or program do not appear in a report, check that the following conditions were met:
		<ul>
			<li>The distributor and component must be in the program version based on the effective date you entered</li>
			<li>The claim mechanic for the component must be set to Include in claim rates report = yes</li>
		</ul>
	</div>
	<br>
	<script language="javascript">
		function DownloadReport()
		{
			window.location.href= 'program_claim_rates_report.cfm?command=showFromFile&windowStatus=1&filePath=Temp_Files/Program/#subFolderName#/#sProgramClaimRateReportFileName#&FileName=#programClaimRateReportFileName#&EffectiveDate=#form.EffectiveDate#&report_type=#form.report_type#'
			changeVar();
		}

		function openEmailPopup(){
			NewWindow('about:blank','contacts','870','720','Yes','No');
			emailReport.target = 'contacts';
			emailReport.submit();
		}

		function openEmailReportAndLetterPopup(){
			emailProgramClaimRatesReportAndLetters.submit();
		}
	</script>

	<cfoutput>
	<div class="center">
	 <cfparam name="vars.clause" default="">
	 <!---
	 THIS IS THE OLD CODE FOR EMAILING (CODE COMMENTED)
	 <form name="emailReport" action="email_report.cfm" method="post">
	 	<input type="hidden" name="attachments" value="#sProgramClaimRateReportFilePath#">
	 	<input type="hidden" name="subject" value="#ReportName# Report">
	 	<input type="hidden" name="clause" value="#HTMLCodeFormat(vars.clause)#">
	 </form>
	 <a href="javascript:DownloadReport();">#application.util.string.actionLinkFormat("download")#</a>
	 <a href="javascript:$('form[name=emailReport]').submit();">#application.util.string.actionLinkFormat("email")#</a>
	 --->
	 <!--- Dev Note: 60400 (NEW CODE FOR EMAILING).It can handle internal as well as external contacts. --->
	 <form name="emailReport" action="/common_files/contracts/email_contacts.cfm" method="post">
	 	<input type="hidden" name="attachments" value="#sProgramClaimRateReportFilePath#">
	 	<input type="hidden" name="subject" value="#ReportName# Report">
	 	<input type="hidden" name="clause" value="#HTMLCodeFormat(vars.clause)#">
		<input type="hidden" name="mode" value="edit">
		<input type="hidden" name="program_id_list" value="#form.program_id_list#">
		<input type="hidden" name="reportType" value="ProgramClaimRatesReport">
		<input type="hidden" name="paidToList" value="#form.paidToList#">
		<input type="hidden" name="paid_to" value="#form.paid_to#">
	 </form>

	 
	 <cfset showReportAndLetterLink = 0>
	 <cfif appSettings.getDisplayQuoteLetter() eq 0 and appSettings.getlettersavailable() neq 4 and appSettings.getExternal_Contacts() neq 0>
		 <cfif listLen(form.program_id_list) eq 1 and appSettings.getlettersavailable() and variables.program.Contract_Status_Type_IDX GTE 3 and (variables.program.operator_letters_required EQ 1 OR variables.program.distributor_letters_required EQ 1)>
			 <cfset showReportAndLetterLink = 1>
		 </cfif>
	 </cfif>
	<!--- Dev Note: 69439 - When user wants to email claim rates report AND program letter in one email, we need to send
	these hidden variables, including the "claim rates report" to the "view letters" page, so that the user can select the appropriate
	letter and email both in one email.
	--->
	 <cfif showReportAndLetterLink eq 1>
		 <form name="emailProgramClaimRatesReportAndLetters" action="/common_files/contracts/Letters/show_opr_dis_letters.cfm?CID=#form.program_id_list#" method="post">
			<input type="hidden" name="attachments" value="#sProgramClaimRateReportFilePath#">
			<input type="hidden" name="subject" value="#ReportName# Report">
			<input type="hidden" name="clause" value="#HTMLCodeFormat(vars.clause)#">
			<input type="hidden" name="mode" value="edit">
			<input type="hidden" name="program_id_list" value="#form.program_id_list#">
			<input type="hidden" name="reportType" value="ProgramClaimRatesReport">
			<input type="hidden" name="paidToList" value="#form.paidToList#">
			<input type="hidden" name="paid_to" value="#form.paid_to#">
			
			<input type="hidden" name="SkipLock" value="1">
			<input type="hidden" name="reportType" value="ProgramClaimRatesReportAndLetters">
		 </form>
	</cfif>

	 <a href="javascript:DownloadReport();">#application.util.string.actionLinkFormat("download")#</a>
	 <a href="##" onClick="openEmailPopup()">#application.util.string.actionLinkFormat("email")#</a>


	<!--- 
	Dev Note:69439 - 
	When user wants to email claim rates report and letter in one email - We show the below link only when the user
	has generated the "distributor" claim rates report and the report is only for one distributor.
	Once they have generated claim rates report for one distributor, then can click the below link, attach the same distributor's letter
	as well and then email the claim rates report and letter in one email.
	--->
	 <cfif showReportAndLetterLink eq 1 and Listlen(form.paidToList) eq 1 and form.paid_to eq "Distributor">
	 <a href="##" onClick="openEmailReportAndLetterPopup()">#application.util.string.actionLinkFormat("email this report and letter")#</a>
	 </cfif>
		
	 <!--- <a href="javascript:window.close()">#application.util.string.actionLinkFormat("close window")#</a> --->
	</div>
	</cfoutput>

<!------------------------------------------------------------------------------------------------------------------------------------------------------>
<cfelse>

	<form name="frmDates" action="#SCRIPT_NAME#" method="post">
  <cfoutput><h2>#ReportName# Report</h2></cfoutput>

	<cfset inputReadOnly = (len(form.paid_to)  ? "readonly" : "") />
	<cfset inputDisabled = (len(form.paid_to)  ? "disabled" : "") />

	<div id="eDate">
		<cfif IsDefined("paidToCheck")>
			<cfif paidToCheck.recordCount EQ 1 and paidToCheck.Component_Paid_To EQ 2>
				<div align="center" style="color:red;font-weight:bold;">Distributor claim report will be empty as program paid to Operator.</div>
			</cfif>
		</cfif>
		<label for="EffectiveDate">Enter the Effective Date</label>
		<input type="text" name="EffectiveDate" id="EffectiveDate" value="#form.EffectiveDate#" #inputReadOnly# style="margin-left:7px;width:100px;font-size:1.1em;">

		<label style="margin-left:20px;">Search</label>
		<span id="paid_to_distributor">
			<cfif len(form.paid_to)>
				<input type="radio" id="paid_to" name="paid_to" value="#form.paid_to#" #inputDisabled# <cfif form.paid_to eq "Distributor">checked</cfif>>#application.returned_customer_setting.distributor_label_plural#
			<cfelse>
				<a href="##" onclick="javascript:searchData('Distributor');" style="cursor: pointer;">#lcase(application.util.string.actionLinkFormat(application.returned_customer_setting.distributor_label_plural))#</a>
			</cfif>
		</span>
		<span id="paid_to_operator">
			<cfif len(form.paid_to)>
				<input type="radio" id="paid_to" name="paid_to" value="#form.paid_to#" #inputDisabled# <cfif form.paid_to eq "Operator">checked</cfif>>#application.returned_customer_setting.operator_label_plural#
			<cfelse>
				<a href="##" onclick="javascript:searchData('Operator');" style="cursor: pointer;">#lcase(application.util.string.actionLinkFormat(application.returned_customer_setting.operator_label_plural))#</a>
			</cfif>
		</span>
		<span id="please01">
			<br/><br/> The #ReportName# report can be generated for distributors OR operators. The report cannot be generated for both at the same time.
		</span>
	</div>  <!---id="eDate"--->
	<hr style="margin-top:20px;" color="black"/>

	<!------------------------------------------------------------------------------------------------
		If paidTo is selected and no payees are selected, display the payees.
		If payees are selected then display programs.
	-------------------------------------------------------------------------------------------------->
	<cfset qGetPaidTo = queryNew("") />
	<cfif len(program_id_list)>
		<cfif form.paid_to eq "Distributor">
			<cfset qGetPaidTo  = DistributorManager.getPaidToDistributor(programId=program_id_list) />
		<cfelseif form.paid_to eq "Operator">
			<cfset qGetPaidTo  = DistributorManager.getPaidToOperator(programId=program_id_list) />
		</cfif>
		<cfif qGetPaidTo.recordCount eq 1 >
			<cfset form.paidToList = qGetPaidTo.BSA_ID />
		</cfif>
	</cfif>

	<!--- **************** Display Distributor/Operator Selection **************** --->
	<cfif len(form.paid_to) and NOT(len(form.paidToList)) >

		<!--- display distributors only if Distributors exist --->
		<cfif qGetPaidTo.recordCount>
			<div id="please01">
				<span style="float:left;">Please select the #lcase(form.paid_to)#s to be included in the report.</span>
				<a style="float:right;display:inline;" href="##" id="nextstep">#application.util.string.actionLinkFormat("next step")#</a>
			</div>
			<div style="clear:both;"></div>
			<div class="datagridwrapper" style="margin-top:10px;">

			<table id="datagrid" class="datagrid" style='table-layout:fixed'>
			<col width="5%">
			<col width="35%">
			<col width="20%">
			<col width="40%">
			<thead>
				<tr>
				  <th style="text-align:left;"><input type="checkbox" name="toggle_all" id="toggle_all" <cfif qGetPaidTo.recordCount eq 1>checked=checked</cfif> /></th>
				  <th>Name</th>
				  <th>#application.returned_customer_setting.Shard_Ship_To_Label#</th>
				  <th>Address</th>
			  </tr>
			</thead>
			<tbody>
				<cfsetting enablecfoutputonly=true>
					<cfloop query="qGetPaidTo">
						<cfoutput><tr></cfoutput>
						<cfoutput><td><input type="checkbox" id="#qGetPaidTo.BSA_ID#" name="paidToList" value="#qGetPaidTo.BSA_ID#" <cfif qGetPaidTo.recordCount eq 1>checked=checked</cfif> class="cb"/></td></cfoutput>
						<cfoutput><td>#trim(qGetPaidTo.Name)#</td></cfoutput>
						<cfoutput><td>#trim(qGetPaidTo.ID)# <cfif form.paid_to eq "Operator">[#trim(qGetPaidTo.BSA_ID)#]</cfif></td></cfoutput>
						<cfoutput><td>#qGetPaidTo.Address_1# #qGetPaidTo.City# #qGetPaidTo.State#</td></cfoutput>
						<cfoutput></tr></cfoutput>
					</cfloop>
				<cfsetting enablecfoutputonly=false>
			</tbody>
			</table>
			</div>
		<cfelse>
					<div class="info">There are no #lcase(form.paid_to)#s found</div>
					<a style="" href="##" onClick="window.history.back()">#application.util.string.actionLinkFormat("go back")#</a>
		</cfif>  <!--- qGetPaidTo.recordCount	 --->

	<!--- **************** Display Program Selection **************** --->
	<cfelseif len(form.paid_to) and len(form.paidToList)>
		<input type="hidden" name="command" value="generateReport">
		<!---<cfdump var="form"/><cfabort>--->
		<cfset qPrograms = objProgramClaimRatesReport.getClaimRatesProgramsDetails(
															effectiveDate = form.EffectiveDate,
															paidTo 				= form.paid_to,
															paidToList 		= form.paidToList,
															programIDList = program_id_list
														)/>
		<cfscript>
			configIdList = ValueList(qPrograms.Config_ID) ;
			configNameList = ValueList(qPrograms.Config_Name);
			configStruct = {};
			for(i=1;i<=ListLen(configIdList);i++)
			{
				configStruct[ListGetAt(configIdList,i)] = ListGetAt(configNameList,i);
			}
		</cfscript>
		<!--- if payee is selected, display program selection --->
		<div style="float:right;"><input type="checkbox" name="chkIncInactive" id="chkIncInactive" value="1"> <strong>Include Inactive Items</strong></div>
		<div id="please01"><span style="float:left;">Please check the programs that need to be included in the report.</span><br>


			<a style="float:right;display:inline;" href="##" onClick="ValidateDaysOfHistoricalData('1');">#application.util.string.actionLinkFormat("generate report")#</a>
		</div>
		<div style="clear:both;"></div>
		<div class="datagridwrapper" style="margin-top:10px;">
			<table id="datagrid" class="datagrid" style='table-layout:fixed'>
				<col width="5%">
				<col width="13%">
				<col width="20%">
				<col width="15%">
				<col width="7%">
				<col width="20%">
				<col width="20%">
				<thead>
					<tr>
						<th style="text-align:left;"><input type="checkbox" name="toggle_all" id="toggle_all" <cfif qPrograms.recordCount eq 1>checked=checked</cfif>/></th>
						<th>Program</th>
						<th>Title</th>
						<th class="columnfilter addselect">Report Setting *<br/>
							<select name="report_config_id" style="width:99%;" id="report_config_id">
								<cfif StructCount(configStruct) gt 1><option value="">#repeatString("&nbsp;",20)#</option></cfif>
								<cfloop collection="#configStruct#" item="configId">
									<option value="#configId#" <cfif StructCount(configStruct) eq 1>selected=selected</cfif>>#StructFind(configStruct,configId)#</option>
								</cfloop>
							</select>
						</th>
						<th>Status</th>
						<th>Type</th>
						<th>RSP</th>
					</tr>
				</thead>
				<tbody>
					<cfsetting enablecfoutputonly=true>
					<cfloop query="qPrograms">
						<cfoutput><tr></cfoutput>
						<cfoutput>
							<td>
								<input type="checkbox" id="#qPrograms.contract_main_id#" name="program_id_list" value="#qPrograms.contract_main_id#" <cfif qPrograms.recordCount eq 1>checked=checked</cfif> class="cb"/>
							</td>
						</cfoutput>
						<cfoutput><td>#trim(qPrograms.contract_number)#-#numberFormat(qPrograms.revision_version, '000')#</td></cfoutput>
						<cfoutput><td>#trim(qPrograms.contract_title)#</td></cfoutput>
						<cfoutput><td>#trim(qPrograms.config_name)#</td></cfoutput>
						<cfoutput><td>#trim(qPrograms.Contract_Status_Type_Desc)#</td></cfoutput>
						<cfoutput><td>#trim(qPrograms.Created_Type)#</td></cfoutput>
						<cfoutput><td>#trim(qPrograms.RSP)#</td></cfoutput>
						<cfoutput></tr></cfoutput>
					</cfloop>
					<cfsetting enablecfoutputonly=false>
				</tbody>
			</table>
			<div style="clear:both;margin-top:5px;">* is a required input</div><br/>
			<div style="clear:both;"></div>
			<cfif (NOT IsDefined("Program_ID"))>
				<hr color="black"/>
				<span style="font-size:12px;font-weight:bold;">#listlen(form.paidToList)# #form.paid_to#(s) selected</span> <br/><br/>
				<cfinclude template="report_distributor_list.cfm">
			</cfif>
		</div>
	</cfif>

	<!---disabled inputs would not be posted therefore create hidden inputs to post--->
	<input type="hidden" id="paid_to" name="paid_to" value="#form.paid_to#">
	<input type="hidden" id="report_type" name="report_type" value="#form.report_type#">
	<input type="hidden" id="paidToList" name="paidToList" value="#form.paidToList#">
	<input type="hidden" id="program_id_list" name="program_id_list" value="#program_id_list#">
	<INPUT type="hidden" id="Operator_List" name="Operator_List" value="#Operator_List#">
	<input type="hidden" id="includeInactive" name="includeInactive" value="0">

	</form>  <!---name="frmDates" action="#SCRIPT_NAME#" method="post">	--->

	<cfinclude template="validate_data.cfm">
</cfif>  <!---url.command eq "showFromFile">--->
</cfoutput>

		<!--- if single program from within a program
				a. find delivery period
				b. add JS validation for effective date against delivery period
		 --->
		<cfquery name="variables.delivery" datasource="#application.datasource#">
			SELECT Contract_Start_Date, Contract_End_Date
			  FROM CONTRACT_MAIN
			 WHERE <cfif not isDefined("url.program_id")>
			 			1 = 0
			 	   <cfelse>
			 			Contract_main_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.program_id#">
			 	   </cfif>
		</cfquery>

<script type="text/javascript" src="/Script/javascript/moment.min.js"></script>
<script type="text/javascript">
	// $(function() {$('input[name=EffectiveDate]').datepicker();});
	$(function() {
		var effectiveDate = $('input[name=EffectiveDate]');
		if(!effectiveDate.is('[readonly]')){

			<cfif isDefined("url.program_id")>
				// remove today default date
				// effectiveDate.val("");
				// apply delivery date as date range
				effectiveDate.datepicker( { numberOfMonths: 3,
					maxDate: new Date("<cfoutput>#dateFormat(variables.delivery.Contract_End_Date,"long")#</cfoutput>"),
					minDate: new Date("<cfoutput>#dateFormat(variables.delivery.Contract_Start_Date,"long")#</cfoutput>") });
			<cfelse>
				effectiveDate.datepicker( { numberOfMonths: 3, showCurrentAtPos: 0,
					maxDate: <cfoutput>#val(application.oApplicationAppSettingsManager.getApplicationAppSettings().getMaxFutureDaysForClaimRatesORPricingExtract())#</cfoutput>,
					minDate: -<cfoutput>#val(application.oApplicationAppSettingsManager.getApplicationAppSettings().getDaysOfHistoricalDataForSpecialPriceList())#</cfoutput> });
			</cfif>
		}
	});

	$(function() {
		<!---data grid--------------------------------------------------------------------------------------------------------->
		mydatagrid = $('#datagrid').dataTable({
			"bAutoWidth": false
			,"bPaginate": false
			,"bSortClasses": false
			,"bScrollCollapse": true
			,"sDom": 'fti'
			,"fnDrawCallback": function() {  toggle_all();   }
			,"aoColumns": [ {"bSearchable":false, "sSortDataType":"dom-checkbox", "bSortable":false }
											,null
											,null
											,{"bSortable":false}
											<cfif len(form.paidToList)>
											,null
											,null
											,null
											</cfif>
										]}).fnSetFilteringDelay();

			/* Add a select menu for each TH element in the table header */
			$('#datagrid thead tr th').each( function ( i ) {
				if ( $(this).hasClass("columnfilter") ) {
					$('select', this).change( function () {
						var report_setting = $("option:selected", this).text();
						// clear out selected programs with diff report setting before applying new filter
						$('tbody tr').each(function() {
							// locate the checkbox on this row
							var pick = $("td:nth-child(1)", this).children("input");
							// if checkbox is checked and report setting is not the same uncheck it
							if ( pick.is(":checked") && report_setting !== $("td:nth-child(4)", this).text() ) {
								pick.prop("checked", false);
							}
						});
						mydatagrid.fnFilter( report_setting.replace(/\s+/g, ' '), i );
					});
				}
			});

			// hover CSS
			$('#datagrid tr').hover (
			  function() { $(this).addClass("over"); },
			  function() { $(this).removeClass("over"); }
			);
	});

	<!---function to set toggle all checkbox------------------------------------------------------------------------------------>
	toggle_all = function() {
		// toggle all is enabled when no. of checkboxes equals to no. of checked checkboxes otherwise make it disabled
		$('#toggle_all').prop('checked', ( $('input.cb').length && $('input.cb:checked').length == $('input.cb').length ) ? true : false );
	}

	<!---events for toggle all checkbox------------------------------------------------------------------------------------>
	$('#toggle_all').change(function(e){      <!---listen for the change event on the toggle--->
	 $('input.cb').prop('checked', ( this.checked ) ? true : false );
	 e.stopPropagation();
	});

	<!---event for individual checkbox------------------------------------------------------------------------------------>
	$('input.cb').change(function(e){      <!---listen for the change event on the toggle--->
		toggle_all();
	});

	// paid_to: if distributor or operator is clicked then submit the form
	setGray = function(){
		if($('input[name=paid_to]:checked').val()){
			$('#EffectiveDate').css("color","gray");
			$('#eDate').css("color","gray");
		}
	}
	setGray();

	// paid_to: if distributor or operator is clicked then submit the form
	function searchData(paidTo){
		// effective date validation against delivery period when this is called from within a program
		<cfif isDefined("url.program_id")>
			var begin_date = new Date("<cfoutput>#dateFormat(variables.delivery.Contract_Start_Date,"long")#</cfoutput>")
			   ,end_date   = new Date("<cfoutput>#dateFormat(variables.delivery.Contract_End_Date,"long")#</cfoutput>")
			   ,error_msg  = ''
			   ,effectiveDate = moment( $('#EffectiveDate').val() );
			if (!effectiveDate) {
				error_msg = 'Please enter a valid effective date.';
			}
			else if ((moment(effectiveDate).isBefore(begin_date)) || (moment(effectiveDate).isAfter(end_date))) {
				error_msg = 'Please enter an effective date between ' + '<cfoutput>#dateFormat(variables.delivery.Contract_Start_Date,"long")#</cfoutput> and <cfoutput>#dateFormat(variables.delivery.Contract_End_Date,"long")#</cfoutput>';
			}
			if (error_msg.length) {
				alert(error_msg);
				return false;
			}
		</cfif>

		$('input[name=paid_to]').val(paidTo);
		setGray();
		<cfif len(program_id_list) >
			frmDates.submit();
		<cfelse>
			// form will be submitted by dist/operator search popup
			if(paidTo == 'Operator'){
				NewWindow("/billbacks/search_screens/PM_select_operators.cfm?Formname=frmDates&SelectSingleSearchResultOnly=0", "searchWindow", "800", "600", "yes", "yes");
			}
			else if(paidTo == 'Distributor'){
				NewWindow("/billbacks/search_screens/PM_select_distributors.cfm?Formname=frmDates&FieldName=paidToList&SelectSingleSearchResultOnly=0&ShowActiveDistributorsOnly=1&AllowImportAll=1", "searchWindow", "800", "600", "yes", "yes");
			}
		</cfif>
	}

	// rename the header for ship_to with operater id
	if($('input[name=paid_to][value="Operator"]:checked').val()){
		$('#datagrid th:nth-child(3)')
			.text("<cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> ID");
	}
	// next step is clicked
	$('#nextstep').click(function() {
		if ( $('input.cb:checked').length == 0 ) {
			alert('select atleast one ' + $('input[name=paid_to]:checked').val().toLowerCase());
			return false;
		}
		else {
			$(this).unbind('click').html('<b>one moment...</b>');
			mydatagrid.fnFilter('');
			frmDates.submit();
		}
	});

	/* I had to close the window after opening the report. Because of that, I am using these two functions -
		- checkVar
		- changeVar
	*/
	function checkVar()	{
		if(document.frm.winStatus){
			if(document.frm.winStatus.value==1)	{
				window.close();
			}
		}
	}

	function changeVar() {
		if(document.frm.winStatus){
			document.frm.winStatus.value=1;
		}
	}
</script>

</body>
</html>

