<cfcomponent output="false">
	
	<cffunction name="getData" returnformat="JSON" access="remote">
		<cfscript>
			var tmp   = structnew();
			var reply = structnew();
			var sql	= structnew();
			var attrs	= structnew();
			
			tmp.page_size   = val(arguments.iDisplayLength);
			tmp.page_number = int(val(arguments.iDisplayStart) / tmp.page_size) + 1;
		
			//this.getAttrs() has an example of required struct. args.getAttrs needs to have a full dot path to a cfc with a getattrs() method
			attrs = createObject('component',arguments.getAttrs).getattrs();
			sql = attrs.sql;
			
			//insert city filter into sql statement
			if(StructKeyExists(arguments, "sSearch") and len(trim(arguments.sSearch))){
				sql.where     = " WHERE ";
				
				for (i=1;i LTE ArrayLen(sql.searchFieldArray);i=i+1) {
					//add where clauses
					if(i > 1){
						sql.where = sql.where & " OR ";
					}
					sql.where = sql.where & (sql.searchFieldArray[i]);
					sql.where = sql.where & " like '%#arguments.sSearch#%' ";
				}
	      		sql.sql_data  = sql.sql_data & sql.where;
			}
	    </cfscript> 
	  <!---  <cfdump var="#arguments#" output="c:\dump.log">    --->  
	  <!---	SSEARCH: [empty string]
		SSEARCH_0: [empty string]
		SSEARCH_1: [empty string]
		SSEARCH_2: California
		SSEARCH_3: Cass
		SSEARCH_4: [empty string]--->   
			<!---pull only the records for the requested page c:\tmp\cfdump.html --->
	    <cfmodule template = "\templates\paginate.cfm"
	              result = "tmp.qData"
	              page_number = #tmp.page_number#
	              page_size = #tmp.page_size#
	              sql_statement = #sql.sql_data#
	              debug_log_file = ""
	              sql_orderby = "#sql.searchFieldArray[arguments.iSortCol_0 + 1]# #arguments.sSortDir_0#" />
	
	    <!---get totalAfterFilter number of records BEFORE filtering--->
	    <cfquery name="totalBeforeFilter" datasource="#application.datasource#" result="totalResult">
	        #PreserveSingleQuotes(sql.sql_count)#
	    </cfquery>
	
	    <cfset reply['iTotalRecords']        = totalBeforeFilter.rownbr>
	    <cfset reply['iTotalDisplayRecords'] = totalBeforeFilter.rownbr>
	
	    <!---insert city filter into sql statements--->
	    <cfif len(sql.where)>
	      <cfset sql.sql_count = sql.sql_count & sql.where>
		    <cfquery name="totalAfterFilter" datasource="#application.datasource#" result="totalResult">
		        #PreserveSingleQuotes(sql.sql_count)#
		    </cfquery>
		    <!---get totalAfterFilter of records AFTER filtering--->
	    	<cfset reply['iTotalDisplayRecords'] = totalAfterFilter.rownbr>
	    </cfif>
	
	    <!--- Generate JSON from Query --->
	    <cfset tmp.dArray = ArrayNew(1) >
	    <cfloop query="tmp.qData">
	      <cfset dArrayTmp = arraynew(1)>
		  <cfset dStructTmp = structNew() />
	      <cfloop array="#sql.columnArray#" index="tmp.columnName">
	        <!---<cfset ArrayAppend(dArrayTmp, tmp.qData[tmp.columnName][tmp.qData.currentRow])>--->
			<cfset dStructTmp["#tmp.columnName#"] = tmp.qData[tmp.columnName][tmp.qData.currentRow]/>
	      </cfloop>
	     <!--- <cfset ArrayAppend(tmp.dArray, dArrayTmp) >--->
		 	 <cfset ArrayAppend(tmp.dArray, dStructTmp) >
	    </cfloop>
	
	    <cfset reply['aaData'] = tmp.dArray>
	    <cfset reply['sEcho']  = javacast('int', arguments.sEcho)>
	
	    <cfset tmp.sOut = SerializeJSON( reply )>

		<cfdump var="#tmp.sOut#" output="c:\dump.log">
	
	  <!---send JSON data back to client returnformat is JSON--->
	  <cfreturn tmp.sOut />
		
	</cffunction>
	
	<cffunction name="getAttrs" returntype="Struct" >
		<cfscript>
			var sql   = structnew();
			sql.columnArray = [];//list of column names in DB
			sql.columnDescArray = [];//list of column names to display.  Same order as columnArray
	      	sql.sql_data = "SELECT 'hello' FROM contract_main";//query to get data.  needs same columns as ColumnArray
	      	sql.sql_count = "SELECT count(1) rownbr FROM contract_main";
			sql.searchFieldArray = [];//list of searchable cols (db col name).  Subset of columnArray
			sql.sortArray = [];//list of sortable cols (db col name),  Subset of columnArray
			sql.where = "";
			return sql;
		</cfscript>
		
	</cffunction>

</cfcomponent>