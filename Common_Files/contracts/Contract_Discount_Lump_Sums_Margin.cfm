<CFPARAM NAME="URL.CID" DEFAULT="">
<CFPARAM NAME="marginedit_saved" DEFAULT="0" />
<cfparam name="url.EZTemplate" default="0">

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
<cfparam name="donotallowaddproductsDE" default = "0">
<cfparam name="form.deletedateexclusions" default = "0">

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
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />

<CFSET PAGE_TITLE= "Product #Application.LumpsumLabel# Component Creation">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" ONLOAD="">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFINCLUDE TEMPLATE="/includes/header.cfm"> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "lump_sums">
<!---
<CFSET Help_URL="/help_files/manual/createprogram/page11.cfm">
--->
<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>
<cfif application.programlayout EQ 1>
<!--- <div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
  <CFINCLUDE TEMPLATE="contract_status_legend_margin.cfm"></div>
<cfelse>
<CFINCLUDE TEMPLATE="contract_status_legend_margin.cfm"> --->
</cfif>
<CFINCLUDE TEMPLATE="commonqueries.cfm">
<cfset programManager = CreateObject("component", "components.programs.ProgramManager") />
<cfset programagreed = programManager.isProgramAgreed(GetContractInfo.Contract_Main_ID)>

<cfif programagreed GT 0 and GetContractInfo.modifying_program EQ 0 and GetContractInfo.Contract_Status_Type_IDX EQ 2>
<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo() />
</cfif>

<BLOCKQUOTE><BLOCKQUOTE>
<cfif GetSettings.Date_Exclusions_ON EQ 1>
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(CSL_Contract_Main_ID,0)>
<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
	<cfset donotallowaddproductsDE = 1>
</CFIF>
</cfif>

<!---There are max or min values for lump sum--->
<cfif len(trim(GetSettings.Min_Lump_Sum)) GT 0 AND GetSettings.Min_Lump_Sum NEQ 0>
	<cfset Use_Min_Lump_Sum = 1>
	<cfset MinLumpSum = GetSettings.Min_Lump_Sum>
<cfelse>
	<cfset Use_Min_Lump_Sum = 0>
</cfif>

<cfif len(trim(GetSettings.Max_Lump_Sum)) GT 0 AND GetSettings.Max_Lump_Sum NEQ 0>
	<cfset Use_Max_Lump_Sum = 1>
	<cfset MaxLumpSum = GetSettings.Max_Lump_Sum>
<cfelse>
	<cfset Use_Max_Lump_Sum = 0>
</cfif>


<cfparam name="form.update" default="0">

<CFSET HideProductList = 1>

<CFSET helpfilenumber=7>
<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:absolute; height:430px; width:200px; z-index:1; left: 10px; top: 10px;">
<!--- <div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 60px; top: 10px;">  ---></cfif>
<cfinclude template="minimal_contract_info.cfm">

<CFQUERY NAME="getProgramInfo" datasource="#application.datasource#">
SELECT     dbo.Units_of_Measure.Unit_Of_Measure_Desc, dbo.Units_of_Measure.Abbreviation, dbo.Contract_Main.Contract_Quantity
FROM         dbo.Contract_Main INNER JOIN
                      dbo.Units_of_Measure ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID
	WHERE dbo.Contract_Main.Contract_Main_ID = '#FORM.Contract_Main_ID#'
