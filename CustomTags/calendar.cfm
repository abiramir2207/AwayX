<!---
	Id: calendar4.cfm, v2.2.4 10/3/00 3:14:01 PM dbabbitt
	Description: This template displays a calendar and 
		sends back to the originating page a 
		command to change the Start input of Attribute.FormName 
		to the date picked.
	--->

<CFSET TESTING="False">
<CFIF TESTING>
	<!--- These are the environmental variables that are sent. --->
	<!--- Relevant CGI Variables: --->
		<CFPARAM NAME="CGI.HTTP_HOST" DEFAULT="davezpc">
		<CFPARAM NAME="CGI.SCRIPT_NAME" DEFAULT="/includes/calendar.cfm">
	<!--- Cookies --->
		<CFPARAM NAME="Cookie.CFTOKEN" DEFAULT="67901898">
		<CFPARAM NAME="Cookie.CFID" DEFAULT="11">
		<CFPARAM NAME="Cookie.LOGON" DEFAULT="Yes">
	</CFIF>

<CFPARAM NAME="Attribute.FormName" TYPE="string" DEFAULT="Attribute.FormName">
<CFPARAM NAME="Attribute.FieldName" TYPE="string" DEFAULT="Start">
<CFPARAM name="Application.DateMask" default="m/d/yyyy">
<CFSET NextWeek=DateAdd('d', 7, Now())>
<!--- Get NextStart to be Sunday by adding the difference --->
<CFPARAM name="NextStart" default="#DateAdd('d', 1-DayOfWeek(NextWeek), NextWeek)#">
<CFSET ScriptName="includes/calendar4.cfm">
<CFIF CGI.SCRIPT_NAME is "/#ScriptName#">
	<CFSET CalendarDate=IIf(ParameterExists(URL.StartDate), 'URL.StartDate', 'Now()')>
	<CFSET PrevMonthString=MonthAsString(DatePart("m", DateAdd("m", -1, CalendarDate)))>
	<CFSET PrevMonth=DateFormat(DateAdd("m", -1, CalendarDate), Application.DateMask)>
	<CFSET NextMonthString=MonthAsString(DatePart("m", DateAdd("m", 1, CalendarDate)))>
	<CFSET NextMonth=DateFormat(DateAdd("m", 1, CalendarDate), Application.DateMask)>
	<CFSET Month=MonthAsString(DatePart("m", CalendarDate))>
	<CFSET MonthNum=Month(CalendarDate)>
	<CFSET Year=DatePart("yyyy", CalendarDate)>
	<CFSET NumOfDays=DaysInMonth(CalendarDate)>
	<CFSET DayOfWeek=DayOfWeek(CalendarDate)>
	<CFSET DayNum=Day(CalendarDate)>
	<CFSET FirstDay=DayOfWeek(MonthNum & "/1/" & Year)>
	<CFSET NumberOfRows=((FirstDay + NumOfDays) / 7) + 1>
	<CFSET FirstRowCount=1>
	<CFSET count=1>
		
	<HTML>
		<HEAD><CFOUTPUT>
			<SCRIPT LANGUAGE="JavaScript">
				<!--
