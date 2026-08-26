<cfparam name="fromSettings_management" default=0>
<CFIF fromSettings_management neq 1> <!--- start :: cfif fromSettings_management neq 1 :: 1 ::Settings Management page 41974--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
</head>
<body <cfif Generic_Type IS NOT "Brokerage">onLoad="return CheckCriteria()"</cfif>>
<!----
/Program_Wizard/secondpage.cfm

Created By: Brenda Flynn
			bflynn@awayx.com
Created On: May 5, 2003
			Happy Cinco de Mayo!
Modified By:
Last Modified On:
-----------------------------

Populates Rate, Discount Type, Claim and Payment Cycle information..

--->
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<cfset displayheader = 1 >

<cfset appSettings = application.appsettingsGet />
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFIF Get_Profile_Settings.Settings_Panel LT 1>
	<CFLOCATION URL="/Manufacturers/home.cfm" ADDTOKEN="yes">
</CFIF>
<cfinclude template="/Common_Files/jQuery.cfm">

<cfparam name="error_PerformanceReq" default="0">
<cfparam name="error_RateType" default="0">
<cfparam name="error_ClaimMech" default="0">
<cfparam name="error_Currency" default="0">
<cfparam name="error_PayOption" default="0">
<cfparam name="error_DiscountType" default="0">
<cfparam name="error_PayOption" default="0">
<cfparam name="DefaultProduct" default="">
<cfparam name="Form.RedirectBack" default="0">
<cfparam name="Form.Group_Deal" default="0">
<cfparam name="form.program_spending_type" default="0">
<cfparam name="form.lumpsum_spending_type" default="0">
<cfparam name="form.price_protection_on" default="0">
<cfparam name="Discount_Lump_Sums" default="0" />

<!---Scopes url variables--->
<cfif IsDefined("form.Generic_Type")>
	<cfset Error = 0>
	<cfset Generic_Type = form.Generic_Type>
<cfelseif IsDefined("url.Generic_Type")>
	<cfset Generic_Type = url.Generic_Type>
<cfelse>
	<cfset Error = 1>
	<cfset Error_Message = "You did not select a generic type.">
</cfif>
<!---Scopes url variables--->
<cfif IsDefined("form.Created_Type")>
	<cfset Error = 0>
	<cfset Created_Type = form.Created_Type>
<cfelseif IsDefined("url.Created_Type")>
	<cfset Created_Type = url.Created_Type>
<cfelse>
	<cfset Error = 1>
	<cfset Error_Message = "You did not select a name.">
</cfif>

<cfif IsDefined("form.ID")>
	<cfset ID = form.ID>
<cfelseif IsDefined("url.ID")>
	<cfset ID = url.ID>
<cfelse>
	<cfset ID = 0>
</cfif>

<cfset url.ID = ID />
<cfset templateMgmtSettingsSecPage = CreateObject("component", "components.settings.settings_management.TemplateSettingsManager").getTemplateMgmtSettingsSecPage(Generic_Type,ID)>

<cfset Active = "">

<!---TSF: Label 9826 - Error handle if Generic_Type isn't defined--->
<cfif not isDefined("Generic_Type")>
	<span style="font-size:medium;color:FF0000">Unable to Idenfify Template Generic Type</span>
	<br />
	<br />
	<CF_smallLink
		title = "program wizard"
		url = "index.cfm"
	>
	<cfabort>
</cfif>

<cfset OperatorBid = false>
<cfif Generic_Type EQ  "Operator Bids">
	<cfset OperatorBid = true>
</cfif>

<cfquery name="SelectSecondary" datasource="#application.datasource#">
	SELECT 	*
	FROM 	Program_Control_Panel_Options
	WHERE 	ProgramControl_Panel_Options_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
</cfquery>

<cfset EZButton_On = SelectSecondary.EZButton_On />
<!---Queries if the record is being edited--->
<cfif Action IS "Edit">
	<!---Available in the data mode:
		RateTypeOption4 - RateTypeOption8
	--->
	<cfset Active = SelectSecondary.Active>
	<cfset Created_Type = SelectSecondary.Created_Type>
	<cfset Form.Group_Deal = SelectSecondary.Group_Deal />
	<cfset form.Program_Spending_Type = SelectSecondary.Program_Spending_Type />
	<cfset form.Lumpsum_Spending_Type = SelectSecondary.Lumpsum_Spending_Type />
	<cfset form.price_protection_on = SelectSecondary.price_protection_on>
</cfif>
<cfparam name="EZBUTTON_ON" default="0">

<!---Queries if the record is being edited--->

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFIF Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 0>
	<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
</CFIF>

<cfset PAGE_TITLE = "Create or Edit a Program Type">

<!--- <html>
<head>
	<title><cfoutput>#PAGE_TITLE#</cfoutput></title>
 --->

	<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	.header {font-size: 12px;}

	.no_comment_input
		{
			border:			1px solid silver;
			color:			Navy;

		}
	.cellLeftBorder { border-left:solid #000000 1px; }
	.noBorder { border: 0; }

	#outerTable th  {font:bold 14px; text-align: left; color:black; padding:7px 0 15px 0;}
	.er73 {font:normal 13px; color:red;}
	.sh42 {font:bold 11px Tahoma !important; color:#6C6679}
	#segmentTable td {background-color: #eeeeee}
	#bigTable th, #segmentTable th  {font:bold 14px; text-align: left; color:3300cc; padding:7px 0 15px 0;}
	#bigTable tr { padding-bottom: 6px;}
	.il52 { padding-left:13px; vertical-align: top;}
	.wd94 {width:94%;}
	.wd70 {width:66%;}
	.rd25 {width:30%; display:inline-block;}
	.rd30 {width:35%; display:inline-block;}
	.td50 {width:50%; display:inline-block;}
	.td72 {width:72%; display:inline-block;}
	.td80 {width:80%; display:inline-block;}
	</style>

	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>

<script>

	function showHideGroupProgramsUOM(thisObj)
	{
		var trObj1 = document.all.tr1_GroupProgramsUOM;
		var trObj2 = document.all.tr2_GroupProgramsUOM;
		var trObj3 = document.all.tr3_GroupProgramsUOM;
		var trObj4 = document.all.tr4_GroupProgramsUOM;

		if(thisObj.checked)
		{
			trObj1.style.display = "";
			trObj2.style.display = "";
			trObj3.style.display = "";
			trObj4.style.display = "";
		}
		else
		{
			trObj1.style.display = "none";
			trObj2.style.display = "none";
			trObj3.style.display = "none";
			trObj4.style.display = "none";
		}
	}

	function minPerformanceRequirements()
	{

		for (i = 0; i < document.all.minPerfRequirementsOn.length; i++)
		{
		 	 if (document.all.minPerfRequirementsOn[i].checked)
			 {
				 if (document.all.minPerfRequirementsOn[i].value == '0')
				 {
				 	document.all.minPerfRequirements.value = '0';
				 	document.all.minPerfRequirements.disabled = true;
				 }
				 else
		     	 {
				    document.all.minPerfRequirements.value = '1';
				 	document.all.minPerfRequirements.disabled = false;
		         }
			 }

		}
	 }

	 function maxPerformanceRequirements()
	{

		for (i = 0; i < document.all.maxPerfRequirementsOn.length; i++)
		{
		 	 if (document.all.maxPerfRequirementsOn[i].checked)
			 {
				 if (document.all.maxPerfRequirementsOn[i].value == '0')
				 {
				 	document.all.maxPerfRequirements.value = '*';
				 	document.all.maxPerfRequirements.disabled = true;
				 }
				 else
		     	 {
				 document.all.maxPerfRequirements.disabled = false;
		         }
			 }

		}
	 }

	function DefaultGroupUOM(thisObjval)
	{
		var thisSubObj	=	document.getElementById("Groups_UOM_Default_" + thisObjval);
		var DiffUOM		=	document.all.Group_Programs_UOM.checked;

		if (DiffUOM){}
		else{
			thisSubObj.checked = true;
		} // end : if (DiffUOM){}
	}

	function selectGroupUOM(thisObj)
	{
		var thisObjName		=	thisObj.name;
		var thisObjchk		=	thisObj.checked;
		var DiffUOM			=	document.all.Group_Programs_UOM.checked;

		if (DiffUOM){}
		else
		{
			if (thisObjName == "RateTypeOption_2"){
				UOM_checker("Groups_UOM_1", thisObjchk)
			}
			else if (thisObjName == "RateTypeOption_1"){
				UOM_checker("Groups_UOM_2", thisObjchk)
			}
			else if (thisObjName == "RateTypeOption_3"){
				UOM_checker("Groups_UOM_3", thisObjchk)
			} //end : thisObjName
		} // end : if (DiffUOM){}
	}

	function UOM_checker(thisObj,thisObjchk){

		var formObj		=	document.getElementById(thisObj);
		var formObjChk 	= 	formObj.checked;

		if(thisObjchk){
			formObj.checked = true;
		}
		else{
			formObj.checked = false;
		}
	}


function changeDisableOtherCheckBoxes(thisObj, OtherObj)
{
	OtherObj.disabled = !(thisObj.checked);
}

function isDefined(item) {
	return (typeof item != 'undefined');
}

var ErrorCount = 0;
function confirmCompletion()
{
	var ErrorCount = 0;
  var errorGBDefault = 0;
		<cfif Generic_Type IS NOT "USDA NOI">
		<cfif OperatorBid EQ false>
			<cfif form.price_protection_on EQ 1>
				/*
				if(document.all.RateTypeOption_1.checked == true)
				{
					ErrorCount++;
					queueMessage("You cannot select LB as UOM when price protection is on.", document.all.error_RateTypeOption_1);
				}
				else
				{
					clearQueue(document.all.error_RateTypeOption_1);
				}
				*/
				if (isDefined(document.all.RateTypeOption_3))
				{
					if(document.all.RateTypeOption_3.checked == true)
					{
						ErrorCount++;
						queueMessage("You cannot select % as UOM when price protection is on.", document.all.error_RateTypeOption_3);
					}
					else
					{
						clearQueue(document.all.error_RateTypeOption_3);
					}
			}
			</cfif>
		<!---Rate Type--->
		<cfif Generic_Type NEQ "LSAutoPay">
			if(document.all.RateTypeDefault[0].checked && document.all.RateTypeOption_1.checked == false)
			{
				ErrorCount++;
				queueMessage("To set an item as default, you must choose to include it.", document.all.error_RateTypeOption_1);
			}
			else
			{
				clearQueue(document.all.error_RateTypeOption_1);
			}

			if(document.all.RateTypeDefault[1].checked && document.all.RateTypeOption_2.checked == false)
			{
				ErrorCount++;
				queueMessage("To set an item as default, you must choose to include it.", document.all.error_RateTypeOption_2);
			}
			else
			{
				clearQueue(document.all.error_RateTypeOption_2);
			}

				<cfif (Generic_Type IS "Distributor Off-Invoice" OR Generic_Type IS "Distributor Trade/Shelter") and EZButton_On EQ 0>
				if(document.all.RateTypeDefault[2].checked && document.all.RateTypeOption_3.checked == false)
				{
					ErrorCount++;
					queueMessage("To set an item as default, you must choose to include it.", document.all.error_RateTypeOption_3);
				}
				else
				{
					clearQueue(document.all.error_RateTypeOption_3);
				}
				</CFIF>

			/*
			if(document.all.RateTypeOption_2.checked == false && document.all.RateTypeOption_1.checked == false)
			{
				ErrorCount++;
				queueMessage("Please include either cases or pounds as an option for every template", document.all.error_RateTypeDefault);
			}
			else
			{
				clearQueue(document.all.error_RateTypeDefault);
			}

			*/
			// if(document.all.Discount_Fixed_Prices)
			//  If Fixed is ON OR % is not available then we require CS OR LB to Be selected.
			// D32010:JS error - Discount_Fixed_Prices.checked' is null or not an object
			if((document.all.Discount_Fixed_Prices && document.all.Discount_Fixed_Prices.checked == true) || (document.all.Fixed_Rebate_Grid_Option && document.all.Fixed_Rebate_Grid_Option.checked == true) || isDefined(document.all.RateTypeOption_3) == false)
			{
				if(document.all.RateTypeOption_2.checked == false && document.all.RateTypeOption_1.checked == false){
					ErrorCount++;
					//conditional message
					if(isDefined(document.all.RateTypeOption_3) == false){
						queueMessage("Please include a Unit of Measure option", document.all.error_RateTypeDefault);
					}
					else{
						queueMessage("Please include either cases or pounds as a Unit of Measure option when Fixed Price Discount Type is turned on", document.all.error_RateTypeDefault);
					}
				}
				else{
					clearQueue(document.all.error_RateTypeDefault);
				}
			}
			else // % is an option so we can check for it
			{
				if (document.all.RateTypeOption_2.checked == false && document.all.RateTypeOption_1.checked == false && document.all.RateTypeOption_3.checked == false) {
					ErrorCount++;
					queueMessage("Please include a Unit of Measure option", document.all.error_RateTypeDefault);
				}
				else{
					clearQueue(document.all.error_RateTypeDefault);
				}
			}


		</cfif>

		<cfif Generic_Type IS "Distributor Off-Invoice">

			 if 	((document.all.Min_OffInvoice_Pound.value > document.all.Max_OffInvoice_Pound.value) && (document.all.Max_OffInvoice_Pound.value != ""))
			{
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_OffInvoice_Pound);
			}
			else
			{
				clearQueue(document.all.error_OffInvoice_Case);
			}
		  if 	((document.all.Min_OffInvoice_Case.value > document.all.Max_OffInvoice_Case.value) && (document.all.Max_OffInvoice_Case.value != ""))
			{
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_OffInvoice_Case);
			}
			else
			{
				clearQueue(document.all.error_OffInvoice_Case);
			}
			 if 	((document.all.Min_OffInvoice_Percent.value > document.all.Max_OffInvoice_Percent.value) && (document.all.Max_OffInvoice_Percent.value != ""))
			{
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_OffInvoice_Percent);
			}
			else
			{
				clearQueue(document.all.error_OffInvoice_Percent);
			}
		<!---Generic type is off invoice--->
		</cfif>

		<!------ ******** Bid Request ******** ----->
		<cfif Generic_Type IS "Bid Request">
			 if 	((document.all.Min_BidRequest_Pound.value > document.all.Max_BidRequest_Pound.value) && (document.all.Max_BidRequest_Pound.value != ""))
			{
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_BidRequest_Pound);
			}
			else
			{
				clearQueue(document.all.error_BidRequest_Case);
			}
			if 	((document.all.Min_BidRequest_Case.value > document.all.Max_BidRequest_Case.value) && (document.all.Max_BidRequest_Case.value != ""))
			{
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_BidRequest_Case);
			}
			else
			{
				clearQueue(document.all.error_BidRequest_Case);
			}

			<!------ check if the default for line item is included ----->
			<cfif SelectSecondary.BidRequestStatusOn IS 1>
			var Chk_Bid_Line_Item_Option_Default = document.all.Bid_Line_Item_Option_Default;
			var Chk_Line_Item_On = document.all.Line_Item_On;
			var defautIsWrong = false;
			if(Chk_Bid_Line_Item_Option_Default[0].checked == true && Chk_Line_Item_On[0].checked == false && Chk_Line_Item_On[1].checked == true)
			{
				defautIsWrong = true;
			}
			if(Chk_Bid_Line_Item_Option_Default[1].checked == true && Chk_Line_Item_On[1].checked == false && Chk_Line_Item_On[0].checked == true)
			{
				defautIsWrong = true;
			}
			if(defautIsWrong)
			{
				ErrorCount++;
				queueMessage("To set a line item as default, Please choose to include it", document.all.error_Bid_Line_Item_Option_Default);
			}
			else
			{
				clearQueue(document.all.error_Bid_Line_Item_Option_Default);
			}
			</cfif>

		<!---Generic type is Bid request--->
		</cfif>
		<!---NOI --->
		</cfif>
		<!---Generic type is bid request or off invoice--->
		</cfif>

		<cfset useLakebaseForGetCurrencyTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("currency")>
