// JavaScript Document

//////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////Helper Functions/////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

	function formatDate(date)
	{

		var day = date.getDate();
		var month = date.getMonth();
		month = month+1;
		var year = date.getFullYear();
		var formatDate = month + "/" + day + "/" + year;
		
		return formatDate;
	}
	
	function outputMoney(num)
	{
	
		var amount = "$" + formatWithComma(formatToDeciamalPlaces(num,2),3,true);
		if (num < 0)
		{
			amount = "<font color='red'>(" + amount + ")</font>";
		}
		return  amount;
	}
	
	function percent(num)
	{
		var temp = num * 100;
		var temp1 = formatWithComma(formatToDeciamalPlaces(temp, 2),3,true) + "%";
		if (num < 0)
			temp1 = "<font color='red'>(" + temp1 + ")</font>";
		return temp1;
	}
//////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////Validation Functions/////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
	
	//Compare qty values entered to volume values from forecast
	function compareWithFocst(qtyItemCount)
	{
		
		var prodId = eval("document.marginForm.planProduct" + qtyItemCount + ".value");
		var tpQty = eval("document.marginForm.qty" + qtyItemCount + ".value");
		var qtyFcsSpan = eval("qtyFsctSts" + qtyItemCount);
		
		//loop through ForeCst JS object that was set using cfwddx in trade_plan_calc.cfm
		for (var rowNum = 0; rowNum < ForeCst.getRowCount(); rowNum++) 
		{
			
			//match for the proper row using product id's
			if (prodId == ForeCst.product_id[rowNum] && ForeCst.volume_cs[rowNum] != null)
			{	
				//if qty doesn't match what's in forecast then indicate it
				if (ForeCst.volume_cs[rowNum] != tpQty)
				{
					qtyFcsSpan.innerHTML = "<font color=FF0000>(2)</font>";
				}
				//if they do match then remove any message
				else
				{
					qtyFcsSpan.innerHTML = "";
				}
			}  
      	}
	}
	
	//check the forecast date with the date entered in the trade plan using JS
	function checkForcstDate()
	{
		
		if (event.type == "change" || (event.propertyName == "value" && document.activeElement.name != "start_date" && document.activeElement.name != "end_date"))
		{
			//alert(event.type);
			//if (event.propertyName == "value")
			{

				var tpStartDate = new Date(document.marginForm.start_date.value);
				var fcStartDate = new Date(ForeCstData.app_area_start_date[0]);
				var tpEndDate = new Date(document.marginForm.end_date.value);
				var fcEndDate = new Date(ForeCstData.app_area_end_date[0]);
				var disfcStDt = formatDate(fcStartDate);
				var disfcEndDt = formatDate(fcEndDate);
			
				if (tpStartDate > fcStartDate || tpStartDate < fcStartDate || tpEndDate > fcEndDate || tpEndDate < fcEndDate)
				{
					//forcstDtMsg.innerHTML = "<font color=FF0000>Trade Plan date span is different from last forecast.<br>Trade Plan date span in last forecast was " + disfcStDt + " to " + disfcEndDt + ".</font>";
					forcstDtMsg.style.visibility = "visible";
				}
				else
				{
					//forcstDtMsg.innerHTML = "";
					forcstDtMsg.style.visibility = "hidden";
				}
			}
		}
	}
	
	function checkString(value)
	{
		isEmpty = true;
		if(trim(value) == "")
			isEmpty = false;
		return isEmpty;
	}
	
	function getItemClassTotals(column,itemClass)
	{		
		var classVal = parseFloat(eval("document.marginForm." + column + itemClass + ".value"));
		return classVal;
	}
	
	function validateValues(val, message) 
	{
		var isValid = true;
		
		if (val == "")
		{
			alert(message);
			isValid = false;
		}
		
		return isValid;
	}
	
	function validateInput()
	{
		var inpValid = true;
		
		//get all the form field values
		var margForm = document.marginForm;
		var title = margForm.tradePlanTitle.value;
		var dist = margForm.Distributor_List.value;
		var prod = margForm.Product_List.value;
		var note = margForm.notes.value;
		var startDate = margForm.start_date.value;
		var endDate = margForm.end_date.value;

		//validate all input fields
		if (!validateValues(title,"Please provide a report title")) {inpValid = false; return inpValid};
		if (!validateValues(note,"Please provide a note")) {inpValid = false; return inpValid};
		if (!validateValues(dist,"Please select a distributor")) {inpValid = false; return inpValid};
		if (!validateValues(startDate,"Please provide a Start Date")) {inpValid = false; return inpValid};
		if (!validateValues(endDate,"Please provide an End Date")) {inpValid = false; return inpValid};
		if (!validateValues(prod,"Please select products")) {inpValid = false; return inpValid};
		
		//check date spans
		fromDate = new Date(startDate);
		toDate = new Date(endDate);		
		
		if(toDate < fromDate)
		{
			alert("The To Date Must Be After The From Date");
			inpValid = false;
			return inpValid;
		}
		
		var totalList = margForm.itemTotal.value;
		var totalArray = totalList.split(",");

		for (i =0; i<totalArray.length;i++)
		{
			var classList = eval("document.marginForm.classItemTotal" + i + ".value");
			var classArray = classList.split(",");
			
			for (n =0; n<classArray.length;n++)
			{
				var propPrc = parseFloat(eval("document.marginForm.proposedPrice" + classArray[n] + ".value"));
				var qty = parseFloat(eval("document.marginForm.qty" + classArray[n] + ".value"));		
		
				if (isNaN(propPrc) || isNaN(qty))
				{
					alert("Please provide a value for price list and quantity");
					inpValid = false; 
					return inpValid;
				}
				
				if (propPrc == 0 || qty == 0)
				{
					alert("Price list and quantity values must be greater than 0");
					inpValid = false; 
					return inpValid;
				}
				
			}
		}
		
		return inpValid;
	}
	
