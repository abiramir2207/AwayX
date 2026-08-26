<!---------------------------------------------------------------------------------------------------------------------
  Template: \planners\templates\select_templates.cfm
  Date:     2018 October
  Author:   Chris Nguyen
  Purpose:  Binding resource for select templates in planner template setting

  Remarks:  These are the required parameters.
				1. URL.Planner_Template_ID
				2. URL.Planner_Segment_ID
				3. URL.Selected_Templates
----------------------------------------------------------------------------------------------------------------------->
<cfsavecontent variable="select_templates">
<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getOperatingGroupOn() EQ 0>
	<cfscript>
		qTemplates  = createObject("component","components.programs.template.TemplateManager").getRetailPlannerTemplates(url.planner_template_id, url.planner_segment_id);
		maxCols     = 4;
		tdWidth     = 100 / maxCols;
	</cfscript>

	<!--- <cfdump var="#url#"> --->

	<table cellpadding="2" cellspacing="0" width="100%" border="0" align="center">
		<cfif qTemplates.recordCount>
			<cfoutput query="qTemplates" group="Generic_Type">
				<cfset colsCount = 0>
				<tr bgcolor="FFCE8" style="height:20px">
					<td width="100%" style="border-bottom:1px solid ##93BEE2;">&nbsp;&nbsp;<strong>#Generic_Type# templates</strong>
						<span id="Err_Component">&nbsp;</span>
						<span style="display:inline-block; float:right; position:relative; top:-2px;">
							<!--- due to binding feature the select_all() function is defined in \Planners\Templates\planner_template_basic_info.cfm --->
							<a style="margin-right:25px;" onclick="javascript:process_all('#Generic_Type#', checked=true)">#application.util.string.linkFormat("select all")#</a>
							<a style="margin-right:15px;" onclick="javascript:process_all('#Generic_Type#', checked=false)">#application.util.string.linkFormat("deselect all")#</a>
						</span>
					</td>
					<!--- <td style="border-bottom:1px solid ##93BEE2;">					</td> --->
				</tr>
				<tr>
					<td colspan="100%" style="border-left:1px solid ##93BEE2;border-right:1px solid ##93BEE2;border-bottom:1px solid ##93BEE2;">
						<table cellpadding="1" cellspacing="0" width="100%" border="0">
							<tr>
								<cfoutput>
									<td width="#tdWidth#%">
										<input type="checkbox" genericType="#Generic_Type#" name="Template_Select" value="#Template_ID#" 
											<cfif Component_Selected or listFind(url.selected_templates, qTemplates.template_id)>checked</cfif>>#Created_Type#
									</td>
									<cfset colsCount = colsCount + 1>
									<cfif colsCount GTE maxCols>
										</tr><tr>
										<cfset colsCount = 0>
									</cfif>
								</cfoutput>
								<cfloop from="#colsCount#" to="#maxCols#" index="i" >
									<td width="#tdWidth#%"></td>
								</cfloop>
							</tr>
						</table>
					</td>
				</tr>
			</cfoutput>
		<cfelse>
			<tr>
				<td>No template found</td>
			</tr>
		</cfif>
		<tr>
			<td colspan="100%">&nbsp;</td>
		</tr>
	</table>
</cfif>

<cfset request.focusHiLightOff = 1>
</cfsavecontent>

<cfoutput>#application.util.string.compress(select_templates)#</cfoutput>