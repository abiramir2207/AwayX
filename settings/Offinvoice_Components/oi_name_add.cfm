<cfif isDefined("stError")>
	<cfset showCompTypeName = "Component name" />
	<script>
	<cfoutput>		
	<cfif stError.bNameExists EQ 2>
		alert("#showCompTypeName# already exists with a different ID.");		
	<cfelseif stError.bNameExists EQ 3>
		alert("Another component exists with the same allowance code.");
	</cfif>
	</cfoutput>
	</script>
</cfif>

<cfparam name="form.compExternalID" 	default="">
<cfparam name="form.compName" 	default="">

<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput>#Application.LumpsumLabel# </cfoutput>Names</LEGEND>
	<table width="90%" border="0">
		<colgroup>
		<col width="30%"></col>
		<col width="30%"></col>
		</colgroup>
		<cfoutput>
		<!------ external id ----->
		<cfif application.returned_customer_setting.external_id_on EQ 1>
		<TR>
			<TD ALIGN="right"><B>ID:</B></TD>
			<TD><INPUT NAME="compExternalID" TYPE="text" VALUE="#form.compExternalID#" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<cfelse><INPUT NAME="compExternalID" TYPE="hidden" VALUE="#form.compExternalID#">
		</cfif>
		<TR>
			<TD ALIGN="right"><B>Component Name:</B></TD>
			<TD><INPUT NAME="compName" TYPE="text" SIZE="25" MAXLENGTH="25" value="#form.compName#"></TD>
		</TR>
		<!--- Operating Group --->
		<cfif operatingGroupOn>
		<TR>
			<TD ALIGN="right"><B>#operatingGroupManager.getLabel(operatingGroupLevel)#:</B></TD>
			<TD>
			<cfset qGetOperatingGroups = operatingGroupManager.get(level = operatingGroupLevel, active = 1) />
			<select name="Operating_Group_ID" style="width:200px">
				<cfloop query="qGetOperatingGroups">
				<option value="#Operating_Group_ID#" <cfif form.Operating_Group_ID EQ Operating_Group_ID></cfif>>#Operating_Group_Number# : #Operating_Group_Desc#</option>
				</cfloop>
			</select>
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>Allowance Code:</B></TD>
			<TD>
			<cfsilent>
			<cfset qGetAllowanceCodes = allowanceCodeManager.getAllowanceCodes() />
			<!------ going to re-use the code to get list of all component names for diffent discount types ----->
			<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
			<cfset discountTypeList = templateManager.getComponentDiscountTypeList() />
			<cfset qGetAllTemplateDiscountComponents = templateManager.getAllTemplateDiscountComponents(0, discountTypeList, 0) />	
			<cfset usedAllowanceCodes = ValueList(qGetAllTemplateDiscountComponents.Allowance_Code_ID) />
			<cfset anyAllowanceCodeAvailable = 0 />
			</cfsilent>
			<select name="Allowance_Code_ID" style="width:200px">
				<option value="0">Select Allowance Code</option>
				<cfloop query="qGetAllowanceCodes">
				<cfif NOT ListFindNOCase(usedAllowanceCodes, Allowance_Code_ID)>
				<cfset anyAllowanceCodeAvailable = 1 />
				<option value="#Allowance_Code_ID#">#Allowance_Code_Number# : #Allowance_Code_Desc#</option>
				</cfif>
				</cfloop>
			</select>
			<cfif anyAllowanceCodeAvailable EQ 0>			
			<font color="red">No allowance code available.</font>
			</cfif>
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>Effective Rate % Required:</B></TD>
			<TD>
			<input type="Checkbox" name="Required_Effective_Rate_Percent" value="1" />
			</TD>
		</TR>
		</cfif>
		</cfoutput>	
		<TR>
		<TD colspan="100%">
		<cfset component_select_templates_component_id = -1 />
		<cfset component_select_templates_discount_type_id = 8 />
		<cfinclude template="/program_wizard/component_select_templates.cfm" />
		</TD>
		</TR>
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Add"
					button_action	=	"return addComp();"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</TD>
		</TR>
	</table>
</FIELDSET>