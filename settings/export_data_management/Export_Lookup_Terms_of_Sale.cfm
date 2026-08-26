<script language="javascript">
	/* Add a new terms of sale field */
	function AddTermsOfSale()
	{
		document.all.TermsOfSaleID.style.display = ''
	}
</script>

<cfset Agreement_Details = CreateObject("component","components.Export.Sales_Agreement") />

<cfset getLookupTermsOfSale = Agreement_Details.getLookupTermsOfSale()>
<cfset getLookupNamedPlaceType = Agreement_Details.getLookupNamedPlaceType()>

<form name="ExportFrm" action="Save_Export_Terms_Of_Sale.cfm" method="post">
	<cfoutput>
		<input type="hidden" name="Action" value="#Action#">
	</cfoutput>
		<table>
			<tr>
				<td><b>Description</b></td>
			</tr>
			<cfoutput query="getLookupTermsOfSale">
			<tr>
				<td><input type="text" name="txtLookupTermsofSaleDesc_#Export_Lookup_Terms_of_Sale_ID#" value="#Export_Lookup_Terms_of_Sale_Desc#" size="6" style="background-color: cccccc" readonly></td>
				<td>
			</tr>
			</cfoutput>
			<tr id="TermsOfSaleID" style="display:none">
				<td><input type="text" name="txtAddLookupTermsofSaleDesc" value="" size="6"></td>
				<td><b>Associate to which Named Place List?</b><br />
						<select name="SelAddLookupNamedPlaceType">
							<cfoutput query="getLookupNamedPlaceType">
								<option value="#Export_Lookup_Named_Place_Type_ID#">#Export_Lookup_Named_Place_Type_Desc#</option>
							</cfoutput>
						</select>
				</td>
			</tr>
			<tr>
				<td colspan="2"><B><font color="FF0000">[</font> <a href="javascript:ExportFrm.submit()">save</a> <font color="FF0000">]</font></B>&nbsp;
				<B><font color="FF0000">[</font> <a href="javascript:void(0);" onClick="AddTermsOfSale()">Add a Terms of Sale</a> <font color="FF0000">]</font></B>&nbsp;
				</td>
			</tr>
		</table>
</form>

<cfsetting showdebugoutput="true">