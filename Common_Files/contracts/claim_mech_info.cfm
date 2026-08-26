<cfparam name="Discount_Type_ID" 				default="">
<cfparam name="Vendor_Master_ID" 				default="0">
<cfparam name="url.VendorSelection" 				default="0">
<cfparam name="Formname" 						default="">
<cfparam name="Caller" 							default="">
<cfparam name="URL.Caller_Split_For_Auto_Pay"  default="0">
<cfparam name="URL.Generic_Type" 				default="">
<cfparam name="variables.Restrict_Pay_Each" 	default="1">
<cfparam name="Payee_Selection" 				default="">
<cfparam name="URL.ProgramType_ID" 			default="" >
<cfparam name="url.Business_Segment_ID" 		default="0" >
<cfparam name="url.Program_Upload" 		default="0" >
<cfparam name="url.Component_Name_ID" default="0">
<cfparam name="url.programId" default="0">

<cfif (URL.programId NEQ 0 AND URL.Business_segment_ID EQ 0)>
	<cfquery name="GetBusInfo" datasource="#application.datasource#">
		SELECT ISNULL(Business_Segment_ID,0) AS Business_Segment_ID,*
		FROM Contract_main
		WHERE contract_Main_ID= #url.programId#
	</cfquery>
	<cfset URL.Business_segment_ID = GetBusInfo.Business_Segment_ID />
</cfif>

<cfset appSettings = application.appsettingsGet />
<cfset variables.Restrict_Pay_Each = appSettings.getBBAutoPayDisablePayEach() />
<cfif isDefined("url.Claim_Mechanics_ID") AND url.Claim_Mechanics_ID neq "">
	<cfquery name="GetClaimMechInfo" datasource="#application.datasource#">
		SELECT Restrict_From_Billback, Is_Auto_pay, Billback_Closing_Method_ID
		FROM Payment_Type
		WHERE Payment_Type_ID = #url.Claim_Mechanics_ID#
	</cfquery>
	<!---D37702 :: Brokerage template type doesn't allow vendor select --->
	<cfif len(URL.ProgramType_ID)>
		<cfset useLakebaseForGetTemplateInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForGetTemplateInfo>
	<cftry>
		<cfset GetTemplateInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#URL.ProgramType_ID#",
				"select" = "allow_only_one_broker"
			}), "allow_only_one_broker"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetTemplateInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetTemplateInfo>
<cfquery name="GetTemplateInfo" datasource="#application.datasource#">
			SELECT Allow_Only_One_Broker
			FROM Program_Control_Panel_Options
			WHERE ProgramControl_Panel_Options_ID = #URL.ProgramType_ID#
		</cfquery>
</cfif>
	<cfelse>
		<cfset GetTemplateInfo.Allow_Only_One_Broker = 0>
	</cfif>
	<cfif GetClaimMechInfo.Is_Auto_pay AND GetTemplateInfo.Allow_Only_One_Broker>
		<cfset showVendor = 1>
	<cfelse>
		<cfset showVendor = 0>
	</cfif>
	<!---D37702 :: Brokerage template type doesn't allow vendor select --->
	<!--- Get the Payee in the "Billback_Closing_Method" settings in the settings panel --->
	<cfquery name="GetPayeeSelection" datasource="#application.datasource#">
		SELECT isnull(nullif(Payee_Type,''),0) As Payee_Selection
		FROM Billback_Closing_Methods
		WHERE iBillback_Closing_Method_ID = #GetClaimMechInfo.Billback_Closing_Method_ID#
	</cfquery>
	<cfset Payee_Selection = GetPayeeSelection.Payee_Selection>
	<cfif len(trim(GetClaimMechInfo.Restrict_From_Billback)) GT 0 AND GetClaimMechInfo.Restrict_From_Billback IS 1>
		Restricted from billbacks
	</cfif>
	<cfif GetClaimMechInfo.Restrict_From_Billback IS 1 AND GetClaimMechInfo.Is_Auto_pay IS 1 AND appSettings.getBBAutoReport()>
		<br>
	</cfif>
	<cfif len(trim(GetClaimMechInfo.Is_Auto_pay)) GT 0 AND GetClaimMechInfo.Is_Auto_pay IS 1 AND appSettings.getBBAutoReport()>
		Auto pay
	</cfif>
