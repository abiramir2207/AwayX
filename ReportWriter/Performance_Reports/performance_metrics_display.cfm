<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
<TITLE>Contract Management Performance Metrics Report</TITLE>
<script language="JavaScript" type="text/JavaScript">
<!--
function MM_reloadPage(init) {  //reloads the window if Nav4 resized
  if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {
    document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}
  else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();
}
MM_reloadPage(true);
//-->
</script>
</HEAD>

<BODY>

<cfset Document_Title = "Performace Metrics">
<cfparam name="url.schedule" default="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- TOP 10 RFA and WIP programs --->
<CFQUERY NAME="Get_Programs" DATASOURCE="#application.datasource#">
	select top 10 contract_main_id,contract_number,contract_title, contract_start_date, contract_end_date,
case when Contract_Quantity_UOM_IDX = 1 then
(select (ISNULL(sum(ISNULL(CAST(volume_CS as float),0)),0) / 7)* 365 from program_product_volume where program_product_volume.program_id = contract_main.contract_main_id)
when Contract_Quantity_UOM_IDX =2 then
(select (ISNULL(sum(ISNULL(CAST(volume_LB as float),0)),0) / 7)* 365 from program_product_volume where program_product_volume.program_id = contract_main.contract_main_id)
end
as Program_Volume,
case when Contract_Quantity_UOM_IDX = 1 then
'cs'
when Contract_Quantity_UOM_IDX =2 then
'lbs'
end as Volume_UOM
from contract_main
where  contract_created_date BETWEEN DateAdd(week, -1, getdate()) AND DateAdd(day, -1, getdate())
and contract_status_type_IDX IN (1,2)
and deleted = 0
order by Program_Volume desc
</CFQUERY>
<style>
	TD {font-size : 12px; font-family: Arial;}
	TD.Maintable {border-bottom:solid #93BEE2 1px;}
	#header {font-size : 13px; font-family: Arial; color: white; font-weight: bold;}
</style>


  <TABLE BORDER="0" ALIGN="center" CELLPADDING="0" CELLSPACING="0" WIDTH="90%">
  <TR>
  <TD width="100%" align="left">
  <span style="font-size: 15px; font-weight:bold; color:black;left: 30px;"> Contract Management Performance Metrics Report</span>
  <CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
  </TD>
  </TR>
  
  <TR>
  <TD>
 <hr color="red" size="2">
  </TD>
  </TR>
  <TR>
  <TD width="100%" align="left" valign="top">
  <cfoutput>
  Report Period: #Dateformat(DateAdd("ww", -1, now()),"mm/dd/yyyy")# - #Dateformat(DateAdd("d", -1, now()),"mm/dd/yyyy")#</cfoutput>
  </TD>
  </TR>
  <tr>
  <td>&nbsp; </td>
  </tr>
  
  </TABLE>
  <cfif NOT isdefined("URL.FAX_EMAIL") AND NOT isdefined("URL.PRINT") AND NOT isdefined("url.report_id")>
 <SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>



<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT> 
</CFIF>

<TABLE BORDER="0" ALIGN="center" CELLPADDING="2" CELLSPACING="0" WIDTH="90%">
<THEAD>
<TR bgcolor="#2f2f00">
<TD COLSPAN="100%" ID="header">
	TOP 10 Programs by Volume for this period
</TD>
</TR>
<tr bgcolor="#d7d700">
<td>
<b>Contract Number</b>
</td>
<td width="300">
<b>Program Title</b>
</td>
<td>
<b>Volume</b>
</td>
<td>
<b>Start Period</b>
</td>
<td>
<b>End Period</b>
</td>
</tr>
</THEAD>
<cfif Get_Programs.recordcount GT 0>
		<CFOUTPUT QUERY="Get_Programs">
			<TR BGCOLOR="#IIF(currentrow Mod 2, DE('FFFFFF'),DE('CCFFCC'))#">
				<TD CLASS="Maintable">#Contract_Number#</TD>
				<TD CLASS="Maintable" width="300">#Contract_Title#</TD>
				<TD CLASS="Maintable">#numberformat(Round(Program_Volume),'_-___,___,___,___,___')##Trim(Volume_UOM)#</TD>
				<TD CLASS="Maintable">#dateformat(contract_start_date,"mm/dd/yyyy")#</TD>
				<TD CLASS="Maintable">
				#dateformat(contract_end_date,"mm/dd/yyyy")#
				</TD>
			</TR>
		</CFOUTPUT>
<CFELSE>
<TR>
<TD align="center" colspan="100%">
<span style="font-size: 15px; font-weight:bold; color:black;left: 30px;"> No Data to report</span>
</TD>
</TR>
</CFIF>
</TABLE>
<!--- end of RFA and wip programs --->

<table>
<tr>
<td>&nbsp;

</td>
</tr>
</table>

<!--- Approved programs for this period --->
<CFQUERY NAME="Get_Approved_Programs" DATASOURCE="#application.datasource#">
	select contract_main_id,contract_number,contract_title, contract_start_date, contract_end_date,
case when Contract_Quantity_UOM_IDX = 1 then
(select (ISNULL(sum(ISNULL(CAST(volume_CS as float),0)),0) / 7)* 365 from program_product_volume where program_product_volume.program_id = contract_main.contract_main_id)
when Contract_Quantity_UOM_IDX =2 then
(select (ISNULL(sum(ISNULL(CAST(volume_LB as float),0)),0) / 7)* 365 from program_product_volume where program_product_volume.program_id = contract_main.contract_main_id)
end
as Program_Volume,
case when Contract_Quantity_UOM_IDX = 1 then
'cs'
when Contract_Quantity_UOM_IDX =2 then
'lbs'
end as Volume_UOM
from contract_main
where  contract_created_date BETWEEN DateAdd(week, -1, getdate()) AND DateAdd(day, -1, getdate())
and contract_status_type_IDX IN (3,4,5)
and deleted = 0
order by Program_Volume desc
</CFQUERY>



<TABLE BORDER="0" ALIGN="center" CELLPADDING="2" CELLSPACING="0" WIDTH="90%">
<THEAD>
<TR bgcolor="#2f2f00">
<TD COLSPAN="100%" ID="header">
	Programs Approved by Volume for this period
</TD>
</TR>
<tr bgcolor="#d7d700">
<td>
<b>Contract Number</b>
</td>
<td>
<b>Program Title</b>
</td>
<td>
<b>Volume</b>
</td>
<td>
<b>Start Period</b>
</td>
<td>
<b>End Period</b>
</td>
</tr>
</THEAD>
<cfif Get_Approved_Programs.recordcount GT 0>
		<CFOUTPUT QUERY="Get_Approved_Programs">
			<TR BGCOLOR="#IIF(currentrow Mod 2, DE('FFFFFF'),DE('CCFFCC'))#">
				<TD CLASS="Maintable">#Contract_Number#</TD>
				<TD CLASS="Maintable">#Contract_Title#</TD>
				<TD CLASS="Maintable">#numberformat(Round(Program_Volume),'_-___,___,___,___,___')##Trim(Volume_UOM)#</TD>
				<TD CLASS="Maintable">#dateformat(contract_start_date,"mm/dd/yyyy")#</TD>
				<TD CLASS="Maintable">
				#dateformat(contract_end_date,"mm/dd/yyyy")#
				</TD>
			</TR>
		</CFOUTPUT>
<CFELSE>
<TR>
<TD align="center" colspan="100%">
<span style="font-size: 15px; font-weight:bold; color:black;left: 30px;"> No Data to report</span>
</TD>
</TR>
</CFIF>
</TABLE>
<!--- end of aprograms approved --->

<table>
<tr>
<td>&nbsp;

</td>
</tr>
</table>

<!--- Expiring programs for this period --->
<CFQUERY NAME="Get_Expiring_Programs" DATASOURCE="#application.datasource#">
	select contract_main_id,contract_number,contract_title, contract_start_date, contract_end_date,
case when Contract_Quantity_UOM_IDX = 1 then
(select (ISNULL(sum(ISNULL(CAST(volume_CS as float),0)),0) / 7)* 365 from program_product_volume where program_product_volume.program_id = contract_main.contract_main_id)
when Contract_Quantity_UOM_IDX =2 then
(select (ISNULL(sum(ISNULL(CAST(volume_LB as float),0)),0) / 7)* 365 from program_product_volume where program_product_volume.program_id = contract_main.contract_main_id)
end
as Program_Volume,
case when Contract_Quantity_UOM_IDX = 1 then
'cs'
when Contract_Quantity_UOM_IDX =2 then
'lbs'
end as Volume_UOM
from contract_main
where  contract_created_date BETWEEN DateAdd(week, -1, getdate()) AND DateAdd(day, -1, getdate())
and contract_status_type_IDX = 6
and deleted = 0
order by Program_Volume desc
</CFQUERY>



<TABLE BORDER="0" ALIGN="center" CELLPADDING="2" CELLSPACING="0" WIDTH="90%">
<THEAD>
<TR bgcolor="#2f2f00">
<TD COLSPAN="100%" ID="header">
	Programs about to expire for this period
</TD>
</TR>
<tr bgcolor="#d7d700">
<td>
<b>Contract Number</b>
</td>
<td>
<b>Program Title</b>
</td>
<td>
<b>Volume</b>
</td>
<td>
<b>Start Period</b>
</td>
<td>
<b>End Period</b>
</td>
</tr>
</THEAD>
<cfif Get_Expiring_Programs.recordcount GT 0>
		<CFOUTPUT QUERY="Get_Expiring_Programs">
			<TR BGCOLOR="#IIF(currentrow Mod 2, DE('FFFFFF'),DE('CCFFCC'))#">
				<TD CLASS="Maintable">#Contract_Number#</TD>
				<TD CLASS="Maintable">#Contract_Title#</TD>
				<TD CLASS="Maintable">#numberformat(Round(Program_Volume),'_-___,___,___,___,___')##Trim(Volume_UOM)#</TD>
				<TD CLASS="Maintable">#dateformat(contract_start_date,"mm/dd/yyyy")#</TD>
				<TD CLASS="Maintable">
				#dateformat(contract_end_date,"mm/dd/yyyy")#
				</TD>
			</TR>
		</CFOUTPUT>
<CFELSE>
<TR>
<TD align="center" colspan="100%">
<span style="font-size: 15px; font-weight:bold; color:black;left: 30px;"> No Data to report</span>
</TD>
</TR>
</CFIF>
</TABLE>
<br>
<cfif NOT isdefined("URL.FAX_EMAIL") AND NOT isdefined("URL.PRINT") AND NOT isdefined("url.report_id")>
<table align="center">
<tr>
			<TD align="center">
					<CF_button
						button_name		=	""
						button_caption	=	"print"
						button_action	=	"NewWindow('report_print.cfm?Include_File_path=/ReportWriter/Performance_Reports/performance_metrics_display.cfm','name','800','600','Yes', 'No')"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Prepare an email contents"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>				
				</TD>
				<TD align="center">
					<CF_button
						button_name		=	""
						button_caption	=	"email"
						button_action	=	"window.location.href='report_email_create.cfm?FAX_EMAIL=EMAIL&Include_File_path=/ReportWriter/Performance_Reports/performance_metrics_display.cfm'"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Prepare an email contents"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>				
				</TD>
			<!--- DEV NOTE: DAA; D15409    REMOVE FAX LINK
				<TD align="center">
					<CF_button
						button_name		=	""
						button_caption	=	"fax"
						button_action	=	"window.location.href='report_email_create.cfm?FAX_EMAIL=FAX&Include_File_path=/ReportWriter/Performance_Reports/performance_metrics_display.cfm'"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Prepare the contents of a fax to be sent"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>				
				</TD>
			 --->
		</tr>	

</table>
</cfif>
<!--- <cfflush> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>


<cfif url.schedule EQ 1>


</cfif>

