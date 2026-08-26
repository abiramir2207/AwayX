// JavaScript Document

//function get's called on all submits
function submitForm(command, disableClickedButton, disableClickedButtonName)
{
	var thisForm = document.dataForm;
	
	if (!checkMinMax())
	{
		alert("Fields highlighted yellow are below the minimum value. Fields highlighted red are above the maximum.")
		return;
	}
	
	//make sure price offered is greater than zero
	if(!checkZeros("net_"))
	{
		alert("Price Offered cannot be zero.");
		return false;
	}
	
	if(disableClickedButton)
	{
		disableButton(disableClickedButtonName, true, false);		
	}
	
	//set the action value then submit	
	thisForm.command.value = command;
	thisForm.submit();
		
}//end submitForm function

//function get's called for sorting
function sortByThis(sortBy)
{
	var thisForm = document.dataForm;
	
	//set the sort values	
	thisForm.sort_by.value = sortBy;
	//handle for sort order
	soField = thisForm.sort_order;
	soVal = soField.value;
	if (soVal == 'asc')
	{
		soField.value = 'desc';
	}
	else
	{
		soField.value = 'asc';
	}
	
	thisForm.submit();
	
}//end submitForm function

//function get's called when allowance value gets changed
function adjustNet(prodId)
{
	
	var thisForm = document.dataForm;
	
	//get default price and allowance
	//if the uom is CS(1) then get the default price for case, otherwise get it for lb
	if(getSelectedUomId(prodId) == 1)
	{
		dpVal = getDefaultCSPrice(prodId);
	}
	else
	{
		dpVal = getDefaultLBPrice(prodId);
	}
	
	allowField = eval("thisForm.allowance_" + prodId);
	allowVal = parseFloat(allowField.value);
	
	if (isNaN(allowVal))
	{
		allowVal = 0.0000;
	}
	
	allowField.value = formatToDeciamalPlaces(allowVal, 4);
	
	//calculate
	netVal = dpVal - allowVal;

	//if the net value is less that zero throw an alert
	if(netVal < 0)
	{
		alert("Price Offered cannot be less than zero.");
		allowField.value = "0.0000";
		return;
	}
	
	//format decimals
	netVal = formatToDeciamalPlaces(netVal, 4);
	//then set the form value
	netField = eval("thisForm.net_" + prodId);
	netField.value = netVal;
	
	
}//end adjustNet function

//function get's called when net value gets changed
function adjustAllowance(prodId)
{
	var thisForm = document.dataForm;
	
	//get default price and allowance
	//if the uom is CS(1) then get the default price for case, otherwise get it for lb
	if(getSelectedUomId(prodId) == 1)
	{
		dpVal = getDefaultCSPrice(prodId);
	}
	else
	{
		dpVal = getDefaultLBPrice(prodId);
	}

	netField = eval("thisForm.net_" + prodId);
	netVal = parseFloat(netField.value);
	
	if (isNaN(netVal))
	{
		netVal = 0.0000;
	}
	
	netField.value = formatToDeciamalPlaces(netVal, 4);
	
	//calculate if the netVal is greater than zero
	if (netVal > 0)
	{
		allowVal = dpVal - netVal;
	}
	else
	{
		return;
	}
	
	//if the allowance value is less that zero throw an alert
	if(allowVal < 0)
	{
		alert("Allowance cannot be less than zero.");
		netField.value = "0.0000";
		return;
	}
	
	//format decimals
	allowVal = formatToDeciamalPlaces(allowVal, 4);
	//then set the form value
	allowField = eval("thisForm.allowance_" + prodId);
	allowField.value = allowVal;
	
}//end adjustAllowance function

//function get's called when the uom get's changed
function uomChange(prodId)
{
	//set variables needed
	var thisForm = document.dataForm;
	var dpDiv = eval("default_price_" + prodId);
	var defaultCSPrice = eval("thisForm.display_default_cs_price_" + prodId + ".value");
	var defaultLBPrice = eval("thisForm.display_default_lb_price_" + prodId + ".value");
	
	//if the uom is CS(1) then set the default price to the default price for case
	if(getSelectedUomId(prodId) == 1)
	{
		dpDiv.innerText = defaultCSPrice;
	}
	else
	{
		dpDiv.innerText = defaultLBPrice;
	}
	
	adjustNet(prodId);
	
}//end uomChange function

//function get's selected uom id based on product id
function getSelectedUomId(prodId)
{
	var thisForm = document.dataForm;
	var selUomId = eval("thisForm.uom_" + prodId + ".options[thisForm.uom_" + prodId + ".selectedIndex].value");
	
	return selUomId;
	
}//end getSelectedUomId function

//function get's default case price based on product id
function getDefaultCSPrice(prodId)
{
	var thisForm = document.dataForm;
	var dpCSPrice = eval("thisForm.default_cs_price_" + prodId + ".value");
	
	return dpCSPrice;
	
}//end getDefaultCSPrice function

//function get's default lb price based on product id
function getDefaultLBPrice(prodId)
{
	var thisForm = document.dataForm;
	var dpLBPrice = eval("thisForm.default_lb_price_" + prodId + ".value");
	
	return dpLBPrice;
	
}//end getDefaultLBPrice function

