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
		alert("Please provide a account program type name");
		return;
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
	if(confirm("Do you really want to activate the selected names?"))
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

	if(confirm("Do you really want to activate the selected name?"))
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

///////////////////////////////////   Change Default //////////////////////////////////////////
function changeDefault(Identifier_ID, Identifier_Number)
{
	if(confirm("Are you sure you want to change the default to " + Identifier_Number + "?"))
	
	{
		Change_Default_ID.New_Default_ID.value = Identifier_ID;
		Change_Default_ID.submit();
		return false;
	}
		
	return false;
}