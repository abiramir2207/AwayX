<!------------------------------------------------------------------------------------------------------------------------------
	   File Name:  \planners\consumer_events\events\summary.cfm
	Created Date:  2017 November
	  Created By:  Chris Nguyen
	 Description:  Display event summary
------------------------------------------------------------------------------------------------------------------------------->
<cfscript>	
	param name="url.rowid" default="";
</cfscript>

<cf_layout_planner_event>
<style>
	section.base {
		margin: 10px 0.5% 15px;
		padding: 0;
		width: 49%;
	}
	section.full {
		margin: 0;
		margin-bottom: 10px !important;
		padding: 0;
		text-align: center;
		width: 99%;
	}
	label.base {
		color: #666;
		display: inline-block;
		font-weight: 600;
	}
	label.base:after {
		content: " ";
	}
	input.base {
		border: none;
		color: #333;
		font-weight: 600;
		margin-left: 3px;
		margin-right: 25px;	
		padding: 5px;
	}
	input.date {
		width: 80px;
	}
	input.long {
		width: 200px;
	}
	input.medium {
		width: 100px;
	}
	input.short {
		width: 50px;
	}
	header {
		margin-left: 15px;
	}
	div.return { 
		display: inline-block; 
		font-size: 11px; 
		margin-left: 25px; 
		position: relative; 
		top: -2px; 
	}
</style>

<cf_include files="/styles/css-loader.css, /common_files/dhx_message.cfm, /common_files/datatable2.css, /common_files/dataTables2.cfm">
<cfset jQueryUI.widgets = "tooltip">
<cfinclude template="/common_files/jQueryUI.cfm">

<cfoutput>
	<section class="full">
			<label class="base">Event Type</label> <input type=text disabled value="#request.qEventsList.title#" class="base medium">
			<label class="base">Event Title</label> <input type=text disabled value="#request.qEventsList.event_title#" class="base long">
			<label class="base">Fiscal Year</label> <input type=text disabled value="#request.qEventsList.fiscal_year#" class="base short">
			<label class="base">Discount</label> <input type=text disabled value="#request.qEventsList.discount_info#" class="base medium">
			<label class="base">Event Dates</label> <input type=text disabled value="#application.util.datetime.DateSpanFormat(request.qEventsList.event_start, request.qEventsList.event_end)#" class="base medium">
			<div style="font-size:12px;">
				<a class=return>#application.util.string.linkFormat("return to events list")#</a>
			</div>
	</section>
	<div style="clear:both;"></div>
	<hr class="two">

	<!---------------->
	<!--- position --->
	<!---------------->
	<cfset positions_json = serializeJSON( [] )>
	<cfif request.qEventsList.position eq 1>
		<section class="base">
			<table class="dataTable row-border order-column hover position">
				<thead>
					<th class="dt-head-left">Position ID</th>
					<th class="dt-head-left">Description</th>
					<th class="dt-head-left">Level</th>
				</thead>
				<tbody></tbody>
			</table>
			<cfset qData = request.planner_event_obj.getPlannerEventPositions( url.rowid )>
			<cfset data_set = []>
			<cfloop query="qData">
				<cfset arrayAppend(data_set, [	qData.Position_ID
												,qData.Position_Type_Desc
												,qData.Position_Type_Desc
											])>
			</cfloop>
			<cfset positions_json = ( arrayLen(data_set) ? serializeJSON( data_set ) : "" )>
		</section>		
	</cfif>

	<!------------------->
	<!--- distributor --->
	<!------------------->
	<cfset distributors_json = serializeJSON( [] )>
	<cfif request.qEventsList.customer eq 1>
		<section class="base">
			<table class="dataTable row-border order-column hover distributor">
				<thead>
					<th class="dt-head-left">#request.planner_labels.distributor_singular# ID</th>
					<th class="dt-head-left">Description</th>
					<th class="dt-head-left">Type</th>
				</thead>
				<tbody></tbody>
			</table>
			<cfset qData = request.planner_event_obj.getPlannerEventDistributors( url.rowid )>
			<cfset data_set = []>
			<cfloop query="qData">
				<cfset arrayAppend(data_set, [	qData.Distributor
												,qData.Distributor_Name
												,qData.Record_Type
											])>
			</cfloop>
			<cfset distributors_json = ( arrayLen(data_set) ? serializeJSON( data_set ) : "" )>
		</section>
	</cfif>

	<!--------------->
	<!--- product --->
	<!--------------->
	<cfset products_json = serializeJSON( [] )>
	<cfif request.qEventsList.product eq 1>
		<section class="base">
			<table class="dataTable row-border order-column hover product">
				<thead>
					<th class="dt-head-left">Product ID</th>
					<th class="dt-head-left">Description</th>
					<th class="dt-head-left">Type</th>
				</thead>
				<tbody></tbody>
			</table>
			<cfset qData = request.planner_event_obj.getPlannerEventProducts( url.rowid )>
			<cfset data_set = []>
			<cfloop query="qData">
				<cfset arrayAppend(data_set, [	qData.Product
												,qData.Product_Name
												,qData.Record_Type
											])>
			</cfloop>
			<cfset products_json = ( arrayLen(data_set) ? serializeJSON( data_set ) : "" )>
		</section>
	</cfif>

	<!---------------->
	<!--- document --->
	<!---------------->
	<cfset documents_json = serializeJSON( [] )>
	<cfif request.qEventsList.document eq 1>
		<section class="base">
			<table class="dataTable row-border order-column hover document">
				<thead>
					<th class="dt-head-left">Uploaded Date</th>
					<th class="dt-head-left">Uploaded By</th>
					<th class="dt-head-left">File Name</th>
					<th class="dt-head-left">File Size</th>
				</thead>
				<tbody></tbody>
			</table>
			<cfset qData = request.planner_event_obj.getDocuments( url.rowid )>
			<cfset data_set = []>
			<cfloop query="qData">
				<cfset arrayAppend(data_set, [	 application.util.dateTime.DateTimeFormat( qData.Uploaded_date, "mmm d, yyyy" )
												,qData.Uploader
												,qData.Doc_File_Name & "." & qData.Doc_Family
												,numberFormat(qData.Doc_Size, ",9")
											])>
			</cfloop>
			<cfset documents_json = ( arrayLen(data_set) ? serializeJSON( data_set ) : "" )>
		</section>
	</cfif>
