<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- right click menu code																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<LINK href="/common_files/scripts/css.css" rel=stylesheet type=text/css>






<!--[if IE]>

	<DIV CLASS="skin1" ID="ie5menu_0" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">
		<DIV class=menuitems url="javascript:history.back(1)"><IMG src="/images/rc_menu/back_icon.gif" ALIGN="absmiddle">&nbsp;Back</DIV>
		<DIV class=menuitems url="javascript:history.forward()"><IMG src="/images/rc_menu/forward_icon.gif" ALIGN="absmiddle">&nbsp;Forward</DIV>

		<HR color="silver" width="125" SIZE="1">
		
		<DIV class=menuitems url="/common_files/contracts/index.cfm"><IMG SRC="/images/rc_menu/contracts_icon.gif" ALIGN="absbottom" ALT="" BORDER="0">&nbsp;Contracts</DIV>
<!--- 		<DIV class=menuitems url="/common_files/payables2/index.cfm"><IMG src="/images/rc_menu/payables_icon.gif" ALIGN="absbottom">&nbsp;Payables</DIV>
 --->		<DIV class=menuitems url="/common_files/admin.cfm"><IMG SRC="/images/rc_menu/profiles_icon.gif" ALT="" BORDER="0" ALIGN="absbottom">&nbsp;Profiles</DIV>

		<CFIF Get_Profile_Settings.Report_Scheduler EQ 1>
			<DIV class=menuitems url="/reports/index.cfm"><IMG src="/images/rc_menu/reports_icon.gif" ALIGN="absbottom">&nbsp;Reports</DIV>
		</CFIF>





		<!--- <DIV class=menuitems url="/reports/index.cfm"><IMG src="/images/rc_menu/reports_icon.gif" ALIGN="absbottom">&nbsp;Reports</DIV> --->



		<DIV class=menuitems url="/pda_stuff/index.cfm"><IMG src="/images/rc_menu/pda_icon.gif" ALIGN="absbottom">&nbsp;PDA</DIV>
		<DIV class=menuitems url="/settings/index.cfm"><IMG src="/images/rc_menu/settings_icon.gif" ALIGN="absbottom">&nbsp;Settings</DIV>
<!--- 		<DIV class=menuitems url="/common_files/deductions/index.cfm"><IMG src="/images/rc_menu/payables_icon.gif" ALIGN="absbottom">&nbsp;Deductions</DIV>
 --->

		<HR color="silver" width="125" SIZE="1">

		<DIV class=menuitems url="/settings/index.cfm" ONMOUSEOVER="doNotRelocate=1;" ONMOUSEOUT="doNotRelocate=0;" ONCLICK="addToDoList()">&nbsp;Add ToDo</DIV>
		<DIV class=menuitems url="/settings/index2.cfm" ONMOUSEOVER="doNotRelocate=1;" ONMOUSEOUT="doNotRelocate=0;" ONCLICK="viewToDoList()">&nbsp;View ToDo</DIV>
		<HR color="silver" width="125" SIZE="1">
		
		<DIV class=menuitems url="/Manufacturers/home.cfm"><IMG src="/images/rc_menu/home_icon.gif" ALIGN="absbottom">&nbsp;Home</DIV></NOBR>
		
		<!--- <HR color=teal width=125> --->
