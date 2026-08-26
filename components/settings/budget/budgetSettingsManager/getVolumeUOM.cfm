	<!--- Return Budget UOM --->
	<cffunction name="getVolumeUOM" output="false" returnType="query">
		<cfquery name="qGetVolumeUOM" datasource="#application.datasource#">
			select * from budget_volume_uom
			order by volume_uom_id ASC
		</cfquery>
	
		<cfreturn qGetVolumeUOM />
	</cffunction>
