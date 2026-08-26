<cfoutput>
<script src="initial_request_create_edit.js"></script>
<SCRIPT SRC="/Script/javascript/validateFormUtils.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/date_functions.js"></SCRIPT>
<!----///////////////////////////////////////////////// PRICING SECTION /////////////////////////////////////////////////////////////////--->
<hr color="##000080">

<form action="#thisPageUrl#" method="post" name="#formName#">
<TABLE BORDER="0" CELLPADDING="5" STYLE="border-collapse: collapse" ID="table1">
	<TR>
		<TD ALIGN="right" VALIGN="top" NOWRAP><span id="Err_Sp_Req_Name"></span><B>Request Name:</B></TD>
		<TD COLSPAN="3" VALIGN="top"><INPUT NAME="title" TYPE="text" SIZE="75" value="#requestObj.getTitle()#" maxlength="225"></TD>
	</TR>
	<TR>
		<TD ALIGN="right" VALIGN="top" NOWRAP><B>Request Description:</B><br><font color="##FF0000">(Max: 1000 characters)</font></TD>
		<TD COLSPAN="3" VALIGN="top"><textarea name="Customer_Request" cols="80" rows="3" onKeyUp="textAreaMaxLength(this, '1000');">#requestObj.getRequest()#</textarea></TD>
	</TR>
</table>
<br><br>
<!---//////////////////////////////////////////////////////// DATES SECTION ////////////////////////////////////////////////////////--->
<B><FONT SIZE="2" COLOR="##000080">Request Dates</FONT></B>&nbsp;&nbsp;&nbsp;
<cfset pageURL = "handler.cfm?command=ceRequestDates&id=#url.id#" />
<CF_smallLink 
	title = "edit dates" 
	url = "#pageURL#"
	parameters = "onClick=""javascript: NewWindow(this.href , 'dates' , 500 , 400 , 'yes' , 'yes'); return false;"""
>
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
			<span id="Err_Sp_Start_Date"></span>
			<cfif Len(trim(requestObj.getStartDate()))>#DateFormat(requestObj.getStartDate(), "mm/dd/yyyy")#<cfelse>None</cfif>
			<input name="Start_Date" type="hidden" value="#DateFormat(requestObj.getStartDate(), "mm/dd/yyyy")#" />
		</TD>
		<TD class="borderRightBottom">
			<span id="Err_Sp_End_Date"></span>
			<cfif Len(trim(requestObj.getEndDate()))>#DateFormat(requestObj.getEndDate(), "mm/dd/yyyy")#<cfelse>None</cfif>
			<input name="End_Date" type="hidden" value="#DateFormat(requestObj.getEndDate(), "mm/dd/yyyy")#" />	
		</TD>
		<TD class="borderRightBottom">
			<cfif Len(trim(requestObj.getDeadLineDate()))>#DateFormat(requestObj.getDeadLineDate(), "mm/dd/yyyy")#<cfelse>None</cfif>
			<input name="Customer_Deadline" type="hidden" value="#DateFormat(requestObj.getDeadLineDate(), "mm/dd/yyyy")#" />
		</TD>
	</TR>
</table>

<br><br><br>
<!---//////////////////////////////////////////////////////// PRODUCTS SECTION ////////////////////////////////////////////////////////--->
<span id="Err_Sp_Products"></span><B><FONT SIZE="2" COLOR="##000080">Products</FONT></B>&nbsp;&nbsp;&nbsp;
<CF_smallLink 
	title = "get products" 
	url = "##"
	parameters = "onClick=""javascript: return showProductSearchWindow('#formName#');"""
>
&nbsp;&nbsp;&nbsp;
<CF_smallLink 
	title = "add new product" 
	url = "##"
	parameters = "onClick=""javascript: return showNewProductSearchWindow('#formName#','New_Product_List');"""
