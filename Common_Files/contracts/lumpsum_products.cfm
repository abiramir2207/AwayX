<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Document		:	/Common_Files/Contracts/lumpsum_products.cfm
Author			:	Deepa Kunnath
Date Created	:	Nov 18, 2004
Purpose			:	The main display part is in this file so that it can be used for just display purposes too
Arguments		:	URL.LUMP_ID if used for display, if not FORM.Contract_Main_ID
Called from		:
					/Common_Files/Contracts/select_lumpsum_products.cfm (save/delete/select products)
					/Common_Files/Contracts/display_view_program_html.cfm (display products)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<cfparam name="url.EZTemplate" default="0">
<cfparam name="variables.byPassJS" default="0">
<cfparam name="commonqueries_Called" default="0" >
<!--- D36277	Add ”brand” to program view --->
<cfparam name="fromviewprogram" default="0" >
<cfif isDefined("URL.LUMP_ID")>
	<cfset URL.Program_Lump_Sum_ID = URL.LUMP_ID />
	<cfset LumpSumManager = CreateObject("component", "components.programs.lump_sum_components.LumpSumManager") />
	<cfset FORM.Contract_Main_ID = LumpSumManager.getLumpSumProgramID(URL.LUMP_ID) />
	<CF_CRYP type="en" key="#request.key#" string="#FORM.Contract_Main_ID#">
	<cfset URL.CID = cryp.value>
	<cfset displaySaveDeleteButtons = 0>
</cfif>
<cfparam name="CSL_Contract_Main_ID" default="#FORM.Contract_Main_ID#" >

<CFINCLUDE TEMPLATE="/common_files/contracts/commonqueries.cfm">


<SCRIPT SRC="/script/javascript/dhtml.js"></SCRIPT>
<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/common_files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>
<SCRIPT SRC="/common_files/Delete_Functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/Queue.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>

	<!---77408 Product Group sequencing START--->
	<cfset ApplicationSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").get(1) />
	<cfif ApplicationSettingsManager.get_Setting('Product_Group_Sequencing') eq '1'>
		<cfset allow = 1>
	<cfelse>
		<cfset allow = 0>
	</cfif>
	<!---77408 Product Group sequencing END--->
<!---TSF - Label 11541: Added logic to not display this JS code from display_view_program_html.cfm
because it causes the lump sum products to not dispaly when printing.--->
<cfif not variables.byPassJS>

	<SCRIPT LANGUAGE="JavaSCript">

		var my_queue = new Queue();
		var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";


		<!--- Dev Note: Drachala; D27822 : Add validation on RFA that lump sum has products START--->

			function deleteAll()

		{
				<cfif CSLGetContractInfo.Discount_Lump_Sums_Item_Mandated EQ 0>
			var srcObj = event.srcElement;
			var tableObject = getParentObject(getParentObject(srcObj, "tr"), "table");
			//find out if we are deleting or undeleting
			var lumpSumProductList = document.Delete.Existing_Program_Lump_Sum_Product_Data_ID.value;
			var lumpSumDeletList = document.all.Delete_Product_Id.value;
			var existingItemArray = lumpSumProductList.split(",");
			var deleteItemArray = lumpSumDeletList.split(",");
			//guilty until proven innocent
			var bDelete = true;
			document.all.Delete_Product_Id.value = document.Delete.Existing_Program_Lump_Sum_Product_Data_ID.value;
			if(existingItemArray.length == deleteItemArray.length)
			{
				bDelete = false;
				document.all.Delete_Product_Id.value = "";
			}
			for(i=1; i<tableObject.rows.length;i++)
			{
				var trObj = tableObject.rows(i);
				var aImages = trObj.getElementsByTagName("IMG");

				if(bDelete)
				{
					srcObj.title = "undo product deletion";
					srcObj.src = undodeleteImg.src;

					trObj.height = trObj.offsetHeight;
					//trObj.cells[trObj.cells.length-1].innerHTML = empty_String;

					propogateProperty(trObj, "style.backgroundColor", "#DDDDDD", false);
					propogateProperty(trObj, "style.textDecoration", "line-through", true);

					for(n=0; n<aImages.length; n++)
					{
						if(aImages[n].name == "IMG_Delete_Scissor")
						{
							aImages[n].title = "undo product deletion";
							aImages[n].src = undodeleteImg.src;
						}
					}
				}
				else
				{
					var bgCol = "FFFFFF";

					srcObj.title = "delete this product";
					srcObj.src = deleteImg.src;

					propogateProperty(trObj, "style.backgroundColor", bgCol, false);
					propogateProperty(trObj, "style.textDecoration", "none", false);

					propogateProperty(trObj, "style.backgroundColor", "FFFFFF", false, true);

					for(n=0; n<aImages.length; n++)
					{
						if(aImages[n].name == "IMG_Delete_Scissor")
						{
							aImages[n].title = "delete this product";
							aImages[n].src = deleteImg.src;
						}
					}
				}
			}
		<cfelse>
			alert("Lump Sum requires atleast one product to be associated to it.");
		</cfif>
		}
		<!--- Dev Note: Drachala; D27822 : Add validation on RFA that lump sum has products END--->
		function deleteThisProduct(prodID)
		{
			var srcObj = event.srcElement;
			var trObj = getParentObject(srcObj, "tr");
			var trIndex = trObj.rowIndex;
			var resultString = document.Delete.Delete_Product_Id.value;
			var existingDeleteList = document.Delete.Delete_Product_Id.value;
			var itemArray = resultString.split(",");
			//guilty until proven innocent
			var bDelete = 'true';

			for (i =0; i<itemArray.length;i++)
			{
				if(itemArray[i] == prodID)
				{
					var bDelete = 'false';
					resultString = ListDeleteItem(existingDeleteList, ",", prodID);
					<!--- Dev Note: Drachala; D27822 : Add validation on RFA that lump sum has products START--->
					var delete_count = parseInt(document.all.deleteitemcount.value);
					var new_delete_count = delete_count - 1;
					document.all.deleteitemcount.value = new_delete_count;
					<!--- Dev Note: Drachala; D27822 : Add validation on RFA that lump sum has products END--->
					break;
				}

			}
			<!--- Dev Note: Drachala; D27822 : Add validation on RFA that lump sum has products START--->
			<cfif CSLGetContractInfo.Discount_Lump_Sums_Item_Mandated EQ 1>
			if (document.all.deleteitemcount.value == document.all.itemcount.value)
			{
				var bDelete = 'false';
				alert("Lump Sum requires atleast one product to be associated to it.");
			}
			</cfif>
			<!--- Dev Note: Drachala; D27822 : Add validation on RFA that lump sum has products END--->
			if(bDelete == 'true')
			{
				resultString = ListAppendItem(existingDeleteList, ",", prodID);

				var delete_count = parseInt(document.all.deleteitemcount.value);
				<!--- Dev Note: Drachala; D27822 : Add validation on RFA that lump sum has products START--->
				if (document.all.deleteitemcount.value < document.all.itemcount.value)
				{
					var new_delete_count = delete_count + 1;
					document.all.deleteitemcount.value = new_delete_count;
				}
				else
				{
					document.all.deleteitemcount.value = document.all.deleteitemcount.value;
				}
				<!--- Dev Note: Drachala; D27822 : Add validation on RFA that lump sum has products END--->

			}

			document.all.Delete_Product_Id.value = resultString;

			if(trObj)
			{
				if(bDelete == 'true')
				{
					trObj.height = trObj.offsetHeight;
					//trObj.cells[trObj.cells.length-1].innerHTML = empty_String;

					propogateProperty(trObj, "style.backgroundColor", "#DDDDDD", false);
					propogateProperty(trObj, "style.textDecoration", "line-through", true);


					srcObj.title = "undo product deletion";
					srcObj.src = undodeleteImg.src;


				}
				else
				{
					var bgCol = "FFFFFF";

					propogateProperty(trObj, "style.backgroundColor", bgCol, false);
					propogateProperty(trObj, "style.textDecoration", "none", false);

					srcObj.title = "delete this product";
					srcObj.src = deleteImg.src;

					propogateProperty(trObj, "style.backgroundColor", "FFFFFF", false, true);
				}

				event.srcElement.setAttribute('bDelete',(bDelete == 'true'?'false':'true'));
				trObj.setAttribute('bDelete',(bDelete == 'true'?1:0));
			}

		}

		//TSF - Label 10877: Set dollar amount as they enter in the values for Samples
		function adjustThisDollarAmount(fieldName)
		{
			var sampleAmount, sampleUom, sampleMarkUp, sampleCsFOB, sampleLbFOB, dollarAmountSpan, finalValue;
			sampleAmount = parseFloat(eval("document.all.Sample_Qty_" + fieldName + ".value"));
			sampleUom = eval("document.all.Sample_UOM_" + fieldName + ".options[document.all.Sample_UOM_" + fieldName + ".selectedIndex].value");
			sampleMarkUp = parseFloat(eval("document.all.Mark_Up_" + fieldName + ".value"));
			sampleCsFOB = parseFloat(eval("document.all.Sample_CS_FOB_" + fieldName + ".value"));
			sampleLbFOB = parseFloat(eval("document.all.Sample_LB_FOB_" + fieldName + ".value"));
			dollarAmountSpan = eval("document.all.dollarAmount_" + fieldName);
			//for case
			if (sampleUom == 1)
			{
				finalValue = sampleAmount * (parseFloat(sampleCsFOB + (sampleCsFOB * sampleMarkUp)/100));
				finalValue = formatToDecimalPlaces(finalValue, 2);
				finalValue = formatWithComma(finalValue,3);
				dollarAmountSpan.innerText = '$' + finalValue;
			}
			//for lb
			else if (sampleUom = 2)
			{
				finalValue = sampleAmount * (parseFloat(sampleLbFOB + (sampleLbFOB * sampleMarkUp)/100));
				finalValue = formatToDecimalPlaces(finalValue, 2);
				finalValue = formatWithComma(finalValue,3);
				dollarAmountSpan.innerText = '$' + finalValue;
			}
		}
	</SCRIPT>