//function will disable/enable the won by fields based off won/lost drop down
function setWonFields(prodId)
{
	var thisForm = document.dataForm;
	var wonId = eval("thisForm.Won_" + prodId + ".options[thisForm.Won_" + prodId + ".selectedIndex].value");
	//var wonByObj = eval("thisForm.won_by_" + prodId);
	var wonPriceObj = eval("thisForm.won_price_" + prodId);
	var wonUomObj = eval("thisForm.won_uom_" + prodId);
	var wonDeliveryObj = eval("thisForm.won_delivery_type_" + prodId);
  var wonByIDObj = eval("thisForm.won_by_id_" + prodId);
  var categoryIDObj = eval("thisForm.category_id_" + prodId);
  var packageIDObj = eval("thisForm.package_id_" + prodId);
    
	if (wonId == 1)
	{
		//wonByObj.disabled = true;
		wonPriceObj.disabled = true;
		wonUomObj.disabled = true;
    wonByIDObj.disabled = true;
    categoryIDObj.disabled = true;
    packageIDObj.disabled = true;
    
		if(wonDeliveryObj){
		wonDeliveryObj.disabled = true;
		}
		//wonByObj.className = 'disable';
		wonPriceObj.className = 'disable';
		wonUomObj.className = 'disable';
    wonByIDObj.className = 'disable';
    categoryIDObj.className = 'disable';
    packageIDObj.className = 'disable';
		if(wonDeliveryObj){
		wonDeliveryObj.className = 'disable';
		}
	}
	else
	{
		//wonByObj.disabled = false;
		wonPriceObj.disabled = false;
		wonUomObj.disabled = false;
    wonByIDObj.disabled = false;
    categoryIDObj.disabled = false;
    packageIDObj.disabled = false;    
		if(wonDeliveryObj){
		wonDeliveryObj.disabled = false;
		}
		//wonByObj.className = 'enable';
		wonPriceObj.className = 'enable';
		wonUomObj.className = 'enable';
    wonByIDObj.className = 'enable';
    categoryIDObj.className = 'enable';
    packageIDObj.className = 'enable';    
		if(wonDeliveryObj){
		wonDeliveryObj.className = 'enable';
		}
	}
	
}//end setWonFields function
	
//function will handle NaN when formatting decimals 
function decimalNumFormat(value, decimalPlaces)
{
	
	if (isNaN(value))
	{
		value = 0.00;
		returnVal = formatToDeciamalPlaces(value, decimalPlaces);
	}
	else
	{
		returnVal = formatToDeciamalPlaces(value, decimalPlaces);
	}
	
	return returnVal;
	
}//end decimalNumFormat function

//function error checks for zero or no values in data form	
function checkZeros(elemPref) 
{

	var thisForm = document.dataForm;
	var elemColctn = thisForm.getElementsByTagName("input");
	var isOk = true;
			
    for (var i = 0; i<elemColctn.length; i++) 
	{
		if (elemColctn[i].name.indexOf(elemPref) > -1)
		{
			if(elemColctn[i].value <= 0 && !elemColctn[i].isDisabled)
			{
				isOk = false;
				return isOk;
			}
		}
    }
		
	return isOk;
}//end checkZeros function

//function checks for minimum and maximum values
function checkMinMax() 
{
	var thisForm = document.dataForm;
	var elemColctn = thisForm.getElementsByTagName("input");
	var isOk = true;
	var AllowName = "allowance_";
	var Suffix;
	var UOMName;
	
	
	for (var i = 0; i<elemColctn.length; i++) 
	{
		if (elemColctn[i].name.indexOf(AllowName) > -1)
		{
			
			Suffix = elemColctn[i].name.substring(AllowName.length, elemColctn[i].name.length);	
			inpVal = elemColctn[i].value
			inpName = elemColctn[i];
			inpUOM = eval("thisForm.uom_" + Suffix);
			
			inpName.style.background = 'white';
			
			if((thisForm.ThereisMinorMax.value == 1)  && (inpVal != "NaN") && (inpName.disabled == false))
			{	
				if((inpUOM.value == 1) && (inpVal.value != ""))
				{								
					if((thisForm.Min_BidRequest_Case.value != 0) && (thisForm.Min_BidRequest_Case.value.length != 0))
					{	
						if(inpVal < thisForm.Min_BidRequest_Case.value)
						{	inpName.style.background = 'yellow'
							isOk = false;
						}
					}
				
					if(document.dataForm.Max_BidRequest_Case.value != 0)
					{					
						if(inpVal > document.dataForm.Max_BidRequest_Case.value)
						{
							inpName.style.background = 'red'
							isOk = false;
						}
					}		
					
				}
				else if((inpUOM.value == 2) && (inpVal.value != ""))
				{
					if((document.dataForm.Min_BidRequest_Pound.value != 0) && (thisForm.Min_BidRequest_Pound.value.length != 0))
					{
						alert("~" + thisForm.Min_BidRequest_Case.value + "~")	
						if(inpVal < document.dataForm.Min_BidRequest_Pound.value)
						{
							inpName.style.background = 'yellow'
							isOk = false;
						}
					}
					
					if(document.dataForm.Max_BidRequest_Pound.value != 0)
					{
					
						if(inpVal > document.dataForm.Max_BidRequest_Pound.value)
						{
							inpName.style.background = 'red'
							isOk = false;
						}
					}	
				}	
				
				else if((inpUOM.value == 3) && (inpVal.value != ""))
				{
					if(document.dataForm.Min_BidRequest_Percent.value != 0)
					{
						if(inpVal < document.dataForm.Min_BidRequest_Percent.value)
						{
							inpName.style.background = 'yellow'
							isOk = false;
						}
					}
					
					if(document.dataForm.Max_BidRequest_Percent.value != 0)
					{
					
						if(inpVal > document.dataForm.Max_BidRequest_Percent.value)
						{
							inpName.style.background = 'red'
							isOk = false;
						}
					}	
				}				
			}		
		}
    }
	
	
	return isOk;
}//end checkMinMax function




