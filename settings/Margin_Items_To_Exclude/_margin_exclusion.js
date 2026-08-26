// JavaScript Document

///////////////////////////////////   Submit //////////////////////////////////////////	
function submitEdit(MarginItemExclusionID)
{
  var actionFrm = document.DataForm;
	actionFrm.MarginItemExclusionID.value = MarginItemExclusionID;
	actionFrm.returnTo.value = actionFrm.display.value;
  actionFrm.display.value = 'edit';
	actionFrm.submit();
	return false;
}


function submitDataForm(action, compId, editMode)
{
	var actionFrm = document.DataForm;
		
	//if action is edit set the compId hidden value, then reset the action to the existing state
	if (action == "edit")
	{
		actionFrm.compId.value = compId;
		actionFrm.returnTo.value = actionFrm.display.value;
	}
 
	/* else if (action == "busRule")
	{
		actionFrm.ruleId.value = compId;
		actionFrm.editMode.value = editMode;
	}
*/	
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
 
	actionFrm.display.value = action;
	actionFrm.submit();
	return false;
}


///////////////////////////////////   Delete Component //////////////////////////////////////////		
function deleteRec(MarginItemExclusionID)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to delete the selected Record?"))
	{
		actionFrm.MarginItemExclusionID.value = MarginItemExclusionID;
		actionFrm.command.value = 'delete';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Deactivate Selected List of Components //////////////////////////////////////////		
function deactivateSelRecs()
{
	var actionFrm = document.DataForm;
		
	if(!Any_Object_Checked(DataForm.CID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to deactivate the selected Records?"))
	{
					
		actionFrm.command.value = 'deactSel';
		actionFrm.display.value = 'active';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Deactivate Single Record  //////////////////////////////////////////		
function deactivateRec(MarginItemExclusionID)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to deactivate the selected Record?"))
	{
		actionFrm.MarginItemExclusionID.value = MarginItemExclusionID;
		actionFrm.command.value = 'deact';
		actionFrm.display.value = 'active';
			actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Activate Selected List of records //////////////////////////////////////////	
function activateSelRecs()
{

	var actionFrm = document.DataForm;
		
	if(!Any_Object_Checked(DataForm.CID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to activate the selected Records?"))
	{
					
		actionFrm.command.value = 'actSel';
		actionFrm.display.value = 'inActive';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Activate Single Component //////////////////////////////////////////	
function activateRec(MarginItemExclusionID)
{
	var actionFrm = document.DataForm;
	if(confirm("Do you really want to activate the selected Record?"))
	{
		actionFrm.MarginItemExclusionID.value = MarginItemExclusionID;
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
 

/**********      FUNCTION THAT WERE ADDED NEW FOR    ********************** ***/

  function showProductSearchWindow() 
  {
	  NewWindow("product_Select_V1.cfm?Formname=MyForm&Discountype=1", "productwindow", 800, 600, "yes", "yes", true)			
	}
  
  
  function submitForm(command, subCommand)
  {
  	var thisForm = document.groupDataForm;
  	var grpLevl1 = thisForm.GroupLevel_1.value;

	//handle for get groups
	if(subCommand == 'getGroups')
	{
		var currGrp = thisForm.GroupLevel_1.value;

		var groupCombinationOn = 0;
		var groupCombinationOnObj = eval("thisForm.groupCombinationOn");
		if(groupCombinationOnObj.value == 1)
		{
			groupCombinationOn = 1;
		}

		if(groupCombinationOn == 1)
		{
			var anySelected = checkGroupOfGroupsMemberSelection();
			if(!anySelected)
			{
				alert("Please set a group name");
				return false;
			}
			var selGrp = thisForm.GroupLevel.value;
		}
		else
		{
			var selGrp = thisForm.GroupLevel.options[thisForm.GroupLevel.selectedIndex].value;
		}
	
 
		if (currGrp != selGrp && currGrp!= "")
		{
			if(confirm("You will lose your current selection. Do you want to continue?"))
			{
				//thisForm.GroupLevel_1.value = selGrp;
				thisForm.clearLevel.value = 1;
			}
			else
			{
				return;
			}
		}
	}
	
	if(command == 'import' || command == 'validate_import')
	{
		if(grpLevl1 == "")
		{
			alert("You must add a Group to a pricing level before importing.");
			return;
		}
	}
	
	//set the action value then submit	
	thisForm.command.value = command;
	thisForm.sub_command.value = subCommand;
	thisForm.submit();
}