&nbsp;
<!--- D14532 Pick payee --->
<!---TSF - Label 15077: Don't display payee options if the discount type is Lump Sum --->
	<cfif GetClaimMechInfo.Is_Auto_pay AND (Discount_Type_ID neq 3 OR URL.bHideFromLSAutoPay EQ 1 OR appSettings.getBBAutoPayLumpSum()) AND URL.Generic_Type NEQ 'Brokerage'  OR showVendor>

	<!--- For Lump sum we want user to pick a payee, pay each is not available  --->
	<cfif Discount_Type_ID eq 3>
		<cfset variables.Restrict_Pay_Each = 1 />
	</cfif>

	<!--- We need to handle for the different pages this can be called from --->
	<cfswitch expression="#Caller#">
		<cfcase value="Fixed">
			<script>
				document.FixedComponents.Auto_Pay_Status.value = 1
			</script>
			<cfset Formname="FixedComponents">
		</cfcase>
		<cfcase value="FixedEdit">
			<cfset Formname="editcomponentform">
		</cfcase>
		<cfcase value="Rebate">
			<script>
				document.dataForm.Auto_Pay_Status.value = 1
			</script>
			<cfset Formname="dataForm">
		</cfcase>
		<cfcase value="LumpSum">
			<script>
				document.NewLumpSum.Auto_Pay_Status.value = 1
			</script>
			<cfset Formname="NewLumpSum">
		</cfcase>
		<cfcase value="RebateEdit">
			<cfset Formname="editcomponentform">
		</cfcase>
		<cfcase value="Growth">
		<script>
			document.newComponentForm.Auto_Pay_Status.value = 1
		</script>
		<cfset Formname="newComponentForm">
	</cfcase>
	</cfswitch>
	<table width="100%">
		<tr>
			<td>
				<hr color="orange" width="100%">
			</td>
		</tr>
		<tr>
			<td>
				<strong>Payee options</strong>
			</td>
		</tr>
		<tr>
			<!--- BJF: Please note that at this point, these form fields do nothing but provide information to the user. They are not saved or used in any way ---->
			<td>
				<!--- Option 1 (select payee) is always available --->
				<cfif variables.Restrict_Pay_Each> <!--- Appsettting tells us that they must select a payee -> due to no vendor/distributor mapping --->
					<input type="hidden" id="VendorSelection" name="VendorSelection" value="true" />
				<cfelse> <!--- Show the payee options --->
					<input type="radio" id="VendorSelection" name="VendorSelection" value="1" onClick="UpdateParent();" <cfif url.VendorSelection eq 1>checked</cfif>>Select a single payee
				</cfif>
				<SPAN ID="Err_Sp_Vendor"></SPAN>
				<a href="##" onClick="CheckPaymentOption();">
					<cfoutput>#application.util.string.actionLinkFormat("select payee")#</cfoutput>
				</a>
				<!--- Option 2 (Pay each) is not available when app setting Auto Pay Disable "Pay Each" is ON  --->
				<cfif NOT variables.Restrict_Pay_Each> <!--- Appsettting tells us that they must select a payee -> due to no vendor/distributor mapping --->
					<cfif appSettings.get_Setting('BB_Auto_Pay_Disable_Pay_Each_Entity_Individually') eq '0'>
					<br>
					<input type="radio" id="VendorSelection" name="VendorSelection" value="2" onClick="UpdateParent();" <cfif url.VendorSelection eq 2>checked</cfif>>Pay each entity individually
					<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="Red">(not valid for operator payee)</font>
					</cfif>
				</cfif>
				<!--- Option 3 (Payee from planning groups) is available when app setting "Establish payee from planning groups" is ON. Currently, this is for "rebate" and "growth" only.--->
				<cfif appsettings.getPayeeFromPlanningGroups() eq 1 AND (Discount_Type_ID eq 2 OR Discount_Type_ID eq 4) >
					<!---  (Payee from planning groups) is not available when app setting Auto Pay Disable "Pay Each" is ON --->
					<cfif NOT variables.Restrict_Pay_Each>
						<br><input type="radio" id="VendorSelection" name="VendorSelection" value="3" onClick="UpdateParent();" <cfif url.VendorSelection eq 3>checked</cfif>>Pay each planning groups
					</cfif>
				</cfif>
			</td>
		</tr>
			<!--- If we've already passed in a vendor master id we need the appropriate vendor id.... --->
			 <cfset Vendor_ID = 0 /> <!---  initialize --->
			 <cfif url.Program_Upload AND url.component_name_ID>
			 	<cfquery name="getVendorInfo" datasource="#application.datasource#">
				 	SELECT Vendor_Master_ID
				 	FROM Program_Rebates_Component
					WHERE program_id = #url.programId#
					AND Program_Rebates_Component_Name_ID = #url.component_name_ID#
					AND Deleted = 0
			  </cfquery>
			  <cfif getVendorInfo.Recordcount>
			 	 	<cfset Vendor_Master_ID = #getVendorInfo.Vendor_Master_ID#>
				</cfif>
			 </cfif>
			<!--- If the Payee is the "Distributor" in the "Billback_Closing_Method" settings in the settings panel --->
		<cfif Vendor_Master_ID NEQ 0 AND Vendor_Master_ID NEQ "">
			<cfif Payee_Selection eq 1>
				Payee_Selection: <cfoutput>#Payee_Selection#</cfoutput>
				<cfquery name="GetVendorID" datasource="#application.datasource#">
					SELECT Shr_Ship_To As Vendor_ID, Name As Vendor_Name
					FROM BSA_Foodservice_Customers
					WHERE BSA_Foodservice_Customers_ID = '#Vendor_Master_ID#'
				</cfquery>
			<cfelse>
				<!--- If the Payee is the "Vendor" in the "Billback_Closing_Method" settings in the settings panel --->
				Payee_Selection: <cfoutput>#Payee_Selection#</cfoutput>
				<cfset useLakebaseForGetVendorID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vendor_master")>
				<cfif useLakebaseForGetVendorID>
					<cftry>
						<cfset GetVendorID = application.oLakebase.toQuery(
							application.oLakebase.selectRows("vendor_master", { "select" = "vendor_id,vendor_name", "vendor_master_id" = "eq.#Vendor_Master_ID#" })
						)>
						<cfcatch type="any">
							<cfset useLakebaseForGetVendorID = false>
						</cfcatch>
					</cftry>
				</cfif>
				<cfif NOT useLakebaseForGetVendorID>
					<cfquery name="GetVendorID" datasource="#application.datasource#">
						SELECT Vendor_ID, Vendor_Name
						FROM Vendor_Master
						WHERE Vendor_Master_ID = '#Vendor_Master_ID#'
					</cfquery>
				</cfif>
			</cfif>

			<cfif GetVendorID.Recordcount>
				<script>
					<cfif Discount_Type_ID eq 4>
						document.newComponentForm.AllowSave.value = 1;
					<cfelse>
						 <cfoutput>document.#Formname#.AllowSave.value = 1;</cfoutput>
					</cfif>
				</script>
				<cfset Vendor_ID = GetVendorID.Vendor_ID>
				<tr  id="ShowPayeeSearch">
					<td>
						<b>Current Payee:</b> <br /><cfoutput>#GetVendorID.Vendor_Name#</cfoutput>
					</td>
				</tr>
			</cfif>
			<input type="hidden" name="AlreadySelectedVendor" value="1">
		<cfelse>
			<input type="hidden" name="AlreadySelectedVendor" value="0">
		</cfif>

		<cfoutput>
			<input type="hidden" name="Vendor_ID" id="Vendor_ID" value="#Vendor_ID#">
			<input type="hidden" name="Payee_Selection"  value="#Payee_Selection#">
		</cfoutput>
		<tr  id="ShowPayeeInfo" style="display: none">
			<td>
				<B>Payee:</B><cfdiv bind="url:/Common_Files/contracts/vendor_id_display.cfm?Vendor_ID={Vendor_ID}&Caller=#Caller#&Payee_Selection=#Payee_Selection#&cfdebug" ID="vendorIDDisplay"/>
			</td>
		</tr>
	</table>
	<script>
		CheckPaymentOption = function(){
			<cfif variables.Restrict_Pay_Each> /* Appsettting tells us that they must select a payee */
				// If the Payee is the "Distributor" in the "Billback_Closing_Method" settings in the settings panel ---
				<cfif Payee_Selection eq 1>
					NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?RebateRecipient_On=1&Formname=<cfoutput>#Formname#</cfoutput>&ReloadForm=0&FieldName=Vendor_ID&SelectSingleSearchResultOnly=1&PageSource=ProgramDistributorSearch&Business_Segment_ID=<cfoutput>#url.Business_Segment_ID#</cfoutput>", "searchwindow", 800, 600, "yes", "yes")
				<cfelse>
				// If the Payee is the "Vendor" in the "Billback_Closing_Method" settings in the settings panel
					NewWindow('/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?RebateRecipient_On=1&Formname=<cfoutput>#Formname#</cfoutput>&ReloadForm=0&FieldName=Vendor_ID&PageSource=ProgramVendorSearch&SelectedVendor_ID=<cfoutput>#Vendor_ID#</cfoutput>&Business_Segment_ID=<cfoutput>#url.Business_Segment_ID#</cfoutput>&programId=<cfoutput>#url.programId#</cfoutput>', 'VendorSearch', '800', '600', 'yes', 'yes');
				</cfif>
			<cfelse>
				var $vendor = $("input[name=VendorSelection]");
				if( $vendor[1] && $vendor[1].checked )
				{
					alert('You cannot select a payee when paying each entity individually');
					return false;
				}
				else if( $vendor[2] && $vendor[2].checked )
				{
					alert('You cannot select a payee from programs, when selecting "payee from planning groups". The payee needs to be set up in the planning groups.');
					return false;
				}
				else if ( $vendor[0].checked )
				{
					// If the Payee is the "Distributor" in the "Billback_Closing_Method" settings in the settings panel ---
					<cfif Payee_Selection eq 1>
						NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?RebateRecipient_On=1&Formname=<cfoutput>#Formname#</cfoutput>&ReloadForm=0&FieldName=Vendor_ID&SelectSingleSearchResultOnly=1&PageSource=ProgramDistributorSearch&Business_Segment_ID=<cfoutput>#url.Business_Segment_ID#</cfoutput>", "searchwindow", 800, 600, "yes", "yes")
					<cfelse>
					//If the Payee is the "Vendor" in the "Billback_Closing_Method" settings in the settings panel ---
						NewWindow('/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?RebateRecipient_On=1&Formname=<cfoutput>#Formname#</cfoutput>&ReloadForm=0&FieldName=Vendor_ID&PageSource=ProgramVendorSearch&SelectedVendor_ID=<cfoutput>#Vendor_ID#</cfoutput>&Business_Segment_ID=<cfoutput>#url.Business_Segment_ID#</cfoutput>', 'VendorSearch', '800', '600', 'yes', 'yes')
					</cfif>
				}
				else
				{
					alert('Please choose a Payee Option');
					return false;
				}
			</cfif>
		}

		UpdateParent = function()
		{
			document.all.Vendor_Selection.value = $("input[name=VendorSelection]").prop("checked");
		}
		<cfif variables.Restrict_Pay_Each> /* Appsettting tells us that they must select a payee */
			document.all.Vendor_Selection.value = true;
		</cfif>
	</script>

	<cfelse>
		<!--- If it's not auto pay, set the auto pay flag to 0 --->
		<cfswitch expression="#Caller#">
			<cfcase value="Fixed">
				<script>
					document.FixedComponents.Auto_Pay_Status.value = 0
				</script>
				<cfset Formname="FixedComponents">
			</cfcase>
			<cfcase value="Rebate">
				<script>
					document.dataForm.Auto_Pay_Status.value = 0
				</script>
				<cfset Formname="dataForm">
			</cfcase>
			<cfcase value="Growth">
				<script>
					document.newComponentForm.Auto_Pay_Status.value = 0
				</script>
				<cfset Formname="newComponentForm">
			</cfcase>
		</cfswitch>
	</cfif>

