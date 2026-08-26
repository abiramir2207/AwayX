<!---
/deductions/search_screens/search_invoices.cfm
Brenda Flynn
July 10, 2003

--->

<!---Sends them home if they're not allowed to use this --->
<!--- <CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFIF Get_Profile_Settings.View_Invoices EQ 0>
	<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
</CFIF> --->


<!--------------------------------------------------------
Start Search Form
--------------------------------------------------------->

<STYLE>
	SELECT,INPUT
	{
		font-size : 10px;
	}
	SELECT
	{
		font-size : 10px;
		WIDTH:200px;
	}
</STYLE>

	<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>

<CFSET Date_Operators=" ,Greater_Or_Equal,Equal,Less_Or_Equal">
			<CFSET Date_Operator_Symbols=" ,>=,=,<=">


<CFSET PAGE_TITLE="Invoice Search">
<CFSET GROUP="Deployment">

<CFPARAM NAME="startrow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<CFPARAM NAME="searchstring" DEFAULT="">
<CFPARAM NAME="DoSearch" DEFAULT="0">
<CFPARAM NAME="invoicenumber" DEFAULT="">
<CFPARAM NAME="datetype" DEFAULT="invoice">
<CFPARAM NAME="invoicedate" DEFAULT="">
<CFPARAM NAME="dollarvalue" default="">
<CFPARAM NAME="InvoiceDate_Operator" Default=">=">
<CFPARAM NAME="FORM.AlreadySelectedItems" DEFAULT="">
<CFPARAM NAME="sort_by" DEFAULT="Invoice_Date">
<CFPARAM NAME="sort_order" DEFAULT="DESC">
<CFPARAM NAME="Return_Value" DEFAULT="0">
<CFPARAM NAME="Source" DEFAULT="Search">
<CFPARAM NAME="finishedselecting" DEFAULT=0>
<cfparam name="highlight" default="0">
<cfparam name="CustomerPO" default="">
<cfparam name="form.CustomerPO" default="">

	<cfset defaultdate = "01/01/" & datepart('yyyy', now())>
<cfif invoicedate IS "">
	<cfset invoicedate = defaultdate>
</cfif>
<cf_Number_of_Rows maxrows=13>


<CFIF finishedselecting IS 1 AND Source IS "Deductions">
<!---Submit the form--->

<Cfif isdefined("SelectedReasons")>

	<!---Parse into type & ID--->
<!--- <cfdump var="#form#"> --->
	<cfset useLakebaseForDeletePrior = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_relationships")>
<cfif useLakebaseForDeletePrior>
<cftry>
<cfset application.oLakebase.deleteRows("dd_relationships",
{ "deduction_id" = "eq.#Deduction_ID#", "dd_relationship_type_id" = "eq.3" }
)>
<cfcatch type="any">
<cfset useLakebaseForDeletePrior = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForDeletePrior><cfquery name="DeletePrior" datasource="#application.datasource#">
	DELETE 
	FROM DD_Relationships
	WHERE Deduction_ID = '#Deduction_ID#'
	AND DD_Relationship_Type_ID = 3
	</cfquery>
</cfif>

<CFLOOP INDEX="ListItem" LIST="#SelectedReasons#" DELIMITERS=",">

	<cfset SelectedReason = replace(ListItem, '_', '-', "all")>

  <cfset useLakebaseForInsertValues = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_relationships")>
<cfif useLakebaseForInsertValues>
<cftry>
<cfset application.oLakebase.insertRow("dd_relationships", {
"deduction_id" = Deduction_ID,
"dd_relationship_type_id" = 3,
"dd_key_to_relationship" = SelectedReason
})>
<cfcatch type="any">
<cfset useLakebaseForInsertValues = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForInsertValues><cfquery name="InsertValues" datasource="#application.datasource#">
	INSERT INTO DD_Relationships
	(
		Deduction_ID,
		DD_Relationship_Type_ID,
		DD_Key_to_Relationship
	)
	VALUES
	(
		'#Deduction_ID#',
		3,
		'#SelectedReason#'
	)
	</cfquery>
