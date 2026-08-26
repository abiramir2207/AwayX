<cfsilent>
<!--- 
FILE: 				Generate Program HTML
FILENAME:   	generate_program_pdf.cfm
CREATED: 			12/15/2007 - RBL
EDITED:				03/17/2008 - RBL

FUNCTIONALITY:
- 	This CF8 custom tag generates an html file without a watermark option.

IMPORTANT TECH NOTE: I initially placed ALL deal letter V2 files in one folder for the deal letter project, confining my new code so as to not allow a conflict being new.
Now, I would prefer to MOVE NOT COPY the 4 deal letter CT's to the CT directory, the 1 (incomplete) cfc to the component directory, and the images to the images directory,
but as i understand, we do NOT delete within our CVS repository.
I anticipate this duplicity WILL cause a problem with the CT's since I recall they look in the current directory first, THEN CT directories, unless I stand corrected this behavior can not be changed. I would always prefer and suggest to delete deprecated code consistently as it is deprecated to clean house. If there is a problem, it will surface in stage. This is a great example of why. RBL 2/1/2008

LEGEND:
Bid Request 		should always be in Program_Bidrequest_Component_Id,Program_Bidrequest_Component_Paid_to,item ORDER
Fixed Price 		should always be in Program_Fixed_Component_Id,Fixed_Component_Paid_to,item ORDER
Lump Sum Items	should always be in item ORDER
Rebate 					should always be in item,Program_Rebates_Component_ID,Component_Paid_to ORDER
--->

<!--- ||| These parameters [in alpha] are required for this template to process correctly --->

<!--- CSL_Contract_Main_ID for folder_name --->
<cfparam name="attributes.CMID" 										type="numeric" 	default="0">

<!--- nameformat --->
<cfparam name="attributes.file_name" 								type="string" 	default="">

<!--- queries from the VARS Include for scoping... [begin] --->
<cfparam name="attributes.qGetLetterSettings" 						type="query" 		default="#queryNew('Letter_Settings')#">
<cfparam name="attributes.qGetProgramDetails" 						type="query" 		default="#queryNew('Program_Details')#">
<cfparam name="attributes.qGetTemplateSettings" 					type="query" 		default="#queryNew('Template_Settings')#">
<!--- The Magnificent 7 --->
<cfparam name="attributes.qProgramBidRequest"							type="query" 		default="#queryNew('Bid_Request')#">
<cfparam name="attributes.qProgramClause"									type="query" 		default="#queryNew('Clause')#">
<cfparam name="attributes.qProgramDistributor"						type="query" 		default="#queryNew('Distributor')#">
<cfparam name="attributes.qProgramFixedPrice"							type="query" 		default="#queryNew('Fixed_Price')#">
<cfparam name="attributes.qProgramLumpSum"								type="query" 		default="#queryNew('Lump_Sum')#">
<cfparam name="attributes.qProgramOperator"								type="query" 		default="#queryNew('Operator')#">
<cfparam name="attributes.qProgramRebate"									type="query" 		default="#queryNew('Rebate')#">
<!--- queries from the VARS Include for scoping... [end] --->

<!--- opr_path OR dis_path --->
<cfparam name="attributes.relative_path" 						type="string" 	default="">

<cfparam name="attributes.revised_doc_title" 				type="string" 	default="Original">

<!--- end structure --->
<cfparam name="attributes.stPDFEndInfo" 						type="struct" 	default="#structNew()#">

<!--- BODY structure [all boolean] --->
<cfparam name="attributes.stPDFBodyInfo" 												type="struct" 	default="#structNew()#">
<cfparam name="attributes.stPDFBodyInfo.bDisplayBidRequest" 		type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayFixedPrice" 		type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayGrowth" 				type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayLumpSum" 				type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayRebate" 				type="boolean"	default="0">

<cfparam name="attributes.stPDFBodyInfo.bDisplayBidRequestDis" 	type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayBidRequestOpr" 	type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayFixedPriceDis" 	type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayFixedPriceOpr" 	type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayLumpSumDis" 		type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayLumpSumOpr" 		type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayRebateDis" 			type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayRebateOpr" 			type="boolean"	default="0">

<cfparam name="attributes.stPDFBodyInfo.bDisLettersRequired" 		type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisPaysToDistributor" 	type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisPaysToOperator" 		type="boolean"	default="0">

<cfparam name="attributes.stPDFBodyInfo.bOprLettersRequired" 		type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bOprPaysToDistributor" 	type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bOprPaysToOperator" 		type="boolean"	default="0">

<!--- header structure [all strings on purpose] --->
<cfparam name="attributes.stPDFHeaderInfo" 										type="struct" 	default="#structNew()#">
<cfparam name="attributes.stPDFHeaderInfo.company_address" 		type="string" 	default="">
<cfparam name="attributes.stPDFHeaderInfo.company_logo_path" 	type="string" 	default="">
<cfparam name="attributes.stPDFHeaderInfo.contract_number" 		type="string" 	default="">
<cfparam name="attributes.stPDFHeaderInfo.program_id" 				type="string" 	default="">
<cfparam name="attributes.stPDFHeaderInfo.program_title" 			type="string" 	default="">

<!--- NO Footer struct... --->

<!--- intro structure --->
<cfparam name="attributes.stPDFIntroInfo" 																		type="struct" 	default="#structNew()#">
<cfparam name="attributes.stPDFIntroInfo.company" 														type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.contract_end_date" 									type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.contract_start_date" 								type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.freight_notes" 											type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.lsFreightBrackets" 									type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.program_payment_frequency" 					type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.program_pricing_type" 								type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.qNotes" 															type="query" 		default="#queryNew('contract_evaluation_notes_id')#">
<cfparam name="attributes.stPDFIntroInfo.responsible_sales_person_email" 			type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.responsible_sales_person_first_name" type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.responsible_sales_person_last_name" 	type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.responsible_sales_person_phone" 			type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.responsible_sales_person_title" 			type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.template_name" 											type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.total_program_value" 								type="string" 	default="">

