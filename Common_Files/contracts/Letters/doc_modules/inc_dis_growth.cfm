<cfsilent>
<!--- 
FILE: 		
FILENAME: doc_modules/inc_dis_growth.cfm
CREATED: 3/12/2015 - Milan
EDITED:		

FUNCTIONALITY:
- This include template is utilized to display the "Distributor Growth".
Note:The basic code flow in this file has been copied from "inc_dis_lump_sum.cfm".
This file also needed it's own code flow due to the need to display "volume" and "tier".
--->
</cfsilent>

<!--- Initialize the table. This table's columns should be in sync with table - "table_growth" --->
<cfset table_dis_growth = PdfPTable.init( javacast("int",colNum) )>
<cfset table_dis_growth.setWidthPercentage(100)>

<!--- The table is not complete yet --->
<cfset table_dis_growth.setComplete(0)>	

<!--- Set the length of the array as big as the number of columns in the table --->
<cfset jArr = arrObj.newInstance(jClass, colNum)>  

<!--- The first index of the array in JAVA starts with 0. Here different indexes are being assigned a value.  These values 
will be used as the width of the columns in the table_dis_growth table.
 --->
<cfif colNum eq 3>
    <cfset arrObj.setInt(jArr, 0, 33)>  
    <cfset arrObj.setInt(jArr, 1, 40)>  
    <cfset arrObj.setInt(jArr, 2, 27)>
<cfelse>
    <cfset arrObj.setInt(jArr, 0, 23)>  
    <cfset arrObj.setInt(jArr, 1, 20)>  
    <cfset arrObj.setInt(jArr, 2, 37)>
    <cfset arrObj.setInt(jArr, 3, 20)>
</cfif>

<cfset table_dis_growth.setWidths(jArr)>

<!--- Initialize a new  table - table_dis_growth_component --->
<cfset table_dis_growth_component = PdfPTable.init( javacast("int",2) )>
<cfset table_dis_growth_component.setWidthPercentage(100)>

<!--- The table is not complete yet --->
<cfset table_dis_growth_component.setComplete(0)>	

<!--- Set the length of the array as big as the number of columns in the table --->
<cfset jArr = arrObj.newInstance(jClass, 2)>  

<!--- The first index of the array in JAVA starts with 0. Here different indexes are being assigned a value.  These values 
will be used as the width of the columns in the table_dis_growth_component table.
--->
<cfset arrObj.setInt(jArr, 0, 50)>  
<cfset arrObj.setInt(jArr, 1, 50)> 

