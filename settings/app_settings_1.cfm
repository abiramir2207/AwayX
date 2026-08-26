<!---
***********************************************************************
Modified By: Milan Mushran
Modification: Added "temp password", "new password", "admin password", "User Password Days" and "Traffic Info Days" functionality
Filename: app_settings_1.cfm
Modified Date: 9/1/2004
Purpose: For controlling the application settings
***********************************************************************
--->
<!------ settings.cfm ----->
<cfoutput>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfif form.state>
	<cfparam name="form.programInterfaceBuffer" 	default="0">
	<cfparam name="form.DollarGrowth" 				default="0">
	<cfparam name="form.UseXMaterial" 				default="0">
	<cfparam name="form.awaitingactiondays" 		default="0">
	<cfparam name="form.Printer2_Name" 				default="">

	<!--- The default number of days for traffic info is 2 --->
	<cfparam name="form.TrafficInfoDays" 			default="2">
	<!---<cfparam name="form.SAPInterfaceBuffer" 		default="2">--->

	<cfparam name="form.programNumberPrefix" 		default="">
	<cfparam name="form.billbackNumberPrefix" 		default="">
	<cfparam name="form.deductionNumberPrefix" 		default="">
	<cfparam name="form.DDCreditNumberPrefix" 		default="">
	<cfparam name="form.plannerNumberPrefix" 		default="">
	<cfparam name="form.Auto_Claim_Buffer" 		default=0>
	<cfparam name="form.DocumentPath" 		default="">
	<cfparam name="form.DocumentMapping" 		default="">

	<cfset appSettings = genSettingsManager.get(0)>
	<cfset appSettings.setProgramInterfaceBuffer(form.programInterfaceBuffer)>
	<cfset appSettings.setawaitingactiondays(form.awaitingactiondays)>
	<cfset appSettings.setTrafficInfoDays(form.TrafficInfoDays)>
	<!---<cfset appSettings.setSAPInterfaceBuffer(form.SAPInterfaceBuffer)>--->
	<cfset appSettings.setPrinter2Name(form.Printer2_Name)>
	<cfset appSettings.setProgramNumberPrefix(form.programNumberPrefix)>
	<cfset appSettings.setBillbackNumberPrefix(form.billbackNumberPrefix)>
	<cfset appSettings.setDeductionNumberPrefix(form.deductionNumberPrefix)>
	<cfset appSettings.setDDCreditNumberPrefix(form.DDCreditNumberPrefix)>
	<cfset appSettings.setPlannerNumberPrefix(form.plannerNumberPrefix)>
	<cfset appSettings.setAutoClaimBuffer(form.Auto_Claim_Buffer)>
	<cfset appSettings.setDocumentpath(form.DocumentPath)>
	<cfset appSettings.setDocumentMapping(form.DocumentMapping)>

	<cfset appSettings.setUpdatedBy(request.AccessStructure.User_ID)>
	<cfset genSettingsManager.save(1)>

	<cflocation addtoken="No" url="#thisPage#">

	<cfabort>
</cfif>

<cfset appSettings = genSettingsManager.get(1, 1, 1)>

<style>
	.appSettingsInput
	{
		text-align:right;
		width:50px;
	}
</style>

<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_validations.js"></SCRIPT>
<script language="JavaScript">

