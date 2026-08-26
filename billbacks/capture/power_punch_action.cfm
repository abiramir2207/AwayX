<!---
Name: 			power_punch_action.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:	N/A
Created By:		N/A
Description:	This file is responsible for saving billback power punch data.  
--->

<cfset useLakebaseForGetStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForGetStatus>
	<cftry>
		<cfset GetStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#FORM.Billback_ID#",
				"select" = "billback_status_id"
			}), "billback_status_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetStatus>
<CFQUERY NAME="GetStatus" DATASOURCE="#Application.Datasource#">
	SELECT Billback_Status_ID FROM Billback WHERE Billback_ID = '#FORM.Billback_ID#'
</CFQUERY>
</cfif>
<CFIF GetStatus.Billback_Status_ID GTE 3> 
	<!--- 17302 - Redirect to Summary --->
	<CFSET Billback_Status_ID = GetStatus.Billback_Status_ID>
	<CFSET BB_ID_TO_Redirect = FORM.Billback_ID>
	<CFINCLUDE TEMPLATE = "BB_Summary_Redirect.cfm">
	<CFABORT>
</CFIF>

<cfset appSettings = application.appSettingsGet>
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfparam name="variables.NoItemList" 			default="">

<cfoutput>

	<cftransaction isolation="read_uncommitted">
	
		<cfsilent>
		
		<!---Loop through the programs represented in the prior page--->
		<cfloop index="variables.Contract_Main_ID" list="#form.program_list#" delimiters=",">
		
			<cfset variables.ListRows = evaluate("form.c_#variables.Contract_Main_ID#_counter")>
			
			<cfquery name="getProgramDiscountList" datasource="#application.datasource#">
				SELECT 	Discount_List 
				FROM 	Billback_Program
				WHERE 	Billback_ID = '#Form.Billback_ID#'
				AND 	Program_ID = '#variables.Contract_Main_ID#'
				AND 	Deleted = 0	
			</cfquery>
			
			<cfset DiscountList = getProgramDiscountList.Discount_List><!--- input for inc_eligible_products.cfm ---->
					
			<cfset BBID = form.Billback_ID><!--- input for inc_eligible_products.cfm ---->
			<cfset Billback_Contract_Main_ID = variables.Contract_Main_ID><!--- input for inc_eligible_products.cfm ---->
			<cfset Calling_Page = "Highlight">
			
			<cfinclude template="/billbacks/capture/inc_eligible_products.cfm">
			
			<!---handle for claims at the component level
			XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			XXXXXXXXXX commented out since components are handeled in the new components pop UP XXXXXXXXXXX
			XXXXXXXXXX  2/19/07 MWS                                                             XXXXXXXXXXX
			XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX--->
			<!--- <cfif appSettings.Claims_at_Comp_Level>
			
				<cfparam name="Rebate_Components_#variables.Contract_Main_ID#"			default="" />
				<cfparam name="Selected_Rebate_Component_ID" 	default="" />
				
				<!---clear out any existing entries--->
				<cfquery name="qInsertRebateData" datasource="#application.datasource#">
					UPDATE	Billback_Program_Rebate_Component
					SET		Deleted = 1
					WHERE	Billback_ID = '#Form.Billback_ID#'
					AND		Billback_Program_ID = '#variables.Contract_Main_ID#'
				</cfquery>
				
				<!---Loop through selected rebate components--->
				<cfloop index="variables.rebIndx" list="#Evaluate("Rebate_Components_#variables.Contract_Main_ID#")#">
				
					<!---innocent until proven guilty--->
					<cfset variables.checked = 'false' />
					
					<!---if we fing a selected rebate component then we are guilty--->
					<cfif ListFindNoCase(Selected_Rebate_Component_ID, variables.rebIndx)>
					
						<cfset variables.checked = 'true' />
						
					</cfif>
	
					
					<cfquery name="ComponentName" datasource="#application.datasource#">
					SELECT 	Program_Rebates_Component_Name.Program_Rebates_Component_Name, 
							Payment_Paid_To_Types.Payment_Paid_To_Type_Name,
							Program_Rebates_Component.Program_Rebates_Component_Name_ID
				FROM 	Program_Rebates_Component
						INNER JOIN Program_Rebates_Component_Name ON
						Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID
						LEFT JOIN Payment_Paid_To_Types ON 
						Payment_Paid_To_Types.Payment_Paid_To_Type_ID = Program_Rebates_Component.Component_Paid_To
				WHERE 	Program_Rebates_Component.Deleted = 0
				AND 	Program_Rebates_Component.Program_ID = #Contract_Main_ID#
				AND 	Program_Rebates_Component.Program_Rebates_Component_ID = #variables.rebIndx#
					</cfquery>
					
					<cfset CompName = ComponentName.Program_Rebates_Component_Name<!---  & " (" & ComponentName.Payment_Paid_To_Type_Name & ")" --->>
										
					<cfquery name="qInsertRebateData" datasource="#application.datasource#">
						INSERT INTO Billback_Program_Rebate_Component
						(
							Billback_ID, 
							Billback_Program_ID, 
							Program_Rebates_Component_Name, 
							Program_Rebates_Component_Name_ID, 
							Program_Rebates_Component_ID,
							Checked
						)
						VALUES
						(
							'#Form.Billback_ID#', 
							'#variables.Contract_Main_ID#', 
							'#CompName#', 
							'#ComponentName.Program_Rebates_Component_Name_ID#',
							'#variables.rebIndx#', 							
							'#variables.checked#'
						)
					</cfquery>
					
				</cfloop><!---END Loop through selected rebate components--->
				
			</cfif><!---END handle for claims at the component level---> --->
			
			<!---get the payee_id--->
			<cfquery name="qGetdistId" datasource="#application.datasource#">
				Declare
				@Billback_ID UniqueIdentifier,
				@Billback_Payee_Type_ID int,
				@PAYEE_ID  uniqueidentifier
				SELECT 	DISTINCT @Billback_ID = Billback_ID,
						@Billback_Payee_Type_ID = Billback_Payee_Type_ID
				FROM 	Billback 
				WHERE 	Billback_ID = '#Form.Billback_ID#'
				
				IF @Billback_Payee_Type_ID = 4
				BEGIN	
					SELECT @PAYEE_ID = Associated_Ship_To FROM Billback_Unidentified_Payee  WHERE Billback_ID = @Billback_ID AND DELETED = 0
				END
				ELSE IF @Billback_Payee_Type_ID = 1
				BEGIN
					SELECT 	@PAYEE_ID = Billback_Distributor.Distributor_ID 
					FROM 	Billback_Distributor 
					WHERE 	Billback_ID = @Billback_ID 
					AND 	DELETED = 0
				END
				ELSE IF @Billback_Payee_Type_ID = 3
				BEGIN
					SELECT 	@PAYEE_ID = Associated_Ship_To
					FROM 	Billback_Broker  
					WHERE 	Billback_ID = @Billback_ID AND DELETED = 0
				END
				ELSE IF @Billback_Payee_Type_ID = 2
				BEGIN
					SELECT 	@PAYEE_ID = Associated_Ship_To
					FROM 	Billback_Operator 
					WHERE 	Billback_ID = @Billback_ID AND DELETED = 0
				END
				
				SELECT 	Shr_Ship_To, 
						BSA_Foodservice_Customers_Id
				FROM 	BSA_Foodservice_Customers
				WHERE 	BSA_Foodservice_Customers_Id = @PAYEE_ID
				AND 	Deleted = 0	
				-------Select @PAYEE_ID as Payee_id, Shr_Ship_To
			</cfquery>
			
			<cfset thisObj = CreateObject("component", "components.Billback.BillbackSummaryManager") >
			<cfset getMultiDistList = thisObj.getMultiDistList(form.Billback_ID) />
			<!--- if there is one cust use it.  check associated ship to first -> then the multi list if there is only one in the list 
					Variables.Shr_Ship_To is used below--->
			<cfif qGetdistId.recordcount eq 1>
				<cfset variables.Shr_Ship_To 					= qGetdistId.Shr_Ship_To>
				<cfset variables.BSA_Foodservice_Customers_Id 	= qGetdistId.BSA_Foodservice_Customers_Id>
			<cfelseif getMultiDistList.recordcount eq 1>
				<cfset variables.Shr_Ship_To 					= getMultiDistList.Shr_Ship_To>
				<cfset variables.BSA_Foodservice_Customers_Id 	= getMultiDistList.BSA_Foodservice_Customers_Id>
			<cfelse>
				<cfset variables.Shr_Ship_To 					= "">
				<cfset variables.BSA_Foodservice_Customers_Id 	= "">	
			</cfif>
			<!---end get payee_id--->
			
			<!---Is the program already there?--->
			<cfquery name="GetBBProgram" datasource="#application.datasource#">
				SELECT 	Billback_Program_ID 
				FROM 	Billback_Program
				WHERE 	Billback_ID = '#Form.Billback_ID#'
				AND 	Program_ID = '#variables.Contract_Main_ID#'
				AND 	Deleted = 0
			</cfquery>
			
			<!---program is not there so insert into Billback_Program--->
			<cfif GetBBProgram.Recordcount IS 0>
			
				<!---Enter information on program--->
				<cfquery name="InsertProgramInfo" datasource="#application.datasource#">
					INSERT INTO Billback_Program
					(
						Billback_ID, 
						Program_ID, 
						Created_Date
					)
					VALUES
					(
						'#Form.Billback_ID#', 
						'#variables.Contract_Main_ID#', 
						#Now()# 
					)
				</cfquery>
				
				<cfset Billback_Program_ID = InsertProgramInfo.Billback_Program_ID>
				
			<cfelse>
			
				<!---Use the ids that are already there--->
				<cfset Billback_Program_ID = GetBBProgram.Billback_Program_ID>
				
			</cfif><!---END program is not there so insert into Billback_Program--->
			
			<cfset variables.Counter = 1>
			
			
			<!---For each program loop through the number of rows (minus the last one) for the contract--->
			<cfloop condition = "variables.Counter LESS THAN OR EQUAL TO variables.ListRows">
			
				<cfif	isdefined("Amount_#variables.Contract_Main_ID#_#variables.Counter#")
						AND len(trim(evaluate("Amount_#variables.Contract_Main_ID#_#variables.Counter#"))) GT 0
						AND evaluate("IsDeleted_#variables.Contract_Main_ID#_#variables.Counter#") IS 0
						AND len(trim(evaluate("Item_#variables.Contract_Main_ID#_#variables.Counter#"))) GT 0
						AND	len(trim(evaluate("Volume_#variables.Contract_Main_ID#_#variables.Counter#"))) GT 0
				>
					<cfif (businessSegManager.isEnabled() and businessSegManager.isEnabledForProduct())>
						<cfquery name="GetBusinessSegmentID" datasource="#application.datasource#">
							SELECT 
								Business_Segment_ID,* 
							FROM 
								Contract_Main 
							WHERE Contract_Main_ID = #variables.Contract_Main_ID#
						</cfquery>
					</cfif>
					<!---It's valid--->
					<!---Check to see if it's a real item--->
					<cfquery name="IsItARealItem" datasource="#application.datasource#">
						SELECT 	BSA_Foodservice_Items_Master_ID, 
								Net_Weight
						FROM 	BSA_Foodservice_Items_Master
						WHERE 	Item = '#evaluate("Item_#variables.Contract_Main_ID#_#variables.Counter#")#'
						<cfif (businessSegManager.isEnabled() and businessSegManager.isEnabledForProduct() AND isDefined("GetBusinessSegmentID") AND GetBusinessSegmentID.RecordCount GTE 1)>
								AND Business_Segment_ID = #GetBusinessSegmentID.Business_Segment_ID#
						</cfif>
					</cfquery>
					<!--- If the above query does not return a result then search again without the Business_segment_ID --->
					<cfif (businessSegManager.isEnabled() and businessSegManager.isEnabledForProduct() AND isDefined("GetBusinessSegmentID") AND GetBusinessSegmentID.RecordCount GTE 1 AND (IsItARealItem.RecordCount EQ 0))>
						<cfquery name="IsItARealItem" datasource="#application.datasource#">
							SELECT 	BSA_Foodservice_Items_Master_ID, 
									Net_Weight
							FROM 	BSA_Foodservice_Items_Master
							WHERE 	Item = '#evaluate("Item_#variables.Contract_Main_ID#_#variables.Counter#")#'
						</cfquery>
					</cfif>					

					
					<!---Is there a distributor Id specified...if not, use payee as default (same as single dist BB)--->
					<cfif trim(evaluate("Distributor_#variables.Contract_Main_ID#_#variables.Counter#")) eq "">
						<cfif trim(variables.Shr_Ship_To) eq ""><!---if no payee, se it to 000--->
							<cfset "Distributor_#variables.Contract_Main_ID#_#variables.Counter#" = '00000000-0000-0000-0000-000000000000'>
						<cfelse>
							<cfset "Distributor_#variables.Contract_Main_ID#_#variables.Counter#" = variables.Shr_Ship_To>
						</cfif>
						
					<cfelse>
					
						<!---check if it is a real cust--->
						<cfquery name="IsItARealCust" datasource="#application.datasource#">
							SELECT 	BSA_Foodservice_Customers_Id
							FROM 	BSA_Foodservice_Customers
							WHERE
							<!--- Dev Note 12454 Ben: Added this check to see if Shr_Ship_To is null
							      Some customers don't have data in Shr_Ship_To. If that is the case
							      then we need to look at Ship_To --->
							<cfif Shr_Ship_To is "">
							 Ship_To = '#evaluate("Distributor_#variables.Contract_Main_ID#_#variables.Counter#")#'
							<cfelse>
							 Shr_Ship_To = '#evaluate("Distributor_#variables.Contract_Main_ID#_#variables.Counter#")#'
							</cfif>
							AND 	Deleted = 0
						</cfquery>
						
						<!--- Is it a Valid Cust ->
						If not...use the payee_id--->
						<cfif IsItARealCust.recordcount EQ 0>
							<cfif trim(variables.Shr_Ship_To) eq ""><!---if no payee, se it to 000--->
								<cfset "Distributor_#variables.Contract_Main_ID#_#variables.Counter#" = '00000000-0000-0000-0000-000000000000'>
							<cfelse>
								<cfset "Distributor_#variables.Contract_Main_ID#_#variables.Counter#" = variables.Shr_Ship_To>
							</cfif>							
						<cfelse>
						
							<!---<!---Is the distributor on the program--->
							<cfquery name="IsTheCustOnTheProgram" datasource="#application.datasource#">
								SELECT 	Contract_Distributors_ID 
								FROM 	Contract_Distributors
								WHERE 	Contract_Main_ID = '#variables.Contract_Main_ID#'
								AND 	BSA_Foodservice_Customers_ID = '#IsItARealCust.BSA_Foodservice_Customers_Id#'
								AND 	Deleted = 0
							</cfquery>
							
							<!---if not use payee_id...we need a valid distributor--->
							<cfif IsTheCustOnTheProgram.Recordcount EQ 0>
							
								<cfset "Distributor_#variables.Contract_Main_ID#_#variables.Counter#" = variables.Shr_Ship_To>
								
							<cfelse>--->
							
								<!---We can use the distributor Id entered--->
								<cfset variables.BSA_Foodservice_Customers_Id = IsItARealCust.BSA_Foodservice_Customers_Id>
								
							<!---</cfif>--->
							
						</cfif>
						
					</cfif>
					
					<!---<cfif trim(variables.BSA_Foodservice_Customers_Id) eq ""> <!---use the custid from the program as the default--->
						<cfquery name="qGetProgramCust" datasource="#application.datasource#">
							SELECT top 1 CD.BSA_Foodservice_Customers_ID, C.Name, C.Ship_To
								FROM Contract_Distributors CD
								JOIN BSA_Foodservice_Customers C
								ON C.BSA_Foodservice_Customers_ID = CD.BSA_Foodservice_Customers_ID 
							WHERE Contract_Main_ID in (#variables.Contract_Main_ID#)
							and C.deleted = 0
							and CD.deleted = 0
							and CD.is_group = 0
							and active_code = 'A'
						</cfquery>
					
					<cfset variables.BSA_Foodservice_Customers_Id = qGetProgramCust.BSA_Foodservice_Customers_Id>
					
					</cfif>--->
					
					<cfif IsItARealItem.Recordcount GT 0>
						<!---The item is a real item, so see if it's on the program--->
						<cfquery name="IsTheItemOnTheProgram" dbtype="query">
							SELECT 	*
							FROM 	AllEligibleProducts
							WHERE 	Product_ID = '#IsItARealItem.BSA_Foodservice_Items_Master_ID#'
						</cfquery>
						
						<cfset Product_Valid_Discount_List = "" />
						<cfif IsTheItemOnTheProgram.recordCount>						
							<cfset Product_Valid_Discount_List = ValueList(IsTheItemOnTheProgram.DiscountTypeID) />
						</cfif>
						<cfset NumberofRecords = ListLen(Product_Valid_Discount_List) />
						
						<cfif NumberofRecords GT 0>
							<cfset variables.ProductTypeID = 1>
						<cfelse>
							<cfset variables.ProductTypeID = 2>
						</cfif>
						
						<!---The item is real and it is actually on the program, so now figure out if it's already been added--->
						<cfquery name="ItemIsAlreadyThere" datasource="#application.datasource#">
							SELECT	* 
							FROM 	Billback_Product
							WHERE 	Billback_ID = '#FORM.Billback_ID#'
							AND 	Product_ID = '#IsItARealItem.BSA_Foodservice_Items_Master_ID#'
							AND 	Billback_Program_ID = '#Billback_Program_ID#'
							<cfif trim(variables.BSA_Foodservice_Customers_Id) neq "">
							And 	Distributor_id = '#variables.BSA_Foodservice_Customers_Id#'
							</cfif>
							AND 	Deleted = 0
						</cfquery>
						
						<!---The item already exists -- update the volume then check to see if it's the same discount type--->
						<cfif ItemIsAlreadyThere.Recordcount IS 1>
						
							<cfset Billback_Product_ID = ItemIsAlreadyThere.Billback_Product_ID>
							
							<!---Check the UOM to make sure you're updating the correct uom--->
							<cfif ItemIsAlreadyThere.BB_Product_UOM IS 1>
							
								<cfset NewProductVolume = ItemIsAlreadyThere.BB_Product_Quantity + evaluate("Volume_#variables.Contract_Main_ID#_#variables.Counter#")>
								
								<cfquery name="UpdateVolume" datasource="#application.datasource#">
									UPDATE 	Billback_Product
									SET 	BB_Product_Quantity = '#NewProductVolume#'
									WHERE 	Billback_Product_ID = '#ItemIsAlreadyThere.Billback_Product_ID#'
								</cfquery>
								
							<cfelse>
							
								<!---Convert the form value to the value currently in the database--->
								<!---Go get the net weight--->
								<!---The value in the db is case, the value in the form must be pound--->
								<cfif ItemIsAlreadyThere.BB_Product_UOM IS 1>
								
									<cfset NewConvertedVolume = evaluate("Volume_#variables.Contract_Main_ID#_#variables.Counter#") / IsItARealItem.Net_Weight>
									
								<!---Value in the db is pound, value in the form is case--->
								<cfelse>
								
									<cfset NewConvertedVolume = evaluate("Volume_#variables.Contract_Main_ID#_#variables.Counter#") * IsItARealItem.Net_Weight>
									
								</cfif>
								
								<!---Update--->
								<cfquery name="UpdateConvertedVolume" datasource="#application.datasource#">
									UPDATE 	Billback_Product
									SET 	BB_Product_Quantity = '#NewConvertedVolume#'
									WHERE 	Billback_Product_ID = '#ItemIsAlreadyThere.Billback_Product_ID#'
								</cfquery>
								
								<!---Updating different uom--->
							</cfif>
							
						<cfelse>
							<cfif trim(variables.BSA_Foodservice_Customers_Id) eq "">
								<cfset variables.BSA_Foodservice_Customers_Id ='00000000-0000-0000-0000-000000000000'>
							</cfif>
							<!---Just insert--->
							<cfquery name="InsertIntoBillbackProduct" datasource="#application.datasource#">
								INSERT INTO Billback_Product
								(
									Billback_ID,
									Product_ID,
									Billback_Program_ID,
									BB_Product_Quantity,
									BB_Product_UOM, 
									Product_Type_ID,
									Created_Date, 
									Deleted
									<cfif trim(variables.BSA_Foodservice_Customers_Id) neq "">,
									Distributor_id
									</cfif>
								)
								VALUES
								(
									'#Billback_ID#',
									'#IsItARealItem.BSA_Foodservice_Items_Master_ID#',
									'#Billback_Program_ID#',
									'#evaluate("Volume_#variables.Contract_Main_ID#_#variables.Counter#")#',
									1, 
									'#variables.ProductTypeID#', 
									#Now()#, 
									0
									<cfif trim(variables.BSA_Foodservice_Customers_Id) neq "">,
									'#variables.BSA_Foodservice_Customers_Id#'
									</cfif>
								)
							</cfquery>
							
							<cfset Billback_Product_ID = InsertIntoBillbackProduct.Billback_Product_ID>
							
						</cfif><!---- <cfif ItemIsAlreadyThere.Recordcount IS 1> ---->
						
						<!---Now enter the discount amount--->
						<!---If they pick the discount type, use it--->
						<cfif appsettings.BB_PP_Manual_Discount IS 1>
						
							<cfset DiscountListForThisBBProduct = evaluate("DiscountType_#variables.Contract_Main_ID#_#variables.Counter#")>
							<cfset NumberofRecords = 1>
							
						<cfelse>
						
							<!---else automatically calculate discount dispersal--->
							<!---Payable to--->
							<cfquery name="GetPayeeType" datasource="#application.datasource#">
								SELECT 	Billback_Payee_Type_ID 
								FROM 	Billback 
								WHERE 	Billback_ID = '#Billback_ID#'
							</cfquery>
							
							<cfset variables.Payee_Type = GetPayeeType.Billback_Payee_Type_ID>
							
							<!---If there is at least one--->
							<cfif ListLen(Product_Valid_Discount_List) GT 0>
							
								<cfset DiscountListForThisBBProduct = Product_Valid_Discount_List>
								
							<!--- Item is not on program, just use the discount list at the program --->
							<cfelse>
							
								<cfset DiscountListForThisBBProduct = DiscountList />
								
							</cfif>

							<cfset NumberofRecords = ListLen(DiscountListForThisBBProduct) />
					
							<!---Auto calculated discounts or user entered--->
								
						</cfif>
						
						<cfset ItemAmount 		= evaluate("Amount_#variables.Contract_Main_ID#_#variables.Counter#")>
						<cfset AmountParsed 	= 0>
						<cfset PartialAmount	= ItemAmount / NumberofRecords>
						<cfset thisCount 		= 0>
						
						<!---splits the amount between the products the item has--->
						<cfloop index="Product_Type_ID" list="#DiscountListForThisBBProduct#">
						
							<cfset thisCount = thisCount + 1>
							
							<cfif thisCount IS NumberofRecords>
							
								<cfset AmountforThisDiscount = ItemAmount - AmountParsed>
								
							<cfelse>
							
								<cfset AmountforThisDiscount = PartialAmount>
								<cfset AmountParsed = AmountParsed + PartialAmount>
								
							</cfif>
							
							<!---Is there already an entry in Billback_Product_Data?--->
							<cfquery name="AlreadyInBBProductData" datasource="#application.datasource#">
								SELECT 	TOP 1 *  
								FROM 	Billback_Product_Detail
								WHERE 	Billback_Product_ID = '#Billback_Product_ID#'
								AND		BB_Product_Type_ID = '#Product_Type_ID#'
								AND 	Deleted = 0
							</cfquery>
							
							<!---Update the product if it already exists--->
							<cfif AlreadyInBBProductData.Recordcount GT 0>
							
								<cfset NewAmountClaimed = val(AlreadyInBBProductData.BB_Rate) + AmountforThisDiscount>
								
								<cfquery name="UpdateBBProductData" datasource="#application.datasource#">
									UPDATE	Billback_Product_Detail
									SET 	BB_Rate = #NewAmountClaimed# 
									WHERE 	Billback_Product_Detail_ID = '#AlreadyInBBProductData.Billback_Product_Detail_ID#'
								</cfquery>
								
							<cfelse>
							
								<!---Just insert--->
								<cfquery name="InsertBBProductData" datasource="#application.datasource#">
									INSERT INTO Billback_Product_Detail
									(
										Billback_Product_ID,
										Billback_ID,
										BB_Product_Type_ID,
										BB_Rate,
										Created_Date,
										Deleted
										<cfif trim(variables.BSA_Foodservice_Customers_Id) neq "">,
										Distributor_ID_Earned
										</cfif>
									)
									VALUES
									(
										'#Billback_Product_ID#',
										'#Billback_ID#',
										'#Product_Type_ID#',
										'#AmountforThisDiscount#',
										#now()#,
										0
										<cfif trim(variables.BSA_Foodservice_Customers_Id) neq "">,
										'#variables.BSA_Foodservice_Customers_Id#'
										</cfif>
									)
								</cfquery>
								<!---Item already on billback--->
								
							</cfif>
							<!---Product Type recordcount--->
							
						</cfloop>
						
					<!---It's not a real Item or customer is not valid--->
					<cfelse>
					
						<cfset variables.NoItemList = listappend(variables.NoItemList, variables.Contract_Main_ID & "_" & variables.Counter, ',')>
						
					</cfif>
					
					<!---You should do anything with the record--->
				</cfif>
				
				<cfset variables.Counter = variables.Counter + 1>
				
			</cfloop><!---- products loop end ---->
			
	
			<!--- Populate approved discount table --->
			
			<!--- Get products --->
			<cfquery name="GetProductsOnProgram" datasource="#application.datasource#">
			SELECT DISTINCT Billback_Product.Product_ID
			FROM Billback_Product_Detail
				INNER JOIN Billback_Product
				ON  Billback_Product.Billback_ID = '#form.Billback_ID#' AND
					Billback_Product.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID
					AND Billback_Product.Deleted = 0
					AND Billback_Product.Product_Type_ID = 1 -- product on program
				INNER JOIN Billback_Program
					ON Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID
					AND Billback_Program.Deleted = 0
					AND Billback_Program.Program_ID = '#variables.Contract_Main_ID#'
			WHERE Billback_Product_Detail.Billback_ID = '#form.Billback_ID#'
			AND Billback_Product_Detail.Deleted = 0
			</cfquery>
			
			<!--- If there's already values, you need to delete them --->
			<cfquery name="DeletePriorValues" datasource="#application.datasource#">
			DELETE FROM BB_Product_Discount
			WHERE Billback_ID = '#form.Billback_ID#'
			AND Program_ID = '#variables.Contract_Main_ID#'
			</cfquery>

			<!--- D12106 Find valid discount types --->
			<cfloop query="GetProductsOnProgram">
			
				<cfset Discount_List = "">
			
				<cfquery name="DiscountsForProduct" dbtype="query">
					SELECT DISTINCT DiscountTypeID
					FROM AllEligibleProducts
					WHERE Product_ID = '#Product_ID#'
				</cfquery>
				
				<cfif DiscountsForProduct.Recordcount GT 0>
					<cfset Discount_List = valuelist(DiscountsForProduct.DiscountTypeID)>
				</cfif>
				
				<cfquery name="InsertIntoTable" datasource="#application.datasource#">
				INSERT INTO BB_Product_Discount
				(
					Discount_List,
					Product_ID,
					Billback_ID,
					Program_ID
				)
				VALUES
				(
					'#Discount_List#',
					'#Product_ID#',
					'#Billback_ID#',
					'#variables.Contract_Main_ID#'
				)
				</cfquery>
			<!--- loop through products for valid/invalid ---->	
			</cfloop>

		</cfloop><!---END Loop through programs started at the top of the page--->	
		
		
		</cfsilent>
		
	</cftransaction>

	<cfif len(trim(variables.NoItemList)) GT 0>
		<form name="InvalidItems" action="power_punch_action_secondary.cfm" method="post">
			<table>
				<tr>
					<th colspan="100%" bgcolor="orange"><strong><font size="3">Items not recognized</font></strong></th>
				</tr>
				
				<!--- Dev Note : Kal: 12235: Cant remove item under the Unknown Products section on BB - [HZQ65]
						Commented the code below to remove ability to add unknown products --->
				<!--- <tr>
					<td><strong>Add Item</strong></td>
					<td><strong>Item Number</strong></td>
					<td><strong>Name</strong></td>
					<td><strong>Description</strong></td>
					<td><strong>Notes</strong></td>
				</tr> --->
				
				<!---All no good items--->
				<cfset NoItemList_Counter = 0 />
				<tr>
					<td valign="top"><br>
				<cfloop index="Row_CM_Partnering" list="#variables.NoItemList#" delimiters=",">
							<strong><font size="2">#evaluate("Item_#Row_CM_Partnering#")#</font></strong>
							<cfset NoItemList_Counter = NoItemList_Counter+1 />
							<cfif listlen(variables.NoItemList) GT NoItemList_Counter>,</cfif>
						</cfloop>
					</td>
				</tr>
					<tr>
					<td valign="top" colspan="100%"><br><strong><font size="2">Above items are invalid and were not added.</font></strong></td>
					</tr>
				<!--- End Note : Kal: 12235: Cant remove item under the Unknown Products section on BB - [HZQ65] --->	
			</table>
			<input type="hidden" name="Billback_ID" value="#Billback_ID#">
		<div align="center">
			<CF_button
				button_name		=	""
				button_caption	=	"continue"
				button_action	=	"document.InvalidItems.submit();"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	"Save and continue"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</div>
		</form>
	<cfelse>
		<cflocation url="/billbacks/capture/program_form.cfm?BBID=#Billback_ID#">
	</cfif>
</cfoutput> 
<script>
	try { window.parent.dyniframesize(); } catch (err) { };
</script>