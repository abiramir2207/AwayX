<script language="javascript">
	/* Add a new Origin field */
	function AddOrigin()
	{
		document.all.OriginID.style.display = ''
	}
</script>

<cfset Agreement_Details = CreateObject("component","components.Export.Sales_Agreement_AJAX") />

<cfset getOrigin = Agreement_Details.getOrigin()>

<form name="ExportFrm" action="Save_Export_Origin.cfm" method="post">
	<cfoutput>
		<input type="hidden" name="Action" value="#Action#">
	</cfoutput>
		<table>
			<tr>
				<td><b>Description</b></td>
				<td><b>Code</b></td>
			</tr>
			<cfoutput query="getOrigin">
			<tr>
				<td><input type="text" name="txtLookupOriginDesc_#Export_Lookup_Origin_ID#" value="#Export_Lookup_Origin_Desc#" style="background-color: cccccc" readonly></td>
				<td><input type="text" name="txtLookupOriginCode_#Export_Lookup_Origin_ID#" value="#Export_Lookup_Origin_Code#" size="1" maxlength="2" style="background-color: cccccc" readonly></td>
			</tr>
			</cfoutput>
			<tr id="OriginID" style="display:none">
				<td><input type="text" name="txtAddLookupOriginDesc" value=""></td>
				<td><input type="text" name="txtAddLookupOriginCode" value="" size="1" maxlength="2"></td>
			</tr>
			<tr>
				<td colspan="2"><B><font color="FF0000">[</font> <a href="javascript:ExportFrm.submit();">save</a> <font color="FF0000">]</font></B>&nbsp;
				<B><font color="FF0000">[</font> <a href="javascript:void(0);" onClick="AddOrigin()">Add a Origin</a> <font color="FF0000">]</font></B>&nbsp;
				</td>
			</tr>
		</table>
</form>

<cfsetting showdebugoutput="true">