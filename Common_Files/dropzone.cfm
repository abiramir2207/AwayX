<cfsetting enableCFoutputOnly = "yes">
<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\Common_Files\dropzone.cfm
      Date:     Mar 21 2018
      Author:   Sharon Harris
      Purpose:  Load dropzone-related files from route in DB or fallback to local server
                DropzoneJS is an Open Source library the provides drag'n'drop file uploads with optional image previews.
                Documentation is at http://www.dropzonejs.com
                Updates to the latest source can be found here: https://gitlab.com/meno/dropzone
----------------------------------------------------------------------------------------------------------------------->
<cfsavecontent variable="_dropzone">
<cf_include files="/script/javascript/dropzone/5.4.0/dropzone.min.js, /script/javascript/dropzone/5.4.0/dropzone.min.css">

<!--- add custom BSA styling for dropzone --->
<style>

.dropzone{
    border: 1px dashed blue;
    border-radius: 3px;
    height: 60px;           /* shorten, no previews inside */
    max-width: 600px;
    min-height: 0px !important;
    padding: 0px;
}
.dropzone:hover {
    background-color: aliceblue;
}
.dropzone.dz-drag-hover {
    background-color: aliceblue;
}

.dropzone .dz-message {
    margin-top: 0.6em;       /* shorten, no previews inside */
    margin-bottom: 0.6em;
}

img.ba-dz-message {
    vertical-align: -70%;   /* align img with text */
    height: 36px;
    width: 36px;
  }
.text-danger {
    color: ##d60000;
}

.dz-success-mark {
    display: none;
    color: ##92d36e;
}
.dz-error-mark {
    display: none;
    color: ##d50000;
}
</style>

<script>
    /* display error messages in the dropzone.js div */
    let dz = { showErrorsInPopup: false };
</script>

<cfif isDefined( "request.dropZone2022" )>
    <style>
        div.dz-complete {
            padding: 0 10px;
        }
    </style>

    <script>
        /* display error messages in DHTMLX centered popup */
        dz.showErrorsInPopup = true;
    </script>
</cfif>

<cfscript>
    blockedExtForFileUpload = application.util.query.get_Setting("blockedExtForFileUpload", 0);
    blockedExtForFileUpload = listToArray( trim(blockedExtForFileUpload) eq ''
                                    ? 'cfm,cfml,cfc,js,bat,com,exe,ps1,sql'
                                    : blockedExtForFileUpload );
</cfscript>

