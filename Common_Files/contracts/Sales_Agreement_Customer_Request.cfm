<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>Sales Agreement</title>
<style type="text/css">	
	.TableAttributes 
	{
		font-family:Arial;
		font-size:11px;
		font-weight:bold;
	}
</style>

<cfparam name="CID" default="">
<cfparam name="Export_Customer_ID" default="0">

<cf_cryp type="de" key="#request.key#" string="#CID#">

<cfif len(CID) NEQ 0>
<cfset Export_Customer_ID = cryp.value>
</cfif>

<!--- Call the required component for AJAX Calls --->
<script type='text/javascript'>_ajaxConfig = {'_cfscriptLocation':'/components/Export/Sales_Agreement_AJAX.cfc', '_jsscriptFolder':'/Script/javascript/Ajax_JS','debug':false};</script>
<script type='text/javascript' src='/Script/javascript/Ajax_JS/ajax.js'></script>

<cfset Agreement_Details = CreateObject("component","components.Export.Sales_Agreement_AJAX") />
<cfset Agreement_Manager_Details = CreateObject("component","components.Export.Sales_Agreement") />

<cfset getcustomerDetails = Agreement_Manager_Details.getcustomerDetails(Export_Customer_ID)>

<cfset qrygetCountryList = Agreement_Manager_Details.getCountryList()>
<cfset qrygetTermsOfSale = Agreement_Details.getTermsOfSale()>
<cfset qrygetInvoiceTerms = Agreement_Details.getInvoiceTerms()>
<cfset qrygetOrigin = Agreement_Details.getOrigin()>

<CF_MessageWindow>
<script language="javascript">
function getPallets()
{
	DWREngine.setAsync(false);

	PalletIndicator = document.frmAddCustomer.Export_Customer_Include_Pallet.options[document.frmAddCustomer.Export_Customer_Include_Pallet.options.selectedIndex].value
	DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'getPalletType', PalletIndicator, Set_Pallet_Type);
}

