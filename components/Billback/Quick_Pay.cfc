<cfcomponent>


<cffunction name="getLSAmount" returntype="any" access="remote" output="false" hint="get list of Operators on the program">
	<cfargument name="ContractMainID" required="true" default="" />
	<cfargument name="ContractNumber" required="true" default="" />

	<cfset Remaining_LS_Amount = 0>

	<cfquery name="qLSAmount" datasource="#application.datasource#">
		SELECT ISNULL(SUM (cast (Lump_Sum_Amount AS decimal (20,4))), 0) AS Program_LS
		FROM Program_Lump_Sums PLS
		WHERE PLS.Program_ID = #arguments.ContractMainID#
		AND PLS.Deleted = 0
	</cfquery>

	<cfif qLSAmount.recordcount>
		<cfset Prg_LS_Amt = qLSAmount.Program_LS>
	<cfelse>
		<cfset Prg_LS_Amt = 0>
	</cfif>

	<cfquery name="local.tempPaidLS" datasource="#application.datasource#">
		IF OBJECT_ID('tempdb..##tempPaidLS') IS NOT NULL
		DROP TABLE ##tempPaidLS
	</cfquery>

	<cfquery name="qBBLSAmount" datasource="#application.datasource#">

		SELECT CASE WHEN B.Billback_Status_ID < 3  THEN ISNUll(SUM(B.BB_Amount),0) ELSE ISNUll(SUM(LS_Paid_Amount), 0)  END AS Paid_LS
		INTO	##tempPaidLS
		FROM Billback B
		LEFT JOIN Billback_Program bpg
		ON		bpg.Billback_ID = B.Billback_ID
		AND		bpg.Deleted = 0
		INNER JOIN Contract_Main cm
		On		cm.Contract_Main_ID = bpg.Program_ID
		LEFT JOIN BB_Lump_Sums BLS
		ON BLS.Billback_ID = B.Billback_ID
		AND BLS.Billback_Program_ID = bpg.Billback_Program_ID
		AND BLS.Deleted = 0
		WHERE B.Billback_Status_ID NOT IN (8)
		AND		B.Deleted = 0
		AND		cm.Contract_Number = '#arguments.ContractNumber#'
		GROUP BY B.Billback_Status_ID

		SELECT 	ISNULL(SUM(Paid_LS), 0) as Paid_LS
		FROM	##tempPaidLS

	</cfquery>

	<cfif qBBLSAmount.recordcount>
		<cfset BB_LS_Amt = qBBLSAmount.Paid_LS>
	<cfelse>
		<cfset BB_LS_Amt = 0>
	</cfif>

	<cfset Remaining_LS_Amount = Prg_LS_Amt - BB_LS_Amt>
	<cfreturn Remaining_LS_Amount>
</cffunction>

<cffunction name="getAccrualAmount" returntype="any" output="false" hint="get list of Remaining Accrual Amount on Program" access="remote">
	<cfargument name="ContractMainID" required="true" default="" />

	<cfquery name="qAccrualAmount" datasource="#application.datasource#">

SELECT CM.Contract_Main_ID, CMAD.Total_Accrued_Dollars,
          ISNULL(CMAD.Total_Accrued_Dollars - CMAD.Total_Spent_Dollars, 0) AS Total_Remaining_Dollars
FROM Contract_Main_Aux_Data CMAD
INNER JOIN  Contract_Main CM
ON                   CM.Contract_Main_ID = CMAD.Contract_Main_ID
WHERE CM.Contract_Main_ID = #arguments.ContractMainID#

	</cfquery>
	<cfset Total_Remaining_Dollars = NumberFormat(qAccrualAmount.Total_Remaining_Dollars,"0.00")>
	<cfreturn Total_Remaining_Dollars>
</cffunction>

<cffunction name="getOperators" returntype="any" access="remote" output="false" hint="get list of Operators on the program">
	<cfargument name="ContractMainID" required="true" default="" />

	<cfquery name="qOperators" datasource="#application.datasource#">
		SELECT O.BSA_Operator_ID AS ID, operator_name+' ( '+legacy_id+' )' AS Name, ISNULL(O.Default_Billback_Closing_Method_ID, 0) as CM
		FROM Contract_Operators CO
		INNER JOIN BSA_Operator O
		ON CO.BSA_Operator_ID = O.BSA_Operator_ID
		WHERE CO.Contract_Main_ID = #arguments.ContractMainID#
		AND CO.Deleted = 0
		ORDER BY operator_name
	</cfquery>
	<cfreturn qOperators>
</cffunction>

<cffunction name="getDistributors" returntype="any" access="remote" output="false" hint="get list of Distributors on the program">
	<cfargument name="ContractMainID" required="true" default="" />
	<cfargument name="PayeeAccrualDollars" required="false" default="0" />
	<cfargument name="discountType" required="false" default="0" />

	<cfquery name="qDistributors" datasource="#application.datasource#">
		<cfif arguments.Payee_Accrual_Dollars>
			<cfif arguments.discountType EQ 3>
				SELECT C.BSA_Foodservice_Customers_ID AS ID, Name+' ( '+C.Ship_To+' ) ' AS Name, SUM(ISNULL(CAST(PLS.Lump_Sum_Amount AS decimal (18,2)), 0)) as Accrued, ISNULL(C.Default_Billback_Closing_Method_ID, 0) as CM
				FROM GLA_Invoice_LS_Info_Details GLA
				INNER JOIN BSA_foodservice_Customers C
				ON		C.BSA_foodservice_Customers_ID = GLA.BSA_foodservice_Customers_ID
				INNER JOIN Program_Lump_Sums PLS
				ON PLS.Program_ID =GLA.Contract_Main_ID
				WHERE Contract_Main_ID = #arguments.ContractMainID#
				GROUP BY C.BSA_Foodservice_Customers_ID, Name, C.Ship_To, C.Default_Billback_Closing_Method_ID
				ORDER BY Name
			<cfelse>
			SELECT C.BSA_Foodservice_Customers_ID AS ID, Name+' ( '+C.Ship_To+' ) ' AS Name, CAST(SUM(ISNULL(Amount, 0)) as decimal(18,2)) as Accrued, ISNULL(C.Default_Billback_Closing_Method_ID, 0) as CM
			FROM GLA_Invoice_Rebate_Info_Details GLA
			INNER JOIN BSA_foodservice_Customers C
			ON		C.BSA_foodservice_Customers_ID = GLA.Distributor_ID
			WHERE Contract_Main_ID = #arguments.ContractMainID#
			GROUP BY C.BSA_Foodservice_Customers_ID, Name, C.Ship_To, C.Default_Billback_Closing_Method_ID
			ORDER BY Name
			</cfif>
		<cfelse>
			SELECT FC.BSA_Foodservice_Customers_ID AS ID, Name+' ( '+Ship_To+' ) ' AS Name, '0.00' as Accrued, ISNULL(FC.Default_Billback_Closing_Method_ID, 0) as CM
			FROM Contract_Distributors CD
			INNER JOIN BSA_Foodservice_Customers FC
			ON FC.BSA_Foodservice_Customers_ID =  CD.BSA_Foodservice_Customers_ID
			WHERE CD.Contract_Main_ID = #arguments.ContractMainID#
			AND CD.Deleted = 0
			AND	CD.Is_Group = 0
			ORDER BY Name
		</cfif>
	</cfquery>
	<cfreturn qDistributors>
</cffunction>

<cffunction name="getInfo" returntype="any" access="remote" output="false" hint="get info on selected Operator/Distributor/Broker">
	<cfargument name="Type" required="true" default="" />
	<cfargument name="PayeeID" required="true" default="" />

	<cfquery name="qInfo" datasource="#application.datasource#">
		<cfif arguments.Type EQ 'D'>

			SELECT '<br>&nbsp;&nbsp;&nbsp;'+Address_1+', '+City+', '+State+', '+ZipCode AS Info, Ship_To AS PayeeID
			FROM	BSA_Foodservice_Customers
			WHERE BSA_Foodservice_Customers_ID = '#arguments.PayeeID#'

		<cfelseif arguments.Type EQ 'O'>

			SELECT	'<br>&nbsp;&nbsp;&nbsp;'+Operator_City+', '+Operator_State+', '+Operator_Zip AS Info, Legacy_ID AS PayeeID
			FROM 	BSA_Operator
			WHERE 	BSA_Operator_ID = '#arguments.PayeeID#'

		<cfelseif arguments.Type EQ 'B'>

			SELECT  '<br>&nbsp;&nbsp;&nbsp;'+Broker_Name AS Info Broker_Shard AS PayeeID
			FROM   BSA_Foodservice_Brokers
			WHERE BSA_Foodservice_Brokers_ID = '#arguments.PayeeID#'
		</cfif>
	</cfquery>
	<cfreturn qInfo>
</cffunction>

<cffunction name="getVendorInfo" returntype="any" access="remote" output="false" hint="get info on selected vendor">
	<cfargument name="vendorID" required="true" default="" />
	<cfargument name="AQP" required="false" default="0" />

	<cfquery name="qVendorInfo" datasource="#application.datasource#">
		select DISTINCT
		<cfif arguments.AQP>
			Vendor_Name+'( '+Vendor_ID+' )' AS Vendor, Vendor_Master_ID, Vendor_ID
		<cfelse>
			Vendor_Name+'( '+Vendor_ID+' )'+'<br>'+Address_1+'<br>'+City +' '+State+' '+Zipcode
		</cfif>
		from Vendor_Master
		where Vendor_ID = '#arguments.vendorID#'
		and Deleted = 0
	</cfquery>
	<cfreturn qVendorInfo>
</cffunction>

<cffunction name="getComponentsList" returntype="query" hint="get list of Components on the program">
	<cfargument name="ContractNumber" required="true" default="" />
	<cfargument name="byProduct" required="false" default="0" />

	<cfquery name="qgetComponents" datasource="#Application.Datasource#">
		SELECT Component_Paid_To AS PaidTo,Program_Rebates_Component_Name AS CompName, PRCN.Program_Rebates_Component_Name_ID AS CompID, 'R' AS Product_Type, PT.Payment_Type_Name, PRCN.Accrual_On, '0' AS Discount_Comp_ID
		FROM Contract_main CM
		INNER JOIN Program_Rebates_Component PRC
		ON PRC.Program_ID = CM.Contract_Main_ID
		INNER JOIN Payment_Type PT
		ON PT.Payment_Type_ID = PRC.Claim_Mechanics
		AND (Is_Auto_Pay = 0 AND Restrict_From_Billback = 0 AND Off_Invoice = 0)
		INNER JOIN Program_Rebates_Component_Name PRCN
		ON PRCN.Program_Rebates_Component_Name_ID = PRC.Program_Rebates_Component_Name_ID
		WHERE CM.Contract_Number = '#arguments.ContractNumber#'
		AND PRC.Deleted = 0

		UNION

		SELECT Fixed_Component_Paid_to AS PaidTo,Program_Fixed_Component_Name AS CompName, PFCN.Program_Fixed_Component_Name_ID AS CompID, 'F' AS Product_Type, PT.Payment_Type_Name, PFCN.Accrual_On, '0' AS Discount_Comp_ID
		FROM Contract_main CM
		INNER JOIN Program_Fixed_Component PFC
		ON PFC.Program_ID = CM.Contract_Main_ID
		INNER JOIN Payment_Type PT
		ON PT.Payment_Type_ID = PFC.Claim_Mechanics
		AND (Is_Auto_Pay = 0 AND Restrict_From_Billback = 0 AND Off_Invoice = 0)
		INNER JOIN Program_Fixed_Component_Name PFCN
		ON PFCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
		WHERE CM.Contract_Number = '#arguments.ContractNumber#'
		AND PFC.Deleted = 0
