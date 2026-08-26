/*
Id: /validate.js, v1.6.5 9/6/2001 9:24:12 AM dbabbitt
Description: 
	This is a modified version of the cfform scripts 
	that prevent bad data from being sent back to the 
	server. Validation functionality is continually 
	added.
*/

function validateSelection(selectionObject, message) {
	/* 
		Highlights the selection box and gives a message 
		if the value is null or zero. 
		*/
	if(selectionObject!=null) {
		var selectionIndex = selectionObject.selectedIndex;
		if(selectionIndex==-1) {var listValue = 0}
		else {var listValue = selectionObject.options[selectionIndex].value}
		if(listValue==0) {
			/* Scroll up a half a screen above the select box */
			selectionObject.scrollIntoView();
			window.scrollTo(0,document.body.scrollTop-(document.body.clientHeight/2));
			alert(message);
			if(selectionIndex!=-1) {
				selectionObject.options[selectionIndex].selected = false;
				selectionObject.options[selectionIndex + 1].selected = true;
				}
			else {
				selectionObject.options[0].selected = true;
				}
			return(false);
			}
		}
	return(true);
	}

function getErrorWindow(inputObject, objectValue, errorMessage) {
	/* opens a new window detailing the error */
	/* and focuses on the offending value */
	inputObject.focus();
	inputObject.select();
	var regExp = new RegExp("that's", "");
	/* spaces.test(objectValue) */
	// var spaces = new RegExp("\w", "");
	if(regExp.test(errorMessage)) {
		errorMessage = errorMessage.replace(regExp, "'" + objectValue + "' is")};
	alert(errorMessage);
	return false}

function convert2AllDigits(str) {
	/* Converts a string to all digits */
	if(str==''){return(str)}
	var valid = '0123456789';
	var newString = '';
	for(var i=str.length; i >= 0; i--) {
		if(valid.indexOf(str.charAt(i)) != -1) {
			newString = str.charAt(i) + newString;
			}
		}
	return(newString);
	}

function convert2PhoneNumber(str) {
	/* Converts a string to NPA-NNX-XXXX xXXXX */
	var phoneNumberArray = str.split(',');
	var phoneNumberExtension = '';
	if(phoneNumberArray.length==2) {
		phoneNumberExtension = ' X' + phoneNumberArray[1];
		}
	var oldDigits = convert2AllDigits(phoneNumberArray[0]);
	var newString = '';
	switch(oldDigits.length) {
		case 11 :
			newString = oldDigits.substring(0,1) + '-';
			oldDigits = oldDigits.substring(1,11);
		case 10 :
			newString = newString + oldDigits.substring(0,3) + '-';
			oldDigits = oldDigits.substring(3,10);
		case 7 :
			newString = newString + oldDigits.substring(0,3) + '-' + oldDigits.substring(3,7);
			break;
		}
	return(newString + phoneNumberExtension);
	}

function getWeekDay(dayValue, monthValue, yearValue) {
	/*	returns the value of the day of the week 
		(0 for a Sunday, 1 for a Monday, 2 for a Tuesday, etc.) 
		for monthValue (1 for January, 2 for February, etc.)
		/dayValue/yearValue */
	
	var a = Math.floor((14 - parseInt(monthValue))/12);
	var y = parseInt(yearValue) - a;
	var m = parseInt(monthValue) + 12*a - 2;
	/* bug fix for parseInt */
	if(dayValue=='09') {
		dayValue = 9;
		}
	var d = y + parseInt(dayValue);
	d =(d + Math.floor(y/4) - Math.floor(y/100) + Math.floor(y/400) + Math.floor((31*m)/12)) % 7;
	return(d);
	}

