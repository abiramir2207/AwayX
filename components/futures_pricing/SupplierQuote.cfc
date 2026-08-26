<cfcomponent hint="Supplier Quote" extends="components.base">

	<cfset this.quoteId 		= 0 />
	<cfset this.supplierId 		= "" />
	<cfset this.supplierName	= "" />
	<cfset this.rawMaterialId 	= "" />
	<cfset this.quote		 	= "" />
	<cfset this.quoteVolume	 	= "" />
	<cfset this.quoteUOM	 	= "" />
	<cfset this.quoteDate	 	= "" />
	<cfset this.quoteGoodUntil 	= "" />
	<cfset this.isSelected	 	= "" />
	
	<!--- quoteId setter --->
	<cffunction name="setQuoteId" access="public" output="false">
		<cfargument name="quoteId" type="numeric" required="true" />
		<cfset this.quoteId = arguments.quoteId />
	</cffunction>
	<!--- quoteId getter --->
	<cffunction name="getQuoteId" access="public" output="false">
		<cfreturn this.quoteId />
	</cffunction>
	
	<!--- supplierId setter --->
	<cffunction name="setSupplierId" access="public" output="false">
		<cfargument name="supplierId" required="true" />
		<cfset this.supplierId = arguments.supplierId />
	</cffunction>
	<!--- supplierId getter --->
	<cffunction name="getSupplierId" access="public" output="false">
		<cfreturn this.supplierId />
	</cffunction>
	
	<!--- supplierName setter --->
	<cffunction name="setSupplierName" access="public" output="false">
		<cfargument name="supplierName" required="true" />
		<cfset this.supplierName = arguments.supplierName />
	</cffunction>
	<!--- supplierName getter --->
	<cffunction name="getSupplierName" access="public" output="false">
		<cfreturn this.supplierName />
	</cffunction>
	
	<!--- rawMaterialId setter --->
	<cffunction name="setRawMaterialId" access="public" output="false">
		<cfargument name="rawMaterialId" required="true" />
		<cfset this.rawMaterialId = arguments.rawMaterialId />
	</cffunction>
	<!--- rawMaterialId getter --->
	<cffunction name="getRawMaterialId" access="public" output="false">
		<cfreturn this.rawMaterialId />
	</cffunction>
	
	<!--- quote setter --->
	<cffunction name="setQuote" access="public" output="false">
		<cfargument name="quote" required="true" />
		<cfset this.quote = arguments.quote />
	</cffunction>
	<!--- quote getter --->
	<cffunction name="getQuote" access="public" output="false">
		<cfreturn this.quote />
	</cffunction>
	
	<!--- quoteVolume setter --->
	<cffunction name="setQuoteVolume" access="public" output="false">
		<cfargument name="quoteVolume" required="true" />
		<cfset this.quoteVolume = arguments.quoteVolume />
	</cffunction>
	<!--- quoteVolume getter --->
	<cffunction name="getQuoteVolume" access="public" output="false">
		<cfreturn this.quoteVolume />
	</cffunction>
	
	<!--- quoteUOM setter --->
	<cffunction name="setQuoteUOM" access="public" output="false">
		<cfargument name="quoteUOM" required="true" />
		<cfset this.quoteUOM = arguments.quoteUOM />
	</cffunction>
	<!--- quoteUOM getter --->
	<cffunction name="getQuoteUOM" access="public" output="false">
		<cfreturn this.quoteUOM />
	</cffunction>
	
	<!--- quoteDate setter --->
	<cffunction name="setQuoteDate" access="public" output="false">
		<cfargument name="quoteDate" required="true" />
		<cfset this.quoteDate = arguments.quoteDate />
	</cffunction>
	<!--- quoteDate getter --->
	<cffunction name="getQuoteDate" access="public" output="false">
		<cfreturn this.quoteDate />
	</cffunction>
	
	<!--- quoteGoodUntil setter --->
	<cffunction name="setQuoteGoodUntil" access="public" output="false">
		<cfargument name="quoteGoodUntil" required="true" />
		<cfset this.quoteGoodUntil = arguments.quoteGoodUntil />
	</cffunction>
	<!--- quoteGoodUntil getter --->
	<cffunction name="getQuoteGoodUntil" access="public" output="false">
		<cfreturn this.quoteGoodUntil />
	</cffunction>
	
	<!--- isSelected setter --->
	<cffunction name="setIsSelected" access="public" output="false">
		<cfargument name="isSelected" required="true" />
		<cfset this.isSelected = arguments.isSelected />
	</cffunction>
	<!--- isSelected getter --->
	<cffunction name="getIsSelected" access="public" output="false">
		<cfreturn this.isSelected />
	</cffunction>
	
</cfcomponent>
