<cfcomponent hint="Revision Change Log" extends="components.Base">

	<cffunction name="init" output="false" returntype="components.programs.ReviseLog">

		<cfreturn this />

	</cffunction>

	<cffunction name="getOperatorsChanged" output="false" returntype="query">

		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<cfargument name="showOnlyChange" required="true">

		<cfquery name="qGetOperator" datasource="#application.datasource#">
			SELECT
					CASE
					WHEN Child_Contract_Operators.BSA_Operator_ID IS NULL THEN
						''
					ELSE
						BSA_Operator.Operator_Name
					END As Child_Name,
					CASE
					WHEN Parent_Contract_Operators.BSA_Operator_ID IS NULL THEN
						''
					ELSE
						BSA_Operator.Operator_Name
					END As Parent_Name,
					CASE
					WHEN Child_Contract_Operators.BSA_Operator_ID IS NULL THEN
						''
					ELSE
						BSA_Operator.legacy_id
					END As Child_Legacy_id,
					CASE
					WHEN Parent_Contract_Operators.BSA_Operator_ID IS NULL THEN
						''
					ELSE
						BSA_Operator.legacy_id
					END As Parent_Legacy_id,
					CASE
					WHEN Child_Contract_Operators.BSA_Operator_ID IS NULL AND Parent_Contract_Operators.BSA_Operator_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE
					WHEN Child_Contract_Operators.BSA_Operator_ID IS NOT NULL AND Parent_Contract_Operators.BSA_Operator_ID IS NULL THEN
						1
					ELSE
						0
					END As Added,
					0 As Change
			FROM	Contract_Main
					LEFT JOIN Contract_Operators Child_Contract_Operators
					ON	Child_Contract_Operators.Deleted = 0
					AND	Child_Contract_Operators.Contract_Main_ID = Contract_Main.Contract_Main_ID
					LEFT JOIN Contract_Operators Parent_Contract_Operators
					ON	Parent_Contract_Operators.Deleted = 0
					AND	Parent_Contract_Operators.Contract_Main_ID = #arguments.ProgramId2#
					AND	Child_Contract_Operators.BSA_Operator_ID = Parent_Contract_Operators.BSA_Operator_ID
					INNER JOIN BSA_Operator
					ON	BSA_Operator.Deleted = 0
					AND	(BSA_Operator.BSA_Operator_ID = Child_Contract_Operators.BSA_Operator_ID
						OR
						BSA_Operator.BSA_Operator_ID = Parent_Contract_Operators.BSA_Operator_ID
						)
					AND ISNULL(Child_Contract_Operators.BSA_Operator_ID, Parent_Contract_Operators.BSA_Operator_ID) = ISNULL(Parent_Contract_Operators.BSA_Operator_ID, Child_Contract_Operators.BSA_Operator_ID)
					<cfif arguments.showOnlyChange>
					AND Parent_Contract_Operators.BSA_Operator_ID IS NULL
					</cfif>
					<!------ AND (Child_Contract_Operators.BSA_Operator_ID IS NULL OR Parent_Contract_Operators.BSA_Operator_ID IS NULL) ----->
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
			ORDER BY Child_Legacy_ID
		</cfquery>

		<cfreturn qGetOperator>

	</cffunction>

	<cffunction name="getDistributorsChanged" output="false" returntype="query">

		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<cfargument name="showOnlyChange" required="true">

		<cfquery name="qGetDistributor" datasource="#application.datasource#">
			SELECT	DISTINCT BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
					CASE
					WHEN Child_Contract_Distributors.BSA_Foodservice_Customers_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Customers.Name
					END As Child_Name,
					CASE
					WHEN Parent_Contract_Distributors.BSA_Foodservice_Customers_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Customers.Name
					END As Parent_Name,
					CASE
					WHEN Child_Contract_Distributors.BSA_Foodservice_Customers_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Customers.shr_ship_to
					END As Child_shr_ship_to,
					CASE
					WHEN Parent_Contract_Distributors.BSA_Foodservice_Customers_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Customers.shr_ship_to
					END As Parent_shr_ship_to,
					Child_Contract_Distributors.BSA_Foodservice_Customers_ID Child_ID,
					Parent_Contract_Distributors.BSA_Foodservice_Customers_ID Parent_ID,
					Parent_Contract_Distributors.Program_Weight Parent_Weight,
					Child_Contract_Distributors.Program_Weight Child_Weight,
					CASE
					WHEN Child_Contract_Distributors.BSA_Foodservice_Customers_ID IS NULL AND Parent_Contract_Distributors.BSA_Foodservice_Customers_ID IS NOT NULL THEN
						1
					ELSE
						0
					END As Deleted,
					CASE
					WHEN Child_Contract_Distributors.BSA_Foodservice_Customers_ID IS NOT NULL AND Parent_Contract_Distributors.BSA_Foodservice_Customers_ID IS NULL THEN
						1
					ELSE
						0
					END As Added,
					CASE
					WHEN Child_Contract_Distributors.BSA_Foodservice_Customers_ID IS NOT NULL AND Parent_Contract_Distributors.BSA_Foodservice_Customers_ID IS NOT NULL AND Parent_Contract_Distributors.Program_Weight <> Child_Contract_Distributors.Program_Weight THEN
						1
					ELSE
						0
					END As Change
			FROM	Contract_Main
					LEFT JOIN Contract_Distributors Child_Contract_Distributors
					ON	Child_Contract_Distributors.Deleted = 0
					AND	Child_Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
					LEFT JOIN Contract_Distributors Parent_Contract_Distributors
					ON	Parent_Contract_Distributors.Deleted = 0
					AND	Parent_Contract_Distributors.Contract_Main_ID = #arguments.ProgramId2#
					AND	Child_Contract_Distributors.BSA_Foodservice_Customers_ID = Parent_Contract_Distributors.BSA_Foodservice_Customers_ID
					INNER JOIN BSA_Foodservice_Customers
					ON	BSA_Foodservice_Customers.Deleted = 0
					AND	(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Child_Contract_Distributors.BSA_Foodservice_Customers_ID
						OR
						BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Parent_Contract_Distributors.BSA_Foodservice_Customers_ID
						)
					AND ISNULL(Child_Contract_Distributors.BSA_Foodservice_Customers_ID, Parent_Contract_Distributors.BSA_Foodservice_Customers_ID) = ISNULL(Parent_Contract_Distributors.BSA_Foodservice_Customers_ID, Child_Contract_Distributors.BSA_Foodservice_Customers_ID)
					<cfif arguments.showOnlyChange>
					AND Parent_Contract_Distributors.BSA_Foodservice_Customers_ID IS NULL
					</cfif>
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
			ORDER BY Parent_Shr_Ship_To
		</cfquery>

		<cfreturn qGetDistributor>

	</cffunction>

	<cffunction name="getProductsChanged" output="false" returntype="query">

		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<cfargument name="showOnlyChange" required="true">

		<!--- Dev Note: KAL; D17007: 5.1 Shortcut Changes - Add Product_Type_ID to the join condition and Select part --->
		<cfquery name="qGetProductsChanged" datasource="#application.datasource#">
			SELECT	DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					Type_Code_Desc.Type_Code_Desc, First_Contract_Products.Product_Type_ID,
					First_Contract_Products.BSA_Foodservice_Items_Master_ID First_ID,
					Second_Contract_Products.BSA_Foodservice_Items_Master_ID Second_ID,
					CASE
						WHEN	First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN ''
						ELSE	BSA_Foodservice_Items_Master.Description
					END As First_Name,
					CASE
						WHEN 	Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN ''
						ELSE	BSA_Foodservice_Items_Master.Description
					END As Second_Name,
					CASE
						WHEN 	First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN ''
						ELSE	BSA_Foodservice_Items_Master.item
					END As First_ItemNumber,
					CASE
						WHEN 	Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN ''
						ELSE	BSA_Foodservice_Items_Master.item
					END As Second_ItemNumber,
					CASE
						WHEN 	First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL
								AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL THEN 1
						ELSE	0
					END As Deleted,
					CASE
						WHEN 	First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL
								AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL THEN 1
						ELSE	0
					END As Added,
					CASE
						WHEN 	First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL
								AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL THEN 1
						ELSE	0
					END As Change
					,First_Contract_Products.IS_group <!--- D32283 Add Setting for EZ Button Program revisios --->
			FROM	Contract_Main
					INNER JOIN Contract_Products First_Contract_Products
					ON	First_Contract_Products.Deleted = 0
					AND	First_Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND
					(
						(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
						OR
						(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
					)
					LEFT JOIN Contract_Products Second_Contract_Products
					ON	Second_Contract_Products.Deleted = 0
					AND	Second_Contract_Products.Contract_Main_ID = <cfqueryparam cfsqltype="integer" value="#arguments.ProgramId2#"/>
					AND	First_Contract_Products.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
					AND	First_Contract_Products.Product_Type_ID = Second_Contract_Products.Product_Type_ID
					AND
					(
						(Second_Contract_Products.Product_Group_ID = CAST(Second_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Second_Contract_Products.Is_Group = 1)
						OR
						(ISNULL(Second_Contract_Products.Product_Group_ID, '') = '' AND Second_Contract_Products.Is_Group = 0)
					)
					INNER JOIN BSA_Foodservice_Items_Master
					ON	BSA_Foodservice_Items_Master.Deleted = 0
					AND	(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = First_Contract_Products.BSA_Foodservice_Items_Master_ID
						OR
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
						)
					<cfif arguments.showOnlyChange>
					AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL
					</cfif>
					AND ISNULL(First_Contract_Products.BSA_Foodservice_Items_Master_ID, Second_Contract_Products.BSA_Foodservice_Items_Master_ID) = ISNULL(Second_Contract_Products.BSA_Foodservice_Items_Master_ID, First_Contract_Products.BSA_Foodservice_Items_Master_ID)
					LEFT JOIN Type_Code_Desc ON Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
			WHERE	Contract_Main.Contract_Main_ID = <cfqueryparam cfsqltype="integer" value="#arguments.ProgramId1#"/>
			order by  Second_ItemNumber
			-- Type_Code_Desc.Type_Code_Desc
		</cfquery>

		<cfreturn qGetProductsChanged />

	</cffunction>

	<!--- Check if products added in Fixed Price at List Price --->
	<cffunction name="getProductsAddedFixedEqPricelist" output="false" returntype="string">
		<cfargument name="Parent_Contract_Main_ID" type="numeric" required="true">
		<cfargument name="Child_Contract_Main_ID" type="numeric" required="true">

		<cfstoredproc procedure="Check_Products_Added_FixedEqPricelist" datasource="#application.datasource#" >
			<cfprocparam cfsqltype="CF_SQL_INTEGER" type="in" value="#arguments.Parent_Contract_Main_ID#" />
			<cfprocparam cfsqltype="CF_SQL_INTEGER" type="in" value="#arguments.Child_Contract_Main_ID#" />
			<cfprocparam cfsqltype="CF_SQL_VARCHAR" type="out" variable="Check_FixedEqPricelist" />
		</cfstoredproc>

		<cfreturn Check_FixedEqPricelist />
	</cffunction>

	<!--- Field Values Changed Check  --->
	<cffunction name="getFieldValueChanged" output="false" returntype="boolean">

		<cfargument name="Parent_Contract_Main_ID"	type="numeric"	required="Yes" />
		<cfargument name="Child_Contract_Main_ID"	type="numeric"	required="Yes" />
		<cfargument name="FieldNametoCheck"			type="string"	required="true" />

		<cfset FieldChanged = 1 />	<!--- By defalut assuming field has changed, if not after comparission, then this is set to 0--->

		<cfset useLakebaseForqGetFieldInfoParent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqGetFieldInfoParent>
	<cftry>
		<cfset qGetFieldInfoParent = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#arguments.Parent_Contract_Main_ID#",
				"select" = "fieldnametocheck#"
			}), "fieldnametocheck#"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetFieldInfoParent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetFieldInfoParent>
<CFQUERY NAME="qGetFieldInfoParent" datasource="#application.datasource#">
			SELECT #arguments.FieldNametoCheck#
			FROM Contract_Main
			WHERE Contract_Main_ID = '#arguments.Parent_Contract_Main_ID#'
		</CFQUERY>
</cfif>
		<cfset useLakebaseForqGetFieldInfoChild = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqGetFieldInfoChild>
	<cftry>
		<cfset qGetFieldInfoChild = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#arguments.Child_Contract_Main_ID#",
				"select" = "fieldnametocheck#"
			}), "fieldnametocheck#"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetFieldInfoChild = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetFieldInfoChild>
