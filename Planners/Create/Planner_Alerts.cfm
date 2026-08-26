<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
Name         :	Planner_Alerts.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	05/03/2016
Created By   : 	Anand Rao
Description  : 	Planner alert
--------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cf_layout_planner>

<style>
	div.section {
		border-bottom: 1px solid #000080;
		margin: 15px 15px 10px 15px;
		padding-bottom: 3px;
		width: 75%;
	}
		span.title {
			color: #000080;
			font-size: 13px;
			font-weight: bold;
			letter-spacing: 0.5px;
		}
		span.count {
			color: #bf1c36;
			display: inline-block;
			margin: 0 20px 0 10px;
			font-size: 15px;
		}
	div.rfa, div.pending_accept {
		margin: 5px 15px;
		width: 50%;
	}
	div.bottom {
		padding-top: 10px;
	}
</style>
<cfinclude template="topnav_form.cfm">

<cfscript>
	show_programs = application.util.string.linkFormat( "show" );
	hide_programs = application.util.string.linkFormat( "hide" );
	display_list  = arrayToList( [  "Contract_Number",
									"Contract_Title",
									"Contract_Start_Date",
									"Contract_End_Date"
								 ]);

	rfa_programs            = request.components.planner.getPlannerRFAPrograms( form.plannerId );
	pending_accept_programs = request.components.planner.getPlannerPendingAcceptPrograms( form.plannerId );
</cfscript>

<cf_include files="/common_files/dataTables2.cfm, /common_files/dataTable2.css">

<cfoutput>
<div class="section">
	<span class="title">#Application.PlannerPrgLabel_Plural# starting that need approval: </span>
	<span class="count">#rfa_programs.recordCount#</span>
	<a href="##" class="rfa">#hide_programs#</a>
</div>
<div class="rfa">
	<table class="dataTable material row-border order-column hover rfa" width="100%" cellpadding="2">
	    <thead>
	        <tr>
	            <th>#Application.PlannerPrgLabel# Number</th>
	            <th>Title</th>
	            <th>#request.planner_labels.delivery_singular# Start</th>
	            <th>#request.planner_labels.delivery_singular# End</th>
	        </tr>
	    </thead>
	    <tbody>
	    </tbody>
	</table>
</div>

<div class="section bottom">
	<span class="title">#Application.PlannerPrgLabel_Plural# starting that need to be customer accepted: </span>
	<span class="count">#pending_accept_programs.recordCount#</span>
	<a href="##" class="pending_accept">#show_programs#</a>
</div>

<div class="pending_accept">
	<table class="dataTable material row-border order-column hover pending_accept" width="100%" cellpadding="0">
	    <thead>
	        <tr>
	            <th>#Application.PlannerPrgLabel# Number</th>
	            <th>Title</th>
	            <th>#request.planner_labels.delivery_singular# Start</th>
	            <th>#request.planner_labels.delivery_singular# End</th>
	        </tr>
	    </thead>
	    <tbody>
	    </tbody>
	</table>
</div>
</cfoutput>

<script>
	var columnDefs = [  { width: 70  },
                        { width: 200 },
                        { width: 70  },
                        { width: 70  }
                    	];
    $("table.rfa").DataTable({
                                columns       : columnDefs,
                                data          : <cfoutput>#application.util.query.toDtJSON( rfa_programs, display_list )#</cfoutput>,
                                dom           : "fti",
                                order         : [ ],
                                scrollY       : "50vh",
                                scrollX       : true,
                                scrollCollapse: true,
                                paging        : false
                            });

    $("table.pending_accept").DataTable({
                                columns       : columnDefs,
                                data          : <cfoutput>#application.util.query.toDtJSON( pending_accept_programs, display_list )#</cfoutput>,
                                dom           : "fti",
                                order         : [ ],
                                scrollY       : "50vh",
                                scrollX       : true,
                                scrollCollapse: true,
                                paging        : false
                            });

    $("div.pending_accept").hide();
    $("a.rfa, a.pending_accept").click(function(){
		var toggle_link    = $(this)
			,programs_list = $(this).hasClass("rfa") ? $( "div.rfa" ) : $( "div.pending_accept" );
		programs_list.toggle();
		<cfoutput>
		toggle_link.html( programs_list.is( ":visible" ) ? "#hide_programs#" : "#show_programs#" );
		</cfoutput>
    });
</script>
</cf_layout_planner>
