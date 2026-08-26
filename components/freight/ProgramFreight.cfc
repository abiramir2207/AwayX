<cfcomponent hint="Program Freight" extends="components.Base" access="public">

	<cffunction name="init" output="false" returntype="components.freight.ProgramFreight">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getProgramDistributorFreight" output="false" returntype="query">
		<cfargument name="programId" required="true" type="numeric" />	
		<cfargument name="distributorId" required="false" type="string" default=""/>
		
		<cfset objFreight = CreateObject("component","components.freight.FreightBracketSetting") />
		<cfset objFreight.getFreightSettings()  />
		
		<cfquery name="qGetProgramDistributorFreight" datasource="#application.datasource#">			
			SELECT DISTINCT
				Program_Distributor_Freight.Program_ID,
				Program_Distributor_Freight.Distributor_ID,
				Program_Distributor_Freight.Warehouse_Master_ID,
				Program_Distributor_Freight.Default_Warehouse_Master_ID,
				Program_Distributor_Freight.Freight_Bracket_Setting_ID,
				Program_Distributor_Freight.Default_Freight_Bracket_Setting_ID,
				Program_Distributor_Freight.Overridden_Warehouse_Master_ID,
				Program_Distributor_Freight.Overridden_Freight_Bracket_Setting_ID,
				Program_Distributor_Freight.Last_Updated_By,
				Program_Distributor_Freight.Last_Updated_Date,
				Program_Distributor_Freight.Deleted,
				Program_Distributor_Freight.Created_Date,
				ISNULL(CONVERT(Decimal(20,2), Program_Distributor_Freight.IBF_Rate), 0) As IBF_Rate,
				ISNULL(CONVERT(Decimal(20,2), Program_Distributor_Freight.OBF_Rate), 0) As OBF_Rate,
				ISNULL(CONVERT(Decimal(20,2), Program_Distributor_Freight.Pickup_Allowance), 0) As Pickup_Allowance,
				ISNULL(CONVERT(Decimal(20,2), Program_Distributor_Freight.Freight_Adjustment), 0) As Freight_Adjustment,
				CONVERT(Decimal(20,2), Program_Distributor_Freight.Default_IBF_Rate) As Default_IBF_Rate,
				CONVERT(Decimal(20,2), Program_Distributor_Freight.Default_OBF_Rate) As Default_OBF_Rate,
				CONVERT(Decimal(20,2), Program_Distributor_Freight.Default_Pickup_Allowance) As Default_Pickup_Allowance,
				CONVERT(Decimal(20,2), Program_Distributor_Freight.Overridden_IBF_Rate) As Overridden_IBF_Rate,
				CONVERT(Decimal(20,2), Program_Distributor_Freight.Overridden_OBF_Rate) As Overridden_OBF_Rate,
				CONVERT(Decimal(20,2), Program_Distributor_Freight.Overridden_Pickup_Allowance) As Overridden_Pickup_Allowance,
				CONVERT(Decimal(20,2), Contract_Distributors.Program_Weight) As Program_Weight,
				BSA_Foodservice_Customers.Shr_Ship_to,
				BSA_Foodservice_Customers.Name,			
				BSA_Foodservice_Customers.Address_1,
				BSA_Foodservice_Customers.Address_2,
				BSA_Foodservice_Customers.City,
				BSA_Foodservice_Customers.State,
				BSA_Foodservice_Customers.ZipCode,
				Warehouse_Master.Warehouse_Code,
				Warehouse_Master.Warehouse_Name,
				Warehouse_Master.Warehouse_Address_1,
				Warehouse_Master.Warehouse_Address_2,
				Warehouse_Master.Warehouse_City,
				Warehouse_Master.Warehouse_State,
				Warehouse_Master.Warehouse_Zip,
				Warehouse_Master.Warehouse_Country_Code,
				Freight_Lookup_Bracket_Settings.Freight_Bracket_Code,
				Freight_Lookup_Bracket_Settings.Freight_Bracket_Label
			FROM	Program_Distributor_Freight
			
			INNER JOIN Contract_Distributors
			ON	Contract_Distributors.Deleted = 0
			AND	Contract_Distributors.Contract_Main_ID = Program_Distributor_Freight.Program_ID
			AND	Contract_Distributors.BSA_Foodservice_Customers_ID = Program_Distributor_Freight.Distributor_ID
			
			INNER JOIN BSA_Foodservice_Customers
			ON	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Program_Distributor_Freight.Distributor_ID
			
			LEFT JOIN Warehouse_Master ON
				Warehouse_Master.Warehouse_Master_ID = Program_Distributor_Freight.Warehouse_Master_ID
			LEFT JOIN Customer_Warehouse_Bracket CWB ON
				CWB.Distributor_ID = Program_Distributor_Freight.Distributor_ID
			LEFT JOIN Freight_Lookup_Bracket_Settings
				<!---get default Bracket for special obf handling--->
				<cfif objFreight.bFREIGHT_VERSION_ITEM>
					ON	Freight_Lookup_Bracket_Settings.Freight_Bracket_Setting_ID = CWB.Freight_Bracket_Setting_ID
				<cfelse> <!---get Bracket from program--->
					ON	Freight_Lookup_Bracket_Settings.Freight_Bracket_Setting_ID = Program_Distributor_Freight.Freight_Bracket_Setting_ID
				</cfif>
			WHERE Program_Distributor_Freight.Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
			<cfif arguments.distributorId neq "">
			AND Program_Distributor_Freight.Distributor_ID = <cfqueryparam value="#arguments.distributorId#" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			AND Contract_Distributors.Captured_From_Group = 0
			AND	Program_Distributor_Freight.Deleted = 0
			ORDER BY BSA_Foodservice_Customers.Shr_Ship_to
		</cfquery>
		<cfreturn qGetProgramDistributorFreight />
	</cffunction>	

	<cffunction name="setProgramDistributorFreight" output="false" returntype="void">
		<cfargument name="formValues" type="string" required="true">
		<cfargument name="programId" type="numeric" required="true">
		<cfargument name="Distributor_List" type="string" required="true">
		<cfargument name="freightNotes" type="string" required="true" default="" />
		
 			<cfif isDefined("FORM.Send_Summarized_Weekly_Notification_Fuel_Surcharge")>
				<cfset FuelSurchargeON = FORM.Send_Summarized_Weekly_Notification_Fuel_Surcharge />
			<cfelse>
				<cfset FuelSurchargeON = "0" />
				<cfset FuelSurchargeExpirationDate = "" />
			</cfif>
			<cfif isDefined("FORM.Fuel_Surcharge_Amount")>
				<cfset FuelSurchargeAmount = FORM.Fuel_Surcharge_Amount />
			<cfelse>
				 <cfset FuelSurchargeAmount = 0.00 />
			</cfif>
			
			<cfif isDefined("FORM.Fuel_Surcharge_Expiration_Date")>
				<cfset FuelSurchargeExpirationDate = FORM.Fuel_Surcharge_Expiration_Date />
			<cfelse>
				<cfset FuelSurchargeExpirationDate = "" />
			</cfif>
			<cfif FuelSurchargeON EQ "0">
				<cfset FuelSurchargeExpirationDate = "" />
			</cfif>
			
			<cfloop list="#Distributor_List#" index="Distributor_ID">

				<cfset Overridden_Warehouse_Master_ID = 0>
				<cfset Overridden_Freight_Bracket_Setting_ID = 0>
				<cfset Overridden_IBF_Rate = 0>
				<cfset Overridden_OBF_Rate = 0>
				<cfset Overridden_Pickup_Allowance = 0>
				<cfset CustId =Replace(Distributor_ID, "_", "-", "all") />

				<cfparam name="form.Default_SelectedWarehouse_#Distributor_ID#" default = "0">
				<cfparam name="form.Default_Freight_Bracket_Setting_ID_#Distributor_ID#" default = "0">
				<cfparam name="form.Freight_Bracket_Setting_ID_#Distributor_ID#" default = "0">
				<cfparam name="form.Default_IBF_Rate_#Distributor_ID#" default = "0">
				<cfparam name="form.IBF_Rate_#Distributor_ID#" default = "0">
				<cfparam name="form.Default_OBF_Rate_#Distributor_ID#" default = "0">
				<cfparam name="form.OBF_Rate_#Distributor_ID#" default = "0">
				<cfparam name="form.Default_Pickup_Allowance_#Distributor_ID#" default = "0">
				<cfparam name="form.Pickup_Allowance_#Distributor_ID#" default = "0">
				<cfparam name="form.Freight_Adjustment_#Distributor_ID#" default = "0">
		
				<cfset Default_Warehouse_Master_ID = Evaluate('form.Default_SelectedWarehouse_'&Distributor_ID)>
				<cfset Warehouse_Master_ID = Evaluate('form.SelectedWarehouse_'&Distributor_ID)>	
				<cfset Default_Freight_Bracket_Setting_ID = Evaluate('form.Default_Freight_Bracket_Setting_ID_'&Distributor_ID)>
				<cfset Freight_Bracket_Setting_ID = Evaluate('form.Freight_Bracket_Setting_ID_'&Distributor_ID)>
				<cfset Default_IBF_Rate = Evaluate('form.Default_IBF_Rate_'&Distributor_ID)>
				<cfset IBF_Rate = Evaluate('form.IBF_Rate_'&Distributor_ID)>
				<cfset Default_OBF_Rate = Evaluate('form.Default_OBF_Rate_'&Distributor_ID)>
				<cfset OBF_Rate = Evaluate('form.OBF_Rate_'&Distributor_ID)>
				<cfset Default_Pickup_Allowance = Evaluate('form.Default_Pickup_Allowance_'&Distributor_ID)>
				<cfset Pickup_Allowance = Evaluate('form.Pickup_Allowance_'&Distributor_ID)>

				<cfset Freight_Adjustment = Evaluate('form.Freight_Adjustment_'&Distributor_ID)>

				<cfif Warehouse_Master_ID neq Default_Warehouse_Master_ID>
					<cfset Overridden_Warehouse_Master_ID = 1>
				</cfif>

				<cfif Freight_Bracket_Setting_ID neq Default_Freight_Bracket_Setting_ID>
					<cfset Overridden_Freight_Bracket_Setting_ID = 1>
				</cfif>

				<cfif IBF_Rate neq Default_IBF_Rate>
					<cfset Overridden_IBF_Rate = 1>
				</cfif>

				<cfif OBF_Rate neq Default_OBF_Rate>
					<cfset Overridden_OBF_Rate = 1>
				</cfif>

				<cfif Pickup_Allowance neq Default_Pickup_Allowance>
					<cfset Overridden_Pickup_Allowance = 1>
				</cfif>

		<cfquery name="qsetProgramDistributorFreight" datasource="#application.datasource#">
			UPDATE Program_Distributor_Freight
			SET Warehouse_Master_ID = '#Warehouse_Master_ID#'
				,Freight_Bracket_Setting_ID = '#Freight_Bracket_Setting_ID#'
				,IBF_Rate = '#IBF_Rate#'
				,OBF_Rate = '#OBF_Rate#'
				,Pickup_Allowance = '#Pickup_Allowance#'
				,Freight_Adjustment = <cfqueryparam value="#Freight_Adjustment#" cfsqltype="cf_sql_decimal" scale="2" />
				,Default_Warehouse_Master_ID  = '#Default_Warehouse_Master_ID#'
				,Default_Freight_Bracket_Setting_ID = '#Default_Freight_Bracket_Setting_ID#'
				,Default_IBF_Rate = '#Default_IBF_Rate#'
				,Default_OBF_Rate = '#Default_OBF_Rate#'
				,Default_Pickup_Allowance = '#Default_Pickup_Allowance#'
				,Overridden_Warehouse_Master_ID = #Overridden_Warehouse_Master_ID#
				,Overridden_Freight_Bracket_Setting_ID = #Overridden_Freight_Bracket_Setting_ID#
				,Overridden_IBF_Rate = #Overridden_IBF_Rate#
				,Overridden_OBF_Rate = #Overridden_OBF_Rate#
				,Overridden_Pickup_Allowance = #Overridden_Pickup_Allowance#
				,Last_Updated_By = '#request.AccessStructure.User_ID#'
				,Last_Updated_Date = getDate()
			WHERE Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
			<!--- We are using Distributor_Group_ID because of distributor groups. 'Distributor_Group_ID' 
				  will be the same for all the members of the distributor group, including the distributor 
				  group itself
			--->
			AND CAST(Distributor_Group_ID As varchar(50)) = <cfqueryparam value="#CustId#" cfsqltype="CF_SQL_VARCHAR">
			AND Deleted = 0 
		</cfquery>

		<cfquery name="qsetContractDistributors" datasource="#application.datasource#">			
			UPDATE	Contract_Distributors
			SET	Warehouse_Master_ID = <cfqueryparam value="#Warehouse_Master_ID#" cfsqltype="CF_SQL_INTEGER">
				,Overridden_Warehouse_Master_ID = <cfqueryparam value="#Overridden_Warehouse_Master_ID#" cfsqltype="CF_SQL_INTEGER">
			WHERE Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
			AND CAST(BSA_Foodservice_Customers_ID As varchar(50)) = <cfqueryparam value="#CustId#" cfsqltype="CF_SQL_VARCHAR">
			AND Deleted  = 0
		</cfquery>
		</cfloop>

 	<cfif FuelSurchargeAmount EQ "">
			 <cfset FuelSurchargeAmount = 0.00 />
		</cfif>  
		<cfquery name="qsetNotesInfo" datasource="#application.datasource#">			
			UPDATE	Contract_Main_Aux_Data
			SET		Freight_Notes = '#arguments.freightNotes#',
					Fuel_Surcharge_ON = #FuelSurchargeON#,
					Fuel_Surcharge_Amount = <cfqueryparam value="#FuelSurchargeAmount#" cfsqltype="CF_SQL_FLOAT">,
					Fuel_Surcharge_Expiration_Date = '#FuelSurchargeExpirationDate#'
			WHERE	Contract_Main_Aux_Data.Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cffunction>

	<cffunction name="approveFreight" output="false" returntype="void">
		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="userId" required="true" type="string" />
		
		<cfquery name="qApproveFreight" datasource="#application.datasource#">			
			UPDATE	Contract_Main_Aux_Data
			SET		Freight_Approved = 1,
					Freight_Approved_By = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_varchar">,
					Freight_Approved_Date = GetDate()
			WHERE	Contract_Main_Aux_Data.Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset addFreightApprovalHistory (
				programId = arguments.programId,
				freightApproved = 1,
				userId = arguments.userId,
				comments = "Approval"
				)/>
			
		<!---- when freight gets approved, if all products in the program is approved, set the program as approved  ----->
		<cfset bApproveProgram = 0 />
		<cfset ProgramApprovalManager = CreateObject("component","components.programs.Approval.layered_program_approval") />
		<cfset getapprovedprogramtypes = ProgramApprovalManager.getapprovedprogramtypecodes(arguments.programId)>
		<cfif getapprovedprogramtypes.Recordcount eq 0>	
			<cfset objProgram = CreateObject("component", "components.programs.Program") />
			<cfset qGetProgramApprovalInfo = objProgram.getProgramApprovalInfo(programId = arguments.programId) />
			<cfif qGetProgramApprovalInfo.Program_Approved eq 1>
			
				<cfset useLakebaseForqGetRevisionContractNumber = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqGetRevisionContractNumber>
	<cftry>
		<cfset qGetRevisionContractNumber = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#arguments.programId#",
				"select" = "is_a_revision,contract_number"
			}), "is_a_revision,contract_number"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetRevisionContractNumber = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetRevisionContractNumber>
