<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset ProgramManager = CreateObject("component", "components.programs.programManager").init() />
<cfset programObj = CreateObject("component", "components.programs.program") />
<cfset objProgramFreight = CreateObject("component", "components.freight.ProgramFreight").init() />
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />

<cfset forbidType = application.oApplicationAppSettingsManager.getApplicationAppSettings().getForbidAllowProfilesInTemplates() />

<cfset bAutoApproveProgram = 0 />
	<cfset appSettings = genSettingsManager.get()>
	<CFINCLUDE TEMPLATE="/Get_Access_Profile.cfm">
	<!--- If its a Date Exclusion Project --->
	<cfparam name="ChildProgramIDList" default="">

	<CFQUERY NAME="CSLGetContractInfo" datasource="#application.datasource#">
		SELECT Program_Control_Panel_Options.Created_Type, Contract_Main.*,
		       dbo.Program_Control_Panel_Options.Generic_Type,Program_Control_Panel_Options.revision_not_allowed,
		       Program_Control_Panel_Options.EZButton_On,
	           Program_Control_Panel_Options.EzButton_Auto_Approve_On
		FROM Contract_Main
			INNER JOIN	Program_Control_Panel_Options
			ON (Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID)
		WHERE Contract_Main_ID = '#cryp.value#'
	</CFQUERY>

	<cfquery name="GetSettings" datasource="#application.datasource#">
		SELECT	*
		FROM	Program_Control_Panel_Options
		WHERE	ProgramControl_Panel_Options_ID = '#CSLGetContractInfo.ProgramType_ID#'
	</cfquery>

	<cfif GetSettings.Date_Exclusions_ON EQ 1>
		<!--- If its a Date exclusion project, get all the IDs including the Date Exclusion Program IDs --->
		<cfset ContractIDList = programManager.ChildProgramIDs(cryp.value,0)>
		<cfif ContractIDList.Recordcount neq 0>
			<cfset ChildProgramIDList = ValueList(ContractIDList.Revision_Program_ID)>
		</cfif>
	</cfif>


	<!--- Dev Note: KAL; 8604: Set flags if the revisions to a program are minor --->
	<!--- Dev Note: Milan;16491 - If we do not have our progress bar for duplicate check already being shown at the top
		  of the page, then show this
	--->
	<!--- set short cut routing flags - start --->
<!---D39479 :: Short Cut Routing profile switch --->
<!---
 D41397 :: Short cut routing not working
