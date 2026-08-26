<!--- This file only exists to call Create PDF and then show the user a link to download it. --->

<!--- Expected values: report_ID and contract_main_ID> --->
<cfparam name="Contract_Main_ID"	default="">
<cfparam name="type" default="1">
<cfset PW_DoNotCFFLUSH = 1/>
<title>Download CPA PDF</title>

<!--- Spinner goes here --->
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<!--- PDF Report --->
<cfif type EQ 1>
	<cfinclude template="/common_files/contracts/OPP/create_distributor_pdf.cfm">
<cfelse>
	<cfinclude template="/common_files/contracts/OPP/create_end_user_pdf.cfm">
</cfif>
<cfset getPageContext().getResponse().reset() />
<cfheader name="Content-Disposition" value="attachment; filename=#PDFFileName#" >
<cfcontent type="application/pdf" file="#PDFLocation#" >
	

