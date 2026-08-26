<!----------------------------------------------------------------------------------
Name         :  PlannerProgramManager
Copyright    :  (c) 2016 Blacksmith Applications, Inc.
Created Date :  06/13/2016
Created By   :  Tim Ford
Description  :  Manager for Planner Program
---------------------------------------------------------------------------------->

<cfcomponent name="PlannerProgramManager" displayname="PlannerProgramManager" hint="Manager for Planner Program">

	<cffunction name="getProgramPlannerData" output="false">

		<cfargument name="id" type="any" required="true" />

		<cfscript>
			//set local variables
			var nId = 0;
			var qReturnData = "";

			//assign local variables
			nId = arguments.id;

		</cfscript>

		<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT 	Contract_Main.*, tps.*, cst.Contract_Status_Type_Desc as contract_status,  ISNULL(pcpo.EZ_Contract_Id, 0) as EZ_Contract_Id, ISNULL(pcpo.EZButton_On, 0) as EZButton_On,
					pcpo.EzButton_Default_Show_Item_Rates, pcpo.EzButton_Auto_Approve_On, pcpo.EzButton_Enter_Beyond_Max_Rates, pcpo.EzButton_Max_Rate_Consider, pcpo.Default_rate_equal_to_zero,
					pcpo.Filter_EZButton_Products, pcpo.Discount_Rebate_Max_Rate_On, pcpo.Planner_Program_Alternate_Customer_ON
			FROM	Contract_Main
					INNER JOIN Program_Control_Panel_Options pcpo on pcpo.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
					INNER JOIN Template_Planner_Settings tps on tps.First_Parent_Id = pcpo.First_Parent_ID
					INNER JOIN Contract_Status_Types cst on cst.Contract_Status_Type_ID = Contract_Main.Contract_Status_Type_IDX
			WHERE	Contract_Main_ID = '#nId#'
		</cfquery>

		<cfset qReturnData = qGetData />

		<cfreturn qReturnData />

	</cffunction>

	<cffunction name="getProgramPlannerProductData" output="false">

		<cfargument name="id" type="any" required="true" />

		<cfscript>
			//set local variables
			var nId = 0;
			var qReturnData = "";

			//assign local variables
			nId = arguments.id;

		</cfscript>

		<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT 	DISTINCT cm.Contract_Main_ID, im.Item, im.BSA_Foodservice_Items_Master_ID
			FROM	Contract_Main cm
					inner join Contract_Products cp on cp.Contract_Main_ID = cm.Contract_Main_ID and cp.Deleted = 0
					and(
							(cp.Product_Group_ID = CAST(cp.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND cp.Is_Group = 1)
							OR
							(ISNULL(cp.Product_Group_ID, '') = '' AND cp.Is_Group = 0)
						)
					inner join BSA_Foodservice_Items_Master im on im.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
			WHERE	cm.Contract_Main_ID = '#nId#'
			and		cm.Deleted = 0
		</cfquery>

		<cfset qReturnData = qGetData />

		<cfreturn qReturnData />

	</cffunction>

	<cffunction name="getProgramPlannerFixedData" output="false">

		<cfargument name="id" type="any" required="true" />

		<cfscript>
			//set local variables
			var nId = 0;
			var qReturnData = "";

			//assign local variables
			nId = arguments.id;

		</cfscript>

		<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT 	DISTINCT cm.Contract_Main_ID, cp.Product_Type_ID, im.Item, im.BSA_Foodservice_Items_Master_ID,
					pfc.Fixed_Component_Paid_to as Component_Paid_To,
					pfc.Program_Fixed_Component_Name_ID as compNameId,
					pfc.Claim_Mechanics as Claim_Mechanics,
					case when ISNULL(pfpd.User_picked_UOM, 0) IN (5, 6, 7) then pfpd.User_Picked_Fixed_Price else pfpd.Fixed_Price_Value end as rate,
					case when ISNULL(pfpd.User_picked_UOM, 0) IN (5, 6, 7) then pfpd.User_picked_UOM else pfpd.Unit_Of_Measure_Id end as uom,
					ppc.Payment_Cycle_ID as PaymentCycle,
					pfc.GL_Account_ID,
					pfc.Vendor_Master_ID,
					pfc.Vendor_Selection,
					pfc.Payee_Type as Payee_Selection
			FROM	Contract_Main cm
					inner join Contract_Products cp on cp.Contract_Main_ID = cm.Contract_Main_ID and cp.Deleted = 0 AND cp.Product_Type_ID = 1
					and(
							(cp.Product_Group_ID = CAST(cp.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND cp.Is_Group = 1)
							OR
							(ISNULL(cp.Product_Group_ID, '') = '' AND cp.Is_Group = 0)
						)
					inner join BSA_Foodservice_Items_Master im on im.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
					inner join Program_Fixed_Component pfc on pfc.Program_ID = cm.Contract_Main_ID and pfc.Deleted = 0
					inner join Program_Fixed_Component_Name pfcn on pfcn.Program_Fixed_Component_Name_ID = pfc.Program_Fixed_Component_Name_ID
					inner join Program_Fixed_Price_Product_Data pfpd on pfpd.Contract_Products_ID = cp.Contract_Products_ID and pfpd.Deleted = 0 and pfpd.Program_Fixed_Component_ID = pfc.Program_Fixed_Component_ID
					left join Program_Payment_Cycle ppc on ppc.Program_ID = cm.Contract_Main_ID and ppc.Deleted = 0 and ppc.Discount_Type_ID = 1 and ppc.Component_ID = pfc.Program_Fixed_Component_ID
			WHERE	cm.Contract_Main_ID = '#nId#'
			and		cm.Deleted = 0
		</cfquery>

		<cfset qReturnData = qGetData />

		<cfreturn qReturnData />

	</cffunction>


	<cffunction name="getProgramPlannerRebateData" output="false">

		<cfargument name="id" type="any" required="true" />
		<cfargument name="compId" 			type="any" required="false" default=""  />
		<cfargument name="itemMastderId" 	type="any" required="false" default=""  />

		<cfscript>
			//set local variables
			var nId = 0;
			var qReturnData = "";
			var strCompId = "";
			var strItemMasterId = "";

			//assign local variables
			nId = arguments.id;
			strCompId = arguments.compId;
			strItemMasterId = arguments.itemMastderId;

		</cfscript>

		<cfquery name="qGetData" datasource="#application.datasource#">

			SELECT 	DISTINCT cm.Contract_Main_ID, cp.Product_Type_ID, im.Item, im.BSA_Foodservice_Items_Master_ID,
					prc.Component_Paid_To as Component_Paid_To,
					prc.Program_Rebates_Component_Name_ID as compNameId,
					prc.Claim_Mechanics,
                    CASE
                        WHEN Cp.Is_Group = 1
                            THEN CASE
                                    WHEN ISNULL(Prcd.User_picked_UOM, 0) = 6    /* CWT */
                                        THEN (Cast(Prcd.Rate AS DECIMAL(10, 4)) * 100.00) / CASE Prcd.Unit_Of_Measure_ID
                                                WHEN 2
                                                    THEN 1
                                                ELSE CAST(Im.Net_Weight as DECIMAL(10,4))
                                                END
                                    ELSE Prcd.Rate
                                    END
                        ELSE CASE
                                WHEN ISNULL(Prcd.User_picked_UOM, 0) = 5
                                    THEN (Cast(Prcd.Rate AS DECIMAL(10, 4)) / CAST(ISNULL(ISNULL(NULLIF(NUCT.Case_Count, ''), CAST(Im.Case_Count AS DECIMAL(10, 0))), 1) AS INT))
                                            /   CASE Prcd.Unit_Of_Measure_ID
                                                    WHEN 2
                                                        THEN CAST(Im.Net_Weight as DECIMAL(10,4))
                                                    ELSE 1
                                                END
                                WHEN ISNULL(Prcd.User_picked_UOM, 0) = 6     /* CWT */
                                    THEN (Cast(Prcd.Rate AS DECIMAL(10, 4)) * 100.00)
                                            /   CASE Prcd.Unit_Of_Measure_ID
                                                    WHEN 2
                                                        THEN 1
                                                    ELSE CAST(Im.Net_Weight as DECIMAL(10,4))
                                                END
                                WHEN ISNULL(Prcd.User_picked_UOM, 0) = 7
                                    THEN (Prcd.Rate / Cast(ISNULL(Im.Sleeves_per_case, 1) AS DECIMAL(18, 4)))
                                        /   CASE Prcd.Unit_Of_Measure_ID
                                                WHEN 2
                                                    THEN CAST(Im.Net_Weight as DECIMAL(10,4))
                                                ELSE 1
                                            END
                                ELSE Prcd.Rate
                            END
                    END AS Rate,
					case when ISNULL(prcd.User_picked_UOM, 0) IN (5, 6, 7) then prcd.User_picked_UOM else prcd.Unit_Of_Measure_ID end as uom,
					ppc.Payment_Cycle_ID as PaymentCycle,
					prc.GL_Account_ID,
					prc.Vendor_Master_ID,
					prc.Vendor_Selection,
					prc.Payee_Type as Payee_Selection,
                    CAST(prcd.Scan_Percentage AS INT) AS Scan_Percentage
			FROM	Contract_Main cm
					inner join Contract_Products cp on cp.Contract_Main_ID = cm.Contract_Main_ID and cp.Deleted = 0 AND cp.Product_Type_ID = 2
					and(
							(cp.Product_Group_ID = CAST(cp.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND cp.Is_Group = 1)
							OR
							(ISNULL(cp.Product_Group_ID, '') = '' AND cp.Is_Group = 0)
						)
					inner join BSA_Foodservice_Items_Master im on im.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
					inner join Program_Rebates_Component prc on prc.Program_ID = cm.Contract_Main_ID and prc.Deleted = 0
					inner join Program_Rebates_Product_Data prpd on prpd.Contract_Products_ID = cp.Contract_Products_ID and prpd.Deleted = 0
					inner join Program_Rebates_Component_Data prcd on prcd.Program_Rebates_Component_ID = prc.Program_Rebates_Component_ID
					and prcd.Program_Rebates_Product_Data_ID = prpd.Program_Rebates_Product_Data_ID and prcd.Deleted = 0
					left join Program_Payment_Cycle ppc on ppc.Program_ID = cm.Contract_Main_ID and ppc.Deleted = 0 and ppc.Discount_Type_ID = 2 and ppc.Component_ID = prc.Program_Rebates_Component_ID
					LEFT JOIN NUC_Targets NUCT ON NUCT.Product_Group_ID = im.BSA_Foodservice_Items_Master_ID  AND NUCT.Deleted = 0
			WHERE	cm.Contract_Main_ID = '#nId#'
			and		cm.Deleted = 0
			<cfif trim(strCompId) neq "">
			and		prc.Program_Rebates_Component_Name_ID = '#strCompId#'
			</cfif>
			<cfif trim(strItemMasterId) neq "">
			and		im.BSA_Foodservice_Items_Master_ID = '#strItemMasterId#'
			</cfif>

		</cfquery>

		<cfset qReturnData = qGetData />

		<cfreturn qReturnData />

	</cffunction>


	<cffunction name="getProgramPlannerLumpSumData" output="false">

		<cfargument name="id" 				type="any" required="true" />
		<cfargument name="compId" 			type="any" required="false" default=""  />
		<cfargument name="itemMastderId" 	type="any" required="false" default=""  />

		<cfscript>
			//set local variables
			var nId = 0;
			var qReturnData = "";
			var strCompId = "";
			var strItemMasterId = "";

			//assign local variables
			nId = arguments.id;
			strCompId = arguments.compId;
			strItemMasterId = arguments.itemMastderId;

		</cfscript>

		<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT 	DISTINCT cm.Contract_Main_ID, cp.Product_Type_ID, im.Item, im.BSA_Foodservice_Items_Master_ID,
					Component_Paid_To as Component_Paid_To,
					pls.Program_Lump_Sum_Name_ID as compNameId,
					pls.Claim_Mechanics,
					pls.Lump_Sum_Amount as Rate,
                    0 as uom,
					pls.Component_Paid_To as PaymentCycle,
					pls.GL_Account_ID,
					pls.Vendor_Master_ID,
					'' as Vendor_Selection,
					pls.Product_Option,
					'' as Payee_Selection
			FROM	Contract_Main cm
					inner join Contract_Products cp on cp.Contract_Main_ID = cm.Contract_Main_ID and cp.Deleted = 0 AND cp.Product_Type_ID = 3
					and(
							(cp.Product_Group_ID = CAST(cp.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND cp.Is_Group = 1)
							OR
							(ISNULL(cp.Product_Group_ID, '') = '' AND cp.Is_Group = 0)
						)
					inner join BSA_Foodservice_Items_Master im on im.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
					inner join Program_Lump_Sums pls on pls.Program_ID = cm.Contract_Main_ID and pls.Deleted = 0
					inner join Program_Lump_Sum_Product_Data plspd on plspd.Contract_Products_ID = cp.Contract_Products_ID and plspd.Deleted = 0
					and plspd.Program_Lump_Sum_ID = pls.Program_Lump_Sum_ID
					left join Program_Payment_Cycle ppc on ppc.Program_ID = cm.Contract_Main_ID and ppc.Deleted = 0 and ppc.Discount_Type_ID = 3 and ppc.Component_ID = pls.Program_Lump_Sum_ID
			WHERE	cm.Contract_Main_ID = '#nId#'
			and		cm.Deleted = 0
			<cfif trim(strCompId) neq "">
			and		pls.Program_Lump_Sum_Name_ID = '#strCompId#'
			</cfif>
			<cfif trim(strItemMasterId) neq "">
			and		im.BSA_Foodservice_Items_Master_ID = '#strItemMasterId#'
			</cfif>
		</cfquery>

		<cfset qReturnData = qGetData />

		<cfreturn qReturnData />

	</cffunction>

	<cffunction name="saveProgramPlannerData" output="true">

		<cfargument name="data" required="true" type="struct" />

		<cfscript>
			//set local variables
			var stData 						= structNew();
			var rId     					= 0;
			var bIsGroup					= 0;
			var bIsEDLP						= 0;
			var bIsNewPrg					= 0;
			var nBusinessSegmentID			= 0;
			var bDistIsGroup 				= 0;
			var nDistributorGroupLevelID	= 0;
			var bIsRevision					= 0;
			var bIsCopy						= 0;
			var nProduct_List_Type			= 0;
			var nParentContractMainID		= 0;

            param stDta.currency = 1;

			//assign local variables
			stData = arguments.data;

			//if Product_List_Type is not "", 0 or 9 then it's a group
			/*
			if(stData.Product_List_Type neq "" && stData.Product_List_Type neq 0 && stData.Product_List_Type neq 9){
				bIsGroup = 1;
			}
			*/

			if(checkIfGroupItems(stData.Product_List)){
				bIsGroup = 1;
				nProduct_List_Type = stData.Product_List_Type;
			}

			objBusinessSegment = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager");

		</cfscript>

		<cfquery name="qGetPlanner"  datasource="#application.datasource#">
			SELECT	Planners.Creator_Position_ID, Planners.RSP_ID, Planner_Template.Business_Segment_ID
			FROM	Planner_Template
					INNER JOIN Planners on Planners.Planner_Template_ID = Planner_Template.Planner_Template_ID
					AND Planners.Deleted = 0
					AND Planners.Planner_ID = '#stData.plannerId#'
			WHERE	Planner_Template.Deleted = 0
		</cfquery>

		<cfif NOT isDefined("stData.Responsible_User_Id_Position_Id") OR stData.Responsible_User_Id_Position_Id IS "NULL" OR ListLast(stData.Responsible_User_Id_Position_Id, "_") IS "NULL">
			<cfset This_User_Positions_ID = qGetPlanner.Creator_Position_ID>
			<cfset stData.Responsible_User_Id_Position_Id = "#This_User_Positions_ID#_#qGetPlanner.RSP_ID#">
		</cfif>

		<cfset This_User_Position_ID = ListFirst(stData.Responsible_User_Id_Position_Id, "_")>
		<cfset stData.Responsible_User_Id = ListLast(stData.Responsible_User_Id_Position_Id, "_")>

		<cfset This_User_Position_ID = ListFirst(stData.Responsible_User_Id_Position_Id, "_")>

		<!--- set local flag to handle for revision --->
		<cfparam name="stData.bRevise" default="0" />
		<cfset bIsRevision = stData.bRevise />

		<!--- set local flag to handle for copy --->
		<cfparam name="stData.bCopy" default="0" />
		<cfset bIsCopy = stData.bCopy />

		<!---- value of parent program id that is being copied or revised--->
		<cfparam name="stData.programIdCopyRevise" default="0" />

		<!--- RETAIL-359  Copy from program menu changes: Call USP_Copy_Program to remove inactive items --->
		<cfif bIsCopy eq 1>

			<CFSTOREDPROC PROCEDURE="USP_Copy_Program" datasource="#application.datasource#">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER "	DBVARNAME="@Program_ID_To_Replicate"		VALUE="#stData.programIdCopyRevise#">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_VARCHAR "	DBVARNAME="@New_Contract_Number"			VALUE="#stData.Contract_Number#">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@IsRevisionOfExistingContract"	VALUE="0">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@ISROLLOVER"						VALUE="0">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@ForceFreightOnAutoCopy"			VALUE="0">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@User_Position_ID"				VALUE="0" null="true">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_VARCHAR"	DBVARNAME="@Responsible_User_ID"			VALUE="" null="true">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_VARCHAR"	DBVARNAME="@Current_User_ID"				VALUE="#request.AccessStructure.User_ID#">
				<CFPROCPARAM TYPE="Out"	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@Contract_Main_ID"				VARIABLE="Renewed_Program_ID">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@Is_Mass_Copy"					VALUE="0">
				<CFPROCPARAM TYPE="Out"	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@Is_Group_Deal"					VARIABLE="Is_Group_Deal">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@From_EZ_Template"				VALUE="0">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@Is_AutoRenew"					VALUE="0">
			</CFSTOREDPROC>

		</cfif>

		<cfquery name="qCheckProgramNumber" datasource="#application.datasource#">
			SELECT 	TOP 1 Contract_Main_ID, Delivery_Start_Date, Delivery_End_Date
			FROM	Contract_Main
			WHERE	Contract_Number = <cfqueryparam value="#stData.Contract_Number#" cfsqltype="CF_SQL_VARCHAR">
			ORDER BY Contract_Main_ID DESC
		</cfquery>

		<cfset bIsEDLP = isEDLP(stData.Planner_Perf_Types_ID) />
        <cfset stData.programId   = qCheckProgramNumber.Contract_Main_ID>
		<cfset nBusinessSegmentID = form.Business_Segment_ID />
        <!--- If segment is enabled, but segment drop down is not displayed - then get segment from planner template --->
        <cfif objBusinessSegment.isEnabled() and application.appsettingsget.getFilterBusinessSegments()
              and form.Business_Segment_ID eq "0" and application.util.query.get_setting("Display_Segment_Planner_Program", 0) neq "1">
            <cfset nBusinessSegmentID = qGetPlanner.Business_Segment_ID />
        </cfif>


		<!--- Contract_Main START--->
		<cfif qCheckProgramNumber.recordCount and bIsRevision eq 0>
			<cfset New_Contract_Main_ID = qCheckProgramNumber.Contract_Main_ID />
			<cfif (form.AltCustomers EQ "1")>
				<cfset useLakebaseForchkAlternateCustomer = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors")>
<cfif useLakebaseForchkAlternateCustomer>
	<cftry>
		<cfset chkAlternateCustomer = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_distributors", {
				"contract_main_id" = "eq.#New_Contract_Main_ID#",
				"alternate_customer_flag" = "eq.1",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForchkAlternateCustomer = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForchkAlternateCustomer>
<cfquery name="chkAlternateCustomer" datasource="#application.datasource#">
					SELECT 	*
					FROM 	Contract_Distributors
					WHERE 	Contract_Main_ID = '#New_Contract_Main_ID#' AND
							Alternate_Customer_Flag = 1 AND
							Deleted = 0
				</cfquery>
</cfif>
				<cfif (isDefined("chkAlternateCustomer") AND chkAlternateCustomer.RecordCount EQ 0)>
						<cfset form.AltCustomers = 0 />
				</cfif>
			<cfelse>
				<cfset useLakebaseForqDelAllDists = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors")>
<cfif useLakebaseForqDelAllDists>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_distributors",
			{
				"contract_main_id" = "eq.#New_Contract_Main_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqDelAllDists = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDelAllDists>
<cfquery name="qDelAllDists" datasource="#application.datasource#">
					UPDATE Contract_Distributors SET Deleted = 1 WHERE Contract_Main_ID = '#New_Contract_Main_ID#'
				</cfquery>
</cfif>
			</cfif>

			<cfquery name="qUpdate" datasource="#application.datasource#">
				UPDATE	Contract_Main
				SET		Planner_Id             = '#stData.plannerId#',
						Contract_Title            = '#stData.Contract_Title#',
						Contract_Start_Date       = '#stData.Delivery_Start_Date#',
						Contract_End_Date         = '#stData.Delivery_End_Date#',
						Delivery_Start_Date       = '#stData.Delivery_Start_Date#',
						Delivery_End_Date         = '#stData.Delivery_End_Date#',
						Performance_Start_Date    = '#dateformat(stData.Perf_Start_Date, 'm/d/yyyy')#',
						Performance_End_Date      = '#dateformat(stData.Perf_End_Date, 'm/d/yyyy')#',
						Notes                     = '#stData.Notes#',
						Planner_Perf_Type_ID      = '#stData.Planner_Perf_Types_ID#',
						Is_EDLP                   = '#bIsEDLP#',
						Business_Segment_ID       = '#nBusinessSegmentID#',
						Contract_Quantity_UOM_IDX = '#stData.Contract_Quantity_UOM_IDX#',
                        Currency                  = #stData.currency#,
						legacy_deal_id            = '#form.legacy_id#',
						Contract_Reference_Number = '#form.reference#',
						Contract_Reference_Number_2 = '#form.reference2#',
						Alternate_Customer_ON 		= #form.AltCustomers#
				WHERE	Contract_Main_ID 		= '#New_Contract_Main_ID#'
			</cfquery>
			<cfif (form.AltCustomers EQ 0)>
				<cfset updDistributor = saveProgramPlannerDist(stdata,New_Contract_Main_ID) />
			</cfif>

			<!--- RETAIL-359  Copy from program menu changes: If it's copy then return now --->
			<cfif bIsCopy eq 1>

				<!--- We have to get a new product list on copy to accomidate for any inactive products that may have been removed --->
				<cfquery name="qGetProductList" datasource="#application.datasource#">
					SELECT	DISTINCT BSA_Foodservice_Items_Master_ID
					FROM	Contract_Products
					WHERE	Deleted = 0
					AND		Contract_Main_ID = '#New_Contract_Main_ID#'
					AND		Is_Group = <cfif bIsGroup eq 1>1<cfelse>0</cfif>
				</cfquery>

				<cfset stData.Product_List = ValueList(qGetProductList.BSA_Foodservice_Items_Master_ID) />

			</cfif>


		<cfelse>

			<cfset bIsNewPrg = 1 />

			<!---- get the Parent_Revised_Contract_Main_ID if its a revision--->
			<cfif bIsRevision eq 1>

				<cfquery name="qGetParentRevisedContractMainId" datasource="#application.datasource#">
					SELECT 	Contract_Main_ID
					FROM	Contract_Main
					WHERE	Approved = 1
					AND		revision_version = 1
					AND		Is_A_Revision = 0
					AND		Contract_Number = <cfqueryparam value="#stData.Contract_Number#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>

				<cfset nParentContractMainID = qGetParentRevisedContractMainId.Contract_Main_ID />

			</cfif>


			<cfquery name="insert" datasource="#application.datasource#">
					SET NOCOUNT ON
					INSERT INTO Contract_Main
					(
						/*  1 */  Contract_Number,
						/*  2 */  Contract_Title,
						/*  3 */  Contract_Start_Date,
						/*  4 */  Contract_End_Date,
						/*  5 */  Delivery_Start_Date,
						/*  6 */  Delivery_End_Date,
						/*  7 */  Performance_Start_Date,
						/*  8 */  Performance_End_Date,
						/*  9 */  contract_status_type_IDX,
						/* 10 */  Creator_ID,
						/* 11 */  Editor_ID,
						/* 12 */  Owner_Company_ID,
						/* 13 */  Notes,
						/* 14 */  ProgramType_ID,
						/* 15 */  Contract_Is_Locked,
						/* 16 */  Contract_Locked_By_User_ID,
						/* 17 */  Creating_User_Position_ID,
						/* 18 */  Responsible_User_Id,
						/* 19 */  Planner_Id,
						/* 20 */  Planner_Perf_Type_ID,
						/* 21 */  Is_EDLP,
						/* 22 */  Business_Segment_ID,
						/* 23 */  Contract_Quantity_UOM_IDX,
						/* 24 */  Renewal_Of_Contract_Main_ID,
						/* 25 */  Revision_of_Contract_Main_ID,
						/* 26 */  Is_A_Revision,
						/* 27 */  Parent_Revised_Contract_Main_ID,
                        /* 28 */  Currency,
						/* 29 */  Is_Manual_Revision,
						/* 30 */  Legacy_Deal_ID,
						/* 31 */  Contract_Reference_Number,
						/* 32 */  Contract_Reference_Number_2,
						/* 33 */  Alternate_Customer_ON
					)
					VALUES
					(
						/*  1 */  '#stData.Contract_Number#',
						/*  2 */  '#stData.Contract_Title#',
						/*  3 */  '#stData.Delivery_Start_Date#',
						/*  4 */  '#stData.Delivery_End_Date#',
						/*  5 */  '#stData.Delivery_Start_Date#',
						/*  6 */  '#stData.Delivery_End_Date#',
						/*  7 */  '#dateformat(stData.Perf_Start_Date, 'm/d/yyyy')#',
						/*  8 */  '#dateformat(stData.Perf_End_Date, 'm/d/yyyy')#',
						/*  9 */  1,
						/* 10 */  '#request.AccessStructure.User_ID#',
						/* 11 */  '#request.AccessStructure.User_ID#',
						/* 12 */  '#request.AccessStructure.Company_Main_ID#',
						/* 13 */  '#stData.Notes#',
						/* 14 */  '#stData.ProgramType_ID#',
						/* 15 */  1,
						/* 16 */  '#request.AccessStructure.User_ID#',
						/* 17 */  '#This_User_Position_ID#',
						/* 18 */  '#stData.Responsible_User_Id#',
						/* 19 */  '#stData.plannerId#',
						/* 20 */  '#stData.Planner_Perf_Types_ID#',
						/* 21 */  '#bIsEDLP#',
						/* 22 */  '#nBusinessSegmentID#',
						/* 23 */  '#stData.Contract_Quantity_UOM_IDX#',
						/* 24 */  <cfif bIsCopy eq 1> '#stData.programIdCopyRevise#' <cfelse> NULL </cfif>,
						/* 25 */  <cfif bIsRevision eq 1>	'#stData.programIdCopyRevise#' <cfelse>	NULL </cfif>,
						/* 26 */  <cfif bIsRevision eq 1> 1 <cfelse> 0 </cfif>,
                        /* 27 */  <cfif bIsRevision eq 1> '#nParentContractMainID#' <cfelse> NULL </cfif>,
                        /* 28 */  #stData.Currency#,
						/* 29 */  <cfif bIsRevision eq 1> 1 <cfelse> 0 </cfif>,
                        /* 30 */  '#form.legacy_id#',
						/* 31 */  '#form.reference#',
						/* 32 */  '#form.reference2#',
						/* 33 */  #form.AltCustomers#
					)

					SELECT Contract_Main_ID = @@IDENTITY
					SET NOCOUNT OFF
			</cfquery>

			<cfset useLakebaseForrecordCheck = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main_aux_data")>
<cfif useLakebaseForrecordCheck>
	<cftry>
		<cfset recordCheck = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main_aux_data", {
				"contract_main_id" = "eq.#insert.Contract_Main_ID#",
				"select" = "contract_main_id"
			}), "contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForrecordCheck = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForrecordCheck>
<cfquery name="recordCheck" datasource="#application.datasource#">
				SELECT	Contract_Main_ID
				FROM 	Contract_Main_Aux_Data
				WHERE 	Contract_Main_ID = '#insert.Contract_Main_ID#'
			</cfquery>
</cfif>

			<cfif recordCheck.recordcount EQ 0>
				<cfset useLakebaseForinsertRecord = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main_aux_data")>
<cfif useLakebaseForinsertRecord>
	<cftry>
		<cfset application.oLakebase.insertRow("contract_main_aux_data", {
			"contract_main_id" = "#insert.Contract_Main_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsertRecord = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsertRecord>
<cfquery name="insertRecord" datasource="#application.datasource#">
					INSERT INTO Contract_Main_Aux_Data
						(Contract_Main_ID)
					VALUES
						('#insert.Contract_Main_ID#')
				</cfquery>
</cfif>
			</cfif>

            <cfif bIsRevision eq 0>
                <cfset useLakebaseForinsertProgramBidRequest = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bid_request")>
<cfif useLakebaseForinsertProgramBidRequest>
	<cftry>
		<cfset application.oLakebase.insertRow("program_bid_request", {
			"program_id" = "#insert.Contract_Main_ID#",
			"bid_request_status_id" = "1"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsertProgramBidRequest = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsertProgramBidRequest>
<cfquery name="insertProgramBidRequest" datasource="#application.datasource#">
                    INSERT INTO Program_Bid_Request
                        (Program_ID, Bid_Request_Status_ID)
                    VALUES
                        ('#insert.Contract_Main_ID#', 1)
                </cfquery>
</cfif>
            <cfelse>
                <cfquery name="copyProgramBidRequest" datasource="#application.datasource#">
                    INSERT INTO Program_Bid_Request
                        (Program_ID, Bid_Request_Status_ID)
                    SELECT  '#insert.Contract_Main_ID#' as Program_ID, Bid_Request_Status_ID
                    FROM    Program_Bid_Request
                    WHERE   Program_ID = '#stData.programIdCopyRevise#'
                    AND     Deleted = 0
                </cfquery>
            </cfif>



			<cfset New_Contract_Main_ID = insert.Contract_Main_ID />
			<cfset stData.programId = New_Contract_Main_ID />
			<cfset updDistributor = saveProgramPlannerDist(stdata,New_Contract_Main_ID) />

			<!--- add Contract_Operators entries --->
			<!--- Delete first --->
			<cfset useLakebaseForqDelContractOperators = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_operators")>
<cfif useLakebaseForqDelContractOperators>
	<cftry>
		<cfset application.oLakebase.deleteRows("contract_operators", {
			"contract_main_id" = "eq.#New_Contract_Main_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqDelContractOperators = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDelContractOperators>
<cfquery name="qDelContractOperators" datasource="#application.datasource#">
				DELETE FROM Contract_Operators WHERE Contract_Main_ID = '#New_Contract_Main_ID#'
			</cfquery>
</cfif>

			<!--- Insert Operators from Planner_Operators --->
			<cfquery name="qAddContractOperators" datasource="#application.datasource#">
            	INSERT INTO Contract_Operators
                	(BSA_Operator_ID, Contract_Main_ID)
				SELECT 	DISTINCT BSA_Operator_ID, '#New_Contract_Main_ID#'
				FROM 	Planner_Operators
				WHERE 	Planner_ID = '#stData.plannerId#'
			</cfquery>

		</cfif>


		<!--- loop over items to add to Contract_Products and discount tables--->
		<!--- Delete Open Contract_Products entries --->
		<cfset useLakebaseForqDeleteFixedContractProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForqDeleteFixedContractProducts>
	<cftry>
		<cfset application.oLakebase.deleteRows("contract_products", {
			"contract_main_id" = "eq.#New_Contract_Main_ID#",
			"product_type_id" = "eq.0"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqDeleteFixedContractProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeleteFixedContractProducts>
<cfquery name="qDeleteFixedContractProducts" datasource="#application.datasource#">
			DELETE FROM Contract_Products WHERE Contract_Main_ID = '#New_Contract_Main_ID#' AND Product_Type_ID = 0
		</cfquery>
</cfif>

		<!--- Delete Contract_Products entries --->
		<cfquery name="qDeleteFixedContractProducts" datasource="#application.datasource#">
			DELETE FROM Contract_Products WHERE Contract_Main_ID = '#New_Contract_Main_ID#' AND Product_Type_ID = 1
		</cfquery>

		<!--- Delete Program_Fixed_Component entries --->
		<cfset useLakebaseForqDeleteFixedPriceComp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_component")>
<cfif useLakebaseForqDeleteFixedPriceComp>
	<cftry>
		<cfset application.oLakebase.deleteRows("program_fixed_component", {
			"program_id" = "eq.#New_Contract_Main_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqDeleteFixedPriceComp = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeleteFixedPriceComp>
<cfquery name="qDeleteFixedPriceComp" datasource="#application.datasource#">
			DELETE FROM Program_Fixed_Component WHERE Program_ID = '#New_Contract_Main_ID#'
		</cfquery>
</cfif>

		<!--- Delete Program_Fixed_Price_Product_Data entries --->
		<cfset useLakebaseForqDeleteFixedPriceData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_price_product_data")>
<cfif useLakebaseForqDeleteFixedPriceData>
	<cftry>
		<cfset application.oLakebase.deleteRows("program_fixed_price_product_data", {
			"program_id" = "eq.#New_Contract_Main_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqDeleteFixedPriceData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeleteFixedPriceData>
<cfquery name="qDeleteFixedPriceData" datasource="#application.datasource#">
			DELETE FROM Program_Fixed_Price_Product_Data WHERE Program_ID = '#New_Contract_Main_ID#'
		</cfquery>
</cfif>

		<!--- Delete Contract_Products entries --->
		<cfset useLakebaseForqDeleteRebateContractProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForqDeleteRebateContractProducts>
	<cftry>
		<cfset application.oLakebase.deleteRows("contract_products", {
			"contract_main_id" = "eq.#New_Contract_Main_ID#",
			"product_type_id" = "eq.2"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqDeleteRebateContractProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeleteRebateContractProducts>
<cfquery name="qDeleteRebateContractProducts" datasource="#application.datasource#">
			DELETE FROM Contract_Products WHERE Contract_Main_ID = '#New_Contract_Main_ID#' AND Product_Type_ID = 2
		</cfquery>
</cfif>

		<!--- Delete Program_Rebates_Component_Data entries --->
		<cfquery name="qDeleteRebateCompData" datasource="#application.datasource#">
			DELETE 	Program_Rebates_Component_Data
			FROM	Program_Rebates_Component_Data
				INNER JOIN Program_Rebates_Component on Program_Rebates_Component.Program_Rebates_Component_ID = Program_Rebates_Component_Data.Program_Rebates_Component_ID
				INNER JOIN Program_Rebates_Product_Data on Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID
			WHERE	Program_Rebates_Component.Program_ID = '#New_Contract_Main_ID#'
			AND		Program_Rebates_Product_Data.Program_ID = '#New_Contract_Main_ID#'
		</cfquery>

		<!--- Delete Program_Rebates_Component entries --->
		<cfset useLakebaseForqDeleteRebateComp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_component")>
<cfif useLakebaseForqDeleteRebateComp>
	<cftry>
		<cfset application.oLakebase.deleteRows("program_rebates_component", {
			"program_id" = "eq.#New_Contract_Main_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqDeleteRebateComp = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeleteRebateComp>
<cfquery name="qDeleteRebateComp" datasource="#application.datasource#">
			DELETE FROM Program_Rebates_Component WHERE Program_ID = '#New_Contract_Main_ID#'
		</cfquery>
</cfif>

		<!--- Delete Program_Rebates_Product_Data entries --->
		<cfset useLakebaseForqDeleteRebateProductData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_product_data")>
<cfif useLakebaseForqDeleteRebateProductData>
	<cftry>
		<cfset application.oLakebase.deleteRows("program_rebates_product_data", {
			"program_id" = "eq.#New_Contract_Main_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqDeleteRebateProductData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeleteRebateProductData>
<cfquery name="qDeleteRebateProductData" datasource="#application.datasource#">
			DELETE FROM Program_Rebates_Product_Data WHERE Program_ID = '#New_Contract_Main_ID#'
		</cfquery>
</cfif>

		<!--- Delete Contract_Products entries --->
		<cfset useLakebaseForqDeleteLumpSumContractProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForqDeleteLumpSumContractProducts>
	<cftry>
		<cfset application.oLakebase.deleteRows("contract_products", {
			"contract_main_id" = "eq.#New_Contract_Main_ID#",
			"product_type_id" = "eq.3"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqDeleteLumpSumContractProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeleteLumpSumContractProducts>
<cfquery name="qDeleteLumpSumContractProducts" datasource="#application.datasource#">
			DELETE FROM Contract_Products WHERE Contract_Main_ID = '#New_Contract_Main_ID#' AND Product_Type_ID = 3
		</cfquery>
</cfif>

		<!--- Delete Program_Lump_Sum_Product_Data entries --->
		<cfquery name="qDeleteLumpSumProduct" datasource="#application.datasource#">
			DELETE FROM Program_Lump_Sum_Product_Data WHERE Program_Lump_Sum_ID IN (SELECT Program_Lump_Sum_ID FROM Program_Lump_Sums WHERE Program_ID = '#New_Contract_Main_ID#')
		</cfquery>

		<!--- Delete Program_Lump_Sums entries --->
		<cfset useLakebaseForqDeleteLumpSumComp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sums")>
<cfif useLakebaseForqDeleteLumpSumComp>
	<cftry>
		<cfset application.oLakebase.deleteRows("program_lump_sums", {
			"program_id" = "eq.#New_Contract_Main_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqDeleteLumpSumComp = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeleteLumpSumComp>
<cfquery name="qDeleteLumpSumComp" datasource="#application.datasource#">
			DELETE FROM Program_Lump_Sums WHERE Program_ID = '#New_Contract_Main_ID#'
		</cfquery>
</cfif>

		<!--- Delete Program_Payment_Cycle entries --->
		<cfquery name="qDeleteLumpSumComp" datasource="#application.datasource#">
			DELETE FROM Program_Payment_Cycle WHERE Program_ID = '#New_Contract_Main_ID#'
		</cfquery>


		<!--- add fixed --->
		<cfif listLen(stData.lFixedCompIds)>

			<!--- Add entries --->
			<cfloop index="iIndx" list="#stData.Product_List#">

				<cfquery name="qSaveFixedContractProducts" datasource="#application.datasource#">
					SET NOCOUNT ON
					INSERT INTO Contract_Products
						(
							BSA_Foodservice_Items_Master_ID,
							Contract_Main_ID,
							Product_Type_ID,
							Pricing_Level_ID,
							Discounted_Item,
							Include_In_Margin,
							Product_Group_ID,
							Product_Group_Level_ID,
							Is_Group
						)
					VALUES
						(
							'#iIndx#',
							'#New_Contract_Main_ID#',
							1,
							'#stData.Pricing_Level_ID#',
							1,
							1,
							<cfif bIsGroup eq 1>'#iIndx#'<cfelse>'#stData.Product_Group_ID#'</cfif>,
							'#nProduct_List_Type#',
							#bIsGroup#
						)

						SELECT Contract_Products_ID = @@IDENTITY
						SET NOCOUNT OFF
				</cfquery>

				<cfloop index="fIndx" list="#stData.lFixedCompIds#">

					<cfquery name="qFixedCompExists" datasource="#application.datasource#">
						SELECT	*
						FROM	Program_Fixed_Component
						WHERE	Program_ID = '#New_Contract_Main_ID#'
						AND		Fixed_Component_Paid_to = '#listFirst(Evaluate("stData.fixed_component_paid_to_#ListGetAt(fIndx, 1, "_")#_#Replace(iIndx, "-", "_", "ALL")#"))#'
						AND		Program_Fixed_Component_Name_ID = '#ListGetAt(fIndx, 1, "_")#'
						AND		Deleted = 0
					</cfquery>

					<cfif qFixedCompExists.RecordCount>

						<cfset iFixedCompId = qFixedCompExists.Program_Fixed_Component_ID />

					<cfelse>

						<cfset strFixedExternalId = "" />

						<cfquery name="qFixedPriceCompExternalID" datasource="#application.datasource#">
							SELECT External_ID from Program_Fixed_Component_Name WHERE Program_Fixed_Component_Name_ID = '#ListGetAt(fIndx, 1, "_")#'
						</cfquery>

						<cfset strFixedExternalId = qFixedPriceCompExternalID.External_ID />
						<cfset strVendorMasterID = stData["fixed_Vendor_Master_ID_" & ListGetAt(fIndx, 1, "_") & "_" & Replace(iIndx, "-", "_", "ALL")] />

						<cfquery name="qSaveFixedPriceComp" datasource="#application.datasource#">
							SET NOCOUNT ON
							INSERT INTO Program_Fixed_Component
								(
									Program_ID,
									Fixed_Component_Paid_to,
									Program_Fixed_Component_Name_ID,
									Claim_Mechanics,
									GL_Account_ID,
									Component_External_ID,
									Vendor_Master_ID,
									Vendor_Selection,
									Payee_Type
								)
							VALUES
								(
									'#New_Contract_Main_ID#',
									'#listFirst(Evaluate("stData.fixed_component_paid_to_#ListGetAt(fIndx, 1, "_")#_#Replace(iIndx, "-", "_", "ALL")#"))#',
									'#ListGetAt(fIndx, 1, "_")#',
									'#Evaluate("stData.fixed_Claim_Mechanics_#ListGetAt(fIndx, 1, "_")#_#Replace(iIndx, "-", "_", "ALL")#")#',
									'#Evaluate("stData.fixed_GL_Account_ID_#ListGetAt(fIndx, 1, "_")#_#Replace(iIndx, "-", "_", "ALL")#")#',
									'#strFixedExternalId#',
									<cfif strVendorMasterID eq 0 or len(trim(strVendorMasterID)) eq 0>
										NULL,
									<cfelse>
										'#strVendorMasterID#',
									</cfif>
									'#Evaluate("stData.fixed_Vendor_Selection_#ListGetAt(fIndx, 1, "_")#_#Replace(iIndx, "-", "_", "ALL")#")#',
									'#Evaluate("stData.fixed_Payee_Selection_#ListGetAt(fIndx, 1, "_")#_#Replace(iIndx, "-", "_", "ALL")#")#'
								)
							SELECT Program_Fixed_Component_ID = @@IDENTITY
							SET NOCOUNT OFF
						</cfquery>

						<cfset iFixedCompId = qSaveFixedPriceComp.Program_Fixed_Component_ID />

						<cfquery name="qSaveFixedPricePaymentCycle" datasource="#application.datasource#">
							INSERT INTO Program_Payment_Cycle
								(
									Program_ID,
									Discount_Type_ID,
									Payment_Cycle_ID,
									Component_ID
								)
							VALUES
								(
									'#New_Contract_Main_ID#',
									'1',
									'#Evaluate("stData.fixed_paymentcycle_#ListGetAt(fIndx, 1, "_")#_#Replace(iIndx, "-", "_", "ALL")#")#',
									'#iFixedCompId#'

								)
						</cfquery>

					</cfif>

					<!--- Handle for Each and Sleeve UOMs --->
					<cfset local.thisSelectedUOM 	= stData["fixed_uom_" & ListGetAt(fIndx, 1, "_") & "_" & Replace(iIndx, "-", "_", "ALL")] />
					<cfset local.thisNetWeight 		= stData["netWeight_" & Replace(iIndx, "-", "_", "ALL")] />
					<cfset local.thisCaseCount 		= stData["case_count_" & Replace(iIndx, "-", "_", "ALL")] />
					<cfset local.thisSleevesPerCase	= stData["Sleeves_per_case_" & Replace(iIndx, "-", "_", "ALL")] />
					<cfset local.thisInventoryUM 	= stData["Inventory_UM_" & Replace(iIndx, "-", "_", "ALL")] />
					<cfset local.thisRate 			= stData["fixed_rate_" & ListGetAt(fIndx, 1, "_") & "_" & Replace(iIndx, "-", "_", "ALL")] />
					<cfset local.thisUserSelectRate	= 0 />
					<cfset local.thisUserSelectedUOM = 0 />

					<cfif listFindNoCase("5,6,7", local.thisSelectedUOM)>
						<cfset local.thisUserSelectRate = local.thisRate />
						<cfif local.thisSelectedUOM EQ 5>
							<cfset local.thisUserSelectedUOM = 5 />
							<cfif local.thisInventoryUM eq "CS">
								<!--- only convert if its not a group --->
								<cfif bIsGroup neq 1>
									<cfset local.thisRate = local.thisRate / local.thisCaseCount /> <!--- EA to CS --->
								</cfif>
								<cfset local.thisSelectedUOM = 1 />
							<cfelse>
								<!--- only convert if its not a group --->
								<cfif bIsGroup neq 1>
									<cfset local.thisRate = (local.thisRate * local.thisCaseCount) / local.thisNetWeight /> <!--- EA to CS to LB--->
								</cfif>
								<cfset local.thisSelectedUOM = 2 />
							</cfif>
						<cfelseif local.thisSelectedUOM EQ 6>
							<cfset local.thisUserSelectedUOM = 6 />
							<cfset local.thisRate = (local.thisRate / 100.00) /><!--- CWT to LB--->
							<cfset local.thisSelectedUOM = 2 />
						<cfelse>
							<cfset local.thisUserSelectedUOM = 7 />
							<cfif local.thisInventoryUM eq "CS">
								<!--- only convert if its not a group --->
								<cfif bIsGroup neq 1>
									<cfset local.thisRate = (local.thisRate * local.thisSleevesPerCase) /> <!--- SL to CS --->
								</cfif>
								<cfset local.thisSelectedUOM = 1 />
							<cfelse>
								<!--- only convert if its not a group --->
								<cfif bIsGroup neq 1>
									<cfset local.thisRate = (local.thisRate * local.thisSleevesPerCase) / local.thisNetWeight /><!--- SL to CS to LB--->
								</cfif>
								<cfset local.thisSelectedUOM = 2 />
							</cfif>
						</cfif>
					</cfif>

					<cfset useLakebaseForqSaveFixedPriceData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_price_product_data")>
<cfif useLakebaseForqSaveFixedPriceData>
	<cftry>
		<cfset application.oLakebase.insertRow("program_fixed_price_product_data", {
			"program_id" = "#New_Contract_Main_ID#",
			"contract_products_id" = "#qSaveFixedContractProducts.Contract_Products_ID#",
			"fixed_price_value" = "#local.thisRate#",
			"unit_of_measure_id" = "#local.thisSelectedUOM#",
			"program_fixed_component_id" = "#iFixedCompId#",
			"user_picked_uom" = "#local.thisUserSelectedUOM#",
			"user_picked_fixed_price" = "#local.thisUserSelectRate#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqSaveFixedPriceData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqSaveFixedPriceData>
<cfquery name="qSaveFixedPriceData" datasource="#application.datasource#">
						INSERT INTO Program_Fixed_Price_Product_Data
							(
								Program_ID,
								Contract_Products_ID,
								Fixed_Price_Value,
								Unit_Of_Measure_ID,
								Program_Fixed_Component_ID,
								User_picked_UOM,
								User_Picked_Fixed_Price
							)
						VALUES
							(
								'#New_Contract_Main_ID#',
								'#qSaveFixedContractProducts.Contract_Products_ID#',
								'#local.thisRate#',
								'#local.thisSelectedUOM#',
								'#iFixedCompId#',
								'#local.thisUserSelectedUOM#',
								'#local.thisUserSelectRate#'
							)
					</cfquery>
</cfif>

				</cfloop>

			</cfloop>

		</cfif>

		<!--- add rebate --->
		<cfif listLen(stData.lRebateCompIds)>

			<!--- Add entries --->
			<cfloop index="iIndx" list="#stData.Product_List#">

				<cfquery name="qSaveRebateContractProducts" datasource="#application.datasource#">
					SET NOCOUNT ON
					INSERT INTO Contract_Products
						(
							BSA_Foodservice_Items_Master_ID,
							Contract_Main_ID,
							Product_Type_ID,
							Pricing_Level_ID,
							Discounted_Item,
							Include_In_Margin,
							Product_Group_ID,
							Product_Group_Level_ID,
							Is_Group
						)
					VALUES
						(
							'#iIndx#',
							'#New_Contract_Main_ID#',
							2,
							'#stData.Pricing_Level_ID#',
							1,
							1,
							<cfif bIsGroup eq 1>'#iIndx#'<cfelse>'#stData.Product_Group_ID#'</cfif>,
							'#nProduct_List_Type#',
							#bIsGroup#
						)

						SELECT Contract_Products_ID = @@IDENTITY
						SET NOCOUNT OFF
				</cfquery>

				<cfloop index="rIndx" list="#stData.lRebateCompIds#">

					<cfquery name="qRebateCompExists" datasource="#application.datasource#">
						SELECT	*
						FROM	Program_Rebates_Component
						WHERE	Program_ID = '#New_Contract_Main_ID#'
						AND		Component_Paid_To = '#listFirst(Evaluate("stData.rebate_component_paid_to_#ListGetAt(rIndx, 1, "_")#_#Replace(iIndx, "-", "_", "ALL")#"))#'
						AND		Program_Rebates_Component_Name_ID = '#ListGetAt(rIndx, 1, "_")#'
						AND		Deleted = 0
					</cfquery>

					<cfif qRebateCompExists.RecordCount>

						<cfset iRebateCompId = qRebateCompExists.Program_Rebates_Component_ID />

					<cfelse>

						<cfset strRebateExternalId = "" />

						<cfquery name="qRebatePriceCompExternalID" datasource="#application.datasource#">
							SELECT External_ID from Program_Rebates_Component_Name WHERE Program_Rebates_Component_Name_ID = '#ListGetAt(rIndx, 1, "_")#'
						</cfquery>

						<cfset strRebateExternalId = qRebatePriceCompExternalID.External_ID />
						<cfset strVendorMasterID = stData["rebate_Vendor_Master_ID_" & ListGetAt(rIndx, 1, "_") & "_" & Replace(iIndx, "-", "_", "ALL")] />

						<cfquery name="qAddRebateComp" datasource="#application.datasource#">
							INSERT INTO	Program_Rebates_Component
							(
								Program_Rebates_Component_Name_ID,
								Program_ID,
								Component_Paid_To,
								Claim_Mechanics,
								GL_Account_ID,
								Component_External_ID,
								Vendor_Master_ID,
								Vendor_Selection,
								Payee_Type
							)
							VALUES
							(
								'#ListGetAt(rIndx, 1, "_")#',
								'#New_Contract_Main_ID#',
								'#listFirst(Evaluate("stData.rebate_component_paid_to_#ListGetAt(rIndx, 1, "_")#_#Replace(iIndx, "-", "_", "ALL")#"))#',
								'#listFirst(Evaluate("stData.rebate_Claim_Mechanics_#ListGetAt(rIndx, 1, "_")#_#Replace(iIndx, "-", "_", "ALL")#"))#',
								'#listFirst(Evaluate("stData.rebate_GL_Account_ID_#ListGetAt(rIndx, 1, "_")#_#Replace(iIndx, "-", "_", "ALL")#"))#',
								'#strRebateExternalId#',
								<cfif strVendorMasterID eq 0 or len(trim(strVendorMasterID)) eq 0>
									NULL,
								<cfelse>
									'#strVendorMasterID#',
								</cfif>
								'#listFirst(Evaluate("stData.rebate_Vendor_Selection_#ListGetAt(rIndx, 1, "_")#_#Replace(iIndx, "-", "_", "ALL")#"))#',
								'#listFirst(Evaluate("stData.rebate_Payee_Selection_#ListGetAt(rIndx, 1, "_")#_#Replace(iIndx, "-", "_", "ALL")#"))#'
							)

						</cfquery>

						<cfset iRebateCompId = qAddRebateComp.Program_Rebates_Component_ID />

						<cfquery name="qSaveRebatePaymentCycle" datasource="#application.datasource#">
							INSERT INTO Program_Payment_Cycle
								(
									Program_ID,
									Discount_Type_ID,
									Payment_Cycle_ID,
									Component_ID
								)
							VALUES
								(
									'#New_Contract_Main_ID#',
									'2',
									'#Evaluate("stData.rebate_paymentcycle_#ListGetAt(rIndx, 1, "_")#_#Replace(iIndx, "-", "_", "ALL")#")#',
									'#iRebateCompId#'

								)
						</cfquery>

					</cfif>

					<cfset useLakebaseForqAddRebateProductData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_product_data")>
<cfif useLakebaseForqAddRebateProductData>
	<cftry>
		<cfset application.oLakebase.insertRow("program_rebates_product_data", {
			"program_id" = "#New_Contract_Main_ID#",
			"contract_products_id" = "#qSaveRebateContractProducts.Contract_Products_ID#",
			"is_group" = "#bIsGroup#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqAddRebateProductData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqAddRebateProductData>
<cfquery name="qAddRebateProductData" datasource="#application.datasource#">
						INSERT INTO Program_Rebates_Product_Data
							(
								Program_ID,
								Contract_Products_ID,
								Is_Group
							)
						VALUES
							(
								'#New_Contract_Main_ID#',
								'#qSaveRebateContractProducts.Contract_Products_ID#',
								#bIsGroup#
							)
					</cfquery>
</cfif>

					<cfset local.thisSelectedUOM 	= stData["rebate_uom_" & ListGetAt(rIndx, 1, "_") & "_" & Replace(iIndx, "-", "_", "ALL")] />
					<cfset local.thisNetWeight 		= stData["netWeight_" & Replace(iIndx, "-", "_", "ALL")] />
					<cfset local.thisCaseCount 		= stData["case_count_" & Replace(iIndx, "-", "_", "ALL")] />
					<cfset local.thisSleevesPerCase	= stData["Sleeves_per_case_" & Replace(iIndx, "-", "_", "ALL")] />
					<cfset local.thisInventoryUM 	= stData["Inventory_UM_" & Replace(iIndx, "-", "_", "ALL")] />
					<cfset local.thisRate 			= stData["rebate_rate_" & ListGetAt(rIndx, 1, "_") & "_" & Replace(iIndx, "-", "_", "ALL")] />
					<cfset local.thisUserSelectRate	= 0 />
					<cfset local.thisUserSelectedUOM = 0 />

					<cfif listFindNoCase("5,6,7", local.thisSelectedUOM)>
						<cfset local.thisUserSelectRate = local.thisRate />
						<cfif local.thisSelectedUOM EQ 5>
							<cfset local.thisUserSelectedUOM = 5 />
							<cfif local.thisInventoryUM eq "CS">
								<!--- only convert if its not a group --->
								<cfif bIsGroup neq 1>
									<cfset local.thisRate = local.thisRate * local.thisCaseCount /> <!--- EA to CS --->
								</cfif>
								<cfset local.thisSelectedUOM = 1 />
							<cfelse>
								<!--- only convert if its not a group --->
								<cfif bIsGroup neq 1>
									<cfset local.thisRate = (local.thisRate * local.thisCaseCount) / local.thisNetWeight /> <!--- EA to CS to LB--->
								</cfif>
								<cfset local.thisSelectedUOM = 2 />
							</cfif>
						<cfelseif local.thisSelectedUOM EQ 6>
							<cfset local.thisUserSelectedUOM = 6 />
							<cfset local.thisRate = (local.thisRate / 100.00) /><!--- CWT to LB --->
							<cfset local.thisSelectedUOM = 2 />
						<cfelse>
							<cfset local.thisUserSelectedUOM = 7 />
							<cfif local.thisInventoryUM eq "CS">
								<!--- only convert if its not a group --->
								<cfif bIsGroup neq 1>
									<cfset local.thisRate = (local.thisRate * local.thisSleevesPerCase) /> <!--- SL to CS --->
								</cfif>
								<cfset local.thisSelectedUOM = 1 />
							<cfelse>
								<!--- only convert if its not a group --->
								<cfif bIsGroup neq 1>
									<cfset local.thisRate = (local.thisRate * local.thisSleevesPerCase) / local.thisNetWeight /><!--- SL to CS to LB--->
								</cfif>
								<cfset local.thisSelectedUOM = 2 />
							</cfif>
						</cfif>
					</cfif>

                    <cfquery name="qAddRebateCompData" datasource="#application.datasource#">
                        <cfparam name="stData.rebate_scan_#ListGetAt(rIndx, 1, "_")#_#Replace(iIndx, "-", "_", "ALL")#" default="0">

						INSERT INTO	Program_Rebates_Component_Data
							(
								Program_Rebates_Component_ID,
								Program_Rebates_Product_Data_ID,
								Rate,
								Unit_Of_Measure_Id,
								Is_Group,
                                Scan_Percentage,
								User_picked_UOM,
								Scan_Rate
							)
						VALUES
							(
								'#iRebateCompId#',
								'#qAddRebateProductData.Program_Rebates_Product_Data_ID#',
								'#local.thisRate#',
								'#local.thisSelectedUOM#',
								#bIsGroup#,
								'#val(Evaluate("stData.rebate_scan_#ListGetAt(rIndx, 1, "_")#_#Replace(iIndx, "-", "_", "ALL")#"))#',
								'#local.thisUserSelectedUOM#',
								'#val(Evaluate("stData.rebate_scan_#ListGetAt(rIndx, 1, "_")#_#Replace(iIndx, "-", "_", "ALL")#"))#'

							)
						</cfquery>

				</cfloop>

			</cfloop>

		</cfif>

		<!--- add lump sum --->
		<cfif listLen(stData.lLumpSumCompIds)>

			<cfquery name="qPrgTemplate" datasource="#application.datasource#">
				SELECT pcpo.Lump_Sum_Allocation_Method
				  FROM CONTRACT_MAIN
				  		INNER JOIN Program_Control_Panel_Options pcpo on pcpo.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
				 WHERE Contract_Main_ID = '#New_Contract_Main_ID#'
			</cfquery>

            <cfset local.product_counter = 0>

			<!--- Add entries --->
			<cfloop index="iIndx" list="#stData.Product_List#">

				<cfset local.product_guid = iIndx>
                <cfset local.product_counter += 1>

				<!--- define the product guid in cf friendly format used in form elements ( i.e. lump_sum_uom_79_E0605C28_41D0_40C6_B86D_3691FEC5459F ) --->
				<cfset local.product_cf_guid = replace( local.product_guid, '-', '_', "all" )>

				<cfloop index="lsIndx" list="#stData.lLumpSumCompIds#">

					<cfscript>
						// define lump sum component ID used in form elements ( i.e. number 79 in lump_sum_uom_79_E0605C28_41D0_40C6_B86D_3691FEC5459F )
						local.lump_sum_id = listFirst( lsIndx, "_" );

						// define element postfix by combining lump sum ID and product GUID
						local.element_postfix = local.lump_sum_id & '_' & local.product_cf_guid;

						// skip invalid entry - sparodically happened
						if ( structKeyExists( stData, "lump_sum_Vendor_Master_ID_" & local.element_postfix ) eq false ) {
							continue;
						}

						param name="stData.lump_sum_apply_to_#local.element_postfix#" default="0";
						thisLsApplyTo = listFirst( stData[ "lump_sum_apply_to_#local.element_postfix#" ] );

						strLumpSumExternalId = "";
					</cfscript>

					<cfset useLakebaseForqLumpSumPriceCompExternalID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sum_name")>
<cfif useLakebaseForqLumpSumPriceCompExternalID>
	<cftry>
		<cfset qLumpSumPriceCompExternalID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_lump_sum_name", {
				"program_lump_sum_name_id" = "eq.#local.lump_sum_id#",
				"select" = "external_id"
			}), "external_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqLumpSumPriceCompExternalID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqLumpSumPriceCompExternalID>
<cfquery name="qLumpSumPriceCompExternalID" datasource="#application.datasource#">
						SELECT External_ID from Program_Lump_Sum_Name WHERE Program_Lump_Sum_Name_ID = '#local.lump_sum_id#'
					</cfquery>
</cfif>

					<cfset strLumpSumExternalId = qLumpSumPriceCompExternalID.External_ID />
					<cfset strVendorMasterID = listFirst( stData[ "lump_sum_Vendor_Master_ID_" & local.element_postfix ] ) />

					<!--- ngt --->
					<cfif local.product_counter eq 1
							or qPrgTemplate.Lump_Sum_Allocation_Method is "component_product">

						<cfscript>
							// pull lump sum total per component
							local.lump_sum_amount      = stData[ "lump_sum_component_amount_" & local.lump_sum_id ];
							local.lump_sum_description = '';

							if ( qPrgTemplate.Lump_Sum_Allocation_Method is "component_product" ) {
								// pull lump sum product item/group + product description from form element
								param name="stData.item.#product_guid#" default="";
								local.lump_sum_description = stData[ "item." & product_guid ];

								// overwrite with individual product lump sum
								local.lump_sum_amount = stData[ "lump_sum_rate_" & local.element_postfix ];
							}

							// use val() to avoid error from empty string (unexpected value)
							local.lump_sum_amount = val( replace( local.lump_sum_amount, ',', '', "all" ) );
						</cfscript>

						<cfquery NAME="qAddLumpSumComp" datasource="#application.datasource#">
							SET NOCOUNT ON

							INSERT INTO Program_Lump_Sums
							(
								Program_ID,
								Program_Lump_Sum_Name_ID,
								Lump_Sum_Description,
								Lump_Sum_Amount,
								Component_Paid_To,
								Claim_Mechanics,
								Product_Option,
								GL_Account_ID,
								Component_External_ID,
								Vendor_Master_ID
							)
							VALUES
							(
								'#New_Contract_Main_ID#',
								'#local.lump_sum_id#',
								'#local.lump_sum_description#',
								#local.lump_sum_amount#,
								'#listFirst( stData[ "lump_sum_component_paid_to_#local.element_postfix#" ] )#',
								'#stData[ "lump_sum_Claim_Mechanics_#local.element_postfix#" ]#',
								'#thisLsApplyTo#',
								'#stData[ "lump_sum_GL_Account_ID_#local.element_postfix#" ]#',
								'#strLumpSumExternalId#',
								<cfif strVendorMasterID eq 0 or len(trim(strVendorMasterID)) eq 0>
									NULL
								<cfelse>
									'#strVendorMasterID#'
								</cfif>
							)

							SET NOCOUNT OFF
						</cfquery>

					<cfelse>
						<!--- not a first product iteration - find the Program_Lump_Sum row created in above step --->
						<cfquery NAME="qAddLumpSumComp" datasource="#application.datasource#">
							SELECT *
								FROM Program_Lump_Sums
								WHERE Program_ID = '#New_Contract_Main_ID#'
									AND Program_Lump_Sum_Name_ID = '#local.lump_sum_id#'
						</cfquery>
					</cfif>
					<cfset sLumpSumCompId = qAddLumpSumComp.Program_Lump_Sum_ID />

					<cfset useLakebaseForqGetLumpSumExtId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sums")>
<cfif useLakebaseForqGetLumpSumExtId>
	<cftry>
		<cfset qGetLumpSumExtId = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_lump_sums", {
				"program_lump_sum_id" = "eq.#sLumpSumCompId#",
				"select" = "program_lumps_sum_ext_id"
			}), "program_lumps_sum_ext_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetLumpSumExtId = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetLumpSumExtId>
<cfquery name="qGetLumpSumExtId" datasource="#application.datasource#">
						SELECT Program_Lumps_Sum_Ext_ID from Program_Lump_Sums WHERE Program_Lump_Sum_ID = '#sLumpSumCompId#'
					</cfquery>
</cfif>

					<cfset iLumpSumCompId = qGetLumpSumExtId.Program_Lumps_Sum_Ext_ID />

					<cfif local.product_counter eq 1
							or qPrgTemplate.Lump_Sum_Allocation_Method is "component_product">
						<cfquery name="qSaveLumpSumPaymentCycle" datasource="#application.datasource#">
							INSERT INTO Program_Payment_Cycle
								(
									Program_ID,
									Discount_Type_ID,
									Payment_Cycle_ID,
									Component_ID
								)
							VALUES
								(
									'#New_Contract_Main_ID#',
									'3',
									'#stData[ "lump_sum_paymentcycle_#local.lump_sum_id#_#local.product_cf_guid#" ]#',
									'#iLumpSumCompId#'
								)
						</cfquery>
					</cfif>

                    <cfquery name="qSaveLumpSumContractProducts" datasource="#application.datasource#">
                        SET NOCOUNT ON
                        INSERT INTO Contract_Products
                            (
                                BSA_Foodservice_Items_Master_ID,
                                Contract_Main_ID,
                                Product_Type_ID,
                                Pricing_Level_ID,
                                Discounted_Item,
                                Include_In_Margin,
                                Product_Group_ID,
                                Product_Group_Level_ID,
                                Is_Group
                            )
                        VALUES
                            (
                                '#iIndx#',
                                '#New_Contract_Main_ID#',
                                3,
                                '#stData.Pricing_Level_ID#',
                                1,
                                1,
                                <cfif bIsGroup eq 1>'#iIndx#'<cfelse>'#stData.Product_Group_ID#'</cfif>,
                                '#nProduct_List_Type#',
                                #bIsGroup#
                            )

                        SELECT Contract_Products_ID = @@IDENTITY
                        SET NOCOUNT OFF
                    </cfquery>

					<cfset useLakebaseForqAddLumpSumProduct = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sum_product_data")>
<cfif useLakebaseForqAddLumpSumProduct>
	<cftry>
		<cfset application.oLakebase.insertRow("program_lump_sum_product_data", {
			"program_lump_sum_id" = "#sLumpSumCompId#",
			"contract_products_id" = "#qSaveLumpSumContractProducts.Contract_Products_ID#",
			"is_group" = "#bIsGroup#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqAddLumpSumProduct = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqAddLumpSumProduct>
<cfquery NAME="qAddLumpSumProduct" datasource="#application.datasource#">
						INSERT INTO Program_Lump_Sum_Product_Data
							(
								Program_Lump_Sum_ID,
								Contract_Products_ID,
								Is_Group
							)
						VALUES
							(
								'#sLumpSumCompId#',
								'#qSaveLumpSumContractProducts.Contract_Products_ID#',
								#bIsGroup#
							)
					</cfquery>
</cfif>

				</cfloop>

			</cfloop>

		</cfif>

		<!--- add to contract products if no discount types --->
		<cfif (not listLen(stData.lFixedCompIds)) and (not listLen(stData.lRebateCompIds)) and (not listLen(stData.lLumpSumCompIds))>

			<!--- Add entries --->
			<cfloop index="iIndx" list="#stData.Product_List#">

				<cfquery name="qSaveContractProducts" datasource="#application.datasource#">
					SET NOCOUNT ON
					INSERT INTO Contract_Products
						(
							BSA_Foodservice_Items_Master_ID,
							Contract_Main_ID,
							Product_Type_ID,
							Pricing_Level_ID,
							Discounted_Item,
							Include_In_Margin,
							Product_Group_ID,
							Product_Group_Level_ID,
							Is_Group
						)
					VALUES
						(
							'#iIndx#',
							'#New_Contract_Main_ID#',
							0,
							'#stData.Pricing_Level_ID#',
							1,
							1,
							<cfif bIsGroup eq 1>'#iIndx#'<cfelse>'#stData.Product_Group_ID#'</cfif>,
							'#nProduct_List_Type#',
							#bIsGroup#
						)

						SELECT Contract_Products_ID = @@IDENTITY
						SET NOCOUNT OFF
				</cfquery>

			</cfloop>

		</cfif>

		<cfset bNewProgramDisabledFields = 1 />
		<cfif (bIsRevision eq 1 or bIsCopy eq 1 or bIsNewPrg eq 0)>
			<cfset bNewProgramDisabledFields = 0 />
		</cfif>

		<cfif not bNewProgramDisabledFields>
			<cfset saveUnitPrice(stData, bIsEDLP) />
		</cfif>


		<cfif len(trim(stData.Product_List))>

			<!--- If it's indirect --->
			<cfif stData.bIsInDirect eq 1>

				<cfif not bNewProgramDisabledFields>
					<cfset saveProgramPlannerVolumeData(stData, stData.bIsGroupItems) />

					<!--- For indirect run capture after volume is saved at group level --->
					<!---Only run capture if we have components--->
					<cfif listLen(stData.lFixedCompIds) or listLen(stData.lRebateCompIds) or listLen(stData.lLumpSumCompIds)>
						<cfstoredproc procedure="SP_CAPTURE_ALL_FOR_GROUPS" datasource="#application.datasource#">
							<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName="@@CONTRACT_MAIN_ID" value="#New_Contract_Main_ID#" null="no">
							<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName="@@Default_One_Case" value="1" null="no">
							<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName="@@From_EZ_Template" value="0" null="no">
							<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName="@@No_Update_Only_Return_List" value="0" null="no">
							<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName="@@Insert_Table_Name" value="" >
							<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName="@@InvokeVolumePlanInsert" value="0" null="no">
						</cfstoredproc>
					</cfif>

                    <!--- Call procedure which update the Indirect field in the volume plan for parent planner --->
					<cfstoredproc procedure="Planner_Program_Volume_Save_To_Volume_Plan_Indirect" datasource="#application.datasource#">
					   <cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName="@Parent_Planner_ID"             value = "#stData.parentPlannerID#" null="no">
					</cfstoredproc>
				</cfif>

			<!--- If it's not indirect --->
			<cfelse>

				<!--- For direct we need to run capture before volume logic --->
				<!---Only run capture if we have components--->
				<cfif listLen(stData.lFixedCompIds) or listLen(stData.lRebateCompIds) or listLen(stData.lLumpSumCompIds)>

				    <cfstoredproc procedure="SP_CAPTURE_ALL_FOR_GROUPS" datasource="#application.datasource#">
						<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName="@@CONTRACT_MAIN_ID" value="#New_Contract_Main_ID#" null="no">
						<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName="@@Default_One_Case" value="1" null="no">
						<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName="@@From_EZ_Template" value="0" null="no">
						<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName="@@No_Update_Only_Return_List" value="0" null="no">
						<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName="@@Insert_Table_Name" value="" >
						<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName="@@InvokeVolumePlanInsert" value="0" null="no">
				    </cfstoredproc>

				</cfif>

				<!--- add to contract products if no discount types --->
				<cfif stData.bVolumeChange eq 1>

					<cfloop index="iIndx" list="#stData.Product_List#">

						<cfset thisVol = structKeyExists(stData, "vol." & iIndx) ? form[ 'vol.' & iIndx ] : 0>
						<cfset bThisVolChanged = structKeyExists(stData, "volChange" & iIndx) ? form[ 'volChange' & iIndx ] : 0>
						<cfset thisStripGUID = Replace(iIndx, "-", "_", "ALL") />
						<cfset prodUom = structKeyExists(stData, "prodUom__" & thisStripGUID) ? form[ 'prodUom__' & thisStripGUID ] : 1>
						<cfset netWeight = structKeyExists(stData, "netWeight_" & thisStripGUID) ? form[ 'netWeight_' & thisStripGUID ] : 1>
						<cfset caseCount = structKeyExists(stData, "case_count_" & thisStripGUID) ? form[ 'case_count_' & thisStripGUID ] : 1>
						<cfset sleevesPerCase = structKeyExists(stData, "Sleeves_per_case_" & thisStripGUID) ? form[ 'Sleeves_per_case_' & thisStripGUID ] : 1>

						<!--- If the “Program Volume Default UOM:” is set to “Program Template” then we need to use the default UOM from program template if they are not the same. --->
						<cfif stData.plTemplateProgramVolumeDefaultUOM eq 2>
							 <cfset thisVol = convertVolume(thisVol, stData.prgTemplateDefaultUOM, prodUOM, netWeight, caseCount, sleevesPerCase)  />
						</cfif>

						<cfif bThisVolChanged eq 1>

							<cfstoredproc procedure="Planner_Program_Volume_Save_To_Volume_Plan" datasource="#application.datasource#">
								<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName="@Program_ID"             value = "#New_Contract_Main_ID#" null="no">
								<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName="@Product_ID"             value = "#iIndx#"                null="no">
								<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName="@Product_Group_Level_ID" value = "#nProduct_List_Type#"   null="no">
								<cfprocparam type="In" CFSQLType="CF_SQL_DECIMAL" dbVarName="@New_Volume"             value = "#thisVol#"              null="no">
								<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName="@UOM"             		  value = "#prodUom#"              null="no">
							</cfstoredproc>

						</cfif>

					</cfloop>

				<cfelseif qCheckProgramNumber.recordCount>

					<!--- If there is date change, we will update the new weeks with volume from old weeks. Lift from old weeks will be removed --->
					<cfif DateDiff("d", dateformat(qCheckProgramNumber.Delivery_Start_Date, 'm/d/yyyy'), stData.Delivery_Start_Date) neq 0
						OR DateDiff("d", dateformat(qCheckProgramNumber.Delivery_End_Date, 'm/d/yyyy'), stData.Delivery_End_Date) neq 0>
						<cfstoredproc procedure="Planner_Program_Date_Change_Update_Volume_Plan" datasource="#application.datasource#" returnCode = "yes">
						<cfprocparam type="in" 	cfsqltype="cf_sql_integer "	value="#New_Contract_Main_ID#">
						<cfprocparam type="in" 	cfsqltype="cf_sql_date"	value="#dateformat(qCheckProgramNumber.Delivery_Start_Date, 'm/d/yyyy')#">
						<cfprocparam type="in"	cfsqltype="cf_sql_date"	value="#dateformat(qCheckProgramNumber.Delivery_End_Date, 'm/d/yyyy')#">
						</cfstoredproc>
					</cfif>

				</cfif>

				<cfset saveVolumeFromPlanner(stData, New_Contract_Main_ID) />

			</cfif>

		</cfif>
		<!---  78969 & 76032--->
		<cfstoredproc procedure="Planner_Volume_Plan_Product_Insert" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName="@Program_ID"  value="#New_Contract_Main_ID#" null="no">
		</cfstoredproc>

		<cfstoredproc procedure="ADV_BUDGET_CREATE_FROM_ACCRUAL_PROGRAM" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName="@Contract_Main_ID"   value="#New_Contract_Main_ID#" null="no">
			<cfprocparam type="in" 	cfsqltype="cf_sql_bit"	dbVarName="@Add_Budget_To_All_Planner_Programs" value="1">
		</cfstoredproc>

        <cfoutput>
        <cfquery datasource="#application.datasource#">
            EXEC Planner_Program_Trade_Spend_Update  #New_Contract_Main_ID#

            <!--- copy attachments from revised program --->
            <cfif stData.bRevise eq 1>
                INSERT INTO Contract_Attachments
                          ( Program_ID, Doc_ID )
                     SELECT #New_Contract_Main_ID#, Doc_ID
                       FROM Contract_Attachments
                      WHERE Program_ID = #stData.programIdCopyRevise#
            </cfif>
        </cfquery>
        </cfoutput>
		
		<!--- <cfif bIsRevision eq 1> --->
			<cfset createObject("component", "components.programs.bid_request.BidRequestProductStatusManager").setStatusOnRevision(New_Contract_Main_ID) />
		<!--- </cfif> --->

        <cfreturn New_Contract_Main_ID />
    </cffunction>

	<cffunction name="saveProgramPlannerDist" output="true">
		<cfargument name="data" required="true" type="struct" />
		<cfargument name="argNew_Contract_Main_ID" required="true" type="numeric">

		<cfscript>
			//set local variables
			var stData 						= structNew();
			var rId     					= 0;
			var bIsGroup					= 0;
			var bIsEDLP						= 0;
			var bIsNewPrg					= 0;
			var nBusinessSegmentID			= 0;
			var bDistIsGroup 				= 0;
			var nDistributorGroupLevelID	= 0;
			var bIsRevision					= 0;
			var bIsCopy						= 0;
			var nProduct_List_Type			= 0;
			var nParentContractMainID		= 0;

            param stDta.currency = 1;

			//assign local variables
			stData = arguments.data;
			New_Contract_Main_ID = arguments.argNew_Contract_Main_ID;
		</cfscript>

			<!--- REVERT BACK TO THE DEFAULT DISTRIBUTOR ON THE PLANNER --->
			<cfquery name="qGetDistGroupData" datasource="#application.datasource#">
				SELECT  Customer_ID,
						ISNULL(Distributor_Group_Level_ID, 0) as Distributor_Group_Level_ID,
						CASE
							WHEN ISNULL(Distributor_Group_Level_ID, 0) <= 0
							THEN 0
							ELSE 1
						END AS Is_Group,
						CASE
							WHEN ISNULL(Distributor_Group_Level_ID, 0) <= 0
							THEN NULL
							ELSE Customer_ID
						END AS Distributor_Group_ID
				FROM	Planners
				WHERE 	Planners.Deleted = 0
				AND		Planners.Planner_ID = '#stData.plannerId#'
			</cfquery>

			<cfset bDistIsGroup = qGetDistGroupData.Is_Group />
			<cfset nDistributorGroupLevelID	= qGetDistGroupData.Distributor_Group_Level_ID />

			<!--- add Contract_Distributor entries --->
			<cfif nDistributorGroupLevelID neq '-1' and nDistributorGroupLevelID neq '-2'>
				<!--- single group or a distributor --->
				<cfquery name="qAddDistributor" datasource="#application.datasource#">
					DELETE FROM Contract_Distributors
					WHERE Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#New_Contract_Main_ID#" />

					INSERT INTO Contract_Distributors
						(BSA_Foodservice_Customers_ID, Contract_Main_ID, Program_Weight, Is_Group, Distributor_Group_Level_ID, Distributor_Group_ID)
					VALUES
						('#qGetDistGroupData.Customer_ID#', '#New_Contract_Main_ID#', '100', '#bDistIsGroup#', '#nDistributorGroupLevelID#', '#qGetDistGroupData.Distributor_Group_ID#')
				</cfquery>
				<cfif bDistIsGroup>
					<cfstoredproc procedure="CAPTURE_CUSTOMER_GROUPS" datasource="#application.datasource#">
						<cfprocparam type = "In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID"           value = "#New_Contract_Main_ID#"          />
						<cfprocparam type = "In" CFSQLType="CF_SQL_DECIMAL" dbVarName = "@@PROGRAM_WEIGHT"             value = "100"                             />
						<cfprocparam type = "In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@DISTRIBUTOR_GROUP_LEVEL_ID" value = "#nDistributorGroupLevelID#"      />
						<cfprocparam type = "In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@DISTRIBUTOR_GROUP_ID"       value = "#qGetDistGroupData.Customer_ID#" />
						<cfprocparam type = "In" CFSQLType="CF_SQL_BIT"     dbVarName = "@@DYNAMIC_STATIC_GROUPS"      value = "0"                               />
					</cfstoredproc>
				</cfif>
			<cfelse>
				<!--- multiple distributors --->
				<cfquery name="qAddDistributor" datasource="#application.datasource#">

					Declare @Distributor_Count Float = 0,
							 @Distributor_Weight decimal(10,2) = 0,
							 @Distributor_Weight_Balance decimal(10,2) = 0;

					SELECT @Distributor_Count = COUNT(Distributor_ID)
					FROM   Planner_Customer_Group_members
					WHERE Planner_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#stData.plannerId#" />

					IF @Distributor_Count = 0 SET @Distributor_Count = 1

					Select @Distributor_Weight = (100.0 / @Distributor_Count)
					Select @Distributor_Weight_Balance = (100.0 - (@Distributor_Weight * (@Distributor_Count-1)))

					DELETE FROM Contract_Distributors
					WHERE Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#New_Contract_Main_ID#" />

					INSERT INTO Contract_Distributors
						(BSA_Foodservice_Customers_ID, Contract_Main_ID, Program_Weight, Is_Group, Distributor_Group_Level_ID)
					Select Distributor_ID, '#New_Contract_Main_ID#', @Distributor_Weight, 0, 0
					FROM Planner_Customer_Group_members
					WHERE Planner_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#stData.plannerId#" />

					UPDATE 	TOP (1) Contract_Distributors
					  SET 	Program_Weight = @Distributor_Weight_Balance
					WHERE 	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#New_Contract_Main_ID#" />
					  AND  Deleted = 0
				</cfquery>
			</cfif>
		<cfreturn />
	</cffunction>



	<cffunction name="saveProgramPlannerVolumeData" output="true">

		<cfargument name="data" 	required="true" 	type="struct" />
		<cfargument name="isGroup"  required="false" 	type="any"	default="0" />


		<cfscript>

			//set local variables
			var stData 		= structNew();
			var rId     	= 0;
			var iIndx		= "";
			var bIsGroup	= 0;
			var nSpan       = 1;

			//assign local variables
			stData		= arguments.data;
			bIsGroup	= arguments.isGroup;
			nSpan       = DateDiff("d", stData.Delivery_Start_Date, stData.Delivery_End_Date) + 1;
		</cfscript>


		<cfset useLakebaseForqDelVolume = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_product_volume")>
<cfif useLakebaseForqDelVolume>
	<cftry>
		<cfset application.oLakebase.deleteRows("program_product_volume", {
			"program_id" = "eq.#stData.programId#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqDelVolume = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDelVolume>
<cfquery name="qDelVolume" datasource="#application.datasource#">
			DELETE FROM Program_Product_Volume WHERE Program_ID = '#stData.programId#'
		</cfquery>
</cfif>

		<cfloop index="iIndx" list="#stData.Product_List#">

			<cfset thisVol = structKeyExists(stData, "vol." & iIndx) ? form[ 'vol.' & iIndx ] : 0>
			<cfset thisVol = replace(thisVol, ",", "") />

			<cfscript>
				local.postfix = "#Replace(iIndx, "-", "_", "ALL")#";
				param name="stData.prodUom__#local.postfix#"       		default="1";
				param name="stData.netWeight_#local.postfix#"    		default="1";
				param name="stData.case_count_#local.postfix#"    		default="1";
				param name="stData.Sleeves_per_case_#local.postfix#"    default="1";
			</cfscript>

			<cfset prodUom = stData[ "prodUom__" & local.postfix ] />
			<cfset netWeight = stData[ "netWeight_" & local.postfix ] />
			<cfset caseCount = stData[ "case_count_" & local.postfix ] />
			<cfset sleevesPerCase = stData[ "Sleeves_per_case_" & local.postfix ] />

			<!--- If the “Program Volume Default UOM:” is set to “Program Template” then we need to use the default UOM from program template if they are not the same. --->
			<cfif stData.plTemplateProgramVolumeDefaultUOM eq 2>
				<cfset thisVol = convertVolume(thisVol, stData.prgTemplateDefaultUOM, prodUOM, netWeight, caseCount, sleevesPerCase)  />
			</cfif>

			<cfif prodUom eq 2>
				<cfset weeklyVolumeLB = (thisVol * 7.00) / nSpan />
				<cfset weeklyVolumeCS = weeklyVolumeLB / netWeight />
			<cfelse>
				<cfset weeklyVolumeCS = (thisVol * 7.00) / nSpan />
				<cfset weeklyVolumeLB = weeklyVolumeCS * netWeight />
			</cfif>

			<cfset useLakebaseForqSaveVolume = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_product_volume")>
<cfif useLakebaseForqSaveVolume>
	<cftry>
		<cfset application.oLakebase.insertRow("program_product_volume", {
			"bsa_foodservice_items_master_id" = "#iIndx#",
			"program_id" = "#stData.programId#",
			"volume_cs" = "#weeklyVolumeCS#",
			"volume_lb" = "#weeklyVolumeLB#",
			"is_group" = "#bIsGroup#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqSaveVolume = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqSaveVolume>
<cfquery name="qSaveVolume" datasource="#application.datasource#">
				INSERT INTO Program_Product_Volume
					(
						BSA_Foodservice_Items_Master_ID,
						Program_ID,
						Volume_CS,
						Volume_LB,
						Is_Group
					)
				VALUES
					(
						'#iIndx#',
						'#stData.programId#',
						#weeklyVolumeCS#,
						#weeklyVolumeLB#,
						'#bIsGroup#'
					)
			</cfquery>
</cfif>
		</cfloop>

	</cffunction>

	<cffunction name="saveUnitPrice" output="true">

		<cfargument name="data" required="true" type="struct" />
		<cfargument name="isEDLP" type="any" required="false" default="0" />

		<cfscript>
			//set local variables
			var stData 	= structNew();
			var rId     = 0;
			var iIndx	= "";
			var bIsEDLP	= 0;
			var bSaveEDLPField	= 0;

			//assign local variables
			stData 	= arguments.data;
			bIsEDLP	= arguments.isEDLP;
		</cfscript>

		<cfset useLakebaseForlocal_qDel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_group_merchant_info")>
<cfif useLakebaseForlocal_qDel>
	<cftry>
		<cfset application.oLakebase.deleteRows("contract_group_merchant_info", {
			"program_id" = "eq.#stData.programId#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_qDel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_qDel>
<cfquery name="local.qDel" datasource="#application.datasource#">
			DELETE FROM Contract_Group_Merchant_Info WHERE Program_ID = '#stData.programId#'
		</cfquery>
</cfif>

		<cfloop index="iIndx" list="#stData.Product_List#">
			<cfscript>
				local.postfix = "#Replace(iIndx, "-", "_", "ALL")#";

				param name="stData.merchprice__#local.postfix#"    default="0";
				param name="stData.everydayprice__#local.postfix#" default="0";
				param name="stData.discountSum_#local.postfix#"    default="0";
				param name="stData.everydayuom__#local.postfix#"   default="5";
				param name="stData.prodUom__#local.postfix#"       default="1";
				param name="stData.free_cases__#local.postfix#"    default="0";
			</cfscript>

			<cfset bSaveEDLPField = 0 />
			<!--- Save value in field Everyday_Low_Price only when
			- program is EDLP
			- and when there is no other existing entry for same product from another program --->
			<!---<cfif bIsEDLP and not getnEDLPPrice(iIndx, stData.plannerId, stData.Contract_Number).RecordCount>--->
			<cfif bIsEDLP>
				<cfset bSaveEDLPField = 1 />
			</cfif>

			<cfquery name="local.qSave" datasource="#application.datasource#">
				INSERT INTO Contract_Group_Merchant_Info
					(
						Group_ID,
						Program_ID,
						Merchant_Price,
						Everyday_Unit_Price,
						Merchant_Quantity,
						UOM
						<cfif bSaveEDLPField>
							,Everyday_Low_Price
							,Everyday_Low_Price_UOM
						</cfif>
						,Free_Cases
					)
				VALUES
					(
						'#iIndx#',
						'#stData.programId#',
						'#stData[ "merchprice__" & local.postfix ]#',
						'#stData[ "everydayprice__" & local.postfix ]#',
						1,
						'#stData[ "everydayuom__" & local.postfix ]#'
						<cfif bSaveEDLPField>
							,'#stData[ "discountSum_" & local.postfix ]#'
							,'#stData[ "prodUom__" & local.postfix ]#'
						</cfif>
						,#stData[ "free_cases__" & local.postfix ]#
					)
			</cfquery>
		</cfloop>

	</cffunction>

	<cffunction name="getProgramProductGroupType" output="false">

		<cfargument name="id" type="any" required="true" />

		<cfscript>
			//set local variables
			var nId = 0;
			var qReturnData = "";

			//assign local variables
			nId = arguments.id;

		</cfscript>

		<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT 	DISTINCT Product_Group_Level_ID
			FROM	Contract_Products
			WHERE	Contract_Main_ID = '#nId#'
			AND		Deleted = 0
			AND		Is_Group = 1
		</cfquery>

		<cfset qReturnData = qGetData />

		<cfreturn qReturnData />

	</cffunction>

	<cffunction name="getUnitPrice" output="false">

		<cfargument name="programId" type="any" required="true" />

		<cfscript>
			//set local variables
			var nId = 0;
			var qReturnData = "";

			//assign local variables
			nId = arguments.programId;

		</cfscript>

		<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT 	Group_ID,
					Merchant_Price,
					Merchant_Quantity,
					UOM,
					Everyday_Unit_Price,
					Everyday_Low_Price,
					Free_Cases
			FROM	Contract_Group_Merchant_Info
			WHERE	Program_ID = '#nId#'
		</cfquery>

		<cfset qReturnData = qGetData />

		<cfreturn qReturnData />

	</cffunction>

	<cffunction name="checkIfGroupItems" output="false">

		<cfargument name="productList" type="any" required="true" />

		<cfscript>
			//set local variables
			var str = "";
			var returnData = 0;

			//assign local variables
			str = arguments.productList;

		</cfscript>

		<cfif len(trim(str))>
			<cfquery name="qGetData" datasource="#application.datasource#">
				SELECT  TOP 1 *
				FROM BSA_Foodservice_Items_Master
				WHERE BSA_Foodservice_Items_Master_ID IN
				(
					#ListQualify(str, "'")#
				)
				AND (Item IS NULL OR Item = '')

			</cfquery>


			<cfif qGetData.RecordCount>
				<cfset returnData = 1 />
			</cfif>

		</cfif>

		<cfreturn returnData />

	</cffunction>

	<cffunction name="getProgramPlannerVolumeData" output="true">

		<cfargument name="id" type="numeric" required="true" default="" />

		<cfscript>

			//set local variables
			var nId 	= 0;
			var qGetVolume	= "";

			//assign local variables
			nId = arguments.id;

		</cfscript>

		<cfquery name="qGetVolume" datasource="#application.datasource#">
			SELECT	ppv.BSA_Foodservice_Items_Master_ID,
					<!--- ppv.Volume_LB, ppv.Volume_CS --->
					((ISNULL(ppv.Volume_LB, 0)) / 7.00) * (DATEDIFF(d, cm.Contract_Start_Date, cm.Contract_End_Date) + 1) as Volume_LB,
					((ISNULL(ppv.Volume_CS, 0)) / 7.00) * (DATEDIFF(d, cm.Contract_Start_Date, cm.Contract_End_Date) + 1) as Volume_CS
			FROM	Program_Product_Volume ppv
					INNER JOIN Contract_Main cm on cm.Contract_Main_ID = ppv.Program_ID
			WHERE	ppv.Program_ID = '#nId#'
		</cfquery>

		<cfreturn qGetVolume />

	</cffunction>

	<cffunction name="getnEDLPPrice" output="false">

		<cfargument name="item" required="true" default="">
		<cfargument name="plannerId" required="true" default="">
		<cfargument name="contractNumber" required="true" type="string" />
		<cfargument name="contractStartDate" type="string" default="" />
		<cfargument name="contractEndDate"	 type="string" default="" />


		<cfquery name="gGetThisEDLP" datasource="#application.datasource#">
			SELECT	cgmi.*
			FROM	Contract_Main cm
					INNER JOIN Contract_Group_Merchant_Info cgmi on cgmi.Program_ID = cm.Contract_Main_ID
					AND cgmi.Group_ID = '#arguments.item#'
			WHERE	cm.Planner_ID = '#arguments.plannerId#'
			AND		cm.Deleted = 0
			AND		cm.Is_EDLP = 1
			AND		cm.Contract_Number != <cfqueryparam value="#arguments.contractNumber#" CFSQLType="CF_SQL_VARCHAR">
			AND		cm.Manual_Cancel = 0
			<cfif arguments.contractStartDate neq "" and arguments.contractEndDate neq "">
			AND		cm.Contract_Start_Date <=  <cfqueryparam value="#arguments.contractEndDate#" CFSQLType="CF_SQL_DATE">
			AND		cm.Contract_End_Date >=  <cfqueryparam value="#arguments.contractStartDate#" CFSQLType="CF_SQL_DATE">
			Order by cm.Contract_Number, cm.Contract_Main_ID Desc <!--- We will use first row - oldest contract_number, latest version --->
			</cfif>
		</cfquery>

		<cfreturn gGetThisEDLP>

	</cffunction>

	<cffunction name="getnPrice" output="false">

		<cfargument name="item" 				required="true">
		<cfargument name="groupLevelId" 		required="false" default="">
		<cfargument name="groupId" 				required="false" default="">
		<cfargument name="programId" 			required="false" default="">
		<cfargument name="defaultUOM"			required="false" default="1">

		<cfscript>

			//set local variables
			var strItem 			= 0;
			var nGroupLevelId		= "";
			var strGroupId			= "";
			var local.query			= "";
			var nProgramID			= 0;
			var bGroup		    	= 0;
			var nDefaultUOM			= 1;

			//assign local variables
			strItem 			= arguments.item;
			nGroupLevelId		= arguments.groupLevelId;
			strGroupId			= arguments.groupId;
			nProgramID			= arguments.programId;
			nDefaultUOM			= arguments.defaultUOM;

		</cfscript>

		<cfif nGroupLevelId neq 0 and nGroupLevelId neq "">
			<cfset gGetAttr = getProdAttrData(nGroupLevelId) />
			<cfif gGetAttr.RecordCount>
				<cfset bGroup = 1 />
			</cfif>
		</cfif>

		<cfif application.appsettingsget.getPriceListByTemplate()>
			<cfquery name="local.query" datasource="#application.datasource#">
				DECLARE @Margin_Price_List_Header_ID uniqueidentifier,
						@Base_Sales_based_on_Prg_Start_Date bit,
						@Effective_Date_for_Price date

				SELECT 	@Margin_Price_List_Header_ID = Margin_Price_List_Header_ID,
						@Base_Sales_based_on_Prg_Start_Date = Base_Sales_based_on_Prg_Start_Date,
						@Effective_Date_for_Price =
						CASE
						WHEN t.Select_Effective_Date_for_Price = 0 THEN cm.Contract_Start_Date
						ELSE ISNULL(ISNULL(cm.Price_Protection_Date, cm.Effective_Date_for_Price), cm.Contract_Start_Date)
						END
				FROM	Contract_Main cm
				INNER JOIN Program_Control_Panel_Options t
				ON		t.ProgramControl_Panel_Options_ID = cm.ProgramType_ID
				WHERE	cm.Contract_Main_ID = <cfqueryparam value='#nProgramID#'>

				SELECT	<cfif nDefaultUOM eq 2>
							AVG(CAST(pl.LB_FOB_Price as decimal(20, 4))) as Price, 'LBS' as Unit_Of_Measure
						<cfelse>
							AVG(CAST(pl.CS_FOB_Price as decimal(20, 4))) as Price, 'CS' as Unit_Of_Measure
						</cfif>
				FROM	BSA_Foodservice_Items_Master im
				<cfif bGroup>
					<cfif gGetAttr.Is_PG EQ 1>
					INNER JOIN PG_Product_Members m
					ON	m.PG_Product_Category_ID = '#strGroupId#'
					AND	m.BSA_Foodservice_Items_Master_ID = im.BSA_Foodservice_Items_Master_ID
					AND	m.Deleted = 0
					<cfelse>
					INNER JOIN #gGetAttr.Product_Group_Attribute_Table# f
					ON		f.#gGetAttr.Product_Group_Attribute_ID_Field# = im.#gGetAttr.Product_Group_Attribute_ID_Field#
					AND 	f.#gGetAttr.Product_Group_Attribute_ID_Field# =  '#strGroupId#'
					</cfif>
				</cfif>
				INNER JOIN price_list_detail pl
				ON		pl.Price_List_Header_ID = @Margin_Price_List_Header_ID
				AND		pl.Product_ID = im.BSA_Foodservice_Items_Master_ID
				AND		pl.Deleted = 0
				AND	(
					(@Base_Sales_based_on_Prg_Start_Date = 1 AND @Effective_Date_for_Price between pl.Start_Date and pl.End_Date)
					OR (@Base_Sales_based_on_Prg_Start_Date = 0 AND pl.Active_Code = 'A')
					)
				WHERE	im.Deleted = 0
				<cfif not bGroup>
					AND		im.BSA_Foodservice_Items_Master_ID = '#strGroupId#'
				</cfif>
				AND		im.Item IS NOT NULL

			</cfquery>
		<cfelse>

            <cfquery name="local.getTemplatePriceSetting" datasource="#application.datasource#">
                SELECT 	Base_Sales_based_on_Prg_Start_Date,
						Effective_Date_for_Price =
                        CAST(
						CASE
						WHEN t.Select_Effective_Date_for_Price = 0 THEN cm.Contract_Start_Date
						ELSE ISNULL(ISNULL(cm.Price_Protection_Date, cm.Effective_Date_for_Price), cm.Contract_Start_Date)
						END as DATE)
				FROM	Contract_Main cm
				INNER JOIN Program_Control_Panel_Options t
				ON		t.ProgramControl_Panel_Options_ID = cm.ProgramType_ID
				WHERE	cm.Contract_Main_ID = <cfqueryparam value='#nProgramID#'>
            </cfquery>

        <cfif local.getTemplatePriceSetting.Base_Sales_based_on_Prg_Start_Date eq 1>

            <cfquery name="local.query" datasource="#application.datasource#">
							IF OBJECT_ID('tempdb..##tmp_ProdDistPrice') IS NOT NULL
							DROP TABLE ##tmp_ProdDistPrice

							IF OBJECT_ID('tempdb..##tmp_Distributors') IS NOT NULL
							DROP TABLE ##tmp_Distributors

							IF OBJECT_ID('tempdb..##tmp_Products') IS NOT NULL
							DROP TABLE ##tmp_Products
            </cfquery>

            <cfquery name="local.query" datasource="#application.datasource#">
                DECLARE @Price decimal(20, 2),
                        @Effective_Date_for_Price date = '#local.getTemplatePriceSetting.Effective_Date_for_Price#',
												@Price_List_By_Currency varchar(10),
												@Currency INT
		
												SELECT @Price_List_By_Currency = ISNULL(dbo.udf_GetAppSetting('Price_List_By_Currency'),'')
												SELECT @Currency = ISNULL(Currency, 0)
												FROM CONTRACT_MAIN
												WHERE CONTRACT_MAIN_ID = <cfqueryparam value='#nProgramID#'>

                SELECT	cd.BSA_Foodservice_Customers_ID, c.Price_List_Header_ID
                INTO	##tmp_Distributors
                FROM	Contract_Distributors cd
                INNER JOIN BSA_Foodservice_Customers c
                ON		c.BSA_Foodservice_Customers_ID = cd.BSA_Foodservice_Customers_ID
                WHERE	cd.Contract_Main_ID = <cfqueryparam value='#nProgramID#'>
                AND		cd.Deleted = 0
                AND		cd.Is_Group = 0

                <cfif not bGroup>
                    <!--- Individual product --->
                    SELECT	im.BSA_Foodservice_Items_Master_ID, im.Active_Code
                    INTO	##tmp_Products
                    FROM	BSA_Foodservice_Items_Master im
                    WHERE   im.BSA_Foodservice_Items_Master_ID = '#strGroupId#'
                <cfelse>
                    <!--- Group - get members from program --->
                    SELECT  BSA_Foodservice_Items_Master_ID, 'A' as Active_Code
                    INTO    ##tmp_Products
                    FROM    Contract_Products cp
                    WHERE	cp.Contract_Main_ID = <cfqueryparam value='#nProgramID#'>
                    AND     cp.Product_Group_ID = '#strGroupId#'
                    AND		cp.Deleted = 0
                    AND		cp.Is_Group = 0

                    <!--- If no products on program, get members frpm item master --->
                    IF NOT EXISTS (SELECT 1 FROM ##tmp_Products)
                    INSERT INTO ##tmp_Products (BSA_Foodservice_Items_Master_ID, Active_Code)
                    SELECT	im.BSA_Foodservice_Items_Master_ID, im.Active_Code
                    FROM	BSA_Foodservice_Items_Master im
                    <cfif gGetAttr.Is_PG EQ 1>
                        INNER JOIN PG_Product_Members m
                        ON	m.PG_Product_Category_ID = '#strGroupId#'
                        AND	m.BSA_Foodservice_Items_Master_ID = im.BSA_Foodservice_Items_Master_ID
                        AND	m.Deleted = 0
                        <cfelse>
                        INNER JOIN #gGetAttr.Product_Group_Attribute_Table# f
                        ON		f.#gGetAttr.Product_Group_Attribute_ID_Field# = im.#gGetAttr.Product_Group_Attribute_ID_Field#
                        AND 	f.#gGetAttr.Product_Group_Attribute_ID_Field# =  '#strGroupId#'
                    </cfif>
                    WHERE	im.Deleted = 0
                    AND		im.Item IS NOT NULL
                </cfif>

                IF OBJECT_ID('tempdb..##tmp_Dist_Prod') IS NOT NULL
                DROP TABLE ##tmp_Dist_Prod

                SELECT	d.BSA_Foodservice_Customers_ID, d.Price_List_Header_ID, p.BSA_Foodservice_Items_Master_ID, p.Active_Code,
                        CAST(0 as decimal(20, 2)) as Price
                INTO	##tmp_Dist_Prod
                FROM	##tmp_Distributors d
                CROSS JOIN ##tmp_Products p

                /* First get special price */
                UPDATE	t
                SET		Price =
                        <cfif nDefaultUOM eq 2>
                            d.LB_FOB_Price
                        <cfelse>
                            d.CS_FOB_Price
                        </cfif>
                FROM	##tmp_Dist_Prod t
                INNER JOIN Price_List_Header_Special h
                ON		h.Customers_ID = t.BSA_Foodservice_Customers_ID
                INNER JOIN price_list_detail_Special d
                ON		d.Price_List_Header_Special_ID = h.Price_List_Header_Special_ID
                AND		d.Product_ID = t.BSA_Foodservice_Items_Master_ID
                WHERE	h.Deleted = 0
                AND		d.Deleted = 0
                AND		@Effective_Date_for_Price BETWEEN d.Start_Date AND d.End_Date

                /* Next get regular price */
                UPDATE	t
                SET		Price =
                        <cfif nDefaultUOM eq 2>
                            d.LB_FOB_Price
                        <cfelse>
                            d.CS_FOB_Price
                        </cfif>
                FROM	##tmp_Dist_Prod t
                INNER JOIN Price_List_Detail d
                ON		d.Price_List_Header_ID = t.Price_List_Header_ID
                AND		d.Product_ID = t.BSA_Foodservice_Items_Master_ID
                WHERE	t.Price = 0
                AND		d.Deleted = 0
                AND		@Effective_Date_for_Price BETWEEN d.Start_Date AND d.End_Date
		AND     (@Price_List_By_Currency <> '1' or d.Currency_ID = @Currency)
																				
                /* Get price from active products */
                /* Get average product price per group */
                SELECT	@Price = AVG(Price)
                FROM	(
                    /* First average distributor price per product */
                    SELECT  BSA_Foodservice_Items_Master_ID, AVG(Price) as Price
                    FROM    ##tmp_Dist_Prod
                    WHERE	Price != 0
                    <cfif bGroup>
                    AND   Active_Code = 'A'
                    </cfif>
                    GROUP BY BSA_Foodservice_Items_Master_ID
                ) as tmp

                /* Get price from all products if price not found from active products*/
                <cfif bGroup>
                /* Get average product price per group */
                IF @Price IS NULL
                BEGIN
                    SELECT	@Price = AVG(Price)
                    FROM	(
                        /* First average distributor price per product */
                        SELECT  BSA_Foodservice_Items_Master_ID, Avg(Price) as Price
                        FROM    ##tmp_Dist_Prod
                        WHERE	Price != 0
                        GROUP BY BSA_Foodservice_Items_Master_ID
                    ) as tmp
                END
                </cfif>

                SELECT	@Price as Price, <cfif nDefaultUOM eq 2>'LBS' as Unit_Of_Measure<cfelse>'CS' as Unit_Of_Measure</cfif>

            </cfquery>

        <cfelse>


			<cfquery name="local.query" datasource="#application.datasource#">
                IF OBJECT_ID('tempdb..##tmp_ProdDistPrice') IS NOT NULL
				DROP TABLE ##tmp_ProdDistPrice
            </cfquery>

            <cfquery name="local.query" datasource="#application.datasource#">
				<!--- Get customers --->

				IF OBJECT_ID('tempdb..##tmp_Distributors') IS NOT NULL
				DROP TABLE ##tmp_Distributors

				SELECT	cd.BSA_Foodservice_Customers_ID
				INTO	##tmp_Distributors
				FROM	Contract_Distributors cd
				WHERE	cd.Contract_Main_ID = <cfqueryparam value='#nProgramID#'>
				AND		cd.Deleted = 0
				AND		cd.Is_Group = 0

				IF OBJECT_ID('tempdb..##tmp_Products') IS NOT NULL
				DROP TABLE ##tmp_Products

                <cfif not bGroup>
                    <!--- Individual product --->
                    SELECT	im.BSA_Foodservice_Items_Master_ID, im.Active_Code
                    INTO	##tmp_Products
                    FROM	BSA_Foodservice_Items_Master im
                    WHERE   im.BSA_Foodservice_Items_Master_ID = '#strGroupId#'
                <cfelse>
                    <!--- Group - get members from program --->
                    SELECT  BSA_Foodservice_Items_Master_ID, 'A' as Active_Code
                    INTO    ##tmp_Products
                    FROM    Contract_Products cp
                    WHERE	cp.Contract_Main_ID = <cfqueryparam value='#nProgramID#'>
                    AND     cp.Product_Group_ID = '#strGroupId#'
                    AND		cp.Deleted = 0
                    AND		cp.Is_Group = 0

                    <!--- If no products on program, get members frpm item master --->
                    IF NOT EXISTS (SELECT 1 FROM ##tmp_Products)
                    INSERT INTO ##tmp_Products (BSA_Foodservice_Items_Master_ID, Active_Code)
                    SELECT	im.BSA_Foodservice_Items_Master_ID, im.Active_Code
                    FROM	BSA_Foodservice_Items_Master im
                    <cfif gGetAttr.Is_PG EQ 1>
                        INNER JOIN PG_Product_Members m
                        ON	m.PG_Product_Category_ID = '#strGroupId#'
                        AND	m.BSA_Foodservice_Items_Master_ID = im.BSA_Foodservice_Items_Master_ID
                        AND	m.Deleted = 0
                        <cfelse>
                        INNER JOIN #gGetAttr.Product_Group_Attribute_Table# f
                        ON		f.#gGetAttr.Product_Group_Attribute_ID_Field# = im.#gGetAttr.Product_Group_Attribute_ID_Field#
                        AND 	f.#gGetAttr.Product_Group_Attribute_ID_Field# =  '#strGroupId#'
                    </cfif>
                    WHERE	im.Deleted = 0
                    AND		im.Item IS NOT NULL
                </cfif>

                IF OBJECT_ID('tempdb..##tmp_ProdDistPrice') IS NOT NULL
				DROP TABLE ##tmp_ProdDistPrice

                SELECT  DISTINCT im.BSA_Foodservice_Items_Master_ID, im.Active_Code, d.BSA_Foodservice_Customers_ID,
                        CAST(0 as decimal(20, 5)) as GM_Price,
                        <cfif nDefaultUOM eq 2>
                            (CAST(ITEM_FOB_BASE_PRICE_LB as decimal(20, 4)))
                        <cfelse>
                            (CAST(ITEM_FOB_BASE_PRICE_CS as decimal(20, 4)))
                        </cfif> as IMT_Price
                INTO    ##tmp_ProdDistPrice
                FROM	##tmp_Products im
				INNER JOIN ##tmp_Distributors d
				ON		1=1
                LEFT JOIN ITEM_MARGIN_TARGETS imt
				ON		imt.Product_Id = im.BSA_Foodservice_Items_Master_ID

                UPDATE  t
                SET     GM_Price =  <cfif nDefaultUOM eq 2>
                                        (CAST(gm.LB_FOB_Price as decimal(20, 4)))
                                    <cfelse>
                                        (CAST(gm.CS_FOB_Price as decimal(20, 4)))
                                    </cfif>
                FROM    ##tmp_ProdDistPrice t
                INNER JOIN Gross_Margin gm
				ON		gm.Customer_Id = t.BSA_Foodservice_Customers_ID
				AND		gm.Product_id = t.BSA_Foodservice_Items_Master_ID

				DECLARE @Price decimal(20, 2)

                <!--- Get price from gross margin --->
				SELECT	@Price = AVG(Price)
				FROM	(
                    SELECT  BSA_Foodservice_Items_Master_ID, AVG(GM_Price) as Price
                    FROM    ##tmp_ProdDistPrice
                    WHERE   GM_Price != 0
                    <cfif bGroup> <!--- only active products --->
                    AND     Active_Code = 'A'
                    </cfif>
                    GROUP BY BSA_Foodservice_Items_Master_ID
                ) as tmp

                <!--- Get price from item margin targets --->
				IF @Price IS NULL
				BEGIN
					SELECT	@Price = AVG(Price)
					FROM	(
						SELECT  BSA_Foodservice_Items_Master_ID, Avg(IMT_Price) as Price
						FROM    ##tmp_ProdDistPrice
						WHERE	IMT_Price != 0
                        <cfif bGroup> <!--- only active products --->
						AND		Active_Code = 'A'
                        </cfif>
						GROUP BY BSA_Foodservice_Items_Master_ID
					) as tmp
				END

                <!--- Get price from all products if price not found from active products --->
                 <cfif bGroup>
                    <!--- Get price from gross margin --->
                    IF @Price IS NULL
                    BEGIN
                        SELECT	@Price = AVG(Price)
                        FROM	(
                            SELECT  BSA_Foodservice_Items_Master_ID, Avg(GM_Price) as Price
                            FROM    ##tmp_ProdDistPrice
                            WHERE	GM_Price != 0
                            GROUP BY BSA_Foodservice_Items_Master_ID
                        ) as tmp
                    END

                    <!--- Get price from item margin targets --->
                    IF @Price IS NULL
                    BEGIN
                        SELECT	@Price = AVG(Price)
                        FROM	(
                            SELECT  BSA_Foodservice_Items_Master_ID, Avg(IMT_Price) as Price
                            FROM    ##tmp_ProdDistPrice
                            WHERE	IMT_Price != 0
                            GROUP BY BSA_Foodservice_Items_Master_ID
                        ) as tmp
                    END
                </cfif>

				SELECT	@Price as Price, <cfif nDefaultUOM eq 2>'LBS' as Unit_Of_Measure<cfelse>'CS' as Unit_Of_Measure</cfif>

			</cfquery>

        </cfif> <!--- <cfif local.getTemplatePriceSetting.Base_Sales_based_on_Prg_Start_Date eq 1> --->
		</cfif>

		<cfscript>
			local.struct = {};
			local.struct.val = val(local.query.Price);
			local.struct.uom = local.query.Unit_Of_Measure;
		</cfscript>

		<cfreturn local.struct>

	</cffunction>

	<cffunction name="getProductVolumeFromVolumePlan" output="true">

		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="groupId" required="true" type="string" />

		<cfscript>

			//set local variables
			var strGroupId		= "";
			var local.query		= "";
			var nProgramID		= 0;

			//assign local variables
			strGroupId		= arguments.groupId;
			nProgramID		= arguments.programId;

		</cfscript>

		<cfstoredproc procedure="Planner_Program_Product_Volume_From_Volume_Plan" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#nProgramID#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@New_Product_ID" value = "#strGroupId#" null="no">
			<cfprocresult name="local.query">
		</cfstoredproc>

		<cfscript>
			local.struct = {};
			local.struct.forecast_cs = val(local.query.forecast_volume_cs);
			local.struct.forecast_lb = val(local.query.forecast_volume_lb);
		</cfscript>

		<cfreturn local.struct>

	</cffunction>

	<cffunction name="getProdAttrData" output="false">

		<cfargument name="groupLevelId" required="false" default="">

		<cfreturn CreateObject("component","mvc.Models.Planner.PlannerManager").getProdAttrData(arguments.groupLevelId) />

	</cffunction>

	<cffunction name="saveVolumeFromPlanner" output="false">

		<cfargument name="data" required="true" type="struct" />
		<cfargument name="programId" required="true" type="string" />


		<cfstoredproc procedure="Planner_Program_Product_Volume_From_Volume_Plan" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#New_Contract_Main_ID#" null="no">
		</cfstoredproc>

	</cffunction>

	<cffunction name="getUnits" output="false">

		<cfargument name="groupId" required="false" default="">

		<cfscript>

			//set local variables
			var strItem 		= 0;
			var nGroupLevelId	= "";
			var strGroupId		= "";
			var strReturn		= "";

			//assign local variables
			strGroupId		= arguments.groupId;

			oPlannerSettings        = CreateObject("component", "mvc.Models.Planner.PlannerSettingsManager");

			strReturn = oPlannerSettings.getNUCTargets(strGroupId).Case_count;

		</cfscript>


		<cfif not IsNumeric(strReturn)>
			<cfset strReturn = 1 />
		</cfif>

		<cfreturn strReturn>

	</cffunction>

	<cffunction name="rfaProgram" access="remote" returnFormat="json" output="no">
		<cfargument name="programId"	required="true" type="numeric" />
		<cfargument name="userId" 		required="true" type="string" />

		<cfscript>
			var objProgram 	= CreateObject("component", "components.programs.program");
			var iProgramId 	= 0;
			var strUserId	= "";
			var objProgramManager	= CreateObject("component","mvc.Models.Program.ProgramManager");
			var bAutoApproveProgram = 0;

			iProgramId		= arguments.programId;
			strUserId		= arguments.userId;



		</cfscript>

		<cfstoredproc procedure="SP_CAPTURE_ALL_FOR_GROUPS" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#iProgramId#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@@Default_One_Case" value = "1" null="no">
		</cfstoredproc>

		<cfscript>
			objProgram.makeRFA(iProgramId, strUserId);
			appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
		</cfscript>

		<cfstoredproc procedure="Planner_Slotting_Products_Update" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Planner_ID" value = "0" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#iProgramId#" null="no">
		</cfstoredproc>

		<!--- handle for auto approve --->
		<!--- check if planner is approved first --->
		<cfquery name="local.qGetPlannerData" datasource="#application.datasource#">
				SELECT	ISNULL(p.Approved, 0) as Planner_Approved, cmad.RFA_Email_Sent
				FROM	Contract_Main cm
				INNER JOIN Contract_Main_Aux_Data cmad
				ON cmad.Contract_Main_ID = cm.Contract_Main_ID
				INNER Join Planners p ON p.Planner_ID = cm.Planner_ID
				WHERE	cm.Contract_Main_ID = <cfqueryparam value="#iProgramId#">
      </cfquery>

		<cfif local.qGetPlannerData.Planner_Approved eq 1>
			<cfset bAutoApproveProgram = objProgramManager.rfaProgramEZButtonHandling(iProgramId) />
			<cfif bAutoApproveProgram eq 1>
				<cfset objProgramManager.autoApproveProgram(iProgramId) />
			<cfelse>
				<cfif appSettings.getRFAEmailEvent() NEQ 2 AND  local.qGetPlannerData.RFA_Email_Sent EQ 0>
					<cfset Contract_Main_ID = iProgramId>
					<cfinclude template="/ANYTHING_AUTOMATED/EMAIL/rfa_program_emailer.cfm">
				</cfif>
			</cfif>
		</cfif>

	</cffunction>

	<!--- D86187 planner program - shorcut routing --->
	<cffunction name="checkShortCutRouting" access="remote" returnFormat="json" output="no">
		<cfargument name="programId"		required="true" type="numeric" />
		<cfargument name="parentProgramId"	required="true" type="numeric" />
		<cfargument name="userId" 			required="true" type="string" />

        <cfset local.bAutoApproveProgram = 0 />

		<cfset objProgram 	= CreateObject("component", "components.programs.program") />
		<cfinclude template="/Get_Access_Profile.cfm">
		<!--- set short cut routing flags - start --->
		<cfif Get_Profile_Settings.Prevent_short_cut_routing EQ 0 AND  application.appsettingsget.getRevisionTypesOn() EQ 1>

			<cfif objProgram.isARevision(arguments.programId)>
				<cfset oRevise_Type_Check = CreateObject("component", "components.programs.Revise_Type_Check") />
				<cfset oReviseLog = CreateObject("component", "components.programs.ReviseLog") />
				<cfset MinorRevision = oRevise_Type_Check.MinorReviseFieldsCheck(arguments.parentProgramId, arguments.programId) />

				<!--- D28558: Shortcut Routing Changes --->
				<!--- If program is flagged as a specific Revision Type and that Revision Type does not require routing, flag the program as approved  --->
				<cfset qGetProgramRevisionTypes = oRevise_Type_Check.getProgramRevisionTypes(programId = arguments.programId) />
				<!--- Program is flagged as short cut type A, B or C --->
				<cfif qGetProgramRevisionTypes.RevisionTypeA GT 0 OR qGetProgramRevisionTypes.RevisionTypeB GT 0 OR qGetProgramRevisionTypes.RevisionTypeC GT 0>
					<cfset qGetRevisionSettingsData = oRevise_Type_Check.getRevisionSettingsData() />
					<cfif
						(qGetProgramRevisionTypes.RevisionTypeA EQ 0 OR qGetRevisionSettingsData.No_Routing_Required_A EQ "1")     <!--- 1.Program is not flagged as short cut type A, 2. Program is flagged as short cut type A and type A does not require routing --->
						AND (qGetProgramRevisionTypes.RevisionTypeB EQ 0 OR qGetRevisionSettingsData.No_Routing_Required_B EQ "1") <!--- 1.Program is not flagged as short cut type B, 2. Program is flagged as short cut type B and type B does not require routing --->
						AND (qGetProgramRevisionTypes.RevisionTypeC EQ 0 OR qGetRevisionSettingsData.No_Routing_Required_C EQ "1") <!--- 1.Program is not flagged as short cut type C, 2. Program is flagged as short cut type C and type C does not require routing --->
						>
						<!--- D32283 Add Setting for EZ Button Program revisios START--->
						<cfset CheckAutoApprove = oRevise_Type_Check.CheckEZRate(arguments.parentProgramId, arguments.programId)>

						<!--- Tim Ford - 05/01/2017: D68417 - Volume Override Enhancement-Revision Functionality
						Don't auto approve if volume override options were changed for revision --->
						<cfset CheckVolumeOverride = oReviseLog.getVolumeOverrideIgnore(arguments.parentProgramId, arguments.programId)>

						<cfif NOT CheckAutoApprove and NOT CheckVolumeOverride.RecordCount>
							<!--- Approve the program --->
							<!--- Here we do not need to check all the auto approval Ezbutton logic (it is below in this file). Here, we just have a simple additional check for "EZ rates", before short-cut coukd approve it. --->
							<cfset local.bAutoApproveProgram = 1 />
						</cfif>
						<!--- D32283 Add Setting for EZ Button Program revisios END--->
					</cfif>
				</cfif>
				<!--- Shortcut Routing ends here. --->
			</cfif>
		</cfif>
        <cfreturn local.bAutoApproveProgram />
	</cffunction>

	<cffunction name="checkDuplicateProgram" access="remote" returnFormat="json" output="no">
		<cfargument name="plannerId"	required="true" type="numeric" />
		<cfargument name="contractNumber"	required="true" type="string" />
		<cfargument name="perfTypeId"	required="true" type="numeric" />
		<cfargument name="startDate"	required="true" type="string" />
		<cfargument name="endDate"	    required="true" type="string" />
		<cfargument name="productList"	required="true" type="string" />
		<cfargument name="delStartDate"	required="true" type="string" />
		<cfargument name="delEndDate"	    required="true" type="string" />

        <cfset useLakebaseForlocal_qPerformanceType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_perf_types")>
<cfif useLakebaseForlocal_qPerformanceType>
	<cftry>
		<cfset local.qPerformanceType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("planner_perf_types", {
				"planner_perf_types_id" = "eq.#arguments.perfTypeId#",
				"select" = "allow_duplicate_programs"
			}), "allow_duplicate_programs"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_qPerformanceType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_qPerformanceType>
<cfquery name="local.qPerformanceType" datasource="#application.datasource#">
            SELECT Allow_Duplicate_Programs
              FROM Planner_Perf_Types
             WHERE Planner_Perf_Types.Planner_Perf_Types_ID = '#arguments.perfTypeId#'
        </cfquery>
</cfif>

        <!--- performance type does NOT allow duplicates --->
        <cfif local.qPerformanceType.Allow_Duplicate_Programs eq '1'>
            <cfquery name="qCheckDuplicateProgram" datasource="#application.datasource#">
                SELECT	cm.Planner_Perf_Type_ID,
                        cm.Contract_Number, cm.Contract_Title,
                        CONVERT(VARCHAR(10), Contract_Start_Date, 101) as Contract_Start_Date,
                        CONVERT(VARCHAR(10), Contract_End_Date, 101) as Contract_End_Date
                FROM	Contract_Main cm
                WHERE	1 = 0
            </cfquery>
        <cfelse>
            <cfquery name="qCheckDuplicateProgram" datasource="#application.datasource#">
                SELECT	DISTINCT cm.Planner_Perf_Type_ID,
                        cm.Contract_Number, cm.Contract_Title,
                        CONVERT(VARCHAR(10), Contract_Start_Date, 101) as Contract_Start_Date,
                        CONVERT(VARCHAR(10), Contract_End_Date, 101) as Contract_End_Date
                FROM	Contract_Main cm
                INNER JOIN Contract_Products cp
                ON		cp.Contract_Main_ID = cm.Contract_Main_ID
                AND		cp.Deleted = 0
                AND		cp.BSA_Foodservice_Items_Master_ID IN (<cfqueryparam value="#arguments.productList#" CFSQLType="CF_SQL_VARCHAR" list="true">)
                WHERE	cm.Planner_ID =	<cfqueryparam value='#arguments.plannerId#' CFSQLType="CF_SQL_INTEGER">
                AND		cm.Deleted = 0
                AND		cm.Manual_Cancel = 0
                AND cm.contract_status_type_idx != 8
                AND     cm.Contract_Number != <cfqueryparam value="#arguments.contractNumber#" CFSQLType="CF_SQL_VARCHAR">
                AND		cm.Planner_Perf_Type_ID = <cfqueryparam value="#arguments.perfTypeId#" CFSQLType="CF_SQL_INTEGER">
                AND		(
                            (
                                cm.Performance_End_Date  >= <cfqueryparam value="#arguments.startDate#" CFSQLType="CF_SQL_DATE">
                                AND cm.Performance_Start_Date <= <cfqueryparam value="#arguments.endDate#" CFSQLType="CF_SQL_DATE">
                            )
                            OR
                            (
                                cm.Contract_End_Date  >= <cfqueryparam value="#arguments.delStartDate#" CFSQLType="CF_SQL_DATE">
                                AND cm.Contract_Start_Date <= <cfqueryparam value="#arguments.delEndDate#" CFSQLType="CF_SQL_DATE">
                            )
                        )
            </cfquery>
        </cfif>

        <cfreturn serializeJSON(qCheckDuplicateProgram)>
	</cffunction>


	<cffunction name="resetProgram" access="remote" returnFormat="json" output="no">
		<cfargument name="programId"	required="true" type="numeric" />
		<cfargument name="userId" 		required="true" type="string" />

		<cfscript>
			var iProgramId 	= 0;
			var strUserId	= "";

			iProgramId		= arguments.programId;
			strUserId		= arguments.userId;

		</cfscript>

		<cfquery datasource="#application.datasource#">
			UPDATE 	Contract_Main
			SET 	Broker_Approved 			= 0,
					Broker_Approved_Date 		= NULL,
					Broker_User_ID 				= NULL,
					Contract_Status_Type_IDX	= 1,
					edit_agreed_program  		= 0,
					modifying_program 			= 0,
					modifying_user_id 			= NULL,
					Reset_Date 					= GetDate(),
					Reset_User_ID 				= <cfqueryparam value="#arguments.userId#">
			WHERE 	Contract_Main_ID = <cfqueryparam value="#arguments.programId#">

			UPDATE 	Contract_Main_Aux_Data
			SET 	Planner_Target_Trade_Approved         = 0,
					Planner_Target_Trade_Approved_By      = NULL,
					Planner_Target_Trade_Approved_Date    = NULL,
					Planner_Target_Demo_Approved          = 0,
					Planner_Target_Demo_Approved_By       = NULL,
					Planner_Target_Demo_Approved_Date     = NULL,
					Planner_Target_Slotting_Approved      = 0,
					Planner_Target_Slotting_Approved_By   = NULL,
					Planner_Target_Slotting_Approved_Date = NULL
			WHERE 	Contract_Main_ID = <cfqueryparam value="#arguments.programId#">

			DELETE FROM Program_Type_Code_Approval_Info WHERE Program_Id = <cfqueryparam value="#arguments.programId#">
			DELETE FROM Program_Approval_By_Profile     WHERE Program_Id = <cfqueryparam value="#arguments.programId#">
			DELETE FROM Program_Agree                   WHERE ProgramID = <cfqueryparam value="#arguments.programId#">
			DELETE FROM Program_Agree_All_Group         WHERE ProgramID = <cfqueryparam value="#arguments.programId#">
		</cfquery>

		<cfstoredproc procedure="Planner_Slotting_Products_Update" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Planner_ID" value = "0" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#iProgramId#" null="no">
		</cfstoredproc>

		<cfquery name="qProgramInfo" datasource="#application.datasource#">
			SELECT 	Contract_Number, Contract_Title, Planner_ID
			FROM	Contract_Main
			WHERE	Contract_Main_ID = <cfqueryparam value="#iProgramId#" cfsqltype="CF_SQL_INTEGER">
			ORDER BY Contract_Main_ID DESC
		</cfquery>

		<cfset plannerManager      = createObject( "component", "mvc.Models.Planner.PlannerManager" )>
		<cfset qPlanner            = plannerManager.getPlanner( qProgramInfo.Planner_ID )>

		<cfset local.emailAction = "Reset" />
		<cfinclude template="/planners/create/planner_send_email.cfm" />
	</cffunction>

	<cffunction name="getProducts" output="false">

		<cfargument name="productList"		type="string" required="true" />
		<cfargument name="productGroupId" 	type="string" required="false" default="" />

		<cfscript>

			//set local variables
			var lProductList	= "";
			var strGroupId		= "";
			var qGetProducts	= QueryNew("Item, BSA_Foodservice_Items_Master_ID, Description, Net_Weight, Inventory_UM, Sleeves_per_case");
			var bIsGroup		= 0;
			var gGetAttr		= "";


			//assign local variables
			lProductList	= arguments.productList;
			strGroupId		= arguments.productGroupId;

		</cfscript>

		<cfset gGetAttr = getProdAttrData(strGroupId) />
		<cfif gGetAttr.RecordCount and checkIfGroupItems(lProductList) eq 1>
			<cfset bIsGroup = 1 />
		</cfif>

		<cfif trim(lProductList) neq "">

			<!--- if it's a group then get the net weight sum ---->
			<cfif bIsGroup>

				<cfif gGetAttr.Is_PG EQ 1>

					<cfquery name="qGetProducts" datasource="#application.datasource#">
						SELECT	grp.PG_Product_Category_Code as Item,
								grp.PG_Product_Category_ID as BSA_Foodservice_Items_Master_ID,
								grp.PG_Product_Category_Name as Description,
								ISNULL(AVG(CAST(Net_Weight AS FLOAT)), 1) AS Net_Weight,
								Min(Inventory_UM) as Inventory_UM,
								Min(ISNULL(Sleeves_per_case, 1)) as Sleeves_per_case,
								AVG(CAST(Case_Count AS FLOAT)) AS Case_Count
						FROM	PG_Product_Category grp
								LEFT JOIN PG_Product_Members m
								ON	m.PG_Product_Category_ID = grp.PG_Product_Category_ID
								AND	m.Deleted = 0
								LEFT JOIN BSA_Foodservice_Items_Master im ON im.BSA_Foodservice_Items_Master_ID =	m.BSA_Foodservice_Items_Master_ID
						WHERE	grp.PG_Product_Category_ID IN (#listqualify(lProductList, "'")#)
						GROUP BY grp.PG_Product_Category_Code, grp.PG_Product_Category_ID, grp.PG_Product_Category_Name
						ORDER BY grp.PG_Product_Category_Name
					</cfquery>

				<cfelse>

					<cfquery name="qGetProducts" datasource="#application.datasource#">
						SELECT	grp.#gGetAttr.Product_Group_Attribute_Number_Field# as Item,
								grp.#gGetAttr.Product_Group_Attribute_ID_Field# as BSA_Foodservice_Items_Master_ID,
								grp.#gGetAttr.Product_Group_Attribute_Name_Field# as Description,
								ISNULL(AVG(CAST(Net_Weight AS FLOAT)), 1) AS Net_Weight,
								Min(Inventory_UM) as Inventory_UM,
								Min(ISNULL(Sleeves_per_case, 1)) as Sleeves_per_case,
								AVG(CAST(Case_Count AS FLOAT)) AS Case_Count
						FROM	#gGetAttr.Product_Group_Attribute_Table# grp
								LEFT JOIN BSA_Foodservice_Items_Master im ON im.#gGetAttr.Product_Group_Attribute_ID_Field# =	grp.#gGetAttr.Product_Group_Attribute_ID_Field# AND im.Deleted = 0
								AND im.Active_Code = 'A'
						WHERE	grp.#gGetAttr.Product_Group_Attribute_ID_Field# IN (#listqualify(lProductList, "'")#)
						GROUP BY grp.#gGetAttr.Product_Group_Attribute_Number_Field#, grp.#gGetAttr.Product_Group_Attribute_ID_Field#, grp.#gGetAttr.Product_Group_Attribute_Name_Field#
						ORDER BY grp.#gGetAttr.Product_Group_Attribute_Name_Field#
					</cfquery>

				</cfif>

			<cfelse>

				<cfquery name="qGetProducts" datasource="#application.datasource#">
					SELECT	Item, BSA_Foodservice_Items_Master_ID,Description, Net_Weight, Inventory_UM, ISNULL(Sleeves_per_case, 1) as Sleeves_per_case,
						CAST(Case_Count AS FLOAT) AS Case_Count
					FROM	BSA_Foodservice_Items_Master
					WHERE	Deleted = 0
					<cfif listlen(lProductList) GT 0>
						AND		BSA_Foodservice_Items_Master_ID IN (#listqualify(lProductList, "'")#)
					<cfelse>
						AND 1 =	2
					</cfif>
					ORDER BY Description
				</cfquery>

			</cfif>

		</cfif>

		<cfreturn qGetProducts>

	</cffunction>

	<cffunction name="isEDLP" output="false" returntype="boolean">

		<cfargument name="perfTypeId" type="numeric" required="true" />

		<cfscript>

			//set local variables
			var bIsEDLP	= 0;

		</cfscript>

		<cfquery name="qCheckEDLP" datasource="#application.datasource#">
			SELECT	1
			FROM	Planner_Perf_Types
			WHERE	Planner_Perf_Types_ID = <cfqueryparam value="#arguments.perfTypeId#" CFSQLType="CF_SQL_INTEGER">
			AND		Everyday_Price = 1
		</cfquery>

		<cfif qCheckEDLP.RecordCount>
			<cfset bIsEDLP = 1 />
		</cfif>

		<cfreturn bIsEDLP />

	</cffunction>

	<cffunction name="existsEDLP" output="false" returntype="boolean">

		<cfscript>

			//set local variables
			var bExistsEDLP	= 0;
			var qCheckEDLPExists = "";

		</cfscript>

		<cfset useLakebaseForqCheckEDLPExists = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_perf_types")>
<cfif useLakebaseForqCheckEDLPExists>
	<cftry>
		<cfset qCheckEDLPExists = application.oLakebase.toQuery(
			application.oLakebase.selectRows("planner_perf_types", {
				"everyday_price" = "eq.1",
				"deleted" = "eq.0",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckEDLPExists = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckEDLPExists>
<cfquery name="qCheckEDLPExists" datasource="#application.datasource#">
			SELECT	1
			FROM	Planner_Perf_Types
			WHERE	Everyday_Price = 1
			AND		Deleted = 0
		</cfquery>
</cfif>

		<cfif qCheckEDLPExists.RecordCount>
			<cfset bExistsEDLP = 1 />
		</cfif>

		<cfreturn bExistsEDLP />

	</cffunction>

	<cffunction name="getPlannerProgramDates" output="false" returntype="query">
		<cfargument name="plannerid" required="true" type="numeric" />
		<cfargument name="contract_main_id" required="true" type="numeric" />

		<cfset useLakebaseForlocal_qGetDates = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForlocal_qGetDates>
	<cftry>
		<cfset local.qGetDates = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#arguments.contract_main_id#",
				"planner_id" = "eq.#arguments.plannerid#",
				"select" = "contract_start_date,contract_end_date,delivery_start_date,delivery_end_date"
			}), "contract_start_date,contract_end_date,delivery_start_date,delivery_end_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_qGetDates = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_qGetDates>
<cfquery name="local.qGetDates" datasource="#application.datasource#">
			SELECT  Contract_Start_Date, Contract_End_Date, Delivery_Start_Date, Delivery_End_Date
			FROM    Contract_Main
			WHERE	Contract_Main_ID 		= '#arguments.contract_main_id#'
			AND     Planner_Id 				= '#arguments.plannerid#'
		</cfquery>
</cfif>

		<cfreturn local.qGetDates />

	</cffunction>

	<!--- update program dates when drag &  dropped : extend or move --->
	<cffunction name="updatePlannerProgram" output="false" returntype="boolean">
		<cfargument name="data" required="true" type="struct" />

		<cfset local.qGetDates = getPlannerProgramDates(arguments.data.plannerid, arguments.data.contract_main_id) />

		<cfquery name="local.qUpdate" datasource="#application.datasource#">
			UPDATE	Contract_Main
			SET		Performance_Start_Date 	= '#dateformat(arguments.data.start_date, "m/d/yyyy")#',
					Performance_End_Date    = '#dateformat(arguments.data.end_date, "m/d/yyyy")#',
					Delivery_Start_Date     = '#dateformat(arguments.data.delivery_start_date, "m/d/yyyy")#',
					Delivery_End_Date       = '#dateformat(arguments.data.delivery_end_date, "m/d/yyyy")#',
					Contract_Start_Date     = '#dateformat(arguments.data.delivery_start_date, "m/d/yyyy")#',
					Contract_End_Date       = '#dateformat(arguments.data.delivery_end_date, "m/d/yyyy")#'
			WHERE	Contract_Main_ID 		= '#arguments.data.contract_main_id#'
			AND     Planner_Id 				= '#arguments.data.plannerid#'
		</cfquery>

		<cfif arguments.data.indirect_planner >
			<cfstoredproc procedure="Planner_Program_Volume_Save_To_Volume_Plan_Indirect" datasource="#application.datasource#" returnCode = "yes">
				<cfprocparam type="in" 	cfsqltype="cf_sql_integer"  value="#arguments.data.parent_planner_id#">
				<cfprocparam type="in" 	cfsqltype="cf_sql_integer" 	value="#arguments.data.contract_main_id#">
			</cfstoredproc>
		<cfelse>
			<cfstoredproc procedure="Planner_Program_Date_Change_Update_Volume_Plan" datasource="#application.datasource#" returnCode = "yes">
				<cfprocparam type="in" 	cfsqltype="cf_sql_integer"  value="#arguments.data.contract_main_id#">
				<cfprocparam type="in" 	cfsqltype="cf_sql_date"   	value="#dateformat(local.qGetDates.Delivery_Start_Date,  'm/d/yyyy')#">
				<cfprocparam type="in" 	cfsqltype="cf_sql_date"   	value="#dateformat(local.qGetDates.Delivery_End_Date,    'm/d/yyyy')#">
				<cfprocparam type="in" 	cfsqltype="cf_sql_varchar" 	value="UPDATE">
			</cfstoredproc>
		</cfif>

		<cfreturn true />
	</cffunction>

	<!--- Copy program in a planner --->
	<cffunction name="copyPlannerProgram" output="false" returntype="query">
		<cfargument name="data" required="true" type="struct" />

		<cfset local.result = {}>
		<cfset local.qGetDates = getPlannerProgramDates(arguments.data.plannerid, arguments.data.contract_main_id) />

		<cfstoredproc procedure="usp_copy_program" datasource="#application.datasource#" returnCode = "yes">
			<cfprocparam type="in" 	cfsqltype="cf_sql_integer "	value="#arguments.data.contract_main_id#">
			<cfprocparam type="in" 	cfsqltype="cf_sql_varchar "	value="">
			<cfprocparam type="in" 	cfsqltype="cf_sql_bit"		value="0">
			<cfprocparam type="in" 	cfsqltype="cf_sql_bit"		value="0">
			<cfprocparam type="in" 	cfsqltype="cf_sql_bit"		value="0">
			<cfprocparam type="in" 	cfsqltype="cf_sql_integer"	value="0">
			<cfprocparam type="in" 	cfsqltype="cf_sql_varchar"	value="">
			<cfprocparam type="in" 	cfsqltype="cf_sql_varchar"	value="#arguments.data.user_id#">
			<cfprocparam type="out"	cfsqltype="cf_sql_integer"	variable="renewed_program_id">
			<cfprocparam type="in" 	cfsqltype="cf_sql_bit"		value="0">
			<cfprocparam type="out"	cfsqltype="cf_sql_integer"	variable="is_group_deal">
			<cfprocparam type="in" 	cfsqltype="cf_sql_bit"		value="0">
			<cfprocparam type="in" 	cfsqltype="cf_sql_bit"		value="0">
		</cfstoredproc>

		<cfquery name="local.qCopyProgramUpdateDates" datasource="#application.datasource#">
			UPDATE	Contract_Main
			SET		Performance_Start_Date 	= '#dateformat(arguments.data.start_date, "m/d/yyyy")#',
					Performance_End_Date    = '#dateformat(arguments.data.end_date, "m/d/yyyy")#',
					Delivery_Start_Date     = '#dateformat(arguments.data.delivery_start_date, "m/d/yyyy")#',
					Delivery_End_Date       = '#dateformat(arguments.data.delivery_end_date, "m/d/yyyy")#',
					Contract_Start_Date     = '#dateformat(arguments.data.delivery_start_date, "m/d/yyyy")#',
					Contract_End_Date       = '#dateformat(arguments.data.delivery_end_date, "m/d/yyyy")#',
					Planner_Perf_Type_ID    = '#arguments.data.planner_perf_id#',
					Planner_ID 				= '#arguments.data.plannerid#'
			WHERE 	Contract_Main_ID		= '#renewed_program_id#'
		</cfquery>

		<cfif arguments.data.indirect_planner >
			<cfstoredproc procedure="Planner_Program_Volume_Save_To_Volume_Plan_Indirect" datasource="#application.datasource#" returnCode = "yes">
				<cfprocparam type="in" 	cfsqltype="cf_sql_integer"  value="#arguments.data.parent_planner_id#">
				<cfprocparam type="in" 	cfsqltype="cf_sql_integer" 	value="#renewed_program_id#">
			</cfstoredproc>
		<cfelse>
			<cfstoredproc procedure="Planner_Program_Date_Change_Update_Volume_Plan" datasource="#application.datasource#" returnCode = "yes">
				<cfprocparam type="in" 	cfsqltype="cf_sql_integer" 	value="#renewed_program_id#">
				<cfprocparam type="in" 	cfsqltype="cf_sql_date"    	value="#dateformat(local.qGetDates.Delivery_Start_Date, 'm/d/yyyy')#">
				<cfprocparam type="in" 	cfsqltype="cf_sql_date"    	value="#dateformat(local.qGetDates.Delivery_End_Date,   'm/d/yyyy')#">
				<cfprocparam type="in" 	cfsqltype="cf_sql_varchar" 	value="COPY">
			</cfstoredproc>
		</cfif>

		<cfquery name="qCopyProgramUpdatePrice" datasource="#application.datasource#">
			DELETE FROM Contract_group_merchant_info  WHERE Program_id = '#renewed_program_id#'

			INSERT INTO Contract_group_merchant_info (Program_id, Group_id, Merchant_price, Merchant_quantity, Uom, Everyday_price, Everyday_low_price, Everyday_unit_price, Everyday_Low_Price_UOM)
			SELECT 	'#renewed_program_id#',
					Group_id, Merchant_price, Merchant_quantity, Uom, Everyday_price, Everyday_low_price, Everyday_unit_price, Everyday_Low_Price_UOM
			FROM 	Contract_group_merchant_info
			WHERE 	Program_id = '#arguments.data.contract_main_id#'
		</cfquery>

		<cfset local.result = getProgramPlannerData(renewed_program_id)>
		<cfreturn local.result />
	</cffunction>

	<cffunction name="getDefaultProductUOM" output="false" returntype="numeric">

		<cfargument name="defaultUOM"			required="true" type="numeric" />
		<cfargument name="progDefUOM"			required="true" type="numeric" />
		<cfargument name="productUOM"			required="true" type="string" />

		<cfscript>

			//set local variables
			var retVar	= arguments.defaultUOM;

		</cfscript>

		<cfif arguments.progDefUOM eq 1>  <!---  1 = Product UOM --->
			<cfif arguments.productUOM eq 'LB' OR arguments.productUOM eq 'LBS'>
				<cfset retVar = 2 />
			<cfelse>
				<cfset retVar = 1 />
			</cfif>
		<cfelse>						<!---  2 = Planner Template  --->
			<cfif arguments.defaultUOM eq 2>
				<cfset retVar = 2 />
			<cfelse>
				<cfset retVar = 1 />
			</cfif>
		</cfif>

		<cfreturn retVar />

	</cffunction>

	<cffunction name="convertFromCSToUnits" output="false" returntype="numeric">

		<cfargument name="nVal"			required="true" type="numeric" />
		<cfargument name="nUnits"		required="true" type="numeric" />
		<cfargument name="nValUom"		required="false" type="numeric" default="1" />
		<cfargument name="nSleeves"		required="false" type="any" default="0" />


		<cfscript>

			//set local variables
			var retVar	= 0;

		</cfscript>


		<cfif arguments.nUnits neq 0>
			<cfif arguments.nValUom eq 5> <!--- EA - no need to convert --->
				<cfset retVar = arguments.nVal />
			<cfelseif arguments.nValUom eq 7><!--- SL -> CS -> EA ---->
					<cfset retVar = (arguments.nVal * arguments.nSleeves) / arguments.nUnits />
			<cfelseif arguments.nValUom eq 1><!--- CS -> EA ---->
					<cfset retVar = arguments.nVal / arguments.nUnits />
			</cfif>
		</cfif>

		<cfreturn retVar />

	</cffunction>

	<cffunction name="getAvailableBudgets" output="false" returntype="query">

		<cfargument name="programId"			required="true" type="numeric" />

			<cfstoredproc   procedure="Adv_Budget_Get_Pgm_Budget_List"
							dataSource="#application.datasource#"
							returnCode="Yes"
							debug="Yes">
				<cfprocresult name=qBudgets>
				<cfprocparam type="in" cfsqltype = cf_sql_integer value="#arguments.programId#" dbVarName = @program_id>
				<cfprocparam type="in" cfsqltype = cf_sql_integer value="0" dbVarName = @user_position_id>
				<cfprocparam type="in" cfsqltype = cf_sql_integer value="0" dbVarName = @new_template_id>
				<cfprocparam type="in" cfsqltype = cf_sql_integer value="0" dbVarName = @new_business_segment_id>
				<cfprocparam type="in" cfsqltype = cf_sql_integer value="#application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetSelectionRequired()#" dbVarName = @budget_required_complete_span>
			</cfstoredproc>

		<cfreturn qBudgets />

	</cffunction>

	<cffunction name="getProgramSelectedBudgets" output="false" returntype="query">

		<cfargument name="programId"			required="true" type="numeric" />

			<cfquery name="qProgramBudgets" datasource="#application.datasource#">
				SELECT  a.Budget_ID, bc.Is_Fiscal, bc.partial_year
				FROM    Budget_Program_Selection a
				INNER JOIN Budget b ON b.Budget_ID = a.Budget_ID
				LEFT JOIN Budget_Class bc ON b.Budget_Class_ID = bc.Budget_Class_ID
				WHERE Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
			</cfquery>

		<cfreturn qProgramBudgets />

	</cffunction>

	<cffunction name="getPlannerProgramPerfTypeInfo" access="public" returntype="query" output="false">
		<cfargument name="templateId" type="string" required="false" default="0" />
		<cfargument name="plannerType" type="string" required="false" default="direct" />
		<cfargument name="programPerfId" type="string" required="false" default="0" />
		<cfargument name="programTemplateId" type="string" required="true" />

		<cfscript>
			//set local variables
			var nId = 0;
			var qReturnData = "";

			//assign local variables
			nId = arguments.templateId;

		</cfscript>

		<cfquery name="qReturnData" datasource="#application.datasource#">
			SELECT 	DISTINCT Planner_Perf_Types.*
  			FROM 	Planner_Perf_Types
  					LEFT JOIN Planner_Template_Perf_Types on Planner_Template_Perf_Types.Planner_Perf_Types_ID = Planner_Perf_Types.Planner_Perf_Types_ID
  					and Planner_Template_Perf_Types.Planner_Template_ID = #nId# and Planner_Template_Perf_Types.Deleted = 0
					left join Template_Planner_Settings_Perf_Types on Template_Planner_Settings_Perf_Types.Planner_Perf_Types_ID = Planner_Perf_Types.Planner_Perf_Types_ID
					and Template_Planner_Settings_Perf_Types.First_Parent_ID = (select First_Parent_ID from Program_Control_Panel_Options where ProgramControl_Panel_Options_ID = '#arguments.programTemplateId#')
					and Template_Planner_Settings_Perf_Types.Deleted = 0
 			WHERE 	Planner_Perf_Types.Deleted = 0
					<cfif val(arguments.programPerfId) neq 0>
						AND (Active = 1 OR Planner_Perf_Types.Planner_Perf_Types_ID = '#arguments.programPerfId#')
						AND (Accrual = 0 OR Planner_Perf_Types.Planner_Perf_Types_ID = '#arguments.programPerfId#')
					<cfelse>
						AND Active = 1
						AND Accrual = 0
					</cfif>
					<cfif arguments.plannerType eq "inDirect">
						AND Planner_Template_Perf_Types.Indirect_Selected = 1
					<cfelse>
						AND (
						  		(Planner_Template_Perf_Types.Selected = 1 AND Template_Planner_Settings_Perf_Types.Planner_Perf_Types_ID IS NOT NULL)
						<cfif val(arguments.programPerfId) neq 0>
								OR Planner_Perf_Types.Planner_Perf_Types_ID = '#arguments.programPerfId#'
						</cfif>
							)
					</cfif>

			ORDER BY Sort_Order
		</cfquery>

		<cfreturn qReturnData />

	</cffunction>

	<cffunction name="getProductVolumeForIndirect" output="true">

		<cfargument name="data" required="true" type="struct" />

		<cfscript>

			//set local variables
			var stData 				= structNew();
			var local.query			= "";
			var nProgramID			= 0;
			var nPlannerID			= 0;
			var lProductList		= "";
			var nProduct_List_Type	= 0;

			//assign local variables
			stData				= arguments.data;
			nProgramID			= stData.programId;
			nPlannerID			= stData.plannerId;
			lProductList		= stData.Product_List;
			nProductListType	= stData.Product_List_Type;

		</cfscript>

		<cfquery name="qGetVolume" datasource="#application.datasource#">
			SET NOCOUNT ON
			declare @Contract_Main_ID int = #nProgramID#,
					@Planner_ID int = #nPlannerID#,
					@product_group_level INT = 0

			IF OBJECT_ID('tempdb..##tmp_group_members') IS NOT NULL
			DROP TABLE ##tmp_group_members

			CREATE TABLE ##tmp_group_members (
				Product_ID uniqueidentifier,
				Include_In_Margin bit
			)

			IF OBJECT_ID('tempdb..##tmp_planner_program_products') IS NOT NULL
			DROP TABLE ##tmp_planner_program_products

			CREATE TABLE ##tmp_planner_program_products (
				Product_Group_Level_ID int,
				Product_Group_ID uniqueidentifier,
				Product_ID uniqueidentifier
			)

		 /*  Get products eligible for this program */
		 /* INSERT INTO ##tmp_group_members (Product_ID, Include_In_Margin) */
			EXEC SP_CAPTURE_ALL_FOR_GROUPS @Contract_Main_ID, 0, 0, 1, ##tmp_group_members



			<!--- Group Entries START--->
			IF OBJECT_ID('tempdb..##tmp_planner_program_groups') IS NOT NULL
			DROP TABLE ##tmp_planner_program_groups

			CREATE TABLE ##tmp_planner_program_groups (
				Product_Group_Level_ID int,
				Product_Group_ID uniqueidentifier,
				Product_ID uniqueidentifier
			)

			<!--- Loop and insert into ##tmp_planner_program_groups --->
			<cfif trim(nProductListType) neq "" and trim(nProductListType) neq 0>
				<cfloop index="idx" list="#lProductList#">
					insert into ##tmp_planner_program_groups (Product_Group_Level_ID, Product_Group_ID)
					values ('#nProductListType#','#idx#')
				</cfloop>

				<!--- get group members --->
				insert into ##tmp_planner_program_products (Product_Group_Level_ID, Product_Group_ID, Product_ID)
				select	grp.Product_Group_Level_ID, grp.Product_Group_ID, m.BSA_Foodservice_Items_Master_ID
				from	##tmp_planner_program_groups grp
				inner join All_Product_Group_Type_Members m on m.Product_Group_ID = grp.Product_Group_ID and m.Product_Group_Level_ID = grp.Product_Group_Level_ID
				where	exists (select 1 from ##tmp_group_members p where p.Product_ID = m.BSA_Foodservice_Items_Master_ID) <!--- Only get member that are eligible for this program --->

				set @product_group_level = #nProductListType#

			</cfif>
			<!--- Group Entries END--->

			<!--- Product Entries START--->
			<!--- Loop and insert into ##tmp_planner_program_groups--->
			<cfif trim(nProductListType) eq "" or trim(nProductListType) eq 0>

				<cfloop index="idx" list="#lProductList#">
					insert into ##tmp_planner_program_products (Product_Group_Level_ID, Product_Group_ID, Product_ID)
					values (0, '#idx#','#idx#')
				</cfloop>

			</cfif>
			<!--- Product Entries END--->

			EXEC Get_Program_Product_Volume_Forecast @Contract_Main_ID, 'EDIT-FORECAST', 'ITEM', null, @product_group_level, @Planner_ID, '##tmp_planner_program_products'

			IF OBJECT_ID('tempdb..##tmp_group_members') IS NOT NULL
			DROP TABLE ##tmp_group_members

			IF OBJECT_ID('tempdb..##tmp_planner_program_groups') IS NOT NULL
			DROP TABLE ##tmp_planner_program_groups

			IF OBJECT_ID('tempdb..##tmp_planner_program_products') IS NOT NULL
			DROP TABLE ##tmp_planner_program_products

		</cfquery>

		<cfreturn qGetVolume />

	</cffunction>


	<cffunction name="checkProgramInactives" output="true" returntype="string" access="remote">
		<cfargument name="programId"	required="true" type="numeric" />

		<cfquery name="qCheckProgramInactives" datasource="#application.datasource#">
			SELECT	1
			FROM 	Program_Copy_Removed_Product
			WHERE	Contract_Main_ID = <cfqueryparam value="#form.programId#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfreturn qCheckProgramInactives.recordCount />
	</cffunction>

	<cffunction name="checkDuplicateProgramBasedOnTemplate" access="remote" returnFormat="json" output="no">
		<cfargument name="plannerId"	required="true" type="numeric" />
		<cfargument name="programId"	required="true" type="numeric" />


		<cfset DuplicateProgramIDList = getDuplicateProgramList(arguments.plannerId, arguments.programId) />

		<cfreturn serializeJSON(DuplicateProgramIDList)>

	</cffunction>

	<cffunction name="getDuplicateProgramList" output="true">

		<cfargument name="plannerId"	required="true" type="numeric" />
		<cfargument name="programId"	required="true" type="numeric" />

		<cfset cryp.value = arguments.programId />
		<cfquery NAME="GetContractInfo" datasource="#application.datasource#">
			SELECT 	Contract_Start_Date,
					Contract_End_Date,
					Revision_Of_Contract_Main_ID,
					Contract_Number,
					Contract_Title,
					isnull(Fiscal_Year, '') AS Fiscal_Year,
					ProgramType_ID
			FROM    Contract_Main
			WHERE   Contract_Main_ID = '#cryp.value#'
		</cfquery>

		<cfset getProgramTemplateInfo.ProgramType_ID = GetContractInfo.ProgramType_ID />
		<cfset form.BUSINESS_CONSIDERATIONS = "" />
		<cfset request.skip_cfflush = "yes" />
		<cfset url.anyStatus = 0 />
		<cfset url.plannerId = arguments.plannerId />

		<cfinclude template="/Common_Files/Contracts/duplicate_program_check.cfm">
		<cfif len(ltrim(trim(DuplicateProgramIDList))) eq 0>
			<cfset DuplicateProgramIDList = "0" />
		</cfif>

		<cfreturn DuplicateProgramIDList />

	</cffunction>

	<cffunction name="getDuplicatePlannerProgramList" access="remote" returnFormat="json" output="false">
		<cfargument name="plannerId"	required="true" type="numeric" />
		<cfparam name="duplicateprogram" default="false" />
		<cfset lProgramList = "" />
		<cfset var lDupCheckedList = ""/>

		<!--- ONLY CHECK RFA.  Duplicate check is in the approval process so if it is approved then ignore it Mark S :: 115090  performance fix --->
		<cfquery NAME="qGetProgramList" datasource="#application.datasource#">
			SELECT	distinct Contract_Main_ID
			FROM    Contract_Main
			WHERE   Planner_ID = '#arguments.plannerId#'
				AND		Deleted = 0  
				AND 	Contract_Status_Type_IDX = 2   <!--- Mark S :: 115090  performance fix --->
				AND 	isnull(manual_cancel, 0) = 0
				AND		isnull(Flagged_As_Purged, 0) = 0
				AND 	isnull(Force_Expiration_Flag, 0) = 0
		</cfquery>

		<cfloop query="qGetProgramList">
			<cfset lDupCheckedList = ListAppend(lDupCheckedList,qGetProgramList.Contract_Main_ID)>
			<cfset cryp.value = Contract_Main_ID />
			<!---duplicate_program_check.cfm needs the GetContractInfo query --->
			<cfquery NAME="GetContractInfo" datasource="#application.datasource#">
				SELECT 	Contract_Start_Date,
						Contract_End_Date,
						Revision_Of_Contract_Main_ID,
						Contract_Number,
						Contract_Title,
						isnull(Fiscal_Year, '') AS Fiscal_Year,
						ProgramType_ID
				FROM    Contract_Main
				WHERE   Contract_Main_ID = '#cryp.value#' 
						
			</cfquery>

			<cfset getProgramTemplateInfo.ProgramType_ID = GetContractInfo.ProgramType_ID />
			<cfset form.BUSINESS_CONSIDERATIONS = "" />
			<cfset request.skip_cfflush = "yes" />
			<cfset url.anyStatus = 1 />
			<cfset url.plannerId = arguments.plannerId />
			<cfset url.ComingFromPlanner = 1>
			<cfinclude template="/Common_Files/Contracts/duplicate_program_check.cfm">

			<cfif duplicateprogram neq "false">
				<!--- Both the Prg we started with and all of it's matches go into the dup list.	Mark S :: 115090  performance fix --->
				<cfset lProgramList = ListAppend(lProgramList,DuplicateProgramIDList)>
				<cfset lProgramList = ListAppend(lProgramList,qGetProgramList.Contract_Main_ID)>
			</cfif>


		</cfloop>
		<cfset lProgramList = application.util.list.removeDupes(lProgramList)>

		<cfreturn serializeJSON(lProgramList)>

	</cffunction>


    <cffunction name="getTotalEstimatedPayment" returnFormat="json" output="false">
        <cfargument name="contract_number" required="true">

        <cfquery name="local.query" datasource="#application.datasource#">
            SELECT Sum( Paid_Amount ) AS Paid_Amount
              FROM PAYMENT_HISTORY_DETAILS
             WHERE Contract_Number = '#form.contract_number#'
        </cfquery>

        <cfreturn local.query.paid_amount>
    </cffunction>


    <cffunction name="getTotalBudget" returnFormat="json" output="false">
        <cfargument name="contract_number" required="true">

        <!--- Cloned logic from \Common_Files\contracts\display_view_program_html.cfm --->
        <cfquery name="local.query" datasource="#application.datasource#">
            DECLARE @Committed_Dollar decimal(20, 4),
                    @Actual_Dollar decimal(20, 4)

            SELECT @Committed_Dollar = SUM(pg.Committed_Dollar),
                    @Actual_Dollar = SUM(pg.Actual_Dollar)
              FROM  Budget_Position_Program pg
             WHERE  pg.Contract_Number = '#form.contract_number#'

            SELECT  @Committed_Dollar = ISNULL(@Committed_Dollar, 0) + ISNULL(SUM(pg.Committed_Dollar), 0),
                    @Actual_Dollar = ISNULL(@Actual_Dollar, 0) + ISNULL(SUM(pg.Actual_Dollar), 0)
              FROM  Budget_Distributor_Program pg
             WHERE  pg.Contract_Number = '#form.contract_number#'

            SELECT @Committed_Dollar as Committed_Dollar, @Actual_Dollar as Actual_Dollar
        </cfquery>

        <cfreturn { Committed: local.query.Committed_Dollar, Actual: local.query.Actual_Dollar }>
    </cffunction>


    <cffunction name="getTotalEstimatedTrade" returnFormat="json" output="false">
        <cfargument name="program_id" required="true" type="numeric">

        <cfquery name="local.query" datasource="#application.datasource#">
            SELECT Program_Spend
              FROM CONTRACT_MAIN_AUX_DATA
             WHERE Contract_Main_Id = '#arguments.program_id#'
        </cfquery>

        <cfreturn local.query.program_spend>
    </cffunction>


    <cffunction name="getDocumentCount"  access="remote" returnFormat="json" output="false">
			<cfargument name="program_id" required="true" type="numeric">

				<cfquery name="qDocuments" datasource="#application.datasource#">
					SELECT  count(*) AS TotalDocuments
					FROM    Contract_Attachments
					WHERE   Program_ID =  '#arguments.program_id#'
					AND Deleted = 0
				</cfquery>

			<cfreturn qDocuments>

	</cffunction>

	<cffunction name="getQualificationRequired"  access="remote" returnFormat="json" output="false">
		<cfargument name="templateId" required="true" type="numeric">
		<cfargument name="programId" required="true" type="numeric">

		<cfset rQualificationValid = 1 />

		<cfset useLakebaseForqCheckTemplate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qualification_template_mapping")>
<cfif useLakebaseForqCheckTemplate>
	<cftry>
		<cfset qCheckTemplate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qualification_template_mapping", {
				"template_id" = "eq.#arguments.templateId#",
				"answer_required" = "eq.1",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckTemplate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckTemplate>
<cfquery name="qCheckTemplate" datasource="#application.datasource#">
		 	SELECT 	*
			FROM  	Qualification_Template_Mapping
			WHERE 	Template_Id = '#arguments.templateId#'
			AND 	Answer_Required = 1
			AND		Deleted = 0
		</cfquery>
</cfif>

		<cfif qCheckTemplate.RecordCount>
			<cfquery name="qCheckRequiredQualification" datasource="#application.datasource#">
				SELECT	*
				FROM 	Program_Qualifications_Info
				WHERE 	Program_ID = '#arguments.programId#'
				AND		Program_Qualification_ID in (#QuotedValueList(qCheckTemplate.Program_Qualification_Id)#)
				AND		Deleted = 0
			</cfquery>

			<cfif not qCheckRequiredQualification.RecordCount>
				<cfset rQualificationValid = 0 />
			</cfif>
		</cfif>

		<cfreturn rQualificationValid />
	</cffunction>

    <cffunction name="getEverydayMerch" access="remote" returnFormat="json" output="false">
		<cfargument name="program_id" required="true" type="numeric">

		<cfreturn serializeJSON( getUnitPrice( arguments.program_Id ), "struct" )>
	</cffunction>

	<cffunction name="convertVolume" output="false" returntype="numeric">

		<cfargument name="nVal"				required="true" type="numeric" />
		<cfargument name="nUOM"				required="true" type="numeric" />
		<cfargument name="nToUOM"			required="true" type="numeric" />
		<cfargument name="nNetWeight"		required="false" type="any" default="1" />
		<cfargument name="nCaseCount"		required="false" type="any" default="1" />
		<cfargument name="nSleeves"			required="false" type="any" default="0" />

		<cfscript>

			//set local variables
			var retVar	= arguments.nVal;

		</cfscript>

		<!--- CS --->
		<cfif arguments.nUOM eq 1>
			<!--- To LB --->
			<cfif arguments.nToUOM eq 2>
				<cfset retVar = arguments.nVal * arguments.nNetWeight />
			<!--- To EA --->
			<cfelseif arguments.nToUOM eq 5>
				<cfset retVar = arguments.nVal * arguments.nCaseCount />
			<!--- To SL --->
			<cfelseif arguments.nToUOM eq 7>
				<cfset retVar = arguments.nVal * arguments.nSleeves />
			<cfelse>
				<cfset retVar = arguments.nVal />
			</cfif>
		<!--- LB --->
		<cfelseif arguments.nUOM eq 2>
			<!--- To CS --->
			<cfif arguments.nToUOM eq 1>
				<cfset retVar = arguments.nVal / arguments.nNetWeight />
			<!--- To CS to EA --->
			<cfelseif arguments.nToUOM eq 5>
				<cfset retVar = (arguments.nVal / arguments.nNetWeight) * arguments.nCaseCount />
			<!--- To CS to SL --->
			<cfelseif arguments.nToUOM eq 7>
				<cfset retVar = (arguments.nVal / arguments.nNetWeight) * arguments.nSleeves />
			<cfelse>
				<cfset retVar = arguments.nVal />
			</cfif>
		<!--- EA --->
		<cfelseif arguments.nUOM eq 5>
			<!--- To CS --->
			<cfif arguments.nToUOM eq 1>
				<cfset retVar = arguments.nVal / arguments.nCaseCount />
			<!--- To CS to LB --->
			<cfelseif arguments.nToUOM eq 2>
				<cfset retVar = (arguments.nVal / arguments.nCaseCount)  * arguments.nNetWeight />
			<!--- To CS to SL --->
			<cfelseif arguments.nToUOM eq 7>
				<cfset retVar = (arguments.nVal / arguments.nCaseCount) * arguments.nSleeves />
			<cfelse>
				<cfset retVar = arguments.nVal />
			</cfif>
		<!--- SL --->
		<cfelseif arguments.nUOM eq 7>
			<!--- To CS --->
			<cfif arguments.nToUOM eq 1>
				<cfset retVar = arguments.nVal / arguments.nSleeves />
			<!--- To CS to LB --->
			<cfelseif arguments.nToUOM eq 2>
				<cfset retVar = (arguments.nVal / arguments.nSleeves)  * arguments.nNetWeight />
			<!--- To CS to EA --->
			<cfelseif arguments.nToUOM eq 5>
				<cfset retVar = (arguments.nVal / arguments.nSleeves) * arguments.nCaseCount />
			<cfelse>
				<cfset retVar = arguments.nVal />
			</cfif>
		</cfif>

		<cfreturn retVar />

	</cffunction>

</cfcomponent>