<CFPARAM NAME="URL.CID" DEFAULT="">
<cfparam name="form.Fixed_Component_Paid_To" default="">
<cfparam name="donotallowaddproductsDE" default = "0">
<cfparam name="form.deletedateexclusions" default = "0">
<cfparam name="marginedit_saved" default="0">
<cfparam name="url.EZTemplate" default="0">

<cfinclude template="Contract_Discount_Fixed_Component_Functions.cfm" />

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
<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/common_files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT SRC="/billbacks/common/common_js_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/Queue.js"></SCRIPT>

<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFINCLUDE TEMPLATE="/includes/header.cfm"> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "fixed_prices"> 
<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>
<cfparam name="URL.Sort_By" 	default="Item">

<cfset programManager = CreateObject("component", "components.programs.ProgramManager") />
<cfset programagreed = programManager.isProgramAgreed(CSL_Contract_Main_ID)>
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

<cfset fixedCompObj = CreateObject("component","components.programs.fixed.fixedComponent") />
<cfset compBusRule = createObject("component","components.programs.fixed.FixedComponentBusinessRule")>
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />

<!--- <cfset profBusRule = createObject("component","components.programs.fixed.FixedComponentProfile")> --->
<!---
<CFSET Help_URL="/help_files/manual/createprogram/page9.cfm">
--->
<cfif application.programlayout EQ 1>
<!--- <div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
  <CFINCLUDE TEMPLATE="contract_status_legend_margin.cfm"></div>
<cfelse>
<CFINCLUDE TEMPLATE="contract_status_legend_margin.cfm">  --->
</cfif>
<CFINCLUDE TEMPLATE="commonqueries.cfm">
<cfif programagreed GT 0 and GetContractInfo.modifying_program EQ 0 and GetContractInfo.Contract_Status_Type_IDX EQ 2>
<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo() />
</cfif>
<BLOCKQUOTE><BLOCKQUOTE>
<!--- <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()> --->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfif GetSettings.Date_Exclusions_ON EQ 1>
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />	
	<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(CSL_Contract_Main_ID,0)>
	<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
		<cfset donotallowaddproductsDE = 1>
	</CFIF>
</cfif>
<CFSET HideProductList = 1>
<cfoutput>	
	<script language="JavaScript">		
		var maxComponentPossible = #appSettings.getRebateMaxComponents()#;
	</script>
</cfoutput>
<CFSET helpfilenumber=7>
<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:absolute; height:430px; width:200px; z-index:1; left: 10px; top: 10px;">
<!--- <div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 60px; top: 0px;">  ---></cfif>
<cfinclude template="minimal_contract_info.cfm">

<CFQUERY NAME="getProgramInfo" datasource="#application.datasource#">
SELECT     dbo.Units_of_Measure.Unit_Of_Measure_Desc, dbo.Units_of_Measure.Abbreviation, dbo.Contract_Main.Contract_Quantity
FROM         dbo.Contract_Main INNER JOIN
                      dbo.Units_of_Measure ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID
	WHERE dbo.Contract_Main.Contract_Main_ID = '#FORM.Contract_Main_ID#' 
</CFQUERY>

<cfif NOT isDefined("form.FixedComponentList")>
	<CFQUERY NAME="getAllFixedComponents" datasource="#application.datasource#">
	SELECT 	Program_Fixed_Component_Name_Id, Fixed_Component_Paid_to,
			isnull(Treatment_Code_Master_ID, 0) as Treatment_Code_Master_ID, 
			isnull(Basis_Code_Master_ID, 0) as Basis_Code_Master_ID, 
			Claim_Mechanics, 
			GL_Account_ID, 
			Vendor_Master_ID,
			Vendor_Selection,
			Parent_Program_Fixed_Component_ID
			<cfif appSettings.getPaymentCycleAtDiscountType()>
				,Program_Payment_Cycle.Payment_Cycle_ID AS PaymentCycle
			</cfif>
			,isnull(nullif(Program_Fixed_Component.Payee_Type,''),0) As Payee_Selection
	FROM 	Program_Fixed_Component
	<cfif appSettings.getPaymentCycleAtDiscountType()>
	LEFT JOIN Program_Payment_Cycle
		ON Program_Payment_Cycle.Program_ID = Program_Fixed_Component.Program_ID
		AND Program_Payment_Cycle.Component_ID = Program_Fixed_Component.Program_Fixed_Component_ID
		AND Program_Payment_Cycle.Discount_Type_ID = 1
		AND Program_Payment_Cycle.Deleted = 0
	</cfif>
	WHERE Program_Fixed_Component.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.Contract_Main_ID#">
		AND Program_Fixed_Component.DELETED = 0
	ORDER BY Program_Fixed_Component.Program_Fixed_Component_Name_Id,Program_Fixed_Component.Program_Fixed_Component_Id
	</CFQUERY>

	<CFSET form.FixedComponentList = "" />
	<cfloop query="getAllFixedComponents">
		<cfif Vendor_Master_ID EQ "">
			<cfset VendorMasterID = 0>
		<cfelse>
			<cfset VendorMasterID = Vendor_Master_ID>
		</cfif>
		<cfset currentComponentInfo = compileComponentInfo(Program_Fixed_Component_Name_Id, Fixed_Component_Paid_to, Treatment_Code_Master_ID, Basis_Code_Master_ID, Claim_Mechanics, GL_Account_ID, VendorMasterID, PaymentCycle, Vendor_Selection, Parent_Program_Fixed_Component_ID, Payee_Selection) />
		<CFSET form.FixedComponentList = ListAppend(form.FixedComponentList, currentComponentInfo, ",") />
	</cfloop>
</cfif>

