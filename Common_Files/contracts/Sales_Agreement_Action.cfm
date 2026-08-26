<cfparam name="Form.product_list" default="">
<cfparam name="Export_Sales_Agreement_ID" default="">
<cfparam name="Form.Export_Is_Sales_Agreement" default="">
<cfparam name="Form.Export_Sticker_Type"  default="0">
<cfparam name="Form.Export_Sales_Agreement_Name" default="">
<cfparam name="Form.Export_ASI_Contract_Number" default="">
<cfparam name="Form.start_date" default="">
<cfparam name="Form.end_date" default="">
<cfparam name="Form.Export_Agreement_Validity" default="">
<cfparam name="Form.Export_Distributor_ID" default="">
<cfparam name="Form.Export_Distributor" default="">
<cfparam name="Form.Export_Shr_Bill_To" default="">
<cfparam name="Form.Export_Terms_of_Sale" default="">
<cfparam name="Form.Export_Named_Place" default="">
<cfparam name="Form.Export_Mexico_Port" default="">
<cfparam name="Form.Export_Origin" default="">
<cfparam name="Form.Export_Destination_Country" default="">
<cfparam name="Form.Export_Pallet_Indicator" default="">
<cfparam name="Form.Export_Pallet_Type" default="">
<cfparam name="Form.Distributor_List" default="">
<cfparam name="Form.Export_Shr_Ship_To" default="">
<cfparam name="Form.Export_Invoice_Terms_Desc" default="">
<cfparam name="Form.Export_Invoice_Terms" default="">
<cfparam name="Form.Export_Freight_Cost" default="">
<cfparam name="Form.Export_Additional_Freight_Cost" default="">
<cfparam name="Form.Export_Inland_Fuel_Surcharge" default="">
<cfparam name="Form.Export_Additional_Inland_Fuel_Surcharge" default="">
<cfparam name="Form.Export_Ocean_Fuel_Surcharge" default="">
<cfparam name="Form.Export_Additional_Ocean_Fuel_Surcharge" default="">
<cfparam name="Form.Export_Internal_Notes" default="">
<cfparam name="Form.Export_Special_Conditions" default="">
<cfparam name="Form.Export_Notify_Party" default="">
<cfparam name="Form.Is_A_Revision" default="0">
<cfparam name="Form.Responsible_User_Id_Position_Id" default="">

<cfif CID neq "">
	<CF_CRYP type="de" string="#CID#" key="#request.key#">
	<cfset Export_Sales_Agreement_ID = cryp.value>
</cfif>

<!--- When EXW, Do this b'coz the "Item_Origin_Code" in the Item Master table has the two digit code
			and not numeric ID's and so now I am being forced to use the Origin_Code, rather than an ID in my "Named Place"
			select box values for EXW. --->
<cfif Form.Export_Terms_of_Sale eq 1>
	<cfset useLakebaseForGetIDforName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_lookup_origin")>
	<cfif useLakebaseForGetIDforName>
		<cftry>
			<cfset getIDforName = application.oLakebase.toQuery(
				application.oLakebase.selectRows("export_lookup_origin", { "export_lookup_origin_code" = "eq.#Form.Export_Origin#", "select" = "export_lookup_origin_id" })
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForGetIDforName = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetIDforName>
		<cfquery name="getIDforName" datasource="#application.datasource#">
				SELECT Export_Lookup_Origin_ID
				FROM Export_Lookup_Origin
				WHERE Export_Lookup_Origin_Code = '#Form.Export_Origin#'
		</cfquery>
	</cfif>
	<cfset Form.Export_Named_Place = getIDforName.Export_Lookup_Origin_ID>
</cfif>

<cfif Form.Responsible_User_Id_Position_Id neq "">
	<cfset This_User_Position_ID = ListFirst(FORM.Responsible_User_Id_Position_Id, "_")>
	<cfset This_Responsible_User_ID = ListLast(FORM.Responsible_User_Id_Position_Id, "_")>
<cfelse>
	<cfset This_User_Position_ID = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.User_ID)>
	<cfset This_Responsible_User_ID = request.AccessStructure.User_ID>
