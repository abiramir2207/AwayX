<DOCTYPE HTML>
<html>
<head>
	<title>Edit Component Information</title>
	<style>
	h4 {
		border-bottom: 1px solid blue;
		background-color: orange;
		width: 99%;
		padding: 0 0 0 7px;
		font-weight: bold;
		font-size: 1.1em;
		margin:12px 0;
	}
	.hidden {
		display: none;
	}
	body {
		padding-left: 5px;
	}
	#dnld907 {
		margin:0 7px;
	}
	</style>
</head>
<body>
<cfparam name="url.ProgramType_ID" default="0">
<cfparam name="url.PaidTo" default="0">
<cfparam name="url.discounttypeid" default="0">
<cfparam name="url.programid" default="0">
<cfparam name="url.Formname" default="">
<cfparam name="url.GL_Account_ID" default="0">
<cfparam name="form.GL_Account_ID" default="0">
<cfparam name="url.copNameIndx" default="0">
<cfparam name="form.command" 	default="">
<cfparam name="url.compid" default="0"> <!--- really comp name id --->
<cfparam name="url.Claim_Mechanics" default="">
<cfparam name="url.FixedComponentList" default="">
<cfparam name="url.ThisFixedComponent" default="">
<cfparam name="url.Vendor_Master_ID" default="0"><!--- Only get this if it's auto pay --->
<cfparam name="url.VendorSelection" default="0">
<cfparam name="form.VendorSelection" default="0">
<cfparam name="url.PaymentCycle" default="">
<cfparam name="form.PaymentCycle" default="">
<cfparam name="FORM.AllowSave" default="0">
<cfparam name="URL.bHideFromLSAutoPay" default="0">
<cfparam name="url.Payee_Selection" default="0">
<cfparam name="form.Payee_Selection" default="0">
<cfparam name="url.priceListID" default="0">
<cfparam name="url.download" default="0">
<cfparam name="url.Business_Segment_ID" default="0">
<cfparam name="url.Is_A_Revision" default="0">
<cfparam name="ModifyDeletedPrograms" default="1">
<cfparam name="forceRunBlendedSP" default="0">
<cfparam name="form.from_date" default="">
<cfparam name="form.to_date" default="">
<cfparam name="url.IsSecondComponent" default="0">

<cfinclude template="/get_access_profile.cfm">

<cfquery name="GetSettings" datasource="#application.datasource#">
	SELECT Base_Sales_Equal_To_Lowest_Bracket, Program_Date_Type
	FROM Program_Control_Panel_Options
	WHERE ProgramControl_Panel_Options_ID = '#url.ProgramType_ID#'
</cfquery>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset ProgramManager = CreateObject("component", "components.programs.ProgramManager") />
<cfset RevisionSettingsManager = CreateObject("component", "components.programs.Display_Program.revision_settings") />
<cfset RevisionSettings = RevisionSettingsManager.getRevisionSettings(templateId = url.ProgramType_ID,profilesID = request.AccessStructure.Profiles_ID, ContractMainID=url.programid)>

<!--- <cfset appSettings = genSettingsManager.get()> --->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<cfset UsePriceBracket = 0>
<cfif appSettings.getUseFixedPriceType()>
	<!--- If the user can edit the price bracket AND template setting "Base_Sales_Equal_To_Lowest_Bracket" is OFF --->
	<cfif Get_Profile_Settings.Edit_Price_Bracket eq 1 AND GetSettings.Base_Sales_Equal_To_Lowest_Bracket eq 0>
	    <!--- For fixed price --->
	    <cfif url.discounttypeid eq 1>
		<cfset UsePriceBracket = 1>
	    </cfif>
	</cfif>
</cfif>

<cfif UsePriceBracket eq 1>
	<!--- Get all the brackets --->
	<cfset bracketList = ProgramManager.getAllPriceListBrackets()>
</cfif>

<!--- Query for component level information --->
<cfset compInfo = CreateObject("component","components.programcomponents.programcomponents") />
<cfset CompDetails = compInfo.GetComponentDetails(url.compid, url.discounttypeid)>

<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<Cfif url.discounttypeid EQ 1>
	<cfinclude template="Contract_Discount_Fixed_Component_Functions.cfm" />
</Cfif>
		<!------ Redirect to next page ----->

		<!--- <cfset templateManager.updatecomponentpaidto(form.Component_Paid_To,url.discounttypeid,url.compid,url.programid)> --->
