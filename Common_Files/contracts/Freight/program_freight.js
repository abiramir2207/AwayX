// JavaScript Document

///////////////////////////////////   Submit //////////////////////////////////////////	
function submitForm(sCommand)
{
	var actionFrm = document.ProgramFreightForm;
	var bContinue = 1;
	var cid = actionFrm.cid.value;
	
	if(sCommand == 'save' || sCommand == 'save-approve')
	{
		var validationReturnValue = validateFreightfrm();
		if(validationReturnValue == 0)
		{
			bContinue = 0;
		}
		else if(validationReturnValue == 2 && sCommand == 'save-approve')
		{
			bContinue = window.confirm("There are some rows with zero freight.\nDo you want to continue?");
		}
	}
	
	if(sCommand == 'refresh-data')
	{
		var anyOverridden = checkIfAnyOverridden();
		if(anyOverridden == 1)
		{
			bContinue = window.confirm("There are some value which are overridden which might get overwritten.\nDo you want to continue?");
		}
		else
		{
			bContinue = window.confirm("Do you want to refresh the freight data?");
		}
	}
	
	if(sCommand == 'print')
	{
		OpenPrinterFriendly(cid);
		bContinue = 0;	
	}	
	
	if(bContinue)
	{
		actionFrm.command.value = sCommand;
		actionFrm.submit();		
	}
	event.returnValue = false;
	return false;
	
}

function validateFreightfrm()
{
var IBF_Rate;
var OBF_Rate;
var ErrorCount;
var j;
var zeroFreight = 0;
var surchargeExpirationDate;
var surchargeAmount;
var errSurchargeExpirationDateObj;
var errSurchargeAmountObj;
var Distributor_List = ProgramFreightForm.Distributor_List.value;
var Distributor_Array = Distributor_List.split(",");
var currentDistributorId, objIBFRate, objOBFRate, objPickupAllowance, iFreight;
var startDate = ProgramFreightForm.ContractStartDate.value;
var endDate  = ProgramFreightForm.ContractEndDate.value;
var today;
var currentDate = new Date();
var day = currentDate.getDate();
var month = currentDate.getMonth() + 1;
var year = currentDate.getFullYear();
today = month + "/" + day + "/" + year;
var rdoFuelSurchargeOn;
var fuelSurchargeOn;
 
j = 0;
ErrorCount = 0;

if (typeof(document.getElementsByName("Send_Summarized_Weekly_Notification_Fuel_Surcharge")) != "undefined")
{
 var rdoFuelSurchargeOn = document.getElementsByName("Send_Summarized_Weekly_Notification_Fuel_Surcharge");

    for (var i = 0; i < rdoFuelSurchargeOn.length; i++) {       
        if (rdoFuelSurchargeOn[i].checked) {
		   fuelSurchargeOn =  rdoFuelSurchargeOn[i].value;		         
        }
	}
	if (fuelSurchargeOn == 1)
	{
		surchargeExpirationDate = ProgramFreightForm.Fuel_Surcharge_Expiration_Date.value;
		surchargeAmount = ProgramFreightForm.Fuel_Surcharge_Amount.value;
	
		errSurchargeExpirationDateObj = document.all.Err_Fuel_Surcharge_Expiration_Date;
		errSurchargeAmountObj = document.all.Err_Fuel_Surcharge_Amount;
		
		if ((surchargeAmount == "") || (surchargeAmount <= 0))
		{
			ErrorCount++;
			queueMessage("Please provide a valid Fuel Base Amount.",errSurchargeAmountObj );
		
		}
		else
		{
			clearQueue(errSurchargeAmountObj);
		}
		
		if (!surchargeExpirationDate.length || surchargeExpirationDate == "01/01/1900" ||  surchargeExpirationDate === "01/01/3900" )
		{
			ErrorCount++;
			queueMessage("Please provide a Fuel Base Adj. Expiration Date.",errSurchargeExpirationDateObj );
		}
		else
		{
			clearQueue(errSurchargeExpirationDateObj);
		
			if (checkDate(surchargeExpirationDate,startDate)<0)
			{	
				ErrorCount++;
				queueMessage("Fuel Base Adj. Expiration Date must be greater or same as the Start Date.", errSurchargeExpirationDateObj);
			}
			else
			{
				clearQueue(errSurchargeExpirationDateObj);
			}
			
			if (checkDate(endDate,surchargeExpirationDate)<0)
			{	
				ErrorCount++;
				queueMessage("Fuel Base Adj. Expiration Date must be lesser or same as the End Date.", errSurchargeExpirationDateObj);
			}
			else
			{
				clearQueue(errSurchargeExpirationDateObj);
			}

			if (checkDate(surchargeExpirationDate,today)<0)
			{	
				ErrorCount++;
				queueMessage("Fuel Base Adj. Expiration Date cannot be in the past.", errSurchargeExpirationDateObj);
			}
			else
			{
				clearQueue(errSurchargeExpirationDateObj);
			}
		} //else for if (!surchargeExpirationDate.length)
	} // if (fuelSurchargeOn)
}	
// Loop through the form
for (var i=0;i<Distributor_Array.length;i++)
{	
	j = i + 1;
 	currentDistributorId = Distributor_Array[i];
 	iFreight = 0;
	var reg = /^\d+(\.\d{0,2})?$/
 	// IBF Rate

	 	objIBFRate = getIBFObject(currentDistributorId);
	 	IBF_Rate = objIBFRate.value;
	 	iFreight = iFreight + parseFloat(IBF_Rate);

		if(isNaN(parseFloat(IBF_Rate)) == true || parseFloat(IBF_Rate) < 0 || !isNumeric(IBF_Rate, 0, 1) || reg.test(parseFloat(IBF_Rate))== false)
		{
			ErrorCount++;
			queueMessage("Please enter a positive numeric value upto 2 decimal places", eval('document.all.error_IBF_Rate_' + j));
		}
		else
		{
			clearQueue(eval('document.all.error_IBF_Rate_' + j));
		}

	if(globalFreightComponentType == 1)
	{
	// OBF Rate
		objOBFRate = getOBFObject(currentDistributorId);
		OBF_Rate = objOBFRate.value;
		iFreight = iFreight + parseFloat(OBF_Rate);
		if(isNaN(parseFloat(OBF_Rate)) == true || parseFloat(OBF_Rate) < 0 || !isNumeric(OBF_Rate, 0, 1) || reg.test(parseFloat(OBF_Rate))== false)
		{
			ErrorCount++;
			queueMessage("Please enter a positive numeric value upto 2 decimal places", eval('document.all.error_OBF_Rate_' + j));
		}
		else
		{
			clearQueue(eval('document.all.error_OBF_Rate_' + j));
		}
		
	// Pickup Allowance
		objPickupAllowance = getPUAObject(currentDistributorId);	
		Pickup_Allowance = objPickupAllowance.value;
		if(isNaN(parseFloat(Pickup_Allowance)) == true || parseFloat(Pickup_Allowance) < 0 || !isNumeric(Pickup_Allowance, 0, 1) || reg.test(parseFloat(Pickup_Allowance))== false)
		{
			ErrorCount++;
			queueMessage("Please enter a positive numeric value upto 2 decimal places", eval('document.all.error_Pickup_Allowance_' + j));
		}
		else
		{
			clearQueue(eval('document.all.error_Pickup_Allowance_' + j));
		}

		if(parseFloat(Pickup_Allowance) > parseFloat(IBF_Rate) + parseFloat(OBF_Rate))
		{
			ErrorCount++;
			queueMessage("PUA cannot be greater than the sum of IBF and OBF", eval('document.all.error_Total_Pickup_Allowance_' + j));
		}
		else
		{
			clearQueue(eval('document.all.error_Total_Pickup_Allowance_' + j));
		}
		 
	}// DEL
	
	if(iFreight == 0)
	{
		zeroFreight++;
	}
}//for

	if(ErrorCount == 0) 
	{
		if(zeroFreight)
		{
			return 2;
		}
		else
		{
			return 1;
		}
	} 	
	else
	{
		showMessageWindow();
		return 0;
	}

}

