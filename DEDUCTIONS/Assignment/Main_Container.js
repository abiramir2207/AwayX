/*
<SCRIPT SRC="/Deductions/Assignment/main_container.js"></SCRIPT>
*/



function Add_Remove_Selected_Users(srcName,desName, changeSize)
{
	var srcObj = eval("document.all."+srcName);
	var desObj = eval("document.all."+desName);
	if (srcName == "Analyst_ID")
	{
		add_Items(srcObj,desObj,'1',srcName);
	}
	else
	{
		add_Items(srcObj,desObj,'0',srcName);
	}
	if(changeSize == 1)
	{
		changeSelectWidth(desObj);
	}
	else if(changeSize == 2)
	{
		changeSelectWidth(srcObj);
	}
}

/*function add_Selected_Users()
{
	var srcObj = document.Pk_Analyst.User_ID;
	var desObj = document.Pk_Analyst.Analyst_ID;
	add_Items(srcObj,desObj);
}

function Remove_Selected_Users()
{
	var desObj = document.Pk_Analyst.User_ID;
	var srcObj = document.Pk_Analyst.Analyst_ID;
	add_Items(srcObj,desObj);
}*/
function remove_all(srcName,desName)
{
	var	call_add_value_from = 0;
	var srcObj = eval("document.all."+srcName);
	var desObj = eval("document.all."+desName);
	var i,srcLen;
	srcLen = srcObj.options.length;
	for (i=(srcLen-1); i>=0; i--)
	{
		call_add_value_from = 0;
		if (srcName == "Analyst_ID")
		{
			if(document.all.Def_Analyst_ID)
			{
				if (srcObj.options[i].value == document.all.Def_Analyst_ID.value)
				{

					if (confirm("Press OK to remove Default Analyst."))
					{
						call_add_value_from = 1;
					}
					else
					{
						srcObj.options[i].selected = false;
					}
				}
				else
				{
					call_add_value_from = 1;
				}
			}
			else
			{
				call_add_value_from = 1;
			}
		}
		else
		{
			call_add_value_from = 1;
		}

		if (call_add_value_from == 1)
		{
			add_value_from(srcObj, desObj, i, srcName);
		}
	}
}


function select_all(srcName)
{
	var srcObj = eval("document.all."+srcName);
	var i,srcLen;
	srcLen = srcObj.options.length;
	for (i=(srcLen-1); i>=0; i--)
	{
		srcObj.options[i].selected = true;
	}
}



function add_Items(srcObj,desObj,defAnaCheck,srcName)
{
	var i,srcLen;
	var call_add_value_from = 0;
	var srcOptions = srcObj.options;
	srcLen = srcOptions.length;

	for (i=(srcLen-1); i>=0; i--)
	{
		call_add_value_from = 0;
		if (srcOptions[i].selected)
		{
			if (defAnaCheck == 1)
			{
				if(document.all.Def_Analyst_ID)
				{
					if (srcOptions[i].value == document.all.Def_Analyst_ID.value)
					{
						if (confirm("Press OK to remove Default Analyst."))
						{
							call_add_value_from = 1;
						}
						else
						{
							srcOptions[i].selected = false;
						}
					}
					else
					{
						call_add_value_from = 1;
					}
				}
				else
				{
					call_add_value_from = 1;
				}
			}
			else
			{
				call_add_value_from = 1;
			}
		}
		if (call_add_value_from == 1)
		{
			add_value_from(srcObj,desObj,i,srcName);
		}
	}
}

function add_value_from(srcObj,desObj,i,srcName)
{
	var oOption = srcObj.options[i];
	addOption(desObj,oOption.value,oOption.text,srcName);

	//77204 :: A Distributor/Market/Operator can now be associated to multiple analysts
	if((document.getElementById('BBAssignmentByTemplate') != null) || 
		(srcName != 'Service_Distributor_ID' && srcName != 'Service_Market_ID' && srcName != 'Service_Operator_ID')){
			srcObj.remove(i);
	}
 
	if (document.all.New_Analyst)
	{
		if (srcName == "Analyst_ID")
		{
			document.all.New_Analyst.remove(i);
		}
	}
}

function addOption(oSelect,sVal,sText,srcName)
{
	var oOption = document.createElement("OPTION");
	oOption.text=sText;
	oOption.value=sVal;

	//77204 :: A Distributor/Market/Operator can now be associated to multiple analysts
	var optionValues = [];

	if((srcName == 'Service_Distributor_ID' || srcName == 'Service_Market_ID'|| srcName == 'Service_Operator_ID') && oSelect.length >= 1 ){
				$('#select[name='+oSelect.name+'] option').each(function() {
		   	 	optionValues.push($(this).val());
				});
		}

		if(jQuery.inArray( sVal, optionValues ) == '-1' ||optionValues.length ==0){
			oSelect.add(oOption);
		}

	//var aOption = oOption.cloneNode(true);

	var aOption = document.createElement("OPTION");
	aOption.text=sText;
	aOption.value=sVal;

	if (document.all.New_Analyst)
	{
		if (srcName == "User_ID")
		{
			document.all.New_Analyst.add(aOption);
		}
	}
}


function changeSelectWidth(selObj)
	{
		var maxSize = 3000;
		var minSize = 4;
		var optLen = selObj.options.length;
		var curSize = selObj.size;
		if(optLen != curSize)
		{
			if(optLen > maxSize)
			{
				optLen = maxSize;
			}
			else if(optLen < minSize)
			{
				optLen = minSize;
			}
			selObj.size = optLen;
		}
	}