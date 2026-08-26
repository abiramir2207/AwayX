		<cfheader name="Content-Disposition" value="attachment; filename=Alias_products.csv">
		<cfcontent type="text/plain"  file="#url.FileName#">