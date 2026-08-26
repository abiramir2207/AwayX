<!----------------------------------------------------------------------------------
Name         :	AwayX/Planners/Templates/planner_template_indirect.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	10/09/2017
Created By   : 	Deepa
Description  : 	Planner Templates
---------------------------------------------------------------------------------->


<cfoutput>
<cfscript>
	param form.Indirect_Product_Source                  = "1" ;
</cfscript>

<cfif qGetPlannerTemplate.RecordCount>
	<cfset form.Indirect_Product_Source    = qGetPlannerTemplate.Indirect_Product_Source />
</cfif>

<table border="0" cellpadding="0" cellspacing="0" id="dataTable" width="40%">
	<tr>
		<th class="h2">
			#sIndirectLabel# Details
		</th>
	</tr>
	<tr>
		<td>
			#sIndirectLabel# Products
		</td>
		<td>
			From #sWholesaleLabel# #Application.PlannerLabel# <input name="Indirect_Product_Source" type="radio" value="1" <cfif form.Indirect_Product_Source eq 1>checked</cfif>>
		</td>
		<td>
			From claim history <input name="Indirect_Product_Source" type="radio" value="2" <cfif form.Indirect_Product_Source eq 2>checked</cfif>>
		</td>
	</tr>
</table>
</cfoutput>
