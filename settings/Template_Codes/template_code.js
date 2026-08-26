// JavaScript Document

///////////////////////////////////   Submit //////////////////////////////////////////	
function submitDataForm(action,compId)
{
	var actionFrm = document.DataForm;
		
	//if action is edit set the compId hidden value, then reset the action to the existing state
	if (action == "edit")
	{
		actionFrm.compId.value = compId;
		actionFrm.returnTo.value = actionFrm.display.value;
	}
	if (action == "add")
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

///////////////////////////////////   Add Component //////////////////////////////////////////		
function addComp()
{
	
	var actionFrm = document.DataForm;
		
	//do validation
	if (trim(actionFrm.compName.value) == "")
	{
		alert("Please provide a template code");
		return false;
	}
		
	//set hidden form fields and submit
	actionFrm.command.value = 'addComp';
	actionFrm.display.value = 'active';
	actionFrm.submit();
	return false;	
}

///////////////////////////////////   Delete Component //////////////////////////////////////////		
function deleteComp(compId)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to delete the selected template code?"))
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
	if(confirm("Do you really want to deactivate the selected template codes?"))
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

	if(confirm("Do you really want to deactivate the selected template code?"))
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
	if(confirm("Do you really want to activate the selected template code?"))
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

	if(confirm("Do you really want to deactivate the selected template code?"))
	{
		actionFrm.compId.value = compId;
		actionFrm.command.value = 'act';
		actionFrm.display.value = 'inActive';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Update Component //////////////////////////////////////////
function upadateComp(compId)
{

	var actionFrm = document.DataForm;

	if (trim(actionFrm.compName.value) == "")
	{
		alert("Please provide a template code");
		return false;
	}
	actionFrm.compId.value = compId;
	actionFrm.command.value = 'update';
	actionFrm.display.value = actionFrm.returnTo.value;
	actionFrm.submit();
	return false;
}

///////////////////////////////////   Select All Checkboxes //////////////////////////////////////////
function selectAll(thisObj)
{
	var chObjs = document.all.CID;
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