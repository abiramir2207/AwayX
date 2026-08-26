<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
Name         :	planner_accruals.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	02/22/2021
Created By   : 	Tim Ford
Description  : 	Planner Accruals
--------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cf_layout_planner>


<cfinclude template="topnav_form.cfm">
    <style>
        .sorting, .sorting_asc, .sorting_desc{cursor: pointer;}
    </style>

    <cfparam name="form.accrualDisplay" default="/Common_Files/contracts/payment_history/accrual_info_fiscal_period_details.cfm" />

    <cfset ContractId = 0 />
    <cfset contractNumber = "" />

    <cfparam name="form.distributorComponentList" default="">

    <cfset objPaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />

    <cfset qGetProgramAccrualData = objPaymentHistoryManager.getProgramAccrualData(contractNumber=contractNumber,contractMainID=ContractId, plannerID=plannerID) />

     <cfloop query="qGetProgramAccrualData.filteredResults">
       
        <cfset form.distributorComponentList = ListAppend(form.distributorComponentList,"#BSA_Foodservice_Customers_ID#_#Component_Name_ID#_#Contract_Number_Key#",",") />
      
     </cfloop>

    <!---<cfinclude template="/Common_Files/contracts/payment_history/program_accrual.cfm">--->
    <cfinclude template="#form.accrualDisplay#">


</cf_layout_planner>