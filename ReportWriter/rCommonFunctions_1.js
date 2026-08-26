//rCommonFunctions.js


function saveReport(thisForm,rType)
{	
	//thisForm.action = reportSaveActionPage;
	
	//thisForm.submit();
	//return true;

	var allClear = true;
	eval("allClear = " + verifyValuesFunction + "(thisForm,rType,false);");
	//allClear = verifyData(thisForm,rType,false);
	///////////////////////////////////////////
	////check report Name
	if(isSpace(thisForm.rName.value))
	{
		queueMessage("Report Name is a required field", document.all.error_ReportName);
		allClear = false;
	}
	/*
	else if(!(/^\w+$/.test(thisForm.rName.value)))
	{		
		queueMessage("Report Name is not valid", document.all.error_ReportName);
		allClear = false;
	}
	*/
	else
	{
		clearQueue(document.all.error_ReportName);
	}
	//////////////////////////////////////////
	
	//////////////////////////////////////////////////////////////
	////check start time and end time
	var dTrue = true;
	var daysDiff = 0;
	//////////////check start time
	
	if(!validateDate(thisForm.rStartDate.value))
	{
		queueMessage("Start Date is not correct", document.all.error_Start_Date);
		dTrue = false;
		allClear = false;
	}
	else if((daysDiff=days_less(makeDate(thisForm.rStartDate.value),thisDate)) < 0)
	{
		queueMessage("Start Date should be greater than or equal to Current Date", document.all.error_Start_Date);
		allClear = false;
	}
	else
	{
		clearQueue(document.all.error_Start_Date);
	}
	
	
	if(thisForm.rInterval.selectedIndex == 0)
	{
		dTrue = false;
	}
	else if(!validateDate(thisForm.rEndDate.value))
	{
		queueMessage("End Date is not correct", document.all.error_End_Date);
		dTrue = false;
		allClear = false;
	}
	
	
	
	if(dTrue)
	{
		if(days_less(makeDate(thisForm.rEndDate.value),makeDate(thisForm.rStartDate.value)) < 0)
		{
			queueMessage("End Date should be greater than or equal to Start Date", document.all.error_End_Date);
			allClear = false;
		}
		else
		{
			clearQueue(document.all.error_End_Date);
		}
	}
	//////////////end check start time
	
	////////////////////////////////////////////////
	//////check start time
	//rStartTime
	
	if(daysDiff == 0)
	{
		var selectedTime = getMilitaryTime(thisForm.rStartTime.value);
		var aSelectedTime = selectedTime.split(":");
		var aThisTime = thisTime.split(":");
		if(checkTimelessThan(aThisTime,aSelectedTime))
		{			
			clearQueue(document.all.error_Start_Time);
		}
		else
		{
			queueMessage("Time should be greater than should be greater than " + thisTime + " if you select Start Date as " + thisDate, document.all.error_Start_Time);
			allClear = false;
		}
	}
	
	/////////////////////////////////////////////////
	
	
	////////////////////////////////////////////
	///check email address
	var validEmailAdd = checkMultipleEmail(thisForm.rEmailAddress);
	if(validEmailAdd!=true)
	{
		queueMessage("Invalid Email Address '" + validEmailAdd + "'", document.all.error_Email_Address);
		allClear = false;
	}
	else if(thisForm.rEmailAddress.value.length >= 3000)
	{
		queueMessage("Email Address exceeds available size limit", document.all.error_Email_Address);
		allClear = false;
	}
	else
	{
		clearQueue(document.all.error_Email_Address);
	}
	////////////////////////////////////////////
	
	//////////////////////////////////////////////////////////////
	
	if(allClear)
	{
		var oldAction = thisForm.action;
		thisForm.action = reportSaveActionPage;
		thisForm.submit();		
		thisForm.action = oldAction;
		return;
	}
	else
	{
		showMessageWindow();				
	}
	//return allClear;
}

