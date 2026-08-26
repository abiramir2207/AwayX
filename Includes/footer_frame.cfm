<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Untitled</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
<!--- Dev Note: Milan; 7996 --->
	<script language="javascript">
			function goBack()
			{
				if(parent.frames[1].document.referrer.indexOf('scorecard/scorecard3.cfm') != -1)
				{
						parent.frames[1].history.back();	
				}
				else
				{	
						history.back();
				}
			}
	</script>
<!--- End Note: Milan; 7996 --->
</HEAD>

<BODY BGCOLOR="#FFFFEA" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" BOTTOMMARGIN="0" TOPMARGIN="0" LEFTMARGIN="0" RIGHTMARGIN="0" MARGINHEIGHT="0" MARGINWIDTH="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Header Goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<table border="0" cellpadding="0" cellspacing="0" width="100%" STYLE="border-top: solid 1px navy;">
  <tr>
    <td WIDTH="90" nowrap><CFOUTPUT><img src="#Application.CompanyLogo#" alt=""  border="0"></CFOUTPUT>&nbsp;</td>

<cfif appSettings.getdisplayclientshelpdeskinfo() EQ 1>
<td STYLE="color: gray; font-size:10px;" nowrap><cfoutput>#appSettings.getclientshelpdeskinfo()#</cfoutput> </td>
</cfif>
<!--- /images/Header_Footer_New/awayx_logo.gif --->
	
    <td ALIGN="center" VALIGN="Middle" width="100%"><CFIF application.returned_customer_setting.show_news EQ 1><iframe id="news_Iframe" src="/News_Ticker/News.cfm"  style="position:relative; width:100%; height:25; z-index:1;border: 0px none #000000;" SCROLLING="No" allowTransparency="true"></iframe></CFIF></td>
	
<!--- DEV NOTE: DAA; D14743
    <td VALIGN="bottom" NOWRAP WIDTH="550" ALIGN="Right"><!--- WIDTH="273" --->
		<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="1">
			<TR>
				<TD ALIGN="right" NOWRAP>&nbsp;&nbsp;&nbsp;
					<FONT COLOR="Red"><B>|</B></FONT> 
					<A HREF="/common_files/privacy_statement.cfm" TARGET="mywindowname">privacy statement</A> 
					<FONT COLOR="Red"><B>|</B></FONT>
					<A HREF="javascript: goBack();"}>prev</A> 
					<FONT COLOR="Red"><B>|</B></FONT> 
					<A HREF="javascript:history.forward();">next</A> 
					<FONT COLOR="Red"><B>|</B></FONT> 
					<A HREF="/common_files/contact_us.cfm" TARGET="mywindowname">contact us</A> 
					<FONT COLOR="Red"><B>|</B></FONT> 
					<A HREF="/logoff.cfm?id=<CFOUTPUT>#request.AccessStructure.User_ID#</CFOUTPUT>">logoff</A> 
					<FONT COLOR="Red"><B>|</B></FONT>
				</TD>
			</TR>
			<TR>
				<TD ALIGN="right">
					<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="3">
					<A HREF="/common_files/copyright.cfm" TARGET="mywindowname" STYLE="color: gray; font-size:10px;"><CFINCLUDE TEMPLATE="/includes/copyright.cfm"></A><!--- Copyright© 2000-2003, AwayX, Inc. All Rights Reserved --->
				</TD>
			</TR>
		</TABLE>
	</td>
 --->
  </tr>
</table>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Footer Goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>