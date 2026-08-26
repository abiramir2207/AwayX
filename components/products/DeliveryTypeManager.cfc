<cfcomponent hint="Delivery Type" extends="components.Base">

	<cffunction name="init" output="false" returntype="components.products.DeliveryTypeManager">
	
		<cfreturn this />
		
	</cffunction>

	
	<cffunction name="getDeliveryType" output="false" returntype="query">
		
		<cfquery name="qGetDeliveryType" datasource="#application.datasource#">
			SELECT 	Delivery_Type_Desc,
					Delivery_Type_ID
			FROM 	Delivery_Type
			WHERE 	Deleted = 0
		</cfquery>
		
		<cfreturn qGetDeliveryType />
		
	</cffunction>
	
	<cffunction name="getDeliveryTypeDesc" output="false" returntype="string">
	
		<cfargument name="id" type="numeric" required="true"/>
		
		<cfset desc = "">
		
		<cfquery name="qGetDeliveryTypeDesc" datasource="#application.datasource#">
			SELECT 	Delivery_Type_Desc,
					Delivery_Type_ID
			FROM 	Delivery_Type
			WHERE 	Deleted = 0
					AND
					Delivery_Type_ID = #arguments.id#
		</cfquery>
		
		<cfloop query="qGetDeliveryTypeDesc">
		
			<cfset desc = Delivery_Type_Desc>
		
		</cfloop>
		
		<cfreturn desc />
		
	</cffunction>

</cfcomponent>