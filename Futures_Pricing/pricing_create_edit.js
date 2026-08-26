function addFilterRows(thisObj, compIndFieldName)
{
	var compIndFieldObj = eval("document.all." + compIndFieldName);
	var currTrMaxLen = parseInt(compIndFieldObj.value);
	currTrMaxLen++;
	var trObj = getParentObject(thisObj, "TR");
	var pObj = getParentObject(trObj, "TABLE");
	var sToken = buildToken(pObj.productId, pObj.compIndep);
	/*
	if(!validateThisRow(sToken, trObj, pObj.compIndep))
	{
		return;
	}
	*/
	var focusInput;
	var trIndex = trObj.rowIndex;
    var rObj = pObj.insertRow(trIndex+1);
	
	var coLen = trObj.cells.length;
	var regExp, newHTML;
	
	var arTokens = getToken(thisObj.name, currTrMaxLen);
	rObj.id = "tr_" + arTokens[2];
	
 	for (i=0;i<coLen;i++)
 	{
		var cObj = rObj.insertCell(i);
		if (trObj.cells[i].align)
		{
			cObj.align = trObj.cells[i].align;
		}
		
		regExp = new RegExp(arTokens[0], "igm");
	    newHTML = trObj.cells(i).innerHTML.replace(regExp, arTokens[1]); 
		
		cObj.innerHTML = newHTML;
		/*
		regExp = new RegExp("setFffectiveOverageExpression\\([^\\)]*?\\);", "igm");
		var arr = newHTML.match(regExp);		
		if(arr)
		{
			eval(arr[0]);
			//object.getExpression(sPropertyName);
		}
		*/
		var inputCol = cObj.getElementsByTagName("input");
		for (j=0;j<inputCol.length;j++)
		{
			if (inputCol[j].type == "text")
			{
				inputCol[j].value = "";
			}
			if(!focusInput)
			{
				focusInput = inputCol[j];
			}
			
			if (inputCol[j].type == "checkbox")
			{
				inputCol[j].checked = true;
			}
		}
		
		var inputCol = cObj.getElementsByTagName("select");
		for (j=0;j<inputCol.length;j++)
		{
			inputCol[j].selectedIndex = 0;
		}
		/*
		var inputCol = cObj.getElementsByTagName("div");
		for (j=0;j<inputCol.length;j++)
		{
			inputCol[j].innerText = "";
		}
		*/
 	}
	compIndFieldObj.value = currTrMaxLen;
	if(focusInput)
	{
		focusInput.focus();
	}
}
    
function deleteFilterRows(thisObj, compIndFieldName)
{
	var trObj = getParentObject(thisObj, "TR");
	if(!trObj)
	{
		return;
	}
	var rIndex = trObj.rowIndex;
	
	dontDelete = true; 
	if(trObj.previousSibling || trObj.nextSibling)
	{
		dontDelete = false;
	}
	
	var pObj = getParentObject(trObj, "TABLE");
	
	if (dontDelete)
	{
		var j, inputCol;
		inputCol = trObj.getElementsByTagName("input");
		for (j=0;j<inputCol.length;j++)
		{
			if(inputCol[j].type == "text")
			{
				inputCol[j].value = "";
			}
		}
		inputCol = trObj.getElementsByTagName("select");
		for (j=0;j<inputCol.length;j++)
		{
			inputCol[j].selectedIndex = 0;
		}
	}
	else
	{
		pObj.deleteRow(rIndex);			
		
		var compIndFieldObj = eval("document.all." + compIndFieldName);
		var currTrMaxLen = parseInt(compIndFieldObj.value);
		compIndFieldObj.value = currTrMaxLen--;
	}
	
	calcCompAndIndep(pObj.productId);

}

function addRow(thisObj, compIndFieldName, checkNumeric)
{
	if(checkNumeric)
	{
		if(!Allow_Key_List('0123456789.'))
		{
			if(event.keyCode != 13)
			{
				return false;
			}
		}
	}
	if(event.keyCode == 13)
	{
		addFilterRows(thisObj, compIndFieldName);
		return false;
	}
	return true;
}



function getToken(objName, curLen)
{
	var returnArray = new Array();
	returnArray[0] = "";
	returnArray[1] = "";
	returnArray[2] = "";
	
	var nameArray = objName.split("_");
	nameArray.splice(0, 1);
	nameArray.splice(0, 1);
	returnArray[0] = nameArray.join("_");
	
	nameArray.splice(nameArray.length-1, 1);
	
	returnArray[1] = nameArray.join("_") + "_" + (curLen + 1);
	
	returnArray[2] = curLen + 1;
	
	return returnArray;
}

