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
<!-----------------------
<!---------1. commented to use shifted time axis------------>
<CFPARAM name="diStartTime" default="000000">
<!---------end commented to use shifted time axis------------>
--------------------->

<CFSCRIPT>
small_hourLimit1=10;
larger_hourLimit1=12;
small_hourLimit2=0;
larger_hourLimit2=7;


</CFSCRIPT>

<!-------------------------------------------------------------
<!---------2. commented to use shifted time axis------------>
<!-----------------------------------------
Get DataIntegration Minimum schedule time from database
------------------------------------------>
<CFQUERY NAME="q_Data_Integration_MinTime" datasource="#application.datasource#">
		Select 		min(Start_Time) as minStart_Time
		From 		Data_Integration
		where		Data_Integration_ID in
			(
			select 	max(Data_Integration_ID)
			from	Data_Integration
			where	Integration_Type='Brokers'
		
			Union
		
			select 	max(Data_Integration_ID)
			from	Data_Integration
			where	Integration_Type='Distributors'
		
			Union
		
			select 	max(Data_Integration_ID)
			from	Data_Integration
			where	Integration_Type='Products'
			)

</CFQUERY>
<CFIF q_Data_Integration_MinTime.recordCount GT 0>
	<CFSET diStartTime=q_Data_Integration_MinTime.minStart_Time>
</CFIF>
<!-----------------------------------------
End Get DataIntegration Minimum schedule time from database
------------------------------------------>
<!----------------------End commented to use shifted time axis-------------------->
---------------------------------------------------------------------------->

<!-----------------------------------------
Get DataIntegration Minimum schedule time from database
Edited to shift time axis
------------------------------------------>
<CFQUERY NAME="q_Data_Integration_Time" datasource="#application.datasource#">
		Select 		Start_Time as diStart_Time
		From 		Data_Integration
		where		Data_Integration_ID in
			(
			select 	max(Data_Integration_ID)
			from	Data_Integration
			where	Integration_Type='Brokers'
		
			Union
		
			select 	max(Data_Integration_ID)
			from	Data_Integration
			where	Integration_Type='Distributors'
		
			Union
		
			select 	max(Data_Integration_ID)
			from	Data_Integration
			where	Integration_Type='Products'
			)
			and End_Date >= #DateFormat(Now(),"yyyymmdd")#
</CFQUERY>
<CFIF q_Data_Integration_Time.recordCount GT 0>
	<CFSET tempDIStartTimes=q_Data_Integration_Time.diStart_Time>
	<CFSET diStartTimes="#Left(tempDIStartTimes,2)#:#Mid(tempDIStartTimes,3,2)#:#Mid(tempDIStartTimes,5,2)#">
	<cfset minDIStartTime=diStartTimes>
	<cfset maxDIStartTime=diStartTimes>
	<cfloop query="q_Data_Integration_Time" startrow="2">
		<CFSET tempDIStartTimes=q_Data_Integration_Time.diStart_Time>
		<CFSET diStartTimes="#Left(tempDIStartTimes,2)#:#Mid(tempDIStartTimes,3,2)#:#Mid(tempDIStartTimes,5,2)#">
		<cfset time1=ListToArray(shiftTimeFrame(TimeSLimit,diStartTimes),":")>
		<cfset time2=ListToArray(shiftTimeFrame(TimeSLimit,minDIStartTime),":")>
		<cfif checkTimelessThan(time1,time2)>
			<cfset minDIStartTime=diStartTimes>
		<cfelse>
			<cfset maxDIStartTime=diStartTimes>
		</cfif>
	</cfloop>
<cfelsE>
	<cfset minDIStartTime=TimeGLimit>
</CFIF>
<!-----------------------------------------
End Get DataIntegration Minimum schedule time from database
------------------------------------------>

<CFSCRIPT>

//3. commented to use shifted time axis
//diMinStartTime = Left(diStartTime,2) & ":" & Mid(diStartTime,3,2) & ":" & Right(diStartTime,2);

//diMinStartTime=minDIStartTime;
diMinStartTime=TimeFormat(DateAdd('n',-30,CreateDateTime(Year(Now()),Month(Now()), Day(Now()), Left(minDIStartTime,2), Mid(minDIStartTime,4,2), Mid(minDIStartTime,7,2))),"HH:mm:ss");
//diMaxStartTime=TimeSLimit;
//diMaxStartTime=TimeFormat(DateAdd('n',30,CreateDateTime(Year(Now()),Month(Now()), Day(Now()), Left(TimeSLimit,2), Mid(TimeSLimit,4,2), Mid(TimeSLimit,7,2))),"HH:mm:ss");
//diMaxStartTime=TimeFormat(DateAdd('n',30,CreateDateTime(Year(Now()),Month(Now()), Day(Now()), Left(TextfileTimeSLimit,2), Mid(TextfileTimeSLimit,4,2), Mid(TextfileTimeSLimit,7,2))),"HH:mm:ss");
diMaxStartTime = TextfileTimeSLimit;


thisTime = timeformat(Now(), 'HH:mm:ss');
TimeSelectLimit = timeformat(DateAdd('h', 1, Now()), 'HH:mm:ss');
DateSelectLimit = dateformat(Now(), 'm/d/yyy');

tempTime1 = ListToArray(TimeSelectLimit,":");		
tempTime2 = ListToArray(TimeGLimit,":");
tempTime3 = ListToArray(TimeSLimit,":");
	
if(checkTimelessThan(tempTime1,tempTime2) AND NOT(checkTimelessThan(tempTime1,tempTime3)))
{
	TimeSelectLimit=TimeGLimit;
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