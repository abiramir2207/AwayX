<cfparam name="fromSettings_management" default=0>
<cfparam name="url.DownloadSettings" default=0>

<cfset useLakebaseForEachInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("units_of_measure")>
<cfif useLakebaseForEachInfo>
	<cftry>
		<cfset EachInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("units_of_measure", {
				"unit_of_measure_id" = "eq.5",
				"select" = "unit_of_measure_desc,abbreviation,unit_of_measure_desc_singular"
			}), "unit_of_measure_desc,abbreviation,unit_of_measure_desc_singular"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForEachInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForEachInfo>
<cfquery name="EachInfo" datasource="#application.datasource#">
	SELECT Unit_Of_Measure_Desc,Abbreviation,Unit_of_Measure_Desc_Singular
	FROM Units_of_Measure
	WHERE Unit_Of_Measure_ID= 5
</cfquery>
</cfif>

<cfif url.DownloadSettings EQ 0>
	<cfset TemplatePage = 'Details'>
	<cfinclude template="SettingsTemplateFormFunction.cfm">
</cfif>

<cfif fromSettings_management neq 1> <!--- start :: cfif fromSettings_management neq 1 :: 1 ::Settings Management page 41974--->
<!DOCTYPE HTML>
<html>
<head>
	<cfsavecontent variable="head_content">
		<link rel="stylesheet" href="/styles/jQueryUI_18/jquery-ui-1.8.10.custom.css" type="text/css" />
		<cfset jQueryUI.version = "1.8.23">
		<cfset jQueryUI.widgets = "full">
		<cfinclude template="/common_files/jQuery.cfm">
		<cf_include files="/styles/css-loader.css">
		<style>
			#stored_records th {
				font-weight: bold;
				font-size: 12px;
				text-align: left;
				vertical-align: top;
			}
  			span.ui-displayRow { display: inline-block; }
            img.in_volume_sleeve, img.in_volume_each {
                margin-left: 4px;
                width: 10px;
                height: 10px;
                display: none;
            }
            img.in_volume_sleeve.checked, img.in_volume_each.checked {
                display: inline-block;
            }
		</style>
	</cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>
<body <cfif Generic_Type IS NOT "Brokerage">onLoad="CheckCriteria();showHideInventoryUOM();showHidePriceListType();"<cfelse>showHideInventoryUOM();</cfif>>
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
<cfif ! url.DownloadSettings>
	<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
</cfif>

<cfset displayheader = 1 >

<cfset appSettings = application.appsettingsGet />
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<cfset SPA = CreateObject("component","components.user.settingsPanelAccess").init() />
<cfset getSPA = SPA.getSPAccess()>

<cfif getSPA.Program_Wizard_Index EQ 0>
	<CFLOCATION URL="/Manufacturers/home.cfm" ADDTOKEN="yes">
</cfif>
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
<cfparam name="Form.price_list_type" default="0" /><!--- 71241 --->

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
	<CF_smallLink title = "program wizard"url = "index.cfm">
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
<cfif Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 0>
	<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
</cfif>

<cfset PAGE_TITLE = "Create or Edit a Program Type">

	<style>
		TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
		.header {font-size: 12px;}
		.no_comment_input{border:	1px solid silver;color:Navy;	}
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

	<script SRC="/Script/javascript/dhtml.js"></script>
	<script SRC="/Script/javascript/dom_common.js"></script>
	<script language="JavaScript" src="/script/javascript/string_functions.js"></script>

<script>

	function showHideGroupProgramsUOM(thisObj){
		var trObj1 = document.all.tr1_GroupProgramsUOM;
		var trObj2 = document.all.tr2_GroupProgramsUOM;
		var trObj3 = document.all.tr3_GroupProgramsUOM;
		var trObj4 = document.all.tr4_GroupProgramsUOM;

		if(thisObj.checked){
			trObj1.style.display = "";
			trObj2.style.display = "";
			trObj3.style.display = "";
			trObj4.style.display = "";
		}
		else	{
			trObj1.style.display = "none";
			trObj2.style.display = "none";
			trObj3.style.display = "none";
			trObj4.style.display = "none";
		}
	}

	function showHideInventoryUOM(){
	/* If "pound" UOM option is turned ON, enable the "Restrict on Inventory UOM" (pound) option */
		if ($('#RateTypeOption_1').is(":checked")){
			$('.RestrictOnInventoryUOMPound').attr("disabled", false);
		}
		else{
			$('.RestrictOnInventoryUOMPound').prop('checked',false);
			$('.RestrictOnInventoryUOMPound').attr("disabled", true);
		}
	/* If "Case" UOM option is turned ON, enable the "Restrict on Inventory UOM" (Case) option */
		if ($('#RateTypeOption_2').is(":checked")){
			$('.RestrictOnInventoryUOMCase').attr("disabled", false);
		}
		else{
			$('.RestrictOnInventoryUOMCase').prop('checked',false);
			$('.RestrictOnInventoryUOMCase').attr("disabled", true);
		}
	}
	function showHidePriceListType()
	{
		<cfoutput>
			var show_Fixed_Price_Populates_Price_List_Special = '#templateMgmtSettingsSecPage.Fixed_Price_Populates_Price_List_Special#';
			var show_price_list_type = '#templateMgmtSettingsSecPage.price_list_type#';
		</cfoutput>

		/* If "Fixed Price Populates Price List" is not hidden on the "template settings" page */
		if(show_Fixed_Price_Populates_Price_List_Special)
		{
			/* Turn ON/OFF the "Price List Type" option based on "Fixed Price Populates Price List" checkbox. */
			if($('input[name=Fixed_Price_Populates_Price_List_Special]').prop('checked')){
				$('#price_list_type_header').show();
			}
			else{
				$('#price_list_type_header').hide();
			}
		}
		else{
			$('input[name=Fixed_Price_Populates_Price_List_Special]').val('0');
			$('#price_list_type_header').hide();
		}

		/* If "price list type" is hidden on the "template settings" page */
		if(show_price_list_type == 0){
				$('#price_list_type_header').hide();
		}
	}
	function minPerformanceRequirements(){
		for (i = 0; i < document.all.minPerfRequirementsOn.length; i++){
		 	 if (document.all.minPerfRequirementsOn[i].checked){
				 if (document.all.minPerfRequirementsOn[i].value == '0'){
				 	document.all.minPerfRequirements.value = '0';
				 	document.all.minPerfRequirements.disabled = true;
				 }
				 else{
				    document.all.minPerfRequirements.value = '1';
				 	document.all.minPerfRequirements.disabled = false;
		         }
			 }

		}
	 }

	 function maxPerformanceRequirements()	{
		for (i = 0; i < document.all.maxPerfRequirementsOn.length; i++){
		 	 if (document.all.maxPerfRequirementsOn[i].checked){
				 if (document.all.maxPerfRequirementsOn[i].value == '0'){
				 	document.all.maxPerfRequirements.value = '*';
				 	document.all.maxPerfRequirements.disabled = true;
				 }
				 else{
				 	document.all.maxPerfRequirements.disabled = false;
		         }
			 }
		}
	 }

    $(function(){
        const default_uom = $("input[name=RateTypeDefault]:checked").val();

        // each, sleeve is the default ~ uncheck + disable case/lb in volume
        if (default_uom == 5 || default_uom == 7) {
            disable_case_pound();
        }
    });

    function disable_case_pound() {
        $("input[name=Volume_Page_UOM_LB], input[name=Volume_Page_UOM_CS]").prop({ checked: false, disabled: true});
    }


	function DefaultGroupUOM(thisObjval){
		var thisSubObj	=	document.getElementById("Groups_UOM_Default_" + thisObjval);
		var DiffUOM		=	document.all.Group_Programs_UOM.checked;

		if (DiffUOM){}
		else{
            if (thisSubObj)
			    thisSubObj.checked = true;
        } // end : if (DiffUOM){}

        // each ~ show checkmark in volume, uncheck + disable case/lb in volume
        if ( thisObjval == '5' ) {
            $("img.in_volume_each").addClass("checked");
            $("img.in_volume_sleeve").removeClass("checked");
            disable_case_pound();
        }
        // sleeve ~ show checkmark in volume, uncheck + disable case/lb in volume
        else if ( thisObjval == '7' ) {
            $("img.in_volume_sleeve").addClass("checked");
            $("img.in_volume_each").removeClass("checked");
            disable_case_pound();
        }
        // others ~ hide each/sleeve checkmarks
        else {
            $("img.in_volume_sleeve, img.in_volume_each").removeClass("checked");
            $("input[name=Volume_Page_UOM_LB], input[name=Volume_Page_UOM_CS]").prop("disabled", false);
        }
	}

	function selectGroupUOM(thisObj)	{
		var thisObjName		=	thisObj.name;
		var thisObjchk		=	thisObj.checked;
		var DiffUOM			=	document.all.Group_Programs_UOM.checked;

		if (DiffUOM){}
		else	{
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


function changeDisableOtherCheckBoxes(thisObj, OtherObj){
	OtherObj.disabled = !(thisObj.checked);
}

function isDefined(item) {
	return (typeof item != 'undefined');
}

var ErrorCount = 0;
function confirmCompletion(){
	var ErrorCount = 0;
  var errorGBDefault = 0;
		<cfif Generic_Type IS NOT "USDA NOI">
		<cfif OperatorBid EQ false>
			<cfif form.price_protection_on EQ 1>
				if (isDefined(document.all.RateTypeOption_3)){
					if(document.all.RateTypeOption_3.checked == true){
						ErrorCount++;
						queueMessage("You cannot select % as UOM when price protection is on.", document.all.error_RateTypeOption_3);
					}else{
						clearQueue(document.all.error_RateTypeOption_3);
					}
			}
			</cfif>
		<!---Rate Type--->
		<cfif Generic_Type NEQ "LSAutoPay">
			if(document.all.RateTypeDefault[0].checked && document.all.RateTypeOption_1.checked == false){
				ErrorCount++;
				queueMessage("To set an item as default, you must choose to include it.", document.all.error_RateTypeOption_1);
			}else{
				clearQueue(document.all.error_RateTypeOption_1);
			}

			if(document.all.RateTypeDefault[1].checked && document.all.RateTypeOption_2.checked == false){
				ErrorCount++;
				queueMessage("To set an item as default, you must choose to include it.", document.all.error_RateTypeOption_2);
			}else{
				clearQueue(document.all.error_RateTypeOption_2);
			}

				<cfif (Generic_Type IS "Distributor Off-Invoice" OR Generic_Type IS "Distributor Trade/Shelter") and EZButton_On EQ 0>
				if(document.all.RateTypeDefault[2].checked && document.all.RateTypeOption_3.checked == false){
					ErrorCount++;
					queueMessage("To set an item as default, you must choose to include it.", document.all.error_RateTypeOption_3);
				}else{
					clearQueue(document.all.error_RateTypeOption_3);
				}
				</cfif>

			if(document.all.RateTypeDefault[3].checked && document.all.RateTypeOption_4.checked == false){
				ErrorCount++;
				queueMessage("To set an item as default, you must choose to include it.", document.all.error_RateTypeOption_4);
			}else{
				clearQueue(document.all.error_RateTypeOption_4);
			}
			if(document.all.RateTypeDefault[4].checked && document.all.RateTypeOption_5.checked == false){
				ErrorCount++;
				queueMessage("To set an item as default, you must choose to include it.", document.all.error_RateTypeOption_5);
			}else{
				clearQueue(document.all.error_RateTypeOption_5);
			}
			if(document.all.RateTypeDefault[5].checked && document.all.RateTypeOption_6.checked == false){
				ErrorCount++;
				queueMessage("To set an item as default, you must choose to include it.", document.all.error_RateTypeOption_6);
			}else{
				clearQueue(document.all.error_RateTypeOption_6);
			}
			// if(document.all.Discount_Fixed_Prices)
			//  If Fixed is ON OR % is not available then we require CS OR LB to Be selected.
			// D32010:JS error - Discount_Fixed_Prices.checked' is null or not an object
			<cfif SelectSecondary.Allow_Vendor_Only EQ 0>
			if((document.all.Discount_Fixed_Prices && document.all.Discount_Fixed_Prices.checked == true) || (document.all.Fixed_Rebate_Grid_Option && document.all.Fixed_Rebate_Grid_Option.checked == true) || isDefined(document.all.RateTypeOption_3) == false){
				if(document.all.RateTypeOption_1.checked == false && document.all.RateTypeOption_2.checked == false && document.all.RateTypeOption_4.checked == false && document.all.RateTypeOption_5.checked == false && document.all.RateTypeOption_6.checked == false){
					ErrorCount++;
					//conditional message
					if(isDefined(document.all.RateTypeOption_3) == false){
						queueMessage("Please include a Unit of Measure option", document.all.error_RateTypeDefault);
					}else{
						queueMessage("Please include either cases or pounds as a Unit of Measure option when Fixed Price Discount Type is turned on", document.all.error_RateTypeDefault);
					}
				}else{
					clearQueue(document.all.error_RateTypeDefault);
				}

                if (
                    document.all.Volume_Page_UOM_CS.checked == false
                    && document.all.Volume_Page_UOM_LB.checked == false
                    && $("img.in_volume_each.checked").length == 0
                    && $("img.in_volume_sleeve.checked").length == 0
                    ) {
					ErrorCount++;
					queueMessage("Please include a Volume Page Unit of Measure", document.all.error_Volume_Page_UOM);
				}else{
					clearQueue(document.all.error_Volume_Page_UOM);
				}

			}
			else // % is an option so we can check for it
			{
			</cfif>

				if (document.all.RateTypeOption_1.checked == false && document.all.RateTypeOption_2.checked == false && document.all.RateTypeOption_3.checked == false && document.all.RateTypeOption_4.checked == false && document.all.RateTypeOption_5.checked == false && document.all.RateTypeOption_6.checked == false) {
					ErrorCount++;
					queueMessage("Please include a Unit of Measure option", document.all.error_RateTypeDefault);
				}else{
					clearQueue(document.all.error_RateTypeDefault);
				}

				// if (document.all.Volume_Page_UOM_CS.checked == false && document.all.Volume_Page_UOM_LB.checked == false) {
                if (
                    document.all.Volume_Page_UOM_CS.checked == false
                    && document.all.Volume_Page_UOM_LB.checked == false
                    && $("img.in_volume_each.checked").length == 0
                    && $("img.in_volume_sleeve.checked").length == 0
                    ) {
					ErrorCount++;
					queueMessage("Please include a Volume Page Unit of Measure", document.all.error_Volume_Page_UOM);
				}else{
					clearQueue(document.all.error_Volume_Page_UOM);
				}

			<cfif SelectSecondary.Allow_Vendor_Only EQ 0>
			}
			</cfif>

		</cfif>

		<cfif Generic_Type IS "Distributor Off-Invoice">

			 if 	((document.all.Min_OffInvoice_Pound.value > document.all.Max_OffInvoice_Pound.value) && (document.all.Max_OffInvoice_Pound.value != "")){
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_OffInvoice_Pound);
			}else{
				clearQueue(document.all.error_OffInvoice_Case);
			}
		  if 	((document.all.Min_OffInvoice_Case.value > document.all.Max_OffInvoice_Case.value) && (document.all.Max_OffInvoice_Case.value != ""))
			{
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_OffInvoice_Case);
			}else{
				clearQueue(document.all.error_OffInvoice_Case);
			}
			 if 	((document.all.Min_OffInvoice_Percent.value > document.all.Max_OffInvoice_Percent.value) && (document.all.Max_OffInvoice_Percent.value != ""))
			{
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_OffInvoice_Percent);
			}else{
				clearQueue(document.all.error_OffInvoice_Percent);
			}
		<!---Generic type is off invoice--->
		</cfif>

		<!------ ******** Bid Request ******** ----->
		<cfif Generic_Type IS "Bid Request">
			 if 	((document.all.Min_BidRequest_Pound.value > document.all.Max_BidRequest_Pound.value) && (document.all.Max_BidRequest_Pound.value != "")){
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_BidRequest_Pound);
			}else{
				clearQueue(document.all.error_BidRequest_Case);
			}
			if 	((document.all.Min_BidRequest_Case.value > document.all.Max_BidRequest_Case.value) && (document.all.Max_BidRequest_Case.value != "")){
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_BidRequest_Case);
			}else{
				clearQueue(document.all.error_BidRequest_Case);
			}

			<!------ check if the default for line item is included ----->
			<cfif SelectSecondary.BidRequestStatusOn IS 1>
			var Chk_Bid_Line_Item_Option_Default = document.all.Bid_Line_Item_Option_Default;
			var Chk_Line_Item_On = document.all.Line_Item_On;
			var defautIsWrong = false;
			if(Chk_Bid_Line_Item_Option_Default[0].checked == true && Chk_Line_Item_On[0].checked == false && Chk_Line_Item_On[1].checked == true){
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
			}else{
				clearQueue(document.all.error_Bid_Line_Item_Option_Default);
			}
			</cfif>

		<!---Generic type is Bid request--->
		</cfif>
		<!---NOI --->
		</cfif>
		<!---Generic type is bid request or off invoice--->
		</cfif>

		<cfquery name="GetCurrencyTypes" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Currency
			WHERE 	Deleted = 0
			AND 	Active = 1
			ORDER BY Currency_Name
		</cfquery>
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
		if(anyCurrencySelection == 0){
			ErrorCount++;
			queueMessage("Please include at least one currency option.", document.all.error_Currency_Selection);
		}else{
			clearQueue(document.all.error_Payment_Type_Selection);
		}
		<!------ if a currrency is set as default, it must be selected ----->
		if(currencyDefaultSelectionWrong != 0){
			ErrorCount++;
			queueMessage("If a currency is set as default, it must be selected.", document.all.error_Currency_Selection);
		}else{
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
			if(document.all.ClaimMechDefaultOption[#DefaultValue#].checked && document.all.Payment_Type_#Payment_Type_ID#.checked == false){
				paymentTypeDefaultSelectionWrong++;
			}
			<cfelse>
			if(document.all.ClaimMechDefaultOption.checked && document.all.Payment_Type_#Payment_Type_ID#.checked == false){
				paymentTypeDefaultSelectionWrong++;
			}
			</cfif>

			if(document.all.Payment_Type_#Payment_Type_ID#.checked == true){
				anyPaymentTypeSelection++;
			}

			<cfset DefaultValue = DefaultValue + 1>
		</cfoutput>

	<!------ atleast one payment type option should be selected ----->
	if(anyPaymentTypeSelection == 0){
		ErrorCount++;
		queueMessage("Please include at least one claim mechanic", document.all.error_Payment_Type_Selection);
	}else{
		clearQueue(document.all.error_Payment_Type_Selection);
	}

	<!------ to select as default, that item should be selected ----->
	if(paymentTypeDefaultSelectionWrong){
		ErrorCount++;
		queueMessage("To set an item as default, you must choose to include it. ", document.all.error_Payment_Type_Default);
	}else{
		clearQueue(document.all.error_Payment_Type_Default);
	}

		<!---Payment Frequency--->

		if(document.all.PayCycleOption_1.checked == false && document.all.PayCycleOption_2.checked == false && document.all.PayCycleOption_3.checked == false && document.all.PayCycleOption_4.checked == false && document.all.PayCycleOption_5.checked == false && document.all.PayCycleOption_6.checked == false && document.all.PayCycleOption_7.checked == false && document.all.PayCycleOption_8.checked == false && document.all.PayCycleOption_9.checked == false && document.all.PayCycleOption_10.checked == false && document.all.PayCycleOption_11.checked == false && document.all.PayCycleOption_12.checked == false)
<!---NOTE: Please also add logic into activate.cfm -- it checks to make sure this is all in order before allowing the template to be activated --->
		{
			ErrorCount++;
			queueMessage("Please include at least one payment cycle", document.all.error_PayCycleOption_1);
		}else{
			clearQueue(document.all.error_PayCycleOption_1);
		}

		if(document.all.PayCycleDefaultOption[0].checked && document.all.PayCycleOption_1.checked == false){
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_1);
		}else{
			clearQueue(document.all.error_PayCycleOption_1);
		}

		if(document.all.PayCycleDefaultOption[1].checked && document.all.PayCycleOption_2.checked == false){
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_2);
		}else{
			clearQueue(document.all.error_PayCycleOption_2);
		}

		if(document.all.PayCycleDefaultOption[2].checked && document.all.PayCycleOption_3.checked == false){
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_3);
		}else{
			clearQueue(document.all.error_PayCycleOption_3);
		}

		if(document.all.PayCycleDefaultOption[3].checked && document.all.PayCycleOption_4.checked == false){
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_4);
		}else{
			clearQueue(document.all.error_PayCycleOption_4);
		}

		if(document.all.PayCycleDefaultOption[4].checked && document.all.PayCycleOption_5.checked == false){
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_5);
		}else{
			clearQueue(document.all.error_PayCycleOption_5);
		}

		if(document.all.PayCycleDefaultOption[5].checked && document.all.PayCycleOption_6.checked == false){
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_6);
		}else{
			clearQueue(document.all.error_PayCycleOption_6);
		}

		if(document.all.PayCycleDefaultOption[6].checked && document.all.PayCycleOption_7.checked == false){
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_7);
		}else{
			clearQueue(document.all.error_PayCycleOption_7);
		}

		if(document.all.PayCycleDefaultOption[7].checked && document.all.PayCycleOption_8.checked == false){
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_8);
		}else{
			clearQueue(document.all.error_PayCycleOption_8);
		}

		if(document.all.PayCycleDefaultOption[8].checked && document.all.PayCycleOption_9.checked == false){
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_9);
		}else{
			clearQueue(document.all.error_PayCycleOption_9);
		}

		if(document.all.PayCycleDefaultOption[9].checked && document.all.PayCycleOption_10.checked == false){
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_10);
		}else{
			clearQueue(document.all.error_PayCycleOption_10);
		}

		if(document.all.PayCycleDefaultOption[10].checked && document.all.PayCycleOption_11.checked == false){
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_11);
		}else{
			clearQueue(document.all.error_PayCycleOption_11);
		}

		//D47825 :: Payment frequency:  Add fiscal year option
		if(document.all.PayCycleDefaultOption[11].checked && document.all.PayCycleOption_12.checked == false){
			ErrorCount++;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_PayCycleOption_12);
		}else{
			clearQueue(document.all.error_PayCycleOption_12);
		}
		//D47825 :: Payment frequency:  Add fiscal year option
			//TSF: Modification Bid Request
			//validate for discount types only if it's not bid request
	<cfif Generic_Type IS NOT "Bid Request" AND Generic_Type IS NOT "USDA NOI" AND Generic_Type NEQ "LSAutoPay">
		<cfif Generic_Type IS NOT "Brokerage" AND EZButton_On eq 0>
		<cfif SelectSecondary.Allow_Vendor_Only EQ 0>
			<cfif EZButton_On EQ 0>
				if(document.all.Discount_Fixed_Prices.checked == false && document.all.Discount_Rebates.checked == false && document.all.Discount_Lump_Sums.checked == false && document.all.Discount_Growth.checked == false && document.all.Discount_Formula_Pricing.checked == false && document.all.Fixed_Rebate_Grid_Option == false<cfif application.bidPricingLinksAvailable> && document.all.Bid_Rule_Option.checked == false</cfif>)
			<cfelse>
				if(document.all.Discount_Fixed_Prices.checked == false && document.all.Discount_Rebates.checked == false && document.all.Discount_Lump_Sums.checked == false)
			</cfif>
				{
					ErrorCount++;
					queueMessage("Please include at least one discount type", document.all.error_Discount_Fixed_Prices);
				}else{
					clearQueue(document.all.error_Discount_Fixed_Prices);
				}
		<cfelse>
				if(document.all.Discount_Lump_Sums.checked == false){
					ErrorCount++;
					queueMessage("Please include lumpsum discount type", document.all.error_Discount_Lump_Sum);
				}else{
					clearQueue(document.all.error_Discount_Lump_Sum);
				}
		</cfif>
		</cfif><!--- Not Brokerage  --->
		<cfif appsettings.gettemplatecodes_on()>
		<cfif generic_type NEQ 'Direct Pricing'AND Generic_Type NEQ "Brokerage" AND Generic_Type NEQ "LSAutoPay">
			if ((document.all.Discount_Rebates.checked ==  true || document.all.Discount_Growth.checked ==  true)  && document.all.Program_Spending_Type.value == 0){
				ErrorCount++;
				queueMessage("Please select a Program Spending Type", document.all.error_program_spending_type);
			}else{
				clearQueue(document.all.error_program_spending_type);
			}
			if (document.all.Discount_Lump_Sums.checked ==  true  && document.all.Lumpsum_Spending_Type.value == 0){
				ErrorCount++;
				queueMessage("Please select a Lumpsum Spending Type", document.all.error_lumpsum_spending_type);
			}else{
				clearQueue(document.all.error_lumpsum_spending_type);
			}
		</cfif><!--- Not Brokerage and Not Direct Pricing --->


			<!---Mins can't be bigger than maxes--->
			<cfif Generic_Type IS NOT "Brokerage" AND Generic_Type NEQ "LSAutoPay">
			<!---Fixed pound--->
			if ((document.all.Min_Fixed_Pound.value > document.all.Max_Fixed_Pound.value) && (document.all.Max_Fixed_Pound.value != "")){
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_Fixed_Pound);
			}else{
				clearQueue(document.all.error_Fixed_Pound);
			}

			<!---Fixed case--->
			 if ((document.all.Min_Fixed_Case.value > document.all.Max_Fixed_Case.value) && (document.all.Max_Fixed_Case.value != "")){
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_Fixed_Case);
			}else{
				clearQueue(document.all.error_Fixed_Case);
			}
			</cfif> <!--- Not Brokerage --->
		<cfif generic_type NEQ 'Direct Pricing' AND Generic_Type NEQ "LSAutoPay">
			<!---Rebate pound--->
			 if ((document.all.Min_Rebate_Pound.value > document.all.Max_Rebate_Pound.value) && (document.all.Max_Rebate_Pound.value != "")){
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_Rebate_Pound);
			}else{
				clearQueue(document.all.error_Rebate_Pound);
			}

			<!---Rebate case--->
			 if ((document.all.Min_Rebate_Case.value > document.all.Max_Rebate_Case.value) && (document.all.Max_Rebate_Case.value != "")){
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_Rebate_Case);
			}else{
				clearQueue(document.all.error_Rebate_Case);
			}

			<!---Rebate percent--->
			 if ((document.all.Min_Rebate_Percent.value > document.all.Max_Rebate_Percent.value) && (document.all.Max_Rebate_Percent.value != "")){
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_Rebate_Percent);
			}else{
				clearQueue(document.all.error_Rebate_Percent);
			}
			<cfif Generic_Type IS NOT "Brokerage" >
			<!---Growth Pound--->
			 if ((document.all.Min_Growth_Pound.value > document.all.Max_Growth_Pound.value) && (document.all.Max_Growth_Pound.value != "")){
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_Growth_Pound);
			}else{
				clearQueue(document.all.error_Growth_Pound);
			}

			<!---Growth Case--->
			 if ((document.all.Min_Growth_Case.value > document.all.Max_Growth_Case.value) && (document.all.Max_Growth_Case.value != "")){
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_Growth_Case);
			}else{
				clearQueue(document.all.error_Growth_Case);
			}

			<!---Growth Percent--->
			 if ((document.all.Min_Growth_Percent.value > document.all.Max_Growth_Percent.value) && (document.all.Max_Growth_Percent.value != "")){
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_Growth_Percent);
			}else{
				clearQueue(document.all.error_Growth_Percent);
			}

			<!---Formula Pound--->
			if ((document.all.Min_Formula_Pound.value > document.all.Max_Formula_Pound.value) && (document.all.Max_Formula_Pound.value != "")){
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_Formula_Pound);
			}else{
				clearQueue(document.all.error_Formula_Pound);
			}

			<!---Formula Percent--->
			if ((document.all.Min_Formula_Percent.value > document.all.Max_Formula_Percent.value) && (document.all.Max_Formula_Percent.value != "")){
				ErrorCount++;
				queueMessage("Your minimum value must be smaller than your maximum value", document.all.error_Formula_Percent);
			}else{
				clearQueue(document.all.error_Formula_Percent);
			}
			</cfif> <!--- Not Brokerage --->
		</cfif>
		</cfif>
		<cfelseif Generic_Type IS "Bid Request">
			if( document.all.Discount_Rebates.checked == false && document.all.Discount_BidRequest.checked == false){
				ErrorCount++;
				queueMessage("Please include at least one discount type", document.all.error_Discount_BidRequest_Prices);
			}else{
				clearQueue(document.all.error_Discount_BidRequest_Prices);
			}
		</cfif>
		</cfif>