function updateDay(earlierObject, dayObject) {
	//updates the day of the week in the Day column
	var DateTimeIn = earlierObject.value.split(' ');
	var DateIn = DateTimeIn[0].split('/');
	var dayIn = DateIn[1];
	var monthIn = DateIn[0];
	var yearIn = DateIn[2];
	/* Get the Day of the Week - shortened to save horizontal space */
	var daysOfWeek = new Array('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
	var dow = daysOfWeek[getWeekDay(dayIn,monthIn,yearIn)];
	dayObject.innerHTML=dow;
	}

function getClockDate(clockValue) {
	/* returns the date specified by clockValue */
	/* clockValue = '3/16/2000 10:15 AM' */
	var clockArray = clockValue.split(' ');
	var clockDateArray = clockArray[0].split('/');
	var clockTimeArray = clockArray[1].split(':');
	var yearClock = parseInt(clockDateArray[2], 10);
	var monthClock = parseInt(clockDateArray[0], 10);
	var dayClock = parseInt(clockDateArray[1], 10);
	var hourClock = parseInt(clockTimeArray[0], 10);
	if(hourClock==12) {hourClock = 0};
	if(clockArray[2]=='PM') {hourClock = hourClock + 12};
	var minuteClock = parseInt(clockTimeArray[1], 10);
	return(new Date(yearClock,monthClock-1,dayClock,hourClock,minuteClock,0))};
	
function validateDate(objectValue) {
	/* returns true if value is a date in the mm/dd/yyyy format */
	isplit = objectValue.indexOf('/');
	if(isplit == -1 || isplit == objectValue.length) {
		return false};
	sMonth = objectValue.substring(0, isplit);
	isplit = objectValue.indexOf('/', isplit + 1);
	if(isplit == -1 || (isplit + 1 ) == objectValue.length) {return false};
	sDay = objectValue.substring((sMonth.length + 1), isplit);
	sYear = objectValue.substring(isplit + 1);
	// if(!validateInteger(sDay)) {return false};
	if(!validateRange(sDay, 1, 31)) {return false};
	// if(!validateInteger(sMonth)) {return false};
	if(!validateRange(sMonth, 1, 12)) {return false};
	// if(!validateInteger(sYear)) {return false};
	if(!validateRange(sYear, 0, 9999)) {return false};
	if(!validateDay(sYear, sMonth, sDay)) {return false};
	return true};
	
function validateDateTime(objectValue) {
	/* returns true if value is a datetime format or is NULL */
	if(objectValue.length == 0) {return true};
	var dateTimeArray = objectValue.split(' ');
	if(dateTimeArray.length != 3) {return false};
	var dateValue = dateTimeArray[0];
	if(!validateDate(dateValue)) {return false};
	/* don't include the AM/PM part */
	var timeValue = dateTimeArray[1];
	if(!validateTime(timeValue)) {return false};
	var ampmValue = dateTimeArray[2];
	if((ampmValue != 'AM') && (ampmValue != 'PM')) {return false};
	return true};
	
function validateDay(yearValue, monthValue, dayValue) {
	/* returns true if dayValue is a day in the month of monthValue/yearValue */
	maxDay = 31;
	if(monthValue == 4 || monthValue == 6 || monthValue == 9 || monthValue == 11) {maxDay = 30}
	else {
		if(monthValue == 2) {
			if(yearValue % 4 > 0) {maxDay =28}
			else {
				if(yearValue % 100 == 0 && yearValue % 400 > 0) {maxDay = 28}
				else {maxDay = 29}}}};
	return validateRange(dayValue, 1, maxDay)};
	
function validateExists(existsObject, objectType) {
	/* 	returns true if the existsObject actually has content for the objectType. 
		You can't call this with existsObject.type for objectType when looking 
		for single value radio buttons or checkboxes. */
	if(objectType == "text" || objectType == "password") {
		if(existsObject.value.length == 0) {return false};
		return true};
	if(objectType == "select") {
		for(i=0; i < existsObject.length; i++) {
			if(existsObject.options[i].selected) {return true}};
		return false};
	if(objectType == "SINGLE_VALUE_RADIO" || objectType == "SINGLE_VALUE_CHECKBOX") {
		if(existsObject.checked) {return true};
		return false};
	if(objectType == "radio" || objectType == "checkbox") {
		for(i=0; i < existsObject.length; i++) {
			if(existsObject[i].checked) {return true}};
		return false}};
		
function validateInteger(objectValue) {
	/* returns true if value is an integer or is NULL */
	if(objectValue.length == 0) {
		return true};
	/* returns true if value is an integer defined as */
	/* having an optional leading + or -. */
	/* otherwise containing only the characters 0-9. */
	var decimal_format = ".";
	var checkChar;
	/* The first character can be + - blank or a digit. */
	checkChar = objectValue.indexOf(decimal_format);
	/* Was it a period? */
	if(checkChar < 1) {return validateNumber(objectValue)};
	return false};
	
function validateNumber(objectValue) {
	/* returns true if value is a number or is NULL */
	if(objectValue.length == 0) {return true};
	/* returns true if value is a number defined as */
	/* having an optional leading + or -. */
	/* having at most 1 decimal point. */
	/* otherwise containing only the characters 0-9. */
	var startFormat = " .+-0123456789";
	var numberFormat = " .0123456789";
	var checkChar;
	var decimal = false;
	var trailingBlank = false;
	var digits = false;
	checkChar = startFormat.indexOf(objectValue.charAt(0));
	/* The first character must be plus minus period blank or a digit. */
	if(checkChar < 1) {return false};
	/* Was it a period? */
	if(checkChar == 1) {decimal = true;};
	/* Remaining characters can be only a period or a digit, but only one decimal. */
	for(var i = 1; i < objectValue.length; i++) {
		checkChar = numberFormat.indexOf(objectValue.charAt(i));
		if(checkChar < 0) {return false};
		if(checkChar == 1) {
			/* Second decimal */
			if(decimal) {return false};
			decimal = true}
		else {
			/* ignore leading blanks */
			if((checkChar == 0) && (decimal || digits)) {trailingBlank = true}
			else {
				if(trailingBlank) {return false};
				digits = true}}};
	/* All tests passed, so... */
	return true};
	
function validateNumberRange(objectValue, minimumValue, maximumValue) {
	/* 	returns true if objectValue is inclusively 
		between minimumValue and maximumValue */
	/* check minimum */
	if((minimumValue != null) && (objectValue < minimumValue)) {return false};
	/* check maximum */
	if((maximumValue != null) && (objectValue > maximumValue)) {return false};
	/* All tests passed, so... */
	return true};
	
function validateRange(objectValue, minimumValue, maximumValue) {
	/* returns true if objectValue is within the number range */
	if(objectValue.length == 0) {return true};
	if(!validateNumber(objectValue)) {return false};
	return(validateNumberRange((eval(objectValue)), minimumValue, maximumValue))};
	
function validateTime(objectValue) {
	/* returns true if objectValue is a time in the hh:mm format */
	var timeArray = objectValue.split(':');
	if(timeArray.length != 2) {return false};
	var sHour = timeArray[0];
	if(sHour.length == 0) {return false};
	// if(!validateInteger(sHour)) {return false};
	if(!validateRange(sHour, 1, 12)) {return false};
	var sMinute = timeArray[1];
	if(sMinute.length == 0) {return false};
	// if(!validateInteger(sMinute)) {return false};
	if(!validateRange(sMinute, 0, 59)) {return false};
	return true};
	
function validateTimeSpan(earlierValue, laterValue) {
	/* returns true if earlierValue is a datetime earlier in the era than laterValue */
	var earlierDate = getClockDate(earlierValue);
	var laterDate = getClockDate(laterValue);
	return(earlierDate <= laterDate);
	}
	
// general purpose function to see if a suspected numeric input
// is a positive or negative number
function isPosNumber(inputVal) {
	oneDecimal = false
	inputStr = inputVal.toString()
	for (var i = 0; i < inputStr.length; i++) {
		var oneChar = inputStr.charAt(i)
		if (i == 0 && oneChar != "-") {
			continue;
		}
		if (oneChar == "." && !oneDecimal) {
			oneDecimal = true;
			continue;
		}
		if (oneChar < "0" || oneChar > "9") {
			return false;
		}
	}
	return true;
}

// general purpose function to see if a suspected numeric input
// is a positive integer
function isPosInteger(inputVal) {
	inputStr = inputVal.toString()
	for (var i = 0; i < inputStr.length; i++) {
		var oneChar = inputStr.charAt(i)
		if (oneChar < "0" || oneChar > "9") {
			return false
		}
	}
return true
}

/*
	Log: /validate.js
	Revision 1.8 2/25/2002 4:51:14 PM dbabbitt
	Added the isPosNumber & isPosInteger functions 
	which validate positive integers and floats.
	
	Revision 1.7 7/10/2001 10:27:48 AM dbabbitt
	Moved the update day function from the 
	schedule search form page, and the schedule 
	entry approval form page.
	
	Revision 1.6 7/2/2001 11:36:09 AM dbabbitt
	Now the convert to phone number function 
	handles extentions.
	
	Revision 1.5 2/14/2001 6:15:07 PM dbabbitt
	Added the validate selection function.
	
	Revision 1.4 10/26/00 3:20:02 PM dbabbitt
	Teased out a convert to all digits 
	function from the convert phone number 
	function. 
	
	Revision 1.3 10/19/00 2:21:59 PM dbabbitt
	Added the get error window function.
	
	Revision 1.2 9/27/00 5:53:00 PM dbabbitt
	Added the get week day function.
	
	Revision 1.1 9/22/00 7:57:12 PM dbabbitt
	Added the convert phone number junction.
	
	Revision 1.0 6/19/00 12:15:01 PM dbabbitt
	This is a modified version of the cfform 
	scripts that prevent bad data from being 
	sent back to the server.
	*/