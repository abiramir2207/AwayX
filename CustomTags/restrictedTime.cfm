<!----------------restrictedTime.cfm------------------>

<cfparam name="Attributes.size" default="10">
<cfparam name="Attributes.value" default="">
<cfparam name="Attributes.name" default="Time">
<cfparam name="Attributes.ImagesDir" default="">
<cfparam name="Attributes.mdelta" default="10">
<cfparam name="Attributes.width" default="80">
<cfparam name="Attributes.hhmmss" default="">
<cfparam name="Attributes.minInterval" default="00:00:00">
<cfparam name="Attributes.maxInterval" default="23:59:59">
<cfparam name="Attributes.showSeconds" default="true">


<cfset minIntervalDefault="00:00:00">
<cfset maxIntervalDefault="23:59:59">
<cfset defaultValue=RTgetAMPMTime(minIntervalDefault)>

<!------------0 <= mdelta <= 60------------------->
<cfif Attributes.mdelta gt 60 or Attributes.mdelta lt 0>
<cfset Attributes.mdelta="10">
</cfif>

<!----
<cfif len(Attributes.value) gt 8 or not Attributes.value contains ':'>
<cfset Attributes.value="00:00">
</cfif> 


<cfif  not isnumeric(listgetat(Attributes.value,1,':')) or not isnumeric(val(listgetat(Attributes.value,2,':')))>
<cfset Attributes.value="00:00">
</cfif>


<cfif left(Attributes.value,2) gt 12 or left(Attributes.value,2) lt 0 or 
val(right(Attributes.value,5)) gt 59 or val(right(Attributes.value,5)) lt 0>
<cfset Attributes.value="00:00">
</cfif>
--->


<!---------------------------------------------------->
<!--------------
If Attributes.hhmmss is not specified and Attributes.value is specified
take Attributes.value
--------------------->
<cfif (Len(Attributes.hhmmss) LTE 0) AND (Len(Attributes.value) GT 0)>
	<cfset Attributes.hhmmss=RTgetMilitaryTime(Attributes.value)>
</cfif>
<!---------------------------------------------------->


<!--------------------------------------------------------->
<!------following if-<cfif Len(Attributes.hhmmss) GT 0>-------------------->
<!------code included to enable to specify null time-------->
<cfif Len(Attributes.hhmmss) GT 0>
<!---------------------------------------------------->
<!-------------Validate hhmmss------------------------>
<cfif ListLen(Attributes.hhmmss,':') LT 3>
	<cfset Attributes.hhmmss="00:00:00">
</cfif>
<cfif  not isnumeric(listgetat(Attributes.hhmmss,1,':')) or not isnumeric(listgetat(Attributes.hhmmss,2,':')) or not isnumeric(listgetat(Attributes.hhmmss,3,':'))>
	<cfset Attributes.hhmmss="00:00:00">
</cfif>

<cfset Attributes.hhmmss=RTgetHHMMSSTime(listgetat(Attributes.hhmmss,1,':'),listgetat(Attributes.hhmmss,2,':'),listgetat(Attributes.hhmmss,3,':'))>
<!---------------------------------------------------->

<!---------------------------------------------------->
<!-------------Validate minInterval------------------------>
<cfif ListLen(Attributes.minInterval,':') LT 3>
	<cfset Attributes.minInterval=minIntervalDefault>
</cfif>
<cfif  not isnumeric(listgetat(Attributes.minInterval,1,':')) or not isnumeric(listgetat(Attributes.minInterval,2,':')) or not isnumeric(listgetat(Attributes.minInterval,3,':'))>
	<cfset Attributes.minInterval=minIntervalDefault>
</cfif>

<cfset Attributes.minInterval=RTgetHHMMSSTime(listgetat(Attributes.minInterval,1,':'),listgetat(Attributes.minInterval,2,':'),listgetat(Attributes.minInterval,3,':'))>
<!---------------------------------------------------->

<!---------------------------------------------------->
<!-------------Validate maxInterval------------------------>
<cfif ListLen(Attributes.maxInterval,':') LT 3>
	<cfset Attributes.maxInterval=maxIntervalDefault>
</cfif>
<cfif  not isnumeric(listgetat(Attributes.maxInterval,1,':')) or not isnumeric(listgetat(Attributes.maxInterval,2,':')) or not isnumeric(listgetat(Attributes.maxInterval,3,':'))>
	<cfset Attributes.maxInterval=maxIntervalDefault>
</cfif>