function validateAndSubmit(thisForm)
{

ErrorCount = 0

			if (!validateThisField(1, document.all.programInterfaceBuffer, "'Program Interface Buffer' should be a valid number"))
			{
				ErrorCount++;
			}
			else
			{
				clearQueue(document.all.err_sp_programInterfaceBuffer);
			}
			<!--- Removed with label 19969
			if (!validateThisField(1, document.all.awaitingactiondays, "'No. of days to allow a profile to take action' should be a valid number"))
			{
				ErrorCount++;
			}
			else
			{
				clearQueue(document.all.err_sp_awaitingaction);
			}
			--->
			if (document.all.TrafficInfoDays.value == 0)
			{
				ErrorCount++;
				queueMessage("No. of days for traffic info cannot be 0 (zero) days", document.all.err_sp_TrafficInfoDays);
			}
			else
			{
				clearQueue(document.all.error_err_sp_TrafficInfoDays);
			}
			/*
			if (document.all.SAPInterfaceBuffer.value == 0)
			{
				ErrorCount++;
				queueMessage("No. of days for SAP interface buffer cannot be 0 (zero) days", document.all.err_sp_SAPInterfaceBuffer);
			}
			else
			{
				clearQueue(document.all.error_err_sp_SAPInterfaceBuffer);
			}
			*/
			if(ErrorCount == 0) {

					submitForm(thisForm, "Settings1");

			}
			else {
				showMessageWindow()
			}

		}

	/*var isValid = true;
	isValid = validateThisField(1, document.all.programInterfaceBuffer, "'Program Interface Buffer' should be a valid number") && validateThisField(1, document.all.awaitingactiondays, "'No. of days to allow a profile to take action' should be a valid number") && isValid;

	if(isValid)
	{
		submitForm(thisForm, "Settings1");
	}
	else
	{
		showMessageWindow();
	}
}*/
</script>
<br>
<cfif Len(appSettings.getUpdatedBy()) GT 0>
<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<TR>
<TD>
	<FONT SIZE="2"><B>The settings were last updated on #dateformat(appSettings.getUpdatedOn(), 'mm/dd/yyyy')# #timeformat(appSettings.getUpdatedOn(), 'hh:mm:ss TT')# by #appSettings.getUpdatedByUserName()#</B></FONT>	</TD>
