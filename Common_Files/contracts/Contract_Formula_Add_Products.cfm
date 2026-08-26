<CFPARAM NAME="FORM.Rule_ID" 	DEFAULT="">

<CFPARAM NAME="FORM.CID" 	DEFAULT="">
<CFPARAM NAME="URL.CID" 	DEFAULT="#FORM.CID#">
<CFPARAM name="form.navigate" default="0">
<CFPARAM name="form.stopnavigate" default="0">


<CF_cryp type="de" key="#request.key#" string="#URL.CID#">

<cfparam name="Form.Sort_By" 	default="Item">
<cfparam name="URL.Sort_By" 	default="#Form.Sort_By#">

<CFPARAM NAME="FORM.New_Formula_Pricing_Rule_ID" 	DEFAULT="">

<CFSET PAGE_TITLE="Formula pricing Rule : Add products">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

	<SCRIPT>
			function showProductSearchWindow() {
				NewWindow("product_Select_V1.cfm?Formname=MyForm&Discountype=5", "productwindow", 800, 600, "yes", "yes")
			}
	</SCRIPT>
</HEAD>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" <cfif appSettings.getAllowNavigate()>onbeforeunload="verifyNavigate();"</cfif>>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/script/javascript/string_functions.js">
</SCRIPT>

<CFIF len(URL.CID) EQ 0>
	<CFSET temp = 0>
<CFELSE>
	<CFSEt temp = cryp.value>
</CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "formula"> 
<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>

<cfif application.programlayout EQ 1>
<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
  <CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
<cfelse>
<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
</cfif>
<BLOCKQUOTE><BLOCKQUOTE>
<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 60px; top: 0px;"></cfif>


<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Added by Deepa 
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<CFSET Rule_ID=FORM.Rule_ID>
<CFIF NOT isDefined("FORM.Product_List")>	
	<CFIF Len(Rule_ID) GT 0>
		<CFQUERY NAME="Get_Active_Products" datasource="#application.datasource#">
			SELECT	cp.BSA_Foodservice_Items_Master_ID
			FROM	Program_Formula_Pricing_Rule_Products fp,  Contract_Products cp
			WHERE	fp.Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
			AND		fp.Program_ID = '#cryp.value#'
			AND		cp.Contract_Products_ID = fp.Contract_Product_ID
			AND		cp.Deleted = 0
			AND		fp.Active = 1
			AND		fp.Deleted = 0	
		</CFQUERY>
		
		<CFIF Get_Active_Products.recordCount GT 0>
			<CFSET FORM.Product_List=ValueList(Get_Active_Products.BSA_Foodservice_Items_Master_ID,",")>
		</CFIF>
	</CFIF>
</CFIF>
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Added by Deepa 
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFPARAM NAME="FORM.Product_List" DEFAULT="">
<CFOUTPUT></CFOUTPUT>

	<CFQUERY NAME="Product_List_To_Exclude" datasource="#application.datasource#">
		SELECT	cp.BSA_Foodservice_Items_Master_ID
		FROM	Program_Formula_Pricing_Rule_Products fp,  Contract_Products cp
		WHERE	
				fp.Program_ID = '#cryp.value#'
		AND		cp.Contract_Products_ID = fp.Contract_Product_ID
		AND		cp.Deleted = 0
		AND		fp.Active = 1
		AND		fp.Deleted = 0
		<CFIF Len(Rule_ID) GT 0>
		AND		fp.Program_Formula_Pricing_Rule_ID <> '#Rule_ID#'
		</cfif>
	</CFQUERY>


<CFIF Product_List_To_Exclude.recordCount GT 0>
	<CFSET ProductListToExcludeFromSelecting=ValueList(Product_List_To_Exclude.BSA_Foodservice_Items_Master_ID)>
</CFIF>


<cfparam name="ProductListToExcludeFromSelecting" 	default="">

<cfinclude template="minimal_contract_info.cfm">
	<CFSET Get_Products = QueryNew("BSA_Foodservice_Items_Master_ID")>
	<CFIF listlen(FORM.Product_List) GT 0>

<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->



<CFSET sql_Sort_By="dbo.BSA_Foodservice_Items_Master.Item">
<CFSWITCH expression="#URL.sort_by#">
	<CFCASE value="Type Code">
		<CFSET sql_Sort_By="dbo.Type_Code_Desc.Type_Code_Desc">
	</CFCASE>
	<CFCASE value="Brand">
		<CFSET sql_Sort_By="dbo.Brand.Brand_Name">
	</CFCASE>
	<CFCASE value="Item">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Items_Master.Item">
	</CFCASE>
	<CFCASE value="UPC">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Items_Master.UPC">
	</CFCASE>
	<CFCASE value="Description">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Items_Master.Description">
	</CFCASE>
