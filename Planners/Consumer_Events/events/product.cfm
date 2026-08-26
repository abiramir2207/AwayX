<!------------------------------------------------------------------------------------------------------------------------------
	   File Name:  \planners\consumer_events\events\product.cfm
	Created Date:  2017 October
	  Created By:  Tim
	 Description:  Add/edit a consumer event
------------------------------------------------------------------------------------------------------------------------------->


<cfscript>
	param name="url.rowid"                  default="";
	param name="form.action"                default="";
	param name="form.groupLevelId"          default="";
	
	if (! structKeyExists(request, "planner_event_obj")) {
		request.planner_event_obj = createObject("component", "mvc.models.planner.plannereventmanager");
	}
	if (! structKeyExists(request, "rowid")) {
		request.rowid = url.rowid;
	}

	if (form.action eq "save") {
		request.planner_event_obj.saveEventProducts(request.rowid, form);
	
		request.qEventsList = request.planner_event_obj.getEvents( request.rowid );
		include "/planners/consumer_events/events/planner_event_navigation.cfm";
		locateToNextPage(currentPageName = constants.page.name_product, rowid = request.rowid);
	}

	if (! structKeyExists(form, "Product_List")) {
		// Get the saved values from DB
		
		// Get saved individual products and set form variable
		qPlannerEventProducts = request.planner_event_obj.getPlannerEventProductList(request.rowid, 0);
		form.Product_List = ValueList(qPlannerEventProducts.Product_GUID);

		// Get saved group products and set form variable	
		qPlannerEventProducts = request.planner_event_obj.getPlannerEventProductList(request.rowid, 1);
		form.SelectedGroupProducts = ValueList(qPlannerEventProducts.Product_GUID);	
		form.groupLevelId = qPlannerEventProducts.Product_Group_Level_ID;
	
	}
	
	// Get display details for the selected products
	qEventProducts = request.planner_event_obj.getProductsFromList( ListAppend(form.Product_List, form.SelectedGroupProducts) );
	labels_obj = createObject("component", "components.settings.Labels.Labels").init();
	qPlannerLabels = labels_obj.plannerLabels();
	
	// Product group levels
	GroupManager = CreateObject("component", "components.products.Group.ProductGroupAttributeManager");
	qGetProductGroupLevels			= GroupManager.getProductGroupAttributes(active=1, includePG=0);
</cfscript>


<cf_layout_planner_event>

<cf_include files="/styles/css-loader.css, /common_files/dhx_message.cfm, /common_files/datatable2.css, /common_files/dataTables2.cfm, /common_files/dhx_message.cfm">

<cfset jQueryUI.widgets = "tooltip,datepicker">
<cfinclude template="/common_files/jQueryUI.cfm">


