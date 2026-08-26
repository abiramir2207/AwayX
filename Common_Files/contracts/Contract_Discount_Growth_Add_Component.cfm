<!--- lock checker --->
<CFSET LockChecker_CID  = URL.PROGRAM_ID>
<CFINCLUDE TEMPLATE="LockChecker_For_Popups.cfm">

<!--- lock checker --->
<cfparam name="donotallowaddproductsDE" default = "0">
<cfparam name="form.deletedateexclusions" default = "0">
<cfparam name="Form.Growth_Component_Name_ID" default="">
<cfparam name="FORM.AllowSave" default="0">
<cfparam name="url.excludeList" default="0">

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset compGrowth = CreateObject("component","components.programs.Growth.GrowthComponent")>
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<cfset RevisionSettingsManager = CreateObject("component", "components.programs.Display_Program.revision_settings") />

<cfif isDefined("url.Component_Name")>
	<cfset FORM.Component_Name = url.Component_Name>
</cfif>

<cfif isDefined("url.Growth_Component_Name_ID")>
	<cfset FORM.Growth_Component_Name_ID = url.Growth_Component_Name_ID>
</cfif>

<cfif isDefined("url.Component_Description")>
	<cfset FORM.Component_Description = url.Component_Description>
</cfif>

<CFPARAM NAME="FORM.Component_Name" DEFAULT="">
<CFPARAM NAME="FORM.Component_Description" DEFAULT="">
<CFPARAM NAME="FORM.rate_type" DEFAULT="1">
<CFPARAM NAME="FORM.Tier_Count" DEFAULT="">
<CFPARAM NAME="Comparison_Type" DEFAULT="">
<CFPARAM NAME="Sample_Period" DEFAULT="">
<CFPARAM NAME="Seperate_Volume_Pool" default="">
<CFPARAM NAME="FORM.Comp_Name_ID" default="0">
<CFPARAM NAME="form.Comp_Paid_To" default="1">
<CFPARAM NAME="FORM.Program_Growth_Comparison_Period_UOM" default ="1">
<CFPARAM NAME="FORM.Claim_Mechanics" default ="">
<CFPARAM NAME="FORM.GL_Account_ID" default ="0">
<CFPARAM NAME="FORM.Vendor_Master_ID" default ="">
<CFPARAM NAME="FORM.VendorSelection" default ="1">
<CFPARAM NAME="url.EZTemplate" default="0">
<CFPARAM NAME="URL.COMPONENT_ID" default="0">
<CFPARAM NAME="FORM.Payee_Selection" default ="">
<CFPARAM NAME="FORM.Min_Purchase_Requirement" DEFAULT="0">
<CFPARAM NAME="FORM.Min_Purchase_Value" DEFAULT="">
<CFPARAM NAME="FORM.Growth_Calculation" DEFAULT="">

<cfset Form.Contract_Main_ID = Program_ID>

<!---
	Dev Notes: 22308/Anand Rao/04-Feb-10
	CAG - multi discount type template
--->
<cfset sDiscountType = "REBATE" />
<CFSET Contract_Main_ID = Program_ID>
<cfinclude template="inc_Discount_Type_Checker.cfm" />

<CFQUERY NAME="GetAllContractInfo" datasource="#application.datasource#">
	SELECT	contract_main.programtype_id,Program_Control_Panel_Options.RateTypeDefault, Program_Control_Panel_Options.Growth_Auto_Pay,
			Program_Control_Panel_Options.Growth_Min_Purchase
	FROM	Contract_Main
			INNER JOIN Units_of_Measure ON
			Contract_Main.Contract_Quantity_UOM_IDX = Units_of_Measure.Unit_Of_Measure_ID
			inner join Program_Control_Panel_Options
			ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = contract_main.programtype_id
	WHERE 	Contract_Main_ID = #FORM.Contract_Main_ID#
</CFQUERY>

<CFIF URL.COMPONENT_ID EQ 0>
	<CFQUERY NAME="getComponentInfo" datasource="#application.datasource#">
		SELECT *,  0 as component_uom, 0 as Program_Growth_Comparison_Period_UOM_ID
		FROM Program_Growth_Component_Tiers
		WHERE 0=1
	</CFQUERY>
	<CFQUERY NAME="getTiers" datasource="#application.datasource#">
		SELECT *
		FROM Program_Growth_Component_Tiers
		WHERE 0=1
	</CFQUERY>
<CFELSE>
	<CFQUERY NAME="getComponentInfo" datasource="#application.datasource#">
	SELECT Program_Growth_Component_ID,Program_ID,Tier_Count,Rate_Type,Component_Name,
			Component_Description,Deleted,component_uom,Comparison_Type,Sample_Period,
			Program_Growth_Component_Type_ID,IsParent,Parent_ID,Is_Rate,Is_Volume,Target_Order,
			Growth_Component_Name_Id,Growth_Revision_Comp_ID,Claim_Mechanics,Component_Paid_To,
			Program_Growth_Components_Name_Id,Program_Growth_Comparison_Period_UOM_ID,
			GL_Account_ID,Component_External_ID,Vendor_Selection,Vendor_Master_ID,
			Payee_Type As Payee_Selection,
			Min_Purchase_Requirement, Min_Purchase_Value,Growth_Calculation
	FROM Program_Growth_Components
	WHERE Program_ID = '#URL.Program_ID#' AND
	Program_Growth_Component_ID = '#URL.COMPONENT_ID#' And Deleted = 0
	</CFQUERY>

	<CFSET FORM.Component_Name = getComponentInfo.Component_Name>
	<CFSET FORM.Component_Description = getComponentInfo.Component_Description>
	<CFSET FORM.rate_type = getComponentInfo.rate_type>
	<CFSET FORM.Tier_Count = getComponentInfo.Tier_Count>
	<cfset Comparison_Type = getComponentInfo.Comparison_Type>
	<cfset Sample_Period = getComponentInfo.Sample_Period>
	<cfset FORM.Comp_Name_ID = getComponentInfo.Growth_Component_Name_ID>
	<cfset form.Comp_Paid_To= getComponentInfo.Component_Paid_To />
	<cfset FORM.Program_Growth_Comparison_Period_UOM = getComponentInfo.Program_Growth_Comparison_Period_UOM_ID />
	<cfset FORM.Claim_Mechanics = getComponentInfo.Claim_Mechanics />
	<cfset FORM.GL_Account_ID = getComponentInfo.GL_Account_ID />
	<cfset FORM.Vendor_Master_ID = getComponentInfo.Vendor_Master_ID />
	<cfset FORM.VendorSelection = getComponentInfo.Vendor_Selection />
	<cfset FORM.Payee_Selection = getComponentInfo.Payee_Selection />
	<cfset FORM.Min_Purchase_Requirement = getComponentInfo.Min_Purchase_Requirement />
	<cfset FORM.Min_Purchase_Value = getComponentInfo.Min_Purchase_Value />
	<cfset FORM.Growth_Calculation = getComponentInfo.Growth_Calculation />

	<cfif getComponentInfo.Program_Growth_Component_Type_ID IS 1>

		<!---See if there are any kids--->
		<cfquery name="CheckforVolumePool" datasource="#application.datasource#">
			SELECT 	Component_Name
			FROM 	Program_Growth_Components
			WHERE 	Deleted = 0
			AND 	Parent_ID = '#URL.COMPONENT_ID#'
		</cfquery>
		<cfparam name="Seperate_Volume_Pool" default=0>

		<cfif CheckforVolumePool.Recordcount GT 0>
			<cfset Seperate_Volume_Pool = 1>
		<cfelse>
			<cfset Seperate_Volume_Pool = 0>
		</cfif>

	</cfif>

	<CFQUERY NAME="getTiers" datasource="#application.datasource#">
		SELECT 	*
		FROM 	Program_Growth_Component_Tiers
		WHERE 	Program_Growth_Component_ID = '#getComponentInfo.Program_Growth_Component_ID#' AND DELETED = 0
		ORDER BY Tier_Number ASC
	</CFQUERY>
