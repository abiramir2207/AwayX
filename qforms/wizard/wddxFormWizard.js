// this function will serialize the WDDX JavaScript recordset, and store it into
// a hidden variable in the form
function createWDDXPacket(){
	// create serializer object
	mySerializer = new WddxSerializer;

	// serialize WDDX packet
	myPacket = mySerializer.serialize(myRecordset);
	
	// store WDDX packet into the hidden field
	myField.value = myPacket;
}

// check to see if information on the current form is in the WDDX packet
function checkForForm(key){
	// if no key specified, use the current URL
	if(!key) key = self.location;

	var iTotalForms = parseInt(wddxPacket.totalforms);

	// loop through all form fields looking for this form
	for( i=1; i <= iTotalForms; i++ ){
		// if the current page is in the wddx packet, then return the position in the WDDX packet
		if( eval("wddxPacket.form" + i + ".key") == key ){
			return i; // return the position in the WDDX packet
			break;
		}
	}
	
	// if no form info was found, then return null
	return null;
}

function changeForm(key){
	// if no key specified, use the current URL
	if(!key) key = self.location;

	// check to see if the current form is in the WDDX packet
	iFormPOS = checkForForm(key);

	// clear the form
	myForm.reset();

	// populate the fields if any fields are found in the WDDX packet
	// spawn the process off after a millisecond -- fixes Netscape
	setTimeout("populateFields()",1); 
}

function initNewFormObject(key){
	// if no key specified, use the current URL
	if(!key) key = self.location;

	// increase the number of forms
	wddxPacket.totalforms = parseInt(wddxPacket.totalforms) + 1;
	// create structure for this form
	eval("wddxPacket.form" + wddxPacket.totalforms + "=new Object();");
	// create a structure to hold all the form field elements
	eval("wddxPacket.form" + wddxPacket.totalforms + ".form=new Object();");
	// store a unique "key" to define this form (defaults to the current URL)
	eval("wddxPacket.form" + wddxPacket.totalforms + ".key='" + key + "';");
	// store the current URL
	eval("wddxPacket.form" + wddxPacket.totalforms + ".url='" + self.location + "';");
	// store the page's title
	eval("wddxPacket.form" + wddxPacket.totalforms + ".title='" + document.title + "';");
	// return the new position of the form in the WDDX packet
	return wddxPacket.totalforms;
}

function goBack(boolSave){
	// if save isn't specified, assume you should save
	if(!boolSave) boolSave = true;
	
	// if saving, save fields
	if(boolSave) saveFields();
	
	// get the previous form position
	var iPreviousForm = iFormPOS - 1;

	// set the current form action to the URL of the previous form			
	myForm.action = eval("wddxPacket.form" + iPreviousForm + ".url")		
	myForm.submit();
}

function goForward(){
	// save fields
	saveFields();

	// submit form	
	myForm.submit();
}

function goToURL(strURL, boolSave){
	// if save isn't specified, assume you should save
	if(!boolSave) boolSave = true;
	
	// if saving, save fields
	if(boolSave) saveFields();
	
	if(strURL.length == 0) strURL = myForm.action;
	
	// set the current form action to the URL of the previous form			
	myForm.action = strURL;
	myForm.submit();
}

function goToForm(iForm, boolSave){
	// if save isn't specified, assume you should save
	if(!boolSave) boolSave = true;
	
	// if saving, save fields
	if(boolSave) saveFields();
	
	// set the current form action to the URL of the previous form			
	myForm.action = eval("wddxPacket.form" + iForm + ".url");
	myForm.submit();
}

function getPacketArray(){
	var iTotalForms = parseInt(wddxPacket.totalforms);
	var aryPacket = new Array();

	// loop through all form fields looking for this form
	for( i=1; i <= iTotalForms; i++ ){
		var PacketInfo = new Object();
		PacketInfo.title = eval("wddxPacket.form" + i + ".title");
		PacketInfo.key = eval("wddxPacket.form" + i + ".key");
		aryPacket[i-1] = PacketInfo;
	}
	
	// if no form info was found, then return null
	return aryPacket;
}

