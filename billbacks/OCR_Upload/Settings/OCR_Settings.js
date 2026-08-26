// JavaScript Document

///////////////////////////////////   Submit //////////////////////////////////////////	
function submitDataForm(action, settingId, editMode)
{
	var actionFrm = document.DataForm;
		
	//if action is edit set the SettingId hidden value, then reset the action to the existing state
	if (action == "edit")
	{
		actionFrm.settingId.value = settingId;
		actionFrm.returnTo.value = actionFrm.display.value;
		
		actionFrm.command.value = 'editOCRSetting';
		actionFrm.display.value = 'edit';
		actionFrm.submit();
	}
	
	else if (action == "add")
	{
		if(actionFrm.settingExternalID)
		{
			actionFrm.settingExternalID.value = "";
		}
		if(actionFrm.settingName)
		{
			actionFrm.settingName.value = "";
		}		
	}	
	actionFrm.display.value = action;
	actionFrm.submit();
	return false;
}


///////////////////////////////////   Delete Setting //////////////////////////////////////////		
function deleteSetting(OCRTemplateSettingsID)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to delete the selected setting?"))
	{
		actionFrm.settingId.value = settingId;
		actionFrm.command.value = 'delete';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Deactivate Selected List of Settings //////////////////////////////////////////		
function deactivateSelSetting()
{
	var actionFrm = document.DataForm;
		
	if(!Any_Object_Checked(DataForm.CID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to deactivate the selected settings?"))
	{
					
		actionFrm.command.value = 'deactSel';
		actionFrm.display.value = 'active';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Deactivate Single Setting //////////////////////////////////////////		
function deactivateSetting(settingId)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to deactivate the selected setting?"))
	{
		actionFrm.settingId.value = settingId;
		actionFrm.command.value = 'deact';
		actionFrm.display.value = 'active';
			actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Activate Selected List of Settings //////////////////////////////////////////	
function activateSelSetting()
{

	var actionFrm = document.DataForm;
		
	if(!Any_Object_Checked(DataForm.CID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to activate the selected settings?"))
	{
		actionFrm.command.value = 'actSel';
		actionFrm.display.value = 'inActive';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Activate Single Setting //////////////////////////////////////////	
function activateSetting(settingId)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to deactivate the selected setting?"))
	{
		actionFrm.settingId.value = OCRTemplateSettingsID;
		actionFrm.command.value = 'act';
		actionFrm.display.value = 'inActive';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

 

///////////////////////////////////   Select All Checkboxes //////////////////////////////////////////
function selectAll(thisObj, objToChk)
{
	var chObjs = eval("document.all." + objToChk);
	var bCheck = thisObj.checked;
	var i;
	if(chObjs)
	{
		if(chObjs.length)
		{
			for(i=0;i<chObjs.length;i++)
			{
				chObjs[i].checked = bCheck;
			}
		}
		else
		{
			chObjs.checked = bCheck;
		}
	}
}

/*function searchGL(ExistingGLList,Action)
{
	var ExistingGLs = document.all.DataForm.ExistingGLList.value;
	
	var urlToOpen = "/settings/GL_Account/GL_Account_Search.cfm?ExistingGLList=" + ExistingGLs + "&action=" + Action
	NewWindow(urlToOpen, "GL_Search", 500, 300, "yes", "yes")	
	return false;
}
*/
function trim(sStr)
{
	return sStr.replace(/^\s*/ig, "").replace(/\s*$/ig, "");
}

function ListFindItem1(sList, delimiter, findItem)
{	
	var resultString = sList;
	var Arr = sList.split(delimiter);
	var i, arrLen;		
	arrLen = Arr.length;
	if (sList.length > 0)
	{
	for(i=0;i<arrLen;i++)
	{	
		if(trim(Arr[i]) == findItem)
		{
			return i;
		}
	}
	}
	return -1;
}

function ListDeleteItem1(sList, delimiter, deleteItem)
{	
	var resultString = sList;
	var Arr = sList.split(delimiter);
	var i, arrLen;
	var iExitOnFirstFind = 1;

	arrLen = Arr.length;
	for(i=arrLen-1;i>=0;i--)
	{
		if(Arr[i] == deleteItem)
		{
			Arr.splice(i, 1);			
			if(iExitOnFirstFind == 1)
			{
				resultString = Arr.join(delimiter);
				return trim(resultString);
			}
		}
	}
	resultString = Arr.join(delimiter);
	return resultString;
}

/*
function deleteGL(GL_Account_ID)
{	
	event.returnValue = false;
	
	var GLList = document.all.DataForm.GLList;
 	var resultstring = GLList.value;
	var ExistingGLList = document.all.DataForm.ExistingGLList;
	var bDelete = ListFindItem1(resultstring, ",", GL_Account_ID)
	var trObj = document.getElementById(GL_Account_ID);
	var srcObj = event.srcElement;
	

if(bDelete <0) //delete
	{	//alert(resultstring.length)
		if(resultstring.length < 1)
		{
			resultstring = GL_Account_ID;
		}
		else
		{
			resultstring = resultstring + "," + GL_Account_ID; 
		}	

		
		trObj.style.backgroundColor = "#CCCCCC";
		trObj.style.textDecoration = "line-through";
		srcObj.src = undodeleteImg.src;
		srcObj.title = "undo delete";
	}
	else //undelete
	{
		resultstring = ListDeleteItem1(resultstring, ',', GL_Account_ID)
		trObj.style.backgroundColor = "WhiteSmoke";
		trObj.style.textDecoration = "none";
		srcObj.src = deleteImg.src;
		srcObj.title = "delete this item";
	}
	GLList.value = resultstring;
}*/
	

	
