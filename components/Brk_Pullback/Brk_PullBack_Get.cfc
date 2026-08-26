<cfcomponent extends="components.Base" output="false" hint="Gets Brokerage Pullback Data">
	<cffunction name="init" output="false" returntype="components.Brk_Pullback.Brk_Pullback_Get">
		<cfreturn this />
	</cffunction>
	
	<!--- XXXXXXXXXXXX	Get Applied Brk Pullbacks for a specific Billback	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction access="public" name="GetPBApplied" returntype="Query">
		<cfargument name="Billback_Id" type="any" required="true">
		<cfif application.appSettingsGet.getBrokerage_Functionality_On()>
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetBrkPB">
				SELECT	L.BillBack_Id,
						B.BB_Code,
						B.BB_Title,
						SUM(Applied_Dollars) AS Applied_Dollars
				FROM Brk_PB_Log L
				JOIN BillBack B ON
					B.BillBack_Id = L.Billback_Id
				WHERE Applied_To_Billback_Id = '#arguments.Billback_Id#' AND
					L.Applied = 1 AND
					L.Deleted = 0
				GROUP BY 	L.BillBack_Id, 
							B.BB_Code,
							B.BB_Title
			</CFQUERY>
	 	</cfif>
	 	<cfreturn qGetBrkPB />
	</cffunction>
	
</cfcomponent>