//////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////DHTML Functions//////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

	function setStyle(val)
	{

		if (val >= 0)
		{
			document.all.netMargLblId.className = 'netMargLblClsGrn';
			document.all.netMargValId.className = 'netMargValClsGrn';
			document.all.netProfLblId.className = 'netProfLblClsGrn';
			document.all.netProfValId.className = 'netProfValClsGrn';
		
		}
		else
		{
			document.all.netMargLblId.className = 'netMargLblClsRed';
			document.all.netMargValId.className = 'netMargValClsRed';
			document.all.netProfLblId.className = 'netProfLblClsRed';
			document.all.netProfValId.className = 'netProfValClsRed';
		}
	}

	function addFilterRows(thisObj)
    {
		var pObj = document.getElementById("enterTable");
		var trObj = getParentElem(thisObj,"TR");
		var inputObj = trObj.getElementsByTagName("input");
		var selectObj = trObj.getElementsByTagName("select");
		var costSection = trObj.section;
		
		//First do validation for each cost type
		if (costSection == "incentive")
		{
			var costField = inputObj[0].name;

			if (selectObj[0].selectedIndex == 0)
			{
				alert("Select a name for cost.");
				return;
			}
			if (eval("trObj.all." + costField + ".value") == "")
			{
				alert("Enter a value for cost.");
				return;
			}
			if (eval("trObj.all." + costField + ".value") <= 0)
			{
				alert("Cost must be greater than zero.");
				return;
			}
			
		}
		else
		{
			var costNameField = inputObj[0].name;
			var costField = inputObj[1].name;

			if (eval("trObj.all." + costNameField + ".value") == "")
			{
				alert("Enter a name for cost.");
				return;
			}
			if (eval("trObj.all." + costField + ".value") == "")
			{
				alert("Enter a value for cost.");
				return;
			}
			
			if (eval("trObj.all." + costField + ".value") <= 0)
			{
				alert("Cost must be greater than zero");
				return;
			}
			
		}
		
		var trNext = trObj.nextSibling;
		if (trNext)
		{
			if (trNext.id)
			{
				if (trNext.id == trObj.id)
					return;
			}
		}
		
	 	var trIndex = trObj.rowIndex;
     	var rObj = pObj.insertRow(trIndex+1);
		if (trObj.id)
		{
			rObj.id = trObj.id;
		}
		if (trObj.section)
		{
			rObj.section = trObj.section;
		}
	 	var coLen = trObj.cells.length;
	 	for (i=0;i<coLen;i++)
	 	{
			var cObj = rObj.insertCell(i);
			if (trObj.cells[i].align)
			{
				cObj.align = trObj.cells[i].align;
			}
     		cObj.innerHTML = incrementName(trObj.cells(i).innerHTML);
			var inputCol = cObj.getElementsByTagName("input");
			for (j=0;j<inputCol.length;j++)
			{
				if (inputCol[j].type == "text")
				{
					inputCol[j].value = "";
				}
				
				if (inputCol[j].type == "checkbox")
				{
					inputCol[j].checked = true;
				}
			}
			
			var inputCol = cObj.getElementsByTagName("select");
			for (j=0;j<inputCol.length;j++)
			{
				inputCol[j].selectedIndex = 0;
			}
			
			var inputCol = cObj.getElementsByTagName("div");
			for (j=0;j<inputCol.length;j++)
			{
				inputCol[j].innerText = "";
			}
	 	}
	}
    
    function deleteFilterRows(thisObj)
    {
     	var trObj = getParentElem(thisObj,"TR");
     	if(!trObj)
      		return;
     	var rIndex = trObj.rowIndex;
     	if(rIndex > 0)
     	{
			dontDelete = false; 
			if(trObj.previousSibling.id && trObj.nextSibling.id)
			{
				if (trObj.previousSibling.id == "incentiveHeader" && trObj.nextSibling.id == "totRow")
				{
					dontDelete = true;
				}
			}
			
			if (!dontDelete)
			{
				var pObj = document.getElementById("enterTable");
      			pObj.deleteRow(rIndex);			
			}

     	}
    }
    
    function getParentElem(thisObj, pTag)
    {
    	if(thisObj.tagName == pTag)
      		return thisObj;
     	if(thisObj.tagName == "BODY")
      		return null;
     	return getParentElem(thisObj.parentElement, pTag);
    }
	
	function incrementName(checkHTML)
 	{
  		var regExp = new RegExp("((name|id)=.*?_(.*?))[\"\\s>]", "igm");
  		var arr = checkHTML.match(regExp);
  		var i;
  		var newHTML = checkHTML;
		if (arr)
		{
  			for(i=0;i<arr.length;i++)
  			{
   				var idField = arr[i];
   				var arr2 = /_(.*?)$/.exec(idField);
   				var indexNumber = RegExp.$1;
   
   				newIndexNumber = parseFloat(indexNumber);
   				if(!isNaN(newIndexNumber))
   				{
    				newIndexNumber = newIndexNumber + 1;
    				var regExp = new RegExp("_" + indexNumber, "igm");
    				newIDField = idField.replace(regExp, "_" + newIndexNumber + idField.substr(idField.length-1));
    				var regExp = new RegExp(idField, "igm");
    				var newHTML = newHTML.replace(regExp, newIDField); 
   				}  
			} 
  		}
		
  		return newHTML;
 	}
	
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
/////////////////////////////////Functions Called from the Form/////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	function showDistributorSearchWindow() 
	{
		NewWindow("/billbacks/search_screens/PM_select_distributors.cfm?Formname=marginForm", "distributorwindow", 800, 600, "yes", "yes");
	}
	
	function showProductSearchWindow() 
	{
		NewWindow("../../common_files/contracts/product_Select_V1.cfm?Formname=marginForm", "productwindow", 800, 600, "yes", "yes");
	}
	
	function showVolApplicator() 
	{	
		var formObj = document.all.marginForm;
		var distVal = formObj.Distributor_List.value;
		var prodVal = formObj.Product_List.value;
		var dtFrom = formObj.start_date.value;
		var dtTo = formObj.end_date.value;		
		
		//make sure we have a distributor, products, start and end dates
		if (!validateValues(distVal,"Please select a distributor")) return;
		if (!validateValues(dtFrom,"Please select a start date")) return;
		if (!validateValues(dtTo,"Please select an end date")) return;
		if (!validateValues(prodVal,"Please select products")) return;

		if(formObj)
		{
			var priorAction = formObj.action.value;
			var oldtarget = formObj.target;
			formObj.target = "volumewindow";
			formObj.action.value = "volumeApp";
			NewWindow("", "volumewindow", 850, 650, "yes", "yes");
			formObj.submit();
			
			formObj.action.value = priorAction;
			formObj.target = oldtarget;
		}
	}
	
	//Function called from input fields for items
	function calculate(itemCount, itemClassCount)
	{
		
		var forecastId = document.marginForm.forecast_id.value;
		
		if (forecastId > 0)
		{
			compareWithFocst(itemCount);
		}

		//format list price
		var propPrce = eval("document.marginForm.proposedPrice" + itemCount + ".value");
		var propPrceInp = eval("document.marginForm.proposedPrice" + itemCount);
		//alert(propPrceInp.value);
		propPrceInp.value = formatToDeciamalPlaces(propPrce, 2);
		
		
		//call calculation methods
		calculateFreightWeight(itemCount,itemClassCount);
		calculateTotalCost(itemCount,itemClassCount);
		calculateRevenue(itemCount,itemClassCount);
		calculateMixedRevenue();
		calculateMixedWeight();
		calculateMarginDoll(itemCount,itemClassCount);
		calculateMargin();
		calculateQty(itemCount,itemClassCount);
	}
		
