<cfparam name="request.html_started" default="0">
<cfif !request.html_started>
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
</cfif>
<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\Letters\distributors_custom3.cfm
      Date:     Oct 1 2014
      Author:   Kal
      Purpose:  Allow users to select distributors to be included on quote letter - 30297

      Parameters:
      	URL.CID:  available all the times

      	Available only in posting:
      		FORM.Submitted:    form posting action indicator
      		FORM.Distributors: commas-delimited list of Contract_Distributors.BSA_Foodservice_Customers_IDs

----------------------------------------------------------------------------------------------------------------------->

<cfoutput>
<!---form posting action here--->
<cfif StructKeyExists(form, "submitted")>    
  <cfif form.submitted eq cgi.script_name>    <!---safeguard--->    
    <!--- generate the letters for selected --->
    <cfif form.letters_available eq 5>
        <cfinclude template="quoteletter/create_letters_custom5.cfm">
    <cfelse>
        <cfinclude template="quoteletter/create_letters_custom3.cfm">
    </cfif>
    
    <!---redirect users to quote letter page--->
    <cflocation url="view_letters.cfm?CID=#CID#&display=view" addtoken="false">
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

<cfset vars.qDistributors = vars.programCFC.getDistributors( URL.CID, busSegMgr.isEnabled, false )>
<cfset vars.qOperators = vars.programCFC.getOperators( URL.CID ) />

<!--- If we don't have any distributors on the program then try operators --->
<cfif not vars.qDistributors.recordCount and vars.qOperators.recordCount>
	
	<cfquery name="vars.qData" dbtype="query">
		SELECT	Operator_name AS Name,
				Operator_ID AS Account,
				BSA_Operator_ID AS Operator_ID,
				0 AS Distributor_ID
		FROM	vars.qOperators
	</cfquery>
	
<cfelse>

	<cfquery name="vars.qData" dbtype="query">
		SELECT	Name AS Name,
				<cfif (appSettings.get_Setting('Display_Distributor_ID') EQ '1')>
					Shr_Ship_To AS Account,
				<cfelse>
					Ship_To AS Account,
				</cfif>	
				BSA_Foodservice_Customers_ID AS Operator_ID,
				BSA_Foodservice_Customers_ID AS Distributor_ID
		FROM	vars.qDistributors
	</cfquery>
	
</cfif>

<cfquery name="vars.qContract" datasource="#application.datasource#">
  SELECT CM.Contract_Number,
         CM.Contract_Title,
         CM.Revision_Version
  FROM Contract_Main CM
  WHERE Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.CID#">
</cfquery>

<cfset vars.programNumberAndRevision = vars.qContract.Contract_Number>
<cfif val(vars.qContract.Revision_Version)>
  <cfset vars.programNumberAndRevision = vars.programNumberAndRevision & ' ' & NumberFormat(vars.qContract.Revision_Version, "009")>
</cfif>


<!--- (Start) Check whether automated letter process is ON --->
<cfset generateLetters = 1>

<!--- Initialize the Java Service Factory --->
<cfobject type="JAVA" action="Create" name="factory" class="coldfusion.server.ServiceFactory">

<!--- Get all the jobs from the JAVA service factory --->
<cfset allTasks = factory.CronService.listAll()>
<CFOUTPUT>
<cfloop array="#allTasks#" item="task">
	<!--- Look for file name "Scheduled/approvalLetter.cfm" and program id in the url of the job. If both exist, then the automated
	letter generation job is still running for the program. Set generateLetters = 0, so that no user can generate the letter while
	the job is running.
	--->
	<cfif FindNoCase("#CGI.HTTP_HOST#/Scheduled/approvalLetter.cfm", task.url) neq 0 
        and FindNoCase(url.CID, task.url) neq 0 
        <!--- wr 103889 - ignore expired CF scheduled task due to unexpected problems --->
        and task.status neq "Expired">                   
		<cfset generateLetters = 0>
		<cfbreak>
	</cfif>
</cfloop>
</CFOUTPUT>
<!--- (End) Check whether automated letter process is ON --->

