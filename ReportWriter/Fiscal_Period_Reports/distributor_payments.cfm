
<cfif application.returned_customer_setting.Customer_Keyword IS "conagra">


<!--- <cfset DistributorProgramType = "FERN'S Trade">
<cfset BuyingGroupProgramType = "FERN'S BUYING GROUP">
<cfset CorporateProgramType = "FERN'S Corporate">

<cfset BGName = "FERN BG">
<cfset DSTName = "FERN Dist">
<cfset CORPName = "FERN Corp"> --->

<cfinclude template="garbage_collection.cfm">

	<!---Get all contracts that qualify--->
	<!---Select and set fiscal periods for use throughout page--->
	<cfquery name="GetFiscalPeriods" datasource="#application.datasource#">
	SELECT TOP 1 Start_Date, End_Date FROM Fiscal_Year
	WHERE Deleted = 0
	AND End_Date < getDate()
	ORDER BY End_Date DESC
	</cfquery>
	
<!--- 	<cfdump var="#GetFiscalPeriods#"> --->
	
	<cfset Fiscal_Period_Start_Date = GetFiscalPeriods.Start_Date>
	<cfset Fiscal_Period_End_Date 	= GetFiscalPeriods.End_Date>
	
	<cfset Fiscal_Period_Start_Date = "01/01/2004">
	<cfset Fiscal_Period_End_Date	= Now()>
	
	<cfset FilePath = DateFormat(Fiscal_Period_Start_Date, 'MM-DD-YYYY') & "_" & DateFormat(Fiscal_Period_End_Date, 'MM-DD-YYYY')>
	
	<!--- <cfquery name="GetContractMainOld" datasource="#application.datasource#">
	SELECT DISTINCT Contract_Main.Contract_Main_ID, Contract_Main.Contract_Number, RP_Type.RP_Type_ID AS Created_Type
	FROM Contract_Main
	INNER JOIN Program_Control_Panel_Options
		ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
		AND Generic_Type = 'Distributor Trade/Shelter'
	INNER JOIN RP_Type 
		ON RP_Type.Program_Type_Name = Program_Control_Panel_Options.Created_Type
		AND RP_Type.Deleted = 0
	WHERE Contract_Main.Contract_Status_Type_IDX > 2
	AND Contract_Main.Contract_End_Date >= '#Fiscal_Period_Start_Date#'
	AND Contract_Main.Contract_Start_Date <= '#Fiscal_Period_End_Date#'
	</cfquery> --->
	
	<!--- <!---GetOldDistPrograms--->
	<cfquery name="GetOldDistPrograms" datasource="#application.datasource#">
	INSERT INTO RP_Contract_Main
		(
			Contract_Main_ID, 
			Contract_Number,
			Created_Type
		)
		SELECT TOP 1 Contract_Main.Contract_Main_ID, Contract_Main.Contract_Number, 1 as Created_Type
		FROM Contract_Main
		Where Contract_Main.Contract_Number IN (<!--- '000-1002475','000-1002479','000-1002485','000-1002489','000-1002490','000-1002492','000-1002494','000-1002495','000-1002496','000-1002498','000-1002499','000-1002500','000-1002502','000-1002505','000-1002506','000-1002507','000-1002511','000-1002513','000-1002515','000-1002519','000-1002580','000-1002590','000-1002591','000-1002592','000-1002510','000-1002704','000-1002705','000-1002713','000-1002714','000-1002716','000-1002736','000-1002737','000-1002772', ---><!---New programs from Zafar--->'000-1015775','1016045','000-1016056','000-1016062','000-1016064','000-1016066','000-1016069','000-1016072','000-1016148','000-1002485','000-1015909','000-1015821','000-1015827','000-1015835','000-1015858','000-1015873','000-1015882','000-1015893','000-1015895','000-1015923','000-1015933','000-1015946','000-1015938','000-1015939','000-1015942','000-1015943','000-1015961','000-1015994','000-1015981','000-1015618','000-1015656','000-1015651','000-1015914','000-1015664','000-1016053','000-1016027','000-1016032','000-1016037','000-1016039','000-1002502','000-1002505','000-1015916','000-1015911','000-1015912','000-1002515','000-1016058','000-1016078','000-1016074','000-1016046','000-1016075','000-1016050','000-1016063','000-1016059','000-1016070','000-1015901','000-1015992','000-1016065','000-1015913','000-1015711','000-1015712','000-1015897','000-1015944','000-1015924','000-1015940','000-1015949','000-1015953','000-1015955','000-1015958','000-1015985','000-1015720','000-1015889','000-1016080','000-1016009','000-1002716','000-1015908','000-1015831','000-1015836','000-1015806','000-1015814','000-1015822','000-1015860','000-1016031','000-1016038','000-1015988')
		AND Contract_Main.Contract_End_Date >= '#Fiscal_Period_Start_Date#'
		AND Contract_Main.Contract_Start_Date <= '#Fiscal_Period_End_Date#'
		AND Contract_Main.Deleted = 0
		AND Contract_Main.Contract_Status_Type_IDX > 3
		ORDER BY Contract_Main.Contract_Main_ID DESC
		</cfquery>
			
	<!---GetOlBGPrograms--->
	<cfquery name="GetOldBGPrograms" datasource="#application.datasource#">
	INSERT INTO RP_Contract_Main
		(
			Contract_Main_ID, 
			Contract_Number,
			Created_Type
		)
		SELECT TOP 1 Contract_Main.Contract_Main_ID, Contract_Main.Contract_Number, 2 as Created_Type
	FROM Contract_Main
	Where Contract_Main.Contract_Number IN (<!--- '000-1002581','000-1002585','000-1002587','000-1002586' ---><!---added on May 12, 2004--->'000-1002581','000-1002585','000-1002587','000-1002586')
	AND Contract_Main.Contract_End_Date >= '#Fiscal_Period_Start_Date#'
	AND Contract_Main.Contract_Start_Date <= '#Fiscal_Period_End_Date#'
	ORDER BY Contract_Main.Contract_Main_ID DESC
	</cfquery> 
	
	 <!---GetCorpPrograms--->
	<cfquery name="GetOldCorpPrograms" datasource="#application.datasource#">
	INSERT INTO RP_Contract_Main
		(
			Contract_Main_ID, 
			Contract_Number,
			Created_Type
		)

	SELECT TOP 1 Contract_Main.Contract_Main_ID, Contract_Main.Contract_Number, 3 as Created_Type
	FROM Contract_Main
	Where Contract_Main.Contract_Number IN (<!--- '000-1014105','000-1014106','000-1014107','000-1014108','000-1014109','000-1014110','000-1014115','000-1014116','000-1014805','000-1014806','000-1014807' ---><!---Added May 12, 2004--->'000-1017009','000-1017010','000-1017006','000-1017008','000-1017060','000-1016980')
	AND Contract_Main.Contract_End_Date >= '#Fiscal_Period_Start_Date#'
	AND Contract_Main.Contract_Start_Date <= '#Fiscal_Period_End_Date#'
	ORDER BY Contract_Main.Contract_Main_ID DESC
	</cfquery> --->
	