</cfif>

<cfparam name="exclusionProductListForLumpSum" default="">
<cfparam name="displaySaveDeleteButtons" 	default="1">
<cfparam name="displayLumpSumInfo" 	default="1">
<cfparam name="form.update" default = "1">
<cfparam name="FORM.new_lump_sum_amount" default="">
<cfparam name="FORM.new_lump_sum_volume" default="">
<cfparam name="FORM.Program_Lump_Sum_Name_ID" default="">
<cfparam name="FORM.new_lump_sum_description" default="">
<cfparam name="FORM.Claim_Mechanics" default="0">
<cfparam name="form.component_id"  default="">
<cfparam name="Form.Product_List" default="">
<CFPARAM NAME="Form.Discount_Lump_Sums_Item_Level" DEFAULT="0">
<CFPARAM NAME="Form.Discount_Lump_Sums_Group_Level" DEFAULT="0">
<CFPARAM NAME="form.Product_Group_ID" DEFAULT="">
<CFPARAM NAME="form.Product_Group_Level_ID" DEFAULT="">
<CFPARAM NAME="form.Pricing_Level_ID" DEFAULT="">
<cfparam name="FORM.PaymentCycle" 	default="">
<CFPARAM name="FORM.Component_Paid_To" default="">
<cfparam name="variables.existingProductStructureKeys" default="#structNew()#" />
<cfparam name="form.GL_Account_ID" default="0">
<cfparam name="form.Split_For_Auto_Pay" default="0">
<cfparam name="form.amount_each_period" default="0">
<cfparam name="form.periodCount" default="0">
<cfparam name="form.Vendor_Id" default="">
<!---77408 Product Group sequencing START--->
<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
	<CFPARAM name="form.Level_#levels#" DEFAULT="">
	<CFPARAM name="form.GroupLevel_#levels#" DEFAULT="">
</cfloop>
<!---77408 Product Group sequencing END--->
<!--- Dev Note: KAL; 9896 flag to check if the component is sample related --->
<CFSET ShowSampleRelated = 0 />

<cfset GroupDataManager = CreateObject("component","components.products.Group.DataManager") />
<cfset LumpSumDataManager = CreateObject("component", "components.programs.lump_sum_components.DataManager").init() />
<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset businessSegmentID = businessSegManager.getSegmentIdByProgram(FORM.Contract_Main_ID) />
<cfset bAllowSelectAllProducts = ProductGroupManager.allowSelectAllProducts(3, FORM.Contract_Main_ID) />
<cfparam name="Form.groupLevelProducts" 	default="0">
<cfparam name="Form.Product_Level_1" 	default="">

<cfif not isdefined("CSLGetContractInfo")>
<CFQUERY NAME="CSLGetContractInfo" datasource="#application.datasource#">
	SELECT 	Contract_Main.*,
			Contract_Main_Aux_Data.*
	FROM 	Contract_Main
	LEFT JOIN Contract_Main_Aux_Data
	ON		Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
	WHERE 	Contract_Main.Contract_Main_ID = <cfqueryparam value="#FORM.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">
</CFQUERY>
</cfif>

<cfset ProdManager = CreateObject("component", "components.products.ProductManager").init()>
<cfset SimilarExistingProduct = ProdManager.getSimilarExistingProduct(FORM.Contract_Main_ID)>
<cfset SimilarExistingProductList = ValueList(SimilarExistingProduct.BSA_Foodservice_Items_Master_ID)>


<cfquery name="getContractProgramID" datasource="#application.datasource#">
	SELECT ProgramType_ID
	FROM Contract_Main
	WHERE COntract_Main_ID = '#Form.Contract_Main_ID#'
</cfquery>

<cfquery name="GetSettings" datasource="#application.datasource#">
	SELECT 	Program_Control_Panel_Options.*
	FROM 	Program_Control_Panel_Options
	WHERE 	ProgramControl_Panel_Options_ID = '#getContractProgramID.ProgramType_ID#'
</cfquery>

<!------ Get pricing level descriptions ----->
<cfset qGetPricingLevel = GroupDataManager.getPricingLevel() />
<cfset arPricingLevel = ListToArray(ValueList(qGetPricingLevel.Pricing_Level_Desc, ","), ",") />

