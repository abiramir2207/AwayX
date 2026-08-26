// JavaScript Document

///////////////////////////////////   Submit //////////////////////////////////////////	
function submitDataForm(action)
{
	var actionFrm = document.DataForm;
	actionFrm.display.value = action;
	actionFrm.submit();
	return false;
}


///////////////////////////////////	Edit	////////////////////////////////////////////

function editDistributorAlias(compId)
{
	var actionFrm = document.DataForm;
	actionFrm.display.value = 'addDist';
	actionFrm.compId.value = compId;
	actionFrm.submit();
	return false;
}

function editProductAlias(compId)
{
	var actionFrm = document.DataForm;
	actionFrm.display.value = 'addProd';
	actionFrm.compId.value = compId;
	actionFrm.submit();
	return false;
}

///////////////////////////////////   Add Component //////////////////////////////////////////		
		function showDistributorSearchWindow() {
			NewWindow("/billbacks/search_screens/PM_select_distributors.cfm?FormName=DataForm&SelectSingleSearchResultOnly=1", "distributorwindow", 800, 600, "yes", "yes")			
		}
		
	
		function showProductSearchWindow() {
			NewWindow("/common_files/contracts/product_Select_V1.cfm?Formname=DataForm&SelectSingleSearchResultOnly=1", "productwindow", 800, 600, "yes", "yes")			
		}
		
		
		function confirmProductCompletion(formType)
		{ 
			
			if (formType == "edit")
			{
				var actionPath = 'editProd';
			}
			else
			{
				var actionPath = 'addProd';
			}
			
			var ErrorCount = 0;
			var actionFrm = document.DataForm;
					
			//Product checking
			if (document.all.Product_Alias.value.length != 0 && document.all.Product_List.value.length == 0)
			{
				
				ErrorCount++;
				queueMessage("If you enter a product alias, you must search for a product in our system.", document.all.error_ProductAlias1);
			}
			else
			{
				clearQueue(document.all.error_ProductAlias1);
			}
			
			if (document.all.Product_Alias.value.length == 0 && document.all.Product_List.value.length != 0)
			{
				
				ErrorCount++;
				queueMessage("If you search for and select a  product, you must also enter an alias to map that product to.", document.all.error_ProductAlias2);
			}
			else
			{
				clearQueue(document.all.error_ProductAlias2);
			} 
			
			if (document.all.Product_Alias.value.length == 0 && document.all.Product_List.value.length == 0)
			{
				alert("Product selected, but not entered")
				ErrorCount++;
				queueMessage("You need to make selections before you save them", document.all.error_ProductAlias3);
			}
			else
			{
				clearQueue(document.all.error_ProductAlias3);
			} 
			
			//Product checking
			
			<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
			if(ErrorCount == 0) {
					
					//set hidden form fields and submit
					actionFrm.command.value = actionPath;
					actionFrm.display.value = 'search';
					actionFrm.submit();
					return false;				
					
			}		
			else {
				showMessageWindow()
			}	

			
		}
		
		function confirmDistributorCompletion(distName,formType)
		{ 
					
			var ErrorCount = 0;
			var actionFrm = document.DataForm;
			
			if (formType == "edit")
			{
				var actionPath = 'editDist';
			}
			else
			{
				var actionPath = 'addDist';
			}
			
		//Distributor checking
			if (document.all.Distributor_Alias.value.length != 0 && document.all.Distributor_List.value.length == 0)
			{	
				ErrorCount++;
				queueMessage("If you enter a " + distName + " alias, you must search for a " + distName + " in our system.", document.all.error_DistributorAlias1);
			}
			else
			{
				clearQueue(document.all.error_DistributorAlias1);
			}
			 
			if (document.all.Distributor_Alias.value.length == 0 && document.all.Distributor_List.value.length != 0)
			{	
				ErrorCount++;
				queueMessage("If you search for and select a " + distName + ", you must also enter an alias to map that" + distName + " to.", document.all.error_DistributorAlias2);
			}
			else
			{
				clearQueue(document.all.error_DistributorAlias2);
			}
			
			if(document.all.Distributor_Alias.value.length == 0 && document.all.Distributor_List.value.length == 0)
			{	
				ErrorCount++;
				queueMessage("You need to make selections before you save them", document.all.error_DistributorAlias3);
			}
			else
			{
				clearQueue(document.all.error_DistributorAlias3);
			}
			
			//Distributor checking

			
			<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
			if(ErrorCount == 0) {
					//set hidden form fields and submit
					actionFrm.command.value = actionPath;
					actionFrm.display.value = 'search';			
					actionFrm.submit();
					return false;	
			}		
			else {
				showMessageWindow()
			}	

			
		}


///////////////////////////////////   Delete Component //////////////////////////////////////////		
function deleteDistributorAlias(compId)
{	
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to delete this alias?"))
	{
		actionFrm.compId.value = compId;
		actionFrm.command.value = 'deleteDistributorAlias';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

function deleteProductAlias(compId)
{	
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to delete this alias?"))
	{
		actionFrm.compId.value = compId;
		actionFrm.command.value = 'deleteProductAlias';
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
		alert("Please provide a component name");
		return;
	}
	if (actionFrm.Allowance_Code_ID)
	{
		if (trim(actionFrm.Allowance_Code_ID.value) == "0")
		{
			alert("Please select an allowance code");
			return;
		}
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