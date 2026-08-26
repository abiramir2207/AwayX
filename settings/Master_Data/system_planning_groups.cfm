<cf_layout selectedIndex=4  layoutID = "masterdata">
<!----
	Name: index.cfm
	Created By:   Dinesh Rachala :: 08/03/2016
	Copyright (c) 2016 Blacksmith Applications, Inc.
 	Description:
	Usage: Used to research distributor without filters
---->

<cf_include file_to_include="/common_files/tabnav.css"/>
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />

<cfif businessSegManager.isEnabled() AND ! businessSegManager.isEnabledForDistributor()>
    <cfparam name="url.type" default="distributorSystemPlanningGroups">
<cfelseif businessSegManager.isEnabled() AND ! businessSegManager.isEnabledForProduct()>
    <cfparam name="url.type" default="productSystemPlanningGroups">
<cfelseif businessSegManager.isEnabled() AND ! businessSegManager.isEnabledForOperator()>
    <cfparam name="url.type" default="operatorSystemPlanningGroups">
</cfif>

<div class="nav">
    <ul class="nav">
        <cfif businessSegManager.isEnabled() AND ! businessSegManager.isEnabledForDistributor()>
        <li <cfif url.type EQ "distributorSystemPlanningGroups">class="active"</cfif>>
            <a class="topnav" href="system_planning_groups.cfm?type=distributorSystemPlanningGroups">distributor</a>
        </li>
        </cfif>
        <cfif businessSegManager.isEnabled() AND ! businessSegManager.isEnabledForProduct()>
        <li <cfif url.type EQ "productSystemPlanningGroups">class="active"</cfif>>
            <a class="topnav" href="system_planning_groups.cfm?type=productSystemPlanningGroups">product</a>
        </li>
         </cfif>
        <cfif businessSegManager.isEnabled() AND ! businessSegManager.isEnabledForOperator()>
          <li <cfif url.type EQ "operatorSystemPlanningGroups">class="active"</cfif>>
            <a class="topnav" href="system_planning_groups.cfm?type=operatorSystemPlanningGroups">operator</a>
        </li>
         </cfif>
    </ul>
</div>

<cfif url.type EQ "distributorSystemPlanningGroups">
	<cfinclude template="distributor_master_data.cfm" />
<cfelseif url.type EQ "productSystemPlanningGroups">
	<cfinclude template="product_master_data.cfm" />
<cfelseif url.type EQ "operatorSystemPlanningGroups">
	<cfinclude template="operator_master_data.cfm" />
</cfif>

</cf_layout>