function getIdFromTrId(trId)
{
	var returnValue = "";
	trNameArray = trId.split("_");
	if(trNameArray.length >= 2)
	{
		returnValue = trNameArray[1];
	}
	return returnValue;
}

function calcCompAndIndep(sProdId)
{
	var thisObj = eval("document.all.finalPrice_" + sProdId);
	var trObj = getParentObject(thisObj, "TR");
	trObj = trObj.previousSibling;
	var tabObjs = trObj.getElementsByTagName("TABLE");
	var i, tabLen = tabObjs.length;
	for(i=0;i<tabLen;i++)
	{
		calcThisTbale(tabObjs[i], tabObjs[i].compIndep);
	}
}
function calcFffectiveOverageExpression(iCompIndep)
{
	var thisObj = event.srcElement;	
	var trObj = getParentObject(thisObj, "TR");	
	var tabObj = getParentObject(trObj, "TABLE");
	var sToken = buildToken(tabObj.productId, tabObj.compIndep);
	validateThisRow(sToken, trObj, tabObj.compIndep, false);
	calcThisTbale(tabObj, iCompIndep);
}

function validateThisRowValues(iCompIndep)
{
	var thisObj = event.srcElement;	
	var trObj = getParentObject(thisObj, "TR");	
	var tabObj = getParentObject(trObj, "TABLE");
	var sToken = buildToken(tabObj.productId, tabObj.compIndep);
	validateThisRow(sToken, trObj, iCompIndep, false);	
}

function validateThisRow(sToken, trObj, iCompIndep, changeColor, setMessageQueue)
{
	var allCorrent = true;
	if(trObj.id)
	{
		var fieldNameSuffix = sToken + "_" + getIdFromTrId(trObj.id);
		var oDesc = eval("document.all.Overhead_Desc_" + fieldNameSuffix);
		var oVal = eval("document.all.Overhead_Value_" + fieldNameSuffix);
		var tdObj;
		var numTextBoxFilled = 0;
		if(oDesc && oVal)
		{
			tdObj = getParentObject(oDesc, "TD");
			if(isSpace(oDesc.value))
			{
				allCorrent = allCorrent && false;
			}
			else
			{
				numTextBoxFilled ++;
			}
			tdObj = getParentObject(oVal, "TD");
			if(!isFloat(oVal.value, false))
			{
				allCorrent = allCorrent && false;
			}
			else
			{
				numTextBoxFilled ++;
			}
			if(numTextBoxFilled == 0)
			{
				allCorrent = true;
			}
			if(!allCorrent)
			{
				//alert(allCorrent);
			}
			if(changeColor)
			{
				if(allCorrent)
				{
					trObj.bgColor = "white";
				}
				else
				{
					trObj.bgColor = "#E9967A";					
				}
			}
			if(setMessageQueue)
			{
				var errObj = eval("document.all.Err_Sp_" + fieldNameSuffix);
				if(allCorrent)
				{
					clearQueue(errObj);					
				}
				else
				{
					queueMessage("You have to enter both description and value", errObj);					
				}
			}
			
		}
	}
	return allCorrent;
}

function calcThisTbale(tabObj, iCompIndep)
{
	var sToken = buildToken(tabObj.productId, tabObj.compIndep);
	var i, rowLen;
	rowLen = tabObj.rows.length;
	var currCompIndepValue, compIndepValue = 0;
	for(i=0;i<rowLen;i++)
	{
		if(tabObj.rows[i].id)
		{
			currCompIndepValue = parseFloat(setFffectiveOverageExpression(sToken + "_" + getIdFromTrId(tabObj.rows[i].id), "value", sToken, iCompIndep));
			if(!isNaN(currCompIndepValue))
			{
				compIndepValue += currCompIndepValue;
			}
		}
	}
	
	//tabObj.tFoot.rows[0].cells[0].innerText = compIndepValue;
	var footerObj = eval("tabObj.tFoot.all.totalOverhead_" + tabObj.productId + "_" + tabObj.compIndep);
	footerObj.innerText = compIndepValue;
	
	//var arName = sToken.split("_");
	if(iCompIndep == 1)//componded
	{
		eval("document.all.finalPrice_" + tabObj.productId + ".iComp = '" + compIndepValue + "'");
	}
	else
	{
		eval("document.all.finalPrice_" + tabObj.productId + ".iIndep = '" + compIndepValue + "'");
	}
}