//////////////////////////////////Totaling functions///////////////////////////////////////////////////////

	//Function to sum up the totals for each item class
	function totalIemClass(itemsToGet,classItemToSet,itemClassCount,format)
	{
		var classList = eval("document.marginForm.classItemTotal" + itemClassCount + ".value");
		var classArray = classList.split(",");
		var classTotal = 0;
		
		for (i =0; i<classArray.length;i++)
		{
			if (eval("document.marginForm." + itemsToGet + classArray[i] + ".value") != '')
			{
				classTotal += parseFloat(eval("document.marginForm." + itemsToGet + classArray[i] + ".value"));
			}
		}
		
		var classTotalField = eval("document.marginForm."  + classItemToSet + itemClassCount);
		classTotalField.value = classTotal;
		
		var formatVal = classTotal;
		switch (format)
		{
			case "comma":
				formatVal = formatWithComma(formatToDeciamalPlaces(formatVal,2),3);
				break;
			case "dollar":
				formatVal = outputMoney(formatVal);
				break;
			case "percent":
				formatVal = percent(formatVal);
				break;
			default:
		}
		var classTotalDiv = eval(classItemToSet + "Div" + itemClassCount);
		if (classItemToSet == "freightWeightItemClassTotal")
			formatVal = formatVal;
		classTotalDiv.innerHTML = formatVal;
	
	}
	
	//Function to sum up the totals for each item
	function totalIem(classItemToGet,totalToSet,format)
	{
		
		var totalList = document.marginForm.itemTotal.value;
		var totalArray = totalList.split(",");
		var total = 0;
		
		for (i =0; i<totalArray.length;i++)
		{
			if (eval("document.marginForm." + classItemToGet + totalArray[i] + ".value") != '')
			{
				total += parseFloat(eval("document.marginForm." + classItemToGet + totalArray[i] + ".value"));
			}
		}

		var totalField = eval("document.marginForm."  + totalToSet);
		//if (total != 0)
		//{	
			totalField.value = total;
			
			var formatVal = total;
			switch (format)
			{
				case "comma":
					formatVal = formatWithComma(formatToDeciamalPlaces(formatVal,2),3);
					break;
				case "dollar":
					formatVal = outputMoney(formatVal);
					break;
				case "percent":
					formatVal = percent(formatVal);
					break;
				default:
			}
			
			var totalDiv = eval(totalToSet + "Div");
			if (totalToSet == "freightWeightItemTotal")
				formatVal = formatVal;
			totalDiv.innerHTML = formatVal;
		//}
	}
	
