<!-----------------------------------------------------------------------------

FILE NAME:		Select_Template_All.cfm
DESCRIPTION:	This Page will display all the templates with the grouping
              selecting and deselecting option using checkboxes.
CREATED BY:		10-Aug-2010
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
      			Anand Rao	  10-Aug-2010	Created the file
------------------------------------------------------------------------------> 

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

<!------ Show template list ----->
<cfset qComponents = CreateObject("component","components.programs.template.TemplateManager").getAllTemplates() />

<cfset maxCols = 4 />
<cfset tdWidth = 100/maxCols />
<CFSCRIPT>
Border="Yes";
BorderSize=1;  
BorderColor="orange";
Image="/images/plus3.gif";
ImageOpen="/images/minus3.gif";
TitleColor="Blue"; 
TitleFont="Arial";
TitleSize=9;
IsClosed="Yes";
</CFSCRIPT>

<CF_OPENLAYER
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
					<CF_smallLink 
						title = "select all" 
						url = "##"
						parameters = "onClick=""javascript: selectAll('#Generic_Type#', true);return false;"""
					>
					<CF_smallLink 
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
								<td width="#tdWidth#%"><input type="checkbox" genericType="#Generic_Type#" name="Template_Select" value="#FIRST_PARENT_ID#"
										<cfif isDefined("FORM.pageSource") AND (FORM.pageSource EQ "ItemExcludeAdd" OR  FORM.pageSource EQ "ItemExcludeEdit")>
											<cfif isDefined("FORM.Template_Select") AND FORM.Template_Select NEQ "">
												<cfloop index = "index_ID"  list ="#FORM.Template_Select#">
													<cfif (index_ID EQ FIRST_PARENT_ID)> checked</cfif>
												</cfloop>
											</cfif>
										<cfelse>
											<cfif Component_Selected EQ 1>checked</cfif>
										</cfif>
										>#Created_Type#</td> 
				
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
</CF_OPENLAYER>
</cfif>