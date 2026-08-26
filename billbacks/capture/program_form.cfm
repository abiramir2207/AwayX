<!--- <cfsilent> --->
<!---
Name: 			program_form.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:	N/A
Created By:		N/A     
Description:	This file is responsible for handling programs that are being billbacked against.  
--->

<cfparam name="URL.BBID" default="">
<cfparam name="rebateActionLabel" default="save">
<cfparam name="form.Last_Date_To_Claim" default="0" />
<cfset form.prodUpdate = 0 />
<cfparam name="url.xl" default="0">
<cfset variables.xl = url.xl>
<cfparam name="ListProgramDiscountTypes" default="" />
<cfparam name="form.ProgramToSwitch" default="0">
<cfparam name="temp_ExistingProductList_On_Program" default="" />
<cfparam name="showProductInfo" default="false" />
<cfparam name="form.ExistingProductList" default="" />
<cfparam name="claimRate" default="0" />
<cfparam name="TotalRebate" default="0" />
<cfparam name="RebateUpdateAllowed" default="0" />
<cfparam name="BB_ID" default="" />
<cfparam name="FiltersList" default="">
<cfset bDivestedNote = 0 />
<cfset BBProductCount = 0>

<!--- GET THE BILLBACK ID --->
<CFIF IsDefined("FORM.Billback_ID")>
	<CFIF FORM.Billback_ID neq "" AND  FORM.Billback_ID neq 0>
		<CFSET BB_ID = FORM.Billback_ID>
	</CFIF>
</CFIF>

<!--- Whether the billback ID passes through the form, or in some other way, it gets stored in BB_ID --->
<CFIF BB_ID eq "" OR BB_ID eq 0>
		<CFIF BBID neq "" AND BBID NEQ 0>
			<CFSET BB_ID = BBID>
	</CFIF>
</CFIF>

<cfset useLakebaseForGetValidDiscountsforProductBB = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_product_discount")>
<cfif useLakebaseForGetValidDiscountsforProductBB>
	<cftry>
		<cfset GetValidDiscountsforProductBB = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_product_discount", {
				"billback_id" = "eq.#BB_ID#",
				"limit" = "1",
				"select" = "billback_id"
			}), "billback_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetValidDiscountsforProductBB = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetValidDiscountsforProductBB>
<cfquery name="GetValidDiscountsforProductBB" datasource="#application.datasource#">
	SELECT top 1 Billback_ID
	FROM BB_Product_Discount
	WHERE Billback_ID = '#BB_ID#'	
</cfquery>
</cfif>

<cfset GetValidDiscountsforProduct = QueryNew("Discount_List") />

<!--- Get a list of programs --->
<cfset useLakebaseForgetProgramCount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForgetProgramCount>
	<cftry>
		<cfset getProgramCount = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program", {
				"billback_id" = "eq.#BB_ID#",
				"deleted" = "eq.0",
				"select" = "program_id"
			}), "program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetProgramCount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetProgramCount>
<CFQUERY NAME="getProgramCount" DATASOURCE="#Application.Datasource#">
 SELECT Program_ID
 FROM Billback_Program
 WHERE billback_id = '#BB_ID#'
 AND deleted = 0
</CFQUERY>
</cfif>

<!--- While adding (modifying) products on this page, get the number of products being added --->
<cfif IsDefined('form.fieldnames') AND ReFindNoCase('Product_list_',form.fieldnames) NEQ 0>
<!--- Get a count of customers --->
	<CFQUERY NAME="getCustomerCount" DATASOURCE="#Application.Datasource#">
		 SELECT 	COUNT(CAST(Distributor_ID As varchar(50))) As Dist_Count
		 FROM 		Billback_Distributor_List 
		 WHERE 		Billback_ID = '#BB_ID#'
		 AND DELETED = 0
	</CFQUERY>

<!--- If there are multiple distributors, get that count, else assume it's 1 --->
		<cfset Dist_Count = getCustomerCount.Dist_Count>
		<cfif Dist_Count eq 0>
			<cfset Dist_Count = 1>
		</cfif>

	<!---	Get the total of all the product entries on the page based on the variable 'Product_list_ProgramID'. There
				could be multiple varibles for multiple programs. 
	--->
	<cfset BBProductList = "">
	<cfloop query="getProgramCount">
		<cfif IsDefined('Product_list_#getProgramCount.Program_ID#')>
			<cfset BBProductCount = BBProductCount + (ListLen(Evaluate('Product_list_#getProgramCount.Program_ID#')) * Dist_Count)>
			<cfset BBProductList = ListAppend(BBProductList,Evaluate('Product_list_#getProgramCount.Program_ID#'))>
		</cfif>
	</cfloop>

<!--- In case the 'Product_list_ProgramID' variables are blank, then 'Product_list' variable might have entries. --->
	<cfif BBProductCount eq 0>
	<cfif ListLen(Product_list)>
		<cfset BBProductCount = ListLen(Product_list) * Dist_Count>
	<cfelse>
		<cfset BBProductCount = 1>
	</cfif>
	<cfelse>

<!--- There might be products not existing in 'Product_list_ProgramID' variable, but do exist in the 'Product_list' variable. 
			If that's the case, then add those products to the product count too.
--->
			<cfloop list="#Product_list#" index="i">
					<cfif ListFindNoCase(BBProductList, i) eq 0>
							<cfset BBProductCount = BBProductCount + (1 * Dist_Count)>
					</cfif>
			</cfloop>
				
	</cfif>

<cfelse>
<!--- If the page is being loaded when the user clicks on the "programs" page --->
	<!--- Get the count for saved products --->
		<CFQUERY NAME="getProductCount" DATASOURCE="#Application.Datasource#">
		 SELECT 	COUNT(*) As BBProductCount
		 FROM 		Billback_Product 
		 WHERE 		Billback_Product.Billback_ID = '#BB_ID#'
		 AND Billback_Product.Deleted = 0
		</CFQUERY>

	<!---	Get the total of all the product entries on the page --->
	<cfset BBProductCount = getProductCount.BBProductCount>
</cfif>

<!--- We need the product entries count for two reasons:
			- The progress bar is for product entries of 10 or more.
			- When looping through the products, we need the total count for the product entries in advance
--->
<!----------------- Add Progress Bar ------------------------>
<cfif BBProductCount GTE 10>
	<CFINCLUDE TEMPLATE="/includes/progress_bar.cfm">
</cfif>

<cfset billbackProgramManager = CreateObject("component", "components.billback.Programs.BillbackProgramsManager").init() />
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset billbackManager = CreateObject("component", "components.billback.BillbackManager").init() />
<cfset objProgram = CreateObject("component", "components.programs.program") />
<cfset bbDeviationManager = CreateObject("component", "components.billback.BillbackDeviationManager").init() />
<cfset variables.billBackProgramsProducts = createObject("component","components.Billback.Programs.Billback_Programs_Products").init() />
<cfset appSettings = application.appSettingsGet>
<cfset getProductData = QueryNew('temp') />
<cfset HasDefaultProgram = 0 />
<cfset defaultProgramMessage = "" />



<!--- Get the Billback profile setting --->
<cfset BB_User_Profile = CreateObject("component", "components.user.profile").getProfileSettings(request.Accessstructure.Profiles_ID)>
<CFIF URL.BBID NEQ "">
	<cfset useLakebaseForCheckCopiedBB = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForCheckCopiedBB>
	<cftry>
		<cfset CheckCopiedBB = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#URL.BBID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckCopiedBB = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckCopiedBB>
<CFQUERY NAME="CheckCopiedBB" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Billback WHERE Billback_ID = '#URL.BBID#'
	</CFQUERY>
</cfif>

	<CFIF CheckCopiedBB.CopiedBB NEQ "" AND CheckCopiedBB.BB_Start_Date EQ "">
		<CFLOCATION URL="basic_information_form.cfm?BBID=#URL.BBID#" ADDTOKEN="No">
	</CFIF>
	<cfset HasDefaultProgram = billbackManager.getBillbackDefaultProgram(URL.BBID) />
	<cfset defaultProgramMessage = "The billback 'programs' page cannot be saved until you transfer all records off of the default program." />
</CFIF>

<CFSET Total_Of_Rates 	= 0>
<CFSET Total_Of_Volume 	= 0>
<CFSET listOfUsedIDS = "">
<cfset alertcolor="lightsteelblue">

<CFIF len(trim(URL.BBID)) GT 0>
	<CFSET FORM.Billback_ID = URL.BBID>

	<!--- <cfquery name="LookForExistingProgram" datasource="#Application.Datasource#" maxrows=1>
		SELECT	Program_ID
		FROM	Billback_Program
		WHERE 	Billback_ID = '#FORM.Billback_ID#' 
		AND		Deleted = 0
	</cfquery>
	<CFIF LookForExistingProgram.recordcount GT 0>
		<CFSET LoadBillbackID = FORM.Billback_ID>	
		<cfinclude template="load_billback_to_struct.cfm">
	</CFIF> --->
<cfelse>
	<CFSET URL.BBID = FORM.Billback_ID>
</CFIF>

<cfset useLakebaseForgetPayeeInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForgetPayeeInfo>
	<cftry>
		<cfset getPayeeInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#FORM.Billback_ID#",
				"select" = "billback_payee_type_id,bb_amount,claim_cases,claim_pounds,uploaded_billback,auto_billback,bb_deviations_override_price as bb_level_deviations_override_price_flag"
			}), "billback_payee_type_id,bb_amount,claim_cases,claim_pounds,uploaded_billback,auto_billback,bb_deviations_override_price as bb_level_deviations_override_price_flag"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPayeeInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPayeeInfo>
<cfquery name="getPayeeInfo" datasource="#Application.Datasource#">
	SELECT 	Billback_Payee_Type_ID, 
			BB_Amount,
			Claim_Cases,
			Claim_Pounds,
      		Uploaded_Billback,
			Auto_Billback,
			Billback.BB_Deviations_Override_Price as BB_Level_Deviations_Override_Price_Flag
			<!--- D12149 Billbacks may now have negative values without this setting --->
			<!--- ,
			Negative_Billback --->
	FROM 	Billback
	WHERE 	Billback_ID = '#FORM.Billback_ID#'
</cfquery>
</cfif>
<cfset getPayeeID = billbackProgramManager.getPayeeID(form.billback_ID,getPayeeInfo.Billback_Payee_Type_ID) />

<!--- D31454:Single Billback Per Invoice:   program search logic START --->
<cfset useLakebaseForIIIvalue = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_settings")>
<cfif useLakebaseForIIIvalue>
	<cftry>
		<cfset IIIvalue = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_settings", {
				"select" = "iii_p_upload_single_bb_per_invoice"
			}), "iii_p_upload_single_bb_per_invoice"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIIIvalue = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIIIvalue>
<cfquery name="IIIvalue" datasource="#Application.Datasource#">
SELECT            III_P_Upload_Single_BB_Per_Invoice 
FROM        Billback_Settings
</cfquery>
</cfif>

<cfif IIIvalue.III_P_Upload_Single_BB_Per_Invoice EQ 1 AND getPayeeInfo.Billback_Payee_Type_ID EQ 1>
		<cfset useLakebaseForqDistList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_distributor_list")>
<cfif useLakebaseForqDistList>
	<cftry>
		<cfset qDistList = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_distributor_list", {
				"billback_id" = "eq.#BB_ID#",
				"deleted" = "eq.0",
				"select" = "distributor_id"
			}), "distributor_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqDistList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDistList>
<cfquery name="qDistList" datasource="#Application.Datasource#">
			Select Distributor_ID 
			From Billback_Distributor_List
			Where Billback_id = '#BB_ID#'
			And deleted = 0
		</cfquery>
</cfif>
		<cfif qDistList.RecordCount>
			<cfset FiltersList = #ValueList(qDistList.Distributor_ID,",")#>
		<cfelse>
			<cfset FiltersList = ''>
		</cfif>
</cfif>
<!--- D31454:Single Billback Per Invoice:   program search logic END --->

<!--- 
  19441 Starts [Added, Uploaded_Billback to the above query] 
  the checking <cfif bDisableLinks EQ 0>  is put on all the controls.
  ---->
<cfset BB_Upload_III_P_Qty_Amt_Editable = appSettings.getBB_Upload_III_P_Qty_Amt_Editable() />
<cfset bEditable_Claimed_Dollars_Quantity = appSettings.getEditableClaimedDollarsQuantity() />
<cfif getPayeeInfo.BB_Level_Deviations_Override_Price_Flag eq 1>
	<cfset BB_Upload_III_P_Qty_Amt_Editable = 0 />
</cfif>
<cfset bFlexBBDeviationOn  = appSettings.get_Setting('BB_Deviation_Format') contains 'Flex' ? 1 : 0>
<cfset bCF2020BBDeviationOn  = appSettings.get_Setting('BB_Deviation_Format') contains 'CF' ? 1 : 0>

<cfset iUploadedBillback = getPayeeInfo.Uploaded_Billback />
<cfset bDisableLinks = 0 />
<cfif (
		(	
			(BB_Upload_III_P_Qty_Amt_Editable EQ 0 AND iUploadedBillback EQ 3) OR (bEditable_Claimed_Dollars_Quantity EQ 0 AND iUploadedBillback EQ 2)
			AND (bFlexBBDeviationOn EQ 1 OR bCF2020BBDeviationOn EQ 1)
		)
		OR getPayeeInfo.Auto_Billback eq 1
	  )
>
  <cfset bDisableLinks = 1 />
</cfif>
<!--- <cfif bDisableLinks EQ 0>
</cfif> --->
<!--- BB_Upload_III_P_Qty_Amt_Editable:<cfoutput>#BB_Upload_III_P_Qty_Amt_Editable#</cfoutput>
 iUploadedBillback:<cfoutput>#iUploadedBillback#</cfoutput> --->
 
<!--- 19441 End--->

<CFSET PayeeProgramIDList = "">
<CFIF len(trim(getPayeeInfo.Billback_Payee_Type_ID)) NEQ 0 AND len(trim(getPayeeID))>
	<CFIF trim(getPayeeInfo.Billback_Payee_Type_ID) NEQ 0 AND trim(getPayeeID) NEQ 0>
		<cfinclude template="build_PayeeProgramIDList.cfm">
	</CFIF>
</CFIF>
<cfset useLakebaseForqCheckSched = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForqCheckSched>
	<cftry>
		<cfset qCheckSched = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#FORM.Billback_ID#",
				"select" = "scheduled_auto_bb"
			}), "scheduled_auto_bb"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckSched = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckSched>
<cfquery name="qCheckSched" datasource="#Application.Datasource#" maxrows=1>
		SELECT	Scheduled_Auto_BB
		FROM	Billback
		WHERE 	Billback_ID = '#FORM.Billback_ID#'
</cfquery>
</cfif>
<!--- --------------------------------------------------------------------------------------------------------------------------- --->
<!--- New code --->
<!--- --------------------------------------------------------------------------------------------------------------------------- --->
<CFSET PAGE_TITLE="">
	<CF_MessageWindow>
<HTML>
<HEAD>
<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

<cfmodule template="/customTags/include.cfm" file_to_include="/script/javascript/string_functions.js, /Common_Files/scripts/allowonlytwodecimalplaces.js">
<cfmodule template="/customTags/include.cfm" file_to_include="/Common_Files/Delete_Functions.js, /Script/javascript/dhtml.js">
<cfmodule template="/customTags/include.cfm" file_to_include="/script/javascript/ajax_js/jquery-1.7.2-min.js, /Script/javascript/Ajax_JS/jquery.AjaxCFC.js">

   <cfset ProgramDataBorderColor = "Blue" />
   <cfset TitleMaxChars  = 50 />
   <cfset Dollar_Sign_Size = 2 />