<cfparam name="attributes.template_name" 										type="string" 	default="">

<!--- set preferred fontFamily [CSS syntax] to be embedded in all pdf docs --->
<cfparam name="attributes.preferred_fontFamily" 						type="string" 	default="">   

<cfparam name="attributes.bAddcustomerproductnumbers"				type="boolean" 	default="0">
<cfparam name="attributes.bLetterDisplayFreight"							type="boolean"	default="0">
<cfparam name="attributes.bIncludeVolumePage"								type="boolean" 	default="0">
<cfparam name="attributes.customerFreightUom"								type="string"		default="">

<cfparam name="attributes.consignee"												type="string" 	default="">

<cfparam name="attributes.lsDistributorNames" 							type="string" 	default="">
<cfparam name="attributes.lsDistributorIDs" 								type="string" 	default="">
<cfparam name="attributes.lsOperatorNames" 									type="string" 	default="">
<cfparam name="attributes.lsOperatorIDs" 										type="string" 	default="">

<!--- ||| Overwrite the default values with incoming... --->
<cfset structAppend(thisTag, attributes, true)>

<!--- [html, pdf] --->
<cfset thisTag.doc_type = "html">

<cfset thisTag.host 		= cgi.http_host />
<cfset thisTag.protocol 	= application.HTTPVar />

<cfif findNoCase("dist",thisTag.relative_path,1)>
	<cfset thisTag.abbreviation = "dis">
<cfelseif findNoCase("oper",thisTag.relative_path,1)>
	<cfset thisTag.abbreviation = "opr">
<cfelse>
  <!--- nothing on purpose... --->
</cfif>

