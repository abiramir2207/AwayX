<cfparam name="form.groupapproval" default="1">
<cfparam name="form.below_program_margin" default="1">
<cfparam name="form.program_margin_value" default="0">
<cfparam name="form.approvable_program_margin_value" default="0">
<cfparam name="ProgramAgree" default ="0">
<cfparam name="DoNotApprove" default ="0">
<cfparam name="form.Programid" default="">
<cfparam name="form.massapproval" default="0">
<cfparam name="form.Manual_Select_Approvers" default="0" />
<cfparam name="form.lAgreeReason" default="" />
<!--- Tim Ford - 03/15/2016: WR 57780 - Add default agree reason when coming from mass approve --->
<cfif form.massapproval eq 1>
	<cfset form.lAgreeReason = "You cannot mass approve this program." />
</cfif>

<cfparam name="form.bFromPlanner" default="0">

<cf_cryp type="de" string ="#form.programid#" key="#request.key#">
<cfset program_id = cryp.value>
<cfset FORM.ApproveContract = form.programid>
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset ApprovalProgramManager = CreateObject("component","components.programs.Approval.layered_program_approval") />

<cfset realProgramManager = CreateObject("component", "components.programs.ProgramManager").init() />
<cfset objProgram = CreateObject("component", "components.programs.program") />
<cfset objWorkFlowManager = createObject("component", "components.workflow.WorkFlowManager") />

<!------ save pullback approval ----->
<cfparam name="form.Approve_Pullback" 	default="0">
<cfif form.Approve_Pullback EQ 1>
	<cfset objProgram.approvePullback(
						programId=program_id,
						userId=request.AccessStructure.User_ID) />
</cfif>

<cfset getProgramInfo = ApprovalProgramManager.getProgramInfo(program_id)>

<!--- Tim Ford - 01/09/2015: WR 47065 Change Order - Program Approvals --->
<cfif form.Manual_Select_Approvers eq 1>
	<cfset ApprovalProgramManager.flagAsApprovedByUserProfile(program_id, request.AccessStructure.Profiles_ID, request.AccessStructure.User_ID) />
</cfif>

<!--- handle agree and approve list for show/hide groups --->
<cfif isDefined("form.checkAll") and appSettings.getShowORHideGroupsInViewMargin()>
	<cfif Not isDefined("form.AGREE") and isDefined("form.PREAGREELIST") and form.PREAGREELIST neq "">
		<!--- add into form.fieldname for products --->
		<cfloop list="#form.PREAGREELIST#" index="thisItem">
			<cfset fieldname = "ProductAgree_#replace(thisItem, "-", "_", "ALL")#" />
			<CFIF NOT ListFind(form.FIELDNAMES,fieldname,",")>
				<cfset form.FIELDNAMES = listAppend(form.FIELDNAMES,fieldname) />
				<cfset "form.#fieldname#" = 1 />
			</CFIF>
		</cfloop>
		<!--- add into form.fieldname for groups --->
		<cfset groupList = ApprovalProgramManager.getProductGroups(form.PREAGREELIST) >
		<cfif groupList neq "">
			<cfloop list="#groupList#" index="thisItem">
				<cfset fieldname = "GroupAgree_#replace(thisItem, "-", "_", "ALL")#" />
				<cfset form.FIELDNAMES = listAppend(form.FIELDNAMES,fieldname) />
				<cfset "form.#fieldname#" = 1 />
			</cfloop>
		</cfif>
	</cfif>
	<cfif Not isDefined("form.APPROVE") and isDefined("form.PREAPPROVELIST") and form.PREAPPROVELIST neq "">
		<cfloop list="#form.PREAPPROVELIST#" index="thisItem">
			<cfset fieldname = "ProductApprove_#replace(thisItem, "-", "_", "ALL")#" />
			<cfset form.FIELDNAMES = listAppend(form.FIELDNAMES,fieldname) />
			<cfset "form.#fieldname#" = 1 />
		</cfloop>
		<!--- add into form.fieldname for groups --->
		<cfset groupList = ApprovalProgramManager.getProductGroups(form.PREAPPROVELIST) >
		<cfif groupList neq "">
			<cfloop list="#groupList#" index="thisItem">
				<cfset fieldname = "GroupApprove_#replace(thisItem, "-", "_", "ALL")#" />
				<cfset form.FIELDNAMES = listAppend(form.FIELDNAMES,fieldname) />
				<cfset "form.#fieldname#" = 1 />
			</cfloop>
		</cfif>
	</cfif>
