<CFSETTING ENABLECFOUTPUTONLY="YES">
<!---
Id: /CustomTags/CostsNavBar2.cfm, v2.2.1 10/24/00 11:31:50 AM dbabbitt
Description: This module provides the user with a navigational aid 
             conditioned on their access level. This is a modified 
			 version of the nav_bar.cfm page in that it surrounds the 
			 gifs with a table. Requires the template_name module.
Example: 

			 <CF_CostsNavBar2 TemplateName="main.cfm" Host="#CGI.HTTP_HOST#" Access="#Access.Access#" LogoImage="http://#CGI.HTTP_HOST#/_pm/images/pm_logo.gif" FirstName="#Access.First_Name#" LastName="#Access.Last_Name#" AgencyName="#Access.AgencyName#" ProgramName="#Access.ProgramName#">
--->

<CFIF NOT IsDefined('Cookie.User_Info')><CFLOCATION URL="http://#Attributes.Host#/index.htm" ADDTOKEN="No"></CFIF>

<CFPARAM NAME="Attributes.TemplateName" TYPE="string" DEFAULT="#CGI.SCRIPT_NAME#">
<CFPARAM NAME="Attributes.Host" TYPE="string" DEFAULT="#CGI.HTTP_HOST#">
<CFPARAM NAME="Attributes.Access" TYPE="numeric" DEFAULT="0">
<CFPARAM NAME="Attributes.LogoImage" TYPE="string" DEFAULT="http://#Attributes.Host#/_pm/images/pm_logo.gif">
<CFPARAM NAME="Attributes.FirstName" TYPE="string" DEFAULT="Unkown">
<CFPARAM NAME="Attributes.LastName" TYPE="string" DEFAULT="User">
<CFPARAM NAME="Attributes.AgencyName" TYPE="string" DEFAULT="Unknown Agency">
<CFPARAM NAME="Attributes.ProgramName" TYPE="string" DEFAULT="Unkown Program">

<CFPARAM NAME="Caller.ModuleColor" DEFAULT="66CC00">

<CFOUTPUT><DIV CLASS="navbar"><NOBR><TABLE BORDER="0">
	<TR>
		<TD><A HREF="http://#attributes.host#/_pm/main.cfm?id=#RandRange(111111111, 999999999)#" TARGET="_top" CLASS="navbar"><IMG SRC="#Attributes.LogoImage#" WIDTH="95" HEIGHT="92" TITLE="Home" BORDER="0"></A></TD>
		<TD WIDTH="100%" CLASS="headline"><TABLE BGCOLOR="White" WIDTH="100%">
			<TR>
				<CFIF Not CompareNoCase(Attributes.TemplateName, '/administrivia/about_us.cfm')>
					<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B>About CSI</B></FONT></TD>
					<CFELSE>
					<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B><A HREF="http://#attributes.host#/_pm/administrivia/about_us.cfm?id=#RandRange(111111111, 999999999)#" TARGET="_top" CLASS="navbar">About CSI</A></B></FONT></TD></CFIF>
				<CFIF Not CompareNoCase(Attributes.TemplateName, '/administrivia/contact_us.cfm')>
					<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B>Contact Us</B></FONT></TD>
					<CFELSE>
					<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B><A HREF="http://#Attributes.Host#/_pm/administrivia/contact_us.cfm" TARGET="_top" CLASS="navbar">Contact Us</A></B></FONT></TD></CFIF>
				<!--- Have to be Program Manager or above to see this --->
				<CFIF (Attributes.Access GTE 2000)><CFIF (Not CompareNoCase(Attributes.TemplateName, '/schedules/shift_management.cfm'))>
					<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B>Scheduling</B></FONT></TD>
					<CFELSE>
					<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B><A HREF="http://#Attributes.Host#/_pm/schedules/shift_management.cfm?id=#RandRange(111111111, 999999999)#" TARGET="_top" CLASS="navbar">Scheduling</A></B></FONT></TD></CFIF></CFIF>
				<CFIF Not CompareNoCase(Attributes.TemplateName, '/time/time_entry_management.cfm')>
					<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B>Time Entry</B></FONT></TD>
					<CFELSE>
					<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B><A HREF="http://#Attributes.Host#/_pm/time/time_entry_management.cfm?id=#RandRange(111111111, 999999999)#" TARGET="_top" CLASS="navbar">Time Entry</A></B></FONT></TD></CFIF>
				<!--- Have to be Program Manager or above to see this --->
				<CFIF (Attributes.Access GTE 2000)><CFIF (Not CompareNoCase(Attributes.TemplateName, '/reports/report_management.cfm'))>
					<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B>Reports</B></FONT></TD>
					<CFELSE>
					<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B><A HREF="http://#Attributes.Host#/_pm/reports/report_management.cfm?id=#RandRange(111111111, 999999999)#" TARGET="_top" CLASS="navbar">Reports</A></B></FONT></TD></CFIF></CFIF>
				<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B><A HREF="http://#Attributes.Host#/central_station.cfm" TARGET="_top" CLASS="navbar">CSI Central</A></B></FONT></TD>
				<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B><A HREF="http://#Attributes.Host#/logoff.cfm" CLASS="navbar">Logoff</A></B></FONT></TD></TR></TABLE>
			<TABLE BGCOLOR="White" WIDTH="100%"><TR>
				<CFIF Not CompareNoCase(Attributes.TemplateName, '/administrivia/corporate.cfm')>
					<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B>Administration</B></FONT></TD>
					<CFELSE>
					<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B><A HREF="http://#Attributes.Host#/_pm/administrivia/corporate.cfm?id=#RandRange(111111111, 999999999)#" TARGET="_top" CLASS="navbar">Administration</A></B></FONT></TD></CFIF>
				<CFIF Not CompareNoCase(Attributes.TemplateName, '/people/user_management.cfm')>
					<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B>People</B></FONT></TD>
					<CFELSE>
					<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B><A HREF="http://#Attributes.Host#/_pm/people/user_management.cfm?id=#RandRange(111111111, 999999999)#" TARGET="_top" CLASS="navbar">People</A></B></FONT></TD></CFIF>
				<CFIF Not CompareNoCase(Attributes.TemplateName, '/administrivia/search_tool.cfm')>
					<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B>Search</B></FONT></TD>
					<CFELSE>
					<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B><A HREF="http://#Attributes.Host#/_pm/administrivia/search_tool.cfm" TARGET="_top" CLASS="navbar">Search</A></B></FONT></TD></CFIF>
				<CFIF Not CompareNoCase(Attributes.TemplateName, '/administrivia/emergency_response_plan.cfm')>
					<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B>Emergency Procedures</B></FONT></TD>
					<CFELSE>
					<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B><A HREF="http://#Attributes.Host#/_pm/administrivia/emergency_response_plan.cfm" TARGET="_top" CLASS="navbar">Emergency Procedures</A></B></FONT></TD></CFIF>
				<!--- Have to be Program Manager or above to see this --->
				<CFIF (Attributes.Access GTE 2000)><CFIF Not CompareNoCase(Attributes.TemplateName, '/administrivia/sysadmin.cfm')>
					<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B>Communications</B></FONT></TD>
					<CFELSE>
					<TD BGCOLOR="66CC00" ALIGN="center"><FONT COLOR="White"><B><A HREF="http://#Attributes.Host#/_pm/administrivia/sysadmin.cfm" TARGET="_top" CLASS="navbar">Communications</A></B></FONT></TD></CFIF></CFIF></TR></TABLE>
			<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
