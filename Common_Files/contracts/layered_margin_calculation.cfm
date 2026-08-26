<cfparam name="url.verticalPNL" default="">
<cfparam name="url.rerunMargin" default="0">
<cfparam name="url.UoT" default="0">

<cfset request.content = []>
<cfif url.verticalPNL eq "">         <!---  44017  --->
    <cfsavecontent variable="subcontent">
        <cf_include files="/script/javascript/prototype/prototype.js, /script/javascript/prototype/scriptaculous.js">
    </cfsavecontent>
    <cfset request.content.append( subcontent )>
</cfif>

<cfparam name="url.bFromPlanner" default="0">

<CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">
<cfsilent>
	<!---
		FILE:
		FILENAME: 	Common_Files/contracts/layered_margin_calculation.cfm
		CREATED: 	??/??/???? - ???
		EDITED:		09/25/2008 - RBL [D16314: Margin Analysis - Add Contract Price]
		FUNCTIONALITY:
		- ...
		--->
	<!--- These parameters are required for this template to process correctly --->
	<!--- na --->
</cfsilent>
<CFSET contract_main_id = cryp.value />
<cfset margin_display_style = application.util.query.get_Setting("margin_display_style")>

<!---76388 Ability for user to re-run margin for a program START--->
<cfif listFirst(url.reRunMargin)>
	<cfset useLakebaseForQreRunMargin = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_margin_log_status")>
	<cfif useLakebaseForQreRunMargin>
		<cftry>
			<cfset application.oLakebase.deleteRows("program_margin_log_status", { "program_id" = "eq.#contract_main_id#" })>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForQreRunMargin = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForQreRunMargin>
	<CFQUERY NAME="qreRunMargin" datasource="#application.datasource#">
		DELETE FROM Program_Margin_Log_Status WHERE Program_id = #contract_main_id#
	</CFQUERY>
	</cfif>
</cfif>
<!---76388 Ability for user to re-run margin for a program END--->
<cfset ViewProgramManager = CreateObject("component", "components.programs.Display_Program.viewprogramtemplateManager") />

<!------ Initialise ----->
<CFINCLUDE TEMPLATE="/Get_Access_Profile.cfm">
<!--- Currently, we are showing the real progress bar only for layered margin, and not for standard margin --->

<cfif url.verticalPNL eq "">         <!---  44017  --->
    <cfsavecontent variable="subcontent">
        <cfif Get_Profile_Settings.program_margin_approval_method IS 5 OR Get_Profile_Settings.program_margin_approval_method IS 7>
            <!--- <CFINCLUDE TEMPLATE="/includes/progress_bar.cfm"> --->
        <cfelse>
            <!----------------- Add Spinner ------------------------>
            <SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
                <br>
                <br>
                <br>
                <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
                <br>
                <br>
                <br>
            </SPAN>
            <SCRIPT>document.all.PleaseWaitMessage.style.display='none';</SCRIPT>
            <!----------------- Add Spinner ------------------------>
        </cfif>
    </cfsavecontent>
    <cfset request.content.append( subcontent )>
</cfif>

<cfparam name="MarginRequestAction" default="">
<cfset thread = createObject("java", "java.lang.Thread") />
<!--- Call the required component for AJAX Calls --->
<cfset ProgramMarginLog = CreateObject("component","components.programs.MarginLog") />
<cfset NewMargin = 0 />
<!--- Currently, the real progress bar exists only for layered margin, and not for standard margin.
	We need to remove this condition, when the real progress bar is required for standard margin also --->

