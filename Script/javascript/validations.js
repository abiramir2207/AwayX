/*
//validations.js
//<script src="/script/javascript/validations.js"></script>
//AnyRadioChecked(chObj);
*/
function AnyRadioChecked(chObj)
{
	var i;
	var returnValue = false;
	if(chObj)
	{
		var chLen = chObj.length;
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
		{
			if(chObj.checked)
			{
				returnValue = true;
			}
		}
	}
	return returnValue;
}
