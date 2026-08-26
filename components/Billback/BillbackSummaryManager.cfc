<cfcomponent hint="Billback Summary Manager" displayname="BillbackSummaryManager">
	<cfproperty name="hasOperatorAsscoiateDistributor" type="boolean" />
	<cfproperty name="payeeType" type="numeric" />
	<cfproperty name="payeeInfo" type="query" />
	<cfset variables.payeeType = 0 />
	<cfset variables.payeeInfo = "" />
	<cfset variables.hasOperatorAsscoiateDistributor = false />
	<cfset variables.hasDistAsscoiateOperator = false />
	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
			
	<!-- init --->
	<cffunction name="init" output="false" returntype="components.billback.BillbackSummaryManager">
		<cfargument name="Billback_ID" type="string" required="true">
		<!---D40664 :: Settings page to show Deleted Billbacks --->
		<cfargument name="deleted_Billback" type="numeric" required="false" default="0">
		<cfquery name="Get_Payee_Info" datasource="#application.datasource#">
				IF OBJECT_ID('tempdb..##TMP_CONTRACT_OPERATORS_LIST') IS NOT NULL
				DROP TABLE ##TMP_CONTRACT_OPERATORS_LIST
								
				SELECT BSA_Operator.BSA_Operator_ID,BSA_Operator.Legacy_ID,BSA_Operator.Operator_Name,BSA_Operator.Operator_City,BSA_Operator.Operator_State
				INTO ##TMP_CONTRACT_OPERATORS_LIST
				FROM Billback_Program INNER JOIN Contract_Operators
				ON Contract_Operators.Contract_Main_ID = Billback_Program.Program_ID
				INNER JOIN BSA_Operator
				ON BSA_Operator.BSA_Operator_ID = Contract_Operators.BSA_Operator_ID
				WHERE Billback_Program.billback_id = '#arguments.Billback_ID#'
				AND Billback_Program.Deleted = 0
				AND Contract_Operators.Deleted = 0

				SELECT	 
						isnull(bb.Billback_Payee_Type_ID, 0) as Billback_Payee_Type_ID,
						------------------------ID
						CASE
							WHEN bb.Billback_Payee_Type_ID=1 THEN  
							CAST(Billback_Distributor.Distributor_ID AS VARCHAR(60))
							
							WHEN bb.Billback_Payee_Type_ID=2 THEN
							CAST(Billback_Operator.Operator_ID AS VARCHAR(60))
							
							WHEN bb.Billback_Payee_Type_ID=3 THEN 
							CAST(Billback_Broker.Broker_ID AS VARCHAR(60))
							
							WHEN bb.Billback_Payee_Type_ID=4 THEN 
							CAST(Billback_Unidentified_Payee.Associated_Ship_To AS VARCHAR(60))
						END AS BB_Payee_ID,
						CASE 
							WHEN bb.Billback_Payee_Type_ID=2 THEN  isnull(CAST(Billback_Operator.Associated_Ship_To AS char(50)),'')
							WHEN bb.Billback_Payee_Type_ID=3 THEN  isnull(CAST(Billback_Broker.Associated_Ship_To AS char(50)),'')
							WHEN bb.Billback_Payee_Type_ID=6 THEN  isnull(CAST(Billback_Operator.Associated_Ship_To AS char(50)),'')
							WHEN bb.Billback_Payee_Type_ID=4 THEN  isnull(CAST(Billback_Unidentified_Payee.Associated_Ship_To AS char(50)),'')
						END Associated_Ship_To,						
				-------------------Name
					CASE
						WHEN bb.Billback_Payee_Type_ID=1 THEN 
							CASE WHEN bb.Auto_Billback = 1 THEN
									ISNULL(Vendor_Name,BSA_Foodservice_Customers.Name)
								ELSE
									BSA_Foodservice_Customers.Name
								END 
						WHEN bb.Billback_Payee_Type_ID=2 THEN
							BSA_Operator.Operator_Name  
						WHEN bb.Billback_Payee_Type_ID=3 THEN 
							CASE WHEN bb.Auto_Billback = 1 THEN
									ISNULL(Vendor_Name,BSA_Foodservice_Brokers.Broker_Name)
								ELSE
									BSA_Foodservice_Brokers.Broker_Name
								END
						WHEN bb.Billback_Payee_Type_ID=4 THEN
							Billback_Unidentified_Payee.BB_UP_Name
						WHEN bb.Billback_Payee_Type_ID=5 THEN
							Billback_Distributor.BB_Distributor_Name
						WHEN bb.Billback_Payee_Type_ID=6 THEN
							Billback_Operator.BB_Operator_Name
						WHEN bb.Billback_Payee_Type_ID=7 THEN
							Billback_Broker.BB_Broker_Name
					END AS Payee_Name,
				-------------------------City
					CASE
						WHEN bb.Billback_Payee_Type_ID=1 THEN	
							CASE WHEN bb.Auto_Billback = 1 THEN
									ISNULL(VM.City,BSA_Foodservice_Customers.City)
								ELSE
									BSA_Foodservice_Customers.City
								END	
						WHEN bb.Billback_Payee_Type_ID=2 THEN
							BSA_Operator.Operator_City
						WHEN bb.Billback_Payee_Type_ID=3 THEN
							CASE WHEN bb.Auto_Billback = 1 THEN
									ISNULL(VM.City,BSA_Foodservice_Brokers.City)
								ELSE
									BSA_Foodservice_Brokers.City
								END	
						WHEN bb.Billback_Payee_Type_ID=4 THEN
							Billback_Unidentified_Payee.BB_UP_Name
						WHEN bb.Billback_Payee_Type_ID=5 THEN		
							Billback_Distributor.BB_Distributor_City
						WHEN bb.Billback_Payee_Type_ID=6 THEN
								Billback_Operator.BB_Operator_City
						WHEN bb.Billback_Payee_Type_ID=7 THEN	
								Billback_Broker.BB_Broker_City
					END AS City,
				-------------------------State
					CASE
						WHEN bb.Billback_Payee_Type_ID=1 THEN
							CASE WHEN bb.Auto_Billback = 1 THEN
									ISNULL(VM.State,BSA_Foodservice_Customers.State)
								ELSE
									BSA_Foodservice_Customers.State
								END				
						WHEN bb.Billback_Payee_Type_ID=2 THEN
							BSA_Operator.Operator_State
						WHEN bb.Billback_Payee_Type_ID=3 THEN
						CASE WHEN bb.Auto_Billback = 1 THEN
									ISNULL(VM.State,BSA_Foodservice_Brokers.State)
								ELSE
									BSA_Foodservice_Brokers.State
								END		
						WHEN bb.Billback_Payee_Type_ID=4 THEN
							_States.State_Code
						WHEN bb.Billback_Payee_Type_ID=5 THEN		
							_States.State_Code
						WHEN bb.Billback_Payee_Type_ID=6 THEN
							_States.State_Code
						WHEN bb.Billback_Payee_Type_ID=7 THEN	
							_States.State_Code
					END AS State_Code,
					isnull(Associated_Distributor.Name, '') as Associated_Dist_Name,
					isnull(Associated_Distributor.City,'') as Associated_Dist_City,
					isnull(Associated_Distributor.State,'') as Associated_Dist_State,
					CASE
						WHEN bb.Billback_Payee_Type_ID=1 THEN
						CASE WHEN bb.Auto_Billback = 1 THEN									
									ISNULL(VM.vendor_ID,<cfif appSettings.get_Setting('Display_Distributor_ID') eq '1'>BSA_Foodservice_Customers.Shr_Ship_To<cfelse>BSA_Foodservice_Customers.Ship_To</cfif>)
								ELSE
								<cfif appSettings.get_Setting('Display_Distributor_ID') eq '1'>
									BSA_Foodservice_Customers.Shr_Ship_To
								<cfelse>
									BSA_Foodservice_Customers.Ship_To
								</cfif>
								END		
						WHEN bb.Billback_Payee_Type_ID=2 THEN
							COALESCE(BSA_Operator.Legacy_ID, cast(BSA_Operator.BSA_Operator_ID as char(50)))
					END AS Payee_ShipTo,
					Associated_Distributor.Shr_Ship_To AS Associated_Payee_ShipTo,
					isnull((select top 1 Operator_Name from ##TMP_CONTRACT_OPERATORS_LIST),'') as dist_assoc_operator_name,
					isnull((select top 1 COALESCE(Legacy_ID, cast(BSA_Operator_ID as char(50))) FROM ##TMP_CONTRACT_OPERATORS_LIST),'') as dist_assoc_operator_id,
					isnull((select top 1 Operator_City from ##TMP_CONTRACT_OPERATORS_LIST),'') as dist_assoc_operator_city,
					isnull((select top 1 Operator_State from ##TMP_CONTRACT_OPERATORS_LIST),'') as dist_assoc_operator_state
				FROM	Billback bb
				LEFT JOIN	
					(
					Billback_Broker
					LEFT JOIN
					BSA_Foodservice_Brokers
					ON
					(Billback_Broker.Broker_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID)
					)
				ON
				(
				(Billback_Broker.Billback_ID = bb.Billback_ID)
				AND
				(
					(bb.Billback_Payee_Type_ID = 3)
					OR
					(bb.Billback_Payee_Type_ID = 7)
				)
				AND
				(Billback_Broker.Deleted = 0)
				)
				LEFT JOIN	
					(
					Billback_Distributor
					LEFT JOIN 
					BSA_Foodservice_Customers
					ON 
					(Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID)
					)
				ON
				(
				(Billback_Distributor.Billback_ID = bb.Billback_ID)
				AND
				(
					(bb.Billback_Payee_Type_ID = 1)
					OR
					(bb.Billback_Payee_Type_ID = 5)
				)
				AND
				(Billback_Distributor.Deleted = 0)
				)
				LEFT JOIN	
						(
							Billback_Operator
							LEFT JOIN  BSA_Operator
									ON (Billback_Operator.Operator_ID = BSA_Operator.BSA_Operator_ID)
						)
				ON
					(
						(Billback_Operator.Billback_ID = bb.Billback_ID)
						AND ( 	(bb.Billback_Payee_Type_ID = 2)
								OR (bb.Billback_Payee_Type_ID = 6)
							)
						AND	(Billback_Operator.Deleted = 0)				
					)
				LEFT JOIN	Billback_Unidentified_Payee
					ON
						(
							(Billback_Unidentified_Payee.Billback_ID = bb.Billback_ID)
							AND	(bb.Billback_Payee_Type_ID = 4)
							AND	(Billback_Unidentified_Payee.Deleted = 0)
						)
				LEFT JOIN _States
						ON
							( ((bb.Billback_Payee_Type_ID = 5) AND (_States.State_ID=Billback_Distributor.BB_Distributor_State))
								OR ((bb.Billback_Payee_Type_ID = 6) AND (_States.State_ID=Billback_Operator.BB_Operator_State))
								OR ((bb.Billback_Payee_Type_ID = 7) AND (_States.State_ID=Billback_Broker.BB_Broker_State))
								OR ((bb.Billback_Payee_Type_ID = 4) AND (_States.State_ID=Billback_Unidentified_Payee.BB_UP_State))
							)
				LEFT JOIN BSA_Foodservice_Customers Associated_Distributor
				ON 		((bb.Billback_Payee_Type_ID = 2 OR bb.Billback_Payee_Type_ID = 6) /*** Operator ***/
						AND Associated_Distributor.BSA_Foodservice_Customers_ID = billback_operator.Associated_Ship_To)
						OR
						((bb.Billback_Payee_Type_ID = 4) /*** Other ***/
						AND Associated_Distributor.BSA_Foodservice_Customers_ID = Billback_Unidentified_Payee.Associated_Ship_To)
						OR
						((bb.Billback_Payee_Type_ID = 3)
						AND Associated_Distributor.BSA_Foodservice_Customers_ID = billback_broker.Associated_Ship_To)
				LEFT JOIN Vendor_Master VM ON -- AUTO Pay Join Only
					bb.Auto_Billback = 1 AND
					(
						(bb.Billback_Payee_Type_ID = 1
							AND
						VM.Vendor_master_ID = Billback_Distributor.Distributor_ID)
						OR
						(bb.Billback_Payee_Type_ID = 3
							AND
						VM.Vendor_master_ID = Billback_Broker.Broker_ID)
					)
				WHERE	
				<!---D40664 :: Settings page to show Deleted Billbacks START --->
				<cfif arguments.deleted_billback EQ 0>
				bb.Deleted = 0				
				AND		
				</cfif>
				<!---D40664 :: Settings page to show Deleted Billbacks END --->
				bb.Billback_ID = '#arguments.Billback_ID#'
		</cfquery>
		
		<cfif Trim(Get_Payee_Info.Associated_Ship_To) EQ "">
			<cfset hasAssociation = false />
		<cfelse>
			<cfset hasAssociation = true />
		</cfif>
		<cfif Get_Payee_Info.dist_assoc_operator_id EQ "">
			<cfset distAssocWithOperator = false />
		<cfelse>
			<cfset distAssocWithOperator = true />
		</cfif>
		
		<cfset setPayeeInfo(Get_Payee_Info) />
		<cfset setPayeeType(Get_Payee_Info.Billback_Payee_Type_ID) />
		<cfset setHasOperatorAsscoiateDistributor(hasAssociation) />
		<cfset setHasDistAsscoiateOperator(distAssocWithOperator) />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getBillbackInfo" output="false" returntype="query">
		<cfargument name="billbackId" type="string" required="true">
		<cfset useLakebaseForqGetBillbackInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForqGetBillbackInfo>
	<cftry>
		<cfset qGetBillbackInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"deleted" = "eq.0",
				"billback_id" = "eq.#arguments.billbackId#",
				"select" = "bb_code,bb_title,bb_start_date,bb_end_date"
			}), "bb_code,bb_title,bb_start_date,bb_end_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetBillbackInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetBillbackInfo>
<cfquery name="qGetBillbackInfo" datasource="#application.datasource#">
			SELECT	BB_Code, BB_Title, BB_Start_Date, BB_End_Date
			FROM	Billback
			WHERE	Billback.Deleted = 0
			AND		Billback.Billback_ID = '#arguments.billbackId#'
		</cfquery>
</cfif>
		<cfreturn qGetBillbackInfo />
	</cffunction>
	
	<cffunction name="getBillbackStatus" output="false" returntype="query">
		<cfargument name="billbackId" type="string" required="true">
		<cfquery name="qGetBillbackStatus" datasource="#application.datasource#">
			SELECT	Billback.Billback_ID, Billback_Status.*
			FROM	Billback
			INNER JOIN Billback_Status
			ON		Billback_Status.Billback_Status_ID = Billback.Billback_Status_ID
			WHERE	Billback.Billback_ID = '#arguments.billbackId#'
		</cfquery>
		<cfreturn qGetBillbackStatus />
	</cffunction>
	
	<cffunction name="getBillbackApprovalInfo" output="false" returntype="query">
		<cfargument name="billbackId" type="string" required="true">
		<cfquery name="qGetBillbackApprovalInfo" datasource="#application.datasource#">
			SELECT	Billback.Billback_ID, Billback.BB_code, Billback.BB_Title,
					BB_Approved.Date_Approved, BB_Approved.User_Approved,
					_Users.Name_First + ' ' + _Users.Name_Last as Billback_Approver
			FROM	Billback
			INNER JOIN BB_Approved
			ON		BB_Approved.Billback_ID = Billback.Billback_ID
			LEFT JOIN _Users
			ON		_Users.User_ID = BB_Approved.User_Approved
			WHERE	Billback.Billback_ID = <cfqueryparam value="#arguments.billbackId#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn qGetBillbackApprovalInfo />
	</cffunction>	
	
	<cffunction name="getAssoOperator" output="false" returntype="query">
		<cfargument name="billbackId" type="string" required="true">
		<cfquery name="qGetAssoOperator" datasource="#application.datasource#">
			SELECT 		DISTINCT 
						CASE 
						WHEN Operator_ID IS NULL THEN
							Operator_Legacy_ID
						ELSE BSA_Operator.Legacy_ID END Legacy_ID,
						CASE 
						WHEN Operator_ID IS NULL THEN
							Billback_Assoc_Operator.Operator_Name
						ELSE  BSA_Operator.Operator_Name END Operator_name
						
			FROM 		Billback_Assoc_Operator
			LEFT JOIN 	BSA_Operator ON BSA_Operator.BSA_Operator_ID = Billback_Assoc_Operator.Operator_ID  
						
			WHERE		Billback_Assoc_Operator.Deleted = 0 AND Billback_Assoc_Operator.Billback_ID = '#arguments.billbackId#'
		
		</cfquery>
		<cfreturn qGetAssoOperator />
	</cffunction>
	<!--- D51977 :: START Billback enhancements for operator level data --->
	<cffunction name="getPrgOperator" output="false" returntype="query">
		<cfargument name="billbackId" type="string" required="true">
		<cfquery name="qGetPrgOperatorr" datasource="#application.datasource#">
			SELECT 		DISTINCT 
						CASE 
						WHEN Operator_ID IS NULL THEN
							Operator_Legacy_ID
						ELSE BSA_Operator.Legacy_ID END Legacy_ID,
						CASE 
						WHEN Operator_ID IS NULL THEN
							Billback_Assoc_Operator.Operator_Name
						ELSE  BSA_Operator.Operator_Name END Operator_name
						
			FROM 		Billback_Assoc_Operator
			LEFT JOIN 	BSA_Operator ON BSA_Operator.BSA_Operator_ID = Billback_Assoc_Operator.Operator_ID  
						
			WHERE		Billback_Assoc_Operator.Deleted = 0 AND Billback_Assoc_Operator.Billback_ID = '#arguments.billbackId#'
		
		</cfquery>
		<cfreturn qGetPrgOperatorr />
	</cffunction>
	
	<!---
    	Dev Notes: Anand Rao/24-Jul-13/D38473: EDI -- 'USE DEFAULT PROGRAM IF OPERATOR AND/OR DISTRIBUTOR IS INVALID'
	--->	
	<cffunction name="getAssociatedDistributor" output="false" returntype="query">
		<cfargument name="billbackId" type="string" required="true">
		<cfquery name="qGetAssociatedDistributor" datasource="#application.datasource#">
			SELECT DISTINCT 
      			CASE 
       			WHEN Distributor_ID = '00000000-0000-0000-0000-000000000000' THEN
            			BAD.Ship_to
       			ELSE BSA_Foodservice_Customers.Ship_to END Ship_to,
       			CASE 
       			WHEN BAD.Distributor_ID = '00000000-0000-0000-0000-000000000000' THEN
                  BAD.Shipto_name
       			ELSE  BSA_Foodservice_Customers.Name END Ship_Name
				FROM   Billback_Associated_Distributors BAD
				LEFT JOIN BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = BAD.Distributor_ID  
				WHERE  BAD.Deleted = 0 AND BAD.Billback_ID = '#arguments.billbackId#'
				AND      BAD.Distributor_ID = '00000000-0000-0000-0000-000000000000'
		</cfquery>
		<cfreturn qGetAssociatedDistributor />
	</cffunction>
	
	<cffunction name="getBillbackIDForProgram" output="false" returntype="string">
		<cfargument name="billbackProgramId" type="string" required="true">
		<cfset useLakebaseForqGetBillbackID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForqGetBillbackID>
	<cftry>
		<cfset qGetBillbackID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program", {
				"deleted" = "eq.0",
				"billback_program_id" = "eq.#arguments.billbackProgramId#",
				"select" = "billback_id"
			}), "billback_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetBillbackID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetBillbackID>
<cfquery name="qGetBillbackID" datasource="#application.datasource#">
			SELECT	Billback_ID
			FROM	Billback_Program
			WHERE	Billback_Program.Deleted = 0
			AND		Billback_Program.Billback_Program_ID = '#arguments.billbackProgramId#'
		</cfquery>
</cfif>
		<cfreturn qGetBillbackID.Billback_ID />
	</cffunction>
	
	<cffunction name="getBillbackProgramId" output="false" returntype="string">
		<cfargument name="billbackId" type="string" required="true">
		<cfquery name="qGetBillbackID" datasource="#application.datasource#">
			SELECT	Billback_Program_ID
			FROM	Billback_Program
			WHERE	Billback_Program.Deleted = 0
			AND		Billback_Program.Billback_ID = '#arguments.billbackId#'
		</cfquery>
		<cfreturn qGetBillbackID.Billback_Program_ID />
	</cffunction>
	
	<cffunction name="getBillbackProgramId_ReturnQuery" output="false" returntype="query">
		<cfargument name="billbackId" type="string" required="true">
		<cfquery name="qGetBillbackID" datasource="#application.datasource#">
			SELECT	Billback_Program_ID, Program_ID 
			FROM	Billback_Program
			WHERE	Billback_Program.Deleted = 0
			AND		Billback_Program.Billback_ID = '#arguments.billbackId#'
		</cfquery>
		<cfreturn qGetBillbackID />
	</cffunction>
	
	<cffunction name="getMultiDistList" output="false" returntype="query">
		<cfargument name="billbackId" type="string" required="true">
		<cfquery name="qgetMultiDistList" datasource="#application.datasource#">
			DECLARE @Display_Distributor_ID BIT
			SET @Display_Distributor_ID = DBO.udf_GetAppSetting('Display_Distributor_ID') 
			
			select 	L.Distributor_ID, 
					Name, 
					State, 
					City, 
					Is_group, 
					C.BSA_Foodservice_Customers_ID,
					CASE WHEN @Display_Distributor_ID = '1' THEN
						c.Shr_Ship_To
					ELSE
						c.Ship_To
					END
					AS 	Shr_Ship_To
			From billback_distributor_list L
				LEFT JOIN 
					BSA_Foodservice_Customers C
					ON 
					(L.Distributor_ID = C.BSA_Foodservice_Customers_ID)
				--LEFT JOIN _States S
						--ON (S.State_ID = C.State)
			where L.Deleted = 0
			and C.Deleted = 0
			--and S.Deleted = 0
			and (is_group = 1 or captured_from_group=0)
			and Billback_ID = '#arguments.billbackId#'
		</cfquery>
		<cfreturn qgetMultiDistList />
	</cffunction>
	
	<cffunction name="getGroupDistList" output="false" returntype="query">
		<cfargument name="billbackId" type="string" required="true">
		<cfquery name="qgetGroupDistList" datasource="#application.datasource#">
			select L.Distributor_ID, Name, State, City, Is_group
			From billback_distributor_list L
				LEFT JOIN 
					BSA_Foodservice_Customers C
					ON 
					(L.Distributor_ID = C.BSA_Foodservice_Customers_ID)
				--LEFT JOIN _States S
						--ON (S.State_ID = C.State)
			where L.Deleted = 0
			and C.Deleted = 0
			--and S.Deleted = 0
			and (is_group = 0 or captured_from_group=1)
			and Billback_ID = '#arguments.billbackId#'
		</cfquery>
		<cfreturn qgetGroupDistList />
	</cffunction>
	
<!---/////////////////////////////////////////// Get ALL Distributor Ids for All BB Products ////////////////////////////////////////////////////////--->

	<cffunction name="getBBProdDistIdList" output="false" returntype="string">
		<cfargument name="billbackId" type="string" required="true">
		<cfquery name="qGetBBProdDistId" datasource="#application.datasource#">
			Select	Distinct BPD.Distributor_ID_Earned as BSA_Foodservice_Customers_ID
			From Billback_Product_Detail BPD
			INNER Join Billback_Product BP on BP.Billback_ID = '#arguments.billbackId#'
				AND BPD.Billback_Product_ID = BP.Billback_Product_ID
			where
				BPD.Billback_ID = '#arguments.billbackId#'	and 
				BPD.deleted = 0 AND
				BP.deleted = 0
		</cfquery>
		<cfreturn valueList(qGetBBProdDistId.BSA_Foodservice_Customers_ID) />
	</cffunction>
<!---\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\          //////////////////////////////////////////////////////////--->	
<!---/////////////////////////////////////////// Get ALL Distributor Ids in distList ////////////////////////////////////////////////////////--->

	<cffunction name="getBBCurrDistIdList" output="false" returntype="string">
		<cfargument name="billbackId" type="string" required="true">
		<cfset useLakebaseForqGetBBCurrDistId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_distributor_list")>
<cfif useLakebaseForqGetBBCurrDistId>
	<cftry>
		<cfset qGetBBCurrDistId = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_distributor_list", {
				"billback_id" = "eq.#FORM.Billback_ID#",
				"deleted" = "eq.0",
				"select" = "distributor_id"
			}), "distributor_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetBBCurrDistId = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetBBCurrDistId>
<cfquery name="qGetBBCurrDistId" datasource="#application.datasource#">
			Select	Distinct Distributor_ID 
				from Billback_Distributor_List
				where Billback_ID = '#FORM.Billback_ID#'
				and	Deleted = 0
		</cfquery>
</cfif>
		<cfreturn valueList(qGetBBCurrDistId.Distributor_ID) />
	</cffunction>
<!---\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\          //////////////////////////////////////////////////////////--->	
	
<!---\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\          //////////////////////////////////////////////////////////--->	
<!---/////////////////////////////////////////// Get Distributor Info from List ////////////////////////////////////////////////////////--->	

<cffunction name="getdistributorInfo" output="false" returntype="query">
	<cfargument name="distIdList" type="string" required="true">
	<CFQUERY NAME="qGetDistributorsInfo" datasource="#application.datasource#">
			SELECT  	DISTINCT BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID, 
						BSA_Foodservice_Customers.Name, 
						BSA_Foodservice_Customers.Address_1, 
						BSA_Foodservice_Customers.City, 
						BSA_Foodservice_Customers.State,
						BSA_Foodservice_Customers.country_code, 
						BSA_Foodservice_Customers.ZipCode,
						BSA_Foodservice_Customers.Ship_To, 
						BSA_Foodservice_Customers.Active_Code,  
						BSA_Foodservice_Customers.Shr_Ship_To
			FROM		BSA_Foodservice_Customers 
				Where BSA_Foodservice_Customers_ID in (#Listqualify(arguments.distIdList,"'",",")#)
	</CFQUERY>
	<cfreturn qGetDistributorsInfo>
</cffunction>	

<!---\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\          //////////////////////////////////////////////////////////--->	
<!---/////////////////////////////////////////// Remove BB products using list of distributors ////////////////////////////////////////////////////////
	\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ used when distributors are removed from a BB, we need to take thir products with them.////////////////--->	

<cffunction name="removeDistributorProducts" output="false" returntype="void">
	<cfargument name="distIdList" type="string" required="true">
	<cfargument name="billbackId" type="string" required="true">
		<CFQUERY NAME="qRemoveDistributorProducts" datasource="#application.datasource#">
				Update Billback_Product set deleted = 1---, created_date = getdate()
									Where 
										Billback_ID= '#arguments.BillbackID#' AND
										Distributor_id in (#Listqualify(arguments.distIdList,"'",",")#)
		</CFQUERY>
		<CFQUERY NAME="qRemoveDistributorProductDetail" datasource="#application.datasource#">
				Update Billback_Product_detail set deleted = 1----, created_date = getdate()
									Where 
										Billback_ID= '#arguments.BillbackID#' AND
										Distributor_id_Earned in (#Listqualify(arguments.distIdList,"'",",")#)
		</CFQUERY>
</cffunction>		
<!---\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\          //////////////////////////////////////////////////////////--->			
	<cffunction name="GetProductFamily" output="false" returntype="query">
		<cfargument name="billbackId" type="string" required="true">
		<cfargument name="Billback_Program_ID" type="string" required="true">
		<CFQUERY NAME="qGetProductFamily" DATASOURCE="#Application.Datasource#">
									SELECT 		DISTINCT 	Billback_Program_ID,
															Product_Hierarchy.Product_Hierarchy_ID,
															Product_Hierarchy_Volume,
															BB_Product_UOM,
															Unit_Of_Measure_Desc,
															<!--- Product_Hierarchy_Rate,
															BB_Product_Type_ID, --->
															Product_Hierarchy.Product_Hierarchy,
															Product_Hierarchy.Product_Hierarchy_Name,
															Sum (cast(Billback_Product_Detail.Volume as float))  as FamilyVol,
															--Sum (cast(bb_product_Quantity as float))  as FamilyVol,
															Sum (cast(bb_rate as float))  as FamilyRate
															,CASE
																WHEN Earned_From_Group = 0	THEN
																	Billback_Product_Detail.Distributor_ID_Earned
																ELSE
																	Billback_Product_Detail.Customer_Group_ID
																END as dist_id
															, Earned_From_Group
															,c.Name
									FROM		Billback_Product
									INNER JOIN 	Billback_Product_Detail ON Billback_Product_Detail.Billback_ID = '#arguments.BillbackID#'
															AND Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID
									INNER JOIN 	Units_of_Measure ON Units_of_Measure.Unit_Of_Measure_ID = Billback_Product.BB_Product_UOM
									LEFT JOIN 	Product_Hierarchy ON Product_Hierarchy.Product_Hierarchy_ID = Billback_Product.Product_Hierarchy_ID
									Left join   BSA_Foodservice_customers C on C.BSA_Foodservice_Customers_ID =  CASE
																WHEN Earned_From_Group = 0	THEN
																	Billback_Product_Detail.Distributor_ID_Earned
																ELSE
																	Billback_Product_Detail.Customer_Group_ID
																END
									
									WHERE 		Billback_Product.Billback_ID = '#arguments.BillbackID#' AND
												Billback_Program_ID = '#arguments.Billback_Program_ID#' AND
												Billback_Product.Deleted = 0 AND Billback_Product_Detail.Deleted = 0 -- AND Product_Hierarchy.Deleted = 0
									Group by   Billback_Program_ID,
												Product_Hierarchy.Product_Hierarchy_ID,
												Product_Hierarchy_Volume,
												BB_Product_UOM,
												Unit_Of_Measure_Desc,
												Product_Hierarchy.Product_Hierarchy,
												Product_Hierarchy.Product_Hierarchy_Name
												,CASE
																WHEN Earned_From_Group = 0	THEN
																	Billback_Product_Detail.Distributor_ID_Earned
																ELSE
																	Billback_Product_Detail.Customer_Group_ID
																END
												, Earned_From_Group
												, Name
									ORDER BY 	CASE
																WHEN Earned_From_Group = 0	THEN
																	Billback_Product_Detail.Distributor_ID_Earned
																ELSE
																	Billback_Product_Detail.Customer_Group_ID
																END, Product_Hierarchy_Name, Billback_Product_Detail.Earned_From_Group								
								</CFQUERY> 
			<cfreturn qGetProductFamily />
	</cffunction>
	
	
	<!---\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\          //////////////////////////////////////////////////////////--->			
	<cffunction name="GetProductFamilyPayment" output="false" returntype="query">
		<cfargument name="billbackId" type="string" required="true">
		<cfargument name="Billback_Program_ID" type="string" required="true">
		<CFQUERY NAME="qGetProductFamily" DATASOURCE="#Application.Datasource#">
									SELECT 		DISTINCT 	--Billback_Program_ID,
															--Product_Hierarchy.Product_Hierarchy_ID,
															--Product_Hierarchy_Volume,
															--BB_Product_UOM,
															--Unit_Of_Measure_Desc,
															<!--- Product_Hierarchy_Rate,
															BB_Product_Type_ID, --->
															Product_Hierarchy.Product_Hierarchy,
															Product_Hierarchy.Product_Hierarchy_Name,
															Sum (cast(Billback_Product_Detail.Volume as float))  as FamilyVol,
															Sum (cast(bb_product_Quantity as float))  as FamilyVol,
															Sum (cast(bb_rate as float))  as FamilyRate
															--,Billback_Product_Detail.Distributor_ID_Earned
															--,Billback_Product_Detail.Customer_Group_ID
															,Earned_From_Group
															--,c.Name				as EarnedName
															--,gc.name			as GroupName
															,C.Shr_Ship_To 	as Earned_Ship_TO
															,CASE
																WHEN Earned_From_Group = 0	THEN
																	GC.Shr_Ship_To
																ELSE
																	GC.Shr_Ship_To
																END 	as Group_Ship_To
															
															
									FROM		Billback_Product
									INNER JOIN 	Billback_Product_Detail ON Billback_Product_Detail.Billback_ID = '#arguments.BillbackID#'
															AND Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID
									INNER JOIN 	Units_of_Measure ON Units_of_Measure.Unit_Of_Measure_ID = Billback_Product.BB_Product_UOM
									LEFT JOIN 	Product_Hierarchy ON Product_Hierarchy.Product_Hierarchy_ID = Billback_Product.Product_Hierarchy_ID
									Left join   BSA_Foodservice_customers C on C.BSA_Foodservice_Customers_ID =  
																	Billback_Product_Detail.Distributor_ID_Earned
									Left join   BSA_Foodservice_customers GC on GC.BSA_Foodservice_Customers_ID = 
																	Billback_Product_Detail.Customer_Group_ID
									
									WHERE 		Billback_Product.Billback_ID = '#arguments.BillbackID#' AND
												Billback_Program_ID = '#arguments.Billback_Program_ID#' AND
												Billback_Product.Deleted = 0 AND Billback_Product_Detail.Deleted = 0 -- AND Product_Hierarchy.Deleted = 0
									Group by   Billback_Program_ID,
												Product_Hierarchy.Product_Hierarchy_ID,
												Product_Hierarchy_Volume,
												BB_Product_UOM,
												Unit_Of_Measure_Desc,
												Product_Hierarchy.Product_Hierarchy,
												Product_Hierarchy.Product_Hierarchy_Name
												, Earned_From_Group
												,C.Shr_Ship_To
												,GC.Shr_Ship_To							
								</CFQUERY> 
			<cfreturn qGetProductFamily />
	</cffunction>
	
	
	<cffunction name="Get_Program_Products" output="false" returntype="query">
		<cfargument name="billback_Id" type="string" required="true">
		<cfargument name="Distributor_ID" type="string" required="true">
		<cfargument name="Display_Product_Group_BB" type="boolean" required="true">
		<cfargument name="Group_Claim_By_Product_Attribute" type="numeric" required="true">
		<cfargument name="Include_Claim_Adjustment" type="boolean" required="false" default="0">
		
		<cfif arguments.Display_Product_Group_BB EQ 1>
		<cfset productGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />
<cfset ProductGroupType	= productGroupAttributeManager.getProductGroupAttributes(groupLevelId = arguments.Group_Claim_By_Product_Attribute) />
		</cfif>

		<CFSET DiscountList = "1,2,4,10"><!--- input for inc_eligible_products.cfm ---->					
		<CFSET BBID = arguments.Billback_ID><!--- input for inc_eligible_products.cfm ---->
		<CFSET BB_Contract_Main_ID = getBillbackProgramId_ReturnQuery(BBID)>
		
		<CFIF BB_Contract_Main_ID.RecordCount GT 1>			
			<CFSET GetParentIDFor_MultiPrograms = 1>
		</CFIF>
		<CFSET Billback_Contract_Main_ID = VALUELIST(BB_Contract_Main_ID.Program_ID)><!--- input for inc_eligible_products.cfm ---->
		
		<CFSET DontExecSPInInclude = 1>
		<CFIF BB_Contract_Main_ID.RecordCount NEQ 0>
		<CFINCLUDE template="/billbacks/capture/inc_eligible_products.cfm">
		</CFIF>
			
		<cfquery name="qChkBBIIL" datasource="#application.datasource#">	
			SELECT Count(*) AS RecCount FROM BB_Item_Invoice_Level WHERE Billback_ID = '#arguments.Billback_ID#'
		</cfquery>
		
		<cfif (qChkBBIIL.RecCount GTE 1 AND application.appSettingsGet.getViewOperatorinBillbackDeviation())>
			<!--- New Query --->
			<cfquery name="qGet_Program_Products" datasource="#application.datasource#">
				<CFIF BB_Contract_Main_ID.RecordCount NEQ 0>
					IF OBJECT_ID('tempdb..##Temp_Product_On_Program_2') IS NOT NULL
					DROP TABLE ##Temp_Product_On_Program_2
							
					CREATE TABLE ##Temp_Product_On_Program_2
					(	
						Product_ID_2 uniqueidentifier, 
						DiscountTypeID_2 int, 
						Contract_Number_2 varchar(50)
					)
					<CFIF getParentIDs_List NEQ "">
						INSERT INTO ##Temp_Product_On_Program_2(Product_ID_2,DiscountTypeID_2,Contract_Number_2)
						EXEC BB_Products_On_Program '#Billback_ID#', '#getParentIDs_List#',#Payee_Type# 
					</CFIF>
				</CFIF>		
				SELECT 	
					bil.Billback_Program_ID,
					bil.Billback_Product_ID,
					bil.product_id AS BSA_Foodservice_Items_Master_ID,
					cm.Contract_Main_ID,
					
					CASE bil.UOM 
					WHEN 1 THEN 
						ISNULL(bil.Claimed_CS,0)
					ELSE 
						ISNULL(bil.Claimed_LB,0)
					END AS BB_Product_Quantity,
					
					Units_Of_Measure.Unit_Of_Measure_Desc,
					<cfif arguments.Display_Product_Group_BB EQ 1>
						#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_TABLE#.#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_NAME_FIELD# as Group_Name_Id,
						cast(#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_TABLE#.#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD# as nvarchar(50)) as Group_Id,
					<cfelse>
					'' as Group_Name_Id, '' as Group_Id,
					</cfif>
					CASE bil.UOM 
					WHEN 1 THEN 
						bil.Claimed_CS
					ELSE 
						bil.Claimed_LB / CAST(i.net_weight AS FLOAT)
					END AS Claimed_CS,
					
					CASE bil.UOM 
					WHEN 1 THEN 
						bil.Claimed_CS * CAST(i.net_weight AS FLOAT)
					ELSE 
						ISNULL(bil.Claimed_LB,0)
					END AS Claimed_LB,
		
					CASE bil.UOM 
					WHEN 1 THEN 
						bil.Allocated_Expected_CS
					ELSE 
						bil.Allocated_Expected_LB / CAST(i.net_weight AS FLOAT)
					END AS Expected_CS,
					
					CASE bil.UOM 
					WHEN 1 THEN 
						bil.Allocated_Expected_CS * CAST(i.net_weight AS FLOAT)
					ELSE 
						bil.Allocated_Expected_LB
					END AS Expected_LB,
			
					bil.Program_ID,
					CASE bil.UOM 
					WHEN 1 THEN 
						ISNULL(bil.Expected_Rate_CS,0)
					ELSE 
						ISNULL(bil.Expected_Rate_LB,0)
					END AS Expected_Rate,
					<!--- CASE bil.UOM 
					 WHEN 1 THEN 
						bil.Claimed_Rate_CS
					ELSE 
						bil.Claimed_Rate_LB
					END AS BillBack_Rate, --->
					bil.Claimed_Amt AS BillBack_Rate,
					CASE WHEN 
						b.billback_status_id >= 3  AND bil.UOM = 1  THEN ISNULL(Selected_Rate_CS,0)
					WHEN 
						b.billback_status_id >= 3  AND bil.UOM = 2  THEN ISNULL(Selected_Rate_LB,0)
					ELSE
					0
					END
					AS Approved_Rate,
							
					CASE WHEN bil.UOM = 1 THEN 
						bil.Claimed_CS
					ELSE
						ISNULL(bil.Claimed_LB,0)
					END AS Item_BB_Volume,
					CASE WHEN bil.UOM = 1 THEN 
					ISNULL(Allocated_Expected_CS,0) 
					ELSE
						ISNULL(Allocated_Expected_LB,0)
					END AS Item_E_Volume,
					CASE WHEN 
						b.billback_status_id >= 3  AND bil.UOM = 1  THEN Selected_Vol_CS
					WHEN 
						b.billback_status_id >= 3  AND bil.UOM = 2  THEN Selected_Vol_LB
					ELSE
					0
					END AS Item_Approved_Volume,
					
					CASE WHEN 
						b.billback_status_id <= 2 THEN 0
					ELSE
						CASE bil.UOM 
						WHEN 1 THEN 
							bil.Selected_Vol_CS
						ELSE 
							bil.Selected_Vol_LB / cast(i.net_weight as float)
						END 
					END AS Item_Approved_Volume_CS,
					
					CASE bil.UOM 
					WHEN 1 THEN 
						bil.Claimed_CS
					ELSE 
						ISNULL(bil.Claimed_LB,0) / CAST(i.net_weight AS FLOAT)
					END  AS Item_Approved_Volume_CS, 
					
					CASE WHEN b.billback_status_id <= 2 THEN 0
					ELSE
						CASE bil.UOM 
						WHEN 1 THEN ISNULL(bil.Selected_Vol_CS, 0) * CAST(ISNULL(i.net_weight,0) AS FLOAT)
						ELSE ISNULL(bil.Selected_Vol_LB, 0)
						END 
					END AS Item_Approved_Volume_LB,
					ISNULL(bil.Allocated_Expected_CS, 0)  AS Item_Expected_Volume_CS,
					ISNULL(bil.Allocated_Expected_LB, 0) AS Item_Expected_Volume_LB,
					CAST(bil.Expected_Rate_CS * bil.Allocated_Expected_CS AS 
					DECIMAL(20, 2)) AS Expected_Amount_CS,
					bil.Claimed_Amt AS Approved_Amount_CS,
					ISNULL(bil.Claimed_CS,0) AS Item_BB_Volume_CS,
					ISNULL(bil.Claimed_LB,0) AS Item_BB_Volume_LB,
					CASE 
						WHEN Program_ID IS NULL THEN
							b.BB_Start_Date
						ELSE
							cm.Contract_Start_Date
						END AS Start_Date,
					CASE 
						WHEN Program_ID IS NULL THEN
							b.BB_End_Date
						ELSE
							cm.Contract_End_Date
						END AS End_Date,
					
					cm.contract_title AS Program_Title,
					cm.contract_number AS Program_Number, 
					i.item AS Item_Number, i.Description,
					bil.Discount_Type_ID AS BB_Product_Type_ID,
					
					bil.Claimed_Amt AS BB_Rate,
					bil.distributor_id as dist_id,
					c.name,
					c.shr_ship_to as ship_to,
					bil.Discount_Type_ID AS Product_Type_ID,
					/* -- Expected Amount */
					CAST(CASE bil.UOM 
					WHEN 1 THEN 
						bil.Expected_Rate_CS * bil.Allocated_Expected_CS
					ELSE 
						bil.Expected_Rate_LB * bil.Allocated_Expected_LB
					END AS DECIMAL(20, 2)) AS Expected_Amount,
					CASE WHEN b.billback_status_id <= 2 THEN 0
					ELSE
						bil.Final_Payment
					END AS Approved_Amount,
					CASE WHEN (##Temp_Product_On_Program_2.Product_ID_2 IS NOT NULL AND ##Temp_Product_On_Program_2.DiscountTypeID_2 
					IS NOT NULL AND ##Temp_Product_On_Program_2.Contract_Number_2 IS NOT NULL ) 
					THEN 1 ELSE 0 END AS IsProductOnProgram, 		
					ISNULL(i.Is_Divested, 0) as Is_Divested
					,bil.Operator_ID
					,bo.Operator_Name
					,LTRIM(RTRIM(CAST (bo.Legacy_ID AS varchar(22)))) + CHAR(13) + RTRIM(bo.Operator_Name) AS Operator_Details
					,bo.Operator_Address + CHAR(13) +  bo.Operator_State + CHAR(13) + bo.Operator_Zip AS Operator_Address
					,bo.Legacy_ID		
			from	billback b
			inner join bb_item_invoice_level bil
			on		bil.billback_id = b.billback_id
			and		bil.deleted = 0
			inner join contract_main cm
			on		cm.contract_main_id = bil.program_id
			left join bsa_foodservice_customers c
			on		c.bsa_foodservice_customers_id = bil.distributor_id
			left join bsa_foodservice_items_master i
			on		i.bsa_foodservice_items_master_id = bil.product_id
			left join bsa_operator bo
			on		bo.bsa_operator_id = bil.operator_id
			LEFT JOIN	Units_of_Measure ON Units_of_Measure.Unit_Of_Measure_ID = bil.UOM 
			LEFT JOIN	##Temp_Product_On_Program_2 ON ##Temp_Product_On_Program_2.Product_ID_2 = bil.Product_ID AND 
									(	
										bil.Discount_Type_ID = 11 AND ##Temp_Product_On_Program_2.DiscountTypeID_2 = 10 OR					
										##Temp_Product_On_Program_2.DiscountTypeID_2 = bil.Discount_Type_ID 
									) AND
									##Temp_Product_On_Program_2.Contract_Number_2 = cm.Contract_Number  
			<cfif arguments.Display_Product_Group_BB EQ 1>
			LEFT JOIN 	#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_TABLE# ON 
						#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_TABLE#.#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD# = i.#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD#
			</cfif>						
			WHERE b.billback_id =  '#arguments.Billback_ID#'	  -- BB-1008673-00 Payment Req
			ORDER BY 
				bil.Billback_Program_ID, 
				c.ship_to, 
				bo.Legacy_ID,
				ISNULL(i.Is_Divested, 0), 
				IsProductOnProgram DESC,
				bil.Discount_Type_ID, 
				Item_Number 
			
			</cfquery>
		<cfelse>
			<!--- Old Query --->
			<cfquery name="qGet_Program_Products" datasource="#application.datasource#">
				<CFIF BB_Contract_Main_ID.RecordCount NEQ 0>
				IF OBJECT_ID('tempdb..##Temp_Product_On_Program_2') IS NOT NULL
						DROP TABLE ##Temp_Product_On_Program_2
						
				CREATE TABLE ##Temp_Product_On_Program_2
				(	
					Product_ID_2 uniqueidentifier, 
					DiscountTypeID_2 int, 
					Contract_Number_2 varchar(50)
				)
				<CFIF getParentIDs_List NEQ "">
				INSERT INTO ##Temp_Product_On_Program_2(Product_ID_2,DiscountTypeID_2,Contract_Number_2)
				EXEC BB_Products_On_Program '#Billback_ID#', '#getParentIDs_List#',#Payee_Type# 
				</CFIF>
				</CFIF>
				
				DECLARE @billback_include_zero_dollar_products bit,
				@Display_Item_No bit
				
				SET @billback_include_zero_dollar_products = DBO.udf_billback_include_zero_dollar_products()
				SET @Display_Item_No = DBO.udf_GetAppSetting('Display_Item_No') 
				
				SELECT	DISTINCT 
					CASE
						WHEN Billback_Program.Billback_Program_ID IS NULL THEN 
							'99999999-9999-9999-9999-999999999999'
						ELSE
							Billback_Program.Billback_Program_ID
					END AS Billback_Program_ID,
						Billback_Product.Billback_Product_ID, BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, Billback_Product.BB_Product_Quantity, Units_Of_Measure.Unit_Of_Measure_Desc
					,contract_main.contract_main_id,
					<cfif arguments.Display_Product_Group_BB EQ 1>
					#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_TABLE#.#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_NAME_FIELD# as Group_Name_Id,
					cast(#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_TABLE#.#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD# as nvarchar(50)) as Group_Id,
					<cfelse>
					'' as Group_Name_Id, '' as Group_Id,
					</cfif>
						Display_Product_Hierarchy,
						program_id, 
			CASE BB_Product_type_id
			WHEN 10 THEN
					ISNULL(Billback_Product_Detail.discount_offered, 0)
				ELSE 
					CASE
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						ISNULL(BB_Item_Final_Detail.Expected_rate_CS, 0)
					ELSE
						ISNULL(BB_Item_Final_Detail.Expected_rate_LB, 0)
					END 
				END
			AS Expected_Rate,
			CASE
			WHEN Billback_Product.BB_Product_UOM = 1 THEN
				ISNULL(Billback_Product_Detail.BB_Rate, 0)
			ELSE
				ISNULL(Billback_Product_Detail.BB_Rate, 0)
			END AS Billback_Rate,
			CASE BB_Product_type_id
			WHEN 10 THEN
					ISNULL(Billback_Product_Detail.discount_offered, 0)
				ELSE
					CASE
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						ISNULL(BB_Item_Final_Detail.Paid_Rate_CS, 0)
					ELSE
						ISNULL(BB_Item_Final_Detail.Paid_Rate_LB, 0)
					END
				END
			AS Approved_Rate,
			CASE
			WHEN Billback_Product.BB_Product_UOM = 1 THEN
				ISNULL(cast(Billback_Product.BB_Product_Quantity as float), 0)
			ELSE
				ISNULL(cast(Billback_Product.BB_Product_Quantity as float), 0)
			END AS Item_BB_Volume,
			CASE
			WHEN Billback_Product.BB_Product_UOM = 1 THEN
				ISNULL(BB_Item_Final.Item_E_Volume_CS, 0)
			ELSE
				ISNULL(BB_Item_Final.Item_E_Volume_LB, 0)
			END AS Item_E_Volume,
			CASE
			WHEN Billback_Product.BB_Product_UOM = 1 THEN
				ISNULL(BB_Item_Final.Item_Volume_Paid_CS, 0)
			ELSE
				ISNULL(BB_Item_Final.Item_Volume_Paid_LB, 0)
			END AS Item_Approved_Volume,
	
			<!--- The Above was replaced with the 4 columns below --->
			isnull(BB_Item_Final.Item_Volume_Paid_CS,0) AS Item_Approved_Volume_CS,
			
			isnull(BB_Item_Final.Item_Volume_Paid_LB,0)  AS Item_Approved_Volume_LB,
				
			isnull(BB_Item_Final.Item_E_Volume_CS,0)  AS Item_Expected_Volume_CS,

			isnull(BB_Item_Final.Item_E_Volume_LB,0)  AS Item_Expected_Volume_LB,

			isnull(cast((BB_Item_Final.Item_E_Volume_CS * BB_Item_Final_Detail.Expected_rate_CS) as decimal(18,2)), 0) as Expected_Amount_CS,
			isnull(cast((BB_Item_Final.Item_Volume_Paid_CS * BB_Item_Final_Detail.Paid_Rate_CS) as decimal(18,2)), 0) as Approved_Amount_CS,
			
			ISNULL(CASE WHEN Billback_Product.BB_Product_UOM = 1 THEN
 			ISNULL(cast(Billback_Product.BB_Product_Quantity as float), 0) ELSE 
			ISNULL(cast(Billback_Product.BB_Product_Quantity as float), 	0)/net_weight END,0) AS Item_BB_Volume_CS,
 			ISNULL(CASE WHEN Billback_Product.BB_Product_UOM = 2 OR Billback_Product.BB_Product_UOM = 3 THEN 
			ISNULL(cast(Billback_Product.BB_Product_Quantity as float), 0) ELSE 
			ISNULL(cast(Billback_Product.BB_Product_Quantity as float), 0)* net_weight END,0) AS Item_BB_Volume_LB,
				
				<!--- Contract dates to be displayed in the summary --->
				CASE 
						WHEN Program_ID IS NULL THEN
							Billback.BB_Start_Date
						ELSE
							Contract_Main.Contract_Start_Date
					END AS Start_Date,
				CASE 
						WHEN Program_ID IS NULL THEN
							Billback.BB_End_Date
						ELSE
							Contract_Main.Contract_End_Date
					END AS End_Date,
				<!--- BJF You only need the logic below if you add completely unknown programs, which we've disabled --->
				CASE 
						WHEN Program_ID IS NULL THEN
							Billback_Program.BB_Program_Title
						ELSE
							Contract_Main.Contract_Title
					END AS Program_Title,
		<!--- CASE
				WHEN Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
					0
				ELSE
					1
			END
			AS IsProductOnProgram, --->
				CASE 
					WHEN Program_ID IS NULL THEN
						Billback_Program.BB_Program_Number
					ELSE
						Contract_Main.Contract_Number
				END AS Program_Number
				,CASE 
					WHEN @Display_Item_No = '1' THEN
						CASE 
							WHEN Product_ID IS NULL THEN
								Billback_Product.BB_Unknown_Product_Item_Number
							ELSE
								BSA_Foodservice_Items_Master.Item
						END 
					ELSE
						CASE 
							WHEN Product_ID IS NULL THEN
								Billback_Product.BB_Unknown_Product_Item_Number
							ELSE
								BSA_Foodservice_Items_Master.UPC
							END
					END
				AS Item_Number
				,CASE 
					WHEN Product_ID IS NULL THEN
						Billback_Product.BB_Unknown_Product_Description
					ELSE
						BSA_Foodservice_Items_Master.Description
				END AS Description,
				BB_Product_Type_ID, 
				BB_Rate, 
				CASE
					WHEN Earned_From_Group = 0	THEN
						Billback_Product_Detail.Distributor_ID_Earned
					ELSE
						Billback_Product_Detail.Customer_Group_ID
					END as dist_id, 
				c.name, 
				c.ship_to,
				<!--- CASE
					WHEN 	(SELECT COUNT(*) FROM Contract_Main WHERE Contract_Main_ID IN (	
																							SELECT	Contract_Main_ID
																							FROM	Contract_Main
																							WHERE	Contract_Number IN (SELECT DISTINCT Contract_Number FROM Contract_Main WHERE Contract_Main_ID = Contract_Main.Contract_Main_ID)
																						)
							) = 0 THEN '1'
					ELSE
						'0'
				END AS Product_Not_On_Program, --->
				Billback_Product.Product_Type_ID,
 <!--- D22078:Anand Rao/21-Jan-10: 
        Rounding fixing, Added two new fields Expected_Amount, Approved_amount--->                
 CAST((CASE
			WHEN Billback_Product.BB_Product_UOM = 1 THEN
				ISNULL(BB_Item_Final.Item_E_Volume_CS, 0)
			ELSE
				ISNULL(BB_Item_Final.Item_E_Volume_LB, 0)
			END) *
      (CASE BB_Product_type_id
			WHEN 10 THEN
					ISNULL(Billback_Product_Detail.discount_offered, 0)
				ELSE 
					CASE
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						ISNULL(BB_Item_Final_Detail.Expected_rate_CS, 0)
					ELSE
						ISNULL(BB_Item_Final_Detail.Expected_rate_LB, 0)
					END 
				END) as decimal(20, 2))
			AS Expected_Amount,   
      CAST((CASE
			WHEN Billback_Product.BB_Product_UOM = 1 THEN
				ISNULL(BB_Item_Final.Item_Volume_Paid_CS, 0)
			ELSE
				ISNULL(BB_Item_Final.Item_Volume_Paid_LB, 0)
			END) *
      (CASE BB_Product_type_id
			WHEN 10 THEN
					ISNULL(Billback_Product_Detail.discount_offered, 0)
				ELSE
					CASE
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						ISNULL(BB_Item_Final_Detail.Paid_Rate_CS, 0)
					ELSE
						ISNULL(BB_Item_Final_Detail.Paid_Rate_LB, 0)
					END
				END) as decimal(20, 2))
			AS Approved_Amount,              
				<CFIF BB_Contract_Main_ID.RecordCount NEQ 0>
				CASE 
				WHEN	(##Temp_Product_On_Program_2.Product_ID_2 IS NOT NULL AND 
						##Temp_Product_On_Program_2.DiscountTypeID_2 IS NOT NULL AND 
						##Temp_Product_On_Program_2.Contract_Number_2 IS NOT NULL ) THEN
					1
				ELSE
					0
				END AS IsProductOnProgram
				<CFELSE>
				0 AS IsProductOnProgram
				</CFIF>
				,ISNULL(BSA_Foodservice_Items_Master.Is_Divested, 0) as Is_Divested
				<CFIF application.appSettingsGet.getViewOperatorinBillbackDeviation()>
					,op.BSA_Operator_ID AS Operator_ID
					,op.Operator_Name
					,LTRIM(RTRIM(CAST (op.Legacy_ID AS varchar(22)))) + CHAR(13) + RTRIM(op.Operator_Name) AS Operator_Details
					,op.Operator_Address + CHAR(13) +  op.Operator_State + CHAR(13) + op.Operator_Zip AS Operator_Address
					,op.Legacy_ID
				<cfelse>
					,'' as Legacy_ID	
				</CFIF>
				,Billback_Product.BS_Var_2 
				,Billback_Product.User_Picked_UOM
				,Billback_Product.User_Entered_Quantity
				,UPUOM.Abbreviation AS User_UOM_DESC
				FROM	
			Billback
			INNER JOIN	Billback_Program ON Billback_Program.Billback_ID = Billback.Billback_ID AND
						Billback_Program.Deleted = 0
			LEFT JOIN	Contract_Main ON Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
			LEFT JOIN	Billback_Product ON Billback_Product.Billback_ID = '#arguments.Billback_ID#' AND
						Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID AND
						Billback_Product.Deleted = 0
			LEFT JOIN	BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID
			
			LEFT JOIN	Billback_Product_Detail ON Billback_Product_Detail.Billback_ID = '#arguments.Billback_ID#'	AND
						<cfif arguments.Include_Claim_Adjustment eq 0>							
							Billback_Product_Detail.BB_Product_Type_ID IN (1,2,4,5,11) AND
						<cfelse>
							Billback_Product_Detail.BB_Product_Type_ID IN (1,2,4,5,10,11) AND
						</cfif>
						Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID AND
						Billback_Product_Detail.Deleted = 0 AND
						Billback_Product_Detail.BB_Rate IS NOT NULL AND
						LEN(Billback_Product_Detail.BB_Rate) > 0 AND
						ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1 AND
						(@billback_include_zero_dollar_products = 1 OR CAST(Billback_Product_Detail.BB_Rate AS Float) <> 0)		
			LEFT JOIN	Units_of_Measure ON Units_of_Measure.Unit_Of_Measure_ID = Billback_Product.BB_Product_UOM	
			LEFT JOIN	Units_of_Measure UPUOM ON UPUOM.Unit_Of_Measure_ID = Billback_Product.User_Picked_UOM	
			LEFT JOIN	BB_Item_Final ON 
						BB_Item_Final.Billback_ID = '#arguments.Billback_ID#'	 AND
						BB_Item_Final.Billback_Program_ID = Billback_Program.Billback_Program_ID AND
						BB_Item_Final.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID AND 
						BB_Item_Final.Deleted = 0
			LEFT JOIN	BB_Item_Final_Detail ON BB_Item_Final_Detail.BB_Item_Final_ID = BB_Item_Final.BB_Item_Final_ID AND
						BB_Item_Final_Detail.BB_Product_Type = Billback_Product_Detail.BB_Product_Type_ID AND
						BB_Item_Final_Detail.Deleted = 0
			LEFT JOIN   BSA_Foodservice_customers C ON C.BSA_Foodservice_Customers_ID = 
						CASE
							WHEN Earned_From_Group = 0	THEN
								Billback_Product_Detail.Distributor_ID_Earned
							ELSE
								Billback_Product_Detail.Customer_Group_ID
							END
			<CFIF application.appSettingsGet.getViewOperatorinBillbackDeviation()>				
				LEFT JOIN Billback_Operator BO ON BO.Billback_ID = 	Billback.Billback_ID		
				LEFT JOIN BSA_Operator op ON op.BSA_Operator_ID = BO.Operator_ID
			</CFIF>
			<cfif arguments.Display_Product_Group_BB EQ 1>
			LEFT JOIN 	#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_TABLE# ON 
						#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_TABLE#.#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD# = BSA_Foodservice_Items_Master.#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD#
			</cfif>
			<CFIF BB_Contract_Main_ID.RecordCount NEQ 0>
			LEFT JOIN	##Temp_Product_On_Program_2 ON ##Temp_Product_On_Program_2.Product_ID_2 = Billback_Product.Product_ID AND 
						(	
							Billback_Product_Detail.BB_Product_Type_ID = 11 AND ##Temp_Product_On_Program_2.DiscountTypeID_2 = 10 OR					
							##Temp_Product_On_Program_2.DiscountTypeID_2 = Billback_Product_Detail.BB_Product_Type_ID
						) AND
						##Temp_Product_On_Program_2.Contract_Number_2 = Contract_Main.Contract_Number  
			</CFIF>
      <!--- 
      	Dev Notes: D23069/Anand Rao/23-Apr-10
      	BB summary - divested items on 2 programs makes the program to repeat
        Moved the Is_Divested column to the 3rd position in order by
      --->      
			WHERE		Billback.Billback_ID = '#arguments.Billback_ID#'		
			ORDER BY 	Billback_Program_ID, c.ship_to, ISNULL(BSA_Foodservice_Items_Master.Is_Divested, 0), IsProductOnProgram DESC,Billback_Product.Product_Type_ID,
						<cfif arguments.Display_Product_Group_BB EQ 1>
							#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_TABLE#.#ProductGroupType.PRODUCT_GROUP_ATTRIBUTE_NAME_FIELD#,
						</cfif>
						item_number, BB_Product_Type_ID
		<CFIF BB_Contract_Main_ID.RecordCount NEQ 0>
			DROP TABLE ##Temp_Product_On_Program_2
		</CFIF>
		</cfquery>
		</cfif>	
			
	<cfreturn qGet_Program_Products />

	</cffunction>
	
	
	<cffunction name="Get_Program_Lumpsum_Products" output="false" returntype="query">
		<cfargument name="billbackId" type="string" required="true">
			<cfquery name="qGet_Program_Lumpsum_Products" datasource="#application.datasource#">
				SELECT     
							Billback_Program_Lumpsum_Component.Billback_Program_ID
							, Billback_Program_Lumpsum_Component_ID, ISNULL(CAST(Amount AS FLOAT),0) as AMOUNT
							,CASE 
							WHEN Component_Type_ID = 1 THEN
								Program_Lump_Sum_Name.Program_Lump_Sum_Name
							WHEN Component_Type_ID = 3 THEN
								Program_Growth_Components.Component_Name + ' Tier ' + Program_Growth_Component_Tiers.Tier_Number
							ELSE
								Billback_Program_Lumpsum_Component.Name
							END AS Component_Name					
				FROM       Billback_Program_Lumpsum_Component
							LEFT JOIN Program_Lump_Sums
							ON
							(
								(Program_Lump_Sums.Program_Lump_Sum_ID = Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID)
							)
							LEFT JOIN Program_Lump_Sum_Name
							ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
							LEFT JOIN Program_Growth_Components
							ON
							(
								Program_Growth_Components.Program_Growth_Component_ID = Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID
							)
							LEFT JOIN Program_Growth_Component_Tiers
							ON
							(
								Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID = Billback_Program_Lumpsum_Component.Program_Growth_Component_Tier_ID
							)
				WHERE 
						(Billback_Program_Lumpsum_Component.Amount IS NOT NULL)
						AND
						(LEN(Billback_Program_Lumpsum_Component.Amount) > 0)
						AND
						(ISNUMERIC(Billback_Program_Lumpsum_Component.Amount) = 1)
						<!---AND
						(CAST(LTRIM(Billback_Program_Lumpsum_Component.Amount) AS Float) > 0)--->
						AND
						Billback_Program_Lumpsum_Component.Billback_ID 		= '#arguments.BillbackID#'
						AND
						Billback_Program_Lumpsum_Component.Deleted 			= 0
				ORDER BY Billback_Program_Lumpsum_Component.Billback_Program_ID
			</cfquery>
	
		<cfreturn qGet_Program_Lumpsum_Products />
	</cffunction>
	
	
	<!---------------------- LumpsUm --------------------------->
	<!--- This is for Grouped LS. For individual LS, look at function "Get_All_Program_Lumpsum" --->
	<cffunction name="Get_Program_Lumpsum" output="false" returntype="query">
		<cfargument name="billback_Id" type="string" required="true">
<cfquery name="qGet_Program_Lumpsum" datasource="#application.datasource#">
	SELECT     	Billback_Program_Lumpsum_Component.Billback_Program_ID,
				ISNULL(SUM(CAST(Amount AS FLOAT)),0) Total_Program_Lumpsum_Amount,
				ISNull(LS_Billback_Amount, 0) AS Billback,
				ISNull(BB_Lump_Sums.LS_Expected_Amount, 0) AS Expected,
				ISNull(LS_Paid_Amount, 0) AS Approved
	FROM       Billback_Program_Lumpsum_Component
				LEFT JOIN BB_Lump_Sums
				ON
				(
					(BB_Lump_Sums.Billback_Program_ID = Billback_Program_Lumpsum_Component.Billback_Program_ID)
				)
	WHERE 
			(Billback_Program_Lumpsum_Component.Amount IS NOT NULL)
			AND
			(LEN(Billback_Program_Lumpsum_Component.Amount) > 0)
			AND
			(ISNUMERIC(Billback_Program_Lumpsum_Component.Amount) = 1)
			<!---AND
			(CAST(LTRIM(Billback_Program_Lumpsum_Component.Amount) AS Float) > 0)--->
			AND
			Billback_Program_Lumpsum_Component.Billback_ID 		= <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="cf_sql_idstamp">
			AND
			Billback_Program_Lumpsum_Component.Deleted 			= 0
	GROUP BY Billback_Program_Lumpsum_Component.Billback_Program_ID, BB_Lump_Sums.Lump_Sum_Deviation
			, BB_Lump_Sums.LS_Expected_Amount, LS_Billback_Amount, LS_Paid_Amount
	ORDER BY Billback_Program_Lumpsum_Component.Billback_Program_ID
</CFQUERY>
<cfreturn qGet_Program_Lumpsum />
</cffunction>

<!---- Get individual lump sums --->
<cffunction name="Get_All_Program_Lumpsum" output="false" returntype="query">
	<cfargument name="billback_Id" type="string" required="true">
<cfquery name="qGet_All_Program_Lumpsum" datasource="#application.datasource#">
	SELECT     	Billback_Program_Lumpsum_Component_ID,
				Billback_Program_Lumpsum_Component.Billback_Program_ID,
				ISNULL(CAST(Amount AS FLOAT),0) As Amount,
				ISNull(LS_Billback_Amount, 0) AS Billback,
				ISNull((BB_Lump_Sums.LS_Expected_Amount * (Amount/LS_Billback_Amount)), 0) AS Expected,
				ISNull((LS_Paid_Amount * (Amount/LS_Billback_Amount)), 0) AS Approved
	FROM       Billback_Program_Lumpsum_Component
				LEFT JOIN BB_Lump_Sums
				ON
				(
					(BB_Lump_Sums.Billback_Program_ID = Billback_Program_Lumpsum_Component.Billback_Program_ID)
				)
	WHERE 
			(Billback_Program_Lumpsum_Component.Amount IS NOT NULL)
			AND
			(LEN(Billback_Program_Lumpsum_Component.Amount) > 0)
			AND
			(ISNUMERIC(Billback_Program_Lumpsum_Component.Amount) = 1)
			<!---AND
			(CAST(LTRIM(Billback_Program_Lumpsum_Component.Amount) AS Float) > 0)--->
			AND
			Billback_Program_Lumpsum_Component.Billback_ID 		= <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="cf_sql_idstamp">
			AND
			Billback_Program_Lumpsum_Component.Deleted 			= 0
	ORDER BY Billback_Program_Lumpsum_Component.Billback_Program_ID
</CFQUERY>
<cfreturn qGet_All_Program_Lumpsum />
</cffunction>
	
	<!---------------------- Get All Growth ----------------------------->
<cffunction name="Get_Program_Growth" output="false" returntype="query">
<cfargument name="billback_Id" type="string" required="true">
<CFQUERY  dataSource="#application.datasource#" NAME="qGet_Program_Growth">
	SELECT	SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT)) AS Total_Growth, 
			Billback_Program.Billback_Program_ID,			
			ISNull(Expected_Amount, 0) AS Expected_Amount,
			ISNull(BB_Growth_Amount, 0) AS BB_Growth_Amount,	
			ISNull(Paid_Amount, 0) AS BB_Approved_Amount
	FROM	
			Billback
			INNER JOIN Billback_Program
			ON
			(
				(Billback_Program.Billback_ID = Billback.Billback_ID)
				AND
				(Billback_Program.Deleted = 0)
			)			
			INNER JOIN 	Billback_product
			ON
			(	(Billback_Product.Billback_ID = '#Billback_ID#')
				AND
				(Billback_product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
				AND
				(Billback_product.Deleted = 0)
			)
			INNER JOIN Billback_Product_Detail
			ON
			(	(Billback_Product_Detail.Billback_ID = '#Billback_ID#')
				AND
				(Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID)
				AND
				(Billback_Product_Detail.Deleted = 0)
				AND
				(Billback_Product_Detail.BB_Rate IS NOT NULL)
				AND
				(LEN(Billback_Product_Detail.BB_Rate) > 0)
				AND
				(ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1)
				AND
				(CAST(Billback_Product_Detail.BB_Rate AS Float) > 0)
				AND
				(Billback_Product_Detail.BB_Product_Type_ID = 4)
			)
			LEFT JOIN BB_Growth_Program
			ON
			(
				(BB_Growth_Program.Billback_Program_ID = Billback_Program.Billback_Program_ID)
				AND
				(BB_Growth_Program.Deleted = 0)
			)			
		WHERE
			Billback.Billback_ID = '#Billback_ID#'				
		GROUP BY Billback_Program.Billback_Program_ID, BB_Growth_Program.Deviated_Amount
					, Expected_Amount, BB_Growth_Amount, Paid_Amount
</CFQUERY>
	<cfreturn qGet_Program_Growth />
	</cffunction>
	
	<cffunction name="getGenericType" access="public" output="false" returntype="string">
		<cfargument name="Program_id" default="0" type="numeric">
		<cfquery name="qGetGenericType" datasource="#application.datasource#">
			SELECT	Generic_Type
			FROM	Program_Control_Panel_Options
			WHERE	ProgramControl_Panel_Options_ID = 
					(
						SELECT 	ProgramType_ID
						FROM	Contract_Main
						WHERE	Contract_Main_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.program_id#" />
					)
	</cfquery>
		<cfreturn qGetGenericType.Generic_Type />
	</cffunction>
	
	<!--- getter --->
	<cffunction name="getPayeeType" access="public" output="false" returntype="numeric">
		<cfreturn variables.payeeType />
	</cffunction>
	<cffunction name="getPayeeInfo" access="public" output="false" returntype="query">
		<cfreturn variables.payeeInfo />
	</cffunction>
	<cffunction name="getHasOperatorAsscoiateDistributor" access="public" output="false" returntype="boolean">
		<cfreturn variables.hasOperatorAsscoiateDistributor />
	</cffunction>
	<cffunction name="getHasDistAsscoiateOperator" access="public" output="false" returntype="boolean">
		<cfreturn variables.hasDistAsscoiateOperator />
	</cffunction>
	<!--- setter --->
	<cffunction name="setPayeeType" access="package" output="false" returntype="void">
		<cfargument name="payeeType" type="numeric" required="true">
		<cfset variables.payeeType = arguments.payeeType />
	</cffunction>
	<cffunction name="setPayeeInfo" access="package" output="false" returntype="void">
		<cfargument name="payeeInfo" type="query" required="true">
		<cfset variables.payeeInfo = arguments.payeeInfo />
	</cffunction>
	<cffunction name="setHasOperatorAsscoiateDistributor" access="package" output="false" returntype="void">
		<cfargument name="hasOperatorAsscoiateDistributor" type="boolean" required="true">
		<cfset variables.hasOperatorAsscoiateDistributor = arguments.hasOperatorAsscoiateDistributor />
	</cffunction>
	<cffunction name="setHasDistAsscoiateOperator" access="package" output="false" returntype="void">
		<cfargument name="hasDistAsscoiateOperator" type="boolean" required="true">
		<cfset variables.hasDistAsscoiateOperator = arguments.hasDistAsscoiateOperator />
	</cffunction>	
	<!--- method --->
	
	<cffunction name="getBillbackAutoApproval" output="false" returntype="boolean">
		<cfargument name="billbackId" type="string" required="true">
		<cfargument name="billbackAmount" type="numeric" required="true">
		<cfargument name="billbackStatus" type="numeric" required="true">
		<cfargument name="billbackPayeeTypeId" type="numeric" required="true">
		<cfargument name="billbackAge" type="numeric" required="true">
		<cfargument name="billbackReference" type="string" required="true">
		
		<cfset var qAutoApprovalSetting = "" />
		<cfset var AutoCloseAmount = 0 />
		<cfset var SelectBillbackDistributor = "" />
		<cfset var GetAutoCloseForDistributor = "" />
		<cfset var qGetDivestedItems = "" />
		<cfset var qGetUnknownItems = "" />
		<cfset var qCheckAllBB = "" />
		<cfset var returnValue = 0 />
		<!---61486 : Default program only when $'s equal to $0.00 START --->
		<cfset HasDefaultProgram = DummyProgram(arguments.billbackId)>
		<!---ONLY AUTO APPROVE A BILLBACK WITH DUMMY PROGRAM WHEN CLAIMED AMOUNT = 0 --->
		<!---DUMMY PROGRAM IF START--->
		<cfif HasDefaultProgram>
			<cfquery name="BillbackClaimed" datasource="#application.datasource#">
				Select * 
				from 	Billback
				where 	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billbackId#">
				and 		BB_amount = '0'
			</cfquery>
			<cfif BillbackClaimed.recordcount EQ 0>
				<cfset returnValue = 0 />
			</cfif>
			
		<cfelse>		
		 <!---61486 : Default program only when $'s equal to $0.00 END --->
		<CFQUERY NAME="qAutoApprovalSetting" DATASOURCE="#Application.Datasource#">
			SELECT 	Auto_Approve_Amount, Auto_Approve_On, Auto_Approve_BB_Types,
					Auto_Appr_Consider_Created_Date, Auto_Appr_Age,
					Auto_Appr_Divested_Items, Auto_Appr_Unknown_Items, Auto_Appr_Reference_Exclusive,
					Auto_Appr_Payee_Operator, Auto_Appr_Payee_Distributor
			FROM 	Billback_Settings
		</CFQUERY>
		<cfif 	arguments.billbackStatus LTE 2 
				AND qAutoApprovalSetting.Auto_Approve_On EQ 1 
				AND (qAutoApprovalSetting.Auto_Approve_BB_Types EQ 2 OR qAutoApprovalSetting.Auto_Approve_BB_Types EQ 3)
				AND (qAutoApprovalSetting.Auto_Appr_Consider_Created_Date EQ 0 OR arguments.billbackAge GT qAutoApprovalSetting.Auto_Appr_Age)
				AND NOT (qAutoApprovalSetting.Auto_Appr_Payee_Distributor EQ 0 AND arguments.billbackPayeeTypeId EQ 1)
				AND NOT (qAutoApprovalSetting.Auto_Appr_Payee_Operator EQ 0 AND arguments.billbackPayeeTypeId EQ 2)
					>
					
			<cfset AutoCloseAmount = qAutoApprovalSetting.Auto_Approve_Amount />
			<cfif arguments.billbackPayeeTypeId EQ 1>
				<cfquery name="SelectBillbackDistributor" datasource="#application.datasource#">
					SELECT 	Distributor_ID 
					FROM 	Billback_Distributor
					WHERE 	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billbackId#">
					AND 	Deleted = 0
				</cfquery>
				
				<cfif SelectBillbackDistributor.Recordcount GT 0>
					<cfquery name="GetAutoCloseForDistributor" datasource="#application.datasource#">
						SELECT 	Auto_Close_Amount AS Payee_Auto_Close_Amount
						FROM 	BB_Auto_Close_Exception
						WHERE 	Distributor_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SelectBillbackDistributor.Distributor_ID#">
						AND 	Deleted = 0
					</cfquery>
				
					<cfif GetAutoCloseForDistributor.recordcount GT 0>
						<cfset AutoCloseAmount = GetAutoCloseForDistributor.Payee_Auto_Close_Amount>
					</cfif>
				</cfif>
			</cfif>
			
			<cfif arguments.billbackAmount LTE AutoCloseAmount>
				
				<cfset returnValue = 1 />
				
				<!--- check divested items - start --->
				<cfif qAutoApprovalSetting.Auto_Appr_Divested_Items EQ 0>
					<cfquery name="qGetDivestedItems" datasource="#application.datasource#">
						SELECT 	top 1 Product_ID
						FROM 	Billback_Product
						INNER JOIN BSA_Foodservice_Items_Master
						ON		BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID
						AND		BSA_Foodservice_Items_Master.Is_Divested = 1
						WHERE 	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billbackId#">
						AND 	Billback_Product.Deleted = 0
					</cfquery>
					
					<cfif qGetDivestedItems.recordCount>
						<cfset returnValue = 0 />
					</cfif>
				</cfif>
				<!--- check divested items - end --->
				
				<!--- check unknown items - start --->
				<cfif qAutoApprovalSetting.Auto_Appr_Unknown_Items EQ 0 AND returnValue EQ 1>
					<cfquery name="qGetUnknownItems" datasource="#application.datasource#">
						SELECT 	top 1 Product_ID
						FROM 	Billback_Product
						WHERE 	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billbackId#">
						AND 	Billback_Product.Deleted = 0
						AND		Billback_Product.Product_ID IS NULL
					</cfquery>
					
					<cfif qGetUnknownItems.recordCount>
						<cfset returnValue = 0 />
					</cfif>
				</cfif>
				<!--- check unknown items - end --->
				
				<!--- check refrence ## - start --->
				<cfif qAutoApprovalSetting.Auto_Appr_Reference_Exclusive EQ 1 AND returnValue EQ 1>
					<cfquery name="qCheckAllBB" datasource="#application.datasource#">
						SELECT	SUM(
								CASE WHEN Billback.Billback_Status_ID >= 3 THEN ISNULL(BB_Approved.Paid_Amount, 0)
								ELSE Billback.BB_Amount
								END
								) as Total_Billback_Amount
						FROM	Billback						
						LEFT JOIN BB_Approved
						ON	BB_Approved.Billback_ID = Billback.Billback_ID
						AND	Billback.Billback_Status_ID >= 3 -- Approved
						WHERE	Billback.BB_Reference = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billbackReference#">
						AND		Billback.Deleted = 0
					</cfquery>
					
					<cfif qCheckAllBB.Total_Billback_Amount GT AutoCloseAmount>
						<cfset returnValue = 0 />
					</cfif>
				</cfif>
				<!--- check refrence ## - end --->
				
				<!--- check payee exception - start --->
				<cfif returnValue EQ 1>
					<cfif arguments.billbackPayeeTypeId EQ 1>
						<cfquery name="qCheckDistributorException" datasource="#application.datasource#">
							SELECT 	Distributor_ID 
							FROM 	Billback_Distributor
							WHERE 	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billbackId#">
							AND 	Deleted = 0
							AND		Distributor_ID NOT IN (SELECT Distributor_ID FROM Auto_Appr_Payee_Exception WHERE Payee_Type = 1)
						</cfquery>
						
						<cfif NOT qCheckDistributorException.recordCount>
							<cfset returnValue = 0 />
						</cfif>
						
					<cfelseif arguments.billbackPayeeTypeId EQ 2>
						<cfquery name="qCheckOperatorException" datasource="#application.datasource#">
							SELECT 	Operator_ID
							FROM 	Billback_Operator
							WHERE 	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billbackId#">
							AND 	Deleted = 0
							AND		Operator_ID NOT IN (SELECT Operator_ID FROM Auto_Appr_Payee_Exception WHERE Payee_Type = 2)
						</cfquery>
						
						<cfif NOT qCheckOperatorException.recordCount>
							<cfset returnValue = 0 />
						</cfif>
					<cfelse>
						<cfset returnValue = 0 />
					</cfif>
				</cfif>
				<!--- check payee exception - end --->
				
			</cfif> <!--- arguments.billbackAmount LTE AutoCloseAmount --->
		</cfif>
	</cfif>			<!---DUMMY PROGRAM IF END--->
		
		<cfreturn returnValue />
	</cffunction>
<!---61486 : Default program only when $'s equal to $0.00 START --->
	<cffunction name="DummyProgram" output="false" returntype="boolean">
		<cfargument name="billback_Id" type="string" required="true">
		
		<cfset var hasDummy = 0 />
		<cfquery name="GetBillbackSettings" datasource="#application.datasource#">
			SELECT Default_Program
			FROM Billback_Settings
		</cfquery>	
		<cfif len(trim(GetBillbackSettings.Default_Program)) GT 0>
			<cfquery name="GetDummyContractNumber" datasource="#application.datasource#">
				SELECT Contract_Number 
				FROM Contract_Main 
				WHERE Contract_Main_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#GetBillbackSettings.Default_Program#" />
			</cfquery>
			
			<cfquery name="IsDefaultProgramOnBillback" datasource="#application.datasource#">
				SELECT * FROM  Billback_Program
				INNER JOIN Contract_Main CM
				ON 	CM.Contract_Main_ID = Billback_Program.Program_ID
				AND CM.Contract_Number = '#GetDummyContractNumber.Contract_Number#'
				WHERE Billback_Program.Billback_ID = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="cf_sql_idstamp">
				AND Billback_Program.Deleted = 0
			</cfquery>
		
			<cfif IsDefaultProgramOnBillback.recordCount>
				<cfset hasDummy = 1>
			</cfif>
		</cfif>
		<cfreturn hasDummy/>
		
	</cffunction>
<!---61486 : Default program only when $'s equal to $0.00 END --->	

<!--- 77204 :: A Distributor/Market/Operator can now be associated to multiple analysts START --->
	<cffunction name="ProgramApprovalRights" output="false" returntype="boolean">
		<cfargument name="billback_Id" type="string" required="true">
		<cfargument name="user_id" type="string" required="true">

		<cfset canApproveProgramTemplate = 0 />
		
			<cfquery name="checkAccess" datasource="#application.datasource#">
				SELECT 1 
				FROM Billback B 
				INNER JOIN Billback_Program BP
				ON BP.Billback_ID = B.Billback_ID
				INNER JOIN Contract_Main CM
				ON CM.Contract_Main_ID = BP.Program_ID
				INNER JOIN Program_Control_Panel_Options PCPO
				ON PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
				INNER JOIN BB_ApproveBy_Template BPT
				ON BPT.First_Parent_ID = PCPO.First_Parent_ID
				WHERE B.Billback_ID =  <cfqueryparam value="#arguments.billback_Id#" cfsqltype="cf_sql_varchar">
				AND BPT.User_ID = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">
			</cfquery>
		
			<cfif checkAccess.recordCount>
				<cfset canApproveProgramTemplate = 1>
			</cfif>

		<cfreturn canApproveProgramTemplate/>
		
	</cffunction>
<!--- 77204 :: A Distributor/Market/Operator can now be associated to multiple analysts END --->
</cfcomponent>
