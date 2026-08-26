<!----------------------------------------------------------------------------------------------------------------------------------
Template     : /Programs/upload/import.cfm
Copyright    : (c) 2018 Blacksmith Applications, Inc.
Created Date : 08/31/2018
Created By   : Kal
Purpose      : Import programs from Excel XLSX file
----------------------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<html lang="en">
	<head>
		<cfsavecontent variable="head_content">
			<meta charset="utf-8">
			<meta http-equiv="X-UA-Compatible" content="IE=edge">
			<cf_include files="/styles/css-loader.css">
			<style>
				div.header {
					height: 27px;
					margin:0 0 15px 0;
					background-image: linear-gradient( to right, #010281, #A7CAF2 );
					color: white;
					font-size: 14px;
					font-weight: bold;
					letter-spacing: 0.75px;
					padding:8px 0 0 8px;
				}
				.instructions {
					color: #000080;
					font-size: 13px;
					float: right;
					margin-right: 10px;
					padding-left: 30px;
				}
				.subtable { margin:10px; width:50% }
				#upl18 { font-size: 14px;	margin:15px; }
				.Title2, select#template, select#businessSegment { margin-left: 15px; }
				select#template, select#businessSegment { margin-top: 2px; padding: 2px;}

				.sectionHeader {
					background-color: #edeef2;
					border:1px solid #d8d9dd;
					color: #343540;
					cursor: pointer;
					line-height: 24px;
					text-align: left;
					transition: 0.4s;
					width: 100%;
				}
				.sectionHeader:hover {
					background-color: #FFF;
					border: 1px solid #406be4;
				}
				.section {
					background-color: #fff;
					display: none;
					opacity: 0.75;
					padding: 5px;
				}
				.dataTables_wrapper {
					min-height: 100px !important;	/* default is too big */
				}
				.copyButton {
					background-color: #fff;
					background-image: url("/images/clipboard-blk-12.png");
					background-repeat: no-repeat;
					border: none;
					cursor: pointer;
					height: 12px;
					width: 12px;
				}
				.copyButton:hover,
				.copyButton:focus {
					background-image: url("/images/clipboard-blue-12.png");
				}
				.spinner{
					margin-left: 20px;
					display: none;
				}
				.sectionLoader {
					margin-left: 20px;
				}

				/* Create two column flexible layout */
				.row {
					display: flex;
					padding-left: 20px;
					padding-top: 5px;
				}
					.row > *:nth-child(1) {
						width: calc(100% / 3 * 1);		/* 1st column takes 1/3 of space */
					}
					.row > *:nth-child(2) {
						width: calc(100% / 3 * 2);		/* 2nd column takes 2/3 of space */
					}
					
					.hideDisplay{
						display: none;
					}

			</style>


		</cfsavecontent>
		<cfsavecontent variable="clickToCopy"> <span class="forceRight"> <button id="compButton" class="copyButton" title="click to copy" onclick="copyTextFn(this)"</button></span> </cfsavecontent>

		<cfset local.arrowDown = "/images/arrow-d-blue-12.png" />
		<cfset local.arrowRight = "/images/arrow-r-blue-12.png" />

		<!--- Dropzone.js open source library is used for the file upload --->
		<cf_include files=#arrayToList( [ "/common_files/dropzone.cfm", "/styles/ba_upload.css" ] )#>
		<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead i, C:\Work\AwayX\Script\javascript\string_functions.jsn Application_Common.cfm --->
		<cfhtmlhead text="#application.util.string.compress( head_content )#">
	</head>
	<body>
		<cfset jQueryUI.widgets = "tooltip">
		<cf_include files=#arrayToList( [ "/common_files/jQuery.cfm",
											"/common_files/jQueryUI.cfm",
											"/common_files/dhx_message.cfm",
											"/styles/css-loader.css",
											"/common_files/datatable.css",
											"/common_files/dataTables2.cfm",
											"/script/javascript/string_functions.min.js"
											] )#>

		<cfscript>
			genSettingsManager     = CreateObject("component", "components.settings.ApplicationSettingsManager").init();
			templateManager        = createObject("component", "components.programs.template.TemplateManager");
			userManager            = createObject("component", "components.user.UserManager");
			profile                = createObject("component", "components.user.Profile");
			businessSegmentManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager");
			
			appSettings            = genSettingsManager.get();
			businessSegments	   = businessSegmentManager.getUploadBusinessSegments();

			if (Len(Trim(appSettings.getbusiness_segment_label() )) > 0) {
				businessSegmentLabel  = appSettings.getbusiness_segment_label();
			} 
			else {
				businessSegmentLabel  = "Business Segment";
			}

			// templates
			getAllTemplates        = templateManager.getAllTemplates();
			allTemplates           = templateManager.getAll();
			templates              = (isDefined("variables.getAllTemplates") ? getAllTemplates : allTemplates);
			discountTypeList       = templateManager.getComponentDiscountTypeList();


			// get user positions id & rsp list
			qGetProfileSettings    = profile.getProfileSettings(request.AccessStructure.Profiles_ID);
			userId 		           = request.AccessStructure.User_ID;
			rspList                = userManager.getRSPList(userId, qGetProfileSettings.Program_Scorecard_Restrict_Created_By, 1);

		</cfscript>

		<!-------------------->
 		<!--- Page Display --->
		<!-------------------->
		<div class="header"> PROGRAM UPLOAD </div>
		<div>
			<span class="Title2"> Choose a <cfoutput>#businessSegmentLabel#</cfoutput>:</span>

			<a class="instructions" href="##" onClick="javaScript: uploadInstructionsWindow();return false;" TITLE="Program Upload instructions">
				Instructions to Upload Programs
			</a>

			<a class="instructions" href="ProgramUploadSample.xlsx" target="_blank" title="Download sample spreadsheet">Sample file</a>
		</div>
		<div>
			<select autofocus id="businessSegment" onchange="businessSegmentChange()" class="Title6">
				<option value="0" id="0">Choose one</option>
				<cfoutput query="businessSegments">
					<option value="#Business_Segment_ID#">#Business_Unit_Desc#</option>
				</cfoutput>
			</select>
		</div><br>

		<div class="Title2"> Choose a template:</div>
		<div>
			<select autofocus id="template" onchange="templateChange()" class="Title6">
				<option value="0" id="0">Choose one</option>
				<!---
				<cfoutput query="templates">
					<option value="#PROGRAMCONTROL_PANEL_OPTIONS_ID#">#created_type#</option>
				</cfoutput>
				--->
			</select>
		</div>

		<!--- begin of Dropzone upload --->
		<br>
		<div id="upl18">
			<!------------- Dropzone area ------------->
			<div id="myDropId" class="dropzone dz-clickable hideDisplay">
				<div class="dz-message">
					<img class='ba-dz-message' src='/Images/cloud_343540.svg'>
					&nbsp; Drop Excel file here or
					<span style="color:blue">click to upload</span>
				</div>
			</div>
			<!------------- File list Results area ------------->
			<div class="upl-table" id="previews" style="max-width:600px;">
				<!--- upload result gets put here via shared template --->
			</div>
			<br><br>
		</div> <!-- #upl18 -->

		<!------------- Dropzone setup ------------->
		<script>
			// <!--- callbacks --->
			doneUploading2 = function(){
				window.close();
			}

			postProcessing = function(good_responses){
				var templateId = $("#template option:selected").val();
				var businessSegmentId = $("#businessSegment option:selected").val();
				
				if (good_responses[0].length) {
					$.getJSON (
						'/mvc/Models/Program/Upload/ProgramUploadManager.cfc',
						{
							method : "fnDataInsert",
							templateId : templateId,
							filePath : good_responses[0],
							busSegment : businessSegmentId,
							creatorId : '<cfoutput>#request.AccessStructure.user_id#</cfoutput>',
							returnFormat : "json"
						},
						// success
						function(batchId){
							$(".spinner").toggle();
							validateData(batchId); // call to validate data
						} //success
						//) .error( function(mydata){ console.log( mydata ); } // handler for upload fail if necessary
					); // $.getJSON
				}
			}

			// call to validate the data
			validateData = function(batchId){
				$.getJSON (
					'/mvc/Models/Program/Upload/ProgramUploadManager.cfc',
					{
						method : "validateUpload",
						batchId : batchId,
						returnFormat : "json"
					},
					// success
					function(mydata){
						// validate on success (mydata = 1) calls execute otherwise email error report
						if(mydata==1){
							executeData(batchId);
						}else{
							// call error report
							validateErrorReport(batchId);
						}
					} //success
				); // $.getJSON
			}

			// call to execute the data
			executeData = function(batchId){
				$.getJSON (
					'/mvc/Models/Program/Upload/ProgramUploadManager.cfc',
					{
						method : "exceuteUpload",
						batchId : batchId,
						returnFormat : "json"
					},
					// success
					function(mydata){
						$(".spinner").toggle();

						var msg = 'You will receive an email with a report.';
						dhtmlx.alert({
							title:"Success",
							type:"confirm",
							text: msg,
							callback:function(response){
								window.location = "/programs/upload/index.cfm";
							} // callback
						}); // dhtmlx.alert

						// email the upload report
						emailReport ( mydata,
													'<cfoutput>#request.AccessStructure.user_email#</cfoutput>',
													'Uploaded Programs report attached!'
												);
					} //success
				); // $.getJSON
			}

			// call to email and download the validate error report
			validateErrorReport = function(batchId){
				$(".spinner").toggle();
				$.getJSON (
					'/mvc/Models/Program/Upload/ProgramUploadManager.cfc',
					{
						method : "getValidateReport",
						batchId : batchId,
						returnFormat : "json"
					},
					// success
					function(mydata){
						var msg = 'Uploaded file has errors. <br/> Download error report?';		
						dhtmlx.confirm({
							title:"Error",
							type:"alert-error",
							text: msg,
							ok: "Download",
							cancel: "Cancel",
							callback:function(response){
								if( response ){
									downloadReport(mydata);
								}
								window.location = "/programs/upload/index.cfm";
							} // callback

						}); // dhtmlx.confirm

						// email error report
						emailReport ( mydata,
							'<cfoutput>#request.AccessStructure.user_email#</cfoutput>',
							msg);
					} //success
				); // $.getJSON
			}

			// call to email and download the validate error report
			emailReport = function(filePath, userEmail, msg){
				$.getJSON (
					'/mvc/Models/Program/Upload/ProgramUploadManager.cfc',
					{
						method : "emailReport",
						filePath : filePath,
						userEmail : userEmail,
						emailMessage : msg,
						returnFormat : "json"
					}
				); // $.getJSON
			}

			// dowload validation error report
			downloadReport = function(filePath){
				NewWindow ("/getdocument.cfm?filepath="+filePath, "download", 400, 300);
			}

			setupDropzone(
				"ajax/import.cfm",	//upload url
				doneUploading2,	//callback after acknowledging completion
				1, 		// max files
				10,		// max size MiB
				"application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", 	// only accept Excel file types sa xls, xlsx
				postProcessing,	// process after upload
				true	// no alert msg on success, wait for validation
			);
		</script>
		<!--- end of Dropzone upload --->

		<cfset sectionHeaders = [
			{ id="rsp", title="RSP &amp; POSITIONS", content="rspContent" },
			{ id="comps", title="COMPONENTS", content="compsContent" },
			{ id="template", title="TEMPLATE RULES", content="templateContent" }
		]>

		<div id="spinner" class="spinner"> VALIDATING UPLOAD... <img src="/Images/ajax-loader.gif"/> </div>
		<br>

		<div id="templateDetail" class="hideDisplay">
			<hr class="six">
			<div class="Title5">Detail Information </div><br>
			<cfoutput>
				<cfloop array="#sectionHeaders#" index="section">
					<!---  section heading  --->
					<button id="#section.id#" class="sectionHeader">
						<img src="#local.arrowRight#" alt="expand/collapse"> #section.title#
					</button>
					<div id="#section.id#" class="section">
						<!---  content of the current section  --->
						<cfset loader = "#section.id#"&"Loader">
						<div id=#loader# class="sectionLoader"><img src="/Images/ajax-loader.gif"/></div>
						<cfinvoke method="#section.content#" returnVariable="result"/> #result#
					</div>
					<br><br>
				</cfloop>
			</cfoutput>
		</div>

		<script>
			var arrowDown  = '<cfoutput>#local.arrowDown#</cfoutput>';
			var arrowRight = '<cfoutput>#local.arrowRight#</cfoutput>';
			var discountTypeArray = '<cfoutput>#discountTypeList#</cfoutput>'.split(",");

			
			$('#template').prop( "disabled", true );
			$('#businessSegment').trigger("change");

			function uploadInstructionsWindow(){
				NewWindow('/Programs/upload/uploadInstructions.cfm','upload instructions','970','620','Yes', 'Yes');
			}

			// look for fn in /Script/javascript/string_functions.js
			copyTextFn = function(obj){
				copyObjText( $(obj).closest("td") );
			}
			function closeTemplateDetail(){
				$(".sectionHeader").each( function(){
					$(this).children(0).attr("src", arrowRight);
					$(this).next().css("display", "none");
				});	
			}
			function hideTemplateDetail(){
				$('#templateDetail').hide();
			}
			function showTemplateDetail(){
				$('#templateDetail').show();
			}
			function hideUpload(){
				$('#myDropId').hide();
			}			
			function showUpload(){
				$('#myDropId').show();
			}
					  
			function businessSegmentChange(){
				var businessSegmentId = $("#businessSegment option:selected").val();
				hideTemplateDetail();
				closeTemplateDetail();
				hideUpload();
				if (businessSegmentId > 0) {
					$('#template').empty();
					$('#template').append('<option value="0" id="0">Choose one</option>');

					$.getJSON(
						'/components/programs/template/TemplateManager.cfc',
						{
							method        : "getAllTemplates",
							businessSegmentId    : businessSegmentId,
							uploadFilter		: 1,
							returnFormat	: "json"
						},
						// success
						function(mydata){
							for(var i = 0; i < mydata.DATA.length; i++) {
								//alert( mydata.DATA[i][0]);
								$('#template').append('<option value="' + mydata.DATA[i][0] + '" >' + mydata.DATA[i][3] + '</option>');
							}
							if (i==1) {
								 $('#template').val(mydata.DATA[i-1][0]);	// if only one, auto-select the only option
								 $('#template').trigger("change");
							}
						}
						
					); // $.getJSON
					$('#template').prop( "disabled", false );
				}
			}
			templateChange = function(){
				var templateId = $("#template option:selected").val();
				if (templateId > 0) {
					showUpload();
					showTemplateDetail(); 
				}
				else {
					hideUpload();
					hideTemplateDetail(); 
				}
				closeTemplateDetail();
			}

			// Query for Currency
			<cfset useLakebaseForGetCurrencyTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("currency")>
