<!--- BillbackAutoManager.cfc - Copyright (c) 2004 Blacksmith Applications, Inc.--->
<!--- Created By: Tim Ford on 05/13/2005 --->
<!--- component to handle Auto Billbacks --->
<cfcomponent hint="Auto Billback Manager">

	<cffunction name="getBillbackComponents" returntype="query">
	
		<cfargument name="programId" required="false" default="" />
		
		<!---call populate periods SP first to make sure we have the payment periods for this program--->
		<cfloop index="programIndx" list="#arguments.programId#">
		
			<cfstoredproc procedure="SP_POPULATE_BILLBACK_PROGRAM_PAYMENT_PERIODS" datasource="#application.datasource#">
							
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#programIndx#" null="no">
				
			</cfstoredproc>
			
		</cfloop>
		
		<cfquery name="qGetComponents" datasource="#application.datasource#">
			SELECT 	Contract_Main.Contract_Number as Program_Number,
					SAP_Reference_ID = 'SAP Reference Number',
					Billback_Program_Payment_Period.Payment_Start_Date,
					Billback_Program_Payment_Period.Payment_End_Date,
					Discount_Type =
						CASE Billback_Program_Payment_Period.Discount_Type_ID
						WHEN 1 THEN 'Fixed'
						WHEN 2 THEN 'Rebate'
						WHEN 3 THEN 'Lump Sum'
						WHEN 4 THEN 'Growth'
						END,
					Component_Name =
						CASE Billback_Program_Payment_Period.Discount_Type_ID
						WHEN 1 THEN (SELECT Program_Fixed_Component_Name FROM Program_Fixed_Component_Name WHERE Program_Fixed_Component_Name_ID = Component_ID)
						WHEN 2 THEN (SELECT Program_Rebates_Component_Name FROM Program_Rebates_Component_Name WHERE Program_Rebates_Component_Name_ID = Component_ID)
						WHEN 3 THEN (SELECT Program_Lump_Sum_Name FROM Program_Lump_Sum_Name WHERE Program_Lump_Sum_Name_ID = Component_ID)
						WHEN 4 THEN (SELECT Component_Name FROM Program_Growth_Components WHERE Growth_Component_Name_ID = Component_ID)
						END,
					Billback_Program_Payment_Period.Discount_Type_ID,
					Billback_Program_Payment_Period.Program_ID,
					Billback_Program_Payment_Period.Component_ID,
					Billback_Program_Payment_Period.Payment_Cycle_ID,
					Billback_Program_Payment_Period.Program_Component_ID,
					B.BB_Code,
					B.Billback_id
			FROM 	Billback_Program_Payment_Period
					INNER JOIN Contract_Main ON
					Contract_Main.Contract_Main_ID = Billback_Program_Payment_Period.Program_ID
					Left Join Billback B on B.billback_id = Billback_Program_Payment_Period.billback_id
			WHERE	Billback_Program_Payment_Period.Program_ID IN (#LISTQUALIFY(arguments.programId,"'",",")#)
			AND		Billback_Program_Payment_Period.Payment_Start_Date <= (SELECT DATEADD(day,-(AutoBB_Notify_Days),getdate()) FROM Billback_Settings)
			--AND		Billback_Program_Payment_Period.Payment_End_Date <= (SELECT DATEADD(day,-(AutoBB_Notify_Days),getdate()) FROM Billback_Settings)
			/*AND		(Billback_Program_Payment_Period.billback_id is NULL 
					or cast(Billback_Program_Payment_Period.billback_id as VarChar(50)) = '') */
		</cfquery>
	
		<cfreturn qGetComponents />
		
	</cffunction>
	
	<cffunction name="saveBillback" output="false">
	
		<cfargument name="programId" type="numeric" required="false" default="" />
		<cfargument name="startDate" type="date" required="false" default="" />
		<cfargument name="endDate" type="date" required="false" default="" />
		<cfargument name="compId" required="false" default="" />
		<cfargument name="programCompId" required="false" default="" />
		<cfargument name="discountTypeID" required="false" default="" />
		<cfargument name="distributorId" required="false" default="" />

		<cfstoredproc procedure="SP_Auto_Create_BB_Distributor" datasource="#application.datasource#">
								
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#arguments.programID#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_DATE" dbVarName = "@@BILLBACK_START_DATE" value = "#arguments.startDate#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_DATE" dbVarName = "@@BILLBACK_END_DATE" value = "#arguments.endDate#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@Component_Id" value = "#arguments.compId#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@Program_Component_ID" value = "#arguments.programCompId#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@Discount_Type_Id" value = "#arguments.discountTypeID#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@DISTRIBUTOR_ID" value = "#arguments.distributorId#" null="no">
			<cfprocparam type="Out" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@@BILLBACK_ID" null="no" variable="rBBID">
					
		</cfstoredproc>
	
		<cfreturn rBBID />

	</cffunction>
	
	<cffunction name="setBillbackCreated" output="false">
	
		<cfargument name="billbackId" required="false" default="" />
		<cfargument name="startDate" type="date" required="false" default="" />
		<cfargument name="endDate" type="date" required="false" default="" />
		<cfargument name="programId" type="numeric" required="false" default="" />
		<cfargument name="discountTypeID" required="false" default="" />
		<cfargument name="paymentCycleID" required="false" default="" />
		<cfargument name="compId" required="false" default="" />
		<cfargument name="programCompId" required="false" default="" />
		
		
		
		
		<cfquery name="qGetComponents" datasource="#application.datasource#">
		
			UPDATE	Billback_Program_Payment_Period
			SET		Billback_Created = 1,
					Billback_Created_Date = getDate(),
					Billback_ID = '#arguments.billbackId#'
			WHERE	Payment_Start_Date = '#arguments.startDate#'
			AND		Payment_End_Date = '#arguments.endDate#'
			AND		Program_ID = '#arguments.programId#'
			AND		Discount_Type_ID = '#arguments.discountTypeID#'
			AND		Payment_Cycle_ID = '#arguments.paymentCycleID#'
			AND		Component_ID = '#arguments.compId#'
			AND		Program_Component_ID = '#arguments.programCompId#'
			
		</cfquery>
		
	</cffunction>
	
	<!--- Lump sums are auto paid on program approval --->
	<cffunction name="AutoPayLS" output="true">
		<cfargument name="Contract_Main_ID" required="true" type="numeric"/>
		<cfargument name="User_Approved_ID" required="true" type="string"/> 
		
		<!--- Universal values --->
		<cfset var BB_Creator_ID = "00000000-0000-0000-0000000000000000">
		<cfset var PayeeList = "">
		<cfset var PayeeType = "">
		<cfset var UseRebateRecipient = 0>
		<cfset var BillbackManager = CreateObject("component","components.Billback.BillbackManager")>
		
		<!---  Get information on the lump sums --->
		<cfquery name="Contract_Info" datasource="#application.datasource#">
			SELECT Rebate_Recipient_Customer_ID, Contract_Number, Contract_Title, Contract_Start_Date, Contract_End_Date,
			Creating_User_Position_ID, Revision_of_Contract_Main_ID, Creator_ID
			FROM Contract_Main
			WHERE Contract_Main_ID = '#arguments.Contract_Main_ID#'
		</cfquery>
		
		<Cfif Contract_Info.Recordcount GT 0 AND len(trim(Contract_Info.Rebate_Recipient_Customer_ID)) GT 0>
			
			<!--- Rebate recipient id is actually vendor master ID, and we need a customer id, so this only works if the vendor_id and ship_to in the vendor/distributor tables match -- may not work for all clients --->
			<cfquery name="GetRRCustomerID" datasource="#application.datasource#">
			SELECT BSA_Foodservice_Customers_ID
				FROM BSA_Foodservice_Customers
				INNER JOIN Vendor_Master
				ON Vendor_Master.Vendor_ID = BSA_Foodservice_Customers.Ship_To
				AND Vendor_Master.Vendor_Master_ID = '#Contract_Info.Rebate_Recipient_Customer_ID#'
				AND Vendor_Master.Deleted = 0
			</cfquery>
			
			<!---If there is one and only one match, then populate the rebate recipient info --->
			<cfif GetRRCustomerID.Recordcount EQ 1>
				<cfset PayeeList = GetRRCustomerID.BSA_Foodservice_Customers_ID>
				<cfset PayeeType = 1>
				<cfset UseRebateRecipient = 1>
			</cfif>
			
		</Cfif>
		
		<!--- Get all the auto pay lump sums --->
		<cfquery name="GetAutoPayLS" datasource="#application.datasource#">
			SELECT	Program_Lump_Sums.Program_Lump_Sum_ID, 
					Program_Lump_Sums.Split_For_Auto_Pay, 
					Program_Lump_Sums.Component_Paid_To,
					Program_Lump_Sums.Lump_Sum_Amount
			FROM 	Program_Lump_Sums
				INNER JOIN Payment_Type
				ON 	Payment_Type.Payment_Type_ID = Program_Lump_Sums.Claim_Mechanics
				AND	Payment_Type.Is_Auto_Pay = 1
			WHERE 	Program_Lump_Sums.Program_ID = '#arguments.Contract_Main_ID#'
				AND	Program_Lump_Sums.Deleted = 0
		</cfquery>
			
		
		<!--- Loop through each LS component  --->
		
			<cfloop query="GetAutoPayLS">
			
				<cfset Has_Interfaced = 0>
			
				<cfquery name="HasInterfaced" datasource="#application.datasource#">
				SELECT BB_Payment_request_sent, * 
				FROM Billback
					INNER JOIN Billback_Program
					ON Billback_Program.Billback_ID = Billback.Billback_ID
					AND Billback_Program.Deleted = 0
					AND Billback_Program.Program_ID IN (SELECT Contract_Main_ID FROM Contract_Main WHERE Contract_Number = (SELECT Contract_Number FROM Contract_Main WHERE Contract_Main_ID = '#arguments.Contract_Main_ID#'))
					INNER JOIN BB_Lump_Sums
					ON Billback.Billback_ID = BB_Lump_Sums.Billback_ID
					AND Billback_Program.Billback_Program_ID = BB_Lump_Sums.Billback_Program_ID
					AND LS_Billback_Amount = '#GetAutoPayLS.Lump_Sum_Amount#'
				WHERE Billback.Deleted = 0
					AND Billback.Auto_Billback = 1
					AND Billback.BB_Payment_request_sent = 1
				</cfquery>
				
				<cfif HasInterfaced.Recordcount GT 0>
					<cfset Has_Interfaced = 1>
				</cfif>
				
				<!--- Only delete and create new billbacks if pre-existing billbacks haven't interfaced --->
				<cfif Has_Interfaced IS 0>
				<!--- If there are already billbacks from a previous version of the lump sum, I need to delete them --->
				<cfif len(trim(Contract_Info.Revision_of_Contract_Main_ID)) GT 0>
					<!--- find and delete any billbacks for previous revision --->
					<cfquery name="DeleteUnsentBBs" datasource="#application.datasource#">
						UPDATE Billback
						SET Deleted = 1
						FROM Billback
							INNER JOIN Billback_Program
							ON Billback_Program.Billback_ID = Billback.Billback_ID
							AND Billback_Program.Program_ID = '#Contract_Info.Revision_of_Contract_Main_ID#'
							AND Billback_Program.Deleted = 0
						WHERE BB_Payment_Request_Sent = 0
						AND Billback.Deleted = 0
					</cfquery>
				</cfif>
				
				<!--- Only get payees if there's not a rebate recipient on the program --->
				<cfif UseRebateRecipient IS NOT 1>
					<cfset PayeeType = GetAutoPayLS.Component_Paid_To>
					
					<cfif PayeeType IS 4>
						<cfset PayeeType = "1,2">
					</cfif>
				</cfif>
					
					<!--- If payee type is 4 (both) then I need to execute below code for both operators and distributors --->
					<cfloop list="#PayeeType#" index="Payee_Type_ID">
					<cfif UseRebateRecipient IS NOT 1> 
					<cfswitch expression="#PayeeType#">
						<!--- Distributor --->
						<cfcase value="1">
							<cfset useLakebaseForGetPayeeIDs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors")>
<cfif useLakebaseForGetPayeeIDs>
	<cftry>
		<cfset GetPayeeIDs = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_distributors", {
				"contract_main_id" = "eq.#arguments.Contract_Main_ID#",
				"deleted" = "eq.0",
				"select" = "bsa_foodservice_customers_id"
			}), "bsa_foodservice_customers_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetPayeeIDs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetPayeeIDs>
