<cfcomponent displayname="layered_program_approval" hint="layered_program_approval" extends="components.programs.Approval.ApprovalManager">

<cffunction name="getProgramSettngs" access="public" returntype="query">
	<cfargument name="ProgramType_ID" type="string" required="true" />
<CFQUERY NAME="qgetProgramSettngs" datasource="#application.datasource#">
	SELECT	*
	FROM	dbo.Program_Control_Panel_Options
	WHERE ProgramControl_Panel_Options_ID = <cfqueryparam value="#arguments.ProgramType_ID#" cfsqltype="cf_sql_varchar">
</CFQUERY>
<cfreturn qgetProgramSettngs />
</cffunction>

<cffunction name="getApprovalSettings" access="public" returntype="query">
	<cfargument name="ProgramType_ID" type="string" required="true" />
	<cfargument name="profile_ID" type="string" required="true" />
	<cfargument name="forbidtype" type="string" required="true" />
	<cfargument name="forbidaccesstype" type="string" required="true" />
<cfquery name="qgetApprovalSettings" datasource="#application.datasource#">
	select 	distinct template_id
						from 	Profile_Forbidden_Template
						where 	Deleted = 0
								AND Template_ID = <cfqueryparam value="#arguments.ProgramType_ID#" cfsqltype="cf_sql_varchar">
								AND Forbid_Type = <cfqueryparam value="#arguments.forbidType#" cfsqltype="cf_sql_varchar">
								AND	Forbid_Access_Type = <cfqueryparam value="#arguments.forbidaccesstype#" cfsqltype="cf_sql_varchar">
								AND profile_id = <cfqueryparam value="#arguments.profile_ID#" cfsqltype="cf_sql_varchar">
</cfquery>
<cfreturn qgetApprovalSettings />
</cffunction>

<cffunction name="getAllProductMarginsHM" access="public" returntype="query">
	<cfargument name="program_id" type="string" required="true" />
	<cfargument name="margin_type" type="string" required="true" />
	<cfargument name="formCopy" type="struct" required="false"/>
	<cfargument name="excludeMarginItems" type="boolean" required="false" default="0" />
	<cfargument name="margin_version" type="string" required="false" default="current" />
	<cfargument name="Operator_program" type="boolean" required="false" default="0"/>
	<cfargument name="GlobalUom" type="numeric" required="false" default="0"/>

	<cfif isDefined("arguments.formCopy.AgreeList")>
		<cfif arguments.formCopy.AgreeList neq "">
			<cfset agreeList = arguments.formCopy.AgreeList />
		<cfelse>
			<cfset agreeList = arguments.formCopy.preAgreeList />
		</cfif>
	</cfif>
	<cfif isDefined("arguments.formCopy.ApproveList")>
		<cfif arguments.formCopy.ApproveList neq "">
			<cfset approveList = arguments.formCopy.ApproveList />
		<cfelse>
			<cfset approveList = arguments.formCopy.preApproveList />
		</cfif>
	</cfif>
	<cfif isDefined("arguments.formCopy.RestrictedList")>
		<cfif arguments.formCopy.RestrictedList neq "">
			<cfset restrictedList = arguments.formCopy.RestrictedList />
		<cfelse>
			<cfset restrictedList = arguments.formCopy.preRestrictedList />
		</cfif>
	</cfif>
		<CFQUERY NAME="qDropTmp" datasource="#application.datasource#">
		    /*** components\programs\Approval\layered_program_approval.cfc - getAllProductMargins() [ arguments.margin_type EQ 1 ] ***/

			IF OBJECT_ID('TEMPDB..##Program_Companion_TC') IS NOT NULL
			DROP TABLE ##Program_Companion_TC

			IF OBJECT_ID('TEMPDB..##Program_NO_Companion_TC') IS NOT NULL
			DROP TABLE ##Program_NO_Companion_TC

		    	IF OBJECT_ID('TEMPDB..##Contract_products_TMP') IS NOT NULL
			DROP TABLE ##Contract_products_TMP

		</CFQUERY>
			<!--- 	HM	HM	HM *******************************************************~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~				--->
		<CFQUERY NAME="qgetAllProductMargins" datasource="#application.datasource#">
		    /*** components\programs\Approval\layered_program_approval.cfc - getAllProductMargins() [ arguments.margin_type EQ 1 ] ***/
				SELECT CP.*, I.Type_Code_Desc_ID, I.Item, I.Description
				INTO ##Contract_products_TMP
				FROM  Contract_products CP
				INNER JOIN BSA_Foodservice_Items_Master I ON
					I.BSA_Foodservice_Items_Master_Id = CP.BSA_Foodservice_Items_Master_ID
				WHERE 	Contract_Main_Id = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar"> AND
						CP.Deleted = 0 AND
						CP.Is_Group = 0

				SELECT DISTINCT CI.Type_Code_Desc_ID AS Parent_Type_Code_Desc_ID,
								CP_Parent.BSA_Foodservice_Items_Master_ID AS Parent_Item_Id,
								CP.BSA_Foodservice_Items_Master_ID AS Child_Item_Id,
								CP.Type_Code_Desc_ID AS Child_Type_Code_Desc_ID,
								0 AS TC_Count,
								0 AS TC_No_Companion_Count
				INTO ##Program_Companion_TC
				FROM  Companion_Item CI
				INNER JOIN  ##Contract_products_TMP CP ON
					CI.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
				INNER JOIN  ##Contract_products_TMP CP_Parent ON
					CI.Type_Code_Desc_ID = CP_Parent.Type_Code_Desc_ID
				WHERE CI.Deleted = 0
				/*WHERE CP.Product_Type_ID = 1 */

				UPDATE ##Program_Companion_TC SET TC_Count = (SELECT Count(DISTINCT Parent_Type_Code_Desc_ID) FROM ##Program_Companion_TC)

				SELECT DISTINCT CP.Type_Code_Desc_ID,
								CP.BSA_Foodservice_Items_Master_ID,
								0 AS TC_Count,
								0 AS TC_No_Companion_Count
				INTO ##Program_NO_Companion_TC
				FROM  ##Contract_products_TMP CP
				LEFT JOIN ##Program_Companion_TC TC_Parent ON
					TC_Parent.Parent_Type_Code_Desc_ID = CP.Type_Code_Desc_ID OR
					TC_Parent.Child_Item_Id = CP.BSA_Foodservice_Items_Master_ID
				WHERE TC_Parent.Parent_Type_Code_Desc_ID IS NULL

				UPDATE ##Program_NO_Companion_TC SET TC_No_Companion_Count = (SELECT Count(DISTINCT Type_Code_Desc_ID) FROM ##Program_NO_Companion_TC)
				UPDATE ##Program_NO_Companion_TC SET TC_Count = (SELECT Count(DISTINCT Parent_Type_Code_Desc_ID) FROM ##Program_Companion_TC)
				UPDATE ##Program_Companion_TC SET TC_No_Companion_Count = (SELECT Count(DISTINCT Type_Code_Desc_ID) FROM ##Program_NO_Companion_TC)

				SELECT distinct
					CPM.Contract_Main_ID,
					CPM.Product_Id,
					ISNULL(CPM.Base_Sales_CS,0) as Base_Sales,
					Cash_discount_CS as Cash_discount,
					Cash_discount_CS AS cash_disc_cs,
					ISNULL(Net_Sales_CS,0) as Net_Sales,
					Cost_CS as cost,
					(ISNULL(Annualized_Allowance_CS,0) + ISNULL(Annualized_Lumpsum_Allowance_CS,0)) as Item_Allowance_Annualized,
					(ISNULL(Item_Allowance_CS,0) + ISNULL(LumpsumAmount_CS,0)) as Item_Allowance,
					ProductVolume_CS as ProductVolume,
					(TargetMargin) as TargetMargin,
					Pullbackamount_CS as PullbackAmount,
					ISNULL(Operating_Income_CS,0) 		as Operating_Income,
					ISNULL(Operating_Income_CS, 0) 		AS	Operating_Income_CS,
					ISNULL(OperatingMargin_percent,0) 	as OperatingMargin_percent,
					ISNULL(Trade_CS,0) 					as Trade,
					ISNULL(Trade_CS,0) 					as Trade_CS,
					ISNULL(Trade_LB,0) 					as Trade_LB,
					ISNULL(Trade_Percent,0) 			as Trade_Percent,
					TC.Type_Code_Desc
					,ISNULL((TC.Target_Margin_Operator),0) as Target_Margin
					,ISNULL(NULLIF(TC.Target_Margin_ListPrice,''),0) AS Target_Margin_ListPrice
					,TC.Target_Case_Rate_UOM,
					ISNULL(TC.Target_Case_Rate, 0) *
					CASE TC.Target_Case_Rate_UOM
					WHEN 1 THEN 1 /* -- CS */
					WHEN 2 THEN CAST(I.Net_Weight as float) /* -- LB */
					ELSE 0
					END 										AS Target_Case_Rate,
					ISNULL(TC.Target_Case_Rate, 0) /
					CASE TC.Target_Case_Rate_UOM
					WHEN 1 THEN CAST(I.Net_Weight as float) /* -- CS */
					WHEN 2 THEN 1 /* -- LB */
					ELSE 1
					END 										AS Target_LB_Rate,
					ISNULL(TC.Target_Case_Rate, 0) 				AS Target_Case_Rate,
					I.Description,
					I.Item,
					I.Net_Weight,
					ISNULL(Product_Program_Volume_CS,0) 		AS Product_Program_Volume ,
					TC.Type_Code_Desc_ID,I.BSA_Foodservice_Items_Master_Id,
					ISNULL(Product_Program_Volume_CS,0) 		AS Product_Program_Volume_CS,
					ISNULL(Product_Program_Volume_LB,0) 		AS Product_Program_Volume_LB,
					ISNULL(CPM.Broker_Cost_CS,0) 				AS Broker_Cost
					,ISNULL(Fx_Man_Cost,0) 						AS Fixed_Mfg_Cost
					,I.UPC
					,ISNULL(Allowance_Surcharges_CS, 0) 		AS Allowance_Surcharges_CS
					,ISNULL(Allowance_Surcharges_CS, 0) 		AS Allowance_Surcharges
					,ISNULL(Customer_Freight_CS, 0)     		AS Customer_Freight
					,ISNULL(Customer_Freight_CS, 0)     		AS Customer_Freight_CS
					,ISNULL(TPA_Oper_CS, 0)             		AS TPA_Oper
					,ISNULL(TPA_CS,0)                   		AS TPA
					,ISNULL(TPA_CS,0)                   		AS TPA_CS
					,ISNULL(Shuttle_Freight_CS, 0)      		AS Shuttle_Freight
					,ISNULL(Shuttle_Freight_CS, 0)      		AS Shuttle_Freight_CS
					,ISNULL(Other_Spend_CS, 0)          		AS Other_Spend
					,ISNULL(Custom_Warehouse_CS, 0)    			AS Custom_Warehouse
					,ISNULL(Custom_Warehouse_CS, 0)     		AS Custom_Warehouse_CS
					,ISNULL(Gross_Margin_CS, 0)         		AS Gross_Margin
					,ISNULL(Custom_Brokerage_CS, 0)     		AS Custom_Brokerage
					,ISNULL(Custom_Brokerage_CS, 0)     		AS custom_brokerage_cs
					,ISNULL(Map_Mdf_CS, 0)              		AS Map_Mdf
					,ISNULL(Map_Mdf_CS, 0)              		AS Map_Mdf_cs
					,ISNULL(SGA_CS, 0)                  		AS SGA
					,ISNULL(SGA_CS, 0) 							AS	SGA_CS
					,ISNULL(Contribution_Margin_Alt_CS, 0)  	AS Contribution_Margin_Alt
					,ISNULL(Contribution_Margin_Alt_CS, 0) 		AS Contribution_Margin_Alt_CS
					,ISNULL(Variable_Contribution_Margin_CS, 0) AS Variable_Contribution_Margin
					,ISNULL(Variable_Contribution_Margin_CS, 0) AS Variable_Contribution_Margin_CS
					,TC_Child.Type_Code_Desc 					AS Child_Type_Code_Desc
					,CASE WHEN TC_Parent.Child_Item_Id = I.BSA_Foodservice_Items_Master_ID THEN 1 ELSE 0 END 	AS Is_Companion_Item
					,CASE WHEN TC_Parent.Parent_Item_Id = I.BSA_Foodservice_Items_Master_ID THEN 1 ELSE 0 END 	AS Is_Parent_Item
					,ISNULL(TC_Parent.TC_Count,ISNULL(TC_No_Companion.TC_Count,0)) 								AS TC_Count
					,ISNULL(TC_No_Companion.TC_No_Companion_Count,ISNULL(TC_Parent.TC_No_Companion_Count,0)) 	AS TC_No_Companion_Count
					,IsNull(Program_Fixed_Price_cs, 0)                											AS Program_Fixed_Price_CS
					,(Program_Fixed_Price_CS / ISNULL(ISNULL(nullif(cast(CP.case_count as decimal(14,0)),0),I.PACK_QTY),1)	) * 1000 					AS Program_Fixed_Price_M
					,(	ISNULL(CPM.Base_Sales_CS,0) / ISNULL(ISNULL(nullif(cast(CP.case_count as decimal(14,0)),0),I.PACK_QTY),1)	) * 1000 			AS Base_Sales_M
					,(	ISNULL(CPM.Net_Sales_CS,0) / ISNULL(ISNULL(nullif(cast(CP.case_count as decimal(14,0)),0),I.PACK_QTY),1)	) * 1000 			AS Net_Sales_M
					,(	ISNULL(CPM.Cost_CS,0) / ISNULL(ISNULL(nullif(cast(CP.case_count as decimal(14,0)),0),I.PACK_QTY),1)	) * 1000 					AS Cost_M
					,(	ISNULL(Contribution_Margin_Alt_CS, 0) / ISNULL(ISNULL(nullif(cast(CP.case_count as decimal(14,0)),0),I.PACK_QTY),1)	) * 1000 	AS Contribution_Margin_Alt_M
					,(	ISNULL(CPM.SGA_CS,0) / ISNULL(ISNULL(nullif(cast(CP.case_count as decimal(14,0)),0),I.PACK_QTY),1)	) * 1000 					AS SGA_M
					,(	ISNULL(CPM.Operating_Income_CS,0) / ISNULL(ISNULL(nullif(cast(CP.case_count AS decimal(14,0)),0),I.PACK_QTY),1)	) * 1000 		AS Operating_Income_M
	                ,ISNULL(Allowance_Surcharges_LB, 0) 											AS Allowance_Surcharges_LB
	                ,ISNULL(Customer_Freight_LB, 0) 												AS Customer_Freight_LB
	                ,ISNULL(ISNULL(nullif(cast(CP.case_count as decimal(14,0)),0),I.PACK_QTY),0) 	AS Case_Count
	                ,ISNULL(ISNULL(nullif(cast(CP.case_cube as decimal(14,2)),0),i.Case_Count),0) 	AS Case_Cube
	                ,IsNull(FPV_CS, 0)					AS Current_Price_CS
	                ,I.Type_Code_desc_Id
	                ,GAR.Group_Id_Margin
	                ,ISNULL(GAR.Group_ID_Approval,0) 	AS Group_ID_Approval
			<cfif arguments.margin_version eq "approved">
				FROM  dbo.Contract_Product_Margin_Approved CPM
			<cfelse>
				FROM  dbo.Contract_Product_Margin CPM
			</cfif>
			INNER JOIN ##Contract_products_TMP CP ON
                /*--- CP.Contract_Products_ID = CONTRACT_PRODUCT_MARGIN.Contract_Product_ID
                CP.Contract_Main_Id = CPM.Contract_Main_Id AND */
                CP.Bsa_FoodService_Items_Master_Id = CPM.Product_Id
			INNER JOIN BSA_Foodservice_Items_Master I
					ON I.BSA_Foodservice_Items_Master_Id = CPM.Product_Id
			LEFT JOIN ##Program_Companion_TC TC_Parent ON
					TC_Parent.Parent_Item_Id = I.BSA_Foodservice_Items_Master_ID OR
					TC_Parent.Child_Item_Id = I.BSA_Foodservice_Items_Master_ID
			LEFT JOIN ##Program_NO_Companion_TC TC_No_Companion ON
					TC_No_Companion.BSA_Foodservice_Items_Master_ID = I.BSA_Foodservice_Items_Master_ID
			LEFT JOIN Companion_Item CI ON
					TC_Parent.Child_Item_Id = CI.BSA_Foodservice_Items_Master_ID AND
					CI.BSA_Foodservice_Items_Master_ID = I.BSA_Foodservice_Items_Master_ID AND
					CI.Deleted = 0
			INNER JOIN Type_Code_Desc TC ON
					TC.Type_Code_Desc_ID =  ISNULL(CI.Type_Code_Desc_ID,I.Type_Code_Desc_ID)
			LEFT JOIN Type_Code_Desc TC_Child ON
					TC_Child.Type_Code_Desc_ID = I.Type_Code_Desc_ID AND
					CI.BSA_Foodservice_Items_Master_ID IS NOT NULL
			LEFT JOIN Group_Approval_Rights GAR ON
					GAR.Group_Id = I.Type_Code_desc_Id AND
                    GAR.User_Profile_Id = #request.Accessstructure.Profiles_ID# AND
                    GAR.Deleted = 0
			WHERE 	CPM.contract_main_id = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar">
			AND 	CPM.deleted = 0
			AND 	CPM.Exclude_From_Margin = <cfqueryparam value="#arguments.excludeMarginItems#" cfsqltype="cf_sql_bit">
			/* AND		(	CI.Companion_Item_ID  IS NOT NULL
						OR
			 			  NEED TMP TABLE TO CHECK IF PARENT ITEM HAS A CHILD ON THIS PROGRAM
			 			TC_Parent.Type_Code_Desc_ID IS NOT NULL
					) */
			<!--- Dev Note: drachala; D28637: In View Margin Page Display Description text in order user selected  START
		    Added/Changed: Added IF condition to Order by--->
			order by TC.Type_Code_Desc,I.Item
			<!--- End Dev Note: drachala; D: Item, Description Sort  --->
		</CFQUERY>
<!--- 	<cfdump var="#qgetAllProductMargins#" output="c:\dump.log">  --->
	<cfreturn qgetAllProductMargins />
</cffunction>


<cffunction name="getAllProductMargins" access="public" returntype="query">
<cfargument name="program_id" type="string" required="true" />
<cfargument name="margin_type" type="string" required="true" />
<cfargument name="formCopy" type="struct" required="false"/>
<cfargument name="excludeMarginItems" type="boolean" required="false" default="0" />
<cfargument name="margin_version" type="string" required="false" default="current" />
<cfargument name="Operator_program" type="boolean" required="false" default="0"/>
<cfargument name="GlobalUom" type="numeric" required="false" default="0"/>
<cfargument name="Lower_Than_Ideal" type="boolean" required="false" default="0"/>

<cfif isDefined("arguments.formCopy.AgreeList")>
	<cfif arguments.formCopy.AgreeList neq "">
		<cfset agreeList = arguments.formCopy.AgreeList />
	<cfelse>
		<cfset agreeList = arguments.formCopy.preAgreeList />
	</cfif>
</cfif>
<cfif isDefined("arguments.formCopy.ApproveList")>
	<cfif arguments.formCopy.ApproveList neq "">
		<cfset approveList = arguments.formCopy.ApproveList />
	<cfelse>
		<cfset approveList = arguments.formCopy.preApproveList />
	</cfif>
</cfif>
<cfif isDefined("arguments.formCopy.RestrictedList")>
	<cfif arguments.formCopy.RestrictedList neq "">
		<cfset restrictedList = arguments.formCopy.RestrictedList />
	<cfelse>
		<cfset restrictedList = arguments.formCopy.preRestrictedList />
	</cfif>
</cfif>

