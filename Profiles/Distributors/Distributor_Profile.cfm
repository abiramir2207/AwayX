<!DOCTYPE HTML>
<HTML>
<HEAD>
	<cfoutput><TITLE>#application.returned_customer_setting.distributor_label_singular# Profile</TITLE></cfoutput>

  <cfinclude template="/common_files/jQuery.cfm">
  <cf_include files="/styles/css-loader.css">
  <cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js, /script/javascript/default.js" />

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Decrypt the URL																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfparam name="URL.Distributor_Group_Level_ID" default="0" />
<cfparam name="URL.Is_Group" default="0" />
<cfparam name="URL.showProgramItems" default="0" />
<cfparam name="URL..programID" default="0" />
<cfparam name ="URL.populateMembers" default="0">
<CFSET BSA_Foodservice_Customers_ID = URL.DID>
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset custManager = CreateObject("component", "components.customer.DistributorManager").init()>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get all the information for this Distributor														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!---if it's a group then get customers in this group, otherwise handle it like it's a regular distributor/customer--->

<cfif URL.Is_Group eq 1>

	<CFOUTPUT>
	<script>
	function callPopulateMembers()
	{
		disableButton('grpMembers', true, false);
		show_loader("UPDATING MEMBERSHIP, PLEASE WAIT...");
		window.location.href = 'Distributor_Profile.cfm?populateMembers=1&programID=#url.programID#&DID=#URL.DID#&showProgramItems=1&Distributor_Group_Level_ID=#URL.Distributor_Group_Level_ID#&Is_Group=#URL.Is_Group#';
	}
	</script>
	</CFOUTPUT>

	<!--- When "update membership" link is clicked. --->
	<cfif URL.populateMembers eq 1>
		<cfset custManager.populateCustomerGroupMembers(url.programID)>
	</cfif>

	<cfif showProgramItems EQ 0>
	 <cfquery name="getDynamicGroupsOn" datasource="#application.datasource#">
	  Select Dynamic_Static_Groups
	  From Program_Control_Panel_Options
	  Where ProgramControl_Panel_Options_ID = (
	    Select ProgramType_ID
	    From Contract_Main
	    Where contract_main_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.programID#" />
	    And Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
	  )
	  And Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
	</cfquery>
	<cfset qGetCustomers = CreateObject("component", "components.customer.Group.DataManager").getCustomersInGroup(BSA_Foodservice_Customers_ID, URL.Distributor_Group_Level_ID, getDynamicGroupsOn.Dynamic_Static_Groups,url.programID) />
	<cfelse>
	<cfset qGetCustomers = CreateObject("component", "components.customer.Group.DataManager").getCustomersInProgram(BSA_Foodservice_Customers_ID, url.programID) />
	</cfif>

	<cfoutput>
	<cfif url.programID neq "" AND URL.DID neq "" AND URL.showProgramItems eq 1 AND URL.Distributor_Group_Level_ID neq 0>
		<div id="grpMembers" style="font-size:8px;">
			Click <a href="javascript:void();" onClick="callPopulateMembers()">#application.util.string.actionLinkFormat("update membership")#</a> to update the membership for this program.
			<br /><br /><span style="font-style:italic">Note:</b> **The standard nightly job will not update membership for expired status programs.  This link allows you to manually update the membership.**
		</div>
	<br />
	</cfif>
	</cfoutput>

<cfelse>

	<CFQUERY NAME="Get_Distributor_Data" datasource="#application.datasource#">

		SELECT	Distributor_Bill_To.Name AS Billto_Name,
				BSA_Foodservice_Customers.*,
				Distributor_Bill_To.Address1 AS Billto_Address1,
				Distributor_Bill_To.Address2 AS Billto_Address2,
				Distributor_Bill_To.City AS Billto_City,
				Distributor_Bill_To.State AS Billto_State,
				Distributor_Bill_To.Zip AS Billto_Zip,
				Distributor_Bill_To.Phone AS Billto_Phone,
				Distributor_Bill_To.Bill_To AS Billto_Bill_To,
				Distributor_Bill_To.Shr_Bill_To AS Billto_shr_bill_to
		FROM	BSA_Foodservice_Customers
				LEFT JOIN Distributor_Bill_To ON
				BSA_Foodservice_Customers.Distributor_Bill_To_ID = Distributor_Bill_To.Distributor_Bill_To_ID
		WHERE	BSA_Foodservice_Customers_ID = '#BSA_Foodservice_Customers_ID#'

	</CFQUERY>

</cfif>

</HEAD>
<!--- <BODY onfocusout="self.focus();" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0"> --->
<body>
<!---if its a group then display customers in group--->
<cfif URL.Is_Group eq 1>
	<cfinclude template="/includes/Search_on_Page.cfm">

	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<table border="0" cellpadding="3" cellspacing="0" CLASS="Maintable" width="100%">
		<cfoutput>
		<tr BGCOLOR="##FFCE84">
			<TD id="header">
				<b>#application.returned_customer_setting.distributor_label_plural#</b> (#qGetCustomers.RecordCount# Records)
			</TD>
		</tr>
		</cfoutput>
		<cfif qGetCustomers.RecordCount>
			<cfset cnt = 1 />
			<cfset display_shr_ship_to = appSettings.get_Setting('Display_Distributor_ID', 0)>
			<cfsavecontent variable="variables.content">
				<cfoutput query="qGetCustomers" group="shr_ship_to">
					<tr>
						<td>
							<cfif display_shr_ship_to eq '1'> #shr_ship_to# <cfelse> #ship_to# </cfif> - #Name#
						</td>
					</tr>
					<cfset cnt = cnt + 1 />
				</cfoutput>
			</cfsavecontent>
			<cfoutput>#application.util.string.compress( variables.content )#</cfoutput>
		<cfelse>
			<cfoutput>
			<tr BGCOLOR="##C6FFC6">
				<td colspan="100%">There are no #application.returned_customer_setting.distributor_label_plural# for this group</td>
			</tr>
			</cfoutput>
		</cfif>
	</table>

	<cfinclude template="/common_files/jQuery.cfm">
	<cfinclude template="/common_files/focus.cfm">
	<script>
		$("#find_Text").focus();
		$( "tr:even" ).css( "background-color", "#C6FFC6" );
	</script>

	</body>
	</html>
	<cfabort>
