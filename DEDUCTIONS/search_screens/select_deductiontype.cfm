<!---
  This shared template is included in both simple search and advanced search.

--->

<!--- any changes to this cached query should be done to the same query in 
      \deductions\settings\classification\save_classifications.cfm,
      otherwise users may not see all the latest changes --->
<cfset useLakebaseForrsDeductionType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_type")>
<cfif useLakebaseForrsDeductionType>
	<cftry>
		<cfset rsDeductionType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deduction_type", {
				"select" = "deductiontype_desc,deductiontype_id",
				"deleted" = "eq.0",
				"order" = "deductiontype_desc.asc"
			}),
			"deductiontype_desc,deductiontype_id"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForrsDeductionType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForrsDeductionType>
<cfquery name="rsDeductionType" datasource="#application.DataSource#" <!---cachedWithin="#application.userDataCacheSpan#"--->>
  SELECT DeductionType_Desc, DeductionType_ID
    FROM Deduction_Type
   WHERE Deleted = 0
ORDER BY DeductionType_Desc
</cfquery>
</cfif>		   

<cfoutput><b>#stDeductionLabels["Deduction Type"]#:</b><br/></cfoutput>

<select name="deductiontype" id="deductiontype" style="width:240px" multiple="multiple">
  <option value="0">**Any** <cfoutput>#stDeductionLabels["Deduction Type"]#</cfoutput></option>
  <cfoutput query="rsDeductionType">
    <option value="#rsDeductionType.DeductionType_ID#">#rsDeductionType.DeductionType_Desc#</option>
  </cfoutput>
</select>
