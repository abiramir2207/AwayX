<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
<cfparam name="donotallowaddproductsDE" default = "0">
<cfparam name="form.deletedateexclusions" default = "0">
<!---Updates information on parent component.--->
<cfparam name="form.Growth_Component_Name_ID" default="">
<cfparam name="url.EZTemplate" default="0">


<cfif isDefined("blnSubmit") OR isDefined("form.Reorder")>
<cfif form.deletedateexclusions EQ 1>

<cfquery name="GetSettings" datasource="#application.datasource#">

	SELECT 	Program_Control_Panel_Options.Date_Exclusions_ON
	FROM 	Program_Control_Panel_Options
	INNER JOIN Contract_Main 
	ON 		Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
	WHERE 	Contract_Main_ID = #form.program_id#
	
</cfquery>

<cfif GetSettings.Date_Exclusions_ON EQ 1>
			<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />	
			<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(form.program_id,0)>
		<cfif form.deletedateexclusions EQ 1>
			<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
			<cfquery name="deletedateexclusions" datasource="#application.datasource#">
				update contract_main
				set deleted = 1
				where contract_main_id in (#valuelist(getDateExclusionprogramIDs.revision_program_id)#)
			</cfquery>
			<cfquery name="deletedateexclusions" datasource="#application.datasource#">
				update program_exclusions
				set deleted = 1
				where revision_program_id in (#valuelist(getDateExclusionprogramIDs.revision_program_id)#)
			</cfquery>
			</CFIF>
		</cfif>
</cfif>
</cfif>
</cfif>

<cfif isDefined("blnSubmit")>
<cfif WhichForm IS "EditInfo">
	<cfset useLakebaseForUpdateParentComponent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components")>
	<cfif useLakebaseForUpdateParentComponent>
		<cftry>
			<cfset application.oLakebase.updateRows("program_growth_components",
				{ "program_growth_component_id" = "eq.#Component_ID#" },
				{
					"component_name" = Component_Name,
					"program_growth_components_name_id" = form.Growth_Component_Name_ID,
					"component_description" = Component_Description,
					"gl_account_id" = GL_Account_ID
				}
			)>
			<cfcatch type="any">
				<cfset useLakebaseForUpdateParentComponent = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUpdateParentComponent>
		<cfquery name="UpdateParentComponent" datasource="#application.datasource#">
		UPDATE Program_Growth_Components
		SET Component_Name = '#Component_Name#',
			Program_Growth_Components_Name_Id = '#form.Growth_Component_Name_ID#',
			Component_Description = '#Component_Description#',
			GL_Account_ID = '#GL_Account_ID#'
		WHERE Program_Growth_Component_ID = '#Component_ID#'
		</cfquery>
	</cfif>
</cfif>
</cfif>

<cfif isDefined("form.Reorder")>

<cfloop collection = #Form# item = "FieldNames">
	<cfif left(FieldNames, 13) IS "Target_Order_">
		<cfset GUID_len = len(FieldNames) - 13>
		<cfset New_Order = evaluate("Form.#FieldNames#")>	
			
		<cfset FieldName = replace(FieldNames, "_", "-", "all")>
		<cfset Child_ID = right(FieldName, GUID_len)>
		
		<cfquery name="UpdateOrder" datasource="#application.datasource#">
		UPDATE Program_Growth_Components
		SET Target_Order = #New_Order#
		WHERE Program_Growth_Component_ID = '#Child_ID#'
		</cfquery>
		
	</cfif>
</cfloop>

</cfif>


<CFPARAM NAME="URL.CID" DEFAULT="">

<!---Get app settings--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<CFIF len(trim(URL.CID)) GT 0>
	<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
	<cfquery name="GetContractInfo" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Main
		WHERE Contract_Main_ID = '#cryp.value#'
	</cfquery>

		<!--- D50074 :: Viewing and Editing prior program versions START --->
		<cfinclude template="/get_access_profile.cfm">
		<cfset ModifyDeletedPrograms = CreateObject("component","components.programs.program").ModifyDeletedProgram(GetContractInfo.Contract_Main_ID,Get_Profile_Settings.Modify_Expired_Programs) />
		<!--- D50074 :: Viewing and Editing prior program versions END --->	
		<!--- Do not show the tabs if the contract is approved --->
	<CFIF GetContractInfo.Contract_Status_Type_IDX GT 2 AND ModifyDeletedPrograms EQ 0><!--- D50074 :: Viewing and Editing prior program versions --->
		<script>
			history.back();
		</script>
		<CFABORT>
	</CFIF>	
</CFIF>
<CFSET PAGE_TITLE="Growth Targets">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" ONLOAD="">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif url.EZTemplate EQ 0>
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "growth"> 
<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>

<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
  <CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
 <cfelse>
<CFINCLUDE TEMPLATE="contract_status_legend.cfm"></cfif>

<cfif GetSettings.Date_Exclusions_ON EQ 1>
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />	
<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(CSL_Contract_Main_ID,0)>
<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
	<cfset donotallowaddproductsDE = 1>
</CFIF>
</cfif>
<cfif url.EZTemplate EQ 0>
<BLOCKQUOTE><BLOCKQUOTE>
</cfif>
<cfoutput>

<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
<div id="Layer1" style="position:relative; height:430px; width:120px; z-index:1; left: 80px; top: 0px;"> </cfif>
<cfif url.EZTemplate EQ 0>
<cfinclude template="minimal_contract_info.cfm">
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	TABLE.Maintable TD	{border-bottom:solid ##93BEE2 1px; font-size : 10px;}
	##header {font-size: 12px;}
</style>


<cfquery name="GetTargets" datasource="#application.datasource#">
SELECT Program_Growth_Components.Component_Name, Program_Growth_Component_Tiers.Range_End AS Target, Program_Growth_Components.Target_Order, Units_Of_Measure.Abbreviation AS UOM, Program_Growth_Components.Program_Growth_Component_ID, Program_Growth_Components.Program_Growth_Component_Type_ID , Program_Growth_Component_Tiers.Growth_Amount
FROM Program_Growth_Components
	LEFT JOIN Program_Growth_Component_Tiers
	ON Program_Growth_Component_Tiers.Program_Growth_Component_ID = Program_Growth_Components.Program_Growth_Component_ID
	INNER JOIN Units_Of_Measure
	ON Units_Of_Measure.Unit_Of_Measure_ID = Program_Growth_Components.Component_UOM
WHERE Program_Growth_Components.Parent_ID = '#Component_ID#'
AND Program_Growth_Components.Deleted = 0
ORDER BY Program_Growth_Components.Target_Order
</cfquery>

<!---Gets component information needed for this growth--->
<cfset useLakebaseForGetComponentInformation = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components")>
<cfif useLakebaseForGetComponentInformation>
	<cftry>
		<cfset GetComponentInformation = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_growth_components", { "program_growth_component_id" = "eq.#Component_ID#" })
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetComponentInformation = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetComponentInformation>
	<cfquery name="GetComponentInformation" datasource="#application.datasource#">
	select *
	FROM Program_Growth_Components
	WHERE Program_Growth_Component_ID = '#Component_ID#'
	</cfquery>
</cfif>

<cfset Component_Type 	= GetComponentInformation.Program_Growth_Component_Type_ID>
<cfset Rate_Type 		= GetComponentInformation.Rate_Type>
	<cfinclude template="/common_files/contracts/contract_discount_growth_navigation.cfm">

<cfif getsettings.EZButton_On EQ 1 and URL.EZTemplate EQ 0>
	<cfset EzButton_Disable = 1>
<cfelse>
	<cfset EzButton_Disable = 0>
</cfif>


<form action="Contract_Discount_Growth_Targets.cfm?Program_ID=#url.Program_ID#&Component_ID=#url.Component_ID#&CID=#URL.CID#&Action=Edit&Component_Type=#url.Component_Type#&EZTemplate=#url.EZTemplate#" method="post" name="EditInfo">
<input type="hidden" name="WhichForm" value="EditInfo">
<input type="hidden" name="blnSubmit" value="1">
<cfset arAllowList = ArrayNew(1) />
<cfset bTemplateLevelComponentFilter = 1 />
<cfset compGrowth = CreateObject("component","components.programs.Growth.GrowthComponent")>
<!------ Operating Group ----->
<cfset componentsUnderOperatingGroupLevel2 = "" />
<cfif appSettings.getOperatingGroupOn()>
	<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
	<cfset programLevel2Level 				= operatingGroupManager.getProgramLevel2Level() />
	<!------ Get the operating group for this program ----->
	<cfset operatingGroupProgramLevel2 	= operatingGroupManager.getProgramOperatingGroupID(level=programLevel2Level, programId=FORM.Contract_Main_ID) />
	<cfset qGetComponentsUnderOperatingGroupLevel2 = operatingGroupManager.getComponents(operatingGroupProgramLevel2, 4) />
	<cfset componentsUnderOperatingGroupLevel2 = ValueList(qGetComponentsUnderOperatingGroupLevel2.Component_ID) />
	<cfset arAllowList[ArrayLen(arAllowList) + 1] = componentsUnderOperatingGroupLevel2 />
	<cfset bTemplateLevelComponentFilter = 0 />
</cfif>
<cfif bTemplateLevelComponentFilter>
	<!--- get a list of comps to filter based on template --->
	<cfset qComponents = CreateObject("component","components.programs.template.TemplateManager").getAllTemplateDiscountComponents(GetSettings.ProgramControl_Panel_Options_ID, 4, 1) />		
	<cfset lTemplateAllowList = ValueList(qComponents.Component_ID) />	
	<cfset arAllowList[ArrayLen(arAllowList) + 1] = lTemplateAllowList />
</cfif>
<cfset qCompGrowth = compGrowth.getActive(arAllowList) />


<table WIDTH="800" BORDER="0" CELLSPACING="0" CELLPADDING="2">
<tr><td colspan="100%" bgcolor="lightsteelblue"><font size="2"><strong>Component Information</strong></font></td></tr>
<tr>
	<td>&nbsp; </td>
	<td valign="top" align="right"><strong>Name:</strong></td>
	<TD nowrap>
		<cfoutput> 
			<select name="Growth_Component_Name_ID" style="width:180px" onChange="javascript:changeEvent(this, document.all.Component_Name);">
			<option value="-1" selected>Select Component</option> 
			<cfloop query="qCompGrowth">
			  <option value="#qCompGrowth.Program_Growth_Components_Name_Id#" <cfif qCompGrowth.Program_Growth_Components_Name_Id EQ GetComponentInformation.Program_Growth_Components_Name_Id >selected</cfif>>#Program_Growth_Components_Name# 
				  <cfif application.returned_customer_setting.external_id_on EQ 1>
					<cfif Len(External_ID) GT 0> (#External_ID#) </cfif>
				  </cfif>
			  </option>
			</cfloop>
			</select>
		</cfoutput> 
	</TD>
	<td><input type="hidden" name="Component_Name" value="#GetComponentInformation.Component_Name#"></td>	<td width="100%">&nbsp; </td>
</tr>

<!--- BJF 13410 Component information in discount pages --->
	<tr>
		<td colspan="2">&nbsp;</td>
		<td colspan="2">
			<cfdiv bind="url:component_information.cfm?Component_Name_ID={Growth_Component_Name_ID}&ModifyDeletedPrograms=#ModifyDeletedPrograms#&Discount_Type_ID=4&caller=GrowthEdit&programId=#FORM.Contract_Main_ID#" ID="compInfo"/>

		</td>
	</tr>
<tr>
	<td>&nbsp; </td>
	<td valign="top" align="right"><strong>Description:</strong></td>
	<td><textarea name="Component_Description" cols="50" rows="3">#GetComponentInformation.Component_Description#</textarea></td>
	<td width="100%">&nbsp; </td>
</tr>
<cfif EzButton_Disable EQ 0>
<tr>
	<Td colspan="2">&nbsp; </TD>
	<td><CF_button
					button_name		=	""
					button_caption	=	"Change information"
					button_action	=	"javascript: SubmitForm(EditInfo);"
					button_type		=	"link"
					button_width	=	"150"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				></td>
	<td width="100%">&nbsp; </td>
</tr>
</cfif>
</table>

<input type="hidden" name="program_id" value="#CSL_Contract_Main_ID#">
<input type="hidden" name="deletedateexclusions" value="#form.deletedateexclusions#">
</form>

<form action="Contract_Discount_Growth_Targets.cfm?Program_ID=#url.Program_ID#&Component_ID=#url.Component_ID#&CID=#URL.CID#&Action=Edit&Component_Type=#url.Component_Type#&EZTemplate=#url.EZTemplate#" method="post" name="Reorder">
<input type="hidden" name="WhichForm" value="EditInfo">
<input type="hidden" name="Reorder" value="1">
<input type="hidden" name="EZTemplate" value="#url.EZTemplate#">
<table WIDTH="800" BORDER="0" CELLSPACING="0" CELLPADDING="2" style="maintable">
<tr>
	<td bgcolor="orange"><font style="bold" size="2"><strong>Target Name</strong></font></td>
	<td bgcolor="orange"><font style="bold" size="2"><strong>Target Amount</strong></font></td>
	<td bgcolor="orange"><font style="bold" size="2"><strong>Unit of Measure</strong></font></td>
	<td bgcolor="orange"><font style="bold" size="2"><strong>Completion <cfoutput>#Application.BonusLabel#</cfoutput></strong></font></td>
	<td bgcolor="orange"><font style="bold" size="2"><strong>Order</strong></font></td>
	<td bgcolor="orange" colspan="2">&nbsp; </td>
</tr>

<cfloop query="GetTargets">

<cfset SafeGUID = replace(GetTargets.Program_Growth_Component_ID, "-", "_", "all")>

<tr>
	<td>#trim(Component_Name)#</td>
	<td>#Target#</td>
	<td>#UOM#</td>
	<td>#Growth_Amount#</td>
	<td><cfif Component_Type IS 2><input type="text" size="2" maxlength="2" name="Target_Order_#SafeGUID#" value="#Target_Order#" onkeyup="clenseText(this, '0123456789')"><cfelse>#Target_Order#</cfif></td>
	<td><A href="Contract_Discount_Growth_Add_Target.cfm?Program_ID=#FORM.Contract_Main_ID#&Component_ID=#Component_ID#&CID=#URL.CID#&Action=Edit&Component_Type=#GetTargets.Program_Growth_Component_Type_ID #&Child_ID=#GetTargets.Program_Growth_Component_ID#&EZTemplate=#url.EZTemplate#"><span STYLE="color: red;">[</span>edit</A><span STYLE="color: red;">]</span></td>
	<cfif EzButton_Disable EQ 0><td>&nbsp;&nbsp;<A STYLE="cursor: pointer;" ONCLICK="verifyDelete('#GetTargets.Program_Growth_Component_ID#', '#replace(GetTargets.Component_Name, "'", "\'")#')"><img src="/Images/scissor.gif"  title="delete this component" border="0"></A></td></cfif>
</tr>

</cfloop>
</table>

<table><tr>
<td>
<cfif Component_Type IS 2><CF_button
					button_name		=	""
					button_caption	=	"Reorder targets"
					button_action	=	"javascript: SubmitForm(Reorder);"
					button_type		=	"link"
					button_width	=	"150"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				><cfelse>&nbsp; </cfif>
				</td>
			<!------<td>
				<CF_button
					button_name		=	""
					button_caption	=	"Add new targets"
					button_action	=	"/common_files/contracts/Contract_Discount_Growth_Add_Target.cfm?Program_ID=#url.Program_ID#&Component_ID=#URL.Component_ID#&CID=#URL.CID#&Component_Type=#GetTargets.Program_Growth_Component_Type_ID#"
					button_type		=	"link"
					button_width	=	"150"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				></td>
			 	<td>
				<CF_button
					button_name		=	""
					button_caption	=	"Main page"
					button_action	=	"/common_files/contracts/Contract_Discount_Growth.cfm?Program_ID=#url.Program_ID#&CID=#URL.CID#"
					button_type		=	"link"
					button_width	=	"150"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				></td> --->
</tr></table>
<input type="hidden" name="program_id" value="#CSL_Contract_Main_ID#">
<input type="hidden" name="deletedateexclusions" value="#form.deletedateexclusions#">
</form>



</cfoutput>
<cfif url.EZTemplate EQ 0>
</BLOCKQUOTE></BLOCKQUOTE>
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>


<FORM ACTION="Contract_Discount_Growth_Delete.cfm" METHOD="post" NAME="deleteComp" ID="deleteComp">
	<INPUT type="hidden" NAME="Comp_ID">
	<INPUT type="hidden" NAME="Program_Id" VALUE="<CFOUTPUT>#URL.CID#</CFOUTPUT>">
	<input type="hidden" name="deletedateexclusions" value="0">
	<input type="hidden" name="EZTemplate" value="<cfoutput>#url.EZTemplate#</cfoutput>">
</FORM>

<script>
	function verifyDelete(component_id, component_name) {
		if(confirm("Are you sure you want to delete " + component_name + "?")) {
		<cfif donotallowaddproductsDE EQ 1>
if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
	{deleteComp.deletedateexclusions.value = 1;</cfif>
			document.all.Comp_ID.value = component_id;
			document.all.deleteComp.submit();
		<cfif donotallowaddproductsDE EQ 1>
	}
	</cfif>
		}
	}
	function SubmitForm(formname)
	{
		<cfif donotallowaddproductsDE EQ 1>
if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
	{formname.deletedateexclusions.value = 1;</cfif>
		formname.submit();
	<cfif donotallowaddproductsDE EQ 1>
	}
	</cfif>
	}
	function changeEvent(thisSelectObj, ComponentNameObj) {
		ComponentNameObj.value = thisSelectObj.options[thisSelectObj.selectedIndex].text;
	}

</script>
