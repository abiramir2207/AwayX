<!doctype html>

<CFSCRIPT>
Border="Yes";
BorderSize=1;
BorderColor="orange";
Image="/images/plus3.gif";
ImageOpen="/images/minus3.gif";
TitleColor="Blue";
TitleFont="Arial";
TitleSize=9;
IsClosed="Yes";
</CFSCRIPT>

<CF_OPENLAYER
	BORDER="#Border#"		BORDERSIZE="#BorderSize#"
	BORDERCOLOR="#BorderColor#"	IMAGE="#Image#"
	IMAGEOPEN="#ImageOpen#"		TITLE="Select Templates"
	TITLECLOSED="Select Templates"	TITLETOOLTIP="Click here to toggle view"
	TITLECOLOR="#TitleColor#"	TITLEFONT="#TitleFont#"
	TITLESIZE="#TitleSize#"		ISCLOSED="#IsClosed#">

<cfsilent>
<!---------------------------------------------------------------------------------------------------------------------
      Template: \Program_Wizard\component_select_templates_grid.cfm
      Date:     2015 June
      Author:   Milan Mushran
      Purpose:  select/unselect templates, assign/unassign "paid to" for component's templates,
      assign/unassign default "paid to" for component's templates.
----------------------------------------------------------------------------------------------------------------------->

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />

<cfset qComponents = CreateObject("component","components.programs.template.TemplateManager").getAllTemplateDiscountComponents(
										templateId = 0,
										discountTypeList = component_select_templates_discount_type_id,
										returnSelected = 0,
										componentId = component_select_templates_component_id,
										templateIsDominant = 1) />


<!--- Get the data for the template generic type "filter" dropdown. --->
<cfset useLakebaseForqGetType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qcomponents")>
<cfif useLakebaseForqGetType>
	<cftry>
		<cfset qGetType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qcomponents", {
				"select" = "generic_type"
			}), "generic_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetType>
<cfquery name="qGetType" dbtype="query">
SELECT DISTINCT Generic_Type
FROM qComponents
</cfquery>
</cfif>

<!--- All paid to's --->
<cfset useLakebaseForGetPaymentPaidToTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_paid_to_types")>
<cfif useLakebaseForGetPaymentPaidToTypes>
	<cftry>
		<cfset GetPaymentPaidToTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payment_paid_to_types", {
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetPaymentPaidToTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetPaymentPaidToTypes>
<cfquery name="GetPaymentPaidToTypes" datasource="#application.datasource#">
SELECT distinct *
FROM Payment_Paid_To_Types
WHERE Deleted = 0
</cfquery>
</cfif>

<cfscript>
	listPaidToTypes = valueList(GetPaymentPaidToTypes.Payment_Paid_To_ID);
	// save all general labels into a structure
	general_labels = application.util.query.generalLabel();
</cfscript>


<!--- "aaData" parameter (an array of arrays) for DataTables --->
<cfset variables.aaData = []>

<cfset AtLeastOne_Default_Component_For_Rates_Grid = 0>
<cfset AtLeastOne_Default_Component_For_CF_Pages = 0>

<cfoutput query="qComponents">

<cfset compCount = templateManager.getCompCountForTemplateAndDiscountType(qComponents.Template_ID,component_select_templates_discount_type_id)>

