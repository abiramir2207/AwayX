<!----------------------------------------------------------------------------------------------------------------------------------
      Template:  \Planners\Templates\ProductGroup_Search.cfm
       Purpose:  Display products in a group and allow for selection

    Parameters:	1. FORM.product_group_level_id = product group level ID (required)
	 			2. FORM.selection_input_name = name of hidden input where user's selections are saved (required)
	 			3. FORM.parent_call_back = parent window call back function to execute after users make their selection (OPTIONAL)
	 										must specify a pair of brackets "()" at the end
	 										(e.g. "<input type="hidden" name="parent_call_back" value="callback_filter_products()" )

	EXAMPLE:    \AwayX\Planners\Create\planner_volume_plan.cfm:

	<form name="add_groups" method="post" action="/Planners/Templates/ProductGroup_Search.cfm" onsubmit="popup_form(this, 'add_groups')">
		<input type="hidden" name="product_group_level_id" value="#request.defaultProductFilterAttr.product_group_level_id#">
		<input type="hidden" name="selection_input_name" value="product_list">
        <cfset qProducts = plannerManager.getPlannerProducts( request.plannerID, request.defaultProductFilterAttr.product_group_level_id )>
        <input type="hidden" name="product_list" value="#valueList(qProducts.Item_Key)#">
		<input type="hidden" name="parent_call_back" value="callback_add_groups()">
	</form>

	$("#add_groups").click(function() {
		$("form[name=add_groups]").submit();                // send "add_groups" form to popup
	});

	function callback_add_groups() {
		$("input[name=action]").val( "save_products" );
		$("form[name=volume_plan]").submit();               // submit a different form to save
	}
----------------------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<HTML>
<cfoutput>
<cfsilent>
<cfparam name="form.plannerID" default="0">
	<cfscript>
		approvalGroupManager = createObject("component", "components.settings.ApprovalGroupManager").init();
		approvalGroupType    = approvalGroupManager.getGroupTypeInfo( form.product_group_level_id );
        objPlannerTemplateManager = CreateObject("component", "mvc.Models.Planner.PlannerTemplateManager");
	</cfscript>
</cfsilent>
<head>
	<title>Select #approvalgrouptype.label#</title>
  	<cf_include files="/common_files/datatable.css, /styles/css-loader.css">
    <cfinclude template="/common_files/jqueryui_icons.cfm">
      
  	<style>
		##actions { text-align: center; }
		##actions > a { 
  			margin: 0 15px;
  			cursor: pointer;
  		}
  		i.ui-icon { position:relative; top:3px; }
        .create_list { float:left; margin-left: 25px; position: relative; top: -3px; }
    </style>
</head>
<body>
<form name="product_group_search">
<!--- Get the records that match the selected criterria --->
<cfset qProducts = objPlannerTemplateManager.getPlannerProductGroups(form.product_group_level_id, val(form.plannerID)) />

<cfsavecontent variable="uncompressed">
<table cellpadding="2" cellspacing="0" width="100%" class="MainTable datagrid" id="datagrid"  style='table-layout:fixed;'>
  	<col width="5%">
  	<col width="25%">
  	<col width="70%">
	<thead>
    	<tr>
	      	<th><input type="checkbox" name="all_items"></th>
	      	<th>#approvalGroupType.label# ID</th>
	      	<th>#approvalGroupType.label#</th>
	    </tr>
	</thead>
    <tfoot>
    	<tr>
    		<th colspan="3" id="actions">
				<a class="import_some">#application.util.string.linkFormat("import selected record(s)")#</a>
				<a class="import_all">#application.util.string.linkFormat("import all record(s)")#</a>
		    	<a class="remove_some">#application.util.string.linkFormat("remove selected record(s)")#</a>
		    	<a class="close_window">#application.util.string.linkFormat("close window")#</a>
			</th>
   		</tr>
	</tfoot>
	<tbody>
	    <cfloop query="qProducts">
		    <tr>
		    	<td>
		    		<input type="checkbox" value="#qProducts.Group_ID#" <cfif ListFindNoCase(FORM[ form.selection_input_name ], qProducts.Group_ID)>checked</cfif> class="item">
		    	</td>
		      	<td>
		      		<cfif (Len(qProducts.Group_ID) NEQ 36)>
		      			#qProducts.Group_ID#
		      		<cfelse>
		      			#qProducts.Group_Number#
		      		</cfif>
		      	</td>
		      	<td>
					<cfif (FORM.product_group_level_id GTE 2000)>
						<a onclick="fnViewMicroMembers('1', '#qProducts.Group_ID#', '')">#qProducts.Group_Name#</a>
					<cfelse>
			  			#qProducts.Group_Name#
					</cfif>
				</td>
		    </tr>
	    </cfloop>
	 	</tbody>
