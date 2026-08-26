
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFSET helpfilenumber=14>
<CFINCLUDE TEMPLATE="/help_files/help_link.cfm"> --->
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
Select 		count(BSA_Foodservice_Customers_ID) as total_count
From		BSA_Foodservice_Customers
Where		deleted		=	0
</CFQUERY>


<!--- if sortby isn't defined then it will be defined by Distributor_Name,
which will be how you want it to be sorted by the first time the user loads the page--->
<CFPARAM name="sortby" default=#sortby#>
<CFPARAM name="sortorder" default=#sortorder#>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve Distributors																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="TheQuery" datasource="#application.datasource#" BLOCKFACTOR="50">

Select		*

From		BSA_Foodservice_Customers

Where		deleted = 0

			<CFIF Family_Name NEQ "All">
				and
				Family_Name	=	'#Family_Name#'
			</CFIF>

			<CFIF Std_Broker NEQ "All">
				and
				Std_Broker	=	'#Std_Broker#'
			</CFIF>

			<CFIF State NEQ "All">
				and
				State	=	'#State#'
			</CFIF>

			<CFIF Market_Area NEQ "All">
				and
				Std_Broker	=	'#Market_Area#'
			</CFIF>

			<CFIF trim(searchstring) NEQ "">
				and
				(
					(
					Name 	like 	'%#searchstring#%'
					or
					Name 	like 	'#searchstring#%'
					or
					Name 	like 	'%#searchstring#'
					or
					Name 	=	 	'#searchstring#'
					)
					OR
					(
					Family_Name 	like 	'%#searchstring#%'
					or
					Family_Name 	like 	'#searchstring#%'
					or
					Family_Name 	like 	'%#searchstring#'
					or
					Family_Name 	=	 	'#searchstring#'
					)
				)
			</CFIF>

ORDER BY 	#sortby# #sortorder#

</CFQUERY>

<BR><BR>

<SPAN CLASS="title2"><CFOUTPUT>There are<CFIF TheQuery.Recordcount EQ 0> no <CFELSE> #TheQuery.Recordcount# </CFIF><cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput> that match the above criteria</CFOUTPUT></SPAN>
<!--- There are <CFOUTPUT>#Get_Total_Count.total_count#</CFOUTPUT> records in the database. --->
<!--- Your query returned <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> items
 --->
<HR COLOR="Orange">

<BR>


<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" BGCOLOR="dddddd" CLASS="Maintable" WIDTH="800">
<CFOUTPUT>
<TR BGCOLOR="dddddd">
	<TD>&nbsp;</TD>
	<TD VALIGN="bottom" NOWRAP><DIV CLASS="data"><A HREF="Javascript: newSortBy('Ship_To')">#application.returned_customer_setting.shard_ship_to_label#</A></DIV></TD>
	<TD VALIGN="bottom" NOWRAP><DIV CLASS="data"><A HREF="Javascript: newSortBy('Name')">Distributor Name</A></DIV></TD>
	<TD VALIGN="bottom" NOWRAP><DIV CLASS="data"><A HREF="Javascript: newSortBy('State')">Address</A></DIV></TD>
	<TD VALIGN="bottom" NOWRAP><DIV CLASS="data"><A HREF="Javascript: newSortBy('Family_Name')">Family Name</A></DIV></TD>
</TR>
</CFOUTPUT>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Defines the number of rows to display per "page"										       --->
	<cf_Number_of_Rows maxrows=#maxrows#>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFOUTPUT QUERY="TheQuery"  startrow="#StartRow#" maxrows="#MaxRows#">
<cfset DID = BSA_Foodservice_Customers_ID>
<CFSET GST_ID = BSA_Foodservice_Customers_ID>
<CF_Cryp type="en" string="#DID#" key="#caller.key#">

<TR BGCOLOR="White" STYLE="cursor:pointer;"  onMouseOver="CellOn(this)" onMouseOut="CellOff(this)"  TITLE="View this Distributor's profile...">
	<TD VALIGN="top" CLASS="data" NOWRAP><CF_GeneralSearchTool_OPTION></TD>
	<TD VALIGN="top" CLASS="data" NOWRAP onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#cryp.value#','name','400','450','Yes', 'No');return false;">#Ship_To#&nbsp;</TD>
	<TD VALIGN="top" CLASS="data" NOWRAP onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#cryp.value#','name','400','450','Yes', 'No');return false;">#Name#&nbsp;</TD>
	<TD VALIGN="top" CLASS="data" NOWRAP onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#cryp.value#','name','400','450','Yes', 'No');return false;">#Address_1# #Address_2#<BR>#City# #State# #ZipCode#&nbsp;</TD>
	<TD VALIGN="top" CLASS="data" NOWRAP onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#cryp.value#','name','400','450','Yes', 'No');return false;">#Family_Name#&nbsp;</TD>
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


<cf_Next_Previous_FOR_GENERALSEARCHTOOL
	maxpages		=	"25"
	query			=	"TheQuery"										
	previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
	next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
	previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">">


</DIV>
<HR COLOR="Orange" SIZE="2">


