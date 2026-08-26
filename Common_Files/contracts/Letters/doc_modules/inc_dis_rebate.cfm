<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/inc_dis_rebate.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			04/10/2008 - RBL
EDITED:			08/16/2010 - Milan [Convert to Itext in Java]
EDITED:			09/15/2010 - Milan [Add template setting to show/hide info on the letter]

FUNCTIONALITY:
- This include template is utilized to display the "Distributor Rebate" module within the Deal Letters v2...
--->
</cfsilent>
<!--- 3.) Rebates [begin] --->
<!--- ACTION: Is this duplicitious? same Q's are asked when calling this template --->
<cfif thisTag.stPDFBodyInfo.bDisplayRebate AND thisTag.qProgramRebate.recordCount AND thisTag.stPDFBodyInfo.bDisplayRebateDis>
<!--- IMPORTANT: RBL reluctantly did this. We can not use nested grouping
[1 group="item" groupcasesensitive="no" AND 2 group="Program_Rebates_Component_ID"]
here since we are combining horizontal and vertical output and if we have an edited letter,
some row level data may no longer be present if turned off, so... --->
<cfquery name="thisTag.qProgramRebateItems" datasource="#application.datasource#">
SELECT 	DISTINCT(item),BSA_Foodservice_Items_Master_ID,GTIN,description,Line_Number,Net_Weight<cfif thisTag.bAddcustomerproductnumbers>,customer_product_number</cfif>
<cfif attributes.stPDFBodyInfo.bDistributorProductAttribute_1 neq 0>,distributor_product_attribute_1</cfif>
FROM	##TMP_Rebate_Price_Details
WHERE Component_Paid_to IN (<cfif ThisTag.stPDFBodyInfo.bDisPaysToOperator>2<cfelse> 0</cfif>,<cfif ThisTag.stPDFBodyInfo.bDisPaysToDistributor>1<cfelse>0</cfif>)

<cfif attributes.qGetLetterSettings.Distributor_Letter_Type eq 1>
 AND BSA_Foodservice_Customers_ID = '#attributes.qProgramDistributor.BSA_FOODSERVICE_CUSTOMERS_ID#'
</cfif>

ORDER BY item
</cfquery>

<!--- Let's group by ITEM ... --->
<cfoutput query="thisTag.qProgramRebateItems">
															
<!--- Add rebate data here --->
<!--- LINE NUMBER --->
<!--- Column 1 --->
<cfif attributes.stPDFBodyInfo.bDistributorLine>
  <cfset LineNumber = PdfPCell.init(phrase.init("#thisTag.qProgramRebateItems.Line_Number#", GothicNormal_font_Bold_Black_Eight))>
  <cfset LineNumber.setColspan( javacast("int", 1) )>
  <cfset LineNumber.setBorder(Rectangle.NO_BORDER)>

    <!--- Alternate coloring --->
  <cfif thisTag.qProgramRebateItems.currentRow MOD 2 eq 1>
    <cfset LineNumber.setBackgroundColor(textColorWhite)>
  <cfelse>
    <cfset LineNumber.setBackgroundColor(textColorLightGray)>
  </cfif>

  <cfset table_dis_Rebate.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
  <cfset table_dis_Rebate.addCell(LineNumber)>
</cfif>

<!--- ITEM AND ITEM DESCRIPTION --->
<!--- Column 2 --->
<cfif attributes.stPDFBodyInfo.bDistributorProductAttribute_1 neq 0>
 <cfset Item_Number_And_Description = PdfPCell.init(phrase.init("#thisTag.qProgramRebateItems.item#" & chr(13) & chr(10) & "#thisTag.qProgramRebateItems.description#"  & chr(13) & chr(10) & "#thisTag.qProgramRebateItems.distributor_product_attribute_1#", GothicNormal_font_Bold_Black_Eight))>
<cfelse>
<cfset Item_Number_And_Description = PdfPCell.init(phrase.init("#thisTag.qProgramRebateItems.item#" & chr(13) & chr(10) & "#thisTag.qProgramRebateItems.description#", GothicNormal_font_Bold_Black_Eight))>
</cfif>

<cfset Item_Number_And_Description.setColspan( javacast("int", 1) )>
<cfset Item_Number_And_Description.setBorder(Rectangle.NO_BORDER)>

