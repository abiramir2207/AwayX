		<cfheader name="Content-Disposition" value="attachment; filename=OutboundFreight.csv">
		<cfcontent type="application/vnd.ms-excel"  file="#url.filename#">