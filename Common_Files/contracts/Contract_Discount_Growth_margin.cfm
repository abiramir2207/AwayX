<CFPARAM NAME="URL.CID" DEFAULT="">
<CFPARAM NAME="URL.MarginEdit_Saved" Default="0">
<cfparam name="donotallowaddproductsDE" default = "0">
<cfparam name="form.deletedateexclusions" default = "0">
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
<!--- <CFINCLUDE TEMPLATE="/includes/header.cfm"> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "growth"> 
<!---
<CFSET Help_URL="/help_files/manual/createprogram/page12.cfm">
--->
<CFSET URL.Contract_Main_ID = CSL_Contract_Main_ID>
<CFSET FORM.Contract_Main_ID = CSL_Contract_Main_ID>

<cfif application.programlayout EQ 1>
<!--- <div id="Layer2" style="position:absolute; width: 0px; height: 400px; z-index: 1; left: 10px; top: 0px;display:none;">
  <CFINCLUDE TEMPLATE="contract_status_legend_margin.cfm"></div>
 <cfelse>
<CFINCLUDE TEMPLATE="contract_status_legend_margin.cfm"> ---></cfif>

<CFINCLUDE TEMPLATE="commonqueries.cfm">
<BLOCKQUOTE><BLOCKQUOTE>
<cfif GetSettings.Date_Exclusions_ON EQ 1>
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />	
<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(CSL_Contract_Main_ID,0)>
<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
	<cfset donotallowaddproductsDE = 1>
</CFIF>
</cfif>