<!--- 		<DIV class=menuitems url=""><IMG src="/images/rc_menu/logoff_icon.gif" ALIGN="absbottom" onclick="history.go(0)">&nbsp;Refresh</DIV> --->
		<DIV class=menuitems url="/logoff.cfm?id=<CFOUTPUT>#createuuid()#</CFOUTPUT>"><IMG src="/images/rc_menu/logoff_icon.gif" ALIGN="absbottom">&nbsp;Logoff</DIV>
	</DIV>

	<!--- Payable Menu --->
	<DIV CLASS="skin1" ID="ie5menu_1" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">

		<DIV class=menuitems url="/common_files/payables2/payable_edit_menu.cfm">&nbsp;View Payable</DIV>
		<DIV class=menuitems url="/common_files/payables2/payable_create_1_form.cfm">&nbsp;Basic Info</DIV>
		<DIV class=menuitems url="/common_files/payables2/select_distributors.cfm">&nbsp;Distributors</DIV>
		<DIV class=menuitems url="/common_files/payables2/select_payable_contracts.cfm">&nbsp;Contracts</DIV>
		<DIV class=menuitems url="/common_files/payables2/payables_product_select.cfm">&nbsp;Products</DIV>
		<DIV class=menuitems url="/common_files/payables2/payables_product_amount_entry.cfm">&nbsp;Billbacks</DIV>
		<DIV class=menuitems url="/common_files/payables2/product_approval_form.cfm">&nbsp;Authorize</DIV>
		<DIV class=menuitems url="/common_files/payables2/payable_payment_entry.cfm">&nbsp;Payment</DIV>
		
		<HR color="silver" width="125" SIZE="1">
		
		<DIV class=menuitems url="/Manufacturers/home.cfm"><IMG src="/images/rc_menu/home_icon.gif" ALIGN="absbottom">&nbsp;Home</DIV></NOBR>
		
		<!--- <HR color=teal width=125> --->
		
		<DIV class=menuitems url="/logoff.cfm?id=<CFOUTPUT>#createuuid()#</CFOUTPUT>"><IMG src="/images/rc_menu/logoff_icon.gif" ALIGN="absbottom">&nbsp;Logoff</DIV>
	</DIV>	

	<!--- Contracts Menu --->
	<DIV CLASS="skin1" ID="ie5menu_2" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">

		<DIV class=menuitems url="/common_files/contracts/contract_edit_menu.cfm">&nbsp;View Contract</DIV>
		<DIV class=menuitems url="/common_files/contracts/contract_create_1_form.cfm">&nbsp;Basic Info</DIV>
		<DIV class=menuitems url="/common_files/contracts/select_operators.cfm">&nbsp;Operators</DIV>
		<DIV class=menuitems url="/common_files/contracts/select_brokers.cfm">&nbsp;Brokers</DIV>
		<DIV class=menuitems url="/common_files/contracts/select_distributors.cfm">&nbsp;Distributors</DIV>
		<DIV class=menuitems url="/common_files/contracts/select_products.cfm">&nbsp;Products</DIV>
		<DIV class=menuitems url="/common_files/contracts/contract_products_rebate_entry.cfm">&nbsp;Rates</DIV>

		
		<HR color="silver" width="125" SIZE="1">
		
		<DIV class=menuitems url="/Manufacturers/home.cfm"><IMG src="/images/rc_menu/home_icon.gif" ALIGN="absbottom">&nbsp;Home</DIV></NOBR>
		
		<!--- <HR color=teal width=125> --->
		
		<DIV class=menuitems url="/logoff.cfm?id=<CFOUTPUT>#createuuid()#</CFOUTPUT>"><IMG src="/images/rc_menu/logoff_icon.gif" ALIGN="absbottom">&nbsp;Logoff</DIV>
	</DIV>	

	<!--- Distributor Menu --->
	<DIV CLASS="skin1" ID="ie5menu_3" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">
		<DIV class=menuitems url="" ONCLICK="profilePopup('distributor')">&nbsp;Distributor Summary</DIV>

		
		<HR color="silver" width="125" SIZE="1">
		
		<DIV class=menuitems url="/Manufacturers/home.cfm"><IMG src="/images/rc_menu/home_icon.gif" ALIGN="absbottom">&nbsp;Home</DIV></NOBR>
		
		<!--- <HR color=teal width=125> --->
		
		<DIV class=menuitems url="/logoff.cfm?id=<CFOUTPUT>#createuuid()#</CFOUTPUT>"><IMG src="/images/rc_menu/logoff_icon.gif" ALIGN="absbottom">&nbsp;Logoff</DIV>
	</DIV>

	<!--- Broker Menu --->
	<DIV CLASS="skin1" ID="ie5menu_4" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">
		<DIV class=menuitems url="" ONCLICK="profilePopup('broker')">&nbsp;Broker Summary</DIV>

		
		<HR color="silver" width="125" SIZE="1">
		
		<DIV class=menuitems url="/Manufacturers/home.cfm"><IMG src="/images/rc_menu/home_icon.gif" ALIGN="absbottom">&nbsp;Home</DIV></NOBR>
		
		<!--- <HR color=teal width=125> --->
		
		<DIV class=menuitems url="/logoff.cfm?id=<CFOUTPUT>#createuuid()#</CFOUTPUT>"><IMG src="/images/rc_menu/logoff_icon.gif" ALIGN="absbottom">&nbsp;Logoff</DIV>
	</DIV>		

	<!--- Operator Menu --->
	<DIV CLASS="skin1" ID="ie5menu_5" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">
		<DIV class=menuitems url="" ONCLICK="profilePopup('operator')">&nbsp;Operator Summary</DIV>

		
		<HR color="silver" width="125" SIZE="1">
		
		<DIV class=menuitems url="/Manufacturers/home.cfm"><IMG src="/images/rc_menu/home_icon.gif" ALIGN="absbottom">&nbsp;Home</DIV></NOBR>
		
		<!--- <HR color=teal width=125> --->
		
		<DIV class=menuitems url="/logoff.cfm?id=<CFOUTPUT>#createuuid()#</CFOUTPUT>"><IMG src="/images/rc_menu/logoff_icon.gif" ALIGN="absbottom">&nbsp;Logoff</DIV>
	</DIV>		

	<!--- Product Menu --->
	<DIV CLASS="skin1" ID="ie5menu_6" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">
		<DIV class=menuitems url="" ONMOUSEOVER="doNotRelocate=1" ONMOUSEOUT="doNotRelocate=0" ONCLICK="profilePopup('product')">&nbsp;Product Summary</DIV>