<style>
	body { min-width: 0; }
	fieldset.base { min-height: 650px; height: 65vh; }
	div.actions a { margin-right: 20px; }
	div.actions { display:inline-block; margin: 0px 25px 10px 25px ; position:relative; top:-2px; }
	label.lb { font-size:12px; width:100px; float:left;}
	div.dataTables_filter input { width: 200px; }
	.cut { background-color:#E5E5E5 !important; text-decoration: line-through; }
	.undo {display: none; width: 50px}
	.del {width: 50px}
</style>


<cfoutput>
	<cfsavecontent variable="action_links">
		<select id=chooseGroupLevelId><option value=0>choose product group level</option>
			<cfloop query="qGetProductGroupLevels"><option value=#Product_Group_Level_ID# <cfif form.groupLevelId eq Product_Group_Level_ID>selected</cfif>>#Group_Level_Desc#</option></cfloop>
		</select>
		<a class=primary  id=product_group>#application.util.string.linkFormat(  "select product group"  )#</a>
		<a class=primary id=product>#application.util.string.linkFormat( "select products" )#</a>
		<a class=primary id=save>#application.util.string.linkFormat( "save" )#</a>
		<a class=secondary id=cancel>#application.util.string.linkFormat( "return to event list" )#</a>
	</cfsavecontent>
</cfoutput>

<cfoutput>
	<form name="event_products" method="post">
		<input name="action"				type="hidden" />
		<input name="groupLevelId"			type="hidden" value="#form.groupLevelId#">
		<input name="SelectedGroupProducts"	type="hidden" value="#form.SelectedGroupProducts#">
		<input name="Product_List" 			type="hidden" value="#Form.Product_List#">
		<input name="ExistingProductList" 	type="hidden" value="#Form.Product_List#">
	

		<fieldset class="base">
			<table class="dataTable row-border order-column hover" id="grid">
				<thead>
					<th class="dt-head-left"></th> <!--- scissors --->
					<th class="dt-head-left"></th> <!--- undo --->
					<th class="dt-head-left">ID</th>
					<th class="dt-head-left">Description</th>
					<th class="dt-head-left">Type</th>
					<th class="dt-head-left">Level</th>
				</thead>
				<tbody></tbody>
			</table>
		</fieldset>
	</form>
	
	<form name="add_groups" method="post" action="/Planners/Templates/ProductGroup_Search.cfm" onsubmit="popup_form(this, 'add_groups')">
		<input type="hidden" name="product_group_level_id" value="">
		<input type="hidden" name="parent_call_back" value="">
		<input type="hidden" name="selection_input_name" value="filter_product_list">
		<input type="hidden" name="filter_product_list" value="">
	</form>
	
</cfoutput>
<cfset data_set = []>
<cfoutput query="qEventProducts">
	<cfset arrayAppend(data_set, [	qEventProducts.Product_GUID
									,qEventProducts.Product_GUID
									,qEventProducts.Product
									,qEventProducts.Product_Name
									,qEventProducts.Record_Type
									,qEventProducts.Product_Group_Level_ID
									])>
</cfoutput>

<cfoutput>
	<cfsavecontent variable="no_data">No data.</cfsavecontent>
</cfoutput>

<script>
	// console.clear();
	cut_format = function(row) {
		return  "<img src='/images/scissor.gif' name='scissor' id='" + row[0] + "'  class='hand' value='" + row[0] + "'>";
	}
	
	undo_format = function(row) {
		return  "<img src='/images/undo.gif' name='undo' id='" + row[0] + "'  class='hand' value='" + row[0] + "'>";
	}

	var table = $("table.dataTable").DataTable({
		data   : <cfoutput>#serializeJSON( data_set )#</cfoutput>,
		dom    : 'f<"actions">ti',
		columns: [
					{ visible:true, className: "hand del", orderable: false, render: function(data, type, row){return cut_format(row); } },
					{ visible:true, className: "hand undo", orderable: false, render: function(data, type, row){return undo_format(row); } },
					{},
					{},
					{},
					{visible:false}
				],
		language: { emptyTable: <cfoutput>"#no_data#"</cfoutput> },
		order  : [ [2, 'asc'] ],
		scrollY: "60vh",
		paging : false
	});
	$("div.actions").html( <cfoutput>"#application.util.string.compress(action_links)#"</cfoutput> );

	// product group search
	$("a#product_group").click(function(){ selectproductGroups(); });

	// product search
	$("a#product").click(function(){ selectProducts(); });

	$("a#cancel").click(function(){ window.location = "list.cfm"; });

	$("a#save").click(function(){
		$("input[name=action]").val( "save" );
		$("form[name=event_products]").submit();
	});

	function callback_save_filter() {
  		var new_products = $("input[name=filter_product_list]").val();
        $("input[name=SelectedGroupProducts]").val( new_products );
		$("input[name=groupLevelId]").val($("form[name=add_groups] input[name=product_group_level_id]").val());
        $("form[name=event_products]").submit();
	}
	

	selectproductGroups  = function()
	{
		var lsValsToDel = "";
		var sURL = "";
		
		var GroupLevelID = $("#chooseGroupLevelId option:selected" ).val();
		if(GroupLevelID == "0") {
		
			
			dhtmlx.alert({
				title: "Error",
				type: "alert-error",
				<cfoutput>
				text: "Choose a product group level",
				</cfoutput>
				width: "500px",
				callback:function(response){
					if(response){
						$("#chooseGroupLevelId" ).focus();
					} // if(response)
				} // callback function
			}); // dhtmlx.confirm
			
			return;
		}
		
		// Submit the form so we can pass already selected product groups to the pop-up
		$("form[name=add_groups] input[name=product_group_level_id]").val( GroupLevelID );
		$("form[name=add_groups] input[name=parent_call_back]").val( "callback_save_filter()" );
		$("form[name=add_groups] input[name=filter_product_list]").val(  $("input[name=SelectedGroupProducts]").val() );
        $("form[name=add_groups]").submit();
		
	}

	selectProducts  = function()
	{
		var actionFrm = document.event_products;
		var lsValsToDel = "";
		var sURL = "";
		sURL = "/Common_Files/contracts/product_Select_V1.cfm?Formname=event_products";
		NewWindow(sURL, 'Select Products', 1000, 800, 'yes', 'yes');
	}
	
	$('#grid tbody').on('click', 'td.del', function () {
		var selected_row = $( this ).parents( "tr" );
		var data = table.row(selected_row).data();
		var recordId = data[0];
		var recordLevelId = data[5];
		var listObj;
		
		// Remove recordId from the list
		if(recordLevelId == "0"){
			listObj = $('input[name=Product_List]');
		}
		else {
			listObj = $('input[name=SelectedGroupProducts]');
		}
		var recordList = listObj.val();
		var recordList = removeFromList(recordList, recordId);
		listObj.val(recordList); // set the new value back into the input
		
		if(recordLevelId == "0"){
			$('input[name=ExistingProductList]').val(recordList);
		}
		
		// Change the table style
		selected_row.addClass('cut');
		selected_row.find('td:nth-child(1)').hide(); // hide scissor column #1
		selected_row.find('td:nth-child(2)').show(); // show undo column #2
		
		
    } );
	
	
	$('#grid tbody').on('click', 'td.undo', function () {
		var selected_row = $( this ).parents( "tr" );
		var data = table.row(selected_row).data();
		var recordId = data[0];
		var recordLevelId = data[5];
		var listObj;
		
		// Remove recordId from the list
		if(recordLevelId == "0"){
			listObj = $('input[name=Product_List]');
		}
		else {
			listObj = $('input[name=SelectedGroupProducts]');
		}
		var recordList = listObj.val();
		var recordList = addToList(recordList, recordId);
		listObj.val(recordList); // set the new value back into the input
		
		if(recordLevelId == "0"){
			$('input[name=ExistingProductList]').val(recordList);
		}
		
		// Change the table style
		selected_row.removeClass('cut');
		selected_row.find('td:nth-child(1)').show(); // show scissor column #1
		selected_row.find('td:nth-child(2)').hide(); // hide undo column #2
		
		
    } );

	
	function removeFromList(sList, itemToRemove){
		var items = sList.split(',');
		var index = items.indexOf(itemToRemove);
		if(index!==-1) {
			items.splice(index, 1);			
		}
		return items.join(',');
	}
	
	function addToList(sList, itemToAdd){
		var items = sList.split(',');
		items.push(itemToAdd);	
		return items.join(',');
	}

</script>

</cf_layout_planner_event>