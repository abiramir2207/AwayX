<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\addActAdjustment.cfm
      Date:     Aug 9, 2012
      Author:   Chris Nguyen
      Purpose:  Add budget actual adjustments
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="form.clicked_save" default="0">

<!--------------------------------------------------------------------------------------------------------------------->

<cfif form.clicked_save eq "1">
	<!--- perform validations on server
	<cfscript>
		server.Errors = [];
		if (not isDate(form.adjustment_date))
			arrayAppend(server.Errors, 'Please enter a valid adjustment date.');

		// clean up extra characters (commas, dollar sign, white spaces) in dollar amount
		server.adjustment_dollar = replace(trim(form.adjustment_dollar), ',', '', 'all');
		server.adjustment_dollar = replace(form.adjustment_dollar, '$', '', 'all');
		if (len(server.adjustment_dollar) eq 0 or not isNumeric(server.adjustment_dollar))
			arrayAppend(server.Errors, 'Please enter a valid adjustment amount.');

		// remove white spaces in program number
		server.program_number = trim(form.program_number);
		if (len(server.program_number) eq 0 or not isNumeric(server.program_number))
			arrayAppend(server.Errors, 'Please enter a valid program number.');

		if (len(form.adjustment_notes) gt 200)
			arrayAppend(server.Errors, 'Please limit adjustment notes to 200 characters.');

		if (not isNumeric(server.adjustment_dollar))
			arrayAppend(server.Errors, 'Please enter a valid adjustment amount.');
	</cfscript>

	<cfif (len(server.program_number) and isNumeric(server.program_number))>
		<cfquery name="qActAdjustment" datasource="#application.datasource#">
			SELECT 1
			  FROM CONTRACT_MAIN cm
			       INNER JOIN PROGRAM_CONTROL_PANEL_OPTIONS t ON cm.ProgramType_Id = t.ProgramControl_Panel_Options_Id
			       INNER JOIN PROGRAM_LUMP_SUMS ls ON ls.Program_Id = cm.Contract_Main_Id
			          															AND ls.Deleted = 0
			       INNER JOIN PROGRAM_LUMP_SUM_NAME lsname ON lsname.Program_Lump_Sum_Name_Id = ls.Program_Lump_Sum_Name_Id
			 WHERE     cm.Deleted = 0
			       AND cm.Approved = 1
			       AND cm.Manual_Cancel <> 1
			       AND RIGHT( cm.Contract_Number, 7 ) = <cfqueryparam cfsqltype="cf_sql_integer" value="#server.program_number#">
						 AND ( ISNULL(t.Billback_Date, 0) = 0 -- There is no last date to claim
	                 OR DateDiff(d, Getdate(), DATEADD(d, t.Billback_Date_Span, cm.Contract_End_Date)) >= 0 -- Or last date to claim is today or in the future
	               )
		</cfquery>
		<cfif qActAdjustment.recordCount eq 0>
			<cfset arrayAppend(server.Errors, 'Please enter a valid program number.')>
		</cfif>
	</cfif>

	<!--- problems found do not save data, display errors --->
	<cfif arrayLen(server.Errors)>
		<script>
			<cfoutput>alert( '#arrayToList(server.Errors, '\n')#' );</cfoutput>
		</script>
	</cfif>
	--->
	  <cfset saveData()>
	  <!--- save & return to adjustment list --->
	  <cfif form.command contains "return">
		  <script>
			  document.forms[budget_form].command.value = "listActAdjustment";
			  document.forms[budget_form].submit();
		  </script>
		<cfelse>
			<!--- save & add another adjustment --->
			<cfscript>
				form.adjustment_date = dateformat(now(),'m/d/yyyy');
				form.adjustment_dollar = '';
				form.adjustment_notes = '';
				form.program_number = '';
				form.program_title = '';
				form.lump_sum = '';
				form.BSA_Foodservice_Customers_ID = '';
				form.contract_main_id = '';
				form.contract_start_date = '';
				form.contract_end_date = '';
			</cfscript>
		</cfif>
</cfif>

<!--------------------------------------------------------------------------------------------------------------------->

