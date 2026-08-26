// JavaScript Document

///////////////////////////////////   Submit //////////////////////////////////////////	
function submitForm(command, id, rCommand)
{
	var dataForm = document.BudgetForm;
	var intId = parseInt(id);

	if(!isNaN(intId))
	{
		dataForm.id.value = id;
	}	

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
function verifyAndsubmitBudgetClassForm(command, id, rCommand, sBudgetClassAssociationLabel)
{
	var dataForm = document.BudgetForm;
	var Simple_Budget_Class_Number, Simple_Budget_Class_Desc;
	var bError = 0;
	
	//validate #
	Simple_Budget_Class_Number 	= dataForm.Simple_Budget_Class_Number.value;
	if(trim(Simple_Budget_Class_Number) == "")
	{
		bError = 1;
		queueMessage("class id cannot be empty.", document.all.Err_Sp_Simple_Budget_Class_Number);
	}
	else
	{
		clearQueue(document.all.Err_Sp_Simple_Budget_Class_Number);
	}
	
	//validate desc
	Simple_Budget_Class_Desc 	= dataForm.Simple_Budget_Class_Desc.value;
	if(trim(Simple_Budget_Class_Desc) == "")
	{
		bError = 1;
		queueMessage("class description cannot be empty.", document.all.Err_Sp_Simple_Budget_Class_Desc);
	}
	else
	{
		clearQueue(document.all.Err_Sp_Simple_Budget_Class_Desc);
	}
	
	//validate dates
	var RegExPattern = /^(?=\d)(?:(?:(?:(?:(?:0?[13578]|1[02])(\/)31)\1|(?:(?:0?[1,3-9]|1[0-2])(\/)(?:29|30)\2))(?:(?:1[6-9]|[2-9]\d)?\d{4})|(?:0?2(\/)29\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))|(?:(?:0?[1-9])|(?:1[0-2]))(\/)(?:0?[1-9]|1\d|2[0-8])\4(?:(?:1[6-9]|[2-9]\d)?\d{4}))($|\ (?=\d)))?(((0?[1-9]|1[012])(:[0-5]\d){0,2}(\ [AP]M))|([01]\d|2[0-3])(:[0-5]\d){1,2})?$/;
	var dateError = 0;
	var Simple_Budget_Class_Start_Date 	= dataForm.Simple_Budget_Class_Start_Date.value;
	if(trim(Simple_Budget_Class_Start_Date) == "" || !Simple_Budget_Class_Start_Date.match(RegExPattern))
	{
		bError = 1;
		dateError = 1;
		queueMessage("You must enter a valid start date in MM/DD/YYYY format.", document.all.Err_Sp_Simple_Budget_Class_Start_Date);
	}
	else
	{
		clearQueue(document.all.Err_Sp_Simple_Budget_Class_Start_Date);
	}
			
	var Simple_Budget_Class_End_Date 	= dataForm.Simple_Budget_Class_End_Date.value;
	if(trim(Simple_Budget_Class_End_Date) == "" || !Simple_Budget_Class_End_Date.match(RegExPattern))
	{
		bError = 1;
		dateError = 1;
		queueMessage("You must enter a valid end date in MM/DD/YYYY format.", document.all.Err_Sp_Simple_Budget_Class_End_Date);
	}
	else
	{
		clearQueue(document.all.Err_Sp_Simple_Budget_Class_End_Date);
	}
	
	if(!dateError)
	{
		var FromDate = new Date(Simple_Budget_Class_Start_Date);
		var ToDate = new Date(Simple_Budget_Class_End_Date);
		if(ToDate < FromDate)
		{
			bError = 1;
			queueMessage("The end date must be on or after the start date.", document.all.Err_Sp_Simple_Budget_Class_Start_End_Date);
		}
		{
			clearQueue(document.all.Err_Sp_Simple_Budget_Class_Start_End_Date);
		}	
	}
	else
	{
		clearQueue(document.all.Err_Sp_Simple_Budget_Class_Start_End_Date);
	}
	
	//validate class budget association number
	
	var thisChkObj;
	var inpColl = document.all.Simple_Budget_ID;
	
	if(typeof(inpColl) == 'object')
	{
		var inpCollLen = inpColl.length;
	
		if(inpCollLen)
		{
			for (var i=0;i<inpCollLen;i++)
			{
				bError += validateClassAssociationNumber(inpColl[i], sBudgetClassAssociationLabel);
			}
		}
		else
		{
			bError += validateClassAssociationNumber(inpColl, sBudgetClassAssociationLabel);
		}
 
	}
	
	if(bError)
	{
		showMessageWindow();
	}
	else
	{
		submitForm(command, id);
	}
	return false;
}

