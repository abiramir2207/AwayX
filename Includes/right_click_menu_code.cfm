<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Right click menu code																			 --->
<!--- Unused links that we used at one time are found at the bottom of the page. Frank				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfset SPA = CreateObject("component","components.user.settingsPanelAccess").init() />
<cfset IsSPAccessAllowed = SPA.getCheckSPAccessAllowed()>

<cfoutput><link href="/common_files/scripts/css.css?v=#application.util.dateTime.fileVersion('/common_files/scripts/css.css')#" rel=stylesheet type=text/css></cfoutput>
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

	<CFIF Get_Profile_Settings.Report_Scheduler EQ 1>
		<CFSET Report_Scheduler="<DIV class=menuitems url='/ReportWriter/index.cfm'><IMG class=menuitems src='/images/rc_menu/reports_icon.gif' ALIGN='absbottom'>&nbsp;Reports</DIV>">
	<CFELSE>
		<CFSET Report_Scheduler="">
	</CFIF>

	<CFIF IsSPAccessAllowed EQ 1>
		<CFSET Settings_Panel="<DIV class=menuitems url='/settings/index2.cfm'><IMG class=menuitems src='/images/rc_menu/settings_icon.gif' ALIGN='absbottom'>&nbsp;Settings</DIV>">
	<CFELSE>
		<CFSET Settings_Panel="">
	</CFIF>

	<CFIF Get_Profile_Settings.PM_Access EQ 1>
		<CFSET PDA="<DIV class=menuitems url='/ReportWriter/PM/index.cfm'><IMG class=menuitems src='/images/rc_menu/pda_icon.gif' ALIGN='absbottom'>&nbsp;Projects</DIV>">
	<CFELSE>
		<CFSET PDA="">
	</CFIF>

	<cfscript>
		Billbacks = "<DIV class=menuitems url='/billbacks/scorecard/billback_Search.cfm'><IMG class=menuitems SRC='/images/rc_menu/payables_icon.gif' ALIGN='absbottom' ALT='' BORDER='0'>&nbsp;Billback Search</DIV>";
		Back      = "<DIV class=menuitems url='javascript:history.back(1)'><IMG onClick='javascript:history.back(1);' class=menuitems src='/images/rc_menu/back_icon.gif' ALIGN='absmiddle'>&nbsp;Back</DIV>";
		Forward   = "<DIV class=menuitems url='javascript:history.forward()'><IMG onClick='javascript:history.forward();' class=menuitems src='/images/rc_menu/forward_icon.gif' ALIGN='absmiddle'>&nbsp;Forward</DIV>";
		Refresh   = "<DIV class=menuitems url='javascript:window.location.reload()'><IMG onClick='javascript:window.location.reload();' class=menuitems src='/images/rc_menu/reload.gif' ALIGN='absmiddle'>&nbsp;Refresh</DIV>";
		Home      = "<DIV class=menuitems url='/Manufacturers/home.cfm'><IMG  class=menuitems src='/images/rc_menu/home_icon.gif' ALIGN='absbottom'>&nbsp;Home</DIV></NOBR>";
		Logoff    = "<DIV class=menuitems url='/logoff.cfm?id=#request.AccessStructure.User_ID#'><IMG class=menuitems src='/images/rc_menu/logoff_icon.gif' ALIGN='absbottom'>&nbsp;Logoff</DIV>";

		Programs  = "<DIV class=menuitems url='/common_files/select_new_program_type.cfm'><IMG class=menuitems SRC='/images/rc_menu/contracts_icon.gif' ALIGN='absbottom' ALT='' BORDER='0'>&nbsp;Programs</DIV>";
		Profiles  = "<DIV class=menuitems url='/common_files/admin.cfm'><IMG class=menuitems SRC='/images/rc_menu/profiles_icon.gif' ALT='' BORDER='0' ALIGN='absbottom'>&nbsp;Profiles</DIV>";

		AddToDo   = "<DIV class=menuitems url='/settings/index.cfm' ONMOUSEOVER='doNotRelocate=1;' ONMOUSEOUT='doNotRelocate=0;' ONCLICK='addToDoList()'><IMG onClick='addToDoList();' class=menuitems src='/images/knob/knobadd.png' width=16 height=16 ALIGN='absmiddle'>&nbsp;Add ToDo</DIV>";
		ViewToDo  = "<DIV class=menuitems url='/settings/index2.cfm' ONMOUSEOVER='doNotRelocate=1;' ONMOUSEOUT='doNotRelocate=0;' ONCLICK='viewToDoList()'><IMG onClick='viewToDoList();' class=menuitems src='/images/view.gif' width=16 height=16 ALIGN='absmiddle'>&nbsp;View ToDo</DIV>";
		View_Program = "<DIV class=menuitems url='/common_files/contracts/contract_edit_menu.cfm'>&nbsp;View Program</DIV>";

		Basic_Info = "<DIV class=menuitems url='/common_files/contracts/contract_create_1_form.cfm'>&nbsp;Basic Info</DIV>";
		Operators  = "<DIV class=menuitems url='/common_files/contracts/select_operators.cfm'>&nbsp;#application.returned_customer_setting.operator_label_plural#</DIV>";
		Brokers    = "<DIV class=menuitems url='/common_files/contracts/select_brokers.cfm'>&nbsp;Brokers</DIV>";
		Distributors = "<DIV class=menuitems url='/common_files/contracts/select_distributors.cfm'>&nbsp;#application.returned_customer_setting.distributor_label_plural#</DIV>";
		Products     = "<DIV class=menuitems url='/common_files/contracts/select_products.cfm'>&nbsp;Products</DIV>";
		Rates        = "<DIV class=menuitems url='/common_files/contracts/contract_products_rebate_entry.cfm'>&nbsp;Rates</DIV>";

		Distributor_Group_Summary   = "<DIV class=menuitems url='' ONCLICK=""profilePopup('distributorgroup')"">&nbsp;Group Summary</DIV>";
		Distributor_Program_Summary ="<DIV class=menuitems url='' ONCLICK=""profilePopup('distributorprogram')"">&nbsp;Program Summary</DIV>";

		Broker_Summary = "<DIV class=menuitems url='' ONCLICK=""profilePopup('broker')"">&nbsp;Broker Summary</DIV>";

		Operator_Group_Summary   = "<DIV class=menuitems url='' ONCLICK=""profilePopup('operatorgroup')"">&nbsp;Group Summary</DIV>";      // <!--- D31561: Operator Groups Search --->
		Operator_Program_Summary = "<DIV class=menuitems url='' ONCLICK=""profilePopup('operatorprogram')"">&nbsp;Program Summary</DIV>";  // <!--- D31561: Operator Groups Search --->
		Operator_Summary         = "<DIV class=menuitems url='' ONCLICK=""profilePopup('operator')"">&nbsp;#application.returned_customer_setting.operator_label_singular# Summary</DIV>";
		Product_Summary          = "<DIV class=menuitems url='' ONMOUSEOVER='doNotRelocate=1' ONMOUSEOUT='doNotRelocate=0' ONCLICK=""profilePopup('product')"">&nbsp;Product Summary</DIV>";
		Price_List               = "<DIV class=menuitems onclick=""pricelistPopup()"" ONMOUSEOVER='doNotRelocate=1' ONMOUSEOUT='doNotRelocate=0'>&nbsp;Price List</DIV>";
		Billback_Summary         = "<DIV class=menuitems onmouseover='doNotRelocate=1;' onclick=""profilePopup('payable')"">Billback Summary</DIV>";
		Invoice_Summary          = "<DIV class=menuitems onmouseover='doNotRelocate=1;' onclick=""profilePopup('invoice')"">Invoice Summary</DIV>";
		OSD_Summary              = "<DIV class=menuitems onmouseover='doNotRelocate=1;' onclick=""profilePopup('osd')"">OSD Summary</DIV>";
		Deduction_Summary        = "<DIV class=menuitems onmouseover='doNotRelocate=1;' onclick=""profilePopup('deduction')"">Deduction Summary</DIV>";
 		Program_Group_Summary    = "<DIV class=menuitems onmouseover='doNotRelocate=1;' onclick=""profilePopup('programGroupItem')"">Program Group Items</DIV>";
		Group_Summary            = "<DIV class=menuitems onmouseover='doNotRelocate=1;' onclick=""profilePopup('groupItem')"">Current Group Items</DIV>";
		Lumpsum_Distributor_Summary = "<DIV class=menuitems onmouseover='doNotRelocate=1;' onclick=""profilePopup('lumpsumDistributor')"">#Application.LumpsumLabel# #application.returned_customer_setting.distributor_label_plural#</DIV>";
		Lumpsum_Product_Summary     = "<DIV class=menuitems onmouseover='doNotRelocate=1;' onclick=""profilePopup('lumpsumProduct')"">#Application.LumpsumLabel# products</DIV>";

		variables.copy              = "<DIV class=menuitems onmouseover='doNotRelocate=1;' onclick=""copyToClipboard();""><IMG onClick='copyToClipboard();' class=menuitems src='/images/copy.png' ALIGN='absmiddle'>&nbsp;Copy</DIV>";
		variables.paste             = "<DIV class=menuitems onmouseover='doNotRelocate=1;' onclick='pasteFromClipboard();'><IMG onClick='pasteFromClipboard();' class=menuitems src='/images/paste.png' ALIGN='absmiddle' width=16>&nbsp;Paste</DIV>";
	</cfscript>

	<DIV CLASS="skin1" ID="ie5menu_0" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5();return false;" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">
		<CFOUTPUT>#Back# #Forward# #Refresh# #variables.Copy# #variables.Paste#</CFOUTPUT>
		<!---<HR color="silver" width="125" SIZE="1">--->
		<!---<CFIF Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 1>
		<CFOUTPUT>#Programs#</CFOUTPUT>
		</CFIF>--->
		<!--- <CFOUTPUT>#Profiles#</CFOUTPUT> --->
		<!--- <CFOUTPUT>#Report_Scheduler#</CFOUTPUT> --->
		<!---<CFIF application.returned_customer_setting.show_billback EQ 1>
		<CFOUTPUT>#Billbacks#</CFOUTPUT>
		</CFIF>
		<CFOUTPUT>#PDA#</CFOUTPUT>--->
		<!---<CFOUTPUT>#Settings_Panel#</CFOUTPUT>--->
		<!--- <HR color="silver" width="125" SIZE="1"> --->
		<hr style="color:rgb(235, 235, 235);width:100%;margin:3px 0;">
		<CFOUTPUT>#AddToDo# #ViewToDo#</CFOUTPUT>
		<!---<HR color="silver" width="125" SIZE="1">--->
		<!--- <CFOUTPUT>#Home#</CFOUTPUT> --->
		<!--- <CFOUTPUT>#Logoff#</CFOUTPUT> --->
	</DIV>

	<!--- Programs Menu --->
	<DIV CLASS="skin1" ID="ie5menu_2" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">
		<CFOUTPUT>#View_Program#</CFOUTPUT>
		<CFOUTPUT>#Basic_Info#</CFOUTPUT>
		<CFOUTPUT>#Operators#</CFOUTPUT>
		<CFOUTPUT>#Brokers#</CFOUTPUT>
		<CFOUTPUT>#Distributors#</CFOUTPUT>
		<CFOUTPUT>#Products#</CFOUTPUT>
		<CFOUTPUT>#Rates#</CFOUTPUT>
		<!---<HR color="silver" width="125" SIZE="1">
		<CFOUTPUT>#Home#</CFOUTPUT>
		<CFOUTPUT>#Logoff#</CFOUTPUT>--->
	</DIV>

	<!--- Distributor Menu --->
	<DIV CLASS="skin1" ID="ie5menu_3" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">
		<CFOUTPUT>#Distributor_Group_Summary#</CFOUTPUT>
		<CFOUTPUT>#Distributor_Program_Summary#</CFOUTPUT>
		<!---<HR color="silver" width="125" SIZE="1">
		<CFOUTPUT>#Home#</CFOUTPUT>
		<CFOUTPUT>#Logoff#</CFOUTPUT>--->
	</DIV>

	<!--- Broker Menu --->
	<DIV CLASS="skin1" ID="ie5menu_4" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">
		<CFOUTPUT>#Broker_Summary#</CFOUTPUT>
		<!---<HR color="silver" width="125" SIZE="1">
		<CFOUTPUT>#Home#</CFOUTPUT>
		<CFOUTPUT>#Logoff#</CFOUTPUT>--->
	</DIV>

	<!--- Operator Menu --->

