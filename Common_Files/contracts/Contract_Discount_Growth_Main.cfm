<!---Only do this once the page has been submitted to itself--->
<cfparam name="donotallowaddproductsDE" default = "0">
<cfparam name="form.deletedateexclusions" default = "0">
<cfparam name="Component_Type" default="0">
<cfparam name="url.EZTemplate" default="0">
<cfparam name="FORM.Component_Name" default="">

<cfif isdefined("blnSubmit")>
<cfparam name="FORM.PaymentCycle" 	default="0">
<cfoutput><!---If it's greater than 1 then it's a stairway or xofy component--->
<cfif Component_Type GT 1>

<cfparam name="Component_Descript" default="">

<Cfif Component_Type IS 2 and len(Trim(Component_Name)) LT 1>
	<cfset Component_Name = "Stairway">
<cfelseif Component_Type IS 3 and len(Trim(Component_Name)) LT 1>
	<cfset Component_Name = "X of Y">
<cfelseif len(Trim(Component_Name)) LT 1 >
	<cfset Component_Name="Growth Component">
</CFIF>

<cfif form.deletedateexclusions EQ 1>
<cfquery name="GetSettings" datasource="#application.datasource#">

	SELECT 	Program_Control_Panel_Options.Date_Exclusions_ON
	FROM 	Program_Control_Panel_Options
			INNER JOIN Contract_Main ON 
			Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
	WHERE 	Contract_Main_ID = '#Form.Program_ID#'
	
</cfquery>

<cfif GetSettings.Date_Exclusions_ON EQ 1>
			<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />	
			<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(Form.Program_ID,0)>
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
	<!----Create parent component--->
	<cfquery name="CreateParentComponent" datasource="#application.datasource#">
	INSERT INTO Program_Growth_Components
	(
		Program_ID,
		Rate_Type,
		Program_Growth_Component_Type_ID,
		IsParent,
		Is_Rate, 
		Component_Name,
		Program_Growth_Components_Name_Id,
		Component_Description,
		Component_UOM,
		GL_Account_ID
	)
	VALUES
	(
		'#Form.Program_ID#',
		'#Rate_Type#',
		'#Component_Type#',
		1,
		1,
		'#Component_Name#',
		'#FORM.Growth_Component_Name_ID#',
		'#Component_Description#',
		0,
		'#GL_Account_ID#'
	)
	</cfquery>
	
	<!------ Start Clause Code ----->
	<cfset discountTypeId = 4>
	<cfset programId = Form.Program_ID>
	<cfinclude template="/Clause_Library/Clause_Discount_Type_Add_Remove.cfm">
	<!------ End  Clause Code ----->

	<!------ update discount type payment cycle ----->
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
	<cfif appSettings.getPaymentCycleAtDiscountType()>		
		<cfset paymentCycleManager = CreateObject("component", "components.programs.PaymentCycleManager").init() />
		<cfset paymentCycleManager.savePaymentCycle(Form.Program_ID, 4, FORM.PaymentCycle) />
	</cfif>
	
	<cflocation url="Contract_Discount_Growth_Add_Target.cfm?Program_ID=#FORM.Program_ID#&CID=#FORM.CID#&Component_Type=#Component_Type#&Rate_Type=#Rate_Type#&Growth_Component_Name_ID=#Growth_Component_Name_ID#&Component_ID=#CreateParentComponent.A_ID#&EZTemplate=#url.EZTemplate#">
<!---It's a normal component, and should be redirected to the main page--->
<cfelse>
	<cflocation url="Contract_Discount_Growth_Add_Component.cfm?Program_ID=#FORM.Program_ID#&Component_ID=0&CID=#FORM.CID#&Component_Type=#Component_Type#&Rate_Type=#Rate_Type#&Growth_Component_Name_ID=#Growth_Component_Name_ID#&Component_Name=#replace(Component_Name,'&','%26','all')#&Component_Description=#Component_Description#&PaymentCycle=#FORM.PaymentCycle#&EZTemplate=#url.EZTemplate#">
</cfif>
</cfoutput>

<cfabort>
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
<CFSET PAGE_TITLE="Product Growth Entry">
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

