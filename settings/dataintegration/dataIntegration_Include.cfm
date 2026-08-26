<!----
dataIntegration_Include.cfm
---->

<CFIF NOT isDefined("DICommon_IncludeFile")>
	<CFINCLUDE template="diCommon.cfm">
</CFIF>

<CFIF NOT isDefined("DI_IncludeFile")>
	<CFINCLUDE template="diLog_Include.cfm">
</CFIF>

<CFPARAM NAME="DI_IncludeFile" DEFAULT="true">
<CFPARAM NAME="URL.pageTitle" DEFAULT="Personal Settings: Data Integration">
<CFPARAM name="diTextFileCreationTime" default="">


<!-----------------------------------------
Get Text File Creation time from database
------------------------------------------>
<CFQUERY NAME="q_TextFile_Creation_Time" datasource="#application.datasource#">
		Select 		File_Creation_Time
		From 		DataInt_Settings
		where			Dataint_setting_ID =
			(Select 	max(Dataint_setting_ID)
			From 		DataInt_Settings)
</CFQUERY>
<CFIF q_TextFile_Creation_Time.recordCount GT 0>	
	<CFIF q_TextFile_Creation_Time.File_Creation_Time NEQ "">
		<CFSET diTextFileCreationTime=q_TextFile_Creation_Time.File_Creation_Time>
	</CFIF>
</CFIF>
<!-----------------------------------------
End Get DataIntegration Minimum schedule time from database
------------------------------------------>


<CFSCRIPT>

small_hourLimit1=10;
larger_hourLimit1=12;
small_hourLimit2=0;
larger_hourLimit2=7;


//////// Todays's time restriction is Now() + 1 hr
thisTime = timeformat(Now(), 'HH:mm:ss');
TimeSelectLimit = timeformat(DateAdd('h', 1, Now()), 'HH:mm:ss');
DateSelectLimit = dateformat(Now(), 'm/d/yyy');
selctTimeisThisTime = true;



///////change time frame to TimeSLimit

if(Len(diTextFileCreationTime) GT 0)
{
	//diFileCreationTime = Left(diTextFileCreationTime,2) & ":" & Mid(diTextFileCreationTime,3,2) & ":" & Mid(diTextFileCreationTime,5,2);
	diFileCreationTime=TimeFormat(DateAdd('n',30,CreateDateTime(Year(Now()),Month(Now()), Day(Now()), Left(diTextFileCreationTime,2), Mid(diTextFileCreationTime,3,2), Mid(diTextFileCreationTime,5,2))),"HH:mm:ss");

	arTimeGLimit = ListToArray(shiftTimeFrame(TimeSLimit,TimeGLimit),":");
	diFileTime = ListToArray(shiftTimeFrame(TimeSLimit,diFileCreationTime),":");
	
	if(checkTimelessThan(arTimeGLimit,diFileTime))
	{
		TimeGLimit=diFileCreationTime;
	}
	
/////////////
///////change time frame to TimeSLimit
}
///////////////////////////////////////////


//////// If TimeGLimit greater than Todays's time restriction
/////// make that Todays's time restriction

tempTime1 = ListToArray(TimeSelectLimit,":");		
tempTime2 = ListToArray(TimeGLimit,":");
tempTime3 = ListToArray(TimeSLimit,":");
if(checkTimelessThan(tempTime1,tempTime2) AND NOT(checkTimelessThan(tempTime1,tempTime3)))
{
	TimeSelectLimit=TimeGLimit;
	selctTimeisThisTime = false;
}

	
default_hour = 10;


function checkArrayThan(sTime,gTime)
{	
	tLen = ArrayLen(sTime);
	
	for(i=1;i LTE tLen;i=i+1)
	{
		if(sTime[i] LT gTime[i])
		{
			return true;
		}
		else if(sTime[i] GT gTime[i])
		{
			return false;
		}
	}
	return true;
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

/*
function writeToErrorMessage(strError,spName)
{
	WriteOutput("<script language=""JavaScript"">");
	WriteOutput("addError('#strError#','#spName#')");
	WriteOutput("</script>");
}
*/
/*
function checkEmail(email) 
{
	retVal = false;
	retVal = REFindNoCase("^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$", email);
  	return retVal;
}


function checkMultipleEmail(emailStr) 
{
  	separator = ";";
  	//emails2 = emailStr.split(separator);
	emails2 = ListToArray(emailStr,";");
  	anyEmail = false;
	for(i=1; i LTE ArrayLen(emails2); i=i+1) 
	{
		//emails2[i] = emails2[i].replace(/(^ )|( $)/g, ""); //trim spaces
		emails2[i] = REReplaceNoCase(emails2[i], "(^ *)|( *$)", "", "All");
    	tempEmail = checkEmail(emails2[i]);
		if(NOT tempEmail) 
		{
			return emails2[i];
		} 		
	}
	return true;
 }
 */
</CFSCRIPT>