/*
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
*/

/* If "prototype" is not loaded, load "jquery". Loading both causes issues. */
if (typeof Prototype == "undefined") {
	/* Load "jquery", if it is not already loaded. */
	(window.jQuery  ||  (document.write('<script type="text/javascript" src="/script/javascript/ajax_js/jquery-1.7.2-min.js"><\/script>')) );
}

function isParentObject(thisObj, parentObject)
{
	var objProper = false;
	if(thisObj)
	{
		if(thisObj.tagName)
		{
			objProper = true;
		}
	}
	if(thisObj.parentElement && objProper)
	{
		if(thisObj == parentObject)
		{
			return true;
		}
		else if(thisObj.tagName.toLowerCase() == "body")
		{
			return false;
		}
		else
		{
			return isParentObject(thisObj.parentElement, parentObject);
		}
	}
	else if(thisObj == parentObject)
	{
		return true;
	}
	return false;
}


function getParentObject(thisObj, tagName)
{
	var objProper = false;
	if(thisObj)
	{
		if(thisObj.tagName)
		{
			objProper = true;
		}
	}

	if(objProper)
	{
		if(thisObj.tagName.toLowerCase() == tagName.toLowerCase())
		{
			return thisObj;
		}
		else if(thisObj.tagName.toLowerCase() == "body")
		{
			return null;
		}
		else
		{
			return getParentObject(thisObj.parentElement, tagName);
		}
	}
	else if(thisObj)
	{
		if(thisObj.parentElement)
		{
			return getParentObject(thisObj.parentElement, tagName);
		}
	}
	return thisObj;
}


function getTotalOffsetProperty(thisObj, tagName, sProperty, addValues, oStopBeforeObject)
{
	var oStopBeforeObj;
	if(oStopBeforeObject)
	{
		oStopBeforeObj = oStopBeforeObject;
	}
	addValues = addValues + eval("thisObj." + sProperty);
	if(thisObj && thisObj.tagName)
	{
		if(thisObj.tagName.toLowerCase() == tagName.toLowerCase())
		{
			return addValues;
		}
		else if(thisObj.tagName.toLowerCase() == "body")
		{
			return addValues;
		}
		else if(oStopBeforeObj == thisObj)
		{
			addValues = addValues - eval("thisObj." + sProperty);
			return addValues;
		}
		else
		{
			return getTotalOffsetProperty(thisObj.offsetParent, tagName, sProperty, addValues, oStopBeforeObj);
		}
	}
}
function disableClass(className, bDis){
	
	var obj = jQuery(className);
	obj.disabled = bDis;
	obj.slideDown();
	var s = jQuery(className).html();
	//alert(s);
	jQuery(obj).find('a').each(function()
		{
			//jQuery(this).hide();
			//alert(this.tagName);
			disableA(jQuery(this).get(0));
		});
	jQuery(obj).find('img').each(function()
		{
		   jQuery(this).get(0).onclick = new Function ("return false;");
		   jQuery(this).get(0).title = '';
		   //jQuery(this).get(0).src='';
		   // jQuery(this).get(0).style.display = "none";
		});
	
}
///////disable div
function disableDiv(divName,bDis,bHide)
{ 
	if(typeof divName === 'object')
	{  
		oDiv = divName;
	}
	else
	{  
		oDiv =	document.getElementById(divName);
	}
	if(oDiv)
	{ 
		oDiv.disabled = bDis;

/* $(oDiv).find('*') is equivalent to "oDiv.all". ".all" for objects has been removed from IE 11 onwards. */
jQuery(oDiv).find('*').each(function() {

		jQuery(this).attr('disabled', bDis);

		/* If this is an input box */
		if(jQuery(this).is("input"))
		{
			if(bDis){
				/* Note: "input" below needs to be in lower case. */
				jQuery(this).css("background-color","cccccc");
			}
			else{
				jQuery(this).css("background-color","ffffff");
			}
		}

		/* If this is an select box */
		if(jQuery(this).is("select"))
		{
			if(bDis){
				jQuery(this).css("background-color","cccccc");
				//jQuery(this).prop('selectedIndex', 0);
			}
			else{
				jQuery(this).css("background-color","ffffff");

					/*
					if(jQuery(this).children('option').length > 0)
					{
						jQuery(this).prop('selectedIndex', 0);
					}
					*/
			}
		}
});


		var args = arguments;
		var argLen = args.length;
		if(argLen <3)
		{
			return;
		}
		if(args[2])
		{
			oDiv.style.display = "none";
		}
		else
		{
			oDiv.style.display = "";
		}
		if(argLen <4)
		{
			return;
		}
		var parObj = document.getElementById(args[3]);


		if(args[2])
		{
			parObj.style.display = "none";
		}
		else
		{
			parObj.style.display = "";
		}
	}
}

