
<cfif qProgramInfo.Fuel_Surcharge_ON EQ 1>
	<cfif ( (DateFormat(qProgramInfo.Fuel_Surcharge_Expiration_Date,"mm/dd/yyyy") EQ "01/01/1900") OR (DateFormat(qProgramInfo.Fuel_Surcharge_Expiration_Date,"mm/dd/yyyy") EQ "01/01/3900") )>
		<cfset fuelSurchargeExpDate = "">
	<cfelse>
		<cfset fuelSurchargeExpDate = DateFormat(qProgramInfo.Fuel_Surcharge_Expiration_Date,"MM/DD/YYYY") />
	</cfif>	
	<cfif IsDefined("qProgramInfo.Fuel_Surcharge_Amount") and qProgramInfo.Fuel_Surcharge_Amount NEQ 0.00>
		<cfset fuelSurchargeAmount = qProgramInfo.Fuel_Surcharge_Amount />
	<cfelse>
		<cfset fuelSurchargeAmount = 0.00 />
	</cfif>
<cfelse>
	<cfset fuelSurchargeExpDate = "">
	<!---D42957 :: 	Fuel surcharge adjustment does not export to Excel when program flag is set to NO --->
	<cfset fuelSurchargeAmount = qProgramInfo.Fuel_Surcharge_Amount/>
</cfif>

<table>
	
	<tr>
		<td><b>Program Number</b></td>
		<td><b>Title</b></td>
		<td><b>Start Date</b></td>
		<td><b>End Date</b></td>
		<td><b><b>Freight Type</b></td>
		<td><b>Program Volume</b></td>
		<td><b><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput></b></td>
		<td><b><cfoutput>#application.returned_customer_setting.shard_ship_to_label#</cfoutput></b></td>
		<td><b>Address</b></td>
		<td><b>City</b></td>
		<td><b>State</b></td>
		<td><b>Zip</b></td>
		<td><b>Weight</b></td>
		<td><b>Warehouse Code</b></td>
		<td><b>Warehouse Name</b></td>
		<td><b>Warehouse Address</b></td>
		<td><b>Warehouse City</b></td>
		<td><b>Warehouse State</b></td>
		<td><b>Warehouse Zip</b></td>
		<td><b>Warehouse Country</b></td>
	<cfif qProgramInfo.Freight_Component_Type eq 1>
		<td><b>Bracket</b></td>
	</cfif>
		<td><b>IBF/cwt</b></td>
	<cfif qProgramInfo.Freight_Component_Type eq 1>
		<td><b>OBF/cwt</b></td>
		<td><b>PUA/cwt</b></td>
	</cfif>	
		<td><b>Frt.Adj</b></td>
		<td><b>Fuel Base Amount</b></td>
		<td><b>Fuel Base Adj. Exp. Date</b></td>
		
		
	</tr>

	<cfoutput query="qProgramDistributorFreight">
	<tr>
		<td align="left">#qProgramInfo.Contract_Number#</td>
		<td align="left">#qProgramInfo.Contract_Title#</td>
		<td align="left">#DateFormat(qProgramInfo.Contract_Start_Date,"MM/DD/YYYY")#</td>
		<td align="left">#DateFormat(qProgramInfo.Contract_End_Date,"MM/DD/YYYY")#</td>
		<td align="left">#qProgramInfo.Fixed_Type#</td>
		<td align="left">#qProgramInfo.Contract_Quantity#</td>
		<td align="left">#Name#</td>
		<td align="left">#Shr_Ship_to#</td>
		<td align="left">#Address_1#&nbsp;#Address_2#</td>
		<td align="left">#City#</td>
		<td align="left">#State#</td>
		<td align="left">#ZipCode#</td>
		<td align="left">#Evaluate("Program_Weight/100")#</td>
		<td align="left">#Warehouse_Code#</td>
		<td align="left">#Warehouse_Name#</td>
		<td align="left">#Warehouse_Address_1#&nbsp;#Warehouse_Address_2#</td>
		<td align="left">#Warehouse_City#</td>
		<td align="left">#Warehouse_State#</td>
		<td align="left">#Warehouse_Zip#</td>
		<td align="left">#Warehouse_Country_Code#</td>
	<cfif qProgramInfo.Freight_Component_Type eq 1>
		<td align="left">#Freight_Bracket_Label#</td>
	</cfif>
		<td align="left">#IBF_Rate#</td>
	<cfif qProgramInfo.Freight_Component_Type eq 1>
		<td align="left">#OBF_Rate#</td>
		<td align="left">#Pickup_Allowance#</td>
	</cfif>
		<td align="left">#Freight_Adjustment#</td>
		<td align="left">$#fuelSurchargeAmount#</td>		
		<td align="left">#fuelSurchargeExpDate#</td>

	</tr>
	</cfoutput>
</table>