

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" <cfif appSettings.getAllowNavigate()>onbeforeunload="verifyNavigate();"</cfif>>
<!---
onbeforeunload="return 'Are you sure you want to leave without storing your data?';" xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFSET GETALLCONTRACTINFO_DISCOUNT_TYPE_ID = 1>

<cfset useLakebaseForGETUOM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("units_of_measure")>
<cfif useLakebaseForGETUOM>
	<cftry>
		<cfset GETUOM = application.oLakebase.toQuery(
			application.oLakebase.selectRows("units_of_measure", {})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGETUOM = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGETUOM>
	<CFQUERY NAME="GETUOM" datasource="#application.datasource#">
		SELECT *
		FROM Units_of_Measure
	</CFQUERY>
</cfif>


 <CFQUERY NAME="GetAllContractInfo" datasource="#application.datasource#">
SELECT     *, dbo.Units_of_Measure.Unit_Of_Measure_Desc
FROM         dbo.Contract_Main INNER JOIN
                      dbo.Units_of_Measure ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID
	WHERE Contract_Main_ID = #FORM.Contract_Main_ID#
</CFQUERY>


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

<cfif isDefined("URL.Program_Fixed_Component_ID")>
<cfset form.component_id = URL.Program_Fixed_Component_ID>
<cfset useLakebaseForgetFixedComponents = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_component")>
<cfif useLakebaseForgetFixedComponents>
	<cftry>
		<cfset getFixedComponents = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_fixed_component", {
				"program_id" = "eq.#FORM.Contract_Main_ID#",
				"deleted" = "eq.0",
				"program_fixed_component_id" = "eq.#URL.Program_Fixed_Component_ID#",
				"select" = "*"
			}), "*"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetFixedComponents = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetFixedComponents>
<CFQUERY NAME="getFixedComponents" datasource="#application.datasource#">
SELECT 	Program_Fixed_Component.*
FROM 	Program_Fixed_Component
WHERE 	Program_ID = '#FORM.Contract_Main_ID#'
		AND Program_Fixed_Component.DELETED = 0
		and Program_Fixed_Component.Program_Fixed_Component_ID = #URL.Program_Fixed_Component_ID#
</CFQUERY>
</cfif>
<cfif getFixedComponents.recordcount GT 0>
	<cfset FORM.Fixed_Component_Paid_To = getFixedComponents.Fixed_Component_Paid_To>
	<cfset FORM.Program_Fixed_Component_Name_ID = getFixedComponents.Program_Fixed_Component_Name_ID>
	<cfset Form.Fixed_Component_Desc = getFixedComponents.Fixed_Component_Desc>
</cfif>
</cfif>

<CFIF NOT IsDefined("FORM.Product_List")>
	<cfif form.component_id NEQ "">
	<CFQUERY NAME="Get_Fixed_Products" DATASOURCE="#application.datasource#">
		SELECT	BSA_Foodservice_Items_Master_ID
		FROM	Contract_Products 
				INNER JOIN	dbo.Program_Fixed_Price_Product_Data 
				ON 
				Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
				AND
				Program_Fixed_Price_Product_Data.Deleted = 0
		WHERE
				Contract_Products.Deleted = 0
				AND 
				Contract_Products.Contract_Main_ID = #FORM.Contract_Main_ID#
				AND Program_Fixed_Price_Product_Data.Program_Fixed_Component_ID = #form.component_id#
	</CFQUERY>
	<CFSET FORM.Product_List = ValueList(Get_Fixed_Products.BSA_Foodservice_Items_Master_ID, ",")>
	<cfelse>
		<CFSET FORM.Product_List = "">
	</cfif>
</CFIF>

<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
SELECT     	distinct  dbo.Program_Fixed_Price_Product_Data.Program_Fixed_Price_Product_Data_ID, 
			dbo.Program_Fixed_Price_Product_Data.Fixed_Price_Value, dbo.Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID, 
			dbo.Type_Code_Desc.Type_Code_Desc, dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, 
			dbo.BSA_Foodservice_Items_Master.Item, dbo.BSA_Foodservice_Items_Master.UPC, dbo.BSA_Foodservice_Items_Master.Description, 
			<!------dbo.Program_Fixed_Price_Product_Data.Volume, ----->
			dbo.Contract_Products.Contract_Main_ID,
			BSA_Foodservice_Items_Master.Inventory_UM
