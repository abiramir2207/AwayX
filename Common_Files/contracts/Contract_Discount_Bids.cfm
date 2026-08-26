<cfparam NAME="form.updateratesflag" DEFAULT="0">
<cfif form.updateratesflag EQ 1>
	<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
	<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>

	<CFLOOP INDEX="BSA_Foodservice_Items_Master_ID" LIST="#FORM.PRODUCT_LIST#" DELIMITERS=",">
		<CFSET PRECURSORSTRING = replace(lcase(BSA_Foodservice_Items_Master_ID), "-", "_", "ALL")>
		<cfset thisRateSource = evaluate("Form.Manual_Rate_Source_#PRECURSORSTRING#")>
		<cfset thisSuppliedRate_CASE = evaluate("FORM.RATE_CS_#PRECURSORSTRING#")>
		<cfset thisSuppliedRate_POUND = evaluate("FORM.RATE_LB_#PRECURSORSTRING#")>
		
		<CFIF thisRateSource EQ 0><!--- allow database to genrate Bid Price --->
			<CFQUERY NAME="GetProductVolume" DATASOURCE="#application.datasource#">
			SELECT Volume_LB
			FROM Program_Product_Volume
			WHERE 
				Program_ID = '#temp#'
				AND
				BSA_Foodservice_Items_Master_ID = '#BSA_Foodservice_Items_Master_ID#'
				AND
				Deleted = 0
				AND
				len(Volume_LB) > 0
				AND
				len(Volume_CS) > 0
			</CFQUERY>
		
			<cfif GetProductVolume.Recordcount GT 0>
				<CFSTOREDPROC PROCEDURE="Get_Bid_Price" DATASOURCE="#application.datasource#">
					<cfprocparam type = "IN" dbVarName = "@@INPUTVAR_BSA_Foodservice_Items_Master" value = "#BSA_Foodservice_Items_Master_ID#" CFSQLType="CF_SQL_IDSTAMP">
					<cfprocparam type = "IN" dbVarName = "@@INPUTVAR_Volume" value = "#GetProductVolume.Volume_LB#" CFSQLType="CF_SQL_FLOAT">
					<cfprocparam type = "IN" dbVarName = "@@INPUTVAR_Volume_UOM" value = "pound" CFSQLType="CF_SQL_VARCHAR">
					
					<cfprocparam type = "OUT" VARIABLE="Final_Rate_CASE" dbVarName = "@OUTPUTVAR_Rate_CASE" CFSQLType="CF_SQL_FLOAT">
					<cfprocparam type = "OUT" VARIABLE="Final_Rate_POUND" dbVarName = "@OUTPUTVAR_Rate_POUND" CFSQLType="CF_SQL_FLOAT">
				</CFSTOREDPROC>
			<CFELSE>
				<CFSET Final_Rate_CASE 	= "NULL">
				<CFSET Final_Rate_POUND = "NULL">
			</cfif>
			

		</CFIF>
		
		<CFIF thisRateSource EQ 1 OR thisRateSource EQ 2><!--- Calculate rate based on user input  --->
			<cfswitch EXPRESSION="#thisRateSource#">
				<cfcase VALUE="2"><!--- case  --->
					<CFSET SuppliedVolumeUOM = "case">
					<CFSET SuppliedRate = thisSuppliedRate_CASE>
				</cfcase>
				<cfcase VALUE="1"><!--- pound  --->
					<CFSET SuppliedVolumeUOM = "pound">
					<CFSET SuppliedRate = thisSuppliedRate_POUND>
				</cfcase>
			</cfswitch>
			
			<CFSTOREDPROC PROCEDURE="Get_Bid_Price_Based_On_Supplied_Volume" DATASOURCE="#application.datasource#">
				<cfprocparam type = "IN" dbVarName = "@@INPUTVAR_BSA_Foodservice_Items_Master" value = "#BSA_Foodservice_Items_Master_ID#" CFSQLType="CF_SQL_IDSTAMP">
				<cfprocparam type = "IN" dbVarName = "@@INPUTVAR_Supplied_Rate" value = "#SuppliedRate#" CFSQLType="CF_SQL_FLOAT">
				<cfprocparam type = "IN" dbVarName = "@@INPUTVAR_Supplied_Rate_UOM" value = "#SuppliedVolumeUOM#" CFSQLType="CF_SQL_VARCHAR">

				<cfprocparam type = "OUT" VARIABLE="Final_Rate_CASE" dbVarName = "@OUTPUTVAR_Rate_CASE" CFSQLType="CF_SQL_FLOAT">
				<cfprocparam type = "OUT" VARIABLE="Final_Rate_POUND" dbVarName = "@OUTPUTVAR_Rate_POUND" CFSQLType="CF_SQL_FLOAT">				

			</CFSTOREDPROC>
		</CFIF>
	
		<CFSET "FORM.RATE_CS_#PRECURSORSTRING#" = Final_Rate_CASE>
		<CFSET "FORM.RATE_LB_#PRECURSORSTRING#" = Final_Rate_POUND>

	</CFLOOP>

	<cfset form.updateratesflag = 0>
