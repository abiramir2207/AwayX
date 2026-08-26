<!------ Formula_Price_Commodity_Summary.cfm ----->
<CFPARAM NAME="URL.Program_ID" 	DEFAULT="">
<CFPARAM NAME="Program_ID" 	DEFAULT="#URL.Program_ID#">

<CFSET SHOW_FORMULA_PRICING_DETAIL_INFO = 0>

<CFPARAM NAME="User_Existing_Query" 	DEFAULT="false">

<CFIF NOT User_Existing_Query>
	<cfquery name="COMM_GetSettings" datasource="#application.datasource#">
		SELECT 	Discount_Formula_Pricing		
		FROM	Contract_Main			
				INNER JOIN Program_Control_Panel_Options
				ON
				Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
		WHERE 
			Contract_Main.Contract_Main_ID = '#Program_ID#'
	</cfquery>
</CFIF>
<CFIF COMM_GetSettings.Discount_Formula_Pricing EQ 1>

<CFIF User_Existing_Query>
	<cfset useLakebaseForgetCommodities = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getrules")>
<cfif useLakebaseForgetCommodities>
	<cftry>
		<cfset getCommodities = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getrules", {
				"select" = "rule_name,formula_pricing_rule_id"
			}), "rule_name,formula_pricing_rule_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCommodities = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCommodities>
<CFQUERY NAME="getCommodities" dbtype="query">
		SELECT     	DISTINCT Rule_Name, Formula_Pricing_Rule_ID
		FROM        getRules
	</CFQUERY>
</cfif>
<CFELSE>
	<CFQUERY NAME="getCommodities" datasource="#application.datasource#">
		SELECT     	DISTINCT 
					Formula_Pricing_Rule.Rule_Name, 		           	
		           	Formula_Pricing_Rule.Formula_Pricing_Rule_ID, 				   	
					Formula_Pricing_Rule.Show_Details
		FROM        dbo.BSA_Foodservice_Items_Master 
					INNER JOIN	dbo.Contract_Products 
					ON dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = dbo.Contract_Products.BSA_Foodservice_Items_Master_ID 
					INNER JOIN dbo.Program_Formula_Pricing_Rule_Products 
					ON dbo.Contract_Products.Contract_Products_ID = dbo.Program_Formula_Pricing_Rule_Products.Contract_Product_ID
					INNER JOIN Program_Formula_Pricing_Rule_Mapped
					ON
					Program_Formula_Pricing_Rule_Mapped.Program_Formula_Pricing_Rule_Mapped_ID = dbo.Program_Formula_Pricing_Rule_Products.Program_Formula_Pricing_Rule_ID
					AND
					Program_Formula_Pricing_Rule_Mapped.Deleted = 0
					LEFT JOIN Formula_Pricing_Rule
					ON
					Formula_Pricing_Rule.Formula_Pricing_Rule_ID = Program_Formula_Pricing_Rule_Mapped.Formula_Pricing_Rule_ID
					AND
					Formula_Pricing_Rule.Deleted = 0
		WHERE     
					(dbo.Contract_Products.Deleted = 0) 
					AND (dbo.Contract_Products.Contract_Main_ID = #Program_ID#) 
					AND (dbo.Program_Formula_Pricing_Rule_Products.Deleted = 0)
	</CFQUERY>
</CFIF>

	<cfif getCommodities.recordcount GT 0>	
		<CFIF NOT User_Existing_Query>	
			<CFSET getInfoForProgramID 	= Program_ID>
			<CFSET getInfoForPeriod 	= "any">
			<CFINCLUDE TEMPLATE="program_pricing_period_information.cfm"> 
		</CFIF>
	<TABLE CELLSPACING="0" CELLPADDING="2" BORDER="0" WIDTH="90%">
		<TR>
		<CFPARAM NAME="HOW_MANY_COMMS" 	DEFAULT="0">		
		<TD COLSPAN="100%" VALIGN="TOP">			
			<CFIF getCommodities.recordcount GT 0>				
				<CFLOOP QUERY="getCommodities">
					<CFIF User_Existing_Query>
						<cfset useLakebaseForGet_Show_Details = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getrules")>
<cfif useLakebaseForGet_Show_Details>
	<cftry>
		<cfset Get_Show_Details = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getrules", {
				"formula_pricing_rule_id" = "eq.#getCommodities.Formula_Pricing_Rule_ID#",
				"select" = "show_details"
			}), "show_details"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Show_Details = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Show_Details>
<CFQUERY NAME="Get_Show_Details" dbtype="query">
							SELECT	Show_Details
							FROM	getRules
							WHERE
									Formula_Pricing_Rule_ID = '#getCommodities.Formula_Pricing_Rule_ID#'
						</CFQUERY>
</cfif>
						<CFSET show_Details = Get_Show_Details.show_Details>
					<CFELSE>
						<CFSET show_Details = getCommodities.show_Details>
					</CFIF>
					<CFIF show_Details>
					<!------<CFIF 1 EQ 1>----->
							<CFSET THIS_PRODUCT_FORMULA_PRICING_RULA_NAME = getCommodities.Rule_Name>
							<CFSET release_Date = periods.Requested_Period_Info.Release_Date>
							<CFSET THIS_PRODUCT_FORMULA_PRICING_RULE_ID = Formula_Pricing_Rule_ID>
							<CFQUERY datasource="#application.datasource#" NAME="Commodity_Data">
								SELECT			fc.Program_Formula_Pricing_Rule_Comm_Data_ID, fc.Program_Formula_Pricing_Rule_ID, fc.Symbol, fc.Point_In_Time, fc.Point_In_Time_UOM, fc.Sample_Size, fc.Sample_Size_UOM, fc.Weight
												,cs.Symbol_Description, cex.Exchange_Detail_Name
								FROM
												Program_Formula_Pricing_Rule_Comm_Data fc,
												Commodities_Symbol cs,
												Commodities_Exchange_Detail cex
								WHERE
												Program_Formula_Pricing_Rule_ID 	= '#THIS_PRODUCT_FORMULA_PRICING_RULE_ID#'
										AND		fc.Deleted	=	0
										AND		fc.Active	=	1
										AND		cs.Symbol = fc.Symbol
										AND		cex.Exchange_Detail_ID = fc.Exchange
							</CFQUERY>
							<CFINCLUDE template="Formula_Price_Display_Commodity_Data.cfm">
					</CFIF>
					
				</CFLOOP>
				
			</CFIF>
			
		</TD>
	</TR>
	</TABLE>
	</CFIF>
</CFIF>