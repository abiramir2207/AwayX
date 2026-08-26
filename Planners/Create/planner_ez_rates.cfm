<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
	   File Name:  AwayX/Planners/Create/planner_ez_rates.cfm
	Created Date:  2021 June
	  Created By:  Tim Ford
	 Description:  Displays planner ez rate
--------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cf_layout_planner>
<style>
	table.dataTable tbody td { padding-left: 15px; }
	div.export { float: left; margin-left: 25px; position: relative; top: -2px; }
	div#DataTables_Table_0_filter input { width: 230px; }
</style>

<cfinclude template="topnav_form.cfm">

<!--- get ez rates --->
<cfquery name="qGetEZRates" datasource="#application.datasource#">

	SELECT 	pcpo.Created_Type as [Program Type], cm.Contract_Number as Program, cm.Contract_Title as Title, i.Item as Product, i.Description, 
			cm.Contract_Start_Date as [Start Date], cm.Contract_End_Date as [End Date], u.Name_First + ' ' + u.Name_First as RSP,
			cst.Contract_Status_Type_Desc as Status, s.ez_rate as [Template EZ Rate], s.ez_uom_ab as [Template Rate UOM], s.program_rate as [Program Rate], 
			s.program_uom_ab as [Program Rate UOM], s.ez_rate - s.program_rate as Variance, p.Planner_Number

	FROM   DBO.UDF_EZ_GET_PLANNER_PROGRAM_PRODUCTS (#form.plannerID#, 'NOT_WITHIN_EZ_RATE', 35) as s
			INNER JOIN BSA_Foodservice_Items_Master i
			ON i.BSA_Foodservice_Items_Master_ID = s.BSA_Foodservice_Items_Master_ID
			INNER JOIN Contract_Main cm
			ON cm.Contract_Main_ID = s.Program_ID
			INNER JOIN Program_Control_Panel_Options pcpo 
			ON pcpo.ProgramControl_Panel_Options_ID = cm.ProgramType_ID
			INNER JOIN _Users u 
			ON u.User_ID = cm.Responsible_User_ID
			INNER JOIN Contract_Status_Types cst 
			ON cst.Contract_Status_Type_ID = cm.Contract_Status_Type_IDX
			INNER JOIN Planners p 
			ON p.Planner_ID = cm.Planner_ID

	order by Program, Product
</cfquery>

<cfset setting_columns = listToArray( qGetEZRates.columnList )>
<cfset report_columns  = []>



<cfloop array="#setting_columns#" index="setting_column">
	<!--- Exclude Planner_Number  --->
	<cfif setting_column neq "Planner_Number">
		<cfswitch expression="#setting_column#">
			<cfcase value="Program Type"><cfset columnOrder = 0 /></cfcase>
			<cfcase value="Program"><cfset columnOrder = 1 /></cfcase>
			<cfcase value="Title"><cfset columnOrder = 2 /></cfcase>
			<cfcase value="Product"><cfset columnOrder = 3 /></cfcase>
			<cfcase value="Description"><cfset columnOrder = 4 /></cfcase>
			<cfcase value="Start Date"><cfset columnOrder = 5 /></cfcase>
			<cfcase value="End Date"><cfset columnOrder = 6 /></cfcase>
			<cfcase value="RSP"><cfset columnOrder = 7 /></cfcase>
			<cfcase value="Status"><cfset columnOrder = 8 /></cfcase>
			<cfcase value="Template EZ Rate"><cfset columnOrder = 9 /></cfcase>
			<cfcase value="Template Rate UOM"><cfset columnOrder = 10 /></cfcase>
			<cfcase value="Program Rate"><cfset columnOrder = 11 /></cfcase>
			<cfcase value="Program Rate UOM"><cfset columnOrder = 12 /></cfcase>
			<cfcase value="Variance"><cfset columnOrder = 13 /></cfcase>
			<cfdefaultcase><cfset columnOrder = arrayLen(setting_columns) /></cfdefaultcase>
		</cfswitch>
		<cfset arrayAppend( report_columns, { 	label=setting_column
													,name=setting_column
													,columnOrder=columnOrder} )>
	</cfif>

</cfloop>

<cf_include files=#arrayToList( [ "/common_files/datatable2.css"
								 ,"/common_files/dataTables2.cfm"
								 ,"/common_files/dhx_message.cfm"
								 ,"/common_files/jQueryUI.cfm"
								 ,"/script/javascript/table2csv.js"
								])#>


	<!---  rearrange columns based on column orders  --->
	<cfset report_columns = application.util.array.arrayOfStructsSort(report_columns, "columnOrder", "asc", "numeric")>

	<table class="dataTable row-border order-column hover" width="120%" cellpadding="0">
		<thead>
			<tr>
				<cfloop array="#report_columns#" index="report_column">
					<cfset style = "text-align:left">
					<cfoutput><th style="#style#">#report_column.label#</th></cfoutput>
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
	<cfloop query="qGetEZRates">
		<cfset row_data = []>
		<!---  gather columns for current row  --->
		<cfloop array="#report_columns#" index="report_column">
			<cfscript>
				column_value = qGetEZRates[ report_column.name ][ qGetEZRates.currentRow ];

				if (report_column.name contains "date" )
						column_value = dateFormat(column_value, "mmm d yyyy");
				else if
						( report_column.name is "Template EZ Rate"
					   	or report_column.name is "Program Rate"
					   	or report_column.name is "Variance")
							column_value = (column_value is "" ? "" : numberFormat(column_value, "$,.99"));
				
				if(report_column.name is "Variance" and column_value contains "-")
					column_value = "(" & column_value & ")";

				row_data.append(column_value);
			</cfscript>
		</cfloop>

		<cfset data_set.append( row_data )>
	</cfloop>

	<script>
		$("table.dataTable").DataTable({	data          : <cfoutput>#serializeJSON( data_set )#</cfoutput>,
											dom           : "f<'export'>ti",
											columns       : [
																<cfset loop_counter = 0>
																<cfloop array="#report_columns#" index="report_column">
																		{ className: "dt-body-left" }
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
											paging        : false
										});
		$("div.export").html( <cfoutput>"#export_to_cvs#"</cfoutput> );

		$("#export").click(function() {
			$('input[name=csv_file_name]').val( "planner-ezrates-"
												+ <cfoutput>"#qGetEZRates.Planner_Number#-"</cfoutput>
			                                    + random367()    // append an arbitrary unique substring
												+ ".csv");
			var csv_value=$("table.dataTable").table2CSV({ delivery:"value", sScrollY:999 });
			$("#csv_text").val(csv_value);
			$("#csv_form").submit();
		});

		/*
		$("table.dataTable.tbody").find('tr').each(function(){
			console.log(this);
		});
		*/
		/*
		$('.dataTables_scrollBody').find('th').each(function() {

		});
		*/
	</script>

</cf_layout_planner>