</CFQUERY>
<CFSET Lump_Desc_Max_Length = 765>
<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/common_files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT>

	function addNewLumpSumRow(){

		tr = document.all.oLumpSumTable.insertRow()

		td_AmountCell = tr.insertCell(-1);
		td_AmountCellHTML = "<INPUT TYPE='text'>"
		td_AmountCell.innerHTML = td_AmountCellHTML;

		td_DescriptionCell = tr.insertCell(-1);
		td_DescriptionCellHTML="<TEXTAREA></TEXTAREA>"
		td_DescriptionCell.innerHTML = td_DescriptionCellHTML;

		td_DeleteCell = tr.insertCell(-1)
		td_DeleteCell.innerHTML = "&nbsp;"

		tr = document.all.oLumpSumTable.insertRow()

		td_SelectProductCell = tr.insertCell(-1)
		td_SelectProductCell.colSpan = "3"
		td_SelectProductCell.innerHTML = "select products"
	}

	function editComponent(id, name_id, description, amount, volume, sumtoavoid, paidTo) {

		if(parseInt(document.all.update.value) == 1) {
			if(confirm("You are currently editing a component. Press OK to save the component OR press CANCEL to edit a new component.")){
				document.all.NewLumpSum.submit()
			}
		}

		LumpSumAmountToAvoid = sumtoavoid;
		var valPaidTo = paidTo;
		//document.all.new_lump_sum_save.value = "save changes"
		changeLabel("save changes", 1);
		document.all.new_lump_sum_amount.value = amount;
		var opt = Get_Object_Property_Match_Collection(document.all.Program_Lump_Sum_Name_ID.options, "value", name_id);
		if (opt)
		{
			opt.selected = true;
		}
		//document.all.Program_Lump_Sum_Name_ID.value = name;
		document.all.new_lump_sum_volume.value = volume
		//document.all.new_lump_sum_description.value = description; CHROMEFIX
		jQuery("textarea[name=new_lump_sum_description]").val(description);
		document.all.update.value = 1;
		document.all.component_id.value = id
		for (i=0; i<document.all.Component_Paid_To.length; i++)
		{
			if (document.all.Component_Paid_To[i].value == valPaidTo)
			{document.all.Component_Paid_To[i].checked = true;}
			else
			{document.all.Component_Paid_To[i].checked = false;}
		}
		document.all.error_Amt.innerHTML = ""
		document.all.error_Amt.style.width = 0;
		document.all.error_Name.innerHTML = ""
		document.all.error_Name.style.width = 0;

	}
	<cfoutput>
	function showProductView(Program_Lump_Sum_ID)
	{
		location = "select_lumpsum_products.cfm?Program_Lump_Sum_ID=" + Program_Lump_Sum_ID + "&CID=#URL.CID#"
	}
	</cfoutput>
	function resetNewLumpSum(){
		LumpSumAmountToAvoid = -1;
		//document.all.new_lump_sum_save.value = "save new"
		changeLabel("save new", 1);
		document.all.new_lump_sum_amount.value = "";
		//document.all.new_lump_sum_name.value = "";
		document.all.new_lump_sum_volume.value = ""
		//document.all.new_lump_sum_description.value = ""; CHROMEFIX
		jQuery("textarea[name=new_lump_sum_description]").val("");
		document.all.update.value = 0;
		document.all.component_id.value = 0

		document.all.error_Amt.innerHTML = ""
		document.all.error_Amt.style.width = 0;
		document.all.error_Name.innerHTML = ""
		document.all.error_Name.style.width = 0;


	}


 	LumpSumAmounts = new Array();
	LumpSumAmountToAvoid = -1;

	function saveNewLumpSum(){
		ErrorCount = 0

		if(document.all.Program_Lump_Sum_Name_ID.selectedIndex < 0){
			ErrorCount++;
			queueMessage("You must select a <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> name", document.all.error_Name);
		}
		else {
			clearQueue(document.all.error_Name);
		}
		//Amt
		if(document.all.new_lump_sum_amount.value.length == 0){
			ErrorCount++;
			queueMessage("You must enter a dollar amount for the <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>", document.all.error_Amt);
		}
		else {
			clearQueue(document.all.error_Amt);
		}

		<!------ [Deepa]: No need to check here for minimum, because the minimum is at program level, so a user can create more tham 1 component and meet the minimum ----->
		<!---Min Lump sum amount--->
		<!------
		/*
		<cfif Use_Min_Lump_Sum IS 1>
		if(document.all.new_lump_sum_amount.value <= <cfoutput>#MinLumpSum#</cfoutput>){
			ErrorCount++;
			queueMessage("You must enter a dollar amount greater than <CFOUTPUT>#lscurrencyformat(MinLumpSum)#</CFOUTPUT>", document.all.error_Amt);
		}
		else {
			clearQueue(document.all.error_Amt);
		}
		</cfif>
		*/
		 ----->
		<!------ [Deepa]: Could check for maximum even though the maximum is at program level, because if a component crosses max, at pgm level also it crosses max.----->
		<!---Max lump sum amount--->
		<cfif Use_Max_Lump_Sum IS 1>
		if(document.all.new_lump_sum_amount.value > <cfoutput>#MaxLumpSum#</cfoutput>){
			ErrorCount++;
			queueMessage("You must enter a dollar amount less than or equal to <CFOUTPUT>#lscurrencyformat(MaxLumpSum)#</CFOUTPUT>", document.all.error_Amt);
		}
		else {
			clearQueue(document.all.error_Amt);
		}
		</cfif>

		var Contract_Quantity = <cfoutput>#GetContractInfo.Contract_Quantity#</cfoutput>;
		//Volume
		var lumpVolume = parseFloat(document.all.new_lump_sum_volume.value);
		if(!isNaN(lumpVolume))
		{
			if(lumpVolume > Contract_Quantity)
			{
				ErrorCount++;
				queueMessage("You must enter a volume less than or equal to the program volume (" + Contract_Quantity + ")", document.all.error_Volume);
			}
			else
			{
				clearQueue(document.all.error_Volume);
			}
		}
		else
		{
			clearQueue(document.all.error_Volume);
		}

		<cfif appSettings.getPaymentCycleAtDiscountType()>
		<!------ check for payment cycle ----->
		if(document.all.PaymentCycle.value == "0")
		{
			queueMessage("Select a payment cycle", document.all.Err_Sp_PaymentCycle1)
			ErrorCount++
		}
		else
		{
			clearQueue(document.all.Err_Sp_PaymentCycle1)
		}
		</cfif>

		//if(document.all.new_lump_sum_description.value.length > <CFOUTPUT>#Lump_Desc_Max_Length#</CFOUTPUT>)	{ CHROMEFIX
		var lsString = jQuery("textarea[name=new_lump_sum_description]").val();
		if(lsString.length > <CFOUTPUT>#Lump_Desc_Max_Length#</CFOUTPUT>)	{
			ErrorCount++;
			queueMessage("Description cannot be longer than <CFOUTPUT>#Lump_Desc_Max_Length#</CFOUTPUT> characters", document.all.error_Desc);
		}
		else
		{
			clearQueue(document.all.error_Desc);
		}

		var LumpSumAmountTotal = 0


		if(ErrorCount==0){

			for(var n=0; n<LumpSumAmounts.length; n++){
				if(n != LumpSumAmountToAvoid){
					LumpSumAmountTotal = parseFloat(LumpSumAmountTotal) + parseFloat(LumpSumAmounts[n]);
				}
			}
			LumpSumAmountTotal = LumpSumAmountTotal + parseFloat(document.all.new_lump_sum_volume.value);
			BIAmount = <CFOUTPUT>#trim(numberformat(getProgramInfo.Contract_Quantity, '_______________.__'))#</CFOUTPUT> + "";
			if(isNaN(LumpSumAmountTotal))
			{
				LumpSumAmountTotal = 0;
			}
			var actionpage = "Contract_Discount_Lump_Sums_Save_New_Lump_Sum.cfm";
			<cfoutput>
			var comp_id = parseInt(document.all.NewLumpSum.component_id.value);
			if ((isNaN(comp_id) || comp_id == 0) && document.all.update.value == 0)
			{
			<cfif GetSettings.Discount_Lump_Sums_Item_Mandated EQ 1>
				actionpage = "select_lumpsum_products.cfm?CID=#URL.CID#";
			<!------ <cfelseif GetSettings.Discount_Lump_Sums_Distributor_Mandated EQ 1>
				actionpage = "select_lumpsum_distributors.cfm?CID=#URL.CID#";  ----->
			</cfif>
			}
			</cfoutput>

			document.all.NewLumpSum.action = actionpage;

			if(LumpSumAmountTotal != BIAmount) {
				if(confirm("The total volume you have entered ("+ LumpSumAmountTotal +" <CFOUTPUT>#getProgramInfo.Unit_Of_Measure_Desc#</CFOUTPUT>) does not equal the volume entered in the basic information page.      ("+BIAmount+" <CFOUTPUT>#getProgramInfo.Unit_Of_Measure_Desc#</CFOUTPUT>)")){
					<cfif donotallowaddproductsDE EQ 1>
					if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
				{ document.all.deletedateexclusions.value = 1;
					<cfif programagreed GT 0 and GetContractInfo.modifying_program EQ 0 and GetContractInfo.Contract_Status_Type_IDX EQ 2>
	if(confirm("The <cfoutput>#approvalGroupType.Label#</cfoutput>'s which are you responsible for will have their previous agreements/approvals cleared and reset.  Changes made to this program will require you to agree/approve the <cfoutput>#approvalGroupType.Label#</cfoutput>'s you are responsible for again."))
				{
					document.all.NewLumpSum.submit();
				}
					<cfelse>
					document.all.NewLumpSum.submit();
					</cfif>

				}
				else
				{
				return false;
				}
				<cfelse>
							<cfif programagreed GT 0 and GetContractInfo.modifying_program EQ 0 and GetContractInfo.Contract_Status_Type_IDX EQ 2>
	if(confirm("The <cfoutput>#approvalGroupType.Label#</cfoutput>'s which are you responsible for will have their previous agreements/approvals cleared and reset.  Changes made to this program will require you to agree/approve the <cfoutput>#approvalGroupType.Label#</cfoutput>'s you are responsible for again."))
				{
							document.all.NewLumpSum.submit();
				}
							<cfelse>
							document.all.NewLumpSum.submit();
							</cfif>
				</cfif>
				}
				else{
					document.all.new_lump_sum_amount.focus()
				}
			}
			else{
				<cfif programagreed GT 0 and GetContractInfo.modifying_program EQ 0 and GetContractInfo.Contract_Status_Type_IDX EQ 2>
	if(confirm("The <cfoutput>#approvalGroupType.Label#</cfoutput>'s which are you responsible for will have their previous agreements/approvals cleared and reset.  Changes made to this program will require you to agree/approve the <cfoutput>#approvalGroupType.Label#</cfoutput>'s you are responsible for again."))
				{
					document.all.NewLumpSum.submit();
				}
					<cfelse>
					document.all.NewLumpSum.submit();
					</cfif>
			}

			//document.all.NewLumpSum.submit();
		}
		else{
			showMessageWindow();
		}
	}
	function changeLabel(sLabel, whichOne)
	{
		var aObj;
		if(whichOne == 2)
		{
			aObj = document.all.new_lump_sum_reset;
		}
		else
		{
			aObj = document.all.new_lump_sum_save;
		}
		aObj.innerHTML = sLabel;
	}