<cfset Attributes.maxInterval=RTgetHHMMSSTime(listgetat(Attributes.maxInterval,1,':'),listgetat(Attributes.maxInterval,2,':'),listgetat(Attributes.maxInterval,3,':'))>
<!---------------------------------------------------->

<!-----validate hhmmss with minInterval and maxInterval---->
<cfset ahhmmss=ListToArray(Attributes.hhmmss,":")>
<cfset aminInterval=ListToArray(Attributes.minInterval,":")>
<cfset amaxInterval=ListToArray(Attributes.maxInterval,":")>
<cfif NOT ((RTcheckTimelessThan(ahhmmss,amaxInterval) OR RTcheckTimelessThan(aminInterval,ahhmmss))) AND RTcheckTimelessThan(amaxInterval,aminInterval)>
	<cfset Attributes.hhmmss=Attributes.minInterval>
<cfelseif NOT((RTcheckTimelessThan(ahhmmss,amaxInterval) AND RTcheckTimelessThan(aminInterval,ahhmmss))) AND RTcheckTimelessThan(aminInterval,amaxInterval)>
	<cfset Attributes.hhmmss=Attributes.minInterval>
</cfif>

<cfset Attributes.hhmmss=RTgetAMPMTime(Attributes.hhmmss)>
<!--------------------------------------------------------->

</cfif>
<!------end code included to enable to specify null time-------->
<!------ if--------------------->
<!--------------------------------------------------------->

<cfscript>
function RTcheckTimelessThan(sTime,gTime)
{	
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

function RTgetHHMMSSTime(sHr,sMn,sSc)
{
	retVal2 = "";		
	args = Arguments;
	for(i=1;i LTE ArrayLen(args);i=i+1)
	{
		retVal2 = retVal2 & RTmakeFixedDigits(2,args[i],"00") & ":";
	}
	
	return Trim(Mid(retVal2,1,Len(retVal2)-1));
}

function RTmakeFixedDigits(dig,val,padStr)
{
	retVal1 = padStr & val;
	tmpVal = Len(retVal1)-dig+1;
	return Mid(retVal1, tmpVal,Len(retVal1)-tmpVal+1);	
}

function RTgetAMPMTime(sTime)
{	
	sTime = Trim(sTime);
	if(Len(sTime) LTE 0)
		return "";
	sHr = Val(Left(sTime,2));	
	if(sHr GT 12)
	{
		sHr = sHr mod 12;
		if(sHr EQ 0)
			lAmpm = " AM";
		else
			lAmpm = " PM";
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
function RTgetMilitaryTime(sTime)
{
	retVal = "";
	spTime = ListToArray(sTime,":");
	if(ArrayLen(spTime) GTE 3)
	{
		hr = Val(spTime[1]);
		if(RTmakeFixedDigits(2,hr,"00") EQ spTime[1])
		{
			mn = Val(spTime[2]);
			if(RTmakeFixedDigits(2,mn,"00") EQ spTime[2])
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
						retVal = RTgetHHMMSSTime(hr,mn,sc);
					}					
				}
				else
				{
					//////not specified ap/pm
					//if(hr <= 24 && mn <=60 && sc <=60)
					if(hr GTE 0 AND hr LT 24 AND mn GTE 0 AND mn LT 60 AND sc GTE 0 AND sc LT 60)
					{
						retVal = RTgetHHMMSSTime(hr,mn,sc);
					}					
				}					
				
			}			
		}
	}		
	return retVal;
}

</cfscript>

<cfoutput>
<script language="JavaScript">
<cfif NOT isDefined("caller.cf_restrictedTimeCalled")>

function RTtoggleMeridian(formname,datename,a){	

	thisObj = 'document.' + formname + '.' + datename;
	thisObj = eval(thisObj)
	
	theUltVal = 'document.' + formname + '.' + datename + '.value'
	theUltValRes = eval(theUltVal);
	
	if(theUltValRes.length <= 0)
	{
		theUltValRes = "#defaultValue#";
	}
	
	setValue = theUltValRes;
	var porm = "+";
	
	if (a=='z') {
		porm = "+";
		if (theUltValRes.substring(10,11) != 'M') 
		{
			theUltValRes = theUltValRes + ' PM';
			setValue = theUltValRes;
		}
		else if(theUltValRes.substr(9,2).toUpperCase() == "AM")
		{
			setValue = changeToPM(theUltValRes);
		}		
		else
		{
			setValue = changeToAM(theUltValRes);
		}
	}else{
		porm = "-";
		if (theUltValRes.substring(10,11) != 'M') 
		{
			theUltValRes = theUltValRes + ' AM';
			setValue = theUltValRes;
		}
		else if(theUltValRes.substr(9,2).toUpperCase() == "PM")
		{
			setValue = changeToAM(theUltValRes);
		}
		else
		{
			setValue = changeToPM(theUltValRes);
		}
	}
	
	totalValue = setValue;
	
	totalValue = RTcheckTime(thisObj,totalValue,porm);
	
	ievalue = "document." + formname + "." + datename + ".value='" + totalValue + "'";
	eval(ievalue);
}