<cfsavecontent variable="vars.htmlHead">
<link rel="stylesheet" href="/styles/jQueryUI_18/smoothness/jquery-ui-1.8.22.custom.css" type="text/css" />
<style>
#mainfieldset { width:98%; padding:1%; border:1px solid blue;}
#actions { margin:0 0 10px 5px; }
#actions a { margin:0 30px 0 0;}
.mid { text-align: center; }
div.save { margin-top:10px; }
.item {
	margin:15px;
}
.itemlabel {
	width:120px;
	font-weight:bold;
	text-align:right;
	margin-right:8px;
	/*vertical-align:top;	*/
	display:inline-block;
}
.itemvalue {
	margin-left:5px;
}
#actions {
	margin-top:15px;
}
.extra {
	margin:10px 0 0 145px;
}
.fieldset2 {
	padding: 2%; width: 93%; margin:0 1%;
}
.legend2 {
	padding: 0 1.5em; font-size: 1.1em; font-weight: bold;
}
</style>
</cfsavecontent>
<cfhtmlhead text="#vars.htmlHead#">

<!--------------------------------------------------------------------------------------------------------------------->

<cfoutput>
<fieldset id="mainfieldset">
  <legend style="font: bold 14px sans-serif; color: red;">Add Actual Adjustment</legend>

 <!---------------------------------------------------------Program  Information---------------------------------------------------------------------->

<fieldset class="fieldset2">
	<legend class="legend2">Program Information</legend>
	<div class="item">
		<label class="itemlabel" for="program_number">Program Number:</label><span></span>
		<cfparam name="form.program_number" default="">
		<span class="itemvalue"><b>PRG-</b><input type="text" name="program_number" id="program_number" class="numberinput" style="vertical-align:middle;" value="#form.program_number#"></span>
		<span class="itemlabel">Title:</span>
		<cfparam name="form.program_title" default="">
		<input type="hidden" name="program_title">
		<span class="itemvalue" id="program_title">#form.program_title#</span>
	</div>

	<div class="item">
		<label class="itemlabel" for="lump_sum">Lump Sum:</label><span></span>
		<span class="itemvalue">
		<select name="lump_sum" id="lump_sum" style="width:350px;">
			<option></option>
		</select>
		</span>
	</div>

	<div class="item">
		<span class="itemlabel" for="ship_to">Ship To:</span>
		<cfparam name="form.ship_to" default="">
		<input type="hidden" name="ship_to">
		<span class="itemvalue" id="ship_to">#form.ship_to#</span>
	</div>

	<input type="hidden" name="BSA_Foodservice_Customers_ID" id="bsa_foodservice_customers_id">
	<input type="hidden" name="Contract_Main_Id" id="contract_main_id">
	<input type="hidden" name="check_duplicate" value="1">
	<input type="hidden" name="contract_start_date" id="contract_start_date">
	<input type="hidden" name="contract_end_date" id="contract_end_date">

</fieldset>

<!---------------------------------------------------------Adjustment  Information---------------------------------------------------------------------->

<fieldset class="fieldset2">
	<legend class="legend2">Adjustment Information</legend>
<!--- 	<div class="item">
		<label class="itemlabel" for="adjustment_date">Adj. Date:</label><span></span>
		<cfparam name="form.adjustment_date" default="#dateformat(now(),'m/d/yyyy')#">
		<input type="text" name="adjustment_date" id="adjustment_date" class="itemvalue" value="#form.adjustment_date#">
	</div> --->
	<cfparam name="form.adjustment_date" default="#dateformat(now(),'m/d/yyyy')#">
	<input type="hidden" name="adjustment_date" id="adjustment_date" class="itemvalue" value="#form.adjustment_date#">
	<div class="item">
		<!--- <label class="itemlabel" for="start_date">Start:</label><span></span>
		<input type="text" name="start_date" id="start_date" class="itemvalue">
		<label class="itemlabel" for="end_date">End:</label><span></span>
		<input type="text" name="end_date" id="end_date" class="itemvalue"> --->
		<label class="itemlabel" for="date_range">Select Single Period:</label><span></span>
		<span class="itemvalue">
		<select name="date_range" id="date_range" style="width:175px;">
			<option></option>
		</select>
		</span>
	</div>

	<div class="item">
		<label class="itemlabel" for="adjustment_dollar">Amount:</label><span></span>
		<cfparam name="form.adjustment_dollar" default="">
		<input type="text" name="adjustment_dollar" id="adjustment_dollar" class="numberinput itemvalue" value="#form.adjustment_dollar#">
	</div>

	<div class="item">
		<label class="itemlabel" for="adjustment_notes" style="vertical-align:top;">Notes:</label>
		<cfparam name="form.adjustment_notes" default="">
		<textarea name="adjustment_notes" id="adjustment_notes" class="itemvalue" rows=4 cols=100>#form.adjustment_notes#</textarea>
	</div>
