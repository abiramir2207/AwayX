
<!--- <cfoutput>#path#</cfoutput><cfabort> --->

<cfoutput>
<cfheader name="Content-Disposition" value="attachment;filename=#ufn#">
<cfcontent type="text/plain"file="#path#"></cfoutput>



