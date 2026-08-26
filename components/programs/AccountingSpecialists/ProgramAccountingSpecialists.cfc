<cfcomponent>
   
	<cffunction name="get" output="false" returntype="query">	
   
   		<cfargument name="contractMainId" required="true" default="0" />
		
		<cfset var qGetAccountingSpecialists = QueryNew("Name, User_ID") />
		<cfset var paymentTypeID = 0 />
		<cfset var programId = 0 />
		
		<!---makes sure contractMainId is a valid number--->
		<cfif isNumeric(arguments.contractMainId)>
			<cfset programId = arguments.contractMainId />
		</cfif>
		
		<cfquery name="qGetProgramPP" datasource="#application.datasource#">
					
			SELECT	_users.Name_First + ' ' + _users.Name_Last AS Name,
					_users.User_ID as User_ID
			FROM 	Program_Accounting_Specialist
					INNER JOIN _users ON
					_users.User_ID = Program_Accounting_Specialist.User_ID
			WHERE 	Program_Accounting_Specialist.Deleted = 0
			AND		Program_Accounting_Specialist.Program_ID = #programId#
			
		</cfquery>
	
		<!---if we have a payment processor for this program then return it--->
		<cfif qGetProgramPP.RecordCount>
			<cfset qGetAccountingSpecialists = qGetProgramPP />
		<!---otherwise try to get it from payment type--->
		<cfelse>
			
			<!---get the payment type id--->
			<cfquery name="qGetPaymentTypeId" datasource="#application.datasource#">
				SELECT 	ClaimMechanics as Payment_Type_ID
				FROM	Contract_Main
				WHERE	Deleted = 0
				AND		Contract_Main_ID = #programId#
			</cfquery>
			
			<!---check to make sure the payment type id is numeric--->
			<cfif isNumeric(qGetPaymentTypeId.Payment_Type_ID)>
				<cfset paymentTypeID = qGetPaymentTypeId.Payment_Type_ID />
			</cfif>
			
			<cfset qPaymentTypeProcessor = CreateObject("component","components.settings.AccountingSpecialists.AccountingSpecialists").getByPaymentType(paymentTypeID) />
			
			<!---if we have a payment processor assigned to a payment type then add it to the program and get it--->
			<cfif qPaymentTypeProcessor.RecordCount>
				<cfset this.add(qPaymentTypeProcessor.User_ID, programId) />
				<cfset qGetAccountingSpecialists = this.get(programId) />
			</cfif>
			
		</cfif>
		
		<cfreturn qGetAccountingSpecialists />
		
   	</cffunction>
	
	<cffunction name="add" output="false">	
   
		<cfargument name="userId" required="true" default="" />
		<cfargument name="contractMainId" required="true" default="" />
		
		<!---delete first--->
		<cfquery name="qDeleteProcessor" datasource="#application.datasource#">
		
			UPDATE 	Program_Accounting_Specialist
			SET		Deleted = 1
			WHERE	Deleted = 0
			AND		Program_ID = #arguments.contractMainId#

		</cfquery>
		
		<cfquery name="qInsertProcessor" datasource="#application.datasource#">
		
			INSERT INTO Program_Accounting_Specialist
				(User_ID, Program_ID)
			VALUES
				('#arguments.userId#', #arguments.contractMainId#)

		</cfquery>

   	</cffunction>
	
	
</cfcomponent>