	<cfset SpanStartDate = "01/01/2004">
	<cfset SpanEndDate	= dateformat(Now(), 'mm/dd/yyyy')>

<cfquery name="DeleteAll" datasource="#application.datasource#">
Truncate Table RP_Mapping_Table
</cfquery>


<cfquery name="GetSumSalesDollarsAndOffInvoice" datasource="#application.datasource#">
				INSERT INTO RP_Mapping_Table
				(
						Distributor_ID,
						Product_ID,
						Program_ID,
						Program_Number,
						Invoice_Header_ID,
						Invoice_Detail_ID,
						Shared_Invoice_Number,
						Invoice_Line_Number, 
						Invoice_Date,
						Span_Start_Date,
						Span_End_Date,
						FP_Start_Date,
						FP_End_Date,
						Item_Number,
						UPC,
						Shared_Ship_To,
						Legacy_Ship_To,
						Cust_ID,
						Corporate_Parent,
						Corporate_Parent_Name,
						Dollars_Sold,
						Off_Invoice,
						Total_Eligible_Trade,
						Rebate_Sum,
						Payment_Amount, 
						Buying_Group,
						Buying_Group_Name,
						<!--- Record_Type, --->
						QBrand_ID
				)
				SELECT DISTINCT
						BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
						Contract_Distributors.Contract_Main_ID,
						Contract_Main.Contract_Number,
						Invoice_Header.Invoice_Header_ID,
						Invoice_Detail.Invoice_Detail_ID,
						Invoice_Header.Shared_Invoice_Number,
						Invoice_Header.Invoice_Date,
						Invoice_Detail.Line,
						Contract_Main.Contract_Start_Date,
						Contract_Main.Contract_End_Date,
						'#SpanStartDate#',
						'#SpanEndDate#',
						BSA_Foodservice_Items_Master.Item,
						BSA_Foodservice_Items_Master.UPC,
						BSA_Foodservice_Customers.Shr_Ship_To AS Shared_Ship_To,
						BSA_Foodservice_Customers.Ship_To AS Legacy_Ship_To,
						Distributor_Customer_ID.CustID,
						Distributor_Family.Family,
						Distributor_Family.Family_Name,
						cast(ISNULL(Invoice_Detail.Sales_Dollars, 0) as float) AS Dollars_Sold, 
						cast(ISNULL(Invoice_Detail.Off_Invoice_Dollars, 0) as float) AS Off_Invoice, 
						cast(ISNULL(Invoice_Detail.Sales_Dollars, 0) as float) - cast(ISNULL(Invoice_Detail.Off_Invoice_Dollars, 0) as float) AS TotalEligibleTrade,
						sum(cast(Program_Rebates_Component_Data.Rate as float)),
						(cast(ISNULL(Invoice_Detail.Sales_Dollars, 0) as float) - cast(ISNULL(Invoice_Detail.Off_Invoice_Dollars, 0) as float)) * (SUM(cast(Program_Rebates_Component_Data.Rate as float)) / 100) AS PaymentAmount,
						Distributor_Buying_Groups.Buying_Group,
						RTRIM(LTRIM(Distributor_Buying_Groups.Buying_Group_Name)),
						<!--- '#Program_Type#' AS Program_Type, --->
						Q_Brand_Desc.Q_Brand_Legacy
				FROM 	<!------ Distributors ----->
						Contract_Distributors		
						INNER JOIN BSA_Foodservice_Customers
						ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
						AND BSA_Foodservice_Customers.Deleted = 0
						LEFT JOIN Distributor_Customer_ID 
						ON Distributor_Customer_ID.Customer_ID = 
						BSA_Foodservice_Customers.Customer_ID
						LEFT JOIN Distributor_Family
						ON Distributor_Family.Family_ID = BSA_Foodservice_Customers.Family_ID
						INNER JOIN Distributor_Buying_Groups
						ON Distributor_Buying_Groups.Buying_Group_ID = BSA_Foodservice_Customers.Buying_Group_ID
						AND Distributor_Buying_Groups.Deleted = 0
						
						<!------ Products ----->
						INNER JOIN Contract_Products
						ON
						Contract_Products.Contract_Main_ID = Contract_Distributors.Contract_Main_ID
						AND	Contract_Products.Deleted = 0
						INNER JOIN Program_Rebates_Product_Data
						ON Program_Rebates_Product_Data.Deleted = 0
						AND	Program_Rebates_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
						INNER JOIN Program_Rebates_Component_Data
						ON	Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID
						AND	Program_Rebates_Component_Data.Unit_of_Measure_ID = 3
						AND	Program_Rebates_Product_Data.Deleted = 0
						INNER JOIN Program_Rebates_Component
						ON	Program_Rebates_Component.Program_ID = Contract_Products.Contract_Main_ID
						AND	Program_Rebates_Component.Deleted = 0
						AND Program_Rebates_Component.Program_Rebates_Component_ID = Program_Rebates_Component_Data.Program_Rebates_Component_ID
						INNER JOIN BSA_Foodservice_Items_Master
						ON 	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
						AND	BSA_Foodservice_Items_Master.Deleted = 0
						INNER JOIN Line_Of_Business
						ON Line_Of_Business.Line_Of_Business_ID = BSA_Foodservice_Items_Master.Line_of_Business_ID
						AND Line_Of_Business.Deleted = 0
						INNER JOIN Product_Q_Brand_Desc
						ON Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
						AND Product_Q_Brand_Desc.Deleted = 0
						AND Product_Q_Brand_Desc.LOB = Line_Of_Business.Line_Of_Business
						INNER JOIN Q_Brand_Desc 
						ON Q_Brand_Desc.Q_Brand_ID = Product_Q_Brand_Desc.Q_Brand_ID 
						<!------ Invoice  Header ----->
						INNER JOIN Invoice_Header
						ON
						Invoice_Header.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
						AND (Invoice_Header.Order_Type = 'N'  OR Invoice_Header.Order_Type = 'R')
						AND Invoice_Header.Order_Status = 'I'
						AND (Invoice_Header.Sales_Type = 'S' OR Invoice_Header.Sales_Type = 'I')
						AND Invoice_Header.Invoice_Date >= '#SpanStartDate#'
						AND Invoice_Header.Invoice_Date <= '#SpanEndDate#'
						INNER JOIN Invoice_Detail
						ON Invoice_Header.Invoice_Header_ID = Invoice_Detail.Invoice_Header_ID
						AND Invoice_Detail.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
						AND Invoice_Detail.Sales_Dollars IS NOT NULL
						AND ISNUMERIC(Invoice_Detail.Sales_Dollars) = 1
						INNER JOIN Contract_Main 
						ON Contract_Main.Contract_Main_ID = Contract_Distributors.Contract_Main_ID
				WHERE 	Contract_Distributors.Deleted = 0
						AND Contract_Distributors.Contract_Main_ID IN 
						(SELECT Contract_Main.Contract_Main_ID
							FROM Contract_Main
								INNER JOIN Program_Control_Panel_Options
								ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
								WHERE Generic_Type LIKE 'Distributor Trade/Shelter'
							AND Contract_Main.Deleted = 0
							AND Contract_Main.Contract_Start_Date >= #SpanEndDate#
							AND Contract_Main.Contract_End_Date >= #SpanStartDate#
							AND Contract_Main.Contract_Status_Type_IDX > 2
						)
						 
												
				GROUP BY
						Distributor_Buying_Groups.Buying_Group,
						Distributor_Buying_Groups.Buying_Group_Name,
						BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID, 
						BSA_Foodservice_Customers.Shr_Ship_To,
						BSA_Foodservice_Customers.Ship_To,
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
						BSA_Foodservice_Items_Master.Item, 
						BSA_Foodservice_Items_Master.UPC, 
						Q_Brand_Desc.Q_Brand_Legacy,
						Invoice_Header.Invoice_Header_ID,
						Invoice_Detail.Invoice_Detail_ID,
						Invoice_Header.Shared_Invoice_Number,
						Invoice_Header.Invoice_Date,
						Invoice_Detail.Line,
						Invoice_Detail.Sales_Dollars, 
						Invoice_Detail.Off_Invoice_Dollars,
						Distributor_Customer_ID.CustID,
						Distributor_Family.Family,
						Distributor_Family.Family_Name,
						Contract_Distributors.Contract_Main_ID,
						Contract_Main.Contract_Number,
						Contract_Main.Contract_Start_Date,
						Contract_Main.Contract_End_Date
			</cfquery>