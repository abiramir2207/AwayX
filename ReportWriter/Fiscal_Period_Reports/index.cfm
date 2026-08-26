<CFIF NOT IsDefined("reportInclude")>
	<CFINCLUDE TEMPLATE="/reportwriter/reportInclude.cfm">
</CFIF>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<STYLE>
	select
	{
		width: 200px;
	}
	</STYLE>
	<SCRIPT language="JavaScript" SRC="/validate.js"></SCRIPT>
	<SCRIPT language="JavaScript" SRC="/Common_Files/scripts/Date_Difference.js"></SCRIPT>
	<SCRIPT language="JavaScript" SRC="rCommonFunctions.js"></SCRIPT>
	
	<CFSCRIPT>
	Border="Yes";
	BorderSize=1;  
	BorderColor="Silver";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Black"; 
	TitleFont="Arial";
	TitleSize=8;
	IsClosed="Yes";  
	WIDTH="99%";
</CFSCRIPT>

<cfset Color1="lightsteelblue"><!---Other Blue--->
<cfset Color2="FFCC66"><!---Yellow--->
<cfset Color3="CCFFCC"><!---Green--->
<cfset Color4="CCFFFF"><!---Light Blue--->
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/header.cfm">

<BLOCKQUOTE>

<!--- <B>
<FONT SIZE="2" COLOR="Red">[</FONT>
<FONT SIZE="2" COLOR="Blue"><A HREF="/help_files/manual/Reports/saved.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;">read me first</A></FONT>
<FONT SIZE="2" COLOR="Red">]</FONT>
</B> --->

<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="5" HEIGHT="100%" WIDTH="95%">
	<TR>
		<TD VALIGN="top">
			<IMG SRC="/images/icon_reports_large.gif" BORDER="0" ALT="">
		</TD>
		<TD BGCOLOR="Navy"></TD>
		<TD VALIGN="top">
		<CFSET diThisPage="#reportListPage#">
		<CFINCLUDE template="/reportwriter/reportHeader.cfm">
		
<SPAN CLASS="title2">Fernando's <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Reports
</SPAN>

<HR COLOR="Orange" SIZE="1">

<strong>All Flat Files</strong>

<cfdirectory action="list" name="FlatFileList" sort="name asc" directory="#Application.Doc_Path#\data_files\created\ReportWriter\Fiscal_Period_Reports\flatfile\">
<ul>
<cfoutput query="FlatFileList">

	<cfset fpstartdate = left(name, 10)>
	<cfset fpenddate = right(name, 10)>

	
<!---
<li><A href="/ReportWriter/Fiscal_Period_Reports/flatfile/#name#/fernandos_payment_report_#name#.txt">#dateformat(fpstartdate, 'mmmm d, yyyy')# - #dateformat(fpenddate, 'mmmm d, yyyy')#</A></li>
--->
<li><A href="<cfoutput>#application.HTTPVar##cgi.server_name#</cfoutput>/GetDocument.cfm?FilePath=data_files\created\ReportWriter\Fiscal_Period_Reports\flatfile\#name#\fernandos_payment_report_#name#.txt">#dateformat(fpstartdate, 'mmmm d, yyyy')# - #dateformat(fpenddate, 'mmmm d, yyyy')#</A></li>
</cfoutput>
</ul>

<strong><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Reports</strong>
<cfdirectory action="list" name="ReportList" sort="name asc" directory="#Application.Doc_Path#\data_files\created\ReportWriter\Fiscal_Period_Reports\report\">
<ul>
<cfoutput query="ReportList">

	<cfset fpstartdate = left(name, 10)>
	<cfset fpenddate = right(name, 10)>

<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#color1#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="#dateformat(fpstartdate, 'mmmm d, yyyy')# - #dateformat(fpenddate, 'mmmm d, yyyy')#"  
	TitleClosed="#dateformat(fpstartdate, 'mmmm d, yyyy')# - #dateformat(fpenddate, 'mmmm d, yyyy')#"  
	TitleTooltip="Click here to toggle the view"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="99%"
	Color="white">

<cfset firstname = name>

	<cfdirectory action="list" name="ReportDetails" sort="name desc" directory="#Application.Doc_Path#\data_files\created\ReportWriter\Fiscal_Period_Reports\report\#name#">

	<cfloop query="ReportDetails">
	
	<cfset namelen = len(name)>
	<cfset shipto = left(name, 9)>
		<cfset amendedname = right(name, (namelen - 10))>
	<cfset fpstart = left(amendedname, 10)>
	<cfset fpend = left(right(amendedname, 15), 10)>
	
		<li><!--- <A href="/ReportWriter/Fiscal_Period_Reports/report/#firstname#/#name#">#name#</a></li>--->
		 <A href="<cfoutput>#application.HTTPVar##cgi.server_name#</cfoutput>/GetDocument.cfm?FilePath=data_files\created\ReportWriter\Fiscal_Period_Reports\report\#firstname#\#name#">#name#</a></li>
	</cfloop>
</cf_openlayer>
	
</cfoutput>
</ul>
 <A href="/reportwriter/fiscal_period_reports/distributor_payments.cfm">Execute reporting functionality</A> (WILL TAKE A VERY LONG TIME AND PROBABLY HAS ALREADY RUN!!!)
