
<!--- <cfwddx action="WDDX2CFML" input="#FORM.SERIALIZEDPACKET#" output="Billback"> --->
<cfset Supplied_Wddx_Packet_To_File_Map_ID = FORM.Wddx_Packet_To_File_Map_ID>
<cfset PacketCommand = "read">
<cfinclude template="/includes/wddxpacketapi.cfm">
<CFSET Billback = Packet.Contents>
<CFSET Original_Packet_Before_Updating = Packet.Contents>
<cfparam name="FORM.Data_Action_ID" default="0">
<cfparam name="FORM.prodUpdate" default="0">
<cfparam name="Form.Billback_ID" default="0">
<!--- The two variables (TotalRebate and RebateUpdateAllowed) are for updating the rebate amount and are being passed from "program_form.cfm" --->
<cfparam name="TotalRebate" default="0" />
<cfparam name="RebateUpdateAllowed" default="0" />

<cfif Not isDefined("billbackProgramManager") >
	<cfset billbackProgramManager = CreateObject("component", "components.billback.Programs.BillbackProgramsManager").init() />
</cfif>
<!--- If the profile, program template allow rebate update and the program has rebate as a discount type --->
 <cfif RebateUpdateAllowed eq 1>
		<cfif TotalRebate neq 0 AND FORM.Billback_ID neq 0>
				<cfset useLakebaseForupdBBAmount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForupdBBAmount>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#FORM.Billback_ID#"
			},
			{
				"bb_amount" = "#TotalRebate#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdBBAmount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdBBAmount>
<cfquery name="updBBAmount" datasource="#application.datasource#">
					UPDATE Billback
					SET BB_Amount = '#TotalRebate#'
					WHERE Billback_ID = '#FORM.Billback_ID#'
				</cfquery>
</cfif>
		</cfif>
 </cfif>

<!------ Get The Distributor ID ----->
<cfset BillbackDeviationManager = CreateObject("component", "components.billback.BillbackDeviationManager").init() />
<cfset BillbackPayeeType = BillbackDeviationManager.getBillbackPayeeType(Form.Billback_ID) />
<!--- <cfset qDistributor = BillbackDeviationManager.getBillbackDistributor(Form.Billback_ID, BillbackPayeeType) />
<cfset variables.distributorId = qDistributor.BSA_Foodservice_Customers_ID /> --->

<!--- store supplied data in the struct --->

<cfloop index="Program_Count_ID" from="1" to="#Billback.Programs.Count#" step="1">
	<CFSET CurrentProgram 			= evaluate("Billback.Programs.Program_#Program_Count_ID#")>
	<CFIF isdefined("CurrentProgram.Products")><!--- MAINTAIN PRODUCT DATA --->
		<CFSET CurrentProductCollection = CurrentProgram.Products>
		<cfloop index="Product_Count_ID" from="1" to="#CurrentProductCollection.Count#" step="1">
			<CFSET CurrentProduct = evaluate("CurrentProductCollection.Product_#Product_Count_ID#")>
			<CFSET ProductIDString = "ProgramCount_#Program_Count_ID#_ProductCount_#Product_Count_ID#">
			
			<CFIF isdefined("FORM.#ProductIDString#_Volume")>
				<CFSET CurrentProduct.Volume  = evaluate("FORM.#ProductIDString#_Volume")>
			</CFIF>
			
			<CFIF isdefined("FORM.#ProductIDString#_UOM")>
				<CFSET CurrentProduct.Volume_UOM  = evaluate("FORM.#ProductIDString#_UOM")>
			</CFIF>
			
			<cfloop index="rtc" from="1" to="11" step="1">
				<CFIF isdefined("FORM.#ProductIDString#_RateType_#rtc#_Value")>
					<CFSET ThisValue = evaluate("FORM.#ProductIDString#_RateType_#rtc#_Value")>
					<cfswitch expression="#rtc#">
						<cfcase value="1"><!--- fixed --->
							<CFSET CurrentProduct.Rate_Fixed = ThisValue>
						</cfcase>
						<cfcase value="2"><!--- rebate --->
							<CFSET CurrentProduct.Rate_Rebate = ThisValue>
						</cfcase>
						<cfcase value="3"><!--- lump --->
							<CFSET CurrentProduct.Rate_Lump_Sum = ThisValue>
						</cfcase>
						<cfcase value="4"><!--- growth --->
							<CFSET CurrentProduct.Rate_Growth = ThisValue>
						</cfcase>
						<cfcase value="5"><!--- formula --->
							<CFSET CurrentProduct.Rate_Formula = ThisValue>							
						</cfcase>
						<cfcase value="6"><!--- other --->
							<CFSET CurrentProduct.Rate_Unknown = ThisValue>
						</cfcase>
						<cfcase value="10"><!--- Claim Adjustment --->
							<CFSET CurrentProduct.Rate_ClaimAdjust = ThisValue>							
						</cfcase>
						<cfcase value="11"><!--- BidRequest --->
							<CFSET CurrentProduct.Rate_BidRequest = ThisValue>							
						</cfcase>
					</CFSWITCH>
				</CFIF>
			</CFLOOP>
			
		</CFLOOP>
	</CFIF>

<!--- 	<CFIF isdefined("CurrentProgram.Lump_Sums")><!--- MAINTAIN LUMPSUM DATA --->
		<CFSET CurrentLumpSumCollection = CurrentProgram.Lump_Sums>
		
		<cfloop index="lscid" from="1" to="#CurrentProgram.Lump_Sums.Count#" step="1">
			<CFSET CurrentComponent = evaluate("CurrentProgram.Lump_Sums.Component_#lscid#")>
				<CFSWITCH expression="#CurrentComponent.COMPONENT_TYPE_ID#">
					<CFCASE value="1"><!--- know component --->
						<CFSET CurrentComponent.Supplied_Amount = evaluate("Form.ProgramCount_#CurrentProgram.Count_ID#_LumpSumCount_#lscid#_Amount")>
					</CFCASE>
					<CFCASE value="2"><!--- unknow component --->
						<CFSET CurrentComponent.Unknown_Name = evaluate("Form.ProgramCount_#CurrentProgram.Count_ID#_LumpSumCount_#lscid#_Name")>
						<CFSET CurrentComponent.Supplied_Amount = evaluate("Form.ProgramCount_#CurrentProgram.Count_ID#_LumpSumCount_#lscid#_Amount")>
					</CFCASE>
					<CFCASE value="3"><!--- growth component --->
						<CFSET CurrentComponent.Supplied_Amount = evaluate("Form.ProgramCount_#CurrentProgram.Count_ID#_LumpSumCount_#lscid#_Amount")>
					</CFCASE>					
				</CFSWITCH>
		</cfloop>
	</CFIF> --->
</CFLOOP>
<CFSWITCH expression="#FORM.Data_Action_ID#">
 	<cfcase value="1"> <!--- add known program --->
		
		<CFSET CurrentList 	= form.temp_ExistingProductList_Programs>
		<CFSET NewList 		= form.Program_List>
		<CF_List_Compare list1="#CurrentList#" list2="#NewList#" list>
		<CFSET ListToAdd 	= LC_Results2>
		<CFSET ListToDelete = LC_Results1>
		<!--- delete unselected programs --->
		<cfloop index="x" from="1" to="#Billback.Programs.Count#" step="1">
			<CFIF listfind(ListToDelete, evaluate("Billback.Programs.Program_#x#.Program_ID")) GT 0>
				<CFSET temp = StructDelete(Billback.Programs, "Program_#x#")>
			</CFIF>
		</CFLOOP>


		<!--- reindex --->
		<CFSET newIndex = 0>
		<CFSET Billback.List_Of_Programs = "">

		<cfloop index="x" from="1" to="#Billback.Programs.Count#" step="1">
		
		<!--- <cfdump var="#Billback#"> --->
			<CFIF Isdefined("Billback.Programs.Program_#x#")>
				<CFSET newIndex = newIndex + 1>
				<cfset nodeData = evaluate("Billback.Programs.Program_#x#")>
				<CFSET "Billback.Programs.Program_#x#" = "">
				<CFSET temp = StructDelete(Billback.Programs, "Program_#x#")>
				<CFSET StructInsert(Billback.Programs, "Program_#newIndex#", nodeData)>
				<CFSET  "Billback.Programs.Program_#newIndex#.Count_ID" = newIndex>
				<CFSET Billback.List_Of_Programs = listappend(Billback.List_Of_Programs, nodeData.Program_ID)>
			</CFIF>
		</CFLOOP>
		
		<CFSET Billback.Programs.Count = newIndex>


		<cfloop index="x" list="#ListToAdd#">
			<CFSET Billback.Programs.Count = Billback.Programs.Count + 1>
			<CFSET "Billback.Programs.Program_#Billback.Programs.Count#" = StructNew()>
			<CFSET Program = evaluate("Billback.Programs.Program_#Billback.Programs.Count#")>
			<CFSET Program.Program_Type_ID = 1>
			<CFSET Program.Count_ID = Billback.Programs.Count>
			
			<CFSET Program.Program_ID = x>
			<CFSET Program.Products_On_Program = 0>
			<CFSET Program.Products_Not_On_Program = 0>
			<CFSET Program.Products_Unknown = 0>
			<CFSET Program.Lump_Sums = StructNew()>
			<CFSET Program.Lump_Sums.Count = 0>
			<CFSET Program.Lump_Sums.Billback_Program_ID = 0>
			<CFSET Program.Rebate	= StructNew()>
			<CFSET Program.Rebate.Count = 0>


			<CFSET Billback.List_Of_Programs = listappend(Billback.List_Of_Programs, x)>
			
			<cfset useLakebaseForGetDiscountList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForGetDiscountList>
	<cftry>
		<cfset GetDiscountList = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program", {
				"billback_id" = "eq.#Billback.Billback_ID#",
				"program_id" = "eq.#x#",
				"deleted" = "eq.0",
				"select" = "discount_list"
			}), "discount_list"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDiscountList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDiscountList>
