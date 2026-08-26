<cfsilent>
<cfif Not isDefined("billbackProgramManager") >
	<cfset billbackProgramManager = CreateObject("component", "components.billback.Programs.BillbackProgramsManager").init() />
</cfif>


<!--- figure out programs and products to delete --->
<CFSEt Billback = "">
<CFSET LoadBillbackID = FORM.Billback_ID>
<cfinclude template="load_billback_to_struct.cfm">
<cfset Scheduled_Auto_BB = BillbAck.Scheduled_Auto_BB>
<CFSET LoadedBillback 				= Billback>

<!--- <cf_Debug
	debug_on="1"
	title="from DB"
	description=""
	variable="LoadedBillback"
> --->



<CFSET StructLocationPerRateType = "fixed_1,rebate_2,lump_sum_3,growth_4,claimadjust_10,bidrequest_11">

<CFSET ProductUpdateStruct 			= StructNew()>
<CFSET ProductUpdateStruct.Count 	= 0>
<CFSET Billback = "">

<cfset Supplied_Wddx_Packet_To_File_Map_ID = FORM.Wddx_Packet_To_File_Map_ID>
<cfset PacketCommand = "read">
<cfinclude template="/includes/wddxpacketapi.cfm">
<CFSET Billback = Packet.Contents>

<CFSET Original_Modified_Billback = Duplicate(Billback)>

<!--- 
<cf_Debug
	debug_on="1"
	title="from packet builder"
	description=""
	variable="Original_Modified_Billback"
>
 --->
<CFSET PNF = 1>
<CFIF Billback.Programs.Unknown_Program_On_Billback EQ 0>
	<CFSET PNF = 0>
</CFIF>