<cfif useLakebaseForGetCurrencyTypes>
	<cftry>
		<cfset GetCurrencyTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("currency", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "currency_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCurrencyTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCurrencyTypes>
<cfquery name="GetCurrencyTypes" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Currency
			WHERE 	Deleted = 0
			AND 	Active = 1
			ORDER BY Currency_Name
		</cfquery>
</cfif>
		<cfset DefaultValue2 = 0>

		<cfset NoDefaultValue2 = GetCurrencyTypes.Recordcount>
		anyCurrencySelection = 0;
		currencyDefaultSelectionWrong = 0;

	<cfoutput query="GetCurrencyTypes">

		if((document.all.CurrencyDefaultOption[#DefaultValue2#].checked) == true && document.all.Currency_#Currency_ID#.checked == false)
		{
			currencyDefaultSelectionWrong++;
		}

		if(document.all.Currency_#Currency_ID#.checked == true)
		{
			anyCurrencySelection++;
		}

		<cfset DefaultValue2 = DefaultValue2 + 1>
	</cfoutput>
		<!------ atleast one Currency option should be selected ----->
		if(anyCurrencySelection == 0)
		{
			ErrorCount++;
			queueMessage("Please include at least one currency option.", document.all.error_Currency_Selection);
		}
		else
		{
			clearQueue(document.all.error_Payment_Type_Selection);
		}
		<!------ if a currrency is set as default, it must be selected ----->
		if(currencyDefaultSelectionWrong != 0)
		{
			ErrorCount++;
			queueMessage("If a currency is set as default, it must be selected.", document.all.error_Currency_Selection);
		}
		else
		{
			clearQueue(document.all.error_Payment_Type_Selection);
		}
	<cfif Generic_Type IS NOT "Distributor Off-Invoice" AND Generic_Type NEQ "LSAutoPay">

		<cfset useLakebaseForGetPaymentTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_type")>
<cfif useLakebaseForGetPaymentTypes>
	<cftry>
		<cfset GetPaymentTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payment_type", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "payment_type_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetPaymentTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetPaymentTypes>
<cfquery name="GetPaymentTypes" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Payment_Type
			WHERE 	Deleted = 0
			AND 	Active = 1
			ORDER BY Payment_Type_Name
		</cfquery>
</cfif>

		<cfset DefaultValue = 0>

		<cfset NoDefaultValue = GetPaymentTypes.Recordcount>
		anyPaymentTypeSelection = 0;
		paymentTypeDefaultSelectionWrong = 0;

		<cfoutput query="GetPaymentTypes">

			<!--- If there's only one record, it will return an error with normal nomenclature because there is no array --->
			<cfif GetPaymentTypes.recordcount GT 1>
			if(document.all.ClaimMechDefaultOption[#DefaultValue#].checked && document.all.Payment_Type_#Payment_Type_ID#.checked == false)
			{
				paymentTypeDefaultSelectionWrong++;
			}
			<cfelse>
			if(document.all.ClaimMechDefaultOption.checked && document.all.Payment_Type_#Payment_Type_ID#.checked == false)
			{
				paymentTypeDefaultSelectionWrong++;
			}

			</cfif>

			if(document.all.Payment_Type_#Payment_Type_ID#.checked == true)
			{
				anyPaymentTypeSelection++;
			}

			<cfset DefaultValue = DefaultValue + 1>
		</cfoutput>

	<!------ atleast one payment type option should be selected ----->
	if(anyPaymentTypeSelection == 0)
	{
		ErrorCount++;
		queueMessage("Please include at least one claim mechanic", document.all.error_Payment_Type_Selection);
	}
	else
	{
		clearQueue(document.all.error_Payment_Type_Selection);
	}

	<!------ to select as default, that item should be selected ----->
	if(paymentTypeDefaultSelectionWrong)
	{
		ErrorCount++;
		queueMessage("To set an item as default, you must choose to include it. ", document.all.error_Payment_Type_Default);
	}
	else
	{
		clearQueue(document.all.error_Payment_Type_Default);
	}

<!--- 	Payment paid To --->
		<cfquery name="GetPaymentPaidToTypes" datasource="#application.datasource#">
					SELECT 	*
					FROM 	Payment_Paid_To_Types
					WHERE 	Deleted = 0
					<cfif Generic_Type IS "Brokerage" > and	Payment_Paid_To_ID = 3 </cfif>
					ORDER BY Payment_Paid_To_ID
		</cfquery>

		<cfset DefaultValue = 0>
		<cfset NoDefaultValue = GetPaymentPaidToTypes.Recordcount>

		<cfoutput query="GetPaymentPaidToTypes">
		<cfif GetPaymentPaidToTypes.Recordcount EQ 1>
		if(document.all.PaidToDefaultOption.checked && document.all.Payment_Paid_To_Type_#Payment_Paid_To_ID#.checked == false)
		<cfelse>
		if(document.all.PaidToDefaultOption[#DefaultValue#].checked && document.all.Payment_Paid_To_Type_#Payment_Paid_To_ID#.checked == false)
		</cfif>
		{
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it. ", document.all.error_Payment_Paid_To_Type_Default);
		}
		else
		{
			clearQueue(document.all.error_Payment_Paid_To_Type_Default);
		}

		<cfset DefaultValue = DefaultValue + 1>
		</cfoutput>


		<!---Payment Frequency--->

		if(document.all.PayCycleOption_1.checked == false && document.all.PayCycleOption_2.checked == false && document.all.PayCycleOption_3.checked == false && document.all.PayCycleOption_4.checked == false && document.all.PayCycleOption_5.checked == false && document.all.PayCycleOption_6.checked == false && document.all.PayCycleOption_7.checked == false && document.all.PayCycleOption_8.checked == false && document.all.PayCycleOption_9.checked == false && document.all.PayCycleOption_10.checked == false && document.all.PayCycleOption_11.checked == false)
<!---NOTE: Please also add logic into activate.cfm -- it checks to make sure this is all in order before allowing the template to be activated --->
		{
			ErrorCount++;
			queueMessage("Please include at least one payment cycle", document.all.error_PayCycleOption_1);
		}
		else
		{
			clearQueue(document.all.error_PayCycleOption_1);
		}

		if(document.all.PayCycleDefaultOption[0].checked && document.all.PayCycleOption_1.checked == false)
		{
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_1);
		}
		else
		{
			clearQueue(document.all.error_PayCycleOption_1);
		}

		if(document.all.PayCycleDefaultOption[1].checked && document.all.PayCycleOption_2.checked == false)
		{
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_2);
		}
		else
		{
			clearQueue(document.all.error_PayCycleOption_2);
		}

		if(document.all.PayCycleDefaultOption[2].checked && document.all.PayCycleOption_3.checked == false)
		{
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_3);
		}
		else
		{
			clearQueue(document.all.error_PayCycleOption_3);
		}

		if(document.all.PayCycleDefaultOption[3].checked && document.all.PayCycleOption_4.checked == false)
		{
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_4);
		}
		else
		{
			clearQueue(document.all.error_PayCycleOption_4);
		}

		if(document.all.PayCycleDefaultOption[4].checked && document.all.PayCycleOption_5.checked == false)
		{
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_5);
		}
		else
		{
			clearQueue(document.all.error_PayCycleOption_5);
		}

		if(document.all.PayCycleDefaultOption[5].checked && document.all.PayCycleOption_6.checked == false)
		{
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_6);
		}
		else
		{
			clearQueue(document.all.error_PayCycleOption_6);
		}

		if(document.all.PayCycleDefaultOption[6].checked && document.all.PayCycleOption_7.checked == false)
		{
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_7);
		}
		else
		{
			clearQueue(document.all.error_PayCycleOption_7);
		}
		if(document.all.PayCycleDefaultOption[7].checked && document.all.PayCycleOption_8.checked == false)
		{
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_8);
		}
		else
		{
			clearQueue(document.all.error_PayCycleOption_8);
		}
		if(document.all.PayCycleDefaultOption[8].checked && document.all.PayCycleOption_9.checked == false)
		{
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_9);
		}
		else
		{
			clearQueue(document.all.error_PayCycleOption_9);
		}
		if(document.all.PayCycleDefaultOption[9].checked && document.all.PayCycleOption_10.checked == false)
		{
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_10);
		}
		else
		{
			clearQueue(document.all.error_PayCycleOption_10);
		}
		if(document.all.PayCycleDefaultOption[10].checked && document.all.PayCycleOption_11.checked == false)
		{
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_11);
		}
		else
		{
			clearQueue(document.all.error_PayCycleOption_11);
		}
			//TSF: Modification Bid Request
			//validate for discount types only if it's not bid request
	<cfif Generic_Type IS NOT "Bid Request" AND Generic_Type IS NOT "USDA NOI" AND Generic_Type NEQ "LSAutoPay">
		<cfif Generic_Type IS NOT "Brokerage" AND EZButton_On eq 0>
			<cfif EZButton_On EQ 0>
				if(document.all.Discount_Fixed_Prices.checked == false && document.all.Discount_Rebates.checked == false && document.all.Discount_Lump_Sums.checked == false && document.all.Discount_Growth.checked == false && document.all.Discount_Formula_Pricing.checked == false && document.all.Fixed_Rebate_Grid_Option == false<cfif application.bidPricingLinksAvailable> && document.all.Bid_Rule_Option.checked == false</cfif>)
			<cfelse>
				if(document.all.Discount_Fixed_Prices.checked == false && document.all.Discount_Rebates.checked == false && document.all.Discount_Lump_Sums.checked == false)
			</cfif>
				{
					ErrorCount++;
					queueMessage("Please include at least one discount type", document.all.error_Discount_Fixed_Prices);
				}
				else
				{
					clearQueue(document.all.error_Discount_Fixed_Prices);
				}
		</cfif><!--- Not Brokerage  --->
		<cfif appsettings.gettemplatecodes_on()>
		<cfif generic_type NEQ 'Direct Pricing'AND Generic_Type NEQ "Brokerage" AND Generic_Type NEQ "LSAutoPay">
			if ((document.all.Discount_Rebates.checked ==  true || document.all.Discount_Growth.checked ==  true)  && document.all.Program_Spending_Type.value == 0)
			{
				ErrorCount++;
				queueMessage("Please select a Program Spending Type", document.all.error_program_spending_type);
			}
			else
			{
				clearQueue(document.all.error_program_spending_type);
			}
			if (document.all.Discount_Lump_Sums.checked ==  true  && document.all.Lumpsum_Spending_Type.value == 0)
			{
				ErrorCount++;
				queueMessage("Please select a Lumpsum Spending Type", document.all.error_lumpsum_spending_type);
			}
			else
			{
				clearQueue(document.all.error_lumpsum_spending_type);
			}
		</cfif><!--- Not Brokerage and Not Direct Pricing --->


			<!---Mins can't be bigger than maxes--->
			<cfif Generic_Type IS NOT "Brokerage" AND Generic_Type NEQ "LSAutoPay">
			<!---Fixed pound--->
			if ((document.all.Min_Fixed_Pound.value > document.all.Max_Fixed_Pound.value) && (document.all.Max_Fixed_Pound.value != ""))
			{
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_Fixed_Pound);
			}
			else
			{
				clearQueue(document.all.error_Fixed_Pound);
			}

			<!---Fixed case--->
			 if ((document.all.Min_Fixed_Case.value > document.all.Max_Fixed_Case.value) && (document.all.Max_Fixed_Case.value != ""))
			{
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_Fixed_Case);
			}
			else
			{
				clearQueue(document.all.error_Fixed_Case);
			}
			</cfif> <!--- Not Brokerage --->
		<cfif generic_type NEQ 'Direct Pricing' AND Generic_Type NEQ "LSAutoPay">
			<!---Rebate pound--->
			 if ((document.all.Min_Rebate_Pound.value > document.all.Max_Rebate_Pound.value) && (document.all.Max_Rebate_Pound.value != ""))
			{
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_Rebate_Pound);
			}
			else
			{
				clearQueue(document.all.error_Rebate_Pound);
			}

			<!---Rebate case--->
			 if ((document.all.Min_Rebate_Case.value > document.all.Max_Rebate_Case.value) && (document.all.Max_Rebate_Case.value != ""))
			{
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_Rebate_Case);
			}
			else
			{
				clearQueue(document.all.error_Rebate_Case);
			}

			<!---Rebate percent--->
			 if ((document.all.Min_Rebate_Percent.value > document.all.Max_Rebate_Percent.value) && (document.all.Max_Rebate_Percent.value != ""))
			{
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_Rebate_Percent);
			}
			else
			{
				clearQueue(document.all.error_Rebate_Percent);
			}
			<cfif Generic_Type IS NOT "Brokerage" >
			<!---Growth Pound--->
			 if ((document.all.Min_Growth_Pound.value > document.all.Max_Growth_Pound.value) && (document.all.Max_Growth_Pound.value != ""))
			{
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_Growth_Pound);
			}
			else
			{
				clearQueue(document.all.error_Growth_Pound);
			}

			<!---Growth Case--->
			 if ((document.all.Min_Growth_Case.value > document.all.Max_Growth_Case.value) && (document.all.Max_Growth_Case.value != ""))
			{
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_Growth_Case);
			}
			else
			{
				clearQueue(document.all.error_Growth_Case);
			}

			<!---Growth Percent--->
			 if ((document.all.Min_Growth_Percent.value > document.all.Max_Growth_Percent.value) && (document.all.Max_Growth_Percent.value != ""))
			{
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_Growth_Percent);
			}
			else
			{
				clearQueue(document.all.error_Growth_Percent);
			}

			<!---Formula Pound--->
			if ((document.all.Min_Formula_Pound.value > document.all.Max_Formula_Pound.value) && (document.all.Max_Formula_Pound.value != ""))
			{
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_Formula_Pound);
			}
			else
			{
				clearQueue(document.all.error_Formula_Pound);
			}

			<!---Formula Percent--->
			if ((document.all.Min_Formula_Percent.value > document.all.Max_Formula_Percent.value) && (document.all.Max_Formula_Percent.value != ""))
			{
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_Formula_Percent);
			}
			else
			{
				clearQueue(document.all.error_Formula_Percent);
			}
			</cfif> <!--- Not Brokerage --->
		</cfif>
		</cfif>
		<cfelseif Generic_Type IS "Bid Request">
			if( document.all.Discount_Rebates.checked == false && document.all.Discount_BidRequest.checked == false)
			{
				ErrorCount++;
				queueMessage("Please include at least one discount type", document.all.error_Discount_BidRequest_Prices);
			}
			else
			{
				clearQueue(document.all.error_Discount_BidRequest_Prices);
			}
		</cfif>
		</cfif>

    <cfif Generic_Type EQ "Operator-Deviated Pricing" or Generic_Type EQ "Operator Direct or HQ Programs">
	<!---
	D20321:Volume Applicator Test Results and Questions
	Operator templates should always have direct ship and billback options.
	Operator templates should never adjust for credit.
	--->
	<!---
      if (document.all.Operator_Off_Invoice_Volume.checked == false && document.all.Operator_Billback_Volume.checked == false)
      {
        ErrorCount++;
				queueMessage("Please select at least one item for Display", document.all.error_Volume_Selection);
      }
      else
      {
        if(document.all.Operator_Off_Invoice_Volume.checked == true)
        {
          if (document.all.Volume_Operator_Template_GroupB_Default[0].checked == true)
          {
            errorGBDefault = 1;
          }
        }
        if(document.all.Operator_Billback_Volume.checked == true)
        {
           if (document.all.Volume_Operator_Template_GroupB_Default[1].checked == true)
          {
            errorGBDefault = 1;
          }
        }
     }
	 	if (errorGBDefault == 0)
        {
			ErrorCount++;
			queueMessage("Default should be selected against a selected Volume Display option", document.all.error_Volume_Selection);
        }
		else
		{
			clearQueue(document.all.error_Volume_Selection);
		}
	--->
     <cfelse>
        if(document.all.Distributor_Off_Invoice_Volume.checked == true)
        {
          if (document.all.Volume_Distributor_Template_GroupB_Default[0].checked == true)
          {
            errorGBDefault = 1;
          }
        }
        if(document.all.Distributor_Billback_Volume.checked == true )
        {
           if (document.all.Volume_Distributor_Template_GroupB_Default[1].checked == true)
          {
            errorGBDefault = 1;
          }
        }
        if(document.all.Adjust_For_Credits.checked == true)
        {
           if (document.all.Volume_Distributor_Template_GroupB_Default[2].checked == true)
          {
            errorGBDefault = 1;
          }
        }

        if (document.all.Volume_Distributor_Template_GroupB_Default[3].checked == true)
        {
          errorGBDefault = 1;
        }
        if (errorGBDefault == 0)
        {
			ErrorCount++;
			queueMessage("Default should be selected against a selected Volume Display option or Invoice should be selected", document.all.error_Volume_Selection);
        }
		else
		{
			clearQueue(document.all.error_Volume_Selection);
		}
   </cfif>



<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0)
	{
			SecondaryInfo.submit()
	}
	else
	{
		showMessageWindow()
	}
}

	function checkType(objPref)
	{
		var includeVar = eval("document.all." + objPref);
		var itemVar = eval("document.all." + objPref + "_Item_Level");
		var groupVar = eval("document.all." + objPref + "_Group_Level");
		var eventObj = event.srcElement;

		// enter this logic when we are unchecking a checkbox
		if(!eventObj.checked)
		{
			<cfif appSettings.getSearchSequenceOn()>
			//when search sequence is on, if item or group are unchecked then uncheck the include checkbox
			if (itemVar.checked == false || groupVar.checked == false)
			{
				includeVar.checked = false;
				if(itemVar.checked) itemVar.checked = false;
				if(groupVar.checked) groupVar.checked = false;
			}
			<cfelse>
			//if item and group are unchecked then uncheck the include checkbox
			if (itemVar.checked == false && groupVar.checked == false)
			{
				includeVar.checked = false;
			}
			</cfif>
		}

		// enter this logic when we are checking a checkbox
		if(eventObj.checked)
		{
			//if item or group are checked then check the include checkbox
			if (itemVar.checked == true || groupVar.checked == true)
			{
				includeVar.checked = true;
				<cfif appSettings.getSearchSequenceOn()>//when search sequence is on, check both item and group
					if(!itemVar.checked) itemVar.checked = true;
					if(!groupVar.checked) groupVar.checked = true;
				</cfif>
			}
		}
	}

	function checkInclude(objPref)
	{

		var includeVar = eval("document.all." + objPref);
		var itemVar = eval("document.all." + objPref + "_Item_Level");
		var groupVar = eval("document.all." + objPref + "_Group_Level");
		<cfif form.Group_Deal eq 1>
			var defaultVar = groupVar;
		<cfelse>
			var defaultVar = itemVar;
		</cfif>

		//handle for discount lump sums
		if (objPref == "Discount_Lump_Sums")
		{
			var reqVar = eval("document.all." + objPref + "_Item_Mandated");
		}

		//if include is unchecked then uncheck item and group
		if (includeVar.checked == false)
		{
			itemVar.checked = false;
			groupVar.checked = false;
			//handle for discount lump sums
			if (objPref == "Discount_Lump_Sums")
			{
				reqVar.checked = false;
			}
		}

		//if include is checked then set to default
		if (includeVar.checked == true)
		{
			<cfif appSettings.getSearchSequenceOn()><!------ If search sequence is on, make both item and group available ----->
			itemVar.checked = includeVar.checked;
			groupVar.checked = includeVar.checked;
			<cfelse>
			if(itemVar.checked == false && groupVar.checked == false)
			{
				defaultVar.checked = true;
			}
			</cfif>
		}
	}

	function changeDisableOtherCheckBoxes(thisObj, OtherObj)
	{
		OtherObj.disabled = !(thisObj.checked);
	}

	<cfif Generic_Type IS NOT "Brokerage" >
		function CheckCriteria()
		{
			if (document.all.Discount_Lump_Sums != null)
			{
			if(document.all.Discount_Lump_Sums.checked == true)
			{
				document.all.Discount_Lump_Sums_Document_Attachment_Mandated.disabled = false;
			}
		 }
		}
	</cfif>


	/* Click on Discount types to get the message related to products. */
	function ClickToOpenLayer(UniqueID,DiscountType)
	{
		var DisplayObject;
		var Discount_Type;
		var Discount_Type = true;

		/* Get the row's ID */
		DisplayObject = document.getElementById(UniqueID);
		if(DiscountType != 'Discount_OffInvoice')
		{
			Discount_Type = eval("document.all."+DiscountType+".checked");
		}

		/* If the discount type is checked */
		if(Discount_Type == true)
		{
			/* Show/Hide based on its visible status */
			if(DisplayObject.style.display == 'none')
			{
			DisplayObject.style.display = '';
			}
			else
			{
			DisplayObject.style.display = 'none';
			}
		}
		else
		{
			DisplayObject.style.display = 'none';
		}

	}

	function enablepounds()
	{
		var specialfixed_checked = document.all.Discount_Fixed_Prices_Freight.checked;
		if (specialfixed_checked == true)
		{
			document.all.RateTypeOption_1.checked = specialfixed_checked;
			document.all.RateTypeDefault[0].checked =  specialfixed_checked;

			if (document.all.Group_Programs_UOM.checked == true)
			{
				document.all.Groups_UOM_2.checked = specialfixed_checked;
				document.all.Groups_UOM_Default[0].checked =  specialfixed_checked;
			}
		}
	}

	function checkFixedRebateGrid(thisObj)
	{
		var objName = thisObj.name;

		if(objName == 'Fixed_Rebate_Grid_Option')
		{
			if (document.all.Fixed_Rebate_Grid_Option.checked)
			{
				// TODO : DEFINE LOGIC.  COMMENTED OUT MWS RG2
				//if(document.all.Discount_Fixed_Prices){document.all.Discount_Fixed_Prices.checked = false; document.all.Discount_Fixed_Prices.disabled = true}
				//if(document.all.Discount_Rebates_Item_Level){document.all.Discount_Rebates_Item_Level.checked = false; document.all.Discount_Rebates_Item_Level.disabled = true}

				//if(document.all.Discount_Fixed_Item_Level){document.all.Discount_Fixed_Item_Level.checked = false; document.all.Discount_Fixed_Item_Level.disabled = true}
			}
			else
			{
				if(document.all.Discount_Fixed_Prices){document.all.Discount_Fixed_Prices.disabled = false}
				if(document.all.Discount_Rebates_Item_Level){document.all.Discount_Rebates_Item_Level.disabled = false}

				if(document.all.Discount_Fixed_Item_Level){document.all.Discount_Fixed_Item_Level.disabled = false}
			}
		}
		else
		{
			if(document.all.Fixed_Rebate_Grid_Option)
			{
				if(document.all.Discount_Fixed_Prices.checked == true)
				{
					//document.all.Fixed_Rebate_Grid_Option.checked = false;
					//document.all.Fixed_Rebate_Grid_Option.disabled = true;
				}
				else
				{
					document.all.Fixed_Rebate_Grid_Option.disabled = false;
				}
			}
		}
	}
</SCRIPT>


<!---</head>--->

<CFSET PAGETITLE = "PROGRAM TEMPLATES: DETAILS">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!---
<body <cfif Generic_Type IS NOT "Brokerage">onLoad="return CheckCriteria()"</cfif>>
--->
<!--- <body leftmargin="0" topmargin="0" bottommargin="0" rightmargin="0">

<cfinclude template="/includes/header.cfm"> --->
<cfset variables.retro = "<font size='2' color='red'><b>R</b></font>">
</CFIF> <!--- end :: cfif fromSettings_management neq 1 :: 1 ::Settings Management page 41974--->
<cfoutput>
<CFIF fromSettings_management neq 1> <!--- start :: cfif fromSettings_management neq 1 :: 2 ::Settings Management page 41974--->
<!------ display header ----->

<cfset pageName = "secondpage">
<cfinclude template="header.cfm">
<CF_MessageWindow>
<form action="secondpage_action.cfm" method="post" name="SecondaryInfo">

<cfif Action IS "Edit">
	<cfset IsDominant = SelectSecondary.IsDominant>
<cfelse>
	<cfset IsDominant = 0>
</cfif>

