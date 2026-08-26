<!---
	Name: 	budget_settings.cfm        
	Copyright (c) 2006 Blacksmith Applications, Inc.       
    Author: Clarence Morse         
	Label: 	9906
--->	

<CFSET PageTitle="BUDGET CONTROL PANEL">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<!--- Tweak to get groups and there current status --->
	
	<cfinvoke component="components.settings.budget.budgetsettingsmanager" method="getCategoryID" returnvariable="budgetCategories">
	<cfinvoke component="components.settings.budget.budgetsettingsmanager" method="getSettings" returnvariable="budgetSettings">
	<cfinvoke component="components.settings.budget.budgetsettingsmanager" method="getAllocationTypes" budget_type="1" returnvariable="tradeBudgetAllocationType">    	
	<cfinvoke component="components.settings.budget.budgetsettingsmanager" method="getAllocationTypes" budget_type="2" returnvariable="volumeBudgetAllocationType">
	<cfinvoke component="components.settings.budget.budgetsettingsmanager" method="getVolumeUOM" returnvariable="volumeUOM">
	<cfinvoke component="components.user.usermanager" method="getusername" userid="#budgetSettings.Updated_By#" returnvariable="SettingsUpdateUser">  	
	
	<cfsavecontent variable="saveSettings">
		<cf_button name="SubmitForm" button_type="link" button_caption="Save Settings" button_action="javascript:document.all.budgetsettings.submit()">
	</cfsavecontent>
	
<!--- Pull this out into it's own style sheet --->	
		<style type="text/css">
		
		body 	{font-family:verdana;border:0px; }
		fieldset {width:282px;left:0px;position:relative; }
		td.sectionContainer {vertical-align:top; }
		legend 	{font-weight:bold;font-size:8pt; }
		select 	{font-size:8pt; }
		table 	{font-size:8pt; }
		table.masterData {padding:0px;border=0px; border-collapse:collapse;width:280px; }

		/* Defines Styles Master Data Allocation Table Headers*/
		.thMasterData {	font-weight:bold;
						font-size:8pt;
						border-top: solid 1px blue;
						border-bottom: solid 1px blue;
						border-right: solid 0px RGB(255,255,255);
						border-left: solid 0px RGB(255,255,255);
						background-color:RGB(210,210,255);
						color:RGB(0,0,0); }
		
		/* Defines Styles Master Data Allocation Table include subheaders*/
		.incMasterData {font-size:7pt;
						border-bottom: solid 1px blue;
						text-align:center; }
		
		/* Defines Styles Master Data Allocation Table data cells*/
		
		.tdHeadMasterData {	font-size:7pt;
							width:200px;
							border-bottom: solid 1px blue;
							text-align:left; }
							
		TD.UNDERLINED {		border-bottom: 1px solid blue;   }
					  	
		TR.highlight TD.UNDERLINED 	{	background-color: #EAFFEA;
						 				font-size:7pt;
						 				border-bottom: solid 1px blue; 	}
		TR.nohighlight TD.UNDERLINED {	font-size:7pt;
										border-bottom: solid 1px blue;  }
		</style>
		
		<script type="text/javascript" language="JavaScript">
		function setVisibility(objref)
		{
			if(objref.style.display == 'none')
				objref.style.display = '';
			else if(objref.style.display == 'visible' || objref.style.display == '')
				objref.style.display = 'none';
		}
		
	//function to check or uncheck all checkboxes of category
	function checkMatchingProd(type_code,header)
	{
		var elemColctn2 = document.budgetsettings.getElementsByTagName("input");
		for (var i = 0; i < elemColctn2.length; i++)
		{
			if (elemColctn2[i].id == type_code)
			{
				if (header.checked)
					elemColctn2[i].checked = true;
				else
					elemColctn2[i].checked = false;
			}
		}
	}
	</script>
	
</head>

<body>

