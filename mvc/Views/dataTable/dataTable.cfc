<cfcomponent output="false">
	
	<cffunction name="getData" returnformat="JSON" access="remote">
		<cfscript>
			var tmp   = structnew();
			var reply = structnew();
			var sql	= structnew();
			var attrs = createObject('component','mvc.Views.pm.dataTableAttrs');
			
			tmp.page_size   = val(arguments.iDisplayLength);
			tmp.page_number = int(val(arguments.iDisplayStart) / tmp.page_size) + 1;
			
			attrs = createObject('component',arguments.cfcAttrsPath).getAttrs();
			
			//insert filter into sql statement
			if((StructKeyExists(arguments, "sSearch") and len(trim(arguments.sSearch)) > 0) OR (StructKeyExists(arguments, "dateFilter") and len(trim(arguments.dateFilter)) > 0)){
				//build the where clause.  sqlData property gets updated as well
				attrs.setsWhere(arguments.sSearch,arguments.dateFilter);
				
			}
			//if we have detail data there is an xtra col
			/*if(LEN(attrs.sRowDetailsHtml) GT 0 && arguments.iSortCol_0){
				arguments.iSortCol_0 = arguments.iSortCol_0 - 1;
			}*/
			
	    </cfscript> 
	<!---<cfdump var="#arguments#" output="c:\dump.log">--->
	  <!---	SSEARCH: [empty string]
		SSEARCH_0: [empty string]
		SSEARCH_1: [empty string]
		SSEARCH_2: California
		SSEARCH_3: Cass
		SSEARCH_4: [empty string]--->   
			<!---pull only the records for the requested page c:\tmp\cfdump.html --->
		<cfset sSortField = 'MDATAPROP_#arguments.iSortCol_0#'/>
		 <cfscript>
		 	orderBy = '';
			for (i=1;i LTE ArrayLen(attrs.arrColumns);i=i+1) {
				if(ListLast(attrs.arrColumns[i],'.') == arguments[sSortField]){
					orderBy = attrs.arrColumns[i];
					if(structKeyExists(attrs.objCustomSort,attrs.arrColumns[i])){
						orderBy = attrs.objCustomSort[attrs.arrColumns[i]];
					}
				}
			}
		</cfscript>
	<!---  <cfdump var="#attrs.sqlData#" output="c:\dump.log"> 
		 <cfdump var="#arguments#" output="c:\dump.log">  --->
			
			
		 <!---get totalAfterFilter number of records BEFORE filtering  FILTER DATE ONLY--->
		<cfset attrs.setSqlCountWhere('',arguments.dateFilter) />
	    <cfquery name="totalBeforeFilter" datasource="#application.datasource#" result="totalResult">
	        #PreserveSingleQuotes(attrs.sqlCount)#
	    </cfquery>
	    
	    <!---<cfdump var="#totalBeforeFilter#" output="c:\dump.log"> --->
	
	    <cfset reply['iTotalRecords']        = totalBeforeFilter.recordcount>
	    <cfset reply['iTotalDisplayRecords'] = totalBeforeFilter.recordcount>
		<cfif tmp.page_size eq -1>
			<cfset tmp.page_size = totalBeforeFilter.recordcount />
		</cfif>
		
	    <cfmodule template = "\templates\paginate.cfm"
	              result = "tmp.qData"
	              page_number = #tmp.page_number#
	              page_size = #tmp.page_size#
	              sql_statement = #attrs.sqlData#
	              debug_log_file = ""
	              sql_orderby = "#orderBy# #arguments.sSortDir_0#" /> <!--- #arguments[sSortField]#--->
	
	    <!---insert filter into sql count statements--->
	    <cfif len(attrs.sWhere)>
	      <cfset attrs.setSqlCountWhere(arguments.sSearch,arguments.dateFilter) />
		    <cfquery name="totalAfterFilter" datasource="#application.datasource#" result="totalResult">
		        #PreserveSingleQuotes(attrs.sqlCount)#
		    </cfquery>
		    <!---get totalAfterFilter of records AFTER filtering--->
	    	<cfset reply['iTotalDisplayRecords'] = totalAfterFilter.recordcount>
			<!---<cfdump var="#totalAfterFilter#" output="c:\dump.log"> --->
	    </cfif>
		
	    <!--- Generate JSON from Query --->
	    <cfset tmp.dArray = ArrayNew(1) >
		<cfloop query="tmp.qData">
			<cfset dArrayTmp = arraynew(1)>
			<cfset dStructTmp = structNew() />
			
			<!--- add id field --->
			<cfif LEN(attrs.sIdColumn) GT 0>
				<cfset dStructTmp["dataTableId"] = tmp.qData['#attrs.sIdColumn#'][tmp.qData.currentRow]/>
			<cfelse>
				<cfset dStructTmp["dataTableId"] = tmp.qData['#Paginate_Row_Number#'][tmp.qData.currentRow]/>
			</cfif>
			
			<cfloop array="#attrs.arrColumns#" index="tmp.columnName">
				<!---<cfset ArrayAppend(dArrayTmp, tmp.qData[tmp.columnName][tmp.qData.currentRow])>--->
				<cfset tmp.idx = ListLast(tmp.columnName,".") />
				<cfset sData = Replace(tmp.qData[tmp.idx][tmp.qData.currentRow],'/','','all' ) />
				
				<!--- <cfif #tmp.idx# EQ "IMG">
						<cfset dStructTmp["#tmp.idx#"] = getRow(id = #tmp.qData['BB_Auto_Report_Id'][tmp.qData.currentRow]#, cfcAttrsPath = 'mvc.Views.dataTable.autoPayTable') />
				<cfelse> --->
						<cfset dStructTmp["#tmp.idx#"] = javacast('string',sData) />
				<!--- </cfif> --->
			</cfloop>
			<!--- <cfset ArrayAppend(tmp.dArray, dArrayTmp) >--->
			<cfset ArrayAppend(tmp.dArray, dStructTmp) >
		</cfloop>
		
	    <cfset reply['aaData'] = tmp.dArray>
	    <cfset reply['sEcho']  = javacast('int', arguments.sEcho)>
	
	    <cfset tmp.sOut = SerializeJSON( reply )>
	<!---	<cfset tmp.sOut = replace(tmp.sOut," |","","ALL") />--->

<!---<cfdump var="#tmp.sOut#" output="c:\dump.log">--->
	
	  <!---send JSON data back to client returnformat is JSON--->
	  <cfreturn tmp.sOut />
		
	</cffunction>
	
	<cffunction name="getRow" returnformat="plain" access="remote">
		<cfscript>		
			var dataTable = createObject('component',arguments.cfcAttrsPath);
			return dataTable.getRow(id = arguments.id);
	    </cfscript> 
	</cffunction>
	

</cfcomponent>