>
<hr color="##000080" size="1px">
<!---if we have a product list then list them--->
<cfif ArrayLen(requestObj.requestProduct)>
	<cfset tmpPeriodType = trim(requestObj.getPeriodType()) />
	<table>
		<tr>
			<td>
				<b>Set Periods By:</b>&nbsp;
				<select name="periodType">
					<option value="1" <cfif tmpPeriodType eq 1>selected</cfif>>Calendar</option>
					<option value="2" <cfif tmpPeriodType eq 2>selected</cfif>>Fiscal</option>
				</select>
				&nbsp;&nbsp;
				<CF_smallLink 
					title = "apply" 
					url = "##"
					parameters = "onClick=""JavaScript: return submitForm('#formName#','ceInitialRequest');"""
				>
			</td>
		</tr>
	</table>
	<br>
	<!---get product data for id's in the list--->
	<cfset requestSpan = 1 />
	<cfif isDate(requestObj.getStartDate()) and isDate(requestObj.getEndDate())>
		<cfset requestSpan = DateDiff("d", requestObj.getStartDate(), requestObj.getEndDate()) +1 />
	</cfif>
	
	<cfloop index="prodIndx" from="1" to="#ArrayLen(requestObj.requestProduct)#">
		<!---set prodId based on prod id or new prod id--->
		<cfif Len(requestObj.requestProduct[prodIndx].getProdId())>
			<cfset productId = requestObj.requestProduct[prodIndx].getProdId() />
			<cfset prodId = request.app_general_functions.replaceHyphen(productId) />
			<cfset sourceProductObject = "Product_List" />
			<cfset sourceProductObject2 = "ExistingProductList" />
		<cfelseif Len(requestObj.requestProduct[prodIndx].getNewProdId())>
			<cfset productId = requestObj.requestProduct[prodIndx].getNewProdId() />
			<cfset prodId = productId />
			<cfset sourceProductObject = "New_Product_List" />
			<cfset sourceProductObject2 = "New_Product_List" />
		</cfif>
		<!---set the volume distribution length--->
		<cfset volDistIndxLen = ArrayLen(requestObj.requestProduct[prodIndx].volumeDist) />
		<table>
			<tr>
				<td>			
					<font face="Arial, Helvetica, sans-serif" color="##FF0000">LTO</font>
					<font face="Arial, Helvetica, sans-serif">=</font>
					<font face="Arial, Helvetica, sans-serif">Limited Time Offer</font>
				</td>
			</tr>
		</table>
		<table border="1" cellpadding="0" cellspacing="0" STYLE="border: 1px" ID="SCISSOR_ITEM_#prodId#" width="100%">
			<TR>
				<TD COLSPAN="100%" VALIGN="top" STYLE="border-bottom: none;background-color:##E8FCFD;">
					<TABLE CELLPADDING="3" cellspacing="0">
						<TR>
							<TD align="left" valign="top" COLSPAN="100%" id="header" STYLE="border-right: 1px">
								<!------ scissors ----->
								<img bDelete="true" name="IMG_Delete_Scissor" src="/images/scissor.gif" alt="click here to delete this record" border="0" onclick="deleteThisRecord('#prodId#', '#productId#', document.#formName#.#sourceProductObject#, document.#formName#.#sourceProductObject2#)" style="cursor: hand;">
								<b>#requestObj.requestProduct[prodIndx].getDesc()#&nbsp;&nbsp;&nbsp;#requestObj.requestProduct[prodIndx].getItem()#&nbsp;&nbsp;&nbsp;#requestObj.requestProduct[prodIndx].getUpc()#</b>
								<!---if the prod id is numeric then we know it's a new product so show edit and display links--->
								<cfif IsNumeric(prodId)>
									<cf_smallLink
										title="display"
										url="##"
										parameters = "onClick=""javascript: return showNewProductWindow('dNewProduct','#prodId#');"""
									>
									&nbsp;&nbsp;
									<cf_smallLink
										title="edit"
										url="##"
										parameters = "onClick=""javascript: return showNewProductWindow('ceNewProduct','#prodId#');"""
									>
								</cfif>
							</TD>
						</tr>
						<tr>
							<TD valign="top">
								<span id="Err_Sp_Volume_#prodId#"></span>
								<B>Volume:</B>
								<INPUT NAME="volume_#prodId#" TYPE="text" SIZE="10" value="#requestObj.requestProduct[prodIndx].getVolume()#" onChange="setDistVolumeOnChange(document.#formName#,'#prodId#','#volDistIndxLen#', #requestSpan#);" onKeyUp="clenseText(this, '0123456789');">&nbsp;
								<cfif Len(requestObj.requestProduct[prodIndx].getNewProdId())>
									<INPUT NAME="uom_#prodId#" TYPE="hidden" VALUE="2" /><B>Pounds</B>
								<cfelse>
									<select name="uom_#prodId#">
										<option value="1" <cfif requestObj.requestProduct[prodIndx].getUom() eq 1>selected</cfif>>Cases</option>
										<option value="2" <cfif requestObj.requestProduct[prodIndx].getUom() eq 2 or not Len(trim(requestObj.requestProduct[prodIndx].getUom()))>selected</cfif>>Pounds</option>
									</select>
								</cfif>
							</td>
							<td valign="top">
								<b>Delivery Type:</b>
								<select name="deliveryTypeId_#prodId#">
									<cfloop query="qGetDeliveryType">
										<option value="#Delivery_Type_ID#" <cfif requestObj.requestProduct[prodIndx].getDeliveryTypeId() eq Delivery_Type_ID>selected</cfif>>#Delivery_Type_Desc#</option>
									</cfloop>
								</select>
							</td>
						</tr>
					</table>
				</td>
			<tr>
			<tr>
				<td>
					<TABLE BORDER="0" CELLPADDING="3" cellspacing="0">
						<tr>
							<td colspan="100%">
								<span id="Err_Sp_Volume_Dist_#prodId#"></span>
								<cf_smallLink
									title="distribute evenly"
									url="##"
									parameters = "onClick=""javascript: return setDistVolume(document.#formName#,'#prodId#','#volDistIndxLen#', #requestSpan#);"""
								>&nbsp;&nbsp;
								<cf_smallLink
									title="reset"
									url="##"
									parameters = "onClick=""javascript: return resetDistVolume(document.#formName#,'#prodId#','#volDistIndxLen#');"""
								>
							</td>
						</tr>
						<tr>
						<cfloop index="volDistIndx" from="1" to="#ArrayLen(requestObj.requestProduct[prodIndx].volumeDist)#">
							<cfset thisVolDist = requestObj.requestProduct[prodIndx].volumeDist[volDistIndx] />
							<td valign="top">
								<table border="1" cellpadding="1" cellspacing="0" STYLE="border: 1px">
									<tr style="background-color:##FFFFCC;">
										<td title="#DateFormat(thisVolDist.getStartDate(), "mm/dd/yyyy")# - #DateFormat(thisVolDist.getEndDate(), "mm/dd/yyyy")#" valign="top" STYLE="border-bottom:none">
											#thisVolDist.getDesc()#
											<font face="Arial, Helvetica, sans-serif" color="##FF0000">LTO</font><input name="lto_#prodId#_#volDistIndx#" type="checkbox" value="1" <cfif thisVolDist.getLimitedTimeOffer() eq 1>checked</cfif> />
										</td>
									</tr>
									<tr style="background-color:##FFFFCC;">
										<td STYLE="border-top:none">
											<INPUT NAME="periodVolume_#prodId#_#volDistIndx#" TYPE="text" value="#NumberFormat(trim(thisVolDist.getVolume()), "_.__")#" size="10" onChange="this.value = formatToDecimalPlaces(this.value, 2);" />
										</td>
									</tr>
								</table>
							</td>
							<input type="hidden" name="periodStartDate_#prodId#_#volDistIndx#" value="#DateFormat(thisVolDist.getStartDate(), "mm/dd/yyyy")#" />
							<input type="hidden" name="periodEndDate_#prodId#_#volDistIndx#" value="#DateFormat(thisVolDist.getEndDate(), "mm/dd/yyyy")#" />
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
<span id="Err_Sp_Dist"></span><B><FONT SIZE="2" COLOR="##000080">#application.returned_customer_setting.distributor_label_plural#</FONT></B>&nbsp;&nbsp;&nbsp;
<CF_smallLink 
	title = "get #LCase(application.returned_customer_setting.distributor_label_plural)#" 
	url = "##"
	parameters = "onClick=""javascript: return showDistributorSearchWindow('dataForm');"""
