<!------ component_select_templates.cfm ----->
<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getOperatingGroupOn() EQ 0>
<script language="JavaScript">
	function selectAll(genericType, bCheck)
	{
		event.returnValue = false;
		var ObjTemplates = eval("document.all.Template_Select");
		var i, templateLen;
		if(ObjTemplates)
		{
			templateLen = ObjTemplates.length;
			if(templateLen)
			{
				for(i=0;i<templateLen;i++)
				{
					if(!ObjTemplates[i].disabled && ObjTemplates[i].getAttribute('genericType') == genericType)
					{
						ObjTemplates[i].checked = bCheck;
					}
				}
			}
			else
			{
				if(!ObjTemplates.disabled && ObjTemplates.getAttribute('genericType') == genericType)
				{
					ObjTemplates.checked = bCheck;
				}
			}
		}
	}
</script>

<cfparam name="variables.Approval_Considerations_ID" default=-1>	<!--- special handling for approval considerations --->
<cfparam name="variables.bGetPlannerTemplates" default="0">			<!--- if calling from planner templates --->
<cfparam name="variables.nPlannerTemplateId" default="0">

<!------ Show template list ----->
<cfif variables.Approval_Considerations_ID gte 0>
	<cfset qComponents = CreateObject("component","components.programs.template.TemplateManager").getAll( 1 )>
<cfelseif variables.bGetPlannerTemplates eq 1>
	<cfset qComponents = CreateObject("component","components.programs.template.TemplateManager").getRetailPlannerTemplates(variables.nPlannerTemplateId)>
<cfelse>
	<cfset qComponents = CreateObject("component","components.programs.template.TemplateManager").getAllTemplateDiscountComponents(
											templateId = 0,
											discountTypeList = component_select_templates_discount_type_id,
											returnSelected = 0,
											componentId = component_select_templates_component_id,
											templateIsDominant = 1) />
</cfif>
<cfset maxCols = 4 />
<cfset tdWidth = 100/maxCols />
<cfscript>
	Border="Yes";
	BorderSize=1;
	BorderColor="orange";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Blue";
	TitleFont="Arial";
	TitleSize=9;
	IsClosed="Yes";
</cfscript>

<cf_openlayer
	BORDER="#Border#"							BORDERSIZE="#BorderSize#"
	BORDERCOLOR="#BorderColor#"					IMAGE="#Image#"
	IMAGEOPEN="#ImageOpen#"						TITLE="Select Templates"
	TITLECLOSED="Select Templates"				TITLETOOLTIP="Click here to toggle view"
	TITLECOLOR="#TitleColor#"					TITLEFONT="#TitleFont#"
	TITLESIZE="#TitleSize#"						ISCLOSED="#IsClosed#">

<table cellpadding="2" cellspacing="0" width="100%" border="0" align="center">
	<cfif qComponents.recordCount>
	<cfoutput query="qComponents" group="Generic_Type">
	<cfset colsCount = 0 />
	<tr bgcolor="FFCE8" style="height:20px">
	<td width="100%" style="border-bottom:1px solid ##93BEE2;">&nbsp;&nbsp;<strong>#Generic_Type# templates</strong>
	<span id="Err_Component">&nbsp;</span>
	</td>
	<td nowrap style="border-bottom:1px solid ##93BEE2;">
	<cf_smalllink
		title = "select all"
		url = "##"
		parameters = "onClick=""javascript: selectAll('#Generic_Type#', true);return false;"""
	>
	<cf_smalllink
		title = "deselect all"
		url = "##"
		parameters = "onClick=""javascript: selectAll('#Generic_Type#', false);return false;"""
	>
	</td>
	</tr>
	<tr>
	<td colspan="100%" style="border-left:1px solid ##93BEE2;border-right:1px solid ##93BEE2;border-bottom:1px solid ##93BEE2;">
		<table cellpadding="1" cellspacing="0" width="100%" border="0">
		<tr>
		<cfoutput>
		<td width="#tdWidth#%"><input type="checkbox" genericType="#Generic_Type#" name="Template_Select" value="#Template_ID#"
		<cfif variables.Approval_Considerations_ID gte 0>
			<cfif variables.Approval_Considerations_ID gt 0
				and qComponents.Approval_Considerations_ID eq variables.Approval_Considerations_ID>
				checked=checked
			</cfif>
		<cfelseif Component_Selected >checked</cfif>>#Created_Type#</td>
		<cfset colsCount = colsCount + 1 />
		<cfif colsCount GTE maxCols>
			</tr><tr>
			<cfset colsCount = 0 />
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
</cf_openlayer>
</cfif>

