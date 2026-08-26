<CFPARAM NAME="URL.CID" DEFAULT="">
<cfparam name="donotallowaddproductsDE" default = "0">
<cfparam name="form.deletedateexclusions" default = "0">
<cfparam name="url.EZTemplate" default="0">
<cfparam name="url.excludeList" default="0">
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
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

<CFSET URL.Contract_Main_ID = CSL_Contract_Main_ID>
<CFSET FORM.Contract_Main_ID = CSL_Contract_Main_ID>



<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 5; left: 10px; top: 0px">
  <CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
 <cfelse>
<CFINCLUDE TEMPLATE="contract_status_legend.cfm"></cfif>


<cfset GrowthChangeTarget = 1>

<!---For a revision, should show edit component information links or not? --->
<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Growth_Change_Target eq 2>
	<cfset GrowthChangeTarget = 2>
</cfif>  

<cfif url.EZTemplate EQ 0>
<BLOCKQUOTE><BLOCKQUOTE>
</cfif>
<cfif GetSettings.Date_Exclusions_ON EQ 1>
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />	
<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(CSL_Contract_Main_ID,0)>
<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
	<cfset donotallowaddproductsDE = 1>
</CFIF>
</cfif>

<cfif getsettings.EZButton_On EQ 1 and URL.EZTemplate EQ 0>
	<cfset EzButton_Disable = 1>
<cfelse>
	<cfset EzButton_Disable = 0>
</cfif>

