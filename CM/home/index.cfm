<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<CFSET PAGE_TITLE="Call Management">
<HTML>
<HEAD>
	<TITLE>Untitled</TITLE>
	<link href="/cm/common/style/master.css" rel="stylesheet" type="text/css" />
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/cm/common/style/master_style_dynamic.cfm">
	
	<SCRIPT LANGUAGE="JavaScript">
		function loadMenus()
		{
			var source = document.all.xml1;
			var stylesheet = document.all.xsl1;
			document.all.leftlinks.innerHTML = source.transformNode(stylesheet);
		}
	</SCRIPT>

	<LINK REL="stylesheet" TYPE="text/css" HREF="leftmenus/menus.css" />
	<SCRIPT LANGUAGE="JScript" SRC="leftmenus/menus.js"></SCRIPT>
	
</HEAD>

<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" ONLOAD="loadMenus()" LEFTMARGIN="0" TOPMARGIN="0">
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<cfinclude template="/cm/common/Measurements.cfm">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Top Banner																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!------ <div id="topbanner"> 
	<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="5" BGCOLOR="ffffff" WIDTH="100%" height="100%">
		<CFOUTPUT><TR><TD BGCOLOR="Navy" STYLE="color: White; font-weight: bold; font-size: 16px; font-family: Arial;" HEIGHT="25"><A HREF="index.cfm" STYLE="color: white; text-decoration: none;">&nbsp;&nbsp;#DayOfWeekAsString(dayofweek(now()))# - #dateformat(now(),'mmmm d, yyyy')#</A></TD></TR></CFOUTPUT>
	</TABLE>
</div> ----->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Left Links																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<div id="leftlinks" STYLE="z-index: 100;">
</div>
<xml src="Leftmenus/menus.xml" id="xml1"></xml>
<xml src="Leftmenus/menus.xsl" id="xsl1"></xml>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Messager																						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<div id="messagewin">
	<layer visibility=hide>
		<div style="width:107px;" align="right"><a href="#" onMouseover="scrollspeed=-2" onMouseout="scrollspeed=0"><IMG SRC="/cm/images/up_small.gif" ALT="" BORDER="0"></a></div>
	</layer>
	<CFOUTPUT>
	<iframe id="datamain" src="messager/test2.cfm" width=105 height=#leftMessageHeight# marginwidth=0 marginheight=0 hspace=0 vspace=0 frameborder=0 scrolling=no STYLE="border: 1 solid blue;"></iframe>	
	</CFOUTPUT>
	<layer visibility=hide>
		<div style="width:107px;" align="right"><a href="#" onMouseover="scrollspeed=2" onMouseout="scrollspeed=0"><IMG SRC="/cm/images/down_small.gif" ALT="" BORDER="0"></a></div>
	</layer>
</div>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Calendar																						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<div id="calendar"> 
	<CFINCLUDE TEMPLATE="calendar.cfm">
</div>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Top Links																						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!------ <div id="toplinks"> 
	<TABLE WIDTH="90%" BORDER="0" CELLPADDING="1" CELLSPACING="5" BGCOLOR="ffffff">
		<TR>
			<TD CLASS="linklive" HEIGHT="20">new customer</TD>
			<TD CLASS="linkdead">new contact</TD>
			<TD CLASS="linkdead">new activity</TD>
			<TD CLASS="linkdead">new campaign</TD>
			<TD CLASS="linkdead">new task</TD>
		</TR>
	</TABLE>
</div> ----->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main Window --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<div id="content"> 	
	<CFOUTPUT>
	<IFRAME SRC="scorecards/index.cfm?id=#month(thisdate)#/#day(thisdate)#/#year(thisdate)#" NAME="mainwindow" ID="mainwindow" WIDTH="99%" HEIGHT="99%" MARGINWIDTH="4" MARGINHEIGHT="4" FRAMEBORDER="0"></IFRAME>	
	</CFOUTPUT>
</div>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>