function showButtons(){
	var d = document;
	d.write("<P>");
	d.write("<INPUT TYPE=\"Button\" VALUE=\"Populate Fields\" onClick=\"populateFields();\">\n");
	d.write("<INPUT TYPE=\"Button\" VALUE=\"Save Fields\" onClick=\"saveFields();\">\n");
	d.write("<INPUT TYPE=\"Button\" VALUE=\"View Packet\" onClick=\"createWDDXPacket();alert(myField.value);\">\n");
	d.write("</P>");
}

function showNavigation(){
	var strURL, strTitle;
	var iTotalForms = parseInt(wddxPacket.totalforms);
	var d = document;

	// if there WDDX packet contains some forms, display the navigation list
	if( iTotalForms > 0 ){
		// output header
		d.write("<P><FONT SIZE=\"+1\"><B>Navigation</B></FONT><BR>");

		// loop through and grab all the page titles
		for( var i=iTotalForms; i >= 1; i-- ){
			strURL = eval("wddxPacket.form" + i + ".url");
			strTitle = eval("wddxPacket.form" + i + ".title");
			d.write("<A HREF=\"\" onClick=\"goToForm('" + i + "'); return false;\">" + strTitle + "</A><BR>");
		}
		
		// end navigation block
		d.write("</P>");
	}
}

function showDebug(){
	var d = document;
	d.write("<P><FONT SIZE=\"+1\"><B>Debug Info</B></FONT><BR>");
	d.write("<INPUT TYPE=\"Button\" VALUE=\"Populate Fields\" onClick=\"populateFields();\">\n");
	d.write("<INPUT TYPE=\"Button\" VALUE=\"Save Fields\" onClick=\"saveFields();\">\n");
	d.write("<INPUT TYPE=\"Button\" VALUE=\"View Packet\" onClick=\"createWDDXPacket();alert(myField.value);\">\n");
	d.write("</P>");
}

function saveFields(key){
	// if no key specified, use the current URL
	if(!key) key = self.location;

	// get the total number of forms in the packet
	var iTotalForms = parseInt(wddxPacket.totalforms);

	// build the list of fields to exclude from the packet, 
	// automatically exclude the hidden form field containing the packet
	lstExcludeFields += "," + myPacketName + ",";
	lstExcludeFields = lstExcludeFields.toLowerCase();
	
	// if the element doesn't already exist, create a new structure
	if( iFormPOS == null ) iFormPOS = initNewFormObject(key);
	
	// pointer to the form structure
	objFormStruct = eval("wddxPacket.form" + iFormPOS + ".form");
	
	var lstFormFields = ""; // list that contains unique form fields
	// loop through all form elements
	for( j=0; j < myForm.elements.length; j++ ){
		// by default do not add value
		boolAddValue = false;
		// current element's name
		strFieldName = myForm.elements[j].name;
		strFieldNameLC = strFieldName.toLowerCase();  // the current elements name in upper case
		
		// check to make sure form field is unique
		if( lstFormFields.indexOf("," + strFieldName) == -1 ){
			// clear the field's structure value
			if(lstExcludeFields.indexOf(strFieldNameLC + ",") == -1) eval("objFormStruct." + strFieldNameLC + "=''");
			// add current field to unique field list
			lstFormFields += "," + strFieldName;
		}

		// if field name is not blank
		if( strFieldNameLC.length > 0 ){
			// get the value of the current field's structure value
			objWDDXStructKey = eval("objFormStruct." + strFieldNameLC);
			// current value to store if necessary
			strValue = myForm.elements[j].value;

			// do not store the wddxPacket or any excluded variables field
			if(lstExcludeFields.indexOf(strFieldNameLC + ",") > -1){
				boolAddValue = false;

			// if field is a checkbox or radio box
			} else if( myForm.elements[j].type == "checkbox" || myForm.elements[j].type == "radio" ){
				if( myForm.elements[j].checked ){
					boolAddValue = true; 
				}

			// if field is a select box
			} else if(  myForm.elements[j].type.substring(0,6) == "select" ){
				// current form element 
				objField = eval("myForm." + strFieldName);
				strValue = "";
				// loop through all element in the array for this field
				for( k=0; k < objField.length; k++ ){
					// if the element is selected, add get the value
					if( objField[k].selected  ){
						// if more then one element already exists, if so comma-delimit the list
						if( strValue.length > 0 ) strValue += ",";
						// append the selected value
						strValue += objField[k].value;
					}
				}
				// if the string is not blank, then add the value
				if( strValue.length > 0 ) boolAddValue = true;

			// anything else, store the value
			} else {
				boolAddValue = true;
			}
			
			// check to see if you should add this value to the WDDX packet
			if( boolAddValue ){
				// check to see if this field already has a value, if so comma-delimit the list
				if( objWDDXStructKey.length > 0 ){
					objWDDXStructKey += ",";
				}
				// append the current field element's value
				objWDDXStructKey += strValue;
				// store the value into the WDDX structure
				eval("objFormStruct." + strFieldNameLC + " = objWDDXStructKey");
			}

		} // end if field name is blank
	} // end for loop (form elements)
	
	// create the WDDX packet
	createWDDXPacket();
}


