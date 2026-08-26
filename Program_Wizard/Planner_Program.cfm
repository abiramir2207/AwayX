<!----------------------------------------------------------------------------------
Name         :	Planner_Program.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	03/01/2016
Created By   : 	Anand Rao
Description  : 	Page to maintain planner program
---------------------------------------------------------------------------------->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfif NOT isDefined("appSettings")>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
</cfif>
<html>
<head>
	<title>Planner Program</title>
	<style>
		body,td
		{
			font-family:		Arial;
			font-size:			12px;
		}
		a,a:visited
		{
			color:				Blue;
			text-decoration:	None;
		}
		a:hover
		{
			color:				Red;
			text-decoration:	Underline;
		}
		td.borders
		{
			border-bottom:		1px Solid blue;
			font-weight:		Bold;
		}
		TR.highlight
		{
			background-color: #D9FFDB;
			cursor:				pointer;
		}
		TR.nothighlight
		{
			background-color: #FFFFFF;
		}

		TD.maintable
		{
			border-bottom: 1px solid #C1C2FF;
		}
		.retroFieldsIndicator {font-size: 22px;color:green;font-weight:bold;vertical-align:middle;}

  	table.#table1 tr { padding-bottom: 9px; }
    .sh73 { border-bottom:1px solid black; font-weight:bold; font-size:14px; padding-top:15px; }
	#bigTable th, #segmentTable th  {font:bold 14px; text-align: left; color:3300cc; padding:7px 0 15px 0;}
	</style>
</HEAD>

<BODY>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<cfset Action = "edit">
<cfset pageName = "planner_program">

<CFSET PAGETITLE = "PROGRAM TEMPLATES: #UCASE(Application.PlannerLabel)# #UCASE(Application.PlannerPrgLabel)#">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<cfparam name="url.id" 	default="0">
<cfparam name="FormStatus" default="">
<cfparam name="LockedBy_Current_User" 	default="0">

<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
<cfset template = templateManager.get(url.id)>
<cfset plannerSettingsManager = CreateObject("component", "mvc.Models.Planner.PlannerSettingsManager") />

<cfset qGetPlannerPerfTypes = plannerSettingsManager.getPerfTypeInfo(type="Active") />

<cfset qGetExistingPerfTypes = templateManager.getPlannerProgramTemplatePerfTypes(template.getFirstParentID()) />
<cfset lPlannerPerfTypes = valueList(qGetExistingPerfTypes.Planner_Perf_Types_ID) />

<!------ display header ----->
<cfset Created_Type = template.getCreatedType()>
<cfset Generic_Type = template.getGenericType()>
<cfset Active = template.getActive()>
<cfinclude template="header.cfm">
<br>
<cfset templateProgramPlanner = templateManager.getTemplateProgramPlanner(url.id) />

<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
<SCRIPT LANGUAGE="javascript">
	function showHideRevisionType(thisObj)
	{
		var formObjName		= 	thisObj.name;
		var formObjVal 		= 	thisObj.value;

		for (k= 1;k<=3;k++){
			var formSubObj	=	document.getElementById(formObjName + "_Type"+k);
			if(formObjVal == 1){
				formSubObj.disabled = false;
				if(k==1){
					formSubObj.checked = true;
				}
			}
			else{
				formSubObj.value	= 0;
				formSubObj.checked = false;
				formSubObj.disabled	= true;
			}
		} // End: for(k= 1;k<=3;k++)
	}
</SCRIPT>

<!--- <cfif templateRevisionSettings.Recordcount neq 0>
	<CFOUTPUT>
	<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="3" ALIGN="CENTER" STYLE="border:2px orange solid;">
	<TR>
		<TD STYLE="font-weight:bold;font-size:13px;">
		This setting was last updated on #DateFormat(templateRevisionSettings.Revision_Setting_Created_On, "mm/dd/yyyy")# #TimeFormat(templateRevisionSettings.Revision_Setting_Created_On, "hh:mm:ss tt")# by #templateRevisionSettings.Name_First#  #templateRevisionSettings.Name_Last#</TD>
		</TR>
	</TABLE>
	</CFOUTPUT>
</cfif>
 --->

<cfif LockedBy_Current_User NEQ 1>
	<cfset FormStatus = "disabled">
</cfif>

