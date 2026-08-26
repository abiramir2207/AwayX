<cfcomponent hint="Program Change Log" extends="components.Base">

	<cffunction name="init" output="false" returntype="components.programs.changeLog">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getChangedPrograms" output="false" returntype="query">
		
		<!------ TODO: Get the ones sent to SAP ----->
		<cfquery name="qGetChangedPrograms" datasource="#application.datasource#">
			SELECT	
					Contract_Main.Contract_Main_ID Child_Contract_Main_ID, Contract_Main.Contract_Number, 
					Contract_Main.Contract_Title, Parent_Contract_Main.Contract_Title Parent_Contract_Title, 
					Contract_Main.Contract_Start_Date Eff_Date, Parent_Contract_Main.Contract_Start_Date, 
					Contract_Main.Contract_End_Date, Parent_Contract_Main.Contract_End_Date Parent_End_Date, 
					Contract_Main.Contract_Quantity Child_Contract_Quantity, Child_Units_Of_Measure.Abbreviation Child_Contract_Quantity_UOM,
					Parent_Contract_Main.Contract_Main_ID Parent_Contract_Main_ID, Contract_Main.Contract_Quantity Parent_Contract_Quantity, Parent_Units_Of_Measure.Abbreviation Parent_Contract_Quantity_UOM,
					Contract_Main.Notes, Parent_Contract_Main.Notes Parent_Notes,
					CU.Name_First + ' ' + CU.Name_Last As Child_Approver,
					PU.Name_First + ' ' + PU.Name_Last As Parent_Approver,
					CSP.Name_First + ' ' + CSP.Name_Last As Child_SP,
					Program_Control_Panel_Options.Specify_Operators, Program_Control_Panel_Options.Specify_Distributors,
					Program_Control_Panel_Options.Specify_Brokers, Program_Control_Panel_Options.Discount_Fixed_Prices,
					Program_Control_Panel_Options.Discount_Rebates, Program_Control_Panel_Options.Discount_Lump_Sums,
					Program_Control_Panel_Options.Discount_Growth, Program_Control_Panel_Options.Discount_Formula_Pricing,
					Program_Control_Panel_Options.Generic_Type, 
					Contract_Main.Cancelled_Date,
					CancelledUser.Name_First + ' ' + CancelledUser.Name_Last As Cancelled_By_User,
					ISNULL(Contract_Main.Manual_Cancel, 0) Manual_Cancel
			FROM	Contract_Main
					LEFT JOIN Contract_Main Parent_Contract_Main
					ON
					Parent_Contract_Main.Contract_Main_ID = Contract_Main.Parent_Revised_Contract_Main_ID
					<!------ Program template ----->
					INNER JOIN Program_Control_Panel_Options
					ON
					Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
					<!------ Volume UOM ----->
					INNER JOIN Units_Of_Measure Child_Units_Of_Measure
					ON
					Child_Units_Of_Measure.Unit_Of_Measure_ID = Contract_Main.Contract_Quantity_UOM_IDX
					LEFT JOIN Units_Of_Measure Parent_Units_Of_Measure
					ON
					Parent_Units_Of_Measure.Unit_Of_Measure_ID = Parent_Contract_Main.Contract_Quantity_UOM_IDX
					<!------ Approver ----->
					LEFT JOIN _Users CU
					ON
					CU.Deleted = 0
					AND CU.User_ID = Contract_Main.Approved_By_User_ID
					LEFT JOIN _Users PU
					ON
					PU.Deleted = 0
					AND PU.User_ID = Parent_Contract_Main.Approved_By_User_ID
					<!------ Sales Person Responsible ----->
					LEFT JOIN _Users CSP
					ON
					CSP.Deleted = 0
					AND CSP.User_ID = Contract_Main.Responsible_User_ID
					<!------ Cancelled_By ----->
					LEFT JOIN _Users CancelledUser
					ON
					CancelledUser.Deleted = 0
					AND CancelledUser.User_ID = Contract_Main.Cancelled_By
			WHERE	Contract_Main.Deleted = 0
					AND
					(
					(
					Contract_Main.Parent_Revised_Contract_Main_ID IS NOT NULL 
					AND Contract_Main.Revision_of_Contract_Main_ID IS NOT NULL 
					<!------ TODO: ----->
					AND Parent_Contract_Main.Sent_To_External_Client = 1
					AND Contract_Main.Sent_To_External_Client = 0
					AND Parent_Contract_Main.Contract_Main_ID IS NOT NULL
					)
					OR
					Contract_Main.Manual_Cancel = 1
					AND Contract_Main.Sent_To_External_Client = 1
					AND Contract_Main.Cancel_Sent_To_External_Client = 0
					)
					AND Contract_Main.Contract_Status_Type_IDX >= 4					
		</cfquery>

		<cfreturn qGetChangedPrograms>
		
	</cffunction>
	
	<cffunction name="getOperatorsRemoved" output="false" returntype="query">
	
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<cfargument name="showOnlyChange" type="numeric" required="true">
		
		<cfquery name="qGetOperator" datasource="#application.datasource#">
			SELECT	
					CASE 
					WHEN Child_Contract_Operators.BSA_Operator_ID IS NULL THEN
						''
					ELSE
						BSA_Operator.Operator_Name
					END As Child_Name,
					CASE 
					WHEN Parent_Contract_Operators.BSA_Operator_ID IS NULL THEN
						''
					ELSE
						BSA_Operator.Operator_Name
					END As Parent_Name,
					CASE 
					WHEN Child_Contract_Operators.BSA_Operator_ID IS NULL AND Parent_Contract_Operators.BSA_Operator_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE 
					WHEN Child_Contract_Operators.BSA_Operator_ID IS NOT NULL AND Parent_Contract_Operators.BSA_Operator_ID IS NULL THEN
						1
					ELSE
						0
					END As Added,
					0 As Change
			FROM	Contract_Main
					LEFT JOIN Contract_Operators Child_Contract_Operators
					ON	Child_Contract_Operators.Deleted = 0
					AND	Child_Contract_Operators.Contract_Main_ID = Contract_Main.Contract_Main_ID
					LEFT JOIN Contract_Operators Parent_Contract_Operators
					ON	Parent_Contract_Operators.Deleted = 0
					AND	Parent_Contract_Operators.Contract_Main_ID = #arguments.ProgramId2#
					AND	Child_Contract_Operators.BSA_Operator_ID = Parent_Contract_Operators.BSA_Operator_ID
					INNER JOIN BSA_Operator
					ON	BSA_Operator.Deleted = 0
					AND	(BSA_Operator.BSA_Operator_ID = Child_Contract_Operators.BSA_Operator_ID
						OR
						BSA_Operator.BSA_Operator_ID = Parent_Contract_Operators.BSA_Operator_ID
						)
					AND ISNULL(Child_Contract_Operators.BSA_Operator_ID, Parent_Contract_Operators.BSA_Operator_ID) = ISNULL(Parent_Contract_Operators.BSA_Operator_ID, Child_Contract_Operators.BSA_Operator_ID)
					<cfif arguments.showOnlyChange>
					AND Parent_Contract_Operators.BSA_Operator_ID IS NULL
					</cfif>
					<!------ AND (Child_Contract_Operators.BSA_Operator_ID IS NULL OR Parent_Contract_Operators.BSA_Operator_ID IS NULL) ----->
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
		</cfquery>
		
		<cfreturn qGetOperator>
		
	</cffunction>
		
	<cffunction name="getDistributorsRemoved" output="false" returntype="query">
	
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<cfargument name="showOnlyChange" type="numeric" required="true">
		
		<cfquery name="qGetDistributor" datasource="#application.datasource#">
			SELECT	DISTINCT BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
					CASE 
					WHEN Child_Contract_Distributors.BSA_Foodservice_Customers_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Customers.Name
					END As Child_Name,
					CASE 
					WHEN Parent_Contract_Distributors.BSA_Foodservice_Customers_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Customers.Name
					END As Parent_Name,
					Child_Contract_Distributors.BSA_Foodservice_Customers_ID Child_ID,
					Parent_Contract_Distributors.BSA_Foodservice_Customers_ID Parent_ID,
					Parent_Contract_Distributors.Program_Weight Parent_Weight,
					Child_Contract_Distributors.Program_Weight Child_Weight,
					CASE 
					WHEN Child_Contract_Distributors.BSA_Foodservice_Customers_ID IS NULL AND Parent_Contract_Distributors.BSA_Foodservice_Customers_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE 
					WHEN Child_Contract_Distributors.BSA_Foodservice_Customers_ID IS NOT NULL AND Parent_Contract_Distributors.BSA_Foodservice_Customers_ID IS NULL THEN
						1
					ELSE
						0
					END As Added,
					CASE
					WHEN Child_Contract_Distributors.BSA_Foodservice_Customers_ID IS NOT NULL AND Parent_Contract_Distributors.BSA_Foodservice_Customers_ID IS NOT NULL AND Parent_Contract_Distributors.Program_Weight <> Child_Contract_Distributors.Program_Weight THEN
						1
					ELSE
						0
					END As Change
			FROM	Contract_Main
					LEFT JOIN Contract_Distributors Child_Contract_Distributors
					ON	Child_Contract_Distributors.Deleted = 0
					AND	Child_Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
					LEFT JOIN Contract_Distributors Parent_Contract_Distributors
					ON	Parent_Contract_Distributors.Deleted = 0
					AND	Parent_Contract_Distributors.Contract_Main_ID = #arguments.ProgramId2#
					AND	Child_Contract_Distributors.BSA_Foodservice_Customers_ID = Parent_Contract_Distributors.BSA_Foodservice_Customers_ID
					INNER JOIN BSA_Foodservice_Customers
					ON	BSA_Foodservice_Customers.Deleted = 0
					AND	(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Child_Contract_Distributors.BSA_Foodservice_Customers_ID
						OR
						BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Parent_Contract_Distributors.BSA_Foodservice_Customers_ID
						)
					AND ISNULL(Child_Contract_Distributors.BSA_Foodservice_Customers_ID, Parent_Contract_Distributors.BSA_Foodservice_Customers_ID) = ISNULL(Parent_Contract_Distributors.BSA_Foodservice_Customers_ID, Child_Contract_Distributors.BSA_Foodservice_Customers_ID)
					<cfif arguments.showOnlyChange>
					AND Parent_Contract_Distributors.BSA_Foodservice_Customers_ID IS NULL
					</cfif>					
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
		</cfquery>
		
		<cfreturn qGetDistributor>
	
	</cffunction>
	
	
	<cffunction name="getBrokersRemoved" output="false" returntype="query">
	
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<cfargument name="showOnlyChange" type="numeric" required="true">
		
		<cfquery name="qGetBroker" datasource="#application.datasource#">
			SELECT	DISTINCT BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID,
					CASE 
					WHEN Child_Contract_Brokers.BSA_Foodservice_Brokers_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Brokers.Broker_Name
					END As Child_Name,
					CASE 
					WHEN Parent_Contract_Brokers.BSA_Foodservice_Brokers_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Brokers.Broker_Name
					END As Parent_Name,
					CASE 
					WHEN Child_Contract_Brokers.BSA_Foodservice_Brokers_ID IS NULL AND Parent_Contract_Brokers.BSA_Foodservice_Brokers_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE 
					WHEN Child_Contract_Brokers.BSA_Foodservice_Brokers_ID IS NOT NULL AND Parent_Contract_Brokers.BSA_Foodservice_Brokers_ID IS NULL THEN
						1
					ELSE
						0
					END As Added,
					0 As Change
			FROM	Contract_Main
					INNER JOIN Contract_Brokers Child_Contract_Brokers
					ON	Child_Contract_Brokers.Deleted = 0
					AND	Child_Contract_Brokers.Contract_Main_ID = Contract_Main.Contract_Main_ID
					LEFT JOIN Contract_Brokers Parent_Contract_Brokers
					ON	Parent_Contract_Brokers.Deleted = 0
					AND	Parent_Contract_Brokers.Contract_Main_ID = #arguments.ProgramId2#
					AND Child_Contract_Brokers.BSA_Foodservice_Brokers_ID = Parent_Contract_Brokers.BSA_Foodservice_Brokers_ID
					INNER JOIN BSA_Foodservice_Brokers
					ON	BSA_Foodservice_Brokers.Deleted = 0
					AND	(BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Child_Contract_Brokers.BSA_Foodservice_Brokers_ID
						OR
						BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Parent_Contract_Brokers.BSA_Foodservice_Brokers_ID
						)
					AND ISNULL(Child_Contract_Brokers.BSA_Foodservice_Brokers_ID, Parent_Contract_Brokers.BSA_Foodservice_Brokers_ID) = ISNULL(Parent_Contract_Brokers.BSA_Foodservice_Brokers_ID, Child_Contract_Brokers.BSA_Foodservice_Brokers_ID)
					<cfif arguments.showOnlyChange>
					AND Parent_Contract_Brokers.BSA_Foodservice_Brokers_ID IS NULL
					</cfif>					
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
		</cfquery>
		
		<cfreturn qGetBroker>
		
	</cffunction>
	
	<cffunction name="getOffInvoiceRemoved" output="false" returntype="query">
	
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<cfargument name="showOnlyChange" type="numeric" required="true">
		
		<cfquery name="qGetOffInvoice" datasource="#application.datasource#">
			SELECT	DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					First_Contract_Products.BSA_Foodservice_Items_Master_ID First_ID,
					Second_Contract_Products.BSA_Foodservice_Items_Master_ID Second_ID,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As First_Name,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As Second_Name,
					First_OffInvoice.Discount_Amount * (CASE WHEN First_OffInvoice.Plus_Minus = 1 THEN 1 ELSE -1 END) First_Rate,
					Second_OffInvoice.Discount_Amount * (CASE WHEN Second_OffInvoice.Plus_Minus = 1 THEN 1 ELSE -1 END) Second_Rate,
					First_Units_Of_Measure.Abbreviation First_UOM,
					Second_Units_Of_Measure.Abbreviation Second_UOM,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						1
					ELSE
						0
					END As Added,
					CASE
					WHEN 	First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL  
							AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL  
							AND (
								First_OffInvoice.Discount_Amount <> Second_OffInvoice.Discount_Amount 
								OR
								First_OffInvoice.Plus_Minus <> Second_OffInvoice.Plus_Minus 
								OR 
								First_Units_Of_Measure.Abbreviation <> Second_Units_Of_Measure.Abbreviation
								) THEN
						1
					ELSE
						0
					END As Change
			FROM	Contract_Main
					<!------ Contract Products ----->
					INNER JOIN Contract_Products First_Contract_Products
					ON	First_Contract_Products.Deleted = 0
					AND	First_Contract_Products.Product_Type_ID = 8
					AND	First_Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND 
					(
						<!------ Group ----->
						(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
					) 
					LEFT JOIN Contract_Products Second_Contract_Products
					ON	Second_Contract_Products.Deleted = 0
					AND	Second_Contract_Products.Product_Type_ID = 8
					AND	Second_Contract_Products.Contract_Main_ID = #arguments.ProgramId2#
					AND	First_Contract_Products.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
					AND 
					(
						<!------ Group ----->
						(Second_Contract_Products.Product_Group_ID = CAST(Second_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Second_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Second_Contract_Products.Product_Group_ID, '') = '' AND Second_Contract_Products.Is_Group = 0)
					) 
					<!------ Fixed ----->
					INNER JOIN Program_OffInvoice_Product_Data First_OffInvoice
					ON	First_OffInvoice.Deleted = 0
					AND	First_OffInvoice.Contract_Products_ID = First_Contract_Products.Contract_Products_ID
					LEFT JOIN Program_OffInvoice_Product_Data Second_OffInvoice
					ON	Second_OffInvoice.Deleted = 0
					AND	Second_OffInvoice.Contract_Products_ID = Second_Contract_Products.Contract_Products_ID					
					<!------ UOM ----->
					INNER JOIN Units_Of_Measure First_Units_Of_Measure
					ON
					First_Units_Of_Measure.Unit_Of_Measure_ID = First_OffInvoice.UOM
					LEFT JOIN Units_Of_Measure Second_Units_Of_Measure
					ON
					Second_Units_Of_Measure.Unit_Of_Measure_ID = Second_OffInvoice.UOM
					INNER JOIN BSA_Foodservice_Items_Master
					ON	BSA_Foodservice_Items_Master.Deleted = 0
					AND	(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = First_Contract_Products.BSA_Foodservice_Items_Master_ID
						OR
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
						)
					<cfif arguments.showOnlyChange>
					AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL
					</cfif>
					AND ISNULL(First_Contract_Products.BSA_Foodservice_Items_Master_ID, Second_Contract_Products.BSA_Foodservice_Items_Master_ID) = ISNULL(Second_Contract_Products.BSA_Foodservice_Items_Master_ID, First_Contract_Products.BSA_Foodservice_Items_Master_ID)
					AND (First_Contract_Products.Product_Type_ID = 8 OR Second_Contract_Products.Product_Type_ID = 8)
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
		</cfquery>
		
		<cfreturn qGetOffInvoice />
	
	</cffunction>
	
	<cffunction name="getBidRequestRemoved" output="false" returntype="query">
	
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<cfargument name="showOnlyChange" type="numeric" required="true">
		
		<cfquery name="qGetBidRequest" datasource="#application.datasource#">
			SELECT	DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					First_Contract_Products.BSA_Foodservice_Items_Master_ID First_ID,
					Second_Contract_Products.BSA_Foodservice_Items_Master_ID Second_ID,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As First_Name,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As Second_Name,
					First_BidRequest.Price First_Price,
					Second_BidRequest.Price Second_Price,
					First_Units_Of_Measure.Abbreviation First_UOM,
					Second_Units_Of_Measure.Abbreviation Second_UOM,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						1
					ELSE
						0
					END As Added,
					CASE
					WHEN 	First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL  
							AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL  
							AND (
								First_BidRequest.Price <> Second_BidRequest.Price 
								OR 
								First_Units_Of_Measure.Abbreviation <> Second_Units_Of_Measure.Abbreviation
								) THEN
						1
					ELSE
						0
					END As Change
			FROM	Contract_Main
					<!------ Contract Products ----->
					INNER JOIN Contract_Products First_Contract_Products
					ON	First_Contract_Products.Deleted = 0
					AND	First_Contract_Products.Product_Type_ID = 10
					AND	First_Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND 
					(
						<!------ Group ----->
						(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
					) 
					LEFT JOIN Contract_Products Second_Contract_Products
					ON	Second_Contract_Products.Deleted = 0
					AND	Second_Contract_Products.Product_Type_ID = 10
					AND	Second_Contract_Products.Contract_Main_ID = #arguments.ProgramId2#
					AND	First_Contract_Products.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
					AND 
					(
						<!------ Group ----->
						(Second_Contract_Products.Product_Group_ID = CAST(Second_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Second_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Second_Contract_Products.Product_Group_ID, '') = '' AND Second_Contract_Products.Is_Group = 0)
					) 
					<!------ Fixed ----->
					INNER JOIN Program_Bid_Request_Product First_BidRequest
					ON	First_BidRequest.Deleted = 0
					AND	First_BidRequest.Contract_Products_ID = First_Contract_Products.Contract_Products_ID
					LEFT JOIN Program_Bid_Request_Product Second_BidRequest
					ON	Second_BidRequest.Deleted = 0
					AND	Second_BidRequest.Contract_Products_ID = Second_Contract_Products.Contract_Products_ID					
					<!------ UOM ----->
					INNER JOIN Units_Of_Measure First_Units_Of_Measure
					ON
					First_Units_Of_Measure.Unit_Of_Measure_ID = First_BidRequest.UOM
					LEFT JOIN Units_Of_Measure Second_Units_Of_Measure
					ON
					Second_Units_Of_Measure.Unit_Of_Measure_ID = Second_BidRequest.UOM
					INNER JOIN BSA_Foodservice_Items_Master
					ON	BSA_Foodservice_Items_Master.Deleted = 0
					AND	(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = First_Contract_Products.BSA_Foodservice_Items_Master_ID
						OR
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
						)
					<cfif arguments.showOnlyChange>
					AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL
					</cfif>
					AND ISNULL(First_Contract_Products.BSA_Foodservice_Items_Master_ID, Second_Contract_Products.BSA_Foodservice_Items_Master_ID) = ISNULL(Second_Contract_Products.BSA_Foodservice_Items_Master_ID, First_Contract_Products.BSA_Foodservice_Items_Master_ID)
					AND (First_Contract_Products.Product_Type_ID = 10 OR Second_Contract_Products.Product_Type_ID = 10)
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
		</cfquery>
		
		<cfreturn qGetBidRequest />
	
	</cffunction>
	
	<cffunction name="getFixedRemoved" output="false" returntype="query">
	
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<cfargument name="showOnlyChange" type="numeric" required="true">
		
		<cfquery name="qGetFixed" datasource="#application.datasource#">
			SELECT	DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					First_Contract_Products.BSA_Foodservice_Items_Master_ID First_ID,
					Second_Contract_Products.BSA_Foodservice_Items_Master_ID Second_ID,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Item
					END As First_Item_ID,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Item
					END As Second_Item_ID,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As First_Name,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As Second_Name,
					First_Fixed.Fixed_Price_Value First_Price,
					Second_Fixed.Fixed_Price_Value Second_Price,
					First_Units_Of_Measure.Abbreviation First_UOM,
					Second_Units_Of_Measure.Abbreviation Second_UOM,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						1
					ELSE
						0
					END As Added,
					CASE
					WHEN 	First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL  
							AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL  
							AND (
								First_Fixed.Fixed_Price_Value <> Second_Fixed.Fixed_Price_Value 
								OR 
								First_Units_Of_Measure.Abbreviation <> Second_Units_Of_Measure.Abbreviation
								) THEN
						1
					ELSE
						0
					END As Change
			FROM	Contract_Main
					<!------ Contract Products ----->
					INNER JOIN Contract_Products First_Contract_Products
					ON	First_Contract_Products.Deleted = 0
					AND	First_Contract_Products.Product_Type_ID = 1
					AND	First_Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND 
					(
						<!------ Group ----->
						(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
					) 
					LEFT JOIN Contract_Products Second_Contract_Products
					ON	Second_Contract_Products.Deleted = 0
					AND	Second_Contract_Products.Product_Type_ID = 1
					AND	Second_Contract_Products.Contract_Main_ID = #arguments.ProgramId2#
					AND	First_Contract_Products.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
					AND 
					(
						<!------ Group ----->
						(Second_Contract_Products.Product_Group_ID = CAST(Second_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Second_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Second_Contract_Products.Product_Group_ID, '') = '' AND Second_Contract_Products.Is_Group = 0)
					) 
					<!------ Fixed ----->
					INNER JOIN Program_Fixed_Price_Product_Data First_Fixed
					ON	First_Fixed.Deleted = 0
					AND	First_Fixed.Contract_Products_ID = First_Contract_Products.Contract_Products_ID
					LEFT JOIN Program_Fixed_Price_Product_Data Second_Fixed
					ON	Second_Fixed.Deleted = 0
					AND	Second_Fixed.Contract_Products_ID = Second_Contract_Products.Contract_Products_ID					
					<!------ UOM ----->
					INNER JOIN Units_Of_Measure First_Units_Of_Measure
					ON
					First_Units_Of_Measure.Unit_Of_Measure_ID = First_Fixed.Unit_Of_Measure_ID
					LEFT JOIN Units_Of_Measure Second_Units_Of_Measure
					ON
					Second_Units_Of_Measure.Unit_Of_Measure_ID = Second_Fixed.Unit_Of_Measure_ID
					INNER JOIN BSA_Foodservice_Items_Master
					ON	BSA_Foodservice_Items_Master.Deleted = 0
					AND	(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = First_Contract_Products.BSA_Foodservice_Items_Master_ID
						OR
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
						)
					<cfif arguments.showOnlyChange>
					AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL
					</cfif>
					AND ISNULL(First_Contract_Products.BSA_Foodservice_Items_Master_ID, Second_Contract_Products.BSA_Foodservice_Items_Master_ID) = ISNULL(Second_Contract_Products.BSA_Foodservice_Items_Master_ID, First_Contract_Products.BSA_Foodservice_Items_Master_ID)
					AND (First_Contract_Products.Product_Type_ID = 1 OR Second_Contract_Products.Product_Type_ID = 1)
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
		</cfquery>
		
		<cfreturn qGetFixed />
	
	</cffunction>
	
	
	<cffunction name="getAllLumpSumNames" output="false" returntype="query">
	
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		
		<cfquery name="qGetAllLumpSumNames" datasource="#application.datasource#">

			SELECT	First_Program_Lump_Sums.Program_Lump_Sum_Name_ID
			FROM	Contract_Main
					INNER JOIN Program_Lump_Sums First_Program_Lump_Sums
					ON
					First_Program_Lump_Sums.Deleted = 0
					AND First_Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID					
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
			UNION
			SELECT	First_Program_Lump_Sums.Program_Lump_Sum_Name_ID
			FROM	Contract_Main
					INNER JOIN Program_Lump_Sums First_Program_Lump_Sums
					ON
					First_Program_Lump_Sums.Deleted = 0
					AND First_Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID					
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId2#
		</cfquery>
		
		<cfreturn qGetAllLumpSumNames>
		
	</cffunction>
	
	<cffunction name="getThisLumpSum" output="false" returntype="query">
	
		<cfargument name="programId" type="numeric" required="true">
		<cfargument name="lumpSumNameId" type="string" required="true">
		
		<cfquery name="qGetAllLumpSums" datasource="#application.datasource#">

			SELECT	Program_Lump_Sum_Name.Program_Lump_Sum_Name, First_Program_Lump_Sums.Lump_Sum_Amount,
					First_Program_Lump_Sums.Program_Lump_Sum_ID
			FROM	Program_Lump_Sums First_Program_Lump_Sums
					INNER JOIN Program_Lump_Sum_Name
					ON
					Program_Lump_Sum_Name.Deleted = 0
					AND Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = First_Program_Lump_Sums.Program_Lump_Sum_Name_ID
			WHERE	First_Program_Lump_Sums.Deleted = 0
					AND First_Program_Lump_Sums.Program_Lump_Sum_Name_ID = '#arguments.lumpSumNameId#'
					AND First_Program_Lump_Sums.Program_ID = #arguments.programId#
			ORDER BY Program_Lump_Sum_Name.Program_Lump_Sum_Name, First_Program_Lump_Sums.Lump_Sum_Amount
		</cfquery>
		
		<cfreturn qGetAllLumpSums>
		
	</cffunction>
	
	<cffunction name="getLumpRemovedxx" output="false" returntype="query">
	
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		
		<cfquery name="qGetLumpsum" datasource="#application.datasource#">
			SELECT	Program_Lump_Sum_Name.Program_Lump_Sum_Name, First_Program_Lump_Sums.Lump_Sum_Amount					
			FROM	Contract_Main
					INNER JOIN Program_Lump_Sums First_Program_Lump_Sums
					ON
					First_Program_Lump_Sums.Deleted = 0
					AND First_Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID
					INNER JOIN Program_Lump_Sum_Name
					ON
					Program_Lump_Sum_Name.Deleted = 0
					AND Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = First_Program_Lump_Sums.Program_Lump_Sum_Name_ID
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
					AND 
					(First_Program_Lump_Sums.Program_Lump_Sum_Name_ID NOT IN
					(
						SELECT	DISTINCT Second_Program_Lump_Sums.Program_Lump_Sum_Name_ID
						FROM Program_Lump_Sums Second_Program_Lump_Sums
						WHERE
						Second_Program_Lump_Sums.Deleted = 0
						AND Second_Program_Lump_Sums.Program_ID = #arguments.ProgramId2#						
					)
					/*OR
					(SELECT Count(l.Program_ID)
					FROM	Program_Lump_Sums l
					WHERE	l.Deleted = 0
							AND l.Program_ID = First_Program_Lump_Sums.Program_ID
							AND l.Program_Lump_Sum_Name_ID = First_Program_Lump_Sums.Program_Lump_Sum_Name_ID
							AND l.Program_Lump_Sum_ID <= First_Program_Lump_Sums.Program_Lump_Sum_ID)
							<
					(SELECT Count(l.Program_ID)
					FROM	Program_Lump_Sums l
					WHERE	l.Deleted = 0
							AND l.Program_ID = #arguments.ProgramId2#
							AND l.Program_Lump_Sum_Name_ID = First_Program_Lump_Sums.Program_Lump_Sum_Name_ID
							)*/
					)				
		</cfquery>
		
		<cfreturn qGetLumpsum>
	</cffunction>
	
	<cffunction name="getLumpChangexx" output="false" returntype="query">
	
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		
		<cfquery name="qGetLumpsumChange" datasource="#application.datasource#">
			SELECT	First_Program_Lump_Sums.Program_Lump_Sum_ID First_Lump_ID, Second_Program_Lump_Sums.Program_Lump_Sum_ID Second_Lump_ID,
					Program_Lump_Sum_Name.Program_Lump_Sum_Name, First_Program_Lump_Sums.Lump_Sum_Amount First_Amount, Second_Program_Lump_Sums.Lump_Sum_Amount Second_Amount,
					CASE
					WHEN First_Program_Lump_Sums.Lump_Sum_Amount <> Second_Program_Lump_Sums.Lump_Sum_Amount THEN
						1
					ELSE
						0
					END As Change					
			FROM	Contract_Main
					INNER JOIN Program_Lump_Sums First_Program_Lump_Sums
					ON
					First_Program_Lump_Sums.Deleted = 0
					AND First_Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID
					INNER JOIN Program_Lump_Sum_Name
					ON
					Program_Lump_Sum_Name.Deleted = 0
					AND Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = First_Program_Lump_Sums.Program_Lump_Sum_Name_ID
					INNER JOIN Program_Lump_Sums Second_Program_Lump_Sums
					ON
					Second_Program_Lump_Sums.Deleted = 0
					AND Second_Program_Lump_Sums.Program_ID = #arguments.ProgramId2#
					AND Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Second_Program_Lump_Sums.Program_Lump_Sum_Name_ID					
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
					AND
					(SELECT Count(l.Program_ID)
					FROM	Program_Lump_Sums l
					WHERE	l.Deleted = 0
							AND l.Program_ID = First_Program_Lump_Sums.Program_ID
							AND l.Program_Lump_Sum_Name_ID = First_Program_Lump_Sums.Program_Lump_Sum_Name_ID
							AND l.Program_Lump_Sum_ID <= First_Program_Lump_Sums.Program_Lump_Sum_ID)
					=
					(SELECT Count(l.Program_ID)
					FROM	Program_Lump_Sums l
					WHERE	l.Deleted = 0
							AND l.Program_ID = Second_Program_Lump_Sums.Program_ID
							AND l.Program_Lump_Sum_Name_ID = Second_Program_Lump_Sums.Program_Lump_Sum_Name_ID)				
		</cfquery>
		
		<cfreturn qGetLumpsumChange>
	</cffunction>
	
	<cffunction name="getLumpProducts" output="false" returntype="query">
	
		<cfargument name="lumpsumId" type="string" required="true">
		
		<cfquery name="qGetLumpProducts" datasource="#application.datasource#">
			SELECT	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID As MaterialID, BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.Description
			FROM	Program_Lump_Sum_Product_Data
					INNER JOIN Contract_Products
					ON
					Contract_Products.Deleted = 0
					AND Contract_Products.Contract_Products_ID = Program_Lump_Sum_Product_Data.Contract_Products_ID
					AND 
					(
						<!------ Group ----->
						(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
					) 
					INNER JOIN BSA_Foodservice_Items_Master
					ON
					BSA_Foodservice_Items_Master.Deleted = 0
					AND BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
			WHERE
					Program_Lump_Sum_Product_Data.Deleted = 0
					AND Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID = '#arguments.lumpsumId#'
			ORDER BY BSA_Foodservice_Items_Master.Item			
		</cfquery>
		
		<cfreturn qGetLumpProducts>
	</cffunction>

	<cffunction name="getPricingLevels" output="false" returntype="query">
	
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		
		<cfquery name="qGetPricingLevels" datasource="#application.datasource#">
			SELECT	DISTINCT Pricing_Level.Pricing_Level_ID, Pricing_Level.Pricing_Level_Label
			FROM	Contract_Products					
					INNER JOIN Pricing_Level
					ON
					Pricing_Level.Deleted = 0
					AND Pricing_Level.Pricing_Level_ID = Contract_Products.Pricing_Level_ID
			WHERE	Contract_Products.Deleted = 0
					AND Contract_Products.Contract_Main_ID = #arguments.ProgramId1#
			
			UNION
			
			SELECT	DISTINCT Pricing_Level.Pricing_Level_ID, Pricing_Level.Pricing_Level_Label
			FROM	Contract_Products					
					INNER JOIN Pricing_Level
					ON
					Pricing_Level.Deleted = 0
					AND Pricing_Level.Pricing_Level_ID = Contract_Products.Pricing_Level_ID
			WHERE	Contract_Products.Deleted = 0
					AND Contract_Products.Contract_Main_ID = #arguments.ProgramId2#
		</cfquery>
		
		<cfreturn qGetPricingLevels>
		
	</cffunction>
	
	
	<cffunction name="getRebateRemoved" output="false" returntype="query">
	
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<cfargument name="showOnlyChange" type="numeric" required="true">
		<cfargument name="pricingLevelId" type="numeric" required="true">
		
		<cfquery name="qGetRebate" datasource="#application.datasource#">
			SELECT	DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					First_Rebate.Program_Rebates_Product_Data_ID First_Rebate_ID,
					Second_Rebate.Program_Rebates_Product_Data_ID Second_Rebate_ID,
					First_Contract_Products.BSA_Foodservice_Items_Master_ID First_ID,
					Second_Contract_Products.BSA_Foodservice_Items_Master_ID Second_ID,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Item
					END As First_Item_ID,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Item
					END As Second_Item_ID,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As First_Name,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As Second_Name,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						1
					ELSE
						0
					END As Added,
					0 As Change
			FROM	Contract_Main
					<!------ Contract Products ----->
					INNER JOIN Contract_Products First_Contract_Products
					ON	First_Contract_Products.Deleted = 0
					AND	First_Contract_Products.Product_Type_ID = 2
					AND	First_Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND First_Contract_Products.Pricing_Level_ID = #arguments.pricingLevelId#
					AND 
					(
						<!------ Group ----->
						(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
					) 
					LEFT JOIN Contract_Products Second_Contract_Products
					ON	Second_Contract_Products.Deleted = 0
					AND	Second_Contract_Products.Product_Type_ID = 2
					AND	Second_Contract_Products.Contract_Main_ID = #arguments.ProgramId2#
					AND Second_Contract_Products.Pricing_Level_ID = #arguments.pricingLevelId#
					AND	First_Contract_Products.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
					AND 
					(
						<!------ Group ----->
						(Second_Contract_Products.Product_Group_ID = CAST(Second_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Second_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Second_Contract_Products.Product_Group_ID, '') = '' AND Second_Contract_Products.Is_Group = 0)
					) 
					<!------ Rebate ----->
					INNER JOIN Program_Rebates_Product_Data First_Rebate
					ON	First_Rebate.Deleted = 0
					AND	First_Rebate.Contract_Products_ID = First_Contract_Products.Contract_Products_ID
					LEFT JOIN Program_Rebates_Product_Data Second_Rebate
					ON	Second_Rebate.Deleted = 0
					AND	Second_Rebate.Contract_Products_ID = Second_Contract_Products.Contract_Products_ID										
					INNER JOIN BSA_Foodservice_Items_Master
					ON	BSA_Foodservice_Items_Master.Deleted = 0
					AND	(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = First_Contract_Products.BSA_Foodservice_Items_Master_ID
						OR
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
						)
					<cfif arguments.showOnlyChange>
					AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL
					</cfif>
					AND ISNULL(First_Contract_Products.BSA_Foodservice_Items_Master_ID, Second_Contract_Products.BSA_Foodservice_Items_Master_ID) = ISNULL(Second_Contract_Products.BSA_Foodservice_Items_Master_ID, First_Contract_Products.BSA_Foodservice_Items_Master_ID)									
					AND (First_Contract_Products.Product_Type_ID = 2 OR Second_Contract_Products.Product_Type_ID = 2)
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
		</cfquery>
		
		<cfreturn qGetRebate />
	
	</cffunction>
	
	<cffunction name="getRebateRates" output="false" returntype="query">
	
		<cfargument name="rebateProductId" type="string" required="true">
		
		<cfquery name="qGetRebateRates" datasource="#application.datasource#">
			SELECT	Program_Rebates_Component_Data.Rate,
					Units_Of_Measure.Abbreviation UOM,
					Units_Of_Measure.Unit_Of_Measure_ID
			FROM	Program_Rebates_Component_Data
					INNER JOIN Units_Of_Measure
					ON
					Units_Of_Measure.Unit_Of_Measure_ID = Program_Rebates_Component_Data.Unit_Of_Measure_ID
			WHERE	Program_Rebates_Component_Data.Deleted = 0
					AND Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID = '#arguments.rebateProductId#'
		</cfquery>
		
		<cfreturn qGetRebateRates>
		
	</cffunction>
	
	<cffunction name="getAllGrowthProducts" output="false" returntype="query">
	
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<cfargument name="showOnlyChange" type="numeric" required="true">
		
		<cfquery name="qGetAllGrowthProducts" datasource="#application.datasource#">
			SELECT	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, 
					First_Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID First_ID,
					First_Contract_Products.Contract_Main_ID First_Program_ID, Second_Contract_Products.Contract_Main_ID Second_Program_ID,
					Second_Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID Second_ID,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Item
					END As First_Item_ID,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Item
					END As Second_Item_ID,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As First_Name,
					CASE 
					WHEN Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As Second_Name,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE 
					WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN
						1
					ELSE
						0
					END As Added
			FROM	Contract_Main
					INNER JOIN Contract_Products First_Contract_Products
					ON	First_Contract_Products.Deleted = 0
					AND	First_Contract_Products.Product_Type_ID = 4
					AND First_Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND 
					(
						<!------ Group ----->
						(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
					) 
					<!------ First Product ----->
					INNER JOIN 	Program_Growth_Component_Product_Data First_Program_Growth_Component_Product_Data
					ON	First_Program_Growth_Component_Product_Data.Deleted = 0
					AND	First_Program_Growth_Component_Product_Data.Contract_Products_ID = First_Contract_Products.Contract_Products_ID
					<!------ Second Product ----->
					LEFT JOIN Contract_Products Second_Contract_Products
					ON	Second_Contract_Products.Deleted = 0
					AND	Second_Contract_Products.Product_Type_ID = 4
					AND	Second_Contract_Products.Contract_Main_ID = #arguments.ProgramId2#
					AND	First_Contract_Products.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
					AND 
					(
						<!------ Group ----->
						(Second_Contract_Products.Product_Group_ID = CAST(Second_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Second_Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Second_Contract_Products.Product_Group_ID, '') = '' AND Second_Contract_Products.Is_Group = 0)
					) 
					LEFT JOIN 	Program_Growth_Component_Product_Data Second_Program_Growth_Component_Product_Data
					ON	Second_Program_Growth_Component_Product_Data.Deleted = 0
					AND	Second_Program_Growth_Component_Product_Data.Contract_Products_ID = Second_Contract_Products.Contract_Products_ID
					<!------ Product Master ----->
					INNER JOIN 	BSA_Foodservice_Items_Master
					ON	BSA_Foodservice_Items_Master.Deleted = 0
					AND	(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = First_Contract_Products.BSA_Foodservice_Items_Master_ID
						OR
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
						)					
					AND ISNULL(First_Contract_Products.BSA_Foodservice_Items_Master_ID, Second_Contract_Products.BSA_Foodservice_Items_Master_ID) = ISNULL(Second_Contract_Products.BSA_Foodservice_Items_Master_ID, First_Contract_Products.BSA_Foodservice_Items_Master_ID)					
					<cfif arguments.showOnlyChange>
					AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL
					</cfif>
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
			ORDER BY BSA_Foodservice_Items_Master.Description
		</cfquery>
		
		<cfreturn qGetAllGrowthProducts>
		
	</cffunction>
	
	<cffunction name="getGrowthProductRates" output="false" returntype="query">
	
		<cfargument name="productId" type="string" required="true">
		<cfargument name="ProgramId" type="string" required="true">
		
		
		<cfif isNumeric(arguments.ProgramId)>
			<cfquery name="qGetAllGrowthProducts" datasource="#application.datasource#">
				SELECT	First_Program_Growth_Component_Tiers.Tier_Number, First_Program_Growth_Component_Tiers.Range_Start, First_Program_Growth_Component_Tiers.Range_End,
						First_Program_Growth_Component_Product_Tier_Data.Rate First_Rate, First_Units_Of_measure.Abbreviation First_UOM
				FROM	Contract_Products First_Contract_Products
						<!------ First Product ----->
						INNER JOIN 	Program_Growth_Component_Product_Data First_Program_Growth_Component_Product_Data
						ON	First_Program_Growth_Component_Product_Data.Deleted = 0
						AND	First_Program_Growth_Component_Product_Data.Contract_Products_ID = First_Contract_Products.Contract_Products_ID
						INNER JOIN	Program_Growth_Components First_Program_Growth_Components
						ON	First_Program_Growth_Components.Deleted = 0
						AND	First_Program_Growth_Components.Program_Growth_Component_ID = First_Program_Growth_Component_Product_Data.Program_Growth_Component_ID
						INNER JOIN	Program_Growth_Component_Tiers First_Program_Growth_Component_Tiers
						ON	First_Program_Growth_Component_Tiers.Deleted = 0
						AND	First_Program_Growth_Components.Program_Growth_Component_ID = First_Program_Growth_Component_Tiers.Program_Growth_Component_ID
						INNER JOIN Program_Growth_Component_Product_Tier_Data First_Program_Growth_Component_Product_Tier_Data
						ON	First_Program_Growth_Component_Product_Tier_Data.Deleted = 0
						AND	First_Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID = First_Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID
						AND	First_Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_ID = First_Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID
						INNER JOIN Units_Of_measure First_Units_Of_measure
						ON	First_Units_Of_measure.Unit_Of_measure_ID = First_Program_Growth_Component_Product_Tier_Data.Unit_Of_measure_ID
				WHERE	First_Contract_Products.Deleted = 0
						AND First_Contract_Products.Contract_Main_ID = #arguments.ProgramId#
						AND First_Contract_Products.BSA_Foodservice_Items_Master_ID = '#arguments.productId#'
						AND 
						(
							<!------ Group ----->
							(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
							OR
							<!------ Product ----->
							(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
						) 
				ORDER BY First_Program_Growth_Component_Tiers.Tier_Number
			</cfquery>
		<cfelse>			
			<cfset qGetAllGrowthProducts = QueryNew("Tier_Number, Range_Start, Range_End, First_Rate, First_UOM")>
		</cfif>
		
		<cfreturn qGetAllGrowthProducts>
		
	</cffunction>
	
	<cffunction name="updateProgramSentStatus" output="false" returntype="void">
	
		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="manualCancel" type="numeric" required="true" />
		
		<cfif arguments.manualCancel>
		
			<cfset useLakebaseForqUpdateSentStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqUpdateSentStatus>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"sent_to_external_client" = "eq.1",
				"manual_cancel" = "eq.1",
				"cancel_sent_to_external_client" = "eq.0",
				"contract_main_id" = "eq.#arguments.programId#"
			},
			{
				"cancel_sent_to_external_client" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdateSentStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdateSentStatus>
<cfquery name="qUpdateSentStatus" datasource="#application.datasource#">
				UPDATE	Contract_Main
				SET		Cancel_Sent_To_External_Client = 1
				WHERE	Sent_To_External_Client = 1
						AND Manual_Cancel = 1
						AND Cancel_Sent_To_External_Client = 0
						AND Contract_Main_ID = #arguments.programId#
			</cfquery>
</cfif>
		
		<cfelse>
		
			<cfquery name="qUpdateSentStatus" datasource="#application.datasource#">
				UPDATE	Contract_Main
				SET		Sent_To_External_Client = 1
				WHERE	Sent_To_External_Client = 0
						AND Contract_Main_ID = #arguments.programId#
			</cfquery>
		
		</cfif>
	
	</cffunction>
		
</cfcomponent>
