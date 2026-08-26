<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
	   File Name:  AwayX/Planners/Create/planner_output.cfm
	Created Date:  2017 Sep
	  Created By:  Chris Nguyen
	 Description:  Displays a planner output
--------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cf_layout_planner>
<style>
	table.dataTable tbody td { padding-left: 15px; }
	div.export { float: left; margin-left: 25px; position: relative; top: -2px; }
	div#DataTables_Table_0_filter input { width: 230px; }
</style>

<cfinclude template="topnav_form.cfm">

<!--- get both default setting and planner template setting, order them by default_setting & pick the top row --->
<cfquery name="qSettings" datasource="#application.datasource#">
	SELECT TOP 1 config.*,
	       p.Planner_Number
	  FROM (   SELECT Planner_Output_Setting.*
	             FROM Planners
	            INNER JOIN Planner_Template
	               ON Planner_Template.Planner_Template_ID = Planners.Planner_Template_ID
	            INNER JOIN Planner_Output_Setting
	               ON Planner_Output_Setting.Config_ID     = Planner_Template.Planner_Output_Setting_Config_ID
	            WHERE Planners.Planner_ID = #form.plannerID#
	           UNION
	           SELECT TOP 1 *
	             FROM Planner_Output_Setting
	            WHERE Planner_Output_Setting.Default_Setting = 1
	              AND Planner_Output_Setting.Deleted         = 0) config
	 INNER JOIN Planners p
	    ON p.Planner_ID = #form.plannerID#
	 ORDER BY config.Default_Setting
</cfquery>

<cfset setting_columns = listToArray( qSettings.columnList )>
<cfset report_columns  = []>
<!---  scan thru all setting columns and gather included columns --->
<cfloop array="#setting_columns#" index="setting_column">
	<!--- find those columns that are selected to include on report  --->
	<cfif setting_column contains "_include" and qSettings[ setting_column ][1] eq "1">
		<!--- remove postfix to get the actual column name --->
		<cfset actual_column = replaceNocase(setting_column, "_include", "", "all")>
		<cfset arrayAppend( report_columns, { 	label=qSettings[ actual_column & "_label" ][1]
												,name=actual_column
												,columnOrder=qSettings[ actual_column & "_sequence" ][1] } )>
	</cfif>
</cfloop>

<cf_include files=#arrayToList( [ "/common_files/datatable2.css"
								 ,"/common_files/dataTables2.cfm"
								 ,"/common_files/dhx_message.cfm"
								 ,"/common_files/jQueryUI.cfm"
								 ,"/script/javascript/table2csv.js"
								])#>


<cfif arrayLen(report_columns) eq 0>
	<script>
		dhx_alert( "Please specify columns to include in the report<br>in <cfoutput>#Application.PlannerLabel#</cfoutput> output settings under Settings." );
	</script>