<FORM ACTION="Planner_Program_Action.cfm" METHOD="post" NAME="PlannerForm" ID="PlannerForm" style="display:inline">
<div style="margin:5px 0;">
	<span style="width:60%;"><img src="/images/ico-info.gif"> <span class="headingTip">All changes on this page will be saved retroactively for all previous versions.</span></span>
	<cfif LockedBy_Current_User EQ 1>
	  <cfoutput>
		<span style="width:39%;text-align:right;"><a href="javascript:document.all.MyForm.submit();">#application.util.string.actionLinkFormat("save and continue")#</a></span>
	  </cfoutput>
	</cfif>
</div>

<TABLE BORDER="0" WIDTH="100%" ID="bigTable" CELLSPACING="0" CELLPADDING="2">
   <col width="5%"><col width="15%"> <col width="80%">
	<cfoutput>
<!--- 	<TR>
		<th COLSPAN="3">These settings apply...</th>
	</TR>
	<TR>
		<TD>&nbsp;&nbsp; ...to all program revisions</TD>
		<td><INPUT TYPE="radio" VALUE="1" NAME="Apply_to_All" CHECKED #FormStatus#></TD>
	</TR>
	<TR>
		<TD>&nbsp;&nbsp; ...only to programs sent to ERP</TD>
		<td><INPUT TYPE="radio" VALUE="2" NAME="Apply_to_All"<CFIF templateRevisionSettings.Apply_to_All EQ 2> CHECKED</CFIF> #FormStatus#></TD>
	</TR>
 --->

 	<tr>
		<th COLSPAN="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Header</th>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>Budget</td>
		<td>
			<INPUT TYPE="checkbox" NAME="Budget" VALUE="1"<CFIF templateProgramPlanner.Budget EQ 1> CHECKED</CFIF> #FormStatus#>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>Consumer Event</td>
		<td>
			<INPUT TYPE="checkbox" NAME="Marketing_Event" VALUE="1"<CFIF templateProgramPlanner.Marketing_Event EQ 1> CHECKED</CFIF> #FormStatus#>
		</td>
	</tr>
	<tr>
		<th COLSPAN="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Detail</th>
	</tr>
 	<tr>
		<td>&nbsp;</td>
		<td>NUC Target</td>
		<td>
			<INPUT TYPE="checkbox" NAME="NUC_Target" VALUE="1"<CFIF templateProgramPlanner.NUC_Target EQ 1> CHECKED</CFIF> #FormStatus#>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>Retailer Unit Cost</td>
		<td>
			<INPUT TYPE="checkbox" NAME="Retailer_Unit_Cost" VALUE="1"<CFIF templateProgramPlanner.Retailer_Unit_Cost EQ 1> CHECKED</CFIF> #FormStatus#>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>Merch Unit Price</td>
		<td>
			<INPUT TYPE="checkbox" NAME="Merch_Unit_Price" VALUE="1"<CFIF templateProgramPlanner.Merch_Unit_Price EQ 1> CHECKED</CFIF> #FormStatus#>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>Retailer Margin</td>
		<td>
			<INPUT TYPE="checkbox" NAME="Retailer_Margin" VALUE="1"<CFIF templateProgramPlanner.Retailer_Margin EQ 1> CHECKED</CFIF> #FormStatus#>
		</td>
	</tr>
	<tr>
		<th COLSPAN="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#Application.PlannerLabel# Perf Types</th>
	</tr>
	<cfloop query="qGetPlannerPerfTypes">
		<tr>
			<td>&nbsp;</td>
			<td>#Description#</td>
			<td>
				<INPUT TYPE="checkbox" NAME="Planner_Perf_Types_ID" VALUE="#Planner_Perf_Types_ID#" <cfif listFind(lPlannerPerfTypes, Planner_Perf_Types_ID)>checked</cfif> #FormStatus#>
			</td>
	</tr>
	</cfloop>

	</TABLE>
</cfoutput>
<BR>
<cfif LockedBy_Current_User EQ 1>
		<table align="center" border="0" cellpadding="0" cellspacing="0">
	<TR>
		<td>

		<CF_button
			button_name		=	""
			button_caption	=	"save and continue"
			button_action	=	"document.all.PlannerForm.submit();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"save and continue"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</td>
		</tr>
		</table>
</cfif>
<cfoutput>
<INPUT NAME="Template_ID" TYPE="Hidden" VALUE="#url.id#">
</cfoutput>
</FORM>
</BODY>
</HTML>
