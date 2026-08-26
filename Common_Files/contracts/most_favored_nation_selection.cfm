<!---
	Name:          	most_favored_nation_selection.cfm
	Copyright:     	Copyright (c) 2011 Blacksmith Applications, Inc.
	Created Date:  	07/22/2014
	Created By:    	Tim Ford
	Description:   	Page to display for MFN selection
	Usage:
--->

<title>Most Favored Nation Selection</title>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<body>
<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/script/javascript/jquery.cfjs.min.js"></script>
<script>
function check_all( element ) {
  $('.cbox').attr('checked', element.checked);
}

function check_all2( element ) {
  $('.cbox2').attr('checked', element.checked);
}

function submitMFN()
{
	document.selectMFN.Save_MFN.value = 1;
	document.selectMFN.submit();
}
</script>

<cfparam name="form.Template_Generic_Type"	default="#getProgramTemplateInfo.Generic_Type#" />
<cfparam name="form.Template_Created_Type"	default="#getProgramTemplateInfo.Created_Type#" />
<cfparam name="form.Template_ID"			default="#getProgramTemplateInfo.ProgramControl_Panel_Options_ID#" />
<cfparam name="form.Program_Number"			default="#getProgramTemplateInfo.Contract_Number#" />
<cfparam name="form.MFN_Component"			default="" />
<cfparam name="form.MFN_Created_Type"		default="" />
<cfparam name="form.Save_MFN"				default="0" />

<cfquery name="qGetBusinessUnit" datasource="#application.datasource#">
	SELECT	Business_Segment.Business_Unit_ID
	FROM	Contract_Main 
			INNER JOIN Business_Segment ON Business_Segment.Business_Segment_ID =  Contract_Main.Business_Segment_ID
	WHERE	Contract_Main_ID = '#cryp.value#'	
</cfquery>

