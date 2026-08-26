<cfcomponent hint="Futures Pricing Preservation Manager" extends="components.Base">

	<cffunction name="init" output="false" returntype="components.futures_pricing.PreservationManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="get" output="false" returntype="components.futures_pricing.Preservation">
		
		<cfargument name="id" type="numeric" required="true" />
	
		<cfset this.preservation = CreateObject("component", "components.futures_pricing.Preservation") />
		
		<cfif arguments.id>
		
			<cfquery name="qGetPresevation" datasource="#application.datasource#">
				SELECT	FP_Preservation_ID, Preservation_Desc, Active, UpdatedBy, UpdatedOn,
						_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName
				FROM	FP_Preservation
						LEFT JOIN _Users
						ON
						_Users.Deleted = 0
						AND
						_Users.User_ID = FP_Preservation.UpdatedBy
				WHERE
						FP_Preservation.Deleted = 0
						AND FP_Preservation_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			
			<cfloop query="qGetPresevation">
			
				<cfset this.preservation.setId(FP_Preservation_ID) />
				<cfset this.preservation.setDesc(Preservation_Desc) />
				<cfset this.preservation.setActive(Active) />
				<cfset this.preservation.setUpdatedBy(UpdatedBy) />
				<cfset this.preservation.setUpdatedByUserName(UpdatedByFullName) />				
				<cfset this.preservation.setUpdatedOn(UpdatedOn) />
			
			</cfloop>			
		
		</cfif>
		
		<cfreturn this.preservation />
	
	</cffunction>
	
	<cffunction name="save" output="false">
	
		<cfif this.preservation.getId()>
		
			<!------ update ----->
			<cfquery name="qUpdatePreservation" datasource="#application.datasource#">
				UPDATE	FP_Preservation
				SET		Preservation_Desc = <cfqueryparam value="#this.preservation.getDesc()#" cfsqltype="CF_SQL_VARCHAR">,
						Active = <cfqueryparam value="#this.preservation.getActive()#" cfsqltype="CF_SQL_BIT">,
						UpdatedBy = <cfqueryparam value="#this.preservation.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
						UpdatedOn = GetDate()
				WHERE
						Deleted = 0
						AND FP_Preservation_ID = <cfqueryparam value="#this.preservation.getId()#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		
		<cfelse>
		
			<!------ insert ----->
			<cfquery name="qInsertPreservation" datasource="#application.datasource#">
				INSERT INTO FP_Preservation (Preservation_Desc, Active, UpdatedBy)
				VALUES	(
						<cfqueryparam value="#this.preservation.getDesc()#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#this.preservation.getActive()#" cfsqltype="CF_SQL_BIT">,
						<cfqueryparam value="#this.preservation.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">
						)
			</cfquery>
		
		</cfif>
	
	</cffunction>
	
	<cffunction name="delete" output="false">
	
		<cfif this.preservation.getId()>
		
			<!------ delete ----->
			<cfquery name="qDeletePreservation" datasource="#application.datasource#">
				UPDATE	FP_Preservation
				SET		Deleted = 1
				WHERE
						Deleted = 0
						AND FP_Preservation_ID = <cfqueryparam value="#this.preservation.getId()#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		
		</cfif>
	
	</cffunction>
	
	<cffunction name="getAll" output="false" returntype="query">
		<cfargument name="active" type="string" required="false" default="" />
	
		<cfquery name="qGetPresevations" datasource="#application.datasource#">
			SELECT	FP_Preservation_ID, Preservation_Desc, Active
			FROM	FP_Preservation
			WHERE
					Deleted = 0
					<cfif arguments.active NEQ "" AND Isnumeric(arguments.active)>
					AND Active = #arguments.active#
					</cfif>
		</cfquery>
		
		<cfreturn qGetPresevations />
	
	</cffunction>
	
	<cffunction name="getRequestWithPreservation" output="false" returntype="query">
	
		<cfargument name="id" type="numeric" required="true" />
	
		<cfquery name="qGetRequests" datasource="#application.datasource#">
			SELECT	FP_Request_Master.FP_Request_Master_ID
			FROM	FP_Mat_Req_Product
					INNER JOIN FP_Product
					ON
					FP_Product.FP_Product_ID = FP_Mat_Req_Product.FP_Product_ID
					AND
					FP_Product.Deleted = 0	
					INNER JOIN 	FP_Request_Master
					ON
					FP_Request_Master.FP_Request_Master_ID = FP_Product.FP_Request_Master_ID
					AND
					FP_Request_Master.Deleted = 0
			WHERE
					FP_Mat_Req_Product.FP_Preservation_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">			
		</cfquery>
		
		<cfreturn qGetRequests />
	
	</cffunction>
	
	<cffunction name="getRequestPreservations" output="false" returntype="query">
		<cfargument name="requestId" type="numeric" required="true" />
		<cfargument name="active" type="string" required="false" default="" />
	
		<cfquery name="qGetPresevations" datasource="#application.datasource#">
			SELECT	FP_Preservation.FP_Preservation_ID, FP_Preservation.Preservation_Desc, FP_Product.FP_Product_ID, Isnull(FP_Product.FP_Product_ID, 0) AS isSelected
			FROM	FP_Preservation
					LEFT JOIN FP_Mat_Req_Product
					ON
					FP_Mat_Req_Product.FP_Preservation_ID = FP_Preservation.FP_Preservation_ID
					LEFT JOIN FP_Product
					ON
					FP_Product.FP_Product_ID = FP_Mat_Req_Product.FP_Product_ID
					AND
					FP_Product.Deleted = 0
					AND
					FP_Product.FP_Request_Master_ID = #arguments.requestId#
			WHERE
					FP_Preservation.Deleted = 0
					<cfif arguments.active NEQ "" AND Isnumeric(arguments.active)>
					AND FP_Preservation.Active = #arguments.active#
					</cfif>
		</cfquery>
		
		<cfreturn qGetPresevations />
	
	</cffunction>

</cfcomponent>
