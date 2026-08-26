<cfcomponent hint="Futures Pricing Status Manager" extends="components.Base">

	<cffunction name="init" output="false" returntype="components.futures_pricing.StatusManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="get" output="false" returntype="components.futures_pricing.Status">
		
		<cfargument name="id" type="numeric" required="true" />
	
		<cfset this.status = CreateObject("component", "components.futures_pricing.Status") />
		
		<cfif arguments.id>
		
			<cfquery name="qGetStatus" datasource="#application.datasource#">
				SELECT	FP_Status_ID, FP_Status_Desc, UpdatedBy, UpdatedOn,
						_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName
				FROM	FP_Status
						LEFT JOIN _Users
						ON
						_Users.Deleted = 0
						AND
						_Users.User_ID = FP_Status.UpdatedBy
				WHERE
						FP_Status.Deleted = 0
						AND FP_Status_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			
			<cfloop query="qGetStatus">
			
				<cfset this.status.setId(FP_Status_ID) />
				<cfset this.status.setDesc(FP_Status_Desc) />
				<cfset this.status.setUpdatedBy(UpdatedBy) />
				<cfset this.status.setUpdatedByUserName(UpdatedByFullName) />				
				<cfset this.status.setUpdatedOn(UpdatedOn) />
			
			</cfloop>
		
		</cfif>
		
		<cfreturn this.status />
	
	</cffunction>
	
	<cffunction name="getAll" output="false" returntype="query">
		<cfargument name="active" type="string" required="false" default="" />
	
		<cfquery name="qGetStatus" datasource="#application.datasource#">
			SELECT	FP_Status_ID, FP_Status_Desc
			FROM	FP_Status
			WHERE
					Deleted = 0					
		</cfquery>
		
		<cfreturn qGetStatus />
	
	</cffunction>
	
	<cffunction name="getStatusDesc" output="false" returntype="string">
		<cfargument name="id" type="numeric" required="true" />
	
		<cfquery name="qGetStatus" datasource="#application.datasource#">
			SELECT	FP_Status_Desc
			FROM	FP_Status					
			WHERE
					Deleted = 0
					AND FP_Status_ID = #arguments.id#					
		</cfquery>
		
		<cfreturn qGetStatus.FP_Status_Desc />
	
	</cffunction>
	
	<cffunction name="save" output="false">
	
		<cfif this.status.getId()>
		
			<!------ update ----->
			<cfquery name="qUpdateStatus" datasource="#application.datasource#">
				UPDATE	FP_Status
				SET		FP_Status_Desc = <cfqueryparam value="#this.status.getDesc()#" cfsqltype="CF_SQL_VARCHAR">,
						UpdatedBy = <cfqueryparam value="#this.status.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
						UpdatedOn = GetDate()
				WHERE
						Deleted = 0
						AND FP_Status_ID = <cfqueryparam value="#this.status.getId()#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		
		</cfif>
	
	</cffunction>

</cfcomponent>
