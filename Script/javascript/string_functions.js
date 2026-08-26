/*
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>

IMPORTANT NOTES:

  Consider to use the minified version of this file.  The minified version is about half of the size,
  so it would load quicker.

  <script type="text/javascript" src="/script/javascript/string_functions.min.js"></script>

FOLLOW THESE STEPS TO MODIFY THIS FILE:
======================================
  a. Make changes to this file
  b. Test your changes against the full size js
  c. Minify the full size js with the tool at http://www.minifyjs.com/javascript-compressor/
  d. Copy, paste the minified code into Notepad, save it to /script/javascript/string_functions.min.js
  e. Change your .cfm file to use the minified version

*/

/*25704 - 2011-mar-15 - combine two email address lists, separate them with a semi-colon*/
function combineEmails( e1, e2 ) {
  if ( trim(e1).length == 0 )
    return trim(e2);
  if ( trim(e2).length == 0 )
    return trim(e1);

  return trim(e1) + ";" + trim(e2);
}

//trims leading and trailing whitespaces and returns a string
// input: string
// output: string
function trim(sStr)
{
	return sStr.replace(/^\s*/ig, "").replace(/\s*$/ig, "");
}

function ArrayDeleteItem(oArray, sValue, useDelimiter)
{
	var originalLen = oArray.length;
	var ArrayList = oArray.join(useDelimiter);
	var newArrayList = ListDeleteItem(ArrayList, useDelimiter, sValue);
	var ReturnArray = newArrayList.split(useDelimiter);
	if(ReturnArray.length == originalLen && originalLen == 1)
	{
		if(trim(ReturnArray[0]).length == 0)
			ReturnArray.length = 0;
	}
	return ReturnArray;
}

function listLength(sList, delimiter)
{
	var Arr = sList.split(delimiter);
	return Arr.length;
}

function ListDeleteAt(sList, delimiter, deletePosition)
{
	var resultString = sList;
	var Arr = sList.split(delimiter);
	var i, arrLen;
	arrLen = Arr.length;
	Arr.splice(deletePosition, 1);
	resultString = Arr.join(delimiter);
	return trim(resultString);

}

function ListDeleteItem(sList, delimiter, deleteItem, searchForMultiple)
{
	var resultString = sList;
	var Arr = sList.split(delimiter);
	var i, arrLen;
	var iExitOnFirstFind = 1;
	if(searchForMultiple)
	{
		if(searchForMultiple == 1)
		{
			iExitOnFirstFind = 0;
		}
	}

	arrLen = Arr.length;
	for(i=arrLen-1;i>=0;i--)
	{
		if(trim(Arr[i]).toLowerCase() == trim(deleteItem).toLowerCase())
		{
			Arr.splice(i, 1);
			if(iExitOnFirstFind == 1)
			{
				resultString = Arr.join(delimiter);
				return trim(resultString);
			}
		}
	}
	resultString = Arr.join(delimiter);
	return resultString;
}

function ListFindItem(sList, delimiter, findItem)
{
	var resultString = sList;
	var Arr = sList.split(delimiter);
	var i, arrLen;
	arrLen = Arr.length;
	for(i=0;i<arrLen;i++)
	{
		if(trim(Arr[i]).toLowerCase() == trim(findItem).toLowerCase())
		{
			return i;
		}
	}
	return -1;
}

function ListAppendItem(sList, delimiter, appendItem)
{
	var resultString = sList;
	var Arr = sList.split(delimiter);
	var arrLen;
	arrLen = Arr.length;
	if(arrLen == 1 && Arr[0].length == 0)
	{
		arrLen = 0;
	}
	Arr[arrLen] = appendItem;
	resultString = Arr.join(delimiter);
	return resultString;
}

function Allow_Key_List(keyList)
{
	var returnValue = false;
	var findThisKey = keyList.indexOf(String.fromCharCode(event.keyCode), 0);
	if(findThisKey >= 0)
	{
		returnValue = true;
	}
	return returnValue;
}

function Disallow_Key_List(keyList)
{
	return !Allow_Key_List(keyList);
}

function Disallow_Key_List_In_String(sStr, keyList)
{
	var i, findThisKey;
	var arrDisallowKeyList = keyList.split("");
	for(i=0;i<arrDisallowKeyList.length;i++)
	{
		findThisKey = sStr.indexOf(arrDisallowKeyList[i], 0);
		if(findThisKey >= 0)
		{
			return false;
		}
	}
	return true;
}