<cfif Generic_Type EQ "Operator-Deviated Pricing" or Generic_Type EQ "Operator Direct or HQ Programs">

 <cfelse>
    if(document.all.Distributor_Off_Invoice_Volume.checked == true){
      if (document.all.Volume_Distributor_Template_GroupB_Default[0].checked == true){
        errorGBDefault = 1;
      }
    }
    if(document.all.Distributor_Billback_Volume.checked == true ){
       if (document.all.Volume_Distributor_Template_GroupB_Default[1].checked == true){
        errorGBDefault = 1;
      }
    }
    if(document.all.Adjust_For_Credits.checked == true){
       if (document.all.Volume_Distributor_Template_GroupB_Default[2].checked == true){
        errorGBDefault = 1;
      }
    }

    if (document.all.Volume_Distributor_Template_GroupB_Default[3].checked == true){
      errorGBDefault = 1;
    }
    if (errorGBDefault == 0){
			ErrorCount++;
			queueMessage("Default should be selected against a selected Volume Display option or Invoice should be selected", document.all.error_Volume_Selection);
    }else{
	clearQueue(document.all.error_Volume_Selection);
}
</cfif>



<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0){
		let seq = 100;
		$("input.seq").each(function() { seq = seq + 10;
				/*assign sequence value based on position*/
				$(this).val( seq );
		});
		SecondaryInfo.submit()
	}else{
		showMessageWindow()
	}
}

	function checkType(objPref){
		var includeVar = eval("document.all." + objPref);
		var itemVar = eval("document.all." + objPref + "_Item_Level");
		var groupVar = eval("document.all." + objPref + "_Group_Level");
		var eventObj = event.srcElement;

		// enter this logic when we are unchecking a checkbox
		if(!eventObj.checked){
			<cfif appSettings.getSearchSequenceOn()>
			//when search sequence is on, if item or group are unchecked then uncheck the include checkbox
			if (itemVar.checked == false || groupVar.checked == false){
				includeVar.checked = false;
				if(itemVar.checked) itemVar.checked = false;
				if(groupVar.checked) groupVar.checked = false;
			}
			<cfelse>
			//if item and group are unchecked then uncheck the include checkbox
			if (itemVar.checked == false && groupVar.checked == false){
				includeVar.checked = false;
			}
			</cfif>
		}

		// enter this logic when we are checking a checkbox
		if(eventObj.checked){
			//if item or group are checked then check the include checkbox
			if (itemVar.checked == true || groupVar.checked == true){
				includeVar.checked = true;
				<cfif appSettings.getSearchSequenceOn()>//when search sequence is on, check both item and group
					if(!itemVar.checked) itemVar.checked = true;
					if(!groupVar.checked) groupVar.checked = true;
				</cfif>
			}
		}
	}

	function checkInclude(objPref){
		var includeVar = eval("document.all." + objPref);
		var itemVar = eval("document.all." + objPref + "_Item_Level");
		var groupVar = eval("document.all." + objPref + "_Group_Level");
	<cfif form.Group_Deal eq 1>
		var defaultVar = groupVar;
	<cfelse>
		var defaultVar = itemVar;
	</cfif>

		//handle for discount lump sums
		if (objPref == "Discount_Lump_Sums"){
			var reqVar = eval("document.all." + objPref + "_Item_Mandated");
		}

		//if include is unchecked then uncheck item and group
		if (includeVar.checked == false){
			itemVar.checked = false;
			groupVar.checked = false;
			//handle for discount lump sums
			if (objPref == "Discount_Lump_Sums"){
				reqVar.checked = false;
			}
		}

		//if include is checked then set to default
		if (includeVar.checked == true){
			<cfif appSettings.getSearchSequenceOn()><!------ If search sequence is on, make both item and group available ----->
			itemVar.checked = includeVar.checked;
			groupVar.checked = includeVar.checked;
			<cfelse>
			if(itemVar.checked == false && groupVar.checked == false){
				defaultVar.checked = true;
			}
			</cfif>
		}
	}

	function changeDisableOtherCheckBoxes(thisObj, OtherObj){
		OtherObj.disabled = !(thisObj.checked);
	}

	<cfif Generic_Type IS NOT "Brokerage" >
		function CheckCriteria(){
			if (document.all.Discount_Lump_Sums != null){
			if(document.all.Discount_Lump_Sums.checked == true){
				document.all.Discount_Lump_Sums_Document_Attachment_Mandated.disabled = false;
			}
		 }
		}
	</cfif>


	/* Click on Discount types to get the message related to products. */
	function ClickToOpenLayer(UniqueID,DiscountType){
		var DisplayObject;
		var Discount_Type;
		var Discount_Type = true;

		/* Get the row's ID */
		DisplayObject = document.getElementById(UniqueID);
		if(DiscountType != 'Discount_OffInvoice'){
			Discount_Type = eval("document.all."+DiscountType+".checked");
		}

		/* If the discount type is checked */
		if(Discount_Type == true){
			/* Show/Hide based on its visible status */
			if(DisplayObject.style.display == 'none'){
				DisplayObject.style.display = '';
			}else{
				DisplayObject.style.display = 'none';
			}
		}else{
			DisplayObject.style.display = 'none';
		}
	}

	function enablepounds(){
		var specialfixed_checked = document.all.Discount_Fixed_Prices_Freight.checked;
		if (specialfixed_checked == true){
			document.all.RateTypeOption_1.checked = specialfixed_checked;
			document.all.RateTypeDefault[0].checked =  specialfixed_checked;

			if (document.all.Group_Programs_UOM.checked == true){
				document.all.Groups_UOM_2.checked = specialfixed_checked;
				document.all.Groups_UOM_Default[0].checked =  specialfixed_checked;
			}
		}
	}

	function checkFixedRebateGrid(thisObj){
		var objName = thisObj.name;

		if(objName == 'Fixed_Rebate_Grid_Option'){
			if (document.all.Fixed_Rebate_Grid_Option.checked){
				// TODO : DEFINE LOGIC.  COMMENTED OUT MWS RG2
				//if(document.all.Discount_Fixed_Prices){document.all.Discount_Fixed_Prices.checked = false; document.all.Discount_Fixed_Prices.disabled = true}
				//if(document.all.Discount_Rebates_Item_Level){document.all.Discount_Rebates_Item_Level.checked = false; document.all.Discount_Rebates_Item_Level.disabled = true}

				//if(document.all.Discount_Fixed_Item_Level){document.all.Discount_Fixed_Item_Level.checked = false; document.all.Discount_Fixed_Item_Level.disabled = true}
			}else{
				if(document.all.Discount_Fixed_Prices){document.all.Discount_Fixed_Prices.disabled = false}
				if(document.all.Discount_Rebates_Item_Level){document.all.Discount_Rebates_Item_Level.disabled = false}
				if(document.all.Discount_Fixed_Item_Level){document.all.Discount_Fixed_Item_Level.disabled = false}
			}
		}else{
			if(document.all.Fixed_Rebate_Grid_Option){
				if(document.all.Discount_Fixed_Prices.checked == true){
					//document.all.Fixed_Rebate_Grid_Option.checked = false;
					//document.all.Fixed_Rebate_Grid_Option.disabled = true;
				}else{
					document.all.Fixed_Rebate_Grid_Option.disabled = false;
				}
			}
		}
	}
</SCRIPT>
<cfif ! url.DownloadSettings>
	<CFSET PAGETITLE = "PROGRAM TEMPLATES: DETAILS">
	<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
</cfif>

<cfset variables.retro = "<font size='2' color='red'><b>R</b></font>">
</cfif>
<cfoutput>
<cfif fromSettings_management neq 1> <!--- start :: cfif fromSettings_management neq 1 :: 2 ::Settings Management page 41974--->
<!------ display header ----->
<cfif ! url.DownloadSettings>
	<cfset pageName = "secondpage">
	<cfinclude template="header.cfm">
<cfelse>
	<cfset LockedBy_Current_User = 0>
</cfif>
<CF_MessageWindow>
<form action="secondpage_action.cfm" method="post" name="SecondaryInfo">

<cfif Action IS "Edit">
	<cfset IsDominant = SelectSecondary.IsDominant>
<cfelse>
	<cfset IsDominant = 0>
</cfif>

<cfif ! url.DownloadSettings>
<div style="margin-top:5px;">    <!--- 42176 --->
	<span style="width:60%;display:inline-block;"><img src="/images/ico-info.gif"><span class="headingTip"> &nbsp; #variables.retro# Indicates field which will be saved retroactively to all previous versions</span></span>
	<cfif LockedBy_Current_User EQ 1>
		<span class="headingActions" style="width:39%;display:inline-block;text-align:right;"><a href="javascript:confirmCompletion()">#application.util.string.actionLinkFormat2("save and continue")#</a></span>
	</cfif>
</div>
</cfif>
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
<table width="100%" cellpadding="2" cellspacing="0" border="0" id="bigTable">
<col width="55%">
<col width="15%">
<col width="15%">
<col width="15%">
				<!---NOI can only and always have pounds --->
