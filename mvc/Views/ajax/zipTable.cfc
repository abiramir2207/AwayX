<cfcomponent output="false">
	
	<cffunction name="getAttrs" returntype="Struct" >
		<cfscript>
			var sql   			= structnew();
			var attrs   		= structnew();
			var ui   			= structnew();
			sql.columnArray 	= ["City", "State", "County", "ZipCode"];//list of column names in DB
			sql.columnDescArray = ["City", "State (US)", "County Desc", "Zip Code"];//list of column names to display.  Same order as columnArray
	      	sql.sql_data 		= "SELECT City, State, County, ZipCode FROM ZipCodes";//query to get data.  needs same columns as ColumnArray
	      	sql.sql_count 		= "SELECT count(1) rownbr FROM ZipCodes";//replace colnames with "count(1) rownbr"
			sql.searchFieldArray = ["City", "State", "County", "ZipCode"];//list of searchable cols (db col name).  Subset of columnArray
			sql.sortArray 		= ["City", "State", "County", "ZipCode"];//list of sortable cols (db col name),  Subset of columnArray
			sql.where = "";//place holder. leave empty
			//this will display when a row is expanded.  use sData.colName to access ajax data.  js formatted (+ to concat strings)
			ui.rowDetailsHtml  = "<table cellpadding=""5"" cellspacing=""0"" border=""0"" style=""padding-left:50px;"">";
			ui.rowDetailsHtml  = ui.rowDetailsHtml &  "<tr><td>STATE:</td><td>' + sData.City + ' ' + sData.State +' '+ sData.County +' '+ sData.ZipCode +' '+'</td></tr>";
			ui.rowDetailsHtml  = ui.rowDetailsHtml &  "<tr><td>Link to source:</td><td>Could provide a link here</td></tr>";
			ui.rowDetailsHtml  = ui.rowDetailsHtml &  "<tr><td>Extra info:</td><td>And any further details here (images etc)</td></tr>";
			ui.rowDetailsHtml  = ui.rowDetailsHtml &  "</table>";
			//ui.rowDetailsHtml  = '';  //empty row turns off the expand row feature
			
			//ui.
			ui.singleSelect = 1;//1 for single 0 for multiselect
			ui.iDisplayLength = 20;
			
			attrs.sql	= sql;
			attrs.ui	= ui;
			return attrs;
		</cfscript>
		
	</cffunction>

</cfcomponent>