>
<hr color="##000080" size="1px">
<table>
	<!---if we have a distributor list then list them--->
	<cfif Len(trim(requestObj.getLDistributorIds()))>
		<!---get distributor data for id's in the list--->
		<cfset qGetDistributors = CreateObject("component", "components.futures_pricing.RequestDistributorManager").getDistributorList(requestObj.getLDistributorIds()) />
		<cfloop query="qGetDistributors">
			<cfset distIDRe = request.app_general_functions.replaceHyphen(BSA_Foodservice_Customers_ID) />
			<TR>
				<td ID="SCISSOR_ITEM_#distIDRe#">
				<img bDelete="true" name="IMG_Delete_Scissor" src="/images/scissor.gif" alt="click here to delete this record" border="0" onclick="deleteThisRecord('#distIDRe#', '#BSA_Foodservice_Customers_ID#', document.#formName#.Distributor_List)" style="cursor: hand;">&nbsp;#Name#</td>
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
<span id="Err_Sp_Oper"></span><B><FONT SIZE="2" COLOR="##000080">#application.returned_customer_setting.operator_label_plural#</FONT></B>&nbsp;&nbsp;&nbsp;
<CF_smallLink 
	title = "get #application.returned_customer_setting.operator_label_plural#" 
	url = "##"
	parameters = "onClick=""javascript: return showOperatorSearchWindow('dataForm');"""
