

<cfparam name="DiscountList" default= "1,2,4,5">

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfoutput>

<cfif isDefined("UseRecord")>
<cfif len(trim(UseRecord)) GT 0>
<cfloop index="Row_CM_Partnering" list="#UseRecord#" delimiters=",">

	<cfset UnderscoreLocation = Find("_", Row_CM_Partnering)>
	<cfset Contract_Main_ID = left(Row_CM_Partnering, UnderscoreLocation - 1)>

	<!---GetBBContractNumber--->
	<cfquery name="GetBBContractNumber" datasource="#application.datasource#">
	SELECT TOP 1 Billback_Program_ID FROM Billback_Program WHERE Program_ID = '#Contract_Main_ID#' AND Billback_ID = '#Billback_ID#' AND Deleted = 0 ORDER BY Created_Date DESC
	</cfquery>
	
	<cfset Billback_Program_ID = GetBBContractNumber.Billback_Program_ID>
	
	
	<cfquery name="IsItARealItem" datasource="#application.datasource#">
	SELECT *
	FROM BSA_Foodservice_Items_Master
	WHERE Item = '#evaluate("Item_#Row_CM_Partnering#")#'		
	</cfquery>
	
	<!---It is a real item--->
	<cfif IsItARealItem.Recordcount IS 1>

		<!---Identical to the insert section on power_punch_action.cfm--->
		<!---The item is real and it is actually on the program, so now figure out if it's already been added--->
		
		<cfquery name="IsTheItemOnTheProgram" datasource="#application.datasource#">
		SELECT Contract_Products_ID FROM Contract_Products
		WHERE Contract_Main_ID = '#Contract_Main_ID#'
		AND BSA_Foodservice_Items_Master_ID = '#IsItARealItem.BSA_Foodservice_Items_Master_ID#'
		AND Deleted = 0
		</cfquery>
			
			<Cfif ISTheItemOnTheProgram.Recordcount GT 0>
				<cfset ProductTypeID = 1>
			<cfelse>
				<cfset ProductTypeID = 2>
			</CFIF>

				<cfquery name="ItemIsAlreadyThere" datasource="#application.datasource#">
				SELECT * 
				FROM Billback_Product
				WHERE Billback_ID = '#FORM.Billback_ID#'
				AND Product_ID = '#IsItARealItem.BSA_Foodservice_Items_Master_ID#'
				AND Billback_Program_ID = '#Billback_Program_ID#'
				AND Distributor_ID = '#evaluate("Distributor_#Row_CM_Partnering#")#'	
				</cfquery>
				
				<!---The item already exists -- update the volume then check to see if it's the same discount type--->
				<cfif ItemIsAlreadyThere.Recordcount IS 1>
				
				<cfset Billback_Product_ID = ItemIsAlreadyThere.Billback_Product_ID>
				
				<!---Check the UOM to make sure you're updating the correct uom--->
				<cfif ItemIsAlreadyThere.BB_Product_UOM IS 1>

					<cfset NewProductVolume = ItemIsAlreadyThere.BB_Product_Quantity + evaluate("Volume_#Row_CM_Partnering#")>
	
					<cfquery name="UpdateVolume" datasource="#application.datasource#">
					UPDATE Billback_Product
					SET BB_Product_Quantity = '#NewProductVolume#'
					WHERE Billback_Product_ID = '#ItemIsAlreadyThere.Billback_Product_ID#'
					</cfquery>
				
				<cfelse>
				<!---Convert the form value to the value currently in the database--->
				
					<!---Go get the net weight--->
						<!---The value in the db is case, the value in the form must be pound--->
					<cfif ItemIsAlreadyThere.BB_Product_UOM IS 1>
						<cfset NewConvertedVolume = evaluate("Volume_#Row_CM_Partnering#")/IsItARealItem.Net_Weight>
					<!---Value in the db is pound, value in the form is case--->
					<cfelse>
						<cfset NewConvertedVolume = evaluate("Volume_#Row_CM_Partnering#") * IsItARealItem.Net_Weight>
					</cfif>
					
					<!---Update--->
					<cfquery name="UpdateConvertedVolume" datasource="#application.datasource#">
					UPDATE Billback_Product
					SET BB_Product_Quantity = '#NewConvertedVolume#'
					WHERE Billback_Product_ID = '#ItemIsAlreadyThere.Billback_Product_ID#'
					</cfquery>
				
				<!---Updating different uom--->	
				</cfif>
					
				<cfelse>
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
					Distributor_ID, 
					Deleted
				)
				VALUES
				(
					'#Billback_ID#',
					'#IsItARealItem.BSA_Foodservice_Items_Master_ID#',
					'#Billback_Program_ID#',
					'#evaluate("Volume_#Row_CM_Partnering#")#',
					1<!--- '#evaluate("UOM_#Row_CM_Partnering#")#' --->, 
					'#ProductTypeID#',
					#Now()#, 
					'#evaluate("Distributor_#Row_CM_Partnering#")#',
					0
				)
				</cfquery>
				
				<cfset Billback_Product_ID = InsertIntoBillbackProduct.Billback_Product_ID>
				
				</cfif>
				
			<!---Now enter the discount amount with the same rigamarole--->
			
			<!---If they pick the discount type, use it--->
			<cfif appsettings.BB_PP_Manual_Discount IS 1>
				<cfset DiscountList = evaluate("DiscountType_#Row_CM_Partnering#")>
				<cfset NumberofRecords = 1>
				
			<cfelse>
			
				<!---Payable to--->
			<cfquery name="GetPayeeType" datasource="#application.datasource#">
			SELECT Billback_Payee_Type_ID FROM Billback WHERE Billback_ID = '#Billback_ID#'
			</cfquery>
			
			<cfset Payee_Type = GetPayeeType.Billback_Payee_Type_ID>
			
			<!---First, figure out if there are any discounts on the program with that item--->
			<cfquery name="ProductOnProgram" datasource="#application.datasource#">
			SELECT Product_Type_ID, Contract_Main_ID 
			FROM Contract_Products
			WHERE Contract_Main_ID = '#Contract_Main_ID#'
			AND BSA_Foodservice_Items_Master_ID = '#IsItARealItem.BSA_Foodservice_Items_Master_ID#'
			AND Product_Type_ID IN ('1','2','4','5')
			</cfquery>
			
			<!---If there is at least one--->
			<cfif ProductOnProgram.Recordcount GT 0>
					
				<cfset DiscountList = valuelist(ProductOnProgram.Product_Type_ID)>	
				<cfset NumberofRecords = ProductOnProgram.Recordcount>
			
			
			<cfif appSettings.fixedcomponents_on IS 1>
				<!---Checking fixed price rebate--->
				<cfif listfind(DiscountList, '1')>
					<cfquery name="GetFixedPayeeTo" datasource="#application.datasource#">
					SELECT Program_Fixed_Component.Fixed_Component_Paid_To
					FROM Program_Fixed_Component
					WHERE Program_Fixed_Component.Fixed_Component_Paid_To = #Payee_Type#
					AND Program_Fixed_Component.Program_ID = #ProductOnProgram.Contract_Main_ID#
					AND Program_Fixed_Component.Deleted = 0
					</cfquery>
								
					<cfif GetFixedPayeeTo.RecordCount IS 0>
						<cfset FixedLocation = listfind(DiscountList, '1')>
						<cfif FixedLocation IS NOT 0>
							<cfset DiscountList = listdeleteat(DiscountList, FixedLocation)>
						<cfset NumberofRecords = NumberofRecords - 1>
						</cfif>
						<cfif NumberofRecords IS 0>
							<cfset NumberofRecords = 4>
							<cfset DiscountList = "1,2,4,5">	
						</cfif>
					</cfif>
				</cfif>
			<!---Fixed components on--->	
			</cfif>
				
				<cfif listfind(DiscountList, '2')>
					<cfquery name="GetRebatePayeeTo" datasource="#application.datasource#">
					SELECT Program_Rebates_Component.Component_Paid_To
					FROM Program_Rebates_Component
					WHERE Program_Rebates_Component.Component_Paid_To = #Payee_Type#
					AND Program_Rebates_Component.Program_ID = #ProductOnProgram.Contract_Main_ID#
					AND Program_Rebates_Component.Deleted = 0
					</cfquery>
					
					<cfif GetRebatePayeeTo.RecordCount IS 0>
						<cfset RebateLocation = listfind(DiscountList, '2')>
						<cfif RebateLocation IS NOT 0>
							<cfset DiscountList = listdeleteat(DiscountList, RebateLocation)>
						<cfset NumberofRecords = NumberofRecords - 1>
						</cfif>
						<cfif NumberofRecords IS 0>
							<cfset NumberofRecords = 4>
							<cfset DiscountList = "1,2,4,5">	
						</cfif>
					</cfif>
				</cfif>
			<!---Item is not on program--->
			<cfelse>
					
				<cfset NumberofRecords = 4>
			<!---Item is not on program--->
			</cfif>
			
			<!---Auto calculated discounts or user entered--->
			</cfif>
			
			<cfset ItemAmount = evaluate("Amount_#Row_CM_Partnering#")>
			<cfset AmountParsed = 0>
			<cfset PartialAmount = ItemAmount / NumberofRecords>
			<cfset thisCount = 0>
			
			<!---splits the amount between the products the item has--->
			<cfloop index="Product_Type_ID" list="#DiscountList#">
	
			
				<cfset thisCount = thisCount + 1>
				<cfif thisCount IS NumberofRecords>
					<cfset AmountforThisDiscount = ItemAmount - AmountParsed>
				<cfelse>
					<cfset AmountforThisDiscount = PartialAmount>
					<cfset AmountParsed = AmountParsed + PartialAmount>
				</cfif>
			
			
			<!---Is there already an entry in Billback_Product_Data?--->		
			<cfquery name="AlreadyInBBProductData" datasource="#application.datasource#">
			SELECT TOP 1 *  FROM Billback_Product_Detail
			WHERE Billback_Product_ID = '#Billback_Product_ID#'
			AND	BB_Product_Type_ID = '#Product_Type_ID#'
			AND Deleted = 0
			</cfquery>
			
			<!---Update the product if it already exists--->
			<cfif AlreadyInBBProductData.Recordcount GT 0>
			
			<cfset NewAmountClaimed = AlreadyInBBProductData.BB_Rate + AmountforThisDiscount>
				<cfquery name="UpdateBBProductData" datasource="#application.datasource#">
				UPDATE Billback_Product_Detail
				SET BB_Rate = #NewAmountClaimed#
				WHERE Billback_Product_Detail_ID = '#AlreadyInBBProductData.Billback_Product_Detail_ID#'
				</cfquery>
			
			<cfelse>
			<!---Just insert--->
				<cfquery name="InsertBBProductData" datasource="#application.datasource#">
				INSERT INTO Billback_Product_Detail
				(
					Billback_Product_ID,
					BB_Product_Type_ID,
					BB_Rate,
					Billback_ID,
					Created_Date,
					Distributor_ID_Earned,
					Deleted
				)
				VALUES
				(
					'#Billback_Product_ID#',
					'#Product_Type_ID#',
					'#AmountforThisDiscount#',
					'#Billback_ID#',
					#now()#,
					'#evaluate("Distributor_#Row_CM_Partnering#")#',
					0
				)
				</cfquery>
			</cfif>
		</cfloop>
	<!---It's not a real item -- enter into unknown item table--->
	<cfelse>

		<cfparam name="Item_#Row_CM_Partnering#" 	default=" ">
		<cfparam name="Desc_#Row_CM_Partnering#" 	default=" ">
		<cfparam name="Volume_#Row_CM_Partnering#" 	default=" ">
		<cfparam name="Notes_#Row_CM_Partnering#" 	default=" ">

		<!---Insert unknown--->
		<cfquery name="InsertUnknownItem" datasource="#application.datasource#"> 
		INSERT INTO Billback_Product
		(
			Billback_ID,
			Billback_Program_ID,
			BB_Unknown_Product_Item_Number,
			BB_Unknown_Product_Description,
			BB_Unknown_Product_Notes,
			BB_Product_Quantity,
			BB_Product_UOM,
			Product_Type_ID,
			Distributor_ID
		)
		VALUES
		(
			'#Billback_ID#',
			'#Billback_Program_ID#',
			'#evaluate("Item_#Row_CM_Partnering#")#',
			'#evaluate("Desc_#Row_CM_Partnering#")#',
			'#evaluate("Notes_#Row_CM_Partnering#")#',
			'#evaluate("Volume_#Row_CM_Partnering#")#',
			1,
			3,
			'#evaluate("Distributor_#Row_CM_Partnering#")#'
		)
		</cfquery>
	
	
		<cfset NumberofRecords = 4>
		
		<cfset ItemAmount = evaluate("Amount_#Row_CM_Partnering#")>
		<cfset AmountParsed = 0>
		<cfset PartialAmount = ItemAmount / NumberofRecords>
		<cfset thisCount = 0>
		
		<cfset UnknownItemID = InsertUnknownItem.Billback_Product_ID>
		
		<cfif appsettings.BB_PP_Manual_Discount IS 1>
				<cfset DiscountList = evaluate("DiscountType_#Row_CM_Partnering#")>
				<cfset NumberofRecords = 1>
				<cfset thisCount =3>
		</cfif>
		
			<!---splits the amount between the products the item has--->
		<cfloop index="Product_Type_ID" list="#DiscountList#">

			<cfset thisCount = thisCount + 1>
			<cfif thisCount IS 4>
				<cfset AmountforThisDiscount = ItemAmount - AmountParsed>
			<cfelse>
				<cfset AmountforThisDiscount = PartialAmount>
				<cfset AmountParsed = AmountParsed + PartialAmount>
			</cfif>
		
	
			<cfquery name="InsertBBProductData" datasource="#application.datasource#">
				INSERT INTO Billback_Product_Detail
				(
					Billback_Product_ID,
					Billback_ID,
					BB_Product_Type_ID,
					BB_Rate,
					Created_Date,
					Distributor_ID_Earned,
					Deleted
				)
				VALUES
				(
					'#UnknownItemID#',
					'#Billback_ID#',
					'#Product_Type_ID#',
					'#AmountforThisDiscount#',
					#now()#,
					'#evaluate("Distributor_#Row_CM_Partnering#")#',
					0
				)
				</cfquery>
		</cfloop>
	</cfif>

</cfloop>
</cfif>
</cfif>

<cflocation url="/billbacks/capture/program_form.cfm?BBID=#Billback_ID#">

</cfoutput>