function verifyData(thisForm)
{
	var allClear = true;
	/////////////////////////////////
	///check for any column headers selected
	
	/*
	var hObj = thisForm.rColumnHeaderID;
	var hLen = hObj.length;
	var anyChecked = false;
	for(i=0;i<hLen;i++)
	{
		if(hObj[i].checked)
		{
			anyChecked=true;
			break;
		}
	}
	
	if(anyChecked)
	{
		clearQueue(eval("document.all." + arguments[1] + "error_ColumnHeader"));
	}
	else
	{
		queueMessage("No column header is seleted.", eval("document.all." + arguments[1] + "error_ColumnHeader"));
		allClear = false;
	}
	*/
	
	//////////////////Validate Geo Filters
	/*
	var rFilterLen = thisForm.rFilter.length;
	var bErr=false;
	var sErr= "";
	
	for(i=0;i<rFilterLen;i++)
	{
		if(thisForm.rFilter[i].checked)
		{
			switch(i)
			{
				case 0:
					if(thisForm.rZones.value == "")
					{
						bErr = true;
						sErr = "Invalid Zone Selection";
					}
					break;
				case 1:
					if(thisForm.rRegions.value == "")
					{
						bErr = true;
						sErr = "Invalid Region Selection";
					}
					break;
				case 2:
					if(thisForm.rBrokers.value == "")
					{
						bErr = true;
						sErr = "Invalid Broker Selection";
					}
					break;					
			}
		}
		if(bErr)
		{
			queueMessage(sErr, document.all.error_rFilter);
			allClear = false;
			break;
		}
	}
	
	if(!bErr)
	{
		clearQueue(document.all.error_rFilter);
	}
	*/
	//////////////////End Validate Geo Filters
	
	
	
	///////////////Validate Broker Filter
	
	if(thisForm.rFilter)
	{
		var rFilterLen = thisForm.rFilter.length;
		var bErr=false;
		var sErr= "";
		
		for(i=0;i<rFilterLen;i++)
		{
			if(thisForm.rFilter[i].checked)
			{
				switch(i)
				{
					case 0:
						if(thisForm.rZones.value == "")
						{
							bErr = true;
							sErr = "Invalid Zone Selection";
						}
						break;
					case 1:
						if(thisForm.rRegions.value == "")
						{
							bErr = true;
							sErr = "Invalid Region Selection";
						}
						break;
					case 2:
						if(thisForm.rBrokers.value == "")
						{
							bErr = true;
							sErr = "Invalid Broker Selection";
						}
						break;					
				}
			}
			if(bErr)
			{
				queueMessage(sErr, document.all.error_rFilter);
				allClear = false;
				break;
			}
		}
		
		if(!bErr)
		{
			clearQueue(document.all.error_rFilter);
		}
	}
	
	//////////////////Validate Item Filters
	
	if(thisForm.rFilterItems)
	{
		var rFilterLen = thisForm.rFilterItems.length;
		var bErr=false;
		var sErr= "";
		
		for(i=0;i<rFilterLen;i++)
		{
			if(thisForm.rFilterItems[i].checked)
			{
				if(thisForm.id == "rProgramSummaryForm")
				{
					switch(i)
					{
						case 0:
							if(thisForm.rFamilys.value == "")
							{
								bErr = true;
								sErr = "Invalid Family Selection";
							}
							break;
						case 1:
							if(thisForm.rBuyingGroups.value == "")
							{
								bErr = true;
								sErr = "Invalid Buying Group Selection";
							}
							break;
						case 2:
							if(thisForm.rDistributors.value == "")
							{
								bErr = true;
								sErr = "Invalid Distributor Selection";
							}
							break;
					}
				}
				else if(thisForm.id == "pProductSummaryForm")
				{
					switch(i)
					{
						case 0:
							if(thisForm.rQBrands.value == "")
							{
								bErr = true;
								sErr = "Invalid Q Brand Selection";
							}
							break;
						case 1:
							if(thisForm.rTypeGroups.value == "")
							{
								bErr = true;
								sErr = "Invalid Type Group Selection";
							}
							break;						
						case 2:
							if(thisForm.rTypeCodes.value == "")
							{
								bErr = true;
								sErr = "Invalid Type Code Selection";
							}
							break;
						case 3:
							if(thisForm.rBrands.value == "")
							{
								bErr = true;
								sErr = "Invalid Brand Selection";
							}
							break;
						case 4:
							if(thisForm.rProductGroups.value == "")
							{
								bErr = true;
								sErr = "Invalid Product Group Selection";
							}
							break;
					}
				}
			}
			if(bErr)
			{
				queueMessage(sErr, document.all.error_rFilterItems);
				allClear = false;
				break;
			}
		}
		
		if(!bErr)
		{
			clearQueue(document.all.error_rFilterItems);
		}
	}
	//////////////////End Validate Item Filters
	
	///////////////// Validate Start and End Dates
	var bErr=false;
	var sErr= "";
	if(thisForm.rOutputStartDate.value.length > 0 && thisForm.rOutputStartDateOperator.value == "")
	{
		bErr = true;
		sErr = sErr + "Select a comparison operator for start date. ";
	}
	if(thisForm.rOutputEndDate.value.length > 0 && thisForm.rOutputEndDateOperator.value == "")
	{
		bErr = true;
		sErr = sErr + "Select a comparison operator for end date. ";
	}
	
	if(!bErr && (thisForm.rOutputStartDate.value.length > 0 && thisForm.rOutputEndDate.value.length > 0))
	{
		if(!validateDate(thisForm.rOutputStartDate.value))
		{
			bErr = true;
			sErr = "Enter valid Start Date";
		}
		else if(!validateDate(thisForm.rOutputEndDate.value))
		{
			bErr = true;
			sErr = "Enter valid End Date";
		}
		else if((daysDiff=days_less(makeDate(thisForm.rOutputEndDate.value), makeDate(thisForm.rOutputStartDate.value))) < 0)
		{
			sErr = "Start Date should be greater than or equal to Current Date";			
			bErr = true;
		}
	}
	
	if(bErr)
	{
		queueMessage(sErr, document.all.err_Start_Date_End_date);
		allClear = false;
	}
	else
	{
		clearQueue(document.all.err_Start_Date_End_date);
	}
	///////////////// End Validate Start and End Dates
	
	//////////////////////////////////
	if(!((arguments.length > 2) && (!arguments[2])))
	{
		if(allClear)
		{			
			var oldTarget = thisForm.target;
			if(thisForm.rReportOutputType[0].checked)
			{
				thisForm.target = thisForm.rReportType.value;
				try
				{
					NewWindow('', thisForm.rReportType.value, '800','550','Yes', 'Yes');
				}
				catch(e)
				{
				}
			}
			else
			{
				if(!confirm("This may take some time. Do you want to continue?"))
				{
					return;
				}
			}
			thisForm.submit();
			thisForm.target = oldTarget;			
			return;
		}
		else
		{		
			showMessageWindow();
			return;
		}
	}
	return allClear;
}


