<cfscript>
	//StructDelete(Session, "Programs");
	if(isDefined("Session.Programs") EQ "YES"){
		//Here
		temp="";
	}
	else {
		Session.Programs=StructNew();

		//Programs Global Vars
		Session.Programs.Properties=StructNew();
		StructInsert(Session.Programs.Properties,"Overwrite_Session_Structure", 0);
		StructInsert(Session.Programs.Properties,"Current_Program_ID", "0"); //ID of Contract Being Edited
		StructInsert(Session.Programs.Properties,"Current_Program_Type_ID", "0"); //ID of user created program Name

		Session.Programs.SECTIONS=StructNew();

		//Setup locations for the data within these sections
		Session.Programs.SECTIONS.Basic_Information=StructNew();
		Session.Programs.SECTIONS.Operators=StructNew();
		Session.Programs.SECTIONS.Brokers=StructNew();
		Session.Programs.SECTIONS.Distributors=StructNew();
		Session.Programs.SECTIONS.Products=StructNew();
		Session.Programs.SECTIONS.LambWestonFunctionality=StructNew();
		Session.Programs.SECTIONS.Rates=StructNew(); //Contract Specfifc
		Session.Programs.SECTIONS.Components=StructNew(); //HQ Rebates Specififc

	}


</cfscript>
<!--- <cfdump var="#Session#"> --->

<CFSET PAGE_TITLE="Program">
<CFSET group="group">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

<script>
function initPage() {
	window.onbeforeunload=saveSessionData;
}

function getAttributesWindow(title, debugObject) {
	/* lists all the attributes associated with debugObject in a separate window */
	msgWindow = window.open('','attributeWindow','');
	msgWindow.document.write('<' + 'SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">\n');
	msgWindow.document.write('function stopError() {return true}\n');
	msgWindow.document.write('window.onerror = stopError;\n');
	msgWindow.document.write('<' + '/SCRIPT>\n');
	msgWindow.document.write('&lt;' + title + '&gt;\n<OL>\n');
	for(var i in debugObject) {
		var valueString = debugObject[i];
		if(typeof(valueString) == 'object') {
			var strValueString = '"' + valueString + '"';
			msgWindow.document.write('\t<LI CLASS="OITEM">' + strValueString + ' <b>[' + i + ']</b><OL TYPE="a">\n');
			if(strValueString!='"null"') {
				// for(var j in debugObject) {
					// valueString2 = debugObject[j];
					// if(typeof(valueString2) == 'string') {
						// var ltRE = new RegExp(String.fromCharCode(60), "g");
						// if(valueString2.match(ltRE)) {valueString2 = valueString2.replace(ltRE, "&lt;");}
						// var gtRE = new RegExp(String.fromCharCode(62), "g");
						// if(valueString2.match(gtRE)) {valueString2 = valueString2.replace(gtRE, "&gt;");}
						// }
					// msgWindow.document.write('\t\t<LI CLASS="OITEM">"' + valueString2 + '" <b>' + i + '.' + j + '</b></LI>\n');
					// }
				}
			msgWindow.document.write('</OL></LI>\n');
			}
		else {
			if(typeof(valueString) == 'string') {
				var ltRE = new RegExp(String.fromCharCode(60), "g");
				if(valueString.match(ltRE)) {valueString = valueString.replace(ltRE, "&lt;");}
				var gtRE = new RegExp(String.fromCharCode(62), "g");
				if(valueString.match(gtRE)) {valueString = valueString.replace(gtRE, "&gt;");}
				}
			msgWindow.document.write('\t<LI CLASS="OITEM">"' + valueString + '" <b>' + i + '</b></LI>\n');
			}
		}
	msgWindow.document.write('</OL>\n');
	}


	//displays session retoration window
	showRestoreWindow=function(){
		NewWindow("restore_from_session_form.cfm", "sessionRestoreWindow", 200, 200, "yes", "yes")
	}

	//function  to popup a window to save session structure
	saveSessionData=function() {
		ANewWindow("save_session_var.cfm?ThisCodeExecutedInWindow=1", "sessionSaveWindow", 10, 10, "yes", "yes")

	}

	var currentlyActiveTab = new Object() //holds last tabClick

	//appends new tab ino the menu
	addTabToMenu=function(Tab_Caption, Tab_ID) {
		//alert(Tab_Caption)
		newMenuTabRow = oMenuTable.insertRow(0)
		newMenuTabRow.objectID = "menu_tab"
		newMenuTabCell = newMenuTabRow.insertCell()
		newMenuTabCell.className = "menuItem_idle"
		newMenuTabCell.innerHTML = Tab_Caption
		newMenuTabCell.pageRenderNumber = Tab_ID
	}

	//clears the menu
	clearMenuTabs=function(){
		for(var x=0; x<oMenuTable.rows.length;x++){
			tempRow = oMenuTable.rows[x]
			if(tempRow.objectID != null){
				oMenuTable.deleteRow(x)
			}
		}
	}

	//binds whatever is necessary to the rows the become useful
	initializeMenuTabs=function(){
		for(var x=0; x<oMenuTable.rows.length;x++){
			tempRow = oMenuTable.rows[x]
			if(tempRow.objectID != null){
				tempRow.cells[0].onmouseover = tabMouseOver;
				tempRow.cells[0].onmouseout = tabMouseOut;
				tempRow.cells[0].onclick = tabMouseClick;
			}
		}
		currentlyActiveTab = oMenuTable.rows[0].cells[0];
		currentlyActiveTab.className = "menuItem_current";
	}

	//highlight the calling tab when the mouse id above it
	tabMouseOver=function(){
		if(this.className != "menuItem_current"){
			this.className = "menuItem_active"
		}
	}

	//unhighlight the calling tab when the mouse id above it
	tabMouseOut=function(){
		if(currentlyActiveTab.innerHTML != null){
			if(this.className != "menuItem_current"){
				this.className = "menuItem_idle";
			}
		}
	}


	//tab menu item clicked
	tabMouseClick=function(){
		currentlyActiveTab.className = "menuItem_idle";
		this.className = "menuItem_current";
		currentlyActiveTab = this;
		navigateTo();

	}

	//navigation routine called after a button is clicked from within tabMouseClick
	navigateTo=function(){
		event.srcElement.tagName
		document.contentIframe.location.href = "render_dynamic_page.cfm?Tab_ID=" + event.srcElement.pageRenderNumber
	}


	function ANewWindow(mypage, myname, w, h, scroll, resize)
	{
		var winl = 10000;
		var wint = 10000;
		winprops = 'height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars='+scroll+',resizable='+resize
		win = window.open(mypage, myname.replace(/\s/g, ''), winprops)
		if (parseInt(navigator.appVersion) >= 4) { win.window.focus(); }
	}
