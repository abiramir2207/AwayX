function commodityCheckOnLoad(thisForm)
{
	var i,mainObjChk;
	
	<cfoutput>
	<cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
		mainObjChk=thisForm.Commodity_Settings_#i#.checked;
		disableThisCheck(thisForm.Commodity_Price_Rule_View_#i#,mainObjChk);
		disableThisCheck(thisForm.Commodity_Price_Rule_Create_Edit_#i#,mainObjChk);		
	</cfloop>
	</cfoutput>
}


function disableCheck()
{
	return false;
}

function disableThisCheck(chObj,bEnable)
{
	if(bEnable)
	{
		chObj.disabled = false;
	}
	else
	{
		chObj.checked = bEnable;
		chObj.disabled = true;
	}
}

function commodityCheck(thisObj)
{
	var mainObjChk = thisObj.checked;
	//thisIndex 
	var underScoreIndex = thisObj.name.lastIndexOf("_");
	if(underScoreIndex > 0)
	{
		var thisIndex = thisObj.name.substr(underScoreIndex+1);
		thisIndex = parseInt(thisIndex);
		if(!isNaN(thisIndex))
		{
			var thisForm = thisObj.form;
			disableThisCheck(eval("thisForm.Commodity_Price_Rule_View_" + thisIndex),mainObjChk);
			disableThisCheck(eval("thisForm.Commodity_Price_Rule_Create_Edit_" + thisIndex),mainObjChk);
		}
	}
}