<!--- Alternate coloring --->
<cfif thisTag.qProgramRebateItems.currentRow MOD 2 eq 1>
<cfset Item_Number_And_Description.setBackgroundColor(textColorWhite)>
<cfelse>
<cfset Item_Number_And_Description.setBackgroundColor(textColorLightGray)>
</cfif>

<cfset table_dis_Rebate.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
<cfset table_dis_Rebate.addCell(Item_Number_And_Description)>

<!--- GTIN AND DISTRIBUTOR PRODUCT NUMBER --->
<!--- Column 3 --->
<!--- Check whether bAddcustomerproductnumbers AND show distributor GTIN is ON --->
<cfif thisTag.bAddcustomerproductnumbers AND attributes.stPDFBodyInfo.bDistributorGTIN>
  <cfif isDefined("thisTag.qProgramRebateItems.customer_product_number") AND thisTag.qProgramRebateItems.customer_product_number NEQ "na" AND len(trim(thisTag.qProgramRebateItems.customer_product_number))>
	<cfset Cust_Prod_Number_And_GTIN = PdfPCell.init(phrase.init("#thisTag.qProgramRebateItems.customer_product_number#"  & chr(13) & chr(10) & "#thisTag.qProgramRebateItems.GTIN#", GothicNormal_font_Bold_Black_Eight))>
  <cfelse>
        <cfif thisTag.qProgramRebateItems.GTIN NEQ "">
	  <cfset Cust_Prod_Number_And_GTIN = PdfPCell.init(phrase.init(chr(13) & chr(10) & "#thisTag.qProgramRebateItems.GTIN#", GothicNormal_font_Bold_Black_Eight))>
	<cfelse>
	  <cfset Cust_Prod_Number_And_GTIN = PdfPCell.init(phrase.init("", GothicNormal_font_Bold_Black_Eight))>
	</cfif>
  </cfif>

<!--- Only bAddcustomerproductnumbers is ON --->
<cfelseif thisTag.bAddcustomerproductnumbers>

  <cfif isDefined("thisTag.qProgramRebateItems.customer_product_number") AND thisTag.qProgramRebateItems.customer_product_number NEQ "na" AND len(trim(thisTag.qProgramRebateItems.customer_product_number))>
	<cfset Cust_Prod_Number_And_GTIN = PdfPCell.init(phrase.init("#thisTag.qProgramRebateItems.customer_product_number#", GothicNormal_font_Bold_Black_Eight))>
  <cfelse>
	<cfset Cust_Prod_Number_And_GTIN = PdfPCell.init(phrase.init(""))>		
  </cfif>

<!--- Only  show distributor GTIN  is ON --->
<cfelseif attributes.stPDFBodyInfo.bDistributorGTIN>

  <cfif thisTag.qProgramRebateItems.GTIN neq "">
	<cfset Cust_Prod_Number_And_GTIN = PdfPCell.init(phrase.init("#thisTag.qProgramRebateItems.GTIN#", GothicNormal_font_Bold_Black_Eight))>
  <cfelse>
	<cfset Cust_Prod_Number_And_GTIN = PdfPCell.init(phrase.init(""))>		
  </cfif>

</cfif>

<!--- If bAddcustomerproductnumbers OR show distributor GTIN is ON --->
<cfif thisTag.bAddcustomerproductnumbers OR attributes.stPDFBodyInfo.bDistributorGTIN>
  <cfset Cust_Prod_Number_And_GTIN.setColspan( javacast("int", 1) )>
  <cfset Cust_Prod_Number_And_GTIN.setBorder(Rectangle.NO_BORDER)>

  <!--- Alternate coloring --->
  <cfif thisTag.qProgramRebateItems.currentRow MOD 2 eq 1>
    <cfset Cust_Prod_Number_And_GTIN.setBackgroundColor(textColorWhite)>
  <cfelse>
    <cfset Cust_Prod_Number_And_GTIN.setBackgroundColor(textColorLightGray)>
  </cfif>

  <cfset table_dis_Rebate.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
  <cfset table_dis_Rebate.addCell(Cust_Prod_Number_And_GTIN)>
</cfif>

