// JavaScript Document

///////////////////////////////////   Submit //////////////////////////////////////////	
function submitForm(command, id, rCommand)
{
	var dataForm = document.DataForm;
	
	dataForm.id.value = id;
	
	//if we are editing or adding then set section value
	if (command == 'eaBusinessSegment' || command == 'eiBusinessSegment' || command == 'cBusinessSegment' || command == 'eClassCodes' || command == 'sBudgetPercentage')
	{
		dataForm.returnCommand.value = rCommand;
	}
	
	if (command == 'sBusinessSegment')
	{
		//if validation is false then show error message
		if (!validateForm())
		{
			showMessageWindow();
			return false;
		}
	}
	
	if(command == "sBudgetPercentage")
	{
		//if validation is false then show error message
		if (!validateBudgetPercentage())
		{
			showMessageWindow();
			return false;
		}
	}
	
	if (command == 'daBusinessSegment')
	{
		//first check to see if we can deactivate
		var canDeactivate = dataForm.canDeactivate.value;
		
		if (canDeactivate == 0)
		{
			alert("At least one Segment must be active if Business Segments are enabled.");
			return false;
		}
		if (!confirm("Are you sure you want to DeActivate this Segment?"))
		{
			return false;
		}
	}
	dataForm.command.value = command;
	dataForm.submit();
	return false;
}


function validateForm()
{

	var dataForm = document.DataForm;
	
	var rVal = true;
	
	//error spans
	var busUnitIDErrObj = document.all.Err_Sp_Unit_ID;
	var busUnitDescErrObj = document.all.Err_Sp_Desc;
	
	var unitDescField = dataForm.Business_Unit_Desc.value;
	var unitIdField = dataForm.Business_Unit_ID.value;
		
	//check for unit id
	if (trim(unitIdField) == "")
	{
		queueMessage("Please provide a Business Unit ID.", busUnitIDErrObj);
		rVal = false;
	}
	else
	{
		clearQueue(busUnitDescErrObj);
	}
	
	//check for unit description
	if (trim(unitDescField) == "")
	{
		queueMessage("Please provide a Business Unit Description.", busUnitDescErrObj);
		rVal = false;
	}
	else
	{
		clearQueue(busUnitDescErrObj);
	}
	
	return rVal;
}

function validateBudgetPercentage()
{
	var retVal = false;
	var totalPercent = getBudgetPercentageTotal();

	if(totalPercent != 100)
	{
		queueMessage("The percentge should add up to 100, currently it adds up to " + totalPercent + ".", document.all.err_percentage);
	}
	else
	{
		clearQueue(document.all.err_percentage);
		retVal = true;
	}
	return retVal;
	
}

function getBudgetPercentageTotal()
{
	var totalPercent = 0;
	var startKeyword = "Breakout_Percentage_";
	var LenStartKeyword = startKeyword.length;
	var i, thisInp, thisInpVal, inpObj = document.getElementsByTagName("INPUT");
	for(i=0;i<inpObj.length;i++)
	{
		thisInp = inpObj[i];
		if(thisInp.name.substr(0, LenStartKeyword) == startKeyword)
		{
			thisInpVal = parseFloat(thisInp.value);
			if(isNaN(thisInpVal))
			{
				thisInpVal = 0;
			}
			totalPercent += thisInpVal;
			totalPercent = numericRoundDecimal(totalPercent, 4);
		}
	}
	return totalPercent;
}

function recalcTotal()
{
	var totalPercent = getBudgetPercentageTotal();
	var oSpan = document.all.totalPercent;
	if(totalPercent == 100)
	{
		oSpan.style.backgroundColor = "ffffff";
	}
	else
	{
		oSpan.style.backgroundColor = "ff0000";
	}
	oSpan.innerText = totalPercent;
}