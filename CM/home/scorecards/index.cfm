<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<CFPARAM NAME="id" DEFAULT=#now()#>
<CFOUTPUT>
<HTML>
<HEAD>
	<TITLE>Untitled</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="scorecards.css">
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="scorecard_style_dynamic.cfm">
</HEAD>


<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<div id="topbanner"> 
	<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="2" BGCOLOR="ffffff" WIDTH="100%" height="100%">
		<TR><TD BGCOLOR="Navy" STYLE="color: White; font-weight: bold; font-size: 16px; font-family: Arial;" HEIGHT="25"><A HREF="index.cfm" STYLE="color: white; text-decoration: none;">&nbsp;&nbsp;#DayOfWeekAsString(dayofweek(id))# - #dateformat(id,'mmmm d, yyyy')#</A></TD></TR>
	</TABLE>
</div>

<DIV ID="tasks">
<table border="0" cellpadding="3" cellspacing="0" width="100%" height="100%">
  <tr>
    <td bgcolor="##4169E1" colspan="100"><b><font color="##FFFFFF">Tasks</font></b></td>
  </tr>
  <tr valign="top">
    <td STYLE="border:1 solid silver;" height="100%">	
	<!------ Task Scorecard ----->
	<!------ 
	<cfset  taskMang = CreateObject("component","cm.task.com.TaskManager").init() />
	<cfset StSearch = StructNew()>
	<cfset StSearch.User_ID = request.AccessStructure.User_ID>
	<cfset StSearch.Task_Start_Date = id>		
	<cfset 	qSearchResult = taskMang.getByFilter(StSearch)>	
	<CFOUTPUT>
	<cfloop query="qSearchResult">		
		<a href="/cm/handler.cfm?command=ceTask&id=#CM_Task_ID#">#Task_Name#</a><br>
	</cfloop>	
	</CFOUTPUT>
	 ----->
	&nbsp;
	</td>
  </tr>
</table>
</DIV>


<DIV ID="activities">
<table border="0" cellpadding="3" cellspacing="0" width="100%" height="100%">
  <tr>
    <td bgcolor="##4169E1" colspan="100"><b><font color="##FFFFFF">Activities</font></b></td>
  </tr>
  <tr valign="top">
    <td STYLE="border:1 solid silver;" height="100%">	
	<!------ activity_scorecard.cfm ----->
	<!------ 
	<cfset  activityMang = CreateObject("component","cm.activity.com.ActivityManager").init() />
	<cfset StSearch = StructNew()>
	<cfset StSearch.User_ID = request.AccessStructure.User_ID>
	<cfset StSearch.Activity_Start_Date = id>		
	<cfset 	qSearchResult = activityMang.getByFilter(StSearch)>	
	<CFOUTPUT>
	<cfloop query="qSearchResult">		
		<a href="/cm/handler.cfm?command=ceActivity&id=#CM_Activity_ID#">#Activity_Name#</a><br>
	</cfloop>	
	</CFOUTPUT>
	 ----->
	&nbsp;
	</td>
  </tr>
</table>
</DIV>


<DIV ID="campaigns">
<table border="0" cellpadding="3" cellspacing="0" width="100%" height="100%">
  <tr>
    <td bgcolor="##4169E1" colspan="100"><b><font color="##FFFFFF">Campaigns</font></b></td>
  </tr>
  <tr valign="top">
    <td STYLE="border:1 solid silver;" height="100%">
	<!------ Campaign Scorecard ----->
	<!------ 
	<cfset  campMang = CreateObject("component","cm.campaign.com.CampaignManager").init() />
	<cfset StSearch = StructNew()>
	<cfset StSearch.User_ID = request.AccessStructure.User_ID>
	<cfset StSearch.Campaign_Start_Date = id>		
	<cfset 	qSearchResult = campMang.getByFilter(StSearch)>	
	<CFOUTPUT>
	<cfloop query="qSearchResult">		
		<a href="/cm/handler.cfm?command=ceCampaign&id=#CM_Campaign_ID#">#Campaign_Name#</a><br>
	</cfloop>	
	</CFOUTPUT>
	 ----->
	&nbsp;
	</td>
  </tr>
</table>
</DIV>







<DIV ID="weeklyscoreard">
<table border="0" cellpadding="3" cellspacing="0" width="100%">
  <tr>
    <td bgcolor="##4169E1" colspan="100"><b><font color="##FFFFFF">Weekly scorecard</font></b></td>
  </tr>
  <tr>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
  </tr>
  <tr>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
  </tr>
  <tr>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
  </tr>
  <tr>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
  </tr>
  <tr>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
    <td STYLE="border:1 solid silver;">&nbsp;</td>
  </tr>
</table>
</DIV>

</BODY>
</HTML>

</CFOUTPUT>