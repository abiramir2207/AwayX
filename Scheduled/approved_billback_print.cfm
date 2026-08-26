<!------ approved_billback_print.cfm ----->
<!------
Be careful while working with this file.
This file is very sensitive with <cfoutput>, we don't want extra characters printed
----->

<cffunction name="CopyFile">
	<cfif server.coldfusion.productLevel eq "Developer"
	    or cgi.server_name contains "stage."
	    or cgi.server_name contains "demo."
	    or cgi.server_name contains "dev."
	    or cgi.server_name contains "train."
	    or cgi.server_name contains "test.">
		<cfset liveSite = false>
	<cfelse>
		<cfset liveSite = true>
	</cfif>
	
	<cfset ftpDestination = "\\10.1.0.18\Uploads\heinz\">
	<cfif liveSite>
		<cfset ftpDestination = ftpDestination & "Production">
	<cfelse>
		<cfset ftpDestination = ftpDestination & "Stage">
	</cfif>
	<cfset ftpDestination = ftpDestination & "\Outbound">
	
	<cftry>
		<cffile action = "copy" 
						source = "#filename#"  
						destination = "#ftpDestination#\ClaimReport.txt">
		<cfcatch type="any">
			<cfset result="Unable to send claims report to FTP location...">
		</cfcatch>
	</cftry>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<!--- call from scheduled task & call to generate today's claims do not provide a specific date --->
<cfif not structKeyExists(url, "printDate")>
	<cfset url.printDate = dateFormat(now(), 'm/d/yyyy')>
<!--- call to regenerate claims report requires a specific date --->	
<cfelseif not isDate(url.printDate)>
	<cfoutput><h2>Sorry, the date is invalid '#url.printDate#'</h2></cfoutput>
	<cfabort>
</cfif>

