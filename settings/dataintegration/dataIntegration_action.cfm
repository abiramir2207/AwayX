<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Data Integration</TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->


<CFINCLUDE template="dataIntegration_Include.cfm">
<!-------------------------------------------------------------------------->
<!---Set Defaults for Form Data--->
<CFPARAM NAME="Form.integration_Type" DEFAULT="">
<CFPARAM NAME="Form.integration_Option" DEFAULT="">

<CFPARAM NAME="Form.week_day1" DEFAULT="">
<CFPARAM NAME="Form.week_day2" DEFAULT="">
<CFPARAM NAME="Form.week_day3" DEFAULT="">
<CFPARAM NAME="Form.week_day4" DEFAULT="">
<CFPARAM NAME="Form.week_day5" DEFAULT="">
<CFPARAM NAME="Form.week_day6" DEFAULT="">
<CFPARAM NAME="Form.week_day7" DEFAULT="">



<CFPARAM NAME="Form.enterDate" DEFAULT="">
<CFPARAM NAME="Form.start_date" DEFAULT="">
<CFPARAM NAME="Form.end_date" DEFAULT="">

<CFPARAM NAME="Form.start_time" DEFAULT="">
<CFPARAM NAME="Form.start_time_hour" DEFAULT="">
<CFPARAM NAME="Form.start_time_min" DEFAULT="">
<CFPARAM NAME="Form.start_time_sec" DEFAULT="">
<CFPARAM NAME="Form.start_time_AMPM" DEFAULT="">
<CFPARAM NAME="Form.dataIntegration_File_Types" DEFAULT="">
<CFPARAM NAME="Form.dataIntegration_File_Names" DEFAULT="">
<CFPARAM NAME="Form.dataIntegration_File_ID" DEFAULT="">
<CFSET userID=request.AccessStructure.user_id>

<CFSET integration_Type="">
<CFSET integration_Option="">

<CFSET fromAction=true>

<SCRIPT LANGUAGE="JavaScript">
var arrErrors = new Array();
var arrSpans = new Array();
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
</SCRIPT>

<CFSCRIPT>
allClear = true;
sErr = "";

isDataClear();

