<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Decrypt the URL																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET BSA_Foodservice_Brokers_ID = URL.BID>
<cfif NOT isDefined("appSettings")>
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>
	</cfif>
	
	<cfparam name="brokerList" default="">
	<cfset url.BID = urldecode(url.BID)>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get all the Distributors for this Broker if URL.Is_Group												 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <cfif URL.Is_Group eq 1> --->
<cfset ViewProgramManager = CreateObject("component", "components.programs.Display_Program.viewprogramtemplateManager") />

<cfif isDefined("URL.Contract_Main_ID")>
	<cfset getMarketsMaster  = ViewProgramManager.getMarkets(url.Contract_Main_ID,appsettings.getRemoveBrokerSelection())>
	<cfset request.getMarketsMaster = getMarketsMaster>
	<cfset getMarkets  = ViewProgramManager.getBrokerIDS("request.getMarketsMaster",url.BID)>

	<cfloop query="getMarkets">
		<cfset brokerList = valueList(getMarkets.BSA_Foodservice_Brokers_ID)>
	</cfloop>

 
	<cfset qGetCustomers = CreateObject("component", "components.customer.Group.DataManager").getBrokerCustomers(brokerList) />
</cfif>

<!--- <cfelse> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get all the information for this Broker														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Broker_Data" datasource="#application.datasource#">
SELECT     dbo.Service_Zones.Zone_Name AS Zone_Name, dbo.Service_Regions.Region_Name AS Region_name,
                      dbo.BSA_Foodservice_Brokers.Active_Code, dbo.BSA_Foodservice_Brokers.Broker_Shard, dbo.BSA_Foodservice_Brokers.Broker_Name,
                      dbo.BSA_Foodservice_Brokers.Address, dbo.BSA_Foodservice_Brokers.Address_2, dbo.BSA_Foodservice_Brokers.City,
                      dbo.BSA_Foodservice_Brokers.State, dbo.BSA_Foodservice_Brokers.Zip, dbo.BSA_Foodservice_Brokers.Country_Code, dbo.BSA_Foodservice_Brokers.Broker_CSR,
                      dbo.BSA_Foodservice_Brokers.Account_Exec, dbo.BSA_Foodservice_Brokers.Phone_Number,
                      dbo.BSA_Foodservice_Brokers.Fax_Number, dbo.BSA_Foodservice_Brokers.E_Mail, dbo.Line_Of_Business.Line_Of_Business_Name,
                      dbo.BSA_Foodservice_Brokers.Fax_1, dbo.BSA_Foodservice_Brokers.Fax_2, dbo.BSA_Foodservice_Brokers.Fax_3,
                      dbo.BSA_Foodservice_Brokers.Phone_1, dbo.BSA_Foodservice_Brokers.Phone_2, dbo.BSA_Foodservice_Brokers.Phone_3,
                      dbo.BSA_Foodservice_Brokers.Phone_Ext
FROM         dbo.BSA_Foodservice_Brokers INNER JOIN
                      dbo.Service_Regions ON dbo.BSA_Foodservice_Brokers.Service_Region_ID = dbo.Service_Regions.Service_Region_ID INNER JOIN
                      dbo.Service_Zones ON dbo.BSA_Foodservice_Brokers.Service_Zone_ID = dbo.Service_Zones.Service_Zone_ID INNER JOIN
                      dbo.Line_Of_Business ON dbo.BSA_Foodservice_Brokers.Line_Of_Business_ID = dbo.Line_Of_Business.Line_Of_Business_ID
Where
		<cfif brokerList GT 0 AND Len(brokerList) EQ 36>
			BSA_Foodservice_Brokers_ID = '#getMarkets.BSA_Foodservice_Brokers_ID#'
		<cfelseif brokerList GT 0 AND Len(brokerList) GTE 36>
			<cfset row = 0>
			<cfloop list="#brokerList#" index="i">
				<cfset row = row + 1>
				<cfif row NEQ 1>OR </cfif>BSA_Foodservice_Brokers_ID = '#i#'
			</cfloop>
		<cfelse>
			1=2
		</cfif>
</CFQUERY>
<!--- </cfif> --->

