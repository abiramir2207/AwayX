<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
	<head>
		<title>Price condition and ZDeal - Sent and Acked Report</title>
	</head>
	<body>

		<cfparam name="ACCESSSTRUCTURE.USER_ID" default="0000000000">
		<cfparam name="to_address" default="kcullom@bigredflame.com">
		<cfparam name="from_address" default="support@bigredflame.com">

		<cfquery name="getEmail" datasource="#application.datasource#">
			SELECT send_Program_Error_Ack_emailaddress,
				Use_Different_From_Address,
				Different_From_Address
			FROM _Application_Settings
		</cfquery>
		<cfset to_address = "#getEmail.send_Program_Error_Ack_emailaddress#" />
		<cfif Len(getEmail.Use_Different_From_Address)>
			<cfset from_address = "#getEmail.Different_From_Address#" />
		</cfif>


		<cfquery name="Partial_Ack" datasource="#Application.Datasource#">
			SELECT Contract_main_ID,
				Contract_Number,
				Revision_version,
				CASE
					WHEN
					(
						Discount_Identifier.Discount_Identifier_Number = 'ZDis'
						OR Discount_Identifier.Discount_Identifier_Number = 'ZNet'
					) THEN
						'Price_Condition'
					ELSE
						'ZDeal'
				END Program_Type,
				REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(CHAR(24), Approval_Date, 121), '-', ''), ' ', ''), ':', ''), '.', '') Approval_Date
			FROM Contract_main
				INNER JOIN Program_Control_Panel_Options
					ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
				INNER JOIN Discount_Identifier
					ON Discount_Identifier.Discount_Identifier_ID = Program_Control_Panel_Options.Discount_Identifier_ID
			/* AND Discount_Identifier.Discount_Identifier_Number IN ('ZDis','ZNet') */
			WHERE External_Client_Error_Ack_Date IS NOT NULL
				AND Contract_main.Deleted = 0
				AND Manual_Cancel = 0
			ORDER BY Program_Type,
					Contract_number
		</cfquery>

		<cfquery name="Sent_Not_Acked" datasource="#Application.Datasource#">
			SELECT Contract_main_ID,
				Contract_Number,
				Revision_version,
				CASE
					WHEN
					(
						Discount_Identifier.Discount_Identifier_Number = 'ZDis'
						OR Discount_Identifier.Discount_Identifier_Number = 'ZNet'
					) THEN
						'Price_Condition'
					ELSE
						'ZDeal'
				END Program_Type,
				REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(CHAR(24), Approval_Date, 121), '-', ''), ' ', ''), ':', ''), '.', '') Approval_Date
			FROM Contract_main
				INNER JOIN Program_Control_Panel_Options
					ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
				INNER JOIN Discount_Identifier
					ON Discount_Identifier.Discount_Identifier_ID = Program_Control_Panel_Options.Discount_Identifier_ID
			/* AND Discount_Identifier.Discount_Identifier_Number IN ('ZDis','ZNet') */
			WHERE Sending_To_External_Client = 1
				AND Contract_main.Deleted = 0
				AND Manual_Cancel = 0
			ORDER BY Program_Type,
					Contract_number
		</cfquery>

		<style>
			table.maintable td { border-bottom:solid #93BEE2 1px; font-size : 12px; }
		</style>

		<!--- Dev Notes: Ana - 13048 - Sent the notification after an hour from the extract time --->
		<cfset Any_Data_To_Email = 0>
		<cfoutput>

			<!--- Sent Not Acked --->
			<cfsavecontent variable="Sent_Not_Acked_Disp">
				<style>
					table.maintable td { border-bottom: solid ##93BEE2 1px; font-size: 12px; }
				</style>

				<table class="maintable" cellpadding="1" cellspacing="0" border="0" align="center">
					<tr>
						<td colspan="100%" align="Center" style="font-size : 14px"><b>Sent Not Acknowledged</b></td>
					</tr>
					<tr bgcolor="FFE083">
						<td><b>Program Number</b>&nbsp;&nbsp;</td>
						<td><b>Revision</b>&nbsp;&nbsp;</td>
						<td><b>Program Type</b>&nbsp;&nbsp;</td>
						<td><b>Approved Date</b>&nbsp;&nbsp;</td>
						<td><b>File Name</b></td>
					</tr>
					<cfloop query="Sent_Not_Acked">
						<tr bgcolor="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
							<td>#Contract_Number#&nbsp;&nbsp;</td>
							<td>#Revision_version#&nbsp;&nbsp;</td>
							<td>#Program_Type#&nbsp;&nbsp;</td>
							<td>#Approval_Date#&nbsp;&nbsp;</td>
							<cfif Program_Type EQ "Price_Condition">
								<cfquery name="Extract_File_Name" datasource="#Application.Datasource#">
									SELECT 'Price_Condition_' + Program_Number + '_' + CAST(Forge_ERP_OffInvoice_Log_ID AS VARCHAR) + '_'
										+ REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(CHAR(24), Created_Date, 121), '-', ''), ' ', ''), ':', ''), '.', '')
										+ '.txt' AS File_name
									FROM Forge_ERP_OffInvoice_Log
									WHERE Program_ID = #Contract_Main_ID#
										AND Sent_On IS NOT NULL
										AND Mode <> 'N'
										AND Mode IS NOT NULL
										AND DATEDIFF(hh, Sent_On, GETDATE()) > 1
								</cfquery>
							<cfelse>
								<cfquery name="Extract_File_Name" datasource="#Application.Datasource#">
									SELECT CASE
											WHEN Mode <> 'I' THEN
												Deal_Change_File_Name
											ELSE
												Deal_Create_File_Name
										END File_Name
									FROM Program_ZDeal_Header
									WHERE Contract_main_ID = #Contract_Main_ID#
										AND Mode <> 'N'
										AND Mode IS NOT NULL
										AND
										(
											Deal_Change_File_Name IS NOT NULL
											OR Deal_Create_File_Name IS NOT NULL
										)
										AND DATEDIFF(hh, Created_Date, GETDATE()) > 1
								</cfquery>
							</cfif>
							<cfif Extract_File_Name.RecordCount GT 0 AND Any_Data_To_Email EQ 0>
								<cfset Any_Data_To_Email = 1>
							</cfif>
							<td>
								<cfloop query="extract_File_Name">#File_Name#<cfif CurrentRow NEQ RecordCount><BR></cfif></cfloop>&nbsp;&nbsp;
							</td>
						</tr>
					</cfloop>
				</table>
			</cfsavecontent>

			<!--- Partially Acked --->
			<cfsavecontent variable="Partially_Acked">
				<style>
					table.maintable td { border-bottom: solid ##93BEE2 1px; font-size: 12px; }
				</style>
				<table class= "maintable" cellpadding="1" cellspacing="0" border="0" align="center">
					<tr>
						<td colspan="100%" align="Center" style="font-size : 14px"><b>Partically Acknowledged</b></td>
					</tr>
					<tr bgcolor="FFE083">
						<td><b>Program Number</b>&nbsp;&nbsp;</td>
						<td><b>Revision</b>&nbsp;&nbsp;</td>
						<td><b>Program Type</b>&nbsp;&nbsp;</td>
						<td><b>Approved Date</b>&nbsp;&nbsp;</td>
						<td><b>File Name (Deal ID)</b></td>
					</tr>
					<cfloop query = "Partial_Ack">
						<tr bgcolor="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
							<td>#Contract_Number#&nbsp;&nbsp;</td>
							<td>#Revision_version#&nbsp;&nbsp;</td>
							<td>#Program_Type#&nbsp;&nbsp;</td>
							<td>#Approval_Date#&nbsp;&nbsp;</td>
							<cfif Program_Type EQ "Price_Condition">
								<cfquery name="Extract_File_Name" datasource="#Application.Datasource#">
									SELECT 'Price_Condition_' + Program_Number + '_' + CAST(Forge_ERP_OffInvoice_Log_ID AS VARCHAR) + '_'
										+ REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(CHAR(24), Created_Date, 121), '-', ''), ' ', ''), ':', ''), '.', '')
										+ '.txt' AS File_name,
										External_Client_ID
									FROM Forge_ERP_OffInvoice_Log
									WHERE Program_ID = #Contract_Main_ID#
										AND Sent_On IS NOT NULL
										AND Mode <> 'N'
										AND Mode IS NOT NULL
										AND DATEDIFF(hh, Sent_On, GETDATE()) > 1
								</cfquery>
							<cfelse>
								<cfquery name="Extract_File_Name" datasource="#Application.Datasource#">
									SELECT CASE
											WHEN Mode <> 'I' THEN
												Deal_Change_File_Name
											ELSE
												Deal_Create_File_Name
										END File_Name,
										External_Deal_ID External_Client_ID
									FROM Program_ZDeal_Header
									WHERE Contract_main_ID = #Contract_Main_ID#
										AND Mode <> 'N'
										AND Mode IS NOT NULL
										AND
										(
											Deal_Change_File_Name IS NOT NULL
											OR Deal_Create_File_Name IS NOT NULL
										)
										AND DATEDIFF(hh, Created_Date, GETDATE()) > 1
								</cfquery>
							</cfif>
							<cfif Extract_File_Name.RecordCount GT 0 AND Any_Data_To_Email EQ 0>
								<cfset Any_Data_To_Email = 1>
							</cfif>
							<td>
								<cfloop query="extract_File_Name">#File_Name# (#External_Client_ID#)<cfif CurrentRow NEQ RecordCount><BR></cfif></cfloop>&nbsp;&nbsp;
							</td>
						</tr>
					</cfloop>
				</table>
			</cfsavecontent>

			<cfset DateTimeStamp = "#DATEFORMAT(now(),"mm/dd/yyyy")##TIMEFORMAT(now(),"HH:mm:ss")#">
			<cfset DateTimeStamp = REPLACE(DateTimeStamp,"/","","ALL")>
			<cfset DateTimeStamp = REPLACE(DateTimeStamp,":","","ALL")>
			<cf_writing_email_attachment
				Naming_Format="Sent_Not_Acked_#DateTimeStamp#"
				File_Extension="html"
				Relative_Path="\Temp_Files\Program\"
				Output_Content="#Sent_Not_Acked_Disp#"
				addNewLine="No"
				Return_File_Name="fName1">

			<cf_writing_email_attachment
				Naming_Format="Partially_Acked_#DateTimeStamp#"
				File_Extension="html"
				Relative_Path="\Temp_Files\Program\"
				Output_Content="#Partially_Acked#"
				addNewLine="No"
				Return_File_Name="fName2">

			<cfif Any_Data_To_Email GT 0>
				<cf_EmailWrapper
				TO = "#to_address#"	<!--- baAckReport@fosterfarms.com --->
				FROM = "#from_address#"
				SUBJECT = "Price condition and ZDeal - Sent and Acked Report - Dated #DATEFORMAT(now(),"mm/dd/yyyy")# #TIMEFORMAT(now(),"HH:mm:ss")#"
				TYPE = "html"
				MESSAGETYPE = "1"
				generatedBy="1"
				appArea="1" >
				<table WIDTH="100%">
					<tr Valign="top">
						<td>
							Price condition and ZDeal - Sent and Acked Report - Dated #DATEFORMAT(now(),"mm/dd/yyyy")# #TIMEFORMAT(now(),"HH:mm:ss")#
						</td>
					</tr>
				</table>
				<!--- The cfmailparam is the file being attached --->
				<cf_EmailWrapperParam file="#fName1#" store="yes"/>
				<cf_EmailWrapperParam file="#fName2#" store="yes"/>
				<!--- <cf_EmailWrapperParam file="#fName3#" store="yes"/> --->
				</cf_EmailWrapper>
			</cfif>
		</cfoutput>
	</body>
</html>
