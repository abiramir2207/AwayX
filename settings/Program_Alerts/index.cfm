<CFOUTPUT>
<CFSET PAGETITLE = "PROGRAMS: PROGRAM ALERTS">
</CFOUTPUT>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE></TITLE>
<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>
<SCRIPT SRC="/script/javascript/string_functions.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dom_common.js"></SCRIPT>

<script language="JavaScript">
function submitForm()
{
	var oForm 					= document.programAlertForm;
	var alertMsg 				= "";
	var reminderAlertMsg 		= "";
	var validateTemplChecked 	= 0;
	var validateStatChecked 	= 0;
	
	templChecked	= document.all.programAlertForm.Distributor_Operator;
	statChecked 	= document.all.programAlertForm.Contract_Status_Type_ID;
	reminder		= trim(document.all.programAlertForm.reminder.value);
	
	for (i = 0; i < templChecked.length; i++)
	{
		if(templChecked[i].checked)
		{
			validateTemplChecked = 1;
			break;
		}
	}

	for (n = 0; n < statChecked.length; n++)
	{
		if(statChecked[n].checked)
		{
			validateStatChecked = 1;
			break;
		}
	}

	if (reminder.length == 0)
	{
		reminderAlertMsg = "Please enter a Reminder.";
	}
	else if (reminder.length > 1200)
	{
		reminderAlertMsg = "Reminders cannot exceed 1200 characters.";
	}
	
	if (validateTemplChecked == 0)
	{
		alertMsg = "Please select at least one Operator Template.\n";
	}
	
	if (validateStatChecked == 0)
	{
		alertMsg = alertMsg + "Please select at least one Status.\n";
	}
	
	if (reminderAlertMsg.length > 0)
	{
		alertMsg = alertMsg + reminderAlertMsg;
	}
	
	if (alertMsg.length > 0)
	{
		alert(alertMsg);
		return false;
	}

	oForm.submit();
	return false;
}
</script>
<!--- Dev Note: drachala; D28078: Text Editor tools in Forge not working with Windows 7  START
What  I did: Added New Jquery Text Editor WYUIWYG--->
		<!---<script type="text/javascript" src="/Script/Editor/scripts/wysiwyg.js"></script>
		<script type="text/javascript" src="/Script/Editor/scripts/wysiwyg-settings.js"></script>
		<script type="text/javascript">
			WYSIWYG.attach('textarea', full);
		</script>--->
<!--- End Dev Note: drachala; D28078: Text Editor tools in Forge not working with Windows 7  --->
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />

<cfset qDistributorTradeShelter 	= templateManager.getTemplatesByGenericType('Distributor Trade/Shelter',request.AccessStructure.Company_Main_ID) />
<cfset qDistributorFieldExecution 	= templateManager.getTemplatesByGenericType('Field Execution',request.AccessStructure.Company_Main_ID) />
<cfset qOperatorDirectHQPrograms 	= templateManager.getTemplatesByGenericType('Operator Direct or HQ Programs',request.AccessStructure.Company_Main_ID) />
<cfset qOperatorDeviatedPricing 	= templateManager.getTemplatesByGenericType('Operator-Deviated Pricing',request.AccessStructure.Company_Main_ID) />

<cfset variables.oProgramAlertManager = createObject("component", "components.settings.ProgramAlerts.ProgramAlertManager") />

<!--- get saved program alert status and put them in a list --->
<cfset variables.qGetProgramAlertStatus = variables.oProgramAlertManager.getProgramAlertStatus() />
<cfset variables.lProgramAlertStatus = valueList(variables.qGetProgramAlertStatus.Contract_Status_Type_ID) />

<!--- get Reminder --->
<cfparam name="variables.reminder" default="" />
<cfset variables.reminder = variables.oProgramAlertManager.getProgramAlertReminder().Reminder />

