//appends the value to the array
function ArrayAppend(array,value){
	newItemPosition = eval(array + '.length')
	eval(array + '[' + newItemPosition + ']="' + value + '"')
}

//remove the first instance of the supplied value from the array
function ArrayRemoveItem(array,value){
	
	for(var i=0; i<eval(array +'.length'); i++) {
		if(eval(array + '[' + i + ']') == value){
			    for (var elementnr=i;elementnr<eval(array + '.length');elementnr++) {
			        // assigns the value of elementnr+1 to elementnr, so you move all items by 1
			        eval(array +'['+ elementnr + ']=' + array + '[' + (elementnr + 1) + ']');
			    }
			   		eval(array + '.length=' + array + '.length - 1');
				    // Yes it is as easy as this!
		}
	}
}

//remove the first instance of the supplied value from the array
function ArrayRemoveItemAtPosition(array,position){
			    for (var elementnr=position;elementnr<eval(array + '.length');elementnr++) {
			        // assigns the value of elementnr+1 to elementnr, so you move all items by 1
			        eval(array +'['+ elementnr + ']=' + array + '[' + (elementnr + 1) + ']');
			    }
			   		eval(array + '.length=' + array + '.length - 1');
				    // Yes it is as easy as this!

}

//checks for the existance of value in the array, returns its position if found, -1 if not
function ArrayContains(arrayname,value){
	for(var z=0; z<eval(arrayname + '.length');z++){
		if(eval(arrayname + '['+ z + ']') == value){
			return z;
		}
	}
	return -1;
}	

//returns a list from an array
function ArrayToList(array){
	
	var tempstring = "";
	
	for(var n=0;n<eval(arrayname + '.length');n++){
		if(n == 0){
			tempstring = eval(arrayname + '[' + n + ']');
		}
		else{
			tempstring = tempstring + ',' + eval(arrayname + '[' + n + ']')
		}
	}
	return tempstring;
}

//returns a list from an array of objects
function ObjectArrayToList(array){
	
	if(array.length == 0){
		alert(array)
	}
	
	var tempstring = "";
	
	for(var n=0;n<array.length;n++){
		if(n == 0){
			tempstring = eval('array[' + n + '].value');
		}
		else{
			tempstring = tempstring + ',' + eval('array[' + n + '].value')
		}
	}
	return tempstring;
}
//this function will clear all items from a select box
function ClearSelectBox(selectboxObject) {
	if(eval('document.all.' + selectboxObject + '.length') != 0){
	do
	     {
			eval('document.all.' + selectboxObject + '.options.remove(0)');
	     }
	   while (eval('document.all.' + selectboxObject + '.length') != 0)
	}
}

//Add an option item to a select box
function addOption(object,value, text){
	
	var oOption = document.createElement("OPTION");
	eval('document.all.' + object + '.options.add(oOption)');
	oOption.innerText = text;
	oOption.Value = value;

}
			function SearchArrayForExistingValue(array, value){
				//alert(eval(array + '.length'))
				
				for(var i=0; i<eval(array + '.length'); i++){
					if(eval(array + '[' + i + '].value') == value){
						return i;
					}
				}
				return -1;
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
