<!---
\Script\cf\margin_functions.cfm
---->
<cfscript>
	//make value = 0 if the value is empty or null
	function makeNumeric(sVal)
	{
		var returnValue = sVal;
		if(Len(Trim(returnValue)) EQ 0 OR NOT isNumeric(returnValue))
		{
			returnValue = 0;
		}
		return returnValue;
	}
	function marginDisplay(num, denom) {
		returnValue = "";
		num = vaildateNumber(num);
		denom = vaildateNumber(denom);
		
		if(denom EQ 0) {
			returnValue = "";
		}
		else{
			//num = (num) * 100000;
			//denom = (denom) * 100000;
			tempB =  (num)/(denom);
			tempB = tempB * 100;
			tempB = trim(numberformat((tempB), '_-___._'));
			returnValue = tempB;
			//returnValue = (returnValue)*(-1);
		}
		
		return returnValue;
	}
	function vaildateNumber(number){
		if(isnumeric(number) EQ False) {
			return 0;
		}
		else {
			return trim(numberformat(number, '_-________.____'));
		}
	}	
</cfscript>