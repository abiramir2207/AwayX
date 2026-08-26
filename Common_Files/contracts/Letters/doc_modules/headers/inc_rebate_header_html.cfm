<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/headers/inc_rebate_header_html.cfm
CREATED: 		11/1/2011 - Milan
EDITED:			

FUNCTIONALITY:
- This is the header for Rebate.
Note:The crux of the code in this file is the same as "inc_fixed_price_header_html.cfm".
--->
</cfsilent>

<!--- This duplicate css file must be here. --->
<cfinclude template="../css/inc_all_style.cfm">

<!--- If it is a "distributor" letter AND it is "One distributor per letter" AND "Dist Product Codes (Customer Product Number)" is ON at the letter tab of the template --->
<cfset IncludeDistProdCode = 0>
<cfif thisTag.abbreviation eq "dis" AND thisTag.qGetLetterSettings.Distributor_Letter_Type eq 1 AND attributes.stPDFBodyInfo.bDistributorDistProductCodes>
  <cfset IncludeDistProdCode = 1>
</cfif>

<cfset IncludeGTIN = 0>
<!--- If it is an "operator" letter, check whether "GTIN" is ON at the letter tab of the template --->
<cfif (thisTag.abbreviation eq "opr" AND ThisTag.stPDFBodyInfo.bOperatorGTIN)
OR				
<!--- If it is a "distributor" letter, check whether "GTIN" is ON at the letter tab of the template --->
	(thisTag.abbreviation eq "dis" AND ThisTag.stPDFBodyInfo.bDistributorGTIN)>		
  <cfset IncludeGTIN = 1>
</cfif>		

<!--- Check whether Line # exists even for a single product --->
<cfquery name="qCheckLineNumber" datasource="#application.datasource#">
	SELECT 	Line_Number
	FROM	##TMP_Rebate_Price_Details
	WHERE	Line_Number IS NOT NULL
</cfquery>

<cfset IncludeLine = 0>
<!--- If Line # exists for at least one product --->
<cfif qCheckLineNumber.recordcount GT 0>
	<!--- If it is an "operator" letter, check whether "Line #" is ON at the letter tab of the template --->
	<cfif (thisTag.abbreviation eq "opr" AND attributes.stPDFBodyInfo.bOperatorLine)
	OR 
	<!--- If it is an "distributor" letter, check whether "Line #" is ON at the letter tab of the template --->
		  (thisTag.abbreviation eq "dis" AND attributes.stPDFBodyInfo.bDistributorLine)>
	  <cfset IncludeLine = 1>
	</cfif>
</cfif>

<cfset showRebate = 0>

<!--- If there are products for rebate AND rebate discount is ON at the letter tab of the template 
for either distributor or operator, then showRebate = 1.
--->
 <cfif thisTag.stPDFBodyInfo.bDisplayRebate AND thisTag.qProgramRebate.recordCount 
 AND (
	(thisTag.abbreviation eq "dis" AND thisTag.stPDFBodyInfo.bDisplayRebateDis)
	OR 
	(thisTag.abbreviation eq "opr" AND thisTag.stPDFBodyInfo.bDisplayRebateOpr)
     )>

     <cfset showRebate = 1>

</cfif>

