<script language="javascript">
	/* Add a new country field */
	function AddCountry()
	{
		document.all.DestinationCountryID.style.display = ''
	}
</script>

<cfset Agreement_Details_AJAX = CreateObject("component","components.Export.Sales_Agreement_AJAX") />
<cfset Agreement_Details = CreateObject("component","components.Export.Sales_Agreement") />

<cfset getLookupDestinationCountry = Agreement_Details_AJAX.getDestination()>
<cfset getLookupPalletType = Agreement_Details.getLookupPalletType()>
<cfset getUnAddedCountries = Agreement_Details.getUnAddedCountries()>

<form name="ExportFrm" action="Save_Export_Country_Data.cfm" method="post">
	<cfoutput>
		<input type="hidden" name="Action" value="#Action#">
	</cfoutput>
		<table>
			<tr>
				<td><b>Description</b></td>
				<td><b>Max Weight</b></td>
				<td>&nbsp;&nbsp;<b>Allow Pallets</b></td>
			</tr>
			<cfoutput query="getLookupDestinationCountry">
			<tr>
				<td><input type="text" name="txtLookupDestinationCountry_#Export_Lookup_Destination_Country_ID#" value="#Export_Lookup_Destination_Country_Desc#" style="background-color: cccccc" readonly></td>
				<td><input type="text" name="txtLookupMaxWeight_#Export_Lookup_Destination_Country_ID#" value="#Export_Lookup_Max_Weight#" size="8"></td>
				<td align="center"><input type="checkbox" name="txtLookupAllowPallets_#Export_Lookup_Destination_Country_ID#" value="1" <cfif Export_Lookup_Allow_Pallets eq 1>checked</cfif>></td>
			</tr>
			</cfoutput>
			<tr id="DestinationCountryID" style="display:none">
				<td valign="top">			
					<select name="selAddLookupDestinationCountry">
							<option value="">--------------------SELECT--------------------</option>
						<cfoutput query="getUnAddedCountries">
							<option value="#Country_Name#">#Country_Name#</option>
						</cfoutput>
					</select>
				</td>
				<td valign="top"><input type="text" name="txtAddLookupMaxWeight" value="" size="8"></td>
				<td valign="top" align="center"><input type="checkbox" name="txtAddLookupAllowPallets" value="1"></td>
				<td valign="top"><b>Select Pallets Not Allowed</b><br />		
						<select name="selAddLookupPalletTypeDesc" multiple size="3">
							<cfoutput query="getLookupPalletType">
								<option value="#Export_Lookup_Pallet_Type_ID#">#Export_Lookup_Pallet_Type_Desc#</option>
							</cfoutput>
						</select>
				</td>
			</tr>
			<tr>
				<td colspan="4"><B><font color="FF0000">[</font> <a href="javascript:ExportFrm.submit();">save</a> <font color="FF0000">]</font></B>&nbsp;
				<B><font color="FF0000">[</font> <a href="javascript:void(0);" onClick="AddCountry()">Add a Country</a> <font color="FF0000">]</font></B>&nbsp;
				</td>
			</tr>
		</table>
</form>

<cfsetting showdebugoutput="true">