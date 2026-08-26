<!---
  This shared template is included in both simple search and advanced search.

--->

<cfset useLakebaseForrsClassification = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
<cfif useLakebaseForrsClassification>
	<cftry>
		<cfset rsClassification = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_classification", {
				"select" = "dd_classification_desc,dd_classification_id",
				"deleted" = "eq.0",
				"order" = "dd_classification_desc.asc"
			}),
			"dd_classification_desc,dd_classification_id"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForrsClassification = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForrsClassification>
<cfquery name="rsClassification" datasource="#application.DataSource#">
  SELECT DD_Classification_Desc, DD_Classification_ID
    FROM DD_Classification
   WHERE Deleted = 0
ORDER BY DD_Classification_Desc
</cfquery>
</cfif>		   

<cfoutput><b>#stDeductionLabels["Classification"]#:</b><br/></cfoutput>

<select name="classification" id="classification" style="width:240px" multiple="multiple">
  <option value="0">**Any** <cfoutput>#stDeductionLabels["Classification"]#</cfoutput></option>
  <cfoutput query="rsClassification">
    <option value="#rsClassification.DD_Classification_ID#">#rsClassification.DD_Classification_Desc#</option>
  </cfoutput>
</select>
