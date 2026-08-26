<CFSETTING ENABLECFOUTPUTONLY="YES">
<!---
Id: /CustomTags/CostsNavBar.cfm, v1.2.0 10/17/00 3:45:51 PM dbabbitt
Description: This module provides the user with a navigational aid 
             conditioned on their access level. This is a modified 
			 version of the nav_bar.cfm page in that it surrounds 
			 the gifs with a table. Requires the template_name 
			 module.
Example: 

			 <CF_CostsNavBar Position="top" TemplateName="main.cfm" Host="#CGI.HTTP_HOST#" Access="#Access.Access#">
--->

<CFPARAM NAME="Attributes.Position" TYPE="string" DEFAULT="top">
<CFPARAM NAME="Attributes.TemplateName" TYPE="string" DEFAULT="#CGI.SCRIPT_NAME#">
<CFPARAM NAME="Attributes.Host" TYPE="string" DEFAULT="#CGI.HTTP_HOST#">
<CFPARAM NAME="Attributes.Access" TYPE="numeric" DEFAULT="0">

<!--- Get the appropriate images for the sides of the nav bar --->
<CFSWITCH EXPRESSION="#Attributes.Position#">
	<CFCASE VALUE="top">
		<CFSET Variables.NavBarVersion="2"></CFCASE>
	<CFCASE VALUE="bottom">
		<CFSET Variables.NavBarVersion=""></CFCASE>
	<CFCASE VALUE="left"><CFOUTPUT><SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
<!--
image1 = new Image();
image1.src = webRoot + 'images/home_green1.gif';
image1on = new Image();
image1on.src = webRoot + 'images/home_green2.gif';
image2 = new Image();
image2.src = webRoot + 'images/search_green1.gif';
image2on = new Image();
image2on.src = webRoot + 'images/search_green2.gif';
image3 = new Image();
image3.src = webRoot + 'images/emailus_green1.gif';
image3on = new Image();
image3on.src = webRoot + 'images/emailus_green2.gif';
image4 = new Image();
image4.src = webRoot + 'images/emergency_green1.gif';
image4on = new Image();
image4on.src = webRoot + 'images/emergency_green2.gif';
image5 = new Image();
image5.src = webRoot + 'images/sysadmin_green1.gif';
image5on = new Image();
image5on.src = webRoot + 'images/sysadmin_green2.gif';
image6 = new Image();
image6.src = webRoot + 'images/training_green1.gif';
image6on = new Image();
image6on.src = webRoot + 'images/training_green2.gif';
imageStay = '';

function imageon(name) {
	if(imageStay != name) {document[name].src = eval(name + 'on.src');}
	}
function imageoff(name) {
	if(imageStay != name){document[name].src = eval(name + '.src');}
	}
function stay(name) {
	document[name].src = eval(name + 'stay.src');
	if(imageStay != name) {
		if(imageStay != '') {document[imageStay].src = eval(imageStay + '.src');}
		}
	imageStay = name;
	}
//-->
		</SCRIPT></CFOUTPUT></CFCASE></CFSWITCH>

<!--- The table width here is dependent on the access level --->
<CFSET Variables.NavBarWidth="#Evaluate('17+2+45+2+51+2+68+2+91+2+56+2+46+2+17')#">
<CFIF Attributes.Access GTE 3><CFSET Variables.NavBarWidth="#Evaluate('Variables.NavBarWidth+73+2+52+2')#"></CFIF>

