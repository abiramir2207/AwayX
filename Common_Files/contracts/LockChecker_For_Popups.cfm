<CFPARAM NAME="LockChecker_CID " DEFAULT="">
<!--- test for lock --->
<CFIF len(LockChecker_CID ) GT 0>
	
	<CFQUERY NAME="getProgramLockInformation" datasource="#application.datasource#">
		SELECT Contract_Is_Locked
		FROM Contract_Main
		WHERE Contract_Main_ID = '#LockChecker_CID #'
	</CFQUERY>

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