<form name="budgetsettings" method="post" action="budget_settings_action.cfm">
<input type="hidden" name="submitted" value="1">
<table>
<cfoutput>
<tr><td colspan="2">
<TABLE ID="lastUpdatedBy" BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<TR>
<TD align="left" width="600px" style="font-size:12px;">
	<B>The budget settings were last updated on <CFOUTPUT>#dateformat(budgetsettings.updated_on, 'm/d/yyy')# #timeformat(budgetsettings.updated_on, 'h:mm:ss TT')# by #SettingsUpdateUser#</CFOUTPUT></B></TD>
</TD>
</TR>
</TABLE>
</td></tr>

</cfoutput>
<tr><td colspan="2"> <cfoutput>#saveSettings#</cfoutput><br></td></tr>
<tr><td class="sectionContainer">
<fieldset>
<legend onClick="setVisibility(document.all.tradeTable);">SETTINGS: TRADE BUDGETS</legend>

<table id="tradeTable" style="display:visible">
<tr><td colspan="3" class="thMasterData">TRADE: BUDGET CONTROL LEVELS</td></tr>
<tr><td colspan="3">
	# OF CONTROL LEVEL(S):	
	<select name="tradeControlLevels">
		<option value="1" <cfif budgetSettings.trade_control_levels EQ 1>SELECTED</cfif> >1</option>
		<option value="2" <cfif budgetSettings.trade_control_levels EQ 2>SELECTED</cfif> >2</option>
	</select>
</td>
</tr>
<cfloop query="budgetCategories">
	<cfset sectionheader = trim(budgetCategories.Category_Desc) />
<tr>
	<td>
		<cfoutput>
		<table id="tradeBudget#sectionheader#Groups" class="masterData">
			<!--- Trade Category --->
			<tr><td colspan="1" class="thMasterData">TRADE: #sectionheader#</td><td class="thMasterData" colspan="2" align="center">(mark all)<input type="checkbox" name="header" onClick="javascript:checkMatchingProd('trade_#sectionheader#',this)"></td></tr>
			<tr><td class="incMasterData"></td><td class="incMasterData">include</td><td class="incMasterData">default</td></tr>
			</cfoutput><cfsilent>
			<cfinvoke component="components.settings.budget.budgetsettingsmanager" 
			  method="getBudgetMasterData" 
			  budgetcategory_id="#budgetCategories.Category_ID#"
			  returnvariable="masterDataGroup">	
			
			<!--- Output Groups from Lookup Table --->
			</cfsilent><cfoutput query="masterDataGroup">
				<tr onmouseover="this.bgColor='RGB(225,255,225)';" onmouseout="this.bgColor='white';">
					<td class="tdHeadMasterData">#UCASE(masterDataGroup.Group_Level_Desc)#</td>
					<td  class="underlined" align="center" >
						<input type="checkbox" id="trade_#sectionheader#" name="trade#sectionheader#Group_#masterDataGroup.Budget_Group_Level_ID#" value="1" <cfif masterDataGroup.trade_active EQ 1>CHECKED</cfif> >
					</td>
					<td  class="underlined" align="center" >
						<input type="radio" name="trade#sectionheader#GroupSelection" value="#masterDataGroup.Budget_Group_Level_ID#" <cfif evaluate("budgetSettings.trade_#sectionheader#_Group_Selection") EQ masterDataGroup.Budget_Group_Level_ID>CHECKED</cfif>>
					</td>
				</tr>
			</cfoutput>
			<!--- None Category --->
			<cfoutput>			
			<tr onmouseover="this.bgColor='RGB(225,255,225)';" onmouseout="this.bgColor='white';">
				<td class="tdHeadMasterData" colspan="2">NO DEFAULT</td><td class="underlined" align="center">
					<input type="radio" name="trade#sectionheader#GroupSelection" value="0" <cfif evaluate("budgetSettings.trade_#sectionheader#_Group_Selection") EQ 0>CHECKED</cfif>>
				</td>
			</tr>
			</cfoutput>
		</table>