// populate the form fields with the information in the WDDX packet
function populateFields(){
	var iTotalForms = parseInt(wddxPacket.totalforms);

	// if the current page is in the wddx packet, then populate the fields
	if( iFormPOS != null ){
		var lstFormFields = ""; // list that contains unique form fields
		// loop through all form elements
		for( j=0; j < myForm.elements.length; j++ ){
			strFieldName = myForm.elements[j].name;
			strFieldNameLC = strFieldName.toLowerCase();  // the current elements name in upper case
			if( strFieldName.length > 0 ){
				strValue = eval("wddxPacket.form" + iFormPOS + ".form." + strFieldNameLC);
			} else {
				strValue = "";
			}
			if( strValue == null ) strValue = "";
			
			// check to make sure form field is unique
			if( lstFormFields.indexOf("," + strFieldName) == -1 ){
				// if field is a text box or textarea
				if( (myForm.elements[j].type.substring(0,4) == "text") || (myForm.elements[j].type == "password") || (myForm.elements[j].type == "hidden") ){
					myForm.elements[j].value = strValue;

				// if field is a checkbox
				} else if(  myForm.elements[j].type == "checkbox" ){
					objField = eval("myForm." + strFieldName);
					// if more then 1 checkbox
					if(objField.length > 0){ 
						// loop through all checkbox elements, and if a checkbox is supposed to be checked, check it
						for( k=0; k < objField.length; k++ ){
							strValue += ","; // add ending comma to treat as list
							// store the values of the checkmarked items into a list
							if( strValue.indexOf(objField[k].value + ",") > -1 ) objField[k].checked = true;
						}
					// otherwise, store the value of the field (if checkmarked) into the list
					} else {
						if( myForm.elements[j].value == strValue ) myForm.elements[j].checked = true;
					}

				// if field is a radio button
				} else if(  myForm.elements[j].type == "radio" ){
					objField = eval("myForm." + strFieldName);
					for( k=0; k < objField.length; k++ ){
						if( objField[k].value == strValue ) objField[k].checked = true;
					}

				// if field is a select box
				} else if(  myForm.elements[j].type.substring(0,6) == "select" ){
					objField = eval("myForm." + strFieldName);
					strValue += ","; // add ending comma to treat as list
					for( k=0; k < objField.length; k++ ){
						if( strValue.indexOf(objField[k].value + ",") > -1 ) objField[k].selected = true;
					}
				}
				
				// add current field to unique field list
				lstFormFields += "," + strFieldName;
			} // end if form unique
		} // end for loop (form elements)
	} // end if form fields exist
}
