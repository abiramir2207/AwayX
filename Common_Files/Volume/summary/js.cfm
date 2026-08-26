<!---------------------------------------------------------------------------------------------------------------------
      Template: \common_files\volume\summary\js.cfm
      Date:     Nov 1 2012
      Author:   Chris Nguyen
      Purpose:  Common JavaScript code for volume forecast summaries
----------------------------------------------------------------------------------------------------------------------->
<cfsavecontent variable="moreCss">
  <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
  <link rel="stylesheet" type="text/css" href="/common_files/tableTools.css">
	<link rel="stylesheet" href="/styles/jQueryUI_18/jquery.multiselect.css" type="text/css" />
	<link rel="stylesheet" href="/styles/jQueryUI_18/jquery-ui-1.8.10.custom.css" type="text/css" />
  <style>
   .act111 {font-weight:bold; font-size:1em; margin:5px 0 0 0; color:green; text-align:center;}
   .clear {clear:both;}
   .csv {float:right;}
   #classSegment { float:left; margin-bottom:10px; }
  </style>
</cfsavecontent>
<cfhtmlhead text="#moreCss#">

<cfquery name="actual" Datasource="#application.datasource#">
	SELECT  MIN( vfp.Start_Date ) AS start_date
	       ,MAX( vfp.End_Date )   AS end_date
	  FROM dbo.VF_PLAN
	       INNER JOIN VF_CLASS ON VF_CLASS.vf_Class_Id = VF_PLAN.vf_Plan_Class_Id
	                              AND VF_CLASS.Deleted = 0
	                              AND VF_CLASS.Active = 1
	                              AND GetDate( ) BETWEEN VF_CLASS.Start_Date AND VF_CLASS.End_Date -- current class only
	       INNER JOIN VF_PERIOD vfp ON vfp.vf_Class_Id = VF_CLASS.vf_Class_Id
	                                   AND GetDate( ) > vfp.End_Date
</cfquery>

<form action="/common_files/csv.cfm" method ="post" id="csv_form">
  <input type="hidden" name="csv_text" id="csv_text">
  <input type="hidden" name="csv_file_name" id="csv_file_name">
</form>

<cfparam name="jQueryui.version" default="1.8.23">
<cfinclude template="/common_files/jQuery.cfm">

<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">

<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js?foo"></script>
<script type="text/javascript" src="/Script/javascript/table2csv.js?foo"></script>
<script type="text/javascript" src="/Script/javascript/jQueryUI_18/jquery.multiselect.min.js"></script>

<script type="text/javascript">
var windowHeight = $(window).height(), headerHeight = 211, sScrollY = windowHeight - headerHeight;
// adjust column headings & font size to fit small screen
if ($(window).width() < 1400) {
  $("th, td").css("font-size", "0.85em");
}
$(function() {
  var oTable = $('#vfsummary').dataTable({
       "aaSorting": []
      ,"aoColumns": [  null
                          // insert 2 columns when it is not a planning group summary
                          <cfif not cgi.script_name contains "/pg.cfm">
                        ,null
                        ,null
                          </cfif>
                      ,{ "sType": "dollar", "bSearchable":false }
               ,{ "sType": "dollar", "bSearchable":false }
                      ,{ "sType": "dollar", "bSearchable":false }

                      ,{ "sType": "dollar", "bSearchable":false }
                      ,{ "sType": "dollar", "bSearchable":false }
                      ,{ "sType": "dollar", "bSearchable":false }

                      ,{ "sType": "dollar", "bSearchable":false }
                      ,{ "sType": "dollar", "bSearchable":false }
                      ,{ "sType": "dollar", "bSearchable":false }
                    ]
      ,"bAutoWidth": false
      ,"bPaginate": true
      ,"bScrollCollapse": true
      ,"bSortClasses": false
      ,"fnDrawCallback": function( oSettings ) {
          // hide total row when filtering is not empty
          if ( $('#vfsummary_filter input').val() )
            $('tfoot').fadeOut();
          else
            $('tfoot').fadeIn();
        }
 			,"iDisplayLength": 500
      ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" }
                       ,"sSearch": "Filter entries:&nbsp;&nbsp;"      }
      ,"sDom": <cfif qDetail.recordCount gt 500>'fp<"act111">tip'<cfelse>'f<"act111">ti'</cfif> // do not display pagination icons when # of records is less than 500
      ,"sScrollY": sScrollY
    })
    .fnSetFilteringDelay()
    ;
 <cfif qDetail.recordCount>
  <cfoutput>$('div.act111').text('Actual values include all activities from #dateFormat(Actual.Start_Date,"mmm d, yyyy")# to #dateFormat(Actual.End_Date,"mmm d, yyyy")#');</cfoutput>
 </cfif>

	getCSVData = function() {
	 var csv_value=$('#vfsummary').table2CSV();
	 $("#csv_text").val(csv_value);
	 $("#csv_file_name").val( $('title').text() + ' ' + $.datepicker.formatDate('mm-dd-yy', new Date()) + '.csv' );
	 $("#csv_form").submit();
	}

	<!----------------------------------------------Events for refresh button-------------------------------------------------->
	$('#refresh').click(function() {
		// when segments drop-down exists users are required to make a selection
		if ( $('#bySegmentID').length && $('#bySegmentID').val() == null ) {
			alert( "You forgot to select a " + "<cfoutput>#lcase(application.appSettingsGet.getbusiness_segment_label())#</cfoutput>" + ".\nPlease make corrections and try again." ) ;
			return false;
		}
		$(this).unbind('click').text('One moment...');
		$('div.dataTables_wrapper, div#layoutFoot').hide();
		window.location = <cfoutput>'#cgi.script_name#'</cfoutput>
		       + '?byClassIDs=' + $('#byClassIDs').val()
		       + '&bySegmentID=' + $('#bySegmentID').val();
	});

	<!----------------------------------------------Events for year & position------------------------------------------------->
	$('#byClassIDs, #bySegmentID').change( function() {
		$('#refresh').css("visibility","visible");
	});

	$("#bySegmentID").multiselect( { selectedList: "2" } );
  setTimeout(function(){ oTable.fnAdjustColumnSizing(); }, 10);   // adjust column header widths

  $(window).resize(function() {
      var NewHeight = $(window).height() - headerHeight;
      var oSettings = oTable.fnSettings();
      oSettings.oScroll.sY = NewHeight + "px";
      oTable.fnDraw();
  } );

});
</script>