<div style="margin-top:5px;">    <!--- 42176 --->
		<span style="width:60%;"><img src="/images/ico-info.gif"><span class="headingTip"> &nbsp; #variables.retro# Indicates field which will be saved retroactively to all previous versions</span></span>
	<cfif LockedBy_Current_User EQ 1>
		<span class="headingActions" style="width:39%;text-align:right;"><a href="javascript:confirmCompletion()">#application.util.string.actionLinkFormat("save and continue")#</a></span>
	</cfif>
</div>

<cfset variables.disabled = ( LockedBy_Current_User NEQ 1 ? "disabled" : "")>

<!--- ...........................................................................
.............................. Outer Table [begin] ..............................
............................................................................ --->
<table cellspacing="1" cellpadding="15" border="0" width="100%" id="outerTable">
  <tr>
    <td colspan="2" class="er73">
      #(error_RateType  eq 1 ? "Please select at least one rate type.<br>" : "")#
      #(error_ClaimMech eq 1 ? "Please select at least one claim mechanic.<br>" : "")#
      #(error_PayOption eq 1 ? "Please select at least one payment period.<br>" : "")#
      #(error_Currency  eq 1 ? "Please select at least one currency.<br>" : "")#
    </td>
  </tr>
	<tr>
		<!---Rate Types--->
		<td valign="top" width="45%">

			<!--- ...........................................................................
			........................... Left Inner Table [begin] ............................
			............................................................................ --->
			<table width="100%" cellpadding="5" cellspacing="0" border="0" id="bigTable">
				<col width="50%">
				<col width="25%">
				<col width="25%">
				<!---NOI can only and always have pounds --->

</CFIF><!--- end :: cfif fromSettings_management neq 1 :: 2 ::Settings Management page 41974--->

				<cfif Generic_Type IS NOT "USDA NOI" AND Generic_Type IS NOT "LSAutoPAy" >

<CFIF fromSettings_management neq 1> <!--- start :: cfif fromSettings_management neq 1 :: 3 ::Settings Management page 41974--->

				<tr>
					<th>Unit of Measure</th>
					<td class="sh42">Include</th>
					<td class="sh42">Set as Default</th>
				</tr>


				<!---27305: removed EZButton_On EQ 1 to allow both Per Pound and Per Case for EZbutton template  --->
				<!---Per pound--->
				<tr>
					<td>Per #Application.UOMPoundSingular#<span id="error_CasePound"></span></td>
					<td><span id="error_RateTypeOption_1"></span> <input type="checkbox" name="RateTypeOption_1" value="1" onClick="javaScript:selectGroupUOM(this)" <cfif OperatorBid EQ false>
						<cfif (Action IS "Edit" and SelectSecondary.RateTypeOption_1 IS 1) OR SelectSecondary.Discount_Fixed_Prices_Freight EQ 1> checked </cfif><cfelse> disabled</cfif>>
						<!---<cfif EZButton_On EQ 1>
							<input type="hidden" name="RateTypeOption_1" value="1">
						</cfif>--->
					</td>
					<td><span id="error_RateTypeDefault"></span><input type="radio" onClick="DefaultGroupUOM(this.value)" name="RateTypeDefault" value="2" <cfif OperatorBid EQ false><cfif Action IS "Edit" and SelectSecondary.RateTypeDefault IS 2> checked</cfif><cfelse> disabled</cfif>></td>
				</tr>

				<!---Per Case--->
				<tr>
					<td>Per #Application.UOMCaseSingular#</td>
					<td><span id="error_RateTypeOption_2"></span><input type="checkbox" name="RateTypeOption_2" value="1" onClick="javaScript:selectGroupUOM(this)"  <cfif OperatorBid EQ false><cfif (Action IS "Edit" and SelectSecondary.RateTypeOption_2 IS 1)> checked</cfif><cfelse> disabled</cfif>>
					<!--- <cfif EZButton_On EQ 1>
						<input type="hidden" name="RateTypeOption_2" value="1">
					</cfif> --->
					</td>
					<td><input type="radio" onClick="DefaultGroupUOM(this.value)" name="RateTypeDefault" value="1" <cfif OperatorBid EQ false><cfif Action IS "Edit" and SelectSecondary.RateTypeDefault IS 1> checked</cfif><cfelse> disabled</cfif>></td>
				</tr>

				<cfset percentAvailable = (OperatorBid EQ false AND (Generic_Type IS "Distributor Off-Invoice" OR Generic_Type IS "Distributor Trade/Shelter"  OR Generic_Type IS "Brokerage" OR appsettings.getAllow_Percent_Operator_Programs() IS 1) AND EZButton_On EQ 0) />
				<cfif percentAvailable>
					<!---Percent--->
					<tr>
						<td>Percent of Revenue</td>
						<td><span id="error_RateTypeOption_3"></span><input type="checkbox" name="RateTypeOption_3" value="1" onClick="javaScript:selectGroupUOM(this)" <cfif Action IS "Edit" and SelectSecondary.RateTypeOption_3 IS 1> checked</cfif>></td>
						<td><input type="radio" onClick="DefaultGroupUOM(this.value)" name="RateTypeDefault" value="3" <cfif Action IS "Edit" and SelectSecondary.RateTypeDefault IS 3> checked</cfif> ></td>
					</tr>
				</cfif>

				<!---No Default--->
				<tr>
					<td>No Default</td>
					<td>&nbsp; </td>
					<td><input type="radio" onClick="DefaultGroupUOM(this.value);selectGroupUOM(this)" name="RateTypeDefault" value="0" <cfif OperatorBid EQ false><cfif Action IS "Edit" and SelectSecondary.RateTypeDefault IS 0> checked</cfif> <cfif Action is "Create">checked</cfif><cfelse> disabled</cfif>></td>
				</tr>

</CFIF> <!--- end :: cfif fromSettings_management neq 1 :: 3 ::Settings Management page 41974--->

				<!---Begin: UOM for Groups --->

				<tr id="UOMforGroups_heading_1"><th colspan="3" class="noBottomLine"><hr></th></tr>

				<tr id="UOMforGroups_heading_2">
					<th>UOM for Groups #variables.retro#</th>
					<td class="sh42" <cfif fromSettings_management eq 1> style="display:none"</cfif> >Include</th>
					<td class="sh42" <cfif fromSettings_management eq 1> style="display:none"</cfif> >Set as Default</th>
				</tr>
				<CFIF fromSettings_management eq 1>
					<cfset SettingsTemplateForm(NameField="Group_Programs_UOM",NameFieldDesc="Different from above")>
				<CFELSE>
				<!---Different from above--->
				<tr class="UOMforGroups" <cfif templateMgmtSettingsSecPage.Group_Programs_UOM EQ 0> style="display:none"</cfif>>
					<td>Different from above</td>
					<td>&nbsp;</td>
					<td>
						<span id="error_Group_Programs_UOM"></span>
						<input onClick="javaScript:showHideGroupProgramsUOM(this)" type="checkbox" name="Group_Programs_UOM" value="1" <cfif Action IS "Edit" and SelectSecondary.Group_Programs_UOM EQ 1>checked</cfif><cfif form.Group_Deal neq 1>disabled</cfif>>
					</td>
				</tr>
				</CFIF>
				<CFIF fromSettings_management eq 1>
					<cfset SettingsTemplateForm(NameField="Groups_UOM_2",NameFieldDesc="Per Pound")>
				<CFELSE>
				<!---Per pound--->
				<tr id="tr2_GroupProgramsUOM" class="UOMforGroups" <cfif SelectSecondary.Group_Programs_UOM NEQ 1> style="display:none;"</cfif> >
					<td>Per Pound</td>
					<td><span id="error_Groups_UOM_2"></span><input type="checkbox" id="Groups_UOM_2" name="Groups_UOM_2" value="1" <cfif OperatorBid EQ false><cfif (Action IS "Edit" and SelectSecondary.Groups_UOM_2 IS 1) OR EZButton_On EQ 1> checked <cfif EZButton_On EQ 1>disabled</cfif></cfif><cfelse> disabled</cfif>>
						<cfif EZButton_On EQ 1><input type="hidden" name="Groups_UOM_2" value="1"></cfif>
					</td>
					<td><span id="error_CasePound"></span><input type="radio" id="Groups_UOM_Default_2" name="Groups_UOM_Default" value="2" <cfif OperatorBid EQ false><cfif Action IS "Edit" and SelectSecondary.Groups_UOM_Default IS 2> checked</cfif><cfelse> disabled</cfif>></td>
				</tr>
				</CFIF>
				<CFIF fromSettings_management eq 1>
					<cfset SettingsTemplateForm(NameField="Groups_UOM_1",NameFieldDesc="Per Case")>
				<CFELSE>
				<!---Per Case--->
				<tr id="tr1_GroupProgramsUOM" class="UOMforGroups" <cfif SelectSecondary.Group_Programs_UOM NEQ 1> style="display:none;"</cfif> >
					<td>Per Case</td>
					<td><span id="error_Groups_UOM_1"></span><input type="checkbox" id="Groups_UOM_1" name="Groups_UOM_1" value="1" <cfif OperatorBid EQ false><cfif (Action IS "Edit" and SelectSecondary.Groups_UOM_1 IS 1) OR EZButton_On EQ 1> checked</cfif><cfif EZButton_On EQ 1>disabled</cfif><cfelse> disabled</cfif>>
					<!--- <cfif EZButton_On EQ 1>
					<input type="hidden" name="Groups_UOM_1" value="1">
					</cfif> --->
					</td>
					<td><input type="radio" id="Groups_UOM_Default_1" name="Groups_UOM_Default" value="1" <cfif OperatorBid EQ false><cfif Action IS "Edit" and SelectSecondary.Groups_UOM_Default IS 1> checked</cfif><cfelse> disabled</cfif>></td>
				</tr>
				</CFIF>
				<!---Percent--->
				<cfset percentAvailable = (OperatorBid EQ false AND (Generic_Type IS "Distributor Off-Invoice" OR Generic_Type IS "Distributor Trade/Shelter" OR Generic_Type IS "Brokerage" OR application.returned_customer_setting.customer_keyword IS "conagra") AND EZButton_On EQ 0) />
				<cfif percentAvailable>




					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="Groups_UOM_3",NameFieldDesc="Percent of Revenue")>
					<CFELSE>
					<tr id="tr3_GroupProgramsUOM" class="UOMforGroups" <cfif SelectSecondary.Group_Programs_UOM NEQ 1> style="display:none;"</cfif> >
						<td>Percent of Revenue</td>
						<td><span id="error_Groups_UOM_3"></span><input type="checkbox" id="Groups_UOM_3" name="Groups_UOM_3" value="1" <cfif Action IS "Edit" and SelectSecondary.Groups_UOM_3 IS 1> checked</cfif> ></td>
						<td><input type="radio" id="Groups_UOM_Default_3" name="Groups_UOM_Default" value="3" <cfif Action IS "Edit" and SelectSecondary.Groups_UOM_Default IS 3> checked</cfif> ></td>
					</tr>
					</CFIF>
				</cfif>
<CFIF fromSettings_management neq 1> <!--- start :: cfif fromSettings_management neq 1 :: 4 ::Settings Management page 41974--->
				<!---No Default--->
				<tr id="tr4_GroupProgramsUOM" class="UOMforGroups" <cfif SelectSecondary.Group_Programs_UOM NEQ 1> style="display:none;"</cfif> >
					<td>No Default</td>
					<td>&nbsp; </td>
					<td><input type="radio" id="Groups_UOM_Default_0" name="Groups_UOM_Default" value="0" <cfif OperatorBid EQ false><cfif Action IS "Edit" and SelectSecondary.Groups_UOM_Default IS 0> checked</cfif> <cfif Action is "Create">checked</cfif> <cfelse> disabled</cfif>></td>
				</tr>
</CFIF> <!--- start :: cfif fromSettings_management neq 1 :: 4 ::Settings Management page 41974--->
				<!---End: UOM for Groups --->

				<!---ELSE NOI --->
				<cfelse>
					<input type="hidden" name="RateTypeDefault" value="1">
					<input type="hidden" name="RateTypeOption_1" value="2">
					<!---NOI --->
				</cfif>

				<cfif Generic_Type IS NOT "Distributor Off-Invoice" AND Generic_Type IS NOT "LSAutoPAy" >


<CFIF fromSettings_management neq 1> <!--- start :: cfif fromSettings_management neq 1 :: 5 ::Settings Management page 41974--->
					<tr><th colspan="3"><hr></th></tr>
					<tr>
						<th>Claim Mechanics</th>
						<td class="sh42">Include</th>
						<td class="sh42">Set as Default</th>
					</tr>

					<cfif Action IS "Edit">
						<cfset ClaimMechDefaultOption = SelectSecondary.ClaimMechDefaultOption>
					<cfelse>
						<cfset ClaimMechDefaultOption = 0>
					</cfif>

					<cfquery name="AllTypes" datasource="#application.datasource#">
						SELECT 	*
						FROM 	Payment_Template_Mapping
						WHERE 	Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
					</cfquery>


					<cfloop query="GetPaymentTypes">

						<cfquery name="TypeInThisTemplate" datasource="#application.datasource#">
							SELECT 	Payment_Type_ID
							FROM 	Payment_Template_Mapping
							WHERE 	Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
							AND 	Payment_Type_ID = <cfqueryparam value="#GetPaymentTypes.Payment_Type_ID#" cfsqltype="cf_sql_integer">
						</cfquery>


						<tr>
							<td>
								#Payment_Type_Name#
								<cfif Is_Auto_Pay IS 1 OR Off_Invoice IS 1 OR Restrict_From_Billback IS 1>
								(
								</cfif>

										<cfif Is_Auto_Pay IS 1>AP</cfif>
										<cfif Off_Invoice IS 1>OI</cfif>
										 <cfif Restrict_From_Billback IS 1>RB</cfif>

								<cfif Is_Auto_Pay IS 1 OR Off_Invoice IS 1 OR Restrict_From_Billback IS 1>
								)
								</cfif>
							</td>
							<td><input type="checkbox" name="Payment_Type_#Payment_Type_ID#" value="1" <cfif len(trim(TypeInThisTemplate.Payment_Type_ID)) GT 0>checked</cfif> ></td>
							<td><input type="radio" name="ClaimMechDefaultOption" value="#Payment_Type_ID#" <cfif ClaimMechDefaultOption IS Payment_Type_ID>checked</cfif>> </td>
						</tr>

					</cfloop>

					<cfif Generic_Type IS NOT "Brokerage">
						<tr>
							<td>No Default</td>
							<td>&nbsp; </td>
							<td><input type="radio" name="ClaimMechDefaultOption" <cfif OperatorBid EQ false><cfif Action IS "Edit" and SelectSecondary.ClaimMechDefaultOption IS 0> checked</cfif> <cfif Action is "Create">checked</cfif><cfelse> disabled</cfif> value="0"></td>
						</tr>
					</cfif>
