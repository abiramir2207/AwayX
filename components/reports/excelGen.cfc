<cfcomponent displayname="ExcelGen" hint="this is the class for the excel Generator Report">
	<!--- declare properties --->
	<cfset variables.claimProductDetail = "" />
	<cfset variables.claimDetail = "" /> <!---include product details, fees and growth--->
	<cfset variables.reportHeader = "" />
	<cfset variables.reportCaption = "" />
	<cfset variables.mappedReportHeader = "" />

	<!--- init --->
	<cffunction name="init" access="public" returntype="ExcelGen" output="false">
		<cfargument name="claimStatus" type="string" required="true" />
		<cfset var thisHeader = "Sold To##,Sold To Name,Operator ##,Operator Name,Program ID,Program Name,Item Number,Item Description,Item Paid Volume (CS),Item Paid $,Billback Date,Claim Start Date,Claim End Date,Check ##,Vendor ##,Vendor Name,Status,Division,Region,Territory,Postmark Date,Receipt Date,Entry Date,Transaction Date" />
		<cfset var mappedHeader = "Sold_To_Number,Sold_To_Name,Operator_ID,Operator_Name,Program_ID,Program_Name,Item_Number,Description,Item_Approved_Volume,Paid_Amount,Billback_Date,Claim_Start_Date,Claim_End_Date,Check_Number,VendorID,VendorName,Status,Division,Region,Territory,Postmark_Date,Receipt_Date,Billback_Date,Transaction_Date" />
		<cfset var thisCaption = "Excel Claim Summary" />
		<cfset this.addReportHeader(thisHeader) />
		<cfset this.addReportCaption(thisCaption) />
		<cfset this.addMappedReportHeader(mappedHeader) />
		<cfset this.addClaimDetail(arguments.claimStatus) />
		<!---<cfset this.addClaimProductDetail(arguments.claimStatus) />--->
		<cfreturn this />
	</cffunction>
	<!--- getter --->
	<cffunction name="getClaimProductDetail" returntype="query" access="public" output="false">
		<cfreturn  variables.claimProductDetail/>
	</cffunction>
	<cffunction name="getClaimDetail" returntype="query" access="public" output="false">
		<cfreturn  variables.claimDetail/>
	</cffunction>
	<cffunction name="getReportHeader" returntype="string" access="public" output="false">
		<cfreturn  variables.reportHeader/>
	</cffunction>
	<cffunction name="getMappedReportHeader" returntype="string" access="public" output="false">
		<cfreturn  variables.mappedReportHeader/>
	</cffunction>
	<cffunction name="getReportCaption" returntype="string" access="public" output="false">
		<cfreturn  variables.reportCaption/>
	</cffunction>
	<!--- setter --->
	<cffunction name="setClaimProductDetail" returntype="void" access="private" output="false">
		<cfargument name="claimProductDetail" type="query" required="true" />
		<cfset variables.claimProductDetail = arguments.claimProductDetail />
	</cffunction>
	<cffunction name="setClaimDetail" returntype="void" access="private" output="false">
		<cfargument name="claimDetail" type="query" required="true" />
		<cfset variables.claimDetail = arguments.claimDetail />
	</cffunction>
	<cffunction name="setReportHeader" returntype="void" access="private" output="false">
		<cfargument name="reportHeader" type="string" required="true" />
		<cfset variables.reportHeader = arguments.reportHeader />
	</cffunction>
	<cffunction name="setMappedReportHeader" returntype="void" access="private" output="false">
		<cfargument name="mappedReportHeader" type="string" required="true" />
		<cfset variables.mappedReportHeader = arguments.mappedReportHeader />
	</cffunction>
	<cffunction name="setReportCaption" returntype="void" access="public" output="false">
		<cfargument name="reportCaption" type="string" required="true" />
		<cfset variables.reportCaption = arguments.reportCaption />
	</cffunction>
	<!--- methods --->
	<cffunction name="addReportCaption" access="public" returntype="void" output="true">
		<cfargument name="reportCaption" type="string" required="true" />
		<cfset setReportCaption(arguments.reportCaption) />
	</cffunction>
	<cffunction name="addReportHeader" access="public" returntype="void" output="true">
		<cfargument name="reportHeader" type="string" required="true" />
		<cfset setReportHeader(arguments.reportHeader) />
	</cffunction>
	<cffunction name="addMappedReportHeader" access="public" returntype="void" output="true">
		<cfargument name="mappedReportHeader" type="string" required="true" />
		<cfset setMappedReportHeader(arguments.mappedReportHeader) />
	</cffunction>
	<cffunction name="addClaimDetail" access="public" returntype="void" output="true">
		<cfargument name="claimStatus" type="string" required="true" />
		<cfstoredproc procedure="Excel_Claim_Gen_SP"
   					dataSource = "#application.datasource#"
  					 returnCode = "No">
		<CFQUERY NAME="qryGetClaimDetail" DATASOURCE="#application.datasource#">
			select distinct *
			from Excel_Claim_Gen
			where Billback_Status_ID in (#arguments.claimStatus#)
			order by Billback_ID,Program_ID,Item_Number
		</CFQUERY>
		<cfset setClaimDetail(qryGetClaimDetail) />
	</cffunction>
	<cffunction name="addClaimProductDetail" access="public" returntype="void" output="true">
		<cfargument name="claimStatus" type="string" required="true" />
		<CFQUERY NAME="qryGetClaimProductDetail" DATASOURCE="#application.datasource#">
			select distinct
				--- billback information 
				Billback.Billback_ID,
				Billback.BB_Code AS claimNo, 
				Billback.Check_Number AS Check_Number, 
				Billback_Status.BB_Status_Description AS Status,
				Billback.Billback_Status_ID,
				Billback.BB_Start_Date AS Claim_Start_Date,
				Billback.BB_End_Date AS Claim_End_Date,
				Billback.Postmark_Date AS Postmark_Date,
				Billback.BB_Date AS Billback_Date,
				Billback.BB_Received_Date AS Receipt_Date,
				Billback.Created_Date AS Transaction_Date,
				---- contract/program information
				CASE WHEN Program_ID IS NULL THEN Billback_Program.BB_Program_Title ELSE Contract_Main.Contract_Title END AS Program_Name,
				CASE WHEN Program_ID IS NULL THEN Billback_Program.BB_Program_Number ELSE Contract_Main.Contract_Number END AS Program_ID,
				---- customer information
				BSA_FoodService_Customers.Name as Sold_To_Name,
				BSA_FoodService_Customers.Shr_Ship_To as Sold_To_Number,
				---- items information
				CASE WHEN Product_ID IS NULL THEN Billback_Product.BB_Unknown_Product_Item_Number ELSE BSA_Foodservice_Items_Master.Item END AS Item_Number,
				CASE WHEN Product_ID IS NULL THEN Billback_Product.BB_Unknown_Product_Description ELSE BSA_Foodservice_Items_Master.Description END AS Description,			
				---- operator information
				ISNull(BSA_operator.operator_name, 'Unknown Operator Name') AS Operator_Name, 
					ISNull(BSA_operator.Eshark_RecordID, 'Unknown') AS Operator_ID,
				---- vendor information 	
				isnull(vendor_dist_oper.Vendor_ID, 'Unknown') AS VendorID,
				isnull(vendor_master.vendor_name, 'Unknown') As VendorName,
				---geography information
				Service_Zones.Zone_Name AS Division,
				Service_Regions.Region_Name AS Region, 
				Service_Markets.Market_Name AS Territory,
				---other information
				Billback_Program.Billback_Program_ID, 
				Billback_Product.Billback_Product_ID, 
				BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
				(
					select isnull(sum(Item_Total_Paid), 0) as Item_Paid_Amount
					from bb_item_final
					where bb_item_final.billback_id = billback.billback_id
					and bb_item_final.billback_program_id = Billback_program.billback_program_id
					and bb_item_final.billback_product_id = billback_product.billback_product_id
					and bb_item_final.deleted = 0
					group by billback_id, billback_program_id, billback_product_id
				) as Paid_Amount,
				isnull(bb_item_final.item_volume_paid_cs, 0) as Item_Approved_Volume
			FROM Billback
			INNER JOIN (Billback_Program 
					LEFT JOIN  	Contract_Main 
							ON 	Billback_Program.Program_ID = Contract_Main.Contract_Main_ID 
							and contract_main.deleted = 0
					LEFT JOIN   Contract_Operators
							ON  Contract_Operators.Contract_Main_ID = Contract_Main.Contract_Main_ID
							And Contract_Operators.Deleted = 0
					left JOIN BSA_Operator		
							ON  BSA_Operator.BSA_Operator_ID = Contract_Operators.BSA_Operator_ID
							and BSA_Operator.Deleted = 0
						)
					ON 	Billback_Program.Billback_ID = Billback.Billback_ID
					AND Billback_Program.Deleted = 0
			LEFT JOIN  BB_Approved
				ON BB_Approved.Billback_ID = Billback.Billback_ID
			LEFT JOIN  Billback_Status
				ON Billback.Billback_Status_ID = Billback_Status.Billback_Status_ID
			LEFT JOIN  vendor_dist_oper
				ON BB_Approved.Vendor_Dist_Oper_ID = vendor_dist_oper.Vendor_Dist_Oper_ID
			Left Join Vendor_Master
				on Vendor_Master.vendor_id = vendor_dist_oper.vendor_id
			LEFT JOIN  (Billback_Product
					LEFT JOIN   BSA_Foodservice_Items_Master
							ON  BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID=Billback_Product.Product_ID 
							AND BSA_Foodservice_Items_Master.Deleted = 0
					LEFT JOIN   Units_of_Measure
							ON  Units_of_Measure.Unit_Of_Measure_ID = Billback_Product.BB_Product_UOM
					RIGHT JOIN  Billback_Product_Detail
							ON  Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID
							AND Billback_Product_Detail.Deleted = 0
							AND Billback_Product_Detail.BB_Rate IS NOT NULL
							AND LEN(RTRIM(Billback_Product_Detail.BB_Rate)) > 0
							AND ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1
							AND CAST(Billback_Product_Detail.BB_Rate AS Float) > 0	
					)
				ON 	Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID
				AND Billback_Product.Deleted = 0	
			LEFT JOIN (	Billback_Distributor
					LEFT JOIN  BSA_Foodservice_Customers
						ON Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
				  )
				ON  Billback_Distributor.Billback_ID = Billback.Billback_ID
				AND Billback.Billback_Payee_Type_ID = 1
				 AND Billback_Distributor.Deleted = 0	
			Left JOIN  BB_Item_Final
				ON  Billback_Program.Billback_Program_ID = BB_Item_Final.Billback_Program_ID 
				AND Billback_Product.Billback_Product_ID = BB_Item_Final.Billback_Product_ID
				AND BB_Item_Final.Billback_ID = Billback.Billback_ID
			LEFT JOIN BB_Item_Final_Detail
				ON 
				(
					BB_Item_Final_Detail.BB_Item_Final_ID = BB_Item_Final.BB_Item_Final_ID
					AND BB_Item_Final_Detail.Deleted = 0
					AND BB_Item_Final_Detail.BB_Product_Type = Billback_Product_Detail.BB_Product_Type_ID
				)
			Left join dbo.BSA_Foodservice_Brokers
				ON  BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID 		
			Left JOIN  Service_Markets 
				ON  BSA_Foodservice_Brokers.Service_Market_ID = Service_Markets.Service_Market_ID
			Left JOIN  Service_Regions 
				ON  BSA_Foodservice_Brokers.Service_Region_ID = Service_Regions.Service_Region_ID 
			Left JOIN  Service_Zones 
				ON  Service_Regions.Service_Zone_ID = Service_Zones.Service_Zone_ID 	
			WHERE Billback.Billback_Status_ID in (#arguments.claimStatus#)	
			order by Sold_To_Number	
		</CFQUERY>
		<cfset setClaimProductDetail(qryGetClaimProductDetail) />
	</cffunction>
</cfcomponent>