<CFOUTPUT><DIV CLASS="navbar"><NOBR><CFIF NOT (Compare(Attributes.Position, 'top') AND CompareNoCase(Attributes.Position, 'bottom'))><TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="center" WIDTH="#Variables.NavBarWidth#"><TR ALIGN="center" VALIGN="top">
	<TD WIDTH="17" ALIGN="center" VALIGN="top" NOWRAP><IMG SRC="http://#Attributes.Host#/_pm/images/corner_l#Variables.NavBarVersion#.gif" WIDTH="17"></TD>
	<TD WIDTH="2" ALIGN="center" VALIGN="top" NOWRAP><IMG SRC="http://#Attributes.Host#/_pm/images/divider.gif" WIDTH="2"></TD>
	<CFIF Not CompareNoCase(Attributes.TemplateName, 'main.cfm')>
		<TD WIDTH="45" ALIGN="center" VALIGN="top" NOWRAP><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/home2.gif" WIDTH="45" HEIGHT="24"></TD>
		<CFELSE>
		<TD WIDTH="45" ALIGN="center" VALIGN="top" NOWRAP><A HREF="http://#Attributes.Host#/_pm/main.cfm?id=#RandRange(111111111, 999999999)#" TARGET="_top"><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/home1.gif" WIDTH="45" HEIGHT="24"></A></TD></CFIF>
	<TD WIDTH="2" ALIGN="center" VALIGN="top" NOWRAP><IMG SRC="http://#Attributes.Host#/_pm/images/divider.gif" WIDTH="2"></TD>
	<CFIF Not CompareNoCase(Attributes.TemplateName, 'user_management.cfm')>
		<TD WIDTH="51" ALIGN="center" VALIGN="top" NOWRAP><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/management2.gif" WIDTH="51" HEIGHT="24" TITLE="View Staff, Virtual Conference Room, Available Shifts"></TD>
		<CFELSE>
		<TD WIDTH="51" ALIGN="center" VALIGN="top" NOWRAP><A HREF="http://#Attributes.Host#/_pm/people/user_management.cfm?id=#RandRange(111111111, 999999999)#" TARGET="_top"><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/management1.gif" WIDTH="51" HEIGHT="24" TITLE="View Staff, Virtual Conference Room, Available Shifts"></A></TD></CFIF>
	<TD WIDTH="2" ALIGN="center" VALIGN="top" NOWRAP><IMG SRC="http://#Attributes.Host#/_pm/images/divider.gif" WIDTH="2"></TD>
	<CFIF Attributes.Access GTE 3>
		<CFIF Not CompareNoCase(Attributes.TemplateName, 'shift_management.cfm')>
			<TD WIDTH="73" ALIGN="center" VALIGN="top" NOWRAP><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/scheduling2.gif" WIDTH="73" HEIGHT="24" TITLE="Time Scheduler, Vacation Scheduler"></TD>
			<CFELSE>
			<TD WIDTH="73" ALIGN="center" VALIGN="top" NOWRAP><A HREF="http://#Attributes.Host#/_pm/schedules/shift_management.cfm?id=#RandRange(111111111, 999999999)#" TARGET="_top"><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/scheduling1.gif" WIDTH="73" HEIGHT="24" TITLE="Time Scheduler, Vacation Scheduler"></A></TD></CFIF>
		<TD WIDTH="2" ALIGN="center" VALIGN="top" NOWRAP><IMG SRC="http://#Attributes.Host#/_pm/images/divider.gif" WIDTH="2"></TD></CFIF>
	<CFIF Not CompareNoCase(Attributes.TemplateName, 'time_entry_management.cfm')>
		<TD WIDTH="68" ALIGN="center" VALIGN="top" NOWRAP><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/time_entry2.gif" WIDTH="68" HEIGHT="24" TITLE="Daily Time Entry System, Daily Time Approval System"></TD>
		<CFELSE>
		<TD WIDTH="68" ALIGN="center" VALIGN="top" NOWRAP><A HREF="http://#Attributes.Host#/_pm/time/time_entry_management.cfm?id=#RandRange(111111111, 999999999)#" TARGET="_top"><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/time_entry1.gif" WIDTH="68" HEIGHT="24" TITLE="Daily Time Entry System, Daily Time Approval System"></A></TD></CFIF>
	<TD WIDTH="2" ALIGN="center" VALIGN="top" NOWRAP><IMG SRC="http://#Attributes.Host#/_pm/images/divider.gif" WIDTH="2"></TD>
	<CFIF Attributes.Access GTE 3>
		<CFIF Not CompareNoCase(Attributes.TemplateName, 'report_management.cfm')>
			<TD WIDTH="52" ALIGN="center" VALIGN="top" NOWRAP><IMG BORDER=0 SRC="http://#Attributes.Host#/_pm/images/reports2.gif" width=52 height=24 TITLE="Reports..."></TD>
			<CFELSE>
			<TD WIDTH="52" ALIGN="center" VALIGN="top" NOWRAP><A HREF="http://#Attributes.Host#/_pm/reports/report_management.cfm?id=#RandRange(111111111, 999999999)#" TARGET="_top"><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/reports1.gif" WIDTH="52" HEIGHT="24" TITLE="Reports..."></A></TD></CFIF>
		<TD WIDTH="2" ALIGN="center" VALIGN="top" NOWRAP><IMG SRC="http://#Attributes.Host#/_pm/images/divider.gif" WIDTH="2"></TD></CFIF>
	<CFIF Not CompareNoCase(Attributes.TemplateName, 'corporate.cfm')>
		<TD WIDTH="91" ALIGN="center" VALIGN="top" NOWRAP><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/corporate2.gif" WIDTH="91" HEIGHT="24" TITLE="Policy Manual, Expenses Report"></TD>
		<CFELSE>
		<TD WIDTH="91" ALIGN="center" VALIGN="top" NOWRAP><A HREF="http://#Attributes.Host#/_pm/administrivia/corporate.cfm?id=#RandRange(111111111, 999999999)#" TARGET="_top"><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/corporate1.gif" WIDTH="91" HEIGHT="24" TITLE="Policy Manual, Expenses Report"></A></TD></CFIF>
	<TD WIDTH="2" ALIGN="center" VALIGN="top" NOWRAP><IMG SRC="http://#Attributes.Host#/_pm/images/divider.gif" WIDTH="2"></TD>
	<CFIF Not CompareNoCase(Attributes.TemplateName, 'training_management.cfm')>
		<TD WIDTH="56" ALIGN="center" VALIGN="top" NOWRAP><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/training2.gif" WIDTH="56" HEIGHT="24" TITLE="Training"></TD>
		<CFELSE>
		<TD WIDTH="56" ALIGN="center" VALIGN="top" NOWRAP><A HREF="http://#Attributes.Host#/_pm/skills/training_management.cfm?id=#RandRange(111111111, 999999999)#" TARGET="_top"><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/training1.gif" WIDTH="56" HEIGHT="24" TITLE="Training"></A></TD></CFIF>
	<TD WIDTH="2" ALIGN="center" VALIGN="top" NOWRAP><IMG SRC="http://#Attributes.Host#/_pm/images/divider.gif" WIDTH="2"></TD>
	<TD WIDTH="46" ALIGN="center" VALIGN="top" NOWRAP><A HREF="http://#Attributes.Host#/logoff.cfm" TARGET="_top"><IMG BORDER="0" SRC="http://#Attributes.Host#/_pm/images/logoff1.gif" WIDTH="46" HEIGHT="24" TITLE="Leave the system"></A></TD>
	<TD WIDTH="2" ALIGN="center" VALIGN="top" NOWRAP><IMG SRC="http://#Attributes.Host#/_pm/images/divider.gif" WIDTH="2"></TD>
	<TD WIDTH="17" ALIGN="center" VALIGN="top" NOWRAP><IMG SRC="http://#Attributes.Host#/_pm/images/corner_r#Variables.NavBarVersion#.gif" WIDTH="17"></TD></TR></TABLE>
	<CFELSEIF NOT CompareNoCase(Attributes.Position, 'left')>
	<CFIF NOT CompareNoCase(Attributes.TemplateName, 'main.cfm')>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
	<IMG SRC="http://#Attributes.Host#/_pm/images/home_green2.gif" BORDER="0" TITLE="Home" WIDTH="50" HEIGHT="50">
	<CFELSE>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
	<A HREF="http://#Attributes.Host#/_pm/main.cfm?id=#RandRange(111111111, 999999999)#" onMouseOver="imageon('image1');" onMouseOut="imageoff('image1')"><IMG SRC="http://#Attributes.Host#/_pm/images/home_green1.gif" BORDER="0" NAME="image1" TITLE="Home" WIDTH="50" HEIGHT="50"></A></CFIF>