function addDate(thedate) {
	// getAttributesWindow("opener.document.Attribute.FormName", opener.document.Attribute.FormName);
	formated_date = #MonthNum# + "/" + thedate + "/" + #Year#;
	opener.document.Attribute.FormName.Start.value=formated_date;
	close()}
				//-->
				</SCRIPT>
			<!SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript" SRC="../debug.js"></SCRIPT>
			<TITLE>#Month# Calendar</TITLE>
			<LINK REL="STYLESHEET" TYPE="text/css" HREF="../standard.css"></CFOUTPUT></HEAD>
		<BODY BGCOLOR="FFFFFF" WIDTH="90%"><CENTER><TABLE BORDER="0" CELLPADDING="0" CELLSPACING="1" BGCOLOR="black" WIDTH="235">
			<TR>
				<!--- Using fully qualified URL for the href --->
				<TD HEIGHT="20" ALIGN="center" BGCOLOR="F2F2F2"><CFOUTPUT><FONT SIZE="2"><A HREF="http://#CGI.HTTP_HOST#/#ScriptName#?StartDate=#PrevMonth#" TITLE="Changes this calendar to the month of #PrevMonthString#"><B>
					#Left(PrevMonthString, 3)#</B></A></FONT></CFOUTPUT></TD>
				<TD COLSPAN="5" ALIGN="center" BGCOLOR="FFFF80" HEIGHT="20"><FONT SIZE="3"><CFOUTPUT><B>
					#Month# #Year#</B></CFOUTPUT></FONT></TD>
				<!--- Using fully qualified URL for the href --->
				<TD HEIGHT="20" ALIGN="center" BGCOLOR="F2F2F2"><CFOUTPUT><FONT SIZE="2"><A HREF="http://#CGI.HTTP_HOST#/#ScriptName#?StartDate=#NextMonth#" TITLE="Changes this calendar to the month of #NextMonthString#"><B>
					#Left(NextMonthString, 3)#</B></A></FONT></CFOUTPUT></TD>
				</TR>
			<TR ALIGN="center" BGCOLOR="F2F2F2">
				<TD HEIGHT="20"><B><FONT SIZE="2">Sun</FONT></B></TD>
				<TD><B><FONT SIZE="2">Mon</FONT></B></TD>
				<TD><B><FONT SIZE="2">Tue</FONT></B></TD>
				<TD><B><FONT SIZE="2">Wed</FONT></B></TD>
				<TD><B><FONT SIZE="2">Thu</FONT></B></TD>
				<TD><B><FONT SIZE="2">Fri</FONT></B></TD>
				<TD><B><FONT SIZE="2">Sat</FONT></B></TD>
				</TR>
			<CFLOOP INDEX="row" FROM="1" TO="#NumberOfRows#"><TR><CFLOOP INDEX="cell" FROM="1" TO="7">
				<CFIF count GT NumOfDays><CFBREAK></CFIF>
				<CFIF FirstRowCount LT FirstDay>
					<CFOUTPUT><TD WIDTH="40" VALIGN="middle" ALIGN="right" HEIGHT="20">
						&nbsp;</TD></CFOUTPUT>
					<CFSET FirstRowCount=IncrementValue(FirstRowCount)>
					<CFELSE>
					<CFOUTPUT><CFIF ((count IS DayNum) AND (Month(Now()) IS MonthNum)) AND (Year IS DatePart("yyyy", Now()))>
						<TD WIDTH="40" VALIGN="middle" ALIGN="right" BGCOLOR="yellow" HEIGHT="20"><B><A HREF="javascript:addDate(#count#)" TITLE="Changes the start date to #MonthNum#/#count#/#Year#."><FONT SIZE="2"><CENTER>
							#count#</CENTER></FONT></A></B></TD>
						<CFELSE>
						<TD WIDTH="40" VALIGN="middle" ALIGN="right" BGCOLOR="white" HEIGHT="20"><B><A HREF="javascript:addDate(#count#)" TITLE="Changes the start date to #MonthNum#/#count#/#Year#."><FONT SIZE="2"><CENTER>
							#count#</CENTER></FONT></A></B></TD>
						</CFIF></CFOUTPUT>
					<CFSET count=IncrementValue(count)></CFIF>
				</CFLOOP></TR></CFLOOP>
			</TABLE></CENTER></BODY>
		</HTML>
	<CFELSE>
	<DIV STYLE="font-weight:lighter; margin :10px">
		<!--- Setup width and height of the pop-up calendar window --->
		<cfset Popup_Width=275>
		<cfset Popup_Height=200>
		<!SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript" SRC="../debug.js"></SCRIPT>
		<!--- Create the appropriate link to the calendar window --->
		<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript"><CFOUTPUT>
var windowLeft=(window.screen.width/2)-(#Popup_Width#/2);
var windowTop=(window.screen.height/2)-(#Popup_Height#/2);
function popUpMonthlyCalendar() {
	var newWind=window.open('../#ScriptName#','remote','width=#Popup_Width#,height=#Popup_Height#,left=windowLeft,top=windowTop');
	if (newWind.opener == null) {newWind.opener = window}
	// getAttributesWindow("newWind", newWind);
	// getAttributesWindow("document.Attribute.FormName", document.Attribute.FormName);
	}
			</CFOUTPUT></SCRIPT>
		<A HREF="javascript:popUpMonthlyCalendar()" TITLE="This pops up a monthly calendar"><IMG SRC="../images/calendar2.gif" HEIGHT=21 WIDTH=21 TITLE="Click here to select the First Day" BORDER=0></A>
		<CFOUTPUT><INPUT TYPE="text" NAME="Start" SIZE="10" VALUE="#DateFormat(NextStart, Application.DateMask)#" ReadOnly></CFOUTPUT></DIV>
	</CFIF>

<!---
	Log: calendar4.cfm
	Revision 2.3 6/27/00 11:21:18 AM dbabbitt
	Now assuming that the Start input is in 
	Attribute.FormName.
	
	Revision 2.2 Tue, Jun 13, 2000 13:51:03 dbabbitt
	Removed all references to Cookies.
	
	Revision 2.1 5/11/00 10:36:42 AM dbabbitt
	Added tool tips to explain each link.
	
	Revision 2.0 5/10/00 11:39:23 PM dbabbitt
	Added the ability to display a link to 
	itself. Must be used inside a form in 
	the same subdirectory as itself. Fills in 
	an input named Start.
	
	Revision 1.0 
	This template displays a calendar and 
	sends back to the originating page a 
	command to change the Start input 
	to the date picked.
	--->
