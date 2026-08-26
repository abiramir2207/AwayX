import src.com.blacksmithapps.*
import mx.utils.ArrayUtil;
import mx.controls.Alert;

	//Application Initialization
	public function initApp():void
   {
	budgetDetailsRO.getAllAsQuery(Application.application.parameters.budgetid, 2);
	budgetDetailsRO.getBudgetBasicInfo(Application.application.parameters.budgetid);
   }

	// Reset Webservice  
   public function resetData():void
   {
	budgetDetailsRO.getAllAsQuery(Application.application.parameters.budgetid, 2);
	budgetDetailsRO.getBudgetBasicInfo(Application.application.parameters.budgetid);
   }

	// Save WIP
   public function saveWIP():void
   {
   	budgetDetailsRO.saveWIP(Application.application.parameters.budgetid);
	// locate back to main page
	// we will uncomment the following 2 lines once we integrate teh swf with teh budget application
	//var request:URLRequest = new URLRequest("/budget/");
	//navigateToURL(request, "_self");
   }

	// Save
   public function save():void
   {
   	budgetDetailsRO.save(Application.application.parameters.budgetid);
	// locate back to main page
	// we will uncomment the following 2 lines once we integrate the swf with the budget application
	//var request:URLRequest = new URLRequest("/budget/");
	//navigateToURL(request, "_self");
   }


	// Manual Updates of the Allocation Data
   public function applyManualInputs(quantity:String,percentage:Number,comment:String):void
   {
   	
	  	if(allocationGrid.selectedItem != null)
	   	{
	   		//Update the DataGrid
	   		if(Number(quantity))
	   		{
	    		allocationGrid.selectedItem.New_Level_Value += Number(quantity);
	   			allocationGrid.selectedItem.Manual_Qty += Number(quantity); 		
	   		}
	   		else if(percentage)
	   		{
				var qtyFromPercentage:Number = Number(((percentage * .01) * Number(budgetBasicInfoROAC.getItemAt(0).Budget_Value)));
				var newPercentage:Number = qtyFromPercentage / Number(budgetBasicInfoROAC.getItemAt(0).Budget_Value);
				if (isNaN(qtyFromPercentage))
				{
					popUp("The application of percentage did not produce a valid result: " + String(qtyFromPercentage));
				}
				else{
				allocationGrid.selectedItem.New_Level_Value += qtyFromPercentage;
		   		allocationGrid.selectedItem.New_Level_Value_Percentage = newPercentage;
		   		allocationGrid.selectedItem.Manual_Percentage += percentage;
		   		allocationGrid.selectedItem.Manual_Qty += qtyFromPercentage;
	   		}
	   	}
		allocationGrid.selectedItem.Manual_Comments = comment;
		//budgetDetailsROAC.refresh();
			
		// save the manual adjustments in the database	
		budgetDetailsRO.saveManualAdjustment(Application.application.parameters.budgetid, allocationGrid.selectedItem.Budget_Detail_Allocation_ID, Number(quantity), percentage, comment);	
   	}
	// Reset the Form values
	txtManQuantity.text = '0';
	txtManPercentage.value = 0;
	txtManComments.text = '';	
   }