///////////////////////////////////Quantity///////////////////////////////////////
	
	//Function that calculates QTY
	function calculateQty(itemCount,itemClassCount)
	{
		var qty = parseFloat(eval("document.marginForm.qty" + itemCount + ".value"));
		
		
		if(! isNaN(qty))
		{
			totalIemClass("qty","qtyItemClassTotal",itemClassCount,"comma");
			totalIem("qtyItemClassTotal","qtyItemTotal","comma");
		}
	}
	
///////////////////////////////////Freight weight///////////////////////////////////////	
	//Function to calculate the freight weight for a given item
	function calculateFreightWeight(itemCount,itemClassCount) 
	{
		var qty = parseFloat(eval("document.marginForm.qty" + itemCount + ".value"));
		var tempCaseNetWeight = parseFloat(eval("document.marginForm.caseNetWeight" + itemCount + ".value"));
		
		if(! isNaN(qty))
		{	
			var freightWeight = eval("document.marginForm.freightWeight" + itemCount);
			var fwDiv = eval("freightWeightDiv" + itemCount);
			var calcWgt = qty * tempCaseNetWeight;
			fwDiv.innerHTML = formatWithComma(formatToDeciamalPlaces(calcWgt,2), 3);
			freightWeight.value = calcWgt;
			totalIemClass("freightWeight","freightWeightItemClassTotal",itemClassCount,"comma");
			totalIem("freightWeightItemClassTotal","freightWeightItemTotal","comma");
		}
	}
	
///////////////////////////////////Total Cost///////////////////////////////////////
	
	//Function to calculate the total cost for a given item
	function calculateTotalCost(itemCount,itemClassCount) 
	{
		var qty = parseFloat(eval("document.marginForm.qty" + itemCount + ".value"));
		var tempCaseCost = parseFloat(eval("document.marginForm.caseCost" + itemCount + ".value"));
		
		if(! isNaN(qty))
		{
			var inpTotalCost = eval("document.marginForm.totalCost" + itemCount);
			var tlCosCalc = qty * tempCaseCost;
			inpTotalCost.value = tlCosCalc;
			var tcOutVal = outputMoney(tlCosCalc);
			var tcDiv = eval("totalCostDiv" + itemCount);
			tcDiv.innerHTML = tcOutVal;
			totalIemClass("totalCost","totalCostItemClassTotal",itemClassCount,"dollar");
			totalIem("totalCostItemClassTotal","totalCostItemTotal","dollar");
		}

	}

///////////////////////////////////Revenue///////////////////////////////////////

	//Function to calculate the revenue for a given item
	function calculateRevenue(itemCount,itemClassCount) 
	{
		var qty = parseFloat(eval("document.marginForm.qty" + itemCount + ".value"));
		var tempPropPrice = parseFloat(eval("document.marginForm.proposedPrice" + itemCount + ".value"));
		
		if(! isNaN(qty) && ! isNaN(tempPropPrice))
		{
			var revenue = eval("document.marginForm.revenue" + itemCount);
			var revCalc = qty * tempPropPrice;
			revenue.value = revCalc;
			var revOutVal = outputMoney(revCalc);
			var revDiv = eval("revenueDiv" + itemCount);
			revDiv.innerHTML = revOutVal;
			totalIemClass("revenue","revenueItemClassTotal",itemClassCount,"dollar");
			totalIem("revenueItemClassTotal","revenueItemTotal","dollar");
		}
	}
	