<!---
<CFINCLUDE TEMPLATE="/script/javascript/string_functions.js">
<CFINCLUDE TEMPLATE="/common_files/scripts/allowonlytwodecimalplaces.js">
--->
</SCRIPT>

<CF_MessageWindow>
<Br>

<!--- <cfif application.returned_customer_setting.lumpsum_product_mandatory EQ 1>
<cfset actionpage = "select_lumpsum_products.cfm?CID=#URL.CID#">
<cfelse>
<cfset actionpage = "Contract_Discount_Lump_Sums_Save_New_Lump_Sum.cfm">
</cfif>
--->
<cfif getsettings.EZButton_On EQ 1 and URL.EZTemplate EQ 0>
	<cfset EzButton_Disable = 1>
<cfelse>
	<cfset EzButton_Disable = 0>
</cfif>

<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
<CFOUTPUT><FORM ACTION="Contract_Discount_Lump_Sums_Save_New_Lump_Sum.cfm" METHOD="post" NAME="NewLumpSum" ID="NewLumpSum"><strong>1. Add a #Application.LumpsumLabel#</CFOUTPUT> component</strong><br>
<cfif appSettings.getPaymentCycleAtDiscountType()>
<table border="0" width="700" cellspacing="0">
	<TR valign="top">
		<TD width="500"></TD>
		<TD nowrap><B>Payment Cycle:</B><SPAN ID="Err_Sp_PaymentCycle1"></SPAN>&nbsp;</TD>
		<TD>
		<cfparam name="FORM.PaymentCycle" 	default="">
		<cf_payment_cycle_selection
			Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
			Program_ID = "#FORM.Contract_Main_ID#"
			discount_Type_ID = "3"
			Selected_Payment_Cycle_ID = "#FORM.PaymentCycle#"
			>
		</TD>
	</TR>
	<TR>
	<cfoutput><TD colspan="3" align="right">(This payment cycle frequency will apply to all #LCase(Application.LumpsumLabel)# components within this program)</TD></cfoutput>
	</TR>
</table>
</cfif>
<FIELDSET STYLE="padding:10px; width: 700px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Component Information</LEGEND>
<!------ <div id="Layer3" style="position:absolute; width: 250px; height: 100px; z-index: 1; left: 400px; top: 50px"> ----->

<!------ </div> ----->
		<TABLE ID="oLumpSumTable" BORDER="0">
			<cfset useLakebaseForGetLSNames = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sum_name")>
<cfif useLakebaseForGetLSNames>
	<cftry>
		<cfset GetLSNames = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_lump_sum_name", {
				"active" = "eq.1",
				"deleted" = "eq.0",
				"select" = "program_lump_sum_name,program_lump_sum_name_id,external_id"
			}), "program_lump_sum_name,program_lump_sum_name_id,external_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetLSNames = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetLSNames>
