<cfsilent>

<cfparam name="Address" 			default=1>
<cfparam name="DD_Date" 			default=0>
<cfparam name="DD_Amount" 			default=0>
<cfparam name="DD_Customer_RefNo" 	default=0>
<cfparam name="DD_Reference" 		default=0>
<cfparam name="DD_Check_Number" 	default=0>
<cfparam name="Transferred_Reason" 	default=0>
<cfparam name="User_Position" 		default=0> --->

<!---Gets data about deduction--->
<cfinclude template="/deductions/sql_Deduction_Info.cfm">

<!---Get Clauses --->
<cfif len(trim(DD_Rebill_ID)) GT 0>
	<cfquery name="GetClauses" datasource="#application.datasource#">
	SELECT DD_Rebill_ID, DD_Rebill_Text, Is_Editable 
	FROM DD_Rebill 
	WHERE DD_Rebill_ID IN (#DD_Rebill_ID#)
	AND Deleted = 0
	ORDER BY Clause_Order, Created_Date
	</cfquery>
</cfif>

<!---Get User Position --->
<cfif User_Position IS 1>
	<cfquery name="GetUserPosition" datasource="#application.datasource#">
	SELECT TOP 1 Position_Label
		FROM User_Positions
		INNER JOIN User_Position_Holders
		ON User_Position_Holders.User_ID = '#request.AccessStructure.User_ID#'
		AND User_Position_Holders.User_Positions_ID = User_Positions.User_Positions_ID
		AND User_Position_Holders.User_Position_Type = 'P'
		AND User_Position_Holders.Deleted = 0
	</cfquery>
</cfif>

<!---Get Deduction Reason --->
<Cfif Transferred_Reason IS 1>
	<cfset useLakebaseForGetDeductionReason = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_rebill_status")>
	<cfif useLakebaseForGetDeductionReason>
		<cftry>
			<cfset GetDeductionReason = application.oLakebase.toQuery(
				application.oLakebase.selectRows("dd_rebill_status", {
					"select" = "transferred_reason",
					"deduction_id" = "eq.#Deduction_ID#",
					"order" = "created_date.desc",
					"limit" = "1"
				}),
				"transferred_reason"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForGetDeductionReason = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetDeductionReason>
	<cfquery name="GetDeductionReason" datasource="#application.datasource#">
	SELECT TOP 1 Transferred_Reason FROM DD_Rebill_Status
	WHERE Deduction_ID = '#Deduction_ID#'
	ORDER BY Created_Date DESC
	</cfquery>
	</cfif>
</CFIF>

</cfsilent>

<cfoutput>

<cfsavecontent variable="LetterBody">

<table border="0" width="600" cellpadding="1" cellspacing="0">

<tr></tr>

<tr>
	<td width="200">
#AddressField#
	</td>
	<td width="200">&nbsp; </td>
	<td valign="top" align="right">#dateformat(now(), 'MMM DD, YYYY')#</td>
</tr>

<tr><td colspan="3"><p>&nbsp; </p></td></td></tr>

<tr><td colspan="3">Dear #AddressName#, <p></p></td></tr>

<cfloop query="GetClauses">
	<cfif is_Editable IS 0>
		<tr><td colspan="3">#DD_Rebill_Text#<p></td></tr>
	<cfelse>
	<tr><td colspan="3">
		<cfset This = evaluate("ID_#GetClauses.DD_Rebill_ID#")>
		#This#<p></p>
	</td></tr>
	</cfif>
	
</cfloop>
<tr><td colspan="3"><p>&nbsp;  </td></tr>
<tr><td colspan="2"><strong>Deduction Information:</strong></td></tr>


	<cfif DD_Date IS 1>
	<tr><td>Deduction Date:</td><td colspan="2">#Dateformat(Deduction_Info.DD_Date, 'MM/DD/YYYY')#</td></tr>
	</cfif>
	<cfif DD_Amount IS 1>
	<tr><td>Deduction Amount:</td><td colspan="2">#LSCurrencyFormat(DD_Amount)#</td></tr>
	</cfif>
	<cfif DD_Customer_RefNo IS 1>
	<tr><td>Customer Reference Number:</td><td colspan="2">#Deduction_Info.DD_Customer_RefNo#</td></tr>
	</cfif>
	<cfif DD_Reference IS 1>
	<tr><td>Deduction Reference Number:</td><td colspan="2">#Deduction_Info.DD_Reference#</td></tr>
	</cfif>
	<cfif DD_Check_Number IS 1>
	<tr><td>Check Number:</td><td colspan="2">#Deduction_Info.DD_Check_Number#</td></tr>
	</cfif>
	<cfif Transferred_Reason IS 1>
	<tr><td>Deduction Reason:</td><td colspan="2">#GetDeductionReason.Transferred_Reason#</td></tr>
	</cfif>

<tr><td colspan="3"><p>&nbsp; </p</td></td></tr>
	
<tr><td colspan="3">Sincerely,<p>&nbsp; </p></td></tr>

<tr><td colspan="3">#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#</td></tr>
<cfif User_Position IS 1><tr><td colspan="3">#UserPosition#</td></tr></cfif>

</table>
</cfsavecontent>
<br>
#LetterBody#

<!---Write file to permanent location --->
<cfset genFunctions = CreateObject("component", "components.Base") />

<cfset FileLocation = "\DEDUCTIONS\Rebill\">
<cfset FileLocation2 = "/Deductions/Rebill/Rebill_Letters/">

<!---Get Last rebill letter ID --->
<cfquery name="GetRebillLogID" datasource="#application.datasource#">
SELECT TOP 1 DD_Rebill_Log_ID
FROM DD_Rebill_Log
WHERE Deduction_ID = '#Deduction_ID#'
ORDER BY DD_Rebill_Log_ID DESC
</cfquery>

<!---Not foolproof, but I'll make the file name unique --->
<cfif GetRebillLogID.Recordcount IS 0>
	<cfset NextRebillID = 0>
<cfelse>
	<cfset NextRebillID = GetRebillLogID.DD_Rebill_Log_ID + 1>
</cfif>

<CFMODULE template="/CustomTags/Writing_Email_Attachment.cfm"
Naming_Format="Rebill_Letter_#Deduction_Info.DD_DedID#_#NextRebillID#"				
Relative_Path="#FileLocation#"
Output_Content="#LetterBody#"
Return_File_Name="fName"
Return_Letter_Name="lName"
Folder_Name="Rebill_Letters">

<cfset FileLink = application.Doc_Mapping & FileLocation2 & lName>

<!---Save all info in database --->
<cfquery name="InsertIntoLog" datasource="#application.datasource#">
INSERT INTO DD_Rebill_Log
(
	File_Location,
	HTML_File_Location,
	Deduction_ID,
	Created_Date,
	Created_By
)
VALUES
(
	'#fName#',
	'#FileLink#',
	'#Deduction_ID#',
	#now()#,
	'#request.AccessStructure.User_ID#'
)
SELECT DD_Rebill_Log_ID = @@IDENTITY
</cfquery> 

<cflocation url="view_letter.cfm?Deduction_ID=#Deduction_ID#&DD_Rebill_Log_ID=#InsertIntoLog.DD_Rebill_Log_ID#"> 

</cfoutput>