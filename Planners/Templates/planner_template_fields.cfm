<!----------------------------------------------------------------------------------
Name         :	AwayX/Planners/Templates/planner_template_fields.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	03/01/2016
Created By   : 	KAL
Description  : 	Planner Templates
---------------------------------------------------------------------------------->
<!--- TODO: LIST -------------------------
	- Validation
	- UI Cleanup
	- Add Select all
----------------------------------------->
<style>
    span.uom {
        display: inline-block;
        width: 35px;
    }
</style>
<cfoutput>
<cfscript>
	param form.Actual_Default                  ="0" ;
	param form.Actual_Display                  ="0" ;
	param form.Actual_Percent_Forecast_Default ="0" ;
	param form.Actual_Percent_Forecast_Display ="0" ;
	param form.AOP_Default                     ="0" ;
	param form.AOP_Display                     ="0" ;
	param form.Demand_Plan_Default             ="0" ;
	param form.Demand_Plan_Display             ="0" ;
	param form.Forecast_Default                ="0" ;
	param form.Forecast_Display                ="0" ;
	param form.Locked_Forecast_Default         ="0" ;
	param form.Locked_Forecast_Display         ="0" ;
	param form.Indirect_Volume_Display         ="0" ;
	param form.Indirect_Volume_Default         ="0" ;
	param form.Indirect_Volume_Percent_Forecast_Display         ="0" ;
	param form.Indirect_Volume_Percent_Forecast_Default         ="0" ;
	param form.Forecast_Percent_PY_Default     ="0" ;
	param form.Forecast_Percent_PY_Display     ="0" ;
	param form.Margin_Display                  ="0" ;
	param form.Net_Sales_Display               ="0" ;
	param form.NUC_Display                     ="0" ;
	param form.PY_Summary_Display              ="0" ;
	param form.Prior_Yr_Default                ="0" ;
	param form.Prior_Yr_Display                ="0" ;
	param form.Trade_Display                   ="0" ;
	param form.UOM_CS                          ="0" ;
	param form.UOM_Default                     ="0" ;
	param form.UOM_EA                          ="0" ;
	param form.UOM_LB                          ="0" ;
	param form.Program_Default_UOM			   ="0" ;
	param form.Program_Volume_Default_UOM	   ="1" ;
	param form.YTD_Default                  ="0" ;
	param form.YTD_Display                  ="0" ;
</cfscript>


<cfif qGetPlannerTemplate.RecordCount>
	<cfset form.UOM_LB 							= qGetPlannerTemplate.UOM_LB />
	<cfset form.UOM_CS 							= qGetPlannerTemplate.UOM_CS />
	<cfset form.UOM_EA 							= qGetPlannerTemplate.UOM_EA />
	<cfset form.UOM_Default 					= qGetPlannerTemplate.UOM_Default />
	<cfset form.Net_Sales_Display 				= qGetPlannerTemplate.Net_Sales_Display />
	<cfset form.Trade_Display 					= qGetPlannerTemplate.Trade_Display />
	<cfset form.Margin_Display 					= qGetPlannerTemplate.Margin_Display />
	<cfset form.NUC_Display 					= qGetPlannerTemplate.NUC_Display />
	<cfset form.PY_Summary_Display 				= qGetPlannerTemplate.PY_Summary_Display />
	<cfset form.AOP_Display 					= qGetPlannerTemplate.AOP_Display />
	<cfset form.AOP_Default 					= qGetPlannerTemplate.AOP_Default />
	<cfset form.Demand_Plan_Display 			= qGetPlannerTemplate.Demand_Plan_Display />
	<cfset form.Demand_Plan_Default 			= qGetPlannerTemplate.Demand_Plan_Default />
	<cfset form.Prior_Yr_Display 				= qGetPlannerTemplate.Prior_Yr_Display />
	<cfset form.Prior_Yr_Default 				= qGetPlannerTemplate.Prior_Yr_Default />
	<cfset form.Forecast_Display 				= qGetPlannerTemplate.Forecast_Display />
	<cfset form.Forecast_Default 				= qGetPlannerTemplate.Forecast_Default />
	<cfset form.Forecast_Percent_PY_Display		= qGetPlannerTemplate.Forecast_Percent_PY_Display />
	<cfset form.Forecast_Percent_PY_Default		= qGetPlannerTemplate.Forecast_Percent_PY_Default />
	<cfset form.Actual_Display 					= qGetPlannerTemplate.Actual_Display />
	<cfset form.Actual_Default 					= qGetPlannerTemplate.Actual_Default />
	<cfset form.Actual_Percent_Forecast_Display	= qGetPlannerTemplate.Actual_Percent_Forecast_Display />
	<cfset form.Actual_Percent_Forecast_Default	= qGetPlannerTemplate.Actual_Percent_Forecast_Default />
	<cfset form.Program_Default_UOM				= qGetPlannerTemplate.Program_Default_UOM />
	<cfset form.Locked_Forecast_Default			= qGetPlannerTemplate.Locked_Forecast_Default />
	<cfset form.Locked_Forecast_Display			= qGetPlannerTemplate.Locked_Forecast_Display />

	<cfset form.Indirect_Volume_Display			= qGetPlannerTemplate.Indirect_Volume_Display />
	<cfset form.Indirect_Volume_Default			= qGetPlannerTemplate.Indirect_Volume_Default />
	<cfset form.Indirect_Volume_Percent_Forecast_Display			= qGetPlannerTemplate.Indirect_Volume_Percent_Forecast_Display />
	<cfset form.Indirect_Volume_Percent_Forecast_Default			= qGetPlannerTemplate.Indirect_Volume_Percent_Forecast_Default />
	<cfset form.Program_Volume_Default_UOM							= qGetPlannerTemplate.Program_Volume_Default_UOM />
	<cfset form.YTD_Display			= qGetPlannerTemplate.YTD_Display />
	<cfset form.YTD_Default			= qGetPlannerTemplate.YTD_Default />