<cfif application.programlayout EQ 1>
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
<BLOCKQUOTE><BLOCKQUOTE>
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
	.underlined {border-bottom:solid ##93BEE2 1px; font-size : 10px;}
</style>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset compGrowth = CreateObject("component","components.programs.Growth.GrowthComponent")>

<!---Form submits to this page and then redirect to the appropriate next page--->
<TABLE WIDTH="600" CELLPADDING="3" CELLSPACING="0" ALIGN="center" BORDER="0">
<form action="contract_discount_growth_main.cfm?EZTemplate=#url.EZTemplate#" name="AdditionalInfo" method="post"> 
<input type="hidden" name="blnSubmit" value="1">
<input type="hidden" name="Program_ID" value="#url.Contract_Main_ID#">
<input type="hidden" name="Component_ID" value="#url.Component_ID#">
<input type="hidden" name="CID" value="#url.CID#">
<cfset arAllowList = ArrayNew(1) />
<cfset bTemplateLevelComponentFilter = 1 />

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
<tr>
	<td class="underlined" colspan="2"><strong><font color="navy" size="2">Component Name</font></strong></td>
	<TD nowrap class="underlined">
		<cfoutput> 
			<select name="Growth_Component_Name_ID" style="width:240px" onChange="javascript:changeEvent(this, document.all.Component_Name);">
			<option value="-1" selected>Select Growth Component</option> 
			<cfloop query="qCompGrowth">
			  <option value="#Program_Growth_Components_Name_Id#" <cfif qCompGrowth.recordcount EQ 1>selected</cfif>>#Program_Growth_Components_Name# 
				  <cfif application.returned_customer_setting.external_id_on EQ 1>
					<cfif Len(External_ID) GT 0> (#External_ID#) </cfif>
				  </cfif>
				  <cfif len(trim(Allowance_Code_Number))> - (#Allowance_Code_Number#)</cfif>
			  </option>
			</cfloop>
			</select>
		</cfoutput> 
	</TD>
</tr>

<!--- BJF 13410 Component information in discount pages --->
	<tr>
		<td colspan="100%"><span class="Err_Sp_GL"></span>
			<cfdiv bind="url:component_information.cfm?Component_Name_ID={Growth_Component_Name_ID}&ModifyDeletedPrograms=#ModifyDeletedPrograms#&Discount_Type_ID=4&ProgramType_ID=#CSLGetContractInfo.ProgramType_ID#&ClaimMechanics=#CSLGetContractInfo.ClaimMechanics#&Is_A_Revision=#CSLGetContractInfo.Is_a_Revision#&EligibleRecordCount=#GetPaymentTypesforTemplate.Recordcount#&caller=Growth&programId=#FORM.Contract_Main_ID#" ID="compInfo"/>

		</td>
	</tr>

<cfif qCompGrowth.recordcount EQ 1 and form.Component_Name eq "">
	<cfset form.Component_Name = qCompGrowth.Program_Growth_Components_Name >
</cfif>
<input type="hidden" name="Component_Name" value="#form.Component_Name#">

<tr><td class="underlined" colspan="2"><strong><font color="navy" size="2">Description</font></strong></td>
	<td class="underlined"><textarea name="Component_Description" rows="3" cols="50"></textarea></td>
</tr>
<cfif appSettings.getPaymentCycleAtDiscountType()>
<tr>
	<td class="underlined" colspan="2"><strong><font color="navy" size="2">Payment Cycle</font></strong></td>
	<td class="underlined">
	<cfparam name="FORM.PaymentCycle" 	default="0">
	<cf_payment_cycle_selection
		Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
		Program_ID = "#FORM.Contract_Main_ID#"
		discount_Type_ID = "4"
		Selected_Payment_Cycle_ID = "#FORM.PaymentCycle#"
		>
	</td>
</tr>
</cfif>

<tr><td colspan="3" class="underlined"><strong><font color="navy" size="2">Component Type</font></strong></td></tr>
<!---Normal--->
<tr><td width="20"><CF_SmallHelp width="400"><table><tr><td>Normal growth components establish tiers of volume for one set of items which need to be purchased. Once enough volume has been purchased to achieve a tier, items will be discounted at that tier's rate.</td></tr></table></CF_SmallHelp></td>
	<td>Normal growth component:</td>
	<td><input type="radio" name="Component_Type" value="1" checked></td>
</tr>
<cfif GetSettings.Allow_XofY IS 1>
	<!---X of Y--->
	<tr><td><cf_SmallHelp width="400"><table><tr><td>In an X of Y component, volume targets are established for groups of items. For each target met, a tier is attained for rate. Let's say you set up three targets: 1000 pounds of Item1, 102% of Item2 and 100 cases of Item3 and Item4. If the clients buy 1200 pounds of Item1 and 230 combined cases of Item3 and Item4, but only 98% of Item2, they will have attained the second tier, and the second tier rates will be paid on whatever items they have added for rates.</td></tr></table> </cf_SmallHelp></td>
		<td>X of Y:</td>
		<td><input type="radio" name="Component_Type" value="3"></td>
	</tr>
</cfif>
<cfif GetSettings.Allow_Stairway IS 1>
	<!---Stairway to Heaven--->
	<tr><td><cf_SmallHelp width="400"><table><tr><td>A stairway component has volume targets the same way an X of Y program is. The difference between an X of Y and a stairway component is that the tiers for a stairway program must be accomplished in order. By default, stairway targets are in the order entered, but you can adjust their order after you have created them.</td></tr></table> </cf_SmallHelp></td>
		<td>Stairway to Heaven:</td>
		<td><input type="radio" name="Component_Type" value="2"></td>
	</tr>
</cfif>

<input type="hidden" name="Rate_Type" value="1">
<!--- <tr><td colspan="2" class="underlined"><strong><font color="navy" size="2">Rate Type</font></strong></td></tr>

<cfif GetSettings.Allow_Single IS NOT 0>
	<!---single rate--->
	<tr>
		<td>Single Rate:</td>
		<td><input type="radio" name="Rate_Type" value="1" checked></td>
	</tr>
</cfif>

<cfif GetSettings.Allow_Multi IS NOT 0>
	<!---Multi rate--->
	<tr>
		<td>Multi Rate:</td>
		<td><input type="radio" name="Rate_Type" value="2"></td>
	</tr>
</cfif>

<cfif GetSettings.Allow_Single IS 0 AND GetSettings.Allow_Multi IS 0>
<input type="hidden" name="Rate_Type" value="1"><Tr><td>Single rate</td><td>&nbsp; </td></TR>
</cfif>
 --->
<input type="hidden" name="deletedateexclusions" value="0">
</form>	
</table>



<div align="center">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 
	<cfif appSettings.getDisableAddingComponentsOnRevision() AND bIsContractARevision>
		<CF_smallLink 
			title = "continue"
			url = "##"
			enabled = "0"
			parameters="title='adding new components are not allowed on revisions'"
		>
	<cfelse>
		<CF_button
			button_name		=	""
			button_caption	=	"continue"
			button_action	=	"javascript: submitForm();"
			button_type		=	"link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</cfif>
</div>

<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0></div></cfif>
</cfoutput>
</BLOCKQUOTE></BLOCKQUOTE>
<cf_MessageWindow>
<script>
function submitForm()
{
	ErrorCount = 0;
	var checknormalgrowth
	<cfif appSettings.getPaymentCycleAtDiscountType()>
		<!------ check for payment cycle ----->		
		if(document.all.PaymentCycle.value == "0") {
			queueMessage("Select a payment cycle", document.all.Err_Sp_PaymentCycle)
			ErrorCount++
		} else {
			clearQueue(document.all.Err_Sp_PaymentCycle)
		}
	</cfif>
	<cfif appsettings.getGL_Account_On() IS 1 AND appsettings.getGL_Account_Required_for_Comp() IS 1>
		if (document.all.GL_Account_ID.value == 0 || document.all.GL_Account_ID.value == null)
		{
			queueMessage("You must select a <cfoutput>#Application.GLAccountLabel#</cfoutput> for this component", document.all.Err_Sp_GL)//D42774
			ErrorCount++
		}
		</cfif>
	if(ErrorCount==0)
	{
		if(window.document.all.Component_Type[0] == null)
		{
			radio_choice = document.all.Component_Type.value;
		}
		else
		{
			for (counter = 0; counter < document.all.Component_Type.length; counter++)
			{
				if (document.all.Component_Type[counter].checked)
				radio_choice = document.all.Component_Type[counter].value; 
			}
		}

	if(radio_choice != 1)
	{
		<cfif donotallowaddproductsDE EQ 1>
if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
	{
		document.all.deletedateexclusions.value = 1; </cfif> 
		document.all.AdditionalInfo.submit();
	<cfif donotallowaddproductsDE EQ 1>}
	</cfif>
	}
	else
	{
		document.all.deletedateexclusions.value = 1;
		document.all.AdditionalInfo.submit();
	}
	}
	else
	{
		showMessageWindow();
	}
}
function changeEvent(thisSelectObj, ComponentNameObj) {
	ComponentNameObj.value = thisSelectObj.options[thisSelectObj.selectedIndex].text;
}
</script>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>

