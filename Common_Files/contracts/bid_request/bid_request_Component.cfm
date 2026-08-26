

<CFPARAM NAME="URL.CID" DEFAULT="">
<cfparam name="form.Bidrequest_Component_Paid_To" default="">
<cfparam name="donotallowaddproductsDE" default = "0">
<cfparam name="form.deletedateexclusions" default = "0">
<cfparam name="url.EZTemplate" default="0">
<cfparam name="form.Program_Bidrequest_Component_Name_ID_Selection_Validated" default="0">

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
	<cfset useLakebaseForGetContractInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetContractInfo>
	<cftry>
		<cfset GetContractInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#cryp.value#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetContractInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetContractInfo>
<cfquery name="GetContractInfo" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Main
		WHERE Contract_Main_ID = '#cryp.value#'
	</cfquery>
</cfif>
	<!--- Do not show the tabs if the contract is approved --->
	<CFIF GetContractInfo.Contract_Status_Type_IDX GT 2>
		<script>
			history.back();
		</script>
		<CFABORT>
	</CFIF>	
</CFIF>

<CFSET PAGE_TITLE= "Product Proposal Component Creation">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/common_files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT SRC="/billbacks/common/common_js_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/Queue.js"></SCRIPT>

<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif url.EZTemplate EQ 0>
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "bid request"> 
<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>
<cfparam name="bIsIndirectBid" default="0">
<cfparam name="URL.Sort_By" 	default="Item">

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />

<!---get bid request spec list--->
<cfset bidRequestSpec = CreateObject("component", "components.programs.bid_request.BidRequestSpec") />
<cfset qGetBidSpec = bidRequestSpec.getBidRequestSpec() />

<cfset bidRequestProdMan = CreateObject("component", "components.programs.bid_request.BidRequestProductManager") />
<cfif appSettings.getBidRequestUsePriceByDate() EQ 1>
<cfset bIsIndirectBid = bidRequestProdMan.checkIndirectBid(form.contract_main_id) />
</cfif>

<!---initialize the OperatorManager--->
<cfset OperatorManager = CreateObject("component", "components.programs.operators.OperatorManager") />
<cfset operatorIds = OperatorManager.getProgramOperatorIds(form.contract_main_id) />
<cfset form.operatorList = operatorIds.getLOperatorIds() />

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

<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 5; left: 10px; top: 0px">
  <CFINCLUDE TEMPLATE="/common_files/contracts/contract_status_legend.cfm"></div>
<cfelse>
<CFINCLUDE TEMPLATE="/common_files/contracts/contract_status_legend.cfm">
</cfif>

<CF_CRYP type="de" string="#CID#" key="#request.key#">

<cfset DiscountType = 1>
<!--- If the program is a revision and revision settings has retrictions for this program --->
<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1>
	<cfif Not IsDefined("ProgramManager")>
		<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>
	</cfif>
	
	<cfif NOT IsDefined("ParentprogramInfo")>
		<cfset ParentprogramInfo = ProgramManager.getParentProgramInfo(cryp.value)>
	</cfif>
	
	<cfif NOT IsDefined("ProgramProducts")>
		<cfset ProgramProducts = CreateObject("component", "components.products.products")/>
	</cfif>
	
	<cfif NOT IsDefined("bidRequestProdMan")>
		<cfset bidRequestProdMan = CreateObject("component", "components.programs.bid_request.BidRequestProductManager") />
	</cfif>
	
	<cfif NOT IsDefined("getProgramProducts")>
		<!--- <cfset getProgramProducts = ProgramProducts.getproducts('',DiscountType,ParentProgramInfo.Revision_of_Contract_main_id)> --->
		<cfset getProgramProducts = bidRequestProdMan.Get_Bidrequest_Products(ParentProgramInfo.Revision_of_Contract_main_id)>
	</cfif>
	
	<cfset ProductItemList = queryNew("")>
	
	<cfif getProgramProducts.recordcount neq 0>
		<cfset ProductItemList = ValueList(getProgramProducts.BSA_Foodservice_Items_Master_ID)>
	<cfelse>
		<cfset ProductItemList = "NULL">
	</cfif>
<cfelse>
	<!--- to avoid an error --->
	<cfset ProductItemList = queryNew("")>
	<cfset ProductItemList = "NULL">
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

<CFSET AllowNullInComponent = appSettings.getProgram_Allow_Null_Rate()>
<CFSET HideProductList = 1>
<cfoutput>	
	<script language="JavaScript">		
	<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
		var maxComponentPossible = 1;
		<cfelse>
		var maxComponentPossible = #appSettings.getRebateMaxComponents()#;
	</cfif>
	</script>
</cfoutput>
<CFSET helpfilenumber=7>
<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:2; left: 60px; top: 0px;"> </cfif>
<cfif url.EZTemplate EQ 0>
<cfinclude template="/common_files/contracts/minimal_contract_info.cfm">
</cfif>
<CFQUERY NAME="getProgramInfo" datasource="#application.datasource#">
SELECT     dbo.Units_of_Measure.Unit_Of_Measure_Desc, dbo.Units_of_Measure.Abbreviation, dbo.Contract_Main.Contract_Quantity, contract_main.Contract_Quantity_UOM_IDX
FROM         dbo.Contract_Main INNER JOIN
                      dbo.Units_of_Measure ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID
	WHERE dbo.Contract_Main.Contract_Main_ID = '#FORM.Contract_Main_ID#' 
</CFQUERY>

<cfif NOT isDefined("form.BidrequestComponentList")>
<cfset getAllBidrequestComponents = bidRequestProdMan.getAllBidrequestComponents(form.contract_main_id)>
<CFSET form.BidrequestComponentList =  ValueList(getAllBidrequestComponents.Bidrequest_Component_Id)>
</cfif>