<!--- Create logpath and file variables to store data files --->
<cfset baseLogPath = getTemplatePath()>
<cfloop list="#baseLogPath#" index="i" delimiters="\">
	<cfset baseLogPath = listDeleteAt(baseLogPath,listlen(baseLogPath,"\"),"\")>
	<cfif listGetAt(baseLogPath,listLen(baseLogPath,"\"),"\") EQ "AwayX">
		<cfbreak>
	</cfif>
</cfloop>

<cfset relativePath = "common_documents\Data_Files\Created\ReportWriter\claim_reports" />
<cfset logPath = "#baseLogPath#\#relativePath#">

<cfset fileLimit = 10>
<cfset fname = dateformat(url.printDate,'yyyymmdd') & "-ClaimReport.txt">
<cfset filename = logPath & "\" & fname />
<cfset relativePath = relativePath & "\" & fname />

<!--- If the log directory does not exist, create it. --->
<cfif not DirectoryExists(logPath)>
	<cfdirectory action="create" directory="#logPath#">
</cfif>

<cfset result = "Claims report has been generated successfully...">

<!--- If the current run file exists then print it, if not generate it and print it --->
<cfif fileExists(filename)>

	<cfset copyFile()>
	
<cfelse>

	<!--- is print date today's date? --->
	<cfif dateDiff('d', url.printDate, now()) eq 0>
		<!--- report already ran if there are rows for today's date --->
		<cfquery name="qGenerated" datasource="#application.datasource#">
			SELECT TOP 1 1
				FROM BILLBACK_ALLIED
		   WHERE Pay_Print_Over = 1
		         AND Pay_Print_Date IS NOT NULL
		         AND DateDiff(d, Billback_Allied.Pay_Print_Date, '#url.printDate#') = 0
		</cfquery>
		<!--- get new data if there is no row with today's date --->
		<cfset gatherNewData = (qGenerated.recordCount eq 0)>
	<cfelse>
		<!--- print date is in the past do not get new data for report --->
		<cfset gatherNewData = false>
	</cfif>
		
	<!--- Create report and automatically print --->
	<cfquery name="getBillbacks" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		
		declare @tmp_rebate_component_name_to_exclude table (component_name_id int)
		insert into @tmp_rebate_component_name_to_exclude (component_name_id)
		select 	Program_Rebates_Component_Name_ID 
		from 	Program_Rebates_Component_Name 
		where 	External_ID LIKE 'CORP%' /* Component names to exclude is hard coded */
		
		IF OBJECT_ID('tempdb..##tmp_autoclaimprintbb') IS NOT NULL
		DROP TABLE ##tmp_autoclaimprintbb

		SELECT 	Billback.Billback_ID, Billback.BB_Title, Billback.BB_Creator_User_Position_ID, Billback.BB_Code,
				Billback_Program.Program_ID,
				ISNULL(CAST(Vendor_master.Vendor_ID as integer), 0) as Vendor_ID,
				Min(Log_700.Interface_Executed_On) AS Transfer_Date
				--(SELECT Min(Interface_Executed_On) FROM Log_700 WHERE Log_700.Deleted = 0 AND Log_700.Billback_ID = Billback.Billback_ID AND Log_700.BB_Code = Billback.BB_Code AND Log_700.Extracted = 1) AS Transfer_Date
		into	##tmp_autoclaimprintbb
		FROM	Billback
				INNER JOIN Billback_Allied
				ON Billback_Allied.Billback_ID = Billback.Billback_ID
				INNER JOIN BB_Approved
				ON BB_Approved.Billback_ID = Billback.Billback_ID
				LEFT JOIN Vendor_Master
				ON Vendor_Master.Vendor_Master_ID = BB_Approved.Vendor_Master_ID
				INNER JOIN Billback_Program
				ON
				Billback_Program.Deleted = 0
				AND Billback_Program.Billback_ID = Billback.Billback_ID
				INNER JOIN Log_700
				ON Log_700.Billback_ID = Billback.Billback_ID 
				AND Log_700.Deleted = 0
				AND Log_700.Extracted = 1
		WHERE	Billback.Deleted = 0
				AND Billback_Payee_Type_ID IN (1,2,4)<!------ distributor, operator, other ----->
				<cfif not gatherNewData>
				AND DateDiff(d, Billback_Allied.Pay_Print_Date, '#url.printDate#') = 0
				<cfelse>
				--AND Billback_Status_ID IN (4)
				--AND BB_Payment_Request_Approved = 1
				AND Billback_Allied.Pay_Print_Over = 0
				</cfif>
				AND	Billback.Billback_ID NOT IN
				(
				SELECT 	B.BB_Parent_ID
				FROM 	Billback B
				WHERE	B.Deleted = 0
				AND 	B.BB_Parent_ID IS NOT NULL
				)
				/* Vendors to exclude is hard coded */
				AND		ISNULL(Vendor_master.Vendor_ID, '') NOT IN ('55489', '59207', '49705', '22038', '54457') -- <!--- AMERINET 55489, AVENDRA LLC 59207, SODEXO MARRIOTT SERVICES  49705, FOODBUY LLC 22038, MBM CORPORATION 54457 --->
				AND	NOT EXISTS
				(
					SELECT	Billback_Program_Rebate_Component.Billback_ID
					FROM	Billback_Program_Rebate_Component
					WHERE	Billback_Program_Rebate_Component.Billback_ID = Billback.Billback_ID
					AND		Billback_Program_Rebate_Component.Program_Rebates_Component_Name_ID IN (SELECT component_name_id from @tmp_rebate_component_name_to_exclude)
					AND		Billback_Program_Rebate_Component.Checked = 'true'
					AND		Billback_Program_Rebate_Component.deleted = 0
					
				)
				--AND EXISTS (SELECT TOP 1 Log_700.Billback_ID FROM Log_700 WHERE Log_700.Deleted = 0 AND Log_700.Billback_ID = Billback.Billback_ID AND Log_700.BB_Code = Billback.BB_Code AND Log_700.Extracted = 1)
		Group By Billback.Billback_ID, Billback.BB_Title, Billback.BB_Creator_User_Position_ID, Billback.BB_Code,
				Billback_Program.Program_ID,
				ISNULL(CAST(Vendor_master.Vendor_ID as integer), 0)
		-- ORDER BY ISNULL(CAST(Vendor_master.Vendor_ID as integer), 0), Billback.BB_CODE
				
		SELECT	*
		FROM	##tmp_autoclaimprintbb
		ORDER BY Vendor_ID, BB_CODE
	</cfquery>

	<cfset currentVendorId = "" />
	<cfset totalCount = getBillbacks.recordCount>
	<cfset url.requestFormat = "txt">
	<cfset BBContents = "">

	<cfset oPrinter.LogFilePath = "#baseLogPath#\scheduled\PrinterLog.log">

	<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">
	<cfif getBillbacks.recordCount eq 0>
		<cfset result = "No claim to generate...">
	<cfelse>
		<!------ <cfoutput><cfsavecontent variable="StartEnd"><cfinclude template="PrintBannerStart.cfm"></cfsavecontent></cfoutput> ----->
		<!------ Print first page to the printer ----->
		<!------ <cfset printPage(StartEnd, 1)> ----->

		<!------ <cfset NewLine = Chr(13) & Chr(10)> ----->
		<cfset ReportNewLine = Chr(13) & Chr(10)>
		<cfset TotalBBContents = "">
		<cfset currentClaimCounterForTotal = 0 />
		<cfset fileCreated = 0 />
		<cfloop query="getBillbacks">
			<cfset url.billback_id = getBillbacks.Billback_ID>
			<cfset url.program_id =  getBillbacks.Program_ID>
			<cfset BBContents = "">

			<cfif currentVendorId NEQ Vendor_ID>
				<cfset currentClaimCounter = 0 />
				<cfset currentVendorId = Vendor_ID />
				<cfquery name="qGetVendorBillbackCount" datasource="#application.datasource#">
				SELECT	Count(*) VendorBillbackCount
				FROM	##tmp_autoclaimprintbb
				WHERE	Vendor_ID = #currentVendorId#
				</cfquery>
				<cfset totalForVendorCount = qGetVendorBillbackCount.VendorBillbackCount>
			</cfif>
			<cfset currentClaimCounter = currentClaimCounter + 1 />
			<cfset currentClaimCounterForTotal = currentClaimCounterForTotal + 1 />
			
<!------ Get the file content from claim report  ----->
<!------ the <cfoutput> </cfoutput> below is intentional :) ----->
<!------ Please leave the following code AS IS ----->
<cfsavecontent variable="BBContents">
<cfoutput>
Claim #currentClaimCounterForTotal# of #totalCount# for total (#DateFormat(Transfer_Date, "mm/dd/yyyy")# #TimeFormat(Transfer_Date, "hh:mm:ss tt")#)
Claim #currentClaimCounter# of #totalForVendorCount# for vendor #currentVendorId#
#ReportNewLine#

</cfoutput><cfinclude template="\ReportWriter\claimDetail.cfm"></cfsavecontent>
<!------ Please leave the above code AS IS ----->

			<cfif Len(BBContents) GT 0>
				<cfquery name="qSetPrintStatus" datasource="#application.datasource#">
					UPDATE	Billback_Allied SET
							Pay_Print_Over = 1,
							Pay_Print_Date = GetDate()
					WHERE	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="cf_sql_idstamp">
					AND		Pay_Print_Over = 0 <!------ Update only if it is the first time ----->
				</cfquery>
				
				<!--- Instead of building a variable with the contents which could take up memory, we will just append it to the file --->
				<cfif fileCreated>
					<cffile action="append" file="#filename#" output="#chr(12)##BBContents#" addnewline="No">
				<cfelse>
					<cffile action="write" file="#filename#" output="#BBContents#" addnewline="No">
					<cfset fileCreated = 1 />
				</cfif>
			</cfif>

		</cfloop>

		<cfset CopyFile()>
				
		<!--- Store file data into a text file for retrieval and quicker printing --->
		<!--- <cffile action="write" file="#filename#" output="#TotalBBContents#"> --->

		<!--- Check for stored report logs, if more than 10 exist then delete the oldest one --->
		<cfdirectory action="list" directory="#logPath#" name="fileList" sort="datelastmodified" filter="*.txt">
		<cfif fileList.recordcount GT fileLimit>
			<cfset overflow = fileList.recordcount - fileLimit>
			<cfset useLakebaseForfileList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("filelist")>
<cfif useLakebaseForfileList>
	<cftry>
		<cfset fileList = application.oLakebase.toQuery(
			application.oLakebase.selectRows("filelist", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForfileList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForfileList>
<cfquery name="fileList" dbtype="query" maxrows="#overflow#">
				SELECT *
				FROM fileList
			</cfquery>
</cfif>
			<cfloop query="fileList">
				<cfset fileName = logpath & "\" & fileList.name>
				<cffile action="delete" file="#fileName#">
			</cfloop>
			<cfdirectory action="list" directory="#logPath#" name="fileList" sort="datelastmodified" filter="*.txt">
		</cfif>
	</cfif>

	<cfsetting enablecfoutputonly="No" showdebugoutput="No">
	
	<cfquery name="qDropTable" datasource="#application.datasource#">
		IF OBJECT_ID('tempdb..##tmp_autoclaimprintbb') IS NOT NULL
		DROP TABLE ##tmp_autoclaimprintbb
	</cfquery>
</cfif>

<cfoutput><center><font color="blue"><B>#result#</B></font></center></cfoutput>
