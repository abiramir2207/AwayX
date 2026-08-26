/*
<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
*/
function formatDollar(sVal, decimalLen, paddZeros, commaLen)
{
	var bMinus = 0;
	if(sVal < 0)
	{
		bMinus = 1;
	}
	var formattedValue = "$" + formatWithComma(formatToDecimalPlaces(sVal, decimalLen, paddZeros), commaLen, 1);
	if(bMinus)
	{
		formattedValue = "(" + formattedValue + ")"
	}
	return formattedValue;	
}

function formatToDecimalPlaces(fVal, decimalLen, paddZeros)
{
	if (fVal == ".")
	{
		fVal = "0.0000";
		return fVal.toString();
	}
	var newAmount = numericRoundDecimal(fVal, decimalLen);
	var strAmount = newAmount.toString();
	var dotIndex = 	strAmount.indexOf(".");
	var i, decimalPresent;
	var addExtraDecimal = 0;
	if(arguments.length < 3 || paddZeros == 1)
	{
		addExtraDecimal = 1;
	}
	if(dotIndex < 0)
	{
		decimalPresent = 0;
		if(decimalLen > 0 && addExtraDecimal)
		{
			strAmount = strAmount + ".";
		}
	}
	else
	{
		decimalPresent = strAmount.length - dotIndex - 1;			
	}		
	if(decimalLen > 0 && addExtraDecimal)
	{
		for(i=decimalPresent;i<decimalLen;i++)
		{
			strAmount = strAmount + "0";
		}
	}
	return strAmount;
}

function numericRoundDecimal(fVal, decimalLen)
{
	var divVal = Math.pow(10, decimalLen);		
	var newAmount = fVal;
	newAmount = newAmount * divVal;
	newAmount = Math.round(newAmount);
	newAmount = newAmount / divVal;
	return newAmount;
}

function PadString(sVal, padLen, padString, bLeft)
{
	var oArr = new Array();
	oArr.length = padLen + 1;
	var isLeft = true;
	if(arguments.length > 3)
	{
		isLeft = bLeft;
	}
	var returnString, rightLen;	
	if(isLeft)
	{
		returnString = oArr.join(padString) + sVal + "";	
		rightLen = returnString.length - padLen;
		returnString = returnString.substr(rightLen);
	}
	else
	{
		returnString = sVal + "" + oArr.join(padString);	
		returnString = returnString.substr(0, padLen);
	}
	return returnString;
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
