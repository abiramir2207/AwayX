<CFPARAM NAME="URL.CID" DEFAULT="">
<cfparam name="form.Fixed_Component_Paid_To" default="">

<CFSET thisPage=GetFileFromPath(GetCurrentTemplatePath())>
<CFSET fullUrl="">
<cfloop collection=#URL# item="thisURLItem">
	<CFIF thisURLItem NEQ "Sort_By">
		<CFSET fullUrl=ListAppend(fullUrl, "#thisURLItem#=#StructFind(URL, thisURLItem)#","&")>
	</CFIF>
</cfloop>
<CFIF Len(fullUrl) GT 0>
	<CFSET fullUrl="#thisPage#?#fullUrl#&">
<CFELSE>
	<CFSET fullUrl="#thisPage#?">
</CFIF>

<cfparam name="URL.Sort_By" 	default="Item">

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

<CFSET PAGE_TITLE= "Product Fixed Component Creation">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" ONLOAD="">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "fixed_prices"> 
<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>
<cfparam name="form.update" default="0">


<cfif application.programlayout EQ 1>
<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
  <CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
<cfelse>
<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
</cfif>
<BLOCKQUOTE><BLOCKQUOTE>

<CFSET HideProductList = 1>

<CFSET helpfilenumber=7>
<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 60px; top: 10px;"> </cfif>
<cfinclude template="minimal_contract_info.cfm">


<CFQUERY NAME="getProgramInfo" datasource="#application.datasource#">
SELECT     dbo.Units_of_Measure.Unit_Of_Measure_Desc, dbo.Units_of_Measure.Abbreviation, dbo.Contract_Main.Contract_Quantity
FROM         dbo.Contract_Main INNER JOIN
                      dbo.Units_of_Measure ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID
	WHERE dbo.Contract_Main.Contract_Main_ID = '#FORM.Contract_Main_ID#' 
</CFQUERY>
<CFSET Fixed_Desc_Max_Length = 255>
<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/common_files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT>

	function editComponent(id, name_id, description, paid_to) {
		
		if(parseInt(document.all.update.value) == 1) {
			if(confirm("You are currently editing a component. Press OK to save the component OR press CANCEL to edit a new component.")){
				document.all.FixedComponents.action = "Contract_Fixed_Component_Save.cfm";
				document.all.FixedComponents.submit()
			}
		}
	
		changeLabel("save changes", 1);
		var opt = Get_Object_Property_Match_Collection(document.all.Program_Fixed_Component_Name_ID.options, "value", name_id);
		if (opt)
		{
			opt.selected = true;
		}
		
		
		document.all.fixed_component_desc.value = description;
		document.all.Fixed_Component_Paid_To.value = paid_to;
		
		if(paid_to == 1)
		{
		document.all.Fixed_Component_Paid_To[0].checked = true;}
		else
		{
		document.all.Fixed_Component_Paid_To[1].checked= true;}
		document.all.update.value = 1;
		document.all.component_id.value = id

		
		document.all.error_Name.innerHTML = ""
		document.all.error_Name.style.width = 0;
		
	}	
	<cfoutput>
	function showProductView(Program_Fixed_Component_ID)
	{
	location = "contract_discount_fixed_prices.cfm?Program_Fixed_Component_ID=" + Program_Fixed_Component_ID + "&CID=#URL.CID#"
	}
	</cfoutput>
	
	function resetFixedComponent(){
		
		changeLabel("save new", 1);
		
		document.all.fixed_component_desc.value = "";
		document.all.update.value = 0;
		document.all.component_id.value = 0
		for(i=0; i < document.all.Fixed_Component_Paid_To.length; i++)
		{
		if (document.all.Fixed_Component_Paid_To[i].checked)
		{
			document.all.Fixed_Component_Paid_To[i].checked = false;
		}
		}
		
		document.all.error_Name.innerHTML = ""
		document.all.error_Name.style.width = 0;


	}
	function deleteComponent(component_id, name) {
		if(confirm("Do you really want to delete " + name + "?")){
			document.all.comDeleteForm.Component_ID.value = component_id;
			document.all.comDeleteForm.submit();
		}

	}
	
	

	function saveFixedComponent(){
		ErrorCount = 0
		var radioSelected; 
		if(document.all.Program_Fixed_Component_Name_ID.selectedIndex <= 0){
			ErrorCount++;
			queueMessage("You must select a fixed component", document.all.error_Name);
		}
		else {
			clearQueue(document.all.error_Name);
		}
		
		for(i=0; i < document.all.Fixed_Component_Paid_To.length; i++)
		{
		if (document.all.Fixed_Component_Paid_To[i].checked)
			 {radioSelected = document.all.Fixed_Component_Paid_To[i].value }
	 }
			
			if(!radioSelected)
			{
			
				ErrorCount++;
				queueMessage("Select A Paid to for this component", document.all.error_Paid_To);
			}
			else {
				clearQueue(document.all.error_Paid_To);
			}	 
	
				
		if(document.all.fixed_component_desc.value.length > <CFOUTPUT>#Fixed_Desc_Max_Length#</CFOUTPUT>)	{
			ErrorCount++;
			queueMessage("Description cannot be longer than <CFOUTPUT>#Fixed_Desc_Max_Length#</CFOUTPUT> characters", document.all.error_Desc);
		}
		else
		{
			clearQueue(document.all.error_Desc);
		}
		
	

	if(ErrorCount == 0)
	{	
	var actionpage = "Contract_Fixed_Component_Save.cfm";
	var comp_id = parseInt(document.all.FixedComponents.component_id.value);
		if ((isNaN(comp_id) || comp_id == 0) && document.all.update.value == 0)
		<cfoutput>{actionpage = "Contract_Discount_Fixed_Prices.cfm?CID=#URL.CID#"; }</cfoutput>

	
	document.all.FixedComponents.action = actionpage;
	document.all.FixedComponents.submit();	
		
		}
		else{
			showMessageWindow();
		}
	}
	function changeLabel(sLabel, whichOne)
	{
		var aObj;
		if(whichOne == 2)
		{			
			aObj = document.all.fixed_component_reset;
		}
		else
		{
			aObj = document.all.fixed_component_save;
		}
		aObj.innerHTML = sLabel;
	}
