<!DOCTYPE HTML>
<!--------------------------------------------------------------------------------------------------------------------------------------------------------
  Component: \profits\operator\index.cfm
  Date:      April 2013
  Author:    Chris Nguyen
    
  Remarks:  This is the main template that controls operator profit report
  
--------------------------------------------------------------------------------------------------------------------------------------------------------->
<html lang="en">
<head>
 <meta http-equiv="content-type" content="text/html; charset=utf-8">
 <link href="/common_files/fixedHeaderTable/reset.css" rel="stylesheet" media="screen" />
 <link href="/common_files/main_style.css" rel="stylesheet" type="text/css">
 <link href="/common_files/960.css" rel="stylesheet" media="screen" />
 <link href="/common_files/select2.css" rel="stylesheet" type="text/css">
 <title>Operator Profit</title>
 <style>
	 .fs425 { margin: 2px; border: 1px solid gray; }
	 .l425 { padding: 0 6px; font-weight: bold; font-size: 1.3em; }
	 #inputform { margin: 2px 0; }
	 .label4 { font-weight: bold; }
	 .input { width: 320px; }
	 .indent { margin-left: 322px; }
	 #operatorDiv { margin-top: 18px; }
	 #buttonDiv { margin-top: -10px; margin-bottom: 5px; }
	 #buttonDiv a:first-child { margin-right: 25px; }
	 #report { margin-left: 4px; overflow: hidden; }
 </style>
 <cfinclude template="/common_files/jQuery.cfm">
</head>
<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
<body>
<!---<cfdump var="#form#">--->
<cfparam name="form.product"      default="">
<cfparam name="form.productText"  default="">
<cfparam name="form.operator"     default=""> 
<cfparam name="form.operatorText" default=""> 
<cfparam name="form.allProducts"  default="">
<cfparam name="form.display"      default="cases_rates">
<cfparam name="form.branded"      default="on">
<cfparam name="form.privateLabel" default="on">
<cfparam name="form.debug"        default="">
<cfparam name="form.operatorSearchBy" default="single">

<fieldset class="fs425">
	<legend class="l425">Operator Profit</legend>
	<cfoutput>
	<form name="operatorProfit" id="operatorProfit" method="post">
		<div id="inputform" class="container_16">
			<div id="productDiv" class="grid_7">
				<input type="checkbox" <cfif form.allProducts eq 'on'>checked</cfif> name="allProducts" id="allProducts">Include All Products 
				<cfif request.AccessStructure.User_Rights_ID eq 9999><input type="checkbox" <cfif form.debug eq 'on'>checked</cfif> name="debug">Developer Mode</cfif>   
				<br>   
				<input type="hidden" name="productText" id="productText" value="#form.productText#">
				<label class="label4" for="product">Search Product Group</label> (not applicable when Include All Products is checked)<br><input type="hidden" name="product" id="product" class="input">  
			</div> <!---end productDiv--->
			
			<div id="operatorDiv" class="grid_9">
				<input type="hidden" name="operatorText" id="operatorText" value="#form.operatorText#">
				<label class="label4" for="operator">Search Operator</label> (by name or by legacy ID)<br><input type="hidden" name="operator" id="operator" class="input">
				<input type="radio" name="operatorSearchBy" value="single" <cfif form.operatorSearchBy eq "single">checked=checked</cfif> class="operatorSearchBy"> individual operator<br>
			  <input type="radio" name="operatorSearchBy" value="group"  <cfif form.operatorSearchBy eq "group">checked=checked</cfif> class="indent operatorSearchBy"> operator group
			</div> <!---end operatorDiv--->
			<div class="clear"></div>
			
			<div id="buttonDiv" class="grid_16">
				<b style="margin-left:0px">Display</b> <!---<input type="radio" name="display" <cfif form.display eq "totals">checked</cfif> value="totals">Dollars--->
				<input type="radio" name="display" <cfif form.display eq "cases_rates">checked</cfif> value="cases_rates">Cases 
				<input type="radio" name="display" <cfif form.display eq "pounds_rates">checked</cfif> value="pounds_rates">Pounds 
				<input type="radio" name="display" <cfif form.display eq "eqc_rates">checked</cfif> value="eqc_rates">EQC 
				<!---<input type="checkbox" name="branded" style="margin-left:23px" <cfif form.branded eq "on">checked</cfif>>Branded
				<input type="checkbox" name="privateLabel" <cfif form.privateLabel eq "on">checked</cfif>>Proprietary--->
				<a style="margin-left:224px" id="genreport" href="##"> #application.util.string.actionLinkFormat( "generate report" )# </a> 
				<cfif cgi.request_method eq 'post'>
					<a id="export" href="##" style="margin-left:15px" onclick="getCSVData();"> #application.util.string.actionLinkFormat( "export" )# </a>
				</cfif>
			</div>  <!---end buttonDiv--->
			<div class="clear"></div>
		</div> <!---end inputform--->
	</form>
	</cfoutput>
	
	<cfif cgi.request_method eq 'post'>	
		<div id="report">
			<cfinclude template="operatorProfitReport.cfm">
		</div>
	</cfif>