<!--- NET WEIGHT --->
<!--- Column 4 --->
<cfif attributes.stPDFBodyInfo.bDistributorProductNetWeight >
  <cfset NetWeight = PdfPCell.init(phrase.init("#thisTag.qProgramRebateItems.Net_Weight#", GothicNormal_font_Bold_Black_Eight))>
  <cfset NetWeight.setColspan( javacast("int", 1) )>
  <cfset NetWeight.setBorder(Rectangle.NO_BORDER)>

  <!--- Alternate coloring --->
  <cfif thisTag.qProgramRebateItems.currentRow MOD 2 eq 1>
    <cfset NetWeight.setBackgroundColor(textColorWhite)>
  <cfelse>
    <cfset NetWeight.setBackgroundColor(textColorLightGray)>
  </cfif>

  <cfset table_dis_Rebate.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
  <cfset table_dis_Rebate.addCell(NetWeight)>
</cfif>

<!--- Additional columns (Components) --->
<!--- Let's group by COMPONENT ID ... --->
<cfloop query="thisTag.qProgramRebateComponents">
<!--- IF a user deleted a component for a single item, we need to throw a placeholder in here... --->
<cfquery name="thisTag.qGetPricing" datasource="#application.datasource#">
SELECT 	*
FROM	##TMP_Rebate_Price_Details
WHERE	Program_Rebates_Component_ID = #thisTag.qProgramRebateComponents.Program_Rebates_Component_ID#	
AND Component_Paid_to IN (<cfif ThisTag.stPDFBodyInfo.bDisPaysToOperator>2<cfelse> 0</cfif>,<cfif ThisTag.stPDFBodyInfo.bDisPaysToDistributor>1<cfelse>0</cfif>)
<!--- Need to query based on "BSA_Foodservice_Items_Master_ID", so that we can details for groups too. If we query on "item" instead, 
groups will not return any record, as items are blank in groups.
--->
AND BSA_Foodservice_Items_Master_ID = '#thisTag.qProgramRebateItems.BSA_Foodservice_Items_Master_ID#'
</cfquery>

<cfif NOT thisTag.qGetPricing.recordCount>
		<cfset RebatePerPound = PdfPCell.init(phrase.init(""))>
		<cfset RebatePerPound.setColspan( javacast("int", 1) )>
		<cfset RebatePerPound.setBorder(Rectangle.NO_BORDER)>
		
		<!--- Alternate coloring --->
		<cfif thisTag.qProgramRebateItems.currentRow MOD 2 eq 1>
			<cfset RebatePerPound.setBackgroundColor(textColorWhite)>
		<cfelse>
			<cfset RebatePerPound.setBackgroundColor(textColorLightGray)>
		</cfif>

		<cfset table_dis_Rebate.addCell(RebatePerPound)>
