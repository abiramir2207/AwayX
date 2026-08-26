<!DOCTYPE HTML>
<html lang="en">
<head>
<title>Blended Rates Report</title>
<link rel="stylesheet" href="/styles/jQueryUI_18/smoothness/jquery-ui-1.8.22.custom.css" type="text/css" />
</head>

<body>
<cfoutput>
<div style="width:100%;background-color:##FFCE84;border-top:1px solid black;border-bottom:1px solid black;height:14px;font-size:13px;">		
	<label style="font-weight:bold;">Blended Rates Report:</label>
</div>

<cfoutput> 
<cfif IsDefined("URL.CID")>
	<cf_cryp type="de" string ="#URL.CID#" key="#request.key#">
	<cfset form.Contract_Main_ID = cryp.value>
	<cfset form.frmCID = URL.CID>
</cfif>

<cfparam name="form.Contract_Main_ID" default="">
<cfparam name="form.frmCID" default="">
<cfparam name="form.generateReport" default="0">
<cfparam name="form.delivery_start_Date" default="">
<cfparam name="form.delivery_end_Date" default="">

<cfset objGeneralFunctions = CreateObject("component","components.general.General_Functions")>

<cfquery name="getContractInfo" datasource="#application.datasource#">
SELECT CONVERT(char(10),Min(Effective_Start_Date),101) As Contract_Start_Date
FROM Contract_Main
WHERE Contract_Number = 
(
SELECT Contract_Number
FROM Contract_Main
WHERE Contract_Main_ID = <cfqueryparam value="#form.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">
)
AND Effective_Start_Date is NOT NULL
</cfquery>

<!--- If the user clicked on "generate report" --->
<cfif form.generateReport eq 1>
	<CFSTOREDPROC PROCEDURE="Blended_Rate_Extract" datasource="#application.datasource#">
		<CFPROCPARAM TYPE="IN" CFSQLType="CF_SQL_INTEGER" DBVARNAME="@Contract_Main_Id" VALUE="#form.Contract_Main_ID#">
		<CFPROCPARAM TYPE="IN" CFSQLType="CF_SQL_DATE" DBVARNAME="@Start_Date" VALUE="#form.delivery_start_Date#">
		<CFPROCPARAM TYPE="IN" CFSQLType="CF_SQL_DATE" DBVARNAME="@End_Date" VALUE="#form.delivery_end_Date#">
		
		<!--- There are multiple data sets returned from the SP. --->
		<CFPROCRESULT NAME="ItemLevel" RESULTSET="1">
		<CFPROCRESULT NAME="TypeCodeLevel" RESULTSET="2">
		<CFPROCRESULT NAME="PlanningGroupLevel" RESULTSET="3">
		<CFPROCRESULT NAME="RecaptureDetails" RESULTSET="4">
	</CFSTOREDPROC>
	
	<!--- If there is data --->
	<cfif ItemLevel.recordcount neq 0 
		or TypeCodeLevel.recordcount neq 0 
		or PlanningGroupLevel.recordcount neq 0
		or RecaptureDetails.recordcount neq 0
	>
	
	<!--- Initialize spreadsheet object --->
	<cfset ItemLevelSheet = SpreadsheetNew("ITEMLEVEL","yes")>
	
	<!--- Initialize an array to store column numbers to be converted to "text". --->
	<cfset arrColumnNumbersToFormatAsText = ArrayNew(1)>

	<!--- Column Numbers --->
	<cfset ArrayAppend(arrColumnNumbersToFormatAsText, 3)>
	
	<!--- Call function to format column(s) as text. --->
	<cfset objGeneralFunctions.spreadsheetAddRowsForceTextFormat(ItemLevelSheet,ItemLevel,arrColumnNumbersToFormatAsText)>
	
	<cfset file_name = "blendedRates_#DateFormat(now(),'mmddyyyy')#_#TimeFormat(now(),'hhmmss')#.xlsx">
	<!--- <cfset file_path = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_Doc\#file_name#"> --->
	<cfset file_path = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_Doc\#file_name#">
	
	<!--- write the excel file (Item Level data).--->
	<cfspreadsheet  
	    action="write" 
	    filename = "#file_path#"
	    <!--- For this sheet, the data was modified above (convert datatype to "text") and so the data comes
	    from a sheet ("ItemLevelSheet") and not a query.
	    --->
	    name ="ItemLevelSheet"
	    sheetname = "ITEM LEVEL">

		
	<!--- update the excel file with the second sheet (Type Code data).--->
	<cfspreadsheet  
	    action="update" 
	    filename = "#file_path#"
	    query = "TypeCodeLevel" 
	    sheetname = "FPL LEVEL">

	<!--- update the excel file with the third sheet (Planning Group level data).--->

	<cfspreadsheet  
	    action="update" 
	    filename = "#file_path#"
	    query = "PlanningGroupLevel" 
	    sheetname = "PLANNING GROUP LEVEL">  

		 <cfif (RecaptureDetails.RecordCount LTE 65534)>
		<!--- <cfif (RecaptureDetails.RecordCount LTE 300)>	 --->
			<!--- update the excel file with the fourth sheet (Recapture Details data).--->
			<cfspreadsheet  
			    action="update" 
			    filename = "#file_path#"
			    query = "RecaptureDetails" 
			    sheetname = "Recapture Details">
			
			<!--- Open the Excel File --->
			<cfheader name="Content-Disposition" value="attachment; filename=#file_name#" >
			<cfcontent type="application/vnd.ms-excel" file="#file_path#">
			
		<cfelse>
		
		 	<cfset file_name_recapDet = "blendedRates_Recapture_Details_#DateFormat(now(),'mmddyyyy')#_#TimeFormat(now(),'hhmmss')#.csv">
			<cfset file_path_recapDet = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_Doc\#file_name_recapDet#">
		
			<cfset fileOutput= CreateObject("java","java.lang.StringBuffer").Init() >  
 			
			<cfloop list="#ArrayToList(RecaptureDetails.getColumnNames())#" index="col" >
				<cfset fileOutput.append("#col#" & ",")>
			</cfloop>
				<cfset fileOutput.append(Chr(13) & Chr(10))>
				<cfset qryResult = RecaptureDetails />
				<cfloop query="qryResult">
					<cfloop list="#ArrayToList(RecaptureDetails.getColumnNames())#" index="col">
						<cfset fileOutput.append("#qryResult[col][currentRow]#" & ",")>
				</cfloop>  
				<cfset fileOutput.append(Chr(13) & Chr(10))>
			</cfloop>		
		
			<cffile action="write" file="#file_path_recapDet#" output="#fileOutput.ToString()#" >			
			<br>
			<br>
			<b><font color="Red">[</font>&nbsp;<a href="/GetDocument.cfm?FilePath=/common_documents/Temp_Files/Documents/Temp_Uploaded_Doc/#file_name#">Download Item/FPL/Planning Group Details</a>&nbsp;<font color="Red">]</font></b>
			<b><font color="Red">[</font>&nbsp;<a href="/GetDocument.cfm?FilePath=/common_documents/Temp_Files/Documents/Temp_Uploaded_Doc/#file_name_recapDet#">Download Recapture Details</a>&nbsp;<font color="Red">]</font></b>
			<b><font color="Red">[</font>&nbsp;<a href="blendedRateFrm.cfm?CID=#form.frmCID#">Return to Search</a>&nbsp;<font color="Red">]</font></b>
			<b><font color="Red">[</font>&nbsp;<a href="javascript:window.close()">Close Window</a>&nbsp;<font color="Red">]</font></b>
			<br>
			<br>
			<cfabort>	
					
		</cfif>		 
	<cfelse>
	<div style="width:100%;font-size:16px;font-weight:bold;color:red;text-align:center;">No Data</div>
	</cfif>
