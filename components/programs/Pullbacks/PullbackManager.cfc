<cfcomponent>
<!--- Get all the list of distributors FROM the current Opr or Local Dis program to apply pullbacks, if pullbacks are already applied, check pullback_details table to get the pullback values --->
	<cffunction name="GetDistributorlist" output="false">
		<cfargument name="program_id" required="true" type="numeric" />
		<cfargument name="applied_pullbacks" required="true" type="numeric" />
		<cfargument name="sql_Sort_By" required="false" type="string" default="name"/>
		<cfargument name="Sort_order" required="false" type="string" default="desc"/>
		<cfquery name="qGetDistributorlist" datasource="#application.datasource#">
			SELECT distinct contract_distributors.BSA_Foodservice_Customers_id, name,shr_ship_to,
			ISNULL(Pullback_Level,'D') AS Pullback_Level,
			ISNULL(pullback_default_value,0) AS pullback_default_value
			,ISNULL(max(ISNULL(pullback_value,0)),0) AS pullback_value,
			SUM(ISNULL(pullback_details.pullback,0)) AS pullback,
			Pullbacks_Distributors_Defaults.pullback AS pullback_default,
			pullback_details.customer_id AS pullback_details_customer_id
			FROM contract_distributors
			INNER JOIN BSA_Foodservice_Customers on
			BSA_Foodservice_Customers.BSA_Foodservice_Customers_id =
			contract_distributors.BSA_Foodservice_Customers_id
			LEFT JOIN pullback_details ON
			pullback_details.customer_id = BSA_Foodservice_Customers.BSA_Foodservice_Customers_id
			AND pullback_details.opr_program_id = contract_distributors.contract_main_id
			AND pullback_details.deleted = 0
			LEFT JOIN Pullbacks_Levels on
			Pullbacks_Levels.Pullback_Program_Id =  <cfqueryparam value="#arguments.program_Id#" cfsqltype="CF_SQL_INTEGER" />
			AND Pullbacks_Levels.customer_id = contract_distributors.BSA_Foodservice_Customers_id
			LEFT JOIN Pullbacks_Distributors_Defaults on
			Pullbacks_Distributors_Defaults.Pullback_Program_Id =  <cfqueryparam value="#arguments.program_Id#" cfsqltype="CF_SQL_INTEGER" />
			AND Pullbacks_Distributors_Defaults.customer_id = contract_distributors.BSA_Foodservice_Customers_id
			WHERE contract_distributors.deleted = 0
			AND contract_main_id = <cfqueryparam value="#arguments.program_Id#" cfsqltype="CF_SQL_INTEGER" />
			group by contract_distributors.BSA_Foodservice_Customers_id, pullback_details.customer_id,
			name,shr_ship_to,Pullback_Level,ISNULL(pullback_default_value,0),
			Pullbacks_Distributors_Defaults.pullback
			order by #arguments.sql_Sort_By# #arguments.Sort_order#
		</cfquery>
		<cfreturn qGetDistributorlist />
	</cffunction>

<!--- 	Get all the available products ON the Opr or Local Dis program ON which the pullbacks are being created --->
	<cffunction name="GetProductlist" output="false">
		<cfargument name="program_id" required="true" type="numeric" />
		<cfquery name="qGetProductlist" datasource="#application.datasource#">
			SELECT distinct contract_products.BSA_Foodservice_items_master_id
			FROM contract_products
			WHERE contract_products.deleted = 0  AND is_Group = 0
			AND contract_main_id = <cfqueryparam value="#arguments.program_Id#" cfsqltype="CF_SQL_INTEGER" />
		</cfquery>
		<cfreturn qGetProductlist />
	</cffunction>

	<cffunction name="GetProductGroup" output="false" returntype="numeric">
		<cfargument name="program_id" required="true" type="numeric" />
		<cfset var retValue = 0 />
		<cfquery name="qGetProductGroupCount" datasource="#application.datasource#">
			SELECT Count(contract_products.contract_products_id) AS TheCount
			FROM contract_products
			WHERE contract_products.deleted = 0  AND is_Group = 1
			AND contract_main_id = <cfqueryparam value="#arguments.program_Id#" cfsqltype="CF_SQL_INTEGER" />
		</cfquery>
		<cfif qGetProductGroupCount.TheCount GT 0>
			<cfset retValue = 1 />
		</cfif>
		<cfreturn retValue />
	</cffunction>

<!--- get the pullback values for all the products  in the current Opr or Local Dis Program --->
	<cffunction name="GetCurrentProductlist" output="false">
		<cfargument name="program_id" required="true" type="numeric" />
		<cfargument name="applied_pullbacks" required="true" type="numeric" />
		<cfargument name="distributor_id" required="false" type="string" />
		<cfargument name="customer_program_id" required="false" type="numeric" />
		<cfargument name="sql_Sort_By" required="false" type="string" default="item"/>
		<cfargument name="Sort_order" required="false" type="string" default="desc"/>

		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBB_Count_Indicator() eq "Operator">
			<cfset Paid_To_Flag = 2 />
		<cfelse>
			<cfset Paid_To_Flag = 1 />
		</cfif>
		<cfquery name="qGetCurrentProductlist" datasource="#application.datasource#">
			SELECT DISTINCT
				CP.BSA_Foodservice_items_master_id,
				Item,
				Description,
				MAX(ISNULL(Pullback_Value,100)) AS Pullback_Value,
				ISNULL(Pullback,100) AS Pullback
			FROM Contract_Products CP
			INNER JOIN BSA_Foodservice_Items_Master I ON
				CP.BSA_Foodservice_items_master_id = I.BSA_Foodservice_items_master_id
			LEFT JOIN pullback_details PD ON
				PD.product_id = I.BSA_Foodservice_Items_Master_id AND
				PD.opr_program_id = CP.contract_main_id AND
				PD.customer_id = '#arguments.distributor_id#' AND
				PD.customer_program_id = '#arguments.customer_program_id#' AND
				PD.deleted = 0
			LEFT JOIN Program_Rebates_Product_Data PR
				ON PR.Contract_Products_ID = CP.Contract_Products_ID
				AND PR.Deleted = 0
			LEFT JOIN Program_Rebates_Component_Data PRCD
				ON PRCD.Program_Rebates_Product_Data_ID = PR.Program_Rebates_Product_Data_ID
				AND PRCD.Deleted = 0 AND
				PR.Contract_Products_ID IS NOT NULL
			LEFT JOIN Program_Rebates_Component PRC ON
				PRC.Program_Rebates_Component_ID = PRCD.Program_Rebates_Component_ID AND
				PRC.Program_ID = <cfqueryparam value="#arguments.program_Id#" cfsqltype="CF_SQL_INTEGER" /> AND
				PRC.Component_Paid_To = #Paid_To_Flag# AND
			    PRC.Deleted = 0 AND
				PR.Contract_Products_ID IS NOT NULL
			LEFT JOIN Program_Fixed_Price_Product_Data PFP
				ON PFP.Contract_Products_ID = CP.Contract_Products_ID
				AND PFP.Deleted = 0 AND
				PFP.Contract_Products_ID IS NOT NULL
			LEFT JOIN Program_Fixed_Component PFC ON
				PFC.Program_Fixed_Component_ID = PFP.Program_Fixed_Component_ID AND
			    PFC.Program_ID = <cfqueryparam value="#arguments.program_Id#" cfsqltype="CF_SQL_INTEGER" /> AND
				PFC.Fixed_Component_Paid_To = #Paid_To_Flag# AND
			    PFC.Deleted = 0 AND
				PFP.Contract_Products_ID IS NOT NULL
			WHERE CP.deleted = 0  AND
				CP.is_Group = 0
			AND CP.Contract_Main_Id = <cfqueryparam value="#arguments.program_Id#" cfsqltype="CF_SQL_INTEGER" />
			AND ( (PFC.Program_Fixed_Component_ID IS NOT NULL OR CP.Product_Type_ID = 2 )
					AND
				  (PRC.Program_Rebates_Component_ID IS NOT NULL OR Product_Type_ID = 1 )
				)
			GROUP BY CP.BSA_Foodservice_items_master_id,
					Item,
					Description,
					Pullback
			ORDER BY #arguments.sql_Sort_By# #arguments.Sort_order#
		</cfquery>
		<cfreturn qGetCurrentProductlist />
	</cffunction>

