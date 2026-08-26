<!----------------------------------------------------------------------------------
Name         :	AwayX/Planners/Templates/planner_template_filters.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	03/01/2016
Created By   : 	KAL
Description  : 	Planner Templates; Page Header
---------------------------------------------------------------------------------->
<!---
<cfparam name="Active" 	default="">
<cfinclude template="lock_template.cfm">

<cfif Active EQ 0 OR (Active EQ 1 AND pageName NEQ "basicinfo") OR (Active EQ 1 AND pageName EQ "basicinfo" and action EQ "Edit" AND displayheader EQ 1)>
	<cfset TR_BORDER_WIDTH = 2>
	<cfset TD_FORE_COLOR = "FFE083">
	<style type="text/css">
    #tabs7 { border-collapse:collapse; margin-top:10px; }
    
    #tabs7 tr { line-height:35px; }
    #tabs7 td { text-align:center; font-weight:bold; font-size:12px; background-color:#dddddd; border:1px solid #A5A5A5; }
    
    #tabs7 a:link, #tabs7 a:visited, 
    #tabs7 a:hover, #tabs7 a:active { color:rgb(0, 136, 204); text-decoration:none; } 
    
    #tabs7 a:link.headerselected , #tabs7 a:visited.headerselected , 
    #tabs7 a:hover.headerselected , #tabs7 a:active.headerselected  { color:black; font-size:1.0em; font-weight:bold; } 
    
    #tabs7 a:hover { background-color:white; }
    #tabs7 .headerselected { background-color:white; border-bottom:0px; }

    #tabs7 .tdfirst { border-top:white; border-left:white; background-color:white }
    #tabs7 .tdlast { border-top:white; border-right:white; background-color:white }
	</style>

	<cfparam name="pageName" 		 default="">
	<cfparam name="ID" 				   default="0">
	<cfparam name="Generic_Type" default="">
	<cfparam name="Action" 			 default="">
	<cfparam name="Created_Type" default="">

	<cfinclude template="Page_List.cfm" />

	<cfset F_Counter = 1>
  <cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( listToArray( "1," & repeatString("10,", listLen(PAGE_TITLES) + 1) ) )>
	<table border="0" cellspacing="0" cellpadding="0" width="100%" id="tabs7">
	<cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
    <cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
  </cfloop>
	<tr>
	    <td class="tdfirst">&nbsp;</td>
			<cfloop list="#PAGE_TITLES#" index="ThisMenuItem">
			  <cfscript>
				  ThisURL             = ListGetAt(PAGE_URLS, F_Counter, ",");
				  ThisPageName        = ListGetAt(PAGE_NAMES, F_Counter, ",");
				  variables.className = ( ThisPageName EQ pageName ? 'class="headerselected"' : '' );
				  F_Counter = F_Counter + 1;
				</cfscript>
				<cfoutput><td #variables.className# nowrap><a #variables.className# href="#ThisURL#"> &nbsp; #ThisMenuItem# &nbsp; </a></td></cfoutput>
			</cfloop>
			<td class="tdlast">&nbsp;</td>
		</tr>
	</table>
</cfif>
--->