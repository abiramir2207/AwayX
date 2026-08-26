<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/inc_dis_fob.cfm
CREATED: 		03/12/2008 - RBL
EDITED:			03/12/2008 - RBL

FUNCTIONALITY:
- This include template is utilized to display the FOB Info module for ONE Distributor/Customer for the Deal Letters v2...
The cfoutput tags ARE needed for this include.
--->

<!--- These parameters are required for this template to process correctly --->
<cfparam name="thisTag.customerFobUom" 																			type="string"		default="">
<cfparam name="thisTag.qProgramDistributor.bsa_foodservice_customers_ID[1]" type="string"		default="">
<cfparam name="thisTag.stPDFHeaderInfo.program_id" 													type="numeric"	default="0">
<cfparam name="thisTag.uomType" 																						type="string" 	default="">

</cfsilent>

<cfif NOT len(trim(thisTag.uomType))>
	<cfif thisTag.customerFobUom EQ 'cs'>
		<cfset thisTag.uomType  = 1>
	<cfelse>
		<cfset thisTag.uomType  = 2>
	</cfif>
</cfif>

<cfset oProgramDistributorFreight = CreateObject("component", "components.freight.ProgramFreight") />	
<cfset oProgram = CreateObject("component", "components.programs.Program") />
<cfset oFixedComp = CreateObject("component", "components.programs.fixed.FixedComponent") />
	
<cfset thisTag.qFOBProgramDistributorFreight = oProgramDistributorFreight.getProgramDistributorFreight(thisTag.stPDFHeaderInfo.program_id,thisTag.qProgramDistributor.bsa_foodservice_customers_ID[1])>
<cfset thisTag.qFOBProgramInfo = oProgram.getProgramInfo(thisTag.stPDFHeaderInfo.program_id) />
<cfset thisTag.qFOBFixedComp = oFixedComp.getFixedPriceDetails(thisTag.stPDFHeaderInfo.program_id)>

<!--- This duplicate css file must be here. --->
<cfinclude template="css/inc_all_style.cfm">

<cfoutput>
<table name="outer_table" width="100%" cellpadding="0" cellspacing="0">
  <tr>
    <td align="center" valign="top">
      <table name="inner_table" width="90%" cellpadding="0" cellspacing="0">
          <tr name="row_4">
          	<td name="leftColumn" colspan="6" align="center">                   
            	<table name="nested_table" border="0" cellpadding="5" cellspacing="0" width="100%">    
                <tr>
                  <td align="left" valign="top" width="100%">
                  <!--- summary info... --->
                  <table border="0" cellpadding="5" cellspacing="0">
                    <tr>
                    	<td><b>Program ##:</b>&nbsp;#thisTag.qFOBProgramInfo.Contract_Number#</td>
                    </tr>
                    <tr>
                    	<td><b>Title:</b>&nbsp;#thisTag.qFOBProgramInfo.Contract_Title#</td>
                    </tr>
                    <tr>
                    	<td><b>Span:</b>&nbsp;#DateFormat(thisTag.qFOBProgramInfo.Contract_Start_Date,"MM/DD/YYYY")# - #DateFormat(thisTag.qFOBProgramInfo.Contract_End_Date,"MM/DD/YYYY")#</td>
                    </tr>
                    <tr>
                    	<td><b>Distributor:</b>&nbsp;#thisTag.qFOBProgramDistributorFreight.Name#&nbsp;(#thisTag.qFOBProgramDistributorFreight.Shr_Ship_to#)</td>
                    </tr>
                    <tr>
                    	<td><b>Warehouse:</b>&nbsp;#thisTag.qFOBProgramDistributorFreight.Warehouse_Name#&nbsp;(#thisTag.qFOBProgramDistributorFreight.Warehouse_Code#)
                    &nbsp;&nbsp;<b>Bracket:</b>&nbsp;#thisTag.qFOBProgramDistributorFreight.Freight_Bracket_Label#
                    	</td>
                    </tr>
                    <tr>
                      <td><b>IBF:</b>&nbsp;#thisTag.qFOBProgramDistributorFreight.IBF_Rate#&nbsp;&nbsp;<b>OBF:</b>&nbsp;#thisTag.qFOBProgramDistributorFreight.OBF_Rate#
                      &nbsp;&nbsp;<b>PUA:</b>&nbsp;#thisTag.qFOBProgramDistributorFreight.Pickup_Allowance#
                      </td>
                    </tr>
                  </table>
                  <br clear="all" />
                  <table border="0" cellspacing="0" width="100%">
                    <tr bgcolor="##eeeeee">
                      <td width="20%"><b>ITEM</b></td>
                      <td width="32%"><b>DESCRIPTION</b></td>
                      <td width="7%"><b>FOB</b></td>
                      <td width="7%"><b>IBF</b></td>
                      <td width="7%"><b>FOB FDC</b></td>
                      <td width="7%"><b>OBF</b></td>
                      <td width="9%"><b>DELIVERED</b></td>
                      <td width="4%"><b>PUA</b></td>
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
                            <td><b>#Program_Fixed_Component_Name#</b></td>
                          </tr>
                        </cfif>
                        <tr bgcolor="#iIf(thisTag.qFOBFixedComp.currentRow MOD 2, DE('ffffff'), DE('eeeeee'))#">
                          <td width="20%">#Item#</td>
                          <td width="32%">#Description#</td>
                          <td width="7%">&nbsp;#FOB#</td>
                          <td width="7%">&nbsp;#IBF_Rate#</td>
                          <td width="7%">&nbsp;#FOBDC_Price#</td>
                          <td width="7%">&nbsp;#OBF_Rate#</td>
                          <td width="7%">&nbsp;#Delivered_Price#</td>
                          <td width="4%" >&nbsp;&nbsp;#Pickup_Allowance#</td>
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