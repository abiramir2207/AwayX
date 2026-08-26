<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<html>
<head>
	<title>Apply <cfoutput>#appsettings.getPullbackLabel()#</cfoutput></title>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">

<cfinclude template="/get_access_profile.cfm">

<!----------------- Add Spinner ------------------------>
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<SCRIPT>
	document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>
<!----------------- Add Spinner ------------------------>

<cfset PullbackManager = CreateObject("component","components.reports.PullbackReportManager") />

<cfset qGetPullbackAppliedInfo = PullbackManager.getpulllbacksunapplied() />
 <cfoutput>

<table width="750" class="maintable" CELLPADDING="0" CELLSPACING="0" align="center" border="0">
 <caption align="left" style="font-size:12px;font-weight:bold;">Unapplied #appsettings.getPullbackLabelLower()#: </caption>
 </cfoutput>
 <tr  bgcolor="ffcc33">
 <TD id="header" valign="top"><strong>Distributor Name</strong>
</td>
 <TD id="header" valign="top"> <strong>Ship To</strong>
 <TD id="header" valign="top" colspan="2">&nbsp;</td>
</td>
 </TR>
 <cfoutput query="qGetPullbackAppliedInfo" group="customer_id">
 <TR bgcolor="C6FFC6">
 <TD valign="top" style="font-size: 11px;">#shr_ship_to#</td>
 <TD valign="top" style="font-size: 11px;">#name#</td>
 <TD valign="top" style="font-size: 11px;" colspan="2">&nbsp;</td>
 </tr>
 <tr bgcolor="ffff66">
 <TD id="header" valign="top"><strong>Contract Number</strong>
</td>
 <TD id="header" valign="top"> <strong>Title</strong>
</td>
 <TD id="header" valign="top"> <strong>Start Date</strong>
</td>
 <TD id="header" valign="top"> <strong>End Date</strong>
</td>
 </TR>
 <cfoutput group="contract_number">
 <TR bgcolor="ffff99">
 <TD valign="top" style="font-size: 11px;">#contract_number#</td>
 <TD valign="top" style="font-size: 11px;">#contract_title#</td>
  <TD valign="top" style="font-size: 11px;">#dateformat(contract_start_date,"mm/dd/yyyy")#</td>
<TD valign="top" style="font-size: 11px;">#dateformat(contract_end_date,"mm/dd/yyyy")#</td>
 </tr>
 <tr  bgcolor="ffcc33">
 <TD id="header" valign="top" colspan="100%"><strong>UnApplied Operator Billback Details</strong>
</td>
</tr>
<tr  bgcolor="ffcc33">
<td>&nbsp;</td>
 <TD id="header" valign="top"> <strong>BB Code</strong>
</td>
 <TD id="header" valign="top"> <strong>BB Reference</strong>
</td>
 <TD id="header" valign="top"> <strong>Title</strong>
</td>
<TD id="header" valign="top" width="35"> <strong>StartDate</strong>
</td>
<TD id="header" valign="top" width="35"> <strong>EndDate</strong>
</td>
<TD id="header" valign="top" colspan="100%"> <strong>Contract Number</strong>
</td>
 </TR>
<cfoutput  group="pullback_billback_id">
 <TR bgcolor="99ccff">
 <td>&nbsp;</td>
 <TD valign="top" style="font-size: 11px;"> <strong>#opr_BB_Code#</strong>
</td>
 <TD valign="top" style="font-size: 11px;"> <strong>#opr_BB_Reference#</strong>
</td>
 <TD valign="top" style="font-size: 11px;"><strong>#opr_BB_Title#</strong>
</td>
<TD valign="top" style="font-size: 11px;"> <strong>#dateformat(opr_bb_start_date,"mm/dd/yyyy")#</strong>
</td>
<TD valign="top" style="font-size: 11px;"> <strong>#dateformat(opr_bb_end_date,"mm/dd/yyyy")#</strong>
</td>
<TD valign="top" style="font-size: 11px;" colspan="100%"> <strong>#pullback_program_number#</strong>
</td>
</TR>
<tr>
<td>&nbsp;</td><td>&nbsp;</td>
 <TD id="header" valign="top"> <strong>Item</strong>
</td>
 <TD id="header" valign="top"> <strong>Description</strong>
</td>
 <TD id="header" valign="top"> <strong>Discount Type</strong>
</td>
<TD id="header" valign="top"> <strong>Volume<br>LB</strong>
</td>
 <TD id="header" valign="top"> <strong>Pullback %</strong>
</td>
<TD id="header" valign="top"> <strong>Rate/LB</strong>
</td>
<TD id="header" valign="top"> <strong>Pullback Amt.</strong>
</td>
 </TR>
 <cfoutput>
  <TR bgcolor="FFE083">
  <td>&nbsp;</td><td>&nbsp;</td>
 <TD valign="top" style="font-size: 10px;"> #item#
</td>
 <TD valign="top" style="font-size: 10px;"> #description#
</td>
 <TD valign="top" style="font-size: 10px;"> #discount_type_desc#
</td>
 <TD valign="top" style="font-size: 10px;">#product_BB_volume_LB#
</td>
<TD valign="top" style="font-size: 10px;"> #pullback_percent#
</td>
<TD valign="top" style="font-size: 10px;"> &nbsp;
</td>
<TD valign="top" style="font-size: 10px;"> &nbsp;
</td>
</TR>
 </cfoutput>
 </cfoutput>
 </cfoutput>
 <tr><td>&nbsp;</td></tr>
 </cfoutput>