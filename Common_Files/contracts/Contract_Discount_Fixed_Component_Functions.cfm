<!------ Contract_Discount_Fixed_Component_Functions.cfm ----->

<cffunction name="compileComponentInfo" output="false" returntype="string">
	<cfargument name="componentId" type="string" required="true" />
	<cfargument name="componentPaidTo" type="string" required="true" />
	<cfargument name="treatmentCodeId" type="string" required="true" default="0" />
	<cfargument name="basisCodeId" type="string" required="true" default="0" />
	<cfargument name="claimMechanics" type="string" required="true" />
	<cfargument name="GL_Account_ID" type="string" required="false" default="0" />
	<cfargument name="Vendor_Master_ID" type="string" required="false" />
	<cfargument name="PaymentCycle" type="string" required="false" />
	<cfargument name="VendorSelection" type="string" required="false" />
	<cfargument name="parentProgramFixedComponentID" type="string" required="false" />
	<cfargument name="Payee_Selection" type="string" required="false"  default=""/>
	<cfargument name="IsSecondComponent" type="string" required="false" default="0" />

	<!--- Dev Note: KAL : D13043: Claim Mechanism on Fixed Price Page  --->
	<cfif  LEN(TRIM(arguments.treatmentCodeId)) EQ 0 >
		<cfset arguments.treatmentCodeId = "0" />
	</cfif>
	<cfif  LEN(TRIM(arguments.basisCodeId)) EQ 0 >
		<cfset arguments.basisCodeId = "0" />
	</cfif>
	<cfif LEN(TRIM(arguments.GL_Account_ID)) EQ 0>
		<cfset arguments.GL_Account_ID = "0" />
	</cfif>
	<cfif  LEN(TRIM(arguments.VendorSelection)) EQ 0 >
		<cfset arguments.VendorSelection = "0" />
	</cfif>
	<cfif  LEN(TRIM(arguments.parentProgramFixedComponentID)) EQ 0 >
		<cfset arguments.parentProgramFixedComponentID = "0" />
	</cfif>
	<cfif  LEN(TRIM(arguments.PaymentCycle)) EQ 0 >
		<cfset arguments.PaymentCycle = "0" />
	</cfif>
	<cfif  LEN(TRIM(arguments.Payee_Selection)) EQ 0 >
		<cfset arguments.Payee_Selection = "0" />
	</cfif>
	<cfif  LEN(TRIM(arguments.IsSecondComponent)) EQ 0 >
		<cfset arguments.IsSecondComponent = "0" />
	</cfif>

	<cfset return_component_info = "" />
	<cfset return_component_info = ListAppend(return_component_info, arguments.componentId, "~") />
	<cfset return_component_info = ListAppend(return_component_info, arguments.componentPaidTo, "_") />
	<cfset return_component_info = ListAppend(return_component_info, arguments.treatmentCodeId, "_") />
	<cfset return_component_info = ListAppend(return_component_info, arguments.basisCodeId, "_") />
	<cfset return_component_info = ListAppend(return_component_info, arguments.claimMechanics, "_") />
	<cfset return_component_info = ListAppend(return_component_info, arguments.GL_Account_ID, "_") />
	<cfset return_component_info = ListAppend(return_component_info, arguments.Vendor_Master_ID, "_") />
	<cfset return_component_info = ListAppend(return_component_info, arguments.PaymentCycle, "_") />
	<cfset return_component_info = ListAppend(return_component_info, arguments.VendorSelection, "_") />
	<cfset return_component_info = ListAppend(return_component_info, arguments.parentProgramFixedComponentID, "_") />
	<cfset return_component_info = ListAppend(return_component_info, arguments.Payee_Selection, "_") />
	<cfset return_component_info = ListAppend(return_component_info, arguments.IsSecondComponent, "_") />
	<cfreturn return_component_info />
</cffunction>

<cffunction name="getComponentNameId" output="false" returntype="string">
	<cfargument name="component_info" type="string" required="true" />

	<cfif ListLen(arguments.component_info, "_") GTE 1>
		<cfreturn Trim(ListGetAt(arguments.component_info, 1, "_")) />
	</cfif>

	<cfreturn "" />