<cfif application.appSettingsGet.getApprovalMarginType() eq 2><!--- Annual Case Rate --->
    <CFQUERY NAME="qgetAllProductMargins" datasource="#application.datasource#">
    /*** components\programs\Approval\layered_program_approval.cfc - getAllProductMargins() [  getApprovalMarginType() eq 2 ] ***/
	SELECT distinct
			Contract_Main_ID,
			CPM.Product_Id,

			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 2 THEN ISNULL(Base_Sales_LB,0)
			ELSE ISNULL(Base_Sales_CS,0)
			END as Base_Sales,

			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 2 THEN Cash_discount_LB
			ELSE Cash_discount_CS
			END as Cash_discount,

			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 2 THEN ISNULL(Net_Sales_LB,0)
			ELSE ISNULL(Net_Sales_CS,0)
			END as Net_Sales,

			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 2 THEN Cost_LB
			ELSE Cost_CS
			END as cost,

			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 2 THEN (ISNULL(Annualized_Allowance_LB,0) + ISNULL(Annualized_Lumpsum_Allowance_LB,0))
			ELSE (ISNULL(Annualized_Allowance_CS,0) + ISNULL(Annualized_Lumpsum_Allowance_CS,0))
			END as Item_Allowance_Annualized,

			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 2 THEN (ISNULL(Item_Allowance_LB,0) + ISNULL(LumpsumAmount_LB,0))
			ELSE (ISNULL(Item_Allowance_CS,0) + ISNULL(LumpsumAmount_CS,0))
			END as Item_Allowance,

			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 2 THEN ProductVolume_LB
			ELSE ProductVolume_CS
			END as ProductVolume,

			(TargetMargin) as TargetMargin,

			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 2 THEN Pullbackamount_LB
			ELSE Pullbackamount_CS
			END as PullbackAmount,

			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 2 THEN ISNULL(Operating_Income_LB,0)
			ELSE ISNULL(Operating_Income_CS,0)
			END as Operating_Income,

			ISNULL(OperatingMargin_percent,0) as OperatingMargin_percent,

			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 2 THEN ISNULL(Trade_LB,0)
			ELSE ISNULL(Trade_CS,0)
			END as Trade,

			ISNULL(Trade_CS,0) as Trade_CS,
			ISNULL(Trade_LB,0) as Trade_LB,
			ISNULL(Trade_Percent,0) as Trade_Percent,

			Type_Code_Desc.Type_Code_Desc

			<!--- 66894 --->
			<cfif arguments.Operator_program>
			,ISNULL((Type_Code_Desc.Target_Margin_Operator),0) as Target_Margin
			<cfelse>
			,ISNULL((Type_Code_Desc.Target_Margin),0) as Target_Margin
			</cfif>
			<!--- 66894 --->
		 	,ISNULL(NULLIF(Type_Code_Desc.Target_Margin_ListPrice,''),0) AS Target_Margin_ListPrice <!---72497 --->
			<!---- **** Target_Case_Rate --->
			,Type_Code_Desc.Target_Case_Rate_UOM
			,ISNULL(Type_Code_Desc.Target_Case_Rate, 0) *
			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 1 THEN 1 /* -- CS */
			WHEN 2 THEN CAST(BSA_Foodservice_Items_Master.Net_Weight as float) /* -- LB */
			ELSE 0
			END as Target_Case_Rate,

			ISNULL(Type_Code_Desc.Target_Case_Rate, 0) /
			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 1 THEN CAST(BSA_Foodservice_Items_Master.Net_Weight as float) /* -- CS */
			WHEN 2 THEN 1 /* -- LB */
			ELSE 1
			END as Target_LB_Rate,

			BSA_Foodservice_Items_Master.Description,BSA_Foodservice_Items_Master.Item,

			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 2 THEN ISNULL(Product_Program_Volume_LB,0)
			ELSE ISNULL(Product_Program_Volume_CS,0)
			END as Product_Program_Volume,

			Type_Code_Desc.Type_Code_Desc_ID,BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id,

			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 2 THEN ISNULL(CPM.Broker_Cost_LB,0)
			ELSE ISNULL(CPM.Broker_Cost_CS,0)
			END as Broker_Cost
			,ISNULL(Fx_Man_Cost,0) as Fixed_Mfg_Cost<!--- 62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost --->
			,BSA_Foodservice_Items_Master.UPC
			,#case_lb_column("Allowance_Surcharges")# AS Allowance_Surcharges
			,#case_lb_column("Customer_Freight")#     AS Customer_Freight
			,#case_lb_column("TPA_Oper")#             AS TPA_Oper
			,#case_lb_column("TPA")#                  AS TPA
			,#case_lb_column("Shuttle_Freight")#      AS Shuttle_Freight
			,#case_lb_column("Other_Spend")#          AS Other_Spend
			,#case_lb_column("Custom_Warehouse")#     AS Custom_Warehouse
			,#case_lb_column("Gross_Margin")#         AS Gross_Margin
			,#case_lb_column("Custom_Brokerage")#     AS Custom_Brokerage
			,#case_lb_column("Map_Mdf")#              AS Map_Mdf
			,#case_lb_column("SGA")#                  AS SGA
			,#case_lb_column("Contribution_Margin_Alt")#      AS Contribution_Margin_Alt
			,#case_lb_column("Variable_Contribution_Margin")# AS Variable_Contribution_Margin
			,IsNull(Program_Fixed_Price_cs, 0)                AS Program_Fixed_Price_CS
			,CPM.Ideal_Price_CS AS Ideal_Price
			,RER_CS AS RER
			,GRR_CS AS GRR
			,OER_CS AS OER
			,Diff_Formula_Price_CS AS Diff_Formula_Price
			,LumpsumAmount_CS AS Lumpsum_Amount
			,Base_Discount_CS AS Base_Discount
			,IsNull(Fixed_Cost_CS, 0) AS Fixed_Cost
			,Annualized_Allowance_CS AS AnnualizedAllowance
			,Item_Allowance_CS AS ItemAllowance
		<cfif arguments.margin_version eq "approved">
			FROM  dbo.Contract_Product_Margin_Approved CPM
		<cfelse>
			FROM  dbo.Contract_Product_Margin CPM
		</cfif>
	INNEr JOIN BSA_Foodservice_Items_Master
			ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = CPM.Product_Id
	INNER JOIN Type_Code_Desc
			ON Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
	where 	contract_main_id = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar">
	<cfif isDefined("arguments.formCopy") and Not isDefined("arguments.formCopy.Agree") and agreeList neq "">
		and BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID not in (#ListQualify(agreeList, "'" , ",")#)
	</cfif>
	<cfif isDefined("arguments.formCopy") and Not isDefined("arguments.formCopy.Approve") and approveList neq "">
		and BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID not in (#ListQualify(approveList, "'" , ",")#)
	</cfif>
	<cfif isDefined("arguments.formCopy") and Not isDefined("arguments.formCopy.Restricted") and restrictedList neq "">
		and BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID not in (#ListQualify(restrictedList, "'" , ",")#)
	</cfif>
	and 	CPM.deleted = 0
	and 	CPM.Exclude_From_Margin = <cfqueryparam value="#arguments.excludeMarginItems#" cfsqltype="cf_sql_bit">
	<!--- 114617 :: Ideal Price START --->
	<cfif arguments.Lower_Than_Ideal>
		and CPM.FPR_CS < CPM.Ideal_Price_CS
	</cfif>
	<!--- 114617 :: Ideal Price END --->
	<!--- Dev Note: drachala; D28637: In View Margin Page Display Description text in order user selected  START
    Added/Changed: Added IF condition to Order by--->
	order by Type_Code_Desc.Type_Code_Desc,Type_Code_Desc.Type_Code_Desc_ID,<cfif application.appSettingsGet.getViewPgmSortBy()>BSA_Foodservice_Items_Master.Description<cfelse>BSA_Foodservice_Items_Master.Item</cfif>
	<!--- End Dev Note: drachala; D: Item, Description Sort  --->
	</CFQUERY>
<cfelse>
<cfif arguments.margin_type EQ 1>			<!--- 	HM	HM	HM *******************************************************~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~				--->
    <CFQUERY NAME="qgetAllProductMargins" datasource="#application.datasource#">
    /*** components\programs\Approval\layered_program_approval.cfc - getAllProductMargins() [ arguments.margin_type EQ 1 ] ***/
	SELECT distinct
			Contract_Main_ID,
			CPM.Product_Id,
			ISNULL(Base_Sales_CS,0) as Base_Sales,
			Cash_discount_CS as Cash_discount,
			ISNULL(Net_Sales_CS,0) as Net_Sales,
		<!--- 70104	Absolute Net Sales $ per Lb or Equiv Case START --->
		<cfif arguments.GlobalUom EQ 1>
			ISNULL(Net_Sales_CS,0) as Global_Net_Sales,
		<cfelseif arguments.GlobalUom EQ 2>
			 ISNULL(Net_Sales_LB,0) as Global_Net_Sales,
		<cfelseif arguments.GlobalUom EQ 3>
			ISNULL(Net_Sales_STAT,0)  as Global_Net_Sales,
		</cfif>
		<!--- 70104	Absolute Net Sales $ per Lb or Equiv Case END --->
			Cost_CS as cost,
			(ISNULL(Annualized_Allowance_CS,0) + ISNULL(Annualized_Lumpsum_Allowance_CS,0)) as Item_Allowance_Annualized,
			(ISNULL(Item_Allowance_CS,0) + ISNULL(LumpsumAmount_CS,0)) as Item_Allowance,
			ProductVolume_CS as ProductVolume,
			(TargetMargin) as TargetMargin,
			Pullbackamount_CS as PullbackAmount,
			ISNULL(Operating_Income_CS,0) as Operating_Income,
			ISNULL(OperatingMargin_percent,0) as OperatingMargin_percent,
			ISNULL(Trade_CS,0) as Trade,
			ISNULL(Trade_CS,0) as Trade_CS,
			ISNULL(Trade_LB,0) as Trade_LB,
			ISNULL(Trade_Percent,0) as Trade_Percent,
			Type_Code_Desc.Type_Code_Desc
			<!--- 66894 --->
			<cfif arguments.Operator_program>
			,ISNULL((Type_Code_Desc.Target_Margin_Operator),0) as Target_Margin
			<cfelse>
			,ISNULL((Type_Code_Desc.Target_Margin),0) as Target_Margin
			</cfif>
			<!--- 66894 --->
			 ,ISNULL(NULLIF(Target_Margin_ListPrice,''),0) AS Target_Margin_ListPrice<!--- 72497 --->
			<!---- **** Target_Case_Rate --->
			,Type_Code_Desc.Target_Case_Rate_UOM,
			ISNULL(Type_Code_Desc.Target_Case_Rate, 0) *
			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 1 THEN 1 /* -- CS */
			WHEN 2 THEN CAST(BSA_Foodservice_Items_Master.Net_Weight as float) /* -- LB */
			ELSE 0
			END as Target_Case_Rate,
			ISNULL(Type_Code_Desc.Target_Case_Rate, 0) /
			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 1 THEN CAST(BSA_Foodservice_Items_Master.Net_Weight as float) /* -- CS */
			WHEN 2 THEN 1 /* -- LB */
			ELSE 1
			END as Target_LB_Rate,
			ISNULL(Type_Code_Desc.Target_Case_Rate, 0) as Target_Case_Rate,
			BSA_Foodservice_Items_Master.Description,BSA_Foodservice_Items_Master.Item,
			ISNULL(Product_Program_Volume_CS,0) as Product_Program_Volume ,Type_Code_Desc.Type_Code_Desc_ID,BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id,
			ISNULL(Product_Program_Volume_CS,0) as Product_Program_Volume_CS,    <!---44017--->
			ISNULL(Product_Program_Volume_LB,0) as Product_Program_Volume_LB,    <!---44017--->
			ISNULL(CPM.Broker_Cost_CS,0) As Broker_Cost
			,ISNULL(Fx_Man_Cost,0) as Fixed_Mfg_Cost<!--- 62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost --->
			,BSA_Foodservice_Items_Master.UPC
			,ISNULL(Allowance_Surcharges_CS, 0) AS Allowance_Surcharges
			,ISNULL(Customer_Freight_CS, 0)     AS Customer_Freight
			,ISNULL(TPA_Oper_CS, 0)             AS TPA_Oper
			,ISNULL(TPA_CS,0)                   AS TPA
			,ISNULL(Shuttle_Freight_CS, 0)      AS Shuttle_Freight
			,ISNULL(Other_Spend_CS, 0)          AS Other_Spend
			,ISNULL(Custom_Warehouse_CS, 0)     AS Custom_Warehouse
			,ISNULL(Gross_Margin_CS, 0)         AS Gross_Margin
			,ISNULL(Custom_Brokerage_CS, 0)     AS Custom_Brokerage
			,ISNULL(Map_Mdf_CS, 0)              AS Map_Mdf
			,ISNULL(SGA_CS, 0)                  AS SGA
			,ISNULL(Contribution_Margin_Alt_CS, 0)      AS Contribution_Margin_Alt
			,ISNULL(Variable_Contribution_Margin_CS, 0) AS Variable_Contribution_Margin
			,IsNull(Program_Fixed_Price_cs, 0)                AS Program_Fixed_Price_CS
			,MTU.Net_Sales_Target_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5)) AS Net_Sales_Target_Value
			,MTU.Net_Sales_Floor_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5)) AS Net_Sales_Floor_Value
			,MTU.GM_Target_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5)) AS GM_Target_Value
			,MTU.GM_Floor_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5)) AS GM_Floor_Value
			,CPM.Ideal_Price_CS AS Ideal_Price
			,RER_CS AS RER
			,GRR_CS AS GRR
			,OER_CS AS OER
			,Diff_Formula_Price_CS AS Diff_Formula_Price
			,LumpsumAmount_CS AS Lumpsum_Amount
			,Base_Discount_CS AS Base_Discount
			,IsNull(Fixed_Cost_CS, 0) AS Fixed_Cost
			,Annualized_Allowance_CS AS AnnualizedAllowance
			,Item_Allowance_CS AS ItemAllowance
		<cfif arguments.margin_version eq "approved">
			FROM  dbo.Contract_Product_Margin_Approved CPM
		<cfelse>
			FROM  dbo.Contract_Product_Margin CPM
		</cfif>
	INNEr JOIN BSA_Foodservice_Items_Master
			ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = CPM.Product_Id
	INNER JOIN Type_Code_Desc
			ON Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
	LEFT JOIN Margin_Targets_Upload MTU
			ON MTU.BSA_Foodservice_Items_Master_ID  = CPM.Product_Id
	where 	contract_main_id = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar">
	<cfif isDefined("arguments.formCopy") and Not isDefined("arguments.formCopy.Agree") and agreeList neq "">
		and BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID not in (#ListQualify(agreeList, "'" , ",")#)
	</cfif>
	<cfif isDefined("arguments.formCopy") and Not isDefined("arguments.formCopy.Approve") and approveList neq "">
		and BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID not in (#ListQualify(approveList, "'" , ",")#)
	</cfif>
	<cfif isDefined("arguments.formCopy") and Not isDefined("arguments.formCopy.Restricted") and restrictedList neq "">
		and BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID not in (#ListQualify(restrictedList, "'" , ",")#)
	</cfif>
	and 	CPM.deleted = 0
	and 	CPM.Exclude_From_Margin = <cfqueryparam value="#arguments.excludeMarginItems#" cfsqltype="cf_sql_bit">
	<!--- 114617 :: Ideal Price START --->
	<cfif arguments.Lower_Than_Ideal>
		and CPM.FPR_CS < CPM.Ideal_Price_CS
	</cfif>
	<!--- 114617 :: Ideal Price END --->
	<!--- Dev Note: drachala; D28637: In View Margin Page Display Description text in order user selected  START
    Added/Changed: Added IF condition to Order by--->
	order by Type_Code_Desc.Type_Code_Desc,Type_Code_Desc.Type_Code_Desc_ID,<cfif application.appSettingsGet.getViewPgmSortBy()>BSA_Foodservice_Items_Master.Description<cfelse>BSA_Foodservice_Items_Master.Item</cfif>
	<!--- End Dev Note: drachala; D: Item, Description Sort  --->
	</CFQUERY>
<cfelseif arguments.margin_type EQ 3>
<CFQUERY NAME="qgetAllProductMargins" datasource="#application.datasource#">
    /*** components\programs\Approval\layered_program_approval.cfc - getAllProductMargins() [ arguments.margin_type EQ 3 ] ***/
	SELECT distinct
			Contract_Main_ID,
			CPM.Product_Id,
			ISNULL(Base_Sales_LB,0) as Base_Sales,
			Cash_discount_LB as Cash_discount,
			ISNULL(Net_Sales_LB,0) as Net_Sales,
		<!--- 70104	Absolute Net Sales $ per Lb or Equiv Case START --->
		<cfif arguments.GlobalUom EQ 1>
			ISNULL(Net_Sales_CS,0) as Global_Net_Sales,
		<cfelseif arguments.GlobalUom EQ 2>
			 ISNULL(Net_Sales_LB,0) as Global_Net_Sales,
		<cfelseif arguments.GlobalUom EQ 3>
			ISNULL(Net_Sales_STAT,0)  as Global_Net_Sales,
		</cfif>
		<!--- 70104	Absolute Net Sales $ per Lb or Equiv Case END --->
			Cost_LB as cost,
			(ISNULL(Annualized_Allowance_LB,0) + ISNULL(Annualized_Lumpsum_Allowance_LB,0)) as Item_Allowance_Annualized,
			(ISNULL(Item_Allowance_LB,0) + ISNULL(LumpsumAmount_LB,0)) as Item_Allowance,
			ProductVolume_LB as ProductVolume,
			(TargetMargin) as TargetMargin,
			Pullbackamount_LB as PullbackAmount,
			ISNULL(Operating_Income_LB,0) as Operating_Income,
			ISNULL(OperatingMargin_percent,0) as OperatingMargin_percent,
			ISNULL(Trade_LB,0) as Trade,
			ISNULL(Trade_CS,0) as Trade_CS,
			ISNULL(Trade_LB,0) as Trade_LB,
			ISNULL(Trade_Percent,0) as Trade_Percent,
			Type_Code_Desc.Type_Code_Desc
			<!--- 66894 --->
			<cfif arguments.Operator_program>
			,ISNULL((Type_Code_Desc.Target_Margin_Operator),0) as Target_Margin
			<cfelse>
			,ISNULL((Type_Code_Desc.Target_Margin),0) as Target_Margin
			</cfif>
			<!--- 66894 --->
		 	,ISNULL(NULLIF(Target_Margin_ListPrice,''),0) AS Target_Margin_ListPrice  <!--- 72497 --->
			<!---- **** Target_Case_Rate --->
			,Type_Code_Desc.Target_Case_Rate_UOM,
			ISNULL(Type_Code_Desc.Target_Case_Rate, 0) *
			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 1 THEN 1 /* -- CS */
			WHEN 2 THEN CAST(BSA_Foodservice_Items_Master.Net_Weight as float) /* -- LB */
			ELSE 0
			END as Target_Case_Rate,
			ISNULL(Type_Code_Desc.Target_Case_Rate, 0) /
			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 1 THEN CAST(BSA_Foodservice_Items_Master.Net_Weight as float) /* -- CS */
			WHEN 2 THEN 1 /* -- LB */
			ELSE 1
			END as Target_LB_Rate,
			BSA_Foodservice_Items_Master.Description,BSA_Foodservice_Items_Master.Item,
			ISNULL(Product_Program_Volume_LB,0) as Product_Program_Volume ,Type_Code_Desc.Type_Code_Desc_ID,BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id,
			ISNULL(CPM.Broker_Cost_LB,0) As Broker_Cost
			,ISNULL(Fx_Man_Cost,0)/ CAST(BSA_Foodservice_Items_Master.Net_Weight as float) as Fixed_Mfg_Cost <!--- 62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost --->
			,BSA_Foodservice_Items_Master.UPC
			,ISNULL(Allowance_Surcharges_LB, 0) AS Allowance_Surcharges
			,ISNULL(Customer_Freight_LB, 0)     AS Customer_Freight
			,ISNULL(TPA_Oper_LB, 0)             AS TPA_Oper
			,ISNULL(TPA_LB, 0)                  AS TPA
			,ISNULL(Shuttle_Freight_LB, 0)      AS Shuttle_Freight
			,ISNULL(Other_Spend_LB, 0)          AS Other_Spend
			,ISNULL(Custom_Warehouse_LB, 0)     AS Custom_Warehouse
			,ISNULL(Gross_Margin_LB, 0)         AS Gross_Margin
			,ISNULL(Custom_Brokerage_LB, 0)     AS Custom_Brokerage
			,ISNULL(Map_Mdf_LB, 0)              AS Map_Mdf
			,ISNULL(SGA_LB, 0)                  AS SGA
			,ISNULL(Contribution_Margin_Alt_LB, 0)      AS Contribution_Margin_Alt
			,ISNULL(Variable_Contribution_Margin_LB, 0) AS Variable_Contribution_Margin
			,IsNull(Program_Fixed_Price_cs, 0)                AS Program_Fixed_Price_CS
			,MTU.Net_Sales_Target_Value AS Net_Sales_Target_Value
			,MTU.Net_Sales_Floor_Value AS Net_Sales_Floor_Value
			,MTU.GM_Target_Value AS GM_Target_Value
			,MTU.GM_Floor_Value AS GM_Floor_Value
			,CPM.Ideal_Price_LB AS Ideal_Price
			,RER_LB AS RER
			,GRR_LB AS GRR
			,OER_LB AS OER
			,Diff_Formula_Price_LB AS Diff_Formula_Price
			,LumpsumAmount_LB AS Lumpsum_Amount
			,Base_Discount_LB AS Base_Discount
			<cfif arguments.margin_version eq "approved">
			,0 AS Fixed_Cost
			<cfelse>
			,IsNull(Fixed_Cost_LB, 0) AS Fixed_Cost
			</cfif>
			,Annualized_Allowance_LB AS AnnualizedAllowance
			,Item_Allowance_LB AS ItemAllowance
		<cfif arguments.margin_version eq "approved">
			FROM  dbo.Contract_Product_Margin_Approved CPM
		<cfelse>
			FROM  dbo.Contract_Product_Margin CPM
		</cfif>
	INNEr JOIN BSA_Foodservice_Items_Master
			ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = CPM.Product_Id
	INNER JOIN Type_Code_Desc
			ON Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
	LEFT JOIN Margin_Targets_Upload MTU
			ON MTU.BSA_Foodservice_Items_Master_ID  = CPM.Product_Id
	where 	contract_main_id = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar">
	<cfif isDefined("arguments.formCopy") and Not isDefined("arguments.formCopy.Agree") and agreeList neq "">
		and BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID not in (#ListQualify(agreeList, "'" , ",")#)
	</cfif>
	<cfif isDefined("arguments.formCopy") and Not isDefined("arguments.formCopy.Approve") and approveList neq "">
		and BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID not in (#ListQualify(approveList, "'" , ",")#)
	</cfif>
	<cfif isDefined("arguments.formCopy") and Not isDefined("arguments.formCopy.Restricted") and restrictedList neq "">
		and BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID not in (#ListQualify(restrictedList, "'" , ",")#)
	</cfif>
	and 	CPM.deleted = 0
	and 	CPM.Exclude_From_Margin = <cfqueryparam value="#arguments.excludeMarginItems#" cfsqltype="cf_sql_bit">
	<!--- 114617 :: Ideal Price START --->
	<cfif arguments.Lower_Than_Ideal>
		and CPM.FPR_LB < CPM.Ideal_Price_LB
	</cfif>
	<!--- 114617 :: Ideal Price END --->
	<!--- Dev Note: drachala; D28637: In View Margin Page Display Description text in order user selected START
    Added/Changed: Added IF condition to Order by--->
	order by Type_Code_Desc.Type_Code_Desc,Type_Code_Desc.Type_Code_Desc_ID,<cfif application.appSettingsGet.getViewPgmSortBy()>BSA_Foodservice_Items_Master.Description<cfelse>BSA_Foodservice_Items_Master.Item</cfif>
	<!--- End Dev Note: drachala; D: Item, Description Sort  --->
	</CFQUERY>
<cfelse>
	<CFQUERY NAME="qgetAllProductMargins" datasource="#application.datasource#">
    /*** components\programs\Approval\layered_program_approval.cfc - getAllProductMargins() [ around line 408 ] ***/
	SELECT distinct
		Contract_Main_ID,
		CPM.Product_Id,
		ISNULL(Base_Sales_STAT,0) as Base_Sales,
		Cash_discount_STAT as Cash_discount,
		ISNULL(Net_Sales_STAT,0) as Net_Sales,
		<!--- 70104	Absolute Net Sales $ per Lb or Equiv Case START --->
		<cfif arguments.GlobalUom EQ 1>
			ISNULL(Net_Sales_CS,0) as Global_Net_Sales,
		<cfelseif arguments.GlobalUom EQ 2>
			 ISNULL(Net_Sales_LB,0) as Global_Net_Sales,
		<cfelseif arguments.GlobalUom EQ 3>
			ISNULL(Net_Sales_STAT,0)  as Global_Net_Sales,
		</cfif>
		<!--- 70104	Absolute Net Sales $ per Lb or Equiv Case END --->
		Cost_STAT as cost,
		(ISNULL(Annualized_Allowance_STAT,0) + ISNULL(Annualized_Lumpsum_Allowance_STAT,0)) as Item_Allowance_Annualized,
		(ISNULL(Item_Allowance_STAT,0) + ISNULL(LumpsumAmount_STAT,0)) as Item_Allowance,
		ProductVolume_STAT as ProductVolume,
		(TargetMargin) as TargetMargin,
		Pullbackamount_STAT as PullbackAmount,
		ISNULL(Operating_Income_STAT,0) as Operating_Income,
		ISNULL(OperatingMargin_percent,0) as OperatingMargin_percent,
		ISNULL(Trade_STAT,0) as Trade,
		ISNULL(Trade_CS,0) as Trade_CS,
		ISNULL(Trade_LB,0) as Trade_LB,
		ISNULL(Trade_Percent,0) as Trade_Percent,
		Type_Code_Desc.Type_Code_Desc
		<!--- 66894 --->
		<cfif arguments.Operator_program>
		,ISNULL((Type_Code_Desc.Target_Margin_Operator),0) as Target_Margin
		<cfelse>
		,ISNULL((Type_Code_Desc.Target_Margin),0) as Target_Margin
		</cfif>
		<!--- 66894 --->
	 	,ISNULL(NULLIF(Target_Margin_ListPrice,''),0) AS Target_Margin_ListPrice  <!---72497 --->
		<!---- **** Target_Case_Rate --->
		,Type_Code_Desc.Target_Case_Rate_UOM,
		ISNULL(Type_Code_Desc.Target_Case_Rate, 0) *
		CASE Type_Code_Desc.Target_Case_Rate_UOM
		WHEN 1 THEN 1 /* -- CS */
		WHEN 2 THEN CAST(BSA_Foodservice_Items_Master.Net_Weight as float) /* -- LB */
		ELSE 0
		END as Target_Case_Rate,
		ISNULL(Type_Code_Desc.Target_Case_Rate, 0) /
		CASE Type_Code_Desc.Target_Case_Rate_UOM
		WHEN 1 THEN CAST(BSA_Foodservice_Items_Master.Net_Weight as float) /* -- CS */
		WHEN 2 THEN 1 /* -- LB */
		ELSE 1
		END as Target_LB_Rate,
		BSA_Foodservice_Items_Master.Description,BSA_Foodservice_Items_Master.Item,
		ISNULL(Product_Program_Volume_STAT,0) as Product_Program_Volume ,Type_Code_Desc.Type_Code_Desc_ID,BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id,ISNULL(CASE_EQUIVALENT,0) as CASE_EQUIVALENT
		<!---D37829 Program Summary Volume Not Totaling --->
		,ISNULL(CPM.Broker_Cost_CS,0) / BSA_Foodservice_Items_Master.Case_Equivalent As Broker_Cost
		<!---D37829 Program Summary Volume Not Totaling --->
		,ISNULL(Fx_Man_Cost,0)/CASE_EQUIVALENT as Fixed_Mfg_Cost <!--- 62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost --->
		,BSA_Foodservice_Items_Master.UPC
		,ISNULL(Allowance_Surcharges_STAT, 0) AS Allowance_Surcharges
		,ISNULL(Customer_Freight_STAT, 0)     AS Customer_Freight
		,ISNULL(TPA_Oper_STAT, 0)             AS TPA_Oper
		,ISNULL(TPA_STAT, 0)                  AS TPA
		,ISNULL(Shuttle_Freight_STAT, 0)      AS Shuttle_Freight
		,ISNULL(Other_Spend_STAT, 0)          AS Other_Spend
		,ISNULL(Custom_Warehouse_STAT, 0)     AS Custom_Warehouse
		,ISNULL(Gross_Margin_STAT, 0)         AS Gross_Margin
		,ISNULL(Custom_Brokerage_STAT, 0)     AS Custom_Brokerage
		,ISNULL(Map_Mdf_STAT, 0)              AS Map_Mdf
		,ISNULL(SGA_STAT, 0)                  AS SGA
		,ISNULL(Contribution_Margin_Alt_STAT, 0)      AS Contribution_Margin_Alt
		,ISNULL(Variable_Contribution_Margin_STAT, 0) AS Variable_Contribution_Margin
		,IsNull(Program_Fixed_Price_cs, 0)                AS Program_Fixed_Price_CS
		,MTU.Net_Sales_Target_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5)) / NULLIF(CAST(BSA_Foodservice_Items_Master.Case_Equivalent as DECIMAL(20, 5)), 0) AS Net_Sales_Target_Value
		,MTU.Net_Sales_Floor_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5)) / NULLIF(CAST(BSA_Foodservice_Items_Master.Case_Equivalent as DECIMAL(20, 5)), 0) AS Net_Sales_Floor_Value
		,MTU.GM_Target_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5)) / NULLIF(CAST(BSA_Foodservice_Items_Master.Case_Equivalent as DECIMAL(20, 5)), 0) AS GM_Target_Value
		,MTU.GM_Floor_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5)) / NULLIF(CAST(BSA_Foodservice_Items_Master.Case_Equivalent as DECIMAL(20, 5)), 0) AS GM_Floor_Value
		,CPM.Ideal_Price_STAT AS Ideal_Price
		,RER_STAT AS RER
		,GRR_STAT AS GRR
		,OER_STAT AS OER
		,Diff_Formula_Price_STAT AS Diff_Formula_Price
		,LumpsumAmount_STAT AS Lumpsum_Amount
		,Base_Discount_STAT AS Base_Discount
		,IsNull(Fixed_Cost_STAT, 0) AS Fixed_Cost
		,Annualized_Allowance_STAT AS AnnualizedAllowance
		,Item_Allowance_STAT AS ItemAllowance
		<cfif arguments.margin_version eq "approved">
			FROM  dbo.Contract_Product_Margin_Approved CPM
		<cfelse>
			FROM  dbo.Contract_Product_Margin CPM
		</cfif>
	INNEr JOIN BSA_Foodservice_Items_Master
			ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = CPM.Product_Id
	INNER JOIN Type_Code_Desc
			ON Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
	LEFT JOIN Margin_Targets_Upload MTU
			ON MTU.BSA_Foodservice_Items_Master_ID  = CPM.Product_Id
	where 	contract_main_id = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar">
	<cfif isDefined("arguments.formCopy") and Not isDefined("arguments.formCopy.Agree") and agreeList neq "">
		and BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID not in (#ListQualify(agreeList, "'" , ",")#)
	</cfif>
	<cfif isDefined("arguments.formCopy") and Not isDefined("arguments.formCopy.Approve") and approveList neq "">
		and BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID not in (#ListQualify(approveList, "'" , ",")#)
	</cfif>
	<cfif isDefined("arguments.formCopy") and Not isDefined("arguments.formCopy.Restricted") and restrictedList neq "">
		and BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID not in (#ListQualify(restrictedList, "'" , ",")#)
	</cfif>
	and 	CPM.deleted = 0
	and 	CPM.Exclude_From_Margin = <cfqueryparam value="#arguments.excludeMarginItems#" cfsqltype="cf_sql_bit">
	<!--- 114617 :: Ideal Price START --->
	<cfif arguments.Lower_Than_Ideal>
		and CPM.FPR_STAT < CPM.Ideal_Price_STAT
	</cfif>
	<!--- 114617 :: Ideal Price END --->
	<!--- Dev Note: drachala; D28637: In View Margin Page Display Description text in order user selected START
    Added/Changed: Added IF condition to Order by--->
	order by Type_Code_Desc.Type_Code_Desc,Type_Code_Desc.Type_Code_Desc_ID,<cfif application.appSettingsGet.getViewPgmSortBy()>BSA_Foodservice_Items_Master.Description<cfelse>BSA_Foodservice_Items_Master.Item</cfif>
	<!--- End Dev Note: drachala; D: Item, Description Sort  --->
	</CFQUERY>
</cfif>
</cfif>
<!---<cfdump var="#qgetAllProductMargins#" output="c:\dump.html">--->
<cfreturn qgetAllProductMargins />
</cffunction>

<cffunction name="getAllGroupMargins" access="public" returntype="query">
	<cfargument name="program_id" type="string" required="true" />
	<cfargument name="Profiles_ID" type="string" required="true" />
	<cfargument name="margin_type" type="string" required="true" />
	<cfargument name="excludeMarginItems" type="boolean" required="false" default="0" />	<!--- D23601: margin items exclude--->
	<cfargument name="margin_version" type="string" required="false" default="current" />
	<cfargument name="Operator_program" type="boolean" required="false" default="0"/>
	<cfargument name="GlobalUom" type="numeric" required="false" default="0"/>
	<cfargument name="productGroupLevelId" type="numeric" required="false" default="0"/>
	<cfargument name="productGroupLevelFilterList" type="string" required="false" default=""/>

	<cfif application.appSettingsGet.getApprovalMarginType() eq 2><!--- Annual Case Rate --->
        <CFQUERY NAME="qgetAllGroupMargins" datasource="#application.datasource#">
            /*** components\programs\Approval\layered_program_approval.cfc - getAllGroupMargins() [ getApprovalMarginType() eq 2 ] ***/
			SELECT Distinct

			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 2 THEN ISNULL(SUM(Product_Program_Volume_LB),0) /* -- LB */
			ELSE ISNULL(SUM(Product_Program_Volume_CS),0) /* -- CS */
			END as Total_Product_Program_Volume ,

			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
				CASE Type_Code_Desc.Target_Case_Rate_UOM
				WHEN 2 THEN ISNULL(Sum(Product_Program_Volume_LB * Base_Sales_LB),0)/SUM(Product_Program_Volume_LB) /* -- LB */
				ELSE ISNULL(Sum(Product_Program_Volume_CS * Base_Sales_CS),0)/SUM(Product_Program_Volume_CS) /* -- CS */
				END
			ELSE 0 END as Total_Base_Sales,

			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
				CASE Type_Code_Desc.Target_Case_Rate_UOM
				WHEN 2 THEN ISNULL(SUM(Product_Program_Volume_LB* Cash_discount_LB),0)/SUM(Product_Program_Volume_LB) /* -- LB */
				ELSE ISNULL(SUM(Product_Program_Volume_CS* Cash_discount_CS),0)/SUM(Product_Program_Volume_CS) /* -- CS */
				END
			ELSE 0 END as Total_Cash_discount ,

			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
				CASE Type_Code_Desc.Target_Case_Rate_UOM
				WHEN 2 THEN ISNULL(SUM(Product_Program_Volume_LB*Pullbackamount_LB),0) /SUM(Product_Program_Volume_LB)
				ELSE ISNULL(SUM(Product_Program_Volume_CS*Pullbackamount_CS),0) /SUM(Product_Program_Volume_CS)
				END
			ELSE 0 END as Total_Pullbackamount,

			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
				CASE Type_Code_Desc.Target_Case_Rate_UOM
				WHEN 2 THEN ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0)/SUM(Product_Program_Volume_LB)
				ELSE ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0)/SUM(Product_Program_Volume_CS)
				END
			ELSE 0 END  as Total_Net_Sales,

			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
				CASE Type_Code_Desc.Target_Case_Rate_UOM
				WHEN 2 THEN ISNULL(SUM(Product_Program_Volume_LB * Cost_LB),0)/SUM(Product_Program_Volume_LB)
				ELSE ISNULL(SUM(Product_Program_Volume_CS * Cost_CS),0)/SUM(Product_Program_Volume_CS)
				END
			ELSE 0 END as Total_Cost,

			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
				CASE Type_Code_Desc.Target_Case_Rate_UOM
				WHEN 2 THEN ISNULL(SUM(Product_Program_Volume_LB*Operating_Income_LB),0)/SUM(Product_Program_Volume_LB)
				ELSE ISNULL(SUM(Product_Program_Volume_CS*Operating_Income_CS),0)/SUM(Product_Program_Volume_CS)
				END
			ELSE 0 END as Total_Operating_Income,

			CASE when Isnull(Sum(PRODUCT_PROGRAM_VOLUME_CS),0) != 0 then
				CASE Type_Code_Desc.Target_Case_Rate_UOM
				WHEN 2 THEN ISNULL(Sum(PRODUCT_PROGRAM_VOLUME_LB * TRADE_LB),0) / Sum(PRODUCT_PROGRAM_VOLUME_LB)
				ELSE ISNULL(Sum(PRODUCT_PROGRAM_VOLUME_CS * TRADE_CS),0) / Sum(PRODUCT_PROGRAM_VOLUME_CS)
				END
			ELSE 0 End As Total_Trade,

			CASE when Isnull(Sum(PRODUCT_PROGRAM_VOLUME_CS),0) != 0 then
				ISNULL(Sum(PRODUCT_PROGRAM_VOLUME_CS * TRADE_CS),0) / Sum(PRODUCT_PROGRAM_VOLUME_CS)
			ELSE 0 End As Total_Trade_CS,

			CASE when Isnull(Sum(PRODUCT_PROGRAM_VOLUME_CS),0) != 0 then
				ISNULL(Sum(PRODUCT_PROGRAM_VOLUME_LB * TRADE_LB),0) / Sum(PRODUCT_PROGRAM_VOLUME_LB)
			ELSE 0 End As Total_Trade_LB,

			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
				CASE Type_Code_Desc.Target_Case_Rate_UOM
				WHEN 2 THEN (ISNULL(SUM((Annualized_Lumpsum_Allowance_LB + Annualized_Allowance_LB) * Product_Program_Volume_LB),0) / SUM(Product_Program_Volume_LB))
				ELSE (ISNULL(SUM((Annualized_Lumpsum_Allowance_CS + Annualized_Allowance_CS) * Product_Program_Volume_CS),0) / SUM(Product_Program_Volume_CS))
				END
			ELSE 0 END as Total_Item_Allowance_Annualized,

			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
				CASE Type_Code_Desc.Target_Case_Rate_UOM
				WHEN 2 THEN (ISNULL(SUM((LumpsumAmount_LB+Item_Allowance_LB)*Product_Program_Volume_LB),0) / SUM(Product_Program_Volume_LB))
				ELSE (ISNULL(SUM((LumpsumAmount_CS+Item_Allowance_CS)*Product_Program_Volume_CS),0) / SUM(Product_Program_Volume_CS))
				END
			ELSE 0 END as Total_Item_Allowance,

			<!--- Total_OperatingMargin_percent --->
			<cfif application.appSettingsGet.getMarginOperatingIncomePercentType() eq 2><!--- Use Base Sales --->
			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 2 THEN
				CASE WHEN Round(isnull(SUM(Base_Sales_LB),0),3) = 0
				THEN 0
				else
					(CASE when ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) ELSE 0 END
					/CASE when ISNULL(SUM(Product_Program_Volume_LB * Base_Sales_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Base_Sales_LB),0) ELSE 1 END) * 100
				END
			ELSE
				CASE WHEN Round(isnull(SUM(Base_Sales_CS),0),3) = 0
				THEN 0
				else
					(CASE when ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) ELSE 0 END
					/CASE when ISNULL(SUM(Product_Program_Volume_CS * Base_Sales_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Base_Sales_CS),0) ELSE 1 END) * 100
				END
			END as Total_OperatingMargin_percent,
			<cfelse>
			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 2 THEN
				CASE WHEN Round(isnull(SUM(Net_Sales_LB),0),3) = 0
				THEN 0
				else
					case when (ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) < 0 and ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),1) < 0)
					then
						-((CASE when ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) ELSE 0 END
						/CASE when ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0) ELSE 1 END) * 100)
					else
						(CASE when ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) ELSE 0 END
						/CASE when ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0) ELSE 1 END) * 100
					end
				END
			ELSE
				CASE WHEN Round(isnull(SUM(Net_Sales_CS),0),3) = 0
				THEN 0
				else
					case when (ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) < 0 and ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),1) < 0)
					then
						-((CASE when ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) ELSE 0 END
						/CASE when ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0) ELSE 1 END) * 100)
					else
						(CASE when ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) ELSE 0 END
						/CASE when ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0) ELSE 1 END) * 100
					end
				END
			END as Total_OperatingMargin_percent,
			</cfif>

			CASE Type_Code_Desc.Target_Case_Rate_UOM
			WHEN 2 THEN
				CASE WHEN Round(isnull(SUM(BASE_SALES_LB),0),3) = 0
				THEN 0
				else
				case when (ISNULL(SUM(Product_Program_Volume_LB * Trade_LB),0) < 0 and ISNULL(SUM(Product_Program_Volume_LB * BASE_SALES_LB),1) < 0)
				then
				-((CASE when ISNULL(SUM(Product_Program_Volume_LB * Trade_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Trade_LB),0) ELSE 0 END
				/CASE when ISNULL(SUM(Product_Program_Volume_LB * BASE_SALES_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * BASE_SALES_LB),0) ELSE 1 END) * 100)
				else
				(CASE when ISNULL(SUM(Product_Program_Volume_LB * Trade_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Trade_LB),0) ELSE 0 END
				/CASE when ISNULL(SUM(Product_Program_Volume_LB * BASE_SALES_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * BASE_SALES_LB),0) ELSE 1 END) * 100
				end
				END
			ELSE
				CASE WHEN Round(isnull(SUM(BASE_SALES_CS),0),3) = 0
				THEN 0
				else
				case when (ISNULL(SUM(Product_Program_Volume_CS * Trade_CS),0) < 0 and ISNULL(SUM(Product_Program_Volume_CS * BASE_SALES_CS),1) < 0)
				then
				-((CASE when ISNULL(SUM(Product_Program_Volume_CS * Trade_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Trade_CS),0) ELSE 0 END
				/CASE when ISNULL(SUM(Product_Program_Volume_CS * BASE_SALES_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * BASE_SALES_CS),0) ELSE 1 END) * 100)
				else
				(CASE when ISNULL(SUM(Product_Program_Volume_CS * Trade_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Trade_CS),0) ELSE 0 END
				/CASE when ISNULL(SUM(Product_Program_Volume_CS * BASE_SALES_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * BASE_SALES_CS),0) ELSE 1 END) * 100
				end
				END
			END as Total_Trade_Percent

			,Type_Code_Desc.Type_Code_Desc_ID
			,Type_Code_Desc.Type_Code_Desc
			,ISNULL(Group_ID_Approval,0) as Group_ID_Approval

			<!--- 66894 --->
			<cfif arguments.Operator_program>
			,ISNULL((Type_Code_Desc.Target_Margin_Operator),0) as Target_Margin
			,ISNULL(Group_ID_Margin_Operator,0) as Group_ID_Margin
			<cfelse>
			,ISNULL((Type_Code_Desc.Target_Margin),0) as Target_Margin
			,ISNULL(Group_ID_Margin,0) as Group_ID_Margin
			</cfif>
			<!--- 66894 --->
			,ISNULL(NULLIF(Type_Code_Desc.Target_Margin_ListPrice,''),0) AS Target_Margin_ListPrice <!--- 72497 --->
			,ISNULL(Group_ID_List_Price,0) AS Group_ID_List_Price <!--- 72497 --->
			,CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
				CASE Type_Code_Desc.Target_Case_Rate_UOM
				WHEN 2 THEN ISNULL(SUM(Product_Program_Volume_LB* Broker_Cost_LB),0)/SUM(Product_Program_Volume_LB)
				ELSE ISNULL(SUM(Product_Program_Volume_CS* Broker_Cost_CS),0)/SUM(Product_Program_Volume_CS)
				END
			ELSE 0 END as Total_Brokerage
			<!--- 62143 --->
			,CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS* Fx_Man_Cost),0)/SUM(Product_Program_Volume_CS)
			ELSE
			0 END as Total_Fixed_Mfg_Cost
			<!--- 62143 --->
			,#case_lb_column_by_volume("Allowance_Surcharges")# AS Total_Allowance_Surcharges2
			,#case_lb_column_by_volume("Customer_Freight")#     AS Total_Customer_Freight
			,#case_lb_column_by_volume("TPA_Oper")#             AS Total_TPA_Oper
			,#case_lb_column_by_volume("TPA")#                  AS Total_TPA
			,#case_lb_column_by_volume("Shuttle_Freight")#      AS Total_Shuttle_Freight
			,#case_lb_column_by_volume("Other_Spend")#          AS Total_Other_Spend
			,#case_lb_column_by_volume("Custom_Warehouse")#     AS Total_Custom_Warehouse
			,#case_lb_column_by_volume("Gross_Margin")#         AS Total_Gross_Margin
			,#case_lb_column_by_volume("Custom_Brokerage")#     AS Total_Custom_Brokerage
			,#case_lb_column_by_volume("Map_Mdf")#              AS Total_Map_Mdf
			,#case_lb_column_by_volume("SGA")#                  AS Total_SGA
			,#case_lb_column_by_volume("Contribution_Margin_Alt")#      AS Total_Contribution_Margin_Alt
			,#case_lb_column_by_volume("Variable_Contribution_Margin")# AS Total_Variable_Contribution_Margin
		<cfif arguments.margin_version eq "approved">
			FROM  dbo.Contract_Product_Margin_Approved CPM
		<cfelse>
			FROM  dbo.Contract_Product_Margin CPM
		</cfif>
			INNEr JOIN BSA_Foodservice_Items_Master
			ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = CPM.Product_Id
			INNER JOIN Type_Code_Desc
			ON Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
			LEFT JOIN Group_Approval_Rights ON
			Group_Approval_Rights.Group_ID = Type_Code_Desc.Type_Code_Desc_ID
			and Group_Approval_Rights.User_Profile_ID = <cfqueryparam value="#arguments.Profiles_ID#" cfsqltype="cf_sql_varchar">
			and Group_Approval_Rights.deleted = 0
			where contract_main_id = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar">
			and CPM.deleted = 0
			and CPM.Exclude_From_Margin = <cfqueryparam value="#arguments.excludeMarginItems#" cfsqltype="cf_sql_bit">
			group by Type_Code_Desc.Type_Code_Desc,Type_Code_Desc.Type_Code_Desc_ID,Group_ID_Approval,Type_Code_Desc.Target_Case_Rate_UOM
			<!--- 66894 --->
			<cfif arguments.Operator_program>
			,Type_Code_Desc.Target_Margin_Operator
			,Group_ID_Margin_Operator
			<cfelse>
			,Type_Code_Desc.Target_Margin
			,Group_ID_Margin
			</cfif>
			<!--- 66894 --->
			,Target_Margin_ListPrice
			,Group_ID_List_Price
			order by Type_Code_Desc.Type_Code_Desc
		</CFQUERY>

	<cfelse>

	<cfscript>
		if(arguments.productGroupLevelId eq 0)
		arguments.productGroupLevelId = 12; // Default = Type code

		var local.prdGroupAttributes = CreateObject("component","components.products.Group.ProductGroupAttributeManager").getProductGroupAttributes(groupLevelId=arguments.productGroupLevelId);


	</cfscript>

	<cfif arguments.margin_type EQ 1>
		<CFQUERY NAME="qgetAllGroupMargins" datasource="#application.datasource#">
            /*** components\programs\Approval\layered_program_approval.cfc - getAllGroupMargins() [ arguments.margin_type EQ 1  ] ***/
			SELECT Distinct ISNULL(SUM(Product_Program_Volume_CS),0) as Total_Product_Program_Volume ,
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_CS * Base_Sales_CS),0)/SUM(Product_Program_Volume_CS)
			ELSE
			0 END as Total_Base_Sales,
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS* Cash_discount_CS),0)/SUM(Product_Program_Volume_CS)
			ELSE 0 END as Total_Cash_discount ,
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS*Pullbackamount_CS),0) /SUM(Product_Program_Volume_CS)
			ELSE 0 END as Total_Pullbackamount,
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0)/SUM(Product_Program_Volume_CS)
			ELSE 0 END  as Total_Net_Sales,
		<!--- 70104	Absolute Net Sales $ per Lb or Equiv Case START --->
		<cfif arguments.GlobalUom EQ 1>
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0)/SUM(Product_Program_Volume_CS)
			ELSE 0 END  as Global_Total_Margin,
		<cfelseif arguments.GlobalUom EQ 2>
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0)/SUM(Product_Program_Volume_LB)
			ELSE 0 END  as Global_Total_Margin,
		<cfelseif arguments.GlobalUom EQ 3>
			CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_STAT * Net_Sales_STAT),0)/SUM(Product_Program_Volume_STAT)
			ELSE 0 END  as Global_Total_Margin,
		</cfif>
		<!--- 70104	Absolute Net Sales $ per Lb or Equiv Case END --->
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS * Cost_CS),0)/SUM(Product_Program_Volume_CS)
			ELSE 0 END as Total_Cost,
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS*Operating_Income_CS),0)/SUM(Product_Program_Volume_CS)
			ELSE 0 END as Total_Operating_Income,
			CASE when Isnull(Sum(PRODUCT_PROGRAM_VOLUME_CS),0) != 0 then
				ISNULL(Sum(PRODUCT_PROGRAM_VOLUME_CS * TRADE_CS),0) / Sum(PRODUCT_PROGRAM_VOLUME_CS)
			ELSE 0 End As Total_Trade,
			CASE when Isnull(Sum(PRODUCT_PROGRAM_VOLUME_CS),0) != 0 then
				ISNULL(Sum(PRODUCT_PROGRAM_VOLUME_CS * TRADE_CS),0) / Sum(PRODUCT_PROGRAM_VOLUME_CS)
			ELSE 0 End As Total_Trade_CS,
			CASE when Isnull(Sum(PRODUCT_PROGRAM_VOLUME_LB),0) != 0 then
				ISNULL(Sum(PRODUCT_PROGRAM_VOLUME_LB * TRADE_LB),0) / Sum(PRODUCT_PROGRAM_VOLUME_LB)
			ELSE 0 End As Total_Trade_LB,
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			(ISNULL(SUM((Annualized_Lumpsum_Allowance_CS + Annualized_Allowance_CS) * Product_Program_Volume_CS),0) / SUM(Product_Program_Volume_CS))
			ELSE 0 END as Total_Item_Allowance_Annualized,
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			(ISNULL(SUM((LumpsumAmount_CS+Item_Allowance_CS)*Product_Program_Volume_CS),0) / SUM(Product_Program_Volume_CS))
			ELSE 0 END as Total_Item_Allowance,

			<!--- Total_OperatingMargin_percent --->
			<cfif application.appSettingsGet.getMarginOperatingIncomePercentType() eq 2><!--- Use Base Sales --->
			CASE WHEN Round(isnull(SUM(Base_Sales_CS),0),3) = 0
			THEN 0
			else
				(CASE when ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) ELSE 0 END
				/CASE when ISNULL(SUM(Product_Program_Volume_CS * Base_Sales_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Base_Sales_CS),0) ELSE 1 END) * 100
			END as Total_OperatingMargin_percent,
			<cfelse>
			CASE WHEN Round(isnull(SUM(Net_Sales_CS),0),3) = 0
			THEN 0
			else
				case when (ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) < 0 and ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),1) < 0)
				then
					-((CASE when ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) ELSE 0 END
					/CASE when ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0) ELSE 1 END) * 100)
				else
					(CASE when ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) ELSE 0 END
					/CASE when ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0) ELSE 1 END) * 100
				end
			END as Total_OperatingMargin_percent,
			</cfif>

			CASE WHEN Round(isnull(SUM(BASE_SALES_CS),0),3) = 0
			THEN 0
			else
			case when (ISNULL(SUM(Product_Program_Volume_CS * Trade_CS),0) < 0 and ISNULL(SUM(Product_Program_Volume_CS * BASE_SALES_CS),1) < 0)
			then
			-((CASE when ISNULL(SUM(Product_Program_Volume_CS * Trade_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Trade_CS),0) ELSE 0 END
			/CASE when ISNULL(SUM(Product_Program_Volume_CS * BASE_SALES_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * BASE_SALES_CS),0) ELSE 1 END) * 100)
			else
			(CASE when ISNULL(SUM(Product_Program_Volume_CS * Trade_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Trade_CS),0) ELSE 0 END
			/CASE when ISNULL(SUM(Product_Program_Volume_CS * BASE_SALES_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * BASE_SALES_CS),0) ELSE 1 END) * 100
			end
			END as Total_Trade_Percent

			,grp.#local.prdGroupAttributes.Product_Group_Attribute_ID_Field# as Type_Code_Desc_ID,
			grp.#local.prdGroupAttributes.Product_Group_Attribute_Name_Field# as Type_Code_Desc
			,ISNULL(Group_ID_Approval,0) as Group_ID_Approval
			<!--- 66894 --->
			<cfif arguments.productGroupLevelId neq 12>
			,0 as Target_Margin
			,0 as Group_ID_Margin
			,0 AS Target_Margin_ListPrice
			<cfelse>
				<cfif arguments.Operator_program>
				,ISNULL((grp.Target_Margin_Operator),0) as Target_Margin
				,ISNULL(Group_ID_Margin_Operator,0) as Group_ID_Margin
				<cfelse>
				,ISNULL((grp.Target_Margin),0) as Target_Margin
				,ISNULL(Group_ID_Margin,0) as Group_ID_Margin
				</cfif>
				<!--- 66894 --->
				,ISNULL(NULLIF(grp.Target_Margin_ListPrice,''),0) AS Target_Margin_ListPrice <!--- 72497 --->
			</cfif>
			,ISNULL(Group_ID_List_Price,0) AS Group_ID_List_Price <!--- 72497 --->
			,CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS* Broker_Cost_CS),0)/SUM(Product_Program_Volume_CS)
			ELSE 0 END as Total_Brokerage
			,ISNULL(SUM(Product_Program_Volume_LB),0) as Total_Product_Program_Volume_LB
			<!--- 62143 --->
			,CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_CS * Fx_Man_Cost),0)/SUM(Product_Program_Volume_CS)
			ELSE
			0 END as Total_Fixed_Mfg_Cost
			,#column_by_volume("Allowance_Surcharges_CS")# AS Total_Allowance_Surcharges
			,#column_by_volume("Customer_Freight_CS")#     AS Total_Customer_Freight
			,#column_by_volume("TPA_Oper_CS")#             AS Total_TPA_Oper
			,#column_by_volume("TPA_CS")#                  AS Total_TPA
			,#column_by_volume("Shuttle_Freight_CS")#      AS Total_Shuttle_Freight
			,#column_by_volume("Other_Spend_CS")#          AS Total_Other_Spend
			,#column_by_volume("Custom_Warehouse_CS")#     AS Total_Custom_Warehouse
			,#column_by_volume("Gross_Margin_CS")#         AS Total_Gross_Margin
			,#column_by_volume("Custom_Brokerage_CS")#     AS Total_Custom_Brokerage
			,#column_by_volume("Map_Mdf_CS")#              AS Total_Map_Mdf
			,#column_by_volume("SGA_CS")#                  AS Total_SGA
			,#column_by_volume("Contribution_Margin_Alt_CS")#      AS Total_Contribution_Margin_Alt
			,#column_by_volume("Variable_Contribution_Margin_CS")# AS Total_Variable_Contribution_Margin
			<!--- 62143 --->
			,CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_CS * MTU.Net_Sales_Target_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5))),0)/SUM(Product_Program_Volume_CS)
			ELSE
			0 END as Net_Sales_Target_Value
			,CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_CS * MTU.Net_Sales_Floor_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5))),0)/SUM(Product_Program_Volume_CS)
			ELSE
			0 END as Net_Sales_Floor_Value
			,CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_CS * MTU.GM_Target_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5))),0)/SUM(Product_Program_Volume_CS)
			ELSE
			0 END as GM_Target_Value
			,CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_CS * MTU.GM_Floor_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5))),0)/SUM(Product_Program_Volume_CS)
			ELSE
			0 END as GM_Floor_Value
		<cfif arguments.margin_version eq "approved">
			FROM  dbo.Contract_Product_Margin_Approved CPM
		<cfelse>
			FROM  dbo.Contract_Product_Margin CPM
		</cfif>
			INNEr JOIN BSA_Foodservice_Items_Master
			ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = CPM.Product_Id
			INNER JOIN #local.prdGroupAttributes.Product_Group_Attribute_Table# as grp
			ON grp.#local.prdGroupAttributes.Product_Group_Attribute_ID_Field# = BSA_Foodservice_Items_Master.#local.prdGroupAttributes.Product_Group_Attribute_Master_ID_Field#
			LEFT JOIN Group_Approval_Rights ON
			Group_Approval_Rights.Group_ID = grp.#local.prdGroupAttributes.Product_Group_Attribute_ID_Field#
			and Group_Approval_Rights.User_Profile_ID = <cfqueryparam value="#arguments.Profiles_ID#" cfsqltype="cf_sql_varchar">
			and Group_Approval_Rights.deleted = 0
			LEFT JOIN Margin_Targets_Upload MTU
			ON MTU.BSA_Foodservice_Items_Master_ID  = CPM.Product_Id
			where contract_main_id = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar">
			and CPM.deleted = 0
			and CPM.Exclude_From_Margin = <cfqueryparam value="#arguments.excludeMarginItems#" cfsqltype="cf_sql_bit">
			<cfif arguments.productGroupLevelFilterList neq "">
			and grp.#local.prdGroupAttributes.Product_Group_Attribute_ID_Field# in (<cfqueryparam value="#arguments.productGroupLevelFilterList#" cfsqltype="cf_sql_varchar" list="yes">)
			</cfif>
			group by grp.#local.prdGroupAttributes.Product_Group_Attribute_Name_Field#,grp.#local.prdGroupAttributes.Product_Group_Attribute_ID_Field#,Group_ID_Approval
			<!--- 66894 --->
			<cfif arguments.productGroupLevelId neq 12>
				--Do Nothing
			<cfelse>
				<cfif arguments.Operator_program>
					,grp.Target_Margin_Operator
					,Group_ID_Margin_Operator
				<cfelse>
					,grp.Target_Margin
					,Group_ID_Margin
				</cfif>
				<!--- 66894 --->
				,Target_Margin_ListPrice <!--- 72497 --->
			</cfif>
			,Group_ID_List_Price <!--- 72497 --->
			order by grp.#local.prdGroupAttributes.Product_Group_Attribute_Name_Field#
		</CFQUERY>
	<cfelseif arguments.margin_type EQ 3>
		<CFQUERY NAME="qgetAllGroupMargins" datasource="#application.datasource#">
            /*** components\programs\Approval\layered_program_approval.cfc - getAllGroupMargins() [ arguments.margin_type EQ 3 ] ***/
			SELECT Distinct ISNULL(SUM(Product_Program_Volume_LB),0) as Total_Product_Program_Volume ,
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_LB * Base_Sales_LB),0)/SUM(Product_Program_Volume_LB)
			ELSE
			0 END as Total_Base_Sales,
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB* Cash_discount_LB),0)/SUM(Product_Program_Volume_LB)
			ELSE 0 END as Total_Cash_discount ,
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB*Pullbackamount_LB),0) /SUM(Product_Program_Volume_LB)
			ELSE 0 END as Total_Pullbackamount,
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0)/SUM(Product_Program_Volume_LB)
			ELSE 0 END  as Total_Net_Sales,
		<!--- 70104	Absolute Net Sales $ per Lb or Equiv Case START --->
		<cfif arguments.GlobalUom EQ 1>
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0)/SUM(Product_Program_Volume_CS)
			ELSE 0 END  as Global_Total_Margin,
		<cfelseif arguments.GlobalUom EQ 2>
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0)/SUM(Product_Program_Volume_LB)
			ELSE 0 END  as Global_Total_Margin,
		<cfelseif arguments.GlobalUom EQ 3>
			CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_STAT * Net_Sales_STAT),0)/SUM(Product_Program_Volume_STAT)
			ELSE 0 END  as Global_Total_Margin,
		</cfif>
		<!--- 70104	Absolute Net Sales $ per Lb or Equiv Case END --->
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB * Cost_LB),0)/SUM(Product_Program_Volume_LB)
			ELSE 0 END as Total_Cost,
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB*Operating_Income_LB),0)/SUM(Product_Program_Volume_LB)
			ELSE 0 END as Total_Operating_Income,
			CASE when Isnull(Sum(PRODUCT_PROGRAM_VOLUME_LB),0) != 0 then
				ISNULL(Sum(PRODUCT_PROGRAM_VOLUME_LB * TRADE_LB),0) / Sum(PRODUCT_PROGRAM_VOLUME_LB)
			ELSE 0 End As Total_Trade,
			CASE when Isnull(Sum(PRODUCT_PROGRAM_VOLUME_CS),0) != 0 then
				ISNULL(Sum(PRODUCT_PROGRAM_VOLUME_CS * TRADE_CS),0) / Sum(PRODUCT_PROGRAM_VOLUME_CS)
			ELSE 0 End As Total_Trade_CS,
			CASE when Isnull(Sum(PRODUCT_PROGRAM_VOLUME_LB),0) != 0 then
				ISNULL(Sum(PRODUCT_PROGRAM_VOLUME_LB * TRADE_LB),0) / Sum(PRODUCT_PROGRAM_VOLUME_LB)
			ELSE 0 End As Total_Trade_LB,
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			(ISNULL(SUM((Annualized_Lumpsum_Allowance_LB + Annualized_Allowance_LB) * Product_Program_Volume_LB),0) / SUM(Product_Program_Volume_LB))
			ELSE 0 END as Total_Item_Allowance_Annualized,
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			(ISNULL(SUM((LumpsumAmount_LB+Item_Allowance_LB)*Product_Program_Volume_LB),0) / SUM(Product_Program_Volume_LB))
			ELSE 0 END as Total_Item_Allowance,

			<!--- Total_OperatingMargin_percent --->
			<cfif application.appSettingsGet.getMarginOperatingIncomePercentType() eq 2><!--- Use Base Sales --->
			CASE WHEN Round(isnull(SUM(Base_Sales_LB),0),3) = 0
			THEN 0
			else
				(CASE when ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) ELSE 0 END
				/CASE when ISNULL(SUM(Product_Program_Volume_LB * Base_Sales_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Base_Sales_LB),0) ELSE 1 END) * 100
			END as Total_OperatingMargin_percent,
			<cfelse>
			CASE WHEN Round(isnull(SUM(Net_Sales_LB),0),3) = 0
			THEN 0
			else
				case when (ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) < 0 and ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),1) < 0)
				then
					-((CASE when ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) ELSE 0 END
					/CASE when ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0) ELSE 1 END) * 100)
				else
					(CASE when ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) ELSE 0 END
					/CASE when ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0) ELSE 1 END) * 100
				end
			END as Total_OperatingMargin_percent,
			</cfif>

			CASE WHEN Round(isnull(SUM(BASE_SALES_LB),0),3) = 0
			THEN 0
			else
			case when (ISNULL(SUM(Product_Program_Volume_LB * Trade_LB),0) < 0 and ISNULL(SUM(Product_Program_Volume_LB * BASE_SALES_LB),1) < 0)
			then
			-((CASE when ISNULL(SUM(Product_Program_Volume_LB * Trade_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Trade_LB),0) ELSE 0 END
			/CASE when ISNULL(SUM(Product_Program_Volume_LB * BASE_SALES_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * BASE_SALES_LB),0) ELSE 1 END) * 100)
			else
			(CASE when ISNULL(SUM(Product_Program_Volume_LB * Trade_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Trade_LB),0) ELSE 0 END
			/CASE when ISNULL(SUM(Product_Program_Volume_LB * BASE_SALES_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * BASE_SALES_LB),0) ELSE 1 END) * 100
			end
			END as Total_Trade_Percent
			,grp.#local.prdGroupAttributes.Product_Group_Attribute_ID_Field# as Type_Code_Desc_ID
			,grp.#local.prdGroupAttributes.Product_Group_Attribute_Name_Field# as Type_Code_Desc
			,ISNULL(Group_ID_Approval,0) as Group_ID_Approval
			<!--- 66894 --->
			<cfif arguments.productGroupLevelId neq 12>
			,0 as Target_Margin
			,0 as Group_ID_Margin
			,0 AS Target_Margin_ListPrice
			<cfelse>
				<cfif arguments.Operator_program>
				,ISNULL((grp.Target_Margin_Operator),0) as Target_Margin
				,ISNULL(Group_ID_Margin_Operator,0) as Group_ID_Margin
				<cfelse>
				,ISNULL((grp.Target_Margin),0) as Target_Margin
				,ISNULL(Group_ID_Margin,0) as Group_ID_Margin
				</cfif>
				<!--- 66894 --->
				,ISNULL(NULLIF(grp.Target_Margin_ListPrice,''),0) AS Target_Margin_ListPrice <!--- 72497 --->
			</cfif>
			,ISNULL(Group_ID_List_Price,0) AS Group_ID_List_Price <!--- 72497 --->
			,CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB* Broker_Cost_LB),0)/SUM(Product_Program_Volume_LB)
			ELSE 0 END as Total_Brokerage
			<!--- 62143 --->
			,CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_LB * ISNULL(Fx_Man_Cost,0)/CAST(BSA_Foodservice_Items_Master.Net_Weight as float)),0)/SUM(Product_Program_Volume_LB)
			ELSE
			0 END as Total_Fixed_Mfg_Cost
			<!--- 62143 --->
			,#column_by_volume("Allowance_Surcharges_LB")# AS Total_Allowance_Surcharges
			,#column_by_volume("Customer_Freight_LB")#     AS Total_Customer_Freight
			,#column_by_volume("TPA_Oper_LB")#             AS Total_TPA_Oper
			,#column_by_volume("TPA_LB")#                  AS Total_TPA
			,#column_by_volume("Shuttle_Freight_LB")#      AS Total_Shuttle_Freight
			,#column_by_volume("Other_Spend_LB")#          AS Total_Other_Spend
			,#column_by_volume("Custom_Warehouse_LB")#     AS Total_Custom_Warehouse
			,#column_by_volume("Gross_Margin_LB")#         AS Total_Gross_Margin
			,#column_by_volume("Custom_Brokerage_LB")#     AS Total_Custom_Brokerage
			,#column_by_volume("Map_Mdf_LB")#              AS Total_Map_Mdf
			,#column_by_volume("SGA_LB")#                  AS Total_SGA
			,#column_by_volume("Contribution_Margin_Alt_LB")#      AS Total_Contribution_Margin_Alt
			,#column_by_volume("Variable_Contribution_Margin_LB")# AS Total_Variable_Contribution_Margin
			,CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_LB * MTU.Net_Sales_Target_Value),0)/SUM(Product_Program_Volume_LB)
			ELSE
			0 END as Net_Sales_Target_Value
			,CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_LB * MTU.Net_Sales_Floor_Value),0)/SUM(Product_Program_Volume_LB)
			ELSE
			0 END as Net_Sales_Floor_Value
			,CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_LB * MTU.GM_Target_Value),0)/SUM(Product_Program_Volume_LB)
			ELSE
			0 END as GM_Target_Value
			,CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_LB * MTU.GM_Floor_Value),0)/SUM(Product_Program_Volume_LB)
			ELSE
			0 END as GM_Floor_Value
		<cfif arguments.margin_version eq "approved">
			FROM  dbo.Contract_Product_Margin_Approved CPM
		<cfelse>
			FROM  dbo.Contract_Product_Margin CPM
		</cfif>
			INNEr JOIN BSA_Foodservice_Items_Master
			ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = CPM.Product_Id
			INNER JOIN #local.prdGroupAttributes.Product_Group_Attribute_Table# as grp
			ON grp.#local.prdGroupAttributes.Product_Group_Attribute_ID_Field# = BSA_Foodservice_Items_Master.#local.prdGroupAttributes.Product_Group_Attribute_Master_ID_Field#
			LEFT JOIN Group_Approval_Rights ON
			Group_Approval_Rights.Group_ID = grp.#local.prdGroupAttributes.Product_Group_Attribute_ID_Field#
			and Group_Approval_Rights.User_Profile_ID = <cfqueryparam value="#arguments.Profiles_ID#" cfsqltype="cf_sql_varchar">
			and Group_Approval_Rights.deleted = 0
			LEFT JOIN Margin_Targets_Upload MTU
			ON MTU.BSA_Foodservice_Items_Master_ID  = CPM.Product_Id
			where contract_main_id = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar">
			and CPM.deleted = 0
			and CPM.Exclude_From_Margin = <cfqueryparam value="#arguments.excludeMarginItems#" cfsqltype="cf_sql_bit">
			<cfif arguments.productGroupLevelFilterList neq "">
			and grp.#local.prdGroupAttributes.Product_Group_Attribute_ID_Field# in (<cfqueryparam value="#arguments.productGroupLevelFilterList#" cfsqltype="cf_sql_varchar" list="yes">)
			</cfif>
			group by grp.#local.prdGroupAttributes.Product_Group_Attribute_Name_Field#,grp.#local.prdGroupAttributes.Product_Group_Attribute_ID_Field#,Group_ID_Approval
			<!--- 66894 --->
			<cfif arguments.productGroupLevelId neq 12>
				--Do Nothing
			<cfelse>
				<cfif arguments.Operator_program>
				,grp.Target_Margin_Operator
				,Group_ID_Margin_Operator
				<cfelse>
				,grp.Target_Margin
				,Group_ID_Margin
				</cfif>
				<!--- 66894 --->
				,Target_Margin_ListPrice <!--- 72497 --->
			</cfif>
			,Group_ID_List_Price <!--- 72497 --->
			order by grp.#local.prdGroupAttributes.Product_Group_Attribute_Name_Field#
		</CFQUERY>
	<cfelse>
		<CFQUERY NAME="qgetAllGroupMargins" datasource="#application.datasource#">
            /*** components\programs\Approval\layered_program_approval.cfc - getAllGroupMargins() [ around line 1102  ] ***/
			SELECT Distinct ISNULL(SUM(Product_Program_Volume_STAT),0) as Total_Product_Program_Volume ,
			CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_STAT * Base_Sales_STAT),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as Total_Base_Sales ,
			CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_STAT * Cash_discount_STAT),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as Total_Cash_discount ,
			CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_STAT*Pullbackamount_STAT),0) /SUM(Product_Program_Volume_STAT)
			ELSE 0 END as Total_Pullbackamount,
			CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_STAT * Net_Sales_STAT),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as Total_Net_Sales,
		<!--- 70104	Absolute Net Sales $ per Lb or Equiv Case START --->
		<cfif arguments.GlobalUom EQ 1>
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0)/SUM(Product_Program_Volume_CS)
			ELSE 0 END  as Global_Total_Margin,
		<cfelseif arguments.GlobalUom EQ 2>
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0)/SUM(Product_Program_Volume_LB)
			ELSE 0 END  as Global_Total_Margin,
		<cfelseif arguments.GlobalUom EQ 3>
			CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_STAT * Net_Sales_STAT),0)/SUM(Product_Program_Volume_STAT)
			ELSE 0 END  as Global_Total_Margin,
		</cfif>
		<!--- 70104	Absolute Net Sales $ per Lb or Equiv Case END --->
			CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_STAT * Cost_STAT),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as Total_Cost,
			CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_STAT *Operating_Income_STAT),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as Total_Operating_Income,
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB*Trade_STAT),0)/SUM(Product_Program_Volume_LB)
			ELSE
			0 END as Total_Trade,
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB*Trade_STAT),0)/SUM(Product_Program_Volume_LB)
			ELSE
			0 END as Total_Trade_LB,
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS*Trade_STAT),0)/SUM(Product_Program_Volume_CS)
			ELSE
			0 END as Total_Trade_CS,
			CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			(ISNULL(SUM((Annualized_Lumpsum_Allowance_STAT + Annualized_Allowance_STAT) * Product_Program_Volume_STAT),0) / SUM(Product_Program_Volume_STAT))
			ELSE 0 END as Total_Item_Allowance_Annualized,
			CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			(ISNULL(SUM(Product_Program_Volume_STAT * Item_Allowance_STAT),0)/SUM(Product_Program_Volume_STAT)  + ISNULL(SUM(LumpsumAmount_STAT),0))
			ELSE
			0 END as Total_Item_Allowance,
			<!--- Total_OperatingMargin_percent --->
			<cfif application.appSettingsGet.getMarginOperatingIncomePercentType() eq 2><!--- Use Base Sales --->
			CASE WHEN Round(isnull(SUM(Base_Sales_STAT),0),3) = 0
			THEN 0
			else
				(CASE when ISNULL(SUM(Product_Program_Volume_STAT * Operating_Income_STAT),0) !=0 then ISNULL(SUM(Product_Program_Volume_STAT * Operating_Income_STAT),0) ELSE 0 END
				/CASE when ISNULL(SUM(Product_Program_Volume_STAT * Base_Sales_STAT),0) !=0 then ISNULL(SUM(Product_Program_Volume_STAT * Base_Sales_STAT),0) ELSE 1 END) * 100
			END as Total_OperatingMargin_percent,
			<cfelse>
			CASE WHEN Round(isnull(SUM(Net_Sales_STAT),0),3) = 0
			THEN 0
			else
			case when (ISNULL(SUM(Product_Program_Volume_STAT * Operating_Income_STAT),0) < 0 and ISNULL(SUM(Product_Program_Volume_STAT * Net_Sales_STAT),1) < 0)
			then
			-((CASE when ISNULL(SUM(Product_Program_Volume_STAT * Operating_Income_STAT),0) !=0 then ISNULL(SUM(Product_Program_Volume_STAT * Operating_Income_STAT),0) ELSE 0 END
			/CASE when ISNULL(SUM(Product_Program_Volume_STAT * Net_Sales_STAT),0) !=0 then ISNULL(SUM(Product_Program_Volume_STAT * Net_Sales_STAT),0) ELSE 1 END) * 100)
			else
			(CASE when ISNULL(SUM(Product_Program_Volume_STAT * Operating_Income_STAT),0) !=0 then ISNULL(SUM(Product_Program_Volume_STAT * Operating_Income_STAT),0) ELSE 0 END
			/CASE when ISNULL(SUM(Product_Program_Volume_STAT * Net_Sales_STAT),0) !=0 then ISNULL(SUM(Product_Program_Volume_STAT * Net_Sales_STAT),0) ELSE 1 END) * 100
			end
			END as Total_OperatingMargin_percent,
			</cfif>

			CASE WHEN Round(isnull(SUM(BASE_SALES_STAT),0),3) = 0
			THEN 0
			else
			case when (ISNULL(SUM(Product_Program_Volume_STAT * Trade_STAT),0) < 0 and ISNULL(SUM(Product_Program_Volume_STAT * BASE_SALES_STAT),1) < 0)
			then
			-((CASE when ISNULL(SUM(Product_Program_Volume_STAT * Trade_STAT),0) !=0 then ISNULL(SUM(Product_Program_Volume_STAT * Trade_STAT),0) ELSE 0 END
			/CASE when ISNULL(SUM(Product_Program_Volume_STAT * BASE_SALES_STAT),0) !=0 then ISNULL(SUM(Product_Program_Volume_STAT * BASE_SALES_STAT),0) ELSE 1 END) * 100)
			else
			(CASE when ISNULL(SUM(Product_Program_Volume_STAT * Trade_STAT),0) !=0 then ISNULL(SUM(Product_Program_Volume_STAT * Trade_STAT),0) ELSE 0 END
			/CASE when ISNULL(SUM(Product_Program_Volume_STAT * BASE_SALES_STAT),0) !=0 then ISNULL(SUM(Product_Program_Volume_STAT * BASE_SALES_STAT),0) ELSE 1 END) * 100
			end
			END as Total_Trade_Percent
			,grp.#local.prdGroupAttributes.Product_Group_Attribute_ID_Field# as Type_Code_Desc_ID
			,grp.#local.prdGroupAttributes.Product_Group_Attribute_Name_Field# as Type_Code_Desc
			,ISNULL(Group_ID_Approval,0) as Group_ID_Approval
			<!--- 66894 --->
			<cfif arguments.productGroupLevelId neq 12>
			,0 as Target_Margin
			,0 as Group_ID_Margin
			,0 AS Target_Margin_ListPrice
			<cfelse>
				<cfif arguments.Operator_program>
					,ISNULL((grp.Target_Margin_Operator),0) as Target_Margin
					,ISNULL(Group_ID_Margin_Operator,0) as Group_ID_Margin
				<cfelse>
					,ISNULL((grp.Target_Margin),0) as Target_Margin
					,ISNULL(Group_ID_Margin,0) as Group_ID_Margin
				</cfif>
				<!--- 66894 --->
				,ISNULL(NULLIF(grp.Target_Margin_ListPrice,''),0) AS Target_Margin_ListPrice <!--- 72497 --->
			</cfif>
			,ISNULL(Group_ID_List_Price,0) AS Group_ID_List_Price <!--- 72497 --->
			<!---D37829 Program Summary Volume Not Totaling --->
			,CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_STAT* Broker_Cost_CS / BSA_Foodservice_Items_Master.Case_Equivalent),0)/SUM(Product_Program_Volume_STAT)
			ELSE 0 END as Total_Brokerage
			<!---D37829 Program Summary Volume Not Totaling --->

			<!--- 62143 --->
			,CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_STAT * ISNULL(Fx_Man_Cost,0)/BSA_Foodservice_Items_Master.CASE_EQUIVALENT),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as Total_Fixed_Mfg_Cost
			<!--- 62143 --->
			,#column_by_volume("Allowance_Surcharges_STAT")# AS Total_Allowance_Surcharges
			,#column_by_volume("Customer_Freight_STAT")#     AS Total_Customer_Freight
			,#column_by_volume("TPA_Oper_STAT")#             AS Total_TPA_Oper
			,#column_by_volume("TPA_STAT")#                  AS Total_TPA
			,#column_by_volume("Shuttle_Freight_STAT")#      AS Total_Shuttle_Freight
			,#column_by_volume("Other_Spend_STAT")#          AS Total_Other_Spend
			,#column_by_volume("Custom_Warehouse_STAT")#     AS Total_Custom_Warehouse
			,#column_by_volume("Gross_Margin_STAT")#         AS Total_Gross_Margin
			,#column_by_volume("Custom_Brokerage_STAT")#     AS Total_Custom_Brokerage
			,#column_by_volume("Map_Mdf_STAT")#              AS Total_Map_Mdf
			,#column_by_volume("SGA_STAT")#                  AS Total_SGA
			,#column_by_volume("Contribution_Margin_Alt_STAT")#      AS Total_Contribution_Margin_Alt
			,#column_by_volume("Variable_Contribution_Margin_STAT")# AS Total_Variable_Contribution_Margin
			,CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_STAT * MTU.Net_Sales_Target_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5)) / NULLIF(CAST(BSA_Foodservice_Items_Master.Case_Equivalent as DECIMAL(20, 5)), 0)),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as Net_Sales_Target_Value
			,CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_STAT * MTU.Net_Sales_Floor_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5)) / NULLIF(CAST(BSA_Foodservice_Items_Master.Case_Equivalent as DECIMAL(20, 5)), 0)),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as Net_Sales_Floor_Value
			,CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_STAT * MTU.GM_Target_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5)) / NULLIF(CAST(BSA_Foodservice_Items_Master.Case_Equivalent as DECIMAL(20, 5)), 0)),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as GM_Target_Value
			,CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_STAT * MTU.GM_Floor_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5)) / NULLIF(CAST(BSA_Foodservice_Items_Master.Case_Equivalent as DECIMAL(20, 5)), 0)),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as GM_Floor_Value
		<cfif arguments.margin_version eq "approved">
			FROM  dbo.Contract_Product_Margin_Approved CPM
		<cfelse>
			FROM  dbo.Contract_Product_Margin CPM
		</cfif>
			INNEr JOIN BSA_Foodservice_Items_Master
			ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = CPM.Product_Id
			INNER JOIN #local.prdGroupAttributes.Product_Group_Attribute_Table# as grp
			ON grp.#local.prdGroupAttributes.Product_Group_Attribute_ID_Field# = BSA_Foodservice_Items_Master.#local.prdGroupAttributes.Product_Group_Attribute_Master_ID_Field#
			LEFT JOIN Group_Approval_Rights ON
			Group_Approval_Rights.Group_ID = grp.#local.prdGroupAttributes.Product_Group_Attribute_ID_Field#
			and Group_Approval_Rights.User_Profile_ID = <cfqueryparam value="#arguments.Profiles_ID#" cfsqltype="cf_sql_varchar">
			and Group_Approval_Rights.deleted = 0
			LEFT JOIN Margin_Targets_Upload MTU
			ON MTU.BSA_Foodservice_Items_Master_ID  = CPM.Product_Id
			where contract_main_id = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar">
			and CPM.deleted = 0
			and CPM.Exclude_From_Margin = <cfqueryparam value="#arguments.excludeMarginItems#" cfsqltype="cf_sql_bit">
			<cfif arguments.productGroupLevelFilterList neq "">
			and grp.#local.prdGroupAttributes.Product_Group_Attribute_ID_Field# in (<cfqueryparam value="#arguments.productGroupLevelFilterList#" cfsqltype="cf_sql_varchar" list="yes">)
			</cfif>
			group by grp.#local.prdGroupAttributes.Product_Group_Attribute_Name_Field#,grp.#local.prdGroupAttributes.Product_Group_Attribute_ID_Field#,Group_ID_Approval
			<!--- 66894 --->
			<cfif arguments.productGroupLevelId neq 12>
				--Do Nothing
			<cfelse>
				<cfif arguments.Operator_program>
					,grp.Target_Margin_Operator
					,Group_ID_Margin_Operator
				<cfelse>
					,grp.Target_Margin
					,Group_ID_Margin
				</cfif>
				<!--- 66894 --->
				,Target_Margin_ListPrice <!--- 72497 --->
			</cfif>
			,Group_ID_List_Price <!--- 72497 --->
			order by grp.#local.prdGroupAttributes.Product_Group_Attribute_Name_Field#
		</CFQUERY>
	</cfif>

	</cfif>