<cfset Default_Component_For_Rates_Grid = 0>
<cfset Default_Component_For_CF_Pages = 0>

	<!--- If "Rates Grid" is ON, and the discount type is "rebates" or "Fixed Price".
	Note:Rates Grid is for rebate and/or fixed price.
	--->
	<cfif qComponents.Fixed_Rebate_Grid_Option AND (component_select_templates_discount_type_id EQ 1 OR component_select_templates_discount_type_id EQ 2)>
		<cfset Default_Component_For_Rates_Grid = 1>
		<!--- Check whether there is at least one template which has "rates grid" ON. --->
		<cfset AtLeastOne_Default_Component_For_Rates_Grid = 1>
	</cfif>

	<!--- If "Rates Grid" is OFF OR the discount type is NOT "rebates" and "Fixed Price".
	Note:Rates Grid is for rebate and/or fixed price.
	For a template, "Default Paid to" select box at the component level should always be available for non-rebate and non-fixed price discount pages,
	but it may or noy not be disabled based on template.
	For rebate and fixed price discount pages, the select box should be available, only when the "rates grid" is OFF on the template.
	For rebate, we can still have the select box available, when groups need to be set up from the CF discount pages, even when
	the products rates are set up from the rates grid. This happens when the "group" checkbox is ON on the "details" tab for rebate on the template..
	--->
	<cfif qComponents.Fixed_Rebate_Grid_Option eq 0 OR (component_select_templates_discount_type_id NEQ 1 AND component_select_templates_discount_type_id NEQ 2)
		OR (component_select_templates_discount_type_id EQ 2 AND (qComponents.Discount_Rebates_Group_Level EQ 1 AND appSettings.getTemplateMultipleProductAttrGroups() EQ 0))>
		<cfset Default_Component_For_CF_Pages = 1>
		<!--- Check whether there is at least one template which has has a discount type ON and where "rates grid" is not the only option ON.  --->
		<cfset AtLeastOne_Default_Component_For_CF_Pages = 1>
	</cfif>

	<!--- All paid to's on a template --->
	<cfset useLakebaseForqPaymentPaidToOnTemplate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_paid_to_template_mapping")>
<cfif useLakebaseForqPaymentPaidToOnTemplate>
	<cftry>
		<cfset qPaymentPaidToOnTemplate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payment_paid_to_template_mapping", {
				"template_id" = "eq.#qComponents.Template_ID#",
				"deleted" = "eq.0",
				"select" = "payment_paid_to_id"
			}), "payment_paid_to_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqPaymentPaidToOnTemplate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqPaymentPaidToOnTemplate>
<cfquery name="qPaymentPaidToOnTemplate" datasource="#application.datasource#">
	SELECT Payment_Paid_To_ID
	FROM Payment_Paid_To_Template_Mapping
	WHERE Template_ID = '#qComponents.Template_ID#'
	AND Deleted = 0
	</cfquery>
