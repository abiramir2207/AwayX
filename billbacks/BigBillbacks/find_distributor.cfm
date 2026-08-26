<cfparam name="form.Distributor_List" default="">
<cfparam name="DistributorName" default="">
<cfparam name="stError" default="">

<cfif len(trim(form.Distributor_List)) GT 0>
	<cfquery name="GetDistributorName" datasource="#application.datasource#">
		SELECT Name, Ship_to, Shr_Ship_To
		FROM BSA_Foodservice_Customers
		WHERE BSA_Foodservice_Customers IN (form.Distributor_List)
	</cfquery>
	
	<cfset DistributorName = GetDistributorName.Name + " " + GetDistributorName.Ship_to + " " + GetDistributorName.Shr_Ship_To>
</cfif>

<cfoutput><SCRIPT LANGUAGE="JavaScript" SRC="bigbillback.js"></SCRIPT></cfoutput>

<cfoutput>
<form name="DistributorAlias" method="post" action="add_distributor_alias.cfm">

<INPUT NAME="Distributor_List" TYPE="hidden"  value="#form.Distributor_List#" >
<input name="Big_Billback_ID" type="hidden" value="#Big_Billback_ID#">

<FIELDSET STYLE="padding:8px; border: 1px solid Blue; width: 375;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">find your #lcase(application.returned_customer_setting.distributor_label_singular)#</LEGEND>
		
		<!---Get data --->
		<cfset useLakebaseForGetBBBData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("big_billback")>
<cfif useLakebaseForGetBBBData>
	<cftry>
		<cfset GetBBBData = application.oLakebase.toQuery(
			application.oLakebase.selectRows("big_billback", {
				"big_billback_id" = "eq.#Big_Billback_ID#",
				"select" = "distributor"
			}), "distributor"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBBBData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBBBData>
<cfquery name="GetBBBData" datasource="#application.datasource#">
		SELECT Distributor FROM Big_Billback WHERE Big_Billback_ID = #Big_Billback_ID#
		</cfquery>
</cfif>
	
		
		<table width="350" cellpadding="0" cellspacing="2" border="0">
		<cfif stError IS 1>
				<tr>
			<td><font color="red">An entry already exists for this alias. If you have already entered this alias but are still seeing highlighted options on your screen, try revalidating.</font></td>
		</tr>
		</cfif>
		
		<tr>
			<td><input type="text" name="Distributor_Alias" size="35" value="#GetBBBData.Distributor#"></td>
		</tr>
		
		<tr>
			<Td>#DistributorName# </TD>
		</tr><tr>
			<td><CF_smallLink 
				title = "search for #lcase(application.returned_customer_setting.distributor_label_singular)#" 
				url = "##"
				parameters = "onClick=""showDistributorSearchWindow();"""
				> 
				</td>
		</td>
		</tr>
		</table>
</FIELDSET>
</form>
</cfoutput>