<!--- If "rebate" is ON for letters --->
<cfif showRebate eq 1>

	<!--- If it is an "operator" letter, check whether display for "price bracket" is ON --->
	<cfif thisTag.abbreviation eq "opr">
	   <cfset bPriceBrackets = thisTag.stPDFBodyInfo.bOperatorPriceBrackets>
	<cfelse>
	<!--- If it is a "distributor" letter, check whether display for "price bracket" is ON --->
	   <cfset bPriceBrackets = thisTag.stPDFBodyInfo.bDistributorPriceBrackets>
	</cfif>

	<cfquery name="thisTag.qProgramRebateComponents" datasource="#application.datasource#">
		SELECT 	DISTINCT(Program_Rebates_Component_ID),Program_Rebates_Component_Name,Component_Paid_To,claim_mechanics
		FROM	##TMP_Rebate_Price_Details
		<!--- If it is an "operator" letter, check whether "Pays To" is ON for operator and/or distributor at the letter tab of the template --->
		<cfif thisTag.abbreviation eq "opr">
		WHERE Component_Paid_to IN (<cfif ThisTag.stPDFBodyInfo.bOprPaysToOperator>2<cfelse> 0</cfif>,<cfif ThisTag.stPDFBodyInfo.bOprPaysToDistributor>1<cfelse>0</cfif>)
		<!--- If it is a "distributor" letter, check whether "Pays To" is ON for operator and/or distributor at the letter tab of the template --->
		<cfelse>
		WHERE Component_Paid_to IN (<cfif ThisTag.stPDFBodyInfo.bDisPaysToOperator>2<cfelse> 0</cfif>,<cfif ThisTag.stPDFBodyInfo.bDisPaysToDistributor>1<cfelse>0</cfif>)
		</cfif>
		ORDER BY Program_Rebates_Component_ID,Component_Paid_to
	</cfquery>

<cfoutput>
<table width="100%" cellspacing="0" cellpadding="0">
<!--- Add the Rebate Header --->
	
<!--- If an operator letter --->
<cfif thisTag.abbreviation eq "opr">
<!--- If "Discount Type" template setting for operators on letters is set to "Display" --->
<cfif attributes.stPDFBodyInfo.bOperatorDiscountType>
  <tr>
  		<td width="5"></td>
        <td class="darkGrayBG header_text whiteText" align="left" valign="middle" height="20"><b>#UCASE(Application.RebateLabel)#<b></td>
  </tr>
</cfif>

<cfelse>

<!--- If a distributor letter --->
<!--- If "Discount Type" template setting for distributors on letters is set to "Display" --->
<cfif attributes.stPDFBodyInfo.bDistributorDiscountType>
  <tr>
  		<td width="5"></td>
        <td class="darkGrayBG header_text whiteText" align="left" valign="middle" height="20"> <b>#UCASE(Application.RebateLabel)#<b></td>
  </tr>
</cfif>
</cfif>
  <tr>
    <td colspan="100%" height="7"></td>
  </tr>
</table>

<!--- If "price bracket" is ON at the letter tab of the template, then we need to show "price bracket" columns.
      Adjust the column size, accordingly.
--->
<!--- We use the following fields to come up with a width of 100%:
IDLength + PriceLength + DescLength + LineNumberLength (If "Include Line" is ON, we use it)
+ PriceBracketLength (If "bPriceBrackets" is ON, we use it. - There are 5 columns using this. So the number is multiplied by 5.)
--->
<cfif bPriceBrackets> 
	<cfset IDLength = 14>
	<cfset PriceLength = 8> 
	<!--- If "Line #" is ON at the letter tab of the template, then we need to show "Line #" column.
      Adjust the column size, accordingly.
	--->
	<cfif IncludeLine eq 1>
		<cfset DescLength = 35>
		<cfset LineNumberLength = 8>	
		<cfset PriceBracketLength = 7><!--- For 5 columns, the total width used by these columns would be number  multiplied by 5)--->

		<!--- These two are not counted for 100% width--->
		<cfset colspan1 = 2>
		<cfset colspan2 = 7>
	<cfelse>
		<cfset DescLength = 44>
		<cfset PriceBracketLength = 7><!--- For 5 columns, the total width used by these columns would be number  multiplied by 5)--->

		<!--- These two are not counted for 100% width--->
		<cfset colspan1 = 2>
		<cfset colspan2 = 6>
	</cfif>
<cfelse> 
	<cfset IDLength = 25> 
	<cfset PriceLength = 17>
	<!--- If "Line #" is ON at the letter tab of the template, then we need to show "Line #" column.
      Adjust the column size, accordingly.
	--->
   <cfif IncludeLine eq 1>		
		<cfset DescLength = 44> 
		<cfset LineNumberLength = 16> 		
		<cfset colspan1 = 1>
		<cfset colspan2 = 3> 
	<cfelse>
		<cfset DescLength = 60> 
		<cfset colspan1 = 1>
		<cfset colspan2 = 2> 
	
	</cfif>
