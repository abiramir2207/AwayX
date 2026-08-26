<!---
	Name: Open_Deductions_Inactive_Customers.cfm         
	Copyright (c) 2006 Blacksmith Applications, Inc.       
             
	Description: This file generates a report and emails to email address set in email settings page.
		Create a scheduled job that will email out every night a report for all open deductions with non-active (active != 'A') or deleted  (deleted = 1) customers.
		Create a settings panel in email settings with text area to enter multiple addresses.
		Do not email out the report either if the report is empty or the email field is blank.
	
	Usage:	This is relies on email settings page for the email ID.  
	Tip:	<gotchas>
	
--->
<cfparam name="emailList" default="">

<cfquery name="getAppDDSentRejectIn1510" datasource="#application.datasource#">
	select DD_Sent_Reject_In_1510
	from  _Application_settings
</cfquery>

<cfquery name="getEmail" datasource="#application.datasource#">
	Select	Open_DD_Inactive_Customers_Email_Address 
	from	general_Settings
</cfquery>

<cfset emailList = valuelist(getEmail.Open_DD_Inactive_Customers_Email_Address)>

<!--- Only email if the email field is not empty --->
<cfif len(emailList) GT 0>
	<cfquery name="getOpenDDInactiveCustomers" datasource="#application.datasource#">
		SELECT	DD_DedID, DD_Status.DD_Status_Description, 
				BSA_Foodservice_Customers.ship_to, BSA_Foodservice_Customers.Name
		FROM 	Deductions 
		INNER JOIN BSA_Foodservice_Customers ON Deductions.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID 
		INNER JOIN DD_Status ON Deductions.DD_Status = DD_Status.DD_Status_ID
		WHERE 	DD_Status IN (1,2,3,7,8)
		AND 	(BSA_Foodservice_Customers.Deleted  = 1 OR BSA_Foodservice_Customers.Active_Code != 'A')
		AND		Deductions.Deleted = 0
		<cfif getAppDDSentRejectIn1510.DD_Sent_Reject_In_1510 NEQ 1> AND Deductions.DD_Rejected=0  </cfif> <!--- D48185 --->
		ORDER BY BSA_Foodservice_Customers.Name, DD_Status.DD_Status_Description
	</cfquery>
	
	<cfif getOpenDDInactiveCustomers.recordcount GT 0>
		<cfsavecontent variable="OpenDeductionsInactiveCustomers">
			<html>
				<Title>Open Deductions with Non-Active Customers</Title>
				<Head></Head>
				<Body>
					<TABLE>
						<TR>
							<TH VALIGN="top">Deduction</TH>		<TH>&nbsp;</TH>
							<TH VALIGN="top">Status</TH>		<TH>&nbsp;</TH>
							<TH VALIGN="top">Ship To</TH>		<TH>&nbsp;</TH>
							<TH VALIGN="top">Customer</TH>		<TH>&nbsp;</TH>
						</TR>
						<cfoutput query="getOpenDDInactiveCustomers">
							<TR>
								<TD VALIGN="top">#DD_DedID#</TD>				<TD>&nbsp;</TD>
								<TD VALIGN="top">#DD_Status_Description#</TD>	<TD>&nbsp;</TD>
								<TD VALIGN="top">#ship_to#</TD>					<TD>&nbsp;</TD>
								<TD VALIGN="top">#Name#</TD>					<TD>&nbsp;</TD>
							</TR>
						</cfoutput>
					</TABLE>
				</Body>
			</html>
		</cfsavecontent>
		
		<!--- Loop through the email list --->
		
			<cfloop index="thisEmail" list="#emailList#" delimiters="," >
				<CF_EMAILWRAPPER 
					TO			=	"#thisEmail#"
					FROM		=	"info@bigredflame.com"
					SUBJECT		=	"Open Deductions with Inactive/Deleted Customers"
					TYPE		=	"html" 
					messagetype="1" 
					generatedby="2"
					appArea="1"
				>
					<cfoutput>#OpenDeductionsInactiveCustomers#</cfoutput>
					
				</CF_EMAILWRAPPER>
			</cfloop>
		
	</cfif>
</cfif>