<cfif application.programlayout EQ 1>
    <div id="Layer1" style="position:absolute; height:430px; width:120px; z-index:1; left: 10px; top: 0px;"> </cfif> 
	  <cfinclude template="minimal_contract_info.cfm">
	  <!---Get app settings--->
	  <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	  <cfset appSettings = genSettingsManager.get()>
	  <script>
	function addNewComponentWindow(component_id) {
		NewWindow("Contract_Discount_Growth_Add_Component.cfm?Program_ID=" + <CFOUTPUT>#FORM.Contract_Main_ID#</CFOUTPUT> + "&Component_ID="+component_id, "componentwindow", 600, 600, "yes", "yes")
	}
</script>
	  <CFQUERY NAME="getGrowthComponents" datasource="#application.datasource#">
	  SELECT *, CASE WHEN component_UOM = 1 THEN 'Cases' WHEN component_UOM = 
	  2 THEN 'Pounds' WHEN component_UOM = 3 THEN '%' ELSE 'N/A' END AS component_UOM_Desc	
	  FROM Program_Growth_Components WHERE Program_ID = '#FORM.Contract_Main_ID#' 
	  AND Deleted = 0 
	  <cfif appSettings.getGrowthExpansion1() IS 1>
		AND IsParent = 1
	  </cfif>
	  </CFQUERY>
	  <!---Growth Options--->
	  <cfif appSettings.getGrowthExpansion1() AND getGrowthComponents.Recordcount IS 0>
		<cfoutput> 
		  <cflocation url="Contract_Discount_Growth_Main.cfm?ProgramID=Program_ID=#FORM.Contract_Main_ID#&Component_ID=0&CID=#URL.CID#">
		</cfoutput> 
		<cfelseif getGrowthComponents.Recordcount IS 0>
		<cfoutput>
		  <cflocation url="Contract_Discount_Growth_Add_Component.cfm?Program_ID=#FORM.Contract_Main_ID#&Component_ID=0&CID=#URL.CID#">
		</cfoutput> 
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
			<TD COLSPAN="100%" ALIGN="center"  style="display:none;"> <cfsavecontent variable="Add_More_Comp_String"> 
			  <cfif CreateObject("component", "components.programs.products.ProductGroupManager").isAllProductProgram(FORM.Contract_Main_ID, 4)><cf_smallLink
			url="##"
			title="add additional component"
			enabled = 0
			parameters="title=""You cannot add more components if you already have a component with 'All Products'"" style=""font-size:10px;font-family : 'Arial';"""
			>
				<cfelse>
				<cfif appSettings.getGrowthExpansion1() IS 1>
				  <cf_smallLink
				url="Contract_Discount_Growth_Main.cfm?Program_ID=#FORM.Contract_Main_ID#&Component_ID=0&CID=#URL.CID#&Action=Add"
				title="add additional component"
				parameters="style=""font-size:10px;font-family : 'Arial';"""
				> 
				  <cfelse>
				  <cf_smallLink
				url="Contract_Discount_Growth_Add_Component.cfm?Program_ID=#FORM.Contract_Main_ID#&Component_ID=0&CID=#URL.CID#&Action=Add"
				title="add additional component"
				parameters="style=""font-size:10px;font-family : 'Arial';"""
				> 
				</cfif>
			  </cfif> </cfsavecontent> <cfoutput>#Add_More_Comp_String#</cfoutput> 
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

		  <!--- Begin Table Data Output --->		  
		  
		  <CFOUTPUT QUERY="getGrowthComponents"> 
			<!---Gets component types--->
			<cfif appSettings.getGrowthExpansion1()>
			  <cfquery name="GetType" datasource="#application.datasource#">
			  SELECT Description FROM Program_Growth_Component_Type WHERE Program_Growth_Component_Type_ID 
			  = #getGrowthComponents.Program_Growth_Component_Type_ID # 
			  </cfquery>
			</cfif>
			<CFQUERY NAME="ItemsForComponent" datasource="#application.datasource#">
			SELECT Program_Growth_Component_Product_Data_ID FROM Program_Growth_Component_Product_Data 
			WHERE Program_Growth_Component_ID = '#getGrowthComponents.Program_Growth_Component_ID#' 
			AND Deleted = 0 
			</CFQUERY>
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top"> 
			  <td><cfif ItemsForComponent.Recordcount GT 0>
				  <img src="../../Images/yes_small.gif" width="12" height="12" alt="" border="0">
				  <cfelse>
				  <img src="../../Images/no_small.gif" width="12" height="12" alt="" border="0"></cfif></td>
			  <TD WIDTH="200" VALIGN="bottom">#getGrowthComponents.Component_Name#&nbsp;</TD>
			  <TD WIDTH="250" VALIGN="bottom">#getGrowthComponents.Component_Description#&nbsp;</TD>
			  <TD VALIGN="bottom" align="center" nowrap>#getGrowthComponents.component_uom_desc#&nbsp; 
			  </TD>
			  <TD VALIGN="bottom" ALIGN="center">#getGrowthComponents.Tier_Count#&nbsp; 
			  </TD>
			  <cfif appSettings.getGrowthExpansion1()>
				<TD VALIGN="bottom" ALIGN="center"><cfif GetType.RecordCount GT 0>
					#trim(GetType.Description)#
				  </cfif>
				  &nbsp; </td>
			  </cfif>
			  <TD VALIGN="bottom" ALIGN="center"><cfif getGrowthComponents.Component_Paid_To eq 1>Distributor<cfelseif getGrowthComponents.Component_Paid_To eq 2>Operator<cfelseif getGrowthComponents.Component_Paid_To eq 3>Broker<cfelseif getGrowthComponents.Component_Paid_To eq 4>Distributor & Operator</cfif></TD>

			  <TD VALIGN="bottom" ALIGN="right"> 
				<!---Products--->
				<cfif ItemsForComponent.Recordcount GT 0>
				  <img src="../../Images/yes_small.gif" width="12" height="12" alt="" border="0">
				  <cfelse>
				  <img src="../../Images/no_small.gif" width="12" height="12" alt="" border="0">
				</cfif>
				<span STYLE="color: red;">[</span><A STYLE="cursor:pointer;" HREF="Contract_Discount_Growth_Add_Component_Products_margin.cfm?CID=#URL.CID#&COMPID=#getGrowthComponents.Program_Growth_Component_ID#&Program_ID=#FORM.Contract_Main_ID#" STYLE="cursor: hand;">products</A><span STYLE="color: red;">]</span> 
				<!---Growth components--->
				&nbsp; <cfif appSettings.getGrowthExpansion1()>
				  <cfif getGrowthComponents.Program_Growth_Component_Type_ID  IS 1>
					<A style="display:none;" href="Contract_Discount_Growth_Add_Component.cfm?Program_ID=#FORM.Contract_Main_ID#&Component_ID=#getGrowthComponents.Program_Growth_Component_ID#&CID=#URL.CID#&Action=Edit&Component_Type=#getGrowthComponents.Program_Growth_Component_Type_ID #"><span STYLE="color: red;">[</span>edit<span STYLE="color: red;">]</span></A> 
					<cfelse>
					<A style="display:none;" href="Contract_Discount_Growth_Targets.cfm?Program_ID=#FORM.Contract_Main_ID#&Component_ID=#getGrowthComponents.Program_Growth_Component_ID#&CID=#URL.CID#&Action=Edit&Component_Type=#getGrowthComponents.Program_Growth_Component_Type_ID #"><span STYLE="color: red;">[</span>edit<span STYLE="color: red;">]</span></A> 
				  </cfif>
				  <cfelse>
				  <A style="display:none;" href="Contract_Discount_Growth_Add_Component.cfm?Program_ID=#FORM.Contract_Main_ID#&Component_ID=#getGrowthComponents.Program_Growth_Component_ID#&CID=#URL.CID#&Action=Edit"><span STYLE="color: red;">[</span>edit<span STYLE="color: red;">]</span></A> 
				</cfif> 
				<!---Delete--->
				&nbsp;&nbsp;<A STYLE="cursor: hand;display:none;" ONCLICK="verifyDelete('#getGrowthComponents.Program_Growth_Component_ID#', '#replace(getGrowthComponents.Component_Name, "'", "\'")#')"><img src="/Images/scissor.gif"  title="delete this component" border="0"></A></TD>
			</TR>