<!---if its a group then display customers for this Broker--->
<cfif isDefined("URL.Is_Group") AND URL.Is_Group eq 1>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<table border="0" cellpadding="3" cellspacing="0" bgcolor="ffce84" CLASS="Maintable" width="100%">
	<cfoutput>
	<tr BGCOLOR="##FFCE84">
		<TD id="header">
			<b>#application.returned_customer_setting.distributor_label_plural# For #Get_Broker_Data.Broker_Name#</b>
		</TD>
	</tr>
	</cfoutput>
	<cfif qGetCustomers.RecordCount>
		<cfset cnt = 1 />
		<cfoutput query="qGetCustomers" group="shr_ship_to">
			<tr BGCOLOR="#IIf(cnt Mod 2, DE('ffffff'), DE('C6FFC6'))#">
				<td>#shr_ship_to# - #Name#</td>
			</tr>
			<cfset cnt = cnt + 1 />
		</cfoutput>

	<cfelse>
		<cfoutput>
		<tr BGCOLOR="##C6FFC6">
			<td colspan="100%">There are no #application.returned_customer_setting.broker_label_plural# for this group</td>
		</tr>
		</cfoutput>
	</cfif>
</table>

</BODY></HTML>
<cfabort>
</cfif>

<CFOUTPUT QUERY="Get_Broker_Data">



<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>#application.returned_customer_setting.broker_label_singular# Profile</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="style.css">
</HEAD>

<BODY ONBLUR="self.focus();" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">




<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%" ALIGN="center">
<TR>
	<TD BGCOLOR="Yellow" ALIGN="center"><FONT COLOR="blue" SIZE="3"><B>#Broker_Name#</B></FONT></TD>
</TR>
</TABLE>

<BR>



<TABLE border="0" cellpadding="0" cellspacing="5" WIDTH="350" ALIGN="center">
  <TR>
    <TD colspan="2" nowrap valign="top">
      <DIV class="title2">
        General
      </DIV>
      <HR color="Orange" SIZE="1">
    </TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Active Code:</B></TD>
    <TD width="100%" valign="top">(#Active_Code#)&nbsp;<CFIF Active_Code EQ "A">Active<cfelse>Inactive</CFIF></TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.broker_label_singular# ID:</B></TD>
    <TD width="100%" valign="top">#Broker_shard#</TD>
  </TR>
<!---   <TR>
    <TD align="right" nowrap valign="top"><B>Name:</B></TD>
    <TD width="100%" valign="top">#Zone_Name#</TD>
  </TR> --->
  <TR>
    <TD align="right" nowrap valign="top"><B>Address:</B></TD>
    <TD width="100%" valign="top">#Address#<BR><CFIF len(trim(address_2))>#Address_2#<BR></CFIF>#city#, #state# #zip#&nbsp;#Country_Code#</TD>
  </TR>
  <TR>
    <TD colspan="2" nowrap valign="top">
      <BR>
	  <DIV class="title2">
        Contact
      </DIV>
      <HR color="Orange" SIZE="1">
    </TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Account Exec:</B></TD>
    <TD width="100%" valign="top">#Account_Exec#<CFIF len(trim(Account_Exec)) EQ 0>Not Supplied</CFIF></TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.broker_label_singular# CSR:</B></TD>
    <TD width="100%" valign="top">#Broker_CSR#<CFIF len(trim(Broker_CSR)) EQ 0>Not Supplied</CFIF></TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Phone Number:</B></TD>
    <TD width="100%" valign="top"><CFIF len(trim(Phone_Ext)) GT 0>&nbsp;Ext. #Phone_Ext#</CFIF><CFIF (len(trim(Phone_1))+len(trim(Phone_2))+len(trim(Phone_3))) EQ 0>Not Supplied<cfelse>#Phone_1#-#Phone_2#-#Phone_3#</CFIF></TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Fax Number:</B></TD>
    <TD width="100%" valign="top"><CFIF (len(trim(Fax_1))+len(trim(Fax_2))+len(trim(Fax_3))) EQ 0>Not Supplied<cfelse>#Fax_1#-#Fax_2#-#Fax_3#</CFIF></TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Email:</B></TD>
    <TD width="100%" valign="top"><A HREF="mailto:#E_Mail#">#E_Mail#</A><CFIF len(trim(E_Mail)) EQ 0>Not Supplied</CFIF></TD>
  </TR>
  <TR>
    <TD colspan="2" nowrap valign="top">
      <BR>
	  <DIV class="title2">
        Market Alignment
      </DIV>
      <HR color="Orange" SIZE="1">
    </TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.lob_label_singular#:</B></TD>
    <TD width="100%" valign="top">#Line_Of_Business_Name#</TD>
  </TR>
<!---   <TR>
    <TD align="right" nowrap valign="top"><B>Market Area:</B></TD>
    <TD width="100%" valign="top">?????????????</TD>
  </TR> --->
  <TR>
    <TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.region_label_singular#:</B></TD>
    <TD width="100%" valign="top">#Region_Name#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.zone_label_singular#:</B></TD>
    <TD width="100%" valign="top">#Zone_Name#</TD>
  </TR>

</TABLE>



</CFOUTPUT>

</BODY>
</HTML>

