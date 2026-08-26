<!---------------------------------------------------------------------------------------------------------------------
      Template: \common_Files\contracts\verticalpnl_action.cfm
      Date:     2018 June
      Author:   Chris Nguyen
      Purpose:  Posting action for vertical p&l
----------------------------------------------------------------------------------------------------------------------->

<cfif cgi.request_method eq 'post'>

	<!--- <cfdump var="#form#" abort="true"> --->
	 <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
	<!--- list of all editable input elements on the page --->
	<cfscript>
		param name="form.action" default="";
		param name="form.product_count" default="0";
		param name="variables.recalcRequestedPrice" default="0";

		field_names = [
					 		"base_sales"
					 		,"allowance_surcharges"
					 		,"customer_freight"
					  		,"tpa_oper"
					  		,"tpa"
					    	,"pullbackamount"
					    	,"other_spend"
				    		,"cost"
				      		,"shuttle_freight"
					    	,"custom_warehouse"
					  		,"custom_brokerage"
				      		,"map_mdf"
					  		,"sga"
					  		,"base_sales_cs"
					  		,"tpa_cs"
					  		,"cash_disc_cs"
					  		,"map_mdf_cs"
					  		,"custom_brokerage_cs"
					  		,"custom_warehouse_cs"
					  		,"customer_freight_cs"
					  		,"shuttle_freight_cs"
					  		,"variable_contribution_margin_cs"
					  		,"program_fixed_price_cs" /*	-----	Start RFP "custom_h"	-----	*/
					  		,"sga_cs"
					  		/*,"Fixed_Price_Value"		This is not updated by user but we use it to hold old Fixed_Price_Value when the user updates CM% (variable_contribution_margin_cs)*/
						];
	
	// margin_type = 1 is CS and UOM = 1, margin_type = 3 is LB and UOM = 2, margin_type = 3 is STAT and UOM = 3
	uom  		= (form.margin_type eq "3" ? 2 : (form.margin_type eq "2" ? 3 : form.margin_type));
	runFreight = 0;
	</cfscript>

	<!---  <cfdump var="#form#" output = "c:\dump.log"> --->
	<cfif form.action is "update_to_system_values">
		<cfif appSettings.get_Setting('Custom_RFP_Process',0) EQ 1 >
			<cfloop from="1" to="#form.product_count#" index="idx">
				<cfset product_id = form[ "prod_id_" & idx ]>
				<cfset checked = structKeyExists(form,"chk_upd_" & idx)>
					<!--- UPDATE FIXED PRICE VALUE BACK TO ORIGINAL VALUE -> FROM BEFORE CM% OVerride Updated it.
						We NEED to update before the Contract_Product_Margin_Override data is deleted 	CPMO.Field_Name = 'Fixed_Price_Value' OR  --->
				<cfif checked>
					<cfquery name="qCheckRequestedPrice" datasource="#application.datasource#">
						SELECT 1 FROM Contract_Product_Margin_Override CPMO
						INNER JOIN Contract_Products CP ON
							CP.Contract_Main_Id = CPMO.Contract_Main_ID AND
							CP.BSA_Foodservice_Items_Master_ID = CPMO.BSA_Foodservice_Items_Master_ID
						INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON 
							PFPPD.Contract_Products_ID = CP.Contract_Products_ID
						WHERE 	CPMO.Contract_Main_ID = #form.contract_main_id# AND
								CPMO.BSA_Foodservice_Items_Master_ID = '#product_id#' AND
								(CPMO.Field_Name = 'program_fixed_price_cs') AND
								CPMO.Deleted = 0 AND
								CP.Contract_Main_Id = #form.contract_main_id#  AND
								CP.Product_Type_ID = 1 AND
								CAST(PFPPD.Fixed_Price_Value as decimal(12,2)) != 0.0 AND
								Fixed_Price_Value != cast(cast(CPMO.Old_Value as decimal(12,2)) as varchar(25))
					</cfquery>

					<cfquery name="qUpdateRequestedPrice" datasource="#application.datasource#"  result="updCount">
						UPDATE PFPPD
							SET Fixed_Price_Value = cast(cast(CPMO.Old_Value as decimal(12,2)) as varchar(25))
						FROM  Contract_Product_Margin_Override CPMO
						INNER JOIN Contract_Products CP ON
							CP.Contract_Main_Id = CPMO.Contract_Main_ID AND
							CP.BSA_Foodservice_Items_Master_ID = CPMO.BSA_Foodservice_Items_Master_ID
						INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON 
							PFPPD.Contract_Products_ID = CP.Contract_Products_ID
						WHERE 	CPMO.Contract_Main_ID = #form.contract_main_id# AND
								CPMO.BSA_Foodservice_Items_Master_ID = '#product_id#' AND
								(CPMO.Field_Name = 'program_fixed_price_cs') AND
								CPMO.Deleted = 0 AND
								CP.Contract_Main_Id = #form.contract_main_id#  AND
								CP.Product_Type_ID = 1 AND
								CAST(PFPPD.Fixed_Price_Value as decimal(12,2)) != 0.0
					</cfquery>
					<cfif qCheckRequestedPrice.RECORDCOUNT GT 0>
						<cfset runFreight = 1>  <!--- If fixed price is updated, re-calc Freight --->
					</cfif>

					<cfquery name="qZapCPMO" datasource="#application.datasource#">
						UPDATE Contract_Product_Margin_Override
							SET Deleted = 1,
								Deleted_User_Id = '#request.AccessStructure.user_id#',
								Deleted_Date = GetDate()
						 WHERE Contract_Main_ID = #form.contract_main_id# AND
								BSA_Foodservice_Items_Master_ID = '#product_id#' 
					</cfquery>
				</cfif>
			</cfloop>
		</cfif>	

		

		<cfif appSettings.get_Setting('Custom_RFP_Process',0) EQ 0 > 
				<cfquery name="qZapCPMO" datasource="#application.datasource#">
					DELETE Contract_Product_Margin_Override
					 WHERE Contract_Main_ID = #form.contract_main_id#
				</cfquery>
		</cfif>

	<cfelseif form.action is "save">
		<cfoutput>	
		<!--- scan through all products --->
		<cfloop from="1" to="#form.product_count#" index="idx">
			<cfset product_id = form[ "prod_id_" & idx ]>
			<cfset marginPercentOverRide = 0>
			<!--- scan through all possible field names --->
			<cfloop array="#field_names#" item="field_name">
				<!--- find input element using field name and product sequence number (e.g. COST_1, TPA_4) --->
				<cfset input_name = field_name & "_" & idx>
				<!--- input element exists when user change it --->
				<cfif structKeyExists(form, input_name)>
					<cfset variables.val = replace(form[ "old_" & input_name ],',','','ALL') />
					<cfset variables.valNew = replace(form[ input_name ],',','','ALL') />
					<cfif appSettings.get_Setting('Custom_RFP_Process',0) EQ 0 >    <!--- ONLY FIFFERENCE IS UPDATE Old_Value --->
						<cfquery name="qUpdateCPMO" datasource="#application.datasource#">
							IF NOT EXISTS(
											SELECT * 
											FROM Contract_Product_Margin_Override
											WHERE Contract_Main_ID                = #form.contract_main_id#
												AND   BSA_Foodservice_Items_Master_ID = '#product_id#'
												AND   Field_Name                      = '#field_name#'
												AND   Deleted = 0

										)
								INSERT INTO Contract_Product_Margin_Override
											(Contract_Main_ID, BSA_Foodservice_Items_Master_ID, Field_Name, Unit_of_measure, Old_Value)
									VALUES	(#form.contract_main_id#, '#product_id#', '#field_name#', #uom#, #variables.val#)

							UPDATE Contract_Product_Margin_Override
								SET  Old_Value        = #variables.val#, /* ONLY DIFFERENCE TO THIS qUpdateCPMO */
									 New_Value        = #variables.valNew#
									, Created_By       = '#request.AccessStructure.user_id#'
									, Unit_of_measure  = #uom#						
							  WHERE   Contract_Main_ID                = #form.contract_main_id#
								AND   BSA_Foodservice_Items_Master_ID = '#product_id#'
								AND   Field_Name                      = '#field_name#'
								AND   Deleted = 0
						</cfquery>
					<cfelseif appSettings.get_Setting('Custom_RFP_Process',0) EQ 1 >
						<cfquery name="qUpdateCPMO" datasource="#application.datasource#">
							IF NOT EXISTS(
											SELECT * 
											FROM Contract_Product_Margin_Override
											WHERE Contract_Main_ID                = #form.contract_main_id#
												AND   BSA_Foodservice_Items_Master_ID = '#product_id#'
												AND   Field_Name                      = '#field_name#'
												AND   Deleted = 0

										)
								INSERT INTO Contract_Product_Margin_Override
											(Contract_Main_ID, BSA_Foodservice_Items_Master_ID, Field_Name, Unit_of_measure, Old_Value)
									VALUES	(#form.contract_main_id#, '#product_id#', '#field_name#', #uom#, #variables.val#)

							UPDATE Contract_Product_Margin_Override
								SET  /*Old_Value        = #variables.val#,*/   /* ONLY DIFFERENCE TO THIS qUpdateCPMO */
									 New_Value        = #variables.valNew#
									, Created_By       = '#request.AccessStructure.user_id#'
									, Unit_of_measure  = #uom#						
							  WHERE   Contract_Main_ID                = #form.contract_main_id#
								AND   BSA_Foodservice_Items_Master_ID = '#product_id#'
								AND   Field_Name                      = '#field_name#'
								AND   Deleted = 0
								AND   ISNULL(New_Value,-1) != #variables.valNew#
						</cfquery>
						<cfif field_name eq 'variable_contribution_margin_cs'>  <!--- SPECIAL MARGIN % OVERRIDE UPDATES REQUESTED PRICE --->
							<cfset marginPercentOverRide = 1>
							<cfquery name="qUpdateCPMO" datasource="#application.datasource#">
								IF NOT EXISTS(
												SELECT * 
												FROM Contract_Product_Margin_Override
												WHERE Contract_Main_ID                = #contract_main_id#
													AND   BSA_Foodservice_Items_Master_ID = '#product_id#'
													AND   Field_Name                      = 'program_fixed_price_cs'
													AND   Deleted = 0
											)
								BEGIN
									INSERT INTO Contract_Product_Margin_Override
												(Contract_Main_ID, BSA_Foodservice_Items_Master_ID, Field_Name, Unit_of_measure, Created_By)
										VALUES	(#form.contract_main_id#, '#product_id#', 'program_fixed_price_cs', 1,'#request.AccessStructure.user_id#')

								UPDATE CPMO
									SET Old_Value   = CAST(PFPPD.Fixed_Price_Value as decimal(12,2))    /* ONLY DIFFERENCE*/
								FROM  Contract_Product_Margin_Override CPMO
								INNER JOIN Contract_Products CP ON
									CP.Contract_Main_Id = CPMO.Contract_Main_ID AND
									CP.BSA_Foodservice_Items_Master_ID = CPMO.BSA_Foodservice_Items_Master_ID
								INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON 
									PFPPD.Contract_Products_ID = CP.Contract_Products_ID
								WHERE 	CPMO.Contract_Main_ID = #form.contract_main_id# AND
										CPMO.Field_Name = 'program_fixed_price_cs' AND
										CPMO.BSA_Foodservice_Items_Master_ID = '#product_id#' AND
										CPMO.Deleted = 0 AND
										CP.Contract_Main_Id = #form.contract_main_id#  AND
										CP.Product_Type_ID = 1 AND
										CAST(PFPPD.Fixed_Price_Value as decimal(12,2)) != 0.0
								END
							</cfquery>
						</cfif>

						<cfif field_name eq 'program_fixed_price_cs' AND marginPercentOverRide EQ 0> <!---  ONLY ONE OVER RIDE ON FIXED --->
							<cfquery name="qUpdateRequestedPrice" datasource="#application.datasource#">
								UPDATE PFPPD
									SET Fixed_Price_Value = cast(cast(#form[ input_name ]# as decimal(12,2)) as varchar(25))
								FROM  Contract_Product_Margin_Override CPMO
								INNER JOIN Contract_Products CP ON
									CP.Contract_Main_Id = CPMO.Contract_Main_ID AND
									CP.BSA_Foodservice_Items_Master_ID = CPMO.BSA_Foodservice_Items_Master_ID
								INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON 
									PFPPD.Contract_Products_ID = CP.Contract_Products_ID
								WHERE 	CPMO.Contract_Main_ID = #form.contract_main_id# AND
										CPMO.Field_Name = 'program_fixed_price_cs' AND
										CPMO.BSA_Foodservice_Items_Master_ID = '#product_id#' AND
										CPMO.Deleted = 0 AND
										CP.Contract_Main_Id = #form.contract_main_id#  AND
										CP.Product_Type_ID = 1 AND
										CAST(PFPPD.Fixed_Price_Value as decimal(12,2)) != 0.0
							</cfquery>
							<!--- If fixed price is updated, re-calc Freight --->
							<cfset runFreight = 1>  <!--- If fixed price is updated, re-calc Freight --->
						</cfif>
					</cfif> <!--- appSettings.get_Setting('Custom_RFP_Process',0) EQ 1 ---> 
				</cfif> <!--- structKeyExists(form, input_name) --->
			</cfloop>
		</cfloop>
		</cfoutput>	
		<cfif runFreight EQ 1 AND appSettings.get_Setting('Custom_RFP_Process',0) EQ 1>
			<cfquery name="SetRFPFreight" datasource="#application.datasource#">
				EXEC Populate_Program_Fixed_Freight_Rates_RFP #form.contract_main_id#
			</cfquery>
		</cfif>
	</cfif>

	<cfparam name="form.next_page_url" default="">

	<cfif form.next_page_url eq "">
		<script>
			window.close();
		</script>
	<cfelse>
		<!--- post to a page due to potential large form elements (e.g. product_group_level_list) --->
		<cfoutput>
			<cfset form.next_page_url = replace(form.next_page_url,"&bReset=0","&bReset=1")>
			<form name="next_page_url" action="#form.next_page_url#" method="post">
				<cfloop collection="#form#" item="variables.item">
					<input type="hidden" name="#variables.item#" value="#form[ variables.item ]#">
				</cfloop>
			</form>
		</cfoutput>
		<script>
			document.next_page_url.submit();
		</script>
	</cfif>
</cfif>
