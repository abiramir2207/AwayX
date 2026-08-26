<cfparam name="url.mode" default="create">
<cfparam name="url.id" default="">


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Profile Maintenance</title>
</head>
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
<cfset Profile_Label 		= "">
<cfset Profile_Label_Abbr 	= "">
<cfset allowProfileDelete 	= 0>
<cfset showButton			= 1>

<cfswitch expression="#lcase(url.mode)#">
<cfcase value="create">
	<cfset url.pageCaption 		= "Create a New Profile">
	<cfset url.showDeleteButton = 0>
	<cfset url.profiles_id 		= 0>
	<cfset url.button_text 		= "save">
	<cfset url.button_action_function = "verfiyData()">
	<cfset url.verify_prompt = 	"Press OK to create this new profile.">
</cfcase>

<cfcase value="edit">
	<cfset url.pageCaption 		= "Edit Profile">
	<cfset url.showDeleteButton = 1>
	<cfset url.profiles_id 		= url.id>
	<cfset url.button_text 		= "save">
	<cfset url.button_action_function = "verfiyData()">
	<cfset url.verify_prompt = 	"Press OK to save your changes.">

	<CFSET getProfileInfo = CreateObject("component", "components.settings.profiles.profile").getProfile(url.profiles_id)>
	
	<cfset Profile_Label 	= getProfileInfo.Profiles_Desc>
	<cfset Profile_Label_Abbr = getProfileInfo.Profiles_Short_Desc>	

</cfcase>

<cfcase value="copy">
	<cfset url.profiles_id 		= url.id>
	<cfset getProfileInfo = CreateObject("component", "components.settings.profiles.profile").getProfile(url.profiles_id)>
	<cfset ProfileNameCopy = getProfileInfo.Profiles_Short_Desc>
	<cfset url.pageCaption 		= "Copy Profile #ProfileNameCopy#  To a New Profile">
	<cfset url.showDeleteButton = 0>
	<cfset url.button_text 		= "save">
	<cfset url.button_action_function = "verfiyData()">
	<cfset url.verify_prompt = 	"Press OK to create this new profile.">
</cfcase>

<cfcase value="delete">
      <cfset isActiveUsersAssociateToProfile = CreateObject("component", "components.settings.profiles.profile").isActiveUsersAssociateToProfile(url.id)>
      <cfif isActiveUsersAssociateToProfile eq 0>
		<cfset oProfiles = CreateObject("component", "components.settings.profiles.profile").deleteProfile(url.id, url.id)>
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
			window.close();
		</script>
		<cfabort>
      <cfelse>
	<cfset url.pageCaption 				= "Reassign User To Another Profile">
	<cfset url.showDeleteButton 		= 0>
	<cfset url.profiles_id 				= url.id>
	<cfset url.button_text 				= "reassign & delete">
	<cfset url.button_action_function 	= "deleteProfileFinalPrompt()">
	<cfset url.verify_prompt 			= 	"">
	
	<cfset allowProfileDelete = 1>
	<cfif  url.profiles_id EQ request.AccessStructure.profiles_id>
		<cfset url.button_text 				= "close window">
		<cfset url.button_action_function 	= "window.close()">
		<cfset allowProfileDelete 			= 0>
		<cfset url.pageCaption 				= "You may not delete the profile you are currently utilizing.">
	</cfif>
      </cfif>	
</cfcase>
</cfswitch>


<CFSET getValidProfiles = CreateObject("component", "components.settings.profiles.profile").getAllProfiles()>
<cfif len(trim(url.id)) GT 0 and url.mode neq "copy">
<cfset useLakebaseForgetValidProfiles = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getvalidprofiles")>
<cfif useLakebaseForgetValidProfiles>
	<cftry>
		<cfset getValidProfiles = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getvalidprofiles", {
				"profiles_id" = "neq.#url.id#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetValidProfiles = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetValidProfiles>
<cfquery name="getValidProfiles" dbtype="query">
SELECT * FROM getValidProfiles
WHERE Profiles_ID <> #url.id#
</cfquery>
</cfif>
</cfif>

<cfif getValidProfiles.recordcount  EQ 1>
	<cfset url.showDeleteButton = 0>
</cfif>

