<CFSET pagetitle = "PROGRAMS: PROGRAM WIZARD">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=32>
<CFINCLUDE TEMPLATE="/help_files/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
 --->
<BR>

<cfset PAGE_TITLE = "Program Type Names">

<cfparam name="z" default="Operator-Deviated Pricing">

<cfquery name="getGenericValues" datasource="#application.datasource#">
	SELECT DISTINCT Generic_Type
	FROM Program_Control_Panel_Options
	WHERE Company_Main_ID = '#request.AccessStructure.Company_Main_ID#'
	AND Deleted = 0
	ORDER BY Generic_Type
</cfquery>

<cfquery name="getCreatedTypes" datasource="#application.datasource#">
	SELECT *
	FROM Program_Control_Panel_Options
	WHERE Company_Main_ID = '#request.AccessStructure.Company_Main_ID#'
	AND Deleted = 0
	ORDER BY Created_Type
</cfquery>

<cfquery name="getGLNames" datasource="#application.datasource#">
	Select Deduction_Programs_And_GL_Reason_Code_ID, Program_Name
	From Deduction_Programs_And_GL_Reason_Codes
</cfquery>		
								
<cfoutput>
<cfwddx action="CFML2JS" input="#getGenericValues#" output="MyDynamicJSCode4getGenericValues" toplevelvariable="generic">
<cfwddx action="CFML2JS" input="#getCreatedTypes#" output="MyDynamicJSCode4getCreatedTypes" toplevelvariable="created">
</cfoutput>
<HTML>
<CF_MessageWindow>
<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
<script>
	function verifyAllData() {

		if(document.all.sel.selectedIndex == -1)
		{
			 alert("Select The Program You Want To Act Upon.")
			 return false
		}

		NoErrors = true
		if(!verifyBasics()) NoErrors = false
		if(!verifyRates()) NoErrors = false		
		if(!verifyDiscountTypes()) NoErrors = false
		if(!verifyClaimMechs()) NoErrors = false
		if(!verifyPaymentCycle()) NoErrors = false
			
		
		
		if(parseInt(document.all.Program_Editable.value) == 0 && parseInt(document.all.Current_Active_State.value) == 0){
			alert("You Cannot Save Changes To An In-Active Program")
			return false;
		}
		
		if(parseInt(document.all.Current_Active_State.value) == 1){
			if(document.all.Active[0].checked) {
				alert("You Cannot Save Changes To An Active Program")
				return false	
			}
		}
		
		if(NoErrors == false) {
			showMessageWindow()
			return false;
		}
		else{
			return true;
		}
		
	}

	<!--- <CFINCLUDE TEMPLATE="/script/javascript/string_functions.js"> --->
</script>

<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<!--- <LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css"> --->
	<!--// load the qForm JavaScript API //-->
	<SCRIPT SRC="/qForms/compressed/qforms.js"></SCRIPT>
	<script src="/wddx.js"></script>
	<script src="/debug.js"></script>