function makeValidIntFloat(obj, intFloat, emptyVal)
{
	var retval = obj.value;

	retval = getNumeric(retval, intFloat, emptyVal);

	retval = retval + "";

	if(obj.value != retval)
	{
		obj.value = retval;
	}
}

function getNumeric(retval, intFloat, emptyVal)
{
	if(intFloat == 1)
	{
		retval = parseInt(retval);
	}
	else
	{
		retval = parseFloat(retval);
	}
	if(isNaN(retval))
	{
		retval = emptyVal;
	}

	return retval;
}

function Numeric_Key_Only(thisObj, allowNegative, allowDecimal)
{
	var returnValue = true;
	var inputValue = thisObj.value;
	var validVal, validVal2;
	returnValue = isNumeric(inputValue, allowNegative, allowDecimal);
	validVal = inputValue;
	if(validVal == "-" && allowNegative)//-
	{
		returnValue = true;
	}
	validVal2 = "";

	if(validVal.substr(validVal.length-1) == "." && allowDecimal)//xxxx....
	{
		validVal = validVal.replace(/\.+$/, "");
		validVal2 = ".";

		if(/\.+/.test(validVal))
		{
			validVal2 = "";
		}
	}

	if(validVal == "-0" && allowNegative)//-0.
	{
		returnValue = true;
	}
	if(!returnValue)
	{

		if(allowDecimal)
		{
			validVal = parseFloat(validVal);
		}
		else
		{
			validVal = parseInt(validVal);
		}

		if(!allowNegative)
		{
			validVal = Math.abs(validVal);
		}

		if(isNaN(validVal))
		{
			validVal = "";
		}
		thisObj.value = validVal + validVal2;
	}
	return returnValue;
}


function isNumeric(sVal, allowNegative, allowDecimal)
{
	var sValTemp = parseFloat(sVal);
	var returnValue = true;
	returnValue = returnValue && (!isNaN(sValTemp));

	if(allowNegative)
	{
		if(allowDecimal)
		{
			returnValue = returnValue && (/^[+-]?\d*(\.(\d)+)?$/.test(sVal));
		}
		else
		{
			returnValue = returnValue && (/^[+-]?\d*$/.test(sVal));
		}
	}
	else
	{
		if(allowDecimal)
		{
			returnValue = returnValue && (/^\d*(\.(\d)+)?$/.test(sVal));
		}
		else
		{
			returnValue = returnValue && (/^\d*$/.test(sVal));
		}
	}
	return returnValue;
}


// validates the text in a text box
//clenseText(textObject, vaildListOfChars)
var valid = "";
function clenseText(textObject, vaildListOfChars){
	/*if(textObject.value == 0) {
		textObject.value = "";
		return false
	}*/
	valid = vaildListOfChars; // define valid characters
	if(isValid(textObject.value, valid)){
		return true
	}
	else{
		ClearCharsUntilIntegerIsFound(textObject)
	}
}

function ClearLastCharEnteredIfNotNumber(textObject){
	if(!isValid(textObject.value, valid)){
		newText = textObject.value.substring(0, textObject.value.length - 1);
		textObject.value = newText;
	}
}


function isValid(string,allowed) {
    decimalCount  = 0;
	for (var i=0; i< string.length; i++) {
       if (allowed.indexOf(string.charAt(i)) == -1) return false;

		if(string.charAt(i) == '.'){
			decimalCount++;
		}

		if(string.charAt(i) == '-' && i != 0){
			return false;
		}

		if(decimalCount >1) return false;
	}
	return true;
}

function ClearCharsUntilIntegerIsFound(textObject) {

	do {
		ClearLastCharEnteredIfNotNumber(textObject)
	}while (!isValid(textObject.value, valid))
}

function limitXdecimalplaces(X, textObject){
	locationOfDecimal = textObject.value.indexOf(".");
	if(locationOfDecimal != -1){
		decimalPlaceCount = textObject.value.length - locationOfDecimal-1;
		if(decimalPlaceCount > X) {
			textObject.value = textObject.value.substring(0, locationOfDecimal+X+1)
		}
	}
}

/*
    replaceChar - Funtion will replace the occurance of text with by in a string
	Syntax: replaceChar(someString, replaceThis, withThis)
*/
function replaceChar(string, text, by)
{
	var reString = text;
	var re;
	//here we have to escape characters like \ ( ) . ? * + \$ \^
	re = new RegExp("([\\\(\)\.\?\*\+\$\^])", "ig");
	reString = reString.replace(re, "\\$1");
	//now replace the original string
	re = new RegExp(reString, "ig");
  	return string.replace(re, by);
}

