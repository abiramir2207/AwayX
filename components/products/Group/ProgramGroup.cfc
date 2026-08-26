<cfcomponent>
	
	<cfset this.discountGroup = ArrayNew(1) />
	
	<cffunction name="init" output="false">
	
		<cfreturn this />
		
	</cffunction>
	
	<!--- discountGroup setter --->
	<cffunction name="setDiscountGroup" access="public" output="false">
		<cfargument name="discountGroup" required="true" default="" type="components.products.Group.GroupManager" />
		<cfset ArrayAppend(this.discountGroup, arguments.discountGroup) />
	</cffunction>
	<!--- discountGroup getter --->
	<cffunction name="getDiscountGroup" access="public" output="false">
		<cfargument name="element" required="false" default="" />
		<!---if element was passed then get for that element--->
		<cfif trim(arguments.element) neq "">
			<cfreturn this.discountGroup[arguments.element] />
		<cfelse>
			<cfreturn this.discountGroup />
		</cfif>
		
	</cffunction>
	
	<cffunction name="getProgramGroups" output="true">
	
		<cfargument name="programId" required="true" type="numeric">
		<cfargument name="discountTypes" required="no" default="2,3,4">
	
		<!---create instance of the data manager--->
		<cfset DataManager = CreateObject("component", "components.products.Group.DataManager").init() />
		
		<!---loop over discount types--->
		<cfloop index="disTypeIndx" list="#arguments.discountTypes#">
			
			<!---run query for each discount type--->
			<cfset qProgramGroups = DataManager.getGroupsForProgram(arguments.programId, disTypeIndx) />
			
			<!---get all group data, including items/products/sku's for this program--->
			<cfset GroupManager = CreateObject("component", "components.products.Group.GroupManager") />
			<cfset GroupManager.setDiscountType(disTypeIndx) />

			<!---loop over the program groups and set group ojects for each one--->
			<cfloop query="qProgramGroups">

				<cfset GroupManager.getByProductGroup(Product_Group_Level_ID, Product_Group_ID, 1) />

			</cfloop>
			
			<cfset this.setDiscountGroup(GroupManager) />

		</cfloop>
		
		<cfreturn this />
		
	</cffunction>
	
</cfcomponent>