<cfif form.command EQ "save">
		<cfset donotupdatepaidto =  templateManager.updatecomponentpaidto(form.Component_Paid_To,url.discounttypeid,url.compid,url.programid)>

			<!--- Dev Note(079237) update the "paid to" for the 2nd component as well. --->
				<cfquery name="getSecondComponent" datasource="#application.datasource#">
					SELECT	Include_Second_Component,Second_Component_Name_ID
					FROM	Program_Fixed_Component_Name
					WHERE	Program_Fixed_Component_Name_ID = #url.compid#
				</cfquery>

				<cfif getSecondComponent.Include_Second_Component EQ 1 AND getSecondComponent.Second_Component_Name_ID GT 0>
					<cfset templateManager.updatecomponentpaidto(form.Component_Paid_To,url.discounttypeid,getSecondComponent.Second_Component_Name_ID,url.programid)>
				</cfif>

	<!--- If the option "Pay each entity individually" or "Pay custom combinations" is selected, delete the selected vendor (if any) --->
	<cfif form.VendorSelection eq 2 OR form.VendorSelection eq 3>
			<cfset form.Vendor_Master_ID = 0>
	</cfif>
<!---62343 8.0 - Blended Rate, CF START--->
	<cfif appSettings.get_Setting('Blended_Rate') eq '1' AND CompDetails.rebate_type EQ 7 AND url.discounttypeid EQ 2>
		<cfquery name="BlendedDates" datasource="#application.datasource#">
			SELECT Calculation_Period_Start,Calculation_Period_End
			FROM Program_Rebates_Component PRC
			WHERE PRC.Program_ID = #url.programid#
			AND PRC.Deleted = 0
		</cfquery>
			<cfif (form.from_date NEQ dateformat(BlendedDates.Calculation_Period_Start,'m/d/yyyy')) OR (form.to_date NEQ dateformat(BlendedDates.Calculation_Period_End,'m/d/yyyy'))>
				<cfset forceRunBlendedSP = 1>
			<cfelse>
				<cfset forceRunBlendedSP = 0>
			</cfif>
	</cfif>
<!---62343 8.0 - Blended Rate, CF END--->
		<cfif donotupdatepaidto EQ "true" and form.Component_Paid_To NEQ url.PaidTo AND form.GL_Account_ID EQ url.GL_Account_ID>
		<cfelse>
		<script>
		<cfoutput>
			<!--- for rebate --->
			<cfif url.discounttypeid EQ 2>
				opener.document.#url.Formname#.compPaidTo_#url.copNameIndx#.value = '#form.Component_Paid_To#';
				opener.document.#url.Formname#.Vendor_Master_ID_#url.copNameIndx#.value = '#form.Vendor_Master_ID#';
				opener.document.#url.Formname#.VendorSelection_#url.copNameIndx#.value = '#form.VendorSelection#';
				opener.document.#url.Formname#.GL_Account_ID_#url.copNameIndx#.value = '#form.GL_Account_ID#';
				opener.document.#url.Formname#.Claim_Mechanics_#url.copNameIndx#.value = '#form.Claim_Mechanics#';
				opener.document.#url.Formname#.PaymentCycle_#url.copNameIndx#.value = '#form.PaymentCycle#';
				opener.document.#url.Formname#.Payee_Selection_#url.copNameIndx#.value = '#form.Payee_Selection#';
				opener.document.#url.Formname#.Force_Run_Blended_Vol_#url.copNameIndx#.value = '#forceRunBlendedSP#'; <!---62343--->
				opener.document.#url.Formname#.Blended_Start_Date_#url.copNameIndx#.value = '#form.from_date#'; <!---62343--->
				opener.document.#url.Formname#.Blended_End_Date_#url.copNameIndx#.value = '#form.to_date#'; <!---62343--->
				opener.document.#url.Formname#.action.value = 'updSave';
				opener.document.#url.Formname#.submit();
		    <!--- for fixed price --->
	    		<cfelseif url.discounttypeid EQ 1>
				<cfset ThisFixedComponent = form.ThisFixedComponent>
				<cfset ThisFixedComponent = setGL_Account_ID(ThisFixedComponent, form.GL_Account_ID)>
				<cfset ThisFixedComponent = setVendor_Master_ID(ThisFixedComponent, form.Vendor_Master_ID)>
				<cfset ThisFixedComponent = setVendorSelection(ThisFixedComponent, form.VendorSelection)>
				<cfset ThisFixedComponent = setClaimMechanics(ThisFixedComponent, form.Claim_Mechanics)>
				<cfset ThisFixedComponent = setPaymentCycle(ThisFixedComponent, form.PaymentCycle)>
				<cfset ThisFixedComponent = setComponentPaidTo(ThisFixedComponent, form.Component_Paid_To)>
				<cfset ThisFixedComponent = setPayeeSelection(ThisFixedComponent, form.Payee_Selection)>
				<cfset FixedComponentList = ListSetAt(form.FixedComponentList, url.copNameIndx, ThisFixedComponent, ",")>
				opener.document.#url.Formname#.FixedComponentList.value = '#FixedComponentList#';
				<cfif UsePriceBracket eq 1>
						opener.document.#url.Formname#.priceListID.value = '#form.priceListID#'
				</cfif>
				opener.document.#url.Formname#.submit();
			<cfelse>
				window.opener.location.reload();
			</cfif>
		</cfoutput>
    			window.close();
		</script>
		<cfabort>
		</cfif>