function checkEmail(email) {
  if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(email)){
    return (true)
  }
  return (false)
}


function checkMultipleEmail(emailTextBox) 
{
  var separator = ";";
  var emails2 = emailTextBox.value.split(separator);
  var anyEmail = false;
	for(var i=0; i<emails2.length; i++) 
	{
		emails2[i] = emails2[i].replace(/(^ *(\r\n)* *)|( *(\r\n)* *$)/g, ""); //trim spaces and enters
		
		tempEmail = checkEmail(emails2[i])
		if(!tempEmail) 
		{
		return emails2[i];
		} 		
	}
	return true;
 }
 

function disableDiv(divName,bDis,bHide)
{
	oDiv = document.all.item(divName);	
	oDiv.disabled = bDis;
	//oDiv.onmousedown=new Function ("return false");
	var i,itemLen = oDiv.all.length;
	for(i=0;i<itemLen;i++)
	{
		oDiv.all[i].disabled = bDis;
		if((oDiv.all[i].tagName == "SELECT") && bDis)
		{
			oDiv.all[i].selectedIndex = 0;
			oDiv.all[i].style.backgroundColor='cccccc';
		}
		else if((oDiv.all[i].tagName == "SELECT") && !bDis)
		{
			if(oDiv.all[i].options.length > 0 && oDiv.all[i].selectedIndex <= 0) oDiv.all[i].selectedIndex = 1;
		}
		if((oDiv.all[i].tagName == "SELECT") && !bDis)
		{
			oDiv.all[i].style.backgroundColor='ffffff';
		}
		
		if(oDiv.all[i].tagName == "IFRAME")
		{
			var j, iframeObjs;
			iframeObjs = oDiv.all[i].document.all;
			eval("window." + oDiv.all[i].name + ".disableAll(" + bDis + ");");
		}		
	}
	var args = arguments;
	var argLen = args.length;
	if(argLen <3)
	{
		return;
	}
	if(args[2])
	{
		oDiv.style.display = "none";
	}
	else
	{
		oDiv.style.display = "";		
	}
	if(argLen <4)
	{
		return;
	}
	var parObj = document.all.item(args[3]);
	
	if(args[2])
	{
		parObj.style.display = "none";
	}
	else
	{
		parObj.style.display = "";
	}
}

