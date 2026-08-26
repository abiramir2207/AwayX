<cfcomponent>

	<cfset this.productGroupId = "" />
	<cfset this.groupLevelId = "" />
	<cfset this.groupLevelDesc = "" />
	<cfset this.productGroupLevelType = "" />
	<cfset this.hierarchyLevel = "" />
	<cfset this.tempItemMasterId = "" />
	<cfset this.pricingLevel = "" />
	<cfset this.parentHierarchyId = "" />
	<cfset this.lHierarchyExclude = "" />
	<cfset this.uom = "" />	   <!--- Dev Note: KAL; New template settings for Group UOM selections --->
	<cfset this.groupProduct = ArrayNew(1) />
	
	<cffunction name="init" output="false">
	
		<cfreturn this />
		
	</cffunction>
	
	<!--- productGroupId setter --->
	<cffunction name="setProductGroupId" access="public" output="false">
		<cfargument name="productGroupId" required="true" default="" />
		<cfset this.productGroupId = arguments.productGroupId />
	</cffunction>
	<!--- productGroupId getter --->
	<cffunction name="getProductGroupId" access="public" output="false">
		<cfreturn this.productGroupId />
	</cffunction>
	
	<!--- groupLevelId setter --->
	<cffunction name="setGroupLevelId" access="public" output="false">
		<cfargument name="groupLevelId" required="true" default="" />
		<cfset this.groupLevelId = arguments.groupLevelId />
	</cffunction>
	<!--- groupLevelId getter --->
	<cffunction name="getGroupLevelId" access="public" output="false">
		<cfreturn this.groupLevelId />
	</cffunction>
	
	<!--- groupLevelDesc setter --->
	<cffunction name="setGroupLevelDesc" access="public" output="false">
		<cfargument name="groupLevelDesc" required="true" default="" />
		<cfset this.groupLevelDesc = arguments.groupLevelDesc />
	</cffunction>
	<!--- groupLevelDesc getter --->
	<cffunction name="getGroupLevelDesc" access="public" output="false">
		<cfreturn this.groupLevelDesc />
	</cffunction>
	
	<!--- Dev Note: KAL; New template settings for Group UOM selections --->
	<!--- uom setter --->
	<cffunction name="setUom" access="public" output="false">
		<cfargument name="uom" required="true" default="" />
		<cfset this.uom = arguments.uom />
	</cffunction>
	<!--- uom getter --->
	<cffunction name="getUom" access="public" output="false">
		<cfreturn this.uom />
	</cffunction>
	
	<!--- productGroupLevelType setter --->
	<cffunction name="setProductGroupLevelType" access="public" output="false">
		<cfargument name="productGroupLevelType" required="true" default="" />
		<cfset this.productGroupLevelType = arguments.productGroupLevelType />
	</cffunction>
	<!--- productGroupLevelType getter --->
	<cffunction name="getProductGroupLevelType" access="public" output="false">
		<cfreturn this.productGroupLevelType />
	</cffunction>
	
	<!--- hierarchyLevel setter --->
	<cffunction name="setHierarchyLevel" access="public" output="false">
		<cfargument name="hierarchyLevel" required="true" default="" />
		<cfset this.hierarchyLevel = arguments.hierarchyLevel />
	</cffunction>
	<!--- hierarchyLevel getter --->
	<cffunction name="getHierarchyLevel" access="public" output="false">
		<cfreturn this.hierarchyLevel />
	</cffunction>
	
	<!--- tempItemMasterId setter --->
	<cffunction name="setTempItemMasterId" access="public" output="false">
		<cfargument name="tempItemMasterId" required="no" default="#this.getProductGroupId()#" />
		<cfset this.tempItemMasterId = arguments.tempItemMasterId />
	</cffunction>
	<!--- tempItemMasterId getter --->
	<cffunction name="getTempItemMasterId" access="public" output="false">
		<cfreturn this.tempItemMasterId />
	</cffunction>
	
	<!--- pricingLevel setter --->
	<cffunction name="setPricingLevel" access="public" output="false">
		<cfargument name="pricingLevel" required="true" default="" />
		<cfset this.pricingLevel = arguments.pricingLevel />
	</cffunction>
	<!--- pricingLevel getter --->
	<cffunction name="getPricingLevel" access="public" output="false">
		<cfreturn this.pricingLevel />
	</cffunction>
	
	<!--- parentHierarchyId setter --->
	<cffunction name="setParentHierarchyId" access="public" output="false">
		<cfargument name="parentHierarchyId" required="true" default="" />
		<cfset this.parentHierarchyId = arguments.parentHierarchyId />
	</cffunction>
	<!--- parentHierarchyId getter --->
	<cffunction name="getParentHierarchyId" access="public" output="false">
		<cfreturn this.parentHierarchyId />
	</cffunction>
	
	<!--- lHierarchyExclude setter --->
	<cffunction name="setLHierarchyExclude" access="public" output="false">
		<cfargument name="lHierarchyExclude" required="true" default="" />
		<cfset this.lHierarchyExclude = arguments.lHierarchyExclude />
	</cffunction>
	<!--- lHierarchyExclude getter --->
	<cffunction name="getLHierarchyExclude" access="public" output="false">
		<cfreturn this.lHierarchyExclude />
	</cffunction>
	
	<!--- get temp uuid getter --->
	<cffunction name="getTempUUID" access="public" output="false">
		<cfquery name="qGetTmpUUID" datasource="#application.datasource#">
			SELECT NEWID() as UUID
		</cfquery>
		<cfreturn qGetTmpUUID.UUID />
	</cffunction>	
	
	<!--- groupProduct setter --->
	<cffunction name="setGroupProduct" access="public" output="false">
		<cfargument name="groupProduct" required="true" default="" />
		<cfset ArrayAppend(this.groupProduct, arguments.groupProduct) />
	</cffunction>
	<!--- groupProduct getter --->
	<cffunction name="getGroupProduct" access="public" output="false">
		<cfreturn this.groupProduct />
	</cffunction>
	
</cfcomponent>