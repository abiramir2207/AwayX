<!--- This file only exists to call Create Report PDF and then show the user a link to download it. --->

<!--- Expected values: report_ID and contract_main_ID> --->
<cfparam name="Billback_ID"			default="">

<title>Summary Statement</title>

<!--- Spinner goes here --->
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<CFFLUSH>

<!--- PDF Report --->
<cfinclude template="/billbacks/create_summary_statement.cfm">

<!---<div align="center">
Your PDF has been created.
	<p></p>

	<A href="<cfoutput>#PDFPath#</cfoutput>" target="_blank"><strong>Download</strong></a> PDF for this report.
	<p></p>
</div>
--->
<!--- Get rid of spinner --->
<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
function downloadDoc(documentLocation)
{
	document.location = documentLocation;
	window.close;
}
</SCRIPT>
	
<fieldset id="mainfieldset" style="padding:10px; border:1px solid blue;">
  <legend style="font: bold 14px sans-serif; color: red;">Summary Statement</legend>

<div style="text-align:center; margin:30px; font-size:10pt;">
Your statement has been generated.&nbsp;&nbsp;&nbsp;Please choose one of these options.
</div>

<cfoutput>
<div style="text-align:center; margin:30px;">
 <a href="#PDFPath#">#actionLinkFormat("download")#</a>
 <a href="email_statement.cfm?attachments=#PDFPath#&billback_id=#billback_id#" style="margin:0 20px;">#actionLinkFormat("email")#</a>
 <a href="javascript:window.close()">#actionLinkFormat("cancel")#</a>
</div>
</cfoutput>
</fieldset>

<script>
window.resizeTo(950, 650);
</script>
	


<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="actionLinkFormat" access="public" returntype="string" output="false">
	<cfargument name="action" type="string" required="true" />
	<cfargument name="style" type="string" required="false" default="classic"/>
	
	<cfscript>
		switch (arguments.style) {
			case "classic": 
				return "<b><font color='red'>[ </font>" & arguments.action & " <font color='red'> ]</font></b>"; break;
			default: 
				return arguments.action;
		}
	</cfscript>
</cffunction>


	