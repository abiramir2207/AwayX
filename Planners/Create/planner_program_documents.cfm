<!DOCTYPE HTML>
<!----------------------------------------------------------------------------------------------------------------------------------
	Template: \planners\create\planner_program_documents.cfm
	  Author: Chris Nguyen
		Date: 2016 December
	 Purpose: Upload/download documents
----------------------------------------------------------------------------------------------------------------------------------->
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
	</style>
  </cfsavecontent>
  <!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
  <cfhtmlhead text="#application.util.string.compress( head_content )#">
  
  <!--- Dropzone.js open source library is used for the file upload --->
  <cf_include files=#arrayToList( [ "/common_files/dropzone.cfm", "/styles/ba_upload.css" ] )#>

</head>
<body>
	<cfsilent>
		<cfif cgi.request_method eq "post">
			<cfif form.action eq "remove">
				<cfquery name="qRemoval" datasource="#application.datasource#">
					UPDATE Contract_Attachments
					   SET Deleted = 1
					 WHERE Program_ID = #url.programID#
					 		AND Doc_ID = '#form.doc_id#'
				</cfquery>
			</cfif>
		</cfif>
		<cfquery name="qProgram" datasource="#application.datasource#">
			SELECT Contract_Number, Contract_Title
			  FROM Contract_Main
			 WHERE Contract_Main_ID = #url.programID#
		</cfquery>
		<cfquery name="qDocuments" datasource="#application.datasource#">
			SELECT  Document_Details.Doc_Uni_Name
			       ,Document_Details.Doc_Title
			       ,Document_Details.Doc_Description
			       ,Document_Details.Uploaded_Date
			       ,_Users.Name_First + ' ' + _Users.Name_Last AS Uploader
			       ,Document_Details.Doc_File_Name
			       ,Document_Details.Doc_Size
			       ,Document_Details.Doc_Family
			       ,Document_Details.Doc_ID
			FROM    Contract_Attachments
			INNER JOIN Document_Details
			        ON Document_Details.Doc_ID = Contract_Attachments.Doc_ID
			INNER JOIN _Users ON _Users.User_ID = Document_Details.Uploaded_By
			WHERE   Contract_Attachments.Program_ID = #url.programID#
					AND Contract_Attachments.Deleted = 0
					ORDER BY Document_Details.Uploaded_Date DESC
		</cfquery>
	</cfsilent>
	<cfset jQueryUI.widgets = "tooltip">
	<cfinclude template="/common_files/jQuery.cfm">
	<cfinclude template="/Common_Files/dhx_message.cfm" />

	<cfoutput>
	<div class="header">
		Documents for #replace(qProgram.Contract_Number, '-', ' ')# - #qProgram.contract_title#
	</div>

	<!---  Use flag to choose old Flash upload vs new dropzone upload --->
	<cfif application.util.query.get_setting("upload_documents_method", false) EQ "flash">

		<div id="upload">
			<cffileupload url="ajax/upload_documents.cfm?programID=#url.programID#"
							maxfileselect     ="9"
							height            ="300"
							width             ="500"
							bgcolor           ="##9BC2E6"
							title             ="Upload documents"
							addbuttonlabel    ="add documents"
							deletebuttonlabel ="remove"
							clearButtonLabel  ="clear"
							uploadbuttonlabel ="upload"
							onUploadComplete  ="complete"
							/>
		</div>
	<cfelse>
		<!--- Replace the Flash upload with a javaScript one based on the dropzone.js library --->
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
		
		<!------------- The rest of the Dropzone setup is below the document form definiton ------------->

	</cfif> <!--- end of Dropzone upload --->

	<div id="grid">
		<form name="documents" method="post" action="#cgi.script_name#?programID=#url.programID#">
		<input type="hidden" name="action">
		<input type="hidden" name="doc_id">
		<cfset column_sizes = application.util.array.dtColumnSizeInPercent( [3, 1.5, 1.5, 3, 3] )>
		<table class="datagrid">
			<cfloop array="#column_sizes#" index="column_percentage">
				<col width="#column_percentage#%">
			</cfloop>
			<thead>
				<tr>
					<th>Document Name</th>
					<th style="text-align:right">Document Size</th>
					<th style="text-align:center">Uploaded Date</th>
					<th>Uploaded By</th>
					<th>Action</th>
				</tr>
			</thead>
			<tbody>
			<cfloop query="qDocuments">
				<tr>
					<td>#qDocuments.Doc_File_Name#.#qDocuments.Doc_Family#</td>
					<td>#numberFormat(qDocuments.Doc_Size / 1024, "_.__")# KB</td>
					<td>#dateFormat(qDocuments.Uploaded_Date, "mmm d, yyyy")#</td>
					<td>#qDocuments.uploader#</td>
					<td><a class="download" file="#encodeForURL(qDocuments.Doc_Uni_Name)#">#application.util.string.linkFormat("download")#</a> <a class="remove" doc_id="#qDocuments.doc_id#">#application.util.string.linkFormat("remove")#</a></td>
				</tr>
			</cfloop>
			</tbody>
		</table>
		</form>
	</div>

	<div id="action">
		<a onclick="window.close()"><cfoutput>#application.util.string.linkFormat("close window")#</cfoutput></a>
	</div>
	</cfoutput>


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
												 { "targets":1, "searchable":false, "sortable":false, "className":"right" }
												,{ "targets":2, "searchable":false, "sortable":false, "className":"center" }
												,{ "targets":4, "searchable":false, "sortable":false }
												],
								"language": { "emptyTable": "No documents available for this program" },
								"orderClasses": true,
								"order": [],
								"paging": false,
								"ScrollCollapse": true,
								"sScrollY": Math.floor(jQuery(window).height()) - 450,
								"sDom": 'ft'
							});

		// add sorting icons to the end of text
		data_table.columns().iterator( 'column', function (ctx, idx) {
		    $( data_table.column(idx).header() ).append('<span class="sort-icon"/>');
		} );

		$('tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

		$("a.download").click(function(){
			<cfoutput>NewWindow(	"#application.HTTPVar##CGI.server_name#/GetDocument.cfm"
											+ "?FilePath=data_files/uploaded/documents/uploaded_doc/"
											+ $(this).attr("file")
											, "download_document"
											, 10
											, 10  );</cfoutput>
		});

		$("a.remove").click(function(){
			if ( confirm("Do you wish to remove the selected file?") ) {
				$("input[name=action]").val( "remove" );
				$("input[name=doc_id]").val( $(this).attr("doc_id") );
				$("form[name=documents]").submit();
			}
		});
	


		<!------------- Dropzone setup ------------->
		function reloadTable () {
			$("form[name=documents]").submit();
		}
		<!------------- order - reloadTable is after documents form is defined, and used below  ------------->
		
		setupDropzone(
			"ajax/upload_documents.cfm?programID=<cfoutput>#url.programID#</cfoutput>",	//upload url 
			reloadTable,	//callback after acknowledging completion
			9, 		// max files
			10);	// max size MiB

	</script>

	<cfinclude template="/common_files/focus.cfm">
</body>
</html>