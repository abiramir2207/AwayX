<html>
<head>
<title>Delete Deduction</title>
</head>
<body>

<cfoutput>
<cfif isDefined("form.blnSubmit")>

	<!---Update deduction to show it as deleted--->
	<cfset useLakebaseForUnDelete_Deduction = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForUnDelete_Deduction>
		<cftry>
			<cfset application.oLakebase.updateRows("deductions",
				{ "deduction_id" = "eq.#Deduction_ID#" },
				{
					"dd_date_closed" = javaCast("null", ""),
					"dd_closed_by" = "",
					"dd_status" = 2
				}
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForUnDelete_Deduction = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUnDelete_Deduction>
		<cfquery name="UnDelete_Deduction" datasource="#application.datasource#">
		UPDATE Deductions
		SET
		DD_Date_Closed = null,
		DD_Closed_By = '',
		DD_Status = 2
		WHERE Deduction_ID = '#Deduction_ID#'
		</cfquery>
	</cfif>
You undeleted it
 <script>
window.parent.location.href = '/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#'
</script> 

</cfif>
<div align="Center">
Are you sure you want to undelete this program? This will set the program status back to open.

<p></p>
<a href="##" onclick="UnDelete_Deduction()"><strong><font color="navy">[ undelete this deduction ]</strong></font></a></div>

<form name="UnDeleteDeduction" action="/deductions/closure/undelete.cfm" method="post">
	<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
	<input type="hidden" name="blnSubmit" value="1">
</form>

<script>

function UnDelete_Deduction()
	{

		document.UnDeleteDeduction.submit();
	}
</script>
</cfoutput>
</body>
</html>