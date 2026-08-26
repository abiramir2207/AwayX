<!------ update_entry_status_search_form.cfm ----->
<!------ Display The Form ----->
<cfoutput>
<table cellpadding="5" cellspacing="0" align="center" border="0">
<tr>
	<td>
		<strong>Enter program number followed by enter key</strong>
	</td>
</tr>
<tr>
	<td align="center">
		<textarea name="Program_Number_List" cols="40" rows="20">#Form.Program_Number_List#</textarea>
	</td>
</tr>
<tr>
	<td align="center">
		<CF_smallLink 
			title = "submit" 
			url = "##"
			parameters = "onClick=""javascript: return submitForm('search-result');"""
		>
	</td>
</tr>
<tr>
	<td>
		<HR color="##000000">
			<span ID="searchItemLabel" STYLE="color:red;font-style:italic;font-weight:bold">Alphanumeric characters only: [A-Z] and [0-9]</span><!--- The only valid characters are Numeric and Alpha --->
		<HR color="##000000">
	</td>
</tr>
</table>
</cfoutput>