<cfquery name="GetDiscountList" datasource="#application.datasource#">
			SELECT Discount_List 
			FROM Billback_Program
			WHERE Billback_ID = '#Billback.Billback_ID#'
			AND Program_ID = '#x#'
			AND Deleted = 0
			</cfquery>
</cfif>
			
			<CFSET Program.Discount_List = "#GetDiscountList.Discount_List#">
			

			<cfquery name="CheckProgramForLumpSums" datasource="#Application.Datasource#">
				SELECT	Program_Control_Panel_Options.Discount_Lump_Sums, Program_Control_Panel_Options.Discount_Growth,
						Program_Control_Panel_Options.Discount_Lump_Sums_Distributor_Mandated
				FROM	Contract_Main 
						INNER JOIN Program_Control_Panel_Options 
						ON  Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
				WHERE	Contract_Main.Deleted = 0
				AND 	Contract_Main.Contract_Main_ID = '#x#'
			</cfquery>
			
			<CFIF CheckProgramForLumpSums.Recordcount GT 0>
				<CFIF CheckProgramForLumpSums.Discount_Lump_Sums EQ 1>
					<cfset getComponents = BillbackDeviationManager.getProgramLumpsumComponents(x, Billback_ID, CheckProgramForLumpSums.Discount_Lump_Sums_Distributor_Mandated, 0) /> <!--- 0 payee type means that we do not check pay to here (save that for deviations --->
					
					<cfloop query="getComponents">
						<CFSET Program.Lump_Sums.Count = Program.Lump_Sums.Count + 1>
						<CFSET "Program.Lump_Sums.Component_#Program.Lump_Sums.Count#" = StructNew()>
						<CFSET CurrentComponent = evaluate("Program.Lump_Sums.Component_#Program.Lump_Sums.Count#")>
						<CFSET CurrentComponent.Count_ID		 		= Program.Lump_Sums.Count>
						<CFSET CurrentComponent.Component_Type_ID 		= 1> <!--- 1 = known 2 = unknown --->
						<CFSET CurrentComponent.Program_Lump_Sum_ID		= getComponents.Program_Lump_Sum_ID>
						<CFSET CurrentComponent.Billback_Lump_Sum_ID	= 0>
						<CFSET CurrentComponent.unknown_Name 			= "">
						<CFSET CurrentComponent.Supplied_Amount 		= "">
					</CFLOOP>
				</CFIF>
				
				<!-- Growth Components -->
				<CFIF CheckProgramForLumpSums.Discount_Growth EQ 1>
					<cfquery name="getComponents" datasource="#Application.Datasource#">
						SELECT 	dbo.Program_Growth_Components.Program_Growth_Component_ID, 
								dbo.Program_Growth_Components.Component_Name, 
								dbo.Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID, 
								dbo.Program_Growth_Component_Tiers.Tier_Number
						FROM  	dbo.Program_Growth_Components 
								INNER JOIN	dbo.Program_Growth_Component_Tiers 
								ON 
								dbo.Program_Growth_Components.Program_Growth_Component_ID = dbo.Program_Growth_Component_Tiers.Program_Growth_Component_ID
						WHERE 	(dbo.Program_Growth_Component_Tiers.Deleted = 0) 
								AND (dbo.Program_Growth_Components.Deleted = 0) 
								AND (dbo.Program_Growth_Components.IsParent = 1)
								AND (dbo.Program_Growth_Components.Program_ID = '#x#')
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
						<CFSET CurrentComponent.unknown_Name 			= "">
						<CFSET CurrentComponent.Supplied_Amount 		= "">
					</CFLOOP>
				</CFIF>				
			</CFIF>
			<!---handle rebate components--->
			<cfset billbackProgramManager.setBillbackProgramID(x) >
			<cfset billbackProgramManager.setBillbackID(Billback.Billback_ID) >
			<cfset qryGetProgramRebateComps = billbackProgramManager.getBillbackProgramRebateComps() />
			<CFLOOP query="qryGetProgramRebateComps">
				<CFSET Program.Rebate.Count 									= Program.Rebate.Count + 1>
				<CFSET "Program.Rebate.Component_#Program.Rebate.Count#" 		= StructNew()>
				<CFSET CurrentComponent 										= evaluate("Program.Rebate.Component_#Program.Rebate.Count#")>
				<CFSET CurrentComponent.Count_ID		 						= Program.Rebate.Count>
				<CFSET CurrentComponent.Component_Type_ID						= 1> <!--- 1 = known 2 = unknown --->
				<CFSET CurrentComponent.Program_Rebates_Component_Name			= replace(Program_Rebates_Component_Name,".","","ALL")>
				<CFSET CurrentComponent.Program_Rebates_Component_Name_ID		= Program_Rebates_Component_Name_ID>
				<CFSET CurrentComponent.Checked									= 'false'>
				<CFSET CurrentComponent.unknown_Name 							= "">
			</CFLOOP> 
						
		</cfloop>
	</cfcase>

 	<cfcase value="2"> <!--- delete known program --->
		<CFIF evaluate("Billback.Programs.Program_#FORM.Count_ID#.Program_Type_ID") EQ 2>
			<CFSET Billback.Programs.Unknown_Program_On_Billback = Billback.Programs.Unknown_Program_On_Billback - 1>
		</CFIF>
		
		<CFSET temp = StructDelete(Billback.Programs, "Program_#FORM.Count_ID#")>
		<CFSET newIndex = 0>

		<!--- reindex --->
		<CFSET Billback.List_Of_Programs = "">
		<cfloop index="x" from="1" to="#Billback.Programs.Count#" step="1">
			<CFIF Isdefined("Billback.Programs.Program_#x#")>
				<CFSET newIndex = newIndex + 1>
				<cfset nodeData = evaluate("Billback.Programs.Program_#x#")>

				<CFSET "Billback.Programs.Program_#x#" = "">
				<CFSET temp = StructDelete(Billback.Programs, "Program_#x#")>
				
				<CFSET StructInsert(Billback.Programs, "Program_#newIndex#", nodeData)>
				<CFSET  "Billback.Programs.Program_#newIndex#.Count_ID" = newIndex>
				<CFSET Billback.List_Of_Programs = listappend(Billback.List_Of_Programs, nodeData.Program_ID)>
			</CFIF>
		</CFLOOP>
		
		<CFSET Billback.Programs.Count = newIndex>
	</cfcase>

	<CFCASE value="3">
		<!--- delete unknown handles by delete known function --->
	</CFCASE>
	
	<CFCASE value="4">
		<CFSET Billback.Programs.Count = Billback.Programs.Count + 1>
		<CFSET Billback.Programs.Unknown_Program_On_Billback = Billback.Programs.Unknown_Program_On_Billback + 1>
		<CFSET "Billback.Programs.Program_#Billback.Programs.Count#" = StructNew()>
		<CFSET Program = evaluate("Billback.Programs.Program_#Billback.Programs.Count#")>
		<CFSET Program.Program_Type_ID = 2>
		<CFSET Program.Program_ID = 0>
		<CFSET Program.Count_ID = Billback.Programs.Count>
		<CFSET Program.Program_Number = FORM.UNKNOWN_PROGRAM_NUMBER>
		<CFSET Program.Program_Title = FORM.UNKNOWN_PROGRAM_Title>
		<CFSET Program.Program_Notes = FORM.UNKNOWN_PROGRAM_Notes>
		<CFSET Program.Products_On_Program = 0>
		<CFSET Program.Products_Not_On_Program = 0>
		<CFSET Program.Products_Unknown = 0>		
		<CFSET Program.Lump_Sums = StructNew()>
		<CFSET Program.Lump_Sums.Count = 0>
		<CFSET Program.Lump_Sums.Billback_Program_ID = 0>		
 	</CFCASE>	

	<cfcase value="5"> <!--- add known product on program--->
	
		<CFSET CurrentList 	= form.ExistingProductList>
		<CFSET NewList 		= form.Product_List>
		
		<CF_List_Compare list1="#CurrentList#" list2="#NewList#" list>

		<CFSET ListToAdd 	= LC_Results2>
		<CFSET ListToDelete = LC_Results1>
		<cfset tmpListToAdd = "">
		<!--- 	UPDATE ListToAdd WITH PRODUCT/dISTRIBUTOR VALUE PAIRS SO WE CAN STORE DISTRIBUTOR AT THE PRODUCT LEVEL
				the default is to add all of the distributors that are defined on the payee page and store in the billback_distributor_List table
				get bb distributor(s). Used to insert products at the distributor level.  every bb product needs a distributor id or an empty (0000-000...) record --->
		<cfset billbackDevManager = CreateObject("component", "components.billback.BillbackDeviationManager") />
		<cfset getDistInfo = billbackDevManager.getBillbackDistributorList(Form.Billback_ID) />
		 <!---no ship to...enter a 0 record--->
		<cfif getDistInfo.RecordCount eq 0>
			<cfset qTemp =  QueryAddRow(getDistInfo)>
			<cfset qTemp = QuerysetCell(getDistInfo, 'BSA_Foodservice_Customers_ID','00000000-0000-0000-0000-000000000000')>
		</cfif>
		<cfset i = 1>
		<!--- <cfoutput>#LC_Results2#  ::  #ListToAdd#</cfoutput>
		<cfabort> --->
		<cfloop index="prodDist" list="#LC_Results2#">
			<cfif find("|",prodDist) eq 0>
				<cfset ListToAdd = listDeleteAt(ListToAdd, i)>
				<cfloop query="getDistInfo">
					<cfset tmpRec = prodDist & "|" & getDistInfo.BSA_Foodservice_Customers_ID>
					<cfset tmpListToAdd = Listappend(tmpListToAdd,tmpRec)>
				</cfloop>
			<cfelse>
				<cfset i = i + 1> <!--- increment only if it is not removed from list... --->
			</cfif>	
		</cfloop>
		
		<cfset ListToAdd = Listappend(ListToAdd,tmpListToAdd)>
		<!--- END update ListToAdd --->
		
		
		
			<!--- 
			Debug	********************************************************
				Current:  <cfoutput>#CurrentList#</cfoutput><br>	********
				New:  <cfoutput>#NewList#</cfoutput><br>			********
				Add:  <cfoutput>#ListToAdd#</cfoutput><br>			********
				Del:  <cfoutput>#ListToDelete#</cfoutput><br>		********
			Debug	******************************************************** 
			--->
		<CFSET Program = evaluate("Billback.Programs.Program_#FORM.Count_ID#")>
		
		<!---Discount list is in DB but not packet -- need to write it to packet --->
		<Cfquery name="GetDiscountList" datasource="#application.datasource#">
		SELECT Discount_List, Billback_Program_ID
		FROM Billback_Program
		WHERE Billback_ID = '#Billback.Billback_ID#'
		AND Program_ID = '#Program.Program_ID#'
		AND Deleted = 0
		</CFQUERY>
		<cfif GetDiscountList.Recordcount IS 1>
			<cfset Program.Discount_List = GetDiscountList.Discount_List>
			<cfset Program.Billback_Program_ID = GetDiscountList.Billback_Program_ID>
		</cfif>
		
		
		<!--- init products collection --->
		<CFIF NOT isdefined("Program.Products")>
			<CFSET Program.Products 								= StructNew()>
			<CFSET Program.Products.Count							= 0>
			<CFSET ProductCollection 								= Program.Products>
			<!---<CFSET ProductCollection.Products_On_Billback_Program 	= "">--->
		<CFELSE><!--- load existing product collection --->
			<CFSET ProductCollection 								= Program.Products>
		</CFIF>
		<!--- delete unselected Products --->
		<!--- <CFIF FORM.IsOnProgram EQ 1>
			<CFSET tempData = "Products_On_Program">		
		<CFELSE>
			<CFSET tempData = "Products_Not_On_Program">
		</CFIF> --->

		<cfloop index="x" from="1" to="#ProductCollection.Count#" step="1">
			<cfset tmpprod = evaluate("ProductCollection.Product_#x#.Product_ID") & "|" & evaluate("ProductCollection.Product_#x#.DISTRIBUTOR_ID_EARNED")>
			<CFIF listfind(ListToDelete, tmpprod) GT 0 OR left(ListToDelete, 36) IS "00000000-0000-0000-0000-000000000000"> <!--- AND evaluate("ProductCollection.Product_#x#.Product_Type_ID") EQ FORM.IsOnProgram --->
				<!--- increment the counter according to product type --->
				<cfif evaluate("ProductCollection.Product_#x#.Product_Type_ID") EQ 1>
					<CFSET Program.Products_On_Program = Program.Products_On_Program - 1>
				<cfelse>
					<CFSET Program.Products_Not_On_Program = Program.Products_Not_On_Program - 1>
				</cfif>
					<!--- DELETE --->
				<CFSET temp = StructDelete(ProductCollection, "Product_#x#")>
			</CFIF>
		</CFLOOP>
		<!--- add products --->
		<cfloop index="thisProduct_ID" list="#ListToAdd#">
			<cfset thisDistributor_Id_Earned = gettoken(thisProduct_ID,2,"|")>
			<cfset thisProduct_ID = gettoken(thisProduct_ID,1,"|")>
			<CFSET ProductCollection.Count = ProductCollection.Count + 1>
			<CFSET "ProductCollection.Product_#Program.Products.Count#" = StructNew()>
			<CFSET ProductStruct = evaluate("ProductCollection.Product_#Program.Products.Count#")>
			<CFSET ProductStruct.Product_Type_ID = FORM.IsOnProgram>

			<!---TSF - 11671: Get the Customer Ship To and the product item number and set them to the sort key in the product struct--->
			<cfset useLakebaseForqGetShipTo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForqGetShipTo>
	<cftry>
		<cfset qGetShipTo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"bsa_foodservice_customers_id" = "eq.#thisDistributor_Id_Earned#",
				"deleted" = "eq.0",
				"select" = "ship_to"
			}), "ship_to"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetShipTo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetShipTo>
