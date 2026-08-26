// JavaScript Document

///////////////////////////////////   Submit //////////////////////////////////////////	
function submitDataForm(action, accSpecId)
{
	var actionFrm = document.DataForm;
	
	//if action is edit set the Accounting_Specialist_ID hidden value
	if (action == "edit")
	{
		actionFrm.Accounting_Specialist_ID.value = accSpecId;
	}	
	
	actionFrm.display.value = action;
	actionFrm.submit();
	return false;
}

///////////////////////////////////   Add Specialist //////////////////////////////////////////		
function addSpecialist()
{
	
	var actionFrm = document.DataForm;
		
	//do validation
	if (trim(actionFrm.Accounting_Specialist_Name.value) == "")
	{
		alert("Please provide a name.");
		return false;
	}
	
	//set hidden form fields and submit
	actionFrm.command.value = 'add';
	actionFrm.display.value = 'list';
	actionFrm.submit();
	return false;	
}

///////////////////////////////////   Edit Specialist //////////////////////////////////////////		
function editSpecialist()
{
	var actionFrm = document.DataForm;
		
	//do validation
	if (trim(actionFrm.Accounting_Specialist_Name.value) == "")
	{
		alert("Please provide a name.");
		return false;
	}
	
	//set hidden form fields and submit
	actionFrm.command.value = 'edit';
	actionFrm.display.value = 'list';
	actionFrm.submit();
	return false;
}

///////////////////////////////////   Delete Specialist //////////////////////////////////////////		
function deleteSpecialist()
{
	var actionFrm = document.DataForm;
	
	//set hidden form fields and submit
	actionFrm.command.value = 'delete';
	actionFrm.display.value = 'list';
	actionFrm.submit();
	return false;
}

///////////////////////////////////   Apply Profile Access //////////////////////////////////////////		
function applyProfileAccess()
{
	var actionFrm = document.DataForm;
	
	//set hidden form fields and submit
	actionFrm.command.value = 'applyProfileAccess';
	actionFrm.display.value = 'profile';
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