<CFSET PAGE_TITLE="Home">


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">


	
	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Give this window a name so that popup based forms can return data to it						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->	
<script language="JavaScript">
	<!--
		window.name="mywindowname";
	//-->
</script>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



</HEAD>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=12>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<style>
	body, table, td
		{font-family: Arial; font-size: 12px;}
	.data
		{font-size: 12px; font-weight: bold}
	input,select, TEXTAREA
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
	<TD VALIGN="bottom" NOWRAP><DIV CLASS="data"><A HREF="Broker_Search_Action.cfm?sortby=Broker_Name&	sortorder=#sortorder#&maxrows=#maxrows#&Market_Area=#Market_Area#&State=#state#&searchstring=#searchstring#">Broker Name</A></DIV></TD>
	<TD VALIGN="bottom" NOWRAP><DIV CLASS="data"><A HREF="Broker_search_action.cfm?sortby=State&		sortorder=#sortorder#&maxrows=#maxrows#&Market_Area=#Market_Area#&State=#state#&searchstring=#searchstring#">Address</A></DIV></TD>
	<TD VALIGN="bottom" NOWRAP><DIV CLASS="data"><A HREF="Broker_search_action.cfm?sortby=Market_Area&	sortorder=#sortorder#&maxrows=#maxrows#&Market_Area=#Market_Area#&State=#state#&searchstring=#searchstring#">Market Area</A></DIV></TD>
	<TD VALIGN="bottom" NOWRAP><DIV CLASS="data"><A HREF="Broker_search_action.cfm?sortby=Account_Exec&	sortorder=#sortorder#&maxrows=#maxrows#&Market_Area=#Market_Area#&State=#state#&searchstring=#searchstring#">Account Executive</A></DIV></TD>
	<!--- <TD VALIGN="bottom" NOWRAP><DIV CLASS="data">Phone/Fax/Email</DIV></TD> --->
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
<cf_cryp type="en" string ="#BSA_Foodservice_Brokers_ID#" key="#request.key#">
<CFSET BID = cryp.value>

<TR BGCOLOR="FFFFFF" STYLE="cursor:hand;" onmouseover="CellOn(this)" onmouseout="CellOff(this)" onclick="NewWindow('/profiles/Brokers/Broker_profile.cfm?BID=#BID#','name','400','450','Yes', 'No');return false;" TITLE="View this Broker's profile...">
	<TD VALIGN="top" CLASS="data" NOWRAP>#Broker_Name#&nbsp;</TD>
	<TD VALIGN="top" CLASS="data" NOWRAP>#Address#<BR>#City# #State# #Zip#&nbsp;</TD>
	<TD VALIGN="top" CLASS="data" NOWRAP>#Market_Area#&nbsp;</TD>
	<TD VALIGN="top" CLASS="data" NOWRAP>#Account_Exec#&nbsp;</TD>
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
</SCRIPT>


<BR>

<HR COLOR="Orange" SIZE="2">
<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">


<cf_Next_Previous 
	maxpages		=	"25"
	query			=	"TheQuery"										
	previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
	next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
	previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	addparams		=	"sortby,sortorder,maxrows,Market_Area,State,searchstring">


</DIV>
<HR COLOR="Orange" SIZE="2">