</cfif>

			<cfscript>
				GetPaymentPaidToTypes = templateManager.GetPaymentPaidToTypes(url.ProgramType_ID,url.discounttypeid,url.compid);
			</cfscript>
<cfoutput>

<form name="editcomponentform" action="ezprogram_editcomponent.cfm?copNameIndx=#url.copNameIndx#&programid=#url.programid#&discounttypeid=#url.discounttypeid#&PaidTo=#url.PaidTo#&ProgramType_ID=#url.ProgramType_ID#&Formname=#url.Formname#&compid=#url.compid#" style="display:inline;" method="post">
<h4>#CompDetails.Component_Name#</h4>
<table width="100%" border="0" cellpadding="10"  cellspacing="10">
<!--- <tr><td STYLE="border-bottom:solid 1px blue; background-color: orange;" align="center" colspan="2"><B>Edit Component Information:</B><br></td></tr> --->
<input name="AllowSave" type="hidden" value="#FORM.AllowSave#">
<input type="hidden" name="Vendor_Selection" value="true">
<input type="hidden" name="PayeeOptionSelected" value="true">
<!--- Bracket (price list id) --->
<cfif UsePriceBracket eq 1>
<tr>
	<td align="right" valign="top" nowrap>Price Bracket(Program):</td>
	<td>
		<select name="priceListID">
			<cfloop query="bracketList">
				<!--- Dev Note: drachala; D28504: Update bracket drop down list to remove price list ID  START
                Changed/Added: Added Query to get Price_list_id based on "Bracket" and check if that list have 85 if it has 85 we assign that price_list_id to select value, if not
                we will assign least price_list_id to select value.--->
				<cfquery name="Pull_price_list_id" datasource="#application.datasource#">
					SELECT *
					FROM  V_Price_List_Bracket
					WHERE Bracket = #Bracket#
					ORDER BY Price_List
				</cfquery>
				<cfset price_list_id_list = #valuelist(Pull_price_list_id.Price_List_ID,",")#>
				<cfif ListContains(price_list_id_list, 85)>
					<cfset price_list_id_value = listgetat(price_list_id_list, ListContains(price_list_id_list, 85))>
				<cfelse>
				    <cfset price_list_id_value = #Pull_price_list_id.Price_List_ID#>
				</cfif>
				<option value="#price_list_id_value#" <cfif price_list_id_value EQ url.priceListID>selected</cfif>>
				#Bracket#
				</option>
				<!--- End Dev Note: drachala; D28504: Update bracket drop down list to remove price list ID  --->
			</cfloop>
		</select>
	</td>
</tr>
</cfif>
<!--- Paid to --->
<cfset Component_Paid_To_Disabled = 0>

<!--- Dev Note(79237) - For a 2nd Component (Child of the first component), we cannot edit the "paid to". It has to match the "paid to" of the first component. --->
<cfif (Is_a_Revision eq 1 and RevisionSettings.Pay_To_Component eq 2) OR url.IsSecondComponent eq 1>
	<cfset Component_Paid_To_Disabled = 1>
</cfif>