<cfif isdefined("form.Program_Fixed_Component_Name_ID") AND form.Program_Fixed_Component_Name_ID NEQ '-1'>
	<cfset currentComponentInfo = compileComponentInfo(form.Program_Fixed_Component_Name_ID, form.Fixed_Component_Paid_To, form.Treatment_Code, form.Basis_Code, form.Claim_Mechanics, form.GL_Account_ID, form.Vendor_Master_ID, form.PaymentCycle, form.VendorSelection, "",form.Payee_Selection) />
	<CFSET form.FixedComponentList = ListAppend(form.FixedComponentList, currentComponentInfo)>
	<cfset componentLen = ListLen(form.FixedComponentList) />
	<cfif isDefined("form.rate") AND isDefined("form.product_list") AND isDefined("form.uom")>
		<cfloop list="#form.product_list#" index="prodid">
			<cfset "form.fixed_C#form.Program_Fixed_Component_Name_Id#_P#replace(prodid, "-", "_", "ALL")#_#componentLen#_rate" = #form.rate#>
			<cfset "form.fixed_C#form.Program_Fixed_Component_Name_Id#_P#replace(prodid, "-", "_", "ALL")#_#componentLen#_uom" = #form.uom#>
			<cfset fixrule = compBusRule.getComponentRules(form.Program_Fixed_Component_Name_Id, 1).Program_Fixed_Component_Rule_ID />
			<cfset "form.fix_rule_C#form.Program_Fixed_Component_Name_Id#_P#replace(prodid, "-", "_", "ALL")#_#componentLen#" = fixrule />
		</cfloop>
	</cfif>
</cfif>

<cfparam name="fixed_comp_ids" default="">
<cfif isdefined("form.FixedComponentList")>
	<cfloop list="#form.FixedComponentList#" index="i">
		<cfset currentComponentId = getComponentNameId(i) />
		<cfset fixed_comp_ids = ListAppend(fixed_comp_ids, currentComponentId, ",")>
		<!--- <cfif ListFindNoCase(profBusRule.compIdsToFilter(request.AccessStructure.Profiles_ID),tmpid)>
			<!--- nada...this profile is restricted from the fixed comp business rule --->
		<cfelse>
			<cfset profHasCompBusRule = 1>
		</cfif> --->
	</cfloop>
</cfif>


