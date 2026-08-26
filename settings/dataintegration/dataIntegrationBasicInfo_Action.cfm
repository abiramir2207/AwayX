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

<CFINCLUDE template="dataIntBasicInfo_Include.cfm">

<!--------Set defaults------------->
<CFPARAM name="Form.Email_Address" default="">
<CFPARAM name="Form.textFileTime" default="">
<!-------------<CFPARAM name="Form.Commodity_Pick_Time" default="">------------->



<CFSET userID=request.AccessStructure.user_id>
<CFSET fromAction=true>
<!--------End Set defaults------------->


<!------------------------
JavaScript code for showing the Error Messages using client side pop up
---------------------------->
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
<!------------------------
End JavaScript code for showing the Error Messages using client side pop up
---------------------------->

<!----------------------
<!--------------------------------
Get commodity Time
--------------------->
<CFPARAM NAME="Commodity_Time" DEFAULT="">
<CFQUERY NAME="q_Data_Integration_Read" datasource="#application.datasource#">
		Select 		di.Commodity_Time
		From 		DataInt_Settings di
		where			di.Dataint_setting_ID =
			(Select 	max(Dataint_setting_ID)
			From 		DataInt_Settings)
</CFQUERY>
<CFIF q_Data_Integration_Read.recordCount GT 0>
	<CFSET tempCommodity_Time=Trim(q_Data_Integration_Read.Commodity_Time)>
	<CFIF Len(tempCommodity_Time) GTE 6>
		<CFSET Commodity_Time="#Left(tempCommodity_Time,2)#:#Mid(tempCommodity_Time,3,2)#:#Mid(tempCommodity_Time,5,2)#">
	</CFIF>
</CFIF>

<!--------------------------------
End Get commodity Time
--------------------->
------------------------>

<!--------------
Validate Form Fields
------------------------>
<CFSCRIPT>
allClear = true;


/*
//////////////////////////////////////////
Validate Email Address
////////////////////////////////////////////
*/
if(Len(Form.Email_Address) GT 0)
{
	validEmail = makeValidEmails(Form.Email_Address);
	if(validEmail NEQ true)
	{
		allClear = false;
		writeToErrorMessage("Invalid Email Address " & validEmail,"error_Email_Address");
	}
	else if(Len(Form.Email_Address) GTE 4000)
	{
		allClear = false;
		writeToErrorMessage("Email Address exceeds available size limit","error_Email_Address");
	}
}
else
{
	allClear = false;
	writeToErrorMessage("Invalid Email Address","error_Email_Address");
}
/*
//////////////////////////////////////////
End Validate Email Address
////////////////////////////////////////////
*/


/*
//////////////////////////////////////////
Validate Text Creation Time
////////////////////////////////////////////
*/
//Form.textFileTime = ":8:7 pm";

WriteOutput(Form.textFileTime);

milTime = getMilitaryTime(Form.textFileTime);

if(milTime EQ "")
{
	allClear = false;
	writeToErrorMessage("Invalid Text Creation Time " & Form.textFileTime,"error_TextFile_Time");
	WriteOutput("Err<br>");
}
else
{	
	tTime = ListToArray(milTime,":");	
	minTime = ListToArray(diMinStartTime,":");
	maxTime = ListToArray(diMaxStartTime,":");
	
	if(NOT((checkTimelessThan(tTime,minTime) OR checkTimelessThan(maxTime,tTime))) AND checkTimelessThan(minTime,maxTime))
	{
		allClear = false;
		writeToErrorMessage("Text File should be Created before the Data Integration Start Time and after Data Integration End Time","error_TextFile_Time");
	}
	else if(NOT((checkTimelessThan(tTime,minTime) AND checkTimelessThan(maxTime,tTime))) AND checkTimelessThan(maxTime,minTime))
	{
		allClear = false;
		writeToErrorMessage("Text File should be Created before the Data Integration Start Time and after Data Integration End Time","error_TextFile_Time");
	}
	else
	{
		milTime2 = Left(milTime,2) & Mid(milTime,4,2) &  Mid(milTime,7,2);
	}
		
}