<cfquery name="GetLSNames" datasource="#application.datasource#">
			SELECT Program_Lump_Sum_Name, Program_Lump_Sum_Name_ID, External_ID
			FROM Program_Lump_Sum_Name
			WHERE Active = 1
			AND Deleted = 0
			</cfquery>
</cfif>
			<TR valign="top">
				<TD ALIGN="right" nowrap><B>Name:</B><SPAN ID="error_Name"></SPAN>&nbsp;</TD>
				<TD>
				<!------ external id ----->
				<cfoutput><select name="Program_Lump_Sum_Name_ID" style="width:180px"><cfloop query="GetLSNames">
					<option value="#Program_Lump_Sum_Name_ID#" <cfif Program_Lump_Sum_Name_ID IS GetLSNames.Program_Lump_Sum_Name_ID>selected</cfif> >#Program_Lump_Sum_Name#<cfif application.returned_customer_setting.external_id_on EQ 1><cfif Len(External_ID) GT 0> (#External_ID#)</cfif></cfif></option>
				</cfloop></select></cfoutput>
				</TD>
			</TR>
			<TR valign="top" style="display:none;">
				<TD ALIGN="right" nowrap ><B>Paid To:</B>&nbsp;</TD>
				<td>
				<!--- "Paid to" radio buttons --->
				<cfdiv bind="url:component_paid_to.cfm?Component_Name_ID={Program_Lump_Sum_Name_ID}&ModifyDeletedPrograms=#ModifyDeletedPrograms#&ContractMainID=#CSLGetContractInfo.contract_main_id#&Discount_Type_ID=3&ProgramType_ID=#CSLGetContractInfo.ProgramType_ID#" bindOnLoad="true" ID="paidToInfo" />
				</td>
			</tr>
			<TR valign="top">
				<TD ALIGN="right" nowrap><B>Amount</B><SPAN ID="error_Amt"></SPAN>&nbsp;</TD>
				<TD><INPUT TYPE="text" NAME="new_lump_sum_amount" onkeyup="clenseText(this, '.0123456789');allowonlytwodecimalplaces(this)"></TD>
			</TR>

			<TR valign="top">
				<TD ALIGN="right" nowrap><B>Volume:</B><SPAN ID="error_Volume"></SPAN>&nbsp;</TD>
				<TD><INPUT TYPE="text" NAME="new_lump_sum_volume" onkeyup="clenseText(this, '0123456789');" READONLY>&nbsp;<CFOUTPUT>#getProgramInfo.Unit_Of_Measure_Desc#</CFOUTPUT></TD>
			</TR>

			<TR valign="top">

				<TD ALIGN="right" nowrap><B>Description:</B><SPAN ID="error_Desc"></SPAN>&nbsp;</TD>
				<TD nowrap><CFOUTPUT><TEXTAREA COLS="50" ROWS="" NAME="new_lump_sum_description" READONLY onPaste="javaScript: return textareaChecklength(#Lump_Desc_Max_Length#, this);"  onkeyPress="javaScript: return textareaChecklength(#Lump_Desc_Max_Length#, this);"></TEXTAREA></CFOUTPUT>
				<!------
				&nbsp;<input TYPE="button" VALUE="save component" ID="new_lump_sum_save" ONCLICK="saveNewLumpSum()">
				&nbsp;<input TYPE="button" VALUE="reset fields" ID="new_lump_sum_reset" ONCLICK="resetNewLumpSum()"></TD>
				 ----->
				&nbsp;<B><FONT COLOR="FF0000">[</FONT><a HREF="##" onClick="<cfif EzButton_Disable EQ 0>saveNewLumpSum();return false;<cfelse></cfif>" id="new_lump_sum_save" >save component</a><FONT COLOR="FF0000">]</FONT></B>
				&nbsp;<B><FONT COLOR="FF0000">[</FONT><a HREF="##" onClick="resetNewLumpSum();return false;" id="new_lump_sum_reset">reset fields</a><FONT COLOR="FF0000">]</FONT></B>
				&nbsp;	<CF_smallLink
							title = "close window"
							url = "##"
							parameters = "onClick=""JavaScript: top.close();if(top.opener){top.opener.focus();};"""
							>
		</TD></TR>
		</table>