</cfif> 
	
	<cfset useLakebaseForGetDistributorID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("invoice_header")>
<cfif useLakebaseForGetDistributorID>
<cftry>
<cfset GetDistributorID = application.oLakebase.toQuery(
application.oLakebase.selectRows("invoice_header", {
"select" = "bsa_foodservice_customers_id",
"invoice_header_id" = "eq.#SelectedReason#"
}),
"bsa_foodservice_customers_id"
)>
<cfcatch type="any">
<cfset useLakebaseForGetDistributorID = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetDistributorID><cfquery name="GetDistributorID" datasource="#application.datasource#">
	SELECT BSA_Foodservice_Customers_ID
	FROM Invoice_Header
	WHERE Invoice_Header_ID = '#SelectedReason#'
	</cfquery>
</cfif>
	
	<cfset useLakebaseForUpdateDistributorInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForUpdateDistributorInfo>
<cftry>
<cfset application.oLakebase.updateRows("deductions",
{ "deduction_id" = "eq.#Deduction_ID#" },
{ "distributor_id" = GetDistributorID.BSA_Foodservice_Customers_ID }
)>
<cfcatch type="any">
<cfset useLakebaseForUpdateDistributorInfo = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateDistributorInfo><cfquery name="UpdateDistributorInfo" datasource="#application.datasource#">
	UPDATE Deductions
	Set Distributor_ID = '#GetDistributorID.BSA_Foodservice_Customers_ID#'
	WHERE Deduction_ID = '#Deduction_ID#'
	</cfquery>
</cfif>
	
</CFLOOP>
</CFIF>

	<cfoutput>
	<script>
		opener.document.all.Refresh.submit()
		window.close()		
	</script>
	</cfoutput>
	<cfabort>
</CFIF>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
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
		
		function reset_form()
		{ 
		if(confirm("Are you sure you want to reset these search criteria?"))
			{
				document.searchinvoices.Family_Name.value = 0;
				document.searchinvoices.Buying_Group.value = 0;
				document.searchinvoices.Line_Of_Biz.value = 0;
				document.searchinvoices.Zone_ID.value = 0;
				document.searchinvoices.Region_ID.value = 0;
				document.searchinvoices.Broker.value = 0;
				document.searchinvoices.searchstring.value = "";
				document.searchinvoices.invoicenumber.value = "";
				document.searchinvoices.datetype.value = "";
				document.searchinvoices.invoicedate_operator.value = "";
				document.searchinvoices.invoicedate.value = "";
			}
		}

		function selectAll(){
		
			if(window.checkallReasons != null){
				for(var x=0; x<checkallReasons.length;x++){
					box = getFirstChild(checkallReasons[x])
					box.checked = document.all.checkall.checked
				}
			}
		}
		
		function finishedSearching() {
		
			document.all.finishedselecting.value = 1
			document.all.searchinvoices.submit();
		}

</SCRIPT>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<!---Spinner--->
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<CFFLUSH>
<SCRIPT LANGUAGE="JavaScript">

function hide_PleaseWaitMessage()
{ 
 document.all.PleaseWaitMessage.style.display='none';
}
hide_PleaseWaitMessage();


</SCRIPT>


<script>


</script>
				
<style>
TABLE.Maintable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header 
{
	font-size: 12px;
}
</style>

<cfif Source IS "Deductions">
	&nbsp; 
<cfelse>
	<!--- Header include --->
	<CFINCLUDE TEMPLATE="/includes/header.cfm">
	<!--- End Header include --->
</cfif>