<!--------------------------------------------------------------------------------------------------------------------->
<cfif !request.html_started>
    <html lang="en">
    <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Quote Letter Distributors - [#vars.programNumberAndRevision#]</title>
    </head>

    <body>
</cfif>

<cf_include files="/styles/css-loader.css, /common_files/datatable.css">
<div style="margin:0 0 5px 0;font:bold 10pt Arial;padding:5px;color:navy;background-color:##ffce84;">
	[#vars.programNumberAndRevision#] - #vars.qContract.Contract_Title#
</div>

<form name="distributors" method="post" action="#cgi.script_name#?#cgi.query_string#">
    <input type="hidden" name="submitted" value="#cgi.script_name#">   <!---safeguard--->
    <input type="hidden" name="distributors">             <!---list of selected distributors stored here--->
    <input type="hidden" name="distLtrDistributors">      <!---list of selected distributors for distributor letter stored here--->
    <input type="hidden" name="operLtrDistributors">      <!---list of selected distributors for operator letter stored here--->
        
<cfif generateLetters eq 0>
    <span style="color:red"><b>THE AUTOMATED LETTER GENERATION PROCESS IS CURRENTLY IN PROGRESS FOR THIS PROGRAM.<b/></span>
<cfelse>
    <style>
        section.rfp, div.rfp {
            margin-bottom: 13px;
        }
        label.rfp {
            font-weight: bold;
            margin-right: 25px;
            cursor: pointer;
        }
        a.rfp {
            margin-left: 25px;
        }
        input.rfp {
            position: relative;
            top: 2px;
        }
    </style>    
    
    <div class="rfp">
        <a class="save_209" href="##">#application.util.string.linkFormat('continue')#</a>
        <a class="cancel_209 rfp" href="##">#application.util.string.linkFormat('cancel')#</a>
    </div>

    <cfset request.letters_available = appSettings.getlettersavailable()>
    <input type="hidden" name="letters_available" value="#request.letters_available#">

    <!--- custom rfp letter --->
    <cfif request.letters_available eq 5>
        <cfif !isDefined("request.getfieldsettings")>
            <cfset templateManager  = CreateObject("component", "components.programs.template.TemplateManager").init()>
            <cfset request.getFieldSettings = templateManager.getProgramTemplate(url.CID)>
        </cfif>
        <!--- show excel export when at least one excel export is selected in program template  --->
        <cfif request.getfieldsettings.Non_Blended_Delivered_Freight_Matrix_Excel_Export
                or request.getfieldsettings.Blended_Delivered_Freight_Matrix_Excel_Export
                or request.getfieldsettings.Escalator_Excel_Export>
            <section class="rfp">
                <label class="rfp">Excel Exports:</label>
                <cfif request.getfieldsettings.Non_Blended_Delivered_Freight_Matrix_Excel_Export>
                    <label class="rfp" style="margin-left:10px;"> 
                        <input class="rfp" type="checkbox" value="1" name="Non_Blended_Delivered_Freight_Matrix_Excel_Export"> Non Blended Delivered Freight Matrix 
                    </label>
                </cfif>
                <cfif request.getfieldsettings.Blended_Delivered_Freight_Matrix_Excel_Export>
                    <label class="rfp"> 
                        <input class="rfp" type="checkbox" value="1" name="Blended_Delivered_Freight_Matrix_Excel_Export"> Blended Delivered Freight Matrix 
                    </label>
                </cfif>
                <cfif request.getfieldsettings.Escalator_Excel_Export>
                    <label class="rfp"> 
                        <input class="rfp" type="checkbox" value="1" name="escalator_excel_export"> Escalator 
                    </label>
                </cfif>
            </section>
            <hr class="two">
        </cfif>    

        <section class="rfp">
            <label class="rfp">Terms</label> <input type="text" name="term" value="1% 15 Net 30"><br><br>
			<label class="rfp" style="vertical-align:top;">Notes </label><textarea name="txtNotes" id="txtMessage" rows="5" cols="100" maxlength="500"></textarea><br><br>
            <label class="rfp">Discount Types:</label>
            <label class="rfp"> <input class="rfp" type="checkbox" value="1" name="fixed_price" checked> Fixed Price </label>
            <label class="rfp"> <input class="rfp" type="checkbox" value="1" name="rebate"> Rebate </label>
            <label class="rfp"> <input class="rfp" type="checkbox" value="1" name="lump_sum"> Lump Sum </label><br><br>
        </section>
    </cfif>
</cfif>

<cfset vars.fixedHeader = false>
<cfif vars.qData.recordCount gt 35>    <!---table too long, turn on fixed header--->
  <cfset vars.fixedHeader = true>
</cfif>

<table id="datagrid" class="datagrid">
	<thead>
		<tr>
			<th>Name</th>
			<th>Account</th>
			<th><input type="checkbox" name="toggle_all_op" id="toggle_all_op" <cfif ((not qGetProgramLetterSettings.operator_letters_required) and qGetProgramLetterSettings.Custom_RFP_Letter EQ 0)>disabled</cfif> /> #application.returned_customer_setting.operator_label_singular# Letter</th>
			<th><input type="checkbox" name="toggle_all_dist" id="toggle_all_dist" <cfif not vars.qDistributors.RecordCount>disabled</cfif> /> #application.returned_customer_setting.distributor_label_singular# Letter</th>
		</tr>
	</thead>
	<tbody>
		<cfloop query="vars.qData">
		<tr>
			<td>#vars.qData.Name#</td>
			<td>#vars.qData.Account#</td>
			<td><input type="checkbox" id="#vars.qData.Operator_ID#" class="toggle_one_op" <cfif ((not qGetProgramLetterSettings.operator_letters_required) and qGetProgramLetterSettings.Custom_RFP_Letter EQ 0) >disabled</cfif> /></td>
			<td><input type="checkbox" id="#vars.qData.Distributor_ID#" class="toggle_one_dist" <cfif not vars.qDistributors.recordCount>disabled</cfif> /></td>
		</tr>
		</cfloop>
	</tbody>
</table>
</form>


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
	<a class="save_209" href="##">#actionLinkFormat('continue')#</a>
	<a class="cancel_209" style="margin-left:30px;" href="##">#actionLinkFormat('cancel')#</a>
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
    var distLtrDist = [];
    var operLtrDist = [];
    oTable.$('.toggle_one_dist:checked:not(:disabled)').each(function(){
        distLtrDist.push( $(this).prop('id') );
    });
    oTable.$('.toggle_one_op:checked:not(:disabled)').each(function(){
        operLtrDist.push( $(this).prop('id') );
    });

	if ( distLtrDist.length == 0 && operLtrDist.length == 0 && $("input.rfp:checked").length == 0 ) {
		alert( "Please select at least one letter" + ( $("input.rfp").length ? " or one excel export" : '' ));
	}
	else {
        show_loader( "PROCESSING YOUR REQUEST, PLEASE WAIT...");
        $('input[name=distributors]').val( operLtrDist.join( ',' ) );
        $('input[name=distLtrDistributors]').val( distLtrDist.join( ',' ) );
        $('input[name=operLtrDistributors]').val( operLtrDist.join( ',' ) );
        $('form[name=distributors]').submit();
	}
});
<!---refresh the main toggle all check box--->
function refresh_toggle_all_op() {
  var cnt = 0;
  var all_checked = 1;
  $('.toggle_one_op').each(function() {    <!---are all single toggle checked?--->
    if ( !$(this).prop('checked') ) {   <!---found one single toggle unchecked--->
       all_checked = 0;
       return false;
    }
    cnt = cnt + 1;
  });
  $('##toggle_all_op').prop('checked', ( (all_checked == 1) && (cnt > 0) ) );
}

