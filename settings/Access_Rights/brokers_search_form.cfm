
<CFSET PageTitle="#ucase(application.returned_customer_setting.broker_label_plural)#<!--- BROKERS --->: LIST #ucase(application.returned_customer_setting.broker_label_plural)#<!--- BROKERS --->">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFSET helpfilenumber=33> --->
<!--- <CFINCLUDE TEMPLATE="/help_files/help_link.cfm"> --->
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<CFPARAM NAME="StartRow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<cf_Number_of_Rows maxrows=25>

<CFPARAM NAME="FORM.BROKER_NAME" 	DEFAULT="">

<CFPARAM NAME="FORM.SORT_BY" 	DEFAULT="Broker_Name">
<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="">

<CFIF FORM.SORT_ORDER NEQ "DESC">
	<CFSET FORM.SORT_ORDER = "ASC">
</CFIF>
<CFSET SQL_Sort_by = "Broker_Name">

<CFSWITCH EXPRESSION="#LCase(FORM.SORT_BY)#">
	<CFCASE VALUE="broker_name">
		<CFSET SQL_Sort_by = "Broker_Name">
	</CFCASE>
	<CFCASE VALUE="id">
		<CFSET SQL_Sort_by = "Broker_Shard">
	</CFCASE>
	<CFCASE VALUE="zone">
		<CFSET SQL_Sort_by = "Zone_Name">
	</CFCASE>
	<CFCASE VALUE="region">
		<CFSET SQL_Sort_by = "Region_Name">
	</CFCASE>
	<CFCASE VALUE="market">
		<CFSET SQL_Sort_by = "Market_Name">
	</CFCASE>
</CFSWITCH>

<CFSET SQL_Sort_by = " #SQL_Sort_by# #FORM.SORT_ORDER#">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BR>
<CFQUERY NAME="getAllBrokers" datasource="#application.datasource#">
SELECT		dbo.BSA_Foodservice_Brokers.*, dbo._states.State_Code, dbo._states.State_ID, dbo.Service_Zones.Zone_Name, 
			dbo.Service_Regions.Region_Name, Service_Markets.Market_Name
FROM		dbo.BSA_Foodservice_Brokers 
			LEFT JOIN	dbo._states 
			ON dbo.BSA_Foodservice_Brokers.State = dbo._states.State_Code 
			LEFT JOIN	dbo.Line_Of_Business 
			ON dbo.BSA_Foodservice_Brokers.Line_Of_Business_ID = dbo.Line_Of_Business.Line_Of_Business_ID 
			LEFT JOIN	dbo.Service_Regions 
			ON dbo.BSA_Foodservice_Brokers.Service_Region_ID = dbo.Service_Regions.Service_Region_ID 
			LEFT JOIN	dbo.Service_Zones 
			ON dbo.BSA_Foodservice_Brokers.Service_Zone_ID = dbo.Service_Zones.Service_Zone_ID
			LEFT JOIN	Service_Markets
			ON BSA_Foodservice_Brokers.Service_Market_ID = Service_Markets.Service_Market_ID
