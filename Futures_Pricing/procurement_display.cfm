<!------ procurement_display.cfm ----->
<cfoutput>	

<cfloop index="rmIndx" from="1" to="#ArrayLen(requestObj.procurement.rawMaterial)#">
	
<!---set the raw material id--->
<cfset rawMatId = requestObj.procurement.rawMaterial[rmIndx].getId() />
<!---set supplier list--->
<cfset lSuppId = "" />

<cfparam name="recommendSuppId" default=0 />
<!---set the recommended supplier id if it exists--->
<cfif Len(trim(requestObj.procurement.rawMaterial[rmIndx].getRecommendedSupplierId()))>
	<!---set recommended supplier--->
	<cfset recommendSuppId = requestObj.procurement.rawMaterial[rmIndx].getRecommendedSupplierId() />
</cfif>
	
<table cellpadding="2" cellspacing="0" width="100%" bgcolor="##E8FCFD">
	<tr>
		<td colspan="4" style="border-bottom:1px solid navy;">
			<B>[#requestObj.procurement.rawMaterial[rmIndx].getNumber()#] #requestObj.procurement.rawMaterial[rmIndx].getDesc()#</B>&nbsp;&nbsp;&nbsp;			
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
			<table width="90%" border="0" cellpadding="2" cellspacing="0" class="MainTable">				
				<tr bgcolor="##FFCE84">
					<td id="header"><b>Awarded</b></td>
					<td id="header"><B>Supplier</B></td>
					<td id="header"><B>Quote</B></td>
					<td id="header"><B>Volume</B></td>
					<td id="header"><B>UOM</B></td>
					<td id="header"><B>Quote Date</B></td>
					<td id="header"><B>Quote Good Until</B></td>
				</tr>
				
					
				<!---now loop over supplier array and display--->
				<cfif ArrayLen(requestObj.procurement.rawMaterial[rmIndx].supplierQuotes)>
				
					<cfloop index="suppIndx" from="1" to="#ArrayLen(requestObj.procurement.rawMaterial[rmIndx].supplierQuotes)#">
						<!---set the supplier id--->
						<cfset suppId = requestObj.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getSupplierId() />

						<cfset lSuppId = ListAppend(lSuppId, suppId) />
						
						<tr>
							<td>
								<cfif requestObj.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getIsSelected()>yes<cfelse>no</cfif></td>
							<td>
								#requestObj.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getSupplierName()#
								<cfif suppId eq recommendSuppId>&nbsp;&nbsp;<font face="Arial, Helvetica, sans-serif" color="##FF0000">RS</font></cfif>
							</td>
							<td>
								#requestObj.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getQuote()#
							</td>
							<td>
								#requestObj.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getQuoteVolume()#
							</td>
							<td>
								<cfif requestObj.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getQuoteUOM() eq 1>LBS</cfif>
								<cfif requestObj.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getQuoteUOM() eq 2>CWT</cfif>
							</td>
							<td>
								#DateFormat(requestObj.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getQuoteDate(), "mm/dd/yyyy")#&nbsp;
							</td>
							<td>
								#DateFormat(requestObj.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getQuoteGoodUntil(), "mm/dd/yyyy")#&nbsp;
							</td>
						</tr>
					</cfloop>
				
				<cfelse>
				<tr><td colspan="100%">None Selected</td></tr>
				</cfif>
			</table>
		</td>
	</tr>
</table>
<br><br>

</cfloop>		

</cfoutput>