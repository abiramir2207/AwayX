
<!--- <cfparam name="form.date_period"	default="2/1/2012"	type="string"> --->

<cfquery name="get_data" datasource="#Application.Datasource#">

SELECT 			top 2000 -- limit the number of records returned
				dbo.Snapshot_Metadata_Item_Type.snapshot_metadata_item_type_description,
				dbo.Snapshot_Metadata.snapshot_metadata_id,
				dbo.Snapshot_Metadata.item_id,
				dbo.Snapshot_Metadata.item_name

	FROM		dbo.Snapshot_Metadata_Item_Type

	INNER JOIN	dbo.Snapshot_Metadata ON dbo.Snapshot_Metadata.item_type_code = dbo.Snapshot_Metadata_Item_Type.snapshot_metadata_item_type_code

	WHERE		Snapshot_Metadata.metadata LIKE '%#form.searchfor#%'
				AND	
				date_period = '#form.date_period#'
				AND	
				item_type_code =  #i#
				AND 
				Snapshot_Metadata.deleted = 0

	ORDER BY	item_type_code

</cfquery>

<cfquery name="get_type_code" datasource="#Application.Datasource#">

	SELECT		dbo.Snapshot_Metadata_Item_Type.snapshot_metadata_item_type_description,
				dbo.Snapshot_Metadata_Item_Type.snapshot_metadata_item_type_code
				
	FROM		dbo.Snapshot_Metadata_Item_Type
	
	WHERE		dbo.Snapshot_Metadata_Item_Type.snapshot_metadata_item_type_code = #i#
				AND
				dbo.Snapshot_Metadata_Item_Type.deleted = 0
</cfquery>