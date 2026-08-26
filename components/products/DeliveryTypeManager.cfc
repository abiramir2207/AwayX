<cfcomponent hint="Delivery Type" extends="components.Base">

	<cffunction name="init" output="false" returntype="components.products.DeliveryTypeManager">
	
		<cfreturn this />
		
	</cffunction>

	
	<cffunction name="getDeliveryType" output="false" returntype="query">
		
		<cfset useLakebaseForqGetDeliveryType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("delivery_type")>
<cfif useLakebaseForqGetDeliveryType>
	<cftry>
		<cfset qGetDeliveryType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("delivery_type", {
				"deleted" = "eq.0",
				"select" = "delivery_type_desc,delivery_type_id"
			}), "delivery_type_desc,delivery_type_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDeliveryType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDeliveryType>
<cfquery name="qGetDeliveryType" datasource="#application.datasource#">
			SELECT 	Delivery_Type_Desc,
					Delivery_Type_ID
			FROM 	Delivery_Type
			WHERE 	Deleted = 0
		</cfquery>
</cfif>
		
		<cfreturn qGetDeliveryType />
		
	</cffunction>
	
	<cffunction name="getDeliveryTypeDesc" output="false" returntype="string">
	
		<cfargument name="id" type="numeric" required="true"/>
		
		<cfset desc = "">
		
		<cfset useLakebaseForqGetDeliveryTypeDesc = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("delivery_type")>
<cfif useLakebaseForqGetDeliveryTypeDesc>
	<cftry>
		<cfset qGetDeliveryTypeDesc = application.oLakebase.toQuery(
			application.oLakebase.selectRows("delivery_type", {
				"deleted" = "eq.0",
				"delivery_type_id" = "eq.#arguments.id#",
				"select" = "delivery_type_desc,delivery_type_id"
			}), "delivery_type_desc,delivery_type_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDeliveryTypeDesc = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDeliveryTypeDesc>
<cfquery name="qGetDeliveryTypeDesc" datasource="#application.datasource#">
			SELECT 	Delivery_Type_Desc,
					Delivery_Type_ID
			FROM 	Delivery_Type
			WHERE 	Deleted = 0
					AND
					Delivery_Type_ID = #arguments.id#
		</cfquery>
</cfif>
		
		<cfloop query="qGetDeliveryTypeDesc">
		
			<cfset desc = Delivery_Type_Desc>
		
		</cfloop>
		
		<cfreturn desc />
		
	</cffunction>

</cfcomponent>