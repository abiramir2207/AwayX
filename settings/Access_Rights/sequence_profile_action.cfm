<!----
	Filename:		C:\Work\Code\base\AwayX\settings\Access_Rights\sequence_profile_action.cfm
	Created:		8/9/2011
 	Developer:	    drachala        
	Copyright (c) 2006 Blacksmith Applications, Inc.  
             
	Description:
		       This file used to update Profile sequence in Profile table, which will effect the sequence we display
		       profiles in profile management page.
---->	

<cfoutput>
<cfif url.type EQ "update">
		<cfset i = 1>
			<cfloop list="#form.PROFILE_ID#" index="profile_id">
				<cfset useLakebaseForUpdate_profile_sequence = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profiles")>
<cfif useLakebaseForUpdate_profile_sequence>
	<cftry>
		<cfset application.oLakebase.updateRows("profiles",
			{
				"profiles_id" = "eq.#profile_id#",
				"deleted" = "eq.0"
			},
			{
				"profile_sequence" = "#listgetat(form.New_order, i)#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_profile_sequence = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_profile_sequence>
<cfquery name="Update_profile_sequence" datasource="#application.datasource#">
				UPDATE Profiles
				SET profile_sequence = #listgetat(form.New_order, i)#
				WHERE profiles_id = #profile_id#  AND deleted = 0
				</cfquery>
</cfif>
				<cfset i = i + 1>
			</cfloop>
<cfelse>

</cfif>
</cfoutput>

<cflocation url = "#CGI.HTTP_REFERER#&updated=yes" addtoken="no">
