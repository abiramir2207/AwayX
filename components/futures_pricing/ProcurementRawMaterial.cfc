<cfcomponent displayname="Procurement Raw Material">
	
	<cfset this.rawMaterial = ArrayNew(1) />
	<cfset this.lRecommendedSupplierIds		= "" />
	
	<!--- rawMaterial setter --->
	<cffunction name="setRawMaterial" access="public" output="false">
		<cfargument name="rawMaterial" required="true" default="" type="components.futures_pricing.RawMaterial" />
		<cfset ArrayAppend(this.rawMaterial, arguments.rawMaterial) />
	</cffunction>
	<!--- rawMaterial getter --->
	<cffunction name="getRawMaterial" access="public" output="false" returntype="array">
		<cfreturn this.rawMaterial />
	</cffunction>
	
	<!--- lRecommendedSupplierIds setter --->
	<cffunction name="setLRecommendedSupplierIds" access="public" output="false">
		<cfargument name="lRecommendedSupplierIds" type="string" required="true" />
		<cfset arguments.lRecommendedSupplierIds = REReplaceNoCase(arguments.lRecommendedSupplierIds, ",+", ",", "All") /><br>
		<cfset arguments.lRecommendedSupplierIds = REReplaceNoCase(arguments.lRecommendedSupplierIds, "^,", "", "All") />
		<cfset arguments.lRecommendedSupplierIds = REReplaceNoCase(arguments.lRecommendedSupplierIds, ",$", "", "All") />
		<cfset this.lRecommendedSupplierIds = arguments.lRecommendedSupplierIds />
	</cffunction>
	<!--- lRecommendedSupplierIds getter --->
	<cffunction name="getLRecommendedSupplierIds" access="public" returntype="string" output="false">
		<cfreturn this.lRecommendedSupplierIds />
	</cffunction>
	
</cfcomponent>