<cfquery name="qGetShipTo" datasource="#application.datasource#">
				SELECT 	DISTINCT Ship_To 
				FROM 	BSA_Foodservice_Customers
				WHERE	BSA_Foodservice_Customers_ID = '#thisDistributor_Id_Earned#'
				AND		Deleted = 0
			</cfquery>
</cfif>
			
			<cfset useLakebaseForqGetProductItem = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForqGetProductItem>
	<cftry>
		<cfset qGetProductItem = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"bsa_foodservice_items_master_id" = "eq.#thisProduct_ID#",
				"deleted" = "eq.0",
				"select" = "item"
			}), "item"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProductItem = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProductItem>
<cfquery name="qGetProductItem" datasource="#application.datasource#">
				SELECT 	DISTINCT Item 
				FROM 	BSA_Foodservice_Items_Master
				WHERE	BSA_Foodservice_Items_Master_ID = '#thisProduct_ID#'
				AND		Deleted = 0
			</cfquery>
</cfif>
			<CFIF FORM.IsOnProgram EQ 1>
				<CFSET Program.Products_On_Program = Program.Products_On_Program + 1>
			<CFELSE>
				<!--- for products not on program, set distributor to 0 if it is empty--->
				<!--- <cfif trim(thisDistributor_Id_Earned) eq ""><cfset thisDistributor_Id_Earned = "00000000-0000-0000-0000-000000000000"></cfif> --->
				<CFSET Program.Products_Not_On_Program = Program.Products_Not_On_Program + 1>
			</CFIF>
			
			<CFSET ProductStruct.Count_ID = ProductCollection.Count>
			<CFSET ProductStruct.Product_ID = thisProduct_ID>
			<CFSET ProductStruct.Distributor_Id_Earned = thisDistributor_Id_Earned>
				<!--- used to sort the struct in program_form.cfm --->
			<CFSET ProductStruct.Sort = qGetShipTo.Ship_To & "|" & qGetProductItem.Item />
			<CFSET ProductStruct.Volume 		= "">
			<CFSET ProductStruct.Volume_UOM 	= "1">
			<CFSET ProductStruct.Rate_Fixed	 	= "">
			<CFSET ProductStruct.Rate_Rebate	= "">
			<CFSET ProductStruct.Rate_Lump_Sum 	= "">
			<CFSET ProductStruct.Rate_Growth 	= "">
			<CFSET ProductStruct.Rate_Formula 	= "">
			<CFSET ProductStruct.Rate_BidRequest 	= "">
			<CFSET ProductStruct.Rate_ClaimAdjust 	= "">

			<CFSET ProductStruct.Rate_Fixed_Show	 	= 0>
			<CFSET ProductStruct.Rate_Rebate_Show		= 0>
			<CFSET ProductStruct.Rate_Lump_Sum_Show 	= 0>
			<CFSET ProductStruct.Rate_Growth_Show 		= 0>
			<CFSET ProductStruct.Rate_Formula_Show 		= 0>
			<CFSET ProductStruct.Rate_BidRequest_Show 	= 0>
			<CFSET ProductStruct.Rate_ClaimAdjust_Show 	= 0>

			<cfif FORM.IsOnProgram EQ 1>
				<cfif len(trim(Program.Program_Id)) NEQ 0 AND trim(Program.Program_Id) NEQ 0>
					<!--- GET PROGRAM CONTRACT NUMBER --->
					<cfquery name="getCtNum" datasource="#application.datasource#">
						SELECT     Contract_Number
						FROM         dbo.Contract_Main
						WHERE     (Contract_Main_ID = '#Program.Program_Id#')
					</cfquery>
					<!--- GET BILLBACK END DATE --->
					<cfquery name="getBBEndDate" datasource="#application.datasource#">
						SELECT     BB_End_Date
						FROM         dbo.Billback
						WHERE     (Billback_ID = '#Billback.Billback_ID#')					
					</cfquery>
				
					<!--- <cfif len(trim(ProductStruct.Product_ID)) GT 0>
						<!--- rate border color code --->
						<cfquery name="getProgramProducts" datasource="#application.datasource#">
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
							AND				Contract_Products.BSA_Foodservice_Items_Master_ID = '#ProductStruct.Product_ID#'
							AND				BB_Program_Revisions.Approval_Start_Date <= #createodbcdatetime(getBBEndDate.BB_End_Date)#
							ORDER BY 		BB_Program_Revisions.Approval_End_Date							
						</cfquery>
				
						<cfset rate_type_list = valuelist(getProgramProducts.Product_Type_ID)>
						<cfif listfind(rate_type_list, 1) NEQ 0>
							<!--- Fixed Price --->
							<CFSET ProductStruct.Rate_Fixed_Show	 	= 1>
						</cfif>
						<cfif listfind(rate_type_list, 2) NEQ 0>
							<!--- Rebate --->
							<CFSET ProductStruct.Rate_Rebate_Show	 	= 1>
						</cfif>
						<cfif listfind(rate_type_list, 3) NEQ 0>
							<!--- Lump Sum --->
							<CFSET ProductStruct.Rate_Lump_Sum_Show	= 1>
						</cfif>
						<cfif listfind(rate_type_list, 4) NEQ 0>
							<!--- Growth --->
							<CFSET ProductStruct.Rate_Growth_Show	 	= 1>
						</cfif>
						<cfif listfind(rate_type_list, 5) NEQ 0>
							<!--- Fromula Pricing --->
							<CFSET ProductStruct.Rate_Formula_Show	= 1>
						</cfif>
						<cfif listfind(rate_type_list, 10) NEQ 0>							
							<!--- BidRequest --->
							<!------ discount_type = 10 is bid request in programs, but as claim adjustment already used up the id 10 in billback,
							bid request has an id of 11 in billback, but when looking at program tables we have to keep using 10 ----->
							<CFSET ProductStruct.Rate_BidRequest_Show	= 1>
						</cfif>
						<!--- rate border color code END--->			
					</cfif> --->
				</cfif>
			</cfif>

		<!--- </CFLOOP> --->
		</CFLOOP> 

		<!--- reindex --->
		<CFSET NEWINDEX = 0>
		<CFSET Billback.PRODUCTS_ON_BILLBACK_PROGRAM = "">
		<cfloop index="x" from="1" to="#ProductCollection.Count#" step="1">
			<CFIF Isdefined("ProductCollection.Product_#x#")>
				<CFSET newIndex = newIndex + 1>
				<cfset nodeData = evaluate("ProductCollection.Product_#x#")>
				<CFSET "ProductCollection.Product_#x#" = "">
				<CFSET temp = StructDelete(ProductCollection, "Product_#x#")>
				<CFSET StructInsert(ProductCollection, "Product_#newIndex#", nodeData)>
				<CFSET  "ProductCollection.Count" = newIndex>
				<CFSET "ProductCollection.Product_#newIndex#.Count_ID" = newIndex>
				<cfset tmpprodCust = nodeData.Product_ID & "|" & nodeData.distributor_id_earned>
				<CFSET Billback.PRODUCTS_ON_BILLBACK_PROGRAM = listappend(Billback.PRODUCTS_ON_BILLBACK_PROGRAM, tmpprodCust)><!--- nodeData.Product_ID --->
			</CFIF>
		</CFLOOP>
		<CFSET ProductCollection.Count = newIndex>
	
	</cfcase>

	<cfcase value="6"> <!--- unknown product--->
		<CFSET Program = evaluate("Billback.Programs.Program_#FORM.Count_ID#")>
		<CFSET Program.Products_Unknown = Program.Products_Unknown + 1>		


		<CFIF NOT isdefined("Program.Products")>
			<CFSET Program.Products = StructNew()>
			<CFSET Program.Products.Count = 0>
			<CFSET ProductCollection = Program.Products>
		<CFELSE>
			<CFSET ProductCollection = Program.Products>
		</CFIF>
		
			<CFSET ProductCollection.Count = ProductCollection.Count + 1>
			<CFSET "ProductCollection.Product_#Program.Products.Count#" = StructNew()>
			<CFSET ProductStruct = evaluate("ProductCollection.Product_#Program.Products.Count#")>
			<CFSET ProductStruct.Product_Type_ID = 3>
			<CFSET ProductStruct.Count_ID = ProductCollection.Count>
			<CFSET ProductStruct.Product_ID = 0>
			
			<cfset ProductStruct.Item_Number 	=  FORM.Unknown_Item_Number>
			<cfset ProductStruct.Description 	=  FORM.Unknown_Description>
			<cfset ProductStruct.Notes 			=  FORM.Unknown_Notes>
			<CFSET ProductStruct.Distributor_Id_Earned = "00000000-0000-0000-0000-000000000000">
				<!--- used to sort the struct in program_form.cfm --->
			<CFSET ProductStruct.Sort = variables.distributorId & "|" & 0>		
			<CFSET ProductStruct.Volume = "">
			<CFSET ProductStruct.Volume_UOM = "">
			<CFSET ProductStruct.Rate_Fixed	 	= "">
			<CFSET ProductStruct.Rate_Rebate	= "">
			<CFSET ProductStruct.Rate_Lump_Sum 	= "">
			<CFSET ProductStruct.Rate_Growth 	= "">
			<CFSET ProductStruct.Rate_Formula 	= "">
			<CFSET ProductStruct.Rate_BidRequest 	= "">
			<CFSET ProductStruct.Rate_Unknown 	= "">
			<CFSET ProductStruct.Rate_ClaimAdjust 	= "">
	</cfcase>	

	<cfcase value="7"><!--- delete product --->
		<CFSET Program = evaluate("Billback.Programs.Program_#FORM.Count_ID#")>
		<CFSET CurrentProduct = evaluate("Program.Products.Product_#Form.Product_Count_ID#")>
		
		<CFSWITCH expression="#CurrentProduct.PRODUCT_TYPE_ID#">
			<cfcase value="1"><!--- known prod. on program --->
				<CFSET Program.PRODUCTS_ON_PROGRAM = Program.PRODUCTS_ON_PROGRAM - 1>
			</cfcase>
			<cfcase value="2"><!--- known prod. not on program --->
				<CFSET Program.PRODUCTS_NOT_ON_PROGRAM = Program.PRODUCTS_NOT_ON_PROGRAM - 1>
			</cfcase>
			<cfcase value="3"><!--- unknown prod. --->
				<CFSET Program.PRODUCTS_UNKNOWN = Program.PRODUCTS_UNKNOWN - 1>
			</cfcase>
		</CFSWITCH>
		
		<CFSET temp = structDelete(Program.Products, "Product_#Form.Product_Count_ID#")>
		
		<!--- reindex the structure --->
		
		<CFSET newIndex = 0>
		<CFSET Billback.PRODUCTS_ON_BILLBACK_PROGRAM = "">
		<cfloop index="x" from="1" to="#Program.Products.Count#" step="1">
			<CFIF Isdefined("Program.Products.Product_#x#")>
				<CFSET newIndex = newIndex + 1>
				<cfset nodeData = evaluate("Program.Products.Product_#x#")>
				<CFSET "Program.Products.Product_#x#" = "">
				<CFSET temp = StructDelete(Program.Products, "Product_#x#")>
				<CFSET temp =  StructInsert(Program.Products, "Product_#newIndex#", nodeData)>
				<CFSET "Program.Products.Product_#newIndex#.Count_ID" = newIndex>
				<CFSET Billback.PRODUCTS_ON_BILLBACK_PROGRAM = listappend(Billback.PRODUCTS_ON_BILLBACK_PROGRAM, nodeData.Product_ID)>
			</CFIF>
		</CFLOOP>
		
		<CFSET Program.Products.Count = newIndex>
	</cfcase>
	
	<CFCASE value="8"><!--- add lump sum component --->
		<CFSET Program = evaluate("Billback.Programs.Program_#FORM.Count_ID#")>
		
		<CFIF NOT isdefined("Program.Lump_Sums")>
			<CFSET Program.Lump_Sums = StructNew()>
			<CFSET Program.Lump_Sums.Count = 0>
			<CFSET Program.Lump_Sums.Billback_Program_ID = Program.Billback_Program_ID>
		</CFIF>
		
		<CFSET Program.Lump_Sums.Count = Program.Lump_Sums.Count + 1>
		<CFSET "Program.Lump_Sums.Component_#Program.Lump_Sums.Count#" = StructNew()>
		<CFSET CurrentComponent = evaluate("Program.Lump_Sums.Component_#Program.Lump_Sums.Count#")>
		<CFSET CurrentComponent.Count_ID		 						= Program.Lump_Sums.Count>
		<CFSET CurrentComponent.Component_Type_ID 						= 2> <!--- 1 = known 2 = unknown --->
		<CFSET CurrentComponent.Program_Lump_Sum_ID						= 0>
		<CFSET CurrentComponent.Billback_Program_Lumpsum_Component_ID	= 0>
		<CFSET CurrentComponent.Unknown_Name 							= "">
		<CFSET CurrentComponent.Supplied_Amount 						= "">	
	</CFCASE>
	
	<CFCASE value="9"><!--- delete sum component --->
		<CFSET Program = evaluate("Billback.Programs.Program_#FORM.Count_ID#")>
		<CFSET CurrentComponent = evaluate("Program.Lump_Sums.Component_#FORM.Component_Count_ID#")>

		<CFSET temp = structDelete(Program.Lump_Sums, "Component_#Form.Component_Count_ID#")>
		
		<!--- reindex the structure --->
		
		<CFSET newIndex = 0>
		<cfloop index="x" from="1" to="#Program.Lump_Sums.Count#" step="1">
			<CFIF Isdefined("Program.Lump_Sums.Component_#x#")>
				<CFSET newIndex = newIndex + 1>
				<cfset nodeData = evaluate("Program.Lump_Sums.Component_#x#")>
				<CFSET "Program.Lump_Sums.Component_#x#" = "">
				<CFSET temp = StructDelete(Program.Lump_Sums, "Component_#x#")>
				<CFSET temp =  StructInsert(Program.Lump_Sums, "Component_#newIndex#", nodeData)>
				<CFSET "Program.Lump_Sums.Component_#newIndex#.Count_ID" = newIndex>
			</CFIF>
		</CFLOOP>
		
		<CFSET Program.Lump_Sums.Count = newIndex>
	</CFCASE>
		
	<cfdefaultcase>
		
	</cfdefaultcase>
 </CFSWITCH>

	<cfset PacketCommand = "write">
	<cfset Supplied_PacketContents = Billback>
	<cfset Supplied_Wddx_Packet_To_File_Map_ID = FORM.Wddx_Packet_To_File_Map_ID>
	<cfinclude template="/includes/wddxpacketapi.cfm">
