/*
<SCRIPT SRC="/Script/javascript/validateFormUtils.js"></SCRIPT>
*/

//Checks that a Text Field contains numeric data within a range
//	if false, pops up an alertbox and focuses on the field
function checkRangeData(objField, sFieldName, minValue, maxValue) {
	if (!isValidRange(objField.value, minValue, maxValue)) {
		return getFocusAlert(objField, "You must enter a valid number for " + sFieldName + " between " + minValue + " and " + maxValue + ".");
	}
	else {
		return true;
	}
}

//Checks that a Text Field contains numeric data
//	if false, pops up an alertbox and focuses on the field
function checkNumberData(objField, sFieldName) {
	if (!isValidNumber(objField.value)){
		return getFocusAlert(objField, "You must enter a valid number for " + sFieldName + ".");
	}
	else {
		return true;
	}
}

//Checks that a Text Field contains numeric data
//	if false, pops up an alertbox and focuses on the field
function checkNumberDataNotReq(objField, sFieldName) {
	if (!isValidNumber(objField.value) && objField.value != ''){
		return errorAlert("You must enter a valid number for " + sFieldName + ".");
	}
	else {
		return true;
	}
}
//Checks if a Text Field contains any data
//	if false, pops up an alertbox and focuses on the field
function checkStringData(objField, sFieldName) {
	if (!isValidString(objField.value)) {
		return getFocusAlert(objField, "You must enter a valid value for " + sFieldName + ".");
	}
	else {
		return true;
	}
}

//Checks if a Text Field contains any data less than a given length
//	if false, pops up an alertbox and focuses on the field
function checkLengthData(objField, sFieldName, maxLength) {
	if (!isValidLength(objField.value, maxLength)) {
		return getFocusAlert(objField, "You cannot enter more than " + maxLength +" characters for " + sFieldName + ".");
	}
	else {
		return true;
	}
}


//Checks if a Text Field contains data that matches any digit
//	and common phone number characters [(, ), ., -, x]
//	if false, pops up an alertbox and focuses on the field
function checkPhoneData(objField, sFieldName) {
	var result = false;

	//Check if the field has data
	if (isValidString(objField.value)) {
		//strip out acceptable non-numeric characters
		var stripped = objField.value.replace(/[x\(\)\.\-\ ]/g, '');

		//Check if there are at least 7 characters
		if (stripped.length >= 10) {
			//Check if the remaining characters are only digits
			if (!isNaN(stripped)) {
				result = true;
			}
		}
	}

	if (result == false) {
		return getFocusAlert(objField, "You must enter a valid value for " + sFieldName + ".");
	}
	return result;
}

//Checks if a Text Field contains data that matches a zipcode (5 or 9 digits)
//	if false, pops up an alertbox and focuses on the field
function checkZipcodeData(objField, sFieldName) {
	if (!isValidZipcode(objField.value)) {
		return getFocusAlert(objField, "You must enter a valid value for " + sFieldName + ".");
	}
	else {
		return true;
	}
}


//Checks if a Text Field contains any non-numeric data
//	if false, pops up an alertbox and focuses on the field
function checkTextData(objField, sFieldName) {
	if (!isValidString(objField.value) || !isNaN(objField.value)) {
		return getFocusAlert(objField, "You must enter a valid value for " + sFieldName + ".");
	}
	else {
		return true;
	}
}

//Checks if a Text Field contains a valid file name
//	if false, pops up an alertbox and focuses on the field
function checkFileName(objField, sFieldName, sFileExtension) {
	if (!isValidFile(objField.value, sFileExtension)) {
		var sMsg = "You must enter a valid file name for " + sFieldName + " that does not contain spaces or the characers \\/\':*?\"<>[]{}|";

		if (isValidText(sFileExtension)) {
			sMsg = sMsg + " and ends with the extension '" + sFileExtension+ "'";
		}

		sMsg = sMsg + ".";

		return getFocusAlert(objField, sMsg);
	}
	else {
		return true;
	}
}