</cfif><!--- end :: cfif fromSettings_management neq 1 :: 2 ::Settings Management page 41974--->
<cfif Generic_Type IS NOT "USDA NOI" AND Generic_Type IS NOT "LSAutoPAy" >
	<tr id="UOM_heading" <cfif DownloadSettings> style="display: none;"</cfif>>
	<cfif fromSettings_management EQ 1>
		<th colspan="4">Unit of Measure</th>
	<cfelse>
		<th>Unit of Measure</th>
		<th style="font-size:12px;color:black;">Included</th>
		<th style="font-size:12px;color:black;">Set as Default</th>
        <th style="font-size:12px;color:black;">In Volume
            <cfif templateMgmtSettingsSecPage.UOM_Sleeve or templateMgmtSettingsSecPage.UOM_Each>
                <img src="/images/i.gif" title="Pound and Case cannnot be checkmarked when Each or Sleeve is checked. To see Each or Sleeve on the Volume page, choose it as the default.">
            </cfif>
        </th>
	</cfif>
	</tr>
	<!---Per pound--->
	<cfif fromSettings_management EQ 1>
		<cfset SettingsTemplateForm(NameField="Per_Pound",NameFieldDesc="Per Pound")>
	<cfelseif url.DownloadSettings>
			<cfset SDValue = 'Not Include'>
			<cfset SDefault = 'No'>
			<cfset SInVolume = 'No'>

			<cfif SelectSecondary.RateTypeOption_1 IS 1 OR SelectSecondary.Discount_Fixed_Prices_Freight IS 1>
				<cfset SDValue = 'Include'>
			</cfif>

			<cfif SelectSecondary.RateTypeDefault IS 2>
				<cfset SDefault = 'Yes'>
			</cfif>

			<cfif SelectSecondary.Volume_Page_UOM_LB eq 1>
				<cfset SInVolume = 'Yes'>
			</cfif>

			<cfset SettingsToExcel (Setting_Name='Per #Application.UOMPoundSingular#', Setting_Field_Name='Per_Pound', Setting_Value='#SDValue#', Is_Child_Of='', SetAsDefault='#SDefault#', InVolume='#SInVolume#', page='2')>
	<cfelse>
	<tr class="UOM" <cfif templateMgmtSettingsSecPage.Per_Pound EQ 0> style="display:none"</cfif>>
		<td>Per #Application.UOMPoundSingular#<span id="error_CasePound"></span></td>
		<td>
			<span id="error_RateTypeOption_1"></span>
			<input type="checkbox" name="RateTypeOption_1" id="RateTypeOption_1" value="1" onClick="javaScript:selectGroupUOM(this);showHideInventoryUOM()"
			<cfif OperatorBid EQ false>
				<cfif (Action IS "Edit" and SelectSecondary.RateTypeOption_1 IS 1) OR SelectSecondary.Discount_Fixed_Prices_Freight EQ 1> checked </cfif>
			<cfelse>
				disabled
			</cfif>>
		</td>
		<td>
			<span id="error_RateTypeDefault"></span>
			<input type="radio" onClick="DefaultGroupUOM(this.value)" name="RateTypeDefault" value="2" <cfif OperatorBid EQ false><cfif Action IS "Edit" and SelectSecondary.RateTypeDefault IS 2> checked</cfif><cfelse> disabled</cfif>>
		</td>
		<td>
			<span id="error_Volume_Page_UOM"></span>
			<input type="checkbox" name="Volume_Page_UOM_LB" value="1" <cfif OperatorBid EQ false> <cfif Action IS "Edit" and SelectSecondary.Volume_Page_UOM_LB eq 1> checked </cfif><cfelse> disabled</cfif>>
		</td>
	</tr>
	</cfif>

	<!---Per Case--->
	<cfif fromSettings_management EQ 1>
		<cfset SettingsTemplateForm(NameField="Per_Case",NameFieldDesc="Per Case")>
	<cfelseif url.DownloadSettings>
			<cfset SDValue = 'Not Include'>
			<cfset SDefault = 'No'>
			<cfset SInVolume = 'No'>

			<cfif SelectSecondary.RateTypeOption_2 IS 1>
				<cfset SDValue = 'Include'>
			</cfif>

			<cfif SelectSecondary.RateTypeDefault IS 1>
				<cfset SDefault = 'Yes'>
			</cfif>

			<cfif SelectSecondary.Volume_Page_UOM_CS eq 1>
				<cfset SInVolume = 'Yes'>
			</cfif>

			<cfset SettingsToExcel (Setting_Name='Per #Application.UOMCaseSingular#', Setting_Field_Name='Per_Case', Setting_Value='#SDValue#', Is_Child_Of='', SetAsDefault='#SDefault#', InVolume='#SInVolume#', page='2')>

	<cfelse>
		<tr class="UOM" <cfif templateMgmtSettingsSecPage.Per_Case EQ 0> style="display:none"</cfif>>
			<td>Per #Application.UOMCaseSingular#</td>
			<td>
				<span id="error_RateTypeOption_2"></span>
				<input type="checkbox" name="RateTypeOption_2" id="RateTypeOption_2" value="1" onClick="javaScript:selectGroupUOM(this);showHideInventoryUOM()"  <cfif OperatorBid EQ false><cfif (Action IS "Edit" and SelectSecondary.RateTypeOption_2 IS 1)> checked</cfif><cfelse> disabled</cfif>>
			</td>
			<td>
				<input type="radio" onClick="DefaultGroupUOM(this.value)" name="RateTypeDefault" value="1" <cfif OperatorBid EQ false><cfif Action IS "Edit" and SelectSecondary.RateTypeDefault IS 1> checked</cfif><cfelse> disabled</cfif>>
			</td>
			<td>
				<input type="checkbox" name="Volume_Page_UOM_CS" value="1" <cfif OperatorBid EQ false> <cfif Action IS "Edit" and SelectSecondary.Volume_Page_UOM_CS eq 1> checked </cfif><cfelse> disabled</cfif>>
			</td>
		</tr>
	</cfif>

	<cfset percentAvailable = (OperatorBid EQ false AND (Generic_Type IS "Distributor Off-Invoice" OR Generic_Type IS "Distributor Trade/Shelter"  OR Generic_Type IS "Brokerage" OR appsettings.getAllow_Percent_Operator_Programs() IS 1)) />
	<cfif percentAvailable>
	<!---Percent--->
	<cfif fromSettings_management EQ 1>
		<cfset SettingsTemplateForm(NameField="Percent_of_Revenue",NameFieldDesc="Percent of Revenue")>
	<cfelseif url.DownloadSettings>
			<cfset SDValue = 'Not Include'>
			<cfset SDefault = 'No'>
			<cfif SelectSecondary.RateTypeOption_3 IS 1>
				<cfset SDValue = 'Include'>
			</cfif>
			<cfif SelectSecondary.RateTypeDefault IS 3>
				<cfset SDefault = 'Yes'>
			</cfif>
			<cfset SettingsToExcel (Setting_Name='Percent of Revenue', Setting_Field_Name='Percent_of_Revenue', Setting_Value='#SDValue#', Is_Child_Of='', SetAsDefault='#SDefault#', page='2')>
	<cfelse>
		<tr class="UOM" <cfif templateMgmtSettingsSecPage.Percent_of_Revenue EQ 0> style="display:none"</cfif>>
			<td>Percent of Revenue</td>
			<td><span id="error_RateTypeOption_3"></span><input type="checkbox" name="RateTypeOption_3" value="1" onClick="javaScript:selectGroupUOM(this)" <cfif Action IS "Edit" and SelectSecondary.RateTypeOption_3 IS 1> checked</cfif>></td>
			<td><input type="radio" onClick="DefaultGroupUOM(this.value)" name="RateTypeDefault" value="3" <cfif Action IS "Edit" and SelectSecondary.RateTypeDefault IS 3> checked</cfif> ></td>
		</tr>
	</cfif>
	<cfelse>
	<tr style="display: none;">
		<td colspan="3">
			<input type="checkbox" name="RateTypeOption_3" value="1">
			<input type="radio" name="RateTypeDefault" value="3" >
		</td>
	</tr>
	</cfif>

<!---63887 :: Need new UOM for Per Hundred Weight (CWT) START--->
	<!---Per Hundred Weight--->
	<cfif fromSettings_management EQ 1>
		<cfset SettingsTemplateForm(NameField="Per_Hundred_Weight",NameFieldDesc="Per Hundred Weight")>
	<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.RateTypeOption_4 IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.RateTypeDefault IS 4>
			<cfset SDefault = 'Yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Per Hundred Weight', Setting_Field_Name='Per_Hundred_Weight', Setting_Value='#SDValue#', Is_Child_Of='', SetAsDefault='#SDefault#', page='2')>
	<cfelse>
	<tr class="UOM" <cfif templateMgmtSettingsSecPage.Per_Hundred_Weight EQ 0> style="display:none"</cfif>>
		<td>Per Hundred Weight</td>
		<td><span id="error_RateTypeOption_4"></span><input type="checkbox" name="RateTypeOption_4" value="1" onClick="javaScript:selectGroupUOM(this)" <cfif Action IS "Edit" and SelectSecondary.RateTypeOption_4 IS 1> checked</cfif>></td>
		<td><input type="radio" onClick="DefaultGroupUOM(this.value)" name="RateTypeDefault" value="6" <cfif Action IS "Edit" and SelectSecondary.RateTypeDefault IS 6> checked</cfif> ></td>
	</tr>
	</cfif>
<!---63887 :: Need new UOM for Per Hundred Weight (CWT) END--->

<!--- 76541 Allow user to create program in Eaches unit of measure --->
<!--- Eaches --->
<cfif appSettings.getUOMEAAvailable()>
	<cfif fromSettings_management EQ 1>
		<cfset SettingsTemplateForm(NameField="UOM_Each",NameFieldDesc="#EachInfo.Unit_Of_Measure_Desc#")>
	<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.RateTypeOption_5 IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.RateTypeDefault IS 5>
			<cfset SDefault = 'Yes'>
		</cfif>

	<cfset SettingsToExcel (Setting_Name='Per Each', Setting_Field_Name='UOM_Each', Setting_Value='#SDValue#', Is_Child_Of='', SetAsDefault='#SDefault#', page='2')>
	<cfelse>
	<tr class="UOM" <cfif templateMgmtSettingsSecPage.UOM_Each EQ 0> style="display:none"</cfif>>
		<td>Per #EachInfo.Unit_of_Measure_Desc_Singular#</td>
		<td><span id="error_RateTypeOption_5"></span><input type="checkbox" name="RateTypeOption_5" value="1" onClick="javaScript:selectGroupUOM(this)" <cfif Action IS "Edit" and SelectSecondary.RateTypeOption_5 IS 1> checked</cfif>></td>
        <cfset in_volume_each = Action IS "Edit" and SelectSecondary.RateTypeDefault IS 5
                                    ? "checked"
                                    : "">
        <td><input type="radio" onClick="DefaultGroupUOM(this.value)" name="RateTypeDefault" value="5" #in_volume_each# ></td>
        <td> <img class="in_volume_each #in_volume_each#" src="/images/yes.gif"> </td>
	</tr>
	</cfif>
<cfelse>
	<tr style="display: none;">
		<td colspan="3">
			<input type="checkbox" name="RateTypeOption_5" value="1">
			<input type="radio" name="RateTypeDefault" value="5" >
		</td>
	</tr>
</cfif>
	<!--- Sleeves --->
	<cfif fromSettings_management EQ 1>
		<cfset SettingsTemplateForm(NameField="UOM_Sleeve",NameFieldDesc="Sleeve")>
	<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.RateTypeOption_6 IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.RateTypeDefault IS 6>
			<cfset SDefault = 'Yes'>
		</cfif>

	<cfset SettingsToExcel (Setting_Name='Per Sleeve', Setting_Field_Name='UOM_Sleeve', Setting_Value='#SDValue#', Is_Child_Of='', SetAsDefault='#SDefault#', page='2')>
    <cfelse>
	<tr class="UOM" <cfif templateMgmtSettingsSecPage.UOM_Sleeve EQ 0> style="display:none"</cfif>>
		<td>Per Sleeve</td>
		<td><span id="error_RateTypeOption_6"></span><input type="checkbox" name="RateTypeOption_6" value="1" onClick="javaScript:selectGroupUOM(this)" <cfif Action IS "Edit" and SelectSecondary.RateTypeOption_6 IS 1> checked</cfif>></td>
        <cfset in_volume_sleeve = Action IS "Edit" and SelectSecondary.RateTypeDefault IS 7
                                    ? "checked"
                                    : "">
		<td><input type="radio" onClick="DefaultGroupUOM(this.value)" name="RateTypeDefault" value="7" #in_volume_sleeve# ></td>
        <td> <img class="in_volume_sleeve #in_volume_sleeve#" src="/images/yes.gif"> </td>
	</tr>
	</cfif>

	<cfif fromSettings_management EQ 1>
		<cfset SettingsTemplateForm(NameField="UOMDefaultOption",NameFieldDesc="No Default")>
	<cfelseif url.DownloadSettings>
		<cfset SDValue = 'NO'>
		<cfif SelectSecondary.RateTypeDefault IS 0>
			<cfset SDValue = 'Yes'>
		</cfif>
		<cfset SettingsToExcel (Setting_Name='No Default', Setting_Field_Name='UOMDefaultOption', Setting_Value='#SDValue#', Is_Child_Of='', SetAsDefault='#SDefault#', page='2')>
	<cfelse>
		<!---No Default--->
		<tr class="UOM" <cfif templateMgmtSettingsSecPage.UOMDefaultOption EQ 0> style="display:none"</cfif>>
			<td>No Default</td>
			<td>&nbsp; </td>
			<td>
				<input type="radio" onClick="DefaultGroupUOM(this.value);selectGroupUOM(this)" name="RateTypeDefault" value="0"
					<cfif OperatorBid EQ false><cfif Action IS "Edit" and SelectSecondary.RateTypeDefault IS 0> checked</cfif>
					<cfif Action is "Create">checked</cfif><cfelse> disabled</cfif>
				>
			</td>
		</tr>
	</cfif>

				<!---Begin: UOM for Groups --->

	<tr id="UOMforGroups_heading_1" <cfif url.DownloadSettings>style="display: none;"</cfif>><th colspan="4"><hr>UOM for Groups #variables.retro#</th></tr>
	<cfif fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="Group_Programs_UOM",NameFieldDesc="Different from above")>
	<cfelseif url.DownloadSettings>
		<cfset SDefault = 'No'>

		<cfif  SelectSecondary.Group_Programs_UOM IS 1>
			<cfset SDefault = 'Yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Different from above', Setting_Field_Name='Group_Programs_UOM', Setting_Value='N/A', Is_Child_Of='', SetAsDefault='#SDefault#', page='2')>

	<cfelse>
		<!---Different from above--->
		<tr class="UOMforGroups" <cfif templateMgmtSettingsSecPage.Group_Programs_UOM EQ 0> style="display:none"</cfif>>
			<td>Different from above</td>
			<td>&nbsp;</td>
			<td>
				<span id="error_Group_Programs_UOM"></span>
				<input onClick="javaScript:showHideGroupProgramsUOM(this)" type="checkbox" name="Group_Programs_UOM" value="1" <cfif Action IS "Edit" and SelectSecondary.Group_Programs_UOM EQ 1>checked</cfif><cfif form.Group_Deal neq 1>disabled</cfif>>
			</td>
		</tr>
	</cfif>

	<cfif fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="Groups_UOM_2",NameFieldDesc="Per Pound")>
	<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfif  SelectSecondary.Groups_UOM_2 IS 1>
			<cfset SDValue = 'Include'>
		</cfif>
			<cfset ShowHide = 'Show'>
		<cfif SelectSecondary.Group_Programs_UOM NEQ 1>
			<cfset ShowHide = 'Hide'>
		</cfif>
		<cfset SettingsToExcel (Setting_Name='Per Pound', Setting_Field_Name='Group_Programs_UOM', Setting_Value='#SDValue#', ShowHide='#ShowHide#', Is_Child_Of='', SetAsDefault='', page='2')>
<cfelse>
	<!---Per pound--->
	<tr id="tr2_GroupProgramsUOM" class="UOMforGroups" <cfif SelectSecondary.Group_Programs_UOM NEQ 1> style="display:none;"</cfif> >
	<td>Per Pound</td>
	<td><span id="error_Groups_UOM_2"></span><input type="checkbox" id="Groups_UOM_2" name="Groups_UOM_2" value="1" <cfif OperatorBid EQ false><cfif (Action IS "Edit" and SelectSecondary.Groups_UOM_2 IS 1) OR EZButton_On EQ 1> checked <cfif EZButton_On EQ 1>disabled</cfif></cfif><cfelse> disabled</cfif>>
	<cfif EZButton_On EQ 1><input type="hidden" name="Groups_UOM_2" value="1"></cfif>
	</td>
	<td><span id="error_CasePound"></span><input type="radio" id="Groups_UOM_Default_2" name="Groups_UOM_Default" value="2" <cfif OperatorBid EQ false><cfif Action IS "Edit" and SelectSecondary.Groups_UOM_Default IS 2> checked</cfif><cfelse> disabled</cfif>></td>
	</tr>
	</cfif>


	<cfif fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="Groups_UOM_1",NameFieldDesc="Per Case")>
<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfif  SelectSecondary.Groups_UOM_1 IS 1>
			<cfset SDValue = 'Include'>
		</cfif>
			<cfset ShowHide = 'Show'>
		<cfif SelectSecondary.Group_Programs_UOM NEQ 1>
			<cfset ShowHide = 'Hide'>
		</cfif>
		<cfset SettingsToExcel (Setting_Name='Per Pound', Setting_Field_Name='Group_Programs_UOM', Setting_Value='#SDValue#',ShowHide='#ShowHide#', page='2')>
	<cfelse>
	<!---Per Case--->
	<tr id="tr1_GroupProgramsUOM" class="UOMforGroups" <cfif SelectSecondary.Group_Programs_UOM NEQ 1> style="display:none;"</cfif> >
		<td>Per Case</td>
		<td><span id="error_Groups_UOM_1"></span><input type="checkbox" id="Groups_UOM_1" name="Groups_UOM_1" value="1" <cfif OperatorBid EQ false><cfif (Action IS "Edit" and SelectSecondary.Groups_UOM_1 IS 1) OR EZButton_On EQ 1> checked</cfif><cfif EZButton_On EQ 1>disabled</cfif><cfelse> disabled</cfif>>
		</td>
		<td><input type="radio" id="Groups_UOM_Default_1" name="Groups_UOM_Default" value="1" <cfif OperatorBid EQ false><cfif Action IS "Edit" and SelectSecondary.Groups_UOM_Default IS 1> checked</cfif><cfelse> disabled</cfif>></td>
	</tr>
	</cfif>

	<!---Percent--->
	<cfset percentAvailable = (OperatorBid EQ false AND (Generic_Type IS "Distributor Off-Invoice" OR Generic_Type IS "Distributor Trade/Shelter" OR Generic_Type IS "Brokerage" OR application.returned_customer_setting.customer_keyword IS "conagra") AND EZButton_On EQ 0) />
	<cfif percentAvailable>
		<cfif fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Groups_UOM_3",NameFieldDesc="Percent of Revenue")>
		<cfelseif url.DownloadSettings>
			<cfset SDValue = 'Not Include'>
			<cfif  SelectSecondary.Groups_UOM_3 IS 1>
				<cfset SDValue = 'Include'>
			</cfif>
			<cfset ShowHide = 'Show'>
		<cfif SelectSecondary.Group_Programs_UOM NEQ 1>
			<cfset ShowHide = 'Hide'>
		</cfif>
			<cfset SettingsToExcel (Setting_Name='Percent of Revenue', Setting_Field_Name='Groups_UOM_3', Setting_Value='#SDValue#', ShowHide='#ShowHide#', page='2')>
		<cfelse>
		<tr id="tr3_GroupProgramsUOM" class="UOMforGroups" <cfif SelectSecondary.Group_Programs_UOM NEQ 1> style="display:none;"</cfif> >
			<td>Percent of Revenue</td>
			<td><span id="error_Groups_UOM_3"></span><input type="checkbox" id="Groups_UOM_3" name="Groups_UOM_3" value="1" <cfif Action IS "Edit" and SelectSecondary.Groups_UOM_3 IS 1> checked</cfif> ></td>
			<td><input type="radio" id="Groups_UOM_Default_3" name="Groups_UOM_Default" value="3" <cfif Action IS "Edit" and SelectSecondary.Groups_UOM_Default IS 3> checked</cfif> ></td>
		</tr>
		</cfif>
	</cfif>

<cfif fromSettings_management neq 1> <!--- start :: cfif fromSettings_management neq 1 :: 4 ::Settings Management page 41974--->
	<!---No Default--->
	<cfif url.DownloadSettings>
		<cfset SDefault = 'Yes'>
		<cfif  SelectSecondary.Groups_UOM_Default IS 0>
			<cfset SDefault = 'NO'>
		</cfif>
			<cfset ShowHide = 'Show'>
		<cfif SelectSecondary.Group_Programs_UOM NEQ 1>
			<cfset ShowHide = 'Hide'>
		</cfif>
		<cfset SettingsToExcel (Setting_Name='Percent of Revenue', Setting_Field_Name='Groups_UOM_3', Setting_Value='N/A', Is_Child_Of='', SetAsDefault='#SDefault#', ShowHide='#ShowHide#', page='2')>
	<cfelse>
	<tr id="tr4_GroupProgramsUOM" class="UOMforGroups" <cfif SelectSecondary.Group_Programs_UOM NEQ 1> style="display:none;"</cfif> >
		<td>No Default</td>
		<td>&nbsp; </td>
		<td><input type="radio" id="Groups_UOM_Default_0" name="Groups_UOM_Default" value="0" <cfif OperatorBid EQ false><cfif Action IS "Edit" and SelectSecondary.Groups_UOM_Default IS 0> checked</cfif> <cfif Action is "Create">checked</cfif> <cfelse> disabled</cfif>></td>
	</tr>
</cfif>
</cfif>

 <!--- start :: cfif fromSettings_management neq 1 :: 4 ::Settings Management page 41974--->
				<!---End: UOM for Groups --->

<!---ELSE NOI --->
<cfelse>
	<input type="hidden" name="RateTypeDefault" value="1">
	<input type="hidden" name="RateTypeOption_1" value="2">
	<!---NOI --->
</cfif>

	<tr id="Restrict_On_Inventory_UOM_heading"
<!--- If the "settings management" page has all the options set to "hide", do not show the header. --->
	<cfif fromSettings_management eq 0>
		<cfif templateMgmtSettingsSecPage.Restrict_On_Inventory_UOM_Pound EQ 0 AND templateMgmtSettingsSecPage.Restrict_On_Inventory_UOM_Case EQ 0 >
		style="display:none"</cfif>
	</cfif>>
	<th colspan="4" <cfif url.DownloadSettings>style="display: none;"</cfif>><hr>Restrict on Inventory UOM</th>
	<cfif fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="Restrict_On_Inventory_UOM_Pound",NameFieldDesc="Pound")>
		<cfelseif url.DownloadSettings>
			<cfset SDValue = 'Not Include'>
			<cfif  SelectSecondary.Restrict_On_Inventory_UOM_Pound IS 1>
				<cfset SDValue = 'Include'>
			</cfif>
			<cfset SettingsToExcel (Setting_Name='Restrict On Inventory UOM Pound', Setting_Field_Name='Restrict_On_Inventory_UOM_Pound', Setting_Value='#SDValue#', page='2')>
	<cfelse>
	<!---Case--->
	<tr <cfif templateMgmtSettingsSecPage.Restrict_On_Inventory_UOM_Pound EQ 0> style="display:none"</cfif>>
		<td>Pound</td>
		<td colspan="3">
			<span id="error_Restrict_On_Inventory_UOM"></span>
			<input type="checkbox" name="Restrict_On_Inventory_UOM_Pound" class="RestrictOnInventoryUOMPound" value="1" <cfif Action IS "Edit" and SelectSecondary.Restrict_On_Inventory_UOM_Pound EQ 1>checked</cfif><!---<cfif form.Group_Deal neq 1>disabled</cfif>--->>
		</td>
	</tr>
	</cfif>
	<!--- </tr> --->

	<cfif fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="Restrict_On_Inventory_UOM_Case",NameFieldDesc="Case")>
		<cfelseif url.DownloadSettings>
			<cfset SDValue = 'Not Include'>
			<cfif  SelectSecondary.Restrict_On_Inventory_UOM_Case IS 1>
				<cfset SDValue = 'Include'>
			</cfif>
			<cfset SettingsToExcel (Setting_Name='Restrict On Inventory UOM Case', Setting_Field_Name='Restrict_On_Inventory_UOM_Case', Setting_Value='#SDValue#', page='2')>
	<cfelse>
	<!---Pound--->
	<tr <cfif templateMgmtSettingsSecPage.Restrict_On_Inventory_UOM_Case EQ 0> style="display:none"</cfif>>
		<td>Case</td>
		<td colspan="3">
			<span id="error_Restrict_On_Inventory_UOM"></span>
			<input  type="checkbox" name="Restrict_On_Inventory_UOM_Case" class="RestrictOnInventoryUOMCase" value="1" <cfif Action IS "Edit" and SelectSecondary.Restrict_On_Inventory_UOM_Case EQ 1>checked</cfif><!---<cfif form.Group_Deal neq 1>disabled</cfif>--->>
		</td>
	</tr>
	</cfif>

