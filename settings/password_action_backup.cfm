
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the password for this user																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Password" datasource="#application.datasource#">
	Select	User_Password
	From	_Users
	Where	User_ID		=	'#request.AccessStructure.User_ID#'
			and
			deleted		=	0
</CFQUERY>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- If the entered old password matches what's in the DB as of now, make the changes				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF Get_Password.User_Password EQ hash(Form.Old_Password)>
	<CFQUERY NAME="Change_Paswword" datasource="#application.datasource#">
		Update	_users
		Set		user_password	=	'#hash(Form.New_Password)#'
		Where	User_ID			=	'#request.AccessStructure.User_ID#'
				and
				deleted			=	0
	</CFQUERY>

	<CFSET pagetitle = "Password Change Successful">
	<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
	<BR>
	<H4 ALIGN="center">Your password has been changed successfully.<BR>
	<CFABORT>

<CFELSE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Otherwise, inform the user that the entered old pass does not match what is there				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFSET pagetitle = "Password Change Error">
	<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
	<BR>
	<H4>Your Old Password does not match the current password used to access the application.<BR>
	<A HREF="javascript:history.back();">Please try again</A></H4>
	<CFABORT>
</CFIF>




</BODY>
</HTML>