<cfif Get_Profile_Settings.program_margin_approval_method IS 5 OR Get_Profile_Settings.program_margin_approval_method IS 7>
	<cftransaction>
		<cflock timeout="2" type="exclusive">
			<cfset Pre_MarginLogInfo = ProgramMarginLog.getMarginLogInfo(trim(contract_main_id)) />

			<cfif Pre_MarginLogInfo[7] neq 0>
				<cfset MarginRequestAction = "RefreshMargin" />
			</cfif>

			<!--- If the margin routine did not complete in 10 minutes, Delete the margin log tables
				(In this case status is still 1 (Processing). Status of 2 means "Processed". --->

			<cfif Pre_MarginLogInfo[3] eq 1 AND Pre_MarginLogInfo[8] GT 10>
				<cfset ProgramMarginLog.DeleteMarginLogInfo(trim(contract_main_id)) />
				<cfset ProgramMarginLog.DeleteMarginLogStatusInfo(trim(contract_main_id)) />
			</cfif>

			<cfset Pre_MarginLogInfo = ProgramMarginLog.getMarginLogInfo(trim(contract_main_id)) />
			<!--- If there is no entry in the log table for the program OR the program's margin is requested for the first time
				during the day OR the Margin Process is complete - (provided the program is still not approved)
				--->

			<cfif Pre_MarginLogInfo[4] eq 0 OR MarginRequestAction eq "RefreshMargin"
				OR (Pre_MarginLogInfo[9] LT 3 AND Pre_MarginLogInfo[3] eq 2)>
				<cfset NewMargin = 1 />
			</cfif>

			<cfif NewMargin eq 1>
				<cfset ProgramMarginLog.DeleteMarginLogInfo(trim(contract_main_id)) />
				<cfset ProgramMarginLog.DeleteMarginLogStatusInfo(trim(contract_main_id)) />
				<cfset ProgramMarginLog.setMarginLogInfo(trim(contract_main_id)) />
				<cfset ProgramMarginLog.setMarginLogStatusInfo(trim(contract_main_id),request.AccessStructure.User_ID,'1',url.UoT) />
			</cfif>

		</cflock>
	</cftransaction>

	<cfset Post_MarginLogInfo = ProgramMarginLog.getMarginLogInfo(trim(contract_main_id))>

    <cfif url.verticalPNL eq "">         <!---  44017  --->
        <cfsavecontent variable="subcontent">
            <script language="javascript">
                <cfif NewMargin eq 1>
                    document.getElementById('Display_Message').innerHTML = 'Calculating Margin';
                <cfelse>
                    document.getElementById('Display_Message').innerHTML = 'Retrieving Margin';
                </cfif>
            </script>

            <script type='text/javascript'>_ajaxConfig = {'_cfscriptLocation':'/components/programs/MarginLog.cfc', '_jsscriptFolder':'/Script/javascript/Ajax_JS','debug':false};</script>
            <cf_include files="/Script/javascript/Ajax_JS/ajax.js">

            <script language=javascript>
                var int=self.setInterval("clock()",2000)
                function clock()
                {
                    //DWREngine._errorHandler =  errorHandler;
                    DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'getAJAXMarginLogInfo', <cfoutput>'#trim(contract_main_id)#'</cfoutput>,ShowStatus);
                }

                function ShowStatus(ReturnValue)
                {
                    var LastPercent = 0;
                    // This will return values of 1 through 10 (1 being 10%, 2 being 20%....10 being 100%)
                    var PercentDone = Math.floor(Math.ceil((ReturnValue[0]/ReturnValue[1]) * 100)/10);

                    var Status = ReturnValue[2];
                    //Show the Image based on product coun
                    if(LastPercent != PercentDone){
                        var Block = "Block" + PercentDone;

                        if(PercentDone <= 9){
                            if('document.'+ Block){
                                for (var i=1;i<=PercentDone;i++){
                                    Block = "Block" + i;
                                    document.getElementsByName(Block)[0].src =  '/images/red_block.gif';
                                }
                            }
                        }
                        //Show the progress in percent
                        if(document.getElementById('ShowPercentProgress')){
                            var PercentDone = PercentDone+'0';
                            if(PercentDone <= 90){
                                document.getElementById('ShowPercentProgress').innerHTML = PercentDone+'%';
                            }
                            if(Status == 2){
                                for (var i=1;i<=10;i++){
                                    Block = "Block" + i;
                                    document.getElementsByName(Block)[0].src =  '/images/red_block.gif';
                                }
                                document.getElementById('ShowPercentProgress').innerHTML = '100%';
                            }
                        }
                    LastPercent = PercentDone;
                    }
                }
                //Do Nothing. This function is just a placeholder for AJAX.
                function PlaceHolderFunction()
                {
                    return void(0);
                }
            </script>
		    <!--- <cfflush>     --->
        </cfsavecontent>
        <cfset request.content.append( subcontent )>
    </cfif>   <!--- url.verticalPNL neq "1"> --->
</cfif>

<!--- call the margin routine only when NewMargin is 1. --->

