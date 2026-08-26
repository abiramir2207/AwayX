<cfcomponent>
	<cffunction name="init" output="false" returntype="components.user.ajaxUserManager">
		<cfargument name="dsn" type="string" required="true" />
		<cfset Application.Datasource = arguments.dsn />

		<cfreturn this />
    </cffunction>

	<cffunction name="populateProfileSelect" access="public" ouput="false" returntype="query">
	  <cfset var qGetProfiles = "" />

	  <cfquery name="qGetProfiles" datasource="#Application.Datasource#">
		Select profiles_id,Profiles_Desc
		From profiles
		Where deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
		Order By Profiles_Desc Asc
	 </cfquery>

	  <cfreturn qGetProfiles />
	</cffunction>

	<cffunction name="populateUsrPosSelect" access="public" ouput="false" returntype="query">
	    <cfset var qGetUserPositions = "" />

		 <cfquery NAME="qGetUserPositions" datasource="#Application.Datasource#">
			Select		User_Positions.Position_Label,
						User_Positions.User_Positions_ID,
						Service_Zones.Zone_Name,
						Service_Regions.Region_Name,
						Service_Markets.Market_Name,
						User_Positions.Service_Zone_ID,
						User_Positions.Service_Region_ID,
						User_Positions.Service_Market_ID
			From	    User_Positions
			Left Join	Service_Zones On
					    Service_Zones.Service_Zone_ID = User_Positions.Service_Zone_ID
			Left Join	Service_Regions On
					    Service_Regions.Service_Region_ID = User_Positions.Service_Region_ID
		    Left Join	Service_Markets On
					    Service_Markets.Service_Market_ID = User_Positions.Service_Market_ID
		    Where		User_Positions.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
			And         (len(User_Positions.Position_Label) <> <cfqueryparam cfsqltype="cf_sql_integer" value="0" />)
		    And
					(
						User_Positions.Service_Zone_ID IS NULL
			OR
						(Service_Zones.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />)
					)
			And
					(
						User_Positions.Service_Region_ID IS NULL
		   Or
						(Service_Regions.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />)
					)
		   And
					(
						User_Positions.Service_Market_ID IS NULL
		   Or
						(Service_Markets.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />)
					)

					    Order By User_Positions.Position_Label Asc

	       </cfquery>
		  <cfreturn qGetUserPositions />
	 </cffunction>

	<cffunction name="getusersList" access="public" output="false" returntype="query">
	 <cfargument name="SQL_Sort_by" required="true" type="string" default="name_first" />
	 <cfargument name="searchstring" type="string" required="true" default="" />
	 <cfargument name="type" required="true" type="any" default="0" />
	 <cfargument name="position" type="string" required="true" default="P" />
	 <cfargument name="position_id" type="Any" required="false" />
	 <cfargument name="profile_id" type="Any" required="false" />
	 <cfargument name="authoritySequence" type="Any" required="false" />
	 <!--- <cfargument name="appsettings" type="any" required="true" /> --->
	 <cfargument name="UserSettingPanel" type="numeric" required="false" default=5>
	 <cfargument name="auditInfo" type="boolean" required="false" default="0">

	  <cfset var getAllUsers = "" />
	  <cfset var getUsers = "" />
	  <cfset var createUserTempTbl = "" />
	  <cfset var firstName = "" />
      <cfset var lastName = "" />
      <cfset var isSplit = 0 />

	  <cfif isSplit neq 0>
	 	<cfset firstName = Left(arguments.searchstring,isSplit-1) />
	 	<cfset lastName = Right(arguments.searchstring,len(arguments.searchstring)-isSplit) />
	  <cfelse>
	    <cfset firstName = arguments.searchstring />
	 	<cfset lastName = arguments.searchstring />
	  </cfif>
	 <!---
	Dev Notes: 23086/Anand Rao/27-May-10
	User Traffic Changes/ added date fields from Audit_transactions_Table
  --->
	 <cfquery name="createUserTempTbl" datasource="#Application.Datasource#">
	 	IF Object_ID('TempDB..##Temp_user') IS NOT NULL
			DROP TABLE ##Temp_user

         Select DISTINCT
			_Users.User_ID,
			_Users.User_Code,
			_Users.Name_First + ' ' + _Users.name_last + '<br />' + 'UserName:' +
			_Users.User_Code +  '<br />' + _Users.User_Email As FullName,
			_Users.Work_Address_1 + ' ' + _Users.Work_Address_2 + '<br />' + _Users.Work_City + ' ' +
			_states.State_Code + ' ' + _Users.Work_Zip As Address,
			'P:' + _Users.Work_Phone_1 + '-' + _Users.Work_Phone_2 + '-' + _Users.Work_Phone_3 + '<br />' +
			'Ext:' + _Users.Work_Phone_Ext + '<br />' + 'F:'
			+  _Users.Work_Fax_1 + '-' + _Users.Work_Fax_2 + '-' +  _Users.Work_Fax_3 as PhoneNum,
			_Users.User_Email,
			_Users.Password_Update_Date As Password_Update_Date,
			Company_Main.Company_Name,
			_Users.Title,
			_Users.User_Number,
			_Users.LDAP_User_Name,
			Profiles.Profiles_Desc,
			Profiles.Profiles_Short_Desc,
			_Users.Deleted,User_Position_Holders.User_Position_Type,
			_Users.Name_First,
			_Users.Name_Last,
			Authority_Sequence.Authority_Sequence_Name,
			CASE
			WHEN User_Positions.Position_Label IS NULL Or User_Positions.Position_Label = '' THEN
			'Pending...'
			ELSE
			User_Positions.Position_Label
			END AS Position_Label,
			_Users.User_Created_Date As CreatedDate,
			_Users.Analytics_SSO_User_Name,
			_Users.Ember_Info
		INTO ##Temp_user
		FROM 	_Users
			INNER JOIN Company_Main
			ON
			Company_Main.Company_Main_ID = _Users.Company_Main_ID
			LEFT JOIN Profiles
			ON
			Profiles.Profiles_ID = _Users.Profiles_ID
			LEFT JOIN _States
			ON
			_Users.Work_State	=	cast(_states.state_ID as nvarchar)
			Left JOIN User_Position_Holders
			ON
			User_Position_Holders.User_ID = _Users.User_ID
			AND
			User_Position_Holders.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
			AND User_Position_Holders.User_Position_Type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.position#" />
			AND User_Position_Holders.User_Positions_ID <> <cfqueryparam cfsqltype="cf_sql_integer" value="0" />
			Left Join Authority_Sequence
			On Authority_Sequence.Authority_Sequence_ID = _Users.Authority_Sequence_ID
			And Authority_Sequence.deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
			LEFT JOIN User_Positions
			ON
			User_Positions.User_Positions_ID = User_Position_Holders.User_Positions_ID
			AND
			User_Positions.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
		WHERE 0=0
		<cfif structKeyExists(arguments,"userid")
			  and arguments.userid NEQ "">
		AND _Users.User_ID Not In (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userid#" list="true" />)

		</cfif>
		<cfif isdefined("arguments.searchstring")
			  and arguments.searchstring NEQ "">
		and (_Users.Name_First like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#Trim(firstName)#%" />
		Or   _Users.Name_Last like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#Trim(lastName)#%" />
		    )

		</cfif>
		<!---
        <cfif isdefined("arguments.User_Last_Name")
		      and arguments.User_Last_Name NEQ "">
		and _Users.Name_Last like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.User_Last_Name#%" />
		</cfif>--->
		<cfif isDefined("arguments.authoritySequence")
			  and arguments.authoritySequence neq 0
			  and arguments.authoritySequence neq "">
			and _Users.Authority_Sequence_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.authoritySequence#" />
		</cfif>
		<cfif isdefined("arguments.profile_id")>
		<cfif arguments.profile_id NEQ "" and arguments.profile_id NEQ 0>
		and _Users.Profiles_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.profile_id#" />
		</cfif>
		</cfif>

		<cfif isdefined("arguments.position_id")>
		<cfif arguments.position_id NEQ "" and arguments.position_id NEQ 0>
		and User_Position_Holders.User_Positions_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.position_id#" />
		</cfif>
		</cfif>

		<cfif isdefined("arguments.type")>
		 <cfif arguments.type EQ "1">
		  AND _Users.DELETED = <cfqueryparam cfsqltype="cf_sql_bit" value="1" />
		<cfelse>
		  AND _Users.DELETED = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
		  </cfif>
		</cfif>
		<!---Don't show BSA users --->
      	<!--- <cfif arguments.appSettings.getHide_BSA_Users() IS 1>
		AND (_Users.User_Rights_ID IS NULL
		OR _Users.User_Rights_ID != 9999)
		</cfif> --->
		<cfif #arguments.UserSettingPanel# LT 5>
			And _Users.Profiles_ID NOT IN (select distinct Profiles_ID from Profiles_Settings where Settings_Panel = 5)
		</cfif>
		<CFSWITCH EXPRESSION="#LCase(arguments.SQL_Sort_by)#">
		<CFCASE VALUE="name_first">
			<CFSET SQL_Sort_by = "Name_First">
		</CFCASE>
		<CFCASE VALUE="name_last">
			<CFSET SQL_Sort_by = "Name_Last">
		</CFCASE>
		<CFCASE VALUE="profile">
			<CFSET SQL_Sort_by = "Profiles_Desc">
		</CFCASE>
		<CFCASE VALUE="position">
			<CFSET SQL_Sort_by = "Position_Label">
		</CFCASE>
		<CFCASE VALUE="lastlogindate">
			<CFSET SQL_Sort_by = "LastLoginDate">
		</CFCASE>
		<CFCASE VALUE="password_update_date">
			<CFSET SQL_Sort_by = "Password_Update_Date">
		</CFCASE>
		</CFSWITCH>
	  	<!--- Ana - D25053 - User Search tuning --->
		SELECT ##Temp_user.*,
		(SELECT MAX(LoginIP.Date_time) FROM LoginIP WHERE ##Temp_user.User_Code = LoginIP.User_Code) As LastLoginDate
		<!--- Audit Info is only needed for the report --->
		<cfif arguments.auditInfo eq 1>, 
		(SELECT MAX(Trans_DateTime) FROM Audit_User_Transactions AUT1 WHERE AUT1.Trans_By_User_ID = ##Temp_user.User_ID AND AUT1.Trans_Type = 'LOCKED-OUT') LastLockedDate,
		(SELECT MAX(Trans_DateTime) FROM Audit_User_Transactions AUT2 WHERE AUT2.Trans_By_User_ID = ##Temp_user.User_ID AND AUT2.Trans_Type = 'UNLOCK-USER') LastUnlockDate,
		(SELECT MAX(Trans_DateTime) FROM Audit_User_Transactions AUT3 WHERE AUT3.Trans_By_User_ID = ##Temp_user.User_ID AND AUT3.Trans_Type = 'PASSWORD-RESET') LastPasswordResetDate,
		(SELECT MAX(Trans_DateTime) FROM Audit_User_Transactions AUT4 WHERE AUT4.Trans_By_User_ID = ##Temp_user.User_ID AND AUT4.Trans_Type = 'PIN-RESET') LastPinResetDate,
		(SELECT MAX(Trans_DateTime) FROM Audit_User_Transactions AUT5 WHERE AUT5.Trans_By_User_ID = ##Temp_user.User_ID AND AUT5.Trans_Type = 'PASSWORD-CHANGE') LastPasswordChangeDate,
		(SELECT MAX(Trans_DateTime) FROM Audit_User_Transactions AUT6 WHERE AUT6.Trans_By_User_ID = ##Temp_user.User_ID AND AUT6.Trans_Type = 'INACTIVATE-USER') LastInactivatedDate,
		(SELECT MAX(Trans_DateTime) FROM Audit_User_Transactions AUT7 WHERE AUT7.Trans_By_User_ID = ##Temp_user.User_ID AND AUT7.Trans_Type = 'ACTIVATE-USER') LastActivatedDate,
		<!--- "CreatedDate" is extracted from the "_Users" table. It should not be extracted from the "Audit_User_Transactions" table, as it only happens once. --->
		<!---(SELECT MAX(Trans_DateTime) FROM Audit_User_Transactions AUT8 WHERE AUT8.Trans_By_User_ID = ##Temp_user.User_ID AND AUT8.Trans_Type = 'CREATE-USER') CreatedDate,--->
		(SELECT MAX(Trans_DateTime) FROM Audit_User_Transactions AUT9 WHERE AUT9.Trans_By_User_ID = ##Temp_user.User_ID AND AUT9.Trans_Type = 'UNSUCCESS-LOGON') LastUnsuccessLoginDate
		 </cfif>
		FROM ##Temp_user
	  	ORDER BY #SQL_Sort_by#

	 </cfquery>
       <!--- <cfcatch type="database">
	     <cflog file="myajaxfile" text="#cfcatch.SQL# : #CFCATCH.message# : #CFCATCH.detail#" />
		</cfcatch>
		</cftry> --->

			<cfreturn createUserTempTbl />
    </cffunction>

	<cffunction name="autoCompleteData" access="public" output="false" returntype="query">
	 <cfargument name="searchstring" type="string" required="true" default="" />
     <cfargument name="SQL_Sort_by" required="true" type="string" default="name_first" />
	 <cfargument name="type" required="true" type="numeric" default="0" />
	 <cfargument name="position" type="string" required="true" default="P" />

	  <cfset var qAutoComplete = "" />

	 <cftransaction>
	  <cftry>
	 <cfquery name="qAutoComplete" datasource="#Application.Datasource#">
          Select  Name_First,Name_Last,User_ID
          From 	_Users
		  Where
		  <cfif isdefined("arguments.type")>
		   <cfif arguments.type EQ 1>
		     _Users.deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="1" />
		   <cfelse>
		    _Users.deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
		   </cfif>
		 </cfif>
		 <cfif isdefined("arguments.searchstring")
			   and arguments.searchstring neq "">
		  And
		     (_Users.Name_Last LIKE '#arguments.searchstring#%'
		  Or  _Users.Name_First LIKE '#arguments.searchstring#%'
		     )
		</cfif>


		<!---Don't show BSA users
		<cfif appSettings.getHide_BSA_Users() IS 1 AND request.AccessStructure.User_Rights_ID NEQ 9999>
		AND (_Users.User_Rights_ID IS NULL
		OR _Users.User_Rights_ID != 9999)
		</cfif>--->


	  ORDER BY #SQL_Sort_by#

	 </cfquery>
       <cfcatch type="database">
	     <cflog file="myajaxfile" text="#cfcatch.SQL# : #CFCATCH.message# : #CFCATCH.detail#" />
		</cfcatch>
		</cftry>
	</cftransaction>

       <cfreturn qAutoComplete />
	</cffunction>
	<!--- <cffunction name="getUsersFromTemp" access="public" returntype="query" output="false">
	 	<cfargument name="startRow" required="true" type="numeric" default="0"  />
	 	<cfargument name="endRow" required="true" type="numeric" default="0"  />

		<cfset var getUsers = "" />
		<cfquery name="getUsers" datasource="#application.datasource#">

			SELECT  User_ID,User_Code,Name_First,Name_Last,Title,User_Email,Work_Address_1,
			        Work_Address_2,Work_Zip,Work_City,State_Code,Work_Phone_1,
			        Work_Phone_2,Work_Phone_3,Work_Phone_Ext,Password_Update_Date,
			        Work_Fax_1,Work_Fax_2, Work_Fax_3, Company_Name,Profiles_Desc,
			        Profiles_Short_Desc,Deleted,User_Position_Type,LastLoginDate,
	                Authority_Sequence_Name,Position_Label
	       From     ajaxUser
		<cfif arguments.startRow neq 0>
	    	Where RowNum Between #arguments.startRow# And #arguments.endRow#
	    	And search_user_Id = '#request.accessstructure.user_id#'
	    <cfelse>
	     Where search_user_Id = '#request.accessstructure.user_id#'
	     </cfif>

		</cfquery>
		<cfreturn getUsers />
	</cffunction> --->


</cfcomponent>