/////////isDataClear.js
function isDataClear()
{

	var thisForm = document.dataIntegrationForm;
	//thisForm.start_time.value = thisForm.start_time1.value;
	
	//thisForm.submit();
	//return true;
	
	
	///////
	var isClear = true;
	var errMsg = "";
	//////////////////////
	////Integration Option
	if(!anyChecked(thisForm.integration_Option))
	{
		isClear = false;
		//errMsg = errMsg + "You have to select an Integration Option\n";
		queueMessage("Integration Option Is A Required Field", document.all.error_Integration_Option);
	}
	else
	{		
		clearQueue(document.all.error_Integration_Option);
	}

	///////////////
	///If integration_Option is "weekly"
	///Weekdays should be selected
	if(thisForm.integration_Option(1).checked)
	{
		anySelected = false;		
		for(i=1;i<=7;i++)
		{
			eval("thisCheck = thisForm.week_day" + i + ";");
			if(thisCheck.checked)
			{
				anySelected = true;
				break;
			}
		}
		if(!anySelected)
		{
			isClear = false;
			//errMsg = errMsg + "You have to select any one or more  weekday\n";
			queueMessage("You have to select any one or more  weekday", document.all.error_Week_Days);
		}
		else
		{
			clearQueue(document.all.error_Week_Days);
		}
	}
	
	var referDate = thisDate;
	if(thisForm.enterDate.checked)
	{
		//////////////////Validate Start Date and End Date
		/////only if enterDate is checked
		
		////Validate Start Date
		var dTrue = true;
		if(!validateDate(thisForm.start_date.value))
		{
			//errMsg = errMsg + "Start Date is not correct\n";
			queueMessage("Start Date is not correct", document.all.error_Start_Date);
			dTrue = false;
			isClear = false;
		}
		else
		{
			//////Validate Start Date against todays date on the webserver
			if(days_less(makeDate(thisForm.start_date.value),thisDate) < 0)
			{
				//errMsg = errMsg + "Start Date should be greater than or equal to Current Date\n";
				queueMessage("Start Date should be greater than or equal to Current Date", document.all.error_Start_Date);
				isClear = false;
			}
			else
			{
				clearQueue(document.all.error_Start_Date);
				referDate = makeDate(thisForm.start_date.value);
			}
		}

		////Validate End Date
		if(!validateDate(thisForm.end_date.value))
		{
			//errMsg = errMsg + "End Date is not correct\n";
			queueMessage("End Date is not correct", document.all.error_End_Date);
			dTrue = false;
			isClear = false;
		}
		else
		{
			clearQueue(document.all.error_End_Date);
		}
	
		if(dTrue)
		{
			if(days_less(makeDate(thisForm.end_date.value),makeDate(thisForm.start_date.value)) < 0)
			{
				//errMsg = errMsg + "End Date should be greater than or equal to Start Date\n";
				queueMessage("End Date should be greater than or equal to Start Date", document.all.error_Start_End_Date);
				isClear = false;
			}
			else
			{
				clearQueue(document.all.error_Start_End_Date);
			}
		}
		else
		{
			clearQueue(document.all.error_Start_End_Date);
		}
	}
	else
	{
		clearQueue(document.all.error_Start_Date);
		clearQueue(document.all.error_End_Date);
		clearQueue(document.all.error_Start_End_Date);
	}
	//////////////////End thisForm.enterDate
	
	
	
	var tempTime = getMilitaryTime(thisForm.start_time.value);
	if(tempTime)
	{
		var time1 = tempTime.split(":");
		
		
		var sTime = TimeSLimit.split(":");	
		var eTime = TimeGLimit.split(":");
		var selTime = TimeSelectLimit.split(":");
		var tTime = thisTime.split(":");
		
		
		var r_date_less = days_less(referDate,thisDate);
		var timeOk = true;
		var timeMsg = "";
		var timeSlot = 1;
		
		
		
		if(r_date_less <= 0)
		{
			////referDate < thisDate
			referDate = thisDate;
			//var curTime = new Array();
			//alert(thisTime);
			//if(checkTimelessThan(selTime,sTime))
			
	
			if(checkTimelessThan(tTime,sTime))
			{
				///before 5
				///he can select time slot less than 5 and greater than 10
				timeSlot = 2;
			}
			else
			{
				////aftre 5
				///he'll have to select time slot greater than 10 only
				timeSlot = 1;
			}
			
			if(checkTimelessThan(selTime,tTime))
			{
				timeSlot = 0;
			}
		}
		else
		{
			/////selected next day
			///he can select time slot less than 5 and greater than 10
			timeSlot = 3;
		}
		
		if(timeSlot == 3)
		{
			if(!(checkTimelessThan(time1,sTime) || checkTimelessThan(eTime,time1)))
			{
				timeOk = false;
				timeMsg = "Time should be greater than " + TimeGLimit + " or less than " + TimeSLimit + ". Check AM/PM";
			}
		}
		else if(timeSlot == 2)
		{
				if(!((checkTimelessThan(time1,sTime) && checkTimelessThan(selTime,time1)) || (checkTimelessThan(eTime,time1))))
				{
					timeOk = false;
					timeMsg = "Time should be between " + TimeSelectLimit + " and " + TimeSLimit + " or greater than " + TimeGLimit + ". Check AM/PM";
				}
		}
		else if(timeSlot == 1)
		{
			if(!(checkTimelessThan(selTime,time1) && checkTimelessThan(tTime,time1)))
			{
				timeOk = false;
				timeMsg = "Time should be greater than " + TimeSelectLimit + ". Check AM/PM";
			}
		}
		else
		{
			timeOk = false;
			timeMsg = "You will have to select a day grater than " + thisDate;
		}
	}
	else
	{
		timeOk = false;
		timeMsg = "Invalid time";
	}
	//if(!(checkTimelessThan(time1,sTime) || checkTimelessThan(eTime,time1)))
	if(!timeOk)
	{
 		isClear = false;
		//errMsg = errMsg + "You have to specify a time greater than 100000 or less than 050000. Check AM/PM\n";
		//queueMessage("Time should be greater than " + TimeSelectLimit + " or less than " + TimeSLimit + ". Check AM/PM", document.all.error_Start_Time);
		queueMessage(timeMsg,document.all.error_Start_Time);
	}
	else
	{
		clearQueue(document.all.error_Start_Time);
	}
	
	/////////////////
	////check textFileNames
	var sTxtErr = "";
	var bTxtErr = false;
	var textObj = thisForm.dataIntegration_File_Names;
	var textObjTypes = thisForm.dataIntegration_File_Types;
	
	if(isNaN(textObj.length))
	{
		if(!checkValid_DI_TextFileName(textObj.value))
		{
			bTxtErr = true;
			sTxtErr = " " + textObjTypes.value + "-'" + textObj.value + "' ";
		}
	}
	else
	{
		for(i=0;i<textObj.length;i++)
		{
			if(!checkValid_DI_TextFileName(textObj[i].value))
			{
				bTxtErr = true;
				sTxtErr = sTxtErr + textObjTypes[i].value + "-'" + textObj[i].value + "'  ";
			}
		}
	}
	
	if(bTxtErr)
	{
		sTxtErr = "Text File Name(s) " + sTxtErr + " are not valid";
		isClear = false;
		queueMessage(sTxtErr,document.all.error_FileNames);
	}
	else
	{
		clearQueue(document.all.error_FileNames);
	}
		
	if(!isClear)
	{
		//alert(errMsg);
		showMessageWindow();
	}
	else
	{
		thisForm.submit();
		//showMessageWindow();
		//alert("submit");
	}
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
					if(hr >= 0 && hr <= 12 && mn >=0 && mn <=60 && sc >=0 && sc <=60)
					{
						hr = hr + ((ampm=="pm" && hr != 12)?12:0);						
						retVal = getHHMMSSTime(hr,mn,sc);
					}					
				}
				else
				{
					//////not specified ap/pm
					//if(hr <= 24 && mn <=60 && sc <=60)
					if(hr >= 0 && hr <= 24 && mn >=0 && mn <=60 && sc >=0 && sc <=60)
					{
						retVal = getHHMMSSTime(hr,mn,sc);
					}					
				}					
			}
		}
	}		
	return retVal;
}

