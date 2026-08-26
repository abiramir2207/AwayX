<!----
	Filename:	C:\Work\Code\base\AwayX\settings\Planning_Groups\Planning_Groups_Display.cfm
	Created:	12/29/2011
 	Developer:	drachala        
	Copyright (c) 2006 Blacksmith Applications, Inc.       
             
	Description:
		Used to display Planning Group Memebers based URL variable passed
	Usage:
		Settings>>Administrator>>Planning Groups
		label # D29685  
---->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset isBusinessSegEnabledForDistributor = businessSegManager.isEnabledForDistributor()>
<cfset isBusinessSegEnabledForProduct = businessSegManager.isEnabledForProduct() /> 

<cfif isdefined("PG_Product_Category_ID")>
	<cfstoredproc procedure="Get_Product_Group_Info_For_PG" datasource="#application.datasource#">
	  	<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@PG_Product_Category_ID" value = "#PG_Product_Category_ID#" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Keyword" value = "" null="no">		
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@OrderByField" value="Group_Name" null="no">			  
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@OrderBy" value="ASC" null="no">
	    <cfprocresult name="qryPGProductCategoryDefinitionByID">
	</cfstoredproc>
</cfif>

<cfif isdefined("PG_Customer_Category_ID")>
	<cfstoredproc procedure="Get_Customer_Group_Info_For_PG" datasource="#application.datasource#">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@PG_Customer_Category_ID" value = "#PG_Customer_Category_ID#" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Keyword" value = "" null="no">		
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@OrderByField" value="Group_Name" null="no">			  
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@OrderBy" value="ASC" null="no">			
		<cfprocresult name="qryPGCustomerCategoryDefinitionByID">
	</cfstoredproc>
</cfif>

<cfif isdefined("PG_Operator_Category_ID")>
    <cfstoredproc procedure="Get_Operator_Group_Info_For_PG" datasource="#application.datasource#">
	    <cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@PG_Operator_Category_ID" value = "#PG_Operator_Category_ID#" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Keyword" value = "" null="no">				
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@OrderByField" value="Group_Name" null="no">			  
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@OrderBy" value="ASC" null="no">			
      	<cfprocresult name="qryPGOperatorCategoryDefinitionByID">
    </cfstoredproc>	
</cfif>
<!--- ************************************************************************************************************************************************************************** --->
<!--- ************************************************************Product Planning Group Memebers Display ************************************************************ --->
<!--- ************************************************************************************************************************************************************************** --->
<cfif isdefined("PG_Product_Category_ID") AND isdefined("PG_Delete")>

<cfoutput>
		<cfif qryPGProductCategoryDefinitionByID.RecordCount EQ 0>
			<script>
				deleteProductRec('#PG_Product_Category_ID#');
			</script>
		<cfelse>
			<script>
				alert("You cannot delete this Planning Group as there are members associated with it.");
			</script>
		</cfif>
</cfoutput>
	
</cfif>


<cfif isdefined("PG_Product_Category_ID") AND isdefined("PG_Deactivate")>

<cfoutput>
		<cfif qryPGProductCategoryDefinitionByID.RecordCount EQ 0>
			<script>
				deActivateProductRec('#PG_Product_Category_ID#');
			</script>
		<cfelse>
			<script>
				alert("You cannot deactivate this Planning Group as there are members associated with it.");
			</script>
		</cfif>
</cfoutput>
		
</cfif>
<cfif isdefined("PG_Product_Category_ID") AND isdefined("PG_Display")>

<cfif qryPGProductCategoryDefinitionByID.RecordCount EQ 0>
		<div style="width:100%; text-align:center; font-size:12px;font-weight:bold;">
		 No Members Found!!
		</div> 
<cfelse>
<cfoutput>
	<cfset height = 0>
	<cfif qryPGProductCategoryDefinitionByID.recordcount GT 10>
		<cfset height = 1>
	</cfif>
	<cfif isBusinessSegEnabledForProduct>
		<cfset width1 = "15%">
		<cfset width2 = "15%">
		<cfset width3 = "45%">
		<cfset width4 = "10%">
		<cfset width5 = "10%">
	<cfelse>
		<cfset width1 = "20%">
		<cfset width2 = "20%">
		<cfset width3 = "45%">
		<cfset width4 = "10%">
	</cfif>
<!--- did try to add style to ID and CLASS did not worked as intended so added to every div --->
<cfif height>
	<div style="width:98%;background-color:##737373;">
	<cfelse>
	<div style="width:100%;background-color:##737373;">
