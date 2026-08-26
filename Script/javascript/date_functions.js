/*
<SCRIPT SRC="/Script/javascript/date_functions.js"></SCRIPT>
*/

/*
dependency function isValidDate() in
<SCRIPT SRC="/Script/javascript/validateFormUtils.js"></SCRIPT>
*/
function build_Date(dateStr)
{
	var returnVal = null;
	var arDate = dateStr.split("/");
	if(arDate.length > 2)
	{
		if(arDate[1].length > 0 && arDate[0].length > 0 && arDate[2].length > 0)
		{
			if(isValidDate(arDate[1], arDate[0], arDate[2]))
			{
				arDate[0] = parseInt(arDate[0], 10);
				arDate[0] = arDate[0] - 1;
				var returnVal = new Date(arDate[2], arDate[0], arDate[1]);
			}
		}
	}
	return returnVal;
}

function days_between(date1, date2, bNotAbs) {

    // The number of milliseconds in one day
    var ONE_DAY = 1000 * 60 * 60 * 24	
    // Convert both dates to milliseconds
    var date1_ms = date1.getTime()
    var date2_ms = date2.getTime()

	var lNotAbs = false;
	if(arguments.length >= 3)
	{
		lNotAbs = bNotAbs;
	}
	
	var difference_ms = date1_ms - date2_ms;
	// Calculate the difference in milliseconds
	if(!lNotAbs)
	{    
    	var difference_ms = Math.abs(difference_ms);
	}
    
    // Convert back to days and return	
	//alert(date1_ms + "\n" + date2_ms + "\n" + difference_ms);
    return Math.round(difference_ms/ONE_DAY)

}

function dateAdd(datePart, date1, addThis)
{
	var retVal;
	var Modifier = 1000;
	var ONE_DAY = 1000 * 60 * 60 * 24;
	if(datePart == "d")//day
	{
		Modifier = 1000 * 60 * 60 * 24;
	}
	else if(datePart == "h")//hour
	{
		Modifier = 1000 * 60 * 60;
	}
	else if(datePart == "n")//minute
	{
		Modifier = 1000 * 60;
	}
	else if(datePart == "s")//second
	{
		Modifier = 1000;
	}
	else if(datePart == "y")//year
	{
		Modifier = 1000 * 60 * 60 * 24 * 365;
	}
	Modifier = Modifier * addThis;
	retVal = new Date(date1.valueOf() + Modifier);
	
	if(datePart == "d")//day
	{	
		var date2 = new Date(retVal.getFullYear(), retVal.getMonth(), retVal.getDay());
		var date1_ms = date1.getTime()
	    var date2_ms = date2.getTime()
		var difference_ms = date1_ms - date2_ms;
		var reminder = difference_ms % ONE_DAY;
		reminder = reminder / (1000 * 60 * 60);
		if(reminder == 23)
		{
			retVal = dateAdd("h", retVal, 1);
		}
	}	
	return retVal;
}

