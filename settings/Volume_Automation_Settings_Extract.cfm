<!---
	Copyright (c)2013 Blacksmith Applications, Inc.
	Filename:		AwayX\settings\Volume_Automation_Settings_Extract.cfm
	Created:		04/08/2013
	Developer:		Anand Rao
	Description:	Creates a cfspreadsheet and shows a download popup window for the user to download.
--->
 
		
 <cfquery name="VolumeAutomationInfo" datasource="#application.datasource#">
	SELECT  t.Created_Type,
            CASE ISNULL(t.Auto_Volume, 0) WHEN 0 THEN 'Off' ELSE 'On' END as Automate_Volume,
            t.Auto_Actual as [Weeks after start date to update actual],
            t.Auto_Future as [Weeks after start date to automate future volume],
            t.Future_Zero as [Weeks before end date to set future volume to zero],
            t.Clear_Lumpsum as [Days after expiration to clear open lump sums]
	FROM  Program_Control_Panel_Options t
	WHERE t.IsDominant = 1
	ORDER BY t.Created_Type
</cfquery>
	<cfscript> 
	    //Use an absolute path for the files.
	    FileName = "Volume_Automation_Settings_Extract.xls";
	    donwloadfilepath = application.Doc_Path & "\Temp_Files\settings\" & FileName; 
		//Create empty ColdFusion spreadsheet object 
	  	theSheet = SpreadsheetNew("VolumeAutomationSettingsExtract");
		headerRow ="Template Name,Automate Volume,Weeks after start date to update actual,Weeks after start date to automate future volume,Weeks before end date to set future volume to zero,Days after expiration to clear open lump sums";
	    //Populate object with query.
	    SpreadsheetAddRows(theSheet,VolumeAutomationInfo);
	    //Insert header row
	    SpreadsheetAddRow(theSheet,headerRow,1,1); 
		SpreadsheetFormatRow(theSheet, {bold=TRUE, alignment="left"}, 1);
	</cfscript> 
	<cfspreadsheet action="write" filename="#donwloadfilepath#" name="theSheet" sheetname="Volume Automation Settings Extract" overwrite=true>
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
