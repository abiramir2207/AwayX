// JavaScript Document

///////////////////////////////////   Submit //////////////////////////////////////////	
function submitDataForm(action,CurrencyId)
{
	var actionFrm = document.DataForm;
		
	//if action is edit set the CurrencyId hidden value, then reset the action to the existing state
	if (action == "edit")
	{
		actionFrm.currencyId.value = CurrencyId;
		actionFrm.returnTo.value = actionFrm.display.value;
	}
		
	actionFrm.display.value = action;
	actionFrm.submit();
	return false;
}

///////////////////////////////////   Add Currency //////////////////////////////////////////		
function addCurrency()
{
	
	var actionFrm = document.DataForm;
		
	//do validation
	if (trim(actionFrm.currencyName.value) == "")
	{
		alert("Please provide a currency name");
		return;
	}
	if (trim(actionFrm.currencyCode.value) == "")
	{
		alert("Please provide a currency code");
		return;
	}
		
	//set hidden form fields and submit
	actionFrm.command.value = 'addCurrency';
	actionFrm.display.value = 'active';
	actionFrm.submit();
	return false;
}

///////////////////////////////////   Delete Currency //////////////////////////////////////////		
function deleteCurrency(CurrencyId)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to delete the selected Currency?"))
	{
		actionFrm.currencyId.value = CurrencyId;
		actionFrm.command.value = 'delete';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Deactivate Selected List of Currencies //////////////////////////////////////////		
function deactivateSelCurrencies()
{
	var actionFrm = document.DataForm;
		
	if(!Any_Object_Checked(DataForm.CID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to deactivate the selected Currencies?"))
	{
					
		actionFrm.command.value = 'deactSel';
		actionFrm.display.value = 'active';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Deactivate Single Currency //////////////////////////////////////////		
function deactivateCurrency(CurrencyId)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to deactivate the selected Currency?"))
	{
		actionFrm.currencyId.value = CurrencyId;
		actionFrm.command.value = 'deact';
		actionFrm.display.value = 'active';
			actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Activate Selected List of Currencies //////////////////////////////////////////	
function activateSelCurrencies()
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

///////////////////////////////////   Activate Single Currency //////////////////////////////////////////	
function activateCurrency(CurrencyId)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to activate the selected name?"))
	{
		actionFrm.currencyId.value = CurrencyId;
		actionFrm.command.value = 'act';
		actionFrm.display.value = 'inActive';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Update Currency //////////////////////////////////////////
function upadateCurrency(CurrencyId)
{

	var actionFrm = document.DataForm;

	actionFrm.currencyId.value = CurrencyId;
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