</CFIF>

<CFQUERY NAME="getProgramUOM" datasource="#application.datasource#">
	SELECT     dbo.Units_of_Measure.Unit_Of_Measure_Desc, dbo.Units_of_Measure.Abbreviation, dbo.Contract_Main.Contract_Main_ID
	FROM         dbo.Contract_Main INNER JOIN
	                      dbo.Units_of_Measure ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID
	WHERE     (dbo.Contract_Main.Contract_Main_ID = '#URL.Program_ID#')
</CFQUERY>


<CFSET PAGE_TITLE= "Product Growth Component Creation">
<!DOCTYPE HTML>
<!--- <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"> --->
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
    <cf_include files="/common_files/jQuery.cfm, /script/javascript/string_functions.js, /Script/javascript/format_functions.js">
    <cfset jQueryUI.widgets = "full">
    <cfinclude template="/common_files/jQueryUI.cfm">      
</HEAD>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" ONLOAD="initPage();">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfif url.EZTemplate EQ 0>
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
	select{height:20px;}
</style>

<CFSET CSL_Contract_Main_ID = url.Program_ID>
<CFSET CSL_CallingPageCode = "growth">
<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 5; left: 10px; top: 0px">
  <CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
<cfelse>
<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
</cfif>

<cfset RevisionSettings = RevisionSettingsManager.getRevisionSettings(templateId = GetSettings.ProgramControl_Panel_Options_ID,profilesID = request.AccessStructure.Profiles_ID, ContractMainID = CSL_Contract_Main_ID)>

<cfif GetSettings.Date_Exclusions_ON EQ 1>
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(CSL_Contract_Main_ID,0)>
<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
	<cfset donotallowaddproductsDE = 1>
</CFIF>
</cfif>

<cfif getsettings.EZButton_On EQ 1 and URL.EZTemplate EQ 0>
	<cfset EzButton_Disable = 1>
<cfelse>
	<cfset EzButton_Disable = 0>