<!--- D31561: Operator Groups Search START--->
	<DIV CLASS="skin1" ID="ie5menu_5" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">
		<CFOUTPUT>#Operator_Summary#</CFOUTPUT>
		<!---<HR color="silver" width="125" SIZE="1">
		<CFOUTPUT>#Home#</CFOUTPUT>
		<CFOUTPUT>#Logoff#</CFOUTPUT>--->
	</DIV>

	<DIV CLASS="skin1" ID="ie5menu_13" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">
		<CFOUTPUT>#Operator_Group_Summary#</CFOUTPUT>
		<CFOUTPUT>#Operator_Program_Summary#</CFOUTPUT>
	</DIV>
<!--- D31561: Operator Groups Search END--->

	<!--- Product Menu --->
	<DIV CLASS="skin1" ID="ie5menu_6" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">
		<CFOUTPUT>#Product_Summary#</CFOUTPUT>
		<cfif appSettings.getPriceListdisplayedRightClick() GT 0>
			<CFOUTPUT>#Price_List#</CFOUTPUT>
		</cfif>
		<!---<HR color="silver" width="125" SIZE="1">
		<CFOUTPUT>#Home#</CFOUTPUT>
		<CFOUTPUT>#Logoff#</CFOUTPUT>--->
	</DIV>

	<!---Watered Down Payable Menu --->
	<DIV CLASS="skin1" ID="ie5menu_7" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">
		<CFOUTPUT>#Billback_Summary#</CFOUTPUT>
		<!---<HR color="silver" width="125" SIZE="1">
		<CFOUTPUT>#Home#</CFOUTPUT>
		<CFOUTPUT>#Logoff#</CFOUTPUT>--->
	</DIV>

	<!---INVOICE Menu --->
	<DIV CLASS="skin1" ID="ie5menu_8" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">
		<CFOUTPUT>#Invoice_Summary#</CFOUTPUT>
		<!---<HR color="silver" width="125" SIZE="1">
		<CFOUTPUT>#Home#</CFOUTPUT>
		<CFOUTPUT>#Logoff#</CFOUTPUT>--->
	</DIV>

	<!---OSD Menu --->
	<DIV CLASS="skin1" ID="ie5menu_9" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">
		<CFOUTPUT>#OSD_Summary#</CFOUTPUT>
		<!---<HR color="silver" width="125" SIZE="1">
		<CFOUTPUT>#Home#</CFOUTPUT>
		<CFOUTPUT>#Logoff#</CFOUTPUT>--->
	</DIV>

	<!---OSD Menu --->
	<DIV CLASS="skin1" ID="ie5menu_10" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">
		<CFOUTPUT>#Deduction_Summary#</CFOUTPUT>
		<!---<HR color="silver" width="125" SIZE="1">
		<CFOUTPUT>#Home#</CFOUTPUT>
		<CFOUTPUT>#Logoff#</CFOUTPUT>--->
	</DIV>

	<!--- Group Menu --->
	<DIV CLASS="skin1" ID="ie5menu_11" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">
		<CFOUTPUT>#Program_Group_Summary#</CFOUTPUT>
		<CFOUTPUT>#Group_Summary#</CFOUTPUT>
		<cfif appSettings.getPriceListdisplayedRightClick() EQ 2>
			<CFOUTPUT>#Price_List#</CFOUTPUT>
		</cfif>
		<!---<<HR color="silver" width="125" SIZE="1">
		CFOUTPUT>#Home#</CFOUTPUT>
		<CFOUTPUT>#Logoff#</CFOUTPUT>--->
	</DIV>

	<!--- LumpSum Menu --->
	<DIV CLASS="skin1" ID="ie5menu_12" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">
		<CFOUTPUT>#Lumpsum_Distributor_Summary#</CFOUTPUT>
		<CFOUTPUT>#Lumpsum_Product_Summary#</CFOUTPUT>
		<!---<HR color="silver" width="125" SIZE="1">
		<CFOUTPUT>#Home#</CFOUTPUT>
		<CFOUTPUT>#Logoff#</CFOUTPUT>--->
	</DIV>



