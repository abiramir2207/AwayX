<!------ select_components.cfm ----->
<cfparam name="form.command" 	default="">
<cfset formName = "frmPullbacks">

<!---Gets application settings--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset oProgram = CreateObject("component", "components.programs.program") />
<cfset qGetProgramUserSettings = oProgram.getProgramUserSettings() />

<cfset bEditEnabled = qGetProgramUserSettings.Pullback_Modify_Corporate_Program_Rates />
<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>Program - #appSettings.getPullbackLabel()#</title>
</head>
<body>
<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js">
</SCRIPT>
</cfoutput>
<!------ display header ----->
<cfif form.command EQ "save">
	<cfif bEditEnabled>
	<!--- 
	Dev Note: Milan (48182) - Remove any insert/update to "template_pullback_program_defaults".
	This table is not being used anymore.
	--->
	<!---<CFTRANSACTION ACTION="BEGIN">
		<CFQUERY NAME="deletedefaultrates" datasource="#application.datasource#">
			UPDATE template_pullback_program_defaults
			set deleted = 1
			where program_id = #CSL_Contract_Main_ID#
		</CFQUERY>
	--->
		<cfif isDefined("form.Template_ID")>
			<cfif len(form.template_id) NEQ 0>
			<!---<cfloop list="#form.template_id#" index="i">
				<cfparam name="Default_Rate_#i#" default="0">
				<cfif evaluate("Default_Rate_#i#") EQ "">
					<cfset "Default_Rate_#i#" = 0>
				</cfif>
				<CFQUERY NAME="adddefaultrates" datasource="#application.datasource#">
				insert into template_pullback_program_defaults
				(program_id,Corp_Template_Id,Opr_Loc_Template_Id,Pullback_Default_Rate)
				values (#CSL_Contract_Main_ID#,#trim(CSLGetContractInfo.programtype_id)#,#i#,#evaluate("Default_Rate_#i#")#)
				</CFQUERY>
			</cfloop>
			--->
			<cfquery name="insertDisPullbackRates" datasource="#application.datasource#">
				update Contract_Main
				set applied_pullbacks = 1
				where Contract_Main_ID = <cfqueryparam value="#CSL_Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER" />
			</cfquery>
			</cfif>
		</cfif>
		<!---<CFTRANSACTION ACTION="COMMIT" />
	</CFTRANSACTION>--->
	</cfif>
	
	<cfoutput>
	<cfif url.margincheck EQ 0>
		<cflocation url="pullback_index.cfm?CID=#url.CID#&FromDistributor_Prg=1">
	<cfelse>
		<cflocation url="/Common_Files/Contracts/duplicate_check.cfm?CID=#URL.CID#">
	</cfif>
	</cfoutput>
<!--- end form.command EQ "save" --->
<cfelse>
<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
<cfset getallprgoprloctemplates = templateManager.getallprgoprloctemplates(CSLGetContractInfo.programtype_id,CSL_Contract_Main_ID)>

<form name="<cfoutput>#formName#</cfoutput>" method="post" action="pullback_index.cfm?CID=<cfoutput>#url.CID#</cfoutput>&FromDistributor_Prg=1&margincheck=<cfoutput>#url.margincheck#</cfoutput>" style="display:inline;">
<table cellspacing="0" width="740" border="0" align="center" class="MAINTABLE">			
	<cfif getallprgoprloctemplates.recordCount>
	<cfoutput query="getallprgoprloctemplates" group="Generic_Type">
	<tr bgcolor="FFCE84" style="height:20px">
	<td style="border-bottom:1px solid ##93BEE2;" colspan="100%"><strong>#Generic_Type# templates</strong>&nbsp;&nbsp;
	<span id="Err_Component">&nbsp;</span>			
	</td>
	</tr>
	<cfoutput>
	<tr style="height:20px">
	<td>#Created_Type#: </td>
<input type="hidden" name="template_id" value="#Template_Id#">
	<td width="50%"> 
	<cfif CSLGetContractInfo.contract_status_type_idx LT 3 AND bEditEnabled>
	<input type="textbox" name="Default_Rate_#Template_Id#" size="5" maxsize="4" value="<cfif Pullback_Default_Rate NEQ "">#Pullback_Default_Rate#<cfelse>0</cfif>" onKeyUp="clenseText(this, '0123456789')">
	<cfelse>#Pullback_Default_Rate#</cfif> <b>%</b></td>
	</tr>
	</cfoutput>
	</cfoutput>
	<cfelse>
		<tr>
		<td>No template found</td>
		</tr>
	</cfif>
</table>
<cfif CSLGetContractInfo.contract_status_type_idx LT 3 AND bEditEnabled>
<table align="center">
<tr>
		<td align="center">
		<CF_button
			button_name		=	""
			button_caption	=	"Save"
			button_action	=	"submitPullbackForm(document.#formName#, 'save');"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Continue"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</td>
		</tr>
</table>
</cfif>
<input type="hidden" name="command" value="<cfoutput>#form.command#</cfoutput>">
</form>
	<script>
		function submitPullbackForm(thisForm, sCommand)
				{
				thisForm.command.value = sCommand;
				thisForm.submit();
				return false;
				}
		
		</script>
</cfif>