</cfif>


<!--- Loop through the rebate components --->
<cfloop query="thisTag.qProgramRebateComponents">

<table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tr>
	<td width="8"></td>
	<td class="darkGrayBG header_text whiteText" valign="middle" height="20" align="left" colspan="#colspan1#">
	<!--- If it is a "distributor" letter, check whether "Payable To" is ON at the letter tab of the template --->
	<cfif (	
		(thisTag.abbreviation eq "dis" AND attributes.stPDFBodyInfo.bDistributorPayableTo)
		OR
		<!--- If it is an "operator" letter, check whether "Payable To" is ON at the letter tab of the template --->	
		(thisTag.abbreviation eq "opr" AND attributes.stPDFBodyInfo.bOperatorPayableTo)
	      )>
	        <b>Pay to:<b>
		<cfif thisTag.qProgramRebateComponents.component_paid_to EQ 1>
		 #application.returned_customer_setting.distributor_label_singular#

		<cfelseif thisTag.qProgramRebateComponents.component_paid_to EQ 2>
		#application.returned_customer_setting.operator_label_singular#
		</cfif>
	<cfelse>
	&nbsp;
	</cfif>
	</td>
	
	<td class="darkGrayBG header_text whiteText" valign="middle" height="20" align="right" colspan="#colspan2#">
	<cfif (
		<!--- If it is an "operator" letter, check whether "Component Name" is ON at the letter tab of the template --->
		(thisTag.abbreviation eq "opr" AND attributes.stPDFBodyInfo.bOperatorComponentName)
	      OR
	    <!--- If it is a "distributor" letter, check whether "Component Name" is ON at the letter tab of the template --->
		(thisTag.abbreviation eq "dis" AND attributes.stPDFBodyInfo.bDistributorComponentName)
	      )
	      >
	<b>Component:&nbsp;#thisTag.qProgramRebateComponents.Program_Rebates_Component_Name#<b>
	<cfelse>
	&nbsp;
	</cfif>
	</td>
  </tr>
 
  <tr>
	<td height=".5px" class="whiteBG" colspan="100%"></td>
  </tr>
  <tr>
  	<td width="16" height="20"></td>
	<td width="#IDLength#%"  valign="middle" height="20" class="header_text darkGrayBG whiteText">
		Product ID<cfif IncludeGTIN><br />GTIN</cfif><cfif IncludeDistProdCode eq 1><br />Dist Product ID</cfif>
	</td>
	<td width="#DescLength#%" valign="middle" height="20" class="header_text darkGrayBG whiteText">Description</td>
	<cfif IncludeLine eq 1>
	<td width="#LineNumberLength#%" valign="middle" height="20" class="header_text darkGrayBG whiteText">Line ##</td>
	</cfif>
	<td width="#PriceLength#%" valign="middle" height="20" class="header_text darkGrayBG whiteText">Rebate/CS</td>
	<!--- If Price Brackets is set to "display",show Price Brackets for each item.--->
	<cfif bPriceBrackets>
	<td width="#PriceBracketLength#%" valign="middle" height="20" class="header_text darkGrayBG whiteText">Net Brkt<br /> Price 1</td>
	<td width="#PriceBracketLength#%" valign="middle" height="20" class="header_text darkGrayBG whiteText">Net Brkt<br /> Price 2</td>
	<td width="#PriceBracketLength#%" valign="middle" height="20" class="header_text darkGrayBG whiteText">Net Brkt<br /> Price 3</td>
	<td width="#PriceBracketLength#%" valign="middle" height="20" class="header_text darkGrayBG whiteText">Net Brkt<br /> Price 4</td>
	<!--- <td width="#PriceBracketLength#%" valign="middle" height="20" class="header_text darkGrayBG whiteText">Net Brkt<br /> Price 5</td> --->
	</cfif>
  </tr>
	
	<!--- Include the rebate data --->
	<cfinclude template="../inc_rebate_html.cfm">

</cfloop>

</cfoutput>

</cfif>



				   	   