</cfif>
	<div style="width=#width1#;float:left;font-size:12px;font-weight:bold;">Group/#application.returned_customer_setting.Item_Label# <br> Description</div>
	<div style="width=#width2#;float:left;font-size:12px;font-weight:bold;">Group/#application.returned_customer_setting.Item_Label# <br> Number</div>
	<div style="width=#width3#;float:left;font-size:12px;font-weight:bold;">Group/#application.returned_customer_setting.Item_Label# <br> Name</div>
	<div style="width=#width4#;float:left;font-size:12px;font-weight:bold;">Include/Exclude</div>
	<cfif isBusinessSegEnabledForProduct>
	<div style="width=#width5#;float:right;font-size:12px;font-weight:bold;">&nbsp;&nbsp;#appsettings.Business_Segment_Label#</div>
	</cfif>
	</div>
<cfif height><div style="width:100%;height:350px;overflow-y:scroll;"></cfif>
 <cfloop query = "qryPGProductCategoryDefinitionByID">
	<div style="width:100%;background-color:dddddd;">
	<div style="width=#width1#;float:left;font-size:12px;">#qryPGProductCategoryDefinitionByID.Group_Desc#</div>
	<div style="width=#width2#;float:left;font-size:12px;">#qryPGProductCategoryDefinitionByID.Group_Number#</div>
	<div style="width=#width3#;float:left;font-size:12px;">#qryPGProductCategoryDefinitionByID.Group_Name#&nbsp;&nbsp;</div>
	<div style="width=#width4#;float:left;font-size:12px;">&nbsp;<cfif (qryPGProductCategoryDefinitionByID.Inclusion_Exclusion)>Include<cfelse>Exclude</cfif></div>
	<cfif isBusinessSegEnabledForProduct>
	<div style="width=#width5#;float:right;font-size:12px;">&nbsp;&nbsp;#qryPGProductCategoryDefinitionByID.Business_Unit_Desc#</div>
	</cfif>
	</div>
</cfloop>
<cfif height></div></cfif>
</cfoutput>	
</cfif>

</cfif>

<!--- ************************************************************************************************************************************************************************** --->
<!--- ************************************************************ Distributor Planning group Members Display START ************************************************************ --->
<!--- ************************************************************************************************************************************************************************** --->
<cfif isdefined("PG_Customer_Category_ID") AND isdefined("PG_Delete")>

<cfoutput>
		<cfif qryPGCustomerCategoryDefinitionByID.RecordCount EQ 0>
			<script>
				deleteCustomerRec('#PG_Customer_Category_ID#');
			</script>
		<cfelse>
			<script>
				alert("You cannot delete this Planning Group as there are members associated with it.");
			</script>
		</cfif>
</cfoutput>
	
</cfif>


<cfif isdefined("PG_Customer_Category_ID") AND isdefined("PG_Deactivate")>

<cfoutput>
		<cfif qryPGCustomerCategoryDefinitionByID.RecordCount EQ 0>
			<script>
				deActivateCustomerRec('#PG_Customer_Category_ID#');
			</script>
		<cfelse>
			<script>
				alert("You cannot deactivate this Planning Group as there are members associated with it.");
			</script>
		</cfif>
</cfoutput>
		
</cfif>
<cfif isdefined("PG_Customer_Category_ID") AND isdefined("PG_Display")>

<cfif qryPGCustomerCategoryDefinitionByID.RecordCount EQ 0>
		<div style="width:100%; text-align:center; font-size:12px;font-weight:bold;">
		 No Members Found!!
		</div> 
<cfelse>
<cfoutput>
	<cfset height = 0>
	<cfif qryPGCustomerCategoryDefinitionByID.recordcount GT 10>
		<cfset height = 1>
	</cfif>
	<cfif isBusinessSegEnabledForDistributor>
		<cfset width1 = "15%">
		<cfset width2 = "15%">
		<cfset width3 = "45%">
		<cfset width4 = "10%">
		<cfset width5 = "10%">
	<cfelse>
		<cfset width1 = "20%">
		<cfset width2 = "20%">
		<cfset width3 = "45%">
		<cfset width4 = "10%">
	</cfif>
<!--- did try to add style to ID and CLASS did not worked as intended so added to every div --->
<cfif height>
	<div style="width:98%;background-color:##737373;">
	<cfelse>
	<div style="width:100%;background-color:##737373;">
</cfif>
	<div style="width=#width1#;float:left;font-size:12px;font-weight:bold;">Group/#application.returned_customer_setting.Item_Label# <br> Description</div>
	<div style="width=#width2#;float:left;font-size:12px;font-weight:bold;">Group/#application.returned_customer_setting.Item_Label# <br> Number</div>
	<div style="width=#width3#;float:left;font-size:12px;font-weight:bold;">Group/#application.returned_customer_setting.Item_Label# <br> Name</div>
	<div style="width=#width4#;float:left;font-size:12px;font-weight:bold;">Include/Exclude</div>
	<cfif isBusinessSegEnabledForDistributor>
	<div style="width=#width5#;float:right;font-size:12px;font-weight:bold;">&nbsp;&nbsp;#appsettings.Business_Segment_Label#</div>
	</cfif>
	</div>
