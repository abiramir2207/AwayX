
<cfoutput>
<cfparam name="url.LSComponentID" default="0">

<!--- The was added for D18299 -Anand Rao 05-Mar-09 --->
<cfparam name="url.EZTemplate" default="0">
<cfparam name="FORM.allowNegative" default = "false" />

<cfset appSettings = application.appSettingsGet />
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<cfset PaymentCycleManager = CreateObject("component", "components.programs.PaymentCycleManager") />
<cfset RevisionSettingsManager = CreateObject("component", "components.programs.Display_Program.revision_settings") />

<CFSET PAGE_TITLE= "#Application.LumpsumLabel# Component Edit">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<script type="text/javascript" src="/script/tTip.js"></script>
	<link rel="stylesheet" href="/styles/tTip.css" type="text/css" />
	<cfinclude template="/common_files/jQuery.cfm">
</HEAD>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" ONLOAD="">

<CFQUERY NAME="getAllLumpSums" datasource="#application.datasource#">
	SELECT 	Program_Lump_Sums.*,
			Program_Lump_Sum_Name.Program_Lump_Sum_Name,
			Program_Lump_Sum_Name.External_ID,
      Program_Lump_Sum_Name.Samples_Related,
	       Program_Lump_Sum_Name.allow_negative,
			Payment_Type.Payment_Type_Name,
			ISNULL(Allowance_Code.Allowance_Code_Number, 0) AS Allowance_Code_Number,
			Program_Lump_Sums.Program_ID,
			Program_Lump_Sums.Program_Lump_Sum_ID,
			Payment_Type.Payment_Type_ID,
			Program_Lump_Sum_Name.Related_to_Equipment,
			Program_Lump_Sum_Name.Equipment_Value,
			Program_Lump_Sum_Name.Allow_Broker_Payee
	FROM 	Program_Lump_Sums
			INNER JOIN Program_Lump_Sum_Name ON
			Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
			LEFT JOIN Payment_Type
			ON Payment_Type.Payment_Type_ID = Program_Lump_Sums.Claim_Mechanics
			LEFT JOIN Allowance_Code ON
			Allowance_Code.Allowance_Code_ID = Program_Lump_Sum_Name.Allowance_Code_ID
			AND Allowance_Code.Deleted = 0
	WHERE 	Program_Lump_Sums.Program_Lump_Sum_ID = '#url.LSComponentID#'
			ORDER BY Program_Lump_Sum_Name.Program_Lump_Sum_Name, Program_Lump_Sums.Lump_Sum_Description
</CFQUERY>

<cfset Form.Contract_Main_ID = getAllLumpSums.Program_ID>
<cfset CSL_Contract_Main_ID = Form.Contract_Main_ID>
<cfinclude template="/common_files/contracts/commonqueries.cfm">
<cfinclude template="/common_files/contracts/discount_queries.cfm">
<!--- ooooooooooooooooooooooooooooooooo --->
<!---<cfset variables.bHideFromLSAutoPay = 0>--->
<cfif (variables.bHideFromLSAutoPay or appSettings.getBBAutoPayLumpSum()) and len(getAllLumpSums.Vendor_Master_Id) EQ 36>
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
		<CFQUERY NAME="getPayeeName" datasource="#application.datasource#">
			SELECT Vendor_Name
			FROM 	Vendor_Master
			WHERE	Vendor_Master_Id = '#getAllLumpSums.Vendor_Master_Id#'
		</CFQUERY>
	</cfif>
	<cfset variables.VendorName = getPayeeName.Vendor_Name>
<cfelse>
	<cfset variables.VendorName = "">
</CFIF>
<cfquery name="GetContractInfo" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Main
		WHERE Contract_Main_ID = '#CSL_Contract_Main_ID#'
	</cfquery>

<cfquery name="GetSettings" datasource="#application.datasource#">
	SELECT 	*
	FROM	Program_Control_Panel_Options
	WHERE 	ProgramControl_Panel_Options_ID = (SELECT ProgramType_ID FROM Contract_Main WHERE Contract_Main_ID = '#Form.Contract_Main_ID#')
</cfquery>