<!---
		UNION

		SELECT Component_Paid_To AS PaidTo,Program_Growth_Components_Name AS CompName, PGCN.Program_Growth_Components_Name_Id AS CompID, 'G' AS Product_Type, PT.Payment_Type_Name, PGCN.Accrual_On
		FROM Contract_main CM
		INNER JOIN Program_Growth_Components PGC
		ON PGC.Program_ID = CM.Contract_Main_ID
		INNER JOIN Payment_Type PT
		ON PT.Payment_Type_ID = PGC.Claim_Mechanics
		AND (Is_Auto_Pay = 0 AND Restrict_From_Billback = 0 AND Off_Invoice = 0)
		INNER JOIN Program_Growth_Components_Name PGCN
		ON PGCN.Program_Growth_Components_Name_Id = PGC.Program_Growth_Components_Name_Id
		WHERE CM.Contract_Number = '#arguments.ContractNumber#'
		AND PGC.Deleted = 0
--->
		UNION

		SELECT DISTINCT Component_Paid_To AS PaidTo, 
		<!--- if arguments.byProduct is = to Component_Product then we need to concatenate the component name with the item number and description ---->
		<cfif trim(arguments.byProduct) eq "1">
			CASE WHEN LTRIM(RTRIM(ISNULL(PLC.Lump_Sum_Description, ''))) != '' THEN Program_Lump_Sum_Name + ' [ ' + LEFT(REPLACE(REPLACE(REPLACE(PLC.Lump_Sum_Description,CHAR(10), ''),CHAR(13),''),CHAR(9),''), 20) + ' ]' ELSE Program_Lump_Sum_Name END AS CompName,
		<cfelse>
			Program_Lump_Sum_Name AS CompName,
		</cfif>
		PLCN.Program_Lump_Sum_Name_ID AS CompID, 'L' AS Product_Type, PT.Payment_Type_Name, PLCN.Accrual_On, CAST(PLC.Program_Lump_Sum_ID as nvarchar(50)) AS Discount_Comp_ID
		FROM Contract_main CM
		INNER JOIN Program_Lump_Sums PLC
		ON PLC.Program_ID = CM.Contract_Main_ID
		INNER JOIN Payment_Type PT
		ON PT.Payment_Type_ID = PLC.Claim_Mechanics
		AND (Is_Auto_Pay = 0 AND Restrict_From_Billback = 0 AND Off_Invoice = 0)
		INNER JOIN Program_Lump_Sum_Name PLCN
		ON PLCN.Program_Lump_Sum_Name_ID = PLC.Program_Lump_Sum_Name_ID
		WHERE CM.Contract_Number = '#arguments.ContractNumber#'
		AND PLC.Deleted = 0
	</cfquery>

	<cfreturn qgetComponents>
</cffunction>

<cffunction name="CreateBillbacks" returntype="query" hint="This function will create billback">

	<cfargument name="form" required="true" type="struct">

	<cfset UserID = request.AccessStructure.User_ID>
	<cfset userManager = createobject("component", "components.user.userManager") />
	<cfset currentUserPositionID = userManager.getPositionId(UserID)>

<cfif len(arguments.form.vendor_id)>
	<cfquery name="qVendorGUID" datasource="#Application.Datasource#">
		SELECT *
		FROM Vendor_Master
		WHERE Vendor_ID = '#arguments.form.Vendor_ID#'
	</cfquery>
	<cfset VendorGUID = qVendorGUID.Vendor_master_ID>
