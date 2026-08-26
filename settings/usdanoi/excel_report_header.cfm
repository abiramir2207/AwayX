<cfoutput>
	<tr>
		<td colspan="100%" bgcolor="##f0fff0" align="center">
			<p align="center"><b>Measured in 
			<cfswitch expression="#form.thisReportUOM#">
											<!--- case --->
											<cfcase value="1">Cases</cfcase>
											<cfcase value="2">Net Pounds</cfcase>
											<cfcase value="rm">Raw Materials</cfcase>
			</cfswitch></b>
		</td>
	</tr>
	<tr  >
		<td><b>Operator</b></td>
		<td><b>RA Number</b></td>
		<td><b>Title</b></td>
		<td><b>Invoice Number</b></td>
		<td><b>Invoice Date</b></td>
		<td><b>Item Number</b></td>
		<td><b>Item Description</b></td>
		<td><b>PTV</b></td>
		<td><b>Current</b></td>
		<td><b>Cases</b></td>
		<td><b>Value</b></td>
	</tr>
</cfoutput>