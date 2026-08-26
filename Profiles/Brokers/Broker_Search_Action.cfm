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
	header 
		{font-size: 12px;}
</style>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the total count of the non-deleted, unique items in the database							 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Total_Count" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#" datasource="#application.datasource#">
Select 		count(BSA_Foodservice_Brokers_ID) as total_count
From		BSA_Foodservice_Brokers
Where		deleted		=	0
</CFQUERY>


<BR><BR>

<!--- if sortby isn't defined then it will be defined by Broker_Name,
which will be how you want it to be sorted by the first time the user loads the page--->
<CFPARAM name="sortby" default=#sortby#>
<CFPARAM name="sortorder" default=#sortorder#>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve Brokers																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="TheQuery" datasource="#application.datasource#" BLOCKFACTOR="50">

Select		*

From		BSA_Foodservice_Brokers

Where		deleted = 0
			<CFIF Market_Area NEQ "All">
				and
				Market_Area	=	'#Market_Area#'
			</CFIF>

			<CFIF State NEQ "All">
				and
				State	=	'#State#'
			</CFIF>

			<CFIF trim(searchstring) NEQ "">
				and
				(
					(
					Broker_Name 	like 	'%#searchstring#%'
					or
					Broker_Name 	like 	'#searchstring#%'
					or
					Broker_Name 	like 	'%#searchstring#'
					or
					Broker_Name 	=	 	'#searchstring#'
					)
					OR
					(
					Broker_CSR 	like 	'%#searchstring#%'
					or
					Broker_CSR 	like 	'#searchstring#%'
					or
					Broker_CSR 	like 	'%#searchstring#'
					or
					Broker_CSR 	=	 	'#searchstring#'
					)
					OR
					(
					Account_Exec 	like 	'%#searchstring#%'
					or
					Account_Exec 	like 	'#searchstring#%'
					or
					Account_Exec 	like 	'%#searchstring#'
					or
					Account_Exec 	=	 	'#searchstring#'
					)
					OR
					(
					City 	like 	'%#searchstring#%'
					or
					City 	like 	'#searchstring#%'
					or
					City 	like 	'%#searchstring#'
					or
					City 	=	 	'#searchstring#'
					)
				)
			</CFIF>

ORDER BY 	#sortby# #sortorder#

</CFQUERY>


<DIV CLASS="title2">
There are <CFOUTPUT>#Get_Total_Count.total_count#</CFOUTPUT> records in the database.
Your query returned <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> items
</DIV>
<HR COLOR="Orange">

<BR>


<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" BGCOLOR="dddddd" WIDTH="83%" CLASS="Maintable">
<CFOUTPUT>
<TR BGCOLOR="dddddd">
	<TD VALIGN="bottom" NOWRAP>&nbsp;</TD>
	<TD VALIGN="bottom" NOWRAP><DIV CLASS="data"><A HREF="Javascript: newSortBy('Broker_Name')">Broker Name</A></DIV></TD>
	<TD VALIGN="bottom" NOWRAP><DIV CLASS="data"><A HREF="Javascript: newSortBy('State')">Address</A></DIV></TD>
	<TD VALIGN="bottom" NOWRAP><DIV CLASS="data"><A HREF="Javascript: newSortBy('Market_Area')">Market Area</A></DIV></TD>
	<TD VALIGN="bottom" NOWRAP><DIV CLASS="data"><A HREF="Javascript: newSortBy('Account_Exec')">Account Executive</A></DIV></TD>
	<!--- <TD VALIGN="bottom" NOWRAP><DIV CLASS="data">Phone/Fax/Email</DIV></TD> --->
</TR>
</CFOUTPUT>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Defines the number of rows to display per "page"										       --->
	<cf_Number_of_Rows maxrows=#maxrows#>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFOUTPUT QUERY="TheQuery"  startrow="#StartRow#" maxrows="#MaxRows#">

<CFSET BID = BSA_Foodservice_Brokers_ID>
<cf_cryp type="en" string="#BID#" key="#caller.key#">
<CFSET GST_ID = BID>
<TR BGCOLOR="FFFFFF" STYLE="cursor:pointer;" onmouseover="CellOn(this)" onmouseout="CellOff(this)" TITLE="View this Broker's profile...">
	<TD VALIGN="top" ALIGN="center"><CF_GeneralSearchTool_OPTION></TD>
	<TD VALIGN="top" CLASS="data" NOWRAP ONCLICK="showProfile('#cryp.value#');">#Broker_Name#&nbsp;</TD>
	<TD VALIGN="top" CLASS="data" NOWRAP ONCLICK="showProfile('#cryp.value#');">#Address#<BR>#City# #State# #Zip#&nbsp;</TD>
	<TD VALIGN="top" CLASS="data" NOWRAP ONCLICK="showProfile('#cryp.value#');">#Market_Area#&nbsp;</TD>
	<TD VALIGN="top" CLASS="data" NOWRAP ONCLICK="showProfile('#cryp.value#');">#Account_Exec#&nbsp;</TD>
	<!--- <TD VALIGN="top" CLASS="data" NOWRAP>PH:#Phone_Number#&nbsp;&nbsp;FX:#Fax_Number#<BR>#E_Mail#&nbsp;</TD> --->
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
	function showProfile(ID){
		NewWindow('/Profiles/Brokers/Broker_profile.cfm?BID=' + ID,'name','400','450','Yes', 'No');	
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
	nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	addparams		=	"sortby,sortorder,maxrows,Market_Area,State,searchstring">


</DIV>
<HR COLOR="Orange" SIZE="2">


