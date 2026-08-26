<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/Settings/ReportIndex.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  23-Aug-17
Created By   :  Anand Rao
Description  :  Displays fields for CIA Usage Report.
---------------------------------------------------------------------------------->

<cfparam name="FORM.From_Date" default="">
<cfparam name="FORM.To_Date" default="">
<cfparam name="FORM.selSource" default="">
<cfparam name="FORM.selType" default="">
<cfparam name="FORM.Submitted" default="0">
<cfset nothingToDownload = 0 />

<cfif (isDefined("FORM.From_Date") AND FORM.From_Date NEQ "" AND  isDefined("FORM.To_Date") AND FORM.To_Date NEQ "" AND FORM.Submitted EQ "1")>
		<cfif FORM.selSource EQ "">
			<cfset selSourceNull = "YES" />
		<cfelse>
			<cfset selSourceNull = "NO" />
		</cfif>
		<cfif FORM.selType EQ "">
			<cfset selTypeNull = "YES" />
		<cfelse>
			<cfset selTypeNull = "NO" />
		</cfif>
		<cfstoredproc datasource="#application.datasource#" procedure="OCR_Upload_Audit_Report">
			<cfprocparam type="IN"  dbVarName="@Upload_Start_Date"	value="#FORM.From_Date#"  CFSQLType="CF_SQL_DATE">
			<cfprocparam type="IN"  dbVarName="@Upload_End_Date"	value="#FORM.To_Date#"  CFSQLType="CF_SQL_DATE">
			<cfprocparam type="IN"  dbVarName="@Source" value="#FORM.selSource#" cfsqltype="CF_SQL_INTEGER" null="#selSourceNull#">
			<cfprocparam type="IN"  dbVarName="@TYPE" value="#FORM.selType#" cfsqltype="CF_SQL_INTEGER" null="#selTypeNull#"> 				
			<cfprocresult name = "OCRUploadAuditReport" > <!--- Original result set that returns status etc --->
	 	</cfstoredproc>
 	 	<cfif (OCRUploadAuditReport.RecordCount GTE 1)>
		 	<cfscript> 
	    		//Use an absolute path for the files.
	    		FileName = "OCR_Upload_Audit_From_#application.datasource#_#DateFormat(now(), 'mmddyyyy')#.xls";
						
	    		donwloadfilepath = application.Doc_Path & "\Data_Files\Created\OCR_Download\" & FileName; 
				//Create empty ColdFusion spreadsheet object 
	  			theSheet = SpreadsheetNew("OCRUpload_Audit_Report");
				headerRow ="OCR_Code,File_Extension,Created_By,File_Size,OCR_Amount,Start_Datetime,Updated_Date,Number_Of_Invoices,Number_Of_Billbacks,Number_Of_Line_Items,Pages_Extracted,Was_Alias_Fixed,Amount_From_File,OCR_Upload_ID,Source Code, Debug_Dev_Status, Server Name, Client_DB_Name, Environment, IP";
		    //Populate object with query.
		    SpreadsheetAddRows(theSheet,OCRUploadAuditReport);
		    //Insert header row
		    SpreadsheetAddRow(theSheet,headerRow,1,1); 
			SpreadsheetFormatRow(theSheet, {bold=TRUE, alignment="left"}, 1);
			</cfscript> 
			<cfdump var="#donwloadfilepath#"/>
			<cfspreadsheet action="write" filename="#donwloadfilepath#" name="theSheet" sheetname="OCR Upload Audit Report" overwrite=true>
			<cfheader name="Content-Disposition" value="attachment; filename=#FileName#" >
			<cfcontent type="application/vnd.ms-excel" file="#donwloadfilepath#">
		<cfelse>
			<cfset nothingToDownload = 1 />
		</cfif>  <!--- END: <cfif (OCRUploadAuditReport.RecordCount GTE 1)> --->
</cfif> <!---  END: <cfif (isDefined("FORM.From_Date") AND FORM.From_Date NEQ "" AND  isDefined("FORM.To_Date") AND FORM.To_Date NEQ "" AND FORM.Submitted EQ "1")> --->

<script language="JavaScript">
	function submitForm(submitter)
	{
		
		var thisForm 	= document.getElementById('ReportForm');
		var FromDate	= thisForm.From_Date.value;
		var ToDate 		= thisForm.To_Date.value;
		var strError 	= "";
		// var source 		= thisForm.selSource.selectedIndex;
		// var type 		= thisForm.selType.selectedIndex;
		if (FromDate == "")
		{
			strError = strError + " - Enter a From Date\n";
		} 	
		if (ToDate == "")
		{
			strError = strError + " - Enter a To Date\n";
		} 	
		if (strError == "")
		{
			thisForm.Submitted.value = "1";
			thisForm.submit();
		}
		else
		{
			strError =   "Correct the below errors:\n\n" + strError;
			alert(strError);
		}
		return false;	 
	}