function changeToPM(theUltValRes)
{
	var theUltValResClip = theUltValRes.substring(0,8) + ' PM';
	var Hvalue = theUltValRes.substring(0,2)
	var Mvalue = theUltValRes.substring(3,5)
	var Svalue = theUltValRes.substring(6,8)
	if(parseFloat(Hvalue) == "00")
	{
		theUltValResClip = "12" + theUltValResClip.substr(2);
	}
	return theUltValResClip;
}
function changeToAM(theUltValRes)
{
	var theUltValResClip = theUltValRes.substring(0,8) + ' AM';
	var Hvalue = theUltValRes.substring(0,2)
	var Mvalue = theUltValRes.substring(3,5)
	var Svalue = theUltValRes.substring(6,8)
	if(parseFloat(Hvalue) == 12)
	{
		theUltValResClip = "00" + theUltValResClip.substr(2);
	}
	return theUltValResClip;
}

function RTChangeHour(formname,datename,porm)
{
thisObj = 'document.' + formname + '.' + datename;
thisObj = eval(thisObj)

theValue= 'document.' + formname + '.' + datename + '.value' 
theValue = eval(theValue)
	if(theValue.length <= 0)
	{
		theValue = "#defaultValue#";
	}

Hvalue = theValue.substring(0,2)
Mvalue = theValue.substring(3,5)
Svalue = theValue.substring(6,8)
MRvalue = theValue.substring(8,11)

//alert(Hvalue);
//alert(Mvalue);
//alert(MRvalue);

if (porm=='+') {
HnewValue =  parseFloat(Hvalue) + 1
if (HnewValue<10) {HnewValue = '0' + HnewValue}
	if (HnewValue>=12 && MRvalue == ' AM') {
		HnewValue = 12;
		MRvalue = ' PM';
	}else if (HnewValue>12 && MRvalue == ' PM') {
		HnewValue = '01';
	}else if (HnewValue>=12 && MRvalue == ' PM') {
		HnewValue = '00';
		MRvalue = ' AM'
	}
}
else
{
HnewValue =  parseFloat(Hvalue) - 1

if (HnewValue < 0 && MRvalue == ' AM')
{
	HnewValue = '11'
	MRvalue = ' PM'
}
else if (HnewValue < 1 && MRvalue == ' PM')
{
	HnewValue = '12'
} else if (HnewValue == 11 && MRvalue == ' PM')
{
	MRvalue = ' AM'
}
if (HnewValue<10) {HnewValue = '0' + HnewValue}
}
	
	totalValue = HnewValue + ":" + Mvalue + ":" + Svalue + MRvalue;
	totalValue = RTcheckTime(thisObj,totalValue,porm);
	
	//ievalue = "document." + formname + "." + datename + ".value='" + HnewValue + ":" + Mvalue + ":" + Svalue + MRvalue + "'"; 
	ievalue = "document." + formname + "." + datename + ".value='" + totalValue + "'";
	eval(ievalue); 
}

function RTChangeMinute(formname,datename,porm,mdelta)
{
	thisObj = 'document.' + formname + '.' + datename;
	thisObj = eval(thisObj)

	var mdel = parseFloat(mdelta);
	theValue= 'document.' + formname + '.' + datename + '.value'
theValue = eval(theValue)
	
	if(theValue.length <= 0)
	{
		theValue = "#defaultValue#";
	}

Hvalue = theValue.substring(0,2)
Mvalue = theValue.substring(3,5)
Svalue = theValue.substring(6,8)
MRvalue = theValue.substring(8,11)

callHourChange = false;

if (porm=='+') 
{
	MnewValue =  parseFloat(Mvalue) + mdel
	//if (MnewValue<10) {MnewValue = '0' + MnewValue}
	if (MnewValue>=60) 
	{
		//MnewValue = '00';
		MnewValue = (MnewValue-60);
		callHourChange = true;
	}
}
else
{
	MnewValue =  parseFloat(Mvalue) - mdel
	if (MnewValue<0) 
	{
	//MnewValue = 60 - mdel;
	MnewValue = 60 + MnewValue;
	callHourChange = true;
	}
}
if (MnewValue<10) {MnewValue = '0' + MnewValue}

totalValue = Hvalue + ":" + MnewValue + ":" + Svalue + MRvalue;

if(!callHourChange)
{
	totalValue = RTcheckTime(thisObj,totalValue,porm);
}

ievalue = "document." + formname + "." + datename + ".value='" + totalValue + "'";
eval(ievalue)

if(callHourChange)
{
	RTChangeHour(formname,datename,porm)
}

}

