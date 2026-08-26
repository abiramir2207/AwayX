
<tr><td colspan="100%">
<cfparam name="OperatorList" default="">
<!---Have operator picked--->
<cfif url.Operator NEQ 0>
	<cfset OperatorList = url.Operator>
<!---No operator, but am a distributor--->
<cfelseif url.Operator EQ 0 AND url.Distributor_ID IS NOT "">
	<cfset OperatorList = AllOperators>
<!---Am an operator, have a county picked--->
<cfelseif url.Operator EQ 0 AND url.County NEQ 0>
	<cfset useLakebaseForGetOpsForCounty = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("usdanoi_operators_no_claims")>
<cfif useLakebaseForGetOpsForCounty>
	<cftry>
		<cfset GetOpsForCounty = application.oLakebase.toQuery(
			application.oLakebase.selectRows("usdanoi_operators_no_claims", {
				"countyfips" = "eq.#url.County#",
				"select" = "bsa_operator_id"
			}), "bsa_operator_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetOpsForCounty = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetOpsForCounty>
<cfquery name="GetOpsForCounty" datasource="#application.datasource#">
	SELECT BSA_Operator_ID 
	FROM USDANOI_Operators_No_Claims
	WHERE CountyFIPS = '#url.County#'
	</cfquery>
</cfif>
	<cfset OperatorList = valuelist(GetOpsForCounty.BSA_Operator_ID)>
<!---Am an operator, have a state picked--->
<cfelseif url.County EQ 0 AND url.Operator EQ 0  AND url.State NEQ 0>
	<cfset useLakebaseForGetOpsForState = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("usdanoi_operators_no_claims")>
<cfif useLakebaseForGetOpsForState>
	<cftry>
		<cfset GetOpsForState = application.oLakebase.toQuery(
			application.oLakebase.selectRows("usdanoi_operators_no_claims", {
				"statefips" = "eq.#url.State#",
				"select" = "bsa_operator_id"
			}), "bsa_operator_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetOpsForState = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetOpsForState>
<cfquery name="GetOpsForState" datasource="#application.datasource#">
	SELECT BSA_Operator_ID 
	FROM USDANOI_Operators_No_Claims
	WHERE StateFIPS = '#url.State#'
	</cfquery>
</cfif>
	<cfset OperatorList = valuelist(GetOpsForState.BSA_Operator_ID)>
<!---Should never happen--->
<cfelseif len(trim(AllOperators)) GT 0>
	<cfset OperatorList = AllOperators>
<cfelse>
	You must select at least a state for which to run the report. <A href="search.cfm">Click here></A> to return to the report selection screen.
	
	<cfabort>
</cfif>

<cfif OperatorList IS "">
There is no data for this report. <A href="search.cfm"Click here></A> to return to the report selection screen.
<cfelse>
<cfsilent>
<cfquery name="QueryWithoutBillbacks" datasource="#application.datasource#">
SELECT DISTINCT BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.Description, 
	BSA_Operator.Operator_Name,BSA_Operator.legacy_id,
	ISNULL(dbo.getItemPTV_CS(Contract_Products.BSA_Foodservice_Items_Master_ID),0) AS PTV_Case,
	ISNULL(dbo.getItemPTV_LB(Contract_Products.BSA_Foodservice_Items_Master_ID),0) AS PTV_Pound,
	ISNULL(dbo.getItemPTV_RM(Contract_Products.BSA_Foodservice_Items_Master_ID),0) AS PTV_RM, 
	ISNULL(dbo.getItemTotalProgramVolume_CS(Contract_Products.BSA_Foodservice_Items_Master_ID, Contract_Main.Contract_Main_ID),0) AS BegBal_CS, 
	ISNULL(dbo.getItemTotalProgramVolume_LB(Contract_Products.BSA_Foodservice_Items_Master_ID, Contract_Main.Contract_Main_ID),0) AS BegBal_LB, 
	ISNULL(dbo.getItemTotalProgramVolume_RM(Contract_Products.BSA_Foodservice_Items_Master_ID, Contract_Main.Contract_Main_ID),0) AS BegBal_RM,
	ISNULL(Contract_Main.contract_quantity,0) as contract_quantity
FROM BSA_Operator
	INNER JOIN Contract_Operators
	ON Contract_Operators.BSA_Operator_ID = BSA_Operator.BSA_Operator_ID
	AND Contract_Operators.Deleted = 0
	INNER JOIN Contract_Main 
	ON Contract_Operators.Contract_Main_ID = Contract_Main.Contract_Main_ID
	AND Contract_Main.Deleted = 0
	<cfif url.Distributor NEQ 0>
	INNER JOIN Contract_Distributors on
	Contract_Distributors.Contract_Main_id = Contract_Main.Contract_Main_id
	and Contract_Distributors.deleted = 0
	</cfif>
	INNER JOIN Contract_Products
	ON Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
	AND Contract_Products.Deleted = 0
	INNER JOIN BSA_Foodservice_Items_Master
	ON Contract_Products.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
	AND Contract_Products.Deleted = 0
	INNER JOIN Program_Rebates_Component
	ON Program_Rebates_Component.Program_ID = Contract_Products.Contract_Main_ID
	AND Program_Rebates_Component.Deleted = 0
	INNER JOIN Program_Rebates_Component_Name
	ON Program_Rebates_Component.Program_Rebates_Component_Name_ID = Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
	AND Program_Rebates_Component_Name.Is_USDA_NOI_Comp = 1
WHERE Contract_Main.Deleted = 0
AND Contract_Main.Contract_Main_ID IN (SELECT Program_ID FROM USDANOI_Programs_Approved)
AND Contract_Main.Contract_Status_Type_IDX >= 3
AND Contract_Main.Contract_Status_Type_IDX != 7
AND BSA_Operator.Deleted = 0
AND BSA_Operator.BSA_Operator_ID IN (#OperatorList#)
<cfif url.Distributor NEQ 0>
and Contract_Distributors.BSA_Foodservice_Customers_id = '#url.Distributor#'
</cfif>
ORDER BY Operator_Name, Item
</cfquery>
</cfsilent>
<table border="0" cellpadding="3" cellspacing="0" style="width: 90%" align="right">
<cfoutput>
	<!---UOM--->
	<tr >
		<td bgcolor="##FFFFFF" colspan="2">&nbsp;</td>
		<td colspan="3" bgcolor="##FFFFFF" >
		<p align="center"><b>Measured in <cfswitch expression="#form.thisReportUOM#">
											<!--- case --->
											<cfcase value="1">Cases</cfcase>
											<cfcase value="2">Net Pounds</cfcase>
											<cfcase value="rm">Raw Materials</cfcase>
		</cfswitch></b></td>
		
	</tr>
	
	<!---Header--->
	
	<tr  >
		<td bgcolor="##FFFFFF"  nowrap align="center">
		<b>Item ##</b></td>
		<td bgcolor="##FFFFFF" nowrap  align="center">
		<b>Item Description</b></td>
		<td bgcolor="##FFFFFF" nowrap title="pass through value" align="right">
		<b>Pass Through Value</b></td>
		<td  align="right"><strong>Allocation</strong></td>
		<td bgcolor="##FFFFFF" nowrap align="right"  align="center">
		<b>Value Available</b></td>
		
	</tr>
</cfoutput>

<cfoutput query="QueryWithoutBillbacks" group="Operator_Name">
<cfsilent>
<cfswitch expression="#form.thisReportUOM#">
		<!--- case --->
		<cfcase value="1">
			<cfset PTV = PTV_Case>
			<cfset BegBal = BegBal_CS>
			<cfset ValueAvailable = PTV_Case * BegBal_CS>
		</cfcase>
		<cfcase value="2">
			<cfset PTV = PTV_Pound>
			<cfset BegBal = contract_quantity>
			<cfset ValueAvailable = BegBal * PTV>
		</cfcase>
		<cfcase value="rm">
			<cfset PTV = PTV_RM>
			<cfset BegBal = contract_quantity/0.55>
			<cfset ValueAvailable = BegBal * PTV>
		</cfcase>
	</cfswitch>
	</cfsilent>
<tr bgcolor="##ffffcc">
<td colspan="3"><FONT FACE="Arial" size="3"><b>#Operator_Name# - #legacy_id#</b></FONT></td>
<td align="right">&nbsp;  #trim(NumberFormat(BegBal, '-___,___,___,___,___'))#lbs</td>
<td align="right">#lscurrencyformat(ValueAvailable)#</td></tr>
<tr><td colspan="5"><hr color="Navy"></td></tr>
	<cfoutput>
	<tr  bgcolor="<CFIF CurrentRow mod 2>##CCFFCC<CFELSE>WhiteSmoke</CFIF>">
		<td >#Item#</td>
		<td>#Description#</td>
		<td align="right">$#numberformat(PTV, '___,___,___.____')#</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	
	</cfoutput>
			<tr bgcolor="lightsteelblue" border="1">
					<td align="left" colspan="3">&nbsp; <b>Total Allocation</b></td>
					<td align="right">&nbsp;  #trim(NumberFormat(BegBal, '-___,___,___,___,___'))#lbs</td>
					<td align="right">#lscurrencyformat(ValueAvailable)#</td>
				</tr>
			<tr><td>&nbsp;</td></tr>
</cfoutput>
</table>
<!---There is a list of operators--->
</cfif>
	</td></tr>