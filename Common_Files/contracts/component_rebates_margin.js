// JavaScript Document
var formaction = null
//function get's called on all submits
function submitForm(action)
{

	var thisForm = document.dataForm;
	var donotallowproductsDE = eval("thisForm.donotallowaddproductsDE");
	//ADD ALL PRODUCTS
	if(action == 'addAllProducts')
	{
		
	}
	//REMOVE PRODUCTS
	else if (action == 'remProd')
	{
		var tmpProd = cycleDataForm('prodChkBx',action);
		var checkSelBox = validateCheckBoxes('prodChkBx');
		var tmpProdArray = tmpProd.split(",");
		
		//if the list length of the product_list is equal to the prodLen hidden value, then we know there were no products selected
		if (trim(checkSelBox) == "")
		{
			alert("At least one product must be selected to remove.");
			return;
		}
		thisForm.Product_List.value = tmpProd;
	}
			
	//REMOVE COMPONENTS
	else if (action == 'remComp')
	{
		var tmpComp = cycleDataForm('comp',action);
		
		if (tmpComp == "")
		{
			alert("At least one component must be selected to remove.");
			return;
		}
		
		thisForm.comps.value = tmpComp;
	}
				
	//SORT
	else if (action == 'upc' || action == 'item' || action == 'description')
	{
		var sortBy = thisForm.sortBy;
		var sortOrder = thisForm.sortOrder;
				
		//SWITCH FOR EACH SORT
		switch(action)
		{
			case 'upc':
				if (sortOrder.value == 'asc' && sortBy.value == 'upc')
					sortOrder.value = 'desc';
				else
					sortOrder.value = 'asc';
							
				sortBy.value = 'upc';
				break;
						
			case 'item':
				if (sortOrder.value == 'asc' && sortBy.value == 'item')
					sortOrder.value = 'desc';
				else
					sortOrder.value = 'asc';
							
					sortBy.value = 'item';
				break;
					
			case 'description':
				if (sortOrder.value == 'asc' && sortBy.value == 'description')
					sortOrder.value = 'desc';
				else
					sortOrder.value = 'asc';
							
				sortBy.value = 'description';
				break;
		}
					
	}
			
	//APPLY VOLUME
	else if (action == 'appVol')
	{
		if (thisForm.volume.value == "")
		{
			alert("Enter a volume to apply.");
			return;
		}
		
		var tmp = cycleDataForm('prodChkBx',action);
		
		if (tmp == "")
		{
			alert("At least one product must be selected to apply volume to.");
			return;
		}
		
		thisForm.applyVol.value = tmp;
	}
				
	//APPLY RATE FOR EACH PRODUCT/COMPONENT COMBINATION
	else if (action == 'appVolComp')
	{
		var tmpProd = cycleDataForm('prodChkBx',action);
		var tmpComp = cycleDataForm('comp',action);
		
		if (tmpProd == "" || tmpComp == "")
		{
			alert("At least one product and one component must be selected to apply rate/uom to.");
			return;
		}
		
		if (thisForm.apply_rate.value == "" && thisForm.uom.selectedIndex == 0)
		{
			alert("Either a rate has to be entered or a UOM selected.");
			return;	
		}
		
		thisForm.applyVol.value = tmpProd;
		thisForm.comps.value = tmpComp;
	}
			
	//ADDING COMPONENTS
	else if (action == 'comp')
	{

		var compLen = thisForm.compLen.value;
		var products = thisForm.Product_List.value;
		
		/* Dont allow the user to add the same component more than twice*/
		/* Initial Count */
		var ExistsComponent = 0;
		/*ID passed to javascript */
		var PassedNumber;
		if(window.document.dataForm.comp)
		{ 
			 if(window.document.dataForm.comp.length > 1)
			 {
				for(i=1; i<= window.document.dataForm.comp.length; i++)
				{
					if(eval("thisForm.compNameId_"+[i]+".value") == thisForm.compNameId.options[thisForm.compNameId.selectedIndex].value)
					{
					PassedNumber = parseInt(thisForm.compNameId.options[thisForm.compNameId.selectedIndex].value);
					ExistsComponent = parseInt(ExistsComponent) + PassedNumber;
						/* Divide the Passed SelectedIndex ID by the previously Selected Number (Chosen twice) */
						if(thisForm.compNameId.options[thisForm.compNameId.selectedIndex].value == ExistsComponent/2)
						{
						alert("You cannot add the same component more than twice");
						return false;
						}
					}
				}
			}
			/*
		 	else
		 	{
					if(thisForm.compNameId_1.value == thisForm.compNameId.options[thisForm.compNameId.selectedIndex].value)
					{
					ExistsComponent = parseInt(ExistsComponent) + parseInt(thisForm.compNameId.options[thisForm.compNameId.selectedIndex].value);
					if(thisForm.compNameId.options[thisForm.compNameId.selectedIndex].value == ExistsComponent/2)
					{
					alert("You cannot add the same component more than twice");
					return false;
					}
					}
			}
			*/
		}

		//check to see if there are any products
		if (products.length == 0 || products == "")
		{
			alert("You must select products before adding components.");
			return;
		}

		//limit components to 8
		if (compLen >= maxComponentPossible)
		{
			alert("Only a maximum of " + maxComponentPossible + " component(s) may be applied.");
			return;
		}
				
		//validate component data
		if (thisForm.compNameId.selectedIndex == 0)
		{
			alert("Please select a component.");
			return;
		}
		
		//check to make sure there are no components with the same paid to
		var tmpCompId = thisForm.compNameId.options[thisForm.compNameId.selectedIndex].value;
		var tmpPaidTo = 0;
		//check to see what paid to selection is made
		if (thisForm.Component_Paid_To[0].checked)
		{
			tmpPaidTo = thisForm.Component_Paid_To[0].value;
		}
		else if (thisForm.Component_Paid_To[1].checked)
		{
			tmpPaidTo = thisForm.Component_Paid_To[1].value;
		}
		for(i=1; i<= compLen; i++)
		{
			cmpNmeId = eval("thisForm.compNameId_"+[i]+".value");
			pdTo = eval("thisForm.compPaidTo_"+[i]+".value");
			//if the component and paid to combination already exists then show an alert
			if (tmpCompId == cmpNmeId && tmpPaidTo == pdTo)
			{
				alert("A component with this Paid To already exists. Please change the Paid To or select another component.");
				return;
			}
		}			
		//if the component is a USDA NOI Component...do not validate the rate as it will be empty
		if(thisForm.compNameId.options[thisForm.compNameId.selectedIndex].is_usda_comp == 0 ) {
			if (!validateNoVal(thisForm.rate.value, "Please provide a default rate.\n(You can edit rate for each item.)"))
				return;
		}
			
	}
		
	//SAVE
	else if (action == 'save')
	{
		//get the number of products and components
		var compLen = thisForm.compLen.value;
		var prodLen = thisForm.prodLen.value;
		
		if (!validateGroups())
			return;
			
		//check to make sure the sum of a products components isn't zero
		/*if (!checkCompSums(prodLen,compLen))
		{
			//alert("The highlighted items do not have any rates for any components.\nPlease remove the item or provide a rate for at least one component.");
			alert("Some of the item/component combinations do not have a rate assigned to them.\nPlease remove the item or provide a rate for at least one component.");
			return;
		}*/
	
		//check to make sure that if a product exists, then a component exists with it... or vice versa.
		if ((compLen == 0 && prodLen > 0) || (prodLen == 0 && compLen > 0))
		{
			alert("Rebate must contain at least one product and one component.");
			return;
		}
		

		//verify component names
		//if (!checkCompNames("Please make sure all components have a name."))
			//return;
		
		//check for zeros or no values
		if (!checkZeros())
			if (!confirm("The highlighted fields have a value of zero. Click Cancel to view them. Click OK to accept them."))
			//document.all.navigate.value = 0;
				return;
		
		//check to see if rules have to be applied
		if(bApplyRule())
		{
		if (donotallowproductsDE.value == 1)
		{
		if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
		{thisForm.deletedateexclusions.value = 1;
			NewWindow("apply_rebate_rule_popup.cfm?uriLocation=" + thisForm.sessionFile.value, "productwindow", 800, 600, "yes", "yes");
			return;
		}
		}
		else
		{
		NewWindow("apply_rebate_rule_popup.cfm?uriLocation=" + thisForm.sessionFile.value, "productwindow", 800, 600, "yes", "yes");
			return;
		}
		}

	}
	
	//set the action value then submit	
	thisForm.action.value = action;
	formaction = action;
	if (thisForm.action.value == 'save')
	{
	
	/**************** check payment cycle *********************/
	var oPaymentSelect = eval("document.all.PaymentCycle");
		if(oPaymentSelect) {
			oPaymentSelect.value = oPaymentSelect.value;
		} else {
			oPaymentSelect.value = 0;
		}
	
	if(oPaymentSelect.value == "0") {
			alert("Select a payment cycle");
			return;
		}
	/**************** check payment cycle *********************/
	
	document.all.navigate.value = 0;
	}
	else
	{
	document.all.navigate.value = 1;
	}
	//alert(donotallowproductsDE.value);
	if (donotallowproductsDE.value == 1 && action == 'save')
	{
		if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
		{thisForm.deletedateexclusions.value = 1;
		thisForm.submit();
		}
	}
	else
	{
		thisForm.submit();
	}
		
}//end submitForm function

