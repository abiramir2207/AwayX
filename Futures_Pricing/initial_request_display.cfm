<cfoutput>

<!----///////////////////////////////////////////////// PRICING SECTION /////////////////////////////////////////////////////////////////--->
<hr color="##000080">

<TABLE BORDER="0" CELLPADDING="5" STYLE="border-collapse: collapse" ID="table1">
	<TR>
		<TD NOWRAP><B>Request:</B>&nbsp;&nbsp;&nbsp;#requestObj.getTitle()#</TD>
	</TR>
	<TR>
		<TD><B>Request Description:</B>&nbsp;&nbsp;&nbsp;#requestObj.getRequest()#</TD>
	</TR>
</table>
<br><br>
<!---//////////////////////////////////////////////////////// DATES SECTION ////////////////////////////////////////////////////////--->
<B><FONT SIZE="2" COLOR="##000080">Request Dates</FONT></B>&nbsp;&nbsp;&nbsp;
<hr color="##000080" size="1px">
<TABLE border="0" CELLPADDING="3" cellspacing="0">
	<TR bgcolor="##FFCE84">
		<TD class="borderRight">
			<b>Start Date</b>
		</TD>
		<TD class="borderRight">
			<b>End Date</b>
		</TD>
		<TD class="borderRight">
			<b>Customer Deadline Date</b>
		</TD>
	</TR>
	<TR>
		<TD class="borderRightBottom">
			<cfif Len(trim(requestObj.getStartDate()))>#DateFormat(requestObj.getStartDate(), "mm/dd/yyyy")#<cfelse>None</cfif>
		</TD>
		<TD class="borderRightBottom">
			<cfif Len(trim(requestObj.getEndDate()))>#DateFormat(requestObj.getEndDate(), "mm/dd/yyyy")#<cfelse>None</cfif>	
		</TD>
		<TD class="borderRightBottom">
			<cfif Len(trim(requestObj.getDeadLineDate()))>#DateFormat(requestObj.getDeadLineDate(), "mm/dd/yyyy")#<cfelse>None</cfif>
		</TD>
	</TR>
</table>

<br><br>
<!---//////////////////////////////////////////////////////// PRODUCTS SECTION ////////////////////////////////////////////////////////--->
<B><FONT SIZE="2" COLOR="##000080">Products</FONT></B>&nbsp;&nbsp;&nbsp;
<hr color="##000080" size="1px">
<!---if we have a product list then list them--->
<cfif ArrayLen(requestObj.requestProduct)>
	<!---get product data for id's in the list--->
	<cfloop index="prodIndx" from="1" to="#ArrayLen(requestObj.requestProduct)#">
		<table>
			<tr>
				<td>			
					<font face="Arial, Helvetica, sans-serif" color="##FF0000">LTO</font>
					<font face="Arial, Helvetica, sans-serif">=</font>
					<font face="Arial, Helvetica, sans-serif">Limited Time Offer</font>
				</td>
			</tr>
		</table>
		<table border="1" cellpadding="0" cellspacing="0" STYLE="border: 1px" width="100%">
			<TR>
				<TD COLSPAN="100%" VALIGN="top" bgcolor="##E8FCFD" STYLE="border-bottom: none">
					<TABLE BORDER="0" CELLPADDING="3" cellspacing="0" STYLE="border: 1px">
						<TR>
							<TD align="left" valign="top" COLSPAN="100%" id="header" STYLE="border-right: 1px"><b>#requestObj.requestProduct[prodIndx].getDesc()#&nbsp;&nbsp;&nbsp;#requestObj.requestProduct[prodIndx].getItem()#&nbsp;&nbsp;&nbsp;#requestObj.requestProduct[prodIndx].getUpc()#</b></TD>
						</TR>
						<TR>
							<TD valign="top">
								<B>Volume:</B>
								#NumberFormat(requestObj.requestProduct[prodIndx].getVolume() , '_.__')#&nbsp; <cfif Len(requestObj.requestProduct[prodIndx].getUom())><b>#request.app_general_functions.getUOMDesc(requestObj.requestProduct[prodIndx].getUom(), 0)#</b></cfif>
							</td>
							<td valign="top">
								<b>Delivery Type:</b>
								#requestObj.requestProduct[prodIndx].getDeliveryTypeDesc()#
							</td>
						</tr>
					</table>
				</td>
			<tr>
			<tr>
				<td STYLE="border-top: none">
					<TABLE BORDER="0" CELLPADDING="3" cellspacing="0" STYLE="border: 1px">
						<tr>
						<cfloop index="volDistIndx" from="1" to="#ArrayLen(requestObj.requestProduct[prodIndx].volumeDist)#">
							<cfset thisVolDist = requestObj.requestProduct[prodIndx].volumeDist[volDistIndx] />
							<td>
								<table border="1" cellpadding="3" cellspacing="0" STYLE="border: 1px solid">
									<tr bgcolor="##FFFFCC">
										<td style="border:none">
											#thisVolDist.getDesc()#
											<cfif thisVolDist.getLimitedTimeOffer() eq 1><font face="Arial, Helvetica, sans-serif" color="##FF0000">LTO</font></cfif>
										</td>
									</tr>
									<tr>
										<td style="border:none">
											#NumberFormat(thisVolDist.getVolume(), '_.__')#
										</td>
									</tr>
								</table>
							</td>
							<!---start new tr for every eight buckets--->
							<cfif volDistIndx mod 8 eq 0><tr></TR></cfif>
						</cfloop>
						</tr>
					</table>
				</td>
			</tr>
		</table>
		<br>
	</cfloop>
	
<cfelse>

<table>
	<tr>
		<td>No Products Selected</td>
	</tr>
</table>

</cfif>
<br><br>
<!---/////////////////////////////////////////////////// DISTRIBUTORS SECTION //////////////////////////////////////////////////////////--->
<B><FONT SIZE="2" COLOR="##000080">#application.returned_customer_setting.distributor_label_plural#</FONT></B>&nbsp;&nbsp;&nbsp;
<hr color="##000080" size="1px">
<table>
	<!---if we have a product list then list them--->
	<cfif Len(trim(requestObj.getLDistributorIds()))>
		<!---get distributor data for id's in the list--->
		<cfset qGetDistributors = CreateObject("component", "components.futures_pricing.RequestDistributorManager").getDistributorList(requestObj.getLDistributorIds()) />
		<cfloop query="qGetDistributors">
			<TR>
				<td>#Name#</td>
			</TR>
		</cfloop>
	<cfelse>
		<tr>
			<td>No #application.returned_customer_setting.distributor_label_plural# Selected</td>
		</tr>
	</cfif>
</TABLE>
<br><br>
<!---///////////////////////////////////////////////////////// OPERATORS SECTION ////////////////////////////////////////////////////////--->
<B><FONT SIZE="2" COLOR="##000080">#application.returned_customer_setting.operator_label_plural#</FONT></B>&nbsp;&nbsp;&nbsp;
<hr color="##000080" size="1px">
<table>
	<!---if we have an operator list then list them--->
	<cfif Len(trim(requestObj.getLOperatorIds()))>
		<!---get operator data for id's in the list--->
		<cfset qGetOperators = CreateObject("component", "components.futures_pricing.RequestOperatorManager").getOperatorList(requestObj.getLOperatorIds()) />
		<cfloop query="qGetOperators">
			<TR>
				<td>#Operator_Name#</td>
			</TR>
		</cfloop>
	<cfelse>
		<tr>
			<td>No #application.returned_customer_setting.operator_label_plural# Selected</td>
		</tr>
	</cfif>
</TABLE>

</cfoutput>
