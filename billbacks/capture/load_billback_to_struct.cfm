
<CFSET Billback 										= "">
<CFSET Billback 										= StructNew()>
<CFSET Billback.LoadedFromDB							= 1>
<CFSET Billback.Billback_ID 							= "">
<CFSET Billback.Scheduled_Auto_BB						= "0">
<CFSET Billback.List_Of_Programs 						= "">
<CFSET Billback.Products_On_Billback_Program 			= "">
<CFSET Billback.Programs 								= StructNew()>
<CFSET Billback.Programs.Discount_List					= "">
<CFSET Billback.Programs.Count							= 0>
<CFSET Billback.Programs.Unknown_Program_On_Billback	= 0>
<cfif Not isDefined("billbackProgramManager") >
	<cfset billbackProgramManager = CreateObject("component", "components.billback.Programs.BillbackProgramsManager").init() />
</cfif>

<!--- load billback id into struct --->
<CFSET Billback.Billback_ID = LoadBillbackID>

<!------ Get The Distributor ID ----->
<cfset BillbackDeviationManager = CreateObject("component", "components.billback.BillbackDeviationManager").init() />
<cfset BillbackPayeeType = BillbackDeviationManager.getBillbackPayeeType(Billback.Billback_ID) />
<!--- <cfset qDistributor = BillbackDeviationManager.getBillbackDistributor(Billback.Billback_ID, BillbackPayeeType) />
<cfset distributorId = qDistributor.BSA_Foodservice_Customers_ID /> --->


<!--- preload billback programs --->
<cfset getBillbackPrograms = billbackProgramManager.getBillbackPrograms(Billback.Billback_ID) />

<!--- <cfdump var="#getBillbackPrograms#"> --->
<!--- load programs into billback  --->
<cfloop query="getBillbackPrograms">

	<CFSET Billback.Programs.Count 									= Billback.Programs.Count + 1>
	<CFSET "Billback.Programs.Program_#Billback.Programs.Count#" 	= StructNew()>
	<CFSET Program 													= evaluate("Billback.Programs.Program_#Billback.Programs.Count#")>
	<CFSET Program.Count_ID 										= Billback.Programs.Count>
	<CFSET Program.Discount_List									= getBillbackPrograms.Discount_List>
	<CFSET Program.Products 										= StructNew()>
	<CFSET Program.Products.Count 									= 0>
	<CFSET Program.Products_Not_On_Program 							= 0>
	<CFSET Program.Products_On_Program 								= 0>
	<CFSET Program.Products_Unknown	 								= 0>	
	<CFSET Program.Lump_Sums 										= StructNew()>
	<CFSET Program.Lump_Sums.Count 									= 0>
	<CFSET Program.Rebate 											= StructNew()>
	<CFSET Program.Rebate.Count 									= 0>
	<CFSET Program.Billback_Program_ID 								= getBillbackPrograms.Billback_Program_ID>	
	<CFSET Billback.Scheduled_Auto_BB								= getBillbackPrograms.Scheduled_Auto_BB>
	<CFSET ListOfProductOnThisProgram 								= "">
	<CFSET Program.Program_ID										= getBillbackPrograms.Program_ID>
	<!--- unknown program type --->
	<CFIF len(Program_ID) EQ 0>
		<CFSET Billback.Programs.Unknown_Program_On_Billback 		= Billback.Programs.Unknown_Program_On_Billback + 1>
		<CFSET Program.Program_Type_ID						 		= 2>
		<CFSET Program.Program_Number						 		= getBillbackPrograms.BB_Program_Number>
		<CFSET Program.Program_Title						 		= getBillbackPrograms.BB_Program_Title>
		<CFSET Program.Program_Notes						 		= getBillbackPrograms.BB_Program_Notes>
	<CFELSE>	
		<CFSET Program.Program_Type_ID								= 1>
		<CFSET Billback.List_Of_Programs 							= listappend(Billback.List_Of_Programs, Program.Program_ID)>
		<cfset FORM.Type_Group_Desc_ID 	= 0>
		<cfset FORM.Type_Code_Desc_ID 	= 0>
		<cfset FORM.Q_Brand_ID 			= 0>
		<cfset FORM.Line_Of_Biz 		= 0>
		<cfset FORM.Brand_ID 			= 0>
		<cfset FORM.Line_Of_Biz 		= 0>
		<cfset FORM.Product_Status 		= 0>
		<cfset FORM.Description_String 	= "">
		<cfset FORM.item_number 		= "">
		<cfset FORM.upc_number 			= "">
		<cfset SHOW_INVOICE_FILTER 		= 0>
		<cfset getLOBCharacter.Line_Of_Business = "">
		<cfset FORM.Rebate_Type_Search_ID = 0>
		<cfset form.program_id			= Program.Program_ID>
		<cfset appSettings = application.appSettingsGet>
		<cfset stStruct = Form>
		<cfset stStruct.appSettings = appSettings>
		<cfset productManager = CreateObject("component", "components.products.ProductManager").init()>
		<cfset getListOfProgramProducts = productManager.search(stStruct)>
		<!---put in request scope so program form does not have to call this again productManager.search()--->
		<cfset request.getProgramProducts =getListOfProgramProducts>
		<CFSET ListOfProductOnThisProgram = valuelist(getListOfProgramProducts.BSA_Foodservice_Items_Master_ID)>
	</CFIF>

	<!--- <CFSET ShowProductsInGroupLevel = 0>
	<CFIF Display_Product_Hierarchy EQ 1> --->
		<CFSET ShowProductsInGroupLevel = Display_Product_Hierarchy>
	<!--- </cfif> --->
	
	<cfset getProductsForBBProgram = billbackProgramManager.getProductsForBBProgram(Billback.Billback_ID,Program.Billback_Program_ID,Display_Product_Hierarchy) />
	
	
