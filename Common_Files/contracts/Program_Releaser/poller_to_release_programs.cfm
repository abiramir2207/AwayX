<!------
<CFSET Max_Retry_Count = 3>

<CFQUERY NAME="Retry_Releases" DATASOURCE="#application.datasource#">
	UPDATE	Program_Formula_Pricing_Release_Programs
	SET		Process_Status_History = Process_Status_History + ',' + CAST(Process_Status AS NVARCHAR(5)),
			Process_Status = 1
	WHERE
			((
			Process_Status > 1
			AND
			Process_Status < 60
			)
			OR
			Process_Status = -1
			)
			AND
			Check_Count < #Max_Retry_Count#
</CFQUERY>
 ----->
<CFQUERY NAME="checkForReleasePrograms" datasource="#application.datasource#">
	SELECT 	Program_Formula_Pricing_Release_Programs.Program_Formula_Pricing_Release_Program_ID, Program_Formula_Pricing_Release_Programs.Program_ID, Program_Formula_Pricing_Release_Programs.Process_Status,
			Program_Formula_Pricing_Release_Programs.Release_Type, Program_Formula_Pricing_Release_Programs.Program_Formula_Pricing_Period_ID
	FROM 	Program_Formula_Pricing_Release_Programs
			INNER JOIN	Program_Formula_Pricing_Periods
			ON
			Program_Formula_Pricing_Periods.Program_Formula_Pricing_Period_ID = Program_Formula_Pricing_Release_Programs.Program_Formula_Pricing_Period_ID
	WHERE 	Program_Formula_Pricing_Release_Programs.Process_Status = 1
	ORDER BY Program_Formula_Pricing_Periods.Release_Date
</CFQUERY>

<CFSET ListOfReleaseTypes = Valuelist(checkForReleasePrograms.Release_Type)>
<CFSET ListOfStatus = Valuelist(checkForReleasePrograms.Process_Status)>
<CFSET ListOfPrograms = Valuelist(checkForReleasePrograms.Program_ID)>
<CFSET ListOfProgram_Formula_Pricing_Period_ID = Valuelist(checkForReleasePrograms.Program_Formula_Pricing_Period_ID)>

<CFSET AllProgramsInQueue = 0>
<CFSET ProgramSummary_Sum = 0>


<CFLOOP INDEX="i" LIST="#ListOfStatus#">
	<CFSET ProgramSummary_Sum = ProgramSummary_Sum + i>
</CFLOOP>

<CFIF ListLen(ListOfPrograms) EQ ProgramSummary_Sum>
	<CFSET AllProgramsInQueue = 1>
</CFIF>

<CFIF AllProgramsInQueue EQ 1>
	<CFSET ListOfProgramsRecordIDS = Valuelist(checkForReleasePrograms.Program_Formula_Pricing_Release_Program_ID)>
	<CFSET releaseLoopCount = 1>

	<!--- loop through the programs to be replicated --->
	<CFLOOP INDEX="i" LIST="#ListOfPrograms#">

		<CFSET thisReleaseType = listgetat(ListOfReleaseTypes,releaseLoopCount)>
		<CFSET thisProgram_ID = i>
		<cfset thisProgram_Formula_Pricing_Period_ID = listgetat(ListOfProgram_Formula_Pricing_Period_ID,releaseLoopCount)>

		<CFSET thisProgram_Formula_Pricing_Release_Program_ID = ListGetAt(ListOfProgramsRecordIDS,releaseLoopCount)>

		<CFIF thisReleaseType EQ 2>

		<!--- status update: 20 = begin building program structure --->
		<cfset useLakebaseForUpdateStatus20 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_release_programs")>
		<cfif useLakebaseForUpdateStatus20>
			<cftry>
				<cfset application.oLakebase.updateRows("program_formula_pricing_release_programs",
					{ "program_formula_pricing_release_program_id" = "eq.#thisProgram_Formula_Pricing_Release_Program_ID#" },
					{ "process_status" = 20 }
				)>
				<cfcatch type="any">
					<cfset useLakebaseForUpdateStatus20 = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdateStatus20>
			<cfset useLakebaseForupdateTheProgramProcessStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_release_programs")>
