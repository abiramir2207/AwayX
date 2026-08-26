<cfquery name="a" datasource="#Application.Datasource#">
	SELECT Contract_Main_ID
	FROM Contract_Main
</cfquery>


<cfloop query="a">
	<cfquery name="b" datasource="#Application.Datasource#">
		insert into contract_main_aux_data
		(Contract_Main_ID)
		VALUES
		(#a.Contract_Main_ID#)
	</cfquery>
</CFLOOP>
