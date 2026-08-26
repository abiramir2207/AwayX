<cfsilent>
<!---  
       Name:          select_components.cfm
       Copyright:     Copyright (c) 2013 Blacksmith Applications, Inc.
       Created Date:  05/30/2014
       Created By:    Kal
       Label:		  		42585
       Description:   Select Comnponents - multi check boxes
       Functionality: This is copy of code from the component_select_templates.cfm file used to display components for selection 
       				  To use this file in another place pass-in the query into the variable qData.
--->
</cfsilent>

<!--- select/unselect toggle switch --->
<script language="JavaScript">
	function selectAll(discountType, bCheck)
	{
		event.returnValue = false;
		var ObjTemplates = eval("document.all.discountComponents");
		var i, templateLen;
		if(ObjTemplates)
		{
			templateLen = ObjTemplates.length;
			if(templateLen)
			{
				for(i=0;i<templateLen;i++)
				{
					if(!ObjTemplates[i].disabled && ObjTemplates[i].getAttribute('discountType') == discountType)
					{
						ObjTemplates[i].checked = bCheck;
					}
				}
			}
			else
			{
				if(!ObjTemplates.disabled && ObjTemplates.getAttribute('discountType') == discountType)
				{
					ObjTemplates.checked = bCheck;
				}
			}
		}
	}
</script>

<!--- get all the templates if the query is not already defined.--->
<cfif NOT isDefined("qData")>
	<cfset glID = 0 />
	<!--- for new GL's glId is not defined --->
	<cfif isDefined("qGetCompRebates.GL_Account_ID") > 
		<cfset glID = qGetCompRebates.GL_Account_ID /> 
	</cfif>		
	<cfset qData = CreateObject("component","settings.gl_account.GLAccountManager").getGLAccountComponents(GL_Account_ID=glID) />
</cfif>

<cfset maxCols = 4 />
<cfset tdWidth = 100/maxCols />
<cfscript>
	Border="No";
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
	border="#Border#"									bordersize="#BorderSize#"  
	bordercolor="#BorderColor#"				image="#Image#"
	imageopen="#ImageOpen#"						title="Select Components"  
	titleclosed="Select Components"		titletooltip="Click here to toggle view"  
	titlecolor="#TitleColor#"					titlefont="#TitleFont#"
	titlesize="#TitleSize#"						isclosed="#IsClosed#">	

	<table cellpadding="2" cellspacing="0" width="100%" border="0" align="center">
		<cfif qData.recordCount>
			<cfoutput query="qData" group="Discount_Type_ID">
				<cfset colsCount = 0 />
				<tr bgcolor="FFCE8" style="height:20px">
					<td width="100%" style="border-bottom:1px solid ##93BEE2;">&nbsp;&nbsp;
						<strong>#Discount_Type_Desc#</strong> <span id="Err_Component">&nbsp;</span>			
					</td>
					<td nowrap style="border-bottom:1px solid ##93BEE2;">
						<cf_smallLink 
							title = "select all" 
							url = "##"
							parameters = "onClick=""javascript: return selectAll('#Discount_Type_ID#', true);"""
						>
						<cf_smallLink 
							title = "deselect all" 
							url = "##"
							parameters = "onClick=""javascript: return selectAll('#Discount_Type_ID#', false);"""
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
										<input type="checkbox" name="discountComponents" #IIF("#Selected#", DE("checked"), DE(""))# discountType="#Discount_Type_ID#" value="#Discount_Type_ID#-#Component_ID#">#Component_Name#
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
			<tr><td>No data found</td></tr>
		</cfif>
		<tr>
			<td colspan="100%">&nbsp;</td>
		</tr>
	</table>
</cf_openlayer>