<FORM ACTION="program_alert_action.cfm" METHOD="post" NAME="programAlertForm">
<p style="font-size:12px">
A program alert is the ability on a newly created or revised distributor program to send an alert to a RSP of an operator program informing
them of the changes that were made on the distributor program.  The alert will be sent to operator programs that have the same distributor/item 
combination as the distributor program. An example where you may want to setup an alert: distributor program which has distributor A was revised 
because the fixed pricing for item A was changed.  An alert is setup on the distributor program so the RSP of an operator program which has 
distributor A and item A will receive an alert.  The alert will notify them of the price change on the distributor program and they should update 
the rebate amount for distributor A / item A on the operator program.
</p>
<p style="font-size:12px">
To setup a program alert:<br>
Step 1:  Click on any distributor template name in the list below.  A list of operator template names will appear.  Place a checkmark next to the operator templates which should be alerted for that distributor template. <br>
Step 2:  Scroll down the page to an area called Alert Operator Programs that are in these statuese. In this section, select the statuses for operator programs that should receive alerts.  <br>
Step 3:  Scroll down the page to an area called Reminder.  In this section, write a default message that should appear to the users of distributor programs to explain the program alert feature and the information they should type into the notes area.  The information in the notes area will be shown to the RSPs of the operator programs. <br>   
Step 4:  Click [save] at the bottom of the page.
</p>
<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="1" WIDTH="95%">
	<tr>
		<td>
			<cfloop query="qDistributorTradeShelter">

				<cfset variables.qDistTradeShelterOps = variables.oProgramAlertManager.getProgramAlertTemplate(qDistributorTradeShelter.First_Parent_ID) />
				<cfset variables.lDistTradeShelterOps = valueList(variables.qDistTradeShelterOps.Operator_Template_ID) />
				
				<CF_openLayer
					Border="Yes"
					BorderSize="1"  
					BorderColor="orange"  
					Image="/images/plus2.gif"
					ImageOpen="/images/minus2.gif"
					Title="#Created_Type#"  
					TitleClosed="#Created_Type#"  
					TitleTooltip="Click to Show/Hide"  
					TitleFont="font"  
					TitleColor="Blue"  
					TitleSize="9"  
					IsClosed="Yes"  
					Width="100%">
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="95%">
					<cfoutput Query="qOperatorDirectHQPrograms">
						<tr>
							<td VALIGN="Top">
								<input name="Distributor_Operator" type="checkbox" value="#qDistributorTradeShelter.First_Parent_ID#_#qOperatorDirectHQPrograms.First_Parent_ID#" <cfif listFindNoCase(variables.lDistTradeShelterOps, qOperatorDirectHQPrograms.First_Parent_ID)>checked</cfif> /> #Created_Type#
							</td>
						</tr>
					</cfoutput>
					<cfoutput Query="qOperatorDeviatedPricing">
						<tr>
							<td VALIGN="Top">
								<input name="Distributor_Operator" type="checkbox" value="#qDistributorTradeShelter.First_Parent_ID#_#qOperatorDeviatedPricing.First_Parent_ID#" <cfif listFindNoCase(variables.lDistTradeShelterOps, qOperatorDeviatedPricing.First_Parent_ID)>checked</cfif> /> #Created_Type#
							</td>
						</tr>
					</cfoutput>
				</TABLE>
				</CF_openLayer>
				<br />
				
			</cfloop>	 
	
			<cfloop query="qDistributorFieldExecution">
			
				<cfset variables.qDistFieldExecOps = variables.oProgramAlertManager.getProgramAlertTemplate(qDistributorFieldExecution.First_Parent_ID) />
				<cfset variables.lDistFieldExecOps = valueList(variables.qDistFieldExecOps.Operator_Template_ID) />
				
				<CF_openLayer
					Border="Yes"
					BorderSize="1"  
					BorderColor="orange"  
					Image="/images/plus2.gif"
					ImageOpen="/images/minus2.gif"
					Title="#Created_Type#"  
					TitleClosed="#Created_Type#"  
					TitleTooltip="Click to Show/Hide"  
					TitleFont="font"  
					TitleColor="Blue"  
					TitleSize="9"  
					IsClosed="Yes"  
					Width="100%">
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="95%">
					<cfoutput Query="qOperatorDirectHQPrograms">
						<tr>
							<td VALIGN="Top">
								<input name="Distributor_Operator" type="checkbox" value="#qDistributorFieldExecution.First_Parent_ID#_#qOperatorDirectHQPrograms.First_Parent_ID#" <cfif listFindNoCase(variables.lDistFieldExecOps, qOperatorDirectHQPrograms.First_Parent_ID)>checked</cfif> /> #Created_Type#
							</td>
						</tr>
					</cfoutput>
					<cfoutput Query="qOperatorDeviatedPricing">
						<tr>
							<td VALIGN="Top">
								<input name="Distributor_Operator" type="checkbox" value="#qDistributorFieldExecution.First_Parent_ID#_#qOperatorDeviatedPricing.First_Parent_ID#" <cfif listFindNoCase(variables.lDistFieldExecOps, qOperatorDeviatedPricing.First_Parent_ID)>checked</cfif> /> #Created_Type#
							</td>
						</tr>
					</cfoutput>
				</TABLE>
				</CF_openLayer>
				<br />
			</cfloop>	
		</td>
	</tr>
	<tr>
		<td>
			<cfquery name="qGetProgramStatus" datasource="#application.datasource#">
				SELECT 	DISTINCT *
				FROM 	Contract_Status_Types
				WHERE 	Contract_Status_Type_ID NOT IN (3,8)
			</cfquery>
			<b>Alert Operator Programs that are in these statuses:</b><br />
			<cfoutput query="qGetProgramStatus">
				<input name="Contract_Status_Type_ID" type="checkbox" value="#Contract_Status_Type_ID#" <cfif listFindNoCase(variables.lProgramAlertStatus, Contract_Status_Type_ID)>checked</cfif> />#Contract_Status_Type_Desc#&nbsp;&nbsp;
			</cfoutput>
		</td>
	</tr>
	<tr>
		<td colspan="100%">
			<b>Reminder:</b><br />
			<textarea name="reminder" cols="75" rows="10"><cfoutput>#variables.reminder#</cfoutput></textarea>
<!--- Dev Note: drachala; D28078: Text Editor tools in Forge not working with Windows 7  START                
What  I did: Comment out above text area and replace it with TEXTAREA for WYSIWYG tool--->
<!---<textarea id="textarea" name="reminder" style="width:610px;height:200px;">
<cfoutput>#variables.reminder#</cfoutput>
</textarea>--->
<!--- End Dev Note: drachala; D28078:Text Editor tools in Forge not working with Windows 7 END  --->
		</td>
	</tr>
	<tr>
		<td><br>
			<!---<span style="width:570px">&nbsp;</span>--->
			<CF_smallLink 
				title = "save" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm();"""
			>
		</td>
	</tr>
</table>
</FORM>

</BODY>
</HTML>
