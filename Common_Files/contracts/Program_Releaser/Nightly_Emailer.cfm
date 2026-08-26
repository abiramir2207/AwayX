<!--- automated code --->
<!---
		When a programs is EXPIRING or EXPIRED
		emails user in position which created it of its status
--->

<CFSET TitleMaxLength 	      = 43>
<CFSET SpacerLength 		  = 12>
<CFSET ProgramCount 		 = 0>
<CFSET Expiring_CID_List 	= "">
<CFSET Expired_CID_List 	= "">
<CFSET Aged_BBD_List		= "">
<cfset BillbackCount				= 0>
<cfset columnspacer = "50">
<cfquery name="GetPositions" datasource="#application.datasource#">
	SELECT     Position_Label, User_Positions_ID
	FROM         dbo.User_Positions
	WHERE     (Deleted = 0)
</cfquery>

<cfinclude template="/get_app_path.cfm">
<CFSET tempfilepath = APPLICATIONPATH & "\Common_Files\contracts\Program_Releaser\Nightly_Emailer_Data.cfm">
<cffile action="READ" file="#tempfilepath#" variable="temp_company_main_id">

<cfquery name="getBBAgedate" datasource="#application.datasource#">
SELECT     BB_Danger_Range
FROM         dbo.Billback_Settings
WHERE     (User_ID = '#trim(temp_company_main_id)#')
</cfquery>

<cfquery name="getwarningsettings" datasource="#application.datasource#">
	SELECT     dbo._Users_Settings.Contract_Expiration_Range, dbo.Billback_Settings.BB_Danger_Range, dbo._Users_Settings.User_ID
	FROM         dbo._Users_Settings INNER JOIN
	                      dbo.Billback_Settings ON dbo._Users_Settings.User_ID = dbo.Billback_Settings.User_ID
	WHERE     (dbo._Users_Settings.User_ID = '#trim(temp_company_main_id)#')
</cfquery>

<cfset exptime = getwarningsettings.Contract_Expiration_Range>
<cfif exptime eq 1><cfset dayscaption = "day"><cfelse><cfset dayscaption = "days"></cfif>

<cfset bbage = getwarningsettings.BB_Danger_Range>
<cfif bbage eq 1><cfset bbcaption = "day"><cfelse><cfset bbcaption = "days"></cfif>

