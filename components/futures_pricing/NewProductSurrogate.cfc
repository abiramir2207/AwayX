<cfcomponent hint="Futures Pricing New Product Surrogates" extends="components.futures_pricing.RequestProductManager">

	<cfset this.id 			= 0 />
	<cfset this.prodId 		= "" />
	<cfset this.newProdId 	= "" />
	<cfset this.desc 		= "" />
	<cfset this.name 		= "" />
	<cfset this.item 		= "" />
	<cfset this.upc 		= "" />
	
	<!--- id setter --->
	<cffunction name="setId" access="public" output="false">
		<cfargument name="id" type="numeric" required="true" />
		<cfset this.id = arguments.id />
	</cffunction>
	<!--- id getter --->
	<cffunction name="getId" access="public" returntype="numeric" output="false">
		<cfreturn this.id />
	</cffunction>
	
	<!--- prodId setter --->
	<cffunction name="setProdId" access="public" output="false">
		<cfargument name="prodId" required="true" />
		<cfset this.prodId = arguments.prodId />
		<cfset qGetProd = this.getProduct(arguments.prodId) />
		
		<cfoutput query="qGetProductInfo">
			<cfset this.setName(Description) />
			<cfset this.setItem(Item) />
			<cfset this.setUpc(UPC) />
		</cfoutput>
		
	</cffunction>
	<!--- prodId getter --->
	<cffunction name="getProdId" access="public" output="false">
		<cfreturn this.prodId />
	</cffunction>
	
	<!--- newProdId setter --->
	<cffunction name="setNewProdId" access="public" output="false">
		<cfargument name="newProdId" required="true" />
		<cfset this.newProdId = arguments.newProdId />
	</cffunction>
	<!--- newProdId getter --->
	<cffunction name="getNewProdId" access="public" output="false">
		<cfreturn this.newProdId />
	</cffunction>
	
	<!--- desc setter --->
	<cffunction name="setDesc" access="public" output="false">
		<cfargument name="desc" type="string" required="true" />
		<cfset this.desc = trim(arguments.desc) />
	</cffunction>
	<!--- desc name --->
	<cffunction name="getDesc" access="public" returntype="string" output="false">
		<cfreturn this.desc />
	</cffunction>
	
	<!--- name setter --->
	<cffunction name="setname" access="public" output="false">
		<cfargument name="name" required="true" />
		<cfset this.name = trim(arguments.name) />
	</cffunction>
	<!--- name getter --->
	<cffunction name="getName" access="public" output="false">
		<cfreturn this.name />
	</cffunction>
	
	<!--- item setter --->
	<cffunction name="setItem" access="public" output="false">
		<cfargument name="item" required="true" />
		<cfset this.item = arguments.item />
	</cffunction>
	<!--- item getter --->
	<cffunction name="getItem" access="public" output="false">
		<cfreturn this.item />
	</cffunction>
	
	<!--- upc setter --->
	<cffunction name="setUpc" access="public" output="false">
		<cfargument name="upc" required="true" />
		<cfset this.upc = arguments.upc />
	</cffunction>
	<!--- upc getter --->
	<cffunction name="getUpc" access="public" output="false">
		<cfreturn this.upc />
	</cffunction>
	
</cfcomponent>