<!---
Id: /CustomTags/CostsHeaderFooter.cfm, v1.1 9/28/00 6:21:24 PM dbabbitt
Description: This is a combined version of the 
	headers and footer includes 
	that produces the navigational bars to 
	the left, top and bottom of the page.
Example: 

         <CF_CostsHeaderFooter Host="#CGI.HTTP_HOST#" PhotoPath="#Access.Image#" FirstName="#Access.First_Name#" LastName="#Access.Last_Name#" AgencyName="#Access.AgencyName#" ProgramName="#Access.ProgramName#" Access="#Access.Access#">
		
         place your content in here...		
		
         </CF_CostsHeaderFooter>
--->

<CFPARAM NAME="Attributes.Host" TYPE="string" DEFAULT="#CGI.HTTP_HOST#">
<CFPARAM NAME="Attributes.PhotoPath" TYPE="string" DEFAULT="http://#Attributes.Host#/_pm/images/no_image_small.gif">
<CFPARAM NAME="Attributes.FirstName" TYPE="string" DEFAULT="Unkown">
<CFPARAM NAME="Attributes.LastName" TYPE="string" DEFAULT="User">
<CFPARAM NAME="Attributes.AgencyName" TYPE="string" DEFAULT="Unknown Agency">
<CFPARAM NAME="Attributes.ProgramName" TYPE="string" DEFAULT="Unkown Program">
<CFPARAM NAME="Attributes.Access" TYPE="numeric" DEFAULT="0">

<CFOUTPUT><CFSWITCH EXPRESSION="#ThisTag.ExecutionMode#"><CFCASE VALUE="start">
	<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0">
		<TR>
			<TD><TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0">
				<TR>
					<TD><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/interf1.gif" WIDTH="12" HEIGHT="12"></TD>
					<TD><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/interf2.gif" WIDTH="79" HEIGHT="12"></TD>
					<TD><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/interf3.gif" WIDTH="15" HEIGHT="12"></TD></TR>
				<TR>
					<TD><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/interf4.gif" WIDTH="12" HEIGHT="79"></TD>
					<TD><IMG SRC="http://#Attributes.Host#/_pm/#Attributes.PhotoPath#" BORDER=0 TITLE="Current user is #Attributes.FirstName# #Attributes.LastName#" WIDTH=79 HEIGHT=79></TD>
					<TD><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/interf5.gif" WIDTH="15" HEIGHT="79"></TD></TR>
				<TR>
					<TD><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/interf6.gif" WIDTH="12" HEIGHT="15"></TD>
					<TD><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/interf7.gif" WIDTH="79" HEIGHT="15"></TD>
					<TD><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/interf8.gif" WIDTH="15" HEIGHT="15"></TD></TR>
				</TABLE></TD>
			<TD BACKGROUND="http://#Attributes.Host#/_pm/images/interf10.gif" WIDTH="100%"><TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0"><TR>
				<TD><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/interf9.gif" WIDTH="14" HEIGHT="106"></TD>
				<TD NOWRAP CLASS="headline">
					<CF_NavBar Position="top" TemplateName="#CGI.SCRIPT_NAME#" Host="#Attributes.Host#" Access="#Attributes.Access#">
					<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
<!--
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
	tick2.innerHTML = '<B STYLE="font-size : 16; color : FFFF00">' + ctime + '</B>';
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
	currentTime = new Date();
	currentMils = Date.parse(currentTime.toLocaleString());
	remainingMils = timeOutMils - currentMils;
	if((remainingMils < thresholdMils) && !alreadyAlerted) {
		window.alert('Your session on this server will expire in ' + eval(thresholdMils / 60 / 1000) + ' minutes!\nPlease save your work now.');
		alreadyAlerted = true;
		}
	timerLoop = setTimeout('changeClock(ch, cm, cs)', 750);
	}
//-->
						</SCRIPT>
					<DIV CLASS="mainhead">#Attributes.FirstName# #Attributes.LastName# - #DateFormat(now(), 'dddd, mmmm d yyyy')# - <SPAN ID="tick2"></SPAN></DIV>
					<DIV CLASS="subhead">#Attributes.AgencyName# - #Attributes.ProgramName#</DIV></TD>
				</TR></TABLE></TD>
			<TD><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/interf11.jpg" WIDTH="58" HEIGHT="106"></TD></TR>
		<TR>
			<TD BACKGROUND="http://#Attributes.Host#/_pm/images/interf13.gif" VALIGN="top">
				<IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/interf12.gif" WIDTH="106" HEIGHT="15">
				<BR>
				<CF_NavBar Position="left" TemplateName="#CGI.SCRIPT_NAME#" Host="#Attributes.Host#" Access="#Attributes.Access#"></TD>
			<TD VALIGN="top" ALIGN="center"></CFCASE><CFCASE VALUE="end"></TD>
			<TD></TD></TR>
		<TR>
			<TD><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/interf14.jpg" WIDTH="91" HEIGHT="60"></TD>
			<TD ALIGN="center"><CF_NavBar Position="bottom" TemplateName="#CGI.SCRIPT_NAME#" Host="#Attributes.Host#" Access="#Attributes.Access#"></TD>
			<TD></TD></TR>
		</TABLE>
	<TABLE WIDTH="100%" BORDER="0" CELLPADDING="0" CELLSPACING="0"><TR>
		<TD><IMG SRC="http://#Attributes.Host#/_pm/images/fill.gif" WIDTH="91" HEIGHT="1"></TD>
		<TD ALIGN="center" WIDTH="100%">
			<A HREF="http://#Attributes.Host#/_pm/administrivia/legal.htm"><IMG SRC="http://#Attributes.Host#/_pm/images/logo_small.gif" BORDER="0" TITLE="Copyright&copy; 1999-2000, Clipboard Solutions, Inc. All Rights Reserved"></A>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
			<BR>
			<A HREF="http://#Attributes.Host#/_pm/administrivia/legal.htm" STYLE="color: ##330099; font-weight: bold;">Copyright&copy; 1999-2000, Clipboard Solutions, Inc. All Rights Reserved </A>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </TD>
		</TR></TABLE>
	</CFCASE></CFSWITCH></CFOUTPUT>

<!---
	Log: /CustomTags/CostsHeaderFooter.cfm
	Revision 1.1 9/28/00 6:20:19 PM dbabbitt
	Now compensating for moving everything 
	down into the _pm subdirectory.
	
	Revision 1.0 9/18/00 7:47:57 AM dbabbitt
	This is a combined version of the 
	headers and footer includes 
	that produces the navigational bars to 
	the left, top and bottom of the page.
	--->