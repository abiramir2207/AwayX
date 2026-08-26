<!---This is the total allowance popup window--->
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
</cfscript>