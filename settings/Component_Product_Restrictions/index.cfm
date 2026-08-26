<!---
***********************************************************************
Created By: Deepa Kunnath
File Path: /deductions/settings/deduction_external_settings.cfm
Created Date: 3/22/2005
Deleted Bit: 0 :)
Purpose: For controlling the deduction settings editable by users
***********************************************************************
--->

<CFSET PAGETITLE = "SYSTEM ADMINISTRATION: COMPONENT PRODUCT RESTRICTIONS">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE></TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfoutput>

<!------ set defaults ----->
<cfparam name="form.state" 	default="0">
<cfparam name="url.command" 	default="Settings1">
<cfparam name="form.command" 	default="#url.command#">
<cfset thisPage = "index.cfm?command=#form.command#">
<cfset formName = "ComponentProductRestrictions">

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<!--- Query existing information --->
<cfquery name="ExistingCriteriaInformation" datasource="#application.datasource#">
SELECT Component_Product_Restriction_Criteria, Component_Product_Restriction_Updated_Date,
_Users.Name_First + ' ' + _Users.Name_Last AS FullName
FROM General_Settings
	INNER JOIN _Users
	ON _USers.User_ID = General_Settings.Component_Product_Restriction_Updated_By
</cfquery>

<!---get product group types--->

<!--- START:  D29684 - Planning Groups and Search Tools/Anand Rao/04-Jan-2012 ---->
<cfset qGetProductGroupTypes = CreateObject("component","components.products.Group.DataManager").getProductGroupsDataNoPG() />
<!--- END: D29684 - Planning Groups and Search Tools/Anand Rao/04-Jan-2012 ----> 

<cfif form.state>
	<!--- Save values --->
	<cfquery name="SaveValues" datasource="#application.datasource#">
	UPDATE General_Settings
	SET Component_Product_Restriction_Criteria = '#form.Component_Product_Restriction_Criteria#', 
		Component_Product_Restriction_Updated_Date = #now()#, 
		Component_Product_Restriction_Updated_By = '#request.AccessStructure.User_ID#'
	</cfquery>
	
	<!--- Delete mapping table --->
	<cfquery name="DeleteFromComponentMappingTable" datasource="#application.datasource#">
	TRUNCATE TABLE Component_Product_Restriction
	</cfquery>
	
	<cfquery name="DeleteFromProductMappingTable" datasource="#application.datasource#">
	TRUNCATE TABLE Component_Products_Restricted
	</cfquery>
	
	<cflocation addtoken="No" url="#thisPage#">
	<cfabort>
</cfif>


<script language="JavaScript">
	function changeDisableSelectBoxes(thisObj, OtherObj)
	{
		
			OtherObj.disabled = !(thisObj.checked);
	}
	function submitForm(thisForm, sCommand)
	{
		if(confirm("If you make a change all previous component selections will be lost. Even if you change back, you will need to recreate every single component restriction selection. Do not change this unless you're very sure about the change!!!"))
		{
			thisForm.command.value = sCommand;
			thisForm.submit();
			return false;
		}
		
	}
</script>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_validations.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>

<form action="#thisPage#" method="post" name="#formName#" style="display:inline;">
	
<cfoutput>

<style>
	.deductionSettingsInput
	{
		text-align:right;
		width:50px;
	}
</style>

<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_validations.js"></SCRIPT>
<br>
<cfif Len(ExistingCriteriaInformation.FullName) GT 0>
<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<TR>
<TD>
	<FONT SIZE="2"><B>The settings were last updated on #dateformat(ExistingCriteriaInformation.Component_Product_Restriction_Updated_Date, 'mm/dd/yyyy')# #timeformat(ExistingCriteriaInformation.Component_Product_Restriction_Updated_Date, 'hh:mm:ss TT')# by #ExistingCriteriaInformation.FullName#</B></FONT>	</TD>
</TD>
</TR>
</TABLE>
<br>
</cfif>
<table cellpadding="2" cellspacing="0" border="0" width="500">

	<tr valign="top">
		<td nowrap>Component restrictions should be based on the following product criteria:
		</td>
		<td>&nbsp; </td>
		<td align="left">
			<select name="Component_Product_Restriction_Criteria">
				<cfloop query="qGetProductGroupTypes">
					<option value="#Product_Group_Level_Id#" <cfif ExistingCriteriaInformation.Component_Product_Restriction_Criteria eq Product_Group_Level_Id>selected</cfif>>#Group_Level_Desc#</option>
				</cfloop>
			</select>
		</td>
	</tr>
</table>

<br><br><br>
<div align="center">
	<CF_button
			button_name		=	""
			button_caption	=	"Save"
			button_action	=	"submitForm(document.#formName#);"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Save"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
</div>
</cfoutput>


	
	
	<input type="Hidden" name="state" value="1">
	<input type="Hidden" name="command" value="#form.command#">
</form>
<CF_MessageWindow />
</cfoutput>
</BODY>
</HTML>
