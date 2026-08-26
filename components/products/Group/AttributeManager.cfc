<cfcomponent name="AttributeManager" extends="components.ajaxCFC.ajax">

 <!--- This prevents errors when OnRequestEnd() is inside of Application.cfc
       otherwise some JS errrors might be thrown --->
    <cfscript>
        setAbortAfterRequest(true);
    </cfscript> 
	
	<cfset variables.attributeGateway = createObject("component", "components.products.Group.ProductGroupAttributeGateway").init() />
	<cfset variables.attributeDAO = createObject("component", "components.products.Group.ProductGroupAttributeDAO").init() />
	<cfset variables.attributeBean = createObject("component", "components.products.Group.ProductGroupAttribute").init() />
	<cfset variables.distributorBean = createObject("component", "components.products.Group.DistributorGroupAttribute").init() />

<cffunction access="private" output="false" name="getAllProductAttributes" returntype="Query">

  <cfreturn variables.attributeGateway.getAllProductAttributes() />

</cffunction>

<cffunction access="private" output="false" name="getAllDistributorAttributes" returntype="Query">

  <cfreturn variables.attributeGateway.getAllDistributorAttributes() />

</cffunction>

<cffunction access="public" output="false" name="getAllClaimSummary" returntype="Query">

  <cfreturn variables.attributeGateway.getAllClaimLabels() />

</cffunction>

<cffunction access="private" output="false" name="updateProductAttribute" returntype="string">
	<cfargument name="product_group_level_id" required="true" type="numeric" />
	<cfargument name="group_internal_label" type="string" required="true"  />
	<cfargument name="group_level_desc" type="string" required="true" />
	
	 <cfset variables.attributeBean.setProductGroupId(arguments.product_group_level_id) />
	 <cfset variables.attributeBean.setInternalLabel(arguments.group_internal_label) />
     <cfset variables.attributeBean.setDescription(arguments.group_level_desc) />
		
		<cfset variables.attributeDAO.updateProductAttributeByID(variables.attributeBean) />
		
		<cfreturn "test" />

</cffunction>

<cffunction access="private" output="false" name="updateDistributorAttribute" returntype="string">
	<cfargument name="distributor_group_level_id" required="true" type="numeric" />
	<cfargument name="group_level_desc_internal" type="string" required="true"  />
	<cfargument name="group_level_desc" type="string" required="true" />
	
	 <cfset variables.distributorBean.setDistributorGroupId(arguments.distributor_group_level_id) />
	 <cfset variables.distributorBean.setInternalLabel(arguments.group_level_desc_internal) />
     <cfset variables.distributorBean.setDescription(arguments.group_level_desc) />
		
		<cfset variables.attributeDAO.updateDistributorAttributeByID(variables.distributorBean) />
		
		<cfreturn "test" />

</cffunction>

<cffunction access="public" output="false" name="updateClaimSummary" returntype="string">
  <cfargument name="claim_summaryid" required="true" type="numeric" />
  <cfargument name="client_label" required="true" type="string" />
  <cfargument name="deleted" required="true" type="numeric" />
   
  <cfset variables.summaryBean = createObject("component", "components.products.Group.ClaimSummary").init() />
  <cfset variables.summaryBean.setClaimSummaryId(arguments.claim_summaryid) />
  <cfset variables.summaryBean.setSummaryLabel(arguments.client_label) />     
  <cfset variables.summaryBean.setDeleted(arguments.deleted) />	
	<cfset variables.attributeDAO.updateSummaryLabelByID(variables.summaryBean) />
	
	<cfreturn "test" />
</cffunction>
</cfcomponent>