<CFLOOP INDEX="GroupCount" FROM="1" TO="5" STEP="1">
	<CFLOOP INDEX="ProfileCount" FROM="1" TO="6" STEP="1">
		<CFQUERY NAME="updateApprovaAmt" datasource="#application.datasource#">
			UPDATE Margin_Group_Profile_Approval_Margins
			SET Amount = '#trim(numberformat(evaluate("FORM.Group_#GroupCount#_Profile_#ProfileCount#")), '____________________________.___')#'
			WHERE Group_ID = '#GroupCount#' AND Profile_ID='#ProfileCount#'
		</CFQUERY>
	</CFLOOP>
</CFLOOP>