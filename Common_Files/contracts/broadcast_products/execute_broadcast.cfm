
<CFSET THEMAINUPCLIST = "">

<CFLOOP INDEX="TheImportantFields" LIST="#FORM.FieldNames#" DELIMITERS=",">
	<CFIF listgetat(TheImportantFields, 1, "_") EQ "UPC">
		<CFIF listfind(THEMAINUPCLIST, replace(listgetat(TheImportantFields, 2, "_"), "X", "-", "ALL")) EQ 0>
			<CFSET THEMAINUPCLIST = listappend(THEMAINUPCLIST, replace(listgetat(TheImportantFields, 2, "_"), "X", "-", "ALL"))>
		</CFIF>
	</CFIF>
</CFLOOP>



<CFLOOP INDEX="ListItem" LIST="#FORM.Contract_List#" DELIMITERS=",">

	<!--- Get the contract info --->
	<cfset useLakebaseForGetContractData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetContractData>
	<cftry>
		<cfset GetContractData = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#ListItem#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetContractData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetContractData>
<CFQUERY NAME="GetContractData" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Main
		WHERE Contract_Main_ID = '#ListItem#'
	</CFQUERY>
</cfif>


	<!--- Get the contract products --->
	<cfset useLakebaseForGetContractProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForGetContractProducts>
	<cftry>
		<cfset GetContractProducts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"contract_main_id" = "eq.#ListItem#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetContractProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetContractProducts>
<CFQUERY NAME="GetContractProducts" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Products
		WHERE Contract_Main_ID = '#ListItem#'
	</CFQUERY>
</cfif>
	<!--- Save the UPC list the a list --->
	<CFSET ContractUPCList = valuelist(GetContractProducts.Product_UPC)>
	<CFSET PricingRuleList = valuelist(GetContractProducts.Pricing_Rule)>
	
	<CFLOOP LIST="#THEMAINUPCLIST#" INDEX="SpecialUPC">


		<!--- O=1 OC=1 --->
		<CFIF listfind(ContractUPCList, SpecialUPC) GT 0 AND FORM.OVERRIDE EQ 1>
			
			<CFIF listgetat(PricingRuleList,listfind(ContractUPCList, SpecialUPC)) EQ 1><cfset weightvalue = "CS"></CFIF><!--- case --->
			<CFIF listgetat(PricingRuleList,listfind(ContractUPCList, SpecialUPC)) EQ 2><cfset weightvalue = "LB"></CFIF><!--- pounds --->
			
			<CFIF GetContractData.Discount_Type_ID EQ 1><cfset DT = "RB"></CFIF><!--- rebate --->
			<CFIF GetContractData.Discount_Type_ID EQ 3 OR GetContractData.Discount_Type_ID EQ 4><cfset DT = "NP"></CFIF><!--- Net price --->

			<CFIF GetContractData.Contract_Quantity_UOM_IDX EQ 1 OR GetContractData.Contract_Quantity_UOM_IDX EQ 2>
				<CFQUERY NAME="UpdateProductData" datasource="#application.datasource#">
					UPDATE Contract_Products
					SET Discount_Value = '#evaluate("FORM.UPC_#replace(SpecialUPC, "-", "X", "ALL")#_#DT##weightvalue#")#'
					WHERE Contract_Main_ID = '#ListItem#'
					AND Product_UPC = '#SpecialUPC#'
				</CFQUERY>				
			</CFIF>
		</CFIF>
		<!--- O=1 OC=0 --->
		<CFIF listfind(ContractUPCList, SpecialUPC) EQ 0 AND FORM.OVERRIDE EQ 1>

			<CFIF GetContractData.Contract_Quantity_UOM_IDX EQ 1><cfset weightvalue = "CS"></CFIF><!--- case --->
			<CFIF GetContractData.Contract_Quantity_UOM_IDX EQ 2><cfset weightvalue = "LB"></CFIF><!--- pounds --->
			
			<CFIF GetContractData.Discount_Type_ID EQ 1><cfset DT = "RB"></CFIF><!--- rebate --->
			<CFIF GetContractData.Discount_Type_ID EQ 3 OR GetContractData.Discount_Type_ID EQ 4><cfset DT = "NP"></CFIF><!--- Net price --->

			<CFIF GetContractData.Contract_Quantity_UOM_IDX EQ 1 OR GetContractData.Contract_Quantity_UOM_IDX EQ 2>
				<CFQUERY NAME="InsertProductData" datasource="#application.datasource#">
					INSERT INTO Contract_Products
					(Product_UPC, Contract_Main_ID, Discount_Value, Pricing_Rule)
					VALUES
					('#SpecialUPC#', '#listitem#', '#evaluate("FORM.UPC_#replace(SpecialUPC, "-", "X", "ALL")#_#DT##weightvalue#")#', #GetContractData.Contract_Quantity_UOM_IDX#)
				</CFQUERY>
			</CFIF>
		</CFIF>

		<!--- O=1 OC=0 --->
		<CFIF listfind(ContractUPCList, SpecialUPC) EQ 0 AND FORM.OVERRIDE EQ 0>
			<CFIF GetContractData.Contract_Quantity_UOM_IDX EQ 1><cfset weightvalue = "CS"></CFIF><!--- case --->
			<CFIF GetContractData.Contract_Quantity_UOM_IDX EQ 2><cfset weightvalue = "LB"></CFIF><!--- pounds --->
			
			<CFIF GetContractData.Discount_Type_ID EQ 1><cfset DT = "RB"></CFIF><!--- rebate --->
			<CFIF GetContractData.Discount_Type_ID EQ 3 OR GetContractData.Discount_Type_ID EQ 4><cfset DT = "NP"></CFIF><!--- Net price --->

			<CFIF GetContractData.Contract_Quantity_UOM_IDX EQ 1 OR GetContractData.Contract_Quantity_UOM_IDX EQ 2>
				<CFQUERY NAME="InsertProductData" datasource="#application.datasource#">
					INSERT INTO Contract_Products
					(Product_UPC, Contract_Main_ID, Discount_Value, Pricing_Rule)
					VALUES
					('#SpecialUPC#', '#listitem#', '#evaluate("FORM.UPC_#replace(SpecialUPC, "-", "X", "ALL")#_#DT##weightvalue#")#', #GetContractData.Contract_Quantity_UOM_IDX#)
				</CFQUERY>
			</CFIF>
		</CFIF>
	</CFLOOP>

</CFLOOP>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>Broadcast Completed</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<BR>

<BLOCKQUOTE>

<DIV ALIGN="center" STYLE="font: larger; color: DarkBlue; font-size:16px; font-weight:Bold;">Your Broadcast Is Complete.</div>

</BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>