<CFQUERY NAME="qGetRevisionContractNumber" datasource="#application.datasource#">
					SELECT 	Is_A_Revision,
							Contract_Number
					FROM 	Contract_main
					where 	Contract_Main_Id = #arguments.programId#
				</CFQUERY>
</cfif> 
	
				<cfif qGetRevisionContractNumber.Is_A_Revision EQ 1>
					
					<!--- now get the maximum version of all the approved programs of this contract number and then update the current approved program with max(revision_number) + 1 --->
					<CFQUERY NAME="GetRevisionVersion" datasource="#application.datasource#">
						SELECT 	MAX(Revision_Version) AS revisionversion
						FROM 	Contract_Main
						WHERE 	Contract_Number LIKE '%#qGetRevisionContractNumber.Contract_Number#%'
						AND 	Approved = 1
						AND 	Contract_Main_ID != #arguments.programId#
					</CFQUERY>
					
					<CFQUERY NAME="UpdateRevisionVersion" datasource="#application.datasource#">
						UPDATE	Contract_Main
						SET 	Revision_Version = #GetRevisionVersion.revisionversion# + 1
						WHERE 	Contract_Main_Id = #arguments.programId#
					</CFQUERY>
					
				</cfif>
				
				<cfset objProgram.approveProgram(
							programId = arguments.programId,
							userId = qGetProgramApprovalInfo.Program_Approved_By,
							Pay_Brokerage="EMPTY",
							approvalDate = qGetProgramApprovalInfo.Program_Approved_Date) />
				<cfset bApproveProgram = 1 />
			</cfif>
		</cfif>
		
		<cfif bApproveProgram eq 0>
			<cfstoredproc procedure = "Populate_Program_Approvable_Positions" dataSource="#application.datasource#">
				<cfprocparam type="IN" CFSQLType="CF_SQL_INTEGER" value="#arguments.programId#"  />
			</cfstoredproc>
		</cfif>
		
	</cffunction>
	
	<cffunction name="resetFreightApproval" output="false" returntype="void">
		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="userId" required="true" type="string" />
		<cfargument name="comments" required="true" type="string" />
		
		<cfquery name="qApproveFreight" datasource="#application.datasource#">			
			UPDATE	Contract_Main_Aux_Data
			SET		Freight_Approved = 0,
					Freight_Approved_By = NULL,
					Freight_Approved_Date = NULL
			WHERE	Contract_Main_Aux_Data.Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfset addFreightApprovalHistory (
				programId = arguments.programId,
				freightApproved = 0,
				userId = arguments.userId,
				comments = "#arguments.comments#"
				)/>
		
		<cfstoredproc procedure = "Populate_Program_Approvable_Positions" dataSource="#application.datasource#">
			<cfprocparam type="IN" CFSQLType="CF_SQL_INTEGER" value="#arguments.programId#"  />
		</cfstoredproc>
		
	</cffunction>
	
	<cffunction name="addFreightApprovalHistory" output="false" returntype="void">
		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="freightApproved" required="true" type="boolean" />
		<cfargument name="userId" required="true" type="string" />
		<cfargument name="comments" required="true" type="string" />
		
		<cfquery name="qApproveFreightHistory" datasource="#application.datasource#">
			INSERT INTO Program_Freight_Approval_History 
				(
				Program_ID, 
				Freight_Approved, 
				User_ID, 
				Comments
				)				
			VALUES	
				(
				<cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#arguments.freightApproved#" cfsqltype="cf_sql_bit">,
				<cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_varchar" null="#Len(arguments.userId) eq 0#">,
				<cfqueryparam value="#arguments.comments#" cfsqltype="cf_sql_varchar" null="#Len(arguments.comments) eq 0#">
				)			
		</cfquery>
		
	</cffunction>	

	<cffunction name="GetProgramDistributorFreightCount" output="false" returntype="boolean">
		<cfargument name="programId" required="true" type="numeric" />	
				
			<cfset ProgramDistributorFreightCount =  0>
			<cfset useLakebaseForqGetProgramDistributorFreightCount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_distributor_freight")>