When user profile settings "Prevent_short_cut_routing" if ON in DB the value is 1, but in below condition we were checking if profile settings "Prevent_short_cut_routing" is ON instead OFF.
Modified code to check profile settings "Prevent_short_cut_routing" is OFF, when it's OFF DB value will be O
--->
<cfif Get_Profile_Settings.Prevent_short_cut_routing EQ 0 AND appSettings.getRevisionTypesOn() EQ 1>
	<cfif IncludeProgressBar eq 0>
		<CFINCLUDE TEMPLATE="/includes/progress_bar.cfm">
	</cfif>
	<!--- Dev Note: drachala; D27484: HZPROD280 -  SARP CRA DISPLAYS INCORRECT CRA  START
	What  I did:  Added a condition in CFIF (getsettings.EZbutton) if EZbutton TURN ON SKIP Short Cut Routing.--->

	<cfif programObj.isARevision(cryp.value)>
		<!--- Show the Progess bar for Shortcut Routing--->
		<SCRIPT LANGUAGE="JavaScript">
		document.getElementById('Display_Message').innerHTML = 'Shortcut Routing';
		</SCRIPT>
		<cfflush>
		<cfset oRevise_Type_Check = CreateObject("component", "components.programs.Revise_Type_Check") />
		<cfset oReviseLog = CreateObject("component", "components.programs.ReviseLog") />
		<cfset MinorRevision = oRevise_Type_Check.MinorReviseFieldsCheck(GetContractInfo.Revision_Of_Contract_Main_ID, cryp.value) />

		<!--- D28558: Shortcut Routing Changes --->
		<!--- If program is flagged as a specific Revision Type and that Revision Type does not require routint, flag the program as approved  --->
		<cfset qGetProgramRevisionTypes = oRevise_Type_Check.getProgramRevisionTypes(programId = cryp.value) />
		<cfif qGetProgramRevisionTypes.RevisionTypeA GT 0 OR qGetProgramRevisionTypes.RevisionTypeB GT 0 OR qGetProgramRevisionTypes.RevisionTypeC GT 0> <!--- Program is flagged as short cut type A, B or C --->
			<cfset qGetRevisionSettingsData = oRevise_Type_Check.getRevisionSettingsData() />
			<cfif
					(qGetProgramRevisionTypes.RevisionTypeA EQ 0 OR qGetRevisionSettingsData.No_Routing_Required_A EQ "1") <!--- 1.Program is not flagged as short cut type A, 2. Program is flagged as short cut type A and type A does not require routing --->
				AND (qGetProgramRevisionTypes.RevisionTypeB EQ 0 OR qGetRevisionSettingsData.No_Routing_Required_B EQ "1") <!--- 1.Program is not flagged as short cut type B, 2. Program is flagged as short cut type B and type B does not require routing --->
				AND (qGetProgramRevisionTypes.RevisionTypeC EQ 0 OR qGetRevisionSettingsData.No_Routing_Required_C EQ "1") <!--- 1.Program is not flagged as short cut type C, 2. Program is flagged as short cut type C and type C does not require routing --->
				>
				<!--- D32283 Add Setting for EZ Button Program revisios START--->
				<cfset CheckAutoApprove = oRevise_Type_Check.CheckEZRate(GetContractInfo.Revision_Of_Contract_Main_ID, cryp.value)>

				<!--- Tim Ford - 05/01/2017: D68417 - Volume Override Enhancement-Revision Functionality
					Don't auto approve if volume override options were changed for revision
				--->
				<cfset CheckVolumeOverride = oReviseLog.getVolumeOverrideIgnore(GetContractInfo.Revision_Of_Contract_Main_ID, cryp.value)>
				<cfif NOT CheckAutoApprove and NOT CheckVolumeOverride.RecordCount>
					<!--- Approve the program --->
					<!--- Here we do not need to check all the auto approval Ezbutton logic (it is below in this file). Here, we just have a simple additional check for "EZ rates", before short-cut coukd approve it. --->
					<cfset bAutoApproveProgram = 1 />
				</cfif>
				<!--- D32283 Add Setting for EZ Button Program revisios END--->
			</cfif>
		</cfif>

		<!--- Shortcut Routing ends here. --->
		<SCRIPT LANGUAGE="JavaScript">
		document.getElementById('ShowPercentProgress').innerHTML = '';
		for (var i=1;i<=10;i++){
				Block = "Block" + i;
				document.getElementsByName(Block)[0].src =  '';
			}
		document.getElementById('Display_Message').innerHTML = 'Loading Page';
		</SCRIPT>
		<cfflush>
	</cfif>
</cfif>


