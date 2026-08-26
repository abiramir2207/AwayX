<!---
	copyright (c)2013 blacksmith applications, inc.       
	filename:		c:\work\base\awayx\settings\limited_revise.cfm
	created:		10/21/2013
	developer:		drachala
	description:	<brief description of what the file is used for>
	usage:			<templates that depend on this file>
	tip:			<gotchas>
--->
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
		TD.maintable
		{
			border-bottom: 1px solid #C1C2FF;
		}
</style>
<CFSET PAGETITLE = "LIMITED REVISION SETTINGS">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<cfparam name="form.status" default="0">

<cfif form.status>
<!--- First set the deleted bit to one for the entrie in the table --->
	<CFQUERY NAME="Set_Deleted" DATASOURCE="#application.datasource#">
		UPDATE 	Limited_Revision_Settings
		SET 		Deleted = 1
		WHERE		Deleted = 0
	</CFQUERY>
	<!--- Then insert the latest settings... --->
	<CFQUERY NAME="Save_Data" DATASOURCE="#application.datasource#">
		INSERT INTO Limited_Revision_Settings
			(
			Title_Changes,
			Date_Changes,
			Date_Changes_End,
			Start_Date_Change,
			End_Date_Change,
			Payment_Frequency_Changes,
			Require_Public_Notes_Changed,
			Require_Private_Notes_Changed,
			Products_Added,
			Products_Removed,
			Products_Rates_Changes,
			Products_UOM_Changes,
			Growth_Change_Target,
			Lump_Sum_Changed,
			Lump_Sum_Created,
			Lump_Sum_Removed,
			Pay_To_Component,
			Claim_Mechanic_Changed,
			Distributors_Added,
			Distributors_Removed,
			Operators_Added,
			Operators_Removed,
			Limited_Revision_Setting_Created_By		
			)
		Values	(
			<cfqueryparam value="#Form.Title_Changes#" 				cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.Date_Changes#" 				cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.Date_Changes_End#" 				cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.Start_Date_Change#" 			cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.End_Date_Change#" 			cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.Payment_Frequency_Changes#" 	cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.Require_Public_Notes_Changed#" 	cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.Require_Private_Notes_Changed#" 	cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.Products_Added#" 			cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.Products_Removed#" 			cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.Products_Rates_Changes#" 		cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.Products_UOM_Changes#" 		cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.Growth_Change_Target#" 		cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.Lump_Sum_Changed#" 			cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.Lump_Sum_Created#" 			cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.Lump_Sum_Removed#" 			cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.Pay_To_Component#" 			cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.Claim_Mechanic_Changed#" 		cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.Distributors_Added#" 			cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.Distributors_Removed#" 			cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.Operators_Added#" 			cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#Form.Operators_Removed#" 			cfsqltype="cf_sql_bit">,
			<cfqueryparam value="#request.AccessStructure.user_id#" 		cfsqltype="cf_sql_varchar">
			)
	</CFQUERY>
</cfif>
	<cfquery name="pull_data" datasource="#application.datasource#">
		SELECT Limited_Revision_Settings.* , U.name_first +' '+U.name_last AS Name
		FROM Limited_Revision_Settings
		LEFT JOIN _users U
		ON U.user_id = Limited_Revision_Settings.Limited_Revision_Setting_Created_By
		WHERE Limited_Revision_Settings.Deleted = 0
	</cfquery>

