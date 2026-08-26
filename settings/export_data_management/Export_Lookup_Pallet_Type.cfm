<script language="javascript">
	/* Add a new pallet field */
	function AddPallet()
	{
		document.all.PalletTypeID.style.display = ''
	}
</script>

<cfset Agreement_Details = CreateObject("component","components.Export.Sales_Agreement") />

<cfset getLookupPalletType = Agreement_Details.getLookupPalletType()>

<form name="ExportFrm" action="Save_Export_Pallet_Type.cfm" method="post">
	<cfoutput>
		<input type="hidden" name="Action" value="#Action#">
	</cfoutput>
		<table>
			<tr>
				<td><b>Description</b></td>
			</tr>
			<cfoutput query="getLookupPalletType">
			<tr>
				<td><input type="text" name="txtLookupPalletTypeDesc_#Export_Lookup_Pallet_Type_ID#" value="#Export_Lookup_Pallet_Type_Desc#" style="background-color: cccccc" readonly></td>
				<td>
			</tr>
			</cfoutput>
			<tr id="PalletTypeID" style="display:none">
				<td><input type="text" name="txtAddLookupPalletTypeDesc" value=""></td>
			</tr>
			<tr>
				<td colspan="2"><B><font color="FF0000">[</font> <a href="javascript:ExportFrm.submit();">save</a> <font color="FF0000">]</font></B>&nbsp;
				<B><font color="FF0000">[</font> <a href="javascript:void(0);" onClick="AddPallet()">Add a Pallet</a> <font color="FF0000">]</font></B>&nbsp;
				</td>
			</tr>
		</table>
</form>

<cfsetting showdebugoutput="true">