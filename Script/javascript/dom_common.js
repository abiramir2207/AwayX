/*
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
*/
function Any_Object_Checked(chObj)
{
	var chLen, i;
	var returnValue = false;
	if(chObj)
	{
		chLen = chObj.length;
		if(chLen)
		{
			for(i=0;i<chLen;i++)
			{
				if(chObj[i].checked)
				{
					returnValue = true;
					break;
				}
			}
		}
		else
		{
			if(chObj.checked)
			{
				returnValue = true;
			}
		}
	}	
	return returnValue;
}

function Any_Object_Checked_Value(chObj)
{
	var chLen, i;
	var returnValue = "";
	if(chObj)
	{
		chLen = chObj.length;
		if(chLen)
		{
			for(i=0;i<chLen;i++)
			{
				if(chObj[i].checked)
				{
					returnValue = chObj[i].value;
					break;
				}
			}
		}
		else
		{
			if(chObj.checked)
			{
				returnValue = chObj.value;
			}
		}
	}	
	return returnValue;
}

function Not_Any_Object_Checked(chObj)
{
	var chLen, i;
	var returnValue = true;
	if(chObj)
	{
		chLen = chObj.length;
		if(chLen)
		{
			for(i=0;i<chLen;i++)
			{
				if(!chObj[i].checked)
				{
					returnValue = false;
					break;
				}
			}
		}
		else
		{
			if(!chObj.checked)
			{
				returnValue = false;
			}
		}
	}	
	return returnValue;
}

function Any_Object_Property_Match(CollObj, propName, matchVal)
{
	var colLen, i;
	var returnValue = false;
	var propVal;
	if(CollObj)
	{
		colLen = CollObj.length;
		if(colLen)
		{
			for(i=0;i<colLen;i++)
			{
				propVal = eval("CollObj[i]." + propName);
				if(propVal == matchVal)
				{
					returnValue = true;
					break;
				}
			}
		}
		else
		{
			propVal = eval("CollObj." + propName);
			if(propVal == matchVal)
			{
				returnValue = true;
			}
		}
	}	
	return returnValue;
}

function Get_Object_Property_Match_Collection(CollObj, propName, matchVal)
{
	var colLen, i;
	var returnValue = 0;
	var propVal;
	if(CollObj)
	{
		colLen = CollObj.length;
		if(colLen)
		{
			for(i=0;i<colLen;i++)
			{
				propVal = eval("CollObj[i]." + propName);
				if(propVal == matchVal)
				{
					returnValue = CollObj[i];
					break;
				}
				else
				{
				returnValue = 0;
				}
			}
		}
		else
		{
			propVal = eval("CollObj." + propName);
			if(propVal == matchVal)
			{
				returnValue = CollObj;
			}				
			else
			{
			returnValue = 0;
			}
		}
	}	
	return returnValue;
}

function CHSelectAll(name_start, bCheck)
{
	var inpColl = document.getElementsByTagName("INPUT");
	var inpCollLen = inpColl.length;
	var thisObj;
	for (var i=0;i<inpCollLen;i++)
	{
		thisObj = inpColl[i];
		if (thisObj.type == 'checkbox') 
		{
			if(thisObj.name.substr(0, name_start.length) == name_start)
			{
				thisObj.checked = bCheck;
			}
		}
	}
}

function ApplyValueForAll(input_name_start, iValue, checkbox_name_Start)
{
	var inpColl = document.getElementsByTagName("INPUT");
	var inpCollLen = inpColl.length;
	var thisObj, chObj, bChange;
	for (var i=0;i<inpCollLen;i++)
	{
		bChange = false;
		thisObj = inpColl[i];
		if (thisObj.type == 'text') 
		{
			if(thisObj.name.substr(0, input_name_start.length) == input_name_start)
			{
				if(checkbox_name_Start.length > 0)
				{
					chObj = eval("document.all." + checkbox_name_Start + thisObj.name.substr(input_name_start.length));
					if(chObj)
					{
						if(chObj.checked)
						{
							bChange = true;
						}
					}
				}
				else
				{
					bChange = true;
				}
				if(bChange)
				{
					thisObj.value = iValue;
				}
			}
		}
	}
}

function Get_Select_Index(SelObj, matchVal)
{
	var opts = SelObj.options;
	var optLen = opts.length;
	var i;
	var retVal = -1;
	for(i=0;i<optLen;i++)
	{
		if(opts[i].value.toLowerCase() == matchVal.toLowerCase())
		{
			retVal = i;
			break;
		}
	}
	return retVal;
}

function Any_Object_Like_Name_Checked(chNameStart)
{
	var inpColl = document.getElementsByTagName("INPUT");
	var chLen, i, thisObj;	
	var returnValue = false;
	chLen = inpColl.length;
	for (var i=0;i<chLen;i++)
	{
		thisObj = inpColl[i];
		if (thisObj.type == 'checkbox')
		{
			if(thisObj.name.substr(0, chNameStart.length) == chNameStart)
			{
				if(thisObj.checked)
				{
					returnValue = true;
					break;
				}
			}
		}
	}
	return returnValue;
}

function toggle(id) {
       var e = document.getElementById(id);
       if(e.style.display == 'block')
          e.style.display = 'none';
       else
          e.style.display = 'block';
    }