<!--- This gets called from an AJAX call and is the interface between index.cfm and DivestedItems.cfc --->

<!--- Initialize connection CFC - /components/settings/DivestedItems.cfc --->
	<cfset DivestedItems = CreateObject("component", "components.settings.DivestedItems").init() />

<!--- Delete the record --->
<Cfif new_Deleted_Status IS 1> 
	<cfset UpdateThisRecord = DivestedItems.deleteDivestedItem(Item_ID, User_ID) />
</Cfif>
