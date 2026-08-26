<cfset Email_To_Test_address = "bflynn@bigredflame.com">
<cfset Send_Email_To_Test_address = 0>

<!---Gets correct "From" address--->
<cfinclude template="/get_Contact_Admin_Email_Address.cfm">

<!---TSF - Label 12527: Changed query to use Company_Main_ID FROM Company_Main instead of hard coded value--->
<cfquery name="getExpirationTime" datasource="#application.datasource#">
	SELECT	Contract_Expiration_Range,User_ID
	FROM	_Users_Settings
	WHERE	User_ID = (SELECT Company_Main_ID FROM Company_Main WHERE Deleted = 0)
</cfquery>

<cfset Contract_Expiration_Range = getExpirationTime.Contract_Expiration_Range>

<cfif not isnumeric(Contract_Expiration_Range)>
	<!--- there is a program misconfiguration, put email code to admin here --->
	<cfabort>
<cfelse>
	<!--- <cfset ExpirationDate = dateformat(DateAdd('ww', Contract_Expiration_Range, Now()), 'm/d/yyyy')> --->

<cfset ExpirationDate = dateformat(Now(), 'mm/dd/yyyy')>
	<cfquery name="getPendingPrograms" datasource="#application.datasource#">
		SELECT Contract_Main.Contract_Main_ID, Contract_Main.Creator_ID, Contract_Main.Contract_Number, Contract_Main.Creating_User_Position_ID,
				datediff(day, getdate(), contract_start_date) as no_of_days, contract_title,
				Contract_Main.Business_Segment_ID, Contract_Main.Responsible_User_ID, Contract_Main.ProgramType_ID
		FROM    Contract_Main
				INNER JOIN	Contract_Main_Aux_Data
				ON Contract_Main.Contract_Main_ID = Contract_Main_Aux_Data.Contract_Main_ID
				<cfif getGSettings.Use_Discount_ID EQ 1><!---BJF D9361 this has resulted in applications that do not use discount identifiers getting no notifications of expiration --->
			INNER JOIN	Program_Control_Panel_Options
			ON (Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID)
			inner join Discount_Identifier on Discount_Identifier.Discount_Identifier_ID = Program_Control_Panel_Options.Discount_Identifier_ID