</CFIF> <!--- end :: cfif fromSettings_management neq 1 :: 5 ::Settings Management page 41974--->

					<!----Payment Cycle--->
					<tr id="PaymentFrequency_heading_1"><th colspan="3"  class="noBottomLine"><hr></th></tr>
					<tr id="PaymentFrequency_heading_2">
						<th>Payment Frequency</th>
						<td class="sh42" <cfif fromSettings_management eq 1> style="display:none"</cfif>>Include</th>
						<td class="sh42" <cfif fromSettings_management eq 1> style="display:none"</cfif>>Set as Default</th>
					</tr>
					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="PayCycleOption_1",NameFieldDesc="Daily")>
					<CFELSE>
					<!---Daily--->
					<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_1 EQ 0> style="display:none"</cfif>>
						<td>Daily</td>
						<td><span id="error_PayCycleOption_1"></span><input type="checkbox" name="PayCycleOption_1" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_1 IS 1> checked</cfif>></td>
						<td><input type="radio" name="PayCycleDefaultOption" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 1> checked</cfif>></td>
					</tr>
					</CFIF>
					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="PayCycleOption_2",NameFieldDesc="Weekly")>
					<CFELSE>
					<!---Weekly--->
					<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_2 EQ 0> style="display:none"</cfif>>
						<td>Weekly</td>
						<td><span id="error_PayCycleOption_2"></span><input type="checkbox" name="PayCycleOption_2" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_2 IS 1> checked</cfif>></td>
						<td><input type="radio" name="PayCycleDefaultOption" value="2" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 2> checked</cfif>></td>
					</tr>
					</CFIF>
					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="PayCycleOption_3",NameFieldDesc="Monthly")>
					<CFELSE>
					<!---Monthly--->
					<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_3 EQ 0> style="display:none"</cfif>>
						<td>Monthly</td>
						<td><span id="error_PayCycleOption_3"></span><input type="checkbox" name="PayCycleOption_3" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_3 IS 1> checked</cfif>></td>
						<td><input type="radio" name="PayCycleDefaultOption" value="3" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 3> checked</cfif>></td>
					</tr>
					</CFIF>
					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="PayCycleOption_4",NameFieldDesc="Quarterly")>
					<CFELSE>
					<!---Quarterly--->
					<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_4 EQ 0> style="display:none"</cfif>>
						<td>Quarterly</td>
						<td><span id="error_PayCycleOption_4"></span><input type="checkbox" name="PayCycleOption_4" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_4 IS 1> checked</cfif>></td>
						<td><input type="radio" name="PayCycleDefaultOption" value="4" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 4> checked</cfif>></td>
					</tr>
					</CFIF>
					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="PayCycleOption_5",NameFieldDesc="Semi-Annually")>
					<CFELSE>
					<!---Semi-Annually--->
					<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_5 EQ 0> style="display:none"</cfif>>
						<td>Semi-Annually</td>
						<td><span id="error_PayCycleOption_5"></span><input type="checkbox" name="PayCycleOption_5" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_5 IS 1> checked</cfif>></td>
						<td><input type="radio" name="PayCycleDefaultOption" value="5" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 5> checked</cfif>></td>
					</tr>
					</CFIF>
					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="PayCycleOption_6",NameFieldDesc="Annually")>
					<CFELSE>
					<!---Annually--->
					<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_6 EQ 0> style="display:none"</cfif>>
						<td>Annually</td>
						<td><span id="error_PayCycleOption_6"></span><input type="checkbox" name="PayCycleOption_6" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_6 IS 1> checked</cfif>></td>
						<td><input type="radio" name="PayCycleDefaultOption" value="6" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 6> checked</cfif>></td>
					</tr>
					</CFIF>
					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="PayCycleOption_7",NameFieldDesc="Upon Expiration")>
					<CFELSE>
					<!---Upon Expiration--->
					<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_7 EQ 0> style="display:none"</cfif>>
						<td>Upon Expiration</td>
						<td><span id="error_PayCycleOption_7"></span><input type="checkbox" name="PayCycleOption_7" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_7 IS 1> checked</cfif>></td>
						<td><input type="radio" name="PayCycleDefaultOption" value="7" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 7> checked</cfif>></td>
					</tr>
					</CFIF>
					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="PayCycleOption_8",NameFieldDesc="Upon Due")>
					<CFELSE>
					<!---Upon Due--->
					<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_8 EQ 0> style="display:none"</cfif>>
						<td>Upon Due</td>
						<td><span id="error_PayCycleOption_8"></span><input type="checkbox" name="PayCycleOption_8" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_8 IS 1> checked</cfif>></td>
						<td><input type="radio" name="PayCycleDefaultOption" value="8" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 8> checked</cfif>></td>
					</tr>
					</CFIF>
					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="PayCycleOption_9",NameFieldDesc="One Time Payment")>
					<CFELSE>
					<!---One Time Payment--->
					<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_9 EQ 0> style="display:none"</cfif>>
						<td>One Time Payment</td>
						<td><span id="error_PayCycleOption_9"></span><input type="checkbox" name="PayCycleOption_9" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_9 IS 1> checked</cfif>></td>
						<td><input type="radio" name="PayCycleDefaultOption" value="9" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 9> checked</cfif>></td>
					</tr>
					</CFIF>
					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="PayCycleOption_10",NameFieldDesc="Fiscal Month")>
					<CFELSE>
					<!--- Fiscal Month --->
					<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_10 EQ 0> style="display:none"</cfif>>
						<td>Fiscal Month</td>
						<td><span id="error_PayCycleOption_10"></span><input type="checkbox" name="PayCycleOption_10" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_10 IS 1> checked</cfif>></td>
						<td><input type="radio" name="PayCycleDefaultOption" value="10" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 10> checked</cfif>></td>
					</tr>
					</CFIF>
					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="PayCycleOption_11",NameFieldDesc="Fiscal Quarter")>
					<CFELSE>
					<!--- Fiscal Quarter --->
					<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_11 EQ 0> style="display:none"</cfif>>
						<td>Fiscal Quarter</td>
						<td><span id="error_PayCycleOption_11"></span><input type="checkbox" name="PayCycleOption_11" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_11 IS 1> checked</cfif>></td>
						<td><input type="radio" name="PayCycleDefaultOption" value="11" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 11> checked</cfif>></td>
					</tr>
					</CFIF>
					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="PayCycleDefaultOption",NameFieldDesc="No Default")>
					<CFELSE>
					<!---No Default--->
					<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleDefaultOption EQ 0> style="display:none"</cfif>>
						<td>No Default</td>
						<td>&nbsp; </td>
						<td><input type="radio" name="PayCycleDefaultOption" value="0" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 0> checked</cfif> <cfif Action is "Create">checked</cfif>></td>
					</tr>
					</CFIF>

				<!----Payment Paid To--->
					<tr id="PaymentPaidTo_heading_1"><th colspan="3" class="noBottomLine"><hr></th></tr>
					<tr id="PaymentPaidTo_heading_2">
						<th>Payment Paid To</th>
						<td class="sh42" <cfif fromSettings_management eq 1> style="display:none"</cfif>>Include</th>
						<td class="sh42" <cfif fromSettings_management eq 1> style="display:none"</cfif>>Set as Default</th>
					</tr>

					<cfif Action IS "Edit">
						<cfset PaidToDefaultOption = SelectSecondary.PaidToDefaultOption>
					<cfelse>
						<cfset PaidToDefaultOption = 0>
					</cfif>

					<cfquery name="AllTypes" datasource="#application.datasource#">
						SELECT 	*
						FROM 	Payment_Paid_To_Template_Mapping
						WHERE 	Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
					</cfquery>

					<cfloop query="GetPaymentPaidToTypes">

						<cfquery name="TypeInThisTemplate" datasource="#application.datasource#">
							SELECT 	Payment_Paid_To_ID
							FROM 	Payment_Paid_To_Template_Mapping
							WHERE 	Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
							AND 	Payment_Paid_To_ID = <cfqueryparam value="#GetPaymentPaidToTypes.Payment_Paid_To_ID#" cfsqltype="cf_sql_integer">
						</cfquery>
						<CFIF fromSettings_management eq 1>
							<tr>
							<td align="left">#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = Payment_Paid_To_Type_Identifier, paidToDesc=Payment_Paid_To_Type_Name)#</td>
							<td align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
									<input type="radio" name="Payment_Paid_To_Type_#Payment_Paid_To_ID#" value="1" id="Payment_Paid_To_Type_#Payment_Paid_To_ID#_1" <cfif GetPaymentPaidToTypes.Setting_Display_Value EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									<input type="radio" name="Payment_Paid_To_Type_#Payment_Paid_To_ID#" value="0" id="Payment_Paid_To_Type_#Payment_Paid_To_ID#_0" <cfif GetPaymentPaidToTypes.Setting_Display_Value EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							</td>
							<cfset SettingsTemplateForm(NameField="Payment_Paid_To_Type_#Payment_Paid_To_ID#",NameFieldDesc="#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = Payment_Paid_To_Type_Identifier, paidToDesc=Payment_Paid_To_Type_Name)#",SettingDisplayValueInTable="Payment_Paid_To_Types",SettingDisplayValueInTableID="#Payment_Paid_To_ID#")>
						<CFELSE>
						<tr class="PaymentPaidTo" <cfif GetPaymentPaidToTypes.Setting_Display_Value EQ 0> style="display:none"</cfif>>
							<td>
							#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = Payment_Paid_To_Type_Identifier, paidToDesc=Payment_Paid_To_Type_Name)#
							</td>
							<cfsilent>
							<cfset checkbox = "false">
							<cfset checkboxdefault = "false">
							<cfif AllTypes.recordcount EQ 0>
								<cfif Generic_Type EQ "Distributor Trade/Shelter" and trim(GetPaymentPaidToTypes.Payment_Paid_To_Type_Identifier) eq "D">
									<cfset checkbox = "true">
									<cfset checkboxdefault = "true">
								<cfelseif Generic_Type EQ "Distributor Trade/Shelter" and trim(GetPaymentPaidToTypes.Payment_Paid_To_Type_Identifier) eq "O">
									<cfset checkbox = "false">
									<cfset checkboxdefault = "false">
								<cfelseif Generic_Type EQ "Operator Direct or HQ Programs" and trim(GetPaymentPaidToTypes.Payment_Paid_To_Type_Identifier) eq "O">
									<cfset checkbox = "true">
									<cfset checkboxdefault = "true">
								<cfelseif Generic_Type EQ "Operator Direct or HQ Programs" and trim(GetPaymentPaidToTypes.Payment_Paid_To_Type_Identifier) eq "D">
									<cfset checkbox = "false">
									<cfset checkboxdefault = "false">
								<cfelseif Generic_Type EQ "Brokerage" and trim(GetPaymentPaidToTypes.Payment_Paid_To_Type_Identifier) eq "B">
									<cfset checkbox = "true">
									<cfset checkboxdefault = "true">
								<cfelse>
									<cfif trim(GetPaymentPaidToTypes.Payment_Paid_To_Type_Identifier) eq "D">
										<cfset checkbox = "true">
										<cfset checkboxdefault = "true">
									</cfif>
									<cfif trim(GetPaymentPaidToTypes.Payment_Paid_To_Type_Identifier) eq "O">
										<cfset checkbox = "true">
									</cfif>
								</cfif>
							</cfif>
							</cfsilent>
							<td><input type="checkbox" name="Payment_Paid_To_Type_#Payment_Paid_To_ID#" value="1" <cfif (len(trim(TypeInThisTemplate.Payment_Paid_To_ID)) GT 0 or checkbox EQ "true") OR (EZButton_On EQ 1 and (Payment_Paid_To_Type_Identifier EQ "D" OR Payment_Paid_To_Type_Identifier EQ "O"))>checked</cfif> <cfif EZButton_On EQ 1>disabled</cfif>>
								<cfif EZButton_On EQ 1 and (Payment_Paid_To_Type_Identifier EQ "D" OR Payment_Paid_To_Type_Identifier EQ "O")>
								<input type="hidden" name="Payment_Paid_To_Type_#Payment_Paid_To_ID#" value="1">
								</cfif>
							</td>
							<td><input type="radio" name="PaidToDefaultOption" value="#Payment_Paid_To_ID#" <cfif PaidToDefaultOption IS Payment_Paid_To_ID or checkboxdefault EQ "true">checked</cfif> > </td>
						</tr>
						</CFIF> <!--- end :: CFIF fromSettings_management eq 1 :: Payment_Paid_To_Type --->
					</cfloop>
					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="DispalyPaysToOnViewProgPage",NameFieldDesc="Display pays to below component name on View Prog Page")>
					<CFELSE>
					<tr <cfif templateMgmtSettingsSecPage.DispalyPaysToOnViewProgPage EQ 0> style="display:none"</cfif>>
						<td>Display pays to below component name on View Prog Page</td>
						<td>
							<input type="checkbox" name="DispalyPaysToOnViewProgPage" value="1" <cfif SelectSecondary.DispalyPaysToOnViewProgPage EQ 1>checked</cfif>>
						</td>
						<td>&nbsp;<td>
					</tr>
					</CFIF>
				</cfif>

<CFIF fromSettings_management neq 1> <!--- start :: cfif fromSettings_management neq 1 :: 6 ::Settings Management page 41974--->
<!--- CURRENCY SECTION --->
				<tr><th colspan="3"><hr></th></tr>
				<tr>
					<th>Currency</th>
					<td class="sh42">Include<span id="error_Currency_Selection"></span></th>
					<td class="sh42">Set as Default<span id="error_Currency_Default"></span></th>
				</tr>

				<cfif Action IS "Edit" OR Action IS "Create">
					<cfset CurrencyDefaultOption = SelectSecondary.CurrencyDefaultOption>
				<cfelse>
					<cfset CurrencyDefaultOption = 1>
				</cfif>

				<cfloop query="GetCurrencyTypes">

					<cfquery name="CurrencyInThisTemplate" datasource="#application.datasource#">
						SELECT 	Currency_ID
						FROM 	Currency_Mapping
						WHERE 	Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
						AND 	Currency_ID = <cfqueryparam value="#GetCurrencyTypes.Currency_ID#" cfsqltype="cf_sql_integer">
					</cfquery>

					<tr>
						<td>#Currency_Name# (#Currency_Code#)</td>
						<td><input type="checkbox" name="Currency_#Currency_ID#" value="1" <cfif (len(trim(CurrencyInThisTemplate.Currency_ID)) GT 0) OR Action IS "Create">checked</cfif> ></td>
						<td><input type="radio" name="CurrencyDefaultOption" value="#Currency_ID#" <cfif (CurrencyDefaultOption IS Currency_ID) OR Action IS "Create">checked</cfif>><!--- <cfoutput>#CurrencyDefaultOption# :: #Currency_ID# ::#Action#</cfoutput> ---></td>
					</tr>

				</cfloop>
					<tr>
						<td>No Default</td>
						<td>&nbsp; </td>
						<td><input type="radio" name="CurrencyDefaultOption" value="0" <cfif Action IS "Edit" and SelectSecondary.CurrencyDefaultOption IS 0> checked</cfif>></td>
					</tr>
<!--- END CURRENCY SECTION --->
</CFIF> <!--- start :: cfif fromSettings_management neq 1 :: 6 ::Settings Management page 41974--->
<!--- ********************* VOLUME SECTION D19117,D20129 -Anand Rao ********************* --->
<!---
	Dev Notes: D23160/Anand Rao/26-Apr-10
  Template settings for volume / Changed all the labels
--->

				<tr id="VolumeCalculations_heading_1"><th colspan="3" class="noBottomLine"><hr></th></tr>
				<tr id="VolumeCalculations_heading_2">
					<th>Volume Calculations<br><span class="er73"><span id="error_Volume_Selection"></span></span></th>
					<td class="sh42" <cfif fromSettings_management eq 1> style="display:none"</cfif>>Include</th>
					<td class="sh42" <cfif fromSettings_management eq 1> style="display:none"</cfif> >Set as Default</th>
				</tr>

        <cfif Generic_Type EQ "Operator-Deviated Pricing" or Generic_Type EQ "Operator Direct or HQ Programs">
        <!---
        	Dev Notes: D23319/Anand Rao/04-May-10
        	Template settings for volume/ Renamed the labels here
        --->
		<CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Operator_Off_Invoice_Volume",NameFieldDesc="Include Direct Shipment Volume and Dollars")>
		<CFELSE>
			<tr class="VolumeCalculations" <cfif templateMgmtSettingsSecPage.Operator_Off_Invoice_Volume EQ 0> style="display:none"</cfif>>
				<td>Include Direct Shipment Volume and Dollars<!--- Direct Shipment Volume and Dollars ---><!--- Off Invoice sales to an operator or program including an operator ---></td>
				<td>Yes<input type="hidden" name="Operator_Off_Invoice_Volume" value="1"></td>
				<td><input type="radio" name="Volume_Operator_Template_GroupB_Default" value="1" <cfif Action IS "Edit" and SelectSecondary.Volume_Operator_Template_GroupB_Default IS 1> checked</cfif>></td>
			</tr>
		</CFIF>
		<CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Operator_Billback_Volume",NameFieldDesc="Include billback volume and dollars")>
		<CFELSE>
			<tr class="VolumeCalculations" <cfif templateMgmtSettingsSecPage.Operator_Billback_Volume EQ 0> style="display:none"</cfif>>
				<td>Include billback volume and dollars<!--- Billback Volume and Dollars ---><!--- Billback volume as basis ---></td>
				<td>Yes<input type="hidden" name="Operator_Billback_Volume" value="1"></td>
				<td><input type="radio" name="Volume_Operator_Template_GroupB_Default" value="2" <cfif Action IS "Edit" and SelectSecondary.Volume_Operator_Template_GroupB_Default IS 2> checked</cfif>></td>
			</tr>
		</CFIF>
          <!---
			Adjust for credits should not be an option on operator templates
				<tr>
						<td>Credit Volume and Dollars<!--- Adjust for credits ---></td>
						<td><input type="checkbox" name="Adjust_For_Credits" value="1" <cfif SelectSecondary.Adjust_For_Credits EQ 1>checked</cfif> ></td>
            <td><input type="radio" name="Volume_Operator_Template_GroupB_Default" value="3" <cfif Action IS "Edit" and SelectSecondary.Volume_Operator_Template_GroupB_Default IS 3> checked</cfif>></td>
					</tr>
					--->

         <cfelse>
         <CFIF fromSettings_management eq 1>
         	<cfset SettingsTemplateForm(NameField="Distributor_Off_Invoice_Volume",NameFieldDesc="Exclude Direct Shipment Volume and Dollars")>
         <CFELSE>
          <tr class="VolumeCalculations" <cfif templateMgmtSettingsSecPage.Distributor_Off_Invoice_Volume EQ 0> style="display:none"</cfif>>
						<td>Exclude Direct Shipment Volume and Dollars<!--- Direct Shipment Volume and Dollars ---><!--- Operator off Invoice volume and dollars ---></td>
						<td><input type="checkbox" name="Distributor_Off_Invoice_Volume" value="1" <cfif SelectSecondary.Distributor_Off_Invoice_Volume EQ 1>checked</cfif> ></td>
            <td><input type="radio" name="Volume_Distributor_Template_GroupB_Default" value="1" <cfif Action IS "Edit" and SelectSecondary.Volume_Distributor_Template_GroupB_Default IS 1> checked</cfif>></td>
					</tr>
         </CFIF>
         <CFIF fromSettings_management eq 1>
         	<cfset SettingsTemplateForm(NameField="Distributor_Billback_Volume",NameFieldDesc="Exclude Operator Billback Volume and Dollars")>
         <CFELSE>
          <tr class="VolumeCalculations" <cfif templateMgmtSettingsSecPage.Distributor_Billback_Volume EQ 0> style="display:none"</cfif>>
						<td>Exclude Operator Billback Volume and Dollars<!--- Operator Billback Volume and Dollars --->
<!--- Operator billback volume ---></td>
						<td><input type="checkbox" name="Distributor_Billback_Volume" value="1" <cfif SelectSecondary.Distributor_Billback_Volume EQ 1>checked</cfif> ></td>
            <td><input type="radio" name="Volume_Distributor_Template_GroupB_Default" value="2" <cfif Action IS "Edit" and SelectSecondary.Volume_Distributor_Template_GroupB_Default IS 2> checked</cfif>></td>
					</tr>
         </CFIF>
         <CFIF fromSettings_management eq 1>
         	<cfset SettingsTemplateForm(NameField="Adjust_For_Credits",NameFieldDesc="Exclude credit volume and dollars")>
         <CFELSE>
          <tr class="VolumeCalculations" <cfif templateMgmtSettingsSecPage.Adjust_For_Credits EQ 0> style="display:none"</cfif>>
						<td>Exclude credit volume and dollars<!--- Credit Volume and Dollars ---><!--- Adjust for credits ---></td>
						<td><input type="checkbox" name="Adjust_For_Credits" value="1" <cfif SelectSecondary.Adjust_For_Credits EQ 1>checked</cfif> ></td>
            <td><input type="radio" name="Volume_Distributor_Template_GroupB_Default" value="3" <cfif Action IS "Edit" and SelectSecondary.Volume_Distributor_Template_GroupB_Default IS 3> checked</cfif>></td>
					</tr>
         </CFIF>
         <CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Volume_Distributor_Template_GroupB_Default",NameFieldDesc="Invoice level view (Default)")>
		<CFELSE>
          <tr class="VolumeCalculations" <cfif templateMgmtSettingsSecPage.Volume_Distributor_Template_GroupB_Default EQ 0> style="display:none"</cfif>>
            <td colspan="2">Invoice level view<!--- Set Invoices as Default ---></td>
            <td><input type="radio" name="Volume_Distributor_Template_GroupB_Default" value="4" <cfif (Action IS "Edit" and SelectSecondary.Volume_Distributor_Template_GroupB_Default IS 4) OR Action IS "Create"> checked</cfif>></td>
          </tr>
          </CFIF>
		     </cfif>
<!--- END VOLUME SECTION D19117,D20129 --->

<CFIF fromSettings_management neq 1> <!--- start :: cfif fromSettings_management neq 1 :: 7 ::Settings Management page 41974--->
<cfif appSettings.label_sets AND Generic_Type IS NOT "LSAutoPAy">
<!--- PROGRAM SUMMARY LABEL SET SECTION --->
				<tr><th colspan="3"><hr></th></tr>
				<tr>
					<th>Label Set</th>
					<td>&nbsp; </th>
					<td class="sh42">Set as Default<span id="error_LabelSet_Default"></span></th>
				</tr>

				<cfset qLabels = createObject("component", "components.settings.Labels.Labels").init()>
				<cfset getProgramLabelSetNames = qLabels.GetProgramLabelSetNames()>

				<cfif Action IS "Edit">
					<cfset LabelSetDefaultOption = SelectSecondary.Label_Set_Default>
				<cfelse>
					<cfset LabelSetDefaultOption = 1>
				</cfif>

				<cfloop query="getProgramLabelSetNames">

					<tr>
						<td>#Label_Set_Name#</td>
						<td>&nbsp; </td>
						<td><input type="radio" name="LabelSetDefaultOption" value="#Label_Set_Name#" <cfif LabelSetDefaultOption IS Label_Set_Name>checked</cfif>> </td>
					</tr>

				</cfloop>
					<tr>
						<td>No Default</td>
						<td>&nbsp; </td>
						<td><input type="radio" name="LabelSetDefaultOption" value="" <cfif Action IS "Edit" and SelectSecondary.Label_Set_Default IS "">checked</cfif>></td>
					</tr>
<!--- END PROGRAM SUMMARY LABEL SET SECTION --->
</cfif>

	<!--- Dev Notes: D23601/Anand Rao/04-Aug-10; Margin Page, Items to Exclude --->
	<cfif appSettings.getMarginItemsExclude()>
		<cfscript>
			ExcludeItemsManager    = CreateObject("component","components.settings.ExcludeItemsManager");
			qGetActiveExcludeItems = ExcludeItemsManager.getActiveItemsExclude();
			bResult = 0;
		</cfscript>
		<tr>
			<th colspan="3"><hr><br>Margin - Items to Exclude</th>
		</tr>
		<cfset useLakebaseForgetTemplateParentID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForgetTemplateParentID>
	<cftry>
		<cfset getTemplateParentID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#ID#",
				"select" = "first_parent_id"
			}), "first_parent_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetTemplateParentID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetTemplateParentID>
<cfquery name="getTemplateParentID" datasource="#application.datasource#">
			SELECT First_Parent_ID FROM Program_Control_Panel_Options WHERE ProgramControl_Panel_Options_ID = #ID#
		</cfquery>