<script type="text/javascript">
  $(document).ready(function() 
  {
    <cfif appSettings.getAutoBillBackType()> 
     KnownProgramForm.ProgramCount_1_ProductCount_1_RateType_10_Value.focus();
	</cfif>
  });
	$.AjaxCFCHelper.setDebug(false);
	$.AjaxCFCHelper.setBlockUI(false);
    $.AjaxCFCHelper.setUseDefaultErrorHandler(true);
    $.AjaxCFCHelper.setSerialization('json'); // json, wddx
		
    var windowStatus = -1;
    var total_billback_amount = <cfoutput>#trim(numberformat(getPayeeInfo.BB_Amount,"_.__"))#</cfoutput>
		
       function submitForm()
       {
    document.KnownProgramForm.action="Program_Form_Save.cfm";
    $("#Data_Action_ID").val(0);
    document.KnownProgramForm.submit();
  }
        
  function addProgramInfo(ProgramID,BillbackID,PayeeTypeID,Program_Count_ID)
  {		
    $("#Data_Action_ID").val(5);
    $("#Count_ID").val(Program_Count_ID);
    $("#IsOnProgram").val(1);
    $("#ExistingProductList").val(eval("document.KnownProgramForm.Product_List_"+ProgramID+".value"));
    $("#temp_ExistingProductList_Programs").val(ProgramID);
	NewWindow("program_components_discounts.cfm?CallingPage=/billbacks/capture/program_form.cfm&Program_ID="+ProgramID+"&Billback_ID="+BillbackID+"&Payee_Type_ID="+PayeeTypeID, "ProgramInformation", 800, 600, "yes", "yes");

  }
	    
  function DeleteProgram(Program_ID) 
  {
	if(confirm("Press OK to remove this program from the billback"))
	{
	 $("#Data_Action_ID").val(2);
	 $("#Program_ToDelete").val(Program_ID);
	 $("#ExistingProductList").val("");
	 $("#temp_ExistingProductList_Programs").val("");
	 $("#Program_List.value").val("");
     document.KnownProgramForm.submit();
	 disableButton("save_table", true, false);
	}
  }
		
  function SearchPrograms(ApplyFilter,ProgramID,SingleSearchOnly) 
  {
	 $("#Data_Action_ID").val(1);
	 $("#Program_List").val($("#temp_ExistingProductList_Programs").val());
	 $("#FilterSearchPrograms").val(ApplyFilter);
     $("#FilterType").val(0);
	 $("#FilterDataList").val("");
	 $("#runsearchonfirstload").val(0);
		
	 <cfif (appSettings.getOneProgramPerBillback() OR appSettings.get_Setting('Restrict_One_Component_Per_Billback') EQ '1')>
		 document.KnownProgramForm.Program_ToDelete.value = $("#Program_List").val();
	</cfif>
	 if(ApplyFilter == 1)
	 {
	 <cfoutput>
	 $("##FilterType").val('#getPayeeInfo.Billback_Payee_Type_ID#');
	 $("##FilterDataList").val('#getPayeeID#') ;
<!--- D31454:Single Billback Per Invoice:   program search logic START  --->
<cfif IIIvalue.III_P_Upload_Single_BB_Per_Invoice EQ 1 AND len(FiltersList) GT 0><!--- D31863 :Error with Operator Billbacks --->
		var FinalFilterList = document.getElementById('FilterDataList').value.concat(',');
		 	FinalFilterList = FinalFilterList.concat('#FiltersList#');
			$("##FilterDataList").val(FinalFilterList) ;
</cfif>

<!--- D31454:Single Billback Per Invoice:   program search logic END  --->
	 $("##runsearchonfirstload").val(1);
	 </cfoutput>
	 }
	 NewWindow("../search_screens/search_programs.cfm?Formname=KnownProgramForm&fieldname=Program_List&Billback_ID=<cfoutput>#Billback_ID#</cfoutput>", "programswindow", 800, 600, "yes", "yes")
  }
		
   function verifyData(ProgramToChange)
   {	
   	
   		<cfif HasDefaultProgram>
			return false;
		</cfif>
	
	  AdjustRateTotal();
	  var bLastDtToClm = document.all.KnownProgramForm.Last_Date_To_Claim.value;
	  var lastDtToClaimMsg = "";
		
	  if (ProgramToChange != 0)
	  {
		  document.KnownProgramForm.ProgramToSwitch.value = ProgramToChange;
	  }
		
	<!--- begin error checking --->

	<!--- Do not initialize these variables using "var", as the checkForNegatives function cannot read it (for some reason) --->
		ErrorCount = 0;
		LS_Delete = 0;
		NegativeValue = 0;

	<!--- Check for negative values, empty volume values and empty Lumpsum values --->
		checkForNegatives();

	  if (ErrorCount == 0)
	  {
		Proceed = 1;
				tempNum = document.all.Total_Rates.innerText;
				reg = new RegExp(",","g");
				tempNum = tempNum.replace(reg, "");
				<!---Auto Auto BB does not need to validate...user can not update values--->
				<cfif qCheckSched.Scheduled_Auto_BB>
					tempDiffer = 0;
				<cfelse>
					tempDiffer = parseFloat(total_billback_amount) - tempNum
				</cfif>
				document.all.temp_rate_storage.value = tempDiffer;
				TwoDecimalsOnBlur(document.all.temp_rate_storage);
				tempDiffer = document.all.temp_rate_storage.value;
				
				if(tempDiffer != 0)
				{
					tempDiffer = FormatTextWithCommas(tempDiffer);
					Proceed = BillbackAmountSet(tempDiffer,LS_Delete);
				}
				else
				{
					tempDiffer = FormatTextWithCommas(tempDiffer);
					Proceed = BillbackAmountSet(tempDiffer,LS_Delete);
				}
					if(Proceed ==1 & NegativeValue == 0){
						submitForm();
						disableButton("save_table", true, false);
					}
	  }
	  else 
	  {		
	      showMessageWindow()
	  } 
	}
		
	function deleteThisProduct(prodID, bgCol,ProgramID,CustomerId, isonprogrambit,Product_Type)
    {	
	  var srcObj = event.srcElement;
	  var trObj = getParentObject(srcObj, "tr");
	  var tbObj = getParentObject(srcObj, "table");
	  var trIndex = trObj.rowIndex;
	  var bDelete = true;
	  var billbackProgramId = 0;
	  var inObjProductProgram = eval("document.all.Product_List_Program_" + ProgramID);
	  var sProductProgramList = inObjProductProgram.value;

	  $.AjaxCFC({
		url: "/components/Billback/Programs/Billback_Programs_Products.cfc",
		method: "getBillbackProgramId",
		data: {"Billback_Id":'<cfoutput>#form.billback_Id#</cfoutput>',"Program_Id":ProgramID},
		serialization: "json",
		success: function(r) {
          billbackProgramId = r.data[0].billback_program_id;
          
          var startDataCol = 1;
		  var objGroupLevel;
          
          if (srcObj.bDelete == !bDelete)
		  {
			  bDelete = false;
		  }
			
			  var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";	
		  if(trObj)
		  {	
		   if (isonprogrambit)
		   {
		   if(bDelete)
		   { 	
            $.AjaxCFC({
		     url: "/components/Billback/Programs/Billback_Programs_Products.cfc",
		     method: "deleteProductsOnProgam",
		     data: {"Billback_Id":'<cfoutput>#form.billback_Id#</cfoutput>',"billback_ProgramId":billbackProgramId, "Product_Id":prodID,"Customer_Id":CustomerId,"Product_Type":Product_Type},
		     serialization: "json",
		     success: function(r) 
		     {
              trObj.height = trObj.offsetHeight;
				
			  for (i=1; i<=trObj.cells.length-2; i++)
			  {
				disableDiv(trObj.cells[i+startDataCol], true, false);
			  }
				propogateProperty(trObj, "style.backgroundColor", "#DDDDDD", false);
				propogateProperty(trObj, "style.textDecoration", "line-through", true);				
				srcObj.title = "undo product deletion";
				srcObj.src = undodeleteImg.src;
				inObjProductProgram.value = ListDeleteItem(sProductProgramList, ",", prodID);
				AdjustRateTotal();
				updateVolume();
		      }
		      });	
			 }
				else
				{	
				$.AjaxCFC({
		         url: "/components/Billback/Programs/Billback_Programs_Products.cfc",
		         method: "undeleteProductsOnProgam",
		         data: {"Billback_Id":'<cfoutput>#form.billback_Id#</cfoutput>',"billback_ProgramId":billbackProgramId, "Product_Id":prodID,"Customer_Id":CustomerId,"Product_Type":Product_Type},
		         serialization: "json",
		         success: function(r) {	
					for (i=1; i<=trObj.cells.length-2; i++)
					{
					disableDiv(trObj.cells[i+startDataCol], false, false);
					}
					
					propogateProperty(trObj, "style.backgroundColor", bgCol, false);
					propogateProperty(trObj, "style.textDecoration", "none", false);
					
					srcObj.title = "delete this product";
					srcObj.src = deleteImg.src;
					propogateProperty(trObj, "style.backgroundColor", "FFFFFF", false, true);
					inObjProductProgram.value = ListAppendItem(sProductProgramList, ",", prodID);
					AdjustRateTotal();
					updateVolume();    
		      }
				});
				
				}
		   }
				srcObj.bDelete = !bDelete;
				trObj.bDelete = (bDelete?1:0);
							
			}				
           }
		 });
		}
		
			function TotalOfAllRateSums(){
				tempVar = ""
				tempVar = "0.00"
				total = TotalOfLumpSums();

			if($(this).get(0).disabled == false)
			{
				if(document.all.VolumeCollection != null){
					if(VolumeCollection.length != null){
				
							for(var x=0;x<VolumeCollection.length;x++){
							total = total + parseFloat(eval("RateCollection_"+VolumeCollection[x].rcid+"[0].SumOfRates"));					
						}
					}
					else {
						total = total + parseFloat(eval("RateCollection_"+VolumeCollection.rcid+"[0].SumOfRates"));
					}
				}
			}
				
				document.all.temp_rate_storage.value = total;
				TwoDecimalsOnBlur(document.all.temp_rate_storage);
				total = document.all.temp_rate_storage.value;
				if(total.length == 0) {
					total = "0.00"
				}
				total = FormatTextWithCommas(total);
				document.all.Total_Rates.innerText = total;
				var amountObj = window.parent.document.all.infoBar_BB_Amount;
				amountObj.innerText = total;
				tempExpectedRate = document.all.Expected_Total_Rates.innerText;
				reg = new RegExp(",","g");
				total2 = total.replace(reg, "")
				tempExpectedRate = tempExpectedRate.replace(reg, "")
				tempExpectedRate = parseFloat(tempExpectedRate)
		
				<!--- window.status=total2 --->
				tempVar = tempExpectedRate - total2
				DeltaDisplay = document.all.Delta_Rates
				document.all.temp_rate_storage.value = tempVar;
				TwoDecimalsOnBlur(document.all.temp_rate_storage);
				tempVar = document.all.temp_rate_storage.value;
				
				if(tempVar.length == 0){
					tempVar = "0.00"
				}
		
				tempVar=FormatTextWithCommas(tempVar);
				
				if(tempVar >= 0) {
					DeltaDisplay.innerText = tempVar
					DeltaDisplay.parentElement.style.color = "green"
					DeltaDisplay.style.cssText = ""
				}
				else{
					DeltaDisplay.style.cssText = "color:red;"
					DeltaDisplay.parentElement.style.color = "red"
					DeltaDisplay.innerText = "["+tempVar+"]";
				}
			}
		
			function TotalOfLumpSums() {
				runningTotal = 0;
				LSColl = document.all.LumpSumAmt
				if(LSColl != null){
				if(LSColl.length != null){
					for(var x = 0; x<LSColl.length; x++) {
						tmpvalue = getFirstChild(LSColl[x]).value
						if(tmpvalue.length > 0){
							runningTotal = runningTotal + parseFloat(tmpvalue)
						}
					}
				}
				else {
					tmpvalue = getFirstChild(LSColl).value
					if(tmpvalue.length > 0){
						runningTotal = runningTotal + parseFloat(tmpvalue)
					}			
				}
				}
				
				return runningTotal
			}
			
	
	function showHelp() {
		NewWindow("help_window.cfm", "helpwindow", 900, 600, "yes", "yes")
	}
		
	function applyGlobalUOM(){
		gUOM = document.all.Global_UOM.selectedIndex;
		
		if(document.all.UOMCollection != null){
			if(UOMCollection.length != null){
				for(var x = 0; x<UOMCollection.length;x++){
					getFirstChild(UOMCollection[x]).selectedIndex = gUOM;
					callfireEvent(document,getFirstChild(UOMCollection[x]),'Change');
				}
			}
			else{
				getFirstChild(UOMCollection).selectedIndex = gUOM;
				callfireEvent(document,getFirstChild(UOMCollection),'Change');
			}
		}
	}
			
			function reloadTallyCard() 
			  {
			     topMargin = 30;
				 document.all.floatLayer.style.top = 30;
				 document.all.floatLayer.style.left = 15;
	          }	

	 	    function BillbackAmountSet(tempDiffer,LS_Delete)
				{
					var Warning_Msg = "Lump sums that have $0 or null values will be deleted.\n\n";
					Proceed = 1;

					<!--- If the first condition exists, then update the bb_amount to be equal to the rebate total on the program page --->
					
					<cfif BB_User_Profile.BB_Apply_Rebate_Rates eq 1 and isDefined("GetSettings") AND GetSettings.Apply_Rebate_Rates eq 1  AND GetSettings.Discount_Rebates eq 1>
					if(tempDiffer != 0){
						Warning_Msg = Warning_Msg + "The billback amount calculated on this page differs from total billback amount by ($ "  + tempDiffer + ") on the basic information.\nDo you want to update the total billback amount? Press Ok to update the billback amount or CANCEL to change the volume entered."
					}
				
				/* If the billback amount calculated on this page differs from the basic info page OR any one of the Lumpsum text boxes have a blank or zero */
				if(tempDiffer != 0 || LS_Delete == 1){
					if(confirm(Warning_Msg)){
						Proceed = 1;
						var TotalRebate = 0;
						for (var i = 0; i<KnownProgramForm.length; i++){
								var name_=KnownProgramForm[i].name; // get element name 
								var type_=KnownProgramForm[i].type; // get element type			

								if(type_ == 'text' && name_.indexOf('Discount2')!=-1){					
									TotalRebate = parseFloat(TotalRebate) + parseFloat(document.getElementById(name_).value)
								}
						
						}
							if(TotalRebate != '#getPayeeInfo.BB_Amount#')
								{
									document.KnownProgramForm.TotalRebate.value=TotalRebate;
									document.KnownProgramForm.RebateUpdateAllowed.value=1;
								}
									document.all.KnownProgramForm.Data_Action_ID.value = 5;
					}	
					else
					{
						Proceed = 0;
					}
				}
				
				else
				{
						Proceed = 1;
				}
					<cfelse>
					if(tempDiffer != 0){
						Warning_Msg = Warning_Msg + "The billback amount calculated on this page differs from the amount supplied by $ "  + tempDiffer + " dollars. \nPress OK to continue or CANCEL to go back and adjust the rates."
					}
			
				if(tempDiffer != 0 || LS_Delete == 1){
					if(confirm(Warning_Msg)) {
						Proceed = 1;
						document.all.KnownProgramForm.Data_Action_ID.value = 5;
					}	
					else
					{
						Proceed = 0;
					}
				}

				else
				{
						Proceed = 1;
				}
					</cfif>
					return Proceed;
				}  
				
	     function FormatTextWithCommas(oText) {
		  if(isNaN(oText)){
			oText = '0';
		  }
		   var nf = new NumberFormat();
		       nf.setNumber(oText);
		       nf.setCommas(true);
		       nf.setCurrency(false);
		       nf.setPlaces(2);
		   
		   return nf.toFormatted()
	    }
	
	function TwoDecimalsOnBlur(oObject){
		if(trim(oObject.value).length > 0){
			if(parseFloat(oObject.value) != 0) {
				var nf = new NumberFormat();
				nf.setNumber(oObject.value);
				nf.setCommas(false);
				nf.setCurrency(false);
				nf.setPlaces(2);
				oObject.value = nf.toFormatted();
			}
			else {
				oObject.value = "0.00";
			}				
		}
	}
	
	function setUom(iPrg,iUom){
		$("#dv_" + iPrg + " select").val(iUom);
	}	
</script>

	
	<cfinclude template="iframe_style.cfm">
<style type="text/css">
					.productListTableStyle {
						border-top : 1 solid #93BEE2;
						border-left : 1 solid #93BEE2;
						border-right : 1 solid #93BEE2;
					}

					<cfoutput>
					.topMenu {
						border-top : 1 solid #ProgramDataBorderColor#;
						border-bottom : 1 solid #ProgramDataBorderColor#;
						border-left : 1 solid #ProgramDataBorderColor#;
						border-right : 1 solid #ProgramDataBorderColor#;
					}

					.programInformationStyle_Top {
						border-top : 1 solid #ProgramDataBorderColor#;
						border-left : 1 solid #ProgramDataBorderColor#;
						border-right : 1 solid #ProgramDataBorderColor#;
						border-bottom : 0 solid red;
						background-color: WhiteSmoke;
					}

					.programInformationStyle_Middle {
						border-left : 1 solid #ProgramDataBorderColor#;
						border-right : 1 solid #ProgramDataBorderColor#;
					}

					.programInformationStyle_Bottom {
						border-left : 1 solid #ProgramDataBorderColor#;
						border-right : 1 solid #ProgramDataBorderColor#;
						border-bottom : 1 solid #ProgramDataBorderColor#;
					}
					
					.lumpStyle {
						border-left: 2 solid black; 
						border-right: 2 solid black; 
						border-top: 2 solid black; 
						border-bottom: 2 solid black; 
						text-align : right;									
					}
					</cfoutput>

					TABLE.productListTableStyle TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}

					.tableHeader {
						background-color : #ffce84;
					}

					.ProductTypeLabel {
						font-size: 12px;
						font-weight: bold;
					}

					.LumpSumRow {
						border-bottom : 1 solid Navy;
					}
					
					input.ValidDiscount 
					{
						border-left: 2 solid black; 
						border-right: 2 solid black; 
						border-top: 2 solid black; 
						border-bottom: 2 solid black;
						background-color: ffff99;
						text-align : right;
					}
					
					input.Discount
					{
						border-left: 2 solid black; 
						border-right: 2 solid black; 
						border-top: 2 solid black; 
						border-bottom: 2 solid black;
						text-align : right;
					}
					input.Volume
					{
						border-left: 2 solid black; 
						border-right: 2 solid black; 
						border-top: 2 solid black; 
						border-bottom: 2 solid black;
						text-align : right;
					}
					.negative 
					{
						color:red;
					}
					.positive
					{
					 color:green;
					}
</style>

<CFPARAM NAME = "ThisProgram_ProductList" DEFAULT = "">
<CFPARAM NAME = "FORM.temp_ExistingProductList_Programs" DEFAULT ="">
<CFPARAM NAME = "thisProductList" DEFAULT ="">
<CFPARAM NAME = "thisProgram_DistinctProductList" DEFAULT ="">
<CFPARAM NAME = "ThisBB_ProductList" DEFAULT ="">

<!--- Delete Program from Billback --->
<cfif structKeyExists(form,"Data_Action_ID")>
	<cfset useLakebaseForGetStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForGetStatus>
	<cftry>
		<cfset GetStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#FORM.Billback_ID#",
				"select" = "billback_status_id"
			}), "billback_status_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetStatus>
<CFQUERY NAME="GetStatus" DATASOURCE="#Application.Datasource#">
		SELECT Billback_Status_ID FROM Billback WHERE Billback_ID = '#FORM.Billback_ID#'
	</CFQUERY>
</cfif>
	<CFIF GetStatus.Billback_Status_ID GTE 3> 
		<!--- 17302 - Redirect to Summary --->
		<CFSET Billback_Status_ID = GetStatus.Billback_Status_ID>
		<CFSET BB_ID_TO_Redirect = FORM.Billback_ID>
		<CFINCLUDE TEMPLATE = "BB_Summary_Redirect.cfm">
		<CFABORT>
	</CFIF>
 	<cfswitch expression="#form.Data_Action_ID#"> 
	<!--- Add Program ---> 
<cfcase value="1">
<!--- Get the current list of Program ID's for this billback
      so we don't insert/display them multiple times ---> 