function setReportFilter(fVal,rType)
{
	var divName = rType + "FilterDIV";
	switch(fVal)
	{
		case 'zone':			
			disableDiv(divName+"zone",false,false);
			disableDiv(divName+"region",true,false);
			disableDiv(divName+"broker",true,false);
			break;		
		case 'region':
			disableDiv(divName+"zone",true,false);
			disableDiv(divName+"region",false,false);
			disableDiv(divName+"broker",true,false);
			break;
		case 'broker':
			disableDiv(divName+"zone",true,false);
			disableDiv(divName+"region",true,false);
			disableDiv(divName+"broker",false,false);
			break;
		case 'none':
			disableDiv(divName+"zone",true,false);
			disableDiv(divName+"region",true,false);
			disableDiv(divName+"broker",true,false);
			break;
		default:			
	}
	
	if(document.rProgramSummaryForm)
	{
		var fixedColumLen = 0;
		//if(fVal != 'none')
		var FilterItemslength = document.rProgramSummaryForm.rFilterItems.length;
		
		if((fVal != 'none') || (!document.rProgramSummaryForm.rFilterItems[FilterItemslength-1].checked))
		{
			for(i=fixedColumLen;i<document.rProgramSummaryForm.rColumnHeaderID.length;i++)
			{
				document.rProgramSummaryForm.rColumnHeaderID[i].checked = false;
				document.rProgramSummaryForm.rColumnHeaderID[i].disabled= true;
			}	
		}
		else
		{
			for(i=fixedColumLen;i<document.rProgramSummaryForm.rColumnHeaderID.length;i++)
			{
				document.rProgramSummaryForm.rColumnHeaderID[i].disabled= false;
			}	
		}
	}
	
}

function setReportFilterItem(fVal)
{
	var divName = "pFilterItemDIV";
	switch(fVal)
	{
		case 'typegroup':			
			disableDiv(divName+"typegroup",false,false);
			disableDiv(divName+"qbrand",true,false);
			disableDiv(divName+"typecode",true,false);
			disableDiv(divName+"brand",true,false);
			disableDiv(divName+"productGroup",true,false);
			disableDiv(divName+"product",true,false);
			break;		
		case 'qbrand':
			disableDiv(divName+"typegroup",true,false);
			disableDiv(divName+"qbrand",false,false);
			disableDiv(divName+"typecode",true,false);
			disableDiv(divName+"brand",true,false);
			disableDiv(divName+"productGroup",true,false);
			disableDiv(divName+"product",true,false);
			break;
		case 'typecode':
			disableDiv(divName+"typegroup",true,false);
			disableDiv(divName+"qbrand",true,false);
			disableDiv(divName+"typecode",false,false);
			disableDiv(divName+"brand",true,false);
			disableDiv(divName+"productGroup",true,false);
			disableDiv(divName+"product",true,false);
			break;
		case 'brand':
			disableDiv(divName+"typegroup",true,false);
			disableDiv(divName+"qbrand",true,false);
			disableDiv(divName+"typecode",true,false);
			disableDiv(divName+"brand",false,false);
			disableDiv(divName+"productGroup",true,false);
			disableDiv(divName+"product",true,false);
			break;
		case 'productGroup':
			disableDiv(divName+"typegroup",true,false);
			disableDiv(divName+"qbrand",true,false);
			disableDiv(divName+"typecode",true,false);
			disableDiv(divName+"brand",true,false);
			disableDiv(divName+"productGroup",false,false);
			disableDiv(divName+"product",true,false);
			break;
		case 'product':
			disableDiv(divName+"typegroup",true,false);
			disableDiv(divName+"qbrand",true,false);
			disableDiv(divName+"typecode",true,false);
			disableDiv(divName+"brand",true,false);
			disableDiv(divName+"productGroup",true,false);
			disableDiv(divName+"product",false,false);
			break;
		case 'none':
			disableDiv(divName+"typegroup",true,false);
			disableDiv(divName+"qbrand",true,false);
			disableDiv(divName+"typecode",true,false);
			disableDiv(divName+"brand",true,false);
			disableDiv(divName+"productGroup",true,false);
			disableDiv(divName+"product",true,false);			
			break;
		default:			
	}	
	var fixedColumLen = 0;
	if(fVal == 'none')
	{
		for(i=fixedColumLen;i<document.pProductSummaryForm.rColumnHeaderID.length;i++)
		{
			document.pProductSummaryForm.rColumnHeaderID[i].checked = false;
			document.pProductSummaryForm.rColumnHeaderID[i].disabled= true;
		}	
	}
	else
	{
		for(i=fixedColumLen;i<document.pProductSummaryForm.rColumnHeaderID.length;i++)
		{
			document.pProductSummaryForm.rColumnHeaderID[i].disabled= false;
		}	
	}
	
}

