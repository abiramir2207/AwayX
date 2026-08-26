	<!--- Return Budget UOM --->
	<cffunction name="getVolumeUOM" output="false" returnType="query">
		<cfset useLakebaseForqGetVolumeUOM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("budget_volume_uom")>
<cfif useLakebaseForqGetVolumeUOM>
	<cftry>
		<cfset qGetVolumeUOM = application.oLakebase.toQuery(
			application.oLakebase.selectRows("budget_volume_uom", {
				"order" = "volume_uom_id.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetVolumeUOM = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetVolumeUOM>
<cfquery name="qGetVolumeUOM" datasource="#application.datasource#">
			select * from budget_volume_uom
			order by volume_uom_id ASC
		</cfquery>
</cfif>
	
		<cfreturn qGetVolumeUOM />
	</cffunction>