//function to determine if rules have to be applied	
function bApplyRule() 
{

	var thisForm = document.dataForm;
	var rApplyRule = false;
	var hasRules = true;
	var compIndx = thisForm.compLen.value;
	var prodIndx = thisForm.prodLen.value;
	
	for (var i = 1; i<=compIndx; i++) 
	{
		var tmpComp = eval("thisForm.compHasRules_" + i + ".value");
		var tmpCompUoms = eval("thisForm.lCompRuleUoms_" + i + ".value");
		var tmpReqRules = eval("thisForm.compRulesReq_" + i + ".value");

		//if a components has rules then we have to check for the uom for that product/components combination
		if (tmpComp == 1 && tmpReqRules == 0)
		{
			var uomSelToCheck = eval("thisForm.uomsToCheck_" + i + ".value");
			var bRequired = eval("thisForm.compRulesReq_" + i + ".value");

			//split the list of product/component combination values
			var aProdUom = uomSelToCheck.split(",");
			var aCompUoms = tmpCompUoms.split(",");
			
			//now loop through and find if any of the uom's are percent. if they are, then return true
			for (n =0; n<aProdUom.length;n++)
			{
				
				var rebRule = eval("thisForm.reb_rule_" + aProdUom[n] + ".value");
				var rateVal = eval("thisForm.comp_rate_" + aProdUom[n] + ".value");
				var uomSelected = eval("thisForm.uom_" + aProdUom[n] + ".options[thisForm.uom_" + aProdUom[n] + ".selectedIndex].value");
				//if the uom is in the list, then return true
				for (num=0; num<aCompUoms.length;num++)
				{
					if (uomSelected == aCompUoms[num] && rateVal > 0)
					{
						if(trim(rebRule) == "" && bRequired == 1)
						{
							hasRules = false;
						}
						
						rApplyRule = true;
	
					}
				}
			}
			
		}
	}
	
	//if rules already exist then give the option to modify
	if(hasRules && rApplyRule)
	{
		if (!confirm("Click OK to modify Business Rules. Click Cancel to continue."))
		{
			rApplyRule = false;
		}
	}
	
	return rApplyRule;
	
}//end bApplyRule function


