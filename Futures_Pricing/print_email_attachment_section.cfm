<cfparam name="Attributes.desc" 	default="">
<cfparam name="Attributes.id" 	default="">
<cfoutput>
<tr>
	<td align="right" width="150" valign="top">
	<input type="Checkbox" name="FP_Attachment_ID" value="#Attributes.id#">
	</td>
	<td>#Attributes.desc#</td>
</tr>
</cfoutput>