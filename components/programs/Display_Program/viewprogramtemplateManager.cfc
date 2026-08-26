<!--- viewprogramtemplateManager.cfc --->
<cfcomponent extends="components.Base">

	<cfset arUOM = ArrayNew(1) />
    <cfset application.util.query.request_settings()>

	<cffunction name="getRateFormatMask" access="public" returntype="string" output="false">

		<cfargument name="dollarInFront" type="boolean" required="false" default="1" />
		<cfargument name="UOM" type="string" required="false" default="0" />
		<cfargument name="applySetting" type="string" required="false" default="0" />

		<cfset decimalPlaces = 0/>
		<cfif (arguments.applySetting EQ 1)>
			<cfif (UOM EQ 1)>
				<cfset decimalPlaces = request.settings.Decimal_display_for_CS />
			<cfelseif (UOM EQ 2)>
				<cfset decimalPlaces = request.settings.Decimal_display_for_LB />
			<cfelseif (UOM EQ 3)>
				<cfset decimalPlaces = request.settings.Decimal_display_for_Percentage />
			<cfelseif (UOM EQ 5)>
				<cfset decimalPlaces = request.settings.Decimal_display_for_EA />
			<cfelseif (UOM EQ 6)>
				<cfset decimalPlaces = request.settings.Decimal_display_for_CWT />
			<cfelse>
				<cfset decimalPlaces = 4 />
			</cfif>

			<cfif (decimalPlaces EQ 3)>
				<cfset rateFormatMask = "_.___" />
			<cfelseif (decimalPlaces EQ 4)>
				<cfset rateFormatMask = "_.____" />
			<cfelseif (decimalPlaces EQ 5)>
				<cfset rateFormatMask = "_._____" />
			<cfelse>
				<cfset rateFormatMask = "_.__" />
			</cfif>
		<cfelse>
			<cfset rateFormatMask = "_.____" />
		</cfif>

		<cfif arguments.dollarInFront>
			<cfset rateFormatMask = "$#rateFormatMask#" />
		</cfif>

		<cfreturn rateFormatMask />

	</cffunction>

	<cffunction name="getPercentFormatMask" access="public" returntype="string" output="false">
	<cfargument name="percentatEnd" type="boolean" required="false" default="0" />

		<cfset rateFormatMask = "_.__" />
		<cfif arguments.percentatEnd>
			<cfset rateFormatMask = "#rateFormatMask#%" />
		</cfif>
		<cfreturn rateFormatMask />

	</cffunction>

	<cffunction name="getVolumeFormatMask" access="public" returntype="string" output="false">

		<cfreturn "___,___,___,___,___,___" />

	</cffunction>

	<cffunction name="getContractUOMLabel" access="public" returntype="query" output="false">

		<cfargument name="Contract_Quantity_UOM_IDX" type="string" required="true" />

		<cfset useLakebaseForqgetContractUOMLabel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("units_of_measure")>