<cfif useLakebaseForupdateTheProgramProcessStatus>
	<cftry>
		<cfset application.oLakebase.updateRows("program_formula_pricing_release_programs",
			{
				"program_formula_pricing_release_program_id" = "eq.#thisProgram_Formula_Pricing_Release_Program_ID#"
			},
			{
				"process_status" = "20"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateTheProgramProcessStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateTheProgramProcessStatus>
<CFQUERY NAME="updateTheProgramProcessStatus" datasource="#application.datasource#">
				UPDATE Program_Formula_Pricing_Release_Programs
				SET Process_Status = 20
				WHERE Program_Formula_Pricing_Release_Program_ID = '#thisProgram_Formula_Pricing_Release_Program_ID#'
			</CFQUERY>
</cfif>
		</cfif>

		<!--- build program structure --->
		<CFSET Program_ID_To_Replicate = thisProgram_ID>

		<cfset Error = 0>
		<cftry>
			<CFINCLUDE TEMPLATE="../replicate_program.cfm">
			<cfcatch type="Any">
				<cfset Error = 1>
				<!--- status update: -1 = some error --->
				<cfset useLakebaseForUpdateStatusNeg1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_release_programs")>
				<cfif useLakebaseForUpdateStatusNeg1>
					<cftry>
						<cfset application.oLakebase.updateRows("program_formula_pricing_release_programs",
							{ "program_formula_pricing_release_program_id" = "eq.#thisProgram_Formula_Pricing_Release_Program_ID#" },
							{ "process_status" = -1 }
						)>
						<cfcatch type="any">
							<cfset useLakebaseForUpdateStatusNeg1 = false>
						</cfcatch>
					</cftry>
				</cfif>
				<cfif NOT useLakebaseForUpdateStatusNeg1>
					<CFQUERY NAME="updateTheProgramProcessStatus" datasource="#application.datasource#">
						UPDATE Program_Formula_Pricing_Release_Programs
						SET Process_Status = -1
						WHERE Program_Formula_Pricing_Release_Program_ID = '#thisProgram_Formula_Pricing_Release_Program_ID#'
					</CFQUERY>
				</cfif>
				<CFRETHROW>
			</cfcatch>
		</cftry>


		<!--- status update: 30 = finished building program structure --->
		<CFQUERY NAME="updateTheProgramProcessStatus" datasource="#application.datasource#">
			UPDATE Program_Formula_Pricing_Release_Programs
			SET Process_Status = 30
			WHERE Program_Formula_Pricing_Release_Program_ID = '#thisProgram_Formula_Pricing_Release_Program_ID#'
		</CFQUERY>


		<!--- custom release modifications --->
		<CFSET Program.Basic_Information.Is_A_Revision = 1>
		<CFSET Program.Basic_Information.DELETED = 0>
		<CFSET Program.Basic_Information.Is_Manual_Revision = 0>



		<!--- make sure the revision of the newly created program is the program it was replicated from --->
		<CFSET Program.Basic_Information.Revision_of_Contract_Main_ID = thisProgram_ID>
		<CFSET Program.Basic_Information.Parent_Revised_Contract_Main_ID = thisProgram_ID>

		<!--- get release Date Information --->
		<cfset useLakebaseForgetPeriodInformation = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_periods")>
<cfif useLakebaseForgetPeriodInformation>
	<cftry>
		<cfset getPeriodInformation = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_formula_pricing_periods", {
				"program_formula_pricing_period_id" = "eq.#thisProgram_Formula_Pricing_Period_ID#",
				"select" = "start_date,end_date,release_date,is_current_period"
			}), "start_date,end_date,release_date,is_current_period"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPeriodInformation = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPeriodInformation>
<CFQUERY NAME="getPeriodInformation" datasource="#application.datasource#">
			SELECT Start_Date,End_Date,Release_Date,Is_Current_Period
			FROM Program_Formula_Pricing_Periods
			WHERE Program_Formula_Pricing_Period_ID = '#thisProgram_Formula_Pricing_Period_ID#'
		</CFQUERY>
