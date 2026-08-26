<cfsilent>
<!---
       Name:          header.cfm
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.
       Created Date:  3/30/2007
       Created By:    cmorse
       Label:		  11367
       Description:   Contains all of the shared header code access the billback upload utility screens.
--->
<cfparam name="printable" default="0">
 </cfsilent>
<!---<html>
<body>

<head>
--->
<!--- Note: Include of Yahoo UI Js & CSS libraries --->
<link type="text/css" rel="stylesheet" href="/script/javascript/yui_2_2_0/reset/reset.css">
<link type="text/css" rel="stylesheet" href="/script/javascript/yui_2_2_0/fonts/fonts.css">
<link type="text/css" rel="stylesheet" href="/script/javascript/yui_2_2_0/logger/assets/logger.css">
<link type="text/css" rel="stylesheet" href="/script/javascript/yui_2_2_0/datatable/assets/datatable.css">
<link type="text/css" rel="stylesheet" href="/Script/javascript/yui_2_2_0/container/assets/container.css">

<script type="text/javascript" src="/Script/javascript/yui/build/yahoo/yahoo-min.js"></script>
<script type="text/javascript" src="/Script/javascript/yui/build/yahoo-dom-event/yahoo-dom-event.js"></script>

<script type="text/javascript" src="/Script/javascript/yui/build/dom/dom-min.js" ></script>
<script type="text/javascript" src="/Script/javascript/yui/build/animation/animation-min.js" ></script>
<script type="text/javascript" src="/Script/javascript/yui/build/container/container-min.js"></script>
<!-- Dependencies -->
<script type="text/javascript" src="/Script/javascript/yui/build/utilities/utilities.js"></script>
<script type="text/javascript" src="/Script/javascript/yui/build/datasource/datasource-beta-min.js"></script>
<script type="text/javascript" src="/Script/javascript/yui/build/datatable/datatable-beta-min.js"></script>

<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>

<script type="text/javascript" src="/Script/javascript/Ajax_JS/jquery.js"></script>
<script type="text/javascript" src="/Script/javascript/Ajax_JS/jquery.AjaxCFC.js"></script>
<script type="text/javascript">
		// additional files
		$.AjaxCFC({require:'dDumper,DWRSyntax,jquery'});
		// more additional files
		// $.AjaxCFC({require:'jquery.fastSerialize'});

		// optional global settings
		// using these setters also automatically include dependencies
		$.AjaxCFCHelper.setDebug(false);
		$.AjaxCFCHelper.setBlockUI(false);
		$.AjaxCFCHelper.setUseDefaultErrorHandler(true);
		$.AjaxCFCHelper.setSerialization('json'); // json, wddx
	</script>

