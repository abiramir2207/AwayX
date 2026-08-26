<!---
	Name: user_profile_management_console.cfm
	Copyright (c) 2006 Blacksmith Applications, Inc.

	Description:
		Basic Menu for the Profile Management Console
	Usage:
		access from the settings control panel by clicking user profiles.
	Modifications:
		CPM 9501: 3/28/2006 - Added logic to display if 'User Profiles' is locked.
--->

<cfparam name="displayLock" default="0" />
<cfparam name="p_displayLock" default = "0">
<html>
<head>
<title>User Profile Management Console</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<!---
	body  {
			background-color:whitesmoke;}
	table {
			width:800px;
			min-width:800px;}
	th 	  {
			font-size: 12px;;
			text-align: left;}
	td {
	font-size: 12px;;
	padding: 5px;}
 --->
<style type="text/css">
#title13 {
 background: url("/Images/gradient.jpg") repeat-y rgb(167, 202, 242);
 width:99%;
 font-size: 1.25em;
 font-weight: bold;
 letter-spacing: 1.7px;
 padding:10px;
 color:white;
}
tr { height: 25px; }
</style>
</head>
<body>
<cfinclude template="/common_files/jQuery.cfm">

<cfparam name="saveToXl" default="no">



<!--- Dev Note: drachala; D28010: Profile Setting Modifications  START
What I did: Added Query to pull who locked the profile console and set Variable LOCKED = 0 or 1 based on profile lock using this variable we will display message who is viewing console currently --->
	<cfset useLakebaseForProfile_lock = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profiles")>
<cfif useLakebaseForProfile_lock>
	<cftry>
		<cfset Profile_lock = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profiles", {
				"deleted" = "eq.0",
				"select" = "is_locked,locked_by_user_id"
			}), "is_locked,locked_by_user_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForProfile_lock = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForProfile_lock>
<cfquery name="Profile_lock" datasource="#application.datasource#">
	 SELECT is_locked, Locked_By_User_ID
	 FROM Profiles
	 WHERE deleted = 0
	</cfquery>
</cfif>

	<cfif profile_lock.is_locked>
	<cfset locked = 1>
	<cfelse>
	<cfset locked = 0>
	</cfif>

<!--- End Dev Note: drachala; D28010: Profile Settings Modifications  --->


<!--- Dev Note: Clay 9501: Retrieving User and Lock Data   --->
<CFSET getProfileLockStatus = CreateObject("component", "components.settings.profiles.profile").getProfileLockStatus()>
<cfif getProfileLockStatus.Is_Locked>
	<cfinvoke component = "components.user.usermanager"   method="getUser"   returnVariable = "qLockingUserData" userId= "#getProfileLockStatus.Locked_By_User_ID#">
    <cfset displayLock = request.AccessStructure.user_id neq getProfileLockStatus.Locked_By_User_ID
                            ? 1
                            : 0>
<cfelseif locked>
	<cfinvoke component = "components.user.usermanager"   method="getUser"   returnVariable = "qProfileLockingUserData" userId= "#Profile_lock.Locked_By_User_ID#">
    <cfset p_displayLock = request.AccessStructure.user_id neq Profile_lock.Locked_By_User_ID
                            ? 1
                            : 0>
</cfif>


<cfset UserSetting = CreateObject("component","components.user.Profile").getUserSettingsPanel(request.AccessStructure.Profiles_ID)>

<!--- Dev Note: DRACHALA; D28010: Profile Setting modifications START--->
<!--- This QUERY is used to display all USER PROFILES when user clicks on link View Selected Profiles --->
	<CFSET getProfilesDataSet = CreateObject("component", "components.settings.profiles.profile").getAllProfiles(UserSettingPanel=UserSetting.Settings_Panel)>
<!--- Dev Note: DRACHALA; D28010: Profile Setting modifications END--->
	<cfoutput>
	<div id="title13">USERS: USER PROFILE MANAGEMENT CONSOLE</div>