<cfif useLakebaseForqGetProgramDistributorFreightCount>
	<cftry>
		<cfset qGetProgramDistributorFreightCount = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_distributor_freight", {
				"program_id" = "eq.#arguments.programId#",
				"deleted" = "eq.0",
				"select" = "program_id"
			}), "program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProgramDistributorFreightCount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProgramDistributorFreightCount>
<cfquery name="qGetProgramDistributorFreightCount" datasource="#application.datasource#">
				SELECT 	program_ID
				FROM 	Program_Distributor_Freight
				WHERE 	Program_ID = '#arguments.programId#' 
				AND Deleted = 0
			</cfquery>
</cfif>
				
				<cfif qGetProgramDistributorFreightCount.RecordCount neq 0>
					<cfset ProgramDistributorFreightCount = 1>
				</cfif>

				<cfreturn ProgramDistributorFreightCount>
	</cffunction>

	<cffunction name="PopulateProgramDistributorFreight" output="no">
		<cfargument	name="programID" type="string" required="true" >
		<cfargument	name="ReCalculateAll" type="boolean" required="true">
		<cfargument	name="DistributorID" type="string" required="false" default="">

		<cfset var returnCode = "0">
		
		<cfstoredproc procedure = "Populate_Program_Distributor_Freight" dataSource="#application.datasource#">
	   		<cfprocparam type="IN" CFSQLType="CF_SQL_INTEGER" value="#arguments.programID#"  />
			<cfprocparam type="IN" CFSQLType="CF_SQL_BIT" value="#arguments.ReCalculateAll#"  />
			<cfprocparam type="IN" CFSQLType="CF_SQL_VARCHAR" value="#arguments.DistributorID#"  />
		</cfstoredproc>
			
		<cfreturn returnCode />
		
	</cffunction>

	<cffunction name="DeleteDistributorFreightInfo" output="false" returntype="void">
		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="distributorId" required="true" type="string" />
		
		<cfquery name="qDeleteDistributorFreightInfo" datasource="#application.datasource#">			
			UPDATE	Program_Distributor_Freight
			SET	Deleted = 1
			WHERE Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
			<!--- We are using Distributor_Group_ID because of distributor groups. 'Distributor_Group_ID' 
				  will be the same for all the members of the distributor group, including the distributor 
				  group itself
			--->
			AND Distributor_Group_ID IN (<cfqueryparam value="#arguments.distributorId#" cfsqltype="CF_SQL_VARCHAR" list="yes">)
			AND Deleted = 0
		</cfquery>
	</cffunction>
	
	<cffunction name="ResetFreightInfo" output="false" returntype="void">
		<cfargument name="programId" required="true" type="numeric" />
		
		<cfquery name="qResetFreightInfo" datasource="#application.datasource#">			
			UPDATE	Program_Distributor_Freight
			SET	Deleted = 1
			WHERE Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
			AND Deleted = 0
		</cfquery>
	</cffunction>

	<cffunction name="UpdateProgramDistributorFreight" output="false">
		<cfargument name="programId" required="true" type="numeric" />	
				
			<cfquery name="qUpdateProgramDistributorFreight" datasource="#application.datasource#">
				UPDATE Program_Distributor_Freight
				SET OBF_Rate = 0
				,Default_OBF_Rate =  0
				,Pickup_Allowance = 0
				,Default_Pickup_Allowance = 0
				,Overridden_OBF_Rate = 0
				,Overridden_Pickup_Allowance = 0
				,Last_Updated_By = '#request.AccessStructure.User_ID#'
				,Last_Updated_Date = getDate()
				WHERE 	Program_ID = '#arguments.programId#' 
				AND Deleted = 0
			</cfquery>
	</cffunction>
	
	<cffunction name="verifyFreightAdjustment" output="false" returntype="numeric">
		<cfargument name="programId" required="true" type="numeric" />
		
		<cfset var qVerifyFreightAdjustment = "" />
				
		<cfquery name="qVerifyFreightAdjustment" datasource="#application.datasource#">			
			Select	Count(Freight_Adjustment) as Freight_Adjusted
			From 	Program_Distributor_Freight
			WHERE 	Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
			AND 	Deleted = 0
			AND 	Freight_Adjustment != <cfqueryparam value="0.00" cfsqltype="cf_sql_decimal" scale="2"> 
		</cfquery>
		
		<cfreturn qVerifyFreightAdjustment.Freight_Adjusted />
		
	</cffunction>

	<!--- Dev Note: KAL; 11/9/2010; D25227:  Dont reset Freight info on reset to WIP 
		For this functionality, on program reset to WIP we don't delete the freight.
		Instead when its RFA again, we check, if there is a non deleted freight values for thr program.
		If yes, dont run the routine to populate freight and you get the last saved freight values.
		Otherwise, run the freight routine to populate the values.
	--->
	<cffunction name="verifyValidFreight" output="false" returntype="numeric">
		<cfargument name="programId" required="true" type="numeric" />
		
		<cfset var qVerifyValidFreight = "" />
				
		<cfquery name="qVerifyValidFreight" datasource="#application.datasource#">			
			Select	program_ID
			From 	Program_Distributor_Freight
			WHERE 	Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
			AND 	Deleted = 0
		</cfquery>
		
		<cfreturn qVerifyValidFreight.recordCount />
		
	</cffunction>
	
	<cffunction name="CallPopulateProgramDistributorFreightThread" output="no" returntype="void">
		<cfargument	name="programID" type="string" required="true" >
		<cfargument	name="ReCalculateAll" type="boolean" required="false" default="0">
		<cfargument	name="userID" type="string" required="true" >
		<cfargument	name="sAction" type="string" required="false" default=""  >

		<CFTHREAD ACTION="RUN" NAME="Freight_#arguments.programId#" program="#arguments.programId#" recalc="#arguments.ReCalculateAll#">
			<cfset PopulateProgramDistributorFreight(program, recalc) />
		</CFTHREAD>
			
	</cffunction>	