<DIV class=menuitems onclick="pricelistPopup()" ONMOUSEOVER="doNotRelocate=1" ONMOUSEOUT="doNotRelocate=0">&nbsp;Price List</DIV>

		
		<HR color="silver" width="125" SIZE="1">
		
		<DIV class=menuitems url="/Manufacturers/home.cfm"><IMG src="/images/rc_menu/home_icon.gif" ALIGN="absbottom">&nbsp;Home</DIV></NOBR>
		
		<!--- <HR color=teal width=125> --->
		
		<DIV class=menuitems url="/logoff.cfm?id=<CFOUTPUT>#createuuid()#</CFOUTPUT>"><IMG src="/images/rc_menu/logoff_icon.gif" ALIGN="absbottom">&nbsp;Logoff</DIV>
	</DIV>		
	<!---Watered Down Payable Menu --->
	<DIV CLASS="skin1" ID="ie5menu_7" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">

		<DIV class=menuitems onmouseover="doNotRelocate=1;" onclick="profilePopup('payable')">Billback Summary</DIV>
		
		<HR color="silver" width="125" SIZE="1">
		
		<DIV class=menuitems url="/Manufacturers/home.cfm"><IMG src="/images/rc_menu/home_icon.gif" ALIGN="absbottom">&nbsp;Home</DIV></NOBR>
		
		<!--- <HR color=teal width=125> --->
		
		<DIV class=menuitems url="/logoff.cfm?id=<CFOUTPUT>#createuuid()#</CFOUTPUT>"><IMG src="/images/rc_menu/logoff_icon.gif" ALIGN="absbottom">&nbsp;Logoff</DIV>
	</DIV>	
	
	<!---INVOICE Menu --->
	<DIV CLASS="skin1" ID="ie5menu_8" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">

		<DIV class=menuitems onmouseover="doNotRelocate=1;" onclick="profilePopup('invoice')">Invoice Summary</DIV>
		
		<HR color="silver" width="125" SIZE="1">
		
		<DIV class=menuitems url="/Manufacturers/home.cfm"><IMG src="/images/rc_menu/home_icon.gif" ALIGN="absbottom">&nbsp;Home</DIV></NOBR>
		
		<!--- <HR color=teal width=125> --->
		
		<DIV class=menuitems url="/logoff.cfm?id=<CFOUTPUT>#createuuid()#</CFOUTPUT>"><IMG src="/images/rc_menu/logoff_icon.gif" ALIGN="absbottom">&nbsp;Logoff</DIV>
	</DIV>	

	<!---OSD Menu --->
	<DIV CLASS="skin1" ID="ie5menu_9" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">

		<DIV class=menuitems onmouseover="doNotRelocate=1;" onclick="profilePopup('osd')">OSD Summary</DIV>
		
		<HR color="silver" width="125" SIZE="1">
		
		<DIV class=menuitems url="/Manufacturers/home.cfm"><IMG src="/images/rc_menu/home_icon.gif" ALIGN="absbottom">&nbsp;Home</DIV></NOBR>
		
		<!--- <HR color=teal width=125> --->
		
		<DIV class=menuitems url="/logoff.cfm?id=<CFOUTPUT>#createuuid()#</CFOUTPUT>"><IMG src="/images/rc_menu/logoff_icon.gif" ALIGN="absbottom">&nbsp;Logoff</DIV>
	</DIV>	
	
	<!---OSD Menu --->
	<DIV CLASS="skin1" ID="ie5menu_10" STYLE="background-color: WhiteSmoke; z-index: 5000;" onClick="jumptoie5()" onMouseOver="highlightie5()" onMouseOut="lowlightie5()">

		<DIV class=menuitems onmouseover="doNotRelocate=1;" onclick="profilePopup('deduction')">Deduction Summary</DIV>
		
		<HR color="silver" width="125" SIZE="1">
		
		<DIV class=menuitems url="/Manufacturers/home.cfm"><IMG src="/images/rc_menu/home_icon.gif" ALIGN="absbottom">&nbsp;Home</DIV></NOBR>
		
		<!--- <HR color=teal width=125> --->
		
		<DIV class=menuitems url="/logoff.cfm?id=<CFOUTPUT>#createuuid()#</CFOUTPUT>"><IMG src="/images/rc_menu/logoff_icon.gif" ALIGN="absbottom">&nbsp;Logoff</DIV>
	</DIV>	