<table>
  <tr>
    <td>
		<a href="/settings/Access_Rights/index.cfm?PageTitle=Users: user profiles" target="_blank" onClick="javascript:popupCenterByPercentages(this.href,'manage',90,75);return false;">1. &nbsp; Profile Management </a>
			<cfif displayLock EQ 1>
				<span style="color:rgb(255,0,0);font-weight:bold;">The Management Console is currently being viewed by #qLockingUserData.name_first# #qLockingUserData.name_last#</span>
			</cfif>
	</td>
  </tr>
			<!--- Dev Note: DRACHALA; D28010: Profile Setting modifications START--->
	<tr>
		<td>
			<a href="/settings/Access_Rights/sequence_profiles.cfm?Locked=#locked#&PageTitle=Users: user profiles">2. &nbsp; Sequence Profiles </a>
				<cfif p_displayLock>
					<span style="color:rgb(255,0,0);font-weight:bold;">This Console is currently being viewed by #qProfileLockingUserData.name_first# #qProfileLockingUserData.name_last#</span>
				</cfif>
		</td>
	</tr>


	<tr>
		<td><a href="javascript: <cfif displayLock EQ 0>hide_show();</cfif> ">3. &nbsp; View Selected Profiles</a>
		       <cfif displayLock EQ 1>
					<span style="color:rgb(255,0,0);font-weight:bold;">This Console is currently being viewed by #qLockingUserData.name_first# #qLockingUserData.name_last#</span>
				</cfif>
	    </td>
	</tr>
    <tr id="profiles" style="display: none;height: 100%">
	<td>
		<!--- D35380 User Profiles - View Selected Profiles--->
		<cfinclude template="profiles.cfm" >
	</td>
	</tr>
	    <!--- Dev Note: drachala; D28054: User Profile issues  START
		What I did: Added link 4 to download EXCEL--->
	<tr>
	    <td>
		  	<a href="/settings/Access_Rights/index.cfm?saveToXl=yes&display=none&PageTitle=Users: user profiles" onClick="javascript:NewWindow(this.href,'manage','300','200','No', 'No');return false;">4. &nbsp; Create XL file</a>
    	</td>
	</tr>
	<!--- End Dev Note: drachala; D28054: User Profile issues  --->

	<!--- START: D51644 Type Codes and Profile Settings  8.0 Release --->
	<tr>
		<td><a href="/settings/Access_Rights/select_profiles.cfm" onClick="javascript:NewWindow(this.href,'manage','800','600','yes', 'yes');return false;">5. &nbsp; #application.returned_customer_setting.type_code_label_singular# Access/Approve</a></td>
	</tr>
	<!--- END: D51644 Type Codes and Profile Settings  8.0 Release --->


		  	<!--- Dev Note: DRACHALA; D28010: Profile Setting modifications START--->
  <tr>
    <td><a href="index2.cfm" onClick="window.location.href='index2.cfm'" target="_parent">Return to Settings Control Panel</a></td>
  </tr>
</table>
				</cfoutput>

		  	<!--- Dev Note: DRACHALA; D28010: Profile Setting modifications START--->
	            <script type="text/javascript">
	            function hide_show()
	            {
	                   var SelectedProfiles = document.getElementById('profiles');
	                       if(SelectedProfiles.style.display == 'block')
	                       {
	                          SelectedProfiles.style.display = 'none';
	                           for (i = 0; i < document.profiles.selected_profiles.length; i++)
	                           {
							     document.profiles.selected_profiles[i].checked = false ;
							   }
	                       }
	                       else
	                       {
	                          SelectedProfiles.style.display = 'block';
	                       }
	            }
							function checkAll(field)
							{
							for (i = 0; i < field.length; i++)
							    field[i].checked = true ;
							}

							function uncheckAll(field)
							{
							for (i = 0; i < field.length; i++)
							    field[i].checked = false ;
							}
							function profiles_id(field){
								var profile_id = '';
							     for (i = 0; i < field.length; i++)
							     {
							            if(field[i].checked == true)
							             {
                                         profile_id = profile_id.concat(field[i].value);
                                         profile_id = profile_id.concat(",");
                                         }

                                  }
                               if (profile_id.length > 0){
                               var href = "/settings/Access_Rights/index.cfm?profile_id="+profile_id;
                               NewWindow(href,'manage','1010','650','No', 'Yes');
                               }
                               else{
                                                             alert("Please select atleast one profile");
                                                             return;
                               }
							}
              </script>
		  	<!--- Dev Note: DRACHALA; D28010: Profile Setting modifications --->



</body>
</html>
