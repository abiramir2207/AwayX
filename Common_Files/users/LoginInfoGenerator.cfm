<CFPARAM NAME="LoginGenerator.User_ID" DEFAULT="">
<CFPARAM NAME="LoginGenerator.GeneratedUserNameVariable" DEFAULT="">
<CFPARAM NAME="LoginGenerator.GeneratedPasswordVariable" DEFAULT="">

<CFPARAM NAME="LoginGenerator.GeneratedUserName" DEFAULT="">
<CFPARAM NAME="LoginGenerator.GeneratedPassword" DEFAULT="">

<cfset useLakebaseForGetUserInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGetUserInfo>
	<cftry>
		<cfset GetUserInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#LoginGenerator.User_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetUserInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetUserInfo>
<CFQUERY NAME="GetUserInfo" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT *
	FROM _Users
	WHERE User_ID = '#LoginGenerator.User_ID#'
</CFQUERY>
</cfif>

<CFSET tempusername = lcase(left(GetUserInfo.Name_First, 1)&GetUserInfo.Name_Last)>
<CFSET UniqueUsername = 0>
<CFSET x = 0>
<CFLOOP CONDITION="UniqueUsername EQUAL 0">

	<cfset useLakebaseForCheckForDuplicateUserName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForCheckForDuplicateUserName>
	<cftry>
		<cfset CheckForDuplicateUserName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_code" = "eq.#tempusername#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckForDuplicateUserName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckForDuplicateUserName>
<CFQUERY NAME="CheckForDuplicateUserName" datasource="#application.datasource#" DBTYPE="ODBC">
		SELECT *
		FROM _Users
		WHERE User_Code = '#tempusername#'
	</CFQUERY>
</cfif>
	
	<CFIF CheckForDuplicateUserName.Recordcount EQ 0>
		<CFSET LoginGenerator.GeneratedUserName = tempusername>
		<CFSET UniqueUsername = 1>
	<CFELSE>
		<CFSET x = incrementValue(x)>
		<CFSET tempusername = lcase(left(GetUserInfo.Name_First, 1)&GetUserInfo.Name_Last&"_"&x)>
	</CFIF>

</CFLOOP>