<cfreturn qgetAllGroupMargins />
</cffunction>

<!----------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="column_by_volume" output="false" hint="Returns a case/lb value by a sum of volume">
	<cfargument name="column_name">

	<cfscript>
		if (listLast(arguments.column_name, "_") is "LB")
			local.sum_column = "Product_Program_Volume_LB";
		else if (listLast(arguments.column_name, "_") is "CS")
			local.sum_column = "Product_Program_Volume_CS";
		else if (listLast(arguments.column_name, "_") is "STAT")
			local.sum_column = "Product_Program_Volume_STAT";
		else
			local.sum_column = "";
	</cfscript>

	<cfreturn application.util.string.compress("CASE
													WHEN ISNULL(SUM(#local.sum_column#),0) != 0 THEN ISNULL(SUM(#local.sum_column# * #arguments.column_name#),0) / SUM(#local.sum_column#)
													ELSE 0
	 		   									END")>
</cffunction>

<cffunction name="case_lb_column_by_volume" output="false" hint="Returns a case/lb value by a sum of volume based on UOM in Type_Code_Desc">
	<cfargument name="column_prefix">
	<cfreturn application.util.string.compress("CASE Type_Code_Desc.Target_Case_Rate_UOM
													WHEN 2 THEN #column_by_volume("#arguments.column_prefix#_LB")#
													ELSE #column_by_volume("#arguments.column_prefix#_CS")#
												END")>
</cffunction>

<cffunction name="case_lb_column" output="false" hint="Returns a case value or a lb value based on UOM in Type_Code_Desc">
	<cfargument name="column_prefix">
	<cfreturn application.util.string.compress("CASE Type_Code_Desc.Target_Case_Rate_UOM
													WHEN 2 THEN ISNULL(#arguments.column_prefix#_LB,0)
													ELSE ISNULL(#arguments.column_prefix#_CS,0)
												END")>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="getapprovedprogramtypecodes" access="public" returntype="query">
<cfargument name="program_id" type="string" required="true" />
<cfquery name="qgetapprovedprogramtypecodes" 			datasource="#application.datasource#">
			SELECT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id,isnull(approve,0)
			FROM  dbo.Contract_Product_Margin
			INNER JOIN BSA_Foodservice_Items_Master
				ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = Contract_Product_Margin.Product_Id
			INNER JOIN Type_Code_Desc
				ON Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
			LEFT JOIN Program_Type_Code_Approval_Info
				ON (Program_Type_Code_Approval_Info.Type_Code_Desc_ID =	Type_Code_Desc.Type_Code_Desc_ID
					OR
					Program_Type_Code_Approval_Info.product_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id)
			AND Program_Type_Code_Approval_Info.program_id = contract_main_id
			AND Program_Type_Code_Approval_Info.deleted = 0
			AND type = 1
			where contract_main_id = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar">
			AND isNULL(approve,0) = 0
			and Contract_Product_Margin.deleted = 0
			and Contract_Product_Margin.Exclude_From_Margin = 0
</cfquery>
<cfreturn qgetapprovedprogramtypecodes />
</cffunction>

<cffunction name="getagreedprogramtypecodes" access="public" returntype="query">
	<cfargument name="program_id" type="string" required="true" />
	<cfargument name="Exec_Agreement" type="string" required="false" />
	<cfargument name="User_ID" type="string" required="false" />
	<cfargument name="User_Profile" type="numeric" required="false" default="0" />
	<cfargument name="onlyTheTypeCodesUserHaveAccessTo" type="boolean" required="false" default="0" />

	<cfquery name="qgetagreedprogramtypecodes" 			datasource="#application.datasource#">
	select 	cp1.product_id
	from 	Contract_Product_Margin cp1
			<cfif arguments.onlyTheTypeCodesUserHaveAccessTo>
			INNER JOIN 	BSA_Foodservice_Items_Master
			ON 			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = cp1.Product_Id
			INNER JOIN 	Type_Code_Desc
			ON 			Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
			AND			exists --Type_Code_Desc.Type_Code_Desc_ID IN
						(
						SELECT	DISTINCT Type_Code_Desc_ID
						FROM	Type_Code_Desc tcd
								INNER JOIN Group_Approval_Rights Group_Level_Access_Rights
								ON
								Group_Level_Access_Rights.User_Profile_Id = <cfqueryparam value="#arguments.User_Profile#" cfsqltype="cf_sql_varchar">
								AND Group_Level_Access_Rights.Deleted = 0
								AND Group_Level_Access_Rights.Group_ID = Tcd.Type_Code_Desc_ID
								AND tcd.Type_Code_Desc_ID = Type_Code_Desc.Type_Code_Desc_ID
								AND Group_Level_Access_Rights.Group_Type = 1
								AND Group_Level_Access_Rights.Group_ID_Approval = 1
						)
			</cfif>
	where 	cp1.contract_main_id = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar">
	and 	cp1.deleted = 0
	and 	--cp1.product_id not in
				not exists
				(SELECT 	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id
				FROM  		dbo.Contract_Product_Margin
				INNER JOIN 	BSA_Foodservice_Items_Master
				ON 			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = Contract_Product_Margin.Product_Id
				INNER JOIN 	Type_Code_Desc
				ON 			Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
				INNER JOIN 	Program_Type_Code_Approval_Info
				ON 			Program_Type_Code_Approval_Info.program_id = contract_main_id
							AND
							(
							Program_Type_Code_Approval_Info.Type_Code_Desc_ID =	Type_Code_Desc.Type_Code_Desc_ID
							OR
							Program_Type_Code_Approval_Info.product_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id
							)

				AND 		Program_Type_Code_Approval_Info.deleted = 0
				<cfif isdefined("arguments.Exec_Agreement") and arguments.Exec_Agreement EQ 1>
				INNER JOIN _Users
				ON			_Users.User_id = Program_Type_Code_Approval_Info.User_id
				and  		_Users.deleted = 0
				inner JOin 	profiles_settings
				On 			profiles_settings.profiles_id = _Users.profiles_id
				and 		profiles_settings.Executive_Agreement = <cfqueryparam value="#arguments.Exec_Agreement#" cfsqltype="cf_sql_varchar">
				</cfif>
				where 		contract_main_id = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar">
				AND		Contract_Product_Margin.product_id = cp1.product_id
				AND 		(isNULL(agree,0) = 1 OR isNULL(approve,0) = 1)
				and Contract_Product_Margin.deleted = 0
				<cfif isdefined("arguments.User_ID")>
				and 		Program_Type_Code_Approval_Info.User_Id = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_varchar">
				</cfif>
				)
	</cfquery>
	<cfreturn qgetagreedprogramtypecodes />
</cffunction>

<cffunction name="getThisProgramsStatus" access="public" returntype="query">
<cfargument name="program_id" type="string" required="true" />
<CFQUERY NAME="qgetThisProgramsStatus" datasource="#application.datasource#">
			SELECT Contract_Status_Type_IDX, Revision_Of_Contract_Main_ID, Broker_User_ID, Contract_Number, Contract_Title,Adv_Spending_Amount
			FROM Contract_main
			WHERE Contract_main_ID = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar">
		</CFQUERY>
	<cfreturn qgetThisProgramsStatus />
</cffunction>

<cffunction name="checkParentStats" access="public" returntype="query">
<cfargument name="Revision_Of_Contract_Main_ID" type="string" required="true" />
<CFQUERY NAME="qcheckParentStats" datasource="#application.datasource#">
				SELECT Contract_Main_ID, Contract_Status_Type_IDX
				FROM Contract_Main
				WHERE Contract_Main_ID = <cfqueryparam value="#arguments.Revision_Of_Contract_Main_ID#" cfsqltype="cf_sql_varchar">
			</CFQUERY>
	<cfreturn qcheckParentStats />
</cffunction>


<cffunction name="getProgramMargins" access="public" returntype="query">
	<cfargument name="program_id" type="string" required="true" />
	<cfargument name="margin_type" type="string" required="true" />
	<cfargument name="margin_version" type="string" required="false" default="current" />	<!--- D21684: current/approved --->
	<cfargument name="excludeMarginItems" type="boolean" required="false" default="0" />	<!--- D23601: margin items exclude--->
	<cfargument name="DefaultUnitMargin" type="boolean" required="false" default="0" />
	<cfargument name="PrgSpan" type="numeric" required="false" default="1" />

    <CFQUERY NAME="qgetProgramMargins" datasource="#application.datasource#">
        /*** components\programs\Approval\layered_program_approval.cfc - getProgramMargins() [ around line 1446 ] ***/
		SELECT
		<cfif arguments.margin_type EQ 1>
			ISNULL(Sum(Product_Program_Volume_CS * Base_Sales_CS),0) as Total_BaseSales_Dollar,
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_CS * Base_Sales_CS),0)/SUM(Product_Program_Volume_CS)
			ELSE
			0 END as Total_BaseSales,
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS* Cash_discount_CS),0)/SUM(Product_Program_Volume_CS)
			ELSE 0 END as Total_Cash_discount ,
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS*pullbackamount_CS),0) /SUM(Product_Program_Volume_CS)
			ELSE 0 END as Total_Pullbackamount,
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0)/SUM(Product_Program_Volume_CS)
			ELSE 0 END  as Total_NetSales,
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS * Cost_CS),0)/SUM(Product_Program_Volume_CS)
			ELSE 0 END as Total_Cost,
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS*Operating_Income_CS),0)/SUM(Product_Program_Volume_CS)
			ELSE 0 END as Total_OprIncome,

			<!---- **** Total_TradeAmt --->
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS*Trade_CS),0)/SUM(Product_Program_Volume_CS)
			ELSE 0 END as Total_TradeAmt,
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS*Trade_CS),0)/SUM(Product_Program_Volume_CS)
			ELSE 0 END as Total_TradeAmt_CS,
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB*Trade_LB),0)/SUM(Product_Program_Volume_LB)
			ELSE 0 END as Total_TradeAmt_LB,

			ISNULL(SUM((LumpsumAmount_CS+Item_Allowance_CS)*Product_Program_Volume_CS),0) as Total_Trade_Spend,

			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			(ISNULL(SUM(Product_Program_Volume_CS * Broker_Cost_CS),0) /SUM(Product_Program_Volume_CS))
			ELSE 0 END
			as TOTAL_Brokerage,
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			(ISNULL(SUM(Product_Program_Volume_CS*
			<cfif application.appSettingsGet.getApprovalMarginType() eq 2>Annualized_Allowance_CS<cfelse>Item_Allowance_CS</cfif>
			),0) /SUM(Product_Program_Volume_CS))
			ELSE 0 END
			as TOTAL_Allowance,

			<!--- Total_OprMargin --->
			<cfif application.appSettingsGet.getMarginOperatingIncomePercentType() eq 2><!--- Use Base Sales --->
			CASE WHEN Round(isnull(SUM(Base_Sales_CS),0),3) = 0
			THEN 0
			else
				(CASE when ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) ELSE 0 END
				/CASE when ISNULL(SUM(Product_Program_Volume_CS * Base_Sales_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Base_Sales_CS),0) ELSE 1 END) * 100
			END as Total_OprMargin,
			<cfelse>
			CASE WHEN Round(isnull(SUM(Net_Sales_CS),0),3) = 0
			THEN 0
			else
				case when (ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) < 0 and ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),1) < 0)then
					-((CASE when ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) ELSE 0 END
					/CASE when ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0) ELSE 1 END) * 100)
				else
					(CASE when ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) ELSE 0 END
					/CASE when ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0) ELSE 1 END) * 100
				end
			END as Total_OprMargin,
			</cfif>

			CASE WHEN Round(isnull(SUM(Base_Sales_CS),0),3) = 0
			THEN 0
			else
			case when (ISNULL(SUM(Product_Program_Volume_CS * Trade_CS),0) < 0 and ISNULL(SUM(Product_Program_Volume_CS * Base_Sales_CS),1) < 0)then
			-((CASE when ISNULL(SUM(Product_Program_Volume_CS * Trade_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Trade_CS),0) ELSE 0 END
			/CASE when ISNULL(SUM(Product_Program_Volume_CS * Base_Sales_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Base_Sales_CS),0) ELSE 1 END) * 100)
			else
			(CASE when ISNULL(SUM(Product_Program_Volume_CS * Trade_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Trade_CS),0) ELSE 0 END
			/CASE when ISNULL(SUM(Product_Program_Volume_CS * Base_Sales_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Base_Sales_CS),0) ELSE 1 END) * 100
			end
			END as Total_TradePercent,
			ISNULL(Sum(Round(Product_Program_Volume_CS, 0)),0) as totalprogramvolume,
			ISNULL(Sum(Round(Product_Program_Volume_CS, 0)),0) as totalprogramvolumecs,
			ISNULL(Sum(Round(Product_Program_Volume_LB, 0)),0) as totalprogramvolumelb

			<!--- 72497	Program Approval - Annual Volume and % of List Price START --->
			<cfif arguments.DefaultUnitMargin><!--- Annual --->
				,ISNULL(Sum(Round(Product_Program_Volume_CS, 0)),0) AS AnnualVolumeCS
				,ISNULL(Sum(Round(Product_Program_Volume_LB, 0)),0) AS AnnualVolumeLB
			<cfelse><!--- Program --->
				,ISNULL(Sum(Round(Product_Program_Volume_CS, 0)),0) * 365.00 / #arguments.PrgSpan# AS AnnualVolumeCS
				,ISNULL(Sum(Round(Product_Program_Volume_LB, 0)),0) * 365.00 / #arguments.PrgSpan# AS AnnualVolumeLB
			</cfif>
			<!--- 72497	Program Approval - Annual Volume and % of List Price END --->

			<!--- 62143 --->
			,CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS* Fx_Man_Cost),0)/SUM(Product_Program_Volume_CS)
			ELSE
			0 END as Total_Fixed_Mfg_Cost
			<!--- 62143 --->
			,#column_by_volume("Allowance_Surcharges_CS")# AS Total_Allowance_Surcharges
			,#column_by_volume("Customer_Freight_CS")#     AS Total_Customer_Freight
			,#column_by_volume("TPA_Oper_CS")#             AS Total_TPA_Oper
			,#column_by_volume("TPA_CS")#                  AS Total_TPA
			,#column_by_volume("Shuttle_Freight_CS")#      AS Total_Shuttle_Freight
			,#column_by_volume("Other_Spend_CS")#          AS Total_Other_Spend
			,#column_by_volume("Custom_Warehouse_CS")#     AS Total_Custom_Warehouse
			,#column_by_volume("Gross_Margin_CS")#         AS Total_Gross_Margin
			,#column_by_volume("Custom_Brokerage_CS")#     AS Total_Custom_Brokerage
			,#column_by_volume("Map_Mdf_CS")#              AS Total_Map_Mdf
			,#column_by_volume("SGA_CS")#                  AS Total_SGA
			,#column_by_volume("Contribution_Margin_Alt_CS")#      AS Total_Contribution_Margin_Alt
			,#column_by_volume("Variable_Contribution_Margin_CS")# AS Total_Variable_Contribution_Margin
            ,CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS * MTU.Net_Sales_Target_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5))),0)/SUM(Product_Program_Volume_CS)
			ELSE
			0 END as Total_Net_Sales_Target_Value
            ,CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS * MTU.Net_Sales_Floor_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5))),0)/SUM(Product_Program_Volume_CS)
			ELSE
			0 END as Total_Net_Sales_Floor_Value
            ,CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS * MTU.GM_Target_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5))),0)/SUM(Product_Program_Volume_CS)
			ELSE
			0 END as Total_GM_Target_Value
            ,CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS * MTU.GM_Floor_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5))),0)/SUM(Product_Program_Volume_CS)
			ELSE
			0 END as Total_GM_Floor_Value

		<cfelseif arguments.margin_type EQ 3>

			ISNULL(Sum(Product_Program_Volume_LB * Base_Sales_LB),0) as Total_BaseSales_Dollar,
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_LB * Base_Sales_LB),0)/SUM(Product_Program_Volume_LB)
			ELSE
			0 END as Total_BaseSales,
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB* Cash_discount_LB),0)/SUM(Product_Program_Volume_LB)
			ELSE 0 END as Total_Cash_discount ,
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB*TPA_LB),0) /SUM(Product_Program_Volume_LB)
			ELSE 0 END as Total_TPA,
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB*pullbackamount_LB),0) /SUM(Product_Program_Volume_LB)
			ELSE 0 END as Total_Pullbackamount,
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0)/SUM(Product_Program_Volume_LB)
			ELSE 0 END  as Total_NetSales,
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB * Cost_LB),0)/SUM(Product_Program_Volume_LB)
			ELSE 0 END as Total_Cost,
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB*Operating_Income_LB),0)/SUM(Product_Program_Volume_LB)
			ELSE 0 END as Total_OprIncome,

			<!---- **** Total_TradeAmt --->
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB*Trade_LB),0)/SUM(Product_Program_Volume_LB)
			ELSE 0 END as Total_TradeAmt,
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS*Trade_CS),0)/SUM(Product_Program_Volume_CS)
			ELSE 0 END as Total_TradeAmt_CS,
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB*Trade_LB),0)/SUM(Product_Program_Volume_LB)
			ELSE 0 END as Total_TradeAmt_LB,

			ISNULL(SUM((LumpsumAmount_LB+Item_Allowance_LB)*Product_Program_Volume_LB),0) as Total_Trade_Spend,

			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB * Broker_Cost_LB),0)/SUM(Product_Program_Volume_LB)
			ELSE 0 END as Total_Brokerage,
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			(ISNULL(SUM(Product_Program_Volume_LB*
			<cfif application.appSettingsGet.getApprovalMarginType() eq 2>Annualized_Allowance_LB<cfelse>Item_Allowance_LB</cfif>
			),0) /SUM(Product_Program_Volume_LB))
			ELSE 0 END
			as TOTAL_Allowance,

			<!--- Total_OprMargin --->
			<cfif application.appSettingsGet.getMarginOperatingIncomePercentType() eq 2><!--- Use Base Sales --->
			CASE WHEN Round(isnull(SUM(Base_Sales_LB),0),3) = 0
			THEN 0
			else
				(CASE when ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) ELSE 0 END
				/CASE when ISNULL(SUM(Product_Program_Volume_LB * Base_Sales_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Base_Sales_LB),0) ELSE 1 END) * 100
			END as Total_OprMargin,
			<cfelse>
			CASE WHEN Round(isnull(SUM(Net_Sales_LB),0),3) = 0
			THEN 0
			else
			case when (ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) < 0 and ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),1) < 0)then
			-((CASE when ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) ELSE 0 END
			/CASE when ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0) ELSE 1 END) * 100)
			else
			(CASE when ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) ELSE 0 END
			/CASE when ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0) ELSE 1 END) * 100
			end
			END as Total_OprMargin,
			</cfif>

			CASE WHEN Round(isnull(SUM(Base_Sales_LB),0),3) = 0
			THEN 0
			else
			case when (ISNULL(SUM(Product_Program_Volume_LB * Trade_LB),0) < 0 and ISNULL(SUM(Product_Program_Volume_LB * Base_Sales_LB),1) < 0)then
			-((CASE when ISNULL(SUM(Product_Program_Volume_LB * Trade_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Trade_LB),0) ELSE 0 END
			/CASE when ISNULL(SUM(Product_Program_Volume_LB * Base_Sales_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Base_Sales_LB),0) ELSE 1 END) * 100)
			else
			(CASE when ISNULL(SUM(Product_Program_Volume_LB * Trade_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Trade_LB),0) ELSE 0 END
			/CASE when ISNULL(SUM(Product_Program_Volume_LB * Base_Sales_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Base_Sales_LB),0) ELSE 1 END) * 100
			end
			END as Total_TradePercent,
			ISNULL(Sum(Round(Product_Program_Volume_LB, 0)),0) as totalprogramvolume,
			ISNULL(Sum(Round(Product_Program_Volume_CS, 0)),0) as totalprogramvolumecs,
			ISNULL(Sum(Round(Product_Program_Volume_LB, 0)),0) as totalprogramvolumelb

			<!--- 72497	Program Approval - Annual Volume and % of List Price START --->
			<cfif arguments.DefaultUnitMargin><!--- Annual --->
				,ISNULL(Sum(Round(Product_Program_Volume_CS, 0)),0) AS AnnualVolumeCS
				,ISNULL(Sum(Round(Product_Program_Volume_LB, 0)),0) AS AnnualVolumeLB
			<cfelse><!--- Program --->
				,ISNULL(Sum(Round(Product_Program_Volume_CS, 0)),0) * 365.00 / #arguments.PrgSpan# AS AnnualVolumeCS
				,ISNULL(Sum(Round(Product_Program_Volume_LB, 0)),0) * 365.00 / #arguments.PrgSpan# AS AnnualVolumeLB
			</cfif>
			<!--- 72497	Program Approval - Annual Volume and % of List Price END --->

			<!--- 62143 --->
			,CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_LB * ISNULL(Fx_Man_Cost,0)/CAST(BSA_Foodservice_Items_Master.Net_Weight as float)),0)/SUM(Product_Program_Volume_LB)
			ELSE
			0 END as Total_Fixed_Mfg_Cost
			<!--- 62143 --->
			,#column_by_volume("Allowance_Surcharges_LB")# AS Total_Allowance_Surcharges
			,#column_by_volume("Customer_Freight_LB")#     AS Total_Customer_Freight
			,#column_by_volume("TPA_Oper_LB")#             AS Total_TPA_Oper
			,#column_by_volume("TPA_LB")#                  AS Total_TPA
			,#column_by_volume("Shuttle_Freight_LB")#      AS Total_Shuttle_Freight
			,#column_by_volume("Other_Spend_LB")#          AS Total_Other_Spend
			,#column_by_volume("Custom_Warehouse_LB")#     AS Total_Custom_Warehouse
			,#column_by_volume("Gross_Margin_LB")#         AS Total_Gross_Margin
			,#column_by_volume("Custom_Brokerage_LB")#     AS Total_Custom_Brokerage
			,#column_by_volume("Map_Mdf_LB")#              AS Total_Map_Mdf
			,#column_by_volume("SGA_LB")#                  AS Total_SGA
			,#column_by_volume("Contribution_Margin_Alt_LB")#      AS Total_Contribution_Margin_Alt
			,#column_by_volume("Variable_Contribution_Margin_LB")# AS Total_Variable_Contribution_Margin
            ,CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB * MTU.Net_Sales_Target_Value),0)/SUM(Product_Program_Volume_LB)
			ELSE
			0 END as Total_Net_Sales_Target_Value
            ,CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB * MTU.Net_Sales_Floor_Value),0)/SUM(Product_Program_Volume_LB)
			ELSE
			0 END as Total_Net_Sales_Floor_Value
            ,CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB * MTU.GM_Target_Value),0)/SUM(Product_Program_Volume_LB)
			ELSE
			0 END as Total_GM_Target_Value
            ,CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB * MTU.GM_Floor_Value),0)/SUM(Product_Program_Volume_LB)
			ELSE
			0 END as Total_GM_Floor_Value
		<CFELSE>
			ISNULL(Sum(Product_Program_Volume_STAT * Base_Sales_STAT),0) as Total_BaseSales_Dollar,
			CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_STAT * Base_Sales_STAT),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as Total_BaseSales ,
			CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_STAT * Cash_discount_STAT),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as Total_Cash_discount ,
			CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_STAT * TPA_STAT),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as Total_TPA,
			CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_STAT * pullbackamount_STAT),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as Total_pullbackamount,
			CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_STAT * Net_Sales_STAT),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as Total_NetSales,
			CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_STAT * Cost_STAT),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as Total_Cost,
			CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_STAT *Operating_Income_STAT),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as Total_OprIncome,

			<!---- **** Total_TradeAmt --->
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS*Trade_STAT),0)/SUM(Product_Program_Volume_CS)
			ELSE 0 END as Total_TradeAmt,
			CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_CS*Trade_CS),0)/SUM(Product_Program_Volume_CS)
			ELSE 0 END as Total_TradeAmt_CS,
			CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_LB*Trade_LB),0)/SUM(Product_Program_Volume_LB)
			ELSE 0 END as Total_TradeAmt_LB,

			ISNULL(SUM((LumpsumAmount_STAT+Item_Allowance_STAT)*Product_Program_Volume_STAT),0) as Total_Trade_Spend,

			CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			(ISNULL(SUM(Product_Program_Volume_STAT *
			<cfif application.appSettingsGet.getApprovalMarginType() eq 2>Annualized_Allowance_STAT<cfelse>Item_Allowance_STAT</cfif>
			),0)/SUM(Product_Program_Volume_STAT) +
			SUM(LumpsumAmount_STAT))
			ELSE
			0 END as TOTAL_Allowance,

			<!--- Total_OprMargin --->
			<cfif application.appSettingsGet.getMarginOperatingIncomePercentType() eq 2><!--- Use Base Sales --->
			CASE WHEN Round(isnull(SUM(Base_Sales_STAT),0),3) = 0
			THEN 0
			else
				(CASE when ISNULL(SUM(Product_Program_Volume_STAT * Operating_Income_STAT),0) !=0 then ISNULL(SUM(Product_Program_Volume_STAT * Operating_Income_STAT),0) ELSE 0 END
				/CASE when ISNULL(SUM(Product_Program_Volume_STAT * Base_Sales_STAT),0) !=0 then ISNULL(SUM(Product_Program_Volume_STAT * Base_Sales_STAT),0) ELSE 1 END) * 100
			END as Total_OprMargin,
			<cfelse>
			CASE WHEN Round(isnull(SUM(Net_Sales_STAT),0),3) = 0
			THEN 0
			else
			case when (ISNULL(SUM(Product_Program_Volume_STAT * Operating_Income_STAT),0) < 0 and ISNULL(SUM(Product_Program_Volume_STAT * Net_Sales_STAT),1) < 0)then
			-((CASE when ISNULL(SUM(Product_Program_Volume_STAT * Operating_Income_STAT),0) !=0 then ISNULL(SUM(Product_Program_Volume_STAT * Operating_Income_STAT),0) ELSE 0 END
			/CASE when ISNULL(SUM(Product_Program_Volume_STAT * Net_Sales_STAT),0) !=0 then ISNULL(SUM(Product_Program_Volume_STAT * Net_Sales_STAT),0) ELSE 1 END) * 100)
			else
			(CASE when ISNULL(SUM(Product_Program_Volume_STAT * Operating_Income_STAT),0) !=0 then ISNULL(SUM(Product_Program_Volume_STAT * Operating_Income_STAT),0) ELSE 0 END
			/CASE when ISNULL(SUM(Product_Program_Volume_STAT * Net_Sales_STAT),0) !=0 then ISNULL(SUM(Product_Program_Volume_STAT * Net_Sales_STAT),0) ELSE 1 END) * 100
			end
			END as Total_OprMargin,
			</cfif>

			CASE WHEN Round(isnull(SUM(Base_Sales_STAT),0),3) = 0
			THEN 0
			else
			case when (ISNULL(SUM(Product_Program_Volume_STAT * Trade_STAT),0) < 0 and ISNULL(SUM(Product_Program_Volume_STAT * Base_Sales_STAT),1) < 0)then
			-((CASE when ISNULL(SUM(Product_Program_Volume_STAT * Trade_STAT),0) !=0 then ISNULL(SUM(Product_Program_Volume_STAT * Trade_STAT),0) ELSE 0 END
			/CASE when ISNULL(SUM(Product_Program_Volume_STAT * Base_Sales_STAT),0) !=0 then ISNULL(SUM(Product_Program_Volume_STAT * Base_Sales_STAT),0) ELSE 1 END) * 100)
			else
			(CASE when ISNULL(SUM(Product_Program_Volume_STAT * Trade_STAT),0) !=0 then ISNULL(SUM(Product_Program_Volume_STAT * Trade_STAT),0) ELSE 0 END
			/CASE when ISNULL(SUM(Product_Program_Volume_STAT * Base_Sales_STAT),0) !=0 then ISNULL(SUM(Product_Program_Volume_STAT * Base_Sales_STAT),0) ELSE 1 END) * 100
			end
			END as Total_TradePercent,
			ISNULL(SUM(Product_Program_Volume_STAT),0) as TotalProgramVolume,
			ISNULL(Sum(Round(Product_Program_Volume_CS, 0)),0) as totalprogramvolumecs,
			ISNULL(Sum(Round(Product_Program_Volume_LB, 0)),0) as totalprogramvolumelb
