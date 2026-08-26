<html>
<head>
<title>Delete Deduction</title>
</head>
<body>

<cfoutput>
<cfif isDefined("form.blnSubmit")>

	<!---Update deduction to show it as deleted--->
	<cfset useLakebaseForDelete_Deduction = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForDelete_Deduction>
		<cftry>
			<cfset application.oLakebase.updateRows("deductions",
				{ "deduction_id" = "eq.#Deduction_ID#" },
				{
					"dd_date_closed" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
					"dd_closed_by" = request.AccessStructure.User_ID,
					"dd_status" = 6
				}
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForDelete_Deduction = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDelete_Deduction>
	<cfquery name="Delete_Deduction" datasource="#application.datasource#">
	UPDATE Deductions 
	SET 
	DD_Date_Closed = getdate(),
	DD_Closed_By = '#request.AccessStructure.User_ID#',
	DD_Status = 6
	WHERE Deduction_ID = '#Deduction_ID#'
	</cfquery>
	</cfif>

<script>
window.parent.location.href = '/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#'
</script>
<cfabort>
</cfif>
<div align="Center">
Are you sure you want to delete this deduction without closing it?

<p></p>
<a href="##" onclick="javaScript: return Delete_Deduction();"><strong><font color="navy">[ delete this deduction ]</strong></font></a></div>

<form name="DeleteDeduction" action="/deductions/closure/delete.cfm" method="post">
	<input type="hidden" name="Deduction_ID" value="#url.Deduction_ID#">
	<input type="hidden" name="blnSubmit" value="1">
</form>

<script>

function Delete_Deduction()
	{

		document.DeleteDeduction.submit();
		return false;
	}
</script>
</cfoutput>
</body>
</html>