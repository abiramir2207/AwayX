<!---
***********************************************************************
Created By: Deepa Kunnath
File Path: /deductions/settings/deduction_external_settings.cfm
Created Date: 3/22/2005
Deleted Bit: 0 :)
Purpose: For controlling the deduction settings editable by users
***********************************************************************
--->

<CFSET PAGETITLE = "SYSTEM ADMINISTRATION: SUB-TOTAL DISPLAY SETTINGS">
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
<cfset thisPage = "sub_total_display.cfm?command=#form.command#">
<cfset formName = "frmSubTotalDisplaySettings">
<cfparam name="form.Display_Product_Group_BB" 	default="0"> <!--- D10258 --->
<cfparam name="form.Group_Claim_By_Product_Attribute" 	default="0"> <!--- D10258 --->


<cfset BillbackSettingsManager = CreateObject("component", "components.billback.BillbackSettingsManager") />
<cfset getSubtotalDisplaySettings = BillbackSettingsManager.getSubtotalDisplaySettings()>

<!---get product group types--->

<!--- START:  D29684 - Planning Groups and Search Tools/Anand Rao/04-Jan-2012 ---->
<cfset qGetProductGroupTypes = CreateObject("component","components.products.Group.DataManager").getProductGroupsDataNoPG() />
<!--- END: D29684 - Planning Groups and Search Tools/Anand Rao/04-Jan-2012 ----> 

<cfif form.state>
	<cfset BillbackSettingsManager.save(form.Display_Product_Group_BB,form.Group_Claim_By_Product_Attribute,request.AccessStructure.User_ID)>
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
		thisForm.command.value = sCommand;
		thisForm.submit();
		return false;
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
<cfif Len(getSubtotalDisplaySettings.BB_Product_Group_Updated_By) GT 0>
<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<TR>
<TD>
	<FONT SIZE="2"><B>The settings were last updated on #dateformat(getSubtotalDisplaySettings.BB_Product_Group_Updated_Date, 'mm/dd/yyyy')# #timeformat(getSubtotalDisplaySettings.BB_Product_Group_Updated_Date, 'hh:mm:ss TT')# by #getSubtotalDisplaySettings.UpdatedByFullName#</B></FONT>	</TD>
</TD>
</TR>
</TABLE>
<br>
</cfif>
<table cellpadding="2" cellspacing="0" border="0" width="500">
	<tr valign="top">
		<td nowrap>Subtotal claim information on billback summary and detail pages? :
		</td>
		<td>&nbsp; </td>
		<td align="left"><input value="1" type="checkbox" name="Display_Product_Group_BB" <cfif getSubtotalDisplaySettings.Display_Product_Group_BB EQ 1>checked</cfif> onClick="changeDisableSelectBoxes(this, this.form.Group_Claim_By_Product_Attribute);"></td> 
	</tr>
	<tr valign="top">
		<td nowrap>Group the subtotals by the following product attribute:
		</td>
		<td>&nbsp; </td>
		<td align="left">
			<select name="Group_Claim_By_Product_Attribute" <cfif getSubtotalDisplaySettings.Display_Product_Group_BB EQ 0>disabled</cfif>>
				<cfloop query="qGetProductGroupTypes">
					<option value="#Product_Group_Level_Id#" <cfif getSubtotalDisplaySettings.Group_Claim_By_Product_Attribute eq Product_Group_Level_Id>selected</cfif>>#Group_Level_Desc#</option>
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