<!---D37829 Program Summary Volume Not Totaling --->
	,CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
                              (ISNULL(SUM(Product_Program_Volume_STAT * Broker_Cost_CS / BSA_Foodservice_Items_Master.Case_Equivalent),0) /SUM(Product_Program_Volume_STAT))
                        ELSE 0 END
as TOTAL_Brokerage
<!---D37829 Program Summary Volume Not Totaling --->

			<!--- 72497	Program Approval - Annual Volume and % of List Price START --->
			<cfif arguments.DefaultUnitMargin><!--- Annual --->
				,ISNULL(Sum(Round(Product_Program_Volume_CS, 0)),0) AS AnnualVolumeCS
				,ISNULL(Sum(Round(Product_Program_Volume_LB, 0)),0) AS AnnualVolumeLB
			<cfelse><!--- Program --->
				,ISNULL(Sum(Round(Product_Program_Volume_CS, 0)),0) * 365.00 / #arguments.PrgSpan# AS AnnualVolumeCS
				,ISNULL(Sum(Round(Product_Program_Volume_LB, 0)),0) * 365.00 / #arguments.PrgSpan# AS AnnualVolumeLB
			</cfif>
			<!--- 72497	Program Approval - Annual Volume and % of List Price END --->

			<!--- 62143 --->
			,CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(Sum(Product_Program_Volume_STAT * ISNULL(Fx_Man_Cost,0)/BSA_Foodservice_Items_Master.Case_Equivalent),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as Total_Fixed_Mfg_Cost
			<!--- 62143 --->
			,#column_by_volume("Allowance_Surcharges_STAT")# AS Total_Allowance_Surcharges
			,#column_by_volume("Customer_Freight_STAT")#     AS Total_Customer_Freight
			,#column_by_volume("TPA_Oper_STAT")#             AS Total_TPA_Oper
			,#column_by_volume("Shuttle_Freight_STAT")#      AS Total_Shuttle_Freight
			,#column_by_volume("Other_Spend_STAT")#          AS Total_Other_Spend
			,#column_by_volume("Custom_Warehouse_STAT")#     AS Total_Custom_Warehouse
			,#column_by_volume("Gross_Margin_STAT")#         AS Total_Gross_Margin
			,#column_by_volume("Custom_Brokerage_STAT")#     AS Total_Custom_Brokerage
			,#column_by_volume("Map_Mdf_STAT")#              AS Total_Map_Mdf
			,#column_by_volume("SGA_STAT")#                  AS Total_SGA
			,#column_by_volume("Contribution_Margin_Alt_STAT")#      AS Total_Contribution_Margin_Alt
			,#column_by_volume("Variable_Contribution_Margin_STAT")# AS Total_Variable_Contribution_Margin
            ,CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_STAT * MTU.Net_Sales_Target_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5)) / NULLIF(CAST(BSA_Foodservice_Items_Master.Case_Equivalent as DECIMAL(20, 5)), 0)),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as Total_Net_Sales_Target_Value
            ,CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_STAT * MTU.Net_Sales_Floor_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5)) / NULLIF(CAST(BSA_Foodservice_Items_Master.Case_Equivalent as DECIMAL(20, 5)), 0)),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as Total_Net_Sales_Floor_Value
            ,CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_STAT * MTU.GM_Target_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5)) / NULLIF(CAST(BSA_Foodservice_Items_Master.Case_Equivalent as DECIMAL(20, 5)), 0)),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as Total_GM_Target_Value
            ,CASE when ISNULL(SUM(Product_Program_Volume_STAT),0) !=0 then
			ISNULL(SUM(Product_Program_Volume_STAT * MTU.GM_Floor_Value * CAST(BSA_Foodservice_Items_Master.Net_Weight as DECIMAL(20, 5)) / NULLIF(CAST(BSA_Foodservice_Items_Master.Case_Equivalent as DECIMAL(20, 5)), 0)),0)/SUM(Product_Program_Volume_STAT)
			ELSE
			0 END as Total_GM_Floor_Value
		</cfif>
		<cfif arguments.margin_version eq "approved">
			FROM  dbo.Contract_Product_Margin_Approved CPM
		<cfelse>
			FROM  dbo.Contract_Product_Margin CPM
		</cfif>
		INNER JOIN 	BSA_Foodservice_Items_Master	ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = CPM.Product_Id
		INNER JOIN 	Type_Code_Desc ON Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
		LEFT JOIN Margin_Targets_Upload MTU ON MTU.BSA_Foodservice_Items_Master_ID  = CPM.Product_Id
		WHERE 		contract_main_id = <cfqueryparam value="#Arguments.Program_ID#" cfsqltype="cf_sql_varchar">
		AND 		CPM.Exclude_From_Margin = <cfqueryparam value="#arguments.excludeMarginItems#" cfsqltype="cf_sql_bit">
		AND 		CPM.deleted = 0
		</CFQUERY>
	<cfreturn qgetProgramMargins />
