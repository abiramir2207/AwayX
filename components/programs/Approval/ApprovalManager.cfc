<cfcomponent displayname="ApprovalManager" hint="ApprovalManager" extends="components.AjaxCFC.ajax">

	<cffunction name="getProgramInfo" access="public" returntype="query">
		<cfargument name="program_id" type="string" required="true" />
		<CFQUERY NAME="qgetProgramInfo" datasource="#application.datasource#">
			SELECT 	Contract_Main.Contract_Main_ID,Contract_Main.Creating_User_Position_ID, Contract_Main.contract_start_date,Contract_Main.contract_end_date,
					DateDiff(d, Contract_Main.contract_start_date,Contract_Main.contract_end_date) + 1 as Program_Span,
					Contract_Main.contract_title,Contract_Main.contract_number,
					Contract_Main.ProgramType_ID, Contract_Main.Contract_Status_Type_IDX,
					Is_A_Revision, Auto_Renew, ISNULL(Scorecard_program_agree,0) as Scorecard_Count,
					Contract_Main_Aux_Data.Equipment_Placement,Contract_Main.REVISION_OF_CONTRACT_MAIN_ID,
					modifying_program, Contract_Main_Aux_Data.RevisionTypeA,
					Contract_Main_Aux_Data.RevisionTypeC, Contract_Main_Aux_Data.RevisionTypeB,
					Contract_Main.Pullback_Available, Contract_Main_Aux_Data.Pullback_Approved,
					Contract_Main_Aux_Data.Pullback_Approved_By, Contract_Main_Aux_Data.Pullback_Approved_Date,
					Contract_Main.revision_version, Contract_Main.Approved,
					ISNULL(Contract_Main_Aux_Data.Program_Spend, 0) AS Program_Spend,
					ISNULL(Contract_Main_Aux_Data.Program_Spend_In_Margin_UOT, 0) AS Program_Spend_In_Margin_UOT,
					ISNULL(Contract_Main_Aux_Data.Program_Spend_Non_Lumpsum_Distributor, 0) AS Program_Spend_Non_Lumpsum_Distributor,
					ISNULL(Contract_Main_Aux_Data.Program_Spend_Lumpsum_Distributor, 0) AS Program_Spend_Lumpsum_Distributor,
					ISNULL(Contract_Main_Aux_Data.Program_Spend_Non_Lumpsum_Operator, 0) AS Program_Spend_Non_Lumpsum_Operator,
					ISNULL(Contract_Main_Aux_Data.Program_Spend_Lumpsum_Operator, 0) AS Program_Spend_Lumpsum_Operator,
					ISNULL(Contract_Main_Aux_Data.Program_Spend_Non_Lumpsum_Broker, 0) AS Program_Spend_Non_Lumpsum_Broker,
					ISNULL(Contract_Main_Aux_Data.Program_Spend_Lumpsum_Broker, 0) AS Program_Spend_Lumpsum_Broker,
					Contract_Main_Aux_Data.Simple_Budget_ID,
					Contract_Main_Aux_Data.Freight_Component_Type,
					Program_Control_Panel_Options.Freight_Approval_Required,
					Program_Control_Panel_Options.Freight_Program,
					ISNULL(Program_Control_Panel_Options.Approval_Considerations_ID, 0) AS Approval_Considerations_ID,
					Contract_Main_Aux_Data.Freight_Approved,
					Contract_Main_Aux_Data.Price_List_ID,
					Contract_Main_Aux_Data.priceBracket_Update,
					Program_Control_Panel_Options.Manual_Selection_Of_Approvers
					,Program_Control_Panel_Options.Ideal_Price
					,Contract_Main.Contract_Is_Locked
	   			,Contract_Main.Contract_Locked_By_User_ID
			FROM 	Contract_Main
			LEFT JOIN Contract_Main_Aux_Data
			ON Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
			INNER JOIN Program_Control_Panel_Options
			ON		Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
			WHERE 	Contract_Main.Contract_Main_ID = '#arguments.Program_ID#'
		</CFQUERY>
		<cfreturn qgetProgramInfo />
	</cffunction>

	<cffunction name="getGroupswithoutProducts" access="public" returntype="query">
		<cfargument name="program_id" type="string" required="true" />
		<CFQUERY NAME="qgetGroupswithoutProducts" datasource="#application.datasource#">
		SELECT DISTINCT PROGRAM_GROUP_PRODUCTS_ID,
			PROGRAM_ID,
			PGPNC.Group_ID,
			PGPNC.PRODUCT_TYPE_ID,
			RATE,
			uom,
			description,
			UOM.Abbreviation
		FROM Program_Groups_Products_Not_Captured PGPNC
		INNER JOIN Contract_Products CP ON
			CP.Contract_Main_Id = '#arguments.program_id#' AND
			CP.PRODUCT_GROUP_ID = PGPNC.Group_ID AND
			CP.IS_Group = 1 AND
			CP.Deleted = 0
		LEFT JOIN	Units_of_Measure UOM ON
					UOM.Unit_Of_Measure_ID = PGPNC.UOM
		WHERE program_id  = '#arguments.program_id#'
		order by PGPNC.Group_ID,
				 description
		</CFQUERY>
		<cfreturn qgetGroupswithoutProducts />
	</cffunction>

	<!--- Does the program contain lumpsum or growth --->
	<cffunction name="getProgramLumpsumOrGrowth" access="private" returntype="boolean">
		<cfargument name="program_id" type="string" required="true" />

		<cfset var bGrowthOrLS = 0>

		<CFQUERY NAME="qgetProgramLumpsum" datasource="#application.datasource#">
			SELECT COUNT(*) As LSCompCount
			FROM Program_Lump_Sums
			WHERE program_id = '#arguments.Program_ID#'
			AND deleted = 0
		</CFQUERY>

		<CFQUERY NAME="qgetProgramGrowth" datasource="#application.datasource#">
			SELECT COUNT(*) As GrowthCompCount
			FROM Program_Growth_Components
			WHERE program_id = '#arguments.Program_ID#'
			AND deleted = 0
		</CFQUERY>

			<!--- If the program has growth or lumpsum --->
			<CFIF qgetProgramLumpsum.LSCompCount GT 0 OR qgetProgramGrowth.GrowthCompCount GT 0>
				<cfset bGrowthOrLS = 1>
			</CFIF>

			<cfreturn bGrowthOrLS />
	</cffunction>

	<cffunction name="getlumpsumwithoutprods" access="public" returntype="query">
		<cfargument name="program_id" type="string" required="true" />
		<CFQUERY NAME="qgetlumpsumwithoutprods" datasource="#application.datasource#">
			select distinct ISNULL(sum(ISNULL(cast(lump_sum_amount as float),0)),0) as lumpsumamount from
			Program_Lump_Sums
			where program_id = '#arguments.Program_ID#'
			and Program_Lump_Sums.deleted = 0
			and Program_Lump_Sum_ID NOT IN (select distinct
			Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID from Program_Lump_Sum_Product_Data
			where Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID = Program_Lump_Sums.Program_Lump_Sum_ID
			and Program_Lump_Sum_Product_Data.deleted = 0)
	</CFQUERY>
		<cfreturn qgetlumpsumwithoutprods />
	</cffunction>

	<cffunction name="getlumpsumwithprods" access="public" returntype="query">
		<cfargument name="program_id" type="string" required="true" />
		<CFQUERY NAME="qgetlumpsumwithprods" datasource="#application.datasource#">
			select distinct ISNULL(sum(ISNULL(cast(lump_sum_amount as float),0)),0) as lumpsumamount from
			Program_Lump_Sums
			where program_id = '#arguments.Program_ID#'
			and Program_Lump_Sums.deleted = 0
			and Program_Lump_Sum_ID IN (select distinct
			Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID from Program_Lump_Sum_Product_Data
			where Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID = Program_Lump_Sums.Program_Lump_Sum_ID
			and Program_Lump_Sum_Product_Data.deleted = 0)
	</CFQUERY>
		<cfreturn qgetlumpsumwithprods />
	</cffunction>

	<cffunction Name="autoApproveEZProducts" access="public" output="false" returntype="query">
		<cfargument name="programID" type="numeric" required="true" />
		<cfargument name="userID" type="string" required="true" />
		<cfset var qProductsNotApproved = queryNew('BSA_Foodservice_Items_Master_ID')/>
		<!--- D28783: Release 7 EZ Button Max Rate
			On program approval, auto-approve logic need to be adjusted to account for each product.
			- When template is set as max rate, products that are within the template max rate can be auto approved
			- When template is set as absolute rate, products that are included in the template product list can be auto approved
			- Template max rate / product list should come from the latest version of the template.
			- Products that did not get approved need to go through regular approval process
			- Program can get auto approved if all products are auto-approved
		--->
		<!--- D45263 :: Create table to store max rates by template/profile --->
		<CFQUERY NAME="qAutoApproveProducts" datasource="#application.datasource#">
			INSERT INTO Program_Type_Code_Approval_Info (Program_Id, Product_Id, Approve, type, User_Id)
			select	distinct #arguments.programID#, BSA_Foodservice_Items_Master_ID, 1, 1, '#arguments.userID#'
			from	DBO.UDF_EZ_GET_PROGRAM_PRODUCTS (#arguments.programID#, 'WITHIN_EZ_RATE', #request.AccessStructure.Profiles_ID#)
		</CFQUERY>

		<cfset qProductsNotApproved = this.productsNotApproved(arguments.programID,arguments.userID) />

		<cfreturn qProductsNotApproved />
	</cffunction>

	<cffunction Name="autoApproveMarketPriceProducts" access="public" output="false" returntype="query">
		<cfargument name="programID" type="numeric" required="true" />
		<cfargument name="userID" type="string" required="true" />
		<!--- D32895 :: Market Price Approval
			On program approval, auto-approve logic need to be adjusted to account for each product.
			- Similar to EZ Button max rate, Items that are on the Program and are at
			- Market POrice rate, do not need to go through Margin Approval.
		--->
		<cfset var qProductsNotApproved = queryNew('BSA_Foodservice_Items_Master_ID')/>
		<!---  ????????????????????????????? IS EXISTS LOGIC OK      ????????????????????????????????????????? --->
		<CFQUERY NAME="qAutoApproveProducts" datasource="#application.datasource#">
			INSERT INTO Program_Type_Code_Approval_Info (Program_Id, Product_Id, Approve, type, User_Id)
			SELECT	DISTINCT MPPA.Contract_Main_Id, MPPA.BSA_Foodservice_Items_Master_ID, 1, 1, '#arguments.userID#'
			FROM	Market_Price_Program_Approvals MPPA
			LEFT JOIN Program_Type_Code_Approval_Info PCTAI_Exist ON
				PCTAI_Exist.Program_Id = MPPA.Contract_Main_Id AND
				PCTAI_Exist.Product_Id = MPPA.BSA_Foodservice_Items_Master_ID AND
				PCTAI_Exist.Approve = 1 AND
				PCTAI_Exist.deleted = 0
			INNER JOIN Contract_Products CP_Include ON
				CP_Include.Contract_Main_ID =  MPPA.Contract_Main_Id AND
				CP_Include.BSA_Foodservice_Items_Master_ID = MPPA.BSA_Foodservice_Items_Master_ID AND
				CP_Include.Deleted = 0 AND
				CP_Include.Product_Type_ID = 1
			LEFT JOIN Contract_Products CP_Exclude ON
				CP_Exclude.Contract_Main_ID =  MPPA.Contract_Main_Id AND
				CP_Exclude.BSA_Foodservice_Items_Master_ID = MPPA.BSA_Foodservice_Items_Master_ID AND
				CP_Exclude.Deleted = 0 AND
				CP_Exclude.Product_Type_ID != 1
			WHERE MPPA.Contract_Main_Id = #arguments.programID# AND
				PCTAI_Exist.Program_Id IS NULL AND
				CP_Exclude.Contract_Main_ID IS NULL AND --ITEM is not on program in another component
				CP_Include.Contract_Main_ID IS NOT NULL --ITEM is on a Fixed Component
		</CFQUERY>

		<cfset qProductsNotApproved = this.productsNotApproved(arguments.programID,arguments.userID) />

		<cfreturn qProductsNotApproved />
	</cffunction>

	<cffunction Name="autoApproveProductsRatesNotChanged" access="public" output="true" returntype="void">
		<cfargument name="Parent_Contract_Main_ID" type="numeric" />
		<cfargument name="Child_Contract_Main_ID" type="numeric" />
		<cfargument name="userID" type="string" required="true" />

			<!--- -Does the program have growth or lumpsum --->
			<cfset bGrowthOrLS = getProgramLumpsumOrGrowth(arguments.Child_Contract_Main_ID)>
			<cfset this.qGetChangeLog = CreateObject("component", "components.programs.ReviseLog").init() />
			<cfset qGetOtherChanges = this.qGetChangeLog.PrgChanges(arguments.Child_Contract_Main_ID)/><!--- D48293 :: Update short cut routing and auto approve product settings --->
			<!--- If the program does not have growth or lumpsum
			D48293 :: Update short cut routing and auto approve product settings
			Added Operator Added and Date changes check
			--->
			<cfif bGrowthOrLS eq 0 AND qGetOtherChanges.Operators_Added EQ 0 AND qGetOtherChanges.Start_Date_Changed EQ 0 AND qGetOtherChanges.End_Date_Changed EQ 0>

				<cfset qGetFixedProductsRatesChanged = this.qGetChangeLog.GetFixedProductsRatesUOMChanged(arguments.Child_Contract_Main_ID, arguments.Parent_Contract_Main_ID, 0,1) />
				<cfset qGetRebateProductsRatesChanged = this.qGetChangeLog.GetRebateProductsRatesUOMChanged(arguments.Child_Contract_Main_ID, arguments.Parent_Contract_Main_ID, 0,1) />


				<!--- On which product did rate change (UOM change means rate change too) OR which was a new product added. --->
				<cfquery name="qRateChanged" datasource="#application.datasource#">
					Select 	DISTINCT BSA_Foodservice_Items_Master_ID
					from 	##TMP_RebateProductsRatesUOMChanged
					<!--- On the revision, we are lookiing for "Rate Change" only.
					UOM Change means Rate Change too
					--->
					where  	(Rate_Change = 1 OR Uom_Change = 1)
					<!--- On the revision, we are also looking for cases where product has been added.
					"Rate2" will be "-1", when a product has been added.
					Note: If the only change in the revision, then we will not consider the products on that
					program for auto approval.
					"##TMP_RebateProductsRatesUOMChanged" will not contain the deleted record.
					--->
					OR Rate2 = '-1'

					UNION
					Select 	DISTINCT BSA_Foodservice_Items_Master_ID
					from 	##TMP_FixedProductsRatesUOMChanged
					<!--- We are lookiing for "Rate Change" only.
					UOM Change means Rate Change too
					--->
					where  	(Rate_Change = 1 OR Uom_Change = 1)
					<!--- On the revision, we are also looking for cases where product has been added.
					""Rate2" will be "-1", when a product has been added.
					Note: If the only change in the revision, then we will not consider the products on that
					program for auto approval.
					"##TMP_FixedProductsRatesUOMChanged" will not contain the deleted record.
					--->
					OR Rate2 = '-1'
				</cfquery>

				<cfif qRateChanged.recordcount GT 0>
					<CFQUERY NAME="qAutoApproveProducts" datasource="#application.datasource#">
					INSERT INTO Program_Type_Code_Approval_Info (Program_Id, Product_Id, Approve, type, User_Id)
					SELECT DISTINCT '#arguments.Child_Contract_Main_ID#', BSA_Foodservice_Items_Master_ID, 1, 1, '#arguments.userID#'
					FROM 	##TMP_RebateProductsRatesUOMChanged
					/* W*/
					WHERE  BSA_Foodservice_Items_Master_ID
					NOT IN
					(
						#QuotedValueList(qRateChanged.BSA_Foodservice_Items_Master_ID)#
					)
					/* Avoid duplicate record. It may be possible that some other process already inserted the product_id for the program. */
					AND BSA_Foodservice_Items_Master_ID NOT IN
					(
						SELECT Product_Id
						FROM Program_Type_Code_Approval_Info
						WHERE ##TMP_RebateProductsRatesUOMChanged.BSA_Foodservice_Items_Master_ID = Program_Type_Code_Approval_Info.Product_Id
						AND Program_Type_Code_Approval_Info.Program_Id =  '#arguments.Child_Contract_Main_ID#'
						AND deleted = 0
					)

					UNION

					SELECT 	DISTINCT '#arguments.Child_Contract_Main_ID#', BSA_Foodservice_Items_Master_ID, 1, 1, '#arguments.userID#'
					FROM 	##TMP_FixedProductsRatesUOMChanged
					WHERE  BSA_Foodservice_Items_Master_ID
					NOT IN
					(
						#QuotedValueList(qRateChanged.BSA_Foodservice_Items_Master_ID)#
					)
					/* Avoid duplicate record. It may be possible that some other process already inserted the product_id for the program. */
					AND BSA_Foodservice_Items_Master_ID NOT IN
					(
						SELECT Product_Id
						FROM Program_Type_Code_Approval_Info
						WHERE ##TMP_FixedProductsRatesUOMChanged.BSA_Foodservice_Items_Master_ID = Program_Type_Code_Approval_Info.Product_Id
						AND Program_Type_Code_Approval_Info.Program_Id =  '#arguments.Child_Contract_Main_ID#'
						AND deleted = 0
					)
					</CFQUERY>
				</cfif>
			</cfif>
	</cffunction>

	<cffunction Name="productsNotApproved" access="public" output="false" returntype="query">
		<cfargument name="programID" type="numeric" required="true" />
		<cfargument name="userID" type="string" required="true" />
		<cfset var qProductsNotApproved = queryNew('BSA_Foodservice_Items_Master_ID')/>
		<!--- Common query to return Products Not approved
		--->

		<CFQUERY NAME="qProductsNotApproved" datasource="#application.datasource#">
			<!--- Get products that are not flagged as approved --->
			SELECT	BSA_Foodservice_Items_Master_ID
			FROM	Contract_Products
			WHERE	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.programID#" />
			AND		Deleted = 0
			AND		IS_Group = 0
			AND		BSA_Foodservice_Items_Master_ID not in
			(	select 	Product_Id
				from 	Program_Type_Code_Approval_Info
				where 	Program_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.programID#" />
				and 	deleted = 0
				and 	Approve = 1
				and		Product_Id is not null
			)
			union
			<!--- Get groups that do not have members --->
			select	BSA_Foodservice_Items_Master_ID
			from	contract_products
			where	contract_main_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.programID#" />
			and		Deleted = 0
			and		Is_Group = 1
			and		not exists
			(
				select	mem.contract_products_id
				from	contract_products mem
				where	mem.Contract_Main_ID = contract_products.Contract_Main_ID
				and		mem.Product_Group_ID = contract_products.BSA_Foodservice_Items_Master_ID
				and		mem.Product_Type_ID = contract_products.Product_Type_ID
				and		mem.Deleted = 0
				and		mem.Captured_From_Group = 1
			)

		</CFQUERY>

		<cfreturn qProductsNotApproved />
	</cffunction>

	<cffunction Name="checkProgramApprovalByProfile" access="public" output="false" returntype="boolean">

		<cfargument name="programID" type="numeric" required="true" />

		<cfscript>
			//declare local vars
			qGetProgramApprovalByProfile	= "";
			nProgramID						= "";
			bReturnVal						= "";

			//assign local vars
			nProgramID	= arguments.programID;
			bReturnVal	= 0;
		</cfscript>

		<cfquery name="qGetProgramApprovalByProfile" datasource="#application.datasource#">
			SELECT	*
			FROM	Program_Approval_By_Profile
			WHERE	Program_ID = '#nProgramID#'
			AND		Deleted = 0
		</cfquery>

		<cfif qGetProgramApprovalByProfile.RecordCount>
			<cfset bReturnVal = 1 />
		</cfif>

		<cfreturn bReturnVal />

	</cffunction>

	<cffunction access="public" Name="saveProgramApprovalByProfile" output="false" returntype="query">

		<cfargument name="programID" 	type="numeric"	required="true" />
		<cfargument name="templateID"	type="numeric"	required="true" />
		<cfargument name="userIds"		type="string" 	required="true" />

		<cfscript>
			//declare local vars
			qSaveProgramApprovalByProfile	= "";
			qReturnProgramApprovalByProfile	= "";
			nProgramID						= "";
			nTemplateID						= "";
			lUserIds						= "";

			//assign local vars
			nProgramID	= arguments.programID;
			nTemplateID	= arguments.templateID;
			lUserIds	= arguments.userIds;

		</cfscript>

		<cfquery name="qSaveProgramApprovalByProfile" datasource="#application.datasource#">
			INSERT INTO Program_Approval_By_Profile
			(
				ProgramControl_Panel_Options_ID,
				Program_ID,
				Profiles_ID,
				Approved_By_User_ID
			)

			select	DISTINCT
					#nTemplateID#,
					#nProgramID#,
					p.Profiles_ID,
					u.User_ID
			from	Profiles p
					inner join Profiles_Settings ps on ps.Profiles_ID = p.Profiles_ID
					and ps.Deleted = 0
					inner join _Users u on u.Profiles_ID = ps.Profiles_ID and u.Deleted = 0
			where	p.Deleted = 0
			and		u.User_ID IN (#ListQualify(lUserIds, "'")#)
		</cfquery>

		<cfquery name="qReturnProgramApprovalByProfile" datasource="#application.datasource#">

			SELECT	Program_Approval_By_Profile_ID,
					ProgramControl_Panel_Options_ID
					Program_ID,
					Program_Approval_By_Profile.Profiles_ID,
					Approved_By_User_ID,
					u.User_Email
			FROM	Program_Approval_By_Profile
					INNER JOIN _Users u on u.User_ID = Program_Approval_By_Profile.Approved_By_User_ID
			WHERE	ProgramControl_Panel_Options_ID = '#nTemplateID#'
			AND		Program_ID = '#nProgramID#'

		</cfquery>

		<cfreturn qReturnProgramApprovalByProfile />

	</cffunction>

	<cffunction Name="checkProgramApprovalByProfileUser" access="public" output="false" returntype="boolean">

		<cfargument name="programID" type="numeric" required="true" />
		<cfargument name="userID" 	type="string" required="true" />

		<cfscript>
			//declare local vars
			qCheckProgramApprovalByProfile	= "";
			nProgramID						= "";
			strUserID						= "";
			bReturnVal						= "";

			//assign local vars
			nProgramID	= arguments.programID;
			strUserID	= arguments.userID;
			bReturnVal	= 0;
		</cfscript>

		<cfquery name="qCheckProgramApprovalByProfile" datasource="#application.datasource#">
			SELECT	*
			FROM	Program_Approval_By_Profile
			WHERE	Program_ID = '#nProgramID#'
			AND		Approved_By_User = 0
			AND		Deleted = 0
		</cfquery>

		<cfif (qCheckProgramApprovalByProfile.RecordCount eq 1 and qCheckProgramApprovalByProfile.Approved_By_User_ID eq strUserID) OR qCheckProgramApprovalByProfile.RecordCount eq 0>
			<cfset bReturnVal = 1 />
		</cfif>

		<cfreturn bReturnVal />

	</cffunction>

	<cffunction Name="flagAsApprovedByUserProfile" access="public" output="false">

		<cfargument name="programID" type="numeric" required="true" />
		<cfargument name="profileID" type="numeric" required="true" />
		<cfargument name="userID" 	type="string" required="true" />

		<cfscript>
			//declare local vars
			qFlagProgramApprovalByProfile	= "";
			nProgramID						= "";
			nProfileID						= "";
			strUserID						= "";
			bReturnVal						= "";

			//assign local vars
			nProgramID	= arguments.programID;
			nProfileID	= arguments.profileID;
			strUserID	= arguments.userID;
			bReturnVal	= 0;
		</cfscript>

		<cfquery name="qFlagProgramApprovalByProfile" datasource="#application.datasource#">
			UPDATE	Program_Approval_By_Profile
			SET		Approved_By_User = 1,
					Approved_By_User_Date = getDate()
			WHERE	Program_ID = '#nProgramID#'
			AND		Profiles_ID = '#nProfileID#'
			AND		Approved_By_User_ID = '#strUserID#'
			AND		Deleted = 0
		</cfquery>

	</cffunction>

</cfcomponent>