function getValidCustomerStatusTypes(ExportCustomerID,StatusAllowed)
{
	DWREngine.setAsync(false);
	DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'getValidCustomerStatusTypes', ExportCustomerID, StatusAllowed, Set_Customer_Status);
}

	function Set_Customer_Status(ReturnValue)
	{
	<!--- If its not WIP --->
		if(ReturnValue[0] > 1) {		
			document.getElementById("Export_Customer_Status_Type_id").innerHTML = '<B><FONT SIZE="2" COLOR="red">[ </FONT><a href="##" ONCLICK="Javascript:CheckForm('+ReturnValue[0]+',\'1\');return false;">'+ReturnValue[1]+'</A><FONT SIZE="2" COLOR="red"> ]</FONT></B>';
		}
	}

	// This function sets the values for "Export_Pallet_Type"
	function Set_Pallet_Type(ReturnValue)
	{
			document.getElementById("Export_Pallet_Type_Cell_id").innerHTML = ReturnValue;
	}

	function CheckForm(StatusAllowed, ChangeStatus)
	{
	var ErrorCount = 0;

		if(document.frmAddCustomer.Export_Customer_Name.value=='')
		{
			ErrorCount++;
			queueMessage("You must fill in the name field ",  document.all.error_Name);
		}
		else{
			clearQueue(document.all.error_Name);
		}
		if(document.frmAddCustomer.Export_Customer_Address_1.value=='')
		{
			ErrorCount++;
			queueMessage("You must fill in the Address 1 field ",  document.all.error_Address_1);
		}
		else{
			clearQueue(document.all.error_Address_1);
		}
		if(document.frmAddCustomer.Export_Customer_Address_2.value=='')
		{
			ErrorCount++;
			queueMessage("You must fill in the Address 2 field ",  document.all.error_Address_2);
		}
		else{
			clearQueue(document.all.error_Address_2);
		}
		if(document.frmAddCustomer.Export_Customer_Address_3.value=='')
		{
			ErrorCount++;
			queueMessage("You must fill in the Address 3 field ",  document.all.error_Address_3);
		}
		else{
			clearQueue(document.all.error_Address_3);
		}
		if(document.frmAddCustomer.Export_Customer_City.value=='')
		{
			ErrorCount++;
			queueMessage("You must fill in the City field ",  document.all.error_City);
		}
		else{
			clearQueue(document.all.error_City);
		}
		if(document.frmAddCustomer.Export_Customer_Country.options[document.frmAddCustomer.Export_Customer_Country.options.selectedIndex].value==0)
		{
			ErrorCount++;
			queueMessage("You must fill in the Country field ",  document.all.error_Country);
		}
		else{
			clearQueue(document.all.error_Country);
		}
		if(document.frmAddCustomer.Export_Customer_Phone.value=='')
		{
			ErrorCount++;
			queueMessage("You must fill in the Phone field ",  document.all.error_Phone);
		}
		else{
			clearQueue(document.all.error_Phone);
		}
		if(document.frmAddCustomer.Export_Customer_Fax.value=='')
		{
			ErrorCount++;
			queueMessage("You must fill in the Fax field ",  document.all.error_Fax);
		}
		else{
			clearQueue(document.all.error_Fax);
		}
		if(document.frmAddCustomer.Export_Customer_Email.value=='')
		{
			ErrorCount++;
			queueMessage("You must fill in the Email field ",  document.all.error_Email);
		}
		else{
			clearQueue(document.all.error_Email);
		}

	if(StatusAllowed > 1)
	{
		if(document.frmAddCustomer.Export_Notify_Name.value=='')
		{
			ErrorCount++;
			queueMessage("You must fill in the notify name field ",  document.all.error_Notify_Name);
		}
		else{
			clearQueue(document.all.error_Notify_Name);
		}
		if(document.frmAddCustomer.Export_Notify_Address_1.value=='')
		{
			ErrorCount++;
			queueMessage("You must fill in the Address 1 field ",  document.all.error_Notify_Address_1);
		}
		else{
			clearQueue(document.all.error_Notify_Address_1);
		}
		if(document.frmAddCustomer.Export_Notify_Address_2.value=='')
		{
			ErrorCount++;
			queueMessage("You must fill in the Address 2 field ",  document.all.error_Notify_Address_2);
		}
		else{
			clearQueue(document.all.error_Notify_Address_2);
		}
		if(document.frmAddCustomer.Export_Notify_Address_3.value=='')
		{
			ErrorCount++;
			queueMessage("You must fill in the Address 3 field ",  document.all.error_Notify_Address_3);
		}
		else{
			clearQueue(document.all.error_Notify_Address_3);
		}
		if(document.frmAddCustomer.Export_Notify_City.value=='')
		{
			ErrorCount++;
			queueMessage("You must fill in the City field ",  document.all.error_Notify_City);
		}
		else{
			clearQueue(document.all.error_Notify_City);
		}
		if(document.frmAddCustomer.Export_Notify_Country.options[document.frmAddCustomer.Export_Notify_Country.options.selectedIndex].value==0)
		{
			ErrorCount++;
			queueMessage("You must fill in the Country field ",  document.all.error_Notify_Country);
		}
		else{
			clearQueue(document.all.error_Notify_Country);
		}
		if(document.frmAddCustomer.Export_Notify_Phone.value=='')
		{
			ErrorCount++;
			queueMessage("You must fill in the Phone field ",  document.all.error_Notify_Phone);
		}
		else{
			clearQueue(document.all.error_Notify_Phone);
		}
		if(document.frmAddCustomer.Export_Notify_Fax.value=='')
		{
			ErrorCount++;
			queueMessage("You must fill in the Fax field ",  document.all.error_Notify_Fax);
		}
		else{
			clearQueue(document.all.error_Notify_Fax);
		}
		if(document.frmAddCustomer.Export_Buyer_Name.value=='')
		{
			ErrorCount++;
			queueMessage("You must fill in the Buyer Name field ",  document.all.error_Buyer_Name);
		}
		else{
			clearQueue(document.all.error_Buyer_Name);
		}
		if(document.frmAddCustomer.Export_Invoice_Terms.options[document.frmAddCustomer.Export_Invoice_Terms.options.selectedIndex].value==0)
		{
			ErrorCount++;
			queueMessage("You must fill in the Invoice Terms field ",  document.all.error_Invoice_Terms);
		}
		else{
			clearQueue(document.all.error_Invoice_Terms);
		}
		if(document.frmAddCustomer.Export_Terms_of_Sale.options[document.frmAddCustomer.Export_Terms_of_Sale.options.selectedIndex].value==0)
		{
			ErrorCount++;
			queueMessage("You must fill in the Terms of Sale field ",  document.all.error_Terms_of_Sale);
		}
		else{
			clearQueue(document.all.error_Terms_of_Sale);
		}
		if(document.frmAddCustomer.Export_Primary_Warehouse.options[document.frmAddCustomer.Export_Primary_Warehouse.options.selectedIndex].value==0)
		{
			ErrorCount++;
			queueMessage("You must fill in the Primary Warehouse field ",  document.all.error_Primary_Warehouse);
		}
		else{
			clearQueue(document.all.error_Primary_Warehouse);
		}
		if(document.frmAddCustomer.Export_Discharge_Port.value=='')
		{
			ErrorCount++;
			queueMessage("You must fill in the Discharge Port field ",  document.all.error_Discharge_Port);
		}
		else{
			clearQueue(document.all.error_Discharge_Port);
		}
	}
		if(ErrorCount == 0) {
			document.frmAddCustomer.ChangeStatus.value = ChangeStatus;
			document.frmAddCustomer.submit();
				}
		else{
			showMessageWindow();
			return false;
		}
	}
