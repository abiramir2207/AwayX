<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Commodity Pricing</TITLE>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="view_commodity_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="commodity_view_data_menu.cfm">
<TABLE CELLPADDING="5">
<TR>
	<TD VALIGN="top">
<TABLE BGCOLOR="Silver" CELLPADDING="2" CELLSPACING="1">
			<TR BGCOLOR="Khaki">
				<TD WIDTH="65"><B>Date</B></TD>
				<TD WIDTH="65"><B>Closing<BR>Price</B></TD>
				<TD WIDTH="65"><B>Previous<BR> Closing</B></TD>
				<TD WIDTH="60" ALIGN="right"><B>Pricing<BR>Movement</B></TD>
			</TR>
		</TABLE>
	
<CFOUTPUT>
<IFRAME SRC="view_commodity_data_window.cfm?Symbol=#URL.Symbol#&amp;datasize=#URL.datasize#&amp;Comm_Month_Year=#Comm_Month_Year#" WIDTH="300" HEIGHT="435" MARGINWIDTH="0" MARGINHEIGHT="0" FRAMEBORDER="0"></IFRAME>
</CFOUTPUT>

	</TD>
	<TD VALIGN="top">

	
<!--- This is where all of the stat functions are located --->	
<CFINCLUDE TEMPLATE="stat_functions.cfm">	

<!--- This is the list of values to be analyzed --->
<CFSET values=valuelist(Get_Commodity_Data.Comm_Last)>

<!--- Get Min & Max --->
<CFSET MinMax=MinMax(values)> 	

<CFOUTPUT>	
	<B><DIV CLASS="title2">General Data Statistics:</DIV></B>
	<BR>
	
<TABLE CELLPADDING="5">
	<TR>
		<TD ALIGN="right"><B>Min. Value</B></TD>
		<TD>#numberformat(MinMax.MinVal, '_.0000')#</TD>
	</TR>
	<TR>
		<TD ALIGN="right"><B>Max. Value</B></TD>
		<TD>#numberformat(MinMax.MaxVal, '_.0000')#</TD>
	</TR>
	<TR>
		<TD ALIGN="right"><B>Median:</B></TD>
		<TD>#numberformat(Median(values), '_.0000')#</TD>
	</TR>
	<TR>
		<TD ALIGN="right"><B>Range</B></TD>
		<TD>#numberformat(Range(values), '_.0000')#</TD>
	</TR>
	<TR>
		<TD ALIGN="right"><B>Mid Range:</B></TD>
		<TD>#numberformat(Midrange(values), '_.0000')#</TD>
	</TR>
	<TR>
		<TD ALIGN="right"><B>Average:</B></TD>
		<TD>#numberformat(Mean(values), '_.0000')#</TD>
	</TR>
	<TR>
		<TD ALIGN="right"><B>Std. Deviation(p):</B></TD>
		<TD>#numberformat(StdDevPop(values), '_.0000')#</TD>
	</TR>
	<TR>
		<TD ALIGN="right"><B>Std. Deviation(s):</B></TD>
		<TD>#numberformat(StdDevSamp(values), '_.0000')#</TD>
	</TR>
	<TR>
		<TD ALIGN="right"><BR>p - population<BR>s - sample</TD>
		<TD></TD>
	</TR>
</TABLE>
</CFOUTPUT>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Create the excel csv file																		 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<BLOCKQUOTE>
<BLOCKQUOTE>
<CENTER>





<!--- 
<!--- Delete any csv files older than 1 day --->
<CFDIRECTORY ACTION="LIST" DIRECTORY="#driveletter#:\inetpub\wwwroot\awayx\profits\excel_files" NAME="DirInfo">
<CFOUTPUT QUERY="DirInfo">
	<CFIF dateformat(DirInfo.dateLastModified, 'mm/dd/yyyy') LT dateformat(now(), 'mm/dd/yyyy')>
		<CFFILE ACTION="DELETE" FILE="#driveletter#:\inetpub\wwwroot\awayx\profits\excel_files\#DirInfo.name#">
	</CFIF>
</CFOUTPUT>
 --->


<cfset csvFile="">
<cfset crlf = chr(13)>

<!--- <cfset crlf = chr(13) & chr(10)> --->

<cfset csvFile = csvFile & '"date","closing price","previous closing","pricing movement"'&#crlf#>
<cfoutput query="Get_Commodity_Data">
	<cfset csvFile = csvFile & '"#dateformat(Comm_Datetime, 'm/d/yyyy')#","#numberformat(Comm_Last, '_.____')#",'>
	<CFIF Comm_Previous NEQ "">
		<cfset csvFile = csvFile & '"#numberformat(Comm_Previous, '_.____')#"'>
	</CFIF>
	<cfset csvFile = csvFile & ','>
	<CFIF Comm_Last NEQ "" AND Comm_Previous NEQ "">
		<cfset csvFile = csvFile & '"#numberformat(evaluate(Comm_Last-Comm_Previous), '+_.____')#"'>
	</CFIF>
	<cfset csvFile = csvFile & '#crlf#'>
</cfoutput>

<!--- Get the drive letter where the root lives													 --->
<!--- <CFSET DRIVELETTER=left(CGI.PATH_TRANSLATED,1)> --->
<CFSET FILENAME=createuuid()>

<!--- <CFSET appPath=APPLICATIONPATH> --->

<!------<cffile action="WRITE" file="#DRIVELETTER#:/inetpub/wwwroot/awayx/profits/excel_files/#FILENAME#.csv" OUTPUT=#csvFile#>----->
<cffile action="WRITE" file="#Application.Doc_Path#\temp_files\profits\excel_files\#FILENAME#.csv" OUTPUT=#csvFile#>

<CFOUTPUT>

<BR>
<FONT COLOR='Red'><B>[</B></FONT>&nbsp;
<!------<A HREF="excel_files/#FILENAME#.csv">----->
<A HREF="/download_Files/show_Download_Files.cfm?APPRELATIVEFILEPATH=profits/excel_files/#FILENAME#.csv&CONTENT_TYPE=application/ms-excel">
get XL data file</A>
&nbsp;<FONT COLOR='Red'><B>]</B></FONT>
</CFOUTPUT>


</CENTER>
</BLOCKQUOTE>
</BLOCKQUOTE>

	</TD>
</TR>
</TABLE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="view_commodity_footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



