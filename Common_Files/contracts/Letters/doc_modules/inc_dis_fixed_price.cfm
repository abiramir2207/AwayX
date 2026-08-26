<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/inc_dis_fixed_price.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			05/27/2008 - RBL

FUNCTIONALITY:
- This include template is utilized to display the "Distributor Fixed Price" module within the Deal Letters v2...
--->

<!--- These parameters are required for this template to process correctly --->
<!--- na --->
</cfsilent>
<!--- This duplicate css file must be here. --->
<cfinclude template="css/inc_all_style.cfm">
<table name="outer_table" width="100%" cellpadding="0" cellspacing="0">
  <tr>
      <td align="center" valign="top">
          <table name="inner_table" width="90%" cellpadding="0" cellspacing="0">
          
          <!--- page break [end]
          <cfinclude template="queries/inc_dis_fixed_price_query.cfm"> --->    

               <!--- 1.) fixed [begin] --->    
              <cfif thisTag.qGetProgramDetails.Discount_Fixed_Prices EQ 1 AND thisTag.qGetTemplateSettings.Distributor_Fixed_Pricing EQ 1>
                <cfif thisTag.qProgramFixedPrice.recordCount>                      

                  <tr name="row_4">
                      <td class="thinBottomBorder" name="leftColumn" colspan="6" valign="top">
                                   
                       <cfif thisTag.oAppSettings.getfixedcomponents_on()>
                         <h3 class="redText">Component Type: Fixed Price</h3>
                            <cfoutput query="thisTag.qProgramFixedPrice" group="Program_Fixed_Component_Id" groupcasesensitive="no">
															<!--- header 1 table [begin] --->
                              <br />
                              <br clear="all">
															<!--- If claims are NOT set at the component level... --->
                              <cfif NOT application.appsettingsget.claims_at_comp_level>
                                <!--- 1 PaymentFrequency --->
                                <cfset thisTag.program_fixed_price_payment_frequency = thisTag.stPDFIntroInfo.program_payment_frequency>
                                <!--- 2 PricingType --->
																<cfset thisTag.program_fixed_price_pricing_type = thisTag.stPDFIntroInfo.program_pricing_type>
                                <!--- 3 ClaimMechanism --->
                                <cfset thisTag.program_fixed_price_claim_mechanism = "FP Pymt Clm Mech @ Pgrm Lvl">
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
                                  	<cfset thisTag.program_fixed_price_payment_frequency = "FP Pymt Freq @ Comp Lvl">
                                  </cfif>
                                <cfelse>
                                	<cfset thisTag.program_fixed_price_payment_frequency = "FP Pymt Freq @ Comp Lvl">
                                </cfif>
                                <!--- 2 PricingType --->
                                <cfset thisTag.oProgramData = createObject("component","components.programs.program") />
																<cfset thisTag.qProgramInfo = thisTag.oProgramData.getProgramInfo(thisTag.CMID)>
                                <cfif thisTag.qProgramInfo.recordCount>
                                	<cfset thisTag.program_fixed_price_pricing_type = thisTag.qProgramInfo.fixed_type[1]>
                                <cfelse>
                                	<cfset thisTag.program_fixed_price_pricing_type = "FP Pr Type @ Comp Lvl">
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
                                	<cfset thisTag.program_fixed_price_claim_mechanism = "FP Pymt Clm Mech @ Comp Lvl">
                                </cfif>
                              </cfif>
                              <!--- NOTE: If claims are set at the component level, or not... [end] --->
                              <table name="header_table" border="0" cellpadding="0" cellspacing="0" width="100%">
                                <tr>
                                  <td width="50%">
                                    <span class="redText">Component Name: <b>#Program_Fixed_Component_Name# #Program_Fixed_Component_Id#</b></span>
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
                                  <cfset fixedcount = 1>
                                  <cfoutput>
                                    <tr bgcolor="#iIf(thisTag.qProgramFixedPrice.currentRow MOD 2, DE('ffffff'), DE('eeeeee'))#">
                                      <cfif thisTag.bAddcustomerproductnumbers>
                                        <td class="width_200" width="200"><cfif thisTag.qProgramFixedPrice.customer_product_number NEQ "na" AND len(trim(thisTag.qProgramFixedPrice.customer_product_number))>#thisTag.qProgramFixedPrice.customer_product_number#<cfelse>&nbsp;</cfif></td>
                                      </cfif>
                                      <td class="width_300">#thisTag.qProgramFixedPrice.item#</td>
                                      <td class="width_400" nowrap="nowrap">#thisTag.qProgramFixedPrice.description#</td>
                                      <td class="width_200" align="right">$#numberFormat(thisTag.qProgramFixedPrice.fixed_price_per_pound,"_9.9999")#</td>
                                      <td class="width_100" width="100">&nbsp;</td>
                                      <td class="width_200" align="right">$#numberFormat(thisTag.qProgramFixedPrice.fixed_price_per_case,"_99.99")#</td>
                                    </tr>
                                    <cfset fixedcount = fixedcount + 1>
                                    </cfoutput>
                                </table>
                             </cfoutput>
                          </cfoutput>
                        <cfelse>
                        
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
                                <cfset fixedcount = 0>
                                <cfoutput query="thisTag.qProgramFixedPrice">
                                  <tr bgcolor="#iIf(thisTag.qProgramFixedPrice.currentRow MOD 2, DE('ffffff'), DE('eeeeee'))#">
                                    <cfif thisTag.bAddcustomerproductnumbers>
                                      <td class="width_200" width="200"><cfif thisTag.qProgramFixedPrice.customer_product_number NEQ "na" AND len(trim(thisTag.qProgramFixedPrice.customer_product_number))>#thisTag.qProgramFixedPrice.customer_product_number#<cfelse>&nbsp;</cfif></td>
                                    </cfif>
                                    <td class="width_300">#thisTag.qProgramFixedPrice.item#</td>
                                    <td class="width_400" nowrap="nowrap">#thisTag.qProgramFixedPrice.description#</td>
                                    <td class="width_200" align="right">$#numberFormat(thisTag.qProgramFixedPrice.fixed_price_per_pound,"_9.9999")#</td>
                                    <td class="width_100" width="100">&nbsp;</td>
                                    <td class="width_200" align="right">$#numberFormat(thisTag.qProgramFixedPrice.fixed_price_per_case,"_99.99")#</td>
                                  </tr>
                                  <cfset fixedcount = fixedcount + 1>
                                </cfoutput>
                                 
                              </table>
                          </cfif>        
                      </td>
                  </tr>
                </cfif>
              </cfif>   
              <!--- 1.) fixed [end] --->  

     <!--- page break [begin] --->
         
     </table>
   </td>
 </tr>
</table>