</cfif>
		WHERE
				Contract_Main.Deleted = 0
				AND
				Contract_Main_Aux_Data.Pending_Status_Email_Sent = 0 --only select programs which havent had this email sent already
				AND
				Contract_Main.Contract_Status_Type_IDX = 10 -- automated process flagged this program as pending
				<cfif Listlen(appSettings.getpricingtemplatelist()) GT 0 AND getGSettings.Use_Discount_ID EQ 1>
				AND Discount_Identifier.Discount_Identifier_Desc NOT IN  (#ListQualify(appSettings.getpricingtemplatelist(), "'" , ",", "ALL")#)
				</cfif>
				And datediff(day, getdate(), contract_start_date) < #getGSettings.Number_Of_Days_For_Program_Start#
	</cfquery>

	<cfloop query="getPendingPrograms">
		<cfset pp.cid = getPendingPrograms.Contract_Main_ID>
		<cfset numDays = no_of_days />
		<cfif appSettings.getSendAutoAttachments() and appSettings.getDisplayQuoteLetter() eq 0>    <!--- 30738 --->
			<CFSET CSL_Contract_Main_ID = getPendingPrograms.Contract_Main_ID>
			<cfset commonqueries_Called = 0 />
			<CFINCLUDE template="\common_files\contracts\commonqueries.cfm">
			<cfsavecontent variable = "EmailContents">
				<CFINCLUDE TEMPLATE="\common_files\contracts\thin_contract_general_display.cfm">
			</cfsavecontent>
		<CFELSE>
			<cfsavecontent variable="EmailContents">
				<cfinclude template="\templates\email\pending_program.cfm">
			</cfsavecontent>
		</CFIF>
		<cfoutput>#EmailContents#</cfoutput>

		<cfset Contract_Business_Segment_ID = Business_Segment_ID>
		<cfset Contract_Responsible_User_ID = Responsible_User_ID>
		<cfset Contract_Template_ID 		= ProgramType_ID>

		<!--- cfinclude template="get_user_position_contact.cfm" / --->

		<cfquery name="userPositionContactInfo" datasource="#application.datasource#">
         Select User_Email
		 From _Users
		 where User_ID = <cfqueryparam cfsqltype="cf_sql_char" value="#getPendingPrograms.Creator_ID#" />
		 and deleted = 0<!--- D38514: Email Notifications -inactivated user T Eckstein --->
		</cfquery>
<!--- D38514: Email Notifications -inactivated user T Eckstein START--->
<cfif userPositionContactInfo.recordcount EQ 0 AND (getPendingPrograms.Creator_ID NEQ getPendingPrograms.Responsible_User_ID)>
			<cfquery name="userPositionContactInfo" datasource="#application.datasource#">
			 		Select User_Email
					 From _Users
					 where User_ID = <cfqueryparam cfsqltype="cf_sql_char" value="#getPendingPrograms.Responsible_User_ID#" />
					 and deleted = 0
			</cfquery>
</cfif>
<!--- D38514: Email Notifications -inactivated user T Eckstein END--->

		<!--- html output for task output--->
		<table align="center">
			<TR>
				<TD align="center">recipients</TD>
			</TR>
			<tr>
				<TD align="center">
					<cfdump var="#userPositionContactInfo#">
				</TD>
			</tr>
		</table>
		<hr>
		<!--- html output for task output--->
		<cfset thisContractNumber = getPendingPrograms.Contract_Number>
		<cfset Contract_Title = getPendingPrograms.Contract_Title>

		<!--- prevent problem in including this template more than once --->
		<cfif not (isDefined("EmailSubject") and isCustomFunction(EmailSubject))>
			<cfinclude template="/Common_Files/Programs/emailsubject.cfm"/>   <!--- 30738 --->
		</cfif>

		<cfloop query="userPositionContactInfo">
			<cfset finalEmailAddress = userPositionContactInfo.User_Email>

			<cfif Send_Email_To_Test_address EQ 1>
				<cfset finalEmailAddress = Email_To_Test_address>
			</cfif>

			<!--- <cfmail to="#finalEmailAddress#" from="awayXNotificationService@awayx.com" subject="Program #thisContractNumber# Expiration Notification" type="HTML">#EmailContents#</cfmail> --->
			<cfoutput>
			<cf_EmailWrapper
				to="#finalEmailAddress#"
				from="#Contact_Admin_Email_Address#"
				subject="#EmailSubject(	getPendingPrograms.Contract_Number       <!--- 30738 --->
			        									,getPendingPrograms.Contract_Title
			        									,'in Pending status')#"
				type="HTML"
				messagetype="1"
				generatedby="1"
				apparea="1">


				<cfif appSettings.getSendAutoAttachments() and appSettings.getDisplayQuoteLetter() eq 0>    <!--- 30738 --->
				Program Starting in Pending Status<br>
				Please be advised this program starts in #numDays# days.
						<CF_Writing_Email_Attachment
  				Naming_Format="Program_#Contract_Title#"
				File_Extension="html"
				Relative_Path="\Temp_Files\Program\"
				Output_Content="#EmailContents#"
				addNewLine="No"
				Return_File_Name="fName">
						<cf_emailwrapperparam file = "#fName#" store="yes" />
			<CFELSE>
				#EmailContents#
				</cfif>
			</cf_EmailWrapper>
			</cfoutput>
			<!--- record that email was sent --->
		</cfloop>

		<cfquery name="recordemailstatus" datasource="#application.datasource#">
			UPDATE
				Contract_Main_Aux_Data
			SET
				Pending_Status_Email_Sent = 1
			WHERE
				Contract_Main_ID = <cfqueryparam value="#pp.cid#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

	</cfloop>

	 <!--- APPLICATION ADMIN SUMMARY EMAIL --->
	<cfset pp.cid = valuelist(getPendingPrograms.Contract_Main_ID)>
	<cfif listlen(pp.cid) GT 0>
		<cfquery name="getContactPerson" datasource="#application.datasource#">
			SELECT     User_Email, Name_First, Name_Last
			FROM         dbo._Users
			WHERE     (Is_System_Administrator = 1)
			AND 	   Deleted = 0
		</cfquery>

		<cfsavecontent variable="EmailContents">
			<cfinclude template="\templates\email\pending_program.cfm">
		</cfsavecontent>

		<cfloop query="getContactPerson">
			<cfset finalEmailAddress = getContactPerson.User_Email>

			<cfif Send_Email_To_Test_address EQ 1>
				<cfset finalEmailAddress = Email_To_Test_address>
			</cfif>

			<!--- <cfmail to="#finalEmailAddress#" from="awayXNotificationService@awayx.com" subject="Program Expiration Notification (ADMINISTRATOR SUMMARY)" type="HTML">#EmailContents#</cfmail> --->
			<cfoutput>
			<cf_EmailWrapper
				to="#finalEmailAddress#"
				from="#Contact_Admin_Email_Address#"
				subject="Program Starting in Pending Status (ADMINISTRATOR SUMMARY)"
				type="HTML"
				messagetype="1"
				generatedby="1"
				apparea="1">

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
					<!--- <cfdump var="#userPositionContactInfo#"> --->
				</TD>
			</tr>
		</table>
		<hr>
	</cfif>
</cfif>