<blockquote>

	<FORM ACTION="/deductions/search_screens/invoice.cfm" METHOD="post" NAME="searchinvoices" ID="searchinvoices">

	<FIELDSET STYLE="padding:8px; border: 1px solid Blue; width:855px">
	    <cfoutput><LEGEND STYLE="font: bold 14px sans-serif; color: Red;">invoice search</LEGEND></cfoutput>
			<TABLE border="0"  WIDTH="855px" cellpadding="0" cellspacing="0">
			
			<tr><td rowspan="3" valign="center"> <strong><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput><br> Criteria</strong></td>
					<TD COLSPAN="1"><!--- Family Name --->
						<span ID="searchItemLabel">Family Name</span><BR>
						<cfset useLakebaseForGetFamilyNames = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_family")>
<cfif useLakebaseForGetFamilyNames>
<cftry>
<cfset GetFamilyNames = application.oLakebase.toQuery(
application.oLakebase.selectRows("distributor_family", {
"deleted" = "eq.0",
"order" = "family_name.asc"
})
)>
<cfcatch type="any">
<cfset useLakebaseForGetFamilyNames = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetFamilyNames><cfquery name="GetFamilyNames" Datasource="#application.datasource#">
							SELECT *
							FROM Distributor_Family
							WHERE Deleted = 0
							ORDER BY Family_Name
						</cfquery>
</cfif>
						<CFPARAM NAME="FORM.Family_Name" DEFAULT="0">
						<SELECT NAME="Family_Name" style="width: 200px;">
							<OPTION VALUE="0">**ALL** Family Names</OPTION>
							<CFOUTPUT QUERY="GetFamilyNames"><OPTION VALUE="#trim(GetFamilyNames.Family_ID)#"#IIF(trim(FORM.Family_Name) EQ trim(GetFamilyNames.Family_ID), DE(" SELECTED"), DE(""))#>#trim(GetFamilyNames.Family_Name)#</OPTION></CFOUTPUT>
						</SELECT>					
					</TD>
					<TD><!--- Buying Groups --->
						<span ID="searchItemLabel">Buying Groups</span><BR>
						<cfset useLakebaseForGetBuyingGroups = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_buying_groups")>
<cfif useLakebaseForGetBuyingGroups>
<cftry>
<cfset GetBuyingGroups = application.oLakebase.toQuery(
application.oLakebase.selectRows("distributor_buying_groups", {
"deleted" = "eq.0",
"order" = "buying_group_name.asc"
})
)>
<cfcatch type="any">
<cfset useLakebaseForGetBuyingGroups = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetBuyingGroups><cfquery name="GetBuyingGroups" Datasource="#application.datasource#">
							SELECT *
							FROM Distributor_Buying_Groups
							WHERE Deleted = 0
							ORDER BY Buying_Group_Name
						</cfquery>
</cfif>
						<CFPARAM NAME="FORM.Buying_Group" DEFAULT="0">
						<SELECT NAME="Buying_Group" style="width: 200px;">
							<OPTION VALUE="0">**ALL** Buying Groups</OPTION>
							<CFOUTPUT QUERY="GetBuyingGroups"><OPTION VALUE="#trim(GetBuyingGroups.Buying_Group_ID)#"#IIF(trim(FORM.Buying_Group) EQ trim(GetBuyingGroups.Buying_Group_ID), DE(" SELECTED"), DE(""))#>#trim(GetBuyingGroups.Buying_Group_Name)#</OPTION></CFOUTPUT>
						</SELECT>					
					</TD>
					<TD><!--- Line Of Biz --->
						<span ID="searchItemLabel">Line Of Business</span><BR>
						<cfset useLakebaseForGetLinesOfBiz = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("line_of_business")>
<cfif useLakebaseForGetLinesOfBiz>
<cftry>
<cfset GetLinesOfBiz = application.oLakebase.toQuery(
application.oLakebase.selectRows("line_of_business", {
"deleted" = "eq.0",
"order" = "line_of_business_name.asc"
})
)>
<cfcatch type="any">
<cfset useLakebaseForGetLinesOfBiz = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetLinesOfBiz><cfquery name="GetLinesOfBiz" Datasource="#application.datasource#">
							SELECT *
							FROM Line_Of_Business
							WHERE Deleted = 0
							ORDER BY Line_Of_Business_Name
						</cfquery>
