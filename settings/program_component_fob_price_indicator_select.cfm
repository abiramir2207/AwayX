<!---
	Created by: Deepa Kunnath
	Created on: 5/24/2010
	Label for creation: D23415 Payment Against Excluded Invoice Events
	Lowest build available: 6.1
	Parameters: payeeTypeId, discountTypeId
	 
	This functionality allows users to select the list of FOB price indicators per payee type to be used in auto pay.
	This seting will replace the hard coded values for X, K and C inside auto pay.
		
 --->


<!--- Code plan
1) Initialize all CFC
2) Get the FOB Price indicators
3) List out FOB Price indicators along with checkboxes
 --->

<!--- application.oFOBPriceIndicatorManager already initiated before --->
<cfset qGetProgramComponentFOBPriceIndicators = application.oFOBPriceIndicatorManager.getProgramComponentFOBPriceIndicators(
		payeeTypeId = payeeTypeId,
		discountTypeId = discountTypeId,
		componentNameId = componentNameId) />
		
<script language="JavaScript">
	function selectAllFOB(payeeType, bCheck)
	{
		event.returnValue = false;
		var oCheck = eval("document.all.FOB_PayeeType" + payeeType + "_DiscountType");
		var i, iChkLen;
		if(oCheck)
		{
			iChkLen = oCheck.length;
			if(iChkLen)
			{
				for(i=0;i<iChkLen;i++)
				{
					oCheck[i].checked = bCheck;					
				}
			}
			else
			{
				oCheck.checked = bCheck;
			}
		}
	}
	
	function anyFOBSelected(payeeType)
	{
		var iSelectedCount = 0;
		var oCheck = eval("document.all.FOB_PayeeType" + payeeType + "_DiscountType");
		var i, iChkLen;
		if(oCheck)
		{
			iChkLen = oCheck.length;
			if(iChkLen)
			{
				for(i=0;i<iChkLen;i++)
				{
					if(oCheck[i].checked) iSelectedCount++;
										
				}
			}
			else
			{
				if(oCheck.checked) iSelectedCount++;
			}
		}
		return iSelectedCount;
	}
</script>
<table cellpadding="2" cellspacing="0" width="100%" border="0" align="center">
	<!--- header --->
	<tr bgcolor="FFCE8" style="height:20px">
	<td width="100%" style="border-bottom:1px solid ##93BEE2;">&nbsp;&nbsp;<strong>
	<cfoutput>
	Payee: 
		<cfif payeeTypeId eq 1>#application.returned_customer_setting.distributor_label_singular#
		<cfelseif payeeTypeId eq 2>#application.returned_customer_setting.operator_label_singular#
		<cfelseif payeeTypeId eq 3>#application.returned_customer_setting.broker_label_singular#
		</cfif>
	</cfoutput>
	</strong>
	<span id="Err_Component">&nbsp;</span>			
	</td>
	<td nowrap style="border-bottom:1px solid ##93BEE2;">
	<CF_smallLink 
		title = "select all" 
		url = "##"
		parameters = "onClick=""javascript: selectAllFOB('#payeeTypeId#', true);return false;"""
	>
	<CF_smallLink 
		title = "deselect all" 
		url = "##"
		parameters = "onClick=""javascript: selectAllFOB('#payeeTypeId#', false);return false;"""
	>	
	</td>
	</tr>
	
	<!--- detail --->
	<tr>
	<td colspan="100%" style="border-left:1px solid ##93BEE2;border-right:1px solid ##93BEE2;border-bottom:1px solid ##93BEE2;">
		<table cellpadding="1" cellspacing="0" width="100%" border="0">	
		<tr>
		<cfparam name="colsCount" default = 0>
		<cfoutput query="qGetProgramComponentFOBPriceIndicators">
		<td width="#tdWidth#%"><input type="checkbox" name="FOB_PayeeType#payeeTypeId#_DiscountType" value="#Fob_Price_Indicator#" <cfif Component_Selected EQ 1>checked</cfif>>#Fob_Price_Indicator# = #Fob_Price_Indicator_Desc#</td>
		<cfset colsCount = colsCount + 1 />
		<cfif colsCount GTE maxCols>
			</tr><tr>
			<cfset colsCount = 0 />
		</cfif>
		</cfoutput>
		<cfloop from="#colsCount#" to="#maxCols#" index="i" >
			<td width="#tdWidth#%"></td>
		</cfloop>
		</tr>
		</table>
	</td>
	</tr>	
</table>