function checkValid_DI_TextFileName(txtFName)
{
	if(/(^\w*?\.\w*)?$/.test(txtFName))
	{
    	return true;
	}
  	return false;	
}


function anyChecked(oObj)
{
	var oLen = oObj.length;
	var i;
	for(i=0;i<oLen;i++)
	{
		if(oObj[i].checked)
			return true;
	}
	return false;
}


function optionIs(optVal)
{
	var args = arguments;
	var argLen = args.length;
	switch(optVal)
	{
		case 1:
			//disableDiv("div_end_date",true);
			break;
		case 4:
			//disableDiv("div_end_date",false);
			if(argLen >1)
			{
				disableDiv("div_week_days",true,true,args[1]);
			}
			else
			{
				disableDiv("div_week_days",true,true);
			}
			break;
		case 8:
			if(argLen >1)
			{
				disableDiv("div_week_days",false,false,args[1]);
			}
			else
			{
				disableDiv("div_week_days",false,false);
			}
			break;
		default:
			
	}
}

//var sErr;


function checkTime(objTime)
{
	sErr = "";
	if(!IsValidTime(objTime.value))
	{
		alert(sErr);
		objTime.focus();
	}
}

function selectDate(thisObj){
	var thisForm = thisObj.form;
	var thisChecked = thisObj.checked;
	disableDiv('div_start_end',!thisChecked,false);
	if(!thisChecked)
	{
		thisForm.start_date.value='';
		thisForm.end_date.value='';
	}
}