</cffunction>

<!--- Date: 10/16/2007 Usage: Gets the latest Date the Margin has run for the Program_ID passed --->
<cffunction name="getMarginCalculatedDate" access="public" returntype="date">
	<cfargument name="Program_ID" type="string" required="true" />
	<cfargument name="margin_version" type="string" required="false" default="current" /> <!--- D21684: current/approved --->

	<cfquery name="qGetMarginCalculatedDate" datasource="#application.datasource#">
		SELECT	ISNULL(MAX(Created_Date),'') as MarginLastCalculatedDate
		<cfif arguments.margin_version eq "approved">
			FROM  dbo.Contract_Product_Margin_Approved
		<cfelse>
			FROM  dbo.Contract_Product_Margin
		</cfif>
		WHERE	Contract_Main_ID = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar">
		AND		Deleted = 0
	</cfquery>
	<cfreturn  qGetMarginCalculatedDate.MarginLastCalculatedDate />
</cffunction>

<cffunction name="getProgramLumpsum" access="public" returntype="query">
<cfargument name="program_id" type="string" required="true" />
	<CFQUERY NAME="qgetProgramLumpsum" datasource="#application.datasource#">
		select 	ISNULL(sum(cast(Lump_Sum_Amount as float)),0) as Lumpsum_Amount
		from 	Program_Lump_Sums
		where	Program_ID =  <cfqueryparam value="#arguments.program_id#" cfsqltype="cf_sql_varchar">
		and 	deleted = 0
	</CFQUERY>
	<cfreturn qgetProgramLumpsum />
