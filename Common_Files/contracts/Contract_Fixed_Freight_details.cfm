<style type="text/css">
td.locked_top,th.locked_top{
		background-color:#ffce84;
    /* CSS expressions are not a part of IE 10. Comment the code below. Instead use the "keepHeaderFixed" function. */
    /*top: expression(document.getElementById('table_container').scrollTop);*/
    position: relative;
    z-index: 1;
  }

  #table_container {
     height: 200px;
     overflow: scroll;
		 overflow-x: hidden;
  }
</style>

<script>
function keepHeaderFixed(topPosition,leftPosition){
	/* CODE FOR VERTICAL SCROLLING */
	
	/* Find the element which is a "<td>" */
	var cellObject = document.getElementsByTagName("td");
	   
	   /*Loop through the "<td>" object. Look for specific "id" (below), then move that cell from the top based on scroll position.
	   The position of the "<td>" will match the scroll position.
	   */
	   for(i=0;i<cellObject.length;i++)
	   {
		if (cellObject[i].getAttribute('id') == 'header') {
			cellObject[i].style.top = topPosition;
		}
	   }
}
</script>

<cfparam name="UOM_Type" default="">

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfif UOM_Type eq "">
	<cfif appSettings.getMarginDisplaydefault() EQ 1>
		<cfset UOM_Type  = 1>
	<cfelse>
		<cfset UOM_Type  = 2>
	</cfif>
</cfif>

<cfset objProgramDistributorFreight = CreateObject("component", "components.freight.ProgramFreight") />	
<cfset objProgram = CreateObject("component", "components.programs.Program") />
<cfset objFixedComp = CreateObject("component", "components.programs.Fixed.FixedComponent") />
<cfset objFreight = CreateObject("component","components.freight.FreightBracketSetting") />

<cfset objFreight.getFreightSettings()  />
<cfset qryProgramDistributorFreight = objProgramDistributorFreight.getProgramDistributorFreight(ProgramID,Distributor_ID)>
<cfset qProgramInfo = objProgram.getProgramInfo(programId = ProgramID) />
<cfset qryFixedComp = objFixedComp.getFixedPriceDetails(ProgramID,objFreight.bFREIGHT_VERSION_ITEM,Distributor_ID)>

<table border="0">
	<cfoutput>
	<tr>
		<td><b>Program ##:</b>&nbsp;#qProgramInfo.Contract_Number#</td>
	</tr>
	<tr>
		<td><b>Title:</b>&nbsp;#qProgramInfo.Contract_Title#</td>
	</tr>
	<tr>
		<td><b>Span:</b>&nbsp;#DateFormat(qProgramInfo.Contract_Start_Date,"MM/DD/YYYY")# - #DateFormat(qProgramInfo.Contract_End_Date,"MM/DD/YYYY")#</td>
	</tr>
	<tr>
		<td><b>Distributor:</b>&nbsp;#qryProgramDistributorFreight.Name#&nbsp;(#qryProgramDistributorFreight.Shr_Ship_to#)</td>
	</tr>
	<tr><!--- if freight is at item level hide this data --->
		<cfif NOT objFreight.bFREIGHT_VERSION_ITEM >
		<td><b>Warehouse:</b>&nbsp;#qryProgramDistributorFreight.Warehouse_Name#&nbsp;(#qryProgramDistributorFreight.Warehouse_Code#)
		&nbsp;&nbsp;
		</cfif>
		<b>Bracket:</b>&nbsp;#qryProgramDistributorFreight.Freight_Bracket_Label#
		</td>
	</tr>
	<tr><!--- if freight is at item level hide this data --->
		<cfif NOT objFreight.bFREIGHT_VERSION_ITEM >
		<td><b>IBF:</b>&nbsp;#qryProgramDistributorFreight.IBF_Rate#&nbsp;&nbsp;<b>OBF:</b>&nbsp;#qryProgramDistributorFreight.OBF_Rate#
		&nbsp;&nbsp;<b>PUA:</b>&nbsp;#qryProgramDistributorFreight.Pickup_Allowance#
		</cfif>
		</td>
	</tr>
	</cfoutput>
