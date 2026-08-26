<!--- This file only exists to call Create PDF and then show the user a link to download it. --->

<!--- Expected values: report_ID and contract_main_ID> --->
<cfparam name="Report_ID"			default="">
<cfparam name="Contract_Main_ID"	default="">
<cfparam name="BB_Auto_Program_Pay_Period_ID" default="0">
<cfset PW_DoNotCFFLUSH = 1/>
<title>Download Auto Pay PDF</title>

<!--- Spinner goes here --->
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<!--- PDF Report --->
<cfinclude template="/billbacks/Auto_BB_Report/create_pdf.cfm">
<cfset getPageContext().getResponse().reset() />
<cfheader name="Content-Disposition" value="attachment; filename=#PDFFileName#" >
<cfcontent type="application/pdf" file="#PDFLocation#" >
	

<!---	http://siriusly/common_documents/Temp_Files/Billback/AutoPayReport/AutoPay_74_1059.pdf 
	<cfoutput>#PDFPath#</cfoutput>--->
<!---<div align="center">
Your PDF has been created.
	<p></p>

	<A href="<cfoutput>#PDFPath#</cfoutput>" target="_blank"><strong>Download</strong></a> PDF for this report.
	<p></p>
</div>

<!--- Get rid of spinner --->
<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';

function downloadDoc(documentLocation)
{
	document.location = documentLocation;
	window.close;
}
</SCRIPT>--->
	