<input type="hidden" name="Vendor_Master_ID" value="<cfoutput>#Vendor_Master_ID#</cfoutput>">
	<!--- auto pay type selection for lump sums --->
	<cfif Discount_Type_ID IS 3 AND GetClaimMechInfo.Is_Auto_pay AND appSettings.getBBAutoReport() AND !appSettings.getBBAutoPayLumpSum()>
		<table  style="border: 1px dotted orange;" width="300">
			<tr>
				<td colspan="2">
					<strong>Auto Pay Type</strong>
				</td>
			</tr>
			<tr>
				<td>
					Each payee gets full <cfoutput>#Application.LumpsumLabel#</cfoutput> amount:
				</td>
				<td>
					<input type="radio" name="Split_For_Auto_Pay" value="0" <cfif URL.Caller_Split_For_Auto_Pay eq 0>checked</cfif> />
				</td>
			</tr>
			<tr>
				<td>
					Divide <cfoutput>#Application.LumpsumLabel#</cfoutput> between payees:
				</td>
				<td>
					<input type="radio" name="Split_For_Auto_Pay" value="1" <cfif URL.Caller_Split_For_Auto_Pay eq 1>checked</cfif> />
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<hr width="100%" color="orange">
					<strong>NOTE:</strong> Check requests for auto pay lump sums are created immediately upon the approval of the program.
					If this program is approved, the request will be sent right away in full, regardless of payment frequency selected.
				</td>
			</tr>
		</table>
	</cfif>

<cfelse>
	<script language="javascript">
		alert("Please ask your system administrator to review the configuration settings for the component.  This component does not have any claim mechanics to display.");
		document.all.Claim_Mech.value = ''
	</script>
</cfif>

<!---
D20867: CAG DEV 14770 - FORMSCOPE.VENDOR_MASTER_ID undefined in ARGUMENTS
enableDisableIncludeComponentLink (true) will enable the link "include this rebate component"
We will enable the link "include this rebate component" at the end of this page
It was previously disabled on component drop down selection and claim mechanics selection
--->
<script language="javascript">
	if(document.all.bEnableDisableIncludeComponentLink)
	{
		if(document.all.bEnableDisableIncludeComponentLink.value == "1")
		{
			enableDisableIncludeComponentLink(true);
		}
	}
</script>