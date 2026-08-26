<cfparam name="FORM.Pay_Brokerage" 	default="EMPTY">
		<cfset program_id = cryp.value>
		<!--- If the approval date is after the start date do something 
		<CFIF dateformat(now(), 'm/d/yyy') GT dateformat(GetContractInfo.Contract_Start_Date, 'm/d/yyy')>
		<CFELSE>
		</CFIF>--->
		

		<!---if payment cycle is handled at the discount level then lock payment cycles --->
		<cfif appSettings.getPaymentCycleAtDiscountType()>
			<cfset CreateObject("component", "components.programs.PaymentCycleManager").lockPaymentCycles(program_id) />
		</cfif>
			<CFQUERY NAME="CSLGetContractInfo" datasource="#application.datasource#">
		SELECT Program_Control_Panel_Options.ProgramControl_Panel_Options_ID,
		Program_Control_Panel_Options.Created_Type, Contract_Main.*,
			Program_Control_Panel_Options.BidRequestStatusOn, 
			Program_Control_Panel_Options.BidRequestStatusChangePgmStatus,
 		dbo.Program_Control_Panel_Options.Generic_Type,
		 Program_Control_Panel_Options.revision_not_allowed
		 ,Pullbacks_On,is_pullback_corporate_deal,pullback_from_corporate
		FROM Contract_Main
			INNER JOIN	Program_Control_Panel_Options
			ON (Contract_Main.ProgramType_ID =  Program_Control_Panel_Options.ProgramControl_Panel_Options_ID)
		WHERE Contract_Main_ID = '#program_id#'
	</CFQUERY>
		<cfset useLakebaseForcheckifrevision = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForcheckifrevision>
	<cftry>
		<cfset checkifrevision = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#program_id#",
				"select" = "is_a_revision,contract_number"
			}), "is_a_revision,contract_number"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheckifrevision = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheckifrevision>
<CFQUERY NAME="checkifrevision" datasource="#application.datasource#">
				SELECT Is_A_Revision,contract_number
				FROM Contract_main
				where Contract_Main_Id = #program_id#
		</CFQUERY>
</cfif> 
		
		<cfif checkifrevision.Is_A_Revision EQ 1>
<!--- if it just a manual revision and not a date exclusion program, remove any of the preactive programs, once the current program becomes active or preactive --->
	<!--- now get the maximum version of all the approved programs of this contract number and then update the current approved program with max(revision_number) + 1 --->
	<CFQUERY NAME="GetRevisionVersion" datasource="#application.datasource#">
		select ISNULL(max(ISNULL(revision_version,0)),0) as revisionversion
		from contract_main
		where contract_number like '%#checkifrevision.contract_number#%'
		and contract_main.Approved = 1
		and contract_main_id != #program_id#
	</CFQUERY>
	
	<CFQUERY NAME="UpdateRevisionVersion" datasource="#application.datasource#">
		UPDATE Contract_Main
		Set revision_version = #GetRevisionVersion.revisionversion# + 1
		WHERE Contract_Main_Id = #program_id#
	</CFQUERY>
	
</cfif>

	<cfset objProgram = CreateObject("component", "components.programs.program") />
	<!------ use this function always so that all different approval routines call the same function ----->
	<cfset objProgram.approveProgram(
						programId=program_id,
						userId=request.AccessStructure.User_ID,
						Pay_Brokerage=Form.Pay_Brokerage,
						BidRequestStatusChangePgmStatus= CSLGetContractInfo.BidRequestStatusChangePgmStatus,
						BidRequestStatusOn=CSLGetContractInfo.BidRequestStatusOn) />

				
		<cfset useLakebaseForcheckifparentisactive = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForcheckifparentisactive>
	<cftry>
		<cfset checkifparentisactive = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#program_id#",
				"select" = "contract_status_type_idx"
			}), "contract_status_type_idx"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheckifparentisactive = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheckifparentisactive>
<CFQUERY NAME="checkifparentisactive" datasource="#application.datasource#">
			SELECT contract_status_type_idx
			FROM Contract_main
			where Contract_Main_Id = #program_id#
	</CFQUERY>