<body bgcolor="whitesmoke" text="Black" link="Blue" vlink="Blue" alink="Red" leftmargin="0" topmargin="0">
<script>
	function validateLabel() {
		if(document.all.Profile_Label.value.length != 0) return true;
		return false;
	}
	
	function validateNickname() {
		if(document.all.Profile_Label_Abbr.value.length != 0) return true;
		return false;
	}

	function verfiyData() {
		if(!validateLabel()) {
			alert("Enter a position label before saving.")
			return false;
		}

		if(!validateNickname()) {
			alert("Enter the abbreviated form of the postion label before saving.")
			return false;
		}

		
		if(confirm("<cfoutput>#url.verify_prompt#</cfoutput>")) document.all.MyForm.submit();
	}
	
	function deleteProfile() {
		if(confirm("Press OK to delete this profile.")) {
			<cfoutput>this.location.href = "user_profile_admin.cfm?mode=delete&id=#url.profiles_id#"</cfoutput>
		}
	}

	function deleteProfileFinalPrompt() {
		if(document.all.Sub_Profiles_ID.selectedIndex == 0) {
			alert("Select a replacement profile please.")
		}
		else {		
			if(confirm("Press OK to reassign users and delete this profile.")) {
				MyForm.submit();
			}
		}
	}	
</script>

<BR>

	<div align="center" class="popupheader"><cfoutput>#url.pageCaption#</cfoutput></div>
	<hr width="80%" color="Orange">

	<cfif url.mode EQ "delete">
		<cfif allowProfileDelete EQ 1>
			<div align="center" style="color: red;">
				*select a replacement profile for the users of the profile you are deleting.
			</div>
						
		<cfelse>
		<BR>
			<div align="center" style="color: red;">
				In order to delete this profile<br>
				you must login as a user with a different profile and appropiate access rights. 
			</div>		
		</cfif>	
	</cfif>
	
	
	<form action="user_profile_admin_Action.cfm" method="post" name="MyForm" id="MyForm">
	
	<cfif lcase(url.mode) NEQ "delete">
		<div align="center" class="datalabel">
			<cfoutput>
			
			<table>
				<tr>
					<td align="right"><b>Profile Label :</b></td>
					<td><input type="text" name="Profile_Label" size="45" maxlength="50" value="#Profile_Label#"></td>
				</tr>
				<tr>
					<td align="right"><b>Abbreviation :</b></td>
					<td><input type="text" name="Profile_Label_Abbr" size="4" maxlength="12" value="#Profile_Label_Abbr#"></TD>
				</tr>
			</table>
			
			</cfoutput>
		<cfif url.showDeleteButton EQ 1>
			<br><br> <span style="color: blue; cursor: pointer;" onclick="deleteProfile();"><img src="/images/no_small.gif" title="click here to delete this profiles" border="0">&nbsp;click here to delete this profile</span>
		</cfif>			
		</div>
	<cfelse>
		<div align="center">
		<cfif allowProfileDelete EQ 1>
			<select name="Sub_Profiles_ID">
				<option value="0">Select One...</option>
				<cfoutput>
				<cfloop query="getValidProfiles">
					<option value="#getValidProfiles.Profiles_ID#">#getValidProfiles.Profiles_Desc# - (#getValidProfiles.Profiles_Short_Desc#)</option>
				</cfloop>
				</cfoutput>
			</select>
		</cfif>
		</div>
	</cfif>

	<cfoutput>
		<input type="Hidden" name="mode" value="#url.mode#">
		<input type="Hidden" name="profiles_id" value="#url.profiles_id#">   
	</cfoutput>
	</form>

	<BR>
	<hr width="80%" color="Orange">
	<BR>
	<div align="center" align="center">
	<cfif showButton EQ 1>
	<CF_BUTTON
		BUTTON_NAME		=	""
		BUTTON_CAPTION	=	"#url.button_text#"
		BUTTON_ACTION	=	"#url.button_action_function#;"
		BUTTON_TYPE		=	"javascript_link"
		BUTTON_WIDTH	=	""
		BUTTON_COLOR	=	"Navy"
		BUTTON_TIP		=	""
		FONT_COLOR		=	"White"
		FONT_SIZE		=	"12"
		FONT_WEIGHT		=	"bold">
	<cfelse>
	<CF_BUTTON
		BUTTON_NAME		=	""
		BUTTON_CAPTION	=	"#url.button_text#"
		BUTTON_ACTION	=	"#url.button_action_function#;"
		BUTTON_TYPE		=	"javascript_link"
		BUTTON_WIDTH	=	""
		BUTTON_COLOR	=	"Navy"
		BUTTON_TIP		=	""
		FONT_COLOR		=	"White"
		FONT_SIZE		=	"12"
		FONT_WEIGHT		=	"bold">
	</cfif>
	</div>
</body>
</html>