</cfoutput>	

<script>
	$("table.position").DataTable({
		<cfif len(positions_json)>
			data: <cfoutput>#positions_json#</cfoutput>,
		</cfif>
		columns: [
					{},
					{},
					{}
					],
		dom    : "fti",
		language: { search:"Search Position:", emptyTable:"There is no position yet.", info:"Showing _START_ to _END_ of _TOTAL_ positions" },
		order  : [ ],
		paging : false
	});

	$("table.distributor").DataTable({
		<cfif len(distributors_json)>
			data: <cfoutput>#distributors_json#</cfoutput>,
		</cfif>
		dom    : "fti",
		language: <cfoutput>{ search: "Search #request.planner_labels.distributor_singular#:", emptyTable: "There is no #request.planner_labels.distributor_singular# yet.", info:"Showing _START_ to _END_ of _TOTAL_ #lcase(request.planner_labels.distributor_plural)#"  }</cfoutput>,
		order  : [ ],
		paging : false
	});

	$("table.product").DataTable({
		<cfif len(products_json)>
			data: <cfoutput>#products_json#</cfoutput>,
		</cfif>
		dom    : "fti",
		language: { search: "Search Product:", emptyTable: "There is no product yet.", info:"Showing _START_ to _END_ of _TOTAL_ products"  },
		order  : [ ],
		paging : false
	});

	$("table.document").DataTable({
		<cfif len(documents_json)>
			data: <cfoutput>#documents_json#</cfoutput>,
		</cfif>
		dom    : "fti",
		columns: [
					{},
					{},
					{},
					{ className:"dt-body-right" }
					],
		language: { search: "Search Document:", emptyTable: "There is no document yet.", info:"Showing _START_ to _END_ of _TOTAL_ documents"  },
		order  : [ ],
		paging : false
	});

	$("a.return").click(function(){
		window.location = "list.cfm";
	});
</script>
</cf_layout_planner_event>