<CFPARAM NAME="LockChecker_CID " DEFAULT="">
<!--- test for lock --->
<CFIF len(LockChecker_CID) GT 0>
	
	<cfset useLakebaseForgetProgramLockInformation = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_sales_agreement")>
<cfif useLakebaseForgetProgramLockInformation>
	<cftry>
		<cfset getProgramLockInformation = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_sales_agreement", {
				"export_sales_agreement_id" = "eq.#LockChecker_CID#",
				"select" = "sales_agreement_is_locked"
			}), "sales_agreement_is_locked"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetProgramLockInformation = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetProgramLockInformation>
<CFQUERY NAME="getProgramLockInformation" datasource="#application.datasource#">
		SELECT Sales_Agreement_Is_Locked
		FROM Export_Sales_Agreement
		WHERE Export_Sales_Agreement_ID = '#LockChecker_CID#'
	</CFQUERY>
</cfif>

	<CFIF getProgramLockInformation.Contract_Is_Locked EQ 0>
		<CF_Cryp type="en" key="#request.key#" string="#LockChecker_CID #" return="LockCheckerData">
		<CFLOCATION URL="Sales_Agreement_Edit_Menu.cfm?CID=#LockCheckerData.value#">
	</CFIF>
</CFIF>
