<cfscript>
function padValues(theString,theLength,padChar)
{
	var stringLen = len(theString);
	var lenDiff = theLength - stringLen;
	var ReturnValue = theString;
	
	if (lenDiff LT 0)
	{
		ReturnValue = left(theString, theLength);
	}
	else
	{
		ReturnValue = theString & repeatString(padChar, lenDiff);
	}
	return ReturnValue;
}
</cfscript>