</cfif>

	<cfset listPaidToTypesInThisTemplate = valueList(qPaymentPaidToOnTemplate.Payment_Paid_To_ID)>

	<!--- All paid to's for a template, component and discount type combination. --->
	<cfquery name="qPaymentPaidToOnTemplateComponent" datasource="#application.datasource#">
	SELECT DISTINCT ptcpt.Payment_Paid_To_ID
	FROM Program_Template_Component ptc
	INNER JOIN
	Program_Template_Component_And_Paid_To ptcpt
	ON ptc.Program_Template_Component_ID = ptcpt.Program_Template_Component_ID
	WHERE ptc.Template_ID = '#qComponents.Template_ID#'
	AND ptc.Component_ID = '#qComponents.Component_ID#'
	AND ptc.Discount_Type_ID = '#component_select_templates_discount_type_id#'
	AND ptc.deleted = 0
	AND ptcpt.deleted = 0
	</cfquery>

	<cfset listPaidToTypesInThisTemplateComponent = valueList(qPaymentPaidToOnTemplateComponent.Payment_Paid_To_ID)>

	<cfset variables.aTemp = []>

	<!--- data column 1 - "Generic Type" dropdown. --->
	<cfset arrayAppend(variables.aTemp, general_labels[ Generic_Type ])>

	<!--- data column 2 - "Created Type' textbox. --->
	<cfset arrayAppend(variables.aTemp,Created_Type)>

	<cfsavecontent variable="CheckBox_Template">
		<input type="hidden" name="Single_Component_Per_Discount_Type_#qComponents.Template_ID#" value="#qComponents.Single_Component_Per_Discount_Type#">
		<span id="error_Template_Paid_To_Select_#component_select_templates_discount_type_id#_#qComponents.Template_ID#"></span>
		<span id="error_Template_Paid_To_Default_#component_select_templates_discount_type_id#_#qComponents.Template_ID#"></span>
		<!--- If "Single Component per Discount Type" template setting is ON, then check to see whether a component is already included for that discount type. If yes, then disable
		the "include" checkbox. Do not disable it for the component which is already selected, so that the user can unselect it, if needed. --->
		<input type="checkbox" genericType="#Generic_Type#" name="Template_Select_#component_select_templates_discount_type_id#" class="cb" value="#qComponents.Template_ID#" OnClick="unselectAllOptions(this)" <cfif compCount gt 0 and Component_Selected eq 0>disabled</cfif><cfif Component_Selected eq 1>checked</cfif>>
	</cfsavecontent>

	<!--- data column 3 - "Include template" checkbox. --->
	<cfset arrayAppend(variables.aTemp,CheckBox_Template)>

	<!--- "Paid to" checkboxes. --->
	<cfloop query="GetPaymentPaidToTypes">
		<cfsavecontent variable="CheckBox_PaidTo">
		<input type="checkbox" name="Template_Paid_To_Select_#component_select_templates_discount_type_id#_#Payment_Paid_To_ID#" class="cb_#GetPaymentPaidToTypes.payment_Paid_To_ID#" value="#qComponents.Template_ID#"
		<cfif ListFindNoCase(listPaidToTypesInThisTemplateComponent,Payment_Paid_To_ID)>checked</cfif>
		<!--- If the "paid to" is not turned on for the template, disable the checkbox. --->
		<cfif NOT ListFindNoCase(listPaidToTypesInThisTemplate,Payment_Paid_To_ID)>disabled</cfif>>
		</cfsavecontent>
		<!--- data column 4.
		Note: There will be as many columns as Paid to's.
		--->
		<cfset arrayAppend(variables.aTemp,CheckBox_PaidTo)>
	</cfloop>


	<!--- "Default paid to" select box for the CF pages (discount type pages). --->
	<cfsavecontent variable="selectBox_Template_Paid_To_Default_CF_Pages">
		<span id="error_Template_Paid_To_Default_CF_Pages_#component_select_templates_discount_type_id#_#qComponents.Template_ID#"></span>
		<select name="Template_Paid_To_Default_CF_Pages_#component_select_templates_discount_type_id#" class="sbox_1" style="width:98%" <cfif Default_Component_For_CF_Pages eq 0>disabled</cfif>>
		<option value="0_0">----None----</option>
		<cfloop query="GetPaymentPaidToTypes">
		<option value="#qComponents.Template_ID#_#GetPaymentPaidToTypes.payment_Paid_To_ID#"<cfif qComponents.Default_Paid_To_CF_Pages eq GetPaymentPaidToTypes.payment_Paid_To_ID>SELECTED</cfif>>#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = GetPaymentPaidToTypes.Payment_Paid_To_Type_Identifier, paidToDesc=GetPaymentPaidToTypes.Payment_Paid_To_Type_Name)#</option>
		</cfloop>
		</select>
	</cfsavecontent>

	<!--- data column 5 --->
	<cfset arrayAppend(variables.aTemp,selectBox_Template_Paid_To_Default_CF_Pages)>

	<!--- "Default paid to" select box for the rates grid. --->
	<cfsavecontent variable="selectBox_Template_Paid_To_Default_Rates_Grid">
		<select name="Template_Paid_To_Default_Rates_Grid_#component_select_templates_discount_type_id#" class="sbox_2" style="width:98%" <cfif Default_Component_For_Rates_Grid eq 0>disabled</cfif>>
		<option value="0_0">----None----</option>
		<cfloop query="GetPaymentPaidToTypes">
		<option value="#qComponents.Template_ID#_#GetPaymentPaidToTypes.payment_Paid_To_ID#" <cfif qComponents.Default_Paid_To_Rates_Grid eq GetPaymentPaidToTypes.payment_Paid_To_ID>SELECTED</cfif>>#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = GetPaymentPaidToTypes.Payment_Paid_To_Type_Identifier, paidToDesc=GetPaymentPaidToTypes.Payment_Paid_To_Type_Name)#</option>
		</cfloop>
		</select>
	</cfsavecontent>
	<!--- data column 6. --->
	<cfset arrayAppend(variables.aTemp,selectBox_Template_Paid_To_Default_Rates_Grid)>

	<cfset arrayAppend(variables.aaData, variables.aTemp)>
</cfoutput>
</cfsilent>

<!---<html>
<head>
    <title>select component templates</title>
    --->
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
    <style>
	.right { float: right; }
	table.datagrid { table-layout: fixed; }
	table.datagrid td { height: 20px; overflow: hidden; }
	th, td { overflow:hidden; }
	td.center { text-align: center; }
	thead th { text-align:left; }
	thead input, thead select, tfoot input { width: 98%; }
	th.center { text-align: center; }
    </style>
<!---</head>--->

