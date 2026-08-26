<script language="javascript">
	/* Add a new port field */
	function AddPort()
	{
		document.all.PortID.style.display = ''
	}
</script>

<cfset Agreement_Details = CreateObject("component","components.Export.Sales_Agreement") />

<cfset getLookupDestinationPorts = Agreement_Details.getLookupDestinationPorts()>
<cfset getLookupNamedPlaceType = Agreement_Details.getLookupNamedPlaceType()>
<cfset getCountryList = Agreement_Details.getCountryList()>

<form name="ExportFrm" action="Save_Export_Destination_Ports.cfm" method="post">
	<cfoutput>
		<input type="hidden" name="Action" value="#Action#">
	</cfoutput>
		<table>
			<tr>
				<td><b>Description</b></td>
			</tr>
			<cfoutput query="getLookupDestinationPorts">
			<tr>
				<td><input type="text" name="txtLookupDestinationPort_#Export_Lookup_Destination_Port_ID#" value="#Export_Lookup_Destination_Port_Desc#" size="28" style="background-color: cccccc" readonly></td>
			</tr>
			</cfoutput>
			<tr id="PortID" style="display:none">
				<td><input type="text" name="txtAddLookupDestinationPort" value="" size="28"></td>
				<td><b>Type of Port</b><br />
						<select name="SelAddLookupNamedPlaceType">
							<cfoutput query="getLookupNamedPlaceType">
								<option value="#Export_Lookup_Named_Place_Type_ID#">#Export_Lookup_Named_Place_Type_Desc#</option>
							</cfoutput>
						</select>
				</td>
				<td><b>Country</b><br />
						<select name="SelAddLookupDestinationCountry">
							<cfoutput query="getCountryList">
								<option value="#Export_Lookup_Destination_Country_ID#">#Export_Lookup_Destination_Country_Desc#</option>
							</cfoutput>
						</select>
				</td>
			</tr>
			<tr>
				<td colspan="2"><B><font color="FF0000">[</font> <a href="javascript:ExportFrm.submit();">save</a> <font color="FF0000">]</font></B>&nbsp;
				<B><font color="FF0000">[</font> <a href="javascript:void(0);" onClick="AddPort()">Add a Port</a> <font color="FF0000">]</font></B>&nbsp;
				</td>
			</tr>
		</table>
</form>

<cfsetting showdebugoutput="true">