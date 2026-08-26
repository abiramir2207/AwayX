<!---
	Copyright (c)2013 Blacksmith Applications, Inc.       
	Filename:		C:\Work\base\AwayX\billbacks\Auto_BB_Report\Operators_display.cfm
	Created:		9/17/2013
	Developer:		drachala
	Description:	<brief description of what the file is used for>
	Usage:			<templates that depend on this file>
	Tip:			<gotchas>
--->
		<cfquery name="qGetOperators" datasource="#application.datasource#">
				SELECT 			BO.Operator_Name, BO.Legacy_ID, CM.contract_number
				FROM 				Contract_Main CM
				INNER JOIN 	Contract_Operators CO
				ON 				 	CO.Contract_Main_ID = CM.Contract_Main_ID
				INNER JOIN 	BSA_Operator BO
				ON 					BO.BSA_Operator_ID = CO.BSA_Operator_ID
				WHERE 			CM.Contract_Main_ID = #url.cmid#
				ORDER BY 		BO.Operator_Name
		</cfquery>

		<table>
			<tr bgcolor="#FFCE84">
				<td><b>Operators for Program : <cfoutput>#qGetOperators.contract_number#</cfoutput></b></td>
			</tr>
			<cfoutput  query="qGetOperators">
				<tr bgcolor="#IIf(qGetOperators.currentrow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
					<td>#Legacy_ID# - #Operator_Name#</td>
				</tr>
			</cfoutput>
		</table>