</cfif>

		<cfloop query="qGetActiveExcludeItems">
			<cfset qGetActiveExcludeTemplate = ExcludeItemsManager.getItemExclusionTemplates(qGetActiveExcludeItems.Margin_Item_Exclusion_ID) />
			<cfset bResult = 1 />
			<cfset bChecked = 0 />

			<!--- Loop through all the availabel templates and check if this template's parent ID is already in the Exclude List --->
			<cfloop query="qGetActiveExcludeTemplate">
				<cfif (qGetActiveExcludeTemplate.Program_Template_ID EQ getTemplateParentID.First_Parent_ID)>
					<cfset bChecked = 1 />
				</cfif>
			</cfloop>

			<tr>
				<td><a href="##" onClick="javascript:NewWindowTopLeft('/settings/Margin_Items_To_Exclude/popupExcludeMarginDetails.cfm?MarginExclusionID=#qGetActiveExcludeItems.Margin_Item_Exclusion_ID#', 'productwindow', 835,650, 'yes', 'yes');return false;">#qGetActiveExcludeItems.Margin_Item_Exclusion_Name#</a></td>
				<td>&nbsp;</td>
				<td><input type="checkbox" name="excludeItems_#qGetActiveExcludeItems.Margin_Item_Exclusion_ID#" value="#qGetActiveExcludeItems.Margin_Item_Exclusion_ID#" <cfif (bChecked EQ 1)>checked</cfif>> </td>
			</tr>
		</cfloop>

		<cfif bResult EQ 0>
		<tr>
			<td>No Records for this Template</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		</cfif>
	</cfif>
	<!--- END D23601: Margin Page, Items to Exclude --->

				<cfif appSettings.getApprovalStandardOn() IS 1 AND Generic_Type IS NOT "LSAutoPAy">
				<!---if product category filter is on allow them to select which product categories to filter on--->
					<cfif isDefined("application.returned_customer_setting.product_category_filter") and application.returned_customer_setting.product_category_filter and EZButton_On EQ 0>
						<!---get the categories--->
						<cfset productCategory = CreateObject("component", "components.products.Category.ProductCategory") />
						<cfset qGetCategores = productCategory.getCategories() />
						<cfset lCategoryFilters = productCategory.getCategoryFilters(ID) />

						<tr style="header">
                        	<!--- colspan="3" --->
							<th colspan="3"><hr><br>Filter Product Category</th>
						</tr>
						<cfloop query="qGetCategores">
							<tr>
								<td>#Category_Name#</td>
								<td colspan="3">
									<input type="checkbox" name="Category_ID" value="#Category_ID#" <cfif ListFindNoCase(lCategoryFilters, Category_ID)>checked</cfif>>
								</td>
							</tr>
						</cfloop>

					</cfif>
					</cfif>
			</table>
            <!--- ...........................................................................
			........................... Left Inner Table [end] ..............................
			............................................................................ --->

		</td>

		<input type="hidden" name="ID" value="#ID#">
		<input type="hidden" name="Action" value="#Action#">
		<input type="hidden" name="Generic_Type" value="#Generic_Type#">
		<input type="hidden" name="IsDominant" value="#IsDominant#">
		<input type="hidden" name="Created_Type" value="#Created_Type#">
		<input type="hidden" name="Active" value="#Active#">

		<cfif isDefined("Form.Product_List")>
			<input type="hidden" name="DefaultProduct" value="#form.Product_List#">
		<cfelseif isDefined("SelectSecondary.Default_Product") AND (len(trim(SelectSecondary.Default_Product)) GT 0)>
			<input type="hidden" name="DefaultProduct" value="#SelectSecondary.Default_Product#">
		<cfelse>
			<input type="hidden" name="DefaultProduct" value="">
		</cfif>

		<!---FILTER: Group Deal--->
		<cfif isDefined("application.returned_customer_setting.group_deals") and application.returned_customer_setting.group_deals eq 1 and form.Group_Deal eq 1>
			<cfset disableGroup = "" />
		<cfelse>
			<cfset disableGroup = "disabled" />
		</cfif>

		<cfparam name="disableItem" default="" />
		<cfparam name="onClickFnForItemGroup" default="" />

		<!---FILTER: Don't display items selection if it's group deals and allow multi level groups is off--->
		<!---Commented to accomidate item selection - Label D7506 --->
		<!---<cfif form.Group_Deal eq 1 and not appSettings.getAllowMultiLevelGroups() and not appSettings.getSearchSequenceOn()>
			<cfset disableItem = "disabled" />
		</cfif>--->
		<cfif appSettings.getSearchSequenceOn()>
			<cfset onClickFnForItemGroup = "return false;" />
		</cfif>

		<cfif Generic_Type IS "USDA NOI">
			<input type="hidden" name="Discount_Rebates" value="1">
			<input type="hidden" name="Discount_Rebates_Item_Level" value="1">
		</cfif>

		<!---Add min/max options for Off Invoice and Bid Request--->
		<cfif Generic_Type IS "Distributor Off-Invoice" OR Generic_Type IS "Bid Request">

			<!--- <td rowspan="100%" width="5"><img src="/images/clear.gif" width="2" height="1"></td>
			<td rowspan="1" bgcolor="orange" width="2"><img src="/images/clear.gif" width="2" height="1"></td>
			<td rowspan="100%" width="5"><img src="/images/clear.gif" width="2" height="1"></td> --->
			<!----MIDPOINT--->

			<!--- class="cellLeftBorder" --->
			<td width="65%">

				<!--- ...........................................................................
				........................... Right Inner Table [begin] ...........................
				................................. option 1 of 2 ............................ --->
				<table width="400" cellpadding="5" cellspacing="0" border="1" class="maintable">

				<!---Discount minimum/maximums--->
					<tr>
						<td colspan="3" align="center" bgcolor="E6E6FA" height="20">
							<strong><div class="header">Discount Minimum/Maximum:</div></strong>
						</td>
					</tr>

					<tr>
						<td>&nbsp; </td>
						<td>Minimum</td>
						<td>Maximum</td>
					</tr>

					<cfif Generic_Type IS "Distributor Off-Invoice">
					<!---Off Invoice--->
					<tr>
						<td valign="top" onClick="ClickToOpenLayer('OffInvoiceProductMessage','Discount_OffInvoice');"><strong><cfif SelectSecondary.Discount_OffInvoice_Product_Message neq ""><a style="text-decoration:underline"></cfif>Off Invoice<cfif SelectSecondary.Discount_OffInvoice_Product_Message neq ""></a></cfif></strong><div> Pound&nbsp; <Br><Br>Case&nbsp; <Br><br>Percent</div></td>

						<td>&nbsp; <br>
							<input type="text" name="Min_OffInvoice_Pound" value="#SelectSecondary.Min_OffInvoice_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<Br>
							<input type="text" name="Min_OffInvoice_Case" value="#SelectSecondary.Min_OffInvoice_Case#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<br>
							<input type="text" name="Min_OffInvoice_Percent" value="#SelectSecondary.Min_OffInvoice_Percent#" onKeyUp="clenseText(this, '0123456789.')" size="10">
						</td>
						<td>&nbsp; <br>
							<input type="text" name="Max_OffInvoice_Pound" value="#SelectSecondary.Max_OffInvoice_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<span id="error_OffInvoice_Pound"></span><Br>
							<input type="text" name="Max_OffInvoice_Case" value="#SelectSecondary.Max_OffInvoice_Case#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<span id="error_OffInvoice_Case"></span> <Br>
							<input type="text" name="Max_OffInvoice_Percent" value="#SelectSecondary.Max_OffInvoice_Percent#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<span id="error_OffInvoice_Percent"></span>
							</td>
					</tr>
					<tr id="OffInvoiceProductMessage" style="display:none;">
						<td colspan="3"><span style="color:red;vertical-align:top;">Off Invoice Message:</span><br /><textarea name="Discount_OffInvoice_Product_Message" rows="4" cols="40" onPaste="javaScript: return textareaChecklength(200, this);"  onkeyPress="javaScript: return textareaChecklength(200, this);">#SelectSecondary.Discount_Rebates_Product_Message#</textarea></td>
					</tr>
					</cfif>

					<cfif Generic_Type IS "Bid Request">
					<!---Bid Request Price--->
					<tr>
						<td onClick="ClickToOpenLayer('BidRequestProductMessage','Discount_BidRequest');"><cfif SelectSecondary.Discount_BidRequest_Product_Message neq ""><a style="text-decoration:underline"></cfif>Bid Fixed Price<cfif SelectSecondary.Discount_BidRequest_Product_Message neq ""></a></cfif></td>
						<td>
							<span id="error_Discount_BidRequest_Prices"></span><input type="checkbox" name="Discount_BidRequest" value="1" onClick="ClickToOpenLayer('BidRequestProductMessage','Discount_BidRequest');"<cfif Action IS "Edit" and SelectSecondary.Discount_BidRequest IS 1>checked</cfif>>
						</td>
						<td>N/A</td>
					</tr>
					<tr id="BidRequestProductMessage" style="display:none;">
						<td colspan="3"><span style="color:red;vertical-align:top;">Bid Fixed Price Message:</span><br /><textarea name="Discount_BidRequest_Product_Message" rows="4" cols="40" onPaste="javaScript: return textareaChecklength(200, this);"  onkeyPress="javaScript: return textareaChecklength(200, this);">#SelectSecondary.Discount_BidRequest_Product_Message#</textarea></td>
					</tr>
					<tr>
						<td>Show Base Price on View Program Page</td>
						<td>
						<input type="checkbox" name="display_BidRequest_basesales" value="1" <cfif Action IS "Edit" and SelectSecondary.display_BidRequest_basesales IS 1>checked</cfif>>
						</td>
						<td>N/A</td>
					</tr>
					<tr>
						<td valign="top"><strong>Bid Fixed Price <br></strong><div> Pound&nbsp; <Br><Br>Case&nbsp;</div></td>

						<td>&nbsp; <br>
							<input type="text" name="Min_BidRequest_Pound" value="#SelectSecondary.Min_BidRequest_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<Br>
							<input type="text" name="Min_BidRequest_Case" value="#SelectSecondary.Min_BidRequest_Case#" onKeyUp="clenseText(this, '0123456789.')" size="10">
						</td>
						<td>&nbsp; <br>
							<input type="text" name="Max_BidRequest_Pound" value="#SelectSecondary.Max_BidRequest_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<span id="error_BidRequest_Pound"></span><Br>
							<input type="text" name="Max_BidRequest_Case" value="#SelectSecondary.Max_BidRequest_Case#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<span id="error_BidRequest_Case"></span> <Br>

							</td>
					</tr>
					<!---Rebate--->
					<tr>
						<td onClick="ClickToOpenLayer('RebateProductMessage','Discount_Rebates');"><cfif SelectSecondary.Discount_Rebates_Product_Message neq ""><a style="text-decoration:underline"></cfif>#Application.RebateLabel#<cfif SelectSecondary.Discount_Rebates_Product_Message neq ""></a></cfif></td>
						<td>
							<input type="checkbox" name="Discount_Rebates" value="1" onClick="checkInclude('Discount_Rebates');ClickToOpenLayer('RebateProductMessage','Discount_Rebates');" <cfif Action IS "Edit" and SelectSecondary.Discount_Rebates IS 1>checked</cfif>>
						</td>
						<td>
							Item:<input name="Discount_Rebates_Item_Level" type="checkbox"  onClick="checkType('Discount_Rebates');" value="1" <cfif Action IS "Edit" AND SelectSecondary.Discount_Rebates_Item_Level eq 1>checked</cfif> />&nbsp;
							Group:<input name="Discount_Rebates_Group_Level" type="checkbox" #disableGroup# onClick="checkType('Discount_Rebates');" value="1" <cfif Action IS "Edit" AND SelectSecondary.Discount_Rebates_Group_Level eq 1 and form.Group_Deal eq 1>checked</cfif> />
						</td>
					</tr>
					<tr id="RebateProductMessage" style="display:none;">
						<td colspan="3"><span style="color:red;">#Application.RebateLabel# Message:</span><br /><textarea name="Discount_Rebates_Product_Message" rows="4" cols="40" onPaste="javaScript: return textareaChecklength(200, this);"  onkeyPress="javaScript: return textareaChecklength(200, this);">#SelectSecondary.Discount_Rebates_Product_Message#</textarea></td>
					</tr>

					<!---validate checkbox selections--->
					<script>checkInclude('Discount_Rebates');</script>

				<!---Rebate--->
					<tr>
						<td valign="top"><strong>#Application.RebateLabel#</strong><div> Pound&nbsp; <Br><Br>Case&nbsp; <Br><Br>Percent&nbsp; </div></td>


						<td nowrap>&nbsp; <br>
							<input type="text" name="Min_Rebate_Pound" value="#SelectSecondary.Min_Rebate_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<Br>
							<input type="text" name="Min_Rebate_Case" value="#SelectSecondary.Min_Rebate_Case#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<br>
							<input type="text" name="Min_Rebate_Percent" value="#SelectSecondary.Min_Rebate_Percent#" onKeyUp="clenseText(this, '0123456789.')" size="10">
						</td>
						<td nowrap>&nbsp; <br>
							<input type="text" name="Max_Rebate_Pound" value="#SelectSecondary.Max_Rebate_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<span id="error_Rebate_Pound"></span><Br>
							<input type="text" name="Max_Rebate_Case" value="#SelectSecondary.Max_Rebate_Case#" onKeyUp="clenseText(this, '0123456789.')" size="10">    <span id="error_Rebate_Case"></span><br>
							<input type="text" name="Max_Rebate_Percent" value="#SelectSecondary.Max_Rebate_Percent#" onKeyUp="clenseText(this, '0123456789.')" size="10">		<span id="error_Rebate_Percent"></span></td>
					</tr>
				</cfif>

				</table>
                <!--- ...........................................................................
				............................ Right Inner Table [end] ............................
				................................. option 1 of 2 ............................ --->
		</cfif>

		<!--- <cfif Generic_Type IS NOT "Distributor Off-Invoice"> --->
		<!---TSF: Modification--->
		<!---FILTER: don't display discount types if the generic type is Distributor Off-Invoice or Bid Request--->

		<cfif not ListFindNoCase("Distributor Off-Invoice,Bid Request,USDA NOI,LSAutoPAy", Generic_Type)>
		<!----MIDPOINT--->

			<!--- <td rowspan="100%" width="5"><img src="/images/clear.gif" width="2" height="1"></td>
			<td rowspan="1" bgcolor="orange" width="2"><img src="/images/clear.gif" width="2" height="1"></td>
			<td rowspan="100%" width="5"><img src="/images/clear.gif" width="2" height="1"></td> --->

			<td valign="top">
		</cfif>

			<!----MIDPOINT--->

            <!--- ...........................................................................
			........................... Right Inner Table [begin] ...........................
			................................. option 2 of 2 ............................ --->
			<table width="100%" cellpadding="5" cellspacing="0" border="0" id="bigTable">
			<col width="50%">
			<col width="25%">
			<col width="25%">

