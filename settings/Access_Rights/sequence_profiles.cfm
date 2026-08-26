<!---
	Copyright (c)2011 Blacksmith Applications, Inc.
	Filename:		C:\Work\Code\base\AwayX\settings\Access_Rights\sequence_profiles.cfm
	Created:		8/5/2011
	Developer:		drachala
	Description:	Sequence Profiles --- This will allow the user to order the profiles from left to right on the profile page.
--->

<!--- get all profiles START --->
<CFSET getProfiles = CreateObject("component", "components.settings.profiles.profile").getAllProfiles()>
<!--- get all profiles END --->

<html>
<head>
<title>Sequence Profile Management Console</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
body  {
        background-color:whitesmoke;
	  }
table {
        width:800px;
        min-width:800px;
	  }
th    {
        font-size: 12px;;
        text-align: left;
	  }
td {
font-size: 12px;;
padding: 5px;}
</style>

</head>
<body>
	
<cfoutput>

	<cfset lock = 1>
	<cfset useLakebaseForget_profile_lock_info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profiles")>
<cfif useLakebaseForget_profile_lock_info>
	<cftry>
		<cfset get_profile_lock_info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profiles", {
				"deleted" = "eq.0",
				"is_locked" = "eq.1",
				"select" = "locked_by_user_id"
			}), "locked_by_user_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_profile_lock_info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_profile_lock_info>
<cfquery name="get_profile_lock_info" datasource="#application.datasource#">
	SELECT Distinct Locked_By_user_ID
	FROM Profiles
	WHERE deleted = 0 and Is_Locked = 1
	</cfquery>
</cfif>
	<cfif get_profile_lock_info.RecordCount>
	    <cfinvoke component = "components.user.usermanager"   method="getUser"   returnVariable = "qLockingUserData" userId= "#get_profile_lock_info.Locked_By_User_ID#">
	    <cfset lockingUserName = '#qLockingUserData.name_first# #qLockingUserData.name_last#'>
    </cfif>



<!--- if Profile consel is locked by you and failed to unlock it UPDATE statement will unlock the profile Console --->
	    	<cfif get_profile_lock_info.Locked_By_User_ID EQ '#trim(request.AccessStructure.user_id)#'>
	    		    <cfquery name="Update_profile_lock" datasource="#application.datasource#">
	    			UPDATE profiles
	    			SET Is_locked = 0, Locked_By_User_ID =  null, Lock_Date = null
	    			WHERE deleted = 0
	    			</cfquery>
	    	</cfif>




<cfif isdefined("url.lock") AND #url.lock# EQ 1>
    <cfquery name="Update_profile_lock" datasource="#application.datasource#">
	UPDATE profiles
	SET Is_locked = 1, Locked_By_User_ID ='#trim(request.AccessStructure.user_id)#', Lock_Date = GetDate()
	WHERE deleted = 0
	</cfquery>
	<cfset lock = 0>
<cfelseif isdefined("url.lock") AND #url.lock# EQ 0>
    <cfquery name="Update_profile_lock" datasource="#application.datasource#">
	UPDATE profiles
	SET Is_locked = 0, Locked_By_User_ID =  null, Lock_Date = null
	WHERE deleted = 0
	</cfquery>
	<cfset lock = 1>
	<cflocation url="sequence_profiles.cfm">
</cfif>

<cfif get_profile_lock_info.Locked_By_User_ID EQ '#trim(request.AccessStructure.user_id)#'><cfset lock = 0></cfif>
	
<cfif lock EQ 0>
	<a href="sequence_profiles.cfm?lock=#lock#">
	    <IMG SRC="/images/edit_Mode.gif"  border="0"  ALIGN="absmiddle" TITLE="Edit Mode">
		<br>    
		<span style="color:red;">[</span>Click for Read Only<span style="color:red;">]</span>
	</a>
