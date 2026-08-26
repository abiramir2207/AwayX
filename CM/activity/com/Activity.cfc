<cfcomponent hint="Activity">

	<cfset this.id 					= 0 />
	<cfset this.name 				= "" />
	<cfset this.notes 				= "" />
	<cfset this.startDate 			= "" />
	<cfset this.endDate 			= "" />
	<cfset this.objectiveId 		= 0 />
	<cfset this.typeId 				= 0 />
	<cfset this.resultId			= 0 />
	<cfset this.ownerId 			= "" />
	<cfset this.createdUserId 		= "" />
	<cfset this.createdUserName		= "" />
	<cfset this.updatedUserId 		= "" />
	<cfset this.updatedUserName		= "" />
	<cfset this.productList		= "" />
	<cfset this.qProduct		= QueryNew("Product_ID") />
	<cfset this.distributorList 	= "" />
	<cfset this.qDistributor 		= QueryNew("Distributor_ID") />
	<cfset this.operatorList 	= "" />
	<cfset this.qOperator		= QueryNew("Operator_ID") />

	<cffunction name="init" output="false" returntype="cm.activity.com.Activity">
		
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
	
	<!--- notes setter--->
	<cffunction name="setNotes" access="public" output="false">
		<cfargument name="notes" type="string" required="true" />
		<cfset this.notes = arguments.notes />
	</cffunction>
	<!--- notes getter--->
	<cffunction name="getNotes" access="public" returntype="string" output="false">
		<cfreturn this.notes />
	</cffunction>
	
	<!--- startDate setter--->
	<cffunction name="setStartDate" access="public" output="false">
		<cfargument name="startDate" type="date" required="true" />
		<cfset this.startDate = arguments.startDate />
	</cffunction>
	<!--- startDate getter--->
	<cffunction name="getStartDate" access="public" returntype="string" output="false">
		<cfreturn this.startDate />
	</cffunction>
	
	<!--- endDate setter--->
	<cffunction name="setEndDate" access="public" output="false">
		<cfargument name="endDate" type="date" required="true" />
		<cfset this.endDate = arguments.endDate />
	</cffunction>
	<!--- endDate getter--->
	<cffunction name="getEndDate" access="public" returntype="string" output="false">
		<cfreturn this.endDate />
	</cffunction>
	
	<!--- objectiveId setter--->
	<cffunction name="setObjectiveId" access="public" output="false">
		<cfargument name="objectiveId" type="numeric" required="true" />
		<cfset this.objectiveId = arguments.objectiveId />
	</cffunction>
	<!--- objectiveId getter--->
	<cffunction name="getObjectiveId" access="public" returntype="numeric" output="false">
		<cfreturn this.objectiveId />
	</cffunction>
	
	<!--- typeId setter--->
	<cffunction name="setTypeId" access="public" output="false">
		<cfargument name="typeId" type="numeric" required="true" />
		<cfset this.typeId = arguments.typeId />
	</cffunction>
	<!--- typeId getter--->
	<cffunction name="getTypeId" access="public" returntype="numeric" output="false">
		<cfreturn this.typeId />
	</cffunction>
	
	<!--- resultId setter--->
	<cffunction name="setResultId" access="public" output="false">
		<cfargument name="resultId" type="numeric" required="true" />
		<cfset this.resultId = arguments.resultId />
	</cffunction>
	<!--- resultId getter--->
	<cffunction name="getResultId" access="public" returntype="numeric" output="false">
		<cfreturn this.resultId />
	</cffunction>
	
	<!--- ownerId setter , may not be used at all ..... --->
	<cffunction name="setOwnerId" access="public" output="false">
		<cfargument name="ownerId" type="string" required="true" />
		<cfset this.ownerId = arguments.ownerId />
	</cffunction>
	<!--- ownerId getter --->
	<cffunction name="getOwnerId" access="public" returntype="string" output="false">
		<cfreturn this.ownerId />
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
	
	<!--- productList setter --->
	<cffunction name="setProductList" access="public" output="false">
		<cfargument name="productList" type="string" required="true" />
		<cfset this.productList = arguments.productList />
	</cffunction>
	<!--- productList getter --->
	<cffunction name="getProductList" access="public" returntype="string" output="false">
		<cfreturn this.productList />
	</cffunction>
	
	<!--- qProduct setter --->
	<cffunction name="setQProduct" access="public" output="false">
		<cfargument name="qProduct" type="query" required="true" />
		<cfset this.qProduct = arguments.qProduct />
	</cffunction>
	<!--- qProduct getter --->
	<cffunction name="getQProduct" access="public" returntype="query" output="false">
		<cfreturn this.qProduct />
	</cffunction>
	
	<!--- distributorList setter --->
	<cffunction name="setDistributorList" access="public" output="false">
		<cfargument name="distributorList" type="string" required="true" />
		<cfset this.distributorList = arguments.distributorList />
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
		<cfset this.operatorList = arguments.operatorList />
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
	
</cfcomponent>