</table>

<p>
<p>
<p>
<p>

<script language="javascript">
	function changeUOM()
	{
		frmFixedFreight.submit();
	}
</script>

<form name="frmFixedFreight" action="contract_fixed_freight_details.cfm" method="post">

<div align="right">
	<B>CS</B> <input type="radio" name="UOM_Type" value="1" OnClick="changeUOM(1)" <cfif UOM_Type eq 1>checked</cfif>>
	<B>LB</B> <input type="radio" name="UOM_Type" value="2" OnClick="changeUOM(2)" <cfif UOM_Type eq 2>checked</cfif>>
</div>

<cfset Fixed_Component_Type = valueList(qryFixedComp.Fixed_Component_Type)>
<div id="table_container" onscroll="keepHeaderFixed(this.scrollTop-1,scrollLeft);">
<table border="0" cellspacing="0" width="100%" class="MainTable">
	<tr BGCOLOR="#FFCE84">
		<td ID="header" style="border-bottom:0px;border-top:0px;" width="20%" class="locked_top"><b>ITEM</b></td>
		<td ID="header" style="border-bottom:0px;border-top:0px;" width="32%" class="locked_top"><b>DESCRIPTION</b></td>
		<td ID="header" style="border-bottom:0px;border-top:0px;" width="7%" class="locked_top"><b><cfif objFreight.bFREIGHT_VERSION_ITEM >CONTRACT<cfelse>FOB</cfif></b></td>
		<!--- if freight is at item level hide these columns --->
		<cfif NOT objFreight.bFREIGHT_VERSION_ITEM >
			<td ID="header" style="border-bottom:0px;border-top:0px;" width="7%" class="locked_top"><b>IBF</b></td>
			<td ID="header" style="border-bottom:0px;border-top:0px;" width="7%" class="locked_top"><b>FOB FDC</b></td>
		</cfif>
		<!--- When delivered component exists --->
	<cfif ListFind(Fixed_Component_Type,1) NEQ 0>
		<td ID="header" style="border-bottom:0px;border-top:0px;" width="7%" class="locked_top"><b><cfif objFreight.bFREIGHT_VERSION_ITEM >FREIGHT<cfelse>OBF</cfif></b></td>
		<td ID="header" style="border-bottom:0px;border-top:0px;" width="9%" class="locked_top"><b>DELIVERED</b></td>
		<!--- if freight is at item level hide these columns --->
		<cfif NOT objFreight.bFREIGHT_VERSION_ITEM >
			<td ID="header" style="border-bottom:0px;border-top:0px;" width="4%" class="locked_top"><b>PUA</b></td>
		</cfif>
	<cfelse>
		<td ID="header" style="border-bottom:0px;border-top:0px;" width="7%" class="locked_top">&nbsp;</td>
		<td ID="header" style="border-bottom:0px;border-top:0px;" width="9%" class="locked_top">&nbsp;</td>
		<td ID="header" style="border-bottom:0px;border-top:0px;" width="4%" class="locked_top">&nbsp;</td>
	</cfif>	
	</tr>

	<cfset Program_Fixed_Component_Name_ID_List = "">
	
	<cfif UOM_Type eq 1>
		<cfset iDecimalLen = 2>
	<cfelse>
		<cfset iDecimalLen = 4>
	</cfif>
	<cfoutput query="qryFixedComp">

<!--- D33882:Distributor links on PRG-1052788 give event error START --->
<cfif len(qryProgramDistributorFreight.IBF_Rate) EQ 0>
	<cfset qryIBF_Rate = 0>
<cfelse>
	<cfset qryIBF_Rate = qryProgramDistributorFreight.IBF_Rate>
