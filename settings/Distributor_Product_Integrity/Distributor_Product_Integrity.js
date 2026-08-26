// JavaScript Document

///////////////////////////////////   Submit //////////////////////////////////////////	
function submitDataForm(action, compId, editMode)
{
	var actionFrm = document.DataForm;
		
	//if action is edit set the compId hidden value, then reset the action to the existing state
	if (action == "edit")
	{	
		actionFrm.compId.value = compId;
		actionFrm.display.value = action;
		actionFrm.submit();
		return false;
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
	
	actionFrm.display.value = action;
	actionFrm.submit();
	return false;
}

///////////////////////////////////   Add Component //////////////////////////////////////////		
function addComp()
{
	var actionFrm = document.DataForm;
		
	//do validation
	if (trim(actionFrm.Rule_Name.value) == "")
	{
		alert("Please provide a rule name");
		return;
	}
			
	//set hidden form fields and submit
	actionFrm.command.value = 'addComp';
	actionFrm.display.value = 'active';
	actionFrm.submit();
	return false;	
}

///////////////////////////////////   Edit Component //////////////////////////////////////////		
function editComp(componentID)
{
	var actionFrm = document.DataForm;
	
	//set hidden form fields and submit
	actionFrm.command.value = 'editComp';
	actionFrm.display.value = 'edit';
	actionFrm.compId.value = componentID;
	actionFrm.submit();
	return false;	
}

///////////////////////////////////   Search product //////////////////////////////////////////		
function showProductSearchWindow() {
		 NewWindow("/common_files/contracts/product_Select_V1.cfm?Formname=DataForm", "productwindow", 800, 600, "yes", "yes", true);
		 return false;		
		}

///////////////////////////////////   Search distributor //////////////////////////////////////////	
function showDistributorSearchWindow()
	{
		NewWindow("/billbacks/search_screens/PM_select_distributors.cfm?Formname=DataForm&SelectSingleSearchResultOnly=0", "distributorwindow", 850, 600, "yes", "yes", true)
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

///////////////////////////////////   Update Component //////////////////////////////////////////
function updateComp(compId)
{

	var actionFrm = document.DataForm;

	if (trim(actionFrm.Rule_Name.value) == "")
	{
		alert("Please provide a rule name");
		return;
	}

	actionFrm.compId.value = compId;
	actionFrm.command.value = 'update';
	actionFrm.display.value = actionFrm.returnTo.value;
	actionFrm.submit();
	return false;
}
