<!----
	Filename:	C:\Work\Code\base\AwayX\views\settings\list_users.cfm
	Created:	12/19/2011
 	Developer:	drachala
	Copyright (c) 2006 Blacksmith Applications, Inc.

	Description:
		Redone LIST USERS page,
		removed coldbox code, eixsting Ajax as we have lot browser compatability issues.

	LABEL NUMBER: D29591:List User page not sorting
---->
<!DOCTYPE HTML>
<html>
<head>
	<cfsavecontent variable="head_content">
		<style>
			#header{
				font-weight: bold;
				}
				#border{
					border:none;
					color: blue;
					font-weight: bold;
					background-color: white;
					width:65px;
				}
				#barcket{
					font-weight: bold;
					color: red;
				}
				td > input[type=text], td > select, td > textarea {
					margin-top:3px;
				}
		</style>

		<cf_include files="/script/tTip.js, /styles/tTip.css">
	</cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>
<body>
<cfparam name="form.type" default="0">
<cfparam name="form.user_search" default="">
<cfparam name="form.userPosition" default="">
<cfparam name="form.user_position_id" default="">
<cfparam name="form.profile_id" default="">
<cfparam name="form.auth_sequence" default="">
<cfparam name="form.search" default="">
<cfparam name="form.upateAccessRights" default="0">
<cfparam name="url.upateAccessRights" default="#form.upateAccessRights#">

<cfset form.upateAccessRights = url.upateAccessRights>

<!---	Queries used to populate User Position, profile, Authority sequence drop dowms START  --->
	<cfset users = CreateObject("component", "components.user.ajaxusermanager")/>
	<cfset positions_list = users.populateUsrPosSelect()>
	<cfset Profiles_list = users.populateProfileSelect()>
	<cfset Authority = CreateObject("component", "components.user.authoritySequenceManager") />
	<cfset AuthSequence = Authority.getAll()>
<!---	Queries used to populate User Position, profile, Authority sequence drop dowms END  --->
<!---	Assign form variables to form variable when form submit which we use to populate form fields START  --->
<cfif form.search EQ 0>
	<cfset form.type = "0">
	<cfset form.user_search= "">
	<cfset form.userPosition= "">
	<cfset form.user_position_id= "">
	<cfset form.profile_id= "">
	<cfset form.auth_sequence= "">
	<cfset form.search = "">
</cfif>
<!---	Assign form variables to form variable when form submit which we use to populate form fields END  --->
<cfinclude template="/settings/Advanced_Budget/actionFormat.cfm">


<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%">
<TR>
	<TD ALIGN="left" bgcolor="#A7CAF2" WIDTH="100%" HEIGHT="25" style="background-image: url(/Images/gradient.jpg); background-repeat:no-repeat;">
		<SPAN STYLE="color:white; font-size:14px; font-weight: bold; padding-left:5px;">USERS: LIST USERS</SPAN>
	</TD>
</TR>
</TABLE>
<cfoutput>
<div style="margin:6px 0">
	<a href="/views/settings/print_users.cfm">#application.util.string.linkFormat("create user report")#</a>