</table>
</cfsavecontent>
#application.util.string.compress( uncompressed )#
</form>

<!----------------------------------------------------------------------------------------------------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">

<cf_include files="/Script/javascript/jquery.dataTables-api.js, /Script/javascript/FixedHeader.min.js">

<script>
	 function fnViewMicroMembers(PGType, IDtoView, LSMembers) {
	 	popupInCenter("/settings/planning_Groups/dspViewMicroMembers.cfm?Group_ID=" + IDtoView + "&PGType=" + PGType + "&members=" + LSMembers, "view_micro_members", 800, 800);
	 }

	 $("input[name=all_items]").click(function(e){
	 	$("input.item").attr("checked", ($(this).attr("checked") ? true : false) );
	 	e.stopPropagation();
	 });

	 $("input.item").click(function(e){
	 	e.stopPropagation();
	 });

	 function final_action( action ){
        action = action || 'import';
        var items = [];
        /* gather selected items into an array */
        $("input.item:checked", mydatagrid.fnGetNodes()).each(function(){
            items.push( $(this).val() );
        });
        /* update hidden inputs in parent form */
        if (action === "import") {
            $("input[name=#form.selection_input_name#]", opener.document).val( items.join() );
        }
        else if (action === "remove") {
            $("input[name=#form.selection_input_name#]", opener.document).val( items.join() );
            $("input[name=action]", opener.document).val( "remove_products" );
        }
        <cfif structKeyExists(form, "parent_call_back")>
            /* execute a call back in parent window */
            opener.#form.parent_call_back#;
        </cfif>
        window.close();
	 }

	 $("a.remove_some").click(function(){
	 	final_action( "remove" );
	 });

	 $("a.import_all").click(function(){
	 	$("input.item", mydatagrid.fnGetNodes()).attr("checked", true );
	 	final_action();
	 });

	 $("a.import_some").click(function(){
	 	final_action();
	 });

	 $("a.close_window").click(function(){
	 	window.close();
	 });

	var mydatagrid = $('##datagrid').dataTable({
						   "aaSorting": [ [0, "desc"] ]
					      ,"aoColumnDefs": [ { "aTargets":[0], "bSortable":true, "bSearchable":false, "sSortDataType":"dom-checkbox" } ]
					      ,"bAutoWidth": false
					      ,"bPaginate": false
					      ,"bSortClasses": false
					      ,"bScrollCollapse": true
						  ,"bFilter": true
					      ,"sDom": 'f<"create_list">t'
                        }).fnSetFilteringDelay();

    <cfoutput>$('div.create_list').html("<a id='create-list'>#application.util.string.linkFormat('create list')#</a>");</cfoutput>

	 $('tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
	 new FixedHeader( mydatagrid, { "bottom": true } );

	 $('tbody tr').click(function(){
	 	var item = $("input.item", this);
	 	item.attr("checked", (item.attr("checked") ? false : true));
     });

     function import_from_create_list( groups ) {
        // alert( "import_from_create_list\n" + groups );

        var items = [];
        /* gather selected items into an array */
        $("input.item:checked", mydatagrid.fnGetNodes()).each(function(){
            items.push( $(this).val() );
        });
        
        $("input[name=#form.selection_input_name#]", opener.document).val( groups + "," + items.join() );

        <cfif structKeyExists(form, "parent_call_back")>
            /* execute a call back in parent window */
            opener.#form.parent_call_back#;
        </cfif>
        window.close();
     }

     $("##create-list").click(function(){
        popupInCenter("/common_files/createListForm.cfm?passObj=ProductGroup&plannerID=#form.plannerID#&group_level_id=#form.product_group_level_id#&callback=import_from_create_list", "Create List", 400, 375);
     })
</script>
<cfinclude template="/common_files/focus.cfm">
</body>
</html>
</cfoutput>