<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
Name         :	planner_spent.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	04/14/2021
Created By   : 	Deepa Kunnath
Description  : 	Planner Spent
--------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cf_layout_planner>


<cfinclude template="topnav_form.cfm">

    <cfset ContractId = 0 />
    <cfset contractNumber = "" /> 
    
    <cfinclude template="/Common_Files/contracts/view_contract_payment_history.cfm">

</cf_layout_planner>