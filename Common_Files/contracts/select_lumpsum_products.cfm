<CFSET PAGE_TITLE= "Select Lumpsum Products">
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfparam name="form.Dynamic_Static_Groups" default="0" />
<cfparam name="donotallowaddproductsDE" default = "0">
<cfparam name="form.deletedateexclusions" default = "0">
<cfparam name="url.EZTemplate" default="0">

<!--- Dev Note: Drachala; D27822: Add validation on RFA that lump sum has products START--->
<cfparam name="url.lumpsum_product_error" default="no">
<!--- Dev Note: Drachala; D27822: Add validation on RFA that lump sum has products END--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
<SCRIPT SRC="/script/javascript/dom_common.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
</HEAD>
<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" ONLOAD="">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif url.EZTemplate EQ 0>
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFIF len(URL.CID) EQ 0>
	<CFSET temp = 0>
	<CFELSE>
	<CFSEt temp = cryp.value>
</CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "lump_sums">
<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>
<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
	<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
		<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
	</div>
	<cfelse>
	<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
</cfif>

<!--- reload search list
<cfif isdefined("session.qGetItems")>
	<cfset StructDelete(session,"qGetItems",false) />
</cfif>
	<cfset application.oController.getObject("mvc.models.Item.ItemSearchService") />
	<cfset application.oItemSearchService.getItems(CSL_Contract_Main_ID,3) />
end reload search items--->
 
<cfif CSL_Contract_Main_ID NEQ 0>
	<cfscript>
		contract = CreateObject("component", "components.programs.rebates.Contract");
		GetContractInfo = contract.get(cryp.value);
	</cfscript>
  <cfquery name="GetTemplateInfo" datasource="#application.datasource#">
		SELECT First_parent_ID 
    FROM Program_Control_Panel_Options
    WHERE ProgramControl_Panel_Options_ID = #GetContractInfo.ProgramType_ID#
  </cfquery>
	 
</cfif>
<cfif isDefined("GetTemplateInfo") AND GetTemplateInfo.RecordCount GTE 1>
	<cfset FirstParentID = GetTemplateInfo.First_parent_ID />
<cfelse>
	<cfset FirstParentID = 0 />
</cfif>
 
<cfif GetSettings.Date_Exclusions_ON EQ 1>
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
	<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(CSL_Contract_Main_ID,0)>
	<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
		<cfset donotallowaddproductsDE = 1>
	</CFIF>
</cfif>

	<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
		<div id="Layer1" style="position:relative; height:431px; width:800px; z-index:1; left: 140px; top: 10px;">
	</cfif>
<cfif url.EZTemplate EQ 0>
<blockquote>
	<cfinclude template="minimal_contract_info.cfm">