</script>
<cfinclude template="/Common_Files/jQuery.cfm">
<cfset datatables.version = "1.9.3">	
	<cfset jQueryUI.widgets = "full">
	<cfinclude template="/common_files/jQueryUI.cfm">
<script src="/script/javascript/chosen/chosen.jquery.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="/styles/chosen/chosen.css">	
<style>
	.newLink:link, .newLink:visited {
	    background-color: #406BE4;
	    color: white;
	    padding: 7px 15px;
	    text-align: center;
	    text-decoration: none;
	    display: inline-block;
		border-radius: 5px;
	}
	.newLink:hover, .newLink:active { 
	    background-color: #1E4DD3;
	}	
	.dateRounded
	{
	 	-moz-border-radius: 4px !important;
		border-radius: 4px;	!important;
	 	border:solid 1px grey  	!important;
		padding:2px !important;
		font-size:14px  !important;
		width:100px  !important;
	}
</style>
<cfset URL.PageTitle="CIA Usage Report">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfinclude template="/settings/settings_title.cfm">
<cfscript>
	OCRSettingsManager  = CreateObject("component","components.Billback.OCRUploadSettingsManager");
	qGetValidSources	= OCRSettingsManager.getValidSourcesForUpload();
</cfscript>
<cfoutput>
<form id="ReportForm" name="ReportForm" method="post" action="ReportIndex.cfm"> 
<font size="2px">Choose the criteria to create a CIA Usage report.</font><br><br>

	<table cellspacing="6" cellpadding="3" border="0">
<!--- 		<tr>
			<td colspan="3">
				<font size="2px">Choose the criteria to create a CIA Usage report.</font>
			</td>
		</tr> --->
		<tr>
			<td>
				<font size="2px">From:</font><br>
				<input type="text" Name="From_Date"  class="dateRounded" value="<cfoutput>#FORM.From_Date#</cfoutput>">
			</td>
			<td valign="bottom">
				<strong>-</strong>
			</td>
			<td>
			<font size="2px">To:</font><br>
			<input type="text" Name="To_Date" class="dateRounded" value="<cfoutput>#FORM.To_Date#</cfoutput>">
			</td>
		</tr>
		<tr>
			<td colspan="3">
				<font size="2px">Source: </font><font color="grey" size="2px"><em>(optional)</em></font><br>
				<select name="selSource" id="selSource" size="3" style="width:200px" data-placeholder="Select a Source" style="z-index: 5000 !important;">
					<option value="">Select a Source</option> 
					<cfloop query="qGetValidSources">
						<option value="#qGetValidSources.BB_Claim_Source_XREF_ID#">#qGetValidSources.Source_Code#</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td colspan="3">		
				<font size="2px">Type: </font><font color="grey" size="2px"><em>(optional)</em></font><br>
				<select name="selType" id="selType" style="width:200px" data-placeholder="Select a Type" style="z-index: 5000 !important;">
					<option value="">Select a Type</option> 
				</select>
			</td>
		</tr>
		<tr>
			<td colspan="3">
				<br>
				<a href="##" onclick="javascript:submitForm(this);" class="newLink">Create Report</a>
			</td>
		</tr>
	</table>
</cfoutput>
<input type="hidden" name="Submitted" value = "1" />

<cfset jQueryUI.version = "1.8.23">
<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script>
	$(function() {
		$('input[name=From_Date]').datepicker();
		$('input[name=To_Date]').datepicker();
	});

 	$("#selSource").chosen();
  	$("#selType").chosen();
	$( "#selSource" ).change( function( ){
		$.ajax( {
			type: "POST",
			url: "/components/Billback/OCRUploadSettingsManager.cfc?method=getOCRSettingsOnXref&ReturnFormat=json",
			data: ({	BBClaimSourceXrefID: $(this).val()}),
			dataType: 'json',
			success: function(response)
			{
				$('#selType').find('option:not(:first)').remove();
				for (var i = 0; i < response.DATA.length; i++)
				{
					$('#selType').append('<option title="' + response.DATA[i][1] + '"  value="' + response.DATA[i][0] + '">' + response.DATA[i][1] + '</option>');
				}
				if (response.DATA.length == 1 )
				{
					document.getElementById('selType').getElementsByTagName('option')[1].selected = 'selected';
				}  
				$('#selType').trigger("chosen:updated");
				},
			error: function(xhr, textStatus, errorThrown){ alert('request failed');}
		});
	});	   
</script>

<cfif nothingToDownload EQ "1">
	<script type="text/javascript" src="/script/javascript/jquery.noty.packaged.min.js"></script>
	<script>
 		noty({
			text: "No records to download!!",
            layout: "center",
            type: 'success',
            timeout:3500  });
	</script>
</cfif>	

<!--- 
Noty Options for layout:
top
topLeft
topCenter
topRight
center
centerLeft
centerRight
bottom
bottomLeft
bottomCenter
bottomRight
--->