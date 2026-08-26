<cfcomponent hint="Futures Pricing Request" extends="components.Base">
	
	<cfset this.id 				= 0 />
	<cfset this.statusId 		= 0 />
	<cfset this.pricingStatusId = 0 />
	<cfset this.statusDesc 		= "" />
	<cfset this.pricingStatusDesc= "" />
	<cfset this.title 			= "" />
	<cfset this.startDate 		= "" />
	<cfset this.endDate			= "" />
	<cfset this.deadLineDate	= "" />
	<cfset this.goodUntilDate	= "" />	
	<cfset this.request			= "" />
	<cfset this.isExpired		= 0 />
	<cfset this.createdBy		= "" />
	<cfset this.createdDate		= "" />
	<cfset this.statusAgeDate		= "" />	
	<cfset this.updatedBy		= "" />
	<cfset this.lDistributorIds	= "" />
	<cfset this.lOperatorIds	= "" />
	<cfset this.lProductIds		= "" />
	<cfset this.lNewProductIds	= "" />
	<cfset this.lFPProductIds	= "" />
	<cfset this.qProductData	= QueryNew("Product_ID, FP_New_Product_ID, Volume, UOM") />
	<cfset this.requestProduct	= ArrayNew(1) />
	<cfset this.aVolumeDist		= ArrayNew(1) />
	<cfset this.notes			= ArrayNew(1) />
	<cfset this.reminder		= ArrayNew(1) />
	<cfset this.procurement		= "" />
	<cfset this.forward			= 0 />
	<cfset this.distVolOrder	= "" />
	<cfset this.periodType		= CreateObject("component", "components.futures_pricing.SettingsManager").get().getDefaultPeriodType() />
	<cfset this.groupUserAccess	= ArrayNew(1) />
	<cfset this.companyId		= "" />
	<cfset this.userId			= "" />
	
	<cffunction name="init" output="false" returntype="components.futures_pricing.Request">
	
		<cfset this.groupUserAccess[1] = 0 />
		<cfset this.groupUserAccess[2] = 0 />
		<cfset this.groupUserAccess[3] = 0 />
		<cfset this.groupUserAccess[4] = 0 />
		<cfset this.groupUserAccess[5] = 0 />
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
	
	<!--- statusId setter --->
	<cffunction name="setStatusId" access="public" output="false">
		<cfargument name="statusId" type="numeric" required="true" />
		<cfif this.statusId NEQ arguments.statusId>
			<cfset this.setStatusDesc(CreateObject("component", "components.futures_pricing.StatusManager").getStatusDesc(arguments.statusId)) />
		</cfif>		
		<cfset this.statusId = arguments.statusId />		
	</cffunction>
	<!--- statusId getter --->
	<cffunction name="getStatusId" access="public" returntype="numeric" output="false">
		<cfreturn this.statusId />
	</cffunction>
	
	<!--- pricingStatusId setter --->
	<cffunction name="setPricingStatusId" access="public" output="false">
		<cfargument name="pricingStatusId" type="numeric" required="true" />
		<cfset this.pricingStatusId = arguments.pricingStatusId />
	</cffunction>
	<!--- statusId getter --->
	<cffunction name="getPricingStatusId" access="public" returntype="numeric" output="false">
		<cfreturn this.pricingStatusId />
	</cffunction>	
	
	<!--- statusDesc setter --->
	<cffunction name="setStatusDesc" access="public" output="false">
		<cfargument name="statusDesc" type="string" required="true" />
		<cfset this.statusDesc = arguments.statusDesc />
	</cffunction>
	<!--- statusDesc getter --->
	<cffunction name="getStatusDesc" access="public" returntype="string" output="false">
		<cfreturn this.statusDesc />
	</cffunction>
	
	<!--- pricingStatusDesc setter --->
	<cffunction name="setPricingStatusDesc" access="public" output="false">
		<cfargument name="pricingStatusDesc" type="string" required="true" />
		<cfset this.pricingStatusDesc = arguments.pricingStatusDesc />
	</cffunction>
	<!--- pricingStatusDesc getter --->
	<cffunction name="getPricingStatusDesc" access="public" returntype="string" output="false">
		<cfreturn this.pricingStatusDesc />
	</cffunction>	
	
	<!--- title setter --->
	<cffunction name="setTitle" access="public" output="false">
		<cfargument name="title" type="string" required="true" />
		<cfset this.title = arguments.title />
	</cffunction>
	<!--- title getter --->
	<cffunction name="getTitle" access="public" returntype="string" output="false">
		<cfreturn this.title />
	</cffunction>
	
	<!--- startDate setter --->
	<cffunction name="setStartDate" access="public" output="false">
		<cfargument name="startDate" type="string" required="true" />
		<cfset this.startDate = arguments.startDate />
	</cffunction>
	<!--- startDate getter --->
	<cffunction name="getStartDate" access="public" returntype="string" output="false">
		<cfreturn this.startDate />
	</cffunction>
	
	<!--- endDate setter --->
	<cffunction name="setEndDate" access="public" output="false">
		<cfargument name="endDate" type="string" required="true" />
		<cfset this.endDate = arguments.endDate />
	</cffunction>
	<!--- endDate getter --->
	<cffunction name="getEndDate" access="public" returntype="string" output="false">
		<cfreturn this.endDate />
	</cffunction>
	
	<!--- deadLineDate setter --->
	<cffunction name="setDeadLineDate" access="public" output="false">
		<cfargument name="deadLineDate" type="string" required="true" />
		<cfset this.deadLineDate = arguments.deadLineDate />
	</cffunction>
	<!--- deadLineDate getter --->
	<cffunction name="getDeadLineDate" access="public" returntype="string" output="false">
		<cfreturn this.deadLineDate />
	</cffunction>
	
	<!--- goodUntilDate setter --->
	<cffunction name="setGoodUntilDate" access="public" output="false">
		<cfargument name="goodUntilDate" type="string" required="true" />
		<cfset this.goodUntilDate = arguments.goodUntilDate />
	</cffunction>
	<!--- goodUntilDate getter --->
	<cffunction name="getGoodUntilDate" access="public" returntype="string" output="false">
		<cfreturn this.goodUntilDate />
	</cffunction>
	
	<!--- request setter --->
	<cffunction name="setRequest" access="public" output="false">
		<cfargument name="request" type="string" required="true" />
		<cfset this.request = arguments.request />
	</cffunction>
	<!--- request getter --->
	<cffunction name="getRequest" access="public" returntype="string" output="false">
		<cfreturn this.request />
	</cffunction>
	
	<!--- isExpired setter --->
	<cffunction name="setIsExpired" access="public" output="false">
		<cfargument name="isExpired" type="numeric" required="true" />
		<cfset this.isExpired = arguments.isExpired />
	</cffunction>
	<!--- isExpired getter --->
	<cffunction name="getIsExpired" access="public" returntype="numeric" output="false">
		<cfreturn this.isExpired />
	</cffunction>	
	
	<!--- createdBy setter --->
	<cffunction name="setCreatedBy" access="public" output="false">
		<cfargument name="createdBy" type="string" required="true" />
		<cfset this.createdBy = arguments.createdBy />
	</cffunction>
	<!--- createdBy getter --->
	<cffunction name="getCreatedBy" access="public" returntype="string" output="false">
		<cfreturn this.createdBy />
	</cffunction>
	
	<!--- updatedBy setter --->
	<cffunction name="setUpdatedBy" access="public" output="false">
		<cfargument name="updatedBy" type="string" required="true" />
		<cfset this.updatedBy = arguments.updatedBy />
	</cffunction>
	<!--- updatedBy getter --->
	<cffunction name="getUpdatedBy" access="public" returntype="string" output="false">
		<cfreturn this.updatedBy />
	</cffunction>
	
	<!--- createdDate setter --->
	<cffunction name="setCreatedDate" access="public" output="false">
		<cfargument name="createdDate" type="string" required="true" />
		<cfset this.createdDate = arguments.createdDate />
	</cffunction>
	<!--- createdDate getter --->
	<cffunction name="getCreatedDate" access="public" returntype="string" output="false">
		<cfreturn this.createdDate />
	</cffunction>
	
	<!--- statusAgeDate setter --->
	<cffunction name="setStatusAgeDate" access="public" output="false">
		<cfargument name="statusAgeDate" type="string" required="true" />
		<cfset this.statusAgeDate = arguments.statusAgeDate />
	</cffunction>
	<!--- statusAgeDate getter --->
	<cffunction name="getStatusAgeDate" access="public" returntype="string" output="false">
		<cfreturn this.statusAgeDate />
	</cffunction>
	
	<!--- lDistributorIds setter --->
	<cffunction name="setLDistributorIds" access="public" output="false">
		<cfargument name="lDistributorIds" type="string" required="true" />
		<cfset this.lDistributorIds = arguments.lDistributorIds />
	</cffunction>
	<!--- lDistributorIds getter --->
	<cffunction name="getLDistributorIds" access="public" returntype="string" output="false">
		<cfreturn this.lDistributorIds />
	</cffunction>
	
	<!--- lOperatorIds setter --->
	<cffunction name="setLOperatorIds" access="public" output="false">
		<cfargument name="lOperatorIds" type="string" required="true" />
		<cfset this.lOperatorIds = arguments.lOperatorIds />
	</cffunction>
	<!--- lOperatorIds getter --->
	<cffunction name="getLOperatorIds" access="public" returntype="string" output="false">
		<cfreturn this.lOperatorIds />
	</cffunction>
	
	<!--- lProductIds setter --->
	<cffunction name="setLProductIds" access="public" output="false">
		<cfargument name="lProductIds" type="string" required="true" />
		<cfset this.lProductIds = REReplaceNoCase(arguments.lProductIds, ",+", ",", "All") />
		<cfset this.lProductIds = REReplaceNoCase(this.lProductIds, "^,", "", "All") />
		<cfset this.lProductIds = REReplaceNoCase(this.lProductIds, ",$", "", "All") />
	</cffunction>
	<!--- lProductIds getter --->
	<cffunction name="getLProductIds" access="public" returntype="string" output="false">
		<cfreturn this.lProductIds />
	</cffunction>
	
	<!--- lNewProductIds setter --->
	<cffunction name="setLNewProductIds" access="public" output="false">
		<cfargument name="lNewProductIds" type="string" required="true" />
		<cfset this.lNewProductIds = REReplaceNoCase(arguments.lNewProductIds, ",+", ",", "All") />
		<cfset this.lNewProductIds = REReplaceNoCase(this.lNewProductIds, "^,", "", "All") />
		<cfset this.lNewProductIds = REReplaceNoCase(this.lNewProductIds, ",$", "", "All") />
	</cffunction>
	<!--- lNewProductIds getter --->
	<cffunction name="getLNewProductIds" access="public" returntype="string" output="false">
		<cfreturn this.lNewProductIds />
	</cffunction>
	
	<!--- lFPProductIds setter --->
	<cffunction name="setLFPProductIds" access="public" output="false">
		<cfargument name="lFPProductIds" type="string" required="true" />
		<cfset this.lFPProductIds = arguments.lFPProductIds />
	</cffunction>
	<!--- lFPProductIds getter --->
	<cffunction name="getLFPProductIds" access="public" returntype="string" output="false">
		<cfreturn this.lFPProductIds />
	</cffunction>
	
	<!--- qProductData setter --->
	<cffunction name="setQProductData" access="public" output="false">
		<cfargument name="qProductData" type="query" required="true" default="" />
		<cfset this.qProductData = arguments.qProductData />
	</cffunction>
	<!--- qProductData getter --->
	<cffunction name="getQProductData" access="public" returntype="query" output="false">
		<cfreturn this.qProductData />
	</cffunction>
	
	<!--- forward setter --->
	<cffunction name="setForward" access="public" output="false">
		<cfargument name="forward" required="true" default="" />
		<cfset this.forward = arguments.forward />
	</cffunction>
	<!--- forward getter --->
	<cffunction name="getForward" access="public" output="false">
		<cfreturn this.forward />
	</cffunction>
	
	<!--- requestProduct setter --->
	<cffunction name="setRequestProduct" access="public" output="false">
		<cfargument name="requestProduct" required="true" default="" type="components.futures_pricing.RequestProduct" />
		<cfset ArrayAppend(this.requestProduct, arguments.requestProduct) />
	</cffunction>
	<!--- requestProduct getter --->
	<cffunction name="getRequestProduct" access="public" output="false">
		<cfreturn this.requestProduct />
	</cffunction>
	
	<!--- notes setter --->
	<cffunction name="setNotes" access="public" output="false">
		<cfargument name="notes" required="true" default="" type="components.futures_pricing.Note" />
		<cfset ArrayAppend(this.notes, arguments.notes) />
	</cffunction>
	<!--- notes getter --->
	<cffunction name="getNotes" access="public" output="false" returntype="array">
		<cfreturn this.notes />
	</cffunction>
	
	<!--- reminder setter --->
	<cffunction name="setReminder" access="public" output="false">
		<cfargument name="reminder" required="true" default="" type="components.futures_pricing.Reminder" />
		<cfset ArrayAppend(this.reminder, arguments.reminder) />
	</cffunction>
	<!--- reminder getter --->
	<cffunction name="getReminder" access="public" output="false" returntype="array">
		<cfreturn this.reminder />
	</cffunction>
	
	<!---periodType setter --->
	<cffunction name="setPeriodType">
		<cfargument name="periodType" type="string" required="true" />
		<cfset this.periodType = arguments.periodType />
	</cffunction>
	<!---periodType getter --->
	<cffunction name="getPeriodType" returntype="string" output="false">
		<cfreturn this.periodType />
	</cffunction>
	
	<!--- procurement setter --->
	<cffunction name="setProcurement" access="public" output="false">
		<cfargument name="procurement" required="true" type="components.futures_pricing.ProcurementRawMaterial" />
		<cfset this.procurement = arguments.procurement />
	</cffunction>
	<!--- procurement getter --->
	<cffunction name="getProcurement" access="public" output="false" returntype="components.futures_pricing.ProcurementRawMaterial">
		<cfreturn this.procurement />
	</cffunction>
	
	<!--- companyId setter --->
	<cffunction name="setCompanyId" access="public" output="false">
		<cfargument name="companyId" required="true" />
		<cfset this.companyId = arguments.companyId />
	</cffunction>
	<!--- companyId getter --->
	<cffunction name="getCompanyId" access="public" output="false">
		<cfreturn this.companyId />
	</cffunction>
	
	<!--- userId setter --->
	<cffunction name="setUserId" access="public" output="false">
		<cfargument name="userId" required="true" />
		<cfset this.userId = arguments.userId />
	</cffunction>
	<!--- userId getter --->
	<cffunction name="getUserId" access="public" output="false">
		<cfreturn this.userId />
	</cffunction>
	
	<!--- get volume and uom for a given product for this object --->
	<cffunction name="getVolUOM" access="public" returntype="query" output="false">
	
		<cfargument name="prodId" required="true" default="" />
		
		<cfquery name="qGetVolUOM" dbtype="query">
			SELECT 	Volume,
					UOM
			FROM	this.qProductData
			WHERE	Product_ID = '#arguments.prodId#'
		</cfquery>
		
		<cfreturn qGetVolUOM />
		
	</cffunction>
	
	<!--- groupUserAccess setter --->
	<cffunction name="setGroupUserAccess" access="public" output="false">
		<cfargument name="groupUserAccess" required="true" type="string" />
		<cfargument name="statusId" required="true" type="numeric" />
		<cfset this.groupUserAccess[arguments.statusId] = arguments.groupUserAccess />
		<cfset this.groupUserAccess[5 - ((arguments.statusId - 1) mod 5)] = arguments.groupUserAccess />		
	</cffunction>
	<!--- groupUserAccess getter --->
	<cffunction name="getGroupUserAccess" access="public" output="false" returntype="string">
		<cfargument name="statusId" required="true" type="numeric" />
		<cfreturn this.groupUserAccess[arguments.statusId] />
	</cffunction>
	
</cfcomponent>