<cfif Generic_Type IS NOT "Distributor Off-Invoice" AND Generic_Type IS NOT "LSAutoPAy" >
<!--- Claim Mechanics START --->
<cfif fromSettings_management NEQ 1>

<cfif url.DownloadSettings>

		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfloop query="GetPaymentTypes">
			<cfquery name="TypeInThisTemplate" datasource="#application.datasource#">
				SELECT 	Payment_Type_ID
				FROM 	Payment_Template_Mapping
				WHERE 	Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
				AND 	Payment_Type_ID = <cfqueryparam value="#GetPaymentTypes.Payment_Type_ID#" cfsqltype="cf_sql_integer">
			</cfquery>
			<cfset subText = ''>
			<cfif Is_Auto_Pay IS 1>
				<cfset subText = '(AP)'>
			</cfif>
			<cfif Off_Invoice IS 1>
				<cfset subText = '(OI)'>
			</cfif>
			<cfif Restrict_From_Billback IS 1>
				<cfset subText = '(RB)'>
			</cfif>

			<cfif  len(trim(TypeInThisTemplate.Payment_Type_ID)) GT 0>
				<cfset SDValue = 'Include'>
			</cfif>

			<cfif SelectSecondary.ClaimMechDefaultOption IS Payment_Type_ID>
				<cfset SDefault = 'Yes'>
			</cfif>

			<cfset SettingsToExcel (Setting_Name='#Payment_Type_Name# #subText#', Setting_Field_Name='Payment_Type_#Payment_Type_ID#', Setting_Value='#SDValue#', ShowHide='Show', Is_Child_Of='', SetAsDefault='#SDefault#', page='2')>
		</cfloop>

<cfelse>
	<tr id="Claim_Mechanics_heading"><th colspan="4"><hr>Claim Mechanics</th></tr>
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

	<cfif url.DownloadSettings>
		<cfset SDefault = 'Yes'>
		<cfif  SelectSecondary.ClaimMechDefaultOption IS 0>
			<cfset SDefault = 'NO'>
		</cfif>
		<cfset SettingsToExcel (Setting_Name='Claim Mech No Default', Setting_Field_Name='ClaimMechDefaultOption', Setting_Value='', Is_Child_Of='', SetAsDefault='#SDefault#', page='2')>
	<cfelse>
	<tr>
		<td>No Default</td>
		<td>&nbsp; </td>
		<td><input type="radio" name="ClaimMechDefaultOption" <cfif OperatorBid EQ false><cfif Action IS "Edit" and SelectSecondary.ClaimMechDefaultOption IS 0> checked</cfif> <cfif Action is "Create">checked</cfif><cfelse> disabled</cfif> value="0"></td>
	</tr>
	</cfif>
</cfif>
</cfif>
</cfif>
<!--- Claim Mechanics END --->
<!----Payment Cycle--->
		<tr id="PaymentFrequency_heading_1" <cfif url.DownloadSettings>style="display: none;"</cfif>><th colspan="4"><hr>Payment Frequency</th></tr>
<cfif fromSettings_management eq 1>
	<cfset SettingsTemplateForm(NameField="PayCycleOption_1",NameFieldDesc="Daily")>
<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.PayCycleOption_1 IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.PayCycleDefaultOption IS 1>
			<cfset SDefault = 'Yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Payment Frequency Daily', Setting_Field_Name='PayCycleOption_1', Setting_Value='#SDValue#', Is_Child_Of='', SetAsDefault='#SDefault#', page='2')>
	<cfelse>
	<!---Daily--->
	<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_1 EQ 0> style="display:none"</cfif>>
	<td>Daily</td>
	<td><span id="error_PayCycleOption_1"></span><input type="checkbox" name="PayCycleOption_1" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_1 IS 1> checked</cfif>></td>
	<td><input type="radio" name="PayCycleDefaultOption" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 1> checked</cfif>></td>
	</tr>
</cfif>


<cfif fromSettings_management eq 1>
	<cfset SettingsTemplateForm(NameField="PayCycleOption_2",NameFieldDesc="Weekly")>
<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.PayCycleOption_2 IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.PayCycleDefaultOption IS 2>
			<cfset SDefault = 'Yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Payment Frequency Weekly', Setting_Field_Name='PayCycleOption_2', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', page='2')>
<cfelse>
	<!---Weekly--->
	<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_2 EQ 0> style="display:none"</cfif>>
		<td>Weekly</td>
		<td><span id="error_PayCycleOption_2"></span><input type="checkbox" name="PayCycleOption_2" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_2 IS 1> checked</cfif>></td>
		<td><input type="radio" name="PayCycleDefaultOption" value="2" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 2> checked</cfif>></td>
	</tr>
</cfif>

<cfif fromSettings_management eq 1>
	<cfset SettingsTemplateForm(NameField="PayCycleOption_3",NameFieldDesc="Monthly")>
<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.PayCycleOption_3 IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.PayCycleDefaultOption IS 3>
			<cfset SDefault = 'Yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Payment Frequency Monthly', Setting_Field_Name='PayCycleOption_3', Setting_Value='#SDValue#', SetAsDefault='#SDefault#')>
<cfelse>
	<!---Monthly--->
	<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_3 EQ 0> style="display:none"</cfif>>
		<td>Monthly</td>
		<td><span id="error_PayCycleOption_3"></span><input type="checkbox" name="PayCycleOption_3" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_3 IS 1> checked</cfif>></td>
		<td><input type="radio" name="PayCycleDefaultOption" value="3" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 3> checked</cfif>></td>
	</tr>
</cfif>

<cfif fromSettings_management eq 1>
	<cfset SettingsTemplateForm(NameField="PayCycleOption_4",NameFieldDesc="Quarterly")>
<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.PayCycleOption_4 IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.PayCycleDefaultOption IS 4>
			<cfset SDefault = 'Yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Payment Frequency Quarterly', Setting_Field_Name='PayCycleOption_4', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', page='2')>
<cfelse>
	<!---Quarterly--->
	<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_4 EQ 0> style="display:none"</cfif>>
		<td>Quarterly</td>
		<td><span id="error_PayCycleOption_4"></span><input type="checkbox" name="PayCycleOption_4" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_4 IS 1> checked</cfif>></td>
		<td><input type="radio" name="PayCycleDefaultOption" value="4" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 4> checked</cfif>></td>
	</tr>
</cfif>

<cfif fromSettings_management eq 1>
	<cfset SettingsTemplateForm(NameField="PayCycleOption_5",NameFieldDesc="Semi-Annually")>
<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.PayCycleOption_5 IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.PayCycleDefaultOption IS 5>
			<cfset SDefault = 'Yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Payment Frequency Semi Annually', Setting_Field_Name='PayCycleOption_5', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', page='2')>
<cfelse>
	<!---Semi-Annually--->
	<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_5 EQ 0> style="display:none"</cfif>>
		<td>Semi-Annually</td>
		<td><span id="error_PayCycleOption_5"></span><input type="checkbox" name="PayCycleOption_5" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_5 IS 1> checked</cfif>></td>
		<td><input type="radio" name="PayCycleDefaultOption" value="5" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 5> checked</cfif>></td>
	</tr>
</cfif>

<cfif fromSettings_management eq 1>
	<cfset SettingsTemplateForm(NameField="PayCycleOption_6",NameFieldDesc="Annually")>
<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.PayCycleOption_6 IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.PayCycleDefaultOption IS 6>
			<cfset SDefault = 'Yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Payment Frequency Annually', Setting_Field_Name='PayCycleOption_6', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', page='2')>
<cfelse>
	<!---Annually--->
	<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_6 EQ 0> style="display:none"</cfif>>
		<td>Annually</td>
		<td><span id="error_PayCycleOption_6"></span><input type="checkbox" name="PayCycleOption_6" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_6 IS 1> checked</cfif>></td>
		<td><input type="radio" name="PayCycleDefaultOption" value="6" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 6> checked</cfif>></td>
	</tr>
</cfif>

<cfif fromSettings_management eq 1>
	<cfset SettingsTemplateForm(NameField="PayCycleOption_7",NameFieldDesc="Upon Expiration")>
<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.PayCycleOption_7 IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.PayCycleDefaultOption IS 7>
			<cfset SDefault = 'Yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Payment Frequency Upon Expiration', Setting_Field_Name='PayCycleOption_7', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', page='2')>
<cfelse>
	<!---Upon Expiration--->
	<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_7 EQ 0> style="display:none"</cfif>>
		<td>Upon Expiration</td>
		<td><span id="error_PayCycleOption_7"></span><input type="checkbox" name="PayCycleOption_7" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_7 IS 1> checked</cfif>></td>
		<td><input type="radio" name="PayCycleDefaultOption" value="7" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 7> checked</cfif>></td>
	</tr>
</cfif>

<cfif fromSettings_management eq 1>
	<cfset SettingsTemplateForm(NameField="PayCycleOption_8",NameFieldDesc="Upon Due")>
<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.PayCycleOption_8 IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.PayCycleDefaultOption IS 8>
			<cfset SDefault = 'Yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Payment Frequency Upon Due', Setting_Field_Name='PayCycleOption_8', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', page='2')>
<cfelse>
	<!---Upon Due--->
	<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_8 EQ 0> style="display:none"</cfif>>
		<td>Upon Due</td>
		<td><span id="error_PayCycleOption_8"></span><input type="checkbox" name="PayCycleOption_8" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_8 IS 1> checked</cfif>></td>
		<td><input type="radio" name="PayCycleDefaultOption" value="8" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 8> checked</cfif>></td>
	</tr>
</cfif>

<cfif fromSettings_management eq 1>
	<cfset SettingsTemplateForm(NameField="PayCycleOption_9",NameFieldDesc="One Time Payment")>
<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.PayCycleOption_9 IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.PayCycleDefaultOption IS 9>
			<cfset SDefault = 'Yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Payment Frequency One Time Payment', Setting_Field_Name='PayCycleOption_9', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', page='2')>
<cfelse>
	<!---One Time Payment--->
	<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_9 EQ 0> style="display:none"</cfif>>
		<td>One Time Payment</td>
		<td><span id="error_PayCycleOption_9"></span><input type="checkbox" name="PayCycleOption_9" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_9 IS 1> checked</cfif>></td>
		<td><input type="radio" name="PayCycleDefaultOption" value="9" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 9> checked</cfif>></td>
	</tr>
</cfif>

<cfif fromSettings_management eq 1>
	<cfset SettingsTemplateForm(NameField="PayCycleOption_10",NameFieldDesc="Fiscal Month")>
<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.PayCycleOption_10 IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.PayCycleDefaultOption IS 10>
			<cfset SDefault = 'Yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Payment Frequency Fiscal Month', Setting_Field_Name='PayCycleOption_10', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', page='2')>
<cfelse>
	<!--- Fiscal Month --->
	<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_10 EQ 0> style="display:none"</cfif>>
		<td>Fiscal Month</td>
		<td><span id="error_PayCycleOption_10"></span><input type="checkbox" name="PayCycleOption_10" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_10 IS 1> checked</cfif>></td>
		<td><input type="radio" name="PayCycleDefaultOption" value="10" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 10> checked</cfif>></td>
	</tr>
</cfif>

<cfif fromSettings_management eq 1>
	<cfset SettingsTemplateForm(NameField="PayCycleOption_11",NameFieldDesc="Fiscal Quarter")>
<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.PayCycleOption_11 IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.PayCycleDefaultOption IS 11>
			<cfset SDefault = 'Yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Payment Frequency Fiscal Quarter', Setting_Field_Name='PayCycleOption_11', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', page='2')>
<cfelse>
	<!--- Fiscal Quarter --->
	<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_11 EQ 0> style="display:none"</cfif>>
		<td>Fiscal Quarter</td>
		<td><span id="error_PayCycleOption_11"></span><input type="checkbox" name="PayCycleOption_11" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_11 IS 1> checked</cfif>></td>
		<td><input type="radio" name="PayCycleDefaultOption" value="11" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 11> checked</cfif>></td>
	</tr>
</cfif>
<!------D47825 :: Payment frequency:  Add fiscal year option --->
<cfif fromSettings_management eq 1>
	<cfset SettingsTemplateForm(NameField="PayCycleOption_12",NameFieldDesc="Fiscal Year")>
<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.PayCycleOption_12 IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.PayCycleDefaultOption IS 12>
			<cfset SDefault = 'Yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Payment Frequency Fiscal Year', Setting_Field_Name='PayCycleOption_12', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', page='2')>
<cfelse>
	<!--- Fiscal Quarter --->
	<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_12 EQ 0> style="display:none"</cfif>>
		<td>Fiscal Year</td>
		<td><span id="error_PayCycleOption_12"></span><input type="checkbox" name="PayCycleOption_12" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_12 IS 1> checked</cfif>></td>
		<td><input type="radio" name="PayCycleDefaultOption" value="12" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 12> checked</cfif>></td>
	</tr>
</cfif>

<!------D76514 :: Add additional payment frequencies (cycles) --->
<cfif fromSettings_management eq 1>
	<cfset SettingsTemplateForm(NameField="PayCycleOption_13",NameFieldDesc="Fiscal Week")>
<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.PayCycleOption_13 IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.PayCycleDefaultOption IS 13>
			<cfset SDefault = 'Yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Payment Frequency Fiscal Week', Setting_Field_Name='PayCycleOption_13', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', page='2')>
<cfelse>
	<!--- Fiscal Week --->
	<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_13 EQ 0> style="display:none"</cfif>>
		<td>Fiscal Week</td>
		<td><span id="error_PayCycleOption_13"></span><input type="checkbox" name="PayCycleOption_13" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_13 IS 1> checked</cfif>></td>
		<td><input type="radio" name="PayCycleDefaultOption" value="13" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 13> checked</cfif>></td>
	</tr>
</cfif>

<!------D76514 :: Add additional payment frequencies (cycles) --->
<cfif fromSettings_management eq 1>
	<cfset SettingsTemplateForm(NameField="PayCycleOption_14",NameFieldDesc="Fiscal Bi Annual")>
<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.PayCycleOption_14 IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.PayCycleDefaultOption IS 14>
			<cfset SDefault = 'Yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Payment Frequency Fiscal Bi Annual', Setting_Field_Name='PayCycleOption_14', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', page='2')>
<cfelse>
	<!--- Fiscal Bi Annual --->
	<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_14 EQ 0> style="display:none"</cfif>>
		<td>Fiscal Bi Annual</td>
		<td><span id="error_PayCycleOption_14"></span><input type="checkbox" name="PayCycleOption_14" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_14 IS 1> checked</cfif>></td>
		<td><input type="radio" name="PayCycleDefaultOption" value="14" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 14> checked</cfif>></td>
	</tr>
</cfif>

<!------D76514 :: Add additional payment frequencies (cycles) --->
<cfif fromSettings_management eq 1>
	<cfset SettingsTemplateForm(NameField="PayCycleOption_15",NameFieldDesc="13 Period Calendar")>
<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.PayCycleOption_15 IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.PayCycleDefaultOption IS 15>
			<cfset SDefault = 'Yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Payment Frequency 13 Period Calendar', Setting_Field_Name='PayCycleOption_15', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', page='2')>
<cfelse>
	<!--- 13 Period Calendar --->
	<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleOption_15 EQ 0> style="display:none"</cfif>>
		<td>13 Period Calendar</td>
		<td><span id="error_PayCycleOption_15"></span><input type="checkbox" name="PayCycleOption_15" value="1" <cfif Action IS "Edit" and SelectSecondary.PayCycleOption_15 IS 1> checked</cfif>></td>
		<td><input type="radio" name="PayCycleDefaultOption" value="15" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 15> checked</cfif>></td>
	</tr>
</cfif>

<!------D47825 :: Payment frequency:  Add fiscal year option --->
<cfif fromSettings_management eq 1>
	<cfset SettingsTemplateForm(NameField="PayCycleDefaultOption",NameFieldDesc="No Default")>
<cfelseif url.DownloadSettings>
		<cfset SDefault = 'Yes'>

		<cfif SelectSecondary.PayCycleDefaultOption IS 0>
			<cfset SDefault = 'No'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Payment Frequency No Default', Setting_Field_Name='PayCycleDefaultOption', Setting_Value='N/A', SetAsDefault='#SDefault#', page='2')>
<cfelse>
	<!---No Default--->
	<tr class="PaymentFrequency" <cfif templateMgmtSettingsSecPage.PayCycleDefaultOption EQ 0> style="display:none"</cfif>>
		<td>No Default</td>
		<td>&nbsp; </td>
		<td><input type="radio" name="PayCycleDefaultOption" value="0" <cfif Action IS "Edit" and SelectSecondary.PayCycleDefaultOption IS 0> checked</cfif> <cfif Action is "Create">checked</cfif>></td>
	</tr>
</cfif>


</cfif>