<!--- 	<CFIF Display_Product_Hierarchy EQ 1>
		<CFSET ShowProductsInGroupLevel = 1>
		<CFQUERY NAME="getProductsForBBProgram" DATASOURCE="#Application.Datasource#">
			SELECT	DISTINCT 	
					Billback_Product.Product_Hierarchy_ID Billback_Product_ID,
					Billback_Product.Product_Hierarchy_ID Product_ID,
					Product_Type_ID,
					BB_Product_UOM,
					sum(cast(BB_Product_Quantity as float)) as BB_Product_Quantity,
					Product_Hierarchy.Product_Hierarchy_Name
			FROM 	Billback_Product 
			LEFT JOIN 	Product_Hierarchy ON Product_Hierarchy.Product_Hierarchy_ID = Billback_Product.Product_Hierarchy_ID
			WHERE 	Billback_ID = '#Billback.Billback_ID#' AND 
					Billback_Program_ID = '#Program.Billback_Program_ID#' AND
					Billback_Product.Deleted = 0
					AND Product_Hierarchy.Deleted = 0
			group by	Billback_Product.Product_Hierarchy_ID,
				 	BB_Product_UOM,
					Product_Type_ID,Product_Hierarchy.Product_Hierarchy_Name
			order by Product_Hierarchy.Product_Hierarchy_Name
		</CFQUERY>
	<CFELSE>
		<!--- begin loading products --->
		<cfquery name="getProductsForBBProgram" datasource="#Application.Datasource#">
			SELECT *
			FROM 	Billback_Product
			WHERE	Billback_ID 		= '#Billback.Billback_ID#'
			AND		Billback_Program_ID = '#Program.Billback_Program_ID#'
			AND		Deleted 			= 0
		</cfquery>
	</CFIF> --->
	<CFSET ThisProductCollection = Program.Products>
	<cfloop query="getProductsForBBProgram">
		<CFSET ThisProductCollection.Count = ThisProductCollection.Count + 1>
		<CFSET "ThisProductCollection.Product_#ThisProductCollection.Count#" = StructNew()>
		<CFSET Product = evaluate("ThisProductCollection.Product_#ThisProductCollection.Count#")>
		<cfparam name="Product.Distributor_ID_Earned" default="00000000-0000-0000-0000-000000000000">
		<CFSET Product.Count_ID 	 			= ThisProductCollection.Count>
		<CFSET Product.Product_ID 	 			= getProductsForBBProgram.Product_ID>
		<CFSET Product.Billback_Product_ID 	 	= getProductsForBBProgram.Billback_Product_ID>
		<CFSET Product.Product_Type_ID 	 		= getProductsForBBProgram.Product_Type_ID>
		<cfif ShowProductsInGroupLevel>
			<CFSET Product.Group		 	 		= getProductsForBBProgram.Product_Group>
			<CFSET Product.Group_ID		 	 		= getProductsForBBProgram.Product_Group_ID>
			<CFSET Product.Product_Hierarchy		= getProductsForBBProgram.Product_Hierarchy>
		</cfif>
		<CFSET Product.BB_Product_Type_ID 	 	= 0>

		<CFSET Product.Volume 		 			= getProductsForBBProgram.BB_Product_Quantity>
		<CFSET Product.Volume_UOM 	 			= getProductsForBBProgram.BB_Product_UOM>
		<cfif trim(getProductsForBBProgram.Distributor_ID_Earned) eq "">
			<CFSET Product.Distributor_ID_Earned	= "00000000-0000-0000-0000-000000000000">
		<cfelse>
			<CFSET Product.Distributor_ID_Earned	= getProductsForBBProgram.Distributor_ID_Earned>
		</cfif>
		<CFSET Product.Ship_To	= getProductsForBBProgram.Ship_To />
			<!--- used to sort the struct in program_form.cfm >> sort by distributor and product--->
		
		<cfif ShowProductsInGroupLevel>
			<CFSET Product.Sort = Product.Ship_To &  "|" & getProductsForBBProgram.Product_Hierarchy & "|" & getProductsForBBProgram.Product_ID>
			<CFSET Product.Sales_Dollars 	 		= getProductsForBBProgram.Sales_Dollars>
			<CFSET Product.Discount_Offered 	 	= getProductsForBBProgram.Discount_Offered>
			<CFSET Product.Discount_UOM 	 		= getProductsForBBProgram.Discount_UOM>
		<cfelse>
			<CFSET Product.Sort = Product.Ship_To &  "|" & getProductsForBBProgram.Item>
		</cfif>
		
		<CFSET Product.Rate_Fixed	 	= "">
		<CFSET Product.Rate_Rebate	 	= "">
		<CFSET Product.Rate_Lump_Sum 	= "">
		<CFSET Product.Rate_Growth 	 	= "">
		<CFSET Product.Rate_Formula  	= "">
		<CFSET Product.Rate_BidRequest  = "">
		<CFSET Product.Rate_ClaimAdjust = "">
		
		<CFSET Product.Rate_Fixed_Show	 	= 0>
		<CFSET Product.Rate_Rebate_Show		= 0>
		<CFSET Product.Rate_Lump_Sum_Show 	= 0>
		<CFSET Product.Rate_Growth_Show 	= 0>
		<CFSET Product.Rate_Formula_Show 	= 0>
		<CFSET Product.Rate_BidRequest_Show 	= 0>
		<CFSET Product.Rate_ClaimAdjust_Show 	= 1>
	
		<!--- unknown product --->
		<CFIF len(Product.Product_ID) EQ 0>
			<CFSET Product.Description 		= getProductsForBBProgram.BB_Unknown_Product_Description>
			<CFSET Product.Item_Number 		= getProductsForBBProgram.BB_Unknown_Product_Item_Number>
			<CFSET Product.Notes 			= getProductsForBBProgram.BB_Unknown_Product_Notes>
			<CFSET Program.PRODUCTS_UNKNOWN = Program.PRODUCTS_UNKNOWN + 1>
		<!--- known product --->
		<CFELSE>
			<cfset tmpprodCust = getProductsForBBProgram.Product_ID & "|" & getProductsForBBProgram.distributor_id_earned>
			<CFSET Billback.Products_On_Billback_Program 			= listappend(Billback.Products_On_Billback_Program, getProductsForBBProgram.Product_ID)><!--- getProductsForBBProgram.Product_ID --->

			<CFIF ShowProductsInGroupLevel EQ 1>
				<CFSET Program.PRODUCTS_ON_PROGRAM 		= getProductsForBBProgram.RecordCount>
			<CFELSEIF listfind(ListOfProductOnThisProgram, getProductsForBBProgram.Product_ID) GT 0>
				<CFSET Program.PRODUCTS_ON_PROGRAM 		= Program.PRODUCTS_ON_PROGRAM + 1>
			<CFELSE>
				<CFSET Program.PRODUCTS_NOT_ON_PROGRAM 	= Program.PRODUCTS_NOT_ON_PROGRAM + 1>
			</CFIF>
		</CFIF>
		
		<CFIF Product.Product_Type_ID EQ 3>
			<CFSET Program.Products_Unknown = Program.Products_Unknown + 1>
		</CFIF>

		<!--- <cfif len(trim(Product.Product_ID)) GT 0 and Not ShowProductsInGroupLevel>
			<!--- rate border color code --->
			<!--- <cfquery name="getProgramProducts" datasource="#application.datasource#">
				declare @program_revision_detail table
				(
				Contract_Main_ID Int, 
				Contract_Number NVARCHAR(50), 
				Approval_Start_Date datetime, 
				Approval_End_Date datetime, 
				Total_Number_Of_Days Int, 
				Check_Type_ID Int, 
				ProgramType_id Int
				)
				<cfif len(trim(Program.Program_ID)) NEQ 0 AND trim(Program.Program_ID) NEQ 0>
				insert into @program_revision_detail (Contract_Main_ID, Contract_Number, Approval_Start_Date, Approval_End_Date, Total_Number_Of_Days, Check_Type_ID, ProgramType_id)
				select	Contract_Main_ID, Contract_Number, Approval_Start_Date, Approval_End_Date, Total_Number_Of_Days, Check_Type_ID, ProgramType_id
				from	dbo.udf_program_revision_detail(#Program.Program_ID#)
				ORDER By Contract_Main_ID
				</cfif>
		
				SELECT     		BB_Program_Revisions.Contract_Number, Contract_Products.BSA_Foodservice_Items_Master_ID, 
								Contract_Products.Product_Type_ID, BB_Program_Revisions.Approval_Start_Date, BB_Program_Revisions.Approval_End_Date
				FROM         	@program_revision_detail BB_Program_Revisions
				INNER JOIN		Contract_Products 
				ON 				BB_Program_Revisions.Contract_Main_ID = Contract_Products.Contract_Main_ID
				WHERE     		Contract_Products.Deleted = 0
				AND				Contract_Products.BSA_Foodservice_Items_Master_ID = '#Product.Product_ID#'
				AND				BB_Program_Revisions.Approval_Start_Date <= #createodbcdatetime(getBillbackPrograms.BB_End_Date)#
				ORDER BY 		BB_Program_Revisions.Approval_End_Date				
			</cfquery>
	
			<cfset rate_type_list = valuelist(getProgramProducts.Product_Type_ID)>
			<cfif listfind(rate_type_list, 1) NEQ 0>
				<!--- Fixed Price --->
				<CFSET Product.Rate_Fixed_Show	 	= 1>
			</cfif>
			<cfif listfind(rate_type_list, 2) NEQ 0>
				<!--- Rebate --->
				<CFSET Product.Rate_Rebate_Show	 	= 1>
			</cfif>
			<cfif listfind(rate_type_list, 3) NEQ 0>
				<!--- Lump Sum --->
				<CFSET Product.Rate_Lump_Sum_Show	= 1>
			</cfif>
			<cfif listfind(rate_type_list, 4) NEQ 0>
				<!--- Growth --->
				<CFSET Product.Rate_Growth_Show	 	= 1>
			</cfif>
			<cfif listfind(rate_type_list, 5) NEQ 0>
				<!--- Fromula Pricing --->
				<CFSET Product.Rate_Formula_Show	= 1>
			</cfif>
			<cfif listfind(rate_type_list, 10) NEQ 0>
				<!--- BidRequest --->
				<!------ discount_type = 10 is bid request in programs, but as claim adjustment already used up the id 10 in billback,
				bid request has an id of 11 in billback, but when looking at program tables we have to keep using 10 ----->
				<CFSET Product.Rate_BidRequest_Show	= 1>
			</cfif> --->
			<!--- rate border color code END--->
		</cfif> --->
		
		<CFIF ShowProductsInGroupLevel EQ 1>
			<CFQUERY NAME="getRateInfo" DATASOURCE="#Application.Datasource#">
				SELECT 		DISTINCT 	
							sum(cast(BB_Rate as float)) as bb_rate,
							BB_Product_Type_ID
							<cfif Billback.Scheduled_Auto_BB>,sum(Billback_Product_Detail.volume) as Volume</cfif>
				FROM 		Billback_Product 
				INNER JOIN 	Billback_Product_Detail 
							ON Billback_Product_Detail.Billback_ID = Billback_Product.Billback_ID 
							and Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID
				WHERE 		Billback_Product.Billback_ID = '#Billback.Billback_ID#' AND
							Billback_Program_ID = '#Program.Billback_Program_ID#' AND
							Product_Hierarchy_ID = '#Product.Billback_Product_ID#' AND
							--(Discount_Offered = '#Product.Discount_Offered#' or BB_Product_Type_ID = '3') AND
							Billback_Product.Deleted = 0 AND 
							Billback_Product_Detail.Deleted = 0 AND
							CASE
							WHEN Earned_From_Group = 0	THEN
							Billback_Product_Detail.Distributor_ID_Earned
							ELSE
							Billback_Product_Detail.Customer_Group_ID
							END 
							 = '#Product.Distributor_ID_Earned#'
							 AND BB_Rate is not Null
				group by Billback_Product_Detail.BB_Product_Type_ID
			</CFQUERY>
		<CFELSE>
			<cfquery name="getRateInfo" datasource="#Application.Datasource#">
				SELECT *
				FROM 
						Billback_Product_Detail
				WHERE
						Billback_ID 		= '#Billback.Billback_ID#'
						AND
						Billback_Product_ID = '#Product.Billback_Product_ID#'
						AND
						Deleted 			= 0
						AND
						CASE
						WHEN Earned_From_Group = 0	THEN
							Billback_Product_Detail.Distributor_ID_Earned
						ELSE
							Billback_Product_Detail.Customer_Group_ID
						END 
						= '#Product.Distributor_ID_Earned#'
						AND BB_Rate is not Null 
			</cfquery>		
		</CFIF>
		<cfloop query="getRateInfo">
			<!--- SET RATES --->
			<CFSET tempBBRate = getRateInfo.BB_Rate>
			
			<cfswitch expression="#getRateInfo.BB_Product_Type_ID#">
				<!--- fixed --->
				<cfcase value="1">
					<CFSET Product.RATE_FIXED = tempBBRate>
					<CFSET Product.BB_Product_Type_ID = "#getRateInfo.BB_Product_Type_ID#">
						<!---for group level prods, we need to set the color of the display box--->
						<CFIF ShowProductsInGroupLevel EQ 1><CFSET Product.Rate_Fixed_Show	 	= 1></CFIF>
				</cfcase>
				<!--- rebate --->
				<cfcase value="2">
					<CFSET Product.RATE_Rebate = tempBBRate>
					<CFSET Product.BB_Product_Type_ID = "#getRateInfo.BB_Product_Type_ID#">
						<!---for group level prods, we need to set the color of the display box--->
						<CFIF ShowProductsInGroupLevel EQ 1><CFSET Product.Rate_Rebate_Show	 	= 1></CFIF>
				</cfcase>
				<!--- lump --->
				<cfcase value="3">
					<CFSET Product.RATE_Lump_Sum = tempBBRate>
					<CFSET Product.BB_Product_Type_ID = "#getRateInfo.BB_Product_Type_ID#">
						<!---for group level prods, we need to set the color of the display box--->
						<CFIF ShowProductsInGroupLevel EQ 1><CFSET Product.Rate_Lump_Sum_Show	 	= 1></CFIF>
				</cfcase>
				<!--- growth --->
				<cfcase value="4">
					<CFSET Product.RATE_Growth = tempBBRate>
					<CFSET Product.BB_Product_Type_ID = "#getRateInfo.BB_Product_Type_ID#">
						<!---for group level prods, we need to set the color of the display box--->
						<CFIF ShowProductsInGroupLevel EQ 1><CFSET Product.Rate_Growth_Show	 	= 1></CFIF>
				</cfcase>
				<!--- formula --->
				<cfcase value="5">
					<CFSET Product.RATE_Formula = tempBBRate>
					<CFSET Product.BB_Product_Type_ID = "#getRateInfo.BB_Product_Type_ID#">
						<!---for group level prods, we need to set the color of the display box--->
						<CFIF ShowProductsInGroupLevel EQ 1><CFSET Product.Rate_Formula_Show	 	= 1></CFIF>
				</cfcase>
				<cfcase value="10">				
					<CFSET Product.Rate_ClaimAdjust = tempBBRate>
				</cfcase>	
				<cfcase value="11">
					<CFSET Product.Rate_BidRequest = tempBBRate>
					<CFSET Product.BB_Product_Type_ID = "#getRateInfo.BB_Product_Type_ID#">
						<!---for group level prods, we need to set the color of the display box--->
						<CFIF ShowProductsInGroupLevel EQ 1><CFSET Product.Rate_BidRequest_Show	 	= 1></CFIF>
				</cfcase>
							
			</CFSWITCH>
		</CFLOOP>
	</CFLOOP>

	<!--- begin rebate components load --->
 	<CFIF Program.Program_ID NEQ 0 AND isNumeric(Program.Program_ID)>
		<!--- set data information for billbackProgramManager--->
		<cfset billbackProgramManager.setBillbackProgramID(Program.Program_ID) >
		<cfset billbackProgramManager.setBillbackID(Billback.Billback_ID) >
		<!--- get program components and load them up --->
		<cfset qryGetProgramRebateComps = billbackProgramManager.loadRebateCompsFromBillbackProgramRebateComponents() />

		<CFLOOP query="qryGetProgramRebateComps">
			<CFSET Program.Rebate.Count 									= Program.Rebate.Count + 1>
			<CFSET "Program.Rebate.Component_#Program.Rebate.Count#" 		= StructNew()>
			<CFSET CurrentComponent 										= evaluate("Program.Rebate.Component_#Program.Rebate.Count#")>
			<CFSET CurrentComponent.Count_ID		 						= Program.Rebate.Count>
			<CFSET CurrentComponent.Component_Type_ID						= 1> <!--- 1 = known 2 = unknown --->
			<CFSET CurrentComponent.Program_Rebates_Component_Name			= Program_Rebates_Component_Name>
			<CFSET CurrentComponent.Program_Rebates_Component_Name_ID		= Program_Rebates_Component_Name_ID>
			<CFSET CurrentComponent.Checked									= Checked>
			<CFSET CurrentComponent.unknown_Name 							= "">
		</CFLOOP>	
	</CFIF> 
	<!--- begin lump sum load --->
	<CFIF Program.Program_ID NEQ 0 AND isNumeric(Program.Program_ID)>
		<!------ Find the template settings ----->
		<cfset qGetProgramTemplateSettings = BillbackDeviationManager.getProgramTemplateSettings(Program.Program_ID) />
		<!--- get program components and load them up --->
		<cfset getProgramComponents = BillbackDeviationManager.getProgramLumpsumComponents(Program.Program_ID, Billback.Billback_ID, qGetProgramTemplateSettings.Discount_Lump_Sums_Distributor_Mandated, 0) /> <!--- 0 payee type means that we do not check pay to here (save that for deviations --->
		<cfif not Billback.Scheduled_Auto_BB> <!--- Scheduled Auto BB's are not editable...only calculated compponents are used...don't check program for them to add more --->
			<CFLOOP query="getProgramComponents">
				<CFSET Program.Lump_Sums.Count 									= Program.Lump_Sums.Count + 1>
				<CFSET "Program.Lump_Sums.Component_#Program.Lump_Sums.Count#" 	= StructNew()>
				<CFSET CurrentComponent 										= evaluate("Program.Lump_Sums.Component_#Program.Lump_Sums.Count#")>
				<CFSET CurrentComponent.Count_ID		 						= Program.Lump_Sums.Count>
				<CFSET CurrentComponent.Component_Type_ID 						= 1> <!--- 1 = known 2 = unknown --->
				<CFSET CurrentComponent.Program_Lump_Sum_ID						= getProgramComponents.Program_Lump_Sum_ID>
				<CFSET CurrentComponent.Billback_Program_Lumpsum_Component_ID	= 0>
				<CFSET CurrentComponent.unknown_Name 							= "">
				<CFSET CurrentComponent.Supplied_Amount 						= ""><!------ we can leave this empty, because it will get set to (claimed) rate at the bottom of this page ----->
			</CFLOOP>	
		</cfif>
	</CFIF>

	<!-- Growth Components -->
	<cfquery name="getComponents" datasource="#Application.Datasource#">
		SELECT 	dbo.Program_Growth_Components.Program_Growth_Component_ID, 
				dbo.Program_Growth_Components.Component_Name, 
				dbo.Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID, 
				dbo.Program_Growth_Component_Tiers.Tier_Number
		FROM  	dbo.Program_Growth_Components 
				INNER JOIN	dbo.Program_Growth_Component_Tiers 
				ON 
				dbo.Program_Growth_Components.Program_Growth_Component_ID = dbo.Program_Growth_Component_Tiers.Program_Growth_Component_ID
		WHERE 
				(dbo.Program_Growth_Component_Tiers.Deleted = 0) 
				AND (dbo.Program_Growth_Components.Deleted = 0)
				AND (dbo.Program_Growth_Components.IsParent = 1)
				AND (dbo.Program_Growth_Components.Program_ID = '#Program.Program_ID#')
				AND CAST(dbo.Program_Growth_Component_Tiers.Growth_Amount AS float(8)) <> 0 
				AND len(CAST(dbo.Program_Growth_Component_Tiers.Growth_Amount AS float(8))) <> 0
		ORDER BY dbo.Program_Growth_Components.Program_Growth_Component_ID, dbo.Program_Growth_Component_Tiers.Tier_Number
	</cfquery>
	
	<cfloop query="getComponents">
		<CFSET Program.Lump_Sums.Count = Program.Lump_Sums.Count + 1>
		<CFSET "Program.Lump_Sums.Component_#Program.Lump_Sums.Count#" = StructNew()>
		<CFSET CurrentComponent = evaluate("Program.Lump_Sums.Component_#Program.Lump_Sums.Count#")>
		<CFSET CurrentComponent.Count_ID		 		= Program.Lump_Sums.Count>
		<CFSET CurrentComponent.Component_Type_ID 		= 3> <!--- 1 = known 2 = unknown 3 = growth comp--->
		<CFSET CurrentComponent.Program_Lump_Sum_ID		= getComponents.Program_Growth_Component_ID>
		<CFSET CurrentComponent.Billback_Lump_Sum_ID	= 0>
		<CFSET CurrentComponent.Program_Growth_Component_Tier_ID	= getComponents.Program_Growth_Component_Tier_ID>
		<CFSET CurrentComponent.Billback_Program_Lumpsum_Component_ID	= 0>
		<CFSET CurrentComponent.unknown_Name 			= "">
		<CFSET CurrentComponent.Supplied_Amount 		= "">
	</CFLOOP>

	<cfquery name="getLSComponents" datasource="#Application.Datasource#">
		SELECT	*
		FROM 	dbo.Billback_Program_Lumpsum_Component
		WHERE 	Billback_ID 		= '#Billback.Billback_ID#'
		AND		Billback_Program_ID = '#Program.Billback_Program_ID#'
		AND		Deleted = 0
	</cfquery>
	
	<CFLOOP query="getLSComponents">
		<!--- loop through existing --->
		<CFSET AddNewComp = 1>
		<cfloop index="x" from="1" to="#Program.Lump_Sums.Count#" step="1">
			<CFSET Existing_Comp = evaluate("Program.Lump_Sums.Component_#x#")>
			<CFSET Continue = 1>
			<CFIF getLSComponents.Program_Lump_Sum_ID EQ Existing_Comp.Program_Lump_Sum_ID AND getLSComponents.COMPONENT_TYPE_ID NEQ 2>

				<cfif getLSComponents.COMPONENT_TYPE_ID EQ 3>
					<CFSET Continue = 0>
					<CFIF getLSComponents.Program_Growth_Component_Tier_ID EQ Existing_Comp.Program_Growth_Component_Tier_ID>
						<CFSET Continue = 1>
					</CFIF>
				</cfif>

				<cfif Continue EQ 1>
					<CFSET Rate = trim(numberformat(getLSComponents.Amount, '_______________________.__'))>
					<CFSET Existing_Comp.Billback_Program_Lumpsum_Component_ID	= getLSComponents.Billback_Program_Lumpsum_Component_ID>
<!--- 					<CFIF Rate EQ 0>
						<CFSET Rate = "">
					</CFIF> --->
					<CFSET Existing_Comp.Supplied_Amount	= Rate>
					<CFSET x 								= Program.Lump_Sums.Count + 1>
					<CFSET AddNewComp						= 0> 
				</cfif>
			</CFIF>
		</CFLOOP>
		
		<CFIF AddNewComp EQ 1>
			<CFSET Program.Lump_Sums.Count 									= Program.Lump_Sums.Count + 1>
			<CFSET "Program.Lump_Sums.Component_#Program.Lump_Sums.Count#" 	= StructNew()>
			<CFSET CurrentComponent 										= evaluate("Program.Lump_Sums.Component_#Program.Lump_Sums.Count#")>
			<CFSET CurrentComponent.Count_ID		 						= Program.Lump_Sums.Count>
			<CFSET CurrentComponent.Component_Type_ID 						= getLSComponents.Component_Type_ID> <!--- 1 = known 2 = unknown --->
			<CFSET CurrentComponent.Program_Lump_Sum_ID						= getLSComponents.Program_Lump_Sum_ID>
			<CFSET CurrentComponent.Billback_Program_Lumpsum_Component_ID	= getLSComponents.Billback_Program_Lumpsum_Component_ID>
			<CFSET CurrentComponent.Program_Growth_Component_Tier_ID		= getLSComponents.Program_Growth_Component_Tier_ID>
			<CFSET CurrentComponent.unknown_Name 							= getLSComponents.Name>
			<CFSET Rate = trim(numberformat(getLSComponents.Amount, '_______________________.__'))>
			<CFSET CurrentComponent.Supplied_Amount 						= Rate>
		</CFIF>
	</CFLOOP>

</CFLOOP>