<![endif]-->

<SCRIPT language=JavaScript1.2 src="/common_files/scripts/demenu.js"></SCRIPT>
<script>

function profilePopup(PopupLocation){
	switch (PopupLocation) {

		//distributor
		case "distributor":
			//alert()
			NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=' + internal_ID,'name','400','450','Yes', 'No')
		break;

		case "broker":
			NewWindow('/profiles/Brokers/Broker_profile.cfm?BID=' + internal_ID,'name','400','450','Yes', 'No')			
		break;

		case "operator":
			NewWindow('/profiles/Operators/Operator_profile.cfm?OID=' + internal_ID,'name','400','450','Yes', 'No')			
		break;

		case "product":
			NewWindow('/profiles/Products/Product_profile.cfm?PID=' + internal_ID,'name','400','450','Yes', 'No')			
		break;

		case "payable":
			NewWindow('/profiles/Payables/Payable_Summary.cfm?PID=' + internal_ID,'name','400','450','Yes', 'No')			
		break;		

		case "invoice":
			NewWindow('/profiles/Invoices/Invoice_Summary.cfm?IID=' + internal_ID,'name','400','450','Yes', 'No')			
		break;		

		case "osd":
			NewWindow('/profiles/OSD/osd_Summary.cfm?OID=' + internal_ID,'name','400','450','Yes', 'No')			
		break;

		case "deduction":
			NewWindow('/common_files/deductions/deduction_Summary_popup.cfm?DID=' + internal_ID,'name','400','450','Yes', 'No')			
		break;					
	}
}

//price list popup
function pricelistPopup(product_upc){
			NewWindow('/common_files/Products/pricelist_display.cfm?upc=' + internal_ID,'name','670','500','Yes', 'No')			
	
	}

</script>
<SCRIPT language=JavaScript1.2>
if (document.all&&window.print){
document.oncontextmenu=showmenuie5
document.body.onclick=hidemenuie5
}
</SCRIPT>