<cfelse>
	<a href="../user_profile_management_console.cfm">Return to User Profile Management Console</a><br><br>
	<cfif get_profile_lock_info.RecordCount AND get_profile_lock_info.Locked_By_User_ID NEQ '#trim(request.AccessStructure.user_id)#'>
		<IMG SRC="/images/ReadOnly_Mode.gif" border="0" TITLE="This Management Console is currently being viewed by: #Ucase(lockingUserName)#"><br>
		<span style="color:red; font-size:12px; font-weight: bold;">This Console is currently being viewed by: #Ucase(lockingUserName)#</span>
	<cfelse>
		<a href="sequence_profiles.cfm?lock=#lock#"><IMG SRC="/images/ReadOnly_Mode.gif" border="0" TITLE="Read-Only Mode">
		<br />
		<span style="color:red; font-size:12px; font-weight: bold;">[</span>Click to Edit<span style="color:red;">]</span></a>
	</cfif>
</cfif>


<div align="center">
<span style="color: red"><b>*</b></span><b>Sequence 1 means the profile will appear in the first column, the left most column in profile settings page.</b>
<cfif isdefined("url.updated")><br><br><span style="color: green;"><strong>Successfully updated new sequence for profiles.</strong></span><br></cfif>
</div>

	<div align="center" <cfif lock>style="display: none;"</cfif>>
		        	                                       <CF_BUTTON
		        	                                        BUTTON_NAME     =   ""
		        	                                        BUTTON_CAPTION  =   "Save"
		        	                                        BUTTON_ACTION   =   "javascript:document.sequence.submit();"
		        	                                        BUTTON_TYPE     =   "link"
		        	                                        BUTTON_WIDTH    =   "100"
		        	                                        BUTTON_COLOR    =   "Navy"
		        	                                        BUTTON_TIP      =   ""
		        	                                        FONT_COLOR      =   "White"
		        	                                        FONT_SIZE       =   "12"
		        	                                        FONT_WEIGHT     =   "bold">
   </div>
	<form name="sequence" action="sequence_profile_action.cfm?type=update" method="post" id="sequence">
	        <table style="display: block;" align="center" class="Maintable" id="seqdis">
	        <tr>
	        <TH ALIGN="left" colspan="2" BGCOLOR="Navy" BACKGROUND="/Images/gradient.jpg" WIDTH="100%" HEIGHT="25">
	        <SPAN STYLE="color:white; font-size:13px; font-weight: bold;">SEQUENCE PROFILES</SPAN>
	        </TH>
	        </tr>

	        <tr>
	        <td style="font-size:14px;font-weight: bold;">Order</td><td style="font-size:14px;font-weight: bold;">Profiles</td>
	        </tr>

	        <cfset i = 1>
	        <cfloop query="getProfiles">
	        <tr>
	            <td>#i#
	        <!--- <cfif #getProfiles.profile_sequence# EQ 0>
		        <cfset id = i+1>
		    <cfelse>
		    	#getProfiles.profile_sequence#
		    	<cfset id = #getProfiles.profile_sequence#+1>
			</cfif> --->
	               
	        <span <cfif lock>style="display:none;"</cfif>>
	        	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	        	------->
	        	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	        							<input type="text" name="new_order" value="#getProfiles.profile_sequence#"style="width:50px;">
	        		        	        <input type="hidden" name="Profile_id" value="#getProfiles.profiles_id#">
	        		        	        <input type="hidden" name="profile_settings_id" value="#getProfiles.profiles_settings_id#">
			</span>
	        	</td>
	        <td>
	        #getProfiles.Profiles_Desc#
	        </td>
	        </tr>
	        <cfset i = i+1>
	        </cfloop>
	        </table>
	</form>
	        	<div align="center" <cfif lock>style="display: none;"</cfif>>
	        		        	                                       <CF_BUTTON
	        		        	                                        BUTTON_NAME     =   ""
	        		        	                                        BUTTON_CAPTION  =   "Save"
	        		        	                                        BUTTON_ACTION   =   "javascript:document.sequence.submit();"
	        		        	                                        BUTTON_TYPE     =   "link"
	        		        	                                        BUTTON_WIDTH    =   "100"
	        		        	                                        BUTTON_COLOR    =   "Navy"
	        		        	                                        BUTTON_TIP      =   ""
	        		        	                                        FONT_COLOR      =   "White"
	        		        	                                        FONT_SIZE       =   "12"
	        		        	                                        FONT_WEIGHT     =   "bold">
	           </div>
</cfoutput>

</body>
</html>














