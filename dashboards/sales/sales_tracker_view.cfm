<!--- ----------------------------------------------------------------------------------------- --->
<!--- styles used for the selector buttons --->
<!--- ----------------------------------------------------------------------------------------- --->

<style>

.selector
{
	color:				#FFFFFF;
	font-weight:		bold;
	font-size:			11px;
	margin:				0px 0px 5px 10px;
	height:				25px;
	width:				125px;
	text-align:			center;
	float:				right;
	cursor:				pointer;
	text-transform:		capitalize;
	text-shadow: 			1px 1px 1px #000000;
	-webkit-border-radius:	5px;
	border-radius: 			5px;
	border:					0px	#333333 solid; 

background: #b5bdc8; /* Old browsers */
/* IE9 SVG, needs conditional override of 'filter' to 'none' */
background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIwJSIgeTI9IjEwMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iI2I1YmRjOCIgc3RvcC1vcGFjaXR5PSIxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiMyODM0M2IiIHN0b3Atb3BhY2l0eT0iMSIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPHJlY3QgeD0iMCIgeT0iMCIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0idXJsKCNncmFkLXVjZ2ctZ2VuZXJhdGVkKSIgLz4KPC9zdmc+);
background: -moz-linear-gradient(top,  #b5bdc8 0%, #28343b 100%); /* FF3.6+ */
background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#b5bdc8), color-stop(100%,#28343b)); /* Chrome,Safari4+ */
background: -webkit-linear-gradient(top,  #b5bdc8 0%,#28343b 100%); /* Chrome10+,Safari5.1+ */
background: -o-linear-gradient(top,  #b5bdc8 0%,#28343b 100%); /* Opera 11.10+ */
background: -ms-linear-gradient(top,  #b5bdc8 0%,#28343b 100%); /* IE10+ */
background: linear-gradient(to bottom,  #b5bdc8 0%,#28343b 100%); /* W3C */
filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#b5bdc8', endColorstr='#28343b',GradientType=0 ); /* IE6-8 */

}

.selector_down
{
	color:				#FFFFFF;
	cursor:				default;

background: #28343b; /* Old browsers */
/* IE9 SVG, needs conditional override of 'filter' to 'none' */
background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIwJSIgeTI9IjEwMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iIzI4MzQzYiIgc3RvcC1vcGFjaXR5PSIxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiNiNWJkYzgiIHN0b3Atb3BhY2l0eT0iMSIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPHJlY3QgeD0iMCIgeT0iMCIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0idXJsKCNncmFkLXVjZ2ctZ2VuZXJhdGVkKSIgLz4KPC9zdmc+);
background: -moz-linear-gradient(top,  #28343b 0%, #b5bdc8 100%); /* FF3.6+ */
background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#28343b), color-stop(100%,#b5bdc8)); /* Chrome,Safari4+ */
background: -webkit-linear-gradient(top,  #28343b 0%,#b5bdc8 100%); /* Chrome10+,Safari5.1+ */
background: -o-linear-gradient(top,  #28343b 0%,#b5bdc8 100%); /* Opera 11.10+ */
background: -ms-linear-gradient(top,  #28343b 0%,#b5bdc8 100%); /* IE10+ */
background: linear-gradient(to bottom,  #28343b 0%,#b5bdc8 100%); /* W3C */
filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#28343b', endColorstr='#b5bdc8',GradientType=0 ); /* IE6-8 */

}

.line
{
	border-top:			2px #00AA00 solid;
	margin:				5px 0px 0px 0px;
	clear: 				both;
}

.title
{
	color:				#FFFF00;
	font-weight:		bold;
	font-size:			16px;
	padding:			3px 3px 6px 3px;
	float:				left;
}

table.datagrid
{
	margin:				5px auto 0px auto;
	width:				100%;
    border-spacing:		0px;
    border-collapse:	collapse;
	background-color:	#555555;

}

th.datagrid
{
	color:				#FFFFFF;
	padding:			3px 3px 3px 3px;
	font-size:			10px;
	font-weight:		bold;
	border:				1px #000000 solid;
}

td.datagrid
{
	color:				#CCCCCC;
	padding:			3px 3px 3px 3px;
	font-size:			10px;
	font-weight:		normal;
	background-color:	#000000;
	border:				1px #555555 solid;
}

td.rmtotal
{
	color:				#FFFF00;
	padding:			3px 3px 3px 3px;
	font-size:			11px;
	font-weight:		bold;
	background-color:	#000000;
	border-top:			2px #FFFF00 solid;
}

td.datagrid_spacer
{
	border:				1px #000000 solid;
	border-bottom:		1px #555555 solid;
	background-color:	#000000;
	padding:			4px 0px 4px 0px; 
	
}

td.grandtotal
{
	color:				#000000;
	padding:			6px 3px 6px 3px;
	font-size:			14px;
	font-weight:		bold;
	background-color:	#DDDDDD;
	border-top:			0px #FFFF00 solid;
}



th.left, td.left {text-align: left;}
th.center, td.center {text-align: center;}
th.right, td.right {text-align: right;}

</style>


<!--- ----------------------------------------------------------------------------------------- --->

<br />

<button 	class="selector 
		<cfif url.content EQ '26011-88319-25672-80891'> selector_down</cfif>" 
		<cfif url.content NEQ '26011-88319-25672-80891'> onClick="window.open('sales_tracker.cfm?content=26011-88319-25672-80891','_parent');"</cfif>
        >Trade Total</button>
        
<button 	class="selector 
		<cfif url.content EQ '74621-35745-50011-23332'> selector_down</cfif>" 
		<cfif url.content NEQ '74621-35745-50011-23332'> onClick="window.open('sales_tracker.cfm?content=74621-35745-50011-23332','_parent');"</cfif>
        >trade distributors</button>

<button	class="selector 
		<cfif url.content EQ '75084-89619-44658-45919'> selector_down</cfif>" 
		<cfif url.content NEQ '75084-89619-44658-45919'> onClick="window.open('sales_tracker.cfm?content=75084-89619-44658-45919','_parent');"</cfif>
        >trade operators</button>
        
<button	class="selector 
		<cfif url.content EQ '63141-57622-30802-14065'> selector_down</cfif>" 
		<cfif url.content NEQ '63141-57622-30802-14065'> onClick="window.open('sales_tracker.cfm?content=63141-57622-30802-14065','_parent');"</cfif>
        >cases</button>


<button	class="selector 
		<cfif url.content EQ '81957-97068-45938-95590'> selector_down</cfif>"
		<cfif url.content NEQ '81957-97068-45938-95590'> onClick="window.open('sales_tracker.cfm?content=81957-97068-45938-95590','_parent');"</cfif>
        >net sales</button>


<span class="title">
	<cfoutput>#title#</cfoutput>
</span>

<div class="line"></div>


<br />





<!--- ----------------------------------------------------------------------------------------- --->
<!--- get the dates for the column headers                                                      --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfset useLakebaseForbudget_dates = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("salestr_dashboard_dates")>
<cfif useLakebaseForbudget_dates>
	<cftry>
		<cfset budget_dates = application.oLakebase.toQuery(
			application.oLakebase.selectRows("salestr_dashboard_dates", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForbudget_dates = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForbudget_dates>
<CFQUERY NAME="budget_dates" datasource="#Application.Datasource#">
  select      *
  from        SalesTR_Dashboard_Dates 
</CFQUERY>
</cfif>

<cfset month_reported     =   budget_dates.Month_description>
<cfset year_report_prv    =   budget_dates.previous_fiscal_year>
<cfset year_report_cur    =   budget_dates.Current_fiscal_year>

<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->






<!--- ----------------------------------------------------------------------------------------- --->
<!--- get the data to populate the table by first deciding which table data is coming from      --->
<!--- ----------------------------------------------------------------------------------------- --->

<CFIF url.content is "63141-57622-30802-14065">
  <!--- show the cases data  --->
  <cfset sales_tracker_table = "SalesTR_Dashboard_Cases">

<CFELSEIF url.content IS "75084-89619-44658-45919">  
  <!--- show the trade operators--->
  <cfset sales_tracker_table = "SalesTR_Dashboard_Trade_Operator">

<CFELSEIF url.content IS "74621-35745-50011-23332">  
  <!--- show the trade distributors  --->
  <cfset sales_tracker_table = "SalesTR_Dashboard_Trade_Distributor">

<CFELSEIF url.content IS "26011-88319-25672-80891">  
  <!--- show the trade total  --->
  <cfset sales_tracker_table = "SalesTR_Dashboard_Total_Trade">

<CFELSE>  
  <!--- show the net sales data  --->
  <cfset sales_tracker_table = "SalesTR_Dashboard_Net_Sales">
</CFIF>  


<CFQUERY NAME="table_data" datasource="#Application.Datasource#">
  Select        *
  from          <cfoutput>#sales_tracker_table#</cfoutput>
  where         Region_Number <> 'None'
</CFQUERY>



<!--- ----------------------------------------------------------------------------------------- --->
<!--- this is the mapping of the ui columns versus the database fields --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- 
table_data.service_zone_id
table_data.zone_number
table_data.zone_name
table_data.Service_region_id
table_data.Region_Number                Market number (Known as region manager)
table_data.Region_Name                  Market name (Known as TBM)
table_data.Service_market_id
table_data.Market_number
table_data.Market_name
table_data.Current_fiscal_period        Curr period of curr year
table_data.Previous_fiscal_period       Curr period of prev year
table_data.Fiscal_period_diff           Curr period of curr year - Curr period of prev year
table_data.Fiscal_period_diff_index     Curr period of curr year - Curr period of prev year in %
table_data.Current_Fiscal_YTD           YTD current year
table_data.Previous_Fiscal_YTD          YTD previous year
table_data.YTD_diff                     YTD current year - YTD previous year
table_data.YTD_diff_index               YTD current year - YTD previous year in %
--->



<table class="datagrid" id="example">

<thead>
    <tr>
        <th class="datagrid left" colspan="2"><div style="text-align: center; text-shadow: 1px 1px 0 #000000; font-style:normal; font-size:10px; font-weight:bold; color: yellow;">*** click column headers to sort the data ***</div></td>
        <th class="datagrid center" colspan="4"><cfoutput>#month_reported#</cfoutput></td>
        <th class="datagrid center" colspan="4">Year to Date</td>
    </tr>
    <tr>
        <th class="datagrid left" style="background-color:#009900;">Region Manager</td>
        <th class="datagrid left" style="background-color:#009900;">TBM</td>
        <th class="datagrid right" style="background-color:#009900;"><cfoutput>#year_report_prv#</cfoutput></td>
        <th class="datagrid right" style="background-color:#009900;"><cfoutput>#year_report_cur#</cfoutput></td>
        <th class="datagrid right" style="background-color:#009900;">Diff.</td>
        <th class="datagrid right" style="background-color:#009900;">Percent.</td>
        <th class="datagrid right" style="background-color:#009900;"><cfoutput>#year_report_prv#</cfoutput></td>
        <th class="datagrid right" style="background-color:#009900;"><cfoutput>#year_report_cur#</cfoutput></td>
        <th class="datagrid right" style="background-color:#009900;">Diff.</td>
        <th class="datagrid right" style="background-color:#009900;">Percent.</td>
    </tr>
</thead>	


<tbody>



<cfloop query="table_data">

<cfset market_number = table_data.Region_Number>
<cfset market_name = table_data.Region_Name>

<cfset curr_period_of_prev_year = table_data.Previous_fiscal_period>
<cfset curr_period_of_curr_year = table_data.Current_fiscal_period>
<cfset dif_periods = table_data.Fiscal_period_diff>
<cfset dif_periods_percent = table_data.Fiscal_period_diff_index>

<cfset ytd_prev_year = table_data.Previous_Fiscal_YTD>
<cfset ytd_curr_year = table_data.Current_Fiscal_YTD>
<cfset dif_ytd = table_data.YTD_diff>
<cfset dif_ytd_percent = table_data.YTD_diff_index>


<cfoutput>
    <tr>
        <td class="datagrid left">#market_number#</td>
        <td class="datagrid left">#market_name#</td>

        <td class="datagrid right">#numberformat(curr_period_of_prev_year, ',0.00')#</td>
        <td class="datagrid right">#numberformat(curr_period_of_curr_year, ',0.00')#</td>
        <td class="datagrid right">#numberformat(dif_periods, ',0.00')#</td>
        <td class="datagrid right"><CFIF dif_periods_percent IS "n/a">#dif_periods_percent#<CFELSE>#numberformat(dif_periods_percent, ',0.00')#%</CFIF></td>


        <td class="datagrid right">#numberformat(ytd_prev_year, ',0.00')#</td>
        <td class="datagrid right">#numberformat(ytd_curr_year, ',0.00')#</td>
        <td class="datagrid right">#numberformat(dif_ytd, ',0.00')#</td>
        <td class="datagrid right"><CFIF dif_ytd_percent IS "n/a">#dif_ytd_percent#<CFELSE>#numberformat(dif_ytd_percent, ',0.00')#%</CFIF></td>
    </tr>
</cfoutput>


  
</cfloop>






</tbody>
<cfoutput>


<!--- 
<tfoot>
	<tr>
    	<td class="datagrid grandtotal left" colspan="2">TOTAL</td>
    	<td class="datagrid grandtotal right">#numberformat(TOTAL_LY_month, ',')#</td>
    	<td class="datagrid grandtotal right">#numberformat(TOTAL_TY_month, ',')#</td>
    	<td class="datagrid grandtotal right">#numberformat(TOTAL_TY_month-TOTAL_LY_month, ',')#</td>
    	<td class="datagrid grandtotal right">#numberformat(TOTAL_TY_month/TOTAL_LY_month*100, '0.00')#</td>
    	<td class="datagrid grandtotal right">#numberformat(TOTAL_LY_year, ',')#</td>
    	<td class="datagrid grandtotal right">#numberformat(TOTAL_TY_year, ',')#</td>
    	<td class="datagrid grandtotal right">#numberformat(TOTAL_TY_year-TOTAL_LY_year, ',')#</td>
    	<td class="datagrid grandtotal right">#numberformat(TOTAL_TY_year/TOTAL_LY_year*100, '0.00')#</td>
    </tr>
</tfoot>
 --->

</cfoutput>
</table>


<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<script src="http://code.jquery.com/jquery-1.11.1.min.js"></script>
<script src="http://cdn.datatables.net/1.10.1/js/jquery.dataTables.min.js"></script>

<script>

  $(document).ready(function() {
      
      $('#example').dataTable( {

          // used to set sorting on the 7th column in descending order
          "order": [[ 7, "desc" ]],

          // used to change the "no data" message displayed
          "language": { "emptyTable": "<br><br><br><br><br><br><br><br>No data available<br><br><br><br><br><br><br><br><br>"}
      } );

  } );

</script>
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->


<style>
/*
 * Table styles
 */
table.dataTable {
  width: 100%;
  margin: 0 auto;
  clear: both;
  border-collapse: separate;
  border-spacing: 0;
  /*
   * Header and footer styles
   */
  /*
   * Body styles
   */
}
table.dataTable thead th,
table.dataTable tfoot th {
  font-weight: bold;
}
table.dataTable thead th,
table.dataTable thead td {
  padding: 5px 8px 5px 20px;
  border-bottom: 1px solid #111111;
  background-color:	#009900;
}
table.dataTable thead th:active,
table.dataTable thead td:active {
  outline: none;
}
table.dataTable tfoot th,
table.dataTable tfoot td {
  padding: 10px 18px 6px 18px;
  border-top: 1px solid #111111;
}
table.dataTable thead .sorting_asc,
table.dataTable thead .sorting_desc,
table.dataTable thead .sorting {
  cursor: pointer;
  *cursor: hand;
}
table.dataTable thead .sorting {
  background: url("images/sort_both.png") no-repeat center left;
}
table.dataTable thead .sorting_asc {
  background: url("images/sort_asc.png") no-repeat center left
}
table.dataTable thead .sorting_desc {
  background: url("images/sort_desc.png") no-repeat center left;
}
table.dataTable thead .sorting_asc_disabled {
  background: url("images/sort_asc_disabled.png") no-repeat center left;
}
table.dataTable thead .sorting_desc_disabled {
  background: url("images/sort_desc_disabled.png") no-repeat center left;
}
table.dataTable tbody tr {
  background-color: #ffffff; /* area where the "no data" message shows up */
}
table.dataTable tbody tr.selected {
  background-color: #b0bed9;
}
table.dataTable tbody th,
table.dataTable tbody td {
  padding: 6px 7px;
}
table.dataTable.row-border tbody th, table.dataTable.row-border tbody td, table.dataTable.display tbody th, table.dataTable.display tbody td {
  border-top: 1px solid #dddddd;
}
table.dataTable.row-border tbody tr:first-child th,
table.dataTable.row-border tbody tr:first-child td, table.dataTable.display tbody tr:first-child th,
table.dataTable.display tbody tr:first-child td {
  border-top: none;
}
table.dataTable.cell-border tbody th, table.dataTable.cell-border tbody td {
  border-top: 1px solid #dddddd;
  border-right: 1px solid #dddddd;
}
table.dataTable.cell-border tbody tr th:first-child,
table.dataTable.cell-border tbody tr td:first-child {
  border-left: 1px solid #dddddd;
}
table.dataTable.cell-border tbody tr:first-child th,
table.dataTable.cell-border tbody tr:first-child td {
  border-top: none;
}
table.dataTable.stripe tbody tr.odd, table.dataTable.display tbody tr.odd {
  background-color: #f9f9f9;
}
table.dataTable.stripe tbody tr.odd.selected, table.dataTable.display tbody tr.odd.selected {
  background-color: #abb9d3;
}
table.dataTable.hover tbody tr:hover,
table.dataTable.hover tbody tr.odd:hover,
table.dataTable.hover tbody tr.even:hover, table.dataTable.display tbody tr:hover,
table.dataTable.display tbody tr.odd:hover,
table.dataTable.display tbody tr.even:hover {
  background-color: whitesmoke;
}
table.dataTable.hover tbody tr:hover.selected,
table.dataTable.hover tbody tr.odd:hover.selected,
table.dataTable.hover tbody tr.even:hover.selected, table.dataTable.display tbody tr:hover.selected,
table.dataTable.display tbody tr.odd:hover.selected,
table.dataTable.display tbody tr.even:hover.selected {
  background-color: #a9b7d1;
}
table.dataTable.order-column tbody tr > .sorting_1,
table.dataTable.order-column tbody tr > .sorting_2,
table.dataTable.order-column tbody tr > .sorting_3, table.dataTable.display tbody tr > .sorting_1,
table.dataTable.display tbody tr > .sorting_2,
table.dataTable.display tbody tr > .sorting_3 {
  background-color: #f9f9f9;
}
table.dataTable.order-column tbody tr.selected > .sorting_1,
table.dataTable.order-column tbody tr.selected > .sorting_2,
table.dataTable.order-column tbody tr.selected > .sorting_3, table.dataTable.display tbody tr.selected > .sorting_1,
table.dataTable.display tbody tr.selected > .sorting_2,
table.dataTable.display tbody tr.selected > .sorting_3 {
  background-color: #acbad4;
}
table.dataTable.display tbody tr.odd > .sorting_1, table.dataTable.order-column.stripe tbody tr.odd > .sorting_1 {
  background-color: #f1f1f1;
}
table.dataTable.display tbody tr.odd > .sorting_2, table.dataTable.order-column.stripe tbody tr.odd > .sorting_2 {
  background-color: #f3f3f3;
}
table.dataTable.display tbody tr.odd > .sorting_3, table.dataTable.order-column.stripe tbody tr.odd > .sorting_3 {
  background-color: whitesmoke;
}
table.dataTable.display tbody tr.odd.selected > .sorting_1, table.dataTable.order-column.stripe tbody tr.odd.selected > .sorting_1 {
  background-color: #a6b3cd;
}
table.dataTable.display tbody tr.odd.selected > .sorting_2, table.dataTable.order-column.stripe tbody tr.odd.selected > .sorting_2 {
  background-color: #a7b5ce;
}
table.dataTable.display tbody tr.odd.selected > .sorting_3, table.dataTable.order-column.stripe tbody tr.odd.selected > .sorting_3 {
  background-color: #a9b6d0;
}
table.dataTable.display tbody tr.even > .sorting_1, table.dataTable.order-column.stripe tbody tr.even > .sorting_1 {
  background-color: #f9f9f9;
}
table.dataTable.display tbody tr.even > .sorting_2, table.dataTable.order-column.stripe tbody tr.even > .sorting_2 {
  background-color: #fbfbfb;
}
table.dataTable.display tbody tr.even > .sorting_3, table.dataTable.order-column.stripe tbody tr.even > .sorting_3 {
  background-color: #fdfdfd;
}
table.dataTable.display tbody tr.even.selected > .sorting_1, table.dataTable.order-column.stripe tbody tr.even.selected > .sorting_1 {
  background-color: #acbad4;
}
table.dataTable.display tbody tr.even.selected > .sorting_2, table.dataTable.order-column.stripe tbody tr.even.selected > .sorting_2 {
  background-color: #adbbd6;
}
table.dataTable.display tbody tr.even.selected > .sorting_3, table.dataTable.order-column.stripe tbody tr.even.selected > .sorting_3 {
  background-color: #afbdd8;
}
table.dataTable.display tbody tr:hover > .sorting_1,
table.dataTable.display tbody tr.odd:hover > .sorting_1,
table.dataTable.display tbody tr.even:hover > .sorting_1, table.dataTable.order-column.hover tbody tr:hover > .sorting_1,
table.dataTable.order-column.hover tbody tr.odd:hover > .sorting_1,
table.dataTable.order-column.hover tbody tr.even:hover > .sorting_1 {
  background-color: #eaeaea;
}
table.dataTable.display tbody tr:hover > .sorting_2,
table.dataTable.display tbody tr.odd:hover > .sorting_2,
table.dataTable.display tbody tr.even:hover > .sorting_2, table.dataTable.order-column.hover tbody tr:hover > .sorting_2,
table.dataTable.order-column.hover tbody tr.odd:hover > .sorting_2,
table.dataTable.order-column.hover tbody tr.even:hover > .sorting_2 {
  background-color: #ebebeb;
}
table.dataTable.display tbody tr:hover > .sorting_3,
table.dataTable.display tbody tr.odd:hover > .sorting_3,
table.dataTable.display tbody tr.even:hover > .sorting_3, table.dataTable.order-column.hover tbody tr:hover > .sorting_3,
table.dataTable.order-column.hover tbody tr.odd:hover > .sorting_3,
table.dataTable.order-column.hover tbody tr.even:hover > .sorting_3 {
  background-color: #eeeeee;
}
table.dataTable.display tbody tr:hover.selected > .sorting_1,
table.dataTable.display tbody tr.odd:hover.selected > .sorting_1,
table.dataTable.display tbody tr.even:hover.selected > .sorting_1, table.dataTable.order-column.hover tbody tr:hover.selected > .sorting_1,
table.dataTable.order-column.hover tbody tr.odd:hover.selected > .sorting_1,
table.dataTable.order-column.hover tbody tr.even:hover.selected > .sorting_1 {
  background-color: #a1aec7;
}
table.dataTable.display tbody tr:hover.selected > .sorting_2,
table.dataTable.display tbody tr.odd:hover.selected > .sorting_2,
table.dataTable.display tbody tr.even:hover.selected > .sorting_2, table.dataTable.order-column.hover tbody tr:hover.selected > .sorting_2,
table.dataTable.order-column.hover tbody tr.odd:hover.selected > .sorting_2,
table.dataTable.order-column.hover tbody tr.even:hover.selected > .sorting_2 {
  background-color: #a2afc8;
}
table.dataTable.display tbody tr:hover.selected > .sorting_3,
table.dataTable.display tbody tr.odd:hover.selected > .sorting_3,
table.dataTable.display tbody tr.even:hover.selected > .sorting_3, table.dataTable.order-column.hover tbody tr:hover.selected > .sorting_3,
table.dataTable.order-column.hover tbody tr.odd:hover.selected > .sorting_3,
table.dataTable.order-column.hover tbody tr.even:hover.selected > .sorting_3 {
  background-color: #a4b2cb;
}
table.dataTable.no-footer {
  border-bottom: 1px solid #111111;
}
table.dataTable.nowrap th, table.dataTable.nowrap td {
  white-space: nowrap;
}
table.dataTable.compact thead th,
table.dataTable.compact thead td {
  padding: 5px 9px;
}
table.dataTable.compact tfoot th,
table.dataTable.compact tfoot td {
  padding: 5px 9px 3px 9px;
}
table.dataTable.compact tbody th,
table.dataTable.compact tbody td {
  padding: 4px 5px;
}
table.dataTable th.dt-left,
table.dataTable td.dt-left {
  text-align: left;
}
table.dataTable th.dt-center,
table.dataTable td.dt-center,
table.dataTable td.dataTables_empty /* "dataTables_empty" is the class that regulates the "no data" message area */{
  text-align: center;
  color:  #FFFF00;
  background-color: black;
}
table.dataTable th.dt-right,
table.dataTable td.dt-right {
  text-align: right;
}
table.dataTable th.dt-justify,
table.dataTable td.dt-justify {
  text-align: justify;
}
table.dataTable th.dt-nowrap,
table.dataTable td.dt-nowrap {
  white-space: nowrap;
}
table.dataTable thead th.dt-head-left,
table.dataTable thead td.dt-head-left,
table.dataTable tfoot th.dt-head-left,
table.dataTable tfoot td.dt-head-left {
  text-align: left;
}
table.dataTable thead th.dt-head-center,
table.dataTable thead td.dt-head-center,
table.dataTable tfoot th.dt-head-center,
table.dataTable tfoot td.dt-head-center {
  text-align: center;
}
table.dataTable thead th.dt-head-right,
table.dataTable thead td.dt-head-right,
table.dataTable tfoot th.dt-head-right,
table.dataTable tfoot td.dt-head-right {
  text-align: right;
}
table.dataTable thead th.dt-head-justify,
table.dataTable thead td.dt-head-justify,
table.dataTable tfoot th.dt-head-justify,
table.dataTable tfoot td.dt-head-justify {
  text-align: justify;
}
table.dataTable thead th.dt-head-nowrap,
table.dataTable thead td.dt-head-nowrap,
table.dataTable tfoot th.dt-head-nowrap,
table.dataTable tfoot td.dt-head-nowrap {
  white-space: nowrap;
}
table.dataTable tbody th.dt-body-left,
table.dataTable tbody td.dt-body-left {
  text-align: left;
}
table.dataTable tbody th.dt-body-center,
table.dataTable tbody td.dt-body-center {
  text-align: center;
}
table.dataTable tbody th.dt-body-right,
table.dataTable tbody td.dt-body-right {
  text-align: right;
}
table.dataTable tbody th.dt-body-justify,
table.dataTable tbody td.dt-body-justify {
  text-align: justify;
}
table.dataTable tbody th.dt-body-nowrap,
table.dataTable tbody td.dt-body-nowrap {
  white-space: nowrap;
}

table.dataTable,
table.dataTable th,
table.dataTable td {
  -webkit-box-sizing: content-box;
  -moz-box-sizing: content-box;
  box-sizing: content-box;
}

/*
 * Control feature layout
 */
.dataTables_wrapper {
  position: relative;
  clear: both;
  *zoom: 1;
  zoom: 1;
}
.dataTables_wrapper .dataTables_length {
  float: left;
}
.dataTables_wrapper .dataTables_filter {
  float: right;
  text-align: right;
}
.dataTables_wrapper .dataTables_filter input {
  margin-left: 0.5em;
}
.dataTables_wrapper .dataTables_info {
  clear: both;
  float: left;
  padding-top: 0.755em;
}
.dataTables_wrapper .dataTables_paginate {
  float: right;
  text-align: right;
  padding-top: 0.25em;
}
.dataTables_wrapper .dataTables_paginate .paginate_button {
  box-sizing: border-box;
  display: inline-block;
  min-width: 1.5em;
  padding: 0.5em 1em;
  margin-left: 2px;
  text-align: center;
  text-decoration: none !important;
  cursor: pointer;
  *cursor: hand;
  color: #333333 !important;
  border: 1px solid transparent;
}
.dataTables_wrapper .dataTables_paginate .paginate_button.current, .dataTables_wrapper .dataTables_paginate .paginate_button.current:hover {
  color: #333333 !important;
  border: 1px solid #cacaca;
  background-color: white;
  background: -webkit-gradient(linear, left top, left bottom, color-stop(0%, white), color-stop(100%, gainsboro));
  /* Chrome,Safari4+ */
  background: -webkit-linear-gradient(top, white 0%, gainsboro 100%);
  /* Chrome10+,Safari5.1+ */
  background: -moz-linear-gradient(top, white 0%, gainsboro 100%);
  /* FF3.6+ */
  background: -ms-linear-gradient(top, white 0%, gainsboro 100%);
  /* IE10+ */
  background: -o-linear-gradient(top, white 0%, gainsboro 100%);
  /* Opera 11.10+ */
  background: linear-gradient(to bottom, white 0%, gainsboro 100%);
  /* W3C */
}
.dataTables_wrapper .dataTables_paginate .paginate_button.disabled, .dataTables_wrapper .dataTables_paginate .paginate_button.disabled:hover, .dataTables_wrapper .dataTables_paginate .paginate_button.disabled:active {
  cursor: default;
  color: #666 !important;
  border: 1px solid transparent;
  background: transparent;
  box-shadow: none;
}
.dataTables_wrapper .dataTables_paginate .paginate_button:hover {
  color: white !important;
  border: 1px solid #111111;
  background-color: #585858;
  background: -webkit-gradient(linear, left top, left bottom, color-stop(0%, #585858), color-stop(100%, #111111));
  /* Chrome,Safari4+ */
  background: -webkit-linear-gradient(top, #585858 0%, #111111 100%);
  /* Chrome10+,Safari5.1+ */
  background: -moz-linear-gradient(top, #585858 0%, #111111 100%);
  /* FF3.6+ */
  background: -ms-linear-gradient(top, #585858 0%, #111111 100%);
  /* IE10+ */
  background: -o-linear-gradient(top, #585858 0%, #111111 100%);
  /* Opera 11.10+ */
  background: linear-gradient(to bottom, #585858 0%, #111111 100%);
  /* W3C */
}
.dataTables_wrapper .dataTables_paginate .paginate_button:active {
  outline: none;
  background-color: #2b2b2b;
  background: -webkit-gradient(linear, left top, left bottom, color-stop(0%, #2b2b2b), color-stop(100%, #0c0c0c));
  /* Chrome,Safari4+ */
  background: -webkit-linear-gradient(top, #2b2b2b 0%, #0c0c0c 100%);
  /* Chrome10+,Safari5.1+ */
  background: -moz-linear-gradient(top, #2b2b2b 0%, #0c0c0c 100%);
  /* FF3.6+ */
  background: -ms-linear-gradient(top, #2b2b2b 0%, #0c0c0c 100%);
  /* IE10+ */
  background: -o-linear-gradient(top, #2b2b2b 0%, #0c0c0c 100%);
  /* Opera 11.10+ */
  background: linear-gradient(to bottom, #2b2b2b 0%, #0c0c0c 100%);
  /* W3C */
  box-shadow: inset 0 0 3px #111;
}
.dataTables_wrapper .dataTables_processing {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 100%;
  height: 40px;
  margin-left: -50%;
  margin-top: -25px;
  padding-top: 20px;
  text-align: center;
  font-size: 1.2em;
  background-color: white;
  background: -webkit-gradient(linear, left top, right top, color-stop(0%, rgba(255, 255, 255, 0)), color-stop(25%, rgba(255, 255, 255, 0.9)), color-stop(75%, rgba(255, 255, 255, 0.9)), color-stop(100%, rgba(255, 255, 255, 0)));
  /* Chrome,Safari4+ */
  background: -webkit-linear-gradient(left, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 0.9) 25%, rgba(255, 255, 255, 0.9) 75%, rgba(255, 255, 255, 0) 100%);
  /* Chrome10+,Safari5.1+ */
  background: -moz-linear-gradient(left, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 0.9) 25%, rgba(255, 255, 255, 0.9) 75%, rgba(255, 255, 255, 0) 100%);
  /* FF3.6+ */
  background: -ms-linear-gradient(left, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 0.9) 25%, rgba(255, 255, 255, 0.9) 75%, rgba(255, 255, 255, 0) 100%);
  /* IE10+ */
  background: -o-linear-gradient(left, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 0.9) 25%, rgba(255, 255, 255, 0.9) 75%, rgba(255, 255, 255, 0) 100%);
  /* Opera 11.10+ */
  background: linear-gradient(to right, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 0.9) 25%, rgba(255, 255, 255, 0.9) 75%, rgba(255, 255, 255, 0) 100%);
  /* W3C */
}
.dataTables_wrapper .dataTables_length,
.dataTables_wrapper .dataTables_filter,
.dataTables_wrapper .dataTables_info,
.dataTables_wrapper .dataTables_processing,
.dataTables_wrapper .dataTables_paginate {
  color: #CCCCCC;
}
.dataTables_wrapper .dataTables_scroll {
  clear: both;
}
.dataTables_wrapper .dataTables_scroll div.dataTables_scrollBody {
  *margin-top: -1px;
  -webkit-overflow-scrolling: touch;
}
.dataTables_wrapper .dataTables_scroll div.dataTables_scrollBody th > div.dataTables_sizing,
.dataTables_wrapper .dataTables_scroll div.dataTables_scrollBody td > div.dataTables_sizing {
  height: 0;
  overflow: hidden;
  margin: 0 !important;
  padding: 0 !important;
}
.dataTables_wrapper.no-footer .dataTables_scrollBody {
  border-bottom: 1px solid #111111;
}
.dataTables_wrapper.no-footer div.dataTables_scrollHead table,
.dataTables_wrapper.no-footer div.dataTables_scrollBody table {
  border-bottom: none;
}
.dataTables_wrapper:after {
  visibility: hidden;
  display: block;
  content: "";
  clear: both;
  height: 0;
}

@media screen and (max-width: 767px) {
  .dataTables_wrapper .dataTables_info,
  .dataTables_wrapper .dataTables_paginate {
    float: none;
    text-align: center;
  }
  .dataTables_wrapper .dataTables_paginate {
    margin-top: 0.5em;
  }
}
@media screen and (max-width: 640px) {
  .dataTables_wrapper .dataTables_length,
  .dataTables_wrapper .dataTables_filter {
    float: none;
    text-align: center;
  }
  .dataTables_wrapper .dataTables_filter {
    margin-top: 0.5em;
  }
}

</style>