</fieldset>



<!---------------------------------------------------------Action Links------------------------------------------------------------------------------>

<div id="actions">
 <a href="##" id="saveAddAnother">#application.util.string.actionLinkFormat("save & add another adjustment")#</a>
 <a href="##" id="return">#application.util.string.actionLinkFormat("cancel")#</a>
 <a href="##" id="saveReturn">#application.util.string.actionLinkFormat("save & return to adjustments list")#</a>
</div>
</fieldset>
</cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="saveData" output="true">
	<cfset local.adjustment_dollar = replace(form.adjustment_dollar, ",", "", "all")>
	<cfset local.adjustment_dollar = replace(form.adjustment_dollar, "$", "", "all")>

 	<cfset var oBudgetClassMgr = createObject("component","mvc.Models.AdvancedBudget.BudgetClassManager") />
 	<cfset var qryDateRange = oBudgetClassMgr.getDateRange(form.Contract_Start_Date,form.Contract_End_Date)/>
 	<cfquery name="qSelDateRange" datasource="#application.datasource#"  dbtype="query">
		SELECT start_Date, end_Date FROM qryDateRange WHERE DateRangeID = #form.Date_Range#
 	</cfquery>

	<cftransaction>
		<cfquery name="local.save" datasource="#application.datasource#">
			INSERT INTO Budget_Actual_Adjustment
			       ( Adjustment_date
			        ,Start_Date
			        ,End_Date
			        ,Adjustment_dollar
			        ,Adjustment_Notes
			        ,Contract_Main_Id
			        ,Program_Lump_Sum_ID
			        ,BSA_Foodservice_Customers_ID
			        ,Created_By
							)
		 VALUES (  <cfqueryparam cfsqltype="cf_sql_date" value="#qSelDateRange.start_date#">
		          ,<cfqueryparam cfsqltype="cf_sql_date" value="#qSelDateRange.start_date#">
		          ,<cfqueryparam cfsqltype="cf_sql_date" value="#qSelDateRange.end_date#">
		          ,<cfqueryparam cfsqltype="cf_sql_decimal" scale="2" value="#local.adjustment_dollar#">
		          ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.adjustment_notes#">
		          ,<cfqueryparam cfsqltype="cf_sql_integer" value="#form.contract_main_id#">
		          ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.lump_sum#">
		          ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.BSA_Foodservice_Customers_ID#">
		          ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#">
			       )
		</cfquery>
		<cfstoredproc procedure="ADV_BUDGET_ACTUAL_ADJUSTMENT" datasource="#application.datasource#">
			<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@contract_main_id" value="#form.contract_main_id#" null="no">
		</cfstoredproc>
	</cftransaction>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->