function setReportFilterCustomer(fVal)
{
	var divName = "rFilterItemDIV";
	switch(fVal)
	{
		case 'family':			
			disableDiv(divName+"family",false,false);
			disableDiv(divName+"buyinggroup",true,false);
			disableDiv(divName+"distributor",true,false);
			break;		
		case 'buyinggroup':
			disableDiv(divName+"family",true,false);
			disableDiv(divName+"buyinggroup",false,false);
			disableDiv(divName+"distributor",true,false);
			break;
		case 'distributor':
			disableDiv(divName+"family",true,false);
			disableDiv(divName+"buyinggroup",true,false);
			disableDiv(divName+"distributor",false,false);
			break;
		case 'none':
			disableDiv(divName+"family",true,false);
			disableDiv(divName+"buyinggroup",true,false);
			disableDiv(divName+"distributor",true,false);
			break;
		default:			
	}
	if(document.rProgramSummaryForm)
	{
		var fixedColumLen = 0;
		var FilterItemslength = document.rProgramSummaryForm.rFilter.length;
		
		
		//if(fVal != 'none')
		if((fVal != 'none') || (!document.rProgramSummaryForm.rFilter[FilterItemslength-1].checked))
		{
			for(i=fixedColumLen;i<document.rProgramSummaryForm.rColumnHeaderID.length;i++)
			{
				document.rProgramSummaryForm.rColumnHeaderID[i].checked = false;
				document.rProgramSummaryForm.rColumnHeaderID[i].disabled= true;
			}	
		}
		else
		{
			for(i=fixedColumLen;i<document.rProgramSummaryForm.rColumnHeaderID.length;i++)
			{
				document.rProgramSummaryForm.rColumnHeaderID[i].disabled= false;
			}	
		}
	}
	
}

function disableProgramFilterItems()
{
	if(document.rProgramSummaryForm)
	{
		var rFilterVal = 'zone';	
		for(i=0;i<4;i++)
		{
			rFilterVal = (document.rProgramSummaryForm.rFilter[i].checked)?document.rProgramSummaryForm.rFilter[i].value:rFilterVal;
		}
		setReportFilter(rFilterVal,'r');
		
		var pFilterItemVal = 'family';
		for(i=0;i<4;i++)
		{
			pFilterItemVal = (document.rProgramSummaryForm.rFilterItems[i].checked)?(document.rProgramSummaryForm.rFilterItems[i].value):pFilterItemVal;
		}
		setReportFilterCustomer(pFilterItemVal);
	}
}

function disableProductFilterItems()
{
	if(document.pProductSummaryForm)
	{
		/*
		var pFilterVal = 'zone';
		for(i=0;i<4;i++)
		{
			pFilterVal = (document.pProductSummaryForm.rFilter[i].checked)?(document.pProductSummaryForm.rFilter[i].value):pFilterVal;
		}
			
		setReportFilter(pFilterVal,'p');
		*/
		
		var pFilterItemVal = 'typegroup';
		for(i=0;i<7;i++)
		{
			pFilterItemVal = (document.pProductSummaryForm.rFilterItems[i].checked)?(document.pProductSummaryForm.rFilterItems[i].value):pFilterItemVal;
		}
		setReportFilterItem(pFilterItemVal);
	}
}


function intervalSelection(oSel)
{
	if(oSel)
	{
		if(oSel.selectedIndex == 0)
		{
			disableDiv("divEndDate",true,false);
		}
		else
		{
			disableDiv("divEndDate",false,false);
		}
	}
}

