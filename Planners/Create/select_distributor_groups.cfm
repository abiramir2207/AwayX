<cfif isDefined( "form.action" ) and form.action is "save">
    <cfstoredproc procedure="Planner_Customer_Save" datasource="#application.datasource#">
        <cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname = "@Planner_ID" value = "#form.planner_id#">
        <cfprocparam type="in" cfsqltype="cf_sql_integer" dbvarname = "@Group_Level_ID" value = "#form.group_level_id#">
        <cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname = "@Distributor_Group_ID" value = "#form.distributors#">
    </cfstoredproc>

    <cfinclude template="/common_files/jQuery.cfm">

    <script>
        $( "form[name=topnav]", window.opener.document ).submit();
        window.close();
    </script>
    <cfabort>
</cfif>

<cfscript>
    labelManager           = createObject( "component", "components.settings.Labels.Labels" ).init();
    planner_labels         = labelManager.plannerLabels();
    request.planner_labels = planner_labels;
</cfscript>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <cfoutput>
    <title>Select #request.planner_labels.distributor_singular# Groups</title>
    </cfoutput>
</head>
<body>
	<cfscript>
        qDistributors = queryExecute(   "
                                            SELECT   g.Group_GUID
                                                    ,g.Group_Number
                                                    ,g.Group_Desc
                                                    ,p.Planner_Template_ID
                                                    ,pg.Distributor_Group_Level_ID
                                            FROM  Planners                          p
                                                INNER JOIN Planner_Customer_Groups  pg
                                                    ON pg.Planner_ID = p.Planner_ID
                                                INNER JOIN All_Customer_Group_Types g
                                                    ON g.Group_GUID  = pg.Distributor_Group_ID
                                            WHERE  p.Planner_ID               = #url.planner_id#
                                            AND  p.Distributor_Group_Level_ID = -2

                                            UNION

                                            SELECT   g.Group_GUID
                                                    ,g.Group_Number
                                                    ,g.Group_Desc
                                                    ,p.Planner_Template_ID
                                                    ,p.Distributor_Group_Level_ID
                                            FROM  Planners                          p
                                                INNER JOIN All_Customer_Group_Types g
                                                    ON g.Group_GUID = p.Customer_ID
                                            WHERE  p.Planner_ID = #url.planner_id#
                                            AND  IsNull ( p.Distributor_Group_Level_ID, 0 ) NOT IN ( 0, -1, -2 )  "
            								, {}, { datasource: application.datasource } );

        if ( qDistributors.recordCount ) {
            template_id = qDistributors.planner_template_id;
        }
        else {
            qTemplate = queryExecute( " SELECT Planner_Template_ID FROM Planners WHERE Planner_ID = #url.planner_id# ", {}, { datasource: application.datasource } );
            template_id = qTemplate.Planner_Template_ID;
        }

		qTopLevels = queryExecute(	            " SELECT 	L.Distributor_group_level_ID,
															cast(L.Is_pg as int) IS_PG,
															L.Group_Level_Desc
													FROM Planner_Template_Filters PTF
														INNER JOIN Distributor_Group_Level L
															ON L.Distributor_Group_Level_ID = PTF.Group_Level_ID
												WHERE PTF.Planner_Template_ID = #template_id#
														AND PTF.PG_Group_Type = 2
														AND PTF.Allow_In_Group_Search = 1
														ORDER BY Group_Level_Desc  "
													, {}, { datasource: application.datasource } );
    </cfscript>

	<cfset jQueryUI.widgets = "tooltip">
	<cfinclude template="/common_files/jQuery.cfm">
	<cf_include files="/common_files/datatable2.css, /common_files/dataTables2.cfm, /common_files/dhx_message.cfm, /styles/css-loader.css">

    <style>
        div#customers_filter {
            text-align: left;
        }
    </style>

    <form id="select_customers" method="post">
        <input type="hidden" name="distributor_list">
        <input type="hidden" name="group_level_id">
        <input type="hidden" name="action" value="save">
        <cfoutput>
        <input type="hidden" name="planner_id" value="#url.planner_id#">
        </cfoutput>

		<div class="dist-btn-group" style="margin-bottom: 10px">
			<span class=SectionHeader> Select Top Level Group: </span>
			<select name="top_level_group">
				<option value="" grpID='' pg=''>Select Group</option>
				<!--- look for customized customer types for this planner template - Butter Ball custom request --->
				<cfoutput><cfset planner_template_customer_types = application.util.query.get_setting("planner_template_#trim(template_id)#_customer_types", 0)></cfoutput>

				<!--- default standard handling --->
				<cfif planner_template_customer_types eq ''>
					<cfoutput query="qTopLevels">
						<option class="dist-button"
                            <cfif qDistributors.Distributor_Group_Level_ID eq qTopLevels.distributor_group_level_id> selected </cfif>
                            grpID="#qTopLevels.distributor_group_level_id#" pg="#qTopLevels.is_pg#">
							#qTopLevels.group_level_desc#
						</option>
					</cfoutput>
				<cfelse>
					<!--- custom handling for Butter Ball to support custom order, custom types --->
					<cfloop list="#planner_template_customer_types#" item="customer_type">
						<cfquery name="qCustomerType" dbtype="query">
							SELECT *
							FROM qTopLevels
							WHERE group_level_desc = '#trim(customer_type)#'
						</cfquery>

						<cfif qCustomerType.recordCount>
							<cfoutput>
								<option class="dist-button"
                                    <cfif qDistributors.Distributor_Group_Level_ID eq qCustomerType.distributor_group_level_id> selected </cfif>
                                    grpID="#qCustomerType.distributor_group_level_id#" pg="#qCustomerType.is_pg#">
									#qCustomerType.group_level_desc#
								</option>
							</cfoutput>
						</cfif>
					</cfloop>
				</cfif>
			</select>

            <cfoutput>
                <a style="margin:0 25px" id="save">#application.util.string.linkFormat( "save" )#</a>
                <a onclick="window.close()">#application.util.string.linkFormat( "cancel" )#</a>
            </cfoutput>
		</div>

		<table class="dataTable row-border order-column hover datagrid" id="customers" width="100%">
			<col width="5%">
			<col width="20%">
			<col width="75%">
			<thead>
				<tr>
					<!-- 1 --> <th style="text-align:left;cursor:pointer;"><input type="checkbox" id="checkall"></th>
					<!-- 2 --> <th style="text-align:left"><cfoutput>Name</cfoutput></th>
					<!-- 3 --> <th style="text-align:left"><cfoutput>ID</cfoutput></th>
				</tr>
			</thead>
			<!--- data inserted here by data grid below --->
			<tbody> </tbody>
		</table>
    </form>

	<script>
        <cfoutput>
        // save previously selected distributors
        let selected = "#valueList( qDistributors.Group_GUID )#".split( ',' );
        </cfoutput>

		$("th:first").click(function() {
			var checkall = $("#checkall");
			checkall.prop("checked", !checkall.prop("checked"));
			$("input[type=checkbox]").prop("checked", checkall.prop("checked"));
		});

		$("#checkall").click(function(e) {
			var checkall = $(this).prop("checked");
			$("input[type=checkbox]").prop("checked", checkall);
			e.stopPropagation();
		});

		$("input.hand").click(function(e) {
			e.stopPropagation();
		});

		$("*[title]").tooltip();

		$("tr td:nth-child(1)").click(function() {
			var checkbox = $(this).find("input[type=checkbox]");
			checkbox.prop("checked", !checkbox.prop("checked"));
		});

		// customer group type selected, display customers
		$("select").change(function (){
			var option = $(this).find( "option:selected" );
			var groupLevelId = option.attr( "grpID" );
			var isPG = option.attr( "pg" );

            // remove existing table
            if ( $.fn.dataTable.isDataTable('#customers') ) { data_table.clear().draw().destroy(); }

            $.getJSON( '/mvc/Models/Planner/PlannerTemplateManager.cfc',
                {
                    method:"getPlannerTemplateCustomers",
                    returnFormat:"json",
                    "id"           : <cfoutput> "#template_id#", </cfoutput>
                    "groupLevelId" : groupLevelId,
                    "isPG"         : isPG
                },
                // success
                function(mydata){
                    data_table =  $('#customers').DataTable({
                        "aaSorting": [ [1, "asc"] ],
                        "data": mydata.DATA,
                        "paging": false,
                        "processing":true,
                        "orderClasses": true,
                        "ScrollCollapse": true,
                        scrollY: "77vh",
                        "sDom": 'fti',
                        columnDefs: [
                            {targets:0, visible:true, sortable:false, className:"left",
                                render: function ( data, type, row ) {
                                                                        let checked = selected.indexOf( row[ 0 ] ) === -1 ? '' : "checked";
                                                                        return  ("<input name='distributors' type='checkbox' class='hand' " + checked + " value='" + row[0] + "'>");
                                                                    } },
                            {targets:1, title:"Group Number", visible:true, className:"left",
                                render: function ( data, type, row ) {
                                                                        return "<a class=members href='#' guid='" + row[ 0 ] + "'> " + row[ 1 ] + " </a>";
                                                                     } },
                            {targets:2, title:"Group", visible:true, className:"left", render: function ( data, type, row ) { return row[2]} },
                            {targets:'_all', visible:false}
                        ]
                    }); // DataTable

                    $( "a.members" ).click( function () {
                        popupCenter2022( "distributor_members.cfm"
                                                + "?customer="  + $( this ).attr( "guid" )
                                                + "&top_level=" + $( "select[name=top_level_group] option:selected").attr( "grpid" )
                                                + "&template="  + <cfoutput> #template_id# </cfoutput>
                                                + "&column=Distributor", "distributor_members", "XS", "LG" );
                    });

                    $("#save").click(function() {
                        // reset the filter input to bring back all selected elements
                        $( "div#customers_filter input").val( '' );
                        show_loader();
                        var selected = [];
                        data_table.$("input.hand:checked").each(function() {
                            selected.push( $(this).val() );
                        });
                        if ( selected.length == 0 ) {
                            dhx_alert( "Please select at least one <cfoutput>#planner_labels.distributor_singular#</cfoutput>.");
                        }
                        else {
                            $("input[name=group_level_id]").val( groupLevelId );
                            $("#select_customers").submit();
                        }
                    });

                    // clear out selected entries due to potential switching top level group
                    selected = [];
                } // success
            ); // $.getJSON
        }); // span[grpID].click

        // automatically expand options for previous selected top level
        if ( $( "select[name=top_level_group]").val() ) {
		    $("select").trigger("change");
        }
	</script>

    <cfinclude template="\common_files\popup2022.cfm">

</body>
</html>