</cfif>

<form action="blendedRateFrm.cfm" name="frmBlendedRate" method="post">

<div style="margin-top:10px;">
	<label style="font-weight:bold;">From:</label>
	<input type="text" name="delivery_start_Date" id="delivery_start_Date" value="#form.delivery_start_Date#" style="margin-left:7px;width:100px;font-size:1.1em;">
	<label style="margin-left:10px;font-weight:bold;">To:</label>
	<input type="text" name="delivery_end_Date" id="delivery_end_Date" value="#form.delivery_start_Date#" style="margin-left:7px;width:100px;font-size:1.1em;">

</div>

<div style="margin-top:10px;" id="divActiveLink">
	<a href="javascript:void();" onClick="fngenerateReport();">#application.util.string.actionLinkFormat("generate report")#</a>
</div>
<div style="margin-top:10px;display:none;" id="divInactiveLink">
<!--- #application.util.string.actionLinkFormat("generate report")# --->
	<b><font color="Red">[</font>&nbsp;<font color="grey">generate report</font>&nbsp;<font color="Red">]</font></b><br>
	<font color="grey"><img src="/images/loading_red.gif"> processing...</font>
</div>

<input type="hidden" name="generateReport" value="1">
<input type="hidden" name="Contract_Main_ID" value="#Contract_Main_ID#">
<input type="hidden" name="frmCID" value="#form.frmCID#">
<input type="hidden" name="ContractStartDate" id="ContractStartDate" value="#getContractInfo.Contract_Start_Date#">
</cfoutput>
<br> 
</form>

<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/script/javascript/ajax_js/jqueryui-1.8.10.min.js"></script>

<!--- code for date picker. --->
<script type="text/javascript">
  $('##delivery_start_Date').datepicker({
			changeMonth: true
			,changeYear: false
			,showButtonPanel: true
  });
  $('##delivery_end_Date').datepicker({
			changeMonth: true
			,changeYear: false
			,showButtonPanel: true
  });

  function fngenerateReport()
  {	
	var errCount = 0;
	var start_date = document.getElementById('delivery_start_Date').value;
	var end_date = document.getElementById('delivery_end_Date').value;
	
	if(start_date == '' || end_date == '') 
	{	errCount = errCount + 1;
		alert('please enter a start date and an end date.');
	}
	else{

		var dt_start_date = new Date(start_date);
		var dt_end_date = new Date(end_date);

		var contract_start_date = new Date(document.getElementById('ContractStartDate').value);
		var dt_contract_start_date = new Date(contract_start_date.getFullYear(), contract_start_date.getMonth(),contract_start_date.getDate())

		if(dt_start_date > dt_end_date){
			errCount = errCount + 1;
			alert('End Date must be after the Start Date');
		}

		if(errCount == 0){
			document.getElementById('divActiveLink').style.display='none';
			document.getElementById('divInactiveLink').style.display='block';
			frmBlendedRate.submit();
		}
	}
  }
</script>
</cfoutput>
</body>
</html>