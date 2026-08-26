<!------ pricing_create_edit.cfm ----->
<cfoutput>
<cfparam name="fromFPEmailFaxPage" 	default="0">
<cfif bForm>
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/string_validations.js"></SCRIPT>
	<script src="pricing_create_edit.js">
	</script>
	<form action="#thisPageUrl#" method="post" name="#formName#" style="display:inline;">	
</cfif>
<CFSCRIPT>
	Border="Yes";
	BorderSize=1;  
	BorderColor="";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Navy"; 
	TitleFont="Arial";
	TitleSize=10;
	IsClosed="#bForm EQ 1#";  
	WIDTH="97%";
</CFSCRIPT>
<cfset ADDSCRIPT = "Yes">
<cfif fromFPEmailFaxPage>
	<cfset ADDSCRIPT = "No">
</cfif>
	<!------ form code here ----->
	<!------ <cfloop query="qGetProducts"> ----->
	<!------ Loop thru products ----->
	<cfset deliveryTypeManager = CreateObject("component","components.products.DeliveryTypeManager").init() />
	
	<cfset requestProductArray = requestObj.getRequestProduct()>
	<cfset productCount = ArrayLen(requestProductArray)>
	<cfloop index="prodIndex" from="1" to="#productCount#">
		<cfset requestProduct = requestProductArray[prodIndex]>
		
		<cfset currentProductId = requestProduct.getRequestProdId()>
		<cfset productVolume = requestProduct.getLbVolume()>
		
		<cfsavecontent variable="priceCalc">		
		<tr>
			<td colspan="100%">
			<cfset totalPrice = 0>
			<cfset totalAmount = 0>
			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="cost details"  
				TitleClosed="cost details"  
				TitleTooltip="Click here to toggle the view"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#"
				ADDSCRIPT="#ADDSCRIPT#">
			<table border="0" width="100%" cellpadding="2" cellspacing="0">
			<colgroup>
				<col span="2" align="left"></col>
				<col span="100%" align="right"></col>
			</colgroup>
			<thead>
				<tr bgcolor="##FFCE84" valign="top">
					<td id="header">&nbsp;</td>
					<td id="header"><B>Raw Material</B></td>
					<td id="header"><B>Blend</B></td>
					<td id="header"><B>Volume<br>(100% yield)</B></td>
					<td id="header"><B>Yield Loss</B></td>
					<td id="header"><B>Volume<br>w / yield loss</B></td>
					<td id="header">&nbsp;</td>
					<td id="header"><B>Rate</B></td>
					<td id="header">&nbsp;</td>
					<td id="header"><B>Amount</B></td>
					<td id="header"><B>&##931; Amount</B></td>					
				</tr>
			</thead>
			<cfset requestRawMaterialsArray = requestProduct.getRequestRawMaterial()>
			<cfset requestRawMaterialsCount = ArrayLen(requestRawMaterialsArray)>
			<!------ Loop thru raw materials ----->				
			<cfloop index="rawMatIndex" from="1" to="#requestRawMaterialsCount#">
				<cfset requestRawMaterial = requestRawMaterialsArray[rawMatIndex]>
				<cfset rawMaterial = requestRawMaterial.getRawMaterial()>
				
				<cfset Quote = requestRawMaterial.getQuote()>
				<cfset rawVolumeCentYield = (requestProduct.getLbVolume() * requestRawMaterial.getBlend()) / 100 />
				<cfset rawVolume = requestRawMaterial.getEffectiveVolume() />
				<cfset rawAmount = Quote * rawVolume>
				<cfset totalAmount = totalAmount + rawAmount>
				<tr>
					<td id="header">&nbsp;</td>
					<td>#rawMaterial.getNumber()# #rawMaterial.getDesc()#</td>
					<td>#requestRawMaterial.getBlend()# %</td>
					<td>#NumberFormat(rawVolumeCentYield, "___,___.___")#</td>
					<td>#requestRawMaterial.getYieldLoss()# %</td>
					<td>#NumberFormat(rawVolume, "___,___.___")#</td>
					<td align="center">*</td>
					<td>#NumberFormat(Quote, "___,___.___")#</td>
					<td align="center">=</td>
					<td>#NumberFormat(rawAmount, "___,___.___")#</td>
					<td>#NumberFormat(totalAmount, "___,___.___")#</td>					
				</tr>				
			</cfloop>
			<tr>
			<td colspan="100%" align="right">
				<cfset totalPrice = totalAmount/productVolume />
				<cfset totalPrice = request.app_general_functions.roundDecimalPlaces(totalPrice, 3) />
				<B>Cost = (#totalAmount#/#productVolume#) =  #totalPrice#</B>
			</td>
			</tr>
			</table>
			</CF_openLayer>
			</td>			
		</tr>
		</cfsavecontent>
		
		<table cellpadding="2" cellspacing="0" width="100%" border="0">
		<tr>
		<td colspan="100%" bgcolor="##E8FCFD" STYLE="border-bottom:1px solid Navy;border-top:1px solid Navy">
			<cfset uomDesc = request.app_general_functions.getUOMDesc(requestProduct.getUom(), 0)>
			<table cellpadding="0" cellspacing="0" width="100%">
			<tr>
				<td colspan="100%"><B>#requestProduct.getDesc()#</B></td>
			</tr>
			<tr>
				<td>
				<B>Volume</B> = #requestProduct.getVolume()# #uomDesc#
				<cfif requestProduct.getUom() EQ 1> 
					(#requestProduct.getlbVolume()# Lbs)			
				</cfif>
				</td>
				<td>
				<font color="red"><B>Cost</B> = #totalPrice# / Lbs
				<cfif requestProduct.getUom() EQ 1>
				<cfset casePrice = totalPrice * requestProduct.getNetWeight() />
				 (#casePrice# / #uomDesc#)
				</cfif>
				</font>			
				</td>
			</tr>
			</table>
		</td>
		#priceCalc#
		<tr>
			<cfset compoundedIndependent = "1,2">
			<cfloop list="#compoundedIndependent#" delimiters="," index="thisCompIndep">
				<cfset fieldNameSuffix = "#currentProductId#_#thisCompIndep#_0">
				<td width="50%" valign="top"<cfif thisCompIndep EQ 2> align="right"</cfif>>
				<input size="4" type="hidden" name="effectiveOverhead_#fieldNameSuffix#" value="#totalPrice#">
				<cf_pricing_overhead_display
					valueQueryName="qGetPricingOverheads"
					uomQueryName="qGetPricingOverheadUOM"
					currentProductId="#currentProductId#"
					compondedIndependent="#thisCompIndep#"
					startValue="#totalPrice#"
					bForm="#bForm#"
					>
				</td>
			</cfloop>
		</tr>
		<tr>
			<td align="right" colspan="100%" style="border-top:1px solid black;">
			<B>Price = </B>
			
			<cfif bForm>
				<input readonly style="text-align:right;border:none;background-color:yellow;" size="5" type="text" name="finalPrice_#currentProductId#" value="" totalPrice="#totalPrice#" iComp="#compIndep_1#" iIndep="#compIndep_2#">
				<script language="JavaScript">
					document.all.finalPrice_#currentProductId#.setExpression("value", "getFinalPrice(document.all.finalPrice_#currentProductId#)");
				</script>
			<cfelse>
				<div style="padding:1px;width:50px;background-color:yellow;display:inline;">#Evaluate(totalPrice + compIndep_1 + compIndep_2)#</div>
			</cfif>
			/ Lb - #deliveryTypeManager.getDeliveryTypeDesc(requestProduct.getDeliveryTypeId())#
			</td>
		</tr>
		</table>			
	</cfloop>
<cfif bForm>
	<input type="hidden" name="state" value="1">
	<INPUT NAME="forward" TYPE="Hidden" VALUE="0" />
	<INPUT NAME="command" TYPE="Hidden" VALUE="#form.command#" />
	<br><br>
	<cf_kickbackLink
		id = "#requestObj.getId()#"
		statusId = "#requestObj.getStatusId()#">
	<cf_smallLink
			title="save only"
			url="##"
			parameters=" onClick=""JavaScript: return submitForm('#formName#','sPricing');"""
			>
	<cf_smallLink
			title="save & forward"
			url="##"
			parameters=" onClick=""JavaScript: return submitForm('#formName#','sPricingForward');"""
			>
</form>
<cf_MessageWindow />
</cfif>
</cfoutput>