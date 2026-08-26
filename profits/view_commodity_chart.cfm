<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Commodity Pricing</TITLE>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Error Checking Javascript code --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<SCRIPT LANGUAGE="JavaScript">	
		<!--BEGIN Script
		function checkData (){
		        if (document.MyForm.Comm_Month_Year.value == "") {
		                alert("To generate a chart for a maturity period you must select a month and a year.")
		                document.MyForm.Comm_Month_Year.focus()
		                return false}
		        if (document.MyForm.Year_of_Maturity.value == "") {
		                alert("To generate a chart for a maturity period you must select a month and a year.")
		                document.MyForm.Year_of_Maturity.focus()
		                return false}
		}
		// -->
	</SCRIPT>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="4" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0">

<!--- Create a default comm_month_year value --->
<CFPARAM NAME="Comm_Month_Year" DEFAULT="">
<CFPARAM NAME="Year_of_Maturity" DEFAULT="">
<!--- Build the look up Comm_Month_Year database string --->
<CFSET COMM_MONTH_YEAR=COMM_MONTH_YEAR&YEAR_OF_MATURITY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="view_commodity_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Properly format the dates after they're retrieved from database --->
<CFSET ITEMS="">
<CFLOOP QUERY="Get_Commodity_Data">
	<CFSET ITEM=DATEFORMAT(GET_COMMODITY_DATA.COMM_DATETIME, 'M/D/YY')>
	<CFSET ITEMS=LISTAPPEND(ITEMS,ITEM)>
</CFLOOP>

<!--- Build list of values --->
<CFSET VALUES=VALUELIST(GET_COMMODITY_DATA.COMM_LAST)>

<!--- Build the link to dataview --->
<CFSET LINK="view_commodity_data.cfm?Symbol=#URL.Symbol#&amp;datasize=#URL.datasize#">

<!--- CALCULATE THE "LABELEVERY" TICK PARAMETER --->
<CFSET TICKEVERY=EVALUATE(GET_COMMODITY_DATA.RECORDCOUNT/15)>

	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the datecodes for the commodities --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->	
