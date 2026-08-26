<cfsilent>
<!---  
       Name:          select_templates.cfm           
       Copyright:     Copyright (c) 2013 Blacksmith Applications, Inc.       
       Created Date:  05/30/2013
       Created By:    Kal
       Label:		  		34605
       Description:   Mass Price Change Utility
       Functionality: This is copy of the 	component_select_templates.cfm file but instead lists only the templates/template.
       				  To use this file in another place pass-in the query into the variable qTemplates.
--->
</cfsilent>

<!--- select/unselect toggle switch --->
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

<!--- get all the templates if the query is not already defined.--->
<cfif NOT isDefined("qTemplates")>
	<cfset qTemplates = CreateObject("component","components.programs.template.TemplateManager").getAll(orderCriteria=1) />
</cfif>

<cfparam name="form.template_select" default="" />

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
	IsClosed="No";
</cfscript>

<cf_openlayer
	border="#Border#"							bordersize="#BorderSize#"  
	bordercolor="#BorderColor#"					image="#Image#"
	imageopen="#ImageOpen#"						title="Select Templates"  
	titleclosed="Select Templates"				titletooltip="Click here to toggle view"  
	titlecolor="#TitleColor#"					titlefont="#TitleFont#"
	titlesize="#TitleSize#"						isclosed="#IsClosed#">	

	<table cellpadding="2" cellspacing="0" width="100%" border="0" align="center">
		<cfif qTemplates.recordCount>
			<cfoutput query="qTemplates" group="Generic_Type">
				<cfset colsCount = 0 />
				<tr bgcolor="FFCE8" style="height:20px">
					<td width="100%" style="border-bottom:1px solid ##93BEE2;">&nbsp;&nbsp;
						<strong>#Generic_Type# templates</strong> <span id="Err_Component">&nbsp;</span>			
					</td>
					<td nowrap style="border-bottom:1px solid ##93BEE2;">
						<cf_smallLink 
							title = "select all" 
							url = "##"
							parameters = "onClick=""javascript: return selectAll('#Generic_Type#', true);"""
						>
						<cf_smallLink 
							title = "deselect all" 
							url = "##"
							parameters = "onClick=""javascript: return selectAll('#Generic_Type#', false);"""
						>	
					</td>
				</tr>
				<tr>
					<td colspan="100%" style="border-left:1px solid ##93BEE2;border-right:1px solid ##93BEE2;border-bottom:1px solid ##93BEE2;">
						<table cellpadding="1" cellspacing="0" width="100%" border="0">
							<tr>
								<!--- output the templates by generic types --->
								<cfoutput>
									<td width="#tdWidth#%">
										<input type="checkbox" genericType="#Generic_Type#" name="Template_Select" value="#ProgramControl_Panel_Options_ID#" <cfif listFindNoCase(form.template_select, ProgramControl_Panel_Options_ID)>checked</cfif>>#Created_Type#
									</td>
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
			<tr><td>No template found</td></tr>
		</cfif>
		<tr>
			<td colspan="100%">&nbsp;</td>
		</tr>
	</table>
</cf_openlayer>
