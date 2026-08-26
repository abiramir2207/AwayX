<!------<cfparam name="Scheduled" default="0">----->

<!---Gets application settings--->
<cfparam name="isdateexclusion" default="0">
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfparam name="form.EZTemplate" default="0">
<cfset EZCheckProgramAndTemplate = 0 />
<cfparam name="form.SUPPRESSPRODUCTSDISTRIBUTORS" default="0">
<cfparam name="Copy_Revise" default="1">

<!--- QUERIES TO GET DATA --->
<CFPARAM NAME="Program_ID_To_Replicate" DEFAULT="0">
<CFPARAM NAME="this.ProgramType_ID" DEFAULT="0">
<CFPARAM NAME="form.IsRevisionOfExistingContract" DEFAULT="0">
<CFPARAM NAME="form.ISROLLOVER" DEFAULT="0">
<CFPARAM NAME="form.ForceFreightOnAutoCopy" DEFAULT="0">  <!--- Dev Note: KAL; 16694 --->
<CFPARAM NAME="CheckForActiveProductsOnly" DEFAULT="0"> 	<!--- Dev Note: KAL; 8362 --->
<cfset actual_Program_ID_To_Replicate = Program_ID_To_Replicate />
<cfparam name="Responsible_User_Id" default="">

	<!--- Basic Information - Contract_Main --->
	<CFQUERY NAME="getContractInfo" datasource="#application.datasource#">
		SELECT     *, dbo.Contract_Main_Aux_Data.Comments, dbo.Contract_Main_Aux_Data.Forecast_ID
		FROM         dbo.Contract_Main INNER JOIN
		                      dbo.Contract_Main_Aux_Data ON dbo.Contract_Main.Contract_Main_ID = dbo.Contract_Main_Aux_Data.Contract_Main_ID
		WHERE dbo.Contract_Main.Contract_Main_ID = '#Program_ID_To_Replicate#'
	</CFQUERY>
	
	<cfif Responsible_User_Id eq "">
		<cfset Responsible_User_Id = getContractInfo.Responsible_User_Id>
	</cfif>
	
	<!---handle for the ProgramType_ID--->
	<cfif getContractInfo.RecordCount>
		<cfset this.ProgramType_ID = getContractInfo.ProgramType_ID />
	</cfif>
	
<cfif isdateexclusion EQ 0>
	<cfset useLakebaseForgettemplateparent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForgettemplateparent>
	<cftry>
		<cfset gettemplateparent = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#this.ProgramType_ID#",
				"select" = "template_parent_id,ez_contract_id"
			}), "template_parent_id,ez_contract_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgettemplateparent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgettemplateparent>
<cfquery name="gettemplateparent" datasource="#application.datasource#">
		SELECT template_parent_id,EZ_Contract_Id
		FROM Program_Control_Panel_Options
		WHERE ProgramControl_Panel_Options_ID = '#this.ProgramType_ID#'
	</cfquery>
</cfif>

	<cfif gettemplateparent.template_parent_id NEQ 0>
		<cfset useLakebaseForgetContractTemplateDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForgetContractTemplateDetails>
	<cftry>
		<cfset getContractTemplateDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"template_parent_id" = "eq.#gettemplateparent.template_parent_id#",
				"isdominant" = "eq.1",
				"deleted" = "eq.0",
				"order" = "programcontrol_panel_options_id.desc",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetContractTemplateDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetContractTemplateDetails>
<cfquery name="getContractTemplateDetails" datasource="#application.datasource#">
			SELECT top 1 * 
			FROM Program_Control_Panel_Options
			WHERE template_parent_id = #gettemplateparent.template_parent_id#
			and isdominant =1
			and deleted = 0
			ORDER BY ProgramControl_Panel_Options_ID desc
		</cfquery>
</cfif>
	<cfelseif gettemplateparent.template_parent_id EQ 0>
		<cfquery name="getContractTemplateDetails" datasource="#application.datasource#">
			SELECT TOP 1 * from
			Program_Control_Panel_Options
			where template_parent_id = '#this.ProgramType_ID#'
			and isdominant =1
			and deleted = 0
			ORDER BY ProgramControl_Panel_Options_ID desc
		</cfquery>
	</cfif><!--- end: gettemplateparent.template_parent_id NEQ 0 --->
	
	<cfif getContractTemplateDetails.recordcount EQ 0>
		<cfquery name="getContractTemplateDetails" datasource="#application.datasource#">
			SELECT *
			FROM Program_Control_Panel_Options
			WHERE ProgramControl_Panel_Options_ID = '#this.ProgramType_ID#'
		</cfquery>
	<cfelse>
		<cfset this.ProgramType_ID = getContractTemplateDetails.ProgramControl_Panel_Options_ID>
	</cfif><!--- end: getContractTemplateDetails.recordcount EQ 0 --->
<cfelse><!--- else: isdateexclusion EQ 0 --->
	<cfquery name="getContractTemplateDetails" datasource="#application.datasource#">
		SELECT *
		FROM Program_Control_Panel_Options
		WHERE ProgramControl_Panel_Options_ID = '#this.ProgramType_ID#'
	</cfquery>
</cfif><!--- end: isdateexclusion EQ 0 --->

<cfset form.EZTemplate = getContractTemplateDetails.EZButton_on /> <!--- the form variable was getting lost when we come through the RSP form --->

<!--- get Similar Products  (Dev Note: Milan; D7226) --->
<cfset ProdManager = CreateObject("component", "components.products.ProductManager").init()>
<cfset SimilarProductsList = ProdManager.getSimilarExistingProduct(Program_ID_To_Replicate)>
<!--- End Note: Milan; D7226 --->

<!--- get Competitive Data only for revisions and rollovers (not copy)  (Dev Note: Milan; D10697) --->
<cfif  Form.IsRevisionOfExistingContract EQ 1 OR Form.IsRollover EQ 1>
<cfset bidRequestProdMan = CreateObject("component", "components.programs.bid_request.BidRequestProductManager") />
<cfset getCompetitiveProductsInfo = bidRequestProdMan.getCompetitiveData(Program_ID_To_Replicate)>
<cfelse>
<!--- For copy - to avoid an error --->
<cfset getCompetitiveProductsInfo  = QueryNew("Previous_Won_By,Previous_Won_Price,Previous_Won_Uom,Previous_Won_Delivery_Type,Created_By,Product_ID")>
</cfif>
<!--- End Note: Milan; D10697 --->

<!--- 	get Program_Accounting_Specialist details --->
<cfif application.returned_customer_setting.Accounting_Specialist eq 1>
	<cfset useLakebaseForgetContractAccountingSpecialist = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_accounting_specialist")>
<cfif useLakebaseForgetContractAccountingSpecialist>
	<cftry>
		<cfset getContractAccountingSpecialist = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_accounting_specialist", {
				"program_id" = "eq.#Program_ID_To_Replicate#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetContractAccountingSpecialist = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetContractAccountingSpecialist>
<CFQUERY NAME="getContractAccountingSpecialist" datasource="#application.datasource#">
		select * from
		Program_Accounting_Specialist
		where program_id = '#Program_ID_To_Replicate#'
		and deleted = 0
	</CFQUERY>
</cfif>
</cfif>
	
<cfif getContractTemplateDetails.Specify_Operators EQ 1>
	<!--- contract_operators --->
	<CFQUERY NAME="getContractOperators" datasource="#application.datasource#">
		SELECT contract_operators.*
		FROM Contract_Operators
		<cfif form.IsRevisionOfExistingContract EQ 0>
		inner join BSA_Operator on
		BSA_Operator.BSA_Operator_id = Contract_Operators.BSA_Operator_id
		</cfif>
		WHERE Contract_Main_ID = '#Program_ID_To_Replicate#' AND Contract_Operators.Deleted = 0
		<cfif form.IsRevisionOfExistingContract EQ 0>
		and BSA_Operator.deleted = 0
		</cfif>
	</CFQUERY>
</cfif>

	<!--- contract_brokers --->
<!--- Ana: D15113 - Commenting the below CFIF condition --->
<!--- <cfif getContractTemplateDetails.Specify_Brokers EQ 1> --->
	<cfset useLakebaseForgetContractBrokers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_brokers")>
<cfif useLakebaseForgetContractBrokers>
	<cftry>
		<cfset getContractBrokers = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_brokers", {
				"contract_main_id" = "eq.#Program_ID_To_Replicate#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetContractBrokers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetContractBrokers>
<CFQUERY NAME="getContractBrokers" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Brokers
		WHERE Contract_Main_ID = '#Program_ID_To_Replicate#' AND Deleted = 0
	</CFQUERY>
</cfif>
<!--- </cfif> --->

