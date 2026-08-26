<!---
	Name:
		trade_plan_calc.cfm
	Created By:
		Tim Ford 04/10/2003
	Description:
		This file will handle the diaply and edit of a trade plan
--->

<cfif CompareNoCase(action, "email")>
<!---Java script source files--->
<SCRIPT LANGUAGE="JavaScript" SRC="/script/javascript/string_functions.js"></script>
<script language="JavaScript" src="/billbacks/common/common_js_functions.js"></script>
<script language="JavaScript" src="trade_plan_src.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../wddx.js"></SCRIPT>

<script>

	function validate(whichAction,trdPlnId)
	{

		if (whichAction != 'update' && whichAction != 'save')
		{
			if(whichAction == 'delete')
			{
				if (confirm("Are you sure you want to delete this record?")) location.href='index.cfm?action=' + whichAction + '&trade_plan_id=' + trdPlnId;
			}
			else
				location.href='index.cfm?action=' + whichAction + '&trade_plan_id=' + trdPlnId;
		}
		else
		{

			if (validateInput())
			{
				document.marginForm.action.value = whichAction;
				document.marginForm.submit();
			}

		}

	}

</script>

</cfif>

<cfscript>

	function fontColor(num)
	{
		if (trim(num) gte 0 or trim(num) eq "")
			return "000000";
		else
			return "FF0000";
	}

</cfscript>

<cfif not CompareNoCase(action, "print")>
	<!------<cfinclude template="_print_help.cfm" />----->
	<CFINCLUDE template="/Common_Files/Printer_Friendly_Script.cfm">
