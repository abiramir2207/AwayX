<!---
  * ====================================================================================================
  *    @File: settings\Planners\Indirect_Allocation\allocation_upload.cfm
  *  @Author: Anand Rao
  *    @Date: 2022 May
  *
  * @Remarks: Create Upload functionality
  *
  * ====================================================================================================
--->
<cfparam name="url.fiscalYear" default="0">
<!DOCTYPE HTML>
<html lang="en">
<head>
  <cfsavecontent variable="head_content">
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <cf_include files="/common_files/datatable.css, /common_files/datatableIcon.css">

    <style>
      body { padding: 3px; }
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
      div#upload, div#grid { margin: 10px 1%; }
      #upl18 { font-size: 14px;  margin: 10px 1%; }
      table.datagrid {
          width: 100%;
      }
      th { font-weight: bold; }
      a.download { margin-right: 27px; }
      .right { text-align: right; }
      .center { text-align: center; }
      td.nowrap { white-space:nowrap; }
    </style>
  </cfsavecontent>
  <!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
  <cfhtmlhead text="#application.util.string.compress( head_content )#">

  <!--- Dropzone.js open source library is used for the file upload --->
  <cf_include files=#arrayToList( [ "/common_files/dropzone.cfm", "/styles/ba_upload.css" ] )#>
</head>
<body>
    <cfscript>
        allocation_cfc    = createObject("component", "mvc.models.planner.IndirectAllocation");
        qGetUploadedDoc   = allocation_cfc.getUploads( url.id );
        final_destination = application.doc_path & "\Data_Files\Uploaded\settings\planner_indirect_allocation\";
    </cfscript>

    <cfset jQueryUI.widgets = "tooltip">

    <cfinclude template="/common_files/jQuery.cfm">
    <cfinclude template="/Common_Files/dhx_message.cfm" />

    <cfoutput>
    <div class="header">
        Upload Allocation for <cfoutput>#url.fiscalYear#</cfoutput>
    </div>

    <div id="upl18">
        <!------------- Dropzone area ------------->
        <div id="myDropId" class="dropzone dz-clickable">
            <div class="dz-message">
                <img class='ba-dz-message' src='/Images/cloud_343540.svg'>
                &nbsp; Drop documents here or <span style="color:blue">click to upload</span>
            </div>
        </div>

        <!------------- File list Results area ------------->
        <div class="upl-table" id="previews">
            <!--- upload result gets put here via shared template --->
        </div>
    </div> <!-- upl18 -->

    <div id="grid">
        <form name="documents" method="post">
        <input type="hidden" name="action">
        <input type="hidden" name="doc_id">

        <cfset column_sizes = application.util.array.dtColumnSizeInPercent( [3, 1.5, 2, 2, 3, 1.5] )>

        <table class="datagrid">
            <cfloop array="#column_sizes#" index="column_percentage">
                <col width="#column_percentage#%">
            </cfloop>
            <thead>
                <tr>
                    <th> Document Name </th>
                    <th> Document Size </th>
                    <th> Uploaded Date </th>
                    <th> Uploaded By </th>
                    <th> Status </th>
                    <th> File </th>
                </tr>
            </thead>
            <tbody>
                <cfloop query="qGetUploadedDoc">
                <tr>
                    <td> #qGetUploadedDoc.Doc_Name# </td>
                    <td> #qGetUploadedDoc.Doc_Size# </td>
                    <td> #Dateformat(qGetUploadedDoc.Uploaded_Date, 'ddd mmm d, yyyy')# @  #Timeformat(qGetUploadedDoc.Uploaded_Date, 'short')# </td>
                    <td> #qGetUploadedDoc.Name# </td>
                    <cfset status = allocation_cfc.uploadStatus( qGetUploadedDoc.Planner_Indirect_Allocation_Upload_ID )>
                    <td> #( status.detail_count eq 0
                                ? "Missing upload detail"
                                : status.error_count
                                    ? "<button class='error button' docid=#qGetUploadedDoc.Planner_Indirect_Allocation_Upload_ID#>" & numberFormat( status.error_count, "," ) & " row" & ( status.error_count gt 1 ? 's' : '' ) & " failed</button>"
                                    : "Loaded successfully" )# </td>
                    <td>
                        <button class="button" onclick="downloadFile( '#qGetUploadedDoc.Doc_Full_Name#' )"> Download </button>
                    </td>
                </tr>
                </cfloop>
            </tbody>
        </table>
    </cfoutput>


    <cfset jQueryUI.widgets = 'full'>
    <cfinclude template="/common_files/jQuery.cfm">
    <cfinclude template="/common_files/dataTables2.cfm">

      <script>
        function complete ( result ) {
            let errors = 0;
            for ( var i = 0; i < result.length; i++ ) {
                if ( result[i].STATUS !== 200 ) {
                    errors++;
                }
            }
            if ( errors == 0 ) {
                window.location.href = window.location.href;
            }
        }

        data_table = $("table.datagrid").DataTable({
                                columns: [
                                                 { "searchable":true, orderable:true, className:"nowrap" }
                                                ,{ "searchable":false, orderable:false }
                                                ,{ "searchable":false, orderable:true }
                                                ,{ "searchable":true, orderable:true }
                                                ,{ "searchable":false, orderable:true }
                                                ,{ "searchable":false, orderable:false }
                                                ],
                                "orderClasses": true,
                                "order": [],
                                "paging": false,
                                "ScrollCollapse": true,
                                "sScrollY": Math.floor(jQuery(window).height()) - 220,
                                "sDom": 'f<"rules">ti'
                            });
        // add sorting icons to the end of text
        data_table.columns().iterator( 'column', function (ctx, idx) {
            $( data_table.column(idx).header() ).append('<span class="sort-icon"/>');
        } );

        $('tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

        <!------------- Dropzone setup ------------->
        function reloadTable () {
            let iframe = $( "iframe[name=edit]", parent.document );
            // refresh the edit iframe tab
            if ( iframe.length ) {
                iframe.attr( "src", iframe.attr( "src" ) );
            }
            location.reload( true );
        }

        <!------------- order - reloadTable is after documents form is defined, and used below  ------------->
        <cfoutput>
        setupDropzone( "ajax/allocation_upload.cfm?id=#url.id#",
                        reloadTable,    //callback after acknowledging completion
                        9, 		        // max files
                        10,	            // max size MiB
                        ".xlsx"         // XLSX format only
                        );
        </cfoutput>


        <cfoutput>
        function downloadFile( filename ){
            generate_export( "/GetDocument.cfm?FilePath=#URLEncodedFormat( final_destination )#" + encodeURIComponent( filename ) );
        }

        $( "a.error, button.error" ).click( function() {
            let docid = $( this ).attr( "docid" );
            popupCenter2022( 'upload_detail.cfm?docid=' + docid, 'upload_detail', 'LG', 'LG' );
        });
        </cfoutput>
    </script>

    <cfinclude template="/common_files/popup2022.cfm">
    <cfinclude template="/common_files/focus.cfm">
</body>
</html>