</CFSWITCH>



<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->
		
		<CFQUERY NAME="Get_Products" datasource="#application.datasource#">
			SELECT     		Type_Code_Desc.Type_Code_Desc, 
							Brand.Brand, 
							BSA_Foodservice_Items_Master.Item, 
							BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
			                BSA_Foodservice_Items_Master.UPC, 
							BSA_Foodservice_Items_Master.Description, 
							Brand.Brand_Name,
							<!------Program_Formula_Pricing_Rule_Products.Weekly_Volume,----->
							Program_Formula_Pricing_Rule_Products.Product_Overage,
							Program_Formula_Pricing_Rule_Products.Unit_Of_Measure_ID,
							Contract_Products.Contract_Products_ID
			FROM         	
							BSA_Foodservice_Items_Master 
							INNER JOIN Type_Code_Desc 
							ON 
							BSA_Foodservice_Items_Master.Type_Code_Desc_ID = Type_Code_Desc.Type_Code_Desc_ID 
							INNER JOIN Brand 
							ON 
							BSA_Foodservice_Items_Master.Brand_ID = Brand.Brand_ID
							LEFT JOIN Contract_Products
							ON
							Contract_Products.Contract_Main_ID = #cryp.value#
							AND
							Contract_Products.Product_Type_ID = 5
							AND
							Contract_Products.Deleted = 0
							AND
							Contract_Products.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID							
							LEFT JOIN	Program_Formula_Pricing_Rule_Products
							ON
							Program_Formula_Pricing_Rule_Products.Contract_Product_ID = Contract_Products.Contract_Products_ID
							AND
							Program_Formula_Pricing_Rule_Products.Deleted = 0
							AND
							Program_Formula_Pricing_Rule_Products.Active = 1
			WHERE
				1 = 2
			<CFIF Len(FORM.Product_List) GT 0>
				OR
				BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
				IN (#ListQualify(FORM.Product_List, "'", ",")#)
			</CFIF>
			--ORDER BY 	description
			ORDER BY #sql_Sort_By#
		</CFQUERY>
		<CFSET FORM.Product_List = ValueList(Get_Products.BSA_Foodservice_Items_Master_ID, ",")>
	</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px; font-weight: bold;}
</style>
<FORM ACTION="Contract_Formula_Add_Products.cfm" METHOD="post" NAME="MyForm" ID="MyForm" STYLE="DISPLAY:INLINE;">

<CFSAVECONTENT VARIABLE="UOM_SELECT_CODE">
			<cf_uom_dropdown
				company_main_id			=	""
				default_option_on		=	""
				default_option_text		=	""
				default_option_value	=	""
				dropdown_name			=	"MY_UOM_SELECT_CODE"
				option_text_abbreviated	=	""
				plural_uom_display		=	""
				product_type_id			=	"5"
				program_template_id		=	""
				selected_uom_id			=	""
				text_before_tag_close	=	"SCRIPT_HERE"
				uom_id_exclusion_list	=	"1"
				uom_id_inclusion_list	=	""
				generic_type_restriction=	"false"
				program_id				=	"#CSL_Contract_Main_ID#"
			>
			</CFSAVECONTENT>	
<cfif Get_Products.Recordcount LT 1>

<strong>Select products</strong>
<p>
<CF_button
				button_name		=	""
				button_caption	=	"select products"
				button_action	=	"showProductSearchWindow();"
				button_type		=	"javascript_link"
				button_width	=	"125"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
</cfif>

<cfif Get_Products.Recordcount GT 0>
	<CFIF CSLGetContractInfo.Formula_Price_Rebate_Type EQ 0>
		<CFSET CSLGetContractInfo.Formula_Price_Rebate_Type = 1>
	</CFIF>
	
	
<!------
<CFQUERY NAME="GetAllContractInfo" datasource="#application.datasource#">
SELECT		Contract_Daily_Volume, Unit_Of_Measure_Desc
FROM		dbo.Contract_Main INNER JOIN
			dbo.Units_of_Measure 
				ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID
	WHERE Contract_Main_ID = #FORM.Contract_Main_ID#