<cfparam name="Form.Title_Changes" 				default="#pull_data.Title_Changes#">
<cfparam name="Form.Date_Changes" 				default="#pull_data.Date_Changes#">
<cfparam name="Form.Date_Changes_End" 				default="#pull_data.Date_Changes_End#">
<cfparam name="Form.Start_Date_Change" 			default="#pull_data.Start_Date_Change#">
<cfparam name="Form.End_Date_Change" 			default="#pull_data.End_Date_Change#">
<cfparam name="Form.Payment_Frequency_Changes" 		default="#pull_data.Payment_Frequency_Changes#">
<cfparam name="Form.Require_Public_Notes_Changed" 	default="#pull_data.Require_Public_Notes_Changed#">
<cfparam name="Form.Require_Private_Notes_Changed" 	default="#pull_data.Require_Private_Notes_Changed#">
<cfparam name="Form.Products_Added" 				default="#pull_data.Products_Added#">
<cfparam name="Form.Products_Removed" 			default="#pull_data.Products_Removed#">
<cfparam name="Form.Products_Rates_Changes" 		default="#pull_data.Products_Rates_Changes#">
<cfparam name="Form.Products_UOM_Changes" 		default="#pull_data.Products_UOM_Changes#">
<cfparam name="Form.Growth_Change_Target" 			default="#pull_data.Growth_Change_Target#">
<cfparam name="Form.Lump_Sum_Changed" 			default="#pull_data.Lump_Sum_Changed#">
<cfparam name="Form.Lump_Sum_Created" 			default="#pull_data.Lump_Sum_Created#">
<cfparam name="Form.Lump_Sum_Removed" 			default="#pull_data.Lump_Sum_Removed#">
<cfparam name="Form.Pay_To_Component" 			default="#pull_data.Pay_To_Component#">
<cfparam name="Form.Claim_Mechanic_Changed" 		default="#pull_data.Claim_Mechanic_Changed#">
<cfparam name="Form.Distributors_Added" 			default="#pull_data.Distributors_Added#">
<cfparam name="Form.Distributors_Removed" 			default="#pull_data.Distributors_Removed#">
<cfparam name="Form.Operators_Added" 			default="#pull_data.Operators_Added#">
<cfparam name="Form.Operators_Removed" 			default="#pull_data.Operators_Removed#">

<table align="center">
	<cfif pull_data.recordcount>
	<tr>
		<td style="border:2px solid;border-color:orange;text-align:center;font-weight:bold">
		<cfoutput>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		This setting was last updated on #DateFormat(pull_data.Limited_Revision_Setting_Created_On, "mm/dd/yyyy")# #TimeFormat(pull_data.Limited_Revision_Setting_Created_On, "hh:mm:ss tt")# <cfif len(pull_data.Name)>by</cfif> #pull_data.Name#.
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		</cfoutput>
		</td>
	</tr>
	</cfif>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td style="border: 2px solid orange;color:red;">
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		Within each template there is a tab called 'revision settings'.  These settings should be in sync with the 'Limited Revise' settings.  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br> 
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		For example, the template revision settings do not allow a product to be added, but the Limited Revise settings page allows the user to add a product.  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		The template revision settings take precedent and thus the user will not be able to add a product on the template during a limited revision.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<table width="100%" align="center" cellspacing="0" cellpadding="1"  border="0">
	<tr>
		<td class="maintable" colspan="5"  valign="bottom" style="border-bottom: 2px solid #0000ff;"><b>Basic information</b></td>
	</tr>