<cfset variables.currentProgamId = billbackProgramManager.getBillbackPrograms(form.Billback_ID) />
<cfset variables.currentProgamIdList = valueList(variables.currentProgamId.Program_ID) />
  <cfif (appSettings.getOneProgramPerBillback() OR appSettings.get_Setting('Restrict_One_Component_Per_Billback') EQ '1') and form.Program_ToDelete neq "" and not listFindNoCase(form.Program_List, form.Program_ToDelete)>
	<cfset variables.getBBPrgToDelete = variables.billBackProgramsProducts.getBillbackProgramId(form.billback_id,form.Program_ToDelete) />
    
	<cfset billbackProgramManager.deleteBBProgramInfo(form.billback_id,variables.getBBPrgToDelete.Billback_Program_Id,form.Program_ToDelete) />
  </cfif>
 <cfloop list="#form.Program_List#" index="programList" delimiters=",">
   <cfif not listFind(variables.currentProgamIdList,programList)> 
    <cfquery name="InsertProgram" datasource="#Application.Datasource#">
     INSERT INTO Billback_Program
     (
	   Billback_ID,							
	   Program_ID
	 )
	 VALUES
     (
	   <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Billback_ID#" />,
	   <cfqueryparam cfsqltype="cf_sql_integer" value="#programList#" list="true" separator="," />
	 )
    </cfquery>
   </cfif>
 </cfloop>
	 </cfcase>
 <!--- Delete Programs and Products --->
 <cfcase value="2">
	<cfset variables.getBillback_Program_ID = variables.billBackProgramsProducts.getBillbackProgramId(form.billback_id,form.Program_ToDelete) />
			
   <cfset billbackProgramManager.deleteBBProgramInfo(form.billback_id,getBillback_Program_ID.Billback_Program_ID,form.Program_ToDelete) />
		
		<!---not remove form.Program_ToDelete from form.Program_List--->
		<cfif ListFindNoCase(form.Program_List, form.Program_ToDelete) neq "0">
			<cfset form.Program_List = ListDeleteAt(form.Program_List, ListFindNoCase(form.Program_List, form.Program_ToDelete)) />
		</cfif>
	</cfcase>
		 
	 <!--- Add Products --->
	 <cfcase value="5">
		<cfset showProductInfo = true />	
	 </cfcase>
	<!--- // End Add Products --->
	</cfswitch>
</cfif>

<cfquery name="LookForExistingProgram" datasource="#Application.Datasource#">
	SELECT	Program_ID,Discount_List,Billback_Program_ID,Contract_Number, Case WHEN RateTypeOption_4 =1 then 6 else RateTypeOption_4 END as RateTypeOption_4
	FROM	Billback_Program
	INNER JOIN Contract_Main 
	ON Contract_Main.Contract_main_ID = Billback_Program.Program_ID
	INNER JOIN Program_Control_Panel_Options PCPO 
	ON PCPO.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
	WHERE 	Billback_ID = '#FORM.Billback_ID#' 
	AND		Billback_Program.Deleted = 0
	ORDER BY Contract_Number
</cfquery>
<cfset Saved_ProgramList = valueList(LookForExistingProgram.Program_ID)>
<cfset RateTypeOption =  valueList(LookForExistingProgram.RateTypeOption_4)>

<!---- show message ---->
<!---- show message to the user that they will not be able to save this page until they move all products off the default program ---->
<cfif HasDefaultProgram>
<div style="color:red;font-weight:bold;font-size:14px;" align="center">
	<br>
	<cfoutput>#defaultProgramMessage#</cfoutput>	
</div>
</cfif>
<cfoutput>
<!--- Coming in from Programs link --->
<form name="KnownProgramForm" id="KnownProgramForm" action="program_form.cfm" method="post">
	<input type="Hidden" name="TotalRebate" value="#TotalRebate#">
	<input type="Hidden" name="RebateUpdateAllowed" value="#RebateUpdateAllowed#">
	<input type="hidden" name="Data_Action_ID" id="Data_Action_ID" value="0" />
	<input type="hidden" name="Count_ID" id="Count_ID" value="0" />
	<input type="hidden" name="IsOnProgram" id="IsOnProgram" value="0" />
    <input type="hidden" name="Last_Date_To_Claim" id="Last_Date_To_Claim" value="#form.Last_Date_To_Claim#" />
	<input type="hidden" name="ExistingProductList" id="ExistingProductList" value="" />
	<input type="hidden" name="FilterSearchPrograms" id="FilterSearchPrograms" value="" />
	<input type="hidden" name="FilterType" id="FilterType" value="" />
	<input type="hidden" name="FilterDataList" id="FilterDataList" value="" />
	<input type="hidden" name="runsearchonfirstload" id="runsearchonfirstload" value="" />
	<CFPARAM NAME="FORM.Program_List" DEFAULT="#Saved_ProgramList#">
    <input type="hidden" name="temp_Program_List" id="temp_Program_List" value="" />
    <input type="hidden" name="Program_List" id="Program_List" value="#FORM.Program_List#" />
    <input type="hidden" name="Product_List" id="Product_List" value="" size="150" />
	<input type="hidden" name="Billback_ID" id="Billback_ID" value="#FORM.Billback_ID#" />
    <input type="hidden" name="Program_ToDelete" id="Program_ToDelete" value="" />
	<input type="hidden" name="PayeeID" value="#getPayeeID#" />
	<input type="hidden" name="ProgramToSwitch" value="0">
	<input type="hidden" name="temp_ExistingProductList_Programs" id="temp_ExistingProductList_Programs" value="#form.Program_List#" />
</cfoutput>
<!--- Start: 19441--->
  <cfif bDisableLinks EQ 1>
    <center><strong>[</strong> <font color="red">This is either an uploaded billback or an auto billback, its data cannot be updated.  Some fields may be disabled.</font> <strong>]</strong></center>
  </cfif>
<!--- End: 19441--->  	
<cfoutput>
	<table width="100%" border="0">
	<tr>
		<td>		
		<CFIF Not qCheckSched.Scheduled_Auto_BB>	
		<table border="0" cellspacing="4" cellpadding="4" align="center" width="95%">
		<TR>
		<!--- TODO: Extra output --->
		<cfoutput>
			<td width="50">&nbsp; </td>
			<td width="50" align="right" valign="top"><strong>STEP 1:</strong></td>
			<TD valign="top">
			<!--- Start: 19441--->
    		<cfif bDisableLinks EQ 0>				
			<CF_button
					button_name		=	""
					button_caption	=	"add program"
					button_action	=	"SearchPrograms(1)"
					button_type		=	"javascript_link"
					button_width	=	"200"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>	
		<cfelse>
      <font color="grey"><nobr><div title="Program greyed">[ add program ]</div></nobr></font>
    </cfif><!--- End: 19441 --->						
			</TD>
					
			<TD valign="top"  width="50" align="right">
			<strong>STEP 2:</strong>
			</TD>
			<td valign="top">Select program information by clicking on green checkmark</td>
			<td valign="top" align="right" width="50"><strong>Step 3:</strong></td>
			<td valign="top">Enter dollars and volume per item</td>
			<td valign="top" align="right">
			<cfif (appSettings.getBBPowerpunch() OR appSettings.getUse_Big_Billbacks())>
				<strong>Other Options:</strong>
			</cfif>
			</td>
			<td valign="top">
				<cfif LookForExistingProgram.recordcount gt 0>
				<!--- Start: 19441---> 
				<cfif appSettings.getBBPowerpunch()>
	          		<cfif bDisableLinks EQ 0>			
	  					<CF_button
	  					button_name		=	""
	  					button_caption	=	"powerpunch"
	  					button_action	=	"power_punch.cfm?BBID=#Billback_ID#"
	  					button_type		=	"link"
	  					button_width	=	"200"
	  					button_color	=	"Navy"
	  					button_tip		=	""
	  					font_color		=	"White"
	  					font_size		=	"12"
	  					font_weight		=	"bold"	>
	          		<cfelse>
	             		<font color="grey">[ powerpunch ]</font><br>
	  				</cfif><!--- End: 19441 --->	
				</cfif>	
        </cfif>
				<cfif appSettings.getUse_Big_Billbacks()>
				<!--- Start: 19441--->
				  <cfif bDisableLinks EQ 0>		
            <CF_button
  					button_name		=	""
  					button_caption	=	"big billbacks"
  					button_action	=	"/billbacks/bigbillbacks/enter_bulk_information.cfm?BBID=#Billback_ID#"
  					button_type		=	"link"
  					button_width	=	"200"
  					button_color	=	"Navy"
  					button_tip		=	""
  					font_color		=	"White"
  					font_size		=	"12"
  					font_weight		=	"bold">
           <cfelse>
             <font color="grey">[ big billbacks ]</font>
  				 </cfif><!--- End: 19441 --->	
        </cfif>
			</td>
			
			</cfoutput>	
		</TR>
		</table>
		</CFIF>
		</td>				
	</tr>
	</table>

	<cfif listfind(RateTypeOption,6)>
		<cfset uom_exclusion_list = "3">
	<cfelse>
		<cfset uom_exclusion_list = "3,6">
	</cfif>
<table width="95%" align="center" cellspacing="0">
	<TR>
		<TD align="right" style="color:navy;">
			<font style="font-weight:bold;">Global UOM:</font>
			<cf_uom_dropdown
				company_main_id			=	""
				default_option_on		=	""
				default_option_text		=	""
				default_option_value	=	""
				dropdown_name			=	"Global_UOM"
				option_text_abbreviated	=	"1"
				plural_uom_display		=	"1"
				product_type_id			=	""
				program_template_id		=	""
				selected_uom_id			=	""
				text_before_tag_close	=	""
				uom_id_exclusion_list	=	"#uom_exclusion_list#"
				uom_id_inclusion_list	=	""
			>			
			<span onclick="applyGlobalUOM()"><font style="color:red;font-weight:bold;">[</font><font color="##0000ff" style="cursor:pointer;">apply</font><font style="color:red;font-weight:bold;">]</font></span>
		</TD>
	</TR>
