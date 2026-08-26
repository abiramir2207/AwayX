<cfcomponent extends="components.AjaxCFC.ajax">
	
<cffunction name="init" output="false" returntype="components.Programs.Rebates.rebateData">
	<cfreturn this />
</cffunction>

<cffunction name="getRebateData" access="public" ouput="true" returntype="query">
	<cfargument name="searchArgs" type="string" required="true" />
	<cfargument name="prodData" type="struct" required="true" />
	<cfargument name="prodGUIDList" type="string" required="false" default=""/>

	<cfset var qGetRebateData = QueryNew("ItemId,arIndex","VarChar,Integer") />
   
	<cftry>
		<cfquery name="variables.drop_tempdb" datasource="#application.datasource#">   <!--- 61108 --->
			IF OBJECT_ID('tempdb..##tmpSearchArgsList') IS NOT NULL
			DROP TABLE ##tmpSearchArgsList
		</cfquery>
		
		<cfquery name="qGetRebateData" datasource="#application.datasource#">
			CREATE TABLE ##tmpSearchArgsList (searchArg varchar(200))
			<cfif trim(arguments.searchArgs) NEQ "" and trim(arguments.searchArgs) NEQ "*">
				<cfloop list="#arguments.searchArgs#" index="searchToken" delimiters=",">
					INSERT INTO ##tmpSearchArgsList (searchArg) VALUES ('#Trim(searchToken)#')
				</cfloop>
			</cfif>
			
			 SELECT ItemId,
			 		arIndex
			 FROM ##tmpAProd p
			 <cfif len(arguments.prodGUIDList)>
			 	WHERE  itemId IN (<cfqueryparam value="#arguments.prodGUIDList#" cfsqltype="cf_sql_varchar" list="yes" />)
			 <cfelse>
 
			 <cfif trim(arguments.searchArgs) NEQ "" and trim(arguments.searchArgs) NEQ "*">
				 WHERE EXISTS (
				 	SELECT 1
				 	FROM	##tmpSearchArgsList s
				 	WHERE	p.Item LIKE '%' + s.searchArg + '%'
				 	UNION
				 	SELECT 1
				 	FROM	##tmpSearchArgsList s
				 	WHERE	p.groupNumber LIKE '%' + s.searchArg + '%'
				 	UNION
				 	SELECT 1
				 	FROM	##tmpSearchArgsList s
				 	WHERE	p.ItemDesc LIKE '%' + s.searchArg + '%'
				 )
			 <cfelseif trim(arguments.searchArgs) EQ "*">
			  	<!--- return all -> No where clause --->
			 <cfelse>
			 	WHERE 1 = 2
			 </cfif>
			 </cfif>
		</cfquery>
		<cfcatch type="any">
			<cflog file="testLog" text="#cfcatch.Message#" />
		</cfcatch>
	</cftry>

	<cfreturn qgetRebatedata />
</cffunction>
			

</cfcomponent>