<cfcomponent hint="Release Settlement Manager" extends="components.Base">

	<cffunction name="init" output="false" returntype="components.programs.ReleaseSettlement.ReleaseSettlementManager">
		<cfreturn this />
	</cffunction>

	<cffunction name="Send" output="No" returntype="numeric">
		<cfargument name="contract_main_id" type="string" required="Yes" />
		<cfargument name="user_id" type="string" required="Yes" />
		<cfargument name="release_type" type="numeric" required="No" default="1" />

		<cfquery name="getPrgNum" datasource="#application.datasource#">
			SELECT Contract_Number
			FROM Contract_Main
			WHERE Contract_Main_ID  IN (<cfqueryparam value="#arguments.contract_main_id#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
		</cfquery>

			<cfquery name="updateContractMain" datasource="#application.datasource#">
				update 	contract_main
				set 	released = '#arguments.release_type#',
						released_by = '#arguments.user_id#',
						released_sending_to_client = 1,
						Released_Sent_to_Client = 0,
						Released_Ack_From_Client = 0,
						released_date = getdate()
				where Contract_Number IN (<cfqueryparam value="#valuelist(getPrgNum.Contract_Number)#" cfsqltype="CF_SQL_VARCHAR" list="Yes">)
				and released = 0
			</cfquery>

			<cfreturn 1 />

	</cffunction>

	<cffunction name="GetReleaseData" output="No" returntype="query">
		<cfargument name="contract_main_id" type="numeric" required="Yes" />

		<cfquery name="qGetReleaseData" datasource="#application.datasource#">
			select 	released_date,
					released_by,
					CASE WHEN released = 1 THEN 'Manual'
						 WHEN released = 2 THEN 'Systemic'
						 ELSE 'Not Released'
					 	 END AS "Release_Type",
					released_ack_date
			FROM contract_main
			WHERE contract_main_id ='#arguments.contract_main_id#'
		</cfquery>

		<cfreturn qGetReleaseData />

	</cffunction>

</cfcomponent>