<cfset table_dis_growth_component.setWidths(jArr)>
              
	<!--- Growth [begin] --->
	<cfif thisTag.stPDFBodyInfo.bDisplayGrowth AND thisTag.qProgramGrowth.recordCount AND thisTag.stPDFBodyInfo.bDisplayGrowthDis>
	

							<cfset ItemList = "">
							<cfset rangeList = "">
							<cfset componentList = "">
							<cfset bgColorChange = 0>
							<cfset bckgroundColor = textColorLightGray>

							<cfloop query="thisTag.qProgramGrowth">

							<cfif ListFind(componentList, Program_Growth_Component_ID) eq 0>
								<cfset bAddComp= 1>
							<cfelse>
								<cfset bAddComp = 0>
							</cfif>

							<cfset componentList = ListAppend(componentList, Program_Growth_Component_ID)>

							<cfif ListFind(ItemList,BSA_Foodservice_Items_Master_ID & Program_Growth_Component_ID) eq 0>
								<cfset bAddProd = 1>
							<cfelse>
								<cfset bAddProd = 0>
							</cfif>

							<cfset itemList = ListAppend(itemList, BSA_Foodservice_Items_Master_ID & Program_Growth_Component_ID)>	

							<cfif bAddProd eq 1>
								<cfif bckgroundColor eq textColorWhite>
									<cfset bckgroundColor = textColorLightGray>
								<cfelse>
									<cfset bckgroundColor = textColorWhite>
								</cfif>
							</cfif>

							<cfif ListFind(RangeList, Range_Start & Program_Growth_Component_ID) eq 0>
								<cfset bAddRange = 1>
							<cfelse>
								<cfset bAddRange = 0>
							</cfif>

							<cfset rangeList = ListAppend(rangeList, Range_Start & Program_Growth_Component_ID)>

								<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::
								:::::::::::: Identify Header Values [begin] ::::::::::::::::
								::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

								<!--- ::::::: 1.) PaymentFrequency ::::::: --->
								
								<!---  IF payment cycle @ component level... --->
								<cfif application.appsettingsget.paymentCycleAtDiscountType>														
										<cfquery name="thisTag.qGetGrowthPaymentFrequency" datasource="#application.datasource#">
											SELECT 	Payment_Cycle.Payment_Cycle
											FROM   	Program_Payment_Cycle,Payment_Cycle
											WHERE   Program_Payment_Cycle.Program_ID = #thisTag.CMID#
											AND     Program_Payment_Cycle.Payment_Cycle_ID = Payment_Cycle.Payment_Cycle_ID           
											AND     Program_Payment_Cycle.Discount_Type_id = 4
											AND     Program_Payment_Cycle.deleted = 0
											AND     Program_Payment_Cycle.Component_ID = '#thisTag.qProgramGrowth.Program_Growth_Component_ID#'
										</cfquery>

										<cfif thisTag.qGetGrowthPaymentFrequency.recordCount>  
											<cfset thisTag.program_growth_payment_frequency = thisTag.qGetGrowthPaymentFrequency.Payment_Cycle[1]>
										<cfelse>
											<cfset thisTag.program_growth_payment_frequency = "">
										</cfif>
								<cfelse>
								
									<cfset thisTag.program_growth_payment_frequency = thisTag.stPDFIntroInfo.program_payment_frequency>

								</cfif>
								

								<!--- ::::::: 2 ClaimMechanism ::::::: --->
								
								<!--- 3A.) IF claims @ component level... --->
								<cfif application.appsettingsget.claims_at_comp_level>

									<cfset useLakebaseForthisTag_qGetGrowthClaimMechanism = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_type")>
<cfif useLakebaseForthisTag_qGetGrowthClaimMechanism>
	<cftry>
		<cfset thisTag.qGetGrowthClaimMechanism = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payment_type", {
				"payment_type_id" = "eq.#thisTag.qProgramGrowth.claim_mechanics#",
				"select" = "payment_type_name"
			}), "payment_type_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForthisTag_qGetGrowthClaimMechanism = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForthisTag_qGetGrowthClaimMechanism>
<cfquery name="thisTag.qGetGrowthClaimMechanism" datasource="#application.datasource#">
										SELECT  Payment_Type.Payment_Type_Name
										FROM   	Payment_Type
										WHERE   Payment_Type_ID = #thisTag.qProgramGrowth.claim_mechanics#
									</cfquery>