</cfif> 

	<CFIF NOT IsDefined("GetSettings")>
		<CFQUERY NAME="GetSettings" datasource="#application.datasource#">
			SELECT	*
			FROM	dbo.Program_Control_Panel_Options
			WHERE ProgramControl_Panel_Options_ID = '#CSLGetContractInfo.ProgramControl_Panel_Options_ID#'
		</CFQUERY>
	</CFIF>
	
		<!--- If the Program has Date Exclusions turned on --->
		<cfif GetSettings.Date_Exclusions_ON EQ 1>
			<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
			
<!--- Get the Child Programs (Date Exclusion Programs) ID's --->
			<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(cryp.value,0)>

				<cfif getDateExclusionprogramIDs.Recordcount GT 0>	
						<cfset Approve_Program_ID_List = ValueList(getDateExclusionprogramIDs.Revision_Program_ID)>
					<cfloop list="#Approve_Program_ID_List#" index="ContractID">
							<CFQUERY NAME="ApproveContract" datasource="#application.datasource#">
								UPDATE Contract_Main
								Set Approval_Date = getdate(), Approved = 1, Approved_By_User_ID = '#request.AccessStructure.User_ID#'<!--- <CFIF FORM.Program_Is_A_Revision EQ 1>,Contract_Start_Date = '#FORM.start_date#',Contract_End_Date= '#FORM.end_date#'</CFIF> ---><CFIF FORM.Pay_Brokerage NEQ "EMPTY">, Pay_Brokerage = '#FORM.Pay_Brokerage#'</CFIF>
									,Is_Manual_Revision = Is_A_Revision,
										revision_version = (select max(revision_version) from contract_main where contract_number like '%#GetContractNumber.contract_number#%' and contract_status_type_idx > 3) + 1
								<!--- WHERE Contract_Main_Id  IN(#Approve_Program_ID_List#) --->
									  WHERE Contract_Main_Id = #ContractID#
							</CFQUERY>
					</cfloop>
				</cfif>
		</cfif>
										
				<CFQUERY NAME="getThisProgramsStatus" datasource="#application.datasource#">
					SELECT Contract_Status_Type_IDX, Revision_Of_Contract_Main_ID, Broker_User_ID, Contract_Number, Contract_Title
					FROM Contract_main
					WHERE Contract_main_ID = '#program_id#'
				</CFQUERY>
		
<!--- <!--- <!--- <!--- <!--- <!--- <!--- <!--- <!--- THIS SECTION FOR PROGRAM EXCLUSION REVISIONS ONLY ---> ---> ---> ---> ---> ---> ---> ---> --->
			<cfset useLakebaseForgetProgramExclusionData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_exclusions")>
<cfif useLakebaseForgetProgramExclusionData>
	<cftry>
		<cfset getProgramExclusionData = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_exclusions", {
				"original_program_id" = "eq.#program_id#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetProgramExclusionData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetProgramExclusionData>
<cfquery name="getProgramExclusionData" datasource="#application.datasource#">
				SELECT *
				FROM Program_Exclusions
				WHERE Original_Program_ID = '#program_id#' AND Deleted = 0
			</cfquery>
</cfif>
			
			<cfif getProgramExclusionData.recordcount GT 0>
				<!--- save a WDDX packe with the approved version of the Master program so it may be restored at the end of every exclusion period --->
				<cfset Program_ID_To_Replicate = cryp.value>
				<cfinclude template="replicate_program.cfm">
				<cfset LongTermData_ProgramID = Program_ID_To_Replicate>
				<cfset LongTermData_Packet = Duplicate(Program)>
				<cfinclude template="/Common_Files/Contracts/SAVE_LongTermWDDXProgramCopy.cfm">
				<cfdump var="#LongTermData_Packet#">
			</cfif>
<!--- <!--- <!--- <!--- <!--- <!--- <!--- <!--- <!--- THIS SECTION FOR PROGRAM EXCLUSION REVISIONS ONLY ---> ---> ---> ---> ---> ---> ---> ---> --->		
		
		<!--- check for revision if it is pre-active remove it --->
		<CFIF len(CSLGetContractInfo.Revision_Of_Contract_Main_ID) GT 0>
			<cfset useLakebaseForcheckParentStats = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForcheckParentStats>
	<cftry>
		<cfset checkParentStats = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#CSLGetContractInfo.Revision_Of_Contract_Main_ID#",
				"select" = "contract_main_id,contract_status_type_idx"
			}), "contract_main_id,contract_status_type_idx"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheckParentStats = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheckParentStats>
