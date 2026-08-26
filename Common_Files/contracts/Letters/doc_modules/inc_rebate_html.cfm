<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/inc_rebate_html.cfm
CREATED: 		11/1/2011 - Milan
EDITED:	

FUNCTIONALITY:
- This include template is utilized to display the rebate data
Note:The crux of the code in this file is the same as "inc_fixed_price_html.cfm".
--->
</cfsilent>

<!--- This duplicate css file must be here. --->
<cfinclude template="css/inc_all_style.cfm">
 	 

   <cfquery name="thisTag.qGetPricing" datasource="#application.datasource#">
	SELECT 	DISTINCT *
	FROM	##TMP_Rebate_Price_Details
	WHERE	Program_Rebates_Component_ID = #thisTag.qProgramRebateComponents.Program_Rebates_Component_ID#			
	<cfif thisTag.abbreviation eq "opr">
	AND Component_Paid_to IN (<cfif ThisTag.stPDFBodyInfo.bOprPaysToOperator>2<cfelse> 0</cfif>,<cfif ThisTag.stPDFBodyInfo.bOprPaysToDistributor>1<cfelse>0</cfif>)
	<cfelse>
	AND Component_Paid_to IN (<cfif ThisTag.stPDFBodyInfo.bDisPaysToOperator>2<cfelse> 0</cfif>,<cfif ThisTag.stPDFBodyInfo.bDisPaysToDistributor>1<cfelse>0</cfif>)
	</cfif>

	<!--- If distributor letters being generated and it is "One Distributor Per Letter" --->
	<cfif thisTag.abbreviation eq "dis" AND attributes.qGetLetterSettings.Distributor_Letter_Type eq 1>
	AND BSA_Foodservice_Customers_ID = '#attributes.qProgramDistributor.BSA_FOODSERVICE_CUSTOMERS_ID#'
	
	<!--- If operator letters being generated and it is "One Distributor Per Letter"
	      Currently, the only option is "No Distributor" for operator letters.	
	 --->
	<!--- Sometimes for the operator letter "attributes.qProgramDistributor.BSA_FOODSERVICE_CUSTOMERS_ID", i.e. the distributor id is blank, even though
	      the recordset (##TMP_Rebate_Price_Details) has products repeated for multiple distributors. In that case, just get the data from TOP 1 distributor
	      as the operator data is not distributor specific data 
	--->
	<cfelseif thisTag.abbreviation eq "opr" AND attributes.qGetLetterSettings.Distributor_Letter_Type eq 1>
	AND Isnull(BSA_Foodservice_Customers_ID,0) = 
	CASE 
		WHEN BSA_Foodservice_Customers_ID IS NULL 
			THEN IsNull(BSA_Foodservice_Customers_ID,0)
	ELSE
	(
	  SELECT TOP 1 BSA_Foodservice_Customers_ID
	  FROM ##TMP_Rebate_Price_Details	  
	)
	END
	</cfif>
	<!---	Dev Note:30173 - "Group_Desc" will only be populated when we have product group on the program. In cases, when it is not populated, 
		the value will be null and the query will be ordered by the remaining fields in the ORDER BY clause.
	--->
	ORDER BY Group_Desc,description
   </cfquery>

  	  <tr>
    		<td colspan="100%" height="1"></td>
  	  </tr>
	  
	<!--- Loop through the rebate products --->
	<cfoutput query ="thisTag.qGetPricing">
	  <tr bgcolor="#iIf(thisTag.qGetPricing.currentRow MOD 2, DE('ffffff'), DE('eeeeee'))#">
	  	<!--- We do not want any background color for this cell - The color is therefore white --->
	  	<td width="8" height="20" valign="top" style="background-color:ffffff"></td>
		<td width="#IDLength#%" valign="top" height="20">#thisTag.qGetPricing.item#
			<!--- check whether "GTIN" is ON at the letter tab of the template --->
			<cfif IncludeGTIN>			  
				<br /><cfif thisTag.qGetPricing.GTIN eq "">None<cfelse>#thisTag.qGetPricing.GTIN#</cfif>
			</cfif>
			<!--- "Dist Product Codes" --->				
			<cfif IncludeDistProdCode>			  
				<br /><cfif thisTag.qGetPricing.customer_product_number eq "">None<cfelse>#thisTag.qGetPricing.customer_product_number#</cfif>
			</cfif>
		</td>
		<td width="#DescLength#%" valign="top" height="20">#thisTag.qGetPricing.description#
		<!--- If it is an "operator" letter, check the "product attribute" at the letter tab of the template --->
		<cfif thisTag.abbreviation eq "opr" AND attributes.stPDFBodyInfo.bOperatorProductAttribute_1 neq 0 AND operator_product_attribute_1 NEQ ""><br>#operator_product_attribute_1#
		<!--- If it is a "distributor" letter, check the "product attribute" at the letter tab of the template --->
		<cfelseif thisTag.abbreviation eq "dis" AND attributes.stPDFBodyInfo.bDistributorProductAttribute_1 neq 0 AND distributor_product_attribute_1 neq ""><br>#distributor_product_attribute_1#
		</cfif>
		<cfif IncludeLine eq 1>
		<td width="#LineNumberLength#%" valign="top" height="20" nowrap>#thisTag.qGetPricing.Line_Number#</td>
		</cfif>
		<td width="#PriceLength#%" valign="top" height="20" nowrap> <cfif NOT thisTag.qGetPricing.recordCount>&nbsp;<cfelse>$#numberFormat(thisTag.qGetPricing.rebate_price_per_case,"_99.99")#</cfif></td>
				
		<!--- If Price Brackets is set to "display",show Price Brackets for each item.--->
		<cfif bPriceBrackets>
		<!--- Bracket price MINUS rebate is the Bracket price for display --->
		<td width="6%" valign="top" height="20" nowrap><cfif CS_Bracket_1 neq "">$#numberFormat(CS_Bracket_1 - thisTag.qGetPricing.rebate_price_per_case,"_9.99")#<cfelse>&nbsp;</cfif></td>
		<td width="6%" valign="top" height="20" nowrap><cfif CS_Bracket_2 neq "">$#numberFormat(CS_Bracket_2 - thisTag.qGetPricing.rebate_price_per_case,"_9.99")#<cfelse>&nbsp;</cfif></td>
		<td width="6%" valign="top" height="20" nowrap><cfif CS_Bracket_3 neq "">$#numberFormat(CS_Bracket_3 - thisTag.qGetPricing.rebate_price_per_case,"_9.99")#<cfelse>&nbsp;</cfif></td>
		<td width="6%" valign="top" height="20" nowrap><cfif CS_Bracket_4 neq "">$#numberFormat(CS_Bracket_4 - thisTag.qGetPricing.rebate_price_per_case,"_9.99")#<cfelse>&nbsp;</cfif></td>
		<!--- <td width="6%" valign="top" height="20" nowrap><cfif CS_Bracket_5 neq "">$#numberFormat(CS_Bracket_5 - thisTag.qGetPricing.rebate_price_per_case,"_9.99")#<cfelse>&nbsp;</cfif></td> --->
		</cfif>
	  </tr>
	  <tr bgcolor="#iIf(thisTag.qGetPricing.currentRow MOD 2, DE('ffffff'), DE('eeeeee'))#">
	  	<td width="8" height="3" style="background-color:ffffff"></td>
		<cfif bPriceBrackets>
	  		<td colspan="8" height="3"></td>
		<cfelse>
			<td colspan="3" height="3"></td>
		</cfif>
	  </tr>
	 </cfoutput>
	</table>