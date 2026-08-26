<!---------------------------------------------------------------------------------------------------------------------
Template:	/Planners/Create/planner_legend.cfm
Date:  		06/14/2016
Author:		Tim Ford
Purpose:  	LH nav for Single Page Planner Program Create
----------------------------------------------------------------------------------------------------------------------->

<script language="JavaScript" type="text/javascript" src="/script/javascript/DHTML_Tooltip_Code.js"></script>
<link rel="stylesheet" type="text/css" href="/common_files/viewmodes.css">
<script>
	function customContainer(){
		document.getElementById('customContainer').style.display='block';//D51575
	}
</script>

<CFPARAM NAME="Cache_Control_Header_Already_Added" 	DEFAULT="0">
<CFPARAM NAME="url.bViewReadOnly" DEFAULT="0">

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<CFSET MainLinksNotClickableClass = "Grayed">

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="SetUpOption" output="true" hint="I display LHP option with one enabled condition.">
  <cfargument name="text"     type="string"  required="true"  hint="option text">
  <cfargument name="enabled"  type="boolean" required="true"  hint="true = option is enabled">
  <cfargument name="anchor"   type="string"  required="true"  hint="anchor attributes (href, onclick, etc..)">
  <cfargument name="disabled" type="string"  required="false" default="display" hint="none = do not display of disabled option">
  <cfargument name="dot_img"  type="string"  required="false" default="/images/programs/ball_blue.gif" hint="dot image file name">

  <cfset var vars = {}>
  <cfsetting enablecfoutputonly="true" >
  <!---determine the disabled dot image file name--->
  <cfif arguments.dot_img contains 'ball_green.gif'>
  	<cfset vars.disabled_dot = '/images/programs/ball_red.gif'>
  <cfelse>
  	<cfset vars.disabled_dot = '/images/programs/ball_gray_filled.gif'>
  </cfif>
  <cfoutput><tr class="contractLinks"></cfoutput> 
		<!---test enabled condition--->
    <cfif arguments.enabled>
      <cfoutput><td nowrap><img border="0" src="#arguments.dot_img#" align="absmiddle"><a #arguments.anchor#>&nbsp;#arguments.text#</a></td></cfoutput>
		<!---option is not enabled--->
    <cfelseif arguments.disabled eq "display">
      <cfoutput><td nowrap class="Grayed"><img border="0" src="#vars.disabled_dot#" align="absmiddle">&nbsp;#arguments.text#</td></cfoutput>
    </cfif>
  <cfoutput></tr></cfoutput>
  <cfsetting enablecfoutputonly="false" >
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="SetUpOption2" output="true" hint="I display LHP option with 2 enabled conditions.">
  <cfargument name="text"      type="string"  required="true"  hint="option text">
  <cfargument name="enabled1"  type="boolean" required="true"  hint="true = option is enabled">
  <cfargument name="anchor1"   type="string"  required="true"  hint="anchor attributes (href, onclick, etc..)">
  <cfargument name="enabled2"  type="boolean" required="true"  hint="true = option is enabled">
  <cfargument name="anchor2"   type="string"  required="true"  hint="anchor attributes (href, onclick, etc..)">
  <cfargument name="disabled"  type="string"  required="false" default="display" hint="none = do not display of disabled option">
  <cfargument name="dot_img"  type="string"   required="false" default="/images/programs/ball_blue.gif" hint="enabled dot image file name">

  <cfset var vars = {}>
  <cfsetting enablecfoutputonly="true" >
  <!---determine the disabled dot image file name--->
  <cfif arguments.dot_img contains 'ball_green.gif'>
  	<cfset vars.disabled_dot = '/images/programs/ball_red.gif'>
  <cfelse>
  	<cfset vars.disabled_dot = '/images/programs/ball_gray_filled.gif'>
  </cfif>
  <cfoutput><tr></cfoutput>
		<!---test 1st enabled condition--->
    <cfif arguments.enabled1>
      <cfoutput><td nowrap><img border="0" src="#arguments.dot_img#" align="absmiddle"><a #arguments.anchor1#>&nbsp;#arguments.text#</a></td></cfoutput>
		<!---test 2nd enabled condition--->
    <cfelseif arguments.enabled2>
      <cfoutput><td nowrap><img border="0" src="#arguments.dot_img#" align="absmiddle"><a #arguments.anchor2#>&nbsp;#arguments.text#</a></td></cfoutput>
		<!---option is not enabled--->
    <cfelseif arguments.disabled eq "display">
      <cfoutput><td nowrap class="Grayed"><img border="0" src="#vars.disabled_dot#" align="absmiddle">&nbsp;#arguments.text#</td></cfoutput>
    </cfif>
  <cfoutput></tr></cfoutput>
  <cfsetting enablecfoutputonly="false" >
</cffunction>

<cfset programManager = CreateObject("component", "components.programs.ProgramManager") />

<!--- check to see if the program template used for this contract is deleted or made inactive --->

<CFOUTPUT>
	<script language="JavaScript" type="text/JavaScript">
	<!--
	function MM_reloadPage(init) {  //reloads the window if Nav4 resized
	  if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {
	    document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}
	  else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();
	}
	MM_reloadPage(true);
	//-->
	</script>
    <div id="divTooltip" style="z-index:200;width:200px;"></div>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
</CFOUTPUT>


