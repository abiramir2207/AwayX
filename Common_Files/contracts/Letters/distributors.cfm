<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\Letters\distributors.cfm
      Date:     Feb 9 2012
      Author:   Chris Nguyen
      Purpose:  Allow users to select distributors to be included on quote letter - 30297
      
      Parameters:
      	URL.Contract_Main_ID:  available all the times
      
      	Available only in posting:
      		FORM.Submitted:    form posting action indicator
      		FORM.Distributors: commas-delimited list of Contract_Distributors.BSA_Foodservice_Customers_IDs 
      
----------------------------------------------------------------------------------------------------------------------->
<cfoutput>

<cfif NOT isDefined('URL.Contract_Main_ID')>
	<cf_cryp type="de" string ="#URL.CID#" key="#request.key#">
	<CFSET url.Contract_Main_ID = cryp.value>
</cfif>

<!---form posting action here--->
<cfif StructKeyExists(form, "submitted")>
	<cfif form.submitted eq cgi.script_name>    <!---safeguard--->
		<cfset saveDistributors( Customer_IDs_List=form.distributors, Contract_Main_ID=url.Contract_Main_ID )>
		<!---redirect users to quote letter page--->
		<cflocation url="quoteLetter.cfm?#cgi.query_string#" addtoken="false">
	</cfif>
	
	<cfabort>
</cfif>

<!---gather distributors in the program--->
<cfscript>
  vars = StructNew();
  vars.programCFC = CreateObject('component', 'components.programs.display_program.viewProgramTemplateManager');
</cfscript>
<cfinvoke component="components.programs.business_segment.BusinessSegmentManager"
    		     method="isEnabled"
     returnVariable="busSegMgr.isEnabled">
</cfinvoke>
<cfset vars.qDistributors = vars.programCFC.getDistributors( URL.Contract_Main_ID, busSegMgr.isEnabled, false )>

<!---redirect to quote letter page when there is only 1 distributor--->
<cfif vars.qDistributors.recordCount eq 1>
	<cfif vars.qDistributors.Is_On_Quote_Letter neq "1">
		<!---distributor has not been selected, select it & update db--->
		<cfset saveDistributors( Customer_IDs_List=vars.qDistributors.Bsa_Foodservice_Customers_Id, Contract_Main_ID=url.Contract_Main_ID )>
	</cfif>
	<!---redirect users to quote letter page--->
	<cflocation url="quoteLetter.cfm?#cgi.query_string#" addtoken="false">
</cfif>

<cfquery name="vars.qContract" datasource="#application.datasource#">
	SELECT	CM.Contract_Number
	        , CM.Contract_Title
	        , CM.Revision_Version
  	FROM	Contract_Main CM
	 WHERE	Contract_Main_ID	=	<cfqueryparam cfsqltype="cf_sql_varchar" value="#url.contract_main_ID#">
</cfquery>

<cfset vars.programNumberAndRevision = vars.qContract.Contract_Number>
<cfif val(vars.qContract.Revision_Version)>
  <cfset vars.programNumberAndRevision = vars.programNumberAndRevision & ' ' & NumberFormat(vars.qContract.Revision_Version, "009")>
</cfif>