<!--- For a given distributor FROM Opr or Dis Local program, get all the Dis Corp programs that have pullback FROM this program ON in the contract_main table that have the end date less than the opr or Local Dis end date --->
	<cffunction name="getDisCorpPorgrams" output="false">
		<cfargument name="Distributor_Id" required="true" type="string" />
		<cfargument name="end_date" required="true" type="string" />
		<cfargument name="start_date" required="true" type="string" />
		<cfargument name="pullback_template_type" required="true" type="numeric" />
		<cfargument name="applied_pullbacks" required="false" type="numeric" default="0" />
		<cfargument name="opr_program_id" required="false" type="numeric" />
		<cfargument name="sql_Sort_By" required="false" type="string" default="contract_number"/>
		<cfargument name="Sort_order" required="false" type="string" default="desc"/>
		<cfargument name="Opr_TemplateId" required="false" type="string" default="0"/>
		<cfset var dateoverlap = -31 />
		<cfquery name="qgetDisCorpPorgrams" datasource="#application.datasource#">

			declare	@program_products table
			(product_id uniqueidentifier)
			insert into @program_products (product_id)
			SELECT 	distinct contract_products.BSA_Foodservice_items_master_id
			FROM 	contract_products
			WHERE 	contract_products.deleted = 0
			AND 	contract_main_id = <cfqueryparam value="#arguments.opr_program_id#" cfsqltype="CF_SQL_INTEGER" />


			SELECT distinct contract_main.contract_main_id,
							contract_number,
							contract_title,
							contract_start_date,
							contract_end_date,
							Program_Control_Panel_Options.created_type,
							Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
			<cfif isdefined("arguments.opr_program_id")>
			,ISNULL(Pullback_Level,'P') AS Pullback_Level
			,case
				when max(ISNULL(pullback_value,0)) > 0
					then max(ISNULL(pullback_value,100))
				when ISNULL(template_pullback_program_defaults.Pullback_Default_Rate,0) > 0
					then ISNULL(template_pullback_program_defaults.Pullback_Default_Rate,100)
			 	else ISNULL(TPD.Pullback_Default_Rate,100)
			 end
			 AS pullback_value
			,SUM(ISNULL(pullback_details.pullback,1)) AS pullback
			</cfif>
			FROM contract_main  with (nolock)

			INNER JOIN Program_Control_Panel_Options with (nolock) on
			Program_Control_Panel_Options.ProgramControl_Panel_Options_id = contract_main.programtype_id

			INNER JOIN contract_distributors with (nolock) ON contract_distributors.contract_main_id =
			contract_main.contract_main_id
			AND contract_distributors.deleted = 0

			LEFT JOIN template_pullback_program_defaults with (nolock) on
			template_pullback_program_defaults.Corp_Template_Id =
			Program_Control_Panel_Options.ProgramControl_Panel_Options_id
			AND template_pullback_program_defaults.program_id =
			contract_main.contract_main_id
			AND template_pullback_program_defaults.Opr_Loc_Template_Id = #arguments.Opr_TemplateId#
			AND template_pullback_program_defaults.deleted = 0

			<cfif isdefined("arguments.opr_program_id")>
			LEFT JOIN pullback_details with (nolock) ON
			pullback_details.customer_program_id = contract_distributors.contract_main_id
			AND pullback_details.opr_program_id = '#arguments.opr_program_id#'
			AND pullback_details.customer_id = contract_distributors.BSA_Foodservice_Customers_id
			AND pullback_details.deleted = 0

			LEFT JOIN Pullbacks_Levels with (nolock) on
			Pullbacks_Levels.Pullback_Program_Id = '#arguments.opr_program_id#'
			AND Pullbacks_Levels.Pullback_FROM_Program_Id = contract_distributors.contract_main_id
			AND Pullbacks_Levels.customer_Id = pullback_details.customer_id

			LEFT JOIN Template_Pullback_Defaults TPD ON
				TPD.corp_Template_Id = Program_Control_Panel_Options.ProgramControl_Panel_Options_id AND
				TPD.Opr_loc_Template_Id = #arguments.Opr_TemplateId#
			</cfif>

			WHERE contract_main.deleted = 0
			AND (
					((DATEDIFF(d, contract_main.contract_start_date, '#arguments.end_date#') >= #dateoverlap#) AND (DATEDIFF(d, '#arguments.end_date#', contract_main.contract_end_date) >= 0))
				OR	((DATEDIFF(d, contract_main.contract_start_date, '#arguments.start_date#') >= 0) AND (DATEDIFF(d, '#arguments.start_date#', contract_main.contract_end_date) >= 0))
				OR	((DATEDIFF(d, '#arguments.start_date#', contract_main.contract_end_date) >= 0) AND (DATEDIFF(d, contract_main.contract_end_date, '#arguments.end_date#') >= 0))
				OR	((DATEDIFF(d, '#arguments.start_date#', contract_main.contract_start_date) >= 0) AND (DATEDIFF(d, contract_main.contract_start_date, '#arguments.end_date#') >= #dateoverlap#))
			)
			AND contract_main.approved = 1 <!--- safe to use approved = 1 instead of relying ON status betwen 3 AND 7 --->
			AND	(contract_main.manual_cancel = 0 or contract_main.Cancel_AND_End_Dated = 1)
			AND contract_main.contract_status_type_idx >= 3
			AND Program_Control_Panel_Options.generic_type like '%Distributor Trade/Shelter%'
			<cfif arguments.pullback_template_type EQ 1>
			AND Program_Control_Panel_Options.pullbacks_ON = 1
			</cfif>
			AND contract_distributors.BSA_Foodservice_Customers_id = '#arguments.Distributor_Id#'
			AND contract_main.Pullback_FROM_This_Program =  1

			AND	exists
			(SELECT	top 1 contract_products_id
			FROM	contract_products with (nolock)
			where	contract_products.deleted = 0
			AND		contract_products.contract_main_id = contract_main.contract_main_id
			AND		contract_products.BSA_Foodservice_items_master_id in
			(SELECT	product_id FROM @program_products)
			)

			<cfif isdefined("arguments.opr_program_id")>
			group by contract_main.contract_main_id,
					contract_number,
					contract_title,
					contract_start_date,
					contract_end_date,
					Pullback_Level,
					Program_Control_Panel_Options.created_type,
					template_pullback_program_defaults.Pullback_Default_Rate,
					Program_Control_Panel_Options.ProgramControl_Panel_Options_ID,
					TPD.Pullback_Default_Rate
			</cfif>
			order by #arguments.sql_Sort_By# #arguments.Sort_order#
			</cfquery>
		<cfreturn qgetDisCorpPorgrams />
	</cffunction>

	<cffunction name="checkDisCorpPorgramsCount" output="false">
		<cfargument name="Distributor_Id" required="true" type="string" />
		<cfargument name="end_date" required="true" type="string" />
		<cfargument name="start_date" required="true" type="string" />
		<cfargument name="contract_main_id" required="true" type="numeric" />
		<cfset var dateoverlap = -31 />
		<cfset returnvalue = 0>

		<cfquery name="qcheckDisCorpPorgramsCount" datasource="#application.datasource#">

			declare	@program_products table
			(product_id uniqueidentifier)
			insert into @program_products (product_id)
			SELECT 	distinct contract_products.BSA_Foodservice_items_master_id
			FROM 	contract_products
			WHERE 	contract_products.deleted = 0
			AND 	contract_main_id = <cfqueryparam value="#arguments.contract_main_id#" cfsqltype="CF_SQL_INTEGER" />

			SELECT count(*) AS DisCorpProgramsCount
			FROM contract_main
			INNER JOIN Program_Control_Panel_Options on
			Program_Control_Panel_Options.ProgramControl_Panel_Options_id = contract_main.programtype_id
			INNER JOIN contract_distributors ON contract_distributors.contract_main_id =
			contract_main.contract_main_id
			AND contract_distributors.deleted = 0
			WHERE contract_main.deleted = 0
			<!--- modified to match same criteria AS getDisCorpPorgrams ---->
			AND (
					((DATEDIFF(d, contract_main.contract_start_date, '#arguments.end_date#') >= #dateoverlap#) AND (DATEDIFF(d, '#arguments.end_date#', contract_main.contract_end_date) >= 0))
				OR	((DATEDIFF(d, contract_main.contract_start_date, '#arguments.start_date#') >= 0) AND (DATEDIFF(d, '#arguments.start_date#', contract_main.contract_end_date) >= 0))
				OR	((DATEDIFF(d, '#arguments.start_date#', contract_main.contract_end_date) >= 0) AND (DATEDIFF(d, contract_main.contract_end_date, '#arguments.end_date#') >= 0))
				OR	((DATEDIFF(d, '#arguments.start_date#', contract_main.contract_start_date) >= 0) AND (DATEDIFF(d, contract_main.contract_start_date, '#arguments.end_date#') >= #dateoverlap#))
			)
			AND contract_main.approved = 1
			AND	(contract_main.manual_cancel = 0 or contract_main.Cancel_AND_End_Dated = 1)
			AND contract_main.contract_status_type_idx >= 3
			AND Program_Control_Panel_Options.generic_type like '%Distributor Trade/Shelter%'
			AND contract_distributors.BSA_Foodservice_Customers_id = '#arguments.Distributor_Id#'
			AND contract_main.Pullback_FROM_This_Program =  1

			AND	exists
			(SELECT	top 1 contract_products_id
			FROM	contract_products with (nolock)
			where	contract_products.deleted = 0
			AND		contract_products.contract_main_id = contract_main.contract_main_id
			AND		contract_products.BSA_Foodservice_items_master_id in
			(SELECT	product_id FROM @program_products)
			)
		</cfquery>

		<cfset returnvalue = qcheckDisCorpPorgramsCount.DisCorpProgramsCount>

		<cfreturn returnvalue />

	</cffunction>

	<cffunction name="deleteoldpullbackrates" output="false">
		<cfargument name="program_id" required="true" type="numeric" />
		<cfargument name="Distributor_Id" required="false" type="string" />
		<cfargument name="corp_program_id" required="false" type="string" />
		<cfquery name="qdeleteoldpullbackrates" datasource="#application.datasource#">
			delete FROM pullback_details
			WHERE opr_program_id = <cfqueryparam value="#arguments.program_Id#" cfsqltype="CF_SQL_INTEGER" />
			<cfif isdefined("arguments.Distributor_Id")>
				<cfif arguments.Distributor_Id NEQ "">
				AND Customer_id = '#arguments.Distributor_Id#'
				</cfif>
			</cfif>
			<cfif isdefined("arguments.corp_program_id")>
				<cfif arguments.corp_program_id NEQ "">
				AND Customer_program_id = '#arguments.corp_program_id#'
				</cfif>
			</cfif>
		</cfquery>
	</cffunction>

	<cffunction name="viewProductlist" output="false">
		<cfargument name="program_id" required="true" type="numeric" />
		<cfargument name="distributor_id" required="false" type="string" />
			<cfargument name="sql_Sort_By" required="false" type="string" default="item"/>
		<cfargument name="Sort_order" required="false" type="string" default="desc"/>
		<cfquery name="qGetCurrentProductlist" datasource="#application.datasource#">
			SELECT distinct customer_program_id,contract_main.contract_number,contract_main.contract_title,contract_main.contract_start_date,
			contract_main.contract_end_date,contract_products.BSA_Foodservice_items_master_id,item,description,customer_program_id
			,max(ISNULL(pullback_value,0)) AS pullback_value,(SELECT max(ISNULL(pullback_value,0)) FROM
			pullback_details WHERE product_id = contract_products.BSA_Foodservice_Items_Master_id
			AND pullback_details.opr_program_id = <cfqueryparam value="#arguments.program_Id#" cfsqltype="CF_SQL_INTEGER" />
			AND pullback_details.customer_id = '#arguments.distributor_id#' group by product_id) AS prod_pullback_value
			FROM contract_products
			INNER JOIN BSA_Foodservice_Items_Master on
			contract_products.BSA_Foodservice_items_master_id = BSA_Foodservice_items_master.BSA_Foodservice_items_master_id
			LEFT JOIN pullback_details ON
			pullback_details.product_id = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_id
			AND pullback_details.opr_program_id = contract_products.contract_main_id
			AND pullback_details.customer_id = '#arguments.distributor_id#'
			AND pullback_details.deleted = 0
			INNER JOIN contract_main on
			contract_main.contract_main_id = pullback_details.customer_program_id
			WHERE contract_products.deleted = 0
			AND contract_products.contract_main_id = <cfqueryparam value="#arguments.program_Id#" cfsqltype="CF_SQL_INTEGER" />
			group by contract_products.BSA_Foodservice_items_master_id,item,description,customer_program_id,contract_main.contract_number,contract_main.contract_title,contract_main.contract_start_date,
			contract_main.contract_end_date
			order by #arguments.sql_Sort_By#,contract_number #arguments.Sort_order#
		</cfquery>
		<cfreturn qGetCurrentProductlist />
	</cffunction>

	<cffunction name="GetDistDetails" output="false">
		<cfargument name="distributors_id" required="true" type="string" />
		<cfargument name="sql_Sort_By" required="false" type="string" default="name"/>
		<cfargument name="Sort_order" required="false" type="string" default="desc"/>
		<cfargument name="opr_program_id" required="false" type="numeric" />
		<cfquery name="qGetDistDetails" datasource="#application.datasource#">
			SELECT name,shr_ship_to,BSA_Foodservice_Customers_id
			<cfif isdefined("arguments.opr_program_id")>
			,ISNULL(pullback_default_value,0) AS pullback_default_value
			</cfif>
			FROM BSA_Foodservice_Customers
			<cfif isdefined("arguments.opr_program_id")>
			LEFT JOIN Pullbacks_Distributors_Defaults on
			Pullbacks_Distributors_Defaults.Pullback_Program_Id =  <cfqueryparam value="#arguments.opr_program_id#" cfsqltype="CF_SQL_INTEGER" />
			AND Pullbacks_Distributors_Defaults.customer_id = BSA_Foodservice_Customers.BSA_Foodservice_Customers_id
			</cfif>
			WHERE BSA_Foodservice_Customers_id IN (#ListQualify(arguments.distributors_id, "'", ",")#)
			order by #arguments.sql_Sort_By# #arguments.Sort_order#
		</cfquery>
		<cfreturn qGetDistDetails />
	</cffunction>

	<cffunction name="GetcontractDetails" output="false">
		<cfargument name="program_id" required="true" type="numeric" />
		<cfquery name="qGetcontractDetails" datasource="#application.datasource#">
			SELECT contract_number,contract_title,contract_start_date,
			contract_end_date
			,ISNULL(Program_Control_Panel_Options.default_pullback_rate,0) as
		 	default_pullback_rate,
			Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
			FROM contract_main
			INNER JOIN Program_Control_Panel_Options on
			Program_Control_Panel_Options.ProgramControl_Panel_Options_id =
			contract_main.programtype_id
			WHERE contract_main_id = <cfqueryparam value="#arguments.program_Id#" cfsqltype="CF_SQL_INTEGER" />
		</cfquery>
		<cfreturn qGetcontractDetails />
	</cffunction>

<!--- Get all the opr or Local Dis templates that have programs with pullbacks rules applied --->
	<cffunction name="GetOprtemplates" output="false">
		<cfargument name="program_id" required="true" type="numeric" />
		<cfargument name="sql_Sort_By" required="false" type="string" default="Program_Control_Panel_Options.created_type"/>
		<cfargument name="Sort_order" required="false" type="string" default="desc"/>
		<cfquery name="qGetOprtemplates" datasource="#application.datasource#">
			SELECT distinct Program_Control_Panel_Options.created_type,
program_description,ISNULL(default_pullback_rate,0) AS default_pullback_rate,ProgramControl_Panel_Options_id
			FROM pullback_details
			INNER JOIN contract_main
			ON contract_main.contract_main_id = pullback_details.opr_program_id
			INNER JOIN Program_Control_Panel_Options on
			Program_Control_Panel_Options.ProgramControl_Panel_Options_id =
			contract_main.programtype_id
			--AND contract_main.deleted = 0
			AND contract_main.contract_status_type_idx > 2
			WHERE customer_program_id = <cfqueryparam value="#arguments.program_Id#"
 cfsqltype="CF_SQL_INTEGER" />
 			AND pullback_details.deleted = 0
			order by #arguments.sql_Sort_By# #arguments.Sort_order#
		</cfquery>
		<cfreturn qGetOprtemplates />
	</cffunction>

<!--- 	get all the Dis Corp Templates that have programs with pullback rules --->
	<cffunction name="GetDisttemplates" output="false">
		<cfargument name="program_id" required="true" type="numeric" />
		<cfargument name="sql_Sort_By" required="false" type="string" default="Program_Control_Panel_Options.created_type"/>
		<cfargument name="Sort_order" required="false" type="string" default="desc"/>
		<cfquery name="qGetDisttemplates" datasource="#application.datasource#">
			SELECT distinct Program_Control_Panel_Options.created_type,
program_description,ISNULL(default_pullback_rate,0) AS default_pullback_rate
			FROM pullback_details
			INNER JOIN contract_main
			ON contract_main.contract_main_id = pullback_details.customer_program_id
			INNER JOIN Program_Control_Panel_Options on
			Program_Control_Panel_Options.ProgramControl_Panel_Options_id =
			contract_main.programtype_id
			--AND contract_main.deleted = 0
			AND contract_main.contract_status_type_idx > 2
			WHERE opr_program_id = <cfqueryparam value="#arguments.program_Id#" cfsqltype="CF_SQL_INTEGER" />
			AND pullback_details.deleted = 0
			order by #arguments.sql_Sort_By# #arguments.Sort_order#
		</cfquery>
		<cfreturn qGetDisttemplates />
	</cffunction>

	<cffunction name="GettemplateDetails" output="false">
		<cfargument name="template_id" required="true" type="string" />
		<cfquery name="qGettemplateDetails" datasource="#application.datasource#">
			SELECT distinct top 1 Program_Control_Panel_Options.created_type,
program_description,default_pullback_rate,ProgramControl_Panel_Options_id
			FROM Program_Control_Panel_Options
			WHERE created_type = <cfqueryparam value="#arguments.template_id#" cfsqltype="CF_SQL_VARCHAR" />
			AND isdominant = 1
		</cfquery>
		<cfreturn qGettemplateDetails />
	</cffunction>

	<cffunction name="GettemplateOprProgramDetails" output="false">
		<cfargument name="program_id" required="true" type="numeric" />
		<cfargument name="template_id" required="false" type="string" default=""/>
		<cfargument name="sql_Sort_By" required="false" type="string" default="contract_number"/>
		<cfargument name="Sort_order" required="false" type="string" default="desc"/>
		<cfargument name="distributors" required="false" type="string" default=""/>
		<cfquery name="qGettemplateOprProgramDetails" datasource="#application.datasource#">
			SELECT distinct contract_main_id AS program_id, contract_number, contract_title,
			contract_start_date,contract_end_date,default_pullback_rate,revision_version
			<cfif arguments.distributors NEQ "">
			,sum(ISNULL(pullback,0)) AS pullback
			,max(pullback_value) AS max_pullback_value,
			min(pullback_value) AS min_pullback_value
			</cfif>
			FROM pullback_details
			INNER JOIN contract_main
				ON contract_main.contract_main_id = pullback_details.opr_program_id
			INNER JOIN Program_Control_Panel_Options on
				Program_Control_Panel_Options.ProgramControl_Panel_Options_id = contract_main.programtype_id
				AND contract_main.deleted = 0
				AND contract_main.contract_status_type_idx > 2

		<!--- 	LEFT JOIN Template_Pullback_Defaults TPD ON
				TPD.corp_Template_Id = Program_Control_Panel_Options.ProgramControl_Panel_Options_id AND
				TPD.Opr_loc_Template_Id = #arguments.Opr_TemplateId# --->

			WHERE customer_program_id = <cfqueryparam value="#arguments.program_Id#" cfsqltype="CF_SQL_INTEGER" />
			AND pullback_details.deleted = 0
			<cfif arguments.template_id NEQ "" AND arguments.template_id NEQ 0>
			AND ProgramControl_Panel_Options_id = <cfqueryparam value="#arguments.template_id#" cfsqltype="CF_SQL_VARCHAR" />
			</cfif>
			<cfif arguments.distributors NEQ "">
			AND customer_id In (#ListQualify(arguments.distributors, "'", ",")#)
			group by contract_main_id, contract_number, contract_title,revision_version,
			contract_start_date,contract_end_date,default_pullback_rate
			</cfif>
			order by #arguments.sql_Sort_By# #arguments.Sort_order#
		</cfquery>
		<cfreturn qGettemplateOprProgramDetails />
	</cffunction>

	<cffunction name="GettemplateDisProgramDetails" output="false">
		<cfargument name="program_id" required="true" type="numeric" />
		<cfargument name="template_id" required="false" type="string" default=""/>
		<cfargument name="sql_Sort_By" required="false" type="string" default="contract_number"/>
		<cfargument name="Sort_order" required="false" type="string" default="desc"/>
		<cfargument name="distributors" required="false" type="string" default=""/>
		<cfargument name="opr_templateid" required="false" type="string" default="0"/>
		<cfquery name="qGettemplateDisProgramDetails" datasource="#application.datasource#">
			SELECT distinct contract_main_id AS program_id, contract_number,
			contract_title,contract_start_date,contract_end_date,
			default_pullback_rate,revision_version
			<cfif arguments.opr_templateid NEQ 0>
			,CASE WHEN (ISNULL(TPPD.Pullback_Default_Rate,0)) > 0
			THEN (ISNULL(TPPD.Pullback_Default_Rate,0))
			ELSE ISNULL(TPD.Pullback_Default_Rate,0)
			END
			AS Pullback_Default_Rate
			</cfif>
			<cfif arguments.distributors NEQ "">
			,sum(isnull(pullback,0)) AS pullback
			,max(pullback_value) AS max_pullback_value, min(pullback_value) AS min_pullback_value
			</cfif>
			FROM pullback_details
			INNER JOIN contract_main
			ON contract_main.contract_main_id = pullback_details.customer_program_id
			INNER JOIN Program_Control_Panel_Options on
			Program_Control_Panel_Options.ProgramControl_Panel_Options_id =
			contract_main.programtype_id
			--AND contract_main.deleted = 0
			AND contract_main.contract_status_type_idx > 2
			<cfif arguments.opr_templateid NEQ 0>
			LEFT JOIN template_pullback_program_defaults TPPD on
				TPPD.Corp_Template_Id = Program_Control_Panel_Options.ProgramControl_Panel_Options_id
				AND TPPD.program_id = contract_main.contract_main_id
				AND TPPD.Opr_Loc_Template_Id = '#arguments.Opr_TemplateId#'

			LEFT JOIN Template_Pullback_Defaults TPD ON
				TPD.corp_Template_Id = Program_Control_Panel_Options.ProgramControl_Panel_Options_id AND
				TPD.Opr_loc_Template_Id = '#arguments.Opr_TemplateId#'
			</cfif>
			WHERE opr_program_id = <cfqueryparam value="#arguments.program_Id#" cfsqltype="CF_SQL_INTEGER" />
			AND pullback_details.deleted = 0
			<cfif arguments.template_id NEQ "">
			AND Program_Control_Panel_Options.created_type = <cfqueryparam value="#arguments.template_id#" cfsqltype="CF_SQL_VARCHAR" />
			</cfif>
			<cfif arguments.distributors NEQ "">
			AND customer_id In (#ListQualify(arguments.distributors, "'", ",")#)
			group by contract_main_id, contract_number, contract_title,
			contract_start_date,contract_end_date,default_pullback_rate,
			revision_version
			<cfif arguments.opr_templateid NEQ 0>,tpd.Pullback_Default_Rate,tppd.Pullback_Default_Rate</cfif>
			</cfif>
			order by #arguments.sql_Sort_By# #arguments.Sort_order#
		</cfquery>
		<cfreturn qGettemplateDisProgramDetails />
	</cffunction>

	<cffunction name="GetProgramDistDetails" output="false">
		<cfargument name="dis_program_id" required="true" type="numeric" />
		<cfargument name="opr_program_id" required="true" type="numeric" />
		<cfargument name="distributors" required="false" type="string" />
		<cfquery name="qGetProgramDistDetails" datasource="#application.datasource#">
			SELECT distinct max(pullback_value) AS max_pullback_value, min(pullback_value) AS min_pullback_value,name,shr_ship_to,BSA_Foodservice_Customers_id
			FROM pullback_details
			INNER JOIN BSA_Foodservice_Customers ON
			BSA_Foodservice_Customers.BSA_Foodservice_Customers_id =
			pullback_details.customer_id
			WHERE customer_program_id = <cfqueryparam value="#arguments.dis_program_id#" cfsqltype="CF_SQL_INTEGER" />
			AND opr_program_id = <cfqueryparam value="#arguments.opr_program_id#" cfsqltype="CF_SQL_INTEGER" />
			AND pullback_details.deleted = 0
			<cfif isdefined("arguments.distributors")>
			<cfif arguments.distributors NEQ "">
			AND pullback_details.customer_id In (#ListQualify(arguments.distributors, "'", ",")#)
			</cfif>
			</cfif>
			group by name,shr_ship_to,BSA_Foodservice_Customers_id
			order by name
		</cfquery>
		<cfreturn qGetProgramDistDetails />
	</cffunction>

	<cffunction name="GetDistItemDetails" output="false">
		<cfargument name="dis_program_id" required="true" type="numeric" />
		<cfargument name="opr_program_id" required="true" type="numeric" />
		<cfargument name="dist_id" required="true" type="string" />
		<cfargument name="sql_Sort_By" required="false" type="string" default="item"/>
		<cfargument name="Sort_order" required="false" type="string" default="desc"/>
		<cfquery name="qGetDistItemDetails" datasource="#application.datasource#">
			SELECT distinct pullback_value,item,description
			FROM pullback_details
			INNER JOIN BSA_Foodservice_Items_Master on
			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_id =
			pullback_details.product_id
			WHERE pullback_details.customer_id = '#arguments.dist_id#'
			AND pullback_details.deleted = 0
			AND customer_program_id = <cfqueryparam value="#arguments.dis_program_id#" cfsqltype="CF_SQL_INTEGER" />
			AND opr_program_id = <cfqueryparam value="#arguments.opr_program_id#" cfsqltype="CF_SQL_INTEGER" />
			order by #arguments.sql_Sort_By# #arguments.Sort_order#
		</cfquery>
		<cfreturn qGetDistItemDetails />
	</cffunction>

<!--- Get all the BB's FROM the pullbacks_Log table for a given Dis Corp BB that match the products,customers,discounttypes AND components for rebates --->
	<cffunction name="GetBillbackstoApply" output="false">
		<cfargument name="Dis_BB_Id" required="true" type="string" />
		<cfargument name="OPR_BB_Id" required="false" type="string" default="" />
		<cfargument name="appliedpullbacks" required="false" type="boolean" default="0" />

		<cfquery name="CheckIfSplit" datasource="#application.datasource#">
		SELECT * FROM Billback WHERE Billback_ID = <cfqueryparam value="#arguments.Dis_BB_Id#" 						cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfset Parent_Billback_ID = arguments.Dis_BB_Id / >
		<CFIF CheckIfSplit.BB_Is_Child EQ 1>
			<cfset Parent_Billback_ID = CheckIfSplit.BB_Parent_ID / >
		</CFIF>

		<cfquery name="qGetBillbackstoApply" datasource="#application.datasource#">

		<!--- For unapplied pullbacks, we need to calculate the budget recapture amount based ON current autopay billback --->
		IF OBJECT_ID('tempdb..##tmp_product_dist_price') IS NOT NULL
		DROP TABLE ##tmp_product_dist_price

		CREATE TABLE ##tmp_product_dist_price (Product_ID uniqueidentifier, Distributor_ID uniqueidentifier, Gross_Price decimal(20, 4), Net_Price decimal(20, 4))

		<cfif arguments.appliedpullbacks eq 0 AND application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetsFunctionalityOn()>
			DECLARE @Budget_Recapture_Rate_Logic bit,
					@Auto_Pay_Net_Of_Cash_Discount bit,
					@Auto_Pay_Net_Of_Freight_Allowance bit

			SELECT	@Budget_Recapture_Rate_Logic = 1,
					@Auto_Pay_Net_Of_Cash_Discount = rcn.Auto_Pay_Net_Of_Cash_Discount,
					@Auto_Pay_Net_Of_Freight_Allowance = rcn.Auto_Pay_Net_Of_Freight_Allowance
			FROM	Billback b
			INNER JOIN Billback_Program_Rebate_Component br
			ON		br.Billback_Id = b.Billback_ID
			AND		br.Deleted = 0
			AND		br.checked = 'true'
			INNER JOIN Program_Rebates_Component_Name rcn
			ON		rcn.Program_Rebates_Component_Name_ID = br.Program_Rebates_Component_Name_ID
			AND		rcn.Recapture_Rate_FROM_Program_Budget = 1
			WHERE	b.Billback_ID = <cfqueryparam value="#Parent_Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND		b.Auto_Billback = 1

			<!--- Only when rebate component hAS recapture FROM budget flag ON --->
			IF @Budget_Recapture_Rate_Logic = 1
			BEGIN
				<!--- Store the data for later use --->
				INSERT INTO ##tmp_product_dist_price (Product_ID, Distributor_ID, Gross_Price, Net_Price)
				SELECT	Product_ID, Distributor_ID_Earned,
						Gross_Price = Cast(avg(l.Sales_Dollars / l.Pounds_Invoiced) AS decimal(20, 4)),
						Net_Price = Cast(avg(
								(l.Sales_Dollars
								- (case @Auto_Pay_Net_Of_Cash_Discount when 1 then isnull(l.Freight_Revenue,0) else 0 end)
								- (case @Auto_Pay_Net_Of_Freight_Allowance when 1 then isnull(l.Cash_Discount, 0) else 0 end)
								) / l.Pounds_Invoiced) AS decimal(20, 4))
				FROM	BB_Auto_Accrual_Log l
				WHERE	l.BB_ID = <cfqueryparam value="#Parent_Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
				GROUP BY Product_ID, Distributor_ID_Earned
			END
		</cfif>

		SELECT distinct
				pullback_billback_id,pullback_FROM_program_number,OPR_BB.BB_title,
				OPR_BB.bb_reference,OPR_BB.bb_code,OPR_BB.bb_start_date,OPR_BB.bb_end_date,
				pullbacks_log.product_id,pullbacks_log.discount_type_id,
				<cfif arguments.appliedpullbacks eq 0>
					ISNULL(SUM(((ISNULL(product_BB_volume_LB,0) * ISNULL(pullback_percent,0))/100) * ISNULL(paid_rate_lb,0)),0)
					<!--- Calculate budget recapture amount when unapplied --->
					- sum(isnull(
					CASE Budget_Recapture_Rate_UOM
					WHEN 1 THEN pullbacks_log.Budget_Recapture_Rate / CAST(BSA_Foodservice_items_master.Net_Weight AS float) --CS
					WHEN 2 THEN pullbacks_log.Budget_Recapture_Rate -- LB
					WHEN 9 THEN pullbacks_log.Budget_Recapture_Rate * BSA_Foodservice_items_master.Case_Equivalent / CAST(BSA_Foodservice_items_master.Net_Weight AS float) --CS
					WHEN 31 THEN pr.Gross_Price * pullbacks_log.Budget_Recapture_Rate * 0.01 * pullbacks_log.product_BB_volume_LB -- % Gross $
					WHEN 32 THEN pr.Net_Price * pullbacks_log.Budget_Recapture_Rate * 0.01 * pullbacks_log.product_BB_volume_LB -- % Net $
					END
					, 0))
				<cfelse>
					ISNULL(SUM(isnull(pullback_expected_dollars,0)),0)
				</cfif> AS pullback_amount,
				<cfif arguments.appliedpullbacks eq 0>
					ISNULL(MAX(ISNULL(paid_rate_lb,0)),0)
				<cfelse>
					ISNULL(MAX(ISNULL(pullbacks_log.Pullback_From_BB_Paid_Rate,0)),0)
				</cfif> AS paid_rate,
				<cfif arguments.appliedpullbacks eq 0>
					<!--- Calculate budget recapture amount when unapplied --->
					sum(isnull(
					CASE Budget_Recapture_Rate_UOM
					WHEN 1 THEN pullbacks_log.Budget_Recapture_Rate / CAST(BSA_Foodservice_items_master.Net_Weight AS float) --CS
					WHEN 2 THEN pullbacks_log.Budget_Recapture_Rate -- LB
					WHEN 9 THEN pullbacks_log.Budget_Recapture_Rate * BSA_Foodservice_items_master.Case_Equivalent / CAST(BSA_Foodservice_items_master.Net_Weight AS float) --CS
					WHEN 31 THEN pr.Gross_Price * pullbacks_log.Budget_Recapture_Rate * 0.01 * pullbacks_log.product_BB_volume_LB -- % Gross $
					WHEN 32 THEN pr.Net_Price * pullbacks_log.Budget_Recapture_Rate * 0.01 * pullbacks_log.product_BB_volume_LB -- % Net $
					END
					, 0))
				<cfelse>
					sum(isnull(Budget_Recapture_Amount, 0))
				</cfif> AS Budget_Recapture_Amount,
				item,
				description,
				cast(BSA_Foodservice_items_master.net_weight AS decimal(20,4)) AS net_weight,
				cast(SUM(cast(product_BB_volume_LB AS float)) AS decimal(20,4)) AS product_BB_volume_LB,
				pullback_percent,CM.contract_number,CM.contract_main_id,
				CM.revision_version,discount_type_desc,
				pullbacks_log.customer_id, BSA_Foodservice_Customers.shr_ship_to, BSA_Foodservice_Customers.name
		FROM billback INNER JOIN
		billback_program ON billback_program.billback_id =
		billback.billback_id INNER JOIN
		contract_main ON contract_main.contract_main_id = billback_program.program_id
		<cfif arguments.appliedpullbacks eq 0>
		LEFT JOIN BB_Item_Final ON BB_Item_Final.billback_id = billback.billback_id AND
			BB_Item_Final.deleted = 0
		LEFT JOIN bb_item_final_detail ON
			bb_item_final_detail.BB_Item_Final_id = BB_Item_Final.BB_Item_Final_id
			AND bb_item_final_detail.deleted = 0
		LEFT JOIN billback_product on
		billback_product.billback_product_ID = BB_Item_Final.billback_product_ID
		</cfif>
		INNER JOIN pullbacks_log ON
		<cfif arguments.appliedpullbacks eq 1>
		Pullback_Applied_To_Billback_Id = <cfqueryparam value="#arguments.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
		AND pullbacks_log.pullback_applied = 1
		<cfelse>
		pullbacks_log.pullback_FROM_program_number= contract_main.contract_number
		AND BB_Item_Final.distributor_id = pullbacks_log.customer_id
		AND pullbacks_log.product_id = billback_product.product_id
		AND pullbacks_log.discount_type_id = bb_item_final_detail.BB_Product_type
		AND pullbacks_log.deleted = 0
		AND pullbacks_log.pullback_applied = 0
		</cfif>
		INNER JOIN Discount_Type on
		Discount_Type.discount_type_id = pullbacks_log.discount_type_id
		INNER JOIN billback OPR_BB on
		OPR_BB.billback_id = pullbacks_log.pullback_billback_id
		AND OPR_BB.deleted = 0
		INNER JOIN contract_main CM on
		CM.contract_main_id = pullbacks_log.pullback_program_id
		INNER JOIN BSA_Foodservice_items_master on
		BSA_Foodservice_items_master.BSA_Foodservice_items_master_id =
		pullbacks_log.product_id
		LEFT JOIN Billback_Program_Rebate_Component on
		Billback_Program_Rebate_Component.billback_id = billback.billback_id
		AND pullbacks_log.component_id = Billback_Program_Rebate_Component.Program_Rebates_Component_name_id
		AND Billback_Program_Rebate_Component.deleted = 0
		AND Billback_Program_Rebate_Component.checked = 'true'
		INNER JOIN BSA_Foodservice_Customers
		ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = pullbacks_log.customer_id
		<cfif arguments.appliedpullbacks eq 0>
		LEFT JOIN ##tmp_product_dist_price pr
		on		pr.Distributor_ID = pullbacks_log.Customer_Id
		AND		pr.Product_ID = pullbacks_log.Product_ID
		</cfif>
		WHERE billback.deleted = 0 AND
		billback.billback_id = <cfqueryparam value="#Parent_Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND pullback_billback_id != <cfqueryparam value="#Parent_Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		<cfif arguments.appliedpullbacks eq 0>
			AND (pullbacks_log.discount_type_id <> 2 or Billback_Program_Rebate_Component.billback_id is not null)
		</cfif>
		<cfif arguments.appliedpullbacks eq 1>
			AND Pullback_Applied_To_Billback_Id = <cfqueryparam value="#arguments.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
		</cfif>
		group by pullback_billback_id,pullback_FROM_program_number,OPR_BB.BB_title,
		OPR_BB.bb_reference,OPR_BB.bb_code,OPR_BB.bb_start_date,OPR_BB.bb_end_date,
		pullbacks_log.product_id,pullbacks_log.discount_type_id
		,item,description,BSA_Foodservice_items_master.net_weight,pullback_percent,
		CM.contract_number,CM.revision_version,CM.contract_main_id,discount_type_desc,
		pullbacks_log.customer_id, BSA_Foodservice_Customers.shr_ship_to, BSA_Foodservice_Customers.name
		order by pullback_billback_id

		IF OBJECT_ID('tempdb..##tmp_product_dist_price') IS NOT NULL
		DROP TABLE ##tmp_product_dist_price
		</cfquery>
	<cfreturn qGetBillbackstoApply />
	</cffunction>
	<!---D39144 :: Autopay Recapture START --->
	<!--- Check if the Dis Corp BB has any products with Growth --->
	<cffunction name="checkifBBhasGrowth" output="false">
	<cfargument name="Dis_BB_Id" required="true" type="string" />
	<cfargument name="pullbacks_applied" required="false" type="boolean" />
	<cfquery name="qcheckifBBhasGrowth" datasource="#application.datasource#">
	<cfif arguments.pullbacks_applied EQ 0>
		SELECT DISTINCT PBL.pullback_billback_id
									,PBL.pullback_FROM_program_number
									,OPR_BB.BB_title
									,OPR_BB.bb_reference
									,OPR_BB.bb_code
									,OPR_BB.bb_start_date,OPR_BB.bb_end_date
									,CM.contract_number
									,CM.contract_main_id
									,CM.revision_version
									,CM.contract_title
									,'growth' AS discount_type_desc
									,PBL.discount_type_id
									,cast(SUM(ISNULL(product_BB_volume_LB,0)*ISNULL(pullback_percent,0)/100) AS decimal(20,0)) AS volume_LB
									,cast(SUM(cast(product_BB_volume_LB AS float) / cast(BSA_Foodservice_items_master.net_weight AS decimal(20,4))) AS decimal(20,4)) AS volume_CS
									,BSA.shr_ship_to
									,BSA.name
		FROM Billback_Product
		INNER JOIN Billback_Product_Detail
		ON 	Billback_Product_Detail.Billback_Product_id =Billback_Product.Billback_Product_id
		AND Billback_Product_Detail.deleted = 0
		INNER JOIN billback_program
		ON billback_program.billback_id = 	Billback_Product_Detail.billback_id
		INNER JOIN contract_main
		ON contract_main.contract_main_id = billback_program.program_id
		INNER JOIN pullbacks_log PBL
		ON 	PBL.pullback_FROM_program_number= contract_main.contract_number
		AND Billback_Product.distributor_id = PBL.customer_id
		AND PBL.product_id = billback_product.product_id
		INNER JOIN billback OPR_BB
		ON OPR_BB.billback_id = PBL.pullback_billback_id
		INNER JOIN contract_main CM
		ON CM.contract_main_id = PBL.pullback_program_id
		INNER JOIN BSA_Foodservice_Customers BSA
		ON BSA.BSA_Foodservice_Customers_ID = PBL.customer_id
		INNER JOIN BSA_Foodservice_items_master
		ON BSA_Foodservice_items_master.BSA_Foodservice_items_master_id = PBL.product_id
		WHERE Billback_Product.billback_Id = <cfqueryparam value="#arguments.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
		AND PBL.pullback_applied =0
		AND PBL.deleted = 0
		AND PBL.discount_type_id = 4
		AND PBL.deleted = 0
		AND BB_product_type_id = 4
		AND ISNULL(cast(BB_rate AS float),0) ! = 0
		GROUP BY  PBL.pullback_billback_id,PBL.pullback_FROM_program_number,PBL.discount_type_id
							,OPR_BB.BB_title,OPR_BB.bb_reference,OPR_BB.bb_code,OPR_BB.bb_start_date,OPR_BB.bb_end_date
							,CM.contract_number,CM.revision_version,CM.contract_title,CM.contract_main_id
							,BSA.shr_ship_to,BSA.name

		<cfelse>

		SELECT PBL.pullback_billback_id
					,PBL.pullback_FROM_program_number
					,OPR_BB.BB_title
					,OPR_BB.bb_reference
					,OPR_BB.bb_code
					,OPR_BB.bb_start_date
					,OPR_BB.bb_end_date
					,CM.contract_number
					,CM.revision_version
					,CM.contract_title
					,'growth' AS discount_type_desc
					,PBL.discount_type_id
					,SUM(ISNULL(pullback_expected_dollars,0))	AS pullback_amount
					,cast(SUM(ISNULL(product_BB_volume_LB,0)*ISNULL(pullback_percent,0)/100) AS decimal(20,0)) AS volume_LB
					,BSA.shr_ship_to
					,BSA.name
		FROM pullbacks_log PBL
		INNER JOIN billback OPR_BB
		ON OPR_BB.billback_id = PBL.pullback_billback_id
		INNER JOIN contract_main CM
		ON CM.contract_main_id = PBL.pullback_program_id
		INNER JOIN BSA_Foodservice_Customers  BSA
		ON BSA.BSA_Foodservice_Customers_ID = PBL.customer_id
		WHERE PBL.pullback_applied = 1
		AND PBL.pullback_applied_to_billback_id = <cfqueryparam value="#arguments.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
		AND PBL.deleted = 0
		AND PBL.discount_type_id = 4
		GROUP BY  PBL.pullback_billback_id,PBL.pullback_FROM_program_number,PBL.discount_type_id
							,OPR_BB.BB_title,OPR_BB.bb_reference,OPR_BB.bb_code,OPR_BB.bb_start_date,OPR_BB.bb_end_date
							,CM.contract_number,CM.revision_version,CM.contract_title
							,BSA.shr_ship_to,BSA.name
		</cfif>
	</cfquery>
	<cfreturn qcheckifBBhasGrowth />
	</cffunction>
<!---D39144 :: Autopay Recapture END --->
<!--- Get the total pullback amount that is applied for a given Dis Corp BB FROM the BB approved table --->
	<cffunction name="getPullbackAppliedInfo" output="false" returnType="query">
		<cfargument name="disBillbackId" required="true" type="string" />

		<cfquery name="qGetPullbackAppliedInfo" datasource="#application.datasource#">
			SELECT 	BB_Approved.Paid_Amount, BB_pullbacks_applied,
							ISNULL(Pullback_applied_Amount,0) AS Pullback_applied_Amount
			FROM 	BB_Approved
			WHERE 	BB_Approved.Billback_ID = <cfqueryparam value="#arguments.disBillbackId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfreturn qGetPullbackAppliedInfo />

	</cffunction>

	<cffunction name="ExecuteGrowthSP" output="false">
	<cfargument name="Dis_BB_Id" required="true" type="string" />
	<cfargument name="OPR_BB_Id" required="true" type="string" />

	<cfquery name="qExecuteGrowthSP" datasource="#application.datasource#">
	<!--- Execute this SP with the total invoice volume for all the products added to growth --->
		EXEC BB_PULLBACKS_GROWTH_RATE_DEV <cfqueryparam value="#arguments.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">,<cfqueryparam value="#arguments.OPR_BB_Id#" cfsqltype="CF_SQL_VARCHAR">,0
<!--- 	Execute this SP, with invoice volume -  total pullback volume for the products that matched the pullback log AND Dis Corp BB  --->
		EXEC BB_PULLBACKS_GROWTH_RATE_DEV <cfqueryparam value="#arguments.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">,<cfqueryparam value="#arguments.OPR_BB_Id#" cfsqltype="CF_SQL_VARCHAR">,1
	</cfquery>

	</cffunction>

<!--- Get the total Growth Pulllback Amount by subtracting the BB_Pullbacks_Growth_Program expected amount FROM the BB_Pullbacks_Growth_Program expected amount --->
	<cffunction name="GrowthPullbackAmount" output="false">
	<cfargument name="Dis_BB_Id" required="true" type="string" />
	<cfargument name="OPR_BB_Id" required="true" type="string" />
	<cfset returnvalue = 0>
	<cfquery name="qGrowthPullbackAmount" datasource="#application.datasource#">
		SELECT ISNULL((ISNULL(BB_Expected_Growth_Program.expected_amount,0) -
		ISNULL(BB_Pullbacks_Growth_Program.expected_amount,0)),0) AS GrowthAmount FROM
		BB_Expected_Growth_Program
		INNER JOIN BB_Pullbacks_Growth_Program
		ON BB_Expected_Growth_Program.billback_id = BB_Pullbacks_Growth_Program.billback_id
		AND BB_Expected_Growth_Program.pullback_billback_id =
		BB_Pullbacks_Growth_Program.pullback_billback_id
		WHERE BB_Expected_Growth_Program.billback_id = <cfqueryparam value="#arguments.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
		AND BB_Expected_Growth_Program.pullback_billback_id =  <cfqueryparam value="#arguments.OPR_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfset returnvalue = qGrowthPullbackAmount.GrowthAmount>
	<cfreturn returnvalue />
	</cffunction>

	<cffunction name="GrowthAppliedPullbackValues" output="false">
	<cfargument name="Dis_BB_Id" required="true" type="string" />
	<cfargument name="OPR_BB_Id" required="true" type="string" />
	<cfquery name="qGrowthAppliedPullbackValues" datasource="#application.datasource#">
		SELECT SUM(ISNULL(pullback_expected_dollars,0)) AS GrowthAmount,
		cast(SUM((product_BB_volume_LB * pullback_percent)/100) AS decimal(20,0)) AS GrowthVolume
		FROM pullbacks_log
		WHERE pullbacks_log.pullback_applied_to_billback_id = <cfqueryparam value="#arguments.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
		AND pullbacks_log.pullback_billback_id =  <cfqueryparam value="#arguments.OPR_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
		AND pullbacks_log.discount_type_id = 4
		AND pullbacks_log.deleted = 0
		AND pullbacks_log.pullback_applied = 1
	</cfquery>
	<cfreturn qGrowthAppliedPullbackValues />
	</cffunction>

	<cffunction name="GrowthPullbackVolume" output="false">
	<cfargument name="Dis_BB_Id" required="true" type="string" />
	<cfargument name="OPR_BB_Id" required="true" type="string" />
	<cfargument name="contract_number" required="true" type="string" />
	<cfset returnvalue = 0>
	<cfquery name="qGrowthPullbackVolume" datasource="#application.datasource#">
	SELECT cast(SUM((product_BB_volume_LB * pullback_percent)/100) AS decimal(20,0)) AS TotalVolume
		FROM pullbacks_log p1
		INNER JOIN billback_product bp1 ON
		bp1.product_id = p1.product_id
		INNER JOIN billback_product_detail ON
		bp1.billback_product_id = billback_product_detail.billback_product_id
		AND billback_product_detail.BB_product_type_id =  p1.discount_type_id
		WHERE p1.discount_type_id = 4 AND p1.pullback_applied = 0
		AND bp1.billback_id =  <cfqueryparam value="#arguments.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
		AND p1.pullback_billback_id =   <cfqueryparam value="#arguments.OPR_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
		AND p1.pullback_FROM_program_number =  <cfqueryparam value="#arguments.contract_number#" cfsqltype="CF_SQL_VARCHAR">
		AND p1.deleted = 0
	</CFQUERY>
	<cfset returnvalue = qGrowthPullbackVolume.TotalVolume>
	<cfreturn returnvalue />
	</cffunction>

<!--- Get the details of the products that were applied AS Growth Pullback Amount for a given Dis Corp BB AND Opr or local Dis BB --->
	<cffunction name="GetGrowthDetails" output="false">
	<cfargument name="Dis_BB_Id" required="true" type="string" />
	<cfargument name="OPR_BB_Id" required="true" type="string" />
	<cfargument name="TotalGrowthAmount" required="true" type="string" />
	<cfargument name="pullbacks_applied" required="false" type="boolean" default="0" />
		<cfquery name="qGetGrowthDetails" datasource="#application.datasource#">
		SELECT distinct pullback_billback_id,
		pullbacks_log.product_id,
		item,description,product_BB_volume_LB,
		pullback_percent,CM.contract_number,CM.revision_version,
		((product_BB_volume_LB * pullback_percent)/100) AS pullback_volume,
		<cfif arguments.pullbacks_applied EQ 0>
		(((product_BB_volume_LB * pullback_percent)/100) * #arguments.TotalGrowthAmount#)/(SELECT SUM((product_BB_volume_LB * pullback_percent)/100)
		FROM pullbacks_log p1
		INNER JOIN billback_product bp1 ON
		bp1.product_id = p1.product_id
		AND bp1.billback_id = billback.billback_id
		INNER JOIN billback_product_detail ON
		bp1.billback_product_id = billback_product_detail.billback_product_id
		AND bp1.deleted = 0
		AND billback_product_detail.BB_product_type_id =  p1.discount_type_id
		WHERE p1.discount_type_id = 4 AND p1.pullback_applied = 0 AND
		p1.pullback_billback_id =  pullbacks_log.pullback_billback_id
		AND p1.pullback_FROM_program_number = pullbacks_log.pullback_FROM_program_number
		AND p1.deleted = 0
		AND p1.customer_id = pullbacks_log.customer_id)
		<cfelse>
		SUM(ISNULL(pullback_expected_dollars,0))
		</cfif>
		AS pullbackamountperproduct
		FROM billback INNER JOIN
		billback_program ON billback_program.billback_id =
		billback.billback_id INNER JOIN
		contract_main ON contract_main.contract_main_id = billback_program.program_id
		INNER JOIN billback_product on
		billback_product.billback_id = billback.billback_id
		INNER JOIN pullbacks_log ON
		pullbacks_log.pullback_FROM_program_number= contract_main.contract_number
		AND billback_product.distributor_id = pullbacks_log.customer_id
		AND pullbacks_log.product_id = billback_product.product_id
		AND pullbacks_log.discount_type_id = 4
		INNER JOIN billback OPR_BB on
		OPR_BB.billback_id = pullbacks_log.pullback_billback_id
		INNER JOIN contract_main CM on
		CM.contract_main_id = pullbacks_log.pullback_program_id
		INNER JOIN BSA_Foodservice_items_master on
		BSA_Foodservice_items_master.BSA_Foodservice_items_master_id =
		pullbacks_log.product_id
		WHERE pullbacks_log.deleted = 0
		<cfif arguments.pullbacks_applied EQ 0>
		AND pullbacks_log.pullback_applied = 0
		<cfelse>
		AND pullbacks_log.pullback_applied = 1
		AND pullback_applied_to_billback_id = <cfqueryparam value="#arguments.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
		</cfif>
		AND pullbacks_log.pullback_billback_id = <cfqueryparam value="#OPR_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
		AND billback.billback_id =  <cfqueryparam value="#arguments.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
		group by pullback_billback_id,pullback_FROM_program_number,pullbacks_log.customer_id ,
		OPR_BB.BB_title,OPR_BB.bb_reference,OPR_BB.bb_code,OPR_BB.bb_start_date,OPR_BB.bb_end_date,
		pullbacks_log.product_id,item,description,product_BB_volume_LB,pullback_percent,billback.billback_id,
		CM.contract_number,CM.revision_version
		order by pullback_billback_id
		</cfquery>
	<cfreturn qGetGrowthDetails />
	</cffunction>

	<cffunction name="GetBillbacksDetails" output="false">
		<cfargument name="BB_Id" required="true" type="string" />
		<cfquery name="qGetBillbacksDetails" datasource="#application.datasource#">
		SELECT distinct BB_title,bb_reference,bb_code,contract_main.contract_number
		FROM billback
		INNER JOIN billback_program ON billback_program.billback_id =
		billback.billback_id INNER JOIN
		contract_main ON contract_main.contract_main_id = billback_program.program_id
		WHERE billback.billback_id = <cfqueryparam value="#arguments.BB_Id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
	<cfreturn qGetBillbacksDetails />
	</cffunction>

<!--- Check if any new distributors are added after the pullback rules are applied ON a Opr or Local Dis program --->
	<cffunction name="checkifdistributorsadded" output="false">
		<cfargument name="Pullback_Prg_Id" required="true" type="string" />
	<cfset returnValue = 0>
		<cfquery name="qcheckifdistributorsadded" datasource="#application.datasource#">
		SELECT count(*) AS distributorsadded
		FROM contract_distributors
		WHERE contract_distributors.deleted = 0 AND
		contract_distributors.contract_main_id = <cfqueryparam value="#arguments.Pullback_Prg_Id#" cfsqltype="CF_SQL_INTEGER">
		AND contract_distributors.bsa_foodservice_customers_id not in
		(SELECT distinct customer_id FROM
		pullback_details WHERE deleted = 0 AND
		opr_program_id =  <cfqueryparam value="#arguments.Pullback_Prg_Id#" cfsqltype="CF_SQL_INTEGER">)
		AND contract_distributors.bsa_foodservice_customers_id not in
		(SELECT distinct customer_id FROM
		Pullbacks_Distributors_Defaults WHERE pullback_program_id =  <cfqueryparam value="#arguments.Pullback_Prg_Id#" cfsqltype="CF_SQL_INTEGER">)
		</cfquery>

	<cfset returnValue = qcheckifdistributorsadded.distributorsadded>
	<cfreturn returnValue />
	</cffunction>

<!--- Check if any new distributors are added after the pullback rules are applied ON a Opr or Local Dis program --->
	<cffunction name="getDistributorsAddedList" output="false" returnType="query">
		<cfargument name="Pullback_Prg_Id" required="true" type="numeric" />

		<cfquery name="qGetDistributorsAddedList" datasource="#application.datasource#">
		SELECT 	distinct contract_distributors.bsa_foodservice_customers_id
		FROM 	contract_distributors
		WHERE 	contract_distributors.deleted = 0
		AND		contract_distributors.contract_main_id = <cfqueryparam value="#arguments.Pullback_Prg_Id#" cfsqltype="CF_SQL_INTEGER">
		AND 	contract_distributors.bsa_foodservice_customers_id not in
		(	SELECT 	distinct customer_id
			FROM	pullback_details
			WHERE 	deleted = 0
			AND		opr_program_id =  <cfqueryparam value="#arguments.Pullback_Prg_Id#" cfsqltype="CF_SQL_INTEGER">
		)
		AND 	contract_distributors.bsa_foodservice_customers_id not in
		(	SELECT 	distinct customer_id
			FROM	Pullbacks_Distributors_Defaults
			WHERE 	pullback_program_id =  <cfqueryparam value="#arguments.Pullback_Prg_Id#" cfsqltype="CF_SQL_INTEGER">
		)
		</cfquery>

		<cfreturn qGetDistributorsAddedList />
	</cffunction>

<!--- Check if any new distributors are removed after the pullback rules are applied ON a Opr or Local Dis program --->
	<cffunction name="checkifdistributorsremoved" output="false">
		<cfargument name="Pullback_Prg_Id" required="true" type="string" />

	<cfset returnValue = 0>
		<cfquery name="qcheckifdistributorsremoved" datasource="#application.datasource#">
		SELECT count(*) AS distributorsremoved
		FROM pullback_details
		WHERE deleted = 0 AND
		opr_program_id =  <cfqueryparam value="#arguments.Pullback_Prg_Id#" cfsqltype="CF_SQL_INTEGER">
		AND pullback_details.customer_id not in
		(SELECT distinct  bsa_foodservice_customers_id
		FROM contract_distributors
		WHERE contract_distributors.deleted = 0 AND
		contract_distributors.contract_main_id = <cfqueryparam value="#arguments.Pullback_Prg_Id#" cfsqltype="CF_SQL_INTEGER">)
		</cfquery>
	<cfset returnValue = qcheckifdistributorsremoved.distributorsremoved>
	<cfreturn returnValue />
	</cffunction>

<!--- Check if any new products are added after the pullback rules are applied ON a Opr or Local Dis program --->
	<cffunction name="checkifproductsadded" output="false">
	<cfargument name="Pullback_Prg_Id" required="true" type="string" />

	<cfset returnValue = 0>
		<cfquery name="qcheckifproductsadded" datasource="#application.datasource#">
		SELECT count(*) AS productsadded
		FROM contract_products
		WHERE contract_products.deleted = 0 AND
		contract_products.contract_main_id = <cfqueryparam value="#arguments.Pullback_Prg_Id#" cfsqltype="CF_SQL_INTEGER">
		AND contract_products.bsa_foodservice_items_master_id not in
		(SELECT distinct product_id
		FROM pullback_details WHERE deleted = 0 AND
		 opr_program_id =  <cfqueryparam value="#arguments.Pullback_Prg_Id#" cfsqltype="CF_SQL_INTEGER">)
		</cfquery>

	<cfset returnValue = qcheckifproductsadded.productsadded>
	<cfreturn returnValue />
	</cffunction>

<!--- Check if any new products are removed after the pullback rules are applied ON a Opr or Local Dis program --->
	<cffunction name="checkifproductsremoved" output="false">
	<cfargument name="Pullback_Prg_Id" required="true" type="string" />
	<cfset returnValue = 0>
		<cfquery name="qcheckifproductsremoved" datasource="#application.datasource#">
		SELECT count(*) AS productsremoved
		FROM
		pullback_details WHERE deleted = 0 AND
		opr_program_id =  <cfqueryparam value="#arguments.Pullback_Prg_Id#" cfsqltype="CF_SQL_INTEGER">
		AND product_id not in
		(SELECT distinct contract_products.bsa_foodservice_items_master_id FROM contract_products
		WHERE contract_products.deleted = 0 AND
		contract_products.contract_main_id = <cfqueryparam value="#arguments.Pullback_Prg_Id#" cfsqltype="CF_SQL_INTEGER">)
		</cfquery>

	<cfset returnValue = qcheckifproductsremoved.productsremoved>
	<cfreturn returnValue />
	</cffunction>

<!--- Check if any pullback rules are applied ON a Opr or Local Dis program --->
	<cffunction name="checkifanypullbacksapplied" output="false">
	<cfargument name="Pullback_Prg_Id" required="true" type="string" />
	<cfargument name="Customer_Id" required="false" type="string" default="" />

	<cfset returnValue = 0>
		<cfquery name="qcheckifanypullbacksapplied" datasource="#application.datasource#">
		SELECT count(*) AS pullbacksapplied
		FROM pullback_details
		WHERE opr_program_id = <cfqueryparam value="#arguments.Pullback_Prg_Id#" cfsqltype="CF_SQL_INTEGER">
		<cfif arguments.Customer_id NEQ "">
			AND Customer_id = <cfqueryparam value="#arguments.Customer_id#" cfsqltype="cf_sql_varchar">
		</cfif>
		AND pullback_details.deleted = 0
		</cfquery>

	<cfset returnValue = qcheckifanypullbacksapplied.pullbacksapplied>
	<cfreturn returnValue />
	</cffunction>

<!--- While deleting the BB, update the pullback log table to remove any pullbacks applied to the current Dis Corp BB --->
	<cffunction name="deleteBillbackPullbacks" output="false">
	<cfargument name="Dis_BB_Id" required="true" type="string" />
	<cfquery name="updateBBApprovedTable" datasource="#application.datasource#">
	update BB_approved
	set paid_amount  = Approved_Amount_Before_Pullbacks,
	Pullback_applied_Amount = 0,
	BB_pullbacks_applied = 1
	WHERE BB_approved.billback_id = <cfqueryparam value="#arguments.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfquery name="updatePullbacksLogTable" datasource="#application.datasource#">
	update Pullbacks_Log
	set pullback_applied  = 0,
	pullback_applied_to_billback_id = NULL,
	pullback_unapplied_date = getdate(),
	pullback_expected_dollars = 0,
	pullback_FROM_program_rate = 0
	WHERE Pullbacks_Log.pullback_applied_to_billback_id = <cfqueryparam value="#arguments.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	</cffunction>

	<cffunction name="getDefaultPullbackRate" output="false">
	<cfargument name="program_id" required="true" type="numeric" />
	<cfargument name="opr_templateId" required="true" type="numeric" />
	<cfquery name="qgetDefaultPullbackRate" datasource="#application.datasource#">
		SELECT isnull(Pullback_Default_Rate,100) AS Pullback_Default_Rate
		FROM template_pullback_program_defaults
		WHERE template_pullback_program_defaults.program_id =
		#arguments.program_id#
		AND template_pullback_program_defaults.Opr_Loc_Template_Id
		= '#arguments.opr_templateId#'
	</cfquery>
	<cfreturn qgetDefaultPullbackRate />
	</cffunction>

	<cffunction name="InsertDefaultsonRFA" output="true">
	<cfargument name="programId" required="true" type="numeric" />
	<cfargument name="userId" required="true" type="string" />

		<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />
		<cfset Program = CreateObject("component","components.programs.Program") />

		<cfset ProgramInfo = Program.getProgramInfo(arguments.programId)>

			<CFIF 	(
						(ProgramInfo.generic_type EQ "Distributor Trade/Shelter" AND ProgramInfo.is_pullback_corporate_deal EQ 0 AND ProgramInfo.pullback_FROM_corporate EQ 1)
						OR
						(ProgramInfo.generic_type EQ "Operator Direct or HQ Programs" OR ProgramInfo.generic_type EQ "Operator-Deviated Pricing")
					)
					AND ProgramInfo.Pullbacks_ON EQ 1>

					<cfset GetDistributors = PullbackManager.GetDistributorlist(arguments.programId,ProgramInfo.applied_pullbacks)>
					<cfif GetDistributors.recordcount GT 0>
						<cfloop query="GetDistributors">
						<!--- set cust id to local var since it is in an outer loop. --->
							<cfset CustomerId = GetDistributors.BSA_Foodservice_Customers_ID />

							<!--- If there are already pullbacks in Pullback_details, for this customer do nothing --->
							<cfset AlreadyPullbacksApplied = PullbackManager.checkifanypullbacksapplied(arguments.programId,CustomerId)>

						<!--- Only insert if there aren't any existing pullbacks --->
						<!---<cfif AlreadyPullbacksApplied EQ 0>
							<cfset getDisCorpPorgrams = PullbackManager.getDisCorpPorgrams(CustomerId,ProgramInfo.Contract_End_Date,ProgramInfo.Contract_Start_Date,ProgramInfo.pullback_template_type,0,arguments.programId,"contract_number","DESC",ProgramInfo.ProgramControl_Panel_Options_ID)>
							<cfif getDisCorpPorgrams.recordcount GT 0>

								<cfloop query="getDisCorpPorgrams">
									<cfset PullbackValue = getDisCorpPorgrams.Pullback_Value>
									<cfset GetProducts = PullbackManager.GetCurrentProductlist(arguments.programId,ProgramInfo.applied_pullbacks,GetDistributors.BSA_Foodservice_Customers_ID,getDisCorpPorgrams.Contract_Main_ID)>
									<!--- set cust prog id to local var since it is in an outer loop.  Insert wAS using value FROM first record only. --->
									<cfset Customer_program_id = getDisCorpPorgrams.contract_main_id />
									 <cfset Customer_contract_number = getDisCorpPorgrams.contract_number />
									 <cfset qItemlist = PullbackManager.GetProductlist(Customer_program_id) >
									 <cfset corpItemList = ValueList(qItemlist.BSA_Foodservice_items_master_id)>
									<cfloop query="GetProducts">
										<CFIF Listfind(corpItemList,GetProducts.BSA_Foodservice_items_master_id) >
											<cfset useLakebaseForinsertDisPullbackRates = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pullback_details")>
<cfif useLakebaseForinsertDisPullbackRates>
	<cftry>
		<cfset application.oLakebase.insertRow("pullback_details", {
			"customer_id" = "#CustomerId#",
			"customer_program_id" = "#Customer_program_id#",
			"product_id" = "#GetProducts.BSA_Foodservice_Items_Master_ID#",
			"opr_program_id" = "#arguments.programId#",
			"pullback" = "1",
			"pullback_value" = "#PullbackValue#",
			"pullbacks_created_by" = "#arguments.userId#",
			"opr_contract_number" = "#ProgramInfo.contract_number#",
			"customer_contract_number" = "#Customer_contract_number#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsertDisPullbackRates = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsertDisPullbackRates>
<cfquery name="insertDisPullbackRates" datasource="#application.datasource#">
												INSERT INTO Pullback_Details
												(
													Customer_id,
													Customer_program_id,
													Product_Id,
													Opr_Program_Id,
													Pullback,
													Pullback_Value,
													pullbacks_created_by,
													opr_contract_number,
													customer_contract_number

												)
												VALUES
												(
													'#CustomerId#',
													#Customer_program_id#,
													'#GetProducts.BSA_Foodservice_Items_Master_ID#',
													#arguments.programId#,
													1,
													#PullbackValue#,
													'#arguments.userId#',
													'#ProgramInfo.contract_number#',
													'#Customer_contract_number#'
												)
											</cfquery>
</cfif>
										</CFIF>
									<!--- Product list--->
									</cfloop>

								<!--- Distributor program list --->
								</cfloop>
							<!--- There are distributor programs --->

							</cfif>
						<!--- There aren't any existing pullbacks MOVED FROM BELOW So WE still INSERT Pullbacks_Distributors_Defaults--->
							</cfif>
							--->
							 <!--- Save the default pullback values for each distributor, so that if any new Dis Corp or Local Dis deals are created after this Opr program got approved, we would use these default values to make an entry in the pullback_details table when the Dis Corp or Local Dis Deals are approved --->
								<!--- <cfset opr_template_id = this.GetcontractDetails(arguments.programId).ProgramControl_Panel_Options_id />
								<cfset dispullbackdefaultvalue = this.getDefaultPullbackRate(arguments.programId,opr_template_id,getDisCorpPorgrams.ProgramControl_Panel_Options_ID) /> --->
								<cfquery name="insertDisPullbackfaultsTable" datasource="#application.datasource#">
									delete FROM Pullbacks_Distributors_Defaults
									WHERE Pullback_Program_Id = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER" />
									AND Customer_id = <cfqueryparam value="#CustomerId#" cfsqltype="CF_SQL_VARCHAR" />

									insert into Pullbacks_Distributors_Defaults
										(Pullback_Program_Id,
										Customer_id,
										Pullback,
										Pullback_Default_Value,
										created_by)
									values
										(#arguments.programId#,
										'#CustomerId#',
										1,
										'100',
										'#arguments.userId#')
								</cfquery>
						<!---- Distributor list --->
						</cfloop>
					<!--- There are distributors --->
					</cfif>

				<!--- There aren't any existing pullbacks WAS HERE...MOVED UP--->
			<!--- INSERT DEFAULTS WHEN CORPORATE DEAL IS RFA
			<cfelseif ProgramInfo.Pullbacks_ON EQ 1 AND ProgramInfo.generic_type EQ "Distributor Trade/Shelter" >
				<cfset getPullbackPorgrams = PullbackManager.getPullbackPorgrams(CustomerId,ProgramInfo.Contract_End_Date,ProgramInfo.Contract_Start_Date,ProgramInfo.pullback_template_type,0,arguments.programId,"contract_number","DESC",ProgramInfo.ProgramControl_Panel_Options_ID)>
			--->
			<!--- Other pullback criteria --->
			</cfif>
	</cffunction>

<!---D39144 :: Autopay Recapture START --->
	<cffunction name="GetBillbackstoApplyPullback" output="false">
		<cfargument name="Dis_BB_Id" 					required="true" 	type="string" />
		<cfargument name="OPR_BB_Id" 				required="false" 	type="string" 			default="" />
		<cfargument name="appliedpullbacks" 	required="false" 	type="boolean" 	default="0" />
		<cfargument name="sSearch" 						required="false" 	type="string" 			default="" />
		<cfargument name="sSortDir" 						required="false" 	type="string" 			default="ASC" />
		<cfargument name="iSortCol" 						required="false" 	type="string" 			default="bb_start_date" />
		<cfargument name="fromcheckboxes" 		required="false" 	type="boolean" 	default="0" />

		<cfquery name="CheckIfSplit" datasource="#application.datasource#">
				SELECT *
				FROM Billback
				WHERE Billback_ID = <cfqueryparam value="#arguments.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfset Parent_Billback_ID = arguments.Dis_BB_Id / >
		<CFIF CheckIfSplit.BB_Is_Child EQ 1>
			<cfset Parent_Billback_ID = CheckIfSplit.BB_Parent_ID / >
		</CFIF>

	<cfset additionalSortColumns = "Operator_Name,pullback_amount,product_BB_volume_CS,bb_start_date,bb_end_date,Contract_Title,name,bb_code">
	<cfif arguments.fromcheckboxes EQ 0>
		<cfset additionalSortColumns = #replace(additionalSortColumns,arguments.iSortCol,'','ALL')#>
	</cfif>

		<cfquery name="qGetBillbackstoApply" datasource="#application.datasource#">

		<!--- For unapplied pullbacks, we need to calculate the budget recapture amount based ON current autopay billback --->
		IF OBJECT_ID('tempdb..##tmp_product_dist_price') IS NOT NULL
		DROP TABLE ##tmp_product_dist_price

		CREATE TABLE ##tmp_product_dist_price (Product_ID uniqueidentifier, Distributor_ID uniqueidentifier, Gross_Price decimal(20, 4), Net_Price decimal(20, 8))

		IF OBJECT_ID('tempdb..##tmp_pullback_apply_unapply_list') IS NOT NULL
		DROP TABLE ##tmp_pullback_apply_unapply_list

		IF OBJECT_ID('tempdb..##tmp_bb_products') IS NOT NULL
		DROP TABLE ##tmp_bb_products

		IF OBJECT_ID('tempdb..##tmp_Operators') IS NOT NULL
		DROP TABLE ##tmp_Operators


		<cfif arguments.appliedpullbacks eq 0 AND application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetsFunctionalityOn()>
			DECLARE @Budget_Recapture_Rate_Logic bit,
					@Auto_Pay_Net_Of_Cash_Discount bit,
					@Auto_Pay_Net_Of_Freight_Allowance bit

			SELECT	@Budget_Recapture_Rate_Logic = 1,
							@Auto_Pay_Net_Of_Cash_Discount = rcn.Auto_Pay_Net_Of_Cash_Discount,
							@Auto_Pay_Net_Of_Freight_Allowance = rcn.Auto_Pay_Net_Of_Freight_Allowance
			FROM	Billback b
			INNER JOIN Billback_Program_Rebate_Component br
			ON		br.Billback_Id = b.Billback_ID
			AND		br.Deleted = 0
			AND		br.checked = 'true'
			INNER JOIN Program_Rebates_Component_Name rcn
			ON		rcn.Program_Rebates_Component_Name_ID = br.Program_Rebates_Component_Name_ID
			AND		rcn.Recapture_Rate_FROM_Program_Budget = 1
			WHERE	b.Billback_ID = <cfqueryparam value="#Parent_Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND		b.Auto_Billback = 1

			<!--- Only when rebate component hAS recapture FROM budget flag ON --->
			IF @Budget_Recapture_Rate_Logic = 1
			BEGIN
				<!--- Store the data for later use --->
				INSERT INTO ##tmp_product_dist_price (Product_ID, Distributor_ID, Gross_Price, Net_Price)
				SELECT	Product_ID, Distributor_ID_Earned,
								Gross_Price = Cast(avg(l.Sales_Dollars / l.Pounds_Invoiced) AS decimal(20, 4)),
								Net_Price = Cast(avg(
								(l.Sales_Dollars
								- (case @Auto_Pay_Net_Of_Cash_Discount when 1 then isnull(l.Freight_Revenue,0) else 0 end)
								- (case @Auto_Pay_Net_Of_Freight_Allowance when 1 then isnull(l.Cash_Discount, 0) else 0 end)
								) / l.Pounds_Invoiced) AS decimal(20, 4))
				FROM	BB_Auto_Accrual_Log l
				WHERE	l.BB_ID = <cfqueryparam value="#Parent_Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
				GROUP BY Product_ID, Distributor_ID_Earned
			END
		</cfif>

		<!--- Get distinct list of products. Auto pay can have duplicates in billback_product table, it stores one row for negative quantity and another row for positive quantity --->
		<cfif arguments.appliedpullbacks eq 0>
		SELECT  DISTINCT billback_program.billback_program_id, BB_Item_Final.distributor_id, billback_product.product_id, bb_item_final_detail.BB_Product_type, paid_rate_lb
		INTO 	##tmp_bb_products
		FROM	billback
		INNER JOIN billback_program
		ON		billback_program.billback_id = billback.billback_id
		AND		billback_program.Deleted = 0
		INNER JOIN BB_Item_Final
		ON		BB_Item_Final.billback_id = billback.billback_id
		AND 	BB_Item_Final.deleted = 0
		INNER JOIN bb_item_final_detail
		ON		bb_item_final_detail.BB_Item_Final_id = BB_Item_Final.BB_Item_Final_id
		AND 	bb_item_final_detail.deleted = 0
		INNER JOIN billback_product
		ON		billback_product.billback_product_ID = BB_Item_Final.billback_product_ID
		AND 	billback_product.Deleted = 0
		WHERE	billback.deleted = 0
		AND		billback.billback_id = <cfqueryparam value="#Parent_Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND BB_Item_Final.Item_Total_Paid >= 0

		INSERT INTO 	##tmp_bb_products (billback_program_id, distributor_id, product_id, BB_Product_type, paid_rate_lb)
		SELECT  DISTINCT billback_program.billback_program_id, BB_Item_Final.distributor_id, billback_product.product_id, bb_item_final_detail.BB_Product_type, paid_rate_lb

		FROM	billback
		INNER JOIN billback_program
		ON		billback_program.billback_id = billback.billback_id
		AND		billback_program.Deleted = 0
		INNER JOIN BB_Item_Final
		ON		BB_Item_Final.billback_id = billback.billback_id
		AND 	BB_Item_Final.deleted = 0
		INNER JOIN bb_item_final_detail
		ON		bb_item_final_detail.BB_Item_Final_id = BB_Item_Final.BB_Item_Final_id
		AND 	bb_item_final_detail.deleted = 0
		INNER JOIN billback_product
		ON		billback_product.billback_product_ID = BB_Item_Final.billback_product_ID
		AND 	billback_product.Deleted = 0
		WHERE	billback.deleted = 0
		AND		billback.billback_id = <cfqueryparam value="#Parent_Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		and BB_Item_Final.Item_Total_Paid < 0
		AND NOT EXISTS(SELECT product_id FROM ##tmp_bb_products tmp where
						tmp.distributor_id = BB_Item_Final.distributor_id and
						tmp.product_id = billback_product.product_id and
						tmp.billback_program_id = billback_program.billback_program_id and
						tmp.BB_Product_type = bb_item_final_detail.BB_Product_type)
		</cfif>

		SELECT  	pullback_billback_id,
						CAST(null as varchar(200)) as Operator_Name,
						CAST(0 as bit) as Operator_Is_group,
						CAST(0 as int) as Operator_Count,
						pullback_FROM_program_number,
						CM.Contract_Title,
						OPR_BB.bb_reference,
						OPR_BB.bb_code,
						OPR_BB.bb_start_date,
						OPR_BB.bb_end_date,
				<cfif arguments.appliedpullbacks eq 0>
						SUM(CAST(ISNULL((((CAST(ISNULL(product_BB_volume_LB,0) as decimal(20, 4)) * ISNULL(pullback_percent,0))/100) * CAST(ISNULL(paid_rate_lb,0) as decimal(20, 8))),0)
						--- Calculate budget recapture amount when unapplied
						- (isnull(
						CAST(
							CASE Budget_Recapture_Rate_UOM
							WHEN 1 THEN pullbacks_log.Budget_Recapture_Rate / CAST(BSA_Foodservice_items_master.Net_Weight AS float) --CS
							WHEN 2 THEN pullbacks_log.Budget_Recapture_Rate -- LB
							WHEN 9 THEN pullbacks_log.Budget_Recapture_Rate * BSA_Foodservice_items_master.Case_Equivalent / CAST(BSA_Foodservice_items_master.Net_Weight AS float) --CS
							WHEN 31 THEN pr.Gross_Price * pullbacks_log.Budget_Recapture_Rate * 0.01 * pullbacks_log.product_BB_volume_LB -- % Gross $
							WHEN 32 THEN pr.Net_Price * cast(pullbacks_log.Budget_Recapture_Rate as decimal(20,8)) * 0.01 * pullbacks_log.product_BB_volume_LB -- % Net $
							END
							 as decimal(20, 4))
						, 0)) as decimal(20, 2)))
				<cfelse>
						ISNULL(SUM(isnull(pullback_expected_dollars,0)),0)
				</cfif> AS pullback_amount,
						cast(SUM(cast(product_BB_volume_LB AS float) / cast(BSA_Foodservice_items_master.net_weight AS decimal(20,4))) AS decimal(20,4)) AS product_BB_volume_CS,
						CM.contract_number,
						MAX(CM.contract_main_id) AS CMID,
						----CM.revision_version,
						pullbacks_log.customer_id,
						BSA_Foodservice_Customers.shr_ship_to,
						BSA_Foodservice_Customers.name
		INTO ##tmp_pullback_apply_unapply_list
		FROM billback
		INNER JOIN billback_program
		ON 		billback_program.billback_id = billback.billback_id
		AND		billback_program.Deleted = 0
		INNER JOIN contract_main
		ON 	contract_main.contract_main_id = billback_program.program_id
		INNER JOIN Program_Control_Panel_Options t
		ON	t.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
		<cfif arguments.appliedpullbacks eq 0>
		LEFT JOIN ##tmp_bb_products bbprod
		ON bbprod.billback_program_id = billback_program.billback_program_id
		</cfif>
		INNER JOIN pullbacks_log
		ON
		<cfif arguments.appliedpullbacks eq 1>
		Pullback_Applied_To_Billback_Id = <cfqueryparam value="#arguments.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
		AND pullbacks_log.pullback_applied = 1
		<cfelse>
		pullbacks_log.pullback_FROM_program_number= contract_main.contract_number
		AND pullbacks_log.customer_id = bbprod.distributor_id
		AND pullbacks_log.product_id = bbprod.product_id
		AND pullbacks_log.discount_type_id = bbprod.BB_Product_type
		AND pullbacks_log.deleted = 0
		AND pullbacks_log.pullback_applied = 0
		</cfif>
		INNER JOIN Discount_Type
		ON Discount_Type.discount_type_id = pullbacks_log.discount_type_id
		INNER JOIN billback OPR_BB
		ON OPR_BB.billback_id = pullbacks_log.pullback_billback_id
		AND OPR_BB.deleted = 0
		INNER JOIN contract_main CM
		ON CM.contract_main_id = pullbacks_log.pullback_program_id
		INNER JOIN BSA_Foodservice_items_master
		ON BSA_Foodservice_items_master.BSA_Foodservice_items_master_id = pullbacks_log.product_id
		LEFT JOIN Billback_Program_Rebate_Component
		ON Billback_Program_Rebate_Component.billback_id = billback.billback_id
		AND pullbacks_log.component_id = Billback_Program_Rebate_Component.Program_Rebates_Component_name_id
		AND Billback_Program_Rebate_Component.deleted = 0
		AND Billback_Program_Rebate_Component.checked = 'true'
		INNER JOIN BSA_Foodservice_Customers
		ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = pullbacks_log.customer_id
		<cfif arguments.appliedpullbacks eq 0>
		LEFT JOIN ##tmp_product_dist_price pr
		ON pr.Distributor_ID = pullbacks_log.Customer_Id
		AND pr.Product_ID = pullbacks_log.Product_ID
		</cfif>
		WHERE billback.deleted = 0
		AND	billback.billback_id = <cfqueryparam value="#Parent_Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND   pullback_billback_id != <cfqueryparam value="#Parent_Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
 <cfif arguments.appliedpullbacks eq 0>
		AND contract_main.Pullback_FROM_This_Program =  1
		AND t.Pullbacks_On = 1
		AND (pullbacks_log.discount_type_id <> 2 or Billback_Program_Rebate_Component.billback_id is not null)
</cfif>
<cfif arguments.appliedpullbacks eq 1>
		AND Pullback_Applied_To_Billback_Id = <cfqueryparam value="#arguments.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
</cfif>
<cfif len(trim(arguments.sSearch))>
		AND (
					(OPR_BB.bb_code like '%#arguments.sSearch#%')
					OR
					(BSA_Foodservice_Customers.name like '%#arguments.sSearch#%')
					OR
					(BSA_Foodservice_Customers.shr_ship_to like '%#arguments.sSearch#%')
					OR
					(CM.contract_number like '%#arguments.sSearch#%')
					OR
					(CM.Contract_Title like '%#arguments.sSearch#%')
				)
</cfif>
		GROUP BY pullback_billback_id,pullback_FROM_program_number,CM.Contract_Title,
							OPR_BB.bb_reference,OPR_BB.bb_code,OPR_BB.bb_start_date,OPR_BB.bb_end_date,
							CM.contract_number,pullbacks_log.customer_id, BSA_Foodservice_Customers.shr_ship_to, BSA_Foodservice_Customers.name
	<cfif arguments.fromcheckboxes EQ 0>
		-- Get all operators from the operator program
		SELECT 		DISTINCT CO.Contract_Main_ID,
							CASE CO.Is_Group
							WHEN 1 THEN PGOC.PG_Operator_Category_Name
							ELSE BSA.Operator_Name
							END AS Operator_name,
							CO.Is_Group,
							DENSE_RANK() OVER(PARTITION BY CO.Contract_Main_ID ORDER BY CASE CO.Is_Group WHEN 1 THEN PGOC.PG_Operator_Category_Name ELSE BSA.Operator_Name END) as Row_Num,
							CAST(0 as Int) as Cnt
		INTO			##tmp_Operators
		FROM  		##tmp_pullback_apply_unapply_list
		INNER JOIN 	Contract_Operators CO
		ON					CO.Contract_Main_ID = ##tmp_pullback_apply_unapply_list.CMID
		AND        		CO.Deleted = 0
		AND         		CO.Captured_From_Group = 0
		LEFT JOIN 		BSA_Operator BSA
		ON	        		BSA.BSA_Operator_ID = CO.BSA_Operator_ID
		AND        		CO.Is_Group = 0
		LEFT JOIN 		PG_Operator_Category PGOC
		ON          		PGOC.PG_Operator_Category_ID = CO.Operator_Group_ID
		AND         		CO.Is_Group = 1

		-- Get count of operators in the operator program
		UPDATE	##tmp_Operators
		SET		Cnt = GetCount.Cnt
		FROM	##tmp_Operators
		INNER JOIN (
									SELECT	Contract_Main_ID, COUNT(*) as Cnt
									FROM	##tmp_Operators
									GROUP BY Contract_Main_ID
								) as GetCount
		ON	##tmp_Operators.Contract_Main_ID = GetCount.Contract_Main_ID

		-- Update main query with operators details
		UPDATE	##tmp_pullback_apply_unapply_list
		SET		Operator_Name = ##tmp_Operators.Operator_Name,
					Operator_Is_Group = ##tmp_Operators.Is_Group,
					Operator_Count = ##tmp_Operators.Cnt
		FROM	##tmp_pullback_apply_unapply_list
		INNER JOIN ##tmp_Operators
		ON	##tmp_Operators.Contract_Main_ID = ##tmp_pullback_apply_unapply_list.CMID
	</cfif>

		SELECT   *
		FROM 	##tmp_pullback_apply_unapply_list
		<cfif arguments.appliedpullbacks eq 1>
		WHERE 1 = 1
		<cfelse>
		WHERE pullback_amount <> 0
		</cfif>
		<cfif len(trim(arguments.sSearch))>
			AND (
					(bb_code like '%#arguments.sSearch#%')
					OR
					(name like '%#arguments.sSearch#%')
					OR
					(shr_ship_to like '%#arguments.sSearch#%')
					OR
					(contract_number like '%#arguments.sSearch#%')
					OR
					(Contract_Title like '%#arguments.sSearch#%')
					OR
					(Operator_Name like '%#arguments.sSearch#%')
				)
		</cfif>
		<cfif arguments.fromcheckboxes EQ 0>
		ORDER BY #arguments.iSortCol# #arguments.sSortDir#
			<cfloop list="#additionalSortColumns#" index="Additional" delimiters=",">
				,#Additional# #arguments.sSortDir#
			</cfloop>
		</cfif>
		IF OBJECT_ID('tempdb..##tmp_pullback_apply_unapply_list') IS NOT NULL
		DROP TABLE ##tmp_pullback_apply_unapply_list

		IF OBJECT_ID('tempdb..##tmp_Operators') IS NOT NULL
		DROP TABLE ##tmp_Operators

		IF OBJECT_ID('tempdb..##tmp_product_dist_price') IS NOT NULL
		DROP TABLE ##tmp_product_dist_price
		</cfquery>

	<cfreturn qGetBillbackstoApply />
	</cffunction>
<!---D39144 :: Autopay Recapture END --->

	<cffunction name="getRecaptureOperatorPGlist" returntype="query" output="false">
		<cfargument name="ContractNumber" required="true"  />
		<cfargument name="programID" required="true"  />
		<cfargument name="editMode" required="true" />

		<cfquery name="qGetRecaptureOperatorPGlist" datasource="#application.datasource#">
			SELECT DISTINCT
			  PGOC.PG_Operator_Category_ID,
			  PGOC.PG_Operator_Category_Code,
			  PGOC.PG_Operator_Category_Name,
			  PGT.PG_Type_Name,
			  CASE WHEN RPOL.PG_Operator_Category_ID IS NOT NULL
					THEN 1
			  ELSE 0
			  END
			  As PG_Exists
			FROM	PG_Operator_Category PGOC
			INNER JOIN PG_Type PGT ON PGT.PG_Type_ID = PGOC.PG_Type_ID
			LEFT JOIN Recapture_Program_Operator_List RPOL
			ON RPOL.PG_Operator_Category_ID = PGOC.PG_Operator_Category_ID
			AND RPOL.Contract_Number = '#arguments.ContractNumber#'
			<!--- For "PG category" selection, make sure that the record is deleted = 0 and active = 1
			and "For_Recapture" setting is ON on "PG_Operator_Category" table.
			If the "PG category" is already saved, then no need to look for these, as these settings cam change.
			--->
			WHERE
			(
			RPOL.PG_Operator_Category_ID IS NOT NULL
			OR
			(PGOC.Active = 1 AND PGOC.Deleted = 0 AND PGOC.For_Recapture = 1)
			)
			<!--- For approved programs, only show the saved entries. --->
			<cfif editMode eq 0>
			AND RPOL.PG_Operator_Category_ID IS NOT NULL
			</cfif>
			ORDER BY PG_Operator_Category_Name ASC
		</cfquery>

		<cfreturn qGetRecaptureOperatorPGlist>

	</cffunction>

	<cffunction name="getRecaptureOperatorPGlistExists" returntype="boolean" output="false">
		<cfargument name="ContractNumber" required="true"  />

		<cfset bPGForRecaptureExists = 0>

		<cfquery name="qGetRecaptureOperatorPGlistExists" datasource="#application.datasource#">
			SELECT 1
			FROM Recapture_Program_Operator_List
			WHERE Contract_Number = '#arguments.ContractNumber#'

			UNION

			SELECT 1
			FROM Recapture_Program_Template_List
			WHERE Contract_Number = '#arguments.ContractNumber#'
		</cfquery>

		<cfif qGetRecaptureOperatorPGlistExists.recordcount>
			<cfset bPGForRecaptureExists = 1>
		</cfif>

		<cfreturn bPGForRecaptureExists>

	</cffunction>

	<cffunction name="saveRecaptureOperatorPGlist" returntype="void" output="false">
		<cfargument name="ContractNumber" required="true"  />
		<cfargument name="programID" required="true"  />
		<cfargument name="PGOperatorCategoryIDList" required="true"  />
		<cfargument name="userID" required="true"  />

			<cfset useLakebaseForqDeleteRecaptureOperatorPGlist = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("recapture_program_operator_list")>
<cfif useLakebaseForqDeleteRecaptureOperatorPGlist>
	<cftry>
		<cfset application.oLakebase.deleteRows("recapture_program_operator_list", {
			"contract_number" = "eq.#arguments.ContractNumber#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqDeleteRecaptureOperatorPGlist = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeleteRecaptureOperatorPGlist>
<cfquery name="qDeleteRecaptureOperatorPGlist" datasource="#application.datasource#">
				DELETE FROM Recapture_Program_Operator_List
				WHERE Contract_Number = '#arguments.ContractNumber#'
			</cfquery>
</cfif>

			<cfloop list="#arguments.PGOperatorCategoryIDList#" index="i">
				<cfquery name="qeRecaptureOperatorPGlist" datasource="#application.datasource#">
					INSERT INTO Recapture_Program_Operator_List(Contract_Number, PG_Operator_Category_ID, Created_By)
					VALUES('#arguments.ContractNumber#','#i#','#arguments.userID#')
				</cfquery>
				<cfset useLakebaseForqeRecaptureOperatorPGlistHistory = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("recapture_program_operator_list_history")>
<cfif useLakebaseForqeRecaptureOperatorPGlistHistory>
	<cftry>
		<cfset application.oLakebase.insertRow("recapture_program_operator_list_history", {
			"contract_number" = "#arguments.ContractNumber#",
			"source_contract_main_id" = "#arguments.programID#",
			"pg_operator_category_id" = "#i#",
			"created_by" = "#arguments.userID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqeRecaptureOperatorPGlistHistory = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqeRecaptureOperatorPGlistHistory>
<cfquery name="qeRecaptureOperatorPGlistHistory" datasource="#application.datasource#">
					INSERT INTO Recapture_Program_Operator_List_History(Contract_Number, Source_Contract_Main_ID, PG_Operator_Category_ID, Created_By)
					VALUES('#arguments.ContractNumber#','#arguments.programID#','#i#','#arguments.userID#')
				</cfquery>
</cfif>
			</cfloop>
	</cffunction>


	<cffunction name="getRecaptureTemplatelist" returntype="query" output="false">
		<cfargument name="ContractNumber" required="true"  />
		<cfargument name="editMode" required="true" />

		<cfquery name="qGetRecaptureTemplatelist" datasource="#application.datasource#">
		Declare @recordExist INT

			SELECT @recordExist = count(*)
			FROM Recapture_Program_Template_List_History
			WHERE Contract_Number = '#arguments.ContractNumber#'

			SELECT PCPO.Created_Type
			, PCPO.Generic_Type
			, PCPO.Program_Description
			, PCPO.Template_In_Program_LH_Recapture_Link_Default
			, PCPO.ProgramControl_Panel_Options_ID
			, PCPO.First_Parent_ID
			, CASE
					WHEN @recordExist = 0 THEN PCPO.Template_In_Program_LH_Recapture_Link_Default
					WHEN RPTL.First_Parent_ID IS NOT NULL THEN 1
			  ELSE 0
			  END
			  As Template_Exists
			FROM Program_Control_Panel_Options PCPO
			LEFT JOIN Recapture_Program_Template_List RPTL
			ON RPTL.Contract_Number = '#arguments.ContractNumber#'
			AND RPTL.First_Parent_ID = PCPO.First_Parent_ID
			WHERE PCPO.Template_In_Program_LH_Recapture_Link = 1
			AND PCPO.IsDominant = 1
			AND PCPO.Deleted = 0
			<cfif editMode eq 0>
			AND RPTL.First_Parent_ID IS NOT NULL
			</cfif>
			Order by 1 asc
		</cfquery>

		<cfreturn qGetRecaptureTemplatelist>

		</cffunction>

		<cffunction name="saveRecaptureTemplatelist" returntype="void" output="false">
		<cfargument name="ContractNumber" required="true"  />
		<cfargument name="programID" required="true"  />
		<cfargument name="FirstParentID" required="true"  />
		<cfargument name="userID" required="true"  />

			<cfquery name="qDeleteRecaptureOperatorPGlist" datasource="#application.datasource#">
				DELETE FROM Recapture_Program_Template_List
				WHERE Contract_Number = '#arguments.ContractNumber#'
			</cfquery>

			<cfloop list="#arguments.FirstParentID#" index="i">
				<cfquery name="qeRecaptureOperatorPGlist" datasource="#application.datasource#">
					INSERT INTO Recapture_Program_Template_List(Contract_Number, First_Parent_ID, Created_By)
					VALUES('#arguments.ContractNumber#','#i#','#arguments.userID#')
				</cfquery>
				<cfquery name="qeRecaptureOperatorPGlistHistory" datasource="#application.datasource#">
					INSERT INTO Recapture_Program_Template_List_History(Contract_Number, Source_Contract_Main_ID, First_Parent_ID, Created_By)
					VALUES('#arguments.ContractNumber#','#arguments.programID#','#i#','#arguments.userID#')
				</cfquery>
			</cfloop>
	</cffunction>

		<cffunction name="FirstTimeRecaptureTemplatelist" returntype="void" output="false">
		<cfargument name="ContractNumber" required="true"  />
		<cfargument name="programID" required="true"  />
		<cfargument name="userID" required="true"  />

			<cfset useLakebaseForqRecaptureOperatorPGlist = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("recapture_program_template_list_history")>
<cfif useLakebaseForqRecaptureOperatorPGlist>
	<cftry>
		<cfset qRecaptureOperatorPGlist = application.oLakebase.toQuery(
			application.oLakebase.selectRows("recapture_program_template_list_history", {
				"contract_number" = "eq.#arguments.ContractNumber#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqRecaptureOperatorPGlist = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqRecaptureOperatorPGlist>
<cfquery name="qRecaptureOperatorPGlist" datasource="#application.datasource#">
				Select *
				FROM Recapture_Program_Template_List_History
				WHERE Contract_Number = '#arguments.ContractNumber#'
			</cfquery>
</cfif>

			<cfif qRecaptureOperatorPGlist.recordcount EQ 0>
				<cfquery name="qeRecaptureOperatorPGlistHistory" datasource="#application.datasource#">
					INSERT INTO Recapture_Program_Template_List_History(Contract_Number, Source_Contract_Main_ID, First_Parent_ID, Created_By)
					VALUES('#arguments.ContractNumber#','#arguments.programID#','0','#arguments.userID#')
				</cfquery>
			</cfif>
	</cffunction>

</cfcomponent>