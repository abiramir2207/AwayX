/*
	Title: Mass Update Functions for UserProfiles
	Author: Clarence Morse
	Date: 2/27/2006
	Description: Contains all Mass Update functions.
	Abbreviations: mU control - Master MassUpdate Control for the Row.
*/
function massUpdate( ctrlType, ctrlName, ctrlValue ) {
	/* Contains all logic to work radio controls */
	if(ctrlType == "radio")
		massUpdateRadio(ctrlName, ctrlValue);
	/* Contains all logic to work checkbox controls */
	else if (ctrlType == "checkbox")
		massUpdateCheckbox(ctrlName, ctrlValue);
	/* Contains all logic to work textbox controls */
	else 
		massUpdateTextBox(ctrlName, ctrlValue);
}

/* 
	MassUpdateRadio Implementation 
   The radio function always sets the radio value 
   of matching attributes to checked (unless they're disabled). 
*/
function massUpdateRadio (ctrlName, ctrlValue) { 
	var ctrl_element   = document.getElementById( ctrlName );
	var parent_element = getParentObject(ctrl_element, "tr");
	// get all input elements under tr tag
	var input_elements = parent_element.getElementsByTagName( "input" );
	
	// skip 1st input element (which is control element)
	for (var i = 1; i < input_elements.length; i++) {
		var masscontrolid = ( input_elements[i].getAttribute("masscontrolid") 
								? input_elements[i].getAttribute("masscontrolid")
								: input_elements[i].getAttribute("MASSCONTROLID") );
		// get the mass apply element in the header
		var mass_apply_element = document.getElementById( masscontrolid );
		// copy control element status
		if ( mass_apply_element && mass_apply_element.checked && !input_elements[i].disabled ) {
			input_elements[i].checked = ctrl_element.checked;
		}
	}
}

/* 
	MassUpdateCheckbox Implementation 
   	The checkbox function always sets the checkbox value 
   	of matching attributes to state of the mU control (unless they're disabled). 
*/
function massUpdateCheckbox (ctrlName, ctrlValue) { 
	var ctrl_element   = document.getElementsByName( ctrlName )[0];
	var parent_element = getParentObject(ctrl_element, "tr");
	// get all input elements under tr tag
	var input_elements = parent_element.getElementsByTagName( "input" );

	// skip 1st input element (which is control element)
	for (var i = 1; i < input_elements.length; i++) {
		var masscontrolid = ( input_elements[i].getAttribute("masscontrolid") 
								? input_elements[i].getAttribute("masscontrolid")
								: input_elements[i].getAttribute("MASSCONTROLID") );
		// get the mass apply element in the header
		var mass_apply_element = document.getElementById( masscontrolid );
		// copy control element status
		if ( mass_apply_element && mass_apply_element.checked && !input_elements[i].disabled ) {
			input_elements[i].checked = ctrl_element.checked;
		}
	}
}

/* 
	MassUpdateTextBox Implementation 
   	The textbox function always sets the checkbox value 
   	of matching attributes to value of the mU control (unless they're disabled). 	
*/
function massUpdateTextBox (ctrlName, ctrlValue) { 
//<!--
		var ctrl_element   = document.getElementsByName( ctrlName )[0];
		var parent_element = getParentObject(ctrl_element, 'tr');
		var input_elements = parent_element.getElementsByTagName("input");
		
		for (var i = 0; i < input_elements.length; i++)
		{
			if( input_elements[i].getAttribute("massupdateid") == ctrlName || input_elements[i].getAttribute("MASSUPDATEID") == ctrlName )
			{ 
				if(input_elements[i].disabled == false && eval("document.all." + input_elements[i].masscontrolid + ".checked")  == true)
				{
					input_elements[i].value = document.getElementById(ctrlName).value;
				}
			}
		}
//-->
}


//Dev Note: Drachala; D27781: 7.0 new bb profile settings --->

function checkview(pid){
	var check_box = document.MyForm.elements["BB_Create_"+pid];
		if(check_box[2].checked)
		{
			document.getElementById("BB_closing_methods_view_"+pid).style.display="none";
			document.getElementById("BBD_closing_methods_view_"+pid).style.display="none";
			document.getElementById("BBDR_closing_methods_view_"+pid).style.display="block";
		}
	    else{
			document.getElementById("BB_closing_methods_view_"+pid).style.display="none";
			document.getElementById("BBDR_closing_methods_view_"+pid).style.display="none";
			document.getElementById("BBD_closing_methods_view_"+pid).style.display="block";
		}
	
}
// Dev Note: Drachala; D27781: 7.0 new bb profile settings
// Dev Note: Drachala; D27926: Billback Profile Settings
function enable_disable(counter){
	var Delete_check_box = document.MyForm.elements["BB_Delete_"+counter];
	var Approve_check_box = document.MyForm.elements["BB_Approve_"+counter];
	if(Delete_check_box.checked == true ){
		document.getElementById("BB_Mass_Delete_"+counter).disabled = false;
	}
	else if(Delete_check_box.checked == false){
		document.getElementById("BB_Mass_Delete_"+counter).disabled = true;
	}
	
	if(Approve_check_box.checked == true ){
		document.getElementById("BB_Mass_Approve_"+counter).disabled = false;
	}
	else if(Approve_check_box.checked == false){
		document.getElementById("BB_Mass_Approve_"+counter).disabled = true;
	}
}
// Dev Note: Drachala; D27926: Billback Profile Settings

