<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Printer Friendly Customer Information</TITLE>
	<style type="text/css">	
		.TableAttributes 
		{
			font-family:Arial;
			font-size:11px;
			font-weight:bold;
		}
	</style>
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is the printer friendly page --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfparam name="Action" default="">
<cfparam name="Source" default="">

<!--- Decode the Program ID that comes from the URL.CID variable --->
<cf_cryp	type = "de" string = "#URL.CID#" key = "#request.key#">
<CFSET Export_Customer_ID =cryp.value>

<cfset Agreement_Details = CreateObject("component","components.Export.Sales_Agreement_AJAX") />
<cfset Agreement_Manager_Details = CreateObject("component","components.Export.Sales_Agreement") />

<cfset qrygetcustomerDetails = Agreement_Manager_Details.getcustomerDetails(Export_Customer_ID)>
<cfset qrygetCustomerCountry = Agreement_Manager_Details.getCountryList(Export_Customer_ID,1)>
<cfset qrygetNotifyCustomerCountry = Agreement_Manager_Details.getCountryList(Export_Customer_ID,2)>
<cfset qrygetTermsOfSale = Agreement_Details.getTermsOfSale(Export_Customer_ID)>
<cfset qrygetInvoiceTerms = Agreement_Details.getInvoiceTerms()>
<cfset qrygetOrigin = Agreement_Details.getOrigin(Export_Customer_ID)>
<cfset qrygetCustomerPalletType = Agreement_Manager_Details.getCustomerPalletType(Export_Customer_ID)>
<cfset qrygetBorderCrossingAgentRecords = Agreement_Manager_Details.getBorderCrossingAgentRecords(Export_Customer_ID)>
<cfset qrygetNotifyCustomerRecords = Agreement_Manager_Details.getNotifyCustomerRecords(Export_Customer_ID)>


<CFSAVECONTENT VARIABLE="CustomerDocument">
<cfoutput query="qrygetcustomerDetails">
<table  border="0" align ="center" cellpadding="2" cellspacing="0" width="450">
	<tr>
		<td colspan="2"><b><u>SOLD TO</u></b></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Customer Base ##:</td>
		<td>#Export_Customer_Base_Number#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Name:</td>
		<td>#Export_Customer_Name#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Address 1:</td>
		<td>#Export_Customer_Address_1#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Address 2:</td>
		<td>#Export_Customer_Address_2#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Address 3:</td>
		<td>#Export_Customer_Address_3#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">City:</td>
		<td>#Export_Customer_City#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Country:</td>
		<td>#qrygetCustomerCountry.Export_Lookup_Destination_Country_Desc#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Phone:</td>
		<td>#Export_Customer_Phone#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Fax:</td>
		<td>#Export_Customer_Fax#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Email:</td>
		<td>#Export_Customer_Email#</td>
	</tr>
	<cfif qrygetNotifyCustomerRecords.NumberofRecords GT 0>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="2"><b><u>NOTIFY</u></b></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Name:</td>
		<td>#Export_Notify_Name#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Address 1:</td>
		<td>#Export_Notify_Address_1#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Address 2:</td>
		<td>#Export_Notify_Address_2#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Address 3:</td>
		<td>#Export_Notify_Address_3#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">City:</td>
		<td>#Export_Notify_City#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Country:</td>
		<td>#qrygetNotifyCustomerCountry.Export_Lookup_Destination_Country_Desc#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Phone:</td>
		<td>#Export_Notify_Phone#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Fax:</td>
		<td>#Export_Notify_Fax#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Buyer Name:</td>
		<td>#Export_Buyer_Name#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Invoice Terms</td>
		<td>#qrygetInvoiceTerms.Inv_code# - #qrygetInvoiceTerms.Description1#,#qrygetInvoiceTerms.Description2#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Terms of Sale:</td>
		<td>#qrygetTermsOfSale.Export_Lookup_Terms_of_Sale_Desc#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Primary Whse/Shipping Location:</td>
		<td>#qrygetOrigin.Export_Lookup_Origin_Desc#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Discharge Port:</td>
		<td>#Export_Discharge_Port#</td>
	</tr>
	</cfif>
	<cfif qrygetBorderCrossingAgentRecords.NumberofRecords GT 0>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="2"><b><u>BORDER CROSSING AGENT: (Mexico Destinations & Canada Origins)</u></b></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Name:</td>
		<td>#Export_Border_Crossing_Agent_Name#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Address 1:</td>
		<td>#Export_Border_Crossing_Agent_Address_1#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Address 2:</td>
		<td>#Export_Border_Crossing_Agent_Address_2#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Address 3:</td>
		<td>#Export_Border_Crossing_Agent_Address_3#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">City:</td>
		<td>#Export_Border_Crossing_Agent_City#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Zip:</td>
		<td>#Export_Border_Crossing_Agent_Zip#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">State:</td>
		<td>#Export_Border_Crossing_Agent_State#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Phone:</td>
		<td>#Export_Border_Crossing_Agent_Phone#</td>
	</tr>
	</cfif>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Include Pallet:</td>
		<td><cfif Export_Customer_Include_Pallet eq 1>Yes<cfelseif Export_Customer_Include_Pallet eq 0>No</cfif></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Pallet Type:</td>
		<td>#qrygetCustomerPalletType.Export_Lookup_Pallet_Type_Desc#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Quantity:</td>
		<td>#Export_Customer_Quantity#</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Customer exempt from relocation charges:</td>
		<td><cfif Export_Customer_Exempt_Relocation_Charge eq 1>Yes<cfelseif Export_Customer_Exempt_Relocation_Charge eq 0>No</cfif></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Invoicing:</td>
		<td><cfif Export_Customer_Unit_Of_Measure_ID eq 1>Cases<cfelseif Export_Customer_Unit_Of_Measure_ID eq 2>Pounds</cfif></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Customer exempt from domestic fuel charges:</td>
		<td><cfif Export_Customer_Exempt_Domestic_Fuel_Charge eq 1>Yes<cfelseif Export_Customer_Exempt_Domestic_Fuel_Charge eq 0>No</cfif></td>
	</tr>
</table>
</cfoutput>
</CFSAVECONTENT>	
<!--- There are email, fax actions we dont want to include this data or file for those actions --->
<cfif Action eq "">
<CFOUTPUT>#CustomerDocument#</CFOUTPUT>
<!--- We do not want this print pop up when emailing about the customer. The "Source" variable is in "Sales_Agreement_Customer_Request_Action.cfm" page --->
<cfif Source eq "">
	<CFINCLUDE template="/Common_Files/Printer_Friendly_Script.cfm">
</cfif>
</cfif>

</BODY>
</HTML>
<cfsetting showdebugoutput="true">
