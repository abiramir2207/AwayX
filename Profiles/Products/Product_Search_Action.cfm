
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=20>
<CFINCLUDE TEMPLATE="/help_files/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<style>
	body, table, td
		{font-family: Arial; font-size: 12px;}
	.data
		{font-size: 12px; font-weight: bold}
	select, TEXTAREA
		{width:	200px;font-size: 10px;}
	TEXTAREA
		{width:	400px;font-size: 10px;}

	TABLE.Maintable TD 
		{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header 
		{font-size: 12px;}
</style>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the total count of the non-deleted, unique items in the database							 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Total_Count" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#" datasource="#application.datasource#">
Select 		distinct count(UPC) as total_count
From		BSA_Foodservice_Items_Master
Where		deleted		=	0
</CFQUERY>


<!--- if sortby isn't defined then it will be defined by product_Name,
which will be how you want it to be sorted by the first time the user loads the page--->
<CFPARAM name="sortby" default=#sortby#>
<CFPARAM name="sortorder" default=#sortorder#>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve products																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="TheQuery" datasource="#application.datasource#" BLOCKFACTOR="50">

Select		*

From		BSA_Foodservice_Items_Master

Where		deleted = 0
			<CFIF Type_Group_Desc NEQ "All">
				and
				Type_Group_Desc	=	'#Type_Group_Desc#'
			</CFIF>

			<CFIF Q_Brand_Desc NEQ "All">
				and
				Q_Brand_Desc	=	'#Q_Brand_Desc#'
			</CFIF>
			
			<CFIF Type_Code_Desc NEQ "All">
				and
				Type_Code_Desc	=	'#Type_Code_Desc#'
			</CFIF>
			
			<CFIF Brand NEQ "All">
				and
				Brand	=	'#Brand#'
			</CFIF>

			<CFIF trim(searchstring) NEQ "">
				and
				(
					(
					upc 	like 	'%#searchstring#%'
					or
					upc 	like 	'#searchstring#%'
					or
					upc 	like 	'%#searchstring#'
					or
					upc 	=	 	'#searchstring#'
					)
					OR
					(
					Item 	like 	'%#searchstring#%'
					or
					Item 	like 	'#searchstring#%'
					or
					Item 	like 	'%#searchstring#'
					or
					Item 	=	 	'#searchstring#'
					)
					OR
					(
					Description 	like 	'%#searchstring#%'
					or
					Description 	like 	'#searchstring#%'
					or
					Description 	like 	'%#searchstring#'
					or
					Description 	=	 	'#searchstring#'
					)
					OR
					(
					Type_Group_Desc 	like 	'%#searchstring#%'
					or
					Type_Group_Desc 	like 	'#searchstring#%'
					or
					Type_Group_Desc 	like 	'%#searchstring#'
					or
					Type_Group_Desc 	=	 	'#searchstring#'
					)
					OR
					(
					Q_Brand_Desc 	like 	'%#searchstring#%'
					or
					Q_Brand_Desc 	like 	'#searchstring#%'
					or
					Q_Brand_Desc 	like 	'%#searchstring#'
					or
					Q_Brand_Desc 	=	 	'#searchstring#'
					)
					OR
					(
					Type_Code_Desc 	like 	'%#searchstring#%'
					or
					Type_Code_Desc 	like 	'#searchstring#%'
					or
					Type_Code_Desc 	like 	'%#searchstring#'
					or
					Type_Code_Desc 	=	 	'#searchstring#'
					)
					OR
					(
					Brand 	like 	'%#searchstring#%'
					or
					Brand 	like 	'#searchstring#%'
					or
					Brand 	like 	'%#searchstring#'
					or
					Brand 	=	 	'#searchstring#'
					)
				)
			</CFIF>

ORDER BY 	#sortby# #sortorder#

</CFQUERY>


<BR><BR>


<DIV CLASS="title2">
There are <CFOUTPUT>#Get_Total_Count.total_count#</CFOUTPUT> records in the database.

Your query returned <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> items
</DIV>
<HR COLOR="Orange">



<BR>

<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" BGCOLOR="dddddd" WIDTH="85%" CLASS="Maintable">
<CFOUTPUT>
<TR BGCOLOR="dddddd">
	<TD><CF_GeneralSearchTool_OPTION selectall="yes"></TD>
	<TD VALIGN="bottom" NOWRAP><DIV  CLASS="data"><A HREF="Javascript: newSortBy('upc')">#application.returned_customer_setting.upc_label# Code</A></DIV></TD>
	<TD VALIGN="bottom" NOWRAP><DIV  CLASS="data"><A HREF="Javascript: newSortBy('Item')">#application.returned_customer_setting.item_label# Number</A></DIV></TD>
	<TD VALIGN="bottom" NOWRAP><DIV  CLASS="data"><A HREF="Javascript: newSortBy('Description')">Product Description</A></DIV></TD>
	<!--- <TD VALIGN="bottom" NOWRAP><DIV  CLASS="data"><A HREF="product_search_action.cfm?sortby=Type_Group_Desc&	sortorder=#sortorder#&maxrows=#maxrows#&Type_Group_Desc=#Type_Group_Desc#&Q_Brand_Desc=#Q_Brand_Desc#&Type_Code_Desc=#Type_Code_Desc#&Brand=#Brand#&searchstring=#searchstring#">Type Group</A></DIV></TD> --->
	<!--- <TD VALIGN="bottom" NOWRAP><DIV  CLASS="data"><A HREF="product_search_action.cfm?sortby=Q_Brand_Desc&		sortorder=#sortorder#&maxrows=#maxrows#&Type_Group_Desc=#Type_Group_Desc#&Q_Brand_Desc=#Q_Brand_Desc#&Type_Code_Desc=#Type_Code_Desc#&Brand=#Brand#&searchstring=#searchstring#">Q Brand</A></DIV></TD> --->
	<TD VALIGN="bottom" NOWRAP><DIV  CLASS="data"><A HREF="Javascript: newSortBy('Type_Code_Desc')">Type Code</A></DIV></TD>
	<TD VALIGN="bottom" NOWRAP><DIV  CLASS="data"><A HREF="Javascript: newSortBy('Brand')">Brand</A></DIV></TD>
</TR>
</CFOUTPUT>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Defines the number of rows to display per "page"										       --->
	<cf_Number_of_Rows maxrows=#maxrows#>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFOUTPUT QUERY="TheQuery"  startrow="#StartRow#" maxrows="#MaxRows#">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Encrypt the URL																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cf_cryp type="en" string ="#UPC#" key="#caller.key#">
<CFSET PID = cryp.value>


<TR BGCOLOR="White" STYLE="cursor:pointer;"  onMouseOver="CellOn(this)" onMouseOut="CellOff(this)" TITLE="View this Product's profile...">
	<CFSET GST_ID = upc>
	<TD><CF_GeneralSearchTool_OPTION></TD>
	<TD VALIGN="top" CLASS="data" NOWRAP onclick="NewWindow('/profiles/products/product_profile.cfm?PID=#PID#','name','400','450','Yes', 'No');return false;">#Item#&nbsp;</TD>
	<TD VALIGN="top" CLASS="data" NOWRAP onclick="NewWindow('/profiles/products/product_profile.cfm?PID=#PID#','name','400','450','Yes', 'No');return false;">#upc#&nbsp;</TD>
	<TD VALIGN="top" CLASS="data" NOWRAP onclick="NewWindow('/profiles/products/product_profile.cfm?PID=#PID#','name','400','450','Yes', 'No');return false;">#Description#&nbsp;</TD>
	<!--- <TD VALIGN="top" CLASS="data" NOWRAP>#Type_Group_Desc#&nbsp;</TD> --->
	<!--- <TD VALIGN="top" CLASS="data" NOWRAP>#Q_Brand_Desc#&nbsp;</TD> --->
	<TD VALIGN="top" CLASS="data" NOWRAP onclick="NewWindow('/profiles/products/product_profile.cfm?PID=#PID#','name','400','450','Yes', 'No');return false;">#Type_Code_Desc#&nbsp;</TD>
	<TD VALIGN="top" CLASS="data" NOWRAP onclick="NewWindow('/profiles/products/product_profile.cfm?PID=#PID#','name','400','450','Yes', 'No');return false;">#Brand#&nbsp;</TD>
</TR>
</CFOUTPUT>
</TABLE>

<SCRIPT language="JavaScript">
	function CellOn(CellName)
		{
			eval("CellName.bgColor = 'CCFFCC'")
		}

	function CellOff(CellName)
		{
			eval("CellName.bgColor = 'FFFFFF'")
		}
</SCRIPT>




<BR>

<HR COLOR="Orange" SIZE="2">
<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">


<cf_Next_Previous_for_GENERALSEARCHTOOL 
	maxpages		=	"25"
	query			=	"TheQuery"									
	previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
	next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
	previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">">


</DIV>
<HR COLOR="Orange" SIZE="2">