<tr>
	<td align="right" valign="top">Paid To:</td>
	<td>
		<cfloop query="GetPaymentPaidToTypes">
		<input name="Component_Paid_To" type="Radio" value="<cfoutput>#Payment_Paid_To_ID#</cfoutput>" <cfif Component_Paid_To_Disabled eq 1>disabled</cfif> <cfif url.PaidTo eq Payment_Paid_To_ID>checked</cfif>><cfoutput>#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = Payment_Paid_To_Type_Identifier, paidToDesc=Payment_Paid_To_Type_Name)#</cfoutput><br>
		</cfloop>
		<!---  If "Paid To" cannot be edited,use the "hidden" field. --->
		<cfif Component_Paid_To_Disabled eq 1><input name="Component_Paid_To" type="hidden" value="<cfoutput>#url.PaidTo#</cfoutput>"></cfif>
	</td>
</tr>

<!--- 62343 8.0 - Blended Rate, CF START--->
<cfif appSettings.get_Setting('Blended_Rate') eq '1' AND CompDetails.rebate_type EQ 7>

	<cfquery name="BlendedDates" datasource="#application.datasource#">
		SELECT Calculation_Period_Start,Calculation_Period_End
		FROM Program_Rebates_Component PRC
		WHERE PRC.Program_ID = #url.programid#
		AND PRC.Deleted = 0
	</cfquery>
<tr>
	<td align="right" valign="top">Calculation Period :</td>
	<td valign="top">
		<b>Start Date : </b>  <input name="from_date" id="from_date" type="text" class="date" value="#dateformat(BlendedDates.Calculation_Period_Start,'m/d/yyyy')#" ><br><br>
		<b>End Date : </b>&nbsp;&nbsp;<input name="to_date" id="to_date" type="text" class="date" tabindex="9" value="#dateformat(BlendedDates.Calculation_Period_End,'m/d/yyyy')#">
		<input name="todays_date" id="todays_date" type="hidden" value="#DateFormat(Now(),'m/dd/yyyy')# ">
	</td>
</tr>
</cfif>
<!--- 62343 8.0 - Blended Rate, CF END--->
<!---GL Account--->
<cfif len(trim(url.GL_Account_ID)) GT 0>
	<!--- Dev Note: Kal; D42585: Program dates as fiscal periods --->
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
	WHERE CM.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.programId#" />
	<cfif ! ModifyDeletedPrograms>AND CM.Deleted = 0</cfif><!--- D50074 :: Viewing and Editing prior program versions  --->
	</cfquery>

	<cfquery name="GetGLs" datasource="#application.datasource#">
		SELECT GL_Account.GL_Account_ID,
					 Gl_Account,
					 GL_Account_Desc
		FROM GL_Account
		INNER JOIN GL_Component_Mapping ON GL_Component_Mapping.GL_Account_ID = GL_Account.GL_Account_ID
		AND GL_Component_Mapping.Component_Name_ID = '#url.compid#'
		AND GL_Component_Mapping.Discount_Type_ID = '#url.discounttypeid#'
		--AND DateDiff(d, GL_Account.Start_Date, '#qGetFiscalDatesforYear.Contract_Start_Date#') >= 0
		--AND DateDiff(d, GL_Account.End_Date, '#qGetFiscalDatesforYear.Contract_End_Date#') <= 0
		AND <cfqueryparam cfsqltype="CF_SQL_DATE" value="#qGetFiscalDatesforYear.Contract_Start_Date#" /> >= GL_Account.Start_Date
		AND <cfqueryparam cfsqltype="CF_SQL_DATE" value="#qGetFiscalDatesforYear.Contract_Start_Date#" /> <= GL_Account.End_Date
		ORDER BY GL_Account
	</cfquery>

	<tr>
		<td align="right" valign="top" nowrap><cfoutput>#Application.GLAccountLabel#</cfoutput> ID:</td><!---D42774 --->
		<td>
			<cfif GetGLs.Recordcount GT 0>
				<select name="GL_Account_ID">
					<cfloop query="GetGLs">
						<option value="#GL_Account_ID#" <cfif GL_Account_ID EQ url.GL_Account_ID>selected</cfif>>
						#Gl_Account# (#GL_Account_Desc#)
						</option>
					</cfloop>
				</select>
			<cfelse>
				No GLs associated with this component
			</cfif>
		</td>
	</tr>
</cfif>

