<cfsilent>
<!--- 
FILE: 		
FILENAME: 		doc_modules/inc_operator_group_query_html.cfm
CREATED: 		11/1/2011 - Milan
EDITED:			11/30/2011 - Milan (Added secondary operators)

FUNCTIONALITY:
- This file is utilized to get the operators (one or all).
--->
</cfsilent>

<cfset thisTag.lsOperatorIDs = trim(thisTag.lsOperatorIDs)>

<cfquery name="thisTag.qOperatorDetails" datasource="#application.datasource#">
    SELECT	* 
	FROM ##TMP_qProgramOperatorInfo
	 <!--- If THIS letter is per operator --->
	 <cfif listLen(thisTag.lsOperatorIDs,",") EQ 1>
	WHERE operator_id IN (#thisTag.lsOperatorIDs#)
	</cfif>
	ORDER BY Operator_Name
</cfquery>

<!--- Note: Operators on a program may have group members OR Not (mixed), but distributors on a program can be added either at the distributor level OR the group level --->
<!--- Get the secondary operators, i.e. operator members --->
<cfquery name="thisTag.qOperatorSecondaryDetails" datasource="#application.datasource#">
	SELECT	*
	FROM ##TMP_qProgramOperatorSecondaryInfo
</cfquery>