<CFPARAM NAME="LockChecker_CID " DEFAULT="">
<!--- test for lock --->
<CFIF len(LockChecker_CID ) GT 0>
	
	<cfset useLakebaseForgetProgramLockInformation = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetProgramLockInformation>
	<cftry>
		<cfset getProgramLockInformation = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#LockChecker_CID #",
				"select" = "contract_is_locked"
			}), "contract_is_locked"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetProgramLockInformation = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetProgramLockInformation>
<CFQUERY NAME="getProgramLockInformation" datasource="#application.datasource#">
		SELECT Contract_Is_Locked
		FROM Contract_Main
		WHERE Contract_Main_ID = '#LockChecker_CID #'
	</CFQUERY>
</cfif>

	<CFIF getProgramLockInformation.Contract_Is_Locked EQ 0>
		<CF_Cryp type="en" key="#request.key#" string="#LockChecker_CID #" return="LockCheckerData">
		<script>
			if(this.opener){
				this.opener.location.href = 'Contract_Edit_Menu.cfm?CID=<CFOUTPUT>#LockCheckerData.value#</CFOUTPUT>'
				window.close()
			}
		</script>
		<cfabort>
	</CFIF>
</CFIF>