<cfset thisTag.relative_url = replace(thisTag.relative_path,'\','/','all')>

</cfsilent>

<!--- HTML [begin] --->
<cfoutput>

<!--- ||| Create html doc [begin] ||| --->

	<cfinclude template="doc_modules/inc_all_head_top.cfm">
	
  <!--- we pass our doc_type [html] through here for the CSS... --->
	<cfinclude template="doc_modules/inc_all_head_bottom_body_top.cfm">

	<!--- PDF header [begin] --->
	<cfinclude template="doc_modules/inc_all_header.cfm">
	<!--- PDF header [end] --->

	<!--- Intro [begin] --->
  <cfinclude template="doc_modules/inc_all_intro.cfm">
	<!--- Intro [end] --->

<!--- !!!!!!! We need to break out our CFOutput tags for grouping functionality... --->
</cfoutput>

		<!--- 3.) IF we want fixed_price... AND we have some... --->
    <cfif thisTag.stPDFBodyInfo.bDisplayFixedPrice AND thisTag.qProgramFixedPrice.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayFixedPrice'&thisTag.abbreviation)>

				<!--- ACTION: Ask Deepa --->
				<cfif thisTag.oAppSettings.getFixedComponents_on()>

            <cfoutput query="thisTag.qProgramFixedPrice" group="Program_Fixed_Component_Id" groupcasesensitive="no">

              <!--- header 1 table [begin] --->
              <br /><font></font><br />
              <cfinclude template="doc_modules/headers/inc_#thisTag.abbreviation#_fixed_price_header.cfm">
              <br clear="all">
                <table name="outer_table" width="100%" cellpadding="0" cellspacing="0">
                  <tr>
                    <td align="center" valign="top">
                      <table name="inner_table" width="90%" cellpadding="0" cellspacing="0">
												<!--- 1.) fixed [begin] --->   
                        <tr name="row_4">
                          <td name="leftColumn" colspan="6" valign="top">
                            <h3 class="redText">Component Type: Fixed Price</h3>
                            <br clear="all">
                            <!--- If claims are NOT set at the component level... --->
                            <cfif NOT application.appsettingsget.claims_at_comp_level>
                              <!--- 1 PaymentFrequency --->
                              <cfset thisTag.program_fixed_price_payment_frequency = thisTag.stPDFIntroInfo.program_payment_frequency>
                              <!--- 2 PricingType --->
                              <cfset thisTag.program_fixed_price_pricing_type = thisTag.stPDFIntroInfo.program_pricing_type>
                              <!--- 3 ClaimMechanism --->
                              <cfset thisTag.program_fixed_price_claim_mechanism = "">
                              <!--- TESTING: FP Pymt Clm Mech @ Pgrm Lvl --->
                            <!--- If claims ARE set at the component level... --->
                            <cfelse>
                              <!--- 1 PaymentFrequency --->
                              <cfif application.appsettingsget.paymentCycleAtDiscountType EQ 1>
                                <cfquery name="thisTag.qGetFixedPricePaymentFrequency" datasource="#application.datasource#">
                                  SELECT	Payment_Cycle.Payment_Cycle
                                  FROM		Program_Payment_Cycle,Payment_Cycle,Program_Fixed_Component
                                  WHERE		Program_Payment_Cycle.Program_ID = #thisTag.CMID#
                                  AND			Program_Payment_Cycle.Payment_Cycle_ID = Payment_Cycle.Payment_Cycle_ID	
                                  AND			Program_Payment_Cycle.Discount_Type_id = 1
                                  AND			Program_Fixed_Component.Program_Fixed_Component_id = #Program_Fixed_Component_Id#
                                </cfquery>
                                <cfif thisTag.qGetFixedPricePaymentFrequency.recordCount>
                                  <cfset thisTag.program_fixed_price_payment_frequency = thisTag.qGetFixedPricePaymentFrequency.Payment_Cycle[1]>
                                <cfelse>
                                  <cfset thisTag.program_fixed_price_payment_frequency = "FP Pymt Freq @ Comp Lvl">
                                </cfif>
                              <cfelseif application.appsettingsget.paymentCycleAtDiscountType EQ 0>
                                <cfquery name="thisTag.qGetFixedPricePaymentFrequency" datasource="#application.datasource#">
                                  SELECT	Payment_Cycle.Payment_Cycle
                                  FROM	Payment_Cycle,Program_Payment_Cycle,Program_Fixed_Component,Contract_Main
                                  WHERE	Program_Payment_Cycle.Program_ID = #thisTag.CMID#
                                  AND		Contract_Main.PaymentCycle = Payment_Cycle.Payment_Cycle_ID	
                                  AND		Program_Payment_Cycle.Discount_Type_id = 1
                                  AND		Program_Fixed_Component.Program_Fixed_Component_id = #Program_Fixed_Component_Id#
                                </cfquery>
                                <cfif thisTag.qGetFixedPricePaymentFrequency.recordCount>  
                                  <cfset thisTag.program_fixed_price_payment_frequency = thisTag.qGetFixedPricePaymentFrequency.Payment_Cycle[1]>
                                <cfelse>
                                  <cfset thisTag.program_fixed_price_payment_frequency = "">
                                  <!--- TESTING: FP Pymt Freq @ Comp Lvl --->
                                </cfif>
                              <cfelse>
                                <cfset thisTag.program_fixed_price_payment_frequency = "">
                                <!--- TESTING: FP Pymt Freq @ Comp Lvl --->
                              </cfif>
                              <!--- 2 PricingType --->
                              <cfset thisTag.oProgramData = createObject("component","components.programs.program") />
                              <cfset thisTag.qProgramInfo = thisTag.oProgramData.getProgramInfo(thisTag.CMID)>
                              <cfif thisTag.qProgramInfo.recordCount>
                                <cfset thisTag.program_fixed_price_pricing_type = thisTag.qProgramInfo.fixed_type[1]>
                              <cfelse>
                                <cfset thisTag.program_fixed_price_pricing_type = "">
                                <!--- TESTING: FP Pr Type @ Comp Lvl --->
                              </cfif>
                              <!--- 3 ClaimMechanism --->
                              <cfquery name="thisTag.qGetFixedPriceClaimMechanism" datasource="#application.datasource#">
                                SELECT 		TOP 1 Payment_Type.Payment_Type_Name
                                FROM			Payment_Type,Program_Fixed_Component
                                WHERE 		Program_Fixed_Component.Claim_Mechanics = Payment_Type.Payment_Type_id
                                AND				Program_Fixed_Component.Program_id = #thisTag.CMID#
                              </cfquery>
                              <cfif thisTag.qGetFixedPriceClaimMechanism.recordCount>
                                <cfset thisTag.program_fixed_price_claim_mechanism = thisTag.qGetFixedPriceClaimMechanism.Payment_Type_Name[1]>
                              <cfelse>
                                <cfset thisTag.program_fixed_price_claim_mechanism = "">
                                <!--- TESTING: FP Pymt Clm Mech @ Comp Lvl --->
                              </cfif>
                            </cfif>
                            <!--- NOTE: If claims are set at the component level, or not... [end] --->
                            <table name="header_table" border="0" cellpadding="0" cellspacing="0" width="100%">
                              <tr>
                                <td width="50%">
                                  <span class="redText">Component Name: <b>#thisTag.qProgramFixedPrice.Program_Fixed_Component_Name# #thisTag.qProgramFixedPrice.Program_Fixed_Component_Id#</b></span>
                                 </td>
                                 <td width="50%">
                                  <span class="redText">Claim Mechanism: <b>#thisTag.program_fixed_price_claim_mechanism#</b></span>
                                 </td>
                               </tr>
                             </table>
                            <br clear="all">
                            <!--- header 1 table [end] --->
                            <cfoutput group="Fixed_Component_Paid_to" groupcasesensitive="no">
                              <!--- header 2 table [begin] --->
                              <table name="header_table" border="0" cellpadding="0" cellspacing="0" width="100%">
                                 <tr>
                                   <td width="50%">
                                    <span class="redText">Payable to: <b><cfif Fixed_Component_Paid_to EQ 1>#application.returned_customer_setting.distributor_label_singular#<cfelse>#application.returned_customer_setting.operator_label_singular#</cfif></b></span>
                                   </td>
                                   <td width="50%">
                                    <span class="redText">Pricing Type: <b>#thisTag.program_fixed_price_pricing_type#</b></span>
                                   </td>
                                 </tr>
                                 <tr>
                                  <td width="50%">
                                    <span class="redText">Payment Frequency: <b>#thisTag.program_fixed_price_payment_frequency#</b></span>
                                  </td>
                                  <td width="50%">&nbsp;
                                  </td>
                                 </tr>
                               </table>
                              <br clear="all">
                              <!--- header 2 table [end] --->
                              <!--- inc_dis_fixed_price_outside A [begin] --->
                              <table name="nested_table" border="0" cellpadding="5" cellspacing="0" width="100%">
                                <tr>
                                  <cfif thisTag.bAddcustomerproductnumbers>
                                    <td height="1" class="width_200" width="200">&nbsp;</td>
                                  </cfif>
                                  <td height="1" class="width_300" width="300">&nbsp;</td>
                                  <td height="1" class="width_400" width="400">&nbsp;</td>
                                  <td height="1" class="width_200" width="200">&nbsp;</td>
                                  <td height="1" class="width_100" width="100">&nbsp;</td>
                                  <td height="1" class="width_200" width="200">&nbsp;</td>
                                </tr>
                                
                                <cfset thisTag.fixedCount = 1>
                                
                                <cfoutput>
                                  <tr bgcolor="#iIf(thisTag.qProgramFixedPrice.currentRow MOD 2, DE('ffffff'), DE('eeeeee'))#">
                                    <cfif thisTag.bAddcustomerproductnumbers>
                                      <td class="width_200" width="200"><cfif thisTag.qProgramFixedPrice.customer_product_number NEQ "na" AND len(trim(thisTag.qProgramFixedPrice.customer_product_number))>#thisTag.qProgramFixedPrice.customer_product_number#<cfelse>&nbsp;</cfif></td>
                                    </cfif>
                                    <td class="width_300">#thisTag.qProgramFixedPrice.item#</td>
                                    <td class="width_400">#thisTag.qProgramFixedPrice.description#</td>
                                    <td class="width_200" align="right">$#numberFormat(thisTag.qProgramFixedPrice.fixed_price_per_pound,"_9.9999")#</td>
                                    <td class="width_100" width="100">&nbsp;</td>
                                    <td class="width_200" align="right">$#numberFormat(thisTag.qProgramFixedPrice.fixed_price_per_case,"_99.99")#</td>
                                  </tr>
                                  <cfset thisTag.fixedCount = thisTag.fixedCount + 1>
                                </cfoutput>
                              
                              </table>
                              <!--- inc_dis_fixed_price_outside A [end] --->
                            </cfoutput>
                       		</td>
                        </tr> 
                        <!--- 1.) fixed [end] --->  

  										<!--- page break [begin] --->
											</table>
										</td>
									</tr>
								</table>
            </cfoutput>

        <cfelse>
        
          <!--- !!!!!!! We need to break out our CFOutput tags for grouping functionality... --->                        
          <cfoutput>
            <br /><font></font><br />
            <cfinclude template="doc_modules/headers/inc_#thisTag.abbreviation#_fixed_price_header.cfm">
            <br clear="all">
          		<table name="outer_table" width="100%" cellpadding="0" cellspacing="0">
								<tr>
                  <td align="center" valign="top">
                    <table name="inner_table" width="90%" cellpadding="0" cellspacing="0">
                      <!--- 1.) fixed [begin] --->    
                      <tr name="row_4">
                          <td class="thinBottomBorder" name="leftColumn" colspan="6">
                            <h3 class="redText">Component Type: Fixed Price</h3>
                            <br clear="all">
                            <!--- inc_dis_fixed_price_outside B [begin] --->                    
                            <table name="nested_table" border="0" cellpadding="5" cellspacing="0" width="100%">
                              <tr>
                                <cfif thisTag.bAddcustomerproductnumbers>
                                  <td height="1" class="width_200" width="200">&nbsp;</td>
                                </cfif>
                                <td height="1" class="width_300" width="300">&nbsp;</td>
                                <td height="1" class="width_400" width="400">&nbsp;</td>
                                <td height="1" class="width_200" width="200">&nbsp;</td>
                                <td height="1" class="width_100" width="100">&nbsp;</td>
                                <td height="1" class="width_200" width="200">&nbsp;</td>
                              </tr>
          
            									<cfset thisTag.fixedCount = 1>
          
															<cfoutput query="thisTag.qProgramFixedPrice">
                                <tr bgcolor="#iIf(thisTag.qProgramFixedPrice.currentRow MOD 2, DE('ffffff'), DE('eeeeee'))#">
                                  <cfif thisTag.bAddcustomerproductnumbers>
                                    <td class="width_200" width="200"><cfif thisTag.qProgramFixedPrice.customer_product_number NEQ "na" AND len(trim(thisTag.qProgramFixedPrice.customer_product_number))>#thisTag.qProgramFixedPrice.customer_product_number#<cfelse>&nbsp;</cfif></td>
                                  </cfif>
                                  <td class="width_300">#thisTag.qProgramFixedPrice.item#</td>
                                  <td class="width_400">#thisTag.qProgramFixedPrice.description#</td>
                                  <td class="width_200" align="right">$#numberFormat(thisTag.qProgramFixedPrice.fixed_price_per_pound,"_9.9999")#</td>
                                  <td class="width_100" width="100">&nbsp;</td>
                                  <td class="width_200" align="right">$#numberFormat(thisTag.qProgramFixedPrice.fixed_price_per_case,"_99.99")#</td>
                                </tr>
                                <cfset thisTag.fixedCount = thisTag.fixedCount + 1>
                              </cfoutput>
          
                            </table>
                            <!--- inc_dis_fixed_price_outside B [end] --->
          
          <!--- !!!!!!! We need to break out our CFOutput tags for grouping functionality... --->
          </cfoutput>                          

                         	</td>
                      </tr> 
                      <!--- 1.) fixed [end] --->  

										<!--- page break [begin] --->
                    </table>
									</td>
								</tr>
							</table>
        </cfif>

    </cfif>
    <!--- Fixed Price [end] --->

