<!------ deal_sheet.cfm ----->
<cfoutput>
<cfset reqManager = CreateObject("component", "components.futures_pricing.PricingManager").init() />
<cfset requestObj = reqManager.getPricingRequest(form.id, 0) />

<FONT SIZE="3" COLOR="##000080"><B>Deal&nbsp; Sheet</B></FONT>
<BR><BR>
<TABLE BORDER="0" CELLPADDING="3" STYLE="border:1px solid ##000080; border-collapse: collapse" WIDTH="100%" ID="table7">
	<TR>
		<TD width="">
		<FONT COLOR="##000080" SIZE="2">
		<B>#requestObj.getTitle()#</B></FONT></TD>
		<TD NOWRAP bgcolor="##000080" width="120">
		<P ALIGN="center"><FONT size="2" color="##FFFFFF"><B>&nbsp; Offer Good Until&nbsp;&nbsp;<BR>
		&nbsp;&nbsp;</FONT><FONT SIZE="2" color="##FFFF00"><cfif isDate(requestObj.getGoodUntilDate())>#DateFormat(requestObj.getGoodUntilDate(), "mm/dd/yyyy")#<cfelse>N/A</cfif></FONT><FONT SIZE="2" color="##FFFFFF">&nbsp;&nbsp;</FONT></B></TD>
	</TR>
</TABLE>

<cfset reqStartDate = requestObj.getStartDate()>
<cfset reqEndDate = requestObj.getEndDate()>
<cfif isDate(reqStartDate) AND isDate(reqEndDate)>
	<cfset requestSpan = DateDiff("d", reqStartDate, reqEndDate) + 1>
<cfelse>
	<cfset requestSpan = 1>
</cfif>
<cfset deliveryTypeManager = CreateObject("component","components.products.DeliveryTypeManager").init() />

