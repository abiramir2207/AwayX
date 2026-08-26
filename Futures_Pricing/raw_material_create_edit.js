function distributeBlend(thisForm, prodId)
{
	var objRawMatId = eval("thisForm.Mat_Id_" + prodId);
	if(objRawMatId)
	{
		var rawMatIds = objRawMatId.value;
		var arRawMatIds = rawMatIds.split(",");
		if(arRawMatIds.length == 1 && arRawMatIds[0].length == 0)
		{
			arRawMatIds.splice(0, 1);
		}
		if(arRawMatIds.length > 0)
		{
			var i, oBlend, totalBlend = 0;
			var inividualBlend = 100.00 / arRawMatIds.length;
			inividualBlend = numericRoundDecimal(inividualBlend, 2);
			
			for(i=0;i<arRawMatIds.length;i++)
			{
				oBlend = eval("thisForm.Mat_Blend_" + prodId + "_" + arRawMatIds[i]);
				if(arRawMatIds.length-1 == i)
				{
					inividualBlend = 100 - totalBlend;
					inividualBlend = numericRoundDecimal(inividualBlend, 2);
				}
				totalBlend += inividualBlend;
				oBlend.value = inividualBlend;
			}
		}
	}
	return false;
}

function distributeVolume(sVolume, thisForm, prodId, rawMatId, requestSpan)
{
	var sBlend = "Mat_Blend_" + prodId + "_" + rawMatId;
	var sYieldLoss = "Mat_YieldLoss_" + prodId + "_" + rawMatId;
	event.returnValue = false;
	var effVol = setValue(sVolume, sBlend, sYieldLoss);
	var effVolPerDay = effVol / requestSpan;
	var totalAllocatedVolume = 0;
	var oPeriodLength = eval("thisForm.periodLength_" + prodId + "_" + rawMatId);
	var oPeriodStart, oPeriodEnd, oVolumePeriod;
	var dStart, dEnd, iPeriodSpan, currVolDist;
	if(oPeriodLength)
	{
		var volDistCount = oPeriodLength.value;
		for(var k=1;k<=volDistCount;k++)
		{
			oVolumePeriod = eval("thisForm.periodVolume_" + prodId + "_" + rawMatId + "_" + k);
			oPeriodStart = eval("thisForm.periodStartDate_" + prodId + "_" + rawMatId + "_" + k);
			oPeriodEnd = eval("thisForm.periodEndDate_" + prodId + "_" + rawMatId + "_" + k);
			
			dStart = build_Date(oPeriodStart.value);
			dEnd = build_Date(oPeriodEnd.value);
			if(dStart && dEnd)
			{
				iPeriodSpan = days_between(dEnd, dStart, true) + 1;
				if(k == volDistCount)
				{
					currVolDist = (effVol - totalAllocatedVolume);						
				}
				else
				{
					currVolDist = effVolPerDay * iPeriodSpan;
				}
				
				currVolDist = numericRoundDecimal(currVolDist, 3);
				totalAllocatedVolume += currVolDist;
				oVolumePeriod.value = currVolDist;
			}
		}
		changeEffectiveVolume(sVolume, eval("document.all.effectiveVolume_" + prodId + "_" + rawMatId), sBlend, sYieldLoss, prodId + "_" + rawMatId);
	}
}


function checkOffsetDays(thisObj, reqStartDate, reqEndDate, firstPeriodStartDate, firstPeriodEndDate, lastPeriodStartDate, lastPeriodEndDate, productIdEscaped)
{
	var addVal = parseInt(thisObj.value);
	addVal = (isNaN(addVal))?0:addVal;
	addVal = addVal * -1;
	var startDate = build_Date(reqStartDate);
	var endDate = build_Date(reqEndDate);
	
	var newFirstPeriodStartDate = dateAdd("d", startDate, addVal);
	var newLastPeriodEndDate = dateAdd("d", endDate, addVal);
	
	var dateCorrect = true;
	
	if(!datesFallInInterval(firstPeriodStartDate, firstPeriodEndDate, newFirstPeriodStartDate))
	{
		dateCorrect = false;
	}
	//alert(firstPeriodStartDate + "\n" + newFirstPeriodStartDate + "\n" + firstPeriodEndDate + "\n" + dateCorrect);
	if(!datesFallInInterval(lastPeriodStartDate, lastPeriodEndDate, newLastPeriodEndDate))
	{
		dateCorrect = false;
	}
	//alert(lastPeriodStartDate + "\n" + newLastPeriodEndDate + "\n" + lastPeriodEndDate + "\n" + dateCorrect);
	var bDisplay = "none";
	if(!dateCorrect)
	{
		bDisplay = "";
	}
	
	var errObj = eval("document.all.vol_dist_period_mismatch_" + productIdEscaped);
	if(errObj)
	{
		errObj.style.display = bDisplay;
	}
}