<cfset RevisionSettings = RevisionSettingsManager.getRevisionSettings(templateId = GetSettings.ProgramControl_Panel_Options_ID,profilesID = request.AccessStructure.Profiles_ID, ContractMainID = #Form.Contract_Main_ID#)>
<cfinclude template="/get_access_profile.cfm">
<cfset ModifyDeletedPrograms = CreateObject("component","components.programs.program").ModifyDeletedProgram(CSL_Contract_Main_ID,Get_Profile_Settings.Modify_Expired_Programs) />


<cf_cryp type="en" key="#request.key#" string="#form.contract_main_ID#">
<cfset url.CID = cryp.value>

<!---There are max or min values for lump sum--->
<cfif len(trim(GetSettings.Min_Lump_Sum)) GT 0 AND GetSettings.Min_Lump_Sum NEQ 0>
	<cfset Use_Min_Lump_Sum = 1>
	<cfset MinLumpSum = GetSettings.Min_Lump_Sum>
<cfelse>
	<cfset Use_Min_Lump_Sum = 0>
</cfif>
<!--- MAX LUMP SUM --->
<cfif len(trim(GetSettings.Max_Lump_Sum)) GT 0 AND GetSettings.Max_Lump_Sum NEQ 0>
	<cfset Use_Max_Lump_Sum = 1>
	<cfset MaxLumpSum = GetSettings.Max_Lump_Sum>
<cfelse>
	<cfset Use_Max_Lump_Sum = 0>
</cfif>
<!--- MIN LUMP SUM --->
<cfif len(trim(GetSettings.Min_Lump_Sum)) GT 0 AND GetSettings.Min_Lump_Sum NEQ 0>
	<cfset Use_Min_Lump_Sum = 1>
	<cfset MinLumpSum = GetSettings.Min_Lump_Sum>
<cfelse>
	<cfset Use_Min_Lump_Sum = 0>
</cfif>

<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 60px; top: 10px;">

<CFQUERY NAME="getProgramInfo" datasource="#application.datasource#">
	SELECT	Units_of_Measure.Unit_Of_Measure_Desc,
			Units_of_Measure.Abbreviation,
			Contract_Main.Contract_Quantity
	FROM 	Contract_Main
			INNER JOIN Units_of_Measure ON
			Contract_Main.Contract_Quantity_UOM_IDX = Units_of_Measure.Unit_Of_Measure_ID
	WHERE	Contract_Main.Contract_Main_ID = '#FORM.Contract_Main_ID#'
</CFQUERY>


<CFSET Lump_Desc_Max_Length = 765>
<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/common_files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT>
	LumpSumAmounts = new Array();
	LumpSumAmountToAvoid = -1;
	function saveNewLumpSum()
	{
		var ErrorCount = 0
		var ExistsComponent = 0;

		<!---TSF - Label 15077: Commenting this out since we are no longer letting components to be changed when editing
		<cfif not appSettings.getDisableAddingComponentsOnRevision() AND not GetContractInfo.Is_A_Revision>
		if(document.all.Program_Lump_Sum_Name_ID.selectedIndex < 0)
		{
			ErrorCount++;
			queueMessage("You must select a <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> name", document.all.error_Name);
		}
		else
		{
			clearQueue(document.all.error_Name);
		}
		</cfif>
		--->
		<cfif appSettings.getBBAutoPayLumpSum()>

			if (document.all.Vendor_ID) {
				if(document.all.Vendor_ID.value == "0")
					{
						queueMessage("Select a Payee", document.all.Err_Sp_Vendor);
						ErrorCount++;
					}
				else
					{
						clearQueue(document.all.Err_Sp_Vendor);
					}
			}

		</cfif>
		//Amt
    //   Added the below if condition for D18299 - Anand Rao, 05-Mar-09
    <cfif NOT(getAllLumpSums.Samples_Related EQ 1)  AND  getAllLumpSums.Related_to_Equipment EQ 0>
  		if(document.all.new_lump_sum_amount.value.length == 0 || document.all.new_lump_sum_amount.value == 0  || isNaN(document.all.new_lump_sum_amount.value))
  		{
  			ErrorCount++;
  			queueMessage("You must enter a dollar amount greater than 0 for the <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>", document.all.error_Amt);
  		}
  		else
  		{
  			clearQueue(document.all.error_Amt);
  		}
		</cfif>

		/*If it is auto pay, and operator or broker, the vendor id is required.
				If it is auto pay and includes distributor and doesn't have id, then let them know
				about the manual allocation of vendors on the auto billbacks
		only bother with any of this if it's auto pay */
		/*
		if(document.NewLumpSum.Auto_Pay_Status.value == 1)
		{
			if(document.NewLumpSum.Vendor_Master_ID.value.length < 1 || document.NewLumpSum.Vendor_Master_ID.value == 0)
			{
				{
					var fourthOption;
					fourthOption = 0;
					if (document.NewLumpSum.Component_Paid_To[3])
					{
						if (document.all.Component_Paid_To[3].checked)
						{
							fourthOption = 1;
						}
					}

					if ((fourthOption == 1) || (document.all.Component_Paid_To[0].checked == 1))
					{
						alert("You must select a vendor for the auto payments.")
						return false;
					}
					else
					{
						alert("You must select a vendor for auto pay components not payable to distributor")
						return false;
					}
				}
			}
		}
		*/

		<cfif appsettings.getGL_Account_On() IS 1 AND appsettings.getGL_Account_Required_for_Comp() IS 1>
			//if a component doesn't have a GL Account associated with it then the GL Account drop down won't display.
			//So to determine if a user didn't select a GL Account we have to make sure that the drop down exists.
			var bGLAccountOption = 0;
			var oSelectTags = document.getElementsByTagName("SELECT");
			if (oSelectTags != null)
			{
				for (i=0; i<oSelectTags.length; i++)
				{
					if(oSelectTags.item(i).name == "GL_Account_ID")
					{
						bGLAccountOption = 1;
					}
				}
			}
			if (bGLAccountOption == 1 && ErrorCount == 0 && (document.all.GL_Account_ID.value == 0 || document.all.GL_Account_ID.value == null))
			{
				alert("You must select a <cfoutput>#Application.GLAccountLabel#</cfoutput> for this component");//D42774
				return false;
			}
		</cfif>

		<!------ [Deepa]: No need to check here for minimum, because the minimum is at program level, so a user can create more tham 1 component and meet the minimum ----->

		<!------ [Deepa]: Could check for maximum even though the maximum is at program level, because if a component crosses max, at pgm level also it crosses max.----->
		<!---Max lump sum amount--->
    //  Added the below if condition for D18299 - Anand Rao, 05-Mar-09
    //  Do not check for the max or min value if the Samples_Related is set to 1
    <cfif NOT(getAllLumpSums.Samples_Related EQ 1) AND  getAllLumpSums.Related_to_Equipment EQ 0>
  		<cfif Use_Max_Lump_Sum IS 1>
  			if(document.all.new_lump_sum_amount.value > <cfoutput>#MaxLumpSum#</cfoutput>)
  			{
  				ErrorCount++;
  				queueMessage("You must enter a dollar amount less than or equal to <CFOUTPUT>#lscurrencyformat(MaxLumpSum)#</CFOUTPUT>", document.all.error_Amt);
  			}
  			else
  			{
  				clearQueue(document.all.error_Amt);
  			}
  		</cfif>
  		<!--- MIN LUMP SUM AMOUNT --->
  		<cfif Use_Min_Lump_Sum IS 1>
  			if(document.all.new_lump_sum_amount.value < <cfoutput>#MinLumpSum#</cfoutput>)
  			{
  				ErrorCount++;
  				queueMessage("You must enter a dollar greater than or equal to <CFOUTPUT>#lscurrencyformat(MinLumpSum)#</CFOUTPUT>", document.all.error_Amt);
  			}
  			else
  			{
  				clearQueue(document.all.error_Amt);
  			}
  		</cfif>
  </cfif>
		var Contract_Quantity = <cfoutput>#GetContractInfo.Contract_Quantity#</cfoutput>;

		<cfif appSettings.getPaymentCycleAtDiscountType()>
			<!------ check for payment cycle ----->
			if(document.all.PaymentCycle.value == "0")
			{
				queueMessage("Select a payment cycle", document.all.Err_Sp_PaymentCycle1);
				ErrorCount++;
			}
			else
			{
				clearQueue(document.all.Err_Sp_PaymentCycle1)
			}
		</cfif>

		//if(document.all.new_lump_sum_description.value.length > <CFOUTPUT>#Lump_Desc_Max_Length#</CFOUTPUT>)
		var lsDescLen = jQuery("textarea[name=new_lump_sum_description]").val();
		if(lsDescLen.length > <CFOUTPUT>#Lump_Desc_Max_Length#</CFOUTPUT>)

		{
			ErrorCount++;
			queueMessage("Description cannot be longer than <CFOUTPUT>#Lump_Desc_Max_Length#</CFOUTPUT> characters", document.all.error_Desc);
		}
		else
		{
			clearQueue(document.all.error_Desc);
		}

		var LumpSumAmountTotal = 0


		if(ErrorCount==0)
		{

			for(var n=0; n<LumpSumAmounts.length; n++)
			{
				if(n != LumpSumAmountToAvoid)
				{
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
				actionpage = "select_lumpsum_products.cfm?CID=#URL.CID#&EZTemplate=#url.EZTemplate#";
			<!------ <cfelseif GetSettings.Discount_Lump_Sums_Distributor_Mandated EQ 1>
				actionpage = "select_lumpsum_distributors.cfm?CID=#URL.CID#&EZTemplate=#url.EZTemplate#";  ----->
			</cfif>
			}
			</cfoutput>
			document.all.NewLumpSum.action = actionpage;

			//TSF: Label 10675 - No longer validating for volume
			<!---if(LumpSumAmountTotal != BIAmount)
			{
				if(confirm("The total volume you have entered ("+ LumpSumAmountTotal +" <CFOUTPUT>#getProgramInfo.Unit_Of_Measure_Desc#</CFOUTPUT>) does not equal the volume entered in the basic information page.      ("+BIAmount+" <CFOUTPUT>#getProgramInfo.Unit_Of_Measure_Desc#</CFOUTPUT>)"))
				{
					<cfif donotallowaddproductsDE EQ 1>
					if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
					{
						document.all.deletedateexclusions.value = 1;
						document.all.NewLumpSum.submit();
					}
					else
					{
						return false;
					}
					<cfelse>
					document.all.NewLumpSum.submit();
					</cfif>
				}
				else
				{
					document.all.new_lump_sum_amount.focus()
				}
			}
			else
			{
				document.all.NewLumpSum.submit();
			}--->
			document.all.NewLumpSum.submit();
		}
		else
		{
			showMessageWindow();
		}
	}


	function checkSampleRelated(thisObj)
	{
		var current 		= 	thisObj.selectedIndex;
	/*	Start - If there are lumpsum components available in the select box */
		if(current != undefined && current != -1)
		{
		var curobjVal		= thisObj.options[current].value;
		var currentObjID	= 	thisObj.options[current].id;
		if (curobjVal != 0)
		{
			var negativeAllowed = eval("document.all.negativeAllowed_"+curobjVal+".value");
			//document.all.allowNegative = negativeAllowed;
 			 if (negativeAllowed == "1")
			{
			negativeAllowed = true;
			}
			else{
			negativeAllowed = false;
			}
			alert("negativeAllowed :" + negativeAllowed);
			$('.numeric').numeric( { negative: negativeAllowed }, function() {} );
			document.all.allowNegative.value = negativeAllowed;
		}
		var trObj1 	= document.all.ls_amount;
		var trObj2 	= document.all.ls_volume;
		var frmObj1 = document.all.new_lump_sum_amount;
		var frmObj2	= document.all.new_lump_sum_volume;

		//Check for Samples only if template setting is On for products required
 		<cfif GetSettings.Discount_Lump_Sums_Item_Mandated EQ 1>
			// alert(currentObjID);
			if(currentObjID == 1){
				//if (frmObj1.value == ""){frmObj1.value = "0";}
				//if (frmObj2.value == ""){frmObj2.value = "0";}
				frmObj1.value = "0";
				frmObj2.value = "0";
				frmObj1.disabled = true;
				frmObj2.disabled = true;
				trObj1.disabled = true;
				trObj2.disabled = true;
			}
			else{
				frmObj1.disabled = false;
				frmObj2.disabled = false;
				trObj1.disabled = false;
				trObj2.disabled = false;
			}
 		</cfif>
		} /*	End - If there are lumpsum components available in the select box */
	}	// end: function checkSampleRelated()

	//TSF: Label 10675 - Modifications to samples
	window.onload=init;
	function init()
	{
		checkSampleRelated(document.all.Program_Lump_Sum_Name_ID);
	}

	function validateDescription(maxLen, obj)
	{
		// check if the text has exceeded the limit.
		var validLen = textareaChecklength(maxLen, obj);
		if(validLen)
		{
			// check for any exclude list characters.
			var validKey = true;
			var disallowKeyList = "'\"";
			if(event.type.toLowerCase() == "paste")
			{
				if(window.clipboardData)
				{
					var clipBoardText = window.clipboardData.getData("Text");
					return Disallow_Key_List_In_String(clipBoardText, disallowKeyList);
				}
			}
			else
			{
				validKey = Disallow_Key_List(disallowKeyList);
			}
			return validKey;
		}
		else
		{
			return false;
		}
		return true;
	}
</SCRIPT>

<CF_MessageWindow>
<Br>

<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
<CFOUTPUT><FORM ACTION="Contract_Discount_Lump_Sums_Save_New_Lump_Sum.cfm" METHOD="post" NAME="NewLumpSum" ID="NewLumpSum"></CFOUTPUT>

<FIELDSET STYLE="padding:10px; width: 700px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;"> <cfoutput>#Application.LumpsumLabel#</cfoutput> Component Information</LEGEND>
<!------ <div id="Layer3" style="position:absolute; width: 250px; height: 100px; z-index: 1; left: 400px; top: 50px"> ----->

<!------ </div> ----->
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
	<cfset arAllowList[ArrayLen(arAllowList) + 1] = lTemplateAllowList />
</cfif>
<TABLE ID="oLumpSumTable" BORDER="0">
	<cfset arAllowListLen = ArrayLen(arAllowList) />
	<cfquery name="GetLSNames" datasource="#application.datasource#">
		SELECT 	Program_Lump_Sum_Name,
				Program_Lump_Sum_Name_ID,
				Samples_Related,
				External_ID,
				Allow_Negative,
				Allowance_Code.Allowance_Code_Number, Allowance_Code.Allowance_Code_Desc
		FROM 	Program_Lump_Sum_Name

		LEFT JOIN Allowance_Code
		ON		Allowance_Code.Allowance_Code_ID = Program_Lump_Sum_Name.Allowance_Code_ID

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

		<!--- BJF D11631 - only allow one ls component per program regardless of payee --->
		<Cfif appSettings.getLumpSumComponentInProgram() EQ 1>
		AND Program_Lump_Sum_Name_ID NOT IN (SELECT Program_Lump_Sum_Name_ID FROM Program_Lump_Sums WHERE Program_ID = '#FORM.Contract_Main_ID#' AND Deleted = 0)
		OR Program_Lump_Sum_Name_ID = '#getAllLumpSums.Program_Lump_Sum_Name_ID#'
		</CFIF>
		order by Program_Lump_Sum_Name
	</cfquery>
	<cfloop query="GetLSNames">
		<cfoutput>
			<input type="hidden" id="negativeAllowed_#getLSNames.Program_Lump_Sum_Name_ID#" name="negativeAllowed_#getLSNames.Program_Lump_Sum_Name_ID#" value="#getLSNames.Allow_Negative#" />
		</cfoutput>
	</cfloop>
	<Input type="hidden" name="allowNegative" id= "allowNegative">

	<TR valign="top">
		<TD ALIGN="right" nowrap>
			<B>Component:</B><SPAN ID="error_Name"></SPAN>&nbsp;
		</TD>
		<TD>
			<!------ external id ----->
			<!--- Dev Note: KAL; 9896: Lumpsum page to handle for samples --->
			<!---Tim Ford - Label 14758: If it's a revision and the getDisableAddingComponentsOnRevision() app setting is on then don't allow the
			lump sum component name to change--->
			<cfoutput>
			#getAllLumpSums.Program_Lump_Sum_Name#
			<cfif application.returned_customer_setting.external_id_on EQ 1>
				<cfif Len(getAllLumpSums.External_ID) GT 0>
					(#getAllLumpSums.External_ID#)
				</cfif>
			</cfif>
			<cfif trim(getAllLumpSums.Allowance_Code_Number) neq 0> - (#getAllLumpSums.Allowance_Code_Number#)</cfif>
			</cfoutput>
			<input type="hidden" name="Program_Lump_Sum_Name_ID" value="<cfoutput>#getAllLumpSums.Program_Lump_Sum_Name_ID#</cfoutput>">

			<!---
			<cfset disableLumpSumComponent = "" />
			<cfif appSettings.getDisableAddingComponentsOnRevision() AND GetContractInfo.Is_A_Revision>
				<input type="hidden" name="Program_Lump_Sum_Name_ID" value="<cfoutput>#getAllLumpSums.Program_Lump_Sum_Name_ID#</cfoutput>">
				<cfset disableLumpSumComponent = "disabled" />
			</cfif>
			<cfoutput>
			<select name="Program_Lump_Sum_Name_ID" style="width:240px" onChange="checkSampleRelated(this);" onFocus="checkSampleRelated(this);" #disableLumpSumComponent#>
				<cfloop query="GetLSNames">
					<!--- Storing the value of samples related in the ID and passing to Javascript to validate if amount should be disabled or not --->
					<option value="#Program_Lump_Sum_Name_ID#" id="#samples_related#" <cfif getAllLumpSums.Program_Lump_Sum_Name_ID EQ GetLSNames.Program_Lump_Sum_Name_ID>selected</cfif>>#Program_Lump_Sum_Name#
						<cfif application.returned_customer_setting.external_id_on EQ 1><cfif Len(External_ID) GT 0> (#External_ID#)</cfif></cfif>
						<cfif len(trim(Allowance_Code_Number))> - (#Allowance_Code_Number#)</cfif>
					</option>
				</cfloop>
			</select>
			</cfoutput>
			--->
		</TD>
	</TR>
	<tr>
		<td>&nbsp;</td>
		<td>
			<!---********************************************************************************************************************************
			**********************************************Component Information Start************************************************************
			*********************************************************************************************************************************--->
			<table border="0" cellpadding="3" cellspacing="0" width="100%" valign="top">
				<tr BGCOLOR="eeeeee" colspan="2" >
					<td STYLE="border-top:solid 1px blue;" colspan="2">
						Component Details
					</td>
				</tr>
				<tr>
					<td valign="top" colspan="2" class="topborder">
						<cfset disabled = 0>
						<cfparam name="FORM.ClaimMechanic" 	default="#CSLGetContractInfo.ClaimMechanics#">
						<cfif appSettings.getClaims_at_Comp_Level() AND GetPaymentTypesforTemplate.Recordcount GT 0>
							<cf_claim_mechanic_selection
								Default_Claim_Selection = "#getAllLumpSums.Claim_Mechanics#"
								Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
								Component_Name_ID = "#getAllLumpSums.Program_Lump_Sum_Name_Id#"
								Edit_Selection = "#getAllLumpSums.Claim_Mechanics#"
								Is_Revision = "#CSLGetContractInfo.Is_a_Revision#"
								disabled = "#disabled#"
								Allow_Auto_Payment = "#appSettings.getBBAutoReport()#"
								Discount_Type_ID = "3"
								Allow_Off_Invoice = "0">
						<cfelse>
							<cfoutput><input type="hidden" name="Claim_Mechanics" value="#getAllLumpSums.Payment_Type_ID#"></cfoutput>
						</cfif>
					<!--- Dev Note: WR 78635 - If "vendor" is a payee on the template, the "paid to" should be distributor. Do not show users any option to search. --->
						<cfif NOT variables.bHideFromLSAutoPay and NOT variables.bvendorOnlyProgram>
							<cfdiv bind="url:claim_mech_info.cfm?Claim_Mechanics_ID={Claim_Mechanics}&ModifyDeletedPrograms=#ModifyDeletedPrograms#&Discount_Type_ID=3&Caller_Split_For_Auto_Pay=#trim(getAllLumpSums.Split_For_Auto_Pay)#&bHideFromLSAutoPay=#variables.bHideFromLSAutoPay#&FormName=NewLumpSum&Vendor_Master_Id=#getAllLumpSums.Vendor_Master_Id#&cfdebug=1&Caller=LumpSum&Business_Segment_ID=#GetContractInfo.Business_Segment_ID#" ID="ClaimMech"/>
						</cfif>
					</td>
				</tr>
				<cfif appSettings.getGL_Account_On()>
					<cfset qGetFiscalDatesforYear = queryNew("") />
						<!--- Dev Note:- (44811)  Removed the join on the fiscal_year as both "template date types" (Free form and Fiscal year)
						use contract dates to pick the GL.
						--->
						<cfquery name="qGetFiscalDatesforYear" datasource="#application.datasource#">
						SELECT
							Contract_Start_Date,
							Contract_End_Date,
							CM.Fiscal_Year
						FROM Contract_Main CM
						WHERE CM.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#CSL_Contract_Main_ID#" />
							AND CM.Deleted = 0
						</cfquery>
					<!--- GL query --->
					<cfquery name="GetGLs" datasource="#application.datasource#">
						SELECT GL_Account.GL_Account_ID,
									 Gl_Account,
									 GL_Account_Desc
						FROM GL_Account
						INNER JOIN GL_Component_Mapping ON GL_Component_Mapping.GL_Account_ID = GL_Account.GL_Account_ID
						AND GL_Component_Mapping.Component_Name_ID = '#getAllLumpSums.Program_Lump_Sum_Name_ID#'
						AND GL_Component_Mapping.Discount_Type_ID = '3'
						--AND DateDiff(d, GL_Account.Start_Date, '#qGetFiscalDatesforYear.Contract_Start_Date#') >= 0
						--AND DateDiff(d, GL_Account.End_Date, '#qGetFiscalDatesforYear.Contract_End_Date#') <= 0
						AND <cfqueryparam cfsqltype="CF_SQL_DATE" value="#qGetFiscalDatesforYear.Contract_Start_Date#" /> >= GL_Account.Start_Date
						AND <cfqueryparam cfsqltype="CF_SQL_DATE" value="#qGetFiscalDatesforYear.Contract_Start_Date#" /> <= GL_Account.End_Date
						ORDER BY GL_Account
					</cfquery>
					<!--- GL drowndown --->
					<tr>
						<td colspan="2"  style="topborder">
							<cfif GetGLs.Recordcount GT 1>
								<select name="GL_Account_ID">
									<option value="0">*** PICK A <cfoutput>#Application.GLAccountLabel#</cfoutput> ***</option><!---D42774 --->
										<cfloop query="GetGLs">
											<option value="#GL_Account_ID#" <cfif GL_Account_ID eq getAllLumpSums.GL_Account_ID>selected</cfif>>#GL_Account# (#GL_Account_Desc#)</option>
										</cfloop>
								</select>
							<cfelseif GetGLs.Recordcount EQ 1>
								<cfoutput>GL: #GetGLs.GL_Account_Desc# (#GetGLs.GL_Account#)</cfoutput>
								<input type="hidden" name="GL_Account_ID" value="<cfoutput>#GetGLs.GL_Account_ID#</cfoutput>">
							<cfelse>
								No GL for this component
								<input type="hidden" name="GL_Account_ID" value="0">
								<!--- There are GLs for the comp --->
							</cfif>
						</td>
					</tr>
				<cfelse>
					<input type="hidden" name="GL_Account_ID" value="0">
				</cfif>
			</table>
			<!---********************************************************************************************************************************
			**********************************************Component Information End**************************************************************
			*********************************************************************************************************************************--->
		</td>
	</tr>
			<!---check to see if we can select Paid To: Distributor, Operator or both based on Template Generic Type--->
			<cfscript>
				GetPaymentPaidToTypes = templateManager.GetPaymentPaidToTypes(CSLGetContractInfo.ProgramType_ID,3,getAllLumpSums.Program_Lump_Sum_Name_ID,0,getAllLumpSums.Allow_Broker_Payee);
			</cfscript>
			<!--- Dev Note: WR 78635 - If "vendor" is a payee on the template, then hide "paid to". 
			"Paid to" is actually vendor, but in the database, we save it as distributor. --->			
			<cfif variables.bvendorOnlyProgram eq 0>
			<tr valign="top">
				<TD ALIGN="right" nowrap>
					<B>Paid To:</B>&nbsp;<br>
				</TD>
				<td>
					<cfif variables.bHideFromLSAutoPay>
							<input type="text" name="paidToName" size="30" value="#variables.VendorName#" readonly="true"/><strong><font color="red">[ </font>
							<a href="##" onClick="searchVendor();">select payee</a>
							<font color="red">  ]</font></strong><SPAN ID="Err_Sp_Vendor"></SPAN>
					<cfelse>
						<cfloop query="GetPaymentPaidToTypes">
							<input name="Component_Paid_To" type="Radio" <cfif CSLGetContractInfo.Is_a_Revision eq 1 and RevisionSettings.Pay_To_Component eq 2>disabled</cfif> value="<cfoutput>#Payment_Paid_To_ID#</cfoutput>" <cfif getAllLumpSums.Component_Paid_To eq Payment_Paid_To_ID>checked</cfif>><cfoutput>#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = Payment_Paid_To_Type_Identifier, paidToDesc=Payment_Paid_To_Type_Name)#</cfoutput><br>
						</cfloop>
						<cfif CSLGetContractInfo.Is_a_Revision eq 1 and RevisionSettings.Pay_To_Component eq 2><input name="Component_Paid_To" type="hidden" value="<cfoutput>#getAllLumpSums.Component_Paid_To#</cfoutput>"></cfif>
						<Input type="hidden" name="paidToName" value="#variables.VendorName#" disabled="1">
					</cfif>

				</td>
			</tr>
			</cfif>

<!--- D37295 Kraft Equipment LS set up --->
<cfif getAllLumpSums.Related_to_Equipment>
<tr valign="top">
				<td align="right" nowrap><b>Quantity:</b>&nbsp;<br></td>
				<td>
				<input name="quantity" type="text" maxlength="50" value="#getAllLumpSums.quantity#" style="width:75px" onkeyup="clenseText(this, '0123456789, ');populateAmount();"  id="quantityvalue">
				<input name="equipmentPrice" type="hidden" value="#getAllLumpSums.Equipment_Value# " id="equipmentPrice">
				</td>
			</tr>
</cfif>
<!--- D37295 Kraft Equipment LS set up --->
	<TR valign="top" id="ls_amount">
		<TD ALIGN="right" nowrap><B><span id="amount_each">Amount<cfif appSettings.BB_Auto_Pay_Lump_Sum eq "1"> Each</cfif></span><!---29963--->:</B><SPAN ID="error_Amt"></SPAN>&nbsp;</TD>
		<TD>
		    <!--- Round the Lump_Sum_Amount to two decimal places for D18299 - Anand Rao 05-Mar-09
				Really???  3 lines of code to decimal format a number???
		    <cfset Lump_Sum_Amount_Formated = getAllLumpSums.Lump_Sum_Amount * 100>
		    <cfset Lump_Sum_Amount_Formated = Round(Lump_Sum_Amount_Formated )>
		    <cfset Lump_Sum_Amount_Formated = Lump_Sum_Amount_Formated / 100>
		    --->
			 <cfset Lump_Sum_Amount_Formated = NumberFormat( getAllLumpSums.Lump_Sum_Amount, ".99" ) />
			 <cfif getAllLumpSums.Allow_negative EQ 0>
			 	<cfset negAllowed = false />
			<Cfelse>
			<cfset negAllowed = true />

			 </cfif>
		   <!---<INPUT TYPE="text" NAME="new_lump_sum_amount" value="#Lump_Sum_Amount_Formated#"
		   			<cfif getAllLumpSums.Samples_Related EQ 1>readonly<cfelse>onClick="checkSampleRelated(document.all.Program_Lump_Sum_Name_ID);" onKeyUp="clenseText(this, '.0123456789');allowonlytwodecimalplaces(this)" </cfif>>--->
				<cfif appSettings.BB_Auto_Pay_Lump_Sum eq "1">		<!---29963--->
	   		<table width="400" border="0" cellspacing="0" cellpadding="0">
			    <tr>
			        <td width=125>
			        	<!--- D37295 Kraft Equipment LS set up --->
						<cfif getAllLumpSums.Related_to_Equipment>
						<input type="text" disabled="true" value="#NumberFormat(getAllLumpSums.amount_each_payment, ".99" )#" NAME="amount_each_period_clone">
						</cfif>

						<input TYPE=<cfif getAllLumpSums.Related_to_Equipment>"hidden"<cfelse>"text"</cfif> NAME="amount_each_period" id="amount_each_period" class="numeric" value="#NumberFormat(getAllLumpSums.amount_each_payment, ".99" )#"
							onClick="checkSampleRelated(document.all.Program_Lump_Sum_Name_ID);"
							onKeyUp="$('.numeric').numeric( { negative: #negAllowed# }, function() {} ); allowonlytwodecimalplaces(this)"
							>
						<!--- D37295 Kraft Equipment LS set up --->
			        </td>
			        <td width=25>
			        	<span id="help_small_1" onmouseout="popUpTip(event,'tLSAmount');" onmouseover="popUpTip(event,'tLSAmount');">
					    	<img src="/images/help_small.gif" />
					    </span>
					   <div id="tLSAmount" class="tip">
					   		For Lump Sum Components with a Payment Type that "Is Auto Pay", the amount represents how much will be paid "EACH" pay period.
					   </div>
			        </td>
			        <td width=100 align="right" >
			        	<div id='tdTotalDesc'>
			        		<B>Amount Total:</B>
						</div>
			        </td>
			        <td width=100 >
			        	<div id='tdTotalVal'>
			        		<div id='div_new_lump_sum_amount'><cfoutput>#getAllLumpSums.Lump_Sum_Amount#</cfoutput></div>
							<input type='hidden' name='new_lump_sum_amount' id='new_lump_sum_amount' value='#Lump_Sum_Amount_Formated#' readonly title='Total payment based on the each amount, payment cycle, and program span.  For non-autopay payment cycle, the total and each amount is always the same.'/>
						</div>
			        </td>
			    </tr>
			</table>
				<cfelse>
				<!--- D37295 Kraft Equipment LS set up --->
   					<INPUT TYPE=<cfif getAllLumpSums.Related_to_Equipment>"hidden"<cfelse>"text"</cfif> class="numeric" NAME="new_lump_sum_amount" value="#Lump_Sum_Amount_Formated#"
					<cfif getAllLumpSums.Samples_Related EQ 1>readonly<cfelse>onClick="checkSampleRelated(document.all.Program_Lump_Sum_Name_ID);"
					onKeyUp="$('.numeric').numeric( { negative: #negAllowed# }, function() {} );allowonlytwodecimalplaces(this)" </cfif>><!--- clenseText(this, '.0123456789'); --->
				</cfif>
	   </TD>
	</TR>
<!--- 	<cfif NOT variables.bHideFromLSAutoPay>
	<TR valign="top" id="ls_volume">
		<TD ALIGN="right" nowrap><B>Volume:</B><SPAN ID="error_Volume"></SPAN>&nbsp;</TD>
		<TD>
			<INPUT TYPE="text" NAME="new_lump_sum_volume" value="#getAllLumpSums.Lump_Sum_Volume#" <cfif getAllLumpSums.Samples_Related EQ 1>readonly<cfelse>onClick="checkSampleRelated(document.all.Program_Lump_Sum_Name_ID);" onKeyUp="clenseText(this, '0123456789');"</cfif>>
				&nbsp;<CFOUTPUT>#getProgramInfo.Unit_Of_Measure_Desc#</CFOUTPUT>
			</TD>
	</TR>
	<cfelse>
		<INPUT TYPE="hidden" NAME="new_lump_sum_volume" value="0"/>
	</cfif> --->
	<INPUT TYPE="hidden" NAME="new_lump_sum_volume" value="0"/>
	<cfif appSettings.getPaymentCycleAtDiscountType() AND variables.bHideFromLSAutoPay EQ 0>

		<cfquery name="GetCurrentPaymentCycle" datasource="#application.datasource#">
			SELECT	DISTINCT Payment_Cycle_ID
			FROM	Program_Payment_Cycle
			WHERE 	Program_ID = '#form.Contract_Main_ID#'
			AND 	Discount_Type_ID = 3
			AND 	Component_ID = '#getAllLumpSums.Program_Lumps_Sum_Ext_ID#'
			AND 	Deleted = 0
		</cfquery>

		<TR valign="top">
			<TD align="right" nowrap>
				<B>Payment Cycle:</B><SPAN ID="Err_Sp_PaymentCycle1"></SPAN>&nbsp;
			</TD>
			<TD>
				<table width="400" border="0" cellspacing="0" cellpadding="3">
				    <tr>
				        <td width=125>
				        	<cf_payment_cycle_selection
								Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
								Program_ID = "#FORM.Contract_Main_ID#"
								Selected_Payment_Cycle_ID = "#GetCurrentPaymentCycle.Payment_Cycle_ID#"
								discount_Type_ID = "3"
							>
						</td>
					<cfif appSettings.BB_Auto_Pay_Lump_Sum eq "1">		<!---29963--->
				        <td width=25>
				        	<div id="spinner" style="display: none;">
								 <image src='/Images/loading_red.gif' />
							</div>
				        </td>
				        <td width=100 align="right" >
				        	<div id='tdCountDesc'>
				        		<B>Payment Count:</B>
							</div>
				        </td>
				        <td width=100 >
				        	<div id='tdCountVal'>
				        		<div id='div_periodCount'><cfoutput>#getAllLumpSums.Payment_Count#</cfoutput></div>
							</div>
				        </td>
				  </cfif>
       		<input type='hidden' name='periodCount' id='periodCount' value='#getAllLumpSums.Payment_Count#' readonly title='Read Only.  Update the Each amount or the Payment Cycle.'/>
				    </tr>
				</table>
			</TD>
		</TR>
	<cfelse>
		<cfparam name="FORM.PaymentCycle" default="8"> <!--- 8 = Upon Due	 --->
		<cfoutput><input type="hidden" name="PaymentCycle" value="#FORM.PaymentCycle#"></cfoutput>
	</cfif>

<!--- 	<cfparam name="FORM.ClaimMechanic" 	default="#CSLGetContractInfo.ClaimMechanics#">
	<cfif appSettings.getClaims_at_Comp_Level() AND GetPaymentTypesforTemplate.Recordcount GT 0>
		<TR valign="top">
			<TD align="right" nowrap><B>Claim Mechanism</B>:</B><SPAN ID="Err_Sp_ClaimMech"></SPAN>&nbsp;</TD>
			<TD>
			<cf_claim_mechanic_selection
			Default_Claim_Selection = "#getAllLumpSums.Claim_Mechanics#"
			Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
			Edit_Selection = "#FORM.ClaimMechanic#"
			Is_Revision = "#CSLGetContractInfo.Is_a_Revision#"
			disabled = "#disabled#">
			</TD>
		</TR>
	<cfelse>
		<cfoutput><input type="hidden" name="Claim_Mechanics" value="#getAllLumpSums.Payment_Type_ID#"></cfoutput>
	</cfif> --->

	<TR valign="top">
		<TD ALIGN="right" nowrap>
			<B>Description:</B><SPAN ID="error_Desc"></SPAN>&nbsp;
		</TD>
		<TD nowrap>
			<CFOUTPUT><TEXTAREA COLS="50" ROWS="" NAME="new_lump_sum_description" onPaste="javaScript: return validateDescription(#Lump_Desc_Max_Length#, this);"  onkeyPress="javaScript: return validateDescription(#Lump_Desc_Max_Length#, this);">#getAllLumpSums.Lump_Sum_Description#</TEXTAREA></CFOUTPUT>
			&nbsp;
			<span id="new_lump_sum_save" style="visibility:visible";>
				<B><FONT COLOR="FF0000">[</FONT>
			<a HREF="##" onClick="saveNewLumpSum(); return false;">save <cfoutput>#Application.LumpsumLabel#</cfoutput> component</a>
			<B><FONT COLOR="FF0000">]</FONT></B></span>
		</td>
	</TR>
</table>
</FIELDSET>
<input type="hidden" name="AllowSave" value="">
<input type="hidden" name="Auto_Pay_Status" value="">
<input TYPE="Hidden" NAME="Program_ID" VALUE="#cryp.value#">
<input TYPE="Hidden" NAME="component_id" VALUE="#url.LSComponentID#">
<input TYPE="Hidden" NAME="update" VALUE="1">
<input TYPE="Hidden" NAME="payment_locked" VALUE="0">
<input TYPE="Hidden" NAME="deletedateexclusions" VALUE="0">
<input type="hidden" name="FromPopup" value="1">
<input type="hidden" name="Vendor_Selection" value="true">
<input type="hidden" name="FieldName" value="Vendor_ID">
<cfif variables.bHideFromLSAutoPay>
	<input type="hidden" name="Vendor_ID" value="0">
</cfif>
<input type="hidden" name="bvendorOnlyProgram" value="#variables.bvendorOnlyProgram#" />
</FORM>
	<script>

	searchVendor =  function()
		{
			NewWindow('/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?RebateRecipient_On=1&Formname=NewLumpSum&ReloadForm=0&FieldName=Vendor_ID&PageSource=ComponentInformation', 'VendorSearch', '800', '600', 'yes', 'yes')
		}

	</script>
</cfoutput>
<script type="text/javascript" src="/Common_Files/contracts/contract_Discount_Lump_Sums.js"></script>

<cfoutput>
	<script type="text/javascript">
			var Contract_Start_Date = '#GetContractInfo.Contract_Start_Date#';
			var Contract_End_Date = '#GetContractInfo.Contract_End_Date#';

			jQuery('input,select,textarea').bind({
		         focus: function() { jQuery(this).addClass('hilight'); }
		        ,blur: function() { jQuery(this).removeClass('hilight'); }
		    });

			jQuery('##amount_each_period').keyup(calc);
			jQuery('##PaymentCycle').change( calc );

			function calc() {
				calcPeriods(Contract_Start_Date,Contract_End_Date);
			}

			fade_count_and_total();  /*29963*/
	function populateAmount(){
		var Amount = document.getElementById('equipmentPrice').value * document.getElementById('quantityvalue').value;
		var newAmount = Amount.toFixed(2);
		document.getElementById('amount_each_period').value= newAmount;
		document.getElementById('amount_each_period_clone').value= newAmount;
	}
</SCRIPT>
</cfoutput>
<script type="text/javascript" src="/Script/javascript/jquery.numeric.js"></script>
