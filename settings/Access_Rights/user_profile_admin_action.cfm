
<cfparam name="url.complete" default="0">

<cfif url.complete EQ 0>
	
	<cfswitch expression="#lcase(form.mode)#">
		<cfcase value="create">
			<cfset oProfiles = CreateObject("component", "components.settings.profiles.profile").addProfile(form.Profile_Label, form.Profile_Label_Abbr)>
		</cfcase>
	
		<cfcase value="edit">
	 		<cfset useLakebaseForupdatePosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profiles")>
<cfif useLakebaseForupdatePosition>
	<cftry>
		<cfset application.oLakebase.updateRows("profiles",
			{
				"profiles_id" = "eq.#form.profiles_id#"
			},
			{
				"profiles_desc" = "#Profile_Label#",
				"profiles_short_desc" = "#Profile_Label_Abbr#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdatePosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdatePosition>
<cfquery name="updatePosition" datasource="#application.datasource#">
				UPDATE Profiles
				SET Profiles_Desc = '#Profile_Label#', Profiles_Short_Desc = '#Profile_Label_Abbr#'
				WHERE Profiles_ID = '#form.profiles_id#'
			</cfquery>
</cfif>	
		</cfcase>

		<cfcase value="copy">
			<cfset oProfiles = CreateObject("component", "components.settings.profiles.profile").copyProfile(form.Profile_Label, form.Profile_Label_Abbr,form.profiles_id)>
		</cfcase>
	
		<cfcase value="delete">
					
			<cfset oProfiles = CreateObject("component", "components.settings.profiles.profile").deleteProfile(form.profiles_id, form.Sub_Profiles_ID)>

		</cfcase>

	</cfswitch>
	
	<cfinclude template="/settings/CUSTOMER_SETTINGS/Memory_Data/Render_Files.cfm">
	<cflocation url="user_profile_admin_action.cfm?complete=1&mode=#form.mode#">
<cfelse>
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	
	<html>
	<head>
		<title>Success!</title>
	</head>
	
	<body>

	<style>
		.popupheader {
			Color: Navy;
			font-size: 15px;
			font-weight: bold;
		}
	
		.datalabel {
			font-size: 13px;
			font-weight: bold;
		}
	
	</style>	
	
	<script>
		/*Earlier, it was "window.opener". For chrome, new file has been added "\Script\javascript\nonIE.js" for
		"window.showModalDialog". So, we need to use "window.parent" and not "window.opener" for chrome.
		*/
		<cfif findNoCase("Chrome", CGI.HTTP_User_Agent)> 
		if (window.parent)
		{
			window.parent.location.reload();
		}
		<cfelse>
		if (window.opener)
		{
			window.opener.location.reload();
		}
		</cfif>
		window.parent.setReturnValue(1);
		
		<cfif findNoCase("Chrome", CGI.HTTP_User_Agent)> 
		window.parent.parent.document.getElementsByTagName('dialog')[0].close(); 
		/* we can also use this code to close the modal window, instead of the one above */
		//window.parent.parent.document.getElementById('dialog-close').click();
		<cfelse>
		window.close();
		</cfif>
	</script>
	
	</body>
	</html>
</cfif>
	