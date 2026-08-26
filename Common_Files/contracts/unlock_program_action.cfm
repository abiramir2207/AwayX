<cf_Cryp type="de" key="#request.key#" string="#FORM.Program_ID#">
<cfquery name="unlockProgram" datasource="#application.datasource#">	
	UPDATE Contract_Main
	SET Contract_Is_Locked = 0
	WHERE Contract_Main_ID = #cryp.value#
</cfquery>

<script>
	window.close();
</script>