<!--- 
<CFINCLUDE TEMPLATE="/script/javascript/string_functions.js">
<CFINCLUDE TEMPLATE="/common_files/scripts/allowonlytwodecimalplaces.js"> 
--->
</SCRIPT>

<CF_MessageWindow>
<Br>



<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
<CFOUTPUT><FORM ACTION="Contract_Discount_Fixed_Prices.cfm?CID=#URL.CID#" METHOD="post" NAME="FixedComponents" ID="FixedComponents"><strong>1. Add a Fixed</CFOUTPUT> component</strong><br>
<FIELDSET STYLE="padding:10px; width: 700px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Component Information</LEGEND>

 <cfquery name="GetFixedComponentNames" datasource="#application.datasource#">
        SELECT *
		FROM Program_Fixed_Component_Name 
		WHERE 
		Active = 1 
		AND Deleted = 0 
  </cfquery>
  
<table WIDTH="750" border="0" cellpadding="2" cellspacing="0">
	<tr>
<!--- 		<td COLSPAN="2" STYLE="border-bottom:solid 1px blue;"><B>Volumes</B></td>
		<td BGCOLOR="white" ROWSPAN="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td> --->
		<td COLSPAN="4" STYLE="border-bottom:solid 1px blue;"><B>Components</B></td>
		<td BGCOLOR="white" ROWSPAN="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
		<!--- <td COLSPAN="2" STYLE="border-bottom:solid 1px blue;"><B>Rates</B></td> --->
	</tr>
	<tr BGCOLOR="eeeeee">
