<!------ procurement_create_edit.cfm ----->
<cfoutput>
<script src="procurement_create_edit.js"></script>
<SCRIPT SRC="/Script/javascript/validateFormUtils.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/date_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>

<form action="#thisPageUrl#" method="post" name="#formName#" style="display:inline;">	

<!---set raw material list--->
<cfset lRawMatId = "" />

<cfloop index="rmIndx" from="1" to="#ArrayLen(requestObj.procurement.rawMaterial)#">

	<!---set the raw material id--->
	<cfset rawMatId = requestObj.procurement.rawMaterial[rmIndx].getId() />
	<!---append id to list--->
	<cfset lRawMatId = ListAppend(lRawMatId, rawMatId) />
	
	<!---set supplier list--->
	<cfset lSuppId = "" />
	
	<cfparam name="recommendSuppId" default=0 />
	
	<!---set the recommended supplier id if it exists--->
	<cfif Len(trim(requestObj.procurement.rawMaterial[rmIndx].getRecommendedSupplierId()))>
		<!---set recommended supplier--->
		<cfset recommendSupp = suppMang.get(requestObj.procurement.rawMaterial[rmIndx].getRecommendedSupplierId()) />
		<cfset recommendSuppId = recommendSupp.getId() />
	</cfif>
	
	<table cellpadding="2" cellspacing="0" width="100%" bgcolor="##E8FCFD">
		<tr>
			<td colspan="4" style="border-bottom:1px solid navy;">
				<B>[#requestObj.procurement.rawMaterial[rmIndx].getNumber()#] #requestObj.procurement.rawMaterial[rmIndx].getDesc()#</B> (#requestObj.procurement.rawMaterial[rmIndx].getVolumeLb()# Lb)&nbsp;&nbsp;&nbsp;
				<input type="hidden" name="totalVolume_#rawMatId#" value="#requestObj.procurement.rawMaterial[rmIndx].getVolumeLb()#" />				
					<CF_smallLink 
						title = "select supplier" 
						url = "##"
						parameters = "onClick=""javascript: return showSupplierSearchWindow('#formName#','lRawMatID_#rawMatId#');"""
					>			
			</td>
		</tr>
	</table>
	<table cellpadding="2" cellspacing="0" width="100%">
		<tr>
			<td>
				<font face="Arial, Helvetica, sans-serif" color="##FF0000">RS</font>
				<font face="Arial, Helvetica, sans-serif">=</font>
				<font face="Arial, Helvetica, sans-serif">Recommended Supplier</font>
				&nbsp;&nbsp;&nbsp;
			</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellpadding="2" cellspacing="0" class="MainTable">
					<tr bgcolor="##FFCE84">
						<td id="header"><span id="AwardErr_Sp_#rawMatId#"></span><b>Awarded</b></td>
						<td id="header"><B>Supplier</B></td>
						<td id="header"><B>Quote</B></td>
						<td id="header"><B>UOM</B></td>
						<td id="header"><span id="TotalVolErr_Sp_#rawMatId#"></span><B>Volume</B></td>
						<td id="header"><B>Quote Date</B></td>
						<td id="header"><B>Quote Good Until</B></td>
					</tr>
					
					<!--- if we have no suppliers then check to see if a recommended supplier was selected and display it--->
					<cfif NOT ArrayLen(requestObj.procurement.rawMaterial[rmIndx].supplierQuotes)>
						<cfif recommendSuppId and not form.state>
							<cfset suppQuote = CreateObject("component", "components.futures_pricing.SupplierQuote") />
							<cfset suppQuote.setSupplierId(recommendSuppId) />							
							<cfset suppQuote.setSupplierName(recommendSupp.getName()) />
							<cfset suppQuote.setIsSelected(0) />
							<cfset requestObj.procurement.rawMaterial[rmIndx].setSupplierQuotes(suppQuote) />
						</cfif>
					</cfif>
					
					<!---now loop over supplier array and display--->
					<cfif ArrayLen(requestObj.procurement.rawMaterial[rmIndx].supplierQuotes)>
					
						<cfloop index="suppIndx" from="1" to="#ArrayLen(requestObj.procurement.rawMaterial[rmIndx].supplierQuotes)#">
							<!---set the supplier id--->
							<cfset suppId = requestObj.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getSupplierId() />
	
							<cfset lSuppId = ListAppend(lSuppId, suppId) />
							
							<tr ID="SCISSOR_ITEM_#rawMatId#_#suppId#">
								<td><input name="selected_#rawMatId#_#suppId#" type="checkbox" value="1" <cfif requestObj.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getIsSelected()>checked</cfif>>
								&nbsp;&nbsp;<img bDelete="true" name="IMG_Delete_Scissor" src="/images/scissor.gif" alt="click here to delete this record" border="0" onclick="deleteThisRecord('#rawMatId#_#suppId#', '#suppId#', document.#formName#.lRawMatID_#rawMatId#)" style="cursor: hand;">
								</td>
								<td>
									#requestObj.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getSupplierName()#
									<!---display legend if recommended supplier--->
									<cfif suppId eq recommendSuppId>&nbsp;&nbsp;<font face="Arial, Helvetica, sans-serif" color="##FF0000">RS</font></cfif>
								</td>
								<td><span id="quote_Err_Sp_#rawMatId#_#suppId#"></span><input name="quote_#rawMatId#_#suppId#" type="text" size="6" value="#requestObj.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getQuote()#" onChange="this.value = formatToDecimalPlaces(this.value, 2);" onKeyUp="clenseText(this, '0123456789.');" /></td>
								<td>
									<select name="uom_#rawMatId#_#suppId#">
										<option value="1" <cfif requestObj.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getQuoteUOM() eq 1>selected</cfif>>LBS</option>
										<option value="2" <cfif requestObj.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getQuoteUOM() eq 2>selected</cfif>>CWT</option>
									</select>
								</td>
								<td><span id="quoteVolume_Err_Sp_#rawMatId#_#suppId#"></span><input name="quoteVolume_#rawMatId#_#suppId#" type="text" value="#NumberFormat(requestObj.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getQuoteVolume(), "_.__")#" onKeyUp="clenseText(this, '0123456789.');" size="10" /></td>
								<td>
									<CF_EASYDATE 
										FORMNAME="#formName#" 
										FIELDNAME="quoteDate_#rawMatId#_#suppId#" 
										FORMAT="mm/dd/yyyy" 
										DEFAULT="#DateFormat(requestObj.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getQuoteDate(), "mm/dd/yyyy")#">
								</td>
								<td>
									<span id="goodUntill_Err_Sp_#rawMatId#_#suppId#"></span>
									<CF_EASYDATE 
										FORMNAME="#formName#" 
										FIELDNAME="goodUntil_#rawMatId#_#suppId#" 
										FORMAT="mm/dd/yyyy" 
										DEFAULT="#DateFormat(requestObj.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getQuoteGoodUntil(), "mm/dd/yyyy")#">
								</td>
							</tr>
						</cfloop>
					
					<cfelse>
					
						<tr><td colspan="100%"><span id="HasSupplierErr_Sp_#rawMatId#"></span>None Selected</td></tr>
						
					</cfif>
				</table>
			</td>
		</tr>
	</table>
	<br><br>
	<input name="lRawMatID_#rawMatId#" type="hidden" value="#lSuppId#" />

</cfloop>

	<br><br>
	<cf_kickbackLink
		id = "#requestObj.getId()#"
		statusId = "#requestObj.getStatusId()#">
	<cf_smallLink
		title="save only"
		url="##"
		parameters=" onClick=""JavaScript: return submitForm('#formName#','sProcurement');"""
	>
	<cf_smallLink
		title="save & forward"
		url="##"
		parameters=" onClick=""JavaScript: return submitForm('#formName#','sProcurementForward');"""
	>
<input name="lRawMatId" type="hidden" value="#lRawMatId#">
<input name="state" type="hidden" value="1">
<INPUT NAME="forward" TYPE="Hidden" VALUE="0" />
<INPUT NAME="command" TYPE="Hidden" VALUE="#form.command#" />
<INPUT NAME="id" TYPE="Hidden" VALUE="#form.id#" />
<INPUT NAME="Today_Date" TYPE="Hidden" VALUE="#DateFormat(Now(), "mm/dd/yyyy")#" />
</form>
<cf_MessageWindow />
</cfoutput>