<BR>
<CFIF NOT CompareNoCase(Attributes.TemplateName, "search_tool.cfm")>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
	<IMG SRC="http://#Attributes.Host#/_pm/images/search_green2.gif" BORDER="0" TITLE="Search" WIDTH="50" HEIGHT="50">
	<CFELSE>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
	<A HREF="http://#Attributes.Host#/_pm/administrivia/search_tool.cfm" onMouseOver="imageon('image2');" onMouseOut="imageoff('image2')"><IMG SRC="http://#Attributes.Host#/_pm/images/search_green1.gif" BORDER="0" NAME="image2" TITLE="Search" WIDTH="50" HEIGHT="50"></A></CFIF>
<BR>
<CFIF NOT CompareNoCase(Attributes.TemplateName, "contact_us.cfm")>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
	<IMG SRC="http://#Attributes.Host#/_pm/images/emailus_green2.gif" BORDER="0" TITLE="Contact Us" WIDTH="50" HEIGHT="50">
	<CFELSE>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
	<A HREF="http://#Attributes.Host#/_pm/administrivia/contact_us.cfm" onMouseOver="imageon('image3');" onMouseOut="imageoff('image3')"><IMG SRC="http://#Attributes.Host#/_pm/images/emailus_green1.gif" BORDER="0" NAME="image3" TITLE="Contact Us" WIDTH="50" HEIGHT="50"></A></CFIF>