//Checks if a select object does not have a specified value selected
//	if false, pops up an alertbox and focuses on the field
function checkSelectData(objField, sFieldName, invalidValue) {
	if (!isValidSelectionValue(objField, invalidValue)) {
		return getFocusAlert(objField, "You must select a valid value for " + sFieldName + ".");
	}
	else {
		return true;
	}
}
//Checks if a Text Field contains any data
//	if false, pops up an alertbox and focuses on the field
function checkEmailData(objField, sFieldName) {
	if (!isValidEmail(objField.value)) {
		return getFocusAlert(objField, "You must enter a valid value for " + sFieldName + ".");
	}
	else {
		return true;
	}
}

//Checks if a checkbox object is checked
//	if false, pops up an alertbox and focuses on the field
function checkCheckboxData(objField, sFieldName) {
	if (!isChecked(objField)) {
		return getFocusAlert(objField, "You must check " + sFieldName + ".");
	}
	else {
		return true;
	}
}

//Checks if a radio button has any selected items
//	if false, pops up an alert box and focuses on the first element
function checkRadioData(objField, sMsg) {
	return checkObjectArrayData(objField, sMsg);
}

//Checks if a radio button or checkbox has any selected items
// if false, pops up an alertbox and focuses on the first element
function checkObjectArrayData(objField, sMsg) {
	var result = getObjectArrayCheckedIndex(objField);

	//Checks if there is only one element and not checked
	if (isNaN(result) && objField.checked == false)	{
		return getFocusAlert(objField, sMsg);
	}
	//Checks if there are multiple elements and nothing checked
	else if (result == -1) {
		objField[0].focus();
		return errorAlert(sMsg);
	}
	//At least one element is checked
	else {
		return true;
	}
}

//Sets focus to the given field, pops up an alertbox, returns false
function getFocusAlert(objField, sMsg) {
	objField.focus();
	return errorAlert(sMsg);
}

//Returns a false result and creates an alert box popup
function errorAlert(sMsg) {
	alert(sMsg);
	return false;
}

//returns the value of the checked radio button option or
//	returns null if no option is selected
function getRadioValue(objField) {
	var result = null;
	var checkedIndex = getCheckedIndex(objField);

	if (isNaN(checkedIndex)) {
		result = objField.value;
	} else {
		result = objField[checkedIndex].value;
	}
	return result;
}

//calls getObjectArrayCheckedIndex
function getCheckedIndex(objField) {
	return getObjectArrayCheckedIndex(objField);
}

//checks a radio button or checkbox object
//	-returns a non-numeric result if it has only one element
// -returns its length if it has more than one element,
function getObjectArrayLength(objField) {
	var result = "only one element";
	if (!isNaN(objField.length)) {
		result = objField.length;
	}
	return result;
}

//checks a radio button or checkbox object
//	-returns a non-numeric result if it has only one element
//	-returns the index of the first checked element
//	-returns -1 if there are no checked elements
function getObjectArrayCheckedIndex(objField) {
	var length = getObjectArrayLength(objField);
	var checkedIndex = -1;

	//Check if the object has only one element
	if (isNaN(length)) {
		checkedIndex = "Not Checked";
	}
	else {
		//Loops through all object elements and
		//	identifies the index of the first checked element
		for(var i = 0; i < length; i++) {
			if (objField[i].checked) {
				checkedIndex = i;
				break;
			}
		}
	}
	return checkedIndex;
}

//Validates String is not zero length
function isValidString(StringValue) {
	var result = false;
	if ((StringValue != null) && (StringValue.length > 0)) {
		result = true;
	}
	return result;
}

//Validates Text is not zero length and not a number
function isValidText(StringValue) {
	var result = false;
	if ((isValidString(StringValue)) && (isNaN(StringValue))) {
		result = true;
	}
	return result;
}

//Validates String is composed only of a-z or A-Z characters
function isAlphabetic(StringValue) {
	var result = false;
	if ((isValidString(StringValue)) && (StringValue.search(/[^a-zA-Z]/g) == -1)) {
		result = true;
	}
	return result;
}

//Validates that a String is not longer than a given value
function isValidLength(StringValue, maxLength) {
	var result = false;
	if (StringValue.length <= maxLength) {
		result = true;
	}
	return result;
}

//Validates String data as a Number
function isValidNumber(StringValue) {
  	var result = false;
	if ((isValidString(StringValue)) && (!isNaN(StringValue))) {
		result = true;
	}
	return result;
}

