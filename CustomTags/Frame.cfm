
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Do not format this template in the normal way because it messes up the layout!!			   --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFPARAM NAME="Attributes.Title" TYPE="string" DEFAULT="">
<CFPARAM NAME="Attributes.Width" TYPE="string" DEFAULT="#Evaluate(Round(1.1*Len(Attributes.Title))+2)#%">
<CFPARAM NAME="Attributes.OuterAlign" TYPE="string" DEFAULT="center">
<CFPARAM NAME="Attributes.Align" TYPE="string" DEFAULT="left">
<CFPARAM NAME="Attributes.InnerAlign" TYPE="string" DEFAULT="#Attributes.Align#">
<CFPARAM NAME="Attributes.Font" TYPE="string" DEFAULT="EA7500">
<CFPARAM NAME="Attributes.FontSize" TYPE="string" DEFAULT="9">
<CFPARAM NAME="Attributes.BGCOLOR" TYPE="string" DEFAULT="white">
<CFPARAM NAME="Attributes.Height" TYPE="string" DEFAULT="50">

<CFOUTPUT><CFSWITCH EXPRESSION="#ThisTag.ExecutionMode#"><CFCASE VALUE="start"><TABLE WIDTH="#Attributes.Width#" BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="#Attributes.OuterAlign#" BGCOLOR="#Attributes.BGCOLOR#">
	<TR>
		<TD BACKGROUND="http://#CGI.HTTP_HOST#/images/FOLDER_BLUE1.gif"><IMG border="0" SRC="http://#CGI.HTTP_HOST#/images/FILL.gif" WIDTH="8" HEIGHT="20"></TD>
		<TD background="http://#CGI.HTTP_HOST#/images/FOLDER_BLUE2.gif"><FONT color="#Attributes.Font#" FACE="Verdana"><SPAN STYLE="background-color: White; font-size: #Attributes.FontSize#pt;">&nbsp;&nbsp;<B>#Attributes.Title#</B>&nbsp;&nbsp;</SPAN></FONT></TD>
		<TD background="http://#CGI.HTTP_HOST#/images/FOLDER_BLUE3.gif"><IMG border="0" SRC="http://#CGI.HTTP_HOST#/images/FILL.gif" WIDTH="8" HEIGHT="20"></TD></TR>
	<TR>
		<TD background="http://#CGI.HTTP_HOST#/images/FOLDER_BLUE4.gif"><IMG border="0" SRC="http://#CGI.HTTP_HOST#/images/FILL.gif" WIDTH="8" HEIGHT="8"></TD>
		<TD width="100%" ALIGN="#Attributes.InnerAlign#" HEIGHT="#Attributes.Height#"></CFCASE><CFCASE VALUE="end"></TD>
		<TD background="http://#CGI.HTTP_HOST#/images/FOLDER_BLUE5.gif"><IMG border="0" SRC="http://#CGI.HTTP_HOST#/images/FILL.gif" WIDTH="8" HEIGHT="8"></TD></TR>
	<TR>
		<TD background="http://#CGI.HTTP_HOST#/images/FOLDER_BLUE6.gif"><IMG border="0" SRC="http://#CGI.HTTP_HOST#/images/FILL.gif" WIDTH="8" HEIGHT="8"></TD>
		<TD background="http://#CGI.HTTP_HOST#/images/FOLDER_BLUE7.gif"><IMG border="0" SRC="http://#CGI.HTTP_HOST#/images/FILL.gif" WIDTH="21" HEIGHT="8"></TD>
		<TD background="http://#CGI.HTTP_HOST#/images/FOLDER_BLUE8.gif"><IMG border="0" SRC="http://#CGI.HTTP_HOST#/images/FILL.gif" WIDTH="8" HEIGHT="8"></TD></TR>
	</TABLE></CFCASE></CFSWITCH></CFOUTPUT>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->