<cfif height><div style="width:100%;height:350px;overflow-y:scroll;"></cfif>
 <cfloop query = "qryPGCustomerCategoryDefinitionByID">
	<div style="width:100%;background-color:dddddd;">
	<div style="width=#width1#;float:left;font-size:12px;">#qryPGCustomerCategoryDefinitionByID.Group_Desc#</div>
	<div style="width=#width2#;float:left;font-size:12px;">#qryPGCustomerCategoryDefinitionByID.Group_Number#</div>
	<div style="width=#width3#;float:left;font-size:12px;">#qryPGCustomerCategoryDefinitionByID.Group_Name#&nbsp;&nbsp;</div>
	<div style="width=#width4#;float:left;font-size:12px;">&nbsp;<cfif (qryPGCustomerCategoryDefinitionByID.Inclusion_Exclusion)>Include<cfelse>Exclude</cfif></div>
	<cfif isBusinessSegEnabledForDistributor>
	<div style="width=#width5#;float:right;font-size:12px;">&nbsp;&nbsp;#qryPGCustomerCategoryDefinitionByID.Business_Unit_Desc#</div>
	</cfif>
	</div>
</cfloop>
<cfif height></div></cfif>
</cfoutput>	
</cfif>

</cfif>
<!--- ************************************************************************************************************************************************************************** --->
<!--- ************************************************************ Operator Planning group Members Display START *************************************************************** --->
<!--- ************************************************************************************************************************************************************************** --->
<cfif isdefined("PG_Operator_Category_ID") AND isdefined("PG_Delete")>

<cfoutput>
		<cfif qryPGOperatorCategoryDefinitionByID.RecordCount EQ 0>
			<script>
				deleteOperatorRec('#PG_Operator_Category_ID#');
			</script>
		<cfelse>
			<script>
				alert("You cannot delete this Planning Group as there are members associated with it.");
			</script>
		</cfif>
</cfoutput>
	
</cfif>


<cfif isdefined("PG_Operator_Category_ID") AND isdefined("PG_Deactivate")>

<cfoutput>
		<cfif qryPGOperatorCategoryDefinitionByID.RecordCount EQ 0>
			<script>
				deActivateOperatorRec('#PG_Operator_Category_ID#');
			</script>
		<cfelse>
			<script>
				alert("You cannot deactivate this Planning Group as there are members associated with it.");
			</script>
		</cfif>
</cfoutput>
		
</cfif>

<cfif isdefined("PG_Operator_Category_ID") AND isdefined("PG_Display")>

<cfif qryPGOperatorCategoryDefinitionByID.RecordCount EQ 0>
		<div style="width:100%; text-align:center; font-size:12px;font-weight:bold;">
		 No Members Found!!
		</div> 
	<cfelse>
			<cfoutput>
				<cfset height = 0>
				<cfif qryPGOperatorCategoryDefinitionByID.recordcount GT 25>
					<cfset height = 1>
				</cfif>
				
					<cfset width1 = "20%">
					<cfset width2 = "20%">
					<cfset width3 = "45%">
					<cfset width4 = "10%">

			<!--- did try to add style to ID and CLASS did not worked as intended so added to every div --->
			<cfif height>
				<div style="width:98%;background-color:##737373;">
				<cfelse>
				<div style="width:100%;background-color:##737373;">
			</cfif>
				<div style="width=#width1#;float:left;font-size:12px;font-weight:bold;">Group/#application.returned_customer_setting.Item_Label# <br> Description</div>
				<div style="width=#width2#;float:left;font-size:12px;font-weight:bold;">Group/#application.returned_customer_setting.Item_Label# <br> Number</div>
				<div style="width=#width3#;float:left;font-size:12px;font-weight:bold;">Group/#application.returned_customer_setting.Item_Label# <br> Name</div>
				<div style="width=#width4#;float:left;font-size:12px;font-weight:bold;">Include/Exclude</div>
				</div>
			<cfif height><div style="width:100%;height:350px;overflow-y:scroll;"></cfif>
			 <cfloop query = "qryPGOperatorCategoryDefinitionByID">
				<div style="width:100%;background-color:dddddd;">
				<div style="width=#width1#;float:left;font-size:12px;">#qryPGOperatorCategoryDefinitionByID.Group_Desc#</div>
				<div style="width=#width2#;float:left;font-size:12px;">#qryPGOperatorCategoryDefinitionByID.Group_Number#</div>
				<div style="width=#width3#;float:left;font-size:12px;">#qryPGOperatorCategoryDefinitionByID.Group_Name#&nbsp;&nbsp;</div>
				<div style="width=#width4#;float:left;font-size:12px;">&nbsp;<cfif (qryPGOperatorCategoryDefinitionByID.Inclusion_Exclusion)>Include<cfelse>Exclude</cfif></div>
				</div>
			</cfloop>
			<cfif height></div></cfif>
			</cfoutput>	

</cfif>
</cfif>