</CFQUERY>
<CFSET Weekly_Volume = GetAllContractInfo.Contract_Daily_Volume * 7>
----->
<TABLE WIDTH="800" BORDER="0" CELLPADDING="2" CELLSPACING="0">
	<TR>
		<cfif appSettings.getPaymentCycleAtDiscountType()>
		<TD width="15%" STYLE="border-bottom:2px solid navy;">
		<span id="error_PaymentCycle"></span>&nbsp;<B>Payment Cycle:</B>
		</TD>
		<TD width="20%" STYLE="border-bottom:2px solid navy;">
		<cfparam name="FORM.PaymentCycle" 	default="">
		<cf_payment_cycle_selection
			Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
			Program_ID = "#FORM.Contract_Main_ID#"
			discount_Type_ID = "5"
			Selected_Payment_Cycle_ID = "#FORM.PaymentCycle#"
			>
		
		</TD>
		</cfif>
		<TD NOWRAP STYLE="border-bottom:2px solid navy;"><CF_SmallHelp>You may choose to apply the same overage to all the items. Specify the overage and click apply.</CF_SmallHelp>&nbsp;&nbsp;&nbsp;&nbsp;
			<FONT SIZE="2">
			Overage: <INPUT TYPE="Text" NAME="Overage_Amount" SIZE="3" ONKEYUP="clenseText(this, '.-0123456789'); threeDecimalPlaces(this);" onblur="threeDecimalPlaces(this)">
			<FONT COLOR="Red">[ </B></FONT><A ONCLICK="ApplyAmountToSelectedBoxes(document.all.Overage_Amount.value)" STYLE="cursor: pointer;">apply overage</A><FONT COLOR="Red"><B> ]</B></FONT>
		</TD>
	</TR>	
</table>
	
	<SCRIPT LANGUAGE="JavaScript">
		function sort_by_This(thisVal)
		{
			document.MyForm.Sort_By.value = thisVal;
			document.MyForm.submit();
			return false;
		}
		
		function overage_keyup(thisObj, uom_select_name)
		{
			var uom_Select = eval("document.all." + uom_select_name);
			var char_Restriction = ".-0123456789";
			if(uom_Select.value == 3)
			{
				char_Restriction = "0123456789";
			}

			clenseText(thisObj, char_Restriction);
			if(uom_Select.value == 3)
			{
				var tValue = thisObj.value;
				if(tValue.length > 0)
				{
					tValue = parseInt(tValue);
					if(isNaN(tValue))
					{
						tValue = 1;
					}
					if(tValue < 1)
					{
						tValue = 1;
					}
					if(tValue > 99)
					{
						tValue = 99;
					}
					thisObj.value = tValue;
				}
			}
		}
		function overage_blur(thisObj, uom_select_name)
		{
			var uom_Select = eval("document.all." + uom_select_name);
			if(uom_Select.value != 3)
			{
				threeDecimalPlaces(thisObj);
			}
		}
	</SCRIPT>
	
<TABLE WIDTH="800">
	<TR>
		<TD>
			<CF_button
				button_name		=	"save"
				button_caption	=	"Save"
				button_action	=	"submitForm();"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>		
		</TD>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"select products"
				button_action	=	"showProductSearchWindow();"
				button_type		=	"javascript_link"
				button_width	=	"125"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</TD>
		<TD>
		<CF_SmallHelp width="400">You may specify the overage for each item here. Click on the save button when you are done.</CF_SmallHelp>
		</TD>
		<TD align="Center">
		<CFOUTPUT>
		<cfif application.returned_customer_setting.show_delivered EQ 1>
		<FIELDSET STYLE="padding:none; width: 200px; border: 1px solid Blue;">
		<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Rate Type:</LEGEND>
		<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="left">
			<TR>
				<TD><INPUT NAME="Formula_Price_Rebate_Type" TYPE="Radio" VALUE="1" onchange="resetnavigate();" <CFIF CSLGetContractInfo.Formula_Price_Rebate_Type EQ 1> CHECKED</CFIF>></TD>
				<TD>Delivered</TD>
				<TD><INPUT NAME="Formula_Price_Rebate_Type" TYPE="Radio" VALUE="2" onchange="resetnavigate();" <CFIF CSLGetContractInfo.Formula_Price_Rebate_Type EQ 2> CHECKED</CFIF>></TD>
				<TD>FOB</TD>
			</TR>
		</TABLE>
		</FIELDSET><BR><BR>
		<cfelse>
			<INPUT NAME="Formula_Price_Rebate_Type" TYPE="Hidden" VALUE="2">
		</cfif>
				
	</CFOUTPUT>
		</TD>
		<td align="right"><font style="font-weight:bold; font-size:11px;">Global UOM:</font>

			<CFOUTPUT>#ReplaceNoCase(ReplaceNoCase(UOM_SELECT_CODE, "MY_UOM_SELECT_CODE", "Global_UOM"), "SCRIPT_HERE", " STYLE=""WIDTH:70px""")#</CFOUTPUT>
	<span onClick="javaScript: uom_select_All(document.all.Global_UOM);"><font style="color:red;font-weight:bold;">[</font><font color="##0000ff" style="cursor:pointer;">apply</font><font style="color:red;font-weight:bold;">]</font></span></td>
	</TR>	
