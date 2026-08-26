<CFSCRIPT>
	function Get_Message_Number(mNumber)
	{
		padLen = 5;
		return_Value = "";
		return_Value =  Right(RepeatString("0", padLen) & mNumber,padLen);
		return_Value = ReplaceNoCase(return_Value, " ","0");
		return return_Value;
		
	}
</CFSCRIPT>