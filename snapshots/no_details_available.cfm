<!--- ----------------------------------------------------------------------------------------- --->
<cfif #get_summary.recordcount# EQ 0>
	<div style="margin:225px 0px 225px 0px; text-align:center">
	<strong>NO DETAIL DATA AVAILABLE</strong>
	<br /><br />
	<a href="#" onClick="history.back();">[ review result set ]</a>
	</div>
	<cfabort>
</cfif>
<!--- ----------------------------------------------------------------------------------------- --->