<cfif useLakebaseForqgetContractUOMLabel>
	<cftry>
		<cfset qgetContractUOMLabel = application.oLakebase.toQuery(
			application.oLakebase.selectRows("units_of_measure", {
				"unit_of_measure_id" = "eq.#arguments.Contract_Quantity_UOM_IDX#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetContractUOMLabel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetContractUOMLabel>
<CFQUERY NAME="qgetContractUOMLabel" datasource="#application.datasource#">

			SELECT 	*
			FROM 	Units_Of_Measure
			WHERE 	Unit_Of_Measure_ID = '#arguments.Contract_Quantity_UOM_IDX#'

		</CFQUERY>
</cfif>

		<cfreturn qgetContractUOMLabel />

	</cffunction>

	<cffunction name="getContract_Main_Aux_Data" access="public" returntype="query" output="false">

		<cfargument name="CSL_Contract_Main_ID" type="string" required="true" />

		<cfset useLakebaseForqgetContract_Main_Aux_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main_aux_data")>
<cfif useLakebaseForqgetContract_Main_Aux_Data>
	<cftry>
		<cfset qgetContract_Main_Aux_Data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main_aux_data", {
				"contract_main_id" = "eq.#arguments.CSL_Contract_Main_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetContract_Main_Aux_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetContract_Main_Aux_Data>
<cfquery name="qgetContract_Main_Aux_Data" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Contract_Main_Aux_Data
			WHERE 	Contract_Main_ID = '#arguments.CSL_Contract_Main_ID#'
		</cfquery>
</cfif>

		<cfreturn qgetContract_Main_Aux_Data />

	</cffunction>

	<cffunction name="getOperators" access="public" returntype="query" output="false">

		<cfargument name="Contract_Main_ID" type="string" required="true" />
		<cfset appSettings = application.appSettingsGet>
		<CFQUERY NAME="qgetOperators" datasource="#application.datasource#">
<!--- D31561: Operator Groups Search START--->
<!---			SELECT	BSA_Operator.Operator_Name,
					BSA_Operator.BSA_Operator_ID,
					BSA_Operator.Operator_City,
					BSA_Operator.Operator_Address,
					BSA_Operator.Operator_State,
					BSA_Operator.Operator_Zip,
					BSA_Operator.Operator_Address,
					BSA_Operator.Operator_Phone,
					BSA_Operator.Legacy_ID,
					COALESCE(Nullif(BSA_Operator.Legacy_ID,''), cast(BSA_Operator.BSA_Operator_ID as char(50))) as Operator_ID			FROM	Contract_Operators
					INNER JOIN BSA_Operator ON
					Contract_Operators.BSA_Operator_ID = BSA_Operator.BSA_Operator_ID
			WHERE	(Contract_Operators.Contract_Main_ID = '#arguments.Contract_Main_ID#')
			AND 	(Contract_Operators.Deleted = 0)
--->
<!--- D31561: Operator Groups Search END--->

			SELECT     	 		<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ '1'>
									CASE  WHEN ISNULL(Operator_Group_ID_Int,0) = 0 AND Contract_Operators.Is_Group = 1 THEN PG_Operator_Category.PG_Operator_Category_Name ELSE BSA_Operator.Operator_Name END AS Operator_name,
		        					CASE WHEN ISNULL(Operator_Group_ID_Int,0) = 0 AND Contract_Operators.Is_Group = 1 THEN PG_Operator_Category.PG_Operator_Category_Code ELSE cast(BSA_Operator.BSA_Operator_ID as varchar(100))  END AS Operator_ID,
		        				<cfelse>
									CASE Contract_Operators.Is_Group when 1 THEN PG_Operator_Category.PG_Operator_Category_Name ELSE BSA_Operator.Operator_Name END AS Operator_name,
		            				CASE Contract_Operators.Is_Group when 1 THEN PG_Operator_Category.PG_Operator_Category_Code ELSE cast(BSA_Operator.BSA_Operator_ID as varchar(100))  END AS Operator_ID,
		            			</cfif>
		            			BSA_Operator.Operator_Name,
								BSA_Operator.BSA_Operator_ID,
								BSA_Operator.Operator_City,
								BSA_Operator.Operator_Address,
								BSA_Operator.Operator_State,
								BSA_Operator.Operator_Zip,
								BSA_Operator.Operator_Address,
								BSA_Operator.Operator_Phone,
								BSA_Operator.Legacy_ID,
								Contract_Operators.Is_Group,
								Contract_Operators.Operator_Group_ID,
								Contract_Operators.Operator_Group_ID_Int,
								Contract_Operators.Group_Level_Desc
								<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ '1'>
									, CASE Contract_Operators.Group_Level_ID
										WHEN '0'           THEN 'End User'
										WHEN '1'           THEN 'Top Parent Name 1'
										WHEN '2'           THEN 'Top Parent Name 2'
										WHEN '3'           THEN 'Direct Parent Name 1'
										WHEN '4'           THEN 'Direct Parent Name 2'
										WHEN '5'			  THEN 'End User Parent'
										WHEN '6'			  THEN 'End User Child'
										ELSE ''    END AS Group_Level_Type
								<cfelse>
									,'' AS Group_Level_Type
								</cfif>
			FROM  			Contract_Operators
			LEFT JOIN 	BSA_Operator
			ON	        	BSA_Operator.BSA_Operator_ID = Contract_Operators.BSA_Operator_ID
			<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ '1'>
				AND
				CASE WHEN ISNULL(Operator_Group_ID_Int,0) > 0 AND Contract_Operators.Is_Group = 1 THEN 1
					WHEN ISNULL(Operator_Group_ID_Int,0) = 0 AND Contract_Operators.Is_Group = 0 Then 1
				ELSE 0 END = 1
			<cfelse>
				AND        		Contract_Operators.Is_Group = 0
			</cfif>
			LEFT JOIN 	PG_Operator_Category
			ON          		PG_Operator_Category.PG_Operator_Category_ID = Contract_Operators.Operator_Group_ID
			AND         	Contract_Operators.Is_Group = 1
			<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ '1'>
				LEFT JOIN Operator_GPO G ON G.Operator_GPO_ID = Contract_Operators.Operator_Group_ID_Int
			</cfif>
			WHERE 			Contract_Operators.Contract_Main_ID = '#arguments.Contract_Main_ID#'
			AND        		Contract_Operators.Deleted = 0
			AND         	Contract_Operators.Captured_From_Group = 0
			ORDER BY 	CASE Contract_Operators.Is_Group when 1 THEN PG_Operator_Category.PG_Operator_Category_Name ELSE BSA_Operator.Operator_Name END
		</CFQUERY>

		<cfreturn qgetOperators />

	</cffunction>

	<cffunction name="GetDiscountIdentifier" access="public" returntype="query" output="false">

		<cfargument name="Discount_Identifier_ID" type="string" required="true" />

		<cfset useLakebaseForqGetDiscountIdentifier = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("discount_identifier")>
<cfif useLakebaseForqGetDiscountIdentifier>
	<cftry>
		<cfset qGetDiscountIdentifier = application.oLakebase.toQuery(
			application.oLakebase.selectRows("discount_identifier", {
				"discount_identifier_id" = "eq.#arguments.Discount_Identifier_ID#",
				"select" = "discount_identifier_number,discount_identifier_desc"
			}), "discount_identifier_number,discount_identifier_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDiscountIdentifier = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDiscountIdentifier>
<cfquery name="qGetDiscountIdentifier" datasource="#application.datasource#">

			SELECT 	Discount_Identifier_Number,
					Discount_Identifier_Desc
			FROM 	Discount_Identifier
			WHERE 	Discount_Identifier_ID = '#arguments.Discount_Identifier_ID#'

		</cfquery>
</cfif>

		<cfreturn qGetDiscountIdentifier />

	</cffunction>

	<cffunction name="getPaymentCycles" access="public" returntype="query" output="false">

		<cfargument name="PaymentCycle" type="string" required="true" />

		<cfset useLakebaseForqgetPaymentCycles = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_cycle")>
<cfif useLakebaseForqgetPaymentCycles>
	<cftry>
		<cfset qgetPaymentCycles = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payment_cycle", {
				"payment_cycle_id" = "eq.#arguments.PaymentCycle#",
				"select" = "payment_cycle"
			}), "payment_cycle"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetPaymentCycles = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetPaymentCycles>
<cfquery name="qgetPaymentCycles" datasource="#application.datasource#" blockfactor="100">

			SELECT 	Payment_Cycle
			FROM 	Payment_Cycle
			WHERE 	Payment_Cycle_ID = '#arguments.PaymentCycle#'

		</cfquery>
</cfif>

		<cfreturn qgetPaymentCycles />

	</cffunction>

	<cffunction name="GetPerfRequirements" access="public" returntype="query" output="false">

		<cfargument name="CSL_Contract_Main_ID" type="string" required="true" />

		<cfset useLakebaseForqGetPerfRequirements = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("one_program_perf_mapping") AND application.oLakebase.isTableMigrated("program_perf_req")>
<cfif useLakebaseForqGetPerfRequirements>
	<cftry>
		<cfset qGetPerfRequirements = application.oLakebase.toQuery(
			application.oLakebase.selectRowsJoin("one_program_perf_mapping", {
				"contract_main_id" = "eq.#arguments.CSL_Contract_Main_ID#",
				"checked" = "eq.1",
				"select" = "program_perf_req_id"
			}, "program_perf_req_id", "program_perf_req", "program_perf_req_id", "requirement_name"), "requirement_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetPerfRequirements = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetPerfRequirements>
<cfquery name="qGetPerfRequirements" datasource="#application.datasource#">

			SELECT	PPR.Requirement_Name
			FROM 	One_Program_Perf_Mapping OPPM
					INNER JOIN Program_Perf_Req PPR ON
						PPR.Program_Perf_Req_ID = OPPM.Program_Perf_Req_ID
			WHERE 	OPPM.Contract_Main_ID = '#arguments.CSL_Contract_Main_ID#' AND
					OPPM.checked = 1


		</cfquery>
</cfif>

		<cfreturn qGetPerfRequirements />

	</cffunction>

	<cffunction name="getDistributors" access="public" returntype="query" output="false">

		<cfargument name="Contract_Main_ID" type="string" required="true" />
		<cfargument name="businessSegmentsOn" type="boolean" required="true" />
		<cfargument name="Specify_Distributor_Groups" type="boolean" required="true" />
		<cfargument name="displayGroupANDIndividual" type="boolean" required="false" default="0" />
		<cfargument name="includeCaptureFromGroup" type="boolean" required="False" default="True" />
		<cfargument name="excludeGroup" type="boolean" required="False" default="False" />
		<cfargument name="altCustomerON" type="any" required="False" default="0" />

		<CFQUERY NAME="qgetDistributors" datasource="#application.datasource#">

		SELECT
				<cfif arguments.businessSegmentsOn IS 1>
				CASE
				WHEN Contract_Distributors.Distributor_Group_Level_ID = 1 THEN
					'All ' + ISNULL(Business_Segment.Business_Unit_Desc, '') + ' #application.returned_customer_setting.distributor_label_plural#'
				ELSE
					BSA_Foodservice_Customers.Name
				END
				<cfelse>
					BSA_Foodservice_Customers.Name
				</cfif> Name,
				BSA_Foodservice_Customers.Shr_Ship_To,
				BSA_Foodservice_Customers.Ship_To,
				BSA_Foodservice_Customers.City,
				BSA_Foodservice_Customers.State,
				BSA_Foodservice_Customers.Address_1,
				BSA_Foodservice_Customers.zipcode,
				BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
				Contract_Distributors.Distributor_Group_Level_ID,
				Contract_Distributors.Distributor_Group_ID,
				Contract_Distributors.Is_Group,
				Contract_Distributors.Is_On_Quote_Letter,       <!---30297--->
				Contract_Distributors.Alternate_Customer_Flag,
				CASE
					WHEN ISNULL(BSA_Foodservice_Brokers.Broker_legcy_Shard, '') <> '' THEN Broker_legcy_Shard
				ELSE
					Broker_Shard
				END
				As Broker_ID,
                Warehouse_Master.Warehouse_Code,
                Warehouse_Master.Warehouse_Name,
                Warehouse_Master.Warehouse_Address_1,
                Warehouse_Master.Warehouse_Address_2,
                Warehouse_Master.Warehouse_City,
                Warehouse_Master.Warehouse_State,
                Warehouse_Master.Warehouse_Zip,
                Warehouse_Master.Warehouse_Country_Code
				As Broker_ID,
				WHM.Warehouse_Name,
				WHM.Warehouse_City,
				WHM.Warehouse_State,
				WHM.Warehouse_Zip
		FROM	Contract_Distributors
				INNER JOIN	BSA_Foodservice_Customers
				ON
				Contract_Distributors.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
				<Cfif arguments.businessSegmentsOn IS 1>
				LEFT JOIN Business_Segment
				ON
				Business_Segment.Deleted = 0
				AND
				Business_Segment.Business_Segment_ID = BSA_Foodservice_Customers.Business_Segment_ID
				</CFIF>
				LEFT JOIN BSA_Foodservice_Brokers
				ON
				BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID
                LEFT JOIN Warehouse_Master
						ON Warehouse_Master.Warehouse_Master_ID = CASE
                                                                    WHEN Contract_Distributors.Warehouse_Master_ID IN ('',0)
							                                                OR Contract_Distributors.Warehouse_Master_ID IS NULL THEN BSA_Foodservice_Customers.Warehouse_Master_ID
							                                        ELSE Contract_Distributors.Warehouse_Master_ID
						                                          END
				LEFT JOIN WareHouse_Master WHM
				ON
				WHM.WareHouse_Master_Id  = Contract_Distributors.WareHouse_Master_Id
		WHERE
				(Contract_Distributors.Contract_Main_ID = '#arguments.Contract_Main_ID#')
				AND (Contract_Distributors.Deleted = 0)
				<cfif arguments.includeCaptureFromGroup EQ 0>
					AND	Contract_Distributors.Captured_From_Group = 0
				</cfif>
				<cfif arguments.Specify_Distributor_Groups EQ 1 AND displayGroupANDIndividual EQ 0>
					AND	Contract_Distributors.Is_Group = 1
				</cfif>
				<cfif arguments.excludeGroup EQ 1 AND displayGroupANDIndividual EQ 0>
					AND	Contract_Distributors.Is_Group = 0
				</cfif>
				<!---D56899 START--->
				<cfif  displayGroupANDIndividual>
					AND Captured_From_Group = 0
				</cfif>
				<cfif (arguments.altCustomerON)>
					AND Contract_Distributors.Alternate_Customer_Flag = 1
				</cfif>
				<!---D56899 END--->
				ORDER BY BSA_Foodservice_Customers.Name

		</CFQUERY>

		<cfreturn qgetDistributors />

	</cffunction>


	<cffunction name="getDistributorExceptions" access="public" returntype="query" output="false">
		<cfargument name="Contract_Main_ID" type="string" required="true" />

		<CFQUERY NAME="qgetDistributorExceptions" datasource="#application.datasource#">
		SELECT
				BSA_Foodservice_Customers.Name,
				BSA_Foodservice_Customers.Shr_Ship_To,
				BSA_Foodservice_Customers.Ship_To,
				BSA_Foodservice_Customers.City,
				BSA_Foodservice_Customers.State,
				BSA_Foodservice_Customers.Address_1,
				BSA_Foodservice_Customers.zipcode
		FROM	Contract_Distributors_Exceptions
				INNER JOIN	BSA_Foodservice_Customers
				ON
				Contract_Distributors_Exceptions.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
		WHERE
				Contract_Distributors_Exceptions.Contract_Main_ID = '#arguments.Contract_Main_ID#'
		ORDER BY BSA_Foodservice_Customers.Name
		</CFQUERY>

		<cfreturn qgetDistributorExceptions />

	</cffunction>

	<cffunction name="getMarkets" access="public" returntype="query" output="false">

		<cfargument name="Contract_Main_ID" type="string" required="true" />
		<!--- Dev Note: Clay 9116: Remove Auto_Brokers from the display_view_program_html.cfm; new argument and sql criteria --->
		<cfargument name="Filter_Auto_Selection" type="numeric" required="false" default="0"/>

			<CFQUERY NAME="qgetMarkets" datasource="#application.datasource#">

				SELECT	Service_Markets.Market_Name,
						BSA_Foodservice_Brokers.Broker_Name,
						BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
				FROM	Contract_Brokers
						INNER JOIN BSA_Foodservice_Brokers ON
						Contract_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
						LEFT JOIN Service_Markets ON
						BSA_Foodservice_Brokers.Service_Market_ID = Service_Markets.Service_Market_ID
				WHERE	((Service_Markets.Deleted = 0) OR (Service_Markets.Deleted is null))
						/*AND (BSA_Foodservice_Brokers.Deleted = 0)  If broker is in the program show it even if it is deleted = 1*/
						AND (Contract_Brokers.Deleted = 0)
						AND	(Contract_Brokers.Contract_Main_ID = '#arguments.Contract_Main_ID#')
						<cfif arguments.filter_auto_selection EQ 1>
							AND Contract_Brokers.Auto_Selection <> 1
						</cfif>
			</CFQUERY>

		<cfreturn qgetMarkets />

	</cffunction>

	<cffunction name="getBrokerNames" access="public" returntype="query" output="false">

		<cfargument name="tableName" type="string" required="true" />

			<cfquery name="qBrokerNames" dbtype="query">
				SELECT DISTINCT Broker_Name
				FROM #arguments.tableName#
				ORDER BY Broker_Name
			</cfquery>

		<cfreturn qBrokerNames />

	</cffunction>

	<cffunction name="getBrokerIDS" access="public" returntype="query" output="false">

		<cfargument name="tableName" type="string" required="true" />
		<cfargument name="brkName" type="string" required="true" />

			<cfquery name="qBrokerIds" dbtype="query">
				SELECT BSA_Foodservice_Brokers_ID, Broker_Name
				FROM #arguments.tableName#
				WHERE Broker_Name = '#arguments.brkName#'
			</cfquery>

		<cfreturn qBrokerIds />

	</cffunction>

	<cffunction name="getOIProgramComponents" access="public" returntype="query" output="false">

		<cfargument name="Contract_Main_ID" type="string" required="true" />

		<cfset var OffInvoiceDAO = CreateObject("component", "components.programs.Off_Invoice.OffInvoiceDAO") />

		<cfset qGetOIProgramComponents = OffInvoiceDAO.getOIProgramComponents(arguments.Contract_Main_ID) />

		<cfreturn qGetOIProgramComponents />

	</cffunction>

	<cffunction name="getOffInvoice" access="public" returntype="query" output="false">

		<cfargument name="Contract_Main_ID" type="string" required="true" />
		<cfargument name="displayGroupType" type="numeric" required="false" default="0" />

		<!---declare the return query object and the OffInvliceDAO object--->
		<cfset var qgetOffInvoicePositive = "" />
		<cfset var OffInvoiceDAO = CreateObject("component", "components.programs.Off_Invoice.OffInvoiceDAO") />

		<!---handle for product q brand in case it doesn't exist--->
		<cfparam name="application.returned_customer_setting.use_product_q_brand" default="0" />

		<!---off loaded this query to a centralized Data Access Object--->
		<cfset qgetOffInvoicePositive = OffInvoiceDAO.getOIProgramProducts(arguments.Contract_Main_ID, '', -1, application.returned_customer_setting.use_product_q_brand, arguments.displayGroupType) />

		<cfreturn qgetOffInvoicePositive />

	</cffunction>

	<cffunction name="getOffInvoicePositive" access="public" returntype="query" output="false">

		<cfargument name="Contract_Main_ID" type="string" required="true" />
		<cfargument name="displayGroupType" type="numeric" required="false" default="0" />

		<!---declare the return query object and the OffInvliceDAO object--->
		<cfset var qgetOffInvoicePositive = "" />
		<cfset var OffInvoiceDAO = CreateObject("component", "components.programs.Off_Invoice.OffInvoiceDAO") />

		<!---handle for product q brand in case it doesn't exist--->
		<cfparam name="application.returned_customer_setting.use_product_q_brand" default="0" />

		<!---off loaded this query to a centralized Data Access Object--->
		<cfset qgetOffInvoicePositive = OffInvoiceDAO.getOIProgramProducts(arguments.Contract_Main_ID, '', 1, application.returned_customer_setting.use_product_q_brand, arguments.displayGroupType) />

		<cfreturn qgetOffInvoicePositive />

	</cffunction>

	<cffunction name="getOffInvoiceNegative" access="public" returntype="query" output="false">

		<cfargument name="Contract_Main_ID" type="string" required="true" />
		<cfargument name="displayGroupType" type="numeric" required="false" default="0" />

		<!---declare the return query object and the OffInvliceDAO object--->
		<cfset var qgetOffInvoiceNegative = "" />
		<cfset var OffInvoiceDAO = CreateObject("component", "components.programs.Off_Invoice.OffInvoiceDAO") />

		<!---handle for product q brand in case it doesn't exist--->
		<cfparam name="application.returned_customer_setting.use_product_q_brand" default="0" />

		<!---off loaded this query to a centralized Data Access Object--->
		<cfset qgetOffInvoiceNegative = OffInvoiceDAO.getOIProgramProducts(arguments.Contract_Main_ID, '', 0, application.returned_customer_setting.use_product_q_brand, arguments.displayGroupType) />

		<cfreturn qgetOffInvoiceNegative />

	</cffunction>

	<cffunction name="getFixedPriceProducts" access="public" returntype="any" output="false">

		<cfargument name="Contract_Main_ID" type="string" required="true" />
		<cfargument name="displayGroupType" type="numeric" required="false" default="0" />
		<!--- For Date Exclusion View Programs Page, IsDateExclusion = 1 --->
		<cfargument name="IsDateExclusion" type="boolean" required="false" default="0" />
		<cfargument name="displaybasesales" required="false" default="0" />
		<cfargument name="getpricebydate" required="false" default="0" />
		<cfargument name="getitemcustprice" required="false" default="0" />
		<cfargument name="freightrateson" required="false" default="0" />
		<cfargument name="UseTableResults" required="false" default="0" />
		<cfargument name="Dist_ID" required="false" default="0" />
		<cfargument name="bDistributorProductAttribute_1" required="false" type="string" default="0" />
	    <cfargument name="bOperatorProductAttribute_1" required="false" type="string" default="0" />
	    <cfargument name="IncludeInactive" required="false" type="string" default="1" />

		<CFQUERY NAME="drpTables" datasource="#application.datasource#">
		SET NOCOUNT ON
			if object_id('tempdb..##tmp_cm') is not null
			drop table ##tmp_cm

			if object_id('tempdb..##contract_distributors') is not null
			drop table ##contract_distributors

			if object_id('tempdb..##tmp_cm_total_weight') is not null
			drop table ##tmp_cm_total_weight

			if object_id('tempdb..##tmp_cp_price_layered') is not null
			drop table ##tmp_cp_price_layered

			if object_id('tempdb..##tmp_program_product_price_layered') is not null
			drop table ##tmp_program_product_price_layered

			<cfif arguments.UseTableResults eq 1>
			if object_id('tempdb..##TMP_Fixed_Price_Details') is not null
			drop table ##TMP_Fixed_Price_Details

			<!--- Note: Dev Note(69526) - "##TMP_Unique_Alias_Info" gets populated from program letters and so this
			table will only exist if the request is made from program letters, but this table does get used here.
			Just creating a placeholder temp table below, in case this table does not already exist.
			--->
			if object_id('tempdb..##TMP_Unique_Alias_Info') is null
			BEGIN
			CREATE TABLE ##TMP_Unique_Alias_Info
			(
			Item varchar(100),
			BB_Claim_Source_XREF_ID int,
			External_Code varchar(100),
			BSA_Foodservice_Customers_ID uniqueIdentifier,
			Row_ID int,
			Use_For_Distributor_Payee_Only bit
			)
			END
			</cfif>
		</CFQUERY>


		<CFQUERY NAME="qgetFixedPriceProducts" datasource="#application.datasource#">
		SET NOCOUNT ON
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		<cfif arguments.getpricebydate EQ 0 and arguments.displaybasesales EQ 1 and arguments.getitemcustprice EQ 0>
		DECLARE @Program_Product_Price table
		(
			Contract_Main_ID Int,
			Product_ID uniqueidentifier,
			Net_Weight decimal(20, 4),
			Price_CS_FOB float,
			Price_LB_FOB float,
			Price_CS_DEL float,
			Price_LB_DEL float
		)

		DECLARE @Program_Products table
		(
			Contract_Main_ID Int,
			Product_ID uniqueidentifier,
			Net_Weight float
		)

		DECLARE
		@Price_List_By_Template BIT,
		@Base_Sales_based_on_Prg_Start_Date bit,
		@Effective_Date_for_Price datetime,
		@Price_List_Header_ID uniqueidentifier,
		@Contract_Start_Date datetime


		SELECT @Price_List_By_Template = Price_List_By_Template FROM _Application_Settings


		SELECT	@Effective_Date_for_Price = ISNULL(cm.Price_Protection_Date, cm.Effective_Date_for_Price),
				@Base_Sales_based_on_Prg_Start_Date =  pcpo.Base_Sales_based_on_Prg_Start_Date,
				@Price_List_Header_ID = pcpo.Margin_Price_List_Header_ID,
				@Contract_Start_Date = cm.Contract_Start_Date
		FROM	Contract_Main cm
				inner join Program_Control_Panel_Options pcpo on pcpo.ProgramControl_Panel_Options_ID = cm.programtype_id
		WHERE	cm.contract_main_id = '#arguments.contract_main_id#'

		IF @Effective_Date_for_Price IS NULL
		SET @Effective_Date_for_Price = @Contract_Start_Date


		INSERT INTO @Program_Products (Contract_Main_ID,Product_ID, Net_Weight)
		SELECT	Contract_Products.Contract_Main_ID,Contract_Products.BSA_Foodservice_Items_master_ID,
		ISNULL(CAST(BSA_Foodservice_Items_Master.Net_Weight as float), 0)

		FROM	Contract_Products
		INNER JOIN BSA_Foodservice_Items_Master
		ON	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
		WHERE	Contract_Products.Contract_Main_ID = '#arguments.contract_main_id#'
		AND Contract_Products.Product_Type_ID = 1
		AND	Contract_Products.Is_Group = 0
		AND Contract_Products.Deleted = 0


		SELECT 	contract_main_id, BSA_Foodservice_Customers_id, cast(program_weight as decimal(20, 4)) as  program_weight
		INTO 	##contract_distributors
		FROM 	Contract_Distributors
		WHERE 	Contract_Distributors.Contract_Main_ID = '#arguments.contract_main_id#'
		AND	Contract_Distributors.Is_Group = 0
		<cfif arguments.Dist_ID neq 0>
		AND Contract_Distributors.BSA_Foodservice_Customers_id IN (#ListQualify(arguments.dist_id,"'")#)
		</cfif>
		AND Contract_Distributors.Deleted = 0


		INSERT INTO @Program_Product_Price (Contract_Main_ID, Product_ID,Net_Weight)
		SELECT	DISTINCT Contract_Main_ID, Product_ID,Net_Weight
		FROM	@Program_Products

		--**********************************************************************************
		-- price list based on template - start
		--**********************************************************************************
		IF @Price_List_By_Template = 1
		BEGIN

			UPDATE	@Program_Product_Price
			SET		Price_CS_DEL = ISNULL(CAST(CS_Bracket_1 as float),0),
					Price_CS_FOB = ISNULL(CAST(CS_FOB_Price as float),0)
			FROM	@Program_Product_Price as Program_Products
					INNER JOIN Price_List_Detail ON	Price_List_Detail.Product_ID = Program_Products.Product_ID
					AND	(
							(@Base_Sales_based_on_Prg_Start_Date = 1 AND @Effective_Date_for_Price between Price_List_Detail.Start_Date and Price_List_Detail.End_Date)
							OR
							(@Base_Sales_based_on_Prg_Start_Date = 0 AND Price_List_Detail.Active_Code = 'A')
						)
					INNER JOIN Price_List_Header ON Price_List_Header.Price_List_Header_ID = Price_List_Detail.Price_List_Header_ID
					AND (@Price_List_By_Template = 1 AND Price_List_Header.Price_List_Header_ID = @Price_List_Header_ID)
			WHERE	Program_Products.Contract_Main_ID =  '#arguments.contract_main_id#'
			AND		Price_List_Detail.Deleted = 0

			UPDATE	@Program_Product_Price
			SET		Price_LB_DEL = Price_CS_DEL / Net_Weight,
					Price_LB_FOB = Price_CS_FOB / Net_Weight

		END
		--**********************************************************************************
		-- price list based on template - end
		--**********************************************************************************
		ELSE
		BEGIN
			--**********************************************************************************
			-- price from item margin targets - start
			--**********************************************************************************

			UPDATE	@Program_Product_Price
			SET	Price_CS_DEL = ISNULL(cast(ITEM_DEL_BASE_PRICE_CS as float),0)
			,Price_CS_FOB = ISNULL(cast(ITEM_FOB_BASE_PRICE_CS as float),0)
			FROM	@Program_Product_Price as Program_Products
			INNER JOIN Item_Margin_Targets
			ON	Item_Margin_Targets.Product_ID = Program_Products.Product_ID
			WHERE Program_Products.Contract_Main_ID =  '#arguments.contract_main_id#'
			AND Item_Margin_Targets.Deleted = 0

			UPDATE	@Program_Product_Price
			SET	Price_LB_DEL = Price_CS_DEL / Net_Weight
			,Price_LB_FOB = Price_CS_FOB / Net_Weight

			--**********************************************************************************
			-- price from item margin targets - end
			--**********************************************************************************


			--**********************************************************************************
			-- price from gross margin table - start
			--**********************************************************************************

			/* Get price per product/distribuor */
			select 	contract_products.contract_main_id,
				contract_products.product_ID,
				contract_distributors.BSA_Foodservice_Customers_id,
				contract_distributors.program_weight,
				ISNULL(CS_FOB_Price, Price_CS_FOB) as Price_CS_FOB,
				ISNULL(CS_DEL_Price, Price_CS_DEL) as Price_CS_DEL
			into	##tmp_cp_price_layered
			from	 @Program_Product_Price as contract_products
			inner join ##contract_distributors contract_distributors
			on 	contract_distributors.Contract_Main_id = contract_products.Contract_Main_id
			left join gross_margin
			on       gross_margin.customer_id = contract_distributors.BSA_Foodservice_Customers_id
			and      gross_margin.product_id = contract_products.Product_ID
			and      gross_margin.deleted = 0

			/* Get sum of weight from distributors that has a price for the product */
			select	contract_main_id, product_ID, sum(program_weight) as sum_program_weight
			into	##tmp_cm_total_weight
			from	##tmp_cp_price_layered
			where	ISNULL(Price_CS_FOB, 0) != 0
			group by contract_main_id, product_ID

			/* Get weighted price per product */
			select	tmp_cp_price.contract_main_id, tmp_cp_price.product_id,
					SUM(tmp_cp_price.Price_CS_FOB * tmp_cp_price.program_weight) / wt.sum_program_weight as Price_CS_FOB,
					SUM(tmp_cp_price.Price_CS_DEL * tmp_cp_price.program_weight) / wt.sum_program_weight as Price_CS_DEL
			into	##tmp_program_product_price_layered
			from	##tmp_cp_price_layered as tmp_cp_price
			inner join ##tmp_cm_total_weight wt
			on		wt.Contract_Main_ID = tmp_cp_price.Contract_Main_ID
			and		wt.product_id = tmp_cp_price.product_id
			group by tmp_cp_price.contract_main_id, tmp_cp_price.product_id, wt.sum_program_weight

			UPDATE	@Program_Product_Price
			SET	Price_CS_FOB = tmp_program_product_price.Price_CS_FOB
			,Price_CS_DEL = tmp_program_product_price.Price_CS_DEL
			FROM	@Program_Product_Price as Program_Products
			INNER JOIN ##tmp_program_product_price_layered as tmp_program_product_price
			ON	tmp_program_product_price.contract_main_id = Program_Products.contract_main_id
			AND	tmp_program_product_price.Product_ID = Program_Products.Product_ID
			WHERE tmp_program_product_price.contract_main_id = '#arguments.contract_main_id#'

			UPDATE	@Program_Product_Price
			SET	Price_LB_DEL = Price_CS_DEL / Net_Weight
			,Price_LB_FOB = Price_CS_FOB / Net_Weight

			--**********************************************************************************
			-- price from gross margin table - end
			--**********************************************************************************
		END
		</cfif>
		<cfif arguments.UseTableResults eq 1>
		CREATE TABLE ##TMP_Fixed_Price_Details(
			[Contract_Main_ID] [int],
			[Contract_Start_Date] [datetime],
			[Contract_End_Date] [datetime],
			[IsExclusionRevision] [bit],
			[Contract_Products_ID] [int],
			[Item] [varchar](50),
			[GTIN] [varchar](30),
			[BSA_Foodservice_Items_Master_ID] [varchar](50),
			[Description] [varchar](255),
			[Net_Weight] [varchar](50),
			[UPC] [nvarchar](50),
			[Product_Type_ID] [tinyint],
			[component_name_id] [int],
			[Program_Fixed_Component_Name] [varchar](50),
			[Program_Fixed_Component_Name_ID] [int],
			[Program_Fixed_Component_ID] [int],
			[Fixed_Component_Type] [int],
			[Fixed_Price_Value] [nvarchar](100),
			[Fixed_Price_Num] [float],
			[Stored_Fixed_Price_Value] [decimal] (20, 10),
			[Stored_Fixed_Price_UOM] [int],
			[Fixed_Price_Per_Pound] [varchar](100),
			[Fixed_Price_Per_Case] [varchar](100),
			[Fixed_Price_Per_Hundred_Weight] [varchar](100),
			[Market_Price_Rate][float],
			[Freight_Rate] [varchar](50),
			[FOB_CS_Price] [float],
			[FOB_LB_Price] [float] ,
			[DEL_CS_Price] [float],
			[DEL_LB_Price] [float],
			[FOB_Price] [decimal](20, 4),
			[Fixed_Component_Paid_to] [char](10),
			[Paid_To] [numeric](18, 0),
			[name] [varchar](255),
			[shr_ship_to] [varchar](50),
			[customer_id] [varchar](50),
			[Unit_Of_Measure_ID] [tinyint] ,
			[Unit_Of_Measure_Desc] [varchar](50),
			[Unit_Of_Measure_Desc_Singular] [varchar](50),
			[Abbreviation] [varchar](10),
			[Approved_Base_Sales] [varchar](100) ,
			[EZButton_On_Default] [bit] NULL,
			[DisplayGroupName] [varchar](255),
			[Program_Summary_Display_Name] [varchar](50),
			[BSA_Foodservice_Customers_ID] [varchar](50),
			[customer_product_number] [varchar](50),
			[claim_mechanics] [varchar] (50),
			[Include_Claim_Rates_Report] [bit],
			[distributor_product_attribute_1] varchar(150),
			[operator_product_attribute_1] varchar(150),
			[Base_Sales_CS] nvarchar(50), <!--- D30357:Today's Price Wrong on Revision History --->
			[Is_Item_Group] BIT,
			[Is_Group] [bit] NULL,
			[Pricing_Level_ID] [int],
			[Pricing_Level_Desc] [varchar] (100),
			[Product_Group_ID] [varchar] (50),
			[Product_Group_Level_ID] [int],
			[Prod_Var_A] [varchar] (50),
			[Line_Number] [varchar] (10)
		)

		CREATE CLUSTERED  INDEX [I_Fixed_Price_Details_tmp] ON [##TMP_Fixed_Price_Details]([Item])  ON [PRIMARY]

			INSERT INTO ##TMP_Fixed_Price_Details
			(UPC,Item,GTIN,<cfif arguments.Dist_ID neq 0>BSA_Foodservice_Customers_ID,Customer_Product_Number,</cfif>Description,Net_Weight,Approved_Base_Sales,BSA_Foodservice_Items_Master_ID,Fixed_Price_Value
			,Fixed_Price_Num,Stored_Fixed_Price_Value,Stored_Fixed_Price_UOM,Unit_Of_Measure_ID,Unit_Of_Measure_Desc,Unit_Of_Measure_Desc_Singular,Abbreviation,Product_Type_ID,EZButton_On_Default
			,Is_Group,Pricing_Level_ID,Pricing_Level_Desc,Product_Group_ID,Product_Group_Level_ID
			,Fixed_Component_Paid_to,fixed_price_per_pound,fixed_price_per_case, Fixed_Price_Per_Hundred_Weight, Market_Price_Rate
			<cfif displayGroupType EQ 3 OR displayGroupType EQ 1>,DisplayGroupName</cfif>
			,Program_Fixed_Component_Name,Fixed_Component_Type,Program_Fixed_Component_Name_ID,Program_Summary_Display_Name
			,Program_Fixed_Component_ID,Contract_Start_date,Contract_End_Date,Contract_Main_ID,IsExclusionRevision
			<cfif arguments.getpricebydate EQ 0 and arguments.displaybasesales EQ 1 and arguments.getitemcustprice EQ 0>
			,FOB_CS_Price,FOB_LB_Price,DEL_CS_Price,DEL_LB_Price
			</cfif>
			<cfif arguments.freightrateson EQ 1>
			,Freight_Rate,FOB_Price,name,shr_ship_to,customer_id,component_name_id,Paid_To
			<cfelse>
			,customer_id,Freight_Rate
			</cfif>
			,claim_mechanics,Include_Claim_Rates_Report
			<cfif arguments.bDistributorProductAttribute_1 neq 0>,distributor_product_attribute_1</cfif>
			<cfif arguments.bOperatorProductAttribute_1 neq 0>,operator_product_attribute_1</cfif>
			,Base_Sales_CS <!--- D30357:Today's Price Wrong on Revision History --->
			,Is_Item_Group
			,Prod_Var_A
			,Line_Number
			)
		</cfif>


			SELECT    	distinct BSA_Foodservice_Items_Master.UPC, BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.GTIN,
					<cfif arguments.Dist_ID neq 0>BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,##TMP_Unique_Alias_Info.External_Code As Distributor_Product_Number,</cfif>
					/* dbo.UDF_REMOVE_NON_ASCIICharOnly(BSA_Foodservice_Items_Master.Description) As Description */
					BSA_Foodservice_Items_Master.Description
					,BSA_Foodservice_Items_Master.Net_Weight,
					isnull(Program_Fixed_Price_Product_Data.Approved_Base_Sales,0) as Approved_Base_Sales,BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID

					<!--- 63887 START ---->
					<!--- Unit_Of_Measure_ID = 6 is for "per hundred weight (CWT)" and that is stored in the db converted to LB.
					Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID is set to 2 for both - LB and CWT. The actual UOM is stored in the "user_picked_UOM" column.
					--->
					,CASE
						WHEN Units_of_Measure.Unit_Of_Measure_ID = 6 THEN CAST(Program_Fixed_Price_Product_Data.Fixed_Price_Value as float) * 100
						WHEN Units_of_Measure.Unit_Of_Measure_ID = 5 THEN Program_Fixed_Price_Product_Data.User_Picked_Fixed_Price
						WHEN Units_of_Measure.Unit_Of_Measure_ID = 7 THEN Program_Fixed_Price_Product_Data.User_Picked_Fixed_Price
					ELSE Program_Fixed_Price_Product_Data.Fixed_Price_Value END AS Fixed_Price_Value
					,
					CASE
						WHEN Units_of_Measure.Unit_Of_Measure_ID = 6 THEN CAST(Program_Fixed_Price_Product_Data.Fixed_Price_Value as float) * 100
						WHEN Units_of_Measure.Unit_Of_Measure_ID = 5 THEN Program_Fixed_Price_Product_Data.User_Picked_Fixed_Price
						WHEN Units_of_Measure.Unit_Of_Measure_ID = 7 THEN Program_Fixed_Price_Product_Data.User_Picked_Fixed_Price
					ELSE CAST(Program_Fixed_Price_Product_Data.Fixed_Price_Value as float) END AS Fixed_Price_Num
					<!--- 63887 END ---->
					,
					CAST(Program_Fixed_Price_Product_Data.Fixed_Price_Value as float) as Stored_Fixed_Price_Value,
					Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID as Stored_Fixed_Price_UOM,
						Units_of_Measure.Unit_Of_Measure_ID
						, Units_of_Measure.Unit_Of_Measure_Desc
						, Units_of_Measure.Abbreviation_Singular
						, Units_of_Measure.Abbreviation
						, Contract_Products.Product_Type_ID, EZButton_On_Default,
						 Contract_Products.Is_Group, Contract_Products.Pricing_Level_ID, Pricing_Level.Pricing_Level_Desc,Contract_Products.Product_Group_ID, Contract_Products.Product_Group_Level_ID, /* D35295:Update market pricing to use new group rates grid */
						<!--- This one (Contract_Products.Contract_Main_ID) is already being queried from the contract_main table. --->
						<cfif arguments.UseTableResults eq 0>Contract_Products.Contract_Main_ID,</cfif>
			Program_Fixed_Component.Fixed_Component_Paid_to,
			<!--- Unit_Of_Measure_ID = 6 is for "per hundred weight (CWT)" and that is stored in the db converted to LB.
			Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID is set to 2 for both - LB and CWT. The actual UOM is stored in the "user_picked_UOM" column.
			--->
			CASE
				WHEN Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID = 2 THEN Program_Fixed_Price_Product_Data.Fixed_Price_Value <!---75851 and 63887 --->
			ELSE Program_Fixed_Price_Product_Data.Fixed_Price_Value / cast(BSA_Foodservice_Items_Master.Net_Weight as float)
			END as fixed_price_per_pound,
			CASE
				WHEN Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID = 2 THEN Program_Fixed_Price_Product_Data.Fixed_Price_Value * cast(BSA_Foodservice_Items_Master.Net_Weight as float)<!---75851 and 63887 --->
			ELSE Program_Fixed_Price_Product_Data.Fixed_Price_Value
			END as fixed_price_per_case,
			<!--- Unit_Of_Measure_ID = 6 is for "per hundred weight (CWT)" and that is stored in the db converted to LB.
			Program_Rebates_Component_Data.Unit_Of_Measure_ID is set to 2 for both - LB and CWT. The actual UOM is stored in the "user_picked_UOM" column.
			--->
			CASE
				WHEN Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID = 2
					THEN CAST(Program_Fixed_Price_Product_Data.Fixed_Price_Value as float) * 100
				WHEN Units_of_Measure.Unit_Of_Measure_ID = 1
					THEN (Program_Fixed_Price_Product_Data.Fixed_Price_Value / cast(BSA_Foodservice_Items_Master.Net_Weight as float)) * 100
			ELSE Program_Fixed_Price_Product_Data.Fixed_Price_Value
			END as fixed_price_per_hundred_weight,
			<!---MARKET PRICE--->
			Program_Fixed_Price_Product_Data.Market_Price_Rate as Market_Price_Rate,
						<cfif displayGroupType EQ 3><!------ Q Brand ----->
						Q_Brand_Desc.Q_Brand DisplayGroupName,
						<cfelseif displayGroupType EQ 1><!------ Type Code ----->
						Type_Code_Desc.Type_Code_Desc DisplayGroupName,
						</cfif>
						Program_Fixed_Component_Name.Program_Fixed_Component_Name, Program_Fixed_Component_Name.Fixed_Component_Type, Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID,
			CASE WHEN ISNULL(Program_Fixed_Component_Name.Program_Summary_Display_Name, '') = '' THEN Program_Fixed_Component_Name.Program_Fixed_Component_Name
			ELSE Program_Fixed_Component_Name.Program_Summary_Display_Name END as Program_Summary_Display_Name,
						Program_Fixed_Component.Program_Fixed_Component_ID
						,Contract_Main.Contract_Start_date,Contract_Main.Contract_end_date
						,Contract_Main.Contract_Main_ID
						,IsExclusionRevision
					<cfif arguments.getpricebydate EQ 0 and arguments.displaybasesales EQ 1 and arguments.getitemcustprice EQ 0>
					,isnull(Program_Product_Price.Price_CS_FOB, 0) as FOB_CS_Price
					,isnull(Program_Product_Price.Price_LB_FOB, 0) as FOB_LB_Price
					,isnull(Program_Product_Price.Price_CS_DEL, 0) as DEL_CS_Price
					,isnull(Program_Product_Price.Price_LB_DEL, 0) as DEL_LB_Price
					</cfif>
					<cfif arguments.freightrateson EQ 1>
					,isnull(Freight_Rate,0.0000) as Freight_Rate,
					isnull(FOB_Price,0.0000) as FOB_Price,
					BSA_Foodservice_Customers.name,
					BSA_Foodservice_Customers.shr_ship_to,
					contract_distributors.BSA_Foodservice_Customers_ID as customer_id,
					Program_Fixed_Freight_Rates.component_name_id,
					CAST(Program_Fixed_Component.Fixed_Component_Paid_to As numeric(18,0)) As Paid_To
					<cfelse>
					,'' as customer_id
					,'' as Freight_Rate
					</cfif>
					,Payment_Type.Payment_Type_Name
					,ISNULL(Payment_Type.Include_Claim_Rates_Report, 0)       <!--- 47759 event error in approval letter due to null value stored in this Boolean (bit) column --->

					<!--- Dev Note: Milan (41921) "arguments.UseTableResults" is 1 when we call this function from program letters. Here is when "arguments.bDistributorProductAttribute_1" could be 1 or 0
					and "arguments.bOperatorProductAttribute_1" could be 1 or 0.
					If the request is not from program letters, then "arguments.UseTableResults" and "arguments.bDistributorProductAttribute_1" and "arguments.bOperatorProductAttribute_1"
					will always be 0.
					Below, we retrieve brand_name when the request is not from letters.
					--->
					<cfif arguments.UseTableResults eq 0>
					,Brand.Brand_Name
					</cfif>

					<!--- If DistributorProductAttribute_1 Is "Brand" --->
					<cfif arguments.bDistributorProductAttribute_1 eq 1>
					,Brand.Brand_Name

					<!--- If DistributorProductAttribute_1 Is "Pack Size" --->
					<cfelseif arguments.bDistributorProductAttribute_1 eq 2>
					,Case_Count.Case_Count_Desc

					<!--- If DistributorProductAttribute_1 Is "QBrand" --->
					<cfelseif arguments.bDistributorProductAttribute_1 eq 3>
					,Q_Brand_Desc.Q_Brand

					<!--- If DistributorProductAttribute_1 Is "Type_Code" --->
					<cfelseif arguments.bDistributorProductAttribute_1 eq 4>
					,Type_Code_Desc.Type_Code_Desc

					<!--- If DistributorProductAttribute_1 Is "Type_Group" --->
					<cfelseif arguments.bDistributorProductAttribute_1 eq 5>
					,Type_Group_Desc.Type_Group_Desc
					</cfif>

					<!--- If OperatorProductAttribute_1 Is "Brand" --->
					<cfif arguments.bOperatorProductAttribute_1 eq 1>
					,Brand.Brand_Name

					<!--- If OperatorProductAttribute_1 Is "Pack Size" --->
					<cfelseif arguments.bOperatorProductAttribute_1 eq 2>
					,Case_Count.Case_Count_Desc

					<!--- If OperatorProductAttribute_1 Is "QBrand" --->
					<cfelseif arguments.bOperatorProductAttribute_1 eq 3>
					,Q_Brand_Desc.Q_Brand

					<!--- If OperatorProductAttribute_1 Is "Type_Code" --->
					<cfelseif arguments.bOperatorProductAttribute_1 eq 4>
					,Type_Code_Desc.Type_Code_Desc

					<!--- If OperatorProductAttribute_1 Is "Type_Group" --->
					<cfelseif arguments.bOperatorProductAttribute_1 eq 5>
					,Type_Group_Desc.Type_Group_Desc
					</cfif>
					,Contract_Products.Base_Sales_CS <!--- D30357:Today's Price Wrong on Revision History --->
					,ISNULL(BSA_Foodservice_Items_Master.is_Item_Group,0) AS Is_Item_Group
					,A.Prod_Var_A
					,Program_Product_Bid_Info.Line_Number
					<cfif arguments.UseTableResults eq 0>,Contract_Products.Contract_Products_Id</cfif>
					<!------, Program_Fixed_Price_Product_Data.Volume----->
FROM  Contract_Products
<cfif arguments.freightrateson EQ 1 OR arguments.Dist_ID neq 0>
	inner join contract_distributors
	on contract_distributors.contract_main_id = Contract_Products.contract_main_id
	and contract_distributors.deleted = 0
	inner join BSA_Foodservice_Customers
	on BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = contract_distributors.BSA_Foodservice_Customers_ID
</cfif>
INNER JOIN	BSA_Foodservice_Items_Master
ON Contract_Products.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
<!--- Get Q_brand --->
<cfif displayGroupType EQ 3><!------ Q Brand ----->
<CFIF application.returned_customer_setting.use_product_q_brand EQ 1>
	INNER JOIN Line_Of_Business
	ON Line_Of_Business.Line_Of_Business_ID = BSA_Foodservice_Items_Master.Line_Of_Business_ID
	LEFT JOIN	Product_Q_Brand_Desc
	ON Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
	AND Product_Q_Brand_Desc.LOB = Line_Of_Business.Line_Of_Business
	AND Product_Q_Brand_Desc.Deleted = 0
	LEFT JOIN Q_Brand_Desc
	ON Q_Brand_Desc.Q_Brand_ID = Product_Q_Brand_Desc.Q_Brand_ID
	AND Q_Brand_Desc.Deleted = 0
<CFELSE>
	LEFT JOIN Q_Brand_Desc
	ON Q_Brand_Desc.Q_Brand_ID = BSA_Foodservice_Items_Master.Q_Brand_ID
	AND Q_Brand_Desc.Deleted = 0
</CFIF>
<!--- Get Q_brand --->
<cfelseif displayGroupType EQ 1><!------ Type Code ----->
	LEFT JOIN Type_Code_Desc
	ON Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
</cfif>
	LEFT JOIN Prod_Var_A A
	ON A.Prod_Var_A_ID = BSA_Foodservice_Items_Master.Prod_Var_A_ID
	INNER JOIN	Program_Fixed_Price_Product_Data
	ON Contract_Products.Contract_Products_ID = Program_Fixed_Price_Product_Data.Contract_Products_ID
	INNER JOIN	Units_of_Measure
	ON Units_of_Measure.Unit_Of_Measure_ID = CASE WHEN Program_Fixed_Price_Product_Data.User_Picked_UOM IN (5,6,7) THEN Program_Fixed_Price_Product_Data.User_Picked_UOM ELSE Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID END<!---63887 --->
	LEFT JOIN Program_Fixed_Component
	ON Program_Fixed_Component.Program_Fixed_Component_Id = Program_Fixed_Price_Product_Data.Program_Fixed_Component_Id
	AND Program_Fixed_Component.DELETED = 0
	LEFT JOIN Program_Fixed_Component_Name
	On Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id = Program_Fixed_Component.Program_Fixed_Component_Name_Id
	INNER JOIN 	Contract_Main
	ON Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
<cfif arguments.getpricebydate EQ 0 and arguments.displaybasesales EQ 1 and arguments.getitemcustprice EQ 0>
	LEFT JOIN @Program_Product_Price As Program_Product_Price
	ON Program_Product_Price.product_id =BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
</cfif>
<cfif arguments.freightrateson EQ 1>
	left join Program_Fixed_Freight_Rates
	on Contract_Products.bsa_foodservice_items_master_id = 	Program_Fixed_Freight_Rates.product_id
	and Program_Fixed_Freight_Rates.customer_id = 	contract_distributors.BSA_Foodservice_Customers_ID
	and Program_Fixed_Freight_Rates.deleted = 0
	and Program_Fixed_Freight_Rates.program_id = 	Contract_Products.Contract_Main_ID
</cfif>

			LEFT JOIN Payment_Type
			ON Program_Fixed_Component.Claim_Mechanics = Payment_Type.Payment_Type_id

			<cfif arguments.Dist_ID neq 0>
			LEFT JOIN ##TMP_Unique_Alias_Info
			ON BSA_Foodservice_Items_Master.Item = ##TMP_Unique_Alias_Info.Item
			AND ##TMP_Unique_Alias_Info.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
			AND ##TMP_Unique_Alias_Info.Use_For_Distributor_Payee_Only =
			CASE
				WHEN Program_Fixed_Component.Fixed_Component_Paid_To <> 1
					THEN 0
			ELSE
				##TMP_Unique_Alias_Info.Use_For_Distributor_Payee_Only
			END
			</cfif>

			 <!--- include this join without condition 41633 --->
			 LEFT JOIN Brand
			 ON BSA_Foodservice_Items_Master.Brand_ID = Brand.Brand_ID

			<!--- If DistributorProductAttribute_1 OR OperatorProductAttribute_1 Is "Pack Size" --->
			<cfif arguments.bDistributorProductAttribute_1 eq 2 OR arguments.bOperatorProductAttribute_1 eq 2>
			 LEFT JOIN Case_Count
			 ON BSA_Foodservice_Items_Master.Case_Count_ID = Case_Count.Case_Count_ID
			</cfif>

			<!--- If DistributorProductAttribute_1 OR OperatorProductAttribute_1 Is "QBrand" --->
			<cfif arguments.bDistributorProductAttribute_1 eq 3 OR arguments.bOperatorProductAttribute_1 eq 3>
			 LEFT JOIN Q_Brand_Desc
			 ON BSA_Foodservice_Items_Master.Q_Brand_ID = Q_Brand_Desc.Q_Brand_ID
			</cfif>

			<!--- If DistributorProductAttribute_1 OR OperatorProductAttribute_1 Is "Type_Code" --->
			<cfif arguments.bDistributorProductAttribute_1 eq 4 OR arguments.bOperatorProductAttribute_1  eq 4>
			 LEFT JOIN Type_Code_Desc
			 ON BSA_Foodservice_Items_Master.Type_Code_Desc_ID= Type_Code_Desc.Type_Code_Desc_ID
			</cfif>

			<!--- If DistributorProductAttribute_1 OR OperatorProductAttribute_1 Is "Type_Group" --->
			<cfif arguments.bDistributorProductAttribute_1 eq 5 OR arguments.bOperatorProductAttribute_1  eq 5>
			 LEFT JOIN Type_Group_Desc
			 ON BSA_Foodservice_Items_Master.Type_Group_Desc_ID = Type_Group_Desc.Type_Group_Desc_ID
			</cfif>

<!--- D35295:Update market pricing to use new group rates grid --->
			LEFT JOIN	Pricing_Level
			ON Pricing_Level.Pricing_Level_ID = Contract_Products.Pricing_Level_ID
<!---D35295:Update market pricing to use new group rates grid --->

			LEFT JOIN Program_Product_Bid_Info
			ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Program_Product_Bid_Info.Product_ID
			AND Contract_Main.Contract_Main_ID = Program_Product_Bid_Info.Program_ID
			AND Program_Product_Bid_Info.deleted = 0

			WHERE       Contract_Products.Deleted = 0 AND Program_Fixed_Price_Product_Data.Deleted = 0
						/* --AND Contract_Main.deleted =0 */
						AND Contract_Products.Product_Type_ID = 1
					  AND Contract_Products.Contract_Main_ID IN (#PreserveSingleQuotes(arguments.Contract_Main_ID)#)
					  AND Contract_Products.Captured_From_Group = 0 --D35295:Update market pricing to use new group rates grid
			<cfif arguments.Dist_ID neq 0>
			AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN (#ListQualify(arguments.Dist_ID,"'")#)
			</cfif>
			<cfif arguments.IncludeInactive eq 0>
	            AND BSA_Foodservice_Items_Master.Active_Code = 'A'
	        </cfif>
			<cfif IsDateExclusion eq 0>
			ORDER BY <cfif arguments.freightrateson EQ 1>contract_distributors.BSA_Foodservice_Customers_ID,</cfif>BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.UPC,   BSA_Foodservice_Items_Master.Description, /* dbo.UDF_REMOVE_NON_ASCIICharOnly(BSA_Foodservice_Items_Master.Description) */
Program_Fixed_Component_Name
			<cfelse>
			ORDER BY <cfif arguments.freightrateson EQ 1>contract_distributors.BSA_Foodservice_Customers_ID,</cfif>BSA_Foodservice_Items_Master.Item , Contract_Main.Contract_Main_ID,Program_Fixed_Component.Program_Fixed_Component_Id, BSA_Foodservice_Items_Master.UPC,
BSA_Foodservice_Items_Master.Description  /*dbo.UDF_REMOVE_NON_ASCIICharOnly(BSA_Foodservice_Items_Master.Description) */
			</cfif>
			if object_id('tempdb..##tmp_cm') is not null
			drop table ##tmp_cm

			if object_id('tempdb..##contract_distributors') is not null
			drop table ##contract_distributors

			if object_id('tempdb..##tmp_cm_total_weight') is not null
			drop table ##tmp_cm_total_weight

			if object_id('tempdb..##tmp_cp_price_layered') is not null
			drop table ##tmp_cp_price_layered

			if object_id('tempdb..##tmp_program_product_price_layered') is not null
			drop table ##tmp_program_product_price_layered
		</CFQUERY>

	<cfif arguments.UseTableResults eq 0>
		<cfreturn qgetFixedPriceProducts />
	<cfelse>

		<CFQUERY NAME="qgetFixedPriceProductsFromTable" datasource="#application.datasource#">
			SELECT top 0 *
			FROM ##TMP_Fixed_Price_Details
		</CFQUERY>

		<cfreturn qgetFixedPriceProductsFromTable />
	</cfif>
	</cffunction>

	<cffunction name="getfixedproductprice" access="public" returntype="query" output="false">

		<cfargument name="FixedPriceProducts" type="query" required="true" default=""/>
		<cfargument name="Program_Fixed_Component_ID" type="string" required="true" />
		<cfargument name="item_num" type="string" required="true" />
		<!--- For Date Exclusion View Programs Page, Contract_Main_ID is not blank --->
		<cfargument name="Contract_Main_ID" type="string" required="false" default =""/>
		<cfargument name="paidTo" type="any" required="false" default =""/>


		<cfquery name="qgetfixedproductprice" dbtype="query">
			select 	distinct Fixed_Price_Value,
					Abbreviation,
					Net_Weight,
					Unit_Of_Measure_ID,
					Contract_Main_ID,
					Contract_Start_Date,
					Contract_End_Date,
					IsExclusionRevision,
					Freight_Rate,
					Market_Price_Rate,
					is_Item_Group,
					Prod_Var_A,
					Stored_Fixed_Price_Value,
					Stored_Fixed_Price_UOM
			from 	arguments.FixedPriceProducts
			where 	Program_Fixed_Component_ID = #arguments.Program_Fixed_Component_ID#
			AND 	BSA_Foodservice_Items_Master_ID = '#arguments.item_num#'
			<cfif Contract_Main_ID neq "">
			AND 	Contract_Main_ID = #arguments.Contract_Main_ID#
			</cfif>
			<cfif arguments.paidTo neq "">
			And Paid_To = #arguments.paidTo#
			</cfif>
		</cfquery>

		<cfreturn qgetfixedproductprice />

	</cffunction>

	<cffunction name="getcompNames" access="public" returntype="query" output="false">

		<cfargument name="Contract_Main_ID" type="string" required="true" />
		<!--- For Date Exclusion View Programs Page, IsDateExclusion = 1 --->
		<cfargument name="IsDateExclusion" type="boolean" required="false" default="0" />

		<CFQUERY name="DROPTMPTABLES" datasource="#application.datasource#">
		IF OBJECT_ID('tempdb..##TMP_CompNames') IS NOT NULL
		DROP TABLE ##TMP_CompNames
		</CFQUERY>

		<CFQUERY name="qgetcompNames" datasource="#application.datasource#">
			SELECT distinct
					ISNULL(firstComp.Program_Fixed_Component_Name, Program_Fixed_Component_Name.Program_Fixed_Component_Name) FirstCompName,
					Program_Fixed_Component_Name.Program_Fixed_Component_Name,
					Program_Fixed_Component_Name.Include_Second_Component,
					Program_Fixed_Component.Fixed_Component_Paid_to,Payment_Paid_To_Type_Name,
					Program_Fixed_Price_Product_Data.Program_Fixed_Component_ID,
					Program_Fixed_Price_Product_Data.Program_Fixed_Component_Name_Rule_ID,
					Program_Fixed_Component_Rule.Unit_Of_Measure_ID as Fixed_Component_Rule_UOM,
					Program_Fixed_Component_Rule.Cost_Impact as Fixed_Component_Rule_Cost_Impact,
					Program_Fixed_Component_Rule.Apply_Percent_To,
					contract_products.Contract_Main_ID, Program_Fixed_Component_Name.Fixed_Component_Type,
					Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id,
					Program_Fixed_Component_Name.Program_Summary_Display_Name

			INTO ##TMP_CompNames
			FROM 	contract_products
					INNER JOIN BSA_Foodservice_Items_Master
					ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = contract_products.BSA_Foodservice_Items_Master_ID
					INNER JOIN Program_Fixed_Price_Product_Data
					ON Program_Fixed_Price_Product_Data.contract_products_id = contract_products.contract_products_id
					AND Program_Fixed_Price_Product_Data.program_id = contract_products.contract_main_id
					INNER JOIN Program_Fixed_Component
					ON Program_Fixed_Component.Program_Fixed_Component_Id = Program_Fixed_Price_Product_Data.Program_Fixed_Component_Id
					AND Program_Fixed_Component.DELETED = 0
					INNER JOIN Program_Fixed_Component_Name
					ON Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id = Program_Fixed_Component.Program_Fixed_Component_Name_Id
					LEFT JOIN Program_Fixed_Component_Name firstComp ON
					firstComp.Second_Component_Name_ID = Program_Fixed_Component.Program_Fixed_Component_Name_Id
					LEFT JOIN Program_Fixed_Component_Rule
					ON	Program_Fixed_Component_Rule.Program_Fixed_Component_Rule_ID = Program_Fixed_Price_Product_Data.Program_Fixed_Component_Name_Rule_ID
					LEFT JOIN Payment_Paid_To_Types ON Payment_Paid_To_Types.Payment_Paid_To_Type_ID = Program_Fixed_Component.Fixed_Component_Paid_to

			WHERE	(Contract_Products.Deleted = 0) AND (Program_Fixed_Price_Product_Data.Deleted = 0) AND (Contract_Products.Product_Type_ID = 1)
			<cfif IsDateExclusion eq 0>
			AND
					(Contract_Products.Contract_Main_ID ='#arguments..Contract_Main_ID#')
			<cfelse>
			AND
					Contract_Products.Contract_Main_ID IN (#ListQualify(replace(arguments..Contract_Main_ID, "'", "","All"),"'")#)
			</cfif>
			<!--- Dev Note(79237) When a component has a second component, both components should be next to neach other, with the parent component displaying before the 2nd component.
			Columns "FirstCompName" and "Include_Second_Component" have been included for that purpose.
			--->
			SELECT * FROM ##TMP_CompNames
			ORDER BY FirstCompName, Include_Second_Component Desc,Program_Fixed_Component_ID
		</CFQUERY>

		<cfreturn qgetcompNames />

	</cffunction>

	<cffunction access="public" name="getgrowthComponents" output="false" returntype="query">

		<cfargument name="Contract_Main_ID" type="string" required="true" />
		<cfargument name="getGrowthExpansion1" type="boolean" required="true" />

		<CFQUERY NAME="qgetgrowthComponents" datasource="#application.datasource#">
			SELECT	Program_Growth_Components.Rate_Type,
					Program_Growth_Components.Component_Name,
					Program_Growth_Components.Component_Description,
					Program_Growth_Components.Program_Growth_Component_ID,
					Program_Growth_Components.Component_Paid_To,
					Program_Growth_Components.Growth_Component_Name_Id,
					Program_Growth_Components.Vendor_Selection,
					isnull(nullif(Program_Growth_Components.Payee_Type,''),0) As Payee_Selection,
					Program_Growth_Components.Vendor_Master_Id,
					<cfif arguments.getGrowthExpansion1>
						Program_Growth_Components.Program_Growth_Component_Type_ID,
						Program_Growth_Components.Tier_Count,
						Program_Growth_Component_Type.Description,
					</cfif>
					Program_Growth_Components.Rate_Type,
					Program_Growth_Components.component_UOM,
					CASE
					  WHEN Program_Growth_Components.component_UOM = 1 THEN
						'Cases'
					  WHEN Program_Growth_Components.component_UOM = 2 THEN
						'Pounds'
					  WHEN Program_Growth_Components.component_UOM = 3 THEN
						'%'
					  WHEN Program_Growth_Components.component_UOM = 4 THEN ---D35731 Growth Auto Pay
						'$'
					  ELSE
						'Not Supplied'
					  END AS component_UOM_Desc,
					  Program_Growth_Components.Program_Growth_Comparison_Period_UOM_ID,
					  GL_Account.GL_Account,
					  GL_Account.GL_Account_Desc,
					  Program_Growth_Components.Program_Growth_Components_Name_Id,
					  Program_Growth_Components.Growth_Calculation, -- D46874 :: New Growth Option (Growth Calculation)
					  Payment_Type.Payment_Type_Name
			FROM      Program_Growth_Components
			<cfif arguments.getGrowthExpansion1>
					INNER JOIN Program_Growth_Component_Type
					ON 	Program_Growth_Component_Type.Program_Growth_Component_Type_ID = Program_Growth_Components.Program_Growth_Component_Type_ID
					AND Program_Growth_Component_Type.Deleted = 0
			</cfif>
					LEFT JOIN GL_Account
					ON GL_Account.GL_Account_ID = Program_Growth_Components.GL_Account_ID
					LEFT JOIN Payment_Type
					ON Program_Growth_Components.Claim_Mechanics = Payment_Type.Payment_Type_id
			WHERE	(Program_Growth_Components.Deleted = 0)
			AND 	(Program_Growth_Components.Program_ID = '#arguments..Contract_Main_ID#')
			<cfif arguments.getGrowthExpansion1>
			AND Program_Growth_Components.IsParent = 1
			</cfif>

		</CFQUERY>

		<cfreturn qgetgrowthComponents />

	</cffunction>

	<cffunction name="GetVolumePool" access="public" returntype="query" output="false">

		<cfargument name="Program_Growth_Component_ID" type="string" required="true" />

		<cfset useLakebaseForqGetVolumePool = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components")>
<cfif useLakebaseForqGetVolumePool>
	<cftry>
		<cfset qGetVolumePool = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_growth_components", {
				"parent_id" = "eq.#arguments.Program_Growth_Component_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetVolumePool = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetVolumePool>
<cfquery name="qGetVolumePool" datasource="#application.datasource#">

			SELECT * FROM Program_Growth_Components
			WHERE Parent_ID = '#arguments.Program_Growth_Component_ID#'
			AND Deleted = 0

		</cfquery>
</cfif>

		<cfreturn qGetVolumePool />

	</cffunction>

	<cffunction name="getComponentTiers" access="public" returntype="query" output="false">

		<cfargument name="Contract_Main_ID" type="string" required="true" />
		<cfargument name="CurrentComponent_ID" type="string" required="true" />

		<CFQUERY NAME="qgetComponentTiers" datasource="#application.datasource#">

			SELECT		Program_Growth_Component_Tier_ID,
						Program_Growth_Component_ID, Tier_Number, Range_Start, Range_End, Growth_Amount,
						Default_Rate, Default_UOM, UOM.Abbreviation,Program_Growth_Component_Tier_ID
			FROM		Program_Growth_Component_Tiers
			LEFT JOIN Units_Of_Measure UOM on UOM.Unit_Of_Measure_ID = Program_Growth_Component_Tiers.Default_UOM
			WHERE
							Deleted = 0
						AND Program_ID = '#arguments.Contract_Main_ID#'
						AND Program_Growth_Component_ID = '#arguments.CurrentComponent_ID#'
			ORDER BY 	CAST(Tier_Number AS FLOAT)

		</CFQUERY>

		<cfreturn qgetComponentTiers />

	</cffunction>

	<cffunction name="GetTargets" access="public" returntype="query" output="false">

		<cfargument name="Program_Growth_Component_ID" type="string" required="true" />

		<cfquery name="qGetTargets" datasource="#application.datasource#">

			SELECT Program_Growth_Component_Tiers.Range_End, Program_Growth_Components.Component_Name, Program_Growth_Components.Target_Order, Units_Of_Measure.Abbreviation, Program_Growth_Components.Program_Growth_Component_ID, Program_Growth_Component_Tiers.Growth_Amount
			FROM Program_Growth_Components
				INNER JOIN Program_Growth_Component_Tiers
				ON Program_Growth_Component_Tiers.Program_Growth_Component_ID = Program_Growth_Components.Program_Growth_Component_ID
				AND Program_Growth_Component_Tiers.Deleted = 0
				INNER JOIN Units_Of_Measure
				ON Units_Of_Measure.Unit_Of_Measure_ID = Program_Growth_Components.Component_UOM
			WHERE Program_Growth_Components.Parent_ID = '#arguments.Program_Growth_Component_ID#'
			AND Program_Growth_Components.Deleted = 0
			ORDER BY Target_Order

		</cfquery>


		<cfreturn qGetTargets />

	</cffunction>

	<cffunction name="TargetItems" access="public" returntype="query" output="false">

		<cfargument name="Program_Growth_Component_ID" type="string" required="true" />

		<cfquery name="qTargetItems" datasource="#application.datasource#">

			SELECT BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.UPC, BSA_Foodservice_Items_Master.Description, BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
			FROM BSA_Foodservice_Items_Master
			INNER JOIN Contract_Products ON Contract_Products.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
			AND Contract_Products.Deleted = 0
			INNER JOIN Program_Growth_Component_Product_Data
				ON Program_Growth_Component_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
				AND Program_Growth_Component_Product_Data.Deleted = 0
				AND Program_Growth_Component_Product_Data.Program_Growth_Component_ID = '#arguments.Program_Growth_Component_ID#'
			WHERE BSA_Foodservice_Items_Master.Deleted = 0
			ORDER BY BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.UPC, BSA_Foodservice_Items_Master.Description
		</cfquery>

		<cfreturn qTargetItems />

	</cffunction>

	<cffunction name="getComponentProducts" access="public" returntype="query" output="false">

		<cfargument name="CurrentComponent_ID" type="string" required="true" />
		<cfargument name="programId" required="true" type="numeric">
		<cfargument name="displayGroupType" type="numeric" required="false" default="0" />
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>
	<!--- 	<cfset var bHasGroups = CreateObject("component", "components.programs.products.Group.ProgramProductGroupDAO").bDiscountTypeHasGroups(arguments.programId, 4) />
		 --->
		<CFQUERY NAME="qgetComponentProducts" datasource="#application.datasource#">

			SELECT		Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID,
						Program_Growth_Component_Product_Data.Program_Growth_Component_ID,
						Program_Growth_Component_Product_Data.Contract_Products_ID,
						CASE
						WHEN Contract_Products.Product_Group_Level_ID = 1 THEN
							'N/A'
						ELSE
							BSA_Foodservice_Items_Master.UPC
						END As UPC,
						CASE
						WHEN Contract_Products.Product_Group_Level_ID = 1 THEN
							'N/A'
						<!---if it's a group product--->
						WHEN Contract_Products.Product_Group_Level_ID IN (SELECT Product_Group_Level_ID FROM Product_Group_Level WHERE Deleted = 0 AND Product_Group_Level_Type NOT IN (1,2,0)) THEN
							APGT.Group_Number
						WHEN Contract_Products.Product_Group_Level_ID IN (SELECT Product_Group_Level_ID FROM Product_Group_Level WHERE Deleted = 0 AND Product_Group_Level_Type = 2) THEN
							Product_Hierarchy.Product_Hierarchy
						ELSE
							BSA_Foodservice_Items_Master.Item
						END As Item,
						BSA_Foodservice_Items_Master.Net_Weight,
						CASE
						WHEN Contract_Products.Product_Group_Level_ID = 1 THEN
							'All ' + ISNULL(Business_Segment.Business_Unit_Desc, '') + ' Products'
						ELSE
							BSA_Foodservice_Items_Master.Description
						END As Description,
						BSA_Foodservice_Items_Master.GTIN,
						Contract_Products.Product_Group_Level_ID,
						Contract_Products.Pricing_Level_ID,
						Contract_Products.Product_Group_ID,
						Contract_Products.Is_Group,
						<cfif displayGroupType EQ 3><!------ Q Brand ----->
						Q_Brand_Desc.Q_Brand DisplayGroupName,
						<cfelseif displayGroupType EQ 1><!------ Type Code ----->
						Type_Code_Desc.Type_Code_Desc DisplayGroupName,
						</cfif>
						Contract_Products.BSA_Foodservice_Items_Master_ID,
						Product_Group_Level.Group_Level_Desc,
						Contract_Products.EZButton_On_Default,
						Brand.Brand_Name
			FROM		Program_Growth_Component_Product_Data
						INNER JOIN	Contract_Products
						ON 	Program_Growth_Component_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
						<!---filter on groups if they exist--->
						AND
						(
							<!------ Group ----->
							(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
							OR
							<!------ Product ----->
							(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
						)
<!--- 						<cfif bHasGroups>
						AND Contract_Products.Is_Group = 1
						</cfif>  --->
						INNER JOIN	BSA_Foodservice_Items_Master
						ON	Contract_Products.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
						LEFT JOIN Brand ON BSA_Foodservice_Items_Master.Brand_ID = Brand.Brand_ID
						<cfif displayGroupType EQ 3><!------ Q Brand ----->
						<!--- Get Q_brand --->
						<CFIF application.returned_customer_setting.use_product_q_brand EQ 1>
						LEFT JOIN	Product_Q_Brand_Desc ON Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID AND
						Product_Q_Brand_Desc.Line_Of_Business_ID = BSA_Foodservice_Items_Master.Line_Of_Business_ID AND
						Product_Q_Brand_Desc.Deleted = 0
						LEFT JOIN Q_Brand_Desc ON Q_Brand_Desc.Q_Brand_ID = Product_Q_Brand_Desc.Q_Brand_ID AND Q_Brand_Desc.Deleted = 0
						<CFELSE>
						LEFT JOIN Q_Brand_Desc ON Q_Brand_Desc.Q_Brand_ID = BSA_Foodservice_Items_Master.Q_Brand_ID AND Q_Brand_Desc.Deleted = 0
						</CFIF>
						<!--- Get Q_brand --->
						<cfelseif displayGroupType EQ 1><!------ Type Code ----->
						LEFT JOIN Type_Code_Desc
						ON
						Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
						</cfif>
						LEFT JOIN Business_Segment
						ON
						Business_Segment.Deleted = 0
						AND
						CAST(Business_Segment.Business_Segment_ID as nvarchar(50)) = Contract_Products.Product_Group_ID
						LEFT JOIN Product_Hierarchy ON
						CAST(Product_Hierarchy.Product_Hierarchy_ID as nvarchar(50)) = Contract_Products.Product_Group_ID
						LEFT JOIN Product_Group_Level ON
						Contract_Products.Product_Group_Level_ID = Product_Group_Level.Product_Group_Level_ID
						LEFT JOIN All_Product_Group_Types APGT
						ON APGT.Group_GUID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
			WHERE
							Contract_Products.Deleted = 0
						AND Program_Growth_Component_ID = '#arguments.CurrentComponent_ID#'

				<cfif appSettings.getViewPgmSortBy() EQ 0 OR appSettings.get_Setting('Product_Group_Sequencing') eq '1'>
					ORDER BY Contract_Products.Pricing_Level_ID, Item, UPC, Description
				<cfelseif appSettings.getViewPgmSortBy() EQ 1>
		 			ORDER BY Description, Item, UPC, Contract_Products.Pricing_Level_ID
				<cfelse>
					ORDER BY Contract_Products.Pricing_Level_ID, Item, UPC, Description
				</cfif>
		</CFQUERY>

		<cfreturn qgetComponentProducts />

	</cffunction>

	<cffunction name="getComponentProductTierData" access="public" returntype="query" output="false">

		<cfargument name="Contract_Main_ID" type="string" required="true" />
		<cfargument name="CurrentProduct" type="string" required="true" />

		<CFQUERY NAME="qgetComponentProductTierData" datasource="#application.datasource#">

			SELECT		Program_Growth_Component_Tiers.Tier_Number, Program_Growth_Component_Product_Tier_Data.Rate,
						Program_Growth_Component_Product_Data.Contract_Products_ID, Program_Growth_Components.Program_ID,
						Units_of_Measure.Abbreviation, Units_of_Measure.Unit_of_Measure_ID
			FROM		Program_Growth_Component_Product_Tier_Data
						INNER JOIN	Program_Growth_Component_Tiers
						ON 	Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID = Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID
						INNER JOIN	Program_Growth_Component_Product_Data
						ON 	Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_ID = Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID
						INNER JOIN	Program_Growth_Components
						ON 	Program_Growth_Component_Tiers.Program_Growth_Component_ID = Program_Growth_Components.Program_Growth_Component_ID
						INNER JOIN	Units_of_Measure
						ON 	Program_Growth_Component_Product_Tier_Data.Unit_Of_Measure_ID = Units_of_Measure.Unit_Of_Measure_ID
			WHERE
								Program_Growth_Component_Product_Tier_Data.Deleted = 0
						AND 	Program_Growth_Component_Product_Data.Deleted = 0
						AND 	Program_Growth_Component_Tiers.Deleted = 0
						AND 	Program_Growth_Component_Product_Data.Contract_Products_ID = '#arguments.CurrentProduct#'
						AND 	Program_Growth_Components.Program_ID = '#arguments.Contract_Main_ID#'
			ORDER BY 	CAST(Program_Growth_Component_Tiers.Tier_Number AS FLOAT)

		</CFQUERY>

		<cfreturn qgetComponentProductTierData />

	</cffunction>

	<cffunction name="getLumpSums" access="public" returntype="query" output="false">

		<cfargument name="Contract_Main_ID" type="string" required="true" />
		<!--- For Date Exclusion View Programs Page, IsDateExclusion = 1 --->
		<cfargument name="IsDateExclusion" type="boolean" required="false" default="0" />

		<CFQUERY NAME="qgetLumpSums" datasource="#application.datasource#">

			SELECT 	Program_Lump_Sums.*, Program_Lump_Sum_Name.Program_Lump_Sum_Name, Program_Lump_Sum_Name.External_ID
					,Contract_Main.Contract_Start_Date, Contract_Main.Contract_End_Date, Contract_Main.IsExclusionRevision,
					GL_Account.GL_Account, GL_Account.GL_Account_Desc, t.Payment_Type_Name
						<!--- D58135 ::  Additional Component info displaye inside program START--->
						,Program_Lump_Sum_Name.ID_on_ViewProgramPage
						,Program_Lump_Sum_Name.DeductionAccount_on_ViewProgramPage
						,Program_Lump_Sum_Name.PaymentAccount_on_ViewProgramPage
						,Program_Lump_Sum_Name.External_ID
						,Program_Lump_Sum_Name.Deduction_Account
						,Program_Lump_Sum_Name.Payment_Account
						<!--- D58135 ::  Additional Component info displaye inside program END--->
			FROM 	Program_Lump_Sums
					INNER JOIN Program_Lump_Sum_Name
					ON
					Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
					LEFT JOIN
					GL_Account
					ON GL_Account.GL_Account_ID = Program_Lump_Sums.GL_Account_ID
					INNER JOIN 	Contract_Main
					ON Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID
					LEFT JOIN Payment_Type t ON t.Payment_Type_id = Program_Lump_Sums.Claim_Mechanics
			WHERE 	Program_ID IN (#PreserveSingleQuotes(arguments.Contract_Main_ID)#)

					AND Program_Lump_Sums.Deleted = 0
					--AND Contract_Main.deleted =0
			<cfif IsDateExclusion eq 0>
			ORDER BY cast(Lump_Sum_Amount as decimal(16,4)),Lump_Sum_Description
			<cfelse>
			ORDER BY Program_Lump_Sums.Program_ID,cast(Lump_Sum_Amount as decimal(16,4)),Lump_Sum_Description
			</cfif>


		</CFQUERY>

		<cfreturn qgetLumpSums />

	</cffunction>

	<cffunction name="getRules" access="public" returntype="query" output="false">

		<cfargument name="Contract_Main_ID" type="string" required="true" />
		<cfargument name="displayGroupType" type="numeric" required="false" default="0" />

		<CFQUERY NAME="qgetRules" datasource="#application.datasource#">

			SELECT     	Contract_Products.Contract_Main_ID,
						Formula_Pricing_Rule.Rule_Name, BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					   	BSA_Foodservice_Items_Master.UPC, BSA_Foodservice_Items_Master.Description,
					   	Formula_Pricing_Rule.Formula_Pricing_Rule_ID,
					   	Program_Formula_Pricing_Rule_Mapped.Program_Formula_Pricing_Rule_Mapped_ID,
					   	<cfif displayGroupType EQ 3><!------ Q Brand ----->
						Q_Brand_Desc.Q_Brand DisplayGroupName,
						<cfelseif displayGroupType EQ 1><!------ Type Code ----->
						Type_Code_Desc.Type_Code_Desc DisplayGroupName,
						</cfif>
					   	Program_Formula_Pricing_Rule_Products.Price
			FROM        BSA_Foodservice_Items_Master
						INNER JOIN	Contract_Products
						ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
						<cfif displayGroupType EQ 3><!------ Q Brand ----->
						<!--- Get Q_brand --->
						<CFIF application.returned_customer_setting.use_product_q_brand EQ 1>
						INNER JOIN	Product_Q_Brand_Desc ON Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID AND
						Product_Q_Brand_Desc.Line_Of_Business_ID = BSA_Foodservice_Items_Master.Line_Of_Business_ID AND
						Product_Q_Brand_Desc.Deleted = 0
						INNER JOIN Q_Brand_Desc ON Q_Brand_Desc.Q_Brand_ID = Product_Q_Brand_Desc.Q_Brand_ID AND Q_Brand_Desc.Deleted = 0
						<CFELSE>
						INNER JOIN Q_Brand_Desc ON Q_Brand_Desc.Q_Brand_ID = BSA_Foodservice_Items_Master.Q_Brand_ID AND Q_Brand_Desc.Deleted = 0
						</CFIF>
						<!--- Get Q_brand --->
						<cfelseif displayGroupType EQ 1><!------ Type Code ----->
						INNER JOIN Type_Code_Desc
						ON
						Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
						</cfif>
						INNER JOIN Program_Formula_Pricing_Rule_Products
						ON Contract_Products.Contract_Products_ID = Program_Formula_Pricing_Rule_Products.Contract_Product_ID
						INNER JOIN Program_Formula_Pricing_Rule_Mapped
						ON
						Program_Formula_Pricing_Rule_Mapped.Program_Formula_Pricing_Rule_Mapped_ID = Program_Formula_Pricing_Rule_Products.Program_Formula_Pricing_Rule_ID
						AND
						Program_Formula_Pricing_Rule_Mapped.Deleted = 0
						LEFT JOIN Formula_Pricing_Rule
						ON
						Formula_Pricing_Rule.Formula_Pricing_Rule_ID = Program_Formula_Pricing_Rule_Mapped.Formula_Pricing_Rule_ID
						AND
						Formula_Pricing_Rule.Deleted = 0
			WHERE
						(Contract_Products.Deleted = 0)
						AND (Contract_Products.Contract_Main_ID = '#arguments.Contract_Main_ID#')
						AND (Program_Formula_Pricing_Rule_Products.Deleted = 0)
			ORDER BY Program_Formula_Pricing_Rule_Mapped.Program_Formula_Pricing_Rule_Mapped_ID, BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.UPC, BSA_Foodservice_Items_Master.Description

		</CFQUERY>

		<cfreturn qgetRules />

	</cffunction>

	<cffunction name="BidProducts" access="public" returntype="query" output="false">

		<cfargument name="Contract_Main_ID" type="string" required="true" />
		<cfargument name="displayGroupType" type="numeric" required="false" default="0" />
		<cfargument name="IncludeInactive" required="false" type="string" default="1" />
		<CFQUERY NAME="qBidProducts" DATASOURCE="#application.datasource#">

			SELECT     	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, BSA_Foodservice_Items_Master.Description,
						BSA_Foodservice_Items_Master.UPC, BSA_Foodservice_Items_Master.Item, Program_Bid_Price_Product_Data.Rate_CS,
						<cfif displayGroupType EQ 3><!------ Q Brand ----->
						Q_Brand_Desc.Q_Brand DisplayGroupName,
						<cfelseif displayGroupType EQ 1><!------ Type Code ----->
						Type_Code_Desc.Type_Code_Desc DisplayGroupName,
						</cfif>
						Program_Bid_Price_Product_Data.Rate_LB
			FROM         Contract_Products INNER JOIN
						  Program_Bid_Price_Product_Data ON
						  Contract_Products.Contract_Products_ID = Program_Bid_Price_Product_Data.Contract_Products_ID INNER JOIN
						  BSA_Foodservice_Items_Master ON
						  Contract_Products.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
						<cfif displayGroupType EQ 3><!------ Q Brand ----->
						<!--- Get Q_brand --->
						<CFIF application.returned_customer_setting.use_product_q_brand EQ 1>
						INNER JOIN	Product_Q_Brand_Desc ON Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID AND
						Product_Q_Brand_Desc.Line_Of_Business_ID = BSA_Foodservice_Items_Master.Line_Of_Business_ID AND
						Product_Q_Brand_Desc.Deleted = 0
						INNER JOIN Q_Brand_Desc ON Q_Brand_Desc.Q_Brand_ID = Product_Q_Brand_Desc.Q_Brand_ID AND Q_Brand_Desc.Deleted = 0
						<CFELSE>
						INNER JOIN Q_Brand_Desc ON Q_Brand_Desc.Q_Brand_ID = BSA_Foodservice_Items_Master.Q_Brand_ID AND Q_Brand_Desc.Deleted = 0
						</CFIF>
						<!--- Get Q_brand --->
						<cfelseif displayGroupType EQ 1><!------ Type Code ----->
						INNER JOIN Type_Code_Desc
						ON
						Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
						</cfif>
					WHERE
							Contract_Products.Deleted = 0
							AND Program_Bid_Price_Product_Data.Deleted = 0
							AND BSA_Foodservice_Items_Master.Deleted = 0
							AND Contract_Products.Product_Type_ID = 9
							AND Contract_Products.Contract_Main_ID = '#arguments.Contract_Main_ID#'
							<cfif arguments.IncludeInactive eq 0>
					            AND BSA_Foodservice_Items_Master.Active_Code = 'A'
					        </cfif>
					ORDER BY BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.UPC, BSA_Foodservice_Items_Master.Description

		</CFQUERY>

		<cfreturn qBidProducts />

	</cffunction>

	<cffunction name="GetValidProductsWithVolume" access="public" returntype="query" output="false">

		<cfargument name="Contract_Main_ID" type="string" required="true" />

		<CFQUERY NAME="qGetValidProductsWithVolume" DATASOURCE="#application.datasource#">

			SELECT BSA_Foodservice_Items_Master_ID
			FROM Program_Product_Volume
			WHERE
				Program_ID = '#arguments.Contract_Main_ID#'
				AND
				len(Volume_LB) > 0
				AND
				len(Volume_CS) > 0
				AND
				Deleted = 0

		</CFQUERY>

		<cfreturn qGetValidProductsWithVolume />

	</cffunction>

	<cffunction name="Att_display" access="public" returntype="query" output="false">

		<cfargument name="Contract_Main_ID" type="string" required="true" />
		<cfargument name="Access_Position_List" type="string" required="true" />
   <cfargument name="User_ID" type="string" required="true" />
    <cfargument name="Profile_View_Private_Documents" type="string" required="true" />
     <cfargument name="Profiles_ID" type="string" required="true" />

	<CFQUERY NAME = "qDeleteTmp" DATASOURCE="#Application.Datasource#">

          IF OBJECT_ID('tempdb..##TMP_CONTRACT_ATTACHMENTS') IS NOT NULL
          DROP TABLE ##TMP_CONTRACT_ATTACHMENTS
	</CFQUERY>
  	<!---
		Dev Notes: D23320/Anand Rao/17-May-10
	  	User profile setting to view private documents
	--->
		<CFQUERY NAME = "qAtt_display" DATASOURCE="#Application.Datasource#">
			/*
        SELECT *
			  FROM 		Document_Details
			  INNER JOIN 	contract_attachments ON Document_Details.Doc_ID = contract_attachments.Doc_ID

			  WHERE 		contract_attachments.Program_ID = #arguments.Contract_Main_ID#
						AND contract_attachments.Deleted = 0
						AND (	(	Public_View = 1
									AND User_Position_ID IN (#preserveSingleQuotes(arguments.Access_Position_List)#)
								)
										OR Public_View = 0
							)
       */

          IF OBJECT_ID('tempdb..##TMP_CONTRACT_ATTACHMENTS') IS NOT NULL
          DROP TABLE ##TMP_CONTRACT_ATTACHMENTS
          SELECT	Document_Details.*
          INTO	##TMP_CONTRACT_ATTACHMENTS
          FROM    Contract_Attachments
          INNER JOIN Document_Details
          ON		Contract_Attachments.Doc_ID = Document_Details.Doc_ID
          AND   (
                  ( Public_View = 1
          		    AND User_Position_ID IN (#Preservesinglequotes(arguments.Access_Position_List)#)
          				)
                 OR Public_View = 0
                )
          LEFT JOIN Profiles_Settings PS
          ON		PS.Profiles_ID = #Request.accessStructure.Profiles_ID#   AND PS.View_Private_Documents = 1
          WHERE   (	Contract_Attachments.Program_ID = '#Trim(arguments.Contract_Main_ID)#'  OR
          					Contract_Attachments.Program_Qualification_ID = '#Trim(arguments.Contract_Main_ID)#'
          				)
          AND 		Contract_Attachments.Deleted = 0
          AND     (Document_Details.uploaded_by = '#arguments.User_ID#' OR  Public_View =0)

          INSERT INTO ##TMP_CONTRACT_ATTACHMENTS
          SELECT	Document_Details.*
          FROM    Contract_Attachments
          INNER JOIN Document_Details ON Contract_Attachments.Doc_ID = Document_Details.Doc_ID
          AND   ((Public_View = 1
                 AND User_Position_ID IN (#Preservesinglequotes(arguments.Access_Position_List)#)
                 )OR Public_View = 0
                )
          INNER JOIN Profiles_Settings PS
          ON		PS.Profiles_ID = #arguments.Profiles_ID#  AND PS.View_Private_Documents = 1
          WHERE   Contract_Attachments.Program_ID = '#trim(arguments.Contract_Main_ID)#'
          AND		Contract_Attachments.DELETED = 0
          AND		NOT EXISTS (SELECT * FROM ##TMP_CONTRACT_ATTACHMENTS
          					WHERE ##TMP_CONTRACT_ATTACHMENTS.Doc_ID = Contract_Attachments.Doc_ID)

          SELECT * FROM ##TMP_CONTRACT_ATTACHMENTS
  	</CFQUERY>

		<cfreturn qAtt_display />

	</cffunction>

	<cffunction name="User_Name" access="public" returntype="query" output="false">

		<cfargument name="Uploaded_By" type="string" required="true" />

		<cfset useLakebaseForqUser_Name = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForqUser_Name>
	<cftry>
		<cfset qUser_Name = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#arguments.Uploaded_By#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUser_Name = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUser_Name>
<CFQUERY NAME="qUser_Name" DATASOURCE="#Application.Datasource#">

			SELECT Name_First, Name_Last FROM _USERS WHERE User_ID = '#arguments.Uploaded_By#'

		</CFQUERY>
</cfif>

		<cfreturn qUser_Name />

	</cffunction>

	<cffunction name="getFixedComponentIDs" access="public" returntype="query" output="false">
		<cfargument name="Contract_Main_ID" type="string" required="true" />
		<cfargument name="Product_ID" type="string" required="false" />

		<CFQUERY NAME = "qFixedComponentIDs" DATASOURCE="#Application.Datasource#">

			SELECT   DISTINCT Program_Fixed_Price_Product_Data.Program_Fixed_Component_ID
			FROM         Contract_Products
						INNER JOIN	BSA_Foodservice_Items_Master
						ON
						Contract_Products.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
						INNER JOIN	Program_Fixed_Price_Product_Data
						ON
						Contract_Products.Contract_Products_ID = Program_Fixed_Price_Product_Data.Contract_Products_ID
						INNER JOIN 	Contract_Main
						ON Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
			WHERE       Contract_Products.Deleted = 0 AND Program_Fixed_Price_Product_Data.Deleted = 0
						AND Contract_Main.deleted =0
						AND Contract_Products.Product_Type_ID = 1

					  	AND Contract_Products.Contract_Main_ID ='#arguments.contract_main_id#'
		</CFQUERY>
		<cfreturn qFixedComponentIDs />

	</cffunction>

	<cffunction name="getRateInUOM" access="public" returntype="string" output="false">

		<cfargument name="rate" type="string" required="true" />
		<cfargument name="currentUOM" type="numeric" required="true" />
		<cfargument name="netWeight" type="string" required="true" />

		<cfset returnValue = arguments.rate />

		<cfif isNumeric(arguments.netWeight)>
			<cfif isNumeric(arguments.rate) AND isNumeric(arguments.netWeight) AND arguments.netWeight NEQ 0>
				<cfset returnValue = arguments.rate />
				<cfif (arguments.currentUOM EQ 1 OR arguments.currentUOM EQ 2)><!------ Right now we only handle 1 and 2 (CS/LB) ----->
					<cfif arguments.currentUOM EQ 2><!------ convert to CS ----->
						<cfset returnValue = arguments.rate * arguments.netWeight />
					<cfelseif arguments.currentUOM EQ 1><!------ convert to LB ----->
						<cfset returnValue = arguments.rate / arguments.netWeight />
					</cfif>
				</cfif>
			</cfif>
		</cfif>

		<!---	Dev Note: Milan(27296) - If one multiplies a number by another in CF and then passes to the NumberFormat function, then we have rounding issues.
			eg:'.0075' multiplied by '30' returns '.225'. This should be shown as '.23' inside the numberformat function in CF, but it shows as '.22'. The solution
			is to use javacast function.
		--->
		<cfset returnValue = javacast("String",returnValue)>
		<cfreturn returnValue />

	</cffunction>

	<cffunction name="getTheOtherUOMDesc" access="public" returntype="string" output="false">

		<cfargument name="currentUOM" type="numeric" required="true" />

		<cfset otherUomId = 0 />
		<cfif (arguments.currentUOM EQ 1 OR arguments.currentUOM EQ 2)><!------ Right now we only handle 1 and 2 (CS/LB) ----->
			<cfif arguments.currentUOM EQ 2><!------ convert to CS ----->
				<cfset otherUomId = 1 />
			<cfelseif arguments.currentUOM EQ 1><!------ convert to LB ----->
				<cfset otherUomId = 2 />
			</cfif>
		</cfif>

		<cfreturn getUOMDesc(otherUomId) />

	</cffunction>

	<cffunction name="getUOMDesc" output="false" returntype="string">
		<cfargument name="uomId" type="numeric" required="true" />
		<cfargument name="descType" type="numeric" required="false" default="1" hint="1=Abbreviation Singular,2=Abbreviation Plural,3=Desc Singular,4=Desc Plural" />

		<cfif ArrayLen(arUOM) EQ 0>
			<cfset arUOM = getUOMArray() />
		</cfif>
		<cfset descType = arguments.descType />

		<cfif arguments.descType LT 1 OR arguments.descType GT 4>
			<cfset descType = 1 />
		</cfif>
		<!---
			D46264 Event Error while selecting a program/Anand Rao/14-Nov-2014
			Since the UOM is not picked we are defaulting it to 1 which is cases to avoid the error.
		--->
		<cfif arguments.uomId EQ 0>
			<cfset arguments.uomId = 1 />
		</cfif>

		<cfreturn arUOM[arguments.uomId][descType] />

	</cffunction>

	<cffunction name="getUOMArray" output="false" returntype="array">

		<cfset var arUOM = arrayNew(1) />

		<cfset useLakebaseForqGetUOM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("units_of_measure")>
<cfif useLakebaseForqGetUOM>
	<cftry>
		<cfset qGetUOM = application.oLakebase.toQuery(
			application.oLakebase.selectRows("units_of_measure", {
				"select" = "unit_of_measure_id,unit_of_measure_desc,unit_of_measure_desc_singular,abbreviation,abbreviation_singular"
			}), "unit_of_measure_id,unit_of_measure_desc,unit_of_measure_desc_singular,abbreviation,abbreviation_singular"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetUOM = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetUOM>
<cfquery name="qGetUOM" datasource="#application.datasource#">
			SELECT	Unit_of_Measure_ID, Unit_Of_Measure_Desc, Unit_Of_Measure_Desc_Singular, Abbreviation, Abbreviation_Singular
			FROM	Units_of_Measure
		</cfquery>
</cfif>

		<cfloop query="qGetUOM">

			<cfset arSingleUOM = arrayNew(1) />
			<cfset arSingleUOM[1] = Abbreviation_Singular />
			<cfset arSingleUOM[2] = Abbreviation />
			<cfset arSingleUOM[3] = Unit_Of_Measure_Desc_Singular />
			<cfset arSingleUOM[4] = Unit_Of_Measure_Desc />
			<cfset arUOM[ArrayLen(arUOM) + 1] = arSingleUOM />

		</cfloop>

		<cfreturn arUOM />
	</cffunction>

	<cffunction name="getfixedbaseprice" access="public" returntype="query" output="false">

		<cfargument name="FixedProducts" type="query" required="true" default=""/>
		<cfargument name="Program_Fixed_Component_ID" type="string" required="true" />
		<cfargument name="item_num" type="string" required="true" />
		<!--- For Date Exclusion View Programs Page, Contract_Main_ID is not blank --->
		<cfargument name="Contract_Main_ID" type="string" required="false" default =""/>
		<cfquery name="qgetfixedbaseprice" dbtype="query">
			select 	distinct Approved_Base_Sales, Fixed_Price_Value,Net_Weight, Unit_Of_Measure_ID,ABBREVIATION,
					Contract_Main_ID
			from 	arguments.FixedProducts
			where 	Program_Fixed_Component_ID = #arguments.Program_Fixed_Component_ID#
			AND 	BSA_Foodservice_Items_Master_ID = '#arguments.item_num#'
			<cfif Contract_Main_ID neq "">
			AND 	Contract_Main_ID = #arguments.Contract_Main_ID#
			</cfif>
		</cfquery>

		<cfreturn qgetfixedbaseprice />
	</cffunction>

	<cffunction name="getFixedPriceOnEmail" access="public" returntype="query" output="false">

		<cfargument name="Contract_Main_ID" type="string" required="true" />
		<cfargument name="Product_ID" type="string" required="false" default="" />

			<CFQUERY NAME="qDeleteTbl" datasource="#application.datasource#">
				IF OBJECT_ID('tempdb..##TMP_Fixed_Price_Rates') IS NOT NULL
				DROP TABLE ##TMP_Fixed_Price_Rates

				IF OBJECT_ID('tempdb..##TMP_Previous_Fixed_Price_Rates') IS NOT NULL
				DROP TABLE ##TMP_Previous_Fixed_Price_Rates
			</CFQUERY>

			<!--- Is this program a revision --->
			<CFQUERY NAME="qgetPreviousVersion" datasource="#application.datasource#">
				SELECT Revision_of_contract_main_id As Previous_Contract_Main_ID
				FROM Contract_Main
				WHERE Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Contract_Main_ID#" />
			</CFQUERY>

			<cfset PreviousContractMainID = qgetPreviousVersion.Previous_Contract_Main_ID>

			<!--- If not a revision, then is this program an "auto renewed" program --->
			<cfif qgetPreviousVersion.Previous_Contract_Main_ID eq "">
				<CFQUERY NAME="qgetProgramRenewalFrom" datasource="#application.datasource#">
					SELECT Renewal_Of_Contract_Main_ID
					FROM Contract_Main
					WHERE Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Contract_Main_ID#" />
					AND Is_AutoRenew = 1
				</CFQUERY>

				<cfset PreviousContractMainID = qgetProgramRenewalFrom.Renewal_Of_Contract_Main_ID>

				<!--- If this program is an "auto renewed" program, we need to get the latest ACTIVE version (if any) of the program from where
				this program was auto-renewed. Price comparison will be made from the latest ACTIVE version of the program from which
				this program was auto renewed.
				--->
				<cfif PreviousContractMainID neq "">
					<CFQUERY NAME="qgetProgramRenewalFromContract" datasource="#application.datasource#">
						SELECT Contract_Number
						FROM Contract_Main
						WHERE Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#PreviousContractMainID#" />
					</CFQUERY>

					<!--- get the "revision_version" of the lastest version of the program --->
					<CFQUERY NAME="qgetRenewedProgramLatestVersion" datasource="#application.datasource#">
						SELECT MAX(Revision_Version) as RevisionVersion
						FROM Contract_Main
						WHERE Contract_Number = '#qgetProgramRenewalFromContract.Contract_Number#'
						AND Contract_Main.Approved = 1
						AND Contract_Main.Effective_Start_Date IS NOT NULL
						AND Contract_Main.Effective_End_Date IS NOT NULL
						AND Contract_Main.deleted = 0
						AND  Contract_Main.Contract_Status_type_IDX IN (5,6,7)
					</CFQUERY>

					<!--- get the "contract_main_id" of the lastest version of the program --->
					<cfif qgetRenewedProgramLatestVersion.recordcount neq 0>
						<CFQUERY NAME="qgetPreviousVersion" datasource="#application.datasource#">
							SELECT Contract_Main_ID As Previous_Contract_Main_ID
							FROM Contract_Main
							WHERE Contract_Number = '#qgetProgramRenewalFromContract.Contract_Number#'
							AND Revision_Version = '#qgetRenewedProgramLatestVersion.RevisionVersion#'
						</CFQUERY>

					<cfset PreviousContractMainID = qgetPreviousVersion.Previous_Contract_Main_ID>
					</cfif>
				</cfif>
			</cfif>

			<CFQUERY NAME="qgetFixedPriceOnEmail" datasource="#application.datasource#">
					DECLARE @Display_Item_No BIT
					SELECT @Display_Item_No = IsNull(NullIf(Value,''),0)
					FROM _Settings
					WHERE Input_Name = 'Display_Item_No'
					CREATE TABLE ##TMP_Previous_Fixed_Price_Rates
					(
					Fixed_Price_Value float,
					BSA_Foodservice_Items_Master_ID varchar(50),
					Program_Fixed_Component_Name_ID int,
					Fixed_Component_Paid_To int,
					Unit_Of_Measure_ID tinyint
					)

					CREATE TABLE ##TMP_Fixed_Price_Rates
					(
					Item varchar(50),
					GTIN varchar(30),
					UPC varchar(50),
					BSA_Foodservice_Items_Master_ID varchar(50),
					description varchar(255),
					alt_description varchar(255),
					Abbreviation char(10),
					Fixed_Price_Value float,
					Fixed_Price_Value_CS float,
					Program_Fixed_Component_Name_ID int,
					Program_Fixed_Component_Name varchar(50),
					Fixed_Component_Paid_To int,
					Component_name_paid_to varchar(55),
					Program_Fixed_Component_ID int,
					Unit_Of_Measure_ID tinyint,
					Program_Fixed_Price_Product_Data_ID int,
					Fixed_Price_Type tinyint,
					Competitor_Name_ID int,
					Competitor_Price decimal (20,4),
					Competitor_Time_Frame varchar(15),
					Volume_CS float,
					Volume_LB float,
					Unit_Of_Measure_Desc varchar(50),
					Payment_Type_Name varchar(50),
					Net_Weight varchar(50)
					)

					<!--- Insert fixed price data --->
					INSERT INTO ##TMP_Fixed_Price_Rates
					(Item,GTIN,UPC,BSA_Foodservice_Items_Master_ID,description,alt_description,Abbreviation,Fixed_Price_Value,Fixed_Price_Value_CS,Program_Fixed_Component_Name_ID,
					Program_Fixed_Component_Name,Fixed_Component_Paid_To,Component_name_paid_to,Program_Fixed_Component_ID,Unit_Of_Measure_ID,Program_Fixed_Price_Product_Data_ID,
					Fixed_Price_Type,Competitor_Name_ID,Competitor_Price,Competitor_Time_Frame,Volume_CS,Volume_LB,Unit_Of_Measure_Desc,Payment_Type_Name,Net_Weight
					)
				SELECT	CASE WHEN @Display_Item_No = '1' THEN
							ISNULL(BSA_Foodservice_Items_Master.Item, '')
						ELSE
							ISNULL(BSA_Foodservice_Items_Master.UPC, '')
						END
						AS item,
					BSA_Foodservice_Items_Master.GTIN,
					BSA_Foodservice_Items_Master.UPC,
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					BSA_Foodservice_Items_Master.description,
					isnull(BSA_Foodservice_Items_Master.alt_description, BSA_Foodservice_Items_Master.description) AS alt_description,
					Units_Of_Measure.Abbreviation,
					Program_Fixed_Price_Product_Data.Fixed_Price_Value,
					CASE Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID
						WHEN 2 THEN CAST(Program_Fixed_Price_Product_Data.Fixed_Price_Value AS FLOAT) * CAST(BSA_Foodservice_Items_Master.Net_Weight AS FLOAT)
						ELSE CAST(Program_Fixed_Price_Product_Data.Fixed_Price_Value AS FLOAT)
					END AS Fixed_Price_Value_CS,
					Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID,
					Program_Fixed_Component_Name.Program_Fixed_Component_Name,
					Program_Fixed_Component.Fixed_Component_Paid_To,
					Program_Fixed_Component_Name.Program_Fixed_Component_Name + '_' + Cast(Program_Fixed_Component.Fixed_Component_Paid_To AS VARCHAR(5)) AS Component_name_paid_to,
					Program_Fixed_Component.Program_Fixed_Component_ID,
					Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID,
					Program_Fixed_Price_Product_Data.Program_Fixed_Price_Product_Data_ID,
					Program_Fixed_Component_Name.Fixed_Price_Type,
					Program_Fixed_Price_Product_Data.Competitor_Name_ID,
					Program_Fixed_Price_Product_Data.Competitor_Price,
					Program_Fixed_Price_Product_Data.Competitor_Time_Frame,
					isnull(Program_Product_Volume.Volume_CS,0) as Volume_CS,
					isnull(Program_Product_Volume.Volume_LB,0) as Volume_LB,
					Units_Of_Measure.Unit_Of_Measure_Desc,
					Payment_Type.Payment_Type_Name,
					BSA_Foodservice_Items_Master.Net_Weight
				FROM	Program_Fixed_Price_Product_Data
					INNER JOIN Program_Fixed_Component ON
					Program_Fixed_Component.Program_Fixed_Component_ID = Program_Fixed_Price_Product_Data.Program_Fixed_Component_ID
					INNER JOIN Program_Fixed_Component_Name ON
					Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID = Program_Fixed_Component.Program_Fixed_Component_Name_ID
					INNER JOIN Units_Of_Measure ON
					Units_Of_Measure.Unit_Of_Measure_ID = Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID
					INNER JOIN Contract_Products ON
					Contract_Products.Contract_Products_ID = Program_Fixed_Price_Product_Data.Contract_Products_ID AND
					Contract_Products.Contract_Main_ID = Program_Fixed_Price_Product_Data.Program_ID
					INNER JOIN BSA_Foodservice_Items_Master ON
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
					LEFT JOIN Program_Product_Volume ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Program_Product_Volume.BSA_Foodservice_Items_Master_ID
													AND Program_Product_Volume.Program_Id = Contract_Products.Contract_Main_Id
					LEFT JOIN Payment_Type
					ON Program_Fixed_Component.Claim_Mechanics = Payment_Type.Payment_Type_id
				WHERE	Program_Fixed_Price_Product_Data.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Contract_Main_ID#" />
				AND	Program_Fixed_Price_Product_Data.Deleted = 0
				AND	Program_Fixed_Component.Deleted = 0
				AND	Program_Product_Volume.Deleted = 0
				<cfif arguments.Product_ID neq "">
				AND Contract_Products.BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Product_ID#" />
				</cfif>
				AND	Contract_Products.Deleted = 0
				AND	Contract_Products.Product_Type_ID = 1

				<!---  For revisions, insert fixed price "rate" for the previous version of the program. --->
				<cfif PreviousContractMainID neq "">
					INSERT INTO ##TMP_Previous_Fixed_Price_Rates(Fixed_Price_Value,BSA_Foodservice_Items_Master_ID,Program_Fixed_Component_Name_ID,
																Fixed_Component_Paid_To,Unit_Of_Measure_ID)
					SELECT	Program_Fixed_Price_Product_Data.Fixed_Price_Value,
							BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
							Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID,
							Program_Fixed_Component.Fixed_Component_Paid_To,
							Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID
					FROM	Program_Fixed_Price_Product_Data
						INNER JOIN Program_Fixed_Component ON
						Program_Fixed_Component.Program_Fixed_Component_ID = Program_Fixed_Price_Product_Data.Program_Fixed_Component_ID
						INNER JOIN Program_Fixed_Component_Name ON
						Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID = Program_Fixed_Component.Program_Fixed_Component_Name_ID
						INNER JOIN Units_Of_Measure ON
						Units_Of_Measure.Unit_Of_Measure_ID = Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID
						INNER JOIN Contract_Products ON
						Contract_Products.Contract_Products_ID = Program_Fixed_Price_Product_Data.Contract_Products_ID AND
						Contract_Products.Contract_Main_ID = Program_Fixed_Price_Product_Data.Program_ID
						INNER JOIN BSA_Foodservice_Items_Master ON
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
						LEFT JOIN Program_Product_Volume ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Program_Product_Volume.BSA_Foodservice_Items_Master_ID
														AND Program_Product_Volume.Program_Id = Contract_Products.Contract_Main_Id
						LEFT JOIN Payment_Type
						ON Program_Fixed_Component.Claim_Mechanics = Payment_Type.Payment_Type_id
					WHERE	Program_Fixed_Price_Product_Data.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#PreviousContractMainID#" />
					AND	Program_Fixed_Price_Product_Data.Deleted = 0
					AND	Program_Fixed_Component.Deleted = 0
					AND	Program_Product_Volume.Deleted = 0
					<cfif arguments.Product_ID neq "">
					AND Contract_Products.BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Product_ID#" />
					</cfif>
					AND	Contract_Products.Deleted = 0
					AND	Contract_Products.Product_Type_ID = 1
				</cfif>

				<!--- Get fixed price data along with "rate change" from previous version --->
					SELECT
						<cfif PreviousContractMainID neq "">
						CASE WHEN tbl_2.Unit_Of_Measure_ID = 1 AND tbl_1.Unit_Of_Measure_ID = 1
							THEN
								tbl_1.Fixed_Price_Value - tbl_2.Fixed_Price_Value
							WHEN tbl_2.Unit_Of_Measure_ID = 2 AND tbl_1.Unit_Of_Measure_ID = 2
							THEN
								tbl_1.Fixed_Price_Value - tbl_2.Fixed_Price_Value
							WHEN tbl_2.Unit_Of_Measure_ID = 1 AND tbl_1.Unit_Of_Measure_ID = 2
							THEN <!--- Convert from cases to pounds --->
								tbl_1.Fixed_Price_Value - (tbl_2.Fixed_Price_Value/tbl_1.Net_Weight)
							WHEN tbl_2.Unit_Of_Measure_ID = 2 AND tbl_1.Unit_Of_Measure_ID = 1
							THEN <!--- Convert from pounds to cases --->
								tbl_1.Fixed_Price_Value - (tbl_2.Fixed_Price_Value * tbl_1.Net_Weight)
							ELSE
								'999999'  <!--- In this case, we do not show rate change --->
							END
							As Rate_Change,
						</cfif>
						tbl_1.*
					FROM ##TMP_Fixed_Price_Rates tbl_1
					LEFT JOIN ##TMP_Previous_Fixed_Price_Rates tbl_2
					ON tbl_1.BSA_Foodservice_Items_Master_ID = tbl_2.BSA_Foodservice_Items_Master_ID
					AND tbl_1.Program_Fixed_Component_Name_ID = tbl_2.Program_Fixed_Component_Name_ID
					AND tbl_1.Fixed_Component_Paid_To = tbl_2.Fixed_Component_Paid_To
					ORDER BY tbl_1.Program_Fixed_Component_Name,tbl_1.Item
			</CFQUERY>

		<cfreturn qgetFixedPriceOnEmail />

	</cffunction>

	<cffunction name="getRebateOnEmail" access="public" returntype="query" output="false">

		<cfargument name="Contract_Main_ID" type="string" required="true" />
		<cfargument name="Product_ID" type="string" required="false" default="" />
		<cfargument name="getItemLevel" type="string" required="false" default="0" />

			<CFQUERY NAME="qDeleteTbl" datasource="#application.datasource#">
				IF OBJECT_ID('tempdb..##TMP_Rebate_Rates') IS NOT NULL
				DROP TABLE ##TMP_Rebate_Rates

				IF OBJECT_ID('tempdb..##TMP_Previous_Rebate_Rates') IS NOT NULL
				DROP TABLE ##TMP_Previous_Rebate_Rates
			</CFQUERY>

			<!--- Is this program a revision --->
			<CFQUERY NAME="qgetPreviousVersion" datasource="#application.datasource#">
				SELECT Revision_of_contract_main_id As Previous_Contract_Main_ID
				FROM Contract_Main
				WHERE Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Contract_Main_ID#" />
			</CFQUERY>

			<cfset PreviousContractMainID = qgetPreviousVersion.Previous_Contract_Main_ID>

			<!--- If not a revision, then is this program an "auto renewed" program --->
			<cfif qgetPreviousVersion.Previous_Contract_Main_ID eq "">
				<CFQUERY NAME="qgetProgramRenewalFrom" datasource="#application.datasource#">
					SELECT Renewal_Of_Contract_Main_ID
					FROM Contract_Main
					WHERE Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Contract_Main_ID#" />
					AND Is_AutoRenew = 1
				</CFQUERY>

				<cfset PreviousContractMainID = qgetProgramRenewalFrom.Renewal_Of_Contract_Main_ID>

				<!--- If this program is an "auto renewed" program, we need to get the latest ACTIVE version (if any) of the program from where
				this program was auto-renewed. Price comparison will be made from the latest ACTIVE version of the program from which
				this program was auto renewed.
				--->
				<cfif PreviousContractMainID neq "">
					<CFQUERY NAME="qgetProgramRenewalFromContract" datasource="#application.datasource#">
						SELECT Contract_Number
						FROM Contract_Main
						WHERE Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#PreviousContractMainID#" />
					</CFQUERY>

					<!--- get the "revision_version" of the lastest version of the program --->
					<CFQUERY NAME="qgetRenewedProgramLatestVersion" datasource="#application.datasource#">
						SELECT MAX(Revision_Version) as RevisionVersion
						FROM Contract_Main
						WHERE Contract_Number = '#qgetProgramRenewalFromContract.Contract_Number#'
						AND Contract_Main.Approved = 1
						AND Contract_Main.Effective_Start_Date IS NOT NULL
						AND Contract_Main.Effective_End_Date IS NOT NULL
						AND Contract_Main.deleted = 0
						AND  Contract_Main.Contract_Status_type_IDX IN (5,6,7)
					</CFQUERY>

					<!--- get the "contract_main_id" of the lastest version of the program --->
					<CFQUERY NAME="qgetPreviousVersion" datasource="#application.datasource#">
						SELECT Contract_Main_ID As Previous_Contract_Main_ID
						FROM Contract_Main
						WHERE Contract_Number = '#qgetProgramRenewalFromContract.Contract_Number#'
						AND Revision_Version = '#qgetRenewedProgramLatestVersion.RevisionVersion#'
					</CFQUERY>

					<cfset PreviousContractMainID = qgetPreviousVersion.Previous_Contract_Main_ID>
				</cfif>
			</cfif>

			<CFQUERY NAME="qgetRebateOnEmail" datasource="#application.datasource#">
				DECLARE @Display_Item_No BIT
				SELECT @Display_Item_No = IsNull(NullIf(Value,''),0)
				FROM _Settings
				WHERE Input_Name = 'Display_Item_No'
				CREATE TABLE ##TMP_Previous_Rebate_Rates
				(
				rate float,
				BSA_Foodservice_Items_Master_ID varchar(50),
				Program_Rebates_Component_Name_ID int,
				Component_Paid_to int,
				Unit_Of_Measure_ID tinyint
				)

				CREATE TABLE ##TMP_Rebate_Rates
				(
				Item varchar(50),
				GTIN varchar(30),
				UPC varchar(50),
				BSA_Foodservice_Items_Master_ID varchar(50),
				description varchar(255),
				alt_description varchar(255),
				Abbreviation char(10),
				rate float,
				Rate_CS float,
				Program_Rebates_Component_Name_ID int,
				Program_Rebates_Component_Name [varchar](50),
				Component_Paid_to int,
				Component_name_paid_to varchar(55),
				Program_Rebates_Component_ID int,
				Unit_Of_Measure_ID tinyint,
				Program_Rebates_Component_Data_ID int,
				Pricing_Level_ID int,
				Group_Level_Desc varchar(100),
				Inventory_UM varchar(3),
				Competitor_Name_ID int,
				Competitor_Price decimal (20,4),
				Competitor_Time_Frame varchar(15),
				Volume_CS float,
				Volume_LB float,
				Unit_Of_Measure_Desc varchar(50),
				Payment_Type_Name varchar(50),
				Net_Weight varchar(50)
				)

				<!--- Insert rebate data --->
				INSERT INTO ##TMP_Rebate_Rates
				(Item,GTIN,UPC,BSA_Foodservice_Items_Master_ID,description,alt_description,Abbreviation,rate,Rate_CS,Program_Rebates_Component_Name_ID,
				Program_Rebates_Component_Name,Component_Paid_to,Component_name_paid_to,Program_Rebates_Component_ID,Unit_Of_Measure_ID,Program_Rebates_Component_Data_ID,
				Pricing_Level_ID,Group_Level_Desc,Inventory_UM,Competitor_Name_ID,Competitor_Price,Competitor_Time_Frame,Volume_CS,Volume_LB,Unit_Of_Measure_Desc,
				Payment_Type_Name,Net_Weight
				)
				SELECT	CASE WHEN @Display_Item_No = '1' THEN
							ISNULL(BSA_Foodservice_Items_Master.Item, '')
						ELSE
							ISNULL(BSA_Foodservice_Items_Master.UPC, '')
						END
						AS item,
				BSA_Foodservice_Items_Master.GTIN,
				BSA_Foodservice_Items_Master.UPC,
				BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
				BSA_Foodservice_Items_Master.description,
				isnull(BSA_Foodservice_Items_Master.alt_description, BSA_Foodservice_Items_Master.description) AS alt_description,
				Units_Of_Measure.Abbreviation,
				Program_Rebates_Component_Data.Rate,
				CASE Program_Rebates_Component_Data.Unit_Of_Measure_ID
					WHEN 2 THEN CAST(Program_Rebates_Component_Data.Rate AS FLOAT) * CAST(bsa_FoodService_Items_Master.Net_Weight AS FLOAT)
					ELSE CAST(Program_Rebates_Component_Data.Rate AS FLOAT)
				END AS Rate_CS,
				Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID,
				Program_Rebates_Component_Name.Program_Rebates_Component_Name,
				Program_Rebates_Component.Component_Paid_To,
				Program_Rebates_Component_Name.Program_Rebates_Component_Name + '_' + Cast(Program_Rebates_Component.Component_Paid_To AS VARCHAR(5)) AS Component_name_paid_to,
				Program_Rebates_Component.Program_Rebates_Component_ID,
				Program_Rebates_Component_Data.Unit_Of_Measure_ID,
				Program_Rebates_Component_Data.Program_Rebates_Component_Data_ID,
				Contract_Products.Pricing_Level_ID,
				Product_Group_Level.Group_Level_Desc,
				BSA_Foodservice_Items_Master.Inventory_UM,
				Program_Rebates_Product_Data.Competitor_Name_ID,
				Program_Rebates_Product_Data.Competitor_Price,
				Program_Rebates_Product_Data.Competitor_Time_Frame,
				isnull(Program_Product_Volume.Volume_CS,0) as Volume_CS,
				isnull(Program_Product_Volume.Volume_LB,0) as Volume_LB,
				Units_Of_Measure.Unit_Of_Measure_Desc,
				Payment_Type.Payment_Type_Name,
				BSA_Foodservice_Items_Master.Net_Weight
			FROM	Program_Rebates_Component_Data
				INNER JOIN Program_Rebates_Product_Data ON
				Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID
				INNER JOIN Program_Rebates_Component ON
				Program_Rebates_Component.Program_Rebates_Component_ID = Program_Rebates_Component_Data.Program_Rebates_Component_ID
				INNER JOIN Program_Rebates_Component_Name ON
				Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID
				INNER JOIN Units_Of_Measure ON
				Units_Of_Measure.Unit_Of_Measure_ID = (CASE WHEN ISNULL(Program_Rebates_Component_Data.User_picked_UOM, 0)  = 0
										THEN  Program_Rebates_Component_Data.Unit_Of_Measure_ID
										ELSE Program_Rebates_Component_Data.User_picked_UOM END
				                                       )
				INNER JOIN Contract_Products ON
				Contract_Products.Contract_Products_ID = Program_Rebates_Product_Data.Contract_Products_ID AND
				Contract_Products.Contract_Main_ID = Program_Rebates_Product_Data.Program_ID
				INNER JOIN BSA_Foodservice_Items_Master ON
				BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
				LEFT JOIN Program_Product_Volume ON	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Program_Product_Volume.BSA_Foodservice_Items_Master_ID
				                                 AND Program_Product_Volume.Program_Id = Contract_Products.Contract_Main_Id
				LEFT JOIN Product_Group_Level ON Contract_Products.Product_Group_Level_ID = Product_Group_Level.Product_Group_Level_ID
				LEFT JOIN Payment_Type ON Program_Rebates_Component.Claim_Mechanics = Payment_Type.Payment_Type_id
			WHERE	Program_Rebates_Component_Data.Deleted = 0
			AND	Program_Rebates_Product_Data.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Contract_Main_ID#" />
			AND	Program_Rebates_Product_Data.Deleted = 0
			AND	Program_Rebates_Component.Program_ID = Program_Rebates_Product_Data.Program_ID
			AND	Program_Rebates_Component.Deleted = 0
			AND	Program_Product_Volume.Deleted = 0
			<cfif arguments.Product_ID neq "">
			AND Contract_Products.BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Product_ID#" />
			</cfif>
			AND	Contract_Products.Deleted = 0
			AND	Contract_Products.Product_Type_ID = 2
			<cfif arguments.getItemLevel eq 1>
				AND	Contract_Products.Is_Group = 0
			<cfelse>
				AND	Contract_Products.Captured_From_Group = 0
			</cfif>

			<!---  For revisions, insert rebate "rate" for the previous version of the program. --->
			<cfif PreviousContractMainID neq "">
				INSERT INTO ##TMP_Previous_Rebate_Rates(rate,BSA_Foodservice_Items_Master_ID,Program_Rebates_Component_Name_ID,Component_Paid_to,Unit_Of_Measure_ID)
				SELECT Program_Rebates_Component_Data.Rate,
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
						Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID,
						Program_Rebates_Component.Component_Paid_To,
						Program_Rebates_Component_Data.Unit_Of_Measure_ID
				FROM	Program_Rebates_Component_Data
					INNER JOIN Program_Rebates_Product_Data ON
					Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID
					INNER JOIN Program_Rebates_Component ON
					Program_Rebates_Component.Program_Rebates_Component_ID = Program_Rebates_Component_Data.Program_Rebates_Component_ID
					INNER JOIN Program_Rebates_Component_Name ON
					Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID
					INNER JOIN Units_Of_Measure ON
					Units_Of_Measure.Unit_Of_Measure_ID = (CASE WHEN ISNULL(Program_Rebates_Component_Data.User_picked_UOM, 0)  = 0
											THEN  Program_Rebates_Component_Data.Unit_Of_Measure_ID
											ELSE Program_Rebates_Component_Data.User_picked_UOM END
					                                       )
					INNER JOIN Contract_Products ON
					Contract_Products.Contract_Products_ID = Program_Rebates_Product_Data.Contract_Products_ID AND
					Contract_Products.Contract_Main_ID = Program_Rebates_Product_Data.Program_ID
					INNER JOIN BSA_Foodservice_Items_Master ON
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
					LEFT JOIN Program_Product_Volume ON	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Program_Product_Volume.BSA_Foodservice_Items_Master_ID
											AND Program_Product_Volume.Program_Id = Contract_Products.Contract_Main_Id
					WHERE	Program_Rebates_Component_Data.Deleted = 0
					AND	Program_Rebates_Product_Data.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#PreviousContractMainID#" />
					AND	Program_Rebates_Product_Data.Deleted = 0
					AND	Program_Rebates_Component.Program_ID = Program_Rebates_Product_Data.Program_ID
					AND	Program_Rebates_Component.Deleted = 0
					AND	Program_Product_Volume.Deleted = 0
					<cfif arguments.Product_ID neq "">
					AND Contract_Products.BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Product_ID#" />
					</cfif>
					AND	Contract_Products.Deleted = 0
					AND	Contract_Products.Product_Type_ID = 2
					<cfif arguments.getItemLevel eq 1>
						AND	Contract_Products.Is_Group = 0
					<cfelse>
						AND	Contract_Products.Captured_From_Group = 0
					</cfif>
			</cfif>

			<!--- Get rebate data along with "rate change" from previous version --->
			SELECT
				<cfif PreviousContractMainID neq "">
				CASE WHEN tbl_2.Unit_Of_Measure_ID = 1 AND tbl_1.Unit_Of_Measure_ID = 1
					THEN
						tbl_1.rate - tbl_2.rate
					WHEN tbl_2.Unit_Of_Measure_ID = 2 AND tbl_1.Unit_Of_Measure_ID = 2
					THEN
						tbl_1.rate - tbl_2.rate
					WHEN tbl_2.Unit_Of_Measure_ID = 1 AND tbl_1.Unit_Of_Measure_ID = 2
					THEN <!--- Convert from cases to pounds --->
						tbl_1.rate - (tbl_2.rate/tbl_1.Net_Weight)
					WHEN tbl_2.Unit_Of_Measure_ID = 2 AND tbl_1.Unit_Of_Measure_ID = 1
					THEN <!--- Convert from pounds to cases --->
						tbl_1.rate - (tbl_2.rate * tbl_1.Net_Weight)
					ELSE
						'999999'  <!--- In this case, we do not show rate change --->
					END
					As Rate_Change,
				</cfif>
					tbl_1.*
				FROM ##TMP_Rebate_Rates tbl_1
				LEFT JOIN ##TMP_Previous_Rebate_Rates tbl_2
				ON tbl_1.BSA_Foodservice_Items_Master_ID = tbl_2.BSA_Foodservice_Items_Master_ID
				AND tbl_1.Program_Rebates_Component_Name_ID = tbl_2.Program_Rebates_Component_Name_ID
				AND tbl_1.Component_Paid_to = tbl_2.Component_Paid_to
			<!--- Dev Note(61239): We need this ORDER BY in this order so that the product rate where distributor is the payee should
			correctly be under the distributor header and the same for operator. This is for the OPERATOR LETTER.
			Note: A similar change has been made on "create_letters_custom3.cfm" (vars.qRebateUniqueItems), where a query of query of this query is being used.
			--->
			ORDER BY tbl_1.Pricing_Level_ID,tbl_1.Component_name_paid_to,tbl_1.Item
			</CFQUERY>

		<cfreturn qgetRebateOnEmail />

	</cffunction>

	<cffunction name="getLumbSumOnEmail" access="public" returntype="query" output="false">

		<cfargument name="Contract_Main_ID" type="string" required="true" />
		<CFQUERY NAME="qgetLumbSumOnEmail" datasource="#application.datasource#">
			SELECT Program_Lump_Sums.Lump_Sum_Amount, Program_Lump_Sum_Name.Program_Lump_Sum_Name
 			FROM Program_Lump_Sums
			INNER JOIN Program_Lump_Sum_Name ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
			INNER JOIN Contract_Main ON Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID
			WHERE Program_ID IN (#arguments.Contract_Main_ID#)
			AND Program_Lump_Sums.Deleted = 0
			order by  Program_Lump_Sum_Name.Program_Lump_Sum_Name

		</CFQUERY>
		<cfreturn qgetLumbSumOnEmail />

	</cffunction>

	<cffunction name="getProgramTypeOnEmail" output="false" returntype="string">

		<cfargument name="ProgramTypeID" required="true" type="numeric" />
		<cfset useLakebaseForqgetProgramTypeOnEmail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForqgetProgramTypeOnEmail>
	<cftry>
		<cfset qgetProgramTypeOnEmail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#arguments.ProgramTypeID#",
				"select" = "created_type"
			}), "created_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetProgramTypeOnEmail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetProgramTypeOnEmail>
<CFQUERY NAME="qgetProgramTypeOnEmail" datasource="#application.datasource#">
			SELECT Created_Type
			FROM Program_Control_Panel_Options
			WHERE ProgramControl_Panel_Options_ID = '#arguments.ProgramTypeID#'
		</CFQUERY>
</cfif>
		<cfreturn qgetProgramTypeOnEmail.Created_Type />

	</cffunction>
<!--- D31561: Operator Groups Search START--->
	<cffunction name="ProgramOperatorIsGroup" output="false">

		<cfargument name="programId" required="true" type="numeric" />

		<cfset returnValue = 0 />
		<cfset useLakebaseForqGetGroupsSaved = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_operators")>
<cfif useLakebaseForqGetGroupsSaved>
	<cftry>
		<cfset qGetGroupsSaved = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_operators", {
				"contract_main_id" = "eq.#arguments.programId#",
				"deleted" = "eq.0",
				"is_group" = "eq.1",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetGroupsSaved = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetGroupsSaved>
<cfquery name="qGetGroupsSaved" datasource="#application.datasource#">
			SELECT 	TOP 1 *
			FROM 	Contract_Operators
			WHERE 	Contract_Main_ID = #arguments.programId#
			AND 	Deleted = 0
			AND		Is_Group = 1
		</cfquery>
</cfif>

		<cfif qGetGroupsSaved.recordCount>
			<cfset returnValue = 1 />
		</cfif>

		<cfreturn returnValue>

	</cffunction>
<!--- D31561: Operator Groups Search END--->

	<cffunction name="getSettings" output="false">
		<cfargument name="programId" required="true" type="numeric" />

		<cfquery name="qGetSettings" datasource="#application.datasource#">
				SELECT PCPO.Discount_Rebates_Group_Level,
						exclude_sig_products,
						modifying_program,
						EZButton_On,
						EZ_Contract_Id,
						First_Parent_Id,
						Contract_Main.Template_Filters_Id,
						PCPO.Custom_Fixed_Price_Options,
						PCPO.Discount_Fixed_Prices_Freight
				FROM Contract_Main
				INNER JOIN	Program_Control_Panel_Options PCPO ON
					Contract_Main.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
				WHERE Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
			</cfquery>

		<cfreturn qGetSettings>

	</cffunction>

	<cffunction name="FixedCompDelete" returntype="any" access="remote" output="false" hint="Remove Comp From Program">
		<cfargument name="ContractMainID" required="true" default="" />
		<cfargument name="CompID" required="true" default="" />

		<cfset useLakebaseForupdFixedComp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_component")>
<cfif useLakebaseForupdFixedComp>
	<cftry>
		<cfset application.oLakebase.updateRows("program_fixed_component",
			{
				"program_id" = "eq.#arguments.ContractMainID#",
				"program_fixed_component_name_id" = "eq.#arguments.CompID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdFixedComp = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdFixedComp>
<cfquery name="updFixedComp" datasource="#application.datasource#">
				UPDATE Program_Fixed_Component
				set deleted = 1
				where Program_ID = '#arguments.ContractMainID#'
				AND Program_Fixed_Component_Name_ID = #arguments.CompID#
		</cfquery>
</cfif>
		<cfreturn 0>
	</cffunction>
</cfcomponent>