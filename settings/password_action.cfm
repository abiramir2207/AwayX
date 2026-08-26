<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Update old password...																		 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFQUERY NAME="Change_Paswword" datasource="#application.datasource#">
		Update	_users
		Set		user_password	=	'#hash(trim(Form.New_Password))#'
		Where	User_ID			=	'#request.AccessStructure.User_ID#'
				and
				deleted			=	0
	</CFQUERY>
  
    <!--- 
    	Dev Notes: 23086/Anand Rao/21-May-10
    	User Traffic Changes
    --->
      <cfset UsersIP = CGI.Remote_Addr>    
      <cfquery name="qGetUserCode" datasource="#application.datasource#">
        SELECT User_Code FROM _Users WHERE User_ID = <cfqueryparam value="#Request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
      </cfquery>    
      <cfquery name="AddUserTransPasswordReset" datasource="#application.datasource#">
        INSERT INTO Audit_User_Transactions(Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_By_User_ID)
        VALUES
        (
          'PASSWORD-CHANGE',
          <cfqueryparam value="#qGetUserCode.User_Code#" cfsqltype="CF_SQL_VARCHAR">,
          <cfqueryparam value="#UsersIP#" cfsqltype="CF_SQL_VARCHAR">, 
          <cfqueryparam value="#Request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
        )
      </cfquery>  
  
	<CFSET pagetitle = "Password Change Successful">
	<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
	<BR>
	<H4 ALIGN="center">Your password has been changed successfully.
	<CFIF FORM.FROMHOME EQ 1>
	<BR><BR><BR><BR><BR>
	<B><FONT COLOR="Red">[</FONT><A HREF="##" ONCLICK="javascript:self.close();">close this window</A><FONT COLOR="Red">]</FONT></B>
	</CFIF>


</BODY>
</HTML>