function RTChangeSecond(formname,datename,porm,mdelta)
{
	thisObj = 'document.' + formname + '.' + datename;
	thisObj = eval(thisObj)
	
	var mdel = parseFloat(mdelta);
	theValue= 'document.' + formname + '.' + datename + '.value'
	theValue = eval(theValue)
	
	if(theValue.length <= 0)
	{
		theValue = "#defaultValue#";
	}

Hvalue = theValue.substring(0,2)
Mvalue = theValue.substring(3,5)
Svalue = theValue.substring(6,8)
MRvalue = theValue.substring(8,11)

callHourChange = false;

if (porm=='+') 
{
	SnewValue =  parseFloat(Svalue) + mdel
	//if (SnewValue<10) {SnewValue = '0' + SnewValue}
	if (SnewValue>=60) 
	{
		//MnewValue = '00';
		SnewValue = (SnewValue-mdel*60);
		callHourChange = true;
	}
	if (SnewValue<0) {SnewValue=0;}
}
else
{
	SnewValue = parseFloat(Svalue) - mdel
	if (SnewValue<0) 
	{
		//MnewValue = 60 - mdel;
		SnewValue = (60 + SnewValue) % 60;
		callHourChange = true;
	}
}

if (SnewValue<10) {SnewValue = '0' + SnewValue}

totalValue = Hvalue + ":" + Mvalue + ":" + SnewValue + MRvalue;

if(!callHourChange)
{
	totalValue = RTcheckTime(thisObj,totalValue,porm);
}

ievalue = "document." + formname + "." + datename + ".value='" + totalValue + "'";
eval(ievalue)

if (callHourChange == true)
{
	RTChangeMinute(formname,datename,porm,mdel)
}

}

function RTcheckTime(timeObj,timeVal,porm)
{
	var retVal = timeVal;
	var newTime = RTgetMilitaryTime(timeVal);
	var minInterval = timeObj.getAttribute('minInterval');
	var maxInterval = timeObj.getAttribute('maxInterval');
	
	var anewTime = newTime.split(":");	
	var aminInterval = minInterval.split(":");
	var amaxInterval = maxInterval.split(":");
		
	/*
	///old working
	if(!(RTcheckTimelessThan(anewTime,amaxInterval) || RTcheckTimelessThan(aminInterval,anewTime)))
	{
		if(porm == "+")
		{
			retVal = RTgetAMPMTime(minInterval);
		}
		else
		{
			retVal = RTgetAMPMTime(maxInterval);
		}
	}
	///old working end
	*/
	///////////////////////////////////////
	///new
	//if(RTcheckTimelessThan(diSTime,txtTime))
	//if not ((anewTime <= amaxInterval) or (aminInterval <= anewTime))
	//else is (anewTime <= amaxInterval) and (aminInterval <= anewTime)
	//time <= 00:10 and 10 <= time
	
	var outOfRange = false;
	
	if(!((RTcheckTimelessThan(anewTime,amaxInterval) || RTcheckTimelessThan(aminInterval,anewTime))) && RTcheckTimelessThan(amaxInterval,aminInterval))
	{
		outOfRange = true;
	}
	else if(!((RTcheckTimelessThan(anewTime,amaxInterval) && RTcheckTimelessThan(aminInterval,anewTime))) && RTcheckTimelessThan(aminInterval,amaxInterval))
	{
		outOfRange = true;
	}
	
	
	//if(!(RTcheckTimelessThan(anewTime,amaxInterval) || RTcheckTimelessThan(aminInterval,anewTime)))
	if(outOfRange)
	{
		if(porm == "+")
		{
			retVal = RTgetAMPMTime(minInterval);
		}
		else
		{
			retVal = RTgetAMPMTime(maxInterval);
		}
	}
	///new end
	///////////////////////////////////////
	
	//minInterval
	//maxInterval
	
	//alert(timeVal);
	return retVal;
}


