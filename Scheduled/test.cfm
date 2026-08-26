<!------ approved_billback_print.cfm ----->
<!------ 
Be careful while working with this file.
This file is very sensitive with <cfoutput>, we don't want extra characters printed
----->
<cfparam name="url.printDate" 	default="">
<cfif url.printDate NEQ "">
	<cfif NOT isDate(url.printDate)>
		<cfoutput><h2>The date is invalid '#url.printDate#'</h2></cfoutput>
		<cfabort>
	</cfif>
</cfif>
<cfquery name="getBillbacks" datasource="#application.datasource#">
	SELECT 	TOP 1 Billback.Billback_ID, Billback.BB_Title, Billback.BB_Creator_User_Position_ID, Billback.BB_Code,
			Billback_Program.Program_ID
	FROM	Billback
			INNER JOIN Billback_Allied
			ON Billback_Allied.Billback_ID = Billback.Billback_ID
			INNER JOIN Billback_Program
			ON
			Billback_Program.Deleted = 0
			AND Billback_Program.Billback_ID = Billback.Billback_ID
	WHERE	Billback.Deleted = 0
			AND Billback_Payee_Type_ID = 1
			AND Billback_Status_ID IN (4)
			<cfif url.printDate NEQ "">
			AND DateDiff(d, Billback_Allied.Pay_Print_Date, '#url.printDate#') = 0
			<cfelse>
			AND Billback_Allied.Pay_Print_Over = 0
			</cfif>
	ORDER BY Billback.BB_CODE
</cfquery>

<cfset totalCount = getBillbacks.recordCount>
<cfset url.requestFormat = "txt">
<cfset BBContents = "">

<!------ Initiate the default Printer ----->
<cfobject action = "Create"
    type = "COM"
    class = "BSAPrinter.bsaPrint"
    name = "oPrinter"> 

<cfset oPrinter.LogFilePath = "#APPLICATIONPATH#\scheduled\PrinterLog.log">

<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">
<cfif getBillbacks.recordCount GT 0>
<cfoutput><cfsavecontent variable="StartEnd"><cfinclude template="PrintBannerStart.cfm"></cfsavecontent></cfoutput>
<!------ Print first page to the printer ----->
<!------ <cfset printPage(StartEnd, 1)> ----->

<!------ <cfset NewLine = Chr(13) & Chr(10)> ----->
<cfset NewLine = "">
<cfset TotalBBContents = "">
<cfloop query="getBillbacks">
	<cfset url.billback_id = Billback_ID>
	<cfset url.program_id = Program_ID>	
	<cfset BBContents = "">
<!------ Get the file content from claim report  ----->
<!------ the <cfoutput> </cfoutput> below is intentional :) ----->
<!------ Please leave the following code AS IS ----->
<cfsavecontent variable="BBContents">
<cfoutput>Claim #currentrow# of #totalCount#
#NewLine# 
 
</cfoutput><cfinclude template="\ReportWriter\claimDetail.cfm"></cfsavecontent>
<!------ Please leave the above code AS IS ----->
	
	<cfif Len(BBContents) GT 0>
		<!------ Print the billback to the printer ----->
		<!------ <cfset printPage(BBContents, 2)> ----->		
		<cfif Len(TotalBBContents) GT 0>
			<cfset TotalBBContents = "#TotalBBContents##chr(12)#">
		</cfif>
		<cfset TotalBBContents = "#TotalBBContents##BBContents#">		
		
		<cfquery name="qSetPrintStatus" datasource="#application.datasource#">
			UPDATE	Billback_Allied SET
					Pay_Print_Over = 1,
					Pay_Print_Date = GetDate()
			WHERE	Billback_ID = '#Billback_ID#'
		</cfquery>
	</cfif>
	
		
</cfloop>
<cfoutput><pre>#TotalBBContents#</pre><hr></cfoutput>
<cfset printPage(TotalBBContents, 2, "")>

<cfoutput><cfsavecontent variable="StartEnd"><cfinclude template="PrintBannerEnd.cfm"></cfsavecontent></cfoutput>
<!------ Print last page to the printer ----->
<!------ <cfset printPage(StartEnd, 1)> ----->


<!------ check if we have to print to one more printer other than the default printer ----->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get(1, 1)>
<CFIF Len(appSettings.getPrinter2Name()) GT 0>
	<cfset printPage(TotalBBContents, 2, appSettings.getPrinter2Name())>
</CFIF>

<cfelse>
	<cfoutput><center><font color="blue"><B>No claim to print...</B></font></center></cfoutput>
</cfif>

<cfscript>

function printPage(sStr, PaperOrientation, changeToPrinter)
{
	oPrinter.PaperOrientation = PaperOrientation; //2=landscape, 1=portrait
	oPrinter.FontName = "Courier New"; // we need any fixed width font
	oPrinter.Text = sStr;
	if(len(changeToPrinter) GT 0)
	{
		oPrinter.printerName = changeToPrinter;
	}
	oPrinter.PrintNow();
}
</cfscript>

<cfsetting enablecfoutputonly="No" showdebugoutput="Yes">