<!--- 	<cfloop query="GetContractMainOld">
		<cfquery name="InsertContractMain" datasource="#application.datasource#">
		INSERT INTO RP_Contract_Main
		(
			Contract_Main_ID, 
			Contract_Number,
			Created_Type
		)
		VALUES
		(
			#Contract_Main_ID#, 
			'#Contract_Number#',
			'#Created_Type#'
		)
		</cfquery>
	</cfloop>
	 --->
<!--- 	<cfquery name="GetContractMainNew" datasource="#application.datasource#">
	INSERT INTO RP_Contract_Main
		(
			Contract_Main_ID, 
			Contract_Number,
			Created_Type
		)
	SELECT DISTINCT Contract_Main.Contract_Main_ID, Contract_Main.Contract_Number, 
		RP_Type.RP_Type_ID AS Created_Type
	FROM Contract_Main
		INNER JOIN Program_Rebates_Component
		ON Program_Rebates_Component.Program_ID = Contract_Main.Contract_Main_ID
		AND Program_Rebates_Component.Deleted = 0
		INNER JOIN Program_Rebates_Component_Name
		ON Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID
		INNER JOIN RP_Type
		ON RP_Type.Component_Name = Program_Rebates_Component_Name.Program_Rebates_Component_Name
		AND RP_Type.Deleted = 0		
	WHERE Contract_Main.Contract_Status_Type_IDX > 2
	AND Contract_Main.Contract_End_Date >= '#Fiscal_Period_Start_Date#'
	AND Contract_Main.Contract_Start_Date <= '#Fiscal_Period_End_Date#'
	</cfquery> --->
	