</script>
</head>
	
<cfset Form.Export_Customer_ID = getcustomerDetails.Export_Customer_ID>
<cfset Form.Export_Customer_Name = getcustomerDetails.Export_Customer_Name>
<cfset Form.Export_Customer_Address_1 = getcustomerDetails.Export_Customer_Address_1>
<cfset Form.Export_Customer_Address_2 = getcustomerDetails.Export_Customer_Address_2>
<cfset Form.Export_Customer_Address_3 = getcustomerDetails.Export_Customer_Address_3>
<cfset Form.Export_Customer_City = getcustomerDetails.Export_Customer_City>
<cfset Form.Export_Customer_Phone = getcustomerDetails.Export_Customer_Phone>
<cfset Form.Export_Customer_Fax = getcustomerDetails.Export_Customer_Fax>
<cfset Form.Export_Customer_Email = getcustomerDetails.Export_Customer_Email>
<cfset Form.Export_Customer_Country = getcustomerDetails.Export_Customer_Country>
<cfset Form.Export_Customer_Base_Number = getcustomerDetails.Export_Customer_Base_Number>
<cfset Form.Export_Customer_Status_Type = getCustomerDetails.Export_Customer_Status_Type>
<cfset Form.Export_Customer_Include_Pallet = getCustomerDetails.Export_Customer_Include_Pallet>
<!--- Let the field name be "Export_Pallet_Type" as the code for populating this select box is in a file where the
			field name is this too and that code is being called in multiple places --->
<cfset Form.Export_Pallet_Type = getCustomerDetails.Export_Customer_Pallet_Type>
<cfset Form.Export_Customer_Quantity = getCustomerDetails.Export_Customer_Quantity>
<cfset Form.Export_Customer_Exempt_Relocation_Charge = getCustomerDetails.Export_Customer_Exempt_Relocation_Charge>
<cfset Form.Export_Customer_Unit_Of_Measure_ID = getCustomerDetails.Export_Customer_Unit_Of_Measure_ID>
<cfset Form.Export_Customer_Exempt_Domestic_Fuel_Charge = getCustomerDetails.Export_Customer_Exempt_Domestic_Fuel_Charge>
<cfset Form.Export_Buyer_Name = getCustomerDetails.Export_Buyer_Name>
<cfset Form.Export_Discharge_Port = getCustomerDetails.Export_Discharge_Port>
<cfset Form.Export_Terms_of_Sale = getCustomerDetails.Export_Terms_of_Sale>
<cfset Form.Export_Invoice_Terms = getCustomerDetails.Export_Invoice_terms>
<cfset Form.Export_Primary_Warehouse = getCustomerDetails.Export_Origin_ID>
<cfset Form.Export_Customer_Notes = getCustomerDetails.Export_Customer_Notes>

