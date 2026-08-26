<cf_cryp type="de" string ="#URL.CID#" key="#request.key#">
<CFSET Program_ID = cryp.value>

<cfquery name="getprogramuseragreed" datasource="#application.datasource#">
	SELECT User_Agree
	FROM Program_Agree
	WHERE USER_ID = '#request.AccessStructure.User_id#'
	AND PROGRAMID = #Program_ID#
</CFQUERY>

<CFIF getprogramuseragreed.recordcount GT 0>
<cfset useragreed = 1>
<cfelse>
<cfset useragreed = 0>
</CFIF>