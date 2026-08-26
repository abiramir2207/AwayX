<!---
	Id: /CustomTags/LeftTopBorderedPane.cfm, v1.4.0 1/29/2001 3:02:08 PM AM rroderick
	Description: 
		This is a combined version of the folder_top and folder_bottom includes that produces a thin blue bordered pane with a title in the top border justified left.
	Example: 
		<CF_LeftTopBorderedPane Title="Location Creation Tool" Width="26%">
			place your content in here...		
		</CF_LeftTopBorderedPane>
	Note: Can't format this template in the normal way because it messes up the layout!!
	--->

<CFPARAM NAME="Attributes.Title" TYPE="string" DEFAULT="">
<CFPARAM NAME="Attributes.Width" TYPE="string" DEFAULT="#Evaluate(Round(1.1*Len(Attributes.Title))+2)#%">
<CFPARAM NAME="Attributes.OuterAlign" TYPE="string" DEFAULT="center">
<CFPARAM NAME="Attributes.Align" TYPE="string" DEFAULT="left">
<CFPARAM NAME="Attributes.InnerAlign" TYPE="string" DEFAULT="#Attributes.Align#">
<CFPARAM NAME="Attributes.Font" TYPE="string" DEFAULT="FF0000">
<CFPARAM NAME="Attributes.BGCOLOR" TYPE="string" DEFAULT="white">

<CFOUTPUT><CFSWITCH EXPRESSION="#ThisTag.ExecutionMode#"><CFCASE VALUE="start"><TABLE WIDTH="#Attributes.Width#" BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="#Attributes.OuterAlign#" BGCOLOR="#Attributes.BGCOLOR#">
	<TR>
		<TD BACKGROUND="http://#CGI.HTTP_HOST#/_pm/images/FOLDER_BLUE1.gif"><IMG border="0" SRC="http://#CGI.HTTP_HOST#/_pm/images/FILL.gif" WIDTH="8" HEIGHT="20"></TD>
		<TD background="http://#CGI.HTTP_HOST#/_pm/images/FOLDER_BLUE2.gif"><FONT color="#Attributes.Font#" FACE="Arial"><SPAN STYLE="background-color: White; font-size: 11pt;">&nbsp;&nbsp;<B>#Attributes.Title#</B>&nbsp;&nbsp;</SPAN></FONT></TD>
		<TD background="http://#CGI.HTTP_HOST#/_pm/images/FOLDER_BLUE3.gif"><IMG border="0" SRC="http://#CGI.HTTP_HOST#/_pm/images/FILL.gif" WIDTH="8" HEIGHT="20"></TD></TR>
	<TR>
		<TD background="http://#CGI.HTTP_HOST#/_pm/images/FOLDER_BLUE4.gif"><IMG border="0" SRC="http://#CGI.HTTP_HOST#/_pm/images/FILL.gif" WIDTH="8" HEIGHT="8"></TD>
		<TD width="100%" ALIGN="#Attributes.InnerAlign#"></CFCASE><CFCASE VALUE="end"></TD>
		<TD background="http://#CGI.HTTP_HOST#/_pm/images/FOLDER_BLUE5.gif"><IMG border="0" SRC="http://#CGI.HTTP_HOST#/_pm/images/FILL.gif" WIDTH="8" HEIGHT="8"></TD></TR>
	<TR>
		<TD background="http://#CGI.HTTP_HOST#/_pm/images/FOLDER_BLUE6.gif"><IMG border="0" SRC="http://#CGI.HTTP_HOST#/_pm/images/FILL.gif" WIDTH="8" HEIGHT="8"></TD>
		<TD background="http://#CGI.HTTP_HOST#/_pm/images/FOLDER_BLUE7.gif"><IMG border="0" SRC="http://#CGI.HTTP_HOST#/_pm/images/FILL.gif" WIDTH="21" HEIGHT="8"></TD>
		<TD background="http://#CGI.HTTP_HOST#/_pm/images/FOLDER_BLUE8.gif"><IMG border="0" SRC="http://#CGI.HTTP_HOST#/_pm/images/FILL.gif" WIDTH="8" HEIGHT="8"></TD></TR>
	</TABLE></CFCASE></CFSWITCH></CFOUTPUT>

<!---
	Log: LeftTopBorderedPane.cfm
	Revision 1.4 1/29/2001 3:01:25 PM rroderick
	Added FONT and BGCOLOR attributes to tag/backwards compatible.
	
	Revision 1.3 1/17/2001 10:41:23 AM dbabbitt
	Added inner and outer align attributes.
	
	Revision 1.2 9/28/00 6:27:02 PM dbabbitt
	Compensating for moving everything down 
	into the _pm subdirectory.
	
	Revision 1.1 9/18/00 5:35:00 PM dbabbitt
	Added table align attribute.
	
	Revision 1.0 8/15/00 4:16:36 PM dbabbitt
	This is a combined version of the 
	folder_top and folder_bottom includes 
	that produces a thin blue bordered pane 
	with a title in the top border 
	justified left.
	--->