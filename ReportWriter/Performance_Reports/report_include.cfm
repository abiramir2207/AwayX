<CF_MessageWindow>

<cfscript>

timeIncr=16;
thisDate = Now();
thisTimeFull=DateAdd('n',timeIncr,Now());
thisTime = timeformat(DateAdd('n',timeIncr,Now()), 'HH:mm:ss');

function isDateValid(dateVal)
{
	dateValid = false;
	arDate = ListToArray(dateVal,"/");
	if(ArrayLen(arDate) GTE 3)
	{		
		
		if((1000 LTE Val(arDate[3]) LTE 9999) AND (1 LTE Val(arDate[1]) LTE 12) AND (1 LTE Val(arDate[2]) LTE 31))
		{			
			dateValid = IsDate(CreateDate(Val(arDate[3]), Val(arDate[1]), Val(arDate[2])));
			//dateValid = true;
		}
		
	}
	return dateValid;
}

	function getMilitaryTime(sTime)
{
	retVal = "";
	spTime = ListToArray(sTime,":");
	if(ArrayLen(spTime) GTE 3)
	{
		hr = Val(spTime[1]);
		if(makeFixedDigits(2,hr,"00") EQ spTime[1])
		{
			mn = Val(spTime[2]);
			if(makeFixedDigits(2,mn,"00") EQ spTime[2])
			{
				sc = Val(spTime[3]);
				ampm = Mid(spTime[3],Len(sc)+2,Len(spTime[3])-Len(sc)+1);
				ampm = REReplaceNoCase(ampm, "(^ *)|( *$)", "", "All");
				ampm = LCase(ampm);
				
				if(REFindNoCase("^[ ]*?[aApP][mM][ ]*?$", ampm))
				{
					//////specified ap/pm
					if(hr GTE 0 AND hr LTE 12 AND mn GTE 0 AND mn LT 60 AND sc GTE 0 AND sc LT 60)
					{
						if((ampm EQ "pm") AND (hr NEQ 12))
						{
							hr = hr + 12;
						}
						retVal = getHHMMSSTime(hr,mn,sc);
					}					
				}
				else
				{
					//////not specified ap/pm
					//if(hr <= 24 && mn <=60 && sc <=60)
					if(hr GTE 0 AND hr LT 24 AND mn GTE 0 AND mn LT 60 AND sc GTE 0 AND sc LT 60)
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
	retVal1 = padStr & val;
	tmpVal = Len(retVal1)-dig+1;
	return Mid(retVal1, tmpVal,Len(retVal1)-tmpVal+1);	
}
function getHHMMSSTime(sHr,sMn,sSc)
{
	retVal2 = "";		
	args = Arguments;
	for(i=1;i LTE ArrayLen(args);i=i+1)
	{
		retVal2 = retVal2 & makeFixedDigits(2,args[i],"00") & ":";
	}
	
	return Trim(Mid(retVal2,1,Len(retVal2)-1));
}

function getDateFromMMDDYYYYFormat(dateVal)
{
	arDate = ListToArray(dateVal,"/");
	if(ArrayLen(arDate) GTE 3)
	{
		return CreateDate(arDate[3], arDate[1], arDate[2]);
	}
	return Now();
}

function checkTimelessThan(sTime,gTime)
{	
	
	if((ArrayLen(sTime) LT 3) OR (ArrayLen(gTime) LT 3))
		return false;
	tLen = ArrayLen(sTime);
	
	if(sTime[1] LT gTime[1])
	{
		return true;
	}
	else if(sTime[1] EQ gTime[1])
	{
		if(sTime[2] LT gTime[2])
		{
			return true;
		}
		else if(sTime[2] EQ gTime[2])
		{
			if(sTime[3] LTE gTime[3])
			{
				return true;
			}
		}
	}
	return false;
}
function writeToErrorMessage(strError,spName)
{
	WriteOutput("<script language=""JavaScript"">");
	WriteOutput("addError('#strError#','#spName#')");
	WriteOutput("</script>");
}

function makeValidEmails(emailValues) 
{
	separator = ";";
	lsLen = ListLen(emailValues,separator);
	
	for(i=1;i LTE lsLen;i=i+1)
	{
		tmpEmail = Trim(ListGetAt(emailValues, i,separator));		
		if(REFindNoCase("^[A-Za-z0-9_]+([\.-]?[A-Za-z0-9_]+)*@[A-Za-z0-9_]+([\.-]?[A-Za-z0-9_]+)*(\.[A-Za-z0-9_]{2,3})+$", tmpEmail) LTE 0)
		{
			return tmpEmail;
		}
		emailValues = ListSetAt(emailValues, i, tmpEmail, separator);		
	}
	
	Form.rEmailAddress = emailValues;
	return "";
}

</cfscript>
<script>
var arrErrors = new Array();
var arrSpans = new Array();
function savethisReport(thisForm)
	{	
		//thisForm.action = reportSaveActionPage;
			//thisForm.submit();
		//return true;
		<cfoutput>
	var thisDate = new Date(#Year(Now())#,#Month(Now())#-1,#Day(Now())#);
	var thisTime = "#thisTime#";</cfoutput>
		var allClear = true;
		//check report name
		if(isSpace(thisForm.rName.value))
		{
			queueMessage("Report Name is a required field", document.all.error_ReportName);
			allClear = false;
		}
		else
		{
			clearQueue(document.all.error_ReportName);
		}
		//////////////////////////////////////////////////////////////
		////check start time and end time
		var dTrue = true;
		var daysDiff = 0;
		//////////////check start time
		if(!validateDate(thisForm.rvStartDate.value))
		{
			queueMessage("Start Date is not correct", document.all.error_Start_Date);
			dTrue = false;
			allClear = false;
		}
		else if((daysDiff=days_less(makeDate(thisForm.rvStartDate.value),thisDate)) < 0)
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
		else if(!validateDate(thisForm.rvEndDate.value))
		{
			queueMessage("End Date is not correct", document.all.error_End_Date);
			dTrue = false;
			allClear = false;
		}
		
		if(dTrue)
		{
			if(days_less(makeDate(thisForm.rvEndDate.value),makeDate(thisForm.rvStartDate.value)) < 0)
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
		
		if(daysDiff == 0)
		{
			var selectedTime = getMilitaryTime(thisForm.rStartTime.value);
			//alert(selectedTime);
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
		if(allClear)
		{
			var oldAction = thisForm.action;
			thisForm.submit();		
			thisForm.action = oldAction;
			return;
		}
		else
		{
			showMessageWindow();				
		}
	}
	
	function addError(sErr,sSpan)
{
	var arLen = arrErrors.length;
	arrErrors[arLen] = sErr; 
	arrSpans[arLen] = sSpan;
}

function showError()
{
	var arLen = arrErrors.length;
	if(arLen > 0)
	{
		for(i=0;i<arLen;i++)
		{
			queueMessage(arrErrors[i], eval("document.all." + arrSpans[i]));
		}
		showMessageWindow();
	}
}
	
	</script>