function validateClassAssociationNumber(thisChkObj, sBudgetClassAssociationLabel)
{
	var thisBudgetAssocNumberObj, thisBudgetAssocNumberErrorObj, bError;
	thisBudgetAssocNumberObj = eval('document.all.Simple_Budget_Class_Association_Number_' + thisChkObj.value);
	thisBudgetAssocNumberErrorObj = eval('document.all.Err_Sp_Simple_Budget_Class_Association_Number_' + thisChkObj.value);
	bError = 0;
	if(thisChkObj.checked)//if budget is selected
	{
		if(thisBudgetAssocNumberObj)//if object found
		{
			if(trim(thisBudgetAssocNumberObj.value) == "")
			{
				bError = 1;
				queueMessage(sBudgetClassAssociationLabel + " cannot be empty.", thisBudgetAssocNumberErrorObj);
			}
			else
			{
				clearQueue(thisBudgetAssocNumberErrorObj);
			}
		}
	}
	else
	{
		clearQueue(thisBudgetAssocNumberErrorObj);
	}
	return bError;
}

///////////////////////////////////   verifyAndsubmitBudgetForm //////////////////////////////////////////
function verifyAndsubmitBudgetForm(command, id, rCommand, sBudgetClassAssociationLabel)
{
	var dataForm = document.BudgetForm;
	var Simple_Budget_Number, Simple_Budget_Desc;
	var bError = 0;
	
	// validate #
	Simple_Budget_Number 	= dataForm.Simple_Budget_Number.value;
	if(trim(Simple_Budget_Number) == "")
	{
		bError = 1;
		queueMessage("budget id cannot be empty.", document.all.Err_Sp_Simple_Budget_Number);
	}
	else
	{
		clearQueue(document.all.Err_Sp_Simple_Budget_Number);
	}
	
	// validate desc
	Simple_Budget_Desc 	= dataForm.Simple_Budget_Desc.value;
	if(trim(Simple_Budget_Desc) == "")
	{
		bError = 1;
		queueMessage("budget description cannot be empty.", document.all.Err_Sp_Simple_Budget_Desc);
	}
	else
	{
		clearQueue(document.all.Err_Sp_Simple_Budget_Desc);
	}
	
	//validate class budget association number
	
	var thisChkObj, thisBudgetAssocNumberObj, thisBudgetAssocNumberErrorObj;
	var inpColl = document.all.Simple_Budget_Class_ID;
	if(typeof(inpColl) == 'object')
	{
		var inpCollLen = inpColl.length;
		
		if(inpCollLen)
		{
			for (var i=0;i<inpCollLen;i++)
			{
				bError += validateClassAssociationNumber(inpColl[i], sBudgetClassAssociationLabel);
			}
		}
		else
		{
			bError += validateClassAssociationNumber(inpColl, sBudgetClassAssociationLabel);
		}		
	}
	
	if(bError)
	{
		showMessageWindow();
	}
	else
	{
		submitForm(command, id);
	}
	return false;
}


