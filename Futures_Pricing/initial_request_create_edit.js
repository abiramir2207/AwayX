//Javascript file for initial request

//validate function
function validate(frmDataForm, command)
{
	//set variables needed
	var frmTitle = trim(frmDataForm.title.value);
	var leadTimeVal = frmDataForm.Lead_Time.value;
	var restctDL = frmDataForm.Restrict_Cust_DL.value;
	
	//return boolean value
	var returnVal = true;
	
	//error spans
	var reqNameErrObj = document.all.Err_Sp_Req_Name;
	
	//first check for a request description
	if (!frmTitle.length)
	{
		queueMessage("Please provide a Request Name.", reqNameErrObj);
		returnVal = false;
	}
	else
	{
		clearQueue(reqNameErrObj);
	}

	//if we are forwarding then do validation for next phase
	if (command == 'sInitialRequestForward')
	{
		if (!validateForward(frmDataForm))
			returnVal = false;
	}
	
	//if validation is false then show error message
	if (!returnVal)
	{
		showMessageWindow();
	}
	
	return returnVal;
}

//validateForward function
function validateForward(frmDataForm)
{
	//set variables needed
	var startDate = trim(frmDataForm.Start_Date.value);
	var endDate = trim(frmDataForm.End_Date.value);
	var custDLDate = trim(frmDataForm.Customer_Deadline.value);
	var prodList = trim(frmDataForm.Product_List.value);
	var newProdList = trim(frmDataForm.New_Product_List.value);
	var volumeDist = trim(frmDataForm.volDistIndx.value);
	var distList = trim(frmDataForm.Distributor_List.value);
	var opList = trim(frmDataForm.Operator_List.value);
	
	//return boolean value
	var returnVal = true;
	
	//error spans
	var startDateErrObj = document.all.Err_Sp_Start_Date;
	var endDateErrObj = document.all.Err_Sp_End_Date;
	var prodErrObj = document.all.Err_Sp_Products;
	var distErrObj = document.all.Err_Sp_Dist;
	var opErrObj = document.all.Err_Sp_Oper;
		
	//validate data entry
	if (!startDate.length)
	{
		queueMessage("Please provide a Start Date.", startDateErrObj);
		returnVal = false;
	}
	else
	{
		clearQueue(startDateErrObj);
	}
	
	if (!endDate.length)
	{
		queueMessage("Please provide an End Date.", endDateErrObj);
		returnVal = false;
	}
	else
	{
		clearQueue(endDateErrObj);
	}
	
	//validate start and end date spans if we have a start and end date
	if (startDate.length && endDate.length)
	{
		if (days_between(build_Date(endDate), build_Date(startDate), true) <= 0)
		{	
			//alert("End Date must be greater than Start Date");
			queueMessage("End Date must be greater than Start Date.", startDateErrObj);
			queueMessage("End Date must be greater than Start Date.", endDateErrObj);
			returnVal = false;
		}
		else
		{
			clearQueue(startDateErrObj);
			clearQueue(endDateErrObj);
		}
	}
	
	//check for products
	if (!prodList.length && !newProdList.length)
	{
		queueMessage("Please select products.", prodErrObj);
		returnVal = false;
	}
	else
	{
		clearQueue(prodErrObj);
	}
	
	
	//validate volume distribution if we have products
	if (prodList.length || newProdList.length)
	{
		//for existing products
		if (prodList.length)
		{
			if (!checkTotalVolVal(frmDataForm,prodList))
			{ 
				returnVal = false;
			}
		}
		
		//for new products
		if (newProdList.length)
		{
			if (!checkTotalVolVal(frmDataForm,newProdList))
			{ 
				returnVal = false;
			}
		}
		
		//make sure volume distribution sums are equal to the total volume distribution if we have one
		if (volumeDist.length)
		{
			//for existing products
			if (prodList.length)
			{
				if (!checkVolSums(frmDataForm,prodList,volumeDist))
				{ 
					returnVal = false;
				}
			}
			
			//for new products
			if (newProdList.length)
			{
				if (!checkVolSums(frmDataForm,newProdList,volumeDist))
				{ 
					returnVal = false;
				}
			}
		}
	}
	
	//check for distributor or operator
	if (!distList.length && !opList.length)
	{
		queueMessage("Select at least one Distributor or Operator.", distErrObj);
		queueMessage("Select at least one Distributor or Operator.", opErrObj);
	
		returnVal = false;
	}

	return returnVal;
}

