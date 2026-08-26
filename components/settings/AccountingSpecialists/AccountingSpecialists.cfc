<cfcomponent>
   
	<cffunction name="get" output="false" returntype="query">	
   
   		<cfargument name="userID" required="false" default="" />
		<cfargument name="Isdeleted" required="false" default="0" />
		
		<cfquery name="qGetAccountingSpecialists" datasource="#application.datasource#">
		
			SELECT 	Name_First + ' ' + Name_Last as Name,
					User_ID
			FROM	_users		
			<cfif arguments.Isdeleted eq 0>
				WHERE 	Deleted = 0
			</cfif>
			<cfif arguments.Isdeleted eq 0>	
				AND	Profiles_ID IN
			<cfelse>
				WHERE Profiles_ID IN
			</cfif>
					(
				
						SELECT 	Profiles_ID
						FROM 	Profiles_Settings
						WHERE 	Deleted = 0
						AND 	Payment_Processor = 1
				
					)
			
			<cfif trim(arguments.userId) neq "">
			AND		User_ID = #arguments.User_ID#
			</cfif>
			
			ORDER BY 	Name_Last
			
		</cfquery>
	
		<cfreturn qGetAccountingSpecialists />
		
   	</cffunction>
	
	<cffunction name="getByPaymentType" output="false" returntype="query">	
   
   		<cfargument name="paymentTypeId" required="false" default="" />
		
		<cfquery name="qGetPaymentTypePP" datasource="#application.datasource#">
		
			SELECT 	_USERS.Name_First + ' ' + _USERS.Name_Last as Name,
					_USERS.User_ID
			FROM	_USERS
					INNER JOIN Payment_Type_Payment_Processor ON
					Payment_Type_Payment_Processor.User_ID = _USERS.User_ID
					AND Payment_Type_Payment_Processor.Payment_Type_ID = #arguments.paymentTypeId#
					AND Payment_Type_Payment_Processor.Deleted = 0
		</cfquery>
	
		<cfreturn qGetPaymentTypePP />
		
   	</cffunction>
	
	<cffunction name="add" output="false">	
   
		<cfargument name="userId" required="true" default="" />
		<cfargument name="paymentTypeId" required="true" default="" />
		
		<!---delete first--->
		<cfset useLakebaseForqDeletePaymentTypeProcessor = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_type_payment_processor")>
<cfif useLakebaseForqDeletePaymentTypeProcessor>
	<cftry>
		<cfset application.oLakebase.updateRows("payment_type_payment_processor",
			{
				"deleted" = "eq.0",
				"payment_type_id" = "eq.#arguments.paymentTypeId#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqDeletePaymentTypeProcessor = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeletePaymentTypeProcessor>
<cfquery name="qDeletePaymentTypeProcessor" datasource="#application.datasource#">
		
			UPDATE 	Payment_Type_Payment_Processor
			SET		Deleted = 1
			WHERE	Deleted = 0
			AND		Payment_Type_ID = #arguments.paymentTypeId#

		</cfquery>
</cfif>
		
		<cfset useLakebaseForqInsertPaymentTypeProcessor = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_type_payment_processor")>
<cfif useLakebaseForqInsertPaymentTypeProcessor>
	<cftry>
		<cfset application.oLakebase.insertRow("payment_type_payment_processor", {
			"user_id" = "#arguments.userId#",
			"payment_type_id" = "#arguments.paymentTypeId#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsertPaymentTypeProcessor = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsertPaymentTypeProcessor>
<cfquery name="qInsertPaymentTypeProcessor" datasource="#application.datasource#">
		
			INSERT INTO Payment_Type_Payment_Processor
				(User_ID, Payment_Type_ID)
			VALUES
				('#arguments.userId#', #arguments.paymentTypeId#)

		</cfquery>
</cfif>

		
   	</cffunction>
	
	
	<cffunction name="addProfileAccess" output="false">
	
		<cfargument name="lProfileId" required="false" default="" />
		
		<!---set deleted to 1 for all records--->
		<cfset useLakebaseForqUpdate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("accounting_specialist_profile_access")>
<cfif useLakebaseForqUpdate>
	<cftry>
		<cfset application.oLakebase.updateRows("accounting_specialist_profile_access",
			{
				"deleted" = "eq.0"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdate>
<cfquery name="qUpdate" datasource="#application.datasource#">
			UPDATE	Accounting_Specialist_Profile_Access
			SET		Deleted = 1
			WHERE	Deleted = 0
		</cfquery>
</cfif>
			
		<!---loop over the list of profile id's and insert for each profile--->
		<cfloop index="profIndx" list="#arguments.lProfileId#">
			
			<!---insert for each record--->
			<cfquery name="qInsert" datasource="#application.datasource#">

				INSERT INTO	Accounting_Specialist_Profile_Access
					(Profiles_ID)
				VALUES
					(#profIndx#)

			</cfquery>
			
		</cfloop>
		
	</cffunction>
	
	<cffunction name="getProfileAccessList" output="false">
		
		<!---get all profiles restrict list--->
		<cfset useLakebaseForqGetProfileList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("accounting_specialist_profile_access")>
<cfif useLakebaseForqGetProfileList>
	<cftry>
		<cfset qGetProfileList = application.oLakebase.toQuery(
			application.oLakebase.selectRows("accounting_specialist_profile_access", {
				"deleted" = "eq.0",
				"select" = "profiles_id"
			}), "profiles_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProfileList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProfileList>
<cfquery name="qGetProfileList" datasource="#application.datasource#">
			SELECT 	Profiles_ID
			FROM	Accounting_Specialist_Profile_Access
			WHERE	Deleted = 0
		</cfquery>
</cfif>
		
		<cfreturn ValueList(qGetProfileList.Profiles_ID) />
		
	</cffunction>
	
	<cffunction name="getProfiles" output="false">
		
		<!---get all profiles --->
		<cfset useLakebaseForqGetProfiles = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profiles")>
<cfif useLakebaseForqGetProfiles>
	<cftry>
		<cfset qGetProfiles = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profiles", {
				"deleted" = "eq.0",
				"select" = "profiles_id,profiles_desc"
			}), "profiles_id,profiles_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProfiles = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProfiles>
<cfquery name="qGetProfiles" datasource="#application.datasource#">
			SELECT 	DISTINCT Profiles_ID, 
					Profiles_Desc 
			FROM 	Profiles 
			WHERE 	Deleted = 0
		</cfquery>
</cfif>
		
		<cfreturn qGetProfiles />
		
	</cffunction>
	
</cfcomponent>