</CFIF> <!--- end :: cfif fromSettings_management neq 1 :: 7 ::Settings Management page 41974--->

			<cfif NOT ListFindNoCase("Distributor Off-Invoice,Bid Request,USDA NOI,LSAutoPAy", Generic_Type)>
					<CFIF fromSettings_management eq 1><tr><th colspan="3" class="noBottomLine"><hr></th></tr></CFIF>
					<tr id="DiscountTypes_heading">
						<th>Discount Types</th>
						<td class="sh42" <cfif fromSettings_management eq 1> style="display:none"</cfif>>Include</th>
						<td class="sh42" <cfif fromSettings_management eq 1> style="display:none"</cfif>>Level</th>
					</tr>
					<!---<cfif EZButton_On eq 0>--->
					<!---Fixed / Rebate Grid--->
					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="Fixed_Rebate_Grid_Option",NameFieldDesc="Fixed/#Application.RebateLabel# Grid")>
					<CFELSE>
					<tr class="DiscountTypes" <cfif templateMgmtSettingsSecPage.Fixed_Rebate_Grid_Option EQ 0> style="display:none"</cfif>>
						<td>Fixed/#Application.RebateLabel# Grid</td>
						<td>			<!--- <cfif SelectSecondary.Fixed_Rebate_Grid_Option neq 1 and (SelectSecondary.Discount_Fixed_Prices eq 1 or (SelectSecondary.Discount_Rebates eq 1 and not len(trim(disableGroup))))>disabled</cfif> 
										onClick="checkFixedRebateGrid(this);" :: D43269 allow only 1 component in rates grid--->
							<input name="Fixed_Rebate_Grid_Option" type="checkbox"  value="1" <cfif Action IS "Edit" and SelectSecondary.Fixed_Rebate_Grid_Option eq 1>checked</cfif>>
						</td>
						<td>
							N/A
						</td>
					</tr>
					</CFIF>
					<!---</cfif>--->
					<!---Fixed Price--->
					<cfif Generic_Type IS NOT "Brokerage" AND Generic_Type IS NOT "LSAutoPay" AND EZButton_On eq 0>
					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="Discount_Fixed_Prices",NameFieldDesc="Fixed Price")>
						<cfif application.appSettingsGet.getTemplateMultipleProductAttrGroups() EQ 1>
							<cfset SettingsTemplateForm(NameField="Discount_Fixed_Prices_Freight",NameFieldDesc="Fixed Price :: #application.returned_customer_setting.distributor_label_singular# Level Fixed Price")>
							<cfset SettingsTemplateForm(NameField="Custom_Fixed_Price_Options",NameFieldDesc="Fixed Price :: Custom Fixed Price Options")>
						</cfif>					
						<cfset SettingsTemplateForm(NameField="Market_Price",NameFieldDesc="Fixed Price :: Market Price")>
						<cfset SettingsTemplateForm(NameField="Fixed_Price_Populates_Price_List_Special",NameFieldDesc="Fixed Price :: Fixed Price Populates Special Price List")>
						<cfset SettingsTemplateForm(NameField="display_FixedPrice_basesales",NameFieldDesc="Fixed Price :: Show Base Price on View Program Page")>
						<cfset SettingsTemplateForm(NameField="Display_FixedPrice_Basesales_On_Approval",NameFieldDesc="Fixed Price :: Show Base Price at time of approval")>
						<cfif appSettings.getShow_Fixed_Freight()>
							<cfset SettingsTemplateForm(NameField="Fixed_Type",NameFieldDesc="Fixed Price :: Fixed Price Type")>
							<cfset SettingsTemplateForm(NameField="Fixed_Type_Explanation",NameFieldDesc="Fixed Price :: Fixed Price Type Explanation")>
						</cfif>
					<CFELSE>
						<tr class="DiscountTypes" <cfif templateMgmtSettingsSecPage.Discount_Fixed_Prices EQ 0> style="display:none"</cfif>>
							<td onClick="ClickToOpenLayer('FixedPriceProductMessage','Discount_Fixed_Prices');" valign="top"><cfif SelectSecondary.Discount_Fixed_Prices_Product_Message neq ""><a style="text-decoration:underline"></cfif>Fixed Price<cfif SelectSecondary.Discount_Fixed_Prices_Product_Message neq ""></a></cfif></td>
							<td valign="top"><span id="error_Discount_Fixed_Prices"></span> <!--- checkFixedRebateGrid(this); :: D43269 allow only 1 component in rates grid --->
								<input type="checkbox" name="Discount_Fixed_Prices" value="1" onClick="ClickToOpenLayer('FixedPriceProductMessage','Discount_Fixed_Prices');" <cfif Action IS "Edit" and SelectSecondary.Discount_Fixed_Prices IS 1>checked</cfif>>
							</td>
							<td>
								<!---//////////////////////////////Start Fixed Price Options ///////////////////////////////// --->
								<!--- <!--- Multi attr groups always uses the Rates Grid and always has ITEM AND GROUP level "items" --->--->
								<cfif application.appSettingsGet.getTemplateMultipleProductAttrGroups() EQ 1>
									Item <input name="Discount_Fixed_Item_Level" type="checkbox" value="1" checked disabled />&nbsp;  <!---and SelectSecondary.Fixed_Rebate_Grid_Option neq 1---> &nbsp; &nbsp;
									Group <input name="Discount_Fixed_Group_Level_chk" type="checkbox" value="1" <cfif form.Group_Deal eq 1>checked</cfif> disabled />
									<input name="Discount_Fixed_Group_Level" type="hidden" <cfif form.Group_Deal eq 1>value="1"<cfelse>value="0"</cfif> />
									<!--- Multi attr groups always uses the Rates Grid and always has Item level "items" --->
									<input name="Discount_Fixed_Item_Level" type="hidden"  value="1" />
								  <br>
								<cfelse>
									N/A<br>
								</cfif>
								<cfif application.appSettingsGet.getTemplateMultipleProductAttrGroups() EQ 1>
									<!--- Customer level Fixed Price Rates.  feature is available for Fixed Component type 3 when this is on --->
									<div <cfif templateMgmtSettingsSecPage.Discount_Fixed_Prices_Freight EQ 0> style="display:none"</cfif>>									
									<span class="td80">#application.returned_customer_setting.distributor_label_singular# Level Fixed Price</span>
									<input type="checkbox" id ="Discount_Fixed_Prices_Freight" name="Discount_Fixed_Prices_Freight" value="1" <cfif Action IS "Edit" and SelectSecondary.Discount_Fixed_Prices_Freight IS 1>checked </cfif> >
									<br>
									</div>								
									<!--- Custom Print Options.  Requires Custom Tables and data from erp--->
									<div <cfif templateMgmtSettingsSecPage.Custom_Fixed_Price_Options EQ 0> style="display:none"</cfif>>
									<span class="td80">Custom Fixed Price Options</span>
									<input type="checkbox" id="Custom_Fixed_Price_Options" name="Custom_Fixed_Price_Options" value="1" <cfif Action IS "Edit" and SelectSecondary.Custom_Fixed_Price_Options IS 1>checked </cfif> >
									<br>
									</div>
								</cfif>
								<!---Remove generic_type restriction.  Used to be "Distributor Trade/Shelter"--->
								<cfif Generic_Type NEQ "">
									<div <cfif templateMgmtSettingsSecPage.Market_Price EQ 0> style="display:none"</cfif>>
									<span class="td80">Market Price</span>
									<input type="checkbox" name="Market_Price" value="1" <cfif Action IS "Edit" and SelectSecondary.Market_Price IS 1>checked </cfif> />
									<br>
									</div>
									<div <cfif templateMgmtSettingsSecPage.Fixed_Price_Populates_Price_List_Special EQ 0> style="display:none"</cfif>>
									<span class="td80">Fixed Price Populates Special Price List</span>
									<input type="checkbox" name="Fixed_Price_Populates_Price_List_Special" value="1" <cfif Action IS "Edit" and SelectSecondary.Fixed_Price_Populates_Price_List_Special IS 1>checked </cfif> />
									<br>
									</div>
								<cfelse>
									<input type="hidden" name="Fixed_Price_Populates_Price_List_Special" value="#SelectSecondary.Fixed_Price_Populates_Price_List_Special#">
									<input type="hidden" name="Market_Price" value="#SelectSecondary.Market_Price#">
								</cfif>
								<div <cfif templateMgmtSettingsSecPage.display_FixedPrice_basesales EQ 0> style="display:none"</cfif>>

								<span class="td80">Show Base Price on View Program Page</span>
								<input type="checkbox" name="display_FixedPrice_basesales" value="1" <cfif Action IS "Edit" and SelectSecondary.display_FixedPrice_basesales IS 1>checked</cfif>>
								<br>
								</div>
								<div <cfif templateMgmtSettingsSecPage.Display_FixedPrice_Basesales_On_Approval EQ 0> style="display:none"</cfif>>

								<span class="td80">Show Base Price at time of approval</span>
								<input type="checkbox" name="Display_FixedPrice_Basesales_On_Approval" value="1" <cfif Action IS "Edit" and SelectSecondary.Display_FixedPrice_Basesales_On_Approval IS 1>checked</cfif>>
								<br>
								</div>
								<!--- Fixed Price type --->
								<cfif appSettings.getShow_Fixed_Freight()>
									<div <cfif templateMgmtSettingsSecPage.Fixed_Type EQ 0> style="display:none"</cfif>>
									Fixed Price Type
									<input type="radio" name="Fixed_Type" value="0" checked> Guaranteed
									<input type="radio" name="Fixed_Type" value="1" <cfif Action IS "Edit" and SelectSecondary.Fixed_Type IS 1>checked </cfif>> Variable<br>
									</div>
									<div <cfif templateMgmtSettingsSecPage.Fixed_Type_Explanation EQ 0> style="display:none"</cfif>>
									<!--- Explanatory fixed price type notes --->
									Fixed Price Type Explanation<br>
									<input type="text" name="Fixed_Type_Explanation" <cfif Action IS "Edit">value="#SelectSecondary.Fixed_Type_Explanation#"</cfif> size="42" maxlength="50" class="wd4">
									<br>
									</div>
								<cfelse>
									<input type="hidden" name="Fixed_Type" value="<cfif Action IS "Edit">#SelectSecondary.Fixed_Type#<cfelse>0</cfif>">
									<input type="hidden" name="Fixed_Type_Explanation" value="<cfif Action IS "Edit">#SelectSecondary.Fixed_Type_Explanation#</cfif>">
								</cfif>
								<!---////////////////////////////// End Fixed Price Options ///////////////////////////////// --->
							</td>
						</tr>
						<tr class="DiscountTypes" id="FixedPriceProductMessage" style="display:none;">
							<td colspan="3">
								<span style="color:red;vertical-align:top;">Fixed Price Message:</span><br />
								<textarea name="Discount_Fixed_Prices_Product_Message" rows="4" cols="40" onPaste="javaScript: return textareaChecklength(200, this);"  onkeyPress="javaScript: return textareaChecklength(200, this);">#trim(SelectSecondary.Discount_Fixed_Prices_Product_Message)#</textarea>
							</td>
						</tr>
					</CFIF> <!--- end :: CFIF fromSettings_management eq 1  --->
					</cfif>

		<cfif not Generic_Type EQ 'Direct Pricing'>
			<!---Rebate--->
			<CFIF fromSettings_management eq 1>
				<cfset SettingsTemplateForm(NameField="Discount_Rebates",NameFieldDesc="#Application.RebateLabel#")>
			<CFELSE>
			<tr class="DiscountTypes" <cfif templateMgmtSettingsSecPage.Discount_Rebates EQ 0> style="display:none"</cfif>>
				<td onClick="ClickToOpenLayer('RebateProductMessage','Discount_Rebates');">
					<cfif SelectSecondary.Discount_Rebates_Product_Message neq "">
						<a style="text-decoration:underline"> #Application.RebateLabel# </a>
					<cfelse>
						#Application.RebateLabel#
					</cfif>
				</td>
				<td>
					<!--- 29808: enable rebate on EZ button template (when template is new or when existing template switches to EZ button (rebate assigned to 1 on 1st tab when new) --->
				  <cfif SelectSecondary.Discount_Rebates eq 1>
						<cfset checked.discount_rebates = "checked=checked">
				  <cfelse>
						<cfset checked.discount_rebates = "">
				  </cfif>			<!--- checkFixedRebateGrid(this); :: D43269 allow only 1 component in rates grid --->
					<input type="checkbox" name="Discount_Rebates" value="1" onClick="checkInclude('Discount_Rebates');ClickToOpenLayer('RebateProductMessage','Discount_Rebates');" <cfif SelectSecondary.Fixed_Rebate_Grid_Option eq 1 and len(trim(disableGroup))>disabled</cfif>#checked.discount_rebates# />
				</td>
				<td>
					Item <input name="Discount_Rebates_Item_Level" type="checkbox"  onClick="checkType('Discount_Rebates');" value="1" <cfif SelectSecondary.Fixed_Rebate_Grid_Option eq 1 and (not len(trim(disableGroup)) or form.Group_Deal neq 1)>disabled</cfif> <cfif Action IS "Edit" AND SelectSecondary.Discount_Rebates_Item_Level eq 1 >checked</cfif> /> &nbsp; &nbsp;<!--- and SelectSecondary.Fixed_Rebate_Grid_Option neq 1 --->
					<cfif application.appSettingsGet.getTemplateMultipleProductAttrGroups() EQ 1>
						Group <input name="Discount_Rebates_Group_Level_chk" type="checkbox" onClick="checkType('Discount_Rebates');" value="1" <cfif form.Group_Deal eq 1>checked</cfif> disabled />
						<input name="Discount_Rebates_Group_Level" type="hidden" onClick="checkType('Discount_Rebates');"  <cfif form.Group_Deal eq 1>value="1"<cfelse>value="0"</cfif> />
					<cfelse>
						Group:<input name="Discount_Rebates_Group_Level" type="checkbox" #disableGroup# onClick="checkType('Discount_Rebates');" value="1" <cfif Action IS "Edit" AND SelectSecondary.Discount_Rebates_Group_Level eq 1 and form.Group_Deal eq 1>checked</cfif> />
					</cfif>
				</td>
			</tr>
			<tr class="DiscountTypes" id="RebateProductMessage" style="display:none;">
				<td colspan="3"><span style="color:red;vertical-align:top;">#Application.RebateLabel# Message:</span><br /><textarea  name="Discount_Rebates_Product_Message" rows="4" cols="40" onPaste="javaScript: return textareaChecklength(200, this);"  onkeyPress="javaScript: return textareaChecklength(200, this);">#SelectSecondary.Discount_Rebates_Product_Message#</textarea></td>
			</tr>
			<!---validate checkbox selections--->
			<script>checkInclude('Discount_Rebates');</script>
			</CFIF>
			<!---Lump Sum--->
			<cfif Generic_Type IS NOT "Brokerage" <!---29808 - AND EZButton_On eq 0--->>
				<CFIF fromSettings_management eq 1>
					<cfset SettingsTemplateForm(NameField="Discount_Lump_Sums",NameFieldDesc="#Application.LumpsumLabel#")>
					<cfset SettingsTemplateForm(NameField="Discount_Lump_Sums_Item_Mandated",NameFieldDesc="#Application.LumpsumLabel# :: Product Required")>
					<cfset SettingsTemplateForm(NameField="Discount_Lump_Sums_Distributor_Mandated",NameFieldDesc="#Application.LumpsumLabel# :: #application.returned_customer_setting.distributor_label_singular# Required")>
					<cfset SettingsTemplateForm(NameField="Discount_Lump_Sums_Document_Attachment_Mandated",NameFieldDesc="#Application.LumpsumLabel# :: Document Attachment Required")>
				<CFELSE>
				<tr class="DiscountTypes" <cfif templateMgmtSettingsSecPage.Discount_Lump_Sums EQ 0> style="display:none"</cfif>>
					<td valign="top" onClick="ClickToOpenLayer('LumpsumProductMessage','Discount_Lump_Sums');"><cfif SelectSecondary.Discount_Lump_Sums_Product_Message neq ""><a style="text-decoration:underline"></cfif>#Application.LumpsumLabel#<cfif SelectSecondary.Discount_Lump_Sums_Product_Message neq ""></a></cfif></td>
					<td valign="top">
						<input type="checkbox" name="Discount_Lump_Sums" value="1" onClick="checkInclude('Discount_Lump_Sums');ClickToOpenLayer('LumpsumProductMessage','Discount_Lump_Sums');"  <cfif Action IS "Edit" and SelectSecondary.Discount_Lump_Sums IS 1> checked</cfif> onpropertychange="changeDisableOtherCheckBoxes(this, this.form.Discount_Lump_Sums_Distributor_Mandated);changeDisableOtherCheckBoxes(this, this.form.Discount_Lump_Sums_Document_Attachment_Mandated);">
					</td>
					<td nowrap>
					Item <input name="Discount_Lump_Sums_Item_Level" type="checkbox"  onClick="checkType('Discount_Lump_Sums');" value="1" <cfif Action IS "Edit" AND SelectSecondary.Discount_Lump_Sums_Item_Level eq 1>checked</cfif> /> &nbsp; &nbsp;
					Group<input name="Discount_Lump_Sums_Group_Level" type="checkbox" #disableGroup# onClick="checkType('Discount_Lump_Sums');" value="1" <cfif Action IS "Edit" AND SelectSecondary.Discount_Lump_Sums_Group_Level eq 1 and form.Group_Deal eq 1>checked</cfif> />
				  </td>
				</tr>
				<tr class="DiscountTypes" <cfif templateMgmtSettingsSecPage.Discount_Lump_Sums_Item_Mandated EQ 0> style="display:none"</cfif>>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
					<td><span class="td80">Product Required</span> <input name="Discount_Lump_Sums_Item_Mandated" type="checkbox" onClick="checkInclude('Discount_Lump_Sums');" value="1" <cfif Action IS "Edit" AND SelectSecondary.Discount_Lump_Sums_Item_Mandated eq 1>checked</cfif> />
				  </td>
				</tr>
				<tr class="DiscountTypes" <cfif templateMgmtSettingsSecPage.Discount_Lump_Sums_Distributor_Mandated EQ 0> style="display:none"</cfif>>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
					<td><span class="td80">#application.returned_customer_setting.distributor_label_singular# Required</span> <input name="Discount_Lump_Sums_Distributor_Mandated" type="checkbox" onClick="checkInclude('Discount_Lump_Sums');" value="1" <cfif Action IS "Edit" AND SelectSecondary.Discount_Lump_Sums_Distributor_Mandated eq 1>checked<cfelse>disabled</cfif> <cfif NOT SelectSecondary.Specify_Distributors>disabled title="#application.returned_customer_setting.distributor_label_plural# are not allowed in this template"</cfif> />
				  </td>
				</tr>
				<tr class="DiscountTypes" <cfif templateMgmtSettingsSecPage.Discount_Lump_Sums_Document_Attachment_Mandated EQ 0> style="display:none"</cfif>>
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
					<td><span class="td80">Document Attachment Required</span> <input name="Discount_Lump_Sums_Document_Attachment_Mandated" type="checkbox" onClick="checkInclude('Discount_Lump_Sums');" value="1" <cfif Action IS "Edit" AND SelectSecondary.Discount_Lump_Sums_Document_Attachment_Mandated eq 1>checked<cfelse>disabled</cfif>/>
					</td>
				</tr>
				<tr class="DiscountTypes" id="LumpsumProductMessage" style="display:none;">
					<td colspan="3"><span style="color:red;vertical-align:top;">#Application.LumpsumLabel# Message:</span><br /><textarea name="Discount_Lump_Sums_Product_Message" rows="4" cols="40" onPaste="javaScript: return textareaChecklength(200, this);"  onkeyPress="javaScript: return textareaChecklength(200, this);">#SelectSecondary.Discount_Lump_Sums_Product_Message#</textarea></td>
				</tr>
				<!---validate checkbox selections--->
				<script>checkInclude('Discount_Lump_Sums');</script>
				</CFIF>
				<cfif EZButton_On EQ 0 AND EZButton_On eq 0>
					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="Discount_Growth",NameFieldDesc="Growth")>
						<cfset SettingsTemplateForm(NameField="Allow_Multi",NameFieldDesc="Growth :: Allow bracket rate")>
						<cfset SettingsTemplateForm(NameField="Allow_Single",NameFieldDesc="Growth :: Allow retroactive rate")>
						<cfset SettingsTemplateForm(NameField="Allow_Volume_Pool_Seperation",NameFieldDesc="Growth :: Allow Volume Pool Separation")>
						<cfset SettingsTemplateForm(NameField="Bonus_Field",NameFieldDesc="Growth :: #Application.BonusLabel# Field")>
						<cfset SettingsTemplateForm(NameField="growth_auto_pay",NameFieldDesc="Growth :: Auto Pay")>
					<CFELSE>
					<!---Growth--->
					<tr valign="top" class="DiscountTypes" <cfif templateMgmtSettingsSecPage.Discount_Growth EQ 0> style="display:none"</cfif>>
						<td onClick="ClickToOpenLayer('GrowthProductMessage','Discount_Growth');"><cfif SelectSecondary.Discount_Growth_Product_Message neq ""><a style="text-decoration:underline"></cfif>Growth<cfif SelectSecondary.Discount_Growth_Product_Message neq ""></a></cfif></td>
						<td><input type="checkbox" name="Discount_Growth" value="1" onClick="checkInclude('Discount_Growth');ClickToOpenLayer('GrowthProductMessage','Discount_Growth');" <cfif Action IS "Edit" and SelectSecondary.Discount_Growth IS 1> checked</cfif>></td>
						<td>
							Item:<input name="Discount_Growth_Item_Level" type="checkbox" onClick="checkType('Discount_Growth');" value="1" <cfif Action IS "Edit" AND SelectSecondary.Discount_Growth_Item_Level eq 1>checked</cfif> />&nbsp;
							Group:<input name="Discount_Growth_Group_Level" type="checkbox" #disableGroup# onClick="checkType('Discount_Growth');" value="1" <cfif Action IS "Edit" AND SelectSecondary.Discount_Growth_Group_Level eq 1 and form.Group_Deal eq 1>checked</cfif> />
							<!--- <br>Allow Bracket Rate <input name="Allow_Growth_Multi_Rate" type="checkbox" value="1" <cfif Action NEQ "Edit" OR SelectSecondary.Discount_Growth NEQ 1> disabled</cfif> <cfif Action IS "Edit" AND SelectSecondary.Allow_Growth_Multi_Rate eq 1>checked</cfif> /> --->
						<br>
						<!---Allow Multi--->
						<div <cfif templateMgmtSettingsSecPage.Allow_Multi EQ 0> style="display:none"</cfif>>									
						<span class="td80">Allow Bracket Rate</span>
						<input type="checkbox" id ="Allow_Multi" name="Allow_Multi" value="1" <cfif Action IS "Edit" and SelectSecondary.Allow_Multi IS 1>checked</cfif><cfif Action IS NOT "Edit">checked</cfif>>
						<br>
						</div>

						<!---Allow Single--->
						<div <cfif templateMgmtSettingsSecPage.Allow_Single EQ 0> style="display:none"</cfif>>									
						<span class="td80">Allow Retroactive Rate</span>
						<input type="checkbox" id="Allow_Single" name="Allow_Single" value="1" <cfif Action IS "Edit" and SelectSecondary.Allow_Single IS 1>checked</cfif><cfif Action IS NOT "Edit">checked</cfif>>
						<br>
						</div>								

						<!---Allow XofY--->
						<div <cfif templateMgmtSettingsSecPage.Allow_Volume_Pool_Seperation EQ 0> style="display:none"</cfif>>									
						<span class="td80">Allow Volume Pool Separation</span>
						<input type="checkbox"  id ="Allow_Volume_Pool_Seperation" name="Allow_Volume_Pool_Seperation" value="1" <cfif Action IS "Edit" and SelectSecondary.Allow_Volume_Pool_Seperation IS 1>checked</cfif><cfif Action IS NOT "Edit">checked</cfif>
						<br>
						</div>

						<!--- Bonus Field --->
						<div <cfif templateMgmtSettingsSecPage.Bonus_Field EQ 0> style="display:none"</cfif>>									
						<span class="td80">#Application.BonusLabel# Field</span>
						<input type="checkbox" id ="Bonus_Field" name="Bonus_Field" value="1" <cfif Action IS "Edit" and SelectSecondary.Bonus_Field IS 1>checked </cfif> >
						<br>
						</div>

						<!---D35731 Growth Auto Pay START--->
						<div <cfif templateMgmtSettingsSecPage.growth_auto_pay EQ 0> style="display:none"</cfif>>									
						<span class="td80">Auto Pay</span>
						<input type="checkbox" id="growth_auto_pay" name="growth_auto_pay" value="1" <cfif SelectSecondary.Growth_Auto_Pay>checked</cfif>>
						<br>
						</div>
					</td>
					</tr>
					<tr id="GrowthProductMessage" style="display:none;" class="DiscountTypes" >
						<td colspan="3"><span style="color:red;vertical-align:top;">Growth Message:</span><br /><textarea name="Discount_Growth_Product_Message" rows="4" cols="40" onPaste="javaScript: return textareaChecklength(200, this);"  onkeyPress="javaScript: return textareaChecklength(200, this);">#SelectSecondary.Discount_Growth_Product_Message#</textarea></td>
					</tr>
					<!---validate checkbox selections--->
					<script>checkInclude('Discount_Growth');</script>
					</CFIF>

					<!---Formula Pricing--->
					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="Discount_Formula_Pricing",NameFieldDesc="Formula Pricing")>
					<CFELSE>
					<tr class="DiscountTypes" <cfif templateMgmtSettingsSecPage.Discount_Formula_Pricing EQ 0> style="display:none"</cfif>>
						<td onClick="ClickToOpenLayer('FormulaPricingProductMessage','Discount_Formula_Pricing');"><cfif SelectSecondary.Discount_Formula_Pricing_Product_Message neq ""><a style="text-decoration:underline"></cfif>Formula Pricing<cfif SelectSecondary.Discount_Formula_Pricing_Product_Message neq ""></a></cfif></td>
						<td><input type="checkbox" name="Discount_Formula_Pricing" onClick="ClickToOpenLayer('FormulaPricingProductMessage','Discount_Formula_Pricing');" <cfif SelectSecondary.Date_Exclusions_ON eq 1>disabled <cfelse>#disableItem# </cfif> value="1" <cfif Action IS "Edit" and SelectSecondary.Discount_Formula_Pricing IS 1 and disableItem neq "disabled"> checked</cfif>></td>
						<td>N/A</td>
					</tr>
					<tr id="FormulaPricingProductMessage" style="display:none;" class="DiscountTypes" >
						<td colspan="3"><span style="color:red;vertical-align:top;">Formula Pricing Message:</span><br /><textarea name="Discount_Formula_Pricing_Product_Message" rows="4" cols="40" onPaste="javaScript: return textareaChecklength(200, this);"  onkeyPress="javaScript: return textareaChecklength(200, this);">#SelectSecondary.Discount_Formula_Pricing_Product_Message#</textarea></td>
					</tr>
					</CFIF>
					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="Bid_Rule_Option",NameFieldDesc="Bid Pricing (automated pricing)")>
					<CFELSE>
					<cfif application.bidPricingLinksAvailable>
						<!---Bid Pricing--->
						<tr  class="DiscountTypes" <cfif templateMgmtSettingsSecPage.Bid_Rule_Option EQ 0> style="display:none"</cfif>>
							<td>Bid Pricing (automated pricing)</td>
							<td><input type="checkbox" name="Bid_Rule_Option" value="1" #disableItem# <cfif Action IS "Edit" and SelectSecondary.Bid_Rule_Option IS 1 and disableItem neq "disabled"> checked</cfif>></td>
							<td>N/A</td>

						</tr>
					</cfif>
					</CFIF>
				</cfif>
			</cfif> <!--- Not Brokerage --->
		</cfif><!------ Not Direct Pricing ----->

		<!---Discount minimum/maximums--->
		<tr id="DiscountMinMax_heading_1"><th colspan="3" class="noBottomLine"><hr></th></tr>
		<tr id="DiscountMinMax_heading_2">
			<th>Discount Min/Max</th>
			<td class="sh42" <cfif fromSettings_management eq 1> style="display:none"</cfif>>Minimum</th>
			<td class="sh42" <cfif fromSettings_management eq 1> style="display:none"</cfif>>Maximum</th>
		</tr>

		<!---Fixed Price--->
		<cfif Generic_Type IS NOT "Brokerage" >
		  <CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Min_Fixed_Pound",NameFieldDesc="Fixed Price Pound")>
		  <CFELSE>
			<tr class="DiscountMinMax" <cfif templateMgmtSettingsSecPage.Min_Fixed_Pound EQ 0> style="display:none"</cfif>>
				<td>Fixed Price Pound</td>
        <td><input type="text" name="Min_Fixed_Pound" value="#SelectSecondary.Min_Fixed_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10"></td>
        <td><input type="text" name="Max_Fixed_Pound" value="#SelectSecondary.Max_Fixed_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<span id="error_Fixed_Pound"></span></td>
			</tr>
		  </CFIF>
		  <CFIF fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Min_Fixed_Case",NameFieldDesc="Fixed Price Case")>
		  <CFELSE>
			<tr class="DiscountMinMax" <cfif templateMgmtSettingsSecPage.Min_Fixed_Case EQ 0> style="display:none"</cfif>>
				<td>Fixed Price Case</td>
        <td><input type="text" name="Min_Fixed_Case" value="#SelectSecondary.Min_Fixed_Case#" onKeyUp="clenseText(this, '0123456789.')" size="10"></td>
        <td><input type="text" name="Max_Fixed_Case" value="#SelectSecondary.Max_Fixed_Case#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<span id="error_Fixed_Case"></span></td>
			</tr>
		  </CFIF>
		</cfif>
		<cfif not Generic_Type EQ 'Direct Pricing'>
			<!---Rebate--->
			<CFIF fromSettings_management eq 1>
				<cfset SettingsTemplateForm(NameField="Min_Rebate_Pound",NameFieldDesc="#Application.RebateLabel# Pound")>
			<CFELSE>
			<tr class="DiscountMinMax" <cfif templateMgmtSettingsSecPage.Min_Rebate_Pound EQ 0> style="display:none"</cfif>>
				<td>#Application.RebateLabel# Pound</td>
				<td><input type="text" name="Min_Rebate_Pound" value="#SelectSecondary.Min_Rebate_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10"></td>
				<td><input type="text" name="Max_Rebate_Pound" value="#SelectSecondary.Max_Rebate_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<span id="error_Rebate_Pound"></span></td>
      </tr>
			</CFIF>
			<CFIF fromSettings_management eq 1>
				<cfset SettingsTemplateForm(NameField="Min_Rebate_Case",NameFieldDesc="#Application.RebateLabel# Case")>
			<CFELSE>
			<tr class="DiscountMinMax" <cfif templateMgmtSettingsSecPage.Min_Rebate_Case EQ 0> style="display:none"</cfif>>
				<td>#Application.RebateLabel# Case</td>
				<td><input type="text" name="Min_Rebate_Case" value="#SelectSecondary.Min_Rebate_Case#" onKeyUp="clenseText(this, '0123456789.')" size="10"></td>
				<td><input type="text" name="Max_Rebate_Case" value="#SelectSecondary.Max_Rebate_Case#" onKeyUp="clenseText(this, '0123456789.')" size="10">    <span id="error_Rebate_Case"></span></td>
      </tr>
			</CFIF>
			<CFIF fromSettings_management eq 1>
				<cfset SettingsTemplateForm(NameField="Min_Rebate_Percent",NameFieldDesc="#Application.RebateLabel# Percent")>
			<CFELSE>
			<tr class="DiscountMinMax" <cfif templateMgmtSettingsSecPage.Min_Rebate_Percent EQ 0> style="display:none"</cfif>>
				<td>#Application.RebateLabel# Percent</td>
				<td><input type="text" name="Min_Rebate_Percent" value="#SelectSecondary.Min_Rebate_Percent#" onKeyUp="clenseText(this, '0123456789.')" size="10"></td>
				<td><input type="text" name="Max_Rebate_Percent" value="#SelectSecondary.Max_Rebate_Percent#" onKeyUp="clenseText(this, '0123456789.')" size="10">		<span id="error_Rebate_Percent"></span></td>
      </tr>
			</CFIF>

			<cfif Generic_Type IS NOT "Brokerage" >
				<cfif EZButton_On EQ 0>
						<!---Growth--->
			<CFIF fromSettings_management eq 1>
				<cfset SettingsTemplateForm(NameField="Min_Growth_Pound",NameFieldDesc="Growth Pound")>
			<CFELSE>
						<tr class="DiscountMinMax" <cfif templateMgmtSettingsSecPage.Min_Growth_Pound EQ 0> style="display:none"</cfif>>
							<td>Growth Pound</td>
							<td><input type="text" name="Min_Growth_Pound" value="#SelectSecondary.Min_Growth_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10"></td>
							<td><input type="text" name="Max_Growth_Pound" value="#SelectSecondary.Max_Growth_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<span id="error_Growth_Pound"></span></td>
						</tr>
			</CFIF>
			<CFIF fromSettings_management eq 1>
				<cfset SettingsTemplateForm(NameField="Min_Growth_Case",NameFieldDesc="Growth Case")>
			<CFELSE>
						<tr class="DiscountMinMax" <cfif templateMgmtSettingsSecPage.Min_Growth_Case EQ 0> style="display:none"</cfif>>
							<td>Growth Case</td>
							<td><input type="text" name="Min_Growth_Case" value="#SelectSecondary.Min_Growth_Case#" onKeyUp="clenseText(this, '0123456789.')" size="10"></td>
							<td><input type="text" name="Max_Growth_Case" value="#SelectSecondary.Max_Growth_Case#" onKeyUp="clenseText(this, '0123456789.')" size="10"> <span id="error_Growth_Case"></span></td>
						</tr>
			</CFIF>
			<CFIF fromSettings_management eq 1>
				<cfset SettingsTemplateForm(NameField="Min_Growth_Percent",NameFieldDesc="Growth Percent")>
			<CFELSE>
						<tr class="DiscountMinMax" <cfif templateMgmtSettingsSecPage.Min_Growth_Percent EQ 0> style="display:none"</cfif>>
							<td>Growth Percent</td>
							<td><input type="text" name="Min_Growth_Percent" value="#SelectSecondary.Min_Growth_Percent#" onKeyUp="clenseText(this, '0123456789.')" size="10"></td>
							<td><input type="text" name="Max_Growth_Percent" value="#SelectSecondary.Max_Growth_Percent#" onKeyUp="clenseText(this, '0123456789.')" size="10">		<span id="error_Growth_Percent"></span></td>
						</tr>
			</CFIF>
			<CFIF fromSettings_management eq 1>
				<cfset SettingsTemplateForm(NameField="Min_Formula_Pound",NameFieldDesc="Formula Pound")>
			<CFELSE>
						<!---Formula Pricing--->
						<tr class="DiscountMinMax" <cfif templateMgmtSettingsSecPage.Min_Formula_Pound EQ 0> style="display:none"</cfif>>
							<td>Formula Pound</td>
              <td><input type="text" name="Min_Formula_Pound" value="#SelectSecondary.Min_Formula_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10"></td>
              <td><input type="text" name="Max_Formula_Pound" value="#SelectSecondary.Max_Formula_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<span id="error_Formula_Pound"></span></td>
            </tr>
			</CFIF>
			<CFIF fromSettings_management eq 1>
				<cfset SettingsTemplateForm(NameField="Min_Formula_Percent",NameFieldDesc="Formula Percent")>
			<CFELSE>						<tr class="DiscountMinMax" <cfif templateMgmtSettingsSecPage.Min_Formula_Percent EQ 0> style="display:none"</cfif>>
  						<td>Formula Percent</td>
              <td><input type="text" name="Min_Formula_Percent" value="#SelectSecondary.Min_Formula_Percent#" onKeyUp="clenseText(this, '0123456789.')" size="10"></td>
              <td><input type="text" name="Max_Formula_Percent" value="#SelectSecondary.Max_Formula_Percent#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<span id="error_Formula_Percent"></span></td>
            </tr>
			</CFIF>

