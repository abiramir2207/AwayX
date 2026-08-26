<cfparam name="url.top" 	default="10">
<cfparam name="url.id" 		default="">

<cfset request.AccessStructure.User_Rights_ID = "9999">

<cfquery name="qGetErrorLog" datasource="#application.datasource#">


select 	top #url.top# Error_Structure
from	CFML_Error_Log
<cfif url.id NEQ "" AND isNumeric(url.id)>
where	CFML_Error_Log_ID = #url.id#
</cfif>
Order By CFML_Error_LOg_ID DESC




</cfquery>

<cfoutput>
<cfloop query="qGetErrorLog">

	<cftry>
	
	#Error_Structure#
	<hr>
	<!------ <CFWDDX ACTION="wddx2cfml" INPUT="#Error_Structure#" OUTPUT="oError_Structure">
	<cfdump var="#oError_Structure#"> ----->
	
		<cfcatch>
		
		</cfcatch>
	
	</cftry>
	
</cfloop>
</cfoutput>