<cfif Form.suppressProductsDistributors EQ 0>
	
	<!--- contract_Distributors --->
	<cfif getContractTemplateDetails.Specify_Distributors EQ 1>
	<cfset DistGroupManager = CreateObject("component", "components.programs.distributors.DistributorGroupManager").init() />
	<cfparam name="Is_Group" default="#getContractTemplateDetails.Specify_Distributor_Groups#" />
	<cfparam name="donotcheckforgroups" default="1" />
	<cfset enableExtraGroupSearch = 0 />
	<cfset enableExtraDistSearch = 0 />
	<cfif appSettings.getSearchSequenceOn() AND len(trim(getContractInfo.Search_Sequence_ID)) GT 0>
		<cfset  SearchSequenceManager 	= CreateObject("component", "components.Search_Sequence.SearchSequenceManager").init() />
		<cfset 	Program_Search_Sequence 	= SearchSequenceManager.getSearchSequenceInfo(getContractInfo.Search_Sequence_ID) />
		<cfset enableExtraGroupSearch = SearchSequenceManager.enableDistributorGroupSelection(Program_Search_Sequence) />
		<cfset enableExtraDistSearch = SearchSequenceManager.enableDistributorSelection(Program_Search_Sequence) />
	</cfif>
	<cfif enableExtraDistSearch EQ 1 AND enableExtraGroupSearch EQ 1>
		<cfset donotcheckforgroups = 1>
	<cfelseif enableExtraDistSearch EQ 1>
		<cfset Is_group = 0 />
		<cfset donotcheckforgroups = 0>
	<cfelseif enableExtraGroupSearch EQ 1>
		<cfset Is_group = 1 />
		<cfset donotcheckforgroups = 0>
	</cfif>
	

		<!------ D10537: If the program is a revision, we will not be removing inactive customers, and so we do not need to adjust the weight ----->
		<cfif form.IsRevisionOfExistingContract EQ 0>

			<!---  Dev Note: CPM 9102 Get the Total and Inactive Counts from Contract_Distributors --->
			<cfquery name="getDistributorCounts" datasource="#application.datasource#">
				Select count(*) AS "Contract_Distributors_Count"
					from contract_distributors 
					where deleted = 0 and contract_main_id = '#Program_ID_To_Replicate#'
			</cfquery>
			
			<cfquery name="getInactiveDistributorCounts" datasource="#application.datasource#">
				SELECT	COUNT(*) AS "Inactive_Contract_Distributors_Count",
						SUM(CAST(Program_Weight AS FLOAT)) AS "Total_Removed_Weight"
				FROM	Contract_Distributors 
						LEFT OUTER JOIN bsa_foodservice_customers ON 
						BSA_Foodservice_Customers.BSA_Foodservice_Customers_id = Contract_Distributors.BSA_Foodservice_Customers_id
						LEFT JOIN All_Customer_Group_Types ON
						All_Customer_Group_Types.Distributor_Group_Level_ID = Contract_Distributors.Distributor_Group_Level_ID AND
						CAST(All_Customer_Group_Types.Group_GUID AS VARCHAR(50)) = Contract_Distributors.Distributor_Group_ID AND
						All_Customer_Group_Types.Deleted = 0
				WHERE	BSA_Foodservice_Customers.deleted = 0 
				AND		Contract_Distributors.deleted = 0 
				AND		BSA_Foodservice_Customers.ship_to IS NOT NULL 
				AND		Contract_Distributors.Contract_Main_ID = '#Program_ID_To_Replicate#'
				AND		Contract_distributors.captured_from_group = 0
				AND		(
							(BSA_Foodservice_Customers.active_code <> 'A' OR BSA_Foodservice_Customers.Deleted <> 0) 
						OR 
							contract_distributors.Is_Group = 1
						)
				AND		(
							(Contract_Distributors.is_group = 0 AND Contract_Distributors.Captured_From_Group = 0)
						OR	
							All_Customer_Group_Types.Group_GUID IS NULL
						)
			</cfquery>
			
			<cfquery name="getActiveDistributorCounts" datasource="#application.datasource#">
				SELECT	COUNT(*) AS "Active_Contract_Distributors_Count",
						SUM(CAST(Program_Weight AS FLOAT)) AS "Total_Remaining_Weight"
				FROM	Contract_Distributors 
						LEFT OUTER JOIN BSA_Foodservice_Customers ON 
						BSA_Foodservice_Customers.BSA_Foodservice_Customers_id = Contract_Distributors.BSA_Foodservice_Customers_id
						LEFT JOIN All_Customer_Group_Types ON
						All_Customer_Group_Types.Distributor_Group_Level_ID = Contract_Distributors.Distributor_Group_Level_ID AND
						CAST(All_Customer_Group_Types.Group_GUID AS VARCHAR(50)) = Contract_Distributors.Distributor_Group_ID AND
						All_Customer_Group_Types.Deleted = 0
				WHERE	Contract_Distributors.Contract_Main_ID = '#Program_ID_To_Replicate#'
				AND		Contract_Distributors.deleted = 0 
				AND		BSA_Foodservice_Customers.ship_to IS NOT NULL 
				AND		BSA_Foodservice_Customers.deleted = 0 
				AND		Contract_distributors.captured_from_group = 0
				AND		(
							(BSA_Foodservice_Customers.active_code = 'A' AND BSA_Foodservice_Customers.Deleted = 0) 
						OR 
							contract_distributors.Is_Group = 1
						)
				AND		(
							(Contract_Distributors.is_group = 0 AND Contract_Distributors.Captured_From_Group = 0)
						OR	
							All_Customer_Group_Types.Group_GUID IS NOT NULL
						)
			</cfquery>
			
		</cfif>
	
		<CFQUERY NAME="getContractDistributors" datasource="#application.datasource#">
			SELECT
			Contract_Distributors.Contract_Distributors_ID, 
			Contract_Distributors.BSA_Foodservice_Customers_ID, 
			Contract_Distributors.Contract_Main_ID, 
			Contract_Distributors.Deleted, 
			<!------ if the program is a revision, we will not be removing inactive customers, and so we do not need to adjust the weight ----->
			<cfif form.IsRevisionOfExistingContract EQ 0>
				<cfif (getDistributorCounts.Contract_Distributors_Count - getInactiveDistributorCounts.Inactive_Contract_Distributors_Count) EQ 1>
					'100.00'
				<cfelseif (getDistributorCounts.Contract_Distributors_Count - getInactiveDistributorCounts.Inactive_Contract_Distributors_Count) EQ getDistributorCounts.Contract_Distributors_Count>
					Contract_Distributors.Program_Weight
				<cfelseif len(getActiveDistributorCounts.Total_Remaining_Weight) EQ 0>
					CAST(Program_Weight AS Float)
				<cfelse>
					100.00 * (CAST(Program_Weight AS Float) / #getActiveDistributorCounts.Total_Remaining_Weight#)	
				</cfif>
			<cfelse>
				CAST(Program_Weight AS Float)
			</cfif>
			 AS Program_Weight,
			Contract_Distributors.Distributor_Group_Level_ID, 
			Contract_Distributors.Distributor_Group_ID, 
			Contract_Distributors.Is_Group, 
			Contract_Distributors.Dynamic_Static_Groups, 
			Contract_Distributors.Captured_From_Group,
			<cfif form.IsRevisionOfExistingContract EQ 0><!---- copy ---->
			ISNULL(BSA_Foodservice_Customers.Warehouse_Master_ID, 0) as Warehouse_Master_ID,
			ISNULL(BSA_Foodservice_Customers.Warehouse_Master_ID, 0) as Default_Warehouse_Master_ID,
			0 as Overridden_Warehouse_Master_ID
			<cfelse><!---- revision ---->
			Contract_Distributors.Warehouse_Master_ID,
			Contract_Distributors.Default_Warehouse_Master_ID,
			Contract_Distributors.Overridden_Warehouse_Master_ID
			</cfif>
			FROM Contract_Distributors
			<cfif form.IsRevisionOfExistingContract EQ 0>
			inner join BSA_Foodservice_Customers on
			BSA_Foodservice_Customers.BSA_Foodservice_Customers_id = Contract_Distributors.BSA_Foodservice_Customers_id
			LEFT JOIN All_Customer_Group_Types ON
			All_Customer_Group_Types.Distributor_Group_Level_ID = Contract_Distributors.Distributor_Group_Level_ID AND
			CAST(All_Customer_Group_Types.Group_GUID AS VARCHAR(50)) = Contract_Distributors.Distributor_Group_ID AND
			All_Customer_Group_Types.Deleted = 0
			</cfif>
			WHERE Contract_Main_ID = '#Program_ID_To_Replicate#' AND Contract_Distributors.Deleted = 0 AND len(Contract_Distributors.Program_Weight) > 0
			<cfif form.IsRevisionOfExistingContract EQ 0>
			AND		(
						(BSA_Foodservice_Customers.active_code = 'A' AND BSA_Foodservice_Customers.Deleted = 0) 
					OR 
						Contract_Distributors.Is_Group = 1
					)
			AND		(
						(Contract_Distributors.is_group = 0 AND Contract_Distributors.Captured_From_Group = 0)
					OR	
						All_Customer_Group_Types.Group_GUID IS NOT NULL
					)
			</cfif>
			<cfif donotcheckforgroups EQ 0>
				<cfif Is_group EQ 1>
				and (Contract_Distributors.is_group = 1 or Contract_Distributors.Captured_From_Group = 1)
				</cfif>
				<cfif Is_group EQ 0>
				and Contract_Distributors.is_group = 0
				</cfif>
			</cfif>
		</CFQUERY>	
	</cfif>
	
		<!--- contract_Attachments --->
		<CFQUERY NAME="getContractAttachments" datasource="#application.datasource#">
			SELECT *
			FROM Contract_Attachments
			WHERE Program_ID = #Program_ID_To_Replicate# AND Deleted = 0
		</CFQUERY>
		
	 	<!--- Auto Renew --->
		<cfif getContractTemplateDetails.Auto_Renew_Option EQ 1>
		<cfset useLakebaseForgetAutoRenew = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_auto_renew")>
<cfif useLakebaseForgetAutoRenew>
	<cftry>
		<cfset getAutoRenew = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_auto_renew", {
				"program_id" = "eq.#Program_ID_To_Replicate#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetAutoRenew = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetAutoRenew>
<CFQUERY NAME="getAutoRenew" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Program_Auto_Renew
			WHERE 	Program_ID = '#Program_ID_To_Replicate#'
			AND		Deleted = 0
		</CFQUERY>
</cfif> 
		</cfif>
	<!---   Sysco deal sheets --->
		 <cfset useLakebaseForqSyscoDealSheets = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("sysco_deal_sheet_programs")>
<cfif useLakebaseForqSyscoDealSheets>
	<cftry>
		<cfset qSyscoDealSheets = application.oLakebase.toQuery(
			application.oLakebase.selectRows("sysco_deal_sheet_programs", {
				"contract_main_id" = "eq.#Program_ID_To_Replicate#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqSyscoDealSheets = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqSyscoDealSheets>
<cfquery name="qSyscoDealSheets" datasource="#application.datasource#">
			SELECT * FROM Sysco_Deal_Sheet_Programs
			WHERE Contract_Main_ID = '#Program_ID_To_Replicate#'
			AND Deleted = 0
		</cfquery>
</cfif> 
		
		<!--- 5.0 fixed freight --->
		<!--- If revision of guaranteed template, copy over values from parent version ---->
		<cfif (form.IsRevisionOfExistingContract EQ 1 and getContractTemplateDetails.Fixed_Type eq 0) or (FORM.ForceFreightOnAutoCopy EQ 1)>
		<cfset useLakebaseForgetProgramDistributorFreight = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_distributor_freight")>
<cfif useLakebaseForgetProgramDistributorFreight>
	<cftry>
		<cfset getProgramDistributorFreight = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_distributor_freight", {
				"program_id" = "eq.#Program_ID_To_Replicate#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetProgramDistributorFreight = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetProgramDistributorFreight>
<CFQUERY NAME="getProgramDistributorFreight" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Program_Distributor_Freight
			WHERE 	Program_ID = #Program_ID_To_Replicate# AND Deleted = 0
		</CFQUERY>
</cfif>
		</cfif>
		
		<!--- If the template is an EZ Template, 
			while revising the original program, 
				- products, rates, components, distributor and operators should be picked up from the original program 
			while copying or roll over, 
				- distributor and operators should be picked up from original program 
				- get component details which can be edited in the program from the original program (paid to, claim mech for fixed and rebate)
				- get component details which cannot be edited in the program from the template (claim mech for lump sum, lumpsum amount, rate)
				- get products which are there in both original program and the template
			 --->
		<cfif 		form.EZTemplate EQ 1 
			<!---and 	gettemplateparent.EZ_Contract_Id NEQ getContractTemplateDetails.EZ_Contract_Id --->
			and 	form.IsRevisionOfExistingContract EQ 0>
			<cfset Program_ID_To_Replicate = getContractTemplateDetails.EZ_Contract_Id>
			<cfset EZCheckProgramAndTemplate = 1 />
		</cfif>
		<!--- contract_products --->
		<cfif getContractTemplateDetails.Restrict_On_Approval_Group>
			<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
			<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo(appSettings.getTemplateRestrictGroupLevel()) />
		</cfif>
		
		
		<cfif form.IsRevisionOfExistingContract EQ 1><!--- revision --->
            
			<cfset programObj = createObject("component", "components.programs.program").getProgramInfo(Program_ID_To_Replicate) />
		     
		    <cfif programObj.Contract_Status_Type_IDX eq 8>
			  <cfset bidRequestManager = CreateObject("component", "components.programs.bid_request.BidRequestManager").applyStatus(Program_ID_To_Replicate,3) />
			</cfif>
		<CFQUERY NAME="getContract_Products" datasource="#application.datasource#">
			SELECT 	distinct Contract_Products.*
			FROM 	Contract_Products
			<cfif getContractTemplateDetails.Restrict_On_Approval_Group>
			inner join bsa_foodservice_items_master on
			bsa_foodservice_items_master.bsa_foodservice_items_master_id = 
			Contract_Products.bsa_foodservice_items_master_id
			inner join Template_Allow_Approval_Group On 
			Template_Allow_Approval_Group.Group_ID =  
			CASE 

			-- Is a product
			WHEN Contract_Products.Is_Group = 0
				THEN  bsa_foodservice_items_master.#approvalGroupType.IDFIELD#

				-- Is a group, but same group type as the group type in the template, so we can filter out
				WHEN Contract_Products.Is_Group = 1 and Contract_Products.Product_Group_Level_ID = #approvalGroupType.GROUPLEVELID#

				THEN Contract_Products.bsa_foodservice_items_master_id

				-- Is a group, but diff group type as the group type in the template, so we cannot filter out

			ELSE

			Template_Allow_Approval_Group.Group_ID

			END

			and Template_Allow_Approval_Group.Program_Type_ID = #getContractTemplateDetails.ProgramControl_Panel_Options_ID#
			</cfif>
			WHERE 	Contract_Main_ID = '#Program_ID_To_Replicate#' AND Contract_Products.Deleted = 0
					AND 
					(
						<!------ Group ----->
						(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
					) 
					and (Contract_Products.product_type_id = 1 
				<cfif getContractTemplateDetails.Discount_Rebates_Item_Level EQ 1>
				OR (Contract_Products.product_type_id = 2 and Contract_Products.Is_Group = 0)
				</cfif>
				<cfif getContractTemplateDetails.Discount_Rebates_Group_Level EQ 1>
				OR (Contract_Products.product_type_id = 2 and Contract_Products.Is_Group = 1)
				</cfif>
				<cfif getContractTemplateDetails.Discount_Lump_Sums_Item_Level EQ 1>
				OR (Contract_Products.product_type_id = 3 and Contract_Products.Is_Group = 0)
				</cfif>
				<cfif getContractTemplateDetails.Discount_Lump_Sums_Group_Level EQ 1>
				OR (Contract_Products.product_type_id = 3 and Contract_Products.Is_Group = 1)
				</cfif>
				<cfif getContractTemplateDetails.Discount_Growth_Item_Level EQ 1>
				OR (Contract_Products.product_type_id = 4 and Contract_Products.Is_Group = 0)
				</cfif>
				<cfif getContractTemplateDetails.Discount_Growth_Group_Level EQ 1>
				OR (Contract_Products.product_type_id = 4 and Contract_Products.Is_Group = 1)
				</cfif>
				OR (Contract_Products.product_type_id = 5)
				OR (Contract_Products.product_type_id = 8)
				OR (Contract_Products.product_type_id = 9)
				OR (Contract_Products.product_type_id = 10)
			)
		</CFQUERY>
		<cfelse><!--- copy --->
		<CFQUERY NAME="getContract_Products" datasource="#application.datasource#">
			SELECT 	distinct Contract_Products.*
			FROM 	Contract_Products
			inner join BSA_Foodservice_items_master
			on Contract_Products.BSA_Foodservice_items_master_id = BSA_Foodservice_items_master.BSA_Foodservice_items_master_id
			<cfif getContractTemplateDetails.Restrict_On_Approval_Group EQ 1>
			inner join Template_Allow_Approval_Group On 
			Template_Allow_Approval_Group.Group_ID =  
			CASE 

			-- Is a product
			WHEN Contract_Products.Is_Group = 0
				THEN  bsa_foodservice_items_master.#approvalGroupType.IDFIELD#

				-- Is a group, but same group type as the group type in the template, so we can filter out
				WHEN Contract_Products.Is_Group = 1 and Contract_Products.Product_Group_Level_ID = #approvalGroupType.GROUPLEVELID#

				THEN Contract_Products.bsa_foodservice_items_master_id

				-- Is a group, but diff group type as the group type in the template, so we cannot filter out

			ELSE

			Template_Allow_Approval_Group.Group_ID

			END

			and Template_Allow_Approval_Group.Program_Type_ID = #getContractTemplateDetails.ProgramControl_Panel_Options_ID#
			</cfif>
			<cfif appSettings.getClassCodesOn()>
			<!--- Dev Note: 12632; Milan. If the user's access to the set of class code changes, then make sure that the products 
			belonging to only the new set of class codes get copied over. This rule does not apply to revisions. --->
				INNER JOIN User_Class_Code
				ON User_Class_Code.Class_Code_Id = 
				CASE 
				WHEN Contract_Products.Product_Group_Level_ID IN (0,9) THEN 
				BSA_Foodservice_items_master.Class_Code_Id
				ELSE
				User_Class_Code.Class_Code_Id
				END
				AND User_Class_Code.Deleted = 0
				AND User_Class_Code.User_Id = '#Responsible_User_Id#'
				INNER JOIN Class_Code
				ON Class_Code.Class_Code_UUID = 
				CASE Contract_Products.Product_Group_Level_ID
				WHEN 10 THEN 
				Contract_Products.BSA_Foodservice_Items_Master_ID
				ELSE
				Class_Code.Class_Code_UUID
				END
				AND User_Class_Code.Class_Code_Id = Class_Code.Class_Code_Id
			</cfif>
			<cfif EZCheckProgramAndTemplate eq 1><!--- copy of ez button program --->
			<!--- on ez program copy (EZCheckProgramAndTemplate = 1), 
			- get products which are there in both original program and the template
			--->
			INNER JOIN Contract_Products as Contract_Products_EZ_Original_Program
			ON	Contract_Products_EZ_Original_Program.Deleted = 0
			AND	Contract_Products_EZ_Original_Program.Contract_Main_ID = '#actual_Program_ID_To_Replicate#'
			AND	Contract_Products_EZ_Original_Program.product_Type_ID = Contract_Products.product_Type_ID
			AND	Contract_Products_EZ_Original_Program.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
			</cfif>
			<!--- Dev Note: Milan;18088 - "All_Product_Group_Types" table stores all the groups and has a
				  "deleted" field, which we look at to make sure we include valid groups only.	  
			 --->
			LEFT JOIN All_Product_Group_Types ON
			All_Product_Group_Types.Product_Group_Level_ID = Contract_Products.Product_Group_Level_ID				
			AND CAST(All_Product_Group_Types.Group_GUID AS VARCHAR(50)) = Contract_Products.Product_Group_ID 
			
			WHERE 	Contract_Products.Contract_Main_ID = '#Program_ID_To_Replicate#' AND Contract_Products.Deleted = 0
					AND 
					(
						<!------ Group ----->
						(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1 AND All_Product_Group_Types.Deleted = 0)
						OR
						<!------ Product ----->
						(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
					) 
			and ((BSA_Foodservice_items_master.active_code = 'A' AND BSA_Foodservice_items_master.Deleted = 0) OR Contract_Products.Is_Group = 1)
					and (Contract_Products.product_type_id = 1 
				<cfif getContractTemplateDetails.Discount_Rebates_Item_Level EQ 1>
				OR (Contract_Products.product_type_id = 2 and Contract_Products.Is_Group = 0)
				</cfif>
				<cfif getContractTemplateDetails.Discount_Rebates_Group_Level EQ 1>
				OR (Contract_Products.product_type_id = 2 and Contract_Products.Is_Group = 1)
				</cfif>
				<cfif getContractTemplateDetails.Discount_Lump_Sums_Item_Level EQ 1>
				OR (Contract_Products.product_type_id = 3 and Contract_Products.Is_Group = 0)
				</cfif>
				<cfif getContractTemplateDetails.Discount_Lump_Sums_Group_Level EQ 1>
				OR (Contract_Products.product_type_id = 3 and Contract_Products.Is_Group = 1)
				</cfif>
				<cfif getContractTemplateDetails.Discount_Growth_Item_Level EQ 1>
				OR (Contract_Products.product_type_id = 4 and Contract_Products.Is_Group = 0)
				</cfif>
				<cfif getContractTemplateDetails.Discount_Growth_Group_Level EQ 1>
				OR (Contract_Products.product_type_id = 4 and Contract_Products.Is_Group = 1)
				</cfif>
				OR (Contract_Products.product_type_id = 5)
				OR (Contract_Products.product_type_id = 8)
				OR (Contract_Products.product_type_id = 9)
				OR (Contract_Products.product_type_id = 10)
			)
			AND	Contract_Products.product_type_id <> 2 -- we do not have to copy rebat eas it is done inside the cfc completely
		</CFQUERY>
		</cfif>
		<CFSET ListOfProductIDs = valuelist(getContract_Products.Contract_Products_ID)>
		<CFIF Listlen(ListOfProductIDs) EQ 0><CFSET ListOfProductIDs = 0></CFIF>
		
	
		
		<!--- FIXED PRICE PRODUCTS --->
		<cfset Contract_Products_ID_Fixed_Price = "" />
		<CFIF getContractTemplateDetails.Discount_Fixed_Prices EQ 1>
		<cfif EZCheckProgramAndTemplate eq 1><!--- copy of ez button program --->
				<!--- on ez program copy, 
				- get component which are in both original program and the template
				- get component details which can be edited in the program from the original program (paid to, claim mech)
				- get component details which cannot be edited in the program from the template (rate)
				- get products which are there in both original program and the template
				- get the rate from the template
				--->
				<CFQUERY NAME="get_Fixed_Price_Components" datasource="#application.datasource#">
				SELECT 	Program_Fixed_Component.Program_Fixed_Component_ID,<!--- from template --->
						Program_Fixed_Component_EZ_Original_Program.Program_ID,
						Program_Fixed_Component_EZ_Original_Program.Fixed_Component_Paid_to,
						Program_Fixed_Component_EZ_Original_Program.Deleted,
						Program_Fixed_Component_EZ_Original_Program.Created_Date,
						Program_Fixed_Component_EZ_Original_Program.Program_Fixed_Component_Name_ID,
						Program_Fixed_Component_EZ_Original_Program.Claim_Mechanics,
						Program_Fixed_Component_EZ_Original_Program.Basis_Code_Master_ID,
						Program_Fixed_Component_EZ_Original_Program.Treatment_Code_Master_ID
				FROM 	Program_Fixed_Component
	
				INNER JOIN Program_Fixed_Component as Program_Fixed_Component_EZ_Original_Program
				ON		Program_Fixed_Component_EZ_Original_Program.Deleted = 0
				AND		Program_Fixed_Component_EZ_Original_Program.program_id = '#actual_Program_ID_To_Replicate#'
				AND		Program_Fixed_Component_EZ_Original_Program.Program_Fixed_Component_Name_ID = Program_Fixed_Component.Program_Fixed_Component_Name_ID
				
				WHERE 	Program_Fixed_Component.Deleted = 0
				AND		Program_Fixed_Component.program_id = '#Program_ID_To_Replicate#'			
			</CFQUERY>
		<cfelse><!--- regular program --->
			<CFQUERY NAME="get_Fixed_Price_Components" datasource="#application.datasource#">
				SELECT *
				FROM Program_Fixed_Component
				WHERE 
				program_id = '#Program_ID_To_Replicate#'
				AND Deleted = 0
			</CFQUERY>
		</cfif>
		
		<cfset fixed_component_id = ValueList(get_Fixed_Price_Components.Program_Fixed_Component_ID) />
		
		<!------ 
		Using temp table to improve performance,
		we had issue in p****v where pricing docs were loading lot of data into fixed and contract products table and was causing slowness
		 ----->
		<!--- on ez program copy (EZCheckProgramAndTemplate = 1), 
		- get component which are in both original program and the template
		- get component details which can be edited in the program from the original program (paid to, claim mech)
		- get component details which cannot be edited in the program from the template (rate)
		- get products which are there in both original program and the template
		- get the rate from the template
		--->
		<CFQUERY NAME="get_Fixed_Price_Products" datasource="#application.datasource#">
			<cfif EZCheckProgramAndTemplate eq 1><!--- copy of ez button program --->
			CREATE TABLE ##Tmp_Program_Product_EZ_Original_Program
			(
				Contract_Products_ID Int,
				Product_ID uniqueidentifier,
				product_Type_ID Int
			)
			INSERT INTO ##Tmp_Program_Product_EZ_Original_Program
			SELECT	DISTINCT Contract_Products_ID, Contract_Products.BSA_Foodservice_Items_Master_ID, product_Type_ID
			FROM	Contract_Products
			WHERE	Contract_Products.Contract_Main_ID = '#actual_Program_ID_To_Replicate#'
			AND 	Contract_Products.product_Type_ID = 1
			AND 	Contract_Products.Deleted = 0
			AND		Contract_Products.Captured_From_Group = 0
			</cfif>
			
			CREATE TABLE ##Tmp_Program_Product
			(
				Contract_Products_ID Int,
				Product_ID uniqueidentifier,
				product_Type_ID Int
			)
			
			INSERT INTO ##Tmp_Program_Product
			SELECT	DISTINCT Contract_Products_ID, Contract_Products.BSA_Foodservice_Items_Master_ID, product_Type_ID
			FROM	Contract_Products
			<cfif form.IsRevisionOfExistingContract EQ 0 OR getContractTemplateDetails.Restrict_On_Approval_Group EQ 1>
			inner join BSA_Foodservice_Items_Master on 
			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = 
			Contract_Products.BSA_Foodservice_Items_Master_ID
			<cfif form.IsRevisionOfExistingContract EQ 0>
			<cfif appSettings.getClassCodesOn()>
			<!--- Dev Note: 12632; Milan. If the user's access to the set of class code changes, then make sure that the products 
			belonging to only the new set of class codes get copied over. This rule does not apply to revisions. --->
				INNER JOIN User_Class_Code
				ON User_Class_Code.Class_Code_Id = 
				CASE 
				WHEN Contract_Products.Product_Group_Level_ID IN (0,9) THEN 
				BSA_Foodservice_items_master.Class_Code_Id
				ELSE
				User_Class_Code.Class_Code_Id
				END
				AND User_Class_Code.Deleted = 0
				AND User_Class_Code.User_Id = '#Responsible_User_Id#'
				INNER JOIN Class_Code
				ON Class_Code.Class_Code_UUID = 
				CASE Contract_Products.Product_Group_Level_ID
				WHEN 10 THEN 
				Contract_Products.BSA_Foodservice_Items_Master_ID
				ELSE
				Class_Code.Class_Code_UUID
				END
				AND User_Class_Code.Class_Code_Id = Class_Code.Class_Code_Id
			</cfif>
			</cfif>
			</cfif>
			<cfif getContractTemplateDetails.Restrict_On_Approval_Group EQ 1>
			inner join Template_Allow_Approval_Group On 
			Template_Allow_Approval_Group.Group_ID =  
			CASE 

			-- Is a product
			WHEN Contract_Products.Is_Group = 0
				THEN  bsa_foodservice_items_master.#approvalGroupType.IDFIELD#

				-- Is a group, but same group type as the group type in the template, so we can filter out
				WHEN Contract_Products.Is_Group = 1 and Contract_Products.Product_Group_Level_ID = #approvalGroupType.GROUPLEVELID#

				THEN Contract_Products.bsa_foodservice_items_master_id

				-- Is a group, but diff group type as the group type in the template, so we cannot filter out

			ELSE

			Template_Allow_Approval_Group.Group_ID

			END

			and Template_Allow_Approval_Group.Program_Type_ID = #getContractTemplateDetails.ProgramControl_Panel_Options_ID#
			</cfif>
			WHERE
			Contract_Products.Contract_Main_ID = '#Program_ID_To_Replicate#'
			AND Contract_Products.product_Type_ID = 1
			AND Contract_Products.Deleted = 0
			AND 
					(
						<!------ Group ----->
						(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
					) 
			<cfif form.IsRevisionOfExistingContract EQ 0>
			and ((BSA_Foodservice_Items_Master.active_code = 'A' AND BSA_Foodservice_Items_Master.Deleted = 0) OR Contract_Products.Is_Group = 1)
			</cfif>
			<cfif EZCheckProgramAndTemplate eq 1><!--- copy of ez button program --->
			AND		Contract_Products.BSA_Foodservice_Items_Master_ID IN 
			(SELECT	Product_ID FROM ##Tmp_Program_Product_EZ_Original_Program)
			</cfif>
			
			SELECT	Program_Fixed_Price_Product_Data.*
			FROM	Program_Fixed_Price_Product_Data
			
			INNER JOIN ##Tmp_Program_Product Tmp_Program_Product
			ON	Tmp_Program_Product.product_Type_ID = 1
			AND	Tmp_Program_Product.Contract_Products_ID = Program_Fixed_Price_Product_Data.Contract_Products_ID
			
			WHERE
				Program_Fixed_Price_Product_Data.Deleted = 0 
			AND len(Program_Fixed_Price_Product_Data.FIXED_PRICE_VALUE) > 0
			<cfif fixed_component_id eq "">
			AND 1=2
			<cfelse>
			AND Program_Fixed_Price_Product_Data.Program_Fixed_Component_ID IN (#fixed_component_id#)
			</cfif>
			
			DROP TABLE ##Tmp_Program_Product
			<cfif EZCheckProgramAndTemplate eq 1><!--- copy of ez button program --->
			DROP TABLE ##Tmp_Program_Product_EZ_Original_Program
			</cfif>
		</CFQUERY>
		<cfset Contract_Products_ID_Fixed_Price = ValueList(get_Fixed_Price_Products.Contract_Products_ID) />
		
			<CFQUERY NAME="get_Fixed_Price_FreightRates" datasource="#application.datasource#">
			<cfif EZCheckProgramAndTemplate eq 1><!--- copy of ez button program --->
			CREATE TABLE ##Tmp_Program_Product_EZ_Original_Program
			(
				Contract_Products_ID Int,
				Product_ID uniqueidentifier,
				product_Type_ID Int
			)
			INSERT INTO ##Tmp_Program_Product_EZ_Original_Program
			SELECT	DISTINCT Contract_Products_ID, Contract_Products.BSA_Foodservice_Items_Master_ID, product_Type_ID
			FROM	Contract_Products
			WHERE	Contract_Products.Contract_Main_ID = '#actual_Program_ID_To_Replicate#'
			AND 	Contract_Products.product_Type_ID = 1
			AND 	Contract_Products.Deleted = 0
			AND		Contract_Products.Captured_From_Group = 0
			</cfif>
			
			CREATE TABLE ##Tmp_Program_Product_Freight
			(
				Product_ID uniqueidentifier
			)
			
			INSERT INTO ##Tmp_Program_Product_Freight
			SELECT	DISTINCT Contract_Products.BSA_Foodservice_Items_Master_ID
			FROM	Contract_Products
			<cfif form.IsRevisionOfExistingContract EQ 0 OR getContractTemplateDetails.Restrict_On_Approval_Group EQ 1>
			inner join BSA_Foodservice_Items_Master on 
			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = 
			Contract_Products.BSA_Foodservice_Items_Master_ID
			<cfif form.IsRevisionOfExistingContract EQ 0>
			<cfif appSettings.getClassCodesOn()>
			<!--- Dev Note: 12632; Milan. If the user's access to the set of class code changes, then make sure that the products 
			belonging to only the new set of class codes get copied over. This rule does not apply to revisions. --->
				INNER JOIN User_Class_Code
				ON User_Class_Code.Class_Code_Id = 
				CASE 
				WHEN Contract_Products.Product_Group_Level_ID IN (0,9) THEN 
				BSA_Foodservice_items_master.Class_Code_Id
				ELSE
				User_Class_Code.Class_Code_Id
				END
				AND User_Class_Code.Deleted = 0
				AND User_Class_Code.User_Id = '#Responsible_User_Id#'
				INNER JOIN Class_Code
				ON Class_Code.Class_Code_UUID = 
				CASE Contract_Products.Product_Group_Level_ID
				WHEN 10 THEN 
				Contract_Products.BSA_Foodservice_Items_Master_ID
				ELSE
				Class_Code.Class_Code_UUID
				END
				AND User_Class_Code.Class_Code_Id = Class_Code.Class_Code_Id
			</cfif>
			</cfif>
			</cfif>
			<cfif getContractTemplateDetails.Restrict_On_Approval_Group EQ 1>
			inner join Template_Allow_Approval_Group On 
			Template_Allow_Approval_Group.Group_ID = bsa_foodservice_items_master.#approvalGroupType.IDFIELD#
			and Template_Allow_Approval_Group.Program_Type_ID = #getContractTemplateDetails.ProgramControl_Panel_Options_ID#
			</cfif>
			WHERE
			Contract_Products.Contract_Main_ID = '#Program_ID_To_Replicate#'
			AND Contract_Products.product_Type_ID = 1
			AND Contract_Products.Deleted = 0
			AND 
					(
						<!------ Group ----->
						(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
					) 
			<cfif form.IsRevisionOfExistingContract EQ 0>
			and ((BSA_Foodservice_Items_Master.active_code = 'A' AND BSA_Foodservice_Items_Master.Deleted = 0) OR Contract_Products.Is_Group = 1)
			</cfif>
			<cfif EZCheckProgramAndTemplate eq 1><!--- copy of ez button program --->
			AND		Contract_Products.BSA_Foodservice_Items_Master_ID IN 
			(SELECT	Product_ID FROM ##Tmp_Program_Product_EZ_Original_Program)
			</cfif>
		
			SELECT	Program_Fixed_Freight_Rates.*
			FROM	Program_Fixed_Freight_Rates
			INNER JOIN ##Tmp_Program_Product_Freight Tmp_Program_Product
			ON	Tmp_Program_Product.Product_ID =
			Program_Fixed_Freight_Rates.product_id
			where Program_Fixed_Freight_Rates.program_id =
			'#Program_ID_To_Replicate#'
			and Program_Fixed_Freight_Rates.deleted = 0
			
			DROP TABLE ##Tmp_Program_Product_Freight
			<cfif EZCheckProgramAndTemplate eq 1><!--- copy of ez button program --->
			DROP TABLE ##Tmp_Program_Product_EZ_Original_Program
			</cfif>
			</CFQUERY>
			
		</cfif>
		
		<!--- Off-Invoice Products--->
		<cfif getContractTemplateDetails.Generic_Type IS "Distributor Off-Invoice">
		<CFQUERY NAME="get_OffInvoice_Components" datasource="#application.datasource#">
			SELECT *
			FROM Program_OffInvoice_Component
			WHERE 
			program_id = '#Program_ID_To_Replicate#'
			AND Deleted = 0
		</CFQUERY>
		
		<CFQUERY NAME="getOffInvoice_Products" datasource="#application.datasource#">
			CREATE TABLE ##Tmp_Program_Product
			(
				Contract_Products_ID Int,
				product_Type_ID Int
			)
			
			INSERT INTO ##Tmp_Program_Product
			SELECT	DISTINCT Contract_Products_ID, product_Type_ID
			FROM	Contract_Products
			<cfif form.IsRevisionOfExistingContract EQ 0 OR getContractTemplateDetails.Restrict_On_Approval_Group EQ 1>
			inner join BSA_Foodservice_Items_Master on 
			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = 
			Contract_Products.BSA_Foodservice_Items_Master_ID
			<cfif form.IsRevisionOfExistingContract EQ 0>
			<cfif appSettings.getClassCodesOn()>
			<!--- Dev Note: 12632; Milan. If the user's access to the set of class code changes, then make sure that the products 
			belonging to only the new set of class codes get copied over. This rule does not apply to revisions. --->
				INNER JOIN User_Class_Code
				ON User_Class_Code.Class_Code_Id = 
				CASE 
				WHEN Contract_Products.Product_Group_Level_ID IN (0,9) THEN 
				BSA_Foodservice_items_master.Class_Code_Id
				ELSE
				User_Class_Code.Class_Code_Id
				END
				AND User_Class_Code.Deleted = 0
				AND User_Class_Code.User_Id = '#Responsible_User_Id#'
				INNER JOIN Class_Code
				ON Class_Code.Class_Code_UUID = 
				CASE Contract_Products.Product_Group_Level_ID
				WHEN 10 THEN 
				Contract_Products.BSA_Foodservice_Items_Master_ID
				ELSE
				Class_Code.Class_Code_UUID
				END
				AND User_Class_Code.Class_Code_Id = Class_Code.Class_Code_Id
			</cfif>
			</cfif>
			</cfif>
			<cfif getContractTemplateDetails.Restrict_On_Approval_Group EQ 1>
			inner join Template_Allow_Approval_Group On 
			Template_Allow_Approval_Group.Group_ID =  
			CASE 

			-- Is a product
			WHEN Contract_Products.Is_Group = 0
				THEN  bsa_foodservice_items_master.#approvalGroupType.IDFIELD#

				-- Is a group, but same group type as the group type in the template, so we can filter out
				WHEN Contract_Products.Is_Group = 1 and Contract_Products.Product_Group_Level_ID = #approvalGroupType.GROUPLEVELID#

				THEN Contract_Products.bsa_foodservice_items_master_id

				-- Is a group, but diff group type as the group type in the template, so we cannot filter out

			ELSE

			Template_Allow_Approval_Group.Group_ID

			END

			and Template_Allow_Approval_Group.Program_Type_ID = #getContractTemplateDetails.ProgramControl_Panel_Options_ID#
			</cfif>
			WHERE
			Contract_Products.Contract_Main_ID = '#Program_ID_To_Replicate#'
			AND Contract_Products.product_Type_ID = 8
			AND Contract_Products.Deleted = 0
			AND 
					(
						<!------ Group ----->
						(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
					) 
			<cfif form.IsRevisionOfExistingContract EQ 0>
			and ((BSA_Foodservice_Items_Master.active_code = 'A' AND BSA_Foodservice_Items_Master.Deleted = 0) OR Contract_Products.Is_Group = 1)
			</cfif>
			
					
			SELECT 	Program_OffInvoice_Product_Data.*
			FROM 	Program_OffInvoice_Product_Data
					INNER JOIN ##Tmp_Program_Product Tmp_Program_Product
					ON
					Program_OffInvoice_Product_Data.Contract_Products_ID = Tmp_Program_Product.Contract_Products_ID
					AND Tmp_Program_Product.product_Type_ID = 8
					
			WHERE 
			Program_OffInvoice_Product_Data.Deleted = 0 AND len(Program_OffInvoice_Product_Data.Discount_Amount) > 0
			
			DROP TABLE ##Tmp_Program_Product
		</CFQUERY>
	</cfif>
	
		<!--- REBATE PRODUCTS --->
		<!--- the call to rebate cfc is done below --->
	
		<!--- lumpsum components --->
		<cfset Contract_Products_ID_Lump_Sum = "" />
		<CFIF getContractTemplateDetails.Discount_Lump_Sums EQ 1>
		<cfif EZCheckProgramAndTemplate eq 1><!--- copy of ez button program --->
			<!--- on ez program copy (EZCheckProgramAndTemplate = 1), 
			- get component which are in both original program and the template
			- get component details which can be edited in the program from the original program (paid to)
			- get component details which cannot be edited in the program from the template (claim mech, amount)
			- get products which are there in both original program and the template
			--->
			<CFQUERY NAME="get_Lump_Sum_Components" datasource="#application.datasource#">
				SELECT 	Program_Lump_Sums.Program_Lump_Sum_ID,<!--- from template --->
						Program_Lump_Sums_EZ_Original_Program.Lump_Sum_Name,
						Program_Lump_Sums_EZ_Original_Program.Lump_Sum_Description, 
						Program_Lump_Sums_EZ_Original_Program.Program_ID,
						Program_Lump_Sums.Lump_Sum_Amount,<!--- from template --->
						Program_Lump_Sums.Lump_Sum_Volume,<!--- from template --->
						Program_Lump_Sums_EZ_Original_Program.Deleted,
						Program_Lump_Sums_EZ_Original_Program.Program_Lump_Sum_Name_ID,
						Program_Lump_Sums_EZ_Original_Program.Program_Lumps_Sum_Ext_Id,
						Program_Lump_Sums_EZ_Original_Program.Lump_Revision_Comp_ID,
						Program_Lump_Sums.Claim_Mechanics,<!--- from template --->
						Program_Lump_Sums_EZ_Original_Program.Component_Paid_To,
						Program_Lump_Sums_EZ_Original_Program.Current_Program_ID
				FROM 	Program_Lump_Sums
				
				INNER JOIN Program_Lump_Sums as Program_Lump_Sums_EZ_Original_Program
				ON		Program_Lump_Sums_EZ_Original_Program.Deleted = 0
				AND		Program_Lump_Sums_EZ_Original_Program.Program_ID = '#actual_Program_ID_To_Replicate#'
				AND		Program_Lump_Sums_EZ_Original_Program.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
				
				WHERE 	Program_Lump_Sums.Program_ID = '#Program_ID_To_Replicate#' 
				AND 	Program_Lump_Sums.Deleted = 0 
				AND 	len(Program_Lump_Sums.Lump_Sum_Amount) > 0 
			</CFQUERY>
		<cfelse><!--- regular program --->
			<CFQUERY NAME="get_Lump_Sum_Components" datasource="#application.datasource#">
				SELECT *
				FROM Program_Lump_Sums
				WHERE Program_ID = '#Program_ID_To_Replicate#' AND Deleted = 0 
					AND len(Lump_Sum_Amount) > 0 
					--AND len(Lump_Sum_Name) > 0 
			</CFQUERY>
		</cfif>
		
		<cfset lump_sum_component_id = ValueList(get_Lump_Sum_Components.Program_Lump_Sum_ID) />
		
	
		<!--- lumpsum component Products --->
		<CFQUERY NAME="get_Lump_Sum_Component_Products" datasource="#application.datasource#">
			<cfif EZCheckProgramAndTemplate eq 1><!--- copy of ez button program --->
			CREATE TABLE ##Tmp_Program_Product_EZ_Original_Program
			(
				Contract_Products_ID Int,
				Product_ID uniqueidentifier,
				product_Type_ID Int
			)
			INSERT INTO ##Tmp_Program_Product_EZ_Original_Program
			SELECT	DISTINCT Contract_Products_ID, Contract_Products.BSA_Foodservice_Items_Master_ID, product_Type_ID
			FROM	Contract_Products
			WHERE	Contract_Products.Contract_Main_ID = '#actual_Program_ID_To_Replicate#'
			AND 	Contract_Products.product_Type_ID = 3
			AND 	Contract_Products.Deleted = 0
			AND		Contract_Products.Captured_From_Group = 0
			</cfif>
			
			CREATE TABLE ##Tmp_Program_Product
			(
				Contract_Products_ID Int,
				product_Type_ID Int
			)
			
			INSERT INTO ##Tmp_Program_Product
			SELECT	DISTINCT Contract_Products_ID, product_Type_ID
			FROM	Contract_Products
			<cfif form.IsRevisionOfExistingContract EQ 0 OR getContractTemplateDetails.Restrict_On_Approval_Group EQ 1>
			inner join BSA_Foodservice_Items_Master on 
			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = 
			Contract_Products.BSA_Foodservice_Items_Master_ID
			<cfif form.IsRevisionOfExistingContract EQ 0>
			<cfif appSettings.getClassCodesOn()>
			<!--- Dev Note: 12632; Milan. If the user's access to the set of class code changes, then make sure that the products 
			belonging to only the new set of class codes get copied over. This rule does not apply to revisions. --->
				INNER JOIN User_Class_Code
				ON User_Class_Code.Class_Code_Id = 
				CASE 
				WHEN Contract_Products.Product_Group_Level_ID IN (0,9) THEN 
				BSA_Foodservice_items_master.Class_Code_Id
				ELSE
				User_Class_Code.Class_Code_Id
				END
				AND User_Class_Code.Deleted = 0
				AND User_Class_Code.User_Id = '#Responsible_User_Id#'
				INNER JOIN Class_Code
				ON Class_Code.Class_Code_UUID = 
				CASE Contract_Products.Product_Group_Level_ID
				WHEN 10 THEN 
				Contract_Products.BSA_Foodservice_Items_Master_ID
				ELSE
				Class_Code.Class_Code_UUID
				END
				AND User_Class_Code.Class_Code_Id = Class_Code.Class_Code_Id
			</cfif>
			</cfif>
			</cfif>
			<cfif getContractTemplateDetails.Restrict_On_Approval_Group EQ 1>
			inner join Template_Allow_Approval_Group On 
			Template_Allow_Approval_Group.Group_ID =  
			CASE 

			-- Is a product
			WHEN Contract_Products.Is_Group = 0
				THEN  bsa_foodservice_items_master.#approvalGroupType.IDFIELD#

				-- Is a group, but same group type as the group type in the template, so we can filter out
				WHEN Contract_Products.Is_Group = 1 and Contract_Products.Product_Group_Level_ID = #approvalGroupType.GROUPLEVELID#

				THEN Contract_Products.bsa_foodservice_items_master_id

				-- Is a group, but diff group type as the group type in the template, so we cannot filter out

			ELSE

			Template_Allow_Approval_Group.Group_ID

			END

			and Template_Allow_Approval_Group.Program_Type_ID = #getContractTemplateDetails.ProgramControl_Panel_Options_ID#
			</cfif>
			WHERE
					Contract_Products.Contract_Main_ID = '#Program_ID_To_Replicate#' 
					AND Contract_Products.product_Type_ID = 3
					AND Contract_Products.Deleted = 0
					AND 
					(
						<!------ Group ----->
						(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
					) 
			<cfif form.IsRevisionOfExistingContract EQ 0>
			and ((BSA_Foodservice_Items_Master.active_code = 'A' AND BSA_Foodservice_Items_Master.Deleted = 0) OR Contract_Products.Is_Group = 1)
			</cfif>
			<cfif getContractTemplateDetails.Discount_Lump_Sums_Item_Level EQ 1 and  getContractTemplateDetails.Discount_Lump_Sums_Group_Level EQ 0>
			AND (Contract_Products.Is_Group = 0)
			</cfif>
			<cfif getContractTemplateDetails.Discount_Lump_Sums_Group_Level EQ 1 and getContractTemplateDetails.Discount_Lump_Sums_Item_Level EQ 0>
			AND (Contract_Products.Is_Group = 1)
			</cfif>
			<cfif EZCheckProgramAndTemplate eq 1><!--- copy of ez button program --->
			AND		Contract_Products.BSA_Foodservice_Items_Master_ID IN 
			(SELECT	Product_ID FROM ##Tmp_Program_Product_EZ_Original_Program)
			</cfif>
					
			SELECT 	Program_Lump_Sum_Product_Data.*
			FROM 	Program_Lump_Sum_Product_Data
					INNER JOIN ##Tmp_Program_Product Tmp_Program_Product
					ON	Program_Lump_Sum_Product_Data.Contract_Products_ID = Tmp_Program_Product.Contract_Products_ID
					AND Tmp_Program_Product.product_Type_ID = 3
			WHERE 	Program_Lump_Sum_Product_Data.Deleted = 0
			<cfif lump_sum_component_id eq "">
			AND		1=2
			<cfelse>
			AND		Program_Lump_Sum_ID IN (#ListQualify(lump_sum_component_id, "'")#)
			</cfif>
			
			DROP TABLE ##Tmp_Program_Product
			<cfif EZCheckProgramAndTemplate eq 1><!--- copy of ez button program --->
			DROP TABLE ##Tmp_Program_Product_EZ_Original_Program
			</cfif>
		</CFQUERY>
		<cfset Contract_Products_ID_Lump_Sum = ValueList(get_Lump_Sum_Component_Products.Contract_Products_ID) />
		<!--- lumpsum component distributors --->
		<CFQUERY NAME="get_Lump_Sum_Component_Distributors" datasource="#application.datasource#">
			SELECT 	Program_Lump_Sum_Distributor.*
			FROM 	Program_Lump_Sum_Distributor						
			WHERE 	Program_Lump_Sum_Distributor.Deleted = 0
			AND		Program_ID = '#Program_ID_To_Replicate#'
		</CFQUERY>
		
		</cfif>
		
		<!--- Growth Components --->
		<CFIF getContractTemplateDetails.Discount_Growth EQ 1>
		<CFQUERY NAME="get_Growth_Components" datasource="#application.datasource#">
			SELECT *
			FROM Program_Growth_Components
			WHERE Program_ID = '#Program_ID_To_Replicate#' AND Deleted = 0
				AND len(Tier_Count) > 0
				AND len(Component_Name) > 0
			ORDER BY IsParent DESC
		</CFQUERY>
	
		<!--- Growth Components Tiers--->
		<CFQUERY NAME="get_Growth_Component_Tiers" datasource="#application.datasource#">
			SELECT *
			FROM Program_Growth_Component_Tiers
			WHERE Program_ID = '#Program_ID_To_Replicate#' AND Deleted = 0
			AND len(Range_Start) > 0
			AND len(Range_End) > 0
			AND len(Growth_Amount) > 0				
		</CFQUERY>
	
		<!--- Growth Components Tier Products--->
		<CFQUERY NAME="get_Growth_Component_Tier_Products" datasource="#application.datasource#">
			CREATE TABLE ##Tmp_Program_Product
			(
				Contract_Products_ID Int,
				product_Type_ID Int
			)
			
			INSERT INTO ##Tmp_Program_Product
			SELECT	DISTINCT Contract_Products_ID, product_Type_ID
			FROM	Contract_Products
			<cfif form.IsRevisionOfExistingContract EQ 0 OR getContractTemplateDetails.Restrict_On_Approval_Group EQ 1>
			inner join BSA_Foodservice_Items_Master on 
			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = 
			Contract_Products.BSA_Foodservice_Items_Master_ID
			<cfif form.IsRevisionOfExistingContract EQ 0>
			<cfif appSettings.getClassCodesOn()>
			<!--- Dev Note: 12632; Milan. If the user's access to the set of class code changes, then make sure that the products 
			belonging to only the new set of class codes get copied over. This rule does not apply to revisions. --->
				INNER JOIN User_Class_Code
				ON User_Class_Code.Class_Code_Id = 
				CASE 
				WHEN Contract_Products.Product_Group_Level_ID IN (0,9) THEN 
				BSA_Foodservice_items_master.Class_Code_Id
				ELSE
				User_Class_Code.Class_Code_Id
				END
				AND User_Class_Code.Deleted = 0
				AND User_Class_Code.User_Id = '#Responsible_User_Id#'
				INNER JOIN Class_Code
				ON Class_Code.Class_Code_UUID = 
				CASE Contract_Products.Product_Group_Level_ID
				WHEN 10 THEN 
				Contract_Products.BSA_Foodservice_Items_Master_ID
				ELSE
				Class_Code.Class_Code_UUID
				END
				AND User_Class_Code.Class_Code_Id = Class_Code.Class_Code_Id
			</cfif>
			</cfif>
			</cfif>
			<cfif getContractTemplateDetails.Restrict_On_Approval_Group EQ 1>
			inner join Template_Allow_Approval_Group On 
			Template_Allow_Approval_Group.Group_ID =  
			CASE 

			-- Is a product
			WHEN Contract_Products.Is_Group = 0
				THEN  bsa_foodservice_items_master.#approvalGroupType.IDFIELD#

				-- Is a group, but same group type as the group type in the template, so we can filter out
				WHEN Contract_Products.Is_Group = 1 and Contract_Products.Product_Group_Level_ID = #approvalGroupType.GROUPLEVELID#

				THEN Contract_Products.bsa_foodservice_items_master_id

				-- Is a group, but diff group type as the group type in the template, so we cannot filter out

			ELSE

			Template_Allow_Approval_Group.Group_ID

			END

			and Template_Allow_Approval_Group.Program_Type_ID = #getContractTemplateDetails.ProgramControl_Panel_Options_ID#
			</cfif>
			WHERE
					Contract_Products.Contract_Main_ID = '#Program_ID_To_Replicate#' 
					AND Contract_Products.product_Type_ID = 4
					AND Contract_Products.Deleted = 0
					AND 
					(
						<!------ Group ----->
						(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
					) 
			<cfif form.IsRevisionOfExistingContract EQ 0>
			and ((BSA_Foodservice_Items_Master.active_code = 'A' AND BSA_Foodservice_Items_Master.Deleted = 0) OR Contract_Products.Is_Group = 1)
			</cfif>
			<cfif getContractTemplateDetails.Discount_Growth_Item_Level EQ 1 and  getContractTemplateDetails.Discount_Growth_Group_Level EQ 0>
			AND (Contract_Products.Is_Group = 0)
			</cfif>
			<cfif getContractTemplateDetails.Discount_Growth_Group_Level EQ 1 and getContractTemplateDetails.Discount_Growth_Item_Level EQ 0>
			AND (Contract_Products.Is_Group = 1)
			</cfif>
					
			SELECT 	Program_Growth_Component_Product_Data.*
			FROM 	Program_Growth_Component_Product_Data
					INNER JOIN ##Tmp_Program_Product Tmp_Program_Product
					ON
					Program_Growth_Component_Product_Data.Contract_Products_ID = Tmp_Program_Product.Contract_Products_ID
					AND Tmp_Program_Product.product_Type_ID = 4
			WHERE 
			Program_Growth_Component_Product_Data.Deleted = 0
			
			DROP TABLE ##Tmp_Program_Product
			
		</CFQUERY>
		
		<CFSET ListOfProductDataIDS = valuelist(get_Growth_Component_Tier_Products.Program_Growth_Component_Product_Data_ID)>
		<CFIF Listlen(ListOfProductDataIDS) EQ 0><CFSET ListOfProductDataIDS = 0></CFIF>
		<!--- Growth Components Tier Product Data--->
		<CFQUERY NAME="get_Growth_Component_Tier_Product_Tier_Data" datasource="#application.datasource#">
			SELECT *
			FROM Program_Growth_Component_Product_Tier_Data
			WHERE 
			<CFIF ListOfProductDataIDS NEQ "0">
			Program_Growth_Component_Product_Data_ID IN(#ListOfProductDataIDS#) 
			<CFELSE>
			1=2
			</CFIF>		
			AND Deleted = 0
			AND len(Rate) > 0
		</CFQUERY>	
	</cfif>
		<!--- Formula Pricing Periods--->
		<CFIF getContractTemplateDetails.Discount_Formula_Pricing EQ 1>
		<CFQUERY NAME="get_Program_Formula_Pricing_Periods" datasource="#application.datasource#">
			SELECT *
			FROM Program_Formula_Pricing_Periods
			WHERE 
				Program_ID = '#Program_ID_To_Replicate#'
				AND 
				Deleted = 0
				AND
				Active = 1
				AND len(Start_Date) > 0
				AND len(End_Date) > 0
				AND len(Release_Date) > 0
		</CFQUERY>	
		
		
		<cfset useLakebaseForget_Program_Formula_Pricing_Rule_Mapped = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_rule_mapped")>
<cfif useLakebaseForget_Program_Formula_Pricing_Rule_Mapped>
	<cftry>
		<cfset get_Program_Formula_Pricing_Rule_Mapped = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_formula_pricing_rule_mapped", {
				"program_id" = "eq.#Program_ID_To_Replicate#",
				"deleted" = "eq.0",
				"select" = "*"
			}), "*"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_Program_Formula_Pricing_Rule_Mapped = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_Program_Formula_Pricing_Rule_Mapped>
<CFQUERY NAME="get_Program_Formula_Pricing_Rule_Mapped" DATASOURCE="#application.datasource#">
			SELECT	Program_Formula_Pricing_Rule_Mapped.*
			FROM	Program_Formula_Pricing_Rule_Mapped
			WHERE
				Program_Formula_Pricing_Rule_Mapped.Program_ID = #Program_ID_To_Replicate#
				AND
				Program_Formula_Pricing_Rule_Mapped.Deleted = 0
		</CFQUERY>
</cfif>
		
		<!--- Formula Product Data --->
		<CFQUERY NAME="get_Program_Formula_Pricing_Rule_Products" datasource="#application.datasource#">
			CREATE TABLE ##Tmp_Program_Product
			(
				Contract_Products_ID Int,
				product_Type_ID Int
			)
			
			INSERT INTO ##Tmp_Program_Product
			SELECT	DISTINCT Contract_Products_ID, product_Type_ID
			FROM	Contract_Products
			<cfif form.IsRevisionOfExistingContract EQ 0 OR getContractTemplateDetails.Restrict_On_Approval_Group EQ 1>
			inner join BSA_Foodservice_Items_Master on 
			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = 
			Contract_Products.BSA_Foodservice_Items_Master_ID
			<cfif form.IsRevisionOfExistingContract EQ 0>
			<cfif appSettings.getClassCodesOn()>
			<!--- Dev Note: 12632; Milan. If the user's access to the set of class code changes, then make sure that the products 
			belonging to only the new set of class codes get copied over. This rule does not apply to revisions. --->
				INNER JOIN User_Class_Code
				ON User_Class_Code.Class_Code_Id = 
				CASE 
				WHEN Contract_Products.Product_Group_Level_ID IN (0,9) THEN 
				BSA_Foodservice_items_master.Class_Code_Id
				ELSE
				User_Class_Code.Class_Code_Id
				END
				AND User_Class_Code.Deleted = 0
				AND User_Class_Code.User_Id = '#Responsible_User_Id#'
				INNER JOIN Class_Code
				ON Class_Code.Class_Code_UUID = 
				CASE Contract_Products.Product_Group_Level_ID
				WHEN 10 THEN 
				Contract_Products.BSA_Foodservice_Items_Master_ID
				ELSE
				Class_Code.Class_Code_UUID
				END
				AND User_Class_Code.Class_Code_Id = Class_Code.Class_Code_Id
			</cfif>
			</cfif>
			</cfif>
			<cfif getContractTemplateDetails.Restrict_On_Approval_Group EQ 1>
			inner join Template_Allow_Approval_Group On 
			Template_Allow_Approval_Group.Group_ID =  
			CASE 

			-- Is a product
			WHEN Contract_Products.Is_Group = 0
				THEN  bsa_foodservice_items_master.#approvalGroupType.IDFIELD#

				-- Is a group, but same group type as the group type in the template, so we can filter out
				WHEN Contract_Products.Is_Group = 1 and Contract_Products.Product_Group_Level_ID = #approvalGroupType.GROUPLEVELID#

				THEN Contract_Products.bsa_foodservice_items_master_id

				-- Is a group, but diff group type as the group type in the template, so we cannot filter out

			ELSE

			Template_Allow_Approval_Group.Group_ID

			END

			and Template_Allow_Approval_Group.Program_Type_ID = #getContractTemplateDetails.ProgramControl_Panel_Options_ID#
			</cfif>
			WHERE
			Contract_Products.Contract_Main_ID = '#Program_ID_To_Replicate#'
			AND Contract_Products.product_Type_ID = 5
			AND Contract_Products.Deleted = 0
			AND 
					(
						<!------ Group ----->
						(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
					) 
			<cfif form.IsRevisionOfExistingContract EQ 0>
			and ((BSA_Foodservice_Items_Master.active_code = 'A' AND BSA_Foodservice_Items_Master.Deleted = 0) OR Contract_Products.Is_Group = 1)
			</cfif>
					
			SELECT 	Program_Formula_Pricing_Rule_Products.*
			FROM 	Program_Formula_Pricing_Rule_Products
					INNER JOIN ##Tmp_Program_Product Tmp_Program_Product
					ON
					Program_Formula_Pricing_Rule_Products.Contract_Product_ID = Tmp_Program_Product.Contract_Products_ID
					AND Tmp_Program_Product.product_Type_ID = 5
			WHERE 
				Program_Formula_Pricing_Rule_Products.Program_ID = '#Program_ID_To_Replicate#'
				AND 
				Program_Formula_Pricing_Rule_Products.Deleted = 0	
				AND
				Program_Formula_Pricing_Rule_Products.Active = 1
				AND len(Program_Formula_Pricing_Rule_Products.Product_Overage) > 0			
				AND len(Program_Formula_Pricing_Rule_Products.Price) > 0
				
			DROP TABLE ##Tmp_Program_Product
		</CFQUERY>
		
	</cfif>
	
	<!--- Bid Pricing --->
		<CFIF getContractTemplateDetails.Discount_BidRequest EQ 1>
		<cfset useLakebaseForget_BidRequest_Components = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bidrequest_component")>
<cfif useLakebaseForget_BidRequest_Components>
	<cftry>
		<cfset get_BidRequest_Components = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bidrequest_component", {
				"program_id" = "eq.#Program_ID_To_Replicate#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_BidRequest_Components = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_BidRequest_Components>
<CFQUERY NAME="get_BidRequest_Components" datasource="#application.datasource#">
			SELECT *
			FROM Program_Bidrequest_Component
			WHERE 
			program_id = '#Program_ID_To_Replicate#'
			AND Deleted = 0
		</CFQUERY>
</cfif>
		<CFQUERY NAME="get_BidRequest_Products" datasource="#application.datasource#">
			CREATE TABLE ##Tmp_Program_Product
			(
				Contract_Products_ID Int,
				product_Type_ID Int
			)
			
			INSERT INTO ##Tmp_Program_Product
			SELECT	DISTINCT Contract_Products_ID, product_Type_ID
			FROM	Contract_Products
			<cfif form.IsRevisionOfExistingContract EQ 0 OR getContractTemplateDetails.Restrict_On_Approval_Group EQ 1>
			inner join BSA_Foodservice_Items_Master on 
			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = 
			Contract_Products.BSA_Foodservice_Items_Master_ID
			<cfif form.IsRevisionOfExistingContract EQ 0>
			<cfif appSettings.getClassCodesOn()>
			<!--- Dev Note: 12632; Milan. If the user's access to the set of class code changes, then make sure that the products 
			belonging to only the new set of class codes get copied over. This rule does not apply to revisions. --->
				INNER JOIN User_Class_Code
				ON User_Class_Code.Class_Code_Id = 
				CASE 
				WHEN Contract_Products.Product_Group_Level_ID IN (0,9) THEN 
				BSA_Foodservice_items_master.Class_Code_Id
				ELSE
				User_Class_Code.Class_Code_Id
				END
				AND User_Class_Code.Deleted = 0
				AND User_Class_Code.User_Id = '#Responsible_User_Id#'
				INNER JOIN Class_Code
				ON Class_Code.Class_Code_UUID = 
				CASE Contract_Products.Product_Group_Level_ID
				WHEN 10 THEN 
				Contract_Products.BSA_Foodservice_Items_Master_ID
				ELSE
				Class_Code.Class_Code_UUID
				END
				AND User_Class_Code.Class_Code_Id = Class_Code.Class_Code_Id
			</cfif>
			</cfif>
			</cfif>
			<cfif getContractTemplateDetails.Restrict_On_Approval_Group EQ 1>
			inner join Template_Allow_Approval_Group On 
			Template_Allow_Approval_Group.Group_ID =  
			CASE 

			-- Is a product
			WHEN Contract_Products.Is_Group = 0
				THEN  bsa_foodservice_items_master.#approvalGroupType.IDFIELD#

				-- Is a group, but same group type as the group type in the template, so we can filter out
				WHEN Contract_Products.Is_Group = 1 and Contract_Products.Product_Group_Level_ID = #approvalGroupType.GROUPLEVELID#

				THEN Contract_Products.bsa_foodservice_items_master_id

				-- Is a group, but diff group type as the group type in the template, so we cannot filter out

			ELSE

			Template_Allow_Approval_Group.Group_ID

			END

			and Template_Allow_Approval_Group.Program_Type_ID = #getContractTemplateDetails.ProgramControl_Panel_Options_ID#
			</cfif>
			WHERE
			Contract_Products.Contract_Main_ID = '#Program_ID_To_Replicate#'
			AND Contract_Products.product_Type_ID = 10
			AND Contract_Products.Deleted = 0
			AND 
					(
						<!------ Group ----->
						(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
					) 
			<cfif form.IsRevisionOfExistingContract EQ 0>
			and ((BSA_Foodservice_Items_Master.active_code = 'A' AND BSA_Foodservice_Items_Master.Deleted = 0) OR Contract_Products.Is_Group = 1)
			</cfif>
		
			SELECT	Program_Bid_Request_Product.*
			FROM	Program_Bid_Request_Product
			
			INNER JOIN ##Tmp_Program_Product Tmp_Program_Product
			ON	Tmp_Program_Product.product_Type_ID = 10
			AND	Tmp_Program_Product.Contract_Products_ID = Program_Bid_Request_Product.Contract_Products_ID
			
			WHERE
				Program_Bid_Request_Product.Deleted = 0 
			
			DROP TABLE ##Tmp_Program_Product
		</CFQUERY>
	</cfif>
	
		<!--- program product volume --->
		<cfquery name="get_Program_Product_Volume" datasource="#application.datasource#">
		<!--- The EZButton program has to get products from the template, in case
		of copy or rollover. This does not apply to revisions.
		--->
		<cfif EZCheckProgramAndTemplate eq 1><!--- copy of ez button program --->
			CREATE TABLE ##Tmp_Program_Product_EZ_Template_Program
			(
				Product_ID uniqueidentifier
			)
			INSERT INTO ##Tmp_Program_Product_EZ_Template_Program
			SELECT	DISTINCT Contract_Products.BSA_Foodservice_Items_Master_ID
			FROM	Contract_Products
			WHERE	Contract_Products.Contract_Main_ID = '#Program_ID_To_Replicate#'
			AND 	Contract_Products.Deleted = 0
			AND		Contract_Products.Captured_From_Group = 0
		</cfif>
			

			SELECT DISTINCT Program_Product_Volume.*
			FROM 	Program_Product_Volume
					INNER JOIN Contract_Products
					ON
					Contract_Products.Contract_Main_ID = Program_Product_Volume.Program_ID
					AND Contract_Products.Deleted = 0
					AND Program_Product_Volume.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
					AND 
					(
						<!------ Group ----->
						(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
					) 
				<cfif form.IsRevisionOfExistingContract EQ 0 OR getContractTemplateDetails.Restrict_On_Approval_Group EQ 1>
			inner join BSA_Foodservice_Items_Master on 
			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = 
			Contract_Products.BSA_Foodservice_Items_Master_ID
			<cfif form.IsRevisionOfExistingContract EQ 0>
			<cfif appSettings.getClassCodesOn()>
			<!--- Dev Note: 12632; Milan. If the user's access to the set of class code changes, then make sure that the products 
			belonging to only the new set of class codes get copied over. This rule does not apply to revisions. --->
				INNER JOIN User_Class_Code
				ON User_Class_Code.Class_Code_Id = 
				CASE 
				WHEN Contract_Products.Product_Group_Level_ID IN (0,9) THEN 
				BSA_Foodservice_items_master.Class_Code_Id
				ELSE
				User_Class_Code.Class_Code_Id
				END
				AND User_Class_Code.Deleted = 0
				AND User_Class_Code.User_Id = '#Responsible_User_Id#'
				INNER JOIN Class_Code
				ON Class_Code.Class_Code_UUID = 
				CASE Contract_Products.Product_Group_Level_ID
				WHEN 10 THEN 
				Contract_Products.BSA_Foodservice_Items_Master_ID
				ELSE
				Class_Code.Class_Code_UUID
				END
				AND User_Class_Code.Class_Code_Id = Class_Code.Class_Code_Id
			</cfif>
			</cfif>
			</cfif>
			<cfif getContractTemplateDetails.Restrict_On_Approval_Group EQ 1>
			inner join Template_Allow_Approval_Group On 
			Template_Allow_Approval_Group.Group_ID =  
			CASE 

			-- Is a product
			WHEN Contract_Products.Is_Group = 0
				THEN  bsa_foodservice_items_master.#approvalGroupType.IDFIELD#

				-- Is a group, but same group type as the group type in the template, so we can filter out
				WHEN Contract_Products.Is_Group = 1 and Contract_Products.Product_Group_Level_ID = #approvalGroupType.GROUPLEVELID#

				THEN Contract_Products.bsa_foodservice_items_master_id

				-- Is a group, but diff group type as the group type in the template, so we cannot filter out

			ELSE

			Template_Allow_Approval_Group.Group_ID

			END

			and Template_Allow_Approval_Group.Program_Type_ID = #getContractTemplateDetails.ProgramControl_Panel_Options_ID#
			</cfif>
			WHERE 	Program_Product_Volume.Program_ID = '#actual_Program_ID_To_Replicate#' AND Program_Product_Volume.Deleted = 0
			<cfif form.IsRevisionOfExistingContract EQ 0>
			and ((BSA_Foodservice_Items_Master.active_code = 'A' AND BSA_Foodservice_Items_Master.Deleted = 0) OR Contract_Products.Is_Group = 1)
			</cfif>
			<cfif EZCheckProgramAndTemplate eq 1><!--- copy of ez button program --->
			AND		Contract_Products.BSA_Foodservice_Items_Master_ID IN 
			(SELECT	Product_ID FROM ##Tmp_Program_Product_EZ_Template_Program)
			</cfif>
			if object_id('tempdb..##Tmp_Program_Product_EZ_Template_Program') is not null
			drop table ##Tmp_Program_Product_EZ_Template_Program 
		</cfquery>
		

	<cfset Program_ID_To_Replicate = actual_Program_ID_To_Replicate>
		
	<CFIF Form.IsRevisionOfExistingContract EQ 1 AND ((getContractTemplateDetails.generic_type EQ "Distributor Trade/Shelter" and getContractTemplateDetails.Pullbacks_On EQ 1 and getContractTemplateDetails.is_pullback_corporate_deal EQ 0 and getContractTemplateDetails.pullback_from_corporate EQ 1) OR ((getContractTemplateDetails.generic_type EQ "Operator Direct or HQ Programs" OR getContractTemplateDetails.generic_type EQ "Operator-Deviated Pricing") and getContractTemplateDetails.Pullbacks_On EQ 1))>
	<cfset useLakebaseForgetPullbacksDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pullback_details")>
<cfif useLakebaseForgetPullbacksDetails>
	<cftry>
		<cfset getPullbacksDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pullback_details", {
				"opr_program_id" = "eq.#Program_ID_To_Replicate#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPullbacksDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPullbacksDetails>
<cfquery name="getPullbacksDetails" datasource="#application.datasource#">
	select * from
	pullback_details
	where opr_program_id = '#Program_ID_To_Replicate#'
	</cfquery>
</cfif>
	<cfset useLakebaseForgetPullbackLevelsDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pullbacks_levels")>
<cfif useLakebaseForgetPullbackLevelsDetails>
	<cftry>
		<cfset getPullbackLevelsDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pullbacks_levels", {
				"pullback_program_id" = "eq.#Program_ID_To_Replicate#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPullbackLevelsDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPullbackLevelsDetails>
<cfquery name="getPullbackLevelsDetails" datasource="#application.datasource#">
	select * from
	pullbacks_Levels
	where pullback_program_id = '#Program_ID_To_Replicate#'
	</cfquery>
</cfif>
	<cfset useLakebaseForgetPullbackDisDefaults = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pullbacks_distributors_defaults")>
<cfif useLakebaseForgetPullbackDisDefaults>
	<cftry>
		<cfset getPullbackDisDefaults = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pullbacks_distributors_defaults", {
				"pullback_program_id" = "eq.#Program_ID_To_Replicate#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPullbackDisDefaults = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPullbackDisDefaults>
<cfquery name="getPullbackDisDefaults" datasource="#application.datasource#">
	select * from
	Pullbacks_Distributors_Defaults
	where pullback_program_id = '#Program_ID_To_Replicate#'
	</cfquery>
</cfif>
	</CFIF>
</cfif> 
<!--- 
Dev Note: Milan (48182) - Remove any insert/update to "template_pullback_program_defaults".
This table is not being used anymore.
--->
<!---<CFIF getContractTemplateDetails.generic_type EQ "Distributor Trade/Shelter" and getContractTemplateDetails.Pullbacks_On EQ 1 and getContractTemplateDetails.is_pullback_corporate_deal EQ 1>
<cfset useLakebaseForgetPullbacksProgramDefaults = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("template_pullback_program_defaults")>
<cfif useLakebaseForgetPullbacksProgramDefaults>
	<cftry>
		<cfset getPullbacksProgramDefaults = application.oLakebase.toQuery(
			application.oLakebase.selectRows("template_pullback_program_defaults", {
				"program_id" = "eq.#Program_ID_To_Replicate#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPullbacksProgramDefaults = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPullbacksProgramDefaults>
<cfquery name="getPullbacksProgramDefaults" datasource="#application.datasource#">
	select * from
	template_pullback_program_defaults
	where program_id = '#Program_ID_To_Replicate#'
	and deleted = 0
</cfquery>
</cfif>
</CFIF>--->
<!--- End suppress distributors & products --->
			
		<cfset qProgramClause = CreateObject("component", "components.clause_library.ClauseProgramManager").getAllProgramClause(Program_ID_To_Replicate)>
		
		<cfset qProgramPaymentCycles = CreateObject("component", "components.programs.PaymentCycleManager").getProgramPaymentCycles(Program_ID_To_Replicate)>
		
		<!------ Operating Group ----->
		<cfset operatingGroupProgramLevel1 = "0" />
		<cfset operatingGroupProgramLevel2 = "0" />
			
		<cfif appSettings.getOperatingGroupOn()>
			<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
			
			<cfset programLevel1Level 				= operatingGroupManager.getProgramLevel1Level() />		
			<cfset programLevel2Level 				= operatingGroupManager.getProgramLevel2Level() />
			
			<cfset operatingGroupProgramLevel1 = operatingGroupManager.getProgramOperatingGroupID(level=programLevel1Level, programId=Program_ID_To_Replicate) />
			<cfset operatingGroupProgramLevel2 = operatingGroupManager.getProgramOperatingGroupID(level=programLevel2Level, programId=Program_ID_To_Replicate) />
			
		</cfif>

	
	<!--- BuildStruct --->
		<CFSET Program = StructNew()>
		<!--- Contract_Main --->
		<CFSET Program.Basic_Information = StructNew()>
		<CFOUTPUT QUERY="getContractInfo">
			<CFLOOP INDEX="Contract_Main_Column_List" LIST="#getContractInfo.ColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("getContractInfo.#Contract_Main_Column_List#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "Program.Basic_Information.#Contract_Main_Column_List#" = ThisRowAndColumnData>
			</CFLOOP>
		</CFOUTPUT>
		<CFSET Program.Basic_Information.Operating_Group_Level_1_ID = operatingGroupProgramLevel1>
		<CFSET Program.Basic_Information.Operating_Group_Level_2_ID = operatingGroupProgramLevel2>
	
		
		<!---Comment: TF - include this if not coming from trade plan--->
		<cfif not isDefined("form.bIsFromTradePlan")>
		
			<CFIF ucase(Program.Basic_Information.Adv_Spending_Amount) EQ "NULL">
				<CFSET Program.Basic_Information.Adv_Spending_Amount = 0>
			</CFIF> 
	
			<CFIF ucase(Program.Basic_Information.ProgramType) EQ "NULL">
				<CFSET Program.Basic_Information.ProgramType = "">
			</CFIF>
			
		</cfif>
		<cfif getContractTemplateDetails.Adv_Spend EQ 0>
			<cfset Program.Basic_Information.Adv_Spending_Amount = 0>
		</cfif>
		<cfif getContractTemplateDetails.Payable_To EQ 0>
		<cfset Program.Basic_Information.Pay_To_Distributor = "">
		<cfset Program.Basic_Information.Payable_Company = "">
		<cfset Program.Basic_Information.Payable_Attention = "">
		<cfset Program.Basic_Information.Payable_Address_1 = "">
		<cfset Program.Basic_Information.Payable_Address_2 = "">
		<cfset Program.Basic_Information.Payable_City = "">
		<cfset Program.Basic_Information.Payable_State = "">
		<cfset Program.Basic_Information.Payable_Zip = "">
		<cfset Program.Basic_Information.Payable_Comments = "">
		</cfif>
		
		<cfif getContractTemplateDetails.Send_Payment_To EQ 0>
		<cfset Program.Basic_Information.Send_To_Broker = "">
		<cfset Program.Basic_Information.Send_Company = "">
		<cfset Program.Basic_Information.Send_Attention = "">
		<cfset Program.Basic_Information.Send_Address_1 = "">
		<cfset Program.Basic_Information.Send_Address_2 = "">
		<cfset Program.Basic_Information.Send_City = "">
		<cfset Program.Basic_Information.Send_State = "">
		<cfset Program.Basic_Information.Send_Zip = "">
		</cfif>
		
		<cfif getContractTemplateDetails.Auto_Renew_Option EQ 0>
		<cfset Program.Basic_Information.Auto_Renew = 0>
		<cfset Program.Auto_Renew.AR_Notification_Date = "">
		<cfset Program.Auto_Renew.AR_Start_Date = "">
		<cfset Program.Auto_Renew.AR_End_Date = "">
		<cfset Program.Auto_Renew.Renewal_Lead_Time = "">
		<cfset Program.Auto_Renew.AR_Renewal_Type = "">
		</cfif>
		
		<cfif getContractTemplateDetails.Controllable_Volume EQ 0>
			<cfset Program.Basic_Information.Controllable_Volume = 0>
		</cfif>
		
		<cfif getContractTemplateDetails.Growth_Inclusion EQ 0>
			<cfset Program.Basic_Information.Growth_Inclusion = 0>
		</cfif>
		<cfif getContractTemplateDetails.Equipment_Placement EQ 0>
			<cfset Program.Basic_Information.Equipment_Placement = 0>
		</cfif>
		<cfset Program.Basic_Information.ProgramType_ID = this.ProgramType_ID>
		
		
		<!--- Similar Products (Dev Note: Milan; D7226) --->
		<CFSET NewStructLevelName 	= "Program.SimilarProducts">
		<CFSET MasterQuery 			= "SimilarProductsList">
	
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>
		<CFSET ThisStructure.Master_Table = "Similar_Existing_Product">
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#" = ThisRowAndColumnData>
			</CFLOOP>
		</CFOUTPUT>
		<!--- End Note: Milan; D7226 --->

		<!--- Competitive Data (Dev Note: Milan; D10697) --->
		<CFSET NewStructLevelName 	= "Program.CompetitiveData">
		<CFSET MasterQuery 			= "getCompetitiveProductsInfo">

		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>
		<CFSET ThisStructure.Master_Table = "Program_Competitive_Data">
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT>
		<!--- End Note: Milan; D10697 --->
	
		<!--- Program_Accounting_Specialist --->
		<cfif application.returned_customer_setting.Accounting_Specialist eq 1>
			<CFSET NewStructLevelName 	= "Program.Program_Accounting_Specialist">
			<CFSET MasterQuery 			= "getContractAccountingSpecialist">
		
			<CFSET "#NewStructLevelName#" = StructNew()>
			<CFSET ThisStructure = evaluate(NewStructLevelName)>
			<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
			<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
			<CFSET ThisStructure.ColumnList = theColumnList>
			<CFSET ThisStructure.Master_Table = "Program_Accounting_Specialist">
			<CFOUTPUT QUERY="#MasterQuery#">
				<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
					<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
					<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
						<CFSET ThisRowAndColumnData = "NULL">
					</CFIF>
					<CFSET "ThisStructure.#Master_Query_Column#" = ThisRowAndColumnData>
				</CFLOOP>
			</CFOUTPUT>
		</cfif>
		
			
		<!--- contract_operators --->
		<cfif getContractTemplateDetails.Specify_Operators EQ 1>
			<CFSET NewStructLevelName 	= "Program.Operators">
			<CFSET MasterQuery 			= "getContractOperators">
		
			<CFSET "#NewStructLevelName#" = StructNew()>
			<CFSET ThisStructure = evaluate(NewStructLevelName)>
			<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
			
			<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
			<CFSET ThisStructure.ColumnList = theColumnList>
			<CFSET ThisStructure.Master_Table = "Contract_Operators">
			<CFSET IndexCounter = 1>
			<CFOUTPUT QUERY="#MasterQuery#">
				<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
					<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
					<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
						<CFSET ThisRowAndColumnData = "NULL">
					</CFIF>
					<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
				</CFLOOP>
			<CFSET IndexCounter = IndexCounter + 1>
			</CFOUTPUT>
		</cfif>
	
		<!--- contract_brokers --->
		<!--- Ana: D15113 - Commenting the below CFIF condition --->
		<!--- <cfif getContractTemplateDetails.Specify_Brokers EQ 1> --->
			<CFSET NewStructLevelName = "Program.Brokers">
			<CFSET MasterQuery = "getContractBrokers">
		
			<CFSET "#NewStructLevelName#" = StructNew()>
			<CFSET ThisStructure = evaluate(NewStructLevelName)>
			<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
			
			<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
			<CFSET ThisStructure.ColumnList = theColumnList>	
			<CFSET ThisStructure.Master_Table = "Contract_Brokers">	
			<CFSET IndexCounter = 1>
			<CFOUTPUT QUERY="#MasterQuery#">
				<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
					<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
					<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
						<CFSET ThisRowAndColumnData = "NULL">
					</CFIF>
					<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
				</CFLOOP>
			<CFSET IndexCounter = IndexCounter + 1>
			</CFOUTPUT>	
		<!--- </cfif> --->
		
		 <!--- Auto Renew --->
		<cfif getContractTemplateDetails.Auto_Renew_Option EQ 1>
			<CFSET NewStructLevelName = "Program.Auto_Renew">
			<CFSET MasterQuery = "getAutoRenew">
		
			<CFSET "#NewStructLevelName#" = StructNew()>
			<CFSET ThisStructure = evaluate(NewStructLevelName)>
			<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
			
			<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
			<CFSET ThisStructure.ColumnList = theColumnList>	
			<CFSET ThisStructure.Master_Table = "Program_Auto_Renew">	
			<CFSET IndexCounter = 1>
			<CFOUTPUT QUERY="#MasterQuery#">
				<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
					<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
					<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
						<CFSET ThisRowAndColumnData = "NULL">
					</CFIF>
					<CFSET "ThisStructure.#Master_Query_Column#" = ThisRowAndColumnData>
				</CFLOOP>
			<CFSET IndexCounter = IndexCounter + 1>
			</CFOUTPUT>
		</cfif>
		<cfif Form.suppressProductsDistributors EQ 0>
			<!--- contract_Distributors--->
			<cfif getContractTemplateDetails.Specify_Distributors EQ 1>
			<CFSET NewStructLevelName = "Program.Distributors">
			<CFSET MasterQuery = "getContractDistributors">
		
			<CFSET "#NewStructLevelName#" = StructNew()>
			<CFSET ThisStructure = evaluate(NewStructLevelName)>
			<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
			
			<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
			<CFSET ThisStructure.ColumnList = theColumnList>	
			<CFSET ThisStructure.Master_Table = "Contract_Distributors">		
			<CFSET IndexCounter = 1>
			<CFOUTPUT QUERY="#MasterQuery#">
				<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
					<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
					<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
						<CFSET ThisRowAndColumnData = "NULL">
					</CFIF>
					<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
				</CFLOOP>
			<CFSET IndexCounter = IndexCounter + 1>
			</CFOUTPUT>		
		</cfif>
		
		<!--- Contract_Attachments --->
		<CFSET NewStructLevelName = "Program.Attachments">
		<CFSET MasterQuery = "getContractAttachments">
	
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>	
		<CFSET ThisStructure.Master_Table = "Contract_Attachments">		
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT>		
	
		<!--- Contract_Products --->
		<CFSET NewStructLevelName = "Program.Products">
		<CFSET MasterQuery = "getContract_Products">
	
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		
		<CFSET ThisStructure.ColumnList = theColumnList>	
		<CFSET ThisStructure.Master_Table = "Contract_Products">		
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<!--- below code (addThisItem) so that when products gets removed because components are removed (eg:ez button rules on copy), we need to make sure the products are removed from the contract_products table also
			if not it might (based on the app switch getComponent_Product_Restrictions_On) show up in the "products removed pop-up"
			This code will need to be modified if this list of products getting removed need to show up in the "products removed pop-up"
			 --->
			<cfset addThisItem = 1 />
			<cfset This_Contract_Products_ID = evaluate("#MasterQuery#.Contract_Products_ID") />
			<cfset This_Product_Type_ID = evaluate("#MasterQuery#.Product_Type_ID") />
			<cfif This_Product_Type_ID EQ 1 and NOT ListFind(Contract_Products_ID_Fixed_Price, This_Contract_Products_ID)>
				<!--- if fixed price make sure it is in the fixed price list --->
				<cfset addThisItem = 0 />
			<cfelseif This_Product_Type_ID EQ 3 and NOT ListFind(Contract_Products_ID_Lump_Sum, This_Contract_Products_ID)>
				<!--- if lump sum make sure it is in the lump sum list --->
				<cfset addThisItem = 0 />
			</cfif>
			
			<cfif addThisItem>
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
			<CFSET IndexCounter = IndexCounter + 1>
			</cfif>			
		</CFOUTPUT>
		<CFSET ThisStructure.Recordcount = IndexCounter-1>
		
			
	
		<!--- Fixed price components --->
		<cfif getContractTemplateDetails.Discount_Fixed_Prices EQ 1>
			<CFSET NewStructLevelName = "Program.Fixed_Price_Components">
			<CFSET MasterQuery = "get_Fixed_Price_Components">
		
			<CFSET "#NewStructLevelName#" = StructNew()>
			<CFSET ThisStructure = evaluate(NewStructLevelName)>
			<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
			
			<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
			<CFSET ThisStructure.ColumnList = theColumnList>	
			<CFSET ThisStructure.Master_Table = "Program_Fixed_Component">		
			<CFSET IndexCounter = 1>
			<CFOUTPUT QUERY="#MasterQuery#">
				<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
					<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
					<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
						<CFSET ThisRowAndColumnData = "NULL">
					</CFIF>
					<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
				</CFLOOP>
			<CFSET IndexCounter = IndexCounter + 1>
			</CFOUTPUT>	
			
			<!--- Fixed price products --->
			<CFSET NewStructLevelName = "Program.Products.Fixed_Price_Products">
			<CFSET MasterQuery = "get_Fixed_Price_Products">
		
			<CFSET "#NewStructLevelName#" = StructNew()>
			<CFSET ThisStructure = evaluate(NewStructLevelName)>
			<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
			
			<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
			<CFSET ThisStructure.ColumnList = theColumnList>	
			<CFSET ThisStructure.Master_Table = "Program_Fixed_Price_Product_Data">		
			<CFSET IndexCounter = 1>
			<CFOUTPUT QUERY="#MasterQuery#">
				<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
					<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
					<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
						<CFSET ThisRowAndColumnData = "NULL">
					</CFIF>
					<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
				</CFLOOP>
			<CFSET IndexCounter = IndexCounter + 1>
			</CFOUTPUT>	
			
			
			<CFSET NewStructLevelName = "Program.Products.Fixed_Price_FreightRates">
			<CFSET MasterQuery = "get_Fixed_Price_FreightRates">
		
			<CFSET "#NewStructLevelName#" = StructNew()>
			<CFSET ThisStructure = evaluate(NewStructLevelName)>
			<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
			
			<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
			<CFSET ThisStructure.ColumnList = theColumnList>	
			<CFSET ThisStructure.Master_Table = "Program_Fixed_Freight_Rates">		
			<CFSET IndexCounter = 1>
			<CFOUTPUT QUERY="#MasterQuery#">
				<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
					<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
					<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
						<CFSET ThisRowAndColumnData = "NULL">
					</CFIF>
					<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
				</CFLOOP>
			<CFSET IndexCounter = IndexCounter + 1>
			</CFOUTPUT>	

		</cfif>
		
		<!--- Bid Request --->
		<cfif getContractTemplateDetails.Discount_BidRequest EQ 1>
			<CFSET NewStructLevelName = "Program.BidRequest_Components">
			<CFSET MasterQuery = "get_BidRequest_Components">
		
			<CFSET "#NewStructLevelName#" = StructNew()>
			<CFSET ThisStructure = evaluate(NewStructLevelName)>
			<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
			
			<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
			<CFSET ThisStructure.ColumnList = theColumnList>	
			<CFSET ThisStructure.Master_Table = "Program_BidRequest_Component">		
			<CFSET IndexCounter = 1>
			<CFOUTPUT QUERY="#MasterQuery#">
				<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
					<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
					<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
						<CFSET ThisRowAndColumnData = "NULL">
					</CFIF>
					<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
				</CFLOOP>
			<CFSET IndexCounter = IndexCounter + 1>
			</CFOUTPUT>	
			
			<!--- Bid Request price products --->
			<CFSET NewStructLevelName = "Program.Products.BidRequest_Products">
			<CFSET MasterQuery = "get_BidRequest_Products">
		
			<CFSET "#NewStructLevelName#" = StructNew()>
			<CFSET ThisStructure = evaluate(NewStructLevelName)>
			<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
			
			<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
			<CFSET ThisStructure.ColumnList = theColumnList>	
			<CFSET ThisStructure.Master_Table = "Program_Bid_Request_Product">		
			<CFSET IndexCounter = 1>
			<CFOUTPUT QUERY="#MasterQuery#">
				<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
					<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
					<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
						<CFSET ThisRowAndColumnData = "NULL">
					</CFIF>
					<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
				</CFLOOP>
			<CFSET IndexCounter = IndexCounter + 1>
			</CFOUTPUT>	
		</cfif>
	
		
		<!--- Off Invoice products --->
		<cfif getContractTemplateDetails.Generic_Type IS "Distributor Off-Invoice">
		
			<!--- Off Invoice components --->
			<CFSET NewStructLevelName = "Program.Program_OffInvoice_Component">
			<CFSET MasterQuery = "get_OffInvoice_Components">
		
			<CFSET "#NewStructLevelName#" = StructNew()>
			<CFSET ThisStructure = evaluate(NewStructLevelName)>
			<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
			
			<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
			<CFSET ThisStructure.ColumnList = theColumnList>	
			<CFSET ThisStructure.Master_Table = "Program_OffInvoice_Component">		
			<CFSET IndexCounter = 1>
			<CFOUTPUT QUERY="#MasterQuery#">
				<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
					<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
					<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
						<CFSET ThisRowAndColumnData = "NULL">
					</CFIF>
					<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
				</CFLOOP>
			<CFSET IndexCounter = IndexCounter + 1>
			</CFOUTPUT>		
			
			<CFSET NewStructLevelName = "Program.Products.OffInvoice_Products">
			<CFSET MasterQuery = "getOffInvoice_Products">
		
			<CFSET "#NewStructLevelName#" = StructNew()>
			<CFSET ThisStructure = evaluate(NewStructLevelName)>
			<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
			
			<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
			<CFSET ThisStructure.ColumnList = theColumnList>	
			<CFSET ThisStructure.Master_Table = "Program_OffInvoice_Product_Data">		
			<CFSET IndexCounter = 1>
			<CFOUTPUT QUERY="#MasterQuery#">
				<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
					<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
					<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
						<CFSET ThisRowAndColumnData = "NULL">
					</CFIF>
					<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
				</CFLOOP>
			<CFSET IndexCounter = IndexCounter + 1>
			</CFOUTPUT>		
		</cfif>
	
		<!--- REBATE products --->
  		<CFIF getContractTemplateDetails.Discount_Rebates EQ 1>
			<CFSET NewStructLevelName = "Program.Products.Rebate_Products">
			<CFSET "#NewStructLevelName#" = StructNew()>
			
			<!--- this code diverts form the normal method of storage and access - but it works --->
			<!--- Dev Note: KAL; 8362: Setting to display both active and inactive programs when a revision and only active if a rollover/copy --->
			<cfif form.IsRevisionOfExistingContract EQ 0>
				<cfset CheckForActiveProductsOnly = 1/>
			</cfif>
			<cfset EZ_Original_Program_ID = 0 />
      	<!--- <cfif form.EZTemplate EQ 1 and gettemplateparent.EZ_Contract_Id NEQ getContractTemplateDetails.EZ_Contract_Id and form.IsRevisionOfExistingContract EQ 0> --->
			<cfif form.EZTemplate EQ 1 and (form.IsRevisionOfExistingContract EQ 0 OR getContractTemplateDetails.EzButton_Update_With_Latest_Template_Settings_On_Revise EQ 1)>
				<cfset Program_ID_To_Replicate = getContractTemplateDetails.EZ_Contract_Id>
				<cfset EZ_Original_Program_ID = actual_Program_ID_To_Replicate />
			</cfif>
			<cfset rebate = createObject("component","components.programs.rebates.Rebate")>
			<cfset Program.Products.Rebate_Products.Rebate_Array = StructNew()>
			<cfif getContractTemplateDetails.Restrict_On_Approval_Group EQ 1>
         <!--- Original assignment on the page--->
        <cfset Program.Products.Rebate_Products.Rebate_Array = rebate.loadFromDB(
						programID=#Program_ID_To_Replicate#,
						checktemplatesettings=1,
						groupfieldname=#approvalGroupType.IDFIELD#,
						template_id = #this.ProgramType_ID#,
						CheckForActiveProductsOnly = #CheckForActiveProductsOnly#,
						EZTemplate=form.EZTemplate,
						Copy_Revise = #Copy_Revise#,
						RevisionOfExistingContract=Form.IsRevisionOfExistingContract,
						ClassCodeUserID=Responsible_User_Id,
						EZOriginalProgramID=EZ_Original_Program_ID
						)>
			<cfelse>
				<cfset Program.Products.Rebate_Products.Rebate_Array = rebate.loadFromDB(
						programID=#Program_ID_To_Replicate#,
						checktemplatesettings=1,
						template_id = #this.ProgramType_ID#,
						EZTemplate=form.EZTemplate,
						Copy_Revise = #Copy_Revise#,
						RevisionOfExistingContract=Form.IsRevisionOfExistingContract,
						ClassCodeUserID=Responsible_User_Id,
						EZOriginalProgramID=EZ_Original_Program_ID
						)>
			</cfif>
		</cfif>
		
		<cfset Program_ID_To_Replicate = actual_Program_ID_To_Replicate>
	
		<!--- lump sum component --->
		<CFIF getContractTemplateDetails.Discount_Lump_Sums EQ 1>
		<CFSET NewStructLevelName = "Program.Lump_Sum_Components">
		<CFSET MasterQuery = "get_Lump_Sum_Components">
	
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>	
		<CFSET ThisStructure.Master_Table = "Program_Lump_Sums">		
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT>
		
		
		<!--- lump sum component products --->
		<CFSET NewStructLevelName = "Program.Lump_Sum_Components.Products">
		<CFSET MasterQuery = "get_Lump_Sum_Component_Products">
	
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>	
		<CFSET ThisStructure.Master_Table = "Program_Lump_Sum_Product_Data">		
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT>
		
		<!--- lump sum component distributors --->
		<CFSET NewStructLevelName = "Program.Lump_Sum_Components.Distributors">
		<CFSET MasterQuery = "get_Lump_Sum_Component_Distributors">
	
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>	
		<CFSET ThisStructure.Master_Table = "Program_Lump_Sum_Distributor">		
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT>
		</cfif>
	
		<!--- growth components --->
		<CFIF getContractTemplateDetails.Discount_Growth EQ 1>
		<CFSET NewStructLevelName = "Program.Growth_Components">
		<CFSET MasterQuery = "get_Growth_Components">
	
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>	
		<CFSET ThisStructure.Master_Table = "Program_Growth_Components">		
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT>	
	
		<!--- <cfabort> --->
		<!--- growth component tiers --->
		<CFSET NewStructLevelName = "Program.Growth_Components.Tiers">
		<CFSET MasterQuery = "get_Growth_Component_Tiers">
	
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>	
		<CFSET ThisStructure.Master_Table = "Program_Growth_Component_Tiers">		
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT>		
		
		<!--- growth component tier products --->
		<CFSET NewStructLevelName = "Program.Growth_Components.Tiers.Tier_Products">
		<CFSET MasterQuery = "get_Growth_Component_Tier_Products">
	
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>	
		<CFSET ThisStructure.Master_Table = "Program_Growth_Component_Product_Data">		
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT>
	
		<!--- growth component tier product tier data --->
		<CFSET NewStructLevelName = "Program.Growth_Components.Tiers.Tier_Products.Product_Tier_Data">
		<CFSET MasterQuery = "get_Growth_Component_Tier_Product_Tier_Data">
	
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>	
		<CFSET ThisStructure.Master_Table = "Program_Growth_Component_Product_Tier_Data">
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT>	
		</cfif>
	
		<!--- create FP root --->
		<CFIF getContractTemplateDetails.Discount_Formula_Pricing EQ 1>
		<CFSET NewStructLevelName = "Program.Formula_Pricing">
		<CFSET "#NewStructLevelName#" = StructNew()>
		
		<!--- formula_pricing_periods --->
		<CFSET NewStructLevelName = "Program.Formula_Pricing.Periods">
		<CFSET MasterQuery = "get_Program_Formula_Pricing_Periods">
	
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>	
		<CFSET ThisStructure.Master_Table = "Program_Formula_Pricing_Periods">		
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT>	
	
		<!--- formula_pricing_rules added to this program --->
		<CFSET NewStructLevelName = "Program.Formula_Pricing.ProgramRules">
		<CFSET MasterQuery = "get_Program_Formula_Pricing_Rule_Mapped">
	
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>	
		<CFSET ThisStructure.Master_Table = "Program_Formula_Pricing_Rule_Mapped">		
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT>
		
		
	<!--- formula_pricing_products --->
		<CFSET NewStructLevelName = "Program.Formula_Pricing.Products">
		<CFSET MasterQuery = "get_Program_Formula_Pricing_Rule_Products">
	
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>	
		<CFSET ThisStructure.Master_Table = "Program_Formula_Pricing_Rule_Products">		
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT>	
		</cfif>
		
		<!--- <!--- <!--- <!--- Program Product Volume - Needed in order for a program to become active  ---> ---> ---> --->
		<CFSET NewStructLevelName = "Program.Program_Product_Volume">
		<CFSET MasterQuery = "get_Program_Product_Volume">
		
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
			
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT>	
	
		
		<!------ Clauses in the program ----->
		<CFSET NewStructLevelName = "Program.Clauses">
		<CFSET MasterQuery = "qProgramClause">
	
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>	
		<CFSET ThisStructure.Master_Table = "Clause_Program">	
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT>
		
		
			<!--- pullbacks --->
		<CFIF Form.IsRevisionOfExistingContract EQ 1 AND ((getContractTemplateDetails.generic_type EQ "Distributor Trade/Shelter" and getContractTemplateDetails.Pullbacks_On EQ 1 and getContractTemplateDetails.is_pullback_corporate_deal EQ 0 and getContractTemplateDetails.pullback_from_corporate EQ 1) OR ((getContractTemplateDetails.generic_type EQ "Operator Direct or HQ Programs" OR getContractTemplateDetails.generic_type EQ "Operator-Deviated Pricing") and getContractTemplateDetails.Pullbacks_On EQ 1))>
		<!--- <CFSET NewStructLevelName 	= "Program.Pullbacks">
		<CFSET MasterQuery 			= "getPullbacksDetails">
	
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>
		<CFSET ThisStructure.Master_Table = "Pullback_Details">
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT> --->
		
		<CFSET NewStructLevelName 	= "Program.PullbacksLevels">
		<CFSET MasterQuery 			= "getPullbackLevelsDetails">
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>
		<CFSET ThisStructure.Master_Table = "Pullbacks_Levels">
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT>
		
		<CFSET NewStructLevelName 	= "Program.PullbacksDisDefaults">
		<CFSET MasterQuery 			= "getPullbackDisDefaults">
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>
		<CFSET ThisStructure.Master_Table = "Pullbacks_Distributors_Defaults">
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT>
		</cfif>
		
		<!---
		<CFIF getContractTemplateDetails.generic_type EQ "Distributor Trade/Shelter" and getContractTemplateDetails.Pullbacks_On EQ 1 and getContractTemplateDetails.is_pullback_corporate_deal EQ 1>
		<CFSET NewStructLevelName 	= "Program.PullbacksProgramDefaults">
		<CFSET MasterQuery 			= "getPullbacksProgramDefaults">
	
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>
		<CFSET ThisStructure.Master_Table = "template_pullback_program_defaults">
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT>
		</CFIF>
		--->
		
		<!------ Paymen Cycle selection at discount type level ----->
		<CFSET NewStructLevelName = "Program.DiscountTypePaymentCycles">
		<CFSET MasterQuery = "qProgramPaymentCycles">
	
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>	
		<CFSET ThisStructure.Master_Table = "Program_Payment_Cycle">	
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT>
		
		
			<!------ Sysco Deal Sheets ----->
		<CFSET NewStructLevelName = "Program.SyscoDealSheetPrograms">
		<CFSET MasterQuery = "qSyscoDealSheets">
	
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>	
		<CFSET ThisStructure.Master_Table = "Sysco_Deal_Sheet_Programs">	
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT>
		
		<!------ 5.0 Fixed Freight ----->
		<!--- If revision of guaranteed template, copy over values from parent version ---->
		<cfif (form.IsRevisionOfExistingContract EQ 1 and getContractTemplateDetails.Fixed_Type eq 0) or (FORM.ForceFreightOnAutoCopy EQ 1)>
		<CFSET NewStructLevelName = "Program.ProgramDistributorFreight">
		<CFSET MasterQuery = "getProgramDistributorFreight">
	
		<CFSET "#NewStructLevelName#" = StructNew()>
		<CFSET ThisStructure = evaluate(NewStructLevelName)>
		<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
		
		<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
		<CFSET ThisStructure.ColumnList = theColumnList>	
		<CFSET ThisStructure.Master_Table = "Program_Distributor_Freight">	
		<CFSET IndexCounter = 1>
		<CFOUTPUT QUERY="#MasterQuery#">
			<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
			</CFLOOP>
		<CFSET IndexCounter = IndexCounter + 1>
		</CFOUTPUT>
		</cfif>
	</cfif>	
		
		<!--- format the columns to a non-odbc timestamp --->		
		<!---Comment: TF - Include this if not coming from trade plan--->
		<!--- Basic Information --->
		<cfif not isDefined("form.bIsFromTradePlan")>
			<!------<cfif isdate(Program.BASIC_INFORMATION.APPROVAL_DATE)><CFSET Program.BASIC_INFORMATION.APPROVAL_DATE 			= DateFormat(Program.BASIC_INFORMATION.APPROVAL_DATE,'m/d/yyyy')></cfif> ----->
			<cfif isdate(Program.BASIC_INFORMATION.BROKER_APPROVED_DATE)><CFSET Program.BASIC_INFORMATION.BROKER_APPROVED_DATE 	= DateFormat(Program.BASIC_INFORMATION.BROKER_APPROVED_DATE,'m/d/yyyy')></cfif>
			<cfif isdate(Program.BASIC_INFORMATION.CONTRACT_CREATED_DATE)><CFSET Program.BASIC_INFORMATION.CONTRACT_CREATED_DATE 	= DateFormat(Program.BASIC_INFORMATION.CONTRACT_CREATED_DATE,'m/d/yyyy')></cfif>
			<cfif isdate(Program.BASIC_INFORMATION.CONTRACT_END_DATE)><CFSET Program.BASIC_INFORMATION.CONTRACT_END_DATE 		= DateFormat(Program.BASIC_INFORMATION.CONTRACT_END_DATE,'m/d/yyyy')></cfif>
			<cfif isdate(Program.BASIC_INFORMATION.CONTRACT_LOCK_DATE)><CFSET Program.BASIC_INFORMATION.CONTRACT_LOCK_DATE = DateFormat(Program.BASIC_INFORMATION.CONTRACT_LOCK_DATE,'m/d/yyyy')></cfif>
			<cfif isdate(Program.BASIC_INFORMATION.CONTRACT_START_DATE)><CFSET Program.BASIC_INFORMATION.CONTRACT_START_DATE 	= DateFormat(Program.BASIC_INFORMATION.CONTRACT_START_DATE,'m/d/yyyy')></cfif>
		</cfif>
		<cfif isdefined("Program.Formula_Pricing")>
			<cfloop index="x" from="1" to="#Program.Formula_Pricing.Periods.RecordCount#" step="1">
				<cfif isdate(evaluate("Program.Formula_Pricing.Periods.END_DATE_#x#"))><cfset "Program.Formula_Pricing.Periods.END_DATE_#x#"		= dateformat(evaluate("Program.Formula_Pricing.Periods.END_DATE_#x#"), 'm/d/yyyy')></cfif>
				<cfif isdate(evaluate("Program.Formula_Pricing.Periods.RELEASE_DATE_#x#"))><cfset "Program.Formula_Pricing.Periods.RELEASE_DATE_#x#"	= dateformat(evaluate("Program.Formula_Pricing.Periods.RELEASE_DATE_#x#"), 'm/d/yyyy')></cfif>
				<cfif isdate(evaluate("Program.Formula_Pricing.Periods.START_DATE_#x#"))><cfset "Program.Formula_Pricing.Periods.START_DATE_#x#"		= dateformat(evaluate("Program.Formula_Pricing.Periods.START_DATE_#x#"), 'm/d/yyyy')></cfif>
			</cfloop>
		</cfif>
		
		
		<cfif isdefined("Program.Products")>
			<cfloop index="x" from="1" to="#Program.Products.RecordCount#" step="1">
				<cfset "Program.Products.Date_Created_#x#"					= dateformat(evaluate("Program.Products.Date_Created_#x#"), 'm/d/yyyy')>
			</cfloop>
		</cfif>

