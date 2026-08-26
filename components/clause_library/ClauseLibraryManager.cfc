<cfcomponent hint="Clause Library Manager" extends="components.clause_library.ClauseCategoryManager">
	<!---
	The app setting (simple clauses) is ON for clients using our new clauses functionality. The clients use different functions based on app setting.
	The code for app setting (simple clauses) ON and OFF is very different. On any environment,we cannot turn ON or OFF this switch. If is not possible for
	any client to move from simple (simple clauses app setting ON) to non-simple(simple clauses app setting OFF).
	To move from non-simple to simple clauses, please refer to label 25647 first.

	For any change to this file, first check whether the client requesting the modification has the "simple clauses" app switch ON or OFF. The clients with this
	app setting OFF use files with the "original" prefix for some of the clause library files and so a change in one file with or without the "original" prefix
	might require a corresponding change in the other file, if the functionality affected is the same for both. Please refer to label 25647.
	--->
	<cfset this.clauseLibraryAccess = 0>

	<cffunction name="init" output="false">

		<cfreturn this />

	</cffunction>


	<cffunction name="setClauseLibraryAccess" output="false">

		<cfargument name="clauseLibraryAccess" required="true" type="string" />

		<cfif arguments.clauseLibraryAccess EQ 1>
			<cfset this.clauseLibraryAccess = 1>
		<cfelse>
			<cfset this.clauseLibraryAccess = 0>
		</cfif>

	</cffunction>

	<cffunction name="getClauseLibraryAccess" output="false" returntype="numeric">

		<cfargument name="profileId" required="true" type="numeric" />

		<cfif NOT isDefined("this.qGetProfileSettings")>
			<!------ initiate the profile class ----->
			<cfset profile = CreateObject("component","components.user.Profile").init() />

			<!------ get the profile settings ----->
			<cfset this.qGetProfileSettings = profile.getProfileSettings(arguments.profileId)>

			<cfset this.setClauseLibraryAccess(this.qGetProfileSettings.Clause_Library_Access)>
		</cfif>

		<cfreturn this.clauseLibraryAccess />

	</cffunction>

	<cffunction name="getClause" output="false">

		<cfargument name="id" required="false" default=0 type="numeric" />
		<cfargument name="catId" required="false" default="0" type="numeric" />

		<cfset this.clauseLib = CreateObject("component","components.clause_library.ClauseLibrary").init() />

		<cfif arguments.id>

			<cfquery name="qGetClause" datasource="#application.datasource#">
				SELECT 	Clause_Library_ID,
						Clause_Category_ID,
						Clause_Library_Parent_ID,
						Clause_Library_Status,
						Clause_Library_Body,
						Clause_Library_Body_French,
						Created_By,
						Updated_By,
						Updated_Date
				FROM	Clause_Library
				WHERE 	Deleted = 0
				AND		Clause_Library_ID = <cfqueryparam value = "#arguments.id#" CFSQLType = "CF_SQL_INTEGER">
			</cfquery>

			<cfloop query="qGetClause">

				<cfset this.clauseLib.setId(Clause_Library_ID) />
				<cfset this.clauseLib.setCategoryId(Clause_Category_ID) />
				<cfset this.clauseLib.setParentId(Clause_Library_Parent_ID) />
				<cfset this.clauseLib.setStatus(Clause_Library_Status) />
				<cfset this.clauseLib.setBody(Clause_Library_Body) />
				<cfset this.clauseLib.setBodyFrench(Clause_Library_Body_French) />
				<cfset this.clauseLib.setCreatedBy(Created_By) />
				<cfset this.clauseLib.setUpdatedBy(Updated_By) />
				<cfset this.clauseLib.setUpdatedDate(Updated_Date) />

			</cfloop>

		<cfelse>

			<cfif arguments.catId>

				<cfset this.clauseLib.setCategoryId(arguments.catId) />

			</cfif>

		</cfif>

		<cfset this.clauseLib.setCategory(this.get(this.clauseLib.getCategoryId())) />

		<cfreturn this.clauseLib />

	</cffunction>

	<cffunction name="getAll" output="false" returntype="query">

		<cfset useLakebaseForqGetAll = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("clause_library")>
