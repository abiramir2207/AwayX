<cfcomponent hint="Clause Category Manager" extends="components.Base">
	<!---
	The app setting (simple clauses) is ON for clients using our new clauses functionality. The clients use different functions based on app setting.
	The code for app setting (simple clauses) ON and OFF is very different. On any environment,we cannot turn ON or OFF this switch. If is not possible for
	any client to move from simple (simple clauses app setting ON) to non-simple(simple clauses app setting OFF).
	To move from non-simple to simple clauses, please refer to label 25647 first.

	For any change to this file, first check whether the client requesting the modification has the "simple clauses" app switch ON or OFF. The clients with this
	app setting OFF use files with the "original" prefix for some of the clause library files and so a change in one file with or without the "original" prefix
	might require a corresponding change in the other file, if the functionality affected is the same for both. Please refer to label 25647.
	--->
	<cffunction name="init" output="false">

		<cfreturn this />

	</cffunction>

	<cffunction name="get" output="false">

		<cfargument name="id" required="false" default=0 type="numeric" />

		<cfset this.clauseCategory = CreateObject("component","components.clause_library.ClauseCategory").init() />

		<cfif arguments.id>

			<cfquery name="qGetClauseCategory" datasource="#application.datasource#">
				SELECT 	Clause_Category_ID,
						Clause_Category_Name,
						Require_Approval,
						Required_For_All,
						Default_Clause_Library_ID,
						Created_By,
						Updated_By,
						Updated_Date
				FROM	Clause_Category
				WHERE 	Deleted = 0
				AND		Clause_Category_ID = <cfqueryPARAM value = "#arguments.id#" CFSQLType = "CF_SQL_INTEGER">
			</cfquery>

			<cfloop query="qGetClauseCategory">

				<cfset this.clauseCategory.setId(Clause_Category_ID) />
				<cfset this.clauseCategory.setTitle(Clause_Category_Name) />
				<cfset this.clauseCategory.setRequireApproval(Require_Approval) />
				<cfset this.clauseCategory.setRequireAll(Required_For_All) />
				<cfset this.clauseCategory.setDefaultClauseId(Default_Clause_Library_ID) />
				<cfset this.clauseCategory.setCreatedBy(Created_By) />
				<cfset this.clauseCategory.setUpdatedBy(Updated_By) />
				<cfset this.clauseCategory.setUpdatedDate(Updated_Date) />

			</cfloop>

		</cfif>

		<cfreturn this.clauseCategory />

	</cffunction>

	<cffunction name="getAll" output="false" returntype="query">

		<cfset useLakebaseForqGetAll = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("clause_category")>