<!--- !!!!!!! We need to break out our CFOutput tags for grouping functionality... --->
<cfoutput>

		<!--- 4.) IF we want rebate... AND we have some... --->
    <cfif thisTag.stPDFBodyInfo.bDisplayRebate AND thisTag.qProgramRebate.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayRebate'&thisTag.abbreviation)>
    		<br /><font></font><br />
        <cfinclude template="doc_modules/headers/inc_#thisTag.abbreviation#_rebate_header.cfm">
        <cfinclude template="doc_modules/inc_#thisTag.abbreviation#_rebate.cfm">
    </cfif>
    <!--- Rebate [end] --->

<!--- !!!!!!! We need to break out our CFOutput tags for grouping functionality... --->
</cfoutput>

		<!--- 5.) IF we want bid_request... AND we have some... --->
    <cfif thisTag.stPDFBodyInfo.bDisplayBidRequest AND thisTag.qProgramBidRequest.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayBidRequest'&thisTag.abbreviation)>

				<cfif thisTag.oAppSettings.getBidRequestComponentsOn()>

            <cfoutput query="thisTag.qProgramBidRequest" group="Program_BidRequest_Component_Id" groupcasesensitive="no">

              <!--- header 1 table [begin] --->
              <br /><font></font><br />
              <cfinclude template="doc_modules/headers/inc_#thisTag.abbreviation#_bid_request_header.cfm">
              <br clear="all">
                <table name="outer_table" width="100%" cellpadding="0" cellspacing="0">
                  <tr>
                    <td align="center" valign="top">
                      <table name="inner_table" width="90%" cellpadding="0" cellspacing="0">
												<!--- 1.) bidRequest [begin] ---> 
                        <tr name="row_4">
                          <td name="leftColumn" colspan="6" valign="top">
                            <h3 class="redText">Component Type: Proposal</h3>
                            <br clear="all">
                            <!--- If claims are NOT set at the component level... --->
                            <cfif NOT application.appsettingsget.claims_at_comp_level>
                              <!--- 1 PaymentFrequency --->
                              <cfset thisTag.program_bid_request_payment_frequency = thisTag.stPDFIntroInfo.program_payment_frequency>
                              <!--- 2 PricingType --->
                              <cfset thisTag.program_bid_request_pricing_type = thisTag.stPDFIntroInfo.program_pricing_type>
                              <!--- 3 ClaimMechanism --->
                              <cfset thisTag.program_bid_request_claim_mechanism = "">
                              <!--- TESTING: BR Pymt Clm Mech @ Pgrm Lvl --->
                            <!--- If claims ARE set at the component level... --->
                            <cfelse>
                              <!--- 1 PaymentFrequency --->
                              <cfif application.appsettingsget.paymentCycleAtDiscountType EQ 1>
                                <cfquery name="thisTag.qGetBidRequestPaymentFrequency" datasource="#application.datasource#">
                                  SELECT	Payment_Cycle.Payment_Cycle
                                  FROM		Program_Payment_Cycle,Payment_Cycle,Program_BidRequest_Component
                                  WHERE		Program_Payment_Cycle.Program_ID = #thisTag.CMID#
                                  AND			Program_Payment_Cycle.Payment_Cycle_ID = Payment_Cycle.Payment_Cycle_ID	
                                  AND			Program_Payment_Cycle.Discount_Type_id = 10
                                  AND			Program_BidRequest_Component.Program_BidRequest_Component_id = #Program_BidRequest_Component_Id#
                                </cfquery>
                                <cfif thisTag.qGetBidRequestPaymentFrequency.recordCount>
                                  <cfset thisTag.program_bid_request_payment_frequency = thisTag.qGetBidRequestPaymentFrequency.Payment_Cycle[1]>
                                <cfelse>
                                  <cfset thisTag.program_bid_request_payment_frequency = "">
                                  <!--- TESTING: BR Pymt Freq @ Comp Lvl --->
                                </cfif>
                              <cfelseif application.appsettingsget.paymentCycleAtDiscountType EQ 0>
                                <cfquery name="thisTag.qGetBidRequestPaymentFrequency" datasource="#application.datasource#">
                                  SELECT	Payment_Cycle.Payment_Cycle
                                  FROM	Payment_Cycle,Program_Payment_Cycle,Program_BidRequest_Component,Contract_Main
                                  WHERE	Program_Payment_Cycle.Program_ID = #thisTag.CMID#
                                  AND		Contract_Main.PaymentCycle = Payment_Cycle.Payment_Cycle_ID	
                                  AND		Program_Payment_Cycle.Discount_Type_id = 10
                                  AND		Program_BidRequest_Component.Program_BidRequest_Component_id = #Program_BidRequest_Component_Id#
                                </cfquery>
                                <cfif thisTag.qGetBidRequestPaymentFrequency.recordCount>  
                                  <cfset thisTag.program_bid_request_payment_frequency = thisTag.qGetBidRequestPaymentFrequency.Payment_Cycle[1]>
                                <cfelse>
                                  <cfset thisTag.program_bid_request_payment_frequency = "">
                                  <!--- TESTING: BR Pymt Freq @ Comp Lvl --->
                                </cfif>
                              <cfelse>
                                <cfset thisTag.program_bid_request_payment_frequency = "">
                                <!--- TESTING: BR Pymt Freq @ Comp Lvl --->
                              </cfif>
                              <!--- 2  PricingType na --->
                              <!--- 3 ClaimMechanism --->
                              <cfquery name="thisTag.qGetBidRequestClaimMechanism" datasource="#application.datasource#">
                                SELECT 		TOP 1 Payment_Type.Payment_Type_Name
                                FROM			Payment_Type,Program_BidRequest_Component
                                WHERE 		Program_BidRequest_Component.Claim_Mechanics = Payment_Type.Payment_Type_id
                                AND				Program_BidRequest_Component.Program_id = #thisTag.CMID#
                              </cfquery>
                              <cfif thisTag.qGetBidRequestClaimMechanism.recordCount>
                                <cfset thisTag.program_bid_request_claim_mechanism = thisTag.qGetBidRequestClaimMechanism.Payment_Type_Name[1]>
                              <cfelse>
                                <cfset thisTag.program_bid_request_claim_mechanism = "">
                                <!--- TESTING: BR Pymt Clm Mech @ Comp Lvl --->
                              </cfif>
                            </cfif>
                            <!--- NOTE: If claims are set at the component level, or not... [end] --->
                            <table name="header_table" border="0" cellpadding="0" cellspacing="0" width="100%">
                              <tr>
                                <td width="50%">
                                  <span class="redText">Component Name: <b>#thisTag.qProgramBidRequest.Program_BidRequest_Component_Name#<!---   #thisTag.qProgramBidRequest.Program_BidRequest_Component_Id# ---></b></span>
                                 </td>
                                 <td width="50%">
                                  <span class="redText">Claim Mechanism: <b>#thisTag.program_bid_request_claim_mechanism#</b></span>
                                 </td>
                               </tr>
                             </table>
                            <br clear="all">
                            <!--- header 1 table [end] --->
                            <cfoutput group="Program_BidRequest_Component_Paid_to" groupcasesensitive="no">
                              <!--- header 2 table [begin] --->
                              <table name="header_table" border="0" cellpadding="0" cellspacing="0" width="100%">
                                 <tr>
                                   <td width="50%">
                                    <span class="redText">Payable to: <b><cfif Program_BidRequest_Component_Paid_to EQ 1>#application.returned_customer_setting.distributor_label_singular#<cfelse>#application.returned_customer_setting.operator_label_singular#</cfif></b></span>
                                   </td>
                                   <td width="50%">&nbsp;
                                   </td>
                                 </tr>
                                 <tr>
                                  <td width="50%">
                                    <span class="redText">Payment Frequency: <b>#thisTag.program_bid_request_payment_frequency#</b></span>
                                  </td>
                                  <td width="50%">&nbsp;
                                  </td>
                                 </tr>
                               </table>
                              <br clear="all">
                              <!--- header 2 table [end] --->
                              <!--- inc_dis_bid_request_outside A [begin] --->
                              <table name="nested_table" border="0" cellpadding="5" cellspacing="0" width="100%">
                                <tr>
                                  <cfif thisTag.bAddcustomerproductnumbers>
                                    <td height="1" class="width_200" width="200">&nbsp;</td>
                                  </cfif>
                                  <td height="1" class="width_300" width="300">&nbsp;</td>
                                  <td height="1" class="width_400" width="400">&nbsp;</td>
                                  <td height="1" class="width_200" width="200">&nbsp;</td>
                                  <td height="1" class="width_100" width="100">&nbsp;</td>
                                  <td height="1" class="width_200" width="200">&nbsp;</td>
                                </tr>
                                
                                <cfset thisTag.bidRequestCount = 1>
                                
                                <cfoutput>
                                  <tr bgcolor="#iIf(thisTag.qProgramBidRequest.currentRow MOD 2, DE('ffffff'), DE('eeeeee'))#">
                                    <cfif thisTag.bAddcustomerproductnumbers>
                                      <td class="width_200" width="200"><cfif thisTag.qProgramBidRequest.customer_product_number NEQ "na" AND len(trim(thisTag.qProgramBidRequest.customer_product_number))>#thisTag.qProgramBidRequest.customer_product_number#<cfelse>&nbsp;</cfif></td>
                                    </cfif>
                                    <td class="width_300">#thisTag.qProgramBidRequest.item#</td>
                                    <td class="width_400">#thisTag.qProgramBidRequest.description#</td>
                                    <td class="width_200" align="right">$#numberFormat(thisTag.qProgramBidRequest.bid_request_per_pound,"_9.9999")#</td>
                                    <td class="width_100" width="100">&nbsp;</td>
                                    <td class="width_200" align="right">$#numberFormat(thisTag.qProgramBidRequest.bid_request_per_case,"_99.99")#</td>
                                  </tr>
                                  <cfset thisTag.bidRequestCount = thisTag.bidRequestCount + 1>
                                </cfoutput>
                              
                              </table>
                              <!--- inc_dis_bid_request_outside A [end] --->
                            </cfoutput>
                       		</td>
                        </tr> 
                        <!--- 1.) bidRequest [end] --->  

  										<!--- page break [begin] --->
											</table>
										</td>
									</tr>
								</table>
            <!--- !!!!!!! We need to break out our CFOutput tags for grouping functionality... --->
            </cfoutput>

        <cfelse>
        
          <!--- !!!!!!! We need to break out our CFOutput tags for grouping functionality... --->                        
          <cfoutput>
            <br /><font></font><br />
            <cfinclude template="doc_modules/headers/inc_#thisTag.abbreviation#_bid_request_header.cfm">
            <br clear="all">
          		<table name="outer_table" width="100%" cellpadding="0" cellspacing="0">
								<tr>
                  <td align="center" valign="top">
                    <table name="inner_table" width="90%" cellpadding="0" cellspacing="0">
                      <!--- 1.) bidRequest [begin] --->    
                      <tr name="row_4">
                          <td class="thinBottomBorder" name="leftColumn" colspan="6">
                            <h3 class="redText">Component Type: Proposal</h3>
                            <br clear="all">
                            <!--- inc_dis_bid_request_outside B [begin] --->                    
                            <table name="nested_table" border="0" cellpadding="5" cellspacing="0" width="100%">
                              <tr>
                                <cfif thisTag.bAddcustomerproductnumbers>
                                  <td height="1" class="width_200" width="200">&nbsp;</td>
                                </cfif>
                                <td height="1" class="width_300" width="300">&nbsp;</td>
                                <td height="1" class="width_400" width="400">&nbsp;</td>
                                <td height="1" class="width_200" width="200">&nbsp;</td>
                                <td height="1" class="width_100" width="100">&nbsp;</td>
                                <td height="1" class="width_200" width="200">&nbsp;</td>
                              </tr>
          
            									<cfset thisTag.bidRequestCount = 1>
          
															<cfoutput query="thisTag.qProgramBidRequest">
                                <tr bgcolor="#iIf(thisTag.qProgramBidRequest.currentRow MOD 2, DE('ffffff'), DE('eeeeee'))#">
                                  <cfif thisTag.bAddcustomerproductnumbers>
                                    <td class="width_200" width="200"><cfif thisTag.qProgramBidRequest.customer_product_number NEQ "na" AND len(trim(thisTag.qProgramBidRequest.customer_product_number))>#thisTag.qProgramBidRequest.customer_product_number#<cfelse>&nbsp;</cfif></td>
                                  </cfif>
                                  <td class="width_300">#thisTag.qProgramBidRequest.item#</td>
                                  <td class="width_400">#thisTag.qProgramBidRequest.description#</td>
                                  <td class="width_200" align="right">$#numberFormat(thisTag.qProgramBidRequest.bid_request_per_pound,"_9.9999")#</td>
                                  <td class="width_100" width="100">&nbsp;</td>
                                  <td class="width_200" align="right">$#numberFormat(thisTag.qProgramBidRequest.bid_request_per_case,"_99.99")#</td>
                                </tr>
                                <cfset thisTag.bidRequestCount = thisTag.bidRequestCount + 1>
                              </cfoutput>
          
                            </table>
                            <!--- inc_dis_bid_request_outside B [end] --->
          
          <!--- !!!!!!! We need to break out our CFOutput tags for grouping functionality... --->
          </cfoutput>                          

                         	</td>
                      </tr> 
                      <!--- 1.) bidRequest [end] --->  

										<!--- page break [begin] --->
                    </table>
									</td>
								</tr>
							</table>
        </cfif>

    </cfif>
    <!--- Bid Request [end] --->

