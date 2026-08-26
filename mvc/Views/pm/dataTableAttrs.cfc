<cfcomponent hint="the vo for calling datatable.cfm" output="false" displayname="mvc.Views.pm.dataTableAttrs">
	
	<cfproperty name="arrColumns" type="array" default="0" hint="List of column names in DataBase">
	<cfproperty name="arrColumnDesc" type="array" default="">
	<cfproperty name="arrSearchField" type="array" default="0">
	<cfproperty name="arrVisible" type="array" default="">
	<cfproperty name="arrSort" type="array" default="">
	<cfproperty name="objCustomSort" type="struct" default="">
	<cfproperty name="sql_data" type="string" default="">
	<cfproperty name="sql_count" type="string" default="">
	<cfproperty name="sWhere" type="string" default="">
	<cfproperty name="sIdColumn" type="string" default="">
	<cfproperty name="rowDetailsHtml" type="string" default="">
	<cfproperty name="singleSelect" type="boolean" default="0">
	<cfproperty name="iDisplayLength" type="numeric" default="">
	<cfproperty name="sPaginationType" type="string" default="two_button" hint="full_numbers OR two_button">

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.arrColumns 	= [];	//list of column names in DB
		this.arrColumnDesc 	= [];	//list of column names to display.  Same order as arrColumns
		this.arrSearchField = [];	//list of Searchable cols (db col name).  Subset of arrColumns. Defaults to arrColumns.
		this.arrVisible 	= [];	//list of Visible cols (db col name).  Subset of arrColumns. Defaults to arrColumns.
		this.arrSort 		= [];	//list of sortable cols (db col name),  Subset of arrColumns
		this.objCustomSort = structNew(); //if any sort fields are derived (ie sum(MyDBField) as MyCount), then we need to use the deriving sql in the sort query.  key is the colname from arrSort. Value is the SQL.
      	this.sqlData 		= "";	//query to get data.  needs same columns as ColumnArray
      	this.sqlCount 		= "";	//replace colnames with "count(1) rownbr"
		this.sWhere 		= "";	//place holder. leave empty
		this.sIdColumn		= "";	//specify the name of the column in the sqlData query that returns the unique id field for each row.  Required for Row Selecting.
		//this will display when a row is expanded.  use sData.colName to access ajax data.  js formatted (+ to concat strings)
		this.sRowDetailsHtml= '';  //empty row turns off the expand row feature
		this.bSingleSelect	= 1;	//1 for single 0 for multiselect
		this.iDisplayLength = 50;	//number of rows to return from server
		this.sPaginationType = "two_button";//The other option is "full_numbers"
	</cfscript>

	<cffunction name="init" output="false" returntype="ClosingMethod">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setArrColumns" access="public" output="false" hint="list of column names in DB.  Should match what the SQL statement Returns">
    	<cfargument name="arrColumns" type="array" required="true" />
		<cfscript>
			this.arrColumns = arguments.arrColumns;
			//default other properties if they have not been set
			//Searchable
			if(ArrayLen(this.arrSearchField) == 0){
				this.setArrSearchField();
			}
			//Visible
			if(ArrayLen(this.arrVisible) == 0){
				this.setArrVisible();
			}
			//Descriptions
			if(ArrayLen(this.arrColumnDesc) == 0){
				this.setArrcolumnDesc();
			}
			//Sortable
			if(ArrayLen(this.arrColumnDesc) == 0){
				this.setArrSort();
			}
		</cfscript>
  	</cffunction>
  	
  	<cffunction name="setArrColumnDesc" access="public" output="false" hint="list of column names to display.  Same order as arrColumns">
    	<cfargument name="arrColumnDesc" type="array" required="false" default="#this.arrColumns#" />
    	<cfset this.arrColumnDesc = arguments.arrColumnDesc />
  	</cffunction>
  	
  	<cffunction name="setArrSearchField" access="public" output="false" hint="list of Searchable cols (db col name).  Subset of arrColumns.  Defaults to arrColumns if no arg is passed">
    	<cfargument name="arrSearchField" type="array" required="false" default="#this.arrColumns#" />
    	<cfset this.arrSearchField = arguments.arrSearchField />	
  	</cffunction>
  	
  	<cffunction name="setArrVisible" access="public" output="false" hint="list of Visible cols (db col name).  Subset of arrColumns.  Defaults to arrColumns if no arg is passed">
    	<cfargument name="arrVisible" type="array" required="false" default="#this.arrColumns#" />
    	<cfset this.arrVisible = arguments.arrVisible />	
  	</cffunction>
  	
  	<cffunction name="setArrSort" access="public" output="false" hint="list of Sortable cols (db col name).  Subset of arrColumns.  Defaults to arrColumns if no arg is passed">
    	<cfargument name="arrSort" type="array" required="false" default="#this.arrColumns#" />
    	<cfset this.arrSort = arguments.arrSort />
  	</cffunction>
  	
  	<cffunction name="setObjCustomSort" access="public" output="false" hint="if any sort fields are derived (ie sum(MyDBField) as MyCount), then we need to use the deriving sql in the sort query.  key is the colname from arrSort. Value is the SQL.">
    	<cfargument name="objCustomSort" type="struct" required="false" default="#structNew()#" />
    	<cfset this.objCustomSort = arguments.objCustomSort />
  	</cffunction>
  	
  	<cffunction name="setSqlData" access="public" output="false" hint="query to get data.  Needs same columns as arrColumns">
    	<cfargument name="sSqlData" type="string" required="true" />
		
    	<cfset this.sqlData = arguments.sSqlData />
  	</cffunction>
  	
  	<cffunction name="setSqlCount" access="public" output="false" hint="replace colnames in sqlData with 'count(1) rownbr'">
    	<cfargument name="sqlCount" type="string" required="true" />
    	<cfset this.sqlCount = arguments.sqlCount />
  	</cffunction>

  	<cffunction name="setsWhere" access="public" output="false" hint="INTERNAL USE ONLY.  Build the sql Where Clause based on columns and provided search string.  Then update sql query sqlData">
    	<cfargument name="sSearch" type="string" required="true" default="" hint="the search string" />
		<cfargument name="dateFilter" type="string" required="false" default="" hint="Custom Datefilter TODO:PARAMETERIZE THIS" />
		<cfscript>
			var sWhere = "";
			var sDateFilter = "";
			//writelog('HELLO','','1','dump');
			if(arguments.sSearch != ''){
				for (i=1;i LTE ArrayLen(this.arrSearchField);i=i+1) {
					//add where clauses
					if(i > 1){
						sWhere = sWhere & " OR ";
					}
					sWhere = sWhere & (this.arrSearchField[i]);
					sWhere = sWhere & " like '%#arguments.sSearch#%' ";
				}
			}
			
			
			if(arguments.dateFilter != ''){
				if(isDate(arguments.dateFilter) eq true){
					sDateFilter = ' P.Start_Date >= ' & CreateODBCDateTime(arguments.dateFilter) & ' AND ';
				}
			}
			//Update the Where and sqlData Properties
			this.sWhere = sWhere;
			this.sDateFilter = sDateFilter;
			if(FINDNOCASE('--WHERE',this.sqlData)){
				if(this.sWhere != ''){
					this.sqlData  = REPLACE(this.sqlData,'--WHERE','(#this.sWhere#)');
				}
				// DATE FILTER
				this.sqlData  = REPLACE(this.sqlData,'--DATE',' #this.sDateFilter# ');
				writelog(this.sqlData,'','1','dump');
			}
			/* else{
				this.sqlData  = this.sqlData & ' WHERE ' & this.sWhere & this.sDateFilter;
			} */
			
		</cfscript>
  	</cffunction>
  	
  	<cffunction name="setSqlCountWhere" access="public" output="false" hint="INTERNAL USE ONLY.  Build the sql Where Clause based on columns and provided search string.  Then update sql query sqlData">
    	<cfargument name="sSearch" type="string" required="true" default="" hint="the search string" />
		<cfargument name="dateFilter" type="string" required="false" default="" hint="Custom Datefilter TODO:PARAMETERIZE THIS" />
		<cfscript>
			var sWhere = "";
			var sDateFilter = "";
			if(arguments.sSearch != ''){
				for (i=1;i LTE ArrayLen(this.arrSearchField);i=i+1) {
					//add where clauses
					if(i > 1){
						sWhere = sWhere & " OR ";
					}
					sWhere = sWhere & (this.arrSearchField[i]);
					sWhere = sWhere & " like '%#arguments.sSearch#%' ";
				}
			}
			
			if(arguments.dateFilter != ''){
				if(isDate(arguments.dateFilter) eq true){
					sDateFilter = ' P.Start_Date >= ' & CreateODBCDateTime(arguments.dateFilter) & ' AND ';
				}
			}
			
			//Update the Where in SqlCount Properties
			if(FINDNOCASE('--WHERE',this.sqlCount)){
				if(this.sWhere != ''){
					this.sqlCount  = REPLACE(this.sqlCount,'--WHERE','(#this.sWhere#)');
				}
				// DATE FILTER
				this.sqlCount  = REPLACE(this.sqlCount,'--DATE',' #this.sDateFilter# ');
				writelog(this.sqlCount,'','1','dump');
			}
			/* else{
				this.sqlCount  = this.sqlCount & ' WHERE ' & this.sWhere & this.sDateFilter;
			} */
			
		</cfscript>
  	</cffunction>
  	
  	<cffunction name="setSRowDetailsHtml" access="public" output="false" hint="empty row turns off the expand row feature.  Valid HTML will display in an expandable row for each row.  Needs to be dynamc">
    	<cfargument name="sRowDetailsHtml" type="string" required="false" default="" />
    	<cfset this.sRowDetailsHtml = arguments.sRowDetailsHtml />
  	</cffunction>
  	
  	<cffunction name="setbSingleSelect" access="public" output="false" hint="Defaults to 1.  The user can click on a row and it will be selected.  Actions can be taken against selected rows">
    	<cfargument name="bSingleSelect" type="Boolean" required="false" default="1" />
    	<cfset this.bSingleSelect = arguments.bSingleSelect />
  	</cffunction>
  	
  	<cffunction name="setiDisplayLength" access="public" output="false" hint="Determines how many rows are returned from server.">
    	<cfargument name="iDisplayLength" type="numeric" required="false" default="50" />
    	<cfset this.iDisplayLength = arguments.iDisplayLength />
  	</cffunction>
  	
  	<cffunction name="setsPaginationType" access="public" output="false" hint="Two types of paging are full_numbers OR two_button">
    	<cfargument name="sPaginationType" type="string" required="false" default="two_button" />
		<cfscript>
			if(arguments.sPaginationType == 'two_button' || arguments.sPaginationType == 'full_numbers'){
				this.sPaginationType = arguments.sPaginationType;
			}
    	</cfscript>
  	</cffunction>
  	
  	<cffunction name="setsIdColumn" access="public" output="false" hint="specify the name of the column in the sqlData query that returns the unique id field for each row.  Required for Row Selecting.">
    	<cfargument name="sIdColumn" type="string" required="false" default="" />
    	<cfset this.sIdColumn = arguments.sIdColumn />
  	</cffunction>
  	
  	
	
</cfcomponent>
