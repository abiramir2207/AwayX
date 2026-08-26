<!---
* ====================================================================================================
*    @File: \billbacks\OnePageBillback\index.cfm
*  @Author: Dinesh Rachala
*    @Date: June 2019
*
* @Remarks: OnePageBillback Settlements page - main file
*
* ====================================================================================================
--->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Settlements</title>
	<cfsavecontent variable="head_content">
		<cfset request.noty_version = "3">
		<cfset jQueryUI.widgets = "datepicker">

		<cfinclude template="/common_files/jQuery.cfm">
		<cf_include files="/Common_Files/dhx_message.cfm, /common_files/tailwind-css.cfm, /common_files/noty.cfm">
		<cf_include files=" /styles/fontawesome/5.8/all.css, /styles/OnePageBillback.css, /styles/resize.css, /script/javascript/multipleselect/1.2/multiple-select.css">
		<cf_include files="/script/javascript/multipleselect/1.2/multiple-select_bsa.js, /script/javascript/moment.min.js, /script/javascript/numeral.min.js, /script/javascript/jquery-resizable.js">

		<cfset appSettings = CreateObject("component", "components.settings.ApplicationSettingsManager").get(0) />
  </cfsavecontent>
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>

<body>
	<cfset request.ag_grid_version = "23">
	<cfset request.ag_grid_theme = "ba-ag-theme-balham">
	<cf_include files=#arrayToList( [
		"/common_files/ag-grid.cfm"
		,"/Common_Files/tabnavDynamic.cfm"
		,"/common_files/dropzone.cfm"
		,"/styles/ba_upload.css"
] )#>

	<cfset MCObject = createObject("Component","components.Match_Central.MatchCentral").init()>
	<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
	<cfset businessSegmentsOn = 'false' />
	<cfif businessSegManager.isEnabled()>
		<cfset businessSegmentsOn = 'true' />
	</cfif>

	<cfquery name="cTempTables" datasource="#application.datasource#">
		IF OBJECT_ID('tempdb..##tmp_OPB_Detail') IS NOT NULL
		DROP TABLE ##tmp_OPB_Detail
	</cfquery>

<!--- Whole document --->

<div id="page-container">
	<!----- LEFT PANE ----->
	<fieldset id="left-pane" class="p-0" style="margin: 0 5px 0 2px;">
		<div class="header-box">
			<span class="font-bold">Search</span>
				<span style="padding: 0 0 0 5px">
					<i class="fa fa-info-circle btn-icon" id="selectedOptions" title="Select filters to search" style="font-size:12px"></i>
				</span>
			<a id="hide-left-button" class="header-box" href="#" onclick="hideLeftPane();return false;"><i class="fa fa-angle-double-left btn-icon-enlarged"></i></a>
		</div>
		<cfinclude template ="/billbacks/OnePageBillback/opb_search_filters.cfm">
	</fieldset>
	<!----- RIGHT PANE ---->
	<fieldset id="right-pane">
		<div class="header-box">
			<a id="options-button" class="header-box" href="#" onclick="showLeftPane();return false;"><i class="fa fa-angle-double-right btn-icon-enlarged"></i></a>
			<!--- Navigation  ----->
			<div class="navi" id="navList">
				<a href="##" id="createId" name="create" class="active" onclick="activateTab( 'create' )">Create</a>
				<a href="##" id="processId" name="process" onclick="activateTab( 'process' )">Process</a>
			</div>
		</div>
		<!--- Tabs Content  ---->
		<div id="allTabContent" style="height:100%">	<!--- id is required to support adding dynamic content in this div --->
			<div id="create" class="active">
				<!--- render Programs --->
				<cfinclude template="opb_create_bb.cfm">
			</div>
			<div id="process">
				<!--- define hidden Matches elements --->
				<cfinclude template="opb_process_bb.cfm">
			</div>
		<!--- Dynamic tab content are divs appended to the "allTabContent" area --->
	</div>
	</fieldset>
</div>

<script>
	// Default to the first tab open
	document.getElementById("programTab").click();
	$( "#billbackTab" ).addClass( "disabled" );
	//$( "#deductionTab" ).addClass( "disabled" );
	$(".assign").css('height','95vh');
	$(".bbSection").css('width','100%');

		/* Show/Hide the left pane */
		function hideLeftPane() {
			// Animate via changing margin to negative #
			let border_width = 3,
				filtersWidth = $("#left-pane").width() + border_width;
				$("#left-pane").css("margin-left", "-"+filtersWidth+"px");
				// Show the link for un-hiding the Left pane
				$("#options-button").css("display", "block");
				$("#options-button").css("cursor", "pointer");
		};

		function showLeftPane() {
			let border_width = 3;
			$("#left-pane").css("margin-left", border_width+"px");
			// Hide the "Options" link when the Left pane is open
			$("#options-button").css("display", "none");
			$("#options-button").css("cursor", "default");
		};

		$("input:radio[name=match_deduction]").click(function() {
			hideDDSection( $(this).val() );
		});

	function hideDDSection(val){
		if(val =='1'){
			$(".assign").css('height','70vh');
			$(".bbSection").css('width','50%');
			$( ".splitter, .splitter-horizontal" ).show();
			$( "#deductionTab" ).show();
			$( "#ddSection" ).show();
			$( "#matchSection" ).show();
		}else{
			$(".assign").css('height','95vh');
			$(".bbSection").css('width','100%');
			$( ".splitter, .splitter-horizontal" ).hide();
			$( "#deductionTab" ).hide();
			$( "#ddSection" ).hide();
			$( "#matchSection" ).hide();
		}
	}

	$(document).ready(function() {
			initTabs('#navList');
		});

		 /* page tab event */
		function activateTab( new_tab ) {
			var CSearch = $('#customer_search').val();
			if(new_tab == 'process'){
				$( "#billbackTab" ).removeClass( "disabled" );
				$( "#deductionTab" ).removeClass( "disabled" );
				$( "#programTab" ).addClass( "disabled" );
				document.getElementById("billbackTab").click();
				if(CSearch.length){
					$("input[name=bb_customer_search]").val(CSearch);//BILLBACK CUSTOMER SEARCH
					BBvalidate();
					//$("input[name=dd_customer_search]").val(CSearch);//DEDUCTION CUSTOMER SEARCH
				}
			}else{
				$( "#billbackTab" ).addClass( "disabled" );
				$( "#deductionTab" ).addClass( "disabled" );
				$( "#programTab" ).removeClass( "disabled" );
				document.getElementById("programTab").click();
			}
		}
</script>

    <cfinclude template="/common_files/focus.cfm">
</body>
</html>