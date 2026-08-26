<cfcomponent hint="Clause Program Manager" extends="components.Base">
	<!--- 
	The app setting (simple clauses) is ON for clients using our new clauses functionality. The code for app setting (simple clauses) ON and OFF is very different. 
	On any environment,we cannot turn ON or OFF this switch. If is not possible for any client to move from simple (simple clauses app setting ON) to non-simple
	(simple clauses app setting OFF).To move from non-simple to simple clauses, please refer to label 25647 first.

	For any change to this file, first check whether the client requesting the modification has the "simple clauses" app switch ON or OFF. The clients with this
	app setting OFF use files with the "original" prefix for some of the clause library files and so a change in one file with or without the "original" prefix 
	might require a corresponding change in the other file, if the functionality affected is the same for both. Also, any change in this file might require a app switch
	condition. Please refer to label 25647.
	--->
	<cfset this.clauseEditRemoveAccess = 0>
	<cfset this.clauseApproveAccess = 0>
	<cfset variables.appsettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

	<cffunction name="init" output="false">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="setClauseEditRemoveAccess" output="false">
	
		<cfargument name="clauseEditRemoveAccess" required="true" type="string" />
		
		<cfif arguments.clauseEditRemoveAccess EQ 1>
			<cfset this.clauseEditRemoveAccess = 1>
		<cfelse>
			<cfset this.clauseEditRemoveAccess = 0>
		</cfif>		
		
	</cffunction>
	
	<cffunction name="getClauseEditRemoveAccess" output="false" returntype="numeric">
	
		<cfargument name="profileId" required="true" type="numeric" />
		
		<cfset this.getProfileSettings(arguments.profileId)>
	
		<cfreturn this.clauseEditRemoveAccess />
		
	</cffunction>
	
	<cffunction name="setClauseProgramApproveAccess" output="false">
	
		<cfargument name="clauseProgramApproveAccess" required="true" type="string" />
		
		<cfif arguments.clauseProgramApproveAccess EQ 1>
			<cfset this.clauseProgramApproveAccess = 1>
		<cfelse>
			<cfset this.clauseProgramApproveAccess = 0>
		</cfif>		
		
	</cffunction>
	
	<cffunction name="getClauseProgramApproveAccess" output="false" returntype="numeric">
	
		<cfargument name="profileId" required="true" type="numeric" />
		
		<cfset this.getProfileSettings(arguments.profileId)>
	
		<cfreturn this.clauseProgramApproveAccess />
		
	</cffunction>
	
	<cffunction name="getProfileSettings" output="false">
	
		<cfargument name="profileId" required="true" type="numeric" />
		
		<cfif NOT isDefined("this.qGetProfileSettings")>
			<!------ initiate the profile class ----->
			<cfset profile = CreateObject("component","components.user.Profile").init() />
			
			<!------ get the profile settings ----->
			<cfset this.qGetProfileSettings = profile.getProfileSettings(arguments.profileId)>		
			
			<cfset this.setClauseEditRemoveAccess(this.qGetProfileSettings.Clause_Program_Edit_Remove)>
			<cfset this.setClauseProgramApproveAccess(this.qGetProfileSettings.Cont_Prog_Approval_Rights)>
		</cfif>
		
	</cffunction>
	
	<cffunction name="importRequiredClause" output="false">
	
		<cfargument name="programTemplateId" required="true" type="numeric" />
		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="userId" required="true" type="string" />
		<cfargument name="clauseType" required="true" type="numeric" />
		<!--- Dev Note: Milan - 19623/25647 - discountTypeId is not being used now for "simple clauses" --->
		<cfargument name="discountTypeId" required="false" default="0" type="numeric" />
		
		
		
		<cfquery name="qImportClause" datasource="#application.datasource#">
			INSERT INTO	Clause_Program 
					(Clause_Library_ID, Clause_Category_ID, Program_ID, Clause_Template_ID, Clause_Type, Discount_Type_ID, Creator_User_ID,overridden,deleted,created_Date)
			SELECT	 
					ISNULL((SELECT TOP 1 Clause_Program.Clause_Library_ID FROM Clause_Program WHERE Clause_Program.Deleted = 0 AND Clause_Program.Overridden = 0 AND Clause_Program.Program_ID = #arguments.programId# AND Clause_Program.Clause_Category_ID = Clause_Template.Clause_Category_ID), Clause_Template.Default_Clause_Library_ID)
					, Clause_Category.Clause_Category_ID, #arguments.programId#, Clause_Template_ID, Clause_Type, Discount_Type_ID, '#arguments.userId#',0,0,getdate()
			FROM	Clause_Template
					INNER JOIN	Clause_Library
					ON
					Clause_Library.Clause_Library_ID = Clause_Template.Default_Clause_Library_ID
					AND
					Clause_Library.Deleted = 0
					INNER JOIN	Clause_Category
					ON
					Clause_Library.Clause_Category_ID = Clause_Category.Clause_Category_ID
					AND
					Clause_Category.Deleted = 0
			WHERE
					Clause_Template.ProgramControl_Panel_Options_ID = #arguments.programTemplateId#
					AND
					Clause_Template.Deleted = 0
					<!--- Dev Note: Milan - 19623/25647. If "simple clauses" is OFF, then we have optional and required clauses, 
					else we do not.
					--->
					<cfif appSettings.getSimpleClause() eq 0>
					AND
					Clause_Template.isRequired = 1
					</cfif>
					AND
					Clause_Template.Clause_Type = #arguments.clauseType#
					<cfif arguments.discountTypeId NEQ 0>
					AND
					Clause_Template.Discount_Type_ID = #arguments.discountTypeId#
					</cfif>
					AND
					NOT EXISTS
					(
					SELECT	Clause_Program.Clause_Library_ID
					FROM	Clause_Program
					WHERE
							Clause_Program.Program_ID = #arguments.programId#
							AND
							Clause_Program.Deleted = 0
							AND
							Clause_Program.Clause_Type = Clause_Template.Clause_Type
							AND
							ISNULL(Clause_Program.Discount_Type_ID, 0) = ISNULL(Clause_Template.Discount_Type_ID, 0)
							AND
							Clause_Program.Clause_Category_ID = Clause_Template.Clause_Category_ID
					)					
		</cfquery>	
				
	</cffunction>
	
	
	<cffunction name="removeRequiredClause" output="false">
	
		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="userId" required="true" type="string" />
		<cfargument name="clauseType" required="true" type="numeric" />
		<!--- Dev Note: Milan - 19623/25647 - discountTypeId is not being used now for "simple clauses" --->
		<cfargument name="discountTypeId" required="false" default="0" type="numeric" />
		
		<cfquery name="qDeleteClause" datasource="#application.datasource#">
			UPDATE	Clause_Program
			SET		Clause_Program.Deleted = 1
			WHERE	Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER" />
					<!------ 
					Clause_Program.isRequired = 1
					AND 
					----->
			AND		Clause_Program.Clause_Type = #arguments.clauseType#
			<!--- Dev Note: Milan - 19623/25647 - discountTypeId is not being used now for "simple clauses" --->
					<cfif arguments.discountTypeId NEQ 0>
					AND
					Clause_Program.Discount_Type_ID = #arguments.discountTypeId#
					</cfif>
					AND
					Clause_Program.Deleted = 0
		</cfquery>
				
	</cffunction>
	
	
	<cffunction name="getProgramClause" output="false" returntype="query">
	
		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="clauseType" required="false" default="" />
		<!--- Dev Note: Milan - 19623/25647 - discountTypeId is not being used now for "simple clauses" --->
		<cfargument name="discountTypeId" required="false" default="" />
		<cfargument name="isRequired" required="false" default="" />
		
		<cfset stSearch = StructNew()>
		<cfset stSearch.programId = arguments.programId>
		<cfif Len(trim(arguments.clauseType))>
			<cfset stSearch.clauseType = arguments.clauseType>
		</cfif>
		<cfif Len(trim(arguments.discountTypeId))>
			<cfset stSearch.discountTypeId = arguments.discountTypeId>
		</cfif>
		<cfif Len(trim(arguments.isRequired))>
			<cfset stSearch.isRequired = arguments.isRequired>
		</cfif>
		<cfset qProgramClause = search(stSearch)>		
		
		<cfreturn qProgramClause />
	
	</cffunction>
	
	<cffunction name="search" output="false" returntype="query">
	
		<cfargument name="search" type="struct" required="true" />
		
		<cfset this.search = arguments.search>
		
		<cfquery name="qProgramClause" datasource="#application.datasource#">
			SELECT	Clause_Category.Clause_Category_ID,
					Clause_Category.Clause_Category_Name, 
					Clause_Library.Clause_Library_Body,
					Clause_Library.Clause_Library_ID,
					Clause_Library.Clause_Library_Status,
					Clause_Category.Require_Approval,
					Clause_Program.Clause_Program_ID,
					ISNULL(Clause_Template.isRequired, 0) isRequired,
					Clause_Program.Clause_Type,
					Clause_Program.Discount_Type_ID,
					Clause_Program.Overridden,
					Clause_Program.Creator_User_ID,
					Clause_Program.Clause_Template_ID,
					Clause_Program.Program_ID					
			FROM	Clause_Program
					INNER JOIN Contract_Main
					ON
					Contract_Main.Deleted = 0
					AND
					Contract_Main.Contract_Main_ID = Clause_Program.Program_ID
					INNER JOIN Clause_Library
					ON
					Clause_Library.Clause_Library_ID = 		Clause_Program.Clause_Library_ID
					AND
					Clause_Library.Deleted = 0
					INNER JOIN Clause_Category
					ON
					Clause_Category.Clause_Category_ID = 	Clause_Library.Clause_Category_ID
					AND
					Clause_Category.Deleted = 0
					<!------ the master clause is the one which is active in the clause library ----->
					<!------ properties like Require_Approval is governed by it ----->
					LEFT JOIN Clause_Template
					ON
					Clause_Template.Deleted = 0
					AND
					Clause_Template.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
					AND
					Clause_Template.Clause_Type = Clause_Program.Clause_Type
					AND
					ISNULL(Clause_Template.Discount_Type_ID, 0) = ISNULL(Clause_Program.Discount_Type_ID, 0)
					<cfif Super.variableExist("this.search.isRequired", "")>
					AND
					Clause_Template.isRequired = #this.search.isRequired#
					</cfif>
					AND
					Clause_Template.Clause_Category_ID = Clause_Category.Clause_Category_ID
			WHERE
					Clause_Program.Deleted = 0
					AND
					Clause_Program.Overridden = 0
					<cfif Super.variableExist("this.search.programId", "")>
					AND
					Clause_Program.Program_ID = #this.search.programId#
					</cfif>
					<cfif Super.variableExist("this.search.clauseType", "")>
					AND
					Clause_Program.Clause_Type = #this.search.clauseType#
					</cfif>
					<!--- Dev Note: Milan - 19623/25647 - this.search.discountTypeId is not being used now for "simple clauses" --->
					<cfif Super.variableExist("this.search.discountTypeId", "0")>
					AND
					Clause_Program.Discount_Type_ID = #this.search.discountTypeId#
					</cfif>			
					
					ORDER BY Clause_Category.Clause_Category_ID DESC
		</cfquery>
		
		<cfreturn qProgramClause />
	
	</cffunction>
	
	<cffunction name="getAllProgramClause" output="false" returntype="query">
	
		<cfargument name="programId" required="true" type="numeric" />
		
		<cfquery name="qProgramClause" datasource="#application.datasource#">
			SELECT	Clause_Program.*
			FROM	Clause_Program
			WHERE
					Clause_Program.Deleted = 0
					AND
					Clause_Program.Overridden = 0
					AND
					Clause_Program.Program_ID = #arguments.programId#
												
		</cfquery>	
		
		<cfreturn qProgramClause />
	
	</cffunction>
	
	<!--- Dev Note: Milan - 19623/25647 - This one is not being used now for "simple clauses" --->
	<cffunction name="getClauseRequireApproval" output="false" returntype="query">
	
		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="discountTypeIdList" required="true" type="string" />
		
		<cfquery name="qGetClauseRequireApproval" datasource="#application.datasource#">
			SELECT	Clause_Library.Clause_Library_ID, Clause_Category.Clause_Category_ID, Clause_Category.Clause_Category_Name, CPL.Clause_Library_ID AS Clause_ID, Clause_Category.Clause_Category_Name AS Category_Name,
					Clause_Library.Clause_Library_Body, CPL.Clause_Library_Body AS Clause_Body,
				CASE
				WHEN 	CPL.Clause_library_Status = 3 THEN
					2
				ELSE
					1
				END AS Clause_Change_Type,
				Clause_Template.Clause_Type,
				Clause_Template.Discount_Type_ID,
				Clause_Template.isRequired
			FROM	Contract_Main
				INNER JOIN	Clause_Template
				ON
				Clause_Template.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
				AND
				Clause_Template.Deleted = 0	
				AND
				(
					Clause_Template.Clause_Type = 1
					<cfif arguments.discountTypeIdList NEQ "">
					OR
					(
						Clause_Template.Clause_Type = 2
						AND						
						Clause_Template.Discount_Type_ID IN (#arguments.discountTypeIdList#)
					)
					</cfif>
				)
				INNER JOIN	Clause_Category
				ON
				Clause_Category.Clause_Category_ID = Clause_Template.Clause_Category_ID
				AND
				Clause_Category.Deleted = 0	
				AND
				Clause_Category.Require_Approval = 1
				INNER JOIN	Clause_Library
				ON
				Clause_Library.Clause_Category_ID = Clause_Category.Clause_Category_ID
				AND
				Clause_Library.Clause_Library_ID = Clause_Template.Default_Clause_Library_ID
				AND
				Clause_Library.Deleted = 0					
				LEFT JOIN 	Clause_Program
				ON
				Clause_Program.Program_ID = Contract_Main.Contract_Main_ID
				AND
				Clause_Program.Deleted = 0
				AND
				Clause_Program.Overridden = 0
				AND
				Clause_Program.Clause_Type = Clause_Template.Clause_Type
				AND
				ISNULL(Clause_Program.Discount_Type_ID, 0) = ISNULL(Clause_Template.Discount_Type_ID, 0)
				AND
				Clause_Program.Clause_Category_ID  = Clause_Library.Clause_Category_ID
				LEFT JOIN Clause_Library CPL
				ON
				CPL.Clause_Library_ID = Clause_Program.Clause_Library_ID
				AND
				CPL.Deleted = 0
			WHERE	
				Contract_Main.Contract_Main_ID = #arguments.programId#
				AND
				(	
					-- removed required
					(	 
					Clause_Program.Clause_Program_ID IS NULL
					AND
					Clause_Template.isRequired = 1
					)
					OR
					(
					CPL.Clause_library_Status = 3
					)
				)
			ORDER BY Clause_Change_Type
		</cfquery>
	
		<cfreturn qGetClauseRequireApproval />
		
	</cffunction>
	
	<cffunction name="saveFromProgram" output="false">
	
		<cfargument name="stData" type="struct" required="true" default="" />
		
		<cftransaction action="begin">
		
		<cftry>
		
			<!---/////////////////////////////////////////////////////////////////////////////////////////////////////--->
			<!---////////////////////////////////////////////OPTIONAL CLAUSES/////////////////////////////////////////--->
			<!---/////////////////////////////////////////////////////////////////////////////////////////////////////--->
			
			<!----   GENERIC    --->
			<cfset saveClauseType(arguments.stData, 1, 0)>
			
			
			<!---    DISCOUNT    --->
			<cfloop index="discTypeIndx" list="#arguments.stData.discTypes#">
				
				<cfset saveClauseType(arguments.stData, 2, discTypeIndx)>
				
			</cfloop>		
			
			<cftransaction action="commit">
			
	
			<cfcatch>
				<cftransaction action="rollback">
				<cfrethrow>
			</cfcatch>
			
		</cftry>
		
		</cftransaction>
		
	</cffunction>
	
	
	<cffunction name="saveClauseType" output="false">
	
		<cfargument name="stData" type="struct" required="true" default="" />
		<cfargument name="clauseType" type="numeric" required="true" default="" />
		<cfargument name="discountTypeId" type="numeric" required="false" default="0" />
		
		<cfset currDiscTypeValue = Evaluate("arguments.stData.discType_#arguments.discountTypeId#")>
		
		<!------ get existing records for this clause type and discount type ----->
		<cfif arguments.discountTypeId>
			<cfset qExistingClause = getProgramClause(arguments.stData.programid, arguments.clauseType, arguments.discountTypeId)>
		<cfelse>
			<cfset qExistingClause = getProgramClause(arguments.stData.programid, arguments.clauseType)>
		</cfif>
		<cfset lExistingClauseIds = ValueList(qExistingClause.Clause_Library_ID)>
		
		
		<!---set deleted to 1 for any optional generic clauses for this program --->
		<cfquery name="qUpdateProgramClause_#arguments.discountTypeId#" datasource="#application.datasource#">
		
			UPDATE 	Clause_Program
			SET		Clause_Program.Deleted = 1
			FROM	Clause_Program
					INNER JOIN Clause_Library ON
					Clause_Library.Deleted = 0
					AND		Clause_Library.Clause_Library_ID = Clause_Program.Clause_Library_ID
					WHERE	Clause_Program.Deleted = 0
					AND		Clause_Program.Program_ID = #arguments.stData.programid#
					AND		Clause_Program.Clause_Type = #arguments.clauseType#
					<cfif arguments.discountTypeId>
					AND		Clause_Program.Discount_Type_ID = #arguments.discountTypeId#
					</cfif>
					<cfif currDiscTypeValue NEQ "">
					AND		Clause_Program.Clause_Library_Id NOT IN (#currDiscTypeValue#)
					</cfif>
					AND		NOT EXISTS 
					(
						SELECT 	Clause_Template.Clause_Category_Id
						FROM	Clause_Template
						WHERE	Clause_Template.ProgramControl_Panel_Options_ID = #arguments.stData.programTypeId#
						AND		Clause_Template.Deleted = 0
						<!--- Dev Note: Milan - 19623/25647. If "simple clauses" is OFF, then we have optional and required clauses, 
						else we do not.
						--->
						<cfif appSettings.getSimpleClause() eq 0>
						AND		Clause_Template.isRequired = 1
						</cfif>
						AND		Clause_Template.Clause_Type = Clause_Program.Clause_Type
						AND		ISNULL (Clause_Template.Discount_Type_ID,0) = ISNULL (Clause_Program.Discount_Type_ID,0)
						AND		Clause_Template.Clause_Category_ID = Clause_Library.Clause_Category_ID
					)

		</cfquery>
		
		<cfquery name="qUpdateProgramClauseOverride_#arguments.discountTypeId#" datasource="#application.datasource#">
		
			UPDATE 	Clause_Program
			SET		Clause_Program.Overridden = 1
			FROM	Clause_Program
					INNER JOIN Clause_Library ON
					Clause_Library.Deleted = 0
					AND		Clause_Library.Clause_Library_ID = Clause_Program.Clause_Library_ID
					WHERE	Clause_Program.Deleted = 0
					AND		Clause_Program.Program_ID = #arguments.stData.programid#
					AND		Clause_Program.Clause_Type = #arguments.clauseType#
					<cfif arguments.discountTypeId>
					AND		Clause_Program.Discount_Type_ID = #arguments.discountTypeId#
					</cfif>
					<cfif currDiscTypeValue NEQ "">
					AND		Clause_Program.Clause_Library_Id NOT IN (#currDiscTypeValue#)
					</cfif>
					AND		EXISTS 
					(
						SELECT 	Clause_Template.Clause_Category_ID
						FROM	Clause_Template
						WHERE	Clause_Template.ProgramControl_Panel_Options_ID = #arguments.stData.programTypeId#
						AND		Clause_Template.Deleted = 0
						<!--- Dev Note: Milan - 19623/25647. If "simple clauses" is OFF, then we have optional and required clauses, 
						else we do not.
						--->
						<cfif appSettings.getSimpleClause() eq 0>
						AND		Clause_Template.isRequired = 1
						</cfif>
						AND		Clause_Template.Clause_Type = Clause_Program.Clause_Type
						AND		ISNULL (Clause_Template.Discount_Type_ID,0) = ISNULL (Clause_Program.Discount_Type_ID,0)
						AND		Clause_Template.Clause_Category_ID = Clause_Library.Clause_Category_ID
					)

		</cfquery>
		
		<!---loop through and insert for any clauses--->
		
		<cfloop index="genIndx" list="#currDiscTypeValue#">
		
			<!------ <cfif not ListFindNoCase(arguments.stData.lExistingClauseIds, genIndx)> ----->
			<cfif not ListFindNoCase(lExistingClauseIds, genIndx)>
			
				<cfset catId = Evaluate("arguments.stData.ClauseCategoryId_#genIndx#")>
				
				<!---insert for each clause--->
				<cfset insertClause(genIndx, arguments.stData.programid, catId, arguments.clauseType, arguments.discountTypeId, arguments.stData.userId)>				

			</cfif>
			
		</cfloop>
		
	</cffunction>
	
	<cffunction name="insertClause" output="false">
	
		<cfargument name="clauseId" type="numeric" required="true" default="" />
		<cfargument name="programId" type="numeric" required="true" default="" />
		<cfargument name="categoryId" type="numeric" required="true" default="" />
		<cfargument name="clauseType" type="numeric" required="true" default="" />
		<!--- Dev Note: Milan - 19623/25647 - discountTypeId is not being used now for "simple clauses" --->
		<cfargument name="discountTypeId" type="numeric" required="true" default="0" />
		<cfargument name="userId" type="string" required="true" default="0" />
		
		<cfquery name="qInsertProgramClause_#arguments.discountTypeId#" datasource="#application.datasource#">
			INSERT INTO Clause_Program
				(Clause_Library_ID, Clause_Category_ID, Program_ID, Clause_Type, Creator_User_Id<cfif arguments.discountTypeId>, Discount_Type_ID</cfif>)
			VALUES
				(#arguments.clauseId#, #arguments.categoryId#, #arguments.programId#, #arguments.clauseType#, '#arguments.userId#'<cfif arguments.discountTypeId>, #arguments.discountTypeId#</cfif>)	
		</cfquery>
		
	</cffunction>
	
	<cffunction name="updateClause" output="false">
	
		<cfargument name="clauseId" type="numeric" required="true" default="" />
		<cfargument name="newClauseId" type="numeric" required="true" default="" />
		<cfargument name="programId" type="numeric" required="true" default="0" />
		
		<cfquery name="qUpdateProgramClause" datasource="#application.datasource#">
			UPDATE	Clause_Program
			SET		Clause_Library_ID = #arguments.newClauseId#
			WHERE
					Clause_Library_ID = #arguments.clauseId#
					AND
					Deleted = 0
					AND
					Program_ID = #arguments.programId#				
		</cfquery>
		
	</cffunction>
	
	
</cfcomponent>