</cfif>
	<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	The main dispplay part is in an include so that it can be used for just display purposes too
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cfinclude template="lumpsum_products.cfm">
	<CFSET redirector_Program_ID = getContractProgramID.ProgramType_ID>
	<CFSET redirector_FromPage_ID = 7>
	<cfinclude template="internal_redirector_based_on_settings.cfm">
	<!---Javascript--->
	<script>
	function showGroupSearchWindow() 
	{
		//do validation first
		var prodList = document.all.Product_List.value;
		var level1List = document.all.Level_1.value;
		
		//if we have a product list but nothing in level 1 then we can't allow adding groups
		/*76386 :: Ability to add [product group] when items already exist
		if(prodList != "" && level1List == "")
		{
			alert("Groups cannot be added when products exist.");
			return;
		}*/
		NewWindowTopLeft("Groups/index.cfm?formName=MyForm<cfif appSettings.getLumpMultipleProducts() EQ 0>&SelectSingleSearchResultOnly=1</cfif>&programId=<cfoutput>#FORM.Contract_Main_ID#</cfoutput>&Discountype=3&EZTemplate=<cfoutput>#url.EZTemplate#</cfoutput>&component_id=<cfoutput>#form.program_lump_sum_name_id#</cfoutput>", "productwindow", 800, 700, "yes", "yes");
		
	}
	function showProductSearchWindow_old(theFormname) 
	{
		var bSelectedAllProducts = false;
		var groupLevel = 0;
		
		if(document.all.groupLevelProducts)
		{
			if(document.all.groupLevelProducts.value == "1")
			{
				groupLevel = 1;
				bSelectedAllProducts = true;
			}
		}
		
		if(bSelectedAllProducts)
		{
			if(window.confirm("Your current action will remove 'All Products'." + "\n" + "Do you want to continue?"))
			{
				//if groupLevel = 1
				document.all.groupLevelProducts.value = "0";				
				document.all.Product_Level_1.value = "";
				document.all.Product_List.value = "";
				document.all.ExistingProductList.value = "";
				bSelectedAllProducts = false;
			}
		}
	
		if(!bSelectedAllProducts)
		{
			//validate for groups
			var level1List = document.all.Level_1.value;
			
			//if we have product groups then don't allow adding products
			/*76386 :: Ability to add [product group] when items already exist
			if(level1List != "")
			{
				alert("Products cannot be added when Groups exist.");
				return;
			}*/
			<cfif donotallowaddproductsDE EQ 1>
					if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
				{
				 document.all.deletedateexclusions.value = 1;
				NewWindowTopLeft("product_Select_V1.cfm?Formname=" + "MyForm<cfif appSettings.getLumpMultipleProducts() EQ 0>&SelectSingleSearchResultOnly=1</cfif>&Discountype=3&EZTemplate=<cfoutput>#url.EZTemplate#</cfoutput>&component_id=<cfoutput>#form.program_lump_sum_name_id#</cfoutput><Cfif appsettings.getComponent_Product_Restrictions_On() IS 1>&ProductListToExcludeFromSelecting_Field_Name=ProductListToExcludeFromSelecting</CFIF>&FirstParentID=<cfoutput>#FirstParentID#</cfoutput>&prgID=<cfoutput>#CSL_Contract_Main_ID#</cfoutput>", "productwindow", 800, 600, "yes", "yes")
				}
			<cfelse>
				NewWindowTopLeft("product_Select_V1.cfm?Formname=" + "MyForm<cfif appSettings.getLumpMultipleProducts() EQ 0>&SelectSingleSearchResultOnly=1</cfif>&Discountype=3&EZTemplate=<cfoutput>#url.EZTemplate#</cfoutput>&component_id=<cfoutput>#form.program_lump_sum_name_id#</cfoutput><Cfif appsettings.getComponent_Product_Restrictions_On() IS 1>&ProductListToExcludeFromSelecting_Field_Name=ProductListToExcludeFromSelecting</CFIF>&FirstParentID=<cfoutput>#FirstParentID#</cfoutput>&prgID=<cfoutput>#CSL_Contract_Main_ID#</cfoutput>", "productwindow", 800, 600, "yes", "yes")
			</cfif>
		}
	}
	function showProductSearchWindow(theFormname) 
	{
		var bSelectedAllProducts = false;
		var groupLevel = 0;
		
		if(document.all.groupLevelProducts)
		{
			if(document.all.groupLevelProducts.value == "1")
			{
				groupLevel = 1;
				bSelectedAllProducts = true;
			}
		}
		
		if(bSelectedAllProducts)
		{
			if(window.confirm("Your current action will remove 'All Products'." + "\n" + "Do you want to continue?"))
			{
				//if groupLevel = 1
				document.all.groupLevelProducts.value = "0";				
				document.all.Product_Level_1.value = "";
				document.all.Product_List.value = "";
				document.all.ExistingProductList.value = "";
				bSelectedAllProducts = false;
			}
		}
	
		if(!bSelectedAllProducts)
		{
			//validate for groups
			var level1List = document.all.Level_1.value;
			
			//if we have product groups then don't allow adding products
			if(level1List != "")
			{
				alert("Products cannot be added when Groups exist.");
				return;
			}
			<cfif donotallowaddproductsDE EQ 1>
					if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
				{
				 document.all.deletedateexclusions.value = 1;
				NewWindowTopLeft("/Flex/search/ItemSearchFx.cfm?Formname=" + "MyForm<cfif appSettings.getLumpMultipleProducts() EQ 0>&SelectSingleSearchResultOnly=1</cfif>&DiscountType=3&EZTemplate=<cfoutput>#url.EZTemplate#</cfoutput>&component_id=<cfoutput>#form.program_lump_sum_name_id#</cfoutput><Cfif appsettings.getComponent_Product_Restrictions_On() IS 1>&ProductListToExcludeFromSelecting_Field_Name=ProductListToExcludeFromSelecting</CFIF>", "productwindow", 1024, 715, "yes", "yes")
				}
			<cfelse>
				NewWindowTopLeft("/Flex/search/ItemSearchFx.cfm?Formname=" + "MyForm<cfif appSettings.getLumpMultipleProducts() EQ 0>&SelectSingleSearchResultOnly=1</cfif>&DiscountType=3&EZTemplate=<cfoutput>#url.EZTemplate#</cfoutput>&component_id=<cfoutput>#form.program_lump_sum_name_id#</cfoutput><Cfif appsettings.getComponent_Product_Restrictions_On() IS 1>&ProductListToExcludeFromSelecting_Field_Name=ProductListToExcludeFromSelecting</CFIF>", "productwindow", 1024, 715, "yes", "yes")
			</cfif>
		}
	}
	
