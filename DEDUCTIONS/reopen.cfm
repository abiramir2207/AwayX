<Cfparam name="blnSubmit" default="0">

<cfif blnSubmit IS 1>

<cfset useLakebaseForUpdateDeductions = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForUpdateDeductions>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{ "deduction_id" = "eq.#Deduction_ID#" },
			{ "dd_status" = 2, "dd_closure_sent" = 0 }
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForUpdateDeductions = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateDeductions>
<cfquery name="UpdateDeductions" datasource="#application.datasource#">
	UPDATE Deductions
	SET DD_Status = 2,
		DD_Closure_Sent = 0
	WHERE Deduction_ID = '#Deduction_ID#'
</cfquery>
</cfif>

<!---Reopen any billbacks closed by this deduction--->
<cfquery name="BBsClosedByDeduction" datasource="#application.datasource#">
	SELECT Billback_ID 
	FROM Billback 
		INNER JOIN Deductions 
		ON Deductions.DD_Closure_ID = Billback.Billback_ID
</cfquery>

<cfloop query="BBsClosedByDeduction">
	<cfset useLakebaseForReopenBillbacks = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForReopenBillbacks>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#BBsClosedByDeduction.Billback_ID#"
			},
			{
				"bb_payment_header_sent" = "0",
				"bb_payment_detail_sent" = "0",
				"bb_payment_user_sent" = "0",
				"bb_reopened_multiplier" = "-1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForReopenBillbacks = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForReopenBillbacks>
<cfquery name="ReopenBillbacks" datasource="#application.datasource#">
	UPDATE Billback
	SET BB_Payment_Header_Sent = 0,
		BB_Payment_Detail_Sent = 0,
		BB_Payment_User_Sent = 0,
		BB_Reopened_Multiplier = -1
	WHERE Billback.Billback_ID = '#BBsClosedByDeduction.Billback_ID#'
	</cfquery>
</cfif>
</cfloop>


<cfif len(trim(DD_NOTE)) GT 0>
	<cfset useLakebaseForInsertNote = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_notes")>
	<cfif useLakebaseForInsertNote>
		<cftry>
			<cfset application.oLakebase.insertRow("dd_notes", {
				"deduction_id" = Form.Deduction_ID,
				"dd_note" = DD_Note,
				"dd_note_date" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
				"dd_note_by" = request.AccessStructure.User_ID
			})>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForInsertNote = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForInsertNote>
	<cfquery name="InsertNote" datasource="#application.datasource#">
			INSERT INTO DD_notes
			(
				Deduction_ID,
				DD_Note,
				DD_Note_Date,
				DD_Note_By
			)
			VALUES
			(
				'#Form.Deduction_ID#',
				'#DD_Note#', 
				#Now()#,
				'#request.AccessStructure.User_ID#'
			)
		</cfquery>
	</cfif>
</cfif>
 <cflocation url="/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#"> 

</cfif>

<cfquery name="AllDeductionAnalysts" datasource="#application.datasource#">

		SELECT 		Analyst_User_ID,
					Default_Analyst,
					Name_First,
					Name_Last 
		FROM 		DD_Analyst 
		INNER JOIN 	_Users ON _Users.User_ID = DD_Analyst.Analyst_User_ID
		WHERE 		DD_Analyst.Deleted = 0 AND _Users.Deleted = 0		
    ORDER BY Name_First,Name_Last
	</CFQUERY>

	<Cfoutput>
	
	<DIV style="padding:10px; position: absolute; width: 690px; height: 500px; z-index: 1; left: 250px; top: 60px" id="deduct_details">
<form name="ReopenDeduction" action="/deductions/reopen.cfm" method="post">	
<table width="90%"><tr><Td valign="Center">
<strong><font size="+1" color="navy">Reopen Deduction</font></strong></td><td valign="Center" align="right"><img src="/images/close1.gif">&nbsp; &nbsp; &nbsp; </TD></tr>


<table border="0" width="90%" cellspacing="0" cellpadding="3" style="border-left:solid navy 2px; border-right:solid navy 2px; border-top:solid navy 2px; border-bottom:solid navy 2px;">
	<tr>
		<td  style="border-right:solid navy 2px;" valign="top"><strong>Assign To:</strong></td>
		<td><select name="NewAnalyst">
			<cfloop query="AllDeductionAnalysts">
			
				<option value="#Analyst_User_ID#" <Cfif Deduction_Info.Analyst_User_ID IS Analyst_User_ID>selected</CFIF>>#Name_First# #Name_Last#</option>
			
			</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td  style="border-right:solid navy 2px;" valign="top"><strong>Note on why it is sent back:</strong></td>
		<td>
		<textarea name="DD_Note" cols="45" rows="6" maxlength="255"></textarea>
		</td>
	</tr>
	

</table>
<Br>
<div align="center"><a href="##" onclick="fnReopenDeduction();"><strong><font color="navy">[ save ]</font></strong></a>
<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
<input type="hidden" name="blnSubmit" value="1">
</cfoutput>


</div>
</form>
</div>
<script>

function fnReopenDeduction(){

		ReopenDeduction.submit()
		
		}
</script>