<!--- 		  <cfset URL.CID="#URL.CID#">
		  <cfset URL.Component_ID="#getGrowthComponents.Program_Growth_Component_ID#">
		  <cfset URL.Program_ID="#FORM.Contract_Main_ID#">
		  
		  <tr><td colspan="100%"><div><cfinclude template="contract_discount_growth_add_component_products.cfm" /></div></td></tr> --->
		   </CFOUTPUT> 
		   <!--- End Table Data Output --->
		  
		  <TR VALIGN="middle" HEIGHT="30"> 
			<TD COLSPAN="100%" ALIGN="center" style="display:none;"> <cfoutput>#Add_More_Comp_String#</cfoutput> 
			</TD>
		  </TR>
		</TABLE>
	
	<div align="center"><br>
	<CF_smallLink   
		title = "close window"   
		url = "##"  
		parameters = "onClick=""JavaScript: top.close();if(top.opener){top.opener.focus()};""" 
		>
	</div>
	</fieldset>
	  </cfif><cfif application.programlayout EQ 1>
	</div>
	</cfif>
</BLOCKQUOTE></BLOCKQUOTE>
<FORM ACTION="Contract_Discount_Growth_Delete.cfm" METHOD="post" NAME="deleteComp" ID="deleteComp">
	<INPUT type="hidden" NAME="Comp_ID">
	<INPUT type="hidden" NAME="Program_Id" VALUE="<CFOUTPUT>#URL.CID#</CFOUTPUT>">
	<input TYPE="hidden" NAME="deletedateexclusions" value="0">
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
<cfif GetContractInfo.modifying_program EQ 0 and marginedit_saved>
	<cfset overrideClosure = 1>
	<cfset form.programid = '#URL.CID#' />
	<cfinclude template="reset_program_agreed.cfm" />
</cfif>
</BODY>
</HTML>