<cfquery name="GetPayeeIDs" datasource="#application.datasource#">
								SELECT BSA_Foodservice_Customers_ID 
								FROM Contract_Distributors
								WHERE Contract_Main_ID = '#arguments.Contract_Main_ID#'
								AND Deleted = 0
							</cfquery>
</cfif>
							
							<cfset PayeeList = valuelist(GetPayeeIDs.BSA_Foodservice_Customers_ID)>
						</cfcase>
						<!--- Operator --->
						<cfcase value="2">
							<cfquery name="GetPayeeIDs" datasource="#application.datasource#">
								SELECT BSA_Operator_ID 
								FROM Contract_Operators
								WHERE Contract_Main_ID = '#arguments.Contract_Main_ID#'
								AND Deleted = 0
							</cfquery>
							<cfset PayeeList = valuelist(GetPayeeIDs.BSA_Operator_ID)>
						</cfcase>
						<!--- Broker --->
						<cfcase value="3">
							<cfquery name="GetPayeeIDs" datasource="#application.datasource#">
								SELECT BSA_Foodservice_Brokers_ID 
								FROM Contract_Brokers
								WHERE Contract_Main_ID = '#arguments.Contract_Main_ID#'
								AND Deleted = 0
							</cfquery>
							<cfset PayeeList = valuelist(GetPayeeIDs.BSA_Foodservice_Brokers_ID)>
						</cfcase>
					</cfswitch>
				<!--- Not rebate recipient --->
				</cfif>
				
				<!--- Only bother doing the rest of this if there's at least one payee --->
				<cfif listlen(PayeeList) GT 0>
				<!--- Set the LS amount per payee --->
				<cfset Each_LS_Amount = GetAutoPayLS.Lump_Sum_Amount>
				
				<!--- If the split flag is on, divide this between the number of payees --->
				<cfif GetAutoPayLS.Split_For_Auto_Pay IS 1>
					<cfset NumberofPayees = listlen(PayeeList)>
					<cfset Each_LS_Amount = Each_LS_Amount / NumberofPayees>
				</cfif>
				
				<!--- Need to create a billback for each payee --->
				<cfloop list="#PayeeList#" index="Payee_ID">
					
					<cfinclude template="/billbacks/capture/billback_number_generator.cfm">
					<CFSET NewBBCode = generator_billback_number>
								
					
					<!--- First, the main billback table --->
					<cfquery name="InsertIntoBillback" datasource="#application.datasource#">
						INSERT INTO Billback
						(
							BB_Code,
							BB_Title,
							BB_Date,
							BB_Start_Date,
							BB_End_Date,
							BB_Amount,
							BB_UP,
							BB_PNF,
							BB_Request_Approval_User_ID,
							BB_Creator_ID,
							BB_Creator_User_Position_ID,
							Billback_Payee_Type_ID,
							BB_Request_Approval_Date,
							Auto_Billback	
						)
				
						VALUES
						(
							'#NewBBCode#',
							'Auto BB :: Lump Sum :: #Contract_Info.Contract_Number# :: #Contract_Info.Contract_Title#',
							getdate(),
							'#Contract_Info.Contract_Start_Date#',
							'#Contract_Info.Contract_End_Date#',
							'#GetAutoPayLS.Lump_Sum_Amount#',
							0,
							0,
							'#arguments.User_Approved_ID#',
							'#Contract_Info.Creator_ID#',
							'#Contract_Info.Creating_User_Position_ID#',
							'#Payee_Type_ID#',
							getdate(),
							1
						)
					</cfquery>
					
					<!--- Get billback_ID --->
					<cfquery name="GetBBID" datasource="#application.datasource#">
					SELECT Billback_ID FROM Billback WHERE BB_Code = '#NewBBCode#'
					</cfquery>
					
					<cfset BBID = GetBBID.Billback_ID>
					
					<!--- Insert into billback program table --->
					<cfquery name="InsertIntoBBProgram" datasource="#application.datasource#">
						INSERT INTO Billback_Program
						(
							Billback_ID,
							Program_ID,
							Discount_List
						)
						VALUES
						(
							'#BBID#',
							'#arguments.Contract_Main_ID#',
							'3'
						)
						SELECT Billback_Program_ID FROM Billback_Program WHERE Billback_ID = '#BBID#' AND Program_ID = '#arguments.Contract_Main_ID#'
					</cfquery>
					
					<cfset BBProgramID = InsertIntoBBProgram.Billback_Program_ID>
					
					<!---Insert into lump sum tables --->
					
					<cfquery name="InsertBBLSComp" datasource="#application.datasource#">
						INSERT INTO Billback_Program_Lumpsum_Component
						(
							Billback_ID,
							Billback_Program_ID,
							Component_Type_ID,
							Program_Lump_Sum_ID,
							Amount
						)
						VALUES
						(
							'#BBID#',
							'#BBProgramID#',
							1,
							'#GetAutoPayLS.Program_Lump_Sum_ID#',
							'#GetAutoPayLS.Lump_Sum_Amount#'
						)
					</cfquery>
										
					<!--- <cfquery name="InsertBBLumpSum" datasource="#application.datasource#">
					INSERT INTO BB_Lump_Sums
					(
						Billback_ID,
						Program_ID,
						Billback_Program_ID,
						Lump_Sum_Deviation,
						LS_Expected_Amount,
						LS_Approved_Amount,
						LS_Billback_Amount,
						LS_Paid_Amount,
						Calc_LS_Amount
					)
					VALUES
					(
						'#BBID#',
						'#arguments.Contract_Main_ID#',
						'#BBProgramID#',
						0,
						'#GetAutoPayLS.Lump_Sum_Amount#',
						'#GetAutoPayLS.Lump_Sum_Amount#',
						'#GetAutoPayLS.Lump_Sum_Amount#',
						'#GetAutoPayLS.Lump_Sum_Amount#',
						'#GetAutoPayLS.Lump_Sum_Amount#'
					)
					</cfquery> --->
					
					<!--- Insert into payee table --->
					<cfset setPayee = BillbackManager.InsertBBPayee(BBID,Payee_ID,PayeeType )>
					
					<!---Go through approval --->
					<cfstoredproc procedure="BB_Auto_Approve" datasource="#application.datasource#">
						<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Auto_Approval_Type" value = "1">
						<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Billback_ID" value = "#BBID#" null="no">
						<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@BB_Auto_Report" value = "1" null="no">
					
					</cfstoredproc>
																				
					<!--- Set billback status --->
					<cfstoredproc procedure="BB_Auto_Report_Set_Status" datasource="#application.datasource#">
						<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@BB_Auto_Report_ID" value = "0">
						<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@Billback_ID" value = "#BBID#" null="no">
					</cfstoredproc>
					
					
					
				<!--- Each payee --->
				</cfloop>
			
				<!--- There is at least one payee --->
				</cfif>
				
				<!--- Each payee type --->
				</cfloop>
			
			<!--- Previous billbacks haven't interfaced --->	
			</cfif>

			<!--- Each component --->
			</cfloop>

	</cffunction>
	
</cfcomponent>