</cfif>
<cfif len(qryProgramDistributorFreight.OBF_Rate) EQ 0>
	<cfset qryOBF_Rate = 0>
<cfelse>
	<cfset qryOBF_Rate = qryProgramDistributorFreight.OBF_Rate>
</cfif>
<cfif len(qryProgramDistributorFreight.Pickup_Allowance) EQ 0>
	<cfset qryPickup_Allowance = 0>
<cfelse>
	<cfset qryPickup_Allowance = qryProgramDistributorFreight.Pickup_Allowance>
</cfif>
		<cfif UOM_Type eq 1>
			 <cfset IBF_Rate = request.app_general_functions.NumericRoundDecimal(iValue=(qryIBF_Rate/100) * val(gross_weight), iDecimalLen=iDecimalLen)>
			 <cfset OBF_Rate = request.app_general_functions.NumericRoundDecimal(iValue=(qryOBF_Rate/100) * val(gross_weight), iDecimalLen=iDecimalLen)>
			 <cfset Pickup_Allowance = request.app_general_functions.NumericRoundDecimal(iValue=(qryPickup_Allowance/100) * val(gross_weight), iDecimalLen=iDecimalLen)>
		
			 <cfif Unit_Of_Measure_ID eq 2>
					<cfset FOB =  request.app_general_functions.NumericRoundDecimal(iValue=val(Fixed_Price_Value) * val(net_weight), iDecimalLen=iDecimalLen)>
			 <cfelse>
					<cfset FOB =  val(Fixed_Price_Value)>
			 </cfif>
		<cfelse>
			<cfset IBF_Rate = request.app_general_functions.NumericRoundDecimal(iValue=((qryIBF_Rate/100)* val(gross_weight)) / val(net_weight), iDecimalLen=iDecimalLen)>
			<cfset OBF_Rate = request.app_general_functions.NumericRoundDecimal(iValue=((qryOBF_Rate/100)* val(gross_weight)) / val(net_weight), iDecimalLen=iDecimalLen)>
			<cfset Pickup_Allowance = request.app_general_functions.NumericRoundDecimal(iValue=((qryPickup_Allowance/100) * val(gross_weight)) / val(net_weight), iDecimalLen=iDecimalLen) >
		
			 <cfif Unit_Of_Measure_ID eq 1>
					<cfset FOB =  request.app_general_functions.NumericRoundDecimal(iValue=val(Fixed_Price_Value)  / val(net_weight), iDecimalLen=iDecimalLen)>
			 <cfelse>
					<cfset FOB =  val(Fixed_Price_Value)>
			 </cfif>
		</cfif>
		
		<cfif objFreight.bFREIGHT_VERSION_ITEM >
			<cfif UOM_Type eq 1>
				<!---<cfset OBF_Rate = qryFixedComp.OBF_Rate_DB />--->
				<cfset OBF_Rate = request.app_general_functions.NumericRoundDecimal(iValue=(qryOBF_Rate/100) * val(gross_weight), iDecimalLen=iDecimalLen)>
			<cfelse>
				<cfset OBF_Rate = request.app_general_functions.NumericRoundDecimal(iValue=((qryOBF_Rate/100)* val(gross_weight)) / val(net_weight), iDecimalLen=iDecimalLen)>
			</cfif>
		</cfif>
