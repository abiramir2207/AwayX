<script language="javascript">
	/* Add a new Relocation Cost field */
	function AddRelocationCost()
	{
		document.all.OriginRelocationID.style.display = ''
	}
</script>

<cfset Agreement_Details = CreateObject("component","components.Export.Sales_Agreement") />

<cfset getLookupRelocationCost = Agreement_Details.getLookupRelocationCost()>

<form name="ExportFrm" action="Save_Export_Origin_Relocation.cfm" method="post">
	<cfoutput>
		<input type="hidden" name="Action" value="#Action#">
	</cfoutput>
		<table width="30%">
			<tr>
				<td><b>From</b></td>
				<td><b>To</b></td>
				<td><b>Cost</b></td>
			</tr>
			<cfoutput query="getLookupRelocationCost">
			<tr>
				<td><input type="text" name="txtLookupItemOriginCode" value="#Item_Origin_Code#"  size="1" maxlength="2" style="background-color: cccccc" readonly</td>
				<td><input type="text" name="txtLookupExportOriginTo" value="#Export_Origin_To#" size="1" maxlength="2"  style="background-color: cccccc" readonly></td>
				<td><input type="text" name="txtLookupExportRelocationCost_#Item_Origin_Code#_#Export_Origin_To#" value="#Export_Origin_Relocation_Cost#" size="8"></td>
			</tr>
			</cfoutput>
			<tr id="OriginRelocationID" style="display:none">
				<td><input type="text" name="txtAddLookupItemOriginCode" size="1" maxlength="2" value=""></td>
				<td><input type="text" name="txtAddLookupExportOriginTo" size="1" maxlength="2" value=""></td>
				<td><input type="text" name="txtAddLookupExportRelocationCost" value="" size="8"></td>
			</tr>
			<tr>
				<td colspan="3"><B><font color="FF0000">[</font> <a href="javascript:ExportFrm.submit();">save</a> <font color="FF0000">]</font></B>&nbsp;
				<B><font color="FF0000">[</font> <a href="javascript:void(0);" onClick="AddRelocationCost()">Add a Relocation Cost</a> <font color="FF0000">]</font></B>&nbsp;
				</td>
			</tr>
		</table>
</form>

<cfsetting showdebugoutput="true">