<TABLE width="100%" BORDER="0" CELLPADDING="5" STYLE="border-collapse: collapse" ID="table2">
	<colgroup>
		<col span="1" width="20%" align="right"></col>
		<col span="1" width="20%"></col>
		<col span="1" width="20%"></col>
		<col span="1" width="40%"></col>
	</colgroup>
	<TR>
		<TD NOWRAP VALIGN="top">&nbsp;</TD>
		<TD VALIGN="top" NOWRAP>
		&nbsp;</TD>
		<TD VALIGN="top" NOWRAP>
		&nbsp;</TD>
		<TD VALIGN="top" NOWRAP>
		&nbsp;</TD>
	</TR>
	<TR>
		<TD NOWRAP VALIGN="top"><B>Critical Dates:</B></TD>
		<TD VALIGN="top" NOWRAP>
		<B>Start Date:<FONT COLOR="##FF0000"><BR>
		#DateFormat(reqStartDate, "mm/dd/yyyy")#</FONT></B></TD>
		<TD VALIGN="top" NOWRAP>
		<B>End Date:<FONT COLOR="##FF0000"><BR>
		#DateFormat(reqEndDate, "mm/dd/yyyy")#</FONT></B></TD>
		<TD VALIGN="top" NOWRAP>
		<B>Customer Deadline:<FONT COLOR="##FF0000"><BR>
		#DateFormat(requestObj.getDeadLineDate(), "mm/dd/yyyy")#</FONT></B></TD>
	</TR>
	<TR>
		<TD colspan="100%">&nbsp;</TD>
	</TR>
	<!------ Loop thru products ----->
	<cfset requestProductArray = requestObj.getRequestProduct()>
	<cfset productCount = ArrayLen(requestProductArray)>
	<cfloop index="prodIndex" from="1" to="#productCount#">
	
		<cfset requestProduct = requestProductArray[prodIndex]>
		<cfset uomDesc = request.app_general_functions.getUOMDesc(requestProduct.getUom(), 0)>
		<TR>
			<TD NOWRAP VALIGN="top"><B>Product#prodIndex#:</B></TD>
			<TD VALIGN="top" COLSPAN="3">#requestProduct.getDesc()# #requestProduct.getItem()# #requestProduct.getUpc()#</TD>
		</TR>
		<TR>
			<TD NOWRAP VALIGN="top">&nbsp;</TD>
			<TD VALIGN="top" NOWRAP>
			<B>Total Volume:<FONT COLOR="##FF0000"><BR>
			#requestProduct.getVolume()# #uomDesc#</FONT></B></TD>
			<TD VALIGN="top" NOWRAP>
			<B>Avg. Volume / Month:<BR>
			<FONT COLOR="##FF0000">#NumberFormat(Evaluate((requestProduct.getVolume()/requestSpan)*30), "___,___,___.__")# #uomDesc#</FONT></B></TD>
			<TD VALIGN="top" NOWRAP>
			<B>Fixed Price:<BR>
			<FONT COLOR="##FF0000">
			<cfif requestObj.getStatusId() GT 4>
			#requestProduct.getFinalPrice()# / #uomDesc# - #deliveryTypeManager.getDeliveryTypeDesc(requestProduct.getDeliveryTypeId())#
			<cfelse>
			N/A
			</cfif>
			</FONT></B></TD>
		</TR>
	</cfloop>
	<TR>
		<TD NOWRAP VALIGN="top"><B>Customer Requests:</B></TD>
		<TD VALIGN="top" COLSPAN="3">#requestObj.getRequest()#</TD>
	</TR>
	<TR>
		<TD NOWRAP VALIGN="top"><B>#application.returned_customer_setting.distributor_label_plural#:</B></TD>
		<TD VALIGN="top" COLSPAN="3">
		<cfset qGetDistributors = CreateObject("component", "components.futures_pricing.RequestDistributorManager").getDistributorList(requestObj.getLDistributorIds()) />
		<cfif qGetDistributors.recordCount GT 0>
			<cfloop query="qGetDistributors">
				#Name#<br>
			</cfloop>
		<cfelse>
			<font color="red">None Selected</font>
		</cfif>
		</TD>
	</TR>
	<TR>
		<TD NOWRAP VALIGN="top"><B>#application.returned_customer_setting.operator_label_plural#:</B></TD>
		<TD VALIGN="top" COLSPAN="3">
		<cfset qGetOperators = CreateObject("component", "components.futures_pricing.RequestOperatorManager").getOperatorList(requestObj.getLOperatorIds()) />
		<cfif qGetOperators.recordCount GT 0>
			<cfloop query="qGetOperators">
				#Operator_Name#<br>
			</cfloop>
		<cfelse>
			<font color="red">None Selected</font>
		</cfif>
		</TD>
	</TR>
	<!--------
	<TR>
		<TD NOWRAP VALIGN="top"><B>Clauses:</B></TD>
		<TD VALIGN="top" COLSPAN="3"><B>Clause 1</B><BR>x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x 
			x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
    x  x&nbsp;x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x 
			x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
    x  x x x x x x x x <B><BR><BR>Clause 2</B><BR>x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x 
			x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
x  x&nbsp;x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x 
			x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
x  x x x x x x x x 
		<P><B>Clause 3<BR></B>x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x 
			x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x 
			x&nbsp;x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x 
			x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x 
			x x x x x x x x </TD>
	</TR>
	<TR>
		<TD ALIGN="right" NOWRAP VALIGN="top"><B>Attachments:</B></TD>
		<TD VALIGN="top" COLSPAN="3">&nbsp;x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x 
			x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x 
			x&nbsp;x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x 
			x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x 
			x x x x x x x x </TD>
	</TR>
	------->
	<TR>
		<TD NOWRAP VALIGN="top">&nbsp;</TD>
		<TD VALIGN="top" COLSPAN="3">
		<DIV ALIGN="center">
			<TABLE BORDER="0" CELLPADDING="0" STYLE="border-collapse: collapse" WIDTH="100%" ID="table6">
				<TR>
					<TD WIDTH="50%" ALIGN="center"><BR>&nbsp;<HR WIDTH="75%" NOSHADE>Signature - Sales Manager<BR>
					<BR>Date:#RepeatString("&nbsp;", 30)#</TD>
					<TD WIDTH="50%" ALIGN="center"><BR>&nbsp;<HR WIDTH="75%" NOSHADE>Signature - Authorized Buyer<BR>
					<BR>Date:#RepeatString("&nbsp;", 30)#</TD>
				</TR>
			</TABLE>
		</DIV>
		</TD>
	</TR>
</TABLE>

</cfoutput>