<BR>
<CFIF NOT CompareNoCase(Attributes.TemplateName, "emergency_response_plan.cfm")>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
	<IMG SRC="http://#Attributes.Host#/_pm/images/emergency_green2.gif" BORDER="0" TITLE="Emergency Procedures" WIDTH="50" HEIGHT="50">
	<CFELSE>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
	<A HREF="http://#Attributes.Host#/_pm/administrivia/emergency_response_plan.cfm" onMouseOver="imageon('image4');" onMouseOut="imageoff('image4')"><IMG SRC="http://#Attributes.Host#/_pm/images/emergency_green1.gif" BORDER="0" NAME="image4" TITLE="Emergency Procedures" WIDTH="50" HEIGHT="50"></A></CFIF>
<BR>
<CFIF NOT CompareNoCase(Attributes.TemplateName, "training_management.cfm")>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
	<IMG SRC="http://#Attributes.Host#/_pm/images/training_green2.gif" BORDER="0" TITLE="FastTrack Training(SM)" WIDTH="50" HEIGHT="50">
	<CFELSE>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
	<A HREF="http://#Attributes.Host#/_pm/skills/training_management.cfm" onMouseOver="imageon('image6');" onMouseOut="imageoff('image6')"><IMG SRC="http://#Attributes.Host#/_pm/images/training_green1.gif" BORDER="0" NAME="image6" TITLE="FastTrack Training(SM)" WIDTH="50" HEIGHT="50"></A></CFIF>
<BR>
<CFIF Attributes.Access gte 3><CFIF NOT CompareNoCase(Attributes.TemplateName, "sysadmin.cfm")>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
	<IMG SRC="http://#Attributes.Host#/_pm/images/sysadmin_green2.gif" BORDER="0" TITLE="System Administration Functions" WIDTH="50" HEIGHT="50">
	<CFELSE>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
	<A HREF="http://#Attributes.Host#/_pm/_pm/administrivia/sysadmin.cfm" onMouseOver="imageon('image5');" onMouseOut="imageoff('image5')"><IMG SRC="http://#Attributes.Host#/_pm/images/sysadmin_green1.gif" BORDER="0" NAME="image5" TITLE="System Administration Functions" WIDTH="50" HEIGHT="50"></A></CFIF></CFIF></CFIF></NOBR></DIV></CFOUTPUT>

<!---
	Log: /CustomTags/CostsNavBar.cfm
	Revision 1.2 10/17/00 3:45:17 PM flopes
	Now logging off links the user to a 
	special page that prevents the user 
	from backing in.
	
	Revision 1.1 9/28/00 6:23:48 PM dbabbitt
	Compensating for moving everything down 
	into the _pm subdirectory.
	
	Revision 1.0 8/12/00 8:00:48 AM dbabbitt
	This module provides the user with a 
	navigational aid conditioned on their 
	access level. This is a modified 
	version of the nav_bar.cfm page in 
	that it surrounds the gifs with a 
	table.
	--->
<CFSETTING ENABLECFOUTPUTONLY="NO">