///////disable button
function disableButton(divName,bDis)
{
	if(typeof divName === 'object')
	{
		oDiv = divName;
	}
	else
	{
		oDiv =	document.getElementById(divName);
	}
	if(oDiv)
	{
		if(oDiv.length)
		{
			var i;
			for(i=0;i<oDiv.length;i++)
			{
				disableButtonOneDivAtATime(oDiv[i], bDis);
			}
		}
		else
		{
			disableButtonOneDivAtATime(oDiv, bDis);
		}
	}
}
function disableButtonOneDivAtATime(oDiv, bDis)
{
	oDiv.disabled = bDis;

	var browser = getBrowser();
	//alert(browser.name + '  ::  ' + browser.version);
   if(browser.name = 'MSIE' && (browser.version < 10 || browser.version == '')){
	   	var i,itemLen = oDiv.all.length;
		//alert('OLD');
		for(i=0;i<itemLen;i++)
		{
			if(oDiv.all[i].tagName == "A")
			{
				if(bDis)//disable
				{
					disableA(oDiv.all[i]);
				}
				/*
				commented because not tested properly, theer was need at the time :)
				else
				{
					if(oDiv.all[i].oldonclick)
					{
						oDiv.all[i].onclick = oDiv.all[i].oldonclick;
						oDiv.all[i].oldonclick = "";
					}
				}
				*/
			}
		}
   }
   else{ //10 or 11
   		//alert('NEW');
   		jQuery(oDiv).find('a').each(function()
		{
			disableA(jQuery(this).get(0));
		});

   }

}
function getBrowser() {
    var userAgent = navigator.userAgent,
        matched = userAgent.match(/(chrome|firefox|opera|safari|msie|trident(?=\/))\/?\s*(\d+)/i) || [],
        version,
        browser = { name: '', version: '' };

    // IE Shells; I gaurantee that you will see this with Dell branded OEM IE 11 installs.
    if(/trident/i.test(matched[1])) {
        version = /\brv[ :]+(\d+)/g.exec(userAgent) || [];

        return { name: 'MSIE', version: (version[1] || '') };
    }

    // Not Chrome; at first glance this looks like a block for chrome identification, but
    // its actually Opera.
    if(matched[1] === 'Chrome') {
        version = userAgent.match(/\b(OPR|Edge)\/(\d+)/);

        if(version !== null) {
            return { name: version[1].replace('OPR', 'Opera'), version: version[2] };
        }
    }

    // The rest; Chrome, Safari, etc
    matched = matched[2] ? [matched[1], matched[2]] : [navigator.appName, navigator.appVersion, '-?'];

    if((version = userAgent.match(/version\/(\d+)/i)) !== null) {
        matched.splice(1, 1, version[1]);
    }

    browser.name = (matched[0] !== "") ? matched[0] : "Unknown";
    browser.version = (matched[1] !== "") ? matched[1] : "Unknown";

    return browser;
}


function disableA(oAnchor)
{
	oAnchor.oldonclick = oAnchor.onclick;
	oAnchor.onclick = new Function ("return false;");
	oAnchor.oldCursor = oAnchor.style.cursor;
	oAnchor.style.cursor = "default";
	oAnchor.oldTextDecoration = oAnchor.style.textDecoration;
	oAnchor.style.textDecoration = "none";
	oAnchor.style.color ="grey";
}

function disableEnableAnchor(anchorObj, disable){
	if(disable){
		var h_ref = anchorObj.getAttribute("href");
			if(h_ref && h_ref != "" && h_ref != null){
				anchorObj.setAttribute('h_ref', h_ref);
			}
		var o_nclick = anchorObj.getAttribute("onclick");
			if(o_nclick && o_nclick != "" && o_nclick != null){
				anchorObj.setAttribute('o_nclick', o_nclick);
			}
			//alert(anchorObj.onclick);
		/* Disable the link */
		anchorObj.setAttribute("href","");
		anchorObj.setAttribute("onclick","");
		anchorObj.style.color="gray";
		anchorObj.style.textDecoration="none";
	}
	else{
		/* Enable the link.
		Note: The link works with "anchorObj.attributes["href"].nodeValue" and not "h_ref".
		*/
		anchorObj.setAttribute("href", anchorObj.getAttribute["h_ref"]);
		anchorObj.setAttribute("onclick", anchorObj.getAttribute["o_nclick"]);
		anchorObj.style.color="blue";
	}
}