</TD>
</TR>
</TABLE>
<br>
</cfif>
<table cellpadding="2" cellspacing="0" border="0" width="500">
	<tr>
		<td>Program Interface Buffer:</td>
		<td><span id="err_sp_programInterfaceBuffer">&nbsp;&nbsp;</span></td>
		<td><input maxlength="3"  onkeypress="return Allow_Key_List('0123456789');" onblur="javaSCript: makeValidIntFloat(this, 1, '0');" class="appSettingsInput" type="Text" name="programInterfaceBuffer" value="#appSettings.getProgramInterfaceBuffer()#"> calendar days</td>
	</tr>
	<!--- Removed with label 19969
	<tr>
		<td>No. of days to allow a profile to take action:</td>
		<td><span id="err_sp_awaitingaction">&nbsp;&nbsp;</span></td>
		<td>&nbsp;<input maxlength="3"  onkeypress="return Allow_Key_List('0123456789');" onblur="javaSCript: makeValidIntFloat(this, 1, '0');" class="appSettingsInput" type="Text" name="awaitingactiondays" value="#appSettings.getawaitingactiondays()#"> days</td>
	</tr>
	--->
	<INPUT type="hidden" NAME="awaitingactiondays" VALUE="<CFIF len(appSettings.getawaitingactiondays) GT 0><CFOUTPUT>#appSettings.getawaitingactiondays()#</CFOUTPUT><CFELSE>3</CFIF>">
	<!--- Removed with label 19969
	<tr>
		<td>Report Scheduled for every:</td>
		<td><span id="err_sp_ReportRunDays">&nbsp;&nbsp;</span></td>
		<td><B><FONT COLOR="Red">[ </FONT><A HREF="javascript: void(0);" onClick="javaScript: showScheduleWindow();">Click here to schedule</A><FONT COLOR="Red"> ]</FONT></B></td>
		<!--- <td>&nbsp;<input maxlength="3"  onkeypress="return Allow_Key_List('0123456789');" onblur="javaSCript: makeValidIntFloat(this, 1, '0');" class="appSettingsInput" type="Text" name="Report_Run_Days" value="#appSettings.getReportRunDays()#"> days</td> --->
	</tr>
	--->
	<tr>
		<td>No. of days for traffic Info:</td>
		<td><span id="err_sp_TrafficInfoDays">&nbsp;&nbsp;</span></td>
		<td align="left"><input maxlength="3"  onkeypress="return Allow_Key_List('0123456789');" onblur="javaSCript: makeValidIntFloat(this, 1, '0');" class="appSettingsInput" type="Text" name="TrafficInfoDays" value="#appSettings.getTrafficInfoDays()#"> days</td>
	</tr>
	<!--- <tr>
		<td>SAP interface buffer to send programs:</td>
		<td><span id="err_sp_SAPInterfaceBuffer">&nbsp;&nbsp;</span></td>
		<td align="left"><input maxlength="3"  onkeypress="return Allow_Key_List('0123456789');" onblur="javaSCript: makeValidIntFloat(this, 1, '0');" class="appSettingsInput" type="Text" name="SAPInterfaceBuffer" value="#appSettings.getSAPInterfaceBuffer()#"> days</td>
	</tr> --->
	<cfif appSettings.getClaimAutoPrint()>
	<tr>
		<td>Claim Report Printer Name:</td>
		<td>&nbsp;</td>
		<td align="left"><input maxlength="50" size="40" type="Text" name="Printer2_Name" value="#appSettings.getPrinter2Name()#"></td>
	</tr>
	</cfif>
	<tr valign="top">
		<td>Program Number Prefix:
		<br><font color="red">prefix won't be added if this field is empty</font>
		</td>
		<td>&nbsp;</td>
		<td align="left"><input maxlength="3" size="3" type="Text" name="programNumberPrefix" value="#appSettings.getProgramNumberPrefix()#"></td>
	</tr>
	<tr valign="top">
		<td>Billback Number Prefix:
		<br><font color="red">prefix won't be added if this field is empty</font>
		</td>
		<td>&nbsp;</td>
		<td align="left"><input maxlength="3" size="3" type="Text" name="billbackNumberPrefix" value="#appSettings.getBillbackNumberPrefix()#"></td>
	</tr>
	<tr valign="top">
		<td>Deduction Number Prefix:
		<br><font color="red">prefix won't be added if this field is empty</font>
		</td>
		<td>&nbsp;</td>
		<td align="left"><input maxlength="3" size="3" type="Text" name="deductionNumberPrefix" value="#appSettings.getDeductionNumberPrefix()#"></td>
	</tr>
	<tr valign="top">
		<td>Credit (Deduction with negative Amount) Number Prefix:
		<br><font color="red">prefix won't be added if this field is empty</font>
		</td>
		<td>&nbsp;</td>
		<td align="left"><input maxlength="3" size="3" type="Text" name="DDCreditNumberPrefix" value="#TRIM(appSettings.getDDCreditNumberPrefix())#"></td>
	</tr>
	<tr valign="top">
		<td>#Application.PlannerLabel# Number Prefix:
		<br><font color="red">prefix won't be added if this field is empty</font>
		</td>
		<td>&nbsp;</td>
		<td align="left"><input maxlength="3" size="3" type="Text" name="plannerNumberPrefix" value="#TRIM(appSettings.getPlannerNumberPrefix())#"></td>
	</tr>
	<tr valign="top">
		<td>
			Auto Claim Buffer:
		</td>
		<td>&nbsp;</td>
		<td align="left"><input name="Auto_Claim_Buffer" type="text" value="#appSettings.getAutoClaimBuffer()#"> calendar days</td>
	</tr>
	<cfif genSettingsManager.get().getShowMapping() eq 1 OR request.AccessStructure.User_Rights_ID EQ 9999>
	<tr valign="top">
		<td>
			Set Document Mapping:
		</td>
		<td>&nbsp;</td>
		<td><B><FONT COLOR="Red">[ </FONT><A HREF="javascript: void(0);" onClick="window.open('Add_Mapping.cfm?formname=#formName#', 'WinMapping', 'height=300,width=300,status=no,toolbar=no,menubar=no');">Click here to view /add a mapped path </A><FONT COLOR="Red"> ]</FONT></B></td>
		<!---
		Purposely used .Documentpath instead of .getDocumentpath()
		We usually leave _application_settings.document_path as blank
		If it is blank, getDocumentpath() will return the application location
		So if we use .Documentpath it will stay blank
		--->
		<input name="DocumentPath" type="hidden" value="#appSettings.Documentpath#">
		<input name="DocumentMapping" type="hidden" value="#appSettings.getDocumentMapping()#">
	</tr>
	<tr valign="top">
		<td>
			Populate Price List Special:
		</td>
		<td>&nbsp;</td>
		<td><B><FONT COLOR="Red">[ </FONT><A HREF="javascript: void(0);" onClick="window.open('PopulatePriceListSpecial.cfm', 'PriceListSpec', 'height=800,width=1024,status=1,toolbar=0,menubar=1,resizable=yes');">
			Populate Pricelist Special
		</A><FONT COLOR="Red"> ]</FONT></B></td>
	</tr>
	</cfif>
</table>

<br><br>
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
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>

<script>
function showScheduleWindow() {
NewWindow("/anything_automated/email/schedule_rfa_awaiting_action.cfm", "StatusNotification", 800, 600, "yes", "yes")
		}

</script>
