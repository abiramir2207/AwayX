<cfcomponent hint="Clause Template Manager" extends="components.Base">
<!--- 
The app setting (simple clauses) is ON for clients using our new clauses functionality. The code for app setting (simple clauses) ON and OFF is very different. 
On any environment,we cannot turn ON or OFF this switch. If is not possible for any client to move from simple (simple clauses app setting ON) to non-simple
(simple clauses app setting OFF).To move from non-simple to simple clauses, please refer to label 25647 first.

For any change to this file, first check whether the client requesting the modification has the "simple clauses" app switch ON or OFF. The clients with this
app setting OFF use files with the "original" prefix for some of the clause library files and so a change in one file with or without the "original" prefix 
might require a corresponding change in the other file, if the functionality affected is the same for both. Also, any change in this file might require a app switch
condition. Please refer to label 25647.
--->
<cfset variables.appsettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

	<cffunction name="init" output="false">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="importRequiredClause" output="false">
	
		<cfargument name="templateId" required="true" type="numeric" />
		<cfargument name="userId" required="true" type="string" />
		
		<cfquery name="qImportClause" datasource="#application.datasource#">
			INSERT INTO	Clause_Template 
					(Clause_Category_ID, Default_Clause_Library_ID, ProgramControl_Panel_Options_ID, isRequired, Clause_Type, Creator_User_ID)
			SELECT	 Clause_Category.Clause_Category_ID, Clause_Category.Default_Clause_Library_ID, #arguments.templateId#, 
			<!--- Dev Note: Milan - 19623/25647. If "simple clauses" is OFF, then we have optional and required clauses, 
			else we do not. If it is ON, we hardcode the value of "isRequired" to 1.
			--->
			<cfif appSettings.getSimpleClause() eq 1>
			1, 
			<cfelse>
			Required_For_All,
			</cfif>
			1, '#arguments.userId#'
			FROM	Clause_Category
			WHERE
					Clause_Category.Deleted = 0
					<!--- Dev Note: Milan - 19623/25647. If "simple clauses" is OFF, then we have optional and required clauses, 
					else we do not. If it is OFF, then we look at "required" clauses ("Required_To_All" is hardcoded to 1).
					--->
					<cfif appSettings.getSimpleClause() eq 0>
					AND
					Clause_Category.Required_For_All = 1
					</cfif>
					AND
					NOT EXISTS
					(
					SELECT	Clause_Category_ID
					FROM	Clause_Template
					WHERE
							Clause_Template.Deleted = 0
							AND
							Clause_Template.Clause_Category_ID = Clause_Category.Clause_Category_ID
							AND
							Clause_Template.Clause_Type = 1
							AND
							Clause_Template.ProgramControl_Panel_Options_ID = #arguments.templateId#
					)					
		</cfquery>
				
	</cffunction>
	
	<cffunction name="importClauseFromTemplate" output="false">
	
		<cfargument name="templateId" required="true" type="numeric" />
		<cfargument name="parentTemplateId" required="true" type="numeric" />
		
		<cfquery name="qImportClause" datasource="#application.datasource#">
			INSERT INTO	Clause_Template 
					(Clause_Category_ID, Default_Clause_Library_ID, ProgramControl_Panel_Options_ID, isRequired, Clause_Type, Discount_Type_ID, Creator_User_ID, Created_Date)
			SELECT	 Clause_Category_ID, Default_Clause_Library_ID, #arguments.templateId#,
			<!--- Dev Note: Milan - 19623/25647. If "simple clauses" is OFF, then we have optional and required clauses, 
			else we do not. If it is ON, we hardcode the value of "isRequired" to 1.
			--->
			<cfif appSettings.getSimpleClause() eq 1>
			1, 
			<cfelse>
			isRequired,
			</cfif>
			Clause_Type, Discount_Type_ID, Creator_User_ID, Created_Date
			FROM	Clause_Template
			WHERE
					Clause_Template.Deleted = 0
					AND
					Clause_Template.ProgramControl_Panel_Options_ID = #arguments.parentTemplateId#					
		</cfquery>		
				
	</cffunction>
	
	
	<cffunction name="getTemplateClause" output="false" returntype="query">
	
		<cfargument name="templateId" required="true" type="numeric" />
		
		<cfquery name="qTemplateClause" datasource="#application.datasource#">
			SELECT	Clause_Category.Clause_Category_ID, Clause_Category.Clause_Category_Name,
					Clause_Template.Default_Clause_Library_ID AS Clause_Library_ID,
					Clause_Template.Clause_Type, Clause_Template.Discount_Type_ID,
					Clause_Template.isRequired
			FROM	Clause_Template
					INNER JOIN Clause_Category
					ON
					Clause_Category.Clause_Category_ID = Clause_Template.Clause_Category_ID
					AND
					Clause_Category.Deleted = 0
			WHERE
					Clause_Template.Deleted = 0
					AND
					Clause_Template.ProgramControl_Panel_Options_ID = #arguments.templateId#					
			ORDER BY Clause_Template.Clause_Type, Clause_Template.Discount_Type_ID
		</cfquery>
		
		<cfreturn qTemplateClause />
	
	</cffunction>
	
		<cffunction name="getClauseAllProgramsSettings" output="false" returntype="query">
	
		<cfargument name="templateId" required="true" type="numeric" />
		
		<cfset useLakebaseForqgetClauseAllProgramsSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForqgetClauseAllProgramsSettings>
	<cftry>
		<cfset qgetClauseAllProgramsSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#arguments.templateId#",
				"select" = "apply_clause_all_programs"
			}), "apply_clause_all_programs"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetClauseAllProgramsSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetClauseAllProgramsSettings>
