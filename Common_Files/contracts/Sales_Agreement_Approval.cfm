<cfparam name="CID" default="">
<cfparam name="Export_Sales_Agreement_ID" default="">
<cfparam name="Status_ID" default="">

<cf_cryp type="de" key="#request.key#" string="#CID#">

<cfif len(CID) NEQ 0>
<cfset Export_Sales_Agreement_ID = cryp.value>
</cfif>

<cfset Agreement_Manager = CreateObject("component","components.Export.Sales_Agreement") />

<!--- Change the program into "Work in Progess" status --->
<cfif Status_ID eq 1>
	<cfset Agreement_Manager.MakeWIP(Export_Sales_Agreement_ID,request.AccessStructure.User_ID)>
<!--- Change the program into "Request for Approval" status --->
<cfelseif Status_ID eq 2>
	<cfset Agreement_Manager.MakeRFA(Export_Sales_Agreement_ID,request.AccessStructure.User_ID)>
	<cfinclude template="/anything_automated/email/sales_agreement_rfa_emailer.cfm">	
<!--- Change the program into "Approved" status --->
<cfelseif Status_ID eq 3>
	<cfset Agreement_Manager.ApproveAgreement(Export_Sales_Agreement_ID,request.AccessStructure.User_ID)>
	<cfinclude template="sales_agreement_generate_approve_email.cfm">
</cfif>

<CF_CRYP type="en" string="#Export_Sales_Agreement_ID#" key="#request.key#">

<cflocation url="Sales_Agreement_Edit_Menu.cfm?CID=#cryp.value#">

<cfsetting showdebugoutput="true">