>
<hr color="##000080" size="1px">
<table>
	<!---if we have an operator list then list them--->
	<cfif Len(trim(requestObj.getLOperatorIds()))>
		<!---get operator data for id's in the list--->
		<cfset qGetOperators = CreateObject("component", "components.futures_pricing.RequestOperatorManager").getOperatorList(requestObj.getLOperatorIds()) />
		<cfloop query="qGetOperators">
			<TR>
				<td ID="SCISSOR_ITEM_#BSA_Operator_ID#">
				<img bDelete="true" name="IMG_Delete_Scissor" src="/images/scissor.gif" alt="click here to delete this record" border="0" onclick="deleteThisRecord('#BSA_Operator_ID#', '#BSA_Operator_ID#', document.#formName#.Operator_List)" style="cursor: hand;">&nbsp;#Operator_Name#</td>
			</TR>
		</cfloop>
	<cfelse>
		<tr>
			<td>No #application.returned_customer_setting.operator_label_plural# Selected</td>
		</tr>
	</cfif>
</TABLE>

<P>
<CF_smallLink 
	title = "save only" 
	url = "##"
	parameters = "onClick=""JavaScript: return submitForm('#formName#','sInitialRequest');"""
>
<CF_smallLink 
	title = "save &amp; forward" 
	url = "##"
	parameters = "onClick=""JavaScript: return submitForm('#formName#','sInitialRequestForward');"""
>

</P>

<INPUT NAME="state" TYPE="Hidden" VALUE="1" />
<INPUT NAME="command" TYPE="Hidden" VALUE="#form.command#" />
<INPUT NAME="volDistIndx" TYPE="Hidden" VALUE="#volDistIndxLen#" />
<INPUT NAME="createdBy" TYPE="Hidden" VALUE="#request.AccessStructure.User_Id#" />
<INPUT NAME="updatedBy" TYPE="Hidden" VALUE="#request.AccessStructure.User_Id#" />
<INPUT NAME="companyId" TYPE="Hidden" VALUE="#request.AccessStructure.Company_Main_ID#" />
<INPUT NAME="SelectSingleSearchResultOnly" TYPE="Hidden" VALUE="0" />
<INPUT NAME="Restrict_Cust_DL" TYPE="Hidden" VALUE="#trim(restrictCustDL)#" />
<INPUT NAME="Lead_Time" TYPE="Hidden" VALUE="#trim(leadTime)#" />

<!---from request object--->
<INPUT NAME="New_Product_List" TYPE="Hidden" VALUE="#requestObj.getLNewProductIds()#" />
<INPUT NAME="Product_List" TYPE="Hidden" VALUE="#requestObj.getLProductIds()#" />
<INPUT NAME="ExistingProductList" TYPE="Hidden" VALUE="#requestObj.getLProductIds()#" />
<INPUT NAME="Distributor_List" TYPE="Hidden" VALUE="#trim(requestObj.getLDistributorIds())#" />
<INPUT NAME="Operator_List" TYPE="Hidden" VALUE="#trim(requestObj.getLOperatorIds())#" />
<INPUT NAME="id" TYPE="Hidden"  VALUE="#requestObj.getId()#" />
<INPUT NAME="statusId" TYPE="Hidden" VALUE="#requestObj.getStatusId()#" />
<INPUT NAME="forward" TYPE="Hidden" VALUE="#requestObj.getForward()#" />

</form>
<cf_MessageWindow />
</cfoutput>
