<!---
  * ====================================================================================================
  *    @File:   AwayX\settings\Self_Service\Self_Serve.cfm
  *    @Author: Anand Rao
  *    @Date:   16 Sep 2024
  *
  *    @Remarks: Self Serve Main Page
  *
  * ====================================================================================================
--->
<cfparam name="url.fiscalYear" default="0">
<cfparam name="url.plannerID" default="0">
<cfparam name="url.plannerTemplateID" default="0">

 

<!DOCTYPE HTML>
<html lang="en">
<head>
    <!--- cfsavecontent variable="head_content" --->
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">

        <style>
            body { padding: 3px; }
            div.header {
                margin: 0 auto;
                display: flex;
                gap: 1rem;
                align-items: center;
                justify-content: left;
                width: 90%;
            }
            div.header > * {
                flex-grow: 0;
            }
            div.mode {
                flex-basis: 100px;
                flex-grow: 0;
            }
            div.dropzone {
                flex-basis: 650px;
            }
            button.hidden {
                display: none !important;
            }
            button.nondisplay {
                display: none !important!
            }
            button.short {
                height: 12px;
                font-size: 10px;
                position: relative;
                top: -2px;
            }
 
            div.footer {
                padding-top: 10px;
                padding-left: 5%;
                width: 60%;
                font-weight: bold;
            }
        </style>
        <script type="text/javascript" src="/script/tTip.js"></script>
        <link rel="stylesheet" href="/styles/tTip.css" type="text/css" />
    <!--- /cfsavecontent --->
    <!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
    <!--- cfhtmlhead text="#application.util.string.compress( head_content )#" --->
    <!--- show error messages in the centered DHTMLX popup --->
    <cfset request.dropZone2022 = true>
    <cf_include files="/common_files/dropzone.cfm, /styles/ba_upload.css">
</head>
<body>
    <cfset request.agGrid2022 = 1>
    <cfset request.ag_grid_dense = 0>
    
    <cfparam name="FORM.submitted" default = "0"/>
    <cfset selfServeMgr = createObject("component","mvc.Models.Admin.SelfServe.SelfServeManager") />
    
    <cfif FORM.submitted EQ '1'>
        <!---  --->
 
    </cfif>

    <cf_include files="/styles/reset2.css, /common_files/ag-Grid.cfm, /common_files/jQuery.cfm, /common_files/popup2022.cfm">
    
    <style>
        /* override ag-grid default height */
        div#ag_grid {
            height: calc( 100vh - 145px );
        }
    </style>

    <cfscript>
        lock     = {};
        lock.cfc = new mvc.models.admin.selfserve.selfservemanager();

        lock.status = lock.cfc.checkSelfServeLock();
        // labelManager     = new components.settings.Labels.Labels();
        qActionLookup = lock.cfc.getActionLookup();
        css.editing  = "";
        css.readonly = "";
        css.dropzone = "disabled";
        css.selectFields = "";
    </cfscript>

    <cfinclude template="/common_files/jQuery.cfm">
    <cfinclude template="/Common_Files/dhx_message.cfm" />
 
    <cfoutput>
	<div class="header">
		<div class="mode">
            <cfscript>
                if ( lock.status.Locked_By_User_ID is request.accessStructure.User_ID )
                {
                    css.readonly = "hidden";

                }
                else if ( lock.status.Locked_By_User_Name gt '' ) {
                    css.editing  = "hidden";
                    css.readonly = "hidden";
                    css.dropzone = "disabled";
                    css.selectFields = "disabled";
                    writeOutput( "<h3 class=locked-by>Locked by #lock.status.Locked_By_User_Name# </h3>" );
                }
                else {
                    css.editing  = "hidden";
                    css.dropzone = "disabled";
                    css.selectFields = "disabled";
                }
            </cfscript>

			<button class="#css.readonly# read-only mode">Read Only</button>
			<button class="editing mode #css.editing#">Edit</button>

		</div>

   
                <!------------- Category  ------------->
        <div style="padding-right:15px;" class="selectFields #css.selectFields#">
            <div style="margin-bottom:5px;font-size:12px;">
                <b>Category</b>
            </div>
            <select id="selCategory" name="selCategory" class="ddSelect">
                <option value="">Select a Category</option>
                <option value="Billback" selected>Billback</option>
                <!--- option value="Programs">Programs</option>
                <option value="Deductions">Deductions</option>
                <option value="Planner">Planner</option --->
            </select>
        </div>
    
        <!------------- Action Type  ------------->
         
        <div style="padding-right:15px;" class="selectFields #css.selectFields#" id="divActionType">
            <div style="margin-bottom:5px;font-size:12px;">
                <b>Action Type</b>
            </div>
            <select id="selActionType" name="selActionType" class="ddSelect"><!--- onChange="javascript:fnDispDropZone();" --->
                <option value="">Select an Action Type</option> 
                    <cfloop query="qActionLookup">
                        <option style="font-size:12px;" value="#qActionLookup.Self_Serve_Action_Category_Type_Lookup_ID#">
                            #qActionLookup.Action_Type#
                        </option>
                    </cfloop>
                <!--- <option value="Update_Dates" dataDesc="Update Dates on BBs">Update Dates</option>
                    <option value="Update_Ref_Number" dataDesc="Update Ref Number on BBs">Update Ref Number</option>
                
                    <option value="Move_BBs" dataDesc="Move BBs from RFA or Approved to Paid">Move BBs</option>
                    <option value="Update_Program" dataDesc="Update program on BBs">Update Program</option>
                    
                    <option value="Update_Operator" dataDesc="Update operator on BBs">Update Operator</option>
                    <option value="Update_Customer" dataDesc="Update customer/ship tos on BBs">Update Customer/Ship tos</option>
                    <option value="Update_Component" dataDesc="Update component on BBs ">Update Component</option>
                    <option value="Update_Volume" dataDesc="Update volume on BBs">Update Volume</option>
                    
                    <option value="Resent_to_RDB" dataDesc="Resend BB changes to RDB">Resent to RDB</option>
                    <option value="Delete_BBs" dataDesc="Delete BB">Delete BBs</option>
                    <option value="Void_BBs" dataDesc="Void BB (includes auto pay bb's)">Void BBs</option>
                    <option value="Reset_BBs" dataDesc="Reset BBs">Reset BBs</option>
                --->
            </select>
        </div>
       <input type="hidden" name="submitted" value="1">
     </div>
