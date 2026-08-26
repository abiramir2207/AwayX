<cfparam name="GLList" default="">

<cfif len(trim(GLList)) GT 0>
<table>

<cfquery name="GetGLS" datasource="#application.datasource#">
SELECT GL_Account, GL_Account_Desc
FROM GL_Account
WHERE GL_Account_ID IN (#GLList#)
</cfquery>
	<cfoutput query="GetGLS">
	<tr>
		<td>
			#GL_Account# (#GL_Account_Desc#)
		</td>
	</tr>
	</cfoutput>
</table>

</cfif>