//validateDate function
function validateDate(frmDataForm)
{
	//set variables needed
	var leadTimeVal = frmDataForm.Lead_Time.value;
	var restctDL = frmDataForm.Restrict_Cust_DL.value;
	
	//check the lead time span between start date and deadline date
	if (!checkLeadTime(frmDataForm))
	{
		if (restctDL != 0)
		{
			alert("The Start Date should be at least " + leadTimeVal + " day(s) before today.");
			return false;
		}
		else
		{
			if (!confirm("The Start Date should be at least " + leadTimeVal + " day(s) before today. Do you want to continue?"))
			return false;
		}
	}
	
	return true;
}

//checkLeadTime function
function checkLeadTime(frmDataForm)
{

	var bIsValidSpan = true;
	var leadTime = frmDataForm.Lead_Time.value;
	var todayDate = build_Date(frmDataForm.Today_Date.value);
	var startDate = build_Date(frmDataForm.Start_Date.value);
		
	if(startDate)
	{

		var dateDiff = days_between(startDate, todayDate, true);
		
		//check the span between the two dates
		if(dateDiff < leadTime)
		{
			bIsValidSpan = false;
		}
	}
	
	return bIsValidSpan;
}

//checkTotalVolVal function
function checkTotalVolVal(frmDataForm, prodList)
{

	//return boolean value
	var returnVal = true;
	
	var prodArray = prodList.split(",");

	//loop only if we have a product list
	if (prodList.length)
	{
		//loop for each product and validate
		for (i=0; i<prodArray.length;i++)
		{
			prodId = replaceChar(prodArray[i], '-', '_');
			
			var volErrObj = eval("document.all.Err_Sp_Volume_" + prodId);

			var volume = eval(trim("frmDataForm.volume_" + prodId + ".value"));

			//check to make sure we have a valid volume value entered
			if(!volume.length || volume <= 0)
			{
				queueMessage("Please provide a Total Volume for each product.", volErrObj);
				returnVal = false;
			}
			else
			{
				clearQueue(volErrObj);
			}
		}
	}
	
	return returnVal;
}

//checkVolSums function
function checkVolSums(frmDataForm, prodList, volDist)
{
	
	//return boolean value
	var returnVal = true;
	var volDiff;

	var prodArray = prodList.split(",");
	var i;
	
	//loop only if we have a product list
	if (prodList.length)
	{
		
		//check volume for each product against sum of distributed volume
		for (i=0; i<prodArray.length;i++)
		{
			prodId = replaceChar(prodArray[i], '-', '_');
			
			var distVolErrObj = eval("document.all.Err_Sp_Volume_Dist_" + prodId);
			
			var volume = eval(trim("frmDataForm.volume_" + prodId + ".value"));

			var distTotal = getDistVolSum(frmDataForm, prodArray[i], volDist);

			if (parseFloat(volume) > 0)
			{
				//if the volume isn't == to the total distributed volume then queue message
				volDiff = parseFloat(volume) - distTotal;
				volDiff = numericRoundDecimal(volDiff, 2);
				if(distTotal != parseFloat(volume))
				{
					queueMessage("Total Volume (" + volume + ") must equal the sum of the distributed volume periods (" + distTotal + "). Difference=" + volDiff, distVolErrObj);
					returnVal = false;
				}
				else
				{
					clearQueue(distVolErrObj);
				}
			}
		}
	}

	return returnVal;
}