</fieldset>

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfscript> 
 oProfitModel  = createObject("component", "components.general.Profitability_Models");
 if ( oProfitModel.isHeadQuarters() ) {
 	below_me_positions = "ALL";
 }
 else {
 	qPositionBelowMe = oProfitModel.getPositionBelowMe();
 	below_me_positions = valueList(qPositionBelowMe.Below_User_Positions_Id);
 }
</cfscript>

<script type="text/javascript" src="/script/javascript/select2.min.js"></script>
<script>
$(function() {
  var pageLength = 40;
  $('#operator').select2( { 
  	placeholder:"Type your operator name or legacy id here...",
  	minimumInputLength: 3,
  	allowClear: true,
    blurOnChange: true,
    openOnEnter: false,
    ajax: {
        url: "/components/general/Profitability_Models.cfc",
        dataType: 'json',
        quietMillis: 100,
        data: function (term, page) {
            return {
                method: "pullOperators",
                searchInput: term,
                searchCategory: $('input:radio[name=operatorSearchBy]:checked').val(),
                page_limit: pageLength,
                page: page,
                below_me_positions: <cfoutput>'#below_me_positions#'</cfoutput>
            };
        },
        results: function (data, page) {
            var more = (page * pageLength) < data.total;
            return { results: data.operators, more: more };
        }
    }
  } );
  $('#product').select2( { 
  	<cfoutput>placeholder:"Type your product #application.returned_customer_setting.type_code_label_singular# here...",</cfoutput>
  	minimumInputLength: 3,
  	allowClear: true,
    blurOnChange: true,
    openOnEnter: false,
    initSelection: function (element, callback) {
        var data = {id: element.val(), text: element.val()};
        callback(data);
    },
    ajax: {
        url: "/components/general/Profitability_Models.cfc",
        dataType: 'json',
        quietMillis: 100,
        data: function (term, page) {
            return {
                method: "pullProducts",
                searchInput: term,
                page_limit: pageLength,
                page: page
            };
        },
        results: function (data, page) {
            var more = (page * pageLength) < data.total;
            return { results: data.products, more: more };
        }
    }
  } );
	/* initialize previously selected product */
	<cfif len(form.product) and len(form.productText)>
		$("#product").select2( 'data', <cfoutput>{id:"#form.product#", text:"#form.productText#"}</cfoutput> );
	</cfif>
	/* initialize previously selected operator */
	<cfif len(form.operator) and len(form.operatorText)>
		$("#operator").select2( 'data', <cfoutput>{id:"#form.operator#", text:"#form.operatorText#"}</cfoutput> );
	</cfif>
	/* save selected product description in form.productText */
	$('#product').on("change", function() {
		var newText = '';
		/* get product text when it is not null */
		if ( $(this).select2('data') ) {
			newText = $(this).select2('data').text;
			$("#allProducts").prop('checked', false);
		}
		$("#productText").val( newText );
		reset();
	});
	$("#allProducts").change(function() { 
		/* when all products is checked we need to clear out individual product selection */
		if ( $(this).prop("checked") ) {
			$('#product').select2('data', null);
		}
		reset();
	});
	/* save selected operator description in form.operatorText */
	$('#operator').on("change", function() {
		var newText = '';
		/* get operator text when it is not null */
		if ( $(this).select2('data') ) {
			newText = $(this).select2('data').text;			 
		}
		$("#operatorText").val( newText );
		reset();
	});
	/* reset operator input when operator search by is changed */
	$('.operatorSearchBy').change(function(){
		$('#operator').select2('data', null);
		$("#operatorText").val( '' );
		reset();
	});
	$('input[name=display], input[name=branded], input[name=privateLabel]').change(function() {
		reset();
	});
	reset = function() {
		$("#report, #export").hide();
	}
	/* handle generate report click */
	$('#genreport').click(function() {
		var errors = [];
		if (! $('#product').val() ) {
			if (! $('#allProducts').is(":checked") ) {
				errors.push( "You forgot to choose a product." );
			}
		}
		if (! $('#operator').val() ) {
			errors.push( "You forgot to choose an operator." );
		}
		if ( errors.length ) {
			alert( errors.join("\n") + "\n\nPlease make the corrections and try again." );
			return false;
		}
		else {
			$("#report, #export").hide();
			$(this).html('Processing, please wait...');
			$('form[name="operatorProfit"]').submit();
		}
	});
});
</script>
</body>
</html>

