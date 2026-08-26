<cfcomponent>

	<cfset this.requestRawMaterialId	= 0 />
	<cfset this.rawMaterialId			= 0 />
	<cfset this.rawMaterial				= "" />
	<cfset this.blend					= 0 />
	<cfset this.yieldLoss				= 0 />
	<cfset this.quote					= 0 />
	<cfset this.effectiveVolume				= 0 />	
	<cfset this.sourceVolumeDist		= ArrayNew(1) />
	<cfset this.volumeDist		= ArrayNew(1) />
	<cfset this.periodType		= 2 />
	
	<!--- requestRawMaterialId setter --->
	<cffunction name="setRequestRawMaterialId" access="public" output="false">
		<cfargument name="requestRawMaterialId" required="true" />
		<cfset this.requestRawMaterialId = arguments.requestRawMaterialId />
	</cffunction>
	<!--- requestRawMaterialId getter --->
	<cffunction name="getRequestRawMaterialId" access="public" output="false">
		<cfreturn this.requestRawMaterialId />
	</cffunction>
	
	<!--- rawMaterialId setter --->
	<cffunction name="setRawMaterialId" access="public" output="false">
	
		<cfargument name="rawMaterialId" required="true" />
		<cfset this.rawMaterialId = arguments.rawMaterialId />
		
		<cfset this.setRawMaterial(CreateObject("component", "components.futures_pricing.RawMaterialManager").get(this.rawMaterialId)) />
		
	</cffunction>
	<!--- rawMaterialId getter --->
	<cffunction name="getRawMaterialId" access="public" output="false">
		<cfreturn this.rawMaterialId />
	</cffunction>
	
	
	<!--- rawMaterial setter --->
	<cffunction name="setRawMaterial" access="public" output="false">
		<cfargument name="rawMaterial" required="true" type="components.futures_pricing.RawMaterial" />
		<cfset this.rawMaterial = arguments.rawMaterial />
	</cffunction>
	<!--- rawMaterial getter --->
	<cffunction name="getRawMaterial" access="public" output="false">
		<cfreturn this.rawMaterial />
	</cffunction>
	
	<!--- blend setter --->
	<cffunction name="setBlend" access="public" output="false">
		<cfargument name="blend" required="true" />
		<cfset this.blend = arguments.blend />
	</cffunction>
	<!--- blend getter --->
	<cffunction name="getBlend" access="public" output="false">
		<cfreturn this.blend />
	</cffunction>
	
	<!--- yieldLoss setter --->
	<cffunction name="setYieldLoss" access="public" output="false">
		<cfargument name="yieldLoss" required="true" />
		<cfset this.yieldLoss = arguments.yieldLoss />
	</cffunction>
	<!--- yieldLoss getter --->
	<cffunction name="getYieldLoss" access="public" output="false">
		<cfreturn this.yieldLoss />
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
	
	<!--- effectiveVolume setter --->
	<cffunction name="setEffectiveVolume" access="public" output="false">
		<cfargument name="productVolume" required="true" />
		<cfset this.effectiveVolume = arguments.productVolume>
		<cfif NOT isNumeric(this.effectiveVolume) OR this.effectiveVolume EQ "">
			<cfset this.effectiveVolume = 0>
		</cfif>
		<cfset this.effectiveVolume = this.effectiveVolume * this.getVolumeMultiplier() />
	</cffunction>
	<!--- effectiveVolume getter --->
	<cffunction name="getEffectiveVolume" access="public" output="false">
		<cfargument name="decimalLen" type="numeric" required="false" default="3" />
		<cfreturn request.app_general_functions.roundDecimalPlaces(this.effectiveVolume, arguments.decimalLen) />
	</cffunction>
	
	<!--- volumeMultiplier getter --->
	<cffunction name="getVolumeMultiplier" access="public" output="false">
		<cfset volMultiplier = 1 />
		<cfif isNumeric(this.getBlend())>
			<cfset volMultiplier = (volMultiplier * this.getBlend()) / 100>
		</cfif>
		<cfif isNumeric(this.getYieldLoss())>
			<cfset volMultiplier = (volMultiplier * (100 + this.getYieldLoss())) / 100>
		</cfif>
				
		<cfreturn volMultiplier />
	</cffunction>
	
	<!--- sourceVolumeDist setter --->
	<cffunction name="setSourceVolumeDist" access="public" output="false">
		<cfargument name="sourceVolumeDist" required="true" default="" type="components.futures_pricing.DistributedVolume" />
		<cfset ArrayAppend(this.sourceVolumeDist, arguments.sourceVolumeDist) />
	</cffunction>
	
	<!--- sourceVolumeDist array setter --->
	<cffunction name="setSourceVolumeDistArray" access="public" output="false">
		<cfargument name="sourceVolumeDistArray" required="true" default="" type="array" />
		<cfset this.sourceVolumeDist = arguments.sourceVolumeDistArray />
	</cffunction>
	
	<!--- sourceVolumeDist getter --->
	<cffunction name="getSourceVolumeDist" access="public" output="false">
		<cfreturn this.sourceVolumeDist />
	</cffunction>
	
	<!--- volumeDist setter --->
	<cffunction name="setVolumeDist" access="public" output="false">
		<cfargument name="volumeDist" required="true" default="" type="components.futures_pricing.DistributedVolume" />
		<cfset ArrayAppend(this.volumeDist, arguments.volumeDist) />
	</cffunction>
	
	<!--- volumeDist array setter --->
	<cffunction name="setVolumeDistArray" access="public" output="false">
		<cfargument name="volumeDistArray" required="true" default="" type="array" />
		<cfset this.volumeDist = arguments.volumeDistArray />
	</cffunction>
	
	<!--- volumeDist getter --->
	<cffunction name="getVolumeDist" access="public" output="false">
		<cfreturn this.volumeDist />
	</cffunction>
	
	<!---periodType setter --->
	<cffunction name="setPeriodType">
		<cfargument name="periodType" type="string" required="true" />
		<cfset this.periodType = arguments.periodType />
	</cffunction>
	<!---periodType getter --->
	<cffunction name="getPeriodType" returntype="string">
		<cfreturn this.periodType />
	</cffunction>
	
</cfcomponent>