<CFIF fromSettings_management neq 1> <!--- start :: cfif fromSettings_management neq 1 :: 8 ::Settings Management page 41974--->

						<!--- start - moved to Discount Types section :: 43234 
						<!---Growth Options--->
						<cfif appSettings.getGrowthExpansion1()>

            	<tr><th colspan="3"><hr></th></tr>
							<tr>
								<th colspan="3">Growth Options</th>
							</tr>

							<!---Allow Multi--->
							<tr>
								<td nowrap>Allow bracket rate</td>
								<td colspan="3"><input type="checkbox" name="Allow_Multi" value="1" <cfif Action IS "Edit" and SelectSecondary.Allow_Multi IS 1>checked</cfif><cfif Action IS NOT "Edit">checked</cfif>></td>
							</tr>

							<!---Allow Single--->
							<tr>
								<td nowrap>Allow retroactive rate</td>
								<td colspan="3"><input type="checkbox" name="Allow_Single" value="1" <cfif Action IS "Edit" and SelectSecondary.Allow_Single IS 1>checked</cfif><cfif Action IS NOT "Edit">checked</cfif>></td>
							</tr>

							<!---Allow Stairway--->
							<!---
							<tr>
								<td>Allow stairway</td>
								<td colspan="3"><input type="checkbox" name="Allow_Stairway" value="1" <cfif Action IS "Edit" and SelectSecondary.Allow_Stairway IS 1>checked</cfif><cfif Action IS NOT "Edit">checked</cfif>></td>
							</tr>
							--->

							<!---Allow XofY--->
							<!---
							<tr>
								<td>Allow X of Y</td>
								<td colspan="3"><input type="checkbox" name="Allow_XofY" value="1" <cfif Action IS "Edit" and SelectSecondary.Allow_XofY IS 1>checked</cfif><cfif Action IS NOT "Edit">checked</cfif>></td>
							</tr>
							--->

							<!---Allow XofY--->
							<tr>
								<td>Allow volume pool separation</td>
								<td colspan="3"><input type="checkbox" name="Allow_Volume_Pool_Seperation" value="1" <cfif Action IS "Edit" and SelectSecondary.Allow_Volume_Pool_Seperation IS 1>checked</cfif><cfif Action IS NOT "Edit">checked</cfif>></td>
							</tr>

						<!--- D35731 Growth Auto Pay START--->
								<tr>
									<td>Auto pay:</td>
									<td colspan="3"><input type="checkbox" name="growth_auto_pay" value="1" <cfif SelectSecondary.Growth_Auto_Pay>checked</cfif>></td>
								</tr>
						<!--- D35731 Growth Auto Pay END--->

							<!---End Growth Options--->
						</cfif>
						end - moved to Discount Types section :: 43234  --->

				</cfif> <!--- End EZButton cfif --->
			</cfif> <!--- Not Brokerage  --->

		</cfif><!------ Not Direct Pricing ----->
		</cfif> <!--- END FROM 1676 NOT ListFindNoCase("Distributor Off-Invoice,Bid Request,USDA NOI,LSAutoPAy", Generic_Type) --->
</CFIF> <!--- end :: cfif fromSettings_management neq 1 :: 8 ::Settings Management page 41974--->

		<cfif NOT ListFindNoCase("Distributor Off-Invoice,Bid Request,USDA NOI", Generic_Type)>

				  <tr id="PerformanceRequirements_heading_1"><th colspan="3" class="noBottomLine"><hr></th></tr>
					<CFIF fromSettings_management eq 1>
						<th>Performance Requirements</th>
						<td class="sh42"  style="display:none"></td>
						<td class="sh42"  style="display:none"></td>
						<cfset SettingsTemplateForm(NameField="minPerfRequirementsOn",NameFieldDesc="Min Required")>
					<CFELSE>
					<tr id="PerformanceRequirements_heading_2">
						<th colspan="3">Performance Requirements</th>
					</tr>
					<tr class="PerformanceRequirements" <cfif templateMgmtSettingsSecPage.minPerfRequirementsOn EQ 0> style="display:none"</cfif>>
					 <td>Min Required</td>
					 <td><input type="radio" name="minPerfRequirementsOn" value="1" <cfif SelectSecondary.minPerfRequirementsOn eq "1">checked</cfif> onClick="minPerformanceRequirements()"/> yes <input type="radio" name="minPerfRequirementsOn" value="0" <cfif SelectSecondary.minPerfRequirementsOn eq "0">checked</cfif> onClick="minPerformanceRequirements()" /> no</td>
					 <td><input type="text" size="5" name="minPerfRequirements" id="minPerfRequirements" value="#SelectSecondary.minPerfRequirements#" <cfif SelectSecondary.minPerfRequirementsOn eq "0">disabled="true"</cfif>  class="wd70"/></td>
					</tr>
					</CFIF>
					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="maxPerfRequirementsOn",NameFieldDesc="Max Required")>
					<CFELSE>
					<tr class="PerformanceRequirements" <cfif templateMgmtSettingsSecPage.maxPerfRequirementsOn EQ 0> style="display:none"</cfif>>
					 <td>Max Required</td>
					 <td><input type="radio" name="maxPerfRequirementsOn" value="1" <cfif SelectSecondary.maxPerfRequirementsOn eq "1">checked</cfif> onClick="maxPerformanceRequirements()" /> yes <input type="radio" name="maxPerfRequirementsOn" value="0" <cfif SelectSecondary.maxPerfRequirementsOn eq "0">checked</cfif> onClick="maxPerformanceRequirements()" /> no</td>
					 <td><input type="text" size="5" name="maxPerfRequirements" <cfif SelectSecondary.maxPerfRequirementsOn eq "0">disabled="true"</cfif> id="maxPerfRequirements" value="#SelectSecondary.maxPerfRequirements#" class="wd70"/></td>
					</tr>
					</CFIF>
					<!---Get all Performance Requirements--->
					<cfset useLakebaseForGetPerformanceRequirements = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_perf_req")>
<cfif useLakebaseForGetPerformanceRequirements>
	<cftry>
		<cfset GetPerformanceRequirements = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_perf_req", {
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetPerformanceRequirements = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetPerformanceRequirements>
<cfquery name="GetPerformanceRequirements" datasource="#application.datasource#">
						SELECT 	*
						FROM 	Program_Perf_Req
						WHERE 	Deleted = 0
					</cfquery>
</cfif>

					<cfquery dbtype="query" name="qmgmtSettingProgram_Perf_Req">
						select Setting_Display_Value
						from GetPerformanceRequirements
						where Setting_Display_Value = 1
					</cfquery>


					<tr id="PerformanceRequirements_heading_3" <cfif fromSettings_management eq 1 or qmgmtSettingProgram_Perf_Req.recordcount eq 0> style="display:none"</cfif>>
           	<td><br></td>
 						<td class="sh42"><br><b>Include</b></td>
            <td class="sh42"><br><b>Display As</b></td>
 					</tr>

					<cfloop query="GetPerformanceRequirements">

						<cfquery name="InThisTemplate" datasource="#application.datasource#">
							SELECT 	*
							FROM 	Program_Perf_Mapping
							WHERE 	Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
							AND 	Program_Perf_Req_ID = <cfqueryparam value="#Program_Perf_Req_ID#" cfsqltype="cf_sql_integer">
						</cfquery>
						<CFIF fromSettings_management eq 1>
							<tr>
							<td align="left">#Requirement_Name#</td>
							<td align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
									<input type="radio" name="Requirement_#Program_Perf_Req_ID#" value="1" id="Requirement_#Program_Perf_Req_ID#_1" <cfif GetPerformanceRequirements.Setting_Display_Value EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									<input type="radio" name="Requirement_#Program_Perf_Req_ID#" value="0" id="Requirement_#Program_Perf_Req_ID#_0" <cfif GetPerformanceRequirements.Setting_Display_Value EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									<cfset SettingsTemplateForm(NameField="Requirement_#Program_Perf_Req_ID#",NameFieldDesc="#Requirement_Name#",SettingDisplayValueInTable="Program_Perf_Mapping",SettingDisplayValueInTableID="#Program_Perf_Req_ID#")>
						<CFELSE>
						<!---Invoice/Billback--->
						<tr class="PerformanceRequirements" <cfif GetPerformanceRequirements.Setting_Display_Value EQ 0> style="display:none"</cfif>>
							<td>#Requirement_Name#</td>
							<td><input type="checkbox" name="Requirement_#Program_Perf_Req_ID#" value="1" <cfif InThisTemplate.Recordcount GT 0>checked</cfif> onClick="javascript:setDefaultCheck(this);"></td>
 							<td>
                            	<!--- 17677 RBL 12/10/08 [begin] --->
								<cfset selReqVal=0>
								<cfif (InThisTemplate.Recordcount AND InThisTemplate.Program_Perf_Req_Checked EQ 1)>
									<cfset selReqVal = 1>
								<cfelseif (InThisTemplate.Recordcount AND InThisTemplate.Program_Perf_Req_Checked EQ 2)>
									<cfset selReqVal = 2>
								<cfelseif (InThisTemplate.Recordcount AND InThisTemplate.Program_Perf_Req_Checked EQ 3)>
									<cfset selReqVal = 3>
								<cfelseif (InThisTemplate.Recordcount AND InThisTemplate.Program_Perf_Req_Checked EQ 4)>
									<cfset selReqVal = 4>
								<cfelseif (InThisTemplate.Recordcount AND NOT InThisTemplate.Program_Perf_Req_Checked)>
									<cfset selReqVal = 0>
								</cfif>
                            	<select name="Requirement_#Program_Perf_Req_ID#_Display" class="wd70">
                                    <option value="1" <cfif selReqVal EQ 1>selected</cfif>>Yes (default)</option>
                                    <option value="2" <cfif selReqVal EQ 2>selected</cfif>>No (default)</option>
                                    <option value="3" <cfif selReqVal EQ 3>selected</cfif>>Only Yes</option>
                                    <option value="4" <cfif selReqVal EQ 4>selected</cfif>>Only No</option>
				    <option value="0" <cfif selReqVal EQ 0>selected</cfif>>Neither</option>                                </select>
                            <!---
                            <input type="checkbox" name="Requirement_#Program_Perf_Req_ID#_Display" value="1" <cfif InThisTemplate.Recordcount GT 0 and InThisTemplate.Program_Perf_Req_Checked eq 1>checked</cfif>>
                            17677 RBL 12/10/08 [end] --->
                            </td>
						</tr>
						</CFIF>
					</cfloop>
				</cfif> <!---END FROM 1955:  NOT ListFindNoCase("Distributor Off-Invoice,Bid Request,USDA NOI", Generic_Type --->
<CFIF fromSettings_management neq 1> <!--- start :: cfif fromSettings_management neq 1 :: 11 ::Settings Management page 41974--->

				<cfif NOT ListFindNoCase("Distributor Off-Invoice,Bid Request,USDA NOI,LSAutoPAy", Generic_Type)>
					<cfif appsettings.gettemplatecodes_on()>
  				  <tr><th colspan="3"><hr></th></tr>
  					<tr>
  						<th colspan="3">Program Spending Types</th>
  					</tr>
						<cfset useLakebaseForgetTemplateCodes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("template_codes")>
<cfif useLakebaseForgetTemplateCodes>
	<cftry>
		<cfset getTemplateCodes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("template_codes", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "template_code.asc",
				"select" = "template_code,template_code_id"
			}), "template_code,template_code_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetTemplateCodes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetTemplateCodes>
