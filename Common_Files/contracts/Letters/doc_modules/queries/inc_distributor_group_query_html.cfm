<cfsilent>
<!--- 
FILE: 		
FILENAME: 		doc_modules/inc_distributor_group_query_html.cfm
CREATED: 		11/1/2011 - Milan
EDITED:	

FUNCTIONALITY:
- This file is utilized to get the distributors - groups or individual distributors).
--->
</cfsilent>

<cfset thisTag.lsDistributorIDs = trim(thisTag.lsDistributorIDs)>

<!--- Get the distributor details for GROUPS --->
<cfquery name="thisTag.qDistDetails" datasource="#application.datasource#">
    SELECT	* 
	FROM 
	<!--- If it is an operator letter, query from "TMP_qProgramAllDistributorInfo". - All distributors
	      If it is a distributor letter, query from "TMP_qProgramDistributorInfo".
	--->
	<cfif thisTag.abbreviation eq "opr">##TMP_qProgramAllDistributorInfo<cfelse>##TMP_qProgramDistributorInfo</cfif>
	WHERE Is_Group = 1
	AND Captured_From_Group = 0  
	<!--- If THIS letter is per distributor... --->
	<cfif listLen(thisTag.lsDistributorIDs,",") EQ 1>
	AND contract_distributors_id IN (#thisTag.lsDistributorIDs#)
	<!--- no distributor --->
	<cfelseif listLen(thisTag.lsDistributorIDs,",") EQ 0>
	AND 1 = 0
	</cfif>
	ORDER BY Group_Desc
</cfquery>

<!--- CALCULATE THE APPPENDIX ALPHABET (Appendix need to have an alphabet associated with it - A,B,C etc):
				Order of preference (starting with "A"): 1- Operator members, 2- distributor members, 3 - clauses
--->
<!--- If "secondary operators" AND "distributor groups" AND Clauses exist --->
<cfif thisTag.qOperatorSecondaryDetails.recordcount GTE 1 AND thisTag.qDistDetails.recordcount GTE 1 AND thisTag.qProgramClause.recordCount GTE 1>	
	<cfset OprAppendixAlphabet = "A"> 
	<cfset distAppendixAlphabet = "B">
	<cfset clauseAppendixAlphabet = "C">
<!--- If only "distributor groups" AND Clauses exist --->
<cfelseif thisTag.qOperatorSecondaryDetails.recordcount EQ 0 AND thisTag.qDistDetails.recordcount GTE 1 AND thisTag.qProgramClause.recordCount GTE 1>	
	<cfset distAppendixAlphabet = "A">
	<cfset clauseAppendixAlphabet = "B">	
<!--- If only Clauses exist --->
<cfelseif thisTag.qOperatorSecondaryDetails.recordcount EQ 0 AND thisTag.qDistDetails.recordcount EQ 0 AND thisTag.qProgramClause.recordCount GTE 1>	
	<cfset clauseAppendixAlphabet = "A">	
<!--- If only "secondary operators" AND Clauses exist --->
<cfelseif thisTag.qOperatorSecondaryDetails.recordcount GTE 1 AND thisTag.qDistDetails.recordcount EQ 0 AND thisTag.qProgramClause.recordCount GTE 1>	
	<cfset OprAppendixAlphabet = "A">
	<cfset clauseAppendixAlphabet = "B">	
<!--- If only "secondary operators" exist --->
<cfelseif thisTag.qOperatorSecondaryDetails.recordcount GTE 1 AND thisTag.qDistDetails.recordcount EQ 0 AND thisTag.qProgramClause.recordCount EQ 0>	
	<cfset OprAppendixAlphabet = "A">
<!--- If only "distributor groups" exist --->
<cfelseif thisTag.qOperatorSecondaryDetails.recordcount EQ 0 AND thisTag.qDistDetails.recordcount GTE 1 AND thisTag.qProgramClause.recordCount EQ 0>	
	<cfset distAppendixAlphabet = "A">
<!--- If only "secondary operators" AND "distributor groups" exist --->
<cfelseif thisTag.qOperatorSecondaryDetails.recordcount GTE 1 AND thisTag.qDistDetails.recordcount GTE 1 AND thisTag.qProgramClause.recordCount EQ 0>
	<cfset OprAppendixAlphabet = "A"> 
	<cfset distAppendixAlphabet = "B">
</cfif>

<!--- If there are NO DISTRIBUTOR GROUPS, get DISTRIBUTORS --->
<cfif thisTag.qDistDetails.recordcount eq 0>
	<cfquery name="thisTag.qDistDetails" datasource="#application.datasource#">
	    SELECT	* 
		FROM 
		<!--- If it is an operator letter, query from "TMP_qProgramAllDistributorInfo". - All distributors
	          If it is a distributor letter, query from "TMP_qProgramDistributorInfo".
		--->
		<cfif thisTag.abbreviation eq "opr">##TMP_qProgramAllDistributorInfo<cfelse>##TMP_qProgramDistributorInfo</cfif>
		WHERE Is_Group = 0
		<!--- "Captured_From_Group" has to be 0 because we are not looking for distributor group members here. Here we need distributors only. ---> 
		AND Captured_From_Group = 0
		<!--- If THIS letter is per distributor... --->
		<cfif listLen(thisTag.lsDistributorIDs,",") EQ 1>
		AND contract_distributors_id IN (#thisTag.lsDistributorIDs#)
		<!--- no distributor --->
		<cfelseif listLen(thisTag.lsDistributorIDs,",") EQ 0>
		AND 1 = 0
		</cfif>
		ORDER BY Name
	</cfquery>
</cfif>