<cfset Form.Export_Notify_Name = getcustomerDetails.Export_Notify_Name>
<cfset Form.Export_Notify_Address_1 = getcustomerDetails.Export_Notify_Address_1>
<cfset Form.Export_Notify_Address_2 = getcustomerDetails.Export_Notify_Address_2>
<cfset Form.Export_Notify_Address_3 = getcustomerDetails.Export_Notify_Address_3>
<cfset Form.Export_Notify_City = getcustomerDetails.Export_Notify_City>
<cfset Form.Export_Notify_Phone = getcustomerDetails.Export_Notify_Phone>
<cfset Form.Export_Notify_Fax = getcustomerDetails.Export_Notify_Fax>
<cfset Form.Export_Notify_Country = getcustomerDetails.Export_Notify_Country>

<cfset Form.Export_Border_Crossing_Agent_Name = getcustomerDetails.Export_Border_Crossing_Agent_Name>
<cfset Form.Export_Border_Crossing_Agent_Address_1 = getcustomerDetails.Export_Border_Crossing_Agent_Address_1>
<cfset Form.Export_Border_Crossing_Agent_Address_2 = getcustomerDetails.Export_Border_Crossing_Agent_Address_2>
<cfset Form.Export_Border_Crossing_Agent_Address_3 = getcustomerDetails.Export_Border_Crossing_Agent_Address_3>
<cfset Form.Export_Border_Crossing_Agent_City = getcustomerDetails.Export_Border_Crossing_Agent_City>
<cfset Form.Export_Border_Crossing_Agent_State = getcustomerDetails.Export_Border_Crossing_Agent_State>
<cfset Form.Export_Border_Crossing_Agent_Zip = getcustomerDetails.Export_Border_Crossing_Agent_Zip>
<cfset Form.Export_Border_Crossing_Agent_Phone = getcustomerDetails.Export_Border_Crossing_Agent_Phone>

<!--- This is when none of the customer info is entered. --->
	<cfset StatusAllowed = 1>

<!--- When the "SOLD TO" info is entered, the status changes to work in progress, and the customer is eligible
			to be changed to the next status (Submit to Credit )--->
<cfif Form.Export_Customer_Name neq "" AND Form.Export_Customer_Address_1 neq "" AND Form.Export_Customer_Address_2 neq ""
AND Form.Export_Customer_Address_3 neq "" AND Form.Export_Customer_City neq "" AND Form.Export_Customer_Phone neq ""
AND Form.Export_Customer_Fax neq "" AND Form.Export_Customer_Email neq "" AND Form.Export_Customer_Country neq "">
	<cfset StatusAllowed = 2>
</cfif>

<!--- When the "NOTIFY" info is entered, the status changes to "Submit to Credit", and the customer is eligible
			to be changed to the next status (Submit to Master Data Group)--->
<cfif StatusAllowed eq 2>
		<cfif Form.Export_Customer_Status_Type eq 2 AND Form.Export_Notify_Name neq "" AND Form.Export_Notify_Address_1 neq "" 
		AND Form.Export_Notify_Address_2 neq "" AND Form.Export_Notify_Address_3 neq "" AND Form.Export_Notify_City neq "" 
		AND Form.Export_Notify_Country neq "" AND Form.Export_Notify_Phone neq "" AND Form.Export_Notify_Fax neq ""
		AND Form.Export_Buyer_Name neq "" AND Form.Export_Invoice_Terms neq "" AND Form.Export_Terms_of_Sale neq "" 
		AND Form.Export_Primary_Warehouse neq "" AND Form.Export_Discharge_Port neq "">
	<cfset StatusAllowed = 3>
</cfif>
</cfif>

<!--- When the status changes to "Submit to Master Data Group",  the customer is eligible to be active --->
<cfif Form.Export_Customer_Status_Type eq 3>
	<cfset StatusAllowed = 4>
</cfif>

<!--- When the customer is active, change the "StatusAllowed" to 0 (zero), as the customer has been made active (last step)
			and we do not want to see any change status link below. --->
<cfif Form.Export_Customer_Status_Type eq 4>
	<cfset StatusAllowed = 0>
</cfif>

