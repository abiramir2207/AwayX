////commodityScripts.js

function validateAndSubmitIndex2(thisForm)
{

	var allClear = true;
	
	///////////////////Validate Rule Name

	var re = /["]/ig;
	thisForm.aa_rulename.value = thisForm.aa_rulename.value.replace(re,"");
	
	var rex1 = /<!\[CDATA\[/ig;
	var rex2 = /\]\]>/ig;
	
	if(isSpace(thisForm.aa_rulename.value))
	{
		queueMessage("Rule Name is a required field", document.all.error_RuleName);
		allClear = false;
	}
	else if(rex1.test(thisForm.aa_rulename.value))
	{
		queueMessage("Rule Name is invalid.\ncharacter combination '&lt;![CDATA[' is forbidden", document.all.error_RuleName);
		allClear = false;
	}
	else if(rex2.test(thisForm.aa_rulename.value))
	{
		queueMessage("Rule Name is invalid.\ncharacter combination ']]&gt;' is forbidden", document.all.error_RuleName);
		allClear = false;
	}
	else
	{
		clearQueue(document.all.error_RuleName);
	}
	///////////////////End Validate Rule Name
	
	
	///////////////////Validate Product Selector 
	//error_PRODUCT_LIST
	if(thisForm.AA_PRODUCT_LIST.value.length <= 0)
	{
		queueMessage("You haven't selected any products", document.all.error_PRODUCT_LIST);
		allClear = false;
	}
	else
	{
		clearQueue(document.all.error_PRODUCT_LIST);
	}
	
	///////////////////End Validate Product Selector 
	
	
	if(!allClear)
	{
		showMessageWindow();
	}
	
	if(event)
	{
		return allClear;
	}
	else if(allClear)
	{
		thisForm.submit();
	}
}


function validateAndSubmitIndex3(thisForm)
{

	var allClear = true;
	
	var totalCommNo = thisForm.aa_comm_number.value;
	var sample_size,compounded_desc,anyComplete;
	var startIndex = 1;
	
	for(i=startIndex;i<=totalCommNo;i++)
	{
		if(eval("thisForm.ExchangeSelection" + i))
			eval("thisForm.ExchangeSelection" + i + ".value=thisForm.Exchange_" + i + ".selectedIndex;");
			
		if(eval("thisForm.commoditySelection" + i))
			eval("thisForm.commoditySelection" + i + ".value=thisForm.Commodity_" + i + ".selectedIndex;");
		
		///////////////////Validate weeks
		sample_size = eval("thisForm.sample_size_" + i + ".value");		
		/*
		sampleSizeTmp = parseInt(sample_size);
		if(!isNaN(sampleSizeTmp) && sampleSizeTmp+"" == sample_size)
		*/
		if(isInt(sample_size))
		{
			clearQueue(eval("document.all.error_sample_size" + i));
		}
		else
		{
			queueMessage("Weeks Should be an Integer value", eval("document.all.error_sample_size" + i));
			allClear = false;
		}
		///////////////////End Validate weeks
		
		///////////////////Validate weeks
		sample_size = eval("thisForm.point_in_time_" + i + ".value");
		/*sampleSizeTmp = parseInt(sample_size);
		if(!isNaN(sampleSizeTmp) && sampleSizeTmp+"" == sample_size)
		*/
		if(isInt(sample_size))
		{
			clearQueue(eval("document.all.error_point_in_time_" + i));
		}
		else
		{
			queueMessage("Weeks Should be an Integer value", eval("document.all.error_point_in_time_" + i));
			allClear = false;
		}
		///////////////////End Validate weeks
		
		
		///////////////////Validate compounded_desc
		anyComplete=true;
		anyEntry = false;
		for(j=1;j<=4;j++)
		{
			thisComplete = true;			
			compounded_desc=eval("thisForm.compounded_desc_calc" + j + "_" + i + ".value");
			if(isSpace(compounded_desc))
			{
				thisComplete = !(eval("thisForm.compounded_desc_calc" + j + "_" + i + ".readOnly")) && false;
			}

			compounded_desc=eval("thisForm.compounded_amount_calc" + j + "_" + i + ".value");
			if(!isFloat(compounded_desc) || eval("thisForm.compounded_amount_calc" + j + "_" + i + ".readOnly"))
			{
				thisComplete = thisComplete == false;
			}
			else
			{
				thisComplete = thisComplete == true;
				if(thisComplete)
					anyEntry = true;
			}

			anyComplete = anyComplete && thisComplete;
		}
		
		//if(anyComplete && anyEntry)
		if(anyComplete)
		{
			clearQueue(eval("document.all.error_compounded_desc_" + i));
		}
		/*else if(!anyEntry)
		{
			queueMessage("Compounded Calculations needs an entry", eval("document.all.error_compounded_desc_" + i));
			allClear = false;
		}*/
		else
		{
			queueMessage("Compounded Calculations are Incomplete/InCorrect", eval("document.all.error_compounded_desc_" + i));
			allClear = false;
		}
		
		///////////////////End Validate compounded_desc
		
		///////////////////Validate independent_desc
		anyComplete=true;
		anyEntry = false;
		for(j=1;j<=4;j++)
		{
			thisComplete = true;
			compounded_desc=eval("thisForm.independent_desc_calc" + j + "_" + i + ".value");
			if(isSpace(compounded_desc))
			{
				thisComplete = !(eval("thisForm.independent_desc_calc" + j + "_" + i + ".readOnly")) && false;
			}
			compounded_desc=eval("thisForm.independent_amount_calc" + j + "_" + i + ".value");
			if(!isFloat(compounded_desc) || eval("thisForm.independent_amount_calc" + j + "_" + i + ".readOnly"))
			{
				thisComplete = thisComplete == false;				
			}
			else
			{
				thisComplete = thisComplete == true;
				if(thisComplete)
					anyEntry = true;
			}
			anyComplete = anyComplete && thisComplete;
		}
		
		//if(anyComplete && anyEntry)
		if(anyComplete)
		{
			clearQueue(eval("document.all.error_independent_desc_" + i));
		}
		/*else if(!anyEntry)
		{
			queueMessage("Independent Calculations needs an entry", eval("document.all.error_independent_desc_" + i));
			allClear = false;
		}*/
		else
		{
			queueMessage("Independent Calculations are Incomplete/InCorrect", eval("document.all.error_independent_desc_" + i));
			allClear = false;
		}
		
		///////////////////End Validate independent_desc
	}
	
	if(totalCommNo == 0)
		allClear = allClear && checkNoCommodities(thisForm);
	
	if(allClear)
	{
		disableElements3(thisForm,false);
		thisForm.submit();		
	}
	else
	{
		showMessageWindow();
	}
}

function checkNoCommodities(thisForm)
{
	var i = 0;
	var anyComplete, anyEntry, allClear = true;
	///////////////////Validate compounded_desc
		anyComplete=true;
		anyEntry = false;
		for(j=1;j<=4;j++)
		{
			thisComplete = true;			
			compounded_desc=eval("thisForm.compounded_desc_calc" + j + "_" + i + ".value");
			if(isSpace(compounded_desc))
			{
				thisComplete = !(eval("thisForm.compounded_desc_calc" + j + "_" + i + ".readOnly")) && false;
			}

			compounded_desc=eval("thisForm.compounded_amount_calc" + j + "_" + i + ".value");
			if(!isFloat(compounded_desc) || eval("thisForm.compounded_amount_calc" + j + "_" + i + ".readOnly"))
			{
				thisComplete = thisComplete == false;
			}
			else
			{
				thisComplete = thisComplete == true;
				if(thisComplete)
					anyEntry = true;
			}

			anyComplete = anyComplete && thisComplete;
		}
		
		//if(anyComplete && anyEntry)
		if(anyComplete)
		{
			clearQueue(eval("document.all.error_compounded_desc_" + i));
		}
		else if(!anyEntry)
		{
			queueMessage("Compounded Calculations needs an entry", eval("document.all.error_compounded_desc_" + i));
			allClear = false;
		}
		else
		{
			queueMessage("Compounded Calculations are Incomplete/InCorrect", eval("document.all.error_compounded_desc_" + i));
			allClear = false;
		}
		
		///////////////////End Validate compounded_desc
		
		///////////////////Validate independent_desc
		anyComplete=true;
		anyEntry = false;
		for(j=1;j<=4;j++)
		{
			thisComplete = true;
			compounded_desc=eval("thisForm.independent_desc_calc" + j + "_" + i + ".value");
			if(isSpace(compounded_desc))
			{
				thisComplete = !(eval("thisForm.independent_desc_calc" + j + "_" + i + ".readOnly")) && false;
			}
			compounded_desc=eval("thisForm.independent_amount_calc" + j + "_" + i + ".value");
			if(!isFloat(compounded_desc) || eval("thisForm.independent_amount_calc" + j + "_" + i + ".readOnly"))
			{
				thisComplete = thisComplete == false;				
			}
			else
			{
				thisComplete = thisComplete == true;
				if(thisComplete)
					anyEntry = true;
			}
			anyComplete = anyComplete && thisComplete;
		}
		
		//if(anyComplete && anyEntry)
		if(anyComplete)
		{
			clearQueue(eval("document.all.error_independent_desc_" + i));
		}
		else if(!anyEntry)
		{
			queueMessage("Independent Calculations needs an entry", eval("document.all.error_independent_desc_" + i));
			allClear = false;
		}
		else
		{
			queueMessage("Independent Calculations are Incomplete/InCorrect", eval("document.all.error_independent_desc_" + i));
			allClear = false;
		}
		
		///////////////////End Validate independent_desc
		if(allClear)
		{
			var oldAction = thisForm.action;
			thisForm.action = "index5.cfm";
		}
		return allClear;
}


function validateAndSubmitIndex4(thisForm)
{
	
	var allClear = true;
	
	//////////////////// Validate Commodity Pricing Weight
	//error_Comm_Weight
	
	var Comm_Weight,Comm_WeightTmp;
	var i = 1;
	var totalWeight=0;
	var sErr="";
	var bErr=false;
	for(i=1;i<=aa_comm_number;i++)
	{
		if(eval("thisForm.all.Comm_Weight_" + i))
		{
			Comm_Weight = eval("thisForm.all.Comm_Weight_" + i + ".value");
			/*Comm_WeightTmp = parseFloat(Comm_Weight);
			if(!(!isNaN(Comm_WeightTmp) && Comm_WeightTmp+"" == Comm_Weight))
			*/
			if(!isFloat(Comm_Weight,true))
			{
				sErr += " " + Comm_Weight + " is not a proper percentage value";
				bErr=true;
			}
			else
			{
				totalWeight += parseFloat(Comm_Weight);
			}
		}		
		//Comm_Weight_
	}

	if(!bErr)
	{
		if(totalWeight > 100)
		{
			bErr=true;
			sErr += " " + "Total weight is greater than 100";
		}
		else if(totalWeight < 100)
		{
			bErr=true;
			sErr += " " + "Total weight is less than 100";
		}
	}
	
	if(bErr)
	{
		allClear = false;
		queueMessage(sErr, document.all.error_Comm_Weight);
	}
	else
	{
		clearQueue(document.all.error_Comm_Weight);
	}
	
	
	//////////////////// End Validate Commodity Pricing Weight
	
	////////////////// Validate Current Cost Lag
	//error_Current_Cost_Lag
	var currCostLag = thisForm.Current_Cost_Lag.value;
	/*var currCostLagTmp = parseInt(currCostLag);
	if((!isNaN(currCostLagTmp) && currCostLagTmp+"" == currCostLag))
	*/
	if(isInt(currCostLag))
	{
		clearQueue(document.all.error_Current_Cost_Lag);
	}
	else
	{
		allClear = false;
		queueMessage("Current cost lag should be an integer", document.all.error_Current_Cost_Lag);
	}
	
	
	////////////////// Validate Current Cost Lag
	
	//////////////////// Validate Compounded Calculations
	i = 1;
	
	if(eval("thisForm.final_compounded_desc_calc" + i))
	{
		anyComplete=true;
		anyEntry = false;
		for(j=1;j<=4;j++)
		{
			thisComplete = true;
			compounded_desc=eval("thisForm.final_compounded_desc_calc" + j + ".value");
			if(isSpace(compounded_desc))
			{
				thisComplete = !(eval("thisForm.final_compounded_desc_calc" + j + ".readOnly")) && false;
			}
			compounded_desc=eval("thisForm.final_compounded_amount_calc" + j + ".value");
			if(!isFloat(compounded_desc) || eval("thisForm.final_compounded_amount_calc" + j + ".readOnly"))
			{
				thisComplete = thisComplete == false;
			}
			else
			{
				thisComplete = thisComplete == true;
				if(thisComplete)
					anyEntry = true;
			}
			anyComplete = anyComplete && thisComplete;
		}
		
		
		//if(anyComplete && anyEntry)
		if(anyComplete)
		{
			clearQueue(document.all.error_final_compounded_desc);
		}
		/*else if(!anyEntry)
		{
			queueMessage("Compounded Calculations needs an entry", document.all.error_final_compounded_desc);
			allClear = false;
		}*/
		else
		{
			queueMessage("Compounded Calculations are Incomplete/InCorrect", document.all.error_final_compounded_desc);
			allClear = false;
		}
	}
	
	
	if(eval("thisForm.final_independent_desc_calc" + i))
	{
		anyComplete=true;
		anyEntry = false;
		for(j=1;j<=4;j++)
		{
			thisComplete = true;
			compounded_desc=eval("thisForm.final_independent_desc_calc" + j + ".value");
			if(isSpace(compounded_desc))
			{
				thisComplete = !(eval("thisForm.final_independent_desc_calc" + j + ".readOnly")) && false;
			}
			compounded_desc=eval("thisForm.final_independent_amount_calc" + j + ".value");

			if(!isFloat(compounded_desc) || eval("thisForm.final_independent_amount_calc" + j + ".readOnly"))
			{
				thisComplete = thisComplete == false;
			}
			else
			{
				thisComplete = thisComplete == true;
				if(thisComplete)
					anyEntry = true;
			}
			anyComplete = anyComplete && thisComplete;
		}
		
		//if(anyComplete && anyEntry)
		if(anyComplete)
		{
			clearQueue(document.all.error_final_independent_desc);
		}
		/*else if(!anyEntry)
		{
			queueMessage("Independent Calculations needs an entry", document.all.error_final_independent_desc);
			allClear = false;
		}*/
		else
		{
			queueMessage("Independent Calculations are Incomplete/InCorrect", document.all.error_final_independent_desc);
			allClear = false;
		}
	}
	
	//////////////////// End Validate Compounded Calculations
	
	
	if(allClear)
	{		
		disableElements4(thisForm,false);
		thisForm.submit();
	}
	else
	{
		showMessageWindow();
	}
}


function CalculationsSelectIndex3(thisObj)
{
	var objName = thisObj.name;
	var nextObjName="";
	switch(objName.substr(0,16))
	{
		case "compounded_desc_":
			nextObjName = "compounded_amount_calc" + objName.substr(20);
			CalculationsSelect3(thisObj.form,thisObj,eval("thisObj.form." + nextObjName));
			break;
		case "compounded_amoun":
			nextObjName = "compounded_desc_calc" + objName.substr(22);
			CalculationsSelect3(thisObj.form,eval("thisObj.form." + nextObjName),thisObj);
			break;
		case "independent_desc":
			nextObjName = "independent_amount_calc" + objName.substr(21);
			CalculationsSelect3(thisObj.form,thisObj,eval("thisObj.form." + nextObjName));
			break;
		case "independent_amou":
			nextObjName = "independent_desc_calc" + objName.substr(23);
			CalculationsSelect3(thisObj.form,eval("thisObj.form." + nextObjName),thisObj);
			break;
	}	
}

function CalculationsSelect3(thisForm,Obj1,Obj2)
{
	var objCount = 4;
	var allClear=true;
	if(isSpace(Obj1.value))
	{
		allClear = allClear && false;
	}
	/*var obj2Temp = parseFloat(Obj2.value);
	if((!isNaN(obj2Temp) && obj2Temp+"" == Obj2.value))
	*/
	if(!isFloat(Obj2.value))
	{
		allClear = allClear && false;
	}
	objName = Obj1.name;
	switch(objName.substr(0,16))
	{
		case "compounded_desc_":
			nextIndex = objName.substring(20,objName.lastIndexOf("_"));
			nextIndex = parseInt(nextIndex) + 1;
			lastPart = objName.substr(objName.lastIndexOf("_"));
			for(i=nextIndex;i<=4;i++)
			{
				Obj1Name = "compounded_desc_calc" + i + lastPart;
				Obj2Name = "compounded_amount_calc" + i + lastPart;
				Obj3Name = "compounded_amount_uom" + i + lastPart;				
				if(enableNextGroup(thisForm,Obj1Name,Obj2Name,Obj3Name,allClear) && allClear)
					break;
			}
			break;
		case "independent_desc":
			nextIndex = objName.substring(21,objName.lastIndexOf("_"));
			nextIndex = parseInt(nextIndex) + 1;
			lastPart = objName.substr(objName.lastIndexOf("_"));
			for(i=nextIndex;i<=4;i++)
			{
				Obj1Name = "independent_desc_calc" + i + lastPart;
				Obj2Name = "independent_amount_calc" + i + lastPart;
				Obj3Name = "independent_amount_uom" + i + lastPart;					
				if(enableNextGroup(thisForm,Obj1Name,Obj2Name,Obj3Name,allClear) && allClear)
					break;
			}
			break;
	}	
	
}

function CalculationsSelectIndex4(thisObj)
{
	var objName = thisObj.name;
	var nextObjName="";
	switch(objName.substr(0,21))
	{
		case "final_compounded_desc":
			nextObjName = "final_compounded_amount_calc" + objName.substr(26);
			CalculationsSelect4(thisObj.form,thisObj,eval("thisObj.form." + nextObjName));
			break;
		case "final_compounded_amou":
			nextObjName = "final_compounded_desc_calc" + objName.substr(28);
			CalculationsSelect4(thisObj.form,eval("thisObj.form." + nextObjName),thisObj);
			break;
		case "final_independent_des":
			nextObjName = "final_independent_amount_calc" + objName.substr(27);
			CalculationsSelect4(thisObj.form,thisObj,eval("thisObj.form." + nextObjName));
			break;
		case "final_independent_amo":
			nextObjName = "final_independent_desc_calc" + objName.substr(29);
			CalculationsSelect4(thisObj.form,eval("thisObj.form." + nextObjName),thisObj);
			break;
	}	
}

function CalculationsSelect4(thisForm,Obj1,Obj2)
{
	var objCount = 4;
	var allClear=true;
	if(isSpace(Obj1.value))
	{
		allClear = allClear && false;
	}
	/*
	var obj2Temp = parseFloat(Obj2.value);
	if((!isNaN(obj2Temp) && obj2Temp+"" == Obj2.value))*/
	if(!isFloat(Obj2.value))
	{
		allClear = allClear && false;
	}
	objName = Obj1.name;
	switch(objName.substr(0,21))
	{
		case "final_compounded_desc":
			nextIndex = objName.substr(26);
			nextIndex = parseInt(nextIndex) + 1;
			for(i=nextIndex;i<=4;i++)
			{
				Obj1Name = "final_compounded_desc_calc" + i;
				Obj2Name = "final_compounded_amount_calc" + i;
				Obj3Name = "final_compounded_amount_uom" + i;					
				if(enableNextGroup(thisForm,Obj1Name,Obj2Name,Obj3Name,allClear) && allClear)
					break;
			}
			break;
		case "final_independent_des":
			nextIndex = objName.substr(27);
			nextIndex = parseInt(nextIndex) + 1;
			for(i=nextIndex;i<=4;i++)
			{
				Obj1Name = "final_independent_desc_calc" + i;
				Obj2Name = "final_independent_amount_calc" + i;
				Obj3Name = "final_independent_amount_uom" + i;					
				if(enableNextGroup(thisForm,Obj1Name,Obj2Name,Obj3Name,allClear) && allClear)
					break;
			}
			break;
	}	
	
}

function resetSelects(thisForm)
{
	var totalCommNo = thisForm.aa_comm_number.value;
	var i,selVal;
	for(i=1;i<=totalCommNo;i++)
	{
		if(eval("thisForm.commoditySelection" + i))
		{
			//eval("MyFormExchange_" + i + "ChangeMenu();");
			eval("MyForm_Exchange_Type_" + i + "_Populate_Select_Box(1);");
			//eval("thisForm.Commodity_" + i + ".onchange= commoditySelectChange();");
			
			
			if(eval("thisForm.ExchangeSelection" + i))
			{
				eval("selVal=thisForm.ExchangeSelection" + i + ".value");
				if(selVal.length > 0)
				{	
					eval("thisForm.Exchange_" + i + ".selectedIndex=thisForm.ExchangeSelection" + i + ".value;");
					eval("MyForm_Exchange_Type_" + i + "_Populate_Select_Box(2);");
				}
			}
				
			eval("selVal=thisForm.commoditySelection" + i + ".value");
			if(selVal.length > 0)		
				eval("thisForm.Commodity_" + i + ".selectedIndex=thisForm.commoditySelection" + i + ".value;");
		}
	}	
}

function disableElements3(thisForm,bDis)
{
	
	var bThisDis;
	var totalCommNo = thisForm.aa_comm_number.value;
	var selObj;
	var startIndex = 1;
	if(totalCommNo == 0)
		startIndex = 0;
	
	for(i=startIndex;i<=totalCommNo;i++)
	{			
		bThisDis = true;
		j = 1;
		Obj1Name = "compounded_desc_calc" + j + "_" + i;
		Obj2Name = "compounded_amount_calc" + j + "_" + i;
		Obj3Name = "compounded_amount_uom" + j + "_" + i;
			
		if((j==1) && !isSpace(eval("thisForm." + Obj1Name + ".value")) && isFloat(eval("thisForm." + Obj2Name + ".value")))
		{
			bThisDis=false;			
		}
		else if(isSpace(eval("thisForm." + Obj1Name + ".value")) && eval("thisForm." + Obj2Name + ".value")=="0")
		{
			eval("thisForm." + Obj2Name + ".value=''");
		}

			
		for(j=2;j<=4;j++)
		{
			Obj1Name = "compounded_desc_calc" + j + "_" + i;
			Obj2Name = "compounded_amount_calc" + j + "_" + i;
			Obj3Name = "compounded_amount_uom" + j + "_" + i;
			
			if(isSpace(eval("thisForm." + Obj1Name + ".value")) && eval("thisForm." + Obj2Name + ".value") == 0)
			{
				//alert("0");
				eval("thisForm." + Obj1Name + ".value = '';");
				eval("thisForm." + Obj2Name + ".value = '';");
			}
			
			if(!isSpace(eval("thisForm." + Obj1Name + ".value")) && isFloat(eval("thisForm." + Obj2Name + ".value")))
			{
				bThisDis=false;			
				continue;
			}
		
			if(bThisDis && bDis)
				bThisDis=!enableNextGroup(thisForm,Obj1Name,Obj2Name,Obj3Name,!bThisDis);
			else
				bThisDis=!bThisDis;
			if(!bDis)
			{
				selObj = eval("thisForm." + Obj3Name);
				if(selObj.tagName == "SELECT")
				{
					selObj.disabled=bDis;
				}
			}
		}
		bThisDis = true;
		j=1;
		Obj1Name = "independent_desc_calc" + j + "_" + i;
		Obj2Name = "independent_amount_calc" + j + "_" + i;
		Obj3Name = "independent_amount_uom" + j + "_" + i;
		
		if((j==1) && !isSpace(eval("thisForm." + Obj1Name + ".value")) && isFloat(eval("thisForm." + Obj2Name + ".value")))
		{
			bThisDis=false;
		}
		else if(isSpace(eval("thisForm." + Obj1Name + ".value")) && eval("thisForm." + Obj2Name + ".value")=="0")
		{
			eval("thisForm." + Obj2Name + ".value=''");
		}
		
		for(j=2;j<=4;j++)
		{
			Obj1Name = "independent_desc_calc" + j + "_" + i;
			Obj2Name = "independent_amount_calc" + j + "_" + i;
			Obj3Name = "independent_amount_uom" + j + "_" + i;
			
			if(isSpace(eval("thisForm." + Obj1Name + ".value")) && eval("thisForm." + Obj2Name + ".value") == 0)
			{
				//alert("0");
				eval("thisForm." + Obj1Name + ".value = '';");
				eval("thisForm." + Obj2Name + ".value = '';");
			}
			
			if(!isSpace(eval("thisForm." + Obj1Name + ".value")) && isFloat(eval("thisForm." + Obj2Name + ".value")))
			{
				bThisDis=false;			
				continue;
			}
			
			if(bThisDis && bDis)
				bThisDis=!enableNextGroup(thisForm,Obj1Name,Obj2Name,Obj3Name,!bThisDis);
			else
				bThisDis=!bThisDis;
			if(!bDis)
			{
				selObj = eval("thisForm." + Obj3Name);
				if(selObj.tagName == "SELECT")
				{
					selObj.disabled=bDis;
				}
			}
		}
		
	}
}
function disableElements4(thisForm,bDis)
{
	var bThisDis = true;
	j = 1;
	Obj1Name = "final_compounded_desc_calc" + j;
	Obj2Name = "final_compounded_amount_calc" + j;
	Obj3Name = "final_compounded_amount_uom" + j;	
	
	if((j==1) && !isSpace(eval("thisForm." + Obj1Name + ".value")) && isFloat(eval("thisForm." + Obj2Name + ".value")))
	{
		bThisDis=false;
	}
	else if(isSpace(eval("thisForm." + Obj1Name + ".value")) && eval("thisForm." + Obj2Name + ".value")=="0")
	{
			eval("thisForm." + Obj2Name + ".value=''");
	}
	for(j=2;j<=4;j++)
	{
		Obj1Name = "final_compounded_desc_calc" + j;
		Obj2Name = "final_compounded_amount_calc" + j;
		Obj3Name = "final_compounded_amount_uom" + j;
		
		if(isSpace(eval("thisForm." + Obj1Name + ".value")) && eval("thisForm." + Obj2Name + ".value") == 0)
		{
				//alert("0");
				eval("thisForm." + Obj1Name + ".value = '';");
				eval("thisForm." + Obj2Name + ".value = '';");
		}
			
		if(!isSpace(eval("thisForm." + Obj1Name + ".value")) && isFloat(eval("thisForm." + Obj2Name + ".value")))
		{
			bThisDis=false;			
			continue;
		}
		if(bThisDis && bDis)
			bThisDis=!enableNextGroup(thisForm,Obj1Name,Obj2Name,Obj3Name,!bThisDis);
		else
			bThisDis = !bThisDis
		if(!bDis)
		{
			selObj = eval("thisForm." + Obj3Name);
			if(selObj.tagName == "SELECT")
			{
				selObj.disabled=bDis;
			}
		}
	}
	bThisDis = true;
	j=1;
	Obj1Name = "final_independent_desc_calc" + j;
	Obj2Name = "final_independent_amount_calc" + j;
	Obj3Name = "final_independent_amount_uom" + j;
	
	if((j==1) && !isSpace(eval("thisForm." + Obj1Name + ".value")) && isFloat(eval("thisForm." + Obj2Name + ".value")))
	{
		bThisDis=false;
	}
	else if(isSpace(eval("thisForm." + Obj1Name + ".value")) && eval("thisForm." + Obj2Name + ".value")=="0")
	{
		eval("thisForm." + Obj2Name + ".value=''");
	}
	
	for(j=2;j<=4;j++)
	{
		Obj1Name = "final_independent_desc_calc" + j;
		Obj2Name = "final_independent_amount_calc" + j;
		Obj3Name = "final_independent_amount_uom" + j;
		
		if(isSpace(eval("thisForm." + Obj1Name + ".value")) && eval("thisForm." + Obj2Name + ".value") == 0)
		{
			//alert("0");
			eval("thisForm." + Obj1Name + ".value = '';");
			eval("thisForm." + Obj2Name + ".value = '';");
		}
			
		if(!isSpace(eval("thisForm." + Obj1Name + ".value")) && isFloat(eval("thisForm." + Obj2Name + ".value")))
		{
			bThisDis=false;			
			continue;
		}
		
		if(bThisDis && bDis)
			bThisDis=!enableNextGroup(thisForm,Obj1Name,Obj2Name,Obj3Name,!bThisDis);
		else
			bThisDis = !bThisDis
		if(!bDis)
		{
			selObj = eval("thisForm." + Obj3Name);
			if(selObj.tagName == "SELECT")
			{
				selObj.disabled=bDis;
			}
		}
	}
}

function enableNextGroup(thisForm,Obj1Name,Obj2Name,Obj3Name,allClear)
{	
	try
	{
		if(!isSpace(eval("thisForm." + Obj1Name + ".value")) && isFloat(eval("thisForm." + Obj2Name + ".value")))
		{
			allClear=true;
		}
		eval("thisForm." + Obj1Name + ".readOnly=" + (!allClear));	
		eval("thisForm." + Obj2Name + ".readOnly=" + (!allClear));
		eval("thisForm." + Obj3Name + ".readOnly=" + (!allClear));
		
		
		var selObj = eval("thisForm." + Obj3Name);
		
		if(selObj.tagName == "SELECT")
		{
			selObj.disabled=(!allClear);
		}
		
		if(allClear)
		{
			var col = "\"ffffff\"";
		}
		else
		{
			var col = "\"cccccc\"";
		}
		eval("thisForm." + Obj1Name + ".style.backgroundColor=" + col);	
		eval("thisForm." + Obj2Name + ".style.backgroundColor=" + col);	
		eval("thisForm." + Obj3Name + ".style.backgroundColor=" + col);	
	}
	catch(e)
	{
		alert(e.description);
	}
	return allClear;
}

function isSpace(sStr)
{
	var re = /^[\s\t]*$/ig;
	if (re.test(sStr))
		return true;
	else
		return false;
}

function isFloat(sVal,noMinus)
{		
	var sValTemp = parseFloat(sVal);
	//if((!isNaN(sValTemp) && sValTemp+"" == sVal))
	
	if(!isNaN(sValTemp) && (/^[+-]?\d*(\.(\d)+)?$/.test(sVal)))
	{
		if(noMinus) return /^\d*(\.(\d)+)?$/.test(sVal);
		return true;
	}
	else
	{
		return false;
	}
	
	//return (/^[+-]?\d*(\.(\d)+)?$/.test(sVal));
}

function isInt(sVal)
{	
	var sValTemp = parseInt(sVal);
	if((!isNaN(sValTemp) && sValTemp+"" == sVal))
		return true;
	else
		return false;
}

function validateXMLCharaters()
{
	switch(event.keyCode)
	{
		case 62://>
		case 60://<
			break;
		case 34://"
			event.returnValue = false;
			event.cancelBubble = true;
			return false;
			break;
		case 39://'			
		case 38://&	
	}
}