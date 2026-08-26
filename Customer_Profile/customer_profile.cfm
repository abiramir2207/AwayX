<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<!----------------------------------------------------------------------
Created on 3/7/2019 by Deepa Kunnath
WR: 83860 Sugar:  Customer Profile
---------------------------------------------------------------------->


<!----------------------------------------------------------------------
Validate the arguments
Sample: 
CustNum=0200013872_X
CustNum=0140124725_X
---------------------------------------------------------------------->
<cfset local.InvalidRequest = 0 />
<cfset local.InvalidMessage = "" />
<cfset local.RequestCustomer = "" />
<cfset local.RequestCustomerType = "" />
	
<cfif local.InvalidRequest eq 0>
<cfif NOT isDefined("URL.CustNum")>
	<cfset local.InvalidRequest = 1 />
	<cfset local.InvalidMessage = "Invalid request parameter" />
</cfif>
</cfif>

<cfif local.InvalidRequest eq 0>
<cfif URL.CustNum EQ "">
	<cfset local.InvalidRequest = 1 />
	<cfset local.InvalidMessage = "Invalid request parameter" />
</cfif>
</cfif>
	
<cfif local.InvalidRequest eq 0>
	<!--- Check if the value is a valid distributor --->
	<CFQUERY NAME="qGetDistributor" datasource="#application.datasource#">
		SELECT	c.BSA_Foodservice_Customers_ID
		FROM	BSA_Foodservice_Customers c
		WHERE	c.Shr_Ship_To = <cfqueryparam value="#URL.CustNum#" cfsqltype="CF_SQL_VARCHAR">
		AND		c.Ship_To != 'Group'
		AND		c.Deleted = 0
	</CFQUERY>
	
	<cfif qGetDistributor.recordCount>
		<cfset local.RequestCustomer = URL.CustNum />
		<cfset local.RequestCustomerType = "D" />
	<cfelse>
		<!--- Check if the value is a valid operator --->
		<CFQUERY NAME="qGetOperator" datasource="#application.datasource#">
			SELECT	o.BSA_Operator_ID
			FROM	BSA_Operator o
			WHERE	o.Legacy_ID = <cfqueryparam value="#URL.CustNum#" cfsqltype="CF_SQL_VARCHAR">
			AND		o.Display_Code = 'A'
		</CFQUERY>
		<cfif qGetOperator.recordCount>
			<cfset local.RequestCustomer = URL.CustNum />
			<cfset local.RequestCustomerType = "O" />
		<cfelse>
			<cfset local.InvalidRequest = 1 />
			<cfset local.InvalidMessage = "Customer not found" />
		</cfif>
	</cfif>
		
</cfif>

<cfif local.InvalidRequest eq 1>
	<cfoutput><center>#local.InvalidMessage#</center></cfoutput>
	<cfabort>
</cfif>

<!----------------------------------------------------------------------
Login the user
---------------------------------------------------------------------->
<cfset Form.External_Customer_Profile_Access = 1 />
<cfset Form.External_Customer_Profile_Access_CustNum = local.RequestCustomer />
<cfset Form.External_Customer_Profile_Access_CustType = local.RequestCustomerType />

<cfinclude template = "/process_login.cfm" />

<!----------------------------------------------------------------------
Build CPAccess
---------------------------------------------------------------------->
<CF_CRYP type="en" string="#local.RequestCustomer#" key="#Session.SessionID#">
<cfset CPAccess = cryp.value>

<!----------------------------------------------------------------------
Relocate:
Every page accessed by Customer Profile Viewer will need below,
URL.CPAccess will need to be passed in, URL.CPAccess will be used in Application_Common.cfm
Page need to be added to CustomerProfileTrustList in Application_Common.cfm 
---------------------------------------------------------------------->
<cfoutput>
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
	window.location.href = '<CFOUTPUT>#HTTPVariable#//#CGI.HTTP_HOST#</CFOUTPUT>/Programs/Program_Search.cfm?CPAccess=#CPAccess#';
</SCRIPT>
</cfoutput>