</cfif>

<!--- If its a new program --->
<cfif Export_Sales_Agreement_ID eq "">
<cftransaction>

<!--- Generate the program number --->
	<cfinclude template="Sales_Agreement_Number_Generator.cfm">

<!--- Add the program --->
		<cfquery name="InsertExportSalesAgreement" datasource="#application.datasource#">
		SET NOCOUNT ON

		INSERT INTO Export_Sales_Agreement(Export_Sales_Agreement_Name,Export_Sales_Agreement_Number,Export_ASI_Contract_Number,Export_Start_Date,Export_End_Date,Creator_ID
		,Creating_User_Position_ID,Contract_Status_Type_IDX,Revision_Version,Export_Agreement_Validity,Export_Distributor_ID,Export_Invoice_Terms,Export_Terms_of_Sale,Export_Named_Place,Export_Mexico_Port
		,Export_Origin,Export_Destination_Country,Export_Pallet_Indicator,Export_Pallet_Type,Export_Is_Sales_Agreement,Export_Freight_Cost
		,Export_Additional_Freight_Cost,Export_Inland_Fuel_Surcharge,Export_Additional_Inland_Fuel_Surcharge,Export_Ocean_Fuel_Surcharge
		,Export_Additional_Ocean_Fuel_Surcharge,Export_Stickering_Cost_ID,Export_Internal_Notes,Export_Special_Conditions,Export_Notify_Party,Responsible_User_ID)

		VALUES('#Export_Sales_Agreement_Name#','#generator_contract_number#','#Export_ASI_Contract_Number#','#Start_Date#',<CFIF IsDate(End_Date)>'#End_Date#'<CFELSE>NULL</CFIF>,'#request.AccessStructure.User_ID#'
		,'#This_User_Position_ID#',1,1,#Export_Agreement_Validity#,<CFIF Export_Distributor_ID neq "">'#Export_Distributor_ID#'<CFELSE>NULL</CFIF>,'#Export_Invoice_Terms#','#Export_Terms_of_Sale#','#Export_Named_Place#','#Export_Mexico_Port#'
		,'#Export_Origin#','#Export_Destination_Country#',#Export_Pallet_Indicator#,'#Export_Pallet_Type#',#Export_Is_Sales_Agreement#,'#val(Export_Freight_Cost)#'
		,'#val(Export_Additional_Freight_Cost)#','#val(Export_Inland_Fuel_Surcharge)#','#val(Export_Additional_Inland_Fuel_Surcharge)#','#val(Export_Ocean_Fuel_Surcharge)#'
		,'#val(Export_Additional_Ocean_Fuel_Surcharge)#','#Form.Export_Sticker_Type#','#Trim(Form.Export_Internal_Notes)#','#Trim(Form.Export_Special_Conditions)#','#Trim(Form.Export_Notify_Party)#','#This_Responsible_User_ID#')

		SELECT Export_Sales_Agreement_ID = @@IDENTITY
		SET NOCOUNT OFF
		</cfquery>

	<!--- Add the program --->
		<cfset Export_Sales_Agreement_ID = InsertExportSalesAgreement.Export_Sales_Agreement_ID>

	<!--- Delete the existing cost values and add what was passed from the form page --->
				<cfset useLakebaseForDeleteExportCostNew = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_cost")>
				<cfif useLakebaseForDeleteExportCostNew>
					<cftry>
						<cfset application.oLakebase.deleteRows("export_cost", { "export_sales_agreement_id" = "eq.#Export_Sales_Agreement_ID#" })>
						<cfcatch type="any">
							<cfset useLakebaseForDeleteExportCostNew = false>
						</cfcatch>
					</cftry>
				</cfif>
				<cfif NOT useLakebaseForDeleteExportCostNew>
					<cfquery name="DeleteExportCost" datasource="#application.datasource#">
						DELETE FROM Export_Cost
						WHERE Export_Sales_Agreement_ID = '#Export_Sales_Agreement_ID#'
					</cfquery>
				</cfif>

				<cfquery name="DeleteExportCost" datasource="#application.datasource#">
					DELETE FROM Export_Misc_Cost
					WHERE Export_Sales_Agreement_ID = '#Export_Sales_Agreement_ID#'
				</cfquery>

			<cfloop list="#StructKeyList(form)#" index="key">
				<cfif Left(key,16) eq "Export_Cost_Desc">
				<cfset Cost_Number = RemoveChars(key,1,find("_",key,16))>
				<cfif Evaluate("Export_Cost_Desc_"&Cost_Number) neq "" AND Evaluate("Export_Cost_Desc_"&Cost_Number) neq 0>
						<cfset useLakebaseForInsertExportCostNew = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_cost")>
						<cfif useLakebaseForInsertExportCostNew>
							<cftry>
								<cfset application.oLakebase.insertRow("export_cost", {
									"export_sales_agreement_id" = Export_Sales_Agreement_ID,
									"export_cost_desc" = Evaluate("Export_Cost_Desc_"&Cost_Number),
									"export_cost" = val(Evaluate("Export_Cost_"&Cost_Number)),
									"export_additional_cost" = val(Evaluate("Export_Additional_Cost_"&Cost_Number)),
									"show_order_sequence" = Cost_Number
								})>
								<cfcatch type="any">
									<cfset useLakebaseForInsertExportCostNew = false>
								</cfcatch>
							</cftry>
						</cfif>
						<cfif NOT useLakebaseForInsertExportCostNew>
							<cfquery name="InsertExportCost" datasource="#application.datasource#">
								INSERT INTO Export_Cost(Export_Sales_Agreement_ID,Export_Cost_Desc,Export_Cost,Export_Additional_Cost,Show_Order_Sequence)
								VALUES('#Export_Sales_Agreement_ID#','#Evaluate("Export_Cost_Desc_"&Cost_Number)#','#val(Evaluate("Export_Cost_"&Cost_Number))#','#val(Evaluate("Export_Additional_Cost_"&Cost_Number))#','#Cost_Number#')
							</cfquery>
						</cfif>
					</cfif>
				</cfif>

				<cfif Left(key,21) eq "Export_Misc_Cost_Desc">
				<cfset Cost_Number = RemoveChars(key,1,find("_",key,21))>
				<cfif Evaluate("Export_Misc_Cost_Desc_"&Cost_Number) neq "" AND Evaluate("Export_Misc_Cost_Desc_"&Cost_Number) neq 0>
						<cfquery name="UpdateExportSalesAgreement" datasource="#application.datasource#">
							INSERT INTO Export_Misc_Cost(Export_Sales_Agreement_ID,Export_Misc_Cost_Desc,Export_Misc_Cost,Show_Order_Sequence)
							VALUES('#Export_Sales_Agreement_ID#','#Evaluate("Export_Misc_Cost_Desc_"&Cost_Number)#','#val(Evaluate("Export_Misc_Cost_"&Cost_Number))#','#Cost_Number#')
						</cfquery>
					</cfif>
				</cfif>
			</cfloop>