//function to get checkboxes in the rebates dataform	
function cycleDataForm(elem,action) 
{

	var elemVal = "";
	var elemColctn = document.dataForm.getElementsByTagName("input");
			
    for (var i = 0; i<elemColctn.length; i++) 
	{
		if ((elemColctn[i].name.indexOf(elem) > -1)) 
		{
			if (action == 'remProd')
			{
          		if (!elemColctn[i].checked) 
				{
					elemVal = listAppend(elemVal,elemColctn[i].value);
            	}//end if
			}//end if
			else
			{
				if (elemColctn[i].checked) 
				{
					elemVal = listAppend(elemVal,elemColctn[i].value);
            	}//end if
			}//end else
		}//end if
	}//end for
		
	return elemVal;
	
}//end cycleDataForm function

//function to check and see if any check boxes are selected for a particular element	
function validateCheckBoxes(elem) 
{

	var elemVal = "";
	var elemColctn = document.dataForm.getElementsByTagName("input");
			
    for (var i = 0; i<elemColctn.length; i++) 
	{
		if ((elemColctn[i].name.indexOf(elem) > -1)) 
		{
			if (elemColctn[i].checked) 
			{
				elemVal = listAppend(elemVal,elemColctn[i].value);
            }//end if
		}//end else
	}//end for
		
	return elemVal;
	
}//end validateCheckBoxes function

//function error checks for the sum of each component	
function checkCompSums(prodLen,compLen) 
{

	bCompSumValid = true;
	
	//loop through for each product component combination and sum values for each product
	for (var i = 1; i<=prodLen; i++)
	{
		var compTotl = 0;
		for (var n = 1; n<=compLen; n++)
		{
			var tmpId = i + "_" + n;
			var inpVal=parseFloat(document.getElementById(tmpId).value);
			compTotl = compTotl += inpVal;
		}
		
		if (!compTotl > 0)
		{
			bCompSumValid = false;
			var compRowId = "compRow_" + i;
			var compRow = document.getElementById(compRowId);
			//compRow.style.backgroundColor = "#FF0000";
		}
		
	}
	
	return bCompSumValid;
			
}//end checkCompSums function
	
