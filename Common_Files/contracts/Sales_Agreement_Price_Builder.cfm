<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>Sales Agreement</title>
<style type="text/css">	
	.TableHeaders 
	{
		font-family:Arial;
		font-size:11px;
		font-weight:bold;
	}
	.ProductTableHeader
	{
		font-family:Arial;
		font-size:10px;
		font-weight:bold;
		border-bottom:solid #93BEE2 1px;
	}
	</style>
</head>

<cfset Agreement_Details = CreateObject("component","components.Export.Sales_Agreement_AJAX") />
<cfset Agreement_Manager = CreateObject("component","components.Export.Sales_Agreement") />
<cfset qry_Export_Costs = Agreement_Details.getStandardCost('#Export_Sales_Agreement_ID#')>
<cfset qry_Export_Misc_Costs = Agreement_Manager.getMiscCosts('#Export_Sales_Agreement_ID#')>

<CFQUERY NAME="getProductDetails" datasource="#application.datasource#">
	SELECT distinct ep.BSA_Foodservice_Items_Master_ID,bfim.Item,bfim.Description,ep.Export_Target_Net_Sales_Price,ep.Export_Sale_Unit_Price
	,ep.Export_Sticker,ep.Export_Sticker_Rate,ep.Export_Accrual,ep.Export_Charge,ep.Export_Estimated_Net_Sales_Price
	,ep.Export_End_User,ep.Export_Required_Volume,ep.Export_Volume_Limit,ep.Export_Origin_Relocation_Cost,bfim.height
	,bfim.length,bfim.width,bfim.cases_Layer,bfim.gross_weight,bfim.net_weight,ep.Export_Net_Loadability
	,esa.*,elsc.Export_Stickering_Cost_Desc
	FROM	Export_Products ep INNER JOIN BSA_Foodservice_Items_Master bfim
	ON ep.BSA_Foodservice_Items_Master_ID = bfim.BSA_Foodservice_Items_Master_ID
	INNER JOIN Export_Sales_Agreement esa
	ON ep.Export_Sales_Agreement_ID = esa.Export_Sales_Agreement_ID
	LEFT JOIN Export_Lookup_Stickering_Cost elsc
	ON esa.Export_Stickering_Cost_ID = elsc.Export_Stickering_Cost_ID
	WHERE ep.Export_Sales_Agreement_ID = '#Export_Sales_Agreement_ID#'
	AND ep.BSA_Foodservice_Items_Master_ID = '#Item_ID#'
	AND ep.Deleted = 0
</CFQUERY>

<cfset SubTotal = 0>
<cfset Charge_SubTotal = 0>

<body>
<cfoutput query="getProductDetails">
<!--- Conditional Logic for CSS style --->
<cfif qry_Export_Costs.recordcount GT 0 AND qry_Export_Misc_Costs.recordcount EQ 0>
	<cfset MiscCost_StyleCode = "">
	<cfset StandardCost_StyleCode = "">
	<cfset Cost_StyleCode = "border-bottom:solid ##000000 1px;">
<cfelseif qry_Export_Misc_Costs.recordcount GT 0>
	<cfset MiscCost_StyleCode = "border-bottom:solid ##000000 1px;">
	<cfset StandardCost_StyleCode = "">
	<cfset Cost_StyleCode = "">
<cfelse>
	<cfset MiscCost_StyleCode = "">
	<cfset StandardCost_StyleCode = "border-bottom:solid ##000000 1px;">
	<cfset Cost_StyleCode = "">
</cfif>
	
<!--- To calculate the sub total, first add the Freight Cost and Inland Fuel Surcharge and Ocean Fuel Surcharge --->
<cfset SubTotal = SubTotal + Export_Freight_Cost + Export_Inland_Fuel_Surcharge + Export_Ocean_Fuel_Surcharge>

<!--- To calculate the Charge sub total, first add the Additional Freight Cost and Additional Inland Fuel Surcharge and Additional Ocean Fuel Surcharge --->
<cfset Charge_SubTotal = Charge_SubTotal + Export_Additional_Freight_Cost + Export_Additional_Inland_Fuel_Surcharge + Export_Additional_Ocean_Fuel_Surcharge>

