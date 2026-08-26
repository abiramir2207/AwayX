<!-----------------General Functions---------------------------->
<CFPARAM NAME="DICommon_IncludeFile" DEFAULT="true">

<!--- Get the profile for this user --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset SPA = CreateObject("component","components.user.settingsPanelAccess").init() />
<cfset getSPA = SPA.getSPAccess()>

<cfif getSPA.dataintegration EQ 0>
	<CFLOCATION addtoken="No" url="/">
	<CFABORT>
</CFIF>
<STYLE>
.di_warning
{
    COLOR: #ff4500;
}
</STYLE>
<CFSET logTables="Log_CF_Zone,Log_CF_Region,Log_CF_LOB,Log_CF_Broker,Log_CF_Buying_Group,Log_CF_Custid,Log_CF_Family,Log_CF_BillTo,Log_CF_ShipTo,LOG_CF_Invoice_Header,LOG_CF_Invoice_Detail,Log_CF_Label,Log_CF_Type_Group,Log_CF_Type,Log_CF_QBrand,Log_CF_Q_Brand_Desc,Log_CF_Item">
<CFSCRIPT>

TimeGLimit = "05:10:00";
TimeSLimit = "05:00:00";
TextfileTimeSLimit = "05:20:00";


diPage="dataIntegration.cfm";
diActionpage="dataIntegration_action.cfm";
basicInfoPage = "dataIntegrationBasicInfo.cfm";
basicInfoActionPage = "dataIntegrationBasicInfo_Action.cfm";
diLogPage = "diLog.cfm";
diLogListPage = "diLogList.cfm";
diLogDetailsPage = "diLogDetails.cfm";
diLogActionPage = "diLog_Action.cfm";
diLogTextFile = "diLogGenerateTextFile.cfm";

diGeneralLogPage="diGeneralLog.cfm";
diGeneralLogDetailsPage="diGeneralLogDetails.cfm";

function getAMPMTime(sTime,sDefault)
{	
	sTime = Trim(sTime);
	if(Len(sTime) LTE 5)
		return sDefault;
	sHr = Val(Left(sTime,2));		
	if(sHr GT 12)
	{
		sHr = sHr mod 12;
		if(sHr EQ 0)
		{
			lAmpm = " AM";
		}
		else
		{
			lAmpm = " PM";
		}
		sHr = Right("0" & #sHr#,2);
		retVal = sHr & Right(sTime,6) & lAmpm;
	}
	else if(sHr EQ 12)
	{
		retVal = sTime & " PM";
	}
	else
	{
		retVal = sTime & " AM";
	}
	

	return retVal;
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


function timeAdd(hr,mn,sc,secs)
{
	retTime = "";
	
	iHr = Val(hr);
	iMn = Val(mn);
	iSc = Val(sc);
	
	
	iSc = iSc + secs;
	if(iSc GTE 60)
	{	
		mns = iSc\60;
		iSc = iSc mod 60;
		iMn = iMn + mns;
		if(iMn GTE 60)
		{
			hrs = iMn\60;
			iMn = iMn mod 60;			
			iHr = iHr + hrs;
			if(iHr GTE 24)
			{
				iHr = iHr mod 24;
			}
		}
		else
		{
			retTime = hr & (iMn+mns) & sc;
		}
	}	
	retTime = makeFixedDigits(2,iHr,"00") & makeFixedDigits(2,iMn,"00") & makeFixedDigits(2,iSc,"00");
	
	return retTime;
}


function shiftTimeFrame(frameOrigin,sTime)
{
	if((ListLen(frameOrigin,":") LT 3) OR (ListLen(sTime,":") LT 3))
		return frameOrigin;
	oHr = ListGetAT(frameOrigin,1,":");
	oMn = ListGetAT(frameOrigin,2,":");
	oSc = ListGetAT(frameOrigin,3,":");
	if((not isNumeric(oHr)) or (not isNumeric(oMn)) or (not isNumeric(oSc)))
		return sTime;	
	
	secs = ((Val(oHr) * 60 * 60) + (Val(oMn) * 60) + Val(oSc)) * -1;
	//WriteOutput("22 " & secs & "<br>");
	//return timeAddOverflow(sTime,24*60*60);
	
	tempTime = timeAddOverflow(timeAddOverflow(sTime,24*60*60),secs);
	
	tHr = ListGetAT(tempTime,1,":");
	tMn = ListGetAT(tempTime,2,":");
	tSc = ListGetAT(tempTime,3,":");
	
	tHr = tHr mod 24;
	
	return makeFixedDigits(2,tHr,"00") & ":" & makeFixedDigits(2,tMn,"00") & ":" & makeFixedDigits(2,tSc,"00");
	//return timeAddOverflow(sTime,secs);
	
}

function timeAddOverflow(sTime,secs)
{
	retTime = "";
	
	if((ListLen(sTime,":") LT 3))
		return sTime;
		
	iHr = Val(ListGetAT(sTime,1,":"));
	iMn = Val(ListGetAT(sTime,2,":"));
	iSc = Val(ListGetAT(sTime,3,":"));
	
	iSecs = (iHr * 60 * 60) + (iMn * 60) + iSc;
	iSecs = iSecs + secs;
	
	iHr = iSecs\3600;
	iSecs = iSecs mod 3600;
	iMn = iSecs\60;
	iSecs = iSecs mod 60;
	iSc = iSecs;
	
	retTime = makeFixedDigits(2,iHr,"00") & ":" & makeFixedDigits(2,iMn,"00") & ":" & makeFixedDigits(2,iSc,"00");
	
	return retTime;
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
</CFSCRIPT>
<!-----------------General Functions---------------------------->