
<!---Edit--->
<cfif action IS "Edit">

	<cfquery name="UpdateEntry" datasource="##">
	UPDATE Auto_Checkbook
	SET Program_ID = '#Program_ID#',
		Distributor_ID = '#Distributor_ID#',
		Send_To = '#Send_To#'
	WHERE Auto_Checkbook_ID = '#Auto_Checkbook#'
	</cfquery>

<!---Add--->
<cfelse>

	<cfquery name="InsertEntry" datasource="#application.datasource#">
	INSERT INTO Auto_Checkbook
	(
		User_ID,
		Program_ID,
		Distributor_ID,
		Created_Date,
		Deleted,
		Send_To
	)
	VALUES
	(
		'#request.AccessStructure.User_ID#',
		'#Program_ID#',
		'#Distributor_ID#',
		#Now()#,
		0,
		'#Send_To#'
	)
	</cfquery>

</cfif>


<cflocation url="index.cfm">