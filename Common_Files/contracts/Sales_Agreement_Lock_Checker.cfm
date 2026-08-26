<CFPARAM NAME="LockChecker_CID " DEFAULT="">
<!--- test for lock --->
<CFIF len(LockChecker_CID) GT 0>
	
	<CFQUERY NAME="getProgramLockInformation" datasource="#application.datasource#">
		SELECT Sales_Agreement_Is_Locked
		FROM Export_Sales_Agreement
		WHERE Export_Sales_Agreement_ID = '#LockChecker_CID#'
	</CFQUERY>

	<CFIF getProgramLockInformation.Contract_Is_Locked EQ 0>
		<CF_Cryp type="en" key="#request.key#" string="#LockChecker_CID #" return="LockCheckerData">
		<CFLOCATION URL="Sales_Agreement_Edit_Menu.cfm?CID=#LockCheckerData.value#">
	</CFIF>
</CFIF>