function datesFallInInterval(periodStartDate, periodEndDate, checkDate)
{
	var periodStart1 = build_Date(periodStartDate);
	var periodEnd1 = build_Date(periodEndDate);
	
	return (days_between(checkDate, periodStart1, true) >=0 && days_between(periodEnd1, checkDate, true) >= 0);
	
}

function setEffectiveVolume(sVolume, oDiv, sBlend, sYieldLoss)
{
	var funcExpression = "setValue('" + sVolume + "', '" + sBlend + "' ,'" + sYieldLoss + "')";
	oDiv.setExpression("innerText", funcExpression);
}

function changeEffectiveVolume(sVolume, oDiv, sBlend, sYieldLoss, sToken)
{
	var effVol = setValue(sVolume, sBlend, sYieldLoss);
	effVol = numericRoundDecimal(effVol, 3);
	oDiv.innerText = effVol;
	setVolumeDiff(sToken, effVol);
}

function setVolumeDiff(sToken, effVol)
{
	var totVolDist = getTotalVolumeDist(eval("document.all.tab_" + sToken));
	
	var volDiff = effVol - totVolDist;
	volDiff = formatToDecimalPlaces(volDiff, 3);
	//alert(effVol + "\n" + totVolDist + "\n" + volDiff + "\n" + removeExponentialFormatting(volDiff, 2));
	
	eval("document.all.volumeMismatch_" + sToken).innerText = numericRoundDecimal(volDiff, 3);
}

function getTotalVolumeDist(tabObj)
{
	var sToken = buildToken(tabObj.reqProdId, tabObj.rawMatId);
	var trObjs = tabObj.rows[0].cells;
	var i, tabObjLen = trObjs.length;
	var volObj, trObj, volVal, totVol = 0;
	
	var periodLen = eval("document.all.periodLength_" + sToken).value;
	
	for(i=1;i<=periodLen;i++)
	{
		trObj = trObjs[i-1];
		volObj = eval("document.all.periodVolume_" + sToken + "_" + i);
		volVal = parseFloat(volObj.value);
		volVal = (isNaN(volVal))?0:volVal;			
		//alert(totVol + " + " + volVal + "\n" + (totVol + volVal));
		totVol += volVal;			
	}		
	totVol = formatToDecimalPlaces(totVol, 3);
	return totVol;
	
}

function buildToken(prodId, compIndep)
{
	return (prodId + "_" + compIndep);
}

function setValue(sVolume, sBlend, sYieldLoss)
{
	var effVolume = "";
	var oBlend = eval("document.all." + sBlend);
	var oYieldLoss = eval("document.all." + sYieldLoss);
	var iBlend, iYieldLoss, iVolume;
	if(oBlend)
	{
		if(oYieldLoss)
		{
			effVolume = getEffectiveVolume(oBlend.value, oYieldLoss.value, sVolume);
		}
	}
	return effVolume;		
}


function getEffectiveVolume(iBlend, iYieldLoss, iVolume)
{
	var effVolume = "";
	iBlend = parseFloat(iBlend);
	iYieldLoss = parseFloat(iYieldLoss);
	iVolume = parseFloat(iVolume);
	
	iBlend = (isNaN(iBlend)?0:iBlend);
	iYieldLoss = (isNaN(iYieldLoss)?0:iYieldLoss);
	iVolume = (isNaN(iVolume)?0:iVolume);
	
	if(!isNaN(iBlend) && !isNaN(iYieldLoss) && !isNaN(iVolume))
	{
		effVolume = (((iVolume * iBlend) / 100) * (100+iYieldLoss)) / 100;
	}
	effVolume = numericRoundDecimal(effVolume, 3);
	return effVolume;
}


