<cfcomponent hint="Operator Category">
	
	<cffunction name="getCategory" output="false" returntype="query">
		
		<cfargument name="id" type="numeric" required="false" default="0" />
		
		<cfquery name="qGetCategory" datasource="#application.datasource#">
			SELECT 	Operator_Category_ID,
					Category_Label,
					isDefault,
					(SELECT TOP 1 BSA_Operator_ID
					FROM BSA_Operator
					WHERE BSA_Operator.Deleted = 0
					AND BSA_Operator.Operator_Category_ID = Operator_Category.Operator_Category_ID)
					as operatorExists
			FROM	Operator_Category
			WHERE	Deleted = 0
			<cfif arguments.id>
			AND		Operator_Category_ID = #arguments.id#		
			</cfif>
		</cfquery>
		
		<cfreturn qGetCategory />
		
	</cffunction>
	
	<cffunction name="save" output="false">
	
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="name" type="string" required="true" default="" />
		
			<!--- if we have an id then we have to update--->
			<cfif arguments.id>
				
				<!---first check to see if this category name already exists--->
				<cfquery name="qCheckExists" datasource="#application.datasource#">
					SELECT	Operator_Category_ID
					FROM	Operator_Category	
					WHERE	Category_Label = '#trim(arguments.name)#'		
					AND		Deleted = 0
				</cfquery>
				
				<!---if a record doesn't exist then we can update--->
				<cfif not qCheckExists.RecordCount>
				
					<cfquery name="qGetCategory" datasource="#application.datasource#">
						UPDATE	Operator_Category
						SET		Category_Label = '#trim(arguments.name)#'
						WHERE	Operator_Category_ID = #arguments.id#		
						AND		Deleted = 0
					</cfquery>
				
				</cfif>
				
			<cfelse>
				
				<!---first check to see if this category name already exists--->
				<cfquery name="qCheckExists" datasource="#application.datasource#">
					SELECT	Operator_Category_ID
					FROM	Operator_Category	
					WHERE	Category_Label = '#trim(arguments.name)#'		
					AND		Deleted = 0
				</cfquery>
				
				<!---if a record doesn't exist then we can update--->
				<cfif not qCheckExists.RecordCount>
				
					<cfquery name="qGetCategory" datasource="#application.datasource#">
						INSERT INTO	Operator_Category
							(Category_Label)
						VALUES
							('#trim(arguments.name)#')
					</cfquery>
				
				</cfif>
			</cfif>
		
	</cffunction>
	
	<cffunction name="deleteCategory" output="false">
	
		<cfargument name="id" type="numeric" required="false" default="0" />
				
			<cfset useLakebaseForqDeleteCategory = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("operator_category")>
<cfif useLakebaseForqDeleteCategory>
	<cftry>
		<cfset application.oLakebase.updateRows("operator_category",
			{
				"operator_category_id" = "eq.#arguments.id#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqDeleteCategory = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeleteCategory>
<cfquery name="qDeleteCategory" datasource="#application.datasource#">
				UPDATE	Operator_Category
				SET		Deleted = 1
				WHERE	Operator_Category_ID = #arguments.id#
			</cfquery>
</cfif>
		
	</cffunction>
	
	<cffunction name="assignCategory" output="false">
	
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="operatorIdList" type="string" required="true" default="" />
		
		<cfquery name="qAssignCategory" datasource="#application.datasource#">
			UPDATE	BSA_Operator
			SET		Operator_Category_ID = #arguments.id#
			WHERE
					BSA_Operator.Deleted = 0
					AND
					BSA_Operator.BSA_Operator_ID IN (#arguments.operatorIdList#)
		</cfquery>		
		
	</cffunction>

</cfcomponent>