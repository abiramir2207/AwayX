<cfset Agreement_Details = CreateObject("component","components.Export.Sales_Agreement") />

<cfset getLookupFreightCharges = Agreement_Details.getLookupFreightCharges()>
<p>
<table>
	<tr>
		<td><b>Origin</b></td>
		<td><b>Port</b></td>
		<td><b>Country</b></td>
		<td><b>Freight Cost</b></td>
	</tr>

	<cfoutput query="getLookupFreightCharges">
	<tr>
		<td><input type="text" name="txtLookupOrigin" value="#Export_Lookup_Origin_Code#" size="1"  style="background-color: cccccc" readonly></td>
		<td><input type="text" name="txtLookupDestinationPort" value="#Export_Lookup_Destination_Port_Desc#" size="10" style="background-color: cccccc" readonly></td>
		<td><input type="text" name="txtLookupDestinationCountry" value="#Export_Lookup_Destination_Country_Desc#" size="10" style="background-color: cccccc" readonly></td>
		<td><input type="text" name="txtLookupFreightCost" value="#Export_Lookup_Freight_Cost#" size="8" style="background-color: cccccc" readonly></td>
	</tr>
	</cfoutput>
</table>


<form action="save_export_freight.cfm" method="post">
	<cfoutput>
		<input type="hidden" name="Action" value="#Action#">
	</cfoutput>
	<span style="color:red">Paste your excel data here. Please do not copy the header row.</span>
	<table>
		<tr>
			<td><textarea name="FreightData" cols="140" rows="15"></textarea></td>
		</tr>
		<tr>
			<td><input type="submit" name="SubmitFreightData" value="Save"></td>
		</tr>
	</table>
</form>

<cfsetting showdebugoutput="true">