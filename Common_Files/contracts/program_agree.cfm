<cf_cryp type="de" string ="#URL.CID#" key="#request.key#">
<CFSET Program_ID = cryp.value>

<cfset useLakebaseForgetprogramuseragreed = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_agree")>
<cfif useLakebaseForgetprogramuseragreed>
	<cftry>
		<cfset getprogramuseragreed = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_agree", {
				"user_id" = "eq.#request.AccessStructure.User_id#",
				"programid" = "eq.#Program_ID#",
				"select" = "user_agree"
			}), "user_agree"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetprogramuseragreed = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetprogramuseragreed>
<cfquery name="getprogramuseragreed" datasource="#application.datasource#">
	SELECT User_Agree
	FROM Program_Agree
	WHERE USER_ID = '#request.AccessStructure.User_id#'
	AND PROGRAMID = #Program_ID#
</CFQUERY>
</cfif>

<CFIF getprogramuseragreed.recordcount GT 0>
<cfset useragreed = 1>
<cfelse>
<cfset useragreed = 0>
</CFIF>