<!---
***************AUTO APPROVAL START***************
Note: Earlier, the Ezbutton and the Market price "auto approval" code was added towards the end of this file.
When the "auto approval product on revision" code was added, the above logic was brought up.
The reason for the above change is that we need to call "auto approval product on revision" code before "makeRFA" function
creates the CRA. Even the Ezbutton and Market price approval code should be run before creating the CRA, so that the
routing is more specific, i.e. it does not route to more a person unnecessarily.
--->

	<cfset ApprovalManager = CreateObject("component", "components.programs.Approval.ApprovalManager") />
	<!--- Dev Note: drachala; D28087: Auto Approve EZ Button Program  START
	What  I did: Added a condition to IF statement to check EZ Auto Approve in ON--->
	<cfset Approve_LS = 0>
	<cfif Get_Profile_Settings.Cont_Prog_Approval_Rights EQ 1 and CSLGetContractInfo.EZButton_On EQ 1 and CSLGetContractInfo.EzButton_Auto_Approve_On EQ 1>
		<!--- When template setting on the EZButton Page called "Max Rate should consider" is  NOT "Rebate & Lumpsum". --->
		<cfif GetSettings.EzButton_Max_Rate_Consider neq 2>
			<!--- Check approval rights for lumpsum --->
			<cfinclude template="common_lumpsum_approval_check.cfm">
			<!--- If program has lump sum. --->
			<cfif programLumpSum GT 0>
				<cfif IsDefined("letUserProceed")>
					<cfif letUserProceed eq 1>
						<cfset Approve_LS = 1>
					</cfif>
				<!--- Default value of "letUserProceed" is 1 and so if the value is not 0, then use the default value. --->
				<cfelse>
				<cfset Approve_LS = 1>
				</cfif>
			<cfelse>
				<cfset Approve_LS = 1>
			</cfif>
		<cfelse>
				<cfset Approve_LS = 1>
		</cfif>


		<!--- D28783: Release 7 EZ Button Max Rate. Auto approve products that can be auto approved --->
		<cfif  Approve_LS eq 1><!--- If there is lumpsum, lumpsum should be approvable OR there is no lumpsum. --->
			<!--- D50297: Broker Routing Approvals: For EZ Rates when no products but just LS then route to regular approvals. --->
			<cfset qGetDiscountTypes = programObj.getDiscountTypes(cryp.value) />
			<cfif not(len(programObj.getprogramDiscounttypes(cryp.value)) eq 0 AND listFind(valuelist(qGetDiscountTypes.Product_Type_ID),3)) >
				<cfset qProductsNotApproved = ApprovalManager.autoApproveEZProducts(cryp.value, request.AccessStructure.user_id)>
				<cfif not qProductsNotApproved.recordCount><!--- If all the products are approved --->
					<cfset bAutoApproveProgram = 1 />
				</cfif>
			</cfif>
		</cfif>
	</cfif>

	  <!--- IF MARKET PRICE, RUN AUTO APPROVE.  IF NO LEFTOVER ITEMS, SET FLAG --->
	 <!--- IF MARKET PRICE, CHECK IF WE CAN BYPASS MARGIN SCREEN --->
	<CFIF GetSettings.Market_Price>
		<cfset qMPProductsNotApproved = ApprovalManager.autoApproveMarketPriceProducts(cryp.value, request.AccessStructure.user_id)>
		<cfif not qMPProductsNotApproved.recordCount><!--- If all products are approved --->
			<cfset bAutoApproveProgram = 1 />
		</cfif>
	</cfif>

	<!--- If the program is a revision - auto approve products, where product rate has not changed and for products that are not new on the revision. --->
	<cfif appsettings.getAutoApproveProductsOnRevision() eq 1 AND programObj.isARevision(cryp.value)>
		<cfset qAutoApproveProductsRatesNotChanged = ApprovalManager.autoApproveProductsRatesNotChanged(GetContractInfo.Revision_Of_Contract_Main_ID, cryp.value,request.AccessStructure.user_id)>
	</cfif>

<!--- 68969  :: Allowing CSR to add a distributor and approve program START
1) check if program is a revision
2) check if program is flaged as limited revision
3) When program is RFA'd by the user who has  "Limited Revision" profile setting ON, Program is auto approved

if all are TRUE set bAutoApproveProgram = 1
--->
<cfif programObj.isARevision(cryp.value) AND programObj.isALimitedRevision(cryp.value) AND Get_Profile_Settings.Limited_Revise>
	<cfset bAutoApproveProgram = 1 />
</cfif>
<!--- 68969 :: Allowing CSR to add a distributor and approve program END--->

<!---***************AUTO APPROVAL  END***************--->

<!---D39479 :: Short Cut Routing profile switch --->
	<!--- set short cut routing flags - end --->

	<cfif appsettings.getCaptureGroupsOnSave() Eq 0>
		<cfquery name="checkisgroup" datasource="#application.datasource#">
			select 	count(*) as groupcount
			from	contract_products
			where 	contract_main_id = '#cryp.value#'
			and 	deleted = 0
			and 	is_group = 1
		</cfquery>
		<cfif checkisgroup.groupcount EQ 0>
			<cfset programObj.makeRFA(cryp.value, request.AccessStructure.user_id) />
			<cfif Listlen(ChildProgramIDList) neq 0>
				<cfloop list="#ChildProgramIDList#" index="ChildContractID">
					<cfset programObj.makeRFA(ChildContractID, request.AccessStructure.user_id) />
				</cfloop>
			</cfif>
		<cfelse>
			<cfset programObj.makeRFA(cryp.value, request.AccessStructure.user_id, 1) />
			<cfif Listlen(ChildProgramIDList) neq 0>
				<cfloop list="#ChildProgramIDList#" index="ChildContractID">
					<cfset programObj.makeRFA(ChildContractID, request.AccessStructure.user_id,1) />
				</cfloop>
			</cfif>
		</cfif>
	<cfelse>
	 	<cfset programObj.makeRFA(cryp.value, request.AccessStructure.user_id) />
		<cfif Listlen(ChildProgramIDList) neq 0>
			<cfloop list="#ChildProgramIDList#" index="ChildContractID">
				<cfset programObj.makeRFA(ChildContractID, request.AccessStructure.user_id) />
			</cfloop>
		</cfif>
	</cfif>

	<cfif appSettings.getbusinessconsiderations_on()>
		<cfset programObj.saveInternalComments(
					programId = cryp.value,
					internalComments = BUSINESS_CONSIDERATIONS) />
	</cfif>

	<CFQUERY NAME="saveRejected" datasource="#application.datasource#">
		UPDATE 	Contract_Main
		SET 	rejected = 0
		WHERE 	Contract_Main_ID = '#cryp.value#'
	</CFQUERY>


