<cfparam name="url.cid" default="">
<cfparam name="url.eztemplate" default="0">
<cfparam name="lumpsum_name_ids" default="">
<cfparam name="form.allownegative" default = "false" />
<cfparam name="URL.Sort_By" 	default="Item">
<cfparam name="donotallowaddproductsDE" default = "0">
<cfparam name="form.deletedateexclusions" default = "0">
<cfparam name="form.update" default="0">
<cfparam name="form.groupLevelProducts" 	default="0">
<cfparam name="form.Product_Level_1" 	default="">

<cfinclude template="/common_files/jquery.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.numeric.js"></script>
<cfif Not isDefined("session.group_rebate_type_search_id")>
	<cfset group_rebate_type_search_id = 0>
</cfif>
<cfset session.group_rebate_type_search_id = 0>
<cfset thisPage=GetFileFromPath(GetCurrentTemplatePath())>
<cfset fullUrl="">

<cfloop collection=#URL# item="thisURLItem">
	<cfif thisURLItem NEQ "Sort_By">
		<cfset fullUrl=ListAppend(fullUrl, "#thisURLItem#=#StructFind(URL, thisURLItem)#","&")>
	</cfif>
</cfloop>

<cfif Len(fullUrl) GT 0>
	<cfset fullUrl="#thisPage#?#fullUrl#&">
<cfelse>
	<cfset fullUrl="#thisPage#?">
</cfif>

<cfset ParentprogramInfo = queryNew("Revision_of_Contract_main_id")>
<cfset appSettings = application.appsettingsGet />
<cfset page_title= "Product #Application.LumpsumLabel# Component Creation">

<cfif len(trim(URL.CID)) GT 0>
	<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
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
	<!--- Dev Notes: 22308/Anand Rao/04-Feb-10 CAG - multi discount type template--->
	<cfset sDiscountType = "LUMPSUM" />
	<cfset Contract_Main_ID = cryp.value>
	<cfinclude template="inc_Discount_Type_Checker.cfm" />
	<cfinclude template="/get_access_profile.cfm">
	<!--- D50074 :: Viewing and Editing prior program versions START --->
	<cfset ModifyDeletedPrograms = CreateObject("component","components.programs.program").ModifyDeletedProgram(GetContractInfo.Contract_Main_ID,Get_Profile_Settings.Modify_Expired_Programs) />
	<!--- D50074 :: Viewing and Editing prior program versions END --->
	<!--- Do not show the tabs if the contract is approved --->
	<!--- D50074 :: Viewing and Editing prior program versions --->
	<cfif GetContractInfo.Contract_Status_Type_IDX GT 2 AND ModifyDeletedPrograms EQ 0>
		<script>
			history.back();
		</script>
		<cfabort>
	</cfif>
</cfif>

<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<cfset LumpSumManager = CreateObject("component", "components.programs.lump_sum_components.LumpSumManager") />
<cfset LumpSumDataManager = CreateObject("component", "components.programs.lump_sum_components.DataManager").init() />
<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset PaymentCycleManager = CreateObject("component", "components.programs.PaymentCycleManager") />


<!DOCTYPE HTML PUBLIC "-//W3C//Dtd HTML 4.01 transitional//EN">
<html>
<head>
	<title><cfoutput>#page_title#</cfoutput></title>
	<script type="text/javascript" src="/script/tTip.js"></script>
	<link rel="stylesheet" href="/styles/tTip.css" type="text/css" />
</head>

<BODY>
<div id="t1" class="tip">Auto Pay Lump Sums Accept Only One Component.</div>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif url.EZTemplate EQ 0>
	<cfinclude template="/includes/top_header.cfm">
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<cfif len(URL.CID) EQ 0>
	<cfset temp = 0>
<cfelse>
	<cfset temp = cryp.value>
</cfif>
<cfset CSL_Contract_Main_ID = temp>
<cfset CSL_CallingPageCode = "lump_sums">
<cfset URL.Contract_Main_ID = cryp.value>
<cfset form.Contract_Main_ID = cryp.value>

<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
	<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 5; left: 10px; top: 0px">
	  <CFINCLUDE TEMPLATE="contract_status_legend.cfm">
	</div>
<cfelse>
	<cfinclude template="contract_status_legend.cfm">
</cfif>
<cfif url.EZTemplate EQ 0>
	<BLOCKQUOTE><BLOCKQUOTE>
</cfif>
<cfquery name="getAllLumpSums" datasource="#application.datasource#">
	SELECT 	Program_Lump_Sums.*,
				Program_Lump_Sum_Name.Program_Lump_Sum_Name,
				Program_Lump_Sum_Name.External_ID,
				Payment_Type.Payment_Type_Name,
				Payment_Type.Is_Auto_Pay,
				ISNULL(Allowance_Code.Allowance_Code_Number, 0) AS Allowance_Code_Number,
				GL_Account.GL_Account,
				GL_Account.GL_Account_Desc
	FROM 	Program_Lump_Sums
	INNER JOIN Program_Lump_Sum_Name
	ON 	Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
	LEFT JOIN Payment_Type
	ON Payment_Type.Payment_Type_ID = Program_Lump_Sums.Claim_Mechanics
	LEFT JOIN Allowance_Code
	ON 	Allowance_Code.Allowance_Code_ID = Program_Lump_Sum_Name.Allowance_Code_ID
	AND Allowance_Code.Deleted = 0
	LEFT JOIN GL_Account
	ON GL_Account.GL_Account_ID = Program_Lump_Sums.GL_Account_ID
	WHERE 	Program_ID = '#form.Contract_Main_ID#'
	AND Program_Lump_Sums.DELETED = 0
	ORDER BY Program_Lump_Sum_Name.Program_Lump_Sum_Name, Program_Lump_Sums.Lump_Sum_Description
</cfquery>


<cfif GetSettings.Date_Exclusions_ON EQ 1>
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
<cfset getdateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(CSL_Contract_Main_ID,0)>
<cfif getdateExclusionprogramIDs.Recordcount gt 0>
	<cfset donotallowaddproductsDE = 1>
</cfif>
</cfif>
<!--- MAX LUMP SUM AMOUNT --->
<cfif len(trim(GetSettings.Max_Lump_Sum)) GT 0 AND GetSettings.Max_Lump_Sum NEQ 0>
	<cfset Use_Max_Lump_Sum = 1>
	<cfset MaxLumpSum = GetSettings.Max_Lump_Sum>
<cfelse>
	<cfset Use_Max_Lump_Sum = 0>
</cfif>
<!--- MIN LUMP SUM AMOUNT --->
<cfif len(trim(GetSettings.Min_Lump_Sum)) GT 0 AND GetSettings.Min_Lump_Sum NEQ 0>
	<cfset Use_Min_Lump_Sum = 1>
	<cfset MinLumpSum = GetSettings.Min_Lump_Sum>
<cfelse>
	<cfset Use_Min_Lump_Sum = 0>
</cfif>
<cfset HideProductList = 1>
<cfset helpfilenumber=7>

<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
	<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 60px; top: 10px;"> </cfif>
	<cfif url.EZTemplate EQ 0>
		<cfinclude template="minimal_contract_info.cfm">
	</cfif>
	<cfquery name="getProgramInfo" datasource="#application.datasource#">
		SELECT     dbo.Units_of_Measure.Unit_Of_Measure_Desc, dbo.Units_of_Measure.Abbreviation, dbo.Contract_Main.Contract_Quantity
		FROM         dbo.Contract_Main
		INNER JOIN  dbo.Units_of_Measure
		ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID
		WHERE dbo.Contract_Main.Contract_Main_ID = '#form.Contract_Main_ID#'
	</cfquery>

<cfset DiscountType = 3>
<cfset ParentLumpSumsList = "">
<cfset getAllParentLumpSums = queryNew("")>
<cfset ParentLumpSumsList = "">
<!--- If the program is a revision and revision settings has retrictions for this program --->
<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1>
	<cfif Not IsDefined("ProgramManager")>
		<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>
	</cfif>
	<cfset ParentprogramInfo = ProgramManager.getParentProgramInfo(cryp.value)>
	<cfif ParentProgramInfo.Revision_of_Contract_main_id neq "">
		<cfquery name="getAllParentLumpSums" datasource="#application.datasource#">
			SELECT 	Program_Lump_Sums.*, Program_Lump_Sums.Lump_Sum_Description
			FROM 	Program_Lump_Sums
			INNER JOIN Program_Lump_Sum_Name
			ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
			WHERE 	Program_ID = '#ParentProgramInfo.Revision_of_Contract_main_id#'
			AND Program_Lump_Sums.DELETED = 0
		</cfquery>
	</cfif>