<table align="center" border="0" cellpadding="3" cellspacing="0">
	<tr>
		<td colspan="100%" class="TableHeaders" align="center">#Description# (#Item#)</td>
	</tr>
	<tr>
		<td colspan="100%" class="TableHeaders">Loadability - #Export_Net_Loadability#</td>
	</tr>
	<tr>
		<td colspan="100%" class="TableHeaders">NSP Calculation</td>
	</tr>
	<tr>
		<td></td>
		<td class="TableHeaders" align="right">True Cost</td>
		<td class="TableHeaders" align="right">Cost/lb</td>
		<td class="TableHeaders" align="right">Charge</td>
		<td class="TableHeaders" align="right">Charge/lb</td>
	</tr>
	<tr>
		<td class="TableHeaders">Sales Unit Price</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<!--- Calculate the Sale Unit Price for the loadability figure --->
		<td align="right"><cfset Sales_Charge = Evaluate(Export_Net_Loadability * Export_Sale_Unit_Price)><b>#Sales_Charge#<b></td>
		<td align="right"><b>#Export_Sale_Unit_Price#</b></td>
	</tr>
	<tr>
		<td colspan="100%">&nbsp;</td>
	</tr>
	<tr>
		<td class="TableHeaders">Total Freight Costs</td>
		<td align="right">#Export_Freight_Cost#</td>
		<td>&nbsp;</td>
		<td align="right">#Export_Additional_Freight_Cost#</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td class="TableHeaders">Inland Fuel Surcharge</td>
		<td align="right">#Export_Inland_Fuel_Surcharge#</td>
		<td>&nbsp;</td>
		<td align="right">#Export_Additional_Inland_Fuel_Surcharge#</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td class="TableHeaders" style="#StandardCost_StyleCode#">Ocean Fuel Surcharge</td>
		<td style="#StandardCost_StyleCode#" align="right">#Export_Ocean_Fuel_Surcharge#</td>
		<td style="#StandardCost_StyleCode#">&nbsp;</td>
		<td style="#StandardCost_StyleCode#" align="right">#Export_Additional_Ocean_Fuel_Surcharge#</td>
		<td style="#StandardCost_StyleCode#">&nbsp;</td>
	</tr>

	<cfloop query="qry_Export_Costs">
	<cfset Separator = 0>
	<cfif qry_Export_Costs.currentrow eq qry_Export_Costs.recordcount>
		<cfset Separator = 1>
	</cfif>
	<!--- Add the standard export costs to the sub total --->
	<cfset SubTotal = SubTotal + Export_Cost>

	<!--- Add the additional export costs (Invoice Charges) to the charge sub total --->
	<cfset Charge_SubTotal = Charge_SubTotal + Export_Additional_Cost>
	<tr>
		<td class="TableHeaders" <cfif Separator eq 1>style="#Cost_StyleCode#"</cfif>>#Export_Lookup_Cost_Desc#</td>
		<td <cfif Separator eq 1>style="#Cost_StyleCode#"</cfif> align="right">#Export_Cost#</td>
		<td <cfif Separator eq 1>style="#Cost_StyleCode#"</cfif>>&nbsp;</td>
		<td <cfif Separator eq 1>style="#Cost_StyleCode#"</cfif> align="right">#Export_Additional_Cost#</td>
		<td <cfif Separator eq 1>style="#Cost_StyleCode#"</cfif>>&nbsp;</td>
	</tr>
	</cfloop>

	<cfloop query="qry_Export_Misc_Costs">
		<cfset Separator = 0>
	<cfif qry_Export_Misc_Costs.currentrow eq qry_Export_Misc_Costs.recordcount>
		<cfset Separator = 1>
	</cfif>

	<!--- Add the misc cost to the charge sub total --->
	<cfset Charge_SubTotal = Charge_SubTotal + Export_Misc_Cost>
	<tr>
		<td class="TableHeaders" <cfif Separator eq 1>style="#MiscCost_StyleCode#"</cfif>>#Export_Misc_Cost_Desc#</td>
		<td <cfif Separator eq 1>style="#MiscCost_StyleCode#"</cfif>>&nbsp;</td>
		<td <cfif Separator eq 1>style="#MiscCost_StyleCode#"</cfif>>&nbsp;</td>
		<td <cfif Separator eq 1>style="#MiscCost_StyleCode#"</cfif> align="right">#Export_Misc_Cost#</td>
		<td <cfif Separator eq 1>style="#MiscCost_StyleCode#"</cfif>>&nbsp;</td>
	</tr>
	</cfloop>

	<!--- Instead of writing lots of 9's in the Numberformat function, I used a shortcut Notation - (',.9999') --->
		<td class="TableHeaders">SUBTOTAL</td>
		<td align="right">#SubTotal#</td>
		<td align="right"><cfif Export_Net_Loadability GT 0>#NumberFormat(Evaluate(SubTotal/Export_Net_Loadability),',.9999')#<cfelse><b>0.0000</b></cfif></td>
		<td align="right"><b>#Charge_SubTotal#</b></td>
		<td align="right"><cfif Export_Net_Loadability GT 0><b>#NumberFormat(Evaluate(Charge_SubTotal/Export_Net_Loadability),',.9999')#</b><cfelse><b>0.0000</b></cfif></td>
	</tr>
	<tr>
		<td class="TableHeaders">Net Cost/Charge</td>
		<td align="right"><b>#Evaluate(SubTotal - Charge_SubTotal)#</b></td>
		<td align="right"><cfif Export_Net_Loadability GT 0><cfset Net_Cost_Charge = Evaluate((SubTotal - Charge_SubTotal) /Export_Net_Loadability)><cfelse><cfset Net_Cost_Charge = 0></cfif><b>#NumberFormat(Net_Cost_Charge,',.9999')#</b></td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td colspan="100%">&nbsp;</td>
	</tr>
	<tr>
		<td class="TableHeaders">Accrual</td>
		<!--- Calculate the accrual amount for the loadability figure --->
		<td align="right"><cfset Total_Accrual = Evaluate(Export_Net_Loadability * Export_Accrual)>#NumberFormat(Total_Accrual,',.99')#</td>
		<td align="right">#Export_Accrual#</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td class="TableHeaders">Relocation</td>
		<!--- Calculate the relocation cost for the loadability figure --->
		<td align="right"><cfset Total_Relocation = Evaluate(Export_Net_Loadability * Export_Origin_Relocation_Cost)>#NumberFormat(Total_Relocation,',.99')#</td>
		<td align="right">#Export_Origin_Relocation_Cost#</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td class="TableHeaders" style="border-bottom:solid ##000000 1px;">&nbsp;#Export_Stickering_Cost_Desc#</td>
		<!--- Calculate the stickering cost for the loadability figure --->
		<td style="border-bottom:solid ##000000 1px;" align="right"><cfset Total_Stickering = Evaluate(Export_Net_Loadability * Export_Sticker_Rate)>#NumberFormat(Total_Stickering,',.99')#</td>
		<td style="border-bottom:solid ##000000 1px;" align="right">#Export_Sticker_Rate#</td>
		<td style="border-bottom:solid ##000000 1px;">&nbsp;</td>
		<td style="border-bottom:solid ##000000 1px;">&nbsp;</td>
	</tr>
	<tr>
		<td class="TableHeaders">Total</td>
		<td align="right"><cfset Total_Cost = SubTotal + Total_Accrual + Total_Relocation + Total_Stickering>#NumberFormat(Total_Cost,',.99')#</td>
		<td align="right"><cfif Export_Net_Loadability GT 0>#NumberFormat(Evaluate(Total_Cost/Export_Net_Loadability),',.9999')#<cfelse>0.0000</cfif></td>
		<td align="right"><cfset Total_Charge = Sales_Charge + Charge_SubTotal><b>#NumberFormat(Total_Charge,',.99')#</b></td>
		<td align="right"><cfif Export_Net_Loadability GT 0><b>#NumberFormat(Evaluate(Total_Charge/Export_Net_Loadability),',.9999')#</b><cfelse><b>0.0000</b></cfif></td>
	</tr>
	<tr>
		<td class="TableHeaders">NSP</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td align="right"><cfset Total_NSP = Total_Charge - Total_Cost><b>#Total_NSP#</b></td>
		<td align="right"><cfif Export_Net_Loadability GT 0><cfset NSP = Total_NSP/Export_Net_Loadability><cfelse><cfset NSP = 0></cfif><b>#NumberFormat(NSP,',.9999')#</b></td>
	</tr>
</table>
</cfoutput>

</body>
</html>
<cfsetting showdebugoutput="true">