<!------>
<!---
Name: 			LumpSumSampleDAO.cfc
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Description: 	I am the Data Access Object Interface to Lump Sum Sample Data. 
Date Created:	10/05/2006
--->
<cfcomponent hint="I am the Data Access Object Interface to Lump Sum Sample Data.">
	
	<cfset this.sampleCollection = arrayNew(1) />
	
	<cffunction name="init">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="get" returntype="components.programs.lump_sum_names.LumpSumSampleDAO" output="false">
		
		<cfset var sampleDatas = "" />
			
		<cfquery name="qGetSamples" datasource="#application.datasource#">
			SELECT	Sample_Type_ID,
					Sample_Type_Desc,
					Sample_Label,
					Sample_Type_Detailed_Desc
			FROM	Sample_Type
			WHERE	Deleted = 0
		</cfquery>
		
		<cfloop query="qGetSamples">
		
			<cfset sampleDatas = structNew() />
			<cfset structInsert(sampleDatas, "sampleTypeID", Sample_Type_ID) />
			<cfset structInsert(sampleDatas, "sampleTypeDesc", Sample_Type_Desc) />
			<cfset structInsert(sampleDatas, "sampleTypeLabel", Sample_Label) />
			<cfset structInsert(sampleDatas, "sampleTypeDetailedDesc", Sample_Type_Detailed_Desc) />

			<cfset arrayAppend(this.sampleCollection, sampleDatas) />
			
		</cfloop>
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="update" returntype="void" output="false">
	
		<cfargument name="data" type="components.programs.lump_sum_names.LumpSumSampleDAO" />
		
		<cfset var indx 			= "" />
		<cfset var sampleTypeId 	= "" />
		<cfset var sampleTypeLabel	= "" />
		
		<!---loop ovet the sampleCollection and update for each one--->
		<cfloop from="1" to="#arrayLen(arguments.data.sampleCollection)#" index="indx">
			
			<cfset sampleTypeId = arguments.data.sampleCollection[indx].sampleTypeId />
			<cfset sampleTypeLabel = arguments.data.sampleCollection[indx].sampleTypeLabel />
			
			<cfquery datasource="#application.datasource#">
				UPDATE	Sample_Type
				SET		Sample_Label = <cfqueryparam value="#trim(sampleTypeLabel)#" cfsqltype="CF_SQL_VARCHAR" />
				WHERE	Sample_Type_ID = <cfqueryparam value="#sampleTypeId#" cfsqltype="CF_SQL_INTEGER" />
			</cfquery>
			
		
		</cfloop>
		
	</cffunction>
	
</cfcomponent>