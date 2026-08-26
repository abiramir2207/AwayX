<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>SAP Reference Numbers</title>
</head>

<body>
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<cfparam name="url.CID" default="">
<cfset headerCount = 0>
<cfif url.CID NEQ "">
<cfquery NAME="getprogramsapdetails" datasource="#application.datasource#">
	select Sent_To_External_Client,error_from_external_client,contract_status_type_idx,contract_number,Discount_Identifier.Discount_Identifier_Number,
	Generic_type
	from contract_main
	INNER JOIN Program_Control_Panel_Options ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
	INNER JOIN Discount_Identifier ON Discount_Identifier.Discount_Identifier_ID = Program_Control_Panel_Options.Discount_Identifier_ID
	<!--- AND Discount_Identifier.Discount_Identifier_Number IN ('ZDis','ZNet') --->
	where contract_main_id = #url.CID#
</cfquery>

<cfif getprogramsapdetails.Sent_To_External_Client EQ 1 and getprogramsapdetails.error_from_external_client EQ 0 AND getprogramsapdetails.contract_status_type_idx GT 2>

	<cfquery NAME="getDistributorGroupType" datasource="#application.datasource#">
		SELECT	DISTINCT Contract_Distributors.Distributor_Group_level_ID, Contract_Distributors.Is_group
		FROM	Contract_Main
		INNER JOIN Contract_Distributors
		ON		Contract_Distributors.Deleted = 0
		AND		Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
		AND		Contract_Distributors.Captured_From_Group = 0
		WHERE 	Contract_Main.Contract_Main_ID = #url.CID#
	</cfquery>
	<cfset Distributor_Group_level_ID = 0 />
	<cfif getDistributorGroupType.Is_group EQ 1 AND (appSettings.getInterface_BuyingGroup_As_Group_To_Client() OR (appSettings.getInterface_BuyingGroup_As_Group_To_Client() EQ 0 AND getDistributorGroupType.Distributor_Group_level_ID NEQ 3))>
		<cfset Distributor_Group_level_ID = getDistributorGroupType.Distributor_Group_level_ID />
		<cfset DistributorGroupAttributeManager = CreateObject("component", "components.customer.group.DistributorGroupAttributeManager").init() />
		<cfset stGetGroupAttributeInfo = DistributorGroupAttributeManager.getGroupAttributeInfo(groupLevelTypeId = Distributor_Group_level_ID) />
	</cfif>

	<cfquery NAME="DealID_Info" datasource="#application.datasource#">
		SELECT 	DISTINCT Sold_To,Deal_ID,Forge_ERP_Mapping.Discount_Type_ID,
		CASE
		WHEN Forge_ERP_Mapping.Discount_Type_ID = 1 THEN Program_Fixed_Component_Name
		WHEN Forge_ERP_Mapping.Discount_Type_ID = 2 THEN Program_Rebates_Component_Name
		WHEN Forge_ERP_Mapping.Discount_Type_ID = 3 THEN Program_Lump_Sum_Name
		WHEN Forge_ERP_Mapping.Discount_Type_ID = 4 THEN Program_Growth_Components_Name
		ELSE ''
		END AS Component_Name,BSA_FoodService_Items_Master.Item

		FROM		Contract_Main
		<cfif getprogramsapdetails.Discount_Identifier_Number EQ "ZDis" OR getprogramsapdetails.Discount_Identifier_Number EQ "ZNet">
			LEFT JOIN 	Contract_Distributors
			ON Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
			<cfif Distributor_Group_level_ID NEQ 0>AND Contract_Distributors.Captured_From_Group = 0</cfif>
			AND Contract_Distributors.Deleted = 0
		</cfif>
		INNER JOIN	Forge_ERP_Mapping
		ON Contract_Main.Contract_Main_ID = Forge_ERP_Mapping.Program_ID
		AND Forge_ERP_Mapping.Deleted = 0
		AND Forge_ERP_Mapping.Deal_ID IS NOT NULL
		<cfif getprogramsapdetails.Discount_Identifier_Number EQ "ZDis" OR getprogramsapdetails.Discount_Identifier_Number EQ "ZNet">
			AND Forge_ERP_Mapping.Distributor_ID = Contract_Distributors.BSA_FoodService_Customers_ID
		</cfif>
		LEFT JOIN 	Program_Fixed_Component_Name
		ON Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID = Forge_ERP_Mapping.Component_Name_ID
		AND Forge_ERP_Mapping.Discount_Type_ID = 1
		LEFT JOIN 	Program_Rebates_Component_Name
		ON Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Forge_ERP_Mapping.Component_Name_ID
		AND Forge_ERP_Mapping.Discount_Type_ID = 2
		LEFT JOIN 	Program_Lump_Sum_Name
		ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Forge_ERP_Mapping.Component_Name_ID
		AND Forge_ERP_Mapping.Discount_Type_ID = 3
		LEFT JOIN 	Program_Growth_Components_Name
		ON Program_Growth_Components_Name.Program_Growth_Components_Name_ID = Forge_ERP_Mapping.Component_Name_ID
		AND Forge_ERP_Mapping.Discount_Type_ID = 4
		LEFT JOIN 	BSA_FoodService_Items_Master
		ON BSA_FoodService_Items_Master.BSA_FoodService_Items_Master_ID = Forge_ERP_Mapping.Product_ID
		WHERE 		Contract_Main.Contract_Main_ID = #url.CID#
		ORDER BY 	Deal_ID, Forge_ERP_Mapping.Discount_Type_ID,Component_Name
	</cfquery>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<cfset pagetitle ="SAP Reference Numbers">
	<div style="width:99%">
		<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
	</div>
	<cfif DealID_Info.recordcount GT 0>
		<cfquery NAME="ColHeader_Dis" DBTYPE="query">
			SELECT COUNT(Deal_ID) FROM DealID_Info WHERE Sold_To IS NOT NULL
		</cfquery>
		<cfquery NAME="ColHeader_Deal" DBTYPE="query">
			SELECT COUNT(Deal_ID) FROM DealID_Info WHERE Deal_ID IS NOT NULL
		</cfquery>
		<cfquery NAME="ColHeader_Comp" DBTYPE="query">
			SELECT COUNT(Deal_ID) FROM DealID_Info WHERE Component_Name IS NOT NULL
		</cfquery>
		<cfquery NAME="ColHeader_Prod" DBTYPE="query">
			SELECT COUNT(Deal_ID) FROM DealID_Info WHERE Item IS NOT NULL
		</cfquery>
		<cfquery name="findDupes" dbtype="query">
		  SELECT Deal_ID FROM DealID_Info GROUP BY Deal_ID
		  HAVING COUNT(*) > 1
		 </cfquery>
		 <cfset headerCount = 0>
		<table class="datagrid" align="center">
		<thead>
		<cfif ColHeader_Deal.RecordCount GT 0>
			<th class="header">Deal ID</th>
		<cfset headerCount = headerCount + 1>
		</cfif>
		<cfif ColHeader_Dis.RecordCount GT 0>
			<th class="header"><CFOUTPUT>#application.returned_customer_setting.shard_ship_to_label#</CFOUTPUT> / Group</th>
		<cfset headerCount = headerCount + 1>
		</cfif>
		<cfif ColHeader_Comp.RecordCount GT 0>
			<th class="header">Component Name</th>
		<cfset headerCount = headerCount + 1>
		</cfif>
		<cfif ColHeader_Prod.RecordCount GT 0>
			<th class="header"><CFOUTPUT>#application.returned_customer_setting.Item_Label#</CFOUTPUT></th>
		<cfset headerCount = headerCount + 1>
		</cfif>
		</thead>
		<tbody>
			<cfset colWidth = 100/headerCount>
		<cfoutput query="DealID_Info">
		<tr>
		<cfif ColHeader_Deal.RecordCount GT 0>
			<td style="width:#Round(colWidth)#%">#Deal_ID#</td>
		</cfif>
		<cfif ColHeader_Dis.RecordCount GT 0>
			<td style="width:#Round(colWidth)#%">#Sold_To#</td>
		</cfif>
		<cfif ColHeader_Comp.RecordCount GT 0>
			<td style="width:#Round(colWidth)#%">#Component_Name#</td>
		</cfif>
		<cfif ColHeader_Prod.RecordCount GT 0>
			<td style="width:#Round(colWidth)#%">#Item#</td>
		</cfif>
		</tr>
		</cfoutput>
		</tbody>
		</TABLE>

	<cfelse>
		<div align="center"><font size="2" color="red">No Data.</font> </div>
	</cfif>
<cfelseif getprogramsapdetails.error_from_external_client EQ 1 and getprogramsapdetails.contract_status_type_idx GT 2>
	<div align="center"><font size="2" color="red"><b>Errors In sending Data to SAP</b></font> </div><br><br>
</cfif>
<cfelse>
	<div align="center"><font size="2" color="red">No Data.</font> </div>
</cfif>


<cfoutput>
<div align="center">
	<br><a onclick="javascript:window.close()" STYLE="cursor: pointer;">#application.util.string.actionLinkFormat2('Close Window')#</a>
</div>

<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables2.cfm">
<script>
	var windowHeight = $(window).height(), sScrollY = ( windowHeight > 400 ? .65 : .55) * windowHeight;

	oTable = $('.datagrid').dataTable({
	 "bAutoWidth": true
	,"bPaginate": false
	,"bSortClasses": false
	,"sDom": "fptpr"
	,"sScrollY": sScrollY
	,"aoColumns": [
										<cfloop from="1" to="#headerCount#" index="hc">
									  	<cfif HC GT 1>,</cfif>{"bSearchable": true,  "bSortable":true}
									  </cfloop>
		            ]

		})
</script>
</cfoutput>
</body>
</html>

</body>
</html>