///////////////////////////////////Mixed Revenue///////////////////////////////////////
		
	//Function to calculate the mixed revenue for a given item
	function calculateMixedRevenue() 
	{
		
		var totalList = document.marginForm.itemTotal.value;
		var totalArray = totalList.split(",");
		var mxRevCalc = 0;
		var itmClsTot = 0;
		
		for (i =0; i<totalArray.length;i++)
		{
			var classList = eval("document.marginForm.classItemTotal" + i + ".value");
			var classArray = classList.split(",");
			
			for (n =0; n<classArray.length;n++)
			{
				var revenue = parseFloat(eval("document.marginForm.revenue" + classArray[n] + ".value"));
				var revenueTotal = parseFloat(eval(document.marginForm.revenueItemTotal.value));		
				if(! isNaN(revenue))
				{
					var tempMixRevenue = eval("document.marginForm.mixRevenue" + classArray[n]);
					if (revenueTotal != 0)
						mxRevCalc = revenue / revenueTotal;
					tempMixRevenue.value = mxRevCalc;
					//display
					var mxRevOutVal = percent(mxRevCalc);
					var mxRevDiv = eval("mixRevenueDiv" + classArray[n]);
					mxRevDiv.innerHTML = mxRevOutVal;
				}
			}
			
			var revenueItemClass = parseFloat(eval("document.marginForm.revenueItemClassTotal" + totalArray[i] + ".value"));
			var mixRevenueItemClass = eval("document.marginForm.mixRevenueItemClassTotal" + totalArray[i]);
			if (! isNaN(revenueItemClass))
			{
				if (revenueTotal != 0)
					itmClsTot = revenueItemClass / revenueTotal;
				mixRevenueItemClass.value = itmClsTot;
				var itmClTotDiv = eval("mixRevenueItemClassTotalDiv" + totalArray[i]);
				var itmClTotOutVal = percent(itmClsTot);
				itmClTotDiv.innerHTML = itmClTotOutVal;
			}
		}
		
		totalIem("mixRevenueItemClassTotal","mixRevenueItemTotal","percent");
	}
	
///////////////////////////////////Mixed Weight///////////////////////////////////////

	//Function to calculate the mixed weight for a given item
	function calculateMixedWeight() 
	{
		var totalList = document.marginForm.itemTotal.value;
		var totalArray = totalList.split(",");
		var mxWgtCalc = 0;
		var mxWgtClsTotCalc = 0;
		
		for (i =0; i<totalArray.length;i++)
		{
			var classList = eval("document.marginForm.classItemTotal" + i + ".value");
			var classArray = classList.split(",");
			
			for (n =0; n<classArray.length;n++)
			{
				var freightWeight = parseFloat(eval("document.marginForm.freightWeight" + classArray[n] + ".value"));
				var freightWeightTotal = parseFloat(eval(document.marginForm.freightWeightItemTotal.value));		
				if(! isNaN(freightWeight) && ! isNaN(freightWeightTotal))
				{
					var tempMixWeight = eval("document.marginForm.mixWeight" + classArray[n]);
					if (freightWeightTotal != 0)
						mxWgtCalc = freightWeight / freightWeightTotal;
					tempMixWeight.value = mxWgtCalc;
					//display
					var mxWgtOutVal = percent(mxWgtCalc);
					var mxWgtDiv = eval("mixWeightDiv" + classArray[n]);
					mxWgtDiv.innerHTML = mxWgtOutVal;
				}
			}
			
			var freightWeightItemClass = parseFloat(eval("document.marginForm.freightWeightItemClassTotal" + totalArray[i] + ".value"));
			var mixWeightItemClass = eval("document.marginForm.mixWeightItemClassTotal" + totalArray[i]);
			if (! isNaN(freightWeightItemClass))
			{
				if (freightWeightTotal != 0)
					mxWgtClsTotCalc = freightWeightItemClass / freightWeightTotal;
				mixWeightItemClass.value = mxWgtClsTotCalc;
				var mxItmClTotDiv = eval("mixWeightItemClassTotalDiv" + totalArray[i]);
				var mxItmClTotOutVal = percent(mxWgtClsTotCalc);
				mxItmClTotDiv.innerHTML = mxItmClTotOutVal;
				
			}
		}
		totalIem("mixWeightItemClassTotal","mixWeightItemTotal","percent");
			
	}
	
///////////////////////////////////Margin Dollar///////////////////////////////////////
	
	//Function to calculate the margin for a given item
	function calculateMarginDoll(itemCount,itemClassCount) 
	{

		var propPrice = parseFloat(eval("document.marginForm.proposedPrice" + itemCount + ".value"));
		var casePrice = parseFloat(eval("document.marginForm.caseCost" + itemCount + ".value"));
		var qty = parseFloat(eval("document.marginForm.qty" + itemCount + ".value"));
				
		if(! isNaN(qty))
		{
			var tempMarginDoll = eval("document.marginForm.marginDoll" + itemCount);
			var marDollCalc = (propPrice - casePrice) * qty;
			tempMarginDoll.value = marDollCalc;
			//display
			var marDollOutVal = outputMoney(marDollCalc);
			var marDollDiv = eval("marginDollDiv" + itemCount);
			marDollDiv.innerHTML = marDollOutVal;
			totalIemClass("marginDoll","marginDollItemClassTotal",itemClassCount,"dollar");
			totalIem("marginDollItemClassTotal","marginDollItemTotal","dollar");
					
		}
	}
	