</cffunction>

<cffunction name="getGrowthproducts" access="public" returntype="query">
<cfargument name="program_id" type="string" required="true" />
<CFQUERY NAME="qgetGrowthproducts" datasource="#application.datasource#">
select *
from contract_products
where
contract_main_id =  <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar">
and Product_Type_ID = 4
and deleted = 0
</CFQUERY>
	<cfreturn qgetGrowthproducts />
</cffunction>

<cffunction name="getagreedprograms" access="public" returntype="query">
	<cfargument name="program_id" type="string" required="true" />
	<cfargument name="User_ID" type="string" required="true" />
	<cfquery name="qgetagreedprograms" 			datasource="#application.datasource#">
		select 	distinct cp1.BSA_Foodservice_Items_Master_Id
		from 	Contract_Products cp1
		where 	cp1.contract_main_id = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar">
		and 	cp1.deleted = 0
		and 	cp1.BSA_Foodservice_Items_Master_Id not in
		(SELECT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id
					FROM  dbo.Contract_Product_Margin
					INNEr JOIN BSA_Foodservice_Items_Master
					ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id =
					Contract_Product_Margin.Product_Id
					INNER JOIN Type_Code_Desc
					ON Type_Code_Desc.Type_Code_Desc_ID =
					BSA_Foodservice_Items_Master.Type_Code_Desc_ID
					LEFT JOIN Program_Type_Code_Approval_Info
					ON Program_Type_Code_Approval_Info.program_id = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar">
					AND (
						Program_Type_Code_Approval_Info.Type_Code_Desc_ID = Type_Code_Desc.Type_Code_Desc_ID
						OR
						Program_Type_Code_Approval_Info.product_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id
						)

					AND Program_Type_Code_Approval_Info.deleted = 0

					where Contract_Product_Margin.contract_main_id = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar">
					AND (isNULL(agree,0) = 1
					OR isNULL(approve,0) = 1
		)
					and Contract_Product_Margin.deleted = 0

					 and Program_Type_Code_Approval_Info.User_Id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">
					)

	</CFQUERY>
	<cfreturn qgetagreedprograms />
