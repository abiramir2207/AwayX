/*
Id: /debug.js, v1.3.1 11/8/00 9:47:36 AM dbabbitt
Description: These scripts aid in plumbing the 
             DOM.
*/

// Usage: 
// getAttributesWindow('Check this out!', myObjectName));

function getNumberAttributes(title, debugObject) {
	/* lists all the integer attributes associated with debugObject in a separate window */
	msgWindow = window.open('','attributeWindow','');
	msgWindow.document.write('<H1>' + title + '</H1>\n<UL>\n');
	for(var i in debugObject) {
		var valueString = debugObject[i];
		if(typeof(valueString) == 'object') {
			// var strValueString = ': ' + valueString;
			// if(strValueString!=': null') {
				// msgWindow.document.write('\t<LI CLASS="OITEM"><b>[' + i + ']</b>' + strValueString + '<UL>\n');
				// for(var j in debugObject) {
					// valueString2 = debugObject[j];
					// if(!isNaN(parseInt(valueString2, 10))) {
						// msgWindow.document.write('\t\t<LI CLASS="OITEM"><b>' + i + '.' + j + '</b>: ' + valueString2 + '</LI>\n');
						// }
					// }
				// }
			// msgWindow.document.write('</UL></LI>\n');
			}
		else {
			if(!isNaN(parseInt(valueString, 10))) {
				msgWindow.document.write('\t<LI CLASS="OITEM"><b>' + i + '</b>: ' + valueString + '</LI>\n');
				}
			}
		}
	msgWindow.document.write('</UL>\n');
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

function getChildrenWindow(debugObject) {
	/* lists all the children of debugObject in a separate window */
	msgWindow = window.open('','attributeWindow','');
	msgWindow.document.write('<dl>&lt;' + debugObject.tagName + '&gt;\n');
	var position = debugObject.sourceIndex;
	while(debugObject.contains(document.all[++position])) {
		msgWindow.document.write('<dd>\n');
		getChildrenWindow(document.all[position]);
		msgWindow.document.write('</dd>\n')};
	msgWindow.document.write('</dl>\n')};
	
	
function getParent(src, tagName) {
	/* Returns the closest parent tag with tagName containing */
	/* the src tag. If no such tag is found - null is returned. */
	while(src != null) {
		if(src.tagName == tagName) {
			return src};
		src = src.parentElement};
	return null}
	
function getParentsWindow(debugObject) {
	/* lists all the parents of debugObject in a separate window */
	msgWindow = window.open('','attributeWindow','');
	msgWindow.document.write('<dl>&lt;' + debugObject.tagName + '&gt;\n');
	while(debugObject != null) {
		msgWindow.document.write('<dd>&lt;' + debugObject.tagName + '&gt;<dl>\n');
		debugObject = debugObject.parentElement}}

/*
	Log: /debug.js
	Revision 1.3 11/8/00 9:46:52 AM dbabbitt
	Added a get number attributes function 
	for those just searching for integer 
	parameters.
	
	Revision 1.2 10/9/00 9:39:18 PM dbabbitt
	Added a replace lt and gt to the get 
	attributes window function to stop the 
	html from running.
	
	Revision 1.1 10/9/00 9:09:19 PM dbabbitt
	Added an onerror event to the get 
	attributes window function to stop the 
	javascript from running.
	
	Revision 1.0 Tuesday, September 19, 2000 11:30:00 AM dbabbitt
	These scripts aid in plumbing the DOM.
	*/