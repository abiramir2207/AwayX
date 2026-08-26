

<CFQUERY NAME="PermanentlydeleteBBanalysts" datasource="#application.datasource#">
	truncate table BB_Analyst
	
	truncate table BB_Assignment

	update Billback
	set Analyst_User_ID = NULL
	where Analyst_User_ID is NOT NULL

</CFQUERY>

<script>
	window.close();
</script>
