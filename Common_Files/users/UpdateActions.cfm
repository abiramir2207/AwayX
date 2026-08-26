<cfset UsersIP = CGI.Remote_Addr>
<CFSWITCH EXPRESSION="#Form.Document_ID#">
	
	<CFCASE VALUE="UserGeneralInfo">
		<CFQUERY NAME="UpdateUserInfo" datasource="#application.datasource#" DBTYPE="ODBC">
			UPDATE _Users
			SET
				Name_First			=	'#Form.User_Name_First#',
				Name_Last			=	'#Form.User_Name_Last#',
				Title				=	'#Form.User_Title#',
				Work_Address_1		=	'#Form.User_Work_Address_1#',
				Work_Address_2		=	'#Form.User_Work_Address_2#',
				Work_City			=	'#Form.User_Work_City#',
				Work_State			=	'#Form.User_Work_State#',
				Work_Zip			=	'#Form.User_Work_Zip#',
				Work_Phone			=	'(#Form.User_Work_Phone_1#)#Form.User_Work_Phone_2##Form.User_Work_Phone_3#',
				Company_Main_ID		=	'#Form.Company_Main_ID#',
				user_email			=	'#FORM.emailaddress#',
				User_Rights_ID		=	'#FORM.User_Rights_ID#'
			WHERE
				User_ID 			= 	'#Form.User_ID#'
		</CFQUERY>
		<CFSET URL = "user_login_info.cfm?User_ID=#Form.User_ID#">
	</CFCASE>
	
	<CFCASE VALUE="DeleteUserForm">
		<CFQUERY NAME="UpdateUserInfo" datasource="#application.datasource#" DBTYPE="ODBC">
			UPDATE _Users
			SET
				Deleted = 1
			WHERE
				User_ID 			= 	'#Form.User_ID#'
		</CFQUERY>		
    <!--- 
	  Dev Notes: 23086/Anand Rao/21-May-10
	  User Traffic Changes
    --->
    <cfquery name="AddUserTransInActivate" datasource="#application.datasource#">
      INSERT INTO Audit_User_Transactions(Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_By_User_ID)
      VALUES
      (
        'INACTIVATE-USER',
        <cfqueryparam value="#FORM.User_Code#" cfsqltype="CF_SQL_VARCHAR">,
        <cfqueryparam value="#UsersIP#" cfsqltype="CF_SQL_VARCHAR">, 
        <cfqueryparam value="#Request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
      )
      </cfquery>
    
		<CFSET URL = "user_search.cfm">
	</CFCASE>

	<CFCASE VALUE="NewLoginInfo">
		<CFQUERY NAME="UpdateLoginInfo" datasource="#application.datasource#" DBTYPE="ODBC">
			UPDATE _Users
			SET
				User_Code = '#Form.Username#',
				User_Password = '#hash(Form.Password)#'
			WHERE
				User_ID 			= 	'#Form.User_ID#'
		</CFQUERY>	
    <!--- 
	  Dev Notes: 23086/Anand Rao/21-May-10
	  User Traffic Changes
    --->
    <cfquery name="AddUserTransCreateUser" datasource="#application.datasource#">
      INSERT INTO Audit_User_Transactions(Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_By_User_ID)
      VALUES
      (
        'UPDATE-USER',
        <cfqueryparam value="#FORM.User_Code#" cfsqltype="CF_SQL_VARCHAR">,
        <cfqueryparam value="#UsersIP#" cfsqltype="CF_SQL_VARCHAR">, 
        <cfqueryparam value="#Request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
      )
      </cfquery>	
		<CFLOCATION URL="user_security_info.cfm?User_ID=#Form.User_ID#">
	</CFCASE>

	<CFCASE VALUE="AccessLevel">
		<cfset useLakebaseForUpdateAccessLevel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForUpdateAccessLevel>
	<cftry>
		<cfset application.oLakebase.updateRows("_users",
			{
				"user_id" = "eq.#Form.User_ID#"
			},
			{
				"access_level" = "#Form.Access_Level#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateAccessLevel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateAccessLevel>
<CFQUERY NAME="UpdateAccessLevel" datasource="#application.datasource#" DBTYPE="ODBC">
			UPDATE _Users
			SET
				Access_Level = '#Form.Access_Level#'
			WHERE
				User_ID 			= 	'#Form.User_ID#'
		</CFQUERY>
</cfif>		
    <!--- 
	  Dev Notes: 23086/Anand Rao/21-May-10
	  User Traffic Changes
    --->
    <cfquery name="AddUserTransAccessLevel" datasource="#application.datasource#">
      INSERT INTO Audit_User_Transactions(Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_By_User_ID)
      VALUES
      (
        'ACCESS-LEVEL-CHANGE',
        (SELECT User_Code FROM _Users WHERE User_Code = <cfqueryparam value="#FORM.USER_ID#" cfsqltype="CF_SQL_VARCHAR">),
        <cfqueryparam value="#UsersIP#" cfsqltype="CF_SQL_VARCHAR">, 
        <cfqueryparam value="#Request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
      )
      </cfquery>	    
		<CFSET URL="user_summary.cfm?User_ID=#Form.User_ID#">
	</CFCASE>	
</CFSWITCH>

<CFIF isdefined("Form.RTS")>
<CFSET URL = "user_summary.cfm?User_ID=#Form.User_ID#">
</CFIF>
<CFLOCATION URL="#URL#">