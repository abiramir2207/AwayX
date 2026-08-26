<!---
Id: /CustomTags/CostsHeaderFooter2.cfm, v1.2.3 10/3/00 9:30:20 AM dbabbitt
Description: This is a modified version of the old costs header footer 
             done up in a new style.
Example: 

         <CF_CostsHeaderFooter2 Host="#CGI.HTTP_HOST#" PhotoPath="#Access.Image#" FirstName="#Access.First_Name#" LastName="#Access.Last_Name#" AgencyName="#Access.AgencyName#" ProgramName="#Access.ProgramName#" Access="#Access.Access#">
		
         place your content in here...		
		
         </CF_CostsHeaderFooter2>
--->

<CFPARAM NAME="Attributes.Host" TYPE="string" DEFAULT="#CGI.HTTP_HOST#">
<CFPARAM NAME="Attributes.PhotoPath" TYPE="string" DEFAULT="http://#Attributes.Host#/_pm/images/no_image_small.gif">
<CFPARAM NAME="Attributes.FirstName" TYPE="string" DEFAULT="Unkown">
<CFPARAM NAME="Attributes.LastName" TYPE="string" DEFAULT="User">
<CFPARAM NAME="Attributes.AgencyName" TYPE="string" DEFAULT="Unknown Agency">
<CFPARAM NAME="Attributes.ProgramName" TYPE="string" DEFAULT="Unkown Program">
<CFPARAM NAME="Attributes.Access" TYPE="numeric" DEFAULT="0">

<CFPARAM NAME="Caller.ModuleColor" DEFAULT="66CC00">

<CFOUTPUT><CFSWITCH EXPRESSION="#ThisTag.ExecutionMode#">
	<CFCASE VALUE="start"><CF_CostsNavBar2 TemplateName="#CGI.SCRIPT_NAME#" Host="#Attributes.Host#" Access="#Attributes.Access#" LogoImage="http://#Attributes.Host#/_pm/images/pm_logo.gif" FirstName="#Attributes.FirstName#" LastName="#Attributes.LastName#" AgencyName="#Attributes.AgencyName#" ProgramName="#Attributes.ProgramName#"></CFCASE>
	<CFCASE VALUE="end">
		<CFIF NOT Compare(CGI.SCRIPT_NAME, '/_pm/administrivia/about_us.cfm')><TABLE ALIGN="center" BGCOLOR="White" CELLPADDING="1" CELLSPACING="2" WIDTH="90%">
			<TR>
				<TD BGCOLOR="#Variables.ModuleColor#" ALIGN="center" VALIGN="bottom"><A HREF="about_us.cfm?M=1" STYLE="color: White;"><B>&nbsp;Program Manager<FONT SIZE="-2">(sm)</FONT></A>&nbsp;</B></TD>
				<TD BGCOLOR="#Variables.ModuleColor#" ALIGN="center" VALIGN="bottom"><A HREF="about_us.cfm?M=2" STYLE="color: White;"><B>&nbsp;FastTrack Training<FONT SIZE="-2">(sm)</FONT></A>&nbsp;</B></TD>
				<TD BGCOLOR="#Variables.ModuleColor#" ALIGN="center" VALIGN="bottom"><A HREF="about_us.cfm?M=3" STYLE="color: White;"><B>&nbsp;Quality Assurance</A>&nbsp;</B></TD>
				<TD BGCOLOR="#Variables.ModuleColor#" ALIGN="center" VALIGN="bottom"><A HREF="about_us.cfm?M=4" STYLE="color: White;"><B>&nbsp;Individual Record</A>&nbsp;</B></TD>
				<TD BGCOLOR="#Variables.ModuleColor#" ALIGN="center" VALIGN="bottom"><A HREF="about_us.cfm?M=5" STYLE="color: White;"><B>&nbsp;Human Resources</A>&nbsp;</B></TD>
				<TD BGCOLOR="#Variables.ModuleColor#" ALIGN="center" VALIGN="bottom"><A HREF="about_us.cfm?M=6" STYLE="color: White;"><B>&nbsp;Financial Manager</A>&nbsp;</B></TD></TR></TABLE></CFIF>
		<TABLE WIDTH="100%" BORDER="0" CELLPADDING="0" CELLSPACING="0"><TR>
			<TD><IMG SRC="http://#Attributes.Host#/_pm/images/fill.gif" WIDTH="91" HEIGHT="1"></TD>
			<TD ALIGN="center" WIDTH="100%">
				<A HREF="http://#Attributes.Host#/_pm/administrivia/legal.htm"><IMG SRC="http://#Attributes.Host#/_pm/images/logo_small.gif" BORDER="0" ALT="Copyright&copy; 1999-2000, Clipboard Solutions, Inc. All Rights Reserved"></A>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
				<BR>
				<A HREF="http://#Attributes.Host#/_pm/administrivia/legal.htm" CLASS="subhead">Copyright&copy; 1999-2000, Clipboard Solutions, Inc. All Rights Reserved </A>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD></TR></TABLE></CFCASE></CFSWITCH></CFOUTPUT>

<!---
	Log: /CustomTags/CostsHeaderFooter2.cfm
	Revision 1.2 10/2/00 9:10:25 AM dbabbitt
	Added module color and now 
	incorporating the corporate solutions 
	navbar as a footer when in "about us".
	
	Revision 1.1 9/28/00 6:13:22 PM dbabbitt
	Now compensating for everything moving 
	down into the _pm subdirectory.
	
	Revision 1.0 9/18/00 12:51:45 PM dbabbitt
	This is a modified version of the old 
	costs header footer done up in a new 
	style.
	--->