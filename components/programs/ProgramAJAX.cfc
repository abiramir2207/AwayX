<!---  
       Name:          ProgramAjax.cfc    
       Copyright:     Copyright (c) 2008 Blacksmith Applications, Inc.  
       Created Date:  9/3/2008
       Created By:    Milan
       Description:   Use this file to make AJAX calls for the program
--->
<!--- Dev Note: 23171 - We do not require this anymore --->
<!---
 <cfcomponent extends="components.ajaxCFC.ajax">

	<cffunction name="CallRevisionReportNightly" output="no" returntype="numeric">
		<cfargument	name="programID" type="string" required="true" >

		<cftry>
		 	<cfstoredproc procedure="SP_Revision_Report_Nightly" datasource="#application.datasource#">
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName="@@CONTRACT_MAIN_ID" value="#arguments.programId#" />
			</cfstoredproc>
			<cfcatch>
				<cfset logError('AJAX_Errors','#CFCATCH#','Call_SP_Revision_Report_Nightly: Program','#arguments.programId#')>
				<cfrethrow />
			</cfcatch>
		</cftry>

			<cfreturn 1>
	</cffunction>

</cfcomponent>
--->