<cfoutput>
<body onLoad="return getValidCustomerStatusTypes('#val(Form.Export_Customer_ID)#','#StatusAllowed#')">
<form action="sales_agreement_customer_request_action.cfm" method="post" name="frmAddCustomer">
<table  border="0" align ="center" cellpadding="2" cellspacing="0" width="450">
	<tr>
		<td width="25%">&nbsp;</td>
		<td><span style="font-size:12px; font-weight:bold">
		<cfif Form.Export_Customer_ID neq "">CUSTOMER ## #Form.Export_Customer_ID#<cfelse><u>ADD A NEW CUSTOMER</u></cfif>
		</style></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="2"><b><u>SOLD TO</u></b></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 1><span style="color:red;font-size:15px;">*</span></cfif>Customer Base ##:</td>
		<td><input type="text" name="Export_Customer_Base_Number" value="#Form.Export_Customer_Base_Number#"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 1><span style="color:red;font-size:15px;">*</span></cfif>Name:</td>
		<td><span id="error_Name"></span><input type="text" name="Export_Customer_Name" value="#Form.Export_Customer_Name#" maxlength="30"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Notes:</td>
		<td><input type="text" name="Export_Customer_Notes" value="#Form.Export_Customer_Notes#"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 1><span style="color:red;font-size:15px;">*</span></cfif>Address 1:</td>
		<td><span id="error_Address_1"></span><input type="text" name="Export_Customer_Address_1" value="#Form.Export_Customer_Address_1#" maxlength="30"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 1><span style="color:red;font-size:15px;">*</span></cfif>Address 2:</td>
		<td><span id="error_Address_2"></span><input type="text" name="Export_Customer_Address_2" value="#Form.Export_Customer_Address_2#" maxlength="30"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 1><span style="color:red;font-size:15px;">*</span></cfif>Address 3:</td>
		<td><span id="error_Address_3"></span><input type="text" name="Export_Customer_Address_3" value="#Form.Export_Customer_Address_3#" maxlength="30"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 1><span style="color:red;font-size:15px;">*</span></cfif>City:</td>
		<td><span id="error_City"></span><input type="text" name="Export_Customer_City" value="#Form.Export_Customer_City#" maxlength="30"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 1><span style="color:red;font-size:15px;">*</span></cfif>Country:</td>
		<td><span id="error_Country"></span>
			<select name="Export_Customer_Country">
					<option value="0">Please Select</option>
				<cfloop query="qrygetCountryList">
					<option value="#Export_Lookup_Destination_Country_ID#" <cfif Form.Export_Customer_Country eq Export_Lookup_Destination_Country_ID>selected </cfif>>#Export_Lookup_Destination_Country_Desc#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 1><span style="color:red;font-size:15px;">*</span></cfif>Phone:</td>
		<td><span id="error_Phone"></span><input type="text" name="Export_Customer_Phone" value="#Form.Export_Customer_Phone#"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 1><span style="color:red;font-size:15px;">*</span></cfif>Fax:</td>
		<td><span id="error_Fax"></span><input type="text" name="Export_Customer_Fax" value="#Form.Export_Customer_Fax#"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 1><span style="color:red;font-size:15px;">*</span></cfif>Email:</td>
		<td><span id="error_Email"></span><input type="text" name="Export_Customer_Email" value="#Form.Export_Customer_Email#"></td>
	</tr>
		<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="2"><b><u>NOTIFY</u></b></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 2><span style="color:red;font-size:15px;">*</span></cfif>Name:</td>
		<td><span id="error_Notify_Name"></span><input type="text" name="Export_Notify_Name" value="#Form.Export_Notify_Name#" maxlength="30"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 2><span style="color:red;font-size:15px;">*</span></cfif>Address 1:</td>
		<td><span id="error_Notify_Address_1"></span><input type="text" name="Export_Notify_Address_1" value="#Form.Export_Notify_Address_1#" maxlength="30"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 2><span style="color:red;font-size:15px;">*</span></cfif>Address 2:</td>
		<td><span id="error_Notify_Address_2"></span><input type="text" name="Export_Notify_Address_2" value="#Form.Export_Notify_Address_2#" maxlength="30"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 2><span style="color:red;font-size:15px;">*</span></cfif>Address 3:</td>
		<td><span id="error_Notify_Address_3"></span><input type="text" name="Export_Notify_Address_3" value="#Form.Export_Notify_Address_3#" maxlength="30"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 2><span style="color:red;font-size:15px;">*</span></cfif>City:</td>
		<td><span id="error_Notify_City"></span><input type="text" name="Export_Notify_City" value="#Form.Export_Notify_City#" maxlength="30"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 2><span style="color:red;font-size:15px;">*</span></cfif>Country:</td>
		<td><span id="error_Notify_Country"></span>
			<select name="Export_Notify_Country">
					<option value="0">Please Select</option>
				<cfloop query="qrygetCountryList">
					<option value="#Export_Lookup_Destination_Country_ID#" <cfif Form.Export_Notify_Country eq Export_Lookup_Destination_Country_ID>selected </cfif>>#Export_Lookup_Destination_Country_Desc#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 2><span style="color:red;font-size:15px;">*</span></cfif>Phone:</td>
		<td><span id="error_Notify_Phone"></span><input type="text" name="Export_Notify_Phone" value="#Form.Export_Notify_Phone#"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 2><span style="color:red;font-size:15px;">*</span></cfif>Fax:</td>
		<td><span id="error_Notify_Fax"></span><input type="text" name="Export_Notify_Fax" value="#Form.Export_Notify_Fax#"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 2><span style="color:red;font-size:15px;">*</span></cfif>Buyer Name:</td>
		<td><span id="error_Buyer_Name"></span><input type="text" name="Export_Buyer_Name" value="#Form.Export_Buyer_Name#" maxlength="15"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 2><span style="color:red;font-size:15px;">*</span></cfif>Invoice Terms</td>
		<td><span id="error_Invoice_Terms"></span>
			<select name="Export_Invoice_Terms">
					<option value="0">Please Select</option>
				<cfloop query="qrygetInvoiceTerms">
					<option value="#Invoice_Terms_ID#" <cfif Form.Export_Invoice_Terms eq Invoice_Terms_ID> selected </cfif>>#Inv_code# - #Description1#,#Description2#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 2><span style="color:red;font-size:15px;">*</span></cfif>Terms of Sale:</td>
		<td><span id="error_Terms_of_Sale"></span>
			<select name="Export_Terms_of_Sale">
					<option value="0">Please Select</option>
				<cfloop query="qrygetTermsOfSale">
					<option value="#Export_Lookup_Terms_of_Sale_ID#" <cfif Form.Export_Terms_of_Sale eq Export_Lookup_Terms_of_Sale_ID> selected </cfif>>#Export_Lookup_Terms_of_Sale_Desc#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 2><span style="color:red;font-size:15px;">*</span></cfif>Primary Whse/Shipping Location:</td>
		<td><span id="error_Primary_Warehouse"></span>
			<select name="Export_Primary_Warehouse">
					<option value="0">Please Select</option>
				<cfloop query="qrygetOrigin">
					<option value="#Export_Lookup_Origin_ID#" <cfif Form.Export_Primary_Warehouse eq Export_Lookup_Origin_ID> selected </cfif>>#Export_Lookup_Origin_Desc#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes"><cfif StatusAllowed eq 2><span style="color:red;font-size:15px;">*</span></cfif>Discharge Port:</td>
		<td><span id="error_Discharge_Port"></span><input type="text" name="Export_Discharge_Port" value="#Form.Export_Discharge_Port#"></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="2"><b><u>BORDER CROSSING AGENT: (Mexico Destinations & Canada Origins)</u></b></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Name:</td>
		<td><input type="text" name="Export_Border_Crossing_Agent_Name" value="#Export_Border_Crossing_Agent_Name#" maxlength="30"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Address 1:</td>
		<td><input type="text" name="Export_Border_Crossing_Agent_Address_1" value="#Export_Border_Crossing_Agent_Address_1#" maxlength="30"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Address 2:</td>
		<td><input type="text" name="Export_Border_Crossing_Agent_Address_2" value="#Export_Border_Crossing_Agent_Address_2#" maxlength="30"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Address 3:</td>
		<td><input type="text" name="Export_Border_Crossing_Agent_Address_3" value="#Export_Border_Crossing_Agent_Address_3#" maxlength="30"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">City:</td>
		<td><input type="text" name="Export_Border_Crossing_Agent_City" value="#Export_Border_Crossing_Agent_City#" maxlength="30"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Zip:</td>
		<td><input type="text" name="Export_Border_Crossing_Agent_Zip" value="#Export_Border_Crossing_Agent_Zip#"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">State:</td>
		<td><input type="text" name="Export_Border_Crossing_Agent_State" value="#Export_Border_Crossing_Agent_State#"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Phone:</td>
		<td><input type="text" name="Export_Border_Crossing_Agent_Phone" value="#Export_Border_Crossing_Agent_Phone#"></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Include Pallet:</td>
		<td>
			<select name="Export_Customer_Include_Pallet" onChange="getPallets()">
					<option value="0">No</option>
					<option value="1" <cfif Form.Export_Customer_Include_Pallet eq 1>selected</cfif>>Yes</option>
			</select>
		</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Pallet Type:</td>
		<td id ="Export_Pallet_Type_Cell_id">
			<select name="Export_Pallet_Type">
					<option value="0">None</option>
			</select>
		</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Quantity:</td>
		<td><input type="text" name="Export_Customer_Quantity" value="#Form.Export_Customer_Quantity#"></td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Customer exempt from relocation<br /> charges:</td>
		<td>
			<select name="Export_Customer_Exempt_Relocation_Charge">
					<option value="0">No</option>
					<option value="1" <cfif Form.Export_Customer_Exempt_Relocation_Charge eq 1>selected</cfif>>Yes</option>
			</select>
		</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Invoicing:</td>
		<td>
			<select name="Export_Customer_Unit_Of_Measure_ID">
					<option value="1">Cases</option>
					<option value="2" <cfif Form.Export_Customer_Unit_Of_Measure_ID eq 2>selected</cfif>>Pounds</option>
			</select>
		</td>
	</tr>
	<tr>
		<td width="25%" class="TableAttributes">Customer exempt from domestic<br /> fuel charges:</td>
		<td>
			<select name="Export_Customer_Exempt_Domestic_Fuel_Charge">
					<option value="0">No</option>
					<option value="1" <cfif Form.Export_Customer_Exempt_Domestic_Fuel_Charge eq 1>selected</cfif>>Yes</option>
			</select>
		</td>
	</tr>
