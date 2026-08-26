<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\uploadActAdjustment.cfm
      Date:     Aug 22, 2012
      Author:   Chris Nguyen
      Purpose:  Upload budget actual adjustments from Excel file

      Required parameters:
         - url.data_handler: string = js callback function for refreshing data on parent window
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<html lang="en">
<head>
<title>Actual Adjustments Upload</title>
<style>
#help {
	margin:15px;
	font-size:1.15em;
}
#upload {
	margin:10px;
}
#upl18 { font-size: 14px;	margin:10px; }
ol li {
	margin-bottom:5px;
  list-style-type:upper-alpha;
}
</style>

	<!--- Dropzone.js open source library is used for the file upload --->
	<cf_include files=#arrayToList( [ "/common_files/dropzone.cfm", "/styles/ba_upload.css" ] )#>
</head>

<!--------------------------------------------------------------------------------------------------------------------->

<body>
	<div id="help">
		<p>The input Excel file should include these <b>five</b> columns on each actual adjustment row:</p>
		<ol>
			<li><b>Adjustment date</b> - required, US format mm/dd/yyyy (e.g. 6/15/2009). Must be within program template's setting "Last Date to Claim" timeframe.</li>
     <!---  <li><b>Starting date</b> - required, cannot be in the future. </li>
      <li><b>Ending date</b> - required, cannot be in the future. </li> --->
			<li><b>Program number</b> - required, format as '1001100'. Must be an approved program and have a lump sum component on it.</li>
			<li><b>Lump sum component name</b> - required, must be a valid lump sum component.</li>
			<li><b>Adjustment amount</b> - required, rounded to precision of 2. Negative amount must begin with a negative sign.</li>
			<li><b>Adjustment notes</b> - maximum length is 200 characters, required only on <b>first</b> row (leave a space bar for none).</li>
		</ol>
		<b>Notes:</b> Header row is not needed. Only the first worksheet is loaded. All formulas and macros should be removed prior to uploading.
	</div>

	<!---  Use flag to choose old Flash upload vs new dropzone upload --->
	<cfif application.util.query.get_setting("upload_documents_method", false) EQ "flash">
		<div id="upload">
			<cffileupload url="ajax/uploadAdjustment.cfm"
				maxfileselect="1"
				oncomplete="doneUploading"
				height="210"
				width="#(url.width - 20)#"
				bgcolor="##4169E1"
				extensionfilter="xls,xlsx"
				title="Import Actual Adjustments from Excel"
				addbuttonlabel="Select Excel File"
				align="center"
				deletebuttonlabel="Clear Selection"
				uploadbuttonlabel="Import"/>
		</div>

		<div id="result"></div>

		<script type="text/javascript">
			doneUploading = function(result){
					if (result.STATUS == 200) {
						<cfoutput>window.opener.#url.data_handler#( result.MESSAGE );</cfoutput>
					}
					else {
						alert(result.MESSAGE);
					}
					window.close();
			}
		</script>
	<cfelse>
	<!--- Replace the Flash upload with a javaScript one based on the dropzone.js library --->
	<cfinclude template="/Common_Files/dhx_message.cfm" />
		<br>
		<div id="upl18">
			<!------------- Dropzone area ------------->
			<div id="myDropId" class="dropzone dz-clickable">
				<div class="dz-message">
					<img class='ba-dz-message' src='/Images/cloud_343540.svg'>
					&nbsp; Drop Actual Adjustments from Excel here or <span style="color:blue">click to upload</span>			
				</div>
			</div>

			<!------------- File list Results area ------------->
			<div class="upl-table" id="previews">      
				<!--- upload result gets put here via shared template --->
			</div>
		</div> <!-- #upl18 -->
		
		<!------------- Dropzone setup ------------->
		<script>
		// callbacks
		doneUploading2 = function(){
			window.close();
		}
		postProcessing = function(good_responses){
			// alert("got to postProcessing " + good_responses[0]);
			if (good_responses[0].length) {
				<cfoutput>window.opener.#url.data_handler#( good_responses[0] );</cfoutput>
				// alert("after new data_handler");
			}
		}

		setupDropzone(
			"ajax/uploadAdjustment.cfm",	//upload url 
			doneUploading2,	//callback after acknowledging completion
			1, 		// max files
			10,		// max size MiB
			"application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",	// only accept Excel file types sa xls, xlsx
			postProcessing);
			
		</script>
	</cfif> <!--- end of Dropzone upload --->
</body>
</html>