</cfif>
		<CFSET Program.Basic_Information.Contract_Start_Date = getPeriodInformation.Start_Date>
		<CFIF DateDiff("d", getPeriodInformation.End_Date, Now()) GT 0><!---- if period is already over ----->
			<CFSET Program.Basic_Information.DELETED = 1>
		</CFIF>

		<CFIF DATEDIFF("d", Program.Basic_Information.Contract_Start_Date, Program.Basic_Information.Contract_End_Date) LT 0>
			<!------ don't release this as the start date is after parent's end date ----->
			<!--- status update: 60 = should not come up in release list next time --->
			<CFQUERY NAME="updateTheProgramProcessStatus" datasource="#application.datasource#">
				UPDATE Program_Formula_Pricing_Release_Programs
				SET Process_Status = 60
				WHERE Program_Formula_Pricing_Release_Program_ID = '#thisProgram_Formula_Pricing_Release_Program_ID#'
			</CFQUERY>

			<!------ Make the period inactive, otherwise it'll try to release again ----->
			<cfset useLakebaseForupdatePeriodStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_periods")>
<cfif useLakebaseForupdatePeriodStatus>
	<cftry>
		<cfset application.oLakebase.updateRows("program_formula_pricing_periods",
			{
				"program_formula_pricing_period_id" = "eq.#thisProgram_Formula_Pricing_Period_ID#"
			},
			{
				"process_by_system" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdatePeriodStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdatePeriodStatus>
<CFQUERY NAME="updatePeriodStatus" datasource="#application.datasource#">
				UPDATE 	Program_Formula_Pricing_Periods
				SET 	Process_By_System = 1
				WHERE
						Program_Formula_Pricing_Period_ID = '#thisProgram_Formula_Pricing_Period_ID#'
			</CFQUERY>
</cfif>
		<CFELSE>
			<!------ Do release ----->

			<!--- establish program release status --->
			<CFIF Program.Basic_Information.ON_RELEASE_CONTRACT_STATUS_TYPE_IDX EQ 2>
				<!--- RFA --->
				<CFSET Program.Basic_Information.Contract_Status_Type_IDX = 2>
				<CFSET Program.Basic_Information.Approved 				= "0">
				<CFSET Program.Basic_Information.Approval_Date 			= "NULL">
				<CFSET Program.Basic_Information.Approved_By_User_ID 	= "NULL">
			<CFELSE>
				<!--- preactive --->
				<CFSET Program.Basic_Information.Contract_Status_Type_IDX 	= 4>
				<CFSET Program.Basic_Information.Approved 					= 1>
			</CFIF>
			<CFSET ListOfKeysRepresentingARecord="ACTIVE,DELETED,DURATION,END_DATE,PROGRAM_FORMULA_PRICING_PERIOD_ID,PROGRAM_ID,RELEASE_DATE,START_DATE,CREATED_BY_SYSTEM,PROCESS_BY_SYSTEM,IS_CURRENT_PERIOD,FORCE_PRICE_CALCULATION_FOR_THIS_PERIOD">

			<!--- remove expired periods from program --->
			<CFSET AppedNewStructureToTree = 0>
			<CFSET PricingPeriodCollection = Program.Formula_Pricing.Periods>
			<CFSET DeleteCount  = 1>

			<CFLOOP INDEX="i" FROM="1" TO="#PricingPeriodCollection.recordcount#" STEP="1">
				<CFSET thisReleaseDate = DateFormat(evaluate("PricingPeriodCollection.Release_Date_#i#"), 'mm-dd-yyyy')>
				<CFSET thisPeriodStartDate = DateFormat(evaluate("PricingPeriodCollection.Start_Date_#i#"), 'mm-dd-yyyy')>
				<CFSET thisPeriodEndDate = DateFormat(evaluate("PricingPeriodCollection.End_Date_#i#"), 'mm-dd-yyyy')>

				<!------<CFIF thisReleaseDate LT DateFormat(Now(), 'mm-dd-yyyy')>----->
				<!------<CFIF thisPeriodEndDate LT DateFormat(Now(), 'mm-dd-yyyy')>----->
				<CFIF DateFormat(thisPeriodStartDate, 'm/d/yyyy') LT DateFormat(Program.Basic_Information.Contract_Start_Date, 'm/d/yyyy')>
					<CFSET "PricingPeriodCollection.Process_By_System_#i#" = 1>
					<CFSET tempDCount = PricingPeriodCollection.RECORDCOUNT - DeleteCount>
					<CFIF (PricingPeriodCollection.RECORDCOUNT - DeleteCount) GT 0>
						<CFLOOP INDEX="theKey" LIST="#ListOfKeysRepresentingARecord#">
							<CFSET temp = StructDelete(PricingPeriodCollection,"#theKey#_#i#")>
						</CFLOOP>
						<CFSET DeleteCount  = DeleteCount + 1>
						<CFSET AppedNewStructureToTree = 1>
					</CFIF>
					<CFIF tempDCount EQ 0>
						<CFSET "PricingPeriodCollection.Created_By_System_#i#" = 1>
					</CFIF>
				</CFIF>

				<CFIF thisReleaseDate EQ DateFormat(Now(), 'mm-dd-yyyy')>
					<CFSET "PricingPeriodCollection.Created_By_System_#i#" = 1>
				</CFIF>

				<!--- only for formula release ------>
				<CFIF DateFormat(thisPeriodStartDate, 'm/d/yyyy') EQ DateFormat(Program.Basic_Information.Contract_Start_Date, 'm/d/yyyy')>
					<CFSET "PricingPeriodCollection.Is_Current_Period_#i#" = 1>
					<CFSET "PricingPeriodCollection.Process_By_System_#i#" = 1>
				<CFELSE>
					<CFSET "PricingPeriodCollection.Is_Current_Period_#i#" = 0>
				</CFIF>

				<CFIF DateFormat(thisReleaseDate, 'm/d/yyyy') LTE DateFormat(Now(), 'm/d/yyyy') OR DateFormat(thisReleaseDate, 'm/d/yyyy') LT DateFormat(Program.Basic_Information.Contract_Start_Date, 'm/d/yyyy')>
					<CFSET "PricingPeriodCollection.Process_By_System_#i#" = 1>
				<CFELSE>
					<CFSET "PricingPeriodCollection.Process_By_System_#i#" = 0>
				</CFIF>

			</CFLOOP>
			<CFIF AppedNewStructureToTree EQ 1>
				<!--- reindex if needed --->
				<CFSET PricingPeriodCollection = Program.Formula_Pricing.Periods>
				<CFSET tempPricingPeriodCollection = StructNew()>
				<CFSET ReIndexCount = 0>
				<CFLOOP INDEX="i" FROM="1" TO="#PricingPeriodCollection.recordcount#" STEP="1">
					<CFIF isdefined("PricingPeriodCollection.Release_Date_#i#")>
						<CFSET ReIndexCount = ReIndexCount + 1>
						<CFLOOP INDEX="theKey" LIST="#ListOfKeysRepresentingARecord#">
							<CFSET thisValue = evaluate("PricingPeriodCollection.#theKey#_#i#")>
							<CFSET temp = StructInsert(tempPricingPeriodCollection,"#theKey#_#ReIndexCount#",thisValue)>
						</CFLOOP>
					</CFIF>
				</CFLOOP>



				<CFSET RECORDCOUNT=ReIndexCount>
				<CFSET MASTER_TABLE=PricingPeriodCollection.MASTER_TABLE>
				<CFSET COLUMNLIST=PricingPeriodCollection.COLUMNLIST>


				<CFSET temp = StructClear(Program.Formula_Pricing.Periods)>

				<CFSET temp = StructAppend(Program.Formula_Pricing.Periods,tempPricingPeriodCollection)>
				<CFSET temp = StructINSERT(Program.Formula_Pricing.Periods,"RECORDCOUNT",RECORDCOUNT)>
				<CFSET temp = StructINSERT(Program.Formula_Pricing.Periods,"MASTER_TABLE",MASTER_TABLE)>
				<CFSET temp = StructINSERT(Program.Formula_Pricing.Periods,"COLUMNLIST",COLUMNLIST)>
			</CFIF>
			<!--- serialize packet --->
			<CFWDDX ACTION="CFML2WDDX" INPUT="#Program#" OUTPUT="Program_Packet" USETIMEZONEINFO="Yes">

			<!--- get application install path --->
			<!--- create usable directory information --->
			<CFSET The_File_Location = Application.Doc_Path & "\temp_files\contracts\XML_Programs\#replace('#Createuuid()##createuuid()#', ' -','','ALL')#.xml">
			<!--- end create usable directory information --->

			<!--- save the wddx packet to the disk because i cant pull the entire packet from the db easily--->
			<CFSET XML_File_Location = The_File_Location>
			<CFFILE ACTION="WRITE" FILE="#XML_File_Location#" OUTPUT="#Program_Packet#" ADDNEWLINE="Yes">

		 	<CFQUERY NAME="savePacket" datasource="#application.datasource#">
				SET NOCOUNT ON
				INSERT INTO Contract_Renewal_Packets
				(Packet_Data, XML_File_Location)
				VALUES
				('#Program_Packet#', '#XML_File_Location#')

				SELECT Contract_Renewal_Packets_ID = @@IDENTITY
				SET NOCOUNT OFF
			</CFQUERY>

			<!--- status update: 40 = XML Packet Written to harddrive and database --->
			<CFQUERY NAME="updateTheProgramProcessStatus" datasource="#application.datasource#">
				UPDATE Program_Formula_Pricing_Release_Programs
				SET Process_Status = 40
				WHERE Program_Formula_Pricing_Release_Program_ID = '#thisProgram_Formula_Pricing_Release_Program_ID#'
			</CFQUERY>


			<!--- status update: 50 = Program being process (data being replicated to the database) --->
			<CFQUERY NAME="updateTheProgramProcessStatus" datasource="#application.datasource#">
				UPDATE Program_Formula_Pricing_Release_Programs
				SET Process_Status = 50
				WHERE Program_Formula_Pricing_Release_Program_ID = '#thisProgram_Formula_Pricing_Release_Program_ID#'
			</CFQUERY>

	 		<!--- write program copy to the database  --->
			<CFSET FORM.CONTRACT_RENEWAL_PACKETS_ID = savePacket.CONTRACT_RENEWAL_PACKETS_ID>
			<CFINCLUDE TEMPLATE="../replicate_program_action.cfm">

			<!--- status update: 60 = Program Processing Finished --->
			<CFQUERY NAME="updateTheProgramProcessStatus" datasource="#application.datasource#">
				UPDATE Program_Formula_Pricing_Release_Programs
				SET Process_Status = 60
				WHERE Program_Formula_Pricing_Release_Program_ID = '#thisProgram_Formula_Pricing_Release_Program_ID#'
			</CFQUERY>

			<CFQUERY NAME="updatePeriodStatus" datasource="#application.datasource#">
				UPDATE Program_Formula_Pricing_Periods
				SET Process_By_System = 1, Force_Price_Calculation_For_This_Period = 0
				WHERE Program_Formula_Pricing_Period_ID = '#thisProgram_Formula_Pricing_Period_ID#'
			</CFQUERY>

			<cfset useLakebaseForgetThisProgramsStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetThisProgramsStatus>
	<cftry>
		<cfset getThisProgramsStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#thisProgram_ID#",
				"select" = "contract_status_type_idx,revision_of_contract_main_id"
			}), "contract_status_type_idx,revision_of_contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetThisProgramsStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetThisProgramsStatus>