function RTgetAMPMTime(sTime)
{	
	if(sTime.length <= 5)
		return "";
	var retVal = "";
	
	var sHr = parseInt(sTime.substr(0,2));	
	var sMn = parseInt(sTime.substr(3,2));
	var sSc = parseInt(sTime.substr(6,2));
	sMn = sMn % 60;
	sSc = sSc % 60;
	
	sMn = "0" + sMn;
	sMn = sMn.substr(sMn.length-2);
	
	sSc = "0" + sSc;
	sSc = sSc.substr(sSc.length-2);
		
	if(sHr > 12)
	{
		sHr = sHr-12;		
		sHr = sHr % 12;
		if(sHr == 0)
			ampm = " AM";
		else
			ampm = " PM";
		sHr = "0" + sHr;
		sHr = sHr.substr(sHr.length-2);
		//retVal = sHr + sTime.substr(sTime.length-6) + " PM";
		
		retVal = sHr + ":" + sMn + ":" + sSc + ampm;
	}
	else
	{
		//retVal = sTime + " AM";
		sHr = sHr % 12;
		sHr = "0" + sHr;
		sHr = sHr.substr(sHr.length-2);
		retVal = sHr + ":" + sMn + ":" + sSc + " AM";
	}	
	
	return retVal;
}


function RTcheckTimelessThan(sTime,gTime)
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

function RTmakeFixedDigits(dig,val,padStr)
{
	var retVal = padStr + val;
	return (retVal.substr(retVal.length-dig));	
}
function RTgetHHMMSSTime()
{
	var retVal = "";
	var tmp;
	var args = arguments;
	for(i=0;i<args.length;i++)
	{
		//tmp = "0" + args[i];
		//retVal = retVal + tmp.substring(tmp.length-2,tmp.length) + ":";
		retVal = retVal + RTmakeFixedDigits(2,args[i],"00") + ":";
	}
	return (retVal.substring(0,retVal.length-1));
}

function RTgetMilitaryTime(sTime)
{
	var retVal = false;
	var spTime = sTime.split(":");
	if(spTime.length >= 3)
	{
		var hr = parseInt(spTime[0],10);
		//if(hr.toString() == spTime[0])
		if(RTmakeFixedDigits(2,hr.toString(),"00") == RTmakeFixedDigits(2,spTime[0],"00"))
		{
			var mn = parseInt(spTime[1],10);			
			if(RTmakeFixedDigits(2,mn.toString(),"00") == RTmakeFixedDigits(2,spTime[1],"00"))
			{
				var sc = parseInt(spTime[2],10);
				var ampm = spTime[2].substr(RTmakeFixedDigits(2,sc.toString(),"00").length);
				ampm = ampm.replace(/(^\s*)|(\s*$)/g, "");
				ampm = ampm.toLowerCase();
				if(/^[\s\t]*?[aApP][mM][\s\t]*?$/.test(ampm))
				{
					//////specified ap/pm
					if(hr >= 0 && hr <= 12 && mn >=0 && mn <=60 && sc >=0 && sc <=60)
					{
						hr = hr + ((ampm=="pm" && hr != 12)?12:0);						
						retVal = RTgetHHMMSSTime(hr,mn,sc);
					}					
				}
				else
				{
					//////not specified ap/pm
					//if(hr <= 24 && mn <=60 && sc <=60)
					if(hr >= 0 && hr <= 24 && mn >=0 && mn <=60 && sc >=0 && sc <=60)
					{
						retVal = RTgetHHMMSSTime(hr,mn,sc);
					}					
				}					
			}
		}
	}		
	return retVal;
}

var intervalID = "";
var imgID = "";
var txtName = "";
var funcID = "";
var frmName = "";
var mDel = "";

function RTstartInterval(funID,formName,tName,incr,mDelta)
{	
	RTstopInterval();
	frmName = formName;
	txtName = tName;
	funcID = funID;
	//imgID = event.srcElement.id;
	imgID = incr;
	mDel = mDelta;
	intervalID = window.setInterval("RTcallChangeHour()",500);
}

function RTstopInterval()
{
	if(intervalID!="")
	{
		window.clearInterval(intervalID);
		intervalID="";		
	}	
}

//document.ondragenter=new Function ("event.returnValue=false;return false;")
//document.ondragover=new Function ("event.returnValue=false;return false;")
//document.ondrop = new Function ("alert();");
document.onmouseup = RTstopInterval;

