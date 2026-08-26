/*
function formatToDeciamalPlaces(fVal, decimalLen)
{
	var divVal = Math.pow(10, decimalLen);		
	var newAmount = fVal;
	newAmount = newAmount * divVal;
	newAmount = Math.round(newAmount);
	newAmount = newAmount / divVal;
	return newAmount;
}
*/

function formatToDeciamalPlaces(fVal, decimalLen)
{	
	if(fVal == "-")
	{
		strAmount = formatToDeciamalPlacesAllowNull(0,decimalLen,0)	
	}
	else {
		strAmount = formatToDeciamalPlacesAllowNull(fVal,decimalLen,0)	
	}
	return strAmount;
}

function formatToDeciamalPlacesAllowNull(fVal,decimalLen,IsNullAllowed)
{	
	var divVal = Math.pow(10, decimalLen);		
	var newAmount = fVal;
	
	if (newAmount == ".")
	{
		newAmount = "0.0000";
		return newAmount.toString();
	}
	newAmount = newAmount * divVal;
	newAmount = Math.round(newAmount);
	newAmount = newAmount / divVal;
	var strAmount = newAmount.toString();
	var dotIndex = 	strAmount.indexOf(".");
	var i, decimalPresent;

	if(dotIndex < 0)
	{
		decimalPresent = 0;
		if(decimalLen > 0)
		{
			strAmount = strAmount + ".";
		}
	}
	else
	{
		decimalPresent = strAmount.length - dotIndex - 1;			
	}
	
	if (IsNullAllowed == 1 && strAmount == "0.")
	{		
		strAmount = "";
	}
	else if(decimalLen > 0)
	{			
		for(i=decimalPresent;i<decimalLen;i++)
		{
			strAmount = strAmount + "0";
		}
	}	
	
	return strAmount;
}

function formatWithComma(sVal, commaLen, doNotReturnSign)
{
	var fVal = sVal.toString();
	var formattedString = fVal;
	var isNegative = false;
	if(commaLen >= 1)
	{		
		var trimDecimalPlaces, decimalPart;
		var decimalPoint = fVal.indexOf(".");
		if(decimalPoint >= 0)
		{
			trimDecimalPlaces = fVal.substr(0, decimalPoint);
			decimalPart = fVal.substr(decimalPoint);
		}
		else
		{
			trimDecimalPlaces = fVal;
			decimalPart = "";
		}
		
		var testNeg = parseFloat(trimDecimalPlaces);
		if(testNeg < 0)
		{
			isNegative = true;
			trimDecimalPlaces = Math.abs(testNeg).toString();
		}
		
		
		trimDecimalPlaces = reverseString(trimDecimalPlaces);
		
		
		var regExpStr = "([0123456789]{1," + commaLen + "})";
		var regExp = new RegExp(regExpStr, "igm");
  		var formattedString = "";		
		var arr = trimDecimalPlaces.match(regExp);
		var i, matchedString;
		matchedString = "";		
		if(arr)
		{
			for(i=0;i<arr.length;i++)
			{
			  	arr[i] = reverseString(arr[i]);			
			}
			arr = arr.reverse();
			formattedString = arr.join(",");
			formattedString = formattedString + decimalPart;
			if(arguments.length > 2)
			{
				if(doNotReturnSign)
				{
					isNegative = false;
				}
			}
			if(isNegative)
			{
				formattedString = "-" + formattedString;
			}
		}
	}
	return formattedString;
	
}

function reverseString(sStr)
{
	var arRev = sStr.split("");;
	arRev = arRev.reverse();
	sStr = arRev.join("");
	return sStr;
}

	
function getParentObject(thisObj, tagName)
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


function getTotalOffsetProperty(thisObj, tagName, sProperty, addValues)
{
	addValues = addValues + eval("thisObj." + sProperty);
	if(thisObj.tagName.toLowerCase() == tagName.toLowerCase())
	{
		return addValues;
	}
	else if(thisObj.tagName.toLowerCase() == "body")
	{
		return addValues;
	}
	else
	{
		return getTotalOffsetProperty(thisObj.offsetParent, tagName, sProperty, addValues);
	}
}