</cffunction>

<cffunction name="getComponentPaidTo" output="false" returntype="string">
	<cfargument name="component_info" type="string" required="true" />

	<cfif ListLen(arguments.component_info, "_") GTE 2>
		<cfreturn Trim(ListGetAt(arguments.component_info, 2, "_")) />
	</cfif>

	<cfreturn "" />
</cffunction>

<cffunction name="setComponentPaidTo" output="false" returntype="string">
	<cfargument name="component_info" type="string" required="true" />
	<cfargument name="Paid_To" type="string" required="true" />

	<cfif ListLen(arguments.component_info, "_") GTE 2>
		<cfreturn Trim(ListSetAt(arguments.component_info, 2, '#arguments.Paid_To#', "_")) />
	</cfif>

	<cfreturn "" />
</cffunction>

<cffunction name="getComponentTreatmentCode" output="false" returntype="string">
	<cfargument name="component_info" type="string" required="true" />

	<cfif ListLen(arguments.component_info, "_") GTE 3>
		<cfreturn Trim(ListGetAt(arguments.component_info, 3, "_")) />
	</cfif>

	<cfreturn 0 />
</cffunction>

<cffunction name="getComponentBasisCode" output="false" returntype="string">
	<cfargument name="component_info" type="string" required="true" />

	<cfif ListLen(arguments.component_info, "_") GTE 4>
		<cfreturn Trim(ListGetAt(arguments.component_info, 4, "_")) />
	</cfif>

	<cfreturn 0 />
</cffunction>

<!--- Dev Note: KAL : D13043: Claim Mechanism on Fixed Price Page  ---> 
<cffunction name="getClaimMechanics" output="false" returntype="Numeric">
	<cfargument name="component_info" type="string" required="true" />

	<cfif ListLen(arguments.component_info, "_") GTE 5>
		<cfreturn Trim(ListGetAt(arguments.component_info, 5, "_")) />
	</cfif>

	<cfreturn 0 />
</cffunction>

<cffunction name="setClaimMechanics" output="false" returntype="string">
	<cfargument name="component_info" type="string" required="true" />
	<cfargument name="Claim_Mechanics" type="string" required="true" />

	<cfif ListLen(arguments.component_info, "_") GTE 5>
		<cfreturn Trim(ListSetAt(arguments.component_info, 5, '#arguments.Claim_Mechanics#', "_")) />
	</cfif>

	<cfreturn "" />
</cffunction>

<!--- BJF GL_Account  ---> 
<cffunction name="getGL_Account_ID" output="false" returntype="Numeric">
	<cfargument name="component_info" type="string" required="true" />

	<cfif ListLen(arguments.component_info, "_") GTE 6>
		<cfreturn Trim(ListGetAt(arguments.component_info, 6, "_")) />
	</cfif>

	<cfreturn 0 />
</cffunction>

<cffunction name="setGL_Account_ID" output="true" returntype="string">
	<cfargument name="component_info" type="string" required="true" />
	<cfargument name="GL_Account_ID" type="string" required="true" />

	<cfif ListLen(arguments.component_info, "_") GTE 6>
		<cfreturn Trim(ListSetAt(arguments.component_info, 6, '#arguments.GL_Account_ID#', "_")) />
	</cfif>

	<cfreturn "" />
</cffunction>

<!--- BJF Vendor_Master_ID  ---> 
<cffunction name="getVendor_Master_ID" output="false" returntype="string">
	<cfargument name="component_info" type="string" required="true" />

	<cfif ListLen(arguments.component_info, "_") GTE 7>
		<cfreturn Trim(ListGetAt(arguments.component_info, 7, "_")) />
	</cfif>

	<cfreturn 0 />
</cffunction>

