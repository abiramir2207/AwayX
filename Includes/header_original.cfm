
<!--- Test for the appropriate browser															 --->
<CF_browser browserVerbose="true" versionVerbose="true">
	<CFIF browser NEQ "MS Internet Explorer" OR (browser EQ "MS Internet Explorer" AND version LT 5.0)>
		<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">window.location.href = '/getie.cfm';</SCRIPT>
	</CFIF>



<CFPARAM NAME="group" 		DEFAULT="">
<CFPARAM NAME="PAGE_TITLE"	DEFAULT=" ">




<STYLE TYPE="text/css">
#navbarlinks
	{
		font-weight : bold;
		color: #000000;
		font-size: 12px;
	}
A:HOVER.navbarlinks
	{
		color : White;
	}

SPAN.text {
font-size: 12pt;
font-weight: bold;
color: Yellow;
position: absolute;
left: 112px;
top: 13px;
z-index: 2
}

SPAN.shadow {
font-size: 12pt;
font-weight: bold;
color: black;
position: absolute;
left: 113px;
top: 14px;
z-index: 1
}
</STYLE>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Preload the mouse over images/icons of the header												 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SCRIPT>
<!-- Begin
image1 = new Image();
image1.src = "/Images/home_icon_new_down.gif";
image2 = new Image();
image2.src = "/Images/contracts_icon_new_down.gif";
image3 = new Image();
image3.src = "/Images/payables_icon_new_down.gif";
image4 = new Image();
image4.src = "/Images/profiles_icon_new_down.gif";
image5 = new Image();
image5.src = "/Images/reports_icon_new_down.gif";
image6 = new Image();
image6.src = "/Images/pda_icon_new_down.gif";
image7 = new Image();
image7.src = "/Images/settings_icon_new_down.gif";
image8 = new Image();
image8.src = "/Images/logoff_icon_new_down.gif";
// End -->
</SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->