<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
    <div id="Layer1" style="position:relative; height:430px; width:120px; z-index:1; left: 80px; top: 0px;"> </cfif> 
	<cfif url.EZTemplate EQ 0>
	  <cfinclude template="minimal_contract_info.cfm">
	</cfif>
	  <!---Get app settings--->
	  <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	  <cfset appSettings = genSettingsManager.get()>
	  <script>
	function addNewComponentWindow(component_id) {
		NewWindow("Contract_Discount_Growth_Add_Component.cfm?Program_ID=" + <CFOUTPUT>#FORM.Contract_Main_ID#</CFOUTPUT> + "&Component_ID="+component_id, "componentwindow", 600, 600, "yes", "yes")
	}
</script>

	<!--- D45016 :: Restrict access at component level for all discount types START--->	
	<cfquery name="getAllGrowthComponentsAccess" datasource="#application.datasource#">
			SELECT 	*
			FROM		Program_Growth_Component_Profile
			WHERE	Deleted = 0
			AND 		Profiles_ID = #request.AccessStructure.Profiles_ID#
			AND 		Allow_User_To_View = 1
	</cfquery> 
	<cfset restictList = valuelist(getAllGrowthComponentsAccess.Program_Growth_Component_Name_ID)>

	<!--- D45016 :: Restrict access at component level for all discount types END--->	

	  <CFQUERY NAME="getGrowthComponents" datasource="#application.datasource#">
	  SELECT *, CASE WHEN component_UOM = 1 THEN 'Cases' WHEN component_UOM = 
	  2 THEN 'Pounds' WHEN component_UOM = 3 THEN '%' WHEN component_UOM = 4 THEN '$' ELSE 'N/A' END AS component_UOM_Desc	
	  FROM Program_Growth_Components 
	  WHERE Program_ID = '#FORM.Contract_Main_ID#' 
	  AND Deleted = 0 
	  <cfif appSettings.getGrowthExpansion1() IS 1>
		AND IsParent = 1
	  </cfif>
	  <cfif listlen(restictList)>
	  	AND Program_Growth_Components_Name_Id NOT IN (#restictList#)
	  </cfif>
	  </CFQUERY>
	  <cfset growthCompList = ValueList(getGrowthComponents.Program_Growth_Components_Name_Id)>
		<cfif getGrowthComponents.Recordcount IS 0>
		  <cflocation url="Contract_Discount_Growth_Add_Component.cfm?Program_ID=#FORM.Contract_Main_ID#&Component_ID=0&CID=#URL.CID#&EZTemplate=#url.EZTemplate#">
		<cfelse>
		<FIELDSET STYLE="padding:6px; width: 800px; border: 1px solid Blue;">
		<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Growth Components 
		(<cfoutput>#getGrowthComponents.Recordcount#</cfoutput>)</LEGEND>
		<BR>
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- Main style used by the data tables															 --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
</style>
		<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0" ALIGN="center" BORDER="0">
	
		  <TR VALIGN="middle" HEIGHT="30"> 
		  
			<TD COLSPAN="100%" ALIGN="center"> 
		
				<cfsavecontent variable="Add_More_Comp_String"> 
				<!---Does revision allow component changes? --->
				<cfif appSettings.getDisableAddingComponentsOnRevision() AND bIsContractARevision>
					<CF_smallLink 
						title = "add additional component"
						url = "##"
						enabled = "0"
						parameters="title='adding new components are not allowed on revisions'"
					>
				<cfelse>
					<cfif EzButton_Disable EQ 0>
						<cfif GrowthChangeTarget IS NOT 2>  
							<cfif CreateObject("component", "components.programs.products.ProductGroupManager").isAllProductProgram(FORM.Contract_Main_ID, 4)>
								<cf_smallLink
									url="##"
									title="add additional component"
									enabled = 0
									parameters="title=""You cannot add more components if you already have a component with 'All Products'"" style=""font-size:10px;font-family : 'Arial';"""
								>
							<cfelse>
									<cf_smallLink
										url="Contract_Discount_Growth_Add_Component.cfm?Program_ID=#FORM.Contract_Main_ID#&Growth_Component_Name_ID=#getGrowthComponents.Program_Growth_Components_Name_Id#&Component_ID=0&CID=#URL.CID#&Action=Add&EZTemplate=#url.EZTemplate#&excludeList=#growthCompList#"
										title="add additional component"
										parameters="style=""font-size:10px;font-family : 'Arial';"""
									> 
							</cfif> 
						  <!---Does revision allow component changes? --->
						</cfif>
					<cfelse>
						&nbsp;
					</cfif>
				</cfif>
				</cfsavecontent>
				<cfoutput>#Add_More_Comp_String#</cfoutput> 
			</TD>
		  </TR>
		  
		  <TR BGCOLOR="#FFCE84" VALIGN="bottom"> 
			<td>&nbsp; </td>
			<TD ID="header"><B>Name</B></TD>
			<TD ID="header"><B>Description</B></TD>
			<TD ID="header" align="center"><B>UOM</B></TD>
			<TD ID="header"><B>Tiers</B></TD>
			<cfif appSettings.getGrowthExpansion1()>
			  <TD ID="header"><B>Type</B></TD>
			</cfif>
			<TD ID="header"><B>Paid To</B></TD>
			<TD ID="header">&nbsp;</TD>
		  </TR>
		  <CFOUTPUT QUERY="getGrowthComponents"> 
			<!---Gets component types--->
			<cfif appSettings.getGrowthExpansion1()>
			  <cfquery name="GetType" datasource="#application.datasource#">
			  SELECT Description FROM Program_Growth_Component_Type WHERE Program_Growth_Component_Type_ID 
			  = #getGrowthComponents.Program_Growth_Component_Type_ID # 
			  </cfquery>
			</cfif>
			<CFQUERY NAME="ItemsForComponent" datasource="#application.datasource#">
			SELECT Program_Growth_Component_Product_Data_ID 
			FROM Program_Growth_Component_Product_Data 
			WHERE Program_Growth_Component_ID = '#getGrowthComponents.Program_Growth_Component_ID#' 
			AND Deleted = 0 
			</CFQUERY>
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top"> 
			  <td><cfif ItemsForComponent.Recordcount GT 0>
				  <img src="../../Images/yes_small.gif" width="12" height="12" alt="" border="0">
				  <cfelse>
				  <img src="../../Images/no_small.gif" width="12" height="12" alt="" border="0"></cfif></td>
			  <TD WIDTH="200" VALIGN="bottom">#getGrowthComponents.Component_Name#&nbsp;</TD>
			  <TD WIDTH="250" VALIGN="bottom">#replace(getGrowthComponents.Component_Description,"&##44",",","ALL")#&nbsp;</TD>
			  <TD VALIGN="bottom" align="center" nowrap>#getGrowthComponents.component_uom_desc#&nbsp; </TD>
			  <TD VALIGN="bottom" ALIGN="center">#getGrowthComponents.Tier_Count#&nbsp; </TD>
			  <cfif appSettings.getGrowthExpansion1()>
				<TD VALIGN="bottom" ALIGN="center">
						<cfif GetType.RecordCount GT 0>
							#trim(GetType.Description)#
						  </cfif>
						  &nbsp; 
				  </TD>
			  </cfif>
			  <TD VALIGN="bottom" ALIGN="center">#templateManager.getPaymentPaidToTypeDesc(paidToID = getGrowthComponents.Component_Paid_To, paidToDesc="")#</TD>
			  <TD VALIGN="bottom" ALIGN="right"> 
				<!---Products--->
				<cfif ItemsForComponent.Recordcount GT 0>
				  <img src="../../Images/yes_small.gif" width="12" height="12" alt="" border="0">
				  <cfelse>
				  <img src="../../Images/no_small.gif" width="12" height="12" alt="" border="0">
				</cfif>
				<span STYLE="color: red;">[</span><A  HREF="Contract_Discount_Growth_Add_Component_Products.cfm?CID=#URL.CID#&COMPID=#getGrowthComponents.Program_Growth_Component_ID#&Growth_Component_Name_ID=#getGrowthComponents.Program_Growth_Components_Name_Id#&Program_ID=#FORM.Contract_Main_ID#&EZTemplate=#url.EZTemplate#" STYLE="cursor: pointer;">products</A><span STYLE="color: red;">]</span> 
				<!---Growth components--->
				<!---Only allow change in revision if not forbidden --->
				<cfif GrowthChangeTarget IS NOT 2>
				&nbsp; 
					<cfif appSettings.getDisableAddingComponentsOnRevision() AND bIsContractARevision>
						<CF_smallLink 
							title = "edit"
							url = "##"
							enabled = "0"
							parameters="title='editing components are not allowed on revisions'"
						>
					<cfelse>
							<A href="Contract_Discount_Growth_Add_Component.cfm?Program_ID=#FORM.Contract_Main_ID#&Growth_Component_Name_ID=#getGrowthComponents.Program_Growth_Components_Name_Id#&Component_ID=#getGrowthComponents.Program_Growth_Component_ID#&CID=#URL.CID#&Action=Edit&EZTemplate=#url.EZTemplate#"><span STYLE="color: red;">[</span>edit</A><span STYLE="color: red;">]</span> 
					</cfif>
				<!---Delete--->
				<cfif EzButton_Disable EQ 0>
				&nbsp;&nbsp;<A STYLE="cursor: pointer;" ONCLICK="verifyDelete('#getGrowthComponents.Program_Growth_Component_ID#', '#replace(getGrowthComponents.Component_Name, "'", "\'")#')"><img src="/Images/scissor.gif"  title="delete this component" border="0"></A>
				</cfif>
</TD>
			</TR>
			<!---Allow tier/target changes on revision --->
			</cfif>
		  </CFOUTPUT> 
		  <TR VALIGN="middle" HEIGHT="30"> 
			<TD COLSPAN="100%" ALIGN="center"> <cfoutput>#Add_More_Comp_String#</cfoutput> 
			</TD>
		  </TR>
		</TABLE>
		</fieldset>
	  </cfif>
	<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
	</div>
	</cfif>
<cfif url.EZTemplate EQ 0>
</BLOCKQUOTE></BLOCKQUOTE>
</cfif>
<FORM ACTION="Contract_Discount_Growth_Delete.cfm" METHOD="post" NAME="deleteComp" ID="deleteComp">
	<INPUT type="hidden" NAME="Comp_ID">
	<INPUT type="hidden" NAME="Program_Id" VALUE="<CFOUTPUT>#URL.CID#</CFOUTPUT>">
	<input TYPE="hidden" NAME="deletedateexclusions" value="0">
	<input TYPE="hidden" NAME="EZTemplate" value="#url.EZTemplate#">
</FORM>

<script>
function verifyDelete(component_id, component_name) {
		if(confirm("Are you sure you want to delete " + component_name + "?")) {
		<cfif donotallowaddproductsDE EQ 1>
if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
	{document.all.deletedateexclusions.value = 1;</cfif>
			document.all.Comp_ID.value = component_id;
			document.all.deleteComp.submit();
			<cfif donotallowaddproductsDE EQ 1> }</CFIF>
		}
	}
</script>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>
