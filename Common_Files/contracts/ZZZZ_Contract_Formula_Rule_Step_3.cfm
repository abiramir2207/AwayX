<cfparam name="Form.RID" 	default="">
<cfparam name="URL.RID" 	default="#Form.RID#">

<CF_cryp type="de" key="#request.key#" string="#URL.CID#">

<cfparam name="URL.Update" 	default="0">
<cfparam name="Form.Update" 	default="#URL.Update#">

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

<cfparam name="Form.Sort_By" 	default="Item">
<cfparam name="URL.Sort_By" 	default="#Form.Sort_By#">

<CFSET PAGE_TITLE="Formula pricing Rule : Step 3">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

	<SCRIPT>
			function showProductSearchWindow() {
				NewWindow("product_Select_V1.cfm?Formname=SaveProgramProducts&Discountype=5", "productwindow", 800, 600, "yes", "yes")
			}
	</SCRIPT>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<SCRIPT LANGUAGE="JavaScript" SRC="../../script/javascript/string_functions.js">
<!--- <CFINCLUDE TEMPLATE="../../script/javascript/string_functions.js"> --->
</SCRIPT>

<CFIF len(URL.CID) EQ 0>
	<CFSET temp = 0>
<CFELSE>
	<CFSEt temp = cryp.value>
</CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "formula"> 
<CFSET Help_URL="/help_files/manual/createprogram/page13.cfm##products">
<CFINCLUDE TEMPLATE="contract_status_legend.cfm">

<BLOCKQUOTE><BLOCKQUOTE>

<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Added by Deepa 
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<CF_Cryp type="de" key="#request.key#" string="#URL.RID#" Return="decrypRuleID">
<CFSET Rule_ID=decrypRuleID.value>
<CFIF NOT isDefined("FORM.Newly_Selected_Products")>	
	<CFIF Len(decrypRuleID.value) GT 0>
		<CFQUERY NAME="Get_Active_Products" datasource="#application.datasource#">
			SELECT	cp.BSA_Foodservice_Items_Master_ID
			FROM	Program_Formula_Pricing_Rule_Products fp,  Contract_Products cp
			WHERE	fp.Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
			AND		fp.Program_ID = '#cryp.value#'
			AND		cp.Contract_Products_ID = fp.Contract_Product_ID
			AND		fp.Active = 1
			AND		fp.Deleted = 0	
		</CFQUERY>
		
		<CFIF Get_Active_Products.recordCount GT 0>
			<CFSET FORM.Newly_Selected_Products=ValueList(Get_Active_Products.BSA_Foodservice_Items_Master_ID,",")>
		</CFIF>
	</CFIF>
</CFIF>
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Added by Deepa 
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFPARAM NAME="FORM.Newly_Selected_Products" DEFAULT="">
<CFSET checkField="cp.BSA_Foodservice_Items_Master_ID=">
<CFSET fakeDelims=" OR #checkField#">
<CFOUTPUT></CFOUTPUT>

<CFSET whereClause="#ListChangeDelims(ListQualify(FORM.Newly_Selected_Products, "'", ","), fakeDelims, ",")#">