</cfif>


<CFOUTPUT QUERY="Get_Distributor_Data">
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%" ALIGN="center">
<TR>
	<TD BGCOLOR="Yellow" ALIGN="center"><FONT COLOR="blue" SIZE="3"><B>#Name#</B></FONT></TD>
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
		<TD width="100%" valign="top"><CFIF Active_Code EQ "A">(A) Active<CFELSE>(N) Inactive</CFIF></TD>
	</TR>
	<TR>
		<TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.shard_ship_to_label#:</B></TD>
		<TD width="100%" valign="top">#Shr_Ship_To#</TD>
	</TR>
	<TR>
		<TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.legacy_ship_to_label# ##:</B></TD>
		<TD width="100%" valign="top">#Ship_To#</TD>
	</TR>
	<TR>
		<TD align="right" nowrap valign="top"><B>Address:</B></TD>
		<TD width="100%" valign="top">#Address_1#<cfif len(trim(Address_2)) GT 0>#Address_2#<BR></cfif><BR>#City# #State# #ZipCode#&nbsp;#Country_code#</TD>
	</TR>
	<TR>
		<TD align="right" nowrap valign="top"><B>Phone:</B></TD>
		<TD width="100%" valign="top">#Phone#</TD>
	</TR>

	<!------ Get application settings ----->
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>

	<CFQUERY NAME="Get_Distributor_Market_Data" datasource="#application.datasource#">

		SELECT	<cfif NOT appSettings.getDistributorMultiPosition()>
				BSA_Foodservice_Brokers.Broker_Name,
				<cfelse>
				Service_Markets.Market_Name,
				</cfif>
				Service_Zones.Zone_Name,
				Service_Regions.Region_Name
		FROM	BSA_Foodservice_Customers
				<cfif NOT appSettings.getDistributorMultiPosition()>
				INNER JOIN BSA_Foodservice_Brokers ON
				BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
				<cfelse>
				INNER JOIN Market_Distributor
				ON Market_Distributor.Deleted = 0
				AND Market_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
				INNER JOIN Service_Markets
				ON Service_Markets.Service_Market_ID = Market_Distributor.Service_Market_ID
				</cfif>
				INNER JOIN Service_Regions ON
				<cfif NOT appSettings.getDistributorMultiPosition()>
				BSA_Foodservice_Brokers.Service_Region_ID = Service_Regions.Service_Region_ID
				<cfelse>
				Service_Markets.Service_Region_ID = Service_Regions.Service_Region_ID
				</cfif>
				INNER JOIN Service_Zones ON
				Service_Regions.Service_Zone_ID = Service_Zones.Service_Zone_ID
		WHERE	BSA_Foodservice_Customers_ID = '#BSA_Foodservice_Customers_ID#'
	</CFQUERY>

	<TR>
		<TD colspan="2" nowrap valign="top">
			<BR>
			<DIV class="title2">
			#application.returned_customer_setting.market_label_singular# Alignment
			</DIV>
			<HR color="Orange" SIZE="1">
		</TD>
	</TR>

	<cfloop query="Get_Distributor_Market_Data">
		<cfif NOT appSettings.getDistributorMultiPosition()>
			<TR>
				<TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.broker_label_singular#:</B></TD>
				<TD width="100%" valign="top">#Broker_Name#</TD>
			</TR>
		<cfelse>
			<TR>
				<TD align="right" nowrap valign="top"><B>Market Area:</B></TD>
				<TD width="100%" valign="top">#Market_Name#</TD>
			</TR>
		</cfif>

		<TR>
			<TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.zone_label_singular# Name:</B></TD>
			<TD width="100%" valign="top">#Zone_Name#</TD>
		</TR>
		<TR>
			<TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.region_label_singular# Name:</B></TD>
			<TD width="100%" valign="top">#Region_Name#</TD>
		</TR>
		<TR>
			<TD colspan="2">&nbsp;</TD>
		</TR>
  </cfloop>

  <TR>
    <TD colspan="2" nowrap valign="top">
      <BR>
	  <DIV class="title2">
        #application.returned_customer_setting.billto_label#
      </DIV>
      <HR color="Orange" SIZE="1">
    </TD>
  </TR>

  <TR>
    <TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.billto_label#:</B></TD>
    <TD width="100%" valign="top">#Billto_shr_bill_to#</TD>
  </TR>

  <TR>
    <TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.billto_label# Name:</B></TD>
    <TD width="100%" valign="top">#Billto_Name#</TD>
  </TR>

  <TR>
    <TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.billto_label# Address:</B></TD>
    <TD width="100%" valign="top">
	#Billto_Address1#<BR>
	#Billto_City#, #Billto_State#&nbsp;#Billto_Zip#
	</TD>
  </TR>
</TABLE>

<cfset request.focusHiLightOff = true>
</BODY>
</HTML>
</CFOUTPUT>