</td></tr>
</cfloop>
<tr><td>
		<table id="tradeAllocation" class="masterData">
			<!--- Trade Allocation --->
			<tr><td colspan="3" class="thMasterData">TRADE: ALLOCATION TYPES</td></tr>
			<tr><td class="incMasterData"></td><td class="incMasterData">include</td><td class="incMasterData">default</td></tr>
			<!--- Output Groups from Lookup Table --->
			<cfoutput query="tradeBudgetAllocationType">
				<tr onmouseover="this.bgColor='RGB(225,255,225)';" onmouseout="this.bgColor='white';">
					<td class="tdHeadMasterData">#tradeBudgetAllocationType.allocation_desc#</td>
					<td class="underlined" align="center">
						<input type="checkbox" name="tradeAllocationType_#allocation_id#" value="1" <cfif trade_include EQ 1>CHECKED</cfif>>
					</td>
					<td class="underlined" align="center">
						<input type="radio" name="tradeAllocationTypeSelection" value="#tradeBudgetAllocationType.allocation_id#" <cfif budgetSettings.trade_allocation_type_selection EQ allocation_id>CHECKED</cfif>>
					</td>
				</tr>
			</cfoutput>
			<!---Default None Category --->			
			<tr onmouseover="this.bgColor='RGB(225,255,225)';" onmouseout="this.bgColor='white';">
				<td class="tdHeadMasterData" colspan="2">NO DEFAULT</td>
				<td class="underlined" align="center">
					<input type="radio" name="tradeAllocationTypeSelection" value="0" <cfif budgetSettings.trade_allocation_type_selection EQ 0>CHECKED</cfif>>
				</td>
			</tr>
		</table>
	</td>
</tr>
</table>
</fieldset>
</td><td class="sectionContainer">
<fieldset>
<legend onClick="setVisibility(document.all.volumeTable);">SETTINGS: VOLUME BUDGETS</legend>
<table id="volumeTable" style="display:visible">
<tr><td colspan="3" class="thMasterData">VOLUME: BUDGET CONTROL LEVELS</td></tr>
<tr><td colspan="3">
	# OF CONTROL LEVEL(S):
	<select name="volumeControlLevels">
		<option value="1" <cfif budgetSettings.volume_control_levels EQ 1>SELECTED</cfif> >1</option>
		<option value="2" <cfif budgetSettings.volume_control_levels EQ 2>SELECTED</cfif> >2</option>
	</select>
</td>
</tr>
<cfloop query="budgetCategories">
	<cfset sectionheader = trim(budgetCategories.Category_Desc) />
<tr>
	<td>
		<cfoutput>
		<table id="volumeBudget#trim(budgetCategories.Category_Desc)#Groups" class="masterData">
			<!--- Volume Category --->
			<tr><td colspan="1" class="thMasterData">VOLUME: #sectionheader#</td><td class="thMasterData"  colspan="2" align="center">(mark all)<input type="checkbox" name="header" onClick="javascript:checkMatchingProd('volume_#sectionheader#',this)"></td></tr>
			<tr><td class="incMasterData"></td><td class="incMasterData">include</td><td class="incMasterData">default</td></tr>
			</cfoutput><cfsilent>
			<cfinvoke component="components.settings.budget.budgetsettingsmanager" 
			  method="getBudgetMasterData" 
			  budgetcategory_id="#budgetCategories.Category_ID#"
			  returnvariable="masterDataGroup">	
			
			<!--- Output Groups from Lookup Table --->
			</cfsilent><cfoutput query="masterDataGroup">
				<tr onmouseover="this.bgColor='RGB(225,255,225)';" onmouseout="this.bgColor='white';">
					<td class="tdHeadMasterData">#UCASE(masterDataGroup.Group_Level_Desc)#</td>
					<td class="underlined" align="center">
						<input type="checkbox"  id="volume_#sectionheader#"  name="volume#sectionheader#Group_#masterDataGroup.Budget_Group_Level_ID#" value="1" <cfif masterDataGroup.volume_active EQ 1>CHECKED</cfif>>
					</td>
					<td class="underlined" align="center">
						<input type="radio" name="volume#sectionheader#GroupSelection" value="#masterDataGroup.Budget_Group_Level_ID#" <cfif evaluate("budgetSettings.volume_#sectionheader#_Group_Selection") EQ masterDataGroup.Budget_Group_Level_ID>CHECKED</cfif>>
					</td>
				</tr>
			</cfoutput>
			<!--- None Category --->
			<cfoutput>			
			<tr onmouseover="this.bgColor='RGB(225,255,225)';" onmouseout="this.bgColor='white';">
				<td class="tdHeadMasterData" colspan="2">NO DEFAULT</td>
				<td class="underlined" align="center" >
					<input type="radio" name="volume#trim(budgetCategories.Category_Desc)#GroupSelection" value="0" <cfif evaluate("budgetSettings.volume_#sectionheader#_Group_Selection") EQ 0>CHECKED</cfif>>
				</td>
			</tr>
			</cfoutput>
		</table>
