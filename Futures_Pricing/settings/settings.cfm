<!------ settings.cfm ----->
<cfoutput>
<cfset fpSettingsManager = CreateObject("component", "components.futures_pricing.SettingsManager").init() />
<cfif form.state>
	<cfparam name="form.restrictCustDeadline" 	default="0">
	
	<cfset fpSettings = fpSettingsManager.getSettings()>
	<cfset fpSettings.setLeadTime(form.leadTime)>
	<cfset fpSettings.setRestrictCustDeadline(form.restrictCustDeadline)>
	<cfset fpSettings.setNotifyCustDeadlineLeadTime(form.notifyCustDeadlineLeadTime)>
	<cfset fpSettings.setNotifyOfferGoodUntilLeadTime(form.notifyOfferGoodUntilLeadTime)>
	<cfset fpSettings.setDefaultPeriodType(form.periodType)>
	<cfset fpSettings.setUpdatedBy(request.AccessStructure.User_ID)>	
	<cfset fpSettingsManager.save()>
	
	<cflocation addtoken="No" url="#thisPage#">
	
	<cfabort>
</cfif>

<cfset fpSettings = fpSettingsManager.get()>

<style>
	.fpSettingsInput
	{
		text-align:right;
		width:50px;
	}
</style>

<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<script language="JavaScript">

function validateAndSubmit(thisForm)
{
	var isValid = true;
	isValid = validateThisField(1, document.all.leadTime, "'Lead time to Start Date' should be a valid number") && isValid;
	isValid = validateThisField(1, document.all.notifyCustDeadlineLeadTime, "'Lead time to Customer deadline email notification' should be a valid number") && isValid;
	isValid = validateThisField(1, document.all.notifyOfferGoodUntilLeadTime, "'Lead time to Offer good until email notification' should be a valid number") && isValid;
	
	if(isValid)
	{
		submitForm(thisForm, "ceSettings");
	}
	else
	{
		showMessageWindow();
	}
}
</script>
<br>
<cfif Len(fpSettings.getUpdatedBy()) GT 0>
<TABLE BGCOLOR="White" BORDERCOLOR="Orange" BORDER="1" CELLPADDING="3" CELLSPACING="0">
<TR>
<TD>
	<FONT SIZE="2"><B>The settings were last updated on #dateformat(fpSettings.getUpdatedOn(), 'mm/dd/yyyy')# #timeformat(fpSettings.getUpdatedOn(), 'hh:mm:ss TT')# by #fpSettings.getUpdatedByUserName()#</B></FONT>	</TD>
</TD>
</TR>
</TABLE>
<br>
</cfif>
<table cellpadding="2" cellspacing="0" border="0" width="500">
	<tr>
		<td>Lead time to Start Date:</td>
		<td><span id="err_sp_leadTime">&nbsp;&nbsp;</span></td>
		<td><input maxlength="3" onkeypress="return Allow_Key_List('0123456789');" onblur="javaSCript: makeValidIntFloat(this, 1, '0');" class="fpSettingsInput" type="Text" name="leadTime" value="#fpSettings.getLeadTime()#"> calendar days</td>
	</tr>
	<tr>
		<td>Restrict 'Lead time to Start Date':</td>
		<td><span id="err_sp_restrictCustDeadline">&nbsp;&nbsp;</span></td>
		<td><input  type="checkbox" name="restrictCustDeadline" value="1"<cfif fpSettings.getRestrictCustDeadline()> checked</cfif>></td>
	</tr>	
	<tr>
		<td>Lead time to Customer deadline email notification:</td>
		<td><span id="err_sp_notifyCustDeadlineLeadTime">&nbsp;&nbsp;</span></td>
		<td><input maxlength="3" onkeypress="return Allow_Key_List('0123456789');" onblur="javaSCript: makeValidIntFloat(this, 1, '0');" class="fpSettingsInput" type="Text" name="notifyCustDeadlineLeadTime" value="#fpSettings.getNotifyCustDeadlineLeadTime()#"> calendar days</td>
	</tr>
	<tr>
		<td>Lead time to Offer good until email notification:</td>
		<td><span id="err_sp_notifyOfferGoodUntilLeadTime">&nbsp;&nbsp;</span></td>
		<td><input maxlength="3" onkeypress="return Allow_Key_List('0123456789');" onblur="javaSCript: makeValidIntFloat(this, 1, '0');" class="fpSettingsInput" type="Text" name="notifyOfferGoodUntilLeadTime" value="#fpSettings.getNotifyOfferGoodUntilLeadTime()#"> calendar days</td>
	</tr>
	<tr>
		<td>Default Period:</td>
		<td><span id="err_sp_periodType">&nbsp;&nbsp;</span></td>
		<td>
			<select name="periodType">
				<option value="1" <cfif fpSettings.getDefaultPeriodType() eq 1>selected</cfif>>Calendar</option>
				<option value="2" <cfif fpSettings.getDefaultPeriodType() eq 2>selected</cfif>>Fiscal</option>
			</select>
		</td>
	</tr>
</table>

<br><br><br>
<div align="center">
	<CF_button
			button_name		=	""
			button_caption	=	"Save"
			button_action	=	"validateAndSubmit(document.#formName#);"
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