///////////////////////////////////   verifyAndsubmitBudgetClassAssociationForm //////////////////////////////////////////	
function verifyAndsubmitBudgetClassAssociationForm(command, id, rCommand, sBudgetClassAssociationLabel)
{
	var dataForm = document.BudgetForm;
	var bError = 0;
	
	//validate class budget association number
	var Association_Number_Input_Name_Start = "Simple_Budget_Class_Association_Number_";
	var Association_Number_Input_Name_Start_Len = Association_Number_Input_Name_Start.length;
	var thisBudgetAssocNumberObj, thisBudgetAssocNumberErrorObj;
	var inpColl = document.getElementsByTagName("INPUT");
	if(typeof(inpColl) == 'object')
	{
		var inpCollLen = inpColl.length;
	}
	else
	{
		var inpCollLen = 0;
	}
	
	for (var i=0;i<inpCollLen;i++)
	{
		thisBudgetAssocNumberObj = inpColl[i];
		if (thisBudgetAssocNumberObj.type == 'text') 
		{
			if(thisBudgetAssocNumberObj.name.substr(0, Association_Number_Input_Name_Start_Len) == Association_Number_Input_Name_Start)
			{
				thisBudgetAssocNumberErrorObj = eval('document.all.Err_Sp_' + thisBudgetAssocNumberObj.name);
				
				if(trim(thisBudgetAssocNumberObj.value) == "")
				{
					bError = 1;
					queueMessage(sBudgetClassAssociationLabel + " cannot be empty.", thisBudgetAssocNumberErrorObj);
				}
				else
				{
					clearQueue(thisBudgetAssocNumberErrorObj);
				}
			}
		}	
	}
 
	
	if(bError)
	{
		showMessageWindow();
	}
	else
	{
		submitForm(command, id);
	}
	return false;
}


function verifyAndsubmitBudgetLabelForm(command)
{
	var dataForm = document.BudgetForm;
	var Budget_Dollar_Label, Committed_Dollar_Label, Budget_Balance_Label, Approved_Payment_Dollar_Label, Available_Budget_Dollar_Label;
	var bError = 0;
	// ****** Budget_Dollar_Label ******
	Budget_Dollar_Label 	= dataForm.Budget_Dollar_Label.value;
	if(trim(Budget_Dollar_Label) == "")
	{
		bError = 1;
		queueMessage("Label for 'Budget Dollars' cannot be empty.", document.all.Err_Sp_Budget_Dollar_Label);
	}
	else
	{
		clearQueue(document.all.Err_Sp_Budget_Dollar_Label);
	}
	// ****** Committed_Dollar_Label ******
	Committed_Dollar_Label 	= dataForm.Committed_Dollar_Label.value;
	if(trim(Committed_Dollar_Label) == "")
	{
		bError = 1;
		queueMessage("Label for 'Committed Dollars' cannot be empty.", document.all.Err_Sp_Committed_Dollar_Label);
	}
	else
	{
		clearQueue(document.all.Err_Sp_Committed_Dollar_Label);
	}
	// ****** Budget_Balance_Label ******
	Budget_Balance_Label 	= dataForm.Budget_Balance_Label.value;
	if(trim(Budget_Balance_Label) == "")
	{
		bError = 1;
		queueMessage("Label for 'Budget Balance' cannot be empty.", document.all.Err_Sp_Budget_Balance_Label);
	}
	else
	{
		clearQueue(document.all.Err_Sp_Budget_Balance_Label);
	}
	// ****** Approved_Payment_Dollar_Label ******
	Approved_Payment_Dollar_Label 	= dataForm.Approved_Payment_Dollar_Label.value;
	if(trim(Approved_Payment_Dollar_Label) == "")
	{
		bError = 1;
		queueMessage("Label for 'Approved Payment Dollars' cannot be empty.", document.all.Err_Sp_Approved_Payment_Dollar_Label);
	}
	else
	{
		clearQueue(document.all.Err_Sp_Approved_Payment_Dollar_Label);
	}
	// ****** Available_Budget_Dollar_Label ******
	Available_Budget_Dollar_Label 	= dataForm.Available_Budget_Dollar_Label.value;
	if(trim(Available_Budget_Dollar_Label) == "")
	{
		bError = 1;
		queueMessage("Label for 'Available Budget Dollars' cannot be empty.", document.all.Err_Sp_Available_Budget_Dollar_Label);
	}
	else
	{
		clearQueue(document.all.Err_Sp_Available_Budget_Dollar_Label);
	}
	
	
	
	if(bError)
	{
		showMessageWindow();
	}
	else
	{
		submitForm(command, 0);
	}
	return false;
}