<CFQUERY NAME="qGetFieldInfoChild" datasource="#application.datasource#">
			SELECT #arguments.FieldNametoCheck#
			FROM Contract_Main
			WHERE Contract_Main_ID = '#arguments.Child_Contract_Main_ID#'
		</CFQUERY>
</cfif>

		<cfif qGetFieldInfoParent.recordCount OR qGetFieldInfoChild.recordCount>
			<cfif (Evaluate("qGetFieldInfoParent.#arguments.FieldNametoCheck#") EQ Evaluate("qGetFieldInfoChild.#arguments.FieldNametoCheck#"))>
				<cfset FieldChanged = 0 />
			</cfif>
		</cfif>

		<cfreturn FieldChanged />
	</cffunction>

	<!--- Flag Setter for third table --->
	<cffunction name="RevisionChangesFlags" output="false" returntype="numeric">

		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="FieldName" type="string"	required="true" />
		<cfargument name="RevisionTypeNum" type="numeric" required="false" default="0" />

		<cfset RevisionTypeNum = arguments.RevisionTypeNum + 1 />
		<!--- It is incremented becoz this function is called only if there is change and if there is a change and doesnt require approval scheme then in
		Program_Revision_Changes the value is 1 for that field else if approval is req and it is type A then it should be 2 and so on --->

		<cfset useLakebaseForqUpdateRevisionChanges = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_revision_changes")>