</TABLE>

<span id="product_1"></span>&nbsp;
<!--- <DIV ID="productSummaryDisplay" STYLE="width: 700; overflow-y: auto; overflow-x: hidden; height: 200px; border: 1px solid Black;"> --->
<span STYLE="color: blue; font-weight: bold;">*Click on the Column Headers to sort the records</span>
<CFOUTPUT>#RepeatString("&nbsp;", 114)#</CFOUTPUT>

	<TABLE CLASS="Maintable" WIDTH="800" CELLPADDING="0" CELLSPACING="0" border="0">
		<TR BGCOLOR="FFCE84">		
			<td><img bDelete="true" sMessage="delete all products in this page" src="/images/scissor.gif" alt="delete all products in this page" border="0" onclick="deleteAll('CH_')" style="cursor: pointer;"></td>
			<TD ID="header">&nbsp;</TD>
			<TD ID="header"><A HREF="#" OnClick="JavaScript:sort_by_This('Item');"><cfoutput>#application.returned_customer_setting.item_label#</cfoutput></A></TD>
			<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD ID="header"><A HREF="#" OnClick="JavaScript: return sort_by_This('UPC');"><cfoutput>#application.returned_customer_setting.upc_label#</cfoutput></A></TD></cfif></cfif>
			<TD ID="header"><A HREF="#" OnClick="JavaScript: return sort_by_This('Description');">Description</A></TD>
			<TD ID="header" WIDTH="100">Overage</TD>
			<TD ID="header">UOM</TD>
			<TD><input TYPE="checkbox" NAME="checkAll" onCLick="javaScript:check_All(this);" checked></TD>
		</TR>

			<SCRIPT>
				var FormattedFormElementName = new Array();
			</SCRIPT>
			<CFOUTPUT QUERY="Get_Products">
			<CFSET ThisProductIDFormattedForHTMLFormElementName = Replace(Get_Products.BSA_Foodservice_Items_Master_ID,"-","_", "ALL")>
				<CFSET ThisProductsID = Get_Products.BSA_Foodservice_Items_Master_ID>
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" ONMOUSEOVER="menuID=6;URLstring='';an_ID='#ThisProductsID#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;" height="30" ID="TR_Products" PRODUCT_ID_RE="#ThisProductIDFormattedForHTMLFormElementName#" bDelete="0">
					<TD><img bDelete="true" name="IMG_Delete_Scissor" src="/images/scissor.gif" alt="click here to delete this product" border="0" onclick="deleteThisFixedPrice('#ThisProductIDFormattedForHTMLFormElementName#', '#ThisProductsID#')" style="cursor: pointer;"></TD>
					<TD ID="header">&nbsp;</TD>
					<TD>#trim(Item)#&nbsp;</TD>
					<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD>#UPC#&nbsp;</TD></cfif></cfif>
					<TD>#trim(Description)#&nbsp;</TD>
					<CFPARAM NAME="FORM.Overage_LB_#ThisProductIDFormattedForHTMLFormElementName#" 	DEFAULT="#Get_Products.Product_Overage#">
					<CFPARAM NAME="FORM.Overage_UOM_#ThisProductIDFormattedForHTMLFormElementName#" 	DEFAULT="#Get_Products.Unit_Of_Measure_ID#">
					<CFSET This_Overage = Evaluate("FORM.Overage_LB_#ThisProductIDFormattedForHTMLFormElementName#")>
					<CFSET This_Overage_UOM = Evaluate("FORM.Overage_UOM_#ThisProductIDFormattedForHTMLFormElementName#")>
					<CFIF len(This_Overage) EQ "">
						<CFSET This_Overage = 0>
					</CFIF>					
					<TD><input TYPE="text" NAME="Overage_LB_#ThisProductIDFormattedForHTMLFormElementName#" size="5" VALUE="<CFIF This_Overage_UOM EQ 3>#trim(numberformat(This_Overage, '__'))#<CFELSE>#trim(numberformat(This_Overage, '__.____'))#</CFIF>"  ONKEYUP="overage_keyup(this, 'Overage_UOM_#ThisProductIDFormattedForHTMLFormElementName#')" onblur="overage_blur(this, 'Overage_UOM_#ThisProductIDFormattedForHTMLFormElementName#')" onchange="resetnavigate();"><span id="Er_Overage_LB_#ThisProductIDFormattedForHTMLFormElementName#"></span>
					</TD>
					<TD>
					<CFSET THIS_UOM_SELECT_STR = ReplaceNoCase(ReplaceNoCase(UOM_SELECT_CODE, "MY_UOM_SELECT_CODE", "Overage_UOM_#ThisProductIDFormattedForHTMLFormElementName#"), "SCRIPT_HERE", " onchange=""resetnavigate();""   STYLE=""WIDTH:70px""")>
					<CFSET THIS_UOM_SELECT_STR = ReReplaceNoCase(THIS_UOM_SELECT_STR, "<option value=""#This_Overage_UOM#"" >(.*?)</option>", "<option value=""#This_Overage_UOM#"" selected>\1</option>")>
					#THIS_UOM_SELECT_STR#
					</TD>
					<SCRIPT>
					FormattedFormElementName[FormattedFormElementName.length] = "#ThisProductIDFormattedForHTMLFormElementName#";
					</SCRIPT>					
					<TD><input TYPE="checkbox" NAME="CH_#ThisProductIDFormattedForHTMLFormElementName#" checked></TD>
				</TR>
			</CFOUTPUT>
		<!--- </CFIF> --->
	</TABLE>
		
