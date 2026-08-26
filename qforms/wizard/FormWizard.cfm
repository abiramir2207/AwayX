<CFSETTING ENABLECFOUTPUTONLY="YES">
<!---// set default attributes //--->
<CFPARAM NAME="Attributes_JS_WDDX" DEFAULT="/cfide/scripts/wddx.js">
<CFPARAM NAME="Attributes_JS_WDDXFORMWIZARD" DEFAULT="wddxFormWizard.js">
<CFPARAM NAME="Attributes_FORMNAME" DEFAULT="document.wddxFormWizard">
<CFPARAM NAME="Attributes_EXCLUDE" DEFAULT="">
<CFPARAM NAME="Attributes_WDDXFIELDNAME" DEFAULT="wddxPacket">
<CFPARAM NAME="Attributes_SHOWDEBUG" DEFAULT="NO">
<CFPARAM NAME="Attributes_SHOWNAVIGATION" DEFAULT="NO">
<CFPARAM NAME="Attributes_SHOWBUTTONS" DEFAULT="BACK,RESET,NEXT">
<CFPARAM NAME="Attributes_BTN_NEXT" DEFAULT="Next &gt;">
<CFPARAM NAME="Attributes_BTN_BACK" DEFAULT="&lt; Back">
<CFPARAM NAME="Attributes_BTN_RESET" DEFAULT="Reset">
<CFPARAM NAME="Attributes_BTN_FINISH" DEFAULT="Finish">
<CFPARAM NAME="Attributes_FINISH_URL" DEFAULT="">
<CFPARAM NAME="Attributes_SAVEONBACK" DEFAULT="YES">

<!---// set default variables //--->
<CFSCRIPT>
// formWizard configuration info
formWizard_Version = "1.1";

// check to see if the form should be saved when going back to a previous form
if( YesNoFormat(Attributes_SAVEONBACK) ){
	strGoBackFunction = "goBack();";      // save form
} else {
	strGoBackFunction = "goBack(false);"; // don't save form
}

stcVariables = StructNew();
stcVariables["BACK"] = "<INPUT TYPE=""Button"" VALUE=""#Attributes_BTN_BACK#"" onClick=""#strGoBackFunction#"">";
stcVariables["RESET"] = "<INPUT TYPE=""Reset"" VALUE=""#Attributes_BTN_RESET#"">";
stcVariables["NEXT"] = "<INPUT TYPE=""Button"" VALUE=""#Attributes_BTN_NEXT#"" onClick=""goForward();"">";
stcVariables["FINISH"] = "<INPUT TYPE=""Button"" VALUE=""#Attributes_BTN_FINISH#"" onClick=""goToURL('#Trim(Attributes_FINISH_URL)#');"">";
</CFSCRIPT>

<!---// if there is a WDDX packet passed through the form scope, use it //--->
<CFIF IsDefined("FORM.#Attributes_WDDXFIELDNAME#")>
	<CFSET SetVariable("Variables.wddxPacket", Evaluate("FORM.#Attributes_WDDXFIELDNAME#"))>
	<CFWDDX ACTION="WDDX2JS" INPUT="#Variables.wddxPacket#" TOPLEVELVARIABLE="wddxPacket" OUTPUT="objWDDX">
<!---// check to see if the user specified a WDDX packet to use //--->
<CFELSEIF IsDefined("Attributes_wddxPacket") AND (Left(LTrim(LCase(Attributes_wddxPacket)), 12) EQ "<wddxpacket ")>
	<CFWDDX ACTION="WDDX2JS" INPUT="#Attributes_wddxPacket#" TOPLEVELVARIABLE="wddxPacket" OUTPUT="objWDDX">
<!---// otherwise, use a new structure //--->
<CFELSE>
	<CFSET stcWizard = StructNew()>
	<CFSET stcWizard["totalforms"] = 0>
	<CFWDDX ACTION="CFML2JS" INPUT="#stcWizard#" TOPLEVELVARIABLE="wddxPacket" OUTPUT="objWDDX">
</CFIF>

<!---// insert JavaScript code in between the <HEAD></HEAD> tags //--->
<CFHTMLHEAD TEXT="
<!--// load the WDDX library //-->
<SCRIPT SRC=""#Attributes_JS_WDDX#""></SCRIPT>
<!--// load the Form Wizard library //-->
<SCRIPT SRC=""#Attributes_JS_WDDXFORMWIZARD#""></SCRIPT>
<SCRIPT>
<!--//
// create the global variables
var myForm, myField, myPacketName, myRecordset, lstExcludeFields, iFormPOS;

function initWDDX(){
	// create the pointer to the form object on the page
	myForm = #Attributes_FORMNAME#;
	// create the pointer to the hidden field on the page, that will be used for the WDDX packet
	myPacketName = ""#Attributes_WDDXFIELDNAME#"";
	// create the pointer to the WDDX recordset (this should be equal to the ""TopLevelVariable""
	// which is set in the CFWDDX tag
	myRecordset = wddxPacket;
	// specify a list of fields to ignore
	lstExcludeFields = ""#Attributes_EXCLUDE#"";

	// do not change the following statements
	myField = eval(""myForm."" + myPacketName);
	
	// check to see if the current form is in the WDDX packet
	iFormPOS = checkForForm();
	
	// populate the fields if any fields are found in the WDDX packet
	populateFields();
	
}

// the WDDX packet array
#objWDDX#

// append the initWDDX() function to the body's onLoad event
window.onload = initWDDX; 
/*
if( window.onload != null ){
	window.onload = eval(""window.onload();initWDDX""); 
} else {
	window.onload = initWDDX; 
}
*/
//-->
</SCRIPT>
">
<CFSETTING ENABLECFOUTPUTONLY="NO">
<INPUT TYPE="Hidden" NAME="<CFOUTPUT>#Attributes_WDDXFIELDNAME#</CFOUTPUT>" VALUE="">
<CFLOOP INDEX="button" LIST="#Attributes_SHOWBUTTONS#">
<CFOUTPUT>#stcVariables[button]#
</CFOUTPUT></CFLOOP>

<SCRIPT><!--//
<CFIF YesNoFormat(Attributes_SHOWDEBUG)>showDebug();</CFIF>
<CFIF YesNoFormat(Attributes_SHOWNAVIGATION)>showNavigation();</CFIF>
//--></SCRIPT>