</cfif>
						<CFSET First_Time = NOT Isdefined("FORM.Line_Of_Biz")>
						<CFPARAM NAME="FORM.Line_Of_Biz" DEFAULT="0">
						<SELECT NAME="Line_Of_Biz" style="width: 200px;">
							<OPTION VALUE="0">**ALL** Lines Of Business</OPTION>
							<CFOUTPUT QUERY="GetLinesOfBiz">
							<CFIF Line_Of_Business EQ "#ListFirst(application.returned_customer_setting.Line_Business_Default,",")#" AND First_Time>
								<CFSET FORM.Line_Of_Biz = GetLinesOfBiz.Line_Of_Business_ID>
							</CFIF><OPTION VALUE="#trim(GetLinesOfBiz.Line_Of_Business_ID)#"#IIF(trim(FORM.Line_Of_Biz) EQ trim(GetLinesOfBiz.Line_Of_Business_ID), DE(" SELECTED"), DE(""))#>#trim(GetLinesOfBiz.Line_Of_Business_Name)#</OPTION></CFOUTPUT>
						</SELECT>					
					</TD>
					<!---Dollar value--->
					<Td>
					Dollar Value<br>
					$<INPUT TYPE="Text" NAME="dollarvalue" STYLE="WIDTH:203px" SIZE="10"<CFIF len(trim(dollarvalue)) GT 0>VALUE="<CFOUTPUT>#trim(dollarvalue)#</CFOUTPUT>"</CFIF> onKeyUp="clenseText(this, '0123456789.');">	
					</TD>
					<input type="hidden" name="Distributor_Status" value="A">
				</TR>
				<TR>
					<TD COLSPAN="1"><!--- Zone --->
						<span ID="searchItemLabel">Zone</span><BR>
						<cfset useLakebaseForGetZones = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("service_zones")>
<cfif useLakebaseForGetZones>
<cftry>
<cfset GetZones = application.oLakebase.toQuery(
application.oLakebase.selectRows("service_zones", {
"zone_name" = "neq.",
"deleted" = "eq.0",
"order" = "zone_name.asc"
})
)>
<cfcatch type="any">
<cfset useLakebaseForGetZones = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetZones><CFQUERY NAME="GetZones" Datasource="#application.datasource#">
						SELECT *
						FROM Service_Zones
						WHERE len(Zone_Name) != 0 AND Deleted = 0
						ORDER BY Zone_Name
						</CFQUERY>
</cfif>
						<CFPARAM NAME="FORM.Zone_ID" DEFAULT="0">
						<SELECT NAME="Zone_ID" style="width: 200px;">
							<OPTION VALUE="0">**ALL** Zones</OPTION>
							<CFOUTPUT QUERY="GetZones"><OPTION VALUE="#trim(GetZones.Service_Zone_ID)#"#IIF(trim(FORM.Zone_ID) EQ GetZones.Service_Zone_ID, DE(" SELECTED"), DE(""))#>#trim(GetZones.Zone_Name)#</OPTION></CFOUTPUT>
						</SELECT>	
					</TD>
					<TD><!--- Regions --->
						<span ID="searchItemLabel">Region</span><BR>
						<cfset useLakebaseForGetRegions = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("service_regions")>
<cfif useLakebaseForGetRegions>
<cftry>
<cfset GetRegions = application.oLakebase.toQuery(
application.oLakebase.selectRows("service_regions", {
"region_name" = "neq.",
"deleted" = "eq.0",
"order" = "region_name.asc"
})
)>
<cfcatch type="any">
<cfset useLakebaseForGetRegions = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetRegions><CFQUERY NAME="GetRegions" Datasource="#application.datasource#">
						SELECT *
						FROM Service_Regions
						WHERE len(Region_Name) != 0 AND Deleted = 0
						ORDER BY Region_Name
						</CFQUERY>
