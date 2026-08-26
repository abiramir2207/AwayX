<cfcomponent name="AttributeDAO">

<cffunction access="public" output="false" name="init" returntype="ProductGroupAttributeDAO">
   <cfreturn this />
 </cffunction>

<cffunction access="public" output="false" name="updateProductAttributeByID" returntype="void">
	<cfargument name="attribute" type="components.products.Group.ProductGroupAttribute" required="true" />
    
	 <cfset var updateAttributeQry = "" />

	 <cfquery name="updateAttributeQry" datasource="#application.datasource#">
	 	Update  Product_Group_Level
	 	Set Group_Internal_Label = '#arguments.attribute.getInternalLabel()#',
	 	    Group_Level_Desc = '#arguments.attribute.getDescription()#'
	 	Where Product_Group_Level_ID = #arguments.attribute.getProductGroupId()#
	 </cfquery>
</cffunction>

<cffunction access="public" output="false" name="updateDistributorAttributeByID" returntype="void">
	<cfargument name="attribute" type="components.products.Group.DistributorGroupAttribute" required="true" />
    
	 <cfset var updateGroupAttributeQry = "" />

	 <cfquery name="updateGroupAttributeQry" datasource="#application.datasource#">
	 	Update  Distributor_Group_Level
	 	Set Group_Level_Desc_Internal = '#arguments.attribute.getInternalLabel()#',
	 	    Group_Level_Desc = '#arguments.attribute.getDescription()#'
	 	Where Distributor_Group_Level_ID = #arguments.attribute.getDistributorGroupId()#
	 </cfquery>
</cffunction>

<cffunction name="updateSummaryLabelByID" access="public" output="false" returntype="void">
  <cfargument name="attribute" type="components.products.Group.ClaimSummary" required="true" />

   <cfset var updateClaimSummaryLabel = "" />

    <cfquery name="updateClaimSummaryLabel" datasource="#application.datasource#">
	 Update Claim_Summary_Labels
	 Set Client_Label = '#arguments.attribute.getSummaryLabel()#',
	     Deleted = #arguments.attribute.getDeleted()#
	 Where Claim_SummaryID = #arguments.attribute.getClaimSummaryId()#
	</cfquery>
</cffunction>
</cfcomponent>