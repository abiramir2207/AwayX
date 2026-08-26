<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/headers/inc_fixed_price_header_html.cfm
CREATED: 		8/10/2017 - Milan
EDITED:			

FUNCTIONALITY:
- This is the header for fixed price
Note:The crux of the code in this file is the same as "inc_rebate_header_html.cfm".
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
	FROM	##TMP_Fixed_Price_Details
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

<cfset showFixedPrice = 0>

<!--- If there are products for fixed price AND fixed price discount is ON at the letter tab of the template 
for either distributor or operator, then showFixedPrice = 1.
--->
 <cfif thisTag.stPDFBodyInfo.bDisplayFixedPrice AND thisTag.qProgramFixedPrice.recordCount 
 AND (
	(thisTag.abbreviation eq "dis" AND thisTag.stPDFBodyInfo.bDisplayFixedPriceDis)
	OR 
	(thisTag.abbreviation eq "opr" AND thisTag.stPDFBodyInfo.bDisplayFixedPriceOpr)
     )>

     <cfset showFixedPrice = 1>

</cfif>

<!--- If "fixed price" is ON for letters --->
<cfif showFixedPrice eq 1>

	<cfquery name="thisTag.qProgramFixedPriceComponents" datasource="#application.datasource#">
		SELECT 	DISTINCT(Program_Fixed_Component_ID),Program_Fixed_Component_Name,Fixed_Component_Paid_to,claim_mechanics
		FROM	##TMP_Fixed_Price_Details
		<!--- If it is an "operator" letter, check whether "Pays To" is ON for operator and/or distributor at the letter tab of the template --->
		<cfif thisTag.abbreviation eq "opr">
		WHERE Fixed_Component_Paid_to IN (<cfif ThisTag.stPDFBodyInfo.bOprPaysToOperator>2<cfelse> 0</cfif>,<cfif ThisTag.stPDFBodyInfo.bOprPaysToDistributor>1<cfelse>0</cfif>)
		<!--- If it is a "distributor" letter, check whether "Pays To" is ON for operator and/or distributor at the letter tab of the template --->
		<cfelse>
		WHERE Fixed_Component_Paid_to IN (<cfif ThisTag.stPDFBodyInfo.bDisPaysToOperator>2<cfelse> 0</cfif>,<cfif ThisTag.stPDFBodyInfo.bDisPaysToDistributor>1<cfelse>0</cfif>)
		</cfif>
		ORDER BY Program_Fixed_Component_ID,Fixed_Component_Paid_to
	</cfquery>

<cfoutput>
<table width="100%" cellspacing="0" cellpadding="0">
<!--- Add the fixed price Header --->
	
<!--- If an operator letter --->
<cfif thisTag.abbreviation eq "opr">
<!--- If "Discount Type" template setting for operators on letters is set to "Display" --->
<cfif attributes.stPDFBodyInfo.bOperatorDiscountType>
  <tr>
  		<td width="5"></td>
        <td class="darkGrayBG header_text whiteText" align="left" valign="middle" height="20"><b>#UCASE(Application.FixedPriceLabel)#<b></td>
  </tr>
</cfif>

<cfelse>

<!--- If a distributor letter --->
<!--- If "Discount Type" template setting for distributors on letters is set to "Display" --->
<cfif attributes.stPDFBodyInfo.bDistributorDiscountType>
  <tr>
  		<td width="5"></td>
        <td class="darkGrayBG header_text whiteText" align="left" valign="middle" height="20"> <b>#UCASE(Application.FixedPriceLabel)#<b></td>
  </tr>
</cfif>
</cfif>
  <tr>
    <td colspan="100%" height="7"></td>
  </tr>
</table>

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

<!--- Loop through the fixed price components --->
<cfloop query="thisTag.qProgramFixedPriceComponents">

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
		<cfif thisTag.qProgramFixedPriceComponents.Fixed_Component_Paid_to EQ 1>
		 #application.returned_customer_setting.distributor_label_singular#

		<cfelseif thisTag.qProgramFixedPriceComponents.Fixed_Component_Paid_to EQ 2>
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
	<b>Component:&nbsp;#thisTag.qProgramFixedPriceComponents.Program_Fixed_Component_Name#<b>
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
	<td width="#PriceLength#%" valign="middle" height="20" class="header_text darkGrayBG whiteText">Fixed Price/CS</td>
  </tr>
	
	<!--- Include the Fixed Price data --->
	<cfinclude template="../inc_fixed_price_html.cfm">

</cfloop>

</cfoutput>

</cfif>