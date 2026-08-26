<cffunction name="getActiveLOB" output="false" returntype="query">
		<cfargument name="userId" type="string" required="false" default="" />
		
		<!---get active LOb's--->
			<cfquery name="qgetActiveLOB" datasource="#application.datasource#">
				SELECT distinct	Line_Of_Business.Line_Of_Business_ID,
						Line_Of_Business,
						Line_Of_Business_Name
				FROM 	Line_Of_Business
						<cfif arguments.userId NEQ "">
						INNER JOIN
	                
	                      User_LOB ON User_LOB.Line_of_Business_ID = Line_Of_Business.Line_of_Business_ID
						AND
						User_LOB.User_ID = '#arguments.userId#'
						AND User_LOB.Deleted = 0
						</cfif>
				WHERE	Line_Of_Business.Deleted = 0
			</cfquery>
		<cfreturn qgetActiveLOB />
	</cffunction>
	
	<cffunction name="getLOBIdByProgram" output="false">
	
		<cfargument name="programId" type="numeric" required="false" default="0" />
		
		<!---get the business segments--->
		<cfset useLakebaseForqGetLOBIdFromProgram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqGetLOBIdFromProgram>
	<cftry>
		<cfset qGetLOBIdFromProgram = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#arguments.programId#",
				"select" = "line_of_business_id"
			}), "line_of_business_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetLOBIdFromProgram = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetLOBIdFromProgram>
<cfquery name="qGetLOBIdFromProgram" datasource="#application.datasource#">
			
			SELECT 	Line_Of_Business_ID 
			FROM 	Contract_Main
			WHERE	Contract_Main_ID = #arguments.programId#
			
		</cfquery>
</cfif>
		
		<cfreturn qGetLOBIdFromProgram.Line_Of_Business_ID />
		
	</cffunction>
	
	
	<cffunction name="get" output="false" returntype="query">
	
		<cfargument name="LOBId" type="string" required="false" default="0" />
		
		<!---get the business segments--->
		<cfquery name="qGetLOB" datasource="#application.datasource#">
			
			SELECT distinct	Line_Of_Business_ID,
						Line_Of_Business,
						Line_Of_Business_Name
				FROM 	Line_Of_Business
			WHERE	Deleted = 0
			AND		Line_Of_Business_ID = '#arguments.LOBId#'
			
		</cfquery>
		
		<!---if we don't get a record count then retrun a record with a No Segment description--->
		<cfif not qGetLOB.RecordCount>
		
			<cfscript>
				QueryAddRow(qGetLOB);
				QuerySetCell(qGetLOB, "Line_Of_Business", "No Sales Org");
			</cfscript>
			
		</cfif>
		
		<cfreturn qGetLOB />
		
	</cffunction>