function isDataClear()
{
	sSql1 = "insert into Data_Integration";
	sSql2 = "";
	sSql3 = "";
	sSql3 = "";
	
	//////Validate integration_Type
	switch(Form.integration_Type)
	{
		case "Brokers":
		case "Distributors":
		case "Products":			
			integration_Type=Form.integration_Type;
			break;
		default:
			allClear = false;		
			sErr = sErr & "Invalid integration Type<br>";
			//writeToErrorMessage(Invalid integration Type,"error_");
	}
	
	sSql2 = sSql2 & "(integration_Type";
	sSql3 = sSql3 & "('#Form.integration_Type#'";


	///////////Validate Integration Option	
	switch(Form.integration_Option)
	{		
		case "8":
			weekSelected = false;
			weekStr = "";
			sum_weeks = Val(0);
			for(i=1;i LTE 7;i=i+1)
			{
				if(Evaluate("Form.week_day" & i) NEQ "")
				{
					weekSelected = true;
					weekStr = weekStr & Evaluate("Form.week_day" & i) & ",";
					sum_weeks = sum_weeks + Val(Evaluate("Form.week_day" & i));
				}
			}
			if(weekSelected)
			{
				weekStr = Left(weekStr,Len(weekStr)-1);
				sSql2 = sSql2 & ",Days";
				sSql3 = sSql3 & ",'#weekStr#'";
				sSql2 = sSql2 & ",Sum_of_Days";
				sSql3 = sSql3 & ",#sum_weeks#";
			}
			else
			{
				allClear = false;
				sErr = sErr & "For integration Option one or more weekdays should be specified<br>";
				writeToErrorMessage("For integration Option one or more weekdays should be specified","error_Week_Days");
			}
		case "4":
			integration_Option=Form.integration_Option;
			break;
		default:
			allClear = false;
			sErr = sErr & "Invalid integration Option<br>";
			writeToErrorMessage("Invalid integration Option","error_Integration_Option");
	}
	
	sSql2 = sSql2 & ",integration_Option";
	sSql3 = sSql3 & ",'#Form.integration_Option#'";
	
	
	
	thisDate = createDate(Year(Now()),Month(Now()),Day(Now()));
	
	referDate = thisDate;
	if(Form.enterDate EQ "yes")
	{
		//enterDate
		////////////Validate Start Date
		
		dateValid1 = isDateValid(Form.start_date);	
		///////////////////////////////////////////////////////////
		if(NOT dateValid1)
		{
			allClear = false;
			sErr = sErr & "Invalid Start Date<br>";
			writeToErrorMessage("Invalid Start Date","error_Start_Date");
		}
		else
		{
			///////////Validate Start Date against web server current date		
			//WriteOutput(DateDiff("d", getDateFromMMDDYYYYFormat(Form.start_date)));
			if(DateDiff("d", thisDate,getDateFromMMDDYYYYFormat(Form.start_date)) LT 0)
			{
				allClear = false;
				sErr = sErr & "Start Date should be greater than or equal to Current Date<br>";
				writeToErrorMessage("Start Date should be greater than or equal to Current Date","error_Start_Date");
			}
			else
			{
				referDate = getDateFromMMDDYYYYFormat(Form.start_date);
			}
		}
		sSql2 = sSql2 & ",start_date";
		sSql3 = sSql3 & ",'#Form.start_date#'";
	
		/////////////////////////////////////////////////////////////

		////////////Validate End Date	
		dateValid2 = isDateValid(Form.end_date);
		if(NOT dateValid2)
		{
			allClear = false;
			sErr = sErr & "Invalid End Date<br>";
			writeToErrorMessage("Invalid End Date","error_End_Date");
		}
		sSql2 = sSql2 & ",end_date";
		sSql3 = sSql3 & ",'#Form.end_date#'";
		/////////////////////////////////////////////////////////////
	
		///////////////////////////Check if end date > start date
		if(dateValid1 AND dateValid2)
		{		
			if(DateDiff("d", getDateFromMMDDYYYYFormat(Form.start_date), getDateFromMMDDYYYYFormat(Form.end_date)) LT 0)
			{
				allClear = false;
				sErr = sErr & "End Date should be less than or equal to Start Date<br>";
				writeToErrorMessage("End Date should be less than or equal to Start Date","error_Start_End_Date");
			}
		}
	////////////End Validate Start and End Date
	}
	else
	{
		//Form.start_date = thisDate;
		//Form.end_date = createDate(9999,12,31);;
		Form.start_date = DateSelectLimit;
		Form.end_date = "12/31/9999";
		
		sSql2 = sSql2 & ",start_date";
		sSql3 = sSql3 & ",'#Form.start_date#'";
		
		sSql2 = sSql2 & ",end_date";
		sSql3 = sSql3 & ",'#Form.end_date#'";
	}
	
	//start_date = ;
	//end_date = "12/31/9999";
	
	
	start_date2=getDateFromMMDDYYYYFormat(Form.start_date);
	
	start_date = ListGetAt(Form.start_date,3,"/") & makeFixedDigits(2,ListGetAt(Form.start_date,1,"/"),"00") & makeFixedDigits(2,ListGetAt(Form.start_date,2,"/"),"00");
	end_date = ListGetAt(Form.end_date,3,"/") & makeFixedDigits(2,ListGetAt(Form.end_date,1,"/"),"00") & makeFixedDigits(2,ListGetAt(Form.end_date,2,"/"),"00");
	
	
	
	//////////Check Time
	
	
	//if(NOT((0 LTE Val(Form.start_time_hour) LTE 12) AND (0 LTE Val(Form.start_time_min) LTE 60) AND (0 LTE Val(Form.start_time_hour) LTE 60)))
	if(false)
	{		
		allClear = false;
		sErr = sErr & "Invalid Start Time<br>";
		writeToErrorMessage("Invalid Start Time","error_Start_Time");
	}
	else
	{
		
		/*
		////old working code
		time1 = ArrayNew(1);
		
		if(Form.start_time_AMPM EQ "am")
		{
			ArrayAppend(time1,Form.start_time_hour);
		}
		else
		{
			ArrayAppend(time1,Val(Form.start_time_hour) + 12);
		}
		
		ArrayAppend(time1,Form.start_time_min);
		ArrayAppend(time1,Form.start_time_sec);
		
		////old working code end
		*/
		
		/*
		valid code
		
		sTime = ListToArray(TimeSLimit,":");
		eTime = ListToArray(TimeGLimit,":");

		if(NOT (checkTimelessThan(time1,sTime) OR checkTimelessThan(eTime,time1)))
		{
			allClear = false;
			sErr = sErr & "You have to specify a time greater than 100000 or less than 050000. Check AM/PM<br>";
			writeToErrorMessage("Time should be greater than 100000 or less than 050000. Check AM/PM","error_Start_Time");
		}
		*/
		
		start_Time = getMilitaryTime(Form.start_time);
		time1 = ListToArray(start_Time,":");
		
		sTime = ListToArray(TimeSLimit,":");
		eTime = ListToArray(TimeGLimit,":");
		selTime = ListToArray(TimeSelectLimit,":");
		tTime = ListToArray(thisTime,":");
		
	
		r_date_less = DateDiff("d", thisDate,referDate);
		timeOk = true;
		timeMsg = "";
		timeSlot = 1;
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
		//WriteOutput(referDate & " " & thisDate & "<br>");
		if(r_date_less LTE 0)
		{
			
			////referDate < thisDate
			referDate = thisDate;
			
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
		
		//WriteOutput("<br>timeSlot " & timeSlot & "<br>" & r_date_less & "<br>");
		//WriteOutput("<br>timeSlot " & timeSlot & "<br>");
		
		if(timeSlot EQ 3)
		{
			if(NOT(checkTimelessThan(time1,sTime) OR checkTimelessThan(eTime,time1)))
			{
				timeOk = false;
				timeMsg = "Time should be greater than " & TimeGLimit & " or less than " & TimeSLimit & ". Check AM/PM";
			}
		}
		else if(timeSlot EQ 2)
		{
				if(NOT((checkTimelessThan(time1,sTime) AND checkTimelessThan(selTime,time1)) OR (checkTimelessThan(eTime,time1))))
				{
					timeOk = false;
					timeMsg = "Time should be between " & TimeSelectLimit & " and " & TimeSLimit & " or greater than " & TimeGLimit & ". Check AM/PM";
				}
		}
		else if(timeSlot EQ 1)
		{
			if(NOT(checkTimelessThan(selTime,time1) AND checkTimelessThan(tTime,time1)))
			{
				timeOk = false;
				timeMsg = "Time should be greater than " & TimeSelectLimit & ". Check AM/PM";
			}
		}
		else
		{

			timeOk = false;
			timeMsg = "You will have to select a day grater than " & thisDate;
		}
	
		if(NOT timeOk)
		{
	 		allClear = false;
			writeToErrorMessage(timeMsg ,"error_Start_Time");
		}		
		
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
		
	}

	/*
	Fstart_time_hour = Val(Form.start_time_hour);

	if(Form.start_time_AMPM EQ "pm" AND (Val(Fstart_time_hour) NEQ 12))
	{
		Fstart_time_hour = Val(Fstart_time_hour) + 12;
	}
	
	//sTime = Fstart_time_hour & Form.start_time_min & Form.start_time_sec;
	sTime = makeFixedDigits(2,Fstart_time_hour,"00") & makeFixedDigits(2,Form.start_time_min,"00") & makeFixedDigits(2,Form.start_time_sec,"00");
	
	sTime2 = timeAdd(Fstart_time_hour,Form.start_time_min,Form.start_time_sec,30*60);
	*/
	
	sTime = makeFixedDigits(2,ListGetAt(start_Time,1,":"),"00") & makeFixedDigits(2,ListGetAt(start_Time,2,":"),"00") & makeFixedDigits(2,ListGetAt(start_Time,3,":"),"00");
	
	sTime2 = timeAdd(ListGetAt(start_Time,1,":"),ListGetAt(start_Time,2,":"),ListGetAt(start_Time,3,":"),30*60);
	
	
	if(Val(Left(sTime,2)) GT Val(Left(sTime2,2)))
	{
		start_date2 = DateAdd('d', 1, start_date2);
	}
	
	start_date2 = DateFormat(start_date2,"mm/dd/yyyy");
	
	start_date2 = ListGetAt(start_date2,3,"/") & makeFixedDigits(2,ListGetAt(start_date2,1,"/"),"00") & makeFixedDigits(2,ListGetAt(start_date2,2,"/"),"00");
		
	sSql2 = sSql2 & ",start_time";
	sSql3 = sSql3 & ",'#sTime#'";
	
	
	
	///////////////////////////////////////////////
	///check textFileNames
	//<CFPARAM NAME="Form.dataIntegration_TextFileTypes" DEFAULT="">
	//<CFPARAM NAME="Form.dataIntegration_TextFileNames" DEFAULT="">
	//WriteOutput("#Form.dataIntegration_TextFileNames#");
	sTxtSql = "";
	sTxtErr = "";
	bTxtErr = false;
	for(i=1;i LTE ListLen(Form.dataIntegration_File_Types,",");i=i+1)
	{
		currentFName = ListGetAt(Form.dataIntegration_File_Names, i,",");
		if(NOT checkValid_DI_TextFileName(currentFName))
		{
			bTxtErr = true;	
			sTxtErr = sTxtErr & " " & ListGetAt(Form.dataIntegration_File_Types, i,",") & "-""" & currentFName & """ ";			
		}
	}
	
	
	if(bTxtErr)
	{
		allClear = false;
		sTxtErr = "Text File Name(s) " & sTxtErr & " are not valid";
		writeToErrorMessage(sTxtErr ,"error_FileNames");
	}
	
	sSql2 = sSql2 & ",User_ID)";
	sSql3 = sSql3 & ",'#userID#')";	
	
	sSql = sSql1  &  sSql2 & " values" & sSql3;
}


function checkValid_DI_TextFileName(txtFName)
{
	//WriteOutput(REFindNoCase("\w+?\.\w+?", txtFName));
	fNameOk = false;
	if(Len(txtFName) GT 0)
	{
		dotPlace = REFindNoCase("\.", txtFName);
		if((dotPlace GT 0) AND (dotPlace LT Len(txtFName)))
		{
			if(REFindNoCase(" ", txtFName) EQ 0)
			{
				fNameOk = true;
			}			
		}
	}		
	return fNameOk;
	/*if(/^\w*?\.\w*?$/.test(txtFName))
	{
    	return true;
	}
  	return false;	
	*/
}

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

function getDateFromMMDDYYYYFormat(dateVal)
{
	arDate = ListToArray(dateVal,"/");
	if(ArrayLen(arDate) GTE 3)
	{
		return CreateDate(arDate[3], arDate[1], arDate[2]);
	}
	return Now();
	
}



</CFSCRIPT>



<CFIF allClear>
	<!--------
	1. Insert new record
	2. Call SP which will schedule 
	Job1 (Job1 will call copy file and removefirst line)
		and
	Job2 (Job2 do all the DI stuff)
	3. Redirect to dataIntegration.cfm
	--------->
	
	<!-----
	<CFOUTPUT>#sSql#</CFOUTPUT>
	----->
	<!-----
	<CFOUTPUT>#sTime#---#sTime2#<br>#start_date#--#end_date#</CFOUTPUT>
	---->
	
	<cftransaction action = "begin">
		<cftry>
			<!---------1. Insert new record------>
			<CFIF Form.integration_Option EQ "4">
				<cfquery name="q_Data_Integration_Insert" datasource="#application.datasource#">
				SET NOCOUNT ON
				insert into Data_Integration
					(integration_Type,integration_Option,start_date,start_date2,end_date,start_time,start_time2,User_ID) values
					('#integration_Type#','#integration_Option#',#start_date#,#start_date2#,#end_date#,'#sTime#','#sTime2#','#userID#')
				SELECT Data_IntegrationID = @@IDENTITY
				SET NOCOUNT OFF
				</cfquery>
			<CFELSEIF Form.integration_Option EQ "8">
				<cfquery name="q_Data_Integration_Insert" datasource="#application.datasource#">
				SET NOCOUNT ON
				insert into Data_Integration
					(integration_Type,Days,Sum_of_Days,integration_Option,start_date,start_date2,end_date,start_time,start_time2,User_ID) values
					('#integration_Type#','#weekStr#',#sum_weeks#,'#integration_Option#',#start_date#,#start_date2#,#end_date#,'#sTime#','#sTime2#','#userID#') 
				SELECT Data_IntegrationID = @@IDENTITY
				SET NOCOUNT OFF
				</cfquery>
			</CFIF>
			
			<CFIF NOT bTxtErr>
			<cfset iIndex = 1>
			<cfloop index="lIndex" list="#Form.dataIntegration_File_ID#" delimiters=",">
				<cfquery name="q_Data_Integration_File_Update" datasource="#application.datasource#">
				Update 		DataIntegration_Files
				Set			DataIntegration_File_Name='#ListGetAt(Form.dataIntegration_File_Names, iIndex,",")#',
							User_ID='#userID#'
				Where		DataIntegration_File_ID=#lIndex#
				</cfquery>
			<cfset iIndex = iIndex+1>
			</cfloop>
			</CFIF>
			<!-----
			<CFOUTPUT>----#q_Data_Integration_Insert.Data_IntegrationID#----</CFOUTPUT>
			----->
			
			<!---------2. Call Srore procedure---------------->
			<cfstoredproc procedure="SCHEDULE_INTEGRATION"  datasource="#application.datasource#">
				<cfprocparam type="IN" CFSQLType="CF_SQL_INTEGER" value="#q_Data_Integration_Insert.Data_IntegrationID#" dbVarName="@@GTYPE">
			</cfstoredproc>
			
		<cftransaction action = "commit"/>
		<cfset bCommit=true>
			<!------<cfcatch type = "DATABASE">---->
			<cfcatch>
	    		<cftransaction action = "rollback"/>
					<CFSET action="showError">
					<cfrethrow>
					<!-----<CFINCLUDE TEMPLATE="../../site_wide_error_handler.cfm">------->					
					<cfset bCommit=false>
					<cfabort>
			</cfcatch>	
		</cftry>
		</cftransaction>

	
	<!---------3. Redirect to dataIntegration.cfm------>
	<CFIF bCommit>
		<CFLOCATION url="#diPage#?diType=#Form.integration_Type#">
	</CFIF>
	
	
<CFELSE>	
	<!----
	Some error occured, so show the dataIntegration.cfm with
	Error Message
	and also fill the form with the last edited but still not updated data	
	------->
	
	<CFSET action="showError">
	<CFINCLUDE template="#diPage#">

</CFIF>

<!-------------------------------------------------------------------------->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