<script>
    function doNothing(arr){
        /* alert("doing nothing"); */
    }

    Dropzone.autoDiscover = false; <!--- will instantiate it instead of applying class to a form, so we can customize it --->

    /* this global "myDropzone" object is defined here so we can turn on/off dropzone feature dynamically */
    myDropzone = 0;

    /* disables dropzone feature */
    function turnDropzoneOn() {
        myDropzone.setupEventListeners();
    }

    /* enables dropzone feature */
    function turnDropzoneOff() {
        myDropzone.removeEventListeners();
    }

    <!--- setupDropzone --->
    function setupDropzone(uploadURL, onUploadCompleteFn, maxNumFiles, maxFileSz, acceptedMimes, postProcessFn, hideSuccess) {
        /* default for optional params */
        maxNumFiles = maxNumFiles || 1;     /*max # files upload together */
        maxFileSz = maxFileSz || 10;        /*MiB */
        acceptedMimes = acceptedMimes || null;  /* optionally limit the file types. Takes a list of mime types, eg "image/*,application/pdf,.psd" */
        postProcessFn = postProcessFn || doNothing; /* can call after all uploads are complete */
        hideSuccess = hideSuccess || false;  /* default to show success alert when uploads complete (before processing complete) */

        let bad_responses  = [];
        let good_responses = [];

        /* Dropzone setup via instantiation */
        var previewTemplate = "<div id='template'><div class='upl-details'><span class='upl-name ellipsis' data-dz-name></span><span class='upl-size' data-dz-size></span><span class='upl-result dz-success-mark'>DONE</span><span class='upl-result dz-error-mark'>ERROR</span></div><div><strong class='error text-danger' data-dz-errormessage></strong></div> <div class=progress-bar><div class='progress-bar-progression' data-dz-uploadprogress></div></div></div>";

        myDropzone = new Dropzone(document.body, { /* Make the whole page a dropzone (less chance of mistake when dropping) */
          url: uploadURL,
          thumbnailWidth: 40,
          thumbnailHeight: 40,
          timeout: 300000,
          maxFilesize: maxFileSz, /*MiB */
          maxFiles: maxNumFiles,
          acceptedFiles: acceptedMimes,
          createImageThumbnails: false,  /* majority of docs in this case are not images, so file name should be prominent */
          dictMaxFilesExceeded: "You can upload a maximum of " + maxNumFiles + " files. This file was not uploaded.",
          previewTemplate: previewTemplate,		/* created above */
          clickable: "#myDropId",               /* Define the clickable area */
          previewsContainer: "#previews", 		/* Define the container to display the previews */
      });

        myDropzone.on("addedfile", function(a) {
            var b=a.name.replace(/^.*\./, '');
            var <cfoutput>#toScript(blockedExtForFileUpload, "nn")#</cfoutput>;
            for (var i=0;i<nn.length;i++) { if (b.toLowerCase()===nn[i]) myDropzone.removeFile(a); }
        });

        /* Update the individual PROGRESS bar */
        myDropzone.on("uploadprogress", function(file, progress, bytesSent) {
            let progressElement = file.previewElement.querySelector(".progress-bar-progression");
            progressElement.style.width = progress + "%";
        });

        /* Update the individual SUCCESS message */
        myDropzone.on("success", function(file, response) {
            /* checking response error statuses - 200 indicates a success */
            let obj = JSON.parse(response);
            if (obj.STATUS !== 200) {
                bad_responses.push(obj.MESSAGE + ": " + file.name);
            }
            else {
                good_responses.push(obj.MESSAGE);
                let element = file.previewElement.querySelector(".dz-success-mark");
                element.style.display = "flex";		/*  or inline - make msg visible */
            }
        });

        /* Update the individual ERROR message */
        myDropzone.on("error", function(file, errorMessage) {
            let element = file.previewElement.querySelector(".dz-error-mark");
            element.style.display = "flex";		/* or inline - make msg visible */
            element = file.previewElement.querySelector(".upl-name");
            element.style.color = "#d60000";	/* red text */
            element = file.previewElement.querySelector(".progress-bar-progression");
            element.style.width = "0%";			/* reset the bar */
            if ( dz.showErrorsInPopup ) {
                bad_responses.push( errorMessage + ' ' + file.name );
            }
        });

        /* Update the screen when all done */
        myDropzone.on("queuecomplete", function(file) {
            let rejected_files = myDropzone.getRejectedFiles();
            let accepted_files = myDropzone.getAcceptedFiles();
            let rejected = rejected_files.length;
            let accepted= accepted_files.length;

            /* handle any errors found while processing the upload */
            if ( bad_responses.length ) {
                dhx_alert_wait ( bad_responses.join("<br>"), onUploadCompleteFn, "Error" + (bad_responses.length > 1 ? "s" : "") );
                postProcessFn( good_responses, bad_responses );
            }
            else if (rejected == 0) {
                if (accepted != 0) {
                    if (!hideSuccess) {
                        dhx_alert_wait ("Successfully uploaded " + accepted + " document" + (accepted > 1 ? "s" : ""), onUploadCompleteFn(accepted), "Complete");
                    }
                    postProcessFn( good_responses, bad_responses );
                }
            } else { /* there was at least 1 error during upload */
                dhx_alert_wait ("There " + (rejected > 1 ? "were " : "was ") + rejected + " error" + (rejected > 1 ? "s" : ""), onUploadCompleteFn);
                postProcessFn( good_responses, bad_responses );
            }
        });
      }

    <cfif createObject( "component", "components.udf" ).is_developer() eq false>
        /* disable right click to protect us from harmful uploads */
        document.addEventListener("contextmenu",function(m){m.preventDefault();},false);
    </cfif>
    document.addEventListener("keydown",function(n){if (n.ctrlKey||n.keyCode==123){n.stopPropagation();n.preventDefault();}});
</script>
</cfsavecontent>

<cfoutput>#application.util.string.compress(_dropzone)#</cfoutput>
<cfsetting enableCFoutputOnly = "no">