<html>
<head>
<title>List of Programs with modified start date</title>
</head>

<body>

<!--- Spinner goes here --->
<cfset PW_DoNotCFFLUSH = 1/>
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<cfparam name="Contract_Main_ID_List" default="">

<cfset objProgram = CreateObject("component", "components.programs.program") />

<cfif Contract_Main_ID_List eq "">
	<!--- show the history --->
	<cfset qGetContractDateChangeHistory = objProgram.getContractDateChangeHistory(url.display_type)>
<cfelse>
	<!--- show the revisions --->
	<cfset qGetContractDateChangeHistory = objProgram.getProgramRevisions(Contract_Main_ID_List)>
</cfif>

	<cfscript> 
	    //Use an absolute path for the files.
	    FileName = "ProgramList_ModifiedStartDate.xls";
	    prgfilepath = application.Doc_Path & "\Temp_Files\Program\ProgramList_ModifiedDate_Report\" & FileName;
		//Create empty ColdFusion spreadsheet object 
	    theSheet = SpreadsheetNew("ProgramListData");
	    headerRow ="Status,Program,Template,Title,Start Date,End Date,Effective Start date,Effective End Date,RSP";
	    //Populate object with query.
	    SpreadsheetAddRows(theSheet,qGetContractDateChangeHistory);
	    //Insert header row
	    SpreadsheetAddRow(theSheet,headerRow,1,1); 
	</cfscript> 

	<!--- Write the two sheets to a single file ---> 
	<cfspreadsheet action="write" filename="#prgfilepath#" name="theSheet"
		sheetname="programList" overwrite="true">

	<cfheader name="Content-Disposition" value="attachment; filename=#FileName#" >
	<cfcontent type="application/vnd.ms-excel" file="#prgfilepath#">

<!--- Get rid of spinner --->
<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';

function downloadDoc(documentLocation)
{
	setInterval(function(){window.close},1);
	document.location = documentLocation;
	window.close;
}
</SCRIPT>

</body>
</html>



