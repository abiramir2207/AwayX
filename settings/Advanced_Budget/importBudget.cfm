<!---------------------------------------------------------------------------------------------------------------------
      Template:
      Date:     2011
      Author:   Chris Nguyen
      Purpose:

      Required parameters:
         - url.budget_id: integer
         - url.data_handler: string = js callback function for refreshing data on parent window
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en">
<head>
  <title>Blacksmith Applications</title>
  <style>
    #upl18 { font-size: 14px;	margin:10px; }
  </style>
	<!--- Dropzone.js open source library is used for the file upload --->
	<cf_include files=#arrayToList( [ "/common_files/dropzone.cfm", "/styles/ba_upload.css" ] )#>
</head>
<body>
	<cfparam name="url.height" default="300">
	<cfparam name="url.width"  default="400">

	<!---  Use flag to choose old Flash upload vs new dropzone upload --->
	<cfif application.util.query.get_setting("upload_documents_method", false) EQ "flash">
    <cffileupload url="ajax/importBudget.cfm?budget_id=#url.budget_id#"
      maxfileselect="1"
      oncomplete="doneUploading"
      height="#url.height#"
      width="#url.width#"
      bgcolor="##4169E1"
      extensionfilter="xls,xlsx"
      title="Import Budget from Excel"
      addbuttonlabel="Select Excel File"
      deletebuttonlabel="Clear Selection"
      uploadbuttonlabel="Import"/>

    <script type="text/javascript">
      doneUploading = function(result){
          if (result.STATUS == 200) {
            <cfoutput>window.opener.#url.data_handler#();</cfoutput>
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
					&nbsp; Drop Excel Budget file here or <span style="color:blue">click to upload</span>			
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
      if (good_responses[0].length) {
        <cfoutput>window.opener.#url.data_handler#();</cfoutput>
      }
    }

    setupDropzone(
      "ajax/importBudget.cfm?budget_id=<cfoutput>#url.budget_id#</cfoutput>",	//upload url 
      doneUploading2,	//callback after acknowledging completion
      1, 		// max files
      10,		// max size MiB
      "application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",	// only accept Excel file types sa xls, xlsx
      postProcessing
      );
				
			</script>
	</cfif> <!--- end of Dropzone upload --->   
</body>
</html>