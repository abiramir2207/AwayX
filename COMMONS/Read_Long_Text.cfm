<CFSILENT>

<!-------------------- Inputs ------------------------------------->
<!------------------------------------------------------------------
1. GetTextData_dataSourceName 	= 	The datasoucename to be used	
2. GetTextData_tableName		=	Table name to query against		
3. GetTextData_fieldName		=	Field name to retrieve			
--------------------------------------------------------------------
4. GetTextData_whereClause		=	Any where condition. 			
									(Default "")					
Should have the complete string										
eg: "WHERE a=b"														
------------------------------------------------------------------->

<!-------------------- Outputs ------------------------------------>
<!-------------------------											
1. GetTextData_totalTextValue	=	The result field value			
------------------------------------------------------------------->


<CFSET GetTextData_eachResultLen=8000>

<cfparam name="GetTextData_dataSourceName" 	default="">
<cfparam name="GetTextData_eachResultLen" 	default=8000>
<cfparam name="GetTextData_tableName" 		default="">
<cfparam name="GetTextData_fieldName" 		default="">
<cfparam name="GetTextData_whereClause" 	default="">


<CFIF  GetTextData_dataSourceName EQ "">
	<CFEXIT>
</CFIF>
<CFIF  GetTextData_tableName EQ "">
	<CFEXIT>
</CFIF>
<CFIF  GetTextData_fieldName EQ "">
	<CFEXIT>
</CFIF>




<CFSET GetTextData_totalTextValue="">
<CFQUERY  DATASOURCE="#GetTextData_dataSourceName#" NAME="readTextLen">
SELECT DATALENGTH(#GetTextData_fieldName#)/#GetTextData_eachResultLen# AS TextLen, DATALENGTH(#GetTextData_fieldName#) % #GetTextData_eachResultLen# AS TextLenMod FROM #GetTextData_tableName# #PreserveSingleQuotes(GetTextData_whereClause)#
</CFQUERY>
<CFSET GetTextData_numResult=readTextLen.TextLen>
<CFIF readTextLen.TextLenMod GT 0>
	<CFSET GetTextData_numResult=GetTextData_numResult+1>
</CFIF>



<CFSTOREDPROC PROCEDURE="READ_LONG_TEXT" DATASOURCE="#GetTextData_dataSourceName#">
	<CFPROCPARAM TYPE="IN" CFSQLType="CF_SQL_VARCHAR" DBVARNAME="@@TABLE_NAME" VALUE="#GetTextData_tableName#">
	<CFPROCPARAM TYPE="IN" CFSQLType="CF_SQL_VARCHAR" DBVARNAME="@@FIELD_NAME" VALUE="#GetTextData_fieldName#">
	<CFPROCPARAM TYPE="IN" CFSQLType="CF_SQL_VARCHAR" DBVARNAME="@@CONDITION" VALUE="#GetTextData_whereClause#">
	<CFPROCPARAM TYPE="IN" CFSQLType="CF_SQL_INTEGER" DBVARNAME="@@RESULT_LENGTH" VALUE="#GetTextData_eachResultLen#">
	<CFLOOP INDEX="i" FROM="1" TO="#GetTextData_numResult#">
		<CFPROCRESULT NAME="GetTextData_p#i#" RESULTSET="#i#">
	</CFLOOP>
</CFSTOREDPROC>

<CFSET totalLen=0>
<CFLOOP INDEX="i" FROM="1" TO="#GetTextData_numResult#">
	<CFIF IsDefined("GetTextData_p#i#.textValue")>
		<CFSET GetTextData_totalTextValue="#GetTextData_totalTextValue##Evaluate("GetTextData_p#i#.textValue")#">
	</CFIF>
</CFLOOP>

<!---
<CFOUTPUT>#Len(GetTextData_totalTextValue)#<br></CFOUTPUT>
<CFOUTPUT>#GetTextData_totalTextValue#</CFOUTPUT>
--->
</CFSILENT>