// onPaste="javaScript: return textareaChecklength(4000, this);" onkeyPress="javaScript: return textareaChecklength(4000, this);"
function textareaChecklength(maxLen, thisObj, trimTillLastChar)
{
	var bStop = 0;
	var clipBoardText = "";
	var subtractLen = 0;

	/* IE 11 and above */
	if (document.getSelection){
		var rngObj = document.getSelection();
	}
	else{
		var rngObj = document.selection.createRange();
	}

	if(rngObj)
	{
		/* IE 11 and above */
		if (document.getSelection){
			var parEem = rngObj.anchorNode
		}
		else{
			var parEem = rngObj.parentElement();
		}

		if(parEem)
		{
			if(parEem.name == "Contract_Title")
			{
				if(rngObj.text)
				{
					subtractLen = rngObj.text.length;
				}
			}
		}
	}
	switch(event.type.toLowerCase())
	{
		case "paste":
			if(window.clipboardData)
			{
				clipBoardText = window.clipboardData.getData("Text");
			}

			if(thisObj.value.length > maxLen)
			{
				bStop = 1;
			}
			else if((thisObj.value.length + clipBoardText.length - subtractLen) > maxLen)
			{
				bStop = 2;
			}
		case "keypress":
			if((thisObj.value.length - subtractLen) >= maxLen)
			{
				bStop = 1;
			}
			break;
	}



	if(bStop == 2)
	{
		var fieldValue = thisObj.value + clipBoardText;
		fieldValue = fieldValue.substr(0, maxLen);

		if(trimTillLastChar)
		{
			var lastColon = fieldValue.lastIndexOf(trimTillLastChar);
			if(lastColon > 0)
			{
				fieldValue = fieldValue.substring(0, lastColon);
			}
		}
		thisObj.value = fieldValue;
	}

	if(bStop == 0)
	{
		return true;
	}
	else
	{
		window.event.returnValue = false;
		window.event.cancelBubble = true;
		return false;
	}
}

function highlightRowCol(thisObj, toColor, rowStart, currCellColor)
{
	var colTrObj = getParentObject(thisObj, "tr");
	var cellIndex = thisObj.cellIndex;
	var rowIndex = colTrObj.rowIndex;
	var tabObj = getParentObject(thisObj, "table");
	var oRows = tabObj.rows;
	var iCount, i;

	if(!currCellColor)
	{
		currCellColor = toColor;
	}

	/// change color for the row
	iCount = colTrObj.cells.length;
	for(i=0;i<iCount;i++)
	{
		colTrObj.cells[i].style.backgroundColor = toColor;
		if(i == cellIndex)
		{
			break;
		}
	}

	///// change color for the column
	iCount = oRows.length;
	for(i=rowStart;i<iCount;i++)
	{
		oRows[i].cells[cellIndex].style.backgroundColor = toColor;
		if(i == rowIndex)
		{
			break;
		}
	}
	thisObj.style.backgroundColor = currCellColor;

}

function changeDisableOtherObjects(thisObj, OtherObjs)
{
	var i;
 if(OtherObjs)
 {
	if(OtherObjs.length)
	{
		for(i=0;i<OtherObjs.length;i++)
		{
			OtherObjs[i].disabled = !(thisObj.checked);
		}
	}
	else
	{
		OtherObjs.disabled = !(thisObj.checked);
	}
 }
}

/* Use the below only when the disabling object is a select box */
function changeDisableOtherObjectSelect(thisObj, OtherObjs)
{
	var i;
	if(OtherObjs)
	{
		OtherObjs.disabled = !(thisObj.checked);
	}
}

/* This function can be used for IE 10 to get the "firstChild".
For IE 10, the firstChild is the TextNode and so "firstChild.nextSibling"
needs to be used.
IE 10 = firstChild.nextSibling
IE 9 and below = firstChild
*/
function getFirstChild(el){
  var firstChild = el.firstChild;
  while(firstChild != null && firstChild.nodeType == 3){ // skip TextNodes
    firstChild = firstChild.nextSibling;
  }
  return firstChild;
}

/* This function can be used for IE 10 to get the "childNodes".
This should work for all versions of IE.
*/
 function getChildNodes (obj) {
   var x = new Array();
    for (var i = 0; i < obj.childNodes.length; i++) {
	/* Get child nodes */
	var child = obj.childNodes[i];
	/* IE 10 even considers TextNodes as a child. We need to skip TextNodes.
	Even space by itself can be considered as text. eg:
	If we have <tr><td>test</td></tr> or even  <tr><td> </td></tr>
	In this case, there should be just 1 childNode of tr, which is one td.
	IE 10 will also consider "test" as a child as TextNodes are also included.
	IE 10 will also consider space just by itself as a child inside the td above as textNode.
	Below we are exluding the child nodes.
	Note: nodeType == 1 is an element node.
	Adding child.nodeType == 1, instead of child.nodeType != 3 also works.
	*/
		if (child.nodeType != 3) { // skip TextNodes
			x.push(child)
		}
    }
    return x;
}