<br>
    <div class="header">
     <!------------- Dropzone area ------------->
        <div id="myDropId" class="dropzone dz-clickable #css.dropzone#" style="height:100px">
            <div class="dz-message">
                <img class='ba-dz-message' src='/Images/cloud_343540.svg'>
                &nbsp; Drop documents here or <span style="color:blue">click to upload</span>
            </div>
            <div align="center">[Select Category & Action Type to enable the upload]</div>
            <!------------- File list Results area ------------->
            <div class="upl-table" id="previews">
                <!--- upload result gets put here via shared template --->
            </div>
        </div>
            <div>
                <button class="button instructions">Instructions to upload</button>
                <button class="button sample">Download sample</button>
            </div>
    </div>
    <div class="footer">
        <font color="red">
            <strong>Note:</strong> Mass Actions taken on this page do not consider the use profile's rights, approval limits.   Mass Actions will be done regardless of the rights/approval limits of the user initiating the action on this page.
        </font>
    </div>
    </cfoutput>

    <cfscript>
         final_destination = application.doc_path & "\Data_Files\Uploaded\settings\self_serve\";
    </cfscript>

    <script>
        'use strict';

        const grid = { id: "#ag_grid" };
        <cfoutput>
        const final_destination = "#URLEncodedFormat( final_destination )#";
        </cfoutput>

        $( "button.instructions" ).click( function() {
            popup2022( "Self_Serve_Instructions.cfm", "Upload Instructions", "xs", "xl", "center" );
        });

        $( "button.sample" ).click( function() {
            <cfoutput>       
                generate_export( "/GetDocument.cfm?FilePath=#URLEncodedFormat( expandPath( 'Self_Serve_Upload_Sample.xlsx' ) )#" );
            </cfoutput>
        });

        $( "button.mode" ).click( function() {
            let button = $( this );
            $.ajax({
                url: "/mvc/models/admin/selfServe/selfServeManager.cfc"
                , data: {   method: button.hasClass( "read-only" ) ? "Lock2" : "unLockByID2"
                            ,user_id: '<cfoutput>#request.accessStructure.User_ID#</cfoutput>'
                        }
                , error: function(XMLHttpRequest, textStatus, errorThrown) { error_handler( arguments ) }
                , success: function( response ) {  
                                                    let result = JSON.parse( response );
                                                    if ( result.SUCCESS ) {
                                                        button.hide();
                                                        
                                                        if ( button.hasClass( "read-only" ) ) {
                                                            $( "div.selectFields" ).removeClass( "disabled" );
                                                            $( "button.editing" ).show();
                                                            if ( $( "select[name=selCategory]" ).val() > 0 && $( "select[name=selActionType]" ).val()) {
                                                                $( "div.dropzone" ).removeClass( "disabled" );
                                                                turnDropzoneOn();
                                                            }
                                                        }
                                                        else {
                                                            $( "button.read-only" ).show();
                                                            $( "div.dropzone" ).addClass( "disabled" );
                                                            $( "div.selectFields" ).addClass( "disabled" );
                                                            turnDropzoneOff();
                                                        }
                                                    }
                                                }
            });
        });

       setupDropzone(     "ajax/ss_upload.cfm",
                            ()=>{ location.reload(true) },    //callback after acknowledging completion
                            1, 		        // max files
                            50,	            // max size MiB
                            ".xlsx"         // XLSX format only
                        );

        // pass a dynamic selected entries to the ajax process
        myDropzone.on( "sending", function( file, xhr, formData ) {
            formData.append( "selCategory", $( "select[name=selCategory]").val() );
            formData.append( "selActionType", $( "select[name=selActionType]").val() );
        });

        <cfif css.dropzone is "disabled">
            turnDropzoneOff();
        </cfif>

        let selCategorySelect = $( "select[name=selCategory]" );
        let selActionTypeSelect = $( "select[name=selActionType]" );
 
        let selCategoryExists = $( "select[name=selCategory]" ).length;
        let cgError = '';

        //enable drop zone when all required values are selected
      
        $( "select.ddSelect" ).change( function() {
            if(selCategoryExists)
            {
                if(selCategorySelect.val() =='Billbacks' && selCategorySelect.val() != '')
                {  //  Add individual values check here in future if we are validting for a single row without the need for a file upload 
                    cgError = selCategorySelect.val();
                }
            } 
            if(selCategorySelect.val() == '' || selActionTypeSelect.val() == '') {
                turnDropzoneOff();
                $( "div.dropzone" ).addClass( "disabled" );
            }
            else {
                turnDropzoneOn();
                $( "div.dropzone" ).removeClass( "disabled" );
            }
       
        } ); 
    
    </script>

    <cfinclude template="/common_files/focus2.cfm">
</body>
</html>