<!---set if groups are static or dynamic--->
<cfif isDefined("GetSettings.Dynamic_Static_Groups")>
	<cfset form.Dynamic_Static_Groups = GetSettings.Dynamic_Static_Groups />
</cfif>

<cfset Form.Discount_Lump_Sums_Item_Level = GetSettings.Discount_Lump_Sums_Item_Level />
<cfset Form.Discount_Lump_Sums_Group_Level = GetSettings.Discount_Lump_Sums_Group_Level />


	<cfif isDefined("URL.Program_Lump_Sum_ID")>

		<cfset form.component_id = URL.Program_Lump_Sum_ID>

		<CFQUERY NAME="qGetLumpSums" datasource="#application.datasource#">
			SELECT 	Program_Lump_Sums.*
			FROM 	Program_Lump_Sums
			WHERE 	Program_ID = '#FORM.Contract_Main_ID#'
			AND 	Program_Lump_Sums.DELETED = 0
			AND 	Program_Lump_Sums.Program_Lump_Sum_ID = '#URL.Program_Lump_Sum_ID#'
		</CFQUERY>

		<cfif qGetLumpSums.recordcount GT 0>
			<cfset FORM.new_lump_sum_amount = qGetLumpSums.Lump_Sum_Amount>
			<cfset FORM.Program_Lump_Sum_Name_ID = qGetLumpSums.Program_Lump_Sum_Name_ID>
			<cfset Form.new_lump_sum_volume = qGetLumpSums.Lump_Sum_Volume>
			<cfset FORM.new_lump_sum_description = qGetLumpSums.Lump_Sum_Description>
			<cfset FORM.Claim_Mechanics = qGetLumpSums.Claim_Mechanics>
			<cfset FORM.Component_Paid_To = qGetLumpSums.Component_Paid_to>
		</cfif>

		<cfset thisBAllowSelectAllProducts = bAllowSelectAllProducts />

<!--- Dev Note: Drachala; D27822: Add validation on RFA that lump sum has products START--->
		<cfif isdefined("lumpsum_product_error") AND #lumpsum_product_error# EQ "yes">
			<div style="text-align: center;width= 100%; border: solid; border-color: red; padding-top: 5px; padding-bottom: 5px; font-weight:bold;">
			Lump Sum requires products to be associated to it.
			</div>
		</cfif>