<cfset arraylistColumnSizes = ArrayNew(1)>

<!--- data column width for column 1 ("Generic Type" dropdown) --->
<cfset ArrayAppend(arraylistColumnSizes,1.5) />

<!--- data column width for column 2 ("Created Type' textbox) --->
<cfset ArrayAppend(arraylistColumnSizes,2.5) />

<!--- data column width for column 3 ("Include template" checkbox) --->
<cfset ArrayAppend(arraylistColumnSizes,.6) />

<!--- data column width for paid to columns. There could be more than one.
(checkboxes for "paid to")
--->
<cfloop query="GetPaymentPaidToTypes">
	<cfset ArrayAppend(arraylistColumnSizes,.6) />
</cfloop>

<!--- data column width for "discount type" select box --->
<cfif AtLeastOne_Default_Component_For_CF_Pages eq 1>
	<cfset ArrayAppend(arraylistColumnSizes,1.25) />
</cfif>

<!--- data column width for "rates grid" select box --->
<cfif AtLeastOne_Default_Component_For_Rates_Grid eq 1>
	<cfset ArrayAppend(arraylistColumnSizes,1.25) />
</cfif>

<!---<body>--->
	<cfsavecontent variable="variables.body">

		<!---<div class="header">
			<span>
				<cfoutput>
				<a href="##" id="reset">#application.util.string.actionLinkFormat2("reset filter")#</a>
				</cfoutput>
			</span>
		</div>--->

		<div class="content">
			<!--- data table grid --->
			<cfset variables.columnSizes = arraylistColumnSizes>

			<!--- Get the percent values for column widths. --->
			<cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( variables.columnSizes )>

			<table id="datagrid" class="datagrid" style='table-layout:fixed;width:100%;'>
				<!--- Set the column width. --->
				<cfoutput>
				<cfloop from="1" to="#ArrayLen(variables.columnSizes)#" index="i">
					<col width="#variables.columnSizes[i]#%">  <!---All columns--->
				</cfloop>

				<thead>
					<!--- column headers --->
					<tr>
						<th class="center">Template<br />Type</th>
						<th class="center">Template<br />Name</th>
						<th class="center">Include</th>
						<cfloop query="GetPaymentPaidToTypes">
						<th class="center">Paid To <br />#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = GetPaymentPaidToTypes.Payment_Paid_To_Type_Identifier, paidToDesc=GetPaymentPaidToTypes.Payment_Paid_To_Type_Name)#</th>
						</cfloop>

						<cfif AtLeastOne_Default_Component_For_CF_Pages>
						<th class="center"><strong>Default Paid To</strong></th>
						</cfif>

						<cfif AtLeastOne_Default_Component_For_Rates_Grid><th class="center"><strong>Default Paid To <br /> for Rates Grid</strong></th></cfif>
					</tr>

					<!--- column filters --->
					<tr id="filter">
						<th class="csvExclude center">
							<select name="filter_generic_type">
								<option value="">All</option>
								<cfloop query="qGetType">
									<option>#general_labels[ Generic_Type ]#</option>
								</cfloop>
							</select>
						</th>
						<th class="csvExclude"><input type="text" name="filter_template"></th>
						<th class="csvExclude center"><input type="checkbox" name="checkall" class="checkall"></th>
						<cfloop query="GetPaymentPaidToTypes">
						<th class="csvExclude center"><input type="checkbox" name="checkall_#GetPaymentPaidToTypes.currentrow#" class="checkall"></th>
						</cfloop>

						<cfif AtLeastOne_Default_Component_For_CF_Pages>
						<th class="csvExclude center">mass apply
							<select name="massApplydefaultCFPages" class="massApply">
								<option value="">----None----</option>
								<cfloop query="GetPaymentPaidToTypes">
								<option>#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = Payment_Paid_To_Type_Identifier, paidToDesc=Payment_Paid_To_Type_Name)#</option>
								</cfloop>
							</select>
						</th>
						</cfif>

						<cfif AtLeastOne_Default_Component_For_Rates_Grid>
						<th class="csvExclude center">mass apply
							<select name="massApplydefaultRatesGrid" class="massApply">
								<option value="">----None----</option>
								<cfloop query="GetPaymentPaidToTypes">
								<option>#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = Payment_Paid_To_Type_Identifier, paidToDesc=Payment_Paid_To_Type_Name)#</option>
								</cfloop>
							</select>
						</th>
						</cfif>
					</tr>
				</thead>
				</cfoutput>
				<tbody>
				</tbody>
			</table>
		</div> <!--- class="content" --->
	</cfsavecontent>
	<!--- remove extra white spaces prior to displaying on the page --->
	<cfoutput>#application.util.string.compress( variables.body )#</cfoutput>


	<cfinclude template="/common_files/jQuery.cfm">
	<cfinclude template="/common_files/dataTables2.cfm">
	<script src="/script/javascript/table2csv.js?d"></script>
	<script src="/script/javascript/jquery.noty.packaged.min.js"></script>
	<script src="/script/javascript/jquery.dataTables-api.js"></script>

	<script src="/Script/javascript/dom_common.js"></script>

<script>
	var  my_form = $('form[name=DataForm]')
	//,checkall = $("input[name=checkall")
	,windowHeight = $(window).height()
	//,sScrollY = Math.floor( ( windowHeight > 800 ? 0.75 : .73 ) * windowHeight )
	,mydatagrid = $('#datagrid').show().dataTable({
		"aaData": <cfoutput>#serializeJSON(variables.aaData)#</cfoutput>
		,"aaSorting": []
		,"aoColumns": [	{"bSortable":true, "sClass":"center"}    /* generic Type */
				,{"bSortable":true, "sClass":"center"}    /* template */
				,{"bSortable":false, "sClass":"center"}     /* include template */
				<cfloop query="GetPaymentPaidToTypes">
				,{"bSortable":false, "sClass":"center"}     /* payment paid to coliumn(s) */
				</cfloop>
				<cfif AtLeastOne_Default_Component_For_CF_Pages>
				,{"bSortable":false, "sClass":"center"}     /* default for cf pages (discount types) */
				</cfif>
				<cfif AtLeastOne_Default_Component_For_Rates_Grid>
				,{"bSortable":false, "sClass":"center"}     /* default for rates grid */
				</cfif>
					]
		,"bAutoWidth": false            // false for quicker rendering
		,"bDeferRender": true           // true for quicker rendering
		,"bPaginate": false
		,"bProcessing": true            // true to show processing message in sorting large table
		,"bScrollCollapse": false
		,"bSortCellsTop": true          // true to inform sorting on first row in thead
		,"bSortClasses": false
		,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
		,"sDom": 'tir'
		//,"sScrollY": sScrollY
		//If one turns "sScrollY" on, then after data filtering,the table size (width and height) increases.
	});

	// highlight current row
	$('#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

	// set up multiple columns filter
	$("#filter th").each( function ( i ) {
	    $('select, input', this).change( function (e) {
		if (! $(this).hasClass("checkall") && ! $(this).hasClass("massApply")) {
	        	mydatagrid.fnFilter( $(this).val(), i );
	    	}
	    });
	});

	// on Enter key filter data in the focused column
	$("form").keypress(function(e) {
		if (e.which == 13) {
			$("#filter th").each( function ( i ) {
			    $('select:focus, input:focus', this).each( function (e) {
	    			//if ($(this).attr("name") !== "checkall" && $(this).attr("name") !== "massApply") {
				if (! $(this).hasClass("checkall") && ! $(this).hasClass("massApply")) {
			        	mydatagrid.fnFilter( $(this).val(), i );
	    			}
			    });
			});
			return false;
		}
	});

	// "Check all" checkbox for "Include template.
	$('input[name=checkall]').change(function() {
		$("input.cb").attr("checked", (this.checked ? true : false));
	});

	// reset all filters
	function reset_filters() {
		$("#filter th").each( function ( i ) {
		    $('select, input', this).each(function() {
		    	//if ($(this).attr("name") !== "checkall" && $(this).attr("name") !== "massApply") {
			if (! $(this).hasClass("checkall") && ! $(this).hasClass("massApply")) {
					// if filter is not empty clear it and refresh
					if ( $(this).val().length ) {
			        	$(this).val("");
			        	mydatagrid.fnFilter( "", i );
					}
		    	}
		    });
		});
		//checkall.removeAttr("checked");
		return true;
	};
	/*$("#reset").click(function() { reset_filters(); });*/


	// First paid to checkbox (check all checkbox).
	$('input[name=checkall_1]').change(function() {

		var massApplyChecked = $(this).attr("checked");

		$("input.cb_1").each( function ( ) {
			// find parent tr
			var tr = $(this).closest("tr");

			// find first checkbox checked status
			var cbChecked = tr.find("input[type=checkbox]:first").attr("checked");

			// Check the paid to checkbox, if the "mass appply" checkbox and the template checkbox is checked.
			$(this).attr("checked", (cbChecked &&  massApplyChecked ? true : false));
		});

	});

	// Second paid to checkbox (check all checkbox),if any.
	$('input[name=checkall_2]').change(function() {
		var massApplyChecked = $(this).attr("checked");

		$("input.cb_2").each( function ( ) {
			// find parent tr
			var tr = $(this).closest("tr");

			// find first checkbox checked status
			var cbChecked = tr.find("input[type=checkbox]:first").attr("checked");

			// Check the paid to checkbox, if the "mass appply" checkbox and the template checkbox is checked.
			$(this).attr("checked", (cbChecked &&  massApplyChecked ? true : false));
		});
	});

	// Third paid to checkbox (check all checkbox),if any.
	$('input[name=checkall_3]').change(function() {
		var massApplyChecked = $(this).attr("checked");

		$("input.cb_3").each( function ( ) {
			// find parent tr
			var tr = $(this).closest("tr");

			// find first checkbox checked status
			var cbChecked = tr.find("input[type=checkbox]:first").attr("checked");

			// Check the paid to checkbox, if the "mass appply" checkbox and the template checkbox is checked.
			$(this).attr("checked", (cbChecked &&  massApplyChecked ? true : false));
		});
	});

	// Fourth paid to checkbox (check all checkbox),if any.
	$('input[name=checkall_4]').change(function() {
		var massApplyChecked = $(this).attr("checked");

		$("input.cb_4").each( function ( ) {
			// find parent tr
			var tr = $(this).closest("tr");

			// find first checkbox checked status
			var cbChecked = tr.find("input[type=checkbox]:first").attr("checked");

			// Check the paid to checkbox, if the "mass appply" checkbox and the template checkbox is checked.
			$(this).attr("checked", (cbChecked &&  massApplyChecked ? true : false));
		});
	});

	// Discount type select box for mass apply.
	$('select[name=massApplydefaultCFPages]').change(function() {
		 var massApplySelectedIndex = $(this).prop('selectedIndex');

		$("select.sbox_1").each( function ( ) {
			// find parent tr
			var tr = $(this).closest("tr");

			// find first checkbox checked status
			var cbChecked = tr.find("input[type=checkbox]:first").attr("checked");

			// If the template checkbox is checked, apply the "paid to" for the template.
			if(cbChecked){
				$(this).prop('selectedIndex', massApplySelectedIndex);
			}
		});
	});

	// Rates grid select box for mass apply.
	$('select[name=massApplydefaultRatesGrid]').change(function() {
		var massApplySelectedIndex = $(this).prop('selectedIndex');

		$("select.sbox_2").each( function ( ) {
			// find parent tr
			var tr = $(this).closest("tr");

			// find first checkbox checked status
			var cbChecked = tr.find("input[type=checkbox]:first").attr("checked");

			// If the template checkbox is checked, apply the "paid to" for the template.
			if(cbChecked){
				$(this).prop('selectedIndex', massApplySelectedIndex);
			}
		});
	});

	function unselectAllOptions(objChkBox)
	{
		if(objChkBox.checked == false)
		{
			var tr = $(objChkBox).closest("tr");

			/* Find all the checkboxes on the row that was clicked, except the first one (the one that was checked/unchecked). */
			var chkBoxes = tr.find("input[type=checkbox]:not(input[type=checkbox]:first)");

			/* uncheck all the checkboxes */
			chkBoxes.attr("checked", false);

			/* Find all the selectboxes on the row that was clicked. */
			var selectBoxes = tr.find("select");

			/* reset the selectboxes. */
			$(selectBoxes).prop("selectedIndex", 0);
		}
	}
</script>
<!---
Note: The JS validation code for this file is on "program_wizard\component_select_templates_grid_js.js".
--->

<!---</body>--->
<CF_MessageWindow>
</CF_OPENLAYER>
<!---</html>--->
