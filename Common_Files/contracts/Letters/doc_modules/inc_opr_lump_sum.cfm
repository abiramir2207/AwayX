<cfsilent>
<!--- 
FILE: 		
FILENAME: 		doc_modules/inc_opr_lump_sum.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			07/31/2008 - RBL [D16586 thisTag.lsProgramAllDiscountItemGUIDs]
EDITED:			08/16/2010 - Milan [Convert to Itext in Java]
EDITED:			09/15/2010 - Milan [Add template setting to show/hide info on the letter]

FUNCTIONALITY:
- This include template is utilized to display the "Operator Lump Sum" module within the Deal Letters v2...
--->
</cfsilent>

<!--- Initialize the table.This table's columns should be in sync with table - "table_lumpsum" --->
<cfset table_opr_lumpsum = PdfPTable.init( javacast("int",colNum) )>
<cfset table_opr_lumpsum.setWidthPercentage(100)>

<!--- The table is not complete yet --->
<cfset table_opr_lumpsum.setComplete(0)>	

<!--- Set the length of the array as big as the number of columns in the table --->
<cfset jArr = arrObj.newInstance(jClass, colNum)>  

<!--- The first index of the array in JAVA starts with 0. Here different indexes are being assigned a value.  These values 
will be used as the width of the columns in the table_opr_lumpsum table.
--->
<cfset elementPosition = -1>
<cfloop list="#percentWidth#" index="i">
	<cfset elementPosition = elementPosition + 1>
	<cfset arrObj.setInt(jArr, #elementPosition#, #i#)>
</cfloop>

<cfset table_opr_lumpsum.setWidths(jArr)>

<!--- Initialize a new  table - table_opr_lumpsum_component --->
<cfset table_opr_lumpsum_component = PdfPTable.init( javacast("int",2) )>
<cfset table_opr_lumpsum_component.setWidthPercentage(100)>

<!--- The table is not complete yet --->
<cfset table_opr_lumpsum_component.setComplete(0)>	

<!--- Set the length of the array as big as the number of columns in the table --->
<cfset jArr = arrObj.newInstance(jClass, 2)>  

<cfset percentWidth = "50,50">
<!--- The first index of the array in JAVA starts with 0. Here different indexes are being assigned a value.  These values 
will be used as the width of the columns in the table_opr_lumpsum_component table.
--->
<cfset elementPosition = -1>
<cfloop list="#percentWidth#" index="i">
	<cfset elementPosition = elementPosition + 1>
	<cfset arrObj.setInt(jArr, #elementPosition#, #i#)>
</cfloop>

<cfset table_opr_lumpsum_component.setWidths(jArr)>

<!--- 4.) Lump Sums [begin] --->
<!--- ACTION: Is this duplicitious? same Q's are asked when calling this template --->
<cfif thisTag.stPDFBodyInfo.bDisplayLumpSum AND thisTag.qProgramLumpSum.recordCount AND thisTag.stPDFBodyInfo.bDisplayLumpSumOpr>
					<cfset lumpcount = 0>
					<cfoutput query="thisTag.qProgramLumpSum">

						<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::
						:::::::::::: Identify Header Values [begin] ::::::::::::::::
						::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

						<!--- ::::::: 1.) PaymentFrequency ::::::: --->
						
						<!--- 1A.) IF payment cycle @ component level... --->
						<cfif application.appsettingsget.paymentCycleAtDiscountType>
						
							<!--- ACTION: TO DELETE <cfquery name="thisTag.qGetLumpSumPaymentFrequency" datasource="#application.datasource#">
									SELECT	Payment_Cycle.Payment_Cycle
									FROM	Program_Payment_Cycle,Payment_Cycle,Program_Lump_Sums
									WHERE	Program_Payment_Cycle.Program_ID = #thisTag.CMID#
									AND		Program_Payment_Cycle.Payment_Cycle_ID = Payment_Cycle.Payment_Cycle_ID	
									AND		Program_Payment_Cycle.Discount_Type_id = 3
									AND		Program_Lump_Sums.Program_ID = #thisTag.CMID#
									AND		Program_Lump_Sums.Component_External_id = '#thisTag.qProgramLumpSum.Component_External_id#'
								</cfquery> --->
								
								<cfquery name="thisTag.qGetLumpSumPaymentFrequency" datasource="#application.datasource#">
									SELECT 	Payment_Cycle.Payment_Cycle
									FROM   	Program_Payment_Cycle,Payment_Cycle
									WHERE   Program_Payment_Cycle.Program_ID = #thisTag.CMID#
									AND     Program_Payment_Cycle.Payment_Cycle_ID = Payment_Cycle.Payment_Cycle_ID           
									AND     Program_Payment_Cycle.Discount_Type_id = 3
									AND	Program_Payment_Cycle.deleted = 0
									AND     Program_Payment_Cycle.Component_ID = '#thisTag.qProgramLumpSum.Program_Lumps_Sum_Ext_Id#'
								</cfquery>
						
								<cfif thisTag.qGetLumpSumPaymentFrequency.recordCount>  
									<cfset thisTag.program_lump_sum_payment_frequency = thisTag.qGetLumpSumPaymentFrequency.Payment_Cycle[1]>
								<cfelse>
									<cfset thisTag.program_lump_sum_payment_frequency = "">
									<!--- TESTING: CmpLvl no records --->
								</cfif>

						<!---1B.)  IF payment cycle @ program level... --->
						<cfelse>
						
							<cfset thisTag.program_lump_sum_payment_frequency = thisTag.stPDFIntroInfo.program_payment_frequency>

						</cfif>
						
						<!--- ::::::: 2 Pricing Type ::::::: --->
						
						<cfset thisTag.program_lump_sum_pricing_type = thisTag.stPDFIntroInfo.program_pricing_type>
						
						<!--- ::::::: 3 ClaimMechanism ::::::: --->
						
						<!--- 3A.) IF claims @ component level... --->
						<cfif application.appsettingsget.claims_at_comp_level>

							<!--- ACTION: TO DELETE <cfquery name="thisTag.qGetLumpSumClaimMechanism" datasource="#application.datasource#">
								SELECT 		TOP 1 Payment_Type.Payment_Type_Name
								FROM			Payment_Type,Program_Lump_Sums
								WHERE 		Program_Lump_Sums.Claim_Mechanics = #thisTag.qProgramLumpSum.claim_mechanics#
								AND				Program_Lump_Sums.Program_id = #thisTag.CMID#
							</cfquery> --->

							<cfquery name="thisTag.qGetLumpSumClaimMechanism" datasource="#application.datasource#">
								SELECT  Payment_Type.Payment_Type_Name
								FROM   	Payment_Type
								WHERE   Payment_Type_ID = #thisTag.qProgramLumpSum.claim_mechanics#
							</cfquery>

							<cfif thisTag.qGetLumpSumClaimMechanism.recordCount>
								<cfset thisTag.program_lump_sum_claim_mechanism = thisTag.qGetLumpSumClaimMechanism.Payment_Type_Name[1]>
							<cfelse>
								<cfset thisTag.program_lump_sum_claim_mechanism = "">
								<!--- TESTING: LS PmtClmMch #Program_Rebates_Component_Id# CmpLvl no records --->
							</cfif>

						<!--- 3B.) IF claims @ program level... --->
						<cfelse>
						
							<cfquery name="thisTag.qGetLumpSumClaimMechanism" datasource="#application.datasource#">
								SELECT 		TOP 1 Payment_Type.Payment_Type_Name
								FROM			Payment_Type,Program_Lump_Sums
								WHERE 		Program_Lump_Sums.Claim_Mechanics = Payment_Type.Payment_Type_id
								AND				Program_Lump_Sums.Program_id = #thisTag.CMID#
							</cfquery>
							<cfif thisTag.qGetLumpSumClaimMechanism.recordCount>
								<cfset thisTag.program_lump_sum_claim_mechanism = thisTag.qGetLumpSumClaimMechanism.Payment_Type_Name[1]>
							<cfelse>
								<cfset thisTag.program_lump_sum_claim_mechanism = "">
								<!--- TESTING: LS PmtClmMch #thisTag.CMID# PgmLvl no records --->
							</cfif>

						</cfif>

						<!--- identify the external_id --->
						<!---
						<cfquery name="thisTag.qGetLumpSumExternalID" datasource="#application.datasource#">
							SELECT	Program_Lump_Sum_Name.External_ID
							FROM	Program_Lump_Sum_Name,Program_Lump_Sums
							WHERE	Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
							AND		Program_Lump_Sums.Program_ID = #thisTag.CMID#
							AND		Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = '#trim(thisTag.qProgramLumpSum.program_lump_sum_name_ID)#'
						</cfquery>
						--->

						<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::
						:::::::::::: Identify Header Values [end] ::::::::::::::::::
						::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

						
		<!--- IF we have data with which to append our growing list... [begin] --->  
		<cfif thisTag.qProgramLumpSum.recordCount>       
								
		<cfset thisTag.lsProgramLumpsumItemGUIDs = replace(valueList(thisTag.qProgramLumpSum.BSA_Foodservice_Items_Master_ID,','),' ','','all')>
										
				<!--- D16586
				<cfset thisTag.lsProgramAllDiscountItemGUIDs = listAppend(thisTag.lsProgramAllDiscountItemGUIDs, thisTag.lsProgramLumpsumItemGUIDs) /> --->

				<!--- NOTE: Brad changed the logic for this Cumulative & Unique list container throughout letters.
				Brad questions whether the general function uniqueList() works as desired. [ProgramLumpsumItemGUID] --->
				
				<!--- D16586 loop over the lsProgramLumpsumItemGUIDs list [begin] --->
				<cfloop list="#thisTag.lsProgramLumpsumItemGUIDs#" index="thisTag.current_ProgramLumpsumItemGUID">
				
						<!--- IF the current_ProgramLumpsumItemGUID is NOT already in the thisTag.lsProgramAllDiscountItemGUIDs Cumulative & Unique list, ADD IT NOW --->
						<cfif NOT listFindNoCase(thisTag.lsProgramAllDiscountItemGUIDs,trim(thisTag.current_ProgramLumpsumItemGUID),',')>
								<cfset thisTag.lsProgramAllDiscountItemGUIDs = listAppend(thisTag.lsProgramAllDiscountItemGUIDs, thisTag.current_ProgramLumpsumItemGUID) />
						</cfif>
				</cfloop>
				<!--- D16586 loop over the lsProgramLumpsumItemGUIDs list [end] --->
				
		</cfif>     
		<!--- IF we have data with which to append our growing list... [end] --->  
    
     <!--- NOTE: Lump Sum should always be in item ORDER --->

	<!--- Add the lumpsum content here --->
		<!--- LINE NUMBER --->
		<!--- Column 1 --->
		<cfif attributes.stPDFBodyInfo.bOperatorLine>
			<cfset LineNumber = PdfPCell.init(phrase.init(thisTag.qProgramLumpSum.Line_Number, GothicNormal_font_Bold_Black_Eight))>
			<cfset LineNumber.setColspan( javacast("int", 1) )>
			<cfset LineNumber.setBorder(Rectangle.NO_BORDER)> 
			
			<!--- Alternate coloring --->
			<cfif thisTag.qProgramLumpSum.currentRow MOD 2 eq 1>
				<cfset LineNumber.setBackgroundColor(textColorWhite)>
			<cfelse>
				<cfset LineNumber.setBackgroundColor(textColorLightGray)>
			</cfif>

			<cfset table_opr_lumpsum.addCell(LineNumber)>
		</cfif>

		<!--- ITEM --->
		<!--- Column 2 --->
		<cfset Item_ID = PdfPCell.init(phrase.init(thisTag.qProgramLumpSum.item, GothicNormal_font_Bold_Black_Eight))>
		<cfset Item_ID.setColspan( javacast("int", 1) )>
		<cfset Item_ID.setBorder(Rectangle.NO_BORDER)> 

		<!--- Alternate coloring --->
		<cfif thisTag.qProgramLumpSum.currentRow MOD 2 eq 1>
			<cfset Item_ID.setBackgroundColor(textColorWhite)>
		<cfelse>
			<cfset Item_ID.setBackgroundColor(textColorLightGray)>
		</cfif>

		<cfset table_opr_lumpsum.addCell(Item_ID)>

		<!--- GTIN --->
		<!--- Column 3 --->
		<cfif attributes.stPDFBodyInfo.bOperatorGTIN>
			<cfset GTIN_Number = PdfPCell.init(phrase.init(thisTag.qProgramLumpSum.GTIN, GothicNormal_font_Bold_Black_Eight))>
			<cfset GTIN_Number.setColspan( javacast("int", 1) )>
			<cfset GTIN_Number.setBorder(Rectangle.NO_BORDER)> 

			<!--- Alternate coloring --->
			<cfif thisTag.qProgramLumpSum.currentRow MOD 2 eq 1>
				<cfset GTIN_Number.setBackgroundColor(textColorWhite)>
			<cfelse>
				<cfset GTIN_Number.setBackgroundColor(textColorLightGray)>
			</cfif>

			<cfset table_opr_lumpsum.addCell(GTIN_Number)>
		</cfif>
	
		<!--- ITEM DESCRIPTION --->
		<!--- Column 4 --->
		<cfif attributes.stPDFBodyInfo.bOperatorProductAttribute_1 neq 0>
		 <cfset Item_Description = PdfPCell.init(phrase.init(thisTag.qProgramLumpSum.description & chr(13) & chr(10) & thisTag.qProgramLumpSum.operator_product_attribute_1, GothicNormal_font_Bold_Black_Eight))>
		<cfelse>
		 <cfset Item_Description = PdfPCell.init(phrase.init(thisTag.qProgramLumpSum.description, GothicNormal_font_Bold_Black_Eight))>
		</cfif>

		<cfset Item_Description.setColspan( javacast("int", 1) )>
		<cfset Item_Description.setBorder(Rectangle.NO_BORDER)> 
		
		<!--- Alternate coloring --->
		<cfif thisTag.qProgramLumpSum.currentRow MOD 2 eq 1>
			<cfset Item_Description.setBackgroundColor(textColorWhite)>
		<cfelse>
			<cfset Item_Description.setBackgroundColor(textColorLightGray)>
		</cfif>

		<cfset table_opr_lumpsum.addCell(Item_Description)>

		<!--- NET WEIGHT --->
		<!--- Column 5 --->
		<cfif attributes.stPDFBodyInfo.bOperatorProductNetWeight>
			<cfset NetWeight = PdfPCell.init(phrase.init(thisTag.qProgramLumpSum.Net_Weight, GothicNormal_font_Bold_Black_Eight))>
			<cfset NetWeight.setColspan( javacast("int", 1) )>
			<cfset NetWeight.setBorder(Rectangle.NO_BORDER)> 
			
			<!--- Alternate coloring --->
			<cfif thisTag.qProgramLumpSum.currentRow MOD 2 eq 1>
				<cfset NetWeight.setBackgroundColor(textColorWhite)>
			<cfelse>
				<cfset NetWeight.setBackgroundColor(textColorLightGray)>
			</cfif>

			<cfset table_opr_lumpsum.addCell(NetWeight)>
		</cfif>

		<!--- AMOUNT --->
		<!--- Column 6 --->
		<cfset Amount = PdfPCell.init(phrase.init(""))>
		<cfset Amount.setColspan( javacast("int", 1) )>
		<cfset Amount.setBorder(Rectangle.NO_BORDER)> 
		
		<!--- Alternate coloring --->
		<cfif thisTag.qProgramLumpSum.currentRow MOD 2 eq 1>
			<cfset Amount.setBackgroundColor(textColorWhite)>
		<cfelse>
			<cfset Amount.setBackgroundColor(textColorLightGray)>
		</cfif>

		<cfset table_opr_lumpsum.addCell(Amount)>
		
		
		<!--- COMPONENTS --->
		<cfset show_component = 0>
		<!--- If the current program lump sum name is not the same as the next one, then show the component info. Here we have to show prducts related to a component one by one --->
		<cfif (thisTag.qProgramLumpSum.Program_Lump_sum_ID[thisTag.qProgramLumpSum.currentrow] neq thisTag.qProgramLumpSum.Program_Lump_sum_ID[thisTag.qProgramLumpSum.currentrow+1]) OR thisTag.qProgramLumpSum.currentrow EQ thisTag.qProgramLumpSum.recordcount>
		<!--- COMPONENT DETAILS --->
		<cfset show_component = 1>
		<!--- Add "Component Name" Info--->
		
		<cfset col_span = 1>

		<!--- If there are odd number of component related info to show AND "ComponentName" is the last one OR only one, make sure this column's colspan is 2 and not 1 --->
		<cfif TotalComponentRelatedInfoCount_Lumpsum MOD 2 eq 1 AND LastComponentRelatedInfo eq "ComponentName">
		 <cfset col_span = 2>
		</cfif>

		<!--- If "Component Name" template setting for operators on letters is set to "Display" --->
		<cfif attributes.stPDFBodyInfo.bOperatorComponentName>
			<cfset Program_Lump_Sum_Name_Description = PdfPCell.init(phrase.init("Component Name: " & thisTag.qProgramLumpSum.program_lump_sum_name,GothicBold_Font_Bold_Brown_Eight))>
			<cfset Program_Lump_Sum_Name_Description.setColspan( javacast("int", #col_span#) )>
			<cfset Program_Lump_Sum_Name_Description.setBorder(Rectangle.NO_BORDER)> 
			<cfset table_opr_lumpsum_component.addCell(Program_Lump_Sum_Name_Description)>
		</cfif>

		
		<!--- Add Claim Mechanism Info --->

		<cfset col_span = 1>

		<!--- If there are odd number of component related info to show AND "ClaimMechanism" is the last one OR only one, make sure this column's colspan is 2 and not 1 --->
		<cfif TotalComponentRelatedInfoCount_Lumpsum MOD 2 eq 1 AND LastComponentRelatedInfo eq "ClaimMechanism">
		 <cfset col_span = 2>
		</cfif>

		<!--- If "Claim Mechanism" template setting for operators on letters is set to "Display" --->
		<cfif attributes.stPDFBodyInfo.bOperatorClaimMechanism>
			<cfset Program_Lump_Sum_Claim_Mechanism_Description = PdfPCell.init(phrase.init("Claim Mechanism: " & thisTag.program_lump_sum_claim_mechanism,GothicBold_Font_Bold_Brown_Eight))>
			<cfset Program_Lump_Sum_Claim_Mechanism_Description.setColspan( javacast("int", #col_span#) )>
			<cfset Program_Lump_Sum_Claim_Mechanism_Description.setBorder(Rectangle.NO_BORDER)> 												
			<cfset table_opr_lumpsum_component.addCell(Program_Lump_Sum_Claim_Mechanism_Description)>
		</cfif>

		<!--- Add Payable to Info --->

		<cfset col_span = 1>

		<!--- If there are odd number of component related info to show AND "PayableTo" is the last one OR only one, make sure this column's colspan is 2 and not 1 --->
		<cfif TotalComponentRelatedInfoCount_Lumpsum MOD 2 eq 1 AND LastComponentRelatedInfo eq "PayableTo">
		 <cfset col_span = 2>
		</cfif>

		<!--- If "Payable to" template setting for operators on letters is set to "Display" --->
		<cfif attributes.stPDFBodyInfo.bOperatorPayableTo>
		  <cfif thisTag.qProgramLumpSum.component_paid_to EQ 1>
			<cfset Payable_To_Description = PdfPCell.init(phrase.init("Payable to: " & application.returned_customer_setting.distributor_label_singular,GothicBold_Font_Bold_Brown_Eight))>														
		  <cfelse>
			<cfset Payable_To_Description = PdfPCell.init(phrase.init("Payable to: " & application.returned_customer_setting.operator_label_singular,GothicBold_Font_Bold_Brown_Eight))>
		  </cfif>
							 
			<cfset Payable_To_Description.setColspan( javacast("int", #col_span#) )>
			<cfset Payable_To_Description.setBorder(Rectangle.NO_BORDER)> 
			<cfset table_opr_lumpsum_component.addCell(Payable_To_Description)>
		</cfif>

		<!--- Add Payment Frequency Info --->

		<cfset col_span = 1>

		<!--- If there are odd number of component related info to show AND "PaymentFrequency" is the last one OR only one, make sure this column's colspan is 2 and not 1 --->
		<cfif TotalComponentRelatedInfoCount_Lumpsum MOD 2 eq 1 AND LastComponentRelatedInfo eq "PaymentFrequency">
		 <cfset col_span = 2>
		</cfif>

		<!--- If "Payment Frequency" template setting for operators on letters is set to "Display" --->
		<cfif attributes.stPDFBodyInfo.bOperatorPaymentFrequency>
			<cfset Program_Lump_Sum_Payment_Frequency_Description = PdfPCell.init(phrase.init("Payment Frequency: " & thisTag.program_lump_sum_payment_frequency,GothicBold_Font_Bold_Brown_Eight))>
			<cfset Program_Lump_Sum_Payment_Frequency_Description.setColspan( javacast("int", #col_span#) )>
			<cfset Program_Lump_Sum_Payment_Frequency_Description.setBorder(Rectangle.NO_BORDER)> 												
			<cfset table_opr_lumpsum_component.addCell(Program_Lump_Sum_Payment_Frequency_Description)>
		</cfif>

		<cfset Program_Lump_Sum_Amount = PdfPCell.init(phrase.init(dollarFormat(Lump_sum_amount),GothicNormal_font_Bold_Black_Eight))>
		<cfset Program_Lump_Sum_Amount.setColspan( javacast("int", 2) )>
		<cfset Program_Lump_Sum_Amount.setBorder(Rectangle.NO_BORDER)> 
		<cfset Program_Lump_Sum_Amount.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT)>
		<cfset table_opr_lumpsum_component.addCell(Program_Lump_Sum_Amount)>

		<!--- If we have lump sum notes, then add the notes. --->
		<cfset Program_Lump_Sum_Desc = PdfPCell.init(phrase.init("(#thisTag.qProgramLumpSum.Lump_Sum_Description#)",GothicBold_Font_Italic_Black_Seven))>
		<cfset Program_Lump_Sum_Desc.setColspan( javacast("int", 2) )>
		<cfset Program_Lump_Sum_Desc.setBorder(Rectangle.NO_BORDER)> 
		<cfset Program_Lump_Sum_Desc.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
		<cfset table_opr_lumpsum_component.addCell(Program_Lump_Sum_Desc)>

		<!--- Add the last product info, before adding the component info below --->
		<cfset document.add(table_opr_lumpsum)>

		<!--- Add the Component details to the pdf document --->
		<cfset document.add(table_opr_lumpsum_component)>

		</cfif>

		<!--- If we have already added the product info, then skip it --->
		<cfif show_component neq 1>
		<!--- Add the table_opr_lumpsum table to the pdf document --->
		<cfset document.add(table_opr_lumpsum)>
		</cfif>


</cfoutput>
		<!---- eliminate duplicates ----->
		<!--- should already be unique NOW... --->
		<!--- D16586 <cfset thisTag.lsProgramAllDiscountItemGUIDs = request.app_general_functions.getUniqueList(thisTag.lsProgramAllDiscountItemGUIDs) /> --->
</cfif>
<!--- 4.) Lump Sums [end] --->