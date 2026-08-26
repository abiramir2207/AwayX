<CFPARAM NAME="cookie.User_Info" DEFAULT="">



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get user data --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="GetUserData" datasource="#application.datasource#" DBTYPE="ODBC">
Select
		_Users.User_ID,
		_Users.User_Code,
		_Users.Name_First,
		_Users.Name_Last,
		_Users.Profiles_ID,
		_Users.Company_Main_ID,
		_Users.Access_Level,
		_Users.User_Email,
		_Users.User_Rights_ID,
		Company_Main.Company_Name,
		Company_Main.Company_Main_ID,
		Company_Main.Company_Type_ID,
		Company_Main.National_Affiliation_Code,
		Company_Main.Company_logo
		
	From
		_Users,
		Company_Main
	Where	User_Code						=	'#Form.User_Code#'
			and
			User_Password					=	'#hash(Form.User_Password)#'
			and
			_Users.Company_Main_ID			=	Company_Main.Company_Main_ID
			and
			_Users.deleted					=	0
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- If the user is not found in the database go back to the login screen							 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF GetUserData.RecordCount EQ 0>
	<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">window.location.href = '/index.cfm';</SCRIPT>
	<CFABORT>
</CFIF>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- If the user is found in the database but is already logged someplace else...					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!-----<CFQUERY NAME="Get_Login_Status" datasource="#application.datasource#">
	Select		Login_Status
	From		_Users
	Where		User_ID	=	'#GetUserData.User_ID#'
</CFQUERY>

<CFIF Get_Login_Status.Login_Status EQ 1>

	<CFLOCATION URL="/try_again.cfm?id=#GetUserData.User_ID#">

<!--- 
	<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">window.location.href = '/try_again.cfm?id=#GetUserData.User_ID#';</SCRIPT>
 --->

	<CFABORT>
