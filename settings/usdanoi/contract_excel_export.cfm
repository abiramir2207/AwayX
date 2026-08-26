
	
	<cfcontent type="application/unknown">
		<cfheader name="Content-Disposition" value="attachment;filename=NOIReport.xls">

	<cfoutput>	
	<CFINCLUDE TEMPLATE="#url.file#">
	</cfoutput>