<!------ price_in_sales_create_edit.cfm ----->
<cfoutput>
<cfif bForm>
	<form action="#thisPageUrl#" method="post" name="#formName#" style="display:inline;">	
</cfif>

<br>
	
	
	<table cellpadding="2" cellspacing="0" width="90%" border="0" class="MainTable">
	<thead>
		<tr bgcolor="##FFCE84" valign="top">
			<td id="header">&nbsp;</td>
			<td id="header"><B>Item/UPC</B></td>
			<td id="header"><B>Desc</B></td>
			<td id="header"><B>Volume</B></td>
			<td id="header"><B>Price</B></td>
		</tr>
		</thead>
	<!------ Loop thru products ----->
	<cfset requestProductArray = requestObj.getRequestProduct()>
	<cfset productCount = ArrayLen(requestProductArray)>
	<cfloop index="prodIndex" from="1" to="#productCount#">
	
		<cfset requestProduct = requestProductArray[prodIndex]>
		<cfset uomDesc = request.app_general_functions.getUOMDesc(requestProduct.getUom(), 0) />
		<tr valign="top">
			<td>&nbsp;</td>
			<td>#requestProduct.getItem()#<br>#requestProduct.getUpc()#</td>
			<td>#requestProduct.getDesc()#</td>
			<td>#requestProduct.getVolume()# #uomDesc#</td>
			<td>#requestProduct.getFinalPrice()# / #uomDesc#</td>
		</tr>			
	</cfloop>
	</table>
	<br>
	<table align="center" cellpadding="10" cellspacing="0" width="50%" border="0" style="border:2px solid navy;">
	<tr>
		<td align="center"><B>Pricing Status</B></td>
		<td align="center">
		<cfset pricingStatusId = requestObj.getPricingStatusId() />
		<cfif bForm>
			<cfset qGetPricingStatus = CreateObject("component", "components.futures_pricing.PricingStatusManager").getAll() />
			<select name="FP_Pricing_Status_ID">
				<cfloop query="qGetPricingStatus">
				<option value="#FP_Pricing_Status_ID#"<cfif pricingStatusId EQ FP_Pricing_Status_ID> SELECTED</cfif>>#FP_Pricing_Status_Desc#</option>
				</cfloop>
			</select>
		<cfelse>
		#requestObj.getPricingStatusDesc()#
		</cfif>
		</td>
	</tr>
	</table>
<cfif bForm>
		<input type="hidden" name="state" value="1">
		<INPUT NAME="command" TYPE="Hidden" VALUE="#form.command#" />
	</form>
	<br>
	<div align="center">
	<cf_kickbackLink
		id = "#requestObj.getId()#"
		statusId = "#requestObj.getStatusId()#">
	<cf_smallLink
			title="save"
			url="##"
			parameters=" onClick=""JavaScript: return submitForm('#formName#','sPriceInSales');"""
			>
	</div>
</cfif>
</cfoutput>