<!--- CURRENCY SECTION --->
	<tr id="Currency_heading" <cfif url.DownloadSettings>style="display: none;"</cfif>><th colspan="4"><hr>Currency</th></tr>
	<cfif fromSettings_management EQ 1>
		<cfloop query="GetCurrencyTypes">
		<cfset SettingsTemplateForm(NameField="CurrencyID_#Currency_ID#",NameFieldDesc="#Currency_Name# (#Currency_Code#)")>
		</cfloop>
		<cfset SettingsTemplateForm(NameField="CurrencyDefaultOption",NameFieldDesc="No Default")>
	<cfelseif url.DownloadSettings>
		<cfloop query="GetCurrencyTypes">
			<cfif Evaluate("templateMgmtSettingsSecPage.CurrencyID_#Currency_ID#")>
				<cfset SDValue = 'Not Include'>
				<cfset SDefault = 'No'>

		<cfquery name="CurrencyInThisTemplate" datasource="#application.datasource#">
			SELECT 	Currency_ID
			FROM 	Currency_Mapping
			WHERE 	Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
			AND 	Currency_ID = <cfqueryparam value="#GetCurrencyTypes.Currency_ID#" cfsqltype="cf_sql_integer">
		</cfquery>

				<cfif len(trim(CurrencyInThisTemplate.Currency_ID)) GT 0>
					<cfset SDValue = 'Include'>
				</cfif>

				<cfif SelectSecondary.CurrencyDefaultOption IS Currency_ID>
					<cfset SDefault = 'Yes'>
				</cfif>

				<cfset SettingsToExcel (Setting_Name='#Currency_Name# (#Currency_Code#)', Setting_Field_Name='CurrencyID_#Currency_ID#', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', page='2')>
			</cfif>
		</cfloop>
	<cfelse>
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

		<tr class="Currency" <cfif Evaluate("templateMgmtSettingsSecPage.CurrencyID_#Currency_ID#") EQ 0> style="display:none"</cfif>>
			<td>#Currency_Name# (#Currency_Code#)</td>
			<td><input type="checkbox" name="Currency_#Currency_ID#" value="1" <cfif (len(trim(CurrencyInThisTemplate.Currency_ID)) GT 0) OR Action IS "Create">checked</cfif> ></td>
			<td><input type="radio" name="CurrencyDefaultOption" value="#Currency_ID#" <cfif (CurrencyDefaultOption IS Currency_ID) OR Action IS "Create">checked</cfif>><!--- <cfoutput>#CurrencyDefaultOption# :: #Currency_ID# ::#Action#</cfoutput> ---></td>
		</tr>

		</cfloop>
	<cfif url.DownloadSettings>
		<cfset SDefault = 'Yes'>

		<cfif SelectSecondary.CurrencyDefaultOption IS 0>
			<cfset SDefault = 'No'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Currency No Default', Setting_Field_Name='CurrencyDefaultOption', Setting_Value='', SetAsDefault='#SDefault#', page='2')>
<cfelse>
		<tr class="Currency" <cfif templateMgmtSettingsSecPage.CurrencyDefaultOption EQ 0> style="display:none"</cfif>>
			<td>No Default</td>
			<td>&nbsp; </td>
			<td><input type="radio" name="CurrencyDefaultOption" value="0" <cfif Action IS "Edit" and SelectSecondary.CurrencyDefaultOption IS 0> checked</cfif>></td>
		</tr>
</cfif>
	</cfif>
<!--- END CURRENCY SECTION --->

<!--- ********************* VOLUME SECTION D19117,D20129 -Anand Rao ********************* --->
<!---
	Dev Notes: D23160/Anand Rao/26-Apr-10
  Template settings for volume / Changed all the labels
--->
<tr id="VolumeCalculations_heading_1" <cfif url.DownloadSettings>style="display:none"</cfif>><th colspan="4"><hr>Volume Calculations</th></tr>
	<cfif Generic_Type EQ "Operator-Deviated Pricing" or Generic_Type EQ "Operator Direct or HQ Programs">
        <!---Dev Notes: D23319/Anand Rao/04-May-10
        	Template settings for volume/ Renamed the labels here
        --->
	<cfif fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="Operator_Off_Invoice_Volume",NameFieldDesc="Include Direct Shipment Volume and Dollars")>
	<cfelseif url.DownloadSettings>
		<cfset SDValue = 'No'>

		<cfif SelectSecondary.Volume_Operator_Template_GroupB_Default IS 1>
			<cfset SDValue = 'yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Include Direct Shipment Volume and Dollars', Setting_Field_Name='Volume_Operator_Template_GroupB_Default', Setting_Value='#SDValue#', page='2')>
	<cfelse>
	<tr class="VolumeCalculations" <cfif templateMgmtSettingsSecPage.Operator_Off_Invoice_Volume EQ 0> style="display:none"</cfif>>
		<td>Include Direct Shipment Volume and Dollars<!--- Direct Shipment Volume and Dollars ---><!--- Off Invoice sales to an operator or program including an operator ---></td>
		<td>Yes<input type="hidden" name="Operator_Off_Invoice_Volume" value="1"></td>
		<td><input type="radio" name="Volume_Operator_Template_GroupB_Default" value="1" <cfif Action IS "Edit" and SelectSecondary.Volume_Operator_Template_GroupB_Default IS 1> checked</cfif>></td>
	</tr>
	</cfif>

		<cfif fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Operator_Billback_Volume",NameFieldDesc="Include billback volume and dollars")>
	<cfelseif url.DownloadSettings>

		<cfset SDValue = 'No'>

		<cfif SelectSecondary.Volume_Operator_Template_GroupB_Default IS 1>
			<cfset SDValue = 'yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Include billback volume and dollars', Setting_Field_Name='Volume_Operator_Template_GroupB_Default', Setting_Value='#SDValue#', page='2')>

		<cfelse>
			<tr class="VolumeCalculations" <cfif templateMgmtSettingsSecPage.Operator_Billback_Volume EQ 0> style="display:none"</cfif>>
				<td>Include billback volume and dollars<!--- Billback Volume and Dollars ---><!--- Billback volume as basis ---></td>
				<td>Yes<input type="hidden" name="Operator_Billback_Volume" value="1"></td>
				<td><input type="radio" name="Volume_Operator_Template_GroupB_Default" value="2" <cfif Action IS "Edit" and SelectSecondary.Volume_Operator_Template_GroupB_Default IS 2> checked</cfif>></td>
			</tr>
		</cfif>

         <cfelse>

<cfif fromSettings_management eq 1>
	<cfset SettingsTemplateForm(NameField="Distributor_Off_Invoice_Volume",NameFieldDesc="Exclude Direct Shipment Volume and Dollars")>
<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.Distributor_Off_Invoice_Volume IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.Volume_Distributor_Template_GroupB_Default IS 1>
			<cfset SDefault = 'Yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Exclude Direct Shipment Volume and Dollars', Setting_Field_Name='Volume_Distributor_Template_GroupB_Default', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', page='2')>
<cfelse>
<tr class="VolumeCalculations" <cfif templateMgmtSettingsSecPage.Distributor_Off_Invoice_Volume EQ 0> style="display:none"</cfif>>
	<td>Exclude Direct Shipment Volume and Dollars<!--- Direct Shipment Volume and Dollars ---><!--- Operator off Invoice volume and dollars ---></td>
	<td><input type="checkbox" name="Distributor_Off_Invoice_Volume" value="1" <cfif SelectSecondary.Distributor_Off_Invoice_Volume EQ 1>checked</cfif> ></td>
	<td><input type="radio" name="Volume_Distributor_Template_GroupB_Default" value="1" <cfif Action IS "Edit" and SelectSecondary.Volume_Distributor_Template_GroupB_Default IS 1> checked</cfif>></td>
</tr>
</cfif>

<cfif fromSettings_management eq 1>
	<cfset SettingsTemplateForm(NameField="Distributor_Billback_Volume",NameFieldDesc="Exclude Operator Billback Volume and Dollars")>
<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.Distributor_Billback_Volume IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.Volume_Distributor_Template_GroupB_Default IS 2>
			<cfset SDefault = 'Yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Exclude Operator Billback Volume and Dollars', Setting_Field_Name='Distributor_Billback_Volume', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', page='2')>
<cfelse>
<tr class="VolumeCalculations" <cfif templateMgmtSettingsSecPage.Distributor_Billback_Volume EQ 0> style="display:none"</cfif>>
	<td>Exclude Operator Billback Volume and Dollars<!--- Operator Billback Volume and Dollars --->
<!--- Operator billback volume ---></td>
	<td><input type="checkbox" name="Distributor_Billback_Volume" value="1" <cfif SelectSecondary.Distributor_Billback_Volume EQ 1>checked</cfif> ></td>
  <td><input type="radio" name="Volume_Distributor_Template_GroupB_Default" value="2" <cfif Action IS "Edit" and SelectSecondary.Volume_Distributor_Template_GroupB_Default IS 2> checked</cfif>></td>
</tr>
</cfif>

 <cfif fromSettings_management eq 1>
 	<cfset SettingsTemplateForm(NameField="Adjust_For_Credits",NameFieldDesc="Exclude credit volume and dollars")>
<cfelseif url.DownloadSettings>
		<cfset SDValue = 'Not Include'>
		<cfset SDefault = 'No'>

		<cfif SelectSecondary.Adjust_For_Credits IS 1>
			<cfset SDValue = 'Include'>
		</cfif>

		<cfif SelectSecondary.Volume_Distributor_Template_GroupB_Default IS 3>
			<cfset SDefault = 'Yes'>
		</cfif>

		<cfset SettingsToExcel (Setting_Name='Exclude credit volume and dollars', Setting_Field_Name='Adjust_For_Credits', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', page='2')>
 <cfelse>
  <tr class="VolumeCalculations" <cfif templateMgmtSettingsSecPage.Adjust_For_Credits EQ 0> style="display:none"</cfif>>
		<td>Exclude credit volume and dollars<!--- Credit Volume and Dollars ---><!--- Adjust for credits ---></td>
		<td><input type="checkbox" name="Adjust_For_Credits" value="1" <cfif SelectSecondary.Adjust_For_Credits EQ 1>checked</cfif> ></td>
    <td><input type="radio" name="Volume_Distributor_Template_GroupB_Default" value="3" <cfif Action IS "Edit" and SelectSecondary.Volume_Distributor_Template_GroupB_Default IS 3> checked</cfif>></td>
	</tr>
 </cfif>

<cfif fromSettings_management eq 1>
	<cfset SettingsTemplateForm(NameField="Volume_Distributor_Template_GroupB_Default",NameFieldDesc="Invoice level view (Default)")>
<cfelseif url.DownloadSettings>
		<cfset SDefault = 'No'>
		<cfif SelectSecondary.Volume_Distributor_Template_GroupB_Default IS 4>
			<cfset SDefault = 'Yes'>
		</cfif>
		<cfset SettingsToExcel (Setting_Name='Invoice level view', Setting_Field_Name='Adjust_For_Credits', Setting_Value='N/A',  SetAsDefault='#SDefault#',  page='2')>
<cfelse>
<tr class="VolumeCalculations" <cfif templateMgmtSettingsSecPage.Volume_Distributor_Template_GroupB_Default EQ 0> style="display:none"</cfif>>
<td colspan="2">Invoice level view<!--- Set Invoices as Default ---></td>
<td><input type="radio" name="Volume_Distributor_Template_GroupB_Default" value="4" <cfif (Action IS "Edit" and SelectSecondary.Volume_Distributor_Template_GroupB_Default IS 4) OR Action IS "Create"> checked</cfif>></td>
</tr>
</cfif>
</cfif>
<!--- END VOLUME SECTION D19117,D20129 --->


<cfif appSettings.label_sets AND Generic_Type IS NOT "LSAutoPAy">
	<cfset qLabels = createObject("component", "components.settings.Labels.Labels").init()>
	<cfset getProgramLabelSetNames = qLabels.GetProgramLabelSetNames()>
	<tr id="Label_Set_heading" <cfif url.DownloadSettings>style="display:none"</cfif>><th colspan="4"><hr>Label Set</th></tr>
	<cfif fromSettings_management eq 1>
		<cfloop query="getProgramLabelSetNames">
			<cfset SettingsTemplateForm(NameField="#Label_Set_Name#",NameFieldDesc="#Label_Set_Name#")>
		</cfloop>
	<cfelseif url.DownloadSettings>
		<cfloop query="getProgramLabelSetNames">
				<cfset SDefault = 'No'>

			<cfif SelectSecondary.Label_Set_Default IS Label_Set_Name>
				<cfset SDefault = 'Yes'>
			</cfif>

				<cfset SettingsToExcel (Setting_Name='#Label_Set_Name#', Setting_Field_Name='LabelSetDefaultOption', Setting_Value='N/A',  SetAsDefault='#SDefault#', page='2')>
		</cfloop>
	<cfelse>
		<cfif Action IS "Edit">
			<cfset LabelSetDefaultOption = SelectSecondary.Label_Set_Default>
		<cfelse>
			<cfset LabelSetDefaultOption = 1>
		</cfif>
		<cfloop query="getProgramLabelSetNames">
			<tr class="Label_Set" <cfif Evaluate("templateMgmtSettingsSecPage.#Label_Set_Name#") EQ 0> style="display:none"</cfif>>
				<td>#Label_Set_Name#</td>
				<td>&nbsp; </td>
				<td><input type="radio" name="LabelSetDefaultOption" value="#Label_Set_Name#" <cfif LabelSetDefaultOption IS Label_Set_Name>checked</cfif>> </td>
			</tr>
		</cfloop>
	</cfif>

	<cfif fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="LabelSetDefaultOption",NameFieldDesc="No Default")>
	<cfelseif url.DownloadSettings>

			<cfset SDefault = 'Yes'>

		<cfif SelectSecondary.Label_Set_Default IS ''>
			<cfset SDefault = 'No'>
		</cfif>

			<cfset SettingsToExcel (Setting_Name='Label No Default', Setting_Field_Name='Label_Set_Default', SetAsDefault='#SDefault#', page='2')>

	<cfelse>
		<tr class="Label_Set" <cfif templateMgmtSettingsSecPage.LabelSetDefaultOption EQ 0> style="display:none"</cfif>>
			<td>No Default</td>
			<td>&nbsp; </td>
			<td><input type="radio" name="LabelSetDefaultOption" value="" <cfif Action IS "Edit" and SelectSecondary.Label_Set_Default IS "">checked</cfif>></td>
		</tr>
	</cfif>
</cfif>

<cfif fromSettings_management neq 1> <!--- start :: cfif fromSettings_management neq 1 :: 7 ::Settings Management page 41974--->
	<!--- Dev Notes: D23601/Anand Rao/04-Aug-10; Margin Page, Items to Exclude --->
	<cfif appSettings.getMarginItemsExclude()>

		<cfscript>
			ExcludeItemsManager    = CreateObject("component","components.settings.ExcludeItemsManager");
			qGetActiveExcludeItems = ExcludeItemsManager.getActiveItemsExclude();
			bResult = 0;
		</cfscript>

		<cfquery name="getTemplateParentID" datasource="#application.datasource#">
			SELECT First_Parent_ID FROM Program_Control_Panel_Options WHERE ProgramControl_Panel_Options_ID = #ID#
		</cfquery>

		<cfif url.DownloadSettings>

			<cfloop query="qGetActiveExcludeItems">
				<cfset qGetActiveExcludeTemplate = ExcludeItemsManager.getItemExclusionTemplates(qGetActiveExcludeItems.Margin_Item_Exclusion_ID) />
				<cfset bChecked = 0 />

				<!--- Loop through all the availabel templates and check if this template's parent ID is already in the Exclude List --->
				<cfloop query="qGetActiveExcludeTemplate">
					<cfif (qGetActiveExcludeTemplate.Program_Template_ID EQ getTemplateParentID.First_Parent_ID)>
						<cfset bChecked = 1 />
					</cfif>
				</cfloop>
			<cfset SettingsToExcel (Setting_Name='#qGetActiveExcludeItems.Margin_Item_Exclusion_Name#', Setting_Field_Name='excludeItems_#qGetActiveExcludeItems.Margin_Item_Exclusion_ID#', Setting_Value='#bChecked#', page='2')>
			</cfloop>

		<cfelse>

			<tr><th colspan="3"><hr>Margin - Items to Exclude</th></tr>

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
	</cfif>

		<cfif bResult EQ 0 AND ! url.DownloadSettings>
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

	<cfif url.DownloadSettings>
		<cfloop query="qGetCategores">
			<cfset SDValue = 'Not Include'>

			<cfif ListFindNoCase(lCategoryFilters, Category_ID)>
				<cfset SDValue = 'Include'>
			</cfif>

			<cfset SettingsToExcel (Setting_Name='#Category_Name#', Setting_Field_Name='Category_ID', Setting_Value='#SDValue#', page='2')>
		</cfloop>
	<cfelse>
	<tr style="header">
		<th colspan="3"><hr>Filter Product Category</th>
	</tr>
	<cfloop query="qGetCategores">
	<tr>
		<td>#Category_Name#</td>
		<td colspan="3"><input type="checkbox" name="Category_ID" value="#Category_ID#" <cfif ListFindNoCase(lCategoryFilters, Category_ID)>checked</cfif>></td>
	</tr>
	</cfloop>
	</cfif>
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

			<!--- class="cellLeftBorder" --->
			<td width="65%">

				<!--- ...........................................................................
				........................... Right Inner Table [begin] ...........................
				................................. option 1 of 2 ............................ --->
				<table width="400" cellpadding="5" cellspacing="0" border="1" class="maintable">

				<!---Discount minimum/maximums--->
					<tr<cfif url.DownloadSettings> Style="display:none"</cfif>>
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
						<td onClick="ClickToOpenLayer('BidRequestProductMessage','Discount_BidRequest');"><cfif SelectSecondary.Discount_BidRequest_Product_Message neq ""><a style="text-decoration:underline"></cfif>Bid Fixed Price<cfif SelectSecondary.Discount_BidRequest_Product_Message neq ""></a></td></cfif>
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
			<table width="100%" cellpadding="2" cellspacing="0" border="0" id="bigTable">
			<col width="30%">
			<col width="10%">
			<col width="60%">

</cfif> <!--- end :: cfif fromSettings_management neq 1 :: 7 ::Settings Management page 41974--->

<cfif NOT ListFindNoCase("Distributor Off-Invoice,Bid Request,USDA NOI,LSAutoPAy", Generic_Type)>
	<tr id="DiscountTypes_heading" <cfif URL.DownloadSettings>style="display: none;"</cfif>><th colspan="3">Discount Types</th></tr>

	<!---Fixed / Rebate Grid--->
	<cfif fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="Fixed_Rebate_Grid_Option",NameFieldDesc="Fixed/#Application.RebateLabel# Grid")>
	<cfelseif url.DownloadSettings>
		<cfset SettingsToExcel (Setting_Name='Fixed/#Application.RebateLabel# Grid', Setting_Field_Name='Fixed_Rebate_Grid_Option', Setting_Value='#SDValue#', page='2')>
	<cfelse>
		<cfif SelectSecondary.Allow_Vendor_Only EQ 0>
		<tr class="DiscountTypes" <cfif templateMgmtSettingsSecPage.Fixed_Rebate_Grid_Option EQ 0> style="display:none"</cfif>>
			<td>Fixed/#Application.RebateLabel# Grid</td>
			<td><input name="Fixed_Rebate_Grid_Option" type="checkbox"  value="1" <cfif Action IS "Edit" and SelectSecondary.Fixed_Rebate_Grid_Option eq 1>checked</cfif>></td>
			<td>N/A</td>
		</tr>
		</cfif>
	</cfif>

<!---Fixed Price--->
<cfif Generic_Type IS NOT "Brokerage" AND Generic_Type IS NOT "LSAutoPay"> <!---  AND EZButton_On eq 0 ---><!--- D45239 removed to allow fixed --->
<cfif fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="Discount_Fixed_Prices",NameFieldDesc="Fixed Price")>
	<cfif application.appSettingsGet.getTemplateMultipleProductAttrGroups() EQ 1>
		<cfset SettingsTemplateForm(NameField="Discount_Fixed_Prices_Freight",NameFieldDesc="Fixed Price :: #application.returned_customer_setting.distributor_label_singular# Level Fixed Price")>
		<cfset SettingsTemplateForm(NameField="Custom_Fixed_Price_Options",NameFieldDesc="Fixed Price :: Custom Fixed Price Options")>
	</cfif>
		<cfset SettingsTemplateForm(NameField="Market_Price",NameFieldDesc="Fixed Price :: Market Price")>
		<cfset SettingsTemplateForm(NameField="Market_Price_Update_Process",NameFieldDesc="Fixed Price :: Market Price Update Process")>
		<cfset SettingsTemplateForm(NameField="Fixed_Price_Populates_Price_List_Special",NameFieldDesc="Fixed Price :: Fixed Price Populates Price List")>
		<cfset SettingsTemplateForm(NameField="price_list_type",NameFieldDesc="Price List Type")>
		<cfset SettingsTemplateForm(NameField="display_FixedPrice_basesales",NameFieldDesc="Fixed Price :: Show Base Price on View Program Page")>
		<cfset SettingsTemplateForm(NameField="Display_FixedPrice_Basesales_On_Approval",NameFieldDesc="Fixed Price :: Show Base Price at time of approval")>
		<cfset SettingsTemplateForm(NameField="Ideal_Price",NameFieldDesc="Fixed Price :: Ideal Price")>
	<cfif appSettings.getShow_Fixed_Freight()>
		<cfset SettingsTemplateForm(NameField="Fixed_Type",NameFieldDesc="Fixed Price :: Fixed Price Type")>
		<cfset SettingsTemplateForm(NameField="Fixed_Type_Explanation",NameFieldDesc="Fixed Price :: Fixed Price Type Explanation")>
	</cfif>
<cfelseif url.DownloadSettings>
			<cfset SettingsToExcel (Setting_Name='Fixed Price', Setting_Field_Name='Discount_Fixed_Prices', Setting_Value='#SDValue#', page='2')>
			<cfif application.appSettingsGet.getTemplateMultipleProductAttrGroups() EQ 1>
				<cfset SettingsToExcel (Setting_Name='Fixed Price : Item', Setting_Field_Name='Discount_Fixed_Item_Level', Setting_Value='Yes', page='2')>
				<cfset SettingsToExcel (Setting_Name='Fixed Price : Group', Setting_Field_Name='Discount_Fixed_Group_Level', Setting_Value='#SDValue#', Is_Child_Of='Discount_Fixed_Prices', page='2')>
			</cfif>

			<cfset SettingsToExcel (Setting_Name='#application.returned_customer_setting.distributor_label_singular# Level Fixed Price', Setting_Field_Name='Discount_Fixed_Prices_Freight', Is_Child_Of='Discount_Fixed_Prices', page='2')>
			<cfset SettingsToExcel (Setting_Name='Custom Fixed Price Options', Setting_Field_Name='Custom_Fixed_Price_Options', Setting_Value='#SDValue#', Is_Child_Of='Discount_Fixed_Prices' , page='2')>
			<cfset SettingsToExcel (Setting_Name='Market Price Market_Price', Setting_Field_Name='Market_Price', Setting_Value='#SDValue#', Is_Child_Of='Discount_Fixed_Prices', page='2')>
			<cfset SettingsToExcel (Setting_Name='Market Price Update Process (Program Fixed Price gets updated with MP rate when fixed price = MP rate when PRG was approved)', Setting_Field_Name='Market_Price_Update_Process', Is_Child_Of='Discount_Fixed_Prices', page='2')>
			<cfset SettingsToExcel (Setting_Name='	Fixed Price Populates Price List', Setting_Field_Name='Fixed_Price_Populates_Price_List_Special', Setting_Value='#SDValue#', Is_Child_Of='Discount_Fixed_Prices', page='2')>