</cfif>

<cfset EzButton_Disable = 0>   <!---29808 2/1/2012 removed classic ez button filtering--->
<cfif EzButton_Disable EQ 1>
	<cfset EZProgramManager = CreateObject("component", "components.programs.EZButton_programManager") />
	<cfset GetEZButtonDefaultComp = EZProgramManager.getLumpsumEZComponents(getsettings.EZ_Contract_Id)>
	<cfif GetEZButtonDefaultComp.recordcount GT 0>
		<cfset EZ_Lumpsum_Comp_Ids = ValueList(GetEZButtonDefaultComp.Program_Lump_Sum_Name_ID)>
	</cfif>
</cfif>
<cfif EzButton_Disable EQ 1 or url.EZTemplate EQ 1>
	<cfset Lumpsum_name_ids = valuelist(getAllLumpSums.Program_Lump_Sum_Name_ID)>
</cfif>

<cfset Lump_Desc_Max_Length = 512>
<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/common_files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT>
	var submitted = 0;  // flag to prevent double clicking
	function openPopup(url, winW, winH)
	{
		var windowwidth = 200;
		var windowHeight = 210;
		if(winW){
			windowwidth = winW;
		}
		if(winH){
			windowHeight = winH;
		}
		var w = 640/3;
		var h = 480/3;
		var cw = w/2;
		var ch = h/2;

		if (window.screen){
			w = Math.floor(screen.availwidth/3);
    		h = Math.floor(screen.availHeight/3);
    		cw = Math.floor((screen.availwidth-w)/2);
    		ch = Math.floor((screen.availHeight-h)/2);
		}
    	myPopup = window.open(url,'popupWindow','resizable=yes,width='+windowwidth+',height='+windowHeight+',top='+ch+',left='+cw);
    	if (!myPopup.opener)
        	myPopup.opener = self;
	}
	function addNewLumpSumRow(){
		tr = document.all.oLumpSumtable.insertrow()
		td_AmountCell = tr.insertCell(-1);
		td_AmountCellHTML = "<input type='text'>"
		td_AmountCell.innerHTML = td_AmountCellHTML;
		td_DescriptionCell = tr.insertCell(-1);
		td_DescriptionCellHTML="<TEXTAREA></TEXTAREA>"
		td_DescriptionCell.innerHTML = td_DescriptionCellHTML;
		td_DeleteCell = tr.insertCell(-1)
		td_DeleteCell.innerHTML = "&nbsp;"
		tr = document.all.oLumpSumtable.insertrow()
		td_SelectProductCell = tr.insertCell(-1)
		td_SelectProductCell.colSpan = "3"
		td_SelectProductCell.innerHTML = "select products"
	}
	function editComponent(id, name_id, description, claimmech, amount, volume, sumtoavoid, paidTo){
		var PageLocation = "/common_files/contracts/contract_discount_lump_sums_edit.cfm?LSComponentID=" + id + "&EZTemplate=<cfoutput>#url.EZTemplate#</cfoutput>";
		NewWindow(PageLocation, "lscomponent", 800, 600, "yes", "yes");
	}
	<!--- Restrict lumpsum --->
	<cfoutput>
	function editcomponentpaidto(name_id,paidTo){
		openPopup('ezprogram_editcomponent.cfm?programid=#GetContractInfo.contract_main_id#&discounttypeid=3&PaidTo='+paidTo+'&ProgramType_ID=#CSLGetContractInfo.ProgramType_ID#&compid='+name_id, 300, 200);
	}
	function showProductView(Program_Lump_Sum_ID){
		location = "select_lumpsum_products.cfm?Program_Lump_Sum_ID=" + Program_Lump_Sum_ID + "&CID=#URL.CID#&EZTemplate=#url.EZTemplate#";
	}
	</cfoutput>
	function resetNewLumpSum(){
		$('select').prop('selectedIndex', 0);
		checkSampleRelated(document.getElementById('Program_Lump_Sum_Name_ID'));
		$('#compInfo').hide();
		LumpSumAmountToAvoid = -1;
		//document.all.new_lump_sum_save.value = "save new"
		changeLabel("save new", 1);
		document.all.new_lump_sum_amount.value = "";
		//document.all.new_lump_sum_name.value = "";
		document.all.new_lump_sum_volume.value = ""
		jQuery("textarea[name=new_lump_sum_description]").val('');
		document.all.update.value = 0;
		document.all.component_id.value = 0
		document.all.error_Amt.innerHTML = ""
		document.all.error_Amt.style.width = 0;
		document.all.error_Name.innerHTML = ""
		document.all.error_Name.style.width = 0;
		document.all.error_Quantity.innerHTML = "";
		document.all.error_Quantity.style.width = 0;
		/* Dev Note(71714) */
		resetAmount();
	}
 	LumpSumAmounts = new Array();
	LumpSumAmountToAvoid = -1;
	function saveNewLumpSum()
	{
		if (submitted)
			return false;
		var ErrorCount = 0
		var ExistsComponent = 0;
    	// These two vars were added for D18299 -Anand Rao 05-Mar-09
    	var current  = document.all.Program_Lump_Sum_Name_ID.selectedIndex;
    	var bSample = document.all.Program_Lump_Sum_Name_ID.options[current].id;
		<cfif EzButton_Disable EQ 1 or url.EZTemplate EQ 1>
			<cfloop list="#Lumpsum_name_ids#" index="LumpSumNameId">
				var thisCompId = <cfoutput>#LumpSumNameId#</cfoutput>;
				var selCompId = document.all.Program_Lump_Sum_Name_ID.value;
				if(selCompId == thisCompId && document.all.update.value != 1){
					alert("You cannot add the same component more than once.");
					return false;
				}
			</cfloop>
		</cfif>

	  	if(document.all.bAllowAddComp.value == 0){
		  alert("This program can only have one discount type. Please remove a discount type.");
			// return false; // This will be a HARD STOP and we only need an information
		}
		if(document.all.Program_Lump_Sum_Name_ID.selectedIndex <= 0)	{
			ErrorCount++;
			queueMessage("You must select a <cfoutput>#Application.LumpsumLabel#</cfoutput> name", document.all.error_Name);
		}
		else{
			clearQueue(document.all.error_Name);
		}
		if(document.all.quantitycheck.value == 1 && (document.getElementById('quantityvalue').value ==0 || document.getElementById('quantityvalue').value =='')){
			ErrorCount++;
			queueMessage("You must enter a value in Quantity field", document.all.error_Quantity);
		}
		else{
			clearQueue(document.all.error_Name);
		}
		<cfif getSettings.Generic_Type EQ 'LSAutoPay' OR appSettings.getBBAutoPayLumpSum()>
			// <!------ check for payment cycle ----->
			if(document.all.Vendor_ID ){
				if(document.all.Vendor_ID.value == "0")	{
						queueMessage("Select a Payee", document.all.Err_Sp_Vendor);
						ErrorCount++;
					}
				else{
						clearQueue(document.all.Err_Sp_Vendor);
					}
			}
		</cfif>
		//Amt
		<cfif EzButton_Disable EQ 0>
      // This if is checking for bSample value was added for D18299 -Anand Rao 05-Mar-09
     if (bSample == "0"){
//D37295 Kraft Equipment LS set up
			if(document.all.quantitycheck.value == 0 && (document.all.new_lump_sum_amount.value.length == 0 || document.all.new_lump_sum_amount.value == 0  || isNaN(document.all.new_lump_sum_amount.value))){
				ErrorCount++;
				queueMessage("You must enter a dollar amount greater than 0 for the <cfoutput>#Application.LumpsumLabel#</cfoutput>", document.all.error_Amt);
			}
			else{
				clearQueue(document.all.error_Amt);
			}

    	}
			else{
				clearQueue(document.all.error_Amt);
			}
			<cfif appsettings.getGL_Account_On() IS 1 AND appsettings.getGL_Account_Required_for_Comp() IS 1>
				//if a component doesn't have a GL Account associated with it then the GL Account drop down won't display.
				//So to determine if a user didn't select a GL Account we have to make sure that the drop down exists.
				var bGLAccountOption = 0;
				var oSelectTags = document.getElementsByTagName("SELECT");
				if (oSelectTags != null){
					for (i=0; i<oSelectTags.length; i++){
						if(oSelectTags.item(i).name == "GL_Account_ID"){
							bGLAccountOption = 1;
						}
					}
				}
				if (bGLAccountOption == 1 && ErrorCount == 0 && (document.all.GL_Account_ID.value == 0 || document.all.GL_Account_ID.value == null)){
					alert("You must select a <cfoutput>#Application.GLAccountLabel#</cfoutput> for this component");//D42774
					return false;
				}
			</cfif>

			<!------ [Deepa]: No need to check here for minimum, because the minimum is at program level, so a user can create more tham 1 component and meet the minimum ----->

			<!------ [Deepa]: Could check for maximum even though the maximum is at program level, because if a component crosses max, at pgm level also it crosses max.----->
			<!---Max lump sum amount--->

 // This if is checking for bSample value was added for D18299 -Anand Rao 05-Mar-09
   if (bSample == "0"){
			<cfif Use_Max_Lump_Sum IS 1>
				if(document.all.new_lump_sum_amount.value > <cfoutput>#MaxLumpSum#</cfoutput>){
					ErrorCount++;
					queueMessage("You must enter a dollar amount less than or equal to <cfoutput>#lscurrencyformat(MaxLumpSum)#</cfoutput>", document.all.error_Amt);
				}
				else{
					clearQueue(document.all.error_Amt);
				}
			</cfif>

			<!--- MIN LUMP SUM AMOUNT --->
			<cfif Use_Min_Lump_Sum IS 1>
				if(document.all.new_lump_sum_amount.value < <cfoutput>#MinLumpSum#</cfoutput>){
					ErrorCount++;
					queueMessage("You must enter a dollar greater than or equal to <cfoutput>#lscurrencyformat(MinLumpSum)#</cfoutput>", document.all.error_Amt);
				}
				else{
					clearQueue(document.all.error_Amt);
				}
			</cfif>
    }
		else{
			clearQueue(document.all.error_Amt);
		}
		var Contract_Quantity = <cfoutput>#GetContractInfo.Contract_Quantity#</cfoutput>;
		</cfif>

		<cfif appSettings.getPaymentCycleAtdiscountType()>
			<!------ check for payment cycle ----->
			if(document.all.PaymentCycle.value == "0"){
				queueMessage("Select a payment cycle", document.all.Err_Sp_PaymentCycle1);
				ErrorCount++;
			}
			else{
				clearQueue(document.all.Err_Sp_PaymentCycle1);
			}
		</cfif>

		if(jQuery("textarea[name=new_lump_sum_description]").val().length > <cfoutput>#Lump_Desc_Max_Length#</cfoutput>){
			ErrorCount++;
			queueMessage("Description cannot be longer than <cfoutput>#Lump_Desc_Max_Length#</cfoutput> characters", document.all.error_Desc);
		}
		else{
			clearQueue(document.all.error_Desc);
		}
		var LumpSumAmountTotal = 0;
		if(ErrorCount==0){
			<cfif EzButton_Disable EQ 0>
				for(var n=0; n<LumpSumAmounts.length; n++){
					if(n != LumpSumAmountToAvoid)
					{
						LumpSumAmountTotal = parseFloat(LumpSumAmountTotal) + parseFloat(LumpSumAmounts[n]);
					}
				}
				LumpSumAmountTotal = LumpSumAmountTotal + parseFloat(document.all.new_lump_sum_volume.value);
				BIAmount = <cfoutput>#trim(numberformat(getProgramInfo.Contract_Quantity, '_______________.__'))#</cfoutput> + "";
				if(isNaN(LumpSumAmountTotal)){
					LumpSumAmountTotal = 0;
				}
			</cfif>
			var actionpage = "Contract_Discount_Lump_Sums_Save_New_Lump_Sum.cfm";
			<cfoutput>
			var comp_id = parseInt(document.all.NewLumpSum.component_id.value);
			if ((isNaN(comp_id) || comp_id == 0) && document.all.update.value == 0){
			<cfif GetSettings.Discount_Lump_Sums_Item_Mandated EQ 1>
				actionpage = "select_lumpsum_products.cfm?CID=#URL.CID#&EZTemplate=#url.EZTemplate#";
			</cfif>
			}
			</cfoutput>
			document.all.NewLumpSum.action = actionpage;
			dim_page();
			document.all.NewLumpSum.submit();
		}
		else{
			showMessageWindow();
		}
	}
	function changeLabel(sLabel, whichOne){
		var aObj;
		if(whichOne == 2){
			aObj = document.all.new_lump_sum_reset;
		}
		else{

			aObj = document.all.new_lump_sum_save;

		}
		if(document.getElementsByName('new_lump_sum_save').disabled = false)	{
			aObj.innerHTML = sLabel;
		}
	}

	function resetAmount(){

		if (typeof(document.all.amount_each_period) != "undefined"){
			document.all.amount_each_period.value="";
		}
		if (typeof(document.all.new_lump_sum_amount) != "undefined"){
			document.all.new_lump_sum_amount.value="";
		}
	}
	window['negativeAllowed'] = true;
	function checkSampleRelated(thisObj){
		$('#compInfo').show();
		var current 		= 	thisObj.selectedIndex;
	/*	Start - If there are lumpsum components available in the select box */
		window['negativeAllowed'] = true;
		//alert(negativeAllowed);
		var curobjVal		= thisObj.options[current].value;
		if(current != -1){
		var currentObjID	= 	thisObj.options[current].id;
		if (curobjVal != 0){
			negativeAllowed = eval("document.all.negativeAllowed_"+curobjVal+".value");
			//document.all.allowNegative = negativeAllowed;
			//alert(negativeAllowed);
 			 if (negativeAllowed == "1"){
				window.negativeAllowed = true;
			}
			else{
				window.negativeAllowed = false;
			}
		//	$('.numeric').numeric( { negative: window.negativeAllowed }, function() {} );
			document.all.allowNegative.value = window.negativeAllowed;
		//D37295 Kraft Equipment LS set up/
			relatedToEquipment = eval("document.all.relatedToEquipment_"+curobjVal+".value");
			if(relatedToEquipment == "1"){
				document.getElementById('Quantity').style.display = 'block';
				document.getElementById('amount_each_period').style.display = 'none';
				document.getElementById('amount_each_period_clone').style.display = 'block';
				document.getElementById('quantitycheck').value=1;
				document.getElementById('equipmentPrice').value= eval("document.all.equipmentValue_"+curobjVal+".value");
			}
			else{
				document.getElementById('Quantity').style.display = 'none';
			//	document.getElementById('amount_each_period').style.display = 'block';
			//	document.getElementById('amount_each_period_clone').style.display = 'none';
				document.getElementById('quantitycheck').value=0;
				document.getElementById('equipmentPrice').value=0;
			}
//D37295 Kraft Equipment LS set up
		}
		var trObj1 	= document.all.ls_amount;
		//var trObj2 	= document.all.ls_volume; D30258:js error on lump sum page WE FAILED TO COMMENT THIS JAVASCRIPT AFTER COMMENT form FILED.
		var frmObj1 = document.all.new_lump_sum_amount;
		var frmObj2	= document.all.new_lump_sum_volume;
		//Check for Samples only if template setting is On for products required
 		<cfif GetSettings.Discount_Lump_Sums_Item_Mandated EQ 1>
			// alert(currentObjID);
			if(currentObjID == 1)
			{
				//if (frmObj1.value == ""){frmObj1.value = "0";}
				//if (frmObj2.value == ""){frmObj2.value = "0";}
				frmObj1.value = "0";
				frmObj2.value = "0";
				frmObj1.disabled = true;
				frmObj2.disabled = true;
				trObj1.disabled = true;
				//trObj2.disabled = true; D30258:js error on lump sum page WE FAILED TO COMMENT THIS JAVASCRIPT AFTER COMMENT form FILED.
			}
			else
			{
				frmObj1.disabled = false;
				frmObj2.disabled = false;
				trObj1.disabled = false;
				//trObj2.disabled = false; D30258:js error on lump sum page WE FAILED TO COMMENT THIS JAVASCRIPT AFTER COMMENT form FILED.
			}
 		</cfif>

		} /*	End - If there are lumpsum components available in the select box */
	}	// end: function checkSampleRelated()

		function checkAllowBrokerPayee(thisObj){
			var current 		= 	thisObj.selectedIndex;
			var curobjVal		= 	thisObj.options[current].value;
			Allow_Broker_Payee = eval("document.all.Allow_Broker_Payee_"+curobjVal+".value");
			DefaultPaidToCFPages = eval("document.all.Default_Paid_To_CF_Pages_"+curobjVal+".value");
			$( "#target" ).empty();
			if(Allow_Broker_Payee == "1"){
				var radioBtn = $('<input name="Component_Paid_To" type="Radio" value="3"><cfoutput>#application.returned_customer_setting.broker_label_singular#</cfoutput><br>');
				radioBtn.appendTo('#target');
			}
			$('input[name="Component_Paid_To"][value='+DefaultPaidToCFPages+']').prop('checked', true);
		}
	//TSF: Label 10675 - Modifications to samples
	window.onload=init;
	function init(){
		checkSampleRelated(document.all.Program_Lump_Sum_Name_ID);
	}

	function validateDescription(maxLen, obj){
		// check if the text has exceeded the limit.
		var validLen = textareaChecklength(maxLen, obj);
		if(validLen){
			// check for any exclude list characters.
			var validKey = true;
			var disallowKeyList = "'\"";
			if(event.type.toLowerCase() == "paste"){
				if(window.clipboardData)
				{
					var clipBoardText = window.clipboardData.getdata("Text");
					return Disallow_Key_List_In_String(clipBoardText, disallowKeyList);
				}
			}
			else{
				validKey = Disallow_Key_List(disallowKeyList);
			}
			return validKey;
		}
		else{
			return false;
		}
		return true;
	}
	//D37295 Kraft Equipment LS set up
	function populateAmount(){
		var Amount = document.getElementById('equipmentPrice').value * document.getElementById('quantityvalue').value;
		var newAmount = Amount.toFixed(2);
		document.getElementById('amount_each_period').value= newAmount;
		document.getElementById('amount_each_period_clone').value= newAmount;
		document.getElementById('new_lump_sum_amount').value= newAmount;
	}
	// D37295 Kraft Equipment LS set up
