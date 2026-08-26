<cfcomponent displayname="SearchSequenceManager" hint="Search Sequence Manager" extends="components.Base">

	<cfset this.appSettings = "" />

	<cffunction name="init" returntype="components.Search_Sequence.SearchSequenceManager" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getSearchSequenceInfo" output="false" returntype="query">
		<cfargument name="searchSequenceId" type="numeric" required="false" default="0" />
		
		<!--- get the Search Sequence --->
		<cfquery name="qGetSearchSequenceInfo" datasource="#application.datasource#">			
			SELECT 	Search_Sequence.*
			FROM 	Search_Sequence			
			WHERE	Search_Sequence.Deleted = 0
			<cfif arguments.searchSequenceId NEQ 0>
			AND		Search_Sequence.Search_Sequence_ID = <cfqueryparam value="#arguments.searchSequenceId#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			ORDER BY Search_Sequence.Search_Sequence_Legacy, Search_Sequence.Search_Sequence_Desc
		</cfquery>
		
		<cfreturn qGetSearchSequenceInfo />
		
	</cffunction>

	<cffunction name="getSelectedSearchSequenceForTemplate" output="false" returntype="query">
		<cfargument name="templateId" type="numeric" required="true" />
		
		<cfset qGetSearchSequenceTemplateSettings = getSearchSequenceTemplateSettings(arguments.templateId, 1) />
		
		<cfreturn qGetSearchSequenceTemplateSettings />
		
	</cffunction>
	
	<cffunction name="enableProductSelection" output="false" returntype="boolean">
		<cfargument name="qSearchSequence" type="query" required="true" />
		
		<cfset returnValue = 0 />
		
		<!------ If item=1, enable product selection ----->
		<cfif qSearchSequence.item EQ 1>
			<cfset returnValue = 1 />
		</cfif>
		
		<cfreturn returnValue />
		
	</cffunction>
	
	<cffunction name="enableGroupSelection" output="true" returntype="boolean">
		<cfargument name="qSearchSequence" type="query" required="true" />
		
		<cfset returnValue = 0 />
		
		<!------ we have to find out if atleast 1 group used by this client is on in search sequence ----->
		<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />
		<cfset productGroupAttributeManager = createobject("component", "components.products.group.ProductGroupAttributeManager")>
		
		<!------ Get the list of available groups ----->
		<cfset qGetTopLevelGroups = GroupDataManager.getProductGroupsData() />
		<cfloop query="qGetTopLevelGroups">
			<cfset ssName = productGroupAttributeManager.getProductGroupAttributeSearchSequenceFieldName(Product_Group_Level_ID) />			
			<cfif ssName NEQ "">
				<cfset ssThisGroupVarName = "arguments.qSearchSequence.#ssName#" />
				<cfif isDefined(ssThisGroupVarName)>
					<cfset ssThisGroupOn = Evaluate(ssThisGroupVarName) /> 
					<cfif ssThisGroupOn EQ 1>
						<cfset returnValue = 1 />
						<cfbreak>
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		<cfreturn returnValue />
		
	</cffunction>
	
	
	
	
	<cffunction name="enableDistributorSelection" output="false" returntype="boolean">
		<cfargument name="qSearchSequence" type="query" required="true" />
		
		<cfset returnValue = 0 />
		
		<!------ If item=1, enable product selection ----->
		<cfif isDefined("qSearchSequence.ship_to") AND qSearchSequence.ship_to EQ 1>
			<cfset returnValue = 1 />
		</cfif>
		<cfif isDefined("qSearchSequence.customer_number") AND qSearchSequence.customer_number EQ 1>
			<cfset returnValue = 1 />
		</cfif>
		
		<cfreturn returnValue />
		
	</cffunction>
	
	<cffunction name="enableDistributorGroupSelection" output="false" returntype="boolean">
		<cfargument name="qSearchSequence" type="query" required="true" />
		
		<cfset returnValue = 0 />
		
		<!------ we have to find out if atleast 1 group used by this client is on in search sequence ----->
		<cfset GroupDataManager = CreateObject("component", "components.customer.Group.DataManager") />
		
		<!------ Get the list of available groups ----->
		<cfset qGetTopLevelGroups = GroupDataManager.getDistributorLevels(bActive=1) />
		<cfloop query="qGetTopLevelGroups">
			<cfset ssThisGroupVarName = "arguments.qSearchSequence.#Search_Sequence_Name#" />
			<cfif Search_Sequence_Name NEQ "" AND isDefined(ssThisGroupVarName)>			
				<cfset ssThisGroupOn = Evaluate(ssThisGroupVarName) /> 
				<cfif ssThisGroupOn EQ 1>
					<cfset returnValue = 1 />
					<cfbreak>					
				</cfif>
			</cfif>
		</cfloop> 
		
		<cfreturn returnValue />
		
	</cffunction>
	
	<cffunction name="enableThisDistributorGroupSelection" output="false" returntype="boolean">
		<cfargument name="qSearchSequence" type="query" required="true" />
		<cfargument name="SearchSequenceName" type="string" required="true" />
		
		<cfset returnValue = 0 />
		
		<!------ we have to find out if this group is on in search sequence ----->
		
		<cfset ssThisGroupVarName = "arguments.qSearchSequence.#arguments.SearchSequenceName#" />
		<cfif arguments.SearchSequenceName NEQ "" AND isDefined(ssThisGroupVarName)>			
			<cfset ssThisGroupOn = Evaluate(ssThisGroupVarName) /> 
			<cfif ssThisGroupOn EQ 1>
				<cfset returnValue = 1 />
			</cfif>
		</cfif>
	
		
		<cfreturn returnValue />
		
	</cffunction>

	<cffunction name="enableThisProductGroupSelection" output="false" returntype="boolean">
		<cfargument name="qSearchSequence" type="query" required="true" />
		<cfargument name="SearchSequenceName" type="string" required="true" />
		
		<cfset returnValue = 0 />
		
		<!------ we have to find out if this group is on in search sequence ----->		
		<cfset ssThisGroupVarName = "arguments.qSearchSequence.#arguments.SearchSequenceName#" />
		<cfif isDefined(ssThisGroupVarName)>			
			<cfset ssThisGroupOn = Evaluate(ssThisGroupVarName) /> 
			<cfif ssThisGroupOn EQ 1>
				<cfset returnValue = 1 />
			</cfif>
		</cfif>
	
		
		<cfreturn returnValue />
		
	</cffunction>
	
	<cffunction name="enableThisDistributorGroupSelectionByID" output="false" returntype="boolean">
		<cfargument name="qSearchSequence" type="query" required="true" />
		<cfargument name="groupLevelTypeId" type="numeric" required="true" />
		
		<!------ we have to find out if this group is on in search sequence ----->
		<cfset GroupDataManager = CreateObject("component", "components.customer.Group.DataManager") />
		<cfset qGetDistributorLevel = GroupDataManager.getDistributorLevels(allowList=arguments.groupLevelTypeId) />
			
		<cfreturn enableThisDistributorGroupSelection(arguments.qSearchSequence, qGetDistributorLevel.Search_Sequence_Name) />
		
	</cffunction>
	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Template level restriction ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getSearchSequenceTemplateSettings" output="false" returntype="query">
		<cfargument name="templateId" type="numeric" required="true" />
		<cfargument name="returnOnlyChecked" type="numeric" required="false" default="0" />
		
		<!--- get the Search Sequence --->
		<cfquery name="qGetSearchSequenceTemplateSettings" datasource="#application.datasource#">			
			SELECT 	Search_Sequence.Search_Sequence_ID,
					Search_Sequence.Search_Sequence_Legacy,
					Search_Sequence.Search_Sequence_Desc,
					Search_Sequence.Active,
					ISNULL(Search_Sequence_Template.Search_Sequence_Template_ID, 0) Template_Checked
			FROM 	Search_Sequence	
			
			<cfif arguments.returnOnlyChecked EQ 1>
			INNER JOIN Search_Sequence_Template
			<cfelse>
			LEFT JOIN Search_Sequence_Template
			</cfif>			
			ON		Search_Sequence_Template.Deleted = 0
			AND		Search_Sequence_Template.Template_ID = <cfqueryparam value="#arguments.templateId#" cfsqltype="CF_SQL_INTEGER">
			AND		Search_Sequence_Template.Search_Sequence_ID = Search_Sequence.Search_Sequence_ID
					
			WHERE	Search_Sequence.Deleted = 0
			ORDER BY Cast(Search_Sequence.Search_Sequence_Legacy As int) Asc
		</cfquery>
		
		<cfreturn qGetSearchSequenceTemplateSettings />
		
	</cffunction>
	
	<cffunction name="deleteSearchSequenceTemplateSettings" output="false" returntype="void">
		<cfargument name="templateId" type="numeric" required="true" />
		
		<!------ Delete ----->
		<cfquery name="DeleteAllPriorSearchSequenceTemplateSettings" datasource="#application.datasource#">
			UPDATE	Search_Sequence_Template
			SET		Deleted = 1
			WHERE	Deleted = 0
			AND		Search_Sequence_Template.Template_ID = <cfqueryparam value="#arguments.templateId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
	</cffunction>
	
	<cffunction name="addSearchSequenceTemplateSettings" output="false" returntype="void">
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="templateId" type="numeric" required="true" />
		
		<!------ Insert ----->
		<cfquery name="qInsertSearchSequenceTemplateSettings" datasource="#application.datasource#">
			INSERT INTO Search_Sequence_Template 
			(
				Template_ID,
				Search_Sequence_ID
			)
			VALUES
			(
				<cfqueryparam value="#arguments.templateId#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			)
		</cfquery> 
		
	</cffunction>
	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Program level function ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getSearchSequenceForProgram" output="false" returntype="numeric">
		<cfargument name="programId" type="numeric" required="true" />
		
		<!--- get the Search Sequence --->
		<cfquery name="qGetSearchSequenceForProgram" datasource="#application.datasource#">			
			SELECT 	Search_Sequence_ID 
			FROM 	Contract_Main 
			WHERE 	Contract_Main_ID= '#arguments.programId#'
		</cfquery>
		<cfset returnValue = 0 />
		<cfif Isnumeric(qGetSearchSequenceForProgram.Search_Sequence_ID)>
			<cfset returnValue = qGetSearchSequenceForProgram.Search_Sequence_ID />
		</cfif>
		<cfreturn returnValue />
		
	</cffunction>

</cfcomponent>