/*****************************  NUMBERFORMAT  ****************************************/
<!--
/*
 * NumberFormat 1.0.3
 * v1.0.3 - 23-March-2002
 * v1.0.2 - 13-March-2002
 * v1.0.1 - 20-July-2001
 * v1.0.0 - 13-April-2000
 * http://www.mredkj.com
 */

/*
 * NumberFormat -The constructor
 * num - The number to be formatted
 */
function NumberFormat(num)
{

	// member variables
	this.num;
	this.numOriginal;
	this.isCommas;
	this.isCurrency;
	this.currencyPrefix;
	this.places;

	// external methods
	this.setNumber = setNumberNF;
	this.toUnformatted = toUnformattedNF;
	this.setCommas = setCommasNF;
	this.setCurrency = setCurrencyNF;
	this.setCurrencyPrefix = setCurrencyPrefixNF;
	this.setPlaces = setPlacesNF;
	this.toFormatted = toFormattedNF;
	this.getOriginal = getOriginalNF;

	// internal methods
	this.getRounded = getRoundedNF;
	this.preserveZeros = preserveZerosNF;
	this.justNumber = justNumberNF;

	// setup defaults
	this.setNumber(num);
	this.setCommas(true);
	this.setCurrency(true);
	this.setCurrencyPrefix('$');
	this.setPlaces(2);
}

/*
 * setNumber - Sets the number
 * num - The number to be formatted
 */
function setNumberNF(num)
{
	this.numOriginal = num;
	this.num = this.justNumber(num);
}

/*
 * toUnformatted - Returns the number as just a number.
 * If the original value was '100,000', then this method will return the number 100000
 * v1.0.2 - Modified comments, because this method no longer returns the original value.
 */
function toUnformattedNF()
{
	return (this.num);
}

/*
 * getOriginal - Returns the number as it was passed in, which may include non-number characters.
 * This function is new in v1.0.2
 */
function getOriginalNF()
{
	return (this.numOriginal);
}

/*
 * setCommas - Sets a switch that indicates if there should be commas
 * isC - true, if should be commas; false, if no commas
 */
function setCommasNF(isC)
{
	this.isCommas = isC;
}

/*
 * setCurrency - Sets a switch that indicates if should be displayed as currency
 * isC - true, if should be currency; false, if not currency
 */
function setCurrencyNF(isC)
{
	this.isCurrency = isC;
}

/*
 * setCurrencyPrefix - Sets the symbol that precedes currency.
 * cp - The symbol
 */
function setCurrencyPrefixNF(cp)
{
	this.currencyPrefix = cp;
}

/*
 * setPlaces - Sets the precision of decimal places
 * p - The number of places. Any number of places less than or equal to zero is considered zero.
 */
function setPlacesNF(p)
{
	this.places = p;
}

/*
 * toFormatted - Returns the number formatted according to the settings (a string)
 */
function toFormattedNF()
{
	var pos;
	var nNum = this.num; // v1.0.1 - number as a number
	var nStr;            // v1.0.1 - number as a string

	// round decimal places
	nNum = this.getRounded(nNum);
	nStr = this.preserveZeros(Math.abs(nNum)); // this step makes nNum into a string. v1.0.1 Math.abs

	if (this.isCommas)
	{
		pos = nStr.indexOf('.');
		if (pos == -1)
		{
			pos = nStr.length;
		}
		while (pos > 0)
		{
			pos -= 3;
			if (pos <= 0) break;
			nStr = nStr.substring(0,pos) + ',' + nStr.substring(pos, nStr.length);
		}
	}

	nStr = (nNum < 0) ? '-' + nStr : nStr; // v1.0.1

	if (this.isCurrency)
	{
		// add dollar sign in front
		nStr = this.currencyPrefix + nStr;
	}

	return (nStr);
}

/*
 * getRounded - Used internally to round a value
 * val - The number to be rounded
 */
function getRoundedNF(val)
{
	var factor;
	var i;

	// round to a certain precision
	factor = 1;
	for (i=0; i<this.places; i++)
	{	factor *= 10; }
	val *= factor;
	val = Math.round(val);
	val /= factor;

	return (val);
}

