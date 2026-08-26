	<cfparam name="Export_Customer_ID" default="0">
	<cfparam name="ChangeStatus" default="0">

	<cfif CID neq "">
		<CF_CRYP type="de" string="#CID#" key="#request.key#">
		<cfset Export_Customer_ID= cryp.value>
	</cfif>

<cfset Agreement_Manager_Details = CreateObject("component","components.Export.Sales_Agreement") />

<cftransaction>
	<cfif Export_Customer_ID neq "0">
		<cfset useLakebaseForUpdateExportCustomer = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_customer")>
		<cfif useLakebaseForUpdateExportCustomer>
			<cftry>
				<cfset application.oLakebase.updateRows("export_customer",
					{ "export_customer_id" = "eq.#Export_Customer_ID#" },
					{
						"export_customer_name" = Export_Customer_Name,
						"export_customer_address_1" = Export_Customer_Address_1,
						"export_customer_address_2" = Export_Customer_Address_2,
						"export_customer_address_3" = Export_Customer_Address_3,
						"export_customer_city" = Export_Customer_City,
						"export_customer_phone" = Export_Customer_Phone,
						"export_customer_fax" = Export_Customer_Fax,
						"export_customer_email" = Export_Customer_Email,
						"export_customer_country" = Export_Customer_Country,
						"export_customer_base_number" = Export_Customer_Base_Number
					}
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForUpdateExportCustomer = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdateExportCustomer>
			<cfquery name="UpdateExportCustomer" datasource="#application.datasource#">
				UPDATE Export_Customer
					SET Export_Customer_Name= '#Export_Customer_Name#'
					,Export_Customer_Address_1 = '#Export_Customer_Address_1#'
					,Export_Customer_Address_2 = '#Export_Customer_Address_2#'
					,Export_Customer_Address_3 = '#Export_Customer_Address_3#'
					,Export_Customer_City = '#Export_Customer_City#'
					,Export_Customer_Phone = '#Export_Customer_Phone#'
					,Export_Customer_Fax = '#Export_Customer_Fax#'
					,Export_Customer_Email = '#Export_Customer_Email#'
					,Export_Customer_Country = '#Export_Customer_Country#'
					,Export_Customer_Base_Number = '#Export_Customer_Base_Number#'
				WHERE Export_Customer_id = '#Export_Customer_ID#'
			</cfquery>
		</cfif>

		<cfset UpdateExportCustomerDetailsData = {
			"export_customer_include_pallet" = Export_Customer_Include_Pallet,
			"export_customer_pallet_type" = Export_Pallet_Type,
			"export_customer_quantity" = Export_Customer_Quantity,
			"export_customer_exempt_relocation_charge" = Export_Customer_Exempt_Relocation_Charge,
			"export_customer_unit_of_measure_id" = Export_Customer_Unit_Of_Measure_ID,
			"export_customer_exempt_domestic_fuel_charge" = Export_Customer_Exempt_Domestic_Fuel_Charge,
			"export_buyer_name" = Export_Buyer_Name,
			"export_terms_of_sale" = Export_Terms_of_Sale,
			"export_invoice_terms" = Export_Invoice_Terms,
			"export_origin_id" = Export_Primary_Warehouse,
			"export_discharge_port" = Export_Discharge_Port,
			"export_customer_notes" = Export_Customer_Notes
		}>
		<cfif ChangeStatus eq 1>
			<cfset UpdateExportCustomerDetailsData["export_customer_status_type"] = StatusAllowed>
		</cfif>
		<cfset useLakebaseForUpdateExportCustomerDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_customer_details")>
		<cfif useLakebaseForUpdateExportCustomerDetails>
			<cftry>
				<cfset application.oLakebase.updateRows("export_customer_details",
					{ "export_customer_id" = "eq.#Export_Customer_ID#" },
					UpdateExportCustomerDetailsData
				)>
				<cfcatch type="any">
					<cfset useLakebaseForUpdateExportCustomerDetails = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdateExportCustomerDetails>
			<cfquery name="UpdateExportCustomerDetails" datasource="#application.datasource#">
				UPDATE Export_Customer_Details
							<!--- If the user clicks on the save button, do not change the status --->
					SET <cfif ChangeStatus eq 1>Export_Customer_Status_Type = '#StatusAllowed#',</cfif>
						Export_Customer_Include_Pallet = '#Export_Customer_Include_Pallet#'
					,Export_Customer_Pallet_Type = '#Export_Pallet_Type#'
					,Export_Customer_Quantity = '#Export_Customer_Quantity#'
					,Export_Customer_Exempt_Relocation_Charge = '#Export_Customer_Exempt_Relocation_Charge#'
					,Export_Customer_Unit_Of_Measure_ID = '#Export_Customer_Unit_Of_Measure_ID#'
					,Export_Customer_Exempt_Domestic_Fuel_Charge = '#Export_Customer_Exempt_Domestic_Fuel_Charge#'
					,Export_Buyer_Name = '#Export_Buyer_Name#'
					,Export_Terms_of_Sale = '#Export_Terms_of_Sale#'
					,Export_Invoice_Terms = '#Export_Invoice_Terms#'
					,Export_Origin_ID = '#Export_Primary_Warehouse#'
					,Export_Discharge_Port = '#Export_Discharge_Port#'
					,Export_Customer_Notes = '#Export_Customer_Notes#'
				WHERE	Export_Customer_id = '#Export_Customer_ID#'
			</cfquery>
		</cfif>

	<cfelse>

		<cfquery name="InsertExportCustomer" datasource="#application.datasource#">
			SET NOCOUNT ON

			INSERT INTO Export_Customer(Export_Customer_Name,Export_Customer_Address_1,Export_Customer_Address_2,Export_Customer_Address_3
			,Export_Customer_City,Export_Customer_Phone,Export_Customer_Fax,Export_Customer_Email,Export_Customer_Country,Export_Customer_Base_Number)

			VALUES('#Export_Customer_Name#','#Export_Customer_Address_1#','#Export_Customer_Address_2#','#Export_Customer_Address_3#','#Export_Customer_City#'
			,'#Export_Customer_Phone#','#Export_Customer_Fax#','#Export_Customer_Email#','#Export_Customer_Country#','#Export_Customer_Base_Number#')

			SELECT Export_Customer_ID = @@Identity
			SET NOCOUNT OFF
		</cfquery>

		<cfset Export_Customer_ID = InsertExportCustomer.Export_Customer_ID>

		<cfset useLakebaseForInsertExportCustomerDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_customer_details")>
		<cfif useLakebaseForInsertExportCustomerDetails>
			<cftry>
				<cfset application.oLakebase.insertRow("export_customer_details", {
					"export_customer_id" = Export_Customer_ID,
					"export_customer_status_type" = StatusAllowed,
					"export_customer_include_pallet" = Export_Customer_Include_Pallet,
					"export_customer_pallet_type" = Export_Pallet_Type,
					"export_customer_quantity" = Export_Customer_Quantity,
					"export_customer_exempt_relocation_charge" = Export_Customer_Exempt_Relocation_Charge,
					"export_customer_unit_of_measure_id" = Export_Customer_Unit_Of_Measure_ID,
					"export_customer_exempt_domestic_fuel_charge" = Export_Customer_Exempt_Domestic_Fuel_Charge,
					"export_buyer_name" = Export_Buyer_Name,
					"export_terms_of_sale" = Export_Terms_of_Sale,
					"export_invoice_terms" = Export_Invoice_Terms,
					"export_origin_id" = Export_Primary_Warehouse,
					"export_discharge_port" = Export_Discharge_Port,
					"deleted" = false
				})>
				<cfcatch type="any">
					<cfset useLakebaseForInsertExportCustomerDetails = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForInsertExportCustomerDetails>
			<cfquery name="InsertExportCustomerDetails" datasource="#application.datasource#">
				INSERT INTO Export_Customer_Details(Export_Customer_ID,Export_Customer_Status_Type,Export_Customer_Include_Pallet
				,Export_Customer_Pallet_Type,Export_Customer_Quantity,Export_Customer_Exempt_Relocation_Charge
				,Export_Customer_Unit_Of_Measure_ID,Export_Customer_Exempt_Domestic_Fuel_Charge,Export_Buyer_Name,Export_Terms_of_Sale
				,Export_Invoice_Terms,Export_Origin_ID,Export_Discharge_Port)

				VALUES('#Export_Customer_ID#','#StatusAllowed#','#Export_Customer_Include_Pallet#'
				,'#Export_Pallet_Type#','#Export_Customer_Quantity#','#Export_Customer_Exempt_Relocation_Charge#','#Export_Customer_Unit_Of_Measure_ID#'
				,'#Export_Customer_Exempt_Domestic_Fuel_Charge#','#Export_Buyer_Name#','#Export_Terms_of_Sale#','#Export_Invoice_Terms#'
				,'#Export_Primary_Warehouse#','#Export_Discharge_Port#')
			</cfquery>
		</cfif>

	</cfif>

		<cfset useLakebaseForGetNotifyRecords = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_notify_details")>
		<cfif useLakebaseForGetNotifyRecords>
			<cftry>
				<cfset qryGetNotifyRecordsRows = application.oLakebase.selectRows("export_notify_details", { "export_customer_id" = "eq.#Export_Customer_ID#", "select" = "export_notify_id" })>
				<cfset getNotifyRecords = application.oLakebase.toQuery([ { "numberofrecords" = ArrayLen(qryGetNotifyRecordsRows) } ])>
				<cfcatch type="any">
					<cfset useLakebaseForGetNotifyRecords = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForGetNotifyRecords>
			<cfquery name="getNotifyRecords" datasource="#application.datasource#">
				SELECT Count(*) As NumberOfRecords
				FROM Export_Notify_Details
				WHERE Export_Customer_id = '#Export_Customer_ID#'
			</cfquery>
		</cfif>

<cfif getNotifyRecords.NumberOfRecords eq 0>		
	<cfif Form.Export_Notify_Name neq "">
		<cfset useLakebaseForInsertExportNotifyDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_notify_details")>
		<cfif useLakebaseForInsertExportNotifyDetails>
			<cftry>
				<cfset application.oLakebase.insertRow("export_notify_details", {
					"export_customer_id" = Export_Customer_ID,
					"export_notify_name" = Export_Notify_Name,
					"export_notify_address_1" = Export_Notify_Address_1,
					"export_notify_address_2" = Export_Notify_Address_2,
					"export_notify_address_3" = Export_Notify_Address_3,
					"export_notify_city" = Export_Notify_City,
					"export_notify_phone" = Export_Notify_Phone,
					"export_notify_fax" = Export_Notify_Fax,
					"export_notify_country" = Export_Notify_Country,
					"deleted" = false
				})>
				<cfcatch type="any">
					<cfset useLakebaseForInsertExportNotifyDetails = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForInsertExportNotifyDetails>
			<cfquery name="InsertExportNotifyDetails" datasource="#application.datasource#">
				INSERT INTO Export_Notify_Details(Export_Customer_ID,Export_Notify_Name,Export_Notify_Address_1,Export_Notify_Address_2,Export_Notify_Address_3
				,Export_Notify_City,Export_Notify_Phone,Export_Notify_Fax,Export_Notify_Country)

				VALUES('#Export_Customer_ID#','#Export_Notify_Name#','#Export_Notify_Address_1#','#Export_Notify_Address_2#','#Export_Notify_Address_3#','#Export_Notify_City#'
				,'#Export_Notify_Phone#','#Export_Notify_Fax#','#Export_Notify_Country#')
			</cfquery>
		</cfif>
	</cfif>

<cfelse>

		<cfset useLakebaseForUpdateExportNotify = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_notify_details")>
		<cfif useLakebaseForUpdateExportNotify>
			<cftry>
				<cfset application.oLakebase.updateRows("export_notify_details",
					{ "export_customer_id" = "eq.#Export_Customer_ID#" },
					{
						"export_notify_name" = Export_Notify_Name,
						"export_notify_address_1" = Export_Notify_Address_1,
						"export_notify_address_2" = Export_Notify_Address_2,
						"export_notify_address_3" = Export_Notify_Address_3,
						"export_notify_city" = Export_Notify_City,
						"export_notify_phone" = Export_Notify_Phone,
						"export_notify_fax" = Export_Notify_Fax,
						"export_notify_country" = Export_Notify_Country
					}
				)>
				<cfcatch type="any">
					<cfset useLakebaseForUpdateExportNotify = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdateExportNotify>
			<cfquery name="UpdateExportNotify" datasource="#application.datasource#">
				UPDATE Export_Notify_Details
					SET Export_Notify_Name= '#Export_Notify_Name#'
					,Export_Notify_Address_1 = '#Export_Notify_Address_1#'
					,Export_Notify_Address_2 = '#Export_Notify_Address_2#'
					,Export_Notify_Address_3 = '#Export_Notify_Address_3#'
					,Export_Notify_City = '#Export_Notify_City#'
					,Export_Notify_Phone = '#Export_Notify_Phone#'
					,Export_Notify_Fax = '#Export_Notify_Fax#'
					,Export_Notify_Country = '#Export_Notify_Country#'
				WHERE Export_Customer_ID = '#Export_Customer_ID#'
			</cfquery>
		</cfif>
</cfif>
	
<cfset qrygetBorderCrossingAgentRecords = Agreement_Manager_Details.getBorderCrossingAgentRecords(Export_Customer_ID)>

<cfif qrygetBorderCrossingAgentRecords.NumberOfRecords eq 0>		
	<cfif Form.Export_Border_Crossing_Agent_Name neq "">
		<cfset useLakebaseForInsertExportBorderCrossingAgent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_border_crossing_agent")>
		<cfif useLakebaseForInsertExportBorderCrossingAgent>
			<cftry>
				<cfset application.oLakebase.insertRow("export_border_crossing_agent", {
					"export_customer_id" = Export_Customer_ID,
					"export_border_crossing_agent_name" = Export_Border_Crossing_Agent_Name,
					"export_border_crossing_agent_address_1" = Export_Border_Crossing_Agent_Address_1,
					"export_border_crossing_agent_address_2" = Export_Border_Crossing_Agent_Address_2,
					"export_border_crossing_agent_address_3" = Export_Border_Crossing_Agent_Address_3,
					"export_border_crossing_agent_city" = Export_Border_Crossing_Agent_City,
					"export_border_crossing_agent_state" = Export_Border_Crossing_Agent_State,
					"export_border_crossing_agent_phone" = Export_Border_Crossing_Agent_Phone,
					"export_border_crossing_agent_zip" = Export_Border_Crossing_Agent_Zip,
					"deleted" = false
				})>
				<cfcatch type="any">
					<cfset useLakebaseForInsertExportBorderCrossingAgent = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForInsertExportBorderCrossingAgent>
			<cfquery name="InsertExportBorderCrossingAgent" datasource="#application.datasource#">
				INSERT INTO Export_Border_Crossing_Agent(Export_Customer_ID,Export_Border_Crossing_Agent_Name,Export_Border_Crossing_Agent_Address_1
				,Export_Border_Crossing_Agent_Address_2,Export_Border_Crossing_Agent_Address_3,Export_Border_Crossing_Agent_City
				,Export_Border_Crossing_Agent_State,Export_Border_Crossing_Agent_Phone,Export_Border_Crossing_Agent_Zip)

				VALUES('#Export_Customer_ID#','#Export_Border_Crossing_Agent_Name#','#Export_Border_Crossing_Agent_Address_1#','#Export_Border_Crossing_Agent_Address_2#'
				,'#Export_Border_Crossing_Agent_Address_3#','#Export_Border_Crossing_Agent_City#','#Export_Border_Crossing_Agent_State#','#Export_Border_Crossing_Agent_Phone#'
				,'#Export_Border_Crossing_Agent_Zip#')
			</cfquery>
		</cfif>
	</cfif>

<cfelse>

		<cfset useLakebaseForUpdateExportBorderCrossingAgent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_border_crossing_agent")>
		<cfif useLakebaseForUpdateExportBorderCrossingAgent>
			<cftry>
				<cfset application.oLakebase.updateRows("export_border_crossing_agent",
					{ "export_customer_id" = "eq.#Export_Customer_ID#" },
					{
						"export_border_crossing_agent_name" = Export_Border_Crossing_Agent_Name,
						"export_border_crossing_agent_address_1" = Export_Border_Crossing_Agent_Address_1,
						"export_border_crossing_agent_address_2" = Export_Border_Crossing_Agent_Address_2,
						"export_border_crossing_agent_address_3" = Export_Border_Crossing_Agent_Address_3,
						"export_border_crossing_agent_city" = Export_Border_Crossing_Agent_City,
						"export_border_crossing_agent_state" = Export_Border_Crossing_Agent_State,
						"export_border_crossing_agent_phone" = Export_Border_Crossing_Agent_Phone,
						"export_border_crossing_agent_zip" = Export_Border_Crossing_Agent_Zip
					}
				)>
				<cfcatch type="any">
					<cfset useLakebaseForUpdateExportBorderCrossingAgent = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdateExportBorderCrossingAgent>
			<cfquery name="UpdateExportBorderCrossingAgent" datasource="#application.datasource#">
				UPDATE Export_Border_Crossing_Agent
					SET Export_Border_Crossing_Agent_Name = '#Export_Border_Crossing_Agent_Name#'
					,Export_Border_Crossing_Agent_Address_1 = '#Export_Border_Crossing_Agent_Address_1#'
					,Export_Border_Crossing_Agent_Address_2 = '#Export_Border_Crossing_Agent_Address_2#'
					,Export_Border_Crossing_Agent_Address_3 = '#Export_Border_Crossing_Agent_Address_3#'
					,Export_Border_Crossing_Agent_City = '#Export_Border_Crossing_Agent_City#'
					,Export_Border_Crossing_Agent_State = '#Export_Border_Crossing_Agent_State#'
					,Export_Border_Crossing_Agent_Phone = '#Export_Border_Crossing_Agent_Phone#'
					,Export_Border_Crossing_Agent_Zip = '#Export_Border_Crossing_Agent_Zip#'
				WHERE Export_Customer_ID = '#Export_Customer_ID#'
			</cfquery>
		</cfif>
</cfif>
</cftransaction>

<cfif ChangeStatus eq 1>	
<cfset URL.CID = CID>
	<cfset Source = "CustomerAddPage">

	<cfinclude template="/common_files/contracts/sales_agreement_customer_email_fax_handler.cfm">	

		<cfset reversed_completepath_email = reverse(completepath_email)>
		<cfset filename_Email =reverse(left(reversed_completepath_email, find("\", reversed_completepath_email)-1))>

		
		<cfset Agreement_Manager_Details = CreateObject("component","components.Export.Sales_Agreement") />
		<cfset qrygetCreditManager = Agreement_Manager_Details.getUsers('Credit Manager')>

	<CF_Naming_Email_Attachments 
					Title="Details_of_Customer" 
					Relative_Src_File_Path="temp_files\customer\#filename_Email#"  
					Relative_Dest_Dir_Path ="Temp_Files\customer" 
					Return_Variable_Name="Program_File_Path">

<!--- Email the file --->
	<cfloop query="qrygetCreditManager">
		<CF_EMAILWRAPPER 
			TO = "#User_Email#"
      FROM = "#request.AccessStructure.user_id#"
      SUBJECT	=	"Credit Check for Customer Number - #CSLGetCustomerInfo.Export_Customer_ID#"
			TYPE	=	"html" 
			messagetype	= "1" 
			generatedby = "3" 
			apparea = "1" 
			userid = "#request.AccessStructure.user_id#">
			Please find the attached file for Customer Number -<cfoutput>#CSLGetCustomerInfo.Export_Customer_ID#</cfoutput>
			<cf_emailwrapperparam file = "#Program_File_Path#" store="yes" />		
	 </CF_EMAILWRAPPER>
	</cfloop>

</cfif>

<CF_CRYP type="en" string="#Export_Customer_ID#" key="#request.key#">

<cflocation url="Sales_Agreement_Customer_Request.cfm?CID=#cryp.value#">