<!--- 		<td>Volume</td>
		<td>Average Volume</td> --->
		<td>Component Name</td>
		<td>Rate</td>
		<td>UOM</td>
		<TD>Paid To</TD>
	</tr>
	<TR>
	<TD>
	  <cfoutput> 
              <select name="Program_Fixed_Component_Name_ID" style="width:180px">
			  	<option value="-1" selected>Select Component</option> 
                <cfloop query="GetFixedComponentNames">
                  <option value="#Program_Fixed_Component_Name_ID#" >#Program_Fixed_Component_Name# 
                  <cfif application.returned_customer_setting.external_id_on EQ 1>
                    <cfif Len(External_ID) GT 0>
                      (#External_ID#) 
                    </cfif>
                  </cfif>
                  </option>
                </cfloop>
              </select>
            </cfoutput> 
	</TD>
	<td><input name="rate" type="text" size="10" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,3)" /></td>
		<td>
							
			<cf_uom_dropdown
				program_id				=	"#FORM.Contract_Main_ID#"
				company_main_id			=	""
				default_option_on		=	"0"
				default_option_text		=	""
				default_option_value	=	""
				dropdown_name			=	"uom"
				option_text_abbreviated	=	"1"
				plural_uom_display		=	""
				product_type_id			=	"1"
				program_template_id		=	""
				selected_uom_id			=	""
				text_before_tag_close	=	""
				uom_id_exclusion_list	=	""
				uom_id_inclusion_list	=	""
				setDefaultSelected		= 	1		
			>
		</td>
		<TD>
			<input name="Fixed_Component_Paid_To" type="Radio" value="1">&nbsp;Distributor<br>
			<input name="Fixed_Component_Paid_To" type="Radio" value="2">&nbsp;Operator
		</TD>
		
	</TR>
