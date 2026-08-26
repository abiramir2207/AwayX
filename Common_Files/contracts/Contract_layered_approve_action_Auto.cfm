<cfparam name="form.groupapproval" 						default="1">
<cfparam name="form.below_program_margin" 				default="1">
<cfparam name="form.program_margin_value" 				default="0">
<cfparam name="form.approvable_program_margin_value"	default="0">
<cfparam name="form.approval_method" 					default="0">
<cfparam name="form.Approved_By_User_ID" 				default="">

<!--- <cfset FORM.ApproveContract = form.programid> --->
<cfset FORM.ApproveContract = Program_ID>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset ApprovalManager = CreateObject("component", "components.Programs.Approval.ApprovalManager") />
<cfset objProgram = CreateObject("component", "components.programs.program") />

<cfif program_id NEQ "" and program_id NEQ 0>

	<!---if payment cycle is handled at the discount level then lock payment cycles --->
	<cfif appSettings.getPaymentCycleAtDiscountType()>
		<cfset CreateObject("component", "components.programs.PaymentCycleManager").lockPaymentCycles(program_id) />
	</cfif>

	<CFQUERY NAME="GetContractInfo" datasource="#application.datasource#">
        SELECT Is_A_Revision,
               contract_number,
               Revision_Of_Contract_Main_ID,
               Contract_Status_Type_IDX,
               ProgramType_ID,
               contract_start_date,
               pullback_from_this_program,
               Program_Control_Panel_Options.BidRequestStatusOn,
               Program_Control_Panel_Options.BidRequestStatusChangePgmStatus,
               isnull(planner_ID, 0) as planner_Id
        FROM   contract_main
               INNER JOIN Program_Control_Panel_Options
                   ON Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
                where contract_main.Contract_Main_Id = #program_id#
	</CFQUERY>

	<cfquery name="GetSettings" datasource="#application.datasource#">
        SELECT dbo.Program_Control_Panel_Options.Generic_Type,
               Pullbacks_On,
               is_pullback_corporate_deal,
               pullback_from_corporate
        FROM   Program_Control_Panel_Options
        WHERE  ProgramControl_Panel_Options_ID = '#GetContractInfo.ProgramType_ID#'
	</cfquery>
	<cfset ApproveProgram = 1>
	<!---- save budget information ----->
	<cfif appSettings.getBudgetsFunctionalityOn() eq 1 and GetContractInfo.planner_Id eq 0 >
		<cfset qGetProgramInfo = objProgram.getProgramInfo(program_id) />
		<!--- When the "ByPass_Margin_Evaluation" template setting is off, then we take the user to the margin page,where they
		can view the budget information and then that information is then updated in the budget tables, where we can keep
		track of budget balances. When the "ByPass_Margin_Evaluation" template setting is on, then the user does not visit
		the margin page and so we need to update the budget tables here.
		--->
		<!--- D32318 Commented below if condition as it need to run when budget is ON and we are auto approving program
		Short cut auto approve was not effecting budgets due to below if condition
		--->
		<!---
		<cfif qGetProgramInfo.ByPass_Margin_Evaluation eq 1 OR (qGetProgramInfo.EZButton_On and qGetProgramInfo.EzButton_Auto_Approve_On)>
		--->
		<!------ update program spend of the program ----->
		<cfstoredproc procedure="PROGRAM_TRADE_SPEND_UPDATE" datasource="#application.datasource#">
		    <cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#program_id#" null="no">
		</cfstoredproc>
		<!--- D25715: Budgeting --->
		<cfset CONTRACT_MAIN_ID = program_id />
		<cfset getProgramInfo = qGetProgramInfo />

		<cfsilent>
		    <cfinclude template="advanced_budget_program_selection.cfm">
		</cfsilent>

		<cfif bUserCannotApproveBudget>
			<cfset ApproveProgram = 0 />
			<CFOUTPUT>
			<script language="javascript">
					alert('#Replace(sProgramBudgetMessage, ",", "\n")#.  This request will now route to the next level for approval.');
					window.close;
					mywindowname.location.href="contract_edit_menu.cfm?CID=#CID#";
			</script>
			</CFOUTPUT>
		</cfif>
	</cfif>
	<cfif ApproveProgram eq 1>
		<!---TSF: Label 10245 - Only get the Approved_By_User_ID from the parent if one wasn't passed --->
		<cfif not len(trim(form.Approved_By_User_ID))>
			<CFQUERY NAME="ParentContractInfo" DATASOURCE="#Application.Datasource#">
				SELECT Approved_By_User_ID
                FROM Contract_main
                WHERE Contract_Main_ID = #GetContractInfo.Revision_Of_Contract_Main_ID#
			</CFQUERY>
			<cfset form.Approved_By_User_ID = ParentContractInfo.Approved_By_User_ID />
		</cfif>
		<CFQUERY NAME="insertprogramtypecodes" DATASOURCE="#Application.Datasource#">
            INSERT INTO Program_Type_Code_Approval_Info (Program_Id, Product_Id, Approve, type, User_Id )
            SELECT DISTINCT #Program_ID#, BSA_Foodservice_Items_Master_ID, 1, 1, '#form.Approved_By_User_ID#'
            FROM   Contract_Products
            WHERE  Contract_Main_ID = #Program_ID#
                   AND is_group = 0
                   AND deleted = 0
		</CFQUERY>
	
		<CFQUERY NAME="insertprogramtypecodestypegroups" DATASOURCE="#Application.Datasource#">
			INSERT INTO Program_Type_Code_Approval_Info
			(Program_Id,Product_Id,Approve,Type,User_Id)
			SELECT	DISTINCT #Program_ID#,
			<cfif trim(form.approval_method) eq 6>
				BSA_Foodservice_Items_Master.Type_Group_Desc_ID,
			<cfelse>
				BSA_Foodservice_Items_Master.Type_Code_Desc_ID,
			</cfif>
			1,
			1,
			'#form.Approved_By_User_ID#'
			FROM	Contract_Products
			INNER JOIN BSA_Foodservice_Items_Master ON
			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
			AND BSA_Foodservice_Items_Master.Deleted = 0
			WHERE	Contract_Products.Contract_Main_ID = #Program_ID#
			AND		Contract_Products.IS_Group = 0
			AND		Contract_Products.Deleted = 0
		</CFQUERY>
	
		<cfif GetContractInfo.Is_A_Revision EQ 1>
			<!--- now get the maximum version of all the approved programs of this contract number and then update the current approved program with max(revision_number) + 1 --->
			<CFQUERY NAME="GetRevisionVersion" datasource="#application.datasource#">
				select max(revision_version) as revisionversion
				from contract_main
				where contract_number like '%#GetContractInfo.contract_number#%'
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
		<cfset objProgram.approveProgram(programId=program_id,
            		userId=form.Approved_By_User_ID,
            		Pay_Brokerage=Form.Pay_Brokerage,
            		BidRequestStatusChangePgmStatus= GetContractInfo.BidRequestStatusChangePgmStatus,
            		BidRequestStatusOn=GetContractInfo.BidRequestStatusOn) />

		<cfif appSettings.getPullbacksOn()>
		</cfif>

		<!--- check for revision if it is pre-active remove it --->
		<CFIF len(GetContractInfo.Revision_Of_Contract_Main_ID) GT 0>
			<CFQUERY NAME="checkParentStats" datasource="#application.datasource#">
				SELECT Contract_Main_ID, Contract_Status_Type_IDX
				FROM Contract_Main
				WHERE Contract_Main_ID = #GetContractInfo.Revision_Of_Contract_Main_ID#
			</CFQUERY>

			<CFIF checkParentStats.Contract_Status_Type_IDX EQ GetContractInfo.Contract_Status_Type_IDX>
				<CFQUERY NAME="deleteParent" datasource="#application.datasource#">
					UPDATE Contract_main
					SET deleted = 1
					where contract_main_id = '#checkParentStats.Contract_Main_ID#'
				</CFQUERY>
			</CFIF>
		</CFIF>
	</cfif>
</cfif>
