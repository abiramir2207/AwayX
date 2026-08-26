<cfset variables.userQry = event.getvalue('userList') />
<!--- Remove CF Output --->
<cfsetting showdebugoutput="false">
<!--- Remove the COldBox Debugging --->
<cfset event.showdebugpanel("false")>
<cfcontent reset="true"><cfloop query="variables.userQry"><cfoutput>#name_first# #name_last##Chr(10)#</cfoutput></cfloop>