function checkTimelessThan(sTime,gTime)
{
	var tLen = sTime.length;
	if(sTime[0] < gTime[0])
	{
		return true;
	}
	else if(sTime[0] == gTime[0])
	{
		if(sTime[1] < gTime[1])
		{
			return true;		
		}
		else if(sTime[1] == gTime[1])
		{
			if(sTime[2] <= gTime[2])
			{
				return true;
			}
		}
	}
	return false;
}

function isSpace(sStr)
{
	var re = /^[\s\t]*$/ig;
	if (re.test(sStr))
		return true;
	else
		return false;
}

function days_less(date1, date2) {

    // The number of milliseconds in one day
    var ONE_DAY = 1000 * 60 * 60 * 24

    // Convert both dates to milliseconds
    var date1_ms = date1.getTime()
    var date2_ms = date2.getTime()

    // Calculate the difference in milliseconds
    //var difference_ms = Math.abs(date1_ms - date2_ms)
	var difference_ms = date1_ms - date2_ms;
    
    // Convert back to days and return
    return Math.round(difference_ms/ONE_DAY)

}
function makeDate(dVal)
{
	var nDate = new Date();
	var ar_s_date = dVal.split("/");	
	if(ar_s_date.length >= 3)
	{
		nDate = new Date(ar_s_date[2],ar_s_date[0]-1,ar_s_date[1]);
	}	
	return nDate;
}


function getMilitaryTime(sTime)
{
	var retVal = false;
	var spTime = sTime.split(":");
	if(spTime.length >= 3)
	{
		var hr = parseInt(spTime[0],10);
		//if(hr.toString() == spTime[0])
		if(makeFixedDigits(2,hr.toString(),"00") == makeFixedDigits(2,spTime[0],"00"))
		{
			var mn = parseInt(spTime[1],10);			
			if(makeFixedDigits(2,mn.toString(),"00") == makeFixedDigits(2,spTime[1],"00"))
			{
				var sc = parseInt(spTime[2],10);
				var ampm = spTime[2].substr(makeFixedDigits(2,sc.toString(),"00").length);
				ampm = ampm.replace(/(^\s*)|(\s*$)/g, "");
				ampm = ampm.toLowerCase();
				if(/^[\s\t]*?[aApP][mM][\s\t]*?$/.test(ampm))
				{
					//////specified ap/pm
					if(hr >= 0 && hr <= 12 && mn >=0 && mn <60 && sc >=0 && sc <60)
					{
						hr = hr + (ampm=="am"?0:12);						
						retVal = getHHMMSSTime(hr,mn,sc);
					}					
				}
				else
				{
					//////not specified ap/pm
					//if(hr <= 24 && mn <=60 && sc <=60)
					if(hr >= 0 && hr < 24 && mn >=0 && mn <60 && sc >=0 && sc <60)
					{
						retVal = getHHMMSSTime(hr,mn,sc);
					}					
				}					
			}
		}
	}		
	return retVal;
}

function makeFixedDigits(dig,val,padStr)
{
	var retVal = padStr + val;
	return (retVal.substr(retVal.length-dig));	
}

function getHHMMSSTime()
{
	var retVal = "";
	var tmp;
	var args = arguments;
	for(i=0;i<args.length;i++)
	{
		//tmp = "0" + args[i];
		//retVal = retVal + tmp.substring(tmp.length-2,tmp.length) + ":";
		retVal = retVal + makeFixedDigits(2,args[i],"00") + ":";
	}
	return (retVal.substring(0,retVal.length-1));
}

function addToEmailAddress(sObj,fObj)
{	
	var emailObj = fObj.rEmailAddress;
	/*if(sObj.value == -1)
	{
		for(i=2;i<sObj.options.length;i++)
		{
			addThisEmail(emailObj,sObj.options[i].value,false);
		}
	}*/
	//if(sObj.value > 0)
	{
		addThisEmail(emailObj,sObj.value,true);
	}
}

function addThisEmail(emailObj,val,bAlert)
{
	var eVal = emailObj.value;
	var re = new RegExp(val,"ig");
	
  	if(re.test(eVal))
	{
		if(bAlert)
		{
			alert(val + " already exist");
		}
	}
	else
	{  
		if(eVal.length > 0)
		{
			emailObj.value = emailObj.value + ";" + val;
		}
		else
		{
			emailObj.value = val;
		}
	}
}