FROM		
			dbo.BSA_Foodservice_Items_Master
			INNER JOIN	dbo.Brand 
			ON dbo.BSA_Foodservice_Items_Master.Brand_ID = dbo.Brand.Brand_ID 
			INNER JOIN	dbo.Type_Code_Desc 
			ON dbo.BSA_Foodservice_Items_Master.Type_Code_Desc_ID = dbo.Type_Code_Desc.Type_Code_Desc_ID
			<!---  --->
			LEFT JOIN	
			(dbo.Contract_Products 
			INNER JOIN dbo.Program_Fixed_Price_Product_Data 
			ON dbo.Program_Fixed_Price_Product_Data.Contract_Products_ID = dbo.Contract_Products.Contract_Products_ID 			
			AND (dbo.Program_Fixed_Price_Product_Data.Deleted = 0)
			AND
			<cfif (isDefined("URL.Program_Fixed_Component_ID") AND URL.Program_Fixed_Component_ID neq "") OR
				(isDefined("form.component_id") AND form.component_id neq "")>
(dbo.Program_Fixed_Price_Product_Data.Program_Fixed_Component_ID = #form.component_id#)
			<cfelse>
			1=2
			</cfif>)
			ON 	dbo.Contract_Products.BSA_Foodservice_Items_Master_ID = dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID 
			AND (dbo.Contract_Products.Deleted = 0)
			AND (dbo.Contract_Products.Contract_Main_ID = '#FORM.Contract_Main_ID#')
			AND (dbo.Contract_Products.Product_Type_ID = 1)			
			
			<!---  --->
			<!--- 
			LEFT JOIN	dbo.Contract_Products 
			ON 	dbo.Contract_Products.BSA_Foodservice_Items_Master_ID = dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID 
			AND (dbo.Contract_Products.Deleted = 0)
			AND (dbo.Contract_Products.Contract_Main_ID = '#FORM.Contract_Main_ID#')
			AND (dbo.Contract_Products.Product_Type_ID = 1)			
			LEFT JOIN	dbo.Program_Fixed_Price_Product_Data 
			ON dbo.Program_Fixed_Price_Product_Data.Contract_Products_ID = dbo.Contract_Products.Contract_Products_ID 			
			AND (dbo.Program_Fixed_Price_Product_Data.Deleted = 0)
			AND
			<cfif (isDefined("URL.Program_Fixed_Component_ID") AND URL.Program_Fixed_Component_ID neq "") OR
				(isDefined("form.component_id") AND form.component_id neq "")>
(dbo.Program_Fixed_Price_Product_Data.Program_Fixed_Component_ID = #form.component_id#)
			<cfelse>
			1=2
			</cfif>
			 --->
WHERE     			
			<CFIF FORM.Product_List EQ "">
				1=2
			<CFELSE>
				BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
				IN (#ListQualify(FORM.Product_List, "'", ",")#)
			</CFIF>
			<!--- AND (ISNULL(Contract_Products.Contract_Products_ID, 0) = ISNULL(Program_Fixed_Price_Product_Data.Contract_Products_ID, 0)) --->
ORDER BY #sql_Sort_By#
</CFQUERY>
<CFSET FORM.Product_List = ValueList(TheQuery.BSA_Foodservice_Items_Master_ID, ",")>





<BLOCKQUOTE><BLOCKQUOTE>
<CFSET URL.Contract_Main_ID = FORM.Contract_Main_ID>
<CFSET HideProductList = 1>

<CFSET helpfilenumber=7>
<cfinclude template="minimal_contract_info.cfm">

<cf_MessageWindow>
 
 <SCRIPT SRC="/Script/javascript/Queue.js"></SCRIPT>

<SCRIPT LANGUAGE="JavaSCript">
	var my_queue = new Queue();
	<!------
	my_queue.addToQueue(key, val);
	my_queue.deleteFromQueue(key);
	my_queue.getValue(key);
	----->
</SCRIPT>
 
		<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
		<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
		<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>
<!--- <SCRIPT SRC="/common_files/scripts/numberValidation.js"></SCRIPT> --->
<SCRIPT>
	function sort_by_This(thisVal)
	{
		document.MyForm.Sort_By.value = thisVal;
		document.MyForm.submit();
		return false;
	}
	function ApplyAmountToSelectedBoxes() {
		if(<CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> > 0){
		if(document.all.checkBoxCollection)
		{
		if(document.all.checkBoxCollection.length != null){
			for(var x = 0; x<document.all.MyForm.elements.length; x++) {
			
				e=document.all.MyForm.elements[x]
				if(e.type == "checkbox")	{
					if(e.APPLYMASSRATE != null) {
						if(e.checked) {
							eval("document.all." + e.APPLYMASSRATE + ".value=" + "'" + document.all.Discount_Amount.value + "'")
							resetnavigate();
						}
					}
				}
			}
		}
		else{
			if(document.all.checkBoxCollection.firstChild.checked) {
				eval("document.all."+document.all.checkBoxCollection.firstChild.APPLYMASSRATE).value = document.all.Discount_Amount.value
resetnavigate();
			}
		}
		}
		
		}
	}

	<!----
	/*
	//apply the supplied gloabl volume to all selected products
	function applyGlobalVolume(volumeToApply){
		if(<CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> > 0){
		if(document.all.checkBoxCollection)
		{
		if(document.all.checkBoxCollection.length != null){
			for(var x = 0; x<document.all.checkBoxCollection.length; x++) {
				e=document.all.checkBoxCollection[x].firstChild
					if(e.checked) {
						document.all.volumeCollection[x].firstChild.value = volumeToApply;
					}
			}
		}
		else {
			if(document.all.checkBoxCollection.firstChild.checked){
				document.all.volumeCollection.firstChild.value = volumeToApply;
			}
		}
		}
		}
	}
	*/
	---->
	
	function formatRate(oInput, fne){
		useAlternateFormat = 0;
		tb = oInput;
		us = eval('document.all.Fixed_Price_UOM_' + fne)
		
		clenseText(tb,'0123456789.')

		if(us.selectedIndex == 2) {
			decimalCount = 1;
			adjustPlace = 2;
		}
		else{
    		decimalCount = 3
			adjustPlace = 0;
		}

		if(event.type == "keyup") {
			if(tb.value.indexOf(".") != -1) {
				if(tb.value.length - tb.value.indexOf(".") >= (4-adjustPlace)) {
					var validNumber = new NumberFormat();
					validNumber.setCommas(false);
					validNumber.setCurrency(false);
					validNumber.setPlaces(decimalCount);		
					validNumber.setNumber(tb.value);
					tb.value = validNumber.toFormatted();
				}
			}
		}
		
		if(event.type == "blur" || event.type == "change") {
			var validNumber = new NumberFormat();
			validNumber.setCommas(false);
			validNumber.setCurrency(false);
			validNumber.setPlaces(decimalCount);		
			validNumber.setNumber(tb.value);
			tb.value = validNumber.toFormatted();			
		}
	
		if(us.selectedIndex == 2) {
			if(parseInt(tb.value) > 100) {
				alert("You cannot exceed 100%")
				tb.value = "0.0"
			}
		}
	}
	
	//errorCheckVolumeFields = new Array();
	//errorCheckVolumeFieldsSpans = new Array();
	//errorCheckPriceFields = new Array();
	//errorCheckPriceFieldsSpans = new Array();
	var ErrorCount = 0;
	var TotalWeeklyVolume = 0;
	
	function check_This_Product(trObj)
	{	
		var product_Name_Re = trObj.PRODUCT_ID_RE;
		var bDelete = 1;		
		if(trObj.bDelete != "undefined")
		{
			bDelete = trObj.bDelete;
		}
		
		if(product_Name_Re && bDelete == 0)
		{
			tempPriceObject			= eval("document.all." + "Fixed_Price_Value_" + product_Name_Re)
			tempPriceObjectSpan		= eval("document.all." + "error_Price_" + product_Name_Re)
			var priceValue = parseFloat(tempPriceObject.value);
			priceValue = (isNaN(priceValue))?0:priceValue;
			
			if(tempPriceObject.value.length == 0)
			{
				ErrorCount++
				queueMessage("Enter a price", tempPriceObjectSpan)
			}
			else if(priceValue <= 0)
			{
				ErrorCount++
				queueMessage("Price should be greater than zero", tempPriceObjectSpan)
			}
			else 
			{
				clearQueue(tempPriceObjectSpan)
			}
		}
	}
	
	function verifyData() {
		
		var tr_Products_obj = document.all.TR_Products;
		ErrorCount = 0;
		TotalWeeklyVolume = 0;
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
		
		if(ErrorCount==0){
			<!----
/*
			TotalDailyVolume = TotalWeeklyVolume
			TotalDailyVolume = TotalDailyVolume

			var nf = new NumberFormat();
			nf.setNumber(TotalWeeklyVolume);
			nf.setCommas(true);
			nf.setCurrency(false);
			nf.setPlaces(0);
			TotalWeeklyVolume = nf.toFormatted();

			<CFSET Weekly_Volume = GetAllContractInfo.Contract_Daily_Volume * 7>
			if(TotalDailyVolume != <CFOUTPUT>#trim(numberformat(Weekly_Volume, '___________________________________'))#</CFOUTPUT>) {
				if(confirm("The Weekly Volume You Have Just Entered ("+TotalWeeklyVolume+" <CFOUTPUT>#GetAllContractInfo.Unit_Of_Measure_Desc#</CFOUTPUT>) Does Not Equal The Calculated Weekly Volume For The Whole Program (<CFOUTPUT>#trim(numberformat(Weekly_Volume, '___,___,___,___,___'))# #GetAllContractInfo.Unit_Of_Measure_Desc#</CFOUTPUT>). Press OK to Continue or CANCEL To Adjust.")){
					document.MyForm.action = "Contract_Discount_Fixed_Prices_Action.cfm";
					document.MyForm.submit();
				}
			}
			else{
				document.MyForm.action = "Contract_Discount_Fixed_Prices_Action.cfm";
				document.MyForm.submit();
			}
			*/
---->
			document.MyForm.action = "Contract_Discount_Fixed_Prices_Action.cfm";
			document.all.navigate.value = 0;
			document.MyForm.submit();
		}
		else {
			showMessageWindow();
			document.all.navigate.value = 1;
		}
	}
	

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
		return 0;
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
		document.MyForm.ExistingProductList.value = resultString;
		var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";	
		if(trObj)
		{			
			if(bDelete)
			{ 
			
				my_queue.addObjValueToQueue(prodID + "_Adjustment", "document.all.Fixed_Price_Value_" + FieldNameRe);
				my_queue.addObjValueToQueue(prodID + "_Adjustment_UOM", "document.all.Fixed_Price_UOM_" + FieldNameRe);

				trObj.height = trObj.offsetHeight;
				
				//trObj.cells[0].innerHTML = empty_String;
				trObj.cells[trObj.cells.length-1].innerHTML = empty_String;
				
				trObj.cells[4].innerHTML = empty_String;				
				disableDiv(trObj.cells[5], true, false);
				
				propogateProperty(trObj, "style.backgroundColor", "#DDDDDD", false);
				propogateProperty(trObj, "style.textDecoration", "line-through", true);				
				
				srcObj.alt = "undo product deletion";
				srcObj.src = undodeleteImg.src;
				resetnavigate();
				
			
			}
			else
			{
			
			
				//trObj.cells[0].innerHTML = "<span ID=\"checkBoxCollection\"><INPUT type=\"Checkbox\" NAME=\"Fixed_Price_Product_" + FieldNameRe + "\" APPLYMASSRATE=\"Fixed_Price_Value_" + FieldNameRe + "\" VALUE=\"" + FieldNameRe + "\" checked></span>";
				trObj.cells[trObj.cells.length-1].innerHTML = "<span ID=\"checkBoxCollection\"><INPUT type=\"Checkbox\" NAME=\"Fixed_Price_Product_" + FieldNameRe + "\" APPLYMASSRATE=\"Fixed_Price_Value_" + FieldNameRe + "\" VALUE=\"" + FieldNameRe + "\" checked></span>";
				
				trObj.cells[4].innerHTML = "$<INPUT TYPE=\"text\" NAME=\"Fixed_Price_Value_" + FieldNameRe + "\" SIZE=\"5\" VALUE=\"\" ONKEYUP=\"formatRate(this,'" + FieldNameRe + "')\" onblur=\"formatRate(this,'" + FieldNameRe + "')\"><SPAN ID=\"error_Price_" + FieldNameRe + "\"></SPAN>"
				disableDiv(trObj.cells[5], false, false);
				
				var bgCol = "#FFFFFF";
				if(trObj.rowIndex % 2 == 1)
				{
					bgCol = "#C6FFC6";
				}
				propogateProperty(trObj, "style.backgroundColor", bgCol, false);
				propogateProperty(trObj, "style.textDecoration", "none", false);
				
				srcObj.alt = "delete this product";
				srcObj.src = deleteImg.src;
				
				propogateProperty(trObj, "style.backgroundColor", "#FFFFFF", false, true);
				
				my_queue.deleteAndSetObjValueFromQueue(prodID + "_Adjustment", "document.all.Fixed_Price_Value_" + FieldNameRe);
				my_queue.deleteAndSetObjValueFromQueue(prodID + "_Adjustment_UOM", "document.all.Fixed_Price_UOM_" + FieldNameRe);

			}
			srcObj.bDelete = !bDelete;
			trObj.bDelete = (bDelete?1:0);
		}				
	}
	
	<!----
/*function resetAverageWeight()
	{	
		var Product_List = document.MyForm.Product_List.value;		
		var Arr = Product_List.split(",");
		var ArrLen = Arr.length;
		var TotalVolume = <cfoutput>#Weekly_Volume#</cfoutput> / ArrLen;
		TotalVolume = Math.round(TotalVolume);
		document.all.AverageVolume.innerText = formatWithComma(TotalVolume, 3);
		document.MyForm.formAverageVolume.value = TotalVolume;
	}*/
---->
	
	
	
</SCRIPT>
<!--- <cfif TheQuery.Recordcount GT 0>
<cfset comparedlist = ListCompare(Form.Product_List,queryproductlist)>
</CFIF> --->


<cfif TheQuery.Recordcount LT 1>
	<strong>Select products</strong>
	<BR><BR>
	<CF_button
		button_name		=	"selectproducts"
		button_caption	=	"select products"
		button_action	=	"javascript: showProductSearchWindow();"
		button_type		=	"javascript_link"
		button_width	=	"100"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
	<BR>
</cfif>
<!------<FORM ACTION="Contract_Discount_Fixed_Prices_Action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">----->
<FORM ACTION="Contract_Discount_Fixed_Prices.cfm?CID=<CFOUTPUT>#URL.CID#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm" STYLE="DISPLAY:INLINE;">
<cfif TheQuery.Recordcount GT 0>

	<TABLE WIDTH="800" BORDER="0" CELLPADDING="2" CELLSPACING="0">
	<TR>
		<TD colspan="3">
		</TD>
	</TR>
	<TR>
		<TD NOWRAP STYLE="border-bottom:2px solid navy;">
		<CF_SmallHelp>You may choose to apply the same price to all the items. Specify the price and click apply.</CF_SmallHelp>
		&nbsp;&nbsp;&nbsp;
		<FONT SIZE="2">
			Enter a price for all items: <INPUT TYPE="Text" NAME="Discount_Amount" SIZE="3" ONKEYUP="clenseText(this, '.0123456789'); threeDecimalPlaces(this);" onblur="threeDecimalPlaces(this)">
			<FONT COLOR="Red"><B>[ </B></FONT><A ONCLICK="ApplyAmountToSelectedBoxes()" STYLE="cursor: hand;">apply price</A><FONT COLOR="Red"><B> ]</B></FONT>			
		</TD>
	</TR>
</table>
<br>
<table width="800" cellpadding="0" cellspacing="0" border="0">
<tr VALIGN="top">
<td width="110">
	<CF_button
		button_name		=	""
		button_caption	=	"save"
		button_action	=	"javascript: verifyData();"
		button_type		=	"javascript_link"
		button_width	=	"100"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
</td>
<td width="110">
	<CF_button
		button_name		=	"selectproducts"
		button_caption	=	"select products"
		button_action	=	"javascript: showProductSearchWindow();"
		button_type		=	"javascript_link"
		button_width	=	"100"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>	
</td>
<!--- <td align="center">
<cfif application.returned_customer_setting.show_delivered EQ 1>
<FIELDSET STYLE="padding:none; width: 200px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Rate Type:</LEGEND>
	<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="left">
		<TR>
			<TD><INPUT NAME="Fixed_Price_Rebate_Type" TYPE="Radio" VALUE="1" <CFIF CSLGetContractInfo.Fixed_Price_Rebate_Type EQ 1> CHECKED</CFIF> onchange="resetnavigate();"></TD>
			<TD>Delivered</TD>
			<TD><INPUT NAME="Fixed_Price_Rebate_Type" TYPE="Radio" VALUE="2" <CFIF CSLGetContractInfo.Fixed_Price_Rebate_Type EQ 2> CHECKED</CFIF> onchange="resetnavigate();"></TD>
			<TD>FOB</TD>
		</TR>
	</TABLE>
</FIELDSET>
<cfelse>
	<INPUT NAME="Fixed_Price_Rebate_Type" TYPE="Hidden" VALUE="2">
</cfif>
</td> --->
<td width="*" align="right">
<font style="font-weight:bold; font-size:11px; color: navy;">Global UOM:</font>
<cf_uom_dropdown
	company_main_id			=	""
	default_option_on		=	""
	setDefaultSelected 		=	"#defaultselected#"
	default_option_text		=	""
	default_option_value	=	"0"
	dropdown_name			=	"Global_UOM"
	option_text_abbreviated	=	""
	plural_uom_display		=	""
	product_type_id			=	"1"
	program_template_id		=	"#GetAllContractInfo.ProgramType_ID#"
	selected_uom_id			=	""
	text_before_tag_close	=	""
	uom_id_exclusion_list	=	""
	uom_id_inclusion_list	=	"#ListOfAvailUOMFF#"
>
			
<span onclick="applyGlobalUOM()"><font style="color:red;font-weight:bold;">[</font><font color="##0000ff" style="cursor:hand;">apply</font><font style="color:red;font-weight:bold;">]</font></span>
</td>
</tr></table>

<TABLE border="0" cellspacing="0" cellpadding="3" CLASS="Maintable" WIDTH="800">
	<TR>
		<TD>
		<CF_SmallHelp 
			width="400">
			Specify the price for each item here. Click on the save button when you are done.
			</CF_SmallHelp>
		</TD>
		<TD align="right" style="color:navy;" colspan="80%">
			<span STYLE="color: blue; font-weight: bold; font-size:12px;">*Click on the Column Headers to sort the records</span>
			
		</TD>
	</TR>
	
	<TR ID="header" BGCOLOR="#ffce84">
		<TD ID="header" WIDTH="30"><NOBR><img bDelete="true" sMessage="delete all products in this page" src="/images/scissor.gif" alt="delete all products in this page" border="0" onclick="deleteAll('Fixed_Price_Product_')" style="cursor: hand;"></NOBR></TD>		
		<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD align="left" ID="header" WIDTH="50"><A HREF="#" OnClick="JavaScript: return sort_by_This('UPC');"><B>UPC</B></A></TD></cfif></cfif>
		<TD align="left" ID="header" WIDTH="50"><A HREF="#" OnClick="JavaScript: return sort_by_This('Item');"><B>Item #</B></A></TD>
		<TD align="left" ID="header" WIDTH="40%"><A HREF="#" OnClick="JavaScript: return sort_by_This('Description');"><B>Description</B></A></TD>
		<!------<TD align="left" ID="header" WIDTH="215"><B>Weekly Volume</B></TD>----->
		<TD ID="header" WIDTH="100"><B>Fixed Price</B></TD>
		<TD ID="header" WIDTH="50"><B>Per</B></TD>
		<TD align="center" ID="header" WIDTH="20"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Products" checked></TD>
	</TR>
<CFOUTPUT QUERY="TheQuery">
	<!------<CFSET FieldNameEnd = replace(TheQuery.Program_Fixed_Price_Product_Data_ID,"-","_", "ALL")>----->
	<CFSET FieldNameEnd = replace(TheQuery.BSA_Foodservice_Items_Master_ID,"-","_", "ALL")>
	<script>
		//errorCheckVolumeFields[errorCheckVolumeFields.length] = "Fixed_Price_Product_Volume_#FieldNameEnd#";
		//errorCheckVolumeFieldsSpans[errorCheckVolumeFieldsSpans.length] = "error_Vol_#FieldNameEnd#";
		//errorCheckPriceFields[errorCheckPriceFields.length] = "Fixed_Price_Value_#FieldNameEnd#";
		//errorCheckPriceFieldsSpans[errorCheckPriceFieldsSpans.length] = "error_Price_#FieldNameEnd#";
	</script>
	<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> ONMOUSEOVER="menuID=6;URLstring='';an_ID='#TheQuery.BSA_Foodservice_Items_Master_ID#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;" ID="TR_Products" PRODUCT_ID_RE="#FieldNameEnd#" bDelete="0">
		<TD><img bDelete="true" name="IMG_Delete_Scissor" src="/images/scissor.gif" alt="click here to delete this product" border="0" onclick="deleteThisFixedPrice('#FieldNameEnd#', '#TheQuery.BSA_FOODSERVICE_ITEMS_MASTER_ID#')" style="cursor: hand;"></TD>			
		<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD NOWRAP>#TheQuery.UPC#</TD></cfif></cfif>
		<TD NOWRAP>#TheQuery.ITEM#</TD>
		<TD>#TheQuery.Description#</TD>
		<!------<CFPARAM NAME="FORM.Fixed_Price_Product_Volume_#FieldNameEnd#" 	DEFAULT="#Volume#">----->


		<CFPARAM NAME="FORM.Fixed_Price_Value_#FieldNameEnd#" 	DEFAULT="#Fixed_Price_Value#">

		<CFPARAM NAME="FORM.Fixed_Price_UOM_#FieldNameEnd#" 	DEFAULT="#Unit_Of_Measure_ID#">

		<CFSET D_Price = Evaluate("FORM.Fixed_Price_Value_#FieldNameEnd#")>
		<!------<TD><SPAN ID="error_Vol_#FieldNameEnd#"></SPAN><SPAN ID="volumeCollection"><INPUT TYPE="Text" NAME="Fixed_Price_Product_Volume_#FieldNameEnd#" VALUE="#Evaluate("FORM.Fixed_Price_Product_Volume_#FieldNameEnd#")#" SIZE="10" ONKEYUP="clenseText(this, '0123456789')"></SPAN>&nbsp;#GetAllContractInfo.Unit_Of_Measure_Desc#</TD>----->
		<TD>$<INPUT TYPE="text" NAME="Fixed_Price_Value_#FieldNameEnd#" SIZE="5" VALUE="<CFIF len(D_Price) EQ 0>#trim(numberformat(0, '__.___'))#<CFELSE>#trim(numberformat(D_Price, '__.___'))#</CFIF>" ONKEYUP="formatRate(this,'#FieldNameEnd#')" onblur="formatRate(this,'#FieldNameEnd#')" onchange="resetnavigate();"><SPAN ID="error_Price_#FieldNameEnd#"></SPAN></TD>

		<TD>

		<CFSET temp = Evaluate("FORM.Fixed_Price_UOM_#FieldNameEnd#")>
		
		<cfif len(trim(temp)) EQ 0><cfset temp = 0>
		<cfset defaultselected = 1>
		<cfelse>
		<cfset defaultselected = 0>
		</cfif>
	
		<span id="UOMCollection">
		<cf_uom_dropdown
			program_id				=	""
			company_main_id			=	""
			default_option_on		=	"0"
			setDefaultSelected 		=	"#defaultselected#"
			default_option_text		=	""
			default_option_value	=	"0"
			dropdown_name			=	"Fixed_Price_UOM_#FieldNameEnd#"
			option_text_abbreviated	=	""
			plural_uom_display		=	""
			product_type_id			=	"1"
			program_template_id		=	"#GetAllContractInfo.ProgramType_ID#"
			selected_uom_id			=	"#temp#"
			text_before_tag_close	=	"onchange=""formatRate(document.all.Fixed_Price_Value_#FieldNameEnd#,'#FieldNameEnd#');resetnavigate();"" onblur=""formatRate(document.all.Fixed_Price_Value_#FieldNameEnd#,'#FieldNameEnd#')"""
			uom_id_exclusion_list	=	""
			uom_id_inclusion_list	=	"#ListOfAvailUOMFF#"
			productUom				=	"#Inventory_UM#"
		>
		</span>
		</TD>
		<TD align="center"><span ID="checkBoxCollection"><INPUT type="Checkbox" NAME="Fixed_Price_Product_#FieldNameEnd#" APPLYMASSRATE="Fixed_Price_Value_#FieldNameEnd#" VALUE="#FieldNameEnd#" checked></span></TD>	
		</TR>
</CFOUTPUT>
<TR><TD COLSPAN="100%" ALIGN="center"></TD></TR>
</TABLE>

<BR>


<CF_button
	button_name		=	""
	button_caption	=	"save"
	button_action	=	"verifyData();"
	button_type		=	"javascript_link"
	button_width	=	"100"
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold"
>	

</cfif>

<INPUT TYPE="hidden" NAME="ProductCount" VALUE="<CFOUTPUT>#TheQuery.Recordcount#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="Contract_Main_ID" VALUE="<CFOUTPUT>#FORM.Contract_Main_ID#</CFOUTPUT>">
<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="Sort_By" 			VALUE="#URL.Sort_By#">
	<INPUT TYPE="Hidden" NAME="Program_ID" 			VALUE="#URL.CID#">
	<INPUT TYPE="Hidden" NAME="Product_List" 		VALUE="#valuelist(TheQuery.BSA_Foodservice_Items_Master_ID)#">
	<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="#valuelist(TheQuery.BSA_Foodservice_Items_Master_ID)#">
	<INPUT TYPE="Hidden" NAME="DTPS_On" 			VALUE="1">
	<INPUT TYPE="Hidden" NAME="DTPS_Program_ID" 	VALUE="#FORM.Contract_Main_ID#">
<INPUT TYPE="Hidden" NAME="navigate" VALUE="#FORM.navigate#">
<INPUT TYPE="Hidden" NAME="stopnavigate" VALUE="0">
<input TYPE="Hidden" NAME="update" VALUE="#form.update#">
		<input TYPE="Hidden" NAME="Program_Fixed_Component_Name_ID" VALUE="#FORM.Program_Fixed_Component_Name_ID#">
		<input TYPE="Hidden" NAME="fixed_component_desc" VALUE="#FORM.fixed_component_desc#">
		<input TYPE="Hidden" NAME="fixed_component_Paid_To" VALUE="#FORM.fixed_component_Paid_To#">
		<input type="hidden" name="component_id" value="#form.component_id#">
		<input type="hidden" name="Program_Fixed_Component_ID" value="#form.component_id#">
<cfif isDefined("URL.Program_Fixed_Component_ID") OR (form.component_id NEQ "" AND form.component_id NEQ 0)>
<input type="hidden" name="onlyproducts" value="1">
</cfif>

	</CFOUTPUT>
</FORM>
</BLOCKQUOTE></BLOCKQUOTE>

<FORM ACTION="Contract_Discount_Fixed_Prices_save_products_Action.cfm" METHOD="post" NAME="SaveProgramProducts" ID="SaveProgramProducts">
	<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="Sort_By" 			VALUE="#URL.Sort_By#">
	<INPUT TYPE="Hidden" NAME="Product_List" 		VALUE="#valuelist(TheQuery.BSA_Foodservice_Items_Master_ID)#">
	<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="#valuelist(TheQuery.BSA_Foodservice_Items_Master_ID)#">
	<INPUT TYPE="Hidden" NAME="DTPS_On" 			VALUE="1">
	<INPUT TYPE="Hidden" NAME="DTPS_Program_ID" 	VALUE="#FORM.Contract_Main_ID#">
	<input TYPE="Hidden" NAME="update" VALUE="#form.update#">
		<input TYPE="Hidden" NAME="Program_Fixed_Component_Name_ID" VALUE="#FORM.Program_Fixed_Component_Name_ID#">
		<input TYPE="Hidden" NAME="fixed_component_desc" VALUE="#FORM.fixed_component_desc#">
		<input TYPE="Hidden" NAME="fixed_component_Paid_To" VALUE="#FORM.fixed_component_Paid_To#">
		<input type="hidden" name="component_id" value"#form.component_id#">
		<input type="hidden" name="Program_Fixed_Component_ID" value="#form.component_id#">
		<INPUT TYPE="Hidden" NAME="Program_ID" VALUE="#URL.CID#">
	</CFOUTPUT>
</FORM>
<cfif application.programlayout EQ 1></div></cfif>
<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
<SCRIPT>

		function showProductSearchWindow() {
			 NewWindow("product_Select_V1.cfm?Formname=MyForm", "productwindow", 800, 600, "yes", "yes", true)			
		}
<!--- <CFINCLUDE TEMPLATE="/script/javascript/string_functions.js"> --->
</SCRIPT>

<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT>

		function CA() {
			document.all.allbox.checked = event.srcElement.checked;
			
			if(0==0) {
				for (var i=0;i<MyForm.elements.length;i++)
					{
						var e = MyForm.elements[i];
						if ((e.name != 'allbox') && (e.type=='checkbox') && (e.name != 'ALLINCATEGORY')) {
							e.checked = MyForm.allbox.checked;
						}
					}
			//toggleRowColors()
			}
			else {
				document.all.allbox.checked = false;
			}
		}

		function applyGlobalUOM(){
			gUOM = document.all.Global_UOM.value;
			
			if(document.all.UOMCollection != null)
			{
				if(UOMCollection.length != null)
				{
					for(var x = 0; x<UOMCollection.length;x++)
					{
						changeUOMTo(UOMCollection[x].firstChild, gUOM);
					}
				}
				else
				{
					changeUOMTo(UOMCollection.firstChild, gUOM);
				}
			}
		}
		
		function changeUOMTo(selObj, selValue)
		{
			var optObj = Get_Object_Property_Match_Collection(selObj.options, "value", selValue)
			if(optObj)
			{
				optObj.selected = true;
				selObj.fireEvent("onchange");
				resetnavigate();
			}
		}
		
		function resetnavigate()
		{
			document.all.navigate.value = 1;
		}
		function verifyNavigate() {
			if (document.all.navigate.value == 1 && document.all.stopnavigate.value == 0) {
				{
					event.returnValue="Your changes will not be saved if you click OK";
			}
		}	
		}
		
 </SCRIPT>	

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- delete product section --->
<cfinclude template="delete_product_include.cfm">
<!--- delete product section --->
</BODY>
</HTML>
