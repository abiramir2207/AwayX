<cfparam name="URL.PRINT" default="0">
<cfparam name="form.generatexlsreport" default="0">
<cfif url.PRINT EQ 1>
	<CFSET Table_Width =  "660">
	<CFSET CI_Width=120>
	<CFSET BB_Width=80>
	<CFSET Payee_Width=120>
	<CFSET SD_Width=30>
	<CFSET ED_Width=30>
	<CFSET Paid_Width =65>
	<CFSET Piaddate_Width=65>
	<CFSET LB_Width=65>
	<CFSET CS_Width=65>
	<CFSET Default_Sort = "PD">
	<CFSET Default_Sort_Order = "DESC">
<cfelse>

	<CFSET table_Width=820>	
	<CFSET CI_Width=120>
	<CFSET BB_Width=80>
	<CFSET Payee_Width=210>
	<CFSET SD_Width=40>
	<CFSET ED_Width=40>
	<CFSET Paid_Width=80>
	<CFSET Piaddate_Width=70>
	<CFSET LB_Width=80>
	<CFSET CS_Width=80>
	<cfset Agg_Width=20>
</cfif>

<CFSET Default_Sort = "PD">
<CFSET Default_Sort_Order = "DESC">

<CFSET ASC_IMG="down_1.gif">
<CFSET DESC_IMG="up_1.gif">


<cfif form.generatexlsreport EQ 0>
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
<style>
Table.maintable td.tableheaders
	{
		font-size:12px;
		font-weight:bold;
		border-bottom:thin FFFFFF 0px; 
	}
Table.maintable td.tableheaders1
	{
		font-size:11px;
		font-weight:bold;
		border-bottom:thin FFFFFF 0px; 
	}
</style>
<STYLE TYPE="text/css">
TD.foreground
	{
		border-left :		1px solid Gray;
		border-right :		1px solid Gray;
		border-top :		1px solid Gray;
		color: 				Black;
		BACKGROUND-COLOR: 	FFCE84;
	}
TD.background
	{
		border-left:		1px solid Gray;
		border-right:		1px solid Gray;
		border-top :		1px solid Gray;
		border-bottom:		1px solid Gray;
		color: 				White;
		cursor:				pointer;		
		BACKGROUND-COLOR: 	WhiteSmoke;
	}
TD.Filler
	{
		border-left:		1px solid White;
		border-bottom:		1px solid Gray;
		color: 				White;
	}
A.tablink_back, A:Hover.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
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
	
	
	
	TD.headernotselected
  {
   background-color : dddddd;
   border-bottom: solid 3px black;
  }
  TD.headerselected
  {
   border-left: solid 3px black;
   border-top: solid 3px black;
   border-right: solid 3px black;
   background-color : #fore_Color#;
  }
  TD.headerblank
  {
   border-bottom: solid 3px black;
  }
  TD.headerspacer
  {
   border-bottom: solid 3px black;
  }
  TD.headerlastone
  {
   border-left: solid 3px black;
  }

</STYLE>
</cfif>