<CFQUERY NAME="checkParentStats" datasource="#application.datasource#">
				SELECT Contract_Main_ID, Contract_Status_Type_IDX
				FROM Contract_Main
				WHERE Contract_Main_ID = #CSLGetContractInfo.Revision_Of_Contract_Main_ID#
			</CFQUERY>
</cfif>

			<CFIF checkParentStats.Contract_Status_Type_IDX EQ getThisProgramsStatus.Contract_Status_Type_IDX>
				<cfset useLakebaseFordeleteParent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseFordeleteParent>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"contract_main_id" = "eq.#checkParentStats.Contract_Main_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteParent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteParent>
<CFQUERY NAME="deleteParent" datasource="#application.datasource#">
					UPDATE Contract_main
					SET deleted = 1
					where contract_main_id = '#checkParentStats.Contract_Main_ID#'
				</CFQUERY>
</cfif>
			</CFIF>
		</CFIF>
		
<cfif appSettings.getPullbacksOn()>
<!--- If pullbacks on and is not a corporate deal execute retro revision check for any BB that are already created for this program. --->
	<CFIF checkifrevision.Is_A_Revision EQ 1 and (GetSettings.generic_type EQ "Distributor Trade/Shelter" and GetSettings.Pullbacks_On EQ 1 and GetSettings.is_pullback_corporate_deal EQ 0 and GetSettings.pullback_from_corporate EQ 1) OR ((GetSettings.generic_type EQ "Operator Direct or HQ Programs" OR GetSettings.generic_type EQ "Operator-Deviated Pricing") and GetSettings.Pullbacks_On EQ 1)>
		<cfif CSLGetContractInfo.contract_start_date LT now()>
			<cfquery name="UpdatePullbackLog" datasource="#application.datasource#">
			exec Update_Pullback_Log_For_RetroRevisions <cfqueryparam value="#CSLGetContractInfo.contract_number#" cfsqltype="CF_SQL_VARCHAR">,<cfqueryparam value="#CSLGetContractInfo.contract_main_id#" cfsqltype="CF_SQL_INTEGER">
			</cfquery> 
		</cfif>
	</cfif>
	<!--- If pullbacks on and pullback from this program is on execute corporate revision check and insert default pullback rates into pullback details table and also check if any opr or Local BB created and make entries into pullbacks log table too. --->
	<!--- 19440: Moved the CFThread call to separate file as it was throwing an error "routines cannot be called twice in a template" when this page is called in a loop --->
	<cfif (GetSettings.generic_type EQ "Distributor Trade/Shelter" and GetSettings.Pullbacks_On EQ 1 and CSLGetContractInfo.pullback_from_this_program EQ 1)>
		<cfinclude template="/Common_Files/contracts/contract_revision_pullback_details.cfm">
	</cfif>
</cfif>

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
template_pullback_defaults.Opr_Loc_Template_Id,template_pullback_defaults.Pullback_Default_Rate 
	FROM template_pullback_defaults
	left join template_pullback_program_defaults
	on template_pullback_program_defaults.Corp_Template_Id = 
	template_pullback_defaults.Corp_Template_Id
	and template_pullback_program_defaults.program_id = #CSLGetContractInfo.contract_main_id#
	WHERE template_pullback_defaults.Corp_Template_Id = #GetSettings.ProgramControl_Panel_Options_ID#
	and ISNULL(template_pullback_program_defaults.Pullback_Default_Rate,100) = 0
	and template_pullback_program_defaults.Opr_Loc_Template_Id IS NULL
	</CFQUERY>
</CFIF>
--->
</cfif> <!--- Pullbacks end --->

		
		<CFSET contract_main_id = cryp.value>
		<CFSET generateReleaseProgramID = contract_main_id>
		
		 <cfinclude template="generate_approve_email.cfm">