<CFQUERY NAME="getThisProgramsStatus" datasource="#application.datasource#">
				SELECT Contract_Status_Type_IDX, Revision_Of_Contract_Main_ID
				FROM Contract_main
				WHERE Contract_main_ID = '#thisProgram_ID#'
			</CFQUERY>
</cfif>

			<cfset useLakebaseForgetReplicantProgramsStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetReplicantProgramsStatus>
	<cftry>
		<cfset getReplicantProgramsStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#Renewed_Program_ID#",
				"select" = "contract_status_type_idx,revision_of_contract_main_id"
			}), "contract_status_type_idx,revision_of_contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetReplicantProgramsStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetReplicantProgramsStatus>
<CFQUERY NAME="getReplicantProgramsStatus" datasource="#application.datasource#">
				SELECT Contract_Status_Type_IDX, Revision_Of_Contract_Main_ID
				FROM Contract_main
				WHERE Contract_main_ID = '#Renewed_Program_ID#'
			</CFQUERY>
</cfif>


			<!--- if revision is same status as its parent remove the parent --->
			<CFIF len(getReplicantProgramsStatus.Revision_Of_Contract_Main_ID) GT 0>
				<CFIF getReplicantProgramsStatus.Contract_Status_Type_IDX EQ getThisProgramsStatus.Contract_Status_Type_IDX>
					<!------
					Let the trigger delete it
					<CFQUERY NAME="deleteParent" datasource="#application.datasource#">
						UPDATE Contract_main
						SET deleted = 1
						where contract_main_id = '#Program_ID_To_Replicate#'
					</CFQUERY>
					----->
				</CFIF>
			</CFIF>

			<!--- this update forces UPDATE Stored Procs To Run Which = GOOD --->
			<cfset useLakebaseForForceTriggersToExecute = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForForceTriggersToExecute>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"contract_main_id" = "eq.#Renewed_Program_ID#"
			},
			{
				"deleted" = "#Program_Packet.Basic_Information.DELETED#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForForceTriggersToExecute = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForForceTriggersToExecute>
<CFQUERY NAME="ForceTriggersToExecute" datasource="#application.datasource#">
				UPDATE Contract_Main
				SET Deleted = '#Program_Packet.Basic_Information.DELETED#'
				WHERE Contract_Main_ID = '#Renewed_Program_ID#'
			</CFQUERY>
</cfif>


			<!--- GET NEW STATUS AFTER UPDATING --->
			<cfset useLakebaseForGetNewStatusAfterUpdate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetNewStatusAfterUpdate>
	<cftry>
		<cfset GetNewStatusAfterUpdate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#Renewed_Program_ID#",
				"select" = "contract_status_type_idx,revision_of_contract_main_id,parent_revised_contract_main_id"
			}), "contract_status_type_idx,revision_of_contract_main_id,parent_revised_contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetNewStatusAfterUpdate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetNewStatusAfterUpdate>
<CFQUERY NAME="GetNewStatusAfterUpdate" datasource="#application.datasource#">
				SELECT Contract_Status_Type_IDX,Revision_Of_Contract_Main_ID,PARENT_REVISED_CONTRACT_MAIN_ID
				FROM Contract_Main
				WHERE Contract_Main_ID = '#Renewed_Program_ID#'
			</CFQUERY>
</cfif>
			<CFSET New_Contract_Status_Type_IDX = GetNewStatusAfterUpdate.Contract_Status_Type_IDX>

			<CFSET IsParent = 0>

			<CFIF len(GetNewStatusAfterUpdate.PARENT_REVISED_CONTRACT_MAIN_ID) EQ 0>
				<CFSET IsParent = 1>
			</CFIF>

			<!--- if the revision is a RFA and there is a RFA OR WIP for the parent remove the existing RFA or WIP --->
			<CFIF New_Contract_Status_Type_IDX EQ 2>
				<CFQUERY NAME="getExistingRFAForThisParent" datasource="#application.datasource#">
					SELECT Contract_Main_ID
					FROM Contract_Main
					WHERE
						<CFIF IsParent EQ 1>
							Contract_main_ID = '#getReplicantProgramsStatus.Revision_Of_Contract_Main_ID#'
						<CFELSE>
							Revision_Of_Contract_Main_ID = '#getReplicantProgramsStatus.Revision_Of_Contract_Main_ID#'
						</CFIF>
						AND	Contract_Status_Type_IDX in (1,2)
						AND	Deleted = 0
						AND Contract_Main_ID <> '#Renewed_Program_ID#'
				</CFQUERY>

				<CFIF getExistingRFAForThisParent.recordcount GT 0>
					<CFQUERY NAME="removeExistingRFA" datasource="#application.datasource#">
						UPDATE Contract_Main
						SET Deleted = 1
						WHERE Contract_Main_ID IN(#valuelist(getExistingRFAForThisParent.contract_main_ID)#)
					</CFQUERY>
				</CFIF>
			</CFIF>

			<!--- if the revision is a PREACTIVE and there is a PREACTIVE for the parent remove the existing PREACTIVE --->
			<!-------
			<!------------ Let the first pre active go active first and
						then when the second pre active goes active it should remove the first sibling -------------------------->
			<CFIF New_Contract_Status_Type_IDX EQ 4>
				<CFQUERY NAME="getExistingPREACTIVEForThisParent" datasource="#application.datasource#">
					SELECT Contract_Main_ID
					FROM Contract_Main
					WHERE
						<CFIF IsParent EQ 1>
							Contract_main_ID = '#getReplicantProgramsStatus.Revision_Of_Contract_Main_ID#'
						<CFELSE>
							Revision_Of_Contract_Main_ID = '#getReplicantProgramsStatus.Revision_Of_Contract_Main_ID#'
						</CFIF>
						AND	Contract_Status_Type_IDX = 4
						AND	Deleted = 0
						AND Contract_Main_ID <> '#Renewed_Program_ID#'
				</CFQUERY>

				<CFIF getExistingPREACTIVEForThisParent.recordcount GT 0>
					<CFQUERY NAME="removeExistingPREACTIVE" datasource="#application.datasource#">
						UPDATE Contract_Main
						SET Deleted = 1
						WHERE Contract_Main_ID IN(#valuelist(getExistingPREACTIVEForThisParent.contract_main_ID)#)
					</CFQUERY>
				</CFIF>
			</CFIF>
			---------------->

			<!--- if the revision is a ACTIVE and there is a ACTIVE for the parent remove the existing ACTIVE --->
			<CFIF New_Contract_Status_Type_IDX GTE 5>
				<CFQUERY NAME="getExistingACTIVEForThisParent" datasource="#application.datasource#">
					SELECT Contract_Main_ID
					FROM Contract_Main
					WHERE
						<CFIF IsParent EQ 1>
							Contract_main_ID = '#getReplicantProgramsStatus.Revision_Of_Contract_Main_ID#'
						<CFELSE>
							Revision_Of_Contract_Main_ID = '#getReplicantProgramsStatus.Revision_Of_Contract_Main_ID#'
						</CFIF>
						AND	Contract_Status_Type_IDX >= 5
						AND	Deleted = 0
						AND Contract_Main_ID <> '#Renewed_Program_ID#'
				</CFQUERY>

				<CFIF getExistingACTIVEForThisParent.recordcount GT 0>
					<CFQUERY NAME="removeExistingACTIVE" datasource="#application.datasource#">
						UPDATE Contract_Main
						SET Deleted = 1
						WHERE Contract_Main_ID IN(#valuelist(getExistingACTIVEForThisParent.contract_main_ID)#)
					</CFQUERY>
				</CFIF>
			</CFIF>

			<CFSET generateReleaseProgramID = thisProgram_ID>
			<CFSET generateRelease_GeneratePrices = 1>
			<CFINCLUDE TEMPLATE="../Contract_Formula_Pricing_Periods_Generate_Prices_For_Release.cfm">

			<CFSET generateReleaseProgramID = Renewed_Program_ID>
			<CFSET generateRelease_GeneratePrices = 1>
			<CFINCLUDE TEMPLATE="../Contract_Formula_Pricing_Periods_Generate_Prices_For_Release.cfm">

			</CFIF><!------ donly release if start date is before or equal to parent's end date ----->

			<CFELSEIF thisReleaseType EQ 1>

				<CFSET generateReleaseProgramID = thisProgram_ID>

				<CFSET generateRelease_GeneratePrices = 1>
				<CFINCLUDE TEMPLATE="../Contract_Formula_Pricing_Periods_Generate_Prices_For_Release.cfm">


				<!--- status update: 60 = Program Processing Finished --->
				<CFQUERY NAME="updateTheProgramProcessStatus" datasource="#application.datasource#">
					UPDATE Program_Formula_Pricing_Release_Programs
					SET Process_Status = 60
					WHERE Program_Formula_Pricing_Release_Program_ID = '#thisProgram_Formula_Pricing_Release_Program_ID#'
				</CFQUERY>

				<CFQUERY NAME="updatePeriodStatus" datasource="#application.datasource#">
					UPDATE Program_Formula_Pricing_Periods
					SET Process_By_System = 1, Force_Price_Calculation_For_This_Period = 0
					WHERE Program_Formula_Pricing_Period_ID = '#thisProgram_Formula_Pricing_Period_ID#'
				</CFQUERY>

			<CFELSE>

			</CFIF>

		<CFSET releaseLoopCount = releaseLoopCount + 1>

	</CFLOOP>
	<CFIF ListLen(ListOfPrograms, ",") GT 0>
		<CFSET Send_Mail_To = "saru@awayx.com;dkunnath@awayx.com">
		<CFMAIL TO="#Send_Mail_To#"
			FROM="forgetrade@bigredflame.com"
			SUBJECT="#CGI.SERVER_NAME# Program Releaser Information (Starting Set_Contract_Status)"
			TYPE="HTML">
			Starting Set_Contract_Status.....<br>
			#Now()#<br>
			#CGI.SERVER_NAME#
			<CFDUMP VAR="#checkForReleasePrograms#">
		</CFMAIL>

		<CFQUERY NAME="UpdateAllProgramStatus" datasource="#application.datasource#">
			EXEC Set_Contract_Status
			--EXEC Set_Contract_Deleted_Status
			--EXEC PROGRAM_FORMULA_PRICING
		</CFQUERY>

		<CFMAIL TO="#Send_Mail_To#"
			FROM="forgetrade@bigredflame.com"
			SUBJECT="#CGI.SERVER_NAME# Program Releaser Information (Set_Contract_Status Over)"
			TYPE="HTML">
			Set_Contract_Status Over .....<br>
			#Now()#<br>
			#CGI.SERVER_NAME#
		</CFMAIL>
	</CFIF>
</CFIF>

<!--- THIS SECTION FOR PROGRAM EXCLUSION REVISIONS ONLY --->
<cfquery name="getProgramsToRenew" datasource="#application.datasource#">
	SELECT     dbo.LongTermWDDXProgramCopy.PacketFilename, dbo.LongTermWDDXProgramCopy.Deleted, dbo.Program_Exclusions.ReviseOriginalProgram,
                      dbo.Program_Exclusions.Original_Program_ID, dbo.Program_Exclusions.Revision_Program_ID, dbo.Program_Exclusions.Program_Exclusion_ID
	FROM         dbo.Program_Exclusions INNER JOIN
                      dbo.LongTermWDDXProgramCopy ON dbo.Program_Exclusions.Original_Program_ID = dbo.LongTermWDDXProgramCopy.Program_ID
	WHERE     (dbo.LongTermWDDXProgramCopy.Deleted = '0') AND (dbo.Program_Exclusions.Deleted = 0) AND
                      (dbo.Program_Exclusions.ReviseOriginalProgram = 1) AND (dbo.Program_Exclusions.ProgramHasBeenRevised = 0)
</cfquery>

<cfif getProgramsToRenew.Recordcount GT 0>
	<cfloop query="getProgramsToRenew">

	<cfset LongTermWDDXProgramCopy_Directory = "#Application.Doc_Path#\data_files\created\contracts\LongTermWDDXProgramCopy\">
	<cfset LongTermWDDXProgramCopy_Filename = getProgramsToRenew.PacketFilename>

	<cffile action="READ" file="#LongTermWDDXProgramCopy_Directory##LongTermWDDXProgramCopy_Filename#" variable="tmpPkt">
	<cfwddx action="WDDX2CFML" input="#tmpPkt#" output="ProgramWDDX">
	<cfset ProgramWDDX.Basic_Information.Revision_of_Contract_Main_ID = getProgramsToRenew.Revision_Program_ID>
	<cfset ProgramWDDX.Basic_Information.Parent_Revised_Contract_Main_ID = getProgramsToRenew.Original_Program_ID>

		<cfset ProgramWDDX.Basic_Information.Is_A_Revision = 1>
		<CFSET SUPPLIEDPROGRAMPACKET = Duplicate(ProgramWDDX)>
		<CFSET form.ProgramPacketSupplied = 1>

		<cfinclude template="/common_files/contracts/replicate_program_action.cfm">
		<cfset useLakebaseForflagProgramAsRevised = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_exclusions")>
<cfif useLakebaseForflagProgramAsRevised>
	<cftry>
		<cfset application.oLakebase.updateRows("program_exclusions",
			{
				"program_exclusion_id" = "eq.#getProgramsToRenew.Program_Exclusion_ID#"
			},
			{
				"reviseoriginalprogram" = "0",
				"programhasbeenrevised" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForflagProgramAsRevised = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForflagProgramAsRevised>
<cfquery name="flagProgramAsRevised" datasource="#application.datasource#">
			UPDATE Program_Exclusions
			SET
				ReviseOriginalProgram = 0,
				ProgramHasBeenRevised = 1
			WHERE Program_Exclusion_ID = '#getProgramsToRenew.Program_Exclusion_ID#'

		</cfquery>
</cfif>
		<hr>
		<cfdump var="#ProgramWDDX#">
				<hr>
	</cfloop>
</cfif>
