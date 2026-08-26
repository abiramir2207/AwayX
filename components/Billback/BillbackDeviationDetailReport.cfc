<cfcomponent displayname="BillbackDeviationDetailReport" hint="Billback Deviation Detail Report" extends="components.Base">

	<cffunction name="init" returntype="components.billback.BillbackDeviationDetailReport" output="false">
		<cfreturn this />
	</cffunction>

	<cffunction name="getDeviationDetailReport" returntype="query" output="false">
		<cfargument name="billbackIDList" type="string" required="false" default="">
		<cfargument name="applied" type="numeric" required="false" default="0">


		<cfquery name="qDeviationDetailReport" datasource="#application.datasource#">
			IF EXISTS (SELECT NAME FROM TEMPDB..SYSOBJECTS WHERE NAME = '##tmp_bbid')
				drop table ##tmp_bbid
		</cfquery>

		<cftry>

		<cfquery name="qDeviationDetailReport" datasource="#application.datasource#">
			IF EXISTS (SELECT NAME FROM TEMPDB..SYSOBJECTS WHERE NAME = '##tmp_bbid')
				drop table ##tmp_bbid

			create table ##tmp_bbid (billback_id uniqueidentifier)

			<cfif arguments.applied eq 0>
				<cfloop list="#arguments.billbackIDList#" index="bbid">
					insert into ##tmp_bbid (billback_id) values ('#bbid#')
				</cfloop>
			<cfelse>
				INSERT INTO ##tmp_bbid
						(billback_id)
				SELECT	Billback_Id
				FROM 	BB_Adjustment BA
				WHERE	BA.Adjustment_Deducted_From_BB_ID = '#arguments.billbackIDList#'  AND
						Deleted = 0
			</cfif>
			EXEC BB_DEVIATION_DETAIL_REPORT

			drop table ##tmp_bbid
		</cfquery>

		<cfcatch>
			<cfquery name="qDeviationDetailReport" datasource="#application.datasource#">
				IF EXISTS (SELECT NAME FROM TEMPDB..SYSOBJECTS WHERE NAME = '##tmp_bbid')
					drop table ##tmp_bbid
			</cfquery>
			<cfrethrow>
		</cfcatch>

		</cftry>

		<!---
		<cfquery name="qDeviationDetailReport" datasource="#application.datasource#">
			select	top 0 *
			into	##BB_DEVIATION_DETAIL_REPORT_DATA
			from	BB_DEVIATION_DETAIL_REPORT_DATA

			<cfloop list="#arguments.billbackIDList#" index="bbid">
				INSERT INTO ##BB_DEVIATION_DETAIL_REPORT_DATA
				EXEC BB_DEVIATION_DETAIL_REPORT_SINGLE '#bbid#'
			</cfloop>

			select	*
			from	##BB_DEVIATION_DETAIL_REPORT_DATA
			order by Billback_ID, Program_ID, Item

			drop table ##BB_DEVIATION_DETAIL_REPORT_DATA
		</cfquery>
		--->

		<!---
		<cfstoredproc datasource="#application.datasource#" procedure="BB_DEVIATION_DETAIL_REPORT">
			<cfprocparam cfsqltype="CF_SQL_LONGVARCHAR" value="#arguments.billbackID#">
			<cfprocresult name="qDeviationDetailReport">
		</cfstoredproc>
		>
		--->

		<cfreturn qDeviationDetailReport />

	</cffunction>

	<!--- Summary statement header (billback information) --->
	<cffunction name="GetSummaryStatementHeader" returntype="query" output="false">
		<cfargument name="Billback_ID" required="true">

		<cfset var qGetSummaryStatementHeader = "">

		<cfquery name="qGetSummaryStatementHeader" datasource="#application.datasource#">
			SELECT 	Billback.BB_Code,
					Billback.BB_Reference,
					Billback.BB_Start_Date,
					Billback.BB_End_Date,
					Billback.Billback_Payee_Type_ID,
					BB_Approved.Check_Number,
					BB_Approved.Check_Date,
					BB_Approved.Check_Amount
			FROM	Billback
				LEFT JOIN 	BB_Approved
				ON			BB_Approved.Billback_ID = Billback.Billback_ID
			WHERE	Billback.Billback_ID = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfreturn qGetSummaryStatementHeader />

	</cffunction>

	<!--- Summary statement payee info  --->
	<cffunction name="GetSummaryStatementPayeeInfo" returntype="query" output="false">
		<cfargument name="Billback_ID" required="true">
		<cfargument name="Billback_Payee_Type_ID" required="true">

		<cfset var qGetSummaryStatementPayeeInfo = "">

		<cfif arguments.Billback_Payee_Type_ID EQ 1>
			<!--- Distributor contact info --->
			<cfquery name="qGetSummaryStatementPayeeInfo" datasource="#application.datasource#">
				SELECT 	BSA_Foodservice_Customers.Name AS Payee_Name,
						BSA_Foodservice_Customers.Ship_To AS Payee_Number,
						BSA_Foodservice_Customers.Address_1 AS Address1,
						BSA_Foodservice_Customers.Address_2 AS Address2,
						BSA_Foodservice_Customers.City AS City,
						BSA_Foodservice_Customers.State AS State,
						BSA_Foodservice_Customers.ZipCode AS PostalCode
				FROM	Billback_Distributor
					INNER JOIN 	BSA_Foodservice_Customers
					ON			Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
				WHERE	Billback_Distributor.Billback_ID = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="cf_sql_varchar">
				AND Billback_Distributor.Deleted = 0
			</cfquery>
		<cfelseif arguments.Billback_Payee_Type_ID EQ 2>
			<!--- Operator contact info --->
			<cfquery name="qGetSummaryStatementPayeeInfo" datasource="#application.datasource#">
				DECLARE
				@Use_Operator_Legacy_ID	BIT
				SELECT @Use_Operator_Legacy_ID = ISNULL(Operator_Legacy_ID_On, 0) FROM CUSTOMER_SETTINGS

				SELECT 	BSA_Operator.Operator_Name AS Payee_Name,
						CASE WHEN @Use_Operator_Legacy_ID = 1 THEN BSA_Operator.Legacy_ID ELSE BSA_Operator.BSA_Operator_ID END AS Payee_Number,
						BSA_Operator.Operator_Address AS Address1,
						BSA_Operator.Operator_Address2 AS Address2,
						BSA_Operator.Operator_City AS City,
						BSA_Operator.Operator_State AS State,
						BSA_Operator.Operator_Zip AS PostalCode
				FROM	Billback_Operator
					INNER JOIN 	BSA_Operator
					ON			Billback_Operator.Operator_ID = BSA_Operator.BSA_Operator_ID
				WHERE	Billback_Operator.Billback_ID = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="cf_sql_varchar">
				AND Billback_Operator.Deleted = 0
			</cfquery>
		<cfelse>
			<!--- We shouldn't need this for the first pass--->
		<!--- 	<!--- Broker contact info --->
			<cfquery name="qGetSummaryStatementPayeeInfo" datasource="#application.datasource#">
				SELECT 	Billback_Broker.Operator_Name AS Payee_Name,
						Billback_Broker.BSA_Operator_ID AS Payee_Number,
						Billback_Broker.Operator_Address AS Address1,
						Billback_Broker.Operator_Address2 AS Address2,
						Billback_Broker.Operator_City AS City,
						Billback_Broker.Operator_State AS State,
						Billback_Broker.Operator_Zip AS PostalCode
				FROM	Billback_Broker
					INNER JOIN 	Billback_Broker
					ON			Billback_Broker.BSA_Operator_ID = Billback_Operator.BSA_Foodservice_Customer_ID
				WHERE	Billback_Operator.Billback_ID = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="cf_sql_varchar">
			</cfquery> --->
		</cfif>

		<cfreturn qGetSummaryStatementPayeeInfo />

	</cffunction>

		<!--- The client wants Payment Amount 0 seperate from paid values -- this query just gets paid values --->
	<cffunction name="GetSummaryStatementDetailNot0" returntype="query" output="false">
		<cfargument name="Billback_ID" required="true">

		<cfset var qGetSummaryStatementDetailNot0 = "">

		<cfquery name="qGetSummaryStatementDetailNot0" datasource="#application.datasource#">
		SELECT	Billback_Program.Billback_Program_ID,
			Billback_Product.Billback_Product_ID,
			Contract_Main.Contract_Number,
			isnull(( select top 1 Operator_Name from BSA_Operator where BSA_Operator_ID in
					(select BSA_Operator_ID from contract_operators where contract_main_id in
					( select program_id from billback_program BP where BP.billback_program_id = billback_program.billback_program_id and deleted =0 ) AND
					contract_operators.deleted = 0) AND BSA_Operator.Deleted = 0),'') as Operator_Name,
			isnull(( select top 1 COALESCE(BSA_Operator.Legacy_ID, cast(BSA_Operator.BSA_Operator_ID as
				char(50))) from BSA_Operator where BSA_Operator_ID in (select BSA_Operator_ID
				from contract_operators where contract_main_id in ( select program_id
				from billback_program BP where BP.billback_program_id = billback_program.billback_program_id
				and deleted =0 ) AND contract_operators.deleted = 0) AND BSA_Operator.Deleted = 0),'') as Operator_Number,
			BSA_Foodservice_Items_Master.Item,
			Billback_Product.Invalid_Product,
			BB_Item_Invoice_Level.Invoice_Price_CS AS Claim_Invoice_Price,
			CASE BB_Item_Invoice_Level.Selected_Invoice_Price_Type
            WHEN 1 THEN BB_Item_Invoice_Level.Invoice_Price_CS
            WHEN 2 THEN BB_Item_Invoice_Level.Expected_Invoice_Price_CS
            WHEN 3 THEN BB_Item_Invoice_Level.Manual_Invoice_Price_CS
            END as Approved_Invoice_Price,
			BB_Item_Invoice_Level.Program_Price_CS AS Claim_Contract_Price,
            CASE BB_Item_Invoice_Level.Selected_Program_Price_Type
            WHEN 1 THEN BB_Item_Invoice_Level.Program_Price_CS
            WHEN 2 THEN BB_Item_Invoice_Level.Expected_Program_Price_CS
            END as Approved_Contract_Price,
			isnull(BB_Item_Invoice_Level.Claimed_CS, 0) AS Claim_CS,
			isnull(BB_Item_Invoice_Level.Selected_Vol_CS, 0) AS Approved_CS,
			isnull(BB_Item_Invoice_Level.Claimed_Rate_CS, 0) AS Claim_Rate,
			isnull(BB_Item_Invoice_Level.Selected_Rate_CS, 0) AS Approved_Rate,
			isnull(BB_Item_Invoice_Level.Claimed_Amt, 0) AS Claim_Amount,
			isnull(BB_Item_Invoice_Level.Final_Payment, 0) AS Approved_Amount,
			BB_Item_Invoice_Level.Final_Payment,
			cast(isnull(BB_Item_Invoice_Level.Claimed_Amt, 0) as float) - cast(isnull(BB_Item_Invoice_Level.Final_Payment, 0) as float) AS Variation,
			CASE WHEN (BB_Program_Deviation_Info.Unauthorized_Payee > 0)					 
				THEN 1 ELSE 0 END AS DEVIATION_UNAUTHORIZED_PAYEE 
			    , CASE WHEN (BB_Product_Deviation_Info.Unauthorized_Product > 0 OR BB_Product_Deviation_Info.Unknown_Product > 0)					 
				THEN 1 ELSE 0 END AS DEVIATION_UNAUTHORIZED_PRODUCT
			    , CASE WHEN BB_Program_Deviation_Info.Dates_Not_Match > 0 
				THEN 1 ELSE 0 END AS DEVIATION_PROGRAM_DATES
	   		    , CASE WHEN BB_Overlap_Deviation_Info.Overlap > 0
				THEN 1 ELSE 0 END AS DEVIATION_BILLBACK_OVERLAP
		FROM Billback
		INNER JOIN Billback_Program
		ON Billback_Program.Billback_ID = Billback.Billback_ID
		AND Billback_Program.Deleted = 0
		LEFT JOIN Contract_Main
		ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
		INNER JOIN Billback_Product
		ON Billback.Billback_ID = Billback_Product.Billback_ID
		AND Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID
		AND Billback_Product.Deleted = 0
		LEFT JOIN BSA_Foodservice_Items_Master
		ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID
		INNER JOIN BB_Item_Invoice_Level
		ON BB_Item_Invoice_Level.Billback_Product_ID = Billback_Product.Billback_Product_ID
		LEFT JOIN BB_Overlap_Deviation_Info ON
			Billback_Product.Billback_ID = BB_Overlap_Deviation_Info.Billback_ID 
			AND Billback_Product.BillBack_Product_Id = BB_Overlap_Deviation_Info.BillBack_Product_Id 
		LEFT JOIN BB_Program_Deviation_Info ON 
			Billback_Program.Billback_Program_ID = BB_Program_Deviation_Info.Billback_Program_ID 
			AND BB_Program_Deviation_Info.Deleted = 0 
		LEFT JOIN BB_Product_Deviation_Info ON 
			Billback_Product.Billback_Product_ID = BB_Product_Deviation_Info.Billback_Product_ID
			AND BB_Product_Deviation_Info.Deleted = 0
		WHERE	Billback.Deleted = 0
		AND		isnull(BB_Item_Invoice_Level.Final_Payment, 0) != 0
		AND		Billback.Billback_ID = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="cf_sql_varchar">
		ORDER BY	Operator_Name,
					Contract_Main.Contract_Number,
					BSA_Foodservice_Items_Master.Item
		</cfquery>

		<cfreturn qGetSummaryStatementDetailNot0 />

	</cffunction>

	<!--- The client wants Payment Amount 0 seperate from paid values -- this query just gets rejected values --->
	<cffunction name="GetSummaryStatementDetail0" returntype="query" output="false">
		<cfargument name="Billback_ID" required="true">

		<cfset var qGetSummaryStatementDetail0 = "">

		<cfquery name="qGetSummaryStatementDetail0" datasource="#application.datasource#">
		SELECT	Billback_Program.Billback_Program_ID,
			Billback_Product.Billback_Product_ID,
			Contract_Main.Contract_Number,
			isnull(( select top 1 Operator_Name from BSA_Operator where BSA_Operator_ID in
					(select BSA_Operator_ID from contract_operators where contract_main_id in
					( select program_id from billback_program BP where BP.billback_program_id = billback_program.billback_program_id and deleted =0 ) AND
					contract_operators.deleted = 0) AND BSA_Operator.Deleted = 0),'') as Operator_Name,
			isnull(( select top 1 COALESCE(BSA_Operator.Legacy_ID, cast(BSA_Operator.BSA_Operator_ID as
				char(50))) from BSA_Operator where BSA_Operator_ID in (select BSA_Operator_ID
				from contract_operators where contract_main_id in ( select program_id
				from billback_program BP where BP.billback_program_id = billback_program.billback_program_id
				and deleted =0 ) AND contract_operators.deleted = 0) AND BSA_Operator.Deleted = 0),'') as Operator_Number,
			BSA_Foodservice_Items_Master.Item,
			Billback_Product.Invalid_Product,
			BB_Item_Invoice_Level.Invoice_Price_CS AS Claim_Invoice_Price,
			CASE BB_Item_Invoice_Level.Selected_Invoice_Price_Type
            WHEN 1 THEN BB_Item_Invoice_Level.Invoice_Price_CS
            WHEN 2 THEN BB_Item_Invoice_Level.Expected_Invoice_Price_CS
            WHEN 3 THEN BB_Item_Invoice_Level.Manual_Invoice_Price_CS
            END as Approved_Invoice_Price,
			BB_Item_Invoice_Level.Program_Price_CS  AS Claim_Contract_Price,
            CASE BB_Item_Invoice_Level.Selected_Program_Price_Type
            WHEN 1 THEN BB_Item_Invoice_Level.Program_Price_CS
            WHEN 2 THEN BB_Item_Invoice_Level.Expected_Program_Price_CS
            END as Approved_Contract_Price,
			isnull(BB_Item_Invoice_Level.Claimed_CS, 0) AS Claim_CS,
			isnull(BB_Item_Invoice_Level.Selected_Vol_CS, 0) AS Approved_CS,
			isnull(BB_Item_Invoice_Level.Claimed_Rate_CS, 0) AS Claim_Rate,
			isnull(BB_Item_Invoice_Level.Selected_Rate_CS, 0) AS Approved_Rate,
			isnull(BB_Item_Invoice_Level.Claimed_Amt, 0) AS Claim_Amount,
			isnull(BB_Item_Invoice_Level.Final_Payment, 0) AS Approved_Amount,
			BB_Item_Invoice_Level.Final_Payment,
			cast(isnull(BB_Item_Invoice_Level.Claimed_Amt, 0) as float) - cast(isnull(BB_Item_Invoice_Level.Final_Payment, 0) as float) AS Variation,
			CASE WHEN (BB_Program_Deviation_Info.Unauthorized_Payee > 0)					 
			THEN 1 ELSE 0 END														         AS DEVIATION_UNAUTHORIZED_PAYEE 
		    , CASE WHEN (BB_Product_Deviation_Info.Unauthorized_Product > 0 OR BB_Product_Deviation_Info.Unknown_Product > 0)					 
			THEN 1 ELSE 0 END														         AS DEVIATION_UNAUTHORIZED_PRODUCT
		    , CASE WHEN BB_Program_Deviation_Info.Dates_Not_Match > 0 
			THEN 1 ELSE 0 END														         AS DEVIATION_PROGRAM_DATES
   		    , CASE WHEN BB_Overlap_Deviation_Info.Overlap > 0
			THEN 1 ELSE 0 END														         AS DEVIATION_BILLBACK_OVERLAP			
		FROM Billback
		INNER JOIN Billback_Program
		ON Billback_Program.Billback_ID = Billback.Billback_ID
		AND Billback_Program.Deleted = 0
		LEFT JOIN Contract_Main
		ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
		INNER JOIN Billback_Product
		ON Billback.Billback_ID = Billback_Product.Billback_ID
		AND Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID
		AND Billback_Product.Deleted = 0
		LEFT JOIN BSA_Foodservice_Items_Master
		ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID
		INNER JOIN BB_Item_Invoice_Level
		ON BB_Item_Invoice_Level.Billback_Product_ID = Billback_Product.Billback_Product_ID
		LEFT JOIN BB_Overlap_Deviation_Info ON
			 Billback_Product.Billback_ID = BB_Overlap_Deviation_Info.Billback_ID 
			AND Billback_Product.BillBack_Product_Id = BB_Overlap_Deviation_Info.BillBack_Product_Id 
		 LEFT JOIN BB_Program_Deviation_Info ON 
			Billback_Program.Billback_Program_ID = BB_Program_Deviation_Info.Billback_Program_ID 
			AND BB_Program_Deviation_Info.Deleted = 0 
		 LEFT JOIN BB_Product_Deviation_Info ON 
			Billback_Product.Billback_Product_ID = BB_Product_Deviation_Info.Billback_Product_ID
			AND BB_Product_Deviation_Info.Deleted = 0
		WHERE	Billback.Deleted = 0
		AND		isnull(BB_Item_Invoice_Level.Final_Payment, 0) = 0
		AND		Billback.Billback_ID = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="cf_sql_varchar">
		ORDER BY	Operator_Name,
					Contract_Main.Contract_Number,
					BSA_Foodservice_Items_Master.Item
		</cfquery>

		<cfreturn qGetSummaryStatementDetail0 />

	</cffunction>

</cfcomponent>