<cfif useLakebaseForGetCurrencyTypes>
	<cftry>
		<cfset GetCurrencyTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("currency", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "currency_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCurrencyTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCurrencyTypes>
<cfquery name="GetCurrencyTypes" datasource="#application.datasource#">
				SELECT 	*
				FROM 	Currency
				WHERE 	Deleted = 0
				AND 	Active = 1
				ORDER BY Currency_Name
			</cfquery>
</cfif>


			// handlers for clicking section headers
			$( ".sectionHeader" ).on( "click", function() {
				var templateId = $("#template option:selected").val();
				var sectionClicker = $(this).attr("id");
				var imgUrl = $(this).children(0).attr('src');

				if ( imgUrl == arrowDown ) {
					$(this).children(0).attr("src", arrowRight);
				}else {
					$(this).children(0).attr("src", arrowDown);
				}
				$(this).next().toggle();


				if(sectionClicker == 'comps' && $(this).next().css('display') == 'block'){
					compsContent(templateId); // components
				}
				if(sectionClicker == 'template' && $(this).next().css('display') == 'block'){
					templateContent(templateId); // template rules
					revisionContent(templateId); // revision rules included in this section to save screen space
				}
			});

			$('#rspLoader').hide();

			// rsp datatable
			var oTable =  $('#rspContent').DataTable({
				"aaSorting": [ [0, "asc"] ],
				"autoWidth": false,
				"paging": false,
				"processing":true,
				"orderClasses": true,
				"ScrollCollapse": true,
				"sDom": 'fti',
				"columns": [
					  {"bSortable":true, "bSearchable":true }
					, {"bSortable":true,  "bSearchable":true}
					, {"bSortable":true,  "bSearchable":true}
					, {"bSortable":true,  "bSearchable":true} ]
			}) // DataTable



			function getCompsTitle(type) {
				if( type == 1 ){ return 'FIXED PRICE Components' }
				else if( type == 2 ){ return 'REBATE Components' }
				else if( type == 3 ){ return 'LUMP SUM Components' }
				else if( type == 4 ){ return 'GROWTH Components' }
				else if( type == 5 ){ return 'FORMULA PRICING Components' }
				else { return "DISCOUNT "+type.toString() }
			}

			compsContent = function(templateId){

				// remove existing table
				$("#compsContent").html('');
				$('#compsLoader').show();

				// Create a separate table for each discount type
				$.each(discountTypeArray, function(index, element) {
					let compsTableId = "compsContent" + index;
					let headerTitle = getCompsTitle(index+1);
					let html='';

					$.getJSON('/components/programs/template/TemplateManager.cfc',
						{	method : "getAllTemplateDiscountComponents",
							templateId : templateId,
							discountTypeList : element,
							returnFormat : "json"
						},
						// success
						function(mydata){
							if (mydata.DATA.length) {	// if there is anything for this discount type, make a table
								html+='<br><div class="Title6">' + headerTitle + '</div>';
								html+='<table class="dataTable row-border order-column hover datagrid" id="'+compsTableId+'" width="100%">';
									
								$.each(mydata.DATA, function(index, element) {
									html+= '<tr> <td>' + element[7] + '<cfoutput>#clickToCopy#</cfoutput>' + '</td></tr>';
								});
								html+='</table><br>';
								$("#compsContent").append(html);

							} // if any data for this type
						} //success
					); // $.getJSON

				});//for each discount type
				$('#compsLoader').hide();

			} //compsContent



			templateContent = function(templateId){
				$('#templateLoader').show();

				// remove existing table
				$("#templateContent").html('');
				$.getJSON(
					'/components/programs/template/TemplateManager.cfc',
					{
						method         : "getTemplateSettings",
						programtype_id : templateId,
						returnFormat   : "json"
					},
					// success
					function(mydata){
						$('#templateLoader').hide();

						// ---------------------------  UOM   ----------------------------------------------
						let uomIndexes = [88,89,90];
						let uomHeaderDisplayed = false;
						let html = '';
						$.each(uomIndexes, function(index, element) {
							if (mydata.DATA[0][element]) {
								if (!uomHeaderDisplayed) {
									html+='<div class="Title6"> Unit of Measure </div>';
									uomHeaderDisplayed = true;
									html+='<div class="subtable"><table class="dataTable row-border order-column hover datagrid" width="100%">';
								}
								if(index==0) { html+= '<tr>'
									+ '<td> Per <cfoutput>#Application.UOMPoundSingular#</cfoutput>'+ (mydata.DATA[0][96]==2 ? ' (default)':'') +'</td>'
									+ '<td> LB '+ '<cfoutput>#clickToCopy#</cfoutput>' + '</td>' + '</tr>'; }
								if(index==1) { html+= '<tr>'
									+ '<td> Per <cfoutput>#Application.UOMCaseSingular#</cfoutput>'+ (mydata.DATA[0][96]==1 ? ' (default)':'') +'</td>'
									+ '<td> CS '+ '<cfoutput>#clickToCopy#</cfoutput>' + '</td>' + '</tr>'; }
								if(index==2) { html+= '<tr>'
									+ '<td> Percent of Revenue'+ (mydata.DATA[0][96]==3 ? ' (default)':'') +'</td>'
									+ '<td> % '+ '<cfoutput>#clickToCopy#</cfoutput>' + '</td>' + '</tr>'; }
							}
						});
						if (uomHeaderDisplayed) {
							html+='</div></table><br>';
							$("#templateContent").append(html);
						}

						// ---------------------------  Currency   ----------------------------------------------
						let currencyHeaderDisplayed = false;
						html = '';

						<cfloop query="GetCurrencyTypes">
							if (!currencyHeaderDisplayed) {
								html+='<div class="Title6"> Currency </div>';
								currencyHeaderDisplayed = true;
								html+='<div class="subtable"><table class="dataTable row-border order-column hover datagrid" width="100%">';
							}
							html+= '<tr>'
									+ '<td> <cfoutput>#Currency_Code#</cfoutput> <cfoutput>#clickToCopy#</cfoutput> </td>' 
								+ '</tr>';
						</cfloop>
						if (currencyHeaderDisplayed) {
							html+='</div></table><br>';
							$("#templateContent").append(html);
						}
								

						// ---------------------------  Payment Type = Claim Mechanics   ----------------------------------------------
						claimMechanics(templateId);

						// ---------------------------  Pays To   ----------------------------------------------
						paysTo(templateId);

						// ---------------------------  Payment Frequency   ----------------------------------------------
						let freqIndexes = [80,81,82,83,84,85,86,189,280,312,313,488,540,541,542];
						let freqHeaderDisplayed = false;
						html = '';
						$.each(freqIndexes, function(index, element) {
							if (mydata.DATA[0][element]) {
								if (!freqHeaderDisplayed) {
									html+='<div class="Title6"> Payment Frequency</div>';
									freqHeaderDisplayed = true;
									html+='<div class="subtable"><table class="dataTable row-border order-column hover datagrid" width="100%">';
								}
								if(index==0) { html+= '<tr>'
									+ '<td> Daily ' + '<cfoutput>#clickToCopy#</cfoutput></td></tr>'; }
								if(index==1) { html+= '<tr>'
									+ '<td> Weekly ' + '<cfoutput>#clickToCopy#</cfoutput></td></tr>'; }
								if(index==2) { html+= '<tr>'
									+ '<td> Monthly ' + '<cfoutput>#clickToCopy#</cfoutput></td></tr>'; }
								if(index==3) { html+= '<tr>'
									+ '<td> Quarterly ' + '<cfoutput>#clickToCopy#</cfoutput></td></tr>'; }
								if(index==4) { html+= '<tr>'
									+ '<td> Semi-Annual ' + '<cfoutput>#clickToCopy#</cfoutput></td></tr>'; }
								if(index==5) { html+= '<tr>'
									+ '<td> Annual ' + '<cfoutput>#clickToCopy#</cfoutput></td></tr>'; }
								if(index==6) { html+= '<tr>'
									+ '<td> Upon Expiration ' + '<cfoutput>#clickToCopy#</cfoutput></td></tr>'; }
								if(index==7) { html+= '<tr>'
									+ '<td> Upon Due ' + '<cfoutput>#clickToCopy#</cfoutput></td></tr>'; }
								if(index==8) { html+= '<tr>'
									+ '<td> One Time Payment ' + '<cfoutput>#clickToCopy#</cfoutput></td></tr>'; }
								if(index==9) { html+= '<tr>'
									+ '<td> Fiscal Month ' + '<cfoutput>#clickToCopy#</cfoutput></td></tr>'; }
								if(index==10) { html+= '<tr>'
									+ '<td> Fiscal Quarter ' + '<cfoutput>#clickToCopy#</cfoutput></td></tr>'; }
								if(index==11) { html+= '<tr>'
									+ '<td> Fiscal Year ' + '<cfoutput>#clickToCopy#</cfoutput></td></tr>'; }
								if(index==12) { html+= '<tr>'
									+ '<td> Fiscal Week ' + '<cfoutput>#clickToCopy#</cfoutput></td></tr>'; }
								if(index==13) { html+= '<tr>'
									+ '<td> Fiscal Bi Annual ' + '<cfoutput>#clickToCopy#</cfoutput></td></tr>'; }
								if(index==14) { html+= '<tr>'
									+ '<td> 13 Period Calendar ' + '<cfoutput>#clickToCopy#</cfoutput></td></tr>'; }
							}
						});
						if (freqHeaderDisplayed) {
							html+='</div></table><br>';
							$("#templateContent").append(html);
						}

						// ---------------------------  Discount Types   ----------------------------------------------
						let discIndexes = [108,109,110];
						let discHeaderDisplayed = false;
						html = '';
						$.each(discIndexes, function(index, element) {
							if (mydata.DATA[0][element]) {
								if (!discHeaderDisplayed) {
									html+='<div class="Title6"> Discount Types </div>';
									discHeaderDisplayed = true;
									html+='<div class="subtable"><table class="dataTable row-border order-column hover datagrid" width="100%">';
								}
								if(index==0) { html+= '<tr>'
									+ '<td> Fixed Prices </td>'
									+ '<td> F '+ '<cfoutput>#clickToCopy#</cfoutput>' + '</td>' + '</tr>'; }
								if(index==1) { html+= '<tr>'
									+ '<td> Rebates </td>'
									+ '<td> R '+ '<cfoutput>#clickToCopy#</cfoutput>' + '</td>' + '</tr>'; }
								if(index==2) { html+= '<tr>'
									+ '<td> Lump Sums </td>'
									+ '<td> L '+ '<cfoutput>#clickToCopy#</cfoutput>' + '</td>' + '</tr>'; }
							}
						});
						if (discHeaderDisplayed) {
							html+='</div></table><br>';
							$("#templateContent").append(html);
						}
					} //success
				); // $.getJSON
			} //templateContent


			//Content for Revision section
			revisionContent = function(templateId){
				<!--- See AwayX\Program_Wizard\revision_settings.cfm --->
				<!--- This array maps the revision setting (zero based) to the display string --->
				var revisionStrings = [
					{ "str": "Allow changes to the Title of the program", "col": "TITLE_CHANGES", "idx": 6 },
					{ "str": "Allow changes to the Start of the program", "col": "DATE_CHANGES", "idx": 7 },
					{ "str": "Allow changes to the End Dates of the program", "col": "Date_Changes_End", "idx": 28 },
					{ "str": "Allow program revision Start Dates to be later than the original", "col": "Start_Date_Change", "idx": 20 },
					{ "str": "Allow program revision End Date to be earlier than the original start date", "col": "End_Date_Change", "idx": 21 },
					{ "str": "Allow payment frequency to be changed", "col": "Payment_Frequency_Changes", "idx": 26 },
					{ "str": "Allow change to program currency", "col": "Currency_Change", "idx": 29 },
					{ "str": "Require public notes to be changed", "col": "Require_Public_Notes_Changed", "idx": 23 },
					{ "str": "Require business considerations to be changed", "col": "Require_Private_Notes_Changed", "idx": 22 },
					{ "str": "Allow products to be added", "col": "Products_Added", "idx": 8 },
					{ "str": "Allow products to be removed", "col": "Products_Removed", "idx": 9 },
					{ "str": "Allow changes to the products rates offered", "col": "Products_Rates_Changes", "idx": 10 },
					{ "str": "Allow changes to the unit of measure", "col": "Products_UOM_Changes", "idx": 11 },
					{ "str": "Allow growth targets/tiers to be changed", "col": "Growth_Change_Target", "idx": 19 },
					{ "str": "Allow lump sum components to be changed", "col": "Lump_Sum_Changed", "idx": 12 },
					{ "str": "Allow lump sum components to be created", "col": "Lump_Sum_Created", "idx": 13 },
					{ "str": "Allow lump sum components to be removed", "col": "Lump_Sum_Removed", "idx": 14 },
					{ "str": "Allow claim mechanic to be changed", "col": "Claim_Mechanic_Changed", "idx": 27 },
					{ "str": "Allow distributors to be added", "col": "Distributors_Added", "idx": 15 },
					{ "str": "Allow distributors to be removed", "col": "Distributors_Removed", "idx": 16 },
					{ "str": "Allow operators to be added", "col": "Operators_Added", "idx": 17 },
					{ "str": "Allow operators to be removed", "col": "Operators_Removed", "idx": 18 }
				];
				// remove existing content
				$("#revisionContent").html('');
				$.getJSON(
					'/components/programs/template/TemplateManager.cfc',
					{
						method 			: "getTemplateRevisionSettings",
						templateId 		: templateId,
						returnFormat	: "json"
					},
					// success
					function(mydata){
						let html = '<div class="Title6"> Revision Rules </div>';
						html +='<div class="subtable"><table class="dataTable row-border order-column hover datagrid" width="100%">';
	
						$.each(revisionStrings, function(index, element) {
							html +=
								'<tr>'
								+ '<td> ' + element.str + '</td>' 
								+ '<td>' + (mydata.DATA[0][element.idx] == '2' ? 'No':'Yes') + '</td>'
								+ '</tr>'
							;
						}); // for each
						
						html +='</div></table><br>';
						$("#revisionContent").append(html);

					} //success
				); // $.getJSON
			} //revisionContent
			
			//Content for Claim Mechanics section
			function claimMechanics(templateId){
			
				let html = '';	
				$.getJSON(
					'/components/programs/template/TemplateManager.cfc',
					{
						method         : "getTemplateClaimMechanics",
						templateId : templateId,
						returnFormat   : "json"
					},
					// success
					function(mydata){
						html+='<div class="Title6"> Claim Mechanics </div>';
						html+='<div class="subtable"><table class="dataTable row-border order-column hover datagrid" width="100%">';
						for(var i = 0; i < mydata.DATA.length; i++) {
							html+= '<tr><td>' + mydata.DATA[i][1] + '<cfoutput>#clickToCopy#</cfoutput></td></tr>';
						}
						html+='</div></table><br>';

						$("#templateContent").append(html);
					}//success
				); // $.getJSON

			} //claimMechanics

			//Content for Pays To section
			function paysTo(templateId){
			
			let html = '';	
			$.getJSON(
				'/components/programs/template/TemplateManager.cfc',
				{
					method         : "getTemplatePaysTo",
					templateId : templateId,
					returnFormat   : "json"
				},
				// success
				function(mydata){
					html+='<div class="Title6"> Pays To </div>';
					html+='<div class="subtable"><table class="dataTable row-border order-column hover datagrid" width="100%">';
					for(var i = 0; i < mydata.DATA.length; i++) {
						html+= '<tr><td>' + mydata.DATA[i][1] + '</td>'
							+ '<td>'+ mydata.DATA[i][1][0] +'<cfoutput>#clickToCopy#</cfoutput></td></tr>'; 

					}
					html+='</div></table><br>';
					$("#templateContent").append(html);
				}//success
			); // $.getJSON
		} //paysTo
		</script>

		<cfinclude template="/common_files/focus.cfm">


		<!------------------------------->
		<!--- Section Header Content  --->
		<!------------------------------->
		<!--- RSP --->
		<cffunction name="rspContent" output="true" hint="rsp Content">
			<cfsavecontent variable="local.rspContent">
				<div style="width:50%">
					<table class="dataTable row-border order-column hover datagrid" id="rspContent" width="100%">
						<thead>
							<tr>
								<th align="left">RSP Name</th>
								<th align="left">RSP ID</th>
								<th align="left">Position</th>
								<th align="left">Position ID</th>
							</tr>
						</thead>
						<tbody>
							<cfoutput query="rspList">
								<cfif rspList.Position_Level eq 3>
									<cfset positionlevel = application.returned_customer_setting.market_label_singular>
								<cfelseif rspList.Position_Level eq 2>
									<cfset positionlevel = application.returned_customer_setting.region_label_singular>
								<cfelseif rspList.Position_Level eq 1>
									<cfset positionlevel = application.returned_customer_setting.zone_label_singular>
								<cfelse>
									<cfset positionlevel = "Headquarters"/>
								</cfif>
								<tr>
									<td>#User_Full_Name#</td>
										<!--- variable with click to copy element --->
									<td>#User_Code# #clickToCopy#</td>
									<td>#Position_Label#</td>
									<td>#User_Positions_ID# #clickToCopy#</td>
								</tr>
							</cfoutput>
						</tbody>
					</table>
				</div>
			</cfsavecontent>
			<cfreturn local.rspContent />
		</cffunction>

		<!--- components  --->
		<cffunction name="compsContent" output="true" hint="comps Content">
			<cfsavecontent variable="local.compsContent">
				<div style="width:25%">
					<div id="compsContent">
						<!--- data inserted here by compsContent function --->
					</div>
				</div>
			</cfsavecontent>
			<cfreturn local.compsContent />
		</cffunction>

		<!--- template rules  --->
		<cffunction name="templateContent" output="true" hint="template Content">
			<cfsavecontent variable="local.templateContent">
				<div class="row">
					<div id="templateContent">
						<!--- data inserted here by templateContent function --->
					</div>
					<div id="revisionContent">
						<!--- data inserted here by revisionContent function --->
					</div>
				</div>
			</cfsavecontent>
			<cfreturn local.templateContent />
		</cffunction>
	</body>
</html>
