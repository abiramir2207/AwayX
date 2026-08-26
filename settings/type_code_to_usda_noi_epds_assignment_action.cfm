<CFSET DeleteList = "">
<CFSET InsertList = "">

<cfset useLakebaseForgetCurrentlySelectedTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("usda_noi_epds_type")>
<cfif useLakebaseForgetCurrentlySelectedTypes>
	<cftry>
		<cfset getCurrentlySelectedTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("usda_noi_epds_type", {
				"usda_noi_epds_id" = "eq.#form.usda_noi_epds_id#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCurrentlySelectedTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCurrentlySelectedTypes>
<cfquery name="getCurrentlySelectedTypes" datasource="#application.datasource#">
	SELECT *
	FROM usda_noi_epds_type
	WHERE usda_noi_epds_ID = '#form.usda_noi_epds_id#'
	AND Deleted = 0
</cfquery>
</cfif>
<CFSET CurrentlySelectedList = valuelist(getCurrentlySelectedTypes.type_id)>


<cf_list_compare list1="#CurrentlySelectedList#" list2="#FORM.Types#">
<CFSET DeleteList 	= LC_Results1>
<CFSET InsertList 		= LC_Results2>

<cfset InsertList = form.Types>

<cfif listlen(InsertList) GT 0>
	<cfloop index="x" list="#InsertList#" delimiters=",">
		<cfset useLakebaseForInsert = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("usda_noi_epds_type")>
<cfif useLakebaseForInsert>
	<cftry>
		<cfset application.oLakebase.insertRow("usda_noi_epds_type", {
			"usda_noi_epds_id" = "#form.usda_noi_epds_ID#",
			"type_id" = "#x#",
			"active" = "0"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsert = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsert>
<cfquery name="Insert" datasource="#application.datasource#">
			INSERT INTO usda_noi_epds_type
			(usda_noi_epds_ID,Type_ID,Active)
			VALUES
			('#form.usda_noi_epds_ID#','#x#',0)
		</cfquery>
</cfif>	
	</cfloop>
</cfif>

<cfif listlen(DeleteList) GT 0>
	<cfloop index="x" list="#DeleteList#" delimiters=",">
		<cfset useLakebaseForDelete = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("usda_noi_epds_type")>
<cfif useLakebaseForDelete>
	<cftry>
		<cfset application.oLakebase.updateRows("usda_noi_epds_type",
			{
				"usda_noi_epds_id" = "eq.#form.usda_noi_epds_ID#",
				"type_id" = "eq.#x#"
			},
			{
				"deleted" = "1",
				"active" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDelete = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete>
<cfquery name="Delete" datasource="#application.datasource#">
			UPDATE usda_noi_epds_type
			SET Deleted = 1, Active = 0
			WHERE usda_noi_epds_ID = '#form.usda_noi_epds_ID#' AND Type_ID = '#x#'
		</cfquery>
</cfif>	
	</cfloop>
</cfif>

<script>
	window.close();
</script>