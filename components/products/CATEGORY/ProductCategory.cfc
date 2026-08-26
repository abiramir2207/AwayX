<cfcomponent displayname="Product Category">

	
	<cffunction name="getCategories" output="false" returntype="query">
	
		<cfargument name="categoryIds" type="string" required="true" default="" />
		
		<cfset var category = "" />
		
		<cfquery name="qGetCategory" datasource="#application.datasource#">
		
			SELECT 	Category_ID, 
					Category_Name 
			FROM 	Category
			WHERE 	Deleted = 0
			
			<cfif trim(arguments.categoryIds) neq "">
			AND		Category_ID IN (#ListQualify(arguments.categoryIds,"'",",","ALL")#)
			</cfif>
			
		</cfquery>
		
		<cfset category = qGetCategory />
		
		<cfreturn category />
		
	</cffunction>
	
	<cffunction name="getCategoryFilters" output="false" returntype="string">
	
		<cfargument name="controlPanelOptionId" type="numeric" required="true" />
		 
		<cfset var categoryFilters = "" />
		
		<cfquery name="qGetCategoryFilters" datasource="#application.datasource#">
		
			SELECT 	Category_ID
			FROM 	Product_Category_Filter
			WHERE 	Deleted = 0
			AND		ProgramControl_Panel_Options_ID = #arguments.controlPanelOptionId#		
			
		</cfquery>
		
		<cfset categoryFilters = ValueList(qGetCategoryFilters.Category_ID) />
		
		<cfreturn categoryFilters />
		
	</cffunction>
	
	<cffunction name="getCategoryFiltersByProgram" output="false" returntype="string">
	
		<cfargument name="programId" type="numeric" required="true" />
		 
		<cfset var programCategoryFilterList = "" />
		<cfset var controlPanelId = 0 />
		
		<!---first get the control panel options id from contract main--->
		<cfquery name="qGetControlPanelId" datasource="#application.datasource#">
			
			SELECT 	ProgramType_ID 
			FROM 	Contract_Main
			WHERE 	Contract_Main_ID = #arguments.programId#		
			
		</cfquery>
		
		<cfset controlPanelId = qGetControlPanelId.ProgramType_ID />
		
		<cfset programCategoryFilterList = this.getCategoryFilters(controlPanelId) />
		
		<cfreturn programCategoryFilterList />
		
	</cffunction>
	
	<cffunction name="saveCategoryFilters" output="false" returntype="void">
		
		<cfargument name="controlPanelOptionsId" type="numeric" required="true" default="" />
		<cfargument name="categories" type="string" required="true" default="" />
		
		<cfset var controlPanelId = 0 />
		<cfset var lCategories = "" />
		
		<cfset controlPanelId = arguments.controlPanelOptionsId />
		<cfset lCategories = arguments.categories />
		
		<!---set deleted = 1 for any existing entries--->
		<cfquery name="insertFilters" datasource="#application.datasource#">
			
			UPDATE	Product_Category_Filter
			SET		Deleted = 1
			WHERE	Deleted = 0
			AND		ProgramControl_Panel_Options_ID = #controlPanelId#
				
		</cfquery>
			
		<!---loop over category list and insert for each one--->
		<cfloop index="indx" list="#lCategories#">
		
			<cfquery name="insertFilters" datasource="#application.datasource#">
			
				INSERT INTO Product_Category_Filter
					(ProgramControl_Panel_Options_ID, Category_ID)
				VALUES
					(#controlPanelId#, '#indx#')
				
			</cfquery>
		
		</cfloop>
		
	</cffunction>
	

</cfcomponent>