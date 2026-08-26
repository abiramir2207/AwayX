<cfcomponent hint="Billback Deviation Manager" extends="components.Base">

	<cffunction name="init" output="false" returntype="components.billback.BillbackDeviationManager">

		<cfreturn this />

	</cffunction>

	<cffunction name="setAppSettings" output="false">

		<cfargument name="appSettings" type="components.settings.ApplicationSettings" required="true">

		<cfset this.appSettings = arguments.appSettings />

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get Fixed Price Delivery Type Information /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getInvoiceDetails" output="false" returntype="query">

		<cfargument name="distributorId" required="true" type="string">
		<cfargument name="productId" required="true" type="string">
		<cfargument name="date1" required="true" type="date">
		<cfargument name="date2" required="true" type="date">
		<cfargument name="billbackUOM" required="true" type="numeric">
		<cfargument name="invoiceDateField" required="true" type="string">
		<cfargument name="returnType" required="true" type="numeric" default="1">
		<cfargument name="ProductReplacementID" required="false" type="string" default="">
		<cfargument name="payeeTypeId" required="false" type="numeric" default="0">
		<cfargument name="BBproductId" required="false" type="string" default="">
		<cfargument name="FobPriceIndicator" required="false" type="string" default="Y,N">
		<cfargument name="InvoiceTypeFilter" required="false" type="string" default="">
		<cfargument name="InvoiceTypeExcludeList" required="false" type="string" default="">
		
		<cfparam name="arguments.programID" default="0" />

		<cfquery NAME="Get_BB_Tolerance_Settings" DATASOURCE="#application.datasource#">
			SELECT Auto_Deviation_Family_Level FROM Billback_Tolerance_Settings
		</cfquery>

		<!------ get data ----->
		<CFIF IsDate(arguments.date1) AND IsDate(arguments.date2)>
			<!------------------- Get invoice info for the sample size ----------------->
			<CFQUERY  dataSource="#application.datasource#" NAME="gGetInvoiceDetails">

				DECLARE @Billback_ID uniqueidentifier,
						@Planner_ID int,
						@Use_MSA_Data bit = 0
				
				SELECT	@Billback_ID = Billback_Product.Billback_ID,
						@Planner_ID = Contract_Main.Planner_ID
				FROM	Billback_Product
				INNER JOIN Billback_Program
				ON		Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID
				INNER JOIN Contract_Main
				ON		Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
				WHERE 	Billback_Product.Billback_Product_ID = '#arguments.BBproductId#'
				
				IF ISNULL(@Planner_ID, 0) != 0
				BEGIN
					SELECT	@Use_MSA_Data = CASE WHEN pt.Category = 'MSA' THEN 1 ELSE 0 END
					FROM	Planners p
					INNER JOIN Planner_Template pt
					ON		pt.Planner_Template_ID = p.Planner_Template_ID
					WHERE	p.Planner_ID = @Planner_ID
				END
					
				IF OBJECT_ID('tempdb..##tmp_program_operators') IS NOT NULL
				DROP TABLE ##tmp_program_operators
					   
				CREATE TABLE ##tmp_program_operators (BSA_Operator_ID int)
					   
				IF @Use_MSA_Data = 1
				BEGIN
					<!---
					For MSA programs:
					When payee is distributor, we will include MSA data for all operators in the program and associated distributor.
					When payee is operator, we will include MSA data for the payee and associated distributor
					--->
					<cfif arguments.payeeTypeId eq 2>
					INSERT INTO ##tmp_program_operators (BSA_Operator_ID)
					SELECT	Operator_ID
					FROM	Billback_Operator
					WHERE	Billback_Operator.Billback_ID = @Billback_ID
					AND		Billback_Operator.Deleted = 0
					
					<cfelse>
					INSERT INTO ##tmp_program_operators (BSA_Operator_ID)
					SELECT	Contract_Operators.BSA_Operator_ID
					FROM	Contract_Operators
					WHERE	Contract_Operators.Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.programId#" />
					AND		Contract_Operators.Deleted = 0
					</cfif>
				END
						
				IF OBJECT_ID('tempdb..##tempDistProd') IS NOT NULL
				DROP TABLE ##tempDistProd

				CREATE TABLE ##tempDistProd(      
				       Distributor_ID uniqueidentifier, 
				       Product_id uniqueidentifier,
				       Billback_Program_ID uniqueidentifier,
				       Billback_Product_ID uniqueidentifier, 
				       Family_ID uniqueidentifier
				)		

		      <cfif Get_BB_Tolerance_Settings.Auto_Deviation_Family_Level EQ 0 OR arguments.payeeTypeId NEQ 1>
			       BEGIN
			              Insert into ##tempDistProd (  Distributor_ID, Product_Id, Billback_Program_ID, Billback_Product_ID,Family_ID)
			              Select Distinct Distributor_ID, Product_Id, Billback_Program_ID, Billback_Product_ID, '00000000-0000-0000-0000-000000000000' as Family_ID    
			              from   Billback_Product
			              Where Billback_Product.Billback_Product_ID = '#arguments.BBproductId#'
			              and    deleted = 0
			       END
		       <cfelse>
			       BEGIN
			              <!--- family exists in settings to be considered for auto deviation --->
			              INSERT INTO ##tempDistProd (  Distributor_ID, Product_Id, Billback_Program_ID, Billback_Product_ID,Family_ID)

			              SELECT DISTINCT fam.BSA_Foodservice_Customers_ID as Distributor_ID,Product_Id, Billback_Program_ID, Billback_Product_ID ,BPC.Family_ID
			              FROM   Billback_Product
			              INNER JOIN  BSA_Foodservice_Customers BPC
			              ON            BPC.BSA_Foodservice_Customers_ID = Billback_Product.Distributor_ID 
			              INNER JOIN  BSA_Foodservice_Customers fam
			              ON            fam.Family_ID = BPC.Family_ID
			              AND           fam.Ship_To <> 'Group'
			              WHERE Billback_Product.Billback_Product_ID = '#arguments.BBproductId#'
			              AND    Billback_Product.deleted = 0
			              AND   EXISTS (SELECT  * FROM Auto_Match_Deviation_Family S WHERE BPC.Family_ID  = S.Family_ID AND S.Auto_Deviation_Family =1)
			              
			              <!--- family does not exists in settings for auto deviation--->
			              INSERT INTO ##tempDistProd (  Distributor_ID, Product_Id, Billback_Program_ID, Billback_Product_ID,Family_ID)

			              SELECT DISTINCT Distributor_ID, Product_Id, Billback_Program_ID, Billback_Product_ID, '00000000-0000-0000-0000-000000000000' as Family_ID    
			              FROM   Billback_Product
			              INNER JOIN  BSA_Foodservice_Customers BPC
			              ON            BPC.BSA_Foodservice_Customers_ID = Billback_Product.Distributor_ID 
			              WHERE Billback_Product.Billback_Product_ID = '#arguments.BBproductId#'
			              AND    Billback_Product.deleted = 0
			              AND    NOT EXISTS (SELECT * FROM Auto_Match_Deviation_Family S WHERE  BPC.Family_ID  = S.Family_ID AND S.Auto_Deviation_Family =1)
			       END
			</cfif>

				SELECT	<cfif arguments.returnType EQ 1>
							<CFIF arguments.billbackUOM EQ 1>
							<!------ return all details ----->
								Cases_Invoiced AS Volume_Invoiced,
								CS_Unit_Price  AS Unit_Price_PER_BB_UOM,
							<CFELSE>
								Pounds_Invoiced AS Volume_Invoiced,
								LB_Unit_Price   AS Unit_Price_PER_BB_UOM,
							</CFIF>
							#arguments.invoiceDateField# AS This_Date,
							Invoice_Header.Shared_Invoice_Number,
							Invoice_Detail.BSA_Foodservice_Items_Master_ID,
							Invoice_Detail.Base_Sales_Price_CS,
							Invoice_Detail.Base_Sales_Price_LB,
							Invoice_Header.IBF_Rate, Invoice_Header.OBF_Rate
						<cfelseif arguments.returnType EQ 2>
							<!------ return just the delivery types and the total volume ordered by each delivery type ----->
							DISTINCT LTRIM(RTRIM(ISNULL(FOB_PRICE_IND, 'N'))) As FOB_PRICE_IND, Sum(CAST(Pounds_Invoiced AS Float)) As TotalVolume
						<cfelseif arguments.returnType EQ 3>
							<!------ return the minimum price paid for non-bid (delivered) ----->
							ISNULL(Min(ISNULL(CAST(
								<CFIF arguments.billbackUOM EQ 1>
									CS_Unit_Price
								<CFELSE>
									LB_Unit_Price
								</CFIF> As Float), 0)
							), 0) As Min_Unit_price
						<cfelseif arguments.returnType EQ 4>
							<!------ have to find out which FOB price was most commonly used ----->
							<CFIF arguments.billbackUOM EQ 1>
							<!------ return all details ----->
								SUM(CAST(Cases_Invoiced AS Float)) AS Volume_Invoiced,
								CS_Unit_Price
							<CFELSE>
								SUM(CAST(Pounds_Invoiced AS Float)) AS Volume_Invoiced,
								LB_Unit_Price
							</CFIF> unitPrice
						</cfif>
				FROM	Invoice_Header
				INNER JOIN	Invoice_Detail
				ON 	Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
				AND	Invoice_Detail.BSA_Foodservice_Items_Master_ID IN ('#arguments.productId#'<cfif arguments.ProductReplacementID neq "">,'#arguments.ProductReplacementID#'</cfif>)
				AND	Invoice_Detail.Deleted = 0
			<cfif this.appSettings.getCheckOrderClass()>
				AND Invoice_Detail.Order_Class IN (#ListQualify(this.appSettings.getOrderClassValue(), "'", ",")#)
			</cfif>
				AND	ISNULL(Invoice_Detail.FOB_PRICE_IND, 'N') IN (#ListQualify(arguments.FobPriceIndicator, "'", ",")#)
				<!--- D21756 -- Commentting based on the discussion with Paul
				--- D22024 -- Uncommenting the Operator and commenting the Negative CS check -- We should do 21756 only in fixed rate--->
				<!--- 49429 - APF Enhancement: INCLUDE OI TRANSACTIONS IN BB VALIDATION/Anand Rao/15-Mar-16 --->
			<cfif this.appSettings.get_Setting('BB_Deviation_Include_Invoices_With_Operator_ID') neq '1'>
				AND (ISNULL(Invoice_Detail.BSA_Operator_ID, 0) = 0 OR @Use_MSA_Data = 1)
			</cfif>
				AND ISNULL(Cast(Invoice_Detail.Cases_Invoiced as float), 0) > 0

				WHERE	invoice_Header.Deleted = 0
				AND 	Invoice_Header.BSA_Foodservice_Customers_ID IN (select Distributor_ID from ##tempDistProd)			
				AND	DATEDIFF(d, #CreateODBCDate(arguments.date1)#, #arguments.invoiceDateField#) >= 0
				AND	DATEDIFF(d, #arguments.invoiceDateField#, #CreateODBCDate(arguments.date2)#) >= 0
			<cfif arguments.InvoiceTypeFilter neq "">
				AND Invoice_Header.Invoice_Type IN (#ListQualify(arguments.InvoiceTypeFilter, "'", ",")#)
			</cfif>
			<cfif arguments.InvoiceTypeExcludeList neq "">
				AND Invoice_Header.Invoice_Type NOT IN (#ListQualify(arguments.InvoiceTypeExcludeList, "'", ",")#)
			</cfif>
				AND ((@Use_MSA_Data = 1 AND Invoice_Header.BSA_Operator_ID IN (SELECT BSA_Operator_ID FROM ##tmp_program_operators)) 
					OR (@Use_MSA_Data = 0 AND ISNULL(Invoice_Header.BSA_Operator_ID, 0) = 0)) <!--- Do not include MSA data on non-MSA programs. For MSA programs only include MSA data --->
							
			<cfif arguments.returnType EQ 1><!------ return all details ----->
				ORDER BY Invoice_Header.Shared_Invoice_Number, Invoice_Header.Invoice_Date
			<cfelseif arguments.returnType EQ 2><!------ return just the delivery types and the total volume ordered by each delivery type ----->
				Group By LTRIM(RTRIM(ISNULL(FOB_PRICE_IND, 'N')))
			<cfelseif arguments.returnType EQ 3><!------ return the minimum price paid for non-bid (delivered) ----->
				AND LTRIM(RTRIM(ISNULL(FOB_PRICE_IND, 'N'))) = 'N'
			<!------ TODO: ----->
			<!------ add non-bid condition ----->
			<cfelseif arguments.returnType EQ 4><!------ have to find out which FOB price was most commonly used ----->
				AND LTRIM(RTRIM(ISNULL(FOB_PRICE_IND, 'N'))) = 'Y'
				Group By <CFIF arguments.billbackUOM EQ 1>CS_Unit_Price<CFELSE>LB_Unit_Price</CFIF>
			</cfif>

				IF OBJECT_ID('tempdb..##tempDistProd') IS NOT NULL
				DROP TABLE ##tempDistProd

			</CFQUERY>
		<CFELSE>
			<CFSET gGetInvoiceDetails = QueryNew("")>
		</CFIF>

		<cfreturn gGetInvoiceDetails />

	</cffunction>


	<cffunction name="getInvoiceDetailsWithFreight" output="false" returntype="query">

		<cfargument name="distributorId" required="true" type="string">
		<cfargument name="productId" required="true" type="string">
		<cfargument name="date1" required="true" type="date">
		<cfargument name="date2" required="true" type="date">
		<cfargument name="billbackUOM" required="true" type="numeric">
		<cfargument name="invoiceDateField" required="true" type="string">
		<cfargument name="deliveryType" required="true" type="numeric">
		<cfargument name="warehouseMasterId" required="true" type="numeric">
		<cfargument name="zipCode" required="true" type="string">
		<cfargument name="ProductReplacementID" required="false" type="string" default="">
		<cfargument name="useFreightCalcDelTypeFromInvoice" required="false" type="boolean" default="0">
		<cfargument name="payeeTypeId" required="false" type="numeric" default="0">
		<cfargument name="programId" required="false" type="numeric" default="0">
		<cfargument name="BBproductId" required="false" type="string" default="">
		<cfargument name="FobPriceIndicator" required="false" type="string" default="Y,N">
		<cfargument name="InvoiceTypeFilter" required="false" type="string" default="">
		<cfargument name="InvoiceTypeExcludeList" required="false" type="string" default="">
			
		 <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		 <cfset appSettings = genSettingsManager.get()>

		<cfquery NAME="Get_BB_Tolerance_Settings" DATASOURCE="#application.datasource#">
			SELECT Auto_Deviation_Family_Level FROM Billback_Tolerance_Settings
		</cfquery>

		<!------ get data ----->
		<CFIF IsDate(arguments.date1) AND IsDate(arguments.date2)>
			<!------------------- Get invoice info for the sample size ----------------->
			<CFQUERY  dataSource="#application.datasource#" NAME="gGetInvoiceDetails">

	
				IF OBJECT_ID('tempdb..##tempDistProd') IS NOT NULL
				DROP TABLE ##tempDistProd

				CREATE TABLE ##tempDistProd(      
				       Distributor_ID uniqueidentifier, 
				       Product_id uniqueidentifier,
				       Billback_Program_ID uniqueidentifier,
				       Billback_Product_ID uniqueidentifier, 
				       Family_ID uniqueidentifier
				)		

			      <cfif Get_BB_Tolerance_Settings.Auto_Deviation_Family_Level EQ 0 OR arguments.payeeTypeId NEQ 1>
				       BEGIN
				              Insert into ##tempDistProd (  Distributor_ID, Product_Id, Billback_Program_ID, Billback_Product_ID,Family_ID)
				              Select Distinct Distributor_ID, Product_Id, Billback_Program_ID, Billback_Product_ID, '00000000-0000-0000-0000-000000000000' as Family_ID    
				              from   Billback_Product
				              Where Billback_Product.Billback_Product_ID = '#arguments.BBproductId#'
				              and    deleted = 0
				       END
			       <cfelse>
				       BEGIN
				              <!--- family exists in settings to be considered for auto deviation --->
				              INSERT INTO ##tempDistProd (  Distributor_ID, Product_Id, Billback_Program_ID, Billback_Product_ID,Family_ID)

				              SELECT DISTINCT fam.BSA_Foodservice_Customers_ID as Distributor_ID,Product_Id, Billback_Program_ID, Billback_Product_ID ,BPC.Family_ID
				              FROM   Billback_Product
				              INNER JOIN  BSA_Foodservice_Customers BPC
				              ON            BPC.BSA_Foodservice_Customers_ID = Billback_Product.Distributor_ID 
				              INNER JOIN  BSA_Foodservice_Customers fam
				              ON            fam.Family_ID = BPC.Family_ID
				              AND           fam.Ship_To <> 'Group'
				              WHERE Billback_Product.Billback_Product_ID = '#arguments.BBproductId#'
				              AND    Billback_Product.deleted = 0
				              AND   EXISTS (SELECT  * FROM Auto_Match_Deviation_Family S WHERE BPC.Family_ID  = S.Family_ID AND S.Auto_Deviation_Family =1)
				              
				              <!--- family does not exists in settings for auto deviation--->
				              INSERT INTO ##tempDistProd (  Distributor_ID, Product_Id, Billback_Program_ID, Billback_Product_ID,Family_ID)

				              SELECT DISTINCT Distributor_ID, Product_Id, Billback_Program_ID, Billback_Product_ID, '00000000-0000-0000-0000-000000000000' as Family_ID    
				              FROM   Billback_Product
				              INNER JOIN  BSA_Foodservice_Customers BPC
				              ON            BPC.BSA_Foodservice_Customers_ID = Billback_Product.Distributor_ID 
				              WHERE Billback_Product.Billback_Product_ID = '#arguments.BBproductId#'
				              AND    Billback_Product.deleted = 0
				              AND    NOT EXISTS (SELECT * FROM Auto_Match_Deviation_Family S WHERE  BPC.Family_ID  = S.Family_ID AND S.Auto_Deviation_Family =1)
				       END
				</cfif>


				<cfif arguments.payeeTypeId eq 2>
					<!--- When payee is operator, include records with FOB PRICE IND=X if the Operator ID on the invoice is present on the program --->
					IF OBJECT_ID('tempdb..##tmp_program_operators') IS NOT NULL
					DROP TABLE ##tmp_program_operators

					SELECT	Contract_Operators.BSA_Operator_ID
					INTO	##tmp_program_operators
					FROM	Contract_Operators
					WHERE	Contract_Operators.Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.programId#" />
					AND		Contract_Operators.Deleted = 0
				</cfif>

				SELECT		<CFIF arguments.billbackUOM EQ 1>
							<!------ return all details ----->
								Cases_Invoiced AS Volume_Invoiced,
								CS_Unit_Price  AS Unit_Price_PER_BB_UOM,
							<CFELSE>
								Pounds_Invoiced AS Volume_Invoiced,
								LB_Unit_Price   AS Unit_Price_PER_BB_UOM,
							</CFIF>
							#arguments.invoiceDateField# AS This_Date,
							Invoice_Header.Shared_Invoice_Number,
							Invoice_Detail.BSA_Foodservice_Items_Master_ID,
							Invoice_Detail.Base_Sales_Price_CS,
							Invoice_Detail.Base_Sales_Price_LB,
							Invoice_Header.IBF_Rate as IH_IBF_Rate,
							Invoice_Header.OBF_Rate as IH_OBF_Rate,
							LTRIM(RTRIM(ISNULL(Invoice_Detail.FOB_PRICE_IND, 'N'))) as FOB_PRICE_IND
				INTO	##tmp_invoice_detail
				FROM	Invoice_Header
				INNER JOIN	Invoice_Detail
				ON 	Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
				AND	Invoice_Detail.BSA_Foodservice_Items_Master_ID IN ('#arguments.productId#'<cfif arguments.ProductReplacementID neq "">,'#arguments.ProductReplacementID#'</cfif>)
				AND	Invoice_Detail.Deleted = 0
			<cfif this.appSettings.getCheckOrderClass()>
				AND Invoice_Detail.Order_Class IN (#ListQualify(this.appSettings.getOrderClassValue(), "'", ",")#)
			</cfif>
				AND	ISNULL(Invoice_Detail.FOB_PRICE_IND, 'N') IN (#ListQualify(arguments.FobPriceIndicator, "'", ",")#)
			<!--- Include records with FOB PRICE IND=X if the Operator ID on the invoice is present on the program --->
			<!--- 49429 - APF Enhancement: INCLUDE OI TRANSACTIONS IN BB VALIDATION/Anand Rao/15-Mar-16 --->
			<cfif appSettings.get_Setting('BB_Deviation_Include_Invoices_With_Operator_ID') neq '1'>
				AND	((ISNULL(Invoice_Detail.FOB_PRICE_IND, 'N') NOT IN ('X')
					AND ISNULL(Invoice_Detail.BSA_Operator_ID, 0) = 0)
					<cfif arguments.payeeTypeId eq 2>
					OR	Invoice_Detail.BSA_Operator_ID IN (SELECT BSA_Operator_ID FROM ##tmp_program_operators)
					</cfif>
					)
			</cfif>
			<!--- D21756 -- Commentting based on the discussion with Paul --->
			<!--- D22024 -- Uncommenting the Operator and commenting the Negative CS check -- We should do 21756 only in fixed rate --->
				AND ISNULL(Cast(Invoice_Detail.Cases_Invoiced as float), 0) > 0
				WHERE	Invoice_Header.BSA_Foodservice_Customers_ID IN (select Distributor_ID from ##tempDistProd)	
				AND	DATEDIFF(d, #CreateODBCDate(arguments.date1)#, #arguments.invoiceDateField#) >= 0
				AND	DATEDIFF(d, #arguments.invoiceDateField#, #CreateODBCDate(arguments.date2)#) >= 0
				AND	Invoice_Header.Deleted = 0
			<cfif arguments.InvoiceTypeFilter neq "">
				AND Invoice_Header.Invoice_Type IN (#ListQualify(arguments.InvoiceTypeFilter, "'", ",")#)
			</cfif>
			<cfif arguments.InvoiceTypeExcludeList neq "">
				AND Invoice_Header.Invoice_Type NOT IN (#ListQualify(arguments.InvoiceTypeExcludeList, "'", ",")#)
			</cfif>
						
						
						
				<cfif arguments.useFreightCalcDelTypeFromInvoice>
					select	##tmp_invoice_detail.*, IH_IBF_Rate as ibf_rate, IH_OBF_Rate as obf_rate
					from	##tmp_invoice_detail
					order by This_Date
				<cfelse>
					-- get the ibf rate for warehouse from the argument
					select	##tmp_invoice_detail.*, inbound_freight_rate.ibf_rate
					into	##tmp_invoice_detail_ibf
					from	##tmp_invoice_detail
					left join inbound_freight_rate
					on	inbound_freight_rate.deleted = 0
					and	inbound_freight_rate.Warehouse_Master_ID = <cfqueryparam value="#arguments.warehouseMasterId#" cfsqltype="cf_sql_integer">
					and	This_Date between inbound_freight_rate.start_date and inbound_freight_rate.end_date

					<cfif deliveryType eq 1>
					-- get the obf rate for warehouse, zip code from the argument
					DECLARE @Default_Freight_Bracket_Setting_ID int

					select	@Default_Freight_Bracket_Setting_ID = Max(Freight_Bracket_Setting_ID)
					from	Freight_Lookup_Bracket_Settings

					select	##tmp_invoice_detail_ibf.*, outbound_freight_rate.obf_rate
					from	##tmp_invoice_detail_ibf
					left join outbound_freight_rate
					on	outbound_freight_rate.deleted = 0
					and	outbound_freight_rate.freight_bracket_setting_id = @Default_Freight_Bracket_Setting_ID
					and	outbound_freight_rate.Warehouse_Master_ID = <cfqueryparam value="#arguments.warehouseMasterId#" cfsqltype="cf_sql_integer">
					and	This_Date between outbound_freight_rate.start_date and outbound_freight_rate.end_date
					AND	cast(#Val(Left(arguments.zipCode, 3))# as int) between cast(Outbound_Freight_Rate.Zip_Start as int) AND cast(Outbound_Freight_Rate.Zip_End as int)
					ORDER BY This_Date
					<cfelse>
					select	##tmp_invoice_detail_ibf.*, 0 as obf_rate
					from	##tmp_invoice_detail_ibf
					order by This_Date
					</cfif>

					drop table ##tmp_invoice_detail_ibf
				</cfif>

				drop table ##tmp_invoice_detail

				IF OBJECT_ID('tempdb..##tmp_program_operators') IS NOT NULL
				DROP TABLE ##tmp_program_operators
				
				IF OBJECT_ID('tempdb..##tempDistProd') IS NOT NULL
				DROP TABLE ##tempDistProd

			</CFQUERY>
		<CFELSE>
			<CFSET gGetInvoiceDetails = QueryNew("")>
		</CFIF>

		<cfreturn gGetInvoiceDetails />

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get Special Price  /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getSpecialPrice" output="false" returntype="query">

		<cfargument name="distributorId" required="true" type="string">
		<cfargument name="productId" required="true" type="string">
		<cfargument name="priceStartDate" required="true" type="date">
		<cfargument name="priceEndDate" required="true" type="date">
		<cfargument name="billbackUOM" required="true" type="numeric">
		<cfargument name="deliveryType" required="true" type="numeric" default="1">

		<cfset delType = "Y" />
		<cfif arguments.deliveryType EQ 1><!------ delivered ----->
			<cfset delType = "N" />
		</cfif>

		<cfquery name="qGetSpecialPrice" datasource="#application.datasource#">
			SELECT DBO.UDF_GET_SPECIAL_PRICE ('#arguments.productId#', '#arguments.distributorId#', #CreateodbcDate(arguments.priceStartDate)#, #CreateodbcDate(arguments.priceEndDate)#, #arguments.billbackUOM#, '#delType#') as Product_Price
		</cfquery>

		<cfreturn qGetSpecialPrice>

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get Truck Load Regular Price  /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getRegularTruckLoadPrice" output="false" returntype="query">

		<cfargument name="distributorId" required="true" type="string">
		<cfargument name="productId" required="true" type="string">
		<cfargument name="priceStartDate" required="true" type="date">
		<cfargument name="priceEndDate" required="true" type="date">
		<cfargument name="billbackUOM" required="true" type="numeric">
		<cfargument name="deliveryType" required="true" type="numeric" default="1">
		<cfargument name="useDates" required="false" type="numeric" default="1">

		<cfquery name="qGetRegularPrice" datasource="#application.datasource#">
			SELECT
					ISNULL(MIN(<cfif arguments.deliveryType EQ 1><!------ delivered ----->
					<cfif arguments.billbackUOM EQ 1>
					Price_List_Detail.CS_Bracket_1
					<cfelse>
					Price_List_Detail.LB_Bracket_1
					</cfif>
					<cfelse> <!------ FOB ----->
					<cfif arguments.billbackUOM EQ 1>
					Price_List_Detail.CS_FOB_Price
					<cfelse>
					Price_List_Detail.LB_FOB_Price
					</cfif>
					</cfif>), 0) Product_Price
			FROM	Price_List_Header
					INNER JOIN BSA_Foodservice_Customers
					ON
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = '#arguments.distributorId#'
					AND BSA_Foodservice_Customers.Price_List_Header_ID = Price_List_Header.Price_List_Header_ID
					INNER JOIN Price_List_Detail
					ON
					Price_List_Header.Price_List_Header_ID = Price_List_Detail.Price_List_Header_ID
					AND Price_List_Detail.Deleted = 0
					AND Price_List_Detail.Product_ID = '#arguments.productId#'
					AND	ISNULL(Price_List_Detail.FOB_Indicator, 'N') = <cfif arguments.deliveryType EQ 1>'N'<cfelse>'Y'</cfif>
			WHERE	Price_List_Header.Deleted = 0
			<cfif useDates eq 1>
			AND 	(#CreateodbcDate(arguments.priceStartDate)# between Price_List_Detail.Start_Date and Price_List_Detail.End_Date
					OR Price_List_Detail.Start_Date between #CreateodbcDate(arguments.priceStartDate)# and #CreateodbcDate(arguments.priceEndDate)#)
			</cfif>
		</cfquery>

		<cfreturn qGetRegularPrice>

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get Program Fixed Price  /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getAvgProgramFixedPrice" output="false" returntype="query">

		<cfargument name="programId" required="true" type="numeric">
		<cfargument name="productId" required="true" type="string">
		<cfargument name="billbackUOM" required="true" type="numeric">
		<cfargument name="deliveryType" required="true" type="numeric">
		<cfargument name="fixedComponentsOn" required="true" type="numeric">
		<cfargument name="payTo" required="false" type="numeric" default="0">
		<cfargument name="distributorId" required="false" type="string" default="">
		<cfargument name="programDelType" required="false" type="numeric" default="0">
		<cfargument name="checkProductWonStatus" required="false" type="numeric" default="0">
		<cfargument name="useFreightCalcDelTypeFromInvoice" required="false" type="boolean" default="0">
		<cfargument name="bFreightVersionItem" required="false" type="Boolean" default="0" />
		<cfargument name="Billback_ID" required="false" type="any" default="" />

		<cfif deliveryType NEQ 1 >
			<cfset arguments.bFreightVersionItem = 0 />
		</cfif>
		<cfquery name="qGetAvgProgramFixedPrice" datasource="#application.datasource#">
			--Get Program_Distributor_Freight Data
			IF OBJECT_ID('tempdb..##tmp_Program_Distributor_Freight') IS NOT NULL
			DROP TABLE ##tmp_Program_Distributor_Freight

			SELECT Program_ID,
					Distributor_ID,
					Warehouse_Master_ID,
					Freight_Bracket_Setting_ID,
					IBF_Rate,
					OBF_Rate,
					Deleted
			INTO ##tmp_Program_Distributor_Freight
			FROM Program_Distributor_Freight PDF
			WHERE PDF.deleted = 0 AND
				  PDF.program_id = #arguments.programId# AND
				  PDF.distributor_id = '#arguments.distributorId#'

			IF((SELECT COUNT(*) FROM ##tmp_Program_Distributor_Freight) = 0)
			BEGIN
				INSERT INTO ##tmp_Program_Distributor_Freight (
					Program_ID,
					Distributor_ID,
					Warehouse_Master_ID,
					Freight_Bracket_Setting_ID,
					IBF_Rate,
					OBF_Rate,
					Deleted
					)
				SELECT  top 1 Program_ID,
					Distributor_ID,
					Warehouse_Master_ID,
					Freight_Bracket_Setting_ID,
					IBF_Rate,
					OBF_Rate,
					Deleted
				FROM Program_Distributor_Freight PDF
				WHERE PDF.deleted = 0 AND
					  PDF.distributor_id = '#arguments.distributorId#' AND
					  PDF.program_id IN (SELECT
							CM2.Contract_Main_Id
							FROM Contract_Main CM
							INNER JOIN Contract_Main CM2 ON
							CM.Contract_Number = CM2.Contract_Number
							WHERE CM.Contract_Main_ID =  #arguments.programId#
							AND CM.Approved = 1 AND CM2.Approved = 1
					  )
				ORDER BY PDF.program_id desc
			END

			SELECT	<!----************ AvgProgramPrice - Start ********* ---->
					Avg(
					(CAST(PFPPD.Fixed_Price_Value AS Float)
					<cfif arguments.billbackUOM EQ 1><!------ billback is case ----->
						* (CASE PFPPD.Unit_Of_Measure_ID
						WHEN 1 THEN 1
						ELSE CAST(IM.Net_Weight As Float)
						END)
					<cfelse><!------ billback is pound ----->
						/ (CASE PFPPD.Unit_Of_Measure_ID
						WHEN 1 THEN CAST(IM.Net_Weight As Float)
						ELSE 1
						END)
					</cfif>)
					<cfif NOT arguments.bFreightVersionItem>
					<!------ Freight ----->
					- (	ISNULL(PFFR.Freight_Rate,0)
						<cfif arguments.billbackUOM EQ 1><!------ billback is case ----->
							* (CASE PFFR.Freight_UOM
							WHEN 1 THEN 1
							ELSE CAST(IM.Net_Weight As Float)
							END)
						<cfelse><!------ billback is pound ----->
							/ (CASE PFFR.Freight_UOM
							WHEN 1 THEN CAST(IM.Net_Weight As Float)
							ELSE 1
							END)
						</cfif>
					)
					</cfif>
					<cfif (arguments.programDelType eq 1 or arguments.programDelType eq 4) and not arguments.useFreightCalcDelTypeFromInvoice> <!--- programDelType: 1=DEL, 4=FOB DC ----->
						+ <!------ IBF ----->
						((ISNULL(PDF.IBF_Rate, 0) / 100.00)  * IM.Gross_Weight
						<cfif arguments.billbackUOM NEQ 1><!------ billback is pound ----->
							 / IM.Net_Weight
						</cfif>)
					</cfif>
					<cfif arguments.programDelType eq 1 and not arguments.useFreightCalcDelTypeFromInvoice> <!--- programDelType: 1=DEL, 4=FOB DC ----->
						+ <!------ OBF ----->
						((ISNULL(ISNULL(PDF.OBF_Rate,0), 0) / 100.00) * IM.Gross_Weight
						<cfif arguments.billbackUOM NEQ 1><!------ billback is pound ----->
						 	/ IM.Net_Weight
						</cfif>)
					</cfif>
					)  As AvgProgramPrice,

					<!----************ IBF_Rate - Start ********* ---->
					<cfif (arguments.programDelType eq 1 or arguments.programDelType eq 4)>
						Avg((ISNULL(PDF.IBF_Rate, 0) / 100.00) * IM.Gross_Weight
						<cfif arguments.billbackUOM NEQ 1><!------ billback is pound ----->
							 / IM.Net_Weight
						</cfif>) as IBF_Rate,
					<cfelse>
						0 as IBF_Rate,
					</cfif>
					<!----************ OBF_Rate - Start ********* ---->
					<!--- Handle for Special Freight At Item Level --->
					<cfif arguments.programDelType eq 1 AND NOT arguments.bFreightVersionItem>
						Avg((ISNULL(PDF.OBF_Rate, 0) / 100.00) * IM.Gross_Weight
						<cfif arguments.billbackUOM NEQ 1><!------ billback is pound ----->
							 / IM.Net_Weight
						</cfif>) as OBF_Rate
					<cfelseif arguments.bFreightVersionItem>
						<!--- Special Item Version has OBF at the Item (Class_Code) level - It will be stored in table Program_Fixed_Freight_Rates going forward --->
						Avg(
						CASE CWB.Freight_Bracket_Setting_ID 
						WHEN 1 THEN OBF.OBF_Rate_1_CS WHEN 2 THEN OBF.OBF_Rate_2_CS WHEN 3 THEN OBF.OBF_Rate_3_CS 
						WHEN 4 THEN OBF.OBF_Rate_4_CS WHEN 5 THEN OBF.OBF_Rate_5_CS WHEN 6 THEN OBF.OBF_Rate_6_CS
						WHEN 7 THEN OBF.OBF_Rate_7_CS WHEN 8 THEN OBF.OBF_Rate_8_CS ELSE 0 
						END
						<cfif arguments.billbackUOM NEQ 1><!------ billback is pound ----->
							 / IM.Net_Weight
						</cfif>) as OBF_Rate
					<cfelse>
						0 as OBF_Rate
					</cfif>
			FROM	Contract_Products CP
					INNER JOIN BSA_Foodservice_Items_Master IM ON
						IM.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
					INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON
						PFPPD.Deleted = 0 AND
						PFPPD.Contract_Products_ID = CP.Contract_Products_ID
					INNER JOIN Units_of_Measure ON
						Units_of_Measure.Unit_Of_Measure_ID = PFPPD.Unit_Of_Measure_ID
					<cfif arguments.fixedComponentsOn>
						INNER JOIN Program_Fixed_Component PFC ON
							PFC.Deleted = 0 AND
							PFC.Program_Fixed_Component_ID = PFPPD.Program_Fixed_Component_ID
						<cfif arguments.payTo NEQ 0>
							AND (PFC.Fixed_Component_Paid_to =  #arguments.payTo# or (PFC.Fixed_Component_Paid_to = 4 and  #arguments.payTo# IN (1,2)))
						</cfif>
						-- D21652 -- SQL and CFM Expected rate differ Becuase of Restrict_From_Billback = 0 is in SQL but not in CFM
						INNER JOIN Payment_Type ON
							PFC.Claim_Mechanics = Payment_Type.Payment_Type_ID AND
							Payment_Type.Restrict_From_Billback = 0
						INNER JOIN Program_Fixed_Component_Name PFCN ON
							PFCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
						<cfif arguments.deliveryType NEQ 0>
							AND PFCN.Fixed_Component_Type = #arguments.deliveryType#
						</cfif>
					</cfif>
					LEFT JOIN Program_Fixed_Freight_Rates PFFR on
						PFFR.product_id = CP.BSA_Foodservice_Items_Master_ID AND
						PFFR.deleted = 0 AND
						PFFR.program_id = CP.Contract_Main_ID AND
						PFFR.Component_Name_Id = PFC.Program_Fixed_Component_Name_ID
					<cfif arguments.distributorId neq "">
						AND PFFR.customer_id = '#arguments.distributorId#'
					<cfelse>
						AND 1=2
					</cfif>
					<cfif (arguments.programDelType eq 1 or arguments.programDelType eq 4 OR arguments.bFreightVersionItem)> <!--- programDelType: 1=DEL, 4=FOB DC ----->
						LEFT JOIN ##tmp_Program_Distributor_Freight PDF on
							PDF.deleted = 0
							-- AND PDF.program_id = CP.Contract_Main_ID
						<cfif arguments.distributorId neq "">
							AND PDF.distributor_id = '#arguments.distributorId#'
						<cfelse>
							AND 1=2
						</cfif>
						<cfif bFreightVersionItem>
							LEFT JOIN Program_Freight_Version_CC OBF ON
								OBF.Program_ID = CP.Contract_Main_ID AND
								OBF.Product_ID  = CP.BSA_Foodservice_Items_Master_ID AND
								PFCN.Fixed_Component_Type = #arguments.deliveryType#
							LEFT JOIN Customer_Warehouse_Bracket CWB ON
								CWB.Distributor_ID = '#arguments.distributorId#'	
						</cfif>
					</cfif>
					<cfif arguments.checkProductWonStatus>
						INNER JOIN Program_Product_Bid_Info ON
							Program_Product_Bid_Info.Program_ID = CP.Contract_Main_ID AND
							Program_Product_Bid_Info.Product_ID = CP.BSA_Foodservice_Items_Master_ID AND
							Program_Product_Bid_Info.deleted = 0 AND
							Program_Product_Bid_Info.Won = 1
					</cfif>
			WHERE
				CP.Deleted = 0
				AND CP.BSA_Foodservice_Items_Master_ID = '#arguments.productId#'
				AND CP.Contract_Main_ID = #arguments.programId#
				AND CAST(PFPPD.Fixed_Price_Value AS Float) > 0
		</cfquery>

		<cfreturn qGetAvgProgramFixedPrice>

	</cffunction>

	<cffunction name="getAvgProgramBidRequestPrice" output="false" returntype="query">

		<cfargument name="programId" required="true" type="numeric">
		<cfargument name="productId" required="true" type="string">
		<cfargument name="billbackUOM" required="true" type="numeric">
		<cfargument name="deliveryType" required="true" type="numeric">
		<cfargument name="fixedComponentsOn" required="true" type="numeric">
		<cfargument name="payTo" required="false" type="numeric" default="0">

		<cfquery name="qGetAvgProgramBidRequestPrice" datasource="#application.datasource#">
			SELECT	Avg(
					CAST(Program_Bid_Request_Product.Price AS Float)
					<cfif arguments.billbackUOM EQ 1><!------ billback is case ----->
					* (CASE Program_Bid_Request_Product.UOM
					WHEN 1 THEN 1
					ELSE CAST(BSA_Foodservice_Items_Master.Net_Weight As Float)
					END)
					<cfelse><!------ billback is pound ----->
					/ (CASE Program_Bid_Request_Product.UOM
					WHEN 1 THEN CAST(BSA_Foodservice_Items_Master.Net_Weight As Float)
					ELSE 1
					END)
					</cfif>
					)  As AvgProgramPrice
			FROM	Contract_Products
					INNER JOIN BSA_Foodservice_Items_Master
					ON
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
					INNER JOIN Program_Bid_Request_Product
					ON
					Program_Bid_Request_Product.Deleted = 0
					AND Program_Bid_Request_Product.Contract_Products_ID = Contract_Products.Contract_Products_ID
					INNER JOIN Units_of_Measure
					ON
					Units_of_Measure.Unit_Of_Measure_ID = Program_Bid_Request_Product.UOM
					<cfif arguments.fixedComponentsOn>
					INNER JOIN Program_Bidrequest_Component
					ON
					Program_Bidrequest_Component.Deleted = 0
					AND Program_Bidrequest_Component.Program_Bidrequest_Component_ID = Program_Bid_Request_Product.Program_Bidrequest_Component_ID
					<cfif arguments.payTo NEQ 0>
					AND (Program_Bidrequest_Component.Program_Bidrequest_Component_Paid_to =  #arguments.payTo# or (Program_Bidrequest_Component.Program_Bidrequest_Component_Paid_to = 4 and  #arguments.payTo# IN (1,2)))
					</cfif>
					INNER JOIN Program_BidRequest_Component_Name
					ON
					Program_BidRequest_Component_Name.Program_BidRequest_Component_Name_ID = Program_Bidrequest_Component.Program_BidRequest_Component_Name_ID
					<cfif arguments.deliveryType NEQ 0>
					AND Program_BidRequest_Component_Name.BidRequest_Component_Type = #arguments.deliveryType#
					</cfif>
					</cfif>
			WHERE
					Contract_Products.Deleted = 0
					AND Contract_Products.BSA_Foodservice_Items_Master_ID = '#arguments.productId#'
					AND Contract_Products.Contract_Main_ID = #arguments.programId#
		</cfquery>

		<cfreturn qGetAvgProgramBidRequestPrice>

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get Fixed Price Delivery Type Information /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getFixedProductComponentDeliveryTypes" output="false" returntype="query">

		<cfargument name="productId" required="true" type="string">
		<cfargument name="programId" required="true" type="numeric">
		<cfargument name="payTo" required="false" type="numeric" default="0">

		<!------ get data ----->
		<CFQUERY NAME="GetFixedComponents" DATASOURCE="#application.datasource#">
			SELECT	DISTINCT Program_Fixed_Component_Name.Fixed_Component_Type<!------ 1= delivered, 2 =FOB ----->
			FROM	Contract_Products
					INNER JOIN Program_Fixed_Price_Product_Data
					ON
					Program_Fixed_Price_Product_Data.Deleted = 0
					AND Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
					INNER JOIN Units_of_Measure
					ON
					Units_of_Measure.Unit_Of_Measure_ID = Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID
					INNER JOIN Program_Fixed_Component
					ON
					Program_Fixed_Component.Deleted = 0
					AND Program_Fixed_Component.Program_Fixed_Component_ID = Program_Fixed_Price_Product_Data.Program_Fixed_Component_ID
					<cfif arguments.payTo NEQ 0>
					AND (Program_Fixed_Component.Fixed_Component_Paid_to =  #arguments.payTo# or (Program_Fixed_Component.Fixed_Component_Paid_to = 4 and  #arguments.payTo# IN (1,2)))
					</cfif>
					-- D21652 -- SQL and CFM Expected rate differ Becuase of Restrict_From_Billback = 0 is in SQL but not in CFM
					INNER JOIN Payment_Type
					ON 	Program_Fixed_Component.Claim_Mechanics = Payment_Type.Payment_Type_ID
					AND 	Payment_Type.Restrict_From_Billback = 0
					INNER JOIN Program_Fixed_Component_Name
					ON
					Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID = Program_Fixed_Component.Program_Fixed_Component_Name_ID
			WHERE
					Contract_Products.Deleted = 0
					AND Contract_Products.BSA_Foodservice_Items_Master_ID = '#arguments.productId#'
					AND Contract_Products.Contract_Main_ID = #arguments.programId#
					AND CAST(Program_Fixed_Price_Product_Data.Fixed_Price_Value AS Float) > 0
		</CFQUERY>

		<cfreturn GetFixedComponents />

	</cffunction>

	<cffunction name="getBidRequestProductComponentDeliveryTypes" output="false" returntype="query">

		<cfargument name="productId" required="true" type="string">
		<cfargument name="programId" required="true" type="numeric">
		<cfargument name="payTo" required="false" type="numeric" default="0">

		<!------ get data ----->
		<CFQUERY NAME="GetBidRequestComponents" DATASOURCE="#application.datasource#">
			SELECT	DISTINCT Program_BidRequest_Component_Name.BidRequest_Component_Type Fixed_Component_Type<!------ 1= delivered, 2 =FOB ----->
			FROM	Contract_Products
					INNER JOIN Program_Bid_Request_Product
					ON
					Program_Bid_Request_Product.Deleted = 0
					AND Program_Bid_Request_Product.Contract_Products_ID = Contract_Products.Contract_Products_ID
					INNER JOIN Units_of_Measure
					ON
					Units_of_Measure.Unit_Of_Measure_ID = Program_Bid_Request_Product.UOM
					INNER JOIN Program_Bidrequest_Component
					ON
					Program_Bidrequest_Component.Deleted = 0
					AND Program_Bidrequest_Component.Program_Bidrequest_Component_ID = Program_Bid_Request_Product.Program_Bidrequest_Component_ID
					<cfif arguments.payTo NEQ 0>
					AND (Program_Bidrequest_Component.Program_Bidrequest_Component_Paid_to = #arguments.payTo# or (Program_Bidrequest_Component.Program_Bidrequest_Component_Paid_to = 4 and #arguments.payTo# IN (1,2)))
					</cfif>
					INNER JOIN Program_BidRequest_Component_Name
					ON
					Program_BidRequest_Component_Name.Program_BidRequest_Component_Name_ID = Program_Bidrequest_Component.Program_BidRequest_Component_Name_ID
			WHERE
					Contract_Products.Deleted = 0
					AND Contract_Products.BSA_Foodservice_Items_Master_ID = '#arguments.productId#'
					AND Contract_Products.Contract_Main_ID = #arguments.programId#
		</CFQUERY>

		<cfreturn GetBidRequestComponents />

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get Fixed Price Information /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getFixedProductComponent" output="false" returntype="query">

		<cfargument name="productId" required="true" type="string">
		<cfargument name="programId" required="true" type="numeric">

		<!------ get data ----->
		<CFQUERY NAME="GetFixedComponents" DATASOURCE="#application.datasource#">
			SELECT	Program_Fixed_Price_Product_Data.Fixed_Price_Value,
					Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID,
					Units_of_Measure.Abbreviation,
					Program_Fixed_Component_Name.Program_Fixed_Component_Name,
					Program_Fixed_Price_Product_Data.Program_Fixed_Price_Product_Data_ID,
					Program_Fixed_Component_Name.Fixed_Component_Type<!------ 1= delivered, 2 =FOB ----->
			FROM	Contract_Products
					INNER JOIN Program_Fixed_Price_Product_Data
					ON
					Program_Fixed_Price_Product_Data.Deleted = 0
					AND Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
					INNER JOIN Units_of_Measure
					ON
					Units_of_Measure.Unit_Of_Measure_ID = Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID
					INNER JOIN Program_Fixed_Component
					ON
					Program_Fixed_Component.Deleted = 0
					AND Program_Fixed_Component.Program_Fixed_Component_ID = Program_Fixed_Price_Product_Data.Program_Fixed_Component_ID
					INNER JOIN Program_Fixed_Component_Name
					ON
					Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID = Program_Fixed_Component.Program_Fixed_Component_Name_ID
			WHERE
					Contract_Products.Deleted = 0
					AND Contract_Products.BSA_Foodservice_Items_Master_ID = '#arguments.productId#'
					AND Contract_Products.Contract_Main_ID = #arguments.programId#
		</CFQUERY>

		<cfreturn GetFixedComponents />

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get Growth Volume Information from invoice /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getGrowthComponentVolume" output="false" returntype="query">

		<cfargument name="distributorId" required="true" type="string">
		<cfargument name="componentId" required="true" type="string">
		<cfargument name="startDate" required="true" type="date">
		<cfargument name="endDate" required="true" type="date">
		<cfargument name="invoiceDateField" required="true" type="string">
		<cfargument name="showProductDetails" required="false" type="numeric" default="1">
		<cfargument name="FobPriceIndicator" required="false" type="string" default="Y,N">

		<CFQUERY  dataSource="#application.datasource#" NAME="qGetGrowthComponentVolume">
			<cfif this.appSettings.getProductReplacementEnabled()>
			DECLARE @ProductsInProgram table (Product_ID uniqueidentifier)
			INSERT INTO @ProductsInProgram (Product_ID)
			SELECT	Contract_Products.BSA_Foodservice_Items_Master_ID
			FROM	Program_Growth_Component_Product_Data
			INNER JOIN	Contract_Products
			ON		Contract_Products.Contract_Products_ID = Program_Growth_Component_Product_Data.Contract_Products_ID
			AND		Contract_Products.Deleted = 0
			WHERE	Program_Growth_Component_Product_Data.Program_Growth_Component_ID = '#arguments.componentId#'
			AND		Program_Growth_Component_Product_Data.Deleted = 0
			</cfif>

			SELECT	DISTINCT
						SUM(CAST(IsNull(Pounds_Invoiced, 0) AS FLOAT)) AS Sum_Volume_Invoiced,
						SUM(CAST(IsNull(Cases_Invoiced, 0) AS FLOAT)) AS Sum_Volume_Invoiced_CS,
						SUM(CAST(IsNull(Sales_Dollars, 0) AS FLOAT)) AS Sum_Amount
						<CFIF arguments.showProductDetails EQ 1>
						, BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
						, BSA_Foodservice_Items_Master.Description
						, BSA_Foodservice_Items_Master.Item
						</CFIF>
			FROM	Program_Growth_Component_Product_Data
					INNER JOIN	Contract_Products
					ON
					Contract_Products.Contract_Products_ID = Program_Growth_Component_Product_Data.Contract_Products_ID
					AND	Contract_Products.Deleted = 0
					INNER JOIN	BSA_Foodservice_Items_Master
					ON
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
					<cfif this.appSettings.getProductReplacementEnabled()>
					LEFT JOIN Item_Replacement
					ON	Item_Replacement.Original_Item_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
					AND	Item_Replacement.Deleted = 0
					AND	Item_Replacement.Replacement_Item_ID NOT IN (SELECT Product_ID FROM @ProductsInProgram)
					</cfif>
					LEFT JOIN Invoice_Header
					ON
					Invoice_Header.BSA_Foodservice_Customers_ID = '#arguments.distributorId#'
					AND	DATEDIFF(d, #CreateODBCDate(arguments.startDate)#, #arguments.invoiceDateField#) >= 0
					AND	DATEDIFF(d, #arguments.invoiceDateField#, #CreateODBCDate(arguments.endDate)#) >= 0
					AND	Invoice_Header.Deleted = 0
					LEFT JOIN	Invoice_Detail
					ON
					Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
					AND	(Contract_Products.BSA_Foodservice_Items_Master_ID = Invoice_Detail.BSA_Foodservice_Items_Master_ID
					<cfif this.appSettings.getProductReplacementEnabled()>
					OR	Item_Replacement.Replacement_Item_ID = Invoice_Detail.BSA_Foodservice_Items_Master_ID
					</cfif>
					)
					AND	Invoice_Detail.Deleted = 0
					<cfif this.appSettings.getCheckOrderClass()>
					AND Invoice_Detail.Order_Class IN (#ListQualify(this.appSettings.getOrderClassValue(), "'", ",")#)
					</cfif>
					AND	ISNULL(Invoice_Detail.FOB_PRICE_IND, 'N') IN (#ListQualify(arguments.FobPriceIndicator, "'", ",")#)
					--- D21756 -- Commentting based on the discussion with Paul
					--- D22024 -- Uncommenting the Operator and commenting the Negative CS check -- We should do 21756 only in fixed rate
					<!--- 49429 - APF Enhancement: INCLUDE OI TRANSACTIONS IN BB VALIDATION/Anand Rao/15-Mar-16 --->
					<cfif this.appSettings.get_Setting('BB_Deviation_Include_Invoices_With_Operator_ID') neq '1'>
						AND ISNULL(Invoice_Detail.BSA_Operator_ID, 0) = 0
					</cfif>
					AND ISNULL(Cast(Invoice_Detail.Cases_Invoiced as float), 0) > 0
				WHERE
					Program_Growth_Component_Product_Data.Program_Growth_Component_ID = '#arguments.componentId#'
					AND	Program_Growth_Component_Product_Data.Deleted = 0
				<CFIF arguments.showProductDetails EQ 1>
				GROUP BY BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, BSA_Foodservice_Items_Master.Description, BSA_Foodservice_Items_Master.Item
				ORDER BY BSA_Foodservice_Items_Master.Description
				</CFIF>
		</CFQUERY>

		<cfreturn qGetGrowthComponentVolume/>

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get Growth Volume Information from billback /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getGrowthComponentBillbackVolume" output="false" returntype="query">

		<cfargument name="billbackId" required="true" type="string">
		<cfargument name="componentId" required="true" type="string">
		<cfargument name="programId" required="true" type="numeric">
		<cfargument name="showProductDetails" required="false" type="numeric" default="1">
		<cfargument name="Program_Growth_Comparison_Period_UOM_ID" required="false" type="numeric" default="0">

		<CFQUERY dataSource="#application.datasource#" NAME="qGetGrowthComponentVolume">
			SELECT	ISNULL(SUM(CAST(ISNULL(
							CASE
							WHEN Billback_Product.BB_Product_UOM = 1 THEN
								Billback_Product.BB_Product_Quantity * CAST(BSA_Foodservice_Items_Master.Net_Weight AS FLOAT)
							ELSE
								Billback_Product.BB_Product_Quantity
							END
							, 0) AS FLOAT)), 0) AS Sum_Volume_Invoiced
						, ISNULL(SUM(CAST(ISNULL(
							CASE
							WHEN Billback_Product.BB_Product_UOM = 1 THEN
								Billback_Product.BB_Product_Quantity
							ELSE
								Billback_Product.BB_Product_Quantity / CAST(BSA_Foodservice_Items_Master.Net_Weight AS FLOAT)
							END
							, 0) AS FLOAT)), 0) AS Sum_Volume_Invoiced_CS

								<CFIF arguments.Program_Growth_Comparison_Period_UOM_ID eq 2>
								,(SELECT ISNULL(SUM(CAST(ISNULL(bb_rate, 0) AS FLOAT)), 0)
									FROM billback_product_detail
									WHERE billback_product_id =  Billback_Product.Billback_Product_ID
									AND deleted =0) As Sum_Amount
								<cfelse>
								,0 AS Sum_Amount
								</CFIF>
						<CFIF arguments.showProductDetails EQ 1>
						, BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
						, BSA_Foodservice_Items_Master.Description
						, BSA_Foodservice_Items_Master.Item
						</CFIF>
			FROM
					Program_Growth_Component_Product_Data
					INNER JOIN	Contract_Products
					ON
					(
						(Contract_Products.Contract_Products_ID = Program_Growth_Component_Product_Data.Contract_Products_ID)
						AND
						(Contract_Products.Deleted = 0)
					)
					INNER JOIN	BSA_Foodservice_Items_Master
					ON
					(
						(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID)
					)
					INNER JOIN Billback_Product
					ON
					(
						(Billback_Product.Product_ID = Contract_Products.BSA_Foodservice_Items_Master_ID)
						AND
						(Billback_Product.Deleted = 0)
					)
					INNER JOIN Billback_Program
					ON
					(
						(Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID)
						AND
						(Billback_Program.Program_ID = #arguments.programId#)
						AND
						(Billback_Program.Billback_ID = '#arguments.billbackId#')
					)
			WHERE
					Program_Growth_Component_Product_Data.Program_Growth_Component_ID = '#arguments.componentId#'
					AND	Program_Growth_Component_Product_Data.Deleted = 0
				<CFIF arguments.showProductDetails NEQ 1>
				<CFIF arguments.Program_Growth_Comparison_Period_UOM_ID eq 2>
				 GROUP BY Billback_Product.Billback_Product_ID
				</CFIF>
				</CFIF>
				<CFIF arguments.showProductDetails EQ 1>
				GROUP BY <CFIF arguments.Program_Growth_Comparison_Period_UOM_ID eq 2>Billback_Product.Billback_Product_ID,</CFIF>BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, BSA_Foodservice_Items_Master.Description, BSA_Foodservice_Items_Master.Item
				ORDER BY BSA_Foodservice_Items_Master.Description
				</CFIF>
			</CFQUERY>

		<cfreturn qGetGrowthComponentVolume/>

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get Invoice Info /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getInvoiceInfo" output="false" returntype="query">

		<cfargument name="distributorId" required="true" type="string">
		<cfargument name="productId" required="true" type="string">
		<cfargument name="startDate" required="true" type="date">
		<cfargument name="endDate" required="true" type="date">
		<cfargument name="returnUOM" required="true" type="numeric">
		<cfargument name="invoiceDateField" required="true" type="string">
		<cfargument name="returnType" required="false" type="numeric" default="1">
		<cfargument name="FobPriceIndicator" required="false" type="string" default="Y,N">
		<cfargument name="InvoiceTypeFilter" required="false" type="string" default="">
		<cfargument name="InvoiceTypeExcludeList" required="false" type="string" default="">

		<CFQUERY  dataSource="#application.datasource#" NAME="qGetInvoiceInfo">
			SELECT	<cfif arguments.returnType EQ 1>
						ISNULL(CAST(<CFIF arguments.returnUOM EQ 1>CS_Unit_Price
						<CFELSE>LB_Unit_Price
						</CFIF> AS FLOAT), 0) AS UOM_Unit_Price ,
						ISNULL(CAST(<CFIF  arguments.returnUOM EQ 1>Cases_Invoiced
						<CFELSE>Pounds_Invoiced
						</CFIF> AS FLOAT), 0) AS UOM_Volume_Invoiced
						,Invoice_Header.Invoice_Version + '-' + Invoice_Header.Order_Number AS Invoice_Number,
						#arguments.invoiceDateField# AS Invoice_Check_Date
						,ISNULL(CAST(Sales_Dollars  AS FLOAT), 0) As Sales_Dollars
					<cfelseif arguments.returnType EQ 2>
						SUM(ISNULL(CAST(<CFIF  arguments.returnUOM EQ 1>Cases_Invoiced
						<CFELSE>Pounds_Invoiced
						</CFIF> AS FLOAT), 0)) AS UOM_Volume_Invoiced,
						SUM(
						CAST(<CFIF arguments.returnUOM EQ 1>CS_Unit_Price<CFELSE>LB_Unit_Price</CFIF> AS Float)
						* CAST(<CFIF  arguments.returnUOM EQ 1>Cases_Invoiced<CFELSE>Pounds_Invoiced</CFIF> AS Float)
						)
						/ SUM(ISNULL(CAST(<CFIF  arguments.returnUOM EQ 1>Cases_Invoiced<CFELSE>Pounds_Invoiced</CFIF> AS FLOAT), 0)) As AvgPrice
						,SUM(ISNULL(CAST(Sales_Dollars  AS FLOAT), 0)) As Sales_Dollars
					</cfif>
			FROM	Invoice_Header
					INNER JOIN Invoice_Detail
					ON
					Invoice_Detail.Deleted = 0
					<cfif this.appSettings.getCheckOrderClass()>
					AND Invoice_Detail.Order_Class IN (#ListQualify(this.appSettings.getOrderClassValue(), "'", ",")#)
					</cfif>
					AND
					Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
					AND
					Invoice_Detail.BSA_Foodservice_Items_Master_ID = '#arguments.productId#'
					AND	ISNULL(Invoice_Detail.FOB_PRICE_IND, 'N') IN (#ListQualify(arguments.FobPriceIndicator, "'", ",")#)
					--- D21756 -- Commentting based on the discussion with Paul
					--- D22024 -- Uncommenting the Operator and commenting the Negative CS check -- We should do 21756 only in fixed rate
					<!--- 49429 - APF Enhancement: INCLUDE OI TRANSACTIONS IN BB VALIDATION/Anand Rao/15-Mar-16 --->
					<cfif this.appSettings.get_Setting('BB_Deviation_Include_Invoices_With_Operator_ID') neq '1'>
						AND ISNULL(Invoice_Detail.BSA_Operator_ID, 0) = 0
					</cfif>
					AND ISNULL(Cast(Invoice_Detail.Cases_Invoiced as float), 0) > 0
			WHERE
					Invoice_Header.Deleted = 0
					AND
					DATEDIFF(d, #arguments.invoiceDateField#, #CreateODBCDate(arguments.startDate)#) <= 0
					AND
					DATEDIFF(d, #arguments.invoiceDateField#, #CreateODBCDate(arguments.endDate)#) >= 0
					<cfif arguments.distributorId EQ "">
					AND 1=2
					<cfelse>
					AND Invoice_Header.BSA_Foodservice_Customers_ID = '#arguments.distributorId#'
					</cfif>
				<cfif arguments.InvoiceTypeFilter neq "">
					AND Invoice_Header.Invoice_Type IN (#ListQualify(arguments.InvoiceTypeFilter, "'", ",")#)
				</cfif>
				<cfif arguments.InvoiceTypeExcludeList neq "">
					AND Invoice_Header.Invoice_Type NOT IN (#ListQualify(arguments.InvoiceTypeExcludeList, "'", ",")#)
				</cfif>
		</CFQUERY>

		<cfreturn qGetInvoiceInfo/>

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get Volume Component  /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getVolumeComponent" output="false" returntype="query">

		<cfargument name="componentId" required="true" type="string">

		<CFQUERY  dataSource="#application.datasource#" NAME="qGetVolumeComponent">
			SELECT	TOP 1 *
			FROM	Program_Growth_Components
			WHERE
					Program_Growth_Components.Deleted = 0
					AND Program_Growth_Components.Parent_ID = '#arguments.componentId#'
		</CFQUERY>

		<cfreturn qGetVolumeComponent/>

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get Growth Tier Attained /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getGrowthTierAttained" output="false" returntype="numeric">

		<cfargument name="componentId" required="true" type="string">
		<cfargument name="totalVolume" required="true" type="numeric">
		<cfargument name="totalAmount" required="true" type="numeric">
		<cfargument name="componentUOM" required="true" type="numeric">
		<cfargument name="priorYearPercent" required="true" type="numeric">
		<cfargument name="Program_Growth_Comparison_Period_UOM_ID" required="true" type="numeric">

		<cfset returnValue = 0>

		<cfif componentUOM EQ 3>
			<cfif Program_Growth_Comparison_Period_UOM_ID eq 2>
				<cfset qGetGrowthTierAttained = this.getGrowthPercentTiersAttained(arguments.componentId, arguments.totalAmount, arguments.priorYearPercent, 2)>
			<cfelse>
				<cfset qGetGrowthTierAttained = this.getGrowthPercentTiersAttained(arguments.componentId, arguments.totalVolume, arguments.priorYearPercent, 2)>
			</cfif>
		<cfelse>
			<CFQUERY  dataSource="#application.datasource#" NAME="qGetGrowthTierAttained">
				SELECT	ISNULL(MAX(Program_Growth_Component_Tiers.Tier_Number), 0) As Max_Tier_Number
				FROM	Program_Growth_Components
						INNER JOIN Program_Growth_Component_Tiers
						ON
						Program_Growth_Component_Tiers.Deleted = 0
						AND Program_Growth_Component_Tiers.Program_Growth_Component_ID = Program_Growth_Components.Program_Growth_Component_ID
						<cfif arguments.componentUOM EQ 4>
						AND CAST(Program_Growth_Component_Tiers.Range_Start AS Float) <= #arguments.totalAmount#
						<cfelse>
						AND CAST(Program_Growth_Component_Tiers.Range_Start AS Float) <= #arguments.totalVolume#
						</cfif>
				WHERE
						Program_Growth_Components.Program_Growth_Component_ID = '#arguments.componentId#'
						AND	Program_Growth_Components.Deleted = 0
			</CFQUERY>
		</cfif>

		<cfif qGetGrowthTierAttained.recordCount>
			<cfset returnValue = qGetGrowthTierAttained.Max_Tier_Number>
		</cfif>

		<cfreturn returnValue/>

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get Growth Tiers Attained % /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getGrowthPercentTiersAttained" output="false" returntype="query">

		<cfargument name="componentId" required="true" type="string">
		<cfargument name="totalInvoice" required="true" type="numeric">
		<cfargument name="priorYearPercent" required="true" type="numeric">
		<cfargument name="returnType" required="true" type="numeric">

		<CFQUERY NAME="qGetGrowthPercentTiersAttained" DATASOURCE="#application.datasource#">
		SELECT	<cfif arguments.returnType EQ 1>
				Program_Growth_Component_Tiers.Growth_Amount,
				CAST(Program_Growth_Component_Tiers.Tier_Number AS INT) AS Tier_Number,
				CASE
				WHEN C2.Range_End = '*' THEN
					#arguments.totalInvoice# <!------/*would not be used*/----->
				WHEN C2.Program_Growth_Component_ID IS NULL THEN
					ROUND(CAST(Program_Growth_Component_Tiers.Range_Start AS FLOAT) * #arguments.priorYearPercent#, 0) <!------ First Tier ----->
				ELSE
					ROUND((CAST(C2.Range_End AS FLOAT) * #arguments.priorYearPercent#) + 1, 0) <!----- Remaining Tiers ------>
				END AS Range_Start,
				CASE
				WHEN Program_Growth_Component_Tiers.Range_End = '*' THEN
					ROUND(#arguments.totalInvoice#, 0)
				WHEN #arguments.totalInvoice# < ROUND(CAST(Program_Growth_Component_Tiers.Range_End AS FLOAT) * #arguments.priorYearPercent#, 0) THEN
					#arguments.totalInvoice#
				ELSE
					ROUND(CAST(Program_Growth_Component_Tiers.Range_End AS FLOAT) * #arguments.priorYearPercent#, 0)
				END AS Effective_Range_End,
				CASE
				WHEN Program_Growth_Component_Tiers.Range_End = '*' THEN
					Program_Growth_Component_Tiers.Range_End
				ELSE
					CAST(CAST(ROUND(CAST(Program_Growth_Component_Tiers.Range_End AS FLOAT) * #arguments.priorYearPercent#, 0) AS DECIMAL(20, 0)) AS NVARCHAR(50))
				END AS Range_End
				<cfelseif arguments.returnType EQ 2>
				ISNULL(MAX(Program_Growth_Component_Tiers.Tier_Number), 0) As Max_Tier_Number
				</cfif>
		FROM	Program_Growth_Component_Tiers
				LEFT JOIN Program_Growth_Component_Tiers C2
				ON
				C2.Program_Growth_Component_ID = Program_Growth_Component_Tiers.Program_Growth_Component_ID
				AND
				C2.Deleted = 0
				AND
				CAST(C2.Tier_Number AS INT) = (CAST(Program_Growth_Component_Tiers.Tier_Number AS INT) - 1)
		WHERE
				Program_Growth_Component_Tiers.Program_Growth_Component_ID = '#arguments.componentId#'
				AND Program_Growth_Component_Tiers.Deleted = 0
				<cfif arguments.returnType EQ 2>
				AND
				(CASE
				WHEN C2.Program_Growth_Component_ID IS NULL THEN
					ROUND(CAST(Program_Growth_Component_Tiers.Range_Start AS FLOAT) * #arguments.priorYearPercent#, 0) <!------ First Tier ----->
				ELSE
					ROUND((CAST(C2.Range_End AS FLOAT) * #arguments.priorYearPercent#) + 1, 0) <!----- Remaining Tiers ------>
				END) <= #arguments.totalInvoice#
				</cfif>
		<cfif arguments.returnType EQ 1>
		ORDER BY Program_Growth_Component_Tiers.Tier_Number
		</cfif>
	</CFQUERY>

	<cfreturn qGetGrowthPercentTiersAttained/>

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get Growth Tiers Information /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getGrowthTiers" output="false" returntype="query">

		<cfargument name="componentId" required="true" type="string">
		<cfargument name="tierReached" required="true" type="string">

		<CFQUERY NAME="qGetGrowthTiers" DATASOURCE="#application.datasource#">

			SELECT	Tier_Number, CAST(BSA_Foodservice_Items_Master.Net_Weight AS FLOAT) AS Net_Weight,
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					BSA_Foodservice_Items_Master.Description,
					BSA_Foodservice_Items_Master.Item,
					CASE
					WHEN Program_Growth_Component_Product_Tier_Data.Unit_Of_Measure_ID = 1 THEN
						CAST(Program_Growth_Component_Product_Tier_Data.Rate AS FLOAT) / CAST(BSA_Foodservice_Items_Master.Net_Weight AS FLOAT)
					ELSE
						CAST(Program_Growth_Component_Product_Tier_Data.Rate AS FLOAT)
					END AS Rate_Per_LB
					,CASE
					WHEN Program_Growth_Component_Product_Tier_Data.Unit_Of_Measure_ID = 1 THEN
						CAST(Program_Growth_Component_Product_Tier_Data.Rate AS FLOAT)
					ELSE
						CAST(Program_Growth_Component_Product_Tier_Data.Rate AS FLOAT) * CAST(BSA_Foodservice_Items_Master.Net_Weight AS FLOAT)
					END AS Rate_Per_CS
					, CAST(Program_Growth_Component_Product_Tier_Data.Rate AS FLOAT) AS Real_Rate
					, Program_Growth_Component_Product_Tier_Data.Unit_Of_Measure_ID AS Rate_UOM
			FROM	Program_Growth_Component_Tiers
					INNER JOIN Program_Growth_Component_Product_Tier_Data
					ON
					(
						(Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID = Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID)
						AND
						(Program_Growth_Component_Product_Tier_Data.Deleted = 0)
						AND
						(Program_Growth_Component_Product_Tier_Data.Rate IS NOT NULL)
					)
					INNER JOIN Program_Growth_Component_Product_Data
					ON
					(
						(Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID = Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_ID)
						AND
						(Program_Growth_Component_Product_Data.Deleted = 0)
					)
					INNER JOIN	Contract_Products
					ON
					(
						(Contract_Products.Contract_Products_ID = Program_Growth_Component_Product_Data.Contract_Products_ID)
						AND
						(Contract_Products.Deleted = 0)
					)
					INNER JOIN	BSA_Foodservice_Items_Master
					ON
					(
						(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID)
					)
			WHERE
					Program_Growth_Component_Tiers.Program_Growth_Component_ID = '#arguments.componentId#'
					AND Program_Growth_Component_Tiers.Deleted = 0
					<cfif arguments.tierReached NEQ "" AND isNumeric(arguments.tierReached)>
						AND Program_Growth_Component_Tiers.Tier_Number = #arguments.tierReached#
					</cfif>
			ORDER BY BSA_Foodservice_Items_Master.Description, BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, Tier_Number

		</CFQUERY>

		<cfreturn qGetGrowthTiers/>

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get Growth Tiers Information /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getGrowthVolumeComponents" output="false" returntype="query">

		<cfargument name="componentId" required="true" type="string">

		<CFQUERY NAME="qGetGrowthVolumeComponents" DATASOURCE="#application.datasource#">

			SELECT	Target_Order, Component_Name, Range_End, Program_Growth_Components.component_uom, Growth_Amount, Program_Growth_Component_Tiers.*
					,Program_Growth_Components.Program_Growth_Comparison_Period_UOM_ID
			FROM	Program_Growth_Components
					INNER JOIN Program_Growth_Component_Tiers
					ON
					Program_Growth_Component_Tiers.Program_Growth_Component_ID = Program_Growth_Components.Program_Growth_Component_ID
			WHERE	Program_Growth_Components.Deleted = 0
					AND Parent_Id = '#arguments.componentId#'
			Order By Target_Order

		</CFQUERY>

		<cfreturn qGetGrowthVolumeComponents/>

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get the program template settings ////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getProgramTemplateSettings" output="false" returntype="query">

		<cfargument name="programId" required="true" type="numeric">

		<cfquery name="qGetProgramTemplateSettings" datasource="#application.datasource#">
			SELECT	Program_Control_Panel_Options.Discount_Lump_Sums, Program_Control_Panel_Options.Discount_Growth,
						Program_Control_Panel_Options.Discount_Lump_Sums_Distributor_Mandated
				FROM	Contract_Main
						INNER JOIN Program_Control_Panel_Options
						ON  Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
				WHERE	Contract_Main.Contract_Main_ID = '#arguments.programId#'
		</cfquery>

		<cfreturn qGetProgramTemplateSettings>

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get the program lump sum ////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getProgramLumpsumComponents" output="false" returntype="query">

		<cfargument name="programId" required="true" type="numeric">
		<!--- <cfargument name="distributorId" required="true" type="string"> --->
		<cfargument name="BBID" required="true" type="string">
		<cfargument name="lumpsumMandated" required="false" type="boolean" default="0">
		<cfargument name="BillbackPayeeType" required="false" type="numeric" default="0">
		<cfset var billbackDevManager = CreateObject("component", "components.billback.BillbackDeviationManager") />
		<cfset var qDistList = billbackDevManager.getBillbackDistributorList(arguments.BBID) />
		<cfset var distList = quotedValueList(qDistList.BSA_Foodservice_Customers_ID)>

		<cfquery name="qGetProgramLumpsumComponents" datasource="#application.datasource#">
			SELECT	Program_Lump_Sums.Program_Lump_Sum_ID, Program_Lump_Sums.Lump_Sum_Name, Program_Lump_Sums.Lump_Sum_Description, Program_Lump_Sums.Program_ID, Program_Lump_Sums.Lump_Sum_Amount, Program_Lump_Sums.Lump_Sum_Volume
			FROM	Program_Lump_Sums
			<cfif arguments.lumpsumMandated EQ 1>
					INNER JOIN Program_Lump_Sum_Distributor
					ON 	Program_Lump_Sum_Distributor.Deleted = 0
					AND Program_Lump_Sum_Distributor.Program_ID = Program_Lump_Sums.Program_ID
					AND Program_Lump_Sum_Distributor.Program_Lump_Sum_ID = Program_Lump_Sums.Program_Lump_Sum_ID
					<cfif qDistList.Recordcount GT 0>
					AND Program_Lump_Sum_Distributor.Distributor_ID in (#PreserveSingleQuotes(distList)#)
					<cfelse>
					AND 1 = 2
					</cfif>
			</cfif>
			WHERE	Program_Lump_Sums.Deleted = 0
			AND 	Program_Lump_Sums.Program_ID = '#arguments.programId#'
			AND 	CAST(Program_Lump_Sums.Lump_Sum_Amount AS float(8)) <> 0
			AND 	len(CAST(Program_Lump_Sums.Lump_Sum_Amount AS float(8))) <> 0
			<cfif arguments.BillbackPayeeType and application.oApplicationAppSettingsManager.getApplicationAppSettings().getBBCheckPayTo()>
			AND (Program_Lump_Sums.Component_Paid_To =  #arguments.BillbackPayeeType# or (Program_Lump_Sums.Component_Paid_To = 4 and  #arguments.BillbackPayeeType# IN (1,2)))
			</cfif>
		</cfquery>

		<cfreturn qGetProgramLumpsumComponents>

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get the payee type ////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getBillbackPayeeType" output="false" returntype="numeric">

		<cfargument name="billbackId" required="true" type="string">
		<cfset payeeTypeId = 0 />

		<cfquery name="qGetBillbackPayeeType" datasource="#application.datasource#">
			SELECT	Billback.Billback_Payee_Type_ID
			FROM	Billback
			WHERE	Billback.Deleted = 0
					AND	Billback.Billback_ID = '#arguments.billbackId#'
		</cfquery>
		<cfif qGetBillbackPayeeType.recordCount>
			<cfset payeeTypeId = qGetBillbackPayeeType.Billback_Payee_Type_ID />
		</cfif>

		<cfreturn payeeTypeId>

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get the payee ////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getBillbackPayee" output="false" returntype="string">

		<cfargument name="billbackId" required="true" type="string">
		<cfargument name="billbackPayeeTypeId" required="true" type="numeric">

		<cfset var payeeId = "" />
		<cfswitch expression="#arguments.billbackPayeeTypeId#">
			<cfcase value="1">
				<cfquery name="qGetBillbackPayee" datasource="#application.datasource#">
					SELECT	Distributor_ID
					FROM	Billback_Distributor
					WHERE	Billback_Distributor.Billback_ID = '#arguments.billbackId#'
					AND		Billback_Distributor.Deleted = 0
				</cfquery>
				<cfset payeeId = qGetBillbackPayee.Distributor_ID />
			</cfcase>
			<cfcase value="2">
				<cfquery name="qGetBillbackPayee" datasource="#application.datasource#">
					SELECT	Operator_ID
					FROM	Billback_Operator
					WHERE	Billback_Operator.Billback_ID = '#arguments.billbackId#'
					AND		Billback_Operator.Deleted = 0
				</cfquery>
				<cfset payeeId = qGetBillbackPayee.Operator_ID />
			</cfcase>
			<cfcase value="3">
				<cfquery name="qGetBillbackPayee" datasource="#application.datasource#">
					SELECT	Broker_ID
					FROM	Billback_Broker
					WHERE	Billback_Broker.Billback_ID = '#arguments.billbackId#'
					AND		Billback_Broker.Deleted = 0
				</cfquery>
				<cfset payeeId = qGetBillbackPayee.Broker_ID />
			</cfcase>
		</cfswitch>

		<cfreturn payeeId />

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get the payee ////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getBillbackDistributor" output="false" returntype="query">

		<cfargument name="billbackId" required="true" type="string">
		<cfargument name="payeeTypeId" required="false" type="numeric" default="1">

		<!---BJF D10726: If the payee isn't one fo these three, then you never join on BSA_Foodservice_Customers which throws an error. It's possible for a billback not to have a Customer. --->
		<cfif listcontains("1,2,4", arguments.payeeTypeId)>
		<cfquery name="qGetPayee" datasource="#application.datasource#">
			SELECT	<cfif payeeTypeId EQ 1 OR payeeTypeId EQ 2 OR payeeTypeId EQ 4>CAST(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID AS NVARCHAR(50))<cfelse>
					''</cfif> BSA_Foodservice_Customers_ID,
					BSA_Foodservice_Customers.Name,
					BSA_Foodservice_Customers.Ship_to,
					BSA_Foodservice_Customers.Shr_Ship_to
			FROM	Billback
				<cfswitch expression="#arguments.payeeTypeId#">
				<cfcase value="1">
					INNER JOIN	Billback_Distributor
					ON	Billback_Distributor.Billback_ID = Billback.Billback_ID
					AND	Billback.Billback_Payee_Type_ID = #arguments.payeeTypeId#
					AND	Billback_Distributor.Deleted = 0
					INNER JOIN BSA_Foodservice_Customers
					ON Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
				</cfcase>
				<cfcase value="2">
					INNER JOIN	Billback_Operator
					ON	Billback_Operator.Billback_ID = Billback.Billback_ID
					AND	Billback.Billback_Payee_Type_ID = #arguments.payeeTypeId#
					AND	Billback_Operator.Deleted = 0
					INNER JOIN BSA_Foodservice_Customers
					ON Billback_Operator.Associated_Ship_To = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
				</cfcase>
				<cfcase value="3">
					INNER JOIN	Billback_Broker
					ON	Billback_Broker.Billback_ID = Billback.Billback_ID
					AND	Billback.Billback_Payee_Type_ID = #arguments.payeeTypeId#
					AND	Billback_Broker.Deleted = 0
					INNER JOIN BSA_Foodservice_Customers
					ON Billback_Broker.Associated_Ship_To = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
				</cfcase>
				<cfcase value="4">
					INNER JOIN	Billback_Unidentified_Payee
					ON	Billback_Unidentified_Payee.Billback_ID = Billback.Billback_ID
					AND	Billback.Billback_Payee_Type_ID = #arguments.payeeTypeId#
					AND	Billback_Unidentified_Payee.Deleted = 0
					INNER JOIN BSA_Foodservice_Customers
					ON Billback_Unidentified_Payee.Associated_Ship_To = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
				</cfcase>
				</cfswitch>
			WHERE	Billback.Deleted = 0
					AND	Billback.Billback_ID = '#arguments.billbackId#'
		</cfquery>
		<cfelse>
		<!--- No distributor on this program --->
		<cfquery name="qGetPayee" datasource="#application.datasource#">
			SELECT	'' AS BSA_Foodservice_Customers_ID,
					'' AS Name,
					'' AS Ship_to,
					'' AS Shr_Ship_to
			FROM	Billback
			WHERE Billback.Deleted = 0
					AND	Billback.Billback_ID = '#arguments.billbackId#'
			</cfquery>
		</cfif>

		<cfreturn qGetPayee>

	</cffunction>


<!---///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get Distributor Id for this BB Product ////////////////////////////////////////////////////////--->
<!---///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->


	<cffunction name="getBBProdDistId" output="false" returntype="query">
		<cfargument name="billbackId" type="string" required="true">
		<cfargument name="billbackProductDetailId" type="string" required="true">
		<cfquery name="qGetBBProdDistId" datasource="#application.datasource#">
			Select	BPD.Distributor_ID_Earned as BSA_Foodservice_Customers_ID
			From Billback_Product_Detail BPD
			where
				Billback_ID = '#arguments.billbackId#'	and
				BillBack_Product_detail_Id = '#arguments.billbackProductDetailId#'
		</cfquery>
		<cfreturn qGetBBProdDistId />
	</cffunction>



<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get the pay to ////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getPayTo" output="false" returntype="numeric">

		<cfargument name="payeeTypeId" required="false" type="numeric" default="1">
		<cfargument name="BBCheckPayTo" required="false" type="numeric" default="0">

		<cfif arguments.BBCheckPayTo>
			<cfreturn arguments.payeeTypeId />
		</cfif>

		<cfreturn 0 />

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// getVolumeFromBillback /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getVolumeFromBillback" output="false" returntype="query">

		<cfargument name="billbackId" required="true" type="string">
		<cfargument name="programId" required="true" type="numeric">
		<cfargument name="productId" required="true" type="string">
		<cfargument name="returnUOM" required="true" type="numeric">

		<CFQUERY dataSource="#application.datasource#" NAME="qGetVolumeFromBillback">
			SELECT	ISNULL(CAST(
						<CFIF arguments.returnUOM EQ 1>
						CASE
						WHEN Billback_Product.BB_Product_UOM = 1 THEN
							Billback_Product.BB_Product_Quantity * CAST(BSA_Foodservice_Items_Master.Net_Weight AS FLOAT)
						ELSE
							Billback_Product.BB_Product_Quantity
						END
						<CFELSE>
						CASE
						WHEN Billback_Product.BB_Product_UOM = 1 THEN
							Billback_Product.BB_Product_Quantity
						ELSE
							Billback_Product.BB_Product_Quantity / CAST(BSA_Foodservice_Items_Master.Net_Weight AS FLOAT)
						END
						</CFIF> AS FLOAT), 0) AS UOM_Volume_Invoiced
			FROM	Billback
					INNER JOIN Billback_Program
					ON
					Billback_Program.Deleted = 0
					AND Billback_Program.Billback_ID = Billback.Billback_ID
					AND Billback_Program.Program_ID = #arguments.programId#
					INNER JOIN Billback_Product
					ON
					Billback_Product.Deleted = 0
					AND Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID
					AND Billback_Product.Product_ID = '#arguments.productId#'
					INNER JOIN	BSA_Foodservice_Items_Master
					ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID
			WHERE	Billback.Deleted = 0
					AND Billback.Billback_ID = '#arguments.billbackId#'
		</CFQUERY>

		<cfreturn qGetVolumeFromBillback/>

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// qGetProgramLumpSumForBillback /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getProgramLumpSumForBillback" output="false" returntype="query">

		<cfargument name="billbackId" required="true" type="string">
		<cfargument name="programNumber" required="true" type="string">
		<cfargument name="BillbackPayeeType" required="false" type="numeric" default="0">

		<CFQUERY dataSource="#application.datasource#" NAME="qGetProgramLumpSumForBillback">
			SELECT 	BB_Program_Lump_Sum_Distributor.Program_ID, Program_Lump_Sum_Name.Program_Lump_Sum_Name Lump_Sum_Name,
					Claimed_Amount, ISNULL(Expected_Amount, 0) Expected_Amount, Program_Amount, Already_Paid_Amount, Program_Avail_Total
			FROM 	BB_Program_Lump_Sum_Distributor
					INNER JOIN BB_Lump_Sums
					ON BB_Lump_Sums.Deleted = 0
					AND BB_Lump_Sums.Billback_ID = BB_Program_Lump_Sum_Distributor.Billback_ID
					AND BB_Lump_Sums.Program_ID = BB_Program_Lump_Sum_Distributor.Program_ID
					INNER JOIN Contract_Main
					ON Contract_Main.Contract_Main_ID = BB_Program_Lump_Sum_Distributor.Program_ID
					AND Contract_Main.Contract_Number = '#arguments.programNumber#'
					INNER JOIN	Program_Lump_Sums
					ON Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID
					AND Program_Lump_Sums.Program_Lump_Sum_ID = BB_Program_Lump_Sum_Distributor.Program_Lump_Sum_ID
					AND Program_Lump_Sums.Deleted = 0
					<cfif arguments.BillbackPayeeType and application.oApplicationAppSettingsManager.getApplicationAppSettings().getBBCheckPayTo()>
					AND (Program_Lump_Sums.Component_Paid_To =  #arguments.BillbackPayeeType# or (Program_Lump_Sums.Component_Paid_To = 4 and  #arguments.BillbackPayeeType# IN (1,2)))
					</cfif>
					<cfif this.appSettings.getClaims_at_Comp_Level()>
					INNER JOIN Billback_Program_Lumpsum_Component
					ON Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID = Program_Lump_Sums.Program_Lump_Sum_ID
					AND Billback_Program_Lumpsum_Component.Deleted = 0
					AND Billback_Program_Lumpsum_Component.Billback_ID = '#arguments.billbackId#'
					</cfif>
					INNER JOIN Program_Lump_Sum_Name
					ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
			WHERE 	BB_Program_Lump_Sum_Distributor.Billback_ID = '#arguments.billbackId#'
			AND 	BB_Program_Lump_Sum_Distributor.Deleted = 0

		</CFQUERY>

		<cfreturn qGetProgramLumpSumForBillback />

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// getAllProgramLumpsumTotals /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getAllProgramLumpsumTotalsVSTemplateMax" output="false" returntype="query">

		<cfargument name="billbackId" required="true" type="string">
		<cfargument name="RatePaidType" required="true" type="string">

		<CFQUERY dataSource="#application.datasource#" NAME="qGetAllProgramLumpsumTotalsVSTemplateMax">
			SELECT 	Contract_Main.Contract_Number, Contract_Main.Contract_Title,
					BB_Lump_Sums.Program_ID, Contract_Main.ProgramType_ID,
					ISNULL(<cfif arguments.RatePaidType EQ "A">
					BB_Lump_Sums.LS_Approved_Amount
					<cfelseif arguments.RatePaidType EQ "BB">
					BB_Lump_Sums.LS_Billback_Amount
					<cfelse>
					BB_Lump_Sums.LS_Expected_Amount
					</cfif>, 0) LS_Amount,
					0.00 LumpSumCap, 0 Discount_Lump_Sums_Distributor_Mandated, 0.00 currentAllocation, 0.00 ProgramAvailBalance
			FROM 	BB_Lump_Sums

			INNER JOIN Contract_Main
			ON		Contract_Main.Contract_Main_ID = BB_Lump_Sums.Program_ID

			WHERE	BB_Lump_Sums.Deleted = 0
			AND		BB_Lump_Sums.Billback_ID = '#arguments.billbackId#'
		</CFQUERY>

		<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
		<cfloop query="qGetAllProgramLumpsumTotalsVSTemplateMax">
			<cfset currentTemplateLumpSumCapAllocation = 0 />
			<cfset templateLumpSumCap = 0 />
			<cfset templateLumpSumDistributorMandated = 0 />
			<cfset iProgramAvailBalance = 0 />

			<cfquery name="qGetProgramAvailBalance" datasource="#application.datasource#">
				SELECT TOP 1 ISNULL(Program_Avail_Total, 0) Program_Avail_Total
				FROM	BB_Program_Lump_Sum_Distributor
				WHERE	Deleted = 0
				AND		Billback_ID = '#arguments.billbackId#'
				AND		Program_ID = #Program_ID#
			</cfquery>
			<cfif qGetProgramAvailBalance.recordCount>
				<cfset iProgramAvailBalance = qGetProgramAvailBalance.Program_Avail_Total />
			</cfif>

			<cfset latestTemplateId = templateManager.getLatestTemplateId(ProgramType_ID)>
			<cfquery name="qGetLumpInfo" datasource="#application.datasource#">
				SELECT	ISNULL(Lump_Sum_Cap, 0) Lump_Sum_Cap, Discount_Lump_Sums_Distributor_Mandated
				FROM	Program_Control_Panel_Options
				WHERE	ProgramControl_Panel_Options_ID = #latestTemplateId#
			</cfquery>
			<cfset templateLumpSumDistributorMandated = qGetLumpInfo.Discount_Lump_Sums_Distributor_Mandated />
			<cfset templateLumpSumCap = qGetLumpInfo.Lump_Sum_Cap />
			<cfif templateLumpSumDistributorMandated EQ 1 AND templateLumpSumCap GT 0>>
				<cfset currentTemplateLumpSumCapAllocation = templateManager.getLumpSumTotal(latestTemplateId)>
			</cfif>

			<cfset QuerySetCell(qGetAllProgramLumpsumTotalsVSTemplateMax, "LumpSumCap", templateLumpSumCap, currentRow) />
			<cfset QuerySetCell(qGetAllProgramLumpsumTotalsVSTemplateMax, "Discount_Lump_Sums_Distributor_Mandated", templateLumpSumDistributorMandated, currentRow) />
			<cfset QuerySetCell(qGetAllProgramLumpsumTotalsVSTemplateMax, "currentAllocation", currentTemplateLumpSumCapAllocation, currentRow) />
			<cfset QuerySetCell(qGetAllProgramLumpsumTotalsVSTemplateMax, "ProgramAvailBalance", iProgramAvailBalance, currentRow) />

		</cfloop>
		<cfreturn qGetAllProgramLumpsumTotalsVSTemplateMax />

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// updateLumpSumAllocation /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="updateLumpSumAllocation" output="false" returntype="void">

		<cfargument name="billbackId" required="true" type="string">
		<cfargument name="selectionType" required="true" type="string">
		<cfargument name="bbLumpSumId" required="false" type="string" default="">
		<cfargument name="bbLumpSumValue" required="false" type="numeric" default="0">

		<cfif application.appSettingsGet.get_Setting('BB_Deviation_Format') contains 'Flex' or application.appSettingsGet.get_Setting('BB_Deviation_Format') contains 'CF'>
			<!---  Update handled in BB_Populate_Approval_Table_Update --->
			<cfreturn />
		</cfif>

		<cfif arguments.selectionType EQ "BB">

			<CFQUERY dataSource="#application.datasource#" NAME="qUpdateLumpSumAllocation1">
				UPDATE	BB_Program_Lump_Sum_Distributor SET Selected_Amount = Claimed_Amount
				WHERE 	BB_Program_Lump_Sum_Distributor.Billback_ID = '#arguments.billbackId#'
				AND 	BB_Program_Lump_Sum_Distributor.Deleted = 0
			</CFQUERY>

		<cfelseif arguments.selectionType EQ "E">

			<CFQUERY dataSource="#application.datasource#" NAME="qUpdateLumpSumAllocation2">
				UPDATE	BB_Program_Lump_Sum_Distributor SET Selected_Amount = Expected_Amount
				WHERE 	BB_Program_Lump_Sum_Distributor.Billback_ID = '#arguments.billbackId#'
				AND 	BB_Program_Lump_Sum_Distributor.Deleted = 0
			</CFQUERY>

		<cfelseif arguments.selectionType EQ "None">

			<CFQUERY dataSource="#application.datasource#" NAME="qUpdateLumpSumAllocation4">
				UPDATE	BB_Program_Lump_Sum_Distributor SET Selected_Amount = 0
				WHERE 	BB_Program_Lump_Sum_Distributor.Billback_ID = '#arguments.billbackId#'
				AND 	BB_Program_Lump_Sum_Distributor.Deleted = 0
			</CFQUERY>

		<cfelseif arguments.bbLumpSumId NEQ "">

			<CFQUERY dataSource="#application.datasource#" NAME="qUpdateLumpSumAllocation5">
				UPDATE	BB_Program_Lump_Sum_Distributor SET Selected_Amount = ISNULL(Selected_Amount,0) + #arguments.bbLumpSumValue#
				WHERE 	BB_Program_Lump_Sum_Distributor.Billback_ID = '#arguments.billbackId#'
				AND 	BB_Program_Lump_Sum_Distributor.Deleted = 0
				<!---- Ana - D17239 - Sum Up the same name_ID selected_Amount -- starting this label Lumpsum will work based on Name_ID instead og Comp_ID----->
				--AND		Billback_Program_Lumpsum_Component_ID = '#arguments.bbLumpSumId#'
				AND		Program_Lump_Sum_Name_ID =
				( 	SELECT 		Program_Lump_Sums.Program_Lump_Sum_Name_ID
					FROM 		Billback_Program_Lumpsum_Component
					INNER JOIN 	Program_Lump_Sums ON Billback_Program_Lumpsum_Component_ID = '#arguments.bbLumpSumId#' AND
								Program_Lump_Sums.Program_Lump_Sum_ID = Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID
				)

			</CFQUERY>

		</cfif>

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// qGetProgramDateDeviation /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getProgramDateDeviation" output="false" returntype="query">

		<cfargument name="billbackId" required="true" type="string">
		<cfargument name="bbProgramId" required="true" type="string">

		<CFQUERY dataSource="#application.datasource#" NAME="qGetProgramDateDeviation">
			SELECT 	<!--- D21647 - Issue#2 - Sum(Claimed_Amount of a program) was = 0 which caused divide by zero error. --->
					CASE
						WHEN BB_Program_Deviation_Info.BB_Dollar_Amount = 0 THEN BB_Program_Deviation_Info.Dates_Not_Match
						ELSE BB_Program_Deviation_Info.Dates_Not_Match / BB_Program_Deviation_Info.BB_Dollar_Amount
					END Dates_Not_Match_Percent
			FROM 	BB_Program_Deviation_Info
			WHERE 	BB_Program_Deviation_Info.Billback_ID = '#arguments.billbackId#'
			AND		BB_Program_Deviation_Info.Billback_Program_ID = '#arguments.bbProgramId#'
			AND 	BB_Program_Deviation_Info.Deleted = 0

		</CFQUERY>

		<cfreturn qGetProgramDateDeviation />

	</cffunction>

	<!------ Get Billback Information #######################################################################	----->
	<!---
		#####	Get the distributor from the deviations component.  This looks at billback_distributor table
		#####	then check for a list of dist id's.  This is for billbacks that have more than one ship to.  typically an operator deal.
		#####	Get the union from these and pass them back with the products so we can insert a product for each distributor
	--->
	<cffunction name="getBillbackDistributorList" output="false" returntype="query">
		<cfargument name="BBID" required="true" type="string">
		<cfset var billbackDevManager = CreateObject("component", "components.billback.BillbackDeviationManager") />
		<cfset var payType = billbackDevManager.getBillbackPayeeType(arguments.BBID) />
		<cfset var getDist = billbackDevManager.getBillbackDistributor(arguments.BBID,payType) />


		<cfquery name="getDistList" datasource="#Application.Datasource#">
		select CAST(billback_distributor_list.Distributor_ID AS NVARCHAR(50)) as BSA_Foodservice_Customers_ID
			from billback_distributor_list
				where billback_distributor_list.deleted = 0
				and billback_distributor_list.Billback_ID = '#arguments.BBID#' </cfquery>

		<cfquery name="qUnionQuery" dbtype="query">
				select BSA_Foodservice_Customers_ID
				from getDist
				union
				select BSA_Foodservice_Customers_ID
				from getDistList
		</cfquery>

		<cfset DistIds = valuelist(qUnionQuery.BSA_Foodservice_Customers_ID)>
		<cfset Dist_IDs = listqualify(DistIds, "'", ",", "all")>

		<!--- There could be no distributor when "getBB_Payee_Operator_Ship_To_Req()" app setting is off --->
		<cfquery name="qGetDistInfo" datasource="#application.datasource#">
		SELECT BSA_Foodservice_Customers_ID
		FROM BSA_Foodservice_Customers
		WHERE <cfif trim('#Dist_IDs#') eq "">1=2<cfelse>BSA_Foodservice_Customers_ID IN (#preservesinglequotes(Dist_IDs)#)</cfif>
		ORDER BY Ship_To
		</cfquery>

		<cfreturn qGetDistInfo />
	</cffunction>
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get Distributor Info /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getDistributorInfo" output="false" returntype="query">
		<cfargument name="CustomerId" required="true" type="string">

		<cfquery name="qGetCustData" datasource="#Application.Datasource#">
					SELECT    Name, Ship_To, Shr_Ship_To, city, state, zipcode -- *
					FROM         dbo.BSA_Foodservice_Customers
					WHERE <cfif trim('#arguments.CustomerId#') eq "">1=2<cfelse>BSA_Foodservice_Customers_ID = '#arguments.CustomerId#'</cfif>
					and deleted = 0
		</cfquery>

		<cfreturn qGetCustData />

	</cffunction>
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Get Product Replacement Details /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getProductReplacementID" output="false" returntype="string">
		<cfargument name="productId" required="true" type="string">

		<cfquery name="qGetItemReplacement" datasource="#Application.Datasource#">
			SELECT	Item_Replacement.*
			FROM	Item_Replacement
			WHERE 	Original_Item_ID = <cfqueryparam value="#arguments.productId#" cfsqltype="CF_SQL_VARCHAR">
			AND		Deleted = 0
		</cfquery>

		<cfif qGetItemReplacement.recordCount>
			<cfreturn qGetItemReplacement.Replacement_Item_ID />
		<cfelse>
			<cfreturn "" />
		</cfif>
	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// getInvoiceFreightFlag /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="bGetInvoiceOnlyOBF" output="false" returntype="boolean" >

		<cfquery name="qGetInvoiceOnlyOBF" datasource="#Application.Datasource#">
				SELECT Add_OBF_Rate_To_Invoice_Only FROM _application_settings
		</cfquery>

		<cfreturn JAVACAST("boolean",qGetInvoiceOnlyOBF.Add_OBF_Rate_To_Invoice_Only) />

	</cffunction>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// getComponentFobPriceIndicator /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getComponentFobPriceIndicator" output="false" returntype="string" >
		<cfargument name="Billback_ID" required="true" type="string">
		<cfargument name="Program_Number" required="true" type="string">
		<cfargument name="BB_Payee_Type_ID" required="true" type="numeric">
		<cfargument name="Billback_Start_Date" required="true" type="date">
		<cfargument name="Billback_End_Date" required="true" type="date">
		<cfargument name="BB_Product_Type_ID" required="true" type="numeric">

		<!---
		81411 Operator deviated BB for REDI should only consider REDI sales
		81411 Removing changes from 76542
		--->
		<cfquery name="qGetComponentFobPriceIndicator" datasource="#Application.Datasource#">
			select 'Y' as Fob_Price_Indicator
			union 
			select 'N' as Fob_Price_Indicator			
		</cfquery>
			
		<cfreturn ValueList(qGetComponentFobPriceIndicator.Fob_Price_Indicator) />

	</cffunction>
			
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// getGrowthComponentFobPriceIndicator /////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getGrowthComponentFobPriceIndicator" output="false" returntype="string" >
		<cfargument name="programGrowthComponentNameID" required="true" type="numeric">
		<cfargument name="BBPayeeTypeID" required="true" type="numeric">
		
		<!---
		81411 Operator deviated BB for REDI should only consider REDI sales
		81411 Removing changes from 76542
		--->
		<cfquery name="qGetComponentFobPriceIndicator" datasource="#Application.Datasource#">
			select 'Y' as Fob_Price_Indicator
			union 
			select 'N' as Fob_Price_Indicator
		</cfquery>
			
		<cfreturn ValueList(qGetComponentFobPriceIndicator.Fob_Price_Indicator) />

	</cffunction>
</cfcomponent>