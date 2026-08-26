// JavaScript Document

///////////////////////////////////   Submit //////////////////////////////////////////	
function submitDataForm(action, compId, editMode)
{
	var actionFrm = document.DataForm;
		
	//if action is edit set the compId hidden value, then reset the action to the existing state
	if (action == "edit")
	{
		actionFrm.compId.value = compId;
		actionFrm.returnTo.value = actionFrm.display.value;
	}
	
	else if (action == "applyBusRule")
	{
		actionFrm.compId.value = compId;
	}
	
	else if (action == "busRule")
	{
		actionFrm.ruleId.value = compId;
		actionFrm.editMode.value = editMode;
	}
	
	else if (action == "add")
	{
		if(actionFrm.compExternalID)
		{
			actionFrm.compExternalID.value = "";
		}
		if(actionFrm.compName)
		{
			actionFrm.compName.value = "";
		}		
	}	
	
	else if (action == "editProfileRestrict")
	{
		actionFrm.compId.value = compId;
	}
	
	actionFrm.display.value = action;
	actionFrm.submit();
	return false;
}


///////////////////////////////////   Delete Component //////////////////////////////////////////		
function deleteComp(compId)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to delete the selected component?"))
	{
		actionFrm.compId.value = compId;
		actionFrm.command.value = 'delete';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Deactivate Selected List of Components //////////////////////////////////////////		
function deactivateSelComps()
{
	var actionFrm = document.DataForm;
		
	if(!Any_Object_Checked(DataForm.CID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to deactivate the selected components?"))
	{
					
		actionFrm.command.value = 'deactSel';
		actionFrm.display.value = 'active';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Deactivate Single Component //////////////////////////////////////////		
function deactivateComp(compId)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to deactivate the selected component?"))
	{
		actionFrm.compId.value = compId;
		actionFrm.command.value = 'deact';
		actionFrm.display.value = 'active';
			actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Activate Selected List of Components //////////////////////////////////////////	
function activateSelComps()
{

	var actionFrm = document.DataForm;
		
	if(!Any_Object_Checked(DataForm.CID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to activate the selected components?"))
	{
					
		actionFrm.command.value = 'actSel';
		actionFrm.display.value = 'inActive';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Activate Single Component //////////////////////////////////////////	
function activateComp(compId)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to deactivate the selected component?"))
	{
		actionFrm.compId.value = compId;
		actionFrm.command.value = 'act';
		actionFrm.display.value = 'inActive';
		actionFrm.submit();
		return false;
	}
		
	return false;
}


///////////////////////////////////   Apply rules to Component //////////////////////////////////////////	
function applyRules(compId)
{

	var actionFrm = document.DataForm;
		
	if(!Any_Object_Checked(DataForm.rule_ids))
	{
		alert("You haven't selected any items.");
		return false;
	}
	
	actionFrm.compId.value = compId;
	actionFrm.command.value = 'applyRules';				
	actionFrm.display.value = 'active';
	actionFrm.submit();
	return false;
}

///////////////////////////////////   Apply rules to Component //////////////////////////////////////////	
function applyProfiles(compId)
{

	var actionFrm = document.DataForm;
	
	actionFrm.compId.value = compId;
	actionFrm.command.value = 'applyProfiles';				
	actionFrm.display.value = 'active';
	actionFrm.submit();
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

function searchGL(ExistingGLList,Action)
{
	var ExistingGLs = document.all.DataForm.ExistingGLList.value;
	
	var urlToOpen = "/settings/GL_Account/GL_Account_Search.cfm?ExistingGLList=" + ExistingGLs + "&action=" + Action
	NewWindow(urlToOpen, "GL_Search", 500, 300, "yes", "yes")	
	return false;
}

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
}
	

	
