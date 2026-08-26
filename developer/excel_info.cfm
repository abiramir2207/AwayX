<!---
  * ==================================================================================================== 
  *    @File: Developer/excel_info.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2019-04-24 10:38:43
  * 
  * @Remarks: Upload an Excel file and display information in it
  *  
  * ==================================================================================================== 
--->
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Excel File Information</title>
    <link rel="stylesheet" type="text/css" href="/common_files/main_style.css?v=08250240">
    <script src="/script/javascript/default.js?v=092020770" ></script>
	<cfsavecontent variable="head_content">
		<style>
            body {
                width: 100%;
                padding:1% 5%;
                font: 12px Arial, sans-serif;
            }
            h2 {
                margin: 15px 0;
            }
            p {
                letter-spacing: 0.5px;
            }
		</style>
    </cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
    <cfhtmlhead text="#application.util.string.compress( head_content )#">
    <link rel="stylesheet" type="text/css" href="https://cdn.awayx.com/base/styles/tailwind/0.7/tailwind.min.css?v=080654236"> 
</head>

<body>
<cf_include files=#arrayToList( [ 
                                    "/common_files/jQuery.cfm"
                                    ,"/common_files/dropzone.cfm"
                                    ,"/styles/ba_upload.css" 
                                    ,"/common_Files/dhx_message.cfm"
                                ] )#>
<div style="margin:10px 0 20px 0; width:99%; height:70px;" class="flex items-center bg-blue text-white text-sm px-4 py-3" role="alert">
    <svg class="fill-current w-4 h-4 mr-2" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M12.432 0c1.34 0 2.01.912 2.01 1.957 0 1.305-1.164 2.512-2.679 2.512-1.269 0-2.009-.75-1.974-1.99C9.789 1.436 10.67 0 12.432 0zM8.309 20c-1.058 0-1.833-.652-1.093-3.524l1.214-5.092c.211-.814.246-1.141 0-1.141-.317 0-1.689.562-2.502 1.117l-.528-.88c2.572-2.186 5.531-3.467 6.801-3.467 1.057 0 1.233 1.273.705 3.23l-1.391 5.352c-.246.945-.141 1.271.106 1.271.317 0 1.357-.392 2.379-1.207l.6.814C12.098 19.02 9.365 20 8.309 20z"/></svg>
    <p class="">This tool displays information from your Excel file. FORGE application <b>reads only the first sheet</b> and ignore the remaining sheets. Please remove all <b>hidden</b> sheets created by Excel third party add-ins prior to loading into FORGE.</p>
</div>

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

<div id="restart" style="display:none;margin-bottom:15px;">
    <button class="button" onclick="window.location=location;">select other excel file</button>
</div>

<div id="inspect">
</div>

<!------------- Dropzone setup ------------->
<script>
    // callbacks
    doneUploading2 = function(){
    }
    postProcessing = function(good_responses){
        if (good_responses[0].length) {
            <!--- <cfoutput>window.opener.#url.data_handler#();</cfoutput> --->
            // console.log(good_responses);
            $("div#myDropId").hide();
            $("div#restart").show();
            $("div#inspect").html(good_responses[0]);
        }
    }
    
    setupDropzone(  "./ajax/excel_info.cfm", //upload url
                    doneUploading2, //callback after acknowledging completion
                    1000,    // max files
                    10,   // max size MiB
                    "application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", // only accept Excel file types sa xls, xlsx
                    postProcessing,    // optional callback
                    true
    );
</script>
</body>
</html>