<cfloop query="GetPositions">
	<CFSET Current_Position 		= GetPositions.User_Positions_ID>
	<CFSET Current_Position_Label 	= GetPositions.Position_Label>

	<cfquery name="getProgramsByPositions" datasource="#application.datasource#">
		SELECT     dbo.Contract_Main.Contract_Main_ID,dbo.Contract_Main.Contract_Number, dbo.Contract_Main.Contract_Title, dbo.Contract_Main.Contract_Start_Date,
		                      dbo.Contract_Main.Contract_End_Date, dbo.Contract_Main.Contract_Status_Type_IDX, dbo.Contract_Main.Creating_User_Position_ID,
		                      dbo.Contract_Main.Flagged_As_Purged, dbo.Contract_Main_Aux_Data.Expired_Email_Sent, dbo.Contract_Main_Aux_Data.Expiring_Email_Sent
		FROM         dbo.Contract_Main INNER JOIN
		                      dbo.Contract_Main_Aux_Data ON dbo.Contract_Main.Contract_Main_ID = dbo.Contract_Main_Aux_Data.Contract_Main_ID
		WHERE     ((dbo.Contract_Main.Contract_Status_Type_IDX = 6 OR dbo.Contract_Main.Contract_Status_Type_IDX = 7)) AND (dbo.Contract_Main.Creating_User_Position_ID = #User_Positions_ID#) AND (dbo.Contract_Main.Flagged_As_Purged = 0) AND (dbo.Contract_Main.Deleted = 0)
		AND
		(
			(Contract_Status_Type_IDX = 6 AND  Expiring_Email_Sent = 0)
			OR
			(Contract_Status_Type_IDX = 7 AND  Expired_Email_Sent = 0)
		)
		ORDER BY dbo.Contract_Main.Contract_Number
	</cfquery>

	<cfquery name="getBillbacks" datasource="#application.datasource#">
			SELECT     BB_Code, BB_Title, Billback_ID
			FROM         dbo.Billback
			WHERE     (Deleted = 0) AND (BB_Creator_User_Position_ID = '#User_Positions_ID#')	AND DateDiff(day,BB_Date,getdate()) >= #trim(numberformat(getBBAgedate.BB_Danger_Range, '_____________'))# AND Age_Email_Sent = 0
			ORDER BY  BB_Code
	</cfquery>


<!--- 		<cfsavecontent variable="Email_Body">
			Program Status Update Email (PSUE)
			<CFOUTPUT>Data current as of #TimeFormat(NOW(), 'h:mm tt')# on #DateFormat(NOW(), 'm/d/yyyy')#</CFOUTPUT>

			Expiring Programs:
			Contract Number	Title						Days Left
			---------------------------------------------------------------------------------
			<cfloop query="getProgramsByPositions"><CFIF getProgramsByPositions.Contract_Status_Type_IDX EQ 6><CFSET ProgramCount = ProgramCount + 1><CFSET title=Left(getProgramsByPositions.Contract_Title,TitleMaxLength)><CFSET Spacer=TitleMaxLength-len(title)+SpacerLength><CFOUTPUT>#getProgramsByPositions.Contract_Number#	#trim(title)#<cfif len(title) EQ TitleMaxLength>...</cfif><cfloop index="x" from="1" to="#Spacer#" step="1"> </CFLOOP><CFSET TimeLeft = DateDiff('d',Now(),getProgramsByPositions.Contract_End_Date)><CFIF TimeLeft EQ 1>Today is the last day<CFELSEIF TimeLeft GT 0>#evaluate("#TimeLeft#+1")#<CFELSE>#TimeLeft#</CFIF><CFSET Expiring_CID_List = listappend(Expiring_CID_List,getProgramsByPositions.Contract_Main_ID)>
			</CFOUTPUT></CFIF></CFLOOP>
			<CFIF ProgramCount EQ 0>There Are No Programs To Report On Today</CFIF>

			Expired Programs:
			Contract Number	Title
			---------------------------------------------------------------------------------
			<CFSET ProgramCount = 0><cfloop query="getProgramsByPositions"><CFIF getProgramsByPositions.Contract_Status_Type_IDX EQ 7><CFSET ProgramCount = ProgramCount + 1><CFSET title=Left(getProgramsByPositions.Contract_Title,TitleMaxLength)><CFOUTPUT>#getProgramsByPositions.Contract_Number#	#trim(title)#<cfif len(title) EQ TitleMaxLength>...</cfif><CFSET Expired_CID_List = listappend(Expired_CID_List,getProgramsByPositions.Contract_Main_ID)>
			</CFOUTPUT></CFIF></CFLOOP>
			<CFIF ProgramCount EQ 0>There Are No Programs To Report On Today</CFIF>
		</cfsavecontent>
--->
		<CFIF getBillbacks.recordcount gt 0 or getProgramsByPositions.recordcount gt 0>
		<cfsavecontent variable="Email_Body">
			<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
			<HTML>
			<HEAD>
				<TITLE>report</TITLE>
			</HEAD>

			<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

			<!--- expiring --->

			<table width="525" border="0" cellspacing="0" cellpadding="0" align="center">
				<thead>
				<TR>
					<TD colspan="100%" align="left" style="font-size:15px; font-weight:bold; color:Red;" height="20" nowrap>Expiring Programs: <span style="font-size:12px; color:black; font-weight: normal;">program will expire in <cfoutput>#exptime# #dayscaption#</cfoutput> </span></TD>
				</TR>
				<TR>
					<TD style="font-size:15px;font-weight:bold;border-bottom:; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" height="20px;" nowrap width="1%">Number</TD>
					<td width="#columnspacer#" style="border-bottom: 1 solid Black;">&nbsp;</td>
					<TD style="font-size:15px;font-weight:bold;border-bottom:; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" align="left">Title</TD>
				</TR>
				</thead>
				<tbody>
				<cfloop query="getProgramsByPositions">
					<CFIF getProgramsByPositions.Contract_Status_Type_IDX EQ 6>
						<TR>
						<CFSET ProgramCount = ProgramCount + 1>
						<CFSET title=Left(getProgramsByPositions.Contract_Title,TitleMaxLength)>
						<CFSET Spacer=TitleMaxLength-len(title)+SpacerLength>
						<CFOUTPUT>
							<td height="20" style="font-size: 13px; border-bottom:; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" nowrap>#getProgramsByPositions.Contract_Number#</td>
							<td width="#columnspacer#" style="border-bottom: 1 solid Black;">&nbsp;</td>
							<td style="font-size: 13px; border-bottom:; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" nowrap>#trim(title)#</td>
							<CFSET Expiring_CID_List = listappend(Expiring_CID_List,getProgramsByPositions.Contract_Main_ID)>
						</CFOUTPUT>
						</TR>
					</CFIF>
				</cfloop>
				<CFIF ProgramCount EQ 0><tr><td colspan="100%" style="font-weight:bold;" align="center" height="30">There Are No Programs To Report On Today</td></tr></CFIF>
				</tbody>
			</table>
			<BR>
			<!--- expired --->
			<table width="525" border="0" cellspacing="0" cellpadding="0" align="center">
				<thead>
				<TR>
					<TD colspan="100%" align="left" style="font-size:15px; font-weight:bold; color:Red;" height="20" nowrap>Expired Programs:</TD>
				</TR>
				<TR>
					<TD style="font-size:15px;font-weight:bold;border-bottom:; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" height="20px;" nowrap width="1%">Number</TD>
					<td width="#columnspacer#" style="border-bottom: 1 solid Black;">&nbsp;</td>
					<TD style="font-size:15px;font-weight:bold;border-bottom:; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" align="left">Title</TD>
				</TR>
				</thead>
				<tbody>
				<cfloop query="getProgramsByPositions">
					<CFIF getProgramsByPositions.Contract_Status_Type_IDX EQ 7>
						<TR>
						<CFSET ProgramCount = ProgramCount + 1>
						<CFSET title=Left(getProgramsByPositions.Contract_Title,TitleMaxLength)>
						<CFSET Spacer=TitleMaxLength-len(title)+SpacerLength>
						<CFOUTPUT>
							<td height="20" style="font-size: 13px; border-bottom:; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" nowrap>#getProgramsByPositions.Contract_Number#</td>
							<td width="#columnspacer#" style="border-bottom: 1 solid Black;">&nbsp;</td>
							<td style="font-size: 13px; border-bottom:; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" nowrap>#trim(title)#</td>
							<CFSET Expired_CID_List = listappend(Expired_CID_List,getProgramsByPositions.Contract_Main_ID)>
						</CFOUTPUT>
						</TR>
					</CFIF>
				</cfloop>
				<CFIF ProgramCount EQ 0><tr><td colspan="100%" style="font-weight:bold;" align="center" height="30">There Are No Programs To Report On Today</td></tr></CFIF>
				</tbody>
			</table>
			<br>
			<!--- aged billbacks --->
			<table width="525" border="0" cellspacing="0" cellpadding="0" align="center">
				<thead>
				<TR>
					<cfoutput>
					<TD colspan="100%" align="left" style="font-size:15px; font-weight:bold; color:Red;" height="20" nowrap>Aging Payables:  <span style="font-size:12px; color:black; font-weight: normal;"> payable has been unresolved for #bbage# #bbcaption# or more past its billback date</span></TD>
					</cfoutput>
				</TR>
				<TR>
					<TD style="font-size:15px;font-weight:bold;border-bottom:; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" height="20px;" nowrap width="1%">Number</TD>
					<td width="#columnspacer#" style="border-bottom: 1 solid Black;">&nbsp;</td>
					<TD style="font-size:15px;font-weight:bold;border-bottom:; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" align="left">Title</TD>
				</TR>
				</thead>
				<tbody>
				<cfloop query="getBillbacks">
						<TR>
						<CFSET BillbackCount = BillbackCount + 1>
						<CFOUTPUT>
							<td height="20" style="font-size: 13px; border-bottom:; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" nowrap>#getBillbacks.BB_Code#</td>
							<td width="#columnspacer#" style="border-bottom: 1 solid Black;">&nbsp;</td>
							<td style="font-size: 13px; border-bottom:; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" nowrap>#trim(getBillbacks.BB_Title)#</td>
						</CFOUTPUT>
						</TR>
					    <CFSET Aged_BBD_List = listappend(Aged_BBD_List ,getBillbacks.Billback_ID)>
				</cfloop>
				<CFIF BillbackCount  EQ 0><tr><td colspan="100%" style="font-weight:bold;" align="center" height="30">There Are No Billbacks To Report On Today</td></tr></CFIF>
				</tbody>
			</table>
			</BODY>
			</HTML>
		</cfsavecontent>

		<cfquery name="getPositionUsers" datasource="#application.datasource#">
			SELECT     dbo._Users.Name_First, dbo._Users.Name_Last, dbo._Users.User_Email, dbo.User_Position_Holders.User_Positions_ID
			FROM         dbo.User_Position_Holders INNER JOIN
			                      dbo._Users ON dbo.User_Position_Holders.User_ID = dbo._Users.User_ID
			WHERE     (dbo.User_Position_Holders.deleted = 0) AND (dbo._Users.Deleted = 0)	AND User_Positions_ID = '#Current_Position#'
		</cfquery>

		<cfloop query="getPositionUsers">
			<CFSET Current_Name_First 	= getPositionUsers.Name_First>
			<CFSET Current_Name_Last 	= getPositionUsers.Name_Last>
			<CFSET Current_Email 		= getPositionUsers.User_Email>

			<!--- <cfmail to="evazquez@awayx.com" from="informer@awayx.com" subject="Status Change Notice For #Current_Position_Label# - #Current_Name_First# #Current_Name_Last#" server="web24" type="HTML">
			<!--- <cfmail to="#Current_Email#" from="informer@awayx.com" subject="Program Status Update For #Current_Position_Label# - #Current_Name_First# #Current_Name_Last#"> --->
				#Email_Body#
				<BR><BR><BR><BR><span style="font-sixe:10px;">Data current as of #TimeFormat(NOW(), 'h:mm tt')# on #DateFormat(NOW(), 'm/d/yyyy')#</span>
			</cfmail> --->
		</CFLOOP>
		</CFIF>
	</CFLOOP>




 		<cfquery name="getSettings" datasource="#application.datasource#">
			SELECT Nightly_Report_Email_List
			FROM _users_settings
			WHERE User_ID = '#trim(temp_company_main_id)#'
		</cfquery>
<!--- 		<cfset getSettings = querynew("Nightly_Report_Email_List")>
		<cfset temp = queryaddrow(getSettings)>
		<cfset temp = QuerySetCell(getSettings,"Nightly_Report_Email_List", "evazquez@awayx.com")>
 --->

		<cfquery name="getPrograms" datasource="#application.datasource#">
			SELECT     dbo.Contract_Main.Contract_Main_ID,dbo.Contract_Main.Contract_Number, dbo.Contract_Main.Contract_Title, dbo.Contract_Main.Contract_Start_Date,
			                      dbo.Contract_Main.Contract_End_Date, dbo.Contract_Main.Contract_Status_Type_IDX, dbo.Contract_Main.Creating_User_Position_ID,
			                      dbo.Contract_Main.Flagged_As_Purged, dbo.Contract_Main_Aux_Data.Expired_Email_Sent, dbo.Contract_Main_Aux_Data.Expiring_Email_Sent
			FROM         dbo.Contract_Main INNER JOIN
			                      dbo.Contract_Main_Aux_Data ON dbo.Contract_Main.Contract_Main_ID = dbo.Contract_Main_Aux_Data.Contract_Main_ID
			WHERE     ((dbo.Contract_Main.Contract_Status_Type_IDX = 6 OR dbo.Contract_Main.Contract_Status_Type_IDX = 7)) AND (dbo.Contract_Main.Flagged_As_Purged = 0) AND (dbo.Contract_Main.Deleted = 0)
			AND
			(
				(Contract_Status_Type_IDX = 6 AND  Expiring_Email_Sent = 0)
				OR
				(Contract_Status_Type_IDX = 7 AND  Expired_Email_Sent = 0)
			)
			ORDER BY dbo.Contract_Main.Contract_Number
		</cfquery>

	<cfquery name="getBillbacks" datasource="#application.datasource#">
			SELECT     BB_Code, BB_Title
			FROM         dbo.Billback
			WHERE     (Deleted = 0) AND DateDiff(day,BB_Date,getdate()) >= #trim(numberformat(getBBAgedate.BB_Danger_Range, '_____________'))# AND Age_Email_Sent = 0
			ORDER BY  BB_Code
	</cfquery>

		<cfsavecontent variable="Email_Body">
			<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
			<HTML>
			<HEAD>
				<TITLE>report</TITLE>
			</HEAD>

			<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

			<!--- expiring --->
			<table width="525" border="0" cellspacing="0" cellpadding="0" align="center">
				<thead>
				<TR>
					<cfoutput>
						<TD colspan="100%" align="left" style="font-size:15px; font-weight:bold; color:Red;" height="20" nowrap>Expiring Programs: <span style="font-size:12px; color:black; font-weight: normal;">program will expire in #exptime# #dayscaption# </span></TD>
					</cfoutput>
				</TR>
				<TR>
					<td  width="1%" height="20px;" nowrap style="font-size:15px; font-weight:bold; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;">Number</td>
					<td width="#columnspacer#" style="border-bottom: 1 solid Black;">&nbsp;</td>
					<TD style="font-size:15px;font-weight:bold; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" align="left">Title</TD>
				</TR>
				</thead>
				<tbody>
				<cfloop query="getPrograms">
					<CFIF getPrograms.Contract_Status_Type_IDX EQ 6>
						<TR>
						<CFSET ProgramCount = ProgramCount + 1>
						<CFSET title=Left(getPrograms.Contract_Title,TitleMaxLength)>
						<CFSET Spacer=TitleMaxLength-len(title)+SpacerLength>
						<CFOUTPUT>
							<td height="20" style="font-size: 13px; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" nowrap>#getPrograms.Contract_Number#</td>
							<td width="#columnspacer#" style="border-bottom: 1 solid Black;">&nbsp;</td>
							<td style="font-size: 13px;border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" nowrap>#trim(title)#</td>
						</CFOUTPUT>
						</TR>
					</CFIF>
				</cfloop>
<!--- 				<CFIF ProgramCount EQ 0><tr><td colspan="100%" style="font-weight:bold;" align="center" height="30">There Are No Programs To Report On Today</td></tr></CFIF> --->
				</tbody>
			</table>
			<BR>
			<!--- expired --->
			<table width="525" border="0" cellspacing="0" cellpadding="0" align="center">
				<thead>
				<TR>
					<TD colspan="100%" align="left" style="font-size:15px; font-weight:bold; color:Red;" height="20" nowrap>Expired Programs:</TD>
				</TR>
				<TR>
					<TD style="font-size:15px;font-weight:bold;border-bottom:; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" height="20px;" nowrap width="1%">Number</TD>
					<td width="#columnspacer#" style="border-bottom: 1 solid Black;">&nbsp;</td>
					<TD style="font-size:15px;font-weight:bold;border-bottom:; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" align="left">Title</TD>
				</TR>
				</thead>
				<tbody>
				<CFSET ProgramCount = 0>
				<cfloop query="getPrograms">
					<CFIF getPrograms.Contract_Status_Type_IDX EQ 7>
						<TR>
						<CFSET ProgramCount = ProgramCount + 1>
						<CFSET title=Left(getPrograms.Contract_Title,TitleMaxLength)>
						<CFSET Spacer=TitleMaxLength-len(title)+SpacerLength>
						<CFOUTPUT>
							<td height="20" style="font-size: 13px; border-bottom:; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" nowrap>#getPrograms.Contract_Number#</td>
							<td width="#columnspacer#" style="border-bottom: 1 solid Black;">&nbsp;</td>
							<td style="font-size: 13px; border-bottom:; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" nowrap>#trim(title)#</td>
						</CFOUTPUT>
						</TR>
					</CFIF>
				</cfloop>
				<CFIF ProgramCount EQ 0><tr><td colspan="100%" style="font-weight:bold;" align="center" height="30">There Are No Programs To Report On Today</td></tr></CFIF>
				</tbody>
			</table>
			<br>
			<!--- aged billbacks --->
			<table width="525" border="0" cellspacing="0" cellpadding="0" align="center">
				<thead>
				<TR>
					<cfoutput>
					<TD colspan="100%" colspan="100%" align="left" style="font-size:15px; font-weight:bold; color:Red;" height="20" nowrap>Aging Payables: <span style="font-size:12px; color:black; font-weight: normal;">payable has been unresolved for #bbage# #bbcaption# or more past its billback date</span></TD>
					</cfoutput>
				</TR>
				<TR>
					<TD style="font-size:15px;font-weight:bold;border-bottom:; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" height="20px;" nowrap width="1%">Number</TD>
					<td width="#columnspacer#" style="border-bottom: 1 solid Black;">&nbsp;</td>
					<TD style="font-size:15px;font-weight:bold;border-bottom:; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" align="left">Title</TD>
				</TR>
				</thead>
				<tbody>
				<CFSET BillbackCount = 0>
				<cfloop query="getBillbacks">
						<TR>
						<CFSET BillbackCount = BillbackCount + 1>
						<CFOUTPUT>
							<td height="20" style="font-size: 13px; border-bottom:; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" nowrap>#getBillbacks.BB_Code#</td>
							<td width="#columnspacer#" style="border-bottom: 1 solid Black;">&nbsp;</td>
							<td style="font-size: 13px; border-bottom:; border-bottom-color: Black; border-bottom-style: solid; border-bottom-width: 1;" nowrap>#trim(getBillbacks.BB_Title)#</td>
						</CFOUTPUT>
						</TR>
				</cfloop>
				<CFIF BillbackCount  EQ 0><tr><td colspan="100%" style="font-weight:bold;" align="center" height="30">There Are No Payables To Report On Today</td></tr></CFIF>
				<tbody>
			</table>
			</BODY>
			</HTML>
		</cfsavecontent>

 		<cfloop index="x" list="#getSettings.Nightly_Report_Email_List#" delimiters=";">
			<CFIF len(trim(x)) GT 0>
				<cfmail to="#x#" from="forgetrade@bigredflame.com" subject="ADMINISTRATOR - Status Change Notice" server="web24" type="HTML">
					#Email_Body#
					<BR><BR><BR><BR><span style="font-sixe:10px;">Data current as of #TimeFormat(NOW(), 'h:mm tt')# on #DateFormat(NOW(), 'm/d/yyyy')#</span>
				</cfmail>
			</CFIF>
		</CFLOOP>

	<CFIF listlen(Expiring_CID_List) gt 0>
		<cfquery name="updateExpiringEmailBit" datasource="#application.datasource#">
			UPDATE Contract_Main_Aux_Data
			SET Expiring_Email_Sent = 1
			WHERE Contract_main_ID IN(#Expiring_CID_List#)
		</cfquery>
	</CFIF>

	<CFIF listlen(Expired_CID_List) gt 0>
		<cfquery name="updateExpiredEmailBit" datasource="#application.datasource#">
			UPDATE Contract_Main_Aux_Data
			SET Expired_Email_Sent = 1
			WHERE Contract_main_ID IN(#Expired_CID_List#)
		</cfquery>
	</CFIF>
		<CFIF listlen(Aged_BBD_List) gt 0>
		<cfquery name="updateBillbackAgeEmailBit" datasource="#application.datasource#">
			UPDATE Billback
			SET Age_Email_Sent = 1
			WHERE Billback_ID IN(#listqualify(Aged_BBD_List,"'")#)
		</cfquery>
	</CFIF>




