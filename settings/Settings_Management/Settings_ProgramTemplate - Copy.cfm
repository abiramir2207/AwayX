<!----
/settings/Settings_Management/Settings_ProgramTemplate.cfm
Created By: Jianxiu
Created On: Sep 10, 2010 
Last Modified On: Sep 8, 2011
--->

<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/locked-column.css">

<style>
tbody td { border-bottom:solid #93BEE2 1px;vertical-align:middle;font-size: 11px;}	
tbody th { border-bottom:solid #93BEE2 1px;vertical-align:middle;font-size: 11px; font-weight:bold; text-align: center; height:20px;}	

thead th, thead th.locked {
	font-size:	12px;
	font-weight:	bold;
	text-align:	left;
	background-color: #DDDDDD;
	color:		blue;
	border-right: 	1px solid silver;
	position:	relative;
	cursor: 	default;
	HEIGHT:		18;
}

#tbl-containerSmall {OVERFLOW: auto; WIDTH: 99.9%; HEIGHT:300;}
</style>

<cfparam name="tabHeader" 		default="1">  
<cfparam name="error_RateType" 	default="0">
<cfset Generic_Type = "#Form.Generic_Type#">
<cfset templateSettingsManager = CreateObject("component", "components.settings.settings_management.TemplateSettingsManager").init() />
<cfif tabHeader neq 1>
	<cfset templateSettings = templateSettingsManager.getTemplateMgmtSettingsSecPage(Generic_Type)>
	<cfset strException_Active = templateSettingsManager.getException_Active(Generic_Type,tabHeader)>
	<cfset SettingIDs = templateSettingsManager.getSettingIDs(tabHeader)>
<cfelse>
	<cfset templateSettings = templateSettingsManager.getTemplateSettings(Generic_Type)>
	<cfset strException_Active = templateSettingsManager.getException_Active(Generic_Type)>
	<cfset SettingIDs = templateSettingsManager.getSettingIDs()>
</cfif>
<!---Gets application settings--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />

<cfset appSettings = genSettingsManager.get()>
<cfset forbidType = appSettings.getForbidAllowProfilesInTemplates() />
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />

<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo(productGroupLevelId=appSettings.getTemplateRestrictGroupLevel()) />
<cfparam name="Form.price_protection_on" 		default="0">

<cfquery name="getGeneralSettings" datasource="#application.datasource#">
	SELECT TOP 1 *
	FROM General_Settings
</cfquery>
<cfquery name="qCheckOptions" datasource="#application.datasource#">
	SELECT 	TOP 1 *
	FROM 	Program_Control_Panel_Options
</cfquery>
<cfsilent>
<cfset fromSettings_management = 1>

<!---initialize business segment manager--->
<cfset variables.businessSegmentManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />

<cfif (Generic_Type EQ "Operator Direct or HQ Programs" OR Generic_Type EQ "Operator-Deviated Pricing")>
	<cfset pullback_template_type = 2>
<cfelseif Generic_Type EQ "Distributor Trade/Shelter">
	<cfset pullback_template_type = 1>
<cfelse>
	<cfset pullback_template_type = 0>
</cfif>
</cfsilent>
<cfparam name="FormStatus" default="">

<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
	.showOptions { display: ; }
	.hideOptions { display: none; }
	.requiredFieldsIndicator {font-size: 22px;color:red;font-weight:bold;}
	.retroFieldsIndicator {font-size: 22px;color:green;font-weight:bold;vertical-align:middle;}
	hs {font-size: 12px;}
</style>

<script type='text/javascript'>
function ShowException(Setting_ID){
	document.getElementById("picon_"+Setting_ID).innerHTML = '<b style="color: red;">*</b>'
}

function AddExceptions(Generic_Type,Setting_ID,Setting_Name)
{
	var windowLocation = "Settings_ProgramTemplate_Exception.cfm?Generic_Type="+Generic_Type+"&Setting_ID="+Setting_ID+"&Setting_Name="+Setting_Name;
	NewWindow(windowLocation, "SettingsManagementExceptions", 600, 600, "yes", "yes");
	return false;
}

<!--- the dynamic template settings from the table records--->
function AddExceptionsTBL(Generic_Type,Setting_ID,Setting_Name,SettingDisplayValueInTable,SettingDisplayValueInTableID)
{
	var windowLocation = "Settings_ProgramTemplate_Exception.cfm?Generic_Type="+Generic_Type+"&Setting_ID="+Setting_ID+"&Setting_Name="+Setting_Name+"&SettingDisplayValueInTable="+SettingDisplayValueInTable+"&SettingDisplayValueInTableID="+SettingDisplayValueInTableID;
	NewWindow(windowLocation, "SettingsManagementExceptions", 600, 600, "yes", "yes");
	return false;
}

function massUpdateCheckAll(ShowHide)
{
        var str = '';
        var elem = document.getElementById('TemplateSettingsManagement').elements;
	if (ShowHide ==1)
	{
	  	if (document.getElementById('selectallShow').checked == true)
	 	{	
			document.getElementById('selectallHide').checked =false;
       	 		for(var i = 2; i < elem.length; i=i+2)
        			{
				var bRadio = elem[i].name+ "_1";
				if (!document.getElementById(bRadio))
				{
					continue
				}
				else
				{
					document.getElementById(bRadio).checked=true;
				}
			}
		}
	}
	else
	{
	  	if (document.getElementById('selectallHide').checked == true)
	  	{	
			document.getElementById('selectallShow').checked =false;
       	 		for(var i = 2; i < elem.length; i=i+2)
        			{
				var bRadio = elem[i].name+ "_0";
				if (!document.getElementById(bRadio))
				{
					continue
				}
				else
				{
					document.getElementById(bRadio).checked=true;
				}
			}
	  	}
	}
}
function showMessageWindow()
{
}

function confirmCompletion(tabHeader,disableClickedButton, disableClickedButtonName1,disableClickedButtonName2)
{ 
	var ErrorCount = 0;
	if(ErrorCount == 0) 
	{	
		if(tabHeader == 2) {
			TemplateSettingsManagement.action = "Settings_ProgramTemplate_SecPage_Save.cfm";
		}
		else {
			TemplateSettingsManagement.action = "Settings_ProgramTemplate_Save.cfm";
		}
		TemplateSettingsManagement.submit();
	}
	else 
	{ 
		showMessageWindow();
	}	
}
function hideTemplateOverridesDeviation()
{
	  	if (document.getElementById('BB_D_Template_Overrides_Deviation_Tolerances_0').checked == true)
	  	{	
			document.getElementById('BB_D_Purchase_Period_OverRide_0').checked =true;
			document.getElementById('BB_D_Purchase_Period_OverRide_Rate_0').checked =true;
			document.getElementById('BB_D_Aggregation_Period_OverRide_0').checked =true;
			document.getElementById('BB_Tolerance_DVT_0').checked =true;
			document.getElementById('BB_Tolerance_ERT_0').checked =true;
			document.getElementById('Cannot_Exceed_Percent_0').checked =true;
			document.getElementById('Cannot_Exceed_Dollar_0').checked =true;
			document.getElementById('Billback_Status_if_Below_Deviation_0').checked =true;
			document.getElementById('Billback_Status_if_Exceeds_Deviation_0').checked =true;
			document.getElementById('Maximum_Dollar_Amount_Checked_0').checked =true;				
			document.getElementById('Auto_Deviation_Inc_Manual_BB_0').checked =true;
	  	}
}
</script>

<!------ Operating Group ----->
<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
<cfset templateMapLevel 			= operatingGroupManager.getTemplateMapLevel() />
<cfset templateMapLevelLabel 			= operatingGroupManager.getLabel(templateMapLevel) />

<cfset LabelComp = Createobject("component", "components.settings.labels.labels").init() />

<br><CFINCLUDE TEMPLATE="template_header.cfm"> <br>		
<cfoutput>
<form action="wSettings_ProgramTemplate_save.cfm" method="post" name="TemplateSettingsManagement" id="TemplateSettingsManagement" style="display:inline;">
<table width="90%" align="center" cellspacing="0" cellpadding="1"  border="0">
	<tr valign="middle">
				<td width="100%" align="right">
						<CF_button
							button_name		=	"save1"
							button_caption	=	"Save Settings"
							button_action	=	"confirmCompletion(#tabHeader#,1, 'save1_table','save2_table');"
							button_type		=	"javascript_link"
							button_width	=	"250"
							button_color	=	"Navy"
							button_tip		=	"Save"
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						>	
				</td>
	</tr>
</table>

<DIV> 
<table width="90%" style="TOP: 0px;" align="center" cellpadding="0" cellspacing="0" border="0" class="maintable">
	<THEAD id="tbl_head">
		<TR>
			<TH  name="bufferTD" class="locked" align="left" valign="middle" style="z-index:40" nowrap>
				#Form.Generic_Type# Template Setting
			</TH>
			<TH width="150" align="left" valign="middle" >&nbsp;&nbsp;
				<input type="checkbox" name="selectallShow" id="selectallShow" value="1" onclick="javascript:massUpdateCheckAll(1);" title="Show All Settings">Show&nbsp;&nbsp;&nbsp;
				<input type="checkbox" name="selectallHide" id="selectallHide" value="1" onclick="javascript:massUpdateCheckAll(0);" title="Hide All Settings Hide">Hide
			</TH>
			<TH width="120">&nbsp;</TH>
		</TR>
	</THEAD>
	<TBODY>
		<cfif tabHeader eq 2>
			<cfset OperatorBid = false>
			<cfif Generic_Type EQ  "Operator Bids">
				<cfset OperatorBid = true>
			</cfif>
			<cfparam name="EZBUTTON_ON" default="0">
			<cfparam name="ID" default="0">
			<!---<style>TABLE.Maintable th {border-bottom:none;}</style>--->
			<CFINCLUDE TEMPLATE="/Program_Wizard/secondpage.cfm">
		<cfelse>
			<CFINCLUDE TEMPLATE="/Program_Wizard/create_edit.cfm">
		</cfif>
	
	</TBODY>
</table>
</DIV>

<div align="center"><CF_button
			button_name		=	"save2"
			button_caption	=	"Save Settings"
			button_action	=	"confirmCompletion(#tabHeader#,1, 'save2_table', 'save1_table');"
			button_type		=	"javascript_link"
			button_width	=	"250"
			button_color	=	"Navy"
			button_tip		=	"Save and Continue"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
</div>

<input type="hidden" name="Generic_Type" value="#Generic_Type#">
</form>
</cfoutput>


