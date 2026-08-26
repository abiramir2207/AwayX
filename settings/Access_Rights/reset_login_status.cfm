<CFSET PageTitle="USERS: reset user loging status">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<BLOCKQUOTE><BLOCKQUOTE>


<CFPARAM NAME="URL.ID" DEFAULT="">
<cfset UsersIP = CGI.Remote_Addr>

<!--- Reset the login status of this user --->
<CFQUERY NAME="Reset_Login_Status" datasource="#application.datasource#">
UPDATE	_Users
SET 	Login_Status = 0
WHERE	User_ID	=	'#URL.ID#'
</CFQUERY>

<!--- 
	Dev Notes: 23086/Anand Rao/24-May-10
	User Traffic Changes
--->
      <cfquery name="qGetUserCode" datasource="#application.datasource#">
        SELECT User_Code FROM _Users WHERE User_ID = <cfqueryparam value="#URL.ID#" cfsqltype="CF_SQL_VARCHAR">
      </cfquery>
      <cfquery name="AddUserTransLoginReset" datasource="#application.datasource#">
        INSERT INTO Audit_User_Transactions(Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_By_User_ID)
        VALUES
        (
          'LOGOFF',
          <cfqueryparam value="#qGetUserCode.User_Code#" cfsqltype="CF_SQL_VARCHAR">,
          <cfqueryparam value="#UsersIP#" cfsqltype="CF_SQL_VARCHAR">, 
          <cfqueryparam value="#URL.ID#" cfsqltype="CF_SQL_VARCHAR">
        )
      </cfquery>

<CENTER><BR><BR><BR><BR><B>The user login status has been reset!<BR><BR>Please wait while we take you back</B></CENTER>


<script language="JavaScript">
function seeya()
{
	history.back();
}
setTimeout('history.back()',2000); 
</script>

</BLOCKQUOTE></BLOCKQUOTE>
