<cfcomponent displayname="Approval Considerations Manager" output="false">

	<cffunction name="getText" output="false" returntype="query">

		<cfset useLakebaseForlocal_query = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("approval_considerations")>
<cfif useLakebaseForlocal_query>
	<cftry>
		<cfset local.query = application.oLakebase.toQuery(
			application.oLakebase.selectRows("approval_considerations", {
				"deleted" = "eq.0",
				"display_on_whatif_generic" = "eq.1",
				"order" = "approval_considerations_name.asc",
				"select" = "approval_considerations_text"
			}), "approval_considerations_text"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_query = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_query>
<cfquery name="local.query" datasource="#application.datasource#">
			SELECT Approval_Considerations_Text
			  FROM Approval_Considerations
			 WHERE Deleted = 0 AND Display_On_WhatIF_Generic = 1
			 ORDER BY Approval_Considerations_Name
		</cfquery>
</cfif>

		<cfreturn local.query>
	</cffunction>

	<!-------------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getProgramText" output="true" returntype="string">
		<cfargument name="program_id" required="true" type="numeric">

		<cfquery name="local.query" datasource="#application.datasource#">
			SELECT c.Approval_Considerations_Text
			  FROM Contract_Main a
			       INNER JOIN Program_Control_Panel_Options b ON b.ProgramControl_Panel_Options_Id = a.ProgramType_Id
			       LEFT JOIN dbo.Approval_Considerations c ON c.Approval_Considerations_Id = b.Approval_Considerations_Id
			 WHERE a.contract_main_id = #arguments.program_id#
		</cfquery>

		<cfreturn local.query.Approval_Considerations_Text>
	</cffunction>

	<!-------------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getApprovalConsiderations" hint="return all the Approval Considerations records that macthes the criteria" access="public" output="false" returntype="query">

		<cfargument name="approvalConsiderationsID" type="numeric" required="false" default="0" />
		<cfargument name="IncludeDeleted" type="boolean" required="false" default="0" />

 		<cfset var qGetApprovalConsiderations = "" />

		<cfquery name="qGetApprovalConsiderations" datasource="#application.datasource#">
			SELECT	Approval_Considerations.Approval_Considerations_ID,
					Approval_Considerations.Approval_Considerations_Name,
					Approval_Considerations.Approval_Considerations_Text,
					Approval_Considerations.Created_By,
					Approval_Considerations.Created_Date,
					Approval_Considerations.Deleted,
					Approval_Considerations.Updated_By,
					Approval_Considerations.Updated_Date,
					Approval_Considerations.Display_On_WhatIF_Generic
			FROM	Approval_Considerations
			WHERE	1 = 1
			<cfif arguments.IncludeDeleted eq 0>
			AND		Approval_Considerations.Deleted = 0
			</cfif>
			<cfif arguments.approvalConsiderationsID neq 0>
			AND		Approval_Considerations.Approval_Considerations_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.approvalConsiderationsID#" />
			</cfif>
			ORDER BY Approval_Considerations.Approval_Considerations_Name
		</cfquery>

		<cfreturn qGetApprovalConsiderations />

	</cffunction>

	<!-------------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="addEditApprovalConsiderations" hint="insert/update Approval Consideration record" access="public" output="true" returntype="void">
		<cfargument name="approvalConsiderationsID" type="numeric" required="true" />
		<cfargument name="approvalConsiderationsName" type="string" required="true" />
		<cfargument name="approvalConsiderationsText" type="string" required="true" />
		<cfargument name="deleted" type="boolean" required="true" />
		<cfargument name="userID" type="string" required="true" />
		<cfargument name="Display_On_WhatIF_Generic" type="boolean" required="true" />
		<cfargument name="template_select" type="string" required="true" />

		<cfscript>
			local = {};
			var qInsertData = "";
			var qUpdateData = "";
		</cfscript>


		<cftransaction>
		<cfif arguments.approvalConsiderationsID EQ 0>

			<!--- Insert the record --->
			<cfquery name="qInsertData" datasource="#application.datasource#">
				INSERT INTO Approval_Considerations
					(
					Approval_Considerations_Name,
					Approval_Considerations_Text,
					Created_By,
					Display_On_WhatIF_Generic
					)
				VALUES
					(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.approvalConsiderationsName#" />,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.approvalConsiderationsText#" />,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#" />,
					<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.Display_On_WhatIF_Generic#" />
					)

				SELECT Scope_Identity() AS Approval_Considerations_ID
			</cfquery>
			<cfset local.Approval_Considerations_ID = qInsertData.Approval_Considerations_ID>

		<cfelse>

			<cfset local.Approval_Considerations_ID = arguments.approvalConsiderationsID>
			<!--- Update the record --->
			<cfquery name="qUpdateData" datasource="#application.datasource#">
				UPDATE 		Approval_Considerations
				SET 		Approval_Considerations_Name  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.approvalConsiderationsName#">,
							Approval_Considerations_Text  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.approvalConsiderationsText#">,
							Updated_Date				  = GetDate(),
							Updated_By					  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#">,
							Deleted						  = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.deleted#">,
							Display_On_WhatIF_Generic     = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.Display_On_WhatIF_Generic#">
				WHERE		Approval_Considerations_ID	  = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.Approval_Considerations_ID#">
			</cfquery>

		</cfif>

		<!--- update templates selection --->
		<cfquery name="qUpdate" datasource="#application.datasource#">
			<!--- clear previously assigned templates that are no longer selected --->
			UPDATE Program_Control_Panel_Options
			   SET Approval_Considerations_ID = NULL
			 WHERE Approval_Considerations_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.Approval_Considerations_ID#">
			   AND ProgramControl_Panel_Options_ID NOT IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.template_select#" list="true">)

			<!--- assign templates --->
			UPDATE Program_Control_Panel_Options
			   SET Approval_Considerations_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.Approval_Considerations_ID#">
			 WHERE ProgramControl_Panel_Options_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.template_select#" list="true">)
		</cfquery>

		<cfset local.templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
		<!--- retroactively assign to other versions as well --->
		<cfloop list="#arguments.template_select#" index="local.item">
			<cfset local.thisTemplateDiffVersionIdList = local.templateManager.getThisTemplateAllParentsID( local.item ) />

			<cfquery name="qUpdate" datasource="#application.datasource#">
				UPDATE Program_Control_Panel_Options
				   SET Approval_Considerations_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.Approval_Considerations_ID#">
				 WHERE ProgramControl_Panel_Options_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.thisTemplateDiffVersionIdList#" list="true">)
			</cfquery>
		</cfloop>
		</cftransaction>

	</cffunction>

</cfcomponent>