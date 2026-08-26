<cfset billbackDevManager = CreateObject("component", "components.billback.BillbackDeviationManager") />
<cfset qDistributorId = billbackDevManager.getBillbackDistributorList(url.Billback_ID) />
<cfsetting showdebugoutput="false">
<cfcontent reset="true"><cfloop query="qDistributorId"><cfset qDistributorInfo = billbackDevManager.getDistributorInfo(qDistributorId.BSA_FOODSERVICE_CUSTOMERS_ID) /><cfoutput>#qDistributorInfo.Ship_To##Chr(10)#</cfoutput></cfloop>