<cfif url.UoT>

	<cfif isDefined('url.NewMarginUoT')>
		<cfset NewMargin = 1>

				<cfset ProgramMarginLog.DeleteMarginLogInfo(trim(contract_main_id)) />
				<cfset ProgramMarginLog.DeleteMarginLogStatusInfo(trim(contract_main_id)) />
				<cfset ProgramMarginLog.setMarginLogInfo(trim(contract_main_id)) />
				<cfset ProgramMarginLog.setMarginLogStatusInfo(trim(contract_main_id),request.AccessStructure.User_ID,'1', url.UoT) />

	</cfif>
	<cfif isDefined('url.margin_type')>
		<cfset form.margin_type = url.margin_type>
	</cfif>
<cfelse>
	<cfset useLakebaseForGet_Settings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_settings")>
<cfif useLakebaseForGet_Settings>
	<cftry>
		<cfset Get_Settings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users_settings", {
				"user_id" = "eq.#request.AccessStructure.Company_Main_ID#",
				"select" = "margin_uot_id"
			}), "margin_uot_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Settings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Settings>
<CFQUERY NAME="Get_Settings" datasource="#application.datasource#">
		Select		Margin_UOT_ID
		From		_Users_Settings
		Where		User_ID		=		'#request.AccessStructure.Company_Main_ID#'
	</CFQUERY>
</cfif>
	<cfset url.UoT = Get_Settings.Margin_UOT_ID>
</cfif>

<cfset PreMarginLogInfo = ProgramMarginLog.getMarginLogInfo(trim(contract_main_id)) />
<cfif arraylen(PreMarginLogInfo) AND url.UoT NEQ PreMarginLogInfo[10]>
	<cfset NewMargin = 1>
	<cfset ProgramMarginLog.DeleteMarginLogInfo(trim(contract_main_id)) />
	<cfset ProgramMarginLog.DeleteMarginLogStatusInfo(trim(contract_main_id)) />
	<cfset ProgramMarginLog.setMarginLogInfo(trim(contract_main_id)) />
	<cfset ProgramMarginLog.setMarginLogStatusInfo(trim(contract_main_id),request.AccessStructure.User_ID,'1', url.UoT) />
</cfif>

<cfscript>
	bCalculate = 1;
	bRunFreight = 0;
	if(margin_display_style == 'custom_h' && NewMargin == 1){
		//if the contract is already approved, don't re-calc margin For "Custom RFP" logic. Post_MarginLogInfo[9] = Contract_Status_Type_IDX
		bCalculate = Post_MarginLogInfo[9] > 2 ? 0 : 1;
	}
</cfscript>

