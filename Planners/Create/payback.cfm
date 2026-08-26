<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
	   File Name:  \planners\create\payback.cfm
	Created Date:  2017 July
	  Created By:  Chris Nguyen
	 Description:  Displays payback periods
--------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cf_layout-bare>
	<style>
		td.numeric {
			text-align: right;
		}
	</style>

	<cfquery name="qPayback" datasource="#application.datasource#">
		SELECT
		    i.BSA_Foodservice_Items_Master_ID,
		    i.Item,
		    i.Description,
		    SUM(m.Slotting_Dollar) AS LS_Amount,
		    SUM(m.Free_Cases) AS Free_Cases,
		    SUM(m.Payback_Period) AS Payback_Period 
		FROM
		    Planner_Margin_Data m 
		    INNER JOIN BSA_Foodservice_Items_Master i ON i.BSA_Foodservice_Items_Master_ID = m.Product_ID 
		WHERE
		    m.Planner_ID = #url.plannerID#
		    AND m.Record_Type = 1 
		    AND m.Slotting = 1 
		GROUP BY
		    i.BSA_Foodservice_Items_Master_ID,
		    i.Item,
		    i.Description		
	</cfquery>

	<cf_include files="/common_files/datatable2.css, /common_files/dataTables2.cfm">

	<table class="dataTable display" width="100%">
		<thead>
			<tr>
				<th style="text-align:left">Item</th>
				<th style="text-align:left">Description</th>
				<th class="center">Lump Sum</th>
				<th class="center">Free Cases</th>
				<th class="center">Payback Period</th>
			</tr>
		</thead>
	</table>

	<cfset dataset = []>
	<cfoutput query="qPayback">
		<cfset arrayAppend(dataset, [	qPayback.Item
										,qPayback.Description
										,dollarFormat( qPayback.Ls_Amount )
										,numberFormat( qPayback.Free_Cases, ",.99" )
										,numberFormat( qPayback.Payback_Period, ",.99" )
									])>
	</cfoutput>
	
	<cfoutput>
	<div style="clear:both;"></div>

	<div style="text-align:center;">
		<a href="##" onclick="parent.dhx_window_close ? parent.dhx_window_close() : window.close();">#application.util.string.linkFormat("close window")#</a>
	</div>
	</cfoutput>

	<script>
		$("table.dataTable").DataTable({	data: <cfoutput>#serializeJSON( dataset )#</cfoutput>,
											columns: [ 	null, 
														null, 
														{ className: "numeric" }, 
														{ className: "numeric" }, 
														{ className: "numeric" } 
													],
											scrollY:        "80vh",
											scrollCollapse: true,
											paging:         false        
		});
	</script>
</cf_layout-bare>