<cfif useLakebaseForqGetAll>
	<cftry>
		<cfset qGetAll = application.oLakebase.toQuery(
			application.oLakebase.selectRows("clause_library", {
				"deleted" = "eq.0",
				"clause_library_status" = "eq.1",
				"select" = "clause_library_id,clause_library_parent_id,clause_library_title,clause_library_body,clause_library_body_french,created_by,updated_by,updated_date"
			}), "clause_library_id,clause_library_parent_id,clause_library_title,clause_library_body,clause_library_body_french,created_by,updated_by,updated_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetAll = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetAll>
<cfquery name="qGetAll" datasource="#application.datasource#">
			SELECT 	Clause_Library_ID,
					Clause_Library_Parent_ID,
					Clause_Library_Title,
					Clause_Library_Body,
					Clause_Library_Body_French,
					Created_By,
					Updated_By,
					Updated_Date
			FROM	Clause_Library
			WHERE 	Deleted = 0
			AND		Clause_Library_Status = 1
		</cfquery>
</cfif>

		<cfreturn qGetAll />

	</cffunction>

	<cffunction name="getList" output="false" returntype="query">

		<cfargument name="idList" required="false" default="0" />

		<cfquery name="qGetList" datasource="#application.datasource#">
			SELECT 	Clause_Library.Clause_Library_ID,
					Clause_Library.Clause_Library_Parent_ID,
					Clause_Category.Clause_Category_Name,
					Clause_Category.Clause_Category_ID,
					Clause_Library.Clause_Library_Body,
					Clause_Library.Clause_Library_Body_French,
					Clause_Library.Clause_Library_Status,
					Clause_Library.Created_By,
					Clause_Library.Updated_By,
					Clause_Library.Updated_Date
			FROM	Clause_Library
					INNER JOIN Clause_Category
					ON
					Clause_Category.Clause_Category_ID = Clause_Library.Clause_Category_ID
					AND
					Clause_Category.Deleted = 0
			WHERE 	Clause_Library.Deleted = 0
			<!--- "Clause_Library.Clause_Library_Status = 1" is the latest version of the clause --->
			AND		Clause_Library.Clause_Library_Status = 1
			<cfif arguments.idList neq "undefined" and arguments.idList neq "0" and Len(trim(arguments.idList))>
				AND	Clause_Library.Clause_Library_ID IN (<cfqueryparam value="#arguments.idList#" cfsqltype="CF_SQL_INTEGER" list="yes" />)
			</cfif>

		</cfquery>

		<cfreturn qGetList />

	</cffunction>

	<!---
	Milan;19623/25647. The app setting (simple clauses) is ON for clients using our new clauses functionality. The clients with this app
	setting OFF use "save_ComplexClauses" function instead of this function. The code for app setting (simple clauses) ON and OFF is very different.
	On any environment,we cannot turn ON or OFF this switch. If is not possible for any client to move from simple (simple clauses app setting ON)
	to non-simple(simple clauses app setting OFF). To move from non-simple to simple clauses, please refer to label 25647 first.
	--->
	<cffunction name="save" output="false" returntype="numeric">

		<cfset returnValue = 0>
		<cftransaction action="begin">

			<cftry>
			<!---///////////////////////////////////////////////////////////////////////////////////////////////////////--->
			<!---////////////////////////////////////////// UPDATE /////////////////////////////////////////////////////--->
			<!---///////////////////////////////////////////////////////////////////////////////////////////////////////--->

			<cfif this.clauseLib.getId()>

				<!---get the version and the createdBy id from the previous record for this clause--->
				<cfquery name="qGetVerCreatedBy" datasource="#application.datasource#">

					SELECT	Clause_Library_Version_Number,
							Created_By
					FROM	Clause_Library
					WHERE	Clause_Library_ID = #this.clauseLib.getId()#
					AND		Deleted = 0

				</cfquery>

				<!---set the version and createdBy for new record--->
				<cfset version = qGetVerCreatedBy.Clause_Library_Version_Number + 1 />
				<cfset this.clauseLib.setCreatedBy(qGetVerCreatedBy.Created_By)>


					<cfquery name="qUpdateClauseLib" datasource="#application.datasource#">

						UPDATE	Clause_Library
						SET		Clause_Library_Status = <cfqueryparam value="2" cfsqltype="CF_SQL_NUMERIC">
						WHERE	Clause_Library_ID = #this.clauseLib.getId()#
						AND		Deleted = 0

					</cfquery>

					<cfset libStatus = 1 />


				<cfquery name="qInsertClauseLib" datasource="#application.datasource#">

					SET NOCOUNT ON

					INSERT INTO	Clause_Library
						(Clause_Library_Parent_ID, Clause_Category_ID, Clause_Library_Version_Number, Clause_Library_Status, Clause_Library_Body, Clause_Library_Body_French, Created_By, Updated_By)
					VALUES
						(
							<cfqueryparam value="#this.clauseLib.getParentId()#" cfsqltype="CF_SQL_NUMERIC">,
							<cfqueryparam value="#this.clauseLib.getCategoryId()#" cfsqltype="CF_SQL_NUMERIC">,
							<cfqueryparam value="#version#" cfsqltype="CF_SQL_NUMERIC">,
							<cfqueryparam value="#libStatus#" cfsqltype="CF_SQL_NUMERIC">,
							<cfqueryparam value="#trim(this.clauseLib.getBody())#" cfsqltype="CF_SQL_LONGVARCHAR">,
							<cfqueryparam value="#trim(this.clauseLib.getBodyFrench())#" cfsqltype="CF_SQL_LONGVARCHAR">,
							<cfqueryparam value="#this.clauseLib.getCreatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
							<cfqueryparam value="#this.clauseLib.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">
						)


					SELECT Clause_Library_ID = @@IDENTITY
					SET NOCOUNT OFF

				</cfquery>

				<!---set the id based on the identity--->
				<cfset this.clauseLib.setId(qInsertClauseLib.Clause_Library_ID)>

					<!---update if apply to all existing programs was selectecd--->
					<cfif this.clauseLib.getApplyToExisting()>

						<cfquery name="qUpdateClauseProgrm" datasource="#application.datasource#">

							UPDATE	Clause_Program
							SET		Clause_Library_ID = <cfqueryparam value="#this.clauseLib.getId()#" cfsqltype="CF_SQL_NUMERIC">
							WHERE	Clause_Library_ID IN
								(
									SELECT 	Clause_Library.Clause_Library_ID
									FROM 	Clause_Library
									WHERE	Clause_Library.Deleted = 0
									AND		Clause_Library.Clause_Library_Parent_ID = #this.clauseLib.getParentId()#
								)
							AND		Deleted = 0

						</cfquery>

					</cfif>

					<cfquery name="qUpdateClauseTemplate" datasource="#application.datasource#">

						UPDATE	Clause_Template
						SET		Default_Clause_Library_ID = <cfqueryparam value="#this.clauseLib.getId()#" cfsqltype="CF_SQL_NUMERIC">
						WHERE	Default_Clause_Library_ID IN
							(
								SELECT 	Clause_Library.Clause_Library_ID
								FROM 	Clause_Library
								WHERE	Clause_Library.Deleted = 0
								AND		Clause_Library.Clause_Library_Parent_ID = #this.clauseLib.getParentId()#
							)
						AND		Deleted = 0

					</cfquery>


			<!---///////////////////////////////////////////////////////////////////////////////////////////////////////--->
			<!---////////////////////////////////////////// INSERT /////////////////////////////////////////////////////--->
			<!---///////////////////////////////////////////////////////////////////////////////////////////////////////--->

			<cfelse>

				<cfquery name="qInsertClauseLib" datasource="#application.datasource#">

					SET NOCOUNT ON

					INSERT INTO	Clause_Library
						(Clause_Library_Version_Number, Clause_Category_ID, Clause_Library_Status, Clause_Library_Body, Clause_Library_Body_French, Created_By, Updated_By)
					VALUES
						(
							<cfqueryparam value="1" cfsqltype="CF_SQL_NUMERIC">,
							<cfqueryparam value="#this.clauseLib.getCategoryId()#" cfsqltype="CF_SQL_NUMERIC">,
							<cfqueryparam value="1" cfsqltype="CF_SQL_NUMERIC">,
							<cfqueryparam value="#trim(this.clauseLib.getBody())#" cfsqltype="CF_SQL_LONGVARCHAR">,
							<cfqueryparam value="#trim(this.clauseLib.getBodyFrench())#" cfsqltype="CF_SQL_LONGVARCHAR">,
							<cfqueryparam value="#this.clauseLib.getCreatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
							<cfqueryparam value="#this.clauseLib.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">
						)

					SELECT Clause_Library_ID = @@IDENTITY
					SET NOCOUNT OFF

				</cfquery>

				<!---set the id based on the identity--->
				<cfset this.clauseLib.setId(qInsertClauseLib.Clause_Library_ID)>

				<!---update the parent id with the id from the insert--->
				<cfquery name="qUpdateParentId" datasource="#application.datasource#">
					UPDATE	Clause_Library
					SET 	Clause_Library_Parent_ID = <cfqueryparam value="#this.clauseLib.getId()#" cfsqltype="CF_SQL_NUMERIC">
					WHERE	Clause_Library_ID = <cfqueryparam value="#this.clauseLib.getId()#" cfsqltype="CF_SQL_NUMERIC">
				</cfquery>

			</cfif><!---END IF ELSE--->

			<!------ set default clause ----->
			<cfif this.clauseLib.getIsDefault()>

				<cfquery name="qSetAsDefault" datasource="#application.datasource#">
					UPDATE	Clause_Category
					SET		Default_Clause_Library_ID = <cfqueryparam value="#this.clauseLib.getId()#" cfsqltype="CF_SQL_NUMERIC">
					WHERE
							Clause_Category_ID = <cfqueryparam value="#this.clauseLib.getCategoryId()#" cfsqltype="CF_SQL_NUMERIC">
							AND
							Deleted = 0
				</cfquery>

			<cfelse>

				<cfquery name="qSetAsDefaultIfNoneExist" datasource="#application.datasource#">
					UPDATE	Clause_Category
					SET		Default_Clause_Library_ID = <cfqueryparam value="#this.clauseLib.getId()#" cfsqltype="CF_SQL_NUMERIC">
					WHERE
							Clause_Category_ID = <cfqueryparam value="#this.clauseLib.getCategoryId()#" cfsqltype="CF_SQL_NUMERIC">
							AND
							Deleted = 0
							AND
							Default_Clause_Library_ID IS NULL
				</cfquery>

			</cfif>

				<cftransaction action="COMMIT">
				<cfset returnValue = this.clauseLib.getId()>

				<cfcatch>
					<cftransaction action="ROLLBACK">
					<cfrethrow>
				</cfcatch>

			</cftry>
		</cftransaction>

		<cfreturn returnValue />

	</cffunction>

	<!---
	Milan;19623/25647. The app setting (simple clauses) is ON for clients using our new clauses functionality. The clients with this app
	setting OFF use this function instead of "save" function. The code for app setting (simple clauses) ON and OFF is very different.
	On any environment,we cannot turn ON or OFF this switch. If is not possible for any client to move from simple (simple clauses app setting ON)
	to non-simple(simple clauses app setting OFF). To move from non-simple to simple clauses, please refer to label 25647 first.
	--->
	<cffunction name="save_ComplexClauses" output="false" returntype="numeric">

		<cfset returnValue = 0>
		<cftransaction action="begin">

			<cftry>
			<!---///////////////////////////////////////////////////////////////////////////////////////////////////////--->
			<!---////////////////////////////////////////// UPDATE /////////////////////////////////////////////////////--->
			<!---///////////////////////////////////////////////////////////////////////////////////////////////////////--->

			<cfif this.clauseLib.getId()>

				<!---get the version and the createdBy id from the previous record for this clause--->
				<cfquery name="qGetVerCreatedBy" datasource="#application.datasource#">

					SELECT	Clause_Library_Version_Number,
							Created_By
					FROM	Clause_Library
					WHERE	Clause_Library_ID = #this.clauseLib.getId()#
					AND		Deleted = 0

				</cfquery>

				<!---set the version and createdBy for new record--->
				<cfset version = qGetVerCreatedBy.Clause_Library_Version_Number + 1 />
				<cfset this.clauseLib.setCreatedBy(qGetVerCreatedBy.Created_By)>

				<!---set the status to 3 if this is being edited from a program--->
				<cfif this.clauseLib.getEditFromProgram()>

					<cfset libStatus = 3 />
					<cfset libId = this.clauseLib.getId() />

				<!---set previous record to history if this isn't being updated from programs--->
				<cfelse>

					<cfquery name="qUpdateClauseLib" datasource="#application.datasource#">

						UPDATE	Clause_Library
						SET		Clause_Library_Status = <cfqueryparam value="2" cfsqltype="CF_SQL_NUMERIC">
						WHERE	Clause_Library_ID = #this.clauseLib.getId()#
						AND		Deleted = 0

					</cfquery>

					<cfset libStatus = 1 />

				</cfif>

				<cfquery name="qInsertClauseLib" datasource="#application.datasource#">

					SET NOCOUNT ON

					INSERT INTO	Clause_Library
						(Clause_Library_Parent_ID, Clause_Category_ID, Clause_Library_Version_Number, Clause_Library_Status, Clause_Library_Body, Clause_Library_Body_French, Created_By, Updated_By)
					VALUES
						(
							<cfqueryparam value="#this.clauseLib.getParentId()#" cfsqltype="CF_SQL_NUMERIC">,
							<cfqueryparam value="#this.clauseLib.getCategoryId()#" cfsqltype="CF_SQL_NUMERIC">,
							<cfqueryparam value="#version#" cfsqltype="CF_SQL_NUMERIC">,
							<cfqueryparam value="#libStatus#" cfsqltype="CF_SQL_NUMERIC">,
							<cfqueryparam value="#trim(this.clauseLib.getBody())#" cfsqltype="CF_SQL_LONGVARCHAR">,
							<cfqueryparam value="#trim(this.clauseLib.getBodyFrench())#" cfsqltype="CF_SQL_LONGVARCHAR">,
							<cfqueryparam value="#this.clauseLib.getCreatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
							<cfqueryparam value="#this.clauseLib.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">
						)


					SELECT Clause_Library_ID = @@IDENTITY
					SET NOCOUNT OFF

				</cfquery>

				<!---set the id based on the identity--->
				<cfset this.clauseLib.setId(qInsertClauseLib.Clause_Library_ID)>

				<!---if this is being edited from programs then update id in clause program then bail--->
				<cfif this.clauseLib.getEditFromProgram()>

					<cfquery name="qUpdateClauseProgram" datasource="#application.datasource#">

						UPDATE	Clause_Program
						SET		Clause_Library_ID = <cfqueryparam value="#this.clauseLib.getId()#" cfsqltype="CF_SQL_NUMERIC">
						WHERE 	Clause_Library_ID = #libId#
						AND		Deleted = 0
						AND		Overridden = 0

					</cfquery>

				<cfelse>
					<!---update if apply to all existing programs was selectecd--->
					<cfif this.clauseLib.getApplyToExisting()>

						<cfquery name="qUpdateClauseProgrm" datasource="#application.datasource#">

							UPDATE	Clause_Program
							SET		Clause_Library_ID = <cfqueryparam value="#this.clauseLib.getId()#" cfsqltype="CF_SQL_NUMERIC">
							WHERE	Clause_Library_ID IN
								(
									SELECT 	Clause_Library.Clause_Library_ID
									FROM 	Clause_Library
									WHERE	Clause_Library.Deleted = 0
									AND		Clause_Library.Clause_Library_Status != 3
									AND		Clause_Library.Clause_Library_Parent_ID = #this.clauseLib.getParentId()#
								)
							<!---if getApplyToExisting() is 1 then only apply to programs that haven't been approved--->
							<cfif this.clauseLib.getApplyToExisting() eq 1>
							AND		Exists
								(
									SELECT 	Contract_Main_ID
									FROM	Contract_Main
									WHERE	Contract_Main.Is_A_Revision = 0
									AND		Contract_Main.Deleted = 0
									AND		Contract_Main.Contract_Status_Type_IDX < 3
									AND		Contract_Main.Contract_Main_ID = Clause_Program.Program_ID
								)
							</cfif>
							AND		Deleted = 0

						</cfquery>

					</cfif>

					<cfquery name="qUpdateClauseTemplate" datasource="#application.datasource#">

						UPDATE	Clause_Template
						SET		Default_Clause_Library_ID = <cfqueryparam value="#this.clauseLib.getId()#" cfsqltype="CF_SQL_NUMERIC">
						WHERE	Default_Clause_Library_ID IN
							(
								SELECT 	Clause_Library.Clause_Library_ID
								FROM 	Clause_Library
								WHERE	Clause_Library.Deleted = 0
								AND		Clause_Library.Clause_Library_Status != 3
								AND		Clause_Library.Clause_Library_Parent_ID = #this.clauseLib.getParentId()#
							)
						AND		Deleted = 0

					</cfquery>

				</cfif>

			<!---///////////////////////////////////////////////////////////////////////////////////////////////////////--->
			<!---////////////////////////////////////////// INSERT /////////////////////////////////////////////////////--->
			<!---///////////////////////////////////////////////////////////////////////////////////////////////////////--->

			<cfelse>

				<cfquery name="qInsertClauseLib" datasource="#application.datasource#">

					SET NOCOUNT ON

					INSERT INTO	Clause_Library
						(Clause_Library_Version_Number, Clause_Category_ID, Clause_Library_Status, Clause_Library_Body, Clause_Library_Body_French, Created_By, Updated_By)
					VALUES
						(
							<cfqueryparam value="1" cfsqltype="CF_SQL_NUMERIC">,
							<cfqueryparam value="#this.clauseLib.getCategoryId()#" cfsqltype="CF_SQL_NUMERIC">,
							<cfqueryparam value="1" cfsqltype="CF_SQL_NUMERIC">,
							<cfqueryparam value="#trim(this.clauseLib.getBody())#" cfsqltype="CF_SQL_LONGVARCHAR">,
							<cfqueryparam value="#trim(this.clauseLib.getBodyFrench())#" cfsqltype="CF_SQL_LONGVARCHAR">,
							<cfqueryparam value="#this.clauseLib.getCreatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
							<cfqueryparam value="#this.clauseLib.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">
						)

					SELECT Clause_Library_ID = @@IDENTITY
					SET NOCOUNT OFF

				</cfquery>

				<!---set the id based on the identity--->
				<cfset this.clauseLib.setId(qInsertClauseLib.Clause_Library_ID)>

				<!---update the parent id with the id from the insert--->
				<cfquery name="qUpdateParentId" datasource="#application.datasource#">
					UPDATE	Clause_Library
					SET 	Clause_Library_Parent_ID = <cfqueryparam value="#this.clauseLib.getId()#" cfsqltype="CF_SQL_NUMERIC">
					WHERE	Clause_Library_ID = <cfqueryparam value="#this.clauseLib.getId()#" cfsqltype="CF_SQL_NUMERIC">
				</cfquery>

			</cfif><!---END IF ELSE--->

			<!------ set default clause ----->
			<cfif this.clauseLib.getIsDefault()>

				<cfquery name="qSetAsDefault" datasource="#application.datasource#">
					UPDATE	Clause_Category
					SET		Default_Clause_Library_ID = <cfqueryparam value="#this.clauseLib.getId()#" cfsqltype="CF_SQL_NUMERIC">
					WHERE
							Clause_Category_ID = <cfqueryparam value="#this.clauseLib.getCategoryId()#" cfsqltype="CF_SQL_NUMERIC">
							AND
							Deleted = 0
				</cfquery>

			<cfelse>

				<cfquery name="qSetAsDefaultIfNoneExist" datasource="#application.datasource#">
					UPDATE	Clause_Category
					SET		Default_Clause_Library_ID = <cfqueryparam value="#this.clauseLib.getId()#" cfsqltype="CF_SQL_NUMERIC">
					WHERE
							Clause_Category_ID = <cfqueryparam value="#this.clauseLib.getCategoryId()#" cfsqltype="CF_SQL_NUMERIC">
							AND
							Deleted = 0
							AND
							Default_Clause_Library_ID IS NULL
				</cfquery>

			</cfif>

				<cftransaction action="COMMIT">
				<cfset returnValue = this.clauseLib.getId()>

				<cfcatch>
					<cftransaction action="ROLLBACK">
					<cfrethrow>
				</cfcatch>

			</cftry>
		</cftransaction>

		<cfreturn returnValue />

	</cffunction>

	<!---
	Milan;19623/25647. The app setting (simple clauses) is ON for clients using our new clauses functionality. The clients with this app
	setting OFF use "delete_ComplexClauses" function instead of this function. The code for app setting (simple clauses) ON and OFF is very different.
	On any environment,we cannot turn ON or OFF this switch. If is not possible for any client to move from simple (simple clauses app setting ON)
	to non-simple(simple clauses app setting OFF). To move from non-simple to simple clauses, please refer to label 25647 first.
	--->
	<cffunction name="delete" output="false">
		<cftransaction action="begin">

			<cftry>
					<!------ Delete from clause program ----->
					<cfquery name="qDeleteClauseProgram" datasource="#application.datasource#">
						UPDATE	Clause_Program
						SET		Deleted = 1
						WHERE
								Clause_Library_ID IN
									(
										SELECT 	Clause_Library.Clause_Library_ID
										FROM 	Clause_Library
										WHERE	Clause_Library.Deleted = 0
										AND		Clause_Library.Clause_Library_Parent_ID = #this.clauseLib.getParentId()#
									)
								AND		Exists
									(
										SELECT 	Contract_Main_ID
										FROM	Contract_Main
										WHERE	Contract_Main.Deleted = 0
										AND		Contract_Main.Contract_Main_ID = Clause_Program.Program_ID
									)
								AND		Deleted = 0
					</cfquery>

					<!------ Delete from clause program ----->
					<cfquery name="qDeleteClauseProgram" datasource="#application.datasource#">
						UPDATE	Clause_Template
						SET		Deleted = 1
						WHERE
								Default_Clause_Library_ID IN
									(
										SELECT 	Clause_Library.Clause_Library_ID
										FROM 	Clause_Library
										WHERE	Clause_Library.Deleted = 0
										AND		Clause_Library.Clause_Library_Parent_ID = #this.clauseLib.getParentId()#
									)
								AND		Deleted = 0
					</cfquery>
				<!---</cfif>--->

				<!------ Delete from clause library ----->
				<cfquery name="qDeleteClauseLib" datasource="#application.datasource#">

					UPDATE	Clause_Library
					SET		Clause_Library_Status = <cfqueryparam value="2" cfsqltype="CF_SQL_NUMERIC">
					WHERE	Clause_Library_ID = #this.clauseLib.getId()#
					AND		Deleted = 0

				</cfquery>

				<cftransaction action="COMMIT">

				<cfcatch>

					<cftransaction action="ROLLBACK">

					<cfrethrow>

				</cfcatch>
			</cftry>

		</cftransaction>

	</cffunction>

	<!---
	Milan;19623/25647. The app setting (simple clauses) is ON for clients using our new clauses functionality. The clients with this app
	setting OFF use this function instead of "delete" function. The code for app setting (simple clauses) ON and OFF is very different.
	On any environment,we cannot turn ON or OFF this switch. If is not possible for any client to move from simple (simple clauses app setting ON)
	to non-simple(simple clauses app setting OFF). To move from non-simple to simple clauses, please refer to label 25647 first.
	--->
	<cffunction name="delete_ComplexClauses" output="false">

		<cfargument name="bDeleteFromTemplate" type="numeric" required="true" />
		<cfargument name="bDeleteFromProgram" type="numeric" required="true" />

		<cftransaction action="begin">

			<cftry>

				<cfif arguments.bDeleteFromProgram>

					<!------ Delete from clause program ----->
					<cfquery name="qDeleteClauseProgram" datasource="#application.datasource#">
						UPDATE	Clause_Program
						SET		Deleted = 1
						WHERE
								Clause_Library_ID IN
									(
										SELECT 	Clause_Library.Clause_Library_ID
										FROM 	Clause_Library
										WHERE	Clause_Library.Deleted = 0
										AND		Clause_Library.Clause_Library_Status != 3
										AND		Clause_Library.Clause_Library_Parent_ID = #this.clauseLib.getParentId()#
									)
								AND		Exists
									(
										SELECT 	Contract_Main_ID
										FROM	Contract_Main
										WHERE	Contract_Main.Is_A_Revision = 0
										AND		Contract_Main.Deleted = 0
										AND		Contract_Main.Contract_Status_Type_IDX < 3
										AND		Contract_Main.Contract_Main_ID = Clause_Program.Program_ID
									)
								AND		Deleted = 0
					</cfquery>
				</cfif>

				<cfif arguments.bDeleteFromTemplate>
					<!------ Delete from clause program ----->
					<cfquery name="qDeleteClauseProgram" datasource="#application.datasource#">
						UPDATE	Clause_Template
						SET		Deleted = 1
						WHERE
								Default_Clause_Library_ID IN
									(
										SELECT 	Clause_Library.Clause_Library_ID
										FROM 	Clause_Library
										WHERE	Clause_Library.Deleted = 0
										AND		Clause_Library.Clause_Library_Status != 3
										AND		Clause_Library.Clause_Library_Parent_ID = #this.clauseLib.getParentId()#
									)
								AND		Deleted = 0
					</cfquery>
				</cfif>

				<!------ Delete from clause library ----->
				<cfquery name="qDeleteClauseLib" datasource="#application.datasource#">

					UPDATE	Clause_Library
					SET		Clause_Library_Status = <cfqueryparam value="2" cfsqltype="CF_SQL_NUMERIC">
					WHERE	Clause_Library_ID = #this.clauseLib.getId()#
					AND		Deleted = 0

				</cfquery>

				<cftransaction action="COMMIT">

				<cfcatch>

					<cftransaction action="ROLLBACK">

					<cfrethrow>

				</cfcatch>
			</cftry>

		</cftransaction>

	</cffunction>

	<cffunction name="getDiscountTypes" output="false" returntype="query">

		<cfset useLakebaseForqGetDiscountTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("discount_type")>
<cfif useLakebaseForqGetDiscountTypes>
	<cftry>
		<cfset qGetDiscountTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("discount_type", {
				"deleted" = "eq.0",
				"select" = "discount_type_id,discount_type_desc"
			}), "discount_type_id,discount_type_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDiscountTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDiscountTypes>
<cfquery name="qGetDiscountTypes" datasource="#application.datasource#">
			SELECT 	Discount_Type_ID,
					Discount_Type_Desc
			FROM 	Discount_Type
			WHERE	Deleted = 0
		</cfquery>
</cfif>

		<cfreturn qGetDiscountTypes />

	</cffunction>

	<cffunction name="search" output="false" returntype="query">

		<cfargument name="search" type="struct" required="false" default="#StructNew()#" />

		<cfset this.search = arguments.search>

		<cfparam name="this.search.sortBy" 	default="title">
		<cfparam name="this.search.sortOrder" 	default="ASC">
		<cfset this.search.sortBy = LCase(this.search.sortBy)>
		<cfset this.search.sortOrder = LCase(this.search.sortOrder)>

		<cfset sql_Sort_By="Clause_Category.Clause_Category_Name">
		<cfswitch expression="#this.search.sortBy#">
			<cfcase value="Category">
				<cfset sql_Sort_By="Clause_Category.Clause_Category_Name">
			</cfcase>
			<cfcase value="body">
				<cfset sql_Sort_By="Clause_Library_Body">
			</cfcase>
		</cfswitch>

		<cfif this.search.sortOrder EQ "desc">
			<cfset sql_Sort_By="#sql_Sort_By# DESC">
		<cfelse>
			<cfset sql_Sort_By="#sql_Sort_By# ASC">
		</cfif>

		<cfquery name="qGetClause" datasource="#application.datasource#">

			SELECT	DISTINCT Clause_Library.Clause_Library_ID,
					CONVERT(varchar(MAX), Clause_Library.Clause_Library_Body) AS Clause_Library_Body,
					CONVERT(varchar(MAX), Clause_Library.Clause_Library_Body_French) AS Clause_Library_Body_French,
					Clause_Category.Clause_Category_ID,
					Clause_Category.Clause_Category_Name,
					<cfif Super.variableExist("this.search.templateId", "")>
					Clause_Template.Default_Clause_Library_ID
					<cfelse>
					Clause_Category.Default_Clause_Library_ID
					</cfif>
			FROM	Clause_Library
					INNER JOIN Clause_Category
					ON
					Clause_Category.Clause_Category_ID = Clause_Library.Clause_Category_ID
					AND
					Clause_Category.Deleted = 0
					<!------ search for required or optional from template ----->
					<cfif Super.variableExist("this.search.templateId", "")>
					INNER JOIN Clause_Template
					ON
					Clause_Template.ProgramControl_Panel_Options_ID = #this.search.templateId#
					AND
					Clause_Template.Clause_Category_ID = Clause_Category.Clause_Category_ID
					AND
					Clause_Template.Deleted = 0
					</cfif>
			WHERE
					Clause_Library.Deleted = 0
					AND	Clause_Library.Clause_Library_Status = 1
					<cfif Super.variableExist("this.search.categoryId", "")>
					AND Clause_Library.Clause_Category_ID = <cfqueryPARAM value = "#this.search.categoryId#" CFSQLType = "CF_SQL_INTEGER">
					</cfif>
					<cfif Super.variableExist("this.search.body", "")>
					AND PATINDEX ('%#this.search.body#%' , Clause_Library.Clause_Library_Body) > 0
					</cfif>
			ORDER BY #sql_Sort_By#
		</cfquery>

		<cfreturn qGetClause>

	</cffunction>

</cfcomponent>