<!--- D30253 : Rebate Grid dropping strategy code from 2200 START--->
	<cffunction name="Freight" output="no" returntype="void" hint="If freight is on, find out if current program has any freight components selected and save a flag" >
		<cfargument	name="Program_ID" type="string" required="true" >
		<cfargument	name="program_fixed_component_name_id_list" type="string" required="true">
	<!--- Ben: 14520 Added check to get the current Component Type. This is needed
	      if a revise is done and the component type changes from one type to another (FOB,FOBDC,Delivered).
		  If it changes, then freight needs to be re-approved --->
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
	<cfset fixedComponentObj = CreateObject("component", "components.programs.Fixed.FixedComponent") />
	<cfset objProgramFreight = CreateObject("component", "components.freight.ProgramFreight") />
	
	<cfset variables.oldComponentType = GenProgramManager.GetProgramFreightComponentType(arguments.Program_ID) />

	<cfset freightComponentType = fixedComponentObj.GetFreightComponentType(arguments.program_fixed_component_name_id_list)>
	<cfset GenProgramManager.SetProgramFreightComponentType(programId = arguments.Program_ID, freightComponentType=freightComponentType) />
    
	<!--- Ben: 14520 Get the new component type so we can do a compare. --->
	<cfset variables.newComponentType = GenProgramManager.GetProgramFreightComponentType(arguments.Program_ID) />

	<!--- The rules for handling freight here are as follows:
		1. If the component type changes from Delivered to FOBDC, then we need to set the OBF and PUA to 0 for the program
		2. If the component type changes from FOBDC to Delivered OR FOB to either of the two, then we need to (Re)populate freight for the program
		3. If the component type changes to FOB, then we will delete all freight info for the program
	---> 

	<!--- Rule 1 --->
	  <cfif variables.oldComponentType eq 1 and variables.newComponentType eq 4>
				<cfset objProgramFreight.UpdateProgramDistributorFreight(arguments.Program_ID)>
				<cfset objProgramFreight.resetFreightApproval(arguments.Program_ID,request.AccessStructure.User_ID,'Reset Approval - Component Type changed from Delivered to FOB FDC') />
	
	<!--- Rule 2 --->
		<cfelseif ((variables.oldComponentType eq 4 and variables.newComponentType eq 1)
		or (variables.oldComponentType eq 0 and (variables.newComponentType eq 1 or variables.newComponentType eq 4)))>
				
				<cfif variables.oldComponentType eq 4 and variables.newComponentType eq 1>
					<cfset objProgramFreight.resetFreightApproval(arguments.Program_ID,request.AccessStructure.User_ID,'Reset Approval - Component Type changed from FOB FDC to Delivered') />
				</cfif>