<!--- Dev Note: Drachala; D27822: Add validation on RFA that lump sum has products END--->

		<cfset getLumpSumProducts = LumpSumDataManager.getProgramLumpSumProducts(Program_Lump_Sum_ID, FORM.Contract_Main_ID) />

		<!---if we are using group products then we have to loop over the product query and reset item master dummy id's and put then in the proper level buckets--->
		<cfif Form.Discount_Lump_Sums_Group_Level eq 1>

		<cfloop query="getLumpSumProducts">
			<!---if this condition is met then we know it's a group--->
			<cfif Is_Group eq 1>
				<cfif ApplicationSettingsManager.get_Setting('Product_Group_Sequencing') eq '1'>
					<!---77408 Product Group sequencing START--->
					<cfset "Form.Level_#Pricing_Level_ID#" = ListAppend(Form["Level_#Pricing_Level_ID#"], BSA_Foodservice_Items_Master_ID) />
					<cfset "Form.GroupLevel_#Pricing_Level_ID#" = Product_Group_Level_ID />
					<!---77408 Product Group sequencing END--->
				<cfelse>
					<!---set the product id in product list to the level 1 list--->
					<cfif not ListFindNoCase(Form.Level_1, BSA_Foodservice_Items_Master_ID)>
						<cfset Form.Level_1 = ListAppend(Form.Level_1, BSA_Foodservice_Items_Master_ID) />
						<cfset Form.GroupLevel_1 = Product_Group_Level_ID />
					</cfif>
				</cfif>
			</cfif>
				<!---now append group id to product list--->
				<cfif not ListFindNoCase(Form.Product_List, BSA_Foodservice_Items_Master_ID)>
					<cfset Form.Product_List = ListAppend(Form.Product_List, BSA_Foodservice_Items_Master_ID) />
				</cfif>

			</cfloop>

		<cfelse>

			<cfset Form.Product_List = valuelist(getLumpSumProducts.BSA_Foodservice_Items_Master_ID, ",") />
	</cfif>

		<cfquery name="qGetLevel_1_Products" dbtype="query">
			SELECT	Product_Group_ID
			FROM	getLumpSumProducts
			WHERE Product_Group_Level_ID = 1
		</cfquery>

		<cfset FORM.Product_Level_1 = ValueList(qGetLevel_1_Products.Product_Group_ID) />

		<cfif Len(FORM.Product_Level_1) GT 0>
			<cfset groupLevelProductId = ProductGroupManager.getProductForGroupProducts(1, form.Product_Level_1) />
			<cfset form.Product_List = groupLevelProductId />
			<cfset FORM.groupLevelProducts = 1 />
		</cfif>

		<cfset  bLumpSelectProductsType = ProductGroupManager.lumpSelectProductsType(FORM.Contract_Main_ID, Program_Lump_Sum_ID) />

		<cfif bLumpSelectProductsType GT 0>
			<cfset thisBAllowSelectAllProducts = 0 />
		</cfif>

		<cfset bAllowSelectProducts = 1 />

		<cfif bLumpSelectProductsType GT 1>
			<cfset bAllowSelectProducts = 0 />
		</cfif>

		<!---Query for component--->
		<CFQUERY NAME="getComponent" datasource="#application.datasource#">
			SELECT 	Program_Lump_Sums.*,
					Program_Lump_Sum_Name.Program_Lump_Sum_Name,
					Program_Lump_Sum_Name.Samples_Related,
					Program_Lump_Sum_Name.Manual_LS_Allocation
			FROM 	Program_Lump_Sums
					INNER JOIN Program_Lump_Sum_Name
					ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
			WHERE 	Program_Lump_Sum_ID = '#Program_Lump_Sum_ID#'
			AND 	Program_Lump_Sums.DELETED = 0
		</CFQUERY>

		<CFQUERY name="getProgramInfo" datasource="#application.datasource#">
			SELECT	dbo.Units_of_Measure.Unit_Of_Measure_Desc,	dbo.Units_of_Measure.Abbreviation,		dbo.Contract_Main.Contract_Quantity
			FROM 	dbo.Contract_Main
			INNER JOIN	dbo.Units_of_Measure
			ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID
			WHERE 	dbo.Contract_Main.Contract_Main_ID = '#FORM.Contract_Main_ID#'
		</CFQUERY>

		<!--- Query for Sample_Types --->
		<cfset useLakebaseForQSampleTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("sample_type")>
		<cfif useLakebaseForQSampleTypes>
			<cftry>
				<cfset qSampleTypes = application.oLakebase.toQuery(
					application.oLakebase.selectRows("sample_type", { "select" = "sample_type_id,sample_label", "deleted" = "eq.false" })
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForQSampleTypes = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForQSampleTypes>
		<cfquery name="qSampleTypes" datasource="#application.datasource#">
			Select	Sample_Type_ID, Sample_Label
			From	Sample_Type
			Where	Deleted = 0
		</cfquery>
		</cfif>

		<cfif getComponent.Samples_Related EQ 1 AND GetSettings.Discount_Lump_Sums_Item_Mandated EQ 1 >
			<cfset ShowSampleRelated = 1 />
		</cfif>

	</cfif>
	<cfif not isDefined("appSettings") >
		<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() >
	</cfif>
 <cfif appSettings.getAvoidSharedProductsinLumpSum()>
	 <cfset qExclusionList = LumpSumDataManager.getExcludedProgramLumpSumProducts(form.component_id,FORM.Contract_Main_ID) >
	 <cfif qExclusionList.recordCount gt 0>
		<cfset exclusionProductListForLumpSum = valueList(qExclusionList.BSA_Foodservice_Items_Master_ID) >
	 <cfelse>
		<cfset 	exclusionProductListForLumpSum = "" >
	 </cfif>
 </cfif>
  <!--- BJF D11147 -- if component product restrictions in place, populate list of items not to be selected --->
  <!--- Dev Note: Milan; 12305 - Added this condition(IsDefined("getComponent.Program_Lump_Sum_Name_ID"), so that when
			getsettings.Discount_Lump_Sums_Item_Mandated EQ 1, there is no error --->
 <Cfif appsettings.getComponent_Product_Restrictions_On() IS 1 AND IsDefined("getComponent.Program_Lump_Sum_Name_ID")>

	<cfquery name="ComponentForbiddenProducts" datasource="#application.datasource#">
		SELECT Product_ID
		FROM Component_Products_Restricted
		WHERE Discount_Type_ID = 3 --Growth
		AND Component_ID = '#getComponent.Program_Lump_Sum_Name_ID#'
	</cfquery>

	<cfset ProductForbiddenList = valuelist(ComponentForbiddenProducts.Product_ID)>
	<cfset exclusionProductListForLumpSum = listappend(exclusionProductListForLumpSum,ProductForbiddenList)>
		<input type="hidden" name="ProductListToExcludeFromSelecting" value="#ProductForbiddenList#">
	</CFIF>




 <cfif displaySaveDeleteButtons>
	<FORM ACTION="contract_discount_lump_sums_save_products.cfm" METHOD="post" NAME="MyForm" ID="MyForm" ONSUBMIT="alert();">
	  <cfoutput>
		<INPUT TYPE="hidden" NAME="ExistingProductList" VALUE="#Form.Product_List#">
		<INPUT TYPE="Hidden" NAME="Program_ID" VALUE="#URL.CID#">
		<INPUT TYPE="hidden" NAME="Product_List" VALUE="#trim(Form.Product_List)#">
		<INPUT TYPE="Hidden" NAME="DTPS_On" VALUE="1">
		<INPUT TYPE="Hidden" NAME="DTPS_Program_ID" 				VALUE="#FORM.Contract_Main_ID#">
		<input TYPE="Hidden" NAME="update" VALUE="#form.update#">
		<input TYPE="Hidden" NAME="Program_Lump_Sum_Name_ID" VALUE="#FORM.Program_Lump_Sum_Name_ID#">
		<input TYPE="Hidden" NAME="new_lump_sum_description" VALUE="#Replace(FORM.new_lump_sum_description, """", " ", "all")#">
		<input TYPE="Hidden" NAME="Claim_Mechanics" VALUE="#FORM.Claim_Mechanics#">
		<input TYPE="Hidden" NAME="new_lump_sum_amount" VALUE="#FORM.new_lump_sum_amount#">
		<input TYPE="Hidden" NAME="new_lump_sum_volume" VALUE="#Form.new_lump_sum_volume#">
		<input type="hidden" name="component_id" value"#form.component_id#">
		<input type="hidden" name="Program_Lump_Sum_ID" value="#form.component_id#">
		<INPUT TYPE="Hidden" NAME="Product_Level_1" VALUE="#Form.Product_Level_1#">
		<input type="Hidden" name="groupLevelProducts" value="#Form.groupLevelProducts#" />
		<input type="Hidden" name="PaymentCycle" value="#Form.PaymentCycle#" />
		<input type="Hidden" name="ProductListToExcludeFromSelecting" value="#exclusionProductListForLumpSum#" />
		<input type="hidden" name="Component_Paid_To" value="#Form.Component_Paid_To#" />

		<cfif isDefined("URL.Program_Lump_Sum_ID")>
		  <input type="hidden" name="onlyproducts" value="1">
		</cfif>
		<!---Modification: Group Deals--->
		<INPUT TYPE="Hidden" NAME="Product_Group_ID" VALUE="#form.Product_Group_ID#">
		<input type="hidden" name="Product_Group_Level_ID" value="#form.Product_Group_Level_ID#" />
		<input type="hidden" name="Pricing_Level_ID" value="#form.Pricing_Level_ID#" />
		<input type="Hidden" name="Discount_Lump_Sums_Item_Level" value="#Form.Discount_Lump_Sums_Item_Level#" />
		<input type="Hidden" name="Discount_Lump_Sums_Group_Level" value="#Form.Discount_Lump_Sums_Group_Level#" />
		<input type="Hidden" name="lExcludeFormField" value="1234" />
		<input type="Hidden" name="GroupExclusionList" value="#exclusionProductListForLumpSum#" />



		<input type="hidden" name="deletedateexclusions" value="#form.deletedateexclusions#">
		<INPUT TYPE="Hidden" NAME="EZTemplate" 	VALUE="#url.EZTemplate#">
		<input type="hidden" name="Allow_Multi_Levels" value="#allow#" />
		<input type="hidden" name="Dynamic_Static_Groups" value="#form.Dynamic_Static_Groups#" />
		<input type="hidden" name="GL_Account_ID" value="#form.GL_Account_ID#" />
		<input type="hidden" name="Split_For_Auto_Pay" value="#form.Split_For_Auto_Pay#" />
		<input type="hidden" name="amount_each_period" value="#form.amount_each_period#" />
		<input type="hidden" name="periodCount" value="#form.periodCount#" />
		<!--- D43446 :: Unable to select product groups on lump sum component--->
		<input type="hidden" name="ProductsGroupLevels" value="" />
		<input type="hidden" name="Vendor_ID" value="#form.Vendor_ID#" />
		<!---77408 Product Group sequencing START--->
		<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
			<input type="Hidden" name="Level_#levels#" value="#trim(Form['Level_#levels#'])#" />
			<!---clear groups if levels are empty--->
			<cfif not Len(trim(form['Level_#levels#']))>
				<cfset Form['GroupLevel_#levels#'] eq "" />
			</cfif>
			<input type="hidden" name="GroupLevel_#levels#" value="#Form['GroupLevel_#levels#']#" />
		</cfloop>
		<!---77408 Product Group sequencing END--->
	  </cfoutput>

		<!---If search sequences are on, modify what they're allowed to see (product or group) based on search sequences as well as other template settings--->

		<cfif appSettings.getSearchSequenceOn()>
				<cfset  SearchSequenceManager 	= CreateObject("component", "components.Search_Sequence.SearchSequenceManager").init() />
				<cfset 	Program_Search_Sequence 	= SearchSequenceManager.getSearchSequenceInfo(CSLGETCONTRACTINFO.Search_Sequence_ID) />
				<cfset 	Form.Discount_Lump_Sums_Item_Level =  SearchSequenceManager.enableProductSelection(Program_Search_Sequence) />
				<cfset 	Form.Discount_Lump_Sums_Group_Level = SearchSequenceManager.enableGroupSelection(Program_Search_Sequence) />
		</cfif>
<cfif ((isDefined("getLumpSumProducts") AND getLumpSumProducts.recordcount EQ 0) OR (NOT isDefined("getLumpSumProducts")))>
	<CFSET AverageWeight = 0>
<cfelse>
	<cfset decimalLen = 2 />
	<cfset multiVar = 10 ^ decimalLen />
	<!--- Weight is not applied for "distributor exceptions" and so we need to remove the count of those exceptions. --->
	<CFSET AverageWeight = Fix(Fix((100 / (getLumpSumProducts.recordcount)) * multiVar)/multiVar) />
</cfif>	
<input TYPE="hidden" NAME="globalPercentage" value="">
<span ID="Er_weightCol" style="display:none;"></span>
</FORM>

<cfoutput>
	<cfif Form.Discount_Lump_Sums_Group_Level eq 1>
	<cfset addGroupLabel = "add groups" />
	<cfif appSettings.getPgmGrpsOnlyProdAtLowerLevel()>
		<cfset addGroupLabel = "add #LCase(arPricingLevel[1])# groups" />
	</cfif>
	<a onclick="javascript: showGroupSearchWindow();">#application.util.string.actionLinkFormat("#addGroupLabel#")#</a>
</cfif>
<cfif Form.Discount_Lump_Sums_Item_Level eq 1>
	<cfif appSettings.getFlexProductSearch() and GetSettings.Group_Deal neq 1>
		<a onclick="javascript: showProductSearchWindow();">#application.util.string.actionLinkFormat("select products")#</a>
	<cfelse>
		<a onclick="javascript: showProductSearchWindow_old();">#application.util.string.actionLinkFormat("select products")#</a>
	</cfif>
</cfif>
<cfif ProductGroupManager.allowSelectAllProducts(8, FORM.Contract_Main_ID)>
	<a onclick="javascript: addGroupsLevelProducts(1, \'#businessSegmentID#\');">#application.util.string.actionLinkFormat("add all products")#</a>
</cfif>
</cfoutput>
<cfif ((displaySaveDeleteButtons AND ShowSampleRelated eq 0) AND (Form.Discount_Lump_Sums_Group_Level EQ 1 OR Form.Discount_Lump_Sums_Item_Level EQ 1) AND (isDefined("getComponent.Manual_LS_Allocation") AND getComponent.Manual_LS_Allocation EQ 1))>
	<cfoutput><a onclick="javascript: assignAverageWeight();">#application.util.string.actionLinkFormat("click here to evenly allocate % of LS (<div style='display:inline' id='DivAverageWeight'><cfoutput>#AverageWeight#%</cfoutput></div>)")#</a></cfoutput>
</cfif>

<script>
	function addGroupsLevelProducts(groupLevel, groupId){
		if(window.confirm('Do you want to add all the products?')){
			if(groupLevel != 0){
				var groupIdListObj = eval("document.all.Product_Level_" + groupLevel);
				groupIdListObj.value = groupId;
				document.MyForm.submit();
			}
		}
	}
	
	function assignAverageWeight(){
			averageWeight = formatToDecimalPlaces(parseFloat(document.all.DivAverageWeight.innerText),0);
			document.all.globalPercentage.value = averageWeight;
			callfireEvent(document,document.all.globalPercentage,'keyup');
			
			/* true or false based on browser - IE 10 and above or IE 9 and below. 
			'1' as an argument below means "true". */
			/*document.all.allbox.checked = checkOrUncheckBeforeFireEvent(1);
			callfireEvent(document,document.all.allbox,'Click');
			*/

			assignGlobalWeight(1);
		}	

	function assignGlobalWeight(whereFrom){
			// 31310 - replaced weight percentage handling with jQuery
			var $w_perc;
			var $Last_perc;
			var checked_count = 0;
			// process all tr rows in Maintable table
			$('table.Maintable tbody tr').each(function() {
					// process only rows with checked box
					//if ($(this).find('.check_Each').is(":checked")) {
						// save weight percentage jQuery element on this tr row
						$w_perc = $(this).find('.w_perc');

						/* "Weight" textbox is disabled, when there are "distibutor exceptions". */
						if($($w_perc).prop("disabled") == false)
						{
							// percentage input element exists update it with new value
							if ($w_perc.length) {
								$Last_perc = $w_perc;
								checked_count++;     // keep track on number of checked boxes
								$w_perc.val( document.all.globalPercentage.value ).trigger('onkeyup');
							}
						}
					//}
			});
			// if there is more than 1 checked box and check for adjustment parameter is enabled
			if (checked_count > 1 && whereFrom == 1) {
				var all_percentages = checked_count * parseFloat(document.all.globalPercentage.value);
				// if total of all percentages does not equal to 100 adjust the last percentage
				if ( all_percentages !== 100 ) {
					// total up all percentages except the last one
					var all_except_last = (checked_count - 1) * parseFloat(document.all.globalPercentage.value);
					all_except_last = formatToDecimalPlaces(100 - all_except_last, 0);

					// update last percentage
					$Last_perc.val( all_except_last ).trigger('onkeyup');
				}
			}
		}  // end of assignGlobalWeight()	
	
</script>

</cfif>

<!---Query--->
<cfif isdefined("URL.Program_Lump_Sum_ID")>
<html>
<head>
<title>View <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>	 Products</title>
</head>
<body>
<form action="contract_discount_lump_sums_save_products.cfm" method="Post" name="Delete">
<cfif (isDefined("getLumpSumProducts") AND getLumpSumProducts.recordcount NEQ 0)>
<!---D50884 :: Improvements to the Rebate/Fixed/Lumpsum Pages inside a Program        8.0 Release START--->

<table class="Maintable" width="100%" cellpadding="3" cellspacing="0" border="0">
	<thead>
		<tr bgcolor="#ffce84" valign="bottom" style="font-weight:bold;">
		<cfif displaySaveDeleteButtons>
			<TD ID="header" style="width:20px;">
				<img bDelete="true" sMessage="delete all products in this page" src="/images/scissor.gif" title="delete all products in this page" border="0" onClick="deleteAll();" style="cursor: pointer;">
			</th>
		</cfif>
			<TD ID="header" width="125px">
			<cfoutput>
				<cfif application.appSettingsget.get_Setting('Display_Item_No') eq '1'>
				#REReplace(application.returned_customer_setting.item_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#
				</cfif>
				<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
					<cfif application.appSettingsget.get_Setting('Display_Item_No') eq '1' AND application.returned_customer_setting.upc_switch EQ 1>/</cfif>
					<cfif application.returned_customer_setting.upc_switch EQ 1>
					 #REReplace(application.returned_customer_setting.upc_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#
					</cfif>
				</cfif>
			</cfoutput>
			</th>
			<TD ID="header">Description</th>
			<cfif getComponent.Manual_LS_Allocation EQ 1>
				<TD ID="header">% Allocation of LS</th>
			</cfif>
		<!--- Dev Note:9896 KAL;  Display only if the component is sample related and products required is checked in the template --->
		<cfif ShowSampleRelated eq 1>
			<TD ID="header">Sample Type
			<CF_SmallHelp
			height = ""
			width = "150"
			displayShifyX = "-120"
			displayShifyY = "-150"
			imgPath="/Images/i.gif"
			imgWidth="12"
			imgHeight="11"
			>
			<cfoutput query="qSampleTypes">

			<cfswitch expression="#qSampleTypes.CurrentRow#">
			<cfcase value="1">
			<!--- Purchase Locally --->#Sample_Label# - Select this option when you are obtaining samples from a local distributor or <BR>
			wholesaler. So that the system can capture the estimated cost of the samples, please also <BR>
			provide the mark-up that the local customer will apply<BR><BR>
			</cfcase>
			<cfcase value="2">
			<!--- DC Shipment --->#Sample_Label# - Select this option when you have arranged to have samples shipped to you from <BR>
			an internal distribution center or warehouse.<BR><BR>
			</cfcase>
			<cfcase value="3">
			<!--- Internal Sample --->#Sample_Label# - Select this option when you have arranged for the samples to be shipped to <BR>
			you directly from a plant, pilot plant or R &amp;D Center.<BR>
			</cfcase>
			</cfswitch>

			</cfoutput>
			</CF_SmallHelp>
			</th>
			<TD ID="header">Qty</th>
			<TD ID="header">UOM</th>
			<TD ID="header">Mark Up %</th>
			<TD ID="header">Dollars</th>
		</cfif>
		<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
			<TD ID="header">Similar Product</th>
		</cfif>
			<TD ID="header" style="display:none;"></th>
		</tr>
	</thead>
	<tbody>
	<cfset LoopCount = 0>

	<cfset ExistingPricingLevelList = "">
	<cfset SumProductPercentAllocation = 0 />
	<cfoutput query="getLumpSumProducts">
		  <cfif getLumpSumProducts.Is_Group IS 1>
			<cfif NOT isDefined("FirstParentID")>
				<cfset FirstParentID = 0 />
			</cfif>
			<cfset qGetProduct = GroupDataManager.getByProductGroupData(prodGroupLevelId=getLumpSumProducts.Product_Group_Level_ID, prodGroupId=getLumpSumProducts.Product_Group_ID, addParentName=2, byPassUserClassCodeRestriction=1,FirstParentID= FirstParentID) />
			<cfset thisGroupLevelDesc = GroupDataManager.getProductGroupsData(getLumpSumProducts.Product_Group_Level_ID).Group_Level_Desc />
				<!---if product group level type is 2 then we know it's hierarchy so get the hierarchy id--->

					<cfif qGetProduct.Product_Group_Level_Type eq 2>
						<cfset thisItem = 	qGetProduct.Product_Hierarchy />
					<cfelse>
						<cfset thisItem = 	getLumpSumProducts.Group_Number />
					</cfif>
					<cfset thisUPC 	=  	"N/A" />
					<cfset thisDesc	=	qGetProduct.Group_Level_Desc />
					<cfset this.isGroup  =	1 />
					<cfset this.productGroupLevelTypeId = qGetProduct.Product_Group_Level_Type />
					<cfset thisItemID	=	qGetProduct.Product_Group_ID />
					<cfset thisPerAllocLS = getLumpSumProducts.Product_Percent_Allocation />
				<!---this is for all products--->
				<cfelseif Product_Group_Level_ID eq 1>
					<cfset qGetProduct = ProductGroupManager.getProductGroupDetails(getLumpSumProducts.Product_Group_Level_ID, getLumpSumProducts.Product_Group_ID) />
					<cfset thisItem = 	qGetProduct.item />
					<cfset thisUPC 	=  	qGetProduct.upc />
					<cfset thisDesc	=	qGetProduct.description />
					<cfset thisItemID	=	qGetProduct.BSA_Foodservice_Items_Master_ID />
					<cfset this.isGroup  =	0 />
					<cfset thisGroupLevelDesc = "Product" />
					<cfset thisPerAllocLS = getLumpSumProducts.Product_Percent_Allocation />
				<!---this is for item/product/sku--->
		<cfelse>
				<cfset ThisItem 	=	getLumpSumProducts.item />
				<cfset ThisUPC 		=	getLumpSumProducts.upc />
				<cfset thisItemID	=	getLumpSumProducts.BSA_Foodservice_Items_Master_ID />
				<!--- Dev Note: KAL; 9896 --->
				<cfset thisSample_Type_ID	=	getLumpSumProducts.Sample_Type_ID />
				<cfset thisSample_Qty		=	getLumpSumProducts.Sample_Qty />
				<cfset thisMark_Up_Percent	=	getLumpSumProducts.Mark_Up_Percent />
				<cfset thisTotal_Price		=	getLumpSumProducts.Sample_Total_Price />
				<cfset thisNet_Weight		=	getLumpSumProducts.Net_Weight />
				<cfset thisSample_UOM		=	getLumpSumProducts.Sample_UOM />
				<cfset thisDesc				=	getLumpSumProducts.Description />
				<cfset thisPerAllocLS 		= getLumpSumProducts.Product_Percent_Allocation />
				<cfset thisGroupLevelDesc = "Product" />
		  </CFIF>
			<cfset fieldname = replace(Program_Lump_Sum_Product_Data_ID, "-", "_", "ALL")>
			<cfset structInsert(variables.existingProductStructureKeys, Program_Lump_Sum_Product_Data_ID, "", "true") />
	<cfset LoopCount =LoopCount + 1>
	<cfset SumProductPercentAllocation =  SumProductPercentAllocation + getLumpSumProducts.Product_Percent_Allocation />
	<!--- Dev Note (77408): When "Product_Group_Sequencing" app setting is ON and one group of one pricing level has not already been added to "ExistingPricingLevelList".
	This logic is needed so that we can only show the "group_level_desc" once for all the groups belonging to a single pricing level.
	Note: we set "LoopCount" back to 1, so that the color coding can restart for a new group.
	thisGroupLevelDesc i.e., "group_level_desc" is shown on a single row.
	--->
	<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1' AND ListFind(ExistingPricingLevelList,getLumpSumProducts.Pricing_level_ID) eq 0>
	<cfset LoopCount = 1>
	<tr bgcolor="##92B792" ><td colspan="100%">#thisGroupLevelDesc#</td></tr>
		<cfset ExistingPricingLevelList = ListAppend(ExistingPricingLevelList,getLumpSumProducts.Pricing_level_ID)>
	</cfif>
	<tr BGCOLOR="#IIf(LoopCount Mod 2, DE('ffffff'), DE('C6FFC6'))#" ID="TR_Products" PRODUCT_ID_RE="#fieldname#" bDelete="0" <cfif Is_Group>ONMOUSEOVER="menuID=11;URLstring='';an_ID='#Product_Group_ID#&Group_Level_ID=#Product_Group_Level_ID#&Program_ID=#FORM.Contract_Main_ID#&producttype_id=3';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;"</cfif>>
		<cfif displaySaveDeleteButtons>
			<td>
				<img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif" title="click here to delete this product" border="0" onClick="deleteThisProduct('#Program_Lump_Sum_Product_Data_ID#')" style="cursor: pointer;">
			</td>
		</cfif>
			<td>
				<cfif application.appSettingsget.get_Setting('Display_Item_No') eq '1'>
				#ThisItem#<br>
				</cfif>
				<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
					<cfif application.returned_customer_setting.upc_switch EQ 1>
						#ThisUPC#
					</cfif>
				</cfif>
			</td>
			<td>
				#thisDesc#
				<cfif appsettings.getShowBrandOnViewProgram() EQ 1>
					<!--- gather brand information for a single item --->
					<cfquery name="variables.qBrand" datasource="#application.datasource#">
						SELECT Brand.Brand_Name
						FROM BSA_Foodservice_Items_Master a
						INNER JOIN Brand
						ON a.Brand_ID = Brand.Brand_ID
						WHERE BSA_Foodservice_Items_Master_ID = '#thisItemID#'
					</cfquery>
					<cfif variables.qBrand.recordcount>&nbsp;&nbsp;(#variables.qBrand.Brand_Name#)</cfif>
				</cfif>

				<cfif url.EZTemplate EQ 1 AND displaySaveDeleteButtons>
					<input type="hidden" name="Prod_Id" value="#thisItemID#">
				</cfif>
			</td>
			<cfif (getComponent.Manual_LS_Allocation EQ 1)>
				<td>
				<cfif ((displaySaveDeleteButtons AND ShowSampleRelated eq 0) AND (Form.Discount_Lump_Sums_Group_Level EQ 1 OR Form.Discount_Lump_Sums_Item_Level EQ 1))>
					<span ID="weightCol"><input type="Text" class="box w_perc" name="PerAllocLS_#fieldname#" id="PerAllocLS_#fieldname#" size="3"   
						 onkeyup="clenseText(this, '0123456789');allowonlytwodecimalplaces(this);" onChange="adjustThisDollarAmount('#fieldname#');" value="#trim(numberformat(thisPerAllocLS,'___,___,___,___,___'))#" ></span>
				<cfelse>
					#trim(numberformat(thisPerAllocLS,'___,___,___,___,___'))#&nbsp;%
				</cfif>
				</td>
			</cfif>
		<cfif ShowSampleRelated eq 1>
			<td>
				<cfstoredproc procedure="GET_PROGRAM_PRODUCT_PRICE" datasource="#application.datasource#">
					<cfprocparam type = "IN" 		CFSQLType ="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value="#FORM.Contract_Main_ID#" null="NO">
					<cfprocparam type = "IN" 		CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@@PRODUCT_ID" value="#BSA_Foodservice_Items_Master_ID#" null="NO">
					<cfprocparam type = "OUT" 	CFSQLType ="CF_SQL_FLOAT" variable="CS_FOB_Price" dbVarName = "@@CS_PRICE" null="NO">
					<cfprocparam type = "OUT" 	CFSQLType ="CF_SQL_FLOAT" variable="LB_FOB_Price" dbVarName = "@@LB_PRICE" null="NO">
				</cfstoredproc>
				<input type="hidden" name="Sample_CS_FOB_#fieldname#"  value="#CS_FOB_Price#">
				<input type="hidden" name="Sample_LB_FOB_#fieldname#"  value="#LB_FOB_Price#">
				<cfif displaySaveDeleteButtons>
				<span id="SampleTypeCollection">
					<select name="Sample_Type_#fieldname#" style="width:120px;" onChange="CheckMarkUp(this, 'Mark_Up_#fieldname#')">
						<option value="0">&nbsp;&nbsp;</option>
						<cfloop query="qSampleTypes">
							<option value="#Sample_Type_ID#" <cfif thisSample_Type_ID eq Sample_Type_ID>selected</cfif>>#Sample_Label#</option>
						</cfloop>
					</select>
				</span>
				<cfelse>
					<cfloop query="qSampleTypes">
						<cfif thisSample_Type_ID eq Sample_Type_ID>#Sample_Label#</cfif>
					</cfloop>
				</cfif>&nbsp;<SPAN id="SampleTypeCollectionErrorSpan"></SPAN>
			</td>
			<td>
				<cfif displaySaveDeleteButtons>
					<span id="QtyCollection">
						<input type="Text" class="box" name="Sample_Qty_#fieldname#" size="3" onChange="adjustThisDollarAmount('#fieldname#');" onKeyUp="clenseText(this, '0123456789');" value="#thisSample_Qty#">
					</span>
				<cfelse>
					#trim(numberformat(thisSample_Qty,'_-___,___,___,___,___.__'))#
				</cfif>&nbsp;<SPAN id="QtyCollectionErrorSpan"></SPAN>
			</td>
			<td>
				<cfif displaySaveDeleteButtons>
					<span id="UOMCollection">
						<cf_uom_dropdown
						company_main_id			=	""
						default_option_on		=	"1"
						default_option_text		=	"Choose"
						default_option_value	=	"0"
						dropdown_name			=	"Sample_UOM_#fieldname#"
						option_text_abbreviated	=	""
						product_type_id			=	""
						program_template_id		=	"#getContractProgramID.ProgramType_ID#"
						selected_uom_id			=	"#thisSample_UOM#"
						text_before_tag_close	=	"STYLE=""width:65px;"""
						uom_id_exclusion_list	=	"3"
						uom_id_inclusion_list	=	""
						onChange				=	"adjustThisDollarAmount('#fieldname#');"
						>
					</span>
				<cfelse>
					<cfset useLakebaseForGetSampleUOMDesc = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("units_of_measure")>
					<cfif useLakebaseForGetSampleUOMDesc>
						<cftry>
							<cfset getSampleUOMDesc = application.oLakebase.toQuery(
								application.oLakebase.selectRows("units_of_measure", { "select" = "unit_of_measure_desc,abbreviation", "unit_of_measure_id" = "eq.#thisSample_UOM#" })
							)>
							<cfcatch type="any">
								<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
								<cfset useLakebaseForGetSampleUOMDesc = false>
							</cfcatch>
						</cftry>
					</cfif>
					<cfif NOT useLakebaseForGetSampleUOMDesc>
					<CFQUERY NAME="getSampleUOMDesc" datasource="#application.datasource#">
						SELECT	Units_of_Measure.Unit_Of_Measure_Desc,Units_of_Measure.Abbreviation
						FROM 	Units_of_Measure
						WHERE 	Units_of_Measure.Unit_Of_Measure_ID = #thisSample_UOM#
					</CFQUERY>
					</cfif>
					#getSampleUOMDesc.Unit_Of_Measure_Desc#
				</cfif>&nbsp;<SPAN id="UOMCollectionErrorSpan"></SPAN>
			</td>
			<td>
			<cfif displaySaveDeleteButtons>
				<span id="MarkUpcollection">
					<input type="Text" class="box" name="Mark_Up_#fieldname#" id="Mark_Up_#fieldname#" size="3"  <cfif thisSample_Type_ID NEQ 1>disabled</cfif>
					 onkeyup="clenseText(this, '.0123456789');allowonlytwodecimalplaces(this);" onChange="adjustThisDollarAmount('#fieldname#');" value="#trim(numberformat(thisMark_Up_Percent,'_-___,___,___,___,___.__'))#" >
				</span>
			<cfelse>
				#trim(numberformat(thisMark_Up_Percent,'_-___,___,___,___,___.__'))#&nbsp;%
			</cfif>&nbsp;<SPAN id="MarkUpCollectionErrorSpan"></SPAN>
			</td>
			<td>
				<span id="dollarAmount_#fieldname#">$#trim(numberformat(thisTotal_Price,'_-___,___,___,___,___.__'))#</span>&nbsp;
				<input type="Hidden" name="Net_Weight_#fieldname#" value="#thisNet_Weight#" >
			</td>
		</cfif>
		<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
			<td>
				<cfif ListFind(SimilarExistingProductList,thisItemID) neq 0>
					&nbsp;Yes&nbsp;
				<cfelse>
					&nbsp;No&nbsp;
				</cfif>&nbsp;
			</td>
		</cfif>
			<td style="display:none;">
				<INPUT TYPE="hidden" NAME="thisItemID" VALUE="#Program_Lump_Sum_Product_Data_ID#_#thisItemID#">
			</td>
		</tr>
	</cfoutput>
	<tbody>
</table>

<!--- Dev Note: Drachala; D27822 : Add validation on RFA that lump sum has products START--->
<input type="hidden" name="itemcount" value="<cfoutput>#getLumpSumProducts.recordcount#</cfoutput>">
<input type="hidden" name="deleteitemcount" value= 1>
<!--- Dev Note: Drachala; D27822 : Add validation on RFA that lump sum has products END--->
</cfif>

<input type="hidden" name="Delete" value="yes">
<input type="hidden" name="UpdateItems" value="1"> <!--- This was 0 earlier --->
<input type="hidden" name="onlyproducts" value="1">
<input type="hidden" name="Delete_Product_Id">
<cfoutput>
<input type="hidden" name="ShowSampleRelated" value="#ShowSampleRelated#" />
<input type="hidden" name="Existing_Program_Lump_Sum_Product_Data_ID" value="#structKeyList(variables.existingProductStructureKeys)#">
<input type="Hidden" name="Contract_Quantity_UOM_IDX" value="#CSLGetContractInfo.Contract_Quantity_UOM_IDX#">
<input type="hidden" name="Program_ID" value="#URL.CID#">
<input type="hidden" name="Program_Lump_Sum_ID" value="#Program_Lump_Sum_ID#">
<input type="hidden" name="deletedateexclusions" value="0">
<INPUT TYPE="hidden" NAME="Is_Like_Product_Exist" VALUE="#CSLGetContractInfo.Like_Product_Exist#">
<INPUT TYPE="Hidden" NAME="EZTemplate" 	VALUE="#url.EZTemplate#">
</cfoutput>
</form>
<cfif displaySaveDeleteButtons>
<cfoutput>
		<cfif not ShowSampleRelated>
			<A STYLE="cursor:pointer;" ONCLICK="deleteItem();">#application.util.string.actionLinkFormat("delete selected products")#</A>&nbsp;&nbsp;
		</cfif>
		<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
			<A STYLE="cursor:pointer;" ONCLICK="MakeLikeProduct();">#application.util.string.actionLinkFormat("Mark as similar product")#</A>&nbsp;&nbsp;
		</cfif>
		<cfif (ShowSampleRelated eq 1 or url.EZTemplate EQ 1) OR (displaySaveDeleteButtons AND ShowSampleRelated eq 0) AND (Form.Discount_Lump_Sums_Group_Level EQ 1 OR Form.Discount_Lump_Sums_Item_Level EQ 1)>
			<A STYLE="cursor:pointer;" ONCLICK="Sample_valid();">#application.util.string.actionLinkFormat("save")#</A>&nbsp;&nbsp;
		</cfif>
		<A STYLE="cursor:pointer;" ONCLICK="javascript: createnew();">#application.util.string.actionLinkFormat("create new")#</A>&nbsp;&nbsp;
		<cfif (ShowSampleRelated eq 0 AND (getComponent.Manual_LS_Allocation EQ 1 AND SumProductPercentAllocation EQ 100))>
			<A STYLE="cursor:pointer;" ONCLICK="javascript: continue_program();">#application.util.string.actionLinkFormat("continue")#</A>&nbsp;&nbsp;
		</cfif>
</cfoutput>

<cfsavecontent variable="LSInfo">
	 <cfif displayLumpSumInfo>
	 	 <cfoutput>
			#getComponent.Program_Lump_Sum_Name#
			<cfif len(getComponent.Lump_Sum_Description)>
			&nbsp;&nbsp;(#getComponent.Lump_Sum_Description#)
			</cfif>
			&nbsp;&nbsp;&nbsp;&nbsp;
			#lsCurrencyFormat(getComponent.Lump_Sum_Amount)#
		</cfoutput>
	  </cfif>
</cfsavecontent>

<cfinclude template="/Common_Files/jQuery.cfm">
<cfinclude template="/Common_Files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/script/javascript/jquery.noty.packaged.min.js"></script>
<script>
oTable = $('.datagrid').dataTable( {
      "bServerSide": false
    , "bProcessing": true
    , "bSortClasses": false
    , "bAutoWidth": false
    , "bPaginate": false
    , "oLanguage": {"sSearch": "<b>Search:</b>"}
    , "sDom": "f<'lsinfo'>prt"
    , "aaSorting": []
    , "aoColumns": [
                               <cfif displaySaveDeleteButtons>
								      {"bSearchable": false,      "bSortable":false}
                              ,
							  </cfif>
							  		 {"bSearchable": true,       "bSortable":true}
                              ,      {"bSearchable": true,       "bSortable":true}
							  <cfif ShowSampleRelated eq 1>
                              ,      {"bSearchable": false,       "bSortable":false}
                              ,      {"bSearchable": false,       "bSortable":false}
                              ,      {"bSearchable": false,      "bSortable":false}
                               ,     {"bSearchable": false,       "bSortable":false}
                              ,      {"bSearchable": false,      "bSortable":false}
                              </cfif>
                              <cfif CSLGetContractInfo.Like_Product_Exist eq 1>
                              ,      {"bSearchable": false,       "bSortable":false}
                              </cfif>
                              ,      {"bSearchable": false,       "bSortable":false}
                            ]
      	} ).fnSetFilteringDelay();
<cfoutput>
$('div.lsinfo').html('#application.util.string.compress(LSInfo)#');
</cfoutput>
</script>
<!---D50884 :: Improvements to the Rebate/Fixed/Lumpsum Pages inside a Program        8.0 Release END--->
</cfif>
</body>
</html>
</cfif>