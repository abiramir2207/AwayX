<cfsetting enablecfoutputonly="Yes">
<!------ pricing_overhead_display.cfm ----->
<cfparam name="Attributes.valueQueryName" 	default="">
<cfparam name="Attributes.currentProductId" 	default="0">
<cfparam name="Attributes.compondedIndependent" 	default="">
<cfparam name="Attributes.startValue" 	default="0">
<cfparam name="Attributes.bForm" 	default="">

<cfset bForm = Attributes.bForm>

<cfset qGetPricingOverheads = Evaluate("caller.#Attributes.valueQueryName#")>
<cfset qGetPricingOverheadUOM = Evaluate("caller.#Attributes.uomQueryName#")>

<cfset totalValue = 0>
<!------ <cfif Attributes.compondedIndependent EQ 1><!------ compounded ----->
	<cfset totalValue = Attributes.startValue>
</cfif> ----->

<cfset startValue = Attributes.startValue>

<cfif bForm>
	<cfoutput>
	<cfsavecontent variable="OverheadUOMString">
	<cfloop query="qGetPricingOverheadUOM">
		<option value="#FP_Overhead_UOM_ID#">#UOM_Desc#</option>
	</cfloop>
	</cfsavecontent>
	</cfoutput>
</cfif>		

<cfquery name="qGetProductPricingOverheads" dbtype="query">
	SELECT	*
	FROM	qGetPricingOverheads
	WHERE
			FP_Product_ID = #Attributes.currentProductId#
			AND
			Componded_Independent = #Attributes.compondedIndependent#
</cfquery>
<cfif bForm>
	<cfset QueryAddRow(qGetProductPricingOverheads)>
</cfif>
<cfset compoundedIndependentDisplay = "Compounded Calculations,Independent Calculations">

<cfset prodCompIndCombination = "#Attributes.currentProductId#_#Attributes.compondedIndependent#">
<cfset compondedIndependentCountField = "compondedIndependentCount_#prodCompIndCombination#">
<cfoutput>
<table width="100%" cellpadding="1" cellspacing="0" compIndep="#Attributes.compondedIndependent#" productId="#Attributes.currentProductId#">
<caption align="left" style="background-color:##D0D0D0;font-size:12px;font-weight:bold;">#ListGetAt(compoundedIndependentDisplay, Attributes.compondedIndependent, ",")#
</caption>
<tbody>
<cfsavecontent variable="calcAllString">calcFffectiveOverageExpression(#Attributes.compondedIndependent#);</cfsavecontent>
<cfloop query="qGetProductPricingOverheads">
	<cfset currentValue = "">
	<cfset prevStartValue = startValue>
	<cfif isNumeric(Overhead_Value) AND Overhead_Value NEQ "" AND isNumeric(FP_Overhead_UOM_ID) AND FP_Overhead_UOM_ID NEQ "">
		<cfif FP_Overhead_UOM_ID EQ 2><!------ % ----->
		
			<cfset currentValue = (Overhead_Value * startValue) / 100>
		
		<cfelse>
		
			<cfset currentValue = Overhead_Value>
			
		</cfif>
		
		<cfset totalValue = totalValue + currentValue>
		
		<!------ <cfif Attributes.compondedIndependent EQ 1><!------ compounded ----->
		
			<cfset currentValue = totalValue>
			
		</cfif> ----->
		
		<cfif Attributes.compondedIndependent EQ 1><!------ compounded ----->
		
			<cfset startValue = startValue + currentValue>
		
		</cfif>
	</cfif>
	<cfif bForm>
	<cfset fieldNameSuffix = "#prodCompIndCombination#_#Currentrow#">	
	<tr id="tr_#Currentrow#">
		<td><input size="30" onchange="javaScript: validateThisRowValues(#Attributes.compondedIndependent#);" onkeypress="javaScript: return addRow(this, '#compondedIndependentCountField#', 0);" type="text" name="Overhead_Desc_#fieldNameSuffix#" value="#Overhead_Desc#">
		<span id="Err_Sp_#fieldNameSuffix#">&nbsp;&nbsp;</span>
		</td>
		<td><input size="2" maxlength="5" onchange="javaScript: #calcAllString#" onkeypress="javaScript: return addRow(this, '#compondedIndependentCountField#', 1);" type="text" name="Overhead_Value_#fieldNameSuffix#" value="#Overhead_Value#"></td>
		<td>
		<select name="Overhead_UOM_#fieldNameSuffix#" onchange="javaScript: #calcAllString#">
			#ReReplaceNoCase(OverheadUOMString, "value=""#FP_Overhead_UOM_ID#"">", "value=""#FP_Overhead_UOM_ID#"" selected>")#
		</select>
		</td>
		<td><input type="button" name="b_Add_#fieldNameSuffix#" value="+" onclick="javaScript: addFilterRows(this, '#compondedIndependentCountField#');"></td>
		<td><input type="button" name="b_Sub_#fieldNameSuffix#" value="-" onclick="javaScript: deleteFilterRows(this, '#compondedIndependentCountField#');"></td>
		<td>=</td>
		<td align="right">
		
		<input readonly style="text-align:right;border:none;background-color:yellow;" size="4" type="hidden" name="effectiveOverhead_#fieldNameSuffix#" value="#startValue#">
		<input readonly style="text-align:right;border:none;background-color:yellow;" size="4" type="text" name="displayEffectiveOverhead_#fieldNameSuffix#" value="#currentValue#">
		</td>
	</tr>
	<cfelse>
		<tr id="tr_#Currentrow#">
			<td>#Overhead_Desc#</td>
			<cfif FP_Overhead_UOM_ID EQ 1>
				<td>#UOM_Desc# #Overhead_Value#</td>
			<cfelse>
				<td>#Overhead_Value# #UOM_Desc# of #prevStartValue#</td>
			</cfif>
			<td align="right"><div style="padding:1px;width:50px;background-color:yellow;display:inline;">#currentValue#</div></td>
		</tr>
	</cfif>
</cfloop>
</tbody>
<tfoot>
<tr>
	<td style="border-top:1px solid navy;" colspan="100%" align="right">&##931; overhead = <div style="display:inline;" id="totalOverhead_#prodCompIndCombination#">#totalValue#</div></td>
</tr>
</tfoot>
</table>
<cfif bForm>
	<input type="Hidden" name="#compondedIndependentCountField#" value="#qGetProductPricingOverheads.recordCount#">
</cfif>
<cfset "caller.compIndep_#Attributes.compondedIndependent#" = totalValue>
</cfoutput>


<cfsetting enablecfoutputonly="No">