<cfif NewMargin eq 1 OR bCalculate eq 0>

	<cfif Get_Profile_Settings.program_margin_approval_method IS 5>
		<cftry>
			<cfscript>/* USED IN CFSTOREDPROC */
				spName = 'GET_PROFIT_MARGIN_LAYERED';
				if(margin_display_style == 'custom_h'){
					spName = 'GET_PROFIT_MARGIN_LAYERED';	/* GET_PROFIT_MARGIN_LAYERED_Custom_H  :: SAME AS ORIGINAL -> Legacy : leave for now in case we need to isolate this code*/
				}
			</cfscript>
			<cfset GetSettings = CreateObject("component", "components.programs.template.TemplateManager").getProgramTemplate(contract_main_id) />
			<cfif margin_display_style EQ 'custom_h' AND GetSettings.RFP_Process EQ 1>
				<!--- Check for freight data --->
				<cfquery name="qgetFreightCount" datasource="#application.datasource#">
					   SELECT count(PFFR.program_fixed_freight_id) AS Freight_Count
					   FROM Program_Fixed_Freight_Rates PFFR
					   WHERE 	PFFR.Program_Id = #contract_main_id# AND
								PFFR.Deleted = 0
				</cfquery>

				<cfquery name="qgetCustItemCount" datasource="#application.datasource#">
					SELECT Count(CP.Contract_Products_Id) AS Cust_Item_Count
					FROM Contract_Products CP
					INNER JOIN Contract_Distributors CD ON
						CD.Contract_Main_ID = #contract_main_id#
					INNER JOIN Program_Fixed_Freight_Rates PFFR ON
						PFFR.Customer_id = CD.BSA_Foodservice_Customers_ID AND
						PFFR.Product_id = CP.BSA_Foodservice_Items_Master_ID AND
						PFFR.Program_id = #contract_main_id#
					WHERE CP.Contract_Main_ID = #contract_main_id# AND
							CP.Deleted = 0 AND
							CD.Deleted = 0 AND
							PFFR.Deleted = 0 AND
							CP.Product_Type_ID = 1
				</cfquery>

				<CFIF qgetCustItemCount.Cust_Item_Count NEQ qgetFreightCount.Freight_Count>	<!--- IF THEY DON't match, re-calc Freight --->
					<cfquery name="SetRFPFreight" datasource="#application.datasource#">
						EXEC Populate_Program_Fixed_Freight_Rates_RFP #contract_main_id#
					</cfquery>
				</CFIF>

			</cfif>

			<CFQUERY NAME="DeleteTempTables" DATASOURCE="#application.datasource#">
				IF object_id('tempdb..##PRODUCT_TRADE_MARGIN_DIST') is not null
				DROP TABLE ##PRODUCT_TRADE_MARGIN_DIST

				IF object_id('tempdb..##PRODUCT_TRADE_MARGIN_OPERATOR') is not null
				DROP TABLE ##PRODUCT_TRADE_MARGIN_OPERATOR
			</CFQUERY>

			<CFSTOREDPROC PROCEDURE="#spName#" datasource="#application.datasource#">
				<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_INTEGER" VARIABLE="CA_ID" VALUE="#trim(contract_main_id)#" NULL="No">
				<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_INTEGER" VARIABLE="@margin_uot" VALUE="#trim(UoT)#" NULL="No">
			</CFSTOREDPROC>
			<!--- if CM % Over Ride Field in Contract_Product_Margin_Override has data we need to update the Fixed_Price_Value (requested Price/CS)--->
			<cfif margin_display_style eq 'custom_h'>
				<cfquery name="qgetMarginOverRide" datasource="#application.datasource#">
					SELECT Contract_Product_Margin_Override_Id,
							New_Value,
							BSA_Foodservice_Items_Master_ID
					FROM Contract_Product_Margin_Override
					WHERE Contract_Main_ID = #contract_main_id#
						AND Field_Name =  'variable_contribution_margin_cs'	<!--- THIS IS the CM % Over Ride Field in Contract_Product_Margin_Override--->
						AND Deleted = 0
				</cfquery>
				<!---
						If there is an over ride for CM % we need to update the Requested Price/CS
							Contract_Product_Margin.Program_Fixed_Price_CS
							Program_Fixed_Price_Product_Data.Fixed_Price_Value
				--->
				<cfoutput query="qgetMarginOverRide">
                    <cfset useLakebaseForqgetConProdMarg = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_product_margin")>
<cfif useLakebaseForqgetConProdMarg>
	<cftry>
		<cfset qgetConProdMarg = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_product_margin", {
				"contract_main_id" = "eq.#contract_main_id#",
				"product_id" = "eq.#qgetMarginOverRide.BSA_Foodservice_Items_Master_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetConProdMarg = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetConProdMarg>
<cfquery name="qgetConProdMarg" datasource="#application.datasource#">
                        SELECT *
                        FROM Contract_Product_Margin
                        WHERE Contract_Main_ID = #contract_main_id# AND
                            Product_Id =  '#qgetMarginOverRide.BSA_Foodservice_Items_Master_ID#'
                    </cfquery>