</div>
<fieldset style="padding:6px; width:99%; border:1px solid Blue;">
	<form name="users" action="/views/settings/list_users.cfm" method="post" id="userForm">
    <legend style="font: bold 14px sans-serif; color: Red;">Search Form</legend>
	<table width="100%" cellpadding="0" cellspacing="2">
			<tr id="header">
				<td>First Name/Last Name</td>
				<td>User Type</td>
				<td>User Position</td>
				<td>Profile</td>
				<td>Authority Sequence</td>
			</tr>
			<tr>
				<td valign="top"><input size="25" name="user_search" value="#form.user_search#" onkeyup="searchKeyPress(event);"></td>
				<td valign="top">
					<input type="radio" name="type" value="0" <cfif (form.type EQ 0) OR (form.type EQ "")>checked</cfif>>Active
					<br>
	    			<input type="radio" name="type" value="1" <cfif form.type EQ 1>checked</cfif>  >In Active
				</td>
				<td valign="top">
					<select name="user_position_id" id="user_position_id">
		 				<option value="0">**ALL** Positions</option>
		   				<cfloop query="positions_list">
						<option value="#trim(User_Positions_ID)#" <cfif form.user_position_id EQ #trim(User_Positions_ID)#>SELECTED</cfif>>#trim(Position_Label)#</option>
		   				</cfloop>
					</select><br>
					<input type="radio" name="userPosition" value="P" <cfif (form.userPosition EQ "P") OR (form.userPosition EQ "")>checked</cfif>>Pri
					<input type="radio" name="userPosition" value="S" <cfif form.userPosition EQ "S">checked</cfif>  >Sec
				</td>
				<td valign="top">
					<select name="profile_id">
		  				<option value="0">**ALL** Profiles</option>
						<cfloop query="Profiles_list">
			 			<option value="#trim(profiles_id)#" <cfif form.profile_id EQ #trim(profiles_id)#>SELECTED</cfif>>#Profiles_Desc#</option>
						</cfloop>
		 			</select>
				</td>
				<td valign="top">
					<select name="auth_sequence">
						<option value="0">**ALL**</option>
						<cfloop query="AuthSequence">
						<option value="#trim(Authority_Sequence_ID)#" <cfif form.auth_sequence EQ #trim(Authority_Sequence_ID)#>SELECTED</cfif>>#Authority_Sequence_Name#</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td colspan="5">
					<input type="hidden" name="search" value="">
					<input type="hidden" name="upateAccessRights" value="#form.upateAccessRights#">
<table align="left" cellpadding="7">
	<tr>
		<td>
				<CF_button
						button_name		=	""
						button_caption	=	"search"
						button_action	=	"search_form()"
						button_type		=	"javascript_link"
						button_width	=	"250"
						button_color	=	"Navy"
						button_tip		=	"Save and Continue"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
</td><td>
				<CF_button
						button_name		=	""
						button_caption	=	"reset"
						button_action	=	"reset_form()"
						button_type		=	"javascript_link"
						button_width	=	"250"
						button_color	=	"Navy"
						button_tip		=	"Save and Continue"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>

		</td>
	</tr>
</table>


				</td>
			</tr>
	</table>
	</form>
</fieldset>
</cfoutput>

<script>
	function search_form(){
		document.users.search.value = 1;
		document.users.submit();
	}
//this function excute onkey up in name text box
	 function searchKeyPress(e){
        if (window.event) { e = window.event; }
        if (e.keyCode == 13)
           {
              search_form();
            }
    }
	function reset_form(){
		document.users.search.value = 0;
		document.users.submit();
	}