//setDistVolume function
function setDistVolume(frmDataForm, prodId, volDist, requestSpan)
{
	var volInp = eval("frmDataForm.volume_" + prodId);
	var vol = formatToDecimalPlaces(volInp.value,2);
	
	var volPerDay = vol / requestSpan;
	var thisVol;
	var totalVol = 0;

	//loop for each distributed volume
	for (i=1; i<=volDist;i++)
	{
		//get period Start Date and End Date
		var perStartDate = eval("frmDataForm.periodStartDate_" + prodId + "_" + i + ".value");
		var perEndDate = eval("frmDataForm.periodEndDate_" + prodId + "_" + i + ".value");
		
		var dateDiff = days_between(build_Date(perEndDate), build_Date(perStartDate), true) + 1;
		thisVol = dateDiff * volPerDay;
		if (i==volDist)
		{
			thisVol = vol - totalVol;
		}
		totalVol += thisVol;
		totalVol = numericRoundDecimal(totalVol, 2);
		
		periodInp = eval("frmDataForm.periodVolume_" + prodId + "_" + i);
		periodInp.value = formatToDecimalPlaces(thisVol,2);
	}
	
	return false;
}

//setDistVolumeOnChange function
function setDistVolumeOnChange(frmDataForm, prodId, volDist, requestSpan)
{
	//check and see if distributed volume has an entries
	checkDistVolSums = getDistVolSum(frmDataForm, prodId, volDist);
	
	//if distributed volume has an entry then don't set
	if(checkDistVolSums <= 0)
	{
		setDistVolume(frmDataForm, prodId, volDist, requestSpan);
	}

}

//setDistVolume function
function resetDistVolume(frmDataForm, prodId, volDist)
{
	var volInp = eval("frmDataForm.volume_" + prodId);
	var resetVal = '0.00';
	
	//loop for each distributed volume
	for (i=1; i<=volDist;i++)
	{
		
		periodInp = eval("frmDataForm.periodVolume_" + prodId + "_" + i);
		periodInp.value = resetVal;
	}
	
	return false;
}

//getDistVolSum function
function getDistVolSum(frmDataForm, prodId, volDist)
{
	var distTotal = 0;
	var objInput, iVal, i;

	//loop for each distributed volume
	for (i=1; i<=volDist;i++)
	{
		
		objInput = eval("frmDataForm.periodVolume_" + replaceChar(prodId, '-', '_') + "_" + i);
		iVal = numericRoundDecimal(parseFloat(objInput.value), 2);
		
		distTotal += iVal;
		distTotal = numericRoundDecimal(distTotal, 2);
			
	}

	return distTotal;
}

//setCustomerDeadline function
function setCustomerDeadline(frmDataForm)
{
	//var formName = eval("document." + formObj);
	var dlDate = frmDataForm.Customer_Deadline.value;
	var leadTime = frmDataForm.Lead_Time.value;
	var startDate;
	if(frmDataForm.Start_Date.value.length >= 10)
	{
		startDate = build_Date(frmDataForm.Start_Date.value);
	}
	
	//set the customer deadline date if its null
	if (trim(dlDate) == "" && startDate)
	{
		custDlDate = dateAdd('d', startDate, leadTime*-1);
		custDlDate = formatDate(custDlDate);
		frmDataForm.Customer_Deadline.value = custDlDate;
	}

}

//formatDate function
function formatDate(date)
{

	var day = date.getDate();
	var month = date.getMonth();
	month = month+1;
	var year = date.getFullYear();
	var formatDate = month + "/" + day + "/" + year;
	
	return formatDate;
}

//checkString function
//function will check if a string is empty then throw the message passed in
function checkString(str, mesg)
{
	var tmpStr = trim(str);
	if (tmpStr == "")
	{
		alert(mesg);
		return false;
	}
	else
		return true;
}