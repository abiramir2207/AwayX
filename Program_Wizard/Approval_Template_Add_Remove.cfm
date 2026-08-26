<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Program Template - Approval</title>
</head>

<body>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<CFSET PAGETITLE = "PROGRAM WIZARD: APPROVAL SETTINGS">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">


<cfset ThisPage = CGI.SCRIPT_NAME>
<cfset formName = "frmTemplateApproval">
<cfparam name="form.command" 	default="">
<cfset tableBorderColor = "##93BEE2">
<cfparam name="form.id" 	default="0">
<cfparam name="url.id" 	default="#form.id#">
<cfparam name="form.approval_margin_item" default="0">
<cfparam name="form.approval_spend_item" default="0">
<cfparam name="form.approval_program_margin" default="0">
<cfparam name="form.approval_program_spend" default="0">

<cfif url.id>

	<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
	<cfset template = templateManager.get(url.id)>
	
				
	<cfif form.command EQ "save">
		
 		<cfset TemplateManager.saveApprovalMetrics(url.id, form)>
		<cfset id = url.id>

		<!------ Redirect to next page ----->		
		<cfset pageName = "approval">
		<cfinclude template="Next_Page.cfm" />
			
	<cfelse>
	<cfset templateApprovalmetrics = templateManager.getApprovalMetrics(url.id)>
		<!------ display header ----->
		<cfset Created_Type = template.getCreatedType()>
		<cfset Generic_Type = template.getGenericType()>
		<cfset Active = template.getActive()>
		<cfset Action = "edit">
		<cfset pageName = "approval">
		<cfinclude template="header.cfm">

		<cfoutput><form name="#formName#" method="post" action="#ThisPage#" style="display:inline;">
		<table cellpadding="4" cellspacing="0" border="0" class="MainTable" width="740">
		<tr>
		<td colspan="100%" align="left">
			<hr color="orange">
		</td>
		</tr>
		<tr bgcolor="FFCE84" valign="bottom">
		<td style="font-size: 12px;" align="Left"><span id="error_Approval_Metrics"></span><B>Approval Metrics</B></td>
		<td style="font-size: 12px;" align="center"><div align="left"><B>Required</B></div></td>
		</tr>
		<tr>
		<td align="left" style="font-size: 10px;">Margin per item</td>
		<td align="center" style="font-size: 10px;"><div align="left">
		  <input type="checkbox" name="approval_margin_item" value="1" <cfif templateApprovalmetrics.approval_margin_item EQ 1>checked</cfif>>
		  </div></td>
		</tr>
		<tr>
		<td align="left" style="font-size: 10px;">Spend per item</td>
		<td align="center" style="font-size: 10px;"><div align="left">
		  <input type="checkbox" name="approval_spend_item" value="1" <cfif templateApprovalmetrics.approval_spend_item EQ 1>checked</cfif>>
		  </div></td>
		</tr>
		<tr>
		<td align="left" style="font-size: 10px;">Program Margin</td>
		<td align="center" style="font-size: 10px;"><div align="left">
		  <input type="checkbox" name="approval_program_margin" value="1" <cfif templateApprovalmetrics.approval_program_margin EQ 1>checked</cfif>>
		  </div></td>
		</tr>
		<tr>
		<td align="left" style="font-size: 10px;">Program Spend</td>
		<td align="center" style="font-size: 10px;"><div align="left">
		  <input type="checkbox" name="approval_program_spend" value="1" <cfif templateApprovalmetrics.approval_program_spend EQ 1>checked</cfif>>
		  </div></td>
		</tr>
		
		<tr>
		<td align="left" style="font-size: 10px;">Unit Of Measure for Margins</td>
		<td align="center" style="font-size: 10px;"><div align="left">
		      <input type="radio" name="approval_uom" value="1" <cfif templateApprovalmetrics.approval_uom EQ 1>checked</cfif>>
		      Cases
		      <input type="radio" name="approval_uom" value="2" <cfif templateApprovalmetrics.approval_uom EQ 2>checked</cfif>>
		    Pounds </div>		  </td>
		</tr>
		</table>
		<input type="hidden" name="id" value="#url.id#">
		<input type="hidden" name="command" value="#form.command#">
		</form></cfoutput>
		
		
		<table align="left" width ="740" id="oTableButton" border="0" cellpadding="4" cellspacing="0">
		<tr>
		<td align="center">
		<CF_button
			button_name		=	""
			button_caption	=	"Save and Continue"
			button_action	=	"submitForm(document.#formName#, 'save');"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Save and Continue"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</td>
		</tr>
		</table>
			
		</cfif>
</cfif>
<script>
function submitForm(thisForm, sCommand)
	{
	var ErrorCount = 0;
if(document.all.approval_margin_item.checked == false && document.all.approval_program_spend.checked == false && document.all.approval_program_margin.checked == false && document.all.approval_spend_item.checked == false)
			{ 
				ErrorCount++;
				queueMessage("You must select atleast one approval type", document.all.error_Approval_Metrics);
			}
			else
			{ 
				clearQueue(document.all.error_Approval_Metrics);
			}
			
if(ErrorCount == 0) 
	{	
		thisForm.command.value = sCommand;
		thisForm.submit();
		return false;
	}
	else 
	{  
		showMessageWindow()
	}	
}

</script>
<CF_MessageWindow>
</body>
</html>

