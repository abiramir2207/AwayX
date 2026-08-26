//common javascript functions

function showDistributorSearchWindow(formName) 
{
	NewWindow("/billbacks/search_screens/PM_select_distributors.cfm?Formname=" + formName, "distributorwindow", 800, 600, "yes", "yes");
	return false;
}

function showOperatorSearchWindow(formName) 
{
	NewWindow("/billbacks/search_screens/PM_select_operators.cfm?Formname=" + formName, "operatorwindow", 800, 600, "yes", "yes");
	return false;
}

function showProductSearchWindow(formName) 
{
	NewWindow("/common_files/contracts/product_Select_V1.cfm?Formname=" + formName, "productwindow", 800, 600, "yes", "yes");
	return false;
}

function showRawMaterialSearchWindow(formName, FieldName)
{
	NewWindow("/futures_pricing/raw_materials_search.cfm?Formname=" + formName + "&FieldName=" + FieldName, "rawmaterialwindow", 800, 600, "yes", "yes");
	return false;
}

function showSupplierSearchWindow(formName, FieldName)
{
	NewWindow("/futures_pricing/supplier_search.cfm?Formname=" + formName + "&FieldName=" + FieldName, "supplierwindow", 800, 600, "yes", "yes");
	return false;
}

function showNewProductSearchWindow(formName, FieldName)
{
	NewWindow("/futures_pricing/new_product_search.cfm?Formname=" + formName + "&FieldName=" + FieldName, "newproductwindow", 800, 600, "yes", "yes");
	return false;
}

function showNewProductWindow(command, itemId)
{
	NewWindow("/futures_pricing/new_product.cfm?command=" + command + "&itemId=" + itemId, "newproductwindow", 800, 600, "yes", "yes");
	return false;
}

function showWindow(file,formName) 
{
	NewWindow(file + "?formName=" + formName, "window", 800, 600, "yes", "yes");
	return false;
}

/*function submitForm(formObj,command) 
{
	
	formObj.command.value = command;

}*/


/*
dependency on 
<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
*/
function format_Volume(vol)
{
	return formatWithComma(vol, 3, false);
}

var my_queue = new Queue();


function deleteThisRecord(FieldNameRe, recordID, recordIDField, recordIDField2)
{	
	var srcObj = event.srcElement;
	
	/*
	var trObj = getParentObject(srcObj, "TABLE");
	trObj = getParentObject(trObj, "TD");
	trObj = getParentObject(trObj, "TABLE");
	*/
	var trObj = eval("document.all.SCISSOR_ITEM_" + FieldNameRe);
	
	var trIndex = trObj.rowIndex;
	var FINALITEMLIST = recordIDField.value;
	var resultString = ListDeleteItem(FINALITEMLIST, ",", recordID);
	
	var bDelete = true;
	
	if(resultString == FINALITEMLIST)
	{
		resultString = ListAppendItem(FINALITEMLIST, ",", recordID);
		bDelete = false;
	}
	
	recordIDField.value = resultString;
	if(recordIDField2)
	{
		recordIDField2.value = resultString;
	}
	var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";	
	if(trObj)
	{
		if(bDelete)
		{ 
			trObj.height = trObj.offsetHeight;
			
			if(trObj.length)
			{
				for(var k=0;k<trObj.length;k++)
				{
					/*
					if(trObj[k].tagName && trObj[k].tagName == "TR")
					{						
						my_queue.addToQueue(FieldNameRe + k + "_bgColor", trObj[k].bgColor);
					}
					*/
					disableDiv(trObj[k], true, false);
					propogatePropertyRetainVals(trObj[k], "style.backgroundColor", "#DDDDDD", false, false, true);
					propogatePropertyRetainVals(trObj[k], "style.textDecoration", "line-through", true, false, true);
				}
			}
			else
			{
				disableDiv(trObj, true, false);
				propogatePropertyRetainVals(trObj, "style.backgroundColor", "#DDDDDD", false, false, true);
				propogatePropertyRetainVals(trObj, "style.textDecoration", "line-through", true, false, true);			
			}
			disableDiv(srcObj, false, false);
			
			srcObj.alt = "undo record deletion";
			srcObj.src = undodeleteImg.src;
		
		}
		else
		{
			var bgCol = "#FFFFFF";
			
			if(trObj.length)
			{
				for(var k=0;k<trObj.length;k++)
				{
					bgCol = "#FFFFFF";
					/*
					if(trObj[k].tagName && trObj[k].tagName == "TR")
					{
						newBgColor = my_queue.deleteFromQueue(FieldNameRe + k + "_bgColor");
						if(newBgColor)
						{
							bgCol = newBgColor;							
						}
					}*/
					
					disableDiv(trObj[k], false, false);
					propogatePropertyRetainVals(trObj[k], "style.backgroundColor", bgCol, false, false, false);
					propogatePropertyRetainVals(trObj[k], "style.textDecoration", "none", false, false, true);
					propogatePropertyRetainVals(trObj[k], "style.backgroundColor", "#FFFFFF", false, true, false);
					
				}
			}
			else
			{
				disableDiv(trObj, false, false);
				propogatePropertyRetainVals(trObj, "style.backgroundColor", bgCol, false, false, false);
				propogatePropertyRetainVals(trObj, "style.textDecoration", "none", false, false, true);
				propogatePropertyRetainVals(trObj, "style.backgroundColor", "#FFFFFF", false, true, false);
			}
			
						
			srcObj.alt = "delete this record";
			srcObj.src = deleteImg.src;	
			
			
		}
		srcObj.bDelete = !bDelete;
		trObj.bDelete = (bDelete?1:0);
	}				
}


function propogatePropertyRetainVals(oObj, bProperty, bValue, bCheckEmpty, bInput, bSet)
{
	
	var i, objLen, oCells;
	//oCells = oObj.cells;
	oCells = oObj.all;
	objLen = oCells.length;
	
	var bChange;
	var checkInput = false;
	if (arguments.length > 4)
	{
		checkInput = bInput;
	}
	
	setPropertyForThisObjRetainVals(oObj, bProperty, bValue, bCheckEmpty, checkInput, bSet);
	for(i=0;i<objLen;i++)
	{ 
		setPropertyForThisObjRetainVals(oCells[i], bProperty, bValue, bCheckEmpty, checkInput, bSet);
	}
	
}

function setPropertyForThisObjRetainVals(thisObj, bProperty, bValue, bCheckEmpty, checkInput, bSet)
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
			else if(thisObj.tagName == "INPUT" && (thisObj.type != "text" && thisObj.type != "checkbox"))
			{
				bChange = false;
			}
		}
		if(bChange)
		{
			if(checkInput)
			{
				//alert(thisObj.outerHTML);
			}
			if(thisObj.uniqueID)
			{
				
			}
			else
			{
				bSet = true;
			}
			
			var bProp = "";
			if(!bSet)
			{
				bProp = my_queue.deleteFromQueue(thisObj.uniqueID + "_" + bProperty);
				if(bProp)
				{
				}
				else
				{
					bProp = "";
				}
			}
			var currProp = eval("thisObj." + bProperty);
			if(bSet)
			{
				if(thisObj.uniqueID)
				{
					if(currProp == "#ffffcc")
					{
						//alert(thisObj.uniqueID + "\n" + currProp);
						//alert(eval("thisObj." + bProperty));
					}
					my_queue.addToQueue(thisObj.uniqueID + "_" + bProperty, currProp);
				}				
				eval("thisObj." + bProperty + " = \"" + bValue + "\"");
			}
			else
			{
				eval("thisObj." + bProperty + " = \"" + bProp + "\"");
			}			
		}
	}
}