</script>



</HEAD>

<BODY BACKGROUND="" onload="initPage()" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/header.cfm">

<style>
	.HeaderBar {
		height: 22px;
		border-right:solid blue 1px;
		border-top:solid blue 1px;
		border-bottom:solid blue 1px;
		border-left:solid blue 1px;
		font-size: 14px;
		font-weight: bold;
	}

	.StatusBar {
		height: 22px;
		border-right:solid blue 1px;
		border-top:solid blue 1px;
		border-bottom:solid blue 1px;
		border-left:solid blue 1px;
	}

	.cellaroundIframe {
		border-right:solid red 1px;
		border-top:solid red 1px;
		border-bottom:solid red 1px;
	}
	.menuItem_idle {
		font-weight: bold;
		background-color: WhiteSmoke;
		PADDING-BOTTOM: 1px;
		PADDING-LEFT: 10px;
		PADDING-RIGHT: 10px;
		PADDING-TOP: 1px;
		border-right:solid red 1px;
		border-top:solid WhiteSmoke 1px;
		border-bottom:solid WhiteSmoke 1px;
		border-left:solid WhiteSmoke 1px;
		border-white:solid White 1px;
	}
	.menuItem_active {
		font-weight: bold;
		background-color: silver;
		PADDING-BOTTOM: 1px;
		PADDING-LEFT: 10px;
		PADDING-RIGHT: 10px;
		PADDING-TOP: 1px;
		border-right:solid red 1px;
		border-top:solid WhiteSmoke 1px;
		border-bottom:solid WhiteSmoke 1px;
		border-left:solid WhiteSmoke 1px;
		border-white:solid White 1px;
		cursor: pointer;
	}

	.menuItem_current {
		font-weight: bold;
		background-color: white;
		PADDING-BOTTOM: 1px;
		PADDING-LEFT: 10px;
		PADDING-RIGHT: 10px;
		PADDING-TOP: 1px;
		border-right:solid white 1px;
		border-top:solid red 1px;
		border-bottom:solid red 1px;
		border-left:solid red 1px;
		border-white:solid red 1px;
	}
</style>


<INPUT type="Button" onclick="showRestoreWindow()" value="RESTORE">
<INPUT type="Button" onclick="window.location='test.cfm'" value="RESTART">
<INPUT type="Button" onclick="NewWindow('show_session.cfm', '', 600, 600, 'yes', 'yes')" value="debug">
<TABLE WIDTH="96%" HEIGHT="100%" BORDER="0" ALIGN="center" ID="oTable" CELLPADDING="0" CELLSPACING="0">
<!--- <TR>
	<td>&nbsp;</td>
	<TD  ID="HeaderBar" CLASS="HeaderBar">&nbsp;</TD>
</TR> --->
<TR>
	<TD COLSPAN="100%" HEIGHT="5px"></TD>
</TR>
<TR>
	<TD VALIGN="top">
		<TABLE id="oMenuTable" HEIGHT="100%" BORDER="0" CELLSPACING="0" CELLPADDING="0" STYLE="border: 0px none;">
 				<TR>
					<TD HEIGHT="100%" CLASS="menuItem_idle">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>
				</TR>
			</TABLE>
	</TD>

	<TD ROWSPAN="1" WIDTH="100%" ID="cellWithIframe" CLASS="cellaroundIframe"><IFRAME SRC="select_program_type.cfm" NAME="contentIframe" ID="contentIframe" WIDTH="100%" HEIGHT="100%" FRAMEBORDER="0"></IFRAME></TD>
</TR>

<TR>
	<TD COLSPAN="100%" HEIGHT="5px"></TD>
</TR>

<!--- <TR>
	<TD>&nbsp;</TD>
	<TD ID="StatusBar" CLASS="StatusBar" VALIGN="middle">&nbsp;</TD>
</TR> --->

</table>
<iframe name="communicationGateway" id="communicationGateway" width="0" height="0" marginwidth="0" marginheight="0" src="automatedSessionSave.cfm"></iframe>

<CFINCLUDE TEMPLATE="/includes/footer.cfm">


</BODY>
</HTML>
