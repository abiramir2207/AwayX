<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get(0) />
<cfset appSettings.setUpdatedBy(request.AccessStructure.User_ID) />
<cfset genSettingsManager.save(11) />


<!--- CREATES A SEQUENCE FOR LABELS (CALLED FROM AJAX.REQUEST IN app_settings_6.cfm) --->
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
		UPDATE Table_Column_Labels
		SET sequence = '#activeSequence#'
		WHERE Table_Column_Labels_ID = '#id#'
			AND Table_Name = '#tblName#'
	</cfquery>

	<cfset row = row + 1>

</cfloop>