<style type="text/css">
	#mainContent table {border-collapse:collapse;border:1px solid RGB(0,0,0);width:820px;}
	#mainContent tbody td {border:1px solid RGB(210,210,210);padding:3px;color:black;}
	#mainContent thead td {border:1px solid RGB(224,205,70);font-size:11px;color:black;font-weight:bold;background-color:RGB(255,224,131);text-align:center;vertical-align:bottom;padding-left:2px;color:black}
	#mainContent thead th {border:1px solid RGB(224,205,70);font-size:11px;color:black;font-weight:bold;background-color:RGB(255,224,131);text-align:left;vertical-align:bottom;padding-left:2px;color:black}
	#mainContent thead th a {color:RGB(0,0,0);}
	#mainContent tbody td.error {border: 3px solid RGB(255,75,75);font-weight:bold;}

	#markup {margin:.25em;}
	#markup table {border-collapse:collapse;border:1px solid RGB(0,0,0);width:820px}
	#markup tbody td {border:1px solid RGB(210,210,210);padding:3px;color:black;}
	#markup thead th {border:1px solid RGB(224,205,70);font-size:11px;color:black;font-weight:bold;background-color:RGB(255,224,131);text-align:center;vertical-align:bottom;padding:2px;color:black}
	#markup thead th a {color:RGB(0,0,0);}
	#markup .yui-dt-odd {background-color:rgb(225,255,225);} /*light green*/
	#markup .yui-dt-highlight {background-color:rgb(204,204,255);}

	body 	{padding-left:5px;}
	thead 	{display: table-header-group;}

	A.tablink_back, A:Hover.tablink_back
		{
			font-family:		Arial;
			font-size :			11px;
			font-weight:		bold;
			text-decoration:	none;
		}
	A:visited.tablink_back /* Main Color */
		{
			font-family:		Arial;
			font-size :			11px;
			font-weight:		bold;
			text-decoration:	none;
			color: 				blue;
		}
	A.tablink_fore
		{
			color: 				black;
			font-family:		Arial;
			font-size :			11px;
			font-weight:		bold;
			text-decoration:	none;
		}
	A:visited.tablink_fore
		{
			color: 				black;
			font-family:		Arial;
			font-size :			11px;
			font-weight:		bold;
			text-decoration:	none;
		}

		.subheading
		{
				font-weight:bold;
				font-size:12px;
				text-decoration:underline;

		}
	  .formLabel
		{
			font-weight:bold;
			width:100%;
			display:inline;
		}

	  TD.headernotselected
	  {
	   background-color 	: dddddd;
	   border-bottom		: solid 1px black;
	   cursor				: pointer;
	   color				: Black;
	  }
	  TD.headerselected
	  {
	   color				: black;
	   border-left			: solid 3px black;
	   border-top			: solid 3px black;
	   border-right			: solid 3px black;
	   padding-left			: 3px;
	   padding-right		: 3px;
	   background-color 	: RGB(255,204,120);
	   cursor				: pointer;
	   TEXT-TRANSFORM		: uppercase;
	  }
	  TD.headerblank
	  {
	   border-bottom		: solid 1px black;
	  }
	  TD.headerspacer
	  {
	   border-bottom		: solid 1px black;
	  }
	  TD.headerlastone
	  {
	   border-left			: solid 1px black;
	  }
</style>

<SCRIPT language="JavaScript">
	function Change_Tab()
		{
			var aObj 	= getParentObject(event.srcElement,"A");
			var oTable_Tab = document.all.Table_Tab;
			var oCells = oTable_Tab.rows[0].cells;
			var i;
			var thisCell = getParentObject(event.srcElement,"TD");
			if(oCells)
			{
				for(i=0;i<oCells.length;i++)
				{
					if(oCells[i] == thisCell)
					{
						oCells[i].className = "headerselected";
						//oCells[i].style.color = "white";
					}
					else
					{
						if(oCells[i].id)
						{
							oCells[i].className = "headernotselected";
						}
					}
				}
			}

			SRCURL = aObj.href;
	}
</SCRIPT>
<!---</head>
<body>
--->
<!--- Hides Title Bar & Help link when in printer friendly view --->
<cfif printable EQ 0>
<!---<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">--->
<CFSET URL.PageTitle="BILLBACK UPLOAD UTILITY">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!---<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</cfif>

<CFOUTPUT>
	<CFPARAM NAME="URL.Show_Tab" DEFAULT="1">
	<cfparam name="FORM.showTab" default="#URL.Show_Tab#">
	<CFPARAM NAME="URL.filetype" DEFAULT="">
	<CFPARAM name="form.item_number" default="">
	<CFPARAM NAME="URL.StartRow" DEFAULT="1">
	<CFPARAM NAME="URL.frompage" DEFAULT="1">
	<CFPARAM NAME="FORM.StartRow" DEFAULT="#URL.StartRow#">
	<CFPARAM NAME="FORM.frompage" DEFAULT="#URL.frompage#">
</CFOUTPUT>
<!--- HANDLE FORM SUBMISSION FROM UPLOAD_HISTORY.CFM --->
<cfif FORM.showTab NEQ URL.Show_Tab> 
	<cfset URL.Show_Tab = FORM.showTab>
</cfif>