</FIELDSET>
<input TYPE="Hidden" NAME="Program_ID" VALUE="<CFOUTPUT>#URL.CID#</CFOUTPUT>">
<input TYPE="Hidden" NAME="component_id" VALUE="0">
<input TYPE="Hidden" NAME="update" VALUE="0">
<input TYPE="Hidden" NAME="deletedateexclusions" VALUE="0">
<!--- Variable controls redirection to "Margin Edit" version of contract rebates --->
	<INPUT TYPE="Hidden" NAME="RedirectPath" 		VALUE="1" />
</FORM>


<CFQUERY NAME="getAllLumpSums" datasource="#application.datasource#">
SELECT 	Program_Lump_Sums.*, Program_Lump_Sum_Name.Program_Lump_Sum_Name, Program_Lump_Sum_Name.External_ID
FROM 	Program_Lump_Sums
		INNER JOIN Program_Lump_Sum_Name
		ON
		Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
WHERE 	Program_ID = '#FORM.Contract_Main_ID#'
		AND Program_Lump_Sums.DELETED = 0
</CFQUERY>
<cfif GetAllLumpSums.Recordcount GT 0>

<strong>2. Add products to the <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> (optional)</strong><br>
<style>
	TABLE.Maintable TD	{ font-size : 10px;}
	#header {font-size: 12px;}
