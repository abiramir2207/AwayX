<cfcomponent hint="Futures Pricing Raw Materials" extends="components.Base">

	<cfset this.id 				= 0 />
	<cfset this.number 			= "" />
	<cfset this.desc 			= "" />
	<cfset this.recommendedSupplierId 	= "" />
	<cfset this.volumeLb 		= 0 />
	<cfset this.supplierQuotes 	= ArrayNew(1) />
	
	<cffunction name="init" output="false" returntype="components.futures_pricing.RawMaterial">
	
		<cfreturn this />
		
	</cffunction>
	
	<!--- id setter --->
	<cffunction name="setId" access="public" output="false">
		<cfargument name="id" type="numeric" required="true" />
		<cfset this.id = arguments.id />
	</cffunction>
	<!--- id getter --->
	<cffunction name="getId" access="public" returntype="numeric" output="false">
		<cfreturn this.id />
	</cffunction>
	
	<!--- number setter --->
	<cffunction name="setNumber" access="public" output="false">
		<cfargument name="number" type="string" required="true" />
		<cfset this.number = arguments.number />
	</cffunction>
	<!--- number getter --->
	<cffunction name="getNumber" access="public" returntype="string" output="false">
		<cfreturn this.number />
	</cffunction>
	
	<!--- desc setter --->
	<cffunction name="setDesc" access="public" output="false">
		<cfargument name="desc" type="string" required="true" />
		<cfset this.desc = arguments.desc />
	</cffunction>
	<!--- desc getter --->
	<cffunction name="getDesc" access="public" returntype="string" output="false">
		<cfreturn this.desc />
	</cffunction>
	
	<!--- recommendedSupplierId setter --->
	<cffunction name="setRecommendedSupplierId" access="public" output="false">
		<cfargument name="recommendedSupplierId" type="string" required="true" />
		<cfset this.recommendedSupplierId = arguments.recommendedSupplierId />
	</cffunction>
	<!--- recommendedSupplierId getter --->
	<cffunction name="getRecommendedSupplierId" access="public" returntype="string" output="false">
		<cfreturn this.recommendedSupplierId />
	</cffunction>
	
	<!--- volumeLb setter --->
	<cffunction name="setVolumeLb" access="public" output="false">
		<cfargument name="volumeLb" type="string" required="true" />
		<cfset this.volumeLb = arguments.volumeLb />
	</cffunction>
	<!--- volumeLb getter --->
	<cffunction name="getVolumeLb" access="public" returntype="string" output="false">
		<cfreturn this.volumeLb />
	</cffunction>	
	
	<!--- supplierQuotes setter --->
	<cffunction name="setSupplierQuotes" access="public" output="false">
		<cfargument name="supplierQuotes" required="true" type="components.futures_pricing.SupplierQuote" />
		<cfset ArrayAppend(this.supplierQuotes, arguments.supplierQuotes) />
	</cffunction>
	<!--- supplierQuotes getter --->
	<cffunction name="getsupplierQuotes" access="public" output="false">
		<cfreturn this.supplierQuotes />
	</cffunction>
	
</cfcomponent>