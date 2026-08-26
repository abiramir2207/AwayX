// JavaScript Document

///////////////////////////////////   Submit //////////////////////////////////////////	
function submitDataForm(action, id)
{
	var actionFrm = document.DataForm;
	actionFrm.display.value = action;
	actionFrm.command.value = "";
	if(actionFrm.Is_First_Time)
	{
		actionFrm.Is_First_Time.value = 1;
	}
	actionFrm.rid.value = 0;
	if(id)
	{
		actionFrm.rid.value = id;
	}
	actionFrm.submit();
	return false;
}


///////////////////////////////////   Add Component //////////////////////////////////////////		
		
		function showProductSearchWindow() {
			NewWindow("/common_files/contracts/product_Select_V1.cfm?Formname=DataForm&SelectSingleSearchResultOnly=0", "productwindow", 800, 600, "yes", "yes")			
		}
		
		
		function confirmProductCompletion(formType)
		{ 
			
			var actionPath = 'addEditProd';
			
			
			var ErrorCount = 0;
			var actionFrm = document.DataForm;
					
			if (document.all.Item_Replacement_Header_Notes.value.length == 0)
			{
				ErrorCount++;
				queueMessage("Please enter notes.", document.all.error_Notes);
			}
			else
			{
				clearQueue(document.all.error_Notes);
			}
			
			var productLen = 0;
			if (document.all.Product_List.value.length > 0)
			{
				var ProdArray = document.all.Product_List.value.split(",");
				productLen = ProdArray.length;				
			}
			
			if (productLen != 2)
			{
				
				ErrorCount++;
				queueMessage("Please select 2 products.", document.all.error_ProductList);
			}
			else
			{
				clearQueue(document.all.error_ProductList);
			} 
			
			
			
			//Product checking
			
			//<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
			if(ErrorCount == 0) {
					
					//set hidden form fields and submit
					actionFrm.command.value = actionPath;
					actionFrm.display.value = 'list';
					actionFrm.submit();
					return false;				
					
			}		
			else {
				showMessageWindow()
			}	

			
		}
		
///////////////////////////////////   Delete Component //////////////////////////////////////////		
function deactivate(id)
{	
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to deactivate this record?"))
	{
		actionFrm.rid.value = id;
		actionFrm.command.value = 'deactivate';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

function activate(id)
{	
	var actionFrm = document.DataForm;

	actionFrm.rid.value = id;
	actionFrm.command.value = 'activate';
	actionFrm.submit();
	return false;
		
}


function deleteRecord(id)
{	
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to delete this record?"))
	{
		actionFrm.rid.value = id;
		actionFrm.command.value = 'delete';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