<cfelse>
	<!---  rearrange columns based on column orders  --->
	<cfset report_columns = application.util.array.arrayOfStructsSort(report_columns, "columnOrder")>

	<!---  retrieve data from a stored procedure  --->
	<cfquery name="qOutput0" datasource="#application.datasource#">
		EXEC Planner_Output #form.plannerID#, #qSettings.by_group#
	</cfquery>

	<!--- rebuild query based on columns order defined in settings  --->
	<cfquery name="qOutput" dbtype="query">
		SELECT
			<cfloop array="#report_columns#" index="report_column">
				#report_column.name#,
			</cfloop>
			1 AS dummy
			,Fixed_Price_UOM AS hidden_fixed_price_uom
			,Rebate_UOM AS hidden_rebate_uom
		  FROM qOutput0
	</cfquery>

	<!--- if columns count is less than 10 use 100% width else add 10% for each additional column --->
	<cfset table_width = max(100, arrayLen(report_columns) * 13) & "%">
	<table class="dataTable row-border order-column hover" width="<cfoutput>#table_width#</cfoutput>" cellpadding="0">
		<thead>
			<tr>
				<cfloop array="#report_columns#" index="report_column">
					<cfif report_column.name is "Fixed_Price_Value"
					   or report_column.name is "rebate_rate"
				       or report_column.name is "Lump_Sum_Amount"
					   or report_column.name is "Merchandised_Price"
					   or report_column.name is "Everyday_Price"
					   or report_column.name is "retailer_profit"
					   or report_column.name contains "volume">
                        <cfset style = "text-align:right">
					<cfelse>
                        <cfset style = "text-align:left">
					</cfif>
                    <cfoutput><th style="#style#">#report_column.label#	</th></cfoutput>
				</cfloop>
			</tr>
		</thead>
		<tbody>
		</tbody>
	</table>

	<!--- export to csv form --->
	<form action="/common_files/csv.cfm" method ="post" id="csv_form" name="csv">
		<input type="hidden" name="csv_text" id="csv_text">
		<input type="hidden" name="csv_file_name">
	</form>

	<cfsavecontent variable="export_to_cvs"><a id=export class=secondary title='click to export to csv format'><cfoutput>#application.util.string.linkFormat('export to csv')#</cfoutput></a></cfsavecontent>
	
	<cfset data_set = []>
	<cfloop query="qOutput">
		<cfset row_data = []>
		<!---  gather columns for current row  --->
		<cfloop array="#report_columns#" index="report_column">
			<cfscript>
				column_value = trim(qOutput[ report_column.name ][ qOutput.currentRow ]);

				if ( report_column.name contains "date" )
					column_value = dateFormat(column_value, "mmm d yyyy");
				else if ( report_column.name contains "volume" )
					column_value = numberFormat(column_value, ",9");
				else if ( report_column.name is "Fixed_Price_Value" )
					column_value = numberFormat(column_value, (trim(qOutput.hidden_fixed_price_uom) is "CS" ? "$,.99" : "$,.9999"));
				else if ( report_column.name is "rebate_rate" )
					column_value = numberFormat(column_value, (trim(qOutput.hidden_rebate_uom) is "CS" ? "$,.99" : "$,.9999"));
				else if ( report_column.name is "Lump_Sum_Amount"
					   or report_column.name is "Merchandised_Price"
					   or report_column.name is "Everyday_Price"
					   or report_column.name is "retailer_profit" )
					column_value = (column_value is "" ? "" : numberFormat(column_value, "$,.99"));

				row_data.append(column_value);
			</cfscript>
		</cfloop>

		<cfset data_set.append( row_data )>
	</cfloop>

	<script>
		$("table.dataTable").DataTable({	data          : <cfoutput>#trim(serializeJSON( data_set ))#</cfoutput>,
											dom           : "f<'export'>pti",
											columns       : [
																<cfset loop_counter = 0>
																<cfloop array="#report_columns#" index="report_column">
																	<cfif report_column.name contains "rate"
																			or report_column.name contains "price"
																			or report_column.name contains "amount"
																			or report_column.name eq "retailer_profit"
																			or report_column.name eq "retailer_margin"
																			or report_column.name contains "volume">
																		{ className: "dt-body-right" }
																	<cfelse>
																		null
																	</cfif>
																	<cfset loop_counter = loop_counter + 1>
																	<cfif loop_counter lt arrayLen(report_columns)>
																		,
																	</cfif>
																</cfloop>
															],
											order         : [ ],
											scrollY       : "69vh",
											scrollX       : true,
											scrollCollapse: true,
											paging:         true,
											pageLength:     1000,
											pagingType: 	"full_numbers"
										});
		$("div.export").html( <cfoutput>"#export_to_cvs#"</cfoutput> );

		$("#export").click(function() {
			$('input[name=csv_file_name]').val( "planner-output-"
												+ <cfoutput>"#qSettings.Planner_Number#-"</cfoutput>
			                                    + random367()    // append an arbitrary unique substring
												+ ".csv");
			var csv_value=$("table.dataTable").table2CSV({ delivery:"value", sScrollY:999 });
			$("#csv_text").val(csv_value);
			$("#csv_form").submit();
		});
	</script>
</cfif>		<!--- <cfif arrayLen(report_columns) eq 0> --->
</cf_layout_planner>
