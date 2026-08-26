<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
<CFSET CTLKR_Export_Sales_Agreement_Main_ID = cryp.value>

<cfset useLakebaseForCSLGetContractInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_sales_agreement")>
<cfif useLakebaseForCSLGetContractInfo>
	<cftry>
		<cfset CSLGetContractInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_sales_agreement", {
				"export_sales_agreement_id" = "eq.#CTLKR_Export_Sales_Agreement_Main_ID#",
				"select" = "*"
			}), "*"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCSLGetContractInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCSLGetContractInfo>
<CFQUERY NAME="CSLGetContractInfo" datasource="#application.datasource#">
	SELECT Export_Sales_Agreement.*
	FROM Export_Sales_Agreement
	WHERE Export_Sales_Agreement_ID = '#CTLKR_Export_Sales_Agreement_Main_ID#'
</CFQUERY>
</cfif>


<cfset useLakebaseForisContractCurrentlyLocked = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_sales_agreement")>
<cfif useLakebaseForisContractCurrentlyLocked>
	<cftry>
		<cfset isContractCurrentlyLocked = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_sales_agreement", {
				"export_sales_agreement_id" = "eq.#CTLKR_Export_Sales_Agreement_Main_ID#",
				"select" = "sales_agreement_is_locked,sales_agreement_locked_by_user_id"
			}), "sales_agreement_is_locked,sales_agreement_locked_by_user_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForisContractCurrentlyLocked = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForisContractCurrentlyLocked>
<cfquery name="isContractCurrentlyLocked" datasource="#application.datasource#">
	SELECT Sales_Agreement_Is_Locked, Sales_Agreement_Locked_By_User_ID
	FROM Export_Sales_Agreement
	WHERE Export_Sales_Agreement_ID ='#CTLKR_Export_Sales_Agreement_Main_ID#'
</cfquery>
</cfif>

<!--- UnLock that particular contract --->		
<CFIF isContractCurrentlyLocked.Sales_Agreement_Is_Locked EQ 1>
	<cfset useLakebaseForunlockContractFromOtherUsers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_sales_agreement")>
<cfif useLakebaseForunlockContractFromOtherUsers>
	<cftry>
		<cfset application.oLakebase.updateRows("export_sales_agreement",
			{
				"export_sales_agreement_id" = "eq.#CTLKR_Export_Sales_Agreement_Main_ID#"
			},
			{
				"sales_agreement_is_locked" = "0",
				"sales_agreement_locked_by_user_id" = "#request.AccessStructure.User_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForunlockContractFromOtherUsers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForunlockContractFromOtherUsers>
<CFQUERY NAME="unlockContractFromOtherUsers" datasource="#application.datasource#">
		UPDATE Export_Sales_Agreement
		Set Sales_Agreement_Is_Locked = 0
		,Sales_Agreement_Locked_By_User_ID = '#request.AccessStructure.User_ID#'
		WHERE Export_Sales_Agreement_ID = '#CTLKR_Export_Sales_Agreement_Main_ID#'
	</CFQUERY>
</cfif>
</CFIF>

<CFLOCATION url="Sales_Agreement_Edit_Menu.cfm?CID=#URL.CID#" ADDTOKEN="No">