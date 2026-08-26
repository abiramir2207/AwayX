<cfset Email_To_Test_address = "bflynn@bigredflame.com">
<cfset Send_Email_To_Test_address = 0>

<!---Gets correct "From" address--->
<cfinclude template="/get_Contact_Admin_Email_Address.cfm">

<cfquery name="getBBAgedate" datasource="#application.datasource#">
SELECT     BB_Danger_Range
FROM         dbo.Billback_Settings
</cfquery>

<cfset Billback_Danger_Range = getBBAgedate.BB_Danger_Range>

<cfif not isnumeric(Billback_Danger_Range)>
	<!--- there is a program misconfiguration, put email code to admin here --->
	<cfabort>
<cfelse>

	<cfquery name="getBillbacks" datasource="#application.datasource#">
		SELECT     
			Billback_ID, BB_Title, BB_Creator_User_Position_ID, BB_Code
		FROM
			dbo.Billback
		WHERE
				Deleted = 0
			AND 
				Age_Email_Sent = 0
			AND 
				DateDiff(day,BB_Date,getdate()) >= <cfqueryparam value="#trim(numberformat(getBBAgedate.BB_Danger_Range, '_____________'))#" cfsqltype="CF_SQL_INTEGER"> 
			AND
				Billback_Status_ID <= 2
		ORDER BY BB_CODE			
	</cfquery>

	<cfloop query="getBillbacks">
		<cfset db.bbid = getBillbacks.Billback_ID>
		<cfsavecontent variable="EmailContents">
			<cfinclude template="\templates\email\danger_of_deduction_billbacks.cfm">
		</cfsavecontent>
		
		<cfoutput>#EmailContents#</cfoutput>
		
		<cfset ContactUserPositionID = getBillbacks.BB_Creator_User_Position_ID />
		<cfinclude template="get_user_position_contact_bb.cfm">
		
		<!--- html output for task output--->
		<table align="center">
			<TR>
				<TD align="center">recipients</TD>
			</TR>
			<tr>
				<TD align="center">
					<cfdump var="#userPositionContactInfoBB#">
				</TD>
			</tr>
		</table>
		<hr>
		<!--- html output for task output--->
		<cfset thisBBCode = getBillbacks.BB_Code>

		<cfloop query="userPositionContactInfoBB">
			<cfset finalEmailAddress = userPositionContactInfoBB.User_Email>

			<cfif Send_Email_To_Test_address EQ 1>
				<cfset finalEmailAddress = Email_To_Test_address>
			</cfif>


				<cfoutput>
				<cf_EmailWrapper 
					to="#finalEmailAddress#" 
					from="#Contact_Admin_Email_Address#" 
					subject="Payable #thisBBCode# is in danger of being deducted" 
					type="HTML" 
					messagetype="1" 
					generatedby="1" 
					apparea="3">
					
				#EmailContents#
				<!--- </cfmail> --->
				</cf_EmailWrapper>
				</cfoutput>
			<!--- record that email was sent --->
		</cfloop>
		
 		<cfquery name="recordemailstatus" datasource="#application.datasource#">
			UPDATE
				Billback
			SET
				Age_Email_Sent = 1
			WHERE
				Billback_ID = #preservesinglequotes(db.bbid)#
		</cfquery>	
	</cfloop>
	
	<!--- APPLICATION ADMIN SUMMARY EMAIL --->
	<cfset db.bbid = valuelist(getBillbacks.Billback_ID)>
	<cfif listlen(db.bbid) GT 0>
		<cfquery name="getContactPerson" datasource="#application.datasource#">
			SELECT     User_Email, Name_First, Name_Last
			FROM         dbo._Users
			WHERE     (Is_System_Administrator = 1)
			AND 	   Deleted = 0
		</cfquery>
		
		<cfsavecontent variable="EmailContents">
			<cfinclude template="\templates\email\danger_of_deduction_billbacks.cfm">
		</cfsavecontent>	
		
		<cfloop query="getContactPerson">
			<cfset finalEmailAddress = getContactPerson.User_Email>
	
			<cfif Send_Email_To_Test_address EQ 1>
				<cfset finalEmailAddress = Email_To_Test_address>
			</cfif>
	
<!--- 			<cfmail to="#finalEmailAddress#" 
					from="awayXNotificationService@awayx.com" 
					subject="Payable in danger of being deducted (ADMINISTRATOR VERSION)" 
					type="HTML">
				
				#EmailContents#
			
			</cfmail> --->
			<cfoutput>
			<cf_EmailWrapper 
				to="#finalEmailAddress#" 
				from="BlacksmithApplicationsNotificationService@#application.CompanyEmailSuffix#" 
				subject="Payable in danger of being deducted (ADMINISTRATOR VERSION)" 
				type="HTML"
				messagetype="1" 
				generatedby="1" 
				apparea="3">
				
				#EmailContents#
				
			</cf_EmailWrapper>
			</cfoutput>
		</cfloop>
		
		<cfoutput>#EmailContents#</cfoutput>
		<!--- html output for task output--->
		<table align="center">
			<TR>
				<TD align="center">recipients of admin summary version</TD>
			</TR>
			<tr>
				<TD align="center">
					<cfdump var="#getContactPerson#">
				</TD>
			</tr>
		</table>
		<hr>
	</cfif>
</cfif>