//WriteOutput(("00:00" EQ "false") & "<br>");
//WriteOutput(milTime & "<br>");

/*
//////////////////////////////////////////
End Validate Text Creation Time
////////////////////////////////////////////
*/



/*
//////////////////////////////////////////
Validate Commodity Time
////////////////////////////////////////////
*/
/*
milTime = getMilitaryTime(Form.Commodity_Pick_Time);


if(milTime EQ "")
{
	allClear = false;
	writeToErrorMessage("Invalid Commodity Time " & Form.Commodity_Pick_Time,"error_CommFile_Time");
	WriteOutput("Err1<br>");
}
else
{	
	tTime = ListToArray(milTime,":");	
	minTime = ListToArray(Commodity_Time,":");
	maxTime = ListToArray(commMaxTime,":");
	
	if(NOT(checkTimelessThan(tTime,maxTime) AND checkTimelessThan(minTime,tTime)) AND checkTimelessThan(minTime,maxTime))
	//if(NOT((checkTimelessThan(tTime,minTime) OR checkTimelessThan(maxTime,tTime))) AND checkTimelessThan(minTime,maxTime))
	{
		allClear = false;
		writeToErrorMessage("Commodity Time should be in the interval \'#getAMPMTime(Commodity_Time,"")#\' to \'#getAMPMTime(commMaxTime,"")#\'","error_CommFile_Time");
		//WriteOutput("Commodity Time should be in the interval \'#getAMPMTime(Commodity_Time,"")#\' to \'#getAMPMTime(commMaxTime,"")#\'");
	}
	else if(NOT(checkTimelessThan(tTime,maxTime) OR checkTimelessThan(minTime,tTime)) AND (checkTimelessThan(maxTime,minTime)))
	//else if(NOT((checkTimelessThan(tTime,minTime) AND checkTimelessThan(maxTime,tTime))) AND checkTimelessThan(maxTime,minTime))
	{
		allClear = false;
		writeToErrorMessage("Commodity Time should be in the interval \'#getAMPMTime(Commodity_Time,"")#\' to \'#getAMPMTime(commMaxTime,"")#\'","error_CommFile_Time");
		WriteOutput("Err3<br>");
	}
	else
	{
		milTime3 = Left(milTime,2) & Mid(milTime,4,2) &  Mid(milTime,7,2);
		WriteOutput("Fine<br>");
	}
		
}
*/
/*
//////////////////////////////////////////
End Validate Commodity Time
////////////////////////////////////////////
*/

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
	
	Form.Email_Address = emailValues;
	return true;
}
</CFSCRIPT>
<!--------------
End Validate Form Fields
------------------------>



<CFIF allClear>
	<!--------
	1. Insert new record
	2. Redirect to dataIntegrationBasicInfo.cfm
	--------->
		
	<!---------1. Insert new record------>
	
	<cfquery name="q_DataIntegrationBInfoInsert" datasource="#application.datasource#">
		insert into 	DataInt_Settings		
		(Server_Name,File_Location,SQL_Reference_Path,DTS_Reference_Path,smtp_server,Copy_Path,Email_Address,File_Creation_Time,User_ID)
		Select 	Server_Name,File_Location,SQL_Reference_Path,DTS_Reference_Path,smtp_server,Copy_Path,'#Form.Email_Address#' as Email_Address,'#milTime2#' as File_Creation_Time,'#userID#' as User_ID 
		From	DataInt_Settings
		where	Dataint_setting_ID in
			(
			Select 	max(Dataint_setting_ID)
			From 		DataInt_Settings
			)
	</cfquery>
	
	<!---------2. Redirect to dataIntegration.cfm------>	
	
	<CFLOCATION url="#basicInfoPage#">
	
<CFELSE>	
	<!----
	Some error occured, so show the dataIntegration.cfm with
	Error Message
	and also fill the form with the last edited but still not updated data	
	------->
	
	<CFSET sErr=true>
	<CFSET action="showError">
	<CFINCLUDE template="#basicInfoPage#">
	
</CFIF>



<!-------------------------------------------------------------------------->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



