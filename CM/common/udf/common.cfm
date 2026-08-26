<cfscript>
	/*******************************************************************************************
	Output inputy type=Hidden 
	with name="Master_#sName#"
	and 
	avlue=sVal
	*******************************************************************************************/
	function writeMasterHidden(sName, sVal)
	{
		WriteOutput("<input type=""hidden"" name=""Master_" & sName & """ value=""" & sVal & """ />");
	}
	/*******************************************************************************************
	if both values are same, return ""
	if both are different, return first value
	*******************************************************************************************/
	function checkSameValue(sVal1, sVal2)
	{
		var retVal = "";
		if(CompareNoCase(sVal1, sVal2))
		{
			retVal = sVal1;
		}
		return retVal;
	}
</cfscript>