<cfif isdefined("form.Program_Bidrequest_Component_Name_Id") 
		AND form.Program_Bidrequest_Component_Name_Id NEQ '-1'
		AND form.Program_Bidrequest_Component_Name_ID_Selection_Validated EQ "1">
	
	<CFSET form.BidrequestComponentList = ListAppend(form.BidrequestComponentList, #form.Program_Bidrequest_Component_Name_Id# & "_" & #form.Bidrequest_Component_Paid_to#)>
	
	<cfif isDefined("form.rate") AND isDefined("form.product_list") AND isDefined("form.uom")>
		<cfloop list="#form.product_list#" index="prodid">
			<cfset "form.Bidrequest_C#form.Program_Bidrequest_Component_Name_Id#_P#replace(prodid, "-", "_", "ALL")#_#ListLen(form.BidrequestComponentList)#_rate" = #form.rate#>
	<cfset "form.Bidrequest_C#form.Program_Bidrequest_Component_Name_Id#_P#replace(prodid, "-", "_", "ALL")#_#ListLen(form.BidrequestComponentList)#_uom" = #form.uom#>
		</cfloop>
	</cfif>
</cfif>


<cfparam name="Bidrequest_Comp_ids" default="">
<cfif isdefined("form.BidrequestComponentList")>
	<cfloop list="#form.BidrequestComponentList#" index="i">
		<cfset comp_id_start = Find("_",i)>
		<cfset Bidrequest_Comp_ids = ListAppend(Bidrequest_Comp_ids,Left(#i#, comp_id_start - 1),",")>
	</cfloop>
</cfif>


<cfset getBidrequestComponents = bidRequestProdMan.getBidrequestComponents(form.contract_main_id,Bidrequest_Comp_ids)>

<CFIF NOT isdefined("form.product_list")>
	<cfset Get_Bidrequest_Products = bidRequestProdMan.Get_Bidrequest_Products(form.contract_main_id)>
	<CFSET FORM.Product_List = ValueList(Get_Bidrequest_Products.BSA_Foodservice_Items_Master_ID, ",")>
</CFIF>
<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1 or GetSettings.display_basesales_Competitive_Data EQ 1>
	<cfset displaybasesales = 1>
<cfelse>
	<cfset displaybasesales = 0>
</cfif>

<cfset TheQuery = bidRequestProdMan.getBidRequestProducts(form.contract_main_id,Bidrequest_Comp_ids,form.Product_List,sql_Sort_By,GetSettings.Include_Competitive_Data_Tracking,displaybasesales)>

<cfif getsettings.EZButton_On EQ 1 and URL.EZTemplate EQ 0>
	<cfset EzButton_Disable = 1>
<cfelse>
	<cfset EzButton_Disable = 0>
</cfif>

<cfif EzButton_Disable EQ 1>
<cfset EZProgramManager = CreateObject("component", "components.programs.EZButton_programManager") />	
<cfset GetEZButtonDefaultRates = EZProgramManager.getBidrequestEZSettings(getsettings.EZ_Contract_Id,FORM.Product_List,Bidrequest_Comp_ids)>
</cfif>

<!--- <cfdump var="#TheQuery#"> --->

<!--- <CFSET FORM.Product_List = ValueList(TheQuery.BSA_Foodservice_Items_Master_ID, ",")> --->

<cfscript>
	function buildFixedInputName(compId, pId, iI, sSuffix)
	{
		return "Bidrequest_C" & compId & "_P" & replace(pId, "-", "_", "ALL") & "_" & iI & sSuffix;
	}
	
	function buildFixeddocumentName(compId, pId, iI, sSuffix)
	{
		return "document.all.Bidrequest_C" & compId & "_P" & replace(pId, "-", "_", "ALL") & "_" & iI & sSuffix & ".value";
	}
	
	function buildSecondInputName(compId, pId, iI, sSuffix)
	{
		return "document.all.Bidrequest_C" & compId & "_P" & replace(pId, "-", "_", "ALL") & "_" & iI & sSuffix;
	}
	
	
</cfscript>

<SCRIPT>
	var my_queue = new Queue();
	function deleteComponent(component_id, name) {
		if(confirm("Do you really want to delete " + name + "?")){
			document.all.comDeleteForm.Component_ID.value = component_id;
			document.all.comDeleteForm.submit();
		}

	}
	
		function showProductSearchWindow() {
			 document.all.Program_Bidrequest_Component_Name_ID.value = "-1";
			 NewWindow("/common_files/contracts/product_Select_V1.cfm?Formname=BidrequestComponents&Discountype=10&EZTemplate=<cfoutput>#url.EZTemplate#</cfoutput>", "productwindow", 800, 600, "yes", "yes", true)			
		}
		
		var startDataCol = 3;
		<cfif application.returned_customer_setting.upc_switch EQ 0>
			startDataCol = startDataCol - 1;
		</cfif>
		
		function deleteThisFixedPrice(FieldNameRe, prodID)
	{	
		var srcObj = event.srcElement;
		var trObj = getParentObject(srcObj, "tr");
		var trIndex = trObj.rowIndex;
		var FINALITEMLIST = document.BidrequestComponents.Product_List.value;
		var resultString = ListDeleteItem(FINALITEMLIST, ",", prodID);
		var bDelete = true;
				
		if(resultString == FINALITEMLIST)
		{
			resultString = ListAppendItem(FINALITEMLIST, ",", prodID);
			bDelete = false;
		}
		
		document.all.Product_List.value = resultString;
		document.all.ExistingProductList.value = resultString;
		var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";	
		if(trObj)
		{			
			if(bDelete)
			{ 
				trObj.height = trObj.offsetHeight;
				
				trObj.cells[trObj.cells.length-1].innerHTML = empty_String;
				
				<cfset CompLen = ListLen(form.Bidrequestcomponentlist)>
				for (i=1; i<=<cfoutput>#CompLen#</cfoutput>; i++)
				{
				disableDiv(trObj.cells[i+startDataCol], true, false);
				}
				
				propogateProperty(trObj, "style.backgroundColor", "#DDDDDD", false);
				propogateProperty(trObj, "style.textDecoration", "line-through", true);				
				
				srcObj.title = "undo product deletion";
				srcObj.src = undodeleteImg.src;
				//resetnavigate();
				
			
			}
			else
			{
				
				<cfset CompLen = ListLen(form.Bidrequestcomponentlist)>
				for (i=1; i<=<cfoutput>#CompLen#</cfoutput>; i++)
				{
				disableDiv(trObj.cells[i+startDataCol], false, false);
				}
				var bgCol = "FFFFFF";
				if(trObj.rowIndex % 2 == 1)
				{
					bgCol = "C6FFC6";
				}
				propogateProperty(trObj, "style.backgroundColor", bgCol, false);
				propogateProperty(trObj, "style.textDecoration", "none", false);
				
				srcObj.title = "delete this product";
				srcObj.src = deleteImg.src;
				
				propogateProperty(trObj, "style.backgroundColor", "FFFFFF", false, true);
			}
			srcObj.bDelete = !bDelete;
			trObj.bDelete = (bDelete?1:0);
		}		
		
	}

		
	function submitForm()
	{
		ErrorCount = 0;
		<cfset complen = ListLen(form.BidrequestComponentList)>
		<cfset prodlen = ListLen(form.Product_List)>
		/* Initial Count */
		var ExistsComponent = 0;
		/*ID passed to javascript */
		var PassedNumber;
		
		/* Dont let the user add the same component more than twice */
		<cfloop list="#form.BidrequestComponentList#" index="BidRequestComponentID">
			//existing comp id and paid to
			var thisCompId = <cfoutput>"#Left(BidRequestComponentID,(Find("_",BidRequestComponentID)-1))#"</cfoutput>;
			var thisPaidTo = <cfoutput>#Mid(BidRequestComponentID,(Find("_",BidRequestComponentID)+1),len(BidRequestComponentID))#</cfoutput>;
			//comp id and paid to being selected
			//comp id and paid to being selected
			var selCompId = document.all.Program_Bidrequest_Component_Name_ID.value;
			//figure out which paid to is selected
			var selPaidTo = 0;
			collObjects = document.getElementsByName("Bidrequest_Component_Paid_To");
			for (var i = 0; i<collObjects.length; i++)
			{
				if(collObjects[i].checked)
					selPaidTo = collObjects[i].value;
			}
			if(selCompId == thisCompId)
			{
				PassedNumber = parseInt(document.all.Program_Bidrequest_Component_Name_ID.value);
				ExistsComponent = parseInt(ExistsComponent) + PassedNumber;
				/* Divide the Passed SelectedIndex ID by the previously Selected Number (Chosen twice) */
				if(document.all.Program_Bidrequest_Component_Name_ID.value == ExistsComponent/2)
				{
					alert("You cannot add the same component more than twice.");
					return false;
				}
				//if this component/paid to combination alrady exists then show alert and don't submit
				if (thisPaidTo == selPaidTo)
				{
					alert("A component with this Paid To already exists. Please change the Paid To or select another component.");
					return false;
				}
			}
		</cfloop>

if (<cfoutput>#prodlen#</cfoutput> == 0)
		{
		alert("You must select products before adding components");
		return false;
		}
				
		if (<cfoutput>#compLen#</cfoutput> >= maxComponentPossible)
		{
			ErrorCount++;
			queueMessage("No more than " + maxComponentPossible + " component(s) may be applied.", document.all.error_component);
		}
		else
			{
				clearQueue(document.all.error_component);
			if(document.all.Program_Bidrequest_Component_Name_ID.value == "-1")
				{
					ErrorCount++;
					queueMessage("You must select at least one component.", document.all.error_component);
		}
				else
				{
					clearQueue(document.all.error_component);
				}
			if(document.all.rate.value == "")
			{
				ErrorCount++;
				queueMessage("You must enter a rate for the component.", 			document.all.error_rate);
			}
			else
				{	clearQueue(document.all.error_rate); }
		}
			if(ErrorCount == 0) 
			{
				document.all.Program_Bidrequest_Component_Name_ID_Selection_Validated.value = 1;
				document.BidrequestComponents.submit();
			}
			else 
			{
				showMessageWindow();
			}	
	}
	
	
	function verifyDelete(component_id, component_name,position) {
		 document.all.Program_Bidrequest_Component_Name_ID.value = "-1";
		if(confirm("Are you sure you want to delete " + component_name + "?")) {
			var FINALCOMPLIST = document.all.BidrequestComponentList.value;
			
			var resultString;
			resultString = ListDeleteAt(FINALCOMPLIST, ",", position);
			document.all.BidrequestComponentList.value = resultString;
			document.all.DeletedComponentPosition.value = position+1;
			document.all.BidrequestComponents.submit();
		}
	}
	
	function adjustdiscount(compprodId,prodId)
	{
		var defaultCSPrice = eval("document.all." + prodId + "_Price_CS.value");
		var defaultLBPrice = eval("document.all." + prodId + "_Price_LB.value");
		var fixedpricevalue = eval("document.all." + compprodId + "_rate.value");
		var fixeduomvalue = eval("document.all." + compprodId + "_uom.value");
		var PDiscountPercent = eval(compprodId + "_DP");
		var PDiscount = eval(compprodId + "_D");
	
		if (fixeduomvalue == 1)
		{
		PDiscount.innerText = '$ ' + formatToDeciamalPlaces((defaultCSPrice - fixedpricevalue),4);
			if (defaultCSPrice != 0)
			{
			PDiscountPercent.innerText = formatToDeciamalPlaces(((defaultCSPrice - fixedpricevalue)/defaultCSPrice) * 100,2) + "%";
			}
			else
			{
			PDiscountPercent.innerText = formatToDeciamalPlaces(0,2) + "%";
			}
		}
		else if (fixeduomvalue == 2)
		{
		PDiscount.innerText = '$ ' + formatToDeciamalPlaces((defaultLBPrice - fixedpricevalue),4);
			if (defaultLBPrice != 0)
			{
			PDiscountPercent.innerText = formatToDeciamalPlaces(((defaultLBPrice - fixedpricevalue)/defaultLBPrice) * 100,2) + "%";
			}
			else
			{
			PDiscountPercent.innerText = 0;
			}
		}
	}
	function openPopup(url, winW, winH) 
	{
		var windowWidth = 200;
		var windowHeight = 210;
		
		if(winW)
		{
			windowWidth = winW;
		}
		if(winH)
		{
			windowHeight = winH;
		}
		var w = 640/3;
		var h = 480/3;
		var cw = w/2;
		var ch = h/2;

		if (window.screen) 
		{
			w = Math.floor(screen.availWidth/3);
    		h = Math.floor(screen.availHeight/3);
    		cw = Math.floor((screen.availWidth-w)/2);
    		ch = Math.floor((screen.availHeight-h)/2);
		}
		
    	myPopup = window.open(url,'popupWindow','resizable=yes,width='+windowWidth+',height='+windowHeight+',top='+ch+',left='+cw);
    	if (!myPopup.opener)
        	myPopup.opener = self; 
	}
</SCRIPT>

<CF_MessageWindow>
<cfif NOT isDefined("FORM.FirstTime")>
<cfoutput query="Thequery" group="BSA_Foodservice_Items_Master_ID">

<cfset i =1>
<cfoutput>
	<cfparam name="form.Bidrequest_C#Program_Bidrequest_Component_Name_Id#_P#replace(Thequery.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#_#i#_rate" default="#Bidrequest_Price_Value#">
	<cfparam name="form.Bidrequest_C#Program_Bidrequest_Component_Name_Id#_P#replace(Thequery.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#_#i#_uom" default="#Unit_Of_Measure_ID#">

<cfset i = i+1>
</cfoutput>

</cfoutput>
</cfif>


<cfif isDefined("FORM.FirstTime")>
<cfparam name="Form.DeletedComponentPosition" default="0">
<cfloop list="#Form.Product_List#" index="productId">
	<cfset anyDeleted = 0>
	<cfloop from="1" to="#ListLen(Bidrequest_Comp_ids)#" index="i">
	
	<cfset sInputRate1 = buildFixedInputName(ListGetAt(Bidrequest_Comp_ids,i), productId, i, "_rate") >		
	<cfset sInputUom1 = buildFixedInputName(ListGetAt(Bidrequest_Comp_ids,i), productId, i, "_uom") >	


	<cfset sInputRate2 = buildFixedInputName(ListGetAt(Bidrequest_Comp_ids,i), productId, i+1, "_rate") >	
	<cfset sInputUom2 = buildFixedInputName(ListGetAt(Bidrequest_Comp_ids,i), productId, i+1, "_uom") >

	<cfif Form.DeletedComponentPosition EQ i>
		<cfset anyDeleted = 1>
	</cfif>

	<cfif anyDeleted>
		<cfparam name="form.#sInputRate1#" default="">	
		<cfparam name="form.#sInputUom1#" default="">
		<cfset "form.#sInputRate1#" = Evaluate("form.#sInputRate2#")>
		<cfset "form.#sInputUom1#" = Evaluate("form.#sInputUom2#")>
	<cfelse>
		<cfparam name="form.#sInputRate1#" default="">	
		<cfparam name="form.#sInputUom1#" default="">	
	</cfif>
	
	</cfloop>
</cfloop>
</cfif>

<cfparam name="Min_Bidrequest_Case" default="">
<cfparam name="Max_Bidrequest_Case" default="">
<cfparam name="Min_Bidrequest_Pound" default="">
<cfparam name="Max_Bidrequest_Pound" default="">
<cfparam name="ThereisMinorMax" default="0">

<!---Sets min and max values if they exist for the profile--->
<cfif len(trim(getSettings.Min_Bidrequest_Case)) IS NOT 0>
	<cfset Min_Bidrequest_Case = getSettings.Min_Bidrequest_Case>
	<cfset ThereisMinorMax = 1>
</cfif>
<cfif len(trim(getSettings.Max_Bidrequest_Case)) IS NOT 0>
	<cfset Max_Bidrequest_Case = getSettings.Max_Bidrequest_Case>
	<cfset ThereisMinorMax = 1>
</cfif>
<cfif len(trim(getSettings.Min_Bidrequest_Pound)) IS NOT 0>
	<cfset Min_Bidrequest_Pound = getSettings.Min_Bidrequest_Pound>
	<cfset ThereisMinorMax = 1>
</cfif>
<cfif len(trim(getSettings.Max_Bidrequest_Pound)) IS NOT 0>
	<cfset Max_Bidrequest_Pound = getSettings.Max_Bidrequest_Pound>
	<cfset ThereisMinorMax = 1>
</cfif>


<SCRIPT>
function verifyData()
{
	
	var Errcount = 0;
	var FatalErr = 0;
	var srcObj = event.srcElement;
	var allowNull = "<CFOUTPUT>#AllowNullInComponent#</CFOUTPUT>";

	<cfloop list="#form.Product_List#" index="prod">
	<cfloop from="1" to="#ListLen(Bidrequest_Comp_ids)#" index="compid">
		<cfset InputRate1 = buildFixeddocumentName(ListGetAt(Bidrequest_Comp_ids,compid), prod, compid, "_rate") >	
		<cfset InputRate2 = buildFixedInputName(ListGetAt(Bidrequest_Comp_ids,compid), prod, compid, "_rate") >	
		<cfset InputUOM   = buildFixeddocumentName(ListGetAt(Bidrequest_Comp_ids,compid), prod, compid, "_uom") >	
		<cfoutput>
		var InputObj = eval("#buildSecondInputName(ListGetAt(Bidrequest_Comp_ids,compid), prod, compid, "_rate")#") 
		</cfoutput>
		
		var spanObj = document.getElementById("SPAN_" + <cfoutput>'#InputRate2#'</cfoutput>);
		propogateProperty(spanObj, "style.backgroundColor", "white", false);
		
		if(<cfoutput>#InputRate1#</cfoutput> == "")
		{
			propogateProperty(spanObj, "style.backgroundColor", "#CC99FF", false);
			Errcount++;
		}
		
		<cfif ThereisMinorMax IS 1>
		<!---Pounds first--->
		if((<cfoutput>#InputUOM#</cfoutput> == 2) && (<cfoutput>#InputRate1#</cfoutput> != "") && (InputObj.disabled == false))
		{	<!--- alert(InputObj.disabled) --->
			<Cfif len(trim(Min_Bidrequest_Pound)) IS NOT 0>
			<!---Pounds Min--->
			if(<cfoutput>#InputRate1#</cfoutput> < <cfoutput>#Min_Bidrequest_Pound#</cfoutput>)
			{
				propogateProperty(spanObj, "style.backgroundColor", "yellow", false);
				FatalErr++
			}
			</cfif>
			
			<Cfif len(trim(Max_Bidrequest_Pound)) IS NOT 0 AND Max_Bidrequest_Pound IS NOT 0>
			<!---Pounds Max--->
			if(<cfoutput>#InputRate1#</cfoutput> > <cfoutput>#Max_Bidrequest_Pound#</cfoutput>)
			{
				propogateProperty(spanObj, "style.backgroundColor", "red", false);
				FatalErr++
			}
			</cfif>
		
		}
		
		<!---Cases--->
		if((<cfoutput>#InputUOM#</cfoutput> == 1) && (<cfoutput>#InputRate1#</cfoutput> != "") && (InputObj.disabled == false))
		{
			<Cfif len(trim(Min_Bidrequest_Case)) IS NOT 0>
			<!---Pounds Min--->
			if(<cfoutput>#InputRate1#</cfoutput> < <cfoutput>#Min_Bidrequest_Case#</cfoutput>)
			{
				propogateProperty(spanObj, "style.backgroundColor", "yellow", false);
				FatalErr++
			}
			</cfif>
			
			<Cfif len(trim(Max_Bidrequest_Case)) IS NOT 0 AND Max_Bidrequest_Case IS NOT 0>
			<!---Pounds Max--->
			if(<cfoutput>#InputRate1#</cfoutput> > <cfoutput>#Max_Bidrequest_Case#</cfoutput>)
			{
				propogateProperty(spanObj, "style.backgroundColor", "red", false);
				FatalErr++
			}
			</cfif>
		
		}
		
		</cfif>
	</cfloop>
	</cfloop>

	if((Errcount == 0 || allowNull == 1) && FatalErr == 0)
	{
		var complistlen = <cfoutput>#ListLen(Bidrequest_Comp_ids)#</cfoutput>;
		var prodlenlist;
		if(document.BidrequestComponents.Product_List.value == "")
		{
			prodlenlist = 0; 
		}
		else 
		{
			prodlenlist = listLength(document.BidrequestComponents.Product_List.value,",");
		} 
	
		if((complistlen > 0 && prodlenlist > 0) ||(complistlen == 0 && prodlenlist == 0))
		{
			{
				<cfif donotallowaddproductsDE EQ 1>
					if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
				{ document.all.deletedateexclusions.value = 1;</cfif>
				var actionpage;
				actionpage = "contract_Bidrequest_Component_save.cfm";
				document.BidrequestComponents.action = actionpage;
				if (allowNull == 1 && Errcount != 0)
				{
					if (confirm("The rate of highlighted products is NULL. Press OK to SAVE them."))
					{
						disableButton("save_table", true, false);
						document.BidrequestComponents.submit();
					}
				}
				else
				{
					disableButton("save_table", true, false);
					document.BidrequestComponents.submit();
				}
				
				<cfif donotallowaddproductsDE EQ 1>} else {
					return false;
				}</cfif>
			}
		}
		else
		{
			if(complistlen == 0)
			{
				alert("Please select at least one component to save");
			}
			else if(prodlenlist == 0)
			{ 
				alert("Please select at least one product to save");
			}
		}
	}
	else
	{
		if (FatalErr > 0)
		{
			alert("Fields highlighted yellow are below the minimum value. Fields highlighted red are above the maximum. ");
			return;
		}
		else
		{
			alert("Please enter rate for these products");
			return;
		}
	}
}
	
	function checkAllProd()
	{
		<cfloop list="#Form.Product_List#" index="product_id">
		<cfset prod_id = replace(product_id,"-","_", "ALL")>
		<cfset prod_check = "Prod_"&#prod_id#>
		if(document.all.prodCheck.checked)
		{
		document.all.<cfoutput>#prod_check#</cfoutput>.checked = true;
		}
		else
		{
		document.all.<cfoutput>#prod_check#</cfoutput>.checked = false;
		}
		</cfloop>
	}

	function applyrate()
	{
	var prodchecked = false;
	var compchecked = false;
	<cfloop list="#Form.Product_List#" index="product_id">
		<cfset prod_id = replace(product_id,"-","_", "ALL")>
		<cfset prod_check = "Prod_"&#prod_id#>
		if(document.all.<cfoutput>#prod_check#</cfoutput>.checked)
		{
			prodchecked = true;
			
		}
	</cfloop>
	
	<cfset listcount = 0>
	<cfloop list="#Bidrequest_Comp_ids#" index="comp_name_id">
		<cfset comp_check = "Comp_"&#comp_name_id#&"_"&#listcount#>
		if(document.all.<cfoutput>#comp_check#</cfoutput>.checked)
		{
			compchecked = true;
			
		}
	<cfset listcount = listcount + 1>
	</cfloop>
	
	if((!prodchecked) && (!compchecked))
	{alert("Please select a component and products.")}
	else if(!prodchecked)
	{ alert("Please select products."); }
	else if(!compchecked)
	{ alert("Please select a component."); }
	else 
	{ 
	
	
	<cfset compcount = 0>
	<cfloop from="1" to="#ListLen(Bidrequest_Comp_ids)#" index="compposition">
	<CFSET comp_name_id = ListGetAt(Bidrequest_Comp_ids,compposition)>
		<cfset comp_check = "Comp_"&#comp_name_id#&"_"&#compcount#>
		if(document.all.<cfoutput>#comp_check#</cfoutput>.checked)
		{
			<cfloop list="#Form.Product_List#" index="product_id">
				<cfset prod_id = replace(product_id,"-","_", "ALL")>
				<cfset prod_check = "Prod_"&#prod_id#>
				if(document.all.<cfoutput>#prod_check#</cfoutput>.checked)
				{
					<cfset NewInputRate = buildFixeddocumentName(comp_name_id, product_id, compposition, "_rate") >
					<CFSET NewUomRate = buildFixeddocumentName(comp_name_id, product_id, compposition, "_uom") >
					if(document.all.apply_rate.value != "" || document.all.apply_rate.value != 0)
{	<cfif NOT(Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2)>
	<cfoutput>#NewInputRate#</cfoutput> = document.all.apply_rate.value; 		
	</cfif>		}
	<cfif NOT(Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_UOM_Changes eq 2)>
		changeUOMTo(<cfoutput>#NewUomRate#</cfoutput>, document.all.apply_uom.value);
	</cfif>
				}
				</cfloop>
		}
	<CFSET compcount = compcount + 1>
	</cfloop>
	}
	}
	function changeUOMTo(selObj, selValue)
		{
			var optObj = Get_Object_Property_Match_Collection(selObj.options, "value", selValue)
			if(optObj)
			{
				optObj.selected = true;
				selObj.fireEvent("onchange");
				//?resetnavigate();
			}
		}	
</SCRIPT>
<CFOUTPUT><FORM ACTION="Bid_request_Component.cfm?CID=#URL.CID#&EZTemplate=#url.EZTemplate#" METHOD="post" NAME="BidrequestComponents" ID="BidrequestComponents" style="display:inline" onSubmit="disableButton('save_table', true, false);"></CFOUTPUT>
<table width="800"><tr><td align="left"><strong>1. Add a Bid Fixed Component</td>
<td align="right"><cfif ListLen(form.operatorList) gt 0 and ListLen(form.operatorList) lte 10>
			<span style="text-align:right">	<FONT SIZE="2">
					<B><FONT COLOR="FF0000">[</FONT><a href="javascript:NewWindow('bid_request_history.cfm?formname=BidrequestComponents','name','850','600','Yes', 'No')"> proposal history </a><FONT COLOR="FF0000">]</FONT></B>
				</FONT>
			</cfif></td>
</tr></table>	

<FIELDSET STYLE="padding:10px; width: 700px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Bid Fixed Component Information</LEGEND>

<cfset arAllowList = ArrayNew(1) />
<cfset bTemplateLevelComponentFilter = 1 />

<!------ Operating Group ----->
<cfset componentsUnderOperatingGroupLevel2 = "" />
<cfif appSettings.getOperatingGroupOn()>
	<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
	<cfset programLevel2Level 				= operatingGroupManager.getProgramLevel2Level() />
	<!------ Get the operating group for this program ----->
	<cfset operatingGroupProgramLevel2 	= operatingGroupManager.getProgramOperatingGroupID(level=programLevel2Level, programId=CSL_Contract_Main_ID) />
	<cfset qGetComponentsUnderOperatingGroupLevel2 = operatingGroupManager.getComponents(operatingGroupProgramLevel2, 10) />
	<cfset componentsUnderOperatingGroupLevel2 = ValueList(qGetComponentsUnderOperatingGroupLevel2.Component_ID) />
	<cfset arAllowList[ArrayLen(arAllowList) + 1] = componentsUnderOperatingGroupLevel2 />
	<cfset bTemplateLevelComponentFilter = 0 />
</cfif>
<!------ Operating Group ----->
<cfif bTemplateLevelComponentFilter>
	<!--- get a list of comps to filter based on template --->
	<cfset qComponents = templateManager.getAllTemplateDiscountComponents(GetSettings.ProgramControl_Panel_Options_ID, 10, 1) />		
	<cfset lTemplateAllowList = ValueList(qComponents.Component_ID) />	
	<cfset arAllowList[ArrayLen(arAllowList) + 1] = lTemplateAllowList />
</cfif>
<cfset arAllowListLen = ArrayLen(arAllowList) />
 <cfquery name="GetBidrequestComponentNames" datasource="#application.datasource#">
        SELECT 	Program_BidRequest_Component_Name.*,
				Allowance_Code.Allowance_Code_Number, Allowance_Code.Allowance_Code_Desc
		FROM 	Program_BidRequest_Component_Name
		
		LEFT JOIN Allowance_Code
		ON		Allowance_Code.Allowance_Code_ID = Program_BidRequest_Component_Name.Allowance_Code_ID
		
		WHERE	Program_BidRequest_Component_Name.Active = 1 
		AND 	Program_BidRequest_Component_Name.Deleted = 0
		<cfloop from="1" to="#arAllowListLen#" index="i">
		<cfset lAllowList = arAllowList[i] />
		<cfif Len(lAllowList) EQ 0>
		AND 1=2
		<cfelse>
		AND	Program_BidRequest_Component_Name_ID IN (#lAllowList#)
		</cfif>
		</cfloop>
  </cfquery>
  
  <!--- D11147 BJF Component product restrictions 
				Set product restriction query here so there are fewer iterations	--->
		<cfif appsettings.getComponent_Product_Restrictions_On()>
	
			<cfset useLakebaseForQuery_#GetBidrequestComponentNames_Program_BidRequest_Component_Name_ID# = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("component_products_restricted")>
<cfif useLakebaseForQuery_#GetBidrequestComponentNames_Program_BidRequest_Component_Name_ID#>
	<cftry>
		<cfset Query_#GetBidrequestComponentNames.Program_BidRequest_Component_Name_ID# = application.oLakebase.toQuery(
			application.oLakebase.selectRows("component_products_restricted", {
				"discount_type_id" = "eq.10 --Bid Request",
				"component_id" = "eq.#GetBidrequestComponentNames.Program_BidRequest_Component_Name_ID#",
				"select" = "product_id"
			}), "product_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForQuery_#GetBidrequestComponentNames_Program_BidRequest_Component_Name_ID# = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForQuery_#GetBidrequestComponentNames_Program_BidRequest_Component_Name_ID#>
<cfquery name="Query_#GetBidrequestComponentNames.Program_BidRequest_Component_Name_ID#" datasource="#application.datasource#">
			SELECT Product_ID
			FROM Component_Products_Restricted
			WHERE Discount_Type_ID = 10 --Bid Request
			AND Component_ID = '#GetBidrequestComponentNames.Program_BidRequest_Component_Name_ID#'
			</cfquery>
</cfif>
		
		</cfif>
  
<table WIDTH="780" border="0" cellpadding="2" cellspacing="0">
	<tr>
<!--- 		<td COLSPAN="2" STYLE="border-bottom:solid 1px blue;"><B>Volumes</B></td>
		<td BGCOLOR="white" ROWSPAN="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td> --->
		<td COLSPAN="4" STYLE="border-bottom:solid 1px blue;"><B>Components</B></td>
		<td BGCOLOR="white" ROWSPAN="3">&nbsp;&nbsp;</td>
		  <td COLSPAN="2" STYLE="border-bottom:solid 1px blue;"> 
			<B>Multi Assignment Tool</B>&nbsp;&nbsp;&nbsp;
			<font color="#0000FF" size="3" title="Use this feature to make adjustments to the price/uom for any item/component combinations listed below." STYLE="cursor:pointer">
				<b>?</b>
			</font> 
		  </td>
	</tr>
	<tr BGCOLOR="eeeeee">
		<td>Component Name</td>
		<td>Default Price</td>
		<td>UOM</td>
		<TD>Paid To</TD>
		<td>Price</td>
		<td>UOM</td>
		<cfif appSettings.getPaymentCycleAtDiscountType()>
		<td>
		<cfparam name="FORM.PaymentCycle" 	default="">
<!--- 		<cf_payment_cycle_selection
			Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
			Program_ID = "#FORM.Contract_Main_ID#"
			discount_Type_ID = "1"
			Selected_Payment_Cycle_ID = "#FORM.PaymentCycle#"
			> --->
		</td>
		</cfif>
	</tr>
	<TR valign="top">
	<TD>
	  <cfoutput> 
              <select name="Program_Bidrequest_Component_Name_ID" style="width:180px">
			  	<option value="-1" selected>Select Bid Fixed Component</option> 
                <cfloop query="GetBidrequestComponentNames">
                  <option value="#Program_Bidrequest_Component_Name_ID#" <cfif GetBidrequestComponentNames.recordcount EQ 1>selected</cfif>>#Allowance_Code_Number# #Program_Bidrequest_Component_Name# 
                  <cfif application.returned_customer_setting.external_id_on EQ 1>
                    <cfif Len(External_ID) GT 0>
                      (#External_ID#) 
                    </cfif>
                  </cfif>
                  </option>
                </cfloop>
              </select>
			<input type="hidden" name="Program_Bidrequest_Component_Name_ID_Selection_Validated" value="0">
            </cfoutput> 
	</TD>
	<TD valign="top">
		<input name="rate" type="text" size="10" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,4)"/></td>
	<TD valign="top">
							
			<cf_uom_dropdown
				program_id				=	"#FORM.Contract_Main_ID#"
				company_main_id			=	""
				default_option_on		=	"0"
				default_option_text		=	""
				default_option_value	=	""
				dropdown_name			=	"uom"
				option_text_abbreviated	=	"1"
				plural_uom_display		=	""
				product_type_id			=	"10"
				program_template_id		=	""
				selected_uom_id			=	""
				text_before_tag_close	=	""
				uom_id_exclusion_list	=	""
				uom_id_inclusion_list	=	""
				setDefaultSelected		= 	1		
			>
		</td>
		<TD valign="top">
		<!---check to see if we can select Paid To: Distributor, Operator or both based on Template Generic Type--->
		<cfscript> 
		GetPaymentPaidToTypes = templateManager.GetPaymentPaidToTypes(CSLGetContractInfo.ProgramType_ID);
		</cfscript>
		<cfloop query="GetPaymentPaidToTypes">
		<input name="Bidrequest_Component_Paid_To" type="Radio" value="<cfoutput>#Payment_Paid_To_ID#</cfoutput>" <cfif GetSettings.PaidToDefaultOption eq Payment_Paid_To_ID>checked</cfif>><cfoutput>#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = Payment_Paid_To_Type_Identifier, paidToDesc=Payment_Paid_To_Type_Name)#</cfoutput><br>
		</cfloop>
		</TD>
		<td><input name="apply_rate" type="text" size="10" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,4)"  <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2>STYLE="background-color: cccccc" DISABLED</cfif>/></td>
		<td>
			<cfset disabled = 0>
		 <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_UOM_Changes eq 2>
			<cfset disabled = 1>
		 </cfif>
			<cf_uom_dropdown
				program_id				=	"#FORM.Contract_Main_ID#"
				company_main_id			=	""
				default_option_on		=	"0"
				default_option_text		=	""
				default_option_value	=	"0"
				dropdown_name			=	"apply_uom"
				option_text_abbreviated	=	"1"
				plural_uom_display		=	""
				product_type_id			=	"10"
				program_template_id		=	""
				selected_uom_id			=	""
				text_before_tag_close	=	""
				uom_id_exclusion_list	=	""
				uom_id_inclusion_list	=	""
				setDefaultSelected		= 	1	
				disabled				=	"#disabled#"
			>
			
		</td>
	</TR>
	<tr BGCOLOR="eeeeee">
		<td colspan="4">
			<cfif appSettings.getDisableAddingComponentsOnRevision() AND bIsContractARevision>
				<CF_smallLink 
					title = "include this bid fixed component"
					url = "##"
					enabled = "0"
					parameters="title='adding new components are not allowed on revisions'"
				>
			<cfelse>
				<B><font color="FF0000">[</font> <a onClick="<cfif EzButton_Disable EQ 0>javascript:submitForm();<cfelse>""</cfif>" STYLE="cursor: pointer;" <cfif EzButton_Disable EQ 1>disabled</cfif>>include this bid fixed component</a> <font color="FF0000">]</font></B>
			</cfif>
		</td>
		<td width="27" BGCOLOR="White">&nbsp;&nbsp;&nbsp;</td>
		<td colspan="2"><B><font color="FF0000">[</font>
		<cfif NOT(Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_UOM_Changes eq 2 AND RevisionSettings.Products_Rates_Changes eq 2)>
		<a onClick="<cfif EzButton_Disable EQ 0>javascript:applyrate();<cfelse>""</cfif>" STYLE="cursor: pointer;"<cfif EzButton_Disable EQ 1>disabled</cfif>>apply this price / uom</a>
		<cfelse>
		<span style="color:gray">apply this price / uom</span>
		</cfif>
		<font color="FF0000">]</font></B>
		</td>
	</tr>
</table>
</FIELDSET>

<INPUT TYPE="Hidden" NAME="FirstTime" 			VALUE="1">
<INPUT TYPE="Hidden" NAME="DeletedComponentPosition" 			VALUE="0">
<!--- </form> --->

<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px; font-weight: bold;}
</style>

<!--- <FORM ACTION="Contract_Discount_Fixed_Component.cfm?CID=#URL.CID#" METHOD="post" NAME="FixedProductComponents" ID="FixedProductComponents"> --->
<table>
<tr>
<td>
<b>
 <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2>
	<CF_smallLink 
				title = "Add Products" 
				url = "##"
				enabled = "0"
			>
<cfelse>
	<CF_smallLink 
		title = "Add Products" 
		url = "##"
		parameters = "onClick=""javascript: return showProductSearchWindow();"""
	>
</cfif>
</b>
</td>
</tr>
</table>
<cfset  component_width = 100>
<table border="0" cellpadding="1" cellspacing="0" bgcolor="ffce84" CLASS="Maintable" width="800">
<tr>
<TD ID="header" WIDTH="15"><NOBR>
<cfif NOT(Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Removed eq 2)>
	<img bDelete="true" sMessage="delete all products in this page" src="/images/scissor.gif" alt="delete all products in this page" border="0" onClick="deleteAll('Prod_');" style="cursor: pointer;"></NOBR>
<cfelse>
	&nbsp;
</cfif>
</TD>
<td width="20">
		<input name="prodCheck" type="checkbox" onClick="checkAllProd()" checked>
</td>
<cfoutput>
<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
<td width="120" ID="header" nowrap>
<cfelse>
<td width="80" ID="header" nowrap>
</cfif>
<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>#application.returned_customer_setting.upc_label#<br></cfif></cfif></cfoutput><cfoutput>#application.returned_customer_setting.item_label#</cfoutput>#
</td>
<td width="90" ID="header">
Description
</td>
<td Id="header" width="50">Spec</td>
<cfif url.EZTemplate EQ 1>
<td width="50" ID="header">Default</td>
</cfif>
<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
<td width="80" ID="header" align="right">
Base Sales
</td>
<cfset  component_width = 120>
<cfelse>
<cfset  component_width = 100>
</cfif>
<cfoutput>
<cfif getBidrequestComponents.Recordcount GT 0>
	<cfset j = 0>
	<cfloop list="#form.Bidrequestcomponentlist#" index="i">
<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
<td width="80" ID="header" align="center">
Discount
</td>
</cfif>
		<cfset comp_id_start = Find("_",i)>
		<CFSET comp_id = Left(#i#, (#comp_id_start#-1))>
		<CFSET paid_to = Mid(#i#,comp_id_start + 1,Len(comp_id))>

		<cfset useLakebaseForgetBidrequestComponentName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bidrequest_component_name")>
<cfif useLakebaseForgetBidrequestComponentName>
	<cftry>
		<cfset getBidrequestComponentName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bidrequest_component_name", {
				"program_bidrequest_component_name_id" = "eq.#comp_id#",
				"deleted" = "eq.0",
				"select" = "program_bidrequest_component_name,program_bidrequest_component_name_id"
			}), "program_bidrequest_component_name,program_bidrequest_component_name_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetBidrequestComponentName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetBidrequestComponentName>
<CFQUERY NAME="getBidrequestComponentName" datasource="#application.datasource#">
			SELECT	Program_Bidrequest_Component_Name.Program_Bidrequest_Component_Name,
					Program_Bidrequest_Component_Name_Id
			FROM 	Program_Bidrequest_Component_Name
			WHERE 	Program_Bidrequest_Component_Name_Id = #comp_id#
			AND 	Program_Bidrequest_Component_Name.DELETED = 0
		</CFQUERY>
</cfif>
	
		<td ID="header" width="#component_width#" nowrap  STYLE="font-size:9px;">
			<cfif EzButton_Disable EQ 0><A STYLE="cursor: pointer;" ONCLICK="verifyDelete('#getBidrequestComponentName.Program_Bidrequest_Component_Name_Id#', '#replace(getBidrequestComponentName.Program_Bidrequest_Component_Name, "'", "\'")#',#j#)">
				<img src="/Images/scissor.gif"  alt="delete this component" border="0">
			</A></cfif>
			<input name="Comp_#comp_id#_#j#" type="checkbox" value="Comp_#comp_id#_#j#">
			<span STYLE="font-size:9px;">#Left(getBidrequestComponentName.Program_Bidrequest_Component_Name, 10)#</span><br>
			<div align="center">#templateManager.getPaymentPaidToTypeDesc(paidToID = paid_to, paidToDesc="")#</div>
<cfif EzButton_Disable EQ 1 and getsettings.EZprogram_editcomponent EQ 1>			<br>&nbsp;<font color="red">[</font><a onClick="JavaScript: openPopup('ezprogram_editcomponent.cfm?programid=#GetContractInfo.contract_main_id#&discounttypeid=10&PaidTo=#Paid_To#&ProgramType_ID=#CSLGetContractInfo.ProgramType_ID#&Formname=BidrequestComponents&compid=#getBidrequestComponentName.Program_Bidrequest_Component_Name_Id#', 300, 200)" title="#getFixedComponentName.Program_Fixed_Component_Name#" STYLE="cursor: pointer;">edit</A><font color="red">]</font>
			</cfif>	
		</td>
		<cfset j = j+1>
<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
<td width="60" ID="header" align="right">
Discount%
</td>
</cfif>
	</cfloop>
</cfif>
<td>&nbsp;</td>
</tr>
</table>

<cfif TheQuery.recordcount GT 8>

	<cfset divHght = "height:200px;" />
	<cfset divTableWidth = "800" />
<cfelse>
	<cfset divHght = "" />
	<cfset divTableWidth = "800" />
</cfif>
 	  <DIV id="CurrentDiv" STYLE="z-index:3;position:relative;overflow:auto;#divHght#"> 
		<table  border="0" cellpadding="1" cellspacing="0" width="800" CLASS="Maintable"></cfoutput>
		  <cfset rowcount = 0>
		  <CFIF TheQuery.recordcount GT 0>
			<cfoutput query="TheQuery" group="BSA_Foodservice_Items_Master_ID">
			<cfsilent>
			<cfset INVENTORYUOM = TheQuery.INVENTORY_UM>
			<CFIF (GetSettings.Include_Competitive_Data_Tracking EQ 1 and GetSettings.display_basesales_Competitive_Data EQ 1) OR appsettings.getshowfixedpriceadditionalfields() EQ 1>
			<cfif appSettings.getBidRequestUsePriceByDate() EQ 1>
				<cfif bIsIndirectBid>
					<cfset priceListId = bidRequestProdMan.getPriceListId("GIL98") />
				<cfelse>
					<cfset priceListId = bidRequestProdMan.getPriceListId() />
				</cfif>	
				<cfparam name="priceIdNull" default="no" />
				<cfif trim(priceListId) eq "">
					<cfset priceIdNull = "yes" />
				</cfif>
				<cfset stPrice = bidRequestProdMan.getPrice(BSA_Foodservice_Items_Master_ID, priceListId, priceIdNull, CSLGetContractInfo.contract_start_date, bIsIndirectBid) />
				<cfset FOB_CS_Price = stPrice.CSPrice />
				<cfset FOB_LB_Price = stPrice.LBPrice />
			<cfelse>
				<cfif appSettings.getUseItemCustPrice() EQ 1>
				<cfset getItemCustPrice = bidRequestProdMan.getItemCustPrice(BSA_Foodservice_Items_Master_ID,form.contract_main_id) />
				<cfset FOB_CS_Price = getItemCustPrice.FOB_CS_Price>
				<cfset FOB_LB_Price = getItemCustPrice.FOB_LB_Price>
				<cfset DEL_CS_Price = getItemCustPrice.DEL_CS_Price>
				<cfset DEl_LB_Price = getItemCustPrice.DEL_LB_Price>
				<cfelse>
				<cfset FOB_CS_Price = TheQuery.FOB_CS_Price>
				<cfset FOB_LB_Price = TheQuery.FOB_LB_Price>
				<cfset DEL_CS_Price = TheQuery.DEL_CS_Price>
				<cfset DEl_LB_Price = TheQuery.DEl_LB_Price>
				</cfif>
			</cfif>	
		</cfif>
			  <CFSET FieldNameEnd = replace(TheQuery.BSA_Foodservice_Items_Master_ID,"-","_", "ALL")>
			  <cfset reproduct_id = replace(Thequery.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")>
			  <cfset rowcount = rowcount + 1>
		 </cfsilent>
		<cfif not len(trim(won))>
		 	<cfset this.won = 1 />
		<cfelse>
			<cfset this.won = won />
		</cfif>
		 <input type="hidden" name="Bid_Request_Status_ID_#reproduct_id#" value="#this.won#">
			  <tr BGCOLOR="#IIf(rowcount Mod 2, DE('ffffff'), DE('C6FFC6'))#" ID="TR_Products" PRODUCT_ID_RE="#FieldNameEnd#" bDelete="0" ONMOUSEOVER="menuID=6;URLstring='';an_ID='#TheQuery.BSA_Foodservice_Items_Master_ID#';doNotRelocate=1;" onMouseOut="menuID=0;doNotRelocate=0;" style="cursor: help;"> 
				<TD width="15">
					<cfif NOT(Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Removed eq 2 AND listfind(ProductItemList, BSA_Foodservice_Items_Master_ID) NEQ 0)>
						<img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif" alt="click here to delete this product" border="0" onClick="deleteThisFixedPrice('#FieldNameEnd#', '#TheQuery.BSA_FOODSERVICE_ITEMS_MASTER_ID#')" style="cursor: pointer;">
					<cfelse>
						&nbsp;
					</cfif>
				</TD>
				<td width="20"> <input name="Prod_#replace(Thequery.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" type="checkbox" value="#replace(Thequery.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" checked> 
				</td>
				<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
				<td width="120">
				<cfelse>
				<td width="80">
				</cfif>
				<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>#trim(TheQuery.UPC)#<br></cfif></cfif>#trim(TheQuery.Item)# </td>
				<TD width="90" STYLE="font-size:9px;" valign="top"> #TheQuery.Description#
				<CFIF GetSettings.Include_Competitive_Data_Tracking EQ 1>
					<CFMODULE template="/CustomTags/SmallHelp.cfm"
					width = "180"
					height = "50"
					imgPath="/Images/Asterix.gif"
					imgWidth="10"
					imgHeight="10"
					>
				<table>
				<CFIF GetSettings.Include_Competitive_Data_Tracking EQ 1 and GetSettings.display_basesales_Competitive_Data EQ 1 and appsettings.getshowfixedpriceadditionalfields() EQ 0>
				<cfif appSettings.getBidRequestUsePriceByDate() EQ 0>
				<tr><td align="left">FOB Base Price/CS:</td><td>#numberformat(FOB_CS_Price,"_,___,____.____")#/CS</td></tr>
<tr><td align="left">FOB Base Price/LB:</td><td>#numberformat(FOB_LB_Price,"_,___,____.____")#/LB</td></tr>
<tr><td align="left">DEL Base Price/CS:</td><td>#numberformat(DEL_CS_Price,"_,___,____.____")#/CS</td></tr>
<tr><td align="left">DEL Base Price/LB:</td><td>#numberformat(DEL_LB_Price,"_,___,____.____")#/LB</td></tr>
<cfelse><tr><td align="left">Base Price/CS:</td><td>#numberformat(FOB_CS_Price,"_,___,____.____")#/CS</td></tr>
<tr><td align="left">Base Price/LB:</td><td>#numberformat(FOB_LB_Price,"_,___,____.____")#/LB</td></tr>
			</cfif>
			</cfif>
<tr><td align="left">Previous Won By:</td><td>#TheQuery.Previous_Won_By#</td></tr>
<tr><td align="left">Previous Won Price:</td>
<td>#numberformat(TheQuery.Previous_Won_Price,"_,___,____.____")#/
<cfif TheQuery.Previous_Won_UOM EQ 1>CS<cfelse>LB</cfif></td></tr>
<cfif appSettings.getBidRequestUsePriceByDate() EQ 0>
<tr><td align="left">Delivery Type:</td><td><cfif TheQuery.Previous_Won_Delivery_Type EQ 1>FOB<cfelse>DEL</cfif></td></tr></cfif>
</table></CFMODULE></cfif>
				</TD>
				<TD width="50" STYLE="font-size:5px;"><select name="Bid_Request_Spec_ID_#reproduct_id#" <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2>STYLE="background-color: cccccc" DISABLED</cfif>>
<cfset this_spec_id = thequery.Bid_Request_Spec_ID>
						<cfloop query="qGetBidSpec">
							<option value="#Bid_Request_Spec_ID#" <cfif Bid_Request_Spec_ID EQ this_spec_id>selected</cfif>>#Bid_Request_Key#</option>
						</cfloop>
					</select>
					<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2>
						<input type="hidden" name="Bid_Request_Spec_ID_#reproduct_id#" value="#this_spec_id#">
					</cfif>
				</TD>
	<cfif url.EZTemplate EQ 1>
	<td width="50">
	<input name="Prod_Default_#replace(Thequery.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" type="checkbox" value="1" <cfif thequery.EZButton_On_Default EQ 1>checked</cfif>> 
	</td>
	</cfif>
	<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
	<td width="80" align="right">
	$#numberformat(FOB_CS_Price,"_,___,____.____")#/CS<br>
	$#numberformat(FOB_LB_Price,"_,___,____.____")#/LB
	</td>
	
	<input type="hidden" name="Bidrequest_P#reproduct_id#_Price_CS" value="#FOB_CS_Price#">
	<input type="hidden" name="Bidrequest_P#reproduct_id#_Price_LB" value="#FOB_LB_Price#">
	</cfif>

				<cfif getBidrequestComponents.Recordcount GT 0>
				  <cfloop from="1" to="#ListLen(Bidrequest_Comp_ids)#" index="i">
					<cfset currentcompid = ListGetAt(Bidrequest_Comp_ids,i)>
					<cfparam name = "form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_rate" default="0">
					<cfparam name = "form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_UOM" default="0">
<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
					<td width="80" valign="top" align="center">
	<cfsilent>
	<cfif #evaluate("form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_uom")# EQ 1>
	<cfset discount = FOB_CS_Price - #evaluate("form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_rate")#>
	<cfelseif #evaluate("form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_uom")# EQ 2>
	<cfset discount = FOB_LB_Price - #evaluate("form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_rate")#>
	<cfelse>
	<cfset discount = 0>
	</cfif>
	</cfsilent>	
<span id="Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_D">$#numberformat(trim(discount),"_,___,____.____")#</span>
					</td>
				</cfif>
					
					<td width="#component_width#" style="border-left:2px solid gray;" align="center"> <span id="SPAN_Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_rate"> 
<!--- D11147 BJF Component product restrictions 
				Check to see if the product is restricted--->
			<cfset DisabledbyComp = 0>
		<cfif appsettings.getComponent_Product_Restrictions_On()>
	
			<cfquery name="ProductInForbiddenlist" dbtype="query">
			SELECT Product_ID
			FROM Query_#currentcompid#
			WHERE Product_ID = '#Thequery.BSA_Foodservice_Items_Master_ID#'
			</cfquery>
		<cfif ProductInForbiddenlist.Recordcount GT 0>
			<cfset DisabledbyComp = 1>
		</cfif>
		</cfif>
					<cfif (Revision_Settings_Allowed eq 0 OR RevisionStatus.Is_A_Revision eq 0 OR RevisionSettings.Products_Rates_Changes neq 2) and ((getsettings.EZButton_On eq 1 and url.EZtemplate EQ 1) OR ((getsettings.EZButton_On eq 0 and url.EZtemplate EQ 0))) AND DisabledbyComp NEQ 1>
					  <input type="text" size="3" <CFIF evaluate("form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_rate") EQ 0 AND appSettings.getProgram_Allow_Null_Rate() EQ 1>value=""<CFELSE>value="#trim(numberformat(evaluate("form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_rate"),"_____.____"))#"</CFIF> name="Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_rate" ONKEYUP="clenseText(this,'0123456789.')" onChange="<CFIF appSettings.getProgram_Allow_Null_Rate() EQ 1>this.value = formatToDeciamalPlacesAllowNull(this.value,4,1);<CFELSE>this.value = formatToDeciamalPlaces(this.value,4);</CFIF><cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>adjustdiscount('Bidrequest_C#currentcompid#_P#reproduct_id#_#i#','Bidrequest_P#reproduct_id#');</cfif>"/>
					<cfelse>
					<cfif EzButton_Disable EQ 1>
					<cfset useLakebaseForgetEZButtonRate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getezbuttondefaultrates")>
<cfif useLakebaseForgetEZButtonRate>
	<cftry>
		<cfset getEZButtonRate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getezbuttondefaultrates", {
				"bsa_foodservice_items_master_id" = "eq.#Thequery.BSA_Foodservice_Items_Master_ID#",
				"program_bidrequest_component_name_id" = "eq.#currentcompid#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetEZButtonRate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetEZButtonRate>
<cfquery name="getEZButtonRate" dbtype="query">
						select * from
						GetEZButtonDefaultRates
						where BSA_Foodservice_Items_Master_ID = '#Thequery.BSA_Foodservice_Items_Master_ID#'
						and Program_Bidrequest_Component_Name_Id = #currentcompid#
					</cfquery>
</cfif>
					<cfset "form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_rate" = getEZButtonRate.Bidrequest_Price_Value>
					<cfset "form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_uom" = getEZButtonRate.Unit_Of_Measure_ID>
					</cfif>
					
					<!--- Set values if forbidden by component --->		
					<cfif DisabledbyComp EQ 1>
					<cfset "form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_rate" = "0">
					<cfset "form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_uom" = getProgramInfo.Contract_Quantity_UOM_IDX>
					
					</cfif>
					  <input type="text" size="1" <CFIF evaluate("form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_rate") EQ 0 AND appSettings.getProgram_Allow_Null_Rate() EQ 1>value=""<CFELSE>value="#evaluate("form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_rate")#"</CFIF> name="Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_rate" ONKEYUP="clenseText(this,'0123456789.')" onChange="<CFIF appSettings.getProgram_Allow_Null_Rate() EQ 1>this.value = formatToDeciamalPlacesAllowNull(this.value,4,1);<CFELSE>this.value = formatToDeciamalPlaces(this.value,4);</CFIF><cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>adjustdiscount('Bidrequest_C#currentcompid#_P#reproduct_id#_#i#','Bidrequest_P#reproduct_id#');</cfif>" <cfif listfind(ProductItemList, BSA_Foodservice_Items_Master_ID) NEQ 0 OR EzButton_Disable EQ 1 OR DisabledbyComp EQ 1>STYLE="background-color: cccccc" DISABLED</cfif> />
					 <cfif listfind(ProductItemList, BSA_Foodservice_Items_Master_ID) NEQ 0 OR (EzButton_Disable EQ 1) OR DisabledbyComp EQ 1>
					 <input type="hidden" <CFIF evaluate("form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_rate") EQ 0 AND appSettings.getProgram_Allow_Null_Rate() EQ 1 OR (DisabledbyComp EQ 1)>value=""<CFELSE>value="#evaluate("form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_rate")#"</CFIF> name="Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_rate" />
					</cfif>
					</cfif>
					  </span> 
					  <cfif #evaluate("form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_uom")# EQ "">
						<cfset setDefaultSelected = 1>
						<cfelse>
						<cfset setDefaultSelected = 0>
					  </cfif>
					  <cfset Disabled = 0>
					  <cfif (Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_UOM_Changes eq 2 AND listfind(ProductItemList, BSA_Foodservice_Items_Master_ID) NEQ 0) OR (EzButton_Disable EQ 1) OR DisabledbyComp EQ 1>
						<cfset Disabled = 1>
					  </cfif>
			<span id="UOMCollection">
<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
<cfset onchangetext = "javascript:adjustdiscount('Bidrequest_C#currentcompid#_P#reproduct_id#_#i#','Bidrequest_P#reproduct_id#');">
<cfelse>
<cfset onchangetext ="">
</cfif>
					  <cf_uom_dropdown
				program_id				=	"#FORM.Contract_Main_ID#"
				company_main_id			=	""
				default_option_on		=	"0"
				default_option_text		=	""
				default_option_value	=	""
				dropdown_name			=	"Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_uom"
				option_text_abbreviated	=	"1"
				plural_uom_display		=	""
				product_type_id			=	"10"
				program_template_id		=	""
				selected_uom_id			=	"#evaluate("form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_uom")#"
				text_before_tag_close	=	""
				uom_id_exclusion_list	=	""
				uom_id_inclusion_list	=	""
				setDefaultSelected		= 	"#setDefaultSelected#"	
				productUom				=	"#INVENTORYUOM#"
				Disabled				= 	"#Disabled#"
				onchange				=   "#onchangetext#"
			>
				</span>
			<cfif Disabled eq 1>
				<input type="hidden" name="Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_uom" value="#evaluate("form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_uom")#">
			</cfif>
			</td>
			<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
			<cfsilent>
			<cfif #evaluate("form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_uom")# EQ 1>
			<cfif FOB_CS_Price NEQ 0>
			<cfset discount_percent = ((FOB_CS_Price - #evaluate("form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_rate")#)/FOB_CS_Price) * 100>
			<cfelse>
			<cfset discount_percent = 0>
			</cfif>
			<cfelseif #evaluate("form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_uom")# EQ 2>
			<cfif FOB_LB_Price NEQ 0>
			<cfset discount_percent = ((FOB_LB_Price - #evaluate("form.Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_rate")#)/FOB_LB_Price) * 100>
			<cfelse>
			<cfset discount_percent = 0>
			</cfif>
			<cfelse>
			<cfset discount_percent = 0>
			</cfif>
	</cfsilent>
				<td width="60" valign="top" align="right">
<span id="Bidrequest_C#currentcompid#_P#reproduct_id#_#i#_DP">#numberformat(discount_percent,"_,___,____.__")#%</span>
				</td>
			</cfif>
				  </cfloop>
				</cfif>
				<td>&nbsp;</td>
			  </tr>
			</cfoutput> 
			<CFELSE>
			<tr bgcolor="C6FFC6"> 
			  <td><strong>No Products Selected</strong></td>
			</tr>
		  </CFIF>
		</table>
	  </div>
<cfoutput><table width="800">
	<!---loop over spec info and display info--->
	<CFIF GetSettings.Include_Competitive_Data_Tracking EQ 1>
	<tr><td><img name="IMG_Asterix" src="/images/Asterix.gif" height="8" width="8"> &nbsp;(Mouse Over on the icon to view previous Bid Information.)</td></tr>
	</cfif>
	<tr>
		<td colspan="100%" style="border:none">
		Spec: 
			<cfloop query="qGetBidSpec">
				#Bid_Request_Key# (#Bid_Request_Desc#)&nbsp;&nbsp;&nbsp;
			</cfloop>
		</td>
	</tr>
</table></cfoutput>
<BR>
<cfoutput>

<CF_button
	button_name		=	"save"
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
<input type="hidden" name="SudmitFormViaSubmitButton" style="display: none" value="1"/>
<input type="submit" name="submitbutton" style="display: none" value="1"/>
<INPUT TYPE="hidden" NAME="ProductCount" VALUE="#TheQuery.Recordcount#">
<INPUT TYPE="hidden" NAME="Contract_Main_ID" VALUE="#FORM.Contract_Main_ID#">
	<INPUT TYPE="Hidden" NAME="Sort_By" 			VALUE="#URL.Sort_By#">
	<INPUT TYPE="Hidden" NAME="Program_ID" 			VALUE="#URL.CID#">
	<INPUT TYPE="Hidden" NAME="Product_List" 		VALUE="#Form.Product_List#">
	<input TYPE="Hidden" NAME="BidrequestComponentList" VALUE="<cfoutput>#form.BidrequestComponentList#</cfoutput>">
	<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="#Form.Product_List#">
	<INPUT TYPE="Hidden" NAME="DTPS_On" 			VALUE="1">
	<INPUT TYPE="Hidden" NAME="DTPS_Program_ID" 	VALUE="#FORM.Contract_Main_ID#">
	<INPUT TYPE="hidden" NAME="deletedateexclusions" VALUE="0">
	<input type="Hidden" name="operatorList" value="#form.operatorList#" />
	<input type="hidden" name="EZTemplate" value="#url.EZTemplate#">
</form>
</cfoutput>
</BLOCKQUOTE></BLOCKQUOTE>
<script>
findselectboxes();
</script>
<cfif application.programlayout EQ 1></div></cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>