function changeClock(hours, minutes, seconds) {
	clearTimeout('timerLoop');
	var dn = 'AM';
	var ctime;
	var chours = '' + hours;
	var cminutes = '' + minutes;
	var cseconds = '' + seconds;
	
	if(hours>12) {dn = 'PM'; chours = hours-12}
	if(hours==0) {chours = 12}
	if(minutes<=9) {cminutes = '0' + minutes}
	if(seconds<=9) {cseconds = '0' + seconds}
	ctime = chours + ':' + cminutes + ':' + cseconds + ' ' + dn;
	tick2.innerHTML = '<B CLASS="mainhead">' + ctime + '</B>';
	/* add one second */
	cs = parseInt(seconds) + 1;
	cm = parseInt(minutes);
	ch = parseInt(hours);
	/* prepare the second for the next round */
	if (cs > 59) {
		cm = cm + 1;
		cs = 0;
	    }
	/* prepare the minute for the next round */
	if (cm > 59) {
		ch = ch + 1;
		cm = 0;
	    }
	/* prepare the hour for the next round */
	if (ch > 23) {
		ch = 0;
	    }
	/* start the next round */
	<!--- No longer needed as we are not alerting users anymore --->
	<!--- currentTime = new Date();
	currentTime = new Date(currentTime.getFullYear(), currentTime.getMonth(), currentTime.getDate(), ch, cm, cs, 0);
	currentMils = Date.parse(currentTime.toLocaleString());
	var remainingMils = timeOutMils - currentMils;
	if((remainingMils < thresholdMils) && !alreadyAlerted) {
		window.alert('Your session on this server will expire in ' + eval(thresholdMils / 60 / 1000) + ' minutes!\nPlease save your work now.');
		alreadyAlerted = true;
		} --->
	/* It takes a minimum of 380 milliseconds to get down here from Application.cfm */
	timerLoop = setTimeout('changeClock(ch, cm, cs)', 1000 - 190);
	}
				</SCRIPT>
			<DIV CLASS="mainhead">#Attributes.FirstName# #Attributes.LastName# - #DateFormat(now(), 'dddd, mmmm d yyyy')# - <SPAN ID="tick2"></SPAN></DIV>
			<DIV CLASS="subhead">#Attributes.AgencyName# - #Attributes.ProgramName#</DIV></TD>
		</TR>
	</TABLE></NOBR></DIV></CFOUTPUT>

<!---
	Log: /CustomTags/CostsNavBar2.cfm
	Revision 2.2 10/24/00 11:30:58 AM dbabbitt
	Changed the name of the wddx cookie to 
	user info.
	
	Revision 2.1 10/17/00 3:43:23 PM flopes
	Now logging off links the user to a 
	special page that prevents the user 
	from backing in.
	
	Revision 2.0 9/28/00 5:34:29 PM dbabbitt
	Now down a directory and handling user 
	logging functions more simply.
	
	Revision 1.6 9/27/00 6:05:20 PM dbabbitt
	Added module color.
	
	Revision 1.5 9/26/00 7:16:20 PM dbabbitt
	Standardized link position to the rest 
	of the modules. The System 
	Administration Functions is now called 
	Communications.
	
	Revision 1.4 9/25/00 3:06:07 PM dbabbitt
	Now the system administration link needs 
	program manager access rights.
	
	Revision 1.3 9/25/00 12:31:06 PM dbabbitt
	Added link to central station.
	
	Revision 1.2 9/25/00 12:16:54 PM dbabbitt
	Now it conforms to the updated user 
	rights table.
	
	Revision 1.1 9/18/00 5:13:20 PM dbabbitt
	Added left navbar as a second table.
	
	Revision 1.0 9/18/00 12:22:41 PM dbabbitt
	This module provides the user with a 
	navigational aid conditioned on their 
	access level. This is a modified 
	version of the the previous custom tag 
	with a different style.
	--->
<CFSETTING ENABLECFOUTPUTONLY="NO">