<cfparam name="Attributes.color" default="000000">
<cfparam name="Attributes.size" default="-1">
<cfparam name="Attributes.date" default="#DateFormat(Now(),"mm/dd/yyyy")#">
<cfparam name="Attributes.time" default="#TimeFormat(Now(),"HH:mm:ss")#">
<cfparam name="Attributes.firstTime" default="#TimeFormat(Now(),"HH:mm:ss")#">
<cfparam name="Attributes.name" default="time_1_1_1">

<cfset defaultTime="00:00:00">
<cfset defaultDate="#DateFormat(Now(),"mm/dd/yyyy")#">

<!-------------------- Check time --------------------->
<cfset bErr=false>
<cfif ListLen(Attributes.time,":") EQ 3>
	<cfif isNumeric(ListGetAt(Attributes.time,1,":")) AND isNumeric(ListGetAt(Attributes.time,2,":")) AND isNumeric(ListGetAt(Attributes.time,3,":"))>
		<cfif (isNumeric(ListGetAt(Attributes.time,1,":")) LT 0) OR (isNumeric(ListGetAt(Attributes.time,1,":")) GT 23)>
			<cfset bErr=true>
		</cfif>
		<cfif (isNumeric(ListGetAt(Attributes.time,2,":")) LT 0) OR (isNumeric(ListGetAt(Attributes.time,2,":")) GT 60)>
			<cfset bErr=true>
		</cfif>
		<cfif (isNumeric(ListGetAt(Attributes.time,3,":")) LT 0) OR (isNumeric(ListGetAt(Attributes.time,3,":")) GT 60)>
			<cfset bErr=true>
		</cfif>
	<cfelse>
		<cfset bErr=true>
	</cfif>	
<cfelse>
	<cfset bErr=true>
</cfif>
<cfif bErr>
	<cfset Attributes.time=defaultTime>
</cfif>

<!-------------------- End Check time --------------------->

<!--------------------  Check date --------------------->
<cfset bErr=false>
<cfif ListLen(Attributes.date,"/") EQ 3>
	<cfif isNumeric(ListGetAt(Attributes.date,1,"/")) AND isNumeric(ListGetAt(Attributes.date,2,"/")) AND isNumeric(ListGetAt(Attributes.date,3,"/"))>
		<cfif (isNumeric(ListGetAt(Attributes.date,1,"/")) LT 0) OR (isNumeric(ListGetAt(Attributes.date,1,"/")) GT 12)>
			<cfset bErr=true>
		</cfif>
		<cfif (isNumeric(ListGetAt(Attributes.date,2,"/")) LT 0) OR (isNumeric(ListGetAt(Attributes.date,2,"/")) GT 31)>
			<cfset bErr=true>
		</cfif>
		<cfif (isNumeric(ListGetAt(Attributes.date,3,"/")) LT 1900) OR (isNumeric(ListGetAt(Attributes.date,3,"/")) GT 9999)>
			<cfset bErr=true>
		</cfif>
	<cfelse>
		<cfset bErr=true>
	</cfif>	
<cfelse>
	<cfset bErr=true>
</cfif>
<cfif bErr>
	<cfset Attributes.date=defaultDate>
</cfif>
<!-------------------- End Check date --------------------->

<cfoutput>
<script language="JavaScript">
<!--
/* IE 11 (and beyond) will be "Trident" */
if (navigator.appVersion.indexOf("MSIE") != -1 || navigator.appVersion.indexOf("Trident") != -1 )
{
	document.write(' <span id="clock#Attributes.name#">#Attributes.firstTime#</span>');
}
else if(navigator.appName == "Netscape") 
{
	document.write('<layer id="clock#Attributes.name#" top="0">#Attributes.firstTime#</layer>');
}


var incr=0;


function upclock#Attributes.name#()
{
	//var tags_before_clock = "<b><font face='Verdana, Arial, Helvetica, sans-serif' color='#Attributes.color#'>"	
	var tags_before_clock = "<b><font color='#Attributes.color#'>"	
	var tags_after_clock  = "</font></b>"
	var mmddyyyyDate = "#Attributes.date#";
	
	//var dte = new Date("8/1/2002 01:44:38 AM");
	var dte = new Date(#ListGetAt(Attributes.date,3,"/")#,#ListGetAt(Attributes.date,1,"/")#,#ListGetAt(Attributes.date,2,"/")#,#ListGetAt(Attributes.time,1,":")#,#ListGetAt(Attributes.time,2,":")#,#ListGetAt(Attributes.time,3,":")#);
	
	dte.setTime(dte.getTime() + (incr * 1000));
	var hrs = dte.getHours();
	var min = dte.getMinutes();
	var sec = dte.getSeconds();
	var wkday;
	
	var apm;
	
	if (12 <= hrs) 
	{
		apm=" PM";
		hrs-=12;
	}
	else 
	{
		apm=" AM";
	}
	
	if (hrs==0) hrs=12;
	if (hrs<=9) hrs="0"+hrs;
	if (min<=9) min="0"+min;
	if (sec<=9) sec="0"+sec;
	
	incr++;
	/* IE 11 (and beyond) will be "Trident" */
	if (navigator.appVersion.indexOf("MSIE") != -1 || navigator.appVersion.indexOf("Trident") != -1)
	{
		clock#Attributes.name#.innerHTML = tags_before_clock+hrs+':'+min+':'+sec+' '+apm+tags_after_clock;
	}
	else if(navigator.appName == "Netscape") 
	{
		document.clock#Attributes.name#.document.write(tags_before_clock+hrs+':'+min+':'+sec+' '+apm+tags_after_clock);		
		document.clock#Attributes.name#.document.close();
	}
	


}

setInterval("upclock#Attributes.name#()",1000);
//-->
</script>
</cfoutput>