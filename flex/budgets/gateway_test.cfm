<cfset gateway = createobject("component","flex.budgets.components.budget_detail_finalgateway") />

<cfset listofBudgets = gateway.getAllAsQuery(2,1)/>

<cfset secondlistofBudgets = gateway.getAllAsQuery(2,2,'AWG')/>

<p>
<cfoutput query="listofBudgets">#currentRow# -  #control_level_1_name#, #level_value# <br></cfoutput>
</p>

<p style="backgroundcolor: RGB(210,210,255);">
<cfoutput query="secondlistofBudgets">#currentRow# -  #control_level_2_name#, #level_value# <br></cfoutput>
</p>