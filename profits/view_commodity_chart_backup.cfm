<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Commodity Pricing</TITLE>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Error Checking Javascript code --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<script language="JavaScript">	
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
	</script>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">

<!--- Create a default comm_month_year value --->
<CFPARAM NAME="Comm_Month_Year" DEFAULT="">
<CFPARAM NAME="Year_of_Maturity" DEFAULT="">
<!--- Build the look up Comm_Month_Year database string --->
<CFSET Comm_Month_Year=Comm_Month_Year&Year_of_Maturity>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="view_commodity_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Properly format the dates after they're retrieved from database --->
<CFSET items="">
<CFLOOP QUERY="Get_Commodity_Data">
	<CFSET item=dateformat(Get_Commodity_Data.Comm_Datetime, 'm/d/yy')>
	<CFSET items=listappend(items,item)>
</CFLOOP>

<!--- Build list of values --->
<CFSET values=valuelist(Get_Commodity_Data.Comm_Last)>

<!--- Build the link to dataview --->
<CFSET link="view_commodity_data.cfm?Symbol=#URL.Symbol#&amp;datasize=#URL.datasize#">

<!--- CALCULATE THE "LABELEVERY" TICK PARAMETER --->
<CFSET TICKEVERY=EVALUATE(Get_Commodity_Data.recordcount/15)>

	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the datecodes for the commodities --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->	
<CFQUERY NAME="Get_Date_Codes" datasource="#application.datasource#">
Select * from Commodities_Datecode
</CFQUERY>	



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- The if statement "if COMMODITIES_DATECODE NEQ Y" filters out the datecode "Futures"			     
That is present in the commodity data that comes from DDFPlus										 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFIF Get_Commodity_Data.RecordCount GT datasize>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0"><TR><TD>
<FORM NAME="MyForm" ID="MyForm" onSubmit="return checkData()" ACTION="view_commodity_chart.cfm?Symbol=<CFOUTPUT>#URL.Symbol#&datasize=#datasize#</CFOUTPUT>" METHOD="post">
&nbsp;&nbsp;<SELECT NAME="Comm_Month_Year" STYLE="width: 200px;">
	<OPTION VALUE="">Please select month of maturity...</OPTION>
	<CFOUTPUT QUERY="Get_Date_Codes">
		<CFIF COMMODITIES_DATECODE NEQ "Y"><OPTION VALUE="#COMMODITIES_DATECODE#">#COMMODITIES_DATECODE_NAME#</OPTION></CFIF>
	</CFOUTPUT>
</SELECT>

<SELECT NAME="Year_of_Maturity" STYLE="width: 200px;">
	<OPTION VALUE="">Please select year of maturity...</OPTION>
	<OPTION VALUE="2">2002</OPTION>
	<OPTION VALUE="3">2003</OPTION>
	<OPTION VALUE="4">2004</OPTION>
	<OPTION VALUE="5">2005</OPTION>
</SELECT>
<INPUT TYPE="submit" VALUE="Create graph for this period" STYLE="width: 196px;">
</FORM></TD></TR></TABLE>

<CFELSE>

.<BR><BR><BR>

</CFIF>




<cfscript>
arrValues = ArrayNew(1);
// a line
tmpStruct = StructNew();
tmpStruct.x = "#items#";
tmpStruct.y = "#values#";
tmpStruct.color = "blue";
tmpStruct.url = "#link#";
tmpStruct.width = 2;
tmpStruct.target = "";
tmpStruct.alt = "The blue line";
ArrayAppend(arrValues, tmpStruct);
</cfscript>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Establish the bounderies of the values for the graph scale									 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Order the retrieved list of values in ascending order (it is by default) --->
	<CFSET neworder=listsort(valuelist(Get_Commodity_Data.Comm_Last), "Numeric")>
	<!--- The ScaleFrom Graph Value is the Min value minus 10% --->
	<CFSET SCALEFROM=ListFirst(neworder)*0.90>
	<!--- The ScaleTo Graph Value is the Max value plus 10% --->
	<CFSET SCALETO=ListLast(neworder)*1.10>

	
	
	
	
	
	
	
	
<CENTER>
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
</CENTER>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="view_commodity_footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>


<!--- 
Code to be used in case we ever get CFXGRAPHICSSERVER to work




<TABLE BORDER="1" CELLPADDING="0" CELLSPACING="0" ALIGN="center">
<TR>
	<TD>
<CFX_GRAPHICSSERVER 
	HEIGHT="345"				WIDTH="600"
	GRAPHTYPE="6"				GRAPHSTYLE="1"
	BACKCOLOR="120"				GRAPHBACKCOLOR="120"	COLORBYSET="9"
	SYMBOLBYSET="13"			SYMBOLSIZE="75"
	TRENDBYSET="24"				CURVEORDER="1"
	BESTFITLINECOLOR="12"		CURVETYPE="4"			MEANLINECOLOR="12"
	GRIDLINESTYLE="2"			GRIDSTYLE="3"			GRIDCOLOR="7"
	LABELFONTSIZE="+90"			LABELSTYLE="1"		
	TICKS="1"					TICKSTYLE="1" 			TICKEVERY="#TICKEVERY#"
	ST_DATASET0="#values#"		ST_XLABELS="#items#"></TD></TR></TABLE>




 --->