<TABLE HEIGHT="97%" WIDTH="100%" CELLPADDING="0" CELLSPACING="0" BORDER="0"><TR><TD>
<CFOUTPUT>
<TABLE border="0" width="100%" cellspacing="0" cellpadding="0" background="/Images/Header_new/header_background.gif">
	<TR>
		<TD><A HREF="#request.AccessStructure.User_Directory#/home.cfm"><IMG border="0" src="/Images/Header_new/#request.AccessStructure.Company_logo#" width="105" height="78"></A></TD>
		<TD width="100%" VALIGN="bottom">




			<SPAN CLASS="Text"><FONT SIZE="3">#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#</FONT><FONT SIZE="2"> - #dateformat(now(), 'dddd')#, #dateformat(now(), 'mmmm d yyyy')#</FONT></SPAN>
			<SPAN CLASS="Shadow"><FONT SIZE="3">#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#</FONT><FONT SIZE="2"> - #dateformat(now(), 'dddd')#, #dateformat(now(), 'mmmm d yyyy')#</FONT></SPAN>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- 		This is the old header data
			<SPAN CLASS="Text">#request.AccessStructure.Company_Name# - <FONT SIZE="3">#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#<!---  - #request.AccessStructure.User_Rights_ID# ---></FONT></SPAN>
			<SPAN CLASS="Shadow">#request.AccessStructure.Company_Name# - <FONT SIZE="3">#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#</FONT></SPAN>
 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
				<TR>
					<TD width="100%">&nbsp;</TD>

					<TD><A HREF="#request.AccessStructure.User_Directory#/home.cfm" onmouseover="homeicon.src='/Images/home_icon_new_down.gif';" onmouseout="homeicon.src='/Images/home_icon_new_up.gif';"><IMG border="0" name="homeicon" src="/Images/home_icon_new_up.gif" TITLE="Home..."></A></TD>
					<TD><A HREF="javascript:NewWindow('/todo/todo_view.cfm','name','320','240','Yes', 'Yes');" onmouseover="ticklericon.src='/Images/tickler_icon_new_down.gif';" onmouseout="ticklericon.src='/Images/tickler_icon_new_up.gif';"><IMG border="0" name="ticklericon" src="/Images/tickler_icon_new_up.gif" TITLE="Tickler..."></A></TD>


					<CFIF request.AccessStructure.User_Rights_ID LT 3000>
						<TD><IMG border="0" name="contractsicon" src="/Images/contracts_icon_new_not.gif" TITLE="Contracts..."></TD>
					<CFELSE>
						<TD><A HREF="/common_files/contracts/index.cfm" onmouseover="contractsicon.src='/Images/contracts_icon_new_down.gif';" onmouseout="contractsicon.src='/Images/contracts_icon_new_up.gif';"><IMG border="0" name="contractsicon" src="/Images/contracts_icon_new_up.gif" TITLE="Contracts..."></A></TD>
					</CFIF>

					<CFIF request.AccessStructure.User_Rights_ID LT 4000>
						<TD><IMG border="0" name="payablesicon" src="/Images/payables_icon_new_not.gif" TITLE="Payables..."></TD>
					<CFELSE>
						<TD><A HREF="/common_files/payables2/index.cfm" onmouseover="payablesicon.src='/Images/payables_icon_new_down.gif';" onmouseout="payablesicon.src='/Images/payables_icon_new_up.gif';"><IMG border="0" name="payablesicon" src="/Images/payables_icon_new_up.gif" TITLE="Payables..."></A></TD>
					</CFIF>


					<CFIF request.AccessStructure.User_Rights_ID LT 2000>
						<TD><IMG border="0" name="profilesicon" src="/Images/profiles_icon_new_not.gif" TITLE="Profiles..."></TD>
					<CFELSE>
						<TD><A HREF="/common_files/admin.cfm" onmouseover="profilesicon.src='/Images/profiles_icon_new_down.gif';" onmouseout="profilesicon.src='/Images/profiles_icon_new_up.gif';"><IMG border="0" name="profilesicon" src="/Images/profiles_icon_new_up.gif" TITLE="Profiles..."></A></TD>
					</CFIF>

					<TD><A HREF="/reports/index.cfm" onmouseover="reportsicon.src='/Images/reports_icon_new_down.gif';" onmouseout="reportsicon.src='/Images/reports_icon_new_up.gif';"><IMG border="0" name="reportsicon" src="/Images/reports_icon_new_up.gif" TITLE="Reports..."></A></TD>



					<CFIF request.AccessStructure.User_Rights_ID LT 4000>
						<TD><IMG border="0" name="pdaicon" src="/Images/pda_icon_new_not.gif" TITLE="PDA Exports..."></TD>
					<CFELSE>
						<TD><A HREF="/pda_stuff/index.cfm" onmouseover="pdaicon.src='/Images/pda_icon_new_down.gif';" onmouseout="pdaicon.src='/Images/pda_icon_new_up.gif';"><IMG border="0" name="pdaicon" src="/Images/pda_icon_new_up.gif" TITLE="PDA Exports..."></A></TD>
					</CFIF>



					<CFIF request.AccessStructure.User_Rights_ID LT 3000>
						<TD><IMG border="0" name="settingsicon" src="/Images/settings_icon_new_not.gif" TITLE="Settings..."></TD>
					<CFELSE>
						<TD><A HREF="/settings/index.cfm" onmouseover="settingsicon.src='/Images/settings_icon_new_down.gif';" onmouseout="settingsicon.src='/Images/settings_icon_new_up.gif';"><IMG border="0" name="settingsicon" src="/Images/settings_icon_new_up.gif" TITLE="Settings..."></A></TD>
					</CFIF>

					<TD><A HREF="/logoff.cfm?id=#createuuid()#" onmouseover="logofficon.src='/Images/logoff_icon_new_down.gif';" onmouseout="logofficon.src='/Images/logoff_icon_new_up.gif';"><IMG border="0" name="logofficon" src="/Images/logoff_icon_new_up.gif" TITLE="Logoff..."></A></TD>
					<TD><IMG SRC="/images/fill.gif" WIDTH="10" HEIGHT="18"></TD>
				</TR>
			</TABLE>


			<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="22">
			<SPAN CLASS="TITLE2">#PAGE_TITLE#</SPAN><BR><BR>
		</TD>
	</TR>
