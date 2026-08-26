<CFSET DeleteList = "">
<CFSET InsertList = "">

<cfquery name="getCurrentlySelectedTypes" datasource="#application.datasource#">
	SELECT *
	FROM usda_noi_epds_type
	WHERE usda_noi_epds_ID = '#form.usda_noi_epds_id#'
	AND Deleted = 0
</cfquery>
<CFSET CurrentlySelectedList = valuelist(getCurrentlySelectedTypes.type_id)>


<cf_list_compare list1="#CurrentlySelectedList#" list2="#FORM.Types#">
<CFSET DeleteList 	= LC_Results1>
<CFSET InsertList 		= LC_Results2>

<cfset InsertList = form.Types>

<cfif listlen(InsertList) GT 0>
	<cfloop index="x" list="#InsertList#" delimiters=",">
		<cfquery name="Insert" datasource="#application.datasource#">
			INSERT INTO usda_noi_epds_type
			(usda_noi_epds_ID,Type_ID,Active)
			VALUES
			('#form.usda_noi_epds_ID#','#x#',0)
		</cfquery>	
	</cfloop>
</cfif>

<cfif listlen(DeleteList) GT 0>
	<cfloop index="x" list="#DeleteList#" delimiters=",">
		<cfquery name="Delete" datasource="#application.datasource#">
			UPDATE usda_noi_epds_type
			SET Deleted = 1, Active = 0
			WHERE usda_noi_epds_ID = '#form.usda_noi_epds_ID#' AND Type_ID = '#x#'
		</cfquery>	
	</cfloop>
</cfif>

<script>
	window.close();
</script>