<!--- Payment cycle --->
	<cfif appSettings.getPaymentCycleAtDiscountType()>
		<tr>
			<td valign="top" align="right">Payment Cycle:</td>
		<td valign="top">

		<cf_payment_cycle_selection
			Template_ID = "#url.ProgramType_ID#"
			Program_ID = "#url.programid#"
			discount_Type_ID = "1"
			Selected_Payment_Cycle_ID = "#url.PaymentCycle#"
			NoneEntry = "0"
			>
		</td>
		</tr>
		</cfif>

		<!--- End payment cycle --->

	<cfif len(trim(url.Claim_Mechanics)) GT 0>
		<cfif Is_a_Revision eq 1 AND RevisionSettings.Claim_Mechanic_Changed eq 2>
			<cfset ClaimMechanicsDisabled = 1>
		<cfelse>
			<cfset ClaimMechanicsDisabled = 0>
		</cfif>
		<tr>
		<td align="right">Claim Mechanism:</td>
		<td valign="top">
			<cf_claim_mechanic_selection
			Default_Claim_Selection = "#url.Claim_Mechanics#"
			Template_ID = "#ProgramType_ID#"
			Component_Name_ID = "#url.compid#"
			Edit_Selection = "#url.Claim_Mechanics#"
			Is_Revision = "#Is_a_Revision#"
			Allow_Auto_Payment = "#appSettings.getBBAutoReport()#"
			Discount_Type_ID = "#DiscountTypeID#"
			Allow_Off_Invoice = "#CompDetails.Off_Invoice_On#"
			ItemsDisabled = "#ClaimMechanicsDisabled#">

		</td>
		</tr>
		<tr>
		<td colspan="2">
			<cfdiv bind="url:claim_mech_info.cfm?Claim_Mechanics_ID={Claim_Mechanics}&Vendor_Master_ID=#url.Vendor_Master_ID#&VendorSelection=#url.VendorSelection#&Caller=FixedEdit&bHideFromLSAutoPay=#URL.bHideFromLSAutoPay#&Business_Segment_ID=#Business_Segment_ID#&Discount_Type_ID=#discounttypeid#" ID="ClaimMech"/>
		</td>
		</tr>
	<cfelse>
		<input type="hidden" name="Claim_Mechanics" value="0">
	</cfif>


<!--- Accrual --->
<cfif len(trim(CompDetails.Accrual_On)) GT 0>
<tr>
	<td align="right" nowrap>Accrual&nbsp;On:</td>
	<td>
		<Cfif CompDetails.Accrual_On IS 1>
		Yes
		<cfelse>
		No
		</Cfif>
	</td>
</tr>
</cfif>

<!--- Brokerage --->
<cfif len(trim(CompDetails.Exclude_Brokerage)) GT 0>
<tr>
	<td align="right"  nowrap>Exclude&nbsp;Brokerage:</td>
	<td>
		<Cfif CompDetails.Exclude_Brokerage IS 1>
		Yes
		<cfelse>
		No
		</Cfif>
	</td>
</tr>
</cfif>

<!--- Floor Pricing --->
<cfif len(trim(CompDetails.Floor_Pricing_On)) GT 0>
<tr>
	<td align="right" nowrap>Floor&nbsp;Pricing&nbsp;On:</td>
	<td>
		<Cfif CompDetails.Floor_Pricing_On IS 1>
		Yes
		<cfelse>
		No
		</Cfif>
	</td>
</tr>
</cfif>

<!--- Off Invoice --->
<cfif len(trim(CompDetails.Off_Invoice_On)) GT 0>
<tr>
	<td align="right" nowrap>Off&nbsp;Invoice&nbsp;On:</td>
	<td>
		<Cfif CompDetails.Off_Invoice_On IS 1>
		Yes
		<cfelse>
		No
		</Cfif>
	</td>
</tr>
</cfif>
<tr><td>&nbsp;</td></tr>
</table>

<a href="##" onclick="submitForm(document.editcomponentform, 'save');">#application.util.string.actionLinkFormat("save")#</a>

	<input type="hidden" name="command" value="#form.command#">
	<input type="hidden" name="FixedComponentList" value="#FixedComponentList#">
	<input type="hidden" name="ThisFixedComponent" value="#ThisFixedComponent#">

</form>

<cfset jQueryUI.version = '1.11.4'/>
<cfinclude template="/common_files/jQuery.cfm">
<cf_include files="/script/css/smoothness/jquery-ui-1.11.4.custom.min.css">

