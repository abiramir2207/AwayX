<!--------------------------------------------------------------------------------------------------------------------------------------------------------
	Component: \components\programs\ContractWhatIF.cfc
	Date:      2014 October
	Author:    Chris Nguyen

	Purposes:  Houses all functions to support program what-if (associated with a program)

	Remarks:

--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfcomponent displayname="Program What IF" output="false">

	<!--------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getWhatIf" access="public" returntype="query" output="false" hint="">
		<cfargument name="contract_main_id" type="numeric" required="true"/>

		<cfquery name="local.result" datasource="#application.datasource#">
			SELECT  wi.*
			       ,u.Name_First
			       ,u.Name_Last
			       ,Changed_Date = ISNULL(wi.Modified_Date, wi.Created_Date)
			  FROM Contract_WhatIf wi
			       INNER JOIN _Users u ON u.User_ID = ISNULL(wi.Modified_By, wi.Created_By)
			 WHERE wi.Deleted = 0
			   AND wi.contract_main_id = #arguments.contract_main_id#
		</cfquery>

		<cfreturn local.result>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getWhatIfProduct" access="public" returntype="query" output="false" hint="">
		<cfargument name="contract_main_id" type="numeric" required="true"/>

		<cfquery name="local.result" datasource="#application.datasource#">
			SELECT	 WhatIf_Product_Id
			        ,Contract_Main_ID
			        ,BSA_FoodService_Items_Master_Id
			        ,Deleted
			        ,ISNULL(User_Volume       , 0) AS User_Volume
			        ,ISNULL(User_List_Price   , 0) AS User_List_Price
			        ,ISNULL(User_Fixed_Price  , 0) AS User_Fixed_Price
			        ,ISNULL(User_Discount     , 0) AS User_Discount
			        ,ISNULL(User_Trade        , 0) AS User_Trade
			        ,ISNULL(User_Pullback     , 0) AS User_Pullback
			        ,ISNULL(User_Raw_Material , 0) AS User_Raw_Material
			        ,ISNULL(User_Packaging    , 0) AS User_Packaging
			        ,ISNULL(User_DVL          , 0) AS User_DVL
			        ,ISNULL(User_Fixed_Cost   , 0) AS User_Fixed_Cost
			        ,ISNULL(User_DNT          , 0) AS User_DNT
			        ,ISNULL(User_Equip_CEMA   , 0) AS User_Equip_CEMA
			        ,ISNULL(User_Freight_FOB  , 0) AS User_Freight_FOB
			        ,ISNULL(User_Warehouse_FOB, 0) AS User_Warehouse_FOB
			        ,ISNULL(User_Comp_Cost    , 0) AS User_Comp_Cost
			        ,ISNULL(User_Rebate       , 0) AS User_Rebate
			        ,ISNULL(User_Growth       , 0) AS User_Growth
			        ,ISNULL(User_Lump_Sum     , 0) AS User_Lump_Sum
			        ,ISNULL(User_Cost         , 0) AS User_Cost
			        ,ISNULL(User_Trade_Cash_Disc       , 0) AS User_Trade_Cash_Disc
			        ,ISNULL(User_Trade_Other_Allowances, 0) AS User_Trade_Other_Allowances
			        ,ISNULL(User_Distributor_Trade     , 0) AS User_Distributor_Trade
			        ,ISNULL(User_Cash_Disc             , 0) AS User_Cash_Disc
			  FROM Contract_WhatIf_Product wi
			 WHERE wi.Deleted = 0
			   AND wi.contract_main_id = #arguments.contract_main_id#
		</cfquery>

		<cfreturn local.result>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="saveWhatIf" access="public" output="true" hint="">
		<cfargument name="contract_main_id" type="numeric" required="true"/>

		<cftransaction>
			<cfscript>
				form.whatif_notes = left(form.whatif_notes, 1000);

				local.cases       = 1;
				local.pounds      = 3;

				local.margin_type = val(form.margin_type);
				// toggle margin type between cases and pounds
				if (form.action eq "switch_uom") {
					local.margin_type = (local.margin_type eq local.cases ? local.pounds : local.cases);
				}
			</cfscript>

			<cfquery name="local.contract_whatif" datasource="#application.datasource#">
			    DECLARE @exist INT = 0
				SELECT @exist = 1
				  FROM CONTRACT_WHATIF
				 WHERE contract_main_id = #arguments.contract_main_id#

				IF ( @exist = 0 )
					BEGIN
						INSERT INTO CONTRACT_WHATIF
								( contract_main_id
								  ,margin_type
								  ,created_by
								  ,notes
								)
						VALUES 	( #arguments.contract_main_id#
								  ,#local.margin_type#
								  ,'#request.AccessStructure.User_ID#'
								  ,'#form.whatif_notes#'
								)
					END
				ELSE
					BEGIN
						UPDATE CONTRACT_WHATIF
						   SET Deleted = 0
						       ,margin_type   = #local.margin_type#
            			       ,Modified_Date = getDate()
            			       ,Modified_By   = '#request.AccessStructure.User_ID#'
            			       ,Notes         = '#form.whatif_notes#'
						 WHERE contract_main_id = #arguments.contract_main_id#
					END
			</cfquery>

			<cfloop from="1" to="#form.product_count#" index="local.counter">
				<cfset local.item = form['prod_id_' & local.counter]>

				<cfquery name="local.insert" datasource="#application.datasource#">
				    DECLARE @exist INT = 0
					SELECT @exist = 1
					  FROM Contract_WhatIF_Product
					 WHERE contract_main_id = #arguments.contract_main_id#
					   AND BSA_Foodservice_Items_Master_ID = <cfoutput>'#local.item#'</cfoutput>

					IF ( @exist = 0 )
						BEGIN
							INSERT INTO Contract_WhatIF_Product
									( contract_main_id
									  ,BSA_Foodservice_Items_Master_ID
									)
							VALUES 	( #arguments.contract_main_id#
									  ,<cfoutput>'#local.item#'</cfoutput>
									)
						END

					SELECT Net_weight
					  FROM BSA_FOODSERVICE_ITEMS_MASTER
					 WHERE BSA_Foodservice_Items_Master_ID = <cfoutput>'#local.item#'</cfoutput>
				</cfquery>

                <cfset local.net_weight = val(local.insert.net_weight)>
                <cfif form.margin_type eq '1'>
                	<cfset local.volume = form[ 'cases_' & local.counter & "_Copy"]>
                <cfelse>
                	<cfset local.volume = form[ 'lbs_' & local.counter & "_Copy"]>
                </cfif>

				<cfparam name="form.list_price_#local.counter#"    default="0">
				<cfparam name="form.fixed_price_#local.counter#"   default="0">
				<cfparam name="form.disc_#local.counter#"          default="0">
				<cfparam name="form.rebate_#local.counter#"        default="0">
				<cfparam name="form.growth_#local.counter#"        default="0">
				<cfparam name="form.lump_sum_#local.counter#"      default="0">
				<cfparam name="form.trade_#local.counter#"         default="0">
				<cfparam name="form.amt_plus_#local.counter#"      default="0">
				<cfparam name="form.raw_material_#local.counter#"  default="0">
				<cfparam name="form.packaging_#local.counter#"     default="0">

				<cfparam name="form.dvl_#local.counter#"           default="0">
				<cfparam name="form.fixed_cost_#local.counter#"    default="0">
				<cfparam name="form.dnt_#local.counter#"           default="0">
				<cfparam name="form.equip_cema_#local.counter#"    default="0">
				<cfparam name="form.Freight_FOB_#local.counter#"   default="0">
				<cfparam name="form.Warehouse_FOB_#local.counter#" default="0">
				<cfparam name="form.comp_cost_#local.counter#"     default="0">

				<cfparam name="form.trade_cash_disc_#local.counter#"        default="0">
				<cfparam name="form.trade_other_allowances_#local.counter#" default="0">
				<cfparam name="form.distributor_trade_#local.counter#"      default="0">

				<cfparam name="form.cash_disc_#local.counter#"              default="0">

				<!--- sanitize input values --->
				<cfscript>
					local.volume         =  whatIFvalue(local.volume);

					local.list_price     =  whatIFvalue(form[ 'list_price_'     & local.counter]);
					local.fixed_price    =  whatIFvalue(form[ 'fixed_price_'    & local.counter]);
					local.rebate         =  whatIFvalue(form[ 'rebate_'         & local.counter]);
					local.growth         =  whatIFvalue(form[ 'growth_'         & local.counter]);
					local.lump_sum       =  whatIFvalue(form[ 'lump_sum_'       & local.counter]);
					local.amt_plus       =  whatIFvalue(form[ 'amt_plus_'       & local.counter]);
					local.raw_material   =  whatIFvalue(form[ 'raw_material_'   & local.counter]);
					local.packaging      =  whatIFvalue(form[ 'packaging_'      & local.counter]);

  	 				local.dvl            =  whatIFvalue(form[ 'dvl_'            & local.counter]);
 	 				local.fixed_cost     =  whatIFvalue(form[ 'fixed_cost_'     & local.counter]);
 	 				local.dnt            =  whatIFvalue(form[ 'dnt_'            & local.counter]);
 	 				local.equip_cema     =  whatIFvalue(form[ 'equip_cema_'     & local.counter]);
 	 				local.Freight_FOB    =  whatIFvalue(form[ 'Freight_FOB_'    & local.counter]);
 	 				local.Warehouse_FOB  =  whatIFvalue(form[ 'Warehouse_FOB_'  & local.counter]);
					local.comp_cost      =  whatIFvalue(form[ 'comp_cost_'      & local.counter]);

					local.trade_cash_disc        =  whatIFvalue(form[ 'trade_cash_disc_'        & local.counter]);
					local.trade_other_allowances =  whatIFvalue(form[ 'trade_other_allowances_' & local.counter]);
					local.distributor_trade      =  whatIFvalue(form[ 'distributor_trade_'      & local.counter]);

					local.cash_disc              =  whatIFvalue(form[ 'cash_disc_'              & local.counter]);
				</cfscript>

				<!--- if margin type is changed do the conversions --->
				<cfif form.action eq "switch_uom">
					<!--- new margin type is CASES --->
					<cfif local.margin_type eq local.cases>
						<cfscript>
							local.volume         =  (local.net_weight eq 0 ? 0 : local.volume / local.net_weight);

							local.list_price     =  (local.list_price    * local.net_weight);
							local.fixed_price    =  (local.fixed_price   * local.net_weight);
							local.rebate         =  (local.rebate        * local.net_weight);
							local.growth         =  (local.growth        * local.net_weight);
							local.lump_sum       =  (local.lump_sum      * local.net_weight);
							local.amt_plus       =  (local.amt_plus      * local.net_weight);
							local.raw_material   =  (local.raw_material  * local.net_weight);
							local.packaging      =  (local.packaging     * local.net_weight);

 	 						local.dvl            =  (local.dvl           * local.net_weight);
	 						local.fixed_cost     =  (local.fixed_cost    * local.net_weight);
	 						local.dnt            =  (local.dnt           * local.net_weight);
	 						local.equip_cema     =  (local.equip_cema    * local.net_weight);
	 						local.Freight_FOB    =  (local.Freight_FOB   * local.net_weight);
	 						local.Warehouse_FOB  =  (local.Warehouse_FOB * local.net_weight);
							local.comp_cost      =  (local.comp_cost     * local.net_weight);

							local.trade_cash_disc        = (local.trade_cash_disc        * local.net_weight);
							local.trade_other_allowances = (local.trade_other_allowances * local.net_weight);
							local.distributor_trade      = (local.distributor_trade      * local.net_weight);

							local.cash_disc              = (local.cash_disc              * local.net_weight);
						</cfscript>

					<!--- new margin type is POUNDS --->
					<cfelseif local.margin_type eq local.pounds>
						<cfscript>
							local.volume         =  (local.net_weight * local.volume);

							local.list_price     =  (local.net_weight eq 0 ? 0 : local.list_price   / local.net_weight);
							local.fixed_price    =  (local.net_weight eq 0 ? 0 : local.fixed_price  / local.net_weight);
							local.rebate         =  (local.net_weight eq 0 ? 0 : local.rebate       / local.net_weight);
							local.growth         =  (local.net_weight eq 0 ? 0 : local.growth       / local.net_weight);
							local.lump_sum       =  (local.net_weight eq 0 ? 0 : local.lump_sum     / local.net_weight);
							local.amt_plus       =  (local.net_weight eq 0 ? 0 : local.amt_plus     / local.net_weight);
							local.raw_material   =  (local.net_weight eq 0 ? 0 : local.raw_material / local.net_weight);
							local.packaging      =  (local.net_weight eq 0 ? 0 : local.packaging    / local.net_weight);

							local.dvl            =  (local.net_weight eq 0 ? 0 : local.dvl           / local.net_weight);
							local.fixed_cost     =  (local.net_weight eq 0 ? 0 : local.fixed_cost    / local.net_weight);
							local.dnt            =  (local.net_weight eq 0 ? 0 : local.dnt           / local.net_weight);
							local.equip_cema     =  (local.net_weight eq 0 ? 0 : local.equip_cema    / local.net_weight);
							local.Freight_FOB    =  (local.net_weight eq 0 ? 0 : local.Freight_FOB   / local.net_weight);
							local.Warehouse_FOB  =  (local.net_weight eq 0 ? 0 : local.Warehouse_FOB / local.net_weight);
							local.comp_cost      =  (local.net_weight eq 0 ? 0 : local.comp_cost     / local.net_weight);

							local.trade_cash_disc        = (local.net_weight eq 0 ? 0 : local.trade_cash_disc        / local.net_weight);
							local.trade_other_allowances = (local.net_weight eq 0 ? 0 : local.trade_other_allowances / local.net_weight);
							local.distributor_trade      = (local.net_weight eq 0 ? 0 : local.distributor_trade      / local.net_weight);

							local.cash_disc              = (local.net_weight eq 0 ? 0 : local.cash_disc              / local.net_weight);
						</cfscript>
					</cfif>
				</cfif>

				<cfquery name="local.save" datasource="#application.datasource#" result="local.result">
					UPDATE Contract_WhatIF_Product
					   SET Deleted = 0
                           ,User_Volume         =  #local.volume#
                           ,User_List_Price     =  #local.list_price#
                           ,User_Pullback       =  #local.amt_plus#
                           ,User_Freight_FOB    =  #local.Freight_FOB#
                           ,User_Warehouse_FOB  =  #local.Warehouse_FOB#

                           <!--- in detail view so update all elements --->
                           <cfif form.page_view eq 'detail'>
	                           ,User_Fixed_Price    =  #local.fixed_price#
	                           ,User_Rebate         =  #local.rebate#
	                           ,User_Growth         =  #local.growth#
	                           ,User_Lump_Sum       =  #local.lump_sum#
	                           ,User_Discount       =  CASE
	                                                     WHEN #local.fixed_price# = 0 THEN #(local.rebate + local.growth + local.lump_sum)#
	                                                     ELSE #((local.list_price - local.fixed_price) + local.rebate + local.growth + local.lump_sum)#
	                                                   END

	                           ,User_Trade_Cash_Disc        = #local.trade_cash_disc#
	                           ,User_trade_other_allowances = #local.trade_other_allowances#
	                           ,User_Distributor_Trade      = #local.distributor_trade#
	                           ,User_Trade                  = #(local.trade_cash_disc + local.trade_other_allowances + local.distributor_trade)#

	                           ,User_Raw_Material   =  #local.raw_material#
	                           ,User_Packaging      =  #local.packaging#
	                           ,User_DVL            =  #local.dvl#
	                           ,User_Fixed_Cost     =  #local.fixed_cost#
	                           ,User_DNT            =  #local.dnt#
	                           ,User_Equip_CEMA     =  #local.equip_cema#
                           	   ,User_Comp_Cost      =  #local.comp_cost#
                           	   ,User_Cost           =  #(local.raw_material + local.packaging + local.dvl + local.fixed_cost + local.dnt + local.equip_cema + local.comp_cost)#
                           	   ,User_Cash_Disc      =  #local.cash_disc#
						   </cfif>
					 WHERE contract_main_id = #arguments.contract_main_id#
					   AND BSA_Foodservice_Items_Master_ID = <cfoutput>'#local.item#'</cfoutput>
				</cfquery>

			</cfloop>
		</cftransaction>

	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="whatIFvalue" access="public" output="true" hint="Strip out dollar sign, commas, html tags, parentheses in a string and convert it into a numeric value">
	    <cfargument name="val" required="true">

	    <cfset local.factor = 1>
	    <cfset arguments.val = application.util.string.stripHTML( arguments.val )>

	    <!--- special handling for negative value with parentheses format --->
	    <cfif arguments.val contains "(">
			<cfset local.factor = -1>
			<!--- remove parentheses --->
			<cfset arguments.val = replace(arguments.val, "(", "", "all")>
			<cfset arguments.val = replace(arguments.val, ")", "", "all")>
		</cfif>

	    <cfset arguments.val = replace(arguments.val, "%", "", "all")>
	    <cfreturn local.factor * val(replace(replace(arguments.val, "$", "", "all"), ",", "", "all"))>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="resetWhatIf" access="public" output="true" hint="">
		<cfargument name="contract_main_id" type="numeric" required="true"/>

		<cfquery name="local.save" datasource="#application.datasource#">
			UPDATE Contract_Whatif
			   SET  Modified_Date = getDate()
			       ,Modified_By   = '#request.AccessStructure.User_ID#'
			       ,Margin_Type   = 1
			 WHERE contract_main_id = #arguments.contract_main_id#

			DELETE Contract_WhatIF_Product
			 WHERE contract_main_id = #arguments.contract_main_id#
		</cfquery>

	</cffunction>

</cfcomponent>