<!--- 	 Store All Approvable Positions
	<cfquery name="qUpdateApprovablePositions" datasource="#application.datasource#">
		EXEC Populate_Program_Approvable_Positions #cryp.value#
	</cfquery> --->


	<cfset LocationFrom = "UponRFA">
	<cfset Contract_Main_ID = cryp.value>


	<cfset ProgramFreightComponentType = ProgramManager.GetProgramFreightComponentType(programId = Contract_Main_ID) />

	<cfif ProgramFreightComponentType NEQ 0>
		<!--- Verify a non deleted version of the freigt exists.
			  If YES, then dont call the freight routine otherwise call the routine.
		 --->
		<cfset variables.freightExists = objProgramFreight.verifyValidFreight(Contract_Main_ID) />
		<cfif NOT variables.freightExists>
			<cfset objProgramFreight.CallPopulateProgramDistributorFreightThread(
					programID = Contract_Main_ID,
					userID = request.AccessStructure.user_id,
					sAction = "RFA") />

			<!---
			Here we can use ajax because the file "contract_approve_broker_action.cfm" which includes this file is loacting to next page using using javascript
			---->
			<!--- D26612 : Link to freight missing for DST's(Lbl 25165)
			Commenting below ajax call
			it is being replaced by above CallPopulateProgramDistributorFreightThread call
			--->
			<!--- Ajax script to call the "Populate Program Distributor Freight" routine asynchronously --->
			<!---
			<script type='text/javascript'>
				_ajaxConfig = {	'_cfscriptLocation':'/components/freight/FreightAjax.cfc','_jsscriptFolder':'/script/javascript/Ajax_JS/','debug':false};
			</script>
			<script type='text/javascript' src='/Script/javascript/Ajax_JS/ajax.js'></script>
			<script type="text/javascript">
				function callPopulateProgramDistributorFreight(programId)
				{
					DWREngine.setAsync(true);
					DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'callpopulateprogramdistributorfreight', programId, doNothing);
				}

				// This function is required for the execute signature but does nothing
				function doNothing(r){

					return void(0);
				}
				<cfoutput>
				callPopulateProgramDistributorFreight(#Contract_Main_ID#);
				</cfoutput>
			</script>
			--->
		</cfif>
	</cfif>

	<!--- Dev Note: KAL; D21050: Require freight approval when product added. --->
	<cfif (ProgramFreightComponentType NEQ 0) AND (programObj.isARevision(cryp.value)) >
		<cfset useLakebaseForCheckifproductsadded = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_revision_changes")>
		<cfif useLakebaseForCheckifproductsadded>
			<cftry>
				<cfset checkifproductsadded = application.oLakebase.toQuery(
					application.oLakebase.selectRows("program_revision_changes", { "select" = "products_added,products_added_fixedeqpricelist", "contract_main_id" = "eq.#Contract_Main_ID#", "deleted" = "eq.false" })
				)>
				<cfcatch type="any">
					<cfset useLakebaseForCheckifproductsadded = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForCheckifproductsadded>
			<cfquery name="checkifproductsadded" datasource="#application.datasource#">
				SELECT 	Products_Added, Products_Added_FixedEqPricelist
				FROM 	Program_Revision_Changes
				WHERE 	Contract_Main_ID = <cfqueryparam value="#Contract_Main_ID#" cfsqltype="cf_sql_integer">
				AND		Deleted = 0
			</cfquery>
		</cfif>
		<!---
		D23471: Route to transp when item added
		When "Products added for Fixed Price at List Price" have shortcut approval = YES
		Products_Added will not be set instead Products_Added_FixedEqPricelist will be set
		 --->
		 <!---D39573 :: Frt Apprvl Routing - Template setting
		 	checkifproductsadded.Products_Added neq 0 OR  --->
		<cfif checkifproductsadded.Products_Added_FixedEqPricelist neq 0>
			<!--- Reset Freight --->
			<!--- Dev Note: KAL; 11/9/2010; D25227: Freight Adjustment; Dont reset Freight info on reset to WIP --->
			<!--- <cfset objProgramFreight.ResetFreightInfo(Contract_Main_ID) /> --->
			<!--- Reset Freight Approval --->
			<cfset objProgramFreight.resetFreightApproval(Contract_Main_ID, request.AccessStructure.User_ID, 'Products Added - Reset Freight') />
		</cfif>
	</cfif>
	<!--- End Note: KAL; D21050: Require freight approval when product added. --->

	<!--- Dev Note: KAL; 9/13/2010; D23601: Margin Items Exclude --->
	<cfif appSettings.getMarginItemsExclude()>
		<cfstoredproc procedure="usp_set_margin_excluded_items" datasource="#application.datasource#">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" value="#Contract_Main_ID#" />
		</cfstoredproc>
	</cfif>
	<!--- End Note: KAL; 9/13/2010; D23601: Margin Items Exclude --->
	<cfif bAutoApproveProgram>
		<cfif Get_Profile_Settings.program_margin_approval_method IS 4> <!--- spending cap --->
			<cfset program_id = cryp.value />
			<cfinclude template="contract_approve_action_include.cfm" />
		<cfelse>
			<cfset form.approval_method = 5 /> <!--- layered --->
			<cfset form.Approved_By_User_ID = request.AccessStructure.user_id />
			<cfset Program_ID = cryp.value />
			<cfinclude template="Contract_layered_approve_action_Auto.cfm" />
			<!---D49082 :: Email settings for prg approval not working correctly START --->
			<cfset contract_main_id = cryp.value />
			<!--- Dev Note(49272) - On "Contract_layered_approve_action_Auto.cfm", "FORM.ApproveContract" gets set to Contract_main_ID.
			Resetting "FORM.ApproveContract" to CID below.
			--->
			<cfset FORM.ApproveContract  = Approve_Contract_ID>
			<cfset CloseWindow = 0>
			<cfinclude template="generate_approve_email.cfm">
			<!---D49082 :: Email settings for prg approval not working correctly END --->
		</cfif>
	<cfelse>
		<!--- Dev Note: Kal; D43870: Run Remote Approval Send on demand for users with Single option --->
		<cfoutput>
			<cfset rfaUserId = request.AccessStructure.User_ID />
			<cfset url.programId = cryp.value />
			<!--- Dont send email if manual selection of users is on --->
			<cfif GetSettings.Manual_Selection_Of_Approvers neq 1>
				<cfinclude template="/Scheduled/ApprovalViaEmailSendEmail.cfm" >
			</cfif>
			<cfset request.AccessStructure.User_ID = rfaUserId />
		</cfoutput>
		<!---Sends out an email notification upon the rfa request, and at a scheduled later date--->
		<cfset alreadySentRFAEmail = 0 />
		<CFQUERY NAME="checkIfAlreadySentRFAEmail" datasource="#application.datasource#">
			SELECT	RFA_Email_Sent
			FROM 		Contract_Main_Aux_Data
			WHERE 	Contract_Main_ID = '#Contract_Main_ID#'
		</CFQUERY>
		<cfif checkIfAlreadySentRFAEmail.recordCount>
			<cfif checkIfAlreadySentRFAEmail.RFA_Email_Sent EQ "1">
				<cfset alreadySentRFAEmail = 0 />
			</cfif>
		</cfif>
		<!------ NEQ 2 (Not At Agree), send only to CRA (currently responsible for approval) users----->
		<cfif appSettings.getRFAEmailEvent() NEQ 2 AND alreadySentRFAEmail EQ 0>
			<cfinclude template="/ANYTHING_AUTOMATED/EMAIL/rfa_program_emailer.cfm">
		</cfif>

	</cfif>
