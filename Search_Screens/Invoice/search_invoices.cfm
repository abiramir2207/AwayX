<cfsilent>
<!---
/search_screens/invoice/search_invoices.cfm
Brenda Flynn
July 10, 2003

--->

<!---Sends them home if they're not allowed to use this --->
<!--- <CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFIF Get_Profile_Settings.View_Invoices EQ 0>
	<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
</CFIF> --->

<!------ Get application settings ----->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset DistGroupDataManager = CreateObject("component", "components.customer.Group.DataManager").init() />
<cfset qGetDistributorLevels = DistGroupDataManager.getDistributorLevels(bActive=1) />
<!--------------------------------------------------------
Start Search Form
--------------------------------------------------------->

<CFSET Date_Operators=" ,Greater_Or_Equal,Equal,Less_Or_Equal">
<CFSET Date_Operator_Symbols=" ,>=,=,<=">


<CFSET PAGE_TITLE="Invoice Search">
<CFSET GROUP="Deployment">

<CFPARAM NAME="startrow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<CFPARAM NAME="searchstring" DEFAULT="">
<CFPARAM NAME="ship_to" default="">
<CFPARAM NAME="DoSearch" DEFAULT="0">
<CFPARAM NAME="invoicenumber" DEFAULT="">
<CFPARAM NAME="datetype" DEFAULT="invoice">
<CFPARAM NAME="dollarvalue" default="">
<CFPARAM NAME="form.dollarvalue" default="">
<CFPARAM NAME="invoicedate" DEFAULT="">
<CFPARAM NAME="InvoiceDate_Operator" Default=">=">
<CFPARAM NAME="FORM.AlreadySelectedItems" DEFAULT="">
<CFPARAM NAME="sort_by" DEFAULT="Invoice_Header.Invoice_Date">
<CFPARAM NAME="sort_order" DEFAULT="DESC">
<CFPARAM NAME="dollarvalue" default="">
<cfparam name="CustomerPO" default="">
<cfparam name="form.CustomerPO" default="">
<cfparam name="form.orderNumber" default="">

<cfset defaultdate = "1/1/" & datepart('yyyy', now())>
<cfif invoicedate IS "">
	<cfset invoicedate = defaultdate>
</cfif>
<cf_Number_of_Rows maxrows=18>
<cfscript>
	variables.busSegObject = createObject("component", "components.programs.business_segment.BusinessSegmentManager");
	variables.busSegmentForDistributors = variables.busSegObject.isEnabledForDistributor();

	variables.labelsObject = createObject("component", "components.settings.labels.labels").init();
	variables.orderNumberLabel = variables.labelsObject.GetGeneralLabels(labelDescription = "Order Number");