<!--- </div> --->		
<BR>
<TABLE>
	<TR>
		<TD>
			<CF_button
				button_name		=	"save"
				button_caption	=	"Save"
				button_action	=	"submitForm();"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>		
		</TD>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"select products"
				button_action	=	"showProductSearchWindow();"
				button_type		=	"javascript_link"
				button_width	=	"125"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</TD>
	</TR>
</TABLE>
<cf_MessageWindow>


<cfparam name="Min_Formula_Percent" default="">
<cfparam name="Max_Formula_Percent" default="">
<cfparam name="Min_Formula_Pound" default="">
<cfparam name="Max_Formula_Pound" default="">
<cfparam name="ThereisMinorMax" default="0">

<!---Sets min and max values if they exist for the profile--->
<cfif len(trim(getSettings.Min_Formula_Percent)) IS NOT 0>
	<cfset Min_Formula_Percent = getSettings.Min_Formula_Percent>
	<cfset ThereisMinorMax = 1>
</cfif>
<cfif len(trim(getSettings.Max_Formula_Percent)) IS NOT 0>
	<cfset Max_Formula_Percent = getSettings.Max_Formula_Percent>
	<cfset ThereisMinorMax = 1>
</cfif>
<cfif len(trim(getSettings.Min_Formula_Pound)) IS NOT 0>
	<cfset Min_Formula_Pound = getSettings.Min_Formula_Pound>
	<cfset ThereisMinorMax = 1>
</cfif>
<cfif len(trim(getSettings.Max_Formula_Pound)) IS NOT 0>
	<cfset Max_Formula_Pound = getSettings.Max_Formula_Pound>
	<cfset ThereisMinorMax = 1>
</cfif>

<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/Queue.js"></SCRIPT>

<SCRIPT LANGUAGE="JavaSCript">
	var my_queue = new Queue();	