</cfif>


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

<!-- get bid rule data -->
<CFQUERY NAME="getBidRule" DATASOURCE="#application.datasource#">
	SELECT     dbo.Bid_Rules.Bid_Rule_ID, dbo.Bid_Rules.Bid_Rule_UOM, dbo.Units_of_Measure.Unit_Of_Measure_Desc
	FROM         dbo.Bid_Rules INNER JOIN
	                      dbo.Units_of_Measure ON dbo.Bid_Rules.Bid_Rule_UOM = dbo.Units_of_Measure.Unit_Of_Measure_ID
	WHERE     (dbo.Bid_Rules.Deleted = 0)
</CFQUERY>

<cfset counter = 1>
<CFLOOP QUERY="getBidRule">
	<cfset "bidrule_#counter#" = structnew()>
	<cfset "bidrule_#counter#.Bid_Rule_ID" = getBidRule.Bid_Rule_ID>
	<cfset "bidrule_#counter#.UOM_ID" = getBidRule.Bid_Rule_UOM>
	<cfset "bidrule_#counter#.UOM_DESC" = getBidRule.Unit_Of_Measure_Desc>
	
	<cfset useLakebaseForGetTypeID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bid_rule_items")>
	<cfif useLakebaseForGetTypeID>
		<cftry>
			<cfset getTypeID = application.oLakebase.toQuery(
				application.oLakebase.selectRows("bid_rule_items", { "deleted" = "eq.false", "select" = "type_item_id" })
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForGetTypeID = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetTypeID>
		<CFQUERY NAME="getTypeID" DATASOURCE="#application.datasource#">
			SELECT Type_Item_ID
			FROM Bid_Rule_Items
			WHERE Deleted = 0
		</CFQUERY>
	</cfif>
	
	<cfloop QUERY="getTypeID">
		<cfset "bidrule_#counter#.typeidlist" = valuelist(getTypeID.Type_Item_ID)>
	</cfloop>
	
	<cfset counter = counter + 1>
</cfloop>

<cfscript>
	function getTypeUOM(typeid) {
		for (i = 1; i LT counter; i = i+1) {  
			tempStruct = evaluate("bidrule_#i#");
			if(listfind(tempStruct.typeidlist, typeid)) {
				return tempStruct;
			}
		} 
	}
</cfscript>

<CFSET PAGE_TITLE= "Bid Price Entry">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" ONLOAD="">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "bids"> 
<cfset FORM.Contract_Main_ID = cryp.value>

<cfif application.programlayout EQ 1>
<div id="Layer2" style="position:absolute; width: 60px; height: 400px; z-index: 1; left: 10px; top: 0px">
  <CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
 <cfelse>
<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
</cfif>
<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:relative; height:430px; width:800px; z-index:1; left: 80px; top: 10px;"></cfif>


<CFSET GETALLCONTRACTINFO_DISCOUNT_TYPE_ID = 1>

<cfset useLakebaseForGETUOM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("units_of_measure")>
<cfif useLakebaseForGETUOM>
	<cftry>
		<cfset GETUOM = application.oLakebase.toQuery(
			application.oLakebase.selectRows("units_of_measure", {})
		)>
		<cfcatch type="any">
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

<CFQUERY NAME="GetValidProductsWithVolume" DATASOURCE="#application.datasource#">
	SELECT BSA_Foodservice_Items_Master_ID
	FROM Program_Product_Volume
	WHERE
		Program_ID = '#FORM.Contract_Main_ID#'
		AND
		len(Volume_LB) > 0
		AND
		len(Volume_CS) > 0
		AND
		Deleted = 0
</CFQUERY>
<cfset listGetValidProductsWithVolume = valuelist(GetValidProductsWithVolume.BSA_Foodservice_Items_Master_ID)>

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
<CFIF NOT IsDefined("FORM.Product_List")>
	<CFQUERY NAME="Get_Bid_Products" DATASOURCE="#application.datasource#">
		SELECT	BSA_Foodservice_Items_Master_ID
		FROM	Contract_Products 
				INNER JOIN	Program_Bid_Price_Product_Data 
				ON 
				Program_Bid_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
				AND
				Program_Bid_Price_Product_Data.Deleted = 0
		WHERE
				Contract_Products.Deleted = 0
				AND 
				Contract_Products.Contract_Main_ID = #FORM.Contract_Main_ID#
	</CFQUERY>
	<CFSET FORM.Product_List = ValueList(Get_Bid_Products.BSA_Foodservice_Items_Master_ID, ",")>
</CFIF>


<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
SELECT     	dbo.Contract_Products.Contract_Products_ID, dbo.Program_Bid_Price_Product_Data.Program_Bid_Price_Product_Data_ID, 
			dbo.Program_Bid_Price_Product_Data.Rate_LB, dbo.Program_Bid_Price_Product_Data.Rate_CS, dbo.Program_Bid_Price_Product_Data.Manual_Rate_Source,
			dbo.Type_Code_Desc.Type_Code_Desc, dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, 
			dbo.BSA_Foodservice_Items_Master.Item, dbo.BSA_Foodservice_Items_Master.UPC, dbo.BSA_Foodservice_Items_Master.Description, 
			dbo.Contract_Products.Contract_Main_ID,
			dbo.BSA_Foodservice_Items_Master.#application.returned_customer_setting.APPROVAL_CRITERIA_TABLE_ID#
FROM		
			dbo.BSA_Foodservice_Items_Master
			INNER JOIN	dbo.Brand 
			ON dbo.BSA_Foodservice_Items_Master.Brand_ID = dbo.Brand.Brand_ID 
			INNER JOIN	dbo.Type_Code_Desc 
			ON dbo.BSA_Foodservice_Items_Master.Type_Code_Desc_ID = dbo.Type_Code_Desc.Type_Code_Desc_ID
			LEFT JOIN	dbo.Contract_Products 
			ON 	dbo.Contract_Products.BSA_Foodservice_Items_Master_ID = dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID 
			AND (dbo.Contract_Products.Deleted = 0)
			AND (dbo.Contract_Products.Contract_Main_ID = '#FORM.Contract_Main_ID#')
			AND (dbo.Contract_Products.Product_Type_ID = 9)
			LEFT JOIN	dbo.Program_Bid_Price_Product_Data 
			ON dbo.Program_Bid_Price_Product_Data.Contract_Products_ID = dbo.Contract_Products.Contract_Products_ID 			
			AND (dbo.Program_Bid_Price_Product_Data.Deleted = 0)
WHERE     			
			<CFIF FORM.Product_List EQ "">
				1=2
			<CFELSE>
				BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
				IN (#ListQualify(FORM.Product_List, "'", ",")#)
			</CFIF>
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
				e=document.all.MyForm.elements[x];
				if(e.type == "checkbox")	{
					if(e.APPLYMASSRATE != null) {
						if(e.checked) {
							inputCollection = e.parentElement.parentElement.parentElement.getElementsByTagName("input");
							for(var n=0; n<inputCollection.length; n++){
								inputObj=inputCollection[n];
								if(inputObj.type=="radio") {
									if(inputObj.checked) {
										//alert(inputObj.parentElement.parentElement.nextSibling.firstChild.firstChild)
									}
								}
							}

						}
					}
				}
			}
		}
		else{
			if(document.all.checkBoxCollection.firstChild.checked) {
				eval("document.all."+document.all.checkBoxCollection.firstChild.APPLYMASSRATE).value = document.all.Discount_Amount.value
			}
		}
		}
		}
	}

	function formatRate(oInput, fne, us){
		useAlternateFormat = 0;
		tb = oInput;
		
		clenseText(tb,'0123456789.')

		
   		decimalCount = 3
		adjustPlace = 0;
					
		/*
		if(us == 2) {
			decimalCount = 1;
			adjustPlace = 2;
		}
		else{
    		decimalCount = 3
			adjustPlace = 0;
		}
		*/

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
	
		/*if(us == 2) {
			if(parseInt(tb.value) > 100) {
				alert("You cannot exceed 100%")
				tb.value = "0.0"
			}
		
		}
		*/
	}
	
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

			tempPriceObject			= eval("document.all." + "Bid_Price_Value_" + product_Name_Re)
			tempPriceObjectSpan		= eval("document.all." + "error_Price_" + product_Name_Re)

			if(tempPriceObject.value.length == 0){
				ErrorCount++
				queueMessage("Enter A Price", tempPriceObjectSpan)
			}
			else {
				clearQueue(tempPriceObjectSpan)
			}
		}
	}
	
	function verifyData() {
		ErrorCount = 0;

		
		if(ErrorCount==0){
			document.MyForm.action = "Contract_Discount_Bid_Prices_Action.cfm";
			document.MyForm.submit();
		}
		else {
			showMessageWindow();
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
	
	
	function deleteThisBidPrice(FieldNameRe, prodID)
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
				trObj.height = trObj.offsetHeight;
				disableDiv(trObj, true, false);
				disableDiv(trObj.cells[0], false, false);
				
				propogateProperty(trObj, "style.backgroundColor", "#DDDDDD", false);
				propogateProperty(trObj, "style.textDecoration", "line-through", true);				
				
				srcObj.alt = "undo product deletion";
				srcObj.src = undodeleteImg.src;
			
			}
			else
			{
				disableDiv(trObj, false, false);
				
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
				
				//my_queue.deleteAndSetObjValueFromQueue(prodID + "_Adjustment", "document.all.Rate_LB_" + FieldNameRe);
				//my_queue.deleteAndSetObjValueFromQueue(prodID + "_Adjustment_UOM", "document.all.Bid_Price_UOM_" + FieldNameRe);

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


	function adjustRateInputs(oRadio, FormnameVar) {
		Rate_LB_Dis = true;
		Rate_CS_Dis = true;
		
		switch(oRadio.value){
			case "0":
				Rate_LB_Dis = true;
				Rate_CS_Dis = true;
			break;

			case "1":
				Rate_LB_Dis = false;
				Rate_CS_Dis = true;
			break;

			case "2":
				Rate_LB_Dis = true;
				Rate_CS_Dis = false;
			break;
		}
		eval("document.all.Rate_LB_" + FormnameVar + ".readOnly = "+Rate_LB_Dis);
		eval("document.all.Rate_CS_" + FormnameVar + ".readOnly = "+Rate_CS_Dis);
	}
	
	function colSelectFunc(radio){
		thisRadioCollection = eval("colSelect_" + radio.value);
		if(thisRadioCollection.length == null){
			thisRadioCollection.firstChild.checked=true;
			thisRadioCollection.firstChild.fireEvent("onclick");
		}
		
		else {
			for(var x=0; x<thisRadioCollection.length; x++)	{
				thisRadioCollection[x].firstChild.checked=true;
				thisRadioCollection[x].firstChild.fireEvent("onclick");
			}
		}
	}
</SCRIPT>


<cfif TheQuery.Recordcount LT 1>
	<strong>Select products</strong>
	<BR><BR>
	<CF_button
		button_name		=	""
		button_caption	=	"select products"
		button_action	=	"javascript: showProductSearchWindow();"
		button_type		=	"link"
		button_width	=	"100"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
	<BR>
</cfif>
<FORM ACTION="Contract_Discount_Bids.cfm?CID=<CFOUTPUT>#URL.CID#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm" STYLE="DISPLAY:INLINE;">
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
			<FONT COLOR="Red"><B>[ </B></FONT><A ONCLICK="ApplyAmountToSelectedBoxes()" STYLE="cursor: pointer;">apply price</A><FONT COLOR="Red"><B> ]</B></FONT>			
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
		button_type		=	"link"
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
		button_name		=	""
		button_caption	=	"select products"
		button_action	=	"javascript: showProductSearchWindow();"
		button_type		=	"link"
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
		button_name		=	""
		button_caption	=	"update rates"
		button_action	=	"document.all.MyForm.updateratesflag.value = 1; document.all.MyForm.submit();"
		button_type		=	"javascript_link"
		button_width	=	"100"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>	
</td>
<!--- this can be implemented when there is more time for development --->
<!---  <td width="110">
	<CF_button
		button_name		=	""
		button_caption	=	"volume"
		button_action	=	"NewWindow('Contract_Volume.cfm?Program_ID=#CSL_Contract_Main_ID#','name','850','650','Yes', 'Yes');"
		button_type		=	"javascript_link"
		button_width	=	"100"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>	
</td> --->
<td align="center">
<cfif application.returned_customer_setting.show_delivered EQ 1>

<FIELDSET STYLE="padding:none; width: 200px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Rate Type:</LEGEND>
	
	<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="left">
		<TR>
			<TD><INPUT NAME="Bid_Price_Rebate_Type" TYPE="Radio" VALUE="1" <CFIF CSLGetContractInfo.Bid_Price_Rebate_Type EQ 1> CHECKED</CFIF> <cfif trim(CSLGetContractInfo.Bid_Price_Rebate_Type) EQ "0">CHECKED</cfif>></TD>
			<TD>Delivered</TD>
			<TD><INPUT NAME="Bid_Price_Rebate_Type" TYPE="Radio" VALUE="2" <CFIF CSLGetContractInfo.Bid_Price_Rebate_Type EQ 2> CHECKED</CFIF>></TD>
			<TD>FOB</TD>
		</TR>
	</TABLE>
</FIELDSET>
<cfelse>
	<INPUT NAME="Bid_Price_Rebate_Type" TYPE="Hidden" VALUE="2">
</cfif>
</td>
<td align="center">

</td>
<td width="*" align="right">&nbsp;

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
		<TD ID="header" WIDTH="30"><NOBR><img bDelete="true" sMessage="delete all products in this page" src="/images/scissor.gif" alt="delete all products in this page" border="0" onclick="deleteAll('Bid_Price_Product_')" style="cursor: pointer;"></NOBR></TD>		
		<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD align="left" ID="header" WIDTH="50"><A HREF="#" OnClick="JavaScript: return sort_by_This('UPC');"><B>UPC</B></A></TD></cfif></cfif>
		<TD align="left" ID="header" WIDTH="50"><A HREF="#" OnClick="JavaScript: return sort_by_This('Item');"><B>Item #</B></A></TD>
		<TD align="left" ID="header" WIDTH="40%"><A HREF="#" OnClick="JavaScript: return sort_by_This('Description');"><B>Description</B></A></TD>
		<TD ID="header" WIDTH="100"><input TYPE="radio" NAME="colSelect" VALUE="1" ONCLICK="colSelectFunc(this);">&nbsp;<B>Rate Per LB</B></TD>
		<TD ID="header" WIDTH="100"><input TYPE="radio" NAME="colSelect" VALUE="2" ONCLICK="colSelectFunc(this);">&nbsp;<B>Rate Per CS</B></TD>
		<TD ID="header" NOWRAP><input TYPE="radio" NAME="colSelect"  VALUE="0" ONCLICK="colSelectFunc(this);">&nbsp;<b>Auto Rate</b></TD>
		<TD align="center" ID="header" WIDTH="20"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Products" checked></TD>
	</TR>
<CFOUTPUT QUERY="TheQuery">
	<CFSET FieldNameEnd = replace(TheQuery.BSA_Foodservice_Items_Master_ID,"-","_", "ALL")>

	<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> ONMOUSEOVER="menuID=6;URLstring='';an_ID='#TheQuery.BSA_Foodservice_Items_Master_ID#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;" ID="TR_Products" PRODUCT_ID_RE="#FieldNameEnd#" bDelete="0">
		<TD><img bDelete="true" name="IMG_Delete_Scissor" src="/images/scissor.gif" alt="click here to delete this product" border="0" onclick="deleteThisBidPrice('#FieldNameEnd#', '#TheQuery.BSA_FOODSERVICE_ITEMS_MASTER_ID#')" style="cursor: pointer;"></TD>			
		<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD NOWRAP>#TheQuery.UPC#</TD></cfif></cfif>
		<TD NOWRAP>#TheQuery.ITEM#</TD>
		<TD>#TheQuery.Description#</TD>
		
		<cfif not isdefined("FORM.Rate_LB_#FieldNameEnd#")><CFPARAM NAME="FORM.Rate_LB_#FieldNameEnd#" 	DEFAULT="#TheQuery.Rate_LB#"></cfif>
		<cfif not isdefined("FORM.Rate_CS_#FieldNameEnd#")><CFPARAM NAME="FORM.Rate_CS_#FieldNameEnd#" 	DEFAULT="#TheQuery.Rate_CS#"></cfif>
		<cfif not isdefined("FORM.Manual_Rate_Source_#FieldNameEnd#")><CFPARAM NAME="FORM.Manual_Rate_Source_#FieldNameEnd#" 	DEFAULT="#TheQuery.Manual_Rate_Source#"></cfif>
		
		<CFSET CurrentRate_LB = evaluate("FORM.Rate_LB_#FieldNameEnd#")>
		<CFSET CurrentRate_CS = evaluate("FORM.Rate_CS_#FieldNameEnd#")>
		<CFSET CurrentManualRateFlag = evaluate("FORM.Manual_Rate_Source_#FieldNameEnd#")>
		<cfif len(trim(CurrentManualRateFlag)) EQ 0><cfset CurrentManualRateFlag = 0></cfif>
		
		
		<cfset thisTypeID = evaluate("TheQuery.#application.returned_customer_setting.APPROVAL_CRITERIA_TABLE_ID#")>
		<cfset tempRuleData = getTypeUOM(thisTypeID)>
		
		<CFIF listfindnocase(listGetValidProductsWithVolume, TheQuery.BSA_Foodservice_Items_Master_ID) EQ 0>
			<TD COLSPAN="4" ALIGN="center">
				<span STYLE="color: red; font-weight: bold;">You must first assign a volume to this product</span>
				<INPUT TYPE="Hidden" NAME="Manual_Rate_Source_#FieldNameEnd#" VALUE="0">
				<INPUT TYPE="Hidden" NAME="Rate_LB_#FieldNameEnd#" VALUE="">
				<INPUT TYPE="Hidden" NAME="Rate_CS_#FieldNameEnd#" VALUE="">
			</TD>
		<CFELSE>
			<TD><SPAN ID="error_Price_#FieldNameEnd#"></SPAN>
				<span ID="colSelect_1"><INPUT NAME="Manual_Rate_Source_#FieldNameEnd#" TYPE="Radio" VALUE="1" ONCLICK="adjustRateInputs(this, '#FieldNameEnd#');" <cfif CurrentManualRateFlag EQ 1> CHECKED</cfif>></span>$<INPUT <cfif CurrentManualRateFlag NEQ 1> READONLY</cfif> TYPE="text" NAME="Rate_LB_#FieldNameEnd#" SIZE="5" VALUE="<CFIF len(CurrentRate_LB) EQ 0>#trim(numberformat(0, '__.___'))#<CFELSE>#trim(numberformat(CurrentRate_LB, '__.___'))#</CFIF>" ONKEYUP="formatRate(this,'#FieldNameEnd#')" onblur="formatRate(this,'#FieldNameEnd#', 1)">
			</TD>
			<TD><SPAN ID="error_Price_#FieldNameEnd#"></SPAN>
				<span ID="colSelect_2"><INPUT NAME="Manual_Rate_Source_#FieldNameEnd#" TYPE="Radio" VALUE="2" ONCLICK="adjustRateInputs(this, '#FieldNameEnd#');" <cfif CurrentManualRateFlag EQ 2> CHECKED</cfif>></span>$<INPUT <cfif CurrentManualRateFlag NEQ 2> READONLY</cfif> TYPE="text" NAME="Rate_CS_#FieldNameEnd#" SIZE="5" VALUE="<CFIF len(CurrentRate_CS) EQ 0>#trim(numberformat(0, '__.___'))#<CFELSE>#trim(numberformat(CurrentRate_CS, '__.___'))#</CFIF>" ONKEYUP="formatRate(this,'#FieldNameEnd#')" onblur="formatRate(this,'#FieldNameEnd#', 2)">
			</TD>
			<TD><span ID="colSelect_0"><INPUT NAME="Manual_Rate_Source_#FieldNameEnd#" TYPE="Radio" VALUE="0" ONCLICK="adjustRateInputs(this, '#FieldNameEnd#');" <cfif CurrentManualRateFlag EQ 0> CHECKED</cfif>></span></TD>
			<TD align="center"><span ID="checkBoxCollection"><INPUT type="Checkbox" NAME="Bid_Price_Product_#FieldNameEnd#" APPLYMASSRATE="Bid_Price_Value_#FieldNameEnd#" VALUE="#FieldNameEnd#" checked></span></TD>
		</CFIF>
		</TR>
</CFOUTPUT>

</TABLE>

<BR>


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

</cfif>

<cfquery name="getBidRUleGroups" datasource="#application.datasource#">
SELECT     dbo.Bid_Rule_Items.Type_Item_ID
FROM         dbo.Bid_Rules INNER JOIN
                      dbo.Bid_Rule_Items ON dbo.Bid_Rules.Bid_Rule_ID = dbo.Bid_Rule_Items.Bid_Rule_ID
WHERE     (dbo.Bid_Rules.Deleted = 0) AND (dbo.Bid_Rule_Items.Deleted = 0)
</cfquery>


<INPUT TYPE="hidden" NAME="ProductCount" VALUE="<CFOUTPUT>#TheQuery.Recordcount#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="Contract_Main_ID" VALUE="<CFOUTPUT>#FORM.Contract_Main_ID#</CFOUTPUT>">
<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="Sort_By" 			VALUE="#URL.Sort_By#">
	<INPUT TYPE="Hidden" NAME="Program_ID" 			VALUE="#URL.CID#">
	<INPUT TYPE="Hidden" NAME="Product_List" 		VALUE="#valuelist(TheQuery.BSA_Foodservice_Items_Master_ID)#">
	<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="#valuelist(TheQuery.BSA_Foodservice_Items_Master_ID)#">
	<INPUT TYPE="Hidden" NAME="DTPS_On" 			VALUE="1">
	<INPUT TYPE="Hidden" NAME="DTPS_Program_ID" 	VALUE="#FORM.Contract_Main_ID#">
	<INPUT TYPE="Hidden" NAME="Bid_Rule_In_Effect"  VALUE="1">
	<INPUT TYPE="Hidden" NAME="updateratesflag" 	VALUE="#FORM.updateratesflag#">	
	<input type="Hidden" name="Only_Show_Products_From_These_Groups" value="#valuelist(getBidRUleGroups.Type_Item_ID)#">
	</CFOUTPUT>
</FORM>
</BLOCKQUOTE></BLOCKQUOTE>

<FORM ACTION="Contract_Discount_Bid_Prices_save_products_Action.cfm" METHOD="post" NAME="SaveProgramProducts" ID="SaveProgramProducts">
	<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="Sort_By" 			VALUE="#URL.Sort_By#">
	<INPUT TYPE="Hidden" NAME="Product_List" 		VALUE="#valuelist(TheQuery.BSA_Foodservice_Items_Master_ID)#">
	<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="#valuelist(TheQuery.BSA_Foodservice_Items_Master_ID)#">
	<INPUT TYPE="Hidden" NAME="DTPS_On" 			VALUE="1">
	<INPUT TYPE="Hidden" NAME="DTPS_Program_ID" 	VALUE="#FORM.Contract_Main_ID#">
	</CFOUTPUT>
</FORM>

<form>

</form>
<cfif application.programlayout EQ 1></div></cfif>

<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
<SCRIPT>
		function showProductSearchWindow() {
			NewWindow("product_Select_V1.cfm?Formname=MyForm&Discountype=9", "productwindow", 800, 600, "yes", "yes")			
		}
</SCRIPT>


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
			gUOM = document.all.Global_UOM.selectedIndex;
			
			if(document.all.UOMCollection != null){
				if(UOMCollection.length != null){
					for(var x = 0; x<UOMCollection.length;x++){
						UOMCollection[x].firstChild.selectedIndex = gUOM;
						UOMCollection[x].firstChild.fireEvent("onchange")
					}
				}
				else{
					UOMCollection.firstChild.selectedIndex = gUOM;
					UOMCollection.firstChild.fireEvent("onchange")
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