<!--- 	<cfloop query="GetContractMainNew">
		<cfquery name="InsertContractMain" datasource="#application.datasource#">
		INSERT INTO RP_Contract_Main
		(
			Contract_Main_ID, 
			Contract_Number,
			Created_Type
		)
		VALUES
		(
			#Contract_Main_ID#, 
			'#Contract_Number#',
			'#Created_Type#'
		)
		</cfquery>
	</cfloop> --->
	
	<cfquery name="GetContractMain" datasource="#application.datasource#">
	SELECT DISTINCT RP_Contract_Main.Contract_Main_ID, RP_Contract_Main.Created_Type, Contract_Main.Contract_Start_Date AS Approval_Start_Date, Contract_End_Date AS Approval_End_Date, Contract_Main.Contract_Number 
	FROM RP_Contract_Main
		INNER JOIN Contract_Main ON Contract_Main.Contract_Main_ID = RP_Contract_Main.Contract_Main_ID
	</cfquery>

	<cfloop query="GetContractMain">
	
	<cfset Program_Type = GetContractMain.Created_Type>
	
		<!---For each contract, get the dates (usually Fiscal Period, if not then start and end date -- use BB stored proc--->
<!--- 		<cfquery name="PopulateTables1" datasource="#application.datasource#">
			exec BB_D_Program_Detail
			@@A_ID = '#GetContractMain.Contract_Main_ID#'
		</cfquery>
		
		<cfquery name="GetRevisionInformation" datasource="#application.datasource#">
			SELECT DISTINCT Contract_Main_ID, Approval_Start_Date, Approval_End_Date FROM BB_Program_Info
			WHERE Contract_Number = '#GetContractMain.Contract_Number#'
			AND Approval_End_Date >= '#Fiscal_Period_Start_Date#'
			AND Approval_Start_Date <= '#Fiscal_Period_End_Date#'
			ORDER BY Approval_Start_Date
		</cfquery>
				 --->
<!--- 		<cfoutput query="GetContractMain" <!--- group="Contract_Main_ID" --->> --->
		
		<!---Contract Main--->
		<cfset ContractMainID = GetContractMain.Contract_Main_ID>
		<!---Start Date--->
			<cfif GetContractMain.Approval_Start_Date LT Fiscal_Period_Start_Date>
				<cfset SpanStartDate = Fiscal_Period_Start_Date>
			<cfelse>
				<cfset SpanStartDate = GetContractMain.Approval_Start_Date>
			</cfif>
		<!---End Date--->
			<cfif GetContractMain.Approval_End_Date GT Fiscal_Period_End_Date>
				<cfset SpanEndDate = Fiscal_Period_End_Date>
			<cfelse>
				<cfset SpanEndDate = GetContractMain.Approval_End_Date>
			</cfif>
			
			<!------ Deepa Code starts ----->

			<!---For each distributor, get invoice info (sales_dollars and off invoice)--->
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
						Record_Type,
						QBrand_ID
				)
				SELECT 	DISTINCT
						BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
						'#ContractMainID#',
						'#Contract_Number#',
						Invoice_Header.Invoice_Header_ID,
						Invoice_Detail.Invoice_Detail_ID,
						Invoice_Header.Shared_Invoice_Number,
						Invoice_Detail.Line,
						'#SpanStartDate#',
						'#SpanEndDate#',
						'#Fiscal_Period_Start_Date#',
						'#Fiscal_Period_End_Date#',
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
						'#Program_Type#' AS Program_Type,
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
						Contract_Products.Contract_Main_ID = '#ContractMainID#'
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
						<!--- INNER JOIN RP_Type
						ON (RP_Type.Component_Name = '#Program_Type#' 
						OR RP_Type.Program_Type_Name = '#Program_Type#')
						AND RP_Type.Deleted = 0

						LEFT JOIN Program_Rebates_Component_Name
						ON Program_Rebates_Component_Name.Program_Rebates_Component_Name = RP_Type.Component_Name
						LEFT JOIN Program_Control_Panel_Options
						ON Program_Control_Panel_Options.Created_Type = RP_Type.Program_Type_Name --->
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
						<!--- AND (Invoice_Header.Deleted = 0 OR Invoice_Header.Invoice_Credit_Flag = 'C') --->
						<!------ Invoice Detail ----->
						INNER JOIN Invoice_Detail
						ON Invoice_Header.Invoice_Header_ID = Invoice_Detail.Invoice_Header_ID
						<!--- AND (Invoice_Detail.Deleted = 0 OR Invoice_Header.Invoice_Credit_Flag = 'C') --->
						AND Invoice_Detail.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
						AND Invoice_Detail.Sales_Dollars IS NOT NULL
						AND ISNUMERIC(Invoice_Detail.Sales_Dollars) = 1
						<!----AND Invoice_Detail.Off_Invoice_Dollars IS NOT NULL
						AND ISNUMERIC(Invoice_Detail.Off_Invoice_Dollars) = 1---> 
				WHERE 	
						Contract_Distributors.Contract_Main_ID = #ContractMainID#
						AND Contract_Distributors.Deleted = 0
						<!--- AND (Program_Rebates_Component_Name.Program_Rebates_Component_Name IS NOT Null 
						OR Program_Control_Panel_Options.Created_Type IS NOT NULL) --->
						
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
						Invoice_Detail.Line,
						Invoice_Detail.Sales_Dollars, 
						Invoice_Detail.Off_Invoice_Dollars,
						Distributor_Customer_ID.CustID,
						Distributor_Family.Family,
						Distributor_Family.Family_Name
						<!--- , 
						Program_Rebates_Component_Name.Program_Rebates_Component_Name  --->
			</cfquery>
				
			<!--- 	
			<!---Get billback information--->
			<cfquery name="GetBillbacks" datasource="#application.datasource#">
				INSERT INTO RP_Billback_Table
				(
						Fiscal_Period_Start_Date,
						Fiscal_Period_End_Date, 
						Legacy_Ship_To,
						Shared_Ship_To, 
						Distributor_ID,
						Product_ID,
						Contract_Main_ID,
						QBrand_ID,
						Item_Number,
						UPC,
						Billed_Back,
						BB_Summary_Type
				)
				SELECT 	DISTINCT
						'#Fiscal_Period_Start_Date#',
						'#Fiscal_Period_End_Date#', 
						BSA_Foodservice_Customers.Ship_To AS Legacy_Ship_To,
						BSA_Foodservice_Customers.Shr_Ship_To AS Shared_Ship_To,
						BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
						'#ContractMainID#',
						Q_Brand_Desc.Q_Brand_Legacy,
						BSA_Foodservice_Items_Master.Item,
						BSA_Foodservice_Items_Master.UPC,
						BB_Item_Final.Item_Total_Paid,
						#Program_Type#							
				FROM 	Billback
						INNER JOIN BB_Approved
						ON BB_Approved.Billback_ID = Billback.Billback_ID 
						AND BB_Approved.Date_Approved BETWEEN '#Fiscal_Period_Start_Date#' AND '#Fiscal_Period_End_Date#'
						INNER JOIN Billback_Program
						ON Billback_Program.Billback_ID = Billback.Billback_ID
						AND Billback_Program.Program_ID = '#ContractMainID#'
						AND Billback_Program.Deleted = 0
						<!------ Distributors ----->
						INNER JOIN Contract_Distributors
						ON
						Contract_Distributors.Contract_Main_ID = #ContractMainID#
						AND Contract_Distributors.Deleted = 0
						INNER JOIN BSA_Foodservice_Customers
						ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
						AND BSA_Foodservice_Customers.Deleted = 0
						INNER JOIN Billback_Distributor
						ON Billback_Distributor.Distributor_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
						AND Billback_Distributor.Billback_ID = Billback.Billback_ID 
						AND Billback_Distributor.Deleted = 0
						<!------ Products ----->
						INNER JOIN Contract_Products
						ON
						Contract_Products.Contract_Main_ID = '#ContractMainID#'
						AND
						Contract_Products.Deleted = 0
						INNER JOIN Program_Rebates_Product_Data
						ON
						Program_Rebates_Product_Data.Deleted = 0
						AND
						Program_Rebates_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
						INNER JOIN Program_Rebates_Component_Data
						ON
						Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID
						AND
						Program_Rebates_Component_Data.Unit_of_Measure_ID = 3
						AND
						Program_Rebates_Product_Data.Deleted = 0							
						INNER JOIN BSA_Foodservice_Items_Master
						ON 
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
						AND
						BSA_Foodservice_Items_Master.Deleted = 0
						INNER JOIN Line_Of_Business
						ON Line_Of_Business.Line_Of_Business_ID = BSA_Foodservice_Items_Master.Line_of_Business_ID
						AND Line_Of_Business.Deleted = 0
						INNER JOIN Product_Q_Brand_Desc
						ON Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
						AND Product_Q_Brand_Desc.Deleted = 0
						AND Product_Q_Brand_Desc.LOB = Line_Of_Business.Line_Of_Business
						INNER JOIN Q_Brand_Desc 
						ON Q_Brand_Desc.Q_Brand_ID = Product_Q_Brand_Desc.Q_Brand_ID 
						INNER JOIN Billback_Product
						ON Billback_Product.Billback_ID = Billback.Billback_ID
						AND Billback_Product.Product_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
						AND Billback_Product.Deleted = 0
						INNER JOIN BB_Item_Final
						ON BB_Item_Final.Billback_ID = Billback.Billback_ID
						AND BB_Item_Final.Billback_Product_ID = Billback_Product.Billback_Product_ID
						AND BB_Item_Final.Billback_Program_ID = Billback_Program.Billback_Program_ID
						AND BB_Item_Final.Deleted = 0
			WHERE 
						Billback.Deleted = 0
						AND BB_Item_Final.Item_Total_Paid > 0
			
			GROUP BY 	
						BSA_Foodservice_Customers.Ship_To,
						BSA_Foodservice_Customers.Shr_Ship_To,
						BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
						Q_Brand_Desc.Q_Brand_Legacy,
						BSA_Foodservice_Items_Master.Item,
						BSA_Foodservice_Items_Master.UPC,
						BB_Item_Final.Item_Total_Paid
			</cfquery> --->
			
			<!------ Deepa Code ends ----->
			
			
		<!---For each revision of the program--->
	<!--- 	</cfoutput> --->
	<!---Original contract main--->
	</cfloop>
