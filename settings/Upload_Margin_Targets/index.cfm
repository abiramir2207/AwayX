<!DOCTYPE HTML>

<html lang="en">
<head>
  <cfsavecontent variable="head_content">
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<title>Documents</title>
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
	  	table-layout: fixed;
	  }
	  th { font-weight: bold; }
	  a.download { margin-right: 27px; }
	  .right { text-align: right; }
	  .center { text-align: center; }
	  .rules{ float: right; }
	</style>
  </cfsavecontent>
  <!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
  <cfhtmlhead text="#application.util.string.compress( head_content )#">
  
  <!--- Dropzone.js open source library is used for the file upload --->
  <cf_include files=#arrayToList( [ "/common_files/dropzone.cfm", "/styles/ba_upload.css" ] )#>

</head>
<body>
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<cfquery name="qGetUploadedDoc" datasource="#application.datasource#">
		SELECT DOC.*, U.Name_First+' '+U.Name_Last AS Name
		FROM Margin_Targets_Upload_Doc_Details DOC
		INNER JOIN _USERS U
		ON U.user_ID = DOC.Uploaded_by
		WHERE U.Deleted = 0
		ORDER BY DOC.Uploaded_Date DESC
</cfquery>

	<cfset jQueryUI.widgets = "tooltip">
	<cfinclude template="/common_files/jQuery.cfm">
	<cfinclude template="/Common_Files/dhx_message.cfm" />

	<cfoutput>
	<div class="header">
		Upload #appSettings.getMarginColHeader26()# Documents
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

<!-- HTML --> 

		<div id = "rulesPopup" title = "File Validation Rules">
			1) #application.returned_customer_setting.item_label# must be in system.<br>
			2) Distribution channel must be valid.<br>
			3) Rates cannot be more than five decimals.	<br>
			4) Rates must be numeric.  Do not format rates with $ sign.<br>
 			5) If the file has any errors, the entire file will fail and no rows will load.     					
		</div>

	<div id="grid">
		<form name="documents" method="post" action="#cgi.script_name#?programID=1">
		<input type="hidden" name="action">
		<input type="hidden" name="doc_id">
		<cfset column_sizes = application.util.array.dtColumnSizeInPercent( [3, 1.5, 2, 2, 1, 2.5] )>
		<table class="datagrid">
			<cfloop array="#column_sizes#" index="column_percentage">
				<col width="#column_percentage#%">
			</cfloop>
			<thead>
				<tr>
					<th>Document Name</th>
					<th>Document Size</th>
					<th>Uploaded Date</th>
					<th>Uploaded By</th>
					<th>Errors</th>
					<th>file</th>
				</tr>
			</thead>
						<tbody>
			<cfloop query="qGetUploadedDoc">
			<tr>
				<td>#Doc_Name#</td>
				<td>#Doc_Size#</td>
				<td>#Dateformat(Uploaded_Date, 'medium')# @  #Timeformat(Uploaded_Date, 'short')#</td>
				<td>#Name#</td>
				<td>
					<cfif ! success>
						<cfquery name="errorCount" datasource="#application.datasource#">
							SELECT count(*) AS Total
							FROM Margin_Targets_Upload_Doc_Error_Details
							WHERE DOC_ID = #DOC_ID#
						</cfquery>					
							<a href="javascript:viewErrors(#doc_id#)">#application.util.string.actionLinkFormat2(errorCount.Total)#</a>
					<cfelse>
							0
						</cfif>
				</td>
				<td>
					<a class="download" onclick="downloadFile('#Doc_Full_Name#')">#application.util.string.actionLinkFormat2("download")#</a>
				</td>
			</tr>
			</cfloop>
			</tbody>
		</table>

	<div id="action">
		<a onclick="window.close()"><cfoutput>#application.util.string.actionLinkFormat2("close window")#</cfoutput></a>
	</div>
	</cfoutput>

	<cfset jQueryUI.widgets = 'full'>
	<cfinclude template="/common_files/jQuery.cfm">
	<cfinclude template="/common_files/dataTables2.cfm">

  	<script>
		function complete ( result ) {
			var errors = 0;
			for (var i = 0; i < result.length; i++) {
				if (result[i].STATUS !== 200) {
					errors++;
				}
			}
			if (errors == 0) {
				window.location.href = window.location.href;
			}
			else {
				alert("Unexpected errors have occurred, please try this option again later.");
			}
		}

		data_table = $("table.datagrid").DataTable({
								// only columns 0 and 3 (Doc name and Uploaded By) are sortable and searchable
								"columnDefs": [
												 { "searchable":false, "sortable":false }
												,{ "searchable":false, "sortable":false }
												,{ "searchable":false, "sortable":false }
												,{ "searchable":false, "sortable":false }
												,{ "searchable":false, "sortable":false }
												,{ "searchable":false, "sortable":false }
												],
								"language": { "emptyTable": "No documents available for this program" },
								"orderClasses": true,
								"order": [],
								"paging": false,
								"ScrollCollapse": true,
								"sScrollY": Math.floor(jQuery(window).height()) - 450,
								"sDom": 'f<"rules">t'
							});
		// add sorting icons to the end of text
		data_table.columns().iterator( 'column', function (ctx, idx) {
		    $( data_table.column(idx).header() ).append('<span class="sort-icon"/>');
		} );

		$('tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

		<!------------- Dropzone setup ------------->
		function reloadTable () {
			//$("form[name=documents]").submit();
			location.reload(true);
		}
		<!------------- order - reloadTable is after documents form is defined, and used below  ------------->
		setupDropzone(
			"ajax/upload_documents.cfm",
			reloadTable,//callback after acknowledging completion
			9, 		// max files
			10,	// max size MiB
			 ".xlsx,.xls" // File Type Restriction
			 );

function downloadFile(filename){
<cfoutput>
		NewWindow(	"#application.HTTPVar##CGI.server_name#/GetDocument.cfm"
		+ "?FilePath=#replace(Application.Doc_Path,'\','/','ALL')#/Data_Files/Uploaded/settings/upload_margin_targets/"
		+ filename
		, "download_document"
		, 10
		, 10  );
</cfoutput>
}

function viewErrors(id){
	NewWindow('upload_file_error_info.cfm?doc_id='+id, 'Fix_File', 1000, 800, 'yes', 'yes');
}
<cfoutput>
$('div.rules').html("&nbsp;&nbsp;<a id='records'>#application.util.string.actionLinkFormat('view current #appSettings.getMarginColHeader26()#')#</a>&nbsp;&nbsp;&nbsp;&nbsp;<a id='rules'>#application.util.string.actionLinkFormat('validation rules')#</a> &nbsp;");
</cfoutput>

 $(function() {
            $( "#rulesPopup" ).dialog({
               autoOpen: false,  
               width: 450,
               height :120,
            });
            $( "a#rules" ).click(function() {
               $( "#rulesPopup" ).dialog( "open" );
            });

            $("a#records").click(function() {
            		NewWindow('Margin_Target_Info.cfm?download=0', '<cfoutput>#appSettings.getMarginColHeader26()#</cfoutput>', 1300, 800, 'yes', 'yes');
            });
  });

</script>

	<cfinclude template="/common_files/focus.cfm">

</body>
</html>