<CFQUERY NAME="Product_List_To_Exclude" datasource="#application.datasource#">
	SELECT	cp.BSA_Foodservice_Items_Master_ID
	FROM	Program_Formula_Pricing_Rule_Products fp,  Contract_Products cp
	WHERE	
			fp.Program_ID = '#cryp.value#'
	AND		cp.Contract_Products_ID = fp.Contract_Product_ID
	AND		fp.Active = 1
	AND		fp.Deleted = 0
	AND		fp.Program_Formula_Pricing_Rule_ID <> '#Rule_ID#'
	<!----
	<CFIF Len(FORM.Newly_Selected_Products) GT 0>
		AND cp.BSA_Foodservice_Items_Master_ID IN (#ListQualify(FORM.Newly_Selected_Products, "'", ",")#)
	</CFIF>
	--->
</CFQUERY>


<CFIF Product_List_To_Exclude.recordCount GT 0>
	<CFSET ProductListToExcludeFromSelecting=ValueList(Product_List_To_Exclude.BSA_Foodservice_Items_Master_ID)>
</CFIF>


<cfparam name="ProductListToExcludeFromSelecting" 	default="">

<cfinclude template="minimal_contract_info.cfm">
<BR>
	<CFSET Get_Products = QueryNew("BSA_Foodservice_Items_Master_ID")>
	<CFIF listlen(FORM.Newly_Selected_Products) GT 0>

		<CFSET checkField="BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID=">
		<CFSET fakeDelims=" OR #checkField#">
		<CFSET whereClause="#ListChangeDelims(ListQualify(FORM.Newly_Selected_Products, "'", ","), fakeDelims, ",")#">

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
			SELECT     		dbo.Type_Code_Desc.Type_Code_Desc, 
							dbo.Brand.Brand, 
							dbo.BSA_Foodservice_Items_Master.Item, 
							dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
			                dbo.BSA_Foodservice_Items_Master.UPC, 
							dbo.BSA_Foodservice_Items_Master.Description, 
							dbo.Brand.Brand_Name,
							fp.Weekly_Volume,
							fp.Product_Overage
			FROM         	
							(
							dbo.BSA_Foodservice_Items_Master INNER JOIN
			                dbo.Type_Code_Desc 
								ON dbo.BSA_Foodservice_Items_Master.Type_Code_Desc_ID = dbo.Type_Code_Desc.Type_Code_Desc_ID INNER JOIN
			                dbo.Brand 
							ON dbo.BSA_Foodservice_Items_Master.Brand_ID = dbo.Brand.Brand_ID
							)
							LEFT JOIN	
							(
								Program_Formula_Pricing_Rule_Products fp INNER JOIN  Contract_Products cp
								ON	((fp.Program_ID = '#cryp.value#') 
									AND (cp.Contract_Products_ID = fp.Contract_Product_ID)
									AND	(fp.Active = 1)
									AND	(fp.Deleted = 0)
									AND	(cp.Deleted = 0)
									)									
							)
							ON	(cp.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID)
			WHERE
				1 = 2
			<!----<CFIF Len(whereClause) GT 0>
				<CFSET whereClause="#checkField##whereClause#">
  				 OR #PreserveSingleQuotes(whereClause)#
			</CFIF>---->
			<CFIF Len(FORM.Newly_Selected_Products) GT 0>
				OR
				BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
				IN (#ListQualify(FORM.Newly_Selected_Products, "'", ",")#)
			</CFIF>
			--ORDER BY 	description
			ORDER BY #sql_Sort_By#
		</CFQUERY>
	</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px; font-weight: bold;}
</style>
<table>
	<TR>
		<TD WIDTH="700">
			<SPAN STYLE="font-weight:bold;color:Navy;font-size:16px;">Select This Rules Products:</SPAN>
			<HR WIDTH="100%" COLOR="Orange">
		</TD>
	</TR>
</table>

<CFQUERY NAME="GetAllContractInfo" datasource="#application.datasource#">
SELECT		Contract_Daily_Volume, Unit_Of_Measure_Desc
FROM		dbo.Contract_Main INNER JOIN
			dbo.Units_of_Measure 
				ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID
	WHERE Contract_Main_ID = #FORM.Contract_Main_ID#
</CFQUERY>
<CFSET Weekly_Volume = GetAllContractInfo.Contract_Daily_Volume * 7>
<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">To apply the same volume to more than one product:</LEGEND>
		<TABLE WIDTH="100%" BORDER="0" ALIGN="center">
			<TR>
				<TD><FONT SIZE="2"><B>Volume Applicator</B></FONT></TD>
				<TD></TD>
				<TD><FONT SIZE="2"><B>Rate Applicator</B></FONT></TD>
			</TR>
			<TR>
				<TD VALIGN="top">
					<CFIF Get_Products.recordcount GT 0>
						<CFSET AverageVolume = trim(Round(Weekly_Volume / Get_Products.recordcount))>
					<CFELSE>
						<CFSET AverageVolume = 1>
					</CFIF> 
					
					<CFIF AverageVolume EQ 0>
						<CFSET AverageVolume = 1>
					</CFIF>
					<FONT SIZE="2">
					<OL>
						<LI>Enter the volume that you would apply:&nbsp;<input TYPE="Text" SIZE="1" NAME="globalVolume" onKeyUp="clenseText(this, '0123456789');"> <CFOUTPUT>#GetAllContractInfo.Unit_Of_Measure_Desc#</CFOUTPUT></LI>
						<LI>Select [<input TYPE="Checkbox" ID="demoCbox1" ONCLICK="check_All(this)">] the products below and <FONT COLOR="Red"><B>[ </B></FONT><A ONCLICK="applyGlobalVolume(document.all.globalVolume.value)" STYLE="cursor: hand;">click here</A><FONT COLOR="Red"><B> ]</B></FONT></LI>
						<LI>To assign a volume of <CFOUTPUT>#trim(numberformat(AverageVolume, '___,___,___,___,___'))#</CFOUTPUT> <FONT COLOR="Red"><B>[ </B></FONT><A ONCLICK="applyGlobalVolume(<CFOUTPUT>#AverageVolume#</CFOUTPUT>)" STYLE="cursor: hand;">click here</a><FONT COLOR="Red"><B> ]</B></FONT></LI>
					</OL>
					</FONT>
				</TD>
				<TD></TD>
				<TD VALIGN="top">
					<FONT SIZE="2">
					<OL>
						<LI>Enter here the rate that you would like to apply: <INPUT TYPE="Text" NAME="Overage_Amount" SIZE="3" ONKEYUP="clenseText(this, '.-0123456789'); threeDecimalPlaces(this);" onblur="threeDecimalPlaces(this)"></LI>
						<LI>Select [<input TYPE="Checkbox" ID="demoCbox2" ONCLICK="check_All(this)">] the products below and <FONT COLOR="Red"><B>[ </B></FONT><A ONCLICK="ApplyAmountToSelectedBoxes(document.all.Overage_Amount.value)" STYLE="cursor: hand;">click here</A><FONT COLOR="Red"><B> ]</B></FONT></LI>
					</OL>			
					</FONT>
				</TD>	
			</TR>
		</table>
</FIELDSET>		
	<CFOUTPUT>
	

	<!------<CFIF Form.Update EQ 0>
		<!------<FORM ACTION="Contract_Formula_Rule_Step_3_action.cfm?CID=#URL.CID#&RID=#URL.RID#" METHOD="post" NAME="MyForm" ID="MyForm">----->
		<FORM ACTION="Contract_Formula_Rule_Step_4.cfm?CID=#URL.CID#&RID=#URL.RID#" METHOD="post" NAME="MyForm" ID="MyForm">
	<CFELSE>
		<FORM ACTION="Contract_Forumla_Confirm_Step_3.cfm?CID=#URL.CID#&RID=#URL.RID#" METHOD="post" NAME="MyForm" ID="MyForm">
	</CFIF>----->
	<FORM ACTION="Contract_Formula_Rule_Step_3_action.cfm?CID=#URL.CID#&RID=#URL.RID#" METHOD="post" NAME="MyForm" ID="MyForm">
		<cfif application.returned_customer_setting.show_delivered EQ 1>
		<FIELDSET STYLE="padding:10px; width: 200px; border: 1px solid Blue;">
		<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Rate Type:</LEGEND>
		<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="left">
			<TR>
				<TD><INPUT NAME="Formula_Price_Rebate_Type" TYPE="Radio" VALUE="1" <CFIF CSLGetContractInfo.Formula_Price_Rebate_Type EQ 1> CHECKED</CFIF>></TD>
				<TD>Delivered</TD>
				<TD><INPUT NAME="Formula_Price_Rebate_Type" TYPE="Radio" VALUE="2" <CFIF CSLGetContractInfo.Formula_Price_Rebate_Type EQ 2> CHECKED</CFIF>></TD>
				<TD>FOB</TD>
			</TR>
		</TABLE>
		</FIELDSET><BR><BR>
		<cfelse>
			<INPUT NAME="Formula_Price_Rebate_Type" TYPE="Hidden" VALUE="2">
		</cfif>
		
		<INPUT TYPE="Hidden" NAME="CID" VALUE="#URL.CID#">
	 	<INPUT TYPE="Hidden" NAME="Abs_Final_Product_List" VALUE="#Form.Newly_Selected_Products#">
		<INPUT TYPE="Hidden" NAME="Program_Formula_Pricing_Rule_ID" VALUE="#URL.RID#">		
	</CFOUTPUT>
	<SCRIPT LANGUAGE="JavaScript">
		function sort_by_This(thisVal)
		{
			document.SaveProgramProducts.Sort_By.value = thisVal;
			document.SaveProgramProducts.submit();
		}
	</SCRIPT>
	
<TABLE>
	<TR>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"continue"
				button_action	=	"submitForm();"
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
<BR>	
<span id="product_1"></span>&nbsp;
<!--- <DIV ID="productSummaryDisplay" STYLE="width: 700; overflow-y: auto; overflow-x: hidden; height: 200px; border: 1px solid Black;"> --->
<span STYLE="color: blue; font-weight: bold;">*Click on the Column Headers to sort the records</span>
	<TABLE CLASS="Maintable" WIDTH="800" CELLPADDING="0" CELLSPACING="0">
		<TR BGCOLOR="FFCE84">
			<TD><input TYPE="checkbox" NAME="checkAll" onCLick="javaScript:check_All(this);"></TD>
			<TD ID="header">&nbsp;</TD>
			<TD ID="header"><A HREF="#" OnClick="JavaScript:sort_by_This('Item');"><cfoutput>#application.returned_customer_setting.item_label#</cfoutput></A></TD>
			<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD ID="header"><A HREF="#" OnClick="JavaScript:sort_by_This('UPC');"><cfoutput>#application.returned_customer_setting.upc_label#</cfoutput></A></TD></cfif></cfif>
			<TD ID="header"><A HREF="#" OnClick="JavaScript:sort_by_This('Description');">Description</A></TD>
			<TD ID="header"><A HREF="#" OnClick="JavaScript:sort_by_This('Type Code');"><cfoutput>#application.returned_customer_setting.type_code_label_singular#</cfoutput></A></TD>
			<TD ID="header"><A HREF="#" OnClick="JavaScript:sort_by_This('Brand');">Brand</A></TD>
			<TD ID="header">Weekly Volume</TD>
			<TD ID="header">Overage/LB</TD>
		</TR>
		<CFIF Get_Products.recordcount GT 0>
			<SCRIPT>
				var FormattedFormElementName = new Array();
			</SCRIPT>
			<CFOUTPUT QUERY="Get_Products">
				<CFSET ThisProductsID = Get_Products.BSA_Foodservice_Items_Master_ID>
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" ONMOUSEOVER="menuID=6;URLstring='';an_ID='#ThisProductsID#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;">
					<TD>
					<CFSET ThisProductIDFormattedForHTMLFormElementName = Replace(Get_Products.BSA_Foodservice_Items_Master_ID,"-","_", "ALL")>
					<input TYPE="checkbox" NAME="CH_#ThisProductIDFormattedForHTMLFormElementName#"></TD>
					<TD ID="header">&nbsp;</TD>
					<TD>#Item#&nbsp;</TD>
					<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD>#UPC#&nbsp;</TD></cfif></cfif>
					<TD>#Description#&nbsp;</TD>
					<TD>#Type_Code_Desc#&nbsp;</TD>
					<TD>#Brand_Name#&nbsp;</TD>					
					<TD><input TYPE="text" NAME="WEEKLYVOLUME_#ThisProductIDFormattedForHTMLFormElementName#" size="8" VALUE="#Get_Products.Weekly_Volume#" onKeyUp="clenseText(this, '0123456789');">&nbsp;#GetAllContractInfo.Unit_Of_Measure_Desc#<span id="Er_#ThisProductIDFormattedForHTMLFormElementName#"></span></TD>
					<TD><input TYPE="text" NAME="Overage_LB_#ThisProductIDFormattedForHTMLFormElementName#" size="5" VALUE="<CFIF len(Get_Products.Product_Overage) EQ "">#trim(numberformat(0, '__.___'))#<CFELSE>#trim(numberformat(Get_Products.Product_Overage, '__.___'))#</CFIF>"  ONKEYUP="clenseText(this, '.-0123456789'); threeDecimalPlaces(this)" onblur="threeDecimalPlaces(this)"><span id="Er_Overage_LB_#ThisProductIDFormattedForHTMLFormElementName#"></span>
					</TD>
					<SCRIPT>
					FormattedFormElementName[FormattedFormElementName.length] = "#ThisProductIDFormattedForHTMLFormElementName#";
					</SCRIPT>
				</TR>
			</CFOUTPUT>
		</CFIF>
	</TABLE>
	 </FORM>	
<!--- </div> --->		
<BR>
<TABLE>
	<TR>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"continue"
				button_action	=	"submitForm();"
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

<SCRIPT>
	
	function threeDecimalPlaces(textObject){		
		if(event.type == "keyup") {
			
			if(textObject.value.indexOf(".") != -1) {
				if(textObject.value.length - textObject.value.indexOf(".") >= 4) {
					var validNumber = new NumberFormat();
					validNumber.setCommas(false);
					validNumber.setCurrency(false);
					validNumber.setPlaces(3);		
					validNumber.setNumber(textObject.value);
					textObject.value = validNumber.toFormatted();
				}
			}
		}
		
		if(event.type == "blur") {
			var validNumber = new NumberFormat();
			validNumber.setCommas(false);
			validNumber.setCurrency(false);
			validNumber.setPlaces(3);		
			validNumber.setNumber(textObject.value);
			textObject.value = validNumber.toFormatted();			
		}
	}
	
	function submitForm(){
		var ErrorCount = 0;
		if(document.all.MyForm.Abs_Final_Product_List.value.length == 0){
			ErrorCount++;			
			queueMessage("You haven't selected any products", document.all.product_1);
		}		
		else 
		{
			clearQueue(document.all.product_1);
		}
		var TotalWeeklyVolume = 0;
		var thisObj;
		<CFOUTPUT QUERY="Get_Products">
			<CFSET ThisProductIDFormattedForHTMLFormElementName = Replace(Get_Products.BSA_Foodservice_Items_Master_ID,"-","_", "ALL")>
			thisObj = document.all.WEEKLYVOLUME_#ThisProductIDFormattedForHTMLFormElementName#;
			if(!isInt(thisObj.value))
			{
				ErrorCount++;	
				queueMessage("Invalid Weekly Volume", document.all.Er_#ThisProductIDFormattedForHTMLFormElementName#);				
			}
			else
			{
				TotalWeeklyVolume = TotalWeeklyVolume + parseInt(thisObj.value);
				clearQueue(document.all.Er_#ThisProductIDFormattedForHTMLFormElementName#);
			}
			thisObj = document.all.Overage_LB_#ThisProductIDFormattedForHTMLFormElementName#;
			if(!isFloat(thisObj.value,false) && thisObj.value.length > 0)
			{
				ErrorCount++;	
				queueMessage("Invalid Rate", document.all.Er_Overage_LB_#ThisProductIDFormattedForHTMLFormElementName#);				
			}
			else
			{
				clearQueue(document.all.Er_Overage_LB_#ThisProductIDFormattedForHTMLFormElementName#);
			}
			
		</CFOUTPUT>		
		if(ErrorCount == 0){
			<CFSET Weekly_Volume = GetAllContractInfo.Contract_Daily_Volume * 7>
			if(TotalWeeklyVolume != <CFOUTPUT>#trim(numberformat(Weekly_Volume, '___________________________________'))#</CFOUTPUT>) {
				if(confirm("The Weekly Volume You Have Just Entered (" + TotalWeeklyVolume + " <CFOUTPUT>#GetAllContractInfo.Unit_Of_Measure_Desc#</CFOUTPUT>) Does Not Equal The Calculated Weekly Volume For The Whole Program (<CFOUTPUT>#trim(numberformat(Weekly_Volume, '___,___,___,___,___'))# #GetAllContractInfo.Unit_Of_Measure_Desc#</CFOUTPUT>). Press OK to Continue or CANCEL To Adjust.")){
					document.MyForm.submit();
				}
			}
			else{
				document.MyForm.submit();
			}			
		}
		else{
			showMessageWindow()
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
	

	function check_All(thisObj)
	{
		document.all.checkAll.checked = event.srcElement.checked
		document.all.demoCbox1.checked = event.srcElement.checked
		document.all.demoCbox2.checked = event.srcElement.checked
		
		var FormattedFormElementNameLen = FormattedFormElementName.length;
		for(var i=0;i<FormattedFormElementNameLen;i++)
		{
			eval("document.all.CH_" + FormattedFormElementName[i] + ".checked=thisObj.checked");
		}
		
	}
	function applyGlobalVolume(volumeToApply)
	{
		var FormattedFormElementNameLen = FormattedFormElementName.length;
		for(var i=0;i<FormattedFormElementNameLen;i++)
		{
			if(eval("document.all.CH_" + FormattedFormElementName[i] + ".checked"))
			{
				eval("document.all.WEEKLYVOLUME_" + FormattedFormElementName[i] + ".value=volumeToApply");
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
			}
		}
	}

</SCRIPT>

<CFOUTPUT>	

	<FORM ACTION="Contract_Formula_Rule_Step_3_products_action.cfm?CID=#URL.CID#&RID=#URL.RID#" METHOD="post" NAME="SaveProgramProducts" ID="SaveProgramProducts">
		<INPUT TYPE="Hidden" NAME="Sort_By" VALUE="#URL.Sort_By#">
	 	<INPUT TYPE="Hidden" NAME="Product_List" VALUE="#Form.Newly_Selected_Products#">
		<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="#Form.Newly_Selected_Products#">		
		<INPUT TYPE="Hidden" NAME="ProductListToExcludeFromSelecting" VALUE="#ProductListToExcludeFromSelecting#">
		<INPUT TYPE="Hidden" NAME="Update" VALUE="#Form.Update#">
		<INPUT TYPE="Hidden" NAME="DTPS_On" 			VALUE="1">
		<INPUT TYPE="Hidden" NAME="DTPS_Program_ID" 	VALUE="#FORM.Contract_Main_ID#">
	 </FORM>
</CFOUTPUT>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>

</BODY>
</HTML>