<CFQUERY NAME="getFixedComponents" datasource="#application.datasource#">
select  Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID,Program_Fixed_Component_Name.Fixed_Component_Type,Program_Fixed_Component_Name.Program_Fixed_Component_Name,
Program_Fixed_Component.Program_Fixed_Component_Id, Program_Fixed_Component.Fixed_Component_Paid_to
FROM Program_Fixed_Component_Name
LEFT JOIN Program_Fixed_Component
ON Program_Fixed_Component.Program_Fixed_Component_Name_ID = 
Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID
AND Program_Fixed_Component.Program_ID = '#FORM.Contract_Main_ID#'
AND Program_Fixed_Component.Deleted = 0
WHERE 	
		Program_Fixed_Component_Name.Deleted = 0
		<cfif form.FixedComponentList NEQ "">
		AND Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id IN (#fixed_comp_ids#)
		<cfelse>
		AND 1=2
		</cfif>
ORDER BY Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID,Program_Fixed_Component.Program_Fixed_Component_Id
</CFQUERY>

<CFIF NOT isdefined("form.product_list")>
<CFQUERY NAME="Get_Fixed_Products" DATASOURCE="#application.datasource#">
		SELECT	distinct BSA_Foodservice_Items_Master_ID
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
				AND Contract_Products.product_type_id =1
	</CFQUERY>
<CFSET FORM.Product_List = ValueList(Get_Fixed_Products.BSA_Foodservice_Items_Master_ID, ",")>
</CFIF>

<cfoutput>
<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
SELECT     	distinct  dbo.Program_Fixed_Price_Product_Data.Program_Fixed_Price_Product_Data_ID, 
			ISNULL(dbo.Program_Fixed_Price_Product_Data.Fixed_Price_Value,0.0000) as Fixed_Price_Value, 
			dbo.Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID, 
			dbo.Type_Code_Desc.Type_Code_Desc, 
			dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, 
			dbo.BSA_Foodservice_Items_Master.Item, 
			dbo.BSA_Foodservice_Items_Master.UPC, 
			dbo.BSA_Foodservice_Items_Master.Description, 
			dbo.Contract_Products.Contract_Main_ID,
			BSA_Foodservice_Items_Master.Inventory_UM,
			Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id,
			dbo.Program_Fixed_Price_Product_Data.volume,
			Program_Fixed_Component.Program_Fixed_Component_Id,
			Program_Fixed_Price_Product_Data.Program_Fixed_Component_Name_Rule_ID
			
FROM		
			dbo.BSA_Foodservice_Items_Master
			LEFT join Program_Fixed_Component_Name
			ON Program_Fixed_Component_Name.deleted = 0
			<CFIF LIstlen(fixed_comp_ids) GT 0>
			and Program_Fixed_Component_Name_Id IN (#fixed_comp_ids#)
			<cfelse>
			AND 1 = 2
			</CFIF>
			INNER JOIN	dbo.Brand 
			ON dbo.BSA_Foodservice_Items_Master.Brand_ID = dbo.Brand.Brand_ID 
			INNER JOIN	dbo.Type_Code_Desc 
			ON dbo.BSA_Foodservice_Items_Master.Type_Code_Desc_ID = dbo.Type_Code_Desc.Type_Code_Desc_ID
			<!---  --->
			LEFT JOIN Program_Fixed_Component On
			Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id = Program_Fixed_Component.Program_Fixed_Component_Name_ID
			AND Program_Fixed_Component.program_id = '#FORM.Contract_Main_ID#'
and Program_Fixed_Component.deleted = 0
			LEFT JOIN	
			(dbo.Contract_Products 
			INNER JOIN dbo.Program_Fixed_Price_Product_Data 
			ON dbo.Program_Fixed_Price_Product_Data.Contract_Products_ID = dbo.Contract_Products.Contract_Products_ID 			
			AND (dbo.Program_Fixed_Price_Product_Data.Deleted = 0)			
)
			ON 	dbo.Contract_Products.BSA_Foodservice_Items_Master_ID = dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID 
			AND (dbo.Contract_Products.Deleted = 0)
			AND (dbo.Contract_Products.Contract_Main_ID = Program_Fixed_Component.program_id)
			AND (dbo.Contract_Products.Product_Type_ID = 1)			
			AND Program_Fixed_Component.Program_Fixed_Component_Id = Program_Fixed_Price_Product_Data.Program_Fixed_Component_Id
	<!--- LEFT JOIN	
			dbo.Contract_Products 
			ON 	dbo.Contract_Products.BSA_Foodservice_Items_Master_ID = dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID 
			AND (dbo.Contract_Products.Deleted = 0)
			AND (dbo.Contract_Products.Contract_Main_ID = '#FORM.Contract_Main_ID#')
			AND (dbo.Contract_Products.Product_Type_ID = 1)			
			LEFT JOIN	dbo.Program_Fixed_Price_Product_Data 
			ON dbo.Program_Fixed_Price_Product_Data.Contract_Products_ID = dbo.Contract_Products.Contract_Products_ID 			
			AND (dbo.Program_Fixed_Price_Product_Data.Deleted = 0)--->
WHERE     			
			<CFIF FORM.Product_List EQ "">
				1=2
			<CFELSE>
				BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
				IN (#ListQualify(FORM.Product_List, "'", ",")#)
				ORDER BY dbo.Type_Code_Desc.Type_Code_Desc, #sql_Sort_By#,Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id,Program_Fixed_Component.Program_Fixed_Component_Id
			</CFIF>

</CFQUERY></cfoutput>

<cfif getsettings.EZButton_On EQ 1 and URL.EZTemplate EQ 0>
	<cfset EzButton_Disable = 1>
<cfelse>
	<cfset EzButton_Disable = 0>
</cfif>

<cfscript>
	function buildFixedInputName(compId, pId, iI, sSuffix)
	{
		return "FIXED_C" & compId & "_P" & replace(pId, "-", "_", "ALL") & "_" & iI & sSuffix;
	}
	
	function buildFixeddocumentName(compId, pId, iI, sSuffix)
	{
		return "document.all.fixed_C" & compId & "_P" & replace(pId, "-", "_", "ALL") & "_" & iI & sSuffix & ".value";
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
			 document.all.Program_Fixed_Component_Name_ID.value = "-1";
			 NewWindow("product_Select_V1.cfm?Formname=FixedComponents", "productwindow", 800, 600, "yes", "yes", true)			
		}
		
		function deleteThisFixedPrice(FieldNameRe, prodID)
	{	
		var srcObj = event.srcElement;
		var trObj = getParentObject(srcObj, "tr");
		var trIndex = trObj.rowIndex;
		var FINALITEMLIST = document.FixedComponents.Product_List.value;
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
				
				<cfset CompLen = ListLen(form.fixedcomponentlist)>
				for (i=1; i<=<cfoutput>#CompLen#</cfoutput>; i++)
				{
				disableDiv(trObj.cells[i+2], true, false);
				}
				
				propogateProperty(trObj, "style.backgroundColor", "#DDDDDD", false);
				propogateProperty(trObj, "style.textDecoration", "line-through", true);				
				
				srcObj.title = "undo product deletion";
				srcObj.src = undodeleteImg.src;
				//resetnavigate();
				
			
			}
			else
			{
				
				<cfset CompLen = ListLen(form.fixedcomponentlist)>
				<cfif url.EZTemplate EQ 0>
				for (i=1; i<=<cfoutput>#CompLen#</cfoutput>; i++)
				{
				disableDiv(trObj.cells[i+2], false, false);
				}
				</cfif>
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
		ErrorCount = 0
		

			if(ErrorCount == 0) 
				{
				document.FixedComponents.submit();
				}
			else 
				{showMessageWindow();}	
	}
	
	
	function verifyDelete(component_id, component_name,position) {
		 document.all.Program_Fixed_Component_Name_ID.value = "-1";
		if(confirm("Are you sure you want to delete " + component_name + "?")) {
			var FINALCOMPLIST = document.all.FixedComponentList.value;
			
			var resultString;
			resultString = ListDeleteAt(FINALCOMPLIST, ",", position);
			document.all.FixedComponentList.value = resultString;
			document.all.DeletedComponentPosition.value = position+1;
			document.all.FixedComponents.submit();
		}
	}

	function CA() {
		document.all.allbox.checked = event.srcElement.checked;
		
		if(0==0) {
			for (var i=0;i<FixedComponents.elements.length;i++)
				{
					var e = FixedComponents.elements[i];
					if ((e.name != 'allbox') && (e.type=='checkbox') && (e.name != 'ALLINCATEGORY')) {
						e.checked = FixedComponents.allbox.checked;
					}
				}
		//toggleRowColors()
		}
		else {
			document.all.allbox.checked = false;
		}
	}
</SCRIPT>

<CF_MessageWindow>
<cfif NOT isDefined("FORM.FirstTime")>
<cfoutput query="Thequery" group="BSA_Foodservice_Items_Master_ID">

<cfset i =1>
<cfoutput>
	<cfparam name="form.fixed_C#Program_Fixed_Component_Name_Id#_P#replace(Thequery.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#_#i#_rate" default="#Fixed_Price_Value#">
	
	<cfparam name="form.fixed_C#Program_Fixed_Component_Name_Id#_P#replace(Thequery.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#_#i#_uom" default="#Unit_Of_Measure_ID#">

<cfparam name="form.fixed_C#Program_Fixed_Component_Name_Id#_P#replace(Thequery.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#_#i#_volume" default="#volume#">

<cfset i = i+1>
</cfoutput>

</cfoutput>
</cfif>

<cfif isDefined("FORM.FirstTime")>
<cfparam name="Form.DeletedComponentPosition" default="0">
<cfloop list="#Form.Product_List#" index="productId">
	<cfset anyDeleted = 0>
	<cfloop from="1" to="#ListLen(fixed_comp_ids)#" index="i">
	
	<cfset sInputRate1 = buildFixedInputName(ListGetAt(fixed_comp_ids,i), productId, i, "_rate") >		
	<cfset sInputUom1 = buildFixedInputName(ListGetAt(fixed_comp_ids,i), productId, i, "_uom") >
	<cfset sInputVolume1 = buildFixedInputName(ListGetAt(fixed_comp_ids,i), productId, i, "_volume") >

	<cfset sInputRate2 = buildFixedInputName(ListGetAt(fixed_comp_ids,i), productId, i+1, "_rate") >	
	<cfset sInputUom2 = buildFixedInputName(ListGetAt(fixed_comp_ids,i), productId, i+1, "_uom") >
	<cfset sInputVolume2 = buildFixedInputName(ListGetAt(fixed_comp_ids,i), productId, i+1, "_volume") >
	
	<cfif Form.DeletedComponentPosition EQ i>
		<cfset anyDeleted = 1>
	</cfif>
	
	
	<cfif anyDeleted>
		<cfparam name="form.#sInputRate1#" default="">	
		<cfparam name="form.#sInputUom1#" default="">
		<cfparam name="form.#sInputVolume1#" default="">
		<cfset "form.#sInputRate1#" = Evaluate("form.#sInputRate2#")>
		<cfset "form.#sInputUom1#" = Evaluate("form.#sInputUom2#")>
		<cfset "form.#sInputVolume1#" = Evaluate("form.#sInputVolume2#")>
	<cfelse>
		<cfparam name="form.#sInputRate1#" default="">	
		<cfparam name="form.#sInputUom1#" default="">	
		<cfparam name="form.#sInputVolume1#" default="">	
	</cfif>
	
	</cfloop>
</cfloop>
</cfif>

<!--- 	used for business_rule_popup...url could not handle size of list --->
<cfset session.fix_Product_List = form.Product_List>

<SCRIPT>
function verifyData()
{
	var Errcount = 0;
	var srcObj = event.srcElement;
	var thisForm = document.FixedComponents;
	
	<cfloop list="#form.Product_List#" index="prod">
	<cfloop from="1" to="#ListLen(fixed_comp_ids)#" index="compid">
		<cfset InputRate1 = buildFixeddocumentName(ListGetAt(fixed_comp_ids,compid), prod, compid, "_rate") >	
		<cfset InputRate2 = buildFixedInputName(ListGetAt(fixed_comp_ids,compid), prod, compid, "_rate") >	
		
		var spanObj = document.getElementById("SPAN_" + <cfoutput>'#InputRate2#'</cfoutput>);
		if(<cfoutput>#InputRate1#</cfoutput> == "")
		{
			propogateProperty(spanObj, "style.backgroundColor", "#CC99FF", false);
			Errcount++;
		}
	</cfloop>
	</cfloop>
	
	if(Errcount == 0)
	{
		var complistlen = <cfoutput>#ListLen(fixed_comp_ids)#</cfoutput>;
		var prodlenlist;
		if(document.FixedComponents.Product_List.value == "")
		{
			prodlenlist = 0; 
		}
		else 
		{
			prodlenlist = listLength(document.FixedComponents.Product_List.value,",");
		} 
	
		if((complistlen > 0 && prodlenlist > 0) ||(complistlen == 0 && prodlenlist == 0))
		{
			<cfif appSettings.getPaymentCycleAtDiscountType()>
			if(document.all.PaymentCycle.value == "0")
			{
				alert("Select a payment cycle");
			}
			else
			</cfif>
			{
			<cfif compBusRule.getComponentRules(fixed_comp_ids,1).recordcount gt 0><!--- compBusRule.getRules().recordcount --->
			if(bApplyRule())
				{	NewWindow("apply_fixed_rule_popup.cfm?Contract_Main_ID=" + thisForm.Contract_Main_ID.value + "&fixedComponentList=" + thisForm.FixedComponentList.value, "productwindow", 800, 600, "yes", "yes");
					return;
				} 
			</cfif>
				<cfif donotallowaddproductsDE EQ 1>
					if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
				{ document.all.deletedateexclusions.value = 1;</cfif>
				var actionpage;
				actionpage = "contract_fixed_component_save.cfm";
				document.FixedComponents.action = actionpage;
				<cfif programagreed GT 0 and GetContractInfo.modifying_program EQ 0 and GetContractInfo.Contract_Status_Type_IDX EQ 2>
				if(confirm("The <cfoutput>#approvalGroupType.Label#</cfoutput>'s which are you responsible for will have their previous agreements/approvals cleared and reset.  Changes made to this program will require you to agree/approve the <cfoutput>#approvalGroupType.Label#</cfoutput>'s you are responsible for again."))
				{
					document.FixedComponents.submit();
				}
				<cfelse>
				document.FixedComponents.submit();
				</cfif>
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
		alert("Please enter rate for these products");
		return;
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

	//function to set all products checkboxes of same type_code to checked
	function checkMatchingProd(type_code,header)
	{
		var elemColctn2 = document.FixedComponents.getElementsByTagName("input");
		for (var i = 0; i < elemColctn2.length; i++)
		{
			if (elemColctn2[i].id == type_code)
			{
				if (header.checked)
					elemColctn2[i].checked = true;
				else
					elemColctn2[i].checked = false;
			}
		}
	}
	//end check checkmatchingProd()
	
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
	<cfloop list="#fixed_comp_ids#" index="comp_name_id">
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
	<cfloop from="1" to="#ListLen(fixed_comp_ids)#" index="compposition">
	<CFSET comp_name_id = ListGetAt(fixed_comp_ids,compposition)>
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
{	<cfoutput>#NewInputRate#</cfoutput> = document.all.apply_rate.value; }
				
	<cfoutput>#NewUomRate#</cfoutput> = document.all.apply_uom.value;
				}
				</cfloop>
		}
	<CFSET compcount = compcount + 1>
	</cfloop>
	}
	}
	
	
	
	
//function to determine if rules have to be applied	
function bApplyRule() 
{ //return true; }

	var thisForm = document.FixedComponents;
	var rApplyRule = true; //false; was false...removed uom check (commented out below) as I am unsure of what it does mws
	var hasRules = true;
	var compIndx = thisForm.compLen.value;
	var prodIndx = thisForm.prodLen.value;
	
	/*for (var i = 1; i<=compIndx; i++) 
	{
		var tmpComp = eval("thisForm.compHasRules_" + i + ".value");
		var tmpCompUoms = eval("thisForm.lCompRuleUoms_" + i + ".value");
		var tmpReqRules = eval("thisForm.compRulesReq_" + i + ".value");

		//if a components has rules then we have to check for the uom for that product/components combination
		if (tmpComp == 1 && tmpReqRules == 0)
		{
			var uomSelToCheck = eval("thisForm.uomsToCheck_" + i + ".value");
			var bRequired = eval("thisForm.compRulesReq_" + i + ".value");

			//split the list of product/component combination values
			var aProdUom = uomSelToCheck.split(",");
			var aCompUoms = tmpCompUoms.split(",");
			
			//now loop through and find if any of the uom's are percent. if they are, then return true
			for (n =0; n<aProdUom.length;n++)
			{
				
				var fixRule = eval("thisForm.fix_rule_" + aProdUom[n] + ".value");
				var rateVal = eval("thisForm.comp_rate_" + aProdUom[n] + ".value");
				var uomSelected = eval("thisForm.uom_" + aProdUom[n] + ".options[thisForm.uom_" + aProdUom[n] + ".selectedIndex].value");
				//if the uom is in the list, then return true
				for (num=0; num<aCompUoms.length;num++)
				{
					if (uomSelected == aCompUoms[num] && rateVal > 0)
					{
						if(trim(rebRule) == "" && bRequired == 1)
						{
							hasRules = false;
						}
						
						rApplyRule = true;
	
					}
				}
			}
			
		}
	}*/
	
	//if rules already exist then give the option to modify
	if(hasRules && rApplyRule)
	{
		if (!confirm("Click OK to modify Business Rules. Click Cancel to continue."))
		{
			rApplyRule = false;
		}
	}
	
	return rApplyRule;
	
}//end bApplyRule function
</SCRIPT>

<cfset fixedData = fixedCompObj.getFixedData(form.CONTRACT_MAIN_ID,FORM.Product_List)>
<CFOUTPUT><FORM ACTION="Contract_Discount_Fixed_Component_Margin.cfm?CID=#URL.CID#&marginedit_saved=1" METHOD="post" NAME="FixedComponents" ID="FixedComponents" style="display:inline"><strong>1. Add a Fixed</CFOUTPUT> component</strong><br>
<FIELDSET STYLE="padding:10px; width: 700px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Component Information</LEGEND>
 <cfscript>
	GetFixedComponentId = fixedCompObj.getActive(request.AccessStructure.Profiles_ID);
  </cfscript>
	 
	 

  <cfquery name="GetFixedComponentNames" datasource="#application.datasource#">
        SELECT *
		FROM Program_Fixed_Component_Name 
		WHERE 
		Active = 1 
		AND Deleted = 0 
		and Program_Fixed_Component_Name_Id in (#QuotedValueList(GetFixedComponentId.Program_Fixed_Component_Name_Id)#)
  </cfquery> 
<!---   <cfscript>
	GetFixedComponentId = fixedCompObj.getActive(request.AccessStructure.Profiles_ID);
  </cfscript> --->
<table WIDTH="780" border="0" cellpadding="2" cellspacing="0">
	<tr>
<!--- 		<td COLSPAN="2" STYLE="border-bottom:solid 1px blue;"><B>Volumes</B></td>
		<td BGCOLOR="white" ROWSPAN="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td> --->
		<td COLSPAN="4" STYLE="border-bottom:solid 1px blue;display:none;"><B>Components</B></td>
		<td BGCOLOR="white" ROWSPAN="3" STYLE="display:none;">&nbsp;&nbsp;</td>
		  <td COLSPAN="2" STYLE="border-bottom:solid 1px blue;"> 
			<B>Multi Assignment Tool</B>&nbsp;&nbsp;&nbsp;
			<font color="#0000FF" size="3" title="Use this feature to make adjustments to the price/uom for any item/component combinations listed below." STYLE="cursor:pointer">
				<b>?</b>
			</font> 
		  </td>
		<cfif appSettings.getPaymentCycleAtDiscountType()>
		<td BGCOLOR="white" ROWSPAN="3">&nbsp;&nbsp;</td>
		<td><B>Select Payment Cycle</B></td>
		</cfif>
	</tr>
	<tr BGCOLOR="eeeeee">
		<td STYLE="display:none;">Component Name</td>
		<td STYLE="display:none;">Default Price</td>
		<td STYLE="display:none;">UOM</td>
		<TD STYLE="display:none;">Paid To</TD>
		<td colspan="2">Price / UOM</td>
		<cfif appSettings.getPaymentCycleAtDiscountType()>
		<td>
		<cfparam name="FORM.PaymentCycle" 	default="">
		<cf_payment_cycle_selection
			Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
			Program_ID = "#FORM.Contract_Main_ID#"
			discount_Type_ID = "1"
			Selected_Payment_Cycle_ID = "#FORM.PaymentCycle#"
			>
		</td>
		</cfif>
	</tr>
	<TR BGCOLOR="eeeeee">
	<TD STYLE="display:none;">
	  <cfoutput> 
              <select name="Program_Fixed_Component_Name_ID" style="width:180px">
			  	<option value="-1" selected>Select Component</option> 
                <cfloop query="GetFixedComponentNames">
                  <option value="#Program_Fixed_Component_Name_ID#" <cfif GetFixedComponentNames.recordcount EQ 1>selected</cfif>>#Program_Fixed_Component_Name# 
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
	<td STYLE="display:none;"><input name="rate" type="text" size="10" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,4)" /></td>
		<td STYLE="display:none;">
							
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
		<TD STYLE="display:none;">
			<!---check to see if we can select Paid To: Distributor, Operator or both based on Template Generic Type--->
	<cfscript> 
	GetPaymentPaidToTypes = templateManager.GetPaymentPaidToTypes(CSLGetContractInfo.ProgramType_ID);
	</cfscript>
	<cfloop query="GetPaymentPaidToTypes">
	<input name="Fixed_Component_Paid_To" type="Radio" value="<cfoutput>#Payment_Paid_To_ID#</cfoutput>" <cfif GetSettings.PaidToDefaultOption eq Payment_Paid_To_ID>checked</cfif>><cfoutput>#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = Payment_Paid_To_Type_Identifier, paidToDesc=Payment_Paid_To_Type_Name)#</cfoutput><br>
	</cfloop>
		</TD>
		<td align="left"><input name="apply_rate" type="text" size="10" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,4)" />
		
			<cf_uom_dropdown
				program_id				=	"#FORM.Contract_Main_ID#"
				company_main_id			=	""
				default_option_on		=	"0"
				default_option_text		=	""
				default_option_value	=	"0"
				dropdown_name			=	"apply_uom"
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
	</TR>
	<tr BGCOLOR="eeeeee">
		<td colspan="4" STYLE="display:none;"><B><font color="FF0000">[</font> <a onclick="<cfif EzButton_Disable EQ 0>javascript:submitForm();<cfelse>""</cfif>" STYLE="cursor: pointer;">include this component</a> <font color="FF0000">]</font></B></td>
		<td width="27" BGCOLOR="White" STYLE="display:none;">&nbsp;&nbsp;&nbsp;</td>
		<td colspan="2"><B><font color="FF0000">[</font> <a onclick="<cfif EzButton_Disable EQ 0>javascript:applyrate();<cfelse>""</cfif>" STYLE="cursor: pointer;">apply this price / uom</a> <font color="FF0000">]</font></B></td>
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
<td STYLE="display:none;">
<b>
<CF_smallLink 
		title = "Add Products" 
		url = "##"
		parameters = "onClick=""javascript: return showProductSearchWindow();"""
	></b>
</td>
</tr>
</table>
<cfset  component_width = 100>
<table border="0" cellpadding="1" cellspacing="0" bgcolor="ffce84" CLASS="Maintable" width="800">
<tr>
<TD ID="header" WIDTH="15" STYLE="display:none;"><NOBR><img bDelete="true" sMessage="delete all products in this page" src="/images/scissor.gif" title="delete all products in this page" border="0" onclick="deleteAll('Prod_');" style="cursor: pointer;"></NOBR></TD>
<td width="20">
		<input name="prodCheck" type="checkbox" onClick="checkAllProd()" style="display:none;" checked>
		<INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Products" checked>
</td>
<cfoutput><td width="65" ID="header">
<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>#application.returned_customer_setting.upc_label#<br></cfif></cfif></cfoutput><cfoutput>#application.returned_customer_setting.item_label#</cfoutput>#
</td>
<td width="90" ID="header">
Description
</td>
<cfoutput>
<cfif getFixedComponents.Recordcount GT 0>
<cfset j = 0><!--- <cfoutput>#form.fixedcomponentlist#</cfoutput> --->
<cfloop list="#form.fixedcomponentlist#" index="i">

<cfset comp_id_start = Find("_",i)>
<CFSET comp_id = Left(#i#, (#comp_id_start#-1))>
<CFSET paid_to = Mid(#i#,comp_id_start + 1,Len(comp_id))>
	<CFQUERY NAME="getFixedComponentName" datasource="#application.datasource#">
SELECT 	Program_Fixed_Component_Name.Program_Fixed_Component_Name,
Program_Fixed_Component_Name_Id
FROM 	Program_Fixed_Component_Name
WHERE 	Program_Fixed_Component_Name_Id = #comp_id#
		AND Program_Fixed_Component_Name.DELETED = 0
</CFQUERY>
<cfset qGetCompRuleUoms = compBusRule.getCompRuleUoms(#comp_id#)>
<td ID="header" width="#component_width#" nowrap  STYLE="font-size:9px;">
<A STYLE="cursor: pointer;display:none;" ONCLICK="verifyDelete('#getFixedComponentName.Program_Fixed_Component_Name_Id#', '#replace(getFixedComponentName.Program_Fixed_Component_Name, "'", "\'")#',#j#)"><img src="/Images/scissor.gif"  title="delete this component" border="0"></A>

<input name="Comp_#comp_id#_#j#" type="checkbox" value="Comp_#comp_id#_#j#">#Left(getFixedComponentName.Program_Fixed_Component_Name, 10)#</FONT><br>
<div align="center"><cfif paid_to EQ 1>(<b>Dis</b>)<cfelseif paid_to EQ 2>(<b>Opr</b>)<cfelseif paid_to EQ 3>(<b>Brk</b>)<cfelseif paid_to EQ 4>(<b>Dis & Opr</b>)</cfif></div>
</td>
<cfset j = j+1> 
	<cfset fixedData_compNameId = "">
	<cfset fixedData_HasRules = "">
	<cfset fixedData_RulesRequired = "">
	<cfset fixedData_componentPaidTo ="">
	<cfif Not ArrayIsEmpty(fixedData.aComp)>
		<cfset fixedData_compNameId = fixedData.aComp[j].compNameId >
		<cfset fixedData_HasRules = fixedData.aComp[j].HasRules>
		<cfset fixedData_RulesRequired = fixedData.aComp[j].RulesRequired >
		<cfset fixedData_componentPaidTo = fixedData.aComp[j].componentPaidTo>
	</cfif>
	
		<input type="hidden" name="compNameId_#j#" value="#fixedData_compNameId#" />
		<input type="hidden" name="compHasRules_#j#" value="#fixedData_HasRules#" />
		<input type="hidden" name="compRulesReq_#j#" value="#fixedData_RulesRequired#" />
		<input type="hidden" name="lCompRuleUoms_#j#" value="#ValueList(qGetCompRuleUoms.Unit_Of_Measure_ID)#" />
		<input type="hidden" name="compPaidTo_#j#" value="#fixedData_componentPaidTo#" />


	<!--- <cfif ArrayLen(fixedData.aComp) GTE j> 
		<input type="hidden" name="compNameId_#j#" value="#fixedData.aComp[j].compNameId#" />
		<input type="hidden" name="compHasRules_#j#" value="#fixedData.aComp[j].HasRules#" />
		<input type="hidden" name="compRulesReq_#j#" value="#fixedData.aComp[j].RulesRequired#" />
		<input type="hidden" name="lCompRuleUoms_#j#" value="#ValueList(qGetCompRuleUoms.Unit_Of_Measure_ID)#" />
		<input type="hidden" name="compPaidTo_#j#" value="#fixedData.aComp[j].componentPaidTo#" />
	 </cfif> --->
		<cfset "Form.uomsToCheck_#j#" = "" />
		
	
</cfloop>
</cfif>
<td>&nbsp;</td>
</tr>
</table>
<cfset theList = ""/>
<cfif TheQuery.recordcount GT 8>

	<cfset divHght = "height:200px;" />
	<cfset divTableWidth = "800" />
<cfelse>
	<cfset divHght = "" />
	<cfset divTableWidth = "800" />
</cfif>
 	<cfparam name="currentheader" default="">  
	<cfparam name="bgcolor_row" default="1">	
	
	<DIV STYLE="position:relative;overflow:auto;#divHght#"> 
		<table  border="0" cellpadding="1" cellspacing="0" width="800" CLASS="Maintable"></cfoutput>
		  <cfset rowcount = 0>
		  <CFIF TheQuery.recordcount GT 0> 
		  
			<cfoutput query="TheQuery" group="BSA_Foodservice_Items_Master_ID"> 
			<cfif TheQuery.Type_Code_Desc NEQ currentheader>
				<cfset bgcolor_row = 1>
				<cfset currentheader = TheQuery.Type_Code_Desc />
				<cfset currentheader_id = #REREPLACE(trim(TheQuery.Type_Code_Desc),' ','_','ALL')# />
				<tr><td colspan="100%" style="background-color:##ddddee;color:##000000;font-weight:900;font-size:11px;"><input type="checkbox" id="tcHeader_#currentheader_id#" name="type_code_header" value="#currentheader_id#" onClick="checkMatchingProd('#JSStringFormat(currentheader_id)#',this);" checked>&nbsp;#application.returned_customer_setting.TYPE_CODE_LABEL_PLURAL#: #UCASE(TheQuery.Type_Code_Desc)#&nbsp;</td></tr>
			<cfelse>
				<cfset bgcolor_row = bgcolor_row + 1 />
			</cfif> 
			
			<cfif bgcolor_row mod 2>
				<cfset rowBGColor="white" />
			<cfelse>
				<cfset rowBGColor="ccffcc" />
			</cfif>	
			
			  <CFSET FieldNameEnd = replace(TheQuery.BSA_Foodservice_Items_Master_ID,"-","_", "ALL")>
			  <cfset reproduct_id = replace(Thequery.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")>
			  <cfset theList = ListAppend(theList, reproduct_id) />
			  <cfset rowcount = rowcount + 1>
			  <tr BGCOLOR="#rowBGColor#" ID="TR_Products" PRODUCT_ID_RE="#FieldNameEnd#" bDelete="0"> 
				<TD width="15" STYLE="display:none;"><img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif" title="click here to delete this product" border="0" onclick="deleteThisFixedPrice('#FieldNameEnd#', '#TheQuery.BSA_FOODSERVICE_ITEMS_MASTER_ID#')" style="cursor: pointer;"></TD>
				<td width="20"> <input name="Prod_#replace(Thequery.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" id="#currentheader_id#" type="checkbox" value="#replace(Thequery.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" checked> 
				</td>
				<td width="65"><cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1> #TheQuery.UPC#<br> </cfif></cfif>#TheQuery.Item# </td>
				<TD width="90" STYLE="font-size:9px;"> #TheQuery.Description# 
				</TD>
				<cfif getFixedComponents.Recordcount GT 0>
				  <cfloop from="1" to="#ListLen(fixed_comp_ids)#" index="i">
					<cfset currentcompid = ListGetAt(fixed_comp_ids,i)>
					<cfset fixrule = fixedCompObj.getFixProdRule(Thequery.BSA_Foodservice_Items_Master_ID,currentcompid,FORM.Contract_Main_ID)><!--- #fixrule# --->
					
						<cfparam name = "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate" default="#TheQuery.Fixed_Price_Value#">
						<cfparam name = "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_volume" default="#TheQuery.volume#">
						<cfparam name = "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_UOM" default="#TheQuery.Unit_Of_Measure_ID#">
					<!--- <cfif fixrule GT 0> --->
						<cfparam name = "form.fix_rule_C#currentcompid#_P#reproduct_id#_#i#" default="#fixrule#">
					<!--- </cfif> --->
					<td width="#component_width#"> <span id="SPAN_fixed_C#currentcompid#_P#reproduct_id#_#i#_rate"> 
					  <input type="text" size="3" value="#evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate")#" name="fixed_C#currentcompid#_P#reproduct_id#_#i#_rate" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,4)" <cfif EzButton_Disable EQ 1>disabled</cfif>/>
					  </span> <input type="hidden" value="#evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_volume")#" name="fixed_C#currentcompid#_P#reproduct_id#_#i#_volume" />
					<!---   <cfif fixrule GT 0> ---> 
					  <input name="fix_rule_C#currentcompid#_P#reproduct_id#_#i#" type="hidden" value="#evaluate("form.fix_rule_C#currentcompid#_P#reproduct_id#_#i#")#" />
					  	<cfset "Form.uomsToCheck_#i#" = ListAppend(Evaluate("form.uomsToCheck_#i#"), reproduct_id) />
					  <!--- </cfif> --->
					  <cfif #evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom")# EQ "">
						<cfset setDefaultSelected = 1>
					  <cfelse>
						<cfset setDefaultSelected = 0>
					  </cfif> 
		 <cfif EzButton_Disable EQ 1>
		 <cfset disabled = 1>
		 <cfelse>
		 <cfset disabled = 0>
		 </cfif>
			<cf_uom_dropdown
				program_id				=	"#FORM.Contract_Main_ID#"
				company_main_id			=	""
				default_option_on		=	"0"
				default_option_text		=	""
				default_option_value	=	""
				dropdown_name			=	"fixed_C#currentcompid#_P#reproduct_id#_#i#_uom"
				option_text_abbreviated	=	"1"
				plural_uom_display		=	""
				product_type_id			=	"1"
				program_template_id		=	""
				selected_uom_id			=	"#evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom")#"
				text_before_tag_close	=	""
				uom_id_exclusion_list	=	""
				uom_id_inclusion_list	=	""
				setDefaultSelected		= 	"#setDefaultSelected#"	
				Disabled				= 	"#Disabled#"
			> </td>
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
<BR>
<cfoutput>
		<CF_smallLink   
			title = "close window"   
			url = "##"  
			parameters = "onClick=""JavaScript: top.close();if(top.opener){top.opener.focus();};""" 
		>
 <cfif EzButton_Disable EQ 0>
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
<INPUT TYPE="hidden" NAME="ProductCount" VALUE="#TheQuery.Recordcount#">
<INPUT TYPE="hidden" NAME="Contract_Main_ID" VALUE="#FORM.Contract_Main_ID#">
	<INPUT TYPE="Hidden" NAME="Sort_By" 			VALUE="#URL.Sort_By#">
	
	<INPUT TYPE="Hidden" NAME="Program_ID" 			VALUE="#URL.CID#">
	<INPUT TYPE="Hidden" NAME="Product_List" 		VALUE="#Form.Product_List#">
	<input TYPE="Hidden" NAME="FixedComponentList" VALUE="<cfoutput>#form.FixedComponentList#</cfoutput>">
	<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="#Form.Product_List#">
	<INPUT TYPE="Hidden" NAME="DTPS_On" 			VALUE="1">
	<INPUT TYPE="Hidden" NAME="DTPS_Program_ID" 	VALUE="#FORM.Contract_Main_ID#">
	<INPUT TYPE="hidden" NAME="deletedateexclusions" VALUE="0">
<!--- Variable controls redirection to "Margin Edit" version of contract --->
	<INPUT TYPE="Hidden" NAME="RedirectPath" 		VALUE="1" />
	
	<input type="hidden" name="compLen" value="#ArrayLen(FixedData.aComp)#" />
    <input type="hidden" name="prodLen" value="#ArrayLen(FixedData.aProd)#" />
	<input type="Hidden" name="prodList" value="#theList#">
	<!--- <input type="Hidden" name="saveCompData" value="#form.saveCompData#"> --->
</form>

</cfoutput>
</BLOCKQUOTE></BLOCKQUOTE>
<cfif application.programlayout EQ 1></div></cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif programagreed GT 0 and GetContractInfo.modifying_program EQ 0 and GetContractInfo.Contract_Status_Type_IDX EQ 2 and marginedit_saved>
	<cfset overrideClosure = 1>
	<cfset form.programid = '#URL.CID#' />
	<cfinclude template="reset_program_agreed.cfm" />
</cfif>
</BODY>
</HTML>
