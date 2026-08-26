<!--- 
<cfdump var="#form#">
<cfaborT> --->

<!---edit--->
<cfif action IS "edit">
	<cfquery name="EditValues" datasource="#application.datasource#">
	UPDATE BB_Reimbursement
	SET Distributor_ID = '#Distributor_ID#', 
	Contract_Main_ID = '#Contract_Main_ID#',
	Reimbursement_Type = '#ReimbursementType#',
	Reimbursement_Amount = '#ReimbursementAmount#',
	Reimbursement_Number = '#ReimbursementNumber#',
	Reimbursement_Date = '#ReimbursementDate#',
	Reimbursement_Comments = '#ReimbursementComments#'
	WHERE BB_Reimbursement_ID = '#BB_Reimbursement_ID#'
	</cfquery>

	<cfset BB_Reimbursement_ID = form.BB_Reimbursement_ID>

<!---otherwise insert by default--->
<cfelse>

	<cfquery name="InsertintoDatabase" datasource="#application.datasource#">
	SET NOCOUNT ON
	INSERT INTO BB_Reimbursement
	(
		Distributor_ID,
		Contract_Main_ID,
		Reimbursement_Type,
		Reimbursement_Amount,
		Reimbursement_Number,
		Reimbursement_Date,
		Reimbursement_Comments, 
		Created_By
	)
	VALUES
	(
		'#Distributor_ID#',
		'#Contract_Main_ID#',
		'#ReimbursementType#',
		'#ReimbursementAmount#',
		'#ReimbursementNumber#',
		'#ReimbursementDate#',
		'#ReimbursementComments#', 
		'#request.AccessStructure.user_id#'
	)
	
	SELECT TOP 1 BB_Reimbursement_ID AS BB_Reimbursement_ID
	FROM BB_Reimbursement
	ORDER BY Created_Date DESC
	
	SET NOCOUNT OFF
	</cfquery>

	<cfset BB_Reimbursement_ID = InsertintoDatabase.BB_Reimbursement_ID>

</cfif>

<!--- <cfquery name="GetEntries" datasource="#application.datasource#">
SELECT * FROM BB_Reimbursement
</cfquery>

<cfdump var="#GetEntries#"> --->

<cfoutput><cflocation url="detail.cfm?BB_Reimbursement_ID=#BB_Reimbursement_ID#"></cfoutput>