</cfif>
						<CFPARAM NAME="FORM.Region_ID" DEFAULT="0">
						<SELECT NAME="Region_ID" style="width: 200px;">
							<OPTION VALUE="0">**ALL** Regions</OPTION>
							<CFOUTPUT QUERY="GetRegions"><OPTION VALUE="#trim(GetRegions.Service_Region_ID)#"#IIF(trim(FORM.Region_ID) EQ getRegions.Service_Region_ID, DE(" SELECTED"), DE(""))#>#trim(GetRegions.Region_Name)#</OPTION></CFOUTPUT>
						</SELECT>	
					</TD>					
					<!--- Get Foodservice Line Of Business ID --->
					<cfset useLakebaseForGetFoodserviceLOBID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("line_of_business")>
<cfif useLakebaseForGetFoodserviceLOBID>
<cftry>
<cfset GetFoodserviceLOBID = application.oLakebase.toQuery(
application.oLakebase.selectRows("line_of_business", {
"select" = "line_of_business_id",
"line_of_business" = "in.(#ListQualify(application.returned_customer_setting.Line_Business_Default, "'", ",")#)"
}),
"line_of_business_id"
)>
<cfcatch type="any">
<cfset useLakebaseForGetFoodserviceLOBID = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetFoodserviceLOBID><CFQUERY NAME="GetFoodserviceLOBID" Datasource="#application.datasource#">
						SELECT Line_Of_Business_ID FROM Line_Of_Business WHERE Line_Of_Business IN (#ListQualify(application.returned_customer_setting.Line_Business_Default, "'", ",")#)
					</CFQUERY>
</cfif>
					<TD><!--- Brokers --->
						<span ID="searchItemLabel">Broker</span><BR>
						<cfset useLakebaseForGetBrokers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_brokers")>
<cfif useLakebaseForGetBrokers>
<cftry>
<cfset GetBrokers = application.oLakebase.toQuery(
application.oLakebase.selectRows("bsa_foodservice_brokers", {
"active_code" = "eq.A",
"line_of_business_id" = "eq.#GetFoodserviceLOBID.Line_Of_Business_ID#",
"deleted" = "eq.0",
"order" = "broker_name.asc"
})
)>
<cfcatch type="any">
<cfset useLakebaseForGetBrokers = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetBrokers><cfquery name="GetBrokers" Datasource="#application.datasource#">
							SELECT *
							FROM BSA_Foodservice_Brokers
							WHERE  ACTIVE_CODE = 'A' AND Line_Of_Business_ID = '#GetFoodserviceLOBID.Line_Of_Business_ID#' AND Deleted = 0
							ORDER BY Broker_Name
						</cfquery>
</cfif>
						<CFPARAM NAME="FORM.Broker" DEFAULT="0">
						<SELECT NAME="Broker" style="width: 200px;">
							<OPTION VALUE="0">**ALL** Brokers</OPTION>
							<CFOUTPUT QUERY="GetBrokers"><OPTION VALUE="#trim(GetBrokers.BSA_Foodservice_Brokers_ID)#"#IIF(trim(FORM.Broker) EQ trim(GetBrokers.BSA_Foodservice_Brokers_ID), DE(" SELECTED"), DE(""))#>#trim(GetBrokers.Broker_Name)#</OPTION></CFOUTPUT>
						</SELECT>	
					</TD>					
					<cfparam name="CustomerPO" default="">
					<td valign="top"><span ID="searchItemLabel">Customer PO</span><BR>
					&nbsp; <input type="text" name="CustomerPO" STYLE="WIDTH:203px" SIZE="10" <cfif len(trim(CustomerPO)) GT 0>value="<cfoutput>#trim(CustomerPO)#</cfoutput>"</cfif>> 
					</td>
			</TR>
			<TR>
					<TD COLSPAN="4" NOWRAP>
					<img src="../../Images/fill.gif" width="1" height="3" alt="" border="0"><br>
						Name <INPUT TYPE="Text" NAME="searchstring" STYLE="WIDTH:405px" SIZE="57"<CFIF len(trim(searchstring)) GT 0>VALUE="<CFOUTPUT>#trim(searchstring)#</CFOUTPUT>" <cfif highlight IS 1>style="background: lightsteelblue;"</cfif></CFIF>>
				<!------<INPUT TYPE="Submit" VALUE="search">----->
						<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
					</TD>
					
			</TR>
			
			<tr><td colspan="100%"><hr width="100%" color="orange"></tr>
			<!---End Distributor Criteria--->
			<tr>
			<td rowspan="100%" valign="Center">
			
			<!---Start Invoice criteria--->
			<strong>Invoice<br> Criteria</strong>
			</td>
							<TD NOWRAP ALIGN="left" colspan="1">
					Invoice Number	<br>	
					<INPUT TYPE="Text" NAME="invoicenumber" STYLE="WIDTH:203px" SIZE="26"<CFIF len(trim(invoicenumber)) GT 0>VALUE="<CFOUTPUT>#trim(invoicenumber)#</CFOUTPUT>"</CFIF>>			
					</TD>
					<TD NOWRAP ALIGN="left" colspan="2">
					<table border="0" cellpadding="0" cellspacing="0">
					<tr><td colspan="3">Date</td></tr>
					
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
				
				<td>
				<CFSET Date_Operators=" ,>=,=,<=">
				<CFSET Date_Operator_Symbols=" ,>=,=,<=">
				<cfoutput>
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
				</cfoutput>
				</td>
				</tr>
					</table>
									
					</TD>
					<TD ALIGN="center" valign="center" NOWRAP>
					&nbsp; &nbsp; 
					<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="reset_form();">reset</a><FONT COLOR="#FF0000">]</FONT></B>
					<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10">
					&nbsp;&nbsp;
					<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript:document.searchinvoices.submit();">search invoices</a><FONT COLOR="#FF0000">]</FONT></B>
					</TD>
			</tr>

			</TABLE>