</cfif>
	<cfquery name="qInsertIntoLog" datasource="#Application.Datasource#">
		SET NOCOUNT ON
		INSERT INTO Billback_Quick_Pay_Log (
			Analyst_User_ID
			,BB_Creator_ID
			,BB_Reference
			,BB_Title
			,BB_Start_Date
			,BB_End_Date
			,Component_Name
			,Component_Name_ID
			,Discount_Type
			,Payee_Type
			,Payee_ID
			,Program_ID
			,Total_Amount
			,User_Position_ID
			<cfif arguments.form.PayeeType EQ 'O'>
			,Operator_ID
			<cfelseif arguments.form.PayeeType EQ 'B'>
			,Broker_ID
			<cfelseif arguments.form.PayeeType EQ 'D'>
			,Distributor_ID
			,Detail_Distributor_ID
			</cfif>
			<cfif len(arguments.form.vendor_id)>
			,Vendor_ID
			,Vendor_master_ID
			</cfif>
			,Closing_Method_ID
			,Closing_Method
			,Accrual_Or_Not
			,Discount_Comp_ID
		)
		VALUES(	'#UserID#'
					,'#UserID#'
					,'#arguments.form.bb_number#'
					,'#arguments.form.bb_title#'
					,'#arguments.form.from_date#'
					,'#arguments.form.to_date#'
					,'#arguments.form.CompName#'
					,'#arguments.form.CompID#'
					,'#arguments.form.Discount_Type#'
					,'#arguments.form.PayeeType#'
					,'#arguments.form.PayeeID#'
					,#arguments.form.ContractMainID#
					,'#arguments.form.amount#'
					,#currentUserPositionID#
					,'#arguments.form.Payee#'
					<cfif arguments.form.PayeeType EQ 'D'>
					,'#arguments.form.Payee#'
					</cfif>
					<cfif len(arguments.form.vendor_id)>
					,'#arguments.form.Vendor_ID#'
					,'#VendorGUID#'
					</cfif>
					,#arguments.form.BB_Closing_Method#
					<cfif arguments.form.BB_Closing_Method EQ 1>,'Payment'<cfelse>,'Deduction'</cfif>
					,'#arguments.form.bIsAccrualOn#'
					,'#arguments.form.Discount_Comp_ID#'
					)
		SELECT Billback_Quick_Pay_Log_ID = @@IDENTITY
		SET NOCOUNT OFF
	</cfquery>


	<!---loop over list of product groups --->
	<cfloop index="idx" list="#arguments.form.lProductGroup#">

		<cfparam name="arguments.form.amount_#idx#" default="0" />
		<cfif len(#evaluate("arguments.form.amount_#idx#")#) eq 0>
			<cfset "arguments.form.amount_#idx#" = 0 />
		</cfif>
		<CFIF #evaluate("arguments.form.amount_#idx#")# NEQ 0>
		<cfquery name="qInsertGroupLevel" datasource="#Application.Datasource#">
			insert into Billback_Quick_Pay_Group_Level_Log
			(
				Program_ID, Billback_Quick_Pay_Log_ID, Group_Number, Product_Group_ID, Entered_Amount, Product_Group_Level_ID, Program_Number
			)
			values
			(
				'#arguments.form.ContractMainID#', '#qInsertIntoLog.Billback_Quick_Pay_Log_ID#', '#evaluate("arguments.form.groupNumber_#idx#")#',  '#replace(idx, "_", "-", "ALL")#', '#evaluate("arguments.form.amount_#idx#")#', '11', '#form.ContractNumber#'
			)
		</cfquery>
	</CFIF>

	</cfloop>

	<cfstoredproc procedure="Billback_Quick_Pay_Create" datasource="#application.datasource#">
		<cfprocparam cfsqltype="CF_SQL_INTEGER" dbvarname="@Billback_Quick_Pay_Log_ID" value="#qInsertIntoLog.Billback_Quick_Pay_Log_ID#" />
	</cfstoredproc>

	<cfquery name="qGetBBInfo" datasource="#Application.Datasource#">
		SELECT BB_Code
		FROM Billback_Quick_Pay_Log
		WHERE Billback_Quick_Pay_Log_ID = #qInsertIntoLog.Billback_Quick_Pay_Log_ID#
	</cfquery>

	<cfreturn qGetBBInfo>
</cffunction>

	<cffunction name="getQuickPayProductGroupLevel" returntype="any" access="remote" hint="get list of product groups">

		<cfargument name="contractMainID" required="true" default="" />
		<cfargument name="productType" required="true" default="" />
		<cfargument name="distributorID" required="false" default="" />
		<cfargument name="filterDistributor" required="false" default="0" />
		<cfargument name="payeeType" required="false" default="0" />

		<cfset retData = "" />

		<cfquery name="local.drop" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tempSpent') IS NOT NULL
			DROP TABLE ##tempSpent
			IF OBJECT_ID('tempdb..##tempAccrued') IS NOT NULL
			DROP TABLE ##tempAccrued
		</cfquery>

		<cfquery name="qGetProductsByGroup" datasource="#application.datasource#">

			DECLARE @Contract_Number varchar(20)
			SELECT @Contract_Number = Contract_Number FROM Contract_Main WHERE Contract_Main_ID = #arguments.contractMainID#

			IF OBJECT_ID('tempdb..##tempSpent') IS NOT NULL
			DROP TABLE ##tempSpent

			SELECT	cm.Contract_Number, i.Q_Brand_ID,
					SUM(CASE	WHEN bp.BB_Product_UOM = 2 THEN ISNULL(cast((bifd.paid_rate_lb * bif.item_volume_Paid_lb) as decimal(20,4)),0)
													ELSE ISNULL(cast((bifd.paid_rate_cs * bif.item_volume_Paid_cs) as decimal(20,4)),0)
											END
					)AS Spent
			INTO	##tempSpent
			FROM	 Contract_Main cm
					INNER JOIN Billback_Program bpg
					ON      bpg.Program_ID = cm.Contract_main_ID
					AND		bpg.Deleted = 0
					INNER JOIN Billback b
					ON      b.Billback_ID = bpg.Billback_ID
					AND     b.deleted = 0
					AND     b.Billback_Status_ID NOT IN (1, 2, 8)
					INNER JOIN billback_product bp
					ON		bp.billback_id = b.billback_id
					AND		bp.Billback_Program_ID = bpg.Billback_Program_ID
					AND		bp.Deleted =0
					INNER JOIN billback_product_Detail bpd
					ON		bpd.billback_id = b.billback_id
					AND		bp.billback_product_ID = bpd.billback_product_ID
					AND		bpd.Deleted =0
					INNER JOIN BB_item_final bif
					ON		bif.billback_product_id = bp.billback_product_id
					AND 	bif.deleted = 0
					INNER JOIN BB_Item_Final_detail bifd
					ON		bifd.BB_Item_Final_id = bif.BB_Item_Final_id
					AND		bifd.deleted = 0
					INNER JOIN BSA_Foodservice_items_master i
					ON		i.BSA_Foodservice_items_master_id = bp.product_id
			WHERE   cm.Contract_Number = @Contract_Number
			AND		bpd.BB_Product_Type_ID = '#arguments.productType#'
			<cfif arguments.payeeType EQ 1 AND arguments.filterDistributor AND len(arguments.distributorID)>
			AND bp.Distributor_ID = '#arguments.distributorID#'
			</cfif>
			GROUP BY cm.Contract_Number, i.Q_Brand_ID

			IF OBJECT_ID('tempdb..##tempAccrued') IS NOT NULL
			DROP TABLE ##tempAccrued

			SELECT	cm.Contract_Number, im.Q_Brand_ID, q.Q_Brand_Legacy, q.Q_Brand, CAST(SUM(ISNULL(gla_rebate.Amount, 0)) as decimal(18,2)) as Accrued, q.Q_Brand_ID as Product_Group_ID
			INTO	##tempAccrued
			FROM	Contract_Main cm
					INNER JOIN Contract_Products cp
					ON cp.Contract_Main_ID = cm.Contract_Main_ID
					AND cp.Deleted = 0
					AND cp.Product_Type_ID = '#arguments.productType#'
					INNER JOIN BSA_Foodservice_Items_Master im
					ON im.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
					INNER JOIN Q_Brand_Desc q
					ON q.Q_Brand_ID = im.Q_Brand_ID
					LEFT JOIN GLA_Invoice_Rebate_Info_Details gla_rebate
					ON gla_rebate.BSA_Foodservice_Items_Master_ID = im.BSA_Foodservice_Items_Master_ID
					AND gla_rebate.Contract_Number = cm.Contract_Number
					AND gla_rebate.Contract_Main_ID = cm.Contract_Main_ID
					WHERE	cm.Contract_Number = @Contract_Number
					<cfif arguments.payeeType EQ 1 AND arguments.filterDistributor AND len(arguments.distributorID)>
					AND gla_rebate.Distributor_ID = '#arguments.distributorID#'
					</cfif>
					GROUP BY cm.Contract_Number, im.Q_Brand_ID, q.Q_Brand_Legacy, q.Q_Brand, q.Q_Brand_ID

			SELECT	Q_Brand_Legacy
			, Q_Brand
			, a.Accrued
			, CAST(ISNULL(s.Spent, 0.00) as decimal(18,2)) as Spent
			, CASE WHEN Accrued = 0.00 THEN ISNULL(s.Spent, 0.00) * -1
				ELSE	CAST(a.Accrued - ISNULL(s.Spent, 0.00) as decimal(18,2))
				END	AS Balance
			, Product_Group_ID
			FROM	##tempAccrued a
			LEFT JOIN ##tempSpent s
			ON a.Q_Brand_ID = s.Q_Brand_ID
			AND s.Contract_Number = a.Contract_Number
			ORDER BY Balance desc,Spent ASC
		</cfquery>

		<cfreturn qGetProductsByGroup>

	</cffunction>

	<cffunction name="getTradeBalance" returntype="any" access="remote" hint="get Trade Balance">
		<cfargument name="Contract_Number" required="true" default="" />

		<cfquery name="qTradeBalance" datasource="#application.datasource#">
		Declare @Trade_Spend DECIMAL(20, 2), @paid_amount DECIMAL(20, 2)

		SELECT  @Trade_Spend = ISNULL(CAST(
																												SUM(ISNULL(Program_Spend_Non_Lumpsum, 0))
																												+
																											SUM(ISNULL((CASE
																																								WHEN TradeSpend.Effective_End_Date = TradeSpend.Max_Effective_End_Date
																																								THEN TradeSpend.Program_Spend_Lumpsum
																																								ELSE 0
																																								END), 0)) as DECIMAL(20, 2)),0)
		FROM  (
									SELECT CM.Effective_End_Date,
																Max_Effective_End_Date = MAX(CM.Effective_End_Date) OVER(PARTITION BY CM.Contract_Number),
																Program_Spend_Non_Lumpsum = (aux.Program_Spend_Non_Lumpsum
																*
																CAST(
																CAST(DATEDIFF(D, CM.Effective_Start_Date, CM.Effective_End_Date) + 1 as decimal(20, 4))
																/ CAST(DATEDIFF(D, CM.Contract_Start_Date, CM.Contract_End_Date) + 1 as decimal(20, 4))
																as decimal(20, 4)
																)),
																aux.Program_Spend_Lumpsum
									FROM  Contract_Main CM
									INNER JOIN Contract_Main_Aux_Data aux
									ON          aux.Contract_Main_ID = CM.Contract_Main_ID
									WHERE CM.Contract_Number = '#arguments.Contract_Number#'
									AND         CM.Approved = 1
									AND         CM.Effective_Start_Date IS NOT NULL
								) as TradeSpend

		--Payments
		SELECT @paid_amount = CAST(SUM(paid_amount) as DECIMAL(20, 2))   
		FROM  Payment_History_Details PHD
		WHERE PHD.Contract_Number = '#arguments.Contract_Number#'
		GROUP BY PHD.Contract_Number

		SELECT @Trade_Spend - ISNULL(@paid_amount, 0) AS Trade_Spend

</cfquery>
<cfreturn qTradeBalance.Trade_Spend>
	</cffunction>

	<cffunction name="getBudgetBalance" returntype="any" access="remote" hint="get Budget Balance">
		<cfargument name="contractMainID" required="true" default="" />
		<cfargument name="Contract_Number" required="true" default="" />

	<cfquery name="qGetBudgetID" datasource="#application.datasource#">
       IF OBJECT_ID('tempdb..##Pgm_Budget_List') IS NOT NULL
       DROP TABLE ##Pgm_Budget_List

       IF OBJECT_ID('tempdb..##Pgm_Budget_Balance') IS NOT NULL
       DROP TABLE ##Pgm_Budget_Balance

       SELECT DISTINCT CM.Contract_Number, b.Budget_ID, b.Allocation_Position_Level, b.Budget_Contribution_Factor_Type_ID, b.Budget_Desc, bc.Budget_Class_Desc
			 ,DENSE_RANK() OVER(Partition By CM.Contract_Number
                     Order by CASE WHEN CAST(GetDate() as DATE) between bc.Start_Date and bc.End_Date THEN 1 ELSE 0 END Desc, bc.End_Date Desc, bc.Start_Date Desc) as Row_ID
       INTO   ##Pgm_Budget_List
       FROM   Contract_Main CM
       INNER JOIN Budget_Program_Selection s
       ON            s.Program_ID = CM.Contract_Main_ID
       INNER JOIN Budget b
       ON            b.Budget_ID = s.Budget_ID
       INNER JOIN Budget_Class bc
       ON            bc.Budget_Class_ID = b.Budget_Class_ID
	   WHERE CM.Contract_Number =  '#arguments.Contract_Number#'
	</cfquery>

	<cfquery name="qTempBudgetBalance" datasource="#application.datasource#">
       -- Budget is position level
			 SELECT b.Budget_Desc, SUM(a.Committed_Dollar - a.Actual_Dollar) as budget_Balance, b.Budget_ID, b.Budget_Class_Desc, b.Row_ID
       INTO   ##Pgm_Budget_Balance
       FROM   ##Pgm_Budget_List b
       INNER JOIN Budget_Position_Allocation a
       ON            a.Budget_ID = b.Budget_ID
       WHERE  (b.Budget_Contribution_Factor_Type_ID = 3 OR b.Allocation_Position_Level != 4)

       AND           EXISTS (
              SELECT 1
              FROM   Budget_Position_Program bPgm
              WHERE  bPgm.Budget_ID = b.Budget_ID
              AND           bPgm.Contract_Number = b.Contract_Number
              AND           a.User_Position_ID = bPgm.User_Position_ID
       )
       GROUP BY b.Budget_Desc, b.Budget_ID, b.Budget_Class_Desc, b.Row_ID

       INSERT INTO ##Pgm_Budget_Balance (Budget_Desc, budget_Balance, Budget_ID, Budget_Class_Desc, Row_ID)
       SELECT b.Budget_Desc, SUM(a.Committed_Dollar - a.Actual_Dollar) as budget_Balance, b.Budget_ID, b.Budget_Class_Desc, b.Row_ID
       FROM   ##Pgm_Budget_List b
       INNER JOIN Budget_Distributor_Allocation a
       ON            a.Budget_ID = b.Budget_ID
       WHERE  b.Allocation_Position_Level = 4
       AND           EXISTS (
              SELECT 1
              FROM   Budget_Distributor_Program bPgm
              WHERE  bPgm.Budget_ID = b.Budget_ID
              AND           bPgm.Contract_Number = b.Contract_Number
              AND           a.BSA_Foodservice_Customers_ID = bPgm.BSA_Foodservice_Customers_ID
       )
       GROUP BY b.Budget_Desc, b.Budget_ID, b.Budget_Class_Desc, b.Row_ID
	</cfquery>
	<cfquery name="qBudgetBalance" datasource="#application.datasource#">
	SELECT Budget_Desc, ISNULL(budget_Balance, 0) AS budget_Balance, Budget_Class_Desc, Row_ID
	FROM ##Pgm_Budget_Balance
	ORDER BY Row_ID
	</cfquery>
			<cfreturn qBudgetBalance>
	</cffunction>

	<cffunction name="getDeductions" returntype="any" access="remote" hint="get Deductions for QP">
		<cfargument name="contractMainID" required="true" default="" />
	<cfquery NAME="qppg" datasource="#application.datasource#">
		IF OBJECT_ID('tempdb..##Deduction_Parent') IS NOT NULL
		DROP TABLE ##Deduction_Parent

		IF OBJECT_ID('tempdb..##Prg_Distributors') IS NOT NULL
		DROP TABLE ##Prg_Distributors

		SELECT cd.BSA_Foodservice_Customers_ID, cm.Distributor_Bill_To_ID
		INTO   ##Prg_Distributors
		FROM Contract_Distributors cd
		INNER JOIN BSA_Foodservice_Customers cm
		ON               cm.BSA_Foodservice_Customers_ID = cd.BSA_Foodservice_Customers_ID
		WHERE Contract_Main_ID = #arguments.ContractMainID#
		AND cd.Deleted = 0


		SELECT DISTINCT DD_Parent_ID
		INTO   ##Deduction_Parent
		FROM   Deductions
		WHERE  Deleted = 0
		AND DD_Rejected = 0
		AND Is_Credit = 0
		AND DD_Parent_ID IS NOT NULL

		SELECT D.DD_DedID
								, D.DD_Amount
								, CONVERT(VARCHAR(10), D.DD_Date, 101) as DD_Date
								, D.DD_Reference
								, BFC.Ship_To
								, BFC.Name
								, Deduction_ID
								, REPLACE(BFC.Name,' ','_') AS CustomName
								, Is_Locked
		FROM   Deductions D
		INNER JOIN BSA_Foodservice_Customers BFC
		ON BFC.BSA_Foodservice_Customers_ID = D.Distributor_ID
		WHERE D.Deleted = 0
		AND D.DD_Rejected = 0
		AND D.DD_Status IN (1,2)
		AND D.Is_Credit = 0
		AND D.Is_Write_Off = 0
		AND D.DD_Closure_ID IS NULL
		AND D.Deduction_ID NOT IN (SELECT DD_Parent_ID FROM ##Deduction_Parent)
		/*AND D.Distributor_ID IN (SELECT BSA_Foodservice_Customers_ID FROM ##Prg_Distributors)
		AND (
              (D.Distributor_ID IS NOT NULL AND D.Distributor_ID IN (SELECT BSA_Foodservice_Customers_ID FROM ##Prg_Distributors)) --Match on Ship To
              OR
              (D.Distributor_ID IS NULL AND D.Distributor_Bill_To_ID IN (SELECT Distributor_Bill_To_ID FROM ##Prg_Distributors)) --Match on Bill To
       )*/

</cfquery>
<cfreturn qppg>
</cffunction>

<cffunction name="getPrgComponents" returntype="query" access="remote">
	<cfargument name="Contract_Main_ID" required="true" default="" />

	<cfquery NAME="qGetPrgComp" datasource="#application.datasource#">
		--Get Rebate Components

		SELECT prcn.Program_Rebates_Component_Name_ID AS ID , prcn.Program_Rebates_Component_Name+'   [ REB ]'  AS Name, 'R' AS Discount_Type, prcn.Program_Rebates_Component_Name
        FROM Contract_Main cm
        INNER JOIN  Program_Rebates_Component prc
        ON            prc.Program_ID = cm.Contract_Main_ID
        AND            prc.Deleted =0
        INNER JOIN    Program_Rebates_Component_Name prcn
        ON            prcn.Program_Rebates_Component_Name_ID = prc.Program_Rebates_Component_Name_ID
        INNER JOIN  Payment_Type pt
        ON            pt.Payment_Type_ID = prc.Claim_Mechanics
        AND            pt.Restrict_From_Billback = 0 --Not restricted from Billback
        AND            pt.Is_Auto_Pay = 0 --No Auto Pay
        AND            pt.Off_Invoice = 0 --No OffInvoice
        WHERE cm.Approved =1
        --AND prc.Component_Paid_To = 1 --For now, only Payee = Distributor
        AND cm.Contract_Main_ID = '#arguments.Contract_Main_ID#'

        --Get Lumpsum Components

			UNION

        SELECT plcn.Program_Lump_Sum_Name_ID AS ID, plcn.Program_Lump_Sum_Name+'   [ LS ]'   AS Name, 'L' AS Discount_Type, plcn.Program_Lump_Sum_Name
        FROM Contract_Main cm
        INNER JOIN  Program_Lump_Sums plc
        ON            plc.Program_ID = cm.Contract_Main_ID
        AND            plc.Deleted =0
        INNER JOIN    Program_Lump_Sum_Name plcn
        ON            plcn.Program_Lump_Sum_Name_ID = plc.Program_Lump_Sum_Name_ID
        INNER JOIN  Payment_Type pt
        ON            pt.Payment_Type_ID = plc.Claim_Mechanics
        AND            pt.Restrict_From_Billback = 0 --Not restricted from Billback
        AND            pt.Is_Auto_Pay = 0 --No Auto Pay
        AND            pt.Off_Invoice = 0 --No OffInvoice
        WHERE cm.Approved = 1
       -- AND plc.Component_Paid_To = 1 --For now, only Payee = Distributor
        AND cm.Contract_Main_ID = '#arguments.Contract_Main_ID#'

        --Get Fixed Components

		UNION

        SELECT pfcn.Program_Fixed_Component_Name_ID AS ID, pfcn.Program_Fixed_Component_Name+'   [ FP ]'   AS Name, 'F' AS Discount_Type, pfcn.Program_Fixed_Component_Name
        FROM Contract_Main cm
        INNER JOIN  Program_Fixed_Component pfc
        ON            pfc.Program_ID = cm.Contract_Main_ID
        AND            pfc.Deleted =0
        INNER JOIN    Program_Fixed_Component_Name pfcn
        ON            pfcn.Program_Fixed_Component_Name_ID = pfc.Program_Fixed_Component_Name_ID
        INNER JOIN  Payment_Type pt
        ON            pt.Payment_Type_ID = pfc.Claim_Mechanics
        AND            pt.Restrict_From_Billback = 0 --Not restricted from Billback
        AND            pt.Is_Auto_Pay = 0 --No Auto Pay
        AND            pt.Off_Invoice = 0 --No OffInvoice
        WHERE cm.Approved = 1
        --AND pfc.Fixed_Component_Paid_to = 1 --For now, only Payee = Distributor
        AND cm.Contract_Main_ID = '#arguments.Contract_Main_ID#'
	</cfquery>
	<cfreturn qGetPrgComp>
</cffunction>

<cffunction name="getPrgDistributors" returntype="query" access="remote">
	<cfargument name="ContractNumber" required="true" default="" />
	<cfset variables.appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
	<cfquery name="qGetPrgDistributors" datasource="#application.datasource#">
<!---Query for the Payee drop down--->
IF OBJECT_ID('tempdb..##tmp_Prg_Distributors') IS NOT NULL
DROP TABLE ##tmp_Prg_Distributors

SELECT DISTINCT cm.Contract_Number, c.BSA_Foodservice_Customers_ID, c.Ship_To, c.Name, CAST(0 AS DECIMAL(18,2)) AS Accrual_Dollars_Remaining
INTO ##tmp_Prg_Distributors
FROM Contract_Main cm
INNER JOIN  Contract_Distributors cd
ON			cd.Contract_Main_ID = cm.Contract_Main_ID
INNER JOIN	BSA_Foodservice_Customers c
ON			c.BSA_Foodservice_Customers_ID = cd.BSA_Foodservice_Customers_ID
WHERE cm.Contract_Number = '#arguments.ContractNumber#'
AND cm.Approved = 1
AND cd.Deleted = 0

<!---Accrual Balance at the Program/Customer Level--->
IF DBO.udf_GetAppSetting('Advance_Quick_Pay_Control')  = 1 <!---Accrual--->
BEGIN

	DECLARE @Accrual_Exclude_Document_Types VARCHAR(50)

	SELECT @Accrual_Exclude_Document_Types = ISNULL(value, '') FROM _Settings WHERE Input_Name = 'Accrual_Exclude_Document_Types'

	IF OBJECT_ID('tempdb..##tmpAccrualExcludeDocumentTypesList') IS NOT NULL
	DROP TABLE ##tmpAccrualExcludeDocumentTypesList

	SELECT LTRIM(RTRIM(Value)) as Exclude_Document_Type
	INTO   ##tmpAccrualExcludeDocumentTypesList
	FROM   DBO.listToTable(@Accrual_Exclude_Document_Types, ',')

	<!---Get Accrued dollars--->
	IF OBJECT_ID('tempdb..##tmp_Pgm_AccrualDollars') IS NOT NULL
		DROP TABLE ##tmp_Pgm_AccrualDollars

	SELECT gla.Contract_Number,
		   gla.Distributor_ID,
		   SUM(gla.Amount) AS Amount
	INTO ##tmp_Pgm_AccrualDollars
	FROM GLA_Combined gla
	WHERE Discount_Type_ID IN (1, 2, 3) <!---Fixed, Rebate & Lump sum--->
	AND ((@Accrual_Exclude_Document_Types != '' AND gla.Document_Type NOT IN (SELECT Exclude_Document_Type FROM ##tmpAccrualExcludeDocumentTypesList)) OR @Accrual_Exclude_Document_Types = '')
	AND EXISTS ( SELECT 1
				 FROM ##tmp_Prg_Distributors t
				 WHERE t.Contract_Number = gla.Contract_Number
			   )
	GROUP BY gla.Contract_Number, gla.Distributor_ID

<!---Get Spent dollars from Payment history--->
	IF OBJECT_ID('tempdb..##tmp_Pgm_SpentDollars') IS NOT NULL
		DROP TABLE ##tmp_Pgm_SpentDollars

	SELECT phid.Contract_Number,
		   CASE WHEN phid.Distributor_ID IS NOT NULL THEN CAST(phid.Distributor_ID AS VARCHAR(50)) <!---Associated Distributor--->
				ELSE phid.Payee_Unique_ID <!---Payee--->
			END as Distributor_ID,
		   SUM(phid.Rate) AS Spent_Dollars
	INTO ##tmp_Pgm_SpentDollars
	FROM Payment_History_Item_Details phid
	WHERE EXISTS (	SELECT 1
					FROM ##tmp_Prg_Distributors t
					WHERE t.Contract_Number = phid.contract_number
				 )
	AND EXISTS
		(
			<!---Rebate--->
			SELECT 1
			FROM   Billback_Program_Rebate_Component bprc
			INNER JOIN	Contract_Main cm
			ON			cm.Contract_Main_ID = bprc.Billback_Program_ID
			INNER JOIN	Program_Rebates_Component_Name prcn
			ON			bprc.Program_Rebates_Component_Name_ID = bprc.Program_Rebates_Component_Name_ID
			WHERE phid.Billback_id = bprc.Billback_ID
			AND   phid.Contract_number = cm.Contract_Number
			AND	  bprc.Deleted = 0
			AND   prcn.Accrual_On = 1

			UNION
			<!---Lump sum--->
			SELECT 1
			FROM Billback_Program_Lumpsum_Component bplc
			INNER JOIN  Billback_Program bp
			ON			bp.Billback_Program_ID = bplc.Billback_Program_ID
			AND			bp.Billback_ID = bplc.Billback_ID
			INNER JOIN  Contract_Main cm
			ON			cm.Contract_Main_ID = bp.Program_ID
			INNER JOIN  Program_Lump_Sums pls
			ON			pls.Program_ID = bp.Program_ID
			AND			pls.Program_Lump_Sum_ID = bplc.Program_Lump_Sum_ID
			INNER JOIN  Program_Lump_Sum_Name plsn
			ON			plsn.Program_Lump_Sum_Name_ID = pls.Program_Lump_Sum_Name_ID
			WHERE phid.Billback_id = bp.Billback_ID
			AND   phid.contract_number = cm.Contract_Number
			AND bplc.Deleted = 0
			AND bp.deleted = 0
			AND pls.Deleted =0
			AND	plsn.Accrual_On = 1

			UNION
			/* Fixed */
			SELECT 1
			FROM Program_Fixed_Component pfc
			INNER JOIN	Billback_Program bp
			ON			pfc.Program_ID = bp.Program_ID
			INNER JOIN	Contract_Main cm
			ON			cm.Contract_Main_ID = bp.Program_ID
			INNER JOIN	Program_Fixed_Component_Name pfcn
			ON			pfc.Program_Fixed_Component_Name_Id = pfcn.Program_Fixed_Component_Name_Id
			WHERE phid.Billback_id = bp.Billback_ID
			AND   phid.contract_number = cm.Contract_Number
			AND pfc.deleted = 0
			AND bp.deleted = 0
			AND	pfcn.Accrual_On = 1
			)
	GROUP BY phid.Contract_Number,
			 CASE WHEN phid.Distributor_ID IS NOT NULL THEN CAST(phid.Distributor_ID AS VARCHAR(50))
				ELSE phid.Payee_Unique_ID
			 END


	IF OBJECT_ID('tempdb..##tmp_Pgm_Accrual_Spent') IS NOT NULL
		DROP TABLE ##tmp_Pgm_Accrual_Spent

	SELECT a.Contract_Number,
		   a.Distributor_ID,
		   SUM(a.Amount) as Accrued_Dollars,
		   SUM(ISNULL(s.Spent_Dollars, 0)) AS Spent_Dollars
	INTO ##tmp_Pgm_Accrual_Spent
	FROM ##tmp_Pgm_AccrualDollars a
	LEFT JOIN ##tmp_Pgm_SpentDollars s
	ON		s.Contract_Number = a.Contract_Number
	AND		s.Distributor_ID = CAST(a.Distributor_ID AS VARCHAR(50))
	GROUP BY a.Contract_Number, a.Distributor_ID


	UPDATE ##tmp_Prg_Distributors
	SET Accrual_Dollars_Remaining = CONVERT(DECIMAL(18,2), Accrued_Dollars - Spent_Dollars)
	FROM ##tmp_Prg_Distributors t
	INNER JOIN ##tmp_Pgm_Accrual_Spent a
	ON		   a.Contract_Number = t.Contract_Number
	AND		   a.Distributor_ID = t.BSA_Foodservice_Customers_ID

	END
      <!---Final output--->
       SELECT Contract_Number, Ship_To as Payee_ID
										<cfif variables.appSettings.get_Setting('Quick_Pay_in_Program_Search') EQ 1 OR variables.appSettings.get_Setting('Quick_Pay_in_Program_Search') EQ 3>
										, Name+' ( $ '+cast (Accrual_Dollars_Remaining AS varchar)+' )' AS Name
										<cfelse>
										, Name
										</cfif>
										, BSA_Foodservice_Customers_ID
										, Name AS distName
       FROM ##tmp_Prg_Distributors t
       ORDER BY Accrual_Dollars_Remaining DESC

	</cfquery>
<cfreturn qGetPrgDistributors>
</cffunction>

<cffunction  name="LogTableInsert"  output="false" access="remote" returnFormat="json">
	<cfargument name="Contract_Main_ID" required="false" default="" />
	<cfargument name="Closing_Method" required="false" default="D" />
	<cfargument name="Closing_Method_ID" required="false" default="2" />
	<cfargument name="Deduction_ID" required="false" default="00000000-0000-0000-0000-000000000000" />
	<cfargument name="DD_Number" required="false" default="" />
	<cfargument name="DD_Ref_selected" required="false" default="" />
	<cfargument name="DD_selected_Amount" required="false" default="" />
	<cfargument name="BB_Start_Date" required="false" default="" />
	<cfargument name="BB_End_Date" required="false" default="" />
	<cfargument name="Billback_Date" required="false" default="" />
	<cfargument name="Payee_Type" required="false" default="" />
	<cfargument name="Payee_ID" required="false" default="" />
	<cfargument name="Discount_Type" required="false" default="" />
	<cfargument name="Component_Name" required="false" default="" />
	<cfargument name="Component_Name_ID" required="false" default="0" />
	<cfargument name="Vendor_Master_ID" required="false" default="00000000-0000-0000-0000-000000000000" />
	<cfargument name="Vendor_ID" required="false" default="" />
	<cfargument name="User_Position_ID" required="false" default="" />
	<cfargument name="BB_Creator_ID" required="false" default="" />
	<cfargument name="Distributor_ID" required="false" default="00000000-0000-0000-0000-000000000000" />
	<cfargument name="Called_From" required="false" default="Programs" />

<cfset Total = 1>

<cfif arguments.Called_From EQ 'Programs' AND len(arguments.Deduction_ID)>
	<cfset Total = listLen(arguments.Deduction_ID)>
<cfelseif arguments.Called_From EQ 'Programs' AND ! len(arguments.Deduction_ID)>
	<cfset arguments.Deduction_ID = '00000000-0000-0000-0000-000000000000'>
	<cfset arguments.DD_selected_Amount = '0.00'>
</cfif>

<cfif arguments.Called_From EQ 'Deductions' AND len(arguments.Contract_Main_ID)>
	<cfset Total = listLen(arguments.Contract_Main_ID)>
</cfif>

<cfset uniqueID = #request.AccessStructure.User_ID#&'_'&#DateTimeFormat(now(),"mmddyyhhmmss")#>

	<cfloop from="1" to="#Total#" index="ID">

		<cfif arguments.Called_From EQ 'Deductions'>
			<cfset CMID = #listgetat(arguments.Contract_Main_ID, ID)#>
			<cfset Payee_Type = 'D'>
			<!---<cfset Payee_Type = #evaluate('arguments.#CMID#_Payee_Type')#> FUTURE --->
			<cfset Distributor_ID  = #evaluate('arguments.#CMID#_PayeeID')#>
			<cfset Payee_ID = #evaluate('arguments.#CMID#_PayeeNumber')#>
			<cfset Discount_Type = #evaluate('arguments.#CMID#_Discount_Type')#>
			<cfset Component_Name = #evaluate('arguments.#CMID#_CompName')#>
			<cfset Component_Name_ID = #evaluate('arguments.#CMID#_CompID')#>
		<cfelse>
			<cfset CMID = arguments.Contract_Main_ID>
			<cfset Lock = setDDLock(1, '#listgetat(arguments.Deduction_ID, ID)#')>
		</cfif>

		<cfset Components = #arguments.Prg_Comp_Len#-1>
		<cfloop from="0" to="#Components#" index="CompLen">

			<cfif arguments.Called_From EQ 'Programs'>
				<cfset DDID = '#listgetat(arguments.Deduction_ID, ID)#'>
				<cfset DD_Allocation =  #arguments[DDID&"_Allocation_" & CompLen]# >
				<cfset Payee_Type = #arguments[DDID&"_PayeeType_" & CompLen]# >
				<cfset Payee_ID = #arguments[DDID&"_Payee_ID_" & CompLen]# >
				<cfset Distributor_ID = #arguments[DDID&"_BB_Payee_" & CompLen]# >
				<cfset Discount_Type = #arguments[DDID&"_Discount_Type_" & CompLen]# >
				<cfset Component_Name = #arguments[DDID&"_CompName_" & CompLen]# >
				<cfset Component_Name_ID = #arguments[DDID&"_CompID_" & CompLen]# >
			</cfif>

<cfif ( StructKeyExists(arguments, "#DDID#_Allocation_#CompLen#") AND arguments[DDID&"_Allocation_" & CompLen] AND LEN(arguments[DDID&"_Allocation_" & CompLen]) ) OR arguments.Deduction_ID EQ '00000000-0000-0000-0000-000000000000'>

	<cfquery name="qinsertData" datasource="#application.datasource#">
	INSERT INTO ADV_Quick_Pay_Billback_Log (
																																							Program_ID
																																							,Closing_Method
																																							,Closing_Method_ID
																																							,Deduction_ID
																																							<cfif arguments.Closing_Method_ID EQ 2>
																																							,DD_DedID
																																							,Total_Amount
																																							,Reference_Number
																																							</cfif>
																																							,User_Position_ID
																																							,BB_Creator_ID
																																							,User_ID
																																							,Called_From
																																							,BB_Start_Date
																																							,BB_End_Date
																																							,Billback_Date
																																							,Payee_Type
																																							,Payee_ID
																																							,Discount_Type
																																							,Component_Name
																																							,Component_Name_ID
																																							,Vendor_Master_ID
																																							,Vendor_ID
																																							,Distributor_ID
	)
	VALUES(
															#CMID#
															,'#arguments.Closing_Method#'
															,'#arguments.Closing_Method_ID#'
															<cfif arguments.Closing_Method_ID EQ 2>
															<cfif arguments.Called_From EQ 'Programs'>
															,'#DDID#'
																<cfif len(arguments.DD_Number)>
																	,'#listgetat(arguments.DD_Number, ID)#'
																<cfelse>
																	, NULL
																</cfif>
																	,'#DD_Allocation#'
																<cfif len(arguments.DD_Ref_selected)>
																	,'#listgetat(arguments.DD_Ref_selected, ID)#'
																<cfelse>
																	, NULL
																</cfif>
															<cfelse>
															,'#arguments.Deduction_ID#'
															,'#arguments.DD_Number#'
															,'#arguments.DD_selected_Amount#'
															,'#arguments.DD_Ref_selected #'
															</cfif>
															<cfelse>
																,'00000000-0000-0000-0000-000000000000'
															</cfif>
															,#arguments.User_Position_ID#
															,'#request.AccessStructure.User_ID#'
															,'#uniqueID#'
															,'#Called_From#'
															,'#arguments.BB_Start_Date#'
															,'#arguments.BB_End_Date#'
															,'#arguments.BB_Date#'
																,'#Payee_Type#'
																,'#Payee_ID#'
																,'#Discount_Type#'
																,'#Component_Name#'
																,#Component_Name_ID#
															,'#arguments.Vendor_Master_ID#'
															,'#arguments.Vendor_ID#'
															,<cfif len(Distributor_ID)>'#Distributor_ID#'<cfelse>'00000000-0000-0000-0000-000000000000'</cfif>

	)
	</cfquery>
	</cfif>
	</cfloop>
	</cfloop>

	<cfset var strData = structnew()>
	<cfset arrBBDate = ArrayNew(1)>
	<cfset arrBBStartDate = ArrayNew(1)>
	<cfset arrBBEndDate = ArrayNew(1)>
	<cfset arrCompID = ArrayNew(1)>
	<cfset arrCompName = ArrayNew(1)>
	<cfset arrCompNameID = ArrayNew(1)>
	<cfset arrCompPaidTo = ArrayNew(1)>
	<cfset arrContractMainID = ArrayNew(1)>
	<cfset arrContractNumber = ArrayNew(1)>
	<cfset arrDDID = ArrayNew(1)>
	<cfset arrDiscountTypeID = ArrayNew(1)>
	<cfset arrDistID = ArrayNew(1)>
	<cfset arrShipTo = ArrayNew(1)>
	<cfset arrUniqueID = ArrayNew(1)>

	<cfset arrVendorMasterID = ArrayNew(1)>
	<cfset arrVendorID = ArrayNew(1)>
	<cfset arrVendorName = ArrayNew(1)>


	<cfstoredproc procedure="ADV_Quick_Pay_Program_Details" datasource="#application.datasource#">
		<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR"  dbVarName = "@Unique_ID" value="#uniqueID#" null="no">
		<cfprocresult name = "qGetBBCreationInfo">
	</cfstoredProc>

	<cfset arrBBDate = ListToArray(valueList(qGetBBCreationInfo.Billback_Date))>
	<cfset arrBBStartDate = ListToArray(valueList(qGetBBCreationInfo.Billback_Period_Start_Date))>
	<cfset arrBBEndDate = ListToArray(valueList(qGetBBCreationInfo.Billback_Period_End_Date))>
	<cfset arrCompID = ListToArray(valueList(qGetBBCreationInfo.Component_ID))>
	<cfset arrCompName = ListToArray(valueList(qGetBBCreationInfo.Component_Name))>
	<cfset arrCompNameID = ListToArray(valueList(qGetBBCreationInfo.Component_Name_ID))>
	<cfset arrCompPaidTo = ListToArray(valueList(qGetBBCreationInfo.Component_Paid_To))>
	<cfset arrContractMainID = ListToArray(valueList(qGetBBCreationInfo.Contract_Main_ID))>
	<cfset arrContractNumber = ListToArray(valueList(qGetBBCreationInfo.Contract_Number))>
	<cfset arrDDID = ListToArray(valueList(qGetBBCreationInfo.Deduction_ID))>
	<cfset arrDiscountTypeID = ListToArray(valueList(qGetBBCreationInfo.Discount_Type_ID))>
	<cfset arrDistID = ListToArray(valueList(qGetBBCreationInfo.Distributor_ID))>
	<cfset arrShipTo = ListToArray(valueList(qGetBBCreationInfo.Ship_To))>
	<cfset arrUniqueID = qGetBBCreationInfo.User_ID>

	<cfset arrVendorMasterID = ListToArray(valueList(qGetBBCreationInfo.Vendor_Master_ID))>
	<cfset arrVendorID = ListToArray(valueList(qGetBBCreationInfo.Vendor_ID))>
	<cfset arrVendorName = ListToArray(valueList(qGetBBCreationInfo.Vendor_Name))>

	<cfset strData.BBDate = arrBBDate>
	<cfset strData.BBStartDate = arrBBStartDate>
	<cfset strData.BBEndDate = arrBBEndDate>
	<cfset strData.CompID = arrCompID>
	<cfset strData.CompName = arrCompName>
	<cfset strData.CompNameID = arrCompNameID>
	<cfset strData.CompPaidTo = arrCompPaidTo>
	<cfset strData.ContractMainID = arrContractMainID>
	<cfset strData.ContractNumber = arrContractNumber>
	<cfset strData.DDID = arrDDID>
	<cfset strData.DiscountTypeID = arrDiscountTypeID>
	<cfset strData.DistID= arrDistID>
	<cfset strData.ShipTo = arrShipTo>
	<cfset strData.UniqueID = arrUniqueID>
	<cfset strData.VendorMasterID= arrVendorMasterID>
	<cfset strData.VendorID = arrVendorID>
	<cfset strData.VendorName = arrVendorName>

	<cfset strData = serializeJSON(strData, "struct")>

	<cfreturn strData>
</cffunction>

<cffunction  name="LogTableUpdate"  output="false" access="remote" returnFormat="json">
<cfargument name="Deduction_ID" required="false" default="00000000-0000-0000-0000-000000000000" />
<cfargument name="Reference_Number" required="false" default="" />
<cfargument name="Total_Amount" required="false" default="" />
<cfargument name="BB_Start_Date" required="false" default="" />
<cfargument name="BB_End_Date" required="false" default="" />
<cfargument name="Billback_Date" required="false" default="" />
<cfargument name="Payee_Type" required="false" default="" />
<cfargument name="Payee_ID" required="false" default="" />
<cfargument name="Discount_Type" required="false" default="" />
<cfargument name="Component_Name" required="false" default="" />
<cfargument name="Component_Name_ID" required="false" default="" />
<cfargument name="Distributor_ID" required="false" default="00000000-0000-0000-0000-000000000000" />
<cfargument name="Vendor_Master_ID" required="false" default="" />
<cfargument name="Vendor_ID" required="false" default="" />
<cfargument name="Tax_Type" required="false" default="0" />
<cfargument name="unique_ID" required="true" default="" />
<cfargument name="Called_From" required="false" default="Programs" />
<cfset variables.appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<cfif ! len(arguments.Deduction_ID)>
	<cfset arguments.Deduction_ID = '00000000-0000-0000-0000-000000000000'>
</cfif>

<cfif ! len(arguments.Vendor_Master_ID)>
	<cfset arguments.Vendor_Master_ID = '00000000-0000-0000-0000-000000000000'>
</cfif>

<cfquery name="qDeleteData" datasource="#application.datasource#">
	DELETE
	FROM ADV_Quick_Pay_Billback_Log
	WHERE User_ID = '#arguments.unique_ID#'
</cfquery>


<cfloop from="1" to="#listLen(arguments.Deduction_ID)#" index="ID">
		<cfif arguments.Called_From EQ 'Programs'>
			<cfset DDID = '#listgetat(arguments.Deduction_ID, ID)#'>
		</cfif>
		<cfset CompLength = arguments.Prg_Comp_Len - 1>
	<cfloop from="0" to="#CompLength#" index="CompLen"> <!--- COMPONENT LOOP--->
			<!----ONLY INSERT THE RECORDS WHICH HAS ALLOCATION AMOUNT GREATER THAN 0---->

		<cfif ( StructKeyExists(arguments, "#DDID#_Allocation_#CompLen#") AND arguments[DDID&"_Allocation_"&CompLen] AND LEN(arguments[DDID&"_Allocation_"&CompLen]) ) OR arguments.Deduction_ID EQ '00000000-0000-0000-0000-000000000000'>
			<cfquery name="qinsertData" datasource="#application.datasource#">
				INSERT INTO ADV_Quick_Pay_Billback_Log (
								Program_ID,Closing_Method,Closing_Method_ID
								,Deduction_ID
								<cfif arguments.Closing_Method_ID EQ 2>
								,DD_DedID
								</cfif>
								,Reference_Number,Total_Amount,User_Position_ID,BB_Creator_ID,User_ID,Called_From
								,BB_Start_Date,BB_End_Date,Billback_Date
								,Payee_Type,Payee_ID,Discount_Type,Component_Name,Component_Name_ID
								,Vendor_Master_ID,Vendor_ID,Distributor_ID
								,Tax_Type
				)
				VALUES(
					#arguments.Contract_Main_ID#,'#arguments.Closing_Method#','#arguments.Closing_Method_ID#'
					<cfif arguments.Closing_Method_ID EQ 2>
						<cfif arguments.Called_From EQ 'Programs'>
						,'#DDID#','#listgetat(arguments.DD_Number, ID)#','#listgetat(arguments.DD_Ref_selected, ID)#','#arguments[DDID&"_Allocation_" & CompLen]#'
						<cfelse>
						,'#arguments.Deduction_ID#','#arguments.DD_Number#','#arguments.DD_Ref_selected #', '#arguments.DD_selected_Amount#'
						</cfif>
					<cfelse>
						,'00000000-0000-0000-0000-000000000000', '#arguments.Billback_Number#', '#arguments.Total_Amount#'
					</cfif>
					, #arguments.User_Position_ID#,'#request.AccessStructure.User_ID#','#arguments.unique_ID#','#Called_From#'
					,'#arguments.BB_Start_Date#','#arguments.BB_End_Date#','#arguments.BB_Date#'
				<cfif arguments.Called_From EQ 'Programs'>
					,'#arguments[DDID&"_PayeeType_"&CompLen]#','#arguments[DDID&"_Payee_ID_"&CompLen]#','#arguments[DDID&"_Discount_Type_"&CompLen]#','#arguments[DDID&"_CompName_"&CompLen]#','#arguments[DDID&"_CompID_"&CompLen]#'
				<cfelse>
					,'#Payee_Type#','#Payee_ID#','#Discount_Type#','#Component_Name#',#Component_Name_ID#
				</cfif>
					,'#arguments.Vendor_Master_ID#','#arguments.Vendor_ID#',
					<cfif arguments.Called_From EQ 'Programs'>
					'#arguments[DDID&"_BB_Payee_"&CompLen]#'
					<cfelse>
					'#Distributor_ID#'
					</cfif>
					----117446 :: Billback - sales tax code  START
				<cfif appSettings.getBillbacksSalesTax() EQ 2>
					<cfif arguments.Called_From EQ 'Programs'>
						<cfif arguments.Closing_Method_ID EQ 2>
							, #arguments[DDID&"_TaxType_"&CompLen]#
						<cfelse>
							, #Tax_Type#
						</cfif>
						<cfelse>
							,0
						</cfif>
					<cfelse>
						, 0
					</cfif>
						----117446 :: Billback - sales tax code  END
				)
			</cfquery>
		</cfif>
	</cfloop>
</cfloop>

<cfstoredproc procedure="ADV_Quick_Pay_Billback_Create" datasource="#application.datasource#">
	<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@Unique_ID" null="no" value="#arguments.unique_ID#">
	<cfprocresult name="qBBCreation">
</cfstoredproc>

<cfquery name="qfinalInfo" datasource="#application.datasource#">
	SELECT    DD_DedID, Program_Number, BB_Code, 'Billback Creation Complete' as BB_Creation_Status_Desc
	FROM    ADV_Quick_Pay_Billback_Log
	WHERE    Deleted = 0
	AND 				Processed = 1
	AND        Billback_ID IS NOT NULL
	AND        User_ID =  '#arguments.unique_ID#'
</cfquery>
<cfif qfinalInfo.recordcount EQ 0>
	<cfquery name="qfinalInfo" datasource="#application.datasource#">
		SELECT 	DD_DedID, Program_Number, BB_Code, BB_Creation_Status_Desc
		FROM 			ADV_Quick_Pay_Billback_Log
		WHERE   Deleted = 0
		AND	 			 Processed = 1
		AND        Billback_ID IS NULL
		AND        User_ID =  '#arguments.unique_ID#'
</cfquery>
</cfif>

<cfset var strData = structnew()>

<cfset arrDDDedID = ArrayNew(1)>
<cfset arrBBInfo = ArrayNew(1)>
<cfset arrBBCreationStatus = ArrayNew(1)>
<cfset arrBBuniqueID = ArrayNew(1)>

<cfset arrDDDedID = ListToArray(valueList(qfinalInfo.DD_DedID))>
<cfset arrBBInfo = ListToArray(valueList(qfinalInfo.BB_Code))>
<cfset arrBBCreationStatus = ListToArray(ListRemoveDuplicates(valueList(qfinalInfo.BB_Creation_Status_Desc)))>
<cfset arrBBuniqueID =  '#arguments.unique_ID#'>

<cfset strData.DDDedID = arrDDDedID>
<cfset strData.BBInfo = arrBBInfo>
<cfset strData.BBCreationStatus = arrBBCreationStatus>
<cfset strData.BBuniqueID = arrBBuniqueID>

<cfreturn strData>
</cffunction>

<cffunction name="AutoApproveQPBillbacks"   output="false" access="remote" returnFormat="json">
	<cfargument name="uniqueID" required="true" default="" />

	<cfquery name="qcheckBBCreation" datasource="#application.datasource#">
		SELECT 1
		FROM ADV_Quick_Pay_Billback_Log
		WHERE Deleted = 0
		AND	  Processed = 1
		AND	  Billback_ID IS NOT NULL
		AND	  BB_Approved = 0
		AND	 User_ID = '#arguments.uniqueID#'
	</cfquery>

	<cfif qcheckBBCreation.recordcount>

		<cfstoredproc procedure="ADV_Quick_Pay_Billback_Approve_Match" datasource="#application.datasource#">
			<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@Unique_ID" null="no" value="#arguments.uniqueID#">
			<cfprocresult name="qBBApprove">
		</cfstoredproc>

	</cfif>

</cffunction>


<cffunction name="getPrograms" returntype="any" access="remote" hint="get Programs for QP">
	<cfargument name="Deduction_ID" required="true" default="" />

	<cfquery name="qgetPrograms" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##DD_Shipto_BillTo') IS NOT NULL
			DROP TABLE ##DD_Shipto_BillTo

			SELECT d.Deduction_ID, d.Distributor_ID, d.Distributor_Bill_To_ID
			INTO ##DD_Shipto_BillTo
			FROM   Deductions d
			WHERE d.Deduction_ID = '#arguments.Deduction_ID#'
			AND d.Deleted = 0
			--Below filters are not needed if we are checking them before.
			AND d.DD_Status IN (1,2)
			AND d.DD_Rejected = 0
			AND d.Is_Credit = 0
			AND d.Is_Write_Off = 0
			AND d.DD_Closure_ID IS NULL


			DECLARE @Default_Program_Contract_Number VARCHAR(20)
			SELECT @Default_Program_Contract_Number = Contract_Number FROM Contract_Main WHERE Contract_Main_ID IN ( SELECT Default_Program FROM Billback_Settings)

			--Get programs matching on Deduction Ship To or Bill To
			SELECT cm.Contract_Main_ID, cm.Contract_Number, cm.Contract_Title, cd.BSA_Foodservice_Customers_ID, c.Distributor_Bill_To_ID
			FROM Contract_Main cm
			INNER JOIN    Contract_Distributors cd
			ON                   cd.Contract_Main_ID = cm.Contract_Main_ID
			AND                  cd.Deleted =0
			INNER JOIN    BSA_Foodservice_Customers c
			ON                   c.BSA_Foodservice_Customers_ID = cd.BSA_Foodservice_Customers_ID
			WHERE cm.Deleted = 0
			AND cm.Approved = 1
			AND cm.Contract_Number != @Default_Program_Contract_Number --Not dummy program
			AND cm.Released = 0 --Not released
			AND cm.Manual_Cancel = 0 --Not cancelled
			AND EXISTS  ( SELECT 1
																FROM ##DD_Shipto_BillTo d
																WHERE (
																								(d.Distributor_ID IS NOT NULL AND d.Distributor_ID = cd.BSA_Foodservice_Customers_ID) --Match on ship to
																								OR
																								(d.Distributor_ID IS NULL AND d.Distributor_Bill_To_ID = c.Distributor_Bill_To_ID) --Match on Bill To
																							)
															)
	</cfquery>
	<cfreturn qgetPrograms>
</cffunction>

<cffunction name="getProgramAmountInfo" output="false" access="remote" returnFormat="json">
	<cfargument name="Contract_Main_ID" required="true" default="" />
	<cfargument name="Contract_Number" required="true" default="" />


<cfset var strData = structnew()>

<cfset arrAccrualAmt = ArrayNew(1)>
<cfset arrBudgetBalance = ArrayNew(1)>
<cfset arrPrgTradeSpend = ArrayNew(1)>

<cfset arrAccrualAmt = ''>
<cfset arrBudgetBalance = ''>
<cfset arrPrgTradeSpend = ''>

<cfloop from="1" to="#listlen(arguments.Contract_Main_ID)#" index="prg">
	<!---ACCRUAL BALANCE---->
	<cfset arrAccrualAmt = ListAppend(arrAccrualAmt,getAccrualAmount(#listGetAt(arguments.Contract_Main_ID, prg)#))>
	<!---BUDGET BALANCE---->
	<cfset BudgetBalance = getBudgetBalance(#listGetAt(arguments.Contract_Main_ID, prg)#, #listGetAt(arguments.Contract_Number, prg)#)>
	<cfset arrBudgetBalance = ListAppend(arrBudgetBalance, BudgetBalance.budget_Balance)>
	<!---TRADE BALANCE---->
	<cfset ProgTrade 	= getTradeBalance(#listGetAt(arguments.Contract_Number, prg)#) />
	<cfset arrPrgTradeSpend = ListAppend(arrPrgTradeSpend,ProgTrade)>
</cfloop>


<cfset strData.AccrualAmt = arrAccrualAmt>
<cfset strData.BudgetBalance = arrBudgetBalance>
<cfset strData.PrgTradeSpend = arrPrgTradeSpend>

<cfreturn strData>

</cffunction>

<cffunction name="SaveProgramInfo" output="false" access="remote" returnFormat="json">
	<cfargument name="Contract_Main_ID" required="true" default="" />
	<cfargument name="Contract_Number" required="true" default="" />
	<cfargument name="Deduction_ID" required="true" default="" />
	<cfargument name="DD_Ded_ID" required="true" default="" />
	<cfargument name="DD_Amount" required="true" default="" />
	<cfargument name="Reference_Number" required="true" default="" />


	<cfset uniqueID = #request.AccessStructure.User_ID#&'_'&#DateTimeFormat(now(),"mmddyyhhmmss")#>
<cfif arguments.DD_Amount LT 0>
	<cfset ISCredit = 1>
<cfelse>
	<cfset ISCredit = 0>
</cfif>
	<cfloop list="#arguments.Contract_Main_ID#" index="CMID">
		<cfset compList = this.getPrgComponents(CMID)>
		<cfloop query="compList">
		<cfquery name="qinsertData" datasource="#application.datasource#">
			INSERT INTO ADV_Quick_Pay_Billback_Log (Program_ID, BB_Creator_ID, Deduction_ID, DD_DedID, Total_Amount, Reference_Number, Closing_Method, Closing_Method_ID, Called_From, User_ID, Discount_Type, Component_Name, Component_Name_ID, Is_Credit)
			VALUES(#CMID#, '#request.AccessStructure.User_ID#', '#arguments.Deduction_ID#', '#arguments.DD_Ded_ID#', '#arguments.DD_Amount#', '#arguments.Reference_Number#', 'D', 2, 'Deductions', '#uniqueID#', '#compList.Discount_Type#', '#compList.Name#', #compList.ID#, #ISCredit#)
		</cfquery>
		</cfloop>
	</cfloop>

		<cfset var strData = structnew()>

		<cfset arrCompNameID = ArrayNew(1)>
		<cfset arrCompName = ArrayNew(1)>
		<cfset arrCompType = ArrayNew(1)>
		<cfset arrContractMainID = ArrayNew(1)>
		<cfset arrPayee = ArrayNew(1)>
		<cfset arrPayeeName = ArrayNew(1)>
		<cfset arrPayeeNumber = ArrayNew(1)>
		<cfset arrUniqueID = ArrayNew(1)>

		<cfstoredproc procedure="ADV_Quick_Pay_Program_Details" datasource="#application.datasource#">
			<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR"  dbVarName = "@Unique_ID" value="#uniqueID#" null="no">
			<cfprocresult name = "qGetBBCreationInfo">
		</cfstoredProc>

		<cfset arrCompNameID = ListToArray(valueList(qGetBBCreationInfo.Component_Name_ID))>
		<cfset arrCompName = ListToArray(valueList(qGetBBCreationInfo.Component_Name))>
		<cfset arrCompType = ListToArray(valueList(qGetBBCreationInfo.Discount_Type))>
		<cfset arrContractMainID = ListToArray(valueList(qGetBBCreationInfo.Contract_Main_ID))>
		<cfset arrPayee = ListToArray(valueList(qGetBBCreationInfo.Distributor_ID))>
		<cfset arrPayeeName = ListToArray(valueList(qGetBBCreationInfo.Name))>
		<cfset arrPayeeNumber = ListToArray(valueList(qGetBBCreationInfo.Ship_To))>
		<cfset arrUniqueID = uniqueID>

		<cfset strData.CompNameID = arrCompNameID>
		<cfset strData.CompName = arrCompName>
		<cfset strData.CompType = arrCompType>
		<cfset strData.ContractMainID = arrContractMainID>
		<cfset strData.PayeeID= arrPayee>
		<cfset strData.PayeeName= arrPayeeName>
		<cfset strData.PayeeNumber= arrPayeeNumber>
		<cfset strData.UniqueID= arrUniqueID>

		<cfset strData = serializeJSON(strData, "struct")>

		<cfreturn strData>

</cffunction>

<cffunction name="CreateQPBillbacks"  output="false" access="remote" returnFormat="json">



	<cfquery name="qDeleteData" datasource="#application.datasource#">
		DELETE FROM ADV_Quick_Pay_Billback_Log WHERE User_ID = '#arguments.unique_ID#'
	</cfquery>



<cfloop from="1" to="#listLen(arguments.Prg_selected)#" index="ID">
	<cfset CMID = #listgetat(arguments.Prg_selected, ID)#>
	<cfset Payee_Type = 'D'>
	<!---<cfset Payee_Type = #evaluate('arguments.#CMID#_Payee_Type')#> FUTURE --->
	<cfset CompLength = #listgetat(arguments.Comp_per_Prg, ID)#-1>
	<cfloop from="0" to="#CompLength#" index="comp"> <!--- COMPONENT LOOP--->
		<!----ONLY INSERT THE RECORDS WHICH HAS ALLOCATION AMOUNT GREATER THAN 0---->
		<cfif StructKeyExists(arguments, "#CMID#_Allocation_#comp#") AND evaluate('arguments.#CMID#_Allocation_#comp#') AND LEN(evaluate('arguments.#CMID#_Allocation_#comp#'))>
			<cfset Distributor_ID  = #evaluate('arguments.#CMID#_PayeeID_#comp#')#>
			<cfset Payee_ID = #evaluate('arguments.#CMID#_PayeeNumber_#comp#')#>
			<cfset Discount_Type = #evaluate('arguments.#CMID#_Discount_Type_#comp#')#>
			<cfset Component_Name = #evaluate('arguments.#CMID#_CompName_#comp#')#>
			<cfset Allocation = #evaluate('arguments.#CMID#_Allocation_#comp#')#>
			<cfset Amount = #evaluate('arguments.#CMID#_Allocation_#comp#')#>
			<cfset Component_Name_ID = #evaluate('arguments.#CMID#_CompID_#comp#')#>
			<cfset Tax_Type_ID = #evaluate('arguments.#CMID#_TaxType_#comp#')#>

			<cfif Amount LT 0>
				<cfset ISCredit = 1>
			<cfelse>
				<cfset ISCredit = 0>
			</cfif>

			<cfquery name="qUpdateData" datasource="#application.datasource#">
				INSERT INTO ADV_Quick_Pay_Billback_Log(
						BB_Start_Date	,	BB_End_Date,	Billback_Date,	Payee_Type,	Payee_ID
					,	Discount_Type,	Component_Name,	Component_Name_ID,	Distributor_ID
					,	Total_Amount,	DD_Split_Type,	DD_Write_Off_Reason_Code_ID,	DD_Write_Off_Reason
					,	DD_Split_Amount,	User_ID,	Program_ID, BB_Creator_ID, Deduction_ID
					, DD_DedID,Reference_Number, Closing_Method, Closing_Method_ID, Called_From, Is_Credit,Vendor_Master_ID,Vendor_ID, Tax_Type, User_Position_ID
				)
				VALUES(
						'#evaluate("arguments.#CMID#_BB_Start_Date_#comp#")#', '#evaluate("arguments.#CMID#_BB_End_Date_#comp#")#', '#evaluate("arguments.#CMID#_Billback_Date_#comp#")#','#Payee_Type#', '#Payee_ID#'
					, '#Discount_Type#', '#Component_Name#',#Component_Name_ID#, '#Distributor_ID#'
					, '#Amount#', #arguments.Split_Action#, #arguments.Reason_Code#, '#arguments.WriteOffReason#'
					, '#arguments.Remaining_Balance#','#arguments.unique_ID#',#CMID#, '#request.AccessStructure.User_ID#', '#arguments.Deduction_ID#'
					, '#arguments.DD_Ded_ID#', '#arguments.Reference_Number#', 'D', 2, 'Deductions', #ISCredit#,'#arguments.Vendor_Master_ID#','#arguments.Vendor_ID#', #Tax_Type_ID#, #arguments.User_Position_ID#
				)
			</cfquery>
		</cfif>
	</cfloop><!--- COMPONENT LOOP--->
</cfloop>

	<cfstoredproc procedure="ADV_Quick_Pay_Billback_Create" datasource="#application.datasource#">
		<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@Unique_ID" null="no" value="#arguments.unique_ID#">
		<cfprocresult name="qBBCreation">
	</cfstoredproc>


	<cfquery name="qfinalInfo" datasource="#application.datasource#">
		SELECT    DD_DedID, Program_Number, BB_Code, 'Billback Creation Complete' as BB_Creation_Status_Desc
		FROM    ADV_Quick_Pay_Billback_Log
		WHERE    Deleted = 0
		AND 				Processed = 1
		AND        Billback_ID IS NOT NULL
		AND        User_ID =  '#arguments.unique_ID#'
	</cfquery>
	<cfif qfinalInfo.recordcount EQ 0>
		<cfquery name="qfinalInfo" datasource="#application.datasource#">
			SELECT 	DD_DedID, Program_Number, BB_Code, BB_Creation_Status_Desc
			FROM 			ADV_Quick_Pay_Billback_Log
			WHERE   Deleted = 0
			AND	 			 Processed = 1
			AND        Billback_ID IS NULL
			AND        User_ID =  '#arguments.unique_ID#'
	</cfquery>
	</cfif>

	<cfset var strData = structnew()>

	<cfset arrDDDedID = ArrayNew(1)>
	<cfset arrBBInfo = ArrayNew(1)>
	<cfset arrBBCreationStatus = ArrayNew(1)>
	<cfset arrBBuniqueID = ArrayNew(1)>

	<cfset arrDDDedID = ListToArray(valueList(qfinalInfo.DD_DedID))>
	<cfset arrBBInfo = ListToArray(valueList(qfinalInfo.BB_Code))>
	<cfset arrBBCreationStatus = ListToArray(ListRemoveDuplicates(valueList(qfinalInfo.BB_Creation_Status_Desc)))>
	<cfset arrBBuniqueID =  '#arguments.unique_ID#'>

	<cfset strData.DDDedID = arrDDDedID>
	<cfset strData.BBInfo = arrBBInfo>
	<cfset strData.BBCreationStatus = arrBBCreationStatus>
	<cfset strData.BBuniqueID = arrBBuniqueID>

	<cfreturn strData>
</cffunction>

<cffunction name="setDDLock" output="false" access="remote" returnFormat="json">
	<cfargument name="Lock_Status" required="true" default="0" />
	<cfargument name="Deduction_ID" required="true" default="" />

	<cfset var strData = structnew()>
	<cfset arrstatus = ArrayNew(1)>
	<cfset arrLocked = ArrayNew(1)>

	<CFQUERY name="qcheckLockStatus" DATASOURCE="#Application.Datasource#">
		SELECT D.Is_Locked, U.Name_First+' '+U.Name_Last AS LockedBy
		FROM 	Deductions D
		INNER JOIN _Users U
		ON U.User_ID = Locked_By
		WHERE	D.Deduction_ID = '#arguments.Deduction_ID#'
		AND D.Is_Locked = 1
		AND D.Locked_By <> '#request.AccessStructure.User_ID#'
		AND D.Deleted=0
		AND U.Deleted = 0
	</CFQUERY>
<cfif ! qcheckLockStatus.recordcount>
	<CFQUERY name="LockDD" DATASOURCE="#Application.Datasource#">
		UPDATE 	Deductions
		SET 	Is_Locked = #arguments.Lock_Status#
						,Locked_By = '#request.AccessStructure.User_ID#'
						,DD_Locked_By_Quick_Pay = 1
		WHERE 	Deduction_ID = '#arguments.Deduction_ID#'
		AND Deleted=0
	</CFQUERY>
	<cfset arrLocked = 0>
	<cfset arrstatus  ="Deduction Is Sucesfully Locked.">
<cfelse>
	<cfset arrLocked = 1>
	<cfset arrstatus ="Deduction is locked by #qcheckLockStatus.LockedBy#, cannot use for quick pay.">
</cfif>
<cfset strData.Locked = arrLocked>
<cfset strData.status = arrstatus>
<cfset strData = serializeJSON(strData, "struct")>

<cfreturn strData>
</cffunction>

<cffunction name="DDUnLock" output="false" access="remote" returnFormat="json">
	<cfargument name="Lock_Status" required="true" default="0" />
	<cfargument name="Deduction_ID" required="true" default="" />

	<CFQUERY name="qcheckLockStatus" DATASOURCE="#Application.Datasource#">
		SELECT D.Is_Locked, U.Name_First+' '+U.Name_Last AS LockedBy
		FROM 	Deductions D
		INNER JOIN _Users U
		ON U.User_ID = Locked_By
		WHERE	D.Deduction_ID = '#arguments.Deduction_ID#'
		AND D.Is_Locked = 1
		AND D.Locked_By = '#request.AccessStructure.User_ID#'
		AND D.Deleted=0
		AND U.Deleted = 0
	</CFQUERY>

<cfif qcheckLockStatus.recordcount>
	<CFQUERY name="LockDD" DATASOURCE="#Application.Datasource#">
		UPDATE 	Deductions
		SET 	Is_Locked = #arguments.Lock_Status#
							,Locked_By = ''
							,DD_Locked_By_Quick_Pay = 0
		WHERE 	Deduction_ID = '#arguments.Deduction_ID#'
		AND Deleted=0
	</CFQUERY>
	<cfset arrLocked = 0>
	<cfset arrstatus  ="Deduction Is Sucesfully Un-Locked.">
</cfif>

<cfset var strData = structnew()>
<cfset arrstatus = ArrayNew(1)>
<cfset arrLocked = ArrayNew(1)>

<cfset strData.Locked = arrLocked>
<cfset strData.status = arrstatus>
<cfset strData = serializeJSON(strData, "struct")>

<cfreturn strData>
</cffunction>
<cffunction name="DeleteRecords" output="false" access="remote" returnFormat="json">
	<cfargument name="unique_ID" required="true" default="" />

	<cfquery name="qCheckDD" DATASOURCE="#Application.Datasource#">
		SELECT DISTINCT Deduction_ID
		FROM ADV_Quick_Pay_Billback_Log
		WHERE User_ID =  '#arguments.unique_ID#'
		AND Deleted = 0
	</cfquery>

	<cfif qCheckDD.RecordCount>
		<cfloop query="qCheckDD">
			<cfset Unlock = DDUnLock(0, Deduction_ID)>
		</cfloop>
	</cfif>

<cfquery name="qDeleteRecords" DATASOURCE="#Application.Datasource#">
	DELETE
	FROM ADV_Quick_Pay_Billback_Log
	WHERE User_ID =  '#arguments.unique_ID#'
</cfquery>

<cfset var strData = structnew()>
<cfset arrstatus = ArrayNew(1)>

<cfset arrstatus  ="Deduction Is Sucesfully Un-Locked.">
<cfset strData.status = arrstatus>
<cfset strData = serializeJSON(strData, "struct")>

<cfreturn strData>
</cffunction>

<cffunction name="ProgramStatus" output="false" access="remote" returnFormat="json">
	<cfargument name="Contract_Main_ID" required="true" default="" />
	<cfargument name="LockType" required="true" default="1" />

		<cfquery name="qUpdatePRGStatus" DATASOURCE="#Application.Datasource#">
		<cfif arguments.LockType>
			UPDATE Contract_Main
			SET Prg_Locked_By_Quick_Pay = #arguments.LockType#
						,Contract_Is_Locked = #arguments.LockType#
						,Contract_Locked_By_User_ID='#request.AccessStructure.User_ID#'
						,Contract_Lock_Date = getdate()
			WHERE Contract_Main_ID = #arguments.Contract_Main_ID#
		<cfelse>
			UPDATE Contract_Main
			SET Prg_Locked_By_Quick_Pay = #arguments.LockType#
						,Contract_Is_Locked = #arguments.LockType#
						,Contract_Locked_By_User_ID=''
						,Contract_Lock_Date =''
			WHERE Contract_Main_ID = #arguments.Contract_Main_ID#
		</cfif>
		</cfquery>
		<cfif arguments.LockType>
			<cfset status = 'Program Locked by Quick Pay'>
		<cfelse>
			<cfset status = 'Program Unlocked from Quick Pay'>
		</cfif>
		<cfreturn status>
</cffunction>

<cffunction name="getTaxTypes" returntype="query" access="remote">
	<cfargument name="Deduction_ID" required="true" default="00000000-0000-0000-0000-000000000000" />
	<cfquery name="qGetTaxTypes" datasource="#application.datasource#">
		SELECT BB_Tax_Main_ID, Description+'( '+Tax_Allowance_Code+' ) ' AS TaxType, Tax_Allowance_Code, ISNULL(D.DD_PricingCode, 0) AS DD_PricingCode
		FROM BB_Tax_Main
		LEFT JOIN Deductions D
		ON D.Deduction_ID = '#arguments.Deduction_ID#'
		WHERE BB_Tax_Main.Deleted = 0
		Order by	Description
	</cfquery>
	<cfreturn qGetTaxTypes>
</cffunction>

</cfcomponent>