</table>
	
      <!--- <TABLE ID="oFixedComponentTable" BORDER="0">
        <cfquery name="GetFixedComponentNames" datasource="#application.datasource#">
        SELECT *
		FROM Program_Fixed_Component_Name 
		WHERE 
		Active = 1 
		AND Deleted = 0 
        </cfquery>
        <TR valign="top"> 
          <TD width="86" ALIGN="right" nowrap><B>Name:</B><SPAN ID="error_Name"></SPAN>&nbsp;</TD>
          <TD colspan="2"> 
            <!------ external id ----->
            <cfoutput> 
              <select name="Program_Fixed_Component_Name_ID" style="width:180px">
			  	<option value="-1" selected>Select Component</option> 
                <cfloop query="GetFixedComponentNames">
                  <option value="#Program_Fixed_Component_Name_ID#" >#Program_Fixed_Component_Name# 
                  <cfif application.returned_customer_setting.external_id_on EQ 1>
                    <cfif Len(External_ID) GT 0>
                      (#External_ID#) 
                    </cfif>
                  </cfif>
                  </option>
                </cfloop>
              </select>
            </cfoutput> </TD>
        </TR>
        <TR valign="top"> 
          <TD rowspan="2" ALIGN="right" nowrap><B>Paid_to:</B><SPAN ID="error_Paid_To"></SPAN>&nbsp;</TD>
          <TD width="20"><INPUT NAME="Fixed_Component_Paid_To" TYPE="Radio" VALUE="1" >
          </td>
          <TD width="540" valign="middle">Distributor</td>
          <td width="10" rowspan="2"> <br> </TD>
        </TR>
        <TR valign="top">
          <TD width="20"><input name="Fixed_Component_Paid_To" type="Radio" value="2"></td>
          <TD valign="middle">Operator</td>
        </TR>
        <TR valign="top"> 
          <TD ALIGN="right" nowrap><B>Description:</B><SPAN ID="error_Desc"></SPAN>&nbsp;</TD>
          <TD colspan="2" nowrap><CFOUTPUT> 
              <TEXTAREA COLS="50" ROWS="" NAME="fixed_component_desc" onPaste="javaScript: return textareaChecklength(#Fixed_Desc_Max_Length#, this);"  onkeyPress="javaScript: return textareaChecklength(#Fixed_Desc_Max_Length#, this);"></TEXTAREA>
            </CFOUTPUT> &nbsp;<B><FONT COLOR="FF0000">[</FONT><a HREF="##" onClick="saveFixedComponent();return false;" id="fixed_component_save">save 
            component</a><FONT COLOR="FF0000">]</FONT></B> &nbsp;<B><FONT COLOR="FF0000">[</FONT><a HREF="##" onClick="resetFixedComponent();return false;" id="fixed_component_reset">reset 
            fields</a><FONT COLOR="FF0000">]</FONT></B> </TR>
      </table> --->
</FIELDSET>
<input TYPE="Hidden" NAME="Program_ID" VALUE="<CFOUTPUT>#URL.CID#</CFOUTPUT>">
<input TYPE="Hidden" NAME="component_id" VALUE="">
<input TYPE="Hidden" NAME="update" VALUE="0">
</FORM>


<CFQUERY NAME="getAllFixedComponents" datasource="#application.datasource#">
SELECT 	Program_Fixed_Component.*, Program_Fixed_Component_Name.Program_Fixed_Component_Name, Program_Fixed_Component_Name.External_ID
FROM 	Program_Fixed_Component
		INNER JOIN Program_Fixed_Component_Name
		ON 
		Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID = Program_Fixed_Component.Program_Fixed_Component_Name_ID
WHERE 	Program_ID = '#FORM.Contract_Main_ID#'
		AND Program_Fixed_Component.DELETED = 0
</CFQUERY>
<cfif getAllFixedComponents.Recordcount GT 0>

<style>
	TABLE.Maintable TD	{ font-size : 10px;}
	#header {font-size: 12px;}
</style>

<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset businessSegmentID = businessSegManager.getSegmentIdByProgram(FORM.Contract_Main_ID) />
<cfset bAllowSelectAllProducts = ProductGroupManager.allowSelectAllProducts(3, FORM.Contract_Main_ID) />
<cfparam name="Form.groupLevelProducts" 	default="0">
<cfparam name="Form.Product_Level_1" 	default="">

<table WIDTH="800" style="Maintable" CELLPADDING="3" CELLSPACING="0" BORDER="0">
<tr BGCOLOR="#FFCE84" VALIGN="bottom">
	<td style="border-bottom:solid #93BEE2 1px;">&nbsp; </td>
	<td style="border-bottom:solid #93BEE2 1px;" nowrap ID="header"><strong>Name</strong></td>
	<td style="border-bottom:solid #93BEE2 1px;" nowrap ID="header"><strong>Paid to</strong></td>
	<td style="border-bottom:solid #93BEE2 1px;" id="header"><strong> Products</strong></td>
	<td style="border-bottom:solid #93BEE2 1px;" colspan="5">&nbsp; </td></tr>

<CFOUTPUT QUERY="getAllFixedComponents">
	<cfset thisBAllowSelectAllProducts = bAllowSelectAllProducts />
	<CFQUERY NAME="getFixedProducts" datasource="#application.datasource#">
		SELECT 	Contract_Products.Contract_Products_ID, 
				Contract_Products.Product_Group_Level_ID,
				Contract_Products.Product_Group_ID,
				BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, 
				Program_Fixed_Price_Product_Data.Program_Fixed_Component_ID
		FROM  	Contract_Products 
				INNER JOIN BSA_Foodservice_Items_Master 
				ON Contract_Products.BSA_Foodservice_Items_Master_ID = 
				BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID 
				INNER JOIN Program_Fixed_Price_Product_Data 
				ON Contract_Products.Contract_Products_ID = Program_Fixed_Price_Product_Data.Contract_Products_ID
		WHERE     
				(Program_Fixed_Price_Product_Data.Deleted = 0) 
				AND (Contract_Products.Deleted = 0) 
				AND (Program_Fixed_Price_Product_Data.Program_Fixed_Component_ID = '#getAllFixedComponents.Program_Fixed_Component_ID#')

	</CFQUERY>
	<cfset Form.Product_List = valuelist(getFixedProducts.BSA_Foodservice_Items_Master_ID, ",") />
	
	
  <cfset thisFormname = "FixedForm_"&replace(getAllFixedComponents.Program_Fixed_Component_ID, "-", "_", "ALL")> 
	<cfset fixed_component_id = getAllFixedComponents.Program_Fixed_Component_ID>
	<cfset fixed_component_desc = replace(replace(replace(Trim(getAllFixedComponents.Fixed_Component_Desc), "'", "", "ALL"), '"', '', "ALL"), chr(13)&chr(10), " ", "ALL")>
	<cfset fixed_component_name = replace(replace(getAllFixedComponents.Program_Fixed_Component_Name, "'", "", "ALL"), '"', '', "ALL")>
	<cfset fixed_component_paid_to = getAllFixedComponents.Fixed_Component_Paid_to>
	
	<tr valign="top" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
	<td>&nbsp; </td>
	<!------ external id ----->
	<td nowrap>#Program_Fixed_Component_Name#<cfif application.returned_customer_setting.external_id_on EQ 1><cfif Len(External_ID) GT 0> (#External_ID#)</cfif></cfif>&nbsp; </td>
	<td nowrap><cfif fixed_component_paid_to EQ 1>Distributor
	<cfelseif fixed_component_paid_to EQ 2>Operator</cfif></td>
	<td><cfif getFixedProducts.Product_Group_Level_ID NEQ 0 AND getFixedProducts.Product_Group_Level_ID NEQ "">#ProductGroupManager.getProductGroupProductCount(getFixedProducts.Product_Group_Level_ID, getFixedProducts.Product_Group_ID)#
<cfelse>#getFixedProducts.Recordcount#
</cfif>&nbsp; </td>
	<td nowrap>
	<cf_smallLink
			url="##"
			title="products"
			parameters="STYLE=""cursor:hand;"" ONCLICK=""javaScript: showProductView('#Program_Fixed_Component_ID#');return false;"""
			>
	</td>
	
	<td nowrap>
	<cf_smallLink
			url="##"
			title="edit component"
			parameters="STYLE=""cursor:hand;"" ONCLICK=""javaScript: editComponent('#fixed_component_id#', ',',',',',',','#JSStringFormat(Program_Fixed_Component_Name_ID)#', ',',',',',',','#fixed_component_desc#', ',',',',',',','#fixed_component_paid_to#');return false;""">
	<!------ <span STYLE="color: red;">[</span><A ONCLICK="editComponent('#lump_id#', '#JSStringFormat(Program_Lump_Sum_Name_ID)#', '#lump_desc#', '#lump_amt#', '#lump_vol#', #evaluate("getAllLumpSums.currentrow-1")#)" STYLE="cursor: hand;">edit component</A><span STYLE="color: red;">]</span> ----->
	</td>
	<td VALIGN="middle"><A STYLE="cursor: hand;" ONCLICK="deleteComponent('#getAllFixedComponents.Program_Fixed_Component_ID#', '#JSStringFormat(Program_Fixed_Component_Name)#')"><img src="../../Images/scissor.gif" alt="remove this component" border="0"></A></td>
	
	</tr>
	<tr style="border-bottom:solid ##93BEE2 1px;" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#"><td style="border-bottom:solid ##93BEE2 1px;">&nbsp; </td><td colspan="9" style="border-bottom:solid ##93BEE2 1px;"><em>#fixed_component_desc#</em>&nbsp; </td></tr>
	<!--- <FORM ACTION="Contract_Discount_Lump_Sums_Save_Products.cfm" METHOD="post" NAME="#thisFormname#" ID="#thisFormname#" ONSUBMIT="alert();">
		<INPUT TYPE="Hidden" NAME="Sort_By" VALUE="#URL.Sort_By#">
		<INPUT TYPE="Hidden" NAME="Program_ID" VALUE="#URL.CID#">
		<INPUT TYPE="hidden" NAME="Program_Fixed_Component_ID" ID="Program_Fixed_Component_ID" VALUE="#getAllFixedComponents.Program_Fixed_Component_ID#">
		<INPUT TYPE="hidden" NAME="ExistingProductList" VALUE="#Form.Product_List#">
		<INPUT TYPE="hidden" NAME="Product_List" VALUE="">
		<INPUT TYPE="Hidden" NAME="DTPS_On" 						VALUE="1">
		<INPUT TYPE="Hidden" NAME="DTPS_Program_ID" 				VALUE="#FORM.Contract_Main_ID#">
	</FORM> --->
</CFOUTPUT>
</table>
	
	<cfoutput><FORM ACTION="Contract_Discount_Fixed_Component_Delete.cfm" METHOD="post" NAME="comDeleteForm" ID="comDeleteForm">
	<input TYPE="Hidden" NAME="Component_ID" VALUE="">
	<INPUT TYPE="Hidden" NAME="Program_ID" VALUE="#URL.CID#">
</FORM>		</cfoutput>
</cfif>
</BLOCKQUOTE></BLOCKQUOTE>
<cfif application.programlayout EQ 1></div></cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>
