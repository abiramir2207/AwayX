<!------

Template Name: /deductions/Get_Lock_Status.cfm
Parameters: Deduction_ID
Output Variables: LockStatus
Usage:
<cfset Deduction_ID = what ever deduction id />
<cfinclude template="/deductions/Get_Lock_Status.cfm">
--------->

<cfparam name="fromMatchCentral" default="0" >

<cfset useLakebaseForCheckLocked = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForCheckLocked>
	<cftry>
		<cfset CheckLocked = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"select" = "is_locked,locked_by,dd_locked_by_match_central,dd_locked_by_quick_pay",
				"deduction_id" = "eq.#Deduction_ID#",
				"deleted" = "eq.0"
			}),
			"is_locked,locked_by,dd_locked_by_match_central,dd_locked_by_quick_pay"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForCheckLocked = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckLocked>
<CFQUERY NAME="CheckLocked" DATASOURCE="#Application.Datasource#">
	SELECT 	dd.Is_Locked,dd.Locked_By,u.Name_First,u.Name_Last,dd.DD_Locked_By_Match_Central, dd.DD_Locked_By_Quick_Pay
	FROM 	Deductions dd
	RIGHT OUTER JOIN _Users u
	ON dd.Locked_By = u.User_ID
	WHERE 	dd.Deduction_ID = '#Deduction_ID#'
	AND	dd.Deleted = 0
</CFQUERY>
</cfif>
<CFSET LockStatus = 0>
<CFIF (CheckLocked.Is_Locked EQ 1 AND CheckLocked.Locked_BY NEQ request.AccessStructure.User_ID) OR (fromMatchCentral EQ 0 AND CheckLocked.DD_Locked_By_Match_Central EQ 1)>
	<CFSET LockStatus = 2>
<CFELSEIF CheckLocked.Is_Locked EQ 1 AND CheckLocked.DD_Locked_By_Quick_Pay EQ 1>
		<CFSET LockStatus = 3>
<CFELSE>
	<CFIF CheckLocked.Is_Locked EQ 1 AND CheckLocked.Locked_BY EQ request.AccessStructure.User_ID>
		<CFSET LockStatus = 1>
	<CFELSE>
		<CFSET LockStatus = 0>
	</CFIF>
</CFIF>