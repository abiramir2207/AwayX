<cfsilent>
<!---#### 
* "DSTDates.cfm" file
* Written by: Sarge
* Date: March 4, 2007
* Version: 1.1
* 
* This file confirms whether or not the JVM DST information 
* has been updated for the 2007 US Daylight Saving Time (DST) 
* changes created by the US Energy Policy Act of 2005.
* 
* ColdFusion systems in time zones affected by daylight savings 
* should display DST ON for date and times between 
* 2:00AM on the 2nd Sunday in March (03/11/2007)
* and 2:00AM on the 2nd Sunday in November (11/04/2007).
*
* This file will run on ColdFusion MX 6.0 and greater.
*
* This file was written for testing purposes 
* and is not intended for production systems. 
* Furthermore, Adobe does not offer any guarantees or warranties.
* Use at own risk. 
*
 ####--->
	<cfscript>
		/*#### ColdFusion Version Number ####*/
		cfVersion = Replace(Left(server.ColdFusion.ProductVersion, 5), ',', '.', 'all');
		if(NOT ListLast(cfVersion, '.') )
			/*#### Delete trailing .0 off version number ####*/
			cfVersion = ListDeleteAt(cfVersion, 3, '.');
		
		today = now();
		/*#### ColdFusion Time Zone Information ####*/
		cfTZ = getTimeZoneInfo();
		if(cfTZ.isDSTOn) {
			tzColor = "green";
		}	else {
			tzColor = "red";
		}
		/*#### Daylight Savings Time Dates ####*/
		/*#### New DST Starts the 2nd Sunday in March ####*/
		newDstStart = createDateTime("2007", "03", "11", "03", "00", "00");
		/*#### New DST Ends the 1st Sunday in November ####*/
		newDstEnd = createDateTime("2007", "11", "04", "03", "00", "00");
		/*#### Old DST would have started 1st Sunday in April ####*/
		oldDstStart = createDateTime("2007", "04", "01", "03", "00", "00");
		/*#### Old DST would have ended the last Sunday in October ####*/
		oldDstEnd = createDateTime("2007", "10", "28", "03", "00", "00");
		
		/*#### Java objects ####*/
		/*#### System object ####*/
		sysObj = createObject("java", "java.lang.System");
		/*#### Gregorian calendar object ####*/
		gregCal = createObject("java", "java.util.GregorianCalendar");
		/*#### Time Zone object ####*/
		tz = createObject("java", "java.util.TimeZone");

	  /*#### Today's offset ####*/
		gregCal.setTime(today);
    todayOffset=gregCal.get(gregCal.DST_OFFSET)/(60*60*1000);
    /*#### New DST Start offset ####*/
    gregCal.setTime(newDstStart);
    newDSTStartOffset=gregCal.get(gregCal.DST_OFFSET)/(60*60*1000);
    /*#### New DST End offset ####*/
    gregCal.setTime(newDstEnd);
    newDstEndOffset=gregCal.get(gregCal.DST_OFFSET)/(60*60*1000);
		/*#### Old DST Start offset ####*/
    gregCal.setTime(oldDstStart);
    oldDstStartOffset=gregCal.get(gregCal.DST_OFFSET)/(60*60*1000);
		/*#### Old DST End offset ####*/
    gregCal.setTime(oldDstEnd);
    oldDstEndOffset=gregCal.get(gregCal.DST_OFFSET)/(60*60*1000);
  </cfscript>
</cfsilent><!---<cfdump var="#tz.Default.getDefault()#">--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>ColdFusion MX <cfoutput>#cfVersion#</cfoutput>: Date Test</title>
	<style type="text/css">
		.no {color:#FF0000}
		.yes {color:#009900}
		.blue {color:#0000FF}
	</style>
</head>

<body>

<table width="200" border="1" style="border-style:solid; border-width:thin;">
  <tr>
  	<th>&nbsp;</th>
    <th valign="top" nowrap>Today</th>
    <th valign="top" nowrap>March 11<br>(New DST Start)</th>
    <th valign="top" nowrap>Apri1<br>(Old DST Start)</th>
    <th valign="top" nowrap>October 28<br>(Old DST End)</th>
    <th valign="top" nowrap>November 4<br>(New DST End)</th>
  </tr>
<CFOUTPUT>  <tr>
  	<th>Dates</th>
  	<td nowrap>#dateFormat(today, 'mm/dd/yyyy')#<br>
		 #timeFormat(today, 'long')#</td>
    <td nowrap>#dateFormat(newDstStart, 'mm/dd/yyyy')#<br>
		 #timeFormat(newDstStart, 'long')#</td>
    <td nowrap>#dateFormat(oldDstStart, 'mm/dd/yyyy')#<br>
		 #timeFormat(oldDstStart, 'long')#</td>
    <td nowrap>#dateFormat(oldDstEnd, 'mm/dd/yyyy')#<br>
		 #timeFormat(oldDstEnd, 'long')#</td>
    <td nowrap>#dateFormat(newDstEnd, 'mm/dd/yyyy')#<br>
		 #timeFormat(newDstEnd, 'long')#</td>
  </tr>
  <tr>
  	<th nowrap>DST ON</th>
  	<td class="#YesNoFormat(todayOffset)#">#YesNoFormat(todayOffset)#</td>
    <td class="#YesNoFormat(newDSTStartOffset)#">#YesNoFormat(newDSTStartOffset)#</td>
    <td class="#YesNoFormat(oldDstStartOffset)#">#YesNoFormat(oldDstStartOffset)#</td>
    <td class="#YesNoFormat(oldDstEndOffset)#">#YesNoFormat(oldDstEndOffset)#</td>
    <td class="#YesNoFormat(newDstEndOffset)#">#YesNoFormat(newDstEndOffset)#</td>
  </tr>

</table>
<p><strong>Java System Properties</strong><br />
   Vendor: #sysObj.getProperty("java.vm.vendor")#<br />
   JVM Version: #sysObj.getProperty("java.runtime.version")#<br />
   OS: #sysObj.getProperty("os.name")#<br />
   OS Arch: #sysObj.getProperty("os.arch")#</p>
<p><strong>Test Date/Time:</strong> #today#</p>
<p><strong>ColdFusion Time Zone Info:</strong><br />
DST On: <span class="#tzColor#">#cfTZ.isDSTOn#</span><br />
UTC Hour Offset: #cfTZ.utcHourOffset#<br />
UTC Minute Offset: #cfTZ.utcMinuteOffset#<br />
UTC Total Offset: #cfTZ.utcTotalOffset#</p>

<p><strong>CreateDateTime: </strong>#createDateTime(year(today), month(today), day(today), hour(today), minute(today), second(today))#<br />

<p><strong>DateConvert:</strong><br />
<strong>Local2UTC:</strong> <span class="blue">#dateConvert("local2UTC", today)#</span> &nbsp;
<strong>UTC2Local:</strong> <span class="blue">#dateConvert("utc2Local", today)#</span></p>
<cfif left(server.ColdFusion.ProductVersion, 1) eq 5><strong>Local2UTC:</strong> 
<cfif cfTZ.isDSTOn> #dateAdd('h', -1, dateConvert("local2UTC", today))#<cfelse>#dateConvert("local2UTC", today)#</cfif>&nbsp;
<strong>UTC2Local:</strong> <cfif cfTZ.isDSTOn>#dateAdd('h', 1, dateConvert("UTC2Local", today))#<cfelse>#dateConvert("UTC2Local", today)#</cfif>
#dateConvert("local2UTC", dateAdd('h', -1, today))#
</cfif>
</CFOUTPUT>
</body>
</html>