<script>
function profilePopup(PopupLocation){
	switch (PopupLocation) {

		//distributor
		case "distributorgroup":
			//alert()
			NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=' + internal_ID,'Distributor_profile','400','450','Yes', 'No')
		break;

		case "distributorprogram":
			//alert()
			NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=' + internal_ID+ '&showProgramItems=1','Distributor_profile','400','450','Yes', 'No')
		break;

		case "broker":
			NewWindow('/profiles/Brokers/Broker_profile.cfm?BID=' + internal_ID,'Broker_profile','400','450','Yes', 'No')
		break;

		case "operator":
			NewWindow('/profiles/Operators/Operator_profile.cfm?OID=' + internal_ID,'Operator_profile','400','450','Yes', 'No')
		break;
//dinesh
		case "operatorgroup":
			//alert();
			NewWindow('/profiles/Operators/Operator_profile.cfm?OID=' + internal_ID,'Operator_profile','400','450','Yes', 'No')
		break;
		case "operatorprogram":
			//alert()
			NewWindow('/profiles/Operators/Operator_profile.cfm?OID=' + internal_ID+ '&showProgramItems=1','Operator_profile','400','450','Yes', 'No')
		break;
//dinesh
		case "product":
			NewWindow('/profiles/Products/Product_profile.cfm?PID=' + internal_ID,'Product_profile','400','550','Yes', 'No')
		break;

		case "payable":
			NewWindow('/profiles/Payables/Payable_Summary.cfm?PID=' + internal_ID,'Payable_Summary','400','450','Yes', 'No')
		break;

		case "invoice":
			NewWindow('/profiles/Invoices/Invoice_Summary.cfm?IID=' + internal_ID,'Invoice_Summary','400','450','Yes', 'No')
		break;

		case "osd":
			NewWindow('/profiles/OSD/osd_Summary.cfm?OID=' + internal_ID,'osd_Summary','400','450','Yes', 'No')
		break;

		case "deduction":
			NewWindow('/common_files/deductions/deduction_Summary_popup.cfm?DID=' + internal_ID,'deduction_Summary_popup','400','450','Yes', 'No')
		break;

		//group deal items for that program
		case "programGroupItem":
			NewWindow('/Common_Files/contracts/Groups/group_items.cfm?Group_ID=' + internal_ID + '&showProgramItems=1','group_items','800','450','Yes', 'No');
		break;

		//group deals
		case "groupItem":
			//alert()
			NewWindow('/Common_Files/contracts/Groups/group_items.cfm?Group_ID=' + internal_ID,'group_items','800','450','Yes', 'No')
		break;

		//lumpsum Distributor
		case "lumpsumDistributor":
			NewWindow('/Common_Files/Contracts/lumpsum_distributors_display.cfm?LUMP_ID=' + internal_ID,'lumpsum_distributors_display','800','450','Yes', 'No')
		break;

		//lumpsum Distributor
		case "lumpsumProduct":
			NewWindow('/Common_Files/Contracts/lumpsum_products.cfm?LUMP_ID=' + internal_ID,'lumpsum_products_display','800','450','Yes', 'No')
		break;

	}
}

//price list popup
function pricelistPopup(product_upc)
{
	NewWindow('/common_files/Products/pricelist_display.cfm?upc=' + internal_ID,'name','670','500','Yes', 'No')
}

/********************************************************
** D50886 - global variables prefixed with '_", they are
** for copying to clipboard and pasting from clipboard
********************************************************/
_active_Element = null;
_selected_Text 	= null;

if (document.all.length && window.print) {
	document.oncontextmenu = showmenuie5;
	document.body.onclick  = hidemenuie5;
}

/********************************************************
** D50886 - takes data on clipboard & place it inside
** the active (focused) element
********************************************************/
function pasteFromClipboard() {
	if ( window.clipboardData ) {
		var text = window.clipboardData.getData('text');
		_active_Element.value = text;
		if (0 && console) { console.log("\n\n\n\n\n\n\n", text); }
	}
}

/********************************************************
** D50886 - takes selected data and save it in clipboard
********************************************************/
function copyToClipboard() {
	if ( window.clipboardData ) {
		window.clipboardData.setData('Text', _selected_Text);
		if (0 && console) { console.log("\n\n\n\n\n\n\n", _selected_Text); }
	}
}
</script>