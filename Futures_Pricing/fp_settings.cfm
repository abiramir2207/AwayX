<CFSET PAGETITLE = "PROGRAMS: FUTURES PRICING SETTINGS">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE></TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfoutput>

<!------ set defaults ----->
<cfparam name="form.state" 	default="0">
<cfset thisPage = cgi.script_name>
<cfset formName = "frmFuturesPricingSettings">

<cfset fpSettingsManager = CreateObject("component", "components.futures_pricing.SettingsManager").init() />
<cfif form.state>
	<cfset fpSettings = fpSettingsManager.getSettings()>
	<cfset fpSettings.setLeadTime(form.leadTime)>
	<cfset fpSettings.setNotifyCustDeadlineLeadTime(form.notifyCustDeadlineLeadTime)>
	<cfset fpSettings.setNotifyOfferGoodUntilLeadTime(form.notifyOfferGoodUntilLeadTime)>
	<cfset fpSettingsManager.save()>
	
	<cflocation addtoken="No" url="#thisPage#">
	
	<cfabort>
</cfif>

<cfset fpSettings = fpSettingsManager.get()>

<style>
	.fpSettingsInput
	{
		text-align:right;
	}
</style>
<script language="JavaScript">
	function submitForm(thisForm)
	{
		thisForm.submit();
	}
</script>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<br>
<form action="#thisPage#" method="post" name="#formName#">
<table cellpadding="2" cellspacing="0" border="0" width="500">
	<tr>
		<td>Lead Time:</td>
		<td><input maxlength="3" onkeypress="return Allow_Key_List('0123456789');" class="fpSettingsInput" type="Text" name="leadTime" value="#fpSettings.getLeadTime()#"></td>
	</tr>
	<tr>
		<td>Customer deadline lead time:</td>
		<td><input maxlength="3" onkeypress="return Allow_Key_List('0123456789');" class="fpSettingsInput" type="Text" name="notifyCustDeadlineLeadTime" value="#fpSettings.getNotifyCustDeadlineLeadTime()#"></td>
	</tr>
	<tr>
		<td>Offer good until lead time:</td>
		<td><input maxlength="3" onkeypress="return Allow_Key_List('0123456789');" class="fpSettingsInput" type="Text" name="notifyOfferGoodUntilLeadTime" value="#fpSettings.getNotifyOfferGoodUntilLeadTime()#"></td>
	</tr>
</table>
<input type="Hidden" name="state" value="1">
</form>
<br><br><br>
<div align="center">
	<CF_button
			button_name		=	""
			button_caption	=	"Save"
			button_action	=	"submitForm(document.#formName#);"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Save and Continue"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
</div>

</cfoutput>
</BODY>
</HTML>
