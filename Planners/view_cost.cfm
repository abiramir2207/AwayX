<!-----------------------------------------------------------------------------------------------------------------------------------------
Name         :  /Planners/view_cost.cfm
Created Date :  2016 Oct
Created By   :  Chris Nguyen
Description  :  Display planner product cost

Remarks      :
----------------------------------------------------------------------------------------------------------------------------------------->
<cf_layout-bare jQueryUI_widgets="tooltip" page_title="Cost Calculation">
	<cfsavecontent variable="head_content">
		<cf_include files="/common_files/datatable.css">
		<style>
			body { margin:0; }
			#header {  	font-weight:bold; font-size:12px; padding:6px; margin:0; color:#333; letter-spacing:0.5px;
						height:28px; line-height:28px;
						background-color:#c6e79c;
						background-image: -webkit-linear-gradient(#e9f6da, #c6e79c);
						background-image: -o-linear-gradient(#e9f6da, #c6e79c);
						background-image: linear-gradient(#e9f6da, #c6e79c);
						vertical-align: middle;
						text-align: center;
			}
			#body { margin:20px 20px 40px 20px; }
			table.datagrid { width:75%; margin:0 auto; table-layout:fixed; }
			tr { height: 33px; }
			#footer { text-align: center; }
			.left { text-align:left; }
			.right { text-align:right; }
			.total { font-style:bold; text-align:center; }
		</style>
	</cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
	<cfscript>
		approval_layerd_cost = application.appSettingsGet.get_Setting('Approval_Layered_Costs');

		MarginCostColHeader = [];

		for (index = 1; index lte 6; index++) {
			MarginCostColHeader[index]         = {};
			MarginCostColHeader[index].label   = application.appSettingsGet.get_Setting('MarginCostColHeader' & index);
			MarginCostColHeader[index].deleted = application.appSettingsGet.get_Setting('MarginCostColHeader' & index & '_delete');
			MarginCostColHeader[index].delivery_type = (index gt 2 ? "1" : "all");

			switch (index) {
				case 1: MarginCostColHeader[index].column = "Var_Man_Cost"; break;
				case 2: MarginCostColHeader[index].column = "Fx_Man_Cost"; break;
				case 3: MarginCostColHeader[index].column = "Del_Del_Cost"; break;
				case 4: MarginCostColHeader[index].column = "Del_Cust_Pickup"; break;
				case 5: MarginCostColHeader[index].column = "Del_Var_Warhs"; break;
				case 6: MarginCostColHeader[index].column = "Del_Frt_Cost"; break;
			}
		}
	</cfscript>

	<cfquery name="qProduct" datasource="#application.datasource#">
		SELECT 	Item,
				Description,
				CAST(ISNULL(CS_Curr_Cost,0) AS float) AS CS_Curr_Cost,
				ISNULL(Net_Weight, 0) AS Net_Weight,
				ISNULL(Var_Man_Cost, 0) AS Var_Man_Cost,
				ISNULL(Fx_Man_Cost, 0) AS Fx_Man_Cost,
				ISNULL(Del_Del_Cost, 0) AS Del_Del_Cost,
				ISNULL(Del_Cust_Pickup, 0) AS Del_Cust_Pickup,
				ISNULL(Del_Var_Warhs, 0) AS Del_Var_Warhs,
				ISNULL(Del_Frt_Cost, 0) AS Del_Frt_Cost,
				ISNULL(FOB_Warhs, 0) AS FOB_Warhs,
				ISNULL(FOB_Frt_Cost, 0) AS FOB_Frt_Cost,
				ISNULL((
					SELECT <cfif url.uom eq "C">
								Planner_Margin_Data.Cost_From_Component_CS
							<cfelse>
								Planner_Margin_Data.Cost_From_Component_LB
							</cfif>
					FROM   Planner_Margin_Data
					WHERE  Planner_Margin_Data.Planner_ID =  <cfqueryparam value="#url.plannerID#">
						  AND Planner_Margin_Data.Product_ID = <cfqueryparam value="#url.bsa_foodservice_items_master_id#">
						  AND Planner_Margin_Data.Program_ID = 0
				), 0) AS Component_Cost
		  FROM BSA_Foodservice_Items_Master
		  WHERE bsa_foodservice_items_master_id = <cfqueryparam value="#url.bsa_foodservice_items_master_id#">
	</cfquery>

	<cfoutput>
	<div id="header" class="shadow opaque-m">
		<!--- <span class="opaque-m">#application.returned_customer_setting.item_label#:</span>  --->#qProduct.Item# - #qProduct.Description#
	</div>

	<div id="body">
		<!--- <cfdump var="#MarginCostColHeader#"> --->
		<table class="datagrid">
		<col width="70%">
		<col width="30%">
		<thead>
			<tr>
				<th class="left shadow">Description</th>
				<th style="text-align:right" class=shadow>Value</th>
			</tr>
		</thead>
		<tbody>
			<cfset total_cost = 0>
			<cfif approval_layerd_cost eq 1>   <!--- single cost --->
				<cfset this_cost = url.uom eq 'C' ? qProduct.cs_curr_cost : (qProduct.Net_Weight eq 0 ? 0 : qProduct.cs_curr_cost / qProduct.Net_Weight)>
				<cfset total_cost = total_cost + this_cost>
				<tr>
					<td>Current Cost</td>
					<td class="right">#dollarFormat(this_cost)#</td>
				</tr>

			<cfelseif approval_layerd_cost eq 2>  <!--- multiple costs --->
				<cfloop from="1" to="6" index="index">
					<cfif MarginCostColHeader[index].deleted eq 0
						  and ( url.delivery_type eq MarginCostColHeader[index].delivery_type or MarginCostColHeader[index].delivery_type eq "all" )>
						<cfset this_cost = url.uom eq 'C' ? qProduct[ MarginCostColHeader[index].column ][1] : (qProduct.Net_Weight eq 0 ? 0 : qProduct[ MarginCostColHeader[index].column ][1] / qProduct.Net_Weight)>
						<cfset total_cost = total_cost + this_cost>
						<tr>
							<td>#MarginCostColHeader[index].label#</td>
							<td class="right">#dollarFormat( this_cost )#</td>
						</tr>
					</cfif>
				</cfloop>
				<cfif url.delivery_type eq 2>  <!--- FOB --->
					<cfset total_cost = total_cost + (url.uom eq 'C' ? qProduct.FOB_Frt_Cost : ( qProduct.Net_Weight eq 0 ? 0 : qProduct.FOB_Frt_Cost/qProduct.Net_Weight ) )>
					<tr>
						<td>Freight FOB</td>
						<td class="right">#dollarFormat(url.uom eq 'C' ? qProduct.FOB_Frt_Cost : ( qProduct.Net_Weight eq 0 ? 0 : qProduct.FOB_Frt_Cost/qProduct.Net_Weight ) )#</td>
					</tr>
					<cfset total_cost = total_cost + (url.uom eq 'C' ? qProduct.FOB_Warhs : ( qProduct.Net_Weight eq 0 ? 0 : qProduct.FOB_Warhs/qProduct.Net_Weight ) )>
					<tr>
						<td>Warehouse FOB</td>
						<td class="right">#dollarFormat( url.uom eq 'C' ? qProduct.FOB_Warhs : ( qProduct.Net_Weight eq 0 ? 0 : qProduct.FOB_Warhs/qProduct.Net_Weight ) )#</td>
					</tr>
				</cfif>
			</cfif>
			<tr>
				<cfscript>
					uom_type   = (url.uom eq "C" ? "CS" : "LB");
					url_params = "ItemId=" & url.bsa_foodservice_items_master_id
									& "&plannerID=" & url.plannerID
									& "&type=" & uom_type
									& "&tpa_type=1";
				</cfscript>
				<cfset total_cost = total_cost + qProduct.Component_Cost>
				<td>
					<a href="##" onclick="popupInCenter(&apos;/common_files/contracts/Contract_Trade_Analysis.cfm?#url_params#&apos;, &apos;Component Cost&apos;, 800, 600)">
						<b>Component Cost</b>
					</a>
				</td>
				<td class="right">#dollarFormat( qProduct.Component_Cost )#</td>
			</tr>
		</tbody>
		<tfoot>
			<tr>
				<th class="total shadow">Total Cost</th>
				<th class="right shadow">#dollarFormat( total_cost )#</th>
			</tr>
		</tfoot>
		</table>
	</div>

	<div id="footer">
		<a id=close class="secondary">#application.util.string.linkFormat("close window")#</a>
	</div>
	</cfoutput>

	<script>
		$("#close").click(function(){
			if ( parent.dhx_window_close )
				parent.dhx_window_close();
			else
				window.close();
			// location.reload();
		});
	</script>
</cf_layout-bare>