</cfif>

									<cfif thisTag.qGetGrowthClaimMechanism.recordCount>
										<cfset thisTag.program_growth_claim_mechanism = thisTag.qGetGrowthClaimMechanism.Payment_Type_Name[1]>
									<cfelse>
										<cfset thisTag.program_growth_claim_mechanism = "">
									</cfif>

								<!--- 3B.) IF claims @ program level... --->
								<cfelse>
								
									<cfquery name="thisTag.qGetGrowthClaimMechanism" datasource="#application.datasource#">
										SELECT 		TOP 1 Payment_Type.Payment_Type_Name
										FROM			Payment_Type,Program_Growth_Components
										WHERE 		Program_Growth_Components.Claim_Mechanics = Payment_Type.Payment_Type_id
										AND				Program_Growth_Components.Program_id = #thisTag.CMID#
									</cfquery>
									<cfif thisTag.qGetGrowthClaimMechanism.recordCount>
										<cfset thisTag.program_growth_claim_mechanism = thisTag.qGeGrowthClaimMechanism.Payment_Type_Name[1]>
									<cfelse>
										<cfset thisTag.program_growth_claim_mechanism = "">
									</cfif>

								</cfif>

								<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::
								:::::::::::: Identify Header Values [end] ::::::::::::::::::
								::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->


		<!--- IF we have data with which to append our growing list... --->  
		<cfif thisTag.qProgramGrowth.recordCount>            
								
		<cfset thisTag.lsProgramGrowthItemGUIDs = replace(valueList(thisTag.qProgramGrowth.BSA_Foodservice_Items_Master_ID,','),' ','','all')>
										
				<!--- D16586 loop over the lsProgramGrowthItemGUIDs list [begin] --->
				<cfloop list="#thisTag.lsProgramGrowthItemGUIDs#" index="thisTag.current_ProgramGrowthItemGUID">
				
						<!--- IF the current_ProgramGrowthItemGUID is NOT already in the thisTag.lsProgramAllDiscountItemGUIDs Cumulative & Unique list, ADD IT NOW --->
						<cfif NOT listFindNoCase(thisTag.lsProgramAllDiscountItemGUIDs,trim(thisTag.current_ProgramGrowthItemGUID),',')>
								<cfset thisTag.lsProgramAllDiscountItemGUIDs = listAppend(thisTag.lsProgramAllDiscountItemGUIDs, thisTag.current_ProgramGrowthItemGUID) />
						</cfif>
				</cfloop>
				<!--- D16586 loop over the lsProgramGrowthItemGUIDs list [end] --->
				
		 </cfif>   

		<!--- NOTE: Growth should always be in item ORDER --->
		
		<!--- Add the Growth content here --->

			<cfif bAddProd eq 0 AND (thisTag.bAddcustomerproductnumbers OR attributes.stPDFBodyInfo.bDistributorGTIN)>
				<cfset Cust_Prod_Number_And_GTIN_Heading = PdfPCell.init(phrase.init("", GothicNormal_font_Bold_Black_Eight))>
			<cfelseif bAddProd eq 1 AND thisTag.bAddcustomerproductnumbers AND attributes.stPDFBodyInfo.bDistributorGTIN>
				<cfset Cust_Prod_Number_And_GTIN_Heading = PdfPCell.init(phrase.init(thisTag.qProgramGrowth.Customer_Product_Number & chr(13) & chr(10) & thisTag.qProgramGrowth.GTIN, GothicNormal_font_Bold_Black_Eight))>
			<cfelseif bAddProd eq 1 AND thisTag.bAddcustomerproductnumbers>
				<cfset Cust_Prod_Number_And_GTIN_Heading = PdfPCell.init(phrase.init(thisTag.qProgramGrowth.Customer_Product_Number, GothicNormal_font_Bold_Black_Eight))>
			<cfelseif bAddProd eq 1 AND attributes.stPDFBodyInfo.bDistributorGTIN>
				<cfset Cust_Prod_Number_And_GTIN_Heading = PdfPCell.init(phrase.init(thisTag.qProgramGrowth.GTIN, GothicNormal_font_Bold_Black_Eight))>
			</cfif>

			<cfif thisTag.bAddcustomerproductnumbers OR attributes.stPDFBodyInfo.bDistributorGTIN>

				<cfset Cust_Prod_Number_And_GTIN_Heading.setColspan( javacast("int", 1) )>
				<cfset Cust_Prod_Number_And_GTIN_Heading.setBorder(Rectangle.NO_BORDER)> 
				
				<!--- Alternate coloring --->
				<cfif thisTag.qProgramGrowth.currentRow MOD 2 eq 1>
					<cfset Cust_Prod_Number_And_GTIN_Heading.setBackgroundColor(bckgroundColor)>
				<cfelse>
					<cfset Cust_Prod_Number_And_GTIN_Heading.setBackgroundColor(bckgroundColor)>
				</cfif>

				<cfset table_dis_growth.addCell(Cust_Prod_Number_And_GTIN_Heading)>
			</cfif>


				<cfif bAddProd eq 0>
					<cfset product = "">
				<cfelse>
					<cfset product = thisTag.qProgramGrowth.item>
				</cfif>
	
				
				<cfset Item_ID = PdfPCell.init(phrase.init(product, GothicNormal_font_Bold_Black_Eight))>
				<cfset Item_ID.setColspan( javacast("int", 1) )>
				<cfset Item_ID.setBorder(Rectangle.NO_BORDER)> 
				
				<!--- Alternate coloring --->
				<cfif thisTag.qProgramGrowth.currentRow MOD 2 eq 1>
					<cfset Item_ID.setBackgroundColor(bckgroundColor)>
				<cfelse>
					<cfset Item_ID.setBackgroundColor(bckgroundColor)>
				</cfif>

				<cfset table_dis_growth.addCell(Item_ID)>
				
				<cfif bAddProd eq 0>
				 <cfset Item_Description = PdfPCell.init(phrase.init("", GothicNormal_font_Bold_Black_Eight))>
				<cfelseif attributes.stPDFBodyInfo.bDistributorProductAttribute_1 neq 0>
				 <cfset Item_Description = PdfPCell.init(phrase.init(thisTag.qProgramGrowth.description  & chr(13) & chr(10) & thisTag.qProgramGrowth.distributor_product_attribute_1, GothicNormal_font_Bold_Black_Eight))>
				<cfelse>
				 <cfset Item_Description = PdfPCell.init(phrase.init(thisTag.qProgramGrowth.description, GothicNormal_font_Bold_Black_Eight))>
				</cfif>

				<cfset Item_Description.setColspan( javacast("int", 1) )>
				<cfset Item_Description.setBorder(Rectangle.NO_BORDER)>

				<!--- Alternate coloring --->
				<cfif thisTag.qProgramGrowth.currentRow MOD 2 eq 1>
					<cfset Item_Description.setBackgroundColor(bckgroundColor)>
				<cfelse>
					<cfset Item_Description.setBackgroundColor(bckgroundColor)>
				</cfif>

				<cfset table_dis_growth.addCell(Item_Description)>

				<cfif thisTag.qProgramGrowth.growth_price_percent neq "">
					<cfset Growth_Price = PdfPCell.init(phrase.init("Tier #thisTag.qProgramGrowth.Tier_Number#: #numberFormat(thisTag.qProgramGrowth.growth_price_percent,'_99.99')# %", GothicNormal_font_Bold_Black_Eight))>
				<!--- If "UOM" template setting for distributors on letters is set to "CS" --->
				<cfelseif attributes.stPDFBodyInfo.bDistributorUOM eq 1>
					<cfset Growth_Price = PdfPCell.init(phrase.init("Tier #thisTag.qProgramGrowth.Tier_Number#: $#numberFormat(thisTag.qProgramGrowth.growth_price_per_case,'_99.99')#/cs", GothicNormal_font_Bold_Black_Eight))>
				<!--- If "UOM" template setting for distributors on letters is set to "LB" --->
				<cfelseif attributes.stPDFBodyInfo.bDistributorUOM eq 2>
					<cfset Growth_Price = PdfPCell.init(phrase.init("Tier #thisTag.qProgramGrowth.Tier_Number#: $#numberFormat(thisTag.qProgramGrowth.growth_price_per_pound,'_9.9999')#/lb", GothicNormal_font_Bold_Black_Eight))>
				<!--- If "UOM" template setting for distributors on letters is set to "BOTH" --->
				<cfelse>
					<cfset Growth_Price = PdfPCell.init(phrase.init("Tier #thisTag.qProgramGrowth.Tier_Number#: $#numberFormat(thisTag.qProgramGrowth.growth_price_per_pound,'_9.9999')#/lb" & chr(13) & chr(10) & "$#numberFormat(thisTag.qProgramGrowth.growth_price_per_case,'_99.99')#/cs", GothicNormal_font_Bold_Black_Eight))>
				</cfif>
				<cfset Growth_Price.setColspan( javacast("int", 1) )>
				<cfset Growth_Price.setBorder(Rectangle.NO_BORDER)> 
				<cfset Growth_Price.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT)>

				<!--- Alternate coloring --->
				<cfif thisTag.qProgramGrowth.currentRow MOD 2 eq 1>
					<cfset Growth_Price.setBackgroundColor(bckgroundColor)>
				<cfelse>
					<cfset Growth_Price.setBackgroundColor(bckgroundColor)>
				</cfif>
				
				<cfset table_dis_growth.addCell(Growth_Price)>

		<!--- Add the "Volume Range" --->
		<cfif bAddRange eq 1>

			<cfif bAddComp eq 1>

				<cfset col_span = 2>
				<cfif attributes.stPDFBodyInfo.bBonusField eq 1>
					<cfset col_span = 1>
				</cfif>

				<cfset Program_Growth_Volume_Range = PdfPCell.init(phrase.init("Volume Range ("& component_UOM_Desc &")"  & chr(13) & chr(10), GothicBold_Font_Bold_Brown_Eight))>
				<cfset Program_Growth_Volume_Range.setColspan( javacast("int", col_span) )>
				<cfset Program_Growth_Volume_Range.setBorder(Rectangle.NO_BORDER)> 												
				<cfset table_dis_growth_component.addCell(Program_Growth_Volume_Range)>

				<cfif attributes.stPDFBodyInfo.bBonusField eq 1>
					<cfset Program_Growth_Bonus_Label = PdfPCell.init(phrase.init(Application.BonusLabel, GothicBold_Font_Bold_Brown_Eight))>
					<cfset Program_Growth_Bonus_Label.setColspan( javacast("int", col_span) )>
					<cfset Program_Growth_Bonus_Label.setBorder(Rectangle.NO_BORDER)> 												
					<cfset table_dis_growth_component.addCell(Program_Growth_Bonus_Label)>
				</cfif>

				<cfset Program_Growth_Volume_Range = PdfPCell.init(phrase.init("Achieve these volume tiers and earn the rate shown above", GothicBold_Font_Italic_Black_Seven))>
				<cfset Program_Growth_Volume_Range.setColspan( javacast("int", 2 ) )>
				<cfset Program_Growth_Volume_Range.setBorder(Rectangle.NO_BORDER)> 												
				<cfset table_dis_growth_component.addCell(Program_Growth_Volume_Range)>
				
				<cfif thisTag.qProgramGrowth.Range_End eq "*">
						<cfif attributes.stPDFBodyInfo.bBonusField eq 1>
							<cfset Program_Growth_Volume_Range = PdfPCell.init(phrase.init('Tier ' & thisTag.qProgramGrowth.Tier_Number &': ' & thisTag.qProgramGrowth.Range_Start & " or More", GothicBold_Font_Bold_Brown_Eight))>
						<cfelse>
							<cfset Program_Growth_Volume_Range = PdfPCell.init(phrase.init(thisTag.qProgramGrowth.Range_Start & " or More", GothicBold_Font_Bold_Brown_Eight))>
						</cfif>
				<cfelse>
						<cfif attributes.stPDFBodyInfo.bBonusField eq 1>
							<cfset Program_Growth_Volume_Range = PdfPCell.init(phrase.init('Tier ' & thisTag.qProgramGrowth.Tier_Number &': ' & thisTag.qProgramGrowth.Range_Start & " to " & thisTag.qProgramGrowth.Range_End, GothicBold_Font_Bold_Brown_Eight))>
						<cfelse>
							<cfset Program_Growth_Volume_Range = PdfPCell.init(phrase.init(thisTag.qProgramGrowth.Range_Start &  " to " & thisTag.qProgramGrowth.Range_End, GothicBold_Font_Bold_Brown_Eight))>
						</cfif>
				</cfif>
			<cfelse>
				<cfif thisTag.qProgramGrowth.Range_End eq "*">
					<cfif attributes.stPDFBodyInfo.bBonusField eq 1>
						<cfset Program_Growth_Volume_Range = PdfPCell.init(phrase.init('Tier ' & thisTag.qProgramGrowth.Tier_Number &': ' & thisTag.qProgramGrowth.Range_Start & " or More", GothicBold_Font_Bold_Brown_Eight))>
					<cfelse>
						<cfset Program_Growth_Volume_Range = PdfPCell.init(phrase.init(thisTag.qProgramGrowth.Range_Start & " or More", GothicBold_Font_Bold_Brown_Eight))>
					</cfif>
				<cfelse>
					<cfif attributes.stPDFBodyInfo.bBonusField eq 1>
						<cfset Program_Growth_Volume_Range = PdfPCell.init(phrase.init('Tier ' & thisTag.qProgramGrowth.Tier_Number &': ' & thisTag.qProgramGrowth.Range_Start & " to " & thisTag.qProgramGrowth.Range_End, GothicBold_Font_Bold_Brown_Eight))>
					<cfelse>
						<cfset Program_Growth_Volume_Range = PdfPCell.init(phrase.init(thisTag.qProgramGrowth.Range_Start & " to " & thisTag.qProgramGrowth.Range_End, GothicBold_Font_Bold_Brown_Eight))>
					</cfif>
				</cfif>
			</cfif>

			
			<cfset Program_Growth_Volume_Range.setColspan( javacast("int", col_span) )>
			<cfset Program_Growth_Volume_Range.setBorder(Rectangle.NO_BORDER)> 												
			<cfset table_dis_growth_component.addCell(Program_Growth_Volume_Range)>

			<cfif attributes.stPDFBodyInfo.bBonusField eq 1>			
				<cfset Program_Growth_Bonus = PdfPCell.init(phrase.init("$ #trim(numberformat(thisTag.qProgramGrowth.Growth_Amount, '___,___,___,___,___,___,___'))#", GothicBold_Font_Bold_Brown_Eight))>
				<cfset Program_Growth_Bonus.setColspan( javacast("int", col_span) )>
				<cfset Program_Growth_Bonus.setBorder(Rectangle.NO_BORDER)> 												
				<cfset table_dis_growth_component.addCell(Program_Growth_Bonus)>
			</cfif>

		</cfif>

		<cfset show_component = 0>
		<!--- If the current program Growth name is not the same as the next one, then show the component info. Here we have to show products related to a component one by one --->
		<cfif (thisTag.qProgramGrowth.Program_Growth_Component_ID[thisTag.qProgramGrowth.currentrow] neq thisTag.qProgramGrowth.Program_Growth_Component_ID[thisTag.qProgramGrowth.currentrow+1]) OR thisTag.qProgramGrowth.currentrow EQ thisTag.qProgramGrowth.recordcount>
		<!--- COMPONENT DETAILS --->
		<cfset show_component = 1>

		<cfset New_Line = PdfPCell.init(phrase.init(chr(13) & chr(10), GothicBold_Font_Bold_Brown_Eight))>
		<cfset New_Line.setColspan( javacast("int", 2) )>
		<cfset New_Line.setBorder(Rectangle.NO_BORDER)> 
		<cfset table_dis_growth_component.addCell(New_Line)>

		<cfset col_span = 1>

		<!--- If there are odd number of component related info to show AND "ComponentName" is the last one OR only one, make sure this column's colspan is 2 and not 1 --->
		<cfif TotalComponentRelatedInfoCount_Growth MOD 2 eq 1 AND LastComponentRelatedInfo eq "ComponentName">
		 <cfset col_span = 2>
		</cfif>
		
		<!--- If "Component Name" template setting for distributors on letters is set to "Display" --->
		<cfif attributes.stPDFBodyInfo.bDistributorComponentName>
			<cfset Program_Growth_Name_Description = PdfPCell.init(phrase.init("Component Name: " & thisTag.qProgramGrowth.Program_Growth_Components_Name,GothicBold_Font_Bold_Brown_Eight))>
			<cfset Program_Growth_Name_Description.setColspan( javacast("int", #col_span#) )>
			<cfset Program_Growth_Name_Description.setBorder(Rectangle.NO_BORDER)> 
			<cfset table_dis_growth_component.addCell(Program_Growth_Name_Description)>
		</cfif>

		<!--- Add Claim Mechanism Info --->

		<cfset col_span = 1>

		<!--- If there are odd number of component related info to show AND "ClaimMechanism" is the last one OR only one, make sure this column's colspan is 2 and not 1 --->
		<cfif TotalComponentRelatedInfoCount_Growth MOD 2 eq 1 AND LastComponentRelatedInfo eq "ClaimMechanism">
		 <cfset col_span = 2>
		</cfif>
		
		<!--- If "Claim Mechanism" template setting for distributors on letters is set to "Display" --->
		<cfif attributes.stPDFBodyInfo.bDistributorClaimMechanism>
			<cfset Program_Growth_Claim_Mechanism_Description = PdfPCell.init(phrase.init("Claim Mechanism: " & thisTag.program_growth_claim_mechanism,GothicBold_Font_Bold_Brown_Eight))>
			<cfset Program_Growth_Claim_Mechanism_Description.setColspan( javacast("int", #col_span#) )>
			<cfset Program_Growth_Claim_Mechanism_Description.setBorder(Rectangle.NO_BORDER)> 												
			<cfset table_dis_growth_component.addCell(Program_Growth_Claim_Mechanism_Description)>
		</cfif>
		
		<!--- Add Payable to Info --->

		<cfset col_span = 1>

		<!--- If there are odd number of component related info to show AND "PayableTo" is the last one OR only one, make sure this column's colspan is 2 and not 1 --->
		<cfif TotalComponentRelatedInfoCount_Growth MOD 2 eq 1 AND LastComponentRelatedInfo eq "PayableTo">
		 <cfset col_span = 2>
		</cfif>
		
		<!--- If "Payable to" template setting for distributors on letters is set to "Display" --->
		<cfif attributes.stPDFBodyInfo.bDistributorPayableTo>

		<cfif thisTag.qProgramGrowth.component_paid_to EQ 1>
			<cfset Payable_To_Description = PdfPCell.init(phrase.init("Payable to: " & application.returned_customer_setting.distributor_label_singular,GothicBold_Font_Bold_Brown_Eight))>														
		<cfelse>
			<cfset Payable_To_Description = PdfPCell.init(phrase.init("Payable to: " & application.returned_customer_setting.operator_label_singular,GothicBold_Font_Bold_Brown_Eight))>
		</cfif>
							 
		<cfset Payable_To_Description.setColspan( javacast("int", #col_span#) )>
		<cfset Payable_To_Description.setBorder(Rectangle.NO_BORDER)> 
		<cfset table_dis_growth_component.addCell(Payable_To_Description)>

		</cfif>

		

		<!--- Add Payment Frequency Info --->
		<cfset col_span = 1>

		<!--- If there are odd number of component related info to show AND "PaymentFrequency" is the last one OR only one, make sure this column's colspan is 2 and not 1 --->
		<cfif TotalComponentRelatedInfoCount_Growth MOD 2 eq 1 AND LastComponentRelatedInfo eq "PaymentFrequency">
		 <cfset col_span = 2>
		</cfif>
		
		<!--- If "Payment Frequency" template setting for distributors on letters is set to "Display" --->
		<cfif attributes.stPDFBodyInfo.bDistributorPaymentFrequency>

		<cfset Program_Growth_Payment_Frequency_Description = PdfPCell.init(phrase.init("Payment Frequency: " & thisTag.program_growth_payment_frequency,GothicBold_Font_Bold_Brown_Eight))>
		<cfset Program_Growth_Payment_Frequency_Description.setColspan( javacast("int", #col_span#) )>
		<cfset Program_Growth_Payment_Frequency_Description.setBorder(Rectangle.NO_BORDER)> 												
		<cfset table_dis_growth_component.addCell(Program_Growth_Payment_Frequency_Description)>

		</cfif>
		  
		  <!--- Add the last product info, before adding the component info below --->
		  <cfset document.add(table_dis_growth)>
				
		  <!--- Add the Component details to the pdf document --->
		  <cfset document.add(table_dis_growth_component)>
		  <cfset document.add(chunk.init(chr(13) & chr(10)))>
		</cfif>
		
		<!--- If we have already added the product info, then skip it --->
		<cfif show_component neq 1>
		  <!--- Add the table_dis_growth table to the pdf document --->
		  <cfset document.add(table_dis_growth)>
		</cfif>


	</cfloop>
</cfif>
<!--- Growth [end] --->