</cfif>


<cfif isdefined("form.programid") and program_id NEQ "" and program_id NEQ 0>

<CFLOOP list="#form.FIELDNAMES#" index="FIELDVALUE">
	<!--- check if its typecode or product --->
	<cfset findposition = #Find("_", FIELDVALUE,1)#>
	<cfif findposition NEQ 0>

		<CFIF FindNoCase("Group", FIELDVALUE,1)>

				<cfset getTypecodeId = Replace(Mid(FIELDVALUE, findposition+1, len(FIELDVALUE)),"_", "-", "ALL")>
				<cfquery name="getprogramtypecodes" datasource="#application.datasource#">
					SELECT *
					from Program_Type_Code_Approval_Info
					where Program_Id = #program_id#
					and Type_Code_Desc_Id = '#getTypecodeId#'
					<CFIF FindNoCase("GroupAgree", FIELDVALUE,1)>
					and user_id = '#request.AccessStructure.user_id#'
					and type = 2
					<cfelseif FindNoCase("GroupApprove", FIELDVALUE,1)>
					and type = 1
					</cfif>
					and deleted = 0
				</cfquery>

				<!--- 	if typecode is agreed --->
				<CFIF FindNoCase("GroupAgree", FIELDVALUE,1)>
					<CFIF getprogramtypecodes.recordcount EQ 0>
						<cfquery name="insertprogramtypecodes" datasource="#application.datasource#">
							INSERT INTO Program_Type_Code_Approval_Info
							(Program_Id,Type_Code_Desc_Id,Agree,type,User_Id)
							Values(#program_id#,'#getTypecodeId#',#evaluate(FIELDVALUE)#,2,'#request.AccessStructure.user_id#')
						</cfquery>
					<cfelse>
						<cfquery name="updateprogramtypecodes" datasource="#application.datasource#">
							UPDATE Program_Type_Code_Approval_Info
							SET Agree = #evaluate(FIELDVALUE)#
							where
							Program_Id = #program_id#
							and Type_Code_Desc_Id = '#getTypecodeId#'
							and user_id = '#request.AccessStructure.user_id#'
							and type = 2
							and deleted = 0
						</cfquery>
					</CFIF>
				<!--- if typecode is approved --->
				<cfelseif FindNoCase("GroupApprove", FIELDVALUE,1)>
					<CFIF getprogramtypecodes.recordcount EQ 0>
						<cfquery name="insertprogramtypecodes" datasource="#application.datasource#">
							INSERT INTO Program_Type_Code_Approval_Info
							(Program_Id,Type_Code_Desc_Id,Approve,type,User_Id)
							Values(#program_id#,'#getTypecodeId#',#evaluate(FIELDVALUE)#,1,'#request.AccessStructure.user_id#')
						</cfquery>
					<cfelse>
						<cfquery name="updateprogramtypecodes" datasource="#application.datasource#">
							UPDATE Program_Type_Code_Approval_Info
							SET
							Approve = #evaluate(FIELDVALUE)#
							where
							Program_Id = #program_id#
							and Type_Code_Desc_Id = '#getTypecodeId#'
							and user_id = '#request.AccessStructure.user_id#'
							and type = 1
							and deleted = 0
						</cfquery>
					</CFIF>
				</CFIF>
		<CFELSEIF FindNoCase("Product", FIELDVALUE,1)>
				<cfset getProductId = Replace(Mid(FIELDVALUE, findposition+1, len(FIELDVALUE)),"_", "-", "ALL")>
				<cfquery name="getprogramproducts" datasource="#application.datasource#">
					SELECT *
					from Program_Type_Code_Approval_Info
					where Program_Id = #program_id#
					and Product_Id = '#getProductId#'
					<CFIF FindNoCase("ProductAgree", FIELDVALUE,1)>
					and user_id = '#request.AccessStructure.user_id#'
					and type = 2
					<cfelseif FindNoCase("ProductApprove", FIELDVALUE,1)>
					and type = 1
					</cfif>
					and deleted = 0
				</cfquery>
				<!--- 	if product is agreed --->
				<CFIF FindNoCase("ProductAgree", FIELDVALUE,1)>
					<CFIF getprogramproducts.recordcount EQ 0>
						<cfquery name="getprogramproducts" datasource="#application.datasource#">
							INSERT INTO Program_Type_Code_Approval_Info
							(Program_Id,Product_Id,Agree,type,User_Id)
							Values(#program_id#,'#getProductId#',#evaluate(FIELDVALUE)#,2,'#request.AccessStructure.user_id#')
						</cfquery>
					<cfelse>
						<cfquery name="updateprogramproducts" datasource="#application.datasource#">
							UPDATE Program_Type_Code_Approval_Info
							SET Agree = #evaluate(FIELDVALUE)#
							where
							Program_Id = #program_id#
							and Product_Id = '#getProductId#'
							and user_id = '#request.AccessStructure.user_id#'
							and type = 2
							and deleted = 0
						</cfquery>
					</CFIF>
				<!--- if product is approved --->
				<cfelseif FindNoCase("ProductApprove", FIELDVALUE,1)>
					<CFIF getprogramproducts.recordcount EQ 0>
						<cfquery name="insertprogramtypecodes" datasource="#application.datasource#">
							INSERT INTO Program_Type_Code_Approval_Info
							(Program_Id, Product_Id, Approve, type, User_Id)
							Values(#program_id#,'#getProductId#',#evaluate(FIELDVALUE)#,1,'#request.AccessStructure.user_id#')
						</cfquery>
					<cfelse>
						<cfquery name="updateprogramtypecodes" datasource="#application.datasource#">
							UPDATE Program_Type_Code_Approval_Info
							SET Approve = #evaluate(FIELDVALUE)#
							where
							Program_Id = #program_id#
							and Product_Id = '#getProductId#'
							and user_id = '#request.AccessStructure.user_id#'
							and type = 1
							and deleted = 0
						</cfquery>
					</CFIF>
				</CFIF>
		</CFIF>
	</cfif>
</CFLOOP>

<!---- save budget information ----->
<cfif appSettings.getBudgetsFunctionalityOn()>
	<cfset BudgetManager = CreateObject("component", "components.budgets.BudgetManager").init() />
	<cfset BudgetManager.saveCommittedProgramBudgetPercentages(
				contractMainID = program_id,
				userID = request.AccessStructure.user_id,
				oForm = Form) />
</cfif>

<cfquery name="checkmodifyprogram" datasource="#application.datasource#">
	select 	modifying_program,
			is_a_revision,
			Revision_Of_Contract_Main_ID,
			revisiontypeA,
			revisiontypeB,
			revisiontypeC,
			program_revisiontype_executed,
			CMAD.Market_Price_Approved
	from 	contract_main
	inner join Contract_Main_Aux_Data CMAD
	on		CMAD.contract_main_id = contract_main.contract_main_id
	where 	contract_main.contract_main_id = <cfqueryparam value="#program_Id#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfif checkmodifyprogram.modifying_program EQ 1>
	<cfquery name="updateagreedprogram" datasource="#application.datasource#">
		update contract_main
		set
		modifying_program = 0
		where contract_main_id = <cfqueryparam value="#program_Id#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfquery name="getagreedmargins" datasource="#application.datasource#">
		select user_id
		from program_agree
		where programid =  <cfqueryparam value="#program_Id#" cfsqltype="CF_SQL_INTEGER">
		and below_program_margin = 1
		and cast(approvable_program_margin_value as decimal(20,1)) <= #form.program_margin_value#
	</cfquery>
	<cfif getagreedmargins.recordcount GT 0>
		<cfquery name="updateagreements" datasource="#application.datasource#">
		UPDATE Program_Type_Code_Approval_Info
		SET Approve = 1,
		type = 1
		where Program_Id = <cfqueryparam value="#program_Id#" cfsqltype="CF_SQL_INTEGER">
		and user_id in (#quotedvaluelist(getagreedmargins.user_id)#)
		and deleted = 0
		</cfquery>
	</cfif>

	<!--- Reset the shorcut routing flags as the user has finished modify agreement  --->
	<cfif checkmodifyprogram.is_a_revision>
		<CFQUERY NAME="reset_program_revisiontype_executed" datasource="#application.datasource#">
			UPDATE 	Contract_Main_Aux_Data
			SET 	program_revisiontype_executed = 0
			WHERE 	Contract_Main_ID = <cfqueryparam value="#program_Id#" cfsqltype="CF_SQL_INTEGER">
		</CFQUERY>
		<cfif appSettings.getRevisionTypesOn() EQ 1>
			<cfset MinorRevision = CreateObject("component", "components.programs.Revise_Type_Check").MinorReviseFieldsCheck(checkmodifyprogram.Revision_Of_Contract_Main_ID, program_Id) />
		</cfif>
	</cfif>
</cfif>

<!--- Requery as the value smight have now changed from the above MinorReviseFieldsCheck --->
<cfquery name="qProgramInfo" datasource="#application.datasource#">
	select 	modifying_program, is_a_revision, Revision_Of_Contract_Main_ID,
			revisiontypeA, revisiontypeB, revisiontypeC, program_revisiontype_executed
	from 	contract_main
	inner join Contract_Main_Aux_Data
	on		Contract_Main_Aux_Data.contract_main_id = contract_main.contract_main_id
	where 	contract_main.contract_main_id = <cfqueryparam value="#program_Id#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfif qProgramInfo.is_a_revision EQ 1 and qProgramInfo.program_revisiontype_executed EQ 0>
	<cfif (qProgramInfo.revisiontypeA EQ 1 OR qProgramInfo.revisiontypeB EQ 1 OR qProgramInfo.revisiontypeC EQ 1)>
		<cfset useLakebaseForCheckprod = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_revision_changes")>
		<cfif useLakebaseForCheckprod>
			<cftry>
				<cfset checkprod = application.oLakebase.toQuery(
					application.oLakebase.selectRows("program_revision_changes", { "select" = "products_added,products_removed", "contract_main_id" = "eq.#program_Id#" })
				)>
				<cfcatch type="any">
					<cfset useLakebaseForCheckprod = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForCheckprod>
			<cfquery name="checkprod" datasource="#application.datasource#">
				select 	products_added,products_removed
				from 	Program_Revision_Changes
				where 	contract_main_id = <cfqueryparam value="#program_Id#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		</cfif>
		<cfif checkprod.products_added GT 1 OR checkprod.products_removed GT 1>
			<cfset realProgramManager.setUserAgree(Program_ID, request.AccessStructure.User_ID, request.AccessStructure.Profiles_ID,form.below_program_margin,numberformat(form.program_margin_value, "______.__"),form.approvable_program_margin_value) />
			<cfset objWorkFlowManager.saveProgramAgreeReason(Program_ID, request.AccessStructure.User_ID, form.lAgreeReason) />
			<cfquery name="qUpdateApprovaltable" datasource="#application.datasource#">
				EXEC Populate_Program_Approvable_Positions #Program_ID#
			</cfquery>
		</cfif>
	</cfif>
</cfif>

<cfif Get_Profile_Settings.program_margin_approval_method IS 5 OR Get_Profile_Settings.program_margin_approval_method IS 7>
	 <cfset ProgramManager = CreateObject("component","components.programs.Approval.layered_program_approval") />
	<cfset getapprovedprogramtypes = ProgramManager.getapprovedprogramtypecodes(Program_ID)>
<cfelseif Get_Profile_Settings.program_margin_approval_method IS 6>
	 <cfset ProgramManager = CreateObject("component","components.programs.Approval.disposable_program_approval") />
	<cfset getapprovedprogramtypes = ProgramManager.getAllGroupMarginsApproved(Program_ID)>
</cfif>


<cfif form.groupapproval EQ 0>
<script>
	window.close();
</script>
<cfabort>
</cfif>

<cfset DoNotApprove = getapprovedprogramtypes.Recordcount>
<!--- If the user only agrees to the program --->
<cfif ProgramAgree eq 1>
	<cfset DoNotApprove = 1>
</cfif>

<CFIF DoNotApprove eq 0>
	<!------ If program is to be approved, check if this program has pullback rules, and if it needs approval ----->
	<cfset oProgram = CreateObject("component", "components.programs.program") />
	<cfset qGetProgramUserSettings = oProgram.getProgramUserSettings() />

	<cfif appSettings.getPullbacksOn() AND getProgramInfo.Pullback_Available EQ 1 AND getProgramInfo.Pullback_Approved EQ 0 AND qGetProgramUserSettings.Pullback_Requires_Approval EQ 1>
		<cfset DoNotApprove = 1 /><!------ cannot approve program until pullback is approved ----->
	</cfif>
</CFIF>

<CFIF DoNotApprove eq 0>
	<!------
	If program is to be approved,
	check if this program has freight, and if it needs approval,
	if yes, do not approve the program yet
	----->
	<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getShow_Fixed_Freight() eq 1
			AND	getProgramInfo.Freight_Approval_Required EQ 1
			AND getProgramInfo.Freight_Component_Type NEQ 0
			AND	getProgramInfo.Freight_Approved EQ 0>
		<cfset DoNotApprove = 1 /><!------ cannot approve program until freight is approved ----->
		<cfset objProgram.storeProgramApprovalInfo(
						programId=program_id,
						userId=request.AccessStructure.User_ID) />
	</cfif>
</CFIF>

<CFQUERY NAME="CSLGetContractInfo" datasource="#application.datasource#">
	SELECT Program_Control_Panel_Options.Created_Type, Contract_Main.*, dbo.Program_Control_Panel_Options.Generic_Type,Program_Control_Panel_Options.revision_not_allowed,
		Program_Control_Panel_Options.Market_Price, TF.Description AS Template_Filter_Description
	FROM Contract_Main
	INNER JOIN	Program_Control_Panel_Options
	ON (Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID)
	LEFT JOIN Template_Filters TF ON
	TF.Template_Filters_Id = Contract_Main.Template_Filters_Id
	WHERE Contract_Main_ID = '#program_id#'
</CFQUERY>

<CFIF DoNotApprove eq 0 AND CSLGetContractInfo.Market_Price EQ 1>
	<!--- Check Market Picing Approval before letting Program Approve --->
	<cfset objMarketPriceManager = CreateObject("component","mvc.Models.Template.MarketPriceManager") />
	<cfscript>
		if(!checkmodifyprogram.Market_Price_Approved && objMarketPriceManager.getCurrentMPList(program_id)){
			DoNotApprove = 1;
		}
	</cfscript>
</CFIF>

<CFIF DoNotApprove eq 0><!--- If program is to be approved (Milan - Label 9353 - 3/8/2006) --->


	<cfquery name="GetSettings" datasource="#application.datasource#">
		SELECT *
		FROM
			Program_Control_Panel_Options
		WHERE
			ProgramControl_Panel_Options_ID = '#CSLGetContractInfo.ProgramType_ID#'
	</cfquery>

	<cfset getThisProgramsStatus = ProgramManager.getThisProgramsStatus(Program_ID)>

	 <cfif appsettings.getsend_to_sap() and  TRIM(getSettings.generic_type) NEQ "Direct Pricing">
	 	 <CFQUERY NAME="updatecontractmain" datasource="#application.datasource#">
			select count(*) as count
			from
			contract_main
			where Sent_To_External_Client = 1
			and deleted = 0
		</CFQUERY>

	 	<cfif updatecontractmain.count GT 3>
			<DIV align="center"><font size="2" color="red">The server is currently sending the maximum allowable number of programs to SAP.  Please try your submission again later.</font></DIV>
			<script>
			window.setTimeout('window.close();', 7000);
			</script>
		<cfelse>
			<CFQUERY NAME="updatecontractmain" datasource="#application.datasource#">
				update contract_main
				set Sent_To_External_Client = 1
				where contract_main_id = #program_id#
				and deleted = 0
			</CFQUERY>
			<cfinclude template="send_data_SAP.cfm">
			<cfoutput><form name="FrmApproveAction" target="mywindowname" action="contract_edit_menu.cfm?CID=#FORM.programid#" method="post"></form></cfoutput>
			<script>
			FrmApproveAction.submit();
			window.setTimeout('window.close();', 5000);
			</script>
		</cfif>
		<cfabort>
	</cfif>


	<!---if payment cycle is handled at the discount level then lock payment cycles --->
	<cfif appSettings.getPaymentCycleAtDiscountType()>
		<cfset CreateObject("component", "components.programs.PaymentCycleManager").lockPaymentCycles(program_id) />
	</cfif>



	<cfset useLakebaseForGetContractNumber = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetContractNumber>
	<cftry>
		<cfset GetContractNumber = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#program_id#",
				"select" = "contract_number"
			}), "contract_number"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetContractNumber = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetContractNumber>
<CFQUERY NAME="GetContractNumber" datasource="#application.datasource#">
		select contract_number
		from contract_main
		where Contract_Main_Id = #program_id#
	</CFQUERY>
</cfif>

	<cfset useLakebaseForcheckifrevision = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForcheckifrevision>
	<cftry>
		<cfset checkifrevision = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#program_id#",
				"select" = "is_a_revision"
			}), "is_a_revision"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheckifrevision = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheckifrevision>
<CFQUERY NAME="checkifrevision" datasource="#application.datasource#">
			SELECT Is_A_Revision
			FROM Contract_main
			where Contract_Main_Id = #program_id#
	</CFQUERY>
</cfif>

	<cfif checkifrevision.Is_A_Revision EQ 1>
		<!--- now get the maximum version of all the approved programs of this contract number and then update the current approved program with max(revision_number) + 1 --->
		<CFQUERY NAME="GetRevisionVersion" datasource="#application.datasource#">
			select max(revision_version) as revisionversion
			from contract_main
			where contract_number like '%#GetContractNumber.contract_number#%'
			and contract_main.Approved = 1
			and contract_main_id != #program_id#
		</CFQUERY>

		<CFQUERY NAME="UpdateRevisionVersion" datasource="#application.datasource#">
			UPDATE Contract_Main
			Set revision_version = #GetRevisionVersion.revisionversion# + 1
			WHERE Contract_Main_Id = #program_id#
		</CFQUERY>

	</cfif>

	<CFPARAM NAME="FORM.Pay_Brokerage" DEFAULT="EMPTY">

	<!------ use this function always so that all different approval routines call the same function ----->
	<cfset objProgram.approveProgram(
						programId=program_id,
						userId=request.AccessStructure.User_ID,
						Pay_Brokerage=Form.Pay_Brokerage) />

	<!--- (start) If the Program has Date Exclusions turned on --->
	<cfif GetSettings.Date_Exclusions_ON EQ 1>
		<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
		<cfset getParentContractInfo = GenProgramManager.ParentProgramInfo(program_id)>

		<cfif getParentContractInfo.RecordCount eq 0>
			<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(program_id,0)>
		<cfelse>
			<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(program_id,1)>
		</cfif>
			<cfif getDateExclusionprogramIDs.Recordcount GT 0>
					<cfset Approve_Program_ID_List = ValueList(getDateExclusionprogramIDs.Revision_Program_ID)>
				<cfloop list="#Approve_Program_ID_List#" index="ContractID">
					<CFQUERY NAME="ApproveContract" datasource="#application.datasource#">
						UPDATE Contract_Main
						Set Approval_Date = getdate(),
						Approved = 1,
						Approved_By_User_ID = '#request.AccessStructure.User_ID#'
						,Is_Manual_Revision = Is_A_Revision,
						revision_version = (select max(revision_version) from contract_main where contract_number like '%#GetContractNumber.contract_number#%' and contract_status_type_idx > 3) + 1
						<!--- WHERE Contract_Main_Id IN (#Approve_Program_ID_List#) --->
						WHERE Contract_Main_Id = #ContractID#
					</CFQUERY>
				</cfloop>
			</cfif>
	</cfif>


	<cfif appSettings.getPullbacksOn()>
		<!--- If pullbacks on and is not a corporate deal execute retro revision check for any BB that are already created for this program. --->
		<!---	<CFIF checkifrevision.Is_A_Revision EQ 1 and (GetSettings.generic_type EQ "Distributor Trade/Shelter" and GetSettings.Pullbacks_On EQ 1 and GetSettings.is_pullback_corporate_deal EQ 0 and GetSettings.pullback_from_corporate EQ 1) OR ((GetSettings.generic_type EQ "Operator Direct or HQ Programs" OR GetSettings.generic_type EQ "Operator-Deviated Pricing") and GetSettings.Pullbacks_On EQ 1)>
		<cfif CSLGetContractInfo.contract_start_date LT now()>
			<cfquery name="UpdatePullbackLog" datasource="#application.datasource#">
			exec Update_Pullback_Log_For_RetroRevisions <cfqueryparam value="#CSLGetContractInfo.contract_number#" cfsqltype="CF_SQL_VARCHAR">,<cfqueryparam value="#CSLGetContractInfo.contract_main_id#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		</cfif>
		</cfif>--->
		<!--- If pullbacks on and pullback from this program is on execute corporate revision check and insert default pullback rates into pullback details table and also check if any opr or Local BB created and make entries into pullbacks log table too. --->
		<!--- 19440: Moved the CFThread call to separate file as it was throwing an error "routines cannot be called twice in a template" when this page is called in a loop --->
		<cfif (GetSettings.generic_type EQ "Distributor Trade/Shelter" and GetSettings.Pullbacks_On EQ 1 and CSLGetContractInfo.pullback_from_this_program EQ 1)>
			 <cfinclude template="/Common_Files/contracts/contract_revision_pullback_details.cfm">
		</cfif>

		<!--- if corporate program --->
		<cfif (GetSettings.generic_type EQ "Distributor Trade/Shelter" and GetSettings.Pullbacks_On EQ 1 and GetSettings.is_pullback_corporate_deal EQ 1)>
			<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
			<cfset qGetProfileTemplates = templateManager.getProfileTemplates(
							profileId = request.AccessStructure.Profiles_ID,
							forbidAccessType = 6,
							templateId = GetSettings.ProgramControl_Panel_Options_ID
							) />
			<!---
			Dev Note: Milan (48182) - Remove any insert/update to "template_pullback_program_defaults".
			This table is not being used anymore.
			--->
			<!---
			<CFIF qGetProfileTemplates.APPROVE EQ 0>
				<CFQUERY NAME="adddefaultrates" datasource="#application.datasource#">
					insert into template_pullback_program_defaults
					(program_id,Corp_Template_Id,Opr_Loc_Template_Id,Pullback_Default_Rate)
					SELECT distinct #CSLGetContractInfo.contract_main_id#, #GetSettings.ProgramControl_Panel_Options_ID#,
					template_pullback_defaults.Opr_Loc_Template_Id,
					template_pullback_defaults.Pullback_Default_Rate
					FROM template_pullback_defaults
					left join template_pullback_program_defaults
					on template_pullback_program_defaults.Corp_Template_Id =
					template_pullback_defaults.Corp_Template_Id
					and template_pullback_program_defaults.program_id = #CSLGetContractInfo.contract_main_id#
					WHERE template_pullback_defaults.Corp_Template_Id = #GetSettings.ProgramControl_Panel_Options_ID#
					and ISNULL(template_pullback_program_defaults.Pullback_Default_Rate,0) = 0
					and template_pullback_program_defaults.Opr_Loc_Template_Id IS NULL
				</CFQUERY>
			</CFIF>
			--->
		</cfif>

	</cfif>

	<CFSET generateReleaseProgramID = form.programid>
	<cfset contract_main_id = program_id>
	<cfset FORM.ApproveContract = form.programid>
	<cfset getThisProgramsStatus = ProgramManager.getThisProgramsStatus(Program_ID)>

	<cfif form.bFromPlanner eq 1>
		<script>
            <cfoutput>
            window.opener.location.href = "/planners/create/planner_program_create.cfm?bInit=1&programId=#contract_main_id#";
            </cfoutput>
			window.close();
		</script>
		<cfabort />
	</cfif>
	<cfinclude template="generate_approve_email.cfm">

<cfelse><!------ If program is not to be approved ----->
	<cfif form.BUSINESS_CONSIDERATIONS NEQ "">
		<CFQUERY NAME="updateBusinessConsiderations" datasource="#application.datasource#">
		UPDATE Contract_Main_Aux_Data
		SET Comments = '#form.BUSINESS_CONSIDERATIONS#'
		WHERE Contract_Main_ID = '#Program_ID#'
		</CFQUERY>
	</cfif>

		<!------ All products/type codes/type groups are agreed/approved to, so Set the flag as agreed for the whole program ----->
		<cfset realProgramManager.setUserAgree(Program_ID, request.AccessStructure.User_ID, request.AccessStructure.Profiles_ID,form.below_program_margin,numberformat(form.program_margin_value, "______.__"),form.approvable_program_margin_value) />
		<cfset objWorkFlowManager.saveProgramAgreeReason(Program_ID, request.AccessStructure.User_ID, form.lAgreeReason) />

		<!------ Update the Pending Approval table ----->
		<cfquery name="qUpdateApprovaltable" datasource="#application.datasource#">
			EXEC Populate_Program_Approvable_Positions #Program_ID#
		</cfquery>
		<CFSET AgreeEmailProgramId 	= Program_ID />
		<CFSET AgreeEmailUserId 	= request.AccessStructure.User_ID />
		<cfinclude template="/Common_Files/contracts/Send_Agree_Email.cfm">

<!--- Dev Note: Milan (22900)."mywindowname" is the name of the main appplication window. Here "target" is being
used to refresh the program summary page after agreeing to a program. This causes a problem when the user visits
from flex as now the program flex grid window is redirected to the program summary page as the window name of that
window is "mywindowname". There are a few scenarios to take care of here -

When program flex is off:
Redirecting the summary page, and so there is no new window.(Here we use the name of the main page "mywindowname").
This was already working.

When program flex is on:
We can visit the program summary page to agree to a program in 3 ways:
   a) Create program link from the main page
	 b) "Create program" from the flex grid
	 c) Click on program link from flex