function mySetExpression(oObj, sProperty, funcName, sFullToken, iCompIndep)
{
	var resultValue = eval(funcName);	
	eval("document.all.displayEffectiveOverhead_" + sFullToken + ".value = resultValue[0]");
	
	
	
	var startValue = resultValue[0];
	if(iCompIndep == 1)
	{
		if(!isNaN(parseFloat(startValue)))
		{
			startValue = startValue + resultValue[1];
		}
	}
	//alert(resultValue[0] + "\n" + startValue);
	eval("oObj." + sProperty + "=startValue");
	return resultValue[0];
}

function setFffectiveOverageExpression(sFullToken, sProperty, sToken, iCompIndep)
{	
	var thisObj = eval("document.all.effectiveOverhead_" + sFullToken);
	//thisObj.setExpression(sProperty, "getEffectiveOverage('" + thisObj.name + "', '" + sToken + "', " + iCompIndep + ")");
	return mySetExpression(thisObj, sProperty, "getEffectiveOverage('" + thisObj.name + "', '" + sToken + "', " + iCompIndep + ")", sFullToken, iCompIndep);
	
}

function getFinalPrice(thisObj)
{
	return parseFloat(thisObj.totalPrice) + parseFloat(thisObj.iComp) + parseFloat(thisObj.iIndep);
}

function getEffectiveOverage(objName, sToken, iCompIndep)
{
	//var retVal = 0;
	var retVal = new Array();
	retVal[0] = 0;
	retVal[1] = 0;
	
	var startObj;
	var thisObj = eval("document.all." + objName);
	var trObj = getParentObject(thisObj, "TR");
	var tabObj = getParentObject(trObj, "TABLE");
	var arSplit = objName.split("_");
	var prodId = "";
	if(arSplit.length >= 4)
	{
		prodId = arSplit[1];
	}
	
	if(trObj)
	{
		if(iCompIndep == 1)
		{
			if(trObj.rowIndex == 0)
			{
				///get first value
				startObj = eval("document.all.effectiveOverhead_" + sToken + "_0");
			}
			else
			{
				///get previous value
				//var prevTr = trObj.previousSibling;
				prevTr = tabObj.rows[trObj.rowIndex-1];			
				if(prevTr)
				{
					startObj = eval("document.all.effectiveOverhead_" + sToken + "_" + getIdFromTrId(prevTr.id));
				}
			}
		}
		else
		{
			///get first value
			startObj = eval("document.all.effectiveOverhead_" + sToken + "_0");
		}
	}
	
	if(startObj)
	{
		var startValue = parseFloat(startObj.value);
		retVal[1] = startValue;
		var trId = getIdFromTrId(trObj.id);
		
		var valObj = eval("document.all.Overhead_Value_" + sToken + "_" + trId);
		var uomObj = eval("document.all.Overhead_UOM_" + sToken + "_" + trId);
		if(uomObj && valObj)
		{
			var iValue = parseFloat(valObj.value);
			if(uomObj.value == 2)//%
			{
				retVal[0] = ((startValue * iValue) / 100);
			}
			else
			{
				retVal[0] = iValue;
			}
			/*
			if(iCompIndep == 1)
			{
				retVal = retVal + startValue;
			}
			*/
		}
	}
	if(isNaN(retVal[0]))
	{
		retVal[0] = "";
	}
	return retVal;
}

function buildToken(prodId, compIndep)
{
	return (prodId + "_" + compIndep);
}

function buildFullToken(prodId, compIndep, rowIndex)
{
	return (buildToken(prodId, compIndep) + "_" + rowIndex);
}

function validateFields()
{
	var tabsObj = document.getElementsByTagName("TABLE");
	var i, tabsLen, j, rowLen, rowsObj;
	var sToken;
	tabsLen = tabsObj.length;
	var allTrue = true;
	
	for(i=0;i<tabsLen;i++)
	{
		if(tabsObj[i].compIndep && tabsObj[i].productId)
		{
			sToken = buildToken(tabsObj[i].productId, tabsObj[i].compIndep);
			rowsObj = tabsObj[i].rows;
			rowLen = rowsObj.length;
			for(j=0;j<rowLen;j++)
			{
				allTrue = validateThisRow(sToken, rowsObj[j], tabsObj[i].compIndep, false, true) && allTrue;
				
			}
		}
	}
	if(!allTrue)
	{
		showMessageWindow();
	}
	return allTrue;
}