WHERE     	(dbo.BSA_Foodservice_Brokers.Deleted = 0) 
			AND (dbo.BSA_Foodservice_Brokers.Active_Code = 'A') 
			--AND (dbo.Line_Of_Business.Line_Of_Business IN (#ListQualify(application.returned_customer_setting.Line_Business_Default, "'", ",")#) )
			<CFIF FORM.BROKER_NAME NEQ "">
			AND BSA_Foodservice_Brokers.Broker_Name LIKE '#FORM.BROKER_NAME#%'
			</CFIF>
	ORDER BY #SQL_Sort_by#
</CFQUERY>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<script>
		function verifyDelete(broker_name, broker_id){
			if(confirm("Are You Sure You Want To Delete " + broker_name)){
				document.DeleteBrokerForm.Broker_ID.value = broker_id
				document.DeleteBrokerForm.submit();
			}
		}
	</script>
</head>
<body BGCOLOR="WhiteSmoke">



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
</style>

<SCRIPT LANGUAGE="JavaScript">
	function sortBy(sVal, sOrder)
	{
		var searchFrm = document.TheForm;
		searchFrm.SORT_BY.value = sVal;
		searchFrm.SORT_ORDER.value = sOrder;
		searchFrm.submit();
		return false;
	}
	function showstartingWith(sValue)
	{
		var searchFrm = document.TheForm;
		searchFrm.BROKER_NAME.value = sValue;
		searchFrm.submit();
		return false;
	}
</SCRIPT>

<FORM ACTION="brokers_Search_form.cfm" METHOD="post" NAME="TheForm" ID="TheForm" STYLE="DISPLAY:INLINE">
<CFOUTPUT>
<INPUT TYPE="Hidden" NAME="SORT_BY" VALUE="#FORM.SORT_BY#">
<INPUT TYPE="Hidden" NAME="SORT_ORDER" VALUE="#FORM.SORT_ORDER#">
<INPUT TYPE="Hidden" NAME="BROKER_NAME" VALUE="#FORM.BROKER_NAME#">	


<TABLE CELLPADDING="3" CELLSPACING="2" BORDER="0"><TR>
<TD><B>Names starting with:</B> </TD>
<cfloop index="LoopCount" from="65" to="90">
  <TD><B>
  <CFIF chr(LoopCount) EQ FORM.BROKER_NAME>
  <FONT COLOR="FF0000">[</FONT>
  </CFIF><A HREF="##" onClick="javaScript: return showstartingWith('#chr(LoopCount)#');">#chr(LoopCount)#</A>
  <CFIF chr(LoopCount) EQ FORM.BROKER_NAME>
  <FONT COLOR="FF0000">]</FONT></CFIF>
  </B></TD>
</cfloop>
	<TD><B>
  <CFIF "" EQ FORM.BROKER_NAME>
  <FONT COLOR="FF0000">[</FONT>
  </CFIF><A HREF="##" onClick="javaScript: return showstartingWith('');">ALL</A>
  <CFIF "" EQ FORM.BROKER_NAME>
  <FONT COLOR="FF0000">]</FONT></CFIF>
  </B>
	</TD>
</TR></TABLE>
</CFOUTPUT>
<TABLE CLASS="Maintable" CELLPADDING="3" CELLSPACING="0">
	<!--- TABLE HEADERS --->
	<TR BGCOLOR="#FFCE84" VALIGN="bottom">
		<CFOUTPUT>
		<CFSET Sort_By_Display_List = "ID,Name / Address,#application.returned_customer_setting.zone_label_singular#,#application.returned_customer_setting.region_label_singular#,#application.returned_customer_setting.market_label_singular#">
		<CFSET Sort_By_Value_List = "ID,Broker_Name,Zone,Region,Market">
		<CFSET Counter = 1>
		<CFLOOP LIST="#Sort_By_Value_List#" INDEX="This_Header_Item">
			<CFSET This_Sort_Order = "ASC">
			<CFSET This_Img = "">
			<CFIF LCase(This_Header_Item) EQ LCase(FORM.SORT_BY)>
				<CFIF FORM.SORT_ORDER EQ "ASC">
					<CFSET This_Sort_Order = "DESC">
					<CFSET This_Img = "up_1.gif"> 
					<!--- Development Note: By KAL - Used reverse direction for arrows
					as it gets changed below (reversed) before displaying --->	
				<CFELSE>
					<CFSET This_Img = "down_1.gif">
				</CFIF>
			</CFIF>
			<CFSET Display_Name = ListGetAt(Sort_By_Display_List, Counter, ",")>
			<TD ID="header"><A HREF="##" onClick="javaScript:return sortBy('#This_Header_Item#','#This_Sort_Order#');"><B>#Display_Name#</B></A>
			<CFIF Len(This_Img) GT 0><IMG SRC="/Images/#This_Img#" BORDER="0"></CFIF>
			</TD>
			<CFSET Counter = Counter + 1>
		</CFLOOP>
		</CFOUTPUT>
		<!------<TD ID="header"><B>ID</B></TD>
		<TD ID="header"><B>Name / Address</B></TD>----->
		
		<cfoutput>
		<!------<TD ID="header"><B>#application.returned_customer_setting.zone_label_singular#</B></TD>----->
		<!------<TD ID="header"><B>#application.returned_customer_setting.region_label_singular#</B></TD>----->
		<!------<TD ID="header"><B>#application.returned_customer_setting.market_label_singular#</B></TD>----->
		<!--- <TD>&nbsp;</TD> --->
		</cfoutput>
	</TR>
	
	<!--- TABLE DATA QUERY --->
	<CFOUTPUT QUERY="getAllBrokers" startrow="#StartRow#" maxrows="#MaxRows#">
		<CFSET HREFHTML = "<A HREF='brokers_create_form.cfm?Broker_ID=#getAllBrokers.BSA_Foodservice_Brokers_ID#'>">
		<CFSET onclick = "VALIGN=""bottom"" onclick=""window.location.href='brokers_create_form.cfm?Broker_ID=#getAllBrokers.BSA_Foodservice_Brokers_ID#'"" STYLE=""cursor:pointer; color: blue;""">
		<!--- DATA OUTPUT --->
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<TD #onclick# ALIGN="center">#HREFHTML##getAllBrokers.Broker_Shard#</A></TD>
			<!--- <TD #onclick#>#getAllBrokers.Broker_Name#</TD> --->
			<TD #onclick# NOWRAP WIDTH="23%">#HREFHTML#
				#getAllBrokers.Broker_Name#<BR>
				#getAllBrokers.Address#
				<CFIF len(trim(getAllBrokers.Address_2)) GT 0><BR>#getAllBrokers.Address_2#</CFIF>
				<BR>#getAllBrokers.City# #getAllBrokers.State_Code# #getAllBrokers.Zip#&nbsp;#getAllBrokers.Country_Code#</A>
			</TD>
			<TD #onclick#  WIDTH="23%">#HREFHTML##getAllBrokers.Zone_Name#</A></TD>
			<TD #onclick#  WIDTH="23%">#HREFHTML##getAllBrokers.Region_Name#</A></TD>
			
			<!------<CFQUERY NAME="getBrokerMarketArea" datasource="#application.datasource#">
				SELECT Market_Name
				FROM Service_Markets
				WHERE Service_Market_ID = '#getAllBrokers.Service_Market_ID#'
			</CFQUERY>
			
			<TD #onclick# NOWRAP WIDTH="23%">#HREFHTML#<CFIF getBrokerMarketArea.Recordcount GT 0>#getBrokerMarketArea.Market_Name#<CFELSE><span STYLE="color:red;">NOT-ASSIGNED</span></CFIF></A></TD>
			----->
			<TD #onclick# NOWRAP WIDTH="23%">#HREFHTML#<CFIF getAllBrokers.Market_Name NEQ "">#getAllBrokers.Market_Name#<CFELSE><span STYLE="color:red;">NOT-ASSIGNED</span></CFIF></A></TD>
			
		<!---<TD VALIGN="bottom">&nbsp; <img SRC="/images/delete.gif" ALT="Delete" STYLE="cursor: pointer;" ONCLICK="verifyDelete('#replace(replace(getAllBrokers.Broker_Name, "'", "\'", "ALL"), chr(34), "\'\'", "ALL")#', '#getAllBrokers.BSA_Foodservice_Brokers_ID#')"> </TD>--->
		</TR>	
	</CFOUTPUT>
</TABLE>

<INPUT TYPE="Hidden" NAME="startrow" VALUE="<CFOUTPUT>#startrow#</CFOUTPUT>">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="<CFOUTPUT>#frompage#</CFOUTPUT>">	

</FORM>

<HR COLOR="Orange" SIZE="2">
<DIV ALIGN="center" STYLE="font-size: 12px; color: Red;">
	<CF_Next_Previous_For_Forms
	formname="TheForm"
	query="getAllBrokers"
	maxpages="40"
	previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
	next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
	previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	addparams="">
</DIV>
<HR COLOR="Orange" SIZE="2">		

<FORM ACTION="brokers_delete.cfm" METHOD="post" NAME="DeleteBrokerForm" ID="DeleteBrokerForm">
	<input TYPE="hidden" NAME="Broker_ID" VALUE="">
</form>

</body>
</html>