</table>
<CFSET ProductCounter = 0>
	<cfif LookForExistingProgram.RecordCount>
		<cfloop query="LookForExistingProgram">
			
			<CFPARAM NAME = "ThisProgram_Product_CustomerList" DEFAULT = "">
			
			
			
			<cfif len(trim(Discount_List)) LT 1 AND  LookForExistingProgram.RecordCount GT 0>
				<!--- if the discount list isn't populated --->
				<cfquery name="GetDiscountsfromBillback" datasource="#application.datasource#">
					SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
					SELECT 	DISTINCT BB_Product_Type_ID 
					FROM 		Billback_Product_Detail
					INNER JOIN 	Billback_Product ON Billback_Product.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID AND 
								Billback_Product.Deleted = 0
					INNER JOIN 	Billback_Program ON Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID AND 
								Billback_Program.Program_ID = '#Program_ID#'
					WHERE 		Billback_Product_Detail.Billback_ID = '#Billback_ID#' AND 
								Billback_Product_Detail.Deleted = 0
					ORDER BY 	BB_Product_Type_ID
				</cfquery>
				<!--- If there's something returned, set that as the discount list --->
				<!--- Dev Notes: 12777 Ana --->
				<cfset DiscountList = VALUELIST(GetDiscountsfromBillback.BB_Product_Type_ID, ',')>
	
				<!--- Update db with discount list --->
				<cfset useLakebaseForUpdateProgramWithDiscountList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForUpdateProgramWithDiscountList>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_program",
			{
				"billback_program_id" = "eq.#Billback_Program_ID#"
			},
			{
				"discount_list" = "#DiscountList#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateProgramWithDiscountList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateProgramWithDiscountList>
<CFQUERY name="UpdateProgramWithDiscountList" datasource="#application.datasource#">
					UPDATE 	Billback_Program
					SET 	Discount_List = '#DiscountList#'
					WHERE 	Billback_Program_ID = '#Billback_Program_ID#'
				</CFQUERY>
</cfif>
			<CFELSE>
				<CFSET DiscountList = Discount_List>
			</cfif>
			<!--- discount list --->


			<!---Need to set all values to 0 first so it doesn't carry over prior values --->
			<cfset ShowFixed = 0>
			<cfset ShowRebate = 0>
			<cfset ShowLumpsum = 0>
			<cfset ShowGrowth = 0>
			<cfset ShowFormulaPricing = 0>
			<cfset ShowBidRequest = 0>
			<cfset ShowClaimAdjustment = appSettings.getShowClaimAdjustment()>
			
	
			<!--- Dev Note: Milan; 10433 - Only show discount types existing in the program --->
			<cfif appSettings.getHideInvalidComponentTypesInBillbacks() EQ 0 OR (appSettings.getHideInvalidComponentTypesInBillbacks() AND ListFind(DiscountList,1) neq 0)>
				<cfset ShowFixed = 1>
			</cfif>
			<cfif appSettings.getHideInvalidComponentTypesInBillbacks() EQ 0 OR (appSettings.getHideInvalidComponentTypesInBillbacks() AND ListFind(DiscountList,2) neq 0)>
				<cfset ShowRebate = 1>
			</cfif>
			<cfif appSettings.getHideInvalidComponentTypesInBillbacks() EQ 0 OR (appSettings.getHideInvalidComponentTypesInBillbacks() AND ListFind(DiscountList,3) neq 0)>
				<cfset ShowLumpsum = 1>
			</cfif>
			<cfif appSettings.getHideInvalidComponentTypesInBillbacks() EQ 0 OR (appSettings.getHideInvalidComponentTypesInBillbacks() AND ListFind(DiscountList,4) neq 0)>
				<cfset ShowGrowth = 1>
			</cfif>
			<cfif appSettings.getHideInvalidComponentTypesInBillbacks() EQ 0 OR (appSettings.getHideInvalidComponentTypesInBillbacks() AND ListFind(DiscountList,5) neq 0)>
				<cfset ShowFormulaPricing = 1>
			</cfif>
			<!--- BJF: Permanently hide formula until someone actually uses it --->
			<!---<cfset ShowFormulaPricing = 0>--->
			<cfif appSettings.getHideInvalidComponentTypesInBillbacks() EQ 0 OR (appSettings.getHideInvalidComponentTypesInBillbacks() AND ListFind(DiscountList,11) neq 0)>
				<cfset ShowBidRequest = 1>
			</cfif>
	
			<!--- </cfsilent> --->
			<!--- End Note: Milan; 10433 - Only show discount types existing in the program --->
			<table width="95%" align="center" cellspacing="0">
			<TR>
			<TD colspan="100%" height="30" <cfif xl eq 0><!--- (start) dont run if export to xl is yes --->class="programInformationStyle_Top"</cfif><!--- (end) dont run if export to xl is yes --->>
				<table border="0" width="100%" <cfif xl eq 0><!--- (start) dont run if export to xl is yes --->style="border-bottom : 1 solid #ProgramDataBorderColor#"</cfif><!--- (end) dont run if export to xl is yes --->>
				<TR valign="top">
					<CFIF trim(Program_ID) GT 0 AND Program_ID NEQ 0>

						<!--- get billback rebate components at the program level --->
						<cfquery name="getBBPrgRebateCompCount" datasource="#Application.Datasource#">
							SELECT count(Billback_Program_ID) As CompCount
							FROM Billback_Program_Rebate_Component
							WHERE Billback_Program_ID =  #Program_ID#
							AND Billback_id = '#Billback_ID#'
							AND Deleted = 0
						</cfquery>
						<!--- This hidden variable stores the number of rebate components at the program level.
						There will be one hidden variable for each program.
						--->
						<input type="hidden" name="Discount2_#Program_ID#_RebateCompCount" id="Discount2_#Program_ID#_RebateCompCount" value="#getBBPrgRebateCompCount.CompCount#">

						<!--- list of programs --->						
						<cfquery name="getProgramInfo" datasource="#Application.Datasource#">
							SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
							SELECT	dbo.Contract_Main.Contract_Number, 
									dbo.Contract_Main.Contract_Title, 
									dbo.Contract_Main.Contract_Start_Date, 
									dbo.Contract_Main.Contract_End_Date, 
									dbo.Contract_Main.Contract_Quantity, 
									dbo.Units_of_Measure.Unit_Of_Measure_Desc, 
									dbo.Units_of_Measure.Abbreviation, 
									dbo.Contract_Main.Contract_Main_ID, 
									dbo.Contract_Main.Contract_Status_Type_IDX,
									dbo.Program_Control_Panel_Options.Discount_Lump_Sums,dbo.Contract_Main.ProgramType_ID,
									dbo.Program_Control_Panel_Options.RateTypeOption_4
							FROM    dbo.Units_of_Measure 
									INNER JOIN dbo.Contract_Main ON 
									dbo.Units_of_Measure.Unit_Of_Measure_ID = dbo.Contract_Main.Contract_Quantity_UOM_IDX 
									INNER JOIN dbo.Program_Control_Panel_Options ON 
									dbo.Contract_Main.ProgramType_ID = dbo.Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
							WHERE	(dbo.Contract_Main.Contract_Main_ID = #Program_ID#)							
						</cfquery>

						<cfif xl eq 0><!--- start (don't run if export to xl is yes) --->
						<TD nowrap align="left" style="font-size:12px;color:navy;font-weight:bold;">
						</cfif><!--- end (don't run if export to xl is yes) --->
						<cfif xl eq 0><!--- start (don't run if export to xl is yes) --->
							<CFSWITCH EXPRESSION="#getProgramInfo.Contract_Status_Type_IDX#">
							<CFCASE VALUE="1">
								<!--- WIP --->
								<IMG SRC="/images/wip.gif" TITLE="Work in progress.">
							</CFCASE>
							<CFCASE VALUE="2">
								<!--- Ready For Approval --->
								<IMG SRC="/images/rfa.gif" TITLE="Ready For Approval.">
							</CFCASE>
							<CFCASE VALUE="4">
								<!--- Preactive Programs --->
								<IMG SRC="/images/preactive.gif" TITLE="Program in pre-active state.">
							</CFCASE>
							<CFCASE VALUE="5">
								<!--- Active Programs --->
								<IMG SRC="/images/active.gif" TITLE="Program currently active.">
							</CFCASE>
							<CFCASE VALUE="6">
								<!--- Expiring --->
								<CFSET diff=DATEDIFF("d", dateformat(now(), 'm/d/yyyy'), dateformat(getProgramInfo.Contract_End_Date, 'm/d/yyyy'))>
								<IMG SRC="/images/expiring.gif" TITLE="Program expires in #diff# days.">
							</CFCASE>
							<CFCASE VALUE="7">
								<!--- Archived/Expired --->
								<IMG SRC="/images/expired.gif" TITLE="Program has expired.">
							</CFCASE>																		
							</CFSWITCH>
						</cfif><!--- end (don't run if export to xl is yes) --->
						<cf_cryp	type = "en" string = "#Program_ID#" key = "#request.key#">
						<CFSET CID=cryp.value>
			 			<cfset targetURL = "/scorecard/program_display.cfm?display_program=1&CID=#CID#">
						<cfset targetWindow = "_blank">
						<cfset windowWidth = 800>
						<cfset windowHeight = 600> 
						<cfif xl eq 0><!--- start (don't run if export to xl is yes) --->			
							<A <cfif Program_ID neq "">onClick="javaScript: NewWindow(this.href , 'Catalog_Program' , #windowWidth# , #windowHeight# , 'yes' , 'yes'); return false;" target="#targetWindow#" HREF="#targetURL#" TITLE="View the details for program #getProgramInfo.Contract_Number#"</cfif>>
							#getProgramInfo.Contract_Number#</a>
							<SPAN id="ProgErrorSpan_#getProgramInfo.Contract_Main_ID#"></SPAN>
							<!--- Using customer keyword to hide this until we're done testing --->
							<!--- <cfif application.returned_customer_setting.customer_keyword IS "Resers" OR application.returned_customer_setting.customer_keyword IS "Conagra"> --->
							<cfif appSettings.getBBShowModifyProgram()>
								<br>
								<cfif isdefined("Billback_Program_ID")>
									<CF_button
									button_name		=	""
									button_caption	=	"modify program"
									button_action	=	"OpenChangeWindow('#getProgramInfo.Contract_Main_ID#')"
									button_type		=	"javascript_link"
									button_width	=	"200"
									button_color	=	"Navy"
									button_tip		=	""
									font_color		=	"White"
									font_size		=	"12"
									font_weight		=	"bold"	>
								</cfif>
							</cfif> 
						</TD>
						<TD nowrap title="#getProgramInfo.Contract_Title#" style="font-weight:bold;" align="left">
							#Left(getProgramInfo.Contract_Title,titleMaxChars)#<CFIF len(getProgramInfo.Contract_Title) GT titleMaxChars>...</CFIF>
						<!---<BR>--->&nbsp;::&nbsp;
							#DateFormat(getProgramInfo.Contract_Start_Date, 'm/d/yyyy')# to #DateFormat(getProgramInfo.Contract_End_Date, 'm/d/yyyy')# for #trim(NumberFormat(getProgramInfo.Contract_Quantity,'___,___,___,___,___,___,___'))#&nbsp;#getProgramInfo.Unit_Of_Measure_Desc#											
						<cfelse>
						<TD colspan="2" align="left" nowrap style="font-weight:bold;" width="80%">							 
							<span style="color:navy;">#getProgramInfo.Contract_Number#</span><BR>
							#Left(getProgramInfo.Contract_Title,titleMaxChars)#<CFIF len(getProgramInfo.Contract_Title) GT titleMaxChars>...</CFIF>
							<BR>
							#DateFormat(getProgramInfo.Contract_Start_Date, 'm/d/yyyy')# to #DateFormat(getProgramInfo.Contract_End_Date, 'm/d/yyyy')#
						</cfif>	<!--- end (don't run if export to xl is yes) --->					
						<!---check for last date to claim--->
						<cfif billbackProgramManager.getLastDateToClaim().RecordCount>
							<cfset form.Last_Date_To_Claim = 1 />
							<br><font color="red">Billback is beyond the last date to claim for this program.</font>
						</cfif>
						</TD>
					<CFELSE>
<!--- 						<TD nowrap ><CFIF len(getProgramInfo.Contract_Number) GT 0>#currentProgramObject.Program_Number#<CFELSE>No Program Number Given</CFIF></TD>
						<TD nowrap title="#currentProgramObject.Program_Title#" >
							<CFIF len(currentProgramObject.Program_Title) GT 0>#Left(currentProgramObject.Program_Title,titleMaxChars)#<CFIF len(currentProgramObject.Program_Title) GT titleMaxChars>...</CFIF><CFELSE>No Title Given</CFIF>
							
							<CFIF len(currentProgramObject.Program_Notes) GT 0><BR>#Left(currentProgramObject.Program_Notes,titleMaxChars)#<CFIF len(currentProgramObject.Program_Notes) GT titleMaxChars>...</CFIF><CFELSE>No Notes Given<BR></CFIF>
						</TD> --->
					</CFIF>
					
					<!--- 
					 TODO:
					<CFSET isUnknownProgram = 0> 
					--->
					<!--- Get the program template setting --->
					<cfquery name="GetSettings" datasource="#application.datasource#">
						SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
						SELECT 		Program_Control_Panel_Options.Apply_Rebate_Rates, Program_Control_Panel_Options.Discount_Rebates
						FROM 		Program_Control_Panel_Options
						INNER JOIN Contract_Main ON Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
						WHERE 		Contract_Main_ID = '#trim(Program_ID)#' 
					</cfquery>

				    <!--- TODO: Find out what the below code does --->
					<!---  If the billback profile setting and program template setting allow for adding "default rebate rates" --->
					<cfif BB_User_Profile.BB_Apply_Rebate_Rates eq 1 AND GetSettings.Apply_Rebate_Rates eq 1 AND GetSettings.Discount_Rebates eq 1> 
					<TD valign="bottom" align="center"> 
						<span style="font-weight:bold">Apply Default Rates<span>
						<br />
						<IMG SRC="/images/get_total_rebate.jpg" height="24" width="24" align="center" title="Get total rebate amount" border="0" style="cursor:pointer;" onClick="return FillRebateValues()">
					</TD>
				  	</cfif>
				  	<TD valign="bottom" align="right">
					<CFIF Not qCheckSched.Scheduled_Auto_BB>
            <cfif bDisableLinks EQ 0>
						<table width="100%" border="0" cellspacing="0" cellpadding="0" title="Mass apply a UOM to all items in this program">
						    <tr>
						    	<td align="left"><b>UOM:</b> </td>
						        <td width="120" align="left">


<!---D35880 UOM in billbacks - incorrect --->
<cfquery name="getUOMs" datasource="#application.datasource#">
	SELECT 	Unit_Of_Measure_ID,
					rtrim(ltrim(Abbreviation_Singular)) AS Abbreviation_Singular,
					#Program_ID# AS Program_ID_UOM
	FROM		Units_Of_Measure
	WHERE	Unit_Of_Measure_ID  in(1,2)
   ORDER BY	Display_Order
</cfquery>		

									<table class="xTable" bgcolor="white" cellspacing="0" cellpadding="0" style="border: 1px solid #ProgramDataBorderColor#" >
									    <tr>
									    	<cfloop query="getUOMs" >
									        <td style="font-size: 10px;">&nbsp;#Abbreviation_Singular#&nbsp; </td>									        
									        <td><input type="radio" id="rdoUom1_#Program_ID_UOM#" name="uom_#Program_ID_UOM#" onclick="setUom(#Program_ID_UOM#, #Unit_Of_Measure_ID#)"></td>
									    	</cfloop>
										</tr>
									</table>
<!---D35880 UOM in billbacks - incorrect --->
						        										
						        </td>
						        <td>  	
						 			 <img src="/images/on_the_program_item.jpg" height="24" width="19" title="add program information" hspace="4" border="0" style="cursor:pointer;" onClick="addProgramInfo(<CFIF len(trim(Program_ID)) EQ 0>0<CFELSE>#Program_ID#</CFIF>,'#URL.BBID#','#getPayeeInfo.Billback_Payee_Type_ID#',#RecordCount#)">&nbsp;
						 			 <img src="/images/no_small.jpg" height="24" width="19" title="Delete This Program From The Billback" border="0" onClick="DeleteProgram(<CFIF len(trim(Program_ID)) EQ 0>0<CFELSE>#Program_ID#</CFIF>)" style="cursor:pointer;" hspace="4">
						        </td>
						    </tr>
						</table>

            </cfif>
					</cfif>
					</TD>			
				</TR>

	   			<!--- Lump sums --->
				<cfif Billback_Program_ID neq "">
					<cfquery name="GetProgramLumpSums" datasource="#application.datasource#">
					   SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
					   SELECT * 
					   FROM Billback_Program_Lumpsum_Component
					   WHERE Billback_Program_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Billback_Program_ID#" />
					   AND Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
					</cfquery>
					<cfif GetProgramLumpSums.Recordcount GT 0>
					<tr><td colspan="100%" ><strong>&nbsp; &nbsp; &nbsp; &nbsp; #Application.LumpsumLabel#s</strong> </td></tr>
					<tr>	
					<td colspan="100%" bgcolor="white"> 
						<table align="left" cellpadding="4" cellspacing="4"><tr><td>&nbsp; </td>
						<cfloop query="GetProgramLumpSums">		
						<!--- If there are more than 3 components, then add a new cell for every new row. This logic will
									fire off on the 4th,7th,10th,13th....etc component number added --->
						<cfif GetProgramLumpSums.currentrow neq 1 AND GetProgramLumpSums.currentrow MOD 3 eq 1>
							<td>&nbsp; </td>
						</cfif>
						<td align="right">
							<cfif GetProgramLumpSums.Component_Type_ID IS 1>
								<cfquery name="GetLSName" datasource="#application.datasource#">
								SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
								SELECT 	Program_Lump_Sum_Name.Program_Lump_Sum_Name + '<br>' + ISNULL(Left(Lump_Sum_Description, 35), '') AS Lump_Sum_Name
								FROM 	Program_Lump_Sums
								INNER JOIN Program_Lump_Sum_Name
								ON 		Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
								WHERE 	Program_Lump_Sum_ID = '#GetProgramLumpSums.PROGRAM_LUMP_SUM_ID#'
								</cfquery>
								
							<cfelseif GetProgramLumpSums.Component_Type_ID IS 3>
								<cfquery name="GetLSName" datasource="#application.datasource#">
								SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
								SELECT dbo.Program_Growth_Components.Component_Name + ' (Tier ' + dbo.Program_Growth_Component_Tiers.Tier_Number + ')'+ '<br>' + 'Growth Lump Sum' AS Lump_Sum_Name
								FROM  dbo.Program_Growth_Components INNER JOIN
								      dbo.Program_Growth_Component_Tiers ON 
								      dbo.Program_Growth_Components.Program_Growth_Component_ID = dbo.Program_Growth_Component_Tiers.Program_Growth_Component_ID
								WHERE (dbo.Program_Growth_Components.Program_Growth_Component_ID = '#GetProgramLumpSums.PROGRAM_LUMP_SUM_ID#') AND (dbo.Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID = '#GetProgramLumpSums.Program_Growth_Component_Tier_ID#')
								</cfquery>
							<cfelse>
							<cfset GetLSName.Lump_Sum_Name = "Unknown Lump Sum">
							</cfif>
							#GetLSName.Lump_Sum_Name#
						</td>
						<cfset SafeLSID = 	replace(GetProgramLumpSums.Billback_Program_Lumpsum_Component_ID, "-", "_", "ALL")>									
						<TD nowrap><span id="LumpSumAmt_#SafeLSID#"></span><font size="#Dollar_Sign_Size#"><b>$</b></font><span id="LumpSumAmt"><input type="text" name="LumpSumCompID_#SafeLSID#" value="#GetProgramLumpSums.Amount#" size="7" class="lumpStyle" onBlur="TwoDecimalsOnBlur(this);" onKeyUp="clenseText(this, '-.0123456789'); allowonlytwodecimalplaces(this);"></span></TD>
						<CFIF GetProgramLumpSums.CURRENTROW MOD 3><CFELSE></TR><TR></tr></CFIF>									
		
						</cfloop>
						<!--- Each lump sum --->
						</table>
					</td></tr>
					</cfif>
				</cfif>
				<!--- END Lump Sums --->
				
				<tr>
			 	<td colspan="100%">
			 		<div id="dv_#program_Id#">
					<table width="100%" id="customerTbl" border="0" cellspacing="0" cellpadding="3" align="left" class="productListTableStyle">		
					<tr class="tableHeader">
					<td width="20">&nbsp;</td>
			 		<td nowrap width="225">#application.returned_customer_setting.item_label#&nbsp;Info</td>
					<!--- Extended amount --->
			 		<td>&nbsp; </td>
			 		<cfset EndSpaces = 0 />
					<!---Discount types --->
					<cfset fieldwidth="75" />
		   			<cfif ShowFixed>
						<td style="border-bottom:solid silver 1px;" align="center" width="#fieldwidth#" nowrap>
						 <font color="black">Fixed Pricing</font> 
						</td>
					<cfelse>
						<!--- Don't show discount, but increment spacer --->
			 			<cfset EndSpaces = EndSpaces + 1 />
		   			</cfif>
		   			<cfif ShowRebate>
					    <td style="border-bottom:solid silver 1px;" align="center"  width="#fieldwidth#" nowrap>
						 <font color="black">#Application.RebateLabel#</font>
						</td>
				   	<cfelse>
		  		 		<!--- Don't show discount, but increment spacer --->
						<cfset EndSpaces = EndSpaces + 1 />
		  			</cfif>
		  			<cfif ShowGrowth>
					   <td style="border-bottom:solid silver 1px;" align="center" width="#fieldwidth#" nowrap>
					    <font color="black">Growth</font></TD>
		  			<cfelse>
		  				<!--- Don't show discount, but increment spacer --->
		   				<cfset EndSpaces = EndSpaces + 1 />
			 		</cfif>
					<cfif ShowFormulaPricing>
						<td style="border-bottom:solid silver 1px;" align="center" width="#fieldwidth#" nowrap>
							<font color="black">Formula Pricing</font>
						</td>
					<cfelse>
					 	<!--- Don't show discount, but increment spacer --->
					  	<cfset EndSpaces = EndSpaces + 1 />
					</cfif>
		 			<cfif ShowBidRequest>
						<td style="border-bottom:solid silver 1px;" align="center" width="#fieldwidth#" nowrap>
					   		<font color="black">Proposal</font>
					  	</td>
		 			<cfelse>
		 				<!--- Don't show discount, but increment spacer --->
						<cfset EndSpaces = EndSpaces + 1 />
		 			</cfif>
		 			<cfif ShowClaimAdjustment>
					  	<td style="border-bottom:solid silver 1px;" align="center" width="#fieldwidth#" nowrap>
					   		<font color="black">Claim Adj.</font>
					  	</td>
		 			<cfelse>
		 				<!--- Don't show discount, but increment spacer --->
		  				<cfset EndSpaces = EndSpaces + 1 />
		 			</cfif>													
		 			<!---Adds spaces to the end of the table to make it look nice --->
		  			<td nowrap>Volume</td>
		 			<cfloop from="0" to="#EndSpaces#" index="Count" step="1">
		  				<td width="#fieldwidth#">&nbsp;</td>
		 			</cfloop>					
		  			<td>&nbsp;</td>
          			<!--- End discount types --->
		 			</tr>	
					<cfquery name="LookForExistingProduct" datasource="#Application.Datasource#">
						SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
					 	SELECT 		DISTINCT <!--- --CAST(Product_ID AS varchar(50)) + '|' + CAST(Distributor_ID AS varchar(50)) AS Product_Distributor, --->
									Product_ID Product_Distributor,
									Distributor_ID,Item,UPC,BB_Product_UOM
						FROM 		Billback_Product 
						INNER JOIN 	BSA_FoodService_Items_Master ON BSA_FoodService_Items_Master.BSA_FoodService_Items_Master_ID = Billback_Product.Product_ID
						WHERE 		Billback_ID = '#FORM.Billback_ID#' AND
									Billback_Program_ID = '#Billback_Program_ID#' AND
									Billback_Product.Deleted = 0
						ORDER BY 	Distributor_ID,Item
					</cfquery>
					<!--- Ana: 17458 - Handling UnKnown Products ---->
					<cfquery name="LookForExistingUnKnowProduct" datasource="#Application.Datasource#">
						SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
					 	SELECT 		DISTINCT <!--- --CAST(Product_ID AS varchar(50)) + '|' + CAST(Distributor_ID AS varchar(50)) AS Product_Distributor, --->
									Billback_Product_ID,
									Product_ID Product_Distributor,
									Distributor_ID,BB_Unknown_Product_Description Item,BB_Product_UOM
						FROM 		Billback_Product 						
						WHERE 		Billback_ID = '#FORM.Billback_ID#' AND
									Billback_Program_ID = '#Billback_Program_ID#' AND
									Billback_Product.Product_Type_ID = 3 AND
									Billback_Product.Deleted = 0
						ORDER BY 	Distributor_ID,Item
					</cfquery>
					<cfset BillbackProgramID = Billback_Program_ID>
					
  					<CFSET Saved_products = VALUELIST(LookForExistingProduct.Product_Distributor)>
					<!---Set ShowSaved_products to 0 first --->
					<CFSET ShowSaved_products = 0>
  					<CFIF LookForExistingProduct.RecordCount GT 0 AND showProductInfo NEQ "True">
					  	<CFSET ShowSaved_products = 1>
						<!--- <CFSET showProductInfo = "true"> --->
  					</CFIF>
					
   					<cfset thisCust = "" />
					
					<!---Dev Note: Label 20871 Added extra condition to determine if we are adding products then set the thisProductList = form.Product_List --->
					<cfset bAddingProducts = 1 />
					<cfif isDefined("form.Data_Action_ID") and form.Data_Action_ID eq 1>
						<cfset bAddingProducts = 0 />
					</cfif>
					
    				<cfparam name="form.Product_List_Program_#Program_ID#" default="" />
					<cfif Program_ID eq form.temp_ExistingProductList_Programs and bAddingProducts eq 1>	
					 	<cfset thisProductList = form.Product_List><!--- EVALUATE("FORM.Product_List_Program_#Program_ID#") ---> 					 	 
					<CFELSE>					
						<cfset thisProductList = EVALUATE("FORM.Product_List_Program_#Program_ID#")>
					</cfif>
					<!---Tim Ford - Label 20228: Removed ISDEFINED on ShowSaved_products variable.
					Instead we are always defaulting the variable to 0 then setting it to 1 if above criteria is met--->
					<!--- <CFIF ISDEFINED("ShowSaved_products")> --->
					
					<cfif ShowSaved_products and thisProductList EQ "">
						<cfset thisProductList = Saved_products>
					</CFIF>
					
					<!--- <CFSET showProductInfo = "false"> --->
					<CFIF thisProductList NEQ "">
						<CFSET showProductInfo = "true">
					</CFIF>

				<!--- -------------------------------------------------------------------- --->	
				<!--- Product display --->
				<!--- -------------------------------------------------------------------- --->	
				<cfif showProductInfo OR LookForExistingUnKnowProduct.RecordCount GT 0>	
					<!--- ------------------------------------------------------------------------ --->
					<!--- Product On program and not on program include --->
					<!--- ------------------------------------------------------------------------ --->
					<CFSET BBID = FORM.Billback_ID><!--- input for inc_eligible_products.cfm ---->
						
					<CFSET GetParentIDFor_MultiPrograms = 1>
			
					<CFSET Billback_Contract_Main_ID = Program_ID><!--- input for inc_eligible_products.cfm ---->
					
					<CFSET DontExecSPInInclude = 1>
					<CFINCLUDE template="/billbacks/capture/inc_eligible_products.cfm">
					
					<!--- ------------------------------------------------------------------------ --->
					<!--- End Product On program and not on program include --->
					<!--- ------------------------------------------------------------------------ --->			
					
					<cfquery name="getProductData" datasource="#Application.Datasource#">
						SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
						IF OBJECT_ID('tempdb..##Temp_Product_On_Program_2') IS NOT NULL
								DROP TABLE ##Temp_Product_On_Program_2
								
						CREATE TABLE ##Temp_Product_On_Program_2
						(	
							Product_ID_2 uniqueidentifier, 
							DiscountTypeID_2 int, 
							Contract_Number_2 varchar(50)
						)
						<CFIF getParentIDs_List NEQ "">
						INSERT INTO ##Temp_Product_On_Program_2(Product_ID_2,DiscountTypeID_2,Contract_Number_2)
						EXEC BB_Products_On_Program '#Billback_ID#', '#getParentIDs_List#',#Payee_Type# 
						</CFIF>
						
						<CFIF thisProductList NEQ "">
				  SELECT	DISTINCT dbo.BSA_Foodservice_Items_Master.Item, 
				            dbo.BSA_Foodservice_Items_Master.UPC, 
							dbo.BSA_Foodservice_Items_Master.Description, 
							dbo.BSA_Foodservice_Items_Master.Net_Weight, 
							Billback_Product.BB_Product_UOM,
							BSA_Foodservice_Customers.Name,
							BSA_Foodservice_Customers.Ship_To,
							BSA_Foodservice_Customers.Shr_Ship_To,
							BSA_Foodservice_Customers.City,
							BSA_Foodservice_Customers.State,
							dbo.Brand.Brand_Name,BSA_Foodservice_Items_Master_ID AS Product_ID,
							 <!--- <CFIF getPayeeInfo.Billback_Payee_Type_ID EQ 1>
								Billback_Distributor.Distributor_ID Customer_ID
							<CFELSE>
								Billback_Distributor_List.Distributor_ID Customer_ID
							</CFIF>, --->
							ISNULL(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID, '00000000-0000-0000-0000-000000000000') AS Customer_ID,
							CASE 
								WHEN Billback_Distributor_List.Distributor_ID IS NOT NULL THEN
									0
								WHEN Billback_Distributor_List.Distributor_ID IS NULL THEN
									1
							END AS HideCustomerRestrictions, 
							CASE 
								WHEN	(##Temp_Product_On_Program_2.Product_ID_2 IS NOT NULL ) THEN
									1
								ELSE
									2
								END AS IsProductOnProgram
								,BSA_Foodservice_Items_Master.Is_Divested
								,Billback_Product.User_Picked_UOM,
								Billback_Product.User_Entered_Quantity
								/* ,Billback_Product.Billback_Product_ID */
				   		FROM     dbo.BSA_Foodservice_Items_Master 
				   		INNER JOIN dbo.Brand 
				   		ON dbo.BSA_Foodservice_Items_Master.Brand_ID = dbo.Brand.Brand_ID
						 <!--- <CFIF getPayeeInfo.Billback_Payee_Type_ID EQ 1> --->
						LEFT JOIN Billback_Distributor ON Billback_Distributor.Billback_ID = '#FORM.Billback_ID#' AND
								 	Billback_Distributor.Deleted = 0
						<!--- <CFELSE> --->
						LEFT JOIN Billback_Distributor_List ON Billback_Distributor_List.Billback_ID = '#FORM.Billback_ID#' AND
								 	Billback_Distributor_List.Deleted = 0
						LEFT JOIN BSA_Foodservice_Customers 
						ON
						(
						BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = IsNull(Billback_Distributor_List.Distributor_ID,Billback_Distributor.Distributor_ID) 
						)
						<!--- </CFIF>  --->
						<!--- Ana: FInd about commenting the discount type --->
						LEFT JOIN	##Temp_Product_On_Program_2 ON ##Temp_Product_On_Program_2.Product_ID_2 = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID 
						AND  ltrim(##Temp_Product_On_Program_2.Contract_Number_2)  =  ltrim('#getProgramInfo.Contract_Number#')
				   		LEFT JOIN	Billback_Product 
						ON	Billback_Product.Billback_ID = '#FORM.Billback_ID#'
						AND Billback_Product.Billback_Program_ID = '#Billback_Program_ID#'
						AND Billback_Product.Product_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
						AND Billback_Product.Deleted = 0
						WHERE 	BSA_Foodservice_Items_Master_ID IN (#LISTQUALIFY(thisProductList,"'")#)
						AND		
						(
							Billback_Product.Billback_ID IS NULL 
							OR
							Billback_Product.Distributor_ID = IsNull(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,'00000000-0000-0000-0000-000000000000')
						)
						
						<!--- Ana: already saved UnKnown Products --->
						
						UNION</CFIF>
						SELECT 
						
						DISTINCT 	Billback_Product.BB_Unknown_Product_Item_Number Item, 
						            Billback_Product.BB_Unknown_Product_Item_Number UPC, 
									Billback_Product.BB_Unknown_Product_Description Description, 
									'1' Net_Weight, 
									Billback_Product.BB_Product_UOM,
									BSA_Foodservice_Customers.Name,
									BSA_Foodservice_Customers.Ship_To,
									BSA_Foodservice_Customers.Shr_Ship_To,
									BSA_Foodservice_Customers.City,
									BSA_Foodservice_Customers.State,
									 'Unknown' Brand_Name,
									Billback_Product.Billback_Product_ID AS Product_ID,
									 
									ISNULL(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID, '00000000-0000-0000-0000-000000000000') AS Customer_ID,
									CASE 
										WHEN Billback_Distributor_List.Distributor_ID IS NOT NULL THEN
											0
										WHEN Billback_Distributor_List.Distributor_ID IS NULL THEN
											1
									END AS HideCustomerRestrictions, 
									3 AS IsProductOnProgram,
									0 AS Is_Divested
									,Billback_Product.User_Picked_UOM
									,Billback_Product.User_Entered_Quantity

									/* ,Billback_Product.Billback_Product_ID */
						FROM    	Billback_Program 
						
						INNER JOIN	Billback_Product ON Billback_Product.Billback_ID = Billback_Program.Billback_ID AND 
									Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID AND 
									Billback_Program.Program_ID = #Program_ID# AND
									Billback_Product.Deleted = 0 AND Product_Type_ID = 3 AND
									Billback_Program.Billback_ID = '#FORM.Billback_ID#' AND 
									Billback_Program.Deleted = 0 

						LEFT JOIN 	Billback_Distributor ON Billback_Distributor.Billback_ID = Billback_Program.Billback_ID AND			
								 	Billback_Distributor.Deleted = 0
						
						LEFT JOIN 	Billback_Distributor_List ON Billback_Distributor_List.Billback_ID = Billback_Program.Billback_ID AND
								 	Billback_Distributor_List.Deleted = 0 AND 
								 	Billback_Distributor_List.Distributor_ID = Billback_Product.Distributor_ID
						LEFT JOIN BSA_Foodservice_Customers 
						ON
						(
						BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = IsNull(Billback_Distributor_List.Distributor_ID,Billback_Distributor.Distributor_ID) 
						)					
																								
				   		ORDER BY Is_Divested, BSA_Foodservice_Customers.Ship_To, IsProductOnProgram, Item, UPC, Description
				  	  	</cfquery>  
						
					<!--- <input type="hidden" name="Product_List_Program_#Program_ID#" value="#thisProductList#"> --->
					
 					<CFSET Program_ID = Program_ID>
					<input type="hidden" name="Product_List_Program_#Program_ID#" id="Product_List_Program_#Program_ID#" value="#thisProductList#">
					
   					<CFSET ProductsNotOnProgram_Count = 0>
					
					<cfloop QUERY="getProductData"><!--- LIST = "#thisProductList#" INDEX="ThisProduct" delimiters=","> ---><!--- LoopCount --->   		
					<CFSET ProductCounter = ProductCounter + 1>				
    					
						<cfset ValidDiscountList = "">

						<CFIF LISTFIND(ThisProgram_ProductList,Product_ID) EQ 0 AND IsProductOnProgram NEQ 3>
						 	<cfset ThisProgram_ProductList = listAppend(ThisProgram_ProductList,Product_ID)>
						</CFIF>
	 
				    	<cfif GetValidDiscountsforProductBB.recordcount>
						<!--- Get valid discounts for this product BJF D11692 --->
						<cfquery name="GetValidDiscountsforProduct" datasource="#application.datasource#">
							SELECT DISTINCT Discount_List
							FROM BB_Product_Discount
							WHERE Program_ID = '#Program_ID#'
							AND Billback_ID = '#Form.Billback_ID#'
							AND Product_ID = '#PRODUCT_ID#'
						</cfquery>
						</cfif>
						
						<!--- Ana 15316: this has been done in the getProductData query itself
						<!--- Reset the customer id in case there are no distributors in the list or no dist on the whole bb --->
						<cfset CustomerID = "">
						<cfset HideCustomerRestrictions = 0>
						<cfif NOT len(trim(getProductData.Customer_ID))>
							<cfif getPayeeInfo.Billback_Payee_Type_ID EQ 1>
								<cfset CustomerID = getPayeeID>
							<cfelse>
								<cfset HideCustomerRestrictions = 1>
							</cfif>
						<cfelse>
							<cfset CustomerID = Customer_ID>
						</cfif> 
						--->
	
						<!---
						<cfquery name="getSavedProdInfo" datasource="#application.datasource#">
						  	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
							
						  	SELECT BB_Product_Quantity,BB_Product_UOM,
							(	SELECT 	BB_Rate 
								FROM BIllback_Product_Detail 
								WHERE 	Billback_ID = Billback_Product.Billback_ID AND
										BB_Product_Type_ID = 1 AND 
										Billback_Product_ID = Billback_Product.Billback_Product_ID AND									
										( 
											(	#HideCustomerRestrictions# = 0 AND
												Distributor_ID_Earned = '#Customer_ID#'
											) OR
											( 	#HideCustomerRestrictions# = 1)
										) AND											
										Deleted = 0
							) AS FixedAmt,
							(	SELECT 	BB_Rate 
								FROM 	BIllback_Product_Detail 
								WHERE 	Billback_ID = Billback_Product.Billback_ID AND
										BB_Product_Type_ID = 2 AND 
										Billback_Product_ID = Billback_Product.Billback_Product_ID AND
										( 
											(	#HideCustomerRestrictions# = 0 AND
												Distributor_ID_Earned = '#Customer_ID#'
											) OR
											( 	#HideCustomerRestrictions# = 1)
										) AND	
										Deleted = 0
							) AS RebateAmt,
							(	SELECT 	BB_Rate 
								FROM 	BIllback_Product_Detail 
								WHERE 	Billback_ID = Billback_Product.Billback_ID AND
										BB_Product_Type_ID = 4 AND 
										Billback_Product_ID = Billback_Product.Billback_Product_ID AND
										( 
											(	#HideCustomerRestrictions# = 0 AND
												Distributor_ID_Earned = '#Customer_ID#'
											) OR
											( 	#HideCustomerRestrictions# = 1)
										) AND	
										Deleted = 0
							) AS GrowthAmt,
							(	SELECT 	BB_Rate 
								FROM 	Billback_Product_Detail 
								WHERE 	Billback_ID = Billback_Product.Billback_ID AND
										BB_Product_Type_ID = 5 AND 
										Billback_Product_ID = Billback_Product.Billback_Product_ID AND
										( 
											(	#HideCustomerRestrictions# = 0 AND
												Distributor_ID_Earned = '#Customer_ID#'
											) OR
											( 	#HideCustomerRestrictions# = 1)
										) AND	
										Deleted = 0
							) AS FormulaAmt,
							(	SELECT 	BB_Rate 
								FROM 	BIllback_Product_Detail 
								WHERE 	Billback_ID = Billback_Product.Billback_ID AND
										BB_Product_Type_ID = 10 AND 
										Billback_Product_ID = Billback_Product.Billback_Product_ID AND
										( 
											(	#HideCustomerRestrictions# = 0 AND
												Distributor_ID_Earned = '#Customer_ID#'
											) OR
											( 	#HideCustomerRestrictions# = 1)
										) AND	
										Deleted = 0
							) AS ClaimAdjAmt,
							(	SELECT 	BB_Rate 
								FROM	Billback_Product_Detail 
								WHERE 	Billback_ID = Billback_Product.Billback_ID AND
										BB_Product_Type_ID = 11 AND 
										Billback_Product_ID = Billback_Product.Billback_Product_ID AND
										( 
											(	#HideCustomerRestrictions# = 0 AND
												Distributor_ID_Earned = '#Customer_ID#'
											) OR
											( 	#HideCustomerRestrictions# = 1)
										) AND	
										Deleted = 0
							) AS BidAmt 
							
							FROM Billback_Program
							INNER JOIN Billback_Product ON Billback_Program.Billback_ID = '#FORM.Billback_ID#' AND 
							Billback_Program.Program_ID = '#Program_ID#' AND
							Billback_Program.Deleted = 0 AND
							Billback_Product.Billback_ID = Billback_Program.Billback_ID AND
							Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID AND
							<CFIF IsProductOnProgram NEQ 3>
							Billback_Product.Product_ID = '#Product_ID#' AND							
							<CFELSE>
							Billback_Product.Billback_Product_ID = '#Product_ID#' AND	
							</CFIF>
							( 
								(	#HideCustomerRestrictions# = 0 AND
									Billback_Product.Distributor_ID = '#Customer_ID#'
								) OR
								( 	#HideCustomerRestrictions# = 1)
							) AND	
							Billback_Product.deleted = 0
						</cfquery>
						--->
						
						<cfquery name="getSavedProdInfo" datasource="#application.datasource#">
						
							SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
														
							declare @billback_product table
							(
							BB_Product_Quantity nvarchar(50),
							BB_Product_UOM int,
							Billback_Product_ID uniqueidentifier
							)
							
							insert into @billback_product (BB_Product_Quantity, BB_Product_UOM, Billback_Product_ID)
							SELECT BB_Product_Quantity,BB_Product_UOM, Billback_Product.Billback_Product_ID
							FROM Billback_Program
							INNER JOIN Billback_Product ON Billback_Program.Billback_ID = '#FORM.Billback_ID#' AND 
							Billback_Program.Program_ID = '#Program_ID#' AND
							Billback_Program.Deleted = 0 AND
							Billback_Product.Billback_ID = Billback_Program.Billback_ID AND
							Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID AND
							<CFIF IsProductOnProgram NEQ 3>
							Billback_Product.Product_ID = '#Product_ID#' AND							
							<CFELSE>
							Billback_Product.Billback_Product_ID = '#Product_ID#' AND	
							</CFIF>
							( 
								(	#HideCustomerRestrictions# = 0 AND
									Billback_Product.Distributor_ID = '#Customer_ID#'
								) OR
								( 	#HideCustomerRestrictions# = 1)
							) AND
							Billback_Product.BB_Product_UOM = NULLIF('#getProductData.BB_Product_UOM#','')
							AND Billback_Product.deleted = 0
							
							declare @billback_product_detail table
							(
							Billback_Product_ID uniqueidentifier,
							BB_Product_Type_ID int,
							BB_Rate [decimal](24, 9)
							)
							insert into @billback_product_detail (Billback_Product_ID, BB_Product_Type_ID, BB_Rate)
							select	Billback_Product.billback_product_id, Billback_Product_Detail.BB_Product_Type_ID, Billback_Product_Detail.BB_Rate
							from	@billback_product Billback_Product
							inner join Billback_Product_Detail 
							ON Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID
							AND	Billback_Product_Detail.Deleted = 0
							
							
							SELECT SUM(CAST(BB_Product_Quantity AS float)) AS BB_Product_Quantity, BB_Product_UOM,
									(	SELECT 	SUM(BB_Rate)
										FROM @billback_product_detail 
										WHERE 	BB_Product_Type_ID = 1
									) AS FixedAmt,
									(	SELECT 	SUM(BB_Rate) 
										FROM @billback_product_detail 
										WHERE 	BB_Product_Type_ID = 2
									) AS RebateAmt,
									(	SELECT 	SUM(BB_Rate) 
										FROM @billback_product_detail 
										WHERE 	BB_Product_Type_ID = 4
									) AS GrowthAmt,
									(	SELECT 	SUM(BB_Rate) 
										FROM @billback_product_detail 
										WHERE 	BB_Product_Type_ID = 5
									) AS FormulaAmt,
									(	SELECT 	SUM(BB_Rate) 
										FROM @billback_product_detail 
										WHERE 	BB_Product_Type_ID = 10
									) AS ClaimAdjAmt,
									(	SELECT 	SUM(BB_Rate) 
										FROM @billback_product_detail 
										WHERE 	BB_Product_Type_ID = 11
									) AS BidAmt
							FROM	@billback_product Billback_Product
							Group By BB_Product_UOM
						</cfquery>
					
					<!--- D51977 :: START Billback enhancements for operator level data --->
					<cfquery name="qChkBBIIL" datasource="#application.datasource#">	
						SELECT Count(*) AS RecCount FROM BB_Item_Invoice_Level WHERE Billback_ID = '#FORM.Billback_ID#'
					</cfquery>
					
					<cfif (qChkBBIIL.RecCount GTE 1 AND application.appSettingsGet.getViewOperatorinBillbackDeviation())>
						<cfquery name="qGet_Opr_Products" datasource="#application.datasource#">
							SELECT 	
								bil.Billback_Program_ID,
								bil.Billback_Product_ID,
								bil.product_id AS BSA_Foodservice_Items_Master_ID,
							<!---	cm.Contract_Main_ID,--->
								CASE bil.UOM 
								WHEN 1 THEN 
									ISNULL(bil.Claimed_CS,0)
								ELSE 
									ISNULL(bil.Claimed_LB,0)
								END AS BB_Product_Quantity,
								Units_Of_Measure.Unit_Of_Measure_Desc,
								'' as Group_Name_Id, '' as Group_Id,
								CASE bil.UOM 
								WHEN 1 THEN 
									bil.Claimed_CS
								ELSE 
									bil.Claimed_LB / CAST(i.net_weight AS FLOAT)
								END AS Claimed_CS,
								
								CASE bil.UOM 
								WHEN 1 THEN 
									bil.Claimed_CS * CAST(i.net_weight AS FLOAT)
								ELSE 
									ISNULL(bil.Claimed_LB,0)
								END AS Claimed_LB,
					
								CASE bil.UOM 
								WHEN 1 THEN 
									bil.Allocated_Expected_CS
								ELSE 
									bil.Allocated_Expected_LB / CAST(i.net_weight AS FLOAT)
								END AS Expected_CS,
								
								CASE bil.UOM 
								WHEN 1 THEN 
									bil.Allocated_Expected_CS * CAST(i.net_weight AS FLOAT)
								ELSE 
									bil.Allocated_Expected_LB
								END AS Expected_LB,
						
								bil.Program_ID,
								CASE bil.UOM 
								WHEN 1 THEN 
									ISNULL(bil.Expected_Rate_CS,0)
								ELSE 
									ISNULL(bil.Expected_Rate_LB,0)
								END AS Expected_Rate,
								bil.Claimed_Amt AS BillBack_Rate,
								CASE WHEN 
									b.billback_status_id >= 3  AND bil.UOM = 1  THEN ISNULL(Selected_Rate_CS,0)
								WHEN 
									b.billback_status_id >= 3  AND bil.UOM = 2  THEN ISNULL(Selected_Rate_LB,0)
								ELSE
								0
								END
								AS Approved_Rate,
										
								CASE WHEN bil.UOM = 1 THEN 
									bil.Claimed_CS
								ELSE
									ISNULL(bil.Claimed_LB,0)
								END AS Item_BB_Volume,
								CASE WHEN bil.UOM = 1 THEN 
								ISNULL(Allocated_Expected_CS,0) 
								ELSE
									ISNULL(Allocated_Expected_LB,0)
								END AS Item_E_Volume,
								CASE WHEN 
									b.billback_status_id >= 3  AND bil.UOM = 1  THEN Selected_Vol_CS
								WHEN 
									b.billback_status_id >= 3  AND bil.UOM = 2  THEN Selected_Vol_LB
								ELSE
								0
								END AS Item_Approved_Volume,
								
								CASE WHEN 
									b.billback_status_id <= 2 THEN 0
								ELSE
									CASE bil.UOM 
									WHEN 1 THEN 
										bil.Selected_Vol_CS
									ELSE 
										bil.Selected_Vol_LB / cast(i.net_weight as float)
									END 
								END AS Item_Approved_Volume_CS,
								
								CASE bil.UOM 
								WHEN 1 THEN 
									bil.Claimed_CS
								ELSE 
									ISNULL(bil.Claimed_LB,0) / CAST(i.net_weight AS FLOAT)
								END  AS Item_Approved_Volume_CS, 
								
								CASE WHEN b.billback_status_id <= 2 THEN 0
								ELSE
									CASE bil.UOM 
									WHEN 1 THEN ISNULL(bil.Selected_Vol_CS, 0) * CAST(ISNULL(i.net_weight,0) AS FLOAT)
									ELSE ISNULL(bil.Selected_Vol_LB, 0)
									END 
								END AS Item_Approved_Volume_LB,
								ISNULL(bil.Allocated_Expected_CS, 0)  AS Item_Expected_Volume_CS,
								ISNULL(bil.Allocated_Expected_LB, 0) AS Item_Expected_Volume_LB,
								CAST(bil.Expected_Rate_CS * bil.Allocated_Expected_CS AS 
								DECIMAL(20, 2)) AS Expected_Amount_CS,
								CASE WHEN bil.UOM = 1 THEN 
									CAST(ISNULL(bil.Claimed_Amt,0) AS DECIMAL(12,2))
								ELSE
									CAST(ISNULL(bil.Claimed_Amt,0) * ISNULL(i.net_weight,0) AS DECIMAL(12,2))
								END AS  Approved_Amount_CS,
								CAST(ISNULL(bil.Claimed_CS,0) AS DECIMAL(12,2)) AS Item_BB_Volume_CS,
								CAST(ISNULL(bil.Claimed_LB,0) AS DECIMAL(12,2)) AS Item_BB_Volume_LB,
							<!---	CASE 
									WHEN Program_ID IS NULL THEN
										b.BB_Start_Date
									ELSE
										cm.Contract_Start_Date
									END AS Start_Date,
								CASE 
									WHEN Program_ID IS NULL THEN
										b.BB_End_Date
									ELSE
										cm.Contract_End_Date
									END AS End_Date,
								
								cm.contract_title AS Program_Title,
								cm.contract_number AS Program_Number, --->
								i.item AS Item_Number, i.Description,
								bil.Discount_Type_ID AS BB_Product_Type_ID,
								
								bil.Claimed_Amt AS BB_Rate,
								bil.distributor_id as dist_id,
								<!---c.name,
								c.shr_ship_to as ship_to,--->
								bil.Discount_Type_ID AS Product_Type_ID,
								/* -- Expected Amount */
								CAST(CASE bil.UOM 
								WHEN 1 THEN 
									bil.Expected_Rate_CS * bil.Allocated_Expected_CS
								ELSE 
									bil.Expected_Rate_LB * bil.Allocated_Expected_LB
								END AS DECIMAL(20, 2)) AS Expected_Amount,
								CASE WHEN b.billback_status_id <= 2 THEN 0
								ELSE
									bil.Final_Payment
								END AS Approved_Amount
							<!---	,CASE WHEN (##Temp_Product_On_Program_2.Product_ID_2 IS NOT NULL AND ##Temp_Product_On_Program_2.DiscountTypeID_2 
								IS NOT NULL AND ##Temp_Product_On_Program_2.Contract_Number_2 IS NOT NULL ) 
								THEN 1 ELSE 0 END AS IsProductOnProgram, 		
								ISNULL(i.Is_Divested, 0) as Is_Divested--->
								,bil.Operator_ID
								,bo.Operator_Name
								,LTRIM(RTRIM( RTRIM(bo.Operator_Name)  + ' (' + CAST (bo.Legacy_ID AS varchar(22))  + ')')) AS Operator_Details
								,bo.Operator_Address + ' ' +  bo.Operator_State + ' ' + bo.Operator_Zip AS Operator_Address
								,bo.Legacy_ID		
						from	billback b
						inner join bb_item_invoice_level bil
						on		bil.billback_id = b.billback_id
						and		bil.deleted = 0
					<!---	inner join contract_main cm
						on		cm.contract_main_id = bil.program_id
						left join bsa_foodservice_customers c
						on		c.bsa_foodservice_customers_id = bil.distributor_id--->
						
						left join bsa_foodservice_items_master i
						on		i.bsa_foodservice_items_master_id = bil.product_id
						left join bsa_operator bo
						on		bo.bsa_operator_id = bil.operator_id
						LEFT JOIN	Units_of_Measure ON Units_of_Measure.Unit_Of_Measure_ID = bil.UOM				
						WHERE b.billback_id =  '#FORM.Billback_ID#' AND
								bil.product_id = '#Product_ID#'  AND 
								bil.distributor_id = '#Customer_ID#' AND
								bil.Program_ID = '#Program_ID#'
						ORDER BY 
							bil.Billback_Program_ID, 
							bo.Legacy_ID,
							bil.Discount_Type_ID, 
							Item_Number 
						
						</cfquery>
					<cfelse>
						<cfset qGet_Opr_Products = querynew('xx')/>
					</cfif>
					<!--- D51977 :: END Billback enhancements for operator level data --->
	  
	  					<cfif GetValidDiscountsforProduct.Recordcount GT 0>
	    					<cfset ValidDiscountList = GetValidDiscountsforProduct.Discount_List>
	   					</cfif>
	   					<CFSET Replaced_Product_List = "#Product_ID#__#Customer_ID#_#BB_Product_UOM#">
	   					<CFSET Replaced_Product_List = REPLACE(Replaced_Product_List,"-","_","All") />
	 					
	 					<cfif not listFind(thisCust,Customer_ID)>
	 					<cfset thisProductOnProgram = "" />
						<CFSET UnknowProduct_Header_Reset = 0>
	  						<!--- <cfset getCustData = bbDeviationManager.getDistributorInfo(Customer_ID) /> --->
		  					<tr bgcolor="D2E1EE" >
		  					<td align="left" bgcolor="8B0000" colspan="100%" nowrap>
		    					<table border="0" style="border-bottom: 0;" cellpadding="0" cellspacing="0">
		 						<tr>
		  						<td style="border-bottom : 0" nowrap width="100%">
										<cfif trim(Shr_Ship_To) neq "" AND (appSettings.get_Setting('Display_Distributor_ID') EQ '1')>
										<span style="color:white; font-weight: bold;">
										#name#&nbsp;(#Shr_Ship_To#)&nbsp;::&nbsp;#city#, #state#
										</span> 
										<cfelseif trim(Ship_To) neq "" AND (appSettings.get_Setting('Display_Distributor_ID') EQ '0')>
										<span style="color:white; font-weight: bold;">
				 						#name#&nbsp;(#Ship_To#)&nbsp;::&nbsp;#city#, #state#
										</span> 
		   							<cfelse>
										<span style="color:white; font-weight: bold;">
			 							No #application.returned_customer_setting.distributor_label_singular# 
										</span> 
		   							</cfif>
		 						</td>
		 						</tr>
		 						</table>
							</td>
	    					</tr>
						</cfif>
						
							
						
						<cfset thisCust = listAppend(thisCust,Customer_ID,",") />
						
		
				<!--- if it's saved with a distributor, don't show each product only products for that distributor --->	
					<Cfset ShowDistributorItem = 1>
					<!--- Modifications to query getProductData will make sure it does only return necessary records for already existing products --->
					<!---
					<cfif listfind(Saved_products, Product_ID)>
						<CFIF len(trim(Customer_ID)) EQ 36><!--- make sure we have a guid --->
							<cfquery name="DoesHaveDistributor" datasource="#application.datasource#">
							SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
						 	SELECT 		DISTINCT 
										Product_ID,
										Distributor_ID,Item
							FROM 		Billback_Product 
							INNER JOIN 	BSA_FoodService_Items_Master ON BSA_FoodService_Items_Master.BSA_FoodService_Items_Master_ID = Billback_Product.Product_ID
							WHERE 		Billback_ID = '#FORM.Billback_ID#' AND
										Billback_Program_ID = '#BillbackProgramID#' AND
										Billback_Product.Deleted = 0
										AND Billback_Product.Product_ID = '#Product_ID#'
										AND Billback_Product.Distributor_ID = '#Customer_ID#'
							ORDER BY 	Distributor_ID,Item
							</cfquery>
							
							<Cfif DoesHaveDistributor.recordcount IS 0>
								<cfset ShowDistributorItem = 0>
							</Cfif>
						<CFELSE>
							<cfset ShowDistributorItem = 0>
						</CFIF>
						
					</cfif>					
					--->
	 					
	<cfif currentrow mod 2 eq 0>
	 <cfset tmpBgColor = "FFFFFF" />
    <cfelse>
	 <cfset tmpBgColor = "ccffcc" />
   </cfif>
    
	<!--- only show the item if the item has the distributor associated --->
	<cfif ShowDistributorItem>

	<cfif not listFind(thisProductOnProgram,Program_ID) AND getProductData.IsProductOnProgram EQ 2>
		<tr class="tableHeader">
			<td colspan="100%">
				Products Not On Program
			</td>
		</tr>
		<cfset thisProductOnProgram = listAppend(thisProductOnProgram,Program_ID,",") />
	</CFIF>
	<CFIF getProductData.IsProductOnProgram EQ 3 AND UnknowProduct_Header_Reset EQ 0>
		<tr class="tableHeader">
			<td colspan="100%">
				Unknown Products
			</td>
		</tr>
		<CFSET UnknowProduct_Header_Reset = 1>
	</CFIF>
	<!--- <tr><td colspan="100%"><cfdump var="#getSavedProdInfo#"></td></tr> --->
	<!--- D51977 :: START Billback enhancements for operator level data --->
	<cfscript>
	    for ( iNum = 1 ; iNum <= qGet_Opr_Products.recordCount ; iNum++ ) {
			writeOutput( '<tr width="100%" bgcolor="#tmpBgColor#"> <td colspan="100%" style="border-bottom : 0" width="100%"><table width="100%" border="0" style="border-bottom: 0;" cellspacing="0" cellpadding="2"><tr><td width="5%">&nbsp;</td>' );
			writeOutput( '<td width="36%">' );
	        writeOutput( qGet_Opr_Products.Operator_Details[ iNum ] );
			writeOutput( " :: " );
	        writeOutput( qGet_Opr_Products.Operator_Address[ iNum ] );
	        writeOutput( '</td>' );
			writeOutput( '<td width="69%">$' );
	        writeOutput( qGet_Opr_Products.Approved_Amount_CS[ iNum ] );
	        writeOutput( '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' );
	        writeOutput( qGet_Opr_Products.Item_BB_Volume_CS[ iNum ] );
	        writeOutput( "</td> </tr></table></td> </tr>" );
	    }
	</cfscript>
	<!--- D51977 :: END Billback enhancements for operator level data --->
	<tr bgcolor="#tmpBgColor#">
	 <td nowrap>
     <cfif bDisableLinks EQ 0>
	    <img bDelete="true" name="IMG_Delete_Scissor"  
	  	   src="/images/scissor.gif" title="click here to delete this product" border="0" 
	  	   onClick="deleteThisProduct('#Product_ID#', '#tmpBgColor#','#Program_ID#','#Customer_ID#',<cfif getSavedProdInfo.recordCount>'1'<cfelse>'0'</cfif>,'#IsProductOnProgram#')"style="cursor: pointer;">
     </cfif> 
	 </td>
	 					<td nowrap width="225">
		 					<!--- If BSA_Foodservice_Items_Master.Is_Divested = 1 the item should display red with an asterisk --->
	  						<cfif getProductData.Is_Divested EQ 1>
                <cfset bDivestedNote = 1 />
                <font color="red"></cfif>
							<cfif (appSettings.get_Setting('Display_Item_No') EQ '1')>
	  							#getProductData.Item# 
							<cfelse>
								#getProductData.UPC# 
							</cfif>
							<!--- <cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1 AND len(trim(getProductData.UPC)) GT 0><br>#getProductData.UPC#</cfif></cfif> --->
	  						<cfif getProductData.Is_Divested EQ 1>*</cfif>
	  						<br>#getProductData.Description#
	  						<cfif getProductData.Is_Divested EQ 1></font></cfif>
	 					</td>
	 					<td><!---<SPAN id="NegativeValueErrorSpan_#ProductCounter#"></SPAN>--->Extended<br>Amount</td>
	
	 					<!------ Fixed ----->
	  					<cfif ShowFixed  OR NOT appSettings.getHideInvalidComponentTypesInBillbacks()>
	  						<CFOUTPUT>
	  							<cfparam name="form.Discount1_#Program_ID#__#Replaced_Product_List#" default="#getSavedProdInfo.FixedAmt#" />
	  						</CFOUTPUT>
	   						<cfset fixedRate = EVALUATE("form.Discount1_#Program_ID#__#Replaced_Product_List#") />
	   
	 						<TD style="border-bottom:solid silver 1px;" align="center" valign="center"  nowrap>
								<font size="#Dollar_Sign_Size#"><b>$</b></font>
<SPAN ID="RateCollection_1_#Program_ID#__#Replaced_Product_List#">
	<input maxlength="10" 
			<cfif listfind(ValidDiscountList, "1")>class="ValidDiscount_#ProductCounter#"<cfelse>class="Discount_#ProductCounter#" </cfif>	
			name="Discount1_#Program_ID#__#Replaced_Product_List#" 
			type="Text" size="7" id="Discount1_#Program_ID#__#Replaced_Product_List#"
			value="<CFIF len(trim(fixedRate)) NEQ 0>#NumberFormat(fixedRate,'.99')#</CFIF>"
		    onFocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);" 
			onKeyUp="clenseText(this, '-.0123456789'); allowonlytwodecimalplaces(this);"
			onBlur="TwoDecimalsOnBlur(this);propogateProperty(this, 'style.backgroundColor', <cfif listfind(ValidDiscountList, "1")>'##ffff99'<cfelse>'##ffffff'</cfif>, false);"
			<cfif bDisableLinks EQ 1>disabled</cfif>></SPAN>
	  						</TD>
						</cfif>
						
						<!--- Rebate --->
						<cfif ShowRebate OR NOT appSettings.getHideInvalidComponentTypesInBillbacks()>
							<cfoutput>
     						<cfparam name="form.Discount2_#Program_ID#__#Replaced_Product_List#" default="#getSavedProdInfo.RebateAmt#" />
	 						</cfoutput>
	 						<cfset rebateRate = EVALUATE("form.Discount2_#Program_ID#__#Replaced_Product_List#") />
	 						<td style="border-bottom:solid silver 1px;" align="center"  nowrap>
	  							<font size="#Dollar_Sign_Size#" ><b>$</b></font>
	  <SPAN ID="RateCollection_2_#Program_ID#__#Replaced_Product_List#">
	   <input maxlength="10"  <cfif listfind(ValidDiscountList, "2")>class="ValidDiscount_#ProductCounter#"<cfelse>class="Discount_#ProductCounter#" </cfif>	
		      name="Discount2_#Program_ID#__#Replaced_Product_List#" 
		      type="Text" size="7" id="Discount2_#Program_ID#__#Replaced_Product_List#"
		      onFocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);" 
			  onKeyUp="clenseText(this, '-.0123456789'); allowonlytwodecimalplaces(this);"
			  onBlur="TwoDecimalsOnBlur(this);propogateProperty(this, 'style.backgroundColor', <cfif listfind(ValidDiscountList, "2")>'##ffff99'<cfelse>'##ffffff'</cfif>, false);"
              value="<CFIF len(trim(rebateRate)) NEQ 0>#NumberFormat(rebateRate,'.99')#</CFIF>" 	
		<cfif bDisableLinks EQ 1>disabled</cfif>>
		  </SPAN>
	  						</td>
	 						<cfif isnumeric(trim(rebateRate))>
	   							<CFSET Total_Of_Rates = Total_Of_Rates + trim(rebateRate)>
	  							<!---  <CFSET LocalRateSum = LocalRateSum + trim(rebateRate)> --->
	 						</cfif>
						</cfif>
						
						<!--- Growth --->
						<cfif ShowGrowth OR NOT appSettings.getHideInvalidComponentTypesInBillbacks()>
							<cfoutput>
	 						<cfparam name="form.Discount4_#Program_ID#__#Replaced_Product_List#" default="#getSavedProdInfo.GrowthAmt#" />
	 						</cfoutput>
	 						<cfset growthRate = EVALUATE("form.Discount4_#Program_ID#__#Replaced_Product_List#") />
	 						<TD style="border-bottom:solid silver 1px;" align="center"  nowrap>
	  							<font size="#Dollar_Sign_Size#" ><b>$</b></font>
	  <SPAN ID="RateCollection_4_#Program_ID#__#Replaced_Product_List#">
	   <input maxlength="10"  <cfif listfind(ValidDiscountList, "4")>class="ValidDiscount_#ProductCounter#"<cfelse>class="Discount_#ProductCounter#" </cfif>	
	          name="Discount4_#Program_ID#__#Replaced_Product_List#"  id="discountInput"
	          type="Text" size="7" value="<CFIF len(trim(growthRate)) NEQ 0>#NumberFormat(growthRate,'.99')#</CFIF>"
	          onFocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);" 
			  onKeyUp="clenseText(this, '-.0123456789'); allowonlytwodecimalplaces(this);"
			  onBlur="TwoDecimalsOnBlur(this);propogateProperty(this, 'style.backgroundColor', <cfif listfind(ValidDiscountList, "4")>'##ffff99'<cfelse>'##ffffff'</cfif>, false);" 
	     <cfif bDisableLinks EQ 1>disabled</cfif>>
		</SPAN>
	   						</TD>
	   						<cfif isnumeric(trim(growthRate))>
	    						<CFSET Total_Of_Rates = Total_Of_Rates + trim(growthRate)>
	    						<!--- <CFSET LocalRateSum = LocalRateSum + trim(growthRate)> --->
	   						</cfif>
	  					</cfif>
						
	 					<!--- Formula --->
						<cfif ShowFormulaPricing>
							<cfoutput>
     						<cfparam name="form.Discount5_#Program_ID#__#Replaced_Product_List#" default="#getSavedProdInfo.FormulaAmt#" />
	 						</cfoutput>
	  						<cfset formulaRate = EVALUATE("form.Discount5_#Program_ID#__#Replaced_Product_List#") />
	 						<TD style="border-bottom:solid silver 1px;" align="center"  nowrap>
       							<font size="#Dollar_Sign_Size#" ><b>$</b></font>
	   <SPAN ID="RateCollection_5_#Program_ID#__#Replaced_Product_List#">
	    <input maxlength="10"  <cfif listfind(ValidDiscountList, "5")>class="ValidDiscount_#ProductCounter#"<cfelse>class="Discount_#ProductCounter#" </cfif>	
	           name="Discount5_#Program_ID#__#Replaced_Product_List#" 
	           type="Text" size="7" id="discountInput"
	           value="<CFIF len(trim(formulaRate)) NEQ 0>#NumberFormat(formulaRate,'.99')#</CFIF>"
		       onFocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);" 
			   onKeyUp="clenseText(this, '-.0123456789'); allowonlytwodecimalplaces(this);"
			   onBlur="TwoDecimalsOnBlur(this); propogateProperty(this, 'style.backgroundColor', <cfif listfind(ValidDiscountList, "5")>'##ffff99'<cfelse>'##ffffff'</cfif>, false);" <cfif bDisableLinks EQ 1>disabled</cfif>>
		</SPAN>
	   						</TD>		
	   						<cfif isnumeric(trim(formulaRate))>
	    						<cfset Total_Of_Rates = Total_Of_Rates + trim(formulaRate)>
	    						<!--- <cfset LocalRateSum = LocalRateSum + trim(formulaRate)> --->
	   						</cfif>
	  					</cfif>
						
	  					<!--- Bid Request --->
	  					<cfif ShowBidRequest OR NOT appSettings.getHideInvalidComponentTypesInBillbacks()>
	  						<cfoutput>
	  						<cfparam name="form.Discount11_#Program_ID#__#Replaced_Product_List#" default="#getSavedProdInfo.BidAmt#" />
	  						</cfoutput>
	  						<cfset bidRate = EVALUATE("form.Discount11_#Program_ID#__#Replaced_Product_List#") />
	   						<!--- <CFSET BB_Current_Product_Type_ID = 11 /> --->
							<TD style="border-bottom:solid silver 1px;" align="center"  nowrap> 
	     						<font size="#Dollar_Sign_Size#" ><b>$</b></font>
	     <SPAN ID="RateCollection_11_#Program_ID#__#Replaced_Product_List#">
		  <input maxlength="10" <cfif listfind(ValidDiscountList, "11")>class="ValidDiscount_#ProductCounter#"<cfelse>class="Discount_#ProductCounter#" </cfif>	
		         name="Discount11_#Program_ID#__#Replaced_Product_List#" 
		         type="Text" size="7" id="discountInput"
		         value="<CFIF len(trim(bidRate)) NEQ 0>#NumberFormat(bidRate,'.99')#</CFIF>" 
		         onFocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);" 
			     onKeyUp="clenseText(this, '-.0123456789'); allowonlytwodecimalplaces(this);"
			     onBlur="TwoDecimalsOnBlur(this); propogateProperty(this, 'style.backgroundColor', <cfif listfind(ValidDiscountList, "11")>'##ffff99'<cfelse>'##ffffff'</cfif>, false);"	<cfif bDisableLinks EQ 1>disabled</cfif>>
		  </SPAN>
		 					</TD>		
							<cfif isnumeric(trim(bidRate))>
		 						<cfset Total_Of_Rates = Total_Of_Rates + trim(bidRate)>
		 						<!--- <cfset LocalRateSum = LocalRateSum + trim(bidRate)> --->
							</cfif>													
	   					</cfif>
						
       					<!--- Claim adjustment --->
	   					<cfif ShowClaimAdjustment>
	   						<cfoutput>
	    					<cfparam name="form.Discount10_#Program_ID#__#Replaced_Product_List#" default="#getSavedProdInfo.ClaimAdjAmt#" />
							</cfoutput>
	    					<cfset claimRate = EVALUATE("form.Discount10_#Program_ID#__#Replaced_Product_List#") />
	    					<TD style="border-bottom:solid silver 1px;" align="center"  nowrap>
		 						<font size="#Dollar_Sign_Size#" ><b>$</b></font>
		  <SPAN ID="RateCollection_10_#Program_ID#__#Replaced_Product_List#">
		   <input maxlength="10" class="Discount_#ProductCounter#" 
			      name="Discount10_#Program_ID#__#Replaced_Product_List#" 
				  type="Text" size="7" id="discountInput"
				  value="<CFIF len(trim(claimRate)) NEQ 0>#NumberFormat(claimRate,'.99')#</CFIF>"
		          onFocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);" 
			      onKeyUp="clenseText(this, '-.0123456789'); allowonlytwodecimalplaces(this);"
			      onBlur="TwoDecimalsOnBlur(this); propogateProperty(this, 'style.backgroundColor', '##ffffff', false);"				   	
			 <cfif bDisableLinks EQ 1>disabled</cfif>>
		  </SPAN>
		 					</TD>													
						</cfif>

											
						<TD nowrap><SPAN id="VolumeCollectionErrorSpan_#ProductCounter#"></SPAN>
						<!--- The volume text box has a few ID's associated with it.The ones starting with the word "Err" are for displaying error messages. 
									In the Onchange event below for UOMcollection , we use firstchild.lastchild bcoz the "VolumeCollection" id is the last id below (the spans are one inside the other) 
									and is being used for changing the UOM's --->
							<cfoutput>
		    				<cfparam name="form.Volume_#Program_ID#__#Replaced_Product_List#" default="#getSavedProdInfo.BB_Product_Quantity#" />
							<cfparam name="form.UOM_#Program_ID#__#Replaced_Product_List#" default="#getSavedProdInfo.BB_Product_UOM#" />
							</cfoutput>			
	        				<cfset volumeRate = EVALUATE("form.Volume_#Program_ID#__#Replaced_Product_List#") />
							<cfset selectedUOM =EVALUATE("form.UOM_#Program_ID#__#Replaced_Product_List#") />
							<span id="VolumeCollection">
							<span id="Err_Volume_#Program_ID#__#Replaced_Product_List#"></span>
							<span id="Err_Percent_Volume_#Program_ID#__#Replaced_Product_List#"></span>
							
			<cfif (getProductData.User_Picked_UOM EQ 6)>
				<cfset volumeRate = getProductData.User_Entered_Quantity />
				<cfset selectedUOM = 6 />
			</cfif>
			<input name="Volume_#Program_ID#__#Replaced_Product_List#"   
				   class="Volume_#ProductCounter#" id="volume_#Program_ID#_#currentRow#" type="text" size="7" maxlength="10" 
				   value="<CFIF len(trim(volumeRate)) GT 0>#trim(NumberFormat(volumeRate, '_.__'))#</CFIF>" 
		           onFocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);" 
				   <CFIF appSettings.getBB_Fractional_Volume()>
			       onKeyUp="clenseText(this, '-.0123456789'); allowonlytwodecimalplaces(this);"
				   <CFELSE>
				   onKeyUp="clenseText(this, '-0123456789');"
				   </CFIF>
			       onBlur="TwoDecimalsOnBlur(this); propogateProperty(this, 'style.backgroundColor', '##ffffff', false);"
              <cfif bDisableLinks EQ 1>disabled</cfif>>
		     
			</span>

	<cfif getProgramInfo.RateTypeOption_4>
		<cfset uom_exclusion_list = "3">
	<cfelse>
		<cfset uom_exclusion_list = "3,6">
	</cfif>
	
							<span id="UOMCollection">
							<cf_uom_dropdown
							  company_main_id			=	""
							  default_option_on		=	""
							  default_option_text		=	""
							  default_option_value	=	""
							  dropdown_name			=	"UOM_#Program_ID#__#Replaced_Product_List#"
							  option_text_abbreviated	=	"1"
							  plural_uom_display		=	"1"
							  product_type_id			=	""
							  program_template_id		=	""
							  selected_uom_id			=	"#selectedUOM#"
							  text_before_tag_close	=	""
							  uom_id_exclusion_list	=	"#uom_exclusion_list#"
							  uom_id_inclusion_list	=	""
			  onchange              =   "updateVolume();"
			  dropdown_id           =   "uom_#Program_ID#_#currentRow#"
         disabled="#bDisableLinks#">
							</span>
			<input type="hidden" name="net_weight_#Program_ID#_#currentRow#" id="net_weight_#Program_ID#_#currentRow#" value="#trim(getProductData.Net_Weight)#" />
		   				</TD>
		  				<CFIF isnumeric(trim(volumeRate))>
		   					<CFSET Total_Of_Volume = Total_Of_Volume + trim(volumeRate)>
		  				</CFIF>
		  				<CFIF isnumeric(trim(claimRate))>
		    				<CFSET Total_Of_Rates = Total_Of_Rates + trim(claimRate)>
		    				<!--- <CFSET LocalRateSum = LocalRateSum + trim(claimRate)> --->
		  				</CFIF>		
													
						<!---Adds spaces to the end of the table to make it look nice --->
		  				<cfloop	from="0" to="#EndSpaces#" index="Count" step="1"><td>&nbsp;</td></cfloop>					
			  			<td>&nbsp; </td>
	 					</tr>
	 					</cfif> 
	 			<!--- D51977 :: START Billback enhancements for operator level data --->
				<!---	<cfloop query="qGet_Opr_Products" >
						<tr class="tableHeader">
							<td colspan="100%">
								#qGet_Opr_Products.Approved_Amount_CS#  ::  #qGet_Opr_Products.Operator_Id# ::  #qGet_Opr_Products.Operator_Name#
							</td>
						</tr>	
					</cfloop>--->
				<cfset LastPercent = 0>
				<!--- This will return values of 1 through 10 (1 being 10%, 2 being 20%....10 being 100%) --->
				<cfset PercentDone = Int(Ceiling((productcounter/BBProductCount) * 100)/10)>

				<!--- Show the Image based on product count --->
				<cfif LastPercent neq PercentDone>
					<cfset Block = "Block" & PercentDone>
					<script>
					<cfif PercentDone LTE 9><!--- Only show till 90%. 100% is at the end of the page. --->
					<cfoutput>if(document.#Block#){document.#Block#.src = '/images/red_block.gif';}</cfoutput>
					</cfif>
					//Show the progress in percent
				 <cfset PercentDone = PercentDone&'0'>
				 <!--- Only show till 90%. 100% is at the end of the page. --->
				 <cfif PercentDone LTE 90>
				 <cfoutput>if(document.getElementById('ShowPercentProgress')){document.getElementById('ShowPercentProgress').innerHTML = '#PercentDone#%';}</cfoutput>
				 </cfif>
					</script>		
					<cfflush>
					<cfset LastPercent = PercentDone>
				</cfif>
<!---- ShowDistributorItem --->
					</cfloop>
	  			</cfif>
		
		<!--- -------------------------------------------------------------------- --->	
				<!--- END Product display --->
				<!--- -------------------------------------------------------------------- --->
	   			<input type="hidden" name="Product_List_#Program_ID#" value="<cfoutput>#ThisProgram_ProductList#</cfoutput>" />	       		
				<CFSET ThisBB_ProductList = LISTAPPEND(ThisBB_ProductList,ThisProgram_ProductList)>
		  		<CFSET ThisProgram_ProductList = "">
			</table>
			</div>
		</td>
		</tr>
		<!--- Ana: Looks like an extra table --->
		</table>
		<tr>
		<td>&nbsp;</td>
		</tr>
		
	</td>
	</tr>
	</table>
	<CFSET showProductInfo = "false">
	</cfloop>
	<!--- Products --->
	<cfset local_bbid = Form.Billback_ID>
	<cfinclude template="bb_menu_stats.cfm">
			
	<script>
		if(window.parent.summary_tab)
		{
			window.parent.current_menu_item = "programs";
			window.parent.assignActiveTab();
			window.parent.buildMenu();
		}
	</script>
	<CFSET InfoBar_BBID = Billback_ID>

	<cfinclude template="billback_load_infobar.cfm">
</cfif>


<cfif LookForExistingProgram.RecordCount>
<script type="text/javascript">
function FillRebateValues()
{	
	<cfif BB_User_Profile.BB_Apply_Rebate_Rates eq 1 AND GetSettings.Apply_Rebate_Rates eq 1 AND GetSettings.Discount_Rebates eq 1 and listLen(ThisBB_ProductList) neq 0> 		
		<cfquery name="getProductRebates" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			
			IF OBJECT_ID('tempdb..##Temp_Rate_Holder_Component_Level') IS NOT NULL
				DROP TABLE ##Temp_Rate_Holder_Component_Level

			SELECT Billback_Program_Rebate_Component.Billback_Program_ID AS Program_ID, cp.BSA_Foodservice_Items_Master_ID Product_ID,prcd.Unit_of_Measure_ID,CAST(Rate AS Decimal(18,4)) Rate,bsaim.Net_Weight,
						CASE 	WHEN prcd.Unit_of_Measure_ID = 1 THEN
									CAST(Rate AS Decimal(18,4))
								WHEN prcd.Unit_of_Measure_ID = 2 THEN
									CAST(Rate AS Decimal(18,4)) * bsaim.Net_Weight
						END CS_Rate,
						CASE 	WHEN prcd.Unit_of_Measure_ID = 1 THEN
									CAST(Rate AS Decimal(18,4)) / bsaim.Net_Weight
								WHEN prcd.Unit_of_Measure_ID = 2 THEN
									CAST(Rate AS Decimal(18,4))
						END LB_Rate
			INTO 		##Temp_Rate_Holder_Component_Level
			FROM 		Billback_Program_Rebate_Component 
			INNER JOIN 	program_rebates_component prc ON  Billback_Program_Rebate_Component.Billback_ID = '#FORM.Billback_ID#' AND
						Billback_Program_Rebate_Component.Billback_Program_ID IN (#FORM.Program_List#) AND
						Billback_Program_Rebate_Component.Checked = 'True' AND
						Billback_Program_Rebate_Component.Deleted = 0 AND
						prc.program_rebates_component_id = Billback_Program_Rebate_Component.Program_Rebates_Component_ID
			INNER JOIN 	program_rebates_component_data prcd ON prcd.program_rebates_component_id = prc.program_rebates_component_id AND
						prcd.Deleted = 0
			INNER JOIN 	program_rebates_product_data prpd ON prcd.program_rebates_product_data_ID = prpd.program_rebates_product_data_ID AND
						prpd.Deleted = 0
			INNER JOIN 	contract_products cp ON prpd.contract_products_id = cp.contract_products_id AND
						cp.BSA_Foodservice_Items_Master_ID IN (#LISTQUALIFY(ThisBB_ProductList,"'")#) AND
						cp.Deleted = 0
			INNER JOIN 	BSA_Foodservice_Items_Master bsaim ON bsaim.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
			
			SELECT 		Program_ID ProgID, 
						LOWER(REPLACE(CAST(Distributor_ID AS VARCHAR(50)),'-','_')) Distributor_ID, 
						LOWER(REPLACE(CAST(Product_ID AS VARCHAR(50)),'-','_')) Product_ID,
						SUM(ISNULL(CS_Rate,0)) CS_Rate,
						SUM(ISNULL(LB_Rate,0)) LB_Rate 
			FROM 		##Temp_Rate_Holder_Component_Level
			<CFIF getPayeeInfo.Billback_Payee_Type_ID EQ 1>
			INNER JOIN	Billback_Distributor ON Billback_ID = '#FORM.Billback_ID#' AND Deleted = 0
			<CFELSEIF getPayeeInfo.Billback_Payee_Type_ID EQ 2>
			INNER JOIN 	BillBack_Distributor_List ON Billback_ID = '#FORM.Billback_ID#' AND Deleted = 0
			</CFIF>
			GROUP BY 	Program_ID,Distributor_ID,Product_ID
		</cfquery>						
	
		<CFLOOP QUERY ="getProductRebates">			
			if (document.KnownProgramForm.Discount2_<CFOUTPUT>#ProgID#</CFOUTPUT>__<CFOUTPUT>#Product_ID#</CFOUTPUT>__<CFOUTPUT>#Distributor_ID#</CFOUTPUT>)
			{
				var csRate = "<CFOUTPUT>#CS_Rate#</CFOUTPUT>"
				var lbRate = "<CFOUTPUT>#LB_Rate#</CFOUTPUT>"
				var rebateVolume = document.KnownProgramForm.Volume_<CFOUTPUT>#ProgID#</CFOUTPUT>__<CFOUTPUT>#Product_ID#</CFOUTPUT>__<CFOUTPUT>#Distributor_ID#</CFOUTPUT>.value
				var rebateUOM = document.KnownProgramForm.UOM_<CFOUTPUT>#ProgID#</CFOUTPUT>__<CFOUTPUT>#Product_ID#</CFOUTPUT>__<CFOUTPUT>#Distributor_ID#</CFOUTPUT>.value
				
				if (rebateUOM == 1 && parseFloat(rebateVolume) > 0)
				{
					document.KnownProgramForm.Discount2_<CFOUTPUT>#ProgID#</CFOUTPUT>__<CFOUTPUT>#Product_ID#</CFOUTPUT>__<CFOUTPUT>#Distributor_ID#</CFOUTPUT>.value = rebateVolume * csRate
				}
				else
				{
					document.KnownProgramForm.Discount2_<CFOUTPUT>#ProgID#</CFOUTPUT>__<CFOUTPUT>#Product_ID#</CFOUTPUT>__<CFOUTPUT>#Distributor_ID#</CFOUTPUT>.value = rebateVolume * lbRate
				}							
			}
		</CFLOOP>
	</cfif>
}
</script>
</cfif>
</cfoutput>
  <cfif bDivestedNote EQ 1>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<FONT COLOR="Red">* - indicates the item is divested</FONT></cfif>

<table align="center" cellspacing="5" border="0">
	<TR>
	<TD <cfif HasDefaultProgram>title="<cfoutput>#defaultProgramMessage#</cfoutput>"</cfif>>
  <cfif bDisableLinks EQ 0>
		<CF_button
			button_name		=	"save"
			button_caption	=	"save"
			button_action	=	"verifyData(0);"
			button_type		=	"javascript_link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"11"
			font_weight		=	"bold"
			enabled			= 	"#HasDefaultProgram eq 0#"
		>	
   
  </cfif>  
	</TD>
	<!--- Currently (Jan, 06), the billback report in Excel is only for Pactiv. More work needs to be done to make it work for other clients. --->
<cfif appSettings.getShowBBExcelReport() AND len(trim(bbid)) GT 0>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"programs report"
			button_action	=	"program_form.cfm?bbid=#bbid#&xl=1"
			button_type		=	"link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"11"
			font_weight		=	"bold"
		>	
	</TD>
</cfif>
<cfif bDisableLinks EQ 0>
	<td>
		<CF_button
			button_name		=	"clear"
			button_caption	=	"clear"
			button_action	=	"resetToZero();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Clear"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</td>
</cfif>	
</TR>
</table>

<cfif HasDefaultProgram>
<table align="center" cellspacing="5" border="0">
<tr>
	<td colspan="2" style="color:red;" align="center">
	<cfoutput>#defaultProgramMessage#</cfoutput>
	</td>
</tr>
</table>
</cfif>

</form>
	<cfinclude template="floating_layer.cfm" />
	<input type="hidden" name="temp_rate_storage"	value="0">
<script>

function resetToZero()
{
	var KnownProgramFormList = document.forms['KnownProgramForm'].elements;
	var i=KnownProgramFormList.length;
	var name_;
	var elem;

	for (var i=0, il= KnownProgramFormList.length; i<il; i++){
 		elem =KnownProgramFormList[i]
		name_ = elem.name;
		if(elem.type=='text' && (name_.indexOf('Volume_')== 0 || name_.indexOf('Discount_')== 0 || name_.indexOf('Discount1_')== 0 || name_.indexOf('Discount2_')== 0 || name_.indexOf('Discount4_')== 0 || name_.indexOf('Discount5_')== 0 || name_.indexOf('Discount10_')== 0 || name_.indexOf('Discount11_')== 0 || name_.indexOf('LumpSumCompID_')== 0 ) )
		{
			if(elem.value != '')
			{
				elem.value= '';
			}
		}	
	}
}


 function AdjustRateTotal()
 {

	var total = parseFloat(0);
	var variance = parseFloat(0);
	var totalRates = document.getElementById("exTotalRates").value;
	var KnownProgramFormList = document.forms['KnownProgramForm'].elements;
	var i=KnownProgramFormList.length;
	var name_;
	var elem;

	for (var i=0, il= KnownProgramFormList.length; i<il; i++){

			 elem =KnownProgramFormList[i]
			 name_ = elem.name;

				if(elem.type=='text' && name_.indexOf('Volume_')== -1)
				{
					if(elem.value != '')
					{
						if(elem.disabled == false)
						{
							total = total + parseFloat(elem.value);	
						}
					}
				}	
			}
			// Update the InfoBar with the total amount
      //$(window.parent.document.all.infoBar_BB_Amount).html("$"+ '<NOBR>' + FormatTextWithCommas(total) + '</NOBR>');
			document.getElementById("Total_Rates").innerHTML = FormatTextWithCommas(total);
                     
			// Update the FLoating layer
      variance = (parseFloat(totalRates) - total);
      
      if (variance >= 0)
      {
				 document.getElementById('Delta_Rates').innerHTML = '<font color=green>' + FormatTextWithCommas(variance) + '</font>'
				 document.getElementById('dollarSign').innerHTML = '<font color=green>' + '$' + '</font>'
      }
      else
      {
				 document.getElementById('Delta_Rates').innerHTML = '<font color=red>[' + FormatTextWithCommas(variance) + ']</font>'
				 document.getElementById('dollarSign').innerHTML = '<font color=red>' + '$' + '</font>'
      }
          
   }

	function OpenChangeWindow(ProgramToChange)
		{
			document.all.runsearchonfirstload.value 			= document.all.temp_ExistingProductList_Programs.value;
			document.all.FilterSearchPrograms.value 	= 1;
			document.all.FilterType.value 				= 0;
			document.all.runsearchonfirstload.value = 1;
			 document.all.ProgramToSwitch.value = 0;
			<cfoutput>
			document.all.FilterType.value 		= '#getPayeeInfo.Billback_Payee_Type_ID#';
			document.all.FilterDataList.value 	= '#getPayeeID#';
			<!--- D31454:Single Billback Per Invoice:   program search logic START  --->
			<cfif IIIvalue.III_P_Upload_Single_BB_Per_Invoice EQ 1 AND len(FiltersList) GT 0><!--- D31863 :Error with Operator Billbacks --->
			var FinalFilterList = document.getElementById('FilterDataList').value.concat(',');
		 		FinalFilterList = FinalFilterList.concat('#FiltersList#');
				document.all.FilterDataList.value = FinalFilterList;
			</cfif>
			<!--- D31454:Single Billback Per Invoice:   program search logic END  --->
			if(confirm("Unsaved data (if any) will be lost. Do you want to continue?"))
				{
					NewWindow("/billbacks/search_screens/search_programs.cfm?Formname=KnownProgramForm&fieldname=Program_List&Program_ID="+ProgramToChange+"&Billback_ID=#FORM.Billback_ID#&SelectSingleSearchResultOnly=1&ModifyProgram=1", "programswindow", 800, 600, "yes", "yes")			
				}
			 </cfoutput>  
		}


    function checkForNegatives()
		{
			var KnownProgramFormList = document.forms['KnownProgramForm'].elements;
			var LastPos;
			var ValidDiscountInputLength = 0;
			var ValidDiscountInputValue= '';
			var DiscountInputLength = 0;
			var DiscountInputValue = '';
			var VolumeInputValue;
			var Number_Sign = 0;
			var ValidDiscountExist = 0;
			var ValidDiscountItemNumber = '';
			var DiscountItemNumber = '';
			var VolumeItemNumber = ''
			var error = 0;
			var ItemCountNumber = 1;
			var Element_Name_;
			var Element_Value_;
			var IsTableObject = 1;
	

				/* get list of programs on the billback which have rebate included on the billback but have a  missing
				rebate component on the billback, i.e. the "billback_program_rebate_component" table.
				This can happen in the following scenario:
				- User has program on a billback which only has rebate.
				- User clicks on "modify program" on the billback program page and changes the program and the new
				program has fixed price only. When this happens, the rebate data for the previous program gets deleted,
				but the rebate still shows on the page. As long as the user does not enter any values for rebate on the
				new program (which does not have any rebate, anyway), there will be no issues, but in some cases, user
				has actually tried to enter rebate values for the program, even though it does not have any rebate. So, we
				end up with rebate data without any rebate component data.				
				This solution is a backup solution. We also modified code on  "switch_program.cfm" so that rebate does
				not show up on this page.
				*/
				listProgMissingRebateComponent = ListOfPrgWithNoRebateComponents();


				theTables=document.all.customerTbl;

				if(document.all.customerTbl.length == undefined)
				{
					theTables.length  = 1;
					IsTableObject = 0;
				}

			/* Every program in the billback has a table with the same id (customerTbl)
				 and so we have to loop through these tables 
			*/
			for(var m=0, ml= theTables.length; m<ml; m++)
			{

			/* If the customerTbl.length is undefined or the length is just 1. */
				if(IsTableObject == 0 || theTables.length == 1)			
				{
					theRows = document.all.customerTbl.rows
				}
				else
				{		
					theRows = document.all.customerTbl[m].rows
				}
				
				for (var i=0, il= theRows.length; i<il; i++)
				{
					trObj = theRows[i];
				
					inpColl = trObj.getElementsByTagName('input')

					IsNegativeNumber = 0;
					error = 0;

			

					/* Loop through the input elements */
					for (var j=0, jl= inpColl.length; j<jl; j++)
					{

							inputObj = inpColl[j];

								if(inputObj.getAttribute('type') == 'text')
								{							
										if(inputObj.disabled == false)
										{				
											Element_Name_ = inputObj.getAttribute('name');
											/* On IE 10, inputObj.getAttribute('value') gets the "original" value, 
											i.e. value before the user modified it. */
											//Element_Value_ = inputObj.getAttribute('value');
											Element_Value_ = inputObj.value;
								
										/* Check for Volume */
											if(Element_Name_.indexOf('Volume_') != -1)
											{											
												className_ =  inputObj.className;
												LastPos = className_.indexOf('_');
												/* Get the Product count number in the loop */
												ItemCountNumber = className_.substring(LastPos + 1,className_.length);

													error_text 		= "Please enter a valid volume (1 or more units)";
													error_oSpan 	= eval('VolumeCollectionErrorSpan_'+ItemCountNumber)
													//error_ID	= KnownProgramFormList[error_oSpan]

												 if(Element_Value_ == '' || Element_Value_ == '0.00')
												 {
													ErrorCount++;
													queueMessage(error_text, error_oSpan);
												 }
												 else
												 {
													clearQueue(error_oSpan);
												 }

											}

											/* Check for Lumpsum */
											if(LS_Delete == 0){
											if(Element_Name_.indexOf('LumpSumCompID_') != -1){
												if(Element_Value_ == '' || Element_Value_ <= 0){
													/* If any one of the lump sum text boxes has a blank or a zero value. */
													LS_Delete = 1;		
												}
											}
										
											/* If it's rebate. "Discount2" will be a part of name of either textboxes with a rebate value OR
											the hidden value which stores the number of rebate components per program.
											*/
											if(Element_Name_.indexOf('Discount2') != -1)
											{
												var firstUnderScorePosition;
												var secondUnderScorePosition;
												var prog_id;

												firstUnderScorePosition = 9; /* On ('Discount2_'), "_" is on the 9th position, starting from 0. */
												secondUnderScorePosition = Element_Name_.indexOf('_',10); /*Look for the second "underscore" */
												prog_id = Element_Name_.substring(firstUnderScorePosition + 1,secondUnderScorePosition);

												error_text 	= "This billback does not include a rebate discount type for some of the dollars and cases."
												
												error_text 	= error_text + "Please move the dollars to the proper discount type, select a different program, or, revise this program to include the appropriate discount type."  
												
												error_text 	= error_text + "To select a Rebate component, click on the green check mark in the program header.  That will provide a pop-up to select a rebate component.";

												error_oSpan 	= eval('document.all.ProgErrorSpan_' + prog_id)

												/*If the user entered a rebate value */
												if(Element_Value_ != '')
												{
													/*If the user entered rebate values for a program which doe not have any rebate component */
													if((ListFindItem(listProgMissingRebateComponent,",",prog_id) != -1))		
													{
														ErrorCount++;
														queueMessage(error_text, error_oSpan,'950');
														/*Remove the program from the comma-delimited list, so that the error message does not
														show up twice for the same program. Without it, the error message will show up as many times
														as there are rebate textboxes.													
														*/
														listProgMissingRebateComponent = ListDeleteItem(listProgMissingRebateComponent,",",prog_id,0)
													}
													else
													{
														clearQueue(error_oSpan);
													}

												}
												else
												{
													clearQueue(error_oSpan);
												}

											}

										}

										if(inputObj.value != '')
										{												
											/* Is it a negative number */
											if(parseFloat(inpColl[0].getAttribute('value')) < 0)
											{
												IsNegativeNumber = 1;
											}

												if(IsNegativeNumber == 1)
												{
												/*	If any of the previous entries in the product row was negative and the current value
														is positive, then flag this row.
												*/
													if(parseFloat(Element_Value_) > 0 )
													{
														error = 1;
														break;
													}
												}
												/* If none of the previous entries in the product row were negative, but the current one (the last entry
													 in the row), then flag this row.
												*/
												else
												{
													if(parseFloat(Element_Value_) < 0 )
													{
														error = 1;
														break;
													}

												}
										}
									}

								}
							}					
							if(error == 1){
								if(confirm("Negative value is entered for one or more products. Do you want to continue?")){
									NegativeValue = 0;					
								}
								else{
									NegativeValue = 1;
								}
							}
							
							/* Comment the below code. The code was a hard-stop for Heinz. Now the hard-stop is removed. It is just a warning now - ok or cancel. */
							/*error_text 	= "If a negative value is entered for a particular product you must enter negative values for that entire row";
							error_oSpan 	= "NegativeValueErrorSpan_"+ItemCountNumber;
							error_ID			= KnownProgramFormList[error_oSpan];

								if(error == 1)
								{
										ErrorCount++;
										queueMessage(error_text, error_ID);
								}
								else
								{
										clearQueue(error_ID);
								}*/	
						}
					}
				}

function ListOfPrgWithNoRebateComponents()
{
	var arrProgMissingRebateComponent = new Array();
	var listProgMissingRebateComponent = '';
	
	/* "Program_List" stores the list of programs. */
	if(document.all.Program_List.value != ''){
		/* List of programs in an array. */
		var arrProgList = document.all.Program_List.value.split(',');
	}
	else{
		var arrProgList = new Array();
	}
	
	/* loop through the list of programs */
	for(var i=0; i<arrProgList.length; i++)
	{
	objName = 'Discount2_'+ arrProgList[i]+'_RebateCompCount';
	objValue = eval("document.all." + objName+'.value');
		
		/* Check how many rebate components there are on the billback for a specific program. */
		if(objValue == 0)
		{
			/* If there are zero, then include that program. */
			arrProgMissingRebateComponent.push(arrProgList[i]);
		}		
	}
	
	/* convert the array to a list. */
	listProgMissingRebateComponent = arrProgMissingRebateComponent.join();

return listProgMissingRebateComponent;
}

  
  function updateVolume()
  {
	var KnownProgramFormList = document.forms['KnownProgramForm'].elements;	
	var i=KnownProgramFormList.length;
	var RateFormList = document.forms['rateForm'].elements;
	var FirstPos;
	var LastPos;
	var ProgID;
	var net_weight;
	var uom;
	var volumeTotalCS = 0;
	var volumeTotalLB = 0;
	var volumeCS = 0;
	var volumeLB = 0;
	var volumeVarianceCS = 0;
	var volumeVarianceLB = 0;
	var ItemNumber;
	var elem_Suffix;
	var theDoc = window.document;

	for (var i=0, il= KnownProgramFormList.length; i<il; i++){

	elem =	KnownProgramFormList[i];
			 name_ = elem.name;
			 type_ = elem.type
			 value_ = elem.value;
			 disabled_ = elem.disabled;
			 id_ = elem.id;

				if(type_=='text' && name_.indexOf('Volume_') != -1)
				{
					if(value_ != '')
					{
						if(disabled_ == false)
						{		
							FirstPos = id_.indexOf('_') + 1;/* First Underscore */
							LastPos = id_.lastIndexOf('_') ;/* Last Underscore */
							ProgID = id_.substring(FirstPos,LastPos);/* ProgramID */
							ItemCountNumber = id_.substring(LastPos + 1,elem.id.length);
							elem_Suffix = '_'+ProgID+'_'+ItemCountNumber;
		
							net_weight = KnownProgramFormList['net_weight'+elem_Suffix].value;
							uom = KnownProgramFormList['uom'+elem_Suffix].value;
			
							if(uom == 1){
								volumeTotalCS = volumeTotalCS + parseFloat(elem.value);	
								volumeLB = parseFloat(elem.value) * parseFloat(net_weight);
								volumeTotalLB = volumeTotalLB + volumeLB;
							}

							if(uom == 2){
								volumeCS = parseFloat(elem.value) / parseFloat(net_weight);
								volumeTotalCS = volumeTotalCS + volumeCS;
								volumeTotalLB = volumeTotalLB + parseFloat(elem.value);								
							}
						}
					}
				}
			}

				theDoc.getElementById('Grand_Total_Vol_CS').innerHTML = FormatTextWithCommas(volumeTotalCS);
				theDoc.getElementById('Grand_Total_Vol_LB').innerHTML = FormatTextWithCommas(volumeTotalLB);

				volumeVarianceCS = parseFloat(RateFormList['exTotalCS'].value) - volumeTotalCS;
				volumeVarianceLB = parseFloat(RateFormList['exTotalLB'].value) - volumeTotalLB;

					if (volumeVarianceCS >= 0)
					{
					theDoc.getElementById('Delta_Vol_CS').innerHTML = '<font color=green>' + FormatTextWithCommas(volumeVarianceCS) + '</font>'
					}
					else
					{
					theDoc.getElementById('Delta_Vol_CS').innerHTML = '<font color=red>[' + FormatTextWithCommas(volumeVarianceCS) + ']</font>'
          }

					if (volumeVarianceLB >= 0)
					{
					theDoc.getElementById('Delta_Vol_LB').innerHTML = '<font color=green>' + FormatTextWithCommas(volumeVarianceLB) + '</font>'
					}
					else
					{
					theDoc.getElementById('Delta_Vol_LB').innerHTML = '<font color=red>[' + FormatTextWithCommas(volumeVarianceLB) + ']</font>'
					}    
    
       layerDisplayToggle();
    } 
    
       layerDisplayToggle();	
</script>


<!--- BSD 11544  --->
<script>
try { window.parent.dyniframesize(); } catch (err) { };
//Hide the Progress Bar
 if(document.getElementById('Progress_Bar')){
 	document.getElementById('Progress_Bar').style.display = 'none';
 }
//Show the progress in percent (100%)
 if(document.getElementById('ShowPercentProgress')){
	document.getElementById('ShowPercentProgress').innerHTML ='100%';
 }
</script>
</BODY>
</HTML>
<cfsetting showdebugoutput="true" />  