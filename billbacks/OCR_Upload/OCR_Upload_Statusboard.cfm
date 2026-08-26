<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/OCR_Upload_Statusboard.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  28-Feb-17
Created By   :  Anand Rao
Description  :  Upload from home page
---------------------------------------------------------------------------------->


<cfquery name="qGetOCRUploadStatus" datasource="#application.datasource#">
	SELECT 	OUL.OCR_Upload_ID,
			OUL.File_Name,
			OUL.Source_Template,
			OUL.Created_User_ID,
			OUL.OCR_Upload_Date,
			OUL.OCR_Upload_Status,
			OUL.OCR_Step,
			OUL.Deleted,
			OUL.Deleted_By,
			OUL.Deleted_Date,
			OUL.upload_type,
			OUL.File_Extension,
			OUL.File_Size,
			OUL.OCR_Amount,
			OUL.OCR_File_Amount,
			OUL.Reprocess,
			OUL.Reprocess_By,
			OUL.Reprocess_Date,
			OUL.BB_Upload_ID,
			OSL.OCR_Status_Lookup_ID
	FROM 
			OCR_Upload_Log OUL
			LEFT JOIN OCR_Status_Lookup OSL ON OUL.OCR_Step = OSL.OCR_Step 
	WHERE 
			OUL.Deleted = 0		
	ORDER BY
			OUL.OCR_Upload_Date DESC  		
</cfquery>  

<!--- START: Jquery DATATABLE STYLE --->
 
 <cfset URL.PageTitle="OCR Upload Status Board ">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
 
<!--- <CFINCLUDE TEMPLATE="/settings/settings_title.cfm"> --->

<link rel="stylesheet" type="text/css" href="/styles/tool-button.css">

<cfsilent>
<cfparam name="PageTitle" default="">
</cfsilent>

<!---  <table width="100%" cellspacing="0" cellpadding="0" border="0">
	<tr>
		<td align="right" width="95%">
			<!--- <p class="page_title1"><cfoutput>#uCase(PageTitle)#</cfoutput></p> --->
			<div>
				<div style="border:0px solid black;width:600px;float:left;">&nbsp;</div>
				<div style="border:0px solid black;width:750px;vertical-align:middle;float:left;">
			</div>
			<input type="checkbox" class="clsGreenArrow"   id="chkGreenArrow"><strong>Show only invoices that require action to proceed &nbsp;</strong></div>
		</td>

		<td class="no-br" align="center" width="238" valign="top">	
			<div class="tool-btn-group">
				<a class="tool-button" href="" title="filter data"><img src="/images/ocr/_thumb_12424.png"  height="20" border="0"></a><a class="tool-button" href="payablesRedirect.cfm?redirectTo=UPLOAD" title="Go to Upload Payables"><img src="/images/ocr/upload-circle-24-c406be4.png" width="20" height="20" border="0"></a><a class="tool-button" href="##" id="refreshButton" onclick="refreshData();" title="Refresh page"><img src="/images/ocr/refresh-24-c406be4.png"  width="22" height="22" border="0"></a>
   			 </div>	<!--- <img src="/images/ocr/_thumb_12423.png" width="20" height="20" border="0"> --->
		</td>
	</tr>
</table> ---> 

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
<table class="datagrid" cellspacing="0" cellpadding="0">
	<thead>
    	<th class="header"><b>ID</b></th>
	    <th class="header"><b>File Name</b></th>
		<th class="header"><b>Source</b></th>
		<th class="header"><b>Amount</b></th>
		<th class="header" ><b>Days<br>Pending</b></th>
		<th class="header"><b>Created by</b></th>
		<th class="header"><b>Status</b></th><!---  style="text-align:center !important;" --->	
		<th class="header"><b>Action</b></th>	
		<th class="header"><b>Step</b></th>	
	</thead>
  	<tbody>

	</tbody>
</table> 

<script>
var $refreshButton =  $('<div align="right">'+ 
	'<a class="tool-button aImgFilter" title="Filter rows"><img src="/images/ocr/_thumb_12424.png" height="20" border="0" id="imgFilter"></a>'+
	'<a class="tool-button" href="payablesRedirect.cfm?redirectTo=UPLOAD" title="Go to Upload Payables"><img src="/images/ocr/upload-circle-24-c406be4.png" width="20" height="20" border="0"></a>'+
	'<a class="tool-button" href="##" id="refreshButton" onclick="refreshData();" title="Refresh page"><img src="/images/ocr/refresh-24-c406be4.png"  width="22" height="22" border="0"></a>'+
	'<div id="divFilter" class="divFilter"><div class="dShowall" id="dShowall"><table border="0"><tr><td width="25" height="25"><img src="/images/ocr/_thumb_12423.png" class="imgAll" width="20" height="20"></td><td>Show All</td></tr></table></div>'+
	'<div class="dShowFiltered" id="dShowFiltered" style="border-top:2px solid #ebebeb;width:100%;"><table border="0"><tr><td width="25" height="25"><img src="/images/ocr/_thumb_12423.png"  class="imgFiltered"  width="20" height="20"></td><td>Show invoices that require action</td></tr></table></div></div></div>');
var windowHeight = $(window).height(), sScrollY = 30; // ( windowHeight > 200 ? .71 : .55) * windowHeight;
oTable = $('.datagrid').dataTable( {
      "bServerSide": true
    , "bProcessing": true
    , "bSortClasses": false
	, "bAutoWidth": false
    , "iDisplayLength": 10
	 , "oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" },
                       "sLengthMenu": 'Display <select>'+
						        '<option value="10">10</option>'+
						        '<option value="15">15</option>'+
						        '<option value="25">25</option>'+
						        '<option value="50">50</option>'+
						        '<option value="100">100</option>' +
						        '</select> records'
					} 
    , "sAjaxSource": "/billbacks/OCR_Upload/ajax/ocr_statusboard_ajax.cfm"
    //, "sPaginationType": "full_numbers"
  	, "sScrollY": sScrollY 
    , "sDom": '<"H"fr><"toolbar">t<"F"ipl>'//'Tfrtip'       // was "fprti"
    , "bJQueryUI": false
    ,"bDeferRender": true
    ,"sLengthMenu": [ 10, 15, 25, 50, 100]
    , "aaSorting": []
    , "aoColumns": [  		{"bSearchable": true,  	"bSortable":true}
	                    ,	{"bSearchable": true, 	"bSortable":true}
	                    ,	{"bSearchable": true, 	"bSortable":true}						
	                    ,	{"bSearchable": true, 	"bSortable":true, "sClass": "amountRight"}	// format the Amount column 					
	                    ,	{"bSearchable": true, 	"bSortable":true}
	                    ,	{"bSearchable": true, 	"bSortable":true}
						,	{"bSearchable": false, 	"bSortable":true}
						,	{"bSearchable": false, 	"bSortable":false}							// no sort on the Action column
						, 	{"bSearchable": true, 	"bSortable":true, "bVisible":false}			// hide the Step column
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
				// $( "#divFilter" ).slideUp( "slow" );
				// $('tool-button').removeClass('divFilter');
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
				// console.log(oTable.get('data').size());
				//  console.log(oTable);
				//  console.log( this.api().rows( {page:'current'} ).data() );
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
 