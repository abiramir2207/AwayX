/*
<SCRIPT SRC="/Script/javascript/math_functions.js"></SCRIPT>
*/

function removeExponentialFormatting(iVal, decimalLen)
{
	var returnString = iVal;
	var sStr = iVal + "";
	if(arguments.length < 2)
	{
		decimalLen = 2;
	}
	//1.6393442622950821e+25
	var sAr = sStr.split(".");
	if(sAr.length > 1)
	{
		returnString = sAr[0];
		sStr = sAr[1];
		sAr = sStr.split("e+");
			var expPart2;
			var expPart1 = sAr[0];
			if(sAr.length > 1)
			{
				expPart2 = parseInt(sAr[1], 10);
			}
			else
			{
				expPart2 = 0;
			}
			
			returnString = returnString + PadString(expPart1, expPart2 + decimalLen, "0", false);
			returnString2 = returnString;
			var nonDecimalPart = returnString.substr(0, returnString.length - decimalLen);
			var decimalPart = returnString.substr(returnString.length - decimalLen);
			returnString1 = returnString;
			returnString = nonDecimalPart + "." + decimalPart;
			
		
	}
	return returnString;
}


function addNumbers() {
	var total = 0, precision = 0;
      
  // loop through the value and total them
  for (var i = 0; i < arguments.length; i++) {
        // check for decimals and check the precision
        var p = arguments[i].toString().match(/\.\d+$/gi), len = (p) ? p[0].length-1 : 0;
        // track the highest level of precision
        if( len > precision ) 
        	precision = len; 
        // we add 0 to the value to ensure we get a numberic value
        total += arguments[i];
  }
  
  // fix any the precision errors
  if( precision ) 
  	total = Number(total.toFixed(precision));
  
  return total;
}