<form name="limitedRevision" action="limited_revise.cfm" method="post" id="limitedRevision">
	<tr>
		<td class="maintable">Allow changes to the title of the program</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1" name="title_changes" checked ></td>
		<td class="maintable" align="right">no</td> 
		<td class="maintable"><input type="radio" value="0" name="title_changes" <cfif form.Title_Changes EQ 0>checked</cfif>></td>
	</tr>
	
	<tr>
		<td class="maintable">Allow changes to the start dates of the program</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="date_changes" checked ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="date_changes"<cfif form.date_changes EQ 0>checked</cfif>></td>
	</tr>
	
	<tr>
		<td class="maintable">Allow changes to the end dates of the program</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="Date_Changes_End" checked ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="Date_Changes_End"<cfif form.Date_Changes_End EQ 0>checked</cfif>></td>
	</tr>	

	<tr>
		<td class="maintable">Allow program revision start dates to be later than the original</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="start_date_change" checked ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="start_date_change"<cfif form.start_date_change EQ 0>checked</cfif>></td>
	</tr>
	
	<tr>
		<td class="maintable">Allow program revision end date to be earlier than the original start date</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="end_date_change" checked ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="end_date_change"<cfif form.end_date_change EQ 0>checked</cfif>></td>
	</tr>

	<tr>
		<td class="maintable">Allow payment frequency to be changed</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="payment_frequency_changes" checked ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="payment_frequency_changes"<cfif form.payment_frequency_changes EQ 0>checked</cfif>></td>
	</tr>
		
	<tr>
		<td class="maintable">Require public notes to be changed</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="require_public_notes_changed" checked ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="require_public_notes_changed"<cfif form.require_public_notes_changed EQ 0>checked</cfif>></td>
	</tr>
	
	<tr>
		<td class="maintable">Require business considerations to be changed</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="require_private_notes_changed" checked ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="require_private_notes_changed"<cfif form.require_private_notes_changed EQ 0>checked</cfif>></td>
	</tr>
	
	<tr>
		<td colspan="100%">&nbsp;</td>
	</tr>
	<!---
		*****************************************************************************************************
	       	***************************PRODUCTS & RATES***************************************************
	       	*****************************************************************************************************
	 --->
	<tr>
		<td class="maintable" colspan="5" valign="bottom" style="border-bottom: 2px solid ##0000ff;"><b>Products & Rates</b></td>
	</tr>

	<tr>
		<td class="maintable">Allow products to be added</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="products_added" checked ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="products_added"<cfif form.products_added EQ 0>checked</cfif>></td>
	</tr>

	<tr>
		<td class="maintable">Allow products to be removed</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="products_removed" checked ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="products_removed"<cfif form.products_removed EQ 0>checked</cfif>></td>
	</tr>

	<tr>
		<td class="maintable">Allow changes to the products rates offered</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="products_rates_changes" checked ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="products_rates_changes"<cfif form.products_rates_changes EQ 0>checked</cfif>></td>
	</tr>

	<tr>
		<td class="maintable">Allow changes to the unit of measure</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="products_uom_changes"  checked ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="products_uom_changes"<cfif form.products_uom_changes EQ 0>checked</cfif>></td>
	</tr>

	<tr>
		<td class="maintable">Allow growth targets/tiers to be changed</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="growth_change_target" checked ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="growth_change_target"<cfif form.growth_change_target EQ 0>checked</cfif>></td>
	</tr>

	<tr>
		<td class="maintable">Allow lump sum components to be changed</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="lump_sum_changed" checked ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="lump_sum_changed"<cfif form.lump_sum_changed EQ 0>checked</cfif>></td>
	</tr>

	<tr>
		<td class="maintable">Allow lump sum components to be created</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="lump_sum_created" checked ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="lump_sum_created"<cfif form.lump_sum_created EQ 0>checked</cfif>></td>
	</tr>

	<tr>
		<td class="maintable">Allow lump sum components to be removed</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="lump_sum_removed" checked  ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="lump_sum_removed"<cfif form.lump_sum_removed EQ 0>checked</cfif>></td>
	</tr>

	<tr>
		<td class="maintable">Allow pays to on a component to be changed</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="pay_to_component" checked  ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="pay_to_component"<cfif form.pay_to_component EQ 0>checked</cfif>></td>
	</tr>
	
	<tr>
		<td class="maintable">Allow claim mechanic to be changed</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="claim_mechanic_changed" checked  ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="claim_mechanic_changed"<cfif form.claim_mechanic_changed EQ 0>checked</cfif>></td>
	</tr>
	<tr>
		<td colspan="100%">&nbsp;</td>
	</tr>
	<!---
		*****************************************************************************************************
		************************************CUSTOMERS***************************************************
		*****************************************************************************************************
	 --->
	<tr>
		<td class="maintable" colspan="5" valign="bottom" style="border-bottom: 2px solid ##0000ff;"><b>Customers</b></td>
	</tr>

	<tr>
		<td class="maintable">Allow distributors to be added</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="distributors_added" checked ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="distributors_added"<cfif form.distributors_added EQ 0>checked</cfif>></td>
	</tr>
	
	<tr>
		<td class="maintable">Allow distributors to be removed</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="distributors_removed" checked ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="distributors_removed"<cfif form.distributors_removed EQ 0>checked</cfif>></td>
	</tr>
	
	<tr>
		<td class="maintable">Allow operators to be added</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="operators_added" checked ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="operators_added"<cfif form.operators_added EQ 0>checked</cfif>></td>
	</tr>
	
	<tr>
		<td class="maintable">Allow operators to be removed</td>
		<td class="maintable" align="right">yes</td>
		<td class="maintable"><input type="radio" value="1"  name="operators_removed" checked ></td>
		<td class="maintable" align="right">no</td>
		<td class="maintable"><input type="radio" value="0" name="operators_removed"<cfif form.operators_removed EQ 0>checked</cfif>></td>
	</tr>
	
	<tr>
		<td align="center" colspan="5" valign="bottom">&nbsp;</td>
	</tr>
	<tr>
		<td align="center" colspan="5" valign="bottom">
			<input type="hidden" name="status" value="0" id="formstatus">
			<cfoutput>
			<a href="javascript: submitform();" style="cursor:pointer;">#application.util.string.actionLinkFormat( "Save" )#</a>
			</cfoutput>
		</td>
	</tr>
</form>		
</table>
<script>
	function submitform(){
		document.getElementById("formstatus").value = 1;
		document.getElementById("limitedRevision").submit();
	}
</script>