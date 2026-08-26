<cfcomponent output="false" displayname="mvc.Views.dataTable.zipTable.cfc">
	
	<cffunction name="getAttrs" returntype="mvc.Views.pm.dataTableAttrs" >
		<cfscript>
			var sRowDetailsHtml = '';
			var attrs   		= structnew();
			
			attrs = createObject('component','mvc.Views.pm.dataTableAttrs');
			attrs.setarrColumns(["City", "State", "County", "ZipCode"]);
			attrs.setArrcolumnDesc(["City", "State (US)", "County Desc", "Zip Code"]);//list of column names to display.  Same order as arrColumns
	      	attrs.setSqlData("SELECT City, State, County, ZipCode FROM ZipCodes");//query to get data.  needs same columns as arrColumns
	      	attrs.setSqlCount("SELECT count(1) rownbr FROM ZipCodes");//replace colnames with "count(1) rownbr"
			//attrs.arrSearchField = attrs.arrColumns;//DEFAULTS TO setarrColumns
			
			//this will display when a row is expanded.  use sData.colName to access ajax data.  js formatted (+ to concat strings)
			sRowDetailsHtml  = "<table cellpadding=""5"" cellspacing=""0"" border=""0"" style=""padding-left:50px;"">";
			sRowDetailsHtml  = sRowDetailsHtml &  "<tr><td>STATE:</td><td>' + sData.City + ' ' + sData.State +' '+ sData.County +' '+ sData.ZipCode +' '+'</td></tr>";
			sRowDetailsHtml  = sRowDetailsHtml &  "<tr><td>Link to source:</td><td>Could provide a link here</td></tr>";
			sRowDetailsHtml  = sRowDetailsHtml &  "<tr><td>Extra info:</td><td>And any further details here (images etc)</td></tr>";
			sRowDetailsHtml  = sRowDetailsHtml &  "</table>";
			
			attrs.setSRowDetailsHtml(sRowDetailsHtml); //empty row turns off the expand row feature

			//uncomment to override defaults
			//attrs.bSingleSelect = 0;//1 for single 0 for multiselect
			//attrs.iDisplayLength = 20;

			return attrs;
		</cfscript>
		
	</cffunction>

</cfcomponent>