//**************************************************************************************
//        Name: formatDate
//              
// Description: Formats a date using a format string. 
//              d or dd represents the day of the month (eg 1 or 01)
//              m or mm represents the month as a number (eg 1 or 01)
//              mmm or mmmm represents the month as a string (eg Jan or January)
//              y or yy represents the year (eg 99 or 1999)
//              w or ww represents the day of the week (eg Mon or Monday)
//              example: formatDate(myDate, "mm/dd/yy") might look like 01/01/2000
//  Parameters: strFullDate - required - the date to display (a date object)
//          strFormatString - required - a format string
//              
//**************************************************************************************
function formatDate(strFullDate, strFormatString) 
{

	var strMonths = new Array();
	var strDay = new Array();
	
	strMonths[0]  = "January";
	strMonths[1]  = "February";
	strMonths[2]  = "March";
	strMonths[3]  = "April";
	strMonths[4]  = "May";
	strMonths[5]  = "June";
	strMonths[6]  = "July";
	strMonths[7]  = "August";
	strMonths[8]  = "September";
	strMonths[9]  = "October";
	strMonths[10] = "November";
	strMonths[11] = "December";
	
	strDay[0]  = "Sunday";
	strDay[1]  = "Monday";
	strDay[2]  = "Tuesday";
	strDay[3]  = "Wednesday";
	strDay[4]  = "Thursday";
	strDay[5]  = "Friday";
	strDay[6]  = "Saturday";
	
	var strValue_d    = strFullDate.getDate();
	var strValue_dd   = (strValue_d < 10) ? '0' + strValue_d : strValue_d;
	var strValue_m    = strFullDate.getMonth() + 1;
	var strValue_mm   = (strValue_m < 10) ? '0' + strValue_m : strValue_m;
	var strValue_mmmm = strMonths[strFullDate.getMonth()];
	var strValue_mmm  = strValue_mmmm.substr(0,3);
	var strValue_yy   = strFullDate.getFullYear() + "";
	var strValue_y    = strValue_yy.substr(2,2);
	var strValue_ww   = strDay[strFullDate.getDay()];
	var strValue_w    = strValue_ww.substr(0,3);
	
	if (strFormatString.indexOf("dd") > -1) {
	strFormatString = strFormatString.replace("dd", "strValue_dd");
	}
	else {
	if (strFormatString.indexOf("d") > -1) {
	strFormatString = strFormatString.replace("d", "strValue_d");
	}
	}
	
	if (strFormatString.indexOf("mmmm") > -1) {
	strFormatString = strFormatString.replace("mmmm", "strValue_mmmm");
	}
	else {
	if (strFormatString.indexOf("mmm") > -1) {
	strFormatString = strFormatString.replace("mmm", "strValue_mmm");
	}
	else {
	if (strFormatString.indexOf("mm") > -1) {
	strFormatString = strFormatString.replace("mm", "strValue_mm");
	}
	else {
	if (strFormatString.indexOf("m") > -1) {
	 strFormatString = strFormatString.replace("m", "strValue_m");
	}
	}
	}
	}
	
	if (strFormatString.indexOf("yy") > -1) {
	strFormatString = strFormatString.replace("yy", "strValue_yy");
	}
	else {
	if (strFormatString.indexOf("y") > -1) {
	strFormatString = strFormatString.replace("y", "strValue_y");
	}
	}
	
	if (strFormatString.indexOf("ww") > -1) {
	strFormatString = strFormatString.replace("ww", "strValue_ww");
	}
	else {
	if (strFormatString.indexOf("w") > -1) {
	strFormatString = strFormatString.replace("w", "strValue_w");
	}
	}
	
	strFormatString = strFormatString.replace("strValue_dd", strValue_dd);
	strFormatString = strFormatString.replace("strValue_d", strValue_d);
	strFormatString = strFormatString.replace("strValue_mmmm", strValue_mmmm);
	strFormatString = strFormatString.replace("strValue_mmm", strValue_mmm);
	strFormatString = strFormatString.replace("strValue_mm", strValue_mm);
	strFormatString = strFormatString.replace("strValue_m", strValue_m);
	strFormatString = strFormatString.replace("strValue_yy", strValue_yy);
	strFormatString = strFormatString.replace("strValue_y", strValue_y);
	strFormatString = strFormatString.replace("strValue_ww", strValue_ww);
	strFormatString = strFormatString.replace("strValue_w", strValue_w);
	
	return strFormatString;
}

function getLastDayOfMonth(date,month)
{ 
	var daysofmonth   = new Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
	var daysofmonthLY = new Array(31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
	
	var thisDate = new Date(date);
	var year = y2k(thisDate.getFullYear());
	
	if (LeapYear(year)) 
	{
  		daysofmonth = daysofmonthLY;
	}
	
	return daysofmonth[month];
}

function LeapYear(year) 
{
    if ((year/4) != Math.floor(year/4)) return false;
    if ((year/100) != Math.floor(year/100)) return true;
    if ((year/400) != Math.floor(year/400)) return false;
    return true;
}

function y2k(number)
{ 
	return (number < 1000) ? number + 1900 : number; 
}

Date.prototype.addDays = function (days) {
	var date = new Date(this.valueOf());
	date.setDate(date.getDate() + days);
	return date;
}