</SCRIPT>
<!--- The Component_ID has been defined --->

<CF_MessageWindow>

<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
<form action="Contract_Discount_Lump_Sums_Save_New_Lump_Sum.cfm" method="post" name="NewLumpSum" ID="NewLumpSum">
<cfoutput>
<div id="ls-body">
<input type="hidden" name="bAllowAddComp" value="#bAllowAddComp#" />
<input type="hidden" name="bvendorOnlyProgram" value="#variables.bvendorOnlyProgram#" />

<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
<LEGEND STYLE="font: bold 14px sans-serif; color: red;"> #Application.LumpsumLabel# </LEGEND>

<cfset arAllowList = ArrayNew(1) />
<cfset bTemplateLevelComponentFilter = 1 />
<!------ Operating Group ----->
<cfset componentsUnderOperatingGroupLevel2 = "" />
<cfif appSettings.getOperatingGroupOn()>
	<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
	<cfset programLevel2Level 				= operatingGroupManager.getProgramLevel2Level() />
	<!------ Get the operating group for this program ----->
	<cfset operatingGroupProgramLevel2 	= operatingGroupManager.getProgramOperatingGroupID(level=programLevel2Level, programId=CSL_Contract_Main_ID) />
	<cfset qGetComponentsUnderOperatingGroupLevel2 = operatingGroupManager.getComponents(operatingGroupProgramLevel2, 3) />
	<cfset componentsUnderOperatingGroupLevel2 = ValueList(qGetComponentsUnderOperatingGroupLevel2.Component_ID) />
	<cfset arAllowList[ArrayLen(arAllowList) + 1] = componentsUnderOperatingGroupLevel2 />
	<cfset bTemplateLevelComponentFilter = 0 />
