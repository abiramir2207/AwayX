// JavaScript Document

///////////////////////////////////   Submit //////////////////////////////////////////	
function submitForm(level, command, id, rCommand)
{
	var dataForm = document.OperatingGroupDataForm;
	var intId = parseInt(id);

	if(!isNaN(intId))
	{
		dataForm.id.value = id;
	}	
	dataForm.level.value = level;
	if(command)
	{
		dataForm.command.value = command;
	}
	if(rCommand)
	{
		dataForm.returnCommand.value = rCommand;
	}
	dataForm.submit();
	return false;
}


///////////////////////////////////   verifyAndsubmitForm //////////////////////////////////////////	
function verifyAndsubmitForm(level, command, id, rCommand)
{
	var dataForm = document.OperatingGroupDataForm;
	var Operating_Group_Number, Operating_Group_Desc, Allowance_Code_ID;
	var bError = 0;
	
	Operating_Group_Number 	= dataForm.Operating_Group_Number.value;
	if(trim(Operating_Group_Number) == "")
	{
		bError = 1;
		queueMessage("" + operatingGroupLabel + " number cannot be empty.", document.all.Err_Sp_Operating_Group_Number);
	}
	else
	{
		clearQueue(document.all.Err_Sp_Operating_Group_Number);
	}
	
	Operating_Group_Desc 	= dataForm.Operating_Group_Desc.value;
	if(trim(Operating_Group_Desc) == "")
	{
		bError = 1;
		queueMessage("" + operatingGroupLabel + " description cannot be empty.", document.all.Err_Sp_Operating_Group_Desc);
	}
	else
	{
		clearQueue(document.all.Err_Sp_Operating_Group_Desc);
	}
	
	if(dataForm.Allowance_Code_ID) // not applicable always
	{
		Allowance_Code_ID 		= dataForm.Allowance_Code_ID.value;
		if(Allowance_Code_ID == "")
		{
			bError = 1;
			queueMessage("You must select allowance code.", document.all.Err_Sp_Allowance_Code);
		}
		else
		{
			clearQueue(document.all.Err_Sp_Allowance_Code);
		}
	}
	
	if(bError)
	{
		showMessageWindow();
	}
	else
	{
		submitForm(level, command, id);
	}
	return false;
}


///////////////////////////////////   changeProductGroupSelectionValues //////////////////////////////////////////	
function changeProductGroupSelectionValues(thisObj, counter)
{
	var dataForm = thisObj.form;
	var valueObj = eval("dataForm.Operating_Group_Definition_Value_" + counter);
	var displayGroupDetailObj = eval("document.all.TR_Group_Detail_" + counter);
	
	if(thisObj.value != thisObj.selectionOnLoad)
	{
		valueObj.value = "";
		if(displayGroupDetailObj) displayGroupDetailObj.style.display = "none";
	}
	else
	{
		valueObj.value = valueObj.onLoadValue;
		if(displayGroupDetailObj) displayGroupDetailObj.style.display = "";
	}
	

}