</cfif>

	<script>
		function initPage(){
			<CFIF len(trim(FORM.Tier_Count)) NEQ 0 AND FORM.Tier_Count NEQ 0>
			if(<CFOUTPUT>#trim(getComponentInfo.Tier_Count)#</CFOUTPUT> > 0) {
				buildTierOutlines(<CFOUTPUT>#trim(getComponentInfo.Tier_Count)#</CFOUTPUT>)
			}
			</CFIF>
			document.all.Tier_Count.focus()
		}


		FirstLoad 					= true;
		tierRangeStartData 			= new Array()
		tierRangeEndData 			= new Array()
		tierRangeGrowthAmountData 	= new Array()
		tierUOM						= new Array();

		<CFIF getTiers.Recordcount GT 0>
			<CFOUTPUT QUERY="getTiers">
				tierRangeStartData[#currentrow#] = "#getTiers.Range_Start#";
				tierRangeEndData[#currentrow#] = "#getTiers.Range_End#";
				tierRangeGrowthAmountData[#currentrow#] = "#trim(numberformat(getTiers.Growth_Amount, '_______________________.__'))#";
			</CFOUTPUT>
		</CFIF>

		function showPercent(thisObj)
		{
			var bDisplay = "none";
			if(thisObj.value == 3)
			{
				bDisplay = "";
			}
			else
			{
				changeUOMAction();
			}
			document.all.TR_Percent.style.display = bDisplay;
			document.all.TR_Percent_UOM.style.display = bDisplay;
		}

		function changeUOMAction() {

			for(var z=0; z<rangeStartCollection.length; z++)
			{
				tempStart		= eval("document.all."+rangeStartCollection[z])
				tempEnd			= eval("document.all."+rangeEndCollection[z])
				tempStart.onchange();
				tempEnd.onchange();
			}

		}

		function selectOnchange(){
			tierUOM[event.srcElement.count] = event.srcElement.selectedIndex+1
		}

			var rangeStartCollection 	= new Array();
			var rangeEndCollection 		= new Array();
			var rangeLumpsumCollection 	= new Array();
			var rangeUOM 				= new Array();


		function buildTierOutlines(tierCount) {
			if(tierCount > 10){
				return false
			}

			rangeStartCollection 	= new Array();
			rangeEndCollection 		= new Array();
			rangeLumpsumCollection 	= new Array();
			rangeUOM 				= new Array();

			for(var r=document.all.oTierTable.rows.length; r > 1; r--) {
				document.all.oTierTable.deleteRow(r-1);
			}

			for(var x=1;x<=tierCount;x++){
				if(x == 1) readonly = "";
				else readonly = "";

				tr = document.all.oTierTable.insertRow(-1);
				tr.TierCount = x

				tierCountCell 	= tr.insertCell(-1)
				tierCountCell.align="center"
				tierCountCell.innerHTML = x

				rangeStartCell 	= tr.insertCell(-1)
				rangeStartCell.innerHTML = "<SPAN ID='error_tier_"+x+"_RangeStart'></SPAN><INPUT NAME='tier_" +x+"_RangeStart' SIZE='6' TYPE='text' onfocus='fillRangeStart(" + x + ");' ONKEYUP='validateCellData(this);tierRangeStartData["+x+"] = this.value;' "+readonly+"  onChange=\" this.value=formatToDecimalPlaces(this.value, getMaxDecimalLen(), 0);\">"

				rangeStartCollection[rangeStartCollection.length] = "tier_" +x+"_RangeStart";

				if(window.tierRangeStartData[x] != null) {
					eval("document.all.tier_" +x+"_RangeStart.value='"+tierRangeStartData[x]+"'")
				}
				readonly = ""


				dashCell 	= tr.insertCell(-1)
				dashCell.align="center"
				dashCell.style.cssText = "font-size: 12px; font-weight: bold;"
				dashCell.innerHTML = "-"


				rangeEndCell 	= tr.insertCell(-1)
				rangeEndCell.innerHTML = "<SPAN ID='error_tier_"+x+"_RangeEnd'></SPAN><INPUT NAME='tier_" +x+"_RangeEnd' SIZE='6' TYPE='text' ONKEYUP='validateCellData(this);tierRangeEndData["+x+"] = this.value;' "+readonly+" onChange=\"if(this.value != '*'){this.value=formatToDecimalPlaces(this.value, getMaxDecimalLen(), 0);initRangeStart(" +  x + ");}\">" /// D35731 Growth Auto Pay
				rangeEndCollection[rangeEndCollection.length] = "tier_" +x+"_RangeEnd";


				if(window.tierRangeEndData[x] != null) {
					if(FirstLoad == false && tierRangeEndData[x] == "*") tierRangeEndData[x] = "";

					eval("document.all.tier_" +x+"_RangeEnd.value='"+tierRangeEndData[x]+"'")
				}

				rangeGrowthCell = tr.insertCell(-1)
				rangeGrowthCell.innerHTML = "<SPAN ID='error_tier_"+x+"_GrowthAmount'></SPAN>&nbsp;"
				<!--- <cfif appSettings.getBonusInGrowthSwitch()>  ---> <!--- 43234 Growth Template Settings --->
				<cfif GetSettings.Bonus_Field eq 1>
					rangeGrowthCell.innerHTML = rangeGrowthCell.innerHTML +  "<INPUT NAME='tier_" +x+"_GrowthAmount' SIZE='6' TYPE='text' value='0' ONKEYUP='clenseText(this, \".0123456789\");' ONCHANGE='this.value=formatToDecimalPlaces(this.value,2);tierRangeGrowthAmountData["+x+"] = this.value;'>"
				<cfelse>
					rangeGrowthCell.innerHTML = rangeGrowthCell.innerHTML + "<INPUT NAME='tier_" +x+"_GrowthAmount' SIZE='6' TYPE='hidden' value='1'>"
				</cfif>

				rangeLumpsumCollection[rangeLumpsumCollection.length] = "tier_" +x+"_GrowthAmount";

				if(window.tierRangeGrowthAmountData[x] != null) {
					eval("document.all.tier_" +x+"_GrowthAmount.value='"+tierRangeGrowthAmountData[x]+"'")
				}



			}
			FirstLoad = false;
		}

		function initRangeStart(rangeEndIndex)
		{
			var Tier_Count = parseInt(document.all.Tier_Count.value);
			if(rangeEndIndex < Tier_Count && rangeEndIndex > 0)
			{
				var addValue = 1;
				var thisObj = eval("document.all.tier_" + (rangeEndIndex) + "_RangeEnd");
				if(getDecimalForTiers())
				{
					var currVal = parseFloat(thisObj.value);
					var dotIndex = 	thisObj.value.indexOf(".");
					if(dotIndex > 0)
					{
						dotIndex = thisObj.value.length - dotIndex - 1;
					}
					if(dotIndex > 0)
					{
						addValue = Math.pow(10, dotIndex * -1);
					}
				}
				else
				{
					var currVal = parseInt(thisObj.value);
				}
				var nextRangeStart = eval("document.all.tier_" + (rangeEndIndex + 1) + "_RangeStart");
				if(nextRangeStart && !isNaN(currVal))
				{
					nextRangeStart.value = numericRoundDecimal(currVal + addValue, getMaxDecimalLen());
				}
			}
		}

		function fillRangeStart(rangeIndex)
		{
			// alert(rangeIndex);
			rangeIndex = rangeIndex-1;
			// alert(rangeIndex);
			initRangeStart(rangeIndex);
		}

		function verifyRanges() {
			ErrorCount=0
			for(var z=0; z<rangeStartCollection.length; z++){
				tempStart		= eval("document.all."+rangeStartCollection[z])
				tempStart_Span	= eval("document.all.error_"+rangeStartCollection[z])

				tempEnd			= eval("document.all."+rangeEndCollection[z])
				tempEnd_Span	= eval("document.all.error_"+rangeEndCollection[z])
				if(parseFloat(tempStart.value) >= parseFloat(tempEnd.value)){
					ErrorCount++;
						queueMessage("The range start must be less than the range end.", tempStart_Span)
						return false
				}
				else{
					clearQueue(tempStart_Span)
				}
			}

		return verifyConcurrency()
		}

		function verifyConcurrency(){
			for(var z=0; z<rangeStartCollection.length; z++) {
				tempStart		= eval("document.all."+rangeStartCollection[z])
				tempStart_Span	= eval("document.all.error_"+rangeStartCollection[z])

				tempEnd			= eval("document.all."+rangeEndCollection[z])
				tempEnd_Span	= eval("document.all.error_"+rangeEndCollection[z])

				nextTempStart		= eval("document.all."+rangeStartCollection[z+1])
				nextTempStart_Span	= eval("document.all.error_"+rangeStartCollection[z+1])

				previousTempEnd		= eval("document.all."+rangeEndCollection[z-1])
				previousTempEnd_Span	= eval("document.all.error_"+rangeEndCollection[z-1])

				if(nextTempStart != null) {
					if(parseFloat(nextTempStart.value) <= parseFloat(tempEnd.value)){
						ErrorCount++;

						queueMessage("The start of this tier must be one more than the end of the prior tier.", nextTempStart_Span)
						return false
					}
					else{
						clearQueue(nextTempStart_Span)
					}
				}


				if(previousTempEnd != null){
					if((parseInt(tempStart.value) - parseInt(previousTempEnd.value)) > 1){
						ErrorCount++;
						queueMessage("The start of this tier must be one more than the end of the prior tier.", tempStart_Span)
						return false
					}
					else{
						clearQueue(tempStart_Span)
					}
				}
			}
			return true
		}

		function getDecimalForTiers()
		{
			var decimalForTiers = 0;
			<cfif appSettings.getGrowthDecimal4PercentTier()>
			/* if(document.all.component_uom.value == "3")
			{ */
				decimalForTiers = 1;
			/* } */
			</cfif>
			return decimalForTiers;
		}

		function getMaxDecimalLen()
		{
			var maxDecimalLen = 0;
			if(getDecimalForTiers())
			{
				maxDecimalLen = 2
			}
			return maxDecimalLen;
		}

		function validateCellData(textObject) {

			validList="0123456789"
			if(getDecimalForTiers())
			{
				validList="0123456789."
			}

			if(textObject.name == "tier_"+parseInt(document.all.Tier_Count.value)+"_RangeEnd") {
				if(textObject.value.indexOf("*") != - 1) {
					textObject.value = "*"
					validList="*"
				}
			}
			clenseText(textObject, validList);


		}

		<!--- <CFINCLUDE TEMPLATE="/script/javascript/string_functions.js"> --->

	function validateForm(){
		ErrorCount=0;
	  	if(document.newComponentForm.bAllowAddComp.value == 0)
			{
			  alert("This program can only have one discount type. Please remove a discount type.");
		    // return false; // This will be a HARD STOP and we only need an information
			}
		if(document.newComponentForm.Growth_Component_Name_ID.value == '-1')
			{
					alert("You must select a growth component");
					return;
			}
	//D46874 :: New Growth Option (Growth Calculation) START
	<cfif GetAllContractInfo.Growth_Auto_Pay>
		if(document.newComponentForm.Growth_Calculation.value == 0)
			{
					alert("You must select a growth calculation");
					return;
			}
		// Growth Calc = Every planning group, Payee = Each distributor
		if(document.newComponentForm.Growth_Calculation.value == 3 && $('input[name="VendorSelection"]:checked').val() == 2)
			{
					alert('Your combinations of Growth Calculation and Payee are not supported.');
					return;
			}
		// Growth Calc = Entire program, Payee = Each distributor
		if(document.newComponentForm.Growth_Calculation.value == 1 && $('input[name="VendorSelection"]:checked').val() == 2)
			{
					alert('Your combinations of Growth Calculation and Payee are not supported.');
					return;
			}
		// Growth Calc = Entire program, Payee = Every planning group
		if(document.newComponentForm.Growth_Calculation.value == 1 && $('input[name="VendorSelection"]:checked').val() == 3)
			{
					alert('Your combinations of Growth Calculation and Payee are not supported.');
					return;
			}
	</cfif>
	//D46874 :: New Growth Option (Growth Calculation) END
	<!--- Make sure that the GL Code validation is only for components which have a GL Code --->
	<cfif appsettings.getGL_Account_On() IS 1 AND appsettings.getGL_Account_Required_for_Comp() IS 1>
		for (var i=0;i<newComponentForm.length;i++){ // loop through all elements
			var name_=newComponentForm[i].name; // get element name
			var type_=newComponentForm[i].type; // get element type
			var GL_Account_Control_Name;
				 GL_Account_Control_Name = 'Growth_GL_Account_ID_'+document.newComponentForm.Growth_Component_Name_ID.value;
				if(type_ == 'hidden' && name_== GL_Account_Control_Name)
				{
					GL_Account_Control_value = eval('document.newComponentForm.Growth_GL_Account_ID_'+document.newComponentForm.Growth_Component_Name_ID.value+'.value');
						if(GL_Account_Control_value != '' && document.newComponentForm.GL_Account_ID.value == "0")
						{
							alert("You must select a <cfoutput>#Application.GLAccountLabel#</cfoutput> for this component");//D42774
							return;
						}
				}
		}
	</cfif>
	<cfif appSettings.getPaymentCycleAtDiscountType()>
		<!------ check for payment cycle ----->
		if(document.all.PaymentCycle.value == "0") {
			alert("Select a payment cycle");
			return;
		}
	</cfif>
<!--- If it is auto pay, and operator or broker, the vendor id is required.
				If it is auto pay and includes distributor and doesn't have id, then let them know
				about the manual allocation of vendors on the auto billbacks --->
		<!--- only bother with any of this if it's auto pay --->

		if(document.newComponentForm.Auto_Pay_Status.value == 1)
		{
			<!--- They didn't pick a payee --->
			//alert(document.all.Vendor_Master_ID.value);
			if(document.all.Vendor_Master_ID)
			{
			 if(document.all.Vendor_Master_ID.value == 0)
			 {
				 var OperatorOption = 0;
				 var PayeeOption = 0;
				if (document.all.Component_Paid_To)
				{
					/* Determine who the payee is */
					for (i=0; i<=document.all.Component_Paid_To.length-1; i++)
					{
						if (document.all.Component_Paid_To[i].checked == true)
						{
						PayeeOption = i;
						}
					}
						if (PayeeOption == 1 || PayeeOption == 3)
						{
						OperatorOption = 1
						}
				}
				/* A vendor needs to be selected if "Select a single payee" option is selected, otherwise the vendor
					 is required ony if the payee is an operator or has an operator (Customer and Operator option).
					 document.all.Vendor_Selection.value will be true for "Select a single payee".
					 (It comes from claim_mech_info.cfm)
				*/
					/* Dev Note: (Milan) - 46530 - If a user created a component to "Pay each entity individually", while editing the same component, "document.all.Vendor_Selection.value"
					needs to be updated. Without it, we get the "You must select a vendor for the auto payments" js validation message for "Pay each entity individually".
					That validation message should only popup for "Select a single payee" option, if a vendor is not selected. On "Claim_mech_info.cfm" file, document.all.Vendor_Selection.value
					is updated only when a user changes the radio button option. So, needed to add logic below.
					*/
					document.all.Vendor_Selection.value = document.all.VendorSelection[0].checked;

					 if(document.all.Vendor_Selection.value == 'true')
					 {
					 		if(PayeeOption == 0)
							{
								alert("You must select a vendor for the auto payments.")
								return;
							}
							else
							{
								alert("You must select a vendor for auto pay components not payable to distributor")
								return;
							}
					}
					 else
					 {
							if(PayeeOption == 1 || PayeeOption == 3)
							{
								alert("You must select a vendor for auto pay components not payable to distributor")
								return;
							}
					 }
					}
				}
			}

			Growth_Component_Name_ID_Obj = document.all.Growth_Component_Name_ID;
			oComponentName =  document.getElementById("Component_Name");
			if (oComponentName.value.length == 0)
				oComponentName.value = Growth_Component_Name_ID_Obj[Growth_Component_Name_ID_Obj.selectedIndex].text;
			if(trim(Growth_Component_Name_ID_Obj[Growth_Component_Name_ID_Obj.selectedIndex].text).length == 0){
				ErrorCount++;
				queueMessage("What is the name for this component?", document.all.error_Name)
			}
			else{
				clearQueue(document.all.error_Name)
			}
			<CFSET Component_Description_Max_Length = 255>
			//if(trim(document.all.Component_Description.value).length > <CFOUTPUT>#Component_Description_Max_Length#</CFOUTPUT>){
			var growthDescLen = jQuery("textarea[name=Component_Description]").val();
			if(growthDescLen.length > <CFOUTPUT>#Component_Description_Max_Length#</CFOUTPUT>){
				ErrorCount++;
				queueMessage("Description cannot be longer than <CFOUTPUT>#Component_Description_Max_Length#</CFOUTPUT> characters", document.all.error_Desc);
			}
			else{
				clearQueue(document.all.error_Desc)
			}
			<cfif GetSettings.Allow_Growth_Multi_Rate EQ 1 AND GetSettings.ALLOW_VOLUME_POOL_SEPERATION EQ 1>
			<!---Can't have multi rate and seperate volume pool--->
			if(document.all.Seperate_Volume_Pool)
			{
				if(document.all.rate_type[1].checked && document.all.Seperate_Volume_Pool.checked)
				{
					ErrorCount++;
					queueMessage("You cannot have a bracket rate component with a separate volume pool.", document.all.error_Multi)
				}
				else
				{
					clearQueue(document.all.error_Multi)
				}
			}
			 </cfif>
			 if(document.all.component_uom.value == 3 && !(document.all.Comparison_Type[0].checked || document.all.Comparison_Type[1].checked)){
				ErrorCount++;
				queueMessage("If your tiers are pecent based, you must select comparison period.", document.all.error_Comparison_Type)
			}
			else{
				clearQueue(document.all.error_Comparison_Type)
			}
			if (document.all.Comparison_Type[1].checked && trim(document.all.Sample_Period.value).length == 0)
			{
				ErrorCount++;
				queueMessage("You must enter the number of days the comparison sample should be.", document.all.error_Sample_Period)
			}
			else{
				clearQueue(document.all.error_Sample_Period)
			}
			<CFIF GetAllContractInfo.Growth_Min_Purchase><!--- Only if template setting is ON --->
			if(document.all.Min_Purchase_Requirement.checked && trim(document.all.Min_Purchase_Value.value).length == 0) {
				ErrorCount++;
				queueMessage("The Minimum $ Purchase is check marked, therefore you must enter a minimum dollar purchase amount in order to continue", document.all.Err_Sp_Growth_Min_Purchase)
			}
			else {
				clearQueue(document.all.Err_Sp_Growth_Min_Purchase)
			}
			</CFIF>
			if(trim(document.all.Tier_Count.value).length == 0){
				ErrorCount++;
				queueMessage("How many tiers will this component have?", document.all.error_TierCount)
			}
			else{
				clearQueue(document.all.error_TierCount)
			}
			for(var z=0; z<rangeStartCollection.length; z++){
				tempStart		= eval("document.all."+rangeStartCollection[z])
				tempStart_Span	= eval("document.all.error_"+rangeStartCollection[z])

				tempEnd			= eval("document.all."+rangeEndCollection[z])
				tempEnd_Span	= eval("document.all.error_"+rangeEndCollection[z])

				tempSum			= eval("document.all."+rangeLumpsumCollection[z])
				tempSum_Span	= eval("document.all.error_"+rangeLumpsumCollection[z])
				//range start
				if(trim(tempStart.value).length == 0) {
					ErrorCount++;
					queueMessage("Enter the range start for this tier.", tempStart_Span)
				}
				else{
					clearQueue(tempStart_Span)
				}
				//range end
				if(trim(tempEnd.value).length == 0) {
					ErrorCount++;
					queueMessage("Enter the range end for this tier.", tempEnd_Span)
				}
				else{
					clearQueue(tempEnd_Span)
					}
				//sum
				if(trim(tempSum.value).length == 0) {
					ErrorCount++;
					queueMessage("Enter a <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> for this tier.", tempSum_Span)
				}
				else{
					clearQueue(tempSum_Span)
				}

			}
			if(trim(document.all.Claim_Mech.value).length == 0){
				ErrorCount++;
				queueMessage("This component does not have any claim mechanics to display.")
			}
			else{
				clearQueue(tempSum_Span)
			}
			if(ErrorCount==0) {
				if(verifyRanges() == true)
				{
				<cfif donotallowaddproductsDE EQ 1>
					if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
					{
						document.all.deletedateexclusions.value = 1;
				</cfif>
				document.all.newComponentForm.submit();
				<cfif donotallowaddproductsDE EQ 1> }</CFIF>
				}
				else showMessageWindow()
			}
			else{
				showMessageWindow()
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
	</script>

	<CF_MessageWindow>

<BLOCKQUOTE>
<blockquote>
<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 65px; top: 0px;"></cfif>
<cfif url.EZTemplate EQ 0>
<cfinclude template="minimal_contract_info.cfm">
</cfif>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>

	<FORM ACTION="Contract_Discount_Growth_Add_Component_Action.cfm" METHOD="post" NAME="newComponentForm" ID="newComponentForm">
  <cfoutput><input type="hidden" name="bAllowAddComp" value="#bAllowAddComp#" /></cfoutput>
	<cfset arAllowList = ArrayNew(1) />
	<cfset bTemplateLevelComponentFilter = 1 />
	<!------ Operating Group ----->
	<cfset componentsUnderOperatingGroupLevel2 = "" />
	<cfif appSettings.getOperatingGroupOn()>
		<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
		<cfset programLevel2Level 				= operatingGroupManager.getProgramLevel2Level() />
		<!------ Get the operating group for this program ----->
		<cfset operatingGroupProgramLevel2 	= operatingGroupManager.getProgramOperatingGroupID(level=programLevel2Level, programId=FORM.Contract_Main_ID) />
		<cfset qGetComponentsUnderOperatingGroupLevel2 = operatingGroupManager.getComponents(operatingGroupProgramLevel2, 4) />
		<cfset componentsUnderOperatingGroupLevel2 = ValueList(qGetComponentsUnderOperatingGroupLevel2.Component_ID) />
		<cfset arAllowList[ArrayLen(arAllowList) + 1] = componentsUnderOperatingGroupLevel2 />
		<cfset bTemplateLevelComponentFilter = 0 />
	</cfif>
	<cfif bTemplateLevelComponentFilter>
		<!--- get a list of comps to filter based on template --->
		<cfset qComponents = templateManager.getAllTemplateDiscountComponents(GetSettings.ProgramControl_Panel_Options_ID, 4, 1) />
		<cfset lTemplateAllowList = ValueList(qComponents.Component_ID) />
	</cfif>

	<!--- D45016 :: Restrict access at component level for all discount types START--->
	<cfquery name="getAllGrowthComponentsAccess" datasource="#application.datasource#">
			SELECT 	*
			FROM		Program_Growth_Component_Profile
			WHERE	Deleted = 0
			AND 		Profiles_ID = #request.AccessStructure.Profiles_ID#
	</cfquery>
	<cfset restictList = valuelist(getAllGrowthComponentsAccess.Program_Growth_Component_Name_ID)>
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
	<cfset qCompGrowth = compGrowth.getActive(arAllowList,URL.excludeList) />
	<input type="hidden" name="Component_Name" id="Component_Name" value="<cfoutput>#form.Component_Name#</cfoutput>">

	<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput>#Application.GrowthLabel#</cfoutput></LEGEND><!--- 29856:labels for Fixed Price, Rebate, Lump Sum, Growth --->
	<TABLE WIDTH="100%" CELLPADDING="3" CELLSPACING="0" BORDER="0">
		<TR>
			<TD VALIGN="TOP" WIDTH="500">
			<TABLE "100%" CELLPADDING="3" CELLSPACING="0" BORDER="0" ALIGN="LEFT">
		<TR>
			<TD ALIGN="right" NOWRAP><span ID="error_Name"></span>&nbsp;<B>Component Name:</B></TD>
			<TD>&nbsp; </TD>
			<TD>
				<cfoutput>
					<select name="Growth_Component_Name_ID" id="Growth_Component_Name_ID" style="width:240px" onChange="javascript:changeEvent(this, document.all.Component_Name)">
						<option value="-1">Select <cfoutput>#Application.GrowthLabel#</cfoutput> Component</option> <!--- 29856:labels for Fixed Price, Rebate, Lump Sum, Growth --->
						<cfloop query="qCompGrowth">
							<option value="#Program_Growth_Components_Name_Id#" <cfif (qCompGrowth.Program_Growth_Components_Name_Id EQ FORM.Growth_Component_Name_ID) or (qCompGrowth.recordCount eq 1) >selected</cfif>>#Program_Growth_Components_Name#
								<cfif application.returned_customer_setting.external_id_on EQ 1>
									<cfif Len(External_ID) GT 0>
										(#External_ID#)
									 </cfif>
								</cfif>
								<cfif len(trim(Allowance_Code_Number))>
									- (#Allowance_Code_Number#)
								</cfif>
							</option>
						</cfloop>
					</select>
					<cfloop query="qCompGrowth">
						<input type="hidden" name="Growth_GL_Account_ID_#Program_Growth_Components_Name_ID#" value="#GL_Account_ID#">
					</cfloop>
				</cfoutput>
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right" NOWRAP><span ID="error_Desc"></span>&nbsp;<B>Component Description:</B></TD>
			<TD>&nbsp; </TD>
			<TD>
				<CFOUTPUT>
					<TEXTAREA COLS="56" ROWS="" NAME="Component_Description" onPaste="javaScript: return textareaChecklength(#Component_Description_Max_Length#, this);"  onkeyPress="javaScript: return textareaChecklength(#Component_Description_Max_Length#, this);">#replace(trim(FORM.Component_Description),"&##44",",","ALL")#</TEXTAREA>
				</CFOUTPUT>
			</TD>
		</TR>
<!---D46874 :: New Growth Option (Growth Calculation) START --->
	<cfif GetAllContractInfo.Growth_Auto_Pay>
		<TR>
			<TD ALIGN="right" NOWRAP><span ID="error_Gcal"></span>&nbsp;<B>Growth Calculation:</B></TD>
			<TD>&nbsp; </TD>
			<TD>
				<select name="Growth_Calculation">
					<option value="0">Select Growth Calculation</option>
					<option value="1" <cfif FORM.Growth_Calculation EQ 1>SELECTED</cfif>>Entire Program</option>
					<cfif NOT appSettings.getBBAutoPayDisablePayEach()>
					<option value="2" <cfif FORM.Growth_Calculation EQ 2>SELECTED</cfif>>Each Distributor</option>
					</cfif>
					<cfif appsettings.getPayeeFromPlanningGroups() eq 1>
					<option value="3" <cfif FORM.Growth_Calculation EQ 3>SELECTED</cfif>>Each Planning Group</option>
					</cfif>
				</select>
			</TD>
		</TR>
	</cfif>
<!---D46874 :: New Growth Option (Growth Calculation) END --->
		<TR>
			<TD ALIGN="right"><span ID="error_Multi"></span><B>Rate:</B></TD>
			<TD>&nbsp;</TD>
			<TD>
				<input NAME="rate_type" TYPE="radio" VALUE="1" CHECKED> Retroactive Rate
					<cf_SmallHelp width="400">
						<TABLE ALIGN ="LEFT">
							<TR>
								<TD>
									These rates will pay back to case one once the target volume tier(s) have been attained.
								</TD>
							</TR>
						</TABLE>
					</cf_SmallHelp>
				<cfif GetSettings.Allow_Growth_Multi_Rate EQ 1 AND GetAllContractInfo.Growth_Auto_Pay EQ 0>
					<input NAME="rate_type" TYPE="radio" VALUE="2" <cfif form.Rate_Type IS 2>checked</cfif>>Bracket Rate
						<cf_SmallHelp displayShifyX="-150" width="400">
							<TABLE>
								<TR>
									<TD>
										These rates apply to all volume within the specified volume bracket listed only.
									</TD>
								</TR>
							</TABLE>
						</cf_SmallHelp>
				</cfif>
			</TD>
		</TR>
		<TR>

		<!---Show this option only if growth options are on and this option in particular is selected--->
		<!---Growth Options--->
	<!---If growth options are on, go to new first page--->
<!--- D35731 Growth Auto Pay --->
	<cfif appSettings.getGrowthExpansion1() AND GetAllContractInfo.Growth_Auto_Pay EQ 0>
		<cfif GetSettings.Allow_Volume_Pool_Seperation IS 1>
			<TR>
				<TD ALIGN="right"><B>Separate Volume Pool:</B></TD>
				<TD>
					<cf_SmallHelp width="400">
						<TABLE>
							<TR>
								<TD>
									Volume pool separation allows you to establish your tiers based on one set of items, while awarding the discounts to a different set of items.
									You cannot have a bracket rate program with a separate volume pool.
								</TD>
							</TR>
						</TABLE>
					</cf_SmallHelp>
				</TD>
				<TD>
					<cfif Seperate_Volume_Pool IS 1>
						<input type="hidden" name="Seperate_Volume_Pool" value="1">Yes
					<cfelseif Seperate_Volume_Pool IS 0>
						<input type="hidden" name="Seperate_Volume_Pool" value="0">No
					<cfelse>
						<input name="Seperate_Volume_Pool" type="checkbox" value="1">
					</cfif>
				</TD>
			</TR>
			<!---<TR>--->
		</cfif>
	</cfif>

	<tr valign="top">
		<TD ALIGN="right" nowrap style="padding-top:5px;"><B>Paid To:</B></TD>
		<TD>
	<cfoutput>
		<cfif EzButton_Disable EQ 1 and getsettings.EZprogram_editcomponent EQ 1>
		<font color="red">[</font> <a onClick="JavaScript: openPopup('ezprogram_editcomponent.cfm?programid=#GetContractInfo.contract_main_id#&discounttypeid=4&PaidTo=#form.Comp_Paid_To#&ProgramType_ID=#CSLGetContractInfo.ProgramType_ID#&compid=#FORM.Growth_Component_Name_ID#&Growth_Auto_Pay=#GetAllContractInfo.Growth_Auto_Pay#', 300, 200)" STYLE="cursor: pointer;">edit</A>
		<font color="red">]</font>
		<cfelse>&nbsp;</cfif>
		</cfoutput>
		</TD>
		<TD>
		<!--- "Paid to" radio buttons --->
		<cfdiv bind="url:component_paid_to.cfm?Component_Name_ID={Growth_Component_Name_ID}&ModifyDeletedPrograms=#ModifyDeletedPrograms#&ContractMainID=#GetContractInfo.contract_main_id#&Discount_Type_ID=4&ProgramType_ID=#CSLGetContractInfo.ProgramType_ID#&Is_a_Revision=#CSLGetContractInfo.Is_a_Revision#&GrowthSelectedCompPaidTo=#form.Comp_Paid_To#" bindOnLoad="true" ID="paidToInfo" />
			<cfif CSLGetContractInfo.Is_a_Revision eq 1 and RevisionSettings.Pay_To_Component eq 2><input name="Component_Paid_To" type="hidden" value="<cfoutput>#form.Comp_Paid_To#</cfoutput>"></cfif>
		</TD>
	</tr>

	<cfif appSettings.getDollarGrowth() IS 1>
		<cfset ShowDollar = 1>
	<cfelse>
		<cfset ShowDollar = 0>
	</cfif>

		<TD ALIGN="right"><B>Component Unit of Measure:</B></TD>
		<TD>&nbsp; </TD>
		<TD>
			<cfif getComponentInfo.component_uom NEQ "" AND getComponentInfo.component_uom NEQ 0>
				<cfset defaultselected = 0>
			<cfelse>
				<cfset defaultselected = 1>
			</cfif>

				<cf_uom_dropdown
					company_main_id			=	""
					default_option_on		=	""
					default_option_text		=	""
					setDefaultSelected 		=	"#defaultselected#"
					default_option_value	=	"0"
					dropdown_name			=	"component_uom"
					option_text_abbreviated	=	""
					plural_uom_display		=	"1"
					product_type_id			=	""
					program_template_id		=	"#GetAllContractInfo.ProgramType_ID#"
					selected_uom_id			=	"#getComponentInfo.component_uom#"
					text_before_tag_close	=	" onChange=""showPercent(this)"""
					uom_id_exclusion_list	=	"5,6,7"
					uom_id_inclusion_list	=	""
					show_dollar				= 	"1">	<!--- D35731 Growth Auto Pay // REPLACED #show_dollar# with 1 as we want to display $ option all the time not based on APP setting.--->

			</TD>
		</TR>
				<cfset AllGrowthComparisonPeriodUOM = CompGrowth.getGrowthComparisonPeriodUOM()>
		<!---Only show this if component_uom IS 3 (percent)."Program_Growth_Comparison_Period_UOM" exists to choose between volume and sales dollars for growth tiers--->
		<TR ID="TR_Percent_UOM" <cfif (getComponentInfo.component_uom NEQ 3 AND getComponentInfo.component_uom NEQ "") OR (getComponentInfo.component_uom EQ "" AND GetAllContractInfo.RateTypeDefault NEQ 3)>style="display: none"</cfif>>
			<TD ALIGN="right" valign="top"><B>Comparison Period UOM:</B></TD>
			<TD>&nbsp; </TD>
			<TD>
			 <cfset SelectedGrowthComparisonPeriodUOM = getComponentInfo.Program_Growth_Comparison_Period_UOM_ID>
			<cfoutput query="AllGrowthComparisonPeriodUOM">
				<input type="radio" name="Program_Growth_Comparison_Period_UOM" value="#AllGrowthComparisonPeriodUOM.Program_Growth_Comparison_Period_UOM_ID#" <cfif SelectedGrowthComparisonPeriodUOM neq "" AND AllGrowthComparisonPeriodUOM.Program_Growth_Comparison_Period_UOM_ID neq SelectedGrowthComparisonPeriodUOM>Disabled="Disabled"</cfif><cfif AllGrowthComparisonPeriodUOM.Program_Growth_Comparison_Period_UOM_ID is FORM.Program_Growth_Comparison_Period_UOM>checked</cfif>> #Program_Growth_Comparison_Period_UOM#
			</cfoutput>
			</TD>
		</TR>
		<TR ID="TR_Percent" <cfif (getComponentInfo.component_uom NEQ 3 AND getComponentInfo.component_uom NEQ "") OR (getComponentInfo.component_uom EQ "" AND GetAllContractInfo.RateTypeDefault NEQ 3)>style="display: none"</cfif>>
			<TD ALIGN="right" valign="top"><B>Comparison Period:</B></TD>
			<TD><span ID="error_Comparison_Type"></span>
			<span ID="error_Sample_Period"></span></TD>
			<TD>
			<input type="radio" name="Comparison_Type" value="1" <cfif Comparison_Type IS 1 OR GetAllContractInfo.Growth_Auto_Pay EQ 0>checked</cfif>> Same period, prior year
				<!--- D35731 Growth Auto Pay START--->
			<span <cfif GetAllContractInfo.Growth_Auto_Pay EQ 1> style="display: none"</cfif>>
			<Br>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <strong>OR</strong><Br>
			<input type="radio" name="Comparison_Type" value="2" <cfif Comparison_Type IS 2>checked</cfif>>  <input type="text" size="5" maxlength="5" name="Sample_Period" value="<cfoutput>#Sample_Period#</cfoutput>"> Days before program start date
			</span>
				<!--- D35731 Growth Auto Pay END--->
			</TD>
		</TR>
		<!---FILTER: handle for payment cycle if it's turned on--->
		<cfif appSettings.getPaymentCycleAtDiscountType()>

			<cfset PaymentCycleManager = CreateObject("component", "components.programs.PaymentCycleManager") />
			<!--- <cfset FORM.PaymentCycle = PaymentCycleManager.getPaymentCycle(FORM.Contract_Main_ID, 4, FORM.Comp_Name_ID) /> --->
			<cfset FORM.PaymentCycle_Is_Locked = PaymentCycleManager.isPaymentCycleLocked(FORM.Contract_Main_ID, 4, FORM.Comp_Name_ID) />

			<TR><span id ="Err_Sp_PaymentCycle">
				<TD ALIGN="right"><B>Payment Cycle:</B></TD>
				<TD>&nbsp; </TD>
				<TD>
				<cfparam name="URL.PaymentCycle" 	default="">
				<cfparam name="FORM.PaymentCycle" 	default="#URL.PaymentCycle#">
				<!--- D35731 Growth Auto Pay --->
				<cf_payment_cycle_selection
					Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
					Program_ID = "#FORM.Contract_Main_ID#"
					discount_Type_ID = "4"
					Selected_Payment_Cycle_ID = "#FORM.PaymentCycle#"
					Component_ID = "#URL.Component_ID#"
					Growth_Auto_Pay  = "#GetAllContractInfo.Growth_Auto_Pay#"
					>
					<!--- Dev Note: Kal; 12047: DisableOnRevision is removed.
						Template revison setting controls whether payment cycle is disabled or not on revison --->
				<input type="hidden" name="hiddenPaymentCycle" value="<cfoutput>#FORM.PaymentCycle#</cfoutput>">
				</TD>
			</TR>

			<!---if the payment cycle is locked then disable the dropdoown--->
			<cfif FORM.PaymentCycle_Is_Locked eq 1>
				<script>
					document.all.PaymentCycle.disabled = true;
				</script>
			</cfif>
			<cfoutput>
				<input type="hidden" name="Comp_Name_ID" value="#FORM.Comp_Name_ID#" />
			</cfoutput>

		</cfif>

		<!--- Minimum $ Purchase --->
		<CFIF GetAllContractInfo.Growth_Min_Purchase><!--- Only if template setting is ON --->
			<TR>
				<TD ALIGN="right"><B>Minimum $ Purchase:</B></TD>
				<TD>&nbsp; </TD>
				<TD><span id ="Err_Sp_Growth_Min_Purchase"></span>
				<cfparam name="URL.Min_Purchase_Requirement" 	default="">
				<cfparam name="FORM.Min_Purchase_Requirement" 	default="#URL.Min_Purchase_Requirement#">
				<cfparam name="URL.Min_Purchase_Value" 	default="">
				<cfparam name="FORM.Min_Purchase_Value" 	default="#URL.Min_Purchase_Value#">
				<input type="checkbox" name="Min_Purchase_Requirement" id="Min_Purchase_Requirement" value="1" <cfif FORM.Min_Purchase_Requirement EQ "1">checked</cfif>
					onclick="if(this.checked) {document.all.Min_Purchase_Value.disabled = false} else {document.all.Min_Purchase_Value.disabled = true};">
				<cfoutput>
				<input type="text" name="Min_Purchase_Value" id="Min_Purchase_Value" size="10" maxlength="20"
						ONKEYUP="clenseText(this, '.0123456789');" <cfif FORM.Min_Purchase_Requirement EQ 0>disabled<cfelse>value="#Form.Min_Purchase_Value#"</cfif>>
				</cfoutput>
				</TD>
			</TR>
		</CFIF>
	</TD>
	</TR>
	<TR>
		<TD ALIGN="right"><B>How Many Tiers:</B></TD>
			<TD>&nbsp; </TD>
		<TD><span ID="error_TierCount"></span>&nbsp;<input TYPE="Text" NAME="Tier_Count" SIZE="3" onKeyUp="if(this.value==0 || this.value>10){this.value=''}clenseText(this, '0123456789'); parseInt(buildTierOutlines(this.value))" VALUE="<CFOUTPUT>#FORM.Tier_Count#</CFOUTPUT>"></TD>
	</TR>
	</TABLE>
	</TD>
	<TD valign="top" ALIGN="LEFT">
	<TABLE WIDTH="100%" CELLPADDING="3" CELLSPACING="0" BORDER="0" valign="top" ALIGN="LEFT">
<!--- BJF 13410 Component information in discount pages --->
	<tr>
		<td colspan="100%">
			<cfdiv bind="url:component_information.cfm?Component_Name_ID={Growth_Component_Name_ID}&ModifyDeletedPrograms=#ModifyDeletedPrograms#&Growth_Auto_Pay=#GetAllContractInfo.Growth_Auto_Pay#&Discount_Type_ID=4&ProgramType_ID=#CSLGetContractInfo.ProgramType_ID#&ClaimMechanics=#Form.Claim_Mechanics#&Is_A_Revision=#CSLGetContractInfo.Is_a_Revision#&EligibleRecordCount=#GetPaymentTypesforTemplate.Recordcount#&GL_Account_ID=#Form.GL_Account_ID#&Vendor_Master_ID=#Form.Vendor_Master_ID#&VendorSelection=#Form.VendorSelection#&caller=Growth&Payee_Selection=#Form.Payee_Selection#&programId=#FORM.Contract_Main_ID#" ID="compInfo"/>
		</TD>
	</tr>
	</table>
	</TD>
	</TR>
	</TABLE>
</FIELDSET>

<hr ALIGN="left" COLOR="orange" style="width:818px;padding-left:5px">


<FIELDSET STYLE="padding:10px; width: 500px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Component Tiers</LEGEND>

	<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
		<FONT COLOR="Red"><B>To indicate no upper limit use asterisk (*)
		</B></FONT>
	</TD>
	</TD>
	</TR>
	</TABLE>
	<TABLE ID="oTierTable" CLASS="Maintable" WIDTH="85%" CELLPADDING="3" CELLSPACING="0" BORDER="0">
		<TR BGCOLOR="#FFCE84" VALIGN="bottom">
			<TD ID="header" ALIGN="center"><B>Tier</B></TD>
			<TD ID="header" WIDTH="67" NOWRAP><B>Range Start</B></TD>
			<TD WIDTH="1">&nbsp;</TD>
			<TD ID="header" WIDTH="60"><B>Range End</B></TD>
			<!---<cfif appSettings.getBonusInGrowthSwitch()> ---> <!--- 43234 Growth Template Settings --->
			<cfif GetSettings.Bonus_Field eq 1>
			<TD ID="header"><B><cfoutput>#Application.BonusLabel#</cfoutput></B></TD>
			<cfelse>
				<TD ID="header">&nbsp;</TD>
			</cfif>
		</TR>
	</table>
</FIELDSET>
<br><br>

<cfoutput><a href="##" style="margin-left:50px;cursor:pointer" onclick="javascript:validateForm();">#application.util.string.actionLinkFormat2("continue")#</a></cfoutput>

<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0></div></cfif>
<CFPARAM NAME="getTiers.Recordcount" DEFAULT="0">

<CFIF getTiers.Recordcount GT 0>
	<CFOUTPUT QUERY="getTiers">
		<input TYPE="hidden" NAME="Tier_#getTiers.Tier_Number#_ID" VALUE="#getTiers.Program_Growth_Component_Tier_ID#">
	</CFOUTPUT>
</CFIF>

<input type="hidden" name="Action" value="url.Action">
<input type="hidden" name="CID" value="<cfoutput>#url.CID#</cfoutput>">
<input TYPE="hidden" NAME="Component_ID" VALUE="<CFOUTPUT>#URL.Component_ID#</CFOUTPUT>">
<input TYPE="hidden" NAME="Program_ID" VALUE="<CFOUTPUT>#URL.Program_ID#</CFOUTPUT>">
<input TYPE="hidden" NAME="deletedateexclusions" value="0">
<input type="hidden" name="EZTemplate" value="<cfoutput>#url.EZTemplate#</cfoutput>">
<input type="hidden" name="Auto_Pay_Status" value="">
<input type="hidden" name="Vendor_Selection" value="true">
<input type="hidden" name="AllowSave"  value="#FORM.AllowSave#">
</FORM>
<cfif url.EZTemplate EQ 0>
</blockquote>
</BLOCKQUOTE>
</cfif>

<script>
    function changeEvent(thisSelectObj, ComponentNameObj) {
        ComponentNameObj.value = thisSelectObj.options[thisSelectObj.selectedIndex].text;
    }
</script>
</BODY>
</HTML>