var prodIdEscapedArray = new Array();	
function validateFields(thisForm)
{
	
	var errCount = 0;
	var i, j, k, arLen1 = prodIdEscapedArray.length;
	var arLen2;
	var thisBlend, thisYield, effVolume, volDistCount, volDistObj, volDistVal, volDistValTotal, findTotal;
	var matIdListObj, matItemsObj;
	var matIdListArray;
	var errObj;
	var prodVolume, prodVolObj;
	
	for(i=0;i<arLen1;i++)
	{
		prodVolObj = eval("thisForm.productVolume_" + prodIdEscapedArray[i]);
		prodVolume = prodVolObj.value;
		matIdListObj = eval("thisForm.Mat_Id_" + prodIdEscapedArray[i]);
		
		if(matIdListObj)
		{
			matIdListArray = matIdListObj.value.split(",");				
			if(matIdListArray.length == 1 && matIdListArray[0].length == 0)
			{
				matIdListArray.splice(0, 1);
			}
			arLen2 = matIdListArray.length;
			
			/////////////any raw material is selected?
			errObj = eval("document.all.er_span_" + prodIdEscapedArray[i]);
			if(arLen2 == 0)
			{					
				queueMessage("You have to select atleast one raw material", errObj);
				errCount++;
			}
			else
			{
				clearQueue(errObj);
				
				//////check whether all the values for the raw material are proper
				findTotal = 0;
				effVolume = 0;
				thisYield = 0;
				thisBlend = 0;
				
				for(j=0;j<arLen2;j++)
				{
					//blend
					matItemsObj = eval("thisForm.Mat_Blend_" + prodIdEscapedArray[i] + "_" + matIdListArray[j]);
					
					if(matItemsObj)
					{
						thisBlend = getNumeric(matItemsObj.value, 2, 0);
						errObj = eval("document.all.er_sp_Mat_Blend_" + prodIdEscapedArray[i] + "_" + matIdListArray[j]);
						if(thisBlend.length == 0 || thisBlend == 0)
						{
							queueMessage("Blend should be greater than zero", errObj);
							errCount++;
						}
						else
						{
							clearQueue(errObj);
							findTotal += thisBlend;
						}							
					}
					
					//yield
					matItemsObj = eval("thisForm.Mat_YieldLoss_" + prodIdEscapedArray[i] + "_" + matIdListArray[j]);
					if(matItemsObj)
					{
						thisYield = getNumeric(matItemsObj.value, 2, 0);							
					}
					
					//volume distribution
					effVolume = getEffectiveVolume(thisBlend, thisYield, prodVolume);
					matItemsObj = eval("thisForm.periodLength_" + prodIdEscapedArray[i] + "_" + matIdListArray[j]);
					volDistCount = 0;
					volDistValTotal = 0;
					if(matItemsObj)
					{
						volDistCount = matItemsObj.value;
						
						for(k=1;k<=volDistCount;k++)
						{
							volDistObj = eval("thisForm.periodVolume_" + prodIdEscapedArray[i] + "_" + matIdListArray[j] + "_" + k);
							volDistVal = parseFloat(volDistObj.value);
							volDistVal = (isNaN(volDistVal)?0:volDistVal);
							volDistValTotal += volDistVal;
						}
					}					
					volDistValTotal = numericRoundDecimal(volDistValTotal, 3);
					errObj = eval("document.all.er_sp_Total_Vol_Dist_" + prodIdEscapedArray[i] + "_" + matIdListArray[j]);
					if(volDistValTotal != effVolume)
					{
						queueMessage("Total of the distributed volume (" + volDistValTotal + ") should equal the total volume (" + effVolume + ")", errObj);
						errCount++;
					}
					else
					{
						clearQueue(errObj);
					}
				}
				///Blend Total
				findTotal = numericRoundDecimal(findTotal, 2);
				errObj = eval("document.all.er_sp_Mat_Blend_" + prodIdEscapedArray[i]);
				if(findTotal != 100)
				{
					queueMessage("Blend should add up to 100% (Current total = " + findTotal + "% )", errObj);
					errCount++;
				}
				else
				{
					clearQueue(errObj);
				}
				
			}
		}
	}
	if(errCount)
	{
		showMessageWindow();
		return false;
	}
	else
	{
		return true;
	}
	
}