<cfif useLakebaseForqUpdateRevisionChanges>
	<cftry>
		<cfset application.oLakebase.updateRows("program_revision_changes",
			{
				"contract_main_id" = "eq.#arguments.programId#",
				"deleted" = "eq.0"
			},
			{
				"fieldname#" = "#RevisionTypeNum#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdateRevisionChanges = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdateRevisionChanges>
<cfquery name="qUpdateRevisionChanges" datasource="#application.datasource#">
			Update	Program_Revision_Changes
			SET		#arguments.FieldName# = #RevisionTypeNum#
			WHERE 	Contract_Main_ID = #arguments.programId#
			AND		Deleted = 0
		</cfquery>
</cfif>

		<cfreturn RevisionTypeNum />
	</cffunction>

	<!---Revision Types Flag Setter for Contract_main table --->
	<cffunction name="MinorReviseFlagSet" output="false" returntype="numeric">

		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="RevisionFlagType" type="numeric" required="true" default="0" />

		<cfif arguments.RevisionFlagType GT 0 AND arguments.RevisionFlagType LTE 4>
			<cfquery name="qUpdateContractMainAux" datasource="#application.datasource#">
				Update Contract_Main_Aux_Data
				SET
					<cfif arguments.RevisionFlagType EQ 4 >	RevisionTypeC = 1	</cfif>
					<cfif arguments.RevisionFlagType EQ 3 >	RevisionTypeB = 1	</cfif>
					<cfif arguments.RevisionFlagType EQ 2 >	RevisionTypeA = 1	</cfif>
					<cfif arguments.RevisionFlagType EQ 1 >	RevisionTypeA = 0, RevisionTypeB = 0, RevisionTypeC = 0 	</cfif>
				WHERE Contract_Main_ID = #arguments.programId#
			</cfquery>
		</cfif>

		<cfreturn RevisionFlagType />
	</cffunction>

	<cffunction name="PrgChanges" output="false" returntype="query">
		<cfargument name="programId" type="numeric" required="true" />
		<cfquery name="qPrgChanges" datasource="#application.datasource#">
			select   Products_Added
						, Products_Removed
						, Distributors_Removed
						, Distributors_Added
						, Operators_Added
						, Operators_Removed
						, Start_Date_Changed
						, End_Date_Changed
			from 	  Program_Revision_Changes
			where  Contract_Main_ID = #arguments.programId#
			and 	  Deleted = 0
		</cfquery>
		<cfreturn qPrgChanges />
	</cffunction>

	<cffunction name="getFixedProductsRatesUOMChanged" output="false" returntype="query">

		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<cfargument name="showOnlyChange" required="true">
		<cfargument name="UseTableResults" required="false" default="0">

		<cfif arguments.UseTableResults eq 1>
			<cfquery name="qDelFixedProductsRatesTbl" datasource="#application.datasource#">
				if object_id('tempdb..##TMP_FixedProductsRatesUOMChanged') is not null
				drop table ##TMP_FixedProductsRatesUOMChanged
			</cfquery>
		</cfif>

		<cfquery name="qgetFixedProductsRatesUOMChanged" datasource="#application.datasource#">
			SELECT DISTINCT
			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
			First_Contract_Products.BSA_Foodservice_Items_Master_ID First_ID,
			Second_Contract_Products.BSA_Foodservice_Items_Master_ID Second_ID,
			First_Program_Fixed_Component.Program_Fixed_Component_Name_Id as First_Comp_Name_Id,
			Second_Program_Fixed_Component.Program_Fixed_Component_Name_Id as Second_Comp_Name_Id,
			First_Fixed.Fixed_Price_Value First_Price,
			Second_Fixed.Fixed_Price_Value Second_Price,
			First_Units_Of_Measure.Abbreviation First_UOM,
			Second_Units_Of_Measure.Abbreviation Second_UOM,
			CASE
				WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL
				AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL
				AND (First_Program_Fixed_Component.Program_Fixed_Component_Name_Id = Second_Program_Fixed_Component.Program_Fixed_Component_Name_Id)
				AND (cast(First_Fixed.Fixed_Price_Value as float) <> cast(Second_Fixed.Fixed_Price_Value as float))
				THEN
					1
				ELSE
					0
			END As Rate_Change,
			CASE
				WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL
				AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL
				AND (First_Program_Fixed_Component.Program_Fixed_Component_Name_Id = Second_Program_Fixed_Component.Program_Fixed_Component_Name_Id)
				AND (First_Units_Of_Measure.Abbreviation <> Second_Units_Of_Measure.Abbreviation)
				THEN
					1
				ELSE
					0
				END As Uom_Change,
			CASE
				WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL
				AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL
				AND (First_Program_Fixed_Component.Program_Fixed_Component_Name_Id = Second_Program_Fixed_Component.Program_Fixed_Component_Name_Id)
				AND (First_Program_Fixed_Component.Claim_Mechanics <> Second_Program_Fixed_Component.Claim_Mechanics)
				THEN
					1
				ELSE
					0
				END As ClaimMech_Changed
				<!--- D34880: Max Rate Easy Button and Short Cut Routing--->
			,
							CAST(First_Fixed.Fixed_Price_Value as float) as  Rate1,
					                  CASE
					                        WHEN First_Fixed.Unit_Of_Measure_ID = Second_Fixed.Unit_Of_Measure_ID THEN <!--- Both are same --->
					                              CAST(Second_Fixed.Fixed_Price_Value as float)
					                        WHEN First_Fixed.Unit_Of_Measure_ID = 1 AND Second_Fixed.Unit_Of_Measure_ID = 2 THEN <!--- Both are different, convert second from lb to cs --->
					                              CAST(Second_Fixed.Fixed_Price_Value as float) * CAST(BSA_Foodservice_Items_Master.Net_Weight as float)
					                        WHEN First_Fixed.Unit_Of_Measure_ID = 2 AND Second_Fixed.Unit_Of_Measure_ID = 1 THEN <!--- Both are different, convert second from cs to lb --->
					                              CAST(Second_Fixed.Fixed_Price_Value as float) / CAST(BSA_Foodservice_Items_Master.Net_Weight as float)
					                        ELSE <!--- Both are different, cannot convert --->
					                              CAST(-1 as float)     <!--- D36386 --->
                  		END as Rate2
                  		,First_Contract_Products.IS_group
		<!--- D34880: Max Rate Easy Button and Short Cut Routing--->
			<cfif arguments.UseTableResults eq 1>
			INTO ##TMP_FixedProductsRatesUOMChanged
			</cfif>
			FROM	Contract_Main
			INNER JOIN Contract_Products First_Contract_Products
				ON	First_Contract_Products.Deleted = 0
				AND	First_Contract_Products.Product_Type_ID = 1
				AND	First_Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
				AND
				(
					(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
					OR
					(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
				)
			LEFT JOIN Contract_Products Second_Contract_Products
				ON	Second_Contract_Products.Deleted = 0
				AND	Second_Contract_Products.Product_Type_ID = 1
				AND	Second_Contract_Products.Contract_Main_ID = #arguments.ProgramId2#
				AND	First_Contract_Products.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
				AND
				(
					(Second_Contract_Products.Product_Group_ID = CAST(Second_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Second_Contract_Products.Is_Group = 1)
					OR
					(ISNULL(Second_Contract_Products.Product_Group_ID, '') = '' AND Second_Contract_Products.Is_Group = 0)
				)
			INNER JOIN Program_Fixed_Price_Product_Data First_Fixed
				ON	First_Fixed.Deleted = 0
				AND	First_Fixed.Contract_Products_ID = First_Contract_Products.Contract_Products_ID
			INNER JOIN Program_Fixed_Component First_Program_Fixed_Component
				ON First_Program_Fixed_Component.Program_Fixed_Component_Id = First_Fixed.Program_Fixed_Component_Id
				AND First_Program_Fixed_Component.deleted = 0
			LEFT JOIN Program_Fixed_Price_Product_Data Second_Fixed
				ON	Second_Fixed.Deleted = 0
				AND	Second_Fixed.Contract_Products_ID = Second_Contract_Products.Contract_Products_ID
			LEFT JOIN Program_Fixed_Component Second_Program_Fixed_Component
				ON	Second_Program_Fixed_Component.Program_Fixed_Component_Id = Second_Fixed.Program_Fixed_Component_Id
				AND Second_Program_Fixed_Component.Program_Fixed_Component_Name_Id = First_Program_Fixed_Component.Program_Fixed_Component_Name_Id
				AND Second_Program_Fixed_Component.Fixed_Component_Paid_to = First_Program_Fixed_Component.Fixed_Component_Paid_to
				AND Second_Program_Fixed_Component.deleted = 0
			INNER JOIN Units_Of_Measure First_Units_Of_Measure
				ON	First_Units_Of_Measure.Unit_Of_Measure_ID = First_Fixed.Unit_Of_Measure_ID
			LEFT JOIN Units_Of_Measure Second_Units_Of_Measure
				ON	Second_Units_Of_Measure.Unit_Of_Measure_ID = Second_Fixed.Unit_Of_Measure_ID
			INNER JOIN BSA_Foodservice_Items_Master
				ON	BSA_Foodservice_Items_Master.Deleted = 0
				AND
				(	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = First_Contract_Products.BSA_Foodservice_Items_Master_ID
					OR
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
				)
			<cfif arguments.showOnlyChange>
				AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL
			</cfif>
				AND ISNULL(First_Contract_Products.BSA_Foodservice_Items_Master_ID, Second_Contract_Products.BSA_Foodservice_Items_Master_ID) = ISNULL(Second_Contract_Products.BSA_Foodservice_Items_Master_ID, First_Contract_Products.BSA_Foodservice_Items_Master_ID)
				AND (First_Contract_Products.Product_Type_ID = 1 OR Second_Contract_Products.Product_Type_ID = 1)
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
			AND
			(
				(Second_Program_Fixed_Component.Program_Fixed_Component_Id = Second_Fixed.Program_Fixed_Component_Id)
				OR
				(Second_Program_Fixed_Component.Program_Fixed_Component_Id IS NULL AND Second_Fixed.Program_Fixed_Component_Id IS NULL)
			)
		</cfquery>

		<cfif arguments.UseTableResults eq 0>
			<cfreturn qgetFixedProductsRatesUOMChanged />
		<cfelse>
		<!--- -The query does not need to return records. The records are already loaded in the temp table "##TMP_FixedProductsRatesUOMChanged" --->
		<cfquery NAME="qgetFixedProductsRatesUOMChangedFromTable" datasource="#application.datasource#">
			SELECT top 0 *
			FROM ##TMP_FixedProductsRatesUOMChanged
		</cfquery>'

			<cfreturn qgetFixedProductsRatesUOMChangedFromTable>
		</cfif>
	</cffunction>

	<cffunction name="getRebateProductsRatesUOMChanged" output="false" returntype="query">
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<cfargument name="showOnlyChange" required="true">
		<cfargument name="UseTableResults" required="false" default="0">

		<cfif arguments.UseTableResults eq 1>
			<cfquery name="qDelRebateProductsRatesTbl" datasource="#application.datasource#">
				if object_id('tempdb..##TMP_RebateProductsRatesUOMChanged') is not null
				drop table ##TMP_RebateProductsRatesUOMChanged
			</cfquery>
		</cfif>

		<cfquery name="qgetRebateProductsRatesUOMChanged" datasource="#application.datasource#">
			SELECT	DISTINCT
			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
			First_Rebate.Program_Rebates_Product_Data_ID First_Rebate_ID,
			Second_Rebate.Program_Rebates_Product_Data_ID Second_Rebate_ID,
			First_Contract_Products.BSA_Foodservice_Items_Master_ID First_ID,
			Second_Contract_Products.BSA_Foodservice_Items_Master_ID Second_ID,
			First_Rebate_Component.rate First_Price,
			Second_Rebate_Component.rate Second_Price,
			First_Rebate_Component.Unit_Of_Measure_ID First_UOM,
			Second_Rebate_Component.Unit_Of_Measure_ID Second_UOM,
			First_Program_Rebates_Component.Program_Rebates_Component_Name_Id First_Program_Rebates_Component_Name_Id,
			Second_Program_Rebates_Component.Program_Rebates_Component_Name_Id Second_Program_Rebates_Component_Name_Id,
			CASE
			WHEN First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL
			AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL
			AND (First_Program_Rebates_Component.Program_Rebates_Component_Name_Id = Second_Program_Rebates_Component.Program_Rebates_Component_Name_Id) AND (
			cast(First_Rebate_Component.rate as float) <> cast(Second_Rebate_Component.rate as float)
			) THEN
				1
			ELSE
				0
			END As Rate_Change,
			CASE WHEN
			First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL
			AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL
			AND (First_Program_Rebates_Component.Program_Rebates_Component_Name_Id = Second_Program_Rebates_Component.Program_Rebates_Component_Name_Id) AND (
			First_Rebate_Component.Unit_Of_Measure_ID <> Second_Rebate_Component.Unit_Of_Measure_ID
				) THEN
				1
			ELSE
				0
			END As Uom_Change
			<!--- D34880: Max Rate Easy Button and Short Cut Routing--->
			,
							CAST(First_Rebate_Component.rate as float) as  Rate1,
					                  CASE
					                        WHEN First_Rebate_Component.Unit_Of_Measure_ID = Second_Rebate_Component.Unit_Of_Measure_ID THEN <!--- Both are same --->
					                              CAST(Second_Rebate_Component.rate as float)
					                        WHEN First_Rebate_Component.Unit_Of_Measure_ID = 1 AND Second_Rebate_Component.Unit_Of_Measure_ID = 2 THEN <!--- Both are different, convert second from lb to cs --->
					                              CAST(Second_Rebate_Component.rate as float) * CAST(BSA_Foodservice_Items_Master.Net_Weight as float)
					                        WHEN First_Rebate_Component.Unit_Of_Measure_ID = 2 AND Second_Rebate_Component.Unit_Of_Measure_ID = 1 THEN <!--- Both are different, convert second from cs to lb --->
					                              CAST(Second_Rebate_Component.rate as float) / CAST(BSA_Foodservice_Items_Master.Net_Weight as float)
					                        ELSE <!--- Both are different, cannot convert --->
					                              CAST(-1 as float)   <!--- D36386 --->
                  		END as Rate2
                  		,First_Contract_Products.IS_group
		<!--- D34880: Max Rate Easy Button and Short Cut Routing--->
				<cfif arguments.UseTableResults eq 1>
				INTO ##TMP_RebateProductsRatesUOMChanged
				</cfif>
				FROM	Contract_Main

						INNER JOIN Contract_Products First_Contract_Products
						ON	First_Contract_Products.Deleted = 0
						AND	First_Contract_Products.Product_Type_ID = 2
						AND	First_Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
						AND
						(
							(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
							OR
							(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
						)
						LEFT JOIN Contract_Products Second_Contract_Products
						ON	Second_Contract_Products.Deleted = 0
						AND	Second_Contract_Products.Product_Type_ID = 2
						AND	Second_Contract_Products.Contract_Main_ID = #arguments.ProgramId2#
						AND	First_Contract_Products.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
						AND
						(
							(Second_Contract_Products.Product_Group_ID = CAST(Second_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Second_Contract_Products.Is_Group = 1)
							OR
							(ISNULL(Second_Contract_Products.Product_Group_ID, '') = '' AND Second_Contract_Products.Is_Group = 0)
						)
						INNER JOIN Program_Rebates_Product_Data First_Rebate
						ON	First_Rebate.Deleted = 0
						AND	First_Rebate.Contract_Products_ID = First_Contract_Products.Contract_Products_ID
						INNER JOIN Program_Rebates_Component_Data First_Rebate_Component
						ON First_Rebate_Component.deleted = 0
						AND First_Rebate_Component.Program_Rebates_Product_Data_Id =
						First_Rebate.Program_Rebates_Product_Data_Id
						INNER JOIN Program_Rebates_Component as
						First_Program_Rebates_Component on First_Program_Rebates_Component.deleted = 0
						AND First_Program_Rebates_Component.Program_Rebates_Component_ID =
						First_Rebate_Component.Program_Rebates_Component_ID
						LEFT JOIN Program_Rebates_Product_Data Second_Rebate
						ON	Second_Rebate.Deleted = 0
						AND	Second_Rebate.Contract_Products_ID = Second_Contract_Products.Contract_Products_ID
						LEFT JOIN Program_Rebates_Component_Data Second_Rebate_Component
						ON Second_Rebate_Component.deleted = 0
						AND Second_Rebate_Component.Program_Rebates_Product_Data_Id =
						Second_Rebate.Program_Rebates_Product_Data_Id
						LEFT JOIN Program_Rebates_Component as
						Second_Program_Rebates_Component on Second_Program_Rebates_Component.deleted = 0
						AND Second_Program_Rebates_Component.Program_Rebates_Component_ID =
						Second_Rebate_Component.Program_Rebates_Component_ID
						AND Second_Program_Rebates_Component.Program_Rebates_Component_Name_Id = First_Program_Rebates_Component.Program_Rebates_Component_Name_Id
						AND Second_Program_Rebates_Component.Component_Paid_To = First_Program_Rebates_Component.Component_Paid_To
						INNER JOIN BSA_Foodservice_Items_Master
						ON	BSA_Foodservice_Items_Master.Deleted = 0
						AND	(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = First_Contract_Products.BSA_Foodservice_Items_Master_ID
							OR
							BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
							)
			<cfif arguments.showOnlyChange>
			AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL
			</cfif>
						AND ISNULL(First_Contract_Products.BSA_Foodservice_Items_Master_ID, Second_Contract_Products.BSA_Foodservice_Items_Master_ID) = ISNULL(Second_Contract_Products.BSA_Foodservice_Items_Master_ID, First_Contract_Products.BSA_Foodservice_Items_Master_ID)
						AND (First_Contract_Products.Product_Type_ID = 2 OR Second_Contract_Products.Product_Type_ID = 2)
				WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
				AND (	(Second_Program_Rebates_Component.Program_Rebates_Component_ID = Second_Rebate_Component.Program_Rebates_Component_ID)
				OR (Second_Program_Rebates_Component.Program_Rebates_Component_ID IS NULL AND Second_Rebate_Component.Program_Rebates_Component_ID IS NULL)
				)
		</cfquery>

			<cfif arguments.UseTableResults eq 0>
				<cfreturn qgetRebateProductsRatesUOMChanged />
			<cfelse>
			<!--- -The query does not need to return records. The records are already loaded in the temp table "##TMP_FixedProductsRatesUOMChanged" --->
			<cfquery NAME="qgetRebateProductsRatesUOMChangedFromTable" datasource="#application.datasource#">
				SELECT top 0 *
				FROM ##TMP_RebateProductsRatesUOMChanged
			</cfquery>'

				<cfreturn qgetRebateProductsRatesUOMChangedFromTable>
			</cfif>
	</cffunction>

	<cffunction name="getBidRequestProductsRatesUOMChanged" output="false" returntype="query">
	<cfargument name="ProgramId1" type="numeric" required="true">
	<cfargument name="ProgramId2" type="numeric" required="true">
	<cfargument name="showOnlyChange" required="true">
	<cfquery name="qgetBidRequestProductsRatesUOMChanged" datasource="#application.datasource#">
		SELECT	DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
		First_Contract_Products.BSA_Foodservice_Items_Master_ID First_ID,
		Second_Contract_Products.BSA_Foodservice_Items_Master_ID Second_ID,
		First_BidRequest.Price First_Price,
		Second_BidRequest.Price Second_Price,
		First_Units_Of_Measure.Abbreviation First_UOM,
		Second_Units_Of_Measure.Abbreviation Second_UOM,
		First_Program_Bidrequest_Component.Program_Bidrequest_Component_Name_Id,
		Second_Program_Bidrequest_Component.Program_Bidrequest_Component_Name_Id,
		CASE
		WHEN 	First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL
				AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL
				AND (First_Program_Bidrequest_Component.Program_Bidrequest_Component_Name_Id = Second_Program_Bidrequest_Component.Program_Bidrequest_Component_Name_Id) AND (
					First_BidRequest.Price <> Second_BidRequest.Price
					) THEN
			1
		ELSE
			0
		END As Rate_Change,
		CASE
		WHEN 	First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL
				AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL
				AND (First_Program_Bidrequest_Component.Program_Bidrequest_Component_Name_Id = Second_Program_Bidrequest_Component.Program_Bidrequest_Component_Name_Id) AND  (
					First_Units_Of_Measure.Abbreviation <> Second_Units_Of_Measure.Abbreviation
					) THEN
			1
		ELSE
			0
		END As UOM_Change
			FROM	Contract_Main
					INNER JOIN Contract_Products First_Contract_Products
					ON	First_Contract_Products.Deleted = 0
					AND	First_Contract_Products.Product_Type_ID = 10
					AND	First_Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND
					(
						(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
						OR
						(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
					)
					LEFT JOIN Contract_Products Second_Contract_Products
					ON	Second_Contract_Products.Deleted = 0
					AND	Second_Contract_Products.Product_Type_ID = 10
					AND	Second_Contract_Products.Contract_Main_ID = #arguments.ProgramId2#
					AND	First_Contract_Products.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
					AND
					(
						(Second_Contract_Products.Product_Group_ID = CAST(Second_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Second_Contract_Products.Is_Group = 1)
						OR
						(ISNULL(Second_Contract_Products.Product_Group_ID, '') = '' AND Second_Contract_Products.Is_Group = 0)
					)
					INNER JOIN Program_Bid_Request_Product First_BidRequest
					ON	First_BidRequest.Deleted = 0
					AND	First_BidRequest.Contract_Products_ID = First_Contract_Products.Contract_Products_ID
					INNER JOIN Program_Bidrequest_Component as First_Program_Bidrequest_Component ON
					First_Program_Bidrequest_Component.deleted = 0
					AND First_Program_Bidrequest_Component.Program_Bidrequest_Component_Id =
					First_BidRequest.Program_Bidrequest_Component_Id
					LEFT JOIN Program_Bid_Request_Product Second_BidRequest
					ON	Second_BidRequest.Deleted = 0
					AND	Second_BidRequest.Contract_Products_ID = Second_Contract_Products.Contract_Products_ID
					LEFT JOIN Program_Bidrequest_Component as Second_Program_Bidrequest_Component ON
					Second_Program_Bidrequest_Component.deleted = 0
					AND Second_Program_Bidrequest_Component.Program_Bidrequest_Component_Id =
					First_BidRequest.Program_Bidrequest_Component_Id
					INNER JOIN Units_Of_Measure First_Units_Of_Measure
					ON
					First_Units_Of_Measure.Unit_Of_Measure_ID = First_BidRequest.UOM
					LEFT JOIN Units_Of_Measure Second_Units_Of_Measure
					ON
					Second_Units_Of_Measure.Unit_Of_Measure_ID = Second_BidRequest.UOM
					INNER JOIN BSA_Foodservice_Items_Master
					ON	BSA_Foodservice_Items_Master.Deleted = 0
					AND	(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = First_Contract_Products.BSA_Foodservice_Items_Master_ID
						OR
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
						)
		<cfif arguments.showOnlyChange>
		AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL
		</cfif>
					AND ISNULL(First_Contract_Products.BSA_Foodservice_Items_Master_ID, Second_Contract_Products.BSA_Foodservice_Items_Master_ID) = ISNULL(Second_Contract_Products.BSA_Foodservice_Items_Master_ID, First_Contract_Products.BSA_Foodservice_Items_Master_ID)
					AND (First_Contract_Products.Product_Type_ID = 10 OR Second_Contract_Products.Product_Type_ID = 10)
			WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
	</cfquery>
	<cfreturn qgetBidRequestProductsRatesUOMChanged />
	</cffunction>

	<cffunction name="getGrowthProductsRatesUOMChanged" output="false" returntype="query">
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<cfargument name="showOnlyChange" required="true">

		<cfquery name="qgetGrowthProductsRatesUOMChanged" datasource="#application.datasource#">
			SELECT
						First_Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID First_ID,
						First_Contract_Products.Contract_Main_ID First_Program_ID, Second_Contract_Products.Contract_Main_ID Second_Program_ID,
						Second_Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID Second_ID,
						First_Program_Growth_Components.Component_Name,
						Second_Program_Growth_Components.Component_Name,
						CASE
						WHEN BSA_Foodservice_Items_Master.BSA_Product_Group_ID IS NULL THEN
						'Groups'
						ELSE
						'Items'
						END As Is_Group,
						First_Program_Growth_Component_Tiers.Tier_Number as First_Tier_Number,
						Second_Program_Growth_Component_Tiers.Tier_Number as Second_Tier_Number,
						First_Program_Growth_Component_Product_Tier_Data.Rate as First_Rate,
						Second_Program_Growth_Component_Product_Tier_Data.Rate as Second_Rate,
						First_Program_Growth_Component_Product_Tier_Data.Unit_Of_measure_ID as First_UOM,
						Second_Program_Growth_Component_Product_Tier_Data.Unit_Of_measure_ID as Second_UOM,
						CASE
						WHEN 	First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL
								AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL
								AND First_Program_Growth_Component_Tiers.Tier_Number =
								Second_Program_Growth_Component_Tiers.Tier_Number
								AND (
									First_Program_Growth_Component_Product_Tier_Data.Rate <> Second_Program_Growth_Component_Product_Tier_Data.Rate
									) THEN
							1
						ELSE
							0
						END As Rate_Change,
								CASE
						WHEN 	First_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL
								AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NOT NULL
								AND First_Program_Growth_Component_Tiers.Tier_Number =
								Second_Program_Growth_Component_Tiers.Tier_Number
								AND (
									First_Program_Growth_Component_Product_Tier_Data.Unit_Of_measure_ID <> Second_Program_Growth_Component_Product_Tier_Data.Unit_Of_measure_ID
									) THEN
							1
						ELSE
							0
						END As UOM_Change
				FROM	Contract_Main
						INNER JOIN Contract_Products First_Contract_Products
						ON	First_Contract_Products.Deleted = 0
						AND	First_Contract_Products.Product_Type_ID = 4
						AND First_Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
						AND
						(

							(First_Contract_Products.Product_Group_ID = CAST(First_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND First_Contract_Products.Is_Group = 1)
							OR

							(ISNULL(First_Contract_Products.Product_Group_ID, '') = '' AND First_Contract_Products.Is_Group = 0)
						)

						INNER JOIN 	Program_Growth_Component_Product_Data First_Program_Growth_Component_Product_Data
						ON	First_Program_Growth_Component_Product_Data.Deleted = 0
						AND	First_Program_Growth_Component_Product_Data.Contract_Products_ID = First_Contract_Products.Contract_Products_ID

						LEFT JOIN Contract_Products Second_Contract_Products
						ON	Second_Contract_Products.Deleted = 0
						AND	Second_Contract_Products.Product_Type_ID = 4
						AND	Second_Contract_Products.Contract_Main_ID = #arguments.ProgramId2#
						AND	First_Contract_Products.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
						AND
						(

							(Second_Contract_Products.Product_Group_ID = CAST(Second_Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Second_Contract_Products.Is_Group = 1)
							OR

							(ISNULL(Second_Contract_Products.Product_Group_ID, '') = '' AND Second_Contract_Products.Is_Group = 0)
						)
						LEFT JOIN 	Program_Growth_Component_Product_Data Second_Program_Growth_Component_Product_Data
						ON	Second_Program_Growth_Component_Product_Data.Deleted = 0
						AND	Second_Program_Growth_Component_Product_Data.Contract_Products_ID = Second_Contract_Products.Contract_Products_ID

						INNER JOIN 	BSA_Foodservice_Items_Master
						ON	BSA_Foodservice_Items_Master.Deleted = 0
						AND	(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = First_Contract_Products.BSA_Foodservice_Items_Master_ID
							OR
							BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Second_Contract_Products.BSA_Foodservice_Items_Master_ID
							)
						AND ISNULL(First_Contract_Products.BSA_Foodservice_Items_Master_ID, Second_Contract_Products.BSA_Foodservice_Items_Master_ID) = ISNULL(Second_Contract_Products.BSA_Foodservice_Items_Master_ID, First_Contract_Products.BSA_Foodservice_Items_Master_ID)
							INNER JOIN Program_Growth_Components First_Program_Growth_Components
							ON First_Program_Growth_Components.deleted = 0
							AND First_Program_Growth_Component_Product_Data.Program_Growth_Component_ID
							= First_Program_Growth_Components.Program_Growth_Component_ID
							INNER JOIN Program_Growth_Component_Tiers First_Program_Growth_Component_Tiers
							ON	First_Program_Growth_Component_Tiers.Deleted = 0
							AND	First_Program_Growth_Components.Program_Growth_Component_ID = First_Program_Growth_Component_Tiers.Program_Growth_Component_ID
							INNER JOIN Program_Growth_Component_Product_Tier_Data First_Program_Growth_Component_Product_Tier_Data
							ON	First_Program_Growth_Component_Product_Tier_Data.Deleted = 0
							AND	First_Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID = First_Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID
							AND	First_Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_ID = First_Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID
							LEFT JOIN Program_Growth_Components Second_Program_Growth_Components
							ON Second_Program_Growth_Components.deleted = 0
							AND Second_Program_Growth_Component_Product_Data.Program_Growth_Component_ID
							= Second_Program_Growth_Components.Program_Growth_Component_ID
							LEFT JOIN Program_Growth_Component_Tiers Second_Program_Growth_Component_Tiers
							ON	Second_Program_Growth_Component_Tiers.Deleted = 0
							AND	Second_Program_Growth_Components.Program_Growth_Component_ID = Second_Program_Growth_Component_Tiers.Program_Growth_Component_ID
							LEFT JOIN Program_Growth_Component_Product_Tier_Data Second_Program_Growth_Component_Product_Tier_Data
							ON	Second_Program_Growth_Component_Product_Tier_Data.Deleted = 0
							AND	Second_Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID = Second_Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID
							AND	Second_Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_ID = Second_Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID
			<cfif arguments.showOnlyChange>
			AND Second_Contract_Products.BSA_Foodservice_Items_Master_ID IS NULL
			</cfif>

				WHERE	Contract_Main.Contract_Main_ID = #arguments.ProgramId1#
				order by First_Program_Growth_Component_Tiers.Tier_Number ,Second_Program_Growth_Component_Tiers.Tier_Number
		</cfquery>
		<cfreturn qgetGrowthProductsRatesUOMChanged />
	</cffunction>

	<cffunction name="getLumpChanged" output="false" returntype="query">
		<cfargument name="ProgramId1" type="numeric" required="true">
		<cfargument name="ProgramId2" type="numeric" required="true">
		<!--- D34880: Max Rate Easy Button and Short Cut Routing--->
		<cfquery name="qgetLumpChanged" datasource="#application.datasource#">
		           declare @ProgramId1_LS decimal(20, 2), @ProgramId2_LS decimal(20, 2)

                  select @ProgramId1_LS = sum(cast(program_lump_sums.lump_sum_amount as decimal(20,4)))
                  from program_lump_sums
                  where deleted =0
                  and program_id =  #arguments.ProgramId1#

                  select @ProgramId2_LS = sum(cast(program_lump_sums.lump_sum_amount as decimal(20,4)))
                  from program_lump_sums
                  where deleted =0
                  and program_id =  #arguments.ProgramId2#

                  select CAST(@ProgramId1_LS as float) as Rate1, CAST(@ProgramId2_LS as float) as Rate2                <!--- D36386 --->
		</cfquery>
		<cfreturn qgetLumpChanged />
	</cffunction>

	<cffunction name="getcomponentchangedflag" output="false" returntype="query">
		<cfargument name="ProgramId1" 		type="numeric" required="true">
		<cfargument name="ProgramId2" 		type="numeric" required="true">
		<cfargument name="bJustAddedComps"	type="boolean" default="0">

		<!---TSF - Label 14073: Added bJustAddedComps argument to just check for components that have been added--->
		<cfset var bCheckJustAddedComps		= 0 />

		<cfset bCheckJustAddedComps 		= arguments.bJustAddedComps />

		<cfquery name="qgetcomponentchangedflag" datasource="#application.datasource#">
			declare @rebatetempparent int,
			@rebatetemprevision int,
			@fixedtempparent int,
			@fixedtemprevision int,
			@growthtempparent int,
			@growthtemprevision int,
			@lumptempparent int,
			@lumptemprevision int,
			@bidtempparent int,
			@bidtemprevision int,
			@rebatecompchanged int,
			@fixedcompchanged int,
			@growthcompchanged int,
			@bidcompchanged int,
			@ProgramId2 int,
			@ProgramId1 int

			set @ProgramId2 = #arguments.ProgramId2#
			set @ProgramId1 = #arguments.ProgramId1#

			select @rebatetempparent = count(*)
			from
			program_rebates_component
			where program_id = @ProgramId2
			and deleted = 0

			select @rebatetemprevision = count(*)
			from
			program_rebates_component
			where program_id = @ProgramId1
			and deleted = 0

			SELECT @rebatecompchanged = COUNT(*) FROM program_rebates_component
			WHERE program_id = @ProgramId1
			and deleted = 0
			AND program_rebates_component_NAME_ID NOT IN
			(SELECT program_rebates_component_NAME_ID FROM
			program_rebates_component
			WHERE program_id = @ProgramId2
			and deleted = 0)

			select @fixedtempparent = count(*)
			from program_fixed_component
			where program_id =  @ProgramId2
			and deleted = 0

			select @fixedtemprevision = count(*)
			from program_fixed_component
			where program_id =  @ProgramId1
			and deleted = 0

			SELECT @fixedcompchanged = COUNT(*)
			FROM program_fixed_component
			WHERE program_id = @ProgramId1
			and deleted = 0
			AND program_fixed_component_name_id NOT IN
			(SELECT program_fixed_component_name_id FROM
			program_fixed_component
			WHERE program_id = @ProgramId2
			and deleted = 0)

			select @growthtempparent = count(*) from
			Program_Growth_Components
			where program_id =  @ProgramId2
			and deleted = 0

			select @growthtemprevision = count(*) from
			Program_Growth_Components
			where program_id =  @ProgramId1
			and deleted = 0

			SELECT @growthcompchanged = COUNT(*)
			FROM Program_Growth_Components
			WHERE program_id = @ProgramId1
			and deleted = 0
			AND Program_Growth_Components_Name_Id NOT IN
			(SELECT Program_Growth_Components_Name_Id FROM
			Program_Growth_Components
			WHERE program_id = @ProgramId2
			and deleted = 0)

			select @lumptempparent = count(*) from
			Program_lump_sums
			where program_id =  @ProgramId2
			and deleted = 0

			select @lumptemprevision = count(*) from
			Program_lump_sums
			where program_id =  @ProgramId1
			and deleted = 0

			select @bidtempparent = count(*)
			from program_bidrequest_component
			where program_id =  @ProgramId2
			and deleted = 0

			select @bidtemprevision = count(*)
			from program_bidrequest_component
			where program_id =  @ProgramId1
			and deleted = 0

			SELECT @bidcompchanged = COUNT(*)
			FROM program_bidrequest_component
			WHERE program_id = @ProgramId1
			and deleted = 0
			AND program_bidrequest_component_Name_Id NOT IN
			(SELECT program_bidrequest_component_Name_Id FROM
			program_bidrequest_component
			WHERE program_id = @ProgramId2
			and deleted = 0)

			<!---If bCheckJustAddedComps is on then set all the component counts to 0 so the query will be just checking changed components--->
			<cfif bCheckJustAddedComps>
			SET	@rebatetempparent 	= 0
			SET	@rebatetemprevision = 0
			SET	@fixedtempparent 	= 0
			SET	@fixedtemprevision 	= 0
			SET	@growthtempparent 	= 0
			SET	@growthtemprevision = 0
			SET	@bidtempparent 		= 0
			SET	@bidtemprevision 	= 0
			</cfif>

			select
			case when (@rebatetempparent != @rebatetemprevision OR @rebatecompchanged > 0)
			then 1
			else 0
			end as rebatecompchanged,
			case when (@fixedtempparent != @fixedtemprevision OR @fixedcompchanged > 0)
			then 1
			else 0
			end as fixedcompchanged,
			case when (@growthtempparent != @growthtemprevision OR @growthcompchanged > 0)
			then 1
			else 0
			end as growthcompchanged,
			case when @lumptempparent != @lumptemprevision
			then 1
			else 0
			end as lumpcompchanged,
			case when (@bidtempparent != @bidtemprevision OR @bidcompchanged > 0)
			then 1
			else 0
			end as bidcompchanged
		</cfquery>
			<cfreturn qgetcomponentchangedflag />
	</cffunction>

	<cffunction name="getVolumeOverrideChanges" output="false" returntype="query" hint="Returns components that are not included in the 2nd contract">
		<cfargument name="contract_main_id_1" type="numeric" required="true">
		<cfargument name="contract_main_id_2" type="numeric" required="true">

		<!---  locate rebate/fixed components that are in contract_main_id_1 but not in contract_main_id_2  --->
		<cfquery name="local.getVolumeOverrideChanges" datasource="#application.datasource#">
			SELECT  (
			          SELECT    Discount_Type.Discount_Type_Desc
			          FROM      Discount_Type
			          WHERE     Discount_Type.Discount_Type_ID = 2
			        ) AS Discount_Type
			       ,prcn.Program_Rebates_Component_Name AS Comp_Name
			       ,CASE WHEN prc.Component_Paid_To = 1 THEN 'Distributor'
			             ELSE 'Operator'
			        END AS Pays_To
			       ,prc.Program_Rebates_Component_ID AS component_id
			       ,prc.Dont_Count_Volume
			FROM    Program_Rebates_Component prc
			        INNER JOIN Program_Rebates_Component_Name prcn
			            ON prcn.Program_Rebates_Component_Name_ID = prc.Program_Rebates_Component_Name_ID
			        LEFT JOIN Program_Rebates_Component prc2
			            ON prc2.Program_ID = <cfqueryparam value="#arguments.contract_main_id_2#">
			               AND prc2.Deleted = 0
			               AND prc2.Program_Rebates_Component_Name_ID = prc.Program_Rebates_Component_Name_ID
			WHERE   prc.Program_ID = <cfqueryparam value="#arguments.contract_main_id_1#">
			        AND prc.Deleted = 0
			        AND prc2.Program_ID IS NULL

			UNION

			SELECT  (
			          SELECT    Discount_Type.Discount_Type_Desc
			          FROM      Discount_Type
			          WHERE     Discount_Type.Discount_Type_ID = 1
			        ) AS Discount_Type
			       ,pfcn.Program_Fixed_Component_Name AS Comp_Name
			       ,CASE WHEN pfc.Fixed_Component_Paid_to = 1 THEN 'Distributor'
			             ELSE 'Operator'
			        END AS Pays_To
			       ,pfc.Program_Fixed_Component_ID AS component_id
			       ,pfc.Dont_Count_Volume
			FROM    Program_Fixed_Component pfc
			        INNER JOIN Program_Fixed_Component_Name pfcn
			            ON pfcn.Program_Fixed_Component_Name_ID = pfc.Program_Fixed_Component_Name_ID
			        LEFT JOIN Program_Fixed_Component pfc2
			            ON pfc2.Program_ID = <cfqueryparam value="#arguments.contract_main_id_2#">
			               AND pfc2.Deleted = 0
			               AND pfc2.Program_Fixed_Component_Name_ID = pfc.Program_Fixed_Component_Name_ID
			WHERE   pfc.Program_ID = <cfqueryparam value="#arguments.contract_main_id_1#">
			        AND pfc.Deleted = 0
			        AND pfc2.Program_ID IS NULL
		</cfquery>

		<cfreturn local.getVolumeOverrideChanges>
	</cffunction>

	<cffunction name="getVolumeOverrideIgnore" output="false" returntype="query" hint="Returns components that are included in both contracts and their ignore volume are different">
		<cfargument name="contract_main_id_1" type="numeric" required="true">
		<cfargument name="contract_main_id_2" type="numeric" required="true">

		<!---  locate rebate/fixed components that are in contract_main_id_1 but not in contract_main_id_2  --->
		<cfquery name="local.getVolumeOverrideChanges" datasource="#application.datasource#">
			SELECT  (
			          SELECT    Discount_Type.Discount_Type_Desc
			          FROM      Discount_Type
			          WHERE     Discount_Type.Discount_Type_ID = 2
			        ) AS Discount_Type
			       ,prcn.Program_Rebates_Component_Name AS Comp_Name
			       ,CASE WHEN prc.Component_Paid_To = 1 THEN 'Distributor'
			             ELSE 'Operator'
			        END AS Pays_To
			       ,prc.Program_Rebates_Component_ID AS component_id
			       ,prc.Dont_Count_Volume  AS Dont_Count_Volume_1
			       ,prc2.Dont_Count_Volume AS Dont_Count_Volume_2
			FROM    Program_Rebates_Component prc
			        INNER JOIN Program_Rebates_Component_Name prcn
			            ON prcn.Program_Rebates_Component_Name_ID = prc.Program_Rebates_Component_Name_ID
			        INNER JOIN Program_Rebates_Component prc2
			            ON prc2.Program_ID = <cfqueryparam value="#arguments.contract_main_id_2#">
			               AND prc2.Deleted = 0
			               AND prc2.Program_Rebates_Component_Name_ID = prc.Program_Rebates_Component_Name_ID
			WHERE   prc.Program_ID = <cfqueryparam value="#arguments.contract_main_id_1#">
			        AND prc.Deleted = 0
			        AND prc.Dont_Count_Volume <> prc2.Dont_Count_Volume

			UNION

			SELECT  (
			          SELECT    Discount_Type.Discount_Type_Desc
			          FROM      Discount_Type
			          WHERE     Discount_Type.Discount_Type_ID = 1
			        ) AS Discount_Type
			       ,pfcn.Program_Fixed_Component_Name AS Comp_Name
			       ,CASE WHEN pfc.Fixed_Component_Paid_to = 1 THEN 'Distributor'
			             ELSE 'Operator'
			        END AS Pays_To
			       ,pfc.Program_Fixed_Component_ID AS component_id
			       ,pfc.Dont_Count_Volume  AS Dont_Count_Volume_1
			       ,pfc2.Dont_Count_Volume AS Dont_Count_Volume_2
			FROM    Program_Fixed_Component pfc
			        INNER JOIN Program_Fixed_Component_Name pfcn
			            ON pfcn.Program_Fixed_Component_Name_ID = pfc.Program_Fixed_Component_Name_ID
			        INNER JOIN Program_Fixed_Component pfc2
			            ON pfc2.Program_ID = <cfqueryparam value="#arguments.contract_main_id_2#">
			               AND pfc2.Deleted = 0
			               AND pfc2.Program_Fixed_Component_Name_ID = pfc.Program_Fixed_Component_Name_ID
			WHERE   pfc.Program_ID = <cfqueryparam value="#arguments.contract_main_id_1#">
			        AND pfc.Deleted = 0
			        AND pfc.Dont_Count_Volume <> pfc2.Dont_Count_Volume
		</cfquery>

		<cfreturn local.getVolumeOverrideChanges>
	</cffunction>
</cfcomponent>
