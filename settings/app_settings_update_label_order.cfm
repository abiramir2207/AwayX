<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get(0) />
<cfset appSettings.setUpdatedBy(request.AccessStructure.User_ID) />

<cfif tableCode EQ "BB">
	<cfset genSettingsManager.save(9) />
</cfif>
<cfif tableCode EQ "PB">
	<cfset genSettingsManager.save(10) />
</cfif>

<cfset colList = listDeleteAt(colList,listlen(colList))>

<cfset row = 1>
<cfloop list="#colList#" index="id" delimiters=",">

	<cfif row LT 10>
		<cfset activeSequence = '000' & row>
	<cfelseif row GTE 10 AND row LT 100>
		<cfset activeSequence = '00' & row>
	<cfelseif row GTE 100 AND row LT 1000>
		<cfset activeSequence = '0' & row>
	<cfelseif row GTE 1000 AND row LT 10000>
		<cfset activeSequence = row>
	</cfif>

	<cfquery name="updateOrder" datasource="#application.datasource#">
		UPDATE BB_Auto_Report_Export_Labels
		SET sequence = '#activeSequence#'
		WHERE BB_Auto_Report_Export_Labels_ID = '#id#'
			AND Table_code = '#tableCode#'
	</cfquery>

	<cfset row = row + 1>

</cfloop>