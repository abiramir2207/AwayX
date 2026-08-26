<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfif NOT isDefined("appSettings")>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
</cfif>
<HTML>
<HEAD>
	<TITLE>Untitled</TITLE>
	<style>
		body,td	{
			font-family:		Arial;
			font-size:			12px;
		}
		a,a:visited{
			color:				Blue;
			text-decoration:	None;
		}
		a:hover{
			color:				Red;
			text-decoration:	Underline;
		}
		td.borders	{
			border-bottom:		1px Solid blue; 
			font-weight:		Bold;
		}
		TR.highlight	{
			background-color: #D9FFDB;
			cursor:				pointer;
		}
		TR.nothighlight{
			background-color: #FFFFFF;
		}
		TD.maintable{
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
<cfset pageName = "revision_settings">

<CFSET PAGETITLE = "PROGRAM TEMPLATES: REVISION">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<cfparam name="url.id" 	default="0">
<cfparam name="FormStatus" default="">
<cfparam name="LockedBy_Current_User" 	default="0">
<cfparam name="url.DownloadSettings" 	default="0">

<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
<cfset template = templateManager.get(url.id)>
	
	
<!------ display header ----->
<cfset Created_Type = template.getCreatedType()>
<cfset Generic_Type = template.getGenericType()>
<cfset Active = template.getActive()>	
<cfinclude template="header.cfm">
<br>
<!--- Get the settings from the database --->

<cfset templateRevisionSettings = templateManager.getTemplateRevisionSettings(url.id) />

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

<cfif LockedBy_Current_User NEQ 1>
	<cfset FormStatus = "disabled">
</cfif>

<FORM ACTION="save_revision_settings.cfm" METHOD="post" name="MyForm" ID="MyForm" style="display:inline">
<div style="margin:5px 0;">
	<span style="width:60%;"><img src="/images/ico-info.gif"> <span class="headingTip">All changes on this page will be saved retroactively for all previous versions.</span></span>
	<cfif LockedBy_Current_User EQ 1>
	  <cfoutput>
		<span style="width:39%;text-align:right;"><a href="javascript:document.all.MyForm.submit();">#application.util.string.actionLinkFormat("save and continue")#</a></span>
	  </cfoutput>
	</cfif>
</div>
    
<TABLE BORDER="0" WIDTH="100%" ID="bigTable" CELLSPACING="0" CELLPADDING="2">
  <col width="40%"> <col width="10%"> <col width="50%">
	<cfoutput>
	<cfif url.DownloadSettings>
		<cfset SDValue = 'No'>
		<cfif templateRevisionSettings.Apply_to_All NEQ 2>
			<cfset SDValue = 'Yes'>
		</cfif>
		<cfset SettingsToExcel (Setting_name='These settings apply to all program revisions', Setting_Field_name='Apply_to_All', Setting_value='#SDValue#', Page='5')>
		<cfset SDValue = 'No'>
		<cfif templateRevisionSettings.Apply_to_All EQ 2>
			<cfset SDValue = 'Yes'>
		</cfif>
		<cfset SettingsToExcel (Setting_name='These settings apply only to programs sent to ERP', Setting_Field_name='Apply_to_All', Setting_value='#SDValue#', Page='5')>
	<cfelse>
		<tr><th COLSPAN="3">These settings apply...</th></tr>
		<tr>
			<td>&nbsp;&nbsp; ...to all program revisions</td>
			<td><input  type="radio" value="1" name="Apply_to_All" CHECKED #FormStatus#></td>
		</tr>
		<tr>
			<td>&nbsp;&nbsp; ...only to programs sent to ERP</td>
			<td><input  type="radio" value="2" name="Apply_to_All"<CFIF templateRevisionSettings.Apply_to_All EQ 2> CHECKED</CFIF> #FormStatus#></td>
		</tr>
	</cfif>
	<tr>
		<th COLSPAN="3"><hr>Basic Information</th>
	</tr>
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Allow changes to the title of the program', Setting_Field_name='Title_Changes', Page='5')>
<cfelse>	
	<tr>
		<td>Allow changes to the title of the program</td>
		<td><input  type="radio" value="1" name="Title_Changes" CHECKED #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Title_Changes"<CFIF templateRevisionSettings.Title_Changes EQ 2> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
</cfif>	
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Allow changes to the Start of the program', Setting_Field_name='Date_Changes', Page='5')>
<cfelse>	
	<tr>
		<td>Allow changes to the Start of the program</td>
		<td><input  type="radio" value="1"  name="Date_Changes" CHECKED #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Date_Changes"<CFIF templateRevisionSettings.Date_Changes EQ 2> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
</cfif>	
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Allow changes to the End Dates of the program', Setting_Field_name='Date_Changes_End', Page='5')>
<cfelse>	
	<tr>
		<td>Allow changes to the End Dates of the program</td>
		<td><input  type="radio" value="1"  name="Date_Changes_End" CHECKED #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Date_Changes_End"<CFIF templateRevisionSettings.Date_Changes_End EQ 2> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>	
</cfif>	
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Allow program revision Start Dates to be later than the original', Setting_Field_name='Start_Date_Change', Page='5')>
<cfelse>	
	<tr>
		<td>Allow program revision Start Dates to be later than the original</td>
		<td><input  type="radio" value="1"  name="Start_Date_Change" CHECKED #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Start_Date_Change"<CFIF templateRevisionSettings.Start_Date_Change EQ 2> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
	</cfif>	
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Allow program revision End Date to be earlier than the original start date', Setting_Field_name='End_Date_Change', Page='5')>
<cfelse>	
	<tr>
		<td>Allow program revision End Date to be earlier than the original start date</td>
		<td><input  type="radio" value="1"  name="End_Date_Change" CHECKED #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="End_Date_Change"<CFIF templateRevisionSettings.End_Date_Change EQ 2> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
	</cfif>	
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Allow payment frequency to be changed', Setting_Field_name='Payment_Frequency_Changes', Page='5')>
<cfelse>	
	<!--- Dev Note: Kal: 12047 : Disable Payment Frequency on Revise --->
	<tr>
		<td>Allow payment frequency to be changed</td>
		<td><input  type="radio" value="1"  name="Payment_Frequency_Changes" CHECKED #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Payment_Frequency_Changes"<CFIF templateRevisionSettings.Payment_Frequency_Changes EQ 2> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
		</cfif>	
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Allow change to program currency', Setting_Field_name='Currency_Change', Page='5')>
<cfelse>	
	<!---77418 :: New Option in Program Revision Tab - Allow change to currency START---->
		<tr>
		<td>Allow change to program currency</td>
		<td><input  type="radio" value="1" name="Currency_Change" CHECKED #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Currency_Change"<CFIF templateRevisionSettings.Currency_Change EQ 2> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
	<!---77418 :: New Option in Program Revision Tab - Allow change to currency END---->
			</cfif>	
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Require public notes to be changed', Setting_Field_name='Require_Public_Notes_Changed', Page='5')>
<cfelse>	
	<tr>
		<td>Require public notes to be changed</td>
		<td><input  type="radio" value="1"  name="Require_Public_Notes_Changed" CHECKED #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Require_Public_Notes_Changed"<CFIF templateRevisionSettings.Require_Public_Notes_Changed EQ 2 OR templateRevisionSettings.Require_Public_Notes_Changed EQ ""> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
				</cfif>	
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Require business considerations to be changed', Setting_Field_name='Require_Private_Notes_Changed', Page='5')>
<cfelse>
	<tr>
		<td>Require business considerations to be changed</td>
		<td><input  type="radio" value="1"  name="Require_Private_Notes_Changed" CHECKED #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Require_Private_Notes_Changed"<CFIF templateRevisionSettings.Require_Private_Notes_Changed EQ 2 OR templateRevisionSettings.Require_Private_Notes_Changed EQ ""> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
</cfif>
	<tr>
		<th COLSPAN="3"><hr>Products & Rates</th>
	</tr>
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Allow products to be added', Setting_Field_name='Products_Added', Page='5')>
<cfelse>
	<tr>
		<td>Allow products to be added</td>
		<td><input  type="radio" value="1"  name="Products_Added" CHECKED #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Products_Added"<CFIF templateRevisionSettings.Products_Added EQ 2> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
</cfif>
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Allow products to be removed', Setting_Field_name='Products_Removed', Page='5')>
<cfelse>
	<tr>
		<td>Allow products to be removed</td>
		<td><input  type="radio" value="1"  name="Products_Removed" CHECKED #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Products_Removed"<CFIF templateRevisionSettings.Products_Removed EQ 2> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
</cfif>
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Allow changes to the products rates offered', Setting_Field_name='Products_Rates_Changes', Page='5')>
<cfelse>	
	<tr>
		<td>Allow changes to the products rates offered</td>
		<td><input  type="radio" value="1"  name="Products_Rates_Changes" CHECKED #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Products_Rates_Changes"<CFIF templateRevisionSettings.Products_Rates_Changes EQ 2> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
</cfif>
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Allow changes to the unit of measure', Setting_Field_name='Products_UOM_Changes', Page='5')>
<cfelse>		
	<tr>
		<td>Allow changes to the unit of measure</td>
		<td><input  type="radio" value="1"  name="Products_UOM_Changes"  CHECKED #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Products_UOM_Changes"<CFIF templateRevisionSettings.Products_UOM_Changes EQ 2> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
</cfif>
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Allow growth targets/tiers to be changed', Setting_Field_name='Growth_Change_Target', Page='5')>
<cfelse>	
	<tr>
		<td>Allow growth targets/tiers to be changed</td>
		<td><input  type="radio" value="1"  name="Growth_Change_Target" CHECKED #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Growth_Change_Target"<CFIF templateRevisionSettings.Growth_Change_Target EQ 2> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
</cfif>
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Allow lump sum components to be changed', Setting_Field_name='Lump_Sum_Changed', Page='5')>
<cfelse>
	<tr>
		<td>Allow lump sum components to be changed</td>
		<td><input  type="radio" value="1"  name="Lump_Sum_Changed" CHECKED #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Lump_Sum_Changed"<CFIF templateRevisionSettings.Lump_Sum_Changed EQ 2> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
</cfif>
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Allow lump sum components to be created', Setting_Field_name='Lump_Sum_Created', Page='5')>
<cfelse>
	<tr>
		<td>Allow lump sum components to be created</td>
		<td><input  type="radio" value="1"  name="Lump_Sum_Created" CHECKED #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Lump_Sum_Created"<CFIF templateRevisionSettings.Lump_Sum_Created EQ 2> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
</cfif>
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Allow lump sum components to be removed', Setting_Field_name='Lump_Sum_Removed', Page='5')>
<cfelse>
	<tr>
		<td>Allow lump sum components to be removed</td>
		<td><input  type="radio" value="1"  name="Lump_Sum_Removed" CHECKED  #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Lump_Sum_Removed"<CFIF templateRevisionSettings.Lump_Sum_Removed EQ 2> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
</cfif>
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Allow claim mechanic to be changed', Setting_Field_name='Claim_Mechanic_Changed', Page='5')>
<cfelse>
	<tr>
		<td>Allow claim mechanic to be changed</td>
		<td><input  type="radio" value="1"  name="Claim_Mechanic_Changed" CHECKED  #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Claim_Mechanic_Changed"<CFIF templateRevisionSettings.Claim_Mechanic_Changed EQ 2> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
</cfif>
	<tr>
		<th COLSPAN="3"><hr>Customers</th>
	</tr>
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Allow distributors to be added', Setting_Field_name='Distributors_Added', Page='5')>
<cfelse>
	<tr>
		<td>Allow distributors to be added</td>
		<td><input  type="radio" value="1"  name="Distributors_Added" CHECKED #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Distributors_Added"<CFIF templateRevisionSettings.Distributors_Added EQ 2> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
</cfif>	
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Allow distributors to be removed', Setting_Field_name='Distributors_Removed', Page='5')>
<cfelse>
	<tr>
		<td>Allow distributors to be removed</td>
		<td><input  type="radio" value="1"  name="Distributors_Removed" CHECKED #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Distributors_Removed"<CFIF templateRevisionSettings.Distributors_Removed EQ 2> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
</cfif>	
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Allow operators to be added', Setting_Field_name='Operators_Added', Page='5')>
<cfelse>
	<tr>
		<td>Allow operators to be added</td>
		<td><input  type="radio" value="1"  name="Operators_Added" CHECKED #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Operators_Added"<CFIF templateRevisionSettings.Operators_Added EQ 2> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
</cfif>	
<cfif url.DownloadSettings>
	<cfset SettingsToExcel (Setting_name='Allow operators to be removed', Setting_Field_name='Operators_Removed', Page='5')>
<cfelse>
	<tr>
		<td>Allow operators to be removed</td>
		<td><input  type="radio" value="1"  name="Operators_Removed" CHECKED #FormStatus#> Yes</td>
		<td><input  type="radio" value="2" name="Operators_Removed"<CFIF templateRevisionSettings.Operators_Removed EQ 2> CHECKED</CFIF> #FormStatus#> No</td>
	</tr>
</cfif>
	</cfoutput>

<cfif appSettings.getRenew_expired_programs()>
	<cfif url.DownloadSettings>
		<cfset SettingsToExcel (Setting_name='Days after program end date which program is no longer eligible to be revised', Setting_Field_name='End_Date_Revision_Not_Eligibile', Page='5')>
		<cfset SDValue = #templateRevisionSettings.End_Date_Revision_Not_Eligibile_Days#>
		<cfset SettingsToExcel (Setting_name='Days after program end date which program is no longer eligible to be revised', Setting_Field_name='End_Date_Revision_Not_Eligibile_Days', Setting_value='#SDValue# Days', Page='5')>
	<cfelse>
		<tr><th COLSPAN="3"><hr>General</th></tr>
		<tr>
			<td>Days after program end date which program is no longer eligible to be revised</td>
			<td><input  type="checkbox" value="1"  name="End_Date_Revision_Not_Eligibile" <cfif templateRevisionSettings.End_Date_Revision_Not_Eligibile EQ 1> CHECKED </cfif>onChange="javascript: if(this.checked){document.all.End_Date_Revision_Not_Eligibile_Days.disabled = false; document.all.End_Date_Revision_Not_Eligibile_Days.style.backgroundColor='white';}else{document.all.End_Date_Revision_Not_Eligibile_Days.disabled = true; document.all.End_Date_Revision_Not_Eligibile_Days.style.backgroundColor='#cccccc';}" <cfoutput> #FormStatus#</cfoutput>></td>
			<td><cfoutput><input  type="textbox" value="#templateRevisionSettings.End_Date_Revision_Not_Eligibile_Days#" name="End_Date_Revision_Not_Eligibile_Days" size="6" maxlength="6" <cfif templateRevisionSettings.End_Date_Revision_Not_Eligibile NEQ 1>DISABLED STYLE="background-color:##cccccc;"</cfif> ONKEYPRESS="javaScript: return Allow_Key_List('0123456789');"></cfoutput></td>
		</tr>	
	</cfif>	
</cfif>
</TABLE>

<BR>
<cfif LockedBy_Current_User EQ 1>
		<table align="center" border="0" cellpadding="0" cellspacing="0">
	<tr>		
		<td>
		
		<CF_button
			button_name		=	""
			button_caption	=	"save and continue"
			button_action	=	"document.all.MyForm.submit();"
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
<input  name="Template_ID" type="Hidden" value="#url.id#">
</cfoutput>
</FORM>	

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>
