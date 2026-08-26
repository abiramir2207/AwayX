<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Search</title>
</head>

<body>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=16>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
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
Select 		distinct count(Operator_Name) as total_count
From		BSA_Operator
Where		deleted		=	0
</CFQUERY>


<!--- if sortby isn't defined then it will be defined by Operator_Name,
which will be how you want it to be sorted by the first time the user loads the page--->
<CFPARAM name="sortby" default=#sortby#>
<CFPARAM name="sortorder" default=#sortorder#>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve operators																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="TheQuery" datasource="#application.datasource#" BLOCKFACTOR="50">

Select		BSA_Operator_ID,
			Operator_Name,
			Operator_DBA,
			Operator_City,
			Operator_State,
			Operator_Number_Of_Locations,
			Operator_Location_Type,
			Operator_Type

From		BSA_Operator

Where		deleted = 0
			<CFIF Operator_State NEQ "All">
				and
				Operator_State	=	'#Operator_State#'
			</CFIF>

			<CFIF Operator_Type NEQ "All">
				and
				Operator_Type	=	'#Operator_Type#'
			</CFIF>
			
			<CFIF Operator_Location_Type NEQ "All">
				and
				Operator_Location_Type	=	'#Operator_Location_Type#'
			</CFIF>
			
			<CFIF trim(Operator_Name) NEQ "">
				and
				(
					Operator_Name 	like 	'%#Operator_Name#%'
					or
					Operator_Name 	like 	'#Operator_Name#%'
					or
					Operator_Name 	like 	'%#Operator_Name#'
					or
					Operator_Name 	=	 	'#Operator_Name#'
				)
			</CFIF>
			
			<CFIF trim(Operator_City) NEQ "">
				and
				(
					Operator_City 	like 	'%#Operator_City#%'
					or
					Operator_City 	like 	'#Operator_City#%'
					or
					Operator_City 	like 	'%#Operator_City#'
					or
					Operator_City 	like 	'#Operator_City#'
				)
			</CFIF>

			<CFIF trim(Operator_DBA) NEQ "">
				and
				(
					Operator_DBA 	like 	'%#Operator_DBA#%'
					or
					Operator_DBA 	like 	'#Operator_DBA#%'
					or
					Operator_DBA 	like 	'%#Operator_DBA#'
					or
					Operator_DBA 	like 	'#Operator_DBA#'
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

<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" BGCOLOR="dddddd"  CLASS="Maintable">
<CFOUTPUT>

<TR BGCOLOR="dddddd">
	<TD><cf_GeneralSearchTool_OPTION selectall="yes"></TD>
	<TD VALIGN="bottom" NOWRAP><DIV CLASS="data"><A HREF="Javascript: newSortBy('Operator_Name')"><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Name</A></DIV></TD>
	<TD VALIGN="bottom" NOWRAP><DIV CLASS="data"><A HREF="Javascript: newSortBy('Operator_City')">City</A></DIV></TD>
	<TD VALIGN="bottom" NOWRAP><DIV CLASS="data"><A HREF="Javascript: newSortBy('Operator_State')">State</A></DIV></TD>
	<TD VALIGN="bottom" NOWRAP><DIV CLASS="data"><A HREF="Javascript: newSortBy('Operator_Number_of_Locations')">Locations</A></DIV></TD>
	<TD VALIGN="bottom" NOWRAP><DIV CLASS="data"><A HREF="Javascript: newSortBy('Operator_Type')"><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Type</A></DIV></TD>
	<TD VALIGN="bottom" NOWRAP><DIV CLASS="data"><A HREF="Javascript: newSortBy('Operator_Location_Type')">Location Type</B></A></DIV></TD>
	<TD VALIGN="bottom" WIDTH="250"><DIV CLASS="data">Does Business As...</TD>
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
<cf_cryp type="en" string ="#BSA_Operator_ID#" key="#caller.key#">
<CFSET OID = cryp.value>


<TR BGCOLOR="White" STYLE="cursor:pointer;"  onMouseOver="CellOn(this)" onMouseOut="CellOff(this)"  TITLE="View this Operator's profile...">
	<CFSET GST_ID=cryp.value>
	<TD VALIGN="top"><cf_GeneralSearchTool_OPTION></TD>
	<TD VALIGN="top" CLASS="data" NOWRAP onclick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#OID#','name','400','450','Yes', 'No');return false;">#Operator_Name#&nbsp;</TD>
	<TD VALIGN="top" CLASS="data" NOWRAP onclick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#OID#','name','400','450','Yes', 'No');return false;">#Operator_City#&nbsp;</TD>
	<TD VALIGN="top" CLASS="data" NOWRAP onclick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#OID#','name','400','450','Yes', 'No');return false;">#Operator_State#&nbsp;</TD>
	<TD VALIGN="top" CLASS="data" NOWRAP onclick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#OID#','name','400','450','Yes', 'No');return false;"><CFIF Operator_Number_of_Locations EQ 0>n/a<CFELSE>#numberformat(Operator_Number_Of_Locations, '_,___,___')#&nbsp;</CFIF></TD>
	<TD VALIGN="top" CLASS="data" NOWRAP onclick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#OID#','name','400','450','Yes', 'No');return false;">#Operator_Type#&nbsp;</TD>
	<TD VALIGN="top" CLASS="data" NOWRAP onclick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#OID#','name','400','450','Yes', 'No');return false;">#Operator_Location_Type#&nbsp;</TD>
	<TD VALIGN="top" CLASS="data" onclick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#OID#','name','400','450','Yes', 'No');return false;">#Operator_DBA#&nbsp;</TD>
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
</body>
</html>

