<cfscript>
	cfcAttrsPath = 'autoPayTable';
</cfscript>

<cfinclude template="\mvc\Views\dataTable.cfm" >

<form name="frm_BB_Auto_Report_View" method="post" action="index.cfm" target="_parent">
	<input type="hidden" name="action" id="action" value="" />
	<input type="hidden" name="userId" id="userId" value="" />
	<input type="hidden" name="reportId" id="reportId" value="0" />
	<input type="hidden" name="periodId" id="periodId" value="0" />
</form>
<style type="text/css">
	.grayBackGround {
	opacity: 0.5;
    background: black;
    filter: alpha(opacity = 50);
    left: 0;
    position: absolute;
    top: 0;
}
</style>

<script>
function deleteReportAction(reportId,periodId,userId) {
	  // Calls remote method with string mask as argument 
	  var argument = new Array();
	  var theId = 'spanLoading' + reportId;
	  //var theId = 'createLoading';
	  var theAction = 'spanAction' + reportId;
	  argument[0]	= reportId;
	  argument[1]	= periodId;
	  argument[2]	= userId;

		document.all.frm_BB_Auto_Report_View.action.value = 'deleteReport';
		document.all.frm_BB_Auto_Report_View.userId.value = userId;
		document.all.frm_BB_Auto_Report_View.reportId.value = reportId;
		document.all.frm_BB_Auto_Report_View.periodId.value = periodId;
		document.all.frm_BB_Auto_Report_View.submit();
	}
	
function approveReportAction(reportId,periodId,userId) {
	  // Calls remote method with string mask as argument 
	  var argument = new Array();
	  var theId = 'spanLoading' + reportId;
	  //var theId = 'createLoading';
	  var theAction = 'spanAction' + reportId;
	  argument[0]	= reportId;
	  argument[1]	= userId;
		    
		   document.all.frm_BB_Auto_Report_View.action.value = 'approve';
		   document.all.frm_BB_Auto_Report_View.userId.value = userId;
		   document.all.frm_BB_Auto_Report_View.reportId.value = reportId;
		   document.all.frm_BB_Auto_Report_View.submit();
	  		//call ajax.  response goes to JS callReportResponse() in an array
	  		//ajBBReport.call('approveReportCaller',callReportResponse,argument);
	  } 	

$(document).ready(function() {
	//alert('ready');

var $dialog = $('<div id="dvModal" class="grayBackGround"></div>')
	.html('<table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td align="center"><img src="/images/ajax-loader_red.gif"/></td></tr></table>')
	.dialog({
	autoOpen: false,
    title: 'PROCESSING',
	modal: true,
	buttons: [],
	dialogClass: "alert",
	disabled: true,
	beforeclose : function() { return false; }
  });
  
 //$.debug($dialog); 
/*
	$("#dvModal").dialog({
  	autoOpen: false,
    title: 'Auto Pay Report',
	html: 'Spinner',
	modal: true
  });
*/
  
});


/*
  DISABLE LINKS ONCLICK
*/


$( document ).on( "click", "a [class!='sPaging']", function( e ) {
	$("#dvModal").dialog('open');
	//var ss = $("#dvModal");
	//$.debug(ss);
	$( document ).on( "click", "a", function( e ) {
		
		
		$('a').attr({
					'href': '',
					'class':'disabled',
					'onClick':''
					});
		return false;
	} );

} );

</script>