</cftransaction>

<!--- If its an existing program --->
<cfelse>

<cftransaction>
		<cfquery name="UpdateExportSalesAgreement" datasource="#application.datasource#">
		 UPDATE Export_Sales_Agreement
		 SET Export_Sales_Agreement_Name='#Export_Sales_Agreement_Name#'
			,Export_ASI_Contract_Number ='#Export_ASI_Contract_Number#'
			<cfif IsDate(Form.End_Date)>,Export_End_Date='#End_Date#'</cfif>
			,Export_Agreement_Validity=#Export_Agreement_Validity#
			,Export_Distributor_ID=<CFIF Export_Distributor_ID neq "">'#Export_Distributor_ID#'<CFELSE>NULL</CFIF>
			,Export_Invoice_Terms='#Export_Invoice_Terms#'
		<!--- These values are not allowed to be changed for revisions --->
		<cfif Form.Is_A_Revision eq 0>
			,Export_Start_Date='#Start_Date#'
			,Export_Terms_of_Sale='#Export_Terms_of_Sale#'
			,Export_Named_Place='#Export_Named_Place#'
			,Export_Mexico_Port='#Export_Mexico_Port#'
			,Export_Origin='#Export_Origin#'
			,Export_Destination_Country='#Export_Destination_Country#'
			,Export_Pallet_Indicator=#Export_Pallet_Indicator#
			,Export_Pallet_Type='#Export_Pallet_Type#'
		</cfif>
			,Export_Is_Sales_Agreement=#Export_Is_Sales_Agreement#
			,Export_Freight_Cost='#val(Export_Freight_Cost)#'
			,Export_Additional_Freight_Cost='#val(Export_Additional_Freight_Cost)#'
			,Export_Inland_Fuel_Surcharge='#val(Export_Inland_Fuel_Surcharge)#'
			,Export_Additional_Inland_Fuel_Surcharge='#val(Export_Additional_Inland_Fuel_Surcharge)#'
			,Export_Ocean_Fuel_Surcharge='#val(Export_Ocean_Fuel_Surcharge)#'
			,Export_Additional_Ocean_Fuel_Surcharge='#val(Export_Additional_Ocean_Fuel_Surcharge)#'
			,Export_Stickering_Cost_ID = '#Form.Export_Sticker_Type#'
			,Export_Internal_Notes = '#TRIM(Form.Export_Internal_Notes)#'
			,Export_Special_Conditions = '#TRIM(Form.Export_Special_Conditions)#'
			,Export_Notify_Party = '#TRIM(Form.Export_Notify_Party)#'
		WHERE Export_Sales_Agreement_ID='#Export_Sales_Agreement_ID#'
		</cfquery>

	<!--- Delete the existing cost values and add what was passed from the form page --->
			<cfset useLakebaseForDeleteExportCostExisting = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_cost")>
			<cfif useLakebaseForDeleteExportCostExisting>
				<cftry>
					<cfset application.oLakebase.deleteRows("export_cost", { "export_sales_agreement_id" = "eq.#Export_Sales_Agreement_ID#" })>
					<cfcatch type="any">
						<cfset useLakebaseForDeleteExportCostExisting = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForDeleteExportCostExisting>
				<cfquery name="DeleteExportCost" datasource="#application.datasource#">
						DELETE FROM Export_Cost
						WHERE Export_Sales_Agreement_ID = '#Export_Sales_Agreement_ID#'
				</cfquery>
			</cfif>
			<cfquery name="DeleteExportCost" datasource="#application.datasource#">
					DELETE FROM Export_Misc_Cost
					WHERE Export_Sales_Agreement_ID = '#Export_Sales_Agreement_ID#'
			</cfquery>

			<cfloop list="#StructKeyList(form)#" index="key">
				<cfif Left(key,16) eq "Export_Cost_Desc">
				<cfset Cost_Number = RemoveChars(key,1,find("_",key,16))>
				<cfif Evaluate("Export_Cost_Desc_"&Cost_Number) neq "" AND Evaluate("Export_Cost_Desc_"&Cost_Number) neq 0>
						<cfset useLakebaseForInsertExportCostExisting = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_cost")>
						<cfif useLakebaseForInsertExportCostExisting>
							<cftry>
								<cfset application.oLakebase.insertRow("export_cost", {
									"export_sales_agreement_id" = Export_Sales_Agreement_ID,
									"export_cost_desc" = Evaluate("Export_Cost_Desc_"&Cost_Number),
									"export_cost" = val(Evaluate("Export_Cost_"&Cost_Number)),
									"export_additional_cost" = val(Evaluate("Export_Additional_Cost_"&Cost_Number)),
									"show_order_sequence" = Cost_Number
								})>
								<cfcatch type="any">
									<cfset useLakebaseForInsertExportCostExisting = false>
								</cfcatch>
							</cftry>
						</cfif>
						<cfif NOT useLakebaseForInsertExportCostExisting>
							<cfquery name="InsertExportCost" datasource="#application.datasource#">
								INSERT INTO Export_Cost(Export_Sales_Agreement_ID,Export_Cost_Desc,Export_Cost,Export_Additional_Cost,Show_Order_Sequence)
								VALUES('#Export_Sales_Agreement_ID#','#Evaluate("Export_Cost_Desc_"&Cost_Number)#','#val(Evaluate("Export_Cost_"&Cost_Number))#','#val(Evaluate("Export_Additional_Cost_"&Cost_Number))#','#Cost_Number#')
							</cfquery>
						</cfif>
					</cfif>
				</cfif>
				<cfif Left(key,21) eq "Export_Misc_Cost_Desc">
				<cfset Cost_Number = RemoveChars(key,1,find("_",key,21))>
				<cfif Evaluate("Export_Misc_Cost_Desc_"&Cost_Number) neq "" AND Evaluate("Export_Misc_Cost_Desc_"&Cost_Number) neq 0>
						<cfset useLakebaseForInsertExportMiscCost = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_misc_cost")>
						<cfif useLakebaseForInsertExportMiscCost>
							<cftry>
								<cfset application.oLakebase.insertRow("export_misc_cost", {
									"export_sales_agreement_id" = Export_Sales_Agreement_ID,
									"export_misc_cost_desc" = Evaluate("Export_Misc_Cost_Desc_"&Cost_Number),
									"export_misc_cost" = val(Evaluate("Export_Misc_Cost_"&Cost_Number)),
									"show_order_sequence" = Cost_Number
								})>
								<cfcatch type="any">
									<cfset useLakebaseForInsertExportMiscCost = false>
								</cfcatch>
							</cftry>
						</cfif>
						<cfif NOT useLakebaseForInsertExportMiscCost>
							<cfquery name="InsertExportMiscCost" datasource="#application.datasource#">
								INSERT INTO Export_Misc_Cost(Export_Sales_Agreement_ID,Export_Misc_Cost_Desc,Export_Misc_Cost,Show_Order_Sequence)
								VALUES('#Export_Sales_Agreement_ID#','#Evaluate("Export_Misc_Cost_Desc_"&Cost_Number)#','#val(Evaluate("Export_Misc_Cost_"&Cost_Number))#','#Cost_Number#')
							</cfquery>
						</cfif>
					</cfif>
				</cfif>
			</cfloop>

