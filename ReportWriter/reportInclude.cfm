<!---------reportInclude.cfm----->
<CFINCLUDE TEMPLATE="schedule/reportCommon.cfm">
<CFSET reportInclude=true>
<CFSET PAGE_TITLE="Report Writer">
<CFSET GROUP="reports">

<CFSET VOL_INPUT_PAGE_TITLE="Volume Summary Report (Filter Section)">
<CFSET VOL_OUTPUT_PAGE_TITLE="Volume Summary Report">
<CFSET VOL_EMAIL_PAGE_TITLE="Volume Email Notification">
<CFSET VOL_EMAIL_SUBJECT="Volume Report Criteria Confirmation">

<!--- Get the profile for this user --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF Get_Profile_Settings.Report_Scheduler NEQ 1>
  <CFIF Get_Profile_Settings.Reports_Access_Level lt 3>
	<CFLOCATION addtoken="No" url="/">
	<CFABORT>
  </CFIF>
</CFIF>

<CFSET PREFIX = "#Replace(CGI.SERVER_NAME, ".", "_", "ALL")#_">

<CFSCRIPT>
rUserName = "dkunnath";
rPassword = "deepa";
// claim Report
claimReportPage	=	"claimsIndex.cfm";

reportPage			=	"index.cfm";
reportProgramPage	=	"reportDistributorSummary.cfm";
newreportProgramPage	=	"newreportDistributorSummary.cfm";
reportProductPage	=	"reportProductSummary.cfm";
newreportProductPage	=	"newreportProductSummary.cfm";
reportProductMarginPage	=	"reportProductMargin.cfm";


reportProgramLookup	= "reportDistributorLookup.cfm";
reportProductLookup	= "reportProductLookup.cfm";

reportProgramForm 	= "reportDistributorForm.cfm";
newreportProgramForm 	= "newreportDistributorForm.cfm";
reportProductForm 	= "reportProductForm.cfm";
newreportProductForm 	= "newreportProductForm.cfm";
reportProductMarginForm 	= "reportProductMarginForm.cfm";

getProgramReportPage=	"getDistributorReport.cfm";
getnewProgramReportPage=	"getnewDistributorReport.cfm";
getProductReportPage=	"getProductReport.cfm";
getnewProductReportPage=	"getnewProductReport.cfm";

schGenerateProduct	= "schedule/generateProductReport.cfm";
schGeneratenewProduct = "schedule/generatenewProductReport.cfm";
schGenerateProgram	= "schedule/generateDistributorReport.cfm";
schGeneratenewProgram	= "schedule/generatenewDistributorReport.cfm";
schGeneratenewVolumeProgram = "schedule/generatenewDistributorVolumeReport.cfm";
schGeneratenewExpenseProgram = "schedule/generatenewDistributorExpenseReport.cfm";
schGeneratenewMarginProgram = "schedule/generatenewDistributorMarginReport.cfm";

showProgramPage		=	"showDistributorReport.cfm";
shownewProgramPage=	"shownewDistributorReport.cfm";
shownewExpenseProgramPage=	"shownewDistributorExpenseReport.cfm";
shownewMarginProgramPage=	"shownewDistributorMarginReport.cfm";
showProductPage		=	"showProductReport.cfm";
shownewProductPage		=	"shownewProductReport.cfm";


displayProduct		= "schedule/reportDisplayProductGP.cfm";
//displaynewProduct		= "schedule/reportnewDisplayProductGP.cfm";
displayProgram		= "schedule/reportDisplayDistributorGP.cfm";
displaynewVolumeProduct = "schedule/reportnewDisplayProductVolumeGP.cfm";
displaynewExpenseProduct = "schedule/reportnewDisplayProductExpenseGP.cfm";
displaynewMarginProduct = "schedule/reportnewDisplayProductMarginGP.cfm";

displaynewVolumeProgram		= "schedule/reportnewDisplayDistributorVolumeGP.cfm";
displaynewExpenseProgram		= "schedule/reportnewDisplayDistributorExpenseGP.cfm";
displaynewMarginProgram		= "schedule/reportnewDisplayDistributorMarginGP.cfm";

reportActionPage	=	"reportAction.cfm";
reportTemplatePage	=	"reportTemplate.cfm";
reportSaveActionPage=	"reportSaveAction.cfm";
reportListPage		= 	"reportList.cfm";
reportDetailsPage	= 	"reportDetails.cfm";
reportDeletePage	=	"reportDelete.cfm";

/*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Added from 9/30/02 onwards for Product/Program Margin Ananysis Report   
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*/
reportMarginAnalysisPage		=	"margin_Analysis.cfm";
reportProductMarginAnalysisPage	=	"margin_Analysis_product.cfm";
reportProgramMarginAnalysisPage	=	"margin_Analysis_program.cfm";

reportProductMarginLookup		=	"MarginProductLookup.cfm";
reportMarginActionPage			=	"MarginAction.cfm";

getProductMarginAnalysis		=	"getProductMarginReport.cfm";
getProgramMarginAnalysis		=	"getProgramMarginReport.cfm";

schGenerateMarginProduct		= 	"schedule/MarginProductGenerate.cfm";

displayProductMarginPage		=	"schedule/marginProductDisplayReport.cfm";

MarginSaveActionPage			=	"MarginSaveAction.cfm";
MarginReportDetailsPage			=	"MarginReportDetails.cfm";

/*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
End Added from 9/30/02 onwards for Product/Program Margin Ananysis Report
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*/

timeIncr=16;
thisDate = Now();
thisTimeFull=DateAdd('n',timeIncr,Now());
thisTime = timeformat(DateAdd('n',timeIncr,Now()), 'HH:mm:ss');
</CFSCRIPT>

<cfoutput>
<SCRIPT LANGUAGE="Javascript">
	var thisDate = new Date(#Year(Now())#,#Month(Now())#-1,#Day(Now())#);
	var thisTime = "#thisTime#";
	var reportSaveActionPage = "#reportSaveActionPage#";
	var verifyValuesFunction = "verifyData";
</SCRIPT>
</cfoutput>

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


<CFSCRIPT>
function writeToErrorMessage(strError,spName)
{
	WriteOutput("<script language=""JavaScript"">");
	WriteOutput("addError('#strError#','#spName#')");
	WriteOutput("</script>");
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
</CFSCRIPT>