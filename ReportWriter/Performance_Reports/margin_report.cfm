<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Margin Exception Report</title>
<STYLE>
	.sectionHead
	{
		font-weight:bold;
		font-size:15px;
		color:red;
		border-bottom:2px solid #0000CD;
	}
</STYLE>
<script language="javascript">
 function CheckValid()
 {
  if(document.all.SearchForm.Start_date.value =="" || document.all.SearchForm.End_date.value =="")
	{alert("You must enter a start and end date.");
 return false;}
 else
 {
 	SearchForm.submit();
	
	}
 }
 

 
</script>
</head>
<!---
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
--->
<cfparam Name="ErrorMessage" default="">
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset displayGroupType = genSettingsManager.getDisplayGroupType(appSettings.getViewProgramProductGroupType()) />
<cfset displayGroupTypeDesc = genSettingsManager.settings.getViewProgramProductGroupTypeDesc() />
		
<body>
<form name="SearchForm" action="margin_report_action.cfm" method="post">
<table align ="center" width="100%">
		<TR VALIGN="TOP">
			<TD COLSPAN="100%" CLASS="sectionHead"><strong>Search Criteria</strong></TD>
		</TR>
		<TR>	
			<TD width="21%"><b>Type Of Report: </b></TD>		
			<TD width="38%">
			<cfoutput><span ID="searchItemLabel"><B><!--- #application.returned_customer_setting.zone_label_singular# ---></B></span><BR></cfoutput>
			
			<cfoutput><SELECT NAME="report_type_id">
				<OPTION VALUE="1">All Items</OPTION>
				<OPTION VALUE="2">Items Margin < Approval Margin</OPTION>
				<OPTION VALUE="3">All #displayGroupTypeDesc#</OPTION>
				<OPTION VALUE="4">#displayGroupTypeDesc# Margin < Approval Margin</OPTION>
			</SELECT></cfoutput>
			</TD>	
			<td width="41%" colspn="100%">&nbsp;</td>
		</TR>
		<TR>
		<TD><b>Approval Date between: </b></TD>
		<TD align="left"><B>Start Date:</B>&nbsp;&nbsp;
			<CFPARAM NAME="FORM.Start_date" DEFAULT="">
			<SPAN ID="SP_Start_date">
<!--- Call the "EASYDATE" custom tag for the calendar --->
			<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="Start_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Start_date#">
			</SPAN>
		</TD>
		<td colspn="100%">&nbsp;</td>
		</TR>
		<tr>
		<td>&nbsp;</td>
		<td  align="left"><B>End Date:</B>&nbsp;&nbsp;
			<CFPARAM NAME="FORM.End_date" DEFAULT="">
			<SPAN ID="SP_End_date">
<!--- Call the "EASYDATE" custom tag for the calendar --->
			<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="End_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.End_date#">
			</SPAN></td>
			<td colspn="100%">&nbsp;</td>
		</tr>
		
		<tr>
		<TD colspan="3">
			<strong>Output Type:</strong>
			<INPUT TYPE="radio" ID="ReportType" NAME="ReportType" VALUE="h" checked>HTML
			<INPUT TYPE="radio" ID="ReportType" NAME="ReportType" VALUE="e">Excel
			<!---
			<INPUT TYPE="radio" ID="rReportType" NAME="rReportType" VALUE="c"<cfif rReportType EQ "c"> CHECKED</cfif>>CSV
			--->
		</TD>
		</tr>
		<tr><Td>&nbsp;</TD></tr>
		<tr>
			<TD valign="bottom">
			<B><FONT COLOR="red">[</FONT> <A HREF="##" ONCLICK="return CheckValid();">generate report</A> <FONT COLOR="red">]</FONT></B>
	    </TD>
		</tr>
	</table>
</form>
</body>
</html>
