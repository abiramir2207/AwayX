<CFSET Filter_CID_List = "">
<CFSET ApplyFilter = 0>

<CFSET FORM.FilterType 		= getPayeeInfo.Billback_Payee_Type_ID>
<CFSET FORM.FilterDataList 	= getPayeeID>
<cfif isDefined("getPayeeID.Payee_ID")>
	<cfset PayeeID = getPayeeID.Payee_ID>
<cfelse>
	<cfset PayeeID = getPayeeID>
</cfif>

	<!--- <CFIF FORM.FilterSearchPrograms NEQ 0 AND len(trim(FORM.FilterDataList)) GT 0> --->
<CFSWITCH expression="#FORM.FilterType#">
	<cfcase value="1"><!--- Distributor --->
		<cfset useLakebaseForgetPayeeFilter = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors")>
<cfif useLakebaseForgetPayeeFilter>
	<cftry>
		<cfset getPayeeFilter = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_distributors", {
				"bsa_foodservice_customers_id" = "eq.#PayeeID#",
				"deleted" = "eq.0",
				"select" = "contract_main_id"
			}), "contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPayeeFilter = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPayeeFilter>
<cfquery name="getPayeeFilter" datasource="#Application.Datasource#">
			SELECT Contract_Main_ID
			FROM Contract_Distributors
			WHERE BSA_Foodservice_Customers_ID = '#PayeeID#' AND Deleted = 0
		</cfquery>
</cfif>
		<CFIF getPayeeFilter.recordcount EQ 0>
			<CFSET Filter_CID_List = 0>
		<CFELSE>
			<CFSET Filter_CID_List = ValueList(getPayeeFilter.Contract_Main_ID)>
		</CFIF>
		<CFSET ApplyFilter = 1>
	</cfcase>
	<cfcase value="2"><!--- Operator --->
		<cfquery name="getPayeeFilter" datasource="#Application.Datasource#">
			SELECT Contract_Main_ID
			FROM Contract_Operators
			WHERE BSA_Operator_ID = '#PayeeID#' AND Deleted = 0
		</cfquery>
		<CFIF getPayeeFilter.recordcount EQ 0>
			<CFSET Filter_CID_List = 0>
		<CFELSE>
			<CFSET Filter_CID_List = ValueList(getPayeeFilter.Contract_Main_ID)>
		</CFIF>
		<CFSET ApplyFilter = 1>					
	</cfcase>
	<cfcase value="3"><!--- Broker --->
		<cfquery name="getPayeeFilter" datasource="#Application.Datasource#">
			SELECT Contract_Main_ID
			FROM Contract_Brokers
			WHERE BSA_Foodservice_Brokers_ID = '#PayeeID#' AND Deleted = 0
		</cfquery>
		<CFIF getPayeeFilter.recordcount EQ 0>
			<CFSET Filter_CID_List = 0>
		<CFELSE>
			<CFSET Filter_CID_List = ValueList(getPayeeFilter.Contract_Main_ID)>
		</CFIF>								
		<CFSET ApplyFilter = 1>
	</cfcase>
	<cfdefaultcase>
		<CFSET Filter_CID_List = 0>
		<CFSET ApplyFilter = 1>
	</cfdefaultcase>
</CFSWITCH>



<CFSET PayeeProgramIDList = Filter_CID_List>