<cfif useLakebaseForqGetAll>
	<cftry>
		<cfset qGetAll = application.oLakebase.toQuery(
			application.oLakebase.selectRows("clause_category", {
				"deleted" = "eq.0",
				"order" = "clause_category_id.asc",
				"select" = "clause_category_id,clause_category_name,require_approval,default_clause_library_id"
			}), "clause_category_id,clause_category_name,require_approval,default_clause_library_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetAll = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetAll>
<cfquery name="qGetAll" datasource="#application.datasource#">
			SELECT 	Clause_Category_ID,
					Clause_Category_Name,
					Require_Approval,
					Default_Clause_Library_ID
			FROM	Clause_Category
			WHERE 	Deleted = 0
			ORDER BY Clause_Category_ID
		</cfquery>
</cfif>

		<cfreturn qGetAll />

	</cffunction>

	<!---
	Milan;19623/25647. The app setting (simple clauses) is ON for clients using our new clauses functionality. The clients with this app
	setting OFF use "save_ComplexClauses" function instead of this function. The code for app setting (simple clauses) ON and OFF is very different.
	On any environment,we cannot turn ON or OFF this switch. If is not possible for any client to move from simple (simple clauses app setting ON)
	to non-simple(simple clauses app setting OFF). To move from non-simple to simple clauses, please refer to label 25647 first.
	--->
	<cffunction name="save" output="false" returntype="numeric">

		<cftransaction action="begin">

			<cftry>

				<cfif this.clauseCategory.getId()>

					<!---///////////////////////////////////////////////////////////////////////////////////////////////////////--->
					<!---////////////////////////////////////////// UPDATE /////////////////////////////////////////////////////--->
					<!---///////////////////////////////////////////////////////////////////////////////////////////////////////--->

					<cfquery name="qUpdateClauseCategory" datasource="#application.datasource#">
						SET NOCOUNT ON

						UPDATE	Clause_Category
						SET		Clause_Category_Name	= <cfqueryPARAM value="#this.clauseCategory.getTitle()#" CFSQLType="CF_SQL_VARCHAR">,
								Required_For_All		= 0,
								Require_Approval		= 0
						WHERE
								Clause_Category_ID = <cfqueryPARAM value="#this.clauseCategory.getId()#" CFSQLType="CF_SQL_INTEGER">

					</cfquery>

				<cfelse>

					<!---///////////////////////////////////////////////////////////////////////////////////////////////////////--->
					<!---////////////////////////////////////////// INSERT /////////////////////////////////////////////////////--->
					<!---///////////////////////////////////////////////////////////////////////////////////////////////////////--->
					<cfquery name="qInsertClauseCategory" datasource="#application.datasource#">
					SET NOCOUNT ON

						INSERT INTO Clause_Category(Clause_Category_Name, Required_For_All, Require_Approval, Created_By)
						VALUES (
								<cfqueryPARAM value="#this.clauseCategory.getTitle()#" CFSQLType="CF_SQL_VARCHAR">,
								0,
								0,
								<cfqueryPARAM value="#this.clauseCategory.getCreatedBy()#" CFSQLType="CF_SQL_VARCHAR">
								)

					SELECT Clause_Category_ID = @@IDENTITY
					SET NOCOUNT OFF
					</cfquery>

				</cfif>
				<cfif this.clauseCategory.getId() eq 0>
					<cfreturn qInsertClauseCategory.Clause_Category_ID>
				<cfelse>
					<cfreturn 0>
				</cfif>

				<cftransaction action="COMMIT" />

				<cfcatch>

					<cftransaction action="ROLLBACK" />
					<cfrethrow />

				</cfcatch>

			</cftry>

		</cftransaction>

	</cffunction>

	<!---
	Milan;19623/25647. The app setting (simple clauses) is ON for clients using our new clauses functionality. The clients with this app
	setting OFF use this function instead of "save" function. The code for app setting (simple clauses) ON and OFF is very different.
	On any environment,we cannot turn ON or OFF this switch. If is not possible for any client to move from simple (simple clauses app setting ON)
	to non-simple(simple clauses app setting OFF). To move from non-simple to simple clauses, please refer to label 25647 first.
	--->
	<cffunction name="save_ComplexClauses" output="false">

		<cftransaction action="begin">

			<cftry>

				<cfif this.clauseCategory.getId()>

					<!---///////////////////////////////////////////////////////////////////////////////////////////////////////--->
					<!---////////////////////////////////////////// UPDATE /////////////////////////////////////////////////////--->
					<!---///////////////////////////////////////////////////////////////////////////////////////////////////////--->

					<cfquery name="qUpdateClauseCategory" datasource="#application.datasource#">

						UPDATE	Clause_Category
						SET		Clause_Category_Name	= <cfqueryPARAM value="#this.clauseCategory.getTitle()#" CFSQLType="CF_SQL_VARCHAR">,
								Required_For_All		= <cfqueryPARAM value="#this.clauseCategory.getRequireAll()#" CFSQLType="CF_SQL_BIT">,
								Require_Approval		= <cfqueryPARAM value="#this.clauseCategory.getRequireApproval()#" CFSQLType="CF_SQL_BIT">
						WHERE
								Clause_Category_ID = <cfqueryPARAM value="#this.clauseCategory.getId()#" CFSQLType="CF_SQL_INTEGER">

					</cfquery>

				<cfelse>

					<!---///////////////////////////////////////////////////////////////////////////////////////////////////////--->
					<!---////////////////////////////////////////// INSERT /////////////////////////////////////////////////////--->
					<!---///////////////////////////////////////////////////////////////////////////////////////////////////////--->
					<cfquery name="qInsertClauseCategory" datasource="#application.datasource#">

						INSERT INTO Clause_Category(Clause_Category_Name, Required_For_All, Require_Approval, Created_By)
						VALUES (
								<cfqueryPARAM value="#this.clauseCategory.getTitle()#" CFSQLType="CF_SQL_VARCHAR">,
								<cfqueryPARAM value="#this.clauseCategory.getRequireAll()#" CFSQLType="CF_SQL_BIT">,
								<cfqueryPARAM value="#this.clauseCategory.getRequireApproval()#" CFSQLType="CF_SQL_BIT">,
								<cfqueryPARAM value="#this.clauseCategory.getCreatedBy()#" CFSQLType="CF_SQL_VARCHAR">
								)

					</cfquery>

				</cfif>

				<cfif this.clauseCategory.getRequireAll()>

					<!---insert into clause template if it doesn't exist--->
					<cfquery name="qInsertReqClause" datasource="#application.datasource#">
						INSERT INTO	Clause_Template
								(Clause_Category_ID, Default_Clause_Library_ID, ProgramControl_Panel_Options_ID, isRequired, Clause_Type, Creator_User_ID)
						SELECT	Clause_Category_ID, Default_Clause_Library_ID, Program_Control_Panel_Options.ProgramControl_Panel_Options_ID, Required_For_All, 1, <cfqueryparam value="#this.clauseCategory.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">
						FROM	Clause_Category
								INNER JOIN Program_Control_Panel_Options
								ON	Program_Control_Panel_Options.Deleted = 0
								AND	Program_Control_Panel_Options.IsDominant = 1
								AND	NOT EXISTS
								(
									SELECT 	Clause_Category_ID
									FROM	Clause_Template
									WHERE	Clause_Template.Deleted = 0
									AND		Clause_Template.Clause_Category_ID = Clause_Category.Clause_Category_ID
									AND		Clause_Template.ProgramControl_Panel_Options_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
									AND		Clause_Template.Clause_Type = 1
								)
						WHERE	Clause_Category.Deleted = 0
						AND		Clause_Category.Clause_Category_ID = <cfqueryparam value="#this.clauseCategory.getId()#" cfsqltype="CF_SQL_NUMERIC">
						AND		Clause_Category.Required_For_All = 1
						AND		Clause_Category.Default_Clause_Library_ID IS NOT NULL
					</cfquery>

					<cfif this.clauseCategory.getApplyToExisting()>

						<cfquery name="qInsertReqClauseToPrograms" datasource="#application.datasource#">
							INSERT INTO	Clause_Program
									(Clause_Category_ID, Clause_Library_ID, Program_ID, Clause_Type, Creator_User_ID)
							SELECT	Clause_Category_ID, Default_Clause_Library_ID, Contract_Main.Contract_Main_ID, 1, <cfqueryparam value="#this.clauseCategory.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">
							FROM	Clause_Category
									INNER JOIN Contract_Main
									ON	Contract_Main.Deleted = 0
									AND	Contract_Main.Is_A_Revision = 0
									AND	Contract_Main.Contract_Status_Type_IDX < 3
									AND	NOT EXISTS
									(
										SELECT 	Clause_Category_ID
										FROM	Clause_Program
										WHERE	Clause_Program.Deleted = 0
										AND		Clause_Program.Clause_Category_ID = Clause_Category.Clause_Category_ID
										AND		Clause_Program.Program_ID = Contract_Main.Contract_Main_ID
										AND		Clause_Program.Clause_Type = 1
									)
							WHERE	Clause_Category.Deleted = 0
							AND		Clause_Category.Clause_Category_ID = <cfqueryparam value="#this.clauseCategory.getId()#" cfsqltype="CF_SQL_NUMERIC">
							AND		Clause_Category.Required_For_All = 1
							AND		Clause_Category.Default_Clause_Library_ID IS NOT NULL
						</cfquery>

					</cfif>
				</cfif>

				<cftransaction action="COMMIT" />

				<cfcatch>

					<cftransaction action="ROLLBACK" />
					<cfrethrow />

				</cfcatch>

			</cftry>

		</cftransaction>

	</cffunction>

	<cffunction name="delete" output="false" returntype="void">

		<cfargument name="categoryId" required="true" type="numeric" />

		<cfset qClauseIds = this.getClauseByCategory(arguments.categoryId) />

		<!---loop over clause id's and delete for each one--->
		<cfloop query="qClauseIds">

			<cfset clauseLibraryManager = CreateObject("component", "components.clause_library.ClauseLibraryManager").init() />
			<cfset clauseLibraryManager.getClause(Clause_Library_ID) />
			<cfset clauseLibraryManager.delete(1, 1)>

		</cfloop>

		<cfset useLakebaseForqDeleteCat = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("clause_category")>
<cfif useLakebaseForqDeleteCat>
	<cftry>
		<cfset application.oLakebase.updateRows("clause_category",
			{
				"deleted" = "eq.0",
				"clause_category_id" = "eq.#arguments.categoryId#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqDeleteCat = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeleteCat>
<cfquery name="qDeleteCat" datasource="#application.datasource#">

			UPDATE 	Clause_Category
			SET		Deleted = 1
			WHERE	Deleted = 0
			AND		Clause_Category_ID = #arguments.categoryId#
		</cfquery>
</cfif>

	</cffunction>

	<cffunction name="getClauseByCategory" output="false" returntype="query">

		<cfargument name="catId" required="true" type="numeric" />

		<cfset useLakebaseForqGetClause = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("clause_library")>
<cfif useLakebaseForqGetClause>
	<cftry>
		<cfset qGetClause = application.oLakebase.toQuery(
			application.oLakebase.selectRows("clause_library", {
				"deleted" = "eq.0",
				"clause_category_id" = "eq.#arguments.catId#",
				"select" = "clause_library_id"
			}), "clause_library_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetClause = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetClause>
<cfquery name="qGetClause" datasource="#application.datasource#">

			SELECT	Clause_Library_ID
			FROM 	Clause_Library
			WHERE 	Deleted = 0
			AND		Clause_Category_ID = #arguments.catId#

		</cfquery>
</cfif>

		<cfreturn qGetClause />

	</cffunction>

</cfcomponent>