<!---
			<cfstoredproc procedure="Populate_Program_Distributor_Freight" datasource="#application.datasource#">
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Program_ID" value = "#arguments.Program_ID#" null="no" />
			</cfstoredproc>
--->
	<CFQUERY NAME="PopulateProgramDistributorFreight" DATASOURCE="#application.datasource#">
		EXEC Populate_Program_Distributor_Freight <cfqueryparam value="#arguments.Program_ID#" cfsqltype="CF_SQL_INTEGER">
	</CFQUERY>

	<!--- Rule 3 --->
		 <cfelseif (variables.oldComponentType eq 4 OR variables.oldComponentType eq 1) AND variables.newComponentType eq 0>
				<cfset objProgramFreight.ResetFreightInfo(arguments.Program_ID)>
				<cfif variables.oldComponentType eq 1>
					<cfset objProgramFreight.resetFreightApproval(arguments.Program_ID,request.AccessStructure.User_ID,'Reset Approval - Component Type changed from Delivered to FOB') />
				<cfelseif variables.oldComponentType eq 4>
					<cfset objProgramFreight.resetFreightApproval(arguments.Program_ID,request.AccessStructure.User_ID,'Reset Approval - Component Type changed from FOB FDC to FOB') />
				</cfif>
		</cfif>	
	</cffunction>