</cfif>
					<cfif isNumeric(qgetMarginOverRide.New_Value) and qgetConProdMarg.recordCount>
						<cfset bRunFreight = 1 >   <!--- CM% OverRide will update the fixed price so we need to run the freight routine after fixed price is updated --->

						<cfscript>
							/* calc 	CM% = (net_sales_cs - Cost_CS)/net_sales_cs
										net_sales_Cs = Program_Fixed_Price_CS - Cash_Discount_CS - 	Allowance_Surcharges_CS - Other_Spend_CS - TPA_CS
												net = requested_price_cs - Csh_Disc - other_allowances - Redi - TPA
												Cost_Predicted_Adjustment_CS = Csh_Disc + other_allowances + Redi + TPA

								net_sales = Cost_CS/cm%	(qgetMarginOverRide.new_value/100)

								Cash_discount_CS = Program_Fixed_Price_CS * @Terms :: [Cash_discount_STAT holds this value from bsa_foodsertvice_customers]
								Cash_discount_STAT -> holds the @Terms which is used to calculate Cash_discount_CS
							*/
							if(qgetMarginOverRide.new_value == 100){
								netSales = qgetConProdMarg.Cost_CS;
							}
							else{
								netSales 				= qgetConProdMarg.Cost_CS/ (1 - (qgetMarginOverRide.new_value/100));
							}
							terms 					= qgetConProdMarg.Cash_discount_STAT;
							fixedProdCost 			= qgetConProdMarg.Allowance_Surcharges_CS + qgetConProdMarg.Other_Spend_CS + qgetConProdMarg.TPA_CS;  /* No Cash_Discout which = terms * Requested price */
							requestedPrice 			= (netSales + fixedProdCost)/ (1 - terms);
							cashDisc 				= requestedPrice * terms;
							// cashDisc 				= requestedPrice - netSales fixedProdCost;
							productId 				= qgetMarginOverRide.BSA_Foodservice_Items_Master_ID;
							currentFixedPriceValue 	= qgetConProdMarg.Program_Fixed_Price_CS;

							prodCost 				= fixedProdCost + cashDisc;
							OprMarginPercent 		= netSales == 0 ? 0.00 : ((netSales - qgetConProdMarg.Cost_CS - qgetConProdMarg.SGA_CS) / netSales) * 100;
							// writedump(var='#netSales# :: #requestedPrice#  :: #prodCost#  :: #cashDisc#  :: #fixedProdCost#', output='c:\dump.log');
						</cfscript>
						<!--- INSERT OverRide Value For Fixed_Price_Value.
										This is used when the CM% override is removed we need to reset the
										Fixed_Price_Value back to original value in verticalpnl_action.cfm
						--->
						<cfquery name="qUpdateCPMO" datasource="#application.datasource#">
							IF NOT EXISTS(
											SELECT *
											FROM Contract_Product_Margin_Override
											WHERE Contract_Main_ID                = #contract_main_id#
												AND   BSA_Foodservice_Items_Master_ID = '#productId#'
												AND   Field_Name                      = 'program_fixed_price_cs'
												AND   Deleted = 0
										)
								BEGIN
								INSERT INTO Contract_Product_Margin_Override
											(Contract_Main_ID, BSA_Foodservice_Items_Master_ID, Field_Name, Unit_of_measure)
									VALUES	(#contract_main_id#, '#productId#', 'program_fixed_price_cs', 1)
								END

							UPDATE Contract_Product_Margin_Override
								SET  New_Value        = cast(#requestedPrice# as decimal(12,2))
									, Created_By       = '#request.AccessStructure.user_id#'
									, Unit_of_measure  = 1
							  WHERE   Contract_Main_ID                = #contract_main_id#
								AND   BSA_Foodservice_Items_Master_ID = '#productId#'
								AND   Field_Name                      = 'program_fixed_price_cs'
								AND   Deleted = 0
								AND   New_Value  != cast(#requestedPrice# as decimal(12,2))
						</cfquery>

						<cfquery name="qUpdContProdMarg" datasource="#application.datasource#">
							Update Contract_Product_Margin
								SET Program_Fixed_Price_CS = cast(#requestedPrice# as decimal(12,2)),
									Variable_Contribution_Margin_CS = #qgetMarginOverRide.new_value#,	<!--- CM % OverRide--->
									Net_Sales_Cs = #netSales#,
									Contribution_Margin_Alt_CS = #netSales# - Cost_CS,
									Cost_Predicted_Adjustment_CS = #prodCost#,
									Cash_Discount_CS = #cashDisc#,
									Operating_Income_CS = (#netSales# - Cost_CS) - SGA_CS,
									OperatingMargin_percent = #OprMarginPercent#
							WHERE Contract_Main_ID = #contract_main_id# AND
									Product_Id =  '#productId#'
						</cfquery>

						<cfquery name="qUpdPrgFixedPrVal" datasource="#application.datasource#">
							UPDATE PFPPD
								SET Fixed_Price_Value = cast(cast(#requestedPrice# as decimal(12,2)) as varchar(25))
							FROM  Contract_Product_Margin_Override CPMO
							INNER JOIN Contract_Products CP ON
								CP.BSA_Foodservice_Items_Master_ID = CPMO.BSA_Foodservice_Items_Master_ID AND
								CP.Contract_Main_ID = CPMO.Contract_Main_ID
							INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON
								PFPPD.Contract_Products_ID = CP.Contract_Products_ID
							WHERE 	CPMO.Contract_Main_ID = #contract_main_id# AND
									CPMO.BSA_Foodservice_Items_Master_ID = '#productId#' AND
									CPMO.Field_Name = 'program_fixed_price_cs' AND
									CPMO.Deleted = 0 AND
									CP.Product_Type_ID = 1 AND
									cast(PFPPD.Fixed_Price_Value as decimal(12,2)) != 0.0
						</cfquery>
					</cfif>
				</cfoutput>

				<cfif bRunFreight EQ 1 AND application.appSettingsGet.get_Setting('Custom_RFP_Process',0) EQ 1>   <!--- CM% OverRide will update the fixed price so we need to run the freight routine after fixed price is updated --->
					<cfquery name="SetRFPFreight" datasource="#application.datasource#">
						EXEC Populate_Program_Fixed_Freight_Rates_RFP #contract_main_id#
					</cfquery>
				</cfif>

			</cfif>	<!---	margin_display_style eq 'custom_h'  --->
			<cfcatch>
				<cfset ProgramMarginLog.DeleteMarginLogInfo(trim('#contract_main_id#')) />
				<cfset ProgramMarginLog.DeleteMarginLogStatusInfo(trim('#contract_main_id#')) />
				<cfrethrow />
			</cfcatch>
		</cftry>
	<cfelseif Get_Profile_Settings.program_margin_approval_method IS 7>
		<CFSTOREDPROC PROCEDURE="STANDARD_MARGIN" datasource="#application.datasource#">
			<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_INTEGER" VARIABLE="CA_ID" VALUE="#trim(contract_main_id)#" NULL="No">
			<CFPROCPARAM TYPE="In" CFSQLTYPE="NVARCHAR" VARIABLE="USER_ID" VALUE="#trim(request.AccessStructure.user_id)#" NULL="No">
		</CFSTOREDPROC>
	</cfif>


	<cfif Get_Profile_Settings.program_margin_approval_method IS 5 OR Get_Profile_Settings.program_margin_approval_method IS 7>
		<cfset ProgramMarginLog.UpdateMarginLogStatusInfo(trim(contract_main_id),'2') />
	</cfif>

<cfelse>
	<!--- When the margin is still running and the user who executed the margin closes the window and opens
		the margin window again, We do not need to run margin again. We just check whether
		the margin has been completed or not. If yes, show it, else wait for it to be completed.
		This also goes for any other user who wants to view the margin already being calculated.
		--->

	<cfif NewMargin eq 0 AND Post_MarginLogInfo[3] EQ 1 AND (Get_Profile_Settings.program_margin_approval_method IS 5 OR Get_Profile_Settings.program_margin_approval_method IS 7)>
		<cfset MarginStatus = 1 />
		<cfloop condition="MarginStatus neq 2">
			<cfset thread.sleep(2000) />
			<cfset CheckMarginLogInfo = ProgramMarginLog.getMarginLogInfo(trim(contract_main_id)) />
			<cfset MarginStatus = CheckMarginLogInfo[3] />
		</cfloop>
	</cfif>

</cfif>

<cfif url.verticalPNL eq "">         <!---  44017  --->
    <cfif Get_Profile_Settings.program_margin_approval_method IS 5 OR Get_Profile_Settings.program_margin_approval_method IS 7>
        <cfsavecontent variable="subcontent">
            <script language="javascript">
                int=window.clearInterval(int);
                document.getElementById('ShowPercentProgress').innerHTML = '';
                for (var i=1;i<=10;i++){
                                Block = "Block" + i;
                                document.getElementsByName(Block)[0].src =  '';
                            }
                document.getElementById('Display_Message').innerHTML = 'Loading Page';
            </script>
        </cfsavecontent>
        <cfset request.content.append( subcontent )>
	</cfif>
</cfif>

<cfsavecontent variable="css_loader">
	<cf_include files=#arrayToList(["/styles/css-loader.css"])#>
</cfsavecontent>
<cfhtmlhead text="#css_loader#"></cfhtmlhead>

<cfif application.util.query.get_Setting("margin_display_style", 0) is "custom_h">
    <cfinclude template="layered_approval_include_hm.cfm">
<cfelse>
    <cfinclude template="layered_approval_include.cfm">
</cfif>
