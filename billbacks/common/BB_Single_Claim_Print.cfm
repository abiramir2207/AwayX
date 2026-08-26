<!DOCTYPE HTML>
<html>
<head>
	<title>Claim Detail Report</title>
</head>
<body>
<cfsetting enablecfoutputonly=true>
<!------ BB_Single_Claim_Print.cfm ----->
<!------
Be careful while working with this file.
This file is very sensitive with <cfoutput>, we don't want extra characters printed
----->

<cfparam name="URL.BBID" default="0">

<!--- Create report and automatically print --->
<cfquery name="getBillbacks" datasource="#application.datasource#">
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT 	Billback.Billback_ID, Billback.BB_Title, Billback.BB_Creator_User_Position_ID, Billback.BB_Code, Billback_Program.Program_ID,
			ISNULL(CAST(Vendor_master.Vendor_ID as integer), 0) as Vendor_ID,
			(SELECT Min(Interface_Executed_On) FROM Log_700 WHERE Log_700.Deleted = 0 AND Log_700.Billback_ID = Billback.Billback_ID AND Log_700.BB_Code = Billback.BB_Code AND Log_700.Extracted = 1) AS Transfer_Date
	FROM	Billback
			INNER JOIN Billback_Allied ON Billback_Allied.Billback_ID = Billback.Billback_ID
			INNER JOIN BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
			LEFT JOIN Vendor_Master ON Vendor_Master.Vendor_Master_ID = BB_Approved.Vendor_Master_ID
			INNER JOIN Billback_Program ON Billback_Program.Deleted = 0
				AND Billback_Program.Billback_ID = Billback.Billback_ID

	WHERE	Billback.Billback_ID = '#URL.BBID#'
			AND Billback.Deleted = 0
			AND Billback_Payee_Type_ID IN (1,2,4)<!------ distributor, operator, other ----->
			AND	Billback.Billback_ID NOT IN
				(
					SELECT 	B.BB_Parent_ID
					FROM 	Billback B
					WHERE	B.Deleted = 0
					AND 	B.BB_Parent_ID IS NOT NULL
				)
			<!--- AND EXISTS (
				SELECT TOP 1 Log_700.Billback_ID
				FROM Log_700
				WHERE Log_700.Deleted = 0
					AND Log_700.Billback_ID = Billback.Billback_ID
					AND Log_700.BB_Code = Billback.BB_Code
					AND Log_700.Extracted = 1) --->
</cfquery>

<cfset currentVendorId = "" />
<cfset totalCount = getBillbacks.recordCount>
<cfset url.requestFormat = "txt">
<cfset BBContents = "">

<!--- <cfsetting enablecfoutputonly="Yes" showdebugoutput="No"> --->
<cfif getBillbacks.recordCount>
	<cfoutput>
		<cfsavecontent variable="StartEnd">
			<cfinclude template="../../scheduled/PrintBannerStart.cfm">
		</cfsavecontent>
	</cfoutput>
	<!------ Print first page to the printer ----->
	<!------ <cfset printPage(StartEnd, 1)> ----->

	<!------ <cfset NewLine = Chr(13) & Chr(10)> ----->
	<cfset ReportNewLine = Chr(13) & Chr(10)>
	<cfset TotalBBContents = "">
	<cfset currentClaimCounterForTotal = 0 />
	<cfloop query="getBillbacks">
		<cfset url.billback_id = Billback_ID>
		<cfset url.program_id = Program_ID>
		<cfset BBContents = "">

		<cfif currentVendorId NEQ Vendor_ID>
			<cfset currentClaimCounter = 0 />
			<cfset currentVendorId = Vendor_ID />
			<cfquery name="qGetVendorBillbackCount" dbtype="query">
			SELECT	Count(*) VendorBillbackCount
			FROM	getBillbacks
			WHERE	Vendor_ID = #currentVendorId#
			</cfquery>
			<cfset totalForVendorCount = qGetVendorBillbackCount.VendorBillbackCount>
		</cfif>
		<cfset currentClaimCounter = currentClaimCounter + 1 />
		<cfset currentClaimCounterForTotal = currentClaimCounterForTotal + 1 />
<!------ Get the file content from claim report  ----->
<!------ the <cfoutput> </cfoutput> below is intentional :) ----->
<!------ Please leave the following code AS IS ----->

<!---
Claim #currentClaimCounterForTotal# of #totalCount# for total (#DateFormat(Transfer_Date, "mm/dd/yyyy")# #TimeFormat(Transfer_Date, "hh:mm:ss tt")#)
Claim #currentClaimCounter# of #totalForVendorCount# for vendor #currentVendorId#
 --->
<cfsavecontent variable="BBContents">
<cfoutput>#ReportNewLine#</cfoutput>
<cfinclude template="../../ReportWriter/claimDetail.cfm">
</cfsavecontent>
<!------ Please leave the above code AS IS ----->

		<cfif Len(BBContents) GT 0>
			<!------ Print the billback to the printer ----->
			<!------ <cfset printPage(BBContents, 2)> ----->
			<cfif Len(TotalBBContents) GT 0>
				<cfset TotalBBContents = "#TotalBBContents##chr(12)#">
			</cfif>
			<cfset TotalBBContents = "#TotalBBContents##BBContents#">

			<!----
			D18035: HZ QA question on claim auto print
			Once user clicked on the left link to see the claim report, we do nto want to set teh flags, otherwise it may not print thru the nightly job.
			<cfquery name="qSetPrintStatus" datasource="#application.datasource#">
				UPDATE	Billback_Allied SET
						Pay_Print_Over = 1,
						Pay_Print_Date = GetDate()
				WHERE	Billback_ID = '#Billback_ID#'
				AND		Pay_Print_Over = 0 <!------ Update only if it is the first time ----->
			</cfquery>
			---->

		</cfif>

	</cfloop>

	<cfoutput><div><pre>#TotalBBContents#</pre></div></cfoutput>

	<cfoutput>
		<cfsavecontent variable="StartEnd">
			<cfinclude template="../../scheduled/PrintBannerEnd.cfm">
		</cfsavecontent>
	</cfoutput>

<cfelse>
	<cfoutput>
		<center><font color="blue"><B>No claim to print...</B></font></center><br />
		<center onclick="window.close()" style="cursor:pointer;"><font color="blue"><B>Close Window</B></font></center>
	</cfoutput>
</cfif>

<cfsetting enablecfoutputonly=false>

<cfoutput>
<cfif getBillbacks.recordCount>
	<script>
		window.print();
	</script>
</cfif>
</body>
</html>
</cfoutput>