</table>
<INPUT TYPE="Hidden" NAME="CID" 	VALUE="#CID#">
<INPUT TYPE="Hidden" NAME="ChangeStatus" 	VALUE="0">
<INPUT TYPE="Hidden" NAME="StatusAllowed" 	VALUE="#StatusAllowed#">
</form>

<div align="center">
	<B>
		<FONT SIZE="2" COLOR="red">[ </FONT><a href="##" ONCLICK="Javascript:CheckForm('#StatusAllowed#','0');return false;">Save</A><FONT SIZE="2" COLOR="red"> ]</FONT>
	</B>

<!--- StatusAllowed is 0 (zero) when the customer is active --->
<cfif StatusAllowed GTE 2 OR StatusAllowed EQ 0>
<!--- Show the current status here --->
<span id="Export_Customer_Status_Type_id"></span>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<B>
		<FONT SIZE="2" COLOR="red">[ </FONT><a href="/common_files/contracts/sales_agreement_customer_fax_create.cfm?CID=#CID#" onClick="NewWindow(this.href,'emailpage','800','600','Yes', 'No');return false;">Fax</a><FONT SIZE="2" COLOR="red"> ]</FONT>
	</B>
	<B>
		<FONT SIZE="2" COLOR="red">[ </FONT><a href="/common_files/contracts/sales_agreement_customer_email_create.cfm?CID=#CID#" onClick="NewWindow(this.href,'emailpage','800','600','Yes', 'No');return false;">Email</a><FONT SIZE="2" COLOR="red"> ]</FONT>
	</B>
	<B>
		<FONT SIZE="2" COLOR="red">[ </FONT><a href="/common_files/contracts/sales_agreement_customer_printer_friendly.cfm?CID=#CID#" onClick="NewWindow(this.href,'printpage','800','600','Yes', 'No');return false;">Print</a><FONT SIZE="2" COLOR="red"> ]</FONT>
	</B>
</cfif>
</div>
</body>
</cfoutput>

<cfsetting showdebugoutput="true">