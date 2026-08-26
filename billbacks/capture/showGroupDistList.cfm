<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Distributor Group List</title>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<cfinclude template="iframe_style.cfm">
</head>

<body onload="window.focus()">
<cfparam name="url.Billback_ID" default="">
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset thisObj = CreateObject("component", "components.Billback.BillbackSummaryManager") >
<cfset getGroupDistList = thisObj.getGroupDistList(url.Billback_ID) />

<cfset getdistmultipos = appSettings.getDistributorMultiPosition()>

<cfoutput>
<TABLE border="0" cellspacing="0" cellpadding="3" align="center" WIDTH="100%" CLASS="Maintable">
			<TR>
				</TR>
				<TR ID="header" BGCOLOR="##ffce84">
					<TD align="left" ID="header"><B>Name / #application.returned_customer_setting.shard_ship_to_label#</B></TD>
					<TD ID="header"><B>Address</B></TD>
					<cfif NOT getdistmultipos>
					<TD ID="header"><B>#application.returned_customer_setting.broker_label_singular#</B></TD>
					</cfif>
					<TD ID="header"><B>#application.returned_customer_setting.family_name_label_singular# / #application.returned_customer_setting.buying_group_label_singular#</B></TD>
				</TR>
				
				
				<!--- <cfset useLakebaseForqGetDistList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_distributor_list")>
<cfif useLakebaseForqGetDistList>
	<cftry>
		<cfset qGetDistList = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_distributor_list", {
				"deleted" = "eq.0",
				"billback_id" = "eq.#Form.Billback_ID#",
				"select" = "distributor_id"
			}), "distributor_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDistList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDistList>
<cfquery name="qGetDistList" datasource="#Application.Datasource#">		
					select Distributor_ID from billback_distributor_list 
					where deleted = 0
					and Billback_ID = '#Form.Billback_ID#' 
				</cfquery>
</cfif>
				<cfset form.multiDistList = valuelist(qGetDistList.Distributor_ID)> --->
				<CFSET x = 0>
				
					<cfquery name="qGetDistListInfo" datasource="#Application.Datasource#">
							SELECT     dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID, dbo.BSA_Foodservice_Customers.Name, 
							                      dbo.BSA_Foodservice_Customers.Ship_To, dbo.BSA_Foodservice_Customers.Address_1, dbo.BSA_Foodservice_Customers.City, 
							                      dbo.BSA_Foodservice_Customers.State, dbo.BSA_Foodservice_Customers.ZipCode,  BSA_Foodservice_Customers.Country_Code,
												  <cfif NOT getdistmultipos>
							                      dbo.BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID, dbo.BSA_Foodservice_Brokers.Broker_Name, 
												  </cfif>
							                      dbo.Distributor_Family.Family_Name, dbo.Distributor_Buying_Groups.Buying_Group_Name, dbo.BSA_Foodservice_Customers.Shr_Ship_To
							FROM	dbo.BSA_Foodservice_Customers 
									<cfif NOT getdistmultipos>
									INNER JOIN	dbo.BSA_Foodservice_Brokers ON 
									dbo.BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = dbo.BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID 
									</cfif>
									INNER JOIN dbo.Distributor_Family ON dbo.BSA_Foodservice_Customers.Family_ID = dbo.Distributor_Family.Family_ID 
									INNER JOIN dbo.Distributor_Buying_Groups ON dbo.BSA_Foodservice_Customers.Buying_Group_ID = dbo.Distributor_Buying_Groups.Buying_Group_ID
							WHERE BSA_Foodservice_Customers_ID in (#QuotedValueList(getGroupDistList.Distributor_ID)#)
						</cfquery> 
						<CFLOOP query="qGetDistListInfo">
							<TR STYLE="cursor:pointer;" bgcolor="###Iif(((x MOD 2) is 0),de('FFFFFF'),de('EAFFEA'))#">
								<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#getGroupDistList.Distributor_ID#','name','400','450','Yes', 'No');return false;" NOWRAP>#qGetDistListInfo.Name#<BR>#qGetDistListInfo.Shr_Ship_To#&nbsp;</TD>
								<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#getGroupDistList.Distributor_ID#','name','400','450','Yes', 'No');return false;">#qGetDistListInfo.Address_1#<BR>#qGetDistListInfo.City#,#qGetDistListInfo.State# #qGetDistListInfo.ZipCode#&nbsp;#qGetDistListInfo.Country_Code#</TD>
								<cfif NOT getdistmultipos>
								<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#getGroupDistList.Distributor_ID#','name','400','450','Yes', 'No');return false;" >#qGetDistListInfo.Broker_Name#&nbsp;</TD>
								</cfif>
								<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#getGroupDistList.Distributor_ID#','name','400','450','Yes', 'No');return false;" NOWRAP>#qGetDistListInfo.Family_Name#<BR>#qGetDistListInfo.Buying_Group_Name#&nbsp;</TD>
			 				</TR>
						
							<CFSET x = x + 1>
				</CFLOOP>
			</TABLE>
</cfoutput>

</body>
</html>