<!--- Delete the existing products  and add what was passed from the form page --->
<cfif ListLen(form.product_List) GT 0>
	<cfset useLakebaseForSelectExistingProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_products")>
	<cfif useLakebaseForSelectExistingProducts>
		<cftry>
			<cfset application.oLakebase.updateRows("export_products",
				{ "export_sales_agreement_id" = "eq.#Export_Sales_Agreement_ID#", "bsa_foodservice_items_master_id" = "not.in.(#form.product_List#)", "deleted" = "eq.false" },
				{ "deleted" = true }
			)>
			<cfcatch type="any">
				<cfset useLakebaseForSelectExistingProducts = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForSelectExistingProducts>
		<cfquery name="SelectExistingProducts" datasource="#application.datasource#">
			UPDATE Export_Products
			SET Deleted = 1
			WHERE Export_Sales_Agreement_ID = '#Export_Sales_Agreement_ID#'
			AND BSA_Foodservice_Items_Master_ID NOT IN (#ListQualify(form.product_List,"'")#)
			AND Deleted = 0
		</cfquery>
	</cfif>

	<cfloop list="#form.Product_List#" index="i">
	<CFSET FieldNameEnd = replace(i,"-","_","ALL")>
	<!--- Since Notes are added for every individual product, we get the notes for the existing products (if any) and then add that
				notes to the newly added products --->
	<cfset useLakebaseForSelectExportNotes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_products")>
	<cfif useLakebaseForSelectExportNotes>
		<cftry>
			<cfset SelectExportNotes = application.oLakebase.toQuery(
				application.oLakebase.selectRows("export_products", { "export_sales_agreement_id" = "eq.#Export_Sales_Agreement_ID#", "bsa_foodservice_items_master_id" = "eq.#i#", "deleted" = "eq.false", "select" = "export_notes" })
			)>
			<cfcatch type="any">
				<cfset useLakebaseForSelectExportNotes = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForSelectExportNotes>
		<cfquery name="SelectExportNotes" datasource="#application.datasource#">
			SELECT Export_Notes
			FROM Export_Products
			WHERE Export_Sales_Agreement_ID = '#Export_Sales_Agreement_ID#'
			AND BSA_Foodservice_Items_Master_ID ='#i#'
			AND Deleted = 0
		</cfquery>
	</cfif>

		<cfquery name="InsertExportProducts" datasource="#application.datasource#">
		SET NOCOUNT ON

		INSERT INTO Export_Products (BSA_Foodservice_Items_Master_ID,Export_Sales_Agreement_ID,Export_Target_Net_Sales_Price,Export_Sale_Unit_Price
		,Export_Sticker,Export_Sticker_Rate,Export_Origin_Relocation_Cost,Export_Accrual,Export_Charge,Export_Estimated_Net_Sales_Price,Export_End_User
		,Export_Required_Volume,Export_Volume_Limit,Export_Net_Loadability)
		VALUES('#i#',#Export_Sales_Agreement_ID#,'#val(Evaluate("Export_Target_Net_Sales_Price_#FieldNameEnd#"))#','#val(Evaluate("Export_Sale_Unit_Price_#FieldNameEnd#"))#'
		,<cfif IsDefined("Export_Sticker_#FieldNameEnd#")>#val(Evaluate("Export_Sticker_#FieldNameEnd#"))#<cfelse>0</cfif>,'#val(Evaluate("Export_Sticker_Rate_#FieldNameEnd#"))#','#val(Evaluate("Export_Origin_Relocation_Cost_#FieldNameEnd#"))#'
		,'#val(Evaluate("Export_Accrual_#FieldNameEnd#"))#','#val(Evaluate("Export_Charge_#FieldNameEnd#"))#','#val(Evaluate("Export_Estimated_Net_Sales_Price_#FieldNameEnd#"))#'
		,'#Evaluate("Export_End_User_#FieldNameEnd#")#',#Evaluate("Export_Required_Volume_#FieldNameEnd#")#,'#Evaluate("Export_Volume_Limit_#FieldNameEnd#")#'
		,'#val(Evaluate("Export_Net_Loadability_#FieldNameEnd#"))#')

		SELECT Export_Product_ID = @@IDENTITY
		SET NOCOUNT OFF
		</cfquery>

	<cfset Export_Product_ID = InsertExportProducts.Export_Product_ID>

	<cfset useLakebaseForUpdateExportProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_products")>
	<cfif useLakebaseForUpdateExportProducts>
		<cftry>
			<cfset application.oLakebase.updateRows("export_products",
				{ "export_sales_agreement_id" = "eq.#Export_Sales_Agreement_ID#", "bsa_foodservice_items_master_id" = "eq.#i#", "export_product_id" = "neq.#Export_Product_ID#" },
				{ "deleted" = true }
			)>
			<cfcatch type="any">
				<cfset useLakebaseForUpdateExportProducts = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUpdateExportProducts>
		<cfquery name="UpdateExportProducts" datasource="#application.datasource#">
			UPDATE Export_Products
			SET Deleted = 1
			WHERE Export_Sales_Agreement_ID = '#Export_Sales_Agreement_ID#'
			AND BSA_Foodservice_Items_Master_ID = '#i#'
			AND Export_Product_ID != '#Export_Product_ID#'
		</cfquery>
	</cfif>

	<cfset useLakebaseForUpdateExportNotes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_products")>
	<cfif useLakebaseForUpdateExportNotes>
		<cftry>
			<cfset application.oLakebase.updateRows("export_products",
				{ "export_sales_agreement_id" = "eq.#Export_Sales_Agreement_ID#", "bsa_foodservice_items_master_id" = "eq.#i#", "deleted" = "eq.false" },
				{ "export_notes" = SelectExportNotes.Export_Notes }
			)>
			<cfcatch type="any">
				<cfset useLakebaseForUpdateExportNotes = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUpdateExportNotes>
		<cfquery name="UpdateExportNotes" datasource="#application.datasource#">
			UPDATE Export_Products
			SET Export_Notes = '#SelectExportNotes.Export_Notes#'
			WHERE Export_Sales_Agreement_ID = '#Export_Sales_Agreement_ID#'
			AND BSA_Foodservice_Items_Master_ID = '#i#'
			AND Deleted = 0
		</cfquery>
	</cfif>
	</cfloop>
	<cfelse>
	<cfset useLakebaseForSelectExistingProductsElse = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_products")>
	<cfif useLakebaseForSelectExistingProductsElse>
		<cftry>
			<cfset application.oLakebase.updateRows("export_products",
				{ "export_sales_agreement_id" = "eq.#Export_Sales_Agreement_ID#" },
				{ "deleted" = true }
			)>
			<cfcatch type="any">
				<cfset useLakebaseForSelectExistingProductsElse = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForSelectExistingProductsElse>
		<cfquery name="SelectExistingProducts" datasource="#application.datasource#">
			UPDATE Export_Products
			SET Deleted = 1
			WHERE Export_Sales_Agreement_ID = '#Export_Sales_Agreement_ID#'
		</cfquery>
	</cfif>
</cfif>
</cftransaction>
</cfif>

<cfset useLakebaseForunlockTheirPrograms = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_sales_agreement")>
<cfif useLakebaseForunlockTheirPrograms>
	<cftry>
		<cfset application.oLakebase.updateRows("export_sales_agreement",
			{
				"sales_agreement_locked_by_user_id" = "eq.#request.AccessStructure.User_ID#",
				"deleted" = "eq.0"
			},
			{
				"sales_agreement_is_locked" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForunlockTheirPrograms = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForunlockTheirPrograms>
<cfquery name="unlockTheirPrograms" datasource="#application.datasource#">
	UPDATE Export_Sales_Agreement
	SET	Sales_Agreement_Is_Locked = 0 
	WHERE Sales_Agreement_Locked_By_User_ID = '#request.AccessStructure.User_ID#' 
	AND Deleted = 0 
</cfquery>
</cfif>

<cfset useLakebaseForlockContractFromOtherUsers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_sales_agreement")>
<cfif useLakebaseForlockContractFromOtherUsers>
	<cftry>
		<cfset application.oLakebase.updateRows("export_sales_agreement",
			{
				"export_sales_agreement_id" = "eq.#Export_Sales_Agreement_ID#"
			},
			{
				"sales_agreement_is_locked" = "1",
				"sales_agreement_locked_by_user_id" = "#request.AccessStructure.User_ID#",
				"sales_agreement_lock_date" = "#createodbcdatetime(Now())#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlockContractFromOtherUsers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlockContractFromOtherUsers>
<cfquery NAME="lockContractFromOtherUsers" datasource="#application.datasource#">
	UPDATE Export_Sales_Agreement
	SET Sales_Agreement_Is_Locked = 1, Sales_Agreement_Locked_By_User_ID = '#request.AccessStructure.User_ID#', Sales_Agreement_Lock_Date = #createodbcdatetime(Now())#
	WHERE Export_Sales_Agreement_ID = '#Export_Sales_Agreement_ID#'
</cfquery>
</cfif>

<CF_CRYP type="en" string="#Export_Sales_Agreement_ID#" key="#request.key#">

<cflocation url="Sales_Agreement.cfm?CID=#cryp.value#">