<cfquery name="qgetClauseAllProgramsSettings" datasource="#application.datasource#">
			SELECT Apply_Clause_All_Programs	
			FROM Program_Control_Panel_Options
			WHERE ProgramControl_Panel_Options_ID = #arguments.templateId#					
		</cfquery>
</cfif>
		
		<cfreturn qgetClauseAllProgramsSettings />
	
	</cffunction>
	
	<cffunction name="getTemplateAvailClause" output="false" returntype="query">
	
		<cfargument name="templateId" required="true" type="numeric" />
		<cfargument name="clauseIdList" required="false" type="string" default="" />
		
		<cfquery name="qTemplateClause" datasource="#application.datasource#">
			SELECT	Clause_Template.Clause_Category_ID,
					CL.Clause_Library_ID,
					Clause_Category.Require_Approval,
					Clause_Template.Clause_Type, Clause_Template.Discount_Type_ID,
					Clause_Template.isRequired
			FROM	Clause_Template
					INNER JOIN Clause_Library
					ON
					Clause_Library.Clause_Library_ID = 		Clause_Template.Default_Clause_Library_ID
					AND
					Clause_Library.Deleted = 0
					INNER JOIN Clause_Library CL
					ON
					CL.Clause_Category_ID = 		Clause_Library.Clause_Category_ID
					AND
					CL.Deleted = 0
					<cfif arguments.clauseIdList NEQ "">
					AND
					CL.Clause_Library_ID IN (#arguments.clauseIdList#)
					</cfif>
					INNER JOIN Clause_Category
					ON
					Clause_Library.Clause_Category_ID = 		Clause_Category.Clause_Category_ID
					AND
					Clause_Category.Deleted = 0
			WHERE
					Clause_Template.Deleted = 0
					AND
					Clause_Template.ProgramControl_Panel_Options_ID = #arguments.templateId#										
			ORDER BY Clause_Template.Clause_Type, Clause_Template.Discount_Type_ID
		</cfquery>
		
		<cfreturn qTemplateClause />
	
	</cffunction>
	
	
	<cffunction name="save" output="false">
	
		<cfargument name="templateId" required="true" type="numeric" />
		<cfargument name="formScope" required="true" type="struct" />
		
		<cfparam name="arguments.formScope.Apply_Existing" default="0" />
		
		<cftransaction action="BEGIN">
			<cftry>
				
				<!------ <cfset this.clauseCatList = CreateObject("component", "components.clause_library.ClauseLibraryManager").getList(arguments.formScope.Clause_List) /> ----->
				
				
				<!------ delete all clause from this template ----->
				<cfquery name="qDeleteClause" datasource="#application.datasource#">
					UPDATE	Clause_Template
					SET		Deleted = 1
					WHERE	Clause_Template.Deleted = 0
					AND		Clause_Template.ProgramControl_Panel_Options_ID = #arguments.templateId#
				</cfquery>
				
				<cfinclude template="/Clause_Library/Clause_Functions.cfm">
				
				<cfset saveClauseType(arguments.templateId, arguments.formScope, 1)>
				<cfloop list="#arguments.formScope.discountTypeIds#" index="ThisDiscountTypeId">
					<cfset saveClauseType(arguments.templateId, arguments.formScope, 2, ThisDiscountTypeId)>
				</cfloop>
				
				<cfquery name="qupdateClause" datasource="#application.datasource#">
					UPDATE	Program_Control_Panel_Options
					SET		Apply_Clause_All_Programs = #arguments.formScope.Apply_Existing#
					WHERE ProgramControl_Panel_Options_ID = #arguments.templateId#
				</cfquery>
				
				<!---if apply to existing was seleted then call the SP_ADJUST_PROGRAM_TEMPLATE_CLAUSE stored procedure--->
				<cfif arguments.formScope.Apply_Existing>
					<!--- Dev Note: Milan - 19623/25647. If "simple clauses" is OFF, then we have optional and required clauses, 
					else we do not.
					--->
					<cfif appSettings.getSimpleClause() eq 0>
					  <!---if Apply_Existing is 2 then we know they selected to adjust all programs--->
					  <cfif arguments.formScope.Apply_Existing eq 2>
						<cfset applyAll = 1 />
					  <cfelse>
						<cfset applyAll = 0 />
					  </cfif>
					</cfif>
					<!--- Dev Note: Milan - 19623/25647. If "simple clauses" is OFF, then we have an option of applying any change 
					to the template to all programs or not, else the value of "@@ALL_PROGRAMS" is hardcoded to 0. @@ALL_PROGRAMS is not
					used in the stored procedure when appSettings.getSimpleClause() eq 1.
					--->
					<cfif appSettings.getSimpleClause() eq 1>

					 <cfstoredproc procedure="SP_ADJUST_PROGRAM_TEMPLATE_CLAUSE" datasource="#application.datasource#">
			   
						<!--- cfprocparam tags --->
						<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@@CONTROL_PANEL_OPTIONS_ID" value="#arguments.templateId#" null="no">
						<!---DEFALULT 0--->
						<cfprocparam type = "In" CFSQLType ="CF_SQL_BIT" dbVarName = "@@ALL_PROGRAMS" null="no" value="0">
					 </cfstoredproc>

					<cfelse>

					 <cfstoredproc procedure="SP_ADJUST_PROGRAM_TEMPLATE_CLAUSE" datasource="#application.datasource#">
			   
						<!--- cfprocparam tags --->
						<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@@CONTROL_PANEL_OPTIONS_ID" value="#arguments.templateId#" null="no">
						<cfprocparam type = "In" CFSQLType ="CF_SQL_BIT" dbVarName = "@@ALL_PROGRAMS" null="no" value="#applyAll#">

					 </cfstoredproc>
					</cfif>
					
				</cfif>
				
				<cftransaction action="COMMIT">
				
				<cfcatch>
					<cftransaction action="ROLLBACK">
					<cfrethrow>
				</cfcatch>
			</cftry>
		</cftransaction>
		
	</cffunction>
	
	<cffunction name="saveClauseType" output="false">
	
		<cfargument name="templateId" required="true" type="numeric" />
		<cfargument name="formScope" required="true" type="struct" />
		<cfargument name="clauseType" required="true" type="numeric" />
		<!--- Dev Note: Milan - 19623/25647 - discountTypeId is not being used now for "simple clauses" --->
		<cfargument name="discountTypeId" required="false" type="string" default="" />
		
		<cfset objClauseProgramManager = CreateObject("component","components.clause_library.ClauseProgramManager") />
		<!--- Dev Note: Milan - 19623/25647. If "simple clauses" is OFF, then we have optional and required clauses (0,1), 
		else we do not and I am using this code for backward compatibilty (for old clauses - "simple" clauses OFF)
		--->
		<cfif appSettings.getSimpleClause() eq 1>
		 <cfset requiredList = "0">
		<cfelse>
		 <cfset requiredList = "1,0">
		</cfif>

		<cfloop list="#requiredList#" delimiters="," index="currRequired">		
			<cfset fieldName = buildFieldName("Clause", "#currRequired#", arguments.clauseType, arguments.discountTypeId)>
			<cfset FormFieldValue = Evaluate("arguments.formScope.#fieldName#")>			
			<cfloop list="#FormFieldValue#" delimiters="," index="thisClauseId">
				<cfset categoryId = Evaluate("arguments.formScope.ClauseTemplateId_#thisClauseId#")>
				
				<!------ insert for this criteria ----->
				<cfquery name="qInsertClause" datasource="#application.datasource#">
					INSERT INTO	Clause_Template
						(Clause_Category_ID, Default_Clause_Library_ID, ProgramControl_Panel_Options_ID, isRequired,
						 Clause_Type<cfif arguments.discountTypeId NEQ "">, Discount_Type_ID</cfif>)
					VALUES
						(#categoryId#, #thisClauseId#, #arguments.templateId#, #currRequired#, #arguments.clauseType#<cfif arguments.discountTypeId NEQ "">, #arguments.discountTypeId#</cfif>)
				</cfquery>
			</cfloop>
		</cfloop>

	 </cffunction>
	
</cfcomponent>