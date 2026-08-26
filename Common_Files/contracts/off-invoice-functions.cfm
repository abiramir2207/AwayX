<!------ off-invoice-functions.cfm ----->

<!------ 
We will be storing all selected component level information in the comma separated list off_invoice_component_info_list
format: component_id_1, component_id_2
off_invoice_component_list will hold just the list of components selected
----->
<cffunction name="extractOffInvoiceComponentList" output="false" returntype="string">
	<cfargument name="lst_off_invoice_component_info" type="string" required="true" />	

	<cfset return_off_invoice_component_list = "" />
	<cfloop list="#arguments.lst_off_invoice_component_info#" delimiters="," index="componentInfo">
		<cfset currentComponentId = getOffInvoiceComponentNameId(componentInfo) />
		<cfset return_off_invoice_component_list = ListAppend(return_off_invoice_component_list, currentComponentId, ",") />
	</cfloop>
	<cfreturn return_off_invoice_component_list />
</cffunction>

<cffunction name="compileOffInvoiceComponentInfo" output="false" returntype="string">
	<cfargument name="componentId" type="string" required="true" />
	<cfargument name="treatmentCodeId" type="string" required="true" />
	<cfargument name="basisCodeId" type="string" required="true" />

	<cfset return_off_invoice_component_info = "" />
	<cfset return_off_invoice_component_info = ListAppend(return_off_invoice_component_info, arguments.componentId, "~") />
	<cfset return_off_invoice_component_info = ListAppend(return_off_invoice_component_info, arguments.treatmentCodeId, "~") />
	<cfset return_off_invoice_component_info = ListAppend(return_off_invoice_component_info, arguments.basisCodeId, "~") />
	
	<cfreturn return_off_invoice_component_info />
</cffunction>

<cffunction name="getArrayOffInvoiceComponentInfo" output="false" returntype="array">
	<cfargument name="lst_off_invoice_component_info" type="string" required="true" />
	<cfargument name="qComponents" type="query" required="true" />

	<cfset var ar_off_invoice_component_info = Arraynew(1) />
	<cfset var st_off_invoice_component_info = "" />
	
	<cfloop list="#arguments.lst_off_invoice_component_info#" delimiters="," index="componentInfo">
		<cfset st_off_invoice_component_info = StructNew() />
		<cfset st_off_invoice_component_info.ComponentNameId = getOffInvoiceComponentNameId(componentInfo) />
		<cfset st_off_invoice_component_info.treatmentCodeId = getOffInvoiceComponentTreatmentCodeId(componentInfo) />
		<cfset st_off_invoice_component_info.basisCodeId = getOffInvoiceComponentBasisCodeId(componentInfo) />
		
		<cfquery name="Get_Program_OffInvoice_Component_Info" dbtype="query">
			SELECT	Program_OffInvoice_Component_Name, Required_Effective_Rate_Percent
			FROM	arguments.qComponents
			WHERE	Program_OffInvoice_Component_Name_ID = #st_off_invoice_component_info.ComponentNameId#
		</cfquery>
		<cfset st_off_invoice_component_info.ComponentName = Get_Program_OffInvoice_Component_Info.Program_OffInvoice_Component_Name />
		<cfset st_off_invoice_component_info.EffectiveMarginFlag = 0 />
		<cfif IsNumeric(Get_Program_OffInvoice_Component_Info.Required_Effective_Rate_Percent)>
			<cfset st_off_invoice_component_info.EffectiveMarginFlag = Get_Program_OffInvoice_Component_Info.Required_Effective_Rate_Percent />
		</cfif>
		
		<cfset ArrayAppend(ar_off_invoice_component_info, st_off_invoice_component_info) />
	</cfloop>
	<cfreturn ar_off_invoice_component_info />
</cffunction>

<cffunction name="CheckExistOffInvoiceComponentId" output="false" returntype="string">
	<cfargument name="lst_off_invoice_component_info" type="string" required="true" />
	<cfargument name="off_invoice_component_id" type="numeric" required="true" />

	<cfset i = 0 />
	<cfloop list="#arguments.lst_off_invoice_component_info#" delimiters="," index="componentInfo">
		<cfset i = i + 1 />
		<cfset currentComponentId = ListFirst(componentInfo, "~") />
		<cfif currentComponentId eq arguments.off_invoice_component_id>
			<cfreturn i />
		</cfif>		
	</cfloop>
	<cfreturn 0 />
</cffunction>

<cffunction name="getOffInvoiceComponentNameId" output="false" returntype="string">
	<cfargument name="off_invoice_component_info" type="string" required="true" />

	<cfif ListLen(arguments.off_invoice_component_info, "~") GTE 1>
		<cfreturn Trim(ListGetAt(arguments.off_invoice_component_info, 1, "~")) />
	</cfif>
	
	<cfreturn "" />
</cffunction>

<cffunction name="getOffInvoiceComponentTreatmentCodeId" output="false" returntype="string">
	<cfargument name="off_invoice_component_info" type="string" required="true" />

	<cfif ListLen(arguments.off_invoice_component_info, "~") GTE 2>
		<cfreturn Trim(ListGetAt(arguments.off_invoice_component_info, 2, "~")) />
	</cfif>
	
	<cfreturn "" />
</cffunction>

<cffunction name="getOffInvoiceComponentBasisCodeId" output="false" returntype="string">
	<cfargument name="off_invoice_component_info" type="string" required="true" />

	<cfif ListLen(arguments.off_invoice_component_info, "~") GTE 3>
		<cfreturn Trim(ListGetAt(arguments.off_invoice_component_info, 3, "~")) />
	</cfif>
	
	<cfreturn "" />
</cffunction>