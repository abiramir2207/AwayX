<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/Upload_Automation/Automation_Upload_Statusboard.cfm
Copyright    :  (c) 2020 Blacksmith Applications, Inc.
Created Date :  20-Jun-20
Created By   :  Anand Rao
Description  :  StatusBoard for the Upload Automation
---------------------------------------------------------------------------------->

 
 <cfset URL.PageTitle="OCR Upload Status Board ">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
 
<link rel="stylesheet" type="text/css" href="/styles/tool-button.css">

<cfsilent>
<cfparam name="PageTitle" default="">
</cfsilent>

<style type="text/css" class="init">
	td.details-control {
    	background: url('/images/ocr/arrowdown24.png') no-repeat center center;
    	cursor: pointer;
	}
	tr.shown td.details-control {
	    background: url('/images/ocr/arroright24.png') no-repeat center center;
	}
</style>
 
<link rel="stylesheet" type="text/css" href="/Common_Files/datatable-ocr.css">
<cfif isDefined("qGetAutoUploadStatus") AND qGetAutoUploadStatus.recordcount GTE  1>
<cfoutput>
<cfinclude template = "UA_Steps.cfm" />
</cfoutput>
</cfif>
<table class="datagrid" cellspacing="0" cellpadding="0">
	<thead>
    	<!--- <th class="header"><b>ID</b></th> --->
	    <th class="header"><b>File Name</b></th>
		<th class="header"><b>Created by</b></th>
		<th class="header"><b>Date</b></th>
		<th class="header"><b>Size</b></th>	
		<th class="header" width="150"><b>Action</b></th>	
	</thead>
  	<tbody>

	</tbody>
</table> 

<script>
var $refreshButton =  $('<div align="right">'+ 
	
	'<a class="tool-button" href="index.cfm?refreshScreen=1" id="refreshButton" title="Refresh page"><img src="/images/ocr/refresh-24-c406be4.png"  width="22" height="22" border="0"></a>'+
	'<div id="divFilter" class="divFilter"><div class="dShowall" id="dShowall"><table border="0"><tr><td width="25" height="25"><img src="/images/ocr/_thumb_12423.png" class="imgAll" width="20" height="20"></td><td>Show All</td></tr></table></div>'+
	'<div class="dShowFiltered" id="dShowFiltered" style="border-top:2px solid #ebebeb;width:100%;"><table border="0"><tr><td width="25" height="25"><img src="/images/ocr/_thumb_12423.png"  class="imgFiltered"  width="20" height="20"></td><td>Show invoices that require action</td></tr></table></div></div></div>');
var windowHeight = $(window).height(), sScrollY = 30; // ( windowHeight > 200 ? .71 : .55) * windowHeight;
oTable = $('.datagrid').dataTable( {
      "bServerSide": true
    , "bProcessing": true
    , "bSortClasses": false
	, "bAutoWidth": false
    , "iDisplayLength": 1
	 , "oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" },
                       "sLengthMenu": 'Display <select>'+
						        '<option value="1" selected>1</option>'+
						        '</select> records'
					} 
    , "sAjaxSource": "/billbacks/Upload_Automation/ajax/automation_upload_statusboard_ajax.cfm?LockMode=<cfoutput>#variables.inEditMode#</cfoutput>"
    //, "sPaginationType": "full_numbers"
  	, "sScrollY": sScrollY 
    , "sDom": '<"H"r><"toolbar">t'//  removed this <"F"ipl>  -- 'Tfrtip'       // was "fprti" // , "sDom": '<"H"fr><"toolbar">t<"F"ipl>'//'Tfrtip'
    , "bJQueryUI": false
    ,"bDeferRender": true
    ,"sLengthMenu": [ 1 ]
    , "aaSorting": []
    , "aoColumns": [  		{"bSearchable": true,  	"bSortable":true}
	                  /*  ,	{"bSearchable": true, 	"bSortable":true} */
	                    ,	{"bSearchable": true, 	"bSortable":true}
						,	{"bSearchable": false, 	"bSortable":true}
						,	{"bSearchable": false, 	"bSortable":false}							// no sort on the Action column
						,	{"bSearchable": false, 	"bSortable":false}
						// , 	{"bSearchable": true, 	"bSortable":true, "bVisible":false}			// hide the Step column
	                 ]
	,"fnInitComplete": function(oSettings, json) {
      //$('.dataTables_filter').append($refreshButton);
      $("div.toolbar").html($refreshButton);
      $("#refreshButton").click(function() {
			oTable.fnDraw();
		});

/* TODO: close the div if user clicks anywhere else on the page */
		$( "document.body" ).click(function(){
			var isImgClicked = 0;
			
		/* $( "#imgFilter" ).click(function() {
     			isImgClicked = 1;
			}); */
			if ($(e.target).parent().hasClass('divFilter')) {
				isImgClicked = 1;
			}
		
		  if ( $( "#divFilter" ).is( ":visible" ) && isImgClicked == 0) {
		    $( "#divFilter" ).slideUp( "fast" );
		  } else {
		  // do nothing
		  }  
		});
		
		$( "#dShowall" ).click(function () {
				$('.imgFiltered').hide();
				$('.imgAll').show();
				oTable.fnFilterClear();
				$( "#divFilter" ).slideUp( "fast" );				
			});
			$( "#dShowFiltered" ).click(function () {
				$('.imgAll').hide();
				$('.imgFiltered').show();
				oTable.fnFilter("'2.CF_Error','2.DB_Error','4.DB_Error','6','6.DB_Error','10','7','9','9.DB_Error'",8);
				oTable.fnDraw();
				$( "#divFilter" ).slideUp( "fast" );
			});
		
		
		// $( "#imgFilter" ).click(function () {
		 $( '.aImgFilter' ).click(function () {
// 		alert('in function');
			$("#divFilter").css( {position:"absolute", top:event.pageY-75, left: event.pageX-175});
		   if ( $( "#divFilter" ).is( ":hidden" ) ) {
		    $( "#divFilter" ).slideDown( "fast" );
		  } else {
		    // $( "div" ).hide();
			$( "#divFilter" ).slideUp( "fast" );
		  } 
		}); 
    }
} ).fnSetFilteringDelay();


/********** Auto refresh interval set to 15 secs **********/ 
/*
setInterval (function test() 
	{
		oTable.fnDraw();
	}, 30000);
*/	
 
</script>
<!--- END : Jquery DATATABLE STYLE --->
 