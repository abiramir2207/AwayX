<CFIF len(trim(ParentContractMainId)) GT 0>
	<!--- there is parent assigned to this Program--->
	<CFQUERY NAME="ParentContractHistory" datasource="#application.datasource#">
		SELECT *
		FROM Temp_History
		WHERE temp_id = '#ParentContractMainId#'
		ORDER BY Changed_Date desc
	</CFQUERY>
	
	<CFLOOP QUERY="ParentContractHistory">
		<!--- if the length of the ParentHistory if gt 0 then preappend the history data to the main history query --->
		<CFSET tempQuery = QueryAddRow(ContractHistory,1)>
		<CFSET tempQuery = QuerySetCell(ContractHistory,"CHANGED_DATE",ParentContractHistory.CHANGED_DATE)>
		<CFSET tempQuery = QuerySetCell(ContractHistory,"CREATED_BY",ParentContractHistory.CREATED_BY)>
		<CFSET tempQuery = QuerySetCell(ContractHistory,"HISTORY_DATE",ParentContractHistory.HISTORY_DATE)>
		<CFSET tempQuery = QuerySetCell(ContractHistory,"NEW_VALUE",ParentContractHistory.NEW_VALUE)>
		<CFSET tempQuery = QuerySetCell(ContractHistory,"OLD_VALUE",ParentContractHistory.OLD_VALUE)>
		<CFSET tempQuery = QuerySetCell(ContractHistory,"TABLE_FIELD_NAME",ParentContractHistory.TABLE_FIELD_NAME)>
		<CFSET tempQuery = QuerySetCell(ContractHistory,"TEMP_HISTORY_ID",ParentContractHistory.TEMP_HISTORY_ID)>
		<CFSET tempQuery = QuerySetCell(ContractHistory,"TEMP_ID",ParentContractHistory.TEMP_ID)>
	</CFLOOP>
</CFIF>