<!--- D33882:Distributor links on PRG-1052788 give event error  END --->		
		<cfif Fixed_Component_Type eq 1>
			<cfset Delivered_Price = request.app_general_functions.NumericRoundDecimal(iValue=val(FOB) + val(IBF_Rate) + val(OBF_Rate), iDecimalLen=iDecimalLen)>
			<cfset FOBDC_Price = request.app_general_functions.NumericRoundDecimal(iValue=val(Delivered_Price) - val(Pickup_Allowance), iDecimalLen=iDecimalLen)>
		<cfelse>
			<cfset FOBDC_Price = request.app_general_functions.NumericRoundDecimal(iValue=val(FOB) + val(IBF_Rate), iDecimalLen=iDecimalLen)>
		</cfif>
		
		
		<!--- When UOM is CS --->
		<cfif UOM_Type eq 1>
			 <cfset IBF_Rate = DollarFormat(IBF_Rate)>
			 <cfset OBF_Rate = DollarFormat(OBF_Rate)>
			 <cfset Pickup_Allowance = DollarFormat(Pickup_Allowance)>
			 <cfset FOB = DollarFormat(FOB)>
			 <cfset FOBDC_Price = DollarFormat(FOBDC_Price)>
			<cfif Fixed_Component_Type eq 1>
			 <cfset Delivered_Price = DollarFormat(Delivered_Price)>
			</cfif>
		<cfelse>
			 <cfset IBF_Rate = '$' & NumberFormat(IBF_Rate,',.9999')>
			 <cfset OBF_Rate = '$' & NumberFormat(OBF_Rate,',.9999')>
			 <cfset Pickup_Allowance = '$' & NumberFormat(Pickup_Allowance,',.9999')>
			 <cfset FOB = '$' & NumberFormat(FOB,',.9999')>
			 <cfset FOBDC_Price = '$' & NumberFormat(FOBDC_Price,',.9999')>
			<cfif Fixed_Component_Type eq 1>
			 <cfset Delivered_Price = '$' & NumberFormat(Delivered_Price,',.9999')>
			</cfif>
		</cfif>
	
		<cfif ListFindNoCase(Program_Fixed_Component_Name_ID_List,Program_Fixed_Component_Name_Id) eq 0>
		<cfif ListLen(Program_Fixed_Component_Name_ID_List) GT 1>
		<tr>
			<td style="border-bottom:0px;border-top:0px;">&nbsp;</td>
		</tr>
		</cfif>
		<tr>
			<td ID="header" style="border-bottom:0px;border-top:0px;"><u><b>#Program_Fixed_Component_Name#</b></u></td>
		</tr>
		<tr>
			<td style="border-bottom:0px;border-top:0px;">&nbsp;</td>
		</tr>
		</cfif>
		<tr>
			<td width="20%">#Item#</td>
			<td width="32%">#Description#</td>
			<td width="7%">&nbsp;#FOB#</td>
			<!--- if freight is at item level hide these columns --->
			<cfif NOT objFreight.bFREIGHT_VERSION_ITEM >
				<td width="7%">&nbsp;#IBF_Rate#</td>
				<td width="7%">&nbsp;#FOBDC_Price#</td>
			</cfif>
		<!--- When delivered component exists --->
		<cfif Fixed_Component_Type eq 1>
			<td width="7%">&nbsp;#OBF_Rate#</td>
			<td width="7%">&nbsp;#Delivered_Price#</td>
			<!--- if freight is at item level hide these columns --->
			<cfif NOT objFreight.bFREIGHT_VERSION_ITEM >
				<td width="4%" >&nbsp;&nbsp;#Pickup_Allowance#</td>
			</cfif>
		<cfelse>
			<td width="7%">&nbsp;</td>
			<td width="7%">&nbsp;</td>
			<td width="4%" >&nbsp;&nbsp;</td>
		</cfif>
		</tr>
			
		<cfset Program_Fixed_Component_Name_ID_List = ListAppend(Program_Fixed_Component_Name_ID_List,Program_Fixed_Component_Name_Id)>
	</cfoutput>
</table>
</div>
<cfoutput>
<input type="hidden" name="ProgramID" value="#ProgramID#">
<input type="hidden" name="Distributor_ID" value="#Distributor_ID#">
</cfoutput>
</form>

<p>

<div align="center">
			<CF_smallLink 
			title = "close window" 
			url = "##"
			parameters = "onClick=""javascript: window.close();return false;"""
		>
</div>