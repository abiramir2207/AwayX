<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!------ select_components.cfm ----->
<cfset Action = "edit">
<cfset pageName = "Pullback_settings">
<cfset ThisPage = CGI.SCRIPT_NAME>
<cfparam name="url.id" 	default="0">
<cfset formName = "frmPullbacks">
<cfparam name="form.command" 	default="">
<cfparam name="form.template_id" 	default=""> <!--- Dev Note: KAL;  D13242: Tempate_ID is undefined in FORM --->

<!---Gets application settings--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfoutput>
	<html>
		<head>
			<title>Program Template - #appSettings.getPullbackLabel()#</title>
			<style>
			table.MAINTABLE tr { line-height:25px; }
			</style>
		</head>
	<body>
	<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
	
	<CFSET PAGETITLE = "PROGRAM TEMPLATES: #UCASE(appSettings.getPullbackLabel())#">
	<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
	<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js">
	</SCRIPT>
</cfoutput>

<!------ display header ----->
<cfif url.id>
	<CFQUERY NAME="getCorp_Template_Parent_Id" datasource="#application.datasource#">
		SELECT Top 1 Template_Parent_Id FROM Program_Control_Panel_Options WHERE ProgramControl_Panel_Options_Id = <cfqueryparam  value="#url.id#" cfsqltype="cf_sql_numeric" >
	</CFQUERY>
	<cfif form.command EQ "save">
		
		<CFTRANSACTION ACTION="BEGIN">
			<!--- WR 67118 use Template_Parent_Id so all template versions are affected  --->
			<CFQUERY NAME="deletedefaultrates" datasource="#application.datasource#">
				UPDATE template_pullback_defaults
				set deleted = 1
				WHERE Corp_Template_Parent_Id = <cfqueryparam  value="#getCorp_Template_Parent_Id.Template_Parent_Id#" cfsqltype="cf_sql_numeric" >
						OR
						Corp_Template_Id = <cfqueryparam  value="#url.id#" cfsqltype="cf_sql_numeric" >
			</CFQUERY>
			<cfif len(form.template_id) NEQ 0>
				<cfloop list="#form.template_id#" index="i">
					<cfparam name="Default_Rate_#i#" default="0">
					<cfparam name="Racapture_On_#i#" default="0">
					<cfif len(trim(#evaluate("Default_Rate_#i#")#)) IS 0>
						<cfset "Default_Rate_#i#" = 100><!--- D30444:Evernt error when saving template revision CHANGED DEFAULT VALUE 0 TO 100--->
					</cfif>
					<CFQUERY NAME="getOpr_Loc_Template_Parent_Id" datasource="#application.datasource#">
						SELECT Top 1 Template_Parent_Id FROM Program_Control_Panel_Options WHERE ProgramControl_Panel_Options_Id = <cfqueryparam  value="#i#" cfsqltype="cf_sql_numeric" >
					</CFQUERY>
					<!--- WR 67118 use Template_Parent_Id so all template versions are affected.  Alos added "Pullback_On" instead of allowing % differences.  --->
					<CFQUERY NAME="adddefaultrates" datasource="#application.datasource#">
                        	insert into template_pullback_defaults
							(	Corp_Template_Id,
								Opr_Loc_Template_Id,
								Pullback_Default_Rate,
								Pullback_On,
								Corp_Template_Parent_Id,
								Opr_Loc_Template_Parent_Id)
							values (<cfqueryparam  value="#url.id#" cfsqltype="cf_sql_numeric" >,
										#i#,
										#evaluate("Default_Rate_#i#")#,
										#evaluate("Racapture_On_#i#")#,
										<cfqueryparam  value="#getCorp_Template_Parent_Id.Template_Parent_Id#" cfsqltype="cf_sql_numeric" >,
										<cfqueryparam  value="#getOpr_Loc_Template_Parent_Id.Template_Parent_Id#" cfsqltype="cf_sql_numeric" >
									)
					</CFQUERY>
				</cfloop>
			</cfif>
			<CFTRANSACTION ACTION="COMMIT">
		</CFTRANSACTION>
		<cfset id = url.id>	
		<cfinclude template="Next_Page.cfm" />
	<cfelse>
	
		<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
		<cfset template = templateManager.get(url.id)>
		<cfset Created_Type = template.getCreatedType()>
		<cfset Generic_Type = template.getGenericType()>
		<cfset Active = template.getActive()>
		<cfinclude template="header.cfm">
		
		<cfset maxCols = 2 />
		<cfset tdWidth = 100/maxCols />
		
		<cfset getoprloctemplates = templateManager.getalloprloctemplates(getCorp_Template_Parent_Id.Template_Parent_Id)>

		<form name="<cfoutput>#formName#</cfoutput>" method="post" action="Pullback_settings.cfm?id=<cfoutput>#url.id#</cfoutput>" style="display:inline;">
			<div style="width:90%;text-align:right;margin:10px 0;"><!--- D30444:Evernt error when saving template revision --->
			<cfif LockedBy_Current_User EQ 1>
					<CF_button
						button_name		=	""
						button_caption	=	"save and continue"
						button_action	=	"submitForm(document.#formName#, 'save');"
						button_type		=	"javascript_link"
						button_width	=	"150"
						button_color	=	"Navy"
						button_tip		=	"Continue"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
						>
			</cfif>
			</div><!--- D30444:Evernt error when saving template revision --->
			<table cellpadding="0" cellspacing="0" width="90%" border="0" align="left" class="MAINTABLE">			
				<cfif getoprloctemplates.recordCount>
					<cfset Generic_Type_tmp = ''/>
					<cfloop query="getoprloctemplates">
						<cfoutput>
						<cfscript>
							Pullback_On = getoprloctemplates.Pullback_On;
							if(Pullback_On == 0){
								Pullback_Default_Rate = 0;
								Checked_Recap_On = '';
							}
							else{
								Pullback_Default_Rate = 100;
								Checked_Recap_On = 'Checked';
							}
						</cfscript>
						<cfif Generic_Type_tmp NEQ Generic_Type>
							<tr bgcolor="FFCE8" style="height:20px">
								<td width="100%" style="border-bottom:1px solid ##93BEE2;" colspan="2">&nbsp;&nbsp;<strong>#Generic_Type# templates</strong>
									<span id="Err_Component">&nbsp;</span>			
								</td>
							</tr>
							<cfset Generic_Type_tmp = Generic_Type/>
						</cfif>
						<cfoutput>
							<tr style="height:20px">
								<td width="50%">#Created_Type#: </td>
								<input type="hidden" name="template_id" value="#Template_Id#">
								<td width="50%"> <input type="Hidden" name="Default_Rate_#Template_Id#" value="#Pullback_Default_Rate#">
								 <input type="checkbox" name="Racapture_On_#Template_Id#" value="#Pullback_On#" #Checked_Recap_On# onClick="handleClick(this);"  title="Allow #appSettings.getPullbackLabel()# from template #Created_Type#"></td>
							</tr>
						</cfoutput>
					</cfoutput>
					</cfloop>
				<cfelse>
						<tr>
							<td>No template found</td>
						</tr>
				</cfif>
			</table>
			

			<input type="hidden" name="command" value="#form.command#">
			<input type="hidden" name="id" value="#url.id#">
		</form>
		<script>
			function submitForm(thisForm, sCommand)
					{
					thisForm.command.value = sCommand;
					thisForm.submit();
					return false;
					}
					
			function handleClick(cb) {
			 	cb.value = cb.checked ? 1 : 0;
			}
						
		</script>
	</cfif>
</cfif>