</cffunction>


<cffunction name="getAnyProgramProducts" access="public" returntype="boolean">
	<cfargument name="program_id" type="string" required="true" />

	<cfquery name="qGetAnyProgramProducts" 			datasource="#application.datasource#">
		select 	top 1 cp1.BSA_Foodservice_Items_Master_Id
		from 	Contract_Products cp1
		where 	cp1.contract_main_id = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar">
		and 	cp1.deleted = 0
	</CFQUERY>
	<cfset bAnyProgramProducts = qGetAnyProgramProducts.recordCount />

	<cfreturn bAnyProgramProducts />

</cffunction>

<cffunction name="getProductGroups" access="public" returntype="string">
	<cfargument name="productList" type="string" required="true" />
	<cfquery name="qGetProductGroups" 			datasource="#application.datasource#">
		select distinct Type_Code_Desc.Type_Code_Desc_ID, Type_Code_Desc.Type_Code_Desc
		from 		BSA_Foodservice_Items_Master
		inner join 	Type_Code_Desc
				on  Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
		where BSA_Foodservice_Items_Master_id in (#ListQualify(arguments.productList, "'",",","ALL" )#)
	</CFQUERY>
	<cfreturn valueList(qGetProductGroups.Type_Code_Desc_ID) />

</cffunction>

<cffunction name="gettotallumpamount" access="public" returntype="string">
	<cfargument name="program_id" type="string" required="true" />
	<cfargument name="program_volume" type="string" required="true" />
	<cfquery name="qgettotallumpamount" 			datasource="#application.datasource#">
		select <cfif arguments.program_volume NEQ 0>
		(ISNULL(sum(ISNULL(cast(lump_sum_amount as float),0)),0) / <cfqueryparam value="#arguments.program_volume#" cfsqltype="cf_sql_varchar">)
		<cfelse> 0
		</cfif> as TotalLumpsumAmount
		from Program_Lump_Sums
		where program_id = <cfqueryparam value="#arguments.Program_ID#" cfsqltype="cf_sql_varchar">
		and Program_Lump_Sums.deleted = 0
	</CFQUERY>
<cfreturn qgettotallumpamount />
</cffunction>

<cffunction name="getagreedProductMargins" access="public" returntype="query">
<cfargument name="reporttype" type="numeric" required="true" />
<cfargument name="start_date" type="string" required="true" />
<cfargument name="end_date" type="string" required="true" />
	<cfquery name="qgetagreedProductMargins" 			datasource="#application.datasource#">
		SELECT distinct
			Contract_Main.Contract_Main_ID,Contract_Main.contract_title,_Users.name_first + ' ' + _Users.name_last as User_Name,
			Program_Type_Code_Approval_Info.created_date as approved_date,
			Contract_Main.contract_number,Program_Control_Panel_Options.created_type,
			Contract_Product_Margin.Product_Id as item_id,
			ISNULL(RER_CS,0) as RER_CS, ISNULL(FPR_CS,0) as FPR_CS,
			(ISNULL(TargetMargin,0)) as Target_Margin,
			ISNULL(OperatingMargin_percent,0) as approved_margin ,
			Type_Code_Desc.Type_Code_Desc,
			BSA_Foodservice_Items_Master.Description,
			BSA_Foodservice_Items_Master.Item as item_number,
			ISNULL(Product_Program_Volume_CS,0) as volume ,
			(ISNULL(OperatingMargin_percent,0) - isnull(TargetMargin,0)) as variance
			from contract_main INNER JOIN dbo.Program_Control_Panel_Options ON
            dbo.Contract_Main.ProgramType_ID = dbo.Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
			inner join
	dbo.Contract_Product_Margin on Contract_Main.Contract_Main_ID =
		Contract_Product_Margin.Contract_Main_ID
	INNEr JOIN BSA_Foodservice_Items_Master
			ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = Contract_Product_Margin.Product_Id
	INNER JOIN Type_Code_Desc
			ON Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
	LEFT JOIN Program_Type_Code_Approval_Info
			ON Program_Type_Code_Approval_Info.program_id = contract_main.contract_main_id
				AND
				(
				Program_Type_Code_Approval_Info.Type_Code_Desc_ID = Type_Code_Desc.Type_Code_Desc_ID
				OR
				Program_Type_Code_Approval_Info.product_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id
				)

			AND Program_Type_Code_Approval_Info.deleted = 0
			AND type = 1
			AND isNULL(approve,0) = 1
			AND Program_Type_Code_Approval_Info.product_ID IS NOT NULL
	LEFT JOIN _Users ON _Users.User_Id = Program_Type_Code_Approval_Info.user_id
	where 	Contract_Main.edit_agreed_program = 1
	and Contract_Main.contract_status_type_idx > 3 and Contract_Main.contract_status_type_idx < 7
	<cfif arguments.reporttype EQ 2>
	and ISNULL(OperatingMargin_percent,0) < isnull(TargetMargin,0)
	</cfif>
	and 	Contract_Product_Margin.deleted = 0
	and (contract_main.approval_date >= <cfqueryparam value="#arguments.start_date#" cfsqltype="cf_sql_varchar">
	and contract_main.approval_date < dateadd(day,1,<cfqueryparam value="#arguments.end_date#" cfsqltype="cf_sql_varchar">))
	order by Contract_Main.Contract_Main_ID,
			Contract_Main.contract_number,item
		</CFQUERY>
	<cfreturn qgetagreedProductMargins />

</cffunction>



	<cffunction name="getagreedTypecodeMargins" access="public" returntype="query">
		<cfargument name="start_date" type="string" required="true" />
		<cfargument name="end_date" type="string" required="true" />
		<cfquery name="qgetagreedTypecodeMargins" 			datasource="#application.datasource#">
			SELECT Contract_Main.Contract_Main_ID,Contract_Main.Contract_Number,Contract_Main.contract_title,
				_Users.name_first + ' ' + _Users.name_last as User_Name,
							Program_Type_Code_Approval_Info.created_date as approved_date,
				Program_Control_Panel_Options.created_type,
						ISNULL(SUM(Product_Program_Volume_CS),0) as volume ,
				CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
				(ISNULL(SUM(Product_Program_Volume_CS*RER_CS),0) /SUM(Product_Program_Volume_CS))
				ELSE 0 END as RER_CS,
				CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
				(ISNULL(SUM(Product_Program_Volume_CS*FPR_CS),0) /SUM(Product_Program_Volume_CS))
				ELSE 0 END
				as FPR_CS,
				CASE WHEN Round(isnull(SUM(Net_Sales_CS),0),3) = 0
				THEN 0
				else
				case when (ISNULL(SUM(Operating_Income_CS),0) < 0 and ISNULL(SUM(Net_Sales_CS),1) < 0)
				then
				-((ISNULL(SUM(Operating_Income_CS),0)/ISNULL(SUM(Net_Sales_CS),1)) * 100)
				else
				((ISNULL(SUM(Operating_Income_CS),0)/ISNULL(SUM(Net_Sales_CS),1)) * 100)
				end
				END as approved_margin,
				ISNULL((cast(Type_Code_Desc.Target_Margin as float)),0) as Target_Margin,
				Type_Code_Desc.Type_Code_Desc_ID,
				Type_Code_Desc.Type_Code_Desc as description
				FROM  Contract_Main
				INNER JOIN dbo.Program_Control_Panel_Options ON
				            dbo.Contract_Main.ProgramType_ID = dbo.Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
				inner join
					dbo.Contract_Product_Margin on Contract_Main.Contract_Main_ID =
						Contract_Product_Margin.Contract_Main_ID
				INNEr JOIN BSA_Foodservice_Items_Master
				ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = Contract_Product_Margin.Product_Id
				INNER JOIN Type_Code_Desc
				ON Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
				LEFT JOIN Program_Type_Code_Approval_Info
							ON (Program_Type_Code_Approval_Info.Type_Code_Desc_ID =
							Type_Code_Desc.Type_Code_Desc_ID OR
							Program_Type_Code_Approval_Info.product_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id)
							AND Program_Type_Code_Approval_Info.program_id = contract_main.contract_main_id
							AND Program_Type_Code_Approval_Info.deleted = 0
							AND type = 1
							AND isNULL(approve,0) = 1
							AND Program_Type_Code_Approval_Info.Type_Code_Desc_ID IS NOT NULL
							LEFT JOIN _Users ON _Users.User_Id = Program_Type_Code_Approval_Info.user_id
				where Contract_Main.edit_agreed_program = 1
				and Contract_Main.contract_status_type_idx > 3 and Contract_Main.contract_status_type_idx < 7
				and Contract_Product_Margin.deleted = 0
					and (contract_main.approval_date >= <cfqueryparam value="#arguments.start_date#" cfsqltype="cf_sql_varchar">
					and contract_main.approval_date < dateadd(day,1,<cfqueryparam value="#arguments.end_date#" cfsqltype="cf_sql_varchar">))
				group by Type_Code_Desc.Type_Code_Desc,Type_Code_Desc.Target_Margin,Type_Code_Desc.Type_Code_Desc_ID,
				Contract_Main.Contract_Main_ID,Contract_Main.contract_number,contract_title,Program_Control_Panel_Options.created_type,
				_Users.name_first,_Users.name_last,
				Program_Type_Code_Approval_Info.created_date
				order by Contract_Main.Contract_Main_ID,Contract_Main.contract_number, Type_Code_Desc.Type_Code_Desc
			</CFQUERY>
		<cfreturn qgetagreedTypecodeMargins />

	</cffunction>

	<cffunction name="getLumpsumAmountForProfile" access="public" returntype="query">

		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="profileId" type="numeric" required="true" />

		<cfset var var_programId = "" />
		<cfset var var_profileId = "" />

		<cfset var_programId = trim(arguments.programId) />
		<cfset var_profileId = trim(arguments.profileId) />

		<cfquery name="qgetLumpsumAmountForProfile" datasource="#application.datasource#">
			SELECT	Program_Lump_Sum_Name.Program_Lump_Sum_Name,
					Profile_LS_Approval.Program_Lump_Sum_Name_ID as Profile_LS_Approval_Program_Lump_Sum_Name_ID,
					Profile_LS_Approval.Approval_Amount
			FROM	Program_Lump_Sums
					INNER JOIN Program_Lump_Sum_Name ON
					Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID AND
					Program_Lump_Sum_Name.Active = 1
					LEFT JOIN Profile_LS_Approval ON
					Profile_LS_Approval.Program_Lump_Sum_Name_ID = Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID
			AND		Profiles_ID = <cfqueryparam value="#var_profileId#" cfsqltype="CF_SQL_INTEGER">
			WHERE	Program_Lump_Sums.Program_ID = <cfqueryparam value="#var_programId#" cfsqltype="CF_SQL_INTEGER">
			AND		Program_Lump_Sums.Deleted = 0
		</cfquery>

		<cfreturn qgetLumpsumAmountForProfile />

	</cffunction>

	<cffunction name="getActiveExceededLumpSumComponents" access="public" returntype="query">

		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="profileId" type="numeric" required="true" />

		<cfset var var_programId = "" />
		<cfset var var_profileId = "" />

		<cfset var_programId = trim(arguments.programId) />
		<cfset var_profileId = trim(arguments.profileId) />

		<cfquery name="qGetActiveExceededLumpSums" datasource="#application.datasource#">
			SELECT	Program_Lump_Sums.Lump_Sum_Amount,
					Program_Lump_Sum_Name.Program_Lump_Sum_Name,
					CASE
					WHEN Profile_LS_Approval.Approval_Amount <> '*' AND ISNUMERIC(Profile_LS_Approval.Approval_Amount) = 0 THEN '0'
					ELSE Profile_LS_Approval.Approval_Amount
					END as Approval_Amount
			FROM	Program_Lump_Sums
					INNER JOIN Program_Lump_Sum_Name ON
					Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID AND
					Program_Lump_Sum_Name.Active = 1
					INNER JOIN Profile_LS_Approval ON
					Profile_LS_Approval.Program_Lump_Sum_Name_ID = Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID
			AND		Profiles_ID = <cfqueryparam value="#var_profileId#" cfsqltype="CF_SQL_INTEGER">
			WHERE	Program_Lump_Sums.Program_ID = <cfqueryparam value="#var_programId#" cfsqltype="CF_SQL_INTEGER">
			AND		Program_Lump_Sums.Deleted = 0
			AND		Profile_LS_Approval.Approval_Amount != '*'
			AND		CAST(Program_Lump_Sums.Lump_Sum_Amount AS DECIMAL(20,4)) >
					CAST(CASE
						WHEN Profile_LS_Approval.Approval_Amount <> '*' AND ISNUMERIC(Profile_LS_Approval.Approval_Amount) = 0 THEN '0'
						ELSE Profile_LS_Approval.Approval_Amount
						END AS DECIMAL(20,4))
		</cfquery>

		<cfreturn qGetActiveExceededLumpSums />

	</cffunction>

	<cffunction name="getInActiveExceededLumpSumComponents" access="public" returntype="query">

		<cfargument name="programId" 	type="numeric" 	required="true" />
		<cfargument name="amount"		type="string" 	required="true" />

		<cfset var var_programId 	= "" />
		<cfset var var_amount 		= "" />

		<cfset var_programId 	= trim(arguments.programId) />
		<cfset var_amount 		= val(trim(arguments.amount)) />

		<cfquery name="qGetInActiveExceededLumpSums" datasource="#application.datasource#">
			SELECT	ISNULL(Program_Lump_Sums.Lump_Sum_Amount, 0) as Lump_Sum_Amount,
					Program_Lump_Sum_Name.Program_Lump_Sum_Name
			FROM	Program_Lump_Sums
					INNER JOIN Program_Lump_Sum_Name ON
					Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID AND
					Program_Lump_Sum_Name.Active = 0
			WHERE	Program_Lump_Sums.Program_ID = <cfqueryparam value="#var_programId#" cfsqltype="CF_SQL_INTEGER">
			AND		Program_Lump_Sums.Deleted = 0
			AND		CAST(Lump_Sum_Amount AS DECIMAL(20,4)) > CAST('#var_amount#' AS DECIMAL(20,4))
		</cfquery>

		<cfreturn qGetInActiveExceededLumpSums />

	</cffunction>

	<cffunction name="getGrowthExceededLumpSumComponents" access="public" returntype="query">

		<cfargument name="programId" 	type="numeric" 	required="true" />
		<cfargument name="amount"		type="string" 	required="true" />

		<cfset var var_programId 	= "" />
		<cfset var var_amount 		= "" />

		<cfset var_programId 	= trim(arguments.programId) />
		<cfset var_amount 		= val(trim(arguments.amount)) />

		<cfquery name="qGetGrowthExceededLumpSums" datasource="#application.datasource#">
			SELECT	Program_Growth_Component_Tiers.Growth_Amount,
					Program_Growth_Components.Component_Name
			FROM	Program_Growth_Component_Tiers
					INNER JOIN Program_Growth_Components ON
					Program_Growth_Components.Program_Growth_Component_ID = Program_Growth_Component_Tiers.Program_Growth_Component_ID AND
					Program_Growth_Components.Deleted = 0
			WHERE	Program_Growth_Component_Tiers.Tier_Number = 1
			AND		Program_Growth_Component_Tiers.Program_ID = <cfqueryparam value="#var_programId#" cfsqltype="CF_SQL_INTEGER">
			AND		CAST(Program_Growth_Component_Tiers.Growth_Amount AS DECIMAL(20,4)) > CAST('#var_amount#' AS DECIMAL(20,4))
		</cfquery>

		<cfreturn qGetGrowthExceededLumpSums />

	</cffunction>

	<cffunction name="getTotalLumpSumAmountWithGrowth" access="public" returntype="query">

		<cfargument name="programId" 	type="numeric" 	required="true" />

		<cfset var var_programId 	= "" />

		<cfset var_programId 	= trim(arguments.programId) />

		<cfquery name="qGetTotalLumpSumAmountWithGrowth" datasource="#application.datasource#">
			DECLARE @Temp_Total_Lump_Sum_Amount TABLE
			(
			  Total_Amount DECIMAL(20,4) NOT NULL
			)

			INSERT INTO @Temp_Total_Lump_Sum_Amount
			SELECT 	ISNULL(CAST(Lump_Sum_Amount AS DECIMAL(20,4)),0)
			FROM 	Program_Lump_Sums
			WHERE	Program_ID =  <cfqueryparam value="#var_programId#" cfsqltype="CF_SQL_INTEGER">
			AND 	Deleted = 0

			INSERT INTO @Temp_Total_Lump_Sum_Amount
			SELECT	ISNULL(CAST(Program_Growth_Component_Tiers.Growth_Amount AS DECIMAL(20,4)),0)
			FROM	Program_Growth_Component_Tiers
					INNER JOIN Program_Growth_Components ON
					Program_Growth_Components.Program_Growth_Component_ID = Program_Growth_Component_Tiers.Program_Growth_Component_ID AND
					Program_Growth_Components.Deleted = 0
			WHERE	Program_Growth_Component_Tiers.Tier_Number = 1
			AND		Program_Growth_Component_Tiers.Program_ID = <cfqueryparam value="#var_programId#" cfsqltype="CF_SQL_INTEGER">

			SELECT	SUM(Total_Amount) AS Total_Lump_Sum_Amount
			FROM	@Temp_Total_Lump_Sum_Amount
		</cfquery>

		<cfreturn qGetTotalLumpSumAmountWithGrowth />

	</cffunction>

	<!--- Dev Note: KAL; D23223: Margin Page functionality changes --->
	<cffunction name="getProfitMarginLayered" access="public" returntype="numeric">
		<cfargument name="program_id" type="string" required="true" />
		<cfscript>
			margin_display_style = application.util.query.get_Setting("margin_display_style");
			spName = 'GET_PROFIT_MARGIN_LAYERED';
			if(margin_display_style == 'custom_h'){
				spName = 'GET_PROFIT_MARGIN_LAYERED';	/* GET_PROFIT_MARGIN_LAYERED_Custom_H 	- Legacy : leave for now in case we need to isolate this code*/
			}
		</cfscript>

		<CFSTOREDPROC PROCEDURE="#spName#" datasource="#application.datasource#" returncode="true" result="profitMarginLayered">
			<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_INTEGER" VARIABLE="CA_ID" VALUE="#trim(arguments.Program_ID)#" NULL="No">
		</CFSTOREDPROC>

		<!--- You have return something when calling via ajax; statuscode is not working so returning executiontime instead.--->
		<cfreturn profitMarginLayered.executionTime />
	</cffunction>

	<cffunction name="getMarginOverride" output="false">
		<cfargument name="program_id" type="numeric" required="true">
		<cfargument name="uom" type="numeric" required="true">

		<cfquery name="local.qGetOverride" datasource="#application.datasource#">
			SELECT 	BSA_Foodservice_Items_Master_ID
					,Field_Name
					,Old_Value
					,New_Value
					,Created_Date
					,ISNULL(u.name_first + ' ' + u.name_last, 'Unknown') AS User_Name
			  FROM Contract_Product_Margin_Override cpmo
			  		LEFT JOIN _Users u ON cpmo.Created_By = u.user_ID
			 WHERE Contract_Main_ID = <cfqueryparam value="#arguments.program_id#">
			 		AND Unit_of_Measure = <cfqueryparam value="#arguments.uom#">
			 		AND CPMO.Deleted = 0
		</cfquery>

		<cfreturn local.qGetOverride>
	</cffunction>
<!--- 114617 :: Ideal Price START --->
	<cffunction name="SaveFixedPrice"  output="false" access="remote" returnFormat="json">

		<cfquery name="ProgInfo" datasource="#application.datasource#">
			SELECT CM.Contract_Number, U.Name_First+' '+U.Name_Last AS userName
			FROM Contract_Main CM
			INNER JOIN _Users U
			ON U.User_ID = '#request.AccessStructure.User_ID#'
			WHERE CM.Contract_Main_ID =  '#arguments.contract_main_id#'
		</cfquery>

		<cfset FPField = 'FPR_CS'>

		<cfloop list="#arguments.Approvelist#" index="BSAID">

			<cfif evaluate("arguments.#replace(BSAID,'-','_','ALL')#_Fixed_Price_Change")>
				<cfquery name="BSAInfo" datasource="#application.datasource#">
					SELECT Item	, Description
					FROM BSA_Foodservice_Items_Master
					WHERE BSA_Foodservice_Items_Master_ID = '#BSAID#'
				</cfquery>
				<cfset info = #BSAInfo.item#&'  '&#BSAInfo.Description#&'  '&'Fixed Price Update'>
				<cfset FixedPrice  = evaluate("arguments.#replace(BSAID,'-','_','ALL')#_Fixed_Price")>

				<cfquery name="local.qSaveFixedPrice" datasource="#application.datasource#">
					UPDATE Program_Fixed_Price_Product_Data
					SET Fixed_Price_Value =
				<cfif arguments.MarginType EQ 1>--1 CS
                                  CASE WHEN Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID = 1  THEN #FixedPrice#
                                            WHEN Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID = 2  THEN #FixedPrice# / CAST ( IM.net_weight AS decimal(10,4) )
                                  ELSE #FixedPrice# END
                                <cfelseif arguments.MarginType EQ 3>--3 LB
                                  CASE WHEN Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID = 1  THEN #FixedPrice# * CAST( IM.net_weight AS decimal(10,4) )
                                            WHEN Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID = 2  THEN #FixedPrice#
                                  ELSE #FixedPrice# END
                                <cfelseif arguments.MarginType EQ 2>--2 EQ
                                  CASE WHEN Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID = 1  THEN #FixedPrice# * IM.Case_Equivalent
                                            WHEN Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID = 2  THEN #FixedPrice# * IM.Case_Equivalent / CAST ( IM.net_weight AS decimal(10,4) )
                                  ELSE #FixedPrice# END
                                </cfif>
					FROM  Program_Fixed_Price_Product_Data
					INNER JOIN Contract_Products
					ON Contract_Products.Contract_Products_ID = Program_Fixed_Price_Product_Data.Contract_Products_ID
					INNER JOIN BSA_Foodservice_Items_Master IM
					ON IM.bsa_FoodService_Items_Master_Id = Contract_Products.BSA_Foodservice_Items_Master_ID
					WHERE Contract_Products.BSA_Foodservice_Items_Master_ID = '#BSAID#'
					AND Contract_Products.Contract_Main_ID = '#arguments.contract_main_id#'
					AND  Contract_Products.Deleted = 0

					INSERT INTO Contract_Evaluation_Notes (Entered_By, Eval_Action, Notes, Contract_Number, Contract_Notes_Type)
					VALUES	('#ProgInfo.userName#', 'Ideal Price Update', '#info#', '#ProgInfo.Contract_Number#', '2')
				</cfquery>
			</cfif>
		</cfloop>
		<CFSTOREDPROC PROCEDURE="GET_PROFIT_MARGIN_LAYERED" datasource="#application.datasource#">
			<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_INTEGER" VARIABLE="CA_ID" VALUE="#arguments.contract_main_id#" NULL="No">
		</CFSTOREDPROC>
	</cffunction>
<!--- 114617 :: Ideal Price END --->
</cfcomponent>