<!------------------------------------------------------------------------------------------------------------------------------
	   File Name:  \Planners\Consumer_Events\events\geography_list.cfm
	Created Date:  2017 November
	  Created By:  Deepa
	 Description:  Display consumer event position list
------------------------------------------------------------------------------------------------------------------------------->


<cf_include files="/styles/css-loader.css, /common_files/dhx_message.cfm, /common_files/datatable2.css, /common_files/dataTables2.cfm">

<cfset jQueryUI.widgets = "tooltip">
<cfinclude template="/common_files/jQueryUI.cfm">
	
<style>
	fieldset.base { min-height: 78vh; width: 60%; }
	form { margin-left: 20px; }
	div.row { height:30px; width:50%; margin-top:10px; }
	div.actions a { margin-right: 20px; }
	div.actions { display:inline-block; margin: 0px 25px 10px 25px ; position:relative; top:-2px; }
	label.lb { font-size:12px; width:100px; float:left;}
	div.dataTables_filter input { width: 200px; }
	.cut { background-color:#E5E5E5 !important; text-decoration: line-through;}
	.undo {display: none;}
</style>

<cfscript>
	qPlannerEventPositions = request.planner_event_obj.getPositions(form.chosen_position_id);
</cfscript>
	


<cfoutput>
	<cfsavecontent variable="action_links">
		<a class=primary id=positionSearch>#application.util.string.linkFormat( "select position" )#</a>
		<a class=primary id=save>#application.util.string.linkFormat( "save" )#</a>
		<a class=secondary id=cancel>#application.util.string.linkFormat( "return to event list" )#</a>
	</cfsavecontent>
</cfoutput>
	
<cfoutput>
	<form name="event_positions" method="post">
		<input type=hidden name=action>
		<input type=hidden name=rowid value="#form.rowid#">
		<input type=hidden name=chosen_position_id value="#form.chosen_position_id#">

		<fieldset class="base">
			<table class="dataTable row-border order-column hover" id="grid">
				<thead>
					<th class="dt-head-left"></th>
					<th class="dt-head-left"></th>
					<th class="dt-head-left">ID</th>
					<th class="dt-head-left">Description</th>
					<th class="dt-head-left">Type</th>
				</thead>
				<tbody></tbody>
			</table>
		</fieldset>
	</form>
</cfoutput>
<cfset data_set = []>
<cfoutput query="qPlannerEventPositions">
	<cfset arrayAppend(data_set, [	qPlannerEventPositions.User_positions_ID
		   							,qPlannerEventPositions.User_positions_ID
									,qPlannerEventPositions.Position_ID
									,qPlannerEventPositions.Position_Label
									,qPlannerEventPositions.Position_Type_Desc
									])>
</cfoutput>
 
<cfoutput>
	<cfsavecontent variable="no_data">No data.</cfsavecontent>
</cfoutput>

<script>

	var table = $("table.dataTable").DataTable({
		data   : <cfoutput>#serializeJSON( data_set )#</cfoutput>,
		dom    : 'f<"actions">ti',
		columns: [
					{ visible:true, className: "hand del", orderable: false, width: "50px", render: function (cell) {
						return  "<img src='/images/scissor.gif' class='del' rowid='" + cell + "'>"; }},
					{ visible:true, className: "hand undo", orderable: false, width: "50px", render: function (cell) {
						return  "<img src='/images/undo.gif' rowid='" + cell + "'>"; }},
					{},
					{},
					{}
				],
		language: { emptyTable: <cfoutput>"#no_data#"</cfoutput> },
		order  : [ [2, 'asc'] ],
		scrollY: "60vh",
		paging : false
	});
	$("div.actions").html( <cfoutput>"#application.util.string.compress(action_links)#"</cfoutput> );

	$("a#cancel").click(function(){ window.location = "list.cfm"; });

	$("#positionSearch").click( function() {
		$('input[name=action]').val("positionSearch");
		$("form[name=event_positions]").submit();
	});

	$("#save").click( function() {
		$('input[name=action]').val("save");
		$("form[name=event_positions]").submit();
	});

	
	$('#grid tbody').on('click', 'td.del', function () {
		var data = table.row( $(this).parents('tr') ).data();
		var recordId = data[0];
		
		// Remove recordId from the list
		var positionList = $('input[name=chosen_position_id]').val();
		positionList = removeFromList(positionList, recordId);		
		$('input[name=chosen_position_id]').val(positionList);
		
		// Change the table style
		$(this).parents('tr').addClass('cut');
		$(this).parents('tr').find('td:nth-child(1)').hide(); // hide scissor column #1
		$(this).parents('tr').find('td:nth-child(2)').show(); // show undo column #2
		
		
    } );
	
	$('#grid tbody').on('click', 'td.undo', function () {
		var data = table.row( $(this).parents('tr') ).data();
		var recordId = data[0];
		
		// Remove recordId from the list
		var positionList = $('input[name=chosen_position_id]').val();
		positionList = addToList(positionList, recordId);		
		$('input[name=chosen_position_id]').val(positionList);
		
		// Change the table style
		$(this).parents('tr').removeClass('cut');
		$(this).parents('tr').find('td:nth-child(1)').show(); // show scissor column #1
		$(this).parents('tr').find('td:nth-child(2)').hide(); // hide undo column #2
		
		
    } );

	
	function removeFromList(sList, itemToRemove){
		var items = sList.split(',');
		items=items.map(function(str) { return parseInt(str, 10); });
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