</td></tr>
</cfloop>
<tr><td>
		<table id="volumeAllocation" class="masterData">
			<!--- Volume Allocation --->
			<tr><td colspan="3" class="thMasterData">VOLUME: ALLOCATION TYPES</td></tr>
			<tr><td class="incMasterData"></td><td class="incMasterData">include</td><td class="incMasterData">default</td></tr>
			<!--- Output Groups from Lookup Table --->
			<cfoutput query="volumeBudgetAllocationType">
				<tr onmouseover="this.bgColor='RGB(225,255,225)';" onmouseout="this.bgColor='white';">
					<td class="tdHeadMasterData">#volumeBudgetAllocationType.allocation_desc#</td>
					<td class="underlined" align="center">
						<input type="checkbox" name="volumeAllocationType_#allocation_id#" value="1"  <cfif volume_include EQ 1>CHECKED</cfif>>
					</td>
					<td class="underlined" align="center">
						<input type="radio" name="volumeAllocationTypeSelection" value="#volumeBudgetAllocationType.allocation_id#" <cfif budgetSettings.volume_allocation_type_selection EQ allocation_id>CHECKED</cfif>>
					</td>
				</tr>
			</cfoutput>
			<!---Default None Category --->			
			<tr onmouseover="this.bgColor='RGB(225,255,225)';" onmouseout="this.bgColor='white';">
				<td class="tdHeadMasterData" colspan="2">NO DEFAULT</td><td class="underlined" align="center">
					<input type="radio" name="volumeAllocationTypeSelection" value="0"  <cfif budgetSettings.volume_allocation_type_selection EQ 0>CHECKED</cfif>>
				</td>
			</tr>
		</table>
	</td>
</tr>
	<tr><td>
		<table id="volumeUOM" class="masterData">
			<!--- Volume Unit of Measure --->
			<tr><td colspan="3" class="thMasterData">VOLUME: UNIT OF MEASURE OPTIONS</td></tr>
			<tr><td class="incMasterData"></td><td class="incMasterData">include</td><td class="incMasterData">default</td></tr>
			<!--- Output Groups from Lookup Table --->
				<cfoutput query="volumeUOM">
					<tr onmouseover="this.bgColor='RGB(225,255,225)';" onmouseout="this.bgColor='white';">
						<td class="tdHeadMasterData">#volume_uom_desc#</td><td class="underlined" align="center">
							<input type="checkbox" name="volumeUOM_#volume_uom_id#" value="1" <cfif volume_include EQ 1>CHECKED</cfif>>
						</td>
						<td class="underlined" align="center" >
							<input type="radio" name="volumeUOMSelection" value="#volume_uom_id#" <cfif budgetSettings.volume_uom_selection EQ volume_uom_id>CHECKED</cfif>>
						</td>
					</tr>
				</cfoutput>
			<!---Default None Category --->			
			<tr onmouseover="this.bgColor='RGB(225,255,225)';" onmouseout="this.bgColor='white';"><td class="tdHeadMasterData" colspan="2">NO DEFAULT</td><td class="underlined" align="center"><input type="radio" name="volumeUOMSelection" value="0" <cfif budgetSettings.volume_uom_selection EQ 0>CHECKED</cfif>></td></tr>
		</table>
	</td>
</tr>
</table>
</fieldset>
</tr>
<tr><td colspan="2"><cfoutput>#saveSettings#</cfoutput></td></tr>
</table>
</form>
</body>
</html>

