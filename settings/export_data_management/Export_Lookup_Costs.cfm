<script language="javascript">
	/* Add a new cost field */
	function AddCost()
	{
		document.all.StandardCostsID.style.display = ''
	}
</script>

<cfset Agreement_Details = CreateObject("component","components.Export.Sales_Agreement") />

<cfset getLookupStandardCosts = Agreement_Details.getLookupStandardCosts()>

<form name="ExportFrm" action="Save_Export_Cost_Data.cfm" method="post">
	<cfoutput>
		<input type="hidden" name="Action" value="#Action#">
	</cfoutput>
		<table>
			<tr>
				<td><b>Description</b></td>
				<td><b>Cost</b></td>
			</tr>
			<cfoutput query="getLookupStandardCosts">
			<tr>
				<td><input type="text" name="txtLookupStandardCostsDesc_#Export_Lookup_Cost_ID#" value="#Export_Lookup_Cost_Desc#" size="25"  style="background-color: cccccc" readonly></td>
				<td><input type="text" name="txtLookupStandardCosts_#Export_Lookup_Cost_ID#" value="#Export_Lookup_Cost#" size="8"></td>
			</tr>
			</cfoutput>
			<tr id="StandardCostsID" style="display:none">
				<td><input type="text" name="txtAddLookupStandardCostsDesc" value="" size="25"></td>
				<td><input type="text" name="txtAddLookupStandardCosts" value="" size="8"></td>
			</tr>
			<tr>
				<td colspan="2"><B><font color="FF0000">[</font> <a href="javascript:ExportFrm.submit();">save</a> <font color="FF0000">]</font></B>&nbsp;
				<B><font color="FF0000">[</font> <a href="javascript:void(0);" onClick="AddCost()">Add a Cost</a> <font color="FF0000">]</font></B>&nbsp;
				</td>
			</tr>
		</table>
</form>

<cfsetting showdebugoutput="true">