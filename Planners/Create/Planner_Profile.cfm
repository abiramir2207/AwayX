 <!----------------------------------------------------------------------------------
Name         : 	Planner_Profile.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	05/03/2016
Created By   : 	Anand Rao
Description  : 	Page to create NUC Targets
---------------------------------------------------------------------------------->

<cf_layout_planner>
	<cfparam name="url.PageTitle" default="Planner Profile" />

	<cfinclude template="/planners/create/planner_volume_constants.cfm">
		<cfoutput>
			<cfscript>
				if ( structKeyExists(form, "page_creating") eq false ) {
					plannerManager.savePlannerProfile( form );
					sleep(2500);
				}
				variables.readonly  = ( form.mode neq constants.edit or form.product_group_level_id neq request.defaultProductFilterAttr.Product_Group_Level_ID );
			</cfscript>
		</cfoutput>
	<cfparam name="form.filter_product_list" default="" />

	<cfscript>
		udf = createObject( "component", "components.udf" );
		getPlannerProfileData         = plannerManager.getPlannerProfile( plannerID=form.plannerID );
		qGetProdAttrData              = plannerManager.getProdAttrData( request.defaultProductFilterAttr.product_group_level_id );
		qGetPlannerProfileProductData = plannerManager.getPlannerProfileProductData( request.plannerID,
																					 request.defaultProductFilterAttr.product_group_level_id,
																					 form.filter_product_group_level_id,
																					 form.filter_product_list );
	</cfscript>

	 <cf_include files="/styles/css-loader.css, /common_files/dhx_message.cfm, /common_files/datatable2.css, /common_files/dataTables2.cfm">

		<cfset plannerUOMS= "">
		<cfif getPlanner.UOM_CS EQ "1">
			<cfset plannerUOMS= ListAppend(plannerUOMS,"1",",")>
		</cfif>
		<cfif getPlanner.UOM_LB EQ "1">
			<cfset plannerUOMS= ListAppend(plannerUOMS,"2",",")>
		</cfif>
		<cfif getPlanner.UOM_EA EQ "1">
			<cfset plannerUOMS= ListAppend(plannerUOMS,"5",",")>
		</cfif>

	 <style>
		.hdr419 { margin-bottom:3px; font-size:11px; }
		form[name=pp_form] { margin-left: 7px; width: 60%; }
		td.hdr419 { width:30%; }
		.right { text-align: right !important; }
		.center { text-align: center !important; }
		.tblhdr419 { background-color:#9BC2E6; padding:2px; }
		.even419 { background-color:#f6f6f6; }
		.datagrid tbody tr.even { background-color:#EEE; }
		select.uom { width: 80%; }
		table.maintable tbody td { padding: 7px 10px }
		table.maintable2 tbody td { padding: 6px 10px }
		table.maintable tbody td { border-bottom: 1px solid #ddd }
		hr.two { margin: 20px 0; }
		div.distributors {
			margin-bottom: 15px;
		}
		table.DataTable {
			height: 40vh;
		}
		th.left {
			text-align: left !important;
			line-height: 18px;
		}
		span.group {
			letter-spacing: 0.5px;
			color: blue;
			opacity: 0.8;
		}
		label.opaque-h {
			margin-left: 15px;
		}
		a.filter {
			margin: 0 15px;
		}
	</style>
	<cfoutput>
		<div class="hdr419">
            <cfif variables.readonly is false>
				<a href="##" id="save" title="click to save changes">#application.util.string.linkFormat("save")#</a>
                <!--- #(form.indirect_planner eq 1)# --->
			</cfif>
		</div>

		<!-------------------------------------------------->
		<!--- this form is used in "add groups" option --->
		<!--- ----------------------------------------------------------------------------------------------------------------->
		<form name="add_groups" method="post" action="/Planners/Templates/ProductGroup_Search.cfm" onsubmit="popup_form(this, 'add_groups', 900, 800)">
			<cfset qProducts = plannerManager.getPlannerProducts( request.plannerID, request.defaultProductFilterAttr.product_group_level_id )>
			<input type="hidden" name="product_group_level_id" value="#request.defaultProductFilterAttr.product_group_level_id#">
			<input type="hidden" name="selection_input_name" value="product_list">
			<input type="hidden" name="product_list" value="#valueList(qProducts.Item_Key)#">
			<input type="hidden" name="ExistingProductList" value="#valueList(qProducts.Item_Key)#">
			<input type="hidden" name="parent_call_back" value="callback_add_groups()">
			<input type="hidden" name="plannerID" value="#form.plannerID#">
		</form>

		<!-------------------------------------------------->
		<!--- this form is used in "add products" option --->
		<!--- ----------------------------------------------------------------------------------------------------------------->
		<form name="vp_add_items" method="post" id="vp_add_items" action="/Planners/Create/planner_add_product.cfm" onsubmit="popup_form(this, 'vp_add_items', 900, 800);">
			<!--- <cfset application.util.struct.convertToHiddenInput( form, "product_list,action,page_creating,plannerID,ExistingProductList" )> --->
			<input type="hidden" name="ExistingProductList" value="#valueList(qProducts.Item_Key)#">   	<!--- this is used in "add groups" & "add products" --->
			<input type="hidden" name="product_list" value="">   <!--- this is used in "add groups" & "add products" --->
			<input type="hidden" name="action" value="select_products">
			<input type="hidden" name="plannerID" value="#form.plannerID#">
			<input type="hidden" name="parent_call_back" value="callback_add_products()">
		</form>

		<!------------------------->
		<!---  add filter form  --->
		<!------------------------------------------------------------------------------------------------------------------------->
		<form name="add_filter" method="post" action="/Planners/Templates/ProductGroup_Search.cfm" onsubmit="popup_form(this, 'add_filter', 900, 800)">
			<input type="hidden" name="product_group_level_id" value="#form.filter_product_group_level_id#">
			<input type="hidden" name="parent_call_back" value="callback_filter_products()">
			<input type="hidden" name="selection_input_name" value="filter_product_list">
			<input type="hidden" name="filter_product_list" value="#form.filter_product_list#">
		</form>
	</cfoutput>

    <cfparam name="form.action" default="">
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~ saving selected distributors to the database ~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfif form.action is "save_distributors">
        <cfparam name="form.selected_distributors" default="">

		<!--- <cfdump var="#form#" abort="true"> --->
		<cfstoredproc procedure="Planner_Customer_Save" datasource="#application.datasource#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname = "@Planner_ID" value = "#form.plannerid#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname = "@Group_Level_ID" value = "0">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname = "@Distributor_Group_ID" value = "#form.selected_distributors#">
		</cfstoredproc>
    </cfif>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~ saving selected operators to the database ~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfif form.action is "save_operators">
        <cfquery datasource="#application.datasource#">
            UPDATE Planner_Operators
               SET Deleted = 1
             WHERE Planner_ID = <cfqueryparam value="#form.plannerID#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfloop list="#form.selected_operators_2#" index="local.operator_id">
            <cfquery datasource="#application.datasource#">
                INSERT INTO Planner_Operators
                    (
                        BSA_Operator_ID,
                        Created_By,
                        Planner_ID
                    )
                VALUES
                    (
                        <cfqueryparam value="#local.operator_id#">,
                        <cfqueryparam value="#request.AccessStructure.user_id#">,
                        <cfqueryparam value="#form.plannerID#">
                    )
            </cfquery>
        </cfloop>

        <cfquery datasource="#application.datasource#">
            INSERT INTO Contract_Operators (
                                                Contract_Main_ID
                                                , BSA_Operator_ID
                                            )
                SELECT cm.Contract_Main_ID, po.BSA_Operator_ID
                  FROM Contract_Main cm
                        INNER JOIN Planner_Operators po
                            ON po.Planner_ID = cm.Planner_ID AND po.Deleted = 0
                 WHERE cm.Planner_ID = <cfqueryparam value="#form.plannerID#" cfsqltype="cf_sql_integer">
                                AND ( cm.Approved = 1 OR cm.Deleted = 0 )
                                AND NOT EXISTS (
                                                    SELECT 1
                                                      FROM Contract_Operators co
                                                     WHERE co.Contract_Main_ID = cm.Contract_Main_ID
                                                                AND co.BSA_Operator_ID = po.BSA_Operator_ID
                                                                AND co.Deleted = 0
                                                )

            UPDATE co
               SET Deleted = 1
              FROM Contract_Main cm
                        INNER JOIN Contract_Operators co ON co.Contract_Main_ID = cm.Contract_Main_ID AND co.Deleted = 0
             WHERE cm.Planner_ID = <cfqueryparam value="#form.plannerID#" cfsqltype="cf_sql_integer">
                        AND ( cm.Approved = 1 OR cm.Deleted = 0 )
                        AND NOT EXISTS (
                                            SELECT 1
                                              FROM Planner_Operators po
                                             WHERE po.Planner_ID = cm.Planner_ID
                                                        AND co.BSA_Operator_ID = po.BSA_Operator_ID
                                                        AND po.Deleted = 0
                                        )
        </cfquery>
    </cfif>

	<form name="pp_form" method="post" id="pp_form" action="Planner_Profile.cfm">
        <input type="hidden" name="action">
		<cfset topnav_elements  = [	"filter_product_list",
									"forecasts",
									"mode",
									"period",
									"plannerID",
									"totals",
									"uom"
							   ]>
		<cfset application.util.struct.saveToHiddenInput( form, arrayToList(topnav_elements) )>
		<cfoutput>
			<input type="hidden" name="profileRowCount"				value="#getPlannerProfileData.RecordCount#">
			<input type="hidden" name="profileProductRowCount"		value="#qGetPlannerProfileProductData.RecordCount#">
			<table cellpadding ="2" cellspacing="2" border="0" width="70%" class=maintable2>
				<tr>
					<td class="hdr419"> <b>Title:</b> </td>
					<td>
						<input type="text" name="txtPlannerTitle" id="txtPlannerTitle" size="40" value="#getPlannerProfileData.Planner_Title#" />
					</td>
				</tr>
				<tr>
					<td class="hdr419"> <b>NickName:</b> </td>
					<td>
						<input type="text" name="txtPlannerNickName" id="txtPlannerNickName" size="40" value="#getPlannerProfileData.Planner_NickName#" />
					</td>
				</tr>
				<tr>
					<td class="hdr419"> <b>Perf start day:</b> </td>
					<td>
						<select name="selWeekday" id="selWeekday">
						<option value="0" <cfif getPlannerProfileData.Planner_Perf_Start_Day eq 0>selected</cfif>>Select a Weekday</option>
						<option value="1" <cfif getPlannerProfileData.Planner_Perf_Start_Day eq 1>selected</cfif>>Sunday</option>
						<option value="2" <cfif getPlannerProfileData.Planner_Perf_Start_Day eq 2>selected</cfif>>Monday</option>
						<option value="3" <cfif getPlannerProfileData.Planner_Perf_Start_Day eq 3>selected</cfif>>Tuesday</option>
						<option value="4" <cfif getPlannerProfileData.Planner_Perf_Start_Day eq 4>selected</cfif>>Wednesday</option>
						<option value="5" <cfif getPlannerProfileData.Planner_Perf_Start_Day eq 5>selected</cfif>>Thursday</option>
						<option value="6" <cfif getPlannerProfileData.Planner_Perf_Start_Day eq 6>selected</cfif>>Friday</option>
						<option value="7" <cfif getPlannerProfileData.Planner_Perf_Start_Day eq 7>selected</cfif>>Saturday</option>
						</select>
					</td>
				</tr>
			</table>

			<cfset distributor_groups = 0>
			<!--- D111109 - Planner Profile tab - remove add distributors / Anand Rao / 15-Oct-2021 --->
            <cfif (getPlanner.Category is "WholeSaler" AND form.indirect_planner)>
                <cfif variables.readonly is false>
                    <div style="margin:0 0 15px 0;">
    				    <a class="operators">#application.util.string.linkFormat( "add " & lcase(request.planner_labels.operator_plural) )#</a>
	    		    </div>
                </cfif>
            <cfelse>

               	<cfif (variables.readonly is false AND udf.is_planner_indirect_category( planner_category = getPlanner.Category ))>
					<cfset distributor_groups = val( getPlanner.Allow_Individual_Distributors ) ? 0 : 1>
                    <div style="margin:0 0 15px 0;">
    				    <a class="distributors">#application.util.string.linkFormat( "add "
																						& ( distributor_groups
																								? lcase( request.planner_labels.distributor_singular ) & " groups"
																								: lcase( request.planner_labels.distributor_plural ) ) )#</a>
						<cfif distributor_groups>
							<a class="members" style="margin-left:30px;"> #application.util.string.linkFormat( "view members" )# </a>
						</cfif>
	    		    </div>
                </cfif>
                <cfset distributor_data_set = []>
                <div class="distributors">
                    <table class="dataTable row-border order-column hover distributors">
                            <cfset qCustomers = plannerManager.getCustomers( form.plannerID, distributor_groups )>
							<cfif distributor_groups>
                            	<thead>
                                    <tr>
                                        <th class="left">#request.planner_labels.distributor_singular# Group</th>
                                        <th class="left">Group Name</th>
                                    </tr>
								</thead>
							<cfelse>
                            	<thead>
                                    <tr>
                                        <th class="left">#request.planner_labels.distributor_singular# ID</th>
                                        <th class="left">Name</th>
                                    </tr>
								</thead>
							</cfif>

							<tbody>
								<cfloop query="qCustomers">
									<cfset distributor_data_set.append( [ qCustomers.Number, qCustomers.Description ] )>
								</cfloop>
							</tbody>
                    </table>
                </div>
                <!--- selected distributors are saved in this hidden input element; add distributors popup refers/updates this element dynamically --->
                <input type="hidden" name="selected_distributors" value="#valueList( qCustomers.ID )#">
                <br style="clear:both;"><br>
            </cfif>




            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  MSA planner - show operators  --->
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <cfset operator_data_set = []>
           <!---  <cfif (udf.is_planner_indirect_category( planner_category = getPlanner.Category ) or form.indirect_planner)> --->
		   <!--- D111109 - Planner Profile tab - remove add distributors / Anand Rao / 15-Oct-2021 --->
		   <!--- D114955 - Need Multiple Operator Codes on MSA Plans Visibl / Anand Rao / 20-Apr-2022 --->
		    <cfif ( ( getPlanner.Category is "WholeSaler" AND form.indirect_planner )
					OR ( udf.is_planner_indirect_category( planner_category = getPlanner.Category ) ) )>
                <div class="operators">
                    <table class="dataTable row-border order-column hover operators">
                            <cfset qOperators = plannerManager.getMSAOperators( form.plannerID )>
                        <thead>
                            <tr>
                                <th class="left">#request.planner_labels.operator_singular# ID</th>
                                <th class="left">Name</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop query="qOperators">
                                <cfset operator_data_set.append( [qOperators.Legacy_ID, qOperators.Operator_Name] )>
                            </cfloop>
                        </tbody>
                    </table>
                </div>
                <input type="hidden" name="selected_operators_2" value="">
                <br style="clear:both;"><br>
            </cfif>

			<table cellpadding ="2" cellspacing="0" border="0" width="100%" class="maintable">
				<thead>
				<tr class="tblhdr419">
					<td rowspan="2" style="padding-left: 10px;">
						<strong>Performance Types</strong>
					</td>
					<td rowspan="2" class="center">
						<b>Duration<br> [Weeks] </b>
					</td>
					<td colspan="2" class="center">
						<b>#request.planner_labels.delivery_plural# Dates</b>
					</td>
				</tr>
				<tr class="tblhdr419">
					<td  style="font-size:11px;"  class="center">
						<b>Days &lt; start<br> [days] </b>
					</td>
					<td  style="font-size:11px;"  class="center">
						<b>Days &lt; end<br> [days] </b>
					</td>
				</tr>
				</thead>
				<tbody>
				<!--- data columns --->
				<cfset i = 2>
				<cfloop query="getPlannerProfileData">
					<tr <cfif (i % 2 NEQ 0)>class="even419a"</cfif>>
						<td><b>#getPlannerProfileData.Description#</b></td>
						<td class="center">
							<input class="right" type="text" name="Duration_#getPlannerProfileData.Planner_Template_Perf_Types_ID#" value="#getPlannerProfileData.Duration#" size="4">
						</td>
						<td class="center">
							<input class="right" type="text" name="DaysLessStart_#getPlannerProfileData.Planner_Template_Perf_Types_ID#" value="#getPlannerProfileData.Planner_Delivery_Days_Start#" size="4">
						</td>
						<td class="center">
							<input class="right" type="text" name="DaysLessEnd_#getPlannerProfileData.Planner_Template_Perf_Types_ID#" value="#getPlannerProfileData.Planner_Delivery_Days_End#" size="4">
						</td>
					</tr>
					<cfset i++ />
				</cfloop>
				</tbody>
			</table>
			<div style="clear: both;height:36px;">
			</div>

                <div style="margin-bottom:10px;">
		            <!--- <cfif variables.readonly is false> --->
        	            <cfif form.product_group_level_id eq "">
            	            <a id="add_products" title="click to add products" class="add_item">#application.util.string.linkFormat("add products")#</a>
                	    <cfelse>
                    	    <a id="add_groups" title="click to add groups" class="add_item">#application.util.string.linkFormat("add groups")#</a>
                    	</cfif>
            		<!--- </cfif> --->
					<cfscript>
						request.components.datamanager = createObject( "component", "components.products.Group.DataManager" );
						queries.product_groups         = request.components.datamanager.getProductGroupsData();
						queries.product_filters        = CreateObject("component", "mvc.Models.Planner.PlannerTemplateManager").getPlannerFilters(form.planner_template_id, 1, 1);
						vars.lProductFilters           = valueList(queries.product_filters.Group_Level_ID);
					</cfscript>

					<label class="opaque-h"><b>filter products</b></label>
					<select name="filter_product_group_level_id" style="width:150px;" visible="1">
						<option value=""></option>
						<cfloop query="queries.product_groups">
							<cfif form.product_group_level_id neq queries.product_groups.product_group_level_id and listFindNoCase(vars.lProductFilters, queries.product_groups.product_group_level_id)>
								<option <cfif form.filter_product_group_level_id eq queries.product_groups.product_group_level_id>selected</cfif> value="#queries.product_groups.product_group_level_id#">#queries.product_groups.group_level_desc#</option>
							</cfif>
						</cfloop>
					</select>
					<a id="add_filter" title="click to add filter products" class="filter">#application.util.string.linkFormat("add filter")#</a>
					<a id="reset_filter" title="click to reset filter products" class="secondary filter">#application.util.string.linkFormat("reset filter")#</a>
                </div>

			<!--- Product Every Day Unit Price --->
			<cfset data_set = []>
			<cfif qGetPlannerProfileProductData.RecordCount>
				<table class="dataTable row-border order-column hover everyday">
					<thead>
						<tr>
							<th style="text-align:left"><input type="checkbox" id="checkall"></th>
							<th class="left">ID</th>
							<th class="left">#request.product_label#</th>
							<th class="dt-head-center">Everyday Unit Retail</th>
							<th class="dt-head-left">
	                            <cf_uom_dropdown
	                                program_id				=	""
	                                company_main_id			=	""
	                                default_option_on		=	"1"
	                                default_option_text		=	""
	                                default_option_value	=	""
	                                dropdown_name			=	"mass_uom"
	                                option_text_abbreviated	=	"1"
	                                plural_uom_display		=	""
	                                selected_uom_id			=	""
	                                uom_id_exclusion_list	=	""
	                                uom_id_inclusion_list	=	"#plannerUOMS#"
	                                show_EA                 =	"1"><br>
								<a href="##" id="apply">#application.util.string.linkFormat("apply")#</a>
							</th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>

				<cfloop query="qGetPlannerProfileProductData">
					<cfset selUOM = qGetPlannerProfileProductData.UOM />
					<cfif selUOM eq ""> <cfset selUOM = getPlanner.uom_default /> </cfif>
					<cfsavecontent variable="price_uom">
                            <cf_uom_dropdown
                                program_id				=	""
                                company_main_id			=	""
                                default_option_on		=	"0"
                                default_option_text		=	""
                                default_option_value	=	""
                                dropdown_name			=	"#qGetPlannerProfileProductData.Item_Key#_uom"
                                option_text_abbreviated	=	"1"
                                plural_uom_display		=	""
                                selected_uom_id			=	"#selUOM#"
                                uom_id_exclusion_list	=	""
                                uom_id_inclusion_list	=	"#plannerUOMS#"
                                show_EA                 =	"1"
                            >
					</cfsavecontent>
					<cfsavecontent variable="unit_price"><input class="right autoselect" type="text" name="#qGetPlannerProfileProductData.Item_Key#" value="#qGetPlannerProfileProductData.EveryDay_Unit_Price#" size="6"></cfsavecontent>
					<cfset arrayAppend(data_set, [ "<input type=checkbox value='#qGetPlannerProfileProductData.Item_Key#'>" ,qGetPlannerProfileProductData.Item, qGetPlannerProfileProductData.Description, unit_price, price_uom ])>
				</cfloop>

			</cfif>
		</cfoutput>
	</form>

		<!--- D111109 - Planner Profile tab - remove add distributors / Anand Rao / 15-Oct-2021 --->
	    <cfif (getPlanner.Category is "WholeSaler" AND form.indirect_planner)>
		<cfoutput>
        <form name="add_operators" method="post" action="/planners/create/planner_operators.cfm" onsubmit="popup_form(this, 'planner_operators', 800, 600)">
            <input type="hidden" name="template_id" value="#getPlanner.planner_template_id#">
            <input type="hidden" name="selected_operators" value="#valueList(qOperators.bsa_operator_id)#">
            <input type="hidden" name="operators_input" value="selected_operators_2">
            <input type="hidden" name="callback" value="callback_add_operators">
        </form>
	    </cfoutput>
    </cfif>

	<cfoutput>
	<!--------------------------------------------------------------------------------------------------------------------------
	NOTE: The same input may be used in more than one form (e.g. filter_product_list, product_list). The reason is we need to pass
	the same piece of information to different parts of the page. Popup page has a small form. And submit page has a larger form.
	--------------------------------------------------------------------------------------------------------------------------->
	<!--------------------------->
	<!---  reset filter form  --->
	<!------------------------------------------------------------------------------------------------------------------------->
	<form name="filter_products" method="post">
		<input type="hidden" name="filter_product_list" value="#form.filter_product_list#">
		<input type="hidden" name="action" value="filter_products">
		<cfset application.util.struct.convertToHiddenInput( form, "filter_product_list,action" )>
	</form>
	</cfoutput>

	<cfinclude template="topnav_form.cfm">
	<cfinclude template="/common_files/dhx_message.cfm">

	<script>
		let changes_count = 0;
		sWidth = 0;
		var data_table = $("table.everyday").DataTable({	data          : <cfoutput>#serializeJSON( data_set )#</cfoutput>,
															dom           : "fti",
															columns       : [ 	{ orderable:false },
																				{},
																				{},
																				{ orderable:false, className:"dt-body-center" },
																				{ orderable:false } ],
															language      : { search: <cfoutput>"Search #request.product_label#:"</cfoutput> },
															order         : [
																				<cfif application.util.query.get_setting( "Sort_Planner_Products_By", 0 ) is "Description">
																					[ 2, "asc" ]
																				</cfif>
																			],
															scrollY       : "40vh",
															scrollX       : false,
															scrollCollapse: true,
															paging        : false
														});

		<cfif form.mode neq 'E'>
			$("input[type=text], input[type=checkbox], a.add_item, select:not([visible])").attr("disabled", true).addClass("disabled");
		</cfif>

		$("#checkall").click(function(e) {
			var checkall = $(this).prop("checked");
			$("input[type=checkbox]").prop("checked", checkall);
			e.stopPropagation();
		});

		$("#apply").click(function(e) {
			var mass_value = $("select[name=mass_uom]").val();
			if ( mass_value ) {
				$("input:checked").each(function(){
					$("select[name=" + $(this).val() + "_uom]").val( mass_value );
				});
			}
		});

		$("#save").click(function() {
			if ( $("#txtPlannerTitle").val().length == 0 ) {
				dhtmlx.alert({ text: "Please enter a <cfoutput>#Application.PlannerLabel#</cfoutput> title." });
			} else {
				show_loader("SAVING CHANGES, PLEASE WAIT...");
				data_table.search( '' ).draw( false );   // reset search string to show hidden rows
				$("#pp_form").submit();
			}
		});

		$("table.maintable tbody tr").hover(function(){
			$(this).toggleClass("even419");
		});

        function save_distributors(){
            show_loader();
            $("input[name=action]").val( "save_distributors" );
            $("#pp_form").submit();
        }

		$("a.distributors").click(function(){
            <!--- ~~~~ selected = the hidden input name where selected distributors are tracked ~~~~~ --->
            <cfoutput>
			<cfif distributor_groups>
                popupInCenter( "/planners/create/select_distributor_groups.cfm"
                                        + "?planner_id=#getPlanner.Planner_ID#"
                                        , "distributor_groups", 800, 600 );
			<cfelse>
                popupInCenter( "/planners/create/planner_distributors.cfm"
                                        + "?template_id=#getPlanner.planner_template_id#"
                                        + "&planner_id=#getPlanner.Planner_ID#"
                                        + "&selected=selected_distributors"
                                        + "&callback=save_distributors"
                                        , "distributor_groups", 800, 600 );
			</cfif>
            </cfoutput>
		});

		$("a.operators").click(function(){
            $("form[name=add_operators]").submit();
		});

        <cfif isDefined("distributor_data_set")>
            $("table.distributors").DataTable({	data          : <cfoutput>#serializeJSON( distributor_data_set )#</cfoutput>,
                                                                dom           : <cfif distributor_data_set.len() gt 1>"fti"<cfelse>"t"</cfif>,
                                                                columns       : [
                                                                                    {},
                                                                                    {} ],
                                                                language      : { search: <cfoutput>"Search #request.planner_labels.distributor_singular#:"</cfoutput> },
                                                                order         : [ ],
                                                                scrollY       : "40vh",
                                                                scrollX       : false,
                                                                scrollCollapse: true,
                                                                paging        : false
                                                            });
        </cfif>

		$("table.operators").DataTable({	data          : <cfoutput>#serializeJSON( operator_data_set )#</cfoutput>,
															dom           : <cfif operator_data_set.len() gt 1>"fti"<cfelse>"t"</cfif>,
															columns       : [
																				{},
																				{} ],
                                                            language      : { search: <cfoutput>"Search #request.planner_labels.operator_singular#:"</cfoutput> },
															order         : [ ],
															scrollY       : "40vh",
															scrollX       : false,
															scrollCollapse: true,
															paging        : false
														});

		$("#add_products").click(function() {
			<cfoutput>
				popupInCenter("/Common_Files/contracts/product_Select_V1.cfm?Formname=vp_add_items&Return_Value_Field_Name=product_list&plannerID=#form.plannerID#", "ProductSelectWindow");
			</cfoutput>
		});

		$("#add_groups").click(function() {
			$("form[name=add_groups]").submit();
		});

		<!----------------------------------------->
		<!---  call back functions from popups  --->
		<!--------------------------------------------------------------------------------------------------------------------->
		function callback_filter_products() {
			show_loader();
			$("form[name=filter_products]").submit();
		}

		function callback_add_groups() {
			$("form[name=vp_add_items]").submit();
		}
		function callback_add_products() {
			$("form[name=vp_add_items]").submit();
		}
        function callback_add_operators() {
            show_loader();
            $("input[name=action]").val( "save_operators" );
            $("#pp_form").submit();
        }

		function add_filter() {
			var filter = $( "select[name=filter_product_group_level_id]" );
			$("input[name=filter_product_group_level_id]").val( filter.val() );
			/* update the product group level id used in add filter popup */
			$("form[name=add_filter] input[name=product_group_level_id]").val( filter.val() );
			$("form[name=add_filter]").submit();
		}

		$( "#add_filter" ).click( function() {
			var filter = $( "select[name=filter_product_group_level_id]" );
			if ( filter.val() === "" ) {
				filter.focus();
				alert( "Please select an option in the filter products dropdown first." );
				return;
			}

			if ( changes_count == 0 ) {
				add_filter();
			}
			else {
				dhtmlx.confirm( {   ok: "Cancel", cancel: "Continue",
									title: "Alert!",
									type: "confirm-warning",
									// note - cancel_button is for ignoring changes and ok_button is for going back to save changes ( reserved order )
									callback: function( cancel_button_clicked ) { if ( cancel_button_clicked == false ) add_filter(); },
									text: "You have <b>unsaved changes</b> on the page.<br><br> \
										   Click <b>Cancel</b> to go back to save them and retry this option.<br><br> \
										   Click <b>Continue</b> to ignore all your changes and proceed."
								   } );
			}
		});

		$("#reset_filter").click(function(){
			$("input[name=filter_product_list]").val( "" );
			$("input[name=filter_product_group_level_id]").val( "" );
			show_loader();
			$("form[name=filter_products]").submit();
		});

		$("select[name=filter_product_group_level_id]").change(function(){
			/* clear out the previous selected list used in add filter popup */
			$("input[name=filter_product_list]").val( "" );
		});

		$( "a.members" ).click( function() {
            popupCenter2022( "distributor_members.cfm"
                                    + "?id=" + <cfoutput> #getPlanner.Planner_ID# </cfoutput>
                                    + "&column=Planner", "distributor_members", "XS", "LG" );
		});

		// keep track of unsaved changes on the page
		$( "input[type=text],     \
		    select.editablefield, \
			select[name=selWeekday]" ).change( function() { changes_count++; } );
    </script>

    <cfinclude template="\common_files\popup2022.cfm">

</cf_layout_planner>
