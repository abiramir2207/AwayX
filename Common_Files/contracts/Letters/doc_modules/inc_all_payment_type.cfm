<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/inc_all_payment_type.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			01/31/2008 - RBL

FUNCTIONALITY:
- This include template is utilized to display the "Payment Type" module within the Deal Letters v2...
ACTION: Q: why cfoutput, leave.
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
              
              <!--- Payment Types [begin] --->
              <cfoutput>
                  <tr name="row_9">
                      <td colspan="6" align="center">
                          <table name="nested_table" border="0" cellpadding="5" cellspacing="0" width="100%">
                          		<tr>
                                <td valign="middle" align="left" width="100%">
                                  <br /><font></font><br />
                                  <h3 class="redText">Program Payment</h3>
                                </td>
                              </tr>
                              <tr>
                                <td valign="middle" align="left" width="100%" class="header_text">
                                    <cfif thisTag.qGetProgramDetails.Discount_Fixed_Prices EQ 1 AND thisTag.qGetTemplateSettings.Distributor_Fixed_Pricing EQ 1>
                                      <cfif thisTag.qProgramFixedPrice.recordCount>
                                        <cfquery name="thisTag.qGetFixedPaidTo" datasource="#application.datasource#">
                                            SELECT 	distinct Fixed_Component_Paid_to 
											FROM ##TMP_fixed_price_details
                                            WHERE 	0 = 0
                                            AND  	Fixed_Component_Paid_to IN (<cfif thisTag.qGetTemplateSettings.Distributor_paysto_opr EQ 1>'2'<cfelse> '0'</cfif>,<cfif thisTag.qGetTemplateSettings.Distributor_paysto_dis EQ 1>'1'<cfelse>'0'</cfif>) 
                                        </cfquery>
                                        <cfif thisTag.qGetFixedPaidTo.recordCount>
                                          <cfloop query="thisTag.qGetFixedPaidTo">
                                            Fixed Price Paid to
                                            <cfif Fixed_Component_Paid_to EQ 1>
                                              #application.returned_customer_setting.distributor_label_singular#
                                              <cfelse>
                                              #application.returned_customer_setting.operator_label_singular#
                                            </cfif>
                                            <br>
                                          </cfloop>
                                        </cfif>
                                      </cfif>
                                    </cfif>
                                    <cfif thisTag.qGetProgramDetails.Discount_Rebates EQ 1 AND thisTag.qGetTemplateSettings.Distributor_Rebate EQ 1>
                                      <cfif thisTag.qProgramRebate.recordCount>
                                        <cfquery name="thisTag.qGetRebatePaidTo" datasource="#application.datasource#">
                                            SELECT 	distinct Component_Paid_to 
											FROM ##TMP_Rebate_price_details
                                            WHERE 	0 = 0
                                            AND  	Component_Paid_to IN (<cfif thisTag.qGetTemplateSettings.Distributor_paysto_opr EQ 1>2<cfelse> 0</cfif>,<cfif thisTag.qGetTemplateSettings.Distributor_paysto_dis EQ 1>1<cfelse>0</cfif>) 
                                        </cfquery>
                                        <cfif thisTag.qGetRebatePaidTo.recordCount>
                                          <cfloop query="thisTag.qGetRebatePaidTo">
                                            #Application.RebateLabel# Paid to
                                            <cfif Component_Paid_to EQ 1>
                                              #application.returned_customer_setting.distributor_label_singular#
                                              <cfelse>
                                              #application.returned_customer_setting.operator_label_singular#
                                            </cfif>
                                            <br>
                                          </cfloop>
                                        </cfif>
                                      </cfif>
                                    </cfif>
                                </td>
                            </tr>
                          </table>
                      </td>
                  </tr>
              </cfoutput>
              <!--- Payment Types [end] --->
   
          </table>
      </td>
  </tr>
</table>	