/*
 * preserveZeros - Used internally to make the number a string
 * 	that preserves zeros at the end of the number
 * val - The number
 */
function preserveZerosNF(val)
{
	var i;

	// make a string - to preserve the zeros at the end
	val = val + '';
	if (this.places <= 0) return val; // leave now. no zeros are necessary - v1.0.1 less than or equal

	var decimalPos = val.indexOf('.');
	if (decimalPos == -1)
	{
		val += '.';
		for (i=0; i<this.places; i++)
		{
			val += '0';
		}
	}
	else
	{
		var actualDecimals = (val.length - 1) - decimalPos;
		var difference = this.places - actualDecimals;
		for (i=0; i<difference; i++)
		{
			val += '0';
		}
	}

	return val;
}

function formatTextboxDecimalPlaces(textObject, decimalLen)
{
	if(event.type == "keyup") {

		if(textObject.value.indexOf(".") != -1) {
			if(textObject.value.length - textObject.value.indexOf(".") >= (decimalLen+1)) {
				var validNumber = new NumberFormat();
				validNumber.setCommas(false);
				validNumber.setCurrency(false);
				validNumber.setPlaces(decimalLen);
				validNumber.setNumber(textObject.value);
				textObject.value = validNumber.toFormatted();
			}
		}
	}
	else {
		var validNumber = new NumberFormat();
		validNumber.setCommas(false);
		validNumber.setCurrency(false);
		validNumber.setPlaces(decimalLen);
		validNumber.setNumber(textObject.value);
		textObject.value = validNumber.toFormatted();
	}
	return 0;
}

/* This function returns the floor value for the specified number of decimal places
e.g.- 1.1275 will return 1.12 and not 1.13.
*/
function JSdecimalFloor(value, decimals) {
	return Number(Math.floor(value+'e'+decimals)+'e-'+decimals);
}

/*
 * justNumber - Used internally to parse the value into a floating point number.
 * If the value is not set, then return 0.
 * If the value is not a number, then replace all characters that are not 0-9, a decimal point, or a negative sign.
 *
 *  Note: The regular expression cleans up the number, but doesn't get rid of - and .
 *  Because all negative signs and all decimal points are allowed,
 *  extra negative signs or decimal points may corrupt the result.
 *  parseFloat will ignore all values after any character that is NaN.
 *
 *  A number can be entered using special notation.
 *  For example, the following is a valid number: 0.0314E+2
 *
 * This function is new in v1.0.2
 */
function justNumberNF(val)
{
	val = (val==null) ? 0 : val;

	// check if a number, otherwise try taking out non-number characters.
	if (isNaN(val))
	{
		var newVal = parseFloat(val.replace(/[^\d\.\-]/g, ''));

		// check if still not a number. Might be undefined, '', etc., so just replace with 0.
		// v1.0.3
		return (isNaN(newVal) ? 0 : newVal);
	}
	// return 0 in place of infinite numbers.
	// v1.0.3
	else if (!isFinite(val))
	{
		return 0;
  }

	return val;
}

// toTitleCase("FOO BAR baz") ---> becomes "Foo Bar Baz"
function toTitleCase(str) {
	var lcStr = str.toLowerCase();
	return lcStr.replace(/(?:^|\s)\w/g, function(match) {
		return match.toUpperCase();
	});
}

// copy text of input element to clipboard --> pass in the element Id
function copyInputText(elementId) {
	var copyElemment = document.getElementById(elementId);
	copyElemment.select();
  	document.execCommand("copy");
  	// console.log(copyElemment.value); // uncomment to output to console
}

// copy text of html element like td or div to clipboard --> pass in the element
function copyObjText(element) {
	var copyText = element.text().trim();
    // create an input element and add text to it and then remove it from document.
    var x = document.createElement("input");
    document.body.appendChild(x);
    x.value = copyText;
    x.select();
    document.execCommand("copy");
    document.body.removeChild(x);
	// console.log(copyText);  // uncomment to output to console
}


// pass an array of objects and a field to check and get an array of unique objects
function getArrUniqueObjs(allArray, fieldToCheck) {
    var retArr = []; // to hold unique objects
    var map = new Map(); // to hold unique id's
    for (var i = 0; i < allArray.length; i++) {
        var obj = allArray[i];
        if (!map.has(obj[fieldToCheck])) {
            map.set(obj[fieldToCheck], true); // save every new id
            retArr.push(obj);
        }
    }
	return retArr;
}
//-->