<cfoutput>
	<SCRIPT LANGUAGE="JavaScript">

	// wddx variable holding getColumns query data
	#MyDynamicJSCode4getCreatedTypes#
	#MyDynamicJSCode4getGenericValues#
		
	// set the path to the qForms directory
	qFormAPI.setLibraryPath("/qForms/compressed/");
	// this loads all the default libraries
	qFormAPI.include("*");

	// this is the default struct to use for the blank options to prefix
	// when populating a select box
	stcBlank = new Object();
	stcBlank[""] = "Existing Created Types(s)";
		
	// create a structure in which to store all the DB information
	jchDBObj = new Object();
	
	/* Get row count */
		nGRows = generic.getRowCount();		// columns
		nCRows = created.getRowCount();		// tables
	
	// Loop through query data and build table/column arrays
	for(var grow = 0; grow < nGRows; ++grow) {
		var gen = generic.getField(grow, 'Generic_Type');
	
		jchDBObj[gen] = new Object();
		
		for (var crow = 0; crow < nCRows; ++crow) {
			var cgen = created.getField(crow, 'Generic_Type');
			if (gen == cgen) {
				var create = created.getField(crow, 'Created_Type');
				
				jchDBObj[gen][create] = new Object();
				jchDBObj[gen][create] = create;
			}
		}
	}	
	
	var addingNewProgramType = 0;
	function init(){
		// initialize the qForm object
		objForm = new qForm("MyForm");
		document.MyForm.txt.focus()
		// make these fields required
		objForm.required("selGeneric,sel");
	}
	
			// this example shows how you could pre-populate the form
		function setDefault(){
			objForm.selGeneric.setValue("selGeneric");
			objForm.sel.setValue("sel");
		}

		function setSelects() {
			if (document.MyForm.hiBit.value != '') {if (confirm("Press Cancel to return and save your work.  Press OK to continue without saving.")){document.MyForm.hiBit.value = ''; objForm.sel.populate(jchDBObj[objForm.selGeneric.getValue()], null, null); return true;}else{return false}}
			objForm.sel.populate(jchDBObj[objForm.selGeneric.getValue()], null, null);
			
			resetAllData();		
		}
		
	//<!--- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end of qforns code  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% --->	
		
	nextfield = "txt"; // name of first box on page
	netscape = "";
	ver = navigator.appVersion; len = ver.length;
	for(iln = 0; iln < len; iln++) if (ver.charAt(iln) == "(") break;
	netscape = (ver.charAt(iln+1).toUpperCase() != "C");

	function keyDown(DnEvents) { // handles keypress
		// determines whether Netscape or Internet Explorer
		k = (netscape) ? DnEvents.which : window.event.keyCode;
		if (k == 13) { // enter key pressed
			if (nextfield == 'done') {
				return true; // submit, we finished all fields
			} else { // we're not done yet, send focus to next box
				eval('document.MyForm.' + nextfield + '.focus()');
				return false;
	      	}
	   	}
	}

	document.onkeydown = keyDown; // work together to analyze keystrokes
	if (netscape) {
		document.captureEvents(Event.KEYDOWN|Event.KEYUP);
	}

	function resetAllData() {
		document.MyForm.Active[1].checked=true;
		resetBasics();
		resetRateTypes();
		resetDiscountTypes();
		resetClaimMechs();
		resetPaymentCycle();
		resetCPR();	
	}
	function setChecks() {
		setChecksCPR(); 
		//setChecksEO(); 
		setChecksBasics(); 
		setChecksDT();
		setChecksPC();
		setChecksRT();
		//setChecksCOMM();
		setChecksCMech();
	}
	
	function onChange(objSel,objTxt) {
	    var Current = objSel.selectedIndex;
	    objTxt.value = objSel.options[Current].text;
	    //objTxt.value = objSel.options[Current].value;
	}
	
	function addOption(objSel,objTxt) {
		if(objTxt.value.length != 0){
			
			resetAllData();
						
			document.MyForm.hiBit.value = '1';
			document.MyForm.sel.length = 0;
		    document.MyForm.Active[1].checked = true;
			var defaultSelected = false;
		    var selected = false;
		    var optionName = new Option(objTxt.value, objTxt.value, defaultSelected, selected)
		    var length = objSel.length;
		    objSel.options[length] = optionName;
			objSel.options[length].selected = true
		}
	}
	
	function replaceOption(objSel,objTxt) {
		if (objSel.selectedIndex == -1) {
			alert('You need to highlight the list item you wish to replace.');
			return false;
		} else {
		    var Current = objSel.selectedIndex;
			document.MyForm.oldCreatedType.value = objSel.options[Current].text
			objSel.options[Current].text = objTxt.value;
			objSel.options[Current].value = objTxt.value;
			document.MyForm.hiBit.value = '2';
			//document.all.z.disabled = true;
			//alert(document.MyForm.hiBit.value);
		}
	}
	
	function setEditMode() {
		if(document.MyForm.sel.selectedIndex != -1){
			document.MyForm.oldCreatedType.value = document.MyForm.sel.options[document.MyForm.sel.selectedIndex].text;
			document.MyForm.hiBit.value = '2';
		}
		//document.all.z.disabled = true;
	}
	
	function deleteOption(objSel) {
		if (objSel.selectedIndex == -1) {
			alert('You need to highlight the list item you wish to delete.');
			return false;
		} else {
		    var Current = objSel.selectedIndex;
			document.MyForm.oldCreatedType.value = objSel.options[Current].text;

			if(confirm("Press OK To Delete "+document.MyForm.oldCreatedType.value)){
				var Current = objSel.selectedIndex;
				//document.MyForm.oldCreatedType.value = objSel.options[Current].text;
			    //objSel.options[Current] = null;
				document.MyForm.hiBit.value = '3';
				document.MyForm.submit();
			}
			
		}
	}

	function verifyStatusChange(oRadioButton) {
		if(oRadioButton.value == 1){
			if(!confirm("ACTIVE PROGRAM TYPES ARE AVAILABLE FOR PROGRAM CREATION AND CAN NOT BE EDITED. ARE YOU SURE THE PROGRAM TYPE IS READY FOR ACTIVE STATUS?")){
				document.MyForm.Active[1].checked = true;
			}
		}
		else
		{
			if(!confirm("THIS PROGRAM TYPE WILL NO LONGER BE AVAILABLE FOR USE ONCE IT IS DEACTIVATED. ARE YOU SURE YOU WANT TO DE-ACTIVATE THIS ONE?")){
				document.MyForm.Active[0].checked = true;
			}
		}
	}
