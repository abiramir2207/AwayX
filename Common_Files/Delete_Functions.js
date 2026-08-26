/*
<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>
*/

/* If "prototype" is not loaded, load "jquery". Loading both causes issues. */
if (typeof Prototype == "undefined") {
	/* Load "jquery", if it is not already loaded. */
	(window.jQuery  ||  (document.write('<script type="text/javascript" src="/script/javascript/ajax_js/jquery-1.7.2-min.js"><\/script>')) );
}


function trim(sStr)
{
	return sStr.replace(/^\s*/ig, "").replace(/\s*$/ig, "");
}

function propogateProperty(oObj, bProperty, bValue, bCheckEmpty, bInput)
{
	var bChange;
	var checkInput = false;
	if (arguments.length > 4)
	{
		checkInput = bInput;
	}
	setProprtyForThisObj(oObj, bProperty, bValue, bCheckEmpty, checkInput);

	/* $(oObj).find('*') is equivalent to "oObj.all". ".all" cannot be used for objects from IE 11 onwards. */
	$(oObj).find('*').each(function() {
		setProprtyForThisObj($(this).get(0), bProperty, bValue, bCheckEmpty, checkInput);

	});
}

function setProprtyForThisObj(thisObj, bProperty, bValue, bCheckEmpty, checkInput)
{
	bChange = true;
	if(!bCheckEmpty || trim(thisObj.innerText).length > 0)
	{
		if (checkInput)
		{

			if(!(thisObj.tagName == "INPUT" || thisObj.tagName == "OPTION" || thisObj.tagName == "SELECT"))
			{
				bChange = false;
			}
			else if(thisObj.tagName == "INPUT" && thisObj.type != "text")
			{
				bChange = false;
			}
		}
		if(bChange)
		{
			eval("thisObj." + bProperty + " = \"" + bValue + "\"");
		}
	}
}
/*
Dependency: getParentObject()
file:
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
*/
var deleteImg = new Image();
deleteImg.src = "/Images/scissor.gif";
var undodeleteImg = new Image();
undodeleteImg.src = "/Images/undo.gif";

function checkboxIsChecked(chNameStart, imgObj)
{
	var returnValue = false;
	var trObj = getParentObject(imgObj, "tr");
	var inpObjs = trObj.getElementsByTagName("input");
	var inpLen = inpObjs.length;
	if(inpLen)
	{
		for(i=0;i<inpLen;i++)
		{
			if(Is_This_Input_Checked(inpObjs[i], chNameStart))
			{
				returnValue = true;
				break;
			}
		}
	}
	else
	{
		if(Is_This_Input_Checked(inpObjs, chNameStart))
		{
			returnValue = true;
		}
	}
	return returnValue;
}

function Is_This_Input_Checked(inpObj, chNameStart)
{
	var returnValue = false;
	if(inpObj.type == "checkbox")
	{
		var inpobjName = inpObj.name;
		if(inpobjName.substr(0, chNameStart.length) == chNameStart)
		{
			if(inpObj.checked)
			{
				returnValue = true;
			}
		}
	}
	return returnValue;
}

function deleteAll(chNameStart)
{
	var checkCheckbox = 'false';
	if(chNameStart)
	{
		checkCheckbox = 'true';
	}
	var deleteObjs = document.getElementsByName("IMG_Delete_Scissor");
	var i, deleteObjLen;
	var bDelete = event.srcElement.getAttribute('bDelete');

	deleteObjLen = deleteObjs.length;
	if(deleteObjLen)
	{
		for(i=0;i<deleteObjLen;i++)
		{
			if(bDelete + "" == deleteObjs[i].getAttribute('bDelete') + "")
			{
				if((bDelete == 'false' || checkCheckbox == 'false' || checkboxIsChecked(chNameStart, deleteObjs[i])) && chNameStart != 'check_Each')
                {
					deleteObjs[i].click();
				}
				else if (chNameStart == 'check_Each')
				{
					deleteObjs[i].click();
				}
			}
		}
	}
	else
	{
		if(bDelete + "" == deleteObjs.getAttribute('bDelete') + "")
		{
			if(bDelete == 'false' || checkCheckbox == 'false' || checkboxIsChecked(chNameStart, deleteObjs))
			{
				deleteObjs.click();
			}
		}
	}

	if(bDelete == 'true')
	{
		event.srcElement.title = "undo " + event.srcElement.getAttribute('sMessage');
		event.srcElement.src = undodeleteImg.src;
	}
	else
	{
		event.srcElement.title = event.srcElement.getAttribute('sMessage');
		event.srcElement.src = deleteImg.src;
	}
	/* The reason why "bDelete" is a string and not a boolean is because "setAttribute" can only set a string value and not a boolean. */
	event.srcElement.setAttribute('bDelete',(bDelete == 'true'?'false':'true'));
}
