<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/headers/inc_dis_bid_request_header.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			05/09/2008 - RBL

FUNCTIONALITY:
- This header include is used for the the Distributor Bid Request Deal Letters ONLY...
--->

<!--- These parameters are required for this template to process correctly --->
<!--- na --->
</cfsilent>
<!--- This duplicate css file must be here. --->
<cfinclude template="../css/inc_all_style.cfm">
<!--- height="50" height_50 --->
<table name="outer_table" class="top noBorderNoPadNoMargin" width="100%" cellpadding="0" cellspacing="0" border="0">
  <tr>
    <td align="center" valign="top">
    	<!--- height="50" height_50 --->
       <table name="inner_table" class="top noBorderNoPadNoMargin" width="90%" cellpadding="0" cellspacing="0" border="0">
          <!--- <tr name="row_4">
              <td name="leftColumn" align="center" valign="top">         
                 <table name="nested_table" height="50" class="height_50" width="100%" cellpadding="0" cellspacing="0" border="0"> --->
                 		<tr>
                     		<td colspan="<cfif thisTag.bAddcustomerproductnumbers>6<cfelse>5</cfif>" valign="middle" class="thinTopBorder grayBG"><h2 class="redText">Component Type: Proposal</h2></td>
                     </tr>     
                     <tr>
                        <cfif thisTag.bAddcustomerproductnumbers>
                          <td class="thinBottomBorder width_200 grayBG" width="200" valign="middle"><b>Cust Prod No</b></td>
                        </cfif>
                        <!--- <cfoutput>#UCASE(application.returned_customer_setting.customer_keyword)#</cfoutput><br /> --->
                        <td class="thinBottomBorder width_300 grayBG" width="300" valign="middle"><b>Item No</b></td>
                        <td class="thinBottomBorder width_400 grayBG" width="400" valign="middle"><b>Item Description</b></td>
                        <td class="thinBottomBorder width_200 grayBG" width="200" align="right" valign="middle"><b>Price/LB</b>&nbsp;</td>
                        <td class="thinBottomBorder width_100 grayBG" width="100" valign="middle">&nbsp;</td>
                        <td class="thinBottomBorder width_200 grayBG" width="200" align="right" valign="middle"><b>Price/CS</b>&nbsp;</td>
                      </tr>
                  <!--- </table>      
               </td>
           </tr> --->
        </table>
    </td>
  </tr>
</table>