<cfoutput>
<CFIF FORM.Data_Action_ID EQ "FinalSubmit" or form.PRODUPDATE eq 1 or FORM.Data_Action_ID EQ 2 or FORM.Data_Action_ID EQ 1>
	<cfinclude template="Packet_Save.cfm">
		<cfif FORM.Data_Action_ID NEQ 2 AND FORM.Data_Action_ID NEQ 1>
			<CFSET FORM.Data_Action_ID = "FinalSubmit">
		</cfif>
</CFIF>
<cfparam name="form.ProgramToSwitch" default="0">
<cfif form.ProgramToSwitch NEQ 0>
	<cfinclude template="Packet_Save.cfm">
</cfif>

 <form action="program_form.cfm" method="post" name="RelayFormBackToProgramMenu" id="RelayFormBackToProgramMenu">
	<input type="Hidden" name="Wddx_Packet_To_File_Map_ID" value="#Form.Wddx_Packet_To_File_Map_ID#">
	<input type="Hidden" name="Billback_ID" value="#FORM.Billback_ID#">
	<input type="hidden" name="ProgramToSwitch" value="#form.ProgramToSwitch#">

 </FORM>
 </cfoutput>

	 <CFIF FORM.Data_Action_ID EQ "FinalSubmit" AND ProgramToSwitch EQ 0>
		<!--- simulate button click --->
		<cfset local_bbid = FORM.Billback_ID>
		<cfinclude template="bb_menu_stats.cfm">
		<script>
			window.parent.summary_tab.fireEvent("onclick")
		</script>		
	<CFELSE>
		<script>
		document.RelayFormBackToProgramMenu.submit();
		</script>
	</CFIF>