</style>
<cfset LumpSumManager = CreateObject("component", "components.programs.lump_sum_components.LumpSumManager") />
<cfset LumpSumDataManager = CreateObject("component", "components.programs.lump_sum_components.DataManager").init() />
<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset businessSegmentID = businessSegManager.getSegmentIdByProgram(FORM.Contract_Main_ID) />
<cfset bAllowSelectAllProducts = ProductGroupManager.allowSelectAllProducts(3, FORM.Contract_Main_ID) />
<cfparam name="Form.groupLevelProducts" 	default="0">
<cfparam name="Form.Product_Level_1" 	default="">

<table WIDTH="800" style="Maintable" CELLPADDING="3" CELLSPACING="0" BORDER="0">
<tr BGCOLOR="#FFCE84" VALIGN="bottom">
	<td style="border-bottom:solid #93BEE2 1px;">&nbsp; </td>
	<td style="border-bottom:solid #93BEE2 1px;" nowrap ID="header"><strong>Name</strong></td>
	<td style="border-bottom:solid #93BEE2 1px;" nowrap ID="header"><strong>Amount</strong></td>
	<td style="border-bottom:solid #93BEE2 1px;" nowrap ID="header"><strong>Volume</strong></td>
	<td style="border-bottom:solid #93BEE2 1px;" id="header"><strong> Product/Group</strong></td>
	<td style="border-bottom:solid #93BEE2 1px;" colspan="5">&nbsp; </td></tr>