<cfset useLakebaseForUpdatePNF = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForUpdatePNF>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#LoadBillbackID#",
				"deleted" = "eq.0"
			},
			{
				"bb_pnf" = "#PNF#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdatePNF = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdatePNF>
<cfquery name="UpdatePNF" datasource="#Application.Datasource#">
	UPDATE Billback
	SET BB_PNF = #PNF#
	WHERE Billback_ID = '#LoadBillbackID#' AND Deleted = 0
</cfquery>
</cfif>
<!--- init lump sum structs --->
<CFSET LumpSumComp_Insert 		= StructNew()>
<CFSET LumpSumComp_Insert.Count = 0>
<CFSET LumpSumComp_Update 		= StructNew()>
<CFSET LumpSumComp_Update.Count = 0>
<CFSET LumpSumComp_Delete 		= StructNew()>
<CFSET LumpSumComp_Delete.Count = 0>

<!--- 
	this is an exsting billback
	move new data into the Billback Struct
	move deleted data into Billback_Delete struct 
--->
<CFSET ListOfSuppliedProgramIDs = "">
<CFSET LISTOFPROGRAMIDSTODELETE = "">
<CFSET listofbillbackproductidstodelete = "">
<CFSET BILLBACK_PROGRAM_LUMPSUM_COMPONENT_ID_DELETE_LIST = "">

<CFIF isdefined("Billback.LOADEDFROMDB")>
	<CFSET temp_Billback 				= StructNew()>
	<CFSET temp_Billback.Billback_ID 	= Billback.Billback_ID>
	<CFSET temp_Billback.Programs		= StructNew()>
	<CFSET temp_Billback.Programs.Count	= 0>
	<cfloop index="Packet_Program_ID" from="1" to="#Billback.Programs.Count#" step="1">
		<CFSET Program 		= "">
		<CFSET tempProgram 	= "">
		<CFSET temp			= "">
		<cfif isdefined("Billback.Programs.Program_#Packet_Program_ID#")>
				<CFSET Program = evaluate("Billback.Programs.Program_#Packet_Program_ID#")>
			<!--- add program if there is no ID --->
			
			<CFIF NOT isdefined("Program.BILLBACK_PROGRAM_ID")>
		
				<CFSET Program.AlreadyStagedToBeInserted = 1>
				<CFSET temp_Billback.Programs.Count = temp_Billback.Programs.Count + 1>
				<CFSET "temp_Billback.Programs.Program_#temp_Billback.Programs.Count#" = Duplicate(Program)>
				<CFSET tempProgram = evaluate("temp_Billback.Programs.Program_#temp_Billback.Programs.Count#")>
				<CFSET tempProgram.Count_ID = temp_Billback.Programs.Count>
				<CFSET tempProgram.Lump_Sums = StructNew()>
				<CFSET tempProgram.Lump_Sums.Count = 0>
			<cfelse>
				<CFSET ListOfSuppliedProgramIDs = listappend(ListOfSuppliedProgramIDs,Program.Program_ID)>
			</CFIF>

			<CFIF isdefined("Program.Products") and not isdefined("Program.AlreadyStagedToBeInserted")>
				<CFSET ProductCollection = Duplicate(Program.Products)>
				<cfloop index="Packet_Product_ID" from="1" to="#ProductCollection.Count#" step="1">
					<CFSET Product 		= "">
					<CFSET temp_Product = "">
					<CFIF isdefined("ProductCollection.PRODUCT_#Packet_Product_ID#")>
						<CFSET Product = evaluate("ProductCollection.Product_#Packet_Product_ID#")>
						<CFIF not isdefined("Product.Billback_PRODUCT_ID")>
							<!--- add program to temp program packet --->
							<CFIF not isdefined("Program.Second_AlreadyStagedToBeInserted") AND Not isdefined("Program.AlreadyStagedToBeInserted")>
								<CFSET temp_Billback.Programs.Count = temp_Billback.Programs.Count + 1>
								<CFSET "temp_Billback.Programs.Program_#temp_Billback.Programs.Count#" = Duplicate(Program)>
								<CFSET tempProgram = evaluate("temp_Billback.Programs.Program_#temp_Billback.Programs.Count#")>
								<CFSET tempProgram.Count_ID = temp_Billback.Programs.Count>
								<CFSET Program.Second_AlreadyStagedToBeInserted = 1>
								<CFSET temp = StructClear(tempProgram.Products)>
								<CFSET tempProgram.Products.Count = 0>
								<CFSET tempProgram.Lump_Sums = StructNew()>
								<CFSET tempProgram.Lump_Sums.Count = 0>
							</CFIF>
								<CFSET tempProgram.Products.Count = tempProgram.Products.Count + 1>
								<CFSET "tempProgram.Products.Product_#tempProgram.Products.Count#" = Duplicate(Product)>
								<CFSET temp_Product = evaluate("tempProgram.Products.Product_#tempProgram.Products.Count#")>
								<CFSET temp_Product.Count_ID = tempProgram.Products.Count>
						</CFIF>
					</CFIF>
				</cfloop>
			</CFIF>
			
			<CFSET addTo_LumpSumComp_Insert = 0>
			<CFSET addTo_LumpSumComp_Update = 0>

			<CFIF isdefined("Program.Lump_Sums")><!--- lump sum maintain --->
				<CFSET LumpSumComp_Insert 		= StructNew()>
				<CFSET LumpSumComp_Insert.Count = 0>
				<CFSET LumpSumComp_Update 		= StructNew()>
				<CFSET LumpSumComp_Update.Count = 0>
				<CFSET ComponentCollection = evaluate("Program.Lump_Sums")>
				<cfloop index="x" from="1" to="#ComponentCollection.Count#">
					<CFSET addTo_LumpSumComp_Insert = 0>
					<CFSET addTo_LumpSumComp_Update = 0>
					<CFSET CurrentComponent = evaluate("ComponentCollection.Component_#x#")>

					<CFIF len(trim(CurrentComponent.Supplied_Amount)) GT 0>
						<CFIF isdefined("CurrentComponent.Billback_Program_Lumpsum_Component_ID")>
							<CFIF len(trim(CurrentComponent.Billback_Program_Lumpsum_Component_ID)) NEQ 0 AND CurrentComponent.Billback_Program_Lumpsum_Component_ID EQ 0>
								<CFSET addTo_LumpSumComp_Insert = 1>
							</CFIF>

							<CFIF len(trim(CurrentComponent.Billback_Program_Lumpsum_Component_ID)) NEQ 0 AND CurrentComponent.Billback_Program_Lumpsum_Component_ID NEQ 0>
								<CFIF len(trim(CurrentComponent.Supplied_Amount)) GT 0>
									<CFSET addTo_LumpSumComp_Update = 1>
								</CFIF>
								
							</CFIF>
							
						<CFELSE>
							<CFSET addTo_LumpSumComp_Insert = 1>
						</CFIF>
					</CFIF>
					
					<CFIF addTo_LumpSumComp_Insert EQ 1>
						<CFSET LumpSumComp_Insert.Count = LumpSumComp_Insert.Count + 1>
						<CFSET "LumpSumComp_Insert.Component_#LumpSumComp_Insert.Count#" = Duplicate(CurrentComponent)>
					</CFIF>

					<CFIF addTo_LumpSumComp_Update EQ 1>
						<CFSET LumpSumComp_Update.Count = LumpSumComp_Update.Count + 1>
						<CFSET "LumpSumComp_Update.Component_#LumpSumComp_Update.Count#" = Duplicate(CurrentComponent)>
					</CFIF>					

				</CFLOOP>
			</CFIF>
			
			
			<CFIF not isdefined("Program.Second_AlreadyStagedToBeInserted") AND Not isdefined("Program.AlreadyStagedToBeInserted") AND LumpSumComp_Insert.Count GT 0>
				<CFSET temp_Billback.Programs.Count = temp_Billback.Programs.Count + 1>
				<CFSET "temp_Billback.Programs.Program_#temp_Billback.Programs.Count#" = Duplicate(Program)>
				<CFSET tempProgram = evaluate("temp_Billback.Programs.Program_#temp_Billback.Programs.Count#")>
				<CFSET tempProgram.Count_ID = temp_Billback.Programs.Count>
				<CFSET Program.Second_AlreadyStagedToBeInserted = 1>
				<CFSET tempProgram.Lump_Sums = StructNew()>
				<CFSET tempProgram.Lump_Sums.Count = 0>
				<CFSET tempProgram.Products = StructNew()>
				<CFSET tempProgram.Products.Count = 0>				
			</CFIF>			

			<CFIF LumpSumComp_Insert.Count GT 0>
				<CFSET tempProgram.Lump_Sums = Duplicate(LumpSumComp_Insert)>
			</CFIF>
		
		</cfif>
	</cfloop>

 	<CFSET Billback = temp_Billback>
</CFIF>

<!--- insert brand new program collection --->
<cfloop index="Packet_Program_ID" from="1" to="#Billback.Programs.Count#" step="1">
	<cfif isdefined("Billback.Programs.Program_#Packet_Program_ID#")>
		<cfset Program = evaluate("Billback.Programs.Program_#Packet_Program_ID#")>
		<cfset FoundErrors = 0>
		<!--- Validate Program Data --->

		<!--- Program_Type_ID --->
		<CFIF NOT isnumeric(Program.Program_Type_ID)>
			<cfset FoundErrors = FoundErrors + 1>
		</CFIF>
		<!--- Count --->
		<CFIF NOT isnumeric(Program.Count_ID)>
			<cfset FoundErrors = FoundErrors + 1>
		</CFIF>
		
		<CFIF FoundErrors EQ 0>
		<cfparam name="Program_#Program.Program_ID#_ShowProductsInGroupLevel" default="0">
			<CFSET InsertProgram = QueryNew("Billback_ID")>
			<CFIF not isdefined("Program.BILLBACK_PROGRAM_ID")>
				
					
						<cfquery name="InsertProgram" datasource="#Application.Datasource#">
							INSERT INTO Billback_Program
							(
								Billback_ID,
								Display_Product_Hierarchy,								
								Program_ID
							)
							VALUES
							(
								'#Billback.Billback_ID#',
								'#evaluate("Program_#Program.Program_ID#_ShowProductsInGroupLevel")#',
								'#Program.Program_ID#'
							)
						</cfquery>
					
			<CFELSE>
				<CFSET InsertProgram = QueryNew("Billback_Program_ID")>
				<CFSEt temp = QueryAddRow(InsertProgram,1)>
				<CFSEt temp = QuerySetCell(InsertProgram,"Billback_Program_ID",Program.Billback_Program_ID,1)>
			</CFIF>
		
			<CFSET Billback_Program_ID = 0>
			<CFIF InsertProgram.Recordcount GT 0>
				<CFSET Billback_Program_ID = InsertProgram.Billback_Program_ID>
			</CFIF>
			
			<!--- loop through the products --->
			<CFIF Billback_Program_ID NEQ 0 AND isdefined("Program.Products")>
				<cfloop index="Product_Count_ID" from="1" to="#Program.Products.Count#" step="1">
					<CFIF isdefined("Program.Products.Product_#Product_Count_ID#")>
						<CFSET Product = evaluate("Program.Products.Product_#Product_Count_ID#")>
						<CFSET FoundErrors = 0>
						
						<CFIF not isnumeric(Product.Volume)>
							<CFSET FoundErrors = FoundErrors + 1>
						</CFIF>

						<CFIF not isnumeric(Product.Volume_UOM)>
							<CFSET FoundErrors = FoundErrors + 1>
						</CFIF>
						
						<CFIF FoundErrors EQ 0>
							<cfparam name="Program_#Program.Program_ID#_ShowProductsInGroupLevel" default="0">
							<CFSET InsertProduct = QueryNew("Billback_ID")>
							<cfswitch expression="#Product.Product_Type_ID#">
								<CFCASE value="1"><!--- known Product --->
									<CFSET DispProdGrp = 0>
									<CFSET DispProdGrp = evaluate("Program_#Program.Program_ID#_ShowProductsInGroupLevel")>
									<CFIF DispProdGrp EQ 1>
										<cfif NOT isDefined("FORM.Program_ID")>
											<cfset form.Program_ID = Program.Program_ID>
										</cfif>
									
										<CFSET ActualProgramID = FORM.Program_ID>
										<cfquery name="getParentIDs" datasource="#application.datasource#">
											select	*
											from	dbo.udf_program_revision_detail(#Form.Program_ID#)
											ORDER By Contract_Main_ID
										</cfquery>
										
										<CFSET getParentIDs_List = valuelist(getParentIDs.contract_main_id)>
										<!------ keep the original one program id, because next statement may set it with alist pf programs ids ----->
										<cfset OriginalProgram_ID = FORM.Program_ID>
										<cfset FORM.Program_ID = getParentIDs_List>
										<cfset FORM.Product_Hierarchy_ID = Product.Product_ID>										
										<cfset passStruct = Form>
										<cfset productManager = CreateObject("component", "components.products.ProductManager").init()>
										<cfset searchResult = productManager.search(passStruct)>
										
										<CFSET VolPerItem = 0>
										<CFSET VolPerItem = Product.Volume / searchResult.RecordCount>
										<CFSET Billback_Product_ID_List = "">
						
										<CFLOOP QUERY="searchResult">										
											<cfquery name="InsertProduct" datasource="#Application.Datasource#">
												INSERT INTO Billback_Product
												(
												 Billback_ID,
												 Product_ID,
												 Billback_Program_ID,
												 BB_Product_Quantity,
												 BB_Product_UOM,
												 Product_Type_ID,
												 Product_Hierarchy_ID,
												 Product_Hierarchy_Volume,
												 Distributor_ID
												)
												VALUES
												(
												 '#Billback.Billback_ID#',
												 '#BSA_Foodservice_Items_Master_ID#',
												 '#Billback_Program_ID#',
												 ROUND(#VolPerItem#,0),
												 '#Product.Volume_UOM#',
												 '#Product.Product_Type_ID#',
												 '#Product.Product_ID#',
												 '#Product.Volume#',
												 '#Product.Distributor_ID_Earned#'
												)
											</cfquery>
											<CFIF InsertProduct.recordcount GT 0>
												<CFSET Billback_Product_ID_List = LISTAPPEND(Billback_Product_ID_List,InsertProduct.Billback_Product_ID,",")>
											</CFIF>
										</CFLOOP>
										<!--- <cfdump var="#BSA_Foodservice_Items_Master_ID#"> --->
										
										<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
										<!--- Make Up the difference --->
										<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
										<CFQUERY NAME="GetSum" DATASOURCE="#Application.Datasource#">
											SELECT 	SUM(CAST(BB_Product_Quantity AS FLOAT)) TotVol
											FROM 	Billback_Product
											WHERE 	Billback_Product.Billback_ID = '#Billback.Billback_ID#' AND 
													Product_Hierarchy_ID = '#Product.Product_ID#' AND 
													Deleted = 0
										</CFQUERY>
										<CFSET VolumeDiff = Product.Volume - GetSum.TotVol> 
										<CFIF VolumeDiff NEQ 0>
											<CFQUERY NAME="MakeUpDiff" DATASOURCE="#Application.Datasource#">
												UPDATE  Billback_Product 
												SET 	BB_Product_Quantity = CAST(BB_Product_Quantity AS FLoat) + #VolumeDiff#
												WHERE 	Billback_ID = '#Billback.Billback_ID#' AND 
														Product_Hierarchy_ID = '#Product.Product_ID#' AND 
														Deleted = 0 AND
														Billback_Product_ID = (	SELECT 	Top 1 Billback_Product_ID 
																				FROM 	Billback_Product 
																				WHERE 	Billback_Product.Billback_ID = '#Billback.Billback_ID#' AND 
																						Product_Hierarchy_ID = '#Product.Product_ID#' AND 
																						Deleted = 0	)
											</CFQUERY>										
										</CFIF>
										<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
										<CFSET FORM.Program_ID = OriginalProgram_ID>
									<CFELSE>
										<cfquery name="InsertProduct" datasource="#Application.Datasource#">
											INSERT INTO Billback_Product
											(
											 Billback_ID,
											 Product_ID,
											 Billback_Program_ID,
											 BB_Product_Quantity,
											 BB_Product_UOM,
											 Product_Type_ID,
											 Distributor_ID
											)
											VALUES
											(
											 '#Billback.Billback_ID#',
											 '#Product.Product_ID#',
											 '#Billback_Program_ID#',
											 '#Product.Volume#',
											 '#Product.Volume_UOM#',
											 '#Product.Product_Type_ID#',
											 '#Product.Distributor_ID_Earned#'
											)
										</cfquery>
									</CFIF>
								</CFCASE>
								<CFCASE value="2"><!--- known Product --->
									<cfquery name="InsertProduct" datasource="#Application.Datasource#">
										INSERT INTO Billback_Product
										(
										 Billback_ID,
										 Product_ID,
										 Billback_Program_ID,
										 BB_Product_Quantity,
										 BB_Product_UOM,
										 Product_Type_ID,
									     Distributor_ID
										)
										VALUES
										(
										 '#Billback.Billback_ID#',
										 '#Product.Product_ID#',
										 '#Billback_Program_ID#',
										 '#Product.Volume#',
										 '#Product.Volume_UOM#',
										 '#Product.Product_Type_ID#',
										 '#Product.Distributor_ID_Earned#'
										)
									</cfquery>
								</CFCASE>								
								<CFCASE value="3"><!--- unknown Product --->
									<cfquery name="InsertProduct" datasource="#Application.Datasource#">
										INSERT INTO Billback_Product
										(
										 Billback_ID,
										 Product_ID,
										 Billback_Program_ID,
										 BB_Product_Quantity,
										 BB_Product_UOM,
										 BB_Unknown_Product_Item_Number,
										 BB_Unknown_Product_Description,
										 BB_Unknown_Product_Notes,
										 Product_Type_ID,
									     Distributor_ID
										)
										VALUES
										(
										 '#Billback.Billback_ID#',
										 NULL,
										 '#Billback_Program_ID#',
										 '#Product.Volume#',
										 '#Product.Volume_UOM#',
										 '#Product.Item_Number#',
										 '#Product.Description#',
										 '#Product.Notes#',
										 '#Product.Product_Type_ID#',
										'#Product.Distributor_ID_Earned#'
										)
									</cfquery>							
								</CFCASE>
							</CFSWITCH>
						
						<CFSET Billback_Product_ID = 0>
						<CFIF InsertProduct.recordcount GT 0>
							<CFSET Billback_Product_ID = InsertProduct.Billback_Product_ID>
						</CFIF>
						
						<!--- save rates --->
						<CFIF Billback_Product_ID GT 0 OR IsDefined("Billback_Product_ID_List")>
						
							<cfloop index="RateType" list="#StructLocationPerRateType#" delimiters=",">
													
								<CFSET  tempRateData = ListToarray(RateType, "_")>
								
								<CFIF RateType EQ "lump_sum_3"><!--- i know, a hack but hey is for horses...lmao --->
									<CFSET  tempRateData[1] = "lump_sum">
									<CFSET  tempRateData[2] = "3">
								</CFIF>
								
								<CFIF isdefined("Product.Rate_#tempRateData[1]#") and trim(evaluate("Product.Rate_#tempRateData[1]#")) neq "">
									
									
									<CFIF IsDefined("Billback_Product_ID_List") AND Billback_Product_ID_List NEQ "">
										
										<CFSET ProductsInList = LISTLEN(Billback_Product_ID_List,",")>
										<CFSET ThisRate = evaluate("Product.Rate_#tempRateData[1]#")>
										<CFSET ThisRate2 = ThisRate>
										<CFIF ProductsInList GT 1 AND ThisRate NEQ "">
											<CFSET ThisRate = ThisRate / ProductsInList>
										</CFIF>
										<CFLOOP LIST="#Billback_Product_ID_List#" INDEX="BBProdID">
										
											<cfset useLakebaseForGetDetailInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_product_detail")>
<cfif useLakebaseForGetDetailInfo>
	<cftry>
		<cfset GetDetailInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_product_detail", {
				"billback_id" = "eq.#Billback.Billback_ID#",
				"billback_product_id" = "eq.#BBProdID#",
				"bb_product_type_id" = "eq.#tempRateData[2]#",
				"deleted" = "eq.0",
				"limit" = "1",
				"select" = "distributor_id_earned,customer_group_id,earned_from_group"
			}), "distributor_id_earned,customer_group_id,earned_from_group"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDetailInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDetailInfo>
<CFQUERY NAME="GetDetailInfo" DATASOURCE="#Application.Datasource#">
												SELECT 	top 1 Distributor_ID_Earned, Customer_Group_ID, Earned_From_Group
												FROM 	Billback_Product_Detail
												WHERE 	Billback_ID = '#Billback.Billback_ID#' AND 
														Billback_Product_ID = '#BBProdID#' AND 
														BB_Product_Type_ID = '#tempRateData[2]#' AND
														Deleted = 0
											</CFQUERY>
</cfif> 
											<!--- No --->
											<cfquery name="InsertProductdet" datasource="#Application.Datasource#">
												INSERT INTO Billback_Product_Detail
												(
													Billback_ID,
													Billback_Product_ID,
													BB_Product_Type_ID,
													BB_Rate,
													Product_Hierarchy_Rate
													 ,
													Distributor_ID_Earned,
													Customer_Group_ID,
													Earned_From_Group 
												)
												VALUES
												(
													'#Billback.Billback_ID#',
													'#BBProdID#',
													'#tempRateData[2]#',
													<CFIF ThisRate EQ "">NULL<CFELSE>ROUND(#ThisRate#,2)</CFIF>,
													<CFIF len(trim(evaluate("Product.Rate_#tempRateData[1]#"))) EQ 0>NULL<CFELSE>'#evaluate("Product.Rate_#tempRateData[1]#")#'</CFIF>
													,
													<cfif trim(Product.Distributor_ID_Earned) eq "">NULL<cfelse>'#Product.Distributor_ID_Earned#'</cfif>,
													<cfif trim(GetDetailInfo.Customer_Group_ID) eq "">NULL<cfelse>'#GetDetailInfo.Customer_Group_ID#'</cfif>,
													<cfif trim(GetDetailInfo.Earned_From_Group) eq "">0<cfelse>'#GetDetailInfo.Earned_From_Group#'</cfif> 
												)
											</cfquery>
										</CFLOOP>
										<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
										<!--- Make Up the difference --->
										<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
										<CFIF ThisRate2 NEQ "">
											<CFQUERY NAME="GetRateSum" DATASOURCE="#Application.Datasource#">
												SELECT 	SUM(CAST(BB_Rate AS FLOAT)) TotRate
												FROM 	Billback_Product_Detail
												WHERE 	Billback_ID = '#Billback.Billback_ID#' AND 
														Billback_Product_ID IN (#LISTQUALIFY(Billback_Product_ID_List,"'",",","All")#) AND 
														BB_Product_Type_ID = '#tempRateData[2]#' AND
														Deleted = 0
											</CFQUERY>
											
											<CFSET RateDiff = ThisRate2 - GetRateSum.TotRate> 
											
											<CFIF RateDiff NEQ 0>
												<CFQUERY NAME="MakeUpDiff" DATASOURCE="#Application.Datasource#">
													UPDATE  Billback_Product_Detail 
													SET 	BB_Rate = CAST(BB_Rate AS FLoat) + #RateDiff#
													WHERE 	Billback_ID = '#Billback.Billback_ID#' AND 
															Billback_Product_ID IN (#LISTQUALIFY(Billback_Product_ID_List,"'",",","All")#) AND 
															BB_Product_Type_ID = '#tempRateData[2]#' AND
															Deleted = 0 AND
															Billback_Product_Detail_ID = (	SELECT 	Top 1 Billback_Product_Detail_ID 
																					FROM 	Billback_Product_Detail 
																					WHERE 	Billback_ID = '#Billback.Billback_ID#' AND 
																							Billback_Product_ID IN (#LISTQUALIFY(Billback_Product_ID_List,"'",",","All")#) AND 
																							BB_Product_Type_ID = '#tempRateData[2]#' AND
																							Deleted = 0	)
												</CFQUERY>										
											</CFIF>
										</CFIF>
										<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->										
									<CFELSE>	
									
											<CFQUERY NAME="GetDetailInfo" DATASOURCE="#Application.Datasource#">
												SELECT 	top 1 Distributor_ID_Earned, Customer_Group_ID, Earned_From_Group
												FROM 	Billback_Product_Detail
												WHERE 	Billback_ID = '#Billback.Billback_ID#' AND 
														Billback_Product_ID = '#Billback_Product_ID#' AND  <!--- BBProdID --->
														BB_Product_Type_ID = '#tempRateData[2]#' AND
														Deleted = 0
											</CFQUERY> 
												
										<cfquery name="InsertProductdet2" datasource="#Application.Datasource#">
											INSERT INTO Billback_Product_Detail
											(
												Billback_ID,
												Billback_Product_ID,
												BB_Product_Type_ID,
												BB_Rate
												 ,
													Distributor_ID_Earned,
													Customer_Group_ID,
													Earned_From_Group 
											)
											VALUES
											(
												'#Billback.Billback_ID#',
												'#Billback_Product_ID#',
												'#tempRateData[2]#',
												<CFIF len(trim(evaluate("Product.Rate_#tempRateData[1]#"))) EQ 0>NULL<CFELSE>'#evaluate("Product.Rate_#tempRateData[1]#")#'</CFIF>
												,
													<cfif trim(Product.Distributor_ID_Earned) eq "">NULL<cfelse>'#Product.Distributor_ID_Earned#'</cfif>,
													<cfif trim(GetDetailInfo.Customer_Group_ID) eq "">NULL<cfelse>'#GetDetailInfo.Customer_Group_ID#'</cfif>,
													<cfif trim(GetDetailInfo.Earned_From_Group) eq "">0<cfelse>'#GetDetailInfo.Earned_From_Group#'</cfif> 
											)
										</cfquery>
									</CFIF>
								</CFIF>								
							</CFLOOP>
						</CFIF>
						</CFIF>
					</CFIF>
				</CFLOOP>
			</CFIF>
			<!--- handle rebate components ---->
			
			<CFIF isdefined("Program.Lump_Sums")>
				<!--- add lump sum component --->
				<cfloop index="x" from="1" to="#Program.Lump_Sums.Count#">
					<CFSET CurrentComponent = evaluate("Program.Lump_Sums.Component_#x#")>
					<CFIF trim(CurrentComponent.Supplied_Amount) NEQ 0 AND len(trim(CurrentComponent.Supplied_Amount)) NEQ 0>
					<cfswitch expression="#CurrentComponent.Component_Type_ID#">
						<cfcase value="1"><!--- known component --->
							<cfquery name="insertComponent" datasource="#Application.Datasource#">
								INSERT INTO Billback_Program_Lumpsum_Component
								(Billback_ID, Billback_Program_ID,Component_Type_ID,Program_Lump_Sum_ID,Amount)
								VALUES
								('#Billback.Billback_ID#', '#Billback_Program_ID#',1,'#CurrentComponent.PROGRAM_LUMP_SUM_ID#','#CurrentComponent.SUPPLIED_AMOUNT#')
							</cfquery>
						</cfcase>
			
						<cfcase value="3"><!--- growth component --->
							<cfquery name="insertComponent" datasource="#Application.Datasource#">
								INSERT INTO Billback_Program_Lumpsum_Component
								(Billback_ID, Billback_Program_ID,Component_Type_ID,Program_Lump_Sum_ID,Amount,Program_Growth_Component_Tier_ID)
								VALUES
								('#Billback.Billback_ID#', '#Billback_Program_ID#',3,'#CurrentComponent.PROGRAM_LUMP_SUM_ID#','#CurrentComponent.SUPPLIED_AMOUNT#', '#CurrentComponent.Program_Growth_Component_Tier_ID#')
							</cfquery>
						</cfcase>			

						<cfdefaultcase>
						
						</cfdefaultcase>
					</cfswitch>
					</CFIF>
				</CFLOOP>
			</CFIF>	
		</CFIF>
	</cfif>
	
</CFLOOP>



<!--- delete programs--->
<cfloop index="Loaded_Billback_Packet_ID" from="1" to="#LoadedBillback.Programs.Count#" step="1">
	<cfif isdefined("LoadedBillback.Programs.Program_#Loaded_Billback_Packet_ID#")>
		<CFSET Original_Program 					= "">
		<CFSET Original_Program_ProductCollection 	= "">
		<CFSET Original_Program_LumpSumCollection 	= "">
		
		
		<CFSET Original_Program = evaluate("LoadedBillback.Programs.Program_#Loaded_Billback_Packet_ID#")>
		<CFIF isdefined("Original_Program.Products")>
			<CFSET Original_Program_ProductCollection = Original_Program.Products>
		</CFIF>

		<CFIF isdefined("Original_Program.Lump_Sums")>
			<CFSET Original_Program_LumpSumCollection = Original_Program.Lump_Sums>
		</CFIF>		
		
		<CFSET DeleteThisProgram = 1>
			<cfloop index="Original_Modified_Billback_Packet_ID" from="1" to="#Original_Modified_Billback.Programs.Count#" step="1">
				<CFIF isdefined("Original_Modified_Billback.Programs.Program_#Original_Modified_Billback_Packet_ID#")>
					<CFSET New_Program = evaluate("Original_Modified_Billback.Programs.Program_#Original_Modified_Billback_Packet_ID#")>
					<CFIF New_Program.Program_ID EQ Original_Program.Program_ID>
						<CFIF isdefined("New_Program.Billback_Program_ID")>
							<CFIF New_Program.Billback_Program_ID EQ Original_Program.Billback_Program_ID>
								<CFSET DeleteThisProgram = 0>
							</CFIF>
						<CFELSE>
							<!--- <CFSET DeleteThisProgram = 0> --->
						</CFIF>
					</CFIF>
				</CFIF>
			</cfloop>

			<CFIF DeleteThisProgram EQ 1>
				<CFSET ListOfProgramIDsToDelete = listappend(ListOfProgramIDsToDelete, Original_Program.Billback_Program_ID)>
			<CFELSE>
				<!--- loop through original products --->
				<cfloop index="Original_Product_Packet_ID" from="1" to="#Original_Program_ProductCollection.Count#" step="1">
					<CFIF isdefined("Original_Program_ProductCollection.Product_#Original_Product_Packet_ID#")>
						<CFSET Original_Product = evaluate("Original_Program_ProductCollection.Product_#Original_Product_Packet_ID#")>

						<!--- loop through the new packet programs--->
						<CFSET DeleteThisProduct = 1>
						<cfloop index="Original_Modified_Billback_Packet_ID_2" from="1" to="#Original_Modified_Billback.Programs.Count#" step="1">
							<CFSET Program_2 = evaluate("Original_Modified_Billback.Programs.Program_#Original_Modified_Billback_Packet_ID_2#")>							
							<CFIF isdefined("Program_2.Products")>
								<cfloop index="Products_Packet_ID_2" from="1" to="#Program_2.Products.Count#" step="1">
									<CFSET Product_2 = evaluate("Program_2.Products.Product_#Products_Packet_ID_2#")>
										<CFIF isdefined("Product_2.Billback_Product_ID")>
											<CFIF Product_2.Billback_Product_ID EQ Original_Product.Billback_Product_ID>
												<CFSET DeleteThisProduct = 0>
												<CFSET ProductToUpdate = Duplicate(Product_2)>
												<CFIF isdefined("Product_2.BILLBACK_PRODUCT_ID")>
													<CFSET ProductUpdateStruct.Count = ProductUpdateStruct.Count + 1>
													<CFSET "ProductUpdateStruct.Product_#ProductUpdateStruct.Count#" = Duplicate(ProductToUpdate)>
												</CFIF>
											</CFIF>
										<CFELSE>
											<!--- <CFSET DeleteThisProduct = 0>
											<CFSET ProductToUpdate = Duplicate(Product_2)> --->
										</CFIF>
								</cfloop>
							</CFIF>
						</cfloop>

						<!--- flag product for delete --->
						<CFIF DeleteThisProduct EQ 1>
							<CFSET listofbillbackproductidstodelete = listappend(listofbillbackproductidstodelete, Original_Product.Billback_Product_ID)>
						<CFELSE>
							<!---<CFIF isdefined("Product_2.BILLBACK_PRODUCT_ID")>
								<CFSET ProductUpdateStruct.Count = ProductUpdateStruct.Count + 1>
								<CFSET "ProductUpdateStruct.Product_#ProductUpdateStruct.Count#" = Duplicate(ProductToUpdate)>
							</CFIF>--->
						</CFIF>
						
					</CFIF>
				</cfloop>

				<!--- loop through original components --->
				<cfloop index="Original_LumpSum_Packet_ID" from="1" to="#Original_Program_LumpSumCollection.Count#" step="1">
				<CFIF isdefined("Original_Program_LumpSumCollection.Component_#Original_LumpSum_Packet_ID#")>
					<CFSET Original_Component = evaluate("Original_Program_LumpSumCollection.Component_#Original_LumpSum_Packet_ID#")>
						<!--- loop through the new packet Compnents --->
						<CFSET DeleteThisComponent = 1>
						<cfloop index="Original_Modified_Billback_Packet_ID_2" from="1" to="#Original_Modified_Billback.Programs.Count#" step="1">
							<CFSET Program_2 = evaluate("Original_Modified_Billback.Programs.Program_#Original_Modified_Billback_Packet_ID_2#")>
							<CFIF isdefined("Program_2.Lump_Sums")>
								<cfloop index="Component_Packet_ID_2" from="1" to="#Program_2.Lump_Sums.Count#" step="1">
									<CFSET Component_2 = evaluate("Program_2.Lump_Sums.Component_#Component_Packet_ID_2#")>
									<cfset SafeLSID = 	replace(Original_Component.Billback_Program_Lumpsum_Component_ID, "-", "_", "ALL")>		
										<cfif isDefined("form.LumpSumCompID_#SafeLSID#")>
											<cfset LSAmount = evaluate("form.LumpSumCompID_#SafeLSID#")>
											<cfif LSAmount IS 0 OR len(trim(LSAmount)) LT 1>
												<cfset DeleteThisComponent = 1>
											<cfelseif LSAmount NEQ Original_Component.Supplied_Amount>
												<cfquery name="UpdateLSAmount" datasource="#application.datasource#">
												UPDATE Billback_Program_Lumpsum_Component
												SET Amount = #LSAmount#
												WHERE Billback_Program_Lumpsum_Component_ID = '#Original_Component.Billback_Program_Lumpsum_Component_ID#'
												</cfquery>
											
											</cfif>
										</cfif>
								</cfloop>
							</CFIF>
						</cfloop>
						
					</CFIF>
				</cfloop>				
			</CFIF>
	</cfif>
</cfloop>

<CFIF listlen(ListOfProgramIDsToDelete) GT 0>

	<CFSET temp_Delete_List = listqualify(ListOfProgramIDsToDelete, "'")>

	<cfquery name="deletePrograms" datasource="#Application.Datasource#">
		UPDATE Billback_Program
		SET Deleted = 1
		WHERE 
			Billback_Program_ID IN(#replace(temp_Delete_List, "#chr(39)##chr(39)#", chr(39), "ALL")#) AND Deleted = 0
	</cfquery>

	<cfquery name="deleteProgramProducts" datasource="#Application.Datasource#">
		UPDATE Billback_Product
		SET Deleted = 1
		WHERE 
			Billback_Program_ID IN(#replace(temp_Delete_List, "#chr(39)##chr(39)#", chr(39), "ALL")#) AND Deleted = 0
	</cfquery>

	<cfquery name="deleteComponents" datasource="#Application.Datasource#">
		UPDATE Billback_Program_Lumpsum_Component
		SET Deleted = 1
		WHERE 
			Billback_Program_ID IN(#replace(temp_Delete_List, "#chr(39)##chr(39)#", chr(39), "ALL")#) AND Deleted = 0
	</cfquery>	
	
		<!---The rebate uses the program id so we get it from billback_program--->
	<cfquery name="deleteRebateComponents" datasource="#Application.Datasource#">
		UPDATE Billback_Program_Rebate_Component
		SET Deleted = 1,
		Deleted_By = 'Packet Save',
		Deleted_Date = getdate()
		WHERE 
			Billback_Program_ID IN (Select program_id from billback_program
									Where billback_program_id in (#replace(temp_Delete_List, "#chr(39)##chr(39)#", chr(39), "ALL")#)
									) 
		AND Billback_ID = '#Billback_ID#'
	</cfquery>	
	
</CFIF>

<!--- delete lump sum components --->
<CFIF listlen(BILLBACK_PROGRAM_LUMPSUM_COMPONENT_ID_DELETE_LIST) GT 0>

	<CFSET BILLBACK_PROGRAM_LUMPSUM_COMPONENT_ID_DELETE_LIST = listqualify(BILLBACK_PROGRAM_LUMPSUM_COMPONENT_ID_DELETE_LIST, "'")>
	<cfquery name="deleteComponents" datasource="#Application.Datasource#">
		UPDATE Billback_Program_Lumpsum_Component
		SET Deleted = 1
		WHERE Billback_Program_Lumpsum_Component_ID IN (#replace(BILLBACK_PROGRAM_LUMPSUM_COMPONENT_ID_DELETE_LIST, "#chr(39)##chr(39)#", chr(39), "ALL")#)
	</cfquery>
</CFIF>

<CFIF listlen(listofbillbackproductidstodelete) GT 0>
	<CFSET temp_Delete_List = listqualify(listofbillbackproductidstodelete, "'")>
	
	<CFQUERY NAME="CheckProdHier" DATASOURCE="#Application.Datasource#">
		SELECT 	* 
		FROM 	Billback_Product
		WHERE 	Deleted = 0 AND 
				Billback_ID = '#Billback_ID#' AND
				Product_Hierarchy_ID IN (#LISTQUALIFY(listofbillbackproductidstodelete,"'",",","All")#)
	</CFQUERY>
	<CFSET BBProdIDList = VALUELIST(CheckProdHier.Billback_Product_ID)>
	<CFIF CheckProdHier.RecordCount GT 0>
		<cfquery name="deleteProducts" datasource="#Application.Datasource#">
			UPDATE Billback_Product
			SET Deleted = 1
			WHERE 
				Billback_Product_ID IN(#LISTQUALIFY(BBProdIDList,"'",",","All")#) AND Deleted = 0
		</cfquery>
		<cfquery name="deleteProducts" datasource="#Application.Datasource#">
			UPDATE Billback_Product_Detail
			SET Deleted = 1
			WHERE 
				Billback_Product_ID IN(#LISTQUALIFY(BBProdIDList,"'",",","All")#) AND Deleted = 0
		</cfquery>	
	</CFIF>
	<cfquery name="deleteProducts" datasource="#Application.Datasource#">
		UPDATE Billback_Product
		SET Deleted = 1
		WHERE 
			Billback_Product_ID IN(#replace(temp_Delete_List, "#chr(39)##chr(39)#", chr(39), "ALL")#) AND Deleted = 0
	</cfquery>
	
	<cfquery name="deleteProducts" datasource="#Application.Datasource#">
		UPDATE Billback_Product_Detail
		SET Deleted = 1
		WHERE 
			Billback_Product_ID IN(#replace(temp_Delete_List, "#chr(39)##chr(39)#", chr(39), "ALL")#) AND Deleted = 0
	</cfquery>	
</CFIF>

<cfloop index="Upd_Count" from="1" to="#ProductUpdateStruct.Count#" step="1">

	<CFSET Product = evaluate("ProductUpdateStruct.Product_#Upd_Count#")>
	<CFIF Isdefined("Product.Billback_Product_ID") and len(Product.Billback_Product_ID) GT 0>
		<!--- <CFIF len(Product.Billback_Product_ID) GT 0> --->

			
		<!--- <CFIF evaluate("Program_#Program.Program_ID#_ShowProductsInGroupLevel") EQ 1> --->
				<!--- OLD XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
					<cfset useLakebaseForGetProdCount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_product")>
<cfif useLakebaseForGetProdCount>
	<cftry>
		<cfset GetProdCount = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_product", {
				"billback_id" = "eq.#Billback_ID#",
				"deleted" = "eq.0",
				"product_hierarchy_id" = "eq.#Product.Billback_Product_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetProdCount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetProdCount>
<CFQUERY NAME="GetProdCount" DATASOURCE="#Application.Datasource#">
					SELECT * FROM Billback_Product WHERE Billback_ID = '#Billback_ID#' AND Deleted = 0 AND Product_Hierarchy_ID = '#Product.Billback_Product_ID#'
				</CFQUERY>
</cfif> --->
			<cfif Scheduled_Auto_BB eq 0>
				<!---set up above...use that else reset <CFSET StructLocationPerRateType = "fixed_1,rebate_2,lump_sum_3,growth_4,formula_5,unknown_6,claimadjust_10"> --->
			<cfelse><!---  AUTO BB CHECK...rates are not modified if Sched Auto BB, ONLY Adjustments can be made...these queries need to adjust for group by Product.Distributor_ID_Earned  ********************* --->
				<CFSET StructLocationPerRateType = "claimadjust_10">
			</cfif>
			
			<cfif Scheduled_Auto_BB eq 0>  
					<CFQUERY NAME="GetProdCount" DATASOURCE="#Application.Datasource#">
						SELECT distinct(Billback_Product_ID) FROM Billback_Product WHERE Billback_ID = '#Billback_ID#' AND Deleted = 0 
							<cfif ShowProductsInGroupLevel>
								AND Product_Hierarchy_ID = '#Product.Billback_Product_ID#'
							<cfelse>
								AND Billback_Product_ID = '#Product.Billback_Product_ID#'
							</cfif>
					</CFQUERY>
				<cfelse>
					<CFQUERY NAME="GetProdCount" DATASOURCE="#Application.Datasource#">
						SELECT distinct(D.Billback_Product_Detail_ID) ,D.Billback_Product_ID
						FROM Billback_Product Join BillBack_product_detail D on Billback_Product.Billback_Product_id = D.Billback_Product_id
						WHERE Billback_Product.Billback_ID = '#Billback_ID#' 
								AND Billback_Product.Deleted = 0 
								And D.deleted = 0 
							<cfif ShowProductsInGroupLevel>
								AND Product_Hierarchy_ID = '#Product.Billback_Product_ID#'
							<cfelse>
								AND Billback_Product_ID = '#Product.Billback_Product_ID#'
							</cfif>
								AND BB_Product_Type_ID = '#Product.BB_Product_type_id#'
						AND
						CASE
							WHEN Earned_From_Group = 0	THEN
								d.Distributor_ID_Earned
							ELSE
								d.Customer_Group_ID
							END  = '#Product.Distributor_ID_Earned#'
						
					</CFQUERY>
					
				</cfif>
				<CFSET ListOfProduct = VALUELIST(GetProdCount.Billback_Product_ID)>
		<cfif Product.Volume neq 0 and  GetProdCount.RecordCount neq 0 and trim(Product.Volume) neq "">
				<CFSET VolumePerItem = Product.Volume / GetProdCount.RecordCount>
		<cfelse>
				<CFSET VolumePerItem = 0>
		</cfif>
	<!---  AUTO BB CHECK**************************^^^^^^^^^^^^^^^^^^^^********************************************************************************************* --->
	<!---  AUTO BB CHECK...Volume is not modified if Sched Auto BB...these queries need to adjust for group by Product.Distributor_ID_Earned  ********************* --->
	<!---***********		IF we wanto let them change Auto BB Volumes ...below															  ********************* --->
		<CFIF Scheduled_Auto_BB eq 0>
			<cfparam name="Program_#Program.Program_ID#_ShowProductsInGroupLevel" default="0">
			<CFIF evaluate("Program_#Program.Program_ID#_ShowProductsInGroupLevel") EQ 1>
							
					<CFQUERY NAME="UpdateVolume" DATASOURCE="#Application.Datasource#">
						UPDATE 	Billback_Product
						SET 	BB_Product_Quantity = ROUND(#VolumePerItem#,2),
								BB_Product_UOM		= '#Product.Volume_UOM#',
								Product_Hierarchy_Volume = '#Product.Volume#'
								
						WHERE 	Billback_ID = '#Billback_ID#' AND
								Product_Hierarchy_ID = '#Product.Billback_Product_ID#' AND
								Deleted = 0
					</CFQUERY>		
					<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
					<!--- Make Up the difference --->
					<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
					<CFQUERY NAME="GetSum" DATASOURCE="#Application.Datasource#">
						SELECT 	SUM(CAST(BB_Product_Quantity AS FLOAT)) TotVol
						FROM 	Billback_Product
						WHERE 	Billback_Product.Billback_ID = '#Billback_ID#' AND 
								Product_Hierarchy_ID = '#Product.Billback_Product_ID#' AND 
								Deleted = 0
					</CFQUERY>
					<CFSET VolumeDiff = Product.Volume - GetSum.TotVol> 
	
					<CFIF VolumeDiff NEQ 0>
						<CFQUERY NAME="MakeUpDiff" DATASOURCE="#Application.Datasource#">
							UPDATE  Billback_Product 
							SET 	BB_Product_Quantity = CAST(BB_Product_Quantity AS FLoat) + #VolumeDiff#
							WHERE 	Billback_ID = '#Billback_ID#' AND 
									Product_Hierarchy_ID = '#Product.Billback_Product_ID#' AND 
									Deleted = 0 AND
									Billback_Product_ID = (	SELECT 	Top 1 Billback_Product_ID 
															FROM 	Billback_Product 
															WHERE 	Billback_Product.Billback_ID = '#Billback_ID#' AND 
																	Product_Hierarchy_ID = '#Product.Billback_Product_ID#' AND 
																	Deleted = 0	)
						</CFQUERY>										
					</CFIF>
					<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->		
				<CFELSE>
					<cfquery name="UpdateVolume" datasource="#Application.Datasource#">
						UPDATE Billback_Product
						SET
							BB_Product_Quantity = '#Product.Volume#',
							BB_Product_UOM		= '#Product.Volume_UOM#'
						WHERE Billback_ID = '#Billback_ID#' AND 
							Billback_Product_ID = '#Product.Billback_Product_ID#'
							AND
							Deleted = 0
					</cfquery>
				</CFIF> 
				<!---  AUTO BB CHECK******************	Turns OFF Volume Update if Scheduled_Auto_BB=1	*********************** --->
			</CFIF>
				<!---  AUTO BB CHECK******************************************************************************************* --->
			 
			<cfloop index="RateType" list="#StructLocationPerRateType#" delimiters=",">
				<CFSET  tempRateData = ListToarray(RateType, "_")>
				
				<CFIF RateType EQ "lump_sum_3"><!--- i know, a hack but hey is for horses...lmao --->
					<CFSET  tempRateData[1] = "lump_sum">
					<CFSET  tempRateData[2] = "3">
				</CFIF>

				
				<CFIF isdefined("Product.Rate_#tempRateData[1]#")>
				  <cfif trim(evaluate("Product.Rate_#tempRateData[1]#")) neq "">
				  	<cfparam name="Program_#Program.Program_ID#_ShowProductsInGroupLevel" default="0">
				    <CFQUERY NAME="checkProdRateExists" DATASOURCE="#Application.Datasource#">
								SELECT 	Billback_Product_ID
								FROM 	Billback_Product_Detail WITH (NOLOCK)
								WHERE Billback_ID = '#Billback_ID#' AND 
								<CFIF evaluate("Program_#Program.Program_ID#_ShowProductsInGroupLevel") EQ 1>
									Billback_Product_ID IN (#LISTQUALIFY(ListOfProduct,"'",",","All")#)
								<cfelse>
									Billback_Product_ID = '#Product.Billback_Product_ID#'
								</cfif>
									AND
									Deleted = 0
									AND
									BB_Product_Type_ID = '#tempRateData[2]#'
							<CFIF Scheduled_Auto_BB eq 1>		
									AND
									CASE
										WHEN Earned_From_Group = 0	THEN
										Distributor_ID_Earned
										ELSE
										Customer_Group_ID
										END  = '#Product.Distributor_ID_Earned#'
								</cfif>
								
					</CFQUERY>
					
											<!--- <CFQUERY NAME="GetDetailInfo" DATASOURCE="#Application.Datasource#">
												SELECT 	top 1 Distributor_ID_Earned, Customer_Group_ID, Earned_From_Group
												FROM 	Billback_Product_Detail
												WHERE 	Billback_ID = '#Billback.Billback_ID#' AND 
														<CFIF evaluate("Program_#Program.Program_ID#_ShowProductsInGroupLevel") EQ 1>
															Billback_Product_ID IN (#LISTQUALIFY(ListOfProduct,"'",",","All")#)
														<cfelse>
															Billback_Product_ID = '#Product.Billback_Product_ID#'
														</cfif>
														 AND 
														Deleted = 0
											</CFQUERY>  --->
					
					<cfparam name="Program_#Program.Program_ID#_ShowProductsInGroupLevel" default="0">
					<CFIF evaluate("Program_#Program.Program_ID#_ShowProductsInGroupLevel") EQ 1>
						<cfif checkProdRateExists.recordcount neq GetProdCount.RecordCount><!---  if recordcount neq total for this prod hierarchy --->
						     <cfloop list="#ListOfProduct#" index="P">
						 		<CFQUERY NAME="checkProdRateExists2" DATASOURCE="#Application.Datasource#">
										SELECT 	Billback_Product_ID
										FROM 	Billback_Product_Detail
										WHERE 
											Billback_Product_ID = '#P#'
											AND
											Deleted = 0
											AND
											BB_Product_Type_ID = '#tempRateData[2]#'
									<CFIF Scheduled_Auto_BB eq 1>	
											AND
									CASE
										WHEN Earned_From_Group = 0	THEN
										Distributor_ID_Earned
										ELSE
										Customer_Group_ID
										END  = '#Product.Distributor_ID_Earned#'
									</cfif>
								</CFQUERY>
						 		<cfif checkProdRateExists2.recordcount eq 0>
											 <CFQUERY NAME="GetDetailInfo" DATASOURCE="#Application.Datasource#">
												SELECT 	top 1 Distributor_ID_Earned, Customer_Group_ID, Earned_From_Group
												FROM 	Billback_Product_Detail
												WHERE 	Billback_ID = '#Billback.Billback_ID#' AND 
														Billback_Product_ID = '#GetProdCount.Billback_Product_ID#' AND 
														--BB_Product_Type_ID = '#tempRateData[2]#' AND
														Deleted = 0
													<CFIF Scheduled_Auto_BB eq 1>
														AND
														CASE
															WHEN Earned_From_Group = 0	THEN
															Distributor_ID_Earned
															ELSE
															Customer_Group_ID
															END  = '#Product.Distributor_ID_Earned#'
									 				</cfif>
											</CFQUERY> 
											
									<CFQUERY NAME="insertnewrate" DATASOURCE="#Application.Datasource#">
												INSERT INTO 
													Billback_Product_Detail
															 (	Billback_Product_ID,
																Billback_ID,
																BB_Product_Type_ID,
																BB_Rate,
																BB_Expected_Rate	
																 ,
																Distributor_ID_Earned,
																Customer_Group_ID,
																Earned_From_Group 	
															)
																			
												VALUES		(	'#P#',
																'#Billback_ID#',
																'#tempRateData[2]#',
																'#evaluate("Product.Rate_#tempRateData[1]#")#',
																'#evaluate("Product.Rate_#tempRateData[1]#")#'	
																,
																<cfif trim(GetDetailInfo.Distributor_ID_Earned) eq "">NULL<cfelse>'#GetDetailInfo.Distributor_ID_Earned#'</cfif>,
																<cfif trim(GetDetailInfo.Customer_Group_ID) eq "">NULL<cfelse>'#GetDetailInfo.Customer_Group_ID#'</cfif>,
																<cfif trim(GetDetailInfo.Earned_From_Group) eq "">0<cfelse>'#GetDetailInfo.Earned_From_Group#'</cfif>  
															)
									</CFQUERY>
								 </cfif>
					         </cfloop>
					    </cfif>
					<CFELSE> 
						<cfif checkProdRateExists.recordcount eq 0><!---  if no record...insert --->
						
					
											<CFQUERY NAME="GetDetailInfo" DATASOURCE="#Application.Datasource#">
												SELECT 	top 1 Distributor_ID_Earned, Customer_Group_ID, Earned_From_Group
												FROM 	Billback_Product_Detail
												WHERE 	Billback_ID = '#Billback.Billback_ID#' AND 
														Billback_Product_ID = '#GetProdCount.Billback_Product_ID#' AND 
														--BB_Product_Type_ID = '#tempRateData[2]#' AND
														Deleted = 0
													<CFIF Scheduled_Auto_BB eq 1>	
														AND
														CASE
															WHEN Earned_From_Group = 0	THEN
															Distributor_ID_Earned
															ELSE
															Customer_Group_ID
															END  = '#Product.Distributor_ID_Earned#'
													</cfif>
											</CFQUERY>  
						
							<CFQUERY NAME="InsertNewRate" DATASOURCE="#Application.Datasource#">
										INSERT INTO 
											Billback_Product_Detail
													 (	Billback_Product_ID,
														Billback_ID,
														BB_Product_Type_ID,
														BB_Rate,
														BB_Expected_Rate
														 ,
														Distributor_ID_Earned,
														Customer_Group_ID,
														Earned_From_Group 			
													)
																	
										VALUES		(	'#Product.Billback_Product_ID#',
														'#Billback_ID#',
														'#tempRateData[2]#',
														'#evaluate("Product.Rate_#tempRateData[1]#")#',
														'#evaluate("Product.Rate_#tempRateData[1]#")#'	
														,
														<cfif trim(GetDetailInfo.Distributor_ID_Earned) eq "">NULL<cfelse>'#GetDetailInfo.Distributor_ID_Earned#'</cfif>,
														<cfif trim(GetDetailInfo.Customer_Group_ID) eq "">NULL<cfelse>'#GetDetailInfo.Customer_Group_ID#'</cfif>,
														<cfif trim(GetDetailInfo.Earned_From_Group) eq "">0<cfelse>'#GetDetailInfo.Earned_From_Group#'</cfif>  
													)
							</CFQUERY>
						</cfif>
					</cfif>
					
					
					<CFIF evaluate("Program_#Program.Program_ID#_ShowProductsInGroupLevel") EQ 1>
						<CFIF evaluate("Product.Rate_#tempRateData[1]#") EQ "">
							<CFSET RatePerItem = 0>
							<CFSET ThisRate2 = 0>
						<CFELSE>
							<cfset stuff = evaluate("Product.Rate_#tempRateData[1]#")>
							<CFSET RatePerItem = evaluate("Product.Rate_#tempRateData[1]#") / GetProdCount.RecordCount>
							<CFSET ThisRate2 = evaluate("Product.Rate_#tempRateData[1]#")>
							<!--- <cfoutput>#stuff#::::::#GetProdCount.RecordCount#</cfoutput> --->
						</CFIF>
						
						<CFQUERY NAME="UpdateProducth" DATASOURCE="#Application.Datasource#">
							UPDATE 	Billback_Product_Detail
							SET 	BB_Rate = ROUND(#RatePerItem#,2),
									Product_Hierarchy_Rate = '#evaluate("Product.Rate_#tempRateData[1]#")#'
									
							WHERE 	Billback_ID = '#Billback_ID#' AND
									Billback_Product_ID IN (#LISTQUALIFY(ListOfProduct,"'",",","All")#) AND
									BB_Product_Type_ID = '#tempRateData[2]#' AND
									CASE
										WHEN Earned_From_Group = 0	THEN
										Distributor_ID_Earned
										ELSE
										Customer_Group_ID
										END  = '#Product.Distributor_ID_Earned#'
										AND
									Deleted = 0
						</CFQUERY>
						<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
						<!--- Make Up the difference --->
						<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
						<CFIF ThisRate2 NEQ "" AND ThisRate2 NEQ 0>
							<CFQUERY NAME="GetRateSum" DATASOURCE="#Application.Datasource#">
								SELECT 	isnull(SUM(CAST(BB_Rate AS decimal (13, 2))),0) TotRate
								FROM 	Billback_Product_Detail
								WHERE 	Billback_ID = '#Billback_ID#' AND 
										Billback_Product_ID IN (#LISTQUALIFY(ListOfProduct,"'",",","All")#) AND 
										BB_Product_Type_ID = '#tempRateData[2]#' AND
										CASE
										WHEN Earned_From_Group = 0	THEN
										Distributor_ID_Earned
										ELSE
										Customer_Group_ID
										END  = '#Product.Distributor_ID_Earned#'
										AND
										Deleted = 0
							</CFQUERY>
							
							<CFSET RateDiff = ThisRate2 - GetRateSum.TotRate> 
							
							<CFIF RateDiff NEQ 0>
								<CFQUERY NAME="MakeUpDiff" DATASOURCE="#Application.Datasource#">
									UPDATE  Billback_Product_Detail 
									SET 	BB_Rate = CAST(BB_Rate AS decimal (13, 2)) + #RateDiff#
									WHERE 	Billback_ID = '#Billback_ID#' AND 
											Billback_Product_ID IN (#LISTQUALIFY(ListOfProduct,"'",",","All")#) AND 
											BB_Product_Type_ID = '#tempRateData[2]#' AND
											CASE
												WHEN Earned_From_Group = 0	THEN
												Distributor_ID_Earned
												ELSE
												Customer_Group_ID
												END  = '#Product.Distributor_ID_Earned#'
												AND
											Deleted = 0 AND
											Billback_Product_Detail_ID = (	SELECT 	Top 1 Billback_Product_Detail_ID 
																	FROM 	Billback_Product_Detail 
																	WHERE 	Billback_ID = '#Billback_ID#' AND 
																			Billback_Product_ID IN (#LISTQUALIFY(ListOfProduct,"'",",","All")#) AND 
																			BB_Product_Type_ID = '#tempRateData[2]#' AND
																			Deleted = 0	)
								</CFQUERY>										
							</CFIF>
						</CFIF>
						<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->										
						
						
					<CFELSE>
						<cfquery name="UpdateProductd" datasource="#Application.Datasource#">
							UPDATE Billback_Product_Detail
								SET 
									BB_Rate = '#evaluate("Product.Rate_#tempRateData[1]#")#'
								WHERE Billback_ID = '#Billback.Billback_ID#' AND 
									Billback_Product_ID = '#Product.Billback_Product_ID#'
									AND
									Deleted = 0
									AND
									BB_Product_Type_ID = '#tempRateData[2]#'
						</cfquery>
					</CFIF>
					
				  </cfif>
				</CFIF>
			</CFLOOP>
		</CFIF>
	<!--- </CFIF> --->
	
</CFLOOP>

<!--- Mark product detail as deleted where discount value = 0 --->
<!--- Dev Note: 12442; Milan - Now, even if "0" is entered as a discount rate, the product will be saved. 
			If any developer wants to add back this feature, just remove the comments below. --->
<!---
<cfquery name="UpdateProductDetail" datasource="#application.datasource#">
UPDATE Billback_Product_Detail
SET Deleted = 1
WHERE CAST(BB_Rate AS decimal (13, 2)) = 0
AND Billback_ID = '#Billback_ID#'
</cfquery>
--->

<cfset useLakebaseForCheckCopied = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForCheckCopied>
	<cftry>
		<cfset CheckCopied = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#FORM.Billback_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckCopied = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckCopied>
<CFQUERY NAME="CheckCopied" DATASOURCE="#Application.Datasource#">
	SELECT * FROM Billback WHERE Billback_ID = '#FORM.Billback_ID#'	
</CFQUERY>
</cfif>
<CFIF CheckCopied.CopiedBB NEQ "">
	<cfset useLakebaseForUpdateBit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForUpdateBit>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#FORM.Billback_ID#"
			},
			{
				"volumeratesaved" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateBit = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateBit>
<CFQUERY NAME="UpdateBit" DATASOURCE="#Application.Datasource#">
		UPDATE Billback 
		SET VolumeRateSaved = 1
		WHERE Billback_ID = '#FORM.Billback_ID#'
	</CFQUERY>
</cfif>
</CFIF>
</cfsilent> 

