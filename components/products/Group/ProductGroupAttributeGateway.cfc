<cfcomponent name="AttributeGateway">
 
<cffunction access="public" output="false" name="init" returntype="ProductGroupAttributeGateway">
   <cfreturn this />
 </cffunction>

<cffunction access="public" output="false" name="getAllProductAttributes" returntype="Query">
	 
	 <cfset var allProductAttributes = "" />

 <cfquery name="allProductAttributes" datasource="#application.datasource#">
   Select Product_Group_Level_ID, Group_Internal_Label, Group_Level_Desc, Convert(varchar,Created_Date,101) as Created_Date, 
          Search_Filter_On,Active
   From   Product_Group_Level
   Where  deleted = 0
  </cfquery>

    <cfreturn allProductAttributes />

</cffunction>

<cffunction access="public" output="false" name="getAllDistributorAttributes" returntype="Query">
	 
	 <cfset var allDistributorAttributes = "" />

 <cfquery name="allDistributorAttributes" datasource="#application.datasource#">
	Select Distributor_Group_Level_ID,Group_Level_Desc,Convert(varchar,Created_Date,101) as Created_Date,
           Active,Search_Filter_On,Group_Level_Desc_Internal
	From   Distributor_Group_Level
	Where  Deleted = 0
  </cfquery>

    <cfreturn allDistributorAttributes />

</cffunction>

<cffunction name="getAllClaimLabels" access="public" output="false" returntype="Query">
  <cfset var getClaimSummaryLabels = "" />
   
   <cfquery name="getClaimSummaryLabels" datasource="#application.datasource#">
   	Select Claim_SummaryID,BALabel,Client_Label,Created_date, deleted
	From Claim_Summary_Labels
   </cfquery>

   <cfreturn getClaimSummaryLabels />
</cffunction>

</cfcomponent>