<!--------------------------------------------------------------------------------------------------------------------->
<html lang="en">
<head>
 <meta http-equiv="content-type" content="text/html; charset=utf-8">
 <title>Quote Letter Distributors - [#vars.programNumberAndRevision#]</title>
 <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
</head>

<body>
<div style="font:bold 11pt Arial;margin:10px 0;">Quote Letter Distributors</div> <hr style="margin:10px 0;" color=navy>
<div style="margin:10px 0;font:bold 10pt Arial;padding:5px;color:navy;background-color:##ffce84">
	[#vars.programNumberAndRevision#] - #vars.qContract.Contract_Title#
</div>

<form name="distributors" method="post" action="#cgi.script_name#?#cgi.query_string#">
<input type="hidden" name="submitted" value="#cgi.script_name#">   <!---safeguard--->
<input type="hidden" name="distributors">      <!---list of selected distributors stored here--->

<cfset vars.fixedHeader = false>
<cfif vars.qDistributors.recordCount gt 35>    <!---table too long, turn on fixed header--->
  <cfset vars.fixedHeader = true>
	<cfset showFormActions()>
</cfif>

<table id="datagrid" class="datagrid">
<thead>
	<tr>
	  <th style="text-align:left;"><input type="checkbox" name="toggle_all" id="toggle_all"/></th>
	  <th>Name</th>
	  <th>Account</th>
	  <th>Address</th>
  </tr>
</thead>
<tbody>
	<cfloop query="vars.qDistributors">    
    <tr>
      <td><input type="checkbox" id="#vars.qDistributors.Bsa_Foodservice_Customers_Id#" class="toggle_one"/></td>
      <td>#vars.qDistributors.Name#</td>
      <td>#vars.qDistributors.Shr_Ship_To#</td>
      <td>#vars.qDistributors.Address_1# #vars.qDistributors.City# #vars.qDistributors.State# #vars.qDistributors.ZipCode#</td>
    </tr>
  </cfloop>
</tbody>
</table>
</form>
<br/>
<cfset showFormActions()>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="actionLinkFormat" access="public" returntype="string" output="false">
	<cfargument name="action" type="string" required="true" />
	<cfargument name="style" type="string" required="false" default="classic"/>
	
	<cfscript>
		switch (arguments.style) {
			case "classic": 
				return "<b><font color='red'>[ </font>" & arguments.action & " <font color='red'> ]</font></b>"; break;
			default: 
				return arguments.action;
		}
	</cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="showFormActions" access="public" output="true">
<div style="">
	<a class="save_209">#actionLinkFormat("save & continue")#</a>  
	<a class="cancel_209" style="margin-left:30px;">#actionLinkFormat("cancel")#</a>
</div>
<br>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="saveDistributors" access="public" output="false">
	<cfargument name="Contract_Main_ID" required="true" type="numeric">
	<cfargument name="Customer_IDs_List" required="true" type="string">
	
	<cfset var vars = structnew()>
	
	<cfoutput>
	<cfquery name="vars.update" datasource="#application.datasource#">
		<!---reset all to not selected--->
		UPDATE Contract_Distributors
		   SET Is_On_Quote_Letter = 0
		 WHERE Contract_Main_ID = #arguments.Contract_Main_ID#
		
		<cfif len(arguments.Customer_IDs_List)>
			<!---mark selected distributors to be included on quote letter--->
			UPDATE Contract_Distributors
			   SET Is_On_Quote_Letter = 1
			 WHERE Contract_Main_ID = #arguments.Contract_Main_ID#
			 			 AND BSA_Foodservice_Customers_ID IN ( <cfqueryparam value='#arguments.Customer_IDs_List#' list="true"> ) 
		</cfif>
	</cfquery>
	</cfoutput>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cfset dataTables.version = "1.9.0">

<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">

<script type="text/javascript" src="/script/javascript/jquery.datatables-api.js"></script>
<cfif vars.fixedHeader>
<script type="text/javascript" src="/script/javascript/FixedHeader.min.js"></script>
</cfif>

<script>
var oTable = 0;
<!---cancel action--->
$('.cancel_209').click(function() {
	window.close();
});
<!---submit action--->
$('.save_209').click(function() {
	var result = [];
	oTable.$('.toggle_one:checked').each(function(){
	  result.push( $(this).prop('id') );
	});
	if ( result.length == 0 ) {
		alert( "Please select at least one distributor." );
	}
	else {
		$('input[name=distributors]').val( result.join( ',' ) );
		$('form[name=distributors]').submit();
	}
});
<!---refresh the main toggle all check box--->
function refresh_toggle_all() {
  var cnt = 0;
  var all_checked = 1;
  $('.toggle_one').each(function() {    <!---are all single toggle checked?--->
    if ( !$(this).prop('checked') ) {   <!---found one single toggle unchecked--->
       all_checked = 0;
       return false;
    }
    cnt = cnt + 1;
  });
  $('##toggle_all').prop('checked', ( (all_checked == 1) && (cnt > 0) ) );
}
<!---anonymous function--->
(function() {
  oTable = $('##datagrid').dataTable({
     "bAutoWidth": false
    ,"bPaginate": false
    ,"bSortClasses": false
    ,"bScrollCollapse": true
    ,"sDom": 'fti'
    ,"fnDrawCallback": function( oSettings ) {
      refresh_toggle_all();
    }
    ,"aoColumns": [   {"sWidth": "3%", "bSortable":false, "bSearchable":false}
                    , {"sWidth": "32%"}
                    , {"sWidth": "32%"}
                    , {"sWidth": "32%"}
                  ]

  }).fnSetFilteringDelay();
  $('##datagrid tr').hover (
    function() { $(this).addClass("over"); },
    function() { $(this).removeClass("over"); }
  );  
  
  $('##toggle_all').click(function(e){      <!---listen for click event on toggle all--->
    e.stopPropagation();
    $('.toggle_one').prop('checked', this.checked );
  }); 
  
  $('.toggle_one').click(function(e){      <!---listen for click event on single toggle--->
    e.stopPropagation();
    if ( $(this).prop('checked') ) {
      refresh_toggle_all();
    }
    else {
      $('##toggle_all').prop('checked', false );   <!---at least one single toggle is unchecked so uncheck toggle all--->
    }
  }); 

	<cfif vars.fixedHeader>
  	new FixedHeader( oTable );  /*must be placed here otherwise toggle all would not work properly*/
  </cfif>
})();
</script>
</body>
</html>
</cfoutput>
