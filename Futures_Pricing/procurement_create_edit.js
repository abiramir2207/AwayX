//Javascript file for procurement

//validate function
function validate(frmDataForm, command)
{
	
	//if we are forwarding then do validation for next phase
	if (command == 'sProcurementForward')
	{
		if (!validateForward(frmDataForm))
			return false;
	}
	
	return true;
}

//validateForward function
function validateForward(frmDataForm)
{
	//set variables needed
	var rawMatIdList = frmDataForm.lRawMatId.value;
	var rawMatArray = rawMatIdList.split(",");
	var bShowMessWindow = false;
	
	//loop through each raw material and validate
	for (i=0; i<rawMatArray.length;i++)
	{
		
		//check to see if each raw material has a supplier
		if (!bHasSupplier(frmDataForm, rawMatArray[i]))
		{
			bShowMessWindow = true;
		}
		else
		{
			//if there is a supplier then validate
			if (!bValidateSupplier(frmDataForm, rawMatArray[i]))
			{
				bShowMessWindow = true;
			}	
		}
		
	}
	
	if (bShowMessWindow)
	{
		showMessageWindow();
		return false;
	}
	
	return true;
}

//bHasSupplier function
function bHasSupplier(frmDataForm, rawMatId)
{
	//return boolean value
	var returnVal = true;
	
	//get the supplier ids
	var suppIdList = eval("frmDataForm.lRawMatID_" + rawMatId + ".value");
	
	var errObj = eval("document.all.HasSupplierErr_Sp_" + rawMatId);
	
	if (!suppIdList.length)
	{
		queueMessage("Each raw material needs at least one supplier.", errObj);
		returnVal = false;
	}
	else
	{
		clearQueue(errObj);
	}
	
	return returnVal;
}

//bValidateSupplier function
function bValidateSupplier(frmDataForm, rawMatId)
{
	//return boolean value
	var returnVal = true;
	
	//queue boolean values
	var queueAwardedMess = true;
	
	//set raw material error objects
	var awardErrObj = eval("document.all.AwardErr_Sp_" + rawMatId);
	var totlVolErrObj = eval("document.all.TotalVolErr_Sp_" + rawMatId);
	
	var volTotalTally = 0;
	var volTotal = eval("frmDataForm.totalVolume_" + rawMatId + ".value");
	
	//get the supplier ids
	var suppIdList = eval("frmDataForm.lRawMatID_" + rawMatId + ".value");
	var suppArray = suppIdList.split(",");
	
	//check to see if a supplier has been awarded for this raw material
	for (n=0;n<suppArray.length;n++)
	{
		
		//get values needed for rawMaterial/supplier combination
		var awarded = eval("frmDataForm.selected_" + rawMatId + "_" + suppArray[n] + ".checked");
		var suppQuote = eval("frmDataForm.quote_" + rawMatId + "_" + suppArray[n] + ".value");
		var suppVolume = eval("frmDataForm.quoteVolume_" + rawMatId + "_" + suppArray[n] + ".value");
		var goodUntilDate = eval("frmDataForm.goodUntil_" + rawMatId + "_" + suppArray[n] + ".value");
		var todayDate = frmDataForm.Today_Date.value;
		
		//set supplier error objects
		var quoteErrObj = eval("document.all.quote_Err_Sp_" + rawMatId + "_" + suppArray[n]);
		var volErrObj = eval("document.all.quoteVolume_Err_Sp_" + rawMatId + "_" + suppArray[n]);
		var goodUntlErrObj = eval("document.all.goodUntill_Err_Sp_" + rawMatId + "_" + suppArray[n]);
	
		//set awarded to true if a supplier was checked, then check to make sure quote and volume are valid
		if(awarded)
		{
			
			queueAwardedMess = false;
			
			if (!suppQuote.length || suppQuote <= 0)
			{
				returnVal = false;
				queueMessage("Please provide a valid value for quote.", quoteErrObj);
			}
			else
			{
				clearQueue(quoteErrObj);
			}
			
			if (!suppVolume.length || suppVolume <= 0)
			{
				returnVal = false;
				queueMessage("Please provide a valid value for volume.", volErrObj);
			}
			else
			{
				volTotalTally += parseFloat(suppVolume);
				volTotalTally = numericRoundDecimal(volTotalTally, 2);
				clearQueue(volErrObj);
			}
			
			//if they added a good untill date make sure it's greater that today
			if (goodUntilDate != "")
			{
				if (goodUntilDate <= todayDate)
				{
					returnVal = false;
					queueMessage("Good Until date must be greater that today.", goodUntlErrObj);
				}
				else
				{
					clearQueue(goodUntlErrObj);
				}
				
			}
		}
	}	
	
	//if a supplier wasn't awarded then queue message
	if (queueAwardedMess)
	{
		returnVal = false;
		queueMessage("At least one supplier must awarded.", awardErrObj);
	}
	else
	{
		clearQueue(awardErrObj);
	}
	
	if(volTotalTally != parseFloat(volTotal) && returnVal)
	{
		var volDiff = parseFloat(volTotal) - volTotalTally;
		volDiff = numericRoundDecimal(volDiff, 2);
		returnVal = false;
		queueMessage("Total supplier volume(" + volTotalTally + ") must be equal to the volume of the Raw Material(" + volTotal + "). Difference=" + volDiff + "", totlVolErrObj);
	}
	else
	{
		clearQueue(totlVolErrObj);
	}
	
	return returnVal;
}