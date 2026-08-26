<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/inc_opr_bid_request.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			02/20/2008 - RBL

FUNCTIONALITY:
- This include template is utilized to display the "Operator Bid Request" module within the Deal Letters v2...
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
          <!--- page break [end] --->

              <!--- 2.) BidRequest [begin] --->    
              <cfif thisTag.qGetProgramDetails.Generic_Type EQ "Bid Request" AND thisTag.qGetTemplateSettings.Operator_Bid_Request EQ 1>
                <cfif thisTag.qProgramBidRequest.recordCount>
                  
                  <tr name="row_5">
                      <td class="thinBottomBorder" name="leftColumn" colspan="6" valign="top">
                          <cfif appSettings.getBidRequestComponentsOn()>
                          	<br clear="all">
                            <h3 class="redText">Component Type: Proposal</h3>
                            <cfoutput query="thisTag.qProgramBidRequest" group="Program_Bidrequest_Component_Id" groupcasesensitive="no">
                            	<!--- header 1 table [begin] --->
                              <br />
                              <br clear="all">
                              <!--- If claims are NOT set at the component level... --->
                              <cfif NOT application.appsettingsget.claims_at_comp_level>
                                <!--- 1 PaymentFrequency --->
																<cfset thisTag.program_bid_request_payment_frequency = thisTag.qLetterInfo.payment_cycle[1]>
                                <!--- 2 PricingType
                                <cfset thisTag.program_bid_request_pricing_type = thisTag.qProgramInfo.fixed_type[1]> na --->
                                <!--- 3 ClaimMechanism --->
                                <cfset thisTag.program_bid_request_claim_mechanism = "BR Pymt Clm Mech @ Pgrm Lvl">
                              <!--- If claims ARE set at the component level... --->
                              <cfelse>
                              	<!--- 1 PaymentFrequency --->
                                <cfif application.appsettingsget.paymentCycleAtDiscountType EQ 1>
                                	<cfquery name="thisTag.qGetBidRequestPaymentFrequency" datasource="#application.datasource#">
																		SELECT	Payment_Cycle.Payment_Cycle
                                    FROM		Program_Payment_Cycle,Payment_Cycle,Program_Bidrequest_Component
                                    WHERE		Program_Payment_Cycle.Program_ID = #thisTag.CMID#
                                    AND			Program_Payment_Cycle.Payment_Cycle_ID = Payment_Cycle.Payment_Cycle_ID	
                                    AND			Program_Payment_Cycle.Discount_Type_id = 10
                                    AND			Program_Bidrequest_Component.Program_Bidrequest_Component_id = #Program_Bidrequest_Component_Id#
                              		</cfquery>
                                  <cfif thisTag.qGetBidRequestPaymentFrequency.recordCount>
                                		<cfset thisTag.program_bid_request_payment_frequency = thisTag.qGetBidRequestPaymentFrequency.Payment_Cycle[1]>
                                  <cfelse>
                                  	<cfset thisTag.program_bid_request_payment_frequency = "BR Pymt Freq @ Comp Lvl">
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
                                  	<cfset thisTag.program_bid_request_payment_frequency = "BR Pymt Freq @ Comp Lvl">
                                  </cfif>
                                <cfelse>
                                	<cfset thisTag.program_bid_request_payment_frequency = "BR Pymt Freq @ Comp Lvl">
                                </cfif>
                                <!--- 2 PricingType
                                <cfset thisTag.program_bid_request_pricing_type = "BR Pr Type @ Comp Lvl"> na --->
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
                                	<cfset thisTag.program_bid_request_claim_mechanism = "BR Pymt Clm Mech @ Comp Lvl">
                                </cfif>
                              </cfif>
                              <!--- NOTE: If claims are set at the component level, or not... [end] --->
                              <table name="header_table" border="0" cellpadding="0" cellspacing="0" width="100%">
                                <tr>
                                  <td width="50%">
                                    <span class="redText">Component Name: <b>#Program_Bidrequest_Component_Name# #Program_BidRequest_Component_Id#</b></span>
                                   </td>
                                   <td width="50%">
                                    <span class="redText">Claim Mechanism: <b>#thisTag.program_bid_request_claim_mechanism#</b></span>
                                   </td>
                                 </tr>
                               </table>
                              <br clear="all">
                              <!--- header 1 table [end] --->
                              <cfoutput group="Program_Bidrequest_Component_Paid_to" groupcasesensitive="no">
                              <!--- header 2 table [begin] --->
                              <table name="header_table" border="0" cellpadding="0" cellspacing="0" width="100%">
                                 <tr>
                                   <td width="50%">
                                    <span class="redText">Payable to: <b><cfif Program_Bidrequest_Component_Paid_to EQ 1>#application.returned_customer_setting.distributor_label_singular#<cfelse>#application.returned_customer_setting.operator_label_singular#</cfif></b></span>
                                   </td>
                                   <td width="50%">&nbsp;
                                    <!--- <span class="redText">Pricing Type: <b>#thisTag.program_bid_request_pricing_type#</b></span> na --->
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

                                <table name="nested_table" border="0" cellpadding="5" cellspacing="0" width="100%">
                                  <tr>
                                    <td height="1" class="width_300" width="300">&nbsp;</td>
                                    <td height="1" class="width_400" width="400">&nbsp;</td>
                                    <td height="1" class="width_200" width="200">&nbsp;</td>
                                    <td height="1" class="width_100" width="100">&nbsp;</td>
                                    <td height="1" class="width_200" width="200">&nbsp;</td>
                                  </tr>

                                  <cfset fixedcount = 1>
                                  <cfoutput>
                                    <tr bgcolor="#iIf(thisTag.qProgramBidRequest.currentRow MOD 2, DE('ffffff'), DE('eeeeee'))#">
                                      <td class="width_300">#thisTag.qProgramBidRequest.item#</td>
                                      <td class="width_400">#thisTag.qProgramBidRequest.description#</td>
                                      <td class="width_200" align="right">$#numberFormat(thisTag.qProgramBidRequest.fixed_price_per_pound,"__.9999")#</td>
                                      <td class="width_100" width="100">&nbsp;</td>
                                      <td class="width_200" align="right">$#numberFormat(thisTag.qProgramBidRequest.fixed_price_per_case,"_99.99")#</td>
                                    </tr>
                                    <cfset fixedcount = fixedcount + 1>
                                    </cfoutput>
                                </table>
                              </cfoutput>
                             </cfoutput>
                          <cfelse>   
                             <table name="nested_table" border="0" cellpadding="5" cellspacing="0" width="100%">
                              <tr>
                                <td height="1" class="width_300" width="300">&nbsp;</td>
                                <td height="1" class="width_400" width="400">&nbsp;</td>
                                <td height="1" class="width_200" width="200">&nbsp;</td>
                                <td height="1" class="width_100" width="100">&nbsp;</td>
                                <td height="1" class="width_200" width="200">&nbsp;</td>
                              </tr>
                              
                              <cfset fixedcount = 0>
                              <cfoutput query="thisTag.qProgramBidRequest">
                                <tr bgcolor="#iIf(thisTag.qProgramBidRequest.currentRow MOD 2, DE('ffffff'), DE('eeeeee'))#">
                                  <td class="width_300">#thisTag.qProgramBidRequest.item#</td>
                                  <td class="width_400">#thisTag.qProgramBidRequest.description#</td>
                                  <td class="width_200" align="right">$#numberFormat(thisTag.qProgramBidRequest.fixed_price_per_pound,"__.9999")#</td>
                                  <td class="width_100" width="100">&nbsp;</td>
                                  <td class="width_200" align="right">$#numberFormat(thisTag.qProgramBidRequest.fixed_price_per_case,"_99.99")#</td>
                                </tr>
                                <cfset fixedcount = fixedcount + 1>
                              </cfoutput>
                            </table>   
                          </cfif>    
                      </td>
                  </tr>
                 </cfif>
              </cfif>
              <!--- 2.) BidRequest [end] --->

     <!--- page break [begin] --->    
     </table>
   </td>
 </tr>
</table>