<cffunction name="setVendor_Master_ID" output="false" returntype="string">
	<cfargument name="component_info" type="string" required="true" />
	<cfargument name="Vendor_Master_ID" type="string" required="true" />

	<cfif ListLen(arguments.component_info, "_") GTE 7>
		<cfreturn Trim(ListSetAt(arguments.component_info, 7, '#arguments.Vendor_Master_ID#', "_")) />
	</cfif>

	<cfreturn "" />
</cffunction>

<!--- BJF Payment_Cycle_ID  ---> 
<cffunction name="getPaymentCycle" output="false" returntype="string">
	<cfargument name="component_info" type="string" required="true" />

	<cfif ListLen(arguments.component_info, "_") GTE 8>
		<cfreturn Trim(ListGetAt(arguments.component_info, 8, "_")) />
	</cfif>

	<cfreturn 0 />
</cffunction>

<cffunction name="setPaymentCycle" output="false" returntype="string">
	<cfargument name="component_info" type="string" required="true" />
	<cfargument name="PaymentCycle" type="string" required="true" />

	<cfif ListLen(arguments.component_info, "_") GTE 8>
		<cfreturn Trim(ListSetAt(arguments.component_info, 8, '#arguments.PaymentCycle#', "_")) />
	</cfif>

	<cfreturn "" />
</cffunction>

<!--- Vendor Payee Option  ---> 
<cffunction name="getVendorSelection" output="false" returntype="string">
	<cfargument name="component_info" type="string" required="true" />

	<cfif ListLen(arguments.component_info, "_") GTE 9>
		<cfreturn Trim(ListGetAt(arguments.component_info, 9, "_")) />
	</cfif>

	<cfreturn 0 />
</cffunction>

<cffunction name="setVendorSelection" output="false" returntype="string">
	<cfargument name="component_info" type="string" required="true" />
	<cfargument name="VendorSelection" type="string" required="true" />

	<cfif ListLen(arguments.component_info, "_") GTE 9>
		<cfreturn Trim(ListSetAt(arguments.component_info, 9, '#arguments.VendorSelection#', "_")) />
	</cfif>

	<cfreturn "" />
</cffunction>

<cffunction name="getParentProgramFixedComponentID" output="false" returntype="string">
	<cfargument name="component_info" type="string" required="true" />

	<cfif ListLen(arguments.component_info, "_") GTE 10>
		<cfreturn Trim(ListGetAt(arguments.component_info, 10, "_")) />
	</cfif>

	<cfreturn "" />
</cffunction>

<!--- Payee Selection Option  ---> 
<cffunction name="getPayeeSelection" output="false" returntype="string">
	<cfargument name="component_info" type="string" required="true" />

	<cfif ListLen(arguments.component_info, "_") GTE 11>
		<cfreturn Trim(ListGetAt(arguments.component_info, 11, "_")) />
	</cfif>

	<cfreturn 0 />
</cffunction>

<cffunction name="setPayeeSelection" output="false" returntype="string">
	<cfargument name="component_info" type="string" required="true" />
	<cfargument name="PayeeSelection" type="string" required="true" />

	<cfif ListLen(arguments.component_info, "_") GTE 11>
		<cfreturn Trim(ListSetAt(arguments.component_info, 11, '#arguments.PayeeSelection#', "_")) />
	</cfif>

	<cfreturn "" />

</cffunction>

<!--- Check if the component is a second component - "Second component ( REDI) feature" ---> 
<cffunction name="getIsSecondComponent" output="false" returntype="string">
	<cfargument name="component_info" type="string" required="true" />

	<cfif ListLen(arguments.component_info, "_") GTE 12>
		<cfreturn Trim(ListGetAt(arguments.component_info, 12, "_")) />
	</cfif>

	<cfreturn 0 />
</cffunction>

<cffunction name="setIsSecondComponent" output="false" returntype="string">
	<cfargument name="component_info" type="string" required="true" />
	<cfargument name="IsSecondComponent" type="string" required="true" />

	<cfif ListLen(arguments.component_info, "_") GTE 12>
		<cfreturn Trim(ListSetAt(arguments.component_info, 12, '#arguments.IsSecondComponent#', "_")) />
	</cfif>

	<cfreturn "" />

</cffunction>