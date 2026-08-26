
<!---Update database and redirect home--->

<!---First see if preference record already exists--->

<cfquery name="IsAlreadyThere" datasource="#application.datasource#">
SELECT * FROM _User_Preferences
WHERE User_ID = '#request.AccessStructure.User_ID#'
</cfquery>

<cfif IsAlreadyThere.Recordcount GT 0>
<!---Update--->
	<cfquery name="UpdateRecord" datasource="#application.datasource#">
	UPDATE _User_Preferences
	SET Records_To_Show = '#RecordsToShow#',
		Last_Updated	= #now()#
	WHERE User_ID = '#request.AccessStructure.User_ID#'
	</cfquery>

<!---Insert--->
<cfelse>
	<cfquery name="InsertRecord" datasource="#application.datasource#">
	INSERT INTO _User_Preferences
	(
		User_ID,
		Last_Updated,
		Records_To_Show
	)
	VALUES
	(
		'#request.AccessStructure.User_ID#',
		#now()#,
		'#RecordsToShow#'
	)
	</cfquery>

</cfif>

<cflocation url="/settings/personalization/index.cfm">