In the above scenarios, we need to redirect the new window (summary page) and not the parent window, which is the
program flex grid. I have the same window name for the new window ("winSummary") in the above cases. Also, now
when program flex is On, we open the "Create Program" in a new window.

<cfif appSettings.getFlexProgramSearch()>
	<cfset targetpage = "winSummary_" & program_id>     <!--- 63687 - added program_id suffix due to changes in D61571 --->
<cfelse>
	<cfset targetpage = "mywindowname">
</cfif>
--->



	<!--- Dev Note: drachala; D28431: Close on RFA  and unlock  START
    Added/Changed: Added URL variable emailFax = 1 to display a pop-up in main page.--->
	<cfif massapproval EQ 0>
		<cfset targetpage = "winSummary_" & Program_ID>
		<script>
		    /* reloadFromVerticalPNL - attempt to grap a particular opened window */
		    let existingWin = window.open('', <cfoutput>'#targetpage#'</cfoutput>);
			if ( existingWin ) {
				// reload function in parent popup is available
				if ( typeof existingWin.reloadFromPopUp === "function" ) {
					existingWin.reloadFromPopUp( 1 );
				}
				/* the particular window did not exist - close it */
				else if ( existingWin.location.href === "about:blank" ) {
					existingWin.close();
				}
			}
			window.close();
		</script>

		<!--- <cfoutput><form name="FrmApproveAction" target="#targetpage#" action="contract_edit_menu.cfm?CID=#FORM.programid#&emailFax=1" method="post"></form></cfoutput>
		<script>
		FrmApproveAction.submit();
		window.close();
		</script> --->

	</cfif>
	<!--- End Dev Note: drachala; D28431: Close on RFA and unlock  --->
</cfif>



</cfif>