/*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Functions added from 9/30/02 onwards for Product/Program Margin Ananysis Report
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*/

function disableProductMarginFilterItems()
{
	
	var thisForm = document.ProductMarginForm;
	if(thisForm)
	{
		var rFilterVal = 'qbrand';	
		for(i=0;i<4;i++)
		{
			rFilterVal = (thisForm.rFilterItem[i].checked)?thisForm.rFilterItem[i].value:rFilterVal;
		}
		if(rFilterVal == 'qbrand')
		{
			thisForm.rFilterItem[0].checked = true;
		}
		setProductMarginItemFilter(rFilterVal);
		
		var pFilterItemVal = 'family';
		for(i=0;i<3;i++)
		{
			pFilterItemVal = (thisForm.rFilterCust[i].checked)?(thisForm.rFilterCust[i].value):pFilterItemVal;
		}
		if(pFilterItemVal == 'family')
		{
			thisForm.rFilterCust[0].checked = true;
		}
		setProductMarginCustomerFilter(pFilterItemVal);
	}
	
}

function setProductMarginItemFilter(fVal)
{
		var divName = "mpdtFilterItemDIV";
	switch(fVal)
	{
		case 'typegroup':			
			disableDiv(divName+"typegroup",false,false);
			disableDiv(divName+"qbrand",true,false);
			disableDiv(divName+"typecode",true,false);
			disableDiv(divName+"brand",true,false);
			break;		
		case 'qbrand':
			disableDiv(divName+"typegroup",true,false);
			disableDiv(divName+"qbrand",false,false);
			disableDiv(divName+"typecode",true,false);
			disableDiv(divName+"brand",true,false);
			break;
		case 'typecode':
			disableDiv(divName+"typegroup",true,false);
			disableDiv(divName+"qbrand",true,false);
			disableDiv(divName+"typecode",false,false);
			disableDiv(divName+"brand",true,false);
			break;
		case 'brand':
			disableDiv(divName+"typegroup",true,false);
			disableDiv(divName+"qbrand",true,false);
			disableDiv(divName+"typecode",true,false);
			disableDiv(divName+"brand",false,false);
			break;
		default:			
	}
}

function setProductMarginCustomerFilter(fVal)
{
	var divName = "mpdtFilterCustDIV";
	switch(fVal)
	{
		case 'family':			
			disableDiv(divName+"family",false,false);
			disableDiv(divName+"buyinggroup",true,false);
			disableDiv(divName+"distributor",true,false);
			break;		
		case 'buyinggroup':
			disableDiv(divName+"family",true,false);
			disableDiv(divName+"buyinggroup",false,false);
			disableDiv(divName+"distributor",true,false);
			break;
		case 'distributor':
			disableDiv(divName+"family",true,false);
			disableDiv(divName+"buyinggroup",true,false);
			disableDiv(divName+"distributor",false,false);
			break;
		default:			
	}
}


