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
		<cfquery name="qDeletePaymentTypeProcessor" datasource="#application.datasource#">
		
			UPDATE 	Payment_Type_Payment_Processor
			SET		Deleted = 1
			WHERE	Deleted = 0
			AND		Payment_Type_ID = #arguments.paymentTypeId#

		</cfquery>
		
		<cfquery name="qInsertPaymentTypeProcessor" datasource="#application.datasource#">
		
			INSERT INTO Payment_Type_Payment_Processor
				(User_ID, Payment_Type_ID)
			VALUES
				('#arguments.userId#', #arguments.paymentTypeId#)

		</cfquery>

		
   	</cffunction>
	
	
	<cffunction name="addProfileAccess" output="false">
	
		<cfargument name="lProfileId" required="false" default="" />
		
		<!---set deleted to 1 for all records--->
		<cfquery name="qUpdate" datasource="#application.datasource#">
			UPDATE	Accounting_Specialist_Profile_Access
			SET		Deleted = 1
			WHERE	Deleted = 0
		</cfquery>
			
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
		<cfquery name="qGetProfileList" datasource="#application.datasource#">
			SELECT 	Profiles_ID
			FROM	Accounting_Specialist_Profile_Access
			WHERE	Deleted = 0
		</cfquery>
		
		<cfreturn ValueList(qGetProfileList.Profiles_ID) />
		
	</cffunction>
	
	<cffunction name="getProfiles" output="false">
		
		<!---get all profiles --->
		<cfquery name="qGetProfiles" datasource="#application.datasource#">
			SELECT 	DISTINCT Profiles_ID, 
					Profiles_Desc 
			FROM 	Profiles 
			WHERE 	Deleted = 0
		</cfquery>
		
		<cfreturn qGetProfiles />
		
	</cffunction>
	
</cfcomponent>