function RTcallChangeHour()
{
	switch(funcID)
	{
		case 1:
			RTChangeHour(frmName,txtName,imgID);
			break;		
		case 2:
			RTChangeMinute(frmName,txtName,imgID,mDel);
			break;
		case 3:
			RTChangeSecond(frmName,txtName,imgID,mDel);
			break;
		default:
			RTstopInterval();
	}
}
</cfif>


</script>
<cfset Attributes.value=Attributes.hhmmss>
<table border="0" cellspacing="0" cellpadding="0">
<tr>
<td><a href="##" onClick="javascript:RTChangeHour('#Attributes.form#','#Attributes.name#','+')" ><img id="+" onmousedown="javascript:RTstartInterval(1,'#Attributes.form#','#Attributes.name#','+');" onmouseup="javascript:RTstopInterval();" onmouseout="javascript:RTstopInterval();" src="#Attributes.ImagesDir#up3.gif" width=16 height=10 alt="" border="0" title="Increase Hours"></a><br><a href="##" onClick="javascript:RTChangeHour('#Attributes.form#','#Attributes.name#','-')"><img id="-" onmousedown="javascript:RTstartInterval(1,'#Attributes.form#','#Attributes.name#','-');" onmouseup="javascript:RTstopInterval();" onmouseout="javascript:RTstopInterval();" src="#Attributes.ImagesDir#down3.gif" width=16 height=10 alt="" border="0" title="Decrease Hours"></a></td>
<td><input maxInterval="#Attributes.maxInterval#" minInterval="#Attributes.minInterval#" type="text" name="#Attributes.name#" readonly value="#Attributes.value#" style="width: #Attributes.width#;" size="#Attributes.size#"></td>
<td><a href="##" onClick="javascript:RTChangeMinute('#Attributes.form#','#Attributes.name#','+','#Attributes.mdelta#')"><img id="+" onmousedown="javascript:RTstartInterval(2,'#Attributes.form#','#Attributes.name#','+','#Attributes.mdelta#');" onmouseup="javascript:RTstopInterval();" onmouseout="javascript:RTstopInterval();" src="#Attributes.ImagesDir#up3.gif" alt="" border="0" title="Increase Minutes"></a><br><a href="##" onClick="javascript:RTChangeMinute('#Attributes.form#','#Attributes.name#','-','#Attributes.mdelta#')"><img id="-" onmousedown="javascript:RTstartInterval(2,'#Attributes.form#','#Attributes.name#','-','#Attributes.mdelta#');" onmouseup="javascript:RTstopInterval();" onmouseout="javascript:RTstopInterval();" src="#Attributes.ImagesDir#down3.gif" width=16 height=10 alt="" border="0" title="Decrease Minutes"></a></td>
<cfif Attributes.showSeconds>
<td><a href="##" onClick="javascript:RTChangeSecond('#Attributes.form#','#Attributes.name#','+','#Attributes.mdelta#')"><img id="+" onmousedown="javascript:RTstartInterval(3,'#Attributes.form#','#Attributes.name#','+','#Attributes.mdelta#');" onmouseup="javascript:RTstopInterval();" onmouseout="javascript:RTstopInterval();" src="#Attributes.ImagesDir#up3.gif" alt="" border="0" title="Increase Seconds"></a><br><a href="##" onClick="javascript:RTChangeSecond('#Attributes.form#','#Attributes.name#','-','#Attributes.mdelta#')"><img id="-" onmousedown="javascript:RTstartInterval(3,'#Attributes.form#','#Attributes.name#','-','#Attributes.mdelta#');" onmouseup="javascript:RTstopInterval();" onmouseout="javascript:RTstopInterval();" src="#Attributes.ImagesDir#down3.gif" width=16 height=10 alt="" border="0" title="Decrease Seconds"></a></td>
</cfif>
<td><a href="##" onClick="javascript:RTtoggleMeridian('#Attributes.form#','#Attributes.name#','z')"><img src="#Attributes.ImagesDir#up3.gif" width=16 height=10 alt="" border="0" title="Set to 'PM'"></a><br><a href="##" onClick="javascript:RTtoggleMeridian('#Attributes.form#','#Attributes.name#','y')"><img src="#Attributes.ImagesDir#down3.gif" width=16 height=10 alt="" border="0" title="Set to 'AM'"></a></td>

</tr>
</table>
</cfoutput>
<cfset caller.cf_restrictedTimeCalled=true>