<cfquery name="getTemplateCodes" datasource="#application.datasource#">
							select 	template_code,
									template_code_id
							from	template_codes
							where 	deleted = 0
							and 	active = 1
							order by template_code
						</cfquery>
</cfif>

						<TR>
							<td nowrap><span id="error_program_spending_type"></span>Program Spending Type</td>
							<TD  colspan="2">
									<SELECT NAME="Program_Spending_Type"  class="wd70">
									<OPTION value="0" selected>None</OPTION>
									<cfloop query="getTemplateCodes">
										<OPTION VALUE="#getTemplateCodes.template_code_id#" <cfif form.Program_Spending_Type eq getTemplateCodes.template_code_id>selected</cfif>>#getTemplateCodes.template_code#</OPTION>
									</cfloop>
									</SELECT>
								</TD>
							</TR>
							<TR>
							<td nowrap><span id="error_lumpsum_spending_type"></span>Lumpsum Spending Type</td>
							<TD colspan="2">
									<SELECT NAME="Lumpsum_Spending_Type" class="wd70">
									<OPTION value="0" selected>None</OPTION>
									<cfloop query="getTemplateCodes">
										<OPTION VALUE="#getTemplateCodes.template_code_id#" <cfif form.Lumpsum_Spending_Type eq getTemplateCodes.template_code_id>selected</cfif>>#getTemplateCodes.template_code#</OPTION>
									</cfloop>
									</SELECT>
							</TD>
						</TR>

					</cfif>

			</cfif><!------ Not Distributor Off-Invoice,Bid Request,USDA NOI ----->
			<cfif Generic_Type IS "LSAutoPay">
				<input type="hidden" name="Discount_Lump_Sums" value="1">
			</cfif>
</CFIF> <!--- end :: cfif fromSettings_management neq 1 :: 9 ::Settings Management page 41974--->

				  <tr id="Qualifications_heading_1"><th colspan="3"><hr></th></tr>
					<tr id="Qualifications_heading_2">
						<th colspan="3">Qualifications</th>
					</tr>
					<CFIF fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="Enable_Program_Qualifications",NameFieldDesc="Display Qualifications")>
						<cfset useLakebaseForvariables_qQualifications = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_qualifications")>
<cfif useLakebaseForvariables_qQualifications>
	<cftry>
		<cfset variables.qQualifications = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_qualifications", {
				"deleted" = "eq.0",
				"isactive" = "eq.1",
				"order" = "qualification_name.asc",
				"select" = "program_qualification_id,qualification_name,setting_display_value,settingsmanagement_id"
			}), "program_qualification_id,qualification_name,setting_display_value,settingsmanagement_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvariables_qQualifications = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvariables_qQualifications>
<cfquery name="variables.qQualifications" datasource="#application.datasource#">
					  		SELECT   Program_Qualification_Id, Qualification_Name, Setting_Display_Value, SettingsManagement_ID
					    		FROM Program_Qualifications 
					    		WHERE Deleted = 0
					         		AND IsActive = 1
					  		 ORDER BY Qualification_Name
					</cfquery>
</cfif>

					<CFELSE>
					<tr class="Qualifications" <cfif templateMgmtSettingsSecPage.Enable_Program_Qualifications EQ 0> style="display:none"</cfif>>
					 <td>Display Qualifications</td>
					 <td><input type="checkbox" name="Enable_Program_Qualifications" <cfif SelectSecondary.Enable_Program_Qualifications eq '1'>checked=checked</cfif> value="1"/></td>
					 <td>&nbsp;</td>
					</tr>
					<tr>					
						<td onClick="ClickToOpenLayer('ProgramQualificationsDocumentMsg','Program_Qualifications_Doc_Attach_Req');"><cfif SelectSecondary.Program_Qualifications_Doc_Msg neq ""><a style="text-decoration:underline"></cfif>Document Attachment Required<cfif SelectSecondary.Program_Qualifications_Doc_Msg neq ""></a></cfif></td>
						<td colspan="2"><input type="checkbox" name="Program_Qualifications_Doc_Attach_Req" onClick="ClickToOpenLayer('ProgramQualificationsDocumentMsg','Program_Qualifications_Doc_Attach_Req');" <cfif SelectSecondary.Program_Qualifications_Doc_Attach_Req eq '1'>checked=checked</cfif> value="1"/>
					</tr>
					<tr id="ProgramQualificationsDocumentMsg" style="display:none;">
						<td colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:red">Document Message</span>
						<br />
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<textarea name="Program_Qualifications_Doc_Msg" rows="4" cols="40" onPaste="javaScript: return textareaChecklength(75, this);"  onkeyPress="javaScript: return textareaChecklength(75, this);">#SelectSecondary.Program_Qualifications_Doc_Msg#</textarea></td>
						</td>
					</tr>
					<cfquery name="variables.qQualifications" datasource="#application.datasource#">
					  SELECT   a.Program_Qualification_Id
					         , a.Qualification_Name
					         , b.Qualification_Template_Mapping_Id
					         , b.Answer_Required
					         , a.Setting_Display_Value
					         , a.SettingsManagement_ID
					    FROM Program_Qualifications a
					         LEFT JOIN Qualification_Template_Mapping b ON a.Program_Qualification_Id = b.Program_Qualification_Id
					                                                   AND b.Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
					   WHERE a.Deleted = 0
					         AND a.IsActive = 1
					   ORDER BY Qualification_Name
					</cfquery>

					</CFIF>
					<cfif variables.qQualifications.recordCount>
						<cfquery dbtype="query" name="qmgmtSettingPrgQualifications">
							select Setting_Display_Value
							from variables.qQualifications
							where Setting_Display_Value = 1
						</cfquery>
						<tr id="Qualifications_heading_3"<cfif fromSettings_management eq 1 or qmgmtSettingPrgQualifications.recordcount eq 0>  style="display:none"</cfif>>
	 						<td class="sh42"><br><b>Qualification</b></td>
	 						<td class="sh42"><br><b>Include</b></td>
	            <td class="sh42"><br><b></b>Ans Req'd</td>
	 					</tr>
	 					<cfset MgmtSettingsSecPageInProgQ = CreateObject("component", "components.settings.settings_management.TemplateSettingsManager").getMgmtSettingsValInTBL(Generic_Type,ID,"Program_Qualifications","SettingsManagement_ID")>
						<cfloop query="variables.qQualifications">
						  <CFIF fromSettings_management eq 1>
							<tr>
							<td align="left">#variables.qQualifications.Qualification_Name#</td>
							<td align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
									<input type="radio" name="Program_Qualifications_#SettingsManagement_ID#" value="1" id="Program_Qualifications_#SettingsManagement_ID#_1" <cfif variables.qQualifications.Setting_Display_Value EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									<input type="radio" name="Program_Qualifications_#SettingsManagement_ID#" value="0" id="Program_Qualifications_#SettingsManagement_ID#_0" <cfif variables.qQualifications.Setting_Display_Value EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							</td>
							<cfset SettingsTemplateForm(NameField="Program_Qualifications_#SettingsManagement_ID#",NameFieldDesc="#variables.qQualifications.Qualification_Name#",SettingDisplayValueInTable="Program_Qualifications",SettingDisplayValueInTableID="#SettingsManagement_ID#")>
					  <CFELSE>
							<tr class="Qualifications" <cfif MgmtSettingsSecPageInProgQ[#SettingsManagement_ID#] EQ 0> style="display:none"</cfif>>
								<td>#variables.qQualifications.Qualification_Name#</td>
								<cfset variables.includeQualification = ( variables.qQualifications.Qualification_Template_Mapping_Id gt 0 )>
								<td><input type="checkbox" name="qualification_ids" <cfif variables.includeQualification> checked=checked </cfif> value="#variables.qQualifications.Program_Qualification_Id#"></td>
								<td><input type="checkbox" name="#variables.qQualifications.Program_Qualification_Id#" <cfif not variables.includeQualification> disabled=disabled <cfelseif variables.qQualifications.Answer_Required eq 1> checked=checked </cfif>></td>
							</tr>
						  </CFIF>
						</cfloop>
					</cfif>

<CFIF fromSettings_management neq 1> <!--- start :: cfif fromSettings_management neq 1 :: 11 ::Settings Management page 41974--->
			<!---Do only if they're using X Material--->
			<cfif appSettings.getUseXMaterial() IS 1>

				<cfparam name="DefaultProduct" default="">
				<cfparam name="DefaultProductName" default="No product selected">

				<cfparam name="Form.RedirectBack" default="0">

				<cfif IsDefined("form.Product_List")>
					<cfset DefaultProduct = form.Product_List>
				<cfelseif Action IS "Edit">
					<cfif len(trim(SelectSecondary.Default_Product)) GT 0>
						<cfset DefaultProduct = SelectSecondary.Default_Product>
					</cfif>
				</cfif>

				<cfif len(trim(DefaultProduct)) GT 0>

					<cfquery name="GetDefaultProductName" datasource="#application.datasource#">
						SELECT Description
						FROM BSA_Foodservice_Items_Master
						WHERE BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#DefaultProduct#" cfsqltype="cf_sql_idstamp">
					</cfquery>

					<cfset DefaultProductName = GetDefaultProductName.Description>

				</cfif>

				<input type="hidden" name="ExistingProductList" value="">
				<INPUT TYPE="Hidden" NAME="Product_List" 		VALUE="">

			  <tr><th colspan="3"><hr></th></tr>
				<tr>
					<th colspan="3">Default Product</th>
				</tr>
				<tr>
					<td colspan="3" valign="center">
						<input type="text" name="Default_Product_Name" size="40" READONLY="true" class="no_comment_input" value="#DefaultProductName#" valign="center">
						<strong>
							<CF_smallLink
								title = "search"
								url = "##"
								parameters = "onClick=""NewWindow('/common_files/contracts/product_Select_V1.cfm?SelectSingleSearchResultOnly=1&FieldName=Default_Product&FormName=SecondaryInfo','name','800','600','Yes', 'Yes');return false;"""
							>
						</strong>
					</td>
				</tr>
			</cfif>

				<!--- 17677 testing confused [begin] --->
				<cfif SelectSecondary.BidRequestStatusOn IS 1>
				  <tr><th colspan="3"><hr></th></tr>
					<tr>
						<th colspan="3">Line Item options</th>
					</tr>

					<tr>
						<td colspan="3">
							If you do not make a selection, both options will be available
						</td>
					</tr>

					<tr>
						<td>&nbsp; </td>
 						<td class="sh42"><br><b>Available</b></td>
 						<td class="sh42"><br><b>Default</b></td>
					</tr>

					<tr>
						<td><input type="checkbox" name="Line_Item_On" value="1" <cfif SelectSecondary.Bid_Line_Item_Option IS 1 OR SelectSecondary.Bid_Line_Item_Option IS 3>checked</cfif>></td>
						<td>Line Item On</td>
						<td><input type="radio" name="Bid_Line_Item_Option_Default" value="1" checked></td>
					</tr>

					<tr>
						<td><input type="checkbox" name="Line_Item_On" value="2" <cfif SelectSecondary.Bid_Line_Item_Option IS 2 OR SelectSecondary.Bid_Line_Item_Option IS 3>checked</cfif>></td>
						<td >Line Item Off</td>
						<td><input type="radio" name="Bid_Line_Item_Option_Default" value="2" <cfif SelectSecondary.Bid_Line_Item_Option_Default IS 2>checked</cfif>></td>
					</tr>

				</cfif>
				<!--- 17677 testing confused [end] --->

				</table>
                <!--- ...........................................................................
				............................ Right Inner Table [end] ............................
				............................................................................ --->

				</form>

				</td>

		</tr>

</table>
<!--- .......................................................................
............................ Outer Table [end] ..............................
........................................................................ --->

<cfif LockedBy_Current_User EQ 1>
<br>
<div align="center"><CF_button
			button_caption	=	"save and continue"
			button_action	=	"confirmCompletion();"
			button_type		=	"javascript_link"
			button_width	=	"250"
			button_color	=	"Navy"
			button_tip		=	"save and continue"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>	</div>
</cfif>

<form action="summary.cfm?ID=#ID#" method="post" name="Abandon">
	<input type="hidden" name="Garbage" value="0">
</form>


</div>
</CFIF> <!--- end :: cfif fromSettings_management neq 1 :: 12 ::Settings Management page 41974--->
</cfoutput>
<CFIF fromSettings_management neq 1> <!--- start :: cfif fromSettings_management neq 1 :: 10 ::Settings Management page 41974--->
<script>
	function setDefaultCheck(theObject) {
		displayObject = document.getElementById(theObject.name + "_display");
		if (theObject.checked )
			displayObject.checked = "true";
		else
			displayObject.checked = "";
	}

$(document).ready(function() {
// Custom_Fixed_Price_Options Discount_Fixed_Prices_Freight

	$('#Custom_Fixed_Price_Options').mousedown(function() {
	    if (!$(this).is(':checked')) {
	        if (!$('#Discount_Fixed_Prices_Freight').is(':checked')) {
				$(this).trigger("change");
			}
			else{
				alert("'Custom Fixed Price Options' are not available when '<cfoutput>#application.returned_customer_setting.distributor_label_singular# Level Fixed Price</cfoutput>' is ON.");
			}
	    }
	});

	$('#Discount_Fixed_Prices_Freight').mousedown(function() {
	    if (!$(this).is(':checked')) {
	        if (!$('#Custom_Fixed_Price_Options').is(':checked')) {
				$(this).trigger("change");
			}
			else{
				alert("'<cfoutput>#application.returned_customer_setting.distributor_label_singular# Level Fixed Price</cfoutput>' is not available when 'Custom Fixed Price Options' are ON.");
			}
	    }
	});

	$("#outerTable td:first-child").addClass("il52");

	/* disable all input and dropdown elements */
	<cfif LockedBy_Current_User NEQ 1>
	  $("#outerTable input[type!=hidden], #outerTable select").attr("disabled", "disabled");
	<cfelse>
		$('input[name=qualification_ids]').change(function() {
	  	// disable answer required checkbox when qualification is not included
			$('input[name=' + $(this).val() + ']').prop("disabled", !$(this).prop("checked"));
		});
	</cfif>

});
</script>
<script>
if ( $('.UOMforGroups:visible').length == 0 ) {
  $('#UOMforGroups_heading_1').hide();
}
if ( $('.UOMforGroups:visible').length == 0 ) {
  $('#UOMforGroups_heading_2').hide();
}
if ( $('.PaymentFrequency:visible').length == 0 ) {
  $('#PaymentFrequency_heading_1').hide();
}
if ( $('.PaymentFrequency:visible').length == 0 ) {
  $('#PaymentFrequency_heading_2').hide();
}
if ( $('.VolumeCalculations:visible').length == 0 ) {
  $('#VolumeCalculations_heading_1').hide();
}
if ( $('.VolumeCalculations:visible').length == 0 ) {
  $('#VolumeCalculations_heading_2').hide();
}
if ( $('.DiscountTypes:visible').length == 0 ) {
  $('#DiscountTypes_heading').hide();
}
if ( $('.DiscountMinMax:visible').length == 0 ) {
  $('#DiscountMinMax_heading_1').hide();
}
if ( $('.DiscountMinMax:visible').length == 0 ) {
  $('#DiscountMinMax_heading_2').hide();
}
if ( $('.PerformanceRequirements:visible').length == 0 ) {
  $('#PerformanceRequirements_heading_1').hide();
}
if ( $('.PerformanceRequirements:visible').length == 0 ) {
  $('#PerformanceRequirements_heading_2').hide();
}
if ( $('.PerformanceRequirements:visible').length == 0 ) {
  $('#PerformanceRequirements_heading_3').hide();
}
if ( $('.Qualifications:visible').length == 0 ) {
  $('#Qualifications_heading_1').hide();
}
if ( $('.Qualifications:visible').length == 0 ) {
  $('#Qualifications_heading_2').hide();
}
if ( $('.Qualifications:visible').length == 0 ) {
  $('#Qualifications_heading_3').hide();
}
if ( $('.PaymentPaidTo:visible').length == 0 ) {
  $('#PaymentPaidTo_heading_1').hide();
}
if ( $('.PaymentPaidTo:visible').length == 0 ) {
  $('#PaymentPaidTo_heading_2').hide();
}

</script>
</body>
</html>
</CFIF><!--- end :: cfif fromSettings_management neq 1 :: 10 ::Settings Management page 41974--->
<!--- <cfinclude template="/includes/footer.cfm">

</body>
</html> --->
<cffunction name="SettingsTemplateForm">
	<cfargument name="NameField" type="string" required="true" default="">
	<cfargument name="NameFieldDesc" type="string" required="true" default="">
	<cfargument name="SettingDisplayValueInTable" type="string" required="false" default="">
	<cfargument name="SettingDisplayValueInTableID" type="string" required="false" default="0">

	<cfset arguments.NameFieldDesc =  ReReplace(arguments.NameFieldDesc, "&", " ", "ALL") />
	<cfoutput>
		<CFIF len(arguments.SettingDisplayValueInTable) GT 0>
			<cfset LinkExceptions = "Update Exceptions">
			<td>
				<CF_smallLink
					title = "#LinkExceptions#"
					url = "##"
					parameters = "onClick=""javascript: return AddExceptionsTBL('#Generic_Type#','0','#arguments.NameFieldDesc#','#arguments.SettingDisplayValueInTable#','#arguments.SettingDisplayValueInTableID#');"""
				>
				<font>&nbsp;</font>
			</td>
		<CFELSE>
			<tr>
				<td align="left">#arguments.NameFieldDesc#</td>
				<td align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
					<input type="radio" name="#arguments.NameField#" value="1" id="#arguments.NameField#_1" <cfif templateSettings[arguments.NameField] EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<input type="radio" name="#arguments.NameField#" value="0" id="#arguments.NameField#_0" <cfif templateSettings[arguments.NameField] EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				</td>
				<cfif strException_Active[arguments.NameField] EQ 0>
					<cfset LinkExceptions = "Select Exceptions">
				<cfelse>
					<cfset LinkExceptions = "Update Exceptions">
				</cfif>
				<td>
					<CF_smallLink
						title = "#LinkExceptions#"
						url = "##"
						parameters = "onClick=""javascript: return AddExceptions('#Generic_Type#','#SettingIDs[arguments.NameField]#','#arguments.NameFieldDesc#');"""
					>
					<span id="picon_#SettingIDs[arguments.NameField]#"></span>
					<font>&nbsp;</font>
				</td>
		</CFIF>
  		</tr>
	</cfoutput>
</cffunction>
