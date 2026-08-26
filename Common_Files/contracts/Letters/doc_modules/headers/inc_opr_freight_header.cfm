<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/headers/inc_dis_freight_header.cfm
CREATED: 		03/17/2007 - RBL
EDITED:			05/09/2008 - RBL

FUNCTIONALITY:
- This header include is used for the the Distributor Freight Deal Letters ONLY...
--->

<!--- These parameters are required for this template to process correctly --->
<!--- na --->
</cfsilent>
<!--- This duplicate css file must be here. --->
<cfinclude template="../css/inc_all_style.cfm">
<table name="outer_table" height="50" class="height_50 top noBorderNoPadNoMargin" width="100%" cellpadding="0" cellspacing="0" border="0">
  <tr>
    <td align="center" valign="top">
       <table name="inner_table" height="50" class="height_50 top noBorderNoPadNoMargin" width="90%" cellpadding="0" cellspacing="0" border="0">
          <tr name="row_4">
              <td name="leftColumn" align="center" valign="top">         
                 <table name="nested_table" height="50" class="height_50" width="100%" cellpadding="2" cellspacing="0" border="0">
                     <tr>
                     		<cfif thisTag.qFOBFixedComp.Fixed_Component_Type[1] EQ 1>
                     			<td class="thinBottomBorder thinTopBorder width_200 grayBG" width="200" valign="middle"><b>Item No</b></td>
                          <td class="thinBottomBorder thinTopBorder width_500 grayBG" width="500" valign="middle"><b>Description</b></td>
                          <td class="thinBottomBorder thinTopBorder width_150 grayBG" width="150" valign="middle"><b>Delivered</b></td>
                          <td class="thinBottomBorder thinTopBorder width_150 grayBG" width="150" valign="middle"><b>PUA</b></td>
                          <td class="thinBottomBorder thinTopBorder width_150 grayBG" width="150" valign="middle"><b>FOB FDC</b></td>
                     		<cfelse>
                          <td class="thinBottomBorder thinTopBorder width_400 grayBG" width="400" valign="middle"><b>Item No</b></td>
                          <td class="thinBottomBorder thinTopBorder width_400 grayBG" width="400" valign="middle"><b>Description</b></td>
                          <td class="thinBottomBorder thinTopBorder width_300 grayBG" width="300" valign="middle"><b>FOB FDC</b></td>
                     		</cfif>
                      </tr>
                  </table>      
               </td>
           </tr>
        </table>
    </td>
  </tr>
</table>