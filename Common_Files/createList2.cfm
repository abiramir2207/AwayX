<!DOCTYPE html>
<cfsilent>
<!---------------------------------------------------------------------------------------------------------------------
			Template:  \Common_Files\createList2.cfm
					Date:  2015 Sep 18
				Author:  Chris Nguyen
			 Purpose:  A generic template which allows users to create a list of entries with search option & cancel option

		 Parameter:  url.parent = name of parent (e.g. 'bb_search') :: string, required
----------------------------------------------------------------------------------------------------------------------->
<!--- constants --->
<cfscript>
	constants                  = {};
	constants.bb_search        = 'bb_search';
	constants.BB_Code   = 'BB_Code';
	constants.Reference_Number   = 'Reference_Number';
	constants.program_search   = 'search_program';
	constants.deduction_search = 'deduction';
	constants.BB_Reassign 	   = 'Reassign_BB_Code';
	variables.submit           = 'search';
	opener                     = {};
	opener.list_input_name     = '';
	opener.form_name           = '';
	opener.match_type		   = 'match_type';
	opener.function_name   	   = "";
</cfscript>

<cfparam name="url.type" default="">
<cfparam name="url.parent" default="">

<cfscript>
	if (url.parent eq constants.bb_search) {
		if(url.type eq 'Payable'){
			variables.listLabel    = 'Create a list of payables';
			opener.list_input_name = "payable_list";
		}else if(url.type eq 'BB_Code'){
			variables.listLabel    = 'Create a list of payables';
			opener.list_input_name = "payable_list";
			opener.pageOrigin = "BB_Reassign";
		}else if(url.type eq 'Item'){
			variables.listLabel    = 'Create a list of Items';
			opener.list_input_name = "Item_list";
		}else if(url.type eq 'Billback'){
			variables.listLabel    = 'Create a list of Billbacks';
			opener.list_input_name = "billback_list";
		}else if(url.type eq 'Reference'){
			variables.listLabel    = 'Create a list of reference ##';
			opener.list_input_name = "reference_list";
		}else if(url.type eq 'Program'){
			variables.listLabel    = 'Create a list of Programs';
			opener.list_input_name = "program_list";
		}else if(url.type eq 'Distributor'){
			variables.listLabel    = 'Create a list of Distributors';
			opener.list_input_name = "distributor_list";
		}else if(url.type eq 'Operator'){
			variables.listLabel    = 'Create a list of Operators';
			opener.list_input_name = "operator_list";
		}else if(url.type eq 'OperatorNumber'){
			variables.listLabel    = 'Create a list of Operator ##';
			opener.list_input_name = "operator_number_list";
		}else if(url.type eq 'VendorID'){
			variables.listLabel    = 'Create a list of Vendor ID';
			opener.list_input_name = "vendor_list";
		}else if(url.type eq 'soldToNo'){
			variables.listLabel    = 'Create a list of Sold To';
			opener.list_input_name = "soldToNo_list";
		}else{
			variables.listLabel    = 'Create a list of payables';
			opener.list_input_name = "payable_list";
		}
		opener.form_name       = "SearchForm";
	}
	else if (url.parent eq constants.BB_Code) {
		variables.listLabel    = 'Create a list of payables';
		opener.list_input_name = "payable_list";
		opener.form_name       = "frmGetDate";
	}
 	else if (url.parent eq constants.BB_Reassign) {
		variables.listLabel    = 'Create a list of payables';
		opener.list_input_name = "payable_list";
		opener.form_name       = "BB_Reassign";
	}
	else if (url.parent eq constants.Reference_Number) {
		variables.listLabel    = 'Create a list of Reference numbers';
		opener.list_input_name = "Reference_Number_list";
		opener.form_name       = "frmGetDate";
	}
	else if (url.parent eq constants.program_search) {
		variables.listLabel    = 'Create a list of programs';
		opener.list_input_name = "program_list";
		opener.form_name       = "MyForm";
	}
	else if (url.parent eq constants.deduction_search) {
		variables.listLabel    = 'Enter deduction ## followed by Enter key';
		opener.list_input_name = "create_list_numbers";
		opener.function_name   = "SubmittoDDSelection";
	}
	else {
		variables.listLabel = 'Create a list of entries';
		variables.submit    = 'save';
	}

	if(url.type eq 'BB_Code'){
	opener.form_name       = "BB_Reassign";
	opener.pageOrigin	= "BB_Reassign";
	}

