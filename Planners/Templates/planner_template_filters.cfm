<!----------------------------------------------------------------------------------
Name         :	AwayX/Planners/Templates/index.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	03/01/2016
Created By   : 	KAL
Description  : 	Planner Templates
---------------------------------------------------------------------------------->
<!--- TODO: LIST -------------------------
	- Validation
	- UI Cleanup
	- Add Select all
----------------------------------------->
<cfoutput>
<cfsavecontent variable="variables.uncompressed">
<style>
	table.filter { border-collapse:collapse; width:700px; margin:10px; table-layout:fixed; }
	table.filter td { border:1px solid ##93BEE2; padding-left:5px; }
	.heading { text-align:center; font-weight:bold; }
</style>
<cfquery name="qryDistList" datasource="#application.datasource#">
  SELECT DISTINCT(Distributor_Group_Level_ID) FROM Distributor_Group_Level WHERE Active = 1 AND Deleted = 0 AND Distributor_Group_Level_ID NOT IN (23, 24, 25)
</cfquery>
<cfscript>
	qGetPlannerFiltersData         = objPlannerTemplateManager.getPlannerFilters(form.id);
	DistGroupDataManager           = CreateObject("component", "components.customer.Group.DataManager").init();
	qGetCustomerGroups             = DistGroupDataManager.getDistributorLevelsAll(1, "#ValueList(qryDistList.Distributor_Group_Level_ID)#", "");
	qGetPlannerFiltersCustomerData = objPlannerTemplateManager.getPlannerFiltersCustomers(form.id);
	qGetPlannerFiltersProductData  = objPlannerTemplateManager.getPlannerFiltersProducts(form.id);
	qGetPlannerFiltersOperatorData  = objPlannerTemplateManager.getPlannerFiltersOperators(form.id);
	GroupDataManager               = CreateObject("component", "components.products.Group.DataManager");
	qGetProductGroups              = GroupDataManager.getProductGroupsData(includeProduct=1);
	labels_manager                 = createObject("component", "components.settings.labels.labels").init();
	OperGroupDataManager           = CreateObject("component", "components.operator.Group.DataManager").init();
	qGetOperatorGroups			   = OperGroupDataManager.getOperatorLevelsAll();
	distributor_labels             = labels_manager.getPlannerLabels("distributor");
	operator_labels                = labels_manager.getPlannerLabels("operator");
</cfscript>

<SCRIPT LANGUAGE="JavaScript" SRC="/settings/Planning_groups/_planning_groups.js"></SCRIPT>

<input type="checkbox"
		<cfif val( qgetplannertemplate.allow_individual_distributors ) eq 1>
			checked
		</cfif>
		name="Allow_Individual_Distributors"> Allow Individual Distributors

<!--- Distributor Filters --->
<table class="filter" cellpadding="2" cellspacing="0">
	<col width="37%">
	<col width="15%">
	<col width="15%">
	<col width="15%">
	<col width="18%">
	<tr bgcolor="FFCE8">
		<td colspan="100%" bgcolor="FFC99"><font size="2px;"><b><cfoutput>#distributor_labels.Planner_Labels_Singular#</cfoutput> Filters</b></font></td>
	</tr>
	<tr bgcolor="ecfab4" style="height:20px">
		<td class="heading" style="text-align:left;">
			Attribute
		</td>
		<td class="heading">
			Field in Search
		</td>
		<td class="heading">
			In Group Search
		</td>
		<td class="heading">
			Allow Filters
		</td>
		<td class="heading">
			Filters
		</td>
	</tr>
	<cfloop query = "qGetCustomerGroups">

	 <cfset bAllowFilter = 0 />
	<cfparam name="form.Customers_Filters_#Distributor_Group_Level_ID#" default="" />

	<cfquery name="qGetSelections" dbtype="query">
		SELECT	Group_Level_ID,
				PG_Group_Type,
				Allow_In_Search,
				Allow_In_Group_Search,
				Allow_Filter
		FROM	qGetPlannerFiltersData
		WHERE	Group_Level_ID = #Distributor_Group_Level_ID#
		AND		PG_Group_Type = 2
	</cfquery>

	<cfquery name="qGetProductSelections" dbtype="query">
		SELECT	Distributor_Group_ID
		FROM	qGetPlannerFiltersCustomerData
		WHERE	Distributor_Group_Level_ID = #Distributor_Group_Level_ID#
	</cfquery>
	<cfif qGetSelections.Allow_Filter eq 1>
		<cfset bAllowFilter = 1 />
	</cfif>
	<cfset "form.Customers_Filters_#Distributor_Group_Level_ID#" = #ValueList(qGetProductSelections.Distributor_Group_ID)# />
	<tr>
		<td>
			#Group_Level_Desc#
		</td>
		<td align="center">
			<input type="checkbox" name="Allow_In_Search_#Distributor_Group_Level_ID#" value="1" <cfif qGetSelections.Allow_In_Search eq 1>checked</cfif> />
		</td>
		<td align="center">
			<input type="checkbox" name="Allow_In_Group_Search_#Distributor_Group_Level_ID#" value="1" <cfif qGetSelections.Allow_In_Group_Search eq 1>checked</cfif> />
		</td>
		<td align="center">
			<input
				type="checkbox"
				name="Allow_Filter_#Distributor_Group_Level_ID#"
				id="Allow_Filter_#Distributor_Group_Level_ID#"
				value="1" <cfif qGetSelections.Allow_Filter eq 1>checked</cfif>
				onclick="toggleFieldDisplay('Allow_Filter_#Distributor_Group_Level_ID#','withoutLinkItem_#Distributor_Group_Level_ID#','withLinkItem_#Distributor_Group_Level_ID#');"
			/>
		</td>

		<td>
			<b>
			<div id="withLinkItem_#Distributor_Group_Level_ID#" <cfif bAllowFilter EQ 0>style="display:none;"</cfif> align="center">
				[ <a href="##" onclick="javascript:selectCusFiltersPopup(#Distributor_Group_Level_ID#);return false;">select filters</a> ]
			</div>
			<div id="withoutLinkItem_#Distributor_Group_Level_ID#" <cfif bAllowFilter EQ 1>style="display:none;"</cfif> align="center" title="Check Allow Filters to select filters">
				[ check filters ]
            </div>
			</b>
			<input name="Customers_Filters_#Distributor_Group_Level_ID#"	type="hidden"  value="#form["Customers_Filters_" & Distributor_Group_Level_ID]#" />
		</td>
	</tr>

	</cfloop>
</table>
<br>
<!--- Product Filters --->
<table class="filter" cellpadding="2" cellspacing="0">
	<col width="37%">
	<col width="15%">
	<col width="15%">
	<col width="15%">
	<col width="18%">
	<tr bgcolor="FFCE8">
		<td colspan="100%" bgcolor="FFC99"><font size="2px;"><b><cfoutput>#application.returned_customer_setting.Item_Label#</cfoutput> Filters</b></font></td>
	</tr>
	<tr bgcolor="ecfab4" style="height:20px">
		<td class="heading" style="text-align:left;">
			Attribute
		</td>
		<td class="heading">
			Default View
		</td>
		<td class="heading">
			#Application.PlannerLabel# View
		</td>
		<td class="heading">
			Allow Filters
		</td>
		<td class="heading">
			Filters
		</td>
	</tr>

	<cfloop query = "qGetProductGroups">
		<cfset bAllowFilter = 0 />
		<cfparam name="form.Product_Filters_#Product_Group_Level_ID#" default="" />

		<cfquery name="qGetProdSelections" dbtype="query">
			SELECT	Group_Level_ID,
					PG_Group_Type,
					Allow_In_Search,
					Allow_Filter,
					Default_view
			FROM	qGetPlannerFiltersData
			WHERE	Group_Level_ID = #Product_Group_Level_ID#
			AND		PG_Group_Type = 1
		</cfquery>

		<cfquery name="qGetProductSelections" dbtype="query">
			SELECT	Product_Group_ID
			FROM	qGetPlannerFiltersProductData
			WHERE	Product_Group_Level_ID = #Product_Group_Level_ID#
		</cfquery>

		<cfset "form.Product_Filters_#Product_Group_Level_ID#" = valueList(qGetProductSelections.Product_Group_ID) />
		<cfif qGetProdSelections.Allow_Filter eq 1>
			<cfset bAllowFilter = 1 />
		</cfif>

		<tr>
			<td>
				#Group_Level_Desc#
			</td>
			<td align="center">
				<input type="radio" name="default_view" value="#Product_Group_Level_ID#" <cfif qGetProdSelections.default_view eq "1">checked</cfif>/>
			</td>
			<td align="center">
				<input type="checkbox" class="planner" name="Allow_In_Search_Prod_#Product_Group_Level_ID#" value="1" <cfif qGetProdSelections.Allow_In_Search eq 1>checked</cfif>  <cfif qGetProdSelections.default_view eq "1">disabled</cfif> />
			</td>
			<td align="center">
				<input
					type="checkbox"
					name="Allow_Filter_Prod_#Product_Group_Level_ID#"
					id="Allow_Filter_Prod_#Product_Group_Level_ID#"
					value="1"
					<cfif Product_Group_Level_ID eq 9>disabled</cfif>
					<cfif qGetProdSelections.Allow_Filter eq 1>checked</cfif>
					onclick="toggleFieldDisplay('Allow_Filter_Prod_#Product_Group_Level_ID#','withoutLinkItemProd_#Product_Group_Level_ID#','withLinkItemProd_#Product_Group_Level_ID#');"
				/>
			</td>

			<td>
				<b>
				<div id="withLinkItemProd_#Product_Group_Level_ID#" <cfif bAllowFilter EQ 0>style="display:none;"</cfif> align="center">
					[ <a href="##" onclick="javascript:selectProductFiltersPopup(#Product_Group_Level_ID#);return false;">select filters</a> ]
				</div>
				<div id="withoutLinkItemProd_#Product_Group_Level_ID#" <cfif bAllowFilter EQ 1>style="display:none;"</cfif> align="center" title="Check Allow Filters to select filters">
					[ check filters ]
	            </div>
				</b>
				<input name="Product_Filters_#Product_Group_Level_ID#"	type="hidden" value="#form["Product_Filters_" & Product_Group_Level_ID]#"  />
			</td>
		</tr>
	</cfloop>
</table>
<br>

<!--- Operator Filters --->
<table class="filter" cellpadding="2" cellspacing="0">
	<col width="37%">
	<col width="15%">
	<col width="15%">
	<col width="15%">
	<col width="18%">
	<tr bgcolor="FFCE8">
		<td colspan="100%" bgcolor="FFC99"><font size="2px;"><b><cfoutput>#operator_labels.Planner_Labels_Singular#</cfoutput> Filters</b></font></td>
	</tr>
	<tr bgcolor="ecfab4" style="height:20px">
		<td class="heading" style="text-align:left;">
			Attribute
		</td>
		<td class="heading" colspan="2">
			Field in Search
		</td>
		<td class="heading" colspan="2">
			Filters
		</td>
	</tr>
	<cfloop query = "qGetOperatorGroups">

	 <cfset bAllowFilter = 0 />
	<cfparam name="form.Operator_Filters_#Operator_Group_Level_ID#" default="" />


	<cfquery name="qGetSelections" dbtype="query">
		SELECT	Allow_Filter
		FROM	qGetPlannerFiltersData
		WHERE	Group_Level_ID = #Operator_Group_Level_ID#
		AND		PG_Group_Type = 3
	</cfquery>

	<cfquery name="qGetOperatorSelections" dbtype="query">
		SELECT	Operator_Group_ID
		FROM	qGetPlannerFiltersOperatorData
		WHERE	Operator_Group_Level_ID = #Operator_Group_Level_ID#
	</cfquery>
	<cfif qGetSelections.Allow_Filter eq 1>
		<cfset bAllowFilter = 1 />
	</cfif>

	<cfset "form.Customers_Filters_#Operator_Group_Level_ID#" = #ValueList(qGetOperatorSelections.Operator_Group_ID)# />
	<tr>
		<td>
			#Group_Level_Desc#
		</td>

		<td align="center" colspan="2">
			<input
				type="checkbox"
				name="Allow_Filter_#Operator_Group_Level_ID#"
				id="Allow_Filter_#Operator_Group_Level_ID#"
				value="1" <cfif qGetSelections.Allow_Filter eq 1>checked</cfif>
				onclick="toggleFieldDisplay('Allow_Filter_#Operator_Group_Level_ID#','withoutLinkItem_#Operator_Group_Level_ID#','withLinkItem_#Operator_Group_Level_ID#');"
				class="whlsPlannerSwith"
			/>
		</td>

		<td colspan="2">
			<b>
			<div id="withLinkItem_#Operator_Group_Level_ID#" <cfif bAllowFilter EQ 0>style="display:none;"</cfif> align="center" class="withLinkItem">
				[ <a href="##" onclick="javascript:selectOperFiltersPopup(#Operator_Group_Level_ID#);return false;" class="whlsPlannerSwith">select filters</a> ]
			</div>
			<div id="withoutLinkItem_#Operator_Group_Level_ID#" <cfif bAllowFilter EQ 1>style="display:none;"</cfif> align="center" title="Check Allow Filters to select filters" class="withoutLinkItem">
				[ check filters ]
            </div>
			</b>
			<input name="Operators_Filters_#Operator_Group_Level_ID#"	type="hidden"  value="#form["Customers_Filters_" & Operator_Group_Level_ID]#" />
		</td>
	</tr>

	</cfloop>
</table>
<input name="groupLevelId" 				type="hidden"  value="" />
<input name="SelectedFilterGroups"		type="hidden"  value="" />
<input name="lDistributorGroupLevelIDs"	type="hidden"  value="#ValueList(qGetCustomerGroups.Distributor_Group_Level_ID)#" />
<input name="lProductGroupLevelIDs"		type="hidden"  value="#ValueList(qGetProductGroups.Product_Group_Level_ID)#" />
<input name="lOperatorGroupLevelIDs"	type="hidden"  value="#ValueList(qGetOperatorGroups.Operator_Group_Level_ID)#" />
</cfsavecontent>

#application.util.string.compress( variables.uncompressed )#

<cfinclude template="/common_files/jQuery.cfm">

<script>

	<cfif form.Wholesaler_Planner eq 0>
		$(".whlsPlannerSwith").prop( "disabled", true ).prop( "checked", false ).addClass("disabled");
	</cfif>

	function selectCusFiltersPopup(GroupID)
	{
		var actionFrm = document.DataForm;
		var lsValsToDel = "";
		var sURL = "";
		actionFrm.groupLevelId.value=GroupID;
		sURL = "DistributorGroup_Search.cfm?FormName=DataForm&FieldName=SelectedFilterGroups&groupLevelId=" + GroupID + "&PlannerTemplateFiltersID=#form.id#";
		NewWindow(sURL, 'Select_filters', 1000, 800, 'yes', 'yes');
	}

	function selectOperFiltersPopup(GroupID)
	{
		var actionFrm = document.DataForm;
		var lsValsToDel = "";
		var sURL = "";
		actionFrm.groupLevelId.value=GroupID;
		sURL = "OperatorGroup_Search.cfm?FormName=DataForm&FieldName=SelectedFilterGroups&groupLevelId=" + GroupID + "&PlannerTemplateFiltersID=#form.id#";
		NewWindow(sURL, 'Select_filters', 1000, 800, 'yes', 'yes');
	}

	function callback_save_filter() {
  		var new_products = $("input[name=filter_product_list]").val();
        $("input[name=SelectedFilterGroups]").val( new_products );
        $("form[name=DataForm]").submit();
	}

	function selectProductFiltersPopup(GroupID)
	{
		$("form[name=add_groups] input[name=product_group_level_id]").val( GroupID );
		$("form[name=add_groups] input[name=parent_call_back]").val( "callback_save_filter()" );
		$("input[name=filter_product_list]").val( $("input[name=Product_Filters_" + GroupID + "]").val() );
		$("input[name=command]").val("svData");
		$("input[name=groupLevelId]").val(GroupID);
        $("form[name=add_groups]").submit();
	}

	/* click event for default view radio button */
	$("input[name=default_view]").click(function() {
		/* find planner view on the same row */
		var planner_view = $(this).closest("tr").find("input[name=Allow_In_Search_Prod_" + $(this).val());
		/* enable all planner view checkboxes */
		$("input.planner").attr("disabled", false);
		/* enable only the planner view on the same row */
		planner_view.attr("checked", "checked").attr("disabled", "disabled");
	});

	/***
	$("input.planner").click(function() {
		if (! $(this).is(":checked")) {
			var default_view = $(this).closest("tr").find("input[name=default_view]");
			default_view.attr("checked", false);
		}
	});
	***/
</script>
</cfoutput>