<CFOUTPUT QUERY="getAllLumpSums">
	<cfset thisBAllowSelectAllProducts = bAllowSelectAllProducts />
	<cfset getLumpSumProducts = LumpSumDataManager.getProgramLumpSumProducts(getAllLumpSums.Program_Lump_Sum_ID, FORM.Contract_Main_ID) />
	<cfset Form.Product_List = valuelist(getLumpSumProducts.BSA_Foodservice_Items_Master_ID, ",") />

  <cfset thisFormname = "LumpSumForm_"&replace(getAllLumpSums.Program_Lump_Sum_ID, "-", "_", "ALL")>
	<cfset lump_id = getAllLumpSums.Program_Lump_Sum_ID>
	<cfset lump_desc = replace(replace(replace(getAllLumpSums.Lump_Sum_Description, "'", "", "ALL"), '"', '', "ALL"), chr(13)&chr(10), " ", "ALL")>
	<cfset lump_name = replace(replace(getAllLumpSums.Lump_Sum_Name, "'", "", "ALL"), '"', '', "ALL")>
	<cfset lump_vol = trim(numberformat(getAllLumpSums.Lump_Sum_Volume, '___________________'))>
	<cfset lump_amt =  trim(numberformat(Lump_Sum_Amount, '_______________.__'))>
	<cfset comp_paid_to = getAllLumpSums.Component_Paid_To>

	<tr valign="top" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
	<td>&nbsp; </td>
	<!------ external id ----->
	<td nowrap>#Program_Lump_Sum_Name#<cfif application.returned_customer_setting.external_id_on EQ 1><cfif Len(External_ID) GT 0> (#External_ID#)</cfif></cfif>&nbsp; </td>
	<td nowrap>#lscurrencyformat(lump_amt)#&nbsp; </td>
	<td nowrap>#lump_vol#&nbsp;#getProgramInfo.Unit_Of_Measure_Desc#&nbsp; </td>
	<td>#getLumpSumProducts.Recordcount#&nbsp; </td>
	<td nowrap style="display:none;">
	<cf_smallLink
			url="##"
			title="product/group"
			parameters="STYLE=""cursor:pointer;"" ONCLICK=""javaScript: showProductView('#Program_Lump_Sum_ID#');return false;"""
			>
	</td>
	<td nowrap style="display:none;">
	<cf_smallLink
			url="select_lumpsum_distributors.cfm?CID=#URL.CID#&Program_Lump_Sum_ID=#Program_Lump_Sum_ID#"
			title="#application.returned_customer_setting.distributor_label_plural#"
			>
	</td>
	<td nowrap>
	<cf_smallLink
			url="##"
			title="edit component"
			parameters="STYLE=""cursor:pointer;"" ONCLICK=""javaScript: editComponent('#lump_id#','#JSStringFormat(Program_Lump_Sum_Name_ID)#','#lump_desc#','#lump_amt#','#lump_vol#',#evaluate("getAllLumpSums.currentrow-1")#,#comp_paid_to#);return false;"""
			>
	<!------ <span STYLE="color: red;">[</span><A ONCLICK="editComponent('#lump_id#', '#JSStringFormat(Program_Lump_Sum_Name_ID)#', '#lump_desc#', '#lump_amt#', '#lump_vol#', #evaluate("getAllLumpSums.currentrow-1")#)" STYLE="cursor: pointer;">edit component</A><span STYLE="color: red;">]</span> ----->
	</td>
	<td VALIGN="middle" style="display:none;"><A STYLE="cursor: pointer;" ONCLICK="deleteComponent('#getAllLumpSums.Program_Lump_Sum_ID#', '#JSStringFormat(Program_Lump_Sum_Name)#')"><img src="../../Images/scissor.gif" title="remove this component" border="0"></A></td>
	</tr>
	<tr style="border-bottom:solid ##93BEE2 1px;" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#"><td style="border-bottom:solid ##93BEE2 1px;">&nbsp; </td><td colspan="9" style="border-bottom:solid ##93BEE2 1px;"><em>#lump_desc#</em>&nbsp;
	<FORM ACTION="Contract_Discount_Lump_Sums_Save_Products.cfm" METHOD="post" NAME="#thisFormname#" ID="#thisFormname#" ONSUBMIT="alert();" style="display:inline;">
		<INPUT TYPE="Hidden" NAME="Sort_By" VALUE="#URL.Sort_By#">
		<INPUT TYPE="Hidden" NAME="Program_ID" VALUE="#URL.CID#">
		<INPUT TYPE="hidden" NAME="Program_Lump_Sum_ID" ID="LumpSum_ID" VALUE="#getAllLumpSums.Program_Lump_Sum_ID#">
		<INPUT TYPE="hidden" NAME="ExistingProductList" VALUE="#Form.Product_List#">
		<INPUT TYPE="hidden" NAME="Product_List" VALUE="">
		<INPUT TYPE="Hidden" NAME="DTPS_On" 						VALUE="1">
		<INPUT TYPE="Hidden" NAME="DTPS_Program_ID" 				VALUE="#FORM.Contract_Main_ID#">
		<!--- Variable controls redirection to "Margin Edit" version of contract rebates --->
	<INPUT TYPE="Hidden" NAME="RedirectPath" 		VALUE="1" />
	</FORM>
	</td></tr>
	<!------ Display details if application settings says so ----->
	<cfif appSettings.getPgmLumpsumDetailedDisplay()>
	<!------ Display distributor details ----->
	<CFIF GetSettings.Discount_Lump_Sums_Distributor_Mandated EQ 1>
	<TR>
		<TD colspan="100%" align="right">
		<!------ Get distributors ----->
		<cfset getDistributors  = LumpSumManager.getLumpSumDistributors(Program_ID, Program_Lump_Sum_ID, 1)>
		<TABLE cellspacing="2" cellpadding="2" WIDTH="90%">
		<tr>
		<td style="border-bottom:1px solid orange;" colspan="100%" id="header" align="left"><B>#Application.LumpsumLabel# #application.returned_customer_setting.distributor_label_plural#</B></td>
		</tr><tr>
			<CFIF getDistributors.RECORDCOUNT GT 0>
				<CFLOOP QUERY="getDistributors">
					<!---handle what gets passed to the distributor profile popup based on groups--->
					<TD style="border:none;" CLASS="dataStyle" WIDTH="33%" VALIGN="top">
						<span>
							<FONT SIZE="1">
							#ucase(trim(getDistributors.Name))# <cfif Len(Shr_Ship_To)>(#Shr_Ship_To#)</cfif>
							</FONT>
						</span>
					</TD>
					<CFIF getDistributors.CURRENTROW MOD 3><CFELSE></TR><TR></CFIF>
				</CFLOOP>
			<CFELSE>
				<TD ALIGN="center"><B><FONT COLOR="Red">NONE SUPPLIED</FONT></B></TD>
			</CFIF>
		</TABLE>
		</TD>
	</TR>
	</CFIF>
	<!------ Display product details ----->
	<TR>
		<TD colspan="100%" align="right">
		<cfset displayLumpSumInfo = 0 />
		<cfset URL.LUMP_ID = Program_Lump_Sum_ID />
		<TABLE cellspacing="0" cellpadding="2" WIDTH="90%">
		<tr>
		<td style="border-bottom:1px solid orange;" colspan="100%" id="header" align="left"><B>#Application.LumpsumLabel# Products</B></td>
		</tr>
		<tr>
		<td style="border:none;">
		<cfinclude template="lumpsum_products.cfm">
		</td>
		</tr>
		</table>
		<br>
		</TD>
	</TR>
	</cfif>
