<cfsilent>
<!---
* ==================================================================================================== 
*    @File: billbacks\Deviation\Deviation_Main.cfm
*  @Author: Sharon Harris
*    @Date: 29-Apr-2019
* 
* @Remarks: Main entrance to the Billback Devations page - replacing the Flex app
*           
*			See old FlexDev\BillbackDevApp\src\com\views\BBMainPanel.mxml
*
* ==================================================================================================== 
--->
</cfsilent>
<!doctype html>
<html lang="en">
<head>
	<title>Billback Deviations</title>
	<cfsavecontent variable="head_content">
	<style>
		html, body {
			margin: 0;
			/* overflow: auto; */
            padding: 0;
			width: 100%
		}
		#app {
			height: 97vh;
		}
        legend {
            font-size: 11px;
            font-weight: 600;
        }

		.text-xxs {
			font-size: .55rem;
		} 
		.card {
			background-color: #fff;
			border-radius: 3px;
			box-shadow: 1px 2px 2px rgba(0,0,0, 0.3), -1px 0 2px rgba(0,0,0, 0.4);
		}
		.card input,
		.card label {
			display: inline-block;
			vertical-align: middle;
		}
		.btn-icon { color: #406be4; }

		/* Restore outline for focus since users may want to tab through the buttons */
		button.button:focus {
			outline: 1px solid #0091ea !important;
		}

		/* FAKE approve COLORS - PULL FROM SETTINGS INSTEAD */
		/* .color-1 { background-color: #dfedd6 !important; } */
		/* .color-2 { background-color: #aaaaaa !important; } */
		/* .color-3 { background-color: #fef67f !important; } */
		/* .color-4 { background-color: #a8c6fa !important; } */
	</style>
    </cfsavecontent>
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>

<body>
<cfset BillbackDevAppManager = CreateObject("component","mvc.models.Billback.BillbackDevAppManager")> 
<cfset appSettings = application.appSettingsGet>


<cfparam name="url.FromDupScreen" default="0">
<cfparam name="form.Submitted" default="0">
<cfparam name="url.caller" default="0">
<cfparam name="url.source" default="0">
<cfparam name="form.actionType" default="">
<cfparam name="form.BillbackOperatorLocationDetailID" default="">

<cfset sCallerSource = url.source>

<cfset parentRefresh = 'NONE' />
<cfif (isDefined("CGI.HTTP_REFERER") AND Findnocase("SECTION_TO_OPEN",CGI.HTTP_REFERER,1) GT 1)>
	<cfset parentRefresh = 'REFRESH' />
</cfif>

<!--- Include file which has the logic to validate the user --->
<cfinclude template="initial_check.cfm">

<!--- Check is access is allowed.
Note: Below arguments are only needed for the "BB Operator Location Level" feature.
url.FromDupScreen,form.Submitted,form.actionType,form.BillbackOperatorLocationDetailID
--->
<cfset strAccessAllowed = showDeviationScreen(url.bbid,url.FromDupScreen,form.Submitted,url.caller,form.actionType,form.BillbackOperatorLocationDetailID)>

<!---  If deviation cannot be run --->
<cfif strAccessAllowed.UpdMessage neq "">
<br><br><br><br>
<div align="center">
	<span style="color:red;font-size:12px;"><cfoutput>#strAccessAllowed.UpdMessage#</cfoutput> is in progress. Cannot Run Deviation.</span>
</div>
<CFABORT>
<!--- If access is not allowed --->
<cfelseif strAccessAllowed.iAccessError eq 1>
<br><br><br><br>
<div align="center">
	<span style="color:red;font-size:12px;"><cfoutput><strong>#strAccessAllowed.strShowError#</strong></cfoutput></span>
<br><br>
	<input type="button" onclick="javascript:window.close();" title="Close window" value="Close window">
</div>
<CFABORT>
</cfif>

<cfset qryBillbackHeader =  BillbackDevAppManager.getBillbackHeader(BBID = url.bbid,UserId= request.AccessStructure.User_ID)> 

<!--- /* Setup Approve button colors from Settings */ --->
<!--- /* must remove the leading "0x" - bad format for css */ --->
<cfscript>
	CSSbg1 = replace (qryBillbackHeader.ExpBtnBgColor, '0x', '');
	CSSbg2 = replace (qryBillbackHeader.EltBtnBgColor, '0x', '');
	CSSbg3 = replace (qryBillbackHeader.ClmBtnBgColor, '0x', '');
	CSSbg4 = replace (qryBillbackHeader.SelBtnBgColor, '0x', '');
</cfscript>
<style>
	<cfoutput> 
	<!--- Must set the font color dark or light depending on background color --->
	.color-1 { background-color: ###CSSbg1# !important; color: #application.util.string.foregroundColor( CSSbg1 )# !important; }
	.color-2 { background-color: ###CSSbg2# !important; color: #application.util.string.foregroundColor( CSSbg2 )# !important; }
	.color-3 { background-color: ###CSSbg3# !important; color: #application.util.string.foregroundColor( CSSbg3 )# !important; }
	.color-4 { background-color: ###CSSbg4# !important; color: #application.util.string.foregroundColor( CSSbg4 )# !important; }
	</cfoutput> 
</style>

<cfset iBBDevOverridePrice = 0 />
<cfif appSettings.getBB_Deviations_Override_Price() eq 1 OR qryBillbackHeader.BB_Level_Deviations_Override_Price_Flag eq 1>
	<cfset iBBDevOverridePrice = 1 />
</cfif>

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
    <cfset request.noty_version = "3">
	<cf_include files="/common_files/tailwind-css.cfm, /common_files/noty.cfm, /styles/css-loader.css">
	<div class="customContainer" style="display:none;"></div>

	<cfset jQueryUI.widgets = "tooltip">
	<cfset request.ag_grid_version = "20">
	<cfset request.ag_grid_theme = "ba-ag-theme-balham">
	<cf_include files=#arrayToList( [	
									"/common_files/jQuery.cfm",
									"/common_Files/ag-Grid.cfm",
									"/script/javascript/jquery.noty.packaged.min.js",
									"/styles/font-awesome.min.css",
									"/script/javascript/numeral.min.js"
									 ])#>
	<style>
		<!--- override the ag-grid styles included above --->

		.ag-theme-balham {
			font-size: 11px;
		}
		.ag-header {
			font-size: 11px !important;
			text-align: center;
		}
		.ag-theme-balham .ag-cell {
			line-height: 12px;
			/* padding-left: 4px; */
			padding-right: 3px;
			/* margin-top: 1px; */
		}
		.ag-theme-balham .ag-header-cell-label {
			width: 100%;	/* work around ag-grid bug #2328 which leaves space for menu icon */
		}
		.ag-theme-balham .ag-row-selected {
			border-bottom-color: #b5b5b5; /* don't hide lines when selected */
		}
		.ag-theme-balham .ag-selection-checkbox span {
			left: 2px; /* center the checkbox */
		}

		.ag-theme-balham .ag-header-group-text, 
		.ag-header-cell-text {
			margin: 0px auto 0px auto;		/* Center the header text */
		}

		.ag-theme-balham .ag-icon-asc,
		.ag-theme-balham .ag-icon-desc {
			width: 6px;
		}

		/* ------ non-group line tweaks: remove mid horizontal line for non-group headers - from ag-grid ticket */
		/* .ag-root.ag-layout-normal, .ag-root.ag-layout-auto-height, .ag-header, .ag-pinned-left-header, .ag-pinned-right-header, .ag-header-viewport, .ag-header-group-cell-no-group, .ag-header-group-cell-with-group { */
			/* overflow: visible !important; */	/* not needed? and breaks pinned scrolls */
		/* } */
		.ag-header-group-cell-no-group {
			background: #FFCE84;
			/* height: calc(100% + 1px) !important;	/* +1 to overwrite the line */ /* This has a bug, it does not extend the height of the resize line */
			height: calc(170%);
			/* z-index: 1; */
			overflow: visble;
		}
		.ag-header-cell-resize {
			content: '';
			position: absolute;
			top: 0;
			right: 0 !important;
			margin: 0 !important;
			
			/* width: 1px !important; */	/* too small to grab easily */
			/* background: #9B9B9C; */

			width: 4px !important;			/* so make it wider, change the background color to match the hdr, and add a thin border */
			background: #ffce84;
			border-right: 1px solid #9b9b9c;
		}
		/* ------ end of non-group line tweaks */


		/* make long non-group header labels wrap */
		.ag-theme-balham .custom-header .ag-cell-label-container {
			height: calc(180%);
		}
		.ag-theme-balham .ag-header-cell-label .ag-header-cell-text {
			white-space: normal;	/* let the header wrap (need taller height) */
			/* z-index: 2;	*/			/* needed, to be in front of ag-header-group-cell-no-group (above) */ 
		}
		.ag-theme-balham .ag-header-icon {
			/* z-index: 2; */				/* needed, to be in front of ag-header-group-cell-no-group (above) */ 
		}

		/* Vertically raise the non-grouped header text */
		.custom-header {
			/* top: -32px; */	/* with default groupHeaderHeight */
			top: -42px;
		}
		.custom-header .ag-cell-label-container {
			margin-top: 15px;
			line-height: 12px;
		}
		.custom-header:after {
			height: 100px !important;
		}

		.ag-header-group-cell-with-group {
			cursor: default;
		}
	</style>



	<cfset isDuplicate = "hidden">	<!--- show if sBBAllDupGroupID != null --->

	<!---------------------->
	<!--- Whole document --->
	<!---------------------->
	<!--- The "save_message" div will be used to show messages to the user --->
	<div class="save_message"></div>
    <div id="app" class="bg-grey-lightest h-screen">	
		<!------------------------------------>
		<!--- Header - with Billback Info  --->
		<!------------------------------------>
		<div id="header" class="flex justify-between bg-blue-darkest font-semibold mb-1 p-2 text-sm text-white">
			<cfoutput>			
				<span>DEVIATIONS</span>
				<span class="text-center">
				#qryBillbackHeader.BB_code# &nbsp;&nbsp;|&nbsp;&nbsp; 
				#qryBillbackHeader.Payee_Name# &nbsp;&nbsp;|&nbsp;&nbsp; 
				#qryBillbackHeader.BB_Title#
				 </span>
				<span class="text-right tracking-wide">#qryBillbackHeader.BB_Start_Date# - #qryBillbackHeader.BB_End_Date#</span>
			</cfoutput>
		</div>

		<!--------------------------------->
		<!------- TOOL CARDS SECTION ------>
		<!--------------------------------->
		<div id="tools" class="xl:flex mx-1 text-sm text-black">
			<div class="md:flex">	<!--- for mid-sized screens, break into two columns of 2 cards each --->
				<!--- Card # 1   ACTIONS section --->
				<div class="card flex mb-1 mr-2 px-2 py-1">

					<div class="flex-column mr-1">
						<div class="<cfoutput>#isDuplicate#</cfoutput> text-red" id="txtDuplicate">
							* Duplicate Billback *
						</div>
						<p class="text-xxs">
							<span>Delivery Period:</span>
							<br>
							<cfoutput>
								<span class="leading-none text-xxs tracking-wide">#qryBillbackHeader.BB_Start_Date# - #qryBillbackHeader.BB_End_Date#</span>
							</cfoutput>
						</p>
						<button type="button" id="btnSave" name="save" onClick="fnDoActions(this)" class="button recommended" title="Save changes made to the Grid" style="margin: 4px 0 0 0">Save changes</button>
					</div>
					
					<div class="flex-column mr-1">
					<cfif Get_Profile_Settings.BB_Rate_Override eq 1 
					AND iBBDevOverridePrice eq 0
					AND qryBillbackHeader.Billback_Status_ID eq 2>
						<button type="button" id="btnRateOverride" name="override-1" class="button" title="Rate Override" style="margin: 0 0 4px 0" onClick="fnRecalculate('','fnRateOverride',0)">Rate Override</button>
						<br>
					</cfif>
					<cfif appSettings.getBBOverlapDeviationBasedOnOperator() EQ 1>
					<cfoutput>
						<button type="button" class="button" title="Download Overlap Report" style="margin: 0 0 0 0" onClick="fnOverLapReport('#url.bbid#')">Overlap Report</button>
					</cfoutput>
					</cfif>
					</div>
					<div class="flex-column mr-1">
					<cfif Get_Profile_Settings.BB_Volume_Override eq 1 AND qryBillbackHeader.Billback_Status_ID eq 2>
						<button type="button" id="btnVolOverride" name="override-2" class="button" title="Volume Override" style="margin: 0 0 4px 0" onClick="fnRecalculate('','fnVolOverride',0)">Volume Override</button>
						<br>
					</cfif>
					<!--- <cfif appSettings.getBBOverlapDeviationBasedOnOperator() EQ 1> --->
						<cfoutput>
						<button type="button" id="btnDownloadData" class="button" title="Download Deviations Data" style="margin: 0 0 0 0" onClick="fnDownloadDeviation('#url.bbid#','#request.AccessStructure.User_ID#')">Download</button>
						</cfoutput>
					<!--- </cfif> --->
					</div>
					<cfif qryBillbackHeader.Billback_Status_ID eq 2>
					<div class="flex-column">
						<button type="button" id="btnRecalc" name="recalc" onClick="fnDoActions(this)" class="button" title="Recalculate Deviations" style="margin: 0 0 4px 0">Recalc Deviations</button>
						<br>
					</div>
					</cfif>
				</div>

				<!--- Card # 2   APPROVE section --->
				<div class="card mb-1 mr-2 pt-2 px-2">
					<div class="flex text-xs">
						<div class="flex-column mr-1">
							<div> <br>APPROVE </div>
						</div>
						<cfoutput>
							<div class="flex-column mr-2">
								<div id="expectedDollars" class="text-center"></div>
								<button type="button" id="btnExpectedAmt" name="approval-1" onClick="fnExpectedAmountClicked(this);" class="button color-1" title="Select the Expected amount, Save and Approve" style="margin: 5px 0 5px 0">
										Expected $</button>
							</div>
							<cfif iBBDevOverridePrice eq 0 AND appSettings.getBB_Approve_Expected_Rate_Less_Tolerance() eq 1>
							<div class="flex-column mr-2">
								<div id="expectedLTDollars" class="text-center"></div>
								<button type="button" id="btnExpectedAmtLT" name="approval-2" onClick="fnExpectedAmountLTClicked(this);" class="button color-2" title="Select the Expected amount Less Tolerance, Save and Approve" style="margin: 5px 0 5px 0">
									Expected $ LT</button>
							</div>
							</cfif>
							<div class="flex-column mr-2">
								<div id="claimedDollars" class="text-center"></div>
								<button type="button" id="btnClaimedAmt" name="approval-3" onClick="fnClaimedAmountClicked(this);" class="button color-3" title="Select the Claimed amount, Save and Approve" style="margin: 5px 0 5px 0">
									Claimed $</button>
							</div>
							<div class="flex-column mr-2">
								<div  id="approvedDollars" class="text-center"></div>
								<button type="button" id="btnApprove" name="approval-4" onClick="fnSelectedAmountClicked(this);" class="button color-4" title="Save and Approve" style="margin: 5px 0 5px 0">
									Selected $</button>
							</div>
						</cfoutput>
						<cfif Get_Profile_Settings.BB_Approve eq 1 AND qryBillbackHeader.Billback_Status_ID eq 2>
						<div class="flex-column">
							<button type="button" id="btnDisagree" name="approval-5" onClick="fnDisagreeClicked()" class="button" title="Disagree" style="margin: 5px 0 0 0">
								Disagree</button>
						</div>
						</cfif>
					</div>
				</div>
			</div>
			<div class="md:flex">

				<!--- Card # 3   FILTER section--->
				<div class="card mb-1 mr-2 pb-1 pt-2 px-2 text-xxs">
					<input type="checkbox" id="cbShowDeviated">
					<label for="cbShowDeviated">show deviated only</label>					
				</div>

				<!--- Card # 4   BB Operator Location Duplicate Check Section --->
				<cfif appSettings.get_Setting('BB_Oper_Location_Level_Dup_Checker') eq 1>
					<div class="card mb-1 mr-2 px-2 py-1">
						<p class="leading-loose text-xxs">
							<span class="font-semibold">Details</span>
							<!--- <span style="padding: 0 0 0 5px"> --->
								<i class="fa fa-info-circle btn-icon pl-1" style="font-size:12px" title="Records that were denied via the Double Dip feature are set to be approved for $0.00 and are represented below with orange highlights."></i>
							<!--- </spanS> --->
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<!--- If the user visits this page from "BBOperLocationDupChecker.cfm", then "form.actionType" has a value. If that is not the case, then the "report" link will be disabled. --->
							<span class=""><button type="button" class="button minor" id="btnBack" 	<cfif form.actionType eq "">disabled="disabled"</cfif> style="cursor:pointer;" onClick="fnBackToDDReport()" title="Double Dip Report">Report</button></span>
							<br>
							<cfoutput>
							Actual: <span id="actualDollars"></span> &nbsp;&nbsp; | &nbsp;&nbsp;  Denied: <span id="deniedDollars"></span>
							</cfoutput>
							<br>
						</p>
					</div>
				</cfif>
			</div>
		</div>		


		<!----------------->
		<!--- MAIN GRID --->
		<!----------------->
		<div id="Deviations_Grid" style="height:450px;" class="ag-theme-balham ml-1 mt-2"></div>
			<cfinclude template="/billbacks/Deviation/Deviation_Main_Grid.cfm">
		</div>


    <!-------------------------------------------------------------------------------------->
    <!--------------------------------- SCRIPTS -------------------------------------------->
    <!-------------------------------------------------------------------------------------->
	<!--- (Start) - Below code has been added for calling Ajax functions on "BillbackAjaxManager.cfc" --->
	<script type='text/javascript'>	
	   	_ajaxConfig = {'_cfscriptLocation':'/components/billback/BillbackAjaxManager.cfc','_jsscriptFolder':'/script/javascript/Ajax_JS/','debug':false};
	</script>
	<script type='text/javascript' src='/Script/javascript/Ajax_JS/ajax.js'></script>
	<!--- (End) - Below code has been added for calling Ajax functions on "BillbackAjaxManager.cfc" --->

	<script>
		set_grid_full_height("Deviations_Grid");
		$(window).resize(function(){ set_grid_full_height("Deviations_Grid"); });


		// wait for the document to be loaded, otherwise ag-Grid will not find the div in the document.
		document.addEventListener("DOMContentLoaded", function () {
			Build_DeviationsGrid();
			loadDeviationData();
			/* If the grid is not editable, disable the buttons */
			if(editableGrid == false){
				disableApprovalButtons();
			}
		});

		$('#cbShowDeviated').change(function() { 
			Deviations_GridOptions.api.onFilterChanged();
		});

		// Disable all the buttons in the Approval section
		function disableApprovalButtons() {
			var elems = document.querySelectorAll('[name^="approval-"],[name^="override-"],[name="recalc"],[name="save"]');
			for (var i = 0; i < elems.length; i++) {	
				elems[i].classList.add ("disabled");		
			}

			// Remove the "color-" classes from the buttons so they look disabled grey
			// code from: https://stackoverflow.com/questions/28608587/how-to-remove-a-class-that-starts-with
			$("button[class*='color-']").removeClass (function (index, css) {
				return (css.match (/(^|\s)color-\S+/g) || []).join(' ');
			});
		}
		
		/*
		When a user opens the deviation screen from the billback scorecard and then going through the approval process by clicking on "Claimed $" 
		or "Expected $" or "Expected $ LT" or "Selected $" buttons.Below function refreshes the billback scorecard by removing the current billback 
		(billback user is working on) from the billback scorecard.
		*/
		function refreshParent() 
		{
			var i = window.opener.location.href.indexOf('&filterIds');
			var n = window.opener.location.href.length;
			var str = window.opener.location.href.substring(i, n);
			window.opener.location.href.replace(str, '');
			window.opener.location.href += "&filterIds=<cfoutput>#URL.bbid#</cfoutput>";
		}

		
		/* This method works for both -  "IE 11 and Chrome". For some reason, "$.ajax" code does not work */
		window.onbeforeunload = function callback(){
			DWREngine.setAsync(false);
			<cfoutput>
			DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'unlockDeviationGridLock' ,'#URL.bbid#','#request.AccessStructure.user_id#',responseFunc);
			</cfoutput>
		
			/* close popups created by this page */
			for (var i = 0; i < popups.length; i++) {
				popups[i] && popups[i].close();
			}
		};

		function responseFunc(response){
			// do nothing
		}

    </script>

	<cfinclude template="/Common_Files/focus.cfm">
</body>
</html>