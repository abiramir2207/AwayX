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

<cfset qGetPullbackAppliedInfo = PullbackManager.getpulllbacksapplied() />
 <cfoutput>

<table width="800" class="maintable" CELLPADDING="0" CELLSPACING="0" align="center" border="0">
 <caption align="left" style="font-size:12px;font-weight:bold;">Applied #appsettings.getPullbackLabelLower()#: </caption>
 </cfoutput>
 <tr  bgcolor="ffcc33">
 <TD id="header" valign="top"><strong>Distributor Name</strong>
</td>
 <TD id="header" valign="top"> <strong>Ship To</strong>
 <TD id="header" valign="top" colspan="2">&nbsp;</td>
 <TD id="header" valign="top" colspan="100%" align="right"> <strong>Total Pullback Amt. </strong></td>
</td>
 </TR>
 <cfoutput query="qGetPullbackAppliedInfo" group="customer_id">
 <TR bgcolor="C6FFC6">
 <TD valign="top" style="font-size: 11px;">#shr_ship_to#</td>
 <TD valign="top" style="font-size: 11px;">#name#</td>
 <TD valign="top" style="font-size: 11px;" colspan="2">&nbsp;</td>
 <cfquery name="totalpullbackamount" dbtype="query">
 select SUM(total_pullbackamount_applied) as total_pullbackamount_applied from
 qGetPullbackAppliedInfo where customer_id = '#customer_id#'
 </cfquery>
 <TD valign="top" style="font-size: 11px;" colspan="100%" align="right">#dollarformat(total_pullbackamount_applied)#</td>
 </tr>
 <tr  bgcolor="ffff66">
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
 <TD id="header" valign="top" colspan="100%"><strong>Distributor Billback Details</strong>
</td>
</tr>
<tr bgcolor="cccc66">
<td>&nbsp;</td>
 <TD id="header" valign="top"> <strong>BB Code</strong>
</td>
 <TD id="header" valign="top"> <strong>BB Reference</strong>
</td>
 <TD id="header" valign="top" width="100"> <strong>Title</strong>
</td>
<TD id="header" valign="top" width="35"> <strong>StartDate</strong>
</td>
<TD id="header" valign="top" width="35"> <strong>EndDate</strong>
</td>
<TD id="header" valign="top"> <strong>Actual Amt</strong>
</td>
<TD id="header" valign="top"> <strong>Pullback Amt</strong>
</td>
<TD id="header" valign="top"> <strong>Paid Amt</strong>
</td>
 </TR>
 <cfoutput  group="pullback_applied_to_billback_id">
 <TR bgcolor="cccc99">
 <td>&nbsp;</td>
 <TD valign="top" style="font-size: 10px;"> #dis_BB_Code#
</td>
 <TD valign="top" style="font-size: 10px;"> #dis_BB_Reference#
</td>
 <TD valign="top" style="font-size: 10px;">#dis_BB_Title#
</td>
<TD valign="top" style="font-size: 10px;"> #dateformat(dis_bb_start_date,"mm/dd/yyyy")#
</td>
<TD valign="top" style="font-size: 10px;"> #dateformat(dis_bb_end_date,"mm/dd/yyyy")#
</td>
<TD valign="top" style="font-size: 10px;"> #dollarformat(Approved_Amount_Before_Pullbacks)#
</td>
<TD valign="top" style="font-size: 10px;">#dollarformat(total_pullbackamount_applied)#
</td>
<TD valign="top" style="font-size: 10px;"> #dollarformat(paid_amount)#
</td>
 </TR>
 <tr  bgcolor="ffcc33">
 <TD id="header" valign="top" colspan="100%"><strong>Applied Operator Billback Details</strong>
</td>
</tr>
<tr bgcolor="99ccff">
<td>&nbsp;</td>
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
<td colspan="100%">&nbsp;</td>
 </TR>
<cfoutput  group="pullback_billback_id">
 <TR bgcolor="99ffff">
 <td>&nbsp;</td>
 <td>&nbsp;</td>
 <TD valign="top" style="font-size: 10px;"> #opr_BB_Code#
</td>
 <TD valign="top" style="font-size: 10px;"> #opr_BB_Reference#
</td>
 <TD valign="top" style="font-size: 10px;">#opr_BB_Title#
</td>
<TD valign="top" style="font-size: 10px;"> #dateformat(opr_bb_start_date,"mm/dd/yyyy")#
</td>
<TD valign="top" style="font-size: 10px;"> #dateformat(opr_bb_end_date,"mm/dd/yyyy")#
</td>
<td colspan="100%">&nbsp;</td>
</TR>
<tr>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
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
  <td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
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
<TD valign="top" style="font-size: 10px;"> #pullback_from_program_rate#
</td>
<TD valign="top" style="font-size: 10px;"> #pullback_expected_dollars#
</td>
</TR>
 </cfoutput>
 </cfoutput>
 </cfoutput>
 </cfoutput>
 <tr><td>&nbsp;</td></tr>
 </cfoutput>