</cfscript>
</cfsilent>
<!---
////////////////////////////
// Page content starts here
////////////////////////////
--->
<html>
<head>
		<title>Create List</title>
		<style>
			h2, form {width:90%;margin:3px 5%;padding:0;}
			h2 { font-size:1.35em; }
			textarea { width:98%; margin:1%; padding:0; }
			a { margin: 5%; }
			#close13 { opacity: 0.75; }
		</style>
</head>
<body>
<!---
//////////////////////////
// Heading starts here
//////////////////////////
--->
<cfoutput><h2>#variables.listLabel#</h2></cfoutput>

<!---
//////////////////////////
// Body starts here
//////////////////////////
--->

<cfsavecontent variable="variables.body">
<form name="createList2" method="post">
	<textarea name="entries" rows=28></textarea>
	<cfif (url.parent eq constants.bb_search OR url.parent eq constants.BB_Code OR url.parent eq constants.Reference_Number OR url.parent eq constants.BB_Reassign)>
	<b>Find using:</b>
		<input type="radio" name="match_type" value="partial" <cfif application.appSettingsget.getExact_List_Matching_On() eq "0">checked</cfif>>Partial match<!---  --->
		<input type="radio" name="match_type" value="exact" <cfif application.appSettingsget.getExact_List_Matching_On()>checked</cfif>>Exact match<br><br><!---  --->
	<cfelse>
		<input type="hidden" name="match_type" value="">
	</cfif>
</form>
</cfsavecontent>
<cfoutput>#application.util.string.compress( variables.body )#</cfoutput>

<!---
//////////////////////////
// Footer starts here
//////////////////////////
--->
<cfoutput>
<cfsavecontent variable="variables.footer">
<a href="##" id="search13">#application.util.string.actionLinkFormat2( variables.submit )#</a><a href="##" id="close13">#application.util.string.actionLinkFormat2("close & reset")#</a>
</cfsavecontent>
#application.util.string.compress( variables.footer )#</cfoutput>

<!--- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --->
<cfinclude template="/common_files/jQuery.cfm">

<script>
var $entries = $('textarea[name=entries]');
//var $matchType = $('textarea[name=match_type]');
// var $matchType = $("input[name='match_type']:checked");
//var radioValue = $("input[name='gender']:checked"). val();


$("#close13").click(function(){
	<cfoutput>window.opener.jQuery("input[name=#opener.list_input_name#]").val('');</cfoutput>
	window.close();
});
// populate current list value
<cfif opener.list_input_name neq "" and 0>
	<cfoutput>$entries.val( window.opener.jQuery("input[name=#opener.list_input_name#]").val() );</cfoutput>
</cfif>
$("#search13").click(function(){
	var entries = $entries.val();
	var matchType = '';
	// is there anything to search for?
	if (!$.trim(entries)) {
		alert("Please enter at least one entry to process.");
		$entries.focus();
		return false;
	}
	<cfoutput>
	window.opener.jQuery("input[name=#opener.list_input_name#]").val(entries);
	<cfif (url.type eq 'BB_Code')>
		window.opener.jQuery("input[name=pageOrigin]").val("BB_Reassign");
	</cfif>

	<cfif (url.parent eq constants.bb_search OR url.parent eq constants.BB_Code OR url.parent eq constants.Reference_Number OR url.parent eq constants.BB_Reassign)>
		matchType = $("input[name='match_type']:checked").val();
		if (!$.trim(matchType)) {
		alert("Please select a type of search!");
		return false;
	}
		window.opener.jQuery("input[name=#opener.match_type#]").val(matchType);
		window.opener.show_loader( "LOADING, PLEASE WAIT...", 1000 );
	</cfif>
	// trigger a form submission in parent window
	<cfif opener.form_name neq "">
	<cfif url.parent eq constants.bb_search>
        if(window.opener.showSearchResult){
		  window.opener.showSearchResult(true, 1);
        }
        else {
            window.opener.jQuery("form[name=#opener.form_name#]").submit();
        }
        <cfelse>
		window.opener.jQuery("form[name=#opener.form_name#]").submit();
	</cfif>
	</cfif>
	// trigger a function call in parent window
	<cfif opener.function_name neq "">
		window.opener.#opener.function_name#();
	</cfif>
	window.close();
	</cfoutput>
});
// focus on text area when document is ready
$(function(){
	$entries.focus();
});
</script>
<cfinclude template="\common_files\focus.cfm">
</body>
</html>