//  End -->
</script>
</cfoutput>

<SCRIPT language="JavaScript" src="/Common_Files/scripts/requiredFields.js"></SCRIPT>	
<SCRIPT language="JavaScript" src="/Common_Files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>
<SCRIPT language="JavaScript" src="/Common_Files/scripts/formattotwodecimals.js"></SCRIPT>	

<SCRIPT>
//																							
//																							
//	This code does several things:															
//	First																					
//		Makes sure that the contents 0f the input box DO match the list on line 24			
//		In this list not only numbers but also the period is allowed						
//	Second																					
//		If a certain number of characters has been typed than the focus "jumps" to			
//		the next text box. Very usefull when creating data input boxes for fixed 			
//		length strings: phone numbers, zip, Social Security numbers etc.					
//																							
//	The way to invoke this, is by adding to the text box being "protected" something like :	
//		ONKEYUP="javascript:nextBox(this, 'fieldname', 3);"									
//																							
//		This 		= the current field name												
//		fieldname	= the name of the field that the focus will jump to						
//		3 			= the number of characters that will be entered in the current field	
//																							
//				

		function nextBox(CurrentElement, NextElement, MaxSize){
			if(isValid(CurrentElement.value, valid)){
				if(CurrentElement.value.length == MaxSize){
					if(NextElement != 'NONE'){
						eval('document.all.'+NextElement+'.focus()')
					}
				}
			}
			else{
				ClearCharsUntilIntegerIsFound(CurrentElement)
			}
		}

		function ClearLastCharEnteredIfNotNumber(textObject){
			if(!isValid(textObject.value, valid)){
				newText = textObject.value.substring(0, textObject.value.length - 1)
				textObject.value = newText;
			}
		}

		var valid = '0123456789'; // define valid characters

		function isValid(string,allowed) {
		    for (var i=0; i< string.length; i++) {
		       if (allowed.indexOf(string.charAt(i)) == -1)
		          return false;
		    }
		    return true;
		}
		
		function ClearCharsUntilIntegerIsFound(textObject) {
			
			do {
				ClearLastCharEnteredIfNotNumber(textObject)
			}while (!isValid(textObject.value, valid))
		}

	function confirmNewProgram(){
		if(document.all.selGeneric.selectedIndex == 0){
			alert("Please Select The Generic Type Of The Program");
		}
		else{
			if( trim(document.all.txt.value).length == 0){
				alert("Please Enter A Valid Name For The Program");
			}
			else{
				return true;
			}
			
		}
		
		return false;
	}
</SCRIPT>

</head>

<body BGCOLOR="whitesmoke" onload="init();">

<B>
		<FONT SIZE="2" COLOR="Red">[</FONT>
			<FONT SIZE="2" COLOR="Blue">
				
					<A HREF="/help_files/manual/administration/program/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Program Wizard">
						read me first
					</A>
				
			</FONT>
		<FONT SIZE="2" COLOR="Red">]</FONT>
		</B>
</p>
		<p style="border: thin solid Orange; padding: 5px 5px 5px 5px; width: 305px; font-size: 12px; font-family: Arial, Helvetica, sans-serif;">
			<strong>How would you like to name your program types?</strong></p>

<form action="/settings/program_type_settings_action.cfm" method="post" name="MyForm" id="MyForm">

<font face="Arial,Helvetica,sans-serif"style="font-size: 11pt;">
	<table border="0" cellspacing="2" cellpadding="0">
		<tr valign="top" align="center">
			<td>
				<CENTER>
					<select name="selGeneric" id="selGeneric" onchange="setSelects(); this.form.txt.value = ''">
					<option>Select Generic Type</option> 
					<option value="Operator-Deviated Pricing">Operator-Deviated Pricing</option>
					<option value="Distributor Trade/Shelter">Distributor Trade/Shelter</option>
					<option value="Operator Direct or HQ Programs">Operator Direct or HQ Programs</option>
					<option value="Field Execution">Field Execution</option>
					</select>
					<BR>
					<input type="text" name="txt" size="29" value="" onFocus="nextfield ='sel';">
					<BR><BR>
					<input type="button" name="add" value=" add " title="ADD" onClick="if(confirmNewProgram()) {addOption(this.form.sel,this.form.txt); addingNewProgramType=1;}"><img src="../Images/CLEAR.GIF" alt="" width="5" height="1" border="0">
					<input type="button" name="remove" value=" delete " title="REMOVE" onClick="deleteOption(this.form.sel);">
					<BR><BR>
					<select name="sel" size="10"  style="width: 175px;" onchange="onChange(this.form.sel,this.form.txt); setChecks();"  onclick="<!--- document.all.z.disabled = false; --->"></select>
					<BR>
					<input type="hidden" name="ClaimPerfReq" id="ClaimPerfReq" value="">
					<BR>
					Program Is:<BR>
					<input TYPE="Radio" NAME="Active" VALUE="1" ONCLICK="verifyStatusChange(this)">Active
					<input TYPE="Radio" NAME="Active" VALUE="0" ONCLICK="verifyStatusChange(this)" CHECKED>In-Active
				</CENTER>
			</td>
			<TD BGCOLOR="Orange"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1" BORDER="0" ALT=""></TD>
			<td WIDTH="100%">

				
				<!---%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--->
				<!---				 Frank's Front Page Output				  --->
				<!---%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--->							
				