<script type="text/javascript" src="/script/javascript/jquery.cfjs.min.js"></script>
<script type="text/javascript" src="/script/javascript/jquery.util.js"></script>
<script type="text/javascript" src="/Script/javascript/variable.debugger.js?v=2011-10-26"></script>
<script>
<!---event for create-------------------------------------------------------------------------------------------------->
var save_trigger = 0;
$('#saveAddAnother, #saveReturn').click(function(){

	save_trigger = 1;
	var errors = [], test_value = '', todayDate = new Date();

	test_value = $.Trim( $('#program_number').val() );
	if (test_value == '') {
		errors.push('Please enter a program number.');
	}
	else if ( ! $.IsNumeric( test_value )	) {
		errors.push('Please enter a valid program number.');
	}
/*	else {
		$('#program_number').val( test_value );
		// call Ajax to validate entered program
		ajax_errors = validateProgram( false );
		errors = errors.concat( ajax_errors );
		// $.debug(ajax_errors);
	} */

	if ($("#lump_sum").val() == '') {
		errors.push('Please select a lump sum.');
	}

	test_value = $.Trim( $('input[name="adjustment_date"]').val() );
	if (test_value == '') {
		errors.push('Please enter an adjustment date.');
	}
	else if ( ! $.IsDate( test_value )	) {
		errors.push('Please enter a valid adjustment date.');
	}

	if ($("#date_range").val() == '') {
		errors.push('Please select a Single Period');
	}
	/* var start_date = $.Trim( $('input[name="start_date"]').val() );
	if (start_date == '') {
		errors.push('Please enter a starting date.');
	}
	else if ( $.DateDiff('d', todayDate, start_date ) > 0 ) {
		errors.push('Starting date cannot be in the future.');
	}

	var end_date = $.Trim( $('input[name="end_date"]').val() );
	if (end_date == '') {
		errors.push('Please enter an ending date.');
	}
	else if ( $.DateDiff('d', todayDate, end_date ) > 0 ) {
		errors.push('Ending date cannot be in the future.');
	}
	else if ( start_date !== '' && $.DateDiff('d', end_date, start_date ) > 0 ) {
		errors.push('Starting date cannot be later than ending date.');
	}
*/
	test_value = $.Trim( $('input[name="adjustment_dollar"]').val() );
	if (test_value == '') {
		errors.push('Please enter an adjustment amount.');
	}
	else if ( ! $.IsNumeric( $.Replace(test_value, ',', '', 'all') )	) {
		errors.push('Please enter a valid adjustment amount.');
	}


	if ( $('#adjustment_notes').val().length > 200 ) {
		errors.push('Please limit adjustment notes to 200 characters.');
	}

	if ( errors.length ) {
		alert( errors.join('\n') );
		save_trigger = 0;
		return false;
	}
	else {
		var record_exists = false;
		$.ajax({ url: "/mvc/Models/AdvancedBudget/BudgetManager.cfc"
		        ,type: "post"
		        ,timeout:60000
		        ,data: { method: "actAdjProgramExists"
						         ,adjustment_date: $("#adjustment_date").val()
						         ,adjustment_dollar: $("#adjustment_dollar").val()
						         ,contract_main_id: $("#contract_main_id").val()
						         ,lump_sum: $("#lump_sum").val()
						         }
		        ,dataType: "json"
		        ,async: false
		        ,success: function(json) { record_exists = json.RECORDEXISTS; }
	  });

		var continue_save = true;
	  if ( record_exists ) {
		 continue_save = confirm("An identical entry already exists for this program, amount and date.\nAre you sure you want to continue?");
	  }
	  if (continue_save) {
		  document.forms[budget_form].command.value = "saveActAdjustment-" + $(this).attr("id");
		  document.forms[budget_form].clicked_save.value = "1";
		  document.forms[budget_form].submit();
	  }
	}
  save_trigger = 0;
  return false;
});
$('#return').click(function(){
  document.forms[budget_form].command.value = "listActAdjustment";
  document.forms[budget_form].submit();
  return false;
});
<!--------------------------------------------------------------------------------------------------------------------->
// $('input[type=text]').bind('focus', function(){ $(this).addClass('hilight'); }).bind('blur', function(){ $(this).removeClass('hilight'); });
$(".numberinput").forceNumeric();
$('#adjustment_date').datepicker({
			changeMonth: true
			,changeYear: false
			,showButtonPanel: true
});
/*
$( "#start_date" ).datepicker( {  defaultDate: ""
	                               ,changeMonth: true
	                               ,numberOfMonths: 3
	                               ,maxDate: '0'
	                               ,onClose: function( selectedDate ) {
	                               	  $( "#end_date" ).datepicker( "option", "minDate", selectedDate );
	                               	}
	                             });
$( "#end_date" ).datepicker( {  defaultDate: ""
	                             ,changeMonth: true
	                             ,numberOfMonths: 3
                               ,maxDate: '0'
	                             ,onClose: function( selectedDate ) {
	                             		$( "#start_date" ).datepicker( "option", "maxDate", selectedDate );
	                             	}
	                           });
*/
$('#program_number').bind({
	change: function() { if (save_trigger == 0) validateProgram( true ); }
});
<!--------------------------------------------------------------------------------------------------------------------->
validateProgram = function( showErrors ) {
	var errors = [];
	// validate for blank value
	if ( $.Trim($("#program_number").val()) == '' ) {
		errors.push("Please enter a program number.");
		// showErrors = true: navigation between form input elements
		if (showErrors) {
			alert( errors[ errors.length - 1 ] );  $('#program_number').focus();  return false;
		}
	}
	else {
		var x_contract_main_id = $('#contract_main_id').val();
		$.ajax({ url: "/mvc/Models/AdvancedBudget/BudgetManager.cfc"
		        ,type: "post"
		        ,data: { method: "actAdjProgram"
						        ,program_number: $("#program_number").val()
						        ,adjustment_date: $("#adjustment_date").val() }
		        ,dataType: "json"
		        ,async: false
		        ,timeout: 60000
		        ,error: function(jqXHR, textStatus, errorThrown) { errors.push( 'System is busy, please try again later.' );
																															 if (showErrors) { alert( errors[ errors.length - 1 ] );  return false; }
																										         }
		        ,success: function(json) { if ( json.ERRORS.length ) {
		        															$('#program_title').text( '' );
		        															$('#ship_to').text( '' );
		        															$('select#lump_sum option').remove();
		        															$('#contract_main_id').val( '' );
		        															$('#bsa_foodservice_customers_id').val( '' );
																			$('#contract_start_date').val( '' );
																			$('#contract_end_date').val( '' );
																					if (showErrors) {
			       															  alert( json.ERRORS.join('\n') );  $('#program_number').focus();  return false;
			       															}
			       														 else {
			       															 errors = errors.concat( json.ERRORS );
			       														 }
		        													 }
		        													 else {
		        															// $.debug(json, {recursive:true});
		        															$('#program_title').text( json.CONTRACT_TITLE );
		        															$('#ship_to').text( json.DISTRIBUTOR_NAME + '  [' + json.SHR_SHIP_TO + ']' );
		        															$('#bsa_foodservice_customers_id').val( json.BSA_FOODSERVICE_CUSTOMERS_ID );
		        															$('#contract_main_id').val( json.CONTRACT_MAIN_ID );
																			$('#contract_start_date').val( json.CONTRACT_START_DATE );
																			$('#contract_end_date').val( json.CONTRACT_END_DATE );
		        															// program changed, load new options
		        															if (json.CONTRACT_MAIN_ID !== x_contract_main_id) {
		        															  var options = [];
		        															  if ( json.LUMP_SUM.length > 1 ) {
		        															  	options.push('<option value="">** select a lump sump component **</option>');
		        															  }
      																		  for (var i = 0; i < json.LUMP_SUM.length; i++) {
        																	  	options.push( '<option value="' + json.PROGRAM_LUMP_SUM_ID[ i ] + '">' + json.LUMP_SUM[ i ] + '</option>' );
      																		  }
      																		  $("select#lump_sum").html(options.join(' '));

																			  var dOptions = [];
																			  if ( json.DATE_RANGE.length > 1 ) {
		        															  	dOptions.push('<option value="">** select a single period **</option>');
		        															  }
      																		  for (var i = 0; i < json.DATE_RANGE.length; i++) {
        																	  	dOptions.push( '<option value="' + json.DATE_RANGE_ID[ i ] + '">' + json.DATE_RANGE[ i ] + '</option>' );
      																		  }
      																		  $("select#date_range").html(dOptions.join(' '));

      																		}
		        													 }
		        	                       }
		      });
	}
	return errors;
}
</script>




