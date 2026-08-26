<!---
Name: settings\Settings_Management\Settings_Profile.cfm.cfm
Copyright (c) 2010 Blacksmith Applications, Inc.
Description:
Manage profile settings and Blacksmith users can configure whether a setting should be shown or not
--->
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/locked-column.css">

<style>
tbody td { border-bottom:solid #93BEE2 1px;vertical-align:middle;font-size: 11px;}	

thead th, thead th.locked	{
	font-size: 12px;
	font-weight: bold;
	text-align: left;
	background-color: #DDDDDD;
	color: blue;
	border-right: 1px solid silver;
	position:relative;
	cursor: default;
	HEIGHT:18;
}

#tbl-containerSmall {
	OVERFLOW: auto; 
	WIDTH: 99.9%; 
	HEIGHT:450;
}
</style>

<CFSCRIPT>
	Border="Yes";
	BorderSize=1;
	BorderColor="orange";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Blue";
	TitleFont="Arial";
	TitleSize=9;
	IsClosed="No";
</CFSCRIPT>

<script type="text/javascript">
function massUpdateCheckAll(ShowHide)
{
	var str = '';
	var elem = document.getElementById('ProfileSettingsManagement').elements;
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

function confirmCompletion(disableClickedButton, disableClickedButtonName1,disableClickedButtonName2)
{ 
	var ErrorCount = 0;
	if(ErrorCount == 0) 
	{	
		ProfileSettingsManagement.action = "Settings_Profile_Save.cfm"
		ProfileSettingsManagement.submit();
	}
	else 
	{ 
		showMessageWindow()
	}	
}
</script>

<cfparam name="hdrColumnWidth" default = 0>
<cfparam name="getProfiles.recordcount" default = 0>

<cfset i = 1>
<cfset Locked =0>
<cfset saveToXl = 0>
<cfset fName = "0">
<cfset templateSettings.Specify_Operators = 1>
<cfset TD_Width = 70>
<cfset fromSettings_management = 1>
<cfset profile_id = 0>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset getSettingsManagerProfiles = CreateObject("component", "components.settings.settings_management.TemplateSettingsManager").getProfileSettings()>
<cfset getProfiles = CreateObject("component", "components.settings.profiles.profile").getAllProfiles()>
<cfset UserSetting = CreateObject("component","components.user.Profile").getUserSettingsPanel(request.AccessStructure.Profiles_ID)>


<!---Does the company have a default price list?--->
<cfquery name="TableExists" datasource="#application.datasource#">
	SELECT * FROM Information_Schema.Tables
	WHERE Table_Name = 'Price_List_Default'
</cfquery>

<cfset useLakebaseForGetLumpSums = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sum_name")>
<cfif useLakebaseForGetLumpSums>
	<cftry>
		<cfset GetLumpSums = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_lump_sum_name", {
				"deleted" = "eq.0",
				"active" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetLumpSums = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetLumpSums>
<cfquery name="GetLumpSums" datasource="#application.datasource#">
	SELECT *
	FROM Program_Lump_Sum_Name
	WHERE Deleted = 0
	AND Active = 1
</cfquery>
</cfif>

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<cfset UseCustomerType = appSettings.getCustomertype()>
<cfif UseCustomerType IS 1>
	<cfset useLakebaseForGetCustomerTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("customer_type")>
<cfif useLakebaseForGetCustomerTypes>
	<cftry>
		<cfset GetCustomerTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("customer_type", {
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCustomerTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCustomerTypes>
<cfquery name="GetCustomerTypes" datasource="#application.datasource#">
	SELECT *
	FROM Customer_Type
	WHERE Deleted = 0
	</cfquery>
</cfif>
</cfif>

<center>
<cfset Generic_Type = "#Form.Generic_Type#">

<form action="wSettings_Profile_Save.cfm" method="post" name="ProfileSettingsManagement" id="ProfileSettingsManagement" style="display:inline;">
<table width="90%" align="center" cellspacing="0" cellpadding="1"  border="0">
	<tr valign="middle">
		<td align="right"><!--- Dev Note: KAL - D7952 : Lock/Unlock Template: Displaying save option if current user locks the template for editing --->
					<CF_button
							button_name	=	"save1"
							button_caption	=	"Save Settings"
							button_action	=	"confirmCompletion(1, 'save1_table','save2_table');"
							button_type	=	"javascript_link"
							button_width	=	"250"
							button_color	=	"Navy"
							button_tip		=	"Save Settings"
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
							>	
		</td>
	</tr>
</table>

<DIV> 
<TABLE class="tbl" style="TOP: 0px;" width="90%" >
	<THEAD id="tbl_head">
		<TR>
			<TH  name="bufferTD" class="locked" align="left" valign="middle" style="z-index:40" nowrap>
				Profile Settings
			</TH>
			<TH align="left" valign="middle" width="270">&nbsp;&nbsp;
				<input type="checkbox" name="selectallShow" id="selectallShow" value="1" onclick="javascript:massUpdateCheckAll(1);" title="Show All Settings">show&nbsp;&nbsp;&nbsp;
				<input type="checkbox" name="selectallHide" id="selectallHide" value="1" onclick="javascript:massUpdateCheckAll(0);" title="Hide All Settings Hide">Hide
			</TH>
		</TR>
	</THEAD>
	<!--- <TBODY id="tbl_body">  <cfoutput> were included in /settings/Access_Rights/access_rights_matrix.cfm --->
	<CFINCLUDE TEMPLATE="/settings/Access_Rights/access_rights_matrix.cfm">
	<!--- </TBODY> </TABLE> </DIV> </cfoutput> were included in /settings/Access_Rights/access_rights_matrix.cfm --->
<br>
<cfoutput>
<input type="hidden" name="Generic_Type" value="#Generic_Type#">
<div align="center"><CF_button
			button_name		=	"save2"
			button_caption	=	"Save Settings"
			button_action	=	"confirmCompletion(1, 'save2_table', 'save1_table');"
			button_type		=	"javascript_link"
			button_width	=	"250"
			button_color	=	"Navy"
			button_tip		=	"Save Settings"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>	
</div>
</cfoutput>
</form>
</center>