<cfset useLakebaseForGet_Date_Codes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("commodities_datecode")>
<cfif useLakebaseForGet_Date_Codes>
	<cftry>
		<cfset Get_Date_Codes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("commodities_datecode", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Date_Codes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Date_Codes>
<CFQUERY NAME="Get_Date_Codes" datasource="#application.datasource#">
Select * from Commodities_Datecode
</CFQUERY>
</cfif>	




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Establish the bounderies of the values for the graph scale									 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Order the retrieved list of values in ascending order (it is by default) --->
	<CFSET NEWORDER=LISTSORT(VALUELIST(GET_COMMODITY_DATA.COMM_LAST), "Numeric")>

	<!--- The ScaleFrom Graph Value is the Min value minus 10% --->	
	<CFSET SCALEFROM=(LISTFIRST(NEWORDER)-1)*0.95>

	<!--- The ScaleTo Graph Value is the Max value plus 10% --->
	<CFSET SCALETO=(LISTLAST(NEWORDER)+1)*1.05>

<!--- 
	<!--- The ScaleFrom Graph Value is the Min value minus 10% --->
	<CFSET SCALEFROM=LISTFIRST(NEWORDER)*0.90>
	<!--- The ScaleTo Graph Value is the Max value plus 10% --->
	<CFSET SCALETO=LISTLAST(NEWORDER)*1.10>
 --->	

<!------ <CENTER>----->

<!--- 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
This is to be used with CF5 only...
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFGRAPH TYPE="LINE"
           QUERY="Get_Commodity_Data"
           VALUECOLUMN="Comm_Last"
           ITEMCOLUMN="Comm_Datetime"
           SCALEFROM="#SCALEFROM#"
           SCALETO="#SCALETO#"
           SHOWITEMLABEL="no"
           ITEMLABELFONT="Arial"
           ITEMLABELSIZE="4"
           ITEMLABELORIENTATION="VERTICAL"
           FILEFORMAT="JPG"
           LINECOLOR="##0000FF"
           LINEWIDTH="1"
           GRAPHHEIGHT="340"
           GRAPHWIDTH="600"
           BACKGROUNDCOLOR="##FFFFFF"
           BORDERCOLOR="##cccccc"
           BORDERWIDTH="1"
           DEPTH="0"
           GRIDLINES="10">
</CFGRAPH>

 --->   

 
<!--- Calculate the trend of the chart in question													 ---> 
<!-----
<CFINCLUDE TEMPLATE="commodity_trend.cfm"> 
------->

<CFINCLUDE TEMPLATE="commodity_view_data_menu.cfm">
 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- For CFMX only... --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="100%">
<TR>
<TD>
<CFCHART
           FORMAT="flash"
           CHARTHEIGHT="425"
           CHARTWIDTH="780"
           SCALEFROM="#SCALEFROM#"
           SCALETO="#SCALETO#"
           GRIDLINES="10"
           SERIESPLACEMENT="default"
           FOREGROUNDCOLOR="Black"
           LABELFORMAT="currency"
           TIPSTYLE="mouseOver"
           TIPBGCOLOR="White"
           FONTSIZE="9"
		   dataBackgroundColor = "##FFFFCC"
		   BACKGROUNDCOLOR="White">


	<CFCHARTSERIES
             TYPE="line"
             SERIESLABEL="Commodity Price"
             SERIESCOLOR="Red"
             PAINTSTYLE="light">
			<CFLOOP QUERY="Get_Commodity_Data">
				<cfchartdata item = "#dateformat(Comm_Datetime, "m/d/yy")#" value = "#Comm_Last#">
			</CFLOOP>
	</CFCHARTSERIES>
	

<!--- 

Uncomment this block to display best fit line trends...

	<CFCHARTSERIES
             TYPE="line"
             SERIESLABEL="Trend Analysis Correlation #numberformat(r, "0.0000")#"
             SERIESCOLOR="Blue"
             PAINTSTYLE="light">
				<cfchartdata item = "#dateformat(ListFirst(valuelist(Get_Commodity_Data.Comm_Datetime)), "m/d/yy")#" value = "#firstpoint#">
				<cfchartdata item = "#dateformat(ListLast(valuelist(Get_Commodity_Data.Comm_Datetime)), "m/d/yy")#" value = "#lastpoint#">
	</CFCHARTSERIES>
 --->
</CFCHART>
</TD>
<!------<TD>&nbsp;&nbsp;
</TD>
<TD VALIGN="top">
	
	<BR><BR><BR><BR><BR>
	<CFOUTPUT>
	<BR><B><FONT COLOR="Red">[</FONT></B>&nbsp;<A HREF="/profits/view_commodity_chart.cfm?Symbol=#URL.Symbol#&datasize=30">&nbsp;&nbsp;30 days</A>&nbsp;<B><FONT COLOR="Red">]</FONT></B>&nbsp;
	<BR><B><FONT COLOR="Red">[</FONT></B>&nbsp;<A HREF="/profits/view_commodity_chart.cfm?Symbol=#URL.Symbol#&datasize=45">&nbsp;&nbsp;45 days</A>&nbsp;<B><FONT COLOR="Red">]</FONT></B>&nbsp;
	<BR><B><FONT COLOR="Red">[</FONT></B>&nbsp;<A HREF="/profits/view_commodity_chart.cfm?Symbol=#URL.Symbol#&datasize=60">&nbsp;&nbsp;60 days</A>&nbsp;<B><FONT COLOR="Red">]</FONT></B>&nbsp;
	<BR><B><FONT COLOR="Red">[</FONT></B>&nbsp;<A HREF="/profits/view_commodity_chart.cfm?Symbol=#URL.Symbol#&datasize=90">&nbsp;&nbsp;90 days</A>&nbsp;<B><FONT COLOR="Red">]</FONT></B>
	<BR><B><FONT COLOR="Red">[</FONT></B>&nbsp;<A HREF="/profits/view_commodity_chart.cfm?Symbol=#URL.Symbol#&datasize=120">120 days</A>&nbsp;<B><FONT COLOR="Red">]</FONT></B>
	</CFOUTPUT>
</TD>
</TR>----->
</TABLE>
<br>
<CFOUTPUT>
<!--- <TD>
<B><FONT COLOR="Red">[</FONT></B>&nbsp;<A HREF="/profits/view_commodity_chart.cfm?Symbol=#URL.Symbol#&datasize=30">30 days</A>&nbsp;<B><FONT COLOR="Red">]</FONT></B>&nbsp;
<B><FONT COLOR="Red">[</FONT></B>&nbsp;<A HREF="/profits/view_commodity_chart.cfm?Symbol=#URL.Symbol#&datasize=45">45 days</A>&nbsp;<B><FONT COLOR="Red">]</FONT></B>&nbsp;
<B><FONT COLOR="Red">[</FONT></B>&nbsp;<A HREF="/profits/view_commodity_chart.cfm?Symbol=#URL.Symbol#&datasize=60">60 days</A>&nbsp;<B><FONT COLOR="Red">]</FONT></B>&nbsp;
<B><FONT COLOR="Red">[</FONT></B>&nbsp;<A HREF="/profits/view_commodity_chart.cfm?Symbol=#URL.Symbol#&datasize=90">90 days</A>&nbsp;<B><FONT COLOR="Red">]</FONT></B>
<B><FONT COLOR="Red">[</FONT></B>&nbsp;<A HREF="/profits/view_commodity_chart.cfm?Symbol=#URL.Symbol#&datasize=120">120 days</A>&nbsp;<B><FONT COLOR="Red">]</FONT></B>
</TD>
<TD>&nbsp;</TD>
 --->
<!--- <CFPARAM NAME="startdate" DEFAULT="">
<CFPARAM NAME="enddate" DEFAULT=""> --->
<!--- <CFSET startdate="">
<CFSET enddate=""> --->
<!--- #Now()# --->

</CFOUTPUT>

<script SRC="/billbacks/common/common_js_functions.js"></script>
<SCRIPT LANGUAGE="JavaSCript">
	function submitForm(thisobj)
	{
		getParentObject(thisobj, 'form').submit();
		return false;
	}
</SCRIPT>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="2" WIDTH="100%">
<TR>
<TD WIDTH="350">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- The if statement "if COMMODITIES_DATECODE NEQ Y" filters out the datecode "Futures"			     
That is present in the commodity data that comes from DDFPlus										 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
<TR>
<CFIF GET_COMMODITY_DATA.RECORDCOUNT GT DATASIZE>

<FORM NAME="MyForm" ID="MyForm" onSubmit="return checkData()" ACTION="view_commodity_chart.cfm?Symbol=<CFOUTPUT>#URL.Symbol#&datasize=#datasize#</CFOUTPUT>" METHOD="post" STYLE="DISPLAY:INLINE;">
<TD>
<B>Month of maturity</B><BR>
<SELECT NAME="Comm_Month_Year" STYLE="width: 120px;">
	<OPTION VALUE="">Month of maturity...</OPTION>
	<CFOUTPUT QUERY="Get_Date_Codes">
		<CFIF COMMODITIES_DATECODE NEQ "Y"><OPTION VALUE="#COMMODITIES_DATECODE#">#COMMODITIES_DATECODE_NAME#</OPTION></CFIF>
	</CFOUTPUT>
</SELECT>
</TD>
<CFOUTPUT>
<CFSET YEAR1 = YEAR(NOW())>
<CFSET YEAR2 = YEAR1 + 1>
<CFSET YEAR3 = YEAR2 + 1>
<CFSET YEAR4 = YEAR3 + 1>
<CFSET YEAR5 = YEAR4 + 1>
<TD>
<B>Year of maturity</B><BR>
<SELECT NAME="Year_of_Maturity" STYLE="width: 120px;">
	<OPTION VALUE="">Year of maturity...</OPTION>
	<OPTION VALUE="#Right(Year1, 1)#">#Year1#</OPTION>
	<OPTION VALUE="#Right(Year2, 1)#">#Year2#</OPTION>
	<OPTION VALUE="#Right(Year3, 1)#">#Year3#</OPTION>
	<OPTION VALUE="#Right(Year4, 1)#">#Year4#</OPTION>
</SELECT>
</TD>

<TD VALIGN="bottom">
<!------<INPUT TYPE="submit" VALUE="Create graph for this period" STYLE="width: 150px;">----->
<B><FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
		<A HREF="void(0);" ONCLICK="javascript: return submitForm(this);">create graph</A>
	<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT></B>
<TD>
</FORM>
<TD>&nbsp;&nbsp;</TD>

</CFOUTPUT>
<CFELSE>
<TD>
&nbsp;&nbsp;
</TD>

</CFIF>
<!------<CFOUTPUT>
<TD>
<B><FONT COLOR="Red">[</FONT></B>&nbsp;<A HREF="/profits/view_commodity_chart.cfm?Symbol=#URL.Symbol#&datasize=30">30 days</A>&nbsp;<B><FONT COLOR="Red">]</FONT></B>&nbsp;
<B><FONT COLOR="Red">[</FONT></B>&nbsp;<A HREF="/profits/view_commodity_chart.cfm?Symbol=#URL.Symbol#&datasize=45">45 days</A>&nbsp;<B><FONT COLOR="Red">]</FONT></B>&nbsp;
<B><FONT COLOR="Red">[</FONT></B>&nbsp;<A HREF="/profits/view_commodity_chart.cfm?Symbol=#URL.Symbol#&datasize=60">60 days</A>&nbsp;<B><FONT COLOR="Red">]</FONT></B>&nbsp;
<B><FONT COLOR="Red">[</FONT></B>&nbsp;<A HREF="/profits/view_commodity_chart.cfm?Symbol=#URL.Symbol#&datasize=90">90 days</A>&nbsp;<B><FONT COLOR="Red">]</FONT></B>
<B><FONT COLOR="Red">[</FONT></B>&nbsp;<A HREF="/profits/view_commodity_chart.cfm?Symbol=#URL.Symbol#&datasize=120">120 days</A>&nbsp;<B><FONT COLOR="Red">]</FONT></B>
</CFOUTPUT>----->
</TD></TR></TABLE>
</TD>
<TD WIDTH="430">
<CFINCLUDE TEMPLATE="commodity_date_form.cfm">
</TD>
</TR>
</TABLE>

 
 

<!------</CENTER>----->

<CENTER>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="view_commodity_footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</CENTER>

</BODY>
</HTML>