<CFIF DOSEARCH EQ 1>
<!------ Get application settings ----->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

	<CFSET form.searchstring = trim(form.searchstring)>
 	<CFQUERY NAME="TheQuery" DATASOURCE="#application.datasource#">
SELECT DISTINCT (Invoice_Header.Invoice_Version + '-' + Invoice_Header.Order_Number) AS Invoice_Number, Invoice_Header.BSA_Foodservice_Customers_ID AS Distributor_ID, Invoice_Header.shared_invoice_number, Invoice_Header.Invoice_Date, Invoice_Header.Invoice_Header_ID, BSA_Foodservice_Customers.Name, Invoice_Header.Original_Shared_Ship_To, Invoice_Header.Purchase_Order, (Select SUM(cast(Invoice_Detail.Sales_Dollars as float)) From Invoice_Detail WHERE Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID) AS Total_Dollars
FROM Invoice_Header 

	INNER JOIN BSA_Foodservice_Customers ON 
	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID =
	Invoice_Header.BSA_Foodservice_Customers_ID
	INNER JOIN Invoice_Detail
	ON Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
WHERE Invoice_Header.BSA_Foodservice_Customers_ID
IN
(
SELECT	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
FROM 	BSA_Foodservice_Customers 
INNER JOIN	Distributor_Family ON BSA_Foodservice_Customers.Family_ID = Distributor_Family.Family_ID 
<cfif appSettings.getDistributorMultiPosition()>
INNER JOIN Market_Distributor
ON	Market_Distributor.Deleted = 0
AND Market_Distributor.Distributor_ID = BSA_FoodService_Customers.BSA_FoodService_Customers_ID
INNER JOIN Service_Markets
ON	Service_Markets.Service_market_ID = Market_Distributor.Service_market_ID
INNER JOIN Service_Regions
ON	Service_Markets.Service_Region_ID = Service_Regions.Service_Region_ID
</cfif>
INNER JOIN	BSA_Foodservice_Brokers ON 
			<cfif appSettings.getDistributorMultiPosition()>
			BSA_Foodservice_Customers.Service_Market_ID = Service_Markets.Service_Market_ID 
			<cfelse>
			BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID 
			</cfif>
WHERE 0 = 0 
AND BSA_Foodservice_Customers.DELETED = 0 
		
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

	<!--- Distributor Status --->
	<CFIF FORM.Distributor_Status NEQ 0>
		AND dbo.BSA_Foodservice_Customers.Active_Code = '#FORM.Distributor_Status#'
	</CFIF>
	
	<!--- Zone --->
	<CFIF FORM.Zone_ID NEQ 0>	
		AND 
		<cfif appSettings.getDistributorMultiPosition()>
		Service_Regions.Service_Zone_ID
		<cfelse>
		BSA_Foodservice_Brokers.Service_Zone_ID
		</cfif>
		 = '#FORM.Zone_ID#'
	</CFIF>

	<!--- Region --->
	<CFIF FORM.Region_ID NEQ 0>
		AND 
		<cfif appSettings.getDistributorMultiPosition()>
		Service_Regions.Service_Region_ID
		<cfelse>
		BSA_Foodservice_Brokers.Service_Region_ID
		</cfif>
		 = '#FORM.Region_ID#'
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
	BSA_Foodservice_Customers.Name LIKE '%#form.searchstring#%'
	OR BSA_Foodservice_Customers.City LIKE '%#form.searchstring#%'
	OR Distributor_Family.Family_Name LIKE '%#form.searchstring#%'
	<CFIF isnumeric(form.searchstring)>
	OR BSA_Foodservice_Customers.Shr_Family LIKE '%#form.searchstring#%'
	</CFIF>
	OR BSA_Foodservice_Brokers.Broker_Name LIKE '%#form.searchstring#%'
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
		AND Invoice_Header.Deleted = 0
		ORDER BY Invoice_Header.#sort_by# #sort_order#
		
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

	<FIELDSET STYLE="padding:8px; border: 1px solid Blue; width:855px" >
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.recordcount EQ 1>is<CFELSE>are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1>invoice<CFELSE>invoices</CFIF> that <CFIF TheQuery.recordcount EQ 1>matched<CFELSE>match</CFIF> the above criteria</LEGEND>

<br>
<cfparam name="AlreadySelected" default="">
<cfif Source IS "Deductions">
	<cfset useLakebaseForAlreadySelectedItems = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_relationships")>
<cfif useLakebaseForAlreadySelectedItems>
<cftry>
<cfset AlreadySelectedItems = application.oLakebase.toQuery(
application.oLakebase.selectRows("dd_relationships", {
"select" = "dd_key_to_relationship",
"deduction_id" = "eq.#Deduction_ID#",
"dd_relationship_type_id" = "eq.3"
}),
"dd_key_to_relationship"
)>
<cfcatch type="any">
<cfset useLakebaseForAlreadySelectedItems = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForAlreadySelectedItems><cfquery name="AlreadySelectedItems" datasource="#application.datasource#">
	SELECT DISTINCT DD_Key_To_Relationship
	FROM DD_Relationships
	WHERE Deduction_ID = '#Deduction_ID#'
	AND DD_Relationship_Type_ID = 3
	</cfquery>
</cfif>

	<cfset AlreadySelected =  listqualify(valuelist(AlreadySelectedItems.DD_Key_To_Relationship), chr(39))>
</cfif>

		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>
			<TABLE border="0" cellspacing="0" cellpadding="3" WIDTH="855px" CLASS="Maintable">
				<TR ID="header" BGCOLOR="#ffce84">
				<cfif Return_Value IS 1><td><!--- <input TYPE="checkbox" NAME="checkall" ONCLICK="selectAll();"> ---></cfif></td>
									<cfoutput>
				<!---Include shared invoice--->					
				<cfif application.returned_customer_setting.shared_invoice IS 1>
				<CFSET HeaderNameList = "Invoice Number, Customer PO, #application.returned_customer_setting.distributor_label_singular#, Invoice Date, Legacy Invoice ##, Total $">
				<CFSET HeaderColumnList = "Invoice_Number,Purchase_Order,Name,Invoice_Date,Shared_Invoice_Number,Total_Dollars">
				<!---Exclude shared invoice--->
				<cfelse>
				<CFSET HeaderNameList = "Invoice Number, Customer PO, #application.returned_customer_setting.distributor_label_singular#, Invoice Date, Total $">
				<CFSET HeaderColumnList = "Invoice_Number,Purchase_Order,Name,Invoice_Date,Total_Dollars">
				</cfif>
				
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
			 <cfset HeaderReplaced = replace(TheQuery.Invoice_Header_ID, '-', '_', "all")>
			
				<TR STYLE="cursor:pointer;" <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
					<cfif return_value IS 1><td><span ID="checkallReasons"><input TYPE="radio" NAME="selectedReasons" value="#HeaderReplaced#" ONCLICK="if(!this.checked) document.all.checkall.checked = false;"  <cfif Listcontains(AlreadySelected, TheQuery.Invoice_Header_ID, ",")> Checked</cfif> ></span></td></cfif>
					<TD onclick="NewWindow('/search_Screens/invoice/invoice_detail.cfm?Invoice_Header_ID=#Invoice_Header_ID#','#trim(Shared_Invoice_Number)#','850','600','Yes', 'Yes');return false;" NOWRAP><strong><font color="Red">[</font> <font color="blue">#Shared_Invoice_Number#&nbsp;</font><font color="red">]</font></strong></TD>
<TD onclick="NewWindow('/search_Screens/invoice/invoice_detail.cfm?Invoice_Header_ID=#Invoice_Header_ID#','#trim(Shared_Invoice_Number)#','850','600','Yes', 'Yes');return false;" NOWRAP>&nbsp; &nbsp; &nbsp; #Purchase_Order#&nbsp; </TD>
					<TD onclick="NewWindow('/search_Screens/invoice/invoice_detail.cfm?Invoice_Header_ID=#Invoice_Header_ID#','#trim(Shared_Invoice_Number)#','850','600','Yes', 'Yes');return false;" NOWRAP>#Name#&nbsp; </TD>
					<TD onclick="NewWindow('/search_Screens/invoice/invoice_detail.cfm?Invoice_Header_ID=#Invoice_Header_ID#','#trim(Shared_Invoice_Number)#','850','600','Yes', 'Yes');return false;" NOWRAP>#DateFormat(Invoice_Date, 'MMM DD, YYYY')#&nbsp;</TD>

<!---Only show this field if the customer uses a shared invoice number--->
<cfif application.returned_customer_setting.shared_invoice IS 1>
					<TD onclick="NewWindow('/search_Screens/invoice/invoice_detail.cfm?Invoice_Header_ID=#Invoice_Header_ID#','#trim(Shared_Invoice_Number)#','850','600','Yes', 'Yes');return false;" NOWRAP>#Invoice_Number#&nbsp; </TD>
</cfif>
<TD onclick="NewWindow('/search_Screens/invoice/invoice_detail.cfm?Invoice_Header_ID=#Invoice_Header_ID#','#trim(Shared_Invoice_Number)#','850','600','Yes', 'Yes');return false;" NOWRAP align="right"><cfif isNumeric(Total_Dollars)>#LSCurrencyFormat(Total_Dollars)#<cfelse>$0.00</cfif>&nbsp;</TD>
 				</TR> 
			</CFOUTPUT>
			
			<cfif return_value IS 1 AND source IS "Deductions"><tr><td colspan="100%" align="center"><a HREF="#" onClick="javascript: javascript: finishedSearching()">[ add to deduction ]</a></tr></cfif>

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
<input type="hidden" name="source" value="#source#">
<input type="hidden" name="return_value" value="#return_value#">
<cfif source IS "Deductions">
<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
</cfif>
</CFOUTPUT>
<INPUT TYPE="Hidden" NAME="startrow" VALUE="1">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="1">
<input type="hidden" name="finishedselecting" value="">


</FORM>


</blockquote>
<BLOCKQUOTE><BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>

</BODY>
</HTML>