function checkIfAnyOverridden()
{

	var bOverride = 0;
	var Distributor_List = ProgramFreightForm.Distributor_List.value;
	var Distributor_Array = Distributor_List.split(",");

	// Loop through the form
	for (var i=0;i<Distributor_Array.length;i++)
	{	
	 	currentDistributorId = Distributor_Array[i];
	 	// IBF Rate
	 	bOverride += GetOverride(getWarehouseObject(currentDistributorId));
	 	bOverride += GetOverride(getIBFObject(currentDistributorId));
	 	if(globalFreightComponentType == 1)
		{
			bOverride += GetOverride(getBracketObject(currentDistributorId));
	 		bOverride += GetOverride(getOBFObject(currentDistributorId));
	 		bOverride += GetOverride(getPUAObject(currentDistributorId));
	 	}//DEL
	 	
		if(bOverride != 0)
		{
			return 1;
		}
	}//for

	return bOverride;

}

function getInputNameSuffix(distributorId)
{
	return distributorId.replace(/-/ig, "_");
}
function getDistributorIdFromInputNameSuffix(distributorId)
{
	return distributorId.replace(/_/ig, "-");
}

function getWarehouseObject(distributorId)
{
	return eval("document.all.SelectedWarehouse_" + distributorId);
}
function getBracketObject(distributorId)
{
	return eval("document.all.Freight_Bracket_Setting_ID_" + distributorId);
}
function getIBFObject(distributorId)
{
	return eval("document.all.IBF_Rate_" + distributorId);
}
function getOBFObject(distributorId)
{
	return eval("document.all.OBF_Rate_" + distributorId);
}
function getPUAObject(distributorId)
{
	return eval("document.all.Pickup_Allowance_" + distributorId);
}
function getZipCodeObject(distributorId)
{
	return eval("document.all.Zip_Code_" + distributorId);
}