<CF_SmallHelp
	height = "200"
	width = "500"
	overflow = "auto"
	displayShifyX = "-30"
	displayShifyY = "-5"
	showImage="-1"
	returnDivId="returnDivId">
<center>
<font color="blue">*** click on the window to close ***</font><br>
</center>
</CF_SmallHelp>


<TABLE BORDER="0" CELLPADDING="0" ID="table1">
	
	<CFSET bIsLocked = 0>
	
	<script language="JavaScript" type="text/javascript">
		Locked = new Image();
		//Locked.src = "/images/lock2.gif";
		Locked.src = "/images/readonly_mode.gif";
	
		UnLocked = new Image();
		//UnLocked.src = "/images/lock3.gif";
		UnLocked.src = "/images/edit_mode.gif";
	</script>
	
	<cfif bIsLocked eq 1>
	<TR>
		<TH NOWRAP COLSPAN="2">
			<button class="readonly" title="This program is currently being viewed by #ucase(LookUpTheLockingUser.Name_First)# #ucase(LookUpTheLockingUser.Name_Last)#">Read Only</button><BR/>
			<span style="color:RGB(255,0,0);font-size:12px;font-weight:bold;text-decoration:none;">Locked By<br />#ucase(LookUpTheLockingUser.Name_First)# #ucase(LookUpTheLockingUser.Name_Last)#</span>
		</TH>
	</TR>
	<cfelse>
	<!--- if it is locked offer to unlock it --->
	<TR>
		<TD COLSPAN="2" align="center" style="word-wrap:break-word;width:13em;">
			<a href="#variables.lockHref#" onclick="customContainer();">
			<button class="edit" onclick="location.href='#variables.lockHref#'">&nbsp; Edit &nbsp;</button><br>
			<span class="ViewModesBracketsm">[</span><span class="ViewModessm"> Click for Read Only </span><span class="ViewModesBracketsm">]</span></a>
		</TD>
	</TR>
	
	</cfif>
	<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<!---/////////////////////////////////////////// Lock Code End ///////////////////////////////////////////////////////--->
	<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
		
	<cfset IMG_SRC = "/images/programs/ball_gray_filled.GIF">
	

	<cfset SetUpOption(  text = 'print', enabled = 1, anchor = "" )>
	<cfset SetUpOption(  text = 'email', enabled = 1, anchor = "" )>
	<cfset SetUpOption(  text = 'letters', enabled = 1, anchor = "" )>
	<cfset SetUpOption(  text = 'copy', enabled = 1, anchor = "" )>
	<cfset SetUpOption(  text = 'history', enabled = 1, anchor = "" )>
	<cfset SetUpOption(  text = 'cancel', enabled = 1, anchor = "" )>
	<cfset SetUpOption(  text = 'revise', enabled = 1, anchor = "" )>
	<cfset SetUpOption(  text = 'delete', enabled = 1, anchor = "" )>
	<cfset SetUpOption(  text = 'purge', enabled = 1, anchor = "" )>
	<cfset SetUpOption(  text = 'reset', enabled = 1, anchor = "" )>
	<cfset SetUpOption(  text = 'changes', enabled = 1, anchor = "" )>
	<cfset SetUpOption(  text = 'bus consid', enabled = 1, anchor = "" )>
	<cfset SetUpOption(  text = 'workflow', enabled = 1, anchor = "" )>
	<TR>
		<TD NOWRAP>
			<IMG BORDER="0" SRC="/images/programs/finial.gif" ALIGN="absmiddle">
		</TD>
	</TR>
</TABLE>
</span>

<STYLE TYPE="text/css">
TD.foreground
	{
		border-left :		1px solid Gray;
		border-right :		1px solid Gray;
		border-top :		1px solid Gray;
		color: 				Red;
	}
TD.background
	{
		border-left:		1px solid Gray;
		border-right:		1px solid Gray;
		border-top :		1px solid Gray;
		border-bottom:		1px solid Gray;
		color: 				White;
	}
TD.Filler
	{
		border-left:		1px solid White;
		border-bottom:		1px solid Gray;
		color: 				White;
	}
A.tablink_back, A:Hover.tablink_back
	{
		color: 				Blue;
		font-family:		Arial;
		font-size :			11px;
		text-decoration:	none;
	}
A:visited.tablink_back
	{
		color: 				Blue;
		font-family:		Arial;
		font-size :			11px;
		text-decoration:	none;
	}
A.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px;
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px;
		font-weight:		bold;
		text-decoration:	none;
	}
.Grayed
	{
		color: 				gray;
		font-family:		Arial;
		font-size :			11px;
	}

	/* POPup tooltip style*/
	#divTooltip {
		position:absolute;
		top:0px;
		width:100px;
		visibility:hidden;
		z-index:200;
		background:#FFFFFF;
		layer-background-color:#FFFFFF;
		text-align:left;
	}
	.normalStyle {
		padding:2px;
		text-align:center;
		font-weight:500;
		width:175px;
		color:#000000;
		top:100px;
		font-family:verdana,arial,helvetica;
		font-size:11px;
		background-color:#f3f3f3;
		layer-background-color:#f3f3f3;
		border-width:1px;
		border-style:solid;
		border-color:#000000;
		cursor:default;
	}
	<!--[if gt IE 8]>
		table#table1 { border-collapse: collapse; table-layout:fixed; }
	<![endif]-->
	<!--[if lte IE 8]>
		table#table1 { border-collapse: collapse; }
	<![endif]-->
</style>


