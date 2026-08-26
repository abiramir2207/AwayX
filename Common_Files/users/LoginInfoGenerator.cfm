<CFPARAM NAME="LoginGenerator.User_ID" DEFAULT="">
<CFPARAM NAME="LoginGenerator.GeneratedUserNameVariable" DEFAULT="">
<CFPARAM NAME="LoginGenerator.GeneratedPasswordVariable" DEFAULT="">

<CFPARAM NAME="LoginGenerator.GeneratedUserName" DEFAULT="">
<CFPARAM NAME="LoginGenerator.GeneratedPassword" DEFAULT="">

<CFQUERY NAME="GetUserInfo" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT *
	FROM _Users
	WHERE User_ID = '#LoginGenerator.User_ID#'
</CFQUERY>

<CFSET tempusername = lcase(left(GetUserInfo.Name_First, 1)&GetUserInfo.Name_Last)>
<CFSET UniqueUsername = 0>
<CFSET x = 0>
<CFLOOP CONDITION="UniqueUsername EQUAL 0">

	<CFQUERY NAME="CheckForDuplicateUserName" datasource="#application.datasource#" DBTYPE="ODBC">
		SELECT *
		FROM _Users
		WHERE User_Code = '#tempusername#'
	</CFQUERY>
	
	<CFIF CheckForDuplicateUserName.Recordcount EQ 0>
		<CFSET LoginGenerator.GeneratedUserName = tempusername>
		<CFSET UniqueUsername = 1>
	<CFELSE>
		<CFSET x = incrementValue(x)>
		<CFSET tempusername = lcase(left(GetUserInfo.Name_First, 1)&GetUserInfo.Name_Last&"_"&x)>
	</CFIF>

</CFLOOP>