function getDefaultWarehouseObject(distributorId)
{
	return eval("document.all.Default_SelectedWarehouse_" + distributorId);
}
function getDefaultBracketObject(distributorId)
{
	return eval("document.all.Default_Freight_Bracket_Setting_ID_" + distributorId);
}
function getDefaultIBFObject(distributorId)
{
	return eval("document.all.Default_IBF_Rate_" + distributorId);
}
function getDefaultOBFObject(distributorId)
{
	return eval("document.all.Default_OBF_Rate_" + distributorId);
}
function getDefaultPUAObject(distributorId)
{
	return eval("document.all.Default_Pickup_Allowance_" + distributorId);
}

function getWarehouse(distributorId)
{
	var warehouseObj = getWarehouseObject(distributorId);	
	if(warehouseObj)
	{
		return warehouseObj.value;
	}
	return 0;
}
function getBracket(distributorId)
{
	var bracketObj = getBracketObject(distributorId);
	if(bracketObj)
	{
		return bracketObj.value;
	}
	return 0;
}
function getZipCode(distributorId)
{
	var zipCodeObj = getZipCodeObject(distributorId);
	if(zipCodeObj)
	{
		return zipCodeObj.value;
	}
	return 0;
}


function OpenWarehousePage(distributorId)
{
	var currentWarehouseId = 0;
	var objWarehouse = getWarehouseObject(distributorId);
	if(objWarehouse)
	{
		currentWarehouseId = objWarehouse.value;
		NewWindow('/common_files/contracts/select_warehouse.cfm?callWHSEChange=1&BSA_Foodservice_Customers_ID=' + distributorId + '&WareHouse_Master_ID=' + currentWarehouseId, 'warehousewindow', 800, 600, 'yes', 'yes', true);
	}
	return false;
}

function OpenPrinterFriendly(cid)
{
	NewWindow('index.cfm?cid=' + cid + '&command=print', 'programFreightPrint', 800, 600, 'yes', 'yes', true);
	return false;
}

function FormatInputValue(inputObj)
{
	inputObj.value = formatToDecimalPlaces(inputObj.value, 2, 1);
	var inpValue = parseFloat(inputObj.value);
	if(inpValue == 0)
	{
		if(inputObj.className != "zeroValue")
			inputObj.className = "zeroValue";
	}
	else
	{
		if(inputObj.className != "nonZeroValue")
			inputObj.className = "nonZeroValue";
	}
	SetOverride(inputObj);
}

function SetOverride(inputObj)
{
	var inpName = inputObj.name;
	var overriddenMessageObj = eval("document.all.Overridden_" + inpName);
	
	if(overriddenMessageObj)
	{
		var overRidden = GetOverride(inputObj);
		if(overRidden)
		{	
			if(overriddenMessageObj.className != "overriddenShow")		
				overriddenMessageObj.className = "overriddenShow";
		}
		else
		{
			if(overriddenMessageObj.className != "overriddenHide")
				overriddenMessageObj.className = "overriddenHide";
		}
	}
}

function GetOverride(inputObj)
{
	var inpName = inputObj.name;
	var inpValue = parseFloat(inputObj.value);
	var defaultObj = eval("document.all.Default_" + inpName);
	var returnValue = 0;
	
	if(defaultObj)
	{
		var defaultValue = parseFloat(defaultObj.value);
		if(defaultValue != inpValue)
		{	
			returnValue = 1;
		}		
	}
	return returnValue;
}

function checkDate(dateStr1,dateStr2)
{
 var dateSplit; 
 var retVal = null;
 dateSplit = dateStr1.split("/"); 
 if(dateSplit.length > 2)
 {
  var date1 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
  dateSplit = dateStr2.split("/");
  if(dateSplit.length > 2)
  {
   var date2 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
   retVal = days_between(date1, date2, true);
  }
 }
 return retVal;
}

function allowonlyfourdecimalplaces(textObject)	{
	var inputText = textObject.value;
	if (inputText == ".")
	{
		textObject.value = "0.0000";
		return true;
	}
	if(inputText.length != 0){
		//look for an existing decimal
		if(inputText.indexOf(".") != -1) {
			textAfterDecimal = inputText.substring(inputText.indexOf(".")+1, inputText.length)
			if(textAfterDecimal.length > 4){
				textObject.value = inputText.substring(0, inputText.indexOf(".")+5)
			}
		}
	}
}
