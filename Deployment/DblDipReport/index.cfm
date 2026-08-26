<!-----------------------------------------------------------------------------

FILE NAME:		index.cfm
DESCRIPTION:	Double Dip Report landing page.
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	9-Dec-2008		
------------------------------------------------------------------------------> 
<cfsilent>
	<cfparam name="FORM.ReportDate"	default="#DateFormat(now(), 'mm/dd/yyyy')#" />
	<cfparam name="FORM.ReportType" default="" />
	<cfparam name="FORM.OverlapDays" default="1" />
	
	<cfset BBDblDipReportMgr = CreateObject("component", "mvc.Models.Billback.BillbackDblDipRpt") />
	<cfset displayErrorMessage = "" />
	<cfset filedownloadpath = "" />
	
	<cfif isDefined("FORM.submitted") AND FORM.submitted EQ "1" AND isDefined("FORM.submitSource") AND FORM.submitSource EQ "self" AND FORM.actionsToDo EQ "SaveOnly">
		<cfset qGetReportHistoryID = BBDblDipReportMgr.updGetReportHistoryID() />
	</cfif>
	
	<cfif isDefined("FORM.submitted") AND FORM.submitted EQ "1" AND isDefined("FORM.submitSource") AND FORM.submitSource EQ "self" AND FORM.actionsToDo EQ "SaveAndGenerate">
	
		<cfquery name="qFilePath" datasource="#application.datasource#">
			SELECT      DTS_Reference_Path
			FROM  DataInt_Settings
			ORDER BY Dataint_setting_ID
		</cfquery>
	
		<cfquery name="qCreateTemp" datasource="#application.datasource#">	
			IF OBJECT_ID ('tempdb..##check_status') IS NOT NULL 
				DROP TABLE ##check_status
				CREATE TABLE ##check_status 
				(Message varchar(1000) ,status int) 
		</cfquery>
		
		<cfset pathFileName = "#Application.Doc_Path#\Data_Files\Created\billbacks\DblDipReport\"   /> 
		<cfif FindNoCase("C:", pathFileName)>
			<cfset pathFileName  = "\\" & Application.WebServerName & Replace(pathFileName, "C:", "")>
		<cfelseif FindNoCase("E:", pathFileName)>
			<cfset pathFileName  = "\\" & Application.WebServerName & Replace(pathFileName, "E:", "")>
		<cfelseif FindNoCase("D:", pathFileName)>
			<cfset pathFileName  = "\\" & Application.WebServerName & Replace(pathFileName, "D:", "")>
		<cfelse>
			<cfset pathFileName  = "\\" & Application.WebServerName & Replace(pathFileName, "F:", "")>
		</cfif> 
	
		<cfset FORM.newOprIDs = "" />
		<cfset FORM.newPrgIDs = "" />
	
		<!--- SYSCO --->
		<cfif FORM.ReportType EQ "SYSCO">
		
			<cfstoredproc procedure="EDI_SYSCO_Double_Dip_Extract" datasource="#application.datasource#">
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@called_from" value = "1" null="no">
				<cfprocparam type="In" CFSQLType="CF_SQL_DATE" dbVarName = "@Date" value = "#DateFormat(FORM.ReportDate,'mm/dd/yyyy')#" null="no">
			</cfstoredproc>
				
			<cfquery name="qGetTempVals" datasource="#application.datasource#">	
				SELECT Message, status from ##check_status 
			</cfquery> 
	
			<cfif qGetTempVals.Status EQ "4">
				<cfset SyscoFile = qGetTempVals.Message />
				<cfif (FileExists(SyscoFile))>
					<!--- 	a) do a entry in the history table
							b) get the ID and then rename the file 
							c) call it with the getDocument.cfm to download
					--->
					<cfset qGetReportHistoryID = BBDblDipReportMgr.updGetReportHistoryID() /> 
					<cfset DownloadFileName = "EDI_SYSCO_DOUBLE_DIP_REPORT" & "_" & qGetReportHistoryID.BB_DblDipRpt_History_ID & ".xlsx" />
					<cfset pathFileName = pathFileName & DownloadFileName />
					<cffile action = "copy" 
						source = "#SyscoFile#" 
						  destination = "#pathFileName#"
						  nameconflict="OVERWRITE">
						<cfdump var="#pathFileName#" />
					<cfset filedownloadpath = "#URLEncodedFormat(pathFileName)#" />
				 <cfelse>
					<cfset displayErrorMessage = "File not found: " & SyscoFile />
				</cfif>
			<cfelse>
				<cfif (qGetTempVals.Status EQ "5")>
					<cfset displayErrorMessage = "No data available for the selected date. Please pick a different date." />
				<cfelse>
					<cfset displayErrorMessage = qGetTempVals.Message />
				</cfif>
			</cfif> <!--- <cfif qGetTempVals.Status EQ "4"> --->
	
		<!--- USFS --->
		<cfelseif FORM.ReportType EQ "USFS">
	 
			  <cfstoredproc procedure="EDI_USFS_Double_Dip_Extract" datasource="#application.datasource#">
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@called_from" value = "1" null="no">
				<cfprocparam type="In" CFSQLType="CF_SQL_DATE" dbVarName = "@Date" value = "#FORM.ReportDate#" null="no">
			</cfstoredproc>
	
			<cfquery name="qGetTempVals" datasource="#application.datasource#">	
				SELECT Message, Status from ##check_status 
			</cfquery> 
			
			<cfif qGetTempVals.Status EQ "4">
				<cfset USFSFile = qGetTempVals.Message />
				<cfif (FileExists(USFSFile))>
					<!--- a) do a entry in the history table
					b) get the ID and then rename the file 
					c) call it with the getDocument.cfm to download
					--->
					<cfset qGetReportHistoryID = BBDblDipReportMgr.updGetReportHistoryID() />
					<cfset DownloadFileName = "EDI_USFS_DOUBLE_DIP_REPORT" & "_" & qGetReportHistoryID.BB_DblDipRpt_History_ID & ".xlsx" />
					<cfset pathFileName = pathFileName & DownloadFileName />
					<cffile action = "copy" 
						source = "#USFSFile#" 
						destination = "#pathFileName#"
						nameconflict="OVERWRITE">
					<cfset filedownloadpath = "#URLEncodedFormat(pathFileName)#" />
					<!--- <cflocation URL="/getDocument.cfm?filePath=#pathFileName#" />  --->
					 <script>
						 show_loader( "Generating Report, Please Wait...", 10);
					 </script>
	
				<cfelse>
						<cfset displayErrorMessage = "File not found: " & USFSFile />
				</cfif>
			<cfelse>
				<cfif (qGetTempVals.Status EQ "5")>
					<cfset displayErrorMessage = "No data available for the selected date. Please pick a different date." />
				<cfelse>
					<cfset displayErrorMessage = qGetTempVals.Message />
				</cfif>
			</cfif> <!--- <cfif qGetTempVals.Status EQ "4"> --->
	
		
		<!--- 3rd Party --->
		<cfelseif FORM.ReportType EQ "3rd Party">
			<cfstoredproc procedure="III_Party_Double_Dip_Extract" datasource="#application.datasource#">
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@called_from" value = "1" null="no">
				<cfprocparam type="In" CFSQLType="CF_SQL_DATE" dbVarName = "@Date" value = "#FORM.ReportDate#" null="no">
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@overlap_Days" value = "#FORM.OverlapDays#" null="no">			
			</cfstoredproc>	
			<cfquery name="qGetTempVals" datasource="#application.datasource#">	
				SELECT Message, status from ##check_status 
			</cfquery> 
			
			<cfif qGetTempVals.Status EQ "4">
				<cfset IIIPartyFile = qGetTempVals.Message />
				<cfif (FileExists(IIIPartyFile))>
					<!--- a) do a entry in the history table
					b) get the ID and then rename the file 
					c) call it with the getDocument.cfm to download
					--->
					<cfset qGetReportHistoryID = BBDblDipReportMgr.updGetReportHistoryID() />
			
				<cfset DownloadFileName = "III_Party_Double_Dip_Report" & "_" & qGetReportHistoryID.BB_DblDipRpt_History_ID & ".xlsx" />
				<cfset pathFileName = pathFileName & DownloadFileName />
				<cffile action = "copy" 
					source = "#IIIPartyFile#" 
					destination = "#pathFileName#"
					nameconflict="OVERWRITE">
					<cfset filedownloadpath = "#URLEncodedFormat(pathFileName)#" />
				<cfelse>
						<cfset displayErrorMessage = "File not found: " & USFSFile />
				</cfif>
			<cfelse>
				<cfif (qGetTempVals.Status EQ "5")>
					<cfset displayErrorMessage = "No data available for the selected date. Please pick a different date." />
				<cfelse>
					<cfset displayErrorMessage = qGetTempVals.Message />
				</cfif>
			</cfif> <!--- <cfif qGetTempVals.Status EQ "4"> --->
		
		</cfif>
	</cfif> <!--- <cfif isDefined("FORM.submitted") AND FORM.submitted EQ "1" AND isDefined("FORM.submitSource") AND FORM.submitSource EQ "self" AND FORM.actionsToDo EQ "SaveAndGenerate"> --->
	
	
	<cfset justSaved = 0 />
	<cfif isDefined("FORM.actionsToDo") AND (FORM.actionsToDo EQ "SaveAndGenerate" OR FORM.actionsToDo EQ "SaveOnly")>
		<cfset justSaved = 1 />
	</cfif>
	


	</cfsilent>
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html>
	<head>
		<title>Double Dip Report</title>
		<style>
			#form-top {
				display: grid;
				grid-template-columns: 1fr auto 8fr;
				grid-template-rows: 1fr 1fr 1fr;
				gap: 15px 10px;

				color: #343540;
				padding-left:20px;
			}
			#form-bottom {
				color: #343540;
				padding-top: 10px;
			}

			#form-top label {
				font-size: 14px;
				margin-bottom: 15px;
				padding-right: 5px;
				text-align: right;
			}
			#form-top .info {
				width: auto;
				color: #7C7C7C;
				font-size: 12px;
				margin-bottom: 10px;
				margin-left: 20px;
				padding-right: 5px;
				text-align: left;
			}
			#form-top input,
			#form-top select {
				font-size:12px;
				height: 22px;
			}
			input.small {
				width: 87px;
			}
			#reportTypeLabel {
				font-size: 14px;
			}
			#form-bottom .group {
				font-size:13px;
				font-weight: 600;
				margin: 15px 0 8px 0;
			}
			#form-bottom .list {
				font-size:13px;
				color: #7C7C7C;
			}

			.message-area {
				color: #009739;
				font-size: 14px;
				font-weight: bold;
				margin: auto;
				text-align: center;
			}
			.err-message {
				color: red;
			}
		
		
			/* Section headers have blue dot, name, then horizontal line */
			.areaHeader {
				overflow: hidden;
				font-size:14px;
				font-weight: normal;
				margin-bottom: 5px;
			}
			.areaHeader:before {
				/* blue dot */
				content: "";
				display: block;
				background: #222A97;
				width: 9px;
				height: 9px;
				border-radius: 50%;
				float: left;
				margin: 1px 6px 0 5px;
			}
			.areaHeader:after {
				/* h line */
				display: inline-block;
				position: relative;
				vertical-align: middle;
				margin-left: 6px;
				height: 1px;
				content: "";
				text-shadow: none;
				background-color: #d8d9dd;
				margin-right: -100%;
				width: 90%; 
			}

			.areaContents-split {
				display: grid;
				grid-template-columns: 1fr 1fr;
				grid-template-rows: 1fr 1fr;
				gap: 15px 10px;

				padding: 0 10px 10px 20px;
			}

			.buttonArea {
				padding-top: 20px;
				text-align:center;
			}
		
		</style>
	</head>
	
	<body>
	<cfset PageTitle="Double Dip Report">
	
	<!--- Title bar --->
	<cfinclude template="/settings/settings_title.cfm">
	
	<cfset jQueryUI.widgets = "datepicker">
	<cf_include files=#arrayToList( [ "/common_files/jQuery.cfm",
									"/common_files/jQueryUI.cfm",
									"/styles/font-awesome.min.css",
									"/common_files/noty.cfm"
									] )#>

	<cfset qGetDropDownRows = BBDblDipReportMgr.getDropDownRows() />
	<cfif isDefined("URL.lockUnlock")>
		<!--- 1 = lock; 0 = unlock --->
		<cfif URL.lockUnlock>
			<cfset temp = BBDblDipReportMgr.lockDblDipRpt(request.accessstructure.user_ID) />
		<cfelse>
			<cfset temp = BBDblDipReportMgr.unlockDblDipRpt() />
		</cfif>
	</cfif>
	
	<!--- Show lock/unlock button --->
	<cfinclude template="dblDipRpt_Lock_Unlock.cfm" />
	<cfoutput> 
	
	<!--- Main FORM --->
	<form name="frmDblDipRpt" id="frmDblDipRpt" action="index.cfm" method="post">
	
		<!--- Message areas --->
		<cfif (isDefined("qGetReportHistoryID") AND qGetReportHistoryID.savedExclusion NEQ "")> 
			<div id="formMsgArea" class="message-area">
				<cfoutput>
					<cfif (qGetReportHistoryID.savedExclusion EQ "Program")>
						Program exclusions were successfully saved.
					<cfelseif (qGetReportHistoryID.savedExclusion EQ "Operator")>
						Operator exclusions were successfully saved.	
					<cfelse>
						Program & Operator exclusions were successfully saved.
					</cfif>
				</cfoutput>
			</div>
			<br>
		</cfif>
		<cfif displayErrorMessage NEQ "">
			<div id="formErrorArea" class="message-area err-message">
				<cfoutput>
					#displayErrorMessage#
				</cfoutput>
			</div>
		</cfif>
	
		<!--- User input area --->
		<div id="form-top">
			<!--- Row 1 --->
			<label for="ReportDate">Date:</label>
			<input name="ReportDate" id="ReportDate" type="text" class="date small" <cfif FORM.ReportDate NEQ ''>value="#FORM.ReportDate#"</cfif>
				style="margin-right:14px;" />

			<!--- For info, show them the date range chosen --->
			<div class="info" id="dateRange">#DateFormat(dateAdd('d', -90, FORM.ReportDate), 'mm/dd/yyyy')# - #FORM.ReportDate#</div>
			<!--- Or empty third column --->
			<!--- <div></div> --->

	
			<!--- Row 2 --->
			<label>Report Type:</label>
	
			<!--- If there is more than one type, let user choose via drop-down, otherwise use the only type --->

			<!--- Drop-down --->
			<cfif (qGetDropDownRows.recordCount GTE 2 OR qGetDropDownRows.recordCount EQ 0 )>
				<select name="ReportType" id="ReportType" size="1" class=""  onkeydown="if (event.keyCode == 13) getHistory(this.value,'1');">
					<option value="0">Select Type</option>
					<cfloop query="qGetDropDownRows">
						<option value="#Dropdown_value#" <cfif FORM.ReportType EQ Dropdown_value>selected</cfif>>#Dropdown_value#</option>
					</cfloop>
				</select>

			<cfelse>
				<div id = "reportTypeLabel"></div>	<!--- show report type string via js --->
				<input type="hidden" name="ReportType" value="#qGetDropDownRows.Dropdown_value#">	
			</cfif>
			<span class="optional info" id = "reportTypeInfo"></span>	<!--- show report type info string via js --->

		<!--- Row 3 --->
			<label for="OverlapDays" class="optional prg_opr">Overlap:</label>
			<div class="optional prg_opr">
				<input type="text" name="OverlapDays" id="OverlapDays" maxlength="4" size="4" style="margin-right:3px; width:40px;" <cfif FORM.OverlapDays NEQ ''>value="#FORM.OverlapDays#"</cfif>>
				days
			</div>
		</div>

		<br>

		<!--- Exclusion section - only used for prg_opr type --->
		<div id="form-bottom" class="optional prg_opr">
			<span class="areaHeader">EXCLUSIONS</span>
			<div class="areaContents-split">

				<div id="xPrograms">
					<div class="group">
						Excluded Programs
						<cfif variables.inEditMode EQ 1>
							<button type="button" id="selPrograms" title="" onclick="SearchPrograms();" class="button">Select</button>
						<cfelse>
							<button type="button" id="selPrograms" title="" onclick="SearchPrograms();" class="button disabled">Select</button>
						</cfif>
					</div>
					<div class="list">
						<cfset prgCurrentList = BBDblDipReportMgr.getExclusionList('PROG') />
						<cfset prgCurrentIDs = BBDblDipReportMgr.getProgramExclusionListIDs() />
						<input type="hidden" name="Program_List" id ="Program_List" value="#ValueList(prgCurrentList.value)#" />
		
						<input type="hidden" name="ProgramCurrentIDsList" id ="ProgramCurrentIDsList" value="#ValueList(prgCurrentIDs.Contract_Main_ID)#" />
						<cfif (isDefined("FORM.Program_IDs_List") AND FORM.Program_IDs_List NEQ "")>
							<cfset prgIDList = FORM.Program_IDs_List />
						<cfelse>
							<cfset prgIDList = ValueList(prgCurrentIDs.Contract_Main_ID) />
						</cfif>
						<input type="hidden" name="Program_IDs_List" id ="Program_IDs_List" value="#prgIDList#" />
						<cfset prgNewlist = "" />
	
						<cfloop query="prgCurrentList">
							<nobr>#Value#;&nbsp;</nobr>
						</cfloop>
					</div>
				</div>
				<cfif (isDefined("FORM.newPrgIDs") AND FORM.newPrgIDs NEQ "")>
					<cfset prgIDList = FORM.newPrgIDs />
				</cfif>


				<div id="xOperators">
					<div class="group">
						Excluded Operators
						<cfif variables.inEditMode EQ 1>
							<button type="button" id="selOperators" title="" onclick="SearchOperators();" class="button">Select</button>
						<cfelse>
							<button type="button" id="selOperators" title="" onclick="SearchOperators();" class="button disabled">Select</button>
						</cfif>
					</div>
					<div class="list">
						<cfset oprCurrentList = BBDblDipReportMgr.getExclusionList('OPER') />
						<cfset oprCurrentIDs = BBDblDipReportMgr.getOperatorExclusionListIDs() />
						<input type="hidden" name="OperatorCurrentIDsList" id ="OperatorCurrentIDsList" value="#ValueList(oprCurrentIDs.BSA_Operator_ID)#" />
						<cfif (isDefined("FORM.Operator_List") AND FORM.Operator_List NEQ "")>
							<cfset oprIDList = FORM.Operator_List />
						<cfelse>
							<cfset oprIDList = ValueList(oprCurrentIDs.BSA_Operator_ID) />
						</cfif>
						<input type="hidden" name="Operator_List" id ="Operator_List" value="#ValueList(oprCurrentIDs.BSA_Operator_ID)#" />
	
						<cfloop query="oprCurrentList">
							<nobr>#Value#;&nbsp;</nobr>
						</cfloop>
						<input type="hidden" name="Opr_List" id ="Opr_List" value="#ValueList(oprCurrentList.value)#" /><br>
	
					</div>
				</div>
				<cfif (isDefined("FORM.newOprIDs") AND FORM.newOprIDs NEQ "")>
					<cfset OprIDList = FORM.newOprIDs />
				</cfif>

				<!--- New Excluded Lists --->
				<div id="xProgramsNew optional prg_opr">
					<cfif ( Compare(ValueList(prgCurrentIDs.Contract_Main_ID),prgIDList) NEQ "0" AND (FORM.submitSource NEQ "Self" AND JustSaved EQ "0")) >
						<div class="group">
							New Excluded Programs
						</div>
						<cfset newPrgList = BBDblDipReportMgr.getProgramExclusionList(prgIDList) />

						<div class="list">
							<cfloop query="newPrgList">
								<nobr>#Contract_Number#;&nbsp;</nobr>
							</cfloop>
						</div>
						<input type="hidden" name="newPrgIDs" id = "newPrgIDs" value= "#prgIDList#" />
					<cfelse>
						<div></div><div></div>
					</cfif>
				</div>


				<div id="xOperatorsNew optional prg_opr">
					<cfif ( Compare(ValueList(oprCurrentIDs.BSA_Operator_ID),OprIDList)neq "0" AND (FORM.submitSource NEQ "Self" AND JustSaved EQ "0"))>
						<div class="group">
							New Excluded Operators
						</div>
						<cfset newOprList = BBDblDipReportMgr.getOperatorExclusionList(OprIDList) />

						<div class="list">
							<cfloop query="newOprList">
								<nobr>#Legacy_ID#;&nbsp;</nobr> 
							</cfloop>
						</div>
						<input type="hidden" name="newOprIDs" id = "newOprIDs" value= "#OprIDList#" />
					<cfelse>
						<div></div><div></div>
					</cfif>
				</div>
			</div> <!--- end of areaContents-split --->
		</div> <!--- end "form-bottom" --->
	
		<!--- Buttons near bottom of page --->
		<div class="buttonArea">
			<cfif (variables.inEditMode EQ 1) AND (variables.processing NEQ 0)>
				<img src="/images/loading_red.gif">In Progress...  please close this window and try again later...</font>
			</cfif>
			<cfif (variables.processing EQ 0)>
				<cfif (variables.inEditMode EQ 0)>
					<button class="button recommended disabled" onClick="ValidateReportForm();">Generate Report</button>
				<cfelse>
					<button class="button recommended" onClick="ValidateReportForm();">Generate Report</button>
					<button class="button recommended optional prg_opr" onClick="SaveExclusionLists();">Save Exclusion Lists</button>
				</cfif>
			</cfif>
	
			<button class="button" onclick="javascript:window.close()"; title="Quit and discard any unsaved changes">Cancel</button>
	
		</div>
	
	
		<input type="hidden" name="submitted" id ="submitted" value="1" />
		<input type="hidden" name="submitSource" id ="submitSource" value="0" />
		<input type="hidden" name="FilterSearchPrograms" id="FilterSearchPrograms" value="" />
		<input type="hidden" name="actionsToDo" id="actionsToDo" value="" />
	</form>
	
	  
	</cfoutput>
	
	<script>	
		function ValidateReportForm()
		{
			errorMessage = ""
			if (frmDblDipRpt.ReportDate.value == '')
			{
				errorMessage = errorMessage.concat('Please select a Date\n');
			}
			<cfif (qGetDropDownRows.recordCount GTE 2 OR qGetDropDownRows.recordCount EQ 0)> 
			if (frmDblDipRpt.ReportType.options[frmDblDipRpt.ReportType.selectedIndex].value == '0')
			{
				errorMessage = errorMessage.concat('Please select a Report Type to generate\n');
			}
			</cfif> 
			if(errorMessage != "")
			{
				noty_error(errorMessage);
			}
			else
			{
				document.frmDblDipRpt.submitSource.value = 'self';
				document.frmDblDipRpt.actionsToDo.value = 'SaveAndGenerate'
				document.frmDblDipRpt.submit();
				show_loader( "Generating Report, Please Wait...");
			}
			return;
		}
	
		function SaveExclusionLists()
		{
			document.frmDblDipRpt.submitSource.value = 'self';
			document.frmDblDipRpt.actionsToDo.value = 'SaveOnly'
	
			document.frmDblDipRpt.submit();
			show_loader( "Saving Changes, Please Wait...");
		}
	
		$( function() {
			$("#ReportDate").datepicker({
				dateFormat: "mm/dd/yy",
				changeMonth: true,
				changeYear: true
			}).on("input change", function (e) {
					// Display the updated report date range
					let newChosen  = new Date(e.target.value);
					let newStart = new Date(e.target.value);
					newStart.setDate(newStart.getDate() -90 );
					let startMonth = newStart.getMonth();
					startMonth++;	// month is zero based (Jan = 0)!
					let newStartString = startMonth +"/"+ newStart.getDate() +"/"+ newStart.getFullYear();
					$("#dateRange").html(newStartString +" - " +e.target.value);
				});
		} );
		
		$(document).ready(function(){

			$("#ReportType").change(function(){
				$( "#ReportType option:selected").each(function(){
					setupReportType ( $(this).attr("value") );

					if($(this).attr("value")=="3rd Party"){
						$(".optional").hide();
						$(".prg_opr").show();
					}
					else if($(this).attr("value")=="SYSCO"){
						$(".optional").hide();
						$(".sysco").show();
					}
					else if($(this).attr("value")=="USFS"){
						$(".optional").hide();
						$(".usfs").show();
					}
					else {
						$(".optional").hide();
					}
				 });
			}).change();


			// Initial setup on page load
			// If only one Report Type, set it instead of using the drop-down
			if ( (<cfoutput>#qGetDropDownRows.recordCount#</cfoutput> == 1) &&  (<cfoutput>"#qGetDropDownRows.Dropdown_value#"</cfoutput> == 'SYSCO') ) {
				$("#reportTypeLabel").text("SYSCO");
				setupReportType("SYSCO");
			}
			else if ( (<cfoutput>#qGetDropDownRows.recordCount#</cfoutput> == 1) &&  (<cfoutput>"#qGetDropDownRows.Dropdown_value#"</cfoutput> == "USFS") ) {
				$("#reportTypeLabel").text("USFS");
				setupReportType("USFS");
			}
			else if ( (<cfoutput>#qGetDropDownRows.recordCount#</cfoutput> == 1) &&  (<cfoutput>"#qGetDropDownRows.Dropdown_value#"</cfoutput> == "3rd Party") ) {
				$("#reportTypeLabel").text("3rd Party");
				setupReportType("3rd Party");
			}
			else {
				$("#reportTypeLabel").text("");
				setupReportType("");
			}

		});

		function setupReportType (reportType) {
			const sDefaultTitle = "The report will include billbacks with a received date as of the date entered and 90 days prior.";

			switch (reportType) {
				case "3rd Party" : 
					$("#ReportDate").prop('title', "The report will include billbacks with an approval date as of the date entered and 90 days prior");
					$("#OverlapDays").prop('title', "By default the report includes billbacks that have at least one overlapping date. You can change the overlap days to be a value greater than 1.");
					$("#reportTypeInfo").text("The Double Dip Report will include records where two or more detail records share the same Operator Location ID, Item ID, Distributor ID, have at least one overlapping date from the POD range and two or more different programs are involved.");
					break;
				case "SYSCO" :
					$("#ReportDate").prop('title', sDefaultTitle);
					$("#reportTypeInfo").text("The Double Dip Report will include records where two or more detail records share the same Operator Location ID, Invoice ##, Item ID, Distributor ID, Quantity, have at least one overlapping date from the POD range and two or more different programs are involved.");
					break;
				case "USFS" :
					$("#ReportDate").prop('title', sDefaultTitle);
					$("#reportTypeInfo").text("The Double Dip Report will include records where two or more detail records share the same Operator Location ID, Operator Location Ship Date, Item ID, Corporate Distributor ID,  have at least one overlapping date from the POD range and two or more different programs are involved.");
					break;
				default :
					$("#ReportDate").prop('title',"");
					$("#reportTypeInfo").text("");
			}
		}

	
		function SearchPrograms() 
		{
			$("#Program_IDs_List").val($("#Program_IDs_List").val()); 
			document.frmDblDipRpt.submitSource.value = '';
			NewWindow("/billbacks/search_screens/search_programs.cfm?Formname=frmDblDipRpt&fieldname=Program_IDs_List&SelectSingleSearchResultOnly=0&AllowImportAll=1", "ProgramsWindow", 800, 600, "yes", "yes")
			// NewWindow("/programs/program_search.cfm?Include_work_in_progress_below_me=1&importlist_type=1&Formname=frmDblDipRpt&Fieldname=Contract_Number&ReturnFieldname=Program_IDs_List&AllowImportAll=1&Disable_Locked=1&Display_Deleted_Programs=0&reassign_type=2", 'pro_search', '1000', '600', 'Yes', 'Yes', 'Yes', 'Yes', 'Yes','Yes', true);
			// scorecard_status=3,5,6,7,8& &userid=<cfoutput>#cookie.user_id#</cfoutput>
		}
	
		function SearchOperators() 
		{
	
			$("#Program_IDs_List").val($("#Program_IDs_List").val()); 
			document.frmDblDipRpt.submitSource.value = '';
			NewWindow("/billbacks/search_screens/PM_select_operators.cfm?Formname=frmDblDipRpt&SelectSingleSearchResultOnly=0", "OperatorWindow", 800, 600, "yes", "yes")
		}
	
		function noty_error (sMsg) {
			noty({
				text: sMsg,
				layout: "center", type: "error", timeout: 5000, killer: true,
				animation: { open: { height: 'toggle' }, close: { height: 'toggle' }, easing: 'swing', speed: 50 }
			});
		}
	
	</script>
	
	<cfif filedownloadpath neq "">
		<cfoutput>
			<script>
				NewWindow("/getDocument.cfm?filePath=#filedownloadpath#", "downloadWindow", 400, 300, "yes", "yes")
			</script>			
		</cfoutput>	
	</cfif>
	
	</body>
	</html>
	