</CFOUTPUT>
</table>

	<cfoutput><FORM ACTION="Contract_Discount_Lump_Sums_Delete.cfm" METHOD="post" NAME="comDeleteForm" ID="comDeleteForm">
	<input TYPE="Hidden" NAME="Component_ID" VALUE="">
	<INPUT TYPE="Hidden" NAME="Program_ID" VALUE="#URL.CID#">
	<input TYPE="Hidden" NAME="deletedateexclusions" VALUE="#form.deletedateexclusions#">
</FORM>		</cfoutput>
</cfif>
</BLOCKQUOTE></BLOCKQUOTE>
<cfif application.programlayout EQ 1></div></cfif>
<script>
function deleteComponent(component_id, name) {
		if(confirm("Do you really want to delete " + name + "?")){
			document.all.comDeleteForm.Component_ID.value = component_id;
			<cfif donotallowaddproductsDE EQ 1>
					if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
				{ comDeleteForm.deletedateexclusions.value = 1;</cfif>
			document.all.comDeleteForm.submit();
			<cfif donotallowaddproductsDE EQ 1> } </cfif>
		}

	}

</script>

<cfif GetContractInfo.modifying_program EQ 0 and marginedit_saved>
	<cfset overrideClosure = 1>
	<cfset form.programid = '#URL.CID#' />
	<cfinclude template="reset_program_agreed.cfm" />
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>
