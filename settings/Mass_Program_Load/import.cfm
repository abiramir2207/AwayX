<!----------------------------------------------------------------------------------------------------------------------------------
	Template:	/settings/Mass_Program_Load/import.cfm
	Author: 	Tim Ford
	Date: 		4/7/2017
	Purpose: 	Import programs from Excel XLSX file
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
		background-image:
		  linear-gradient(
			to right,
			 #010281, #A7CAF2
		  );
		color: white;
		font-size: 14px;
		font-weight: bold;
		letter-spacing: 0.75px;
		padding:8px 0 0 8px;
	  }
	  div.header > button { margin:6px 10px; }
	  div#upload, div#action { margin:15px; }
		#upl18 { font-size: 14px;	margin:15px; }
	</style>
  </cfsavecontent>

	<!--- Dropzone.js open source library is used for the file upload --->	
	<cf_include files=#arrayToList( [ "/common_files/dropzone.cfm", "/styles/ba_upload.css" ] )#>

  <!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
  <cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>
<body>
	<cfset jQueryUI.widgets = "tooltip">
	<cfinclude template="/common_files/jQuery.cfm">
	<cfinclude template="/Common_Files/dhx_message.cfm" />
	<div class="header">
		PROGRAMS - IMPORT
	</div>

	<!---  Use flag to choose old Flash upload vs new dropzone upload --->
	<cfif application.util.query.get_setting("upload_documents_method", false) EQ "flash">
		<div id="upload">
			<cffileupload url="ajax/import.cfm"
							maxfileselect     ="1"
							oncomplete        ="complete"
							height            ="300"
							width             ="500"
							bgcolor           ="##9BC2E6"
							extensionfilter   ="xlsx"
							title             ="Import from Excel"
							addbuttonlabel    ="Select .xlsx file"
							deletebuttonlabel ="Remove file"
							clearButtonLabel  ="Reset"
							uploadbuttonlabel ="Import"/>
		</div>
	<cfelse>
	<!--- Replace the Flash upload with a javaScript one based on the dropzone.js library --->
		<br>
		<div id="upl18">
			<!------------- Dropzone area ------------->
			<div id="myDropId" class="dropzone dz-clickable">
				<div class="dz-message">
					<img class='ba-dz-message' src='/Images/cloud_343540.svg'>
					&nbsp; Drop Excel file here or <span style="color:blue">click to upload</span>			
				</div>
			</div>

			<!------------- File list Results area ------------->
			<div class="upl-table" id="previews">      
				<!--- upload result gets put here via shared template --->
			</div>
		</div> <!-- #upl18 -->
		
			<!------------- Dropzone setup ------------->
			<script>

			<!--- callbacks --->
			doneUploading2 = function(){
				window.close();
			}
			postProcessing = function(good_responses){
				if (good_responses[0].length) {
					window.location.href = "process_import.cfm?f=" + good_responses;
				}
			}
			
			setupDropzone(
				"ajax/import.cfm",	//upload url 
				doneUploading2,	//callback after acknowledging completion
				1, 		// max files
				10,		// max size MiB
				"application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", 	// only accept Excel file types sa xls, xlsx
				postProcessing	// process after upload
			);	
			</script>
	</cfif> <!--- end of Dropzone upload --->


	<div id="action">
		<cfoutput>
		<a href="index.cfm">#application.util.string.actionLinkFormat('return to home page')#</a>
		</cfoutput>
	</div>

  	<script>
		complete = function(result){
					if (result.STATUS == 200) {
						//show_loader("IMPORTING PROGRAMS, PLEASE WAIT...", 2000);
						window.location.href = "process_import.cfm?f=" + result.MESSAGE;
					}
					else {
						alert(result.MESSAGE);
					}
		}
	</script>

	<cfinclude template="/common_files/focus.cfm">
</body>
</html>