<cfelse>
	  <!---30303 - if rebate percent exists print the % value & symbol--->
		<cfif thisTag.qGetPricing.rebate_price_percent[1] neq "">
			<cfset RebatePerPound = PdfPCell.init(phrase.init("#numberFormat(thisTag.qGetPricing.rebate_price_percent[1],'_99.99')# %", GothicNormal_font_Bold_Black_Eight))>
		<!--- If "UOM" template setting for distributors on letters is set to "CS"
		Dev Note: (66548) - The UOM" template setting is for products only and not for groups. For groups, we need to show what is on the program (Whether it is CS or LB).
		Groups have a default weight of 1 and so we cannot convert from one UOM to another.		
		--->
		<cfelseif (attributes.stPDFBodyInfo.bDistributorUOM eq 1 AND thisTag.qGetPricing.Is_Group eq 0) OR (thisTag.qGetPricing.Is_Group eq 1 AND thisTag.qGetPricing.Unit_Of_measure_ID eq 1)>
			<cfset RebatePerPound = PdfPCell.init(phrase.init("$#numberFormat(thisTag.qGetPricing.rebate_price_per_case[1],'_99.99')#/CS", GothicNormal_font_Bold_Black_Eight))>
		<!--- If "UOM" template setting for distributors on letters is set to "LB" 
		Dev Note: (66548) - The UOM" template setting is for products only and not for groups. For groups, we need to show what is on the program (Whether it is CS or LB).
		Groups have a default weight of 1 and so we cannot convert from one UOM to another.		
		--->
		<cfelseif (attributes.stPDFBodyInfo.bDistributorUOM eq 2 AND thisTag.qGetPricing.Is_Group eq 0) OR (thisTag.qGetPricing.Is_Group eq 1 AND thisTag.qGetPricing.Unit_Of_measure_ID eq 2)>
			<cfset RebatePerPound = PdfPCell.init(phrase.init("$#numberFormat(thisTag.qGetPricing.rebate_price_per_pound[1],'_9.9999')#/LB", GothicNormal_font_Bold_Black_Eight))>
		<!--- If "UOM" template setting for distributors on letters is set to "per hundred weight (CWT)" --->
		<cfelseif (attributes.stPDFBodyInfo.bDistributorUOM eq 4 AND thisTag.qGetPricing.Is_Group eq 0) OR (thisTag.qGetPricing.Is_Group eq 1 AND thisTag.qGetPricing.Unit_Of_measure_ID eq 4)>
			<cfset RebatePerPound = PdfPCell.init(phrase.init("$#numberFormat(thisTag.qGetPricing.rebate_price_per_hundred_weight[1],'_9.9999')#/CWT", GothicNormal_font_Bold_Black_Eight))>	
		<!--- If "UOM" template setting for distributors on letters is set to "Program UOM" --->
		<cfelseif (attributes.stPDFBodyInfo.bDistributorUOM eq 5 AND thisTag.qGetPricing.Is_Group eq 0) OR (thisTag.qGetPricing.Is_Group eq 1 AND thisTag.qGetPricing.Unit_Of_measure_ID eq 5)>
			<!--- If the product UOM is "CS", show the rate in 2 decimal places --->
			<cfif thisTag.qGetPricing.Unit_Of_measure_ID eq 1>
				<cfset RebatePerPound = PdfPCell.init(phrase.init("$#numberFormat(thisTag.qGetPricing.rate[1],'_99.99')#/#thisTag.qGetPricing.Abbreviation_Singular#", GothicNormal_font_Bold_Black_Eight))>
			<!--- If the product UOM is NOT "CS", show the rate in 4 decimal places --->
			<cfelse>
				<cfset RebatePerPound = PdfPCell.init(phrase.init("$#numberFormat(thisTag.qGetPricing.rate[1],'_9.9999')#/#thisTag.qGetPricing.Abbreviation_Singular#", GothicNormal_font_Bold_Black_Eight))>
			</cfif>
		<!--- If "UOM" template setting for distributors on letters is set to "BOTH" --->
		<cfelse>
			<cfset RebatePerPound = PdfPCell.init(phrase.init("$#numberFormat(thisTag.qGetPricing.rebate_price_per_pound[1],'_9.9999')#/LB" & chr(13) & chr(10) & "$#numberFormat(thisTag.qGetPricing.rebate_price_per_case[1],'_99.99')#/CS", GothicNormal_font_Bold_Black_Eight))>
		</cfif>	
			<cfset RebatePerPound.setColspan( javacast("int", 1) )>
			<cfset RebatePerPound.setBorder(Rectangle.NO_BORDER)>
		
		<!--- Alternate coloring --->
		<cfif thisTag.qProgramRebateItems.currentRow MOD 2 eq 1>
			<cfset RebatePerPound.setBackgroundColor(textColorWhite)>
		<cfelse>
			<cfset RebatePerPound.setBackgroundColor(textColorLightGray)>
		</cfif>

		<cfset RebatePerPound.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT)>
		<cfset table_dis_Rebate.addCell(RebatePerPound)>
</cfif>
</cfloop>    
	<!--- Add table_dis_Rebate tabkle to the pdf document --->												
	<cfset document.add(table_dis_Rebate)>
</cfoutput>
 <cfoutput>

<!--- If we have "bAddcustomerproductnumbers" turned ON, and bDistributorGTIN turned Off. bDistributorGTIN should be turned off because when it is turned ON, we already add a column 
using colpan = 2 below in the code 
--->
<cfif thisTag.bAddcustomerproductnumbers AND attributes.stPDFBodyInfo.bDistributorGTIN eq 0>
	<cfset BlankCell = PdfPCell.init(phrase.init(""))>
	<cfset BlankCell.setColspan( javacast("int", 1) )>
	<cfset BlankCell.setBorder(Rectangle.NO_BORDER)>
	<!--- Add a blank cell --->
	<cfset table_dis_Rebate.addCell(BlankCell)>           
</cfif>    

												
  <!--- Totals by Program --->
  <!--- ACTION: TO DELETE <h3 class="redText">Component Type: #Application.RebateLabel#</h3> --->
													
<!--- COMPONENT INFO HEADERS --->

<cfset Heading_Details = "">

<!--- Add "Component Name" Info--->
<!--- If "Component Name" template setting for distributors on letters is set to "Display" --->
<cfif attributes.stPDFBodyInfo.bDistributorComponentName>
	<cfset Heading_Details = Heading_Details & "Component Name: " & chr(13) & chr(10)>