<script>
	$('tr td:first-child').css('font-weight', 'bold');

	function submitForm(thisForm,sCommand) {
		var radios = document.getElementsByName('VendorSelection');
    	document.all.PayeeOptionSelected.value = false;
	    for (var i=0; i<radios.length; i++) {
		        if (radios[i].checked) {
		        	document.all.PayeeOptionSelected.value = true;
		        }
		    }
		if (document.all.PayeeOptionSelected.value == false) {
			alert("Please select Payee options.");
			return false;
		}
		/*62343 8.0 - Blended Rate, CF START */
		<cfif appSettings.get_Setting('Blended_Rate') eq '1' AND CompDetails.rebate_type EQ 7>

		var todaysdate = new Date(document.all.todays_date.value);
		var enddate = new Date(document.all.to_date.value);

			if(enddate >  todaysdate){
				alert("End Date cannot be in future.");
				return false;
			}
			if(document.all.from_date.value== "" || document.all.to_date.value== "" ){
				alert("Enter Start Date / End Date.");
				return false;
			}
		</cfif>
		/*62343 8.0 - Blended Rate, CF END */
		if (document.all.Vendor_Master_ID.value == 0) {
				 var OperatorOption = 0;
				 var PayeeOption = 0;

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

		/* If Vendor selection radio boxes exist */
				if(document.all.VendorSelection)
				{	
					if(document.all.VendorSelection.type != "hidden"){
						/* if none of the payee radio button options are selected */
						if($("input:radio[name='VendorSelection']").is(":checked") == false){
								alert("You must select a payee.")
								return false;
						}
					}
					/* In this case, there are no "radio button" options  to select a payee type ("Select a single payee", "Pay each entity individually") etc.,
					but the "select a payee" link does exist as "VendorSelection" is true (From claim_mech_info.cfm), when "Auto Pay Disable Pay Each" appp setting
					is ON.
					*/
					else{
						alert("You must select a payee.");
						return false;
					}
			/* Pay to a single Payee */
					if(document.all.VendorSelection.type != "hidden" && document.all.VendorSelection[0].checked)
					 {
					 		if(PayeeOption == 0)
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
			 /* Pay Individually */
					 else
					 {
							if(PayeeOption == 1 || PayeeOption == 3)
							{
								alert("You must select a vendor for auto pay components not payable to distributor")
								return false;
							}
					 }
				 }
			}
							thisForm.command.value = sCommand;
							thisForm.submit();
							opener.callSpinner();
	}

	$("a[name=downloadLink]").click(function() {
		<!--- users have to select a group product or check the non-group product box --->
		if ($("select[name=groupProduct]").val() == "" && !$("input[name=nonGroupProduct]").prop("checked")) {
			alert( "Please make at least one selection and try again." );
			return false;
		}
		<!--- abbreviate the URL parameters to hide their actual meanings --->
		var params = 'cmi=#url.programid#'
								 + '&' + 'coi=#url.compid#'
								 + '&' + 'dti=#url.discounttypeid#'
								 + '&' + 'gp=' + $("select[name=groupProduct]").val()
								 + '&' + 'ngp=' + $("input[name=nonGroupProduct]").prop("checked")
								 + '&' + 'Business_Segment_ID=#Business_Segment_ID#';
		<cfif url.download eq '1'>
			NewWindow('/common_files/contracts/downloadRebate.cfm?' + params, 'downloadRebate', '800', '600', 'No', 'No');
		<cfelse>
			NewWindow('/common_files/contracts/downloadFixed.cfm?' + params, 'downloadFixed', '800', '600', 'No', 'No');
		</cfif>
	});

	function calc() { return true; }  // this gets called from claim_mechanic_selection custom tag

	function uploadComplete(result) {
		if (result.STATUS !== 200) {
			// display errors found in .csv file
			window.location.href = "/common_files/displayFile.cfm?title=Upload Result" + "&file=" + result.MESSAGE;
		}
		else {
			// reload parent window
			opener.location.reload();
			window.close();

		}
	}

/*62343 8.0 - Blended Rate, CF START */
$( document ).ready(function(){
	jQuery(".date").datepicker({
	    dateFormat: "m/d/yy",
	    changeMonth: true,
	    changeYear: true,
	    maxDate: 0 ,
	    onSelect: function( selected ) {
	        // change date limit based on selected value
	        if ( jQuery(this).attr("name") === "from_date" )
	            jQuery("input[name=to_date]").datepicker("option", "minDate", selected);
	        else
	            jQuery("input[name=from_date]").datepicker("option", "maxDate", selected);
	    }
	});
});
/*62343 8.0 - Blended Rate, CF  END */


</script>
</cfoutput>
</body>
</html>