function verifyMarginReportValuesAndSendEmail(thisForm,rType)
{	
	var allClear = true;
	allClear = verifyMarginReportValues(thisForm,rType,false);
	if(allClear)
	{
		var oldAction = thisForm.action;
		thisForm.action = reportEmailActionPage;
		thisForm.submit();		
		thisForm.action = oldAction;
		return;		
	}
	else
	{
		showMessageWindow();
	}
}
function verifyMarginReportValues(thisForm)
{
	var allClear = true;
	
	//////////////////Validate Item Filters
	if(thisForm.rFilterItem)
	{
		var rFilterLen = thisForm.rFilterItem.length;
		var bErr=false;
		var sErr= "";

		for(i=0;i<rFilterLen;i++)
		{
			if(thisForm.rFilterItem[i].checked)
			{
				/*
					switch(i)
					{
						case 0:
							if(thisForm.rFamilys.value == "")
							{
								bErr = true;
								sErr = "Invalid Family Selection";
							}
							break;
						case 1:
							if(thisForm.rBuyingGroups.value == "")
							{
								bErr = true;
								sErr = "Invalid Buying Group Selection";
							}
							break;
						case 2:
							if(thisForm.rDistributors.value == "")
							{
								bErr = true;
								sErr = "Invalid Distributor Selection";
							}
							break;
					}
					*/
				switch(i)
				{
					case 0:
						if(thisForm.rQBrands.value == "")
						{
							bErr = true;
							sErr = "Invalid Q Brand Selection";
						}
						break;
					case 1:
						if(thisForm.rTypeGroups.value == "")
						{
							bErr = true;
							sErr = "Invalid Type Group Selection";
						}
						break;						
					case 2:
						if(thisForm.rTypeCodes.value == "")
						{
							bErr = true;
							sErr = "Invalid Type Code Selection";
						}
						break;
					case 3:
						if(thisForm.rBrands.value == "")
						{
							bErr = true;
							sErr = "Invalid Brand Selection";
						}
						break;
					case 4:
						if(thisForm.rProductGroups.value == "")
						{
							bErr = true;
							sErr = "Invalid Product Group Selection";
						}
						break;					
				}
			}
			if(bErr)
			{
				queueMessage(sErr, document.all.error_rFilterItem);
				allClear = false;
				break;
			}
		}
		
		if(!bErr)
		{
			clearQueue(document.all.error_rFilterItem);
		}
	}
	//////////////////End Validate Item Filters
	
	//////////////////Validate Customer Filters
	if(thisForm.rFilterCust)
	{
		rFilterLen = thisForm.rFilterCust.length;
		bErr=false;
		sErr= "";

		for(i=0;i<rFilterLen;i++)
		{
			if(thisForm.rFilterCust[i].checked)
			{
				switch(i)
				{
					case 0:
						if(thisForm.rFamilys.value == "")
						{
							bErr = true;
							sErr = "Invalid Family Selection";
						}
						break;
					case 1:
						if(thisForm.rBuyingGroups.value == "")
						{
							bErr = true;
							sErr = "Invalid Buying Group Selection";
						}
						break;
					case 2:
						if(thisForm.rDistributors.value == "")
						{
							bErr = true;
							sErr = "Invalid Distributor Selection";
						}
						break;
				}				
			}
			if(bErr)
			{
				queueMessage(sErr, document.all.error_rFilterCust);
				allClear = false;
				break;
			}
		}
		
		if(!bErr)
		{
			clearQueue(document.all.error_rFilterCust);
		}
	}
	//////////////////End Validate Customer Filters
	
	//////////////////////////////////
	
	if(!((arguments.length > 2) && (!arguments[2])))
	{
		if(allClear)
		{			
			var oldTarget = thisForm.target;
			if(thisForm.rReportOutputType[0].checked)
			{
				thisForm.target = thisForm.rReportType.value;
				try
				{
					NewWindow('', thisForm.rReportType.value, '800','550','Yes', 'Yes');
				}
				catch(e)
				{
				}
			}
			/*else
			{
				alert("This may take some time. Please Wait.");
			}*/
			thisForm.submit();
			thisForm.target = oldTarget;			
			return;
		}
		else
		{		
			showMessageWindow();
			return;
		}
	}
	return allClear;
}
function marginOptionSelected(thisObj)	
{
	if(thisObj)
	{
	switch(thisObj.value)
	{
		case 'ALL':			
			disableDiv("divMarginValue1",true,true);
			break;
		case 'GT':			
		case 'LT':
			disableDiv("divMarginValue1",false,false);
			disableDiv("divMarginValue2",true,true);
			break;
		case 'BTW':
			disableDiv("divMarginValue1",false,false);
			disableDiv("divMarginValue2",false,false);
			break;
	}
	}	
}

function threeDecimalPlaces(textObject)
{
	if(event.type == "keyup") {
		
		if(textObject.value.indexOf(".") != -1) {
			if(textObject.value.length - textObject.value.indexOf(".") >= 4) {
				var validNumber = new NumberFormat();
				validNumber.setCommas(false);
				validNumber.setCurrency(false);
				validNumber.setPlaces(3);		
				validNumber.setNumber(textObject.value);
				textObject.value = validNumber.toFormatted();
			}
		}
	}
	
	if(event.type == "blur") {
		var validNumber = new NumberFormat();
		validNumber.setCommas(false);
		validNumber.setCurrency(false);
		validNumber.setPlaces(3);		
		validNumber.setNumber(textObject.value);
		textObject.value = validNumber.toFormatted();			
	}
}

/*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
End Functions added from 9/30/02 onwards for Product/Program Margin Ananysis Report
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*/