</cfif>

    <!--- ::::::: 1.) PaymentFrequency ::::::: --->
    <!---1.)  IF payment cycle @ program level... --->
   <!--- If "Payment Frequency" template setting for distributors on letters is set to "Display" --->
   <cfif attributes.stPDFBodyInfo.bDistributorPaymentFrequency>
    <cfif NOT application.appsettingsget.paymentCycleAtDiscountType>

	<cfset Heading_Details = Heading_Details & "Payment Frequency: #thisTag.stPDFIntroInfo.program_payment_frequency#"  & chr(13) & chr(10)>
    <cfelse>
	<cfset Heading_Details = Heading_Details & "Payment Frequency: "  & chr(13) & chr(10)>
    </cfif>
   </cfif>
														
    <!--- ::::::: 2 PricingType ::::::: Always @ Program Level --->
    <!--- ACTION: TO DELETE Pricing Type: #thisTag.stPDFIntroInfo.program_pricing_type#
    <br /> --->
    <!--- ::::::: 3 ClaimMechanism ::::::: --->
    <!--- 3.) IF claims @ program level... --->
    <cfif NOT application.appsettingsget.claims_at_comp_level>
      <cfquery name="thisTag.qGetRebateClaimMechanism" datasource="#application.datasource#">
	SELECT 		TOP 1 Payment_Type.Payment_Type_Name
	FROM			Payment_Type,Program_Rebates_Component
	WHERE 		Program_Rebates_Component.Claim_Mechanics = Payment_Type.Payment_Type_id
	AND				Program_Rebates_Component.Program_id = #thisTag.CMID#
      </cfquery>

      <!--- If "Claim Mechanism" template setting for distributor on letters is set to "Display" --->
     <cfif attributes.stPDFBodyInfo.bDistributorClaimMechanism>
      <cfif thisTag.qGetRebateClaimMechanism.recordCount>
	<cfset thisTag.program_rebate_claim_mechanism = thisTag.qGetRebateClaimMechanism.Payment_Type_Name[1]>
      <cfelse>
	<cfset thisTag.program_rebate_claim_mechanism = "">
      </cfif>

	<cfset Heading_Details = Heading_Details & "Claim Mechanism: #thisTag.program_rebate_claim_mechanism#"  & chr(13) & chr(10)>
     </cfif>

   <!--- if "claims_at_comp_level" app setting is ON --->
   <cfelse>
<!--- If "Claim Mechanism" template setting for distributor on letters is set to "Display" --->
	<cfif attributes.stPDFBodyInfo.bDistributorClaimMechanism>
		<cfset Heading_Details = Heading_Details & "Claim Mechanism: "  & chr(13) & chr(10)>
	</cfif>
</cfif>

<!--- If "Payable To" template setting for distributor on letters is set to "Display" --->
	<cfif attributes.stPDFBodyInfo.bDistributorPayableTo>
		<cfset Heading_Details = Heading_Details & "Paid To: ">
	</cfif>

<!--- If there is at least one component related info to display --->
<cfif Heading_Details neq "">
	<cfset Heading_Details_Header = PdfPCell.init(phrase.init(Heading_Details, GothicBold_Font_Bold_Brown_Eight))>
   <cfif attributes.stPDFBodyInfo.bDistributorGTIN>
	<cfset Heading_Details_Header.setColspan( javacast("int", 2) )>
   <cfelse>
	<cfset Heading_Details_Header.setColspan( javacast("int", 1) )>
   </cfif>
	<cfset Heading_Details_Header.setBorder(Rectangle.NO_BORDER)>

	<cfset Heading_Details_Header.setHorizontalAlignment(PdfPCell.LEFT)>
	<cfset table_dis_Rebate.addCell(Heading_Details_Header)>
</cfif>

</cfoutput>

<!--- Let's group by component_name... Totals by Component --->

<!--- COMPONENT INFO DETAILS --->
<cfoutput query="thisTag.qProgramRebateComponents">
<cfsilent>
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::: Identify Header Values [begin] ::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

<!--- ::::::: 1.) PaymentFrequency ::::::: --->