</cfif>
<style>
	.thickSec td
	{
		border-bottom:2px solid #000080;
	}
	.thinBottom td
	{
		border-bottom:1px solid #000080;
	}
	.thinTop td
	{
		border-top:1px solid #000080;
	}
	.thinTpThickBtm td
	{
		border-top:1px solid #000080;
		border-bottom:2px solid #000080;
	}
	.tableHeader td
	{
		border-bottom:1px solid #000080;
	}

	DIV.BreakHere
	{
		page-break-before: always;
	}

	.bdRgt  {border-right:1px solid #909090;}
	.bdBotRgt  {border-right:1px solid #909090;border-bottom:1px solid #909090;}
	.bdBotRgtTop  {border-right:1px solid #909090;border-bottom:1px solid #909090;border-top:1px solid #909090;}
	.bdBotRgtLft  {border-right:1px solid #909090;border-bottom:1px solid #909090;border-left:1px solid #909090;}
	.bdBot  {border-bottom:1px solid #909090;}
	.bd  {border:1px solid #909090;}

	.netMargLblClsGrn {border-top:2px #00FF00 solid;border-left:2px #00FF00 solid;}
	.netMargValClsGrn {border-top:2px #00FF00 solid;border-right:2px #00FF00 solid;}
	.netProfLblClsGrn {border-bottom:2px #00FF00 solid;border-left:2px #00FF00 solid;}
	.netProfValClsGrn {border-bottom:2px #00FF00 solid;border-right:2px #00FF00 solid;}

	.netMargLblClsRed {border-top:2px #FF0000 solid;border-left:2px #FF0000 solid;}
	.netMargValClsRed {border-top:2px #FF0000 solid;border-right:2px #FF0000 solid;}
	.netProfLblClsRed {border-bottom:2px #FF0000 solid;border-left:2px #FF0000 solid;}
	.netProfValClsRed {border-bottom:2px #FF0000 solid;border-right:2px #FF0000 solid;}

</style>

<style type="text/css" media="print">
	thead
	{
		display: table-header-group;
	}
</style>

<cfoutput>

<!---Set default params--->
<cfparam name="Product_List" default="" />
<cfparam name="ExistingProductList" default="" />
<cfparam name="Distributor_List" default="" />
<cfparam name="lTypeGroupList" default="" />
<cfparam name="Proposed_Price" default="" />
<cfparam name="Quantity" default="" />
<cfparam name="Trade_Plan_ID" default="" />
<cfparam name="createdBy" default="" />
<cfparam name="volume" default=0 />
<cfparam name="totalCost" default=0 />
<cfparam name="revenue" default=0 />
<cfparam name="mixRev" default="" />
<cfparam name="mixWgt" default="" />
<cfparam name="extMarg" default="" />
<cfparam name="extMargPerc" default="" />
<cfparam name="classQtyTotal" default="" />
<cfparam name="classVolumeTotal" default="" />
<cfparam name="classTotalCostTotal" default="" />
<cfparam name="classTotalRevenue" default="" />
<cfparam name="classTotalMixRev" default="" />
<cfparam name="classTotalWgt" default="" />
<cfparam name="classTotalMargDoll" default="" />
<cfparam name="classTotalMargPercent" default="" />
<cfparam name="qtyTotal" default="0" />
<cfparam name="volumeTotal" default="0" />
<cfparam name="totalCostTotal" default="0" />
<cfparam name="totalRevenue" default="0" />
<cfparam name="totalMixRev" default="0" />
<cfparam name="totalWgt" default="0" />
<cfparam name="totalMargDoll" default="0" />
<cfparam name="totalMargPercent" default="0" />
<cfparam name="grandCostTotl" default="" />
<cfparam name="incCostGrndTotl" default="" />
<cfparam name="miscCostGrndTotl" default="" />
<cfparam name="lumpSumCostGrndTotl" default="" />
<cfparam name="totlNetProfit" default="" />
<cfparam name="totlNetMargin" default="" />
<cfparam name="netMargVal" default="" />
<cfparam name="revTotal" default=0 />
<cfparam name="volTotal" default=0 />
<cfparam name="actionState" default="" />
<cfparam name="form.start_date" default="" />
<cfparam name="form.end_date" default="" />
<cfparam name="tradePlanTitle" default="" />
<cfparam name="notes" default="" />
<cfparam name="Form.itemTotal" default="" />
<cfparam name="Form.forecast_id" default=0 />

<!---Gaurd against different action types--->

<!---////////////// EDIT //////////////--->
<cfif not CompareNoCase(action, "edit")>
	<cfset actionState = "edit" />
	<!---
	<cfset actionValue = "update" />
	<cfset actionLabel = "save" />
	--->
<!---////////////// COPY //////////////--->
<cfelseif not CompareNoCase(action, "copy")>
	<cfset actionState = "copy" />

<!---////////////// CREATE //////////////--->
<cfelseif not CompareNoCase(action, "create")>
	<cfset actionState = "create" />
	<!---
	<cfset actionValue = "save" />
	<cfset actionLabel = "save" />
	--->
<!---////////////// DISPLAY //////////////--->
<cfelseif not CompareNoCase(action, "display")>
	<cfset actionState = "display" />
	<!---
	<cfset actionValue = "edit" />
	<cfset actionLabel = "edit" />
	--->
<!---////////////// EMAIL //////////////--->
<cfelseif not CompareNoCase(action, "email")>
	<cfset actionState = "email_send" />
<!---////////////// FAX //////////////--->
<cfelseif not CompareNoCase(action, "fax")>
	<cfset actionState = "fax_send" />
</cfif>

<!---create all instances of objects--->
<cfscript>
	oUser = createObject("component","components.trade_plan.users");
	oTradePlan = createObject("component","components.trade_plan.trade_plan");
	oProduct = createObject("component","components.trade_plan.products");
	oDist = createObject("component","components.programs.distributors.Distributor");
	oForecast = createObject("component", "components.trade_plan.TradePlanForecast");
</cfscript>

<!---Gets the current user's position--->
<cfscript>
	getUserPosition = oUser.getUserPosition(request.AccessStructure.user_id);
</cfscript>

<CFSET GP_Supplied_Position = getUserPosition>

<!---Include approval rights--->
<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">

<!---if we aren't in create mode then get data from database--->
<cfif CompareNoCase(action, "create")>

	<!---Get trade plan data--->
	<cfscript>
		qGetTradePlan = oTradePlan.getTradePlan(Trade_Plan_ID,GP_Position_List_From_My_Position_Down);
	</cfscript>

	<!---set trade plan values--->
	<!---use forecast id from query if first time in, otherwise use what's in the form scope--->
	<cfif not isDefined("form.action")>
		<cfset tradePlanTitle = qGetTradePlan.Trade_Plan_Title />
		<cfset form.start_date = qGetTradePlan.Start_Date />
		<cfset form.end_date = qGetTradePlan.End_Date />
		<cfset notes = qGetTradePlan.Notes />
		<cfset form.forecast_id = qGetTradePlan.forecast_id />
	</cfif>

	<cfscript>
		qGetProductList = oProduct.getProductList(Trade_Plan_ID);
		qGetTotals = oProduct.getTotals(Trade_Plan_ID);
	</cfscript>

	<cfset revTotal = qGetTotals.Total_Revenue />
	<cfset volTotal = qGetTotals.Total_Volume />

	<!---Get user data--->
	<cfscript>
		qUserCreate = oUser.getUser(qGetTradePlan.Created_By);
		qUserUpdate = oUser.getUser(qGetTradePlan.Updated_By);
	</cfscript>

	<!---
	<cfif not CompareNoCase(Distributor_List, "") or CompareNoCase(action, "edit,copy")>
		<cfset Distributor_List = qGetTradePlan.Distributor_ID />
	</cfif>
	--->
	<!---  (start) This code replaces the code above --->
	<cfif isDefined("form.distributor_list")>
		<cfset Distributor_list = distributor_list />
	<cfelse>
		<cfset Distributor_list = ValueList(qGetTradePlan.Distributor_ID) />
	</cfif>
	<!--- (End) This code replaces the code above --->

	<!---We have to clear the Product_List for display--->
	<cfif not CompareNoCase(action, "display")>
		<cfset Product_List = "" />
		<cfset Product_List =  ValueList(qGetProductList.product_ID) />
	</cfif>

	<cfif isDefined("form.product_list")>
		<cfset product_list = form.product_list />
	<cfelse>
		<cfset product_list = ValueList(qGetProductList.product_ID) />
	</cfif>

</cfif>

<!---get volume forecast info if we have one--->
<cfif form.forecast_id>

	<cfset qForecastData = oForecast.getForecastData(form.forecast_id) />
	<cfset tradeSpan = form.end_date - form.start_date+1 />
	<cfset forcstSpan = qForecastData.Forecast_To_Date - qForecastData.Forecast_From_Date+1	 />
	<cfset qForecastProdData = oForecast.getForecastProdData(form.forecast_id,tradeSpan,forcstSpan) />

	<!---don't create JS objects if in email--->
	<cfif CompareNoCase(action, "email")>

			<!---convert queries into JS--->
			<script language="JavaScript">

				//convert forecast summary data into a JS object
				<CFWDDX ACTION="cfml2js" INPUT="#qForecastData#" TOPLEVELVARIABLE="ForeCstData">

				//convert forecast product data into a JS object
				<CFWDDX ACTION="cfml2js" INPUT="#qForecastProdData#" TOPLEVELVARIABLE="ForeCst">

			</script>

	</cfif>

</cfif>

<!---If we have an item list then let's get the data from the database--->
<cfif Len(Product_List)>

	<cfscript>
		qGetItems = oProduct.getProducts(Product_List);
		qGetItemTypes = oProduct.getProductTypes(Product_List);
	</cfscript>

	<cfset product_list = ValueList(qGetItems.BSA_Foodservice_Items_Master_ID) />

</cfif>

<!---get distributor--->
<cfif Len(Distributor_List)>
	<cfset qGetDist = oDist.getDistributor('#Distributor_List#') />
</cfif>

<form method="post" name="marginForm">

<!---PRINT,FAX,EMAIL MODE:--->
<cfif ListFindNoCase("print,email,fax", action)>
<table width="90%" align="center">
	<tr bgcolor="000080">
		<td colspan="100"><font color="white" size="+1"><b>#application.returned_customer_setting.Trade_Label# Spending #Application.PlannerLabel#</b></font></td>
	</tr>
</table>
</cfif>

<!---Header Table--->
<table BGCOLOR="Whitesmoke" WIDTH="90%" align="center" border="0" cellpadding="0" cellspacing="5" STYLE="BORDER-LEFT:1PX SOLID SILVER; BORDER-RIGHT:1PX SOLID SILVER; BORDER-TOP:1PX SOLID SILVER; BORDER-BOTTOM:1PX SOLID SILVER;">
<!---Report information --->
	<tr>
		<td NOWRAP><font color="##FFFFFF">&nbsp;</font><FONT SIZE="2"><b>Report Title:</b></FONT></td>
		<TD ROWSPAN="100%">&nbsp;&nbsp;&nbsp;</TD>
		<td align="left" WIDTH="50%">
		<cfif ListFindNoCase("edit,copy,create", action)>
			<input type="text" name="tradePlanTitle" size="61" value="#HTMLEditFormat(tradePlanTitle)#">
		<cfelse>
			<FONT SIZE="2">#tradePlanTitle#</FONT>
		</cfif>
		</td>
		<TD ROWSPAN="100%" width="50%" valign="top" align="left">

		</TD>
	</tr>
	<!---EDIT,PRINT,DISPLAY,EMAIL,FAX MODES:--->
	<cfif ListFindNoCase("edit,copy,display,print,email,fax", action)>
	<tr>
		<td NOWRAP><FONT SIZE="2"><b>Created By/on:</b></FONT></td>
		<td><FONT SIZE="2">#qUserCreate.name_first#</FONT><FONT SIZE="2"> #qUserCreate.name_last# on #DateFormat(qGetTradePlan.Created_Date, "mm/dd/yyyy")#</FONT></td>
	</tr>
	<tr>
		<td NOWRAP><FONT SIZE="2"><b>Updated By/on:</b></FONT></td>
		<td><FONT SIZE="2"><cfif qUserUpdate.RecordCount>#qUserUpdate.name_first# #qUserUpdate.name_last# on #DateFormat(qGetTradePlan.Updated_Date, "mm/dd/yyyy")#</cfif></FONT></td>
	</tr>
	</cfif>
	<tr>
		<td NOWRAP><FONT SIZE="2"><b>Notes:</b></FONT></td>
		<td>
		<cfif ListFindNoCase("edit,copy,create", action)>
			<textarea rows="5" name="notes" cols="47">#HTMLEditFormat(notes)#</textarea>
		<cfelse>
			<FONT SIZE="2">#notes#</FONT>
		</cfif>
		</td>
	</tr>
	<tr>
		<td VALIGN="top" NOWRAP><FONT SIZE="2"><b>#application.returned_customer_setting.distributor_label_singular#:</b></FONT></td>
		<td VALIGN="top">
			<FONT SIZE="2"><cfif isDefined("qGetDist") and qGetDist.RecordCount><cfloop query="qGetDist">#Name#</cfloop></cfif></FONT>
			<!---EDIT,CREATE MODE:--->
			<cfif ListFindNoCase("edit,copy,create",action)>
				<b><font color="FF0000">[</font> <a href="javascript: showDistributorSearchWindow();">select #application.returned_customer_setting.distributor_label_singular#</a> <font color="FF0000">]</font></b>
			</cfif>
			<cfif form.forecast_id>
				<cfset forecastDistId = oForecast.getForecastDist(form.forecast_id).distributor_ID />
				<cfif not ListFindNoCase(Distributor_List, forecastDistId)>
					<br>
					<font color="FF0000">
						#application.returned_customer_setting.distributor_label_singular# not in forecast.
					</font>
				</cfif>

			</cfif>

		</td>
	</tr>
	<tr>
		<td VALIGN="top" NOWRAP><FONT SIZE="2"><b>Span:</b></FONT></td>
		<td>
			<table cellpadding="1">
				<tr>
					<!---EDIT,CREATE MODE:--->
					<cfif ListFindNoCase("edit,copy,create",action)>
						<td VALIGN="top">
							From:<br>
							<CF_EASYDATE FORMNAME="marginForm" FIELDNAME="start_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.start_date#">
						</td>
						<td VALIGN="top">
							To:<br>
							<CF_EASYDATE FORMNAME="marginForm" FIELDNAME="end_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.end_date#">
						</td>
					<cfelse>
						<td VALIGN="top">
							From:<br>
							<FONT SIZE="2">#DateFormat(form.start_date, "mm/dd/yyyy")#</font>
						</td>
						<td VALIGN="top">
							To:<br>
							<FONT SIZE="2">#DateFormat(form.end_date, "mm/dd/yyyy")#</font>
						</td>
					</cfif>
				</tr>
					<tr>
						<td colspan="4">
						<cfif form.forecast_id>
							<span id="forcstDtMsg" style="visibility:hidden">
								<font color="FF0000">
									#application.returned_customer_setting.Trade_Label# Plan date span is different from last forecast.<br>
									#application.returned_customer_setting.Trade_Label# Plan date span in last forecast was #DateFormat(qForecastData.App_Area_Start_Date, "mm/dd/yyyy")# to #DateFormat(qForecastData.App_Area_End_Date, "mm/dd/yyyy")#.
								</font>
							</span>
							<!---if trade plan dates don't match forecast trade plan dates then show message--->
							<cfif (form.start_date neq qForecastData.App_Area_Start_Date) or (form.end_date neq qForecastData.App_Area_End_Date)>
								<script>
									forcstDtMsg.style.visibility = "visible";
								</script>
							</cfif>
						</cfif>
						</td>
					</tr>

			</table>
		</td>
	</tr>
	<cfif Form.forecast_id>
		<cfset forecastUser = oUser.getUser(qForecastData.Forecast_Update_User_ID) />
				<tr>
					<td colspan="100%">
						Forecast last updated by <b>#forecastUser.Name_First# #forecastUser.Name_Last#</b> on <b>#DateFormat(qForecastData.Forecast_Update_Date, "mm/dd/yyyy")#</b>
					</td>
				</tr>
	<cfelse>
		<tr><td colspan="100%"><b>This #application.returned_customer_setting.Trade_Label# Plan does not contain a volume forecast.</b></td></tr>
	</cfif>
</table>
<br>

<cfif Form.forecast_id>
<table width="90%" align="center">
	<tr>
		<td>
			<font color="FF0000">
			(1) Product Not In Forecast.<br>
			(2) QTY doesn't match volume forecast.<br>
			(3) QTY is zero in volume forecast.<br>
			</font>
		</td>
	</tr>
</table>
</cfif>
<br>
<!---
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////Products Section/////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--->

	<table WIDTH="90%" align="center" id="oTopSheet" border="0" cellspacing="0" cellpadding="2">
		<tr class="thickSec">
			<td colspan="20">
				<font color="red" size="+1"><b>Products</b></font>&nbsp;
				<cfif ListFindNoCase("edit,copy,create",action)>
					<cfif Len(Distributor_List)>
						<b><font color="FF0000">[</font> <a href="javascript: showProductSearchWindow();">select products</a> <font color="FF0000">]</font></b>
						<!---only show volume link if we have products--->
						<cfif Len(Product_List)>
							<b><font color="FF0000">[</font> <a href="javascript: showVolApplicator();">volume</a><font color="FF0000">]</font></b>
						</cfif>
					<cfelse>
						(Select a #application.returned_customer_setting.distributor_label_singular#)
					</cfif>
				</cfif>
			</td>

		</tr>
		<tr><td rowspan="<cfif isDefined("qGetItems") and isDefined("qGetItemTypes")>#Evaluate(qGetItems.RecordCount + qGetItemTypes.RecordCount + 2)#</cfif>">&nbsp;</td></tr>
		<tr class="tableHeader">
			<td><B>Item</B></td>
			<td><B>Description</B></td>
			<td align="right"><B>Case<BR>Cost</B></td>
			<td align="right"><B>Case<BR>Net Wgt.<br>(Lbs)</B></td>
			<td align="right"><B>Case<BR>List Price</B></td>
			<td align="right"><B>Prop. Case<BR>List Price</B></td>
			<td align="right"><B>QTY<br>(Case)</B></td>
			<td align="right"><B>Volume<BR>(Lbs)</B></td>
			<td align="right"><B>Total<BR>Cost</B></td>
			<td align="right"><B>Revenue</B></td>
			<td align="right"><B>Mix %<br>Rev.</B></td>
			<td align="right"><B>Mix %<br>Wgt.</B></td>
			<td align="right"><B>Ext.<br>Mar $</B></td>
			<td align="right"><B>Ext.<br>Mar %</B></td>
		</tr>
<!---Build the table once we get a product list--->
<cfif Len(Product_List)>

	<!---First loop through the item types--->
	<cfloop query="qGetItemTypes">

		<cfset thisItemType = qGetItemTypes.Type_Group_Desc />
		<!---Build a list of item id's--->
		<cfset lTypeGroupList = ListAppend(lTypeGroupList, Type_Group_Desc_ID) />

		<tr>
			<td colspan="20" bgcolor="##FFFFCC"><b>#thisItemType#</b></td>
		</tr>
		<!---Counter for each item class--->
		<cfparam name="itemClassCounter" default="0" />
		<!---Counter for each item--->
		<cfparam name="itemCounter" default="0" />

		<cfparam name="classQtyTotal#itemClassCounter#" default="0" />
		<cfparam name="classVolumeTotal#itemClassCounter#" default="0" />
		<cfparam name="classTotalCostTotal#itemClassCounter#" default="0" />
		<cfparam name="classTotalRevenue#itemClassCounter#" default="0" />
		<cfparam name="classTotalMargDoll#itemClassCounter#" default="0" />
		<cfparam name="classTotalMixRev#itemClassCounter#" default="0" />
		<cfparam name="classTotalWgt#itemClassCounter#" default="0" />

		<!---List variable that will hold a list of unique counters for each item in an item class--->
		<cfset itemClassList = "" />

		<!---Now loop through the products and build the table rows--->
		<cfloop query="qGetItems">

			<cfif not CompareNoCase(Trim(thisItemType), Trim(qGetItems.Type_Group_Desc))>

				<!---include file to get price list--->
				<cfinclude template="_get_price_list.cfm" />

				<cfset "proposedPrice#itemCounter#" = casePrice />
				<cfset "qty#itemCounter#" = 0 />
				<cfparam name="revenue#itemCounter#" default=0 />
				<cfparam name="freightWeight#itemCounter#" default=0 />

				<!---
				////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				///////////////////////////////////////////////////DISPLAY MODE////////////////////////////////////////////////////
				////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				--->
				<cfif CompareNoCase(action, "edit,copy,create") and not isDefined("form.action")>
					<!---Query on qGetProductList to get computed values--->
					<cfquery name="qGetCompVals" dbtype="query">
						SELECT 	Proposed_Price,
								Quantity
						FROM 	qGetProductList
						WHERE 	Product_ID = '#BSA_Foodservice_Items_Master_ID#'
					</cfquery>

					<cfif qGetCompVals.RecordCount>

						<cfset "proposedPrice#itemCounter#" = qGetCompVals.Proposed_Price />
						<cfset "qty#itemCounter#" = qGetCompVals.Quantity />

					</cfif>

				<!---
				////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				///////////////////////////////////////////////////EDIT,CREATE MODE////////////////////////////////////////////////////
				////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				--->
				<cfelse>

					<!---first time in edit mode then pull from database--->
					<cfif not compareNoCase(action, "edit,copy") and not isDefined("form.action")>

						<!---Query on qGetProductList to get computed values--->
						<cfquery name="qGetCompVals" dbtype="query">
							SELECT 	Proposed_Price,
									Quantity
							FROM 	qGetProductList
							WHERE 	Product_ID = '#BSA_Foodservice_Items_Master_ID#'
						</cfquery>

						<cfif qGetCompVals.RecordCount>

							<cfset "proposedPrice#itemCounter#" = qGetCompVals.Proposed_Price />
							<cfset "qty#itemCounter#" = qGetCompVals.Quantity />

						</cfif>

					<!---otherwise pull from form scope--->
					<cfelse>

						<!---get the totals for revenue and volume for calculations--->
						<cfscript>
							revTotal = oProduct.getFormRevTotl(Evaluate("#qGetItems.RecordCount#-1"));
							volTotal = oProduct.getFormVolTotl(Evaluate("#qGetItems.RecordCount#-1"),ValueList(qGetItems.net_weight));
						</cfscript>

						<!---Loop through the form field names to determine how many costs exists--->
						<cfloop index="index" list="#Form.FieldNames#">

							<!---find each planProduct field--->
							<cfset prodExists = ListContainsNoCase(index, "planProduct") />

							<cfif prodExists>
								<cfif Evaluate("#index#") eq BSA_Foodservice_Items_Master_ID>
									<cfset tmpIndx = Mid(index, 12, Len(index))/>
									<cfset "proposedPrice#itemCounter#" = Evaluate("form.proposedPrice#tmpIndx#") />
									<cfset "qty#itemCounter#" = Evaluate("form.qty#tmpIndx#") />

								</cfif>
							</cfif>

						</cfloop>

					</cfif>

				</cfif>

				<cfset Case_Cost = Curr_Cost * Net_Weight />
				<cfset volume = Evaluate("qty#itemCounter#") *  Net_Weight />
				<cfset totalCost = Evaluate("qty#itemCounter#") * Curr_Cost />
				<cfset revenue = Evaluate("qty#itemCounter#") * Evaluate("proposedPrice#itemCounter#") />
				<!---guard against division by zero--->
				<cfif revTotal neq 0>
					<cfset mixRev = (revenue / revTotal) * 100 />
				</cfif>
				<!---guard against division by zero--->
				<cfif volTotal neq 0>
					<cfset mixWgt = (volume / volTotal) * 100 />
				</cfif>

				<cfset extMarg = (Evaluate("proposedPrice#itemCounter#") - Curr_Cost) * Evaluate("qty#itemCounter#") />
				<!---guard against division by zero--->
				<cfif revenue neq 0>
					<cfset extMargPerc = (revenue - totalCost) / revenue * 100 />
				</cfif>

				<!---check to see if this product is in the forecast--->
				<cfif Form.forecast_id>
					<cfset forcstProdInfo = oForecast.checkProdForecast(BSA_Foodservice_Items_Master_ID,Evaluate("qty#itemCounter#"),qForecastProdData) />

				</cfif>
				<tr>
					<td nowrap>
						#Item#
					</td>
					<td nowrap>
						#Description#
					</td>
					<td align="right" nowrap>#LSNumberFormat(Case_Cost, "(_$,_.__)")#<INPUT NAME="caseCost#itemCounter#" TYPE="hidden" VALUE="#LSNumberFormat(Curr_Cost, "-_.__")#" /></td>
					<td align="right" nowrap>#LSNumberFormat(Net_Weight, "(,_.__)")#<INPUT NAME="caseNetWeight#itemCounter#" TYPE="hidden" VALUE="#Net_Weight#" /></td>
					<td align="right" nowrap>#LSNumberFormat(casePrice, "(_$,_.__)")#<INPUT NAME="priceList#itemCounter#" TYPE="hidden" VALUE="#casePrice#" /></td>
					<td align="right" nowrap>
						<!--- <cfif action eq "edit" or action eq "create"> --->
						<cfif ListFindNoCase("edit,copy,create", action)>
							<!--- <input type="text" size="6" maxlength="6" name="proposedPrice#itemCounter#" value="#Evaluate("proposedPrice#itemCounter#")#" onKeyUp="clenseText(this, '0123456789.');" onChange="calculate(#itemCounter#,#itemClassCounter#)" STYLE="text-align:right;" /> --->
							<input type="text" size="6" maxlength="12" name="proposedPrice#itemCounter#" value="#LSNumberFormat(Evaluate("proposedPrice#itemCounter#"),"(_.__)")#" onKeyUp="clenseText(this, '0123456789.');" onChange="calculate(#itemCounter#,#itemClassCounter#)" STYLE="text-align:right;" />
						<cfelse>
							#LSNumberFormat(Evaluate("proposedPrice#itemCounter#"), "(_$,_.__)")#
						</cfif>
					</td>
					<td align="right" nowrap>
						<!----if we have a forecast id then display status of current qty against volume forecast--->
						<cfif form.forecast_id>
							<cfif not forcstProdInfo.ProdExists>
								<font color="FF0000">(1)</font>
							</cfif>
							<span id="qtyFsctSts#itemCounter#">
							<!---only display qty status if this product lives in the forecast--->
							<cfif forcstProdInfo.prodExists>
								<font color="FF0000">
									<cfif not CompareNoCase(forcstProdInfo.qtyStatus, "isZero")>
										(3)
									<cfelseif not CompareNoCase(forcstProdInfo.qtyStatus, "notMatch")>
										(2)
									</cfif>
								</font>
							</cfif>
							</span>
						</cfif>
						<cfif ListFindNoCase("edit,copy,create", action)>
							<input type="text" name="qty#itemCounter#" value="#Evaluate("qty#itemCounter#")#" size="6" maxlength="6" onKeyUp="clenseText(this, '0123456789.');" onChange="calculate(#itemCounter#,#itemClassCounter#)" STYLE="text-align:right;" />
						<cfelse>
							#LSNumberFormat(Evaluate("qty#itemCounter#"), "(,_.__)")#
						</cfif>
					</td>
					<td align="right" nowrap><div id="freightWeightDiv#itemCounter#"><font color="#fontColor(volume)#">#LSNumberFormat(volume, "(,_.__)")#</font></div><input type="hidden" name="freightWeight#itemCounter#" value="#volume#"/></td>
					<td align="right" nowrap><div id="totalCostDiv#itemCounter#"><font color="#fontColor(totalCost)#">#LSNumberFormat(totalCost, "(_$,_.__)")#</font></div><input type="hidden" name="totalCost#itemCounter#"></td>
					<td align="right" nowrap><div id="revenueDiv#itemCounter#"><font color="#fontColor(revenue)#">#LSNumberFormat(revenue, "(_$,_.__)")#</font></div><input type="hidden" name="revenue#itemCounter#" value="#revenue#"></td>
					<td align="right" nowrap><div id="mixRevenueDiv#itemCounter#"><font color="#fontColor(mixRev)#">#LSNumberFormat(mixRev, "(,_.__)")#%</font></div><input type="hidden" name="mixRevenue#itemCounter#"></td>
					<td align="right" nowrap><div id="mixWeightDiv#itemCounter#"><font color="#fontColor(mixWgt)#">#LSNumberFormat(mixWgt, "(,_.__)")#%</font></div><input type="hidden" name="mixWeight#itemCounter#" /></td>
					<td align="right" nowrap><div id="marginDollDiv#itemCounter#"><font color="#fontColor(extMarg)#">#LSNumberFormat(extMarg, "(_$,_.__)")#</font></div><input type="hidden" name="marginDoll#itemCounter#" /></td>
					<td align="right" nowrap><div id="marginDiv#itemCounter#"><font color="#fontColor(extMargPerc)#">#LSNumberFormat(extMargPerc, "(,_.__)")#%</font></div><input type="hidden" name="margin#itemCounter#" /></td>
				</tr>

				<!---Add the unique counter to the item class list--->
				<cfset itemClassList = ListAppend(itemClassList, itemCounter) />

				<input type="hidden" name="planProduct#itemCounter#" value="#BSA_Foodservice_Items_Master_ID#" />


			<!--- 	<cfif CompareNoCase(action, "create")> --->
					<cfset "classQtyTotal#itemClassCounter#" = Evaluate("classQtyTotal#itemClassCounter#") + Evaluate("qty#itemCounter#") />
					<cfset "classVolumeTotal#itemClassCounter#" = Evaluate("classVolumeTotal#itemClassCounter#") + volume />
					<cfset "classTotalCostTotal#itemClassCounter#" = Evaluate("classTotalCostTotal#itemClassCounter#") + totalCost />
					<cfset "classTotalRevenue#itemClassCounter#" = Evaluate("classTotalRevenue#itemClassCounter#") + revenue />
					<!---guard against zeros--->
					<cfif revTotal neq 0>
						<cfset "classTotalMixRev#itemClassCounter#" =  (Evaluate("classTotalRevenue#itemClassCounter#") / revTotal) * 100/>
						<cfset "classTotalWgt#itemClassCounter#" =   (Evaluate("classVolumeTotal#itemClassCounter#") / volTotal) * 100 />
					</cfif>
					<cfset "classTotalMargDoll#itemClassCounter#" = Evaluate("classTotalMargDoll#itemClassCounter#") + extMarg />
				<!--- </cfif> --->

				<cfset itemCounter =  itemCounter + 1 />

				<!---reset values--->
				<cfset "proposedPrice#itemCounter#" = 0 />
				<cfset "qty#itemCounter#" = 0 />
				<cfset volume = "" />
				<cfset totalCost = "" />
				<cfset revenue = "" />
				<cfset mixRev = "" />
				<cfset mixWgt = "" />
				<cfset extMarg = "" />
				<cfset extMargPerc = "" />

			</cfif>

		</cfloop>

		<!---Holds a list of pointers to items--->
		<INPUT NAME="classItemTotal#itemClassCounter#" TYPE="Hidden" VALUE="#itemClassList#" />

			<!---set totals--->
			<cfset qtyTotal = qtyTotal + Evaluate("classQtyTotal#itemClassCounter#") />
			<cfset volumeTotal = volumeTotal +  Evaluate("classVolumeTotal#itemClassCounter#") />
			<cfset totalCostTotal = totalCostTotal +  Evaluate("classTotalCostTotal#itemClassCounter#")/>
			<cfset totalRevenue = totalRevenue +  Evaluate("classTotalRevenue#itemClassCounter#") />
			<cfset totalMixRev = totalMixRev +  Evaluate("classTotalMixRev#itemClassCounter#" ) />
			<cfset totalWgt = totalWgt +  Evaluate("classTotalWgt#itemClassCounter#") />
			<cfset totalMargDoll = totalMargDoll +  Evaluate("classTotalMargDoll#itemClassCounter#") />
			<!--guard against dividing by zero--->
			<cfif totalRevenue eq 0>
				<cfset totalMargPercent = 0 />
			<cfelse>
				<cfset totalMargPercent = (totalRevenue - totalCostTotal) / totalRevenue * 100 />
			</cfif>

		<!--- </cfif> --->

		<cfset itemClassCounter =  itemClassCounter + 1 />

	</cfloop>

<!---
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////Item Class Section////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--->
	<tr class="tableHeader">
		<td colspan="100%"><b>#application.returned_customer_setting.type_group_label_singular# Summary</b></td>
	</tr>
	<tr><td rowspan="#Evaluate(qGetItemTypes.RecordCount + 2)#">&nbsp;</td></tr>
	<cfset itemClassCounter = 0 />
	<cfset totalList = "" />
	<!---set an array to hold item class data--->
	<cfset aItmClass=arrayNew(2)>
	<cfloop query="qGetItemTypes">

		<!--- <cfif CompareNoCase(action, "create")> --->
			<cfset classQtyTotal = Evaluate("classQtyTotal#itemClassCounter#") />
			<cfset classVolumeTotal = Evaluate("classVolumeTotal#itemClassCounter#") />
			<cfset classTotalCostTotal = Evaluate("classTotalCostTotal#itemClassCounter#") />
			<cfset classTotalRevenue = Evaluate("classTotalRevenue#itemClassCounter#") />
			<cfset classTotalMixRev = Evaluate("classTotalMixRev#itemClassCounter#") />
			<cfset classTotalWgt = Evaluate("classTotalWgt#itemClassCounter#") />
			<cfset classTotalMargDoll = Evaluate("classTotalMargDoll#itemClassCounter#")  />
			<cfif classTotalRevenue neq 0>
				<cfset classTotalMargPercent = ((classTotalRevenue - classTotalCostTotal) / classTotalRevenue) * 100 />
			<cfelse>
				<cfset classTotalMargPercent = 0 />
			</cfif>

			<cfset aItmClass[CurrentRow][1] = classTotalRevenue />
			<cfset aItmClass[CurrentRow][2] = classVolumeTotal />
			<cfset aItmClass[CurrentRow][3] = classTotalCostTotal />

	<!--- 	</cfif> --->
		<tr>
			<td colspan="6"><b><font color="##00CC00">[#Evaluate(itemClassCounter +1)#]</font></b>&nbsp;#Type_Group_Desc#</td>
			<td align="right" nowrap><div id="qtyItemClassTotalDiv#itemClassCounter#"><font color="#fontColor(classQtyTotal)#">#LSNumberFormat(classQtyTotal, "(,_.__)")#</font></div><input type="hidden" name="qtyItemClassTotal#itemClassCounter#" value="#classQtyTotal#"/></td>
			<td align="right" nowrap><div id="freightWeightItemClassTotalDiv#itemClassCounter#"><font color="#fontColor(classVolumeTotal)#">#LSNumberFormat(classVolumeTotal, "(,_.__)")#</font></div><input type="hidden" name="freightWeightItemClassTotal#itemClassCounter#" value="#classVolumeTotal#"/></td>
			<td align="right" nowrap><div id="totalCostItemClassTotalDiv#itemClassCounter#"><font color="#fontColor(classTotalCostTotal)#">#LSNumberFormat(classTotalCostTotal, "(_$,_.__)")#</font></div><input type="hidden" name="totalCostItemClassTotal#itemClassCounter#" value="#classTotalCostTotal#"/></td>
			<td align="right" nowrap><div id="revenueItemClassTotalDiv#itemClassCounter#"><font color="#fontColor(classTotalRevenue)#">#LSNumberFormat(classTotalRevenue, "(_$,_.__)")#</font></div><input type="hidden" name="revenueItemClassTotal#itemClassCounter#" value="#classTotalRevenue#"/></td>
			<td align="right" nowrap><div id="mixRevenueItemClassTotalDiv#itemClassCounter#"><font color="#fontColor(classTotalMixRev)#">#LSNumberFormat(classTotalMixRev, "(,_.__)")#%</font></div><input type="hidden" name="mixRevenueItemClassTotal#itemClassCounter#" value="#classTotalMixRev#"/></td>
			<td align="right" nowrap><div id="mixWeightItemClassTotalDiv#itemClassCounter#"><font color="#fontColor(classTotalWgt)#">#LSNumberFormat(classTotalWgt, "(,_.__)")#%</font></div><input type="hidden" name="mixWeightItemClassTotal#itemClassCounter#" value="#classTotalWgt#"/></td>
			<td align="right" nowrap><div id="marginDollItemClassTotalDiv#itemClassCounter#"><font color="#fontColor(classTotalMargDoll)#">#LSNumberFormat(classTotalMargDoll, "(_$,_.__)")#</font></div><input type="hidden" name="marginDollItemClassTotal#itemClassCounter#" value="#classTotalMargDoll#" /></td>
			<td align="right" nowrap><div id="marginItemClassTotalDiv#itemClassCounter#"><font color="#fontColor(classTotalMargPercent)#">#LSNumberFormat(classTotalMargPercent, "(,_.__)")#%</font></div><input type="hidden" name="marginItemClassTotal#itemClassCounter#" value="#classTotalMargPercent#" /></td>
		</tr>
		<cfset totalList = ListAppend(totalList, itemClassCounter) />
		<cfset itemClassCounter =  itemClassCounter + 1 />
	</cfloop>
		<tr BGCOLOR="CCCCFF">
			<td colspan="6"><b>Total:</b></td>
			<td align="right" nowrap><B><div id="qtyItemTotalDiv"><font color="#fontColor(qtyTotal)#">#LSNumberFormat(qtyTotal, "(,_.__)")#</font></div><input type="hidden" name="qtyItemTotal" value="#qtyTotal#"/></B></td>
			<td align="right" nowrap><B><div id="freightWeightItemTotalDiv"><font color="#fontColor(volumeTotal)#">#LSNumberFormat(volumeTotal, "(,_.__)")#</font></div><input type="hidden" name="freightWeightItemTotal" value="#volumeTotal#" /></B></td>
			<td align="right" nowrap><B><div id="totalCostItemTotalDiv"><font color="#fontColor(totalCostTotal)#">#LSNumberFormat(totalCostTotal, "(_$,_.__)")#</font></div><input type="hidden" name="totalCostItemTotal" value="#totalCostTotal#" /></B></td>
			<td align="right" nowrap><B><div id="revenueItemTotalDiv"><font color="#fontColor(totalRevenue)#">#LSNumberFormat(totalRevenue, "(_$,_.__)")#</font></div><input type="hidden" name="revenueItemTotal" value="#totalRevenue#" /></B></td>
			<td align="right" nowrap><B><div id="mixRevenueItemTotalDiv"><font color="#fontColor(totalMixRev)#">#LSNumberFormat(totalMixRev, "(,_.__)")#%</font></div><input type="hidden" name="mixRevenueItemTotal" value="#totalMixRev#" /></B></td>
			<td align="right" nowrap><B><div id="mixWeightItemTotalDiv"><font color="#fontColor(totalWgt)#">#LSNumberFormat(totalWgt, "(,_.__)")#%</font></div><input type="hidden" name="mixWeightItemTotal" value="#totalWgt#" /></B></td>
			<td align="right" nowrap><B><div id="marginDollItemTotalDiv"><font color="#fontColor(totalMargDoll)#">#LSNumberFormat(totalMargDoll, "(_$,_.__)")#</font></div><input type="hidden" name="marginDollItemTotal" value="#totalMargDoll#" /></B></td>
			<td align="right" nowrap><B><div id="marginItemTotalDiv"><font color="#fontColor(totalMargPercent)#">#LSNumberFormat(totalMargPercent, "(,_.__)")#%</font></div><input type="hidden" name="marginItemTotal" value="#totalMargPercent#" /></B></td>
		</tr>
	</table>

	<!---Holds a list of pointers to item classes--->
	<INPUT NAME="itemTotal" TYPE="Hidden" VALUE="#totalList#" />
	<br>

<DIV CLASS="BreakHere">

<!---
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////Costs Section////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--->
	<table WIDTH="90%" align="center" id="enterTable" border="0" cellspacing="0" cellpadding="2">
		<tr class="thickSec">
			<td colspan="20">
				<font color="red" size="+1"><b>Costs</b></font>
			</td>
		</tr>
		<tr><td rowspan="100"></td></tr>
		<!---Program Incentive Costs--->
		<tr class="thinBottom" id="incentiveHeader">
			<td><b>Program Incentive Costs</b></td>
			<cfloop query="qGetItemTypes"><td align="right" title="#Type_Group_Desc#" STYLE="cursor: help;" NOWRAP><b><font color="##00CC00">[#Evaluate(CurrentRow)#]</font></b></td></cfloop>
			<td align="right"><b>Total</b></td>
		</tr>

		<cfset aGrandCostTot = arrayNew(1) />

		<!---EDIT MODE: PRINT MODE:--->

<!---
//////////////////////////////////////////////////Edit, Display Mode Section////////////////////////////////////////////////////
---->
			<!---incentive costs--->
			<cf_costs_section
				CostType="1"
				qItemTypes="#qGetItemTypes#"
				aItmClass="#aItmClass#"
				totalList="#totalList#"
				aGrandCostTot="#aGrandCostTot#"
				rReturnGrndTotlArray="grndTotlArrayCost1"
				rCostGrndTotl="incCostGrndTotl"
				action="#action#"
				name="incentive"
			>


			<!---misc costs--->
			<tr class="thinBottom" id="incentiveHeader">
				<td colspan="#Evaluate(qGetItemTypes.RecordCount + 2)#"><b>Miscellaneous Costs</b></td>
			</tr>

			<cf_costs_section
				CostType="2"
				qItemTypes="#qGetItemTypes#"
				aItmClass="#aItmClass#"
				totalList="#totalList#"
				aGrandCostTot="#grndTotlArrayCost1#"
				rReturnGrndTotlArray="grndTotlArrayCost2"
				rCostGrndTotl="miscCostGrndTotl"
				action="#action#"
				name="misc"
			>

			<!---lump sum costs--->
			<tr class="thinBottom" id="incentiveHeader">
				<td colspan="#Evaluate(qGetItemTypes.RecordCount + 2)#"><b>#Application.LumpsumLabel# Costs</b></td>
			</tr>

			<cf_costs_section
				CostType="3"
				qItemTypes="#qGetItemTypes#"
				aItmClass="#aItmClass#"
				totalList="#totalList#"
				aGrandCostTot="#grndTotlArrayCost2#"
				rReturnGrndTotlArray="grndTotlArray"
				rCostGrndTotl="lumpSumCostGrndTotl"
				action="#action#"
				name="lumpSum"
			>

		<!---set the grand cost total amount--->
		<cfset grandCostTotl = incCostGrndTotl + miscCostGrndTotl + lumpSumCostGrndTotl/>

		<!---
		<cfelse>
<!---
/////////////////////////////////////////////////////Create Mode Section////////////////////////////////////////////////////////////
---->
			<!---incentive costs--->
			<cf_costs_section
				totalList="#totalList#"
				action="#action#"
				name="incentive"
			>

			<!---misc costs--->
			<tr class="thinBottom" id="incentiveHeader">
				<td colspan="#Evaluate(qGetItemTypes.RecordCount + 2)#"><b>Miscellaneous Costs</b></td>
			</tr>

			<cf_costs_section
				totalList="#totalList#"
				action="#action#"
				name="misc"
			>

			<!---lump sum costs--->
			<tr class="thinBottom" id="incentiveHeader">
				<td colspan="#Evaluate(qGetItemTypes.RecordCount + 2)#"><b>Lump Sum Costs</b></td>
			</tr>

			<cf_costs_section
				totalList="#totalList#"
				action="#action#"
				name="lumpSum"
			>

	</cfif>
	--->
<!------------------------------------------------------Grand Total-------------------------------------------------------------------->

		<tr id="grndTotRow" BGCOLOR="CCCCFF">
			<td><b>Total Costs</b></td>
				<cfloop index="x" list="#totalList#">

				<td align="right">
					<div style="display:inline;" id="classCostTotalDiv#x#"><cfif isDefined("grndTotlArray") and ArrayLen(grndTotlArray)><font color="#fontColor(grndTotlArray[x+1])#">#LSNumberFormat(grndTotlArray[x+1], "(_$,_.__)")#</font></cfif></div>
					<input type="hidden" name="classCostTotal#x#" />
					<!--- <cfif action eq "edit" or action eq "create_calculate"> --->
					<cfif ListFindNoCase("edit,copy,create", action)>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</cfif>
				</td>
				</cfloop>
			<td align="right" valign="top">
				<div style="display:inline;" id="costTotalDiv"><font color="#fontColor(grandCostTotl)#">#LSNumberFormat(grandCostTotl, "(_$,_.__)")#</font></div>
				<input type="hidden" name="costTotal" value="#grandCostTotl#"/>
			</td>
		</tr>
	</table>
	<br>

<!---
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////Profit Analysis Section//////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--->
	<table WIDTH="90%" align="center" border="0" cellspacing="0" cellpadding="0">
		<tr class="thickSec">
			<td colspan="20">
				<font color="red" size="+1"><b>Profit Analysis</b></font>&nbsp;&nbsp;
				<!--- <cfif action eq "edit" or action eq "create_calculate"> --->
				<cfif ListFindNoCase("edit,copy,create", action)>
					<FONT SIZE="2"><B><FONT COLOR="FF0000">[</FONT><a href="" onClick="javascript: return calcAnalysis();"> calculate </a><FONT COLOR="FF0000">]</FONT></B></FONT>
				</cfif>
			</td>
		</tr>
		<tr><td rowspan="100"></td></tr>
		<tr>
			<td>
				<table border="0" cellspacing="0" cellpadding="2">
					<tr>
						<td>Program Incentive Costs:</td>
						<td nowrap>
							<div id="incentiveCostTotalPrftDiv"><font color="#fontColor(incCostGrndTotl)#">#LSNumberFormat(incCostGrndTotl, "(_$,_.__)")#</font></div>
							<input type="hidden" name="incentiveCostTotalPrft"/>
						</td>
						<td><b>(PIC)</b></td>
					</tr>
					<tr>
						<td>Miscellaneous Costs:</td>
						<td nowrap>
							<div id="miscCostTotalPrftDiv"><font color="#fontColor(miscCostGrndTotl)#">#LSNumberFormat(miscCostGrndTotl, "(_$,_.__)")#</font></div>
							<input type="hidden" name="miscCostTotalPrft"/>
						</td>
						<td><b>(MIC)</b></td>
					</tr>
					<tr>
						<td>#Application.LumpsumLabel# Costs:</td>
						<td nowrap>
							<div id="lumpSumCostTotalPrftDiv"><font color="#fontColor(lumpSumCostGrndTotl)#">#LSNumberFormat(lumpSumCostGrndTotl, "(_$,_.__)")#</font></div>
							<input type="hidden" name="lumpSumCostTotalPrft"/>
						</td>
						<td><b>(LSC)</b></td>
					</tr>

					<cfset counter = 0 />
					<cfloop query="qGetItemTypes">

						<!--- <cfif action neq "create_calculate"> --->
						<cfif CompareNoCase(action, "create")>
							<cfif (aItmClass[counter+1][1] - grndTotlArray[counter+1])>
								<cfset netMargVal = (aItmClass[counter+1][1] - grndTotlArray[counter+1] - aItmClass[counter+1][3]) / (aItmClass[counter+1][1] - grndTotlArray[counter+1]) * 100 />
							</cfif>
						</cfif>


					<tr>
						<td>#Type_Group_Desc#:</td>
						<td nowrap>
							<div style="display:inline;" id="netMarginDiv#counter#"><font color="#fontColor(netMargVal)#">#LSNumberFormat(netMargVal, "(,_.__)")#%</font></div>
							<input type="hidden" name="netMargin#counter#"/>
						</td>
					</tr>

					<cfset netMargVal = 0 />
					<cfset counter = counter + 1 />

				</cfloop>

				<!--- <cfif action neq "create_calculate"> --->
				<cfif CompareNoCase(action, "create")>
					<cfset totlNetProfit = totalRevenue - (totalCostTotal + incCostGrndTotl + miscCostGrndTotl + lumpSumCostGrndTotl) />
					<!---guard against division by zero--->
					<cfif totalRevenue eq 0>
						<cfset totlNetMargin = 0 />
					<cfelse>
						<cfset totlNetMargin = (totlNetProfit / totalRevenue) * 100 />
					</cfif>

				</cfif>

				<cfif totlNetProfit gte 0 or compareNoCase(trim(totlNetProfit), "") eq 0>
					<cfset clsSuf = "Grn" />
				<cfelse>
					<cfset clsSuf = "Red" />
				</cfif>

					<tr>
						<td id="netMargLblId" class="netMargLblCls#clsSuf#"><font size="2"><b>Total Net Margin:</b></font></td>
						<td id="netMargValId" class="netMargValCls#clsSuf#" nowrap>
							<div style="font-weight:bold;font-size:12px;text-align:right;display:inline;" id="netMargTotlDiv"><font color="#fontColor(totlNetMargin)#">#LSNumberFormat(totlNetMargin, "(,_.__)")#%</font></div>
							<input type="hidden" name="netMargTotl" value="#totlNetMargin#"/>
						</td>
					</tr>
					<tr>
						<td id="netProfLblId" class="netProfLblCls#clsSuf#"><font size="2"><b>Total Net Profit:</b></font></td>
						<td id="netProfValId" class="netProfValCls#clsSuf#" nowrap>
							<div style="font-weight:bold;font-size:12px;text-align:right;display:inline;" id="totlNetProfitDiv"><font color="#fontColor(totlNetProfit)#">#LSNumberFormat(totlNetProfit, "(_$,_.__)")#</font></div>
							<input type="hidden" name="totlNetProfit" value="#totlNetProfit#"/>
						</td>
					</tr>
				</table>
			</td>
			<!---show the what if calculator only when in edit mode--->
			<cfif ListFindNoCase("edit,copy,create", action)>
			<td valign="top">
				<table border="0" cellpadding="2" cellspacing="0" width="400">
					<tr>
						<td colspan="5">What if my
						<select name="targType">
							<option value="wiNetMarg">Net Margin</option>
							<option value="wiNetProf">Net Profit</option>
							<option value="wiTotlCost">Total Cost</option>
						</select>
						was
						<input name="wi_target" type="text" size="2" onKeyUp="clenseText(this, '0123456789.');">&nbsp;?&nbsp;&nbsp;<FONT SIZE="2"><B><FONT COLOR="FF0000">[</FONT><a href="" onClick="javascript: return calcTarget();"> calculate </a><FONT COLOR="FF0000">]</FONT></B></FONT>
						<br>
						</td>
					</tr>
					<tr>
						<td bgcolor="CCCCFF" class="bd">&nbsp;</td>
						<td bgcolor="CCCCFF" class="bdBotRgtTop"><b>C</b>urrent</td>
						<td bgcolor="CCCCFF" class="bdBotRgtTop"><b>P</b>roposed</td>
						<td bgcolor="CCCCFF" class="bdBotRgtTop"><b>P</b> - <b>C</b></td>
					</tr>
					<tr>
						<td class="bdBotRgtLft">Net Margin %</td>
						<td class="bdBotRgt"><div style="display:inline;" id="netMargTotlWIDiv"><font color="#fontColor(totlNetMargin)#">#LSNumberFormat(totlNetMargin, "(,_.__)")#%</font></div></td>
						<td class="bdBotRgt"><div style="display:inline;" id="propNetMargTotlDiv">&nbsp;</div></td>
						<td class="bdBotRgt"><div style="display:inline;" id="netMargDiffDiv">&nbsp;</div></td>
					</tr>
					<tr>
						<td class="bdBotRgtLft">Net Profit $</td>
						<td class="bdBotRgt"><div style="display:inline;" id="totlNetProfitWIDiv"><font color="#fontColor(totlNetProfit)#">#LSNumberFormat(totlNetProfit, "(_$,_.__)")#</font></div></td>
						<td class="bdBotRgt"><div style="display:inline;" id="propTotlNetProfitDiv">&nbsp;</div></td>
						<td class="bdBotRgt"><div style="display:inline;" id="netProfDiffDiv">&nbsp;</div></td>
					</tr>
					<tr>
						<td class="bdBotRgtLft">Total Costs</td>
						<td class="bdBotRgt"><div style="display:inline;" id="costTotalWIDiv"><sup><font color="FF0000">1</font></sup><font color="#fontColor(grandCostTotl)#">#LSNumberFormat(grandCostTotl, "(_$,_.__)")#</font></div></td>
						<td class="bdBotRgt" valign="bottom"><div style="display:inline;" id="propCostTotalDiv">&nbsp;</div></td>
						<td class="bdBotRgt" valign="bottom"><div style="display:inline;" id="costTotlDiffDiv">&nbsp;</div></td>
					</tr>
					<tr>
						<td>
							<br>
							<font color="FF0000"><sup>1</sup></font> Total Costs Current = <b>PIC</b> + <b>MIC</b> + <b>LSC</b>
						</td>
					</tr>
				</table>
			</td>
		</cfif>
		</tr>
	</table>
<cfelse>
<tr><td><br>No Products Selected<br><br></td></tr>
</table>
</cfif>

<input type="hidden" name="typeGroupList" value="#lTypeGroupList#" />
<cfif isdefined("qGetItems")>
<input type="hidden" name="prodCount" value="#qGetItems.RecordCount#" />
</cfif>

<INPUT NAME="action" TYPE="Hidden" VALUE="#actionState#" />
<input name="createdBy" type="hidden" value="#createdBy#"/>
<input name="Trade_Plan_ID" type="hidden" value="#Trade_Plan_ID#"/>
<INPUT NAME="Product_List" TYPE="Hidden" VALUE="#Product_List#" />
<INPUT NAME="ExistingProductList" TYPE="Hidden" VALUE="#Product_List#" />
<INPUT NAME="Distributor_List" TYPE="Hidden" VALUE="#Distributor_List#" />
<INPUT NAME="forecast_id" TYPE="Hidden" VALUE="#form.forecast_id#" />
<!---only use hidden if not in edit mode--->
<cfif ListFindNoCase(action, "edit,copy,create")>
	<INPUT TYPE="Hidden" NAME="start_date" VALUE="#form.start_date#" />
	<INPUT TYPE="Hidden" NAME="end_date" VALUE="#form.end_date#" />
</cfif>

<cfif ListFindNoCase("edit,copy,display,create", action)>
<table width="90%" align="center">
	<tr>
		<td>
		<!---
		<FONT SIZE="2">
			<B><FONT COLOR="FF0000">[</FONT><a href="javascript:validate('#actionValue#','#trade_plan_id#')"> #actionLabel# </a><FONT COLOR="FF0000">]</FONT></B>
		</FONT>

		<cfif not CompareNoCase(action, "display")>
		<FONT SIZE="2">
			<B><FONT COLOR="FF0000">[</FONT><a href="javascript:validate('delete','#trade_plan_id#')"> delete </a><FONT COLOR="FF0000">]</FONT></B>
		</FONT>
		</cfif>
		<!--- <cfif action eq "edit"> --->
		<cfif not CompareNoCase(action, "edit")>
		<FONT SIZE="2">
			<B><FONT COLOR="FF0000">[</FONT><a href="javascript:validate('display','#trade_plan_id#')"> cancel </a><FONT COLOR="FF0000">]</FONT></B>
		</FONT>
		</cfif>
		--->
		<cfif ListFindNoCase("display",action)>
		<FONT SIZE="2">
			<B><FONT COLOR="FF0000">[</FONT><a href="javascript:validate('edit','#trade_plan_id#')"> edit </a><FONT COLOR="FF0000">]</FONT></B>
		</FONT>
		<FONT SIZE="2">
			<B><FONT COLOR="FF0000">[</FONT><a href="javascript:validate('copy','#trade_plan_id#')"> copy </a><FONT COLOR="FF0000">]</FONT></B>
		</FONT>
		</cfif>

		<cfif   ListFindNoCase("copy,create",action)>
		<FONT SIZE="2">
			<B><FONT COLOR="FF0000">[</FONT><a href="javascript:validate('save')">save</a><FONT COLOR="FF0000">]</FONT></B>
		</FONT>
		</cfif>

		<cfif  not CompareNoCase(action,"edit")>
		<FONT SIZE="2">
			<B><FONT COLOR="FF0000">[</FONT><a href="javascript:validate('update')">update</a><FONT COLOR="FF0000">]</FONT></B>
		</FONT>
		</cfif>

		<cfif not CompareNoCase(action, "display")>
		<FONT SIZE="2">
			<B><FONT COLOR="FF0000">[</FONT><a href="javascript:validate('delete','#trade_plan_id#')"> delete </a><FONT COLOR="FF0000">]</FONT></B>
		</FONT>
		</cfif>
		<cfif ListFindNoCase("edit,copy",action)>
		<FONT SIZE="2">
			<B><FONT COLOR="FF0000">[</FONT><a href="javascript:validate('display','#trade_plan_id#')"> cancel </a><FONT COLOR="FF0000">]</FONT></B>
		</FONT>
		</cfif>
		<!---Gets application settings--->
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>

		<cfset userManager = CreateObject("component", "components.user.UserManager") />
		<!--- <cfif action eq "display"> --->
		<cfif not CompareNoCase(action, "display") AND Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 1 AND (appSettings.getUserNumberRestrict() EQ 0 OR userManager.getUserNumberExists(request.AccessStructure.User_ID) EQ 1)>
		<FONT SIZE="2">
			<B><FONT COLOR="FF0000">[</FONT><a href="javascript:validate('createWIP','#trade_plan_id#')"> create WIP </a><FONT COLOR="FF0000">]</FONT></B>
		</FONT>
		</cfif>
		</td>
	</tr>
</table>
</cfif>
</form>

<cfif not CompareNoCase(action, "display")>
<table>
	<tr>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"print"
				button_action	=	"NewWindow('trade_plan_calc.cfm?action=print&Trade_Plan_ID=#Trade_Plan_ID#','name','800','600','Yes', 'No')"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	"Print page"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</TD>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"email"
				button_action	=	"window.location.href='index.cfm?action=email&Trade_Plan_ID=#Trade_Plan_ID#'"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	"Prepare an email contents"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</TD>
	<!--- DEV NOTE: DAA; D15409    REMOVE FAX LINK
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"fax"
				button_action	=	"window.location.href='index.cfm?action=fax&Trade_Plan_ID=#Trade_Plan_ID#'"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	"Prepare the contents of a fax to be sent"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</TD>
	 --->
	</tr>
</table>
</cfif>
<br>

<!---add start date and end date functions if we have a forecast and we are in edit or create mode--->
<cfif ListFindNoCase("edit,copy,create", action) and form.forecast_id>

	<script>

		var forecastId = document.marginForm.forecast_id.value;

		document.marginForm.start_date.onchange = new Function("checkForcstDate()");
		document.marginForm.end_date.onchange = new Function("checkForcstDate()");
		document.marginForm.start_date.onpropertychange = new Function("checkForcstDate()");
		document.marginForm.end_date.onpropertychange = new Function("checkForcstDate()");

	</script>

</cfif>
</cfoutput>