<!--- 	
				<style>
					TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
					#header {font-size: 12px;}
				</style>
 --->				
				
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<!--- Table options																					 --->
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<CFSET tableborder=0>
				<CFSET bgcolor="Silver">
				<CFSET tablewidth="500">
				<CFSET cellpadding=3>
				<CFSET cellspacing=0>
								
				
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<!--- Open layer Options																			 --->
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<CFSCRIPT>
				Layerborder="Yes";
				BorderSize=1;  
				BorderColor="orange";
				Image="/images/plus3.gif";
				ImageOpen="/images/minus3.gif";
				TitleColor="Blue"; 
				TitleFont="Arial";
				TitleSize=9;
				IsClosed="Yes";  
				layerwidth=525;
				</CFSCRIPT>


				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<CF_openLayer
				border="#layerborder#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="BASICS"  
				TitleClosed="BASICS"  
				TitleTooltip="Click here to toggle the view..."  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				width="#layerwidth#">
					<cfinclude template="program_type_settings_basics.cfm">
				</CF_openLayer>
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<BR><BR>
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<CF_openLayer
				border="#layerborder#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="RATE TYPES"  
				TitleClosed="RATE TYPES"  
				TitleTooltip="Click here to toggle the view..."  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				width="#layerwidth#">
					<cfinclude template="program_type_settings_rate_types.cfm">
				</CF_openLayer>
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<BR><BR>
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<CF_openLayer
				border="#layerborder#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="DISCOUNT TYPES"  
				TitleClosed="DISCOUNT TYPES"  
				TitleTooltip="Click here to toggle the view..."  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				width="#layerwidth#">
					<cfinclude template="program_type_settings_discount_types.cfm">
				</CF_openLayer>
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					<BR><BR>
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<CF_openLayer
				border="#layerborder#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="CLAIM MECHANICS"  
				TitleClosed="CLAIM MECHANICS"  
				TitleTooltip="Click here to toggle the view..."  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				width="#layerwidth#">
					<cfinclude template="program_type_settings_claim_mech.cfm">
				</CF_openLayer>
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<BR><BR>
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<CF_openLayer
				border="#layerborder#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="PAYMENT CYCLE"  
				TitleClosed="PAYMENT CYCLE"  
				TitleTooltip="Click here to toggle the view..."  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				width="#layerwidth#">
					<cfinclude template="program_type_settings_payment_cycle.cfm">
				</CF_openLayer>
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<BR><BR>
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<CF_openLayer
				border="#layerborder#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="CLAIM / PERFORMANCE REQUIREMENTS"  
				TitleClosed="CLAIM / PERFORMANCE REQUIREMENTS"  
				TitleTooltip="Click here to toggle the view..."  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				width="#layerwidth#">
					<cfinclude template="program_type_settings_claim_perf_req.cfm">
				</CF_openLayer>
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

				

			</td>
		</tr>
	</table>
</font>


<input type="hidden" name="hiBit" id="hiBit" value="">
<input type="hidden" name="saveType" id="saveType" value="">
<input type="hidden" name="oldCreatedType" id="oldCreatedType" value="">

<CENTER>
<BR>
<FONT COLOR="Red"><B><I>You must press the continue button to save each record or all work will be lost!</I></B></FONT>
<br>

<INPUT TYPE="button" NAME="save" ID="save" VALUE=" continue " onClick="if(verifyAllData()) { 
     if(addingNewProgramType == 0) {
          setEditMode()
     }
     sendScriptPTS();
}">
</CENTER>

<INPUT TYPE="hidden" NAME="Program_Editable" VALUE="">
<INPUT TYPE="hidden" NAME="Current_Active_State" VALUE="">
<INPUT TYPE="hidden" NAME="ProgramControl_Panel_Options_ID" VALUE="0">
<INPUT TYPE="hidden" NAME="selGeneric_Text" VALUE="">
</form>



</body>
</html>
<cfoutput>
	<script>
	<!--
	function sendScriptPTS() {
		/*if (document.all.hiBit.value != '') 
		{
			document.all.hiBit.value = ''
		}*/
		if(confirm("Press OK if all Program information is correct"))
		{
			MyForm.submit()
		}
	}
	//-->
	</script> 
</cfoutput>