<cfelse>
					 <cfif SelectSecondary.Allow_Vendor_Only EQ 0>
						<tr class="DiscountTypes" <cfif templateMgmtSettingsSecPage.Discount_Fixed_Prices EQ 0> style="display:none"</cfif>>
							<td onClick="ClickToOpenLayer('FixedPriceProductMessage','Discount_Fixed_Prices');" valign="top"><cfif SelectSecondary.Discount_Fixed_Prices_Product_Message neq ""><a style="text-decoration:underline"></cfif>Fixed Price<cfif SelectSecondary.Discount_Fixed_Prices_Product_Message neq ""></a></td></cfif>
							<td valign="top"><span id="error_Discount_Fixed_Prices"></span> <!--- checkFixedRebateGrid(this); :: D43269 allow only 1 component in rates grid --->
								<input type="checkbox" name="Discount_Fixed_Prices" value="1" onClick="ClickToOpenLayer('FixedPriceProductMessage','Discount_Fixed_Prices');" id="Discount_Fixed_Prices" <cfif Action IS "Edit" and SelectSecondary.Discount_Fixed_Prices IS 1>checked</cfif>>
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
									<div <cfif templateMgmtSettingsSecPage.Market_Price_Update_Process EQ 0> style="display:none"</cfif>>
									<span class="td80">Market Price Update Process (Program Fixed Price gets updated with MP rate when fixed price = MP rate when PRG was approved)</span>
									<input type="checkbox" name="Market_Price_Update_Process" value="1" <cfif Action IS "Edit" and SelectSecondary.Market_Price_Update_Process IS 1>checked </cfif> />
									<br>
									</div>
									<div <cfif templateMgmtSettingsSecPage.Fixed_Price_Populates_Price_List_Special EQ 0> style="display:none"</cfif>>
									<span class="td80">Fixed Price Populates Price List</span>
									<input type="checkbox" name="Fixed_Price_Populates_Price_List_Special" value="1" onClick="showHidePriceListType();" <cfif Action IS "Edit" and SelectSecondary.Fixed_Price_Populates_Price_List_Special IS 1>checked </cfif> />
									<br>
									</div>
									<!--- 71241/73454 :: Create Customer Price List template settings START --->
									<div id="price_list_type_header" <cfif templateMgmtSettingsSecPage.Fixed_Price_Populates_Price_List_Special EQ 0 OR templateMgmtSettingsSecPage.price_list_type EQ 0> style="display:none;"</cfif>  style="margin-bottom:5px;margin-top:5px;">
									Price List Type <br />
									<select name="price_list_type" id="price_list_type">
										<option value="1" <cfif Action IS "Edit" AND selectSecondary.price_list_type IS 1>selected</cfif>>Default Price List</option>
										<option value="2" <cfif Action IS "Edit" AND selectSecondary.price_list_type IS 2>selected</cfif>>List Price by Groups of Customers</option>
										<option value="3" <cfif Action IS "Edit" AND selectSecondary.price_list_type IS 3 OR selectSecondary.price_list_type IS "" OR selectSecondary.price_list_type IS 0>selected</cfif>>Customer and product Specific</option>
									</select>
									</div>
									<!--- 71241/73454 :: Create Customer Price List template settings END --->
								<cfelse>
									<input type="hidden" name="Fixed_Price_Populates_Price_List_Special" value="#SelectSecondary.Fixed_Price_Populates_Price_List_Special#">
									<input type="hidden" name="Market_Price" value="#SelectSecondary.Market_Price#">
									<input type="hidden" name="Market_Price_Update_Process" value="#SelectSecondary.Market_Price_Update_Process#">
									<input type="hidden" name="price_list_type" value="#SelectSecondary.price_list_type#">
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
							<!--- 114617 :: Ideal Price START --->
							<cfif ! findNoCase("Distributor", Generic_Type)>
								<div <cfif templateMgmtSettingsSecPage.Ideal_Price EQ 0 OR SelectSecondary.Retail_Planner NEQ 0 > style="display:none"</cfif>>
									<span class="td80">Ideal Price</span>
									<input type="checkbox" name="Ideal_Price" value="1" id="Ideal_Price" <cfif Action IS "Edit" and SelectSecondary.Ideal_Price IS 1>checked</cfif> <cfif SelectSecondary.Discount_Fixed_Prices NEQ 1>disabled</cfif>>
									<span id="tmpListLink" <cfif ! SelectSecondary.Ideal_Price> style="display:none" </cfif>>
									<cfif LockedBy_Current_User EQ 1>
									<a onclick="javascript:IdealPrice();" STYLE="cursor: pointer;" >
										#application.util.string.actionLinkFormat("view list")#
										</a>
									<cfelse>
										<span id="TemplateLinkDisabled" style="color:gray;cursor:pointer;">
											#application.util.string.actionLinkFormat("view list")#
										</span>
									</cfif>
								</span>
									<br>
								</div>
							</cfif>
							<!--- 114617 :: Ideal Price END --->
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
								<CFIF appSettings.get_Setting('Custom_RFP_Process',0) EQ 1>
									<div <cfif templateMgmtSettingsSecPage.RFP_Process EQ 0> style="display:none"</cfif>>
									<span class="td80">Custom RFP</span>
									<input type="checkbox" id="RFP_Process" name="RFP_Process" value="1" <cfif Action IS "Edit" and SelectSecondary.RFP_Process IS 1>checked </cfif> >
									<br>
									</div>
								<cfelse>
									<input type="hidden" name="RFP_Process" value="<cfif Action IS "Edit">#SelectSecondary.RFP_Process#<cfelse>0</cfif>">
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
					</cfif><!--- end :: cfif SelectSecondary.Allow_Vendor_Only EQ 0 --->
					</cfif><!--- end :: cfif fromSettings_management eq 1  --->
					</cfif>

		<cfif not Generic_Type EQ 'Direct Pricing'>
			<!---Rebate--->
		<cfif fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Discount_Rebates",NameFieldDesc="#Application.RebateLabel#")>
		<cfelseif url.DownloadSettings>
			<cfset SettingsToExcel (Setting_Name='#Application.RebateLabel#', Setting_Field_Name='Discount_Rebates', page='2')>
			<cfset SettingsToExcel (Setting_Name='#Application.RebateLabel# : Item', Setting_Field_Name='Discount_Rebates_Item_Level', Is_Child_Of='Discount_Rebates', page='2')>
			<cfset SettingsToExcel (Setting_Name='#Application.RebateLabel# : Group', Setting_Field_Name='Discount_Rebates_Group_Level', Is_Child_Of='Discount_Rebates', page='2')>
			<cfset SettingsToExcel (Setting_Name='#Application.RebateLabel# : Message', Setting_Field_Name='Discount_Rebates_Product_Message', Is_Child_Of='Discount_Rebates', page='2')>
		<cfelse>
			<cfif SelectSecondary.Allow_Vendor_Only EQ 0>
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
					<input type="checkbox" name="Discount_Rebates" value="1" onClick="checkInclude('Discount_Rebates');ClickToOpenLayer('RebateProductMessage','Discount_Rebates');" #checked.discount_rebates# />
				</td>
				<td>			<!--- <cfif SelectSecondary.Fixed_Rebate_Grid_Option eq 1 and (not len(trim(disableGroup)) or form.Group_Deal neq 1)>disabled</cfif> --->
					Item <input name="Discount_Rebates_Item_Level" type="checkbox"  onClick="checkType('Discount_Rebates');" value="1"  <cfif Action IS "Edit" AND SelectSecondary.Discount_Rebates_Item_Level eq 1 >checked</cfif> /> &nbsp; &nbsp;<!--- and SelectSecondary.Fixed_Rebate_Grid_Option neq 1 --->
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
			</cfif>
			</cfif>

			<!---Lump Sum--->
			<cfif Generic_Type IS NOT "Brokerage" <!---29808 - AND EZButton_On eq 0--->>
				<cfif fromSettings_management eq 1>
					<cfset SettingsTemplateForm(NameField="Discount_Lump_Sums",NameFieldDesc="#Application.LumpsumLabel#")>
					<cfset SettingsTemplateForm(NameField="Discount_Lump_Sums_Item_Mandated",NameFieldDesc="#Application.LumpsumLabel# :: Product Required")>
					<cfset SettingsTemplateForm(NameField="Discount_Lump_Sums_Distributor_Mandated",NameFieldDesc="#Application.LumpsumLabel# :: #application.returned_customer_setting.distributor_label_singular# Required")>
					<cfset SettingsTemplateForm(NameField="Discount_Lump_Sums_Document_Attachment_Mandated",NameFieldDesc="#Application.LumpsumLabel# :: Document Attachment Required")>
			<cfelseif url.DownloadSettings>
				<cfset SettingsToExcel (Setting_Name='#Application.LumpsumLabel#', Setting_Field_Name='Discount_Lump_Sums', page='2')>
				<cfset SettingsToExcel (Setting_Name='#Application.LumpsumLabel# : Item', Setting_Field_Name='Discount_Lump_Sums_Item_Level', Is_Child_Of='Discount_Lump_Sums', page='2')>
				<cfset SettingsToExcel (Setting_Name='#Application.LumpsumLabel# : Group', Setting_Field_Name='Discount_Lump_Sums_Group_Level', Is_Child_Of='Discount_Lump_Sums', page='2')>
				<cfset SettingsToExcel (Setting_Name='#Application.LumpsumLabel# : Product Required', Setting_Field_Name='Discount_Lump_Sums_Item_Mandated', Is_Child_Of='Discount_Lump_Sums', page='2')>
				<cfset SettingsToExcel (Setting_Name='#Application.LumpsumLabel# : #application.returned_customer_setting.distributor_label_singular# Required', Setting_Field_Name='Discount_Lump_Sums_Distributor_Mandated', Is_Child_Of='Discount_Lump_Sums', page='2')>
				<cfset SettingsToExcel (Setting_Name='#Application.LumpsumLabel# :: Document Attachment Required', Setting_Field_Name='Discount_Lump_Sums_Document_Attachment_Mandated', Is_Child_Of='Discount_Lump_Sums', page='2')>
				<cfset SettingsToExcel (Setting_Name='#Application.LumpsumLabel# : Message', Setting_Field_Name='Discount_Lump_Sums_Product_Message', Is_Child_Of='Discount_Lump_Sums', page='2')>
			<cfelse>
				<tr class="DiscountTypes" <cfif templateMgmtSettingsSecPage.Discount_Lump_Sums EQ 0> style="display:none"</cfif>>
					<td valign="top" onClick="ClickToOpenLayer('LumpsumProductMessage','Discount_Lump_Sums');"><span id="error_Discount_Lump_Sum"></span><cfif SelectSecondary.Discount_Lump_Sums_Product_Message neq ""><a style="text-decoration:underline"></cfif>#Application.LumpsumLabel#<cfif SelectSecondary.Discount_Lump_Sums_Product_Message neq ""></a></cfif></td>
					<td valign="top">
						<input type="checkbox" name="Discount_Lump_Sums" value="1" onClick="checkInclude('Discount_Lump_Sums');ClickToOpenLayer('LumpsumProductMessage','Discount_Lump_Sums');changeDisableOtherCheckBoxes(this, this.form.Discount_Lump_Sums_Distributor_Mandated);changeDisableOtherCheckBoxes(this, this.form.Discount_Lump_Sums_Document_Attachment_Mandated);"  <cfif Action IS "Edit" and SelectSecondary.Discount_Lump_Sums IS 1> checked</cfif>>
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
				</cfif>

				<!---
					D45979  :: Growth discount type not available when EZ Button is on for Advance food we want to display GROWTH even template is EZ button, to customize this for advancefoods we added "Max rate from Internal table"  setting in IF statement
					In label D46116 we removed app setting "Max rate from internal table" Constrain
					In label D46372  we removed EZ button constrain , making growth component visible all the times.
					<cfif EZButton_On EQ 0 AND EZButton_On eq 0>--->
					<cfif fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="Discount_Growth",NameFieldDesc="Growth")>
						<cfset SettingsTemplateForm(NameField="Allow_Multi",NameFieldDesc="Growth :: Allow bracket rate")>
						<cfset SettingsTemplateForm(NameField="Allow_Single",NameFieldDesc="Growth :: Allow retroactive rate")>
						<cfset SettingsTemplateForm(NameField="Allow_Volume_Pool_Seperation",NameFieldDesc="Growth :: Allow Volume Pool Separation")>
						<cfset SettingsTemplateForm(NameField="Bonus_Field",NameFieldDesc="Growth :: #Application.BonusLabel# Field")>
						<cfset SettingsTemplateForm(NameField="growth_auto_pay",NameFieldDesc="Growth :: Auto Pay")>
						<cfset SettingsTemplateForm(NameField="Growth_Min_Purchase",NameFieldDesc="Growth :: Minimum $ Purchase")>
				<cfelseif url.DownloadSettings>
					<cfset SettingsToExcel (Setting_Name='Growth', Setting_Field_Name='Discount_Growth', page='2')>
					<cfset SettingsToExcel (Setting_Name='Growth : Allow bracket rate', Setting_Field_Name='Allow_Multi', Is_Child_Of='Discount_Growth', page='2')>
					<cfset SettingsToExcel (Setting_Name='Growth : Allow retroactive rate', Setting_Field_Name='Allow_Single', Is_Child_Of='Discount_Growth', page='2')>
					<cfset SettingsToExcel (Setting_Name='Growth : Allow Volume Pool Separation', Setting_Field_Name='Allow_Volume_Pool_Seperation', Is_Child_Of='Discount_Growth', page='2')>
					<cfset SettingsToExcel (Setting_Name='Growth : #Application.BonusLabel# Field', Setting_Field_Name='Bonus_Field', Is_Child_Of='Discount_Growth', page='2')>
					<cfset SettingsToExcel (Setting_Name='Growth : Auto Pay', Setting_Field_Name='Growth_Auto_Pay', Is_Child_Of='Discount_Growth', page='2')>
					<cfset SettingsToExcel (Setting_Name='Growth : Minimum $ Purchase', Setting_Field_Name='Growth_Min_Purchase', Is_Child_Of='Discount_Growth', page='2')>
				<cfelse>
					<cfif SelectSecondary.Allow_Vendor_Only EQ 0>
					<!---Growth--->
					<tr valign="top" class="DiscountTypes" <cfif templateMgmtSettingsSecPage.Discount_Growth EQ 0> style="display:none"</cfif>>
						<td onClick="ClickToOpenLayer('GrowthProductMessage','Discount_Growth');"><cfif SelectSecondary.Discount_Growth_Product_Message neq ""><a style="text-decoration:underline"></cfif>Growth<cfif SelectSecondary.Discount_Growth_Product_Message neq ""></a></td></cfif>
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

						<!--- 45068 Growth  Minimum $ Purchase --->
						<div <cfif templateMgmtSettingsSecPage.Growth_Min_Purchase EQ 0> style="display:none"</cfif>>
						<span class="td80">Minimum $ Purchase</span>
						<input type="checkbox" id="Growth_Min_Purchase" name="Growth_Min_Purchase" value="1" <cfif SelectSecondary.Growth_Min_Purchase>checked</cfif>>
						<br>
						</div>
					</td>
					</tr>
					<tr id="GrowthProductMessage" style="display:none;" class="DiscountTypes" >
						<td colspan="3"><span style="color:red;vertical-align:top;">Growth Message:</span><br /><textarea name="Discount_Growth_Product_Message" rows="4" cols="40" onPaste="javaScript: return textareaChecklength(200, this);"  onkeyPress="javaScript: return textareaChecklength(200, this);">#SelectSecondary.Discount_Growth_Product_Message#</textarea></td>
					</tr>
					<!---validate checkbox selections--->
					<script>checkInclude('Discount_Growth');</script>
					</cfif>
					</cfif>
				<!---</cfif>--->
				<!---	D45979  :: Growth discount type not available when EZ Button is on --->
				<cfif EZButton_On EQ 0 AND EZButton_On eq 0>
					<!---Formula Pricing--->
					<cfif fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="Discount_Formula_Pricing",NameFieldDesc="Formula Pricing")>
				<cfelseif url.DownloadSettings>
					<cfset SettingsToExcel (Setting_Name='Formula Pricing', Setting_Field_Name='Discount_Formula_Pricing', page='2')>
					<cfset SettingsToExcel (Setting_Name='Formula Pricing Message', Setting_Field_Name='Discount_Formula_Pricing_Product_Message', Is_Child_Of='Discount_Formula_Pricing', page='2')>
					<cfset SettingsToExcel (Setting_Name='Bid Pricing (automated pricing)', Setting_Field_Name='Bid_Rule_Option', Is_Child_Of='Discount_Formula_Pricing', page='2')>
				<cfelse>
					<cfif SelectSecondary.Allow_Vendor_Only EQ 0>
					<tr class="DiscountTypes" <cfif templateMgmtSettingsSecPage.Discount_Formula_Pricing EQ 0> style="display:none"</cfif>>
						<td onClick="ClickToOpenLayer('FormulaPricingProductMessage','Discount_Formula_Pricing');"><cfif SelectSecondary.Discount_Formula_Pricing_Product_Message neq ""><a style="text-decoration:underline"></cfif>Formula Pricing<cfif SelectSecondary.Discount_Formula_Pricing_Product_Message neq ""></a></td></cfif>
						<td><input type="checkbox" name="Discount_Formula_Pricing" onClick="ClickToOpenLayer('FormulaPricingProductMessage','Discount_Formula_Pricing');" <cfif SelectSecondary.Date_Exclusions_ON eq 1>disabled <cfelse>#disableItem# </cfif> value="1" <cfif Action IS "Edit" and SelectSecondary.Discount_Formula_Pricing IS 1 and disableItem neq "disabled"> checked</cfif>></td>
						<td>N/A</td>
					</tr>
					<tr id="FormulaPricingProductMessage" style="display:none;" class="DiscountTypes" >
						<td colspan="3"><span style="color:red;vertical-align:top;">Formula Pricing Message:</span><br /><textarea name="Discount_Formula_Pricing_Product_Message" rows="4" cols="40" onPaste="javaScript: return textareaChecklength(200, this);"  onkeyPress="javaScript: return textareaChecklength(200, this);">#SelectSecondary.Discount_Formula_Pricing_Product_Message#</textarea></td>
					</tr>
						<cfif appSettings.get_Setting('Custom_RFP_Process',0) EQ 0 and appSettings.get_Setting('Formula_Price_Item_Level_Config',0) EQ 1>
							<!---Formula Pricing Type--->
							<tr class="DiscountTypes" <cfif templateMgmtSettingsSecPage.Discount_Formula_Pricing EQ 0> style="display:none"</cfif>>
								<td>Formula Pricing Type</td>
								<td>
									<select name="Formula_Pricing_Type">
										<option value="0">Select Type...</option>
										<option value="1" <cfif Action IS "Edit" and SelectSecondary.Formula_Pricing_Type eq 1 and disableItem neq "disabled"> selected</cfif> >Item - Bracket Level</option>
										<option value="2" <cfif Action IS "Edit" and SelectSecondary.Formula_Pricing_Type eq 2 and disableItem neq "disabled"> selected</cfif> >Item - Component Level</option>
									</select>
								</td>
							</tr>
						</cfif>
					</cfif>
					<cfif fromSettings_management eq 1>
						<cfset SettingsTemplateForm(NameField="Bid_Rule_Option",NameFieldDesc="Bid Pricing (automated pricing)")>
					<cfelse>
					<cfif application.bidPricingLinksAvailable>
						<!---Bid Pricing--->
						<tr  class="DiscountTypes" <cfif templateMgmtSettingsSecPage.Bid_Rule_Option EQ 0> style="display:none"</cfif>>
							<td>Bid Pricing (automated pricing)</td>
							<td><input type="checkbox" name="Bid_Rule_Option" value="1" #disableItem# <cfif Action IS "Edit" and SelectSecondary.Bid_Rule_Option IS 1 and disableItem neq "disabled"> checked</cfif>></td>
							<td>N/A</td>

						</tr>
					</cfif>
					</cfif>
				</cfif>
				</cfif>
			</cfif> <!--- Not Brokerage --->
		</cfif><!------ Not Direct Pricing ----->

		<!---Discount minimum/maximums--->

		<tr id="DiscountMinMax_heading_1"<cfif url.DownloadSettings> Style="display:none"</cfif>><th colspan="3"><hr>Discount Min/Max</th></tr>

		<!---Fixed Price--->
		<cfif Generic_Type IS NOT "Brokerage" >
		  <cfif fromSettings_management eq 1>
				<cfset SettingsTemplateForm(NameField="Min_Fixed_Pound",NameFieldDesc="Fixed Price Pound")>
		  <cfelseif url.DownloadSettings>
					<cfset SettingsToExcel (Setting_Name='Fixed Price Pound', Setting_Field_Name='Min_Fixed_Pound', Setting_Value='#SelectSecondary.Min_Fixed_Pound#', page='2')>
					<cfset SettingsToExcel (Setting_Name='Fixed Price Pound', Setting_Field_Name='Max_Fixed_Pound', Setting_Value='#SelectSecondary.Max_Fixed_Pound#', Is_Child_Of='Min_Fixed_Pound',  page='2')>
		  <cfelse>
			<tr class="DiscountMinMax" <cfif templateMgmtSettingsSecPage.Min_Fixed_Pound EQ 0> style="display:none"</cfif>>
				<td>Fixed Price Pound</td>
        <td><input type="text" name="Min_Fixed_Pound" value="#SelectSecondary.Min_Fixed_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10"></td>
        <td><input type="text" name="Max_Fixed_Pound" value="#SelectSecondary.Max_Fixed_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<span id="error_Fixed_Pound"></span></td>
			</tr>
		  </cfif>

		  <cfif fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Min_Fixed_Case",NameFieldDesc="Fixed Price Case")>
			<cfelseif url.DownloadSettings>
					<cfset SettingsToExcel (Setting_Name='Fixed Price Case', Setting_Field_Name='Min_Fixed_Case', Setting_Value='#SelectSecondary.Min_Fixed_Case#', page='2')>
					<cfset SettingsToExcel (Setting_Name='Fixed Price Case', Setting_Field_Name='Max_Fixed_Case', Setting_Value='#SelectSecondary.Max_Fixed_Case#', Is_Child_Of='Min_Fixed_Case', page='2')>
		  <cfelse>
			<tr class="DiscountMinMax" <cfif templateMgmtSettingsSecPage.Min_Fixed_Case EQ 0> style="display:none"</cfif>>
				<td>Fixed Price Case</td>
        <td><input type="text" name="Min_Fixed_Case" value="#SelectSecondary.Min_Fixed_Case#" onKeyUp="clenseText(this, '0123456789.')" size="10"></td>
        <td><input type="text" name="Max_Fixed_Case" value="#SelectSecondary.Max_Fixed_Case#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<span id="error_Fixed_Case"></span></td>
			</tr>
		  </cfif>
		</cfif>

		<cfif not Generic_Type EQ 'Direct Pricing'>
			<!---Rebate--->
			<cfif fromSettings_management eq 1>
				<cfset SettingsTemplateForm(NameField="Min_Rebate_Pound",NameFieldDesc="#Application.RebateLabel# Pound")>
			<cfelseif url.DownloadSettings>
					<cfset SettingsToExcel (Setting_Name='#Application.RebateLabel# Pound', Setting_Field_Name='Min_Rebate_Pound', Setting_Value='#SelectSecondary.Min_Rebate_Pound#', page='2')>
					<cfset SettingsToExcel (Setting_Name='#Application.RebateLabel# Pound', Setting_Field_Name='Max_Rebate_Pound', Setting_Value='#SelectSecondary.Max_Rebate_Pound#', Is_Child_Of='Min_Rebate_Pound', page='2')>
			<cfelse>
			<tr class="DiscountMinMax" <cfif templateMgmtSettingsSecPage.Min_Rebate_Pound EQ 0> style="display:none"</cfif>>
				<td>#Application.RebateLabel# Pound</td>
				<td><input type="text" name="Min_Rebate_Pound" value="#SelectSecondary.Min_Rebate_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10"></td>
				<td><input type="text" name="Max_Rebate_Pound" value="#SelectSecondary.Max_Rebate_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<span id="error_Rebate_Pound"></span></td>
      </tr>
			</cfif>

			<cfif fromSettings_management eq 1>
				<cfset SettingsTemplateForm(NameField="Min_Rebate_Case",NameFieldDesc="#Application.RebateLabel# Case")>
			<cfelseif url.DownloadSettings>
					<cfset SettingsToExcel (Setting_Name='#Application.RebateLabel# Case', Setting_Field_Name='Min_Rebate_Case', Setting_Value='#SelectSecondary.Min_Rebate_Case#', page='2')>
					<cfset SettingsToExcel (Setting_Name='#Application.RebateLabel# Case', Setting_Field_Name='Max_Rebate_Case', Setting_Value='#SelectSecondary.Max_Rebate_Case#', Is_Child_Of='Min_Rebate_Case', page='2')>
			<cfelse>
			<tr class="DiscountMinMax" <cfif templateMgmtSettingsSecPage.Min_Rebate_Case EQ 0> style="display:none"</cfif>>
				<td>#Application.RebateLabel# Case</td>
				<td><input type="text" name="Min_Rebate_Case" value="#SelectSecondary.Min_Rebate_Case#" onKeyUp="clenseText(this, '0123456789.')" size="10"></td>
				<td><input type="text" name="Max_Rebate_Case" value="#SelectSecondary.Max_Rebate_Case#" onKeyUp="clenseText(this, '0123456789.')" size="10">    <span id="error_Rebate_Case"></span></td>
      </tr>
			</cfif>

			<cfif fromSettings_management eq 1>
				<cfset SettingsTemplateForm(NameField="Min_Rebate_Percent",NameFieldDesc="#Application.RebateLabel# Percent")>
			<cfelseif url.DownloadSettings>
					<cfset SettingsToExcel (Setting_Name='#Application.RebateLabel# Percent', Setting_Field_Name='Min_Rebate_Percent', Setting_Value='#SelectSecondary.Min_Rebate_Percent#', page='2')>
					<cfset SettingsToExcel (Setting_Name='#Application.RebateLabel# Percent', Setting_Field_Name='Max_Rebate_Percent', Setting_Value='#SelectSecondary.Max_Rebate_Percent#', Is_Child_Of='Min_Rebate_Percent', page='2')>
			<cfelse>
			<tr class="DiscountMinMax" <cfif templateMgmtSettingsSecPage.Min_Rebate_Percent EQ 0> style="display:none"</cfif>>
				<td>#Application.RebateLabel# Percent</td>
				<td><input type="text" name="Min_Rebate_Percent" value="#SelectSecondary.Min_Rebate_Percent#" onKeyUp="clenseText(this, '0123456789.')" size="10"></td>
				<td><input type="text" name="Max_Rebate_Percent" value="#SelectSecondary.Max_Rebate_Percent#" onKeyUp="clenseText(this, '0123456789.')" size="10">		<span id="error_Rebate_Percent"></span></td>
      </tr>
			</cfif>

			<cfif Generic_Type IS NOT "Brokerage" >
				<cfif EZButton_On EQ 0>
						<!---Growth--->
			<cfif fromSettings_management eq 1>
				<cfset SettingsTemplateForm(NameField="Min_Growth_Pound",NameFieldDesc="Growth Pound")>
			<cfelseif url.DownloadSettings>
					<cfset SettingsToExcel (Setting_Name='Growth Pound', Setting_Field_Name='Min_Growth_Pound', Setting_Value='#SelectSecondary.Min_Growth_Pound#', page='2')>
					<cfset SettingsToExcel (Setting_Name='Growth Pound', Setting_Field_Name='Max_Growth_Pound', Setting_Value='#SelectSecondary.Max_Growth_Pound#', Is_Child_Of='Min_Growth_Pound', page='2')>
			<cfelse>
				<tr class="DiscountMinMax" <cfif templateMgmtSettingsSecPage.Min_Growth_Pound EQ 0> style="display:none"</cfif>>
					<td>Growth Pound</td>
					<td><input type="text" name="Min_Growth_Pound" value="#SelectSecondary.Min_Growth_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10"></td>
					<td><input type="text" name="Max_Growth_Pound" value="#SelectSecondary.Max_Growth_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<span id="error_Growth_Pound"></span></td>
				</tr>
			</cfif>

			<cfif fromSettings_management eq 1>
				<cfset SettingsTemplateForm(NameField="Min_Growth_Case",NameFieldDesc="Growth Case")>
			<cfelseif url.DownloadSettings>
					<cfset SettingsToExcel (Setting_Name='Growth Case', Setting_Field_Name='Min_Growth_Case', Setting_Value='#SelectSecondary.Min_Growth_Case#', page='2')>
					<cfset SettingsToExcel (Setting_Name='Growth Case', Setting_Field_Name='Max_Growth_Case', Setting_Value='#SelectSecondary.Max_Growth_Case#', Is_Child_Of='Min_Growth_Case', page='2')>
			<cfelse>
				<tr class="DiscountMinMax" <cfif templateMgmtSettingsSecPage.Min_Growth_Case EQ 0> style="display:none"</cfif>>
					<td>Growth Case</td>
					<td><input type="text" name="Min_Growth_Case" value="#SelectSecondary.Min_Growth_Case#" onKeyUp="clenseText(this, '0123456789.')" size="10"></td>
					<td><input type="text" name="Max_Growth_Case" value="#SelectSecondary.Max_Growth_Case#" onKeyUp="clenseText(this, '0123456789.')" size="10"> <span id="error_Growth_Case"></span></td>
				</tr>
			</cfif>

			<cfif fromSettings_management eq 1>
				<cfset SettingsTemplateForm(NameField="Min_Growth_Percent",NameFieldDesc="Growth Percent")>
			<cfelseif url.DownloadSettings>
					<cfset SettingsToExcel (Setting_Name='Growth Percent', Setting_Field_Name='Min_Growth_Percent', Setting_Value='#SelectSecondary.Min_Growth_Percent#', page='2')>
					<cfset SettingsToExcel (Setting_Name='Growth Percent', Setting_Field_Name='Max_Growth_Percent', Setting_Value='#SelectSecondary.Max_Growth_Percent#', Is_Child_Of='Min_Growth_Percent', page='2')>
			<cfelse>
						<tr class="DiscountMinMax" <cfif templateMgmtSettingsSecPage.Min_Growth_Percent EQ 0> style="display:none"</cfif>>
							<td>Growth Percent</td>
							<td><input type="text" name="Min_Growth_Percent" value="#SelectSecondary.Min_Growth_Percent#" onKeyUp="clenseText(this, '0123456789.')" size="10"></td>
							<td><input type="text" name="Max_Growth_Percent" value="#SelectSecondary.Max_Growth_Percent#" onKeyUp="clenseText(this, '0123456789.')" size="10">		<span id="error_Growth_Percent"></span></td>
						</tr>
			</cfif>

			<cfif fromSettings_management eq 1>
				<cfset SettingsTemplateForm(NameField="Min_Formula_Pound",NameFieldDesc="Formula Pound")>
			<cfelseif url.DownloadSettings>
					<cfset SettingsToExcel (Setting_Name='Formula Pound', Setting_Field_Name='Min_Formula_Pound', Setting_Value='#SelectSecondary.Min_Formula_Pound#', page='2')>
					<cfset SettingsToExcel (Setting_Name='Formula Pound', Setting_Field_Name='Max_Formula_Pound', Setting_Value='#SelectSecondary.Max_Formula_Pound#', Is_Child_Of='Min_Formula_Pound', page='2')>
			<cfelse>
						<!---Formula Pricing--->
						<tr class="DiscountMinMax" <cfif templateMgmtSettingsSecPage.Min_Formula_Pound EQ 0> style="display:none"</cfif>>
							<td>Formula Pound</td>
              <td><input type="text" name="Min_Formula_Pound" value="#SelectSecondary.Min_Formula_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10"></td>
              <td><input type="text" name="Max_Formula_Pound" value="#SelectSecondary.Max_Formula_Pound#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<span id="error_Formula_Pound"></span></td>
            </tr>
			</cfif>

			<cfif fromSettings_management eq 1>
				<cfset SettingsTemplateForm(NameField="Min_Formula_Percent",NameFieldDesc="Formula Percent")>
			<cfelseif url.DownloadSettings>
					<cfset SettingsToExcel (Setting_Name='Formula Percent', Setting_Field_Name='Min_Formula_Percent', Setting_Value='#SelectSecondary.Min_Formula_Percent#', page='2')>
					<cfset SettingsToExcel (Setting_Name='Formula Percent', Setting_Field_Name='Max_Formula_Percent', Setting_Value='#SelectSecondary.Max_Formula_Percent#', Is_Child_Of='Min_Formula_Percent', page='2')>
			<cfelse>
			<tr class="DiscountMinMax" <cfif templateMgmtSettingsSecPage.Min_Formula_Percent EQ 0> style="display:none"</cfif>>
				<td>Formula Percent</td>
			  <td><input type="text" name="Min_Formula_Percent" value="#SelectSecondary.Min_Formula_Percent#" onKeyUp="clenseText(this, '0123456789.')" size="10"></td>
			  <td><input type="text" name="Max_Formula_Percent" value="#SelectSecondary.Max_Formula_Percent#" onKeyUp="clenseText(this, '0123456789.')" size="10">	<span id="error_Formula_Percent"></span></td>
			</tr>
			</cfif>

 <!--- End EZButton cfif --->