</script>
	<script>
		<cfoutput>
		function continue_program()
		{
		<cfif url.EZTemplate EQ 0>
			redirectURL = "redirect.cfm?destination=#redirector_NextLocation#&CID=#URL.CID#";
			<cfif qualPopup eq 1>  redirectURL = redirectURL + "&pop019=qualifications"; </cfif>
			location = redirectURL;
		<cfelse>
			location = "contract_discount_lump_sums.cfm?CID=#URL.CID#&EZTemplate=#url.EZTemplate#"
		</cfif>
		}
		function createnew()
		{
		location = "contract_discount_lump_sums.cfm?CID=#URL.CID#&EZTemplate=#url.EZTemplate#"
		}
		</cfoutput>
		
		function selectAll()
		{
			document.all.checkall.checked = event.srcElement.checked;
			
			if(document.all.checkAllProducts.length != null)
			{
				for(var x=0; x<checkAllProducts.length;x++)
				{
					box = getFirstChild(checkAllProducts[x])
					box.checked = document.all.checkall.checked
				}
			}
			else
			{
				if(document.all.checkAllProducts != null)
				{
					box = getFirstChild(checkAllProducts)
					box.checked = document.all.checkall.checked
				}
			}
		}
			
		//TSF: Label 10569 - Function to uncheck all checkboxes for products to prevent products from getting deleted when saving
		function unSelectAll()
		{
			document.all.checkall.checked = false;
			document.all.Delete_Product_Id.checked = false;
		}
			
		function deleteItem() 
			{
				//alert(Not_Any_Object_Checked(document.all.Delete_Product_Id));
				<cfif donotallowaddproductsDE EQ 1>
					if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
					{
						Delete.deletedateexclusions.value = 1;
				</cfif>
				
				<cfif GetSettings.Discount_Lump_Sums_Item_Mandated EQ 1>
					if(!Not_Any_Object_Checked(document.all.Delete_Product_Id))
					{
						if(confirm("Do you really want to delete these items?"))
						{
							Delete.submit();
						}
					}
					else
					{
						alert("You should have at least one product in the list"); 
					}
				<cfelse>
					if(confirm("Do you really want to delete these items?"))
					{
						Delete.submit();
					}
				</cfif>
				
				<cfif donotallowaddproductsDE EQ 1>
					}
				</cfif>
			}
	
		function UpdateItems(){
			// unchecking the select boxes as we use the delete function as if any are checked then 
			// those products are deleted first 
			if(document.all.checkAllProducts.length != null) {
				for(var x=0; x<checkAllProducts.length;x++) {
					box = getFirstChild(checkAllProducts[x])
					box.checked = false;
					document.all.checkall.checked = false;
				}
			}
			document.Delete.UpdateItems.value=1;
			document.Delete.submit();
		} // end: function UpdateItems
		
		function Sample_valid(){
	
			//TSF: Label 10569 - Call function to uncheck any products that may be checked to prevent products from getting deleted when saving
			//unSelectAll();
	
			var ErrorCount = 0;
			var bHundred = verifyPercentage();	
			if (bHundred == false)
			{
				return;	
			}
			<cfif ShowSampleRelated eq 1>
			if(document.all.SampleTypeCollection != null){
				if(SampleTypeCollection.length != null){
					for(var x = 0; x<SampleTypeCollection.length;x++){
						SampleSelected 	= getFirstChild(SampleTypeCollection[x]).value;
						QtySelected 	= getFirstChild(QtyCollection[x]).value;
						UOMSelected 	= getFirstChild(UOMCollection[x]).value;
						MarkUPSelected 	= getFirstChild(MarkUpcollection[x]).value;
	
						error_sSpan 	= document.all.SampleTypeCollectionErrorSpan[x];
						error_qSpan 	= document.all.QtyCollectionErrorSpan[x];
						error_uSpan 	= document.all.UOMCollectionErrorSpan[x];
						error_mSpan 	= document.all.MarkUpCollectionErrorSpan[x];			
						
						// Sample Type selected = 0
						if(SampleSelected == 0){
							ErrorCount++;
							queueMessage("Select a Sample Type", error_sSpan);
						}
						else {
							clearQueue(error_sSpan);
						}// end: if(SampleSelected == 0)
	
						// Sample Type selected = 1 && mark_up = 0
						if(SampleSelected == 1 && MarkUPSelected == 0 ){
							ErrorCount++;
							queueMessage("Enter Mark Up Percentages", error_mSpan);
						}
						else {
							clearQueue(error_mSpan);
						}// end: if(SampleSelected == 0)
						
						//Quantity
						if (QtySelected.length == 0){
							ErrorCount++;
							queueMessage("Enter Sample Quantity", error_qSpan);
						}
						else {
							clearQueue(error_qSpan);
						}// end: if (QtySelected.length ==0)
						
						//UOM
						if (UOMSelected == 0){
							ErrorCount++;
							queueMessage("Select a Unit of Measure", error_uSpan);
						}
						else {
							clearQueue(error_uSpan);
						}// end: if (UOMSelected ==0)
	
							
					} //end for(var x = 0; x<SampleTypeCollection.length;x++)
				}	//end : if(SampleTypeCollection.length != null) 
			} 	// end: if(document.all.SampleTypeCollection != null)
			</cfif>
			// Show Error Message Window
			if(ErrorCount == 0){	
				//submit document
				//UpdateItems();
			<cfif ShowSampleRelated eq 1>
				document.Delete.UpdateItems.value=1;
			</cfif>
				document.Delete.submit();
			}
			else {  
				showMessageWindow();
			}	
		} // end: function Sample_valid()
		
	function verifyPercentage()
	{
		tempHolder = verifySummationAsWhole();
		if(tempHolder == "true") {
				//document.all.MyForm.WeightAssignmentCompleted.value = 1;
			//	document.all.MyForm.LoadSavedDistributors.value = 0;
				//document.all.finishedselectingitems.value = 1;

				//$(".save_table").attr('disabled','true');
/*				disableButton("save_table", true, false);
				disableButton("save_table_2", true, false); */
				// document.all.MyForm.submit();
				document.Delete.submit();
		}
		else if(tempHolder == "false")
		{
			alert("The sum of the supplied Allocation does not equal 100%. Please adjust the Allocation");
			return false;
		}
		else
		{
			if(tempHolder > 0) tempHolder = "+ "+tempHolder;
			else {
				tempHolder = tempHolder * -1
				tempHolder = "- " + tempHolder
			}
			alert("The sum of the supplied Allocation does not equal 100%. Please adjust the Allocation by: " + tempHolder + "%");
			return false;
		}
		return true;
	}		
	
	function verifySummationAsWhole()
	{
		var bErr;
		totalSum=0;
		if(document.all.weightCol)
		{
			if(document.all.weightCol.length != null){
				for(var x=0; x<document.all.weightCol.length; x++){

					weightBox = getFirstChild(document.all.weightCol[x]);
					/*if(weightBox.value.length > 0){
						totalSum = totalSum + parseFloat(weightBox.value);
					}*/		
					if(isFloat(weightBox.value,true) && weightBox.value != 0){
					/* "Weight" textbox is disabled, when there are "distibutor exceptions". */
						if(weightBox.disabled == false){
							totalSum = totalSum + parseFloat(weightBox.value);
						}
						clearQueue(document.all.Er_weightCol[x]);
					}
					else
					{	/* "Weight" textbox is disabled, when there are "distibutor exceptions". */
						if(weightBox.disabled == false){
							bErr = true;
							queueMessage("Invalid Weight", document.all.Er_weightCol[x]);
						}
					}
				}
			}
			else {
				weightBox = getFirstChild(document.all.weightCol);
				/*if(weightBox.value.length > 0){
					totalSum = totalSum + parseFloat(weightBox.value);
				}*/
				if(isFloat(weightBox.value,true) && weightBox.value != 0){
					totalSum = totalSum + parseFloat(weightBox.value);
					clearQueue(document.all.Er_weightCol);
				}
				else
				{
					bErr = true;
					queueMessage("Invalid Weight", document.all.Er_weightCol);
				}
			}
		}
		else
		{
			totalSum = 100;
		}

		totalSum = (totalSum * 100);
		totalSum = Math.round(totalSum)
		totalSum = (totalSum / 100);

		if(bErr)
		{
			//showMessageWindow(); // do not show the popup window
			return "false";
		}
		else if(totalSum == 100){
			return "true";
		}
		else{
			tempData = (parseFloat(100) - totalSum);
			tempData = (tempData * 100);
			tempData = Math.round(tempData)
			tempData = (tempData / 100);
			return tempData;
		}
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
			
		function CheckMarkUp(SampleObj, fldname){
	
			var SampleTypeID = SampleObj.value;
			var MarkUpObj	= document.getElementById(fldname);
			
			if (SampleTypeID == 1){
				MarkUpObj.disabled = false;
			}else {
				MarkUpObj.value = "0.00";
				MarkUpObj.disabled = true;
			}
	
		} // end: function CheckMarkUp()	
		
		function MakeLikeProduct()
		{
			window.document.Delete.action="contract_lumpsum_create_like_product.cfm?CID=<cfoutput>#URL.CID#</cfoutput>";
			window.document.Delete.submit();
		}
		</script>
	<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
		</div>
	</cfif>
</blockquote>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>
<CF_MessageWindow>
</body>
</html>
