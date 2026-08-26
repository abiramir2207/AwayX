<!---
Id: LeftTopTabbedPane.cfm, v1.0.1 8/24/00 11:21:57 PM dbabbitt
Description: This is a combined version of the tab_top_new and 
             tab_bottom_new includes that produces a thin gray 
			 bordered pane with a title positioned below the 
			 top tab and justified left.
Example: 

         <CF_LeftTopTabbedPane Title="Step 1 of 2" TabWidth="100%" ToolTip="Don't eat yellow snow...">
		
         place your content in here...		
		
         </CF_LeftTopTabbedPane>
--->

<CFPARAM NAME="Attributes.Title" TYPE="string" DEFAULT="">
<CFPARAM NAME="Attributes.TabWidth" TYPE="string" DEFAULT="100%">
<CFPARAM NAME="Attributes.ToolTip" TYPE="string" DEFAULT="">
<CFOUTPUT><CFSWITCH EXPRESSION="#ThisTag.ExecutionMode#"><CFCASE VALUE="start">
	<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="center" WIDTH="#Attributes.TabWidth#"><TR>
		<TD BACKGROUND="http://#CGI.HTTP_HOST#/images/tab_bl1.gif"><IMG BORDER="0" SRC="http://#CGI.HTTP_HOST#/images/fill.gif" WIDTH="16" HEIGHT="38"></TD>
		<TD BACKGROUND="http://#CGI.HTTP_HOST#/images/tab_bl2.gif"><IMG BORDER="0" SRC="http://#CGI.HTTP_HOST#/images/fill.gif" WIDTH="6" HEIGHT="38"></TD>
		<TD ALIGN="right" BACKGROUND="http://#CGI.HTTP_HOST#/images/tab_bl3.gif"><IMG BORDER="0" SRC="http://#CGI.HTTP_HOST#/images/fill.gif" WIDTH="26" HEIGHT="38"></TD>
		<TD ALIGN="center" NOWRAP BACKGROUND="http://#CGI.HTTP_HOST#/images/tab_bl4.gif" TITLE=""><B><FONT COLOR="Red" SIZE="3">#Attributes.Title#</FONT></B></TD>
		<TD BACKGROUND="http://#CGI.HTTP_HOST#/images/tab_bl5.gif"><IMG BORDER="0" SRC="http://#CGI.HTTP_HOST#/images/fill.gif" WIDTH="23" HEIGHT="38"></TD>
		<TD BACKGROUND="http://#CGI.HTTP_HOST#/images/tab_bl6.gif" WIDTH="#Attributes.TabWidth#"><IMG BORDER="0" SRC="http://#CGI.HTTP_HOST#/images/fill.gif" WIDTH="6" HEIGHT="38"></TD>
		<TD BACKGROUND="http://#CGI.HTTP_HOST#/images/tab_bl7.gif"><IMG BORDER="0" SRC="http://#CGI.HTTP_HOST#/images/fill.gif" WIDTH="16" HEIGHT="38"></TD></TR></TABLE>
	<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="center" WIDTH="#Attributes.TabWidth#"><TR>
		<TD BACKGROUND="http://#CGI.HTTP_HOST#/images/tab_bl8.gif"><IMG BORDER="0" SRC="http://#CGI.HTTP_HOST#/images/fill.gif" WIDTH="16" HEIGHT="107"></TD>
		<TD COLSPAN="5" WIDTH="#Attributes.TabWidth#" ALIGN="center"></CFCASE><CFCASE VALUE="end"></TD>
		<TD BACKGROUND="http://#CGI.HTTP_HOST#/images/tab_bl9.gif"><IMG BORDER="0" SRC="http://#CGI.HTTP_HOST#/images/fill.gif" WIDTH="16" HEIGHT="107"></TD></TR></TABLE>
	<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="center" WIDTH="#Attributes.TabWidth#"><TR>
		<TD BACKGROUND="http://#CGI.HTTP_HOST#/images/tab_bl10.gif"><IMG BORDER="0" SRC="http://#CGI.HTTP_HOST#/images/fill.gif" WIDTH="16" HEIGHT="15"></TD>
		<TD COLSPAN="5" BACKGROUND="http://#CGI.HTTP_HOST#/images/tab_bl11.gif" WIDTH="#Attributes.TabWidth#"><IMG BORDER="0" SRC="http://#CGI.HTTP_HOST#/images/fill.gif" WIDTH="57" HEIGHT="15"></TD>
		<TD BACKGROUND="http://#CGI.HTTP_HOST#/images/tab_bl12.gif"><IMG BORDER="0" SRC="http://#CGI.HTTP_HOST#/images/fill.gif" WIDTH="16" HEIGHT="15"></TD></TR></TABLE>
	</CFCASE></CFSWITCH></CFOUTPUT>

<!---
	Log: LeftTopTabbedPane.cfm
	Revision 1.0 8/24/00 11:05:19 PM dbabbitt
	This is a combined version of the 
	tab_top_new and tab_bottom_new includes 
	that produces a thin gray bordered pane 
	with a title in the top tab justified 
	left.
	--->