//function error checks for zero or no values in data form	
function checkZeros() 
{

	var elemColctn = document.dataForm.getElementsByTagName("input");
	var isOk = true;
			
    for (var i = 0; i<elemColctn.length; i++) 
	{
		//if ((elemColctn[i].name.indexOf("volume_") > -1) || (elemColctn[i].name.indexOf("comp_rate_") > -1))
		if (elemColctn[i].name.indexOf("comp_rate_") > -1)
		{
			if(elemColctn[i].value <= 0)
			{
				elemColctn[i].style.background = '#FFFF00';
				isOk = false;
			}
		}
    }
			
	return isOk;
}//end checkZeros function

	
//function sets all product checkboxes to checked	
function checkAllProd()
{
	var elemColctn = document.dataForm.getElementsByTagName("input");

	for (var i = 0; i<elemColctn.length; i++) 
	{
		if ((elemColctn[i].name.indexOf('prodChkBx') > -1)) 
		{
			if (elemColctn.prodCheck.checked)
				elemColctn[i].checked = true;
			else
				elemColctn[i].checked = false;
        }
    }
}//end checkAllProd function

//function to set all products checkboxes of same type_code to checked
function checkMatchingProd(type_code,header)
{
	var elemColctn2 = document.dataForm.getElementsByTagName("input");
	for (var i = 0; i < elemColctn2.length; i++)
	{
		if (elemColctn2[i].id == type_code)
		{
			if (header.checked)
				elemColctn2[i].checked = true;
			else
				elemColctn2[i].checked = false;
		}
	}
}
//end check checkmatchingProd()



function addGroupsLevelProducts(groupLevel, groupId)
{
	if(window.confirm('Do you want to add all the products?')) 
	{
		if(groupLevel != 0)
		{
			var groupIdListObj = eval("document.all.Product_Level_" + groupLevel);
			groupIdListObj.value = groupId;
			submitForm('addGroupProducts');
		}
	}
}

//function error checks null values		
function validateNoVal(value,message)
{

	var isValid = true;
			
	if (trim(value) == "")
	{
		alert(message);
		isValid = false;
	}
	return isValid;
}//end validateNoVal function


//function error checks component names		
function checkCompNames(message)
{
	var isNotEmpty = true;
	var elemColctn = document.dataForm.getElementsByTagName("input");

	for (var i = 0; i<elemColctn.length; i++) 
	{
		if ((elemColctn[i].name.indexOf("compName_") > -1))
		{
			if (!validateNoVal(elemColctn[i].value,message))
				isNotEmpty = false;
		}
    }
			
	return isNotEmpty;
}//end checkCompNames function

//listAppend function
function listAppend(list, value)
{

	if (list == "")
	{
		list += value;
		return list;
	}
	else
	{
		list += "," + value;
		return list;
	}
}//end listAppend function

//check navigate
		function resetnavigate()
		{
			document.all.navigate.value = 1;
		}
		function verifyNavigate() {
		if(formaction == null)
		{
			if (document.all.navigate.value == 1 && document.all.stopnavigate.value == 0) {
				{
					event.returnValue="Your changes will not be saved if you click OK";
			}
		}	}
		}
		
//if the selected component name is a usda compoonent....disable the rate box	
function  disableRateBox(oSelect) {
	oOpt = oSelect.options[oSelect.selectedIndex]
	if(oOpt.is_usda_comp == 1) {
		document.all.rate.value = '';
		document.all.rate.readOnly  = true;
	}
	else {
		document.all.rate.readOnly  = false;
	}
}

//validate groups
function  validateGroups() 
{

	var thisForm = document.dataForm;
	var level1 = thisForm.Level_1.value;
	var level2 = thisForm.Level_2.value;
	var level3 = thisForm.Level_3.value;
	
	var bIsValid= true;

	//validate group levels
	//if we have something in level 3 make sure something is in level 1 and 2
	if (trim(level3) != "")
	{
		if(trim(level2) == "")
		{
			alert("Level 2 cannot be empty if Groups or Products exist in Level 3.");
			bIsValid = false;
			return bIsValid;
		}
		else if(trim(level1) == "")
		{
			alert("Level 1 cannot be empty if Groups or Products exist in Level 2 or Level 3.");
			bIsValid = false;
			return bIsValid;
		}
	}
	
	//if we have something in level 2 make sure something is in level 1
	if (trim(level2) != "")
	{
		if(trim(level1) == "")
		{
			alert("Level 1 cannot be empty if Groups or Products exist in Level 2.");
			bIsValid = false;
			return bIsValid;
		}
	}
	
	return bIsValid;
}
