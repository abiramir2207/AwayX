<cffunction name="SettingsTemplateForm">
	<cfargument name="NameField" type="string" required="true" default="">
	<cfargument name="NameFieldDesc" type="string" required="true" default="">
	<cfargument name="SettingDisplayValueInTable" type="string" required="false" default="">
	<cfargument name="SettingDisplayValueInTableID" type="string" required="false" default="0">

	<cfoutput>
	<cfif TemplatePage EQ 'BasicInfo'>
		<tr>
			<td>#arguments.NameFieldDesc#</td>
			<td align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="#arguments.NameField#" value="1" id="#arguments.NameField#_1" <cfif templateSettings[arguments.NameField] EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="#arguments.NameField#" value="0" id="#arguments.NameField#_0" <cfif templateSettings[arguments.NameField] EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</td>
			<cfif strException_Active[arguments.NameField] EQ 0>
				<cfset LinkExceptions = "Select Exceptions">
			<cfelse>
				<cfset LinkExceptions = "Update Exceptions">
			</cfif>
			<td>
				<CF_smallLink
					title = "#LinkExceptions#"
					url = "##"
					parameters = "onClick=""javascript: return AddExceptions('#Generic_Type#','#SettingIDs[arguments.NameField]#','#arguments.NameField#');"""
				>
				<span id="picon_#SettingIDs[arguments.NameField]#"></span>
				<font>&nbsp;</font>
			</td>
  		</tr>


<cfelse>


	<cfset arguments.NameFieldDesc =  ReReplace(arguments.NameFieldDesc, "&", " ", "ALL") />

		<cfif len(arguments.SettingDisplayValueInTable) GT 0>
			<cfset LinkExceptions = "Update Exceptions">
			<td>
				<CF_smallLink
					title = "#LinkExceptions#"
					url = "##"
					parameters = "onClick=""javascript: return AddExceptionsTBL('#Generic_Type#','0','#arguments.NameFieldDesc#','#arguments.SettingDisplayValueInTable#','#arguments.SettingDisplayValueInTableID#');"""
				>
				<font>&nbsp;</font>
			</td>
		<cfelse>
			<tr>
				<td align="left">#arguments.NameFieldDesc#</td>
				<td align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
					<input type="radio" name="#arguments.NameField#" value="1" id="#arguments.NameField#_1" <cfif templateSettings[arguments.NameField] EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<input type="radio" name="#arguments.NameField#" value="0" id="#arguments.NameField#_0" <cfif templateSettings[arguments.NameField] EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				</td>
				<cfif strException_Active[arguments.NameField] EQ 0>
					<cfset LinkExceptions = "Select Exceptions">
				<cfelse>
					<cfset LinkExceptions = "Update Exceptions">
				</cfif>
				<td>
					<CF_smallLink
						title = "#LinkExceptions#"
						url = "##"
						parameters = "onClick=""javascript: return AddExceptions('#Generic_Type#','#SettingIDs[arguments.NameField]#','#arguments.NameFieldDesc#');"""
					>
					<span id="picon_#SettingIDs[arguments.NameField]#"></span>
					<font>&nbsp;</font>
				</td>
		</tr>
		</cfif>
</cfif>
	</cfoutput>
</cffunction>