<!--- !!!!!!! We need to break out our CFOutput tags for grouping functionality... --->
<cfoutput>

    <!--- 6.) IF we want lump_sum... AND we have some... --->
    <cfif thisTag.stPDFBodyInfo.bDisplayLumpSum AND thisTag.qProgramLumpSum.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayLumpSum'&thisTag.abbreviation)>
    		<br /><font></font><br />
        <cfinclude template="doc_modules/headers/inc_#thisTag.abbreviation#_lump_sum_header.cfm">
        <cfinclude template="doc_modules/inc_#thisTag.abbreviation#_lump_sum.cfm">
    </cfif>
    <!--- Lump Sum [end] --->

    <!--- 7.) IF we want growth... --->
    <cfif thisTag.stPDFBodyInfo.bDisplayGrowth>
    	<!--- EMPTY On Purpose... --->
    </cfif>
    <!--- Growth [end] --->   
    
		<!--- 7A.) IF we want to include the volume page --->
    <cfif thisTag.bIncludeVolumePage>
    	<cfinclude template="doc_modules/inc_all_volume.cfm">
    </cfif>
    <!--- Volume Page [end] --->

    <!--- 7B.) IF we want to include the Freight page --->
    <cfif thisTag.bLetterDisplayFreight AND thisTag.qProgramDistributor.recordCount>

			<cfoutput query="thisTag.qProgramDistributor">  

				<cfif thisTag.customerFreightUom EQ 'cs'>
          <cfset thisTag.uomType  = 1>
        <cfelse>
          <cfset thisTag.uomType  = 2>
        </cfif>

				<cfset oProgramDistributorFreight = CreateObject("component", "components.freight.ProgramFreight") />	
        <cfset oProgram 	= createObject("component", "components.programs.Program") />
        <cfset oFixedComp = createObject("component", "components.programs.fixed.FixedComponent") />

				<cfset thisTag.qFOBProgramDistributorFreight = oProgramDistributorFreight.getProgramDistributorFreight(thisTag.stPDFHeaderInfo.program_id,thisTag.qProgramDistributor.bsa_foodservice_customers_ID)>
        <cfset thisTag.qFOBProgramInfo = oProgram.getProgramInfo(thisTag.stPDFHeaderInfo.program_id) />
        <cfset thisTag.qFOBFixedComp = oFixedComp.getFixedPriceDetails(thisTag.stPDFHeaderInfo.program_id)>

				<!--- This duplicate css file must be here. --->
        <cfinclude template="doc_modules/css/inc_all_style.cfm">

        <table name="outer_table" width="100%" cellpadding="0" cellspacing="0" class="freight_text">
          <tr>
            <td align="center" valign="top">
              <table name="inner_table" width="90%" cellpadding="0" cellspacing="0">
                  <tr name="row_4">
                    <td name="leftColumn" colspan="6" align="center">                
                      <table name="nested_table" border="0" cellpadding="5" cellspacing="0" width="100%">
                        <tr>
                          <td height="1" class="width_200" width="200">&nbsp;</td>
                          <td height="1" class="width_300" width="300">&nbsp;</td>
                          <td height="1" class="width_100" width="100" align="right">&nbsp;</td>
                          <td height="1" class="width_100" width="100" align="right">&nbsp;</td>
                          <td height="1" class="width_100" width="100" align="right">&nbsp;</td>
                          <td height="1" class="width_100" width="100" align="right">&nbsp;</td>
                          <td height="1" class="width_100" width="100" align="right">&nbsp;</td>
                          <td height="1" class="width_100" width="100" align="right">&nbsp;</td>
                        </tr> 
                        <tr>
                          <td colspan="3" class="thinTopBorder"><b>Distributor:</b>&nbsp;#thisTag.qFOBProgramDistributorFreight.Name#&nbsp;(#thisTag.qFOBProgramDistributorFreight.Shr_Ship_to#)</td>
                          <td colspan="5" class="thinTopBorder"><b>Span:</b>&nbsp;#DateFormat(thisTag.qFOBProgramInfo.Contract_Start_Date,"MM/DD/YYYY")# - #DateFormat(thisTag.qFOBProgramInfo.Contract_End_Date,"MM/DD/YYYY")#</td>
                        </tr>
                        <tr>
                          <td colspan="3"><b>Warehouse:</b>&nbsp;#thisTag.qFOBProgramDistributorFreight.Warehouse_Name#
                          </td>
                          <td colspan="5"><b>Code:</b>&nbsp;#thisTag.qFOBProgramDistributorFreight.Warehouse_Code#
                          </td>
                        </tr>
                        <tr>
                          <td colspan="3"><b>IBF:</b>&nbsp;#thisTag.qFOBProgramDistributorFreight.IBF_Rate#</td>
                          <td colspan="5"><b>PUA:</b>&nbsp;#thisTag.qFOBProgramDistributorFreight.Pickup_Allowance#</td>
                        </tr>
                        <tr>
                          <td colspan="3"><b>Bracket:</b>&nbsp;#thisTag.qFOBProgramDistributorFreight.Freight_Bracket_Label#
                          </td>
                          <td colspan="5"><b>OBF:</b>&nbsp;#thisTag.qFOBProgramDistributorFreight.OBF_Rate#</td>
                        </tr>
                        <tr>
                          <td colspan="8" class="thinBottomBorder">UOM: <cfif thisTag.customerFreightUom EQ 'cs'>cs<cfelseif thisTag.customerFreightUom EQ 'lb'>lb</cfif></td>
                        </tr>

                            <cfset Program_Fixed_Component_Name_ID_List = "">
                            
                              <cfloop query="thisTag.qFOBFixedComp">
                              
                                <cfif thisTag.uomType EQ 1>
                                
                                  <cfset IBF_Rate = Evaluate((val(thisTag.qFOBProgramDistributorFreight.IBF_Rate)/100) * val(gross_weight))>
                                  <cfset OBF_Rate = Evaluate((val(thisTag.qFOBProgramDistributorFreight.OBF_Rate)/100) * val(gross_weight))>
                                  <cfset Pickup_Allowance = Evaluate((val(thisTag.qFOBProgramDistributorFreight.Pickup_Allowance)/100) * val(gross_weight))>
                                
                                  <cfif Unit_Of_Measure_ID EQ 2>
                                    <cfset FOB =  Evaluate(val(Fixed_Price_Value) * val(net_weight))>
                                  <cfelse>
                                    <cfset FOB =  val(Fixed_Price_Value)>
                                  </cfif>
                                  
                                <cfelse>
                                
                                  <cfset IBF_Rate = Evaluate(((val(thisTag.qFOBProgramDistributorFreight.IBF_Rate)/100)* val(gross_weight)) / val(net_weight))>
                                  <cfset OBF_Rate = Evaluate(((val(thisTag.qFOBProgramDistributorFreight.OBF_Rate)/100)* val(gross_weight)) / val(net_weight))>
                                  <cfset Pickup_Allowance = Evaluate(((val(thisTag.qFOBProgramDistributorFreight.Pickup_Allowance)/100) * val(gross_weight)) / val(net_weight)) >
                                
                                  <cfif Unit_Of_Measure_ID EQ 1>
                                    <cfset FOB =  Evaluate(val(Fixed_Price_Value)  / val(net_weight))>
                                  <cfelse>
                                    <cfset FOB =  val(Fixed_Price_Value)>
                                  </cfif>
                                  
                                </cfif>
                                
                                <cfif Fixed_Component_Type EQ 1>
                                
                                  <cfset Delivered_Price = Evaluate(val(FOB) + val(IBF_Rate) + val(OBF_Rate))>
                                  <cfset FOBDC_Price = Evaluate(val(Delivered_Price) - val(Pickup_Allowance))>
                                  
                                <cfelse>
                                
                                  <!--- ACTION: ask Deepa --->
                                  <cfset Delivered_Price = 0>
                                  <cfset FOBDC_Price = Evaluate(val(FOB) + val(IBF_Rate))>
                                  
                                </cfif>
                                
                                <!--- When UOM is CS --->
                                <cfif thisTag.uomType EQ 1>
                                
                                  <cfset IBF_Rate = NumberFormat(IBF_Rate,',.99')>
                                  <cfset OBF_Rate = NumberFormat(OBF_Rate,',.99')>
                                  <cfset Pickup_Allowance = NumberFormat(Pickup_Allowance,',.99')>
                                  <cfset FOB = NumberFormat(FOB,',.99')>
                                  <cfset FOBDC_Price = NumberFormat(FOBDC_Price,',.99')>
                                  
                                  <cfif Fixed_Component_Type EQ 1>
                                    <cfset Delivered_Price = NumberFormat(Delivered_Price,',.99')>
                                  </cfif>
                                  
                                <cfelse>
                                
                                  <cfset IBF_Rate = NumberFormat(IBF_Rate,',.9999')>
                                  <cfset OBF_Rate = NumberFormat(OBF_Rate,',.9999')>
                                  <cfset Pickup_Allowance = NumberFormat(Pickup_Allowance,',.9999')>
                                  <cfset FOB = NumberFormat(FOB,',.9999')>
                                  <cfset FOBDC_Price = NumberFormat(FOBDC_Price,',.9999')>
                                
                                  <cfif Fixed_Component_Type EQ 1>
                                    <cfset Delivered_Price = NumberFormat(Delivered_Price,',.9999')>
                                  </cfif>
                                  
                                </cfif>
                                
                                <cfif ListFindNoCase(Program_Fixed_Component_Name_ID_List,Program_Fixed_Component_Name_Id) EQ 0>
                                  <tr>
                                    <td colspan="8"><br /><b>#Program_Fixed_Component_Name#</b><br /></td>
                                  </tr>
                                </cfif>
                                <tr bgcolor="#iIf(thisTag.qFOBFixedComp.currentRow MOD 2, DE('ffffff'), DE('eeeeee'))#">
                                  <td class="width_200" width="200">#Item#</td>
                                  <td class="width_300" width="300">#Description#</td>
                                  <td class="width_100" width="100">#FOB#</td>
                                  <td class="width_100" width="100">#IBF_Rate#</td>
                                  <td class="width_100" width="100">#FOBDC_Price#</td>
                                  <td class="width_100" width="100">#OBF_Rate#</td>
                                  <td class="width_100" width="100">#Delivered_Price#</td>
                                  <td class="width_100" width="100">#Pickup_Allowance#</td>
                                </tr>
                              
                                <cfset Program_Fixed_Component_Name_ID_List = ListAppend(Program_Fixed_Component_Name_ID_List,Program_Fixed_Component_Name_Id)>
                                
                              </cfloop>
                            </table>
                          </td>
                        </tr>
                      </table>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>

			</cfoutput>

    </cfif>
    <!--- Freight Page [end] --->
    
    <!--- 8.) IF we have clauses [begin] --->
		<cfif thisTag.qProgramClause.recordCount>
  		<br /><font></font><br />
      <cfinclude template="doc_modules/inc_all_clauses.cfm">
		</cfif>
    <!--- Clauses [end] --->

    <!--- Payment Type [begin] --->
      <!--- <cfinclude template="doc_modules/inc_all_payment_type.cfm"> --->
		<!--- Payment Type [end] --->
	
		<!--- Signatures [begin] --->
    <cfinclude template="doc_modules/inc_#thisTag.abbreviation#_signatures.cfm">
    <!--- Signatures [end] --->
  
		<cfinclude template="doc_modules/inc_all_body_bottom.cfm">

<!--- ||| Create html doc [end] ||| --->

<!--- !!!!!!! We need to break out our CFOutput tags for grouping functionality... --->
</cfoutput>
<!--- HTML [end] --->