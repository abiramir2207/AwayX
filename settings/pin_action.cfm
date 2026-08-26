<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Update old pin...																		 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFQUERY NAME="Change_Pin" datasource="#application.datasource#">
		Update	_users
		Set		user_pin		=	<cfqueryparam value="#hash(trim(Form.NewPin))#" cfsqltype="cf_sql_varchar"/>,  
				pin_update_date	=	getdate()
		Where	user_id			=	<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_idstamp"/>
		and		deleted			=	0
	</CFQUERY>
	
	<CFSET pagetitle = "Pin Change Successful">
	<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
	<BR>
	<H4 ALIGN="center">Your pin has been changed successfully.
	
	<BR><BR><BR><BR><BR>
	<B><FONT COLOR="Red">[</FONT><A HREF="##" ONCLICK="javascript:self.close();">close this window</A><FONT COLOR="Red">]</FONT></B>

</BODY>
</HTML>