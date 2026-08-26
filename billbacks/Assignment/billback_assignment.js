/* billback_assignment.js */
function submitForm(sCommand, sSubCommand)
{
	var oForm = document.frmBillbackAssignment;
	var bProceed = 1;
	switch(sCommand)
	{
	
		case "analyst":
			if (oForm.Analyst_ID.options.length == 0)
			{
				alert("Please select atleast one Analyst from user list and try again.")
				bProceed = 0;
				return false;
			}
			
			if (document.all.New_Analyst)
			{
				var objNew = document.all.New_Analyst;
				var objNewOptions = objNew.options;
				var selOpt = Get_Object_Property_Match_Collection(objNewOptions, "value", document.all.New_Analyst.value);				
				if(selOpt)
				{
					var conNew = confirm("Press OK to assign all billbacks from the removed analysts to " + selOpt.text);
					if (!(conNew))
					{
						bProceed = 0;
						return false;
					}
				}
			}
			select_all("Analyst_ID");
			break;
			
		case "market":
				var analystCount = oForm.Analyst_Record_Count.value;		
				for (i=1; i<=analystCount;i++)
				{	
					select_all("Market_ID_" + i);
				}	
			break;		
			
		case "distributor":
				var analystCount = oForm.Analyst_Record_Count.value;		
				for (i=1; i<=analystCount;i++)
				{	
					select_all("Distributor_ID_" + i);
				}	
			break;

		case "operator":
				var analystCount = oForm.Analyst_Record_Count.value;		
				for (i=1; i<=analystCount;i++)
				{
				    select_all("Operator_ID_" + i);
				}
			break;
			
		case "supervisor":
			if (oForm.Analyst_ID.options.length == 0)
			{
				alert("Please select atleast one Supervisor from analyst list and try again.")
				bProceed = 0;
				return false;
			}
			
			if (document.all.New_Analyst)
			{
				var objNew = document.all.New_Analyst;
				var objNewOptions = objNew.options;
				var selOpt = Get_Object_Property_Match_Collection(objNewOptions, "value", document.all.New_Analyst.value);				
				if(selOpt)
				{
					var conNew = confirm("Press OK to assign all analysts from the removed supervisor to " + selOpt.text);
					if (!(conNew))
					{
						bProceed = 0;
						return false;
					}
				}
			}
			select_all("Analyst_ID");
			break;			
			
		case "assign-supervisor":
				var analystCount = oForm.Supervisor_Record_Count.value;		
				for (i=1; i<=analystCount;i++)
				{	
					select_all("Analyst_User_ID_" + i);
				}	
			break;
			
			
		case "director":		
			if (oForm.Analyst_ID.options.length == 0)
			{
				alert("Please select atleast one director from supervisor list and try again.")
				bProceed = 0;
				return false;
			}
			
			if (document.all.New_Analyst)
			{
				var objNew = document.all.New_Analyst;
				var objNewOptions = objNew.options;
				var selOpt = Get_Object_Property_Match_Collection(objNewOptions, "value", document.all.New_Analyst.value);				
				if(selOpt)
				{
					var conNew = confirm("Press OK to assign all supervisor from the removed director to " + selOpt.text);
					if (!(conNew))
					{
						bProceed = 0;
						return false;
					}
				}
			}
			select_all("Analyst_ID");
			break;			
			
		case "assign-director":
				var analystCount = oForm.Director_Record_Count.value;	
				for (i=1; i<=analystCount;i++)
				{	
					select_all("Analyst_User_ID_" + i);
				}	
			break;
	}

	if(bProceed)
	{
		oForm.subcommand.value = sSubCommand;
		oForm.submit();
	}
	return false;
	
}

function updateAssignNewDistributors()
{
	var oForm = document.frmBillbackAssignment;
	oForm.saveAssignNewDistributors.value = 1;
	oForm.submit();
	return false;
}

function updateAssignNewOperators()
{
	var oForm = document.frmBillbackAssignment;
	oForm.saveAssignNewOperators.value = 1;
	oForm.submit();
	return false;
}

function scroll_div()
{
	var oDiv = eval("document.all." + sDiv);
	var oCell = getParentObject(oDiv, "td");
	var tdTop = getTotalOffsetProperty(oCell, "body", "offsetTop", 0);
	var thisScroll = document.body.scrollTop;
	var divHeight = oDiv.offsetHeight;
	var divWidth = oDiv.offsetWidth;
	oCell.height = divHeight;
	oCell.width = divWidth;
	var cellHeight = oCell.offsetHeight;
	var nextTop = tdTop + thisScroll;
	if((nextTop + divHeight) > (tdTop + cellHeight))
	{
		nextTop = tdTop + cellHeight - divHeight;
	}
	oDiv.style.left = getTotalOffsetProperty(oDiv, "body", "offsetLeft", 0);
	oDiv.style.top = nextTop;
	oDiv.style.position = "absolute";	
}