<!---BidRequest.cfc--->
<cfcomponent>

	<cfset this.id = 0 />
	<cfset this.programId = 0 />
	<cfset this.openDate = "" />
	<cfset this.dateNeeded = "" />
	<cfset this.expectedReplyDate = "" />
	<cfset this.lineItem = 0 />
	<cfset this.status = 1 />
	<cfset this.sourceID = 0>
	<cfset this.sourceType = 0>
	<cfset this.statusDesc = "" />
	<cfset this.bidRequestProducts = ArrayNew(1) />
	<cfset this.discountTypeId = 0 />
	<cfset this.lBidRequestProductIds = "" />
	<cfset this.openTime = "" />
	
	<cffunction name="init" output="false" returntype="components.programs.bid_request.BidRequest">
	
		<cfreturn this />
		
	</cffunction>
	
	<!--- id setter --->
	<cffunction name="setId" access="public" output="false">
		<cfargument name="id" required="true" default="" />
		<cfset this.id = arguments.id />
	</cffunction>
	<!--- id getter --->
	<cffunction name="getId" access="public" output="false">
		<cfreturn this.id />
	</cffunction>
	
	<!--- programId setter --->
	<cffunction name="setProgramId" access="public" output="false">
		<cfargument name="programId" required="true" default="" />
		<cfset this.programId = arguments.programId />
	</cffunction>
	<!--- programId getter --->
	<cffunction name="getProgramId" access="public" output="false">
		<cfreturn this.programId />
	</cffunction>
	
	<!--- openDate setter --->
	<cffunction name="setOpenDate" access="public" output="false">
		<cfargument name="openDate" required="true" default="" />
		<cfset this.openDate = arguments.openDate />
	</cffunction>
	<!--- openDate getter --->
	<cffunction access="public" name="getOpenDate" output="false">
		<cfreturn this.openDate />
	</cffunction>
	
	<!--- dateNeeded setter --->
	<cffunction name="setDateNeeded" access="public" output="false">
		<cfargument name="dateNeeded" required="true" default="" />
		<cfset this.dateNeeded = arguments.dateNeeded />
	</cffunction>
	<!--- dateNeeded getter --->
	<cffunction access="public" name="getDateNeeded" output="false">
		<cfreturn this.dateNeeded />
	</cffunction>
	
	<!--- expectedReplyDate setter --->
	<cffunction name="setExpectedReplyDate" access="public" output="false">
		<cfargument name="expectedReplyDate" required="true" default="" />
		<cfset this.expectedReplyDate = arguments.expectedReplyDate />
	</cffunction>
	<!--- expectedReplyDate getter --->
	<cffunction access="public" name="getExpectedReplyDate" output="false">
		<cfreturn this.expectedReplyDate />
	</cffunction>
	
	<!--- lineItem setter --->
	<cffunction name="setLineItem" access="public" output="false">
		<cfargument name="lineItem" required="true" default="" />
		<cfset this.lineItem = arguments.lineItem />
	</cffunction>
	<!--- lineItem getter --->
	<cffunction name="getLineItem" access="public" output="false">
		<cfreturn this.lineItem />
	</cffunction>
	
	<!--- status setter --->
	<cffunction name="setStatus" access="public" output="false">
		<cfargument name="status" required="true" default="" />
		<cfset this.status = arguments.status />
	</cffunction>
	<!--- status getter --->
	<cffunction name="getStatus" access="public" output="false">
		<cfreturn this.status />
	</cffunction>

	<!--- sourceID setter --->
	<cffunction name="setSourceID" access="public" output="false">
		<cfargument name="SourceID" required="true" default="" />
		<cfset this.SourceID = arguments.SourceID />
	</cffunction>
	<!--- sourceID getter --->
	<cffunction name="getSourceID" access="public" output="false">
		<cfreturn this.SourceID />
	</cffunction>

	<!--- sourceType setter --->
	<cffunction name="setSourceType" access="public" output="false">
		<cfargument name="SourceType" required="true" default="" />
		<cfset this.SourceType = arguments.SourceType />
	</cffunction>
	<!--- sourceType getter --->
	<cffunction name="getSourceType" access="public" output="false">
		<cfreturn this.SourceType />
	</cffunction>
	
	<!--- statusDesc getter --->
	<cffunction name="getStatusDesc" access="public" output="false">
		<!---get the status desc based on the status id--->
		<cfset thisStatusDesc = CreateObject("component", "components.programs.bid_request.BidRequestStatus").getBidRequestStatus(this.status).Status_Desc />
		<cfset this.statusDesc = thisStatusDesc />
		<cfreturn this.statusDesc />
	</cffunction>
	
	<!---bidRequestProducts setter--->
	<cffunction name="setBidRequestProducts" output="false">
		<cfargument name="bidRequestProductsObj" required="false" default="" type="components.programs.bid_request.BidRequestProduct" />
		<cfset ArrayAppend(this.bidRequestProducts, arguments.bidRequestProductsObj) />
	</cffunction>
	<!---bidRequestProducts getter--->
	<cffunction name="getBidRequestProducts" output="false" returntype="array">
		<cfreturn this.bidRequestProducts />
	</cffunction>
	
	<!---discountTypeId setter--->
	<cffunction name="setDiscountTypeId" output="false">
		<cfargument name="discountTypeId" required="true" default="" />
		<cfset this.discountTypeId = arguments.discountTypeId />
	</cffunction>
	<!---discountTypeId getter--->
	<cffunction name="getDiscountTypeId" output="false">
		
		<!---get the Discount Type ID for Bid Request--->
		<cfset useLakebaseForqGetDiscountTypeId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("discount_type")>
<cfif useLakebaseForqGetDiscountTypeId>
	<cftry>
		<cfset qGetDiscountTypeId = application.oLakebase.toQuery(
			application.oLakebase.selectRows("discount_type", {
				"deleted" = "eq.0",
				"discount_type_desc" = "eq.Bid Request",
				"select" = "discount_type_id"
			}), "discount_type_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDiscountTypeId = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDiscountTypeId>
<cfquery name="qGetDiscountTypeId" datasource="#application.datasource#" cachedwithin="#CreateTimeSpan(0, 12, 0, 0)#">
			SELECT 	Discount_Type_ID
			FROM	Discount_Type
			WHERE	Deleted = 0
			AND		Discount_Type_Desc = 'Bid Request'
		</cfquery>
</cfif>
		<cfset this.setDiscountTypeId(qGetDiscountTypeId.Discount_Type_ID) />
		<cfreturn this.discountTypeId />
	</cffunction>
	
	<!--- lBidRequestProductIds setter --->
	<cffunction name="setLBidRequestProductIds" access="public" output="false">
		<cfargument name="lBidRequestProductIds" required="true" default="" />
		<cfset this.lBidRequestProductIds = trim(arguments.lBidRequestProductIds) />
	</cffunction>
	<!--- lBidRequestProductIds getter --->
	<cffunction name="getLBidRequestProductIds" access="public" output="false">
		<cfreturn trim(this.lBidRequestProductIds) />
	</cffunction>
	
	<!--- openTime setter --->
	<cffunction name="setOpenTime" access="public" output="false">
		<cfargument name="openTime" required="true" default="" />
		<cfif IsDate(arguments.openTime)>
			<cfset this.openTime = timeFormat(arguments.openTime, "hh:mm tt") />
		<cfelse>
			<cfset this.openTime = arguments.openTime />
		</cfif>
	</cffunction>
	<!--- openTime getter --->
	<cffunction access="public" name="getOpenTime" output="false">
		<cfreturn this.openTime />
	</cffunction>
	
</cfcomponent>