<!--- 1.) IF payment cycle @ component level... --->
<cfif application.appsettingsget.paymentCycleAtDiscountType>

  <cfquery name="thisTag.qGetRebatePaymentFrequency" datasource="#application.datasource#">
      SELECT	Payment_Cycle.Payment_Cycle
      FROM	Program_Payment_Cycle,Payment_Cycle
      WHERE	Program_Payment_Cycle.Program_ID = #thisTag.CMID#
      AND		Program_Payment_Cycle.Payment_Cycle_ID = Payment_Cycle.Payment_Cycle_ID	
      AND		Program_Payment_Cycle.Discount_Type_id = 2
      AND		Program_Payment_Cycle.Component_ID = '#thisTag.qProgramRebateComponents.Program_Rebates_Component_Id#'
    </cfquery>

    <cfif thisTag.qGetRebatePaymentFrequency.recordCount>  
      <cfset thisTag.program_rebate_payment_frequency = thisTag.qGetRebatePaymentFrequency.Payment_Cycle[1]>
    <cfelse>
      <cfset thisTag.program_rebate_payment_frequency = "">
      <!--- TESTING: #thisTag.qProgramRebateComponents.Program_Rebates_Component_Id# C --->
    </cfif>

</cfif>

<!--- ::::::: 2 PricingType ::::::: Always @ Program Level --->


<!--- identify the external_id --->
<!---
<cfquery name="thisTag.qGetRebateExternalID" datasource="#application.datasource#">
  SELECT	Program_Rebates_Component_Name.External_ID
  FROM	Program_Rebates_Component_Name,Program_Rebates_Component
  WHERE	Program_Rebates_Component.Program_Rebates_Component_Name_ID = Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
  AND		Program_Rebates_Component.Program_ID = #thisTag.CMID#
  AND		Program_Rebates_Component.Program_Rebates_Component_ID = #thisTag.qProgramRebateComponents.Program_Rebates_Component_Id#
</cfquery>
--->

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::: Identify Header Values [end] ::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
</cfsilent>

<!--- Add "Component Name" Info--->

<cfset Component_Heading_Details = "">

<!--- If "Component Name" template setting for distributors on letters is set to "Display" --->
<cfif attributes.stPDFBodyInfo.bDistributorComponentName>
	<cfset Component_Heading_Details = "#thisTag.qProgramRebateComponents.Program_Rebates_Component_Name#" & chr(13) & chr(10)>
</cfif>

<!--- If "Payment Frequency" template setting for distributors on letters is set to "Display" --->
<cfif attributes.stPDFBodyInfo.bDistributorPaymentFrequency>
 <cfif application.appsettingsget.paymentCycleAtDiscountType>
	<cfset Component_Heading_Details = Component_Heading_Details & "#thisTag.program_rebate_payment_frequency#" & chr(13) & chr(10)>
 </cfif>
</cfif>

<cfif application.appsettingsget.claims_at_comp_level>
	<!--- Add Claim Mechanism Info --->
	<!--- If "Claim Mechanism" template setting for distributor on letters is set to "Display" --->
		<cfif attributes.stPDFBodyInfo.bDistributorClaimMechanism>
			<cfset Component_Heading_Details = Component_Heading_Details & "#thisTag.qProgramRebateComponents.Claim_Mechanics#" & chr(13) & chr(10)>
		</cfif>
</cfif>

<!--- If "Payable To" template setting for distributor on letters is set to "Display" --->
<cfif attributes.stPDFBodyInfo.bDistributorPayableTo>
 <cfif thisTag.qProgramRebateComponents.component_paid_to EQ 1>
	<cfset Component_Heading_Details = Component_Heading_Details & application.returned_customer_setting.distributor_label_singular & chr(13) & chr(10)>
 <cfelse>
	<cfset Component_Heading_Details = Component_Heading_Details & application.returned_customer_setting.operator_label_singular & chr(13) & chr(10)>
 </cfif>
</cfif>

<!--- If there is at least one component related info to display --->
<cfif Component_Heading_Details neq "">
	<cfset Component_Heading_Details_Header = PdfPCell.init(phrase.init(Component_Heading_Details, GothicBold_Font_Bold_Brown_Eight))>
	<cfset Component_Heading_Details_Header.setColspan( javacast("int", 1) )>
	<cfset Component_Heading_Details_Header.setBorder(Rectangle.NO_BORDER)>

	<cfset Component_Heading_Details_Header.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT)>
	<cfset table_dis_Rebate.addCell(Component_Heading_Details_Header)>
</cfif>

</cfoutput>
</cfif>
<!--- 3.) Rebates [end] --->