<!--- D30253 : Rebate Grid dropping strategy code from 2200 END--->
			 
	<cffunction name="getFreightDataCC" hint="getFreightData" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="freightId" type="numeric" required="false" default="0" />
		<cfscript>
			// stuff
			var a = arguments;
		</cfscript>
				
		<cfquery name="GetRFPFreight" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_frt_vals') IS NOT NULL
			DROP TABLE ##tmp_frt_vals
			
			SELECT  PFFR.Program_Freight_Version_CC_ID,
					PFFR.product_id, 
					PFFR.program_id,
					PFFR.Product_Attribute_Code,
					PFFR.OBF_Rate_1_CS, PFFR.OBF_Rate_2_CS, PFFR.OBF_Rate_3_CS, PFFR.OBF_Rate_4_CS,
					PFFR.OBF_Rate_5_CS, PFFR.OBF_Rate_6_CS, PFFR.OBF_Rate_7_CS, PFFR.OBF_Rate_8_CS,
					I.Item,
					I.Description,
					CAST(I.Net_Weight as float) as Net_Weight,
					CAST(0 as decimal(20, 5)) as FOB_Price_CS,
					CAST(0 as decimal(20, 5)) as DEL_Price_1_CS,
					CAST(0 as decimal(20, 5)) as DEL_Price_2_CS,
					CAST(0 as decimal(20, 5)) as DEL_Price_3_CS,
					CAST(0 as decimal(20, 5)) as DEL_Price_4_CS,
					CAST(0 as decimal(20, 5)) as DEL_Price_5_CS,
					CAST(0 as decimal(20, 5)) as DEL_Price_6_CS,
					CAST(0 as decimal(20, 5)) as DEL_Price_7_CS,
					CAST(0 as decimal(20, 5)) as DEL_Price_8_CS,
					cp.Contract_Products_ID
			into	##tmp_frt_vals
			FROM Program_Freight_Version_CC PFFR
			INNER JOIN BSA_Foodservice_Items_Master I ON
				I.BSA_Foodservice_Items_Master_ID = PFFR.Product_Id
			INNER JOIN Contract_Products cp ON
				cp.Contract_Main_ID = PFFR.Program_Id AND
				cp.BSA_Foodservice_Items_Master_ID = PFFR.Product_Id AND
				cp.Product_Type_ID = 1 AND
				cp.Deleted = 0
			WHERE 	Program_Id = '#a.contractId#'
			AND 	PFFR.Deleted = 0
			<cfif a.freightId NEQ 0>
				AND PFFR.Program_Freight_Version_CC_ID = #a.freightId#
			</cfif>
			
			DECLARE @Program_Fixed_Component_ID int

			-- Get fixed price component
			-- Get DEL component if there is more than one.
			SELECT	TOP 1 @Program_Fixed_Component_ID = Program_Fixed_Component_ID
			FROM	Program_Fixed_Component fc
			INNER JOIN Program_Fixed_Component_Name cn
			ON		cn.Program_Fixed_Component_Name_ID = fc.Program_Fixed_Component_Name_ID
			WHERE	fc.Program_ID = '#a.contractId#'
			AND		fc.Deleted = 0
			Order By CASE cn.Fixed_Component_Type WHEN 1 THEN 99 WHEN 4 THEN 98 ELSE 0 END Desc 
			
			-- Get Fixed Price Value
			UPDATE	f
			SET		FOB_Price_CS = CASE pd.Unit_Of_Measure_ID WHEN 2 THEN pd.Fixed_Price_Value * F.Net_Weight ELSE pd.Fixed_Price_Value END
			FROM	##tmp_frt_vals F
			INNER JOIN Program_Fixed_Price_Product_Data pd
			ON		pd.Contract_Products_ID = F.Contract_Products_ID
			AND		pd.Program_Fixed_Component_ID = @Program_Fixed_Component_ID
			AND		pd.Deleted = 0

			-- Del price = Fixed Price + Freight value
			UPDATE	##tmp_frt_vals
			SET		DEL_Price_1_CS = FOB_Price_CS + OBF_Rate_1_CS,
					DEL_Price_2_CS = FOB_Price_CS + OBF_Rate_2_CS,
					DEL_Price_3_CS = FOB_Price_CS + OBF_Rate_3_CS,
					DEL_Price_4_CS = FOB_Price_CS + OBF_Rate_4_CS,
					DEL_Price_5_CS = FOB_Price_CS + OBF_Rate_5_CS,
					DEL_Price_6_CS = FOB_Price_CS + OBF_Rate_6_CS,
					DEL_Price_7_CS = FOB_Price_CS + OBF_Rate_7_CS,
					DEL_Price_8_CS = FOB_Price_CS + OBF_Rate_8_CS
			
			SELECT  PFFR.Program_Freight_Version_CC_ID,
					PFFR.product_id, 
					PFFR.program_id,
					PFFR.Product_Attribute_Code,
					PFFR.OBF_Rate_1_CS, PFFR.OBF_Rate_2_CS, PFFR.OBF_Rate_3_CS, PFFR.OBF_Rate_4_CS,
					PFFR.OBF_Rate_5_CS, PFFR.OBF_Rate_6_CS, PFFR.OBF_Rate_7_CS, PFFR.OBF_Rate_8_CS,
					Item,
					Description,
					FOB_Price_CS,
					DEL_Price_1_CS, DEL_Price_2_CS, DEL_Price_3_CS, DEL_Price_4_CS, 
					DEL_Price_5_CS, DEL_Price_6_CS, DEL_Price_7_CS, DEL_Price_8_CS
			FROM	##tmp_frt_vals PFFR
			ORDER BY Product_Attribute_Code, Item
		</cfquery>

		<cfreturn application.util.query.toAgGridJSON(GetRFPFreight) />
	</cffunction>

	<cffunction name="saveFreightDataCC" hint="saveItemBracketFreight" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="stData" type="string" required="true" />
		<cfargument name="field" type="string" required="true" />
		<cfscript>
			// stuff
			var a = arguments;
			var st = deserializeJson(a.stData);
			var data = st[field];
			var overField = 'OverRide_' & a.field;
			var frId = st.program_freight_version_cc_id;

		</cfscript>
		
		<cfquery name="qSaveItemBracketFreight" datasource="#application.datasource#">
			Update 	Program_Freight_Version_CC 
			SET 	#a.field# = #val(data)#,
					#a.field#_Override_By = '#request.AccessStructure.User_ID#',
					#a.field#_Override_Date = Getdate()
			WHERE	program_freight_version_cc_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#frId#" /> AND
					Program_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#a.contractId#" /> AND
					Deleted = 0
		</cfquery>

		<cfreturn this.getFreightDataCC(a.contractId,frId) />
	</cffunction>
			 
</cfcomponent>