</cfif>
<!------ Operating Group ----->
<cfif bTemplateLevelComponentFilter>
	<!--- get a list of comps to filter based on template --->
	<cfset qComponents = templateManager.getAllTemplateDiscountComponents(GetSettings.ProgramControl_Panel_Options_ID, 3, 1) />
	<cfset lTemplateAllowList = ValueList(qComponents.Component_ID) />
</cfif>
	<!--- D45016 :: Restrict access at component level for all discount types START--->
	<cfset useLakebaseForgetAllLumpSumComponentsAccess = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lumpsum_component_profile")>
<cfif useLakebaseForgetAllLumpSumComponentsAccess>
	<cftry>
		<cfset getAllLumpSumComponentsAccess = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_lumpsum_component_profile", {
				"deleted" = "eq.0",
				"profiles_id" = "eq.#request.AccessStructure.Profiles_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetAllLumpSumComponentsAccess = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetAllLumpSumComponentsAccess>
<cfquery name="getAllLumpSumComponentsAccess" datasource="#application.datasource#">
			SELECT 	*
			FROM		Program_Lumpsum_Component_Profile
			WHERE		Deleted = 0
			AND 		Profiles_ID = #request.AccessStructure.Profiles_ID#
	</cfquery>
</cfif>
	<cfset restictList = valuelist(getAllLumpSumComponentsAccess.Program_LumpSum_Component_Name_ID)>
	<cfif listlen(restictList)>
		<cfloop list ="#restictList#" index="rl">
			<cfset rposition = listfind(lTemplateAllowList,rl)/>
			<cfif rposition>
				<cfset lTemplateAllowList = listdeleteat(lTemplateAllowList,rposition) />
			</cfif>
		</cfloop>
	</cfif>
	<!--- D45016 :: Restrict access at component level for all discount types END--->
	<cfset arAllowList[ArrayLen(arAllowList) + 1] = lTemplateAllowList />
			<cfset arAllowListLen = ArrayLen(arAllowList) />
			<cfquery name="GetLSNames" datasource="#application.datasource#">
				SELECT 	Program_Lump_Sum_Name,
							Program_Lump_Sum_Name_ID,
							Samples_Related,
							External_ID,
							Allow_Negative,
							Related_to_Equipment,
							Equipment_Value,
							Allowance_Code.Allowance_Code_Number,
							Allowance_Code.Allowance_Code_Desc,
							Allow_Broker_Payee,
							Program_Template_Component.Default_Paid_To_CF_Pages
				FROM 	Program_Lump_Sum_Name
				LEFT JOIN Allowance_Code
				ON		Allowance_Code.Allowance_Code_ID = Program_Lump_Sum_Name.Allowance_Code_ID
				LEFT JOIN Program_Template_Component
				ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Template_Component.Component_ID
				AND Program_Template_Component.Discount_Type_ID = 3
				AND Program_Template_Component.Template_ID = '#CSLGetContractInfo.ProgramType_ID#'
				AND Program_Template_Component.Deleted = 0
				WHERE 	Program_Lump_Sum_Name.Active = 1
				AND 	Program_Lump_Sum_Name.Deleted = 0
				<cfloop from="1" to="#arAllowListLen#" index="i">
				<cfset lAllowList = arAllowList[i] />
				<cfif Len(lAllowList) EQ 0>
				AND 1=2
				<cfelse>
				AND	Program_Lump_Sum_Name_ID IN (#lAllowList#)
				</cfif>
				</cfloop>
				<cfif EzButton_Disable EQ 1>
				<cfif GetEZButtonDefaultComp.recordcount EQ 0>
				AND 1 = 2
				<cfelse>
				and Program_Lump_Sum_Name_ID IN (#EZ_Lumpsum_Comp_Ids#)
				</cfif>
				</cfif>
				<!--- BJF D11631 - only allow one ls component per program regardless of payee --->
				<cfif appSettings.getLumpSumComponentInProgram() EQ 1>
				AND Program_Lump_Sum_Name_ID NOT IN (SELECT Program_Lump_Sum_Name_ID FROM Program_Lump_Sums WHERE Program_ID = '#form.Contract_Main_ID#' AND Deleted = 0)
				</cfif>
				order by Program_Lump_Sum_Name
			</cfquery>
	<table ID="oLumpSumtable" border="0">
	<tr valign="top">
		<td align="right" nowrap>
			<B>Component:</B><SPAN ID="error_Name"></SPAN>&nbsp;
			<cfloop query="GetLSNames">
				<input type="hidden" id="negativeAllowed_#getLSNames.Program_Lump_Sum_Name_ID#" name="negativeAllowed_#getLSNames.Program_Lump_Sum_Name_ID#" value="#getLSNames.Allow_Negative#" />
				<!--- D37295 Kraft Equipment LS set up --->
				<input type="hidden" id="relatedToEquipment#getLSNames.Program_Lump_Sum_Name_ID#" name="relatedToEquipment_#getLSNames.Program_Lump_Sum_Name_ID#" value="#getLSNames.Related_to_Equipment#" />
				<input type="hidden" id="equipmentValue#getLSNames.Program_Lump_Sum_Name_ID#" name="equipmentValue_#getLSNames.Program_Lump_Sum_Name_ID#" value="#getLSNames.Equipment_Value#" />
				<!--- D37295 Kraft Equipment LS set up --->
				<input type="hidden" id="Allow_Broker_Payee_#getLSNames.Program_Lump_Sum_Name_ID#" name="Allow_Broker_Payee_#getLSNames.Program_Lump_Sum_Name_ID#" value="#getLSNames.Allow_Broker_Payee#" />
				<input type="hidden" id="Default_Paid_To_CF_Pages_#getLSNames.Program_Lump_Sum_Name_ID#" name="Default_Paid_To_CF_Pages_#getLSNames.Program_Lump_Sum_Name_ID#" value="#getLSNames.Default_Paid_To_CF_Pages#" />
			</cfloop>
			<input type="hidden" name="allowNegative" id= "allowNegative">
		</td>
		<td>
		<!------ external id ----->
		<!--- Dev Note: KAL; 9896: Lumpsum page to handle for samples --->
		<span <cfif variables.bHideFromLSAutoPay AND GetAllLumpSums.Recordcount GT 0>onmouseout="popUpTip(event,'t1');" onmouseover="popUpTip(event,'t1');"</cfif>>
		<select class name="Program_Lump_Sum_Name_ID" id='Program_Lump_Sum_Name_ID' style="width:240px" onChange="checkSampleRelated(this);resetAmount();checkAllowBrokerPayee(this)" onFocus="checkSampleRelated(this);" <cfif variables.bHideFromLSAutoPay AND GetAllLumpSums.Recordcount GT 0>disabled="true"</cfif>>
			<option value="0">Select #Application.LumpsumLabel# Component</option>
			<cfloop query="GetLSNames">
				<!--- Storing the value of samples related in the ID and passing to Javascript to validate if amount should be disabled or not --->
				<option value="#Program_Lump_Sum_Name_ID#" id="#samples_related#" <cfif GetLSNames.RecordCount EQ 1>selected</cfif>>#Program_Lump_Sum_Name#
					<cfif application.returned_customer_setting.external_id_on EQ 1><cfif Len(External_ID) GT 0> (#External_ID#)</cfif></cfif>
					<cfif len(trim(Allowance_Code_Number))> - (#Allowance_Code_Number#)</cfif>
				</option>
			</cfloop>
		</select>
		</span>
		</td>
	</tr>
	<!--- BJF 13410 Component information in discount pages --->
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;
			<cfdiv bind="url:component_information.cfm?Component_Name_ID={Program_Lump_Sum_Name_ID}&ModifyDeletedPrograms=#ModifyDeletedPrograms#&Discount_Type_ID=3&ProgramType_ID=#CSLGetContractInfo.ProgramType_ID#&ClaimMechanics=#CSLGetContractInfo.ClaimMechanics#&Is_A_Revision=#CSLGetContractInfo.Is_a_Revision#&EligibleRecordCount=#GetPaymentTypesforTemplate.Recordcount#&bHideFromLSAutoPay=#variables.bHideFromLSAutoPay#&formname=NewLumpSum&programId=#form.Contract_Main_ID#" ID="compInfo"/>
		</td>
	</tr>
	<!--- Dev Note: WR 78635 - If "vendor" is a payee on the template, the "paid to" should be distributor. Do not show users any option to search. --->
	<cfif variables.bvendorOnlyProgram eq 0>
		<tr valign="top">
			<td align="right" nowrap style="padding-top:5px;"><B>Paid To:</B>&nbsp;<br></td>
			<td valign="top">
		<cfif variables.bHideFromLSAutoPay>
				<input type="text" name="paidToName" value="" readonly="1" size="30">
				<a onClick="searchVendor();" style="cursor:pointer;">#application.util.string.actionLinkformat("select payee")#</a>
				<SPAN ID="Err_Sp_Vendor"></SPAN>
		<cfelse>
				<cfif EzButton_Disable EQ 1 and getsettings.EZprogram_editcomponent EQ 1>
					&nbsp;&nbsp;&nbsp;
					<a  id="editcomppaidto" style="visibility:hidden;cursor: pointer;">#application.util.string.actionLinkformat("edit")#</a>
				</cfif>
			<!--- "Paid to" radio buttons --->
			<cfdiv bind="url:component_paid_to.cfm?Component_Name_ID={Program_Lump_Sum_Name_ID}&ModifyDeletedPrograms=#ModifyDeletedPrograms#&ContractMainID=#CSLGetContractInfo.contract_main_id#&Discount_Type_ID=3&ProgramType_ID=#CSLGetContractInfo.ProgramType_ID#" bindOnLoad="true" ID="paidToInfo" />
			<!--- Note: "GetPaymentPaidToTypes" is populated based on template, component and discount type on "component_paid_to.cfm".
			On this page, the only reason "GetPaymentPaidToTypes" still exists is because it is being used below on this page to set "rdoBroker" variable.
			--->
			<cfscript>
				GetPaymentPaidToTypes = templateManager.GetPaymentPaidToTypes(CSLGetContractInfo.ProgramType_ID,3,0,0);
			</cfscript>
			<cfset rdoBroker = 0>
			<cfloop query="GetPaymentPaidToTypes">
				<cfif Payment_Paid_To_ID eq 3><cfset rdoBroker = 1></cfif>
			</cfloop>
			<cfif rdoBroker eq 0><div id="target"></div></cfif>
				<input type="hidden" name="paidToName" value="" disabled="1">
		</cfif>
			</td>
		</tr>
	</cfif>


<!--- D37295 Kraft Equipment LS set up --->
	<tr valign="top" id="Quantity" style="display:none;">
		<td align="right" nowrap><B><span id="quantity">Quantity</span>:</B><SPAN ID="error_Quantity"></SPAN>&nbsp;</td>
		<td width=125>
			<input name="quantity" type="text" maxlength="50" value="" style="width:75px" onkeyup="clenseText(this, '0123456789, ');populateAmount();"  id="quantityvalue">
			<input name="quantitycheck" type="hidden" value="0" id="quantitycheck">
			<input name="equipmentPrice" type="hidden" value=" " id="equipmentPrice">
		</td>
	</tr>
<!--- D37295 Kraft Equipment LS set up --->
	<tr valign="top" id="ls_amount">
		<td align="right" nowrap>
			<B><span id="amount_each">Amount<cfif appSettings.BB_Auto_Pay_Lump_Sum eq "1"> Each</cfif></span><!---29963--->:</B><SPAN ID="error_Amt"></SPAN>&nbsp;
		</td>
		<td>
			<cfif appSettings.BB_Auto_Pay_Lump_Sum eq "1">		<!---29963--->
				<table width="400" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td width=125>
							<input type="text" name="amount_each_period" id="amount_each_period" class="numeric" onClick="checkSampleRelated(document.all.Program_Lump_Sum_Name_ID);" onKeyUp="allowonlytwodecimalplaces(this,window.negativeAllowed);"
							<cfif EzButton_Disable EQ 1>disabled</cfif>>
							<input type="text" name="amount_each_period_clone" id="amount_each_period_clone" value="" style="display:none" disabled>
						</td>
						<td width=25 align='left'>
							<span id="help_small_1" onmouseout="popUpTip(event,'tLSAmount');" onmouseover="popUpTip(event,'tLSAmount');">
								<img src="/images/help_small.gif" />
							</span>
							<div id="tLSAmount" class="tip">
								This amount represents how much will be paid "EACH" pay period.
							</div>
						</td>
						<td width=100>
							<div id='tdTotalDesc'>
								<B>Amount Total:</B>
							</div>
						</td>
						<td width=100>
							<div id='tdTotalVal'>
								<div id='div_new_lump_sum_amount'></div>
								<input type='hidden' name='new_lump_sum_amount' id='new_lump_sum_amount' value='0' readonly title='Total payment based on the each amount, payment cycle, and program span.  For non-autopay payment type, the total and each amount is always the same.'  />
							</div>
						</td>
					</tr>
				</table>
			<cfelse>
				<input  class="numeric" type="text" name="new_lump_sum_amount" onClick="checkSampleRelated(document.all.Program_Lump_Sum_Name_ID);" onKeyUp="allowonlytwodecimalplaces(this,window.negativeAllowed);"<cfif EzButton_Disable EQ 1>disabled</cfif>>
			</cfif>
			<input type="hidden" name="new_lump_sum_volume" value="0"/>
		</td>
	</tr>
	<cfset disabled = 0>
	<cfif EzButton_Disable EQ 1>
		<cfset disabled = 1>
	</cfif>
	<cfif appSettings.getPaymentCycleAtdiscountType() AND variables.bHideFromLSAutoPay EQ 0>
	<tr valign="top">
		<td align="right" nowrap>
			<B>Payment Cycle:</B><SPAN ID="Err_Sp_PaymentCycle1"></SPAN>&nbsp;
		</td>
		<td>
			<cfparam name="form.PaymentCycle" default="">
			<table width="400" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td width=125>
						<cf_payment_cycle_selection Template_ID = "#CSLGetContractInfo.ProgramType_ID#" Program_ID = "#form.Contract_Main_ID#" discount_Type_ID = "3" Selected_Payment_Cycle_ID = "#form.PaymentCycle#">
					</td>
					<cfif appSettings.BB_Auto_Pay_Lump_Sum eq "1">		<!---29963--->
					<td width=25>
						<div id="spinner" style="display: none;">
							<image src='/Images/loading_red.gif' />
						</div>
					</td>
					<td width=100>
						<div id='tdCountdesc'>
						<B>Payment Count:</B>
						</div>
					</td>
					<td width=100>
						<div id='tdCountVal'>
						<div id='div_periodCount'></div>
						</div>
					</td>
					</cfif>
				</tr>
			</table>
			<input type='hidden' name='periodCount' id='periodCount' value='' readonly title='Payment count based on the payment cycle and program span.  Non-autopay components always have a payment count of 1.'/>
		</td>
	</tr>
	<cfelse>
	<cfparam name="form.PaymentCycle" default="8"> <!--- 8 = Upon Due	 --->
		<input type="hidden" name="PaymentCycle" value="#form.PaymentCycle#">
	</cfif>
	<tr valign="top">
		<td align="right" nowrap>
			<B>Description:</B><SPAN ID="error_Desc"></SPAN>&nbsp;
		</td>
		<td nowrap>
			<TEXTAREA COLS="50" ROWS="" name="new_lump_sum_description" onPaste="javaScript: return validateDescription(#Lump_Desc_Max_Length#, this);"  onkeyPress="javaScript: return validateDescription(#Lump_Desc_Max_Length#, this);"></TEXTAREA>
		</td>
	</tr>
    </table>
<!--- D33254:Not able to search for program in billback START --->
		<div style="width:370px;padding-top:5px;">
			<div style="float:right;">
				&nbsp;
				<a HREF="##" onClick="<cfif EzButton_Disable EQ 0>resetNewLumpSum();return false;<cfelse>""</cfif>" id="new_lump_sum_reset">
				#application.util.string.actionLinkformat("reset fields")#
				</a>
			&nbsp;
			<a href="##" onclick="load_program_page();">#application.util.string.actionLinkFormat("program summary")#</a>
			</div>
		<div style="display:none;float:right;padding-right:20px;" id="component_information">
			<cfif appSettings.getdisableAddingComponentsOnRevision() AND bIsContractARevision>
				<a title="adding new components are not allowed on revisions">
					#application.util.string.actionLinkformat("save #lcase(Application.LumpsumLabel)# component")#
				</a>
			<cfelse>
				<span id="new_lump_sum_save" <cfif NOT(Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Lump_Sum_Created eq 2)>style="visibility:visible";<cfelse>style="visibility:hidden";</cfif>>
				<a HREF="##" <cfif variables.bHideFromLSAutoPay AND GetAllLumpSums.Recordcount GT 0>onmouseout="popUpTip(event,'t1')" onmouseover="popUpTip(event,'t1')"<cfelse>onClick="saveNewLumpSum();"</cfif>>
					#application.util.string.actionLinkformat("save #Application.LumpsumLabel# component")#
				</a>
			</cfif>
			</div>
		</div>
<!--- D33254:Not able to search for program in billback END --->
</cfoutput>
</FIELDSET>

<!--- This value gets set in the file Claim_Mech_Info but needs to be on this page to prevent javascript errors
in case they save before selecting a component. --->
<input type="hidden" name="AllowSave" value="">
<input type="hidden" name="Auto_Pay_Status" value="">
<input type="hidden" name="Vendor_Selection" value="true">
<input type="hidden" name="Program_ID" value="<cfoutput>#URL.CID#</cfoutput>">
<input type="hidden" name="component_id" value="0">
<input type="hidden" name="update" value="0">
<input type="hidden" name="payment_locked" value="0">
<input type="hidden" name="FieldName" value="Vendor_ID">
<cfif variables.bHideFromLSAutoPay>
	<input type="hidden" name="Vendor_ID" value="0">
</cfif>
<input type="hidden" name="deletedateexclusions" value="0">
<input type="hidden" name="ParentProgramID" value="<cfoutput>#ParentProgramInfo.Revision_of_Contract_main_id#</cfoutput>">
<input type="hidden" name="EZTemplate" 	value="<cfoutput>#url.EZTemplate#</cfoutput>">
</form>

<cfif GetAllLumpSums.Recordcount GT 0>

<style>
	table.Maintable td	{ font-size : 10px;}
	#header {font-size: 12px;}
</style>

<cfset businessSegmentID = businessSegManager.getSegmentIdByProgram(form.Contract_Main_ID) />
<cfset bAllowSelectAllProducts = ProductGroupManager.allowSelectAllProducts(3, form.Contract_Main_ID) />
<cfoutput query="getAllLumpSums">
	<!--- D45016 :: Restrict access at component level for all discount types START--->
	<cfset useLakebaseForcompvisibility = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getalllumpsumcomponentsaccess")>
<cfif useLakebaseForcompvisibility>
	<cftry>
		<cfset compvisibility = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getalllumpsumcomponentsaccess", {
				"program_lumpsum_component_name_id" = "eq.#getAllLumpSums.Program_Lump_Sum_Name_ID#",
				"allow_user_to_view" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcompvisibility = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcompvisibility>
<cfquery name="compvisibility" dbtype="query">
		SELECT *
		FROM getAllLumpSumComponentsAccess
		WHERE Program_LumpSum_Component_Name_ID = #getAllLumpSums.Program_Lump_Sum_Name_ID#
		AND Allow_User_To_View = 1
	</cfquery>
</cfif>
	<cfif compvisibility.recordcount>
		<cfset display="none">
	<cfelse>
		<cfset display="">
	</cfif>
	<!--- D45016 :: Restrict access at component level for all discount types END--->
	<cfset thisBAllowSelectAllProducts = bAllowSelectAllProducts />
	<cfset getLumpSumProducts = LumpSumDataManager.getProgramLumpSumProducts(getAllLumpSums.Program_Lump_Sum_ID, form.Contract_Main_ID) />
	<cfset form.Product_List = valuelist(getLumpSumProducts.BSA_Foodservice_Items_Master_ID, ",") />
  	<cfset thisformname = "LumpSumform_"&replace(getAllLumpSums.Program_Lump_Sum_ID, "-", "_", "ALL")>
	<cfset lump_id = getAllLumpSums.Program_Lump_Sum_ID>
	<cfset lump_desc = replace(replace(replace(getAllLumpSums.Lump_Sum_Description, "'", "", "ALL"), '"', '', "ALL"), chr(13)&chr(10), " ", "ALL")>
	<cfset lump_name = replace(replace(getAllLumpSums.Lump_Sum_Name, "'", "", "ALL"), '"', '', "ALL")>
	<cfset lump_vol = trim(numberformat(getAllLumpSums.Lump_Sum_Volume, '___________________'))>
	<cfset lump_amt =  Lump_Sum_Amount />
	<cfset lump_CurrentProgID = getAllLumpSums.Current_Program_ID>

	<cfif (variables.bHideFromLSAutoPay OR appSettings.getBBAutoPayLumpSum()) and len(getAllLumpSums.Vendor_Master_Id) EQ 36>
		<cfset useLakebaseForGetPayeeName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vendor_master")>
		<cfif useLakebaseForGetPayeeName>
			<cftry>
				<cfset getPayeeName = application.oLakebase.toQuery(
					application.oLakebase.selectRows("vendor_master", { "vendor_master_id" = "eq.#getAllLumpSums.Vendor_Master_Id#", "select" = "vendor_name" }),
					"Vendor_Name"
				)>
				<cfcatch type="any">
					<cfset useLakebaseForGetPayeeName = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForGetPayeeName>
			<cfquery name="getPayeeName" datasource="#application.datasource#">
				SELECT Vendor_Name
				FROM 	Vendor_Master
				WHERE	Vendor_Master_Id = '#getAllLumpSums.Vendor_Master_Id#'
			</cfquery>
		</cfif>
		<cfif getPayeeName.RecordCount EQ 0><!--- If vendor not found, it could be a distributor --->
			<cfquery name="getPayeeName" datasource="#application.datasource#">
				SELECT 	Name as Vendor_Name
				FROM 	BSA_Foodservice_Customers
				WHERE	BSA_Foodservice_Customers_Id = '#getAllLumpSums.Vendor_Master_Id#'
			</cfquery>
		</cfif>
		<cfset variables.VendorName = getPayeeName.Vendor_Name />
	<cfelse>
		<cfset variables.VendorName = "" />
	</cfif>
<!--- Dev Note: KAL; kal's redesign --->

	<!---handle for payment cycle if it's turned on--->
	<cfif appSettings.getPaymentCycleAtdiscountType()>
		<cfset lumpSumExtId = getAllLumpSums.Program_Lumps_Sum_Ext_ID>
		<cfset strippedLumpSumId = request.app_general_functions.replaceHyphen(lump_id) />
		<cfset "form.PaymentCycle_#strippedLumpSumId#" = PaymentCycleManager.getPaymentCycle(form.Contract_Main_ID, 3, lumpSumExtId) />
		<cfset "form.PaymentCycleIsLocked_#strippedLumpSumId#" = PaymentCycleManager.isPaymentCycleLocked(form.Contract_Main_ID, 3, lumpSumExtId) />
		<cfset ClaimMechanic = Claim_Mechanics />
		<input type="hidden" name="PaymentCycle_#strippedLumpSumId#" value="#Evaluate("form.PaymentCycle_#strippedLumpSumId#")#" />
		<input type="hidden" name="PaymentCycleIsLocked_#strippedLumpSumId#" value="#Evaluate("form.PaymentCycleIsLocked_#strippedLumpSumId#")#" />
	</cfif>
	<cfset comp_paid_to = getAllLumpSums.Component_Paid_To>
	<cfset Hide = 0>
	<cfset enabled = 1>
	<cfset HideDelete = 0>
	<cfset enabledDelete = 1>
	<cfset HideProducts = 0>
	<cfset enabledProducts = 1>

	<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Lump_Sum_Changed eq 2 AND NOT(lump_CurrentProgID eq Program_ID)>
		<cfset Hide = 1>
		<cfset enabled = 0>
	</cfif>
	<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2 AND RevisionSettings.Products_Removed eq 2 AND NOT(lump_CurrentProgID eq Program_ID)>
		<cfset HideProducts = 1>
		<cfset enabledProducts = 0>
	</cfif>
	<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Lump_Sum_Removed eq 2 AND NOT(lump_CurrentProgID eq Program_ID)>
		<cfset HideDelete = 1>
		<cfset enabledDelete = 0>
	</cfif>
	<cfif getAllLumpSums.Is_Auto_Pay IS 1>
		<cfquery name="HasInterfaced" datasource="#application.datasource#">
			SELECT BB_Payment_request_sent, *
			FROM Billback
			INNER JOIN Billback_Program
			ON Billback_Program.Billback_ID = Billback.Billback_ID
			AND Billback_Program.Deleted = 0
			AND Billback_Program.Program_ID IN (SELECT Contract_Main_ID FROM Contract_Main WHERE Contract_Number = (SELECT Contract_Number FROM Contract_Main WHERE Contract_Main_ID = '#Program_ID#'))
			INNER JOIN BB_Lump_Sums
			ON Billback.Billback_ID = BB_Lump_Sums.Billback_ID
			AND Billback_Program.Billback_Program_ID = BB_Lump_Sums.Billback_Program_ID
			AND LS_Billback_Amount = '#getAllLumpSums.Lump_Sum_Amount#'
			WHERE Billback.Deleted = 0
			AND Billback.Auto_Billback = 1
			AND Billback.BB_Payment_request_sent = 1
		</cfquery>
		<cfif HasInterfaced.Recordcount GT 0>
			<cfset enabled = 0>
			<cfset enabledProducts = 0>
			<cfset HideDelete = 1>
			<cfset enabledDelete = 0>
		</cfif>
	</cfif>
	<cfset ShowThisLink = "ShowThisLink" & Replace(Program_Lump_sum_Id,'-','','ALL')>
	<cfset LabelComp 			= Createobject("component", "components.settings.labels.labels").init() />
	<table width="800" style="Maintable" cellpadding="0" cellspacing="0" border="0">
	<tr>
		<td colspan="3" style="font-weight:bold;padding-top:5px;padding-bottom:5px;">
			Add products to the #Application.LumpsumLabel# (optional)
		</td>
	</tr>
	<tr>
		<td style="font-weight:bold;font-size:14px;width:40%">
			#Program_Lump_Sum_Name#
		</td>
		<td style="font-weight:bold;font-size:14px;width:40%" valign="top">
			#lscurrencyformat(lump_amt)#&nbsp;&nbsp;
			<cfif getAllLumpSums.Is_Auto_Pay EQ 1 >
				(#lscurrencyformat(getAllLumpSums.Amount_Each_Payment)#&nbsp;x&nbsp;#getAllLumpSums.Payment_Count# payments)
			</cfif>
		</td>
		<td style="font-weight:bold;width:20%" valign="top" rowspan="100%">
			<A STYLE="cursor: pointer;" ONCLICK="deleteComponent('#getAllLumpSums.Program_Lump_Sum_ID#', '#JSStringformat(Program_Lump_Sum_Name)#')">
				<img src="../../Images/scissor.gif" title="remove this component" border="0">
			</A><br>
			<cfif NOT variables.bHideFromLSAutoPay>
				<cfif HideProducts EQ 0>
					<cfif enabledProducts>
						<a STYLE="cursor:pointer;" ONCLICK="javaScript: showProductView('#Program_Lump_Sum_ID#');return false;">
							#application.util.string.actionLinkformat("product/group")#
						</a>
					<cfelse>
						#application.util.string.actionLinkformat("product/group")#
					</cfif>
				</cfif>
			</cfif><br>
			<cfif url.EZTemplate EQ 0>
				<cfset ShowThisDistributorLink = "ShowThisDistributorLink" & Replace(Program_Lump_sum_Id,'-','','ALL')>
				<cfif appSettings.getLumpSumDistributors() eq 1>
					<cfif NOT variables.bHideFromLSAutoPay>
						<cfif hide EQ 0>
							<cfif enabled>
								<a href="select_lumpsum_distributors.cfm?CID=#URL.CID#&Program_Lump_Sum_ID=#Program_Lump_Sum_ID#">
									#application.util.string.actionLinkformat("#application.returned_customer_setting.distributor_label_plural#")#
								</a>
							<cfelse>
								#application.util.string.actionLinkformat("#application.returned_customer_setting.distributor_label_plural#")#
							</cfif>
						</cfif>
					</cfif><BR>
				</cfif>
			</cfif>
			<cfset EditLink = "EditLink" & Replace(Program_Lump_sum_Id,'-','','ALL')>
			<cfif Hide EQ 0>
				<cfif enabled>
					<a STYLE="cursor:pointer;" onclick="javaScript: editComponent('#lump_id#','#JSStringformat(Program_Lump_Sum_Name_ID)#','#lump_desc#','#Claim_Mechanics#','#lump_amt#','#lump_vol#',#evaluate("getAllLumpSums.currentrow-1")#,#comp_paid_to#);return false;">
						#application.util.string.actionLinkformat("edit component")#
					</a>
				<cfelse>
					#application.util.string.actionLinkformat("edit component")#
				</cfif>
			</cfif>
		</td>
	</tr>
	<cfif len(lump_desc)>
	<tr>
		<td colspan="2" style="padding-top:5px;"><em>#lump_desc#</em></td>
	</tr>
	</cfif>
	<!--- Dev Note: WR 78635 - If "vendor" is a payee on the template, then hide "paid to".
	"Paid to" is actually vendor, but in the database, we save it as distributor. --->
	<cfif variables.bvendorOnlyProgram eq 0>
		<cfset colheaders ="Paid to">
		<cfset headersvalue =#templateManager.getPaymentPaidToTypeDesc(paidToID = comp_paid_to, paidToDesc="")#>
	<cfelse>
		<cfset colheaders ="">
		<cfset headersvalue ="">
	</cfif>

	<cfset colheaders =ListAppend(colheaders,'Payment Cycle')>
	<cfset headersvalue =ListAppend(headersvalue,'#PaymentCycleManager.getPaymentCycleDescription(Evaluate("form.PaymentCycle_#strippedLumpSumId#"))# ')>
	<!--- GL ACCOUNT --->
	<cfif appSettings.getGL_Account_On()>
		<cfset colheaders=ListAppend(colheaders,#Application.GLAccountLabel#)>
		<cfset headersvalue =ListAppend(headersvalue,'#GL_Account_Desc# (#GL_Account#)')>
	</cfif>
	<!--- EXTERNAL ID --->
	<cfif application.returned_customer_setting.external_id_on AND Len(External_ID)>
		<cfset ID = LabelComp.getGeneralLabels('Lump Sum External ID')>
		<cfset colheaders=ListAppend(colheaders,#ID.General_Labels_Label#)>
		<cfset headersvalue =ListAppend(headersvalue,#External_ID#)>
	</cfif>
	<!--- Payee --->
	<cfif len(variables.VendorName)>
		<cfset colheaders=ListAppend(colheaders,'Payee')>
		<cfset headersvalue =ListAppend(headersvalue,#variables.VendorName#)>
	</cfif>
	<!--- PAYMENT TYPE --->
	<cfif appSettings.getClaims_at_Comp_Level()>
		<cfset colheaders=ListAppend(colheaders,'Payment Type')>

		<cfset headersvalue =ListAppend(headersvalue,#Payment_Type_Name#)>
	</cfif>
	<cfloop from="1" to="#listlen(colheaders)#" index="headers">
		<cfif headers MOD 2 EQ 1>
			<tr>
		</cfif>
			<td>
				<li>#listgetat(colheaders,headers,',',true)# : #listgetat(headersvalue,headers,',',true)#</li>
			</td>
		<cfif headers MOD 2 EQ 0>
			</tr>
		</cfif>
	</cfloop>

	<form action="Contract_Discount_Lump_Sums_Save_Products.cfm" method="post" name="#thisformname#" ID="#thisformname#" ONSUBMIT="alert();" style="display:inline;">
		<input type="hidden" name="Sort_By" 							value="#URL.Sort_By#">
		<input type="hidden" name="Program_ID" 					value="#URL.CID#">
		<input type="hidden" name="Program_Lump_Sum_ID" 	value="#getAllLumpSums.Program_Lump_Sum_ID#" ID="LumpSum_ID">
		<input type="hidden" name="ExistingProductList" 			value="#form.Product_List#">
		<input type="hidden" name="Product_List" 					value="">
		<input type="hidden" name="DTPS_On" 							value="1">
		<input type="hidden" name="DTPS_Program_ID" 			value="#form.Contract_Main_ID#">
		<input type="hidden" name="EZTemplate" 						value="#url.EZTemplate#">
	</form>
<!------ Display details if application settings says so ----->
<cfif appSettings.getPgmLumpsumDetailedDisplay()>
	<!------ Display distributor details ----->
	<cfif GetSettings.Discount_Lump_Sums_Distributor_Mandated EQ 1>
		<tr>
			<td colspan="100%" align="right">
				<!------ Get distributors ----->
				<cfset getdistributors  = LumpSumManager.getLumpSumDistributors(Program_ID, Program_Lump_Sum_ID, 1)>
				<table cellspacing="2" cellpadding="2" width="100%" align="center">
				<tr>
					<td style="border-bottom:1px solid orange;" colspan="100%" id="header" align="left"><B>#application.returned_customer_setting.distributor_label_plural#</B></td>
				</tr>
				<tr>
				<cfif getdistributors.RECORDCOUNT GT 0>
					<cfloop query="getdistributors">
						<!---handle what gets passed to the distributor profile popup based on groups--->
						<td style="border:none;" class="dataStyle" width="33%" valign="top">
						<span>
						<font SIZE="1">
						#ucase(trim(getdistributors.Name))# <cfif Len(Shr_Ship_To)>(#Shr_Ship_To#)</cfif>
						</font>
						</span>
						</td>
						<cfif getdistributors.CURRENtrOW MOD 3><cfelse></tr><tr></cfif>
					</cfloop>
				<cfelse>
					<td align="center"><B><font color="Red">NONE SUPPLIED</font></B></td>
				</cfif>
				</table>
			</td>
		</tr>
	</cfif>
</table>
	<!------ Display product details ----->
	<cfset datatableID = getAllLumpSums.currentrow>
	<cfif NOT variables.bHideFromLSAutoPay>
		<cfset displayLumpSumInfo = 0 />
		<cfset URL.LUMP_ID = Program_Lump_Sum_ID />
		<div style="display:#display#;width:800px;padding-top:5px">
			<cfinclude template="lumpsum_products.cfm">
		</div>
	</cfif> <!--- NOT variables.bHideFromLSAutoPay --->
</cfif><br><br>
</cfoutput>

</div>    <!--- id="ls-body">	 --->
<cfoutput>
<form action="Contract_Discount_Lump_Sums_Delete.cfm" method="post" name="comDeleteform" ID="comDeleteform">
	<input type="hidden" name="Component_ID" value="">
	<input type="hidden" name="Program_ID" value="#URL.CID#">
	<input type="hidden" name="deletedateexclusions" value="#form.deletedateexclusions#">
	<input type="hidden" name="EZTemplate" 	value="#url.EZTemplate#">
</form>
</cfoutput>
</cfif>
</BLOCKQUOTE></BLOCKQUOTE>
<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0></div></cfif>
<script type="text/javascript" src="/Common_Files/contracts/contract_Discount_Lump_Sums.js"></script>
<script>
function deleteComponent(component_id, name){
	if (submitted)
		return false;
	if(confirm("Do you really want to delete " + name + "?")){
		document.all.comDeleteform.Component_ID.value = component_id;
	<cfif donotallowaddproductsDE EQ 1>
		if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))	{
		comDeleteform.deletedateexclusions.value = 1;
	</cfif>
	dim_page();
	document.all.comDeleteform.submit();
	<cfif donotallowaddproductsDE EQ 1> } </cfif>
	}
}
searchVendor =  function(){
	NewWindow('/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?RebateRecipient_On=1&formname=NewLumpSum&Reloadform=0&Fieldname=Vendor_ID&PageSource=ComponentInformation', 'VendorSearch', '800', '600', 'yes', 'yes')
}

<cfoutput>
	var Contract_Start_Date = '#GetContractInfo.Contract_Start_Date#';
	var Contract_End_Date = '#GetContractInfo.Contract_End_Date#';
	//setAmount is in contract_Discount_Lump_Sums.js
	jQuery('##amount_each_period').keyup(calc);
	jQuery('##PaymentCycle').change( calc );
	jQuery('##Claim_Mechanics').change( calc );
</cfoutput>
function calc() {
	//calcPeriods is in contract_Discount_Lump_Sums.js
	calcPeriods(Contract_Start_Date,Contract_End_Date);
}
</script>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<script>
	function load_program_page() {
		dim_page();
		window.location = <cfoutput>"/common_files/contracts/contract_edit_menu.cfm?CID=#URL.CID#" ;</cfoutput>
	}
	function dim_page() {
		submitted = 1;
		/* dim the main page body */
		jQuery("#ls-body").css("opacity", "0.45");
		/* disable anchor tags to prevent double clicking */
		jQuery("a")
			.prop("onclick", null)
			.off("click")
			.hover(function(){ $(this).css("cursor", "none"); });
	}
</script>
</BODY>
</HTML>