///////////////////////////////////Margin///////////////////////////////////////
	
	//Function to calculate the margin for a given item
	function calculateMargin() 
	{
		var totalList = document.marginForm.itemTotal.value;
		var totalArray = totalList.split(",");
		var mgItmClsTot = 0;
		var margTotl = 0;
		
		for (i =0; i<totalArray.length;i++)
		{
			var classList = eval("document.marginForm.classItemTotal" + i + ".value");
			var classArray = classList.split(",");
			
			for (n =0; n<classArray.length;n++)
			{
				var revenue = parseFloat(eval("document.marginForm.revenue" + classArray[n] + ".value"));
				var totalCost = parseFloat(eval("document.marginForm.totalCost" + classArray[n] + ".value"));
				
				if(! isNaN(revenue) && ! isNaN(totalCost))
				{
					var marCalc = 0;	
					var tempMargin = eval("document.marginForm.margin" + classArray[n]);
					if (revenue != 0)
						marCalc = (revenue - totalCost) / revenue;
					tempMargin.value = marCalc;
					//display
					var marOutVal = percent(marCalc);
					var marDiv = eval("marginDiv" + classArray[n]);
					marDiv.innerHTML = marOutVal;
				}
			}
			
			var revenueItemClass = parseFloat(eval("document.marginForm.revenueItemClassTotal" + totalArray[i] + ".value"));
			var totalCostItemClass = parseFloat(eval("document.marginForm.totalCostItemClassTotal" + totalArray[i] + ".value"));
			var marginItemClass = eval("document.marginForm.marginItemClassTotal" + totalArray[i]);
			if (! isNaN(revenueItemClass))
			{
				if (revenueItemClass != 0)
					mgItmClsTot = (revenueItemClass - totalCostItemClass) / revenueItemClass;
				marginItemClass.value = mgItmClsTot;
				var mgItmClsTotDiv = eval("marginItemClassTotalDiv" + totalArray[i]);
				var mgItmClsTotOutVal = percent(mgItmClsTot);
				mgItmClsTotDiv.innerHTML = mgItmClsTotOutVal;
			}
		}
		
		var tmpRevenue = document.marginForm.revenueItemTotal.value;
		var tmpTotalCost = document.marginForm.totalCostItemTotal.value;
		var totalMargin = document.marginForm.marginItemTotal;
		if (tmpRevenue != 0)
			margTotl = (tmpRevenue - tmpTotalCost) / tmpRevenue;

		//if (! isNaN(revenueItemClass))
		//{
			totalMargin.value = margTotl;
			var mgTotOutVal = percent(margTotl);
			marginItemTotalDiv.innerHTML = mgTotOutVal;
		//}
	}