</script>
<!--- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --->
<!--- /////////////////////////////////////////////////////////////////////DispLay Results////////////////////////////////////////////////////////////////////////////////////// --->
<!--- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --->
<cfif len(form.search)><!--- D30310 : Event errors in list users --->
	<cfset UserSetting = CreateObject("component","components.user.Profile").getUserSettingsPanel(request.AccessStructure.Profiles_ID)>

			<cfset ListUsers = users.getusersList(	searchstring = #form.user_search#,
																	type = #form.type#,
																	position = #form.userPosition#,
																	position_id = #form.user_position_id#,
																	profile_id = #form.profile_id#,
																	authoritySequence = #form.auth_sequence#,
																	UserSettingPanel = #UserSetting.Settings_Panel#)>

			<cfsavecontent variable="vars.htmlHead">
			<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
			<style>
				.action { font-weight:bold; margin:0 3px 0 3px; }
			</style>
			</cfsavecontent>
			<cfhtmlhead text="#vars.htmlHead#">

			<cfscript>
			  vars = StructNew();
			</cfscript>

			<table id="Users" class="datagrid" border="0" style="width:100%;">
				<thead>
				<tr>
					<th>Name</th>
					<th>Profile</th>
					<th>Position</th>
					<th>Last <br>Successful Login</th>
					<th>Last <br>Password Change</th>
					<th>Address</th>
					<th>Phone/Fax</th>
					<th>Authority Sequence</th>
					<th>More <br> Information</th>
				</tr>
				</thead>
				<tbody>
				<cfoutput query="ListUsers">
				<tr>
					<td style="width:100px;">
						<a href="/settings/Access_Rights/users_create_form.cfm?activateuser=0&User_ID=#user_id#&upateAccessRights=#url.upateAccessRights#">
							#fullname#
						</a>
							<cfset count = Find("UserName", fullname) - 7>
							<cfset name  = (count gt 0 ? left(fullname, count) : fullname)>
					</td>
				 	<td>#profiles_desc#</td>
				 	<td>#position_label#</td>
					<td>
						<cfset login_right_count = len(lastlogindate) - 10>
						#dateFormat(lastlogindate, "yyyy/mm/dd")#
					</td>
				 	<td>
					 	<cfset password_right_count = len(password_update_date) - 10>
					 	#dateFormat(password_update_date, "yyyy/mm/dd")#
				 	</td>
				 	<td>#address#</td>
				 	<td  nowrap>#phonenum#</td>
				 	<td>#authority_sequence_name#</td>
				 	<td  nowrap  style="width:125px;">
						<cfif Application.oApplicationAppSettingsManager.getApplicationAppSettings().getSingleSignOnOverrideUserId() OR (NOT (Application.oApplicationAppSettingsManager.getApplicationAppSettings().getLDAP_SSO_Enabled() or len(LDAP_User_Name)))>
							<a href="/settings/Access_Rights/send_password.cfm?User_ID=#user_id#" target="mainwindow">#actiontext("Reset Password")#</a><br>
						<cfelse>
							<span onmouseout="popUpTip(event,'sso_alert');" onmouseover="popUpTip(event,'sso_alert');" style="cursor:pointer;cursor:hand;">#actiontext("Reset Password")#</span><br>
							<div id="sso_alert" style="color: blue;margin-top:-295px;margin-right:-35px; border:solid;border-width:2px;font-size:11px;"  class="tip">
								<!---The password cannot be reset from the application for users with Single Sign On credentials.--->
								Reset password not available for users with Single Sign On credentials
							</div>
						</cfif>
						<cfif #form.type# eq 0>
							<!--- D36796 :: --->
							<cfset name = #Replace(name, "'", "", "ALL")#>
							<a href="javascript:onclick= verifyDelete('#name#', '#user_id#');">
								#actiontext("InActivate User")#
							</a>
						<cfelseif #form.type# eq 1>
							<a href="/settings/Access_Rights/users_create_form.cfm?activateuser=1&User_ID=#user_id#">
								#actiontext("Activate User")#
							</a>
						</cfif>
							<br>
							<a href="/settings/Access_Rights/users_create_form.cfm?copyuser=1&User_ID=#user_id#" target="mainwindow">#actiontext("Copy User")#</a><br>
							<a href="javascript:onclick= verifyUnlock('#user_id#');">#actiontext("Unlock Records")#</a>
					</td>
				</tr>
				</cfoutput>
				</tbody>
			</table>
<form name="DeleteUserForm" action="/settings/Access_Rights/users_delete.cfm" method="post">
	<input type="hidden" name="User_ID" />
</form>

<form name="UnlockUserForm" action="/settings/Access_Rights/unlock_user_records.cfm" method="post">
	<input type="hidden" name="User_ID" />
</form>

<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">
<cf_include files="/Script/javascript/jquery.dataTables-api.js">
<script>
	var grid = $('#Users').dataTable({
														"bPaginate": true
														,"bSortClasses": false
														,"bScrollCollapse": true
													    , "iDisplayLength": 50
														,"sDom": 'Rlrtip'
														,"sScrollXInner": "100%"
														,"aaSorting": [[ 0, "asc" ]]
														,"aoColumns": [	 {"bSortable":true}
																					,{"bSortable":true}
																					,{"bSortable":true}
																					,{"bSortable":true}
																					,{"bSortable":true}
																					,{"bSortable":true}
																					,{"bSortable":true}
																					,{"bSortable":true}
																					,{"bSortable":false}]
		})

$('table#Users tr').hover (
	function() { $(this).addClass("over"); },
	function() { $(this).removeClass("over"); }
);
function verifyUnlock(user_id){
	if(confirm("Click OK to unlock all records.")){
		document.all.UnlockUserForm.User_ID.value = user_id;
		document.UnlockUserForm.submit();
	}
	//return false;
}
function verifyDelete(user_name, user_id){
	if(confirm("If " + user_name + " currently has programs, deductions or billbacks, you will have an opportunity to reassign them. Otherwise the user will be immediately deactivated.")){
		document.all.DeleteUserForm.User_ID.value = user_id;
		document.DeleteUserForm.submit();
	}
}
</script>
</cfif>
</body>
</html>