<cfif isdefined('url.check') AND url.check EQ 1>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
	<head>
		
		<body>

<cfset no_filters = "">

<cfif len(url.DistributorGroupLevelID) GT 0>
	
	<cfset DistGroupDataManager = CreateObject("component", "components.customer.Group.DataManager").init() />
	<cfset DistributorGroupAttributeManager = CreateObject("component", "components.customer.group.DistributorGroupAttributeManager").init() />
	
	<cfset list = #trim(url.DistributorGroupLevelID)#>
	
	<cfloop from="1" to="#listlen(list)#" index="ID">
	
		<cfset stGetGroupAttributeInfo = DistributorGroupAttributeManager.getGroupAttributeInfo(groupLevelTypeId = #trim(listgetat(list, ID))#) />
		
		<cfset GetGroupValues = DistributorGroupAttributeManager.getDistributorGroupValues(
										DistributorGroupAttributeInfo 	= stGetGroupAttributeInfo,
										cachedwithin					= #CreateTimeSpan(0, 0, 0, 0)#,
										ExcludeDistID 				= 0,
										IncludeIOPGFlag				= 0,
		                                businessSegmentId           = 0
										) />
		
		
		<cfset qGetExistingData = DistGroupDataManager.fnQryExistingCustomerData( 
		                                TemplateID = #trim(url.TemplateID)#, 
		                                TemplateFiltersID = #trim(url.TemplateFiltersID)#, 
		                                DistributorGroupLevelID = #trim(listgetat(list, ID))#, 
		                                bActive = 1
		                                ) />
		
		
		
		
		<cfif qGetExistingData.recordcount EQ 0>
			<cfset qGetTopLevelGroupsList = DistGroupDataManager.getDistributorLevelsAll(1, "#trim(listgetat(list, ID))#", "")>
			<cfset no_filters = listappend(no_filters, qGetTopLevelGroupsList.GROUP_LEVEL_DESC)>
		</cfif>
	
	</cfloop>
</cfif>
<!--- ###################################################################################################################### --->
<!--- ###################################################################################################################### --->
<!--- ###################################################################################################################### --->
<cfif len(url.itemGroupLevelID) GT 0>
	  <cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />
	  <cfset ProdGroupDataManager = CreateObject("component", "components.products.Group.DataManager").init() /> 
	  <cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
	  <cfset qGetTopLevelGroups = GroupDataManager.getProductGroupsData() />
	  <cfset list = #trim(url.itemGroupLevelID)#>
	    
	  <cfloop from="1" to="#listlen(list)#" index="ID">
	
			<cfset qGetApprovalGroups = approvalGroupManager.getApprovalGroups(
					                            ExcludeItemID=0,
			                                    IncludeIOPGFlag=0, 
			                                    businessSegmentId= 0)>
			
			
			<cfset qGetExistingData = ProdGroupDataManager.fnQryExistingProductData( 
			                                TemplateID = #trim(url.TemplateID)#, 
			                                TemplateFiltersID = #trim(url.TemplateFiltersID)#, 
			                                ProductGroupLevelID = #trim(listgetat(list, ID))#, 
			                                bActive = 1
			                                ) />
			
			
			<cfif qGetExistingData.recordcount EQ 0>
				<cfquery name="description" dbtype="query">
					SELECT * FROM qGetTopLevelGroups WHERE product_group_level_id = #trim(listgetat(list, ID))#
				</cfquery> 
				<cfset no_filters = listappend(no_filters, description.Group_Level_Desc)>
			</cfif>
	
	</cfloop>  
    
    
</cfif>
				

<cfoutput>
	<script language="javascript">
	<cfif listlen(no_filters) GT 0>
		var s = #listlen(no_filters)#;
		var sfilters = "#no_filters#";
	<cfelse>
		var s = 0;
		var sfilters = "#no_filters#";
	</cfif>
	filters(s, sfilters);
	</script>
</cfoutput>

	</body>
	</head>
</html>

</cfif>