//////////////////////////////////Calculate the analysis data//////////////////////////////////////
	function calcAnalysis()
	{
		//for each cost entered perform calculations
		var totlLumSum = 0;
		var tObj = document.getElementById("enterTable");
		var tRows = tObj.rows;
		var tCols = tObj.cells.length;
		var rowLen = tRows.length;
		var grandTotl = 0;
		var classList = document.marginForm.itemTotal.value;
		var classArray = classList.split(",");
		var totlArray = new Array();
		var totlCount = 0;

		for (i=0;i<classArray.length;i++)
		{
			totlArray[i] = 0;
		}
		var grndTotlArray = new Array();
		for (i=0;i<classArray.length;i++)
		{
			grndTotlArray[i] = 0;
		}
		for (i=0;i<rowLen;i++)
		{
			inpObjCol = tRows[i].getElementsByTagName("input");
			selObjCol = tRows[i].getElementsByTagName("select");
			var inpLen = inpObjCol.length;
			var costVal = 0;
			var itmClassVal = 0;
			var itmClassCalc = 0;
			var costTotl = 0;
			var whichItmClass = "";
			
			if(tRows[i].id)
			{

				if(tRows[i].id == "calcRow" && inpLen>=2)
				{
					var rowName = tRows[i].section;
					//var inpPre1 = inpObjCol[1].name;
					//var inpPreArray1 = inpPre1.split("_");
					var inpPre = "";
					var inpPreArray = [1];

					//Loop through rows that only have a drop down
					if ((rowName == "incentive") || (rowName == "misc") || (rowName == "lumpSum"))
					{
						
						if (rowName == "incentive")
						{
							var inpPre = inpObjCol[0].name;
							var percDolDd = selObjCol[1].selectedIndex;
							costVal = inpObjCol[0].value;
						}
						else if (rowName == "misc")
						{
							var inpPre = inpObjCol[1].name;
							var percDolDd = selObjCol[0].selectedIndex;
							costVal = inpObjCol[1].value;
						}
						else
						{
							var inpPre = inpObjCol[0].name;
							costVal = inpObjCol[0].value;
						}
						
						var inpPreArray = inpPre.split("_");

						//if its a lump sum cost type then don't check for drop down or tally classes 
						if (rowName == "lumpSum")
						{
							
							costTotl = parseFloat(costVal);
							if (isNaN(costTotl))
							{
								costTotl = 0;
							}
							
							totlLumSum += costTotl;

						}	
						else
						{
							
							//If percent was selected then get revenue otherwise get freight weight
							if (percDolDd == 0)
								whichItmClass = "revenueItemClassTotal";
							else
								whichItmClass = "freightWeightItemClassTotal";
						
							for (x =0; x<classArray.length;x++)
							{
								var itmClassVal = getItemClassTotals(whichItmClass,x);
								var isChecked = eval("document.marginForm." + inpPreArray[0] + "Calc" + x + "_" + inpPreArray[1] + ".checked");
								
								if (isChecked)
								{
									if (percDolDd == 0)
										itmClassCalc = itmClassVal * costVal / 100;
									else
										itmClassCalc = itmClassVal * costVal;
								}
								
								var costCol = eval("document.marginForm." + inpPreArray[0] + "Class" + x + "_" + inpPreArray[1]);
								costCol.value = itmClassCalc; 
								var costColDiv = eval(inpPreArray[0] + "ClassDiv" + x + "_" + inpPreArray[1]);
								var outVal = outputMoney(itmClassCalc);
								costColDiv.innerHTML = outVal;
								costTotl += itmClassCalc;
								totlArray[x] += itmClassCalc;
								grndTotlArray[x] += itmClassCalc;
								itmClassCalc = 0;
							}
						}
						
						var costColTotl = eval("document.marginForm." + inpPreArray[0] + "Total_" + inpPreArray[1]);
						costColTotl.value = costTotl;
						var outTotlVal = outputMoney(costTotl);
						var costTotlDiv = eval(inpPreArray[0] + "TotalDiv_" + inpPreArray[1]);
						costTotlDiv.innerHTML = outTotlVal;
					}
				}
			}
			if (tRows[i].id)
			{
				
				if(tRows[i].id == "totRow")
				{
					var costTypeTotl = 0;
										
					for (x =0; x<classArray.length;x++)
					{
						if (totlCount == 0)
						{
							var classTotlColCell = eval("document.marginForm.incentiveCostClassTotal" + x);
							var outVal = totlArray[x];
							classTotlColCell.value = outVal;
							var formOutVal = outputMoney(outVal);
							var totlClsDiv = eval("incentiveCostClassTotalDiv" + x);
							totlClsDiv.innerHTML = formOutVal;
						}
						else if (totlCount == 1)
						{
							var classTotlColCell = eval("document.marginForm.miscCostClassTotal" + x);
							var outVal = totlArray[x];
							classTotlColCell.value = outVal;
							var formOutVal = outputMoney(outVal);
							var totlClsDiv = eval("miscCostClassTotalDiv" + x);
							totlClsDiv.innerHTML = formOutVal;
						}
						
						costTypeTotl += totlArray[x];
						totlArray[x] = 0;
					}
					if (totlCount == 0)
					{	
						document.marginForm.incentiveCostTotal.value = costTypeTotl;
						document.marginForm.incentiveCostTotalPrft.value = costTypeTotl;
						incentiveCostTotalDiv.innerHTML = outputMoney(costTypeTotl);
						incentiveCostTotalPrftDiv.innerHTML = outputMoney(costTypeTotl);
						
					}
					else if(totlCount ==1)
					{
						document.marginForm.miscCostTotal.value = costTypeTotl;
						document.marginForm.miscCostTotalPrft.value = costTypeTotl;
						miscCostTotalDiv.innerHTML = outputMoney(costTypeTotl);
						miscCostTotalPrftDiv.innerHTML = outputMoney(costTypeTotl);
					}
					else if(totlCount ==2)
					{
						document.marginForm.lumpSumCostTotal.value = totlLumSum;
						document.marginForm.lumpSumCostTotalPrft.value = totlLumSum;
						lumpSumCostTotalDiv.innerHTML = outputMoney(totlLumSum);
						lumpSumCostTotalPrftDiv.innerHTML = outputMoney(totlLumSum);
					}
					totlCount += 1;
				}
				
				if(tRows[i].id == "grndTotRow")
				{
					var grndCostTypeTotl = totlLumSum;
					for (x =0; x<classArray.length;x++)
					{
						var grndTotlColCell = eval("document.marginForm.classCostTotal" + x);
						grndTotlColCell.value = grndTotlArray[x];
						var grndTotlColCellDiv = eval("classCostTotalDiv" + x);
						grndTotlColCellDiv.innerHTML = outputMoney(grndTotlArray[x]);
						grndCostTypeTotl += grndTotlArray[x];
						grndTotlArray[x] = 0;
					}
					
					document.marginForm.costTotal.value = grndCostTypeTotl;
					costTotalDiv.innerHTML = outputMoney(grndCostTypeTotl);
				}
			}
		}
		
		calcProfAnalysis();
		return false;
	}
	
	//////////////////////////////////Calculate profit analysis//////////////////////////////////////
	function calcProfAnalysis()
	{

		var classList = document.marginForm.itemTotal.value;
		var classArray = classList.split(",");
		var netProfTotl = 0;
		var netMargTotl = 0;
		var revTotl = parseFloat(document.marginForm.revenueItemTotal.value);
		var incTotl = parseFloat(document.marginForm.incentiveCostTotal.value);
		var miscTotl = parseFloat(document.marginForm.miscCostTotal.value);
		var lmpSumTotl  = parseFloat(document.marginForm.lumpSumCostTotal.value);
		var totlCost = parseFloat(document.marginForm.totalCostItemTotal.value);
					
		for (i=0;i<classArray.length;i++)
		{
			var netMargFld = eval("document.marginForm.netMargin" + i);
			var rev = eval("document.marginForm.revenueItemClassTotal" + i + ".value");
			var totlCostsCost = eval("document.marginForm.classCostTotal" + i + ".value");
			var totlCostVal = eval("document.marginForm.totalCostItemClassTotal" + i + ".value");
			var netMargCalc = 0;
			var checkZero = rev - totlCostsCost;
			if (checkZero != 0)
				netMargCalc = (rev - totlCostsCost - totlCostVal) / (rev - totlCostsCost);
			netMargFld.value = netMargCalc;
			var netMargFldDiv = eval("netMarginDiv" + i);
			netMargFldDiv.innerHTML = percent(netMargCalc);
		}
		
		netProfTotl = revTotl - (totlCost + incTotl + miscTotl + lmpSumTotl);
		document.marginForm.totlNetProfit.value = netProfTotl;
		totlNetProfitDiv.innerHTML = outputMoney(netProfTotl);
		if (revTotl != 0)
			netMargTotl = netProfTotl / revTotl;
		document.marginForm.netMargTotl.value = netMargTotl;
		netMargTotlDiv.innerHTML = percent(netMargTotl);
		setStyle(netProfTotl);
	}
	
	////////////////////////////////////function to calculate target data///////////////////////////////////////////////////
	function calcTarget()
	{
		var tpForm = document.marginForm;
		
		var targetOn = tpForm.targType.options[tpForm.targType.selectedIndex].value;
		var targetVal = tpForm.wi_target.value;
		var netProf	= tpForm.totlNetProfit.value;
		var netMarg = tpForm.netMargTotl.value;
		var costTotl = tpForm.costTotal.value;
		var rev = tpForm.revenueItemTotal.value;
		
		//first check target values
		if (trim(targetVal) == "")
		{
			alert("Please provide a value to calculate.");
			return false;
		}
		
		if (targetVal == 0)
		{
			alert("Please provide a value greater than zero.");
			return false;
		}
		
		
		switch (targetOn)
		{
			case "wiNetMarg":
		
				var newNetProf = targetVal * (rev / 100);
				var newCostTotl = parseFloat(netProf) + parseFloat(costTotl) - newNetProf;
				propNetMargTotlDiv.innerHTML = percent(targetVal / 100);
				propTotlNetProfitDiv.innerHTML = outputMoney(newNetProf);
				propCostTotalDiv.innerHTML = outputMoney(newCostTotl);
				var diffPerc = parseFloat(targetVal) - parseFloat(netMarg);
				netMargDiffDiv.innerHTML = percent(diffPerc / 100);
				netProfDiffDiv.innerHTML = outputMoney(newNetProf - netProf);
				costTotlDiffDiv.innerHTML = outputMoney(newCostTotl - costTotl);
				break;
				
			case "wiNetProf":
			
				var newNetMarg = (targetVal / rev);
				var newCostTotl = parseFloat(netProf) + parseFloat(costTotl) - targetVal;
				propNetMargTotlDiv.innerHTML = percent(newNetMarg);
				propTotlNetProfitDiv.innerHTML = outputMoney(targetVal);
				propCostTotalDiv.innerHTML = outputMoney(newCostTotl);
				var diffPerc = parseFloat(newNetMarg * 100) - parseFloat(netMarg);
				netMargDiffDiv.innerHTML = percent(diffPerc / 100);
				netProfDiffDiv.innerHTML = outputMoney(targetVal - netProf);
				costTotlDiffDiv.innerHTML = outputMoney(newCostTotl - costTotl);
				break;
				
			case "wiTotlCost":

				var newNetProf = parseFloat(costTotl) - parseFloat(targetVal) + parseFloat(netProf);
				var newNetMarg = (newNetProf / rev);
				propNetMargTotlDiv.innerHTML = percent(newNetMarg);
				propTotlNetProfitDiv.innerHTML = outputMoney(newNetProf);
				propCostTotalDiv.innerHTML = outputMoney(targetVal);
				var diffPerc = parseFloat(newNetMarg * 100) - parseFloat(netMarg);
				netMargDiffDiv.innerHTML = percent(diffPerc / 100);
				netProfDiffDiv.innerHTML = outputMoney(newNetProf - netProf);
				costTotlDiffDiv.innerHTML = outputMoney(targetVal - costTotl);
				break;
				
			default:
		}
			
		return false;
	}