Done.
<cfabort>
<!-----<cfquery name="TotalEarn" datasource="#application.datasource#">
SELECT * FROM RP_Mapping_Table
</cfquery>

 <cfdump var="#TotalEarn#"> --->

<!---  <cftransaction action="Commit">
<cfabort>  --->
<cfquery name="TotalBB" datasource="#application.datasource#">
<!--- SELECT * FROM RP_Mapping_Table --->
SELECT * FROM RP_Billback_Table
</cfquery>

<!----Build directory structure--->
<cfif DirectoryExists("#Application.Doc_Path#\data_files\created\ReportWriter\Fiscal_Period_Reports\flatfile\#FilePath#") IS FALSE>
	<cfdirectory action="create" directory="#Application.Doc_Path#\data_files\created\ReportWriter\Fiscal_Period_Reports\flatfile\#FilePath#">
</cfif>

<cfif DirectoryExists("#Application.Doc_Path#\data_files\created\ReportWriter\Fiscal_Period_Reports\report\#FilePath#") IS FALSE>
	<cfdirectory action="create" directory="#Application.Doc_Path#\data_files\created\ReportWriter\Fiscal_Period_Reports\report\#FilePath#">
</cfif>

<!---Start including sub reports--->

	<!---Payment_Report_Summary--->
	<cfinclude template="Payment_Report_Summary.cfm">
	
	<!---Invoice_Summary--->
	<cfinclude template="Invoice_Summary.cfm">
	
	<!---Invoice_Detail--->
	<cfinclude template="Invoice_Detail.cfm">
	
	<!---Billback_Summary--->
	<cfinclude template="billback_mapping.cfm">
	
	<!---Distributor Summary--->
	<cfinclude template="distributor_Summary.cfm">
	
	<!---Create Reports--->
	<cfinclude template="create_reports.cfm">
	
	<!---Delete everything--->
	<!--- <cfinclude template="garbage_collection.cfm">  --->

<cfelse>
This report was written specifically for BSA Foodservices, and is ineligble to be run by any other client.
</cfif>
