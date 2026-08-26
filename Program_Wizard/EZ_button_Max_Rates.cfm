<!---
	Copyright (c)2013 Blacksmith Applications, Inc.
	Filename:		AwayX\Program_Wizard\EZ_button_Max_Rates.cfm
	Created:		04/08/2013
	Developer:		Anand Rao
	Description:	Creates a cfspreadsheet and shows a download popup window for the user to download.
--->
<cfparam name="url.TemplateID" default="0">
	<cfstoredproc procedure="EzButton_Max_Rates_Report" datasource="#application.datasource#">
		<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@@Template_ID" value="#url.TemplateID#" null="no">
		<cfprocresult name = "EZInfo">
	</cfstoredproc>

 <cfquery name="TemplateInfo" datasource="#application.datasource#">
	SELECT Created_Type
	FROM Program_Control_Panel_Options
	WHERE ProgramControl_Panel_Options_ID = #url.TemplateID#
</cfquery>

	<cfscript>
	    //Use an absolute path for the files.
	    FileName = "MaxRates_" &  application.util.io.filterFilename( TemplateInfo.Created_Type ) & ".xls";
	    donwloadfilepath = application.Doc_Path & "\Temp_Files\settings\" & FileName; //AutoPayReport\
		//Create empty ColdFusion spreadsheet object
	  	theSheet = SpreadsheetNew("ProgramRateGreaterThanTheMaxRate");
		headerRow ="Contract_Number,Contract_Title,Template_Name,RSP,Approved_By,Approval_Date,Contract_Start_Date,Contract_End_Date,Item,Program_Rate,Max_Rate,UOM";
	    //Populate object with query.
	    SpreadsheetAddRows(theSheet,EZInfo);
	    //Insert header row
	    SpreadsheetAddRow(theSheet,headerRow,1,1);
		SpreadsheetFormatRow(theSheet, {bold=TRUE, alignment="left"}, 1);
	</cfscript>
	<cfspreadsheet action="write" filename="#donwloadfilepath#" name="theSheet"
	    sheetname="Prg Rate greater than Max Rate" overwrite=true>

	<cfheader name="Content-Disposition" value="attachment; filename=#FileName#" >
	<cfcontent type="application/vnd.ms-excel" file="#donwloadfilepath#">

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