</cfif>


<cfset structAppend(url, createObject( "component", "components.udf" ))>

<table border="0" cellpadding="0" cellspacing="0" id="dataTable" width="40%">
	<tr>
		<th class="h2">
			#Application.PlannerLabel# Summary Details
		</th>
	</tr>
	<tr>
		<td>
			UOM
		</td>
		<td>
			<span class="uom">#get_UOM(2).Abbreviation#</span>
            <input name="UOM_LB" type="checkbox" value="1" <cfif form.UOM_LB eq 1>checked</cfif>>
		</td>
		<td>
			<input name="UOM_Default" type="radio" value="2" <cfif form.UOM_Default eq 2>checked</cfif>> (Default)
		</td>
	</tr>
	<tr>
		<td>
		</td>
		<td>
			<span class="uom">#get_UOM(1).Abbreviation#</span>
			<input name="UOM_CS" type="checkbox" value="1" <cfif form.UOM_CS eq 1>checked</cfif>>
		</td>
		<td>
			<input name="UOM_Default" type="radio" value="1" <cfif form.UOM_Default eq 1>checked</cfif>> (Default)
		</td>
	</tr>
	<tr>
		<td>
		</td>
		<td>
            <span class="uom">#get_UOM(5).Abbreviation#</span>
			<input name="UOM_EA" type="checkbox" value="1" <cfif form.UOM_EA eq 1>checked</cfif>>
		</td>
		<td>
			<input name="UOM_Default" type="radio" value="5" <cfif form.UOM_Default eq 5>checked</cfif>> (Default)
		</td>
	</tr>
	<tr>
		<td>
			#Application.PlannerPrgLabel# Default UOM
		</td>
		<td>
			Product UOM <input name="Program_Default_UOM" type="radio" value="1" <cfif form.Program_Default_UOM eq 1>checked</cfif>>
		</td>
		<td>
			#Application.PlannerLabel# Template <input name="Program_Default_UOM" type="radio" value="2" <cfif form.Program_Default_UOM eq 2>checked</cfif>>
		</td>
	</tr>
	<tr>
		<td>
			#Application.PlannerPrgLabel# Volume Default UOM
		</td>
		<td>
			#Application.PlannerLabel#  Template <input name="Program_Volume_Default_UOM" type="radio" value="1" <cfif form.Program_Volume_Default_UOM eq 1>checked</cfif>>
		</td>
		<td>
			#Application.PlannerPrgLabel# Template <input name="Program_Volume_Default_UOM" type="radio" value="2" <cfif form.Program_Volume_Default_UOM eq 2>checked</cfif>>
		</td>
	</tr>
	<tr>
		<td>
			Net Sales
		</td>
		<td>
			<input name="Net_Sales_Display" type="checkbox" value="1" <cfif form.Net_Sales_Display eq 1>checked</cfif>>
		</td>
	</tr>
	<tr>
		<td>
			Trade
		</td>
		<td>
			<input name="Trade_Display" type="checkbox" value="1" <cfif form.Trade_Display eq 1>checked</cfif>>
		</td>
	</tr>
	<tr>
		<td>
			Margin
		</td>
		<td>
			<input name="Margin_Display" type="checkbox" value="1" <cfif form.Margin_Display eq 1>checked</cfif>>
		</td>
	</tr>
	<tr>
		<td>
			NUC
		</td>
		<td>
			<input name="NUC_Display" type="checkbox" value="1" <cfif form.NUC_Display eq 1>checked</cfif>>
		</td>
	</tr>
	<tr>
		<td>
			Last Year - Sales &amp; Trade
		</td>
		<td>
			<input name="PY_Summary_Display" type="checkbox" value="1" <cfif form.PY_Summary_Display eq 1>checked</cfif>>
		</td>
	</tr>
	<tr>
		<th class="h2">Volume page</th>
	</tr>
	<tr>
		<td>&nbsp;

		</td>
		<td>
			<b>Include</b>
		</td>
		<td>
			<b>Default</b>
		</td>
	</tr>
	<tr>
		<td>
			Actual
		</td>
		<td>
			<input name="Actual_Display" type="checkbox" value="1" <cfif form.Actual_Display eq 1>checked</cfif>>
		</td>
		<td>
			<input name="Actual_Default" type="checkbox" value="1" <cfif form.Actual_Default eq 1>checked</cfif>>
		</td>
	</tr>
	<tr>
		<td>
			Actual % FCST
		</td>
		<td>
			<input name="Actual_Percent_Forecast_Display" type="checkbox" value="1" <cfif form.Actual_Percent_Forecast_Display eq 1>checked</cfif>>
		</td>
		<td>
			<input name="Actual_Percent_Forecast_Default" type="checkbox" value="1" <cfif form.Actual_Percent_Forecast_Default eq 1>checked</cfif>>
		</td>
	</tr>
	<tr>
		<td>
			AOP
		</td>
		<td>
			<input name="AOP_Display" type="checkbox" value="1" <cfif form.AOP_Display eq 1>checked</cfif>>
		</td>
		<td>
			<input name="AOP_Default" type="checkbox" value="1" <cfif form.AOP_Default eq 1>checked</cfif>>
		</td>
	</tr>
	<cfif application.appsettingsget.get_Setting('Retail_Demand_Plan_Enabled') eq '1'>
	<tr>
		<td>
			Demand
		</td>
		<td>
			<input name="Demand_Plan_Display" type="checkbox" value="1" <cfif form.Demand_Plan_Display eq 1>checked</cfif>>
		</td>
		<td>
			<input name="Demand_Plan_Default" type="checkbox" value="1" <cfif form.Demand_Plan_Default eq 1>checked</cfif>>
		</td>
	</tr>
	</cfif>
	<tr>
		<td>
			FCST % LY
		</td>
		<td>
			<input name="Forecast_Percent_PY_Display" type="checkbox" value="1" <cfif form.Forecast_Percent_PY_Display eq 1>checked</cfif>>
		</td>
		<td>
			<input name="Forecast_Percent_PY_Default" type="checkbox" value="1" <cfif form.Forecast_Percent_PY_Default eq 1>checked</cfif>>
		</td>
	</tr>
    <cfif form.Wholesaler_Planner>
	<tr>
		<td>
			#sIndirectLabel# Volume
		</td>
		<td>
			<input name="Indirect_Volume_Display" type="checkbox" value="1" class="whlsPlannerSwith" <cfif form.Indirect_Volume_Display eq 1>checked</cfif>>
		</td>
		<td>
			<input name="Indirect_Volume_Default" type="checkbox" value="1" class="whlsPlannerSwith" <cfif form.Indirect_Volume_Default eq 1>checked</cfif>>
		</td>
	</tr>
	<tr>
		<td>
			#sIndirectLabel# % FCST
		</td>
		<td>
			<input name="Indirect_Volume_Percent_Forecast_Display" type="checkbox" value="1" class="whlsPlannerSwith" <cfif form.Indirect_Volume_Percent_Forecast_Display eq 1>checked</cfif>>
		</td>
		<td>
			<input name="Indirect_Volume_Percent_Forecast_Default" type="checkbox" value="1" class="whlsPlannerSwith" <cfif form.Indirect_Volume_Percent_Forecast_Default eq 1>checked</cfif>>
		</td>
	</tr>
    </cfif>
	<tr>
		<td>
			Last Year
		</td>
		<td>
			<input name="Prior_Yr_Display" type="checkbox" value="1" <cfif form.Prior_Yr_Display eq 1>checked</cfif>>
		</td>
		<td>
			<input name="Prior_Yr_Default" type="checkbox" value="1" <cfif form.Prior_Yr_Default eq 1>checked</cfif>>
		</td>
	</tr>
	<tr>
		<td>
			Latest Forecast
		</td>
		<td>
			<input name="Forecast_Display" type="checkbox" value="1" <cfif form.Forecast_Display eq 1>checked</cfif>>
		</td>
		<td>
			<input name="Forecast_Default" type="checkbox" value="1" <cfif form.Forecast_Default eq 1>checked</cfif>>
		</td>
	</tr>
	<tr>
		<td>
			Locked Forecast
		</td>
		<td>
			<input name="Locked_Forecast_Display" type="checkbox" value="1" <cfif form.Locked_Forecast_Display eq 1>checked</cfif>>
		</td>
		<td>
			<input name="Locked_Forecast_Default" type="checkbox" value="1" <cfif form.Locked_Forecast_Default eq 1>checked</cfif>>
		</td>
	</tr>
	<tr>
		<td>
			YTD
		</td>
		<td>
			<input name="YTD_Display" type="checkbox" value="1" <cfif form.YTD_Display eq 1>checked</cfif>>
		</td>
		<td>
			<input name="YTD_Default" type="checkbox" value="1" <cfif form.YTD_Default eq 1>checked</cfif>>
		</td>
	</tr>
</table>
</cfoutput>