</cfif> <!--- Not Brokerage  --->

		</cfif><!------ Not Direct Pricing ----->
		</cfif> <!--- END FROM 1676 NOT ListFindNoCase("Distributor Off-Invoice,Bid Request,USDA NOI,LSAutoPAy", Generic_Type) --->
</cfif> <!--- end :: cfif fromSettings_management neq 1 :: 8 ::Settings Management page 41974--->

<cfif NOT ListFindNoCase("Distributor Off-Invoice,Bid Request,USDA NOI", Generic_Type)>

<tr id="PerformanceRequirements_heading_1"<cfif url.DownloadSettings> Style="display:none"</cfif>><th colspan="3"><hr><br>Performance Requirements</th></tr>
	<cfif fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="minPerfRequirementsOn",NameFieldDesc="Min Required")>
	<cfelseif url.DownloadSettings>
			<cfset SettingsToExcel (Setting_Name='Performance Requirements Min Required', Setting_Field_Name='minPerfRequirementsOn', page='2')>
			<cfset SettingsToExcel (Setting_Name='Performance Requirements Min Requirements', Setting_Field_Name='minPerfRequirements', Setting_Value='#SelectSecondary.minPerfRequirements#', Is_Child_Of='minPerfRequirementsOn', page='2')>
	<cfelse>
	<tr class="PerformanceRequirements" <cfif templateMgmtSettingsSecPage.minPerfRequirementsOn EQ 0> style="display:none"</cfif>>
		<td>Min Required</td>
		<td>yes<input type="radio" name="minPerfRequirementsOn" value="1" <cfif SelectSecondary.minPerfRequirementsOn eq "1">checked</cfif> onClick="minPerformanceRequirements()"/>
						no<input type="radio" name="minPerfRequirementsOn" value="0" <cfif SelectSecondary.minPerfRequirementsOn eq "0">checked</cfif> onClick="minPerformanceRequirements()" />
		</td>
		<td><input type="text" size="5" name="minPerfRequirements" id="minPerfRequirements" value="#SelectSecondary.minPerfRequirements#" <cfif SelectSecondary.minPerfRequirementsOn eq "0">disabled="true"</cfif>  class="wd70"/></td>
	</tr>
	</cfif>

	<cfif fromSettings_management eq 1>
		<cfset SettingsTemplateForm(NameField="maxPerfRequirementsOn",NameFieldDesc="Max Required")>
	<cfelseif url.DownloadSettings>
			<cfset SettingsToExcel (Setting_Name='Performance Requirements Max Required', Setting_Field_Name='maxPerfRequirementsOn', page='2')>
			<cfset SettingsToExcel (Setting_Name='Performance Requirements Max Requirements', Setting_Field_Name='maxPerfRequirements', Setting_Value='#SelectSecondary.maxPerfRequirements#', Is_Child_Of='maxPerfRequirementsOn', page='2')>
	<cfelse>
	<tr class="PerformanceRequirements" <cfif templateMgmtSettingsSecPage.maxPerfRequirementsOn EQ 0> style="display:none"</cfif>>
	 <td>Max Required</td>
	 <td>yes<input type="radio" name="maxPerfRequirementsOn" value="1" <cfif SelectSecondary.maxPerfRequirementsOn eq "1">checked</cfif> onClick="maxPerformanceRequirements()" />
						no <input type="radio" name="maxPerfRequirementsOn" value="0" <cfif SelectSecondary.maxPerfRequirementsOn eq "0">checked</cfif> onClick="maxPerformanceRequirements()" />
	</td>
	 <td><input type="text" size="5" name="maxPerfRequirements" <cfif SelectSecondary.maxPerfRequirementsOn eq "0">disabled="true"</cfif> id="maxPerfRequirements" value="#SelectSecondary.maxPerfRequirements#" class="wd70"/></td>
	</tr>
	</cfif>

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


					<tr id="PerformanceRequirements_heading_3" <cfif (fromSettings_management eq 1 or qmgmtSettingProgram_Perf_Req.recordcount eq 0) or url.DownloadSettings> style="display:none"</cfif>>
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
	<cfif fromSettings_management eq 1>
	<tr>
		<td align="left">#Requirement_Name#</td>
		<td align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
		<input type="radio" name="Requirement_#Program_Perf_Req_ID#" value="1" id="Requirement_#Program_Perf_Req_ID#_1" <cfif GetPerformanceRequirements.Setting_Display_Value EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="radio" name="Requirement_#Program_Perf_Req_ID#" value="0" id="Requirement_#Program_Perf_Req_ID#_0" <cfif GetPerformanceRequirements.Setting_Display_Value EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<cfset SettingsTemplateForm(NameField="Requirement_#Program_Perf_Req_ID#",NameFieldDesc="#Requirement_Name#",SettingDisplayValueInTable="Program_Perf_Mapping",SettingDisplayValueInTableID="#Program_Perf_Req_ID#")>
	<cfelseif url.DownloadSettings>
		<cfif GetPerformanceRequirements.Setting_Display_Value>
			<cfset SDValue = 'Not Include'>
			<cfset SDefault = ''>

			<cfif SelectSecondary.minPerfRequirementsOn>
				<cfset SDValue = 'Yes'>
			</cfif>

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
								<cfquery name="InPerfReq" datasource="#application.datasource#">
									select *
									from Program_Perf_Req_Labels
									where Program_Perf_Req_ID = #GetPerformanceRequirements.Program_Perf_Req_ID#
									and deleted = 0
								</cfquery>

								<cfif InThisTemplate.Recordcount>
									<cfset useLakebaseForInPerfReqName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("inperfreq")>
<cfif useLakebaseForInPerfReqName>
	<cftry>
		<cfset InPerfReqName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("inperfreq", {
				"perf_req_label_id" = "eq.#InThisTemplate.Program_Perf_Req_Checked#",
				"deleted" = "eq.0",
				"select" = "perf_req_label"
			}), "perf_req_label"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForInPerfReqName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInPerfReqName>
<cfquery name="InPerfReqName" dbtype="query">
										select Perf_Req_Label
										from InPerfReq
										where Perf_Req_Label_ID = #InThisTemplate.Program_Perf_Req_Checked#
										and deleted = 0
									</cfquery>
</cfif>
									<cfset SDefault = '#InPerfReqName.Perf_Req_Label#'>
								<cfelse>
										<cfif selReqVal EQ 1><cfset SDefault = 'Yes (default)'></cfif>
										<cfif selReqVal EQ 2><cfset SDefault = 'No (default)'></cfif>
										<cfif selReqVal EQ 3><cfset SDefault = 'Only Yes'></cfif>
										<cfif selReqVal EQ 4><cfset SDefault = 'Only No'></cfif>
								</cfif>

			<cfset SettingsToExcel (Setting_Name='#Requirement_Name#', Setting_Field_Name='Requirement_#Program_Perf_Req_ID#', Setting_Value='#SDValue#', page='2')>

		</cfif>
	<cfelse>
						<!---Invoice/Billback--->
						<tr class="PerformanceRequirements" <cfif GetPerformanceRequirements.Setting_Display_Value EQ 0> style="display:none"</cfif>>
							<td>#Requirement_Name#</td>
							<td><input type="checkbox" name="Requirement_#Program_Perf_Req_ID#" value="1" <cfif InThisTemplate.Recordcount GT 0>checked</cfif> onClick="javascript:setDefaultCheck(this);"></td>
 							<td>
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
								<cfquery name="InPerfReq" datasource="#application.datasource#">
									select *
									from Program_Perf_Req_Labels
									where Program_Perf_Req_ID = #GetPerformanceRequirements.Program_Perf_Req_ID#
									and deleted = 0
								</cfquery>
								<select name="Requirement_#Program_Perf_Req_ID#_Display" class="wd70">
										<option value="0" <cfif selReqVal EQ 0>selected</cfif>>Neither</option>
									<cfif InPerfReq.Recordcount>
										<cfloop query="InPerfReq">
											<option value="#Perf_Req_Label_ID#" <cfif InThisTemplate.Program_Perf_Req_Checked EQ Perf_Req_Label_ID>selected</cfif>>#Perf_Req_Label#</option>
										</cfloop>
									<cfelse>
										<option value="1" <cfif selReqVal EQ 1>selected</cfif>>Yes (default)</option>
										<option value="2" <cfif selReqVal EQ 2>selected</cfif>>No (default)</option>
										<option value="3" <cfif selReqVal EQ 3>selected</cfif>>Only Yes</option>
										<option value="4" <cfif selReqVal EQ 4>selected</cfif>>Only No</option>
									</cfif>
								</select>
							</td>
						</tr>
						</cfif>
					</cfloop>

				</cfif> <!---END FROM 1955:  NOT ListFindNoCase("Distributor Off-Invoice,Bid Request,USDA NOI", Generic_Type --->
<cfif fromSettings_management neq 1> <!--- start :: cfif fromSettings_management neq 1 :: 11 ::Settings Management page 41974--->

	<cfif NOT ListFindNoCase("Distributor Off-Invoice,Bid Request,USDA NOI,LSAutoPAy", Generic_Type)>
	<cfif appsettings.gettemplatecodes_on()>
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
			select 	template_code,template_code_id
			from	template_codes
			where 	deleted = 0
			and 	active = 1
			order by template_code
		</cfquery>
</cfif>

		<cfif url.DownloadSettings>
				<cfset SDValue = 'None'>
				<cfif form.Program_Spending_Type>
					<cfset useLakebaseForPST_Name = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gettemplatecodes")>
<cfif useLakebaseForPST_Name>
	<cftry>
		<cfset PST_Name = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gettemplatecodes", {
				"template_code_id" = "eq.#form.Program_Spending_Type#",
				"select" = "template_code"
			}), "template_code"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForPST_Name = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForPST_Name>
