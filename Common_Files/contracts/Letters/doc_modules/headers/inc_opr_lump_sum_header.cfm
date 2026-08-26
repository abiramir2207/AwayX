<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/headers/inc_opr_lump_sum_header.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			05/09/2008 - RBL

FUNCTIONALITY:
- This header include is used for the the Operator Lump Sum Deal Letters ONLY...
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
       <table name="inner_table" class="top noBorderNoPadNoMargin" width="90%" cellpadding="1" cellspacing="0" border="0">
          <!--- <tr name="row_4">
              <td name="leftColumn" align="center" valign="top">         
                 <table name="nested_table" height="50" class="height_50" width="100%" cellpadding="0" cellspacing="0" border="0"> --->
                 		<tr>
                     		<td colspan="3" valign="middle" class="thinTopBorder grayBG"><h2 class="redText">Component Type: <cfoutput>#Application.LumpSumLabel#</cfoutput></h2></td>
                     </tr>    
                     <tr>
                     	<td class="thinBottomBorder width_300 grayBG" width="300" valign="middle"><b>Item No</b></td>
                        <td class="thinBottomBorder width_400 grayBG" width="400" valign="middle"><b>Item Description</b></td>
                        <td class="thinBottomBorder width_200 grayBG" width="200" align="right" valign="middle"><b>Amount</b>&nbsp;</td>
                      </tr>
                  <!--- </table>      
               </td>
           </tr> --->
        </table>
    </td>
  </tr>
</table>