</CFIF>------->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!-----  Check login against Session_Tracker ------->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFSET thisSessionID=Session.SessionID>
<cfset useLakebaseForGet_Session_Status = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("session_tracker")>
<cfif useLakebaseForGet_Session_Status>
	<cftry>
		<cfset Get_Session_Status = application.oLakebase.toQuery(
			application.oLakebase.selectRows("session_tracker", {
				"session_user_id" = "eq.#GetUserData.User_ID#",
				"select" = "session_id"
			}), "session_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Session_Status = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Session_Status>
<CFQUERY NAME="Get_Session_Status" datasource="#application.datasource#">
	Select		Session_ID
	From		Session_Tracker
	Where		Session_User_ID	= '#GetUserData.User_ID#'
</CFQUERY>
</cfif>


<CFIF Get_Session_Status.recordCount GT 0>
	<CFIF Get_Session_Status.Session_ID EQ "">
		<cfset useLakebaseForUpdate_Session_Status = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("session_tracker")>
<cfif useLakebaseForUpdate_Session_Status>
	<cftry>
		<cfset application.oLakebase.updateRows("session_tracker",
			{
				"session_user_id" = "eq.#GetUserData.User_ID#"
			},
			{
				"session_id" = "#thisSessionID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_Session_Status = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_Session_Status>
<CFQUERY NAME="Update_Session_Status" datasource="#application.datasource#">
			UPDATE	Session_Tracker
			SET		Session_ID = '#thisSessionID#'
			WHERE	Session_User_ID = '#GetUserData.User_ID#'
		</CFQUERY>
</cfif>
	<CFELSE>
		<CFIF Get_Session_Status.Session_ID NEQ thisSessionID>			
			<CFLOCATION URL="try_again.cfm?id=#GetUserData.User_ID#">
			<CFABORT>
		</CFIF>
	</CFIF>
<CFELSE>
	<CFQUERY NAME="Insert_Session_Status" datasource="#application.datasource#">
		INSERT	INTO
		Session_Tracker(Session_User_ID,Session_ID)
		VALUES('#GetUserData.User_ID#','#thisSessionID#')
	</CFQUERY>
</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!-----  End Check login against Session_Tracker ------->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->





<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- If the user is found in the database got forward with the process								 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSWITCH EXPRESSION="#GetUserData.Company_Type_ID#">
	<CFCASE VALUE="1"><CFSET User_Directory = "/Manufacturers"></CFCASE>
	<CFCASE VALUE="2"><CFSET User_Directory = "/Distributors"></CFCASE>	
	<CFCASE VALUE="3"><CFSET User_Directory = "/Operators"></CFCASE>
</CFSWITCH>

<!--- Create a structure here to hold the variables. --->
<CFSET AccessStructure=StructNew()>
<!--- Build structure elements with personal information --->
<CFSET Variables.Temp = StructInsert(AccessStructure, 'User_ID', 					GetUserData.User_ID, True)>
<CFSET Variables.Temp = StructInsert(AccessStructure, 'User_Code', 					GetUserData.User_Code, True)>
<CFSET Variables.Temp = StructInsert(AccessStructure, 'Name_First', 				GetUserData.Name_First, True)>
<CFSET Variables.Temp = StructInsert(AccessStructure, 'Name_Last', 					GetUserData.Name_Last, True)>
<CFSET Variables.Temp = StructInsert(AccessStructure, 'Profiles_ID', 				GetUserData.Profiles_ID, True)>
<CFSET Variables.Temp = StructInsert(AccessStructure, 'National_Affiliation_Code', 	GetUserData.National_Affiliation_Code, True)>
<CFSET Variables.Temp = StructInsert(AccessStructure, 'Company_Name', 				GetUserData.Company_Name, True)>
<CFSET Variables.Temp = StructInsert(AccessStructure, 'Company_Main_ID', 			GetUserData.Company_Main_ID, True)>
<CFSET Variables.Temp = StructInsert(AccessStructure, 'Company_Type_ID', 			GetUserData.Company_Type_ID, True)>
<CFSET Variables.Temp = StructInsert(AccessStructure, 'Company_logo', 				GetUserData.Company_logo, True)>
<CFSET Variables.Temp = StructInsert(AccessStructure, 'User_Directory', 			User_Directory, True)>
<CFSET Variables.Temp = StructInsert(AccessStructure, 'Access_Level', 				GetUserData.Access_Level, True)>
<CFSET Variables.Temp = StructInsert(AccessStructure, 'User_Rights_ID', 			GetUserData.User_Rights_ID, True)>
<CFSET Variables.Temp = StructInsert(AccessStructure, 'User_Email', 				GetUserData.User_Email, True)>

<!--- Serialize packet --->
<CFWDDX ACTION="CFML2WDDX" INPUT="#AccessStructure#" OUTPUT="myPacket">
<!--- Create cookie with contents of the WDDX packet --->
<CFCOOKIE NAME="User_Info" VALUE="#myPacket#">



<!--- Set the Login_Status bit in the database --->
<CFQUERY NAME="Set_Login_Status" datasource="#application.datasource#">
	UPDATE	_Users
	SET 	Login_Status = 1
	WHERE	User_ID	=	'#GetUserData.User_ID#'
</CFQUERY>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFINCLUDE TEMPLATE="/profile.cfm"> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->




<!--- clear the session VAR of data --->
<cfif isdefined("SESSION.Programs")>
	<cfset temp = StructDelete(SESSION, "Programs")>
</cfif>


<CFSWITCH EXPRESSION="#GetUserData.Company_Type_ID#">
	<!--- Manufacturer Homepage --->
	<CFCASE VALUE="1"><SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">window.location.href = '/Manufacturers/home.cfm';</SCRIPT></CFCASE>
	<!--- Distributor Homepage --->
	<CFCASE VALUE="2"><SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">window.location.href = '/Distributors/home.cfm';</SCRIPT></CFCASE>
	<!--- Operator Homepage --->
	<CFCASE VALUE="3"><SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">window.location.href = '/index.cfm';</SCRIPT></CFCASE>
	<!--- No Access --->
	<CFDEFAULTCASE><SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">window.location.href = '/index.cfm';</SCRIPT></CFDEFAULTCASE>
</CFSWITCH>
