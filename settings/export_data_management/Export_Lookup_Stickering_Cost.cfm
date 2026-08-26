<script language="javascript">
	/* Add a new cost field */
	function AddCost()
	{
		document.all.StickeringCostsID.style.display = ''
	}
</script>

<cfset Agreement_Details = CreateObject("component","components.Export.Sales_Agreement_AJAX") />

<cfset getLookupStickeringCosts = Agreement_Details.getAllStickeringCosts()>

<form name="ExportFrm" action="Save_Export_Stickering_Cost.cfm" method="post">
	<cfoutput>
		<input type="hidden" name="Action" value="#Action#">
	</cfoutput>
		<table>
			<tr>
				<td><b>Description</b></td>
				<td><b>Cost</b></td>
			</tr>
			<cfoutput query="getLookupStickeringCosts">
			<tr>
				<td><input type="text" name="txtLookupStickeringCostsDesc_#Export_Stickering_Cost_ID#" value="#Export_Stickering_Cost_Desc#" size="30" style="background-color: cccccc" readonly></td>
				<td><input type="text" name="txtLookupStickeringCostsLB_#Export_Stickering_Cost_ID#" value="#Export_Stickering_Cost_LB#" size="8"></td>
			</tr>
			</cfoutput>
			<tr id="StickeringCostsID" style="display:none">
				<td><input type="text" name="txtAddLookupStickeringCostsDesc" value="" size="30"></td>
				<td><input type="text" name="txtAddLookupStickeringCostsLB" value="" size="8"></td>
			</tr>
			<tr>
				<td colspan="2"><B><font color="FF0000">[</font> <a href="javascript:ExportFrm.submit();">save</a> <font color="FF0000">]</font></B>&nbsp;
				<B><font color="FF0000">[</font> <a href="javascript:void(0);" onClick="AddCost()">Add a Cost</a> <font color="FF0000">]</font></B>&nbsp;
				</td>
			</tr>
		</table>
</form>

<cfsetting showdebugoutput="true">