if (!Array.prototype.indexOf) {
		Array.prototype.indexOf = function(obj, start) {
         for (var i = (start || 0), j = this.length; i < j; i++) {
             if (this[i] === obj) { return i; }
         }
         return -1;
    };
}

function callfireEvent(docRoot,docPath,eventName)
{
	/*
	"docRoot" can be "document" or "opener.document" etc.
	"docPath" can be "opener.document.all.FixedComponents.Vendor_ID" etc.
	"eventName" passed can be "Change" or "Click" etc.
	*/

	/* eventName becomes "onChange" or "onClick" etc for IE 9. */
	var evtIE9 = 'on' + eventName;

	/* eventName becomes "change" or "click" etc for IE 9, i.e. lowercase characters. */
	var evtIE10 = eventName.toLowerCase();

	/* On IE 10 and beyond, "change" event is not fired until we use HTMLEvents code. This code does not work on IE 9. */
	if ("createEvent" in docRoot) {
		var evt = docRoot.createEvent("HTMLEvents");
		evt.initEvent(evtIE10, false, true);

		docPath.dispatchEvent(evt);
	}
	/* This code already existed and we will continue to use it for IE 9 and below. */
	else{
		docPath.fireEvent(evtIE9);
	}


	/* Note: If this function was not dynamic and would be called from a specific scenario, the code would
	look like the folowing:
	*****************************************************************************************************
	On IE 10 and beyond, "change" event is not fired until we use "HTMLEvents". This does not work on IE 9.
	-------------------------------------------------------------------------------------------------------
	if ("createEvent" in document) {
		var evt = document.createEvent("HTMLEvents");
		evt.initEvent("change", false, true);
		document.all.FixedComponents.Vendor_ID.dispatchEvent(evt);
	}
	 This code already existed and we will continue to use it for IE 9 and below.
	 ----------------------------------------------------------------------------
	else
		document.all.FixedComponents.Vendor_ID.fireEvent('onChange');
	}
	*****************************************************************************************************
	*/
}

function checkOrUncheckBeforeFireEvent(action)
{
	var bChecked;

		/* For IE 10 and above */
		if ("createEvent" in document && navigator.appVersion.indexOf("Chrome") == -1){
			/* REMOVE ALL SELECTED ITEMS */
			if(action == 0){
				/*
				For IE 11, if we uncheck the checkbox (select all), then when we use the "callfireEvent",
				the checkbox (select all) gets checked and so we do not want to use "false".
				For IE 11, we want to use "true" instead. This way all the selected checkboxes
				will be unselected as IE 11 treats "callfireEvent" as a separate action - eg:click,change etc.
				IE 10 can work with the checkbox being checked or unchecked. */
				bChecked = true;
			}
			/* CHECK (SELECT) ALL ITEMS */
			else{
				/*
				For IE 11, if we check the checkbox (select all), then when we use the "callfireEvent",
				the checkbox (select all) gets unchecked and so we do not want to use "true".
				For IE 11, we want to use "false" instead.This way all the checkboxes
				will be selected as IE 11 treats "callfireEvent" as a separate action - eg:click,change etc.
				IE 10 can work with the checkbox being checked or unchecked. */
				bChecked = false;
			}
		}

		/* For IE 9 and below */
		else{
		/* For IE 9, we need to uncheck the checkbox (select all).
		Then when the "callfireEvent" is executed, all the checkboxes are unchecked.
		*/
			/* REMOVE ALL SELECTED ITEMS */
			if(action == 0){
				bChecked = false;
			}
		/* For IE 9, we need to check the checkbox (select all).
		Then when the "callfireEvent" is executed, all the checkboxes are checked.
		*/
			/* CHECK (SELECT) ALL ITEMS */
			else{
				bChecked = true;
			}
		}

	return bChecked;
}

function showHideFilters(idObj1,idObj2)
{
	if(document.getElementById(idObj1).style.display == 'none'){
		document.getElementById(idObj1).style.display = '';
		document.getElementById(idObj2).src = '/images/nolines_minus.gif';
	}
	else{
		document.getElementById(idObj1).style.display = 'none';
		document.getElementById(idObj2).src = '/images/nolines_plus.gif';
	}
}

/* Pass "URL Param" and the "URL". Get back the "URL param" value. */
function getUrlParameterValue(url_param,url_path) {
	url_param = url_param.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
	var regex = new RegExp('[\\?&]' + url_param + '=([^&#]*)');
	var results = regex.exec(url_path);
return results === null ? '' : decodeURIComponent(results[1].replace(/\+/g, ' '));
}