 
<CFQUERY NAME="GETUOM" datasource="#application.datasource#" cachedwithin="#CreateTimeSpan(0, 24, 0, 0)#">
	SELECT *
	FROM Units_of_Measure
</CFQUERY>

<CFQUERY NAME="GetAllContractInfo" datasource="#application.datasource#">
	SELECT *
	FROM Contract_Main
	WHERE Contract_Main_ID IN (#ValueList(ExistingTradeProgramsForTheseDistributors.HQ_Rebate_ID)#)
</CFQUERY>

<CFQUERY NAME="GetAllContractsProducts" datasource="#application.datasource#">
	SELECT * 
	FROM Contract_Products
	WHERE Contract_Main_ID IN (#ValueList(ExistingTradeProgramsForTheseDistributors.HQ_Rebate_ID)#)
</CFQUERY>

<cfquery name="getSelectedContractsBrands" datasource="#application.datasource#" blockfactor="100">
	Select DISTINCT Brand
	FROM Contract_Products
	INNER JOIN  BSA_Foodservice_items_Master 
	ON Contract_Products.Product_UPC = BSA_Foodservice_items_Master.UPC
	WHERE Contract_Products.Contract_Main_ID = #a# 
	order by brand
</cfquery>

<cfset VL = #ValueList(GetAllContractInfo.Contract_Main_ID)#>
				
<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
	SELECT dbo.BSA_Foodservice_Items_Master.*, 
	    dbo.Contract_Products.Discount_Value, 
	    dbo.Contract_Products.Pricing_Rule, 	
	    dbo.Contract_Products.Contract_Main_ID
	FROM dbo.Contract_Products INNER JOIN
	    dbo.BSA_Foodservice_Items_Master ON 
	    dbo.Contract_Products.Product_UPC = dbo.BSA_Foodservice_Items_Master.UPC
	WHERE (dbo.Contract_Products.Contract_Main_ID IN (#ExistingTradeProgramsForTheseDistributors.HQ_Rebate_ID#)) 	
</CFQUERY>

<cf_cryp type="de" string="#URL.HQR_ID#" key="#request.key#">

<cfquery name="getContractLambProducts" datasource="#application.datasource#">
	SELECT DISTINCT *
	FROM lamb_requirements, lamb_requirements_products
	WHERE lamb_requirements.HQ_Rebate_ID = #cryp.value#
	AND lamb_requirements.Program_Component_ID = lamb_requirements_products.Program_Component_ID
	AND lamb_requirements_products.Program_Component_ID = 'CONTRACT' 
	AND lamb_requirements.Assoc_Program_ID = lamb_requirements_products.Assoc_Program_ID
	AND lamb_requirements.Assoc_Dist_ID = lamb_requirements_products.Assoc_Dist_ID
	AND Right(lamb_requirements.hq_rebate_component_id, 5) = Right(lamb_requirements_products.UPC, 5)
	AND lamb_requirements.Company_Main_ID = '#request.AccessStructure.Company_Main_ID#'
	AND lamb_requirements_products.Deleted = 0
	and lamb_requirements.Deleted = 0
</cfquery>

<cfset HQRC_ID = #ValueList(getContractLambProducts.HQ_Rebate_Component_ID)#>

<cfif HQRC_ID neq ''>
	<cfquery name="getContractLambRequirements" datasource="#application.datasource#">
		SELECT DISTINCT *
		FROM lamb_requirements
		WHERE HQ_Rebate_ID = #cryp.value#
		AND HQ_Rebate_Component_ID IN (#HQRC_ID#)
		AND Company_Main_ID = '#request.AccessStructure.Company_Main_ID#'
		AND Deleted = 0
	</cfquery>
</cfif>
		
<TABLE border="0" cellspacing="0" cellpadding="0" style="margin-left: 30px;" width="90%">
	<TR>
		
		<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD align="left" width="10%"><strong>UPC Code</strong></TD></cfif></cfif>
		<TD align="left" width="40%">&nbsp;&nbsp;&nbsp;&nbsp;<strong>Description</strong></TD>
		<TD align="right">
			<CFIF GetAllContractInfo.Discount_Type_ID EQ 1>
				<strong>Fixed<br><CFOUTPUT>#Application.RebateLabel#</CFOUTPUT></strong>
			<CFELSE>
				<strong>Net<br>Price</strong>
			</CFIF>
		</TD>
		<TD><strong>&nbsp;&nbsp;&nbsp;&nbsp;Per</strong></TD>
		<td>&nbsp;</td>
		<td width="10%" align="right"><strong>AMT</strong></td>
		<td>&nbsp;</td>
		<td width="10%" align="right"><strong>ADJ</strong></td>
		<td>&nbsp;</td>
	</TR>
<CFLOOP QUERY="TheQuery">
<cfoutput>
<cfset x = #getSelectedContractsBrands.Brand#>
	<cfquery name="GetCurrentContractProducts" datasource="#application.datasource#">
		SELECT DISTINCT 
			Contract_Products.Contract_Products_ID, 
			Contract_Products.Product_UPC,
			Contract_Products.Contract_Main_ID,
			BSA_Foodservice_items_Master.*
		FROM Contract_Products
		INNER JOIN  BSA_Foodservice_items_Master 
		ON Contract_Products.Product_UPC = BSA_Foodservice_items_Master.UPC
		WHERE (Contract_Products.Contract_Main_ID = #a# 
		AND BSA_Foodservice_items_Master.brand = '#Trim(x)#')
		order by BSA_Foodservice_items_Master.brand
	</cfquery>
	
	<cf_cryp type="en" string="#trim(TheQuery.UPC)#" key="#request.key#">
	<TR ONMOUSEOVER="menuID=6;URLstring='';an_ID='#cryp.value#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;">
			<cfset product = #REPLACE(TheQuery.UPC, "-", "__", "ALL")#>
			<cfset Contract_Main_ID = #TheQuery.Contract_Main_ID#>
			<cfset This_Prod = #TheQuery.UPC#>
		
		<cfif HQRC_ID neq ''>
			<!--- Declare the array --->
			<cfset myarray=arraynew(2)>
			<!--- Populate the array row by row --->
			<cfloop query="getContractLambProducts">
			  <cfset myarray[currentrow][3]=UPC[currentrow]>
			  <cfset myarray[currentrow][4]=Assoc_Dist_ID[currentrow]>
			  <cfset myarray[currentrow][5]=Assoc_Program_ID[currentrow]>
			</cfloop>
			<!--- array upper bound --->
			<cfset total_records = #getContractLambRequirements.recordcount#>
		</cfif>
			
		<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD NOWRAP>#TheQuery.UPC#</TD></cfif></cfif>
		<TD NOWRAP>&nbsp;&nbsp;&nbsp;&nbsp;#TheQuery.Description#</TD>
			<TD ALIGN="right">
				$<CFIF len(TheQuery.Discount_Value) EQ 0>
					#trim(numberformat(0, '__.___'))#
				<CFELSE>
					#trim(numberformat(TheQuery.Discount_Value, '__.___'))#
				</CFIF>
			</TD>
			<TD>
				<CFLOOP QUERY="GETUOM"> 
					<CFSET temp = GetAllContractInfo.Contract_Quantity_UOM_IDX>
						<cfif GETUOM.Unit_Of_Measure_ID EQ temp>
							&nbsp;&nbsp;&nbsp;&nbsp;#Left(GETUOM.Unit_of_Measure_Desc, Len(GETUOM.Unit_of_Measure_Desc)-1)#
						</cfif>
				</CFLOOP>
			</TD>
		
		
		<cfif HQRC_ID neq ''>
			<!--- Declare the array --->
			<cfset myarray=arraynew(2)>
			<!--- Populate the array row by row --->
			<cfloop query="getContractLambRequirements">
			  <cfset myarray[currentrow][1]=Comp_Rate_Discount[currentrow]>
			  <cfset myarray[currentrow][2]=Comp_Rate_Delta[currentrow]>
			  <cfset myarray[currentrow][3]=HQ_Rebate_Component_ID[currentrow]>
			  <cfset myarray[currentrow][4]=Assoc_Dist_ID[currentrow]>
			  <cfset myarray[currentrow][5]=Assoc_Program_ID[currentrow]>
			</cfloop>
			<!--- array upper bound --->
			<cfset total_records = #getContractLambRequirements.recordcount#>
		 </cfif>
		 <cfset prod_num = Left(product, 5) & Right(product, 5)>
		 <cfset sub_prod = #Left(product, 5)# - #Right(product, 5)#>
		 <cfset con_Prod = #Left(product, 5)# & '-' & #Right(product, 5)#>
		
		<td>&nbsp;</td>
		
		<td width="10%" align="right">
		<cfif HQRC_ID neq ''>
			<cfif #ListContains(ValueList(getContractLambRequirements.Assoc_Dist_ID, ","), c, ",")# 
			AND #ListContains(ValueList(getContractLambRequirements.Assoc_Program_ID, ","), a, ",")# 
			AND #ListContains(ValueList(getContractLambRequirements.HQ_Rebate_Component_ID, ","), prod_num, ",")#> 
				   <cfloop index="Counter" from=1 to="#Total_Records#"><cfif #prod_num# eq #myarray[counter][3]# AND #c# eq myarray[counter][4] AND #a# eq myarray[counter][5]>&nbsp;#Trim(NumberFormat(myarray[counter][1], "__.___"))#</cfif></cfloop>
			 <cfelse>
				 <cfif len(TheQuery.Discount_Value) EQ 0>
				 	<strong>N/A</strong>
				<cfelse>
				<strong>N/A</strong>
				</cfif>
			</cfif>
		<cfelse>
				 <cfif len(TheQuery.Discount_Value) EQ 0>
				 	<strong>N/A</strong>
				<cfelse>
					<strong>N/A</strong>
				</cfif>
		</cfif>
		</td>

		<td>&nbsp;</td>

		<td width="10%" align="right">
		<cfif HQRC_ID neq ''>
			<cfif #ListContains(ValueList(getContractLambRequirements.Assoc_Dist_ID, ","), c, ",")# AND #ListContains(ValueList(getContractLambRequirements.Assoc_Program_ID, ","), a, ",")# AND #ListContains(ValueList(getContractLambRequirements.HQ_Rebate_Component_ID, ","), prod_num, ",")#>
				   <cfloop index="Counter" from=1 to="#Total_Records#"><cfif #prod_num# eq #myarray[counter][3]# AND #c# eq myarray[counter][4] AND #a# eq myarray[counter][5]>&nbsp;#Trim(NumberFormat(myarray[counter][2], "__.___"))#</cfif></cfloop>
			 <cfelse>
			 	<cfif len(TheQuery.Discount_Value) EQ 0>
					<strong>N/A</strong>
				<cfelse>
					<strong>N/A</strong>
				</cfif>   
			 </cfif>
			 <cfelse>
			 	 <cfif len(TheQuery.Discount_Value) EQ 0>
				 	<strong>N/A</strong>
				<cfelse>
					<strong>N/A</strong>
				</cfif>
			</cfif>
		</td>
	</TR>
	</cfoutput>
</CFLOOP>
<TR><TD COLSPAN="100%" ALIGN="center"></TD></TR>
</TABLE>

<INPUT TYPE="hidden" NAME="ProductCount" VALUE="<CFOUTPUT>#TheQuery.Recordcount#</CFOUTPUT>">

</BODY>
</HTML>