<!---refresh the main toggle all check box--->
function refresh_toggle_all_dist() {
  var cnt = 0;
  var all_checked = 1;
  $('.toggle_one_dist').each(function() {    <!---are all single toggle checked?--->
    if ( !$(this).prop('checked') ) {   <!---found one single toggle unchecked--->
       all_checked = 0;
       return false;
    }
    cnt = cnt + 1;
  });
  $('##toggle_all_dist').prop('checked', ( (all_checked == 1) && (cnt > 0) ) );
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
      refresh_toggle_all_op();
	  refresh_toggle_all_dist();
    }
    ,"aoColumns": [   {"sWidth": "32%"}
                    , {"sWidth": "32%"}
					, {"sWidth": "15%", "bSortable":false, "bSearchable":false}
                    , {"sWidth": "15%", "bSortable":false, "bSearchable":false}
                  ]
  }).fnSetFilteringDelay();
  $('##datagrid tr').hover (
    function() { $(this).addClass("over"); },
    function() { $(this).removeClass("over"); }
  );

  $('##toggle_all_op').prop('checked', true ); <!--- D45946 --->
  $('.toggle_one_op').prop('checked', true ); <!--- D45946 --->

  $('##toggle_all_op').click(function(e){      <!---listen for click event on toggle all--->
    e.stopPropagation();
    $('.toggle_one_op').prop('checked', this.checked );
  });

  $('.toggle_one_op').click(function(e){      <!---listen for click event on single toggle--->
    e.stopPropagation();
    if ( $(this).prop('checked') ) {
      refresh_toggle_all_op();
    }
    else {
      $('##toggle_all_op').prop('checked', false );   <!---at least one single toggle is unchecked so uncheck toggle all--->
    }
  });

  $('##toggle_all_dist').click(function(e){      <!---listen for click event on toggle all--->
    e.stopPropagation();
    $('.toggle_one_dist').prop('checked', this.checked );
  });

  $('.toggle_one_dist').click(function(e){      <!---listen for click event on single toggle--->
    e.stopPropagation();
    if ( $(this).prop('checked') ) {
      refresh_toggle_all_dist();
    }
    else {
      $('##toggle_all_dist').prop('checked', false );   <!---at least one single toggle is unchecked so uncheck toggle all--->
    }
  });
  
	<cfif vars.fixedHeader>
  	new FixedHeader( oTable );  /*must be placed here otherwise toggle all would not work properly*/
  </cfif>
})();
</script>

<cfif !request.html_started>
    </body>
    </html>
</cfif>
</cfoutput>