//Validates String data as a Number within a set range
function isValidRange(StringValue, minValue, maxValue) {
  	var result = false;
	if (isValidNumber(StringValue)) {
		if((StringValue <= maxValue) && (StringValue >= minValue)) {
			result = true;
		}
	}
	return result;
}

//Validates the selected value of a select object does not match a given value
function isValidSelectionValue(objField, invalidValue) {
	var result = false;
	if (objField.options[objField.options.selectedIndex].value != invalidValue) {
		result = true;
	}
	return result;
}

//Validates the selected index of a select object does not match a given index
function isValidSelectionIndex(objField, invalidIndex) {
	var result = false;
	if (objField.selectedIndex != invalidIndex) {
		result = true;
	}
	return result;
}


//Validates the selected index of a select object does not match a given index
function isValidFile(sFileName, sFileExtension) {
	sFileName = sFileName.toLowerCase();
	sFileExtension = sFileExtension.toLowerCase();
	var result = false;
	if (isValidText(sFileName)) {
		//Check that the filename doesn't contain invalid characters
		if (sFileName.search(/[\\\/\:\*\?\<\>\|\s\"\'\{\}\[\]]/g) == -1) {	//"

			//Check if a file extension was supplied
			if (isValidText(sFileExtension)) {
				//Check that the filename has a valid file extension
				if (sFileName.indexOf(sFileExtension) > 0) {
					result = true;
				}
			} else {
				result = true;
			}
		}
	}
	return result;
}


//Validates String data as an Email Address
function isValidEmail(email) {
	var result = false;
	if(isValidString(email)) {
		var theStr = new String(email);
		var index = theStr.indexOf("@");
		if (index > 0)	{
			var pindex = theStr.indexOf(".",index);
			if ((pindex > index+1) && (theStr.length > pindex+2)) {
				result = true;
			}
		}
	}
	return result;
}

//Validates if the integer values for day, month, and year
//	combine to form a valid date - if not, returns false
function isValidDate(day, month, year) {
	day = "" + parseInt(day, 10);
	month = "" + parseInt(month, 10);
	year = "" + parseInt(year, 10);

	//Check that the month value is in the correct range
	if (!isValidRange(month, 1, 12)) {
		return false;
	}
	//Check that the day value is in the correct range
	if (!isValidRange(day, 1, 31)) {
		return false;
	}

	// Make sure user doesn't put 31 for a month that only has 30 days
	if ((month == 4 || month == 6 || month == 9 || month == 11) && day == 31) {
		return false;
	}

	// Check for February date validity (including leap years)
	if (month == 2) {

		// figure out if "year" is a leap year; don't forget that
		// century years are only leap years if divisible by 400
		var isleap=(year%4==0 && (year%100!=0 || year%400==0));
		if (day > 29 || (day == 29 && !isleap)) {
			return false;
		}
	}
	return true;
}

//Validates if the integer values for day, month, and year
//	combine to form a valid future date - if not, returns false
function isFutureDate(day, month, year) {

	day = "" + parseInt(day);
	month = "" + parseInt(month);
	year = "" + parseInt(year);

	//Check that this is a valid date
	if (!isValidDate(day, month, year)) {
		return false;
	}

	var currentDate = new Date();
	var testDate = new Date(year, month - 1, day);

	if (currentDate.getFullYear() > testDate.getFullYear()) {
		return false;
	}
	else if (currentDate.getFullYear() == testDate.getFullYear()) {
		if (currentDate.getMonth() > testDate.getMonth()) {
			return false;
		}
		else if (currentDate.getMonth() == testDate.getMonth()) {
			if (currentDate.getDate() >= testDate.getDate()) {
				return false;
			}
		}
	}
	return true;
}

//Sets a default value for an empty field
function setDefaultValue(objField, sDefaultVal) {
	if (!isValidString(objField.value)) {
		objField.value = sDefaultVal;
	}
}

//Validates a Checkbox is checked
function isChecked(objField) {
  	var result = false;
	if (objField.checked == true) {
		result = true;
	}
	return result;
}

//Sets the checked/unchecked value for a checkbox or radio button
function setCheckValue(objField, checkedValue, uncheckedValue) {
	if (objField.checked == true)	{
		objField.value = checkedValue;
	}
	else {
		objField.value = uncheckedValue;
	}
}

//remove everything that isn't a number and return the result
function cleanNumberic(strNumeric) {
	return strNumeric.replace(/\D/g,'')
}

function checkCardNumWithMod10(cardNum) {
	var i;
	var cc = new Array(16);
	var checksum = 0;
	var validcc;

	// assign each digit of the card number to a space in the array
	for (i = 0; i < cardNum.length; i++) {
		cc[i] = Math.floor(cardNum.substring(i, i+1));
	}

	// walk through every other digit doing our magic
	// if the card number is sixteen digits then start at the
	// first digit (position 0), otherwise start from the
	// second (position 1)
	for (i = (cardNum.length % 2); i < cardNum.length; i+=2) {
		var a = cc[i] * 2;
		if (a >= 10) {
			var aStr = a.toString();
			var b = aStr.substring(0,1);
			var c = aStr.substring(1,2);
			cc[i] = Math.floor(b) + Math.floor(c);
		} else {
			cc[i] = a;
		}
	}

	// add up all of the digits in the array
	for (i = 0; i < cardNum.length; i++) {
		checksum += Math.floor(cc[i]);
	}

	// if the checksum is evenly divisble by 10
	// then this is a valid card number
	validcc = ((checksum % 10) == 0);

	return validcc;
}

function isValidCCNum(cardNum, cardType)
{
	var upperCardType = cardType.toUpperCase();
	var result = false;
	var cardLen = cardNum.length;
	var firstdig = cardNum.substring(0,1);
	var seconddig = cardNum.substring(1,2);
	var first4digs = cardNum.substring(0,4);

	switch (upperCardType)
	{
		case "VISA":	//Visa Card
			result = ((cardLen == 16) || (cardLen == 13)) && (firstdig == "4");
			break;
		case "AMEX":	//American Express
			var validNums = "47";
			result = (cardLen == 15) && (firstdig == "3") && (validNums.indexOf(seconddig)>=0);
			break;
		case "MSTR":	//MasterCard
			var validNums = "12345";
			result = (cardLen == 16) && (firstdig == "5") && (validNums.indexOf(seconddig)>=0);
			break;
		case "DISC":	//Discover
			result = (cardLen == 16) && (first4digs == "6011");
			break;
		/*
		case "DINERS":	//Diner's Club
			var validNums = "068";
			result = (cardLen == 14) && (firstdig == "3") && (validNums.indexOf(seconddig)>=0);
			break;
		*/
		default:
			return errorAlert(cardType + " is not a recognized credit card type");
			break;
	}

	/*
	if (result == true) {
		// card number seems OK so do the Mod10
		if (!checkCardNumWithMod10(cardNum)) {
			result = false;
		}
	}
	*/

	return result;
}

//Checks if a credit card field contains valid data
//	if false, pops up an alertbox and focuses on the field
function checkCCData(objField, sFieldName, sCardType) {

	//Check if it is a valid string
	if (isValidString(objField.value)) {
		sCardNum = objField.value;

		// clean up any spaces or dashes in the card number
		sCardNum = sCardNum.replace(/[-\s]/g, '');
	}
	else {
		return getFocusAlert(objField, "You must enter a valid value for " + sFieldName + ".");
	}

	if (isNaN(sCardNum) || (!isValidCCNum(sCardNum, sCardType))) {
		return getFocusAlert(objField, "You must enter a valid value for " + sFieldName + ".");
	} else {
		// set the field value to the updated value
		objField.value = sCardNum;
		return true;
	}
}

//check for valid US Zipcode
function isValidZipcode(strZipCode) {
  	var result = false;

	if (isValidString(strZipCode)) {
		var objRegExp  = /(^\d{5}$)|(^\d{5}-\d{4}$)/;
		result = objRegExp.test(strZipCode);
	}
	return result;
}

function textAreaMaxLength(textObj, len)
{

	if (textObj.value.length > len)
	{
		alert('Only a maximum of ' + len + ' characters allowed');
		textObj.value=textObj.value.substring(0,len);
		return false;

    }

	return true;
}