<cfquery name="PST_Name" dbtype="query">
						SELECT template_code
						FROM getTemplateCodes
						WHERE template_code_id = #form.Program_Spending_Type#
					</cfquery>
</cfif>
					<cfset SDValue = '#PST_Name.template_code#'>
				</cfif>
				<cfset SettingsToExcel (Setting_Name='Program Spending Type', Setting_Field_Name='Program_Spending_Type', Setting_Value='#SDValue#', page='2')>
		<cfelse>
	<tr><th colspan="3"><hr></th></tr>
	<tr><th colspan="3">Program Spending Types</th></tr>
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
</cfif>

<cfif url.DownloadSettings>
		<cfset SDValue = 'None'>
		<cfif form.Lumpsum_Spending_Type>
			<cfquery name="PST_Name" dbtype="query">
				SELECT template_code
				FROM getTemplateCodes
				WHERE template_code_id = #form.Lumpsum_Spending_Type#
			</cfquery>
			<cfset SDValue = '#PST_Name.template_code#'>
		</cfif>
		<cfset SettingsToExcel (Setting_Name='Lumpsum Spending Type', Setting_Field_Name='Lumpsum_Spending_Type', Setting_Value='#SDValue#', page='2')>
<cfelse>
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
</cfif>
</cfif><!------ Not Distributor Off-Invoice,Bid Request,USDA NOI ----->
<cfif Generic_Type IS "LSAutoPay">
	<input type="hidden" name="Discount_Lump_Sums" value="1">
</cfif>
</cfif> <!--- end :: cfif fromSettings_management neq 1 :: 9 ::Settings Management page 41974--->

	<tr id="Qualifications_heading_2"<cfif url.DownloadSettings> Style="display:none"</cfif>><th colspan="3"><hr><br>Qualifications</th></tr>
		<cfif fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Enable_Program_Qualifications",NameFieldDesc="Display Qualifications")>
			<cfset useLakebaseForqQualifications = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_qualifications")>
<cfif useLakebaseForqQualifications>
	<cftry>
		<cfset qQualifications = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_qualifications", {
				"deleted" = "eq.0",
				"isactive" = "eq.1",
				"order" = "qualification_name.asc",
				"select" = "program_qualification_id,qualification_name,setting_display_value,settingsmanagement_id"
			}), "program_qualification_id,qualification_name,setting_display_value,settingsmanagement_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqQualifications = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqQualifications>
<cfquery name="qQualifications" datasource="#application.datasource#">
				SELECT   Program_Qualification_Id, Qualification_Name, Setting_Display_Value, SettingsManagement_ID
				FROM Program_Qualifications
				WHERE Deleted = 0
				AND IsActive = 1
				ORDER BY Qualification_Name
			</cfquery>
</cfif>
		<cfelseif url.DownloadSettings>
			<cfquery name="qQualifications" datasource="#application.datasource#">
				SELECT  a.Program_Qualification_Id
							, a.Qualification_Name
							, b.Qualification_Template_Mapping_Id
							, b.Answer_Required
							, a.Setting_Display_Value
							, a.SettingsManagement_ID
							, b.Is_Included
				 FROM Program_Qualifications a
				LEFT JOIN Qualification_Template_Mapping b
				ON a.Program_Qualification_Id = b.Program_Qualification_Id
				AND b.Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
				WHERE a.Deleted = 0
				AND a.IsActive = 1
				ORDER BY b.Display_Sequence, a.Qualification_Name
			</cfquery>
			<cfif templateMgmtSettingsSecPage.Enable_Program_Qualifications>
				<cfset SDValue = 'No'>
				<cfif SelectSecondary.Enable_Program_Qualifications eq '1'>
					<cfset SDValue = 'Yes'>
				</cfif>
			<cfset SettingsToExcel (Setting_Name='Display Qualifications', Setting_Field_Name='Enable_Program_Qualifications', Setting_Value='#SDValue#', page='2')>
		</cfif>
		<cfelse>
			<tr class="Qualifications" <cfif templateMgmtSettingsSecPage.Enable_Program_Qualifications EQ 0> style="display:none"</cfif>>
				<td>Display Qualifications</td>
				<td><input type="checkbox" name="Enable_Program_Qualifications" <cfif SelectSecondary.Enable_Program_Qualifications eq '1'>checked=checked</cfif> value="1"/></td>
				<td>&nbsp;</td>
			</tr>
			<cfquery name="qQualifications" datasource="#application.datasource#">
				SELECT  a.Program_Qualification_Id
							, a.Qualification_Name
							, b.Qualification_Template_Mapping_Id
							, b.Answer_Required
							, a.Setting_Display_Value
							, a.SettingsManagement_ID
							, b.Is_Included
				 FROM Program_Qualifications a
				LEFT JOIN Qualification_Template_Mapping b
				ON a.Program_Qualification_Id = b.Program_Qualification_Id
				AND b.Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
				WHERE a.Deleted = 0
				AND a.IsActive = 1
				ORDER BY b.Display_Sequence, a.Qualification_Name
			</cfquery>
		</cfif>

		<cfif fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Program_Qualifications_Doc_Attach_Req",NameFieldDesc="Document Attachment Required")>
		<cfelseif url.DownloadSettings>
			<cfset SettingsToExcel (Setting_Name='Document Attachment Required', Setting_Field_Name='Program_Qualifications_Doc_Attach_Req', page='2')>
		<cfelse>
			<tr class="Qualifications" <cfif templateMgmtSettingsSecPage.Program_Qualifications_Doc_Attach_Req EQ 0> style="display:none"</cfif>>
				<td onClick="ClickToOpenLayer('ProgramQualificationsDocumentMsg','Program_Qualifications_Doc_Attach_Req');">
					<cfif SelectSecondary.Program_Qualifications_Doc_Msg neq "">
						<a style="text-decoration:underline">Document Attachment Required</a>
					<cfelse>
						Document Attachment Required
					</cfif>
				</td>
				<td colspan="2">
					<input type="checkbox" name="Program_Qualifications_Doc_Attach_Req"
						<cfif templateMgmtSettingsSecPage.Program_Qualifications_Doc_Message>
							onClick="ClickToOpenLayer('ProgramQualificationsDocumentMsg','Program_Qualifications_Doc_Attach_Req');"
						</cfif>
						<cfif SelectSecondary.Program_Qualifications_Doc_Attach_Req eq '1'>checked=checked</cfif> value="1">
				</td>
			</tr>
		</cfif>

		<cfif fromSettings_management eq 1>
			<cfset SettingsTemplateForm(NameField="Program_Qualifications_Doc_Message",NameFieldDesc="Document Message")>
		<cfelseif url.DownloadSettings>
			<cfset SettingsToExcel (Setting_Name='Document Message', Setting_Field_Name='Program_Qualifications_Doc_Msg', Setting_Value='#SelectSecondary.Program_Qualifications_Doc_Msg#', page='2')>
		<cfelse>
			<tr class="Qualifications" style="display:none;" id="ProgramQualificationsDocumentMsg">
				<td colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:red">Document Message</span>
				<br />
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<textarea name="Program_Qualifications_Doc_Msg" rows="4" cols="40" onPaste="javaScript: return textareaChecklength(75, this);"  onkeyPress="javaScript: return textareaChecklength(75, this);">
						#SelectSecondary.Program_Qualifications_Doc_Msg#
					</textarea>
				</td>
			</tr>
		</cfif>

		<cfif qQualifications.recordCount>
			<cfquery dbtype="query" name="qmgmtSettingPrgQualifications">
				SELECT Setting_Display_Value
				  FROM qQualifications
				 WHERE Setting_Display_Value = 1
			</cfquery>
			<tr>
				<td colspan="3">
					<cfif fromSettings_management neq 1 AND url.DownloadSettings EQ 0>
						<p style="margin:15px 0;" class="headingTip"><img src="/images/ico-info.gif" style="position:relative;top:2px;"> Click & drag qualifications using the mouse to place them in a desired sequence on proram qualifications page</p>
					</cfif>
					<table>
						<tr id="Qualifications_heading_3"<cfif (fromSettings_management eq 1 or qmgmtSettingPrgQualifications.recordcount eq 0) OR url.DownloadSettings>  style="display:none"</cfif>>
							<td colspan="2" class="sh42" align="left">Qualification</td>
							<td class="sh42">Include</td>
							<td class="sh42">Ans Req'd</td>
						</tr>
						<tbody class="sortable">
							<cfset MgmtSettingsSecPageInProgQ = CreateObject("component", "components.settings.settings_management.TemplateSettingsManager").getMgmtSettingsValInTBL(Generic_Type,ID,"Program_Qualifications","SettingsManagement_ID")>
							<input type="hidden" name="qualification_row_ids" value="#valueList(qQualifications.Program_Qualification_Id)#">
							<cfloop query="qQualifications">
								<cfif fromSettings_management eq 1>
									<tr>
										<td width="5px">&nbsp;</td>
										<td align="left" valign="top">#qQualifications.Qualification_Name#</td>
										<td align="left" valign="top" nowrap="nowrap" style="padding-left:10px;">
											<input type="radio" name="Program_Qualifications_#SettingsManagement_ID#" value="1" id="Program_Qualifications_#SettingsManagement_ID#_1" <cfif qQualifications.Setting_Display_Value EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
											<input type="radio" name="Program_Qualifications_#SettingsManagement_ID#" value="0" id="Program_Qualifications_#SettingsManagement_ID#_0" <cfif qQualifications.Setting_Display_Value EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
										</td>
										<cfset SettingsTemplateForm(NameField="Program_Qualifications_#SettingsManagement_ID#",NameFieldDesc="#qQualifications.Qualification_Name#",SettingDisplayValueInTable="Program_Qualifications",SettingDisplayValueInTableID="#SettingsManagement_ID#")>
									</tr>
								<cfelseif url.DownloadSettings>
									<cfif MgmtSettingsSecPageInProgQ[#SettingsManagement_ID#]>
										<cfset SDValue = 'No'>
										<cfset SDefault = 'No'>

										<cfset variables.includeQualification = ( val(qQualifications.is_included) gt 0 )>
										<cfif variables.includeQualification IS '1'>
											<cfset SDValue = 'Yes'>
										</cfif>
										<cfif qQualifications.Answer_Required IS '1'>
											<cfset SDefault = 'Yes'>
										</cfif>

											<cfset SettingsToExcel (Setting_Name='#qQualifications.Qualification_Name#', Setting_Field_Name='qualification_display_sequence_#qQualifications.currentRow#', Setting_Value='#SDValue#', Is_Child_Of='', SetAsDefault='#SDefault#', page='2')>
									</cfif>
								<cfelse>
									<tr class="Qualifications" <cfif MgmtSettingsSecPageInProgQ[#SettingsManagement_ID#] EQ 0> style="display:none"</cfif>>
										<td width="5px">
											<span class="ui-displayRow ui-icon ui-icon-arrowthick-2-n-s"></span>
										</td>
											<td valign="top">#qQualifications.Qualification_Name#
											<!---internal hidden input to keep track of sequence to save in db, value gets updated right after clicking on save--->
											<input type="hidden" name="qualification_display_sequence_#qQualifications.currentRow#" class="seq">
										</td>
										<cfset variables.includeQualification = ( val(qQualifications.is_included) gt 0 )>
										<td valign="middle"><input type="checkbox" name="qualification_is_included_#qQualifications.currentRow#" class="is_included" data-row-number="#qQualifications.currentRow#" <cfif variables.includeQualification> checked=checked </cfif>></td>
										<td valign="middle"><input type="checkbox" name="qualification_answer_required_#qQualifications.currentRow#" <cfif not variables.includeQualification> disabled=disabled <cfelseif qQualifications.Answer_Required eq 1> checked=checked </cfif>></td>
									</tr>
								</cfif>
							</cfloop>
						</tbody>
					</table>
				</td>
			</tr>
		</cfif>

<cfif fromSettings_management neq 1> <!--- start :: cfif fromSettings_management neq 1 :: 11 ::Settings Management page 41974--->
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
			<cfif url.DownloadSettings>
					<cfset SettingsToExcel (Setting_Name='Default Product', Setting_Field_Name='Default_Product_Name', Setting_Value='#DefaultProductName#', SetAsDefault='#SDefault#', page='2')>
			<cfelse>
				<input type="hidden" name="ExistingProductList" value="">
				<INPUT TYPE="Hidden" NAME="Product_List" 		VALUE="">

			  <tr><th colspan="3"><hr></th></tr>
				<tr><th colspan="3">Default Product</th></tr>
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
			</cfif>
			
	
<cfif SelectSecondary.Retail_Planner NEQ "1">
	<cfparam name="FormStatus" default="">
	
	<cfif LockedBy_Current_User NEQ 1>
		<cfset FormStatus = "disabled">
	</cfif>

	<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
	<cfset template = templateManager.get(url.id)>
	<cfset plannerSettingsManager = CreateObject("component", "mvc.Models.Planner.PlannerSettingsManager") />
	
	<cfset qGetPlannerPerfTypes = plannerSettingsManager.getPerfTypeInfo(type="Active") />
	
	<cfset qGetExistingPerfTypes = templateManager.getPlannerProgramTemplatePerfTypes(template.getFirstParentID()) />
	<cfset lPlannerPerfTypes = valueList(qGetExistingPerfTypes.Planner_Perf_Types_ID) />
	
	<cfquery  dbtype="query" name="qGetPlannerPerfTypesSorted">
		SELECT * FROM qGetPlannerPerfTypes order by Description 
	</cfquery>

	<tr><th colspan="3"><hr></th></tr>
	<tr><th colspan="3">Performance Types</th></tr>	
		<cfloop query="qGetPlannerPerfTypesSorted">
			<tr>
				<td>#Description#</td>
				<td>
					<INPUT TYPE="checkbox" NAME="Planner_Perf_Types_ID" VALUE="#Planner_Perf_Types_ID#" <cfif listFind(lPlannerPerfTypes, Planner_Perf_Types_ID)>checked</cfif> #FormStatus#>
				</td>
				<td>&nbsp;</td>
			</tr>
		</cfloop>
</cfif>	
	
<!--- 17677 testing confused [begin] --->
<cfif SelectSecondary.BidRequestStatusOn IS 1>
	<cfif url.DownloadSettings EQ 0>
	  <tr><th colspan="3"><hr></th></tr>
		<tr><th colspan="3">Line Item options</th></tr>
		<tr><td colspan="3">If you do not make a selection, both options will be available</td></tr>
		<tr>
				<td>&nbsp; </td>
				<td class="sh42"><br><b>Available</b></td>
				<td class="sh42"><br><b>Default</b></td>
		</tr>
	</cfif>
	<cfif url.DownloadSettings>
		<cfset SDValue = 'No'>
		<cfset SDefault ='No'>

		<cfif SelectSecondary.Bid_Line_Item_Option IS 1 OR SelectSecondary.Bid_Line_Item_Option IS 3>
			<cfset SDValue = 'Yes'>
		</cfif>
		<cfif SelectSecondary.Bid_Line_Item_Option_Default IS 1>
			<cfset SDefault ='Yes'>
		</cfif>
		<cfset SettingsToExcel (Setting_Name='Line Item On', Setting_Field_Name='Line_Item_On', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', page='2')>
	<cfelse>
		<tr>
			<td><input type="checkbox" name="Line_Item_On" value="1" <cfif SelectSecondary.Bid_Line_Item_Option IS 1 OR SelectSecondary.Bid_Line_Item_Option IS 3>checked</cfif>></td>
			<td>Line Item On</td>
			<td><input type="radio" name="Bid_Line_Item_Option_Default" value="1" checked></td>
		</tr>
	</cfif>

	<cfif url.DownloadSettings>
		<cfset SDValue = 'No'>
		<cfset SDefault ='No'>

		<cfif SelectSecondary.Bid_Line_Item_Option IS 2 OR SelectSecondary.Bid_Line_Item_Option IS 3>
			<cfset SDValue = 'Yes'>
		</cfif>
		<cfif SelectSecondary.Bid_Line_Item_Option_Default IS 2>
			<cfset SDefault ='Yes'>
		</cfif>
		<cfset SettingsToExcel (Setting_Name='Line Item Off', Setting_Field_Name='Line_Item_On', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', page='2')>
	<cfelse>
		<tr>
			<td><input type="checkbox" name="Line_Item_On" value="2" <cfif SelectSecondary.Bid_Line_Item_Option IS 2 OR SelectSecondary.Bid_Line_Item_Option IS 3>checked</cfif>></td>
			<td >Line Item Off</td>
			<td><input type="radio" name="Bid_Line_Item_Option_Default" value="2" <cfif SelectSecondary.Bid_Line_Item_Option_Default IS 2>checked</cfif>></td>
		</tr>
	</cfif>
</cfif>
				<!--- 17677 testing confused [end] --->

				</table>
                <!--- ...........................................................................
				............................ Right Inner Table [end] ............................
				............................................................................ --->
			</td>
		</tr>
	</table>
</form>
<!--- .......................................................................
............................ Outer Table [end] ..............................
........................................................................ --->

<cfif LockedBy_Current_User EQ 1>
	<div style="text-align:center;margin-top:20px;">
		<a href="javaScript:confirmCompletion();">#application.util.string.actionLinkFormat2("save and continue")#</a>
	</div>
</cfif>

<form action="summary.cfm?ID=#ID#" method="post" name="Abandon">
	<input type="hidden" name="Garbage" value="0">
</form>


<!--- </div> --->
</cfif> <!--- end :: cfif fromSettings_management neq 1 :: 12 ::Settings Management page 41974--->
</cfoutput>
<cfif fromSettings_management neq 1> <!--- start :: cfif fromSettings_management neq 1 :: 10 ::Settings Management page 41974--->
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
		$('input.is_included').change(function() {
	  		// disable answer required checkbox when qualification is not included
			$("input[name=qualification_answer_required_" + $(this).attr("data-row-number") + "]").prop("disabled", !$(this).prop("checked"));
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
if ( $('.Label_Set:visible').length == 0 ) {
  $('#Label_Set_heading').hide();
}
if ( $('.Currency:visible').length == 0 ) {
  $('#Currency_heading').hide();
}
if ( $('.UOM:visible').length == 0 ) {
  $('#UOM_heading').hide();
}

$("tbody.sortable").sortable();

function IdealPrice() {
	NewWindow("Ideal_Price_Template_List.cfm?First_Parent_ID=<cfoutput>#SelectSecondary.First_Parent_ID#</cfoutput>", "IdealPriceTemplateList", 800, 400, "yes", "yes");
}

$("#Discount_Fixed_Prices").click(function () {
    if($(this).prop('checked')){
			$("#Ideal_Price").removeAttr("disabled")
		}else{
			$("#Ideal_Price").prop('checked', false);
			$("#tmpListLink").hide();
			$("#Ideal_Price").attr('disabled','disabled');
		}
	});

$("#Ideal_Price").click(function () {
    if($(this).prop('checked')){
			$('#tmpListLink').show();
		}else{
			$('#tmpListLink').hide();
		}
});

</script>

<cfinclude template="/common_files/focus.cfm">
</body>
</html>
</cfif><!--- end :: cfif fromSettings_management neq 1 :: 10 ::Settings Management page 41974--->