</cfscript>
</cfsilent>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<!--- <LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css"> --->
	<link rel="stylesheet" href="/styles/jQueryUI_18/smoothness/jquery-ui-1.8.22.custom.css" type="text/css" />
	<STYLE>
		div#msg55 { font-size: 1.15em; letter-spacing:0.9px; }
		div#msg55 p { font-size: 1.35em; margin:20px; padding:20px; background-color: #BDE5F8; letter-spacing:0.9px; }
		table#invoiceSearch { width: 96%; margin:0 2%; }
		table#invoiceSearch tr { height2: 17px; }
		table#invoiceSearch td { padding:1px 1%; }
		table#invoiceSearch select, table#invoiceSearch input { width:96%; margin:3px 0 6px 0; }
		.criteria { font-weight: bold; letter-spacing: 1.1px; font-size: 1.1em; display:inline-block; padding-right: 13px; }
		.label { font-weight: bold; }
		TABLE.Maintable TD { border-bottom:solid #93BEE2 1px; font-size : 10px; }
		#header	{font-size: 12px;}
		#actions { margin:5px 5% 5px 5%; }
		#actions a { margin-right: 25px; }
	</STYLE>
	<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
		<SCRIPT>
		function sortByThisItem(thisObj, thisSortItem, thisSortOrder)
		{ 	isSearching = 1;
			var formObj;
			formObj = document.all.searchinvoices;
			formObj.sort_by.value = thisSortItem;
			formObj.sort_Order.value = thisSortOrder;
			if(formObj.frompage.value.length == 0)	formObj.frompage.value = 1;
			if(formObj.startrow.value.length == 0)	formObj.startrow.value = 1;
			formObj.submit();
			return false;
		}

		function reset_form() {
			$("select").val(0);
			$("select[name=datetype]").val("invoice");
			$("select[name=invoicedate_operator]").val(">=");
			$("input[type!=hidden]").val("");
			<cfoutput>$("input[name=invoicedate]").val("#dateFormat(defaultdate,'m/d/yyyy')#");</cfoutput>
			$("fieldset[name=result]").hide();
		}

		function isDefined(item) {
    		return (typeof item != 'undefined');
		}

</SCRIPT>
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<div id="msg55"></div>    <!--- reserve this div for displaying message in long process (e.g. saving changes) --->
<cfoutput>
<SCRIPT LANGUAGE="JavaScript">
function hide_PleaseWaitMessage()
{
 document.all.PleaseWaitMessage.style.display='none';
}
//hide_PleaseWaitMessage();
function submitForm( it )
{
	var oForm = document.searchinvoices;
	var ErrorCount = 0;

	<!------ Broker search filter is a must ----->
	<cfif appSettings.getInvoiceBrokerFilterRestrict()>
	if(oForm.Broker)
	{
		if(oForm.Broker.selectedIndex == 0)
		{
			ErrorCount++;
			queueMessage("You must select a #application.returned_customer_setting.broker_label_singular#", document.all.Err_Broker);
		}
		else
		{
			clearQueue(document.all.Err_Broker);
		}
	}
	</cfif>


	if(ErrorCount)
	{
		showMessageWindow();
	}
	else
	{
		$("form[name=searchinvoices]").hide();
		$("##msg55").append("<p>Gathering invoices, please wait...</p>");
		oForm.submit();
	}
}
</script>
</cfoutput>
<blockquote>
<cfscript>
function isNextRow(maxCols, currCols)
{
	if(currCols LTE 1)
	{
		return 0;
	}
	else
	{
		return (not(currCols) mod maxCols);
	}
}
</cfscript>
<cfset maxColsPerRow = 4/>
<cfset currentColCount = 0/>

	<FORM ACTION="search_invoices.cfm" METHOD="post" NAME="searchinvoices" ID="searchinvoices">
	<cfinclude template="/helpsystem/help_link2.cfm">
	<FIELDSET STYLE="border:1px solid Blue; width:100%;">

	    <cfoutput><LEGEND STYLE="font: bold 14px sans-serif; color: Red;">invoice search</LEGEND></cfoutput>
			<TABLE border="0" cellpadding="0" cellspacing="0" id="invoiceSearch">
			<tr>
				<td rowspan="3" valign="center"> <span class="criteria"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput><br> Criteria</span></td>
				<CFPARAM NAME="FORM.Family_Name" DEFAULT="0">
				<cfif DistGroupDataManager.getDistributorLevelSearchFilterOn(qGetDistributorLevels, 2)>
					<TD COLSPAN="1"><!--- Family Name --->
						<span class="label" ID="searchItemLabel"><cfoutput>#application.returned_customer_setting.Family_Name_Label_Singular#</cfoutput>:</span><BR>
						<cfquery name="GetFamilyNames" Datasource="#application.datasource#">
							SELECT *
							FROM Distributor_Family
							WHERE Deleted = 0
							ORDER BY Family_Name
						</cfquery>
						<SELECT NAME="Family_Name">
							<OPTION VALUE="0">**ALL** <cfoutput>#application.returned_customer_setting.Family_Name_Label_Plural#</cfoutput></OPTION>
							<CFOUTPUT QUERY="GetFamilyNames"><OPTION VALUE="#trim(GetFamilyNames.Family_ID)#"#IIF(trim(FORM.Family_Name) EQ trim(GetFamilyNames.Family_ID), DE(" SELECTED"), DE(""))#>#trim(GetFamilyNames.Family_Name)#</OPTION></CFOUTPUT>
						</SELECT>
					</TD>
					<cfset currentColCount = currentColCount + 1 />
					<cfif isNextRow(maxColsPerRow, currentColCount)></TR><TR></cfif>
				</cfif>
				<CFPARAM NAME="FORM.Buying_Group" DEFAULT="0">
				<cfif DistGroupDataManager.getDistributorLevelSearchFilterOn(qGetDistributorLevels, 3)>
					<TD><!--- Buying Groups --->
						<span class="label" ID="searchItemLabel"><cfoutput>#application.returned_customer_setting.Buying_Group_Label_Singular#</cfoutput>:</span><BR>
						<cfquery name="GetBuyingGroups" Datasource="#application.datasource#">
							SELECT *
							FROM Distributor_Buying_Groups
							WHERE Deleted = 0
							ORDER BY Buying_Group_Name
						</cfquery>
						<SELECT NAME="Buying_Group">
							<OPTION VALUE="0">**ALL** <cfoutput>#application.returned_customer_setting.buying_group_label_plural#</cfoutput></OPTION>
							<CFOUTPUT QUERY="GetBuyingGroups"><OPTION VALUE="#trim(GetBuyingGroups.Buying_Group_ID)#"#IIF(trim(FORM.Buying_Group) EQ trim(GetBuyingGroups.Buying_Group_ID), DE(" SELECTED"), DE(""))#>#trim(GetBuyingGroups.Buying_Group_Name)#</OPTION></CFOUTPUT>
						</SELECT>
					</TD>
					<cfset currentColCount = currentColCount + 1 />
					<cfif isNextRow(maxColsPerRow, currentColCount)></TR><TR></cfif>
				</cfif>
				<CFPARAM NAME="FORM.Line_Of_Biz" DEFAULT="0">
				<cfif application.returned_customer_setting.lob_search_switch eq 1 OR DistGroupDataManager.getDistributorLevelSearchFilterOn(qGetDistributorLevels, 4)>
					<TD><!--- Line Of Biz --->
						<span class="label" ID="searchItemLabel"><cfoutput>#application.returned_customer_setting.LOB_Label_Singular#</cfoutput>:</span><BR>
						<cfquery name="GetLinesOfBiz" Datasource="#application.datasource#">
							SELECT *
							FROM Line_Of_Business
							WHERE Deleted = 0
							ORDER BY Line_Of_Business_Name
						</cfquery>
						<CFSET First_Time = NOT Isdefined("FORM.Line_Of_Biz")>
						<SELECT NAME="Line_Of_Biz">
							<OPTION VALUE="0">**ALL** <cfoutput>#application.returned_customer_setting.LOB_Label_Plural#</cfoutput></OPTION>
							<CFOUTPUT QUERY="GetLinesOfBiz">
								<CFIF Line_Of_Business EQ "#ListFirst(application.returned_customer_setting.Line_Business_Default,",")#" AND First_Time AND appSettings.getSalesOrgOn() IS NOT 1>
									<CFSET FORM.Line_Of_Biz = GetLinesOfBiz.Line_Of_Business_ID>
								</CFIF>
								<OPTION VALUE="#trim(GetLinesOfBiz.Line_Of_Business_ID)#"#IIF(trim(FORM.Line_Of_Biz) EQ trim(GetLinesOfBiz.Line_Of_Business_ID), DE(" SELECTED"), DE(""))#>#trim(GetLinesOfBiz.Line_Of_Business_Name)#</OPTION>
							</CFOUTPUT>
						</SELECT>
					</TD>
					<cfset currentColCount = currentColCount + 1 />
					<cfif isNextRow(maxColsPerRow, currentColCount)></TR><TR></cfif>
				</cfif>
				<cfif variables.busSegmentForDistributors>
					<TD><!--- Business Segment --->
						<span class="label" ID="searchItemLabel"><cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput>:</span><BR>
						<cfquery name="GetBusinessSegs" Datasource="#application.datasource#">
							SELECT *
							FROM Business_Segment
							WHERE	Deleted = 0
							ORDER BY Business_Unit_Desc
						</cfquery>
						<CFSET First_Time = NOT Isdefined("FORM.Business_Segment_Id")>
						<CFPARAM NAME="FORM.Business_Segment_Id" DEFAULT="0">
						<SELECT NAME="Business_Segment_Id">
							<OPTION VALUE="0">**ALL** <cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput></OPTION>
							<CFOUTPUT QUERY="GetBusinessSegs">
							<cfif GetBusinessSegs.recordCount EQ 1>
								<CFSET FORM.Business_Segment_Id = GetBusinessSegs.Business_Segment_Id>
							</cfif>
								<OPTION VALUE="#trim(GetBusinessSegs.Business_Segment_Id)#" <cfif trim(FORM.Business_Segment_Id) EQ trim(GetBusinessSegs.Business_Segment_Id)>SELECTED</cfif>>
	#trim(GetBusinessSegs.Business_Unit_Desc)#</OPTION>
							</CFOUTPUT>
						</SELECT>
					</TD>
					<cfset currentColCount = currentColCount + 1 />
					<cfif isNextRow(maxColsPerRow, currentColCount)></TR><TR></cfif>
				</cfif>
					<input type="hidden" name="Distributor_Status" value="A">
					<TD COLSPAN="1"><!--- Zone --->
						<span class="label" ID="searchItemLabel"><cfoutput>#application.returned_customer_setting.zone_label_singular#</cfoutput>:</span><BR>
						<CFQUERY NAME="GetZones" Datasource="#application.datasource#">
						SELECT *
						FROM Service_Zones
						WHERE len(Zone_Name) != 0 AND Deleted = 0
						ORDER BY Zone_Name
						</CFQUERY>
						<CFPARAM NAME="FORM.Zone_ID" DEFAULT="0">
						<SELECT NAME="Zone_ID">
							<OPTION VALUE="0">**ALL** <cfoutput>#application.returned_customer_setting.zone_label_plural#</cfoutput></OPTION>
							<CFOUTPUT QUERY="GetZones"><OPTION VALUE="#trim(GetZones.Service_Zone_ID)#"#IIF(trim(FORM.Zone_ID) EQ GetZones.Service_Zone_ID, DE(" SELECTED"), DE(""))#>#trim(GetZones.Zone_Name)#</OPTION></CFOUTPUT>
						</SELECT>
					</TD>
					<cfset currentColCount = currentColCount + 1 />
					<cfif isNextRow(maxColsPerRow, currentColCount)></TR><TR></cfif>
					<TD><!--- Regions --->
						<span class="label" ID="searchItemLabel"><cfoutput>#application.returned_customer_setting.region_label_singular#</cfoutput>:</span><BR>
						<CFQUERY NAME="GetRegions" Datasource="#application.datasource#">
						SELECT *
						FROM Service_Regions
						WHERE len(Region_Name) != 0 AND Deleted = 0
						ORDER BY Region_Name
						</CFQUERY>
						<CFPARAM NAME="FORM.Region_ID" DEFAULT="0">
						<SELECT NAME="Region_ID">
							<OPTION VALUE="0">**ALL** <cfoutput>#application.returned_customer_setting.region_label_plural#</cfoutput></OPTION>
							<CFOUTPUT QUERY="GetRegions"><OPTION VALUE="#trim(GetRegions.Service_Region_ID)#"#IIF(trim(FORM.Region_ID) EQ getRegions.Service_Region_ID, DE(" SELECTED"), DE(""))#>#trim(GetRegions.Region_Name)#</OPTION></CFOUTPUT>
						</SELECT>
					</TD>
					<cfset currentColCount = currentColCount + 1 />
					<cfif isNextRow(maxColsPerRow, currentColCount)></TR><TR></cfif>
					<!--- Get Foodservice Line Of Business ID --->
					<CFQUERY NAME="GetFoodserviceLOBID" Datasource="#application.datasource#">
						SELECT Line_Of_Business_ID FROM Line_Of_Business WHERE Line_Of_Business IN (#ListQualify(application.returned_customer_setting.Line_Business_Default, "'", ",")#)
					</CFQUERY>
					<CFPARAM NAME="FORM.Broker" DEFAULT="0">

					<TD><!--- Brokers --->
						<span class="label" ID="searchItemLabel"><cfoutput>#application.returned_customer_setting.broker_label_singular#</cfoutput>:</span>
						<span id="Err_Broker">&nbsp;</span>
						<BR>
						<cfquery name="GetBrokers" Datasource="#application.datasource#">
							SELECT *
							FROM BSA_Foodservice_Brokers
							WHERE  	ACTIVE_CODE = 'A'
									<cfif NOT appSettings.getInvoiceBrokerFilterRestrict()>
									AND Line_Of_Business_ID = '#GetFoodserviceLOBID.Line_Of_Business_ID#'
									</cfif>
									AND Deleted = 0
							ORDER BY Broker_Name
						</cfquery>
						<SELECT NAME="Broker">
							<OPTION VALUE="0">**ALL** <cfoutput>#application.returned_customer_setting.broker_label_plural#</cfoutput></OPTION>
							<CFOUTPUT QUERY="GetBrokers"><OPTION VALUE="#trim(GetBrokers.BSA_Foodservice_Brokers_ID)#"#IIF(trim(FORM.Broker) EQ trim(GetBrokers.BSA_Foodservice_Brokers_ID), DE(" SELECTED"), DE(""))#>#trim(GetBrokers.Broker_Name)#</OPTION></CFOUTPUT>
						</SELECT>
					</TD>
					<cfset currentColCount = currentColCount + 1 />
					<cfif isNextRow(maxColsPerRow, currentColCount)></TR><TR></cfif>
						<cfparam name="CustomerPO" default="">
					<td valign="top"><span class="label" ID="searchItemLabel">PO Number:</span><BR>
					<input type="text" name="CustomerPO" SIZE="10" <cfif len(trim(CustomerPO)) GT 0>value="<cfoutput>#trim(CustomerPO)#</cfoutput>"</cfif>>
					</td>
				</TR>
				<TR>
					<TD NOWRAP>
					<span class="label" ID="searchItemLabel">Name:</span><Br>
					<INPUT TYPE="Text" NAME="searchstring" SIZE="20"<CFIF len(trim(searchstring)) GT 0>VALUE="<CFOUTPUT>#trim(FORM.searchstring)#</CFOUTPUT>"</CFIF>>
					</TD>
					<TD NOWRAP>
					<span class="label" ID="searchItemLabel"><cfoutput> #application.returned_customer_setting.Shard_Ship_To_Label# </cfoutput>:</span> <br>
					<input type="text" name="Ship_To" style=""  SIZE="10"<CFIF len(trim(ship_to)) GT 0>VALUE="<CFOUTPUT>#trim(FORM.ship_to)#</CFOUTPUT>"</CFIF>>
					</TD>
					<!---Dollar value--->
					<Td NOWRAP>
					<span class="label">Dollar Value:</span><br>
					<INPUT TYPE="Text" NAME="dollarvalue" <CFIF len(trim(dollarvalue)) GT 0>VALUE="<CFOUTPUT>#trim(dollarvalue)#</CFOUTPUT>"</CFIF> onKeyUp="clenseText(this, '0123456789.');">
					</TD>
			</TR>
			<INPUT TYPE="hidden" NAME="DOSEARCH" VALUE="1">
			<tr><td colspan="100%"><hr width="100%" color="orange"></tr>
			<!---End Distributor Criteria--->

			<!---Start Invoice criteria--->
			<tr>
			<td rowspan="100%" valign="Center"><span class="criteria">Invoice<br> Criteria</span></td>
			<TD NOWRAP ALIGN="left" colspan="1">
				<span class="label">Invoice Number:</span><br>
				<INPUT TYPE="Text" NAME="invoicenumber" SIZE="26"<CFIF len(trim(invoicenumber)) GT 0>VALUE="<CFOUTPUT>#trim(invoicenumber)#</CFOUTPUT>"</CFIF>>
			</TD>
			<TD NOWRAP ALIGN="left" colspan="2">
				<span class="label">Date:</span><br>
				<select name="datetype" style="width:40%">
					<option value="" <cfif datetype IS "">selected</cfif>>**All Date Types**</option>
					<option value="order" <cfif datetype IS "order">selected</cfif>>Order Date</option>
					<option value="ship" <cfif datetype IS "ship">selected</cfif>>Ship Date</option>
					<option value="invoice" <cfif datetype IS "invoice">selected</cfif>>Invoice Date</option>
					<option value="delivery" <cfif datetype IS "delivery">selected</cfif>>Delivery Date</option>
				</select>
				<cfoutput>
				<CFSET Date_Operators=" ,>=,=,<=">
				<CFSET Date_Operator_Symbols=" ,>=,=,<=">
				&nbsp;
				<SELECT  NAME="invoicedate_operator" ID="invoicedate_operator" STYLE="WIDTH:15%">
					<CFSET cnt=0>
					<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
						<CFSET cnt=cnt+1>
						<OPTION VALUE="#Trim(thisOperator)#"<CFIF invoicedate_operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
					</CFLOOP>
				</SELECT>
				&nbsp;
				<SPAN ID="invoice_date">
				<!--- <CF_EASYDATE FORMNAME="searchinvoices" FIELDNAME="invoicedate" FORMAT="mm/dd/yyyy" default="#invoicedate#"> --->
				<input type="text" name="invoicedate" value="#invoicedate#" style="width:40%" id="invoicedate">
				</SPAN>
				</cfoutput>

<!---
				<table border="0" cellpadding="0" cellspacing="0">
					<tr><td colspan="3"><span class="label">Date:</span></td></tr>
					<tr>
						<td>
							<select name="datetype">
								<option value="" <cfif datetype IS "">selected</cfif>>**All Date Types**</option>
								<option value="order" <cfif datetype IS "order">selected</cfif>>Order Date</option>
								<option value="ship" <cfif datetype IS "ship">selected</cfif>>Ship Date</option>
								<option value="invoice" <cfif datetype IS "invoice">selected</cfif>>Invoice Date</option>
								<option value="delivery" <cfif datetype IS "delivery">selected</cfif>>Delivery Date</option>
							</select>
						</td>
						<cfoutput>
						<td>
							<CFSET Date_Operators=" ,>=,=,<=">
							<CFSET Date_Operator_Symbols=" ,>=,=,<=">
							&nbsp; &nbsp; <SELECT  NAME="invoicedate_operator" ID="invoicedate_operator" STYLE="WIDTH:45px">
								<CFSET cnt=0>
								<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
									<CFSET cnt=cnt+1>
									<OPTION VALUE="#Trim(thisOperator)#"<CFIF invoicedate_operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
								</CFLOOP>
							</SELECT>
						</td>
						<td>
							<SPAN ID="invoice_date">
							<CF_EASYDATE FORMNAME="searchinvoices" FIELDNAME="invoicedate" FORMAT="mm/dd/yyyy" default="#invoicedate#">
							</SPAN>
						</td>
						</cfoutput>
					</tr>
				</table>
 --->
			</TD>
			<TD NOWRAP>
				<cfoutput><span class="label">#variables.orderNumberLabel.General_Labels_Label#:</span><br></cfoutput>
				<cfoutput><input name="ordernumber" type="Text" size="26" value="#form.orderNumber#"></cfoutput>
			</td>
			</tr>
			</TABLE>      <!--- TABLE border="0" cellpadding="0" cellspacing="0" id="invoiceSearch" --->

			<cfoutput>
			<div id="actions">
				<a href="##" onclick="javascript:submitForm(this);return false;">#application.util.string.actionLinkFormat("search invoices")#</a>
				<a href="##" onclick="reset_form();">#application.util.string.actionLinkFormat("reset")#</a>
			</div>
			</cfoutput>
<cfset displayBrokerInSearchResult = 0>
<cfif appSettings.getInvoiceBrokerFilterRestrict() AND NOT appSettings.getDistributorMultiPosition()>
	<cfset displayBrokerInSearchResult = 1>
</cfif>
<CFIF DOSEARCH EQ 1>

	<cfset UserPositionList = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.user_id, 0, 1) />

	<cfset HQPosition = CreateObject("component", "components.geography.position").getHQPosition() />
	<cfset HQUser = 0>
	<cfif listfind(UserPositionList, HQPosition.User_Positions_ID)>
		<cfset HQUser = 1>
	</cfif>

	<CFSET form.searchstring = trim(form.searchstring)>
 	<CFQUERY NAME="TheQuery" DATASOURCE="#application.datasource#">
        /*** \search_screens\invoice\search_invoices.cfm - around line 450 ***/
		<cfif appSettings.getInvoicePositionRestriction()>
		DECLARE @Markets_Below_Me table
		(
		  Service_Market_ID   int          NOT NULL
		)
		INSERT INTO @Markets_Below_Me(Service_Market_ID)
		SELECT	DISTINCT Service_Market_ID
		FROM	Positions_Below_Me
		WHERE	Service_Market_ID IS NOT NULL
		AND		User_Positions_ID IN (#PreserveSingleQuotes(UserPositionList)#)
		</cfif>
		SELECT 	DISTINCT (Invoice_Header.Invoice_Version + '-' + Invoice_Header.Order_Number) AS Invoice_Number, Invoice_Header.BSA_Foodservice_Customers_ID AS Distributor_ID, Invoice_Header.shared_invoice_number, Invoice_Header.Invoice_Date, Invoice_Header.Invoice_Header_ID, BSA_Foodservice_Customers.Name, Invoice_Header.Original_Shared_Ship_To, Invoice_Header.Purchase_Order, (Select SUM(cast(isnull(Invoice_Detail.Sales_Dollars, 0) as float)) From Invoice_Detail WHERE Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID AND ISNULL(Invoice_Detail.Deleted,0) = 0) AS Total_Dollars
				<cfif displayBrokerInSearchResult>
				,BSA_Foodservice_Brokers.Broker_Name
				</cfif>
				,Invoice_Header.Pro_Number
		FROM 	Invoice_Header
				INNER JOIN BSA_Foodservice_Customers
				ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Invoice_Header.BSA_Foodservice_Customers_ID
				INNER JOIN Invoice_Detail
				ON Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
				AND ISNULL(Invoice_Detail.Deleted,0) = 0
				<cfif displayBrokerInSearchResult>
				LEFT JOIN	BSA_Foodservice_Brokers ON BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
				</cfif>
		WHERE 	Invoice_Header.BSA_Foodservice_Customers_ID
				IN
				(
					SELECT	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
					FROM 	BSA_Foodservice_Customers
							LEFT JOIN	Distributor_Family ON BSA_Foodservice_Customers.Family_ID = Distributor_Family.Family_ID
							<cfif NOT appSettings.getDistributorMultiPosition()>
								LEFT JOIN	BSA_Foodservice_Brokers ON BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
							<cfelse>
								LEFT JOIN Market_Distributor ON Market_Distributor.Deleted = 0 AND Market_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
								LEFT JOIN Service_Markets ON Service_Markets.Service_Market_ID = Market_Distributor.Service_Market_ID
								LEFT JOIN Service_Regions ON Service_Regions.Service_Region_ID = Service_Markets.Service_Region_ID AND Service_Regions.Deleted = 0
								LEFT JOIN BSA_Foodservice_Brokers ON Service_Markets.Service_Market_ID = BSA_Foodservice_Brokers.Service_Market_ID
							</cfif>
					WHERE 0 = 0
					<cfif NOT appSettings.getDistributorMultiPosition()>
						<cfif appSettings.getInvoicePositionRestriction() AND HQUser EQ 0>
						AND		BSA_Foodservice_Brokers.Service_Market_ID IN (SELECT Service_Market_ID FROM @Markets_Below_Me)
						</cfif>
					<cfelse>
						<cfif appSettings.getInvoicePositionRestriction() AND HQUser EQ 0>
						AND		Service_Markets.Service_Market_ID IN (SELECT Service_Market_ID FROM @Markets_Below_Me)
						</cfif>
					</cfif>

					<!--- family name --->
					<CFIF FORM.Family_Name NEQ 0>
						AND dbo.BSA_Foodservice_Customers.Family_ID = '#FORM.Family_Name#'
					</CFIF>

					<!--- Purchase order --->
					<CFIF FORM.CustomerPO NEQ "">
						AND dbo.Invoice_Header.Purchase_Order LIKE '%#FORM.CustomerPO#%'
					</CFIF>


					<!--- buying group --->
					<CFIF FORM.Buying_Group NEQ 0>
						AND dbo.BSA_Foodservice_Customers.Buying_Group_ID = '#FORM.Buying_Group#'
					</CFIF>

					<!--- Line Of Business --->
					<CFIF FORM.Line_Of_Biz NEQ 0>
						AND dbo.BSA_Foodservice_Customers.Line_Of_Business_ID = '#FORM.Line_Of_Biz#'
					</CFIF>

					<!--- Business Segment --->
					<cfparam name="FORM.Business_Segment_Id" 	default="0">
					<CFIF FORM.Business_Segment_Id NEQ 0>
						AND dbo.BSA_Foodservice_Customers.Business_Segment_Id = #FORM.Business_Segment_Id#
					</CFIF>


					<!--- Distributor Status --->
					<CFIF FORM.Distributor_Status NEQ 0>
						AND dbo.BSA_Foodservice_Customers.Active_Code = '#FORM.Distributor_Status#'
					</CFIF>

					<!---Ship To--->
					<cfif form.Ship_To NEQ "">
						AND
							((BSA_Foodservice_Customers.Ship_To LIKE '%#form.Ship_To#%')
						OR
							(BSA_Foodservice_Customers.Shr_Ship_To LIKE '%#form.Ship_To#%'))
					</cfif>

					<!--- Zone --->
					<CFIF FORM.Zone_ID NEQ 0>
						AND
						<cfif NOT appSettings.getDistributorMultiPosition()>
						BSA_Foodservice_Brokers.Service_Zone_ID
						<cfelse>Service_Regions.Service_Zone_ID</cfif> = '#FORM.Zone_ID#'
					</CFIF>

					<!--- Region --->
					<CFIF FORM.Region_ID NEQ 0>
						AND <cfif NOT appSettings.getDistributorMultiPosition()>
						BSA_Foodservice_Brokers.Service_Region_ID
						<cfelse>Service_Markets.Service_Region_ID</cfif> = '#FORM.Region_ID#'
					</CFIF>

					<!--- Broker --->
					<CFIF FORM.Broker NEQ 0>
						AND dbo.BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = '#FORM.Broker#'
					</CFIF>

						<!--- Dollar Value --->
					<CFIF FORM.DollarValue NEQ "">
						AND
						(
							Invoice_Detail.Sales_Dollars LIKE '%#Form.DollarValue#%'
							OR
							cast((Select SUM(cast(Invoice_Detail.Sales_Dollars as money)) From Invoice_Detail WHERE Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID) as nvarchar) LIKE '%#Form.DollarValue#%'
						)
					</CFIF>

					<CFIF len(trim(FORM.searchstring)) GT 0>
						AND
						(
							BSA_Foodservice_Customers.Name LIKE '%#form.searchstring#%'
							OR BSA_Foodservice_Customers.City LIKE '%#form.searchstring#%'
							OR Distributor_Family.Family_Name LIKE '%#form.searchstring#%'
							<CFIF isnumeric(form.searchstring)>
								OR BSA_Foodservice_Customers.Shr_Family LIKE '%#form.searchstring#%'
							</CFIF>
							OR BSA_Foodservice_Brokers.Broker_Name LIKE '%#form.searchstring#%'
						)
					</CFIF>

				)
		<!---Additional invoice criteria--->

		<!---Invoice number--->
		<cfif len(trim(invoicenumber)) GT 0>
		AND
		(
			Invoice_Header.Order_Number LIKE '%#invoicenumber#%'
			OR Invoice_Header.Invoice_Version LIKE '%#invoicenumber#%'
			OR Invoice_Header.Order_Number + Invoice_Header.Invoice_Version LIKE '%#invoicenumber#%'
			OR Invoice_Header.Shared_Invoice_Number LIKE '%#invoicenumber#%'
		)
		</cfif>

		<!---Dates--->
		<cfif len(trim(datetype)) IS NOT ""  AND len(trim(invoicedate)) IS NOT "" AND invoicedate_operator IS NOT "">
			AND
				<cfif datetype IS "delivery">
				Invoice_Header.Delivery_Date #invoicedate_operator# '#invoicedate#'
				<cfelseif datetype IS "ship">
				Invoice_Header.Ship_Date #invoicedate_operator# '#invoicedate#'
				<cfelseif datetype IS "invoice">
				Invoice_Header.Invoice_Date #invoicedate_operator# '#invoicedate#'
				<cfelse>
				Invoice_Header.Invoice_Date #invoicedate_operator# '#invoicedate#'
				</cfif>

		</cfif>

		<!--- order number --->
		<cfif len(trim(form.orderNumber))>
			AND Invoice_Header.Pro_Number like '%#trim(form.orderNumber)#%'
		</cfif>
		AND Invoice_Header.Deleted = 0
		ORDER BY #replaceNoCase(form.sort_by, "Invoice_Header.", '')# #sort_order#

	</CFQUERY>


	<SCRIPT>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			function CA() {
				if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many invoices in the list below while selecting them all.")<CFELSE>0==0</CFIF>) {
					for (var i=0;i<MyForm.elements.length;i++)
						{
							var e = MyForm.elements[i];
							if ((e.name != 'allbox') && (e.type=='checkbox') && (e.name != 'ALLINCATEGORY')) {
								e.checked = MyForm.allbox.checked;
							}
						}
				//toggleRowColors()
				}
				else {
					document.all.allbox.checked = false;
				}
			}
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	</SCRIPT>

</fieldset>

<div style="clear:both;"></div>

	<FIELDSET STYLE="margin-top:5px; padding:4px; border: 1px solid Blue; width:100%;" name="result">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.recordcount EQ 1>is<CFELSE>are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1>invoice<CFELSE>invoices</CFIF> that <CFIF TheQuery.recordcount EQ 1>matched<CFELSE>match</CFIF> the above criteria</LEGEND>
		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>
			<TABLE border="0" cellspacing="0" cellpadding="3" WIDTH="100%" CLASS="Maintable">
				<TR ID="header" BGCOLOR="#ffce84">

				<cfoutput>

				<CFSET HeaderNameList = "Invoice Number, PO Number, " & variables.orderNumberLabel.General_Labels_Label & ", #application.returned_customer_setting.distributor_label_singular#">
				<CFSET HeaderColumnList = "Invoice_Header.Shared_Invoice_Number,Invoice_Header.Purchase_Order,Invoice_Header.Pro_Number,Name">

				<!--- Include broker name --->
				<cfif displayBrokerInSearchResult>
					<CFSET HeaderNameList = ListAppend(HeaderNameList, "#application.returned_customer_setting.broker_label_singular#") />
					<CFSET HeaderColumnList = ListAppend(HeaderColumnList, "BSA_Foodservice_Brokers.Broker_Name") />
				</cfif>

				<CFSET HeaderNameList = ListAppend(HeaderNameList, "Invoice Date") />
				<CFSET HeaderColumnList = ListAppend(HeaderColumnList, "Invoice_Header.Invoice_Date") />

				<!---Include shared invoice--->
				<cfif application.returned_customer_setting.shared_invoice IS 1>
					<CFSET HeaderNameList = ListAppend(HeaderNameList, "Legacy Invoice ##") />
					<CFSET HeaderColumnList = ListAppend(HeaderColumnList, "Invoice_Number") />
				</cfif>

				<CFSET HeaderNameList = ListAppend(HeaderNameList, "Total $") />
				<CFSET HeaderColumnList = ListAppend(HeaderColumnList, "Invoice_Header.Total_Dollars") />

				<CFSET Counter = 1>
				<CFLOOP LIST="#HeaderNameList#" INDEX="this_Header" DELIMITERS=",">
				<CFSET sortImage="">

				<CFIF listgetat(HeaderColumnList,Counter) EQ sort_by>
					<CFIF SORT_ORDER EQ "DESC">
						<CFSET New_Sort_Order="ASC">
						<CFSET sortImage="up_1.gif">
					<CFELSE>
						<CFSET New_Sort_Order="DESC">
						<CFSET sortImage="down_1.gif">
					</CFIF>
					<CFELSE>
						<CFSET New_Sort_Order="ASC">
				  </CFIF>
					<TD ID="header" <cfif this_Header IS " Total $">align="right"<cfelse>align="left"</cfif>><strong><A HREF="##" OnClick="javaScript: return sortByThisItem(this,'#listgetat(HeaderColumnList,Counter)#','#New_Sort_Order#');">#this_Header#<CFIF Len(sortImage) GT 0> <IMG BORDER="0" SRC="/Images/#sortImage#"></CFIF></A></strong></TD>
					<CFSET Counter = Counter + 1>
				  </CFLOOP>
				</cfoutput>

				</TR>


			<CFOUTPUT QUERY="TheQuery" startrow="#StartRow#" maxrows="#MaxRows#">
				<TR STYLE="cursor:pointer;" <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>

					<TD onClick="NewWindow('/search_Screens/invoice/invoice_detail.cfm?Invoice_Header_ID=#Invoice_Header_ID#','#trim(ReplaceNoCase(ReplaceNoCase(Shared_Invoice_Number, "-", "", "ALL"), ".", "","ALL"))#','850','600','Yes', 'Yes');return false;" NOWRAP><strong><font color="Red">[</font> <font color="blue">#Shared_Invoice_Number#&nbsp;</font><font color="red">]</font></strong></TD>
					<TD onClick="NewWindow('/search_Screens/invoice/invoice_detail.cfm?Invoice_Header_ID=#Invoice_Header_ID#','#trim(ReplaceNoCase(ReplaceNoCase(Shared_Invoice_Number, "-", "", "ALL"), ".", "","ALL"))#','850','600','Yes', 'Yes');return false;" NOWRAP>&nbsp; &nbsp; &nbsp; #Purchase_Order#&nbsp; </TD>
					<TD onClick="NewWindow('/search_Screens/invoice/invoice_detail.cfm?Invoice_Header_ID=#Invoice_Header_ID#','#trim(ReplaceNoCase(ReplaceNoCase(Shared_Invoice_Number, "-", "", "ALL"), ".", "","ALL"))#','850','600','Yes', 'Yes');return false;" NOWRAP>&nbsp; &nbsp; &nbsp; #Pro_Number#&nbsp; </TD>
					<TD onClick="NewWindow('/search_Screens/invoice/invoice_detail.cfm?Invoice_Header_ID=#Invoice_Header_ID#','#trim(ReplaceNoCase(ReplaceNoCase(Shared_Invoice_Number, "-", "", "ALL"), ".", "","ALL"))#','850','600','Yes', 'Yes');return false;" NOWRAP>#Name#&nbsp; </TD>
					<cfif displayBrokerInSearchResult>
					<TD onClick="NewWindow('/search_Screens/invoice/invoice_detail.cfm?Invoice_Header_ID=#Invoice_Header_ID#','#trim(ReplaceNoCase(ReplaceNoCase(Shared_Invoice_Number, "-", "", "ALL"), ".", "","ALL"))#','850','600','Yes', 'Yes');return false;" NOWRAP>#Broker_Name#&nbsp; </TD>
					</cfif>
					<TD onClick="NewWindow('/search_Screens/invoice/invoice_detail.cfm?Invoice_Header_ID=#Invoice_Header_ID#','#trim(ReplaceNoCase(ReplaceNoCase(Shared_Invoice_Number, "-", "", "ALL"), ".", "","ALL"))#','850','600','Yes', 'Yes');return false;" NOWRAP>#DateFormat(Invoice_Date, 'MMM DD, YYYY')#&nbsp;</TD>
					<!---Only show this field if the customer uses a shared invoice number--->
					<cfif application.returned_customer_setting.shared_invoice IS 1>
					<TD onClick="NewWindow('/search_Screens/invoice/invoice_detail.cfm?Invoice_Header_ID=#Invoice_Header_ID#','#trim(ReplaceNoCase(ReplaceNoCase(Shared_Invoice_Number, "-", "", "ALL"), ".", "","ALL"))#','850','600','Yes', 'Yes');return false;" NOWRAP>#Invoice_Number#&nbsp; </TD>
					</cfif>
					<TD onClick="NewWindow('/search_Screens/invoice/invoice_detail.cfm?Invoice_Header_ID=#Invoice_Header_ID#','#trim(ReplaceNoCase(ReplaceNoCase(Shared_Invoice_Number, "-", "", "ALL"), ".", "","ALL"))#','850','600','Yes', 'Yes');return false;" NOWRAP align="right"><cfif isNumeric(Total_Dollars)>#LSCurrencyFormat(Total_Dollars)#<cfelse>$0.00</cfif>&nbsp;</TD>
 				</TR>
			</CFOUTPUT>
			</TABLE>

			<DIV ALIGN="center" STYLE="font-size: 12px; color: Red;">
			<CF_Next_Previous_For_Forms
				formname="searchinvoices"
				query="TheQuery"
				maxpages="40"
				previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
				next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
				previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				addparams=""
			>
		</CFIF>
	</FIELDSET>

</CFIF>
<Cfoutput>
<INPUT TYPE="hidden" name="sort_by" value="#sort_by#">
<INPUT TYPE="hidden" name="sort_Order" value="#sort_Order#">
</CFOUTPUT>
<INPUT TYPE="hidden" NAME="startrow" VALUE="1">
<INPUT TYPE="hidden" NAME="frompage" VALUE="1">


</FORM>

<cf_messagewindow />
</blockquote>

<cfset jQueryUI.version = "1.8.23">
<cfinclude template="/common_files/jQuery.cfm">
<script>
$("input#invoicedate").datepicker( { numberOfMonths: 3, showCurrentAtPos: 0 });
</script>
</BODY>
</HTML>