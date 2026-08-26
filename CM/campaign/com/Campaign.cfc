<cfcomponent hint="Campaign" extends="cm.com.Base">

	<cfset this.id 					= 0 />
	<cfset this.name 				= "" />
	<cfset this.desc 				= "" />
	<cfset this.startDate 			= "" />
	<cfset this.endDate 			= "" />
	<cfset this.createdUserId 		= "" />
	<cfset this.createdUserName		= "" />
	<cfset this.updatedUserId 		= "" />
	<cfset this.updatedUserName		= "" />
	
	<cfset this.distributorList 	= "" />	
	<cfset this.qDistributor 		= QueryNew("Distributor_ID") />
	
	<cfset this.operatorList 		= "" />	
	<cfset this.qOperator 			= QueryNew("Operator_ID") />
	
	<cfset this.familyList 			= "" />
	<cfset this.buyingGroupList 	= "" />
	<cfset this.operatorTypeList 	= "" />
	
	<cffunction name="init" output="false" returntype="cm.campaign.com.Campaign">
		
		<cfreturn this />
		
	</cffunction>
	
	
	<!--- id setter--->
	<cffunction name="setId" access="public" output="false">
		<cfargument name="id" type="numeric" required="true" />
		<cfset this.id = arguments.id />
	</cffunction>
	<!--- id getter--->
	<cffunction name="getId" access="public" returntype="string" output="false">
		<cfreturn this.id />
	</cffunction>
	
	<!--- name setter--->
	<cffunction name="setName" access="public" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfset this.name = arguments.name />
	</cffunction>
	<!--- name getter--->
	<cffunction name="getName" access="public" returntype="string" output="false">
		<cfreturn this.name />
	</cffunction>
	
	<!--- desc setter--->
	<cffunction name="setDesc" access="public" output="false">
		<cfargument name="desc" type="string" required="true" />
		<cfset this.desc = arguments.desc />
	</cffunction>
	<!--- desc getter--->
	<cffunction name="getDesc" access="public" returntype="string" output="false">
		<cfreturn this.desc />
	</cffunction>
	
	<!--- startDate setter--->
	<cffunction name="setStartDate" access="public" output="false">
		<cfargument name="startDate" type="string" required="true" />
		<cfif isDate(arguments.startDate)>
			<cfset this.startDate = arguments.startDate />
		</cfif>
	</cffunction>
	<!--- startDate getter--->
	<cffunction name="getStartDate" access="public" returntype="string" output="false">
		<cfreturn this.startDate />
	</cffunction>
	
	<!--- endDate setter--->
	<cffunction name="setEndDate" access="public" output="false">
		<cfargument name="endDate" type="string" required="true" />
		<cfif isDate(arguments.endDate)>
			<cfset this.endDate = arguments.endDate />
		</cfif>
	</cffunction>
	<!--- endDate getter--->
	<cffunction name="getEndDate" access="public" returntype="string" output="false">
		<cfreturn this.endDate />
	</cffunction>
	
	<!--- createdUserId setter , may not be used at all ..... --->
	<cffunction name="setCreatedUserId" access="public" output="false">
		<cfargument name="createdUserId" type="string" required="true" />
		<cfset this.createdUserId = arguments.createdUserId />
	</cffunction>
	<!--- createdUserId getter --->
	<cffunction name="getCreatedUserId" access="public" returntype="string" output="false">
		<cfreturn this.createdUserId />
	</cffunction>
	
	<!--- updatedUserId setter , may not be used at all ..... --->
	<cffunction name="setUpdatedUserId" access="public" output="false">
		<cfargument name="updatedUserId" type="string" required="true" />
		<cfset this.updatedUserId = arguments.updatedUserId />
	</cffunction>
	<!--- updatedUserId getter --->
	<cffunction name="getUpdatedUserId" access="public" returntype="string" output="false">
		<cfreturn this.updatedUserId />
	</cffunction>
	
	<!--- createdUserName setter , may not be used at all ..... --->
	<cffunction name="setCreatedUserName" access="public" output="false">
		<cfargument name="createdUserName" type="string" required="true" />
		<cfset this.createdUserName = arguments.createdUserName />
	</cffunction>
	<!--- createdUserName getter --->
	<cffunction name="getCreatedUserName" access="public" returntype="string" output="false">
		<cfreturn this.createdUserName />
	</cffunction>
	
	<!--- updatedUserName setter , may not be used at all ..... --->
	<cffunction name="setUpdatedUserName" access="public" output="false">
		<cfargument name="updatedUserName" type="string" required="true" />
		<cfset this.updatedUserName = arguments.updatedUserName />
	</cffunction>
	<!--- updatedUserName getter --->
	<cffunction name="getUpdatedUserName" access="public" returntype="string" output="false">
		<cfreturn this.updatedUserName />
	</cffunction>	
	
	<!--- distributorList setter --->
	<cffunction name="setDistributorList" access="public" output="false">
		<cfargument name="distributorList" type="string" required="true" />
		<cfset this.distributorList = replaceMultipleChars(arguments.distributorList, ",") />
	</cffunction>
	<!--- distributorList getter --->
	<cffunction name="getDistributorList" access="public" returntype="string" output="false">
		<cfreturn this.distributorList />
	</cffunction>
	
	<!--- qDistributor setter --->
	<cffunction name="setQDistributor" access="public" output="false">
		<cfargument name="qDistributor" type="query" required="true" />
		<cfset this.qDistributor = arguments.qDistributor />
	</cffunction>
	<!--- qDistributor getter --->
	<cffunction name="getQDistributor" access="public" returntype="query" output="false">
		<cfreturn this.qDistributor />
	</cffunction>
	
	 <!--- operatorList setter --->
	<cffunction name="setOperatorList" access="public" output="false">
		<cfargument name="operatorList" type="string" required="true" />
		<cfset this.operatorList = replaceMultipleChars(arguments.operatorList, ",") />
	</cffunction>
	<!--- operatorList getter --->
	<cffunction name="getOperatorList" access="public" returntype="string" output="false">
		<cfreturn this.operatorList />
	</cffunction>
	
	<!--- qOperator setter --->
	<cffunction name="setQOperator" access="public" output="false">
		<cfargument name="qOperator" type="query" required="true" />
		<cfset this.qOperator = arguments.qOperator />
	</cffunction>
	<!--- qOperator getter --->
	<cffunction name="getQOperator" access="public" returntype="query" output="false">
		<cfreturn this.qOperator />
	</cffunction>
	
	<!--- familyList setter --->
	<cffunction name="setFamilyList" access="public" output="false">
		<cfargument name="familyList" type="string" required="true" />
		<cfset this.familyList = replaceMultipleChars(arguments.familyList, ",") />
	</cffunction>
	<!--- familyList getter --->
	<cffunction name="getFamilyList" access="public" returntype="string" output="false">
		<cfreturn this.familyList />
	</cffunction>
	
	<!--- buyingGroupList setter --->
	<cffunction name="setBuyingGroupList" access="public" output="false">
		<cfargument name="buyingGroupList" type="string" required="true" />
		<cfset this.buyingGroupList = replaceMultipleChars(arguments.buyingGroupList, ",") />
	</cffunction>
	<!--- buyingGroupList getter --->
	<cffunction name="getBuyingGroupList" access="public" returntype="string" output="false">
		<cfreturn this.buyingGroupList />
	</cffunction>
	
	
	<!--- OperatorTypeList setter --->
	<cffunction name="setOperatorTypeList" access="public" output="false">
		<cfargument name="operatorTypeList" type="string" required="true" />
		<cfset this.operatorTypeList = replaceMultipleChars(arguments.operatorTypeList, ",") />
	</cffunction>
	<!--- OperatorTypeList getter --->
	<cffunction name="getOperatorTypeList" access="public" returntype="string" output="false">
		<cfreturn this.operatorTypeList />
	</cffunction>
	
</cfcomponent>