</TABLE>

</CFOUTPUT>

</TD></TR>
<TR><TD HEIGHT="100%" VALIGN="top">



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
		<DIV class=menuitems url="/common_files/payables2/index.cfm"><IMG src="/images/rc_menu/payables_icon.gif" ALIGN="absbottom">&nbsp;Payables</DIV>
		<DIV class=menuitems url="/common_files/admin.cfm"><IMG SRC="/images/rc_menu/profiles_icon.gif" ALT="" BORDER="0" ALIGN="absbottom">&nbsp;Profiles</DIV>
		<DIV class=menuitems url="/reports/index.cfm"><IMG src="/images/rc_menu/reports_icon.gif" ALIGN="absbottom">&nbsp;Reports</DIV>
		<DIV class=menuitems url="/pda_stuff/index.cfm"><IMG src="/images/rc_menu/pda_icon.gif" ALIGN="absbottom">&nbsp;PDA</DIV>
		<DIV class=menuitems url="/settings/index.cfm"><IMG src="/images/rc_menu/settings_icon.gif" ALIGN="absbottom">&nbsp;Settings</DIV>
		<DIV class=menuitems url="/common_files/deductions/index.cfm"><IMG src="/images/rc_menu/payables_icon.gif" ALIGN="absbottom">&nbsp;Deductions</DIV>


		<HR color="silver" width="125" SIZE="1">

		<DIV class=menuitems url="/settings/index.cfm" ONMOUSEOVER="doNotRelocate=1;" ONMOUSEOUT="doNotRelocate=0;" ONCLICK="addToDoList()">&nbsp;Add ToDo</DIV>
		<DIV class=menuitems url="/settings/index.cfm" ONMOUSEOVER="doNotRelocate=1;" ONMOUSEOUT="doNotRelocate=0;" ONCLICK="viewToDoList()">&nbsp;View ToDo</DIV>
		<HR color="silver" width="125" SIZE="1">

		<DIV class=menuitems url="/Manufacturers/home.cfm"><IMG src="/images/rc_menu/home_icon.gif" ALIGN="absbottom">&nbsp;Home</DIV></NOBR>

		<!--- <HR color=teal width=125> --->
		<DIV class=menuitems url=""><IMG src="/images/rc_menu/logoff_icon.gif" ALIGN="absbottom" onclick="history.go(0)">&nbsp;Refresh</DIV>
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


<![endif]-->

<SCRIPT language=JavaScript1.2 src="/common_files/scripts/demenu.js"></SCRIPT>
<SCRIPT language=JavaScript1.2>

if (document.all&&window.print){
document.oncontextmenu=showmenuie5
document.body.onclick=hidemenuie5
}

//code to open a new window
function NewWindow(mypage, myname, w, h, scroll, resize)
{
	var winl = (screen.width - w) / 2;
	var wint = (screen.height - h) / 2;
	winprops = 'height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars='+scroll+',resizable='+resize
	win = window.open(mypage, myname.replace(/\s/g, ''), winprops)
	if (parseInt(navigator.appVersion) >= 4) { win.window.focus(); }
}

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

	}
}

//price list popup
function pricelistPopup(product_upc){
			NewWindow('/common_files/Products/pricelist_display.cfm?upc=' + internal_ID,'name','450','550','Yes', 'Yes')

	}

function addToDoList(){
	NewWindow('/todo/todo_entry.cfm','name','320','240','Yes', 'Yes')
}

function viewToDoList(){
	NewWindow('/todo/todo_view.cfm','name','320','240','Yes', 'Yes')
}



</SCRIPT>