</SCRIPT>
<SCRIPT>
	
	function threeDecimalPlaces(textObject){		
		if(event.type == "keyup") {
			
			if(textObject.value.indexOf(".") != -1) {
				if(textObject.value.length - textObject.value.indexOf(".") >= 4) {
					var validNumber = new NumberFormat();
					validNumber.setCommas(false);
					validNumber.setCurrency(false);
					validNumber.setPlaces(4);		
					validNumber.setNumber(textObject.value);
					textObject.value = validNumber.toFormatted();
				}
			}
		}
		
		if(event.type == "blur") {
			var validNumber = new NumberFormat();
			validNumber.setCommas(false);
			validNumber.setCurrency(false);
			validNumber.setPlaces(4);		
			validNumber.setNumber(textObject.value);
			textObject.value = validNumber.toFormatted();			
		}
	}
	
	var ErrorCount = 0;
	var TotalWeeklyVolume = 0;
	function check_This_Product(trObj)
	{
		var this_prod_id_re = trObj.PRODUCT_ID_RE;
		var bDelete = 1;
		if(trObj.bDelete != "undefined")
		{
			bDelete = trObj.bDelete;
		}
		
		if(this_prod_id_re && bDelete == 0)
		{
			var thisObj;
			var errObj;
			<!----
/*
			thisObj = eval("document.all.WEEKLYVOLUME_" + this_prod_id_re);
			errObj = eval("document.all.Er_" + this_prod_id_re);
			if(!isInt(thisObj.value))
			{
				ErrorCount++;	
				queueMessage("Invalid Weekly Volume", errObj);
			}
			else
			{
				TotalWeeklyVolume = TotalWeeklyVolume + parseInt(thisObj.value);
				clearQueue(errObj);
			}
			*/
---->
			thisObj = eval("document.all.Overage_LB_" + this_prod_id_re);
			thisObjUOM = eval("document.all.Overage_UOM_" + this_prod_id_re);
			errObj = eval("document.all.Er_Overage_LB_" + this_prod_id_re);

			if(!isFloat(thisObj.value,false) && thisObj.value.length > 0)
			{
				ErrorCount++;	
				queueMessage("Invalid Rate", errObj);
			}
			
			<cfif ThereisMinorMax IS 1>
				<!---Pounds first--->
				else if((thisObjUOM.value == 2) && (thisObj.value != ""))
				{
					<Cfif len(trim(Min_Formula_Pound)) IS NOT 0>
					<!---Pounds Min--->
					if(thisObj.value < <cfoutput>#Min_Formula_Pound#</cfoutput>)
					{
						ErrorCount++
						queueMessage("The price must be greater than <cfoutput>#Min_Formula_Pound#</cfoutput>", errObj)
					}
					</CFIF>
					
					<Cfif len(trim(Max_Formula_Pound)) IS NOT 0 AND Max_Formula_Pound IS NOT 0>
					<!---Pounds Max--->
					if(thisObj.value > <cfoutput>#Max_Formula_Pound#</cfoutput>)
					{
						ErrorCount++
						queueMessage("The price must be less than <cfoutput>#Max_Formula_Pound#</cfoutput>", errObj)
					}
					</cfif>
				
				}
				
				<!---Percent--->
				else if((thisObjUOM.value == 3) && (thisObj.value != ""))
				{
					<Cfif len(trim(Min_Formula_Percent)) IS NOT 0>
					<!---Pounds Min--->
					if(thisObj.value < <cfoutput>#Min_Formula_Percent#</cfoutput>)
					{
						ErrorCount++
						queueMessage("The price must be greater than <cfoutput>#Min_Formula_Percent#</cfoutput>", errObj)
					}
					</cfif>
					
					<Cfif len(trim(Max_Formula_Percent)) IS NOT 0 AND Max_Formula_Percent IS NOT 0>
					<!---Pounds Max--->
					if(thisObj.value > <cfoutput>#Max_Formula_Percent#</cfoutput>)
					{
						ErrorCount++
						queueMessage("The price must be less than <cfoutput>#Max_Formula_Percent#</cfoutput>", errObj)
					}
					</cfif>
				
				}
				
				</cfif>
			
			
			
			else
			{
				clearQueue(errObj);
			}
		}
	}
	
	function submitForm(){
		ErrorCount = 0;
		if(document.all.MyForm.Abs_Final_Product_List.value.length == 0){
			ErrorCount++;			
			queueMessage("You haven't selected any products", document.all.product_1);
		}		
		else 
		{
			clearQueue(document.all.product_1);
		}
		TotalWeeklyVolume = 0;
		
		var tr_Products_obj = document.all.TR_Products;
		
		var k, this_prod_id_re;
		
		
		if(tr_Products_obj.length)
		{
			for(var x=0;x<tr_Products_obj.length;x++)
			{
				check_This_Product(tr_Products_obj[x]);
			}
		}
		else
		{
			check_This_Product(tr_Products_obj);
		}
		/*
		for(k=0;k<prod_list_len;k++)
		{
			this_prod_id_re = arrProd[k].replace(/-/ig,"_");
			check_This_Product(this_prod_id_re);			
		}
		*/
		
		<cfif appSettings.getPaymentCycleAtDiscountType()>
		<!------ check for payment cycle ----->
		if(document.all.PaymentCycle.value == "0")
		{
			queueMessage("Select a payment cycle", document.all.Err_Sp_PaymentCycle)
			ErrorCount++
		}
		else
		{
			clearQueue(document.all.Err_Sp_PaymentCycle)
		}
		</cfif>
		
		if(ErrorCount == 0){
		<!----
/*
			<CFSET Weekly_Volume = GetAllContractInfo.Contract_Daily_Volume * 7>
			if(TotalWeeklyVolume != <CFOUTPUT>#trim(numberformat(Weekly_Volume, '___________________________________'))#</CFOUTPUT>) {
				if(confirm("The weekly volume you have entered(" + TotalWeeklyVolume + " <CFOUTPUT>#GetAllContractInfo.Unit_Of_Measure_Desc#</CFOUTPUT>) does not match the calculated weekly volume for the program (<CFOUTPUT>#trim(numberformat(Weekly_Volume, '___,___,___,___,___'))# #GetAllContractInfo.Unit_Of_Measure_Desc#</CFOUTPUT>).")){
					document.MyForm.action = "Contract_Formula_Add_Products_Action.cfm";
					document.MyForm.submit();
				}
			}
			else{
				document.MyForm.action = "Contract_Formula_Add_Products_Action.cfm";
				document.MyForm.submit();
			}
			*/
---->
			document.MyForm.action = "Contract_Formula_Add_Products_Action.cfm";
			document.all.navigate.value = 0;
			disableButton("save_table", true, false);
			document.MyForm.submit();
		}
		else{
			showMessageWindow()
			document.all.navigate.value = 1;
			return false;
		}
		
	}
	
	function isInt(sVal)
	{	
		var sValTemp = parseInt(sVal);
		if((!isNaN(sValTemp) && sValTemp+"" == sVal))
			return true;
		else
			return false;
	}
	
	
	function isFloat(sVal,noMinus)
	{		
		var sValTemp = parseFloat(sVal);
		
		if(!isNaN(sValTemp) && (/^[+-]?\d*(\.(\d)+)?$/.test(sVal)))
		{
			if(noMinus) return /^\d*(\.(\d)+)?$/.test(sVal);
			return true;
		}
		else
		{
			return false;
		}
		
	}
	
	function uom_select_All(thisObj)
	{
		var selIndex = thisObj.selectedIndex;
		var eachSelObj;
		var FormattedFormElementNameLen = FormattedFormElementName.length;
		for(var i=0;i<FormattedFormElementNameLen;i++)
		{
			eval("eachSelObj = document.all.Overage_UOM_" + FormattedFormElementName[i] + ";");
			if(eachSelObj.options.length > selIndex)
			{
				eachSelObj.selectedIndex = selIndex;
				resetnavigate();
			}
		}
		
	}

	function check_All(thisObj)
	{
		document.all.checkAll.checked = event.srcElement.checked
		var thisChObj;
		var FormattedFormElementNameLen = FormattedFormElementName.length;
		for(var i=0;i<FormattedFormElementNameLen;i++)
		{
			thisChObj = eval("document.all.CH_" + FormattedFormElementName[i]);
			if(thisChObj)
			{
				thisChObj.checked=thisObj.checked;
			}			
		}
		
	}

	function applyGlobalVolume(volumeToApply){
		var FormattedFormElementNameLen = FormattedFormElementName.length;
		for(var i=0;i<FormattedFormElementNameLen;i++)
		{
			if(eval("document.all.CH_" + FormattedFormElementName[i] + ".checked"))
			{
				eval("document.all.WEEKLYVOLUME_" + FormattedFormElementName[i] + ".value=volumeToApply");
				resetnavigate();
			}
		}
	}
	
	function ApplyAmountToSelectedBoxes(fAmount)
	{
		var FormattedFormElementNameLen = FormattedFormElementName.length;
		for(var i=0;i<FormattedFormElementNameLen;i++)
		{
			if(eval("document.all.CH_" + FormattedFormElementName[i] + ".checked"))
			{
				eval("document.all.Overage_LB_" + FormattedFormElementName[i] + ".value=fAmount");
			resetnavigate();
			}
		}
	}
	
	
	function deleteThisFixedPrice(FieldNameRe, prodID)
	{	
		var srcObj = event.srcElement;
		//var trObj = document.getElementById("TR_" + FieldNameRe);
		var trObj = getParentObject(srcObj, "tr");
		var trIndex = trObj.rowIndex;
		var FINALITEMLIST = document.MyForm.Product_List.value;
		var resultString = ListDeleteItem(FINALITEMLIST, ",", prodID);
		var bDelete = true;
				
		if(resultString == FINALITEMLIST)
		{
			resultString = ListAppendItem(FINALITEMLIST, ",", prodID);
			bDelete = false;
		}
		
		document.MyForm.Product_List.value = resultString;
		document.MyForm.Abs_Final_Product_List.value = resultString;
		document.MyForm.ExistingProductList.value = resultString;		
	
		var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";
		if(trObj)
		{			
			if(bDelete)
			{ 
				my_queue.addObjValueToQueue(prodID + "_Overage", "document.all.Overage_LB_" + FieldNameRe);
				my_queue.addObjValueToQueue(prodID + "_Overage_UOM", "document.all.Overage_UOM_" + FieldNameRe);
				
				//trObj.cells[0].innerHTML = empty_String;
				trObj.cells[trObj.cells.length - 1].innerHTML = empty_String;
	
				trObj.cells[5].innerHTML = empty_String;
				disableDiv(trObj.cells[6], true, false);
				
				propogateProperty(trObj, "style.backgroundColor", "#DDDDDD", false);
				propogateProperty(trObj, "style.textDecoration", "line-through", true);
				
				srcObj.alt = "undo product deletion";
				srcObj.src = undodeleteImg.src;
				resetnavigate();
			
			}
			else
			{
				//trObj.cells[0].innerHTML = "<input TYPE=\"checkbox\" NAME=\"CH_" + FieldNameRe + "\" checked>";
				trObj.cells[trObj.cells.length - 1].innerHTML = "<input TYPE=\"checkbox\" NAME=\"CH_" + FieldNameRe + "\" checked>";				
				
				trObj.cells[5].innerHTML = "<input TYPE=\"text\" NAME=\"Overage_LB_" + FieldNameRe + "\" size=\"5\" VALUE=\"\"  ONKEYUP=\"overage_keyup(this, 'Overage_UOM_" + FieldNameRe + "')\" onblur=\"overage_blur(this, 'Overage_UOM_" + FieldNameRe + "')\"><span id=\"Er_Overage_LB_" + FieldNameRe + "\"></span>";
				disableDiv(trObj.cells[6], false, false);
				
				var bgCol = "#FFFFFF";
				if(trObj.rowIndex % 2 != 1)
				{
					bgCol = "#C6FFC6";
				}
				propogateProperty(trObj, "style.backgroundColor", bgCol, false);
				propogateProperty(trObj, "style.textDecoration", "none", false);
				
				propogateProperty(trObj, "style.backgroundColor", "FFFFFF", false, true);
				
				srcObj.alt = "delete this product";
				srcObj.src = deleteImg.src;
				
				my_queue.deleteAndSetObjValueFromQueue(prodID + "_Overage", "document.all.Overage_LB_" + FieldNameRe);
				my_queue.deleteAndSetObjValueFromQueue(prodID + "_Overage_UOM", "document.all.Overage_UOM_" + FieldNameRe);
			}
			srcObj.bDelete = !bDelete;
			trObj.bDelete = (bDelete?1:0);
		}		
	}
	
	function resetnavigate()
		{
			document.all.navigate.value = 1;
		}
		function verifyNavigate() {
			if (document.all.navigate.value == 1 && document.all.stopnavigate.value == 0) {
				{
					event.returnValue='Product selections you have not saved will be lost.'
			}
		}	
	}

</SCRIPT>

</cfif>
<CFOUTPUT>
		<INPUT TYPE="Hidden" NAME="CID" VALUE="#URL.CID#">
	 	<INPUT TYPE="Hidden" NAME="Abs_Final_Product_List" VALUE="#FORM.Product_List#">
		<INPUT TYPE="Hidden" NAME="Rule_ID" VALUE="#Rule_ID#">
		<INPUT TYPE="Hidden" NAME="Sort_By" VALUE="#URL.Sort_By#">
	 	<INPUT TYPE="Hidden" NAME="Product_List" VALUE="#FORM.Product_List#">
		<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="#FORM.Product_List#">		
		<INPUT TYPE="Hidden" NAME="ProductListToExcludeFromSelecting" VALUE="#ProductListToExcludeFromSelecting#">
		<INPUT TYPE="Hidden" NAME="DTPS_On" 			VALUE="1">
		<INPUT TYPE="Hidden" NAME="DTPS_Program_ID" 	VALUE="#FORM.Contract_Main_ID#">
		<INPUT TYPE="Hidden" 	 NAME="New_Formula_Pricing_Rule_ID" VALUE="#FORM.New_Formula_Pricing_Rule_ID#">
<INPUT TYPE="Hidden" NAME="navigate" VALUE="#FORM.navigate#">
<INPUT TYPE="Hidden" NAME="stopnavigate" VALUE="0">
		</CFOUTPUT>
	 </FORM>	
<cfif application.programlayout EQ 1></div></cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>
<!--- delete product section --->
<cfinclude template="delete_product_include.cfm">
<!--- delete product section --->

</BODY>
</HTML>
