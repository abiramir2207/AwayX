<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
	   File Name:  AwayX/Planners/Include/select_planner_distributors.cfm
	Created Date:  2016 Apr
	  Created By:  kal
	 Description:  displays products from source planner not in target planner during copy
--------------------------------------------------------------------------------------------------------------------------------------------------------------->
<style>
	th.left { text-align: left;}
	td.center { text-align: center; }
	td.hand { cursor: pointer; }
	td.numeric { text-align: right; }
	div.actions a { margin: 0 50px; position: relative; top: -2px; }
	.dist-btn-group { margin: 5px 5px 10px 5px; letter-spacing:0.5px; }
	span.dist-button { padding:5px; background-color:#FFF; border: 1px solid #9bc2e6; color: #1E4DD3; font-weight: bold; }
	span.dist-button:nth-child(2) {	border-radius: 3px 0 0 3px;}
	span.dist-button:last-child { border-radius: 0 3px 3px 0; }
	span.dist-button { border-radius: 3px; }
	span.dist-button:hover { background-color: #9bc2e6; color: #343540; text-decoration: none; }
	span.dist-button.btn-selected { background-color: #9bc2e6; color: #343540; text-decoration: none; }
</style>

<cfscript>
	qPlannerCustomerTypes = plannerTemplateManager.getPlannerTemplateCustomerTypes( id=form.template_id );
</cfscript>

	<cfset jQueryUI.widgets = "tooltip">
	<cf_include files="/common_files/datatable2.css, /common_files/dataTables2.cfm, /common_files/dhx_message.cfm">

<form id="select_customers" method="post">
	<cfset saveHiddenValues()>

	<div class="dist-btn-group">
		<span class=SectionHeader> View : </span>
        <!--- look for customized customer types for this planner template - Butter Ball custom request --->
        <cfoutput><cfset planner_template_customer_types = application.util.query.get_setting("planner_template_#trim(form.template_id)#_customer_types", 0)></cfoutput>

        <!--- default standard handling --->
        <cfif planner_template_customer_types eq ''>
            <cfoutput query="qPlannerCustomerTypes">
                <span class="dist-button" grpID="#qPlannerCustomerTypes.distributor_group_level_id#" pg="#qPlannerCustomerTypes.is_pg#"> #qPlannerCustomerTypes.group_level_desc# </span>
            </cfoutput>
        <cfelse>
            <!--- custom handling for Butter Ball to support custom order, custom types --->
            <cfloop list="#planner_template_customer_types#" item="customer_type">
                <cfquery name="qCustomerType" dbtype="query">
                    SELECT *
                      FROM qPlannerCustomerTypes
                     WHERE group_level_desc = '#trim(customer_type)#'
                </cfquery>

                <cfif qCustomerType.recordCount>
                    <cfoutput>
                        <span class="dist-button" grpID="#qCustomerType.distributor_group_level_id#" pg="#qCustomerType.is_pg#"> #qCustomerType.group_level_desc# </span>
                    </cfoutput>
                </cfif>
            </cfloop>
        </cfif>
	</div>

	<table class="dataTable row-border order-column hover datagrid" id="customers" width="100%">
		<col width="5%">
		<col width="20%">
		<col width="15%">
		<col width="60%">
		<thead>
			<tr>
				<!-- 1 --> <th style="text-align:left;cursor:pointer;"><input type="checkbox" id="checkall"></th>
				<!-- 2 --> <th style="text-align:left"><cfoutput>Name</cfoutput></th>
				<!-- 3 --> <th style="text-align:left"><cfoutput>ID</cfoutput></th>
				<!-- 4 --> <th style="text-align:left"><cfoutput>Address</cfoutput></th>
			</tr>
		</thead>
		<!--- data inserted here by data grid below --->
		<tbody> </tbody>
	</table>

	<cfoutput>
	<div style="clear:both;"></div>

	<cfset actions = "">
	<cfsavecontent variable="actions"><a href='##' id='choose'>#application.util.string.linkFormat("create #Application.PlannerLabel#")#</a></cfsavecontent>
	</cfoutput>

	<script>

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
		$("span[grpID]").click(function (){
			var groupLevelId = $(this).attr("grpID");
			var isPG = $(this).attr("pg");


			$("span.dist-button").removeClass('btn-selected');
			$(this).addClass('btn-selected');
			if (groupLevelId > 0){
				$("#checkall").prop("disabled", "true" ).css("display","none");
			}else{
				$("#checkall").removeAttr("disabled").css("display","block");
			}

			// remove existing table
			if ( $.fn.dataTable.isDataTable('#customers') ) {data_table.clear().draw().destroy();}

			$.getJSON( '/mvc/Models/Planner/PlannerTemplateManager.cfc',
				{
					method:"getPlannerTemplateCustomers",
					returnFormat:"json",
					"id"           : $('input[name=template_id]').val(),
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
						scrollY: (window.innerHeight > 768 ? "67vh" : "58vh"),
						"sDom": 'f<"actions">ti',
						columnDefs: [
							{targets:0, visible:true, sortable:false, className:"left",
								render: function ( data, type, row ){
									if (groupLevelId > 0){
										return  ("<input name='grp' type='radio' class='hand'" + " value='" + row[0] + "'>");
									}else{
										return  ("<input type='checkbox' class='hand'" + " value='" + row[0] + "'>");
									}
								} },
							{targets:1, title:"Name", visible:true, className:"left", render: function ( data, type, row ) { return row[2]} },
							{targets:2, title:"ID", visible:true, className:"left", render: function ( data, type, row ) { return row[1]} },
							{targets:3, title:"Address", visible:true, className:"left", render: address_format},
							{targets:'_all', visible:false}
						]
					}); // DataTable

					$("div.actions").html( <cfoutput>"#actions#"</cfoutput> );
					$("*[title]").tooltip();

					$("#choose").click(function() {
						var selected = [];
						data_table.$("input.hand:checked").each(function() {
							selected.push( $(this).val() );
						});
						if ( selected.length == 0 ) {
							dhtmlx.message({
											text: 	"select a <cfoutput>#planner_labels.distributor_singular#</cfoutput>",
											expire: 2000
										});
						}else{
							$("input[name=distributor_list]").val( selected.join(",") );
							$("input[name=group_level_id]").val( groupLevelId );
							$("#select_customers").submit();
						}
					});
				} // success
			); // $.getJSON
		}); // span[grpID].click

		address_format = function(data, type, row) {
			return (row[3] + "  " + row[5] + "  " + row[6] + "  " + row[8]);
		}

		// set the first distributor type as clicked
		$("span.dist-button").first() .trigger("click");

	</script>

</form>