<cfset objProgramMFN = createObject("component", "components.programs.ProgramMostFavoredNation") />
<cfset objGetComponent = createObject("component", "mvc.Models.Program.Component.ComponentManager") />
<cfset aComp = objGetComponent.getComponent(cryp.value) />
<cfset qGetTemplates = objProgramMFN.getTemplatesByType(form.Template_Generic_Type, qGetBusinessUnit.Business_Unit_ID, form.Template_Created_Type) />

		
<cfif form.Save_MFN eq 1>

	<cfset useLakebaseForQDeleteExistingEntries = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_most_favored_nation_data")>
	<cfif useLakebaseForQDeleteExistingEntries>
		<cftry>
			<cfset application.oLakebase.updateRows("program_most_favored_nation_data",
				{ "program_number" = "eq.#form.Program_Number#" },
				{ "deleted" = true }
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForQDeleteExistingEntries = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForQDeleteExistingEntries>
	<cfquery name="qDeleteExistingEntries" datasource="#application.datasource#">

		UPDATE	Program_Most_Favored_Nation_Data
		SET		Deleted = 1
		WHERE	Program_Number = '#form.Program_Number#'

	</cfquery>
	</cfif>

	<cfoutput>
	
		<cfloop index="inx1" list="#form.MFN_Component#">
	
			<cfset variables.createdType	= form.Template_Created_Type />
			<cfset variables.compType 		= ListGetAt(inx1, 1, "_") />
			<cfset variables.compId 		= ListGetAt(inx1, 2, "_") />
			<cfset variables.compPaidTo		= ListGetAt(inx1, 3, "_") />
			<cfset variables.compName		= ListGetAt(inx1, 4, "_") />
			
			<cfloop index="n" from="1" to="#arrayLen(aComp)#">
				
				<cfif trim(aComp[n].type) eq variables.compType and trim(aComp[n].componentId) eq variables.compId and trim(aComp[n].paidTo.paidToId) eq variables.compPaidTo>
				
					<cfloop index="i" from="1" to="#arrayLen(aComp[n].prodRate)#">
					
						<cfset variables.rate = aComp[n].prodRate[i].rate />
						<cfset variables.uom = aComp[n].prodRate[i].uom.uomId />
						<cfset variables.item = aComp[n].prodRate[i].itemNumber />
						<cfset objProgramMFN.saveMFNData(form.Template_Generic_Type, form.Template_Created_Type, form.MFN_Program_ID, form.Program_Number, variables.compType, variables.compId, variables.compName, variables.compPaidTo, variables.rate, variables.uom, variables.item, qGetBusinessUnit.Business_Unit_ID) />
						
						<cfloop index="inx2" list="#form.MFN_Created_Type#">
							<cfset objProgramMFN.saveMFNData(form.Template_Generic_Type, inx2, form.MFN_Program_ID, form.Program_Number, variables.compType, variables.compId, variables.compName, variables.compPaidTo, variables.rate, variables.uom, variables.item, qGetBusinessUnit.Business_Unit_ID) />
						</cfloop>
							
					</cfloop>
					
				</cfif>
		
			</cfloop>
	
		</cfloop>
		
	</cfoutput>
	<cflocation url="contract_approve_broker_action.cfm?CID=#FORM.ApproveContract#&mfnComplete=1" />
</cfif>

<cfoutput>
<FORM NAME="selectMFN" ACTION="contract_approve_broker_action.cfm" METHOD="post">
<b>Select components to be considered as part of the Most Favored Nation:<b>
<br>
<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0" WIDTH="50%" CLASS="datagrid" id="compList">
	<thead>
	<tr>
		<th><INPUT TYPE="checkbox" NAME="allbox" ONCLICK="javaScript: check_all(this);"></th>
		<th>Component Name</th>
		<th>Component Type</th>
		<th>Pays To</th>
	</tr>
	</thead>
	<tbody>
		<cfloop index="n" from="1" to="#arrayLen(aComp)#">
		<TR>
			<td><input name="MFN_Component" value="#trim(aComp[n].type)#_#trim(aComp[n].componentId)#_#trim(aComp[n].paidTo.paidToId)#_#trim(aComp[n].name)#" type="checkbox" class="cbox"></td>
			<td>#aComp[n].name#</td>
			<td><cfif aComp[n].type eq 1>Fixed<cfelse>Rebate</cfif></td>
			<td>#aComp[n].paidTo.description#</td>
		</TR>
		</cfloop>
	</tbody>
</table>
<br>
<b>Select other templates to be considered as part of the Most Favored Nation:<b>
<br>
<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0" WIDTH="50%" CLASS="datagrid" id="templateList">
	<thead>
	<tr>
		<th><INPUT TYPE="checkbox" NAME="allbox2" ONCLICK="javaScript: check_all2(this);"></th>
		<th>Template</th>
	</tr>
	</thead>
	<tbody>
		<cfloop query="qGetTemplates">
		<TR>
			<td><input name="MFN_Created_Type" type="checkbox" class="cbox2" value="#trim(Created_Type)#"></td>
			<td>#Created_Type#</td>
		</TR>
		</cfloop>
	</tbody>
</table>
<br>
<table align="center">
	<tr>
		<td>
			<CF_button
				button_name		=	"continue"
				button_caption	=	"continue"
				button_action	=	"submitMFN()"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"continue with the application"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</td>
		<td>
			<CF_button
				button_name		=	"cancel"
				button_caption	=	"cancel"
				button_action	=	"contract_edit_menu.cfm?CID=#FORM.ApproveContract#"
				button_type		=	"link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"continue with the application"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</td>
	</tr>
</table>

<input name="ApproveContract" 		type="hidden" 	value="#form.ApproveContract#" />
<input name="Save_MFN" 				type="hidden" 	value="#form.Save_MFN#" />
<input name="Template_Generic_Type" type="hidden" 	value="#form.Template_Generic_Type#" />
<input name="Template_Created_Type" type="hidden" 	value="#form.Template_Created_Type#" />
<input name="Template_ID" 			type="hidden" 	value="#form.Template_ID#" />
<input name="Program_Number"		type="hidden"	value="#form.Program_Number#" />
<input name="MFN_Program_ID" 		type="hidden" 	value="#cryp.value#" />
</FORM>

</cfoutput>
</body>