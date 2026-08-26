<!------------------------------------------------------------------------------------------------------------------------------
	   File Name:  \planners\consumer_events\events\documents.cfm
	Created Date:  2017 November
	  Created By:  Chris Nguyen
	 Description:  Add/edit documents for a consumer event
------------------------------------------------------------------------------------------------------------------------------->

<cfscript>
	param name="url.rowid"                  default="";
	param name="form.action"                default="";
	if (! structKeyExists(request, "planner_event_obj")) {
		request.planner_event_obj = createObject("component", "mvc.models.planner.plannereventmanager");
	}
	if (! structKeyExists(request, "rowid")) {
		request.rowid = url.rowid;
	}

	document_path = application.doc_path & "\data_files\uploaded\documents\uploaded_doc\";
</cfscript>

<cfif form.action is "delete">
	<cfquery name="delete" datasource="#application.datasource#">
		UPDATE Planner_Event_Documents
		   SET Deleted = 1
		 WHERE Planner_Event_ID = <cfqueryparam value="#url.rowid#">
		       AND Doc_ID =  <cfqueryparam value="#form.doc_id#">
	</cfquery>

<cfelseif form.action is "upload">
	<cffile action = "upload"
			fileField    = "form.upload_file"
			destination  = "#document_path#"
			nameConflict = "MakeUnique">

	<cfquery name="upload" datasource="#application.datasource#">
		DECLARE @newDocID UNIQUEIDENTIFIER
		SET @newDocID = NewID()

		INSERT INTO	Document_Details
						(	Doc_ID,
							Doc_Uni_Name,
							Doc_Title,
							Doc_Description,
							Uploaded_Date,
							Uploaded_By,
							Doc_File_Name,
							Doc_Size,
							Doc_Family,
							LastUpdated_UserId
						)
		VALUES	(	@newDocID,
			        '#cffile.serverFile#',
							'#cffile.clientFileName#',
							'#cffile.clientFileName#',
							#now()#,
							'#request.AccessStructure.user_id#',
							'#cffile.clientFileName#',
							'#cffile.fileSize#',
							'#cffile.serverFileExt#',
							'#request.AccessStructure.user_id#'
						)

		INSERT INTO Planner_Event_Documents
					(	Planner_Event_ID,
						Doc_ID
					)
			VALUES  (
						'#url.rowid#',
						@newDocID
					)
	</cfquery>
</cfif>

<cfscript>
	qDocuments = request.planner_event_obj.getDocuments( url.rowid );
</cfscript>

<cf_layout_planner_event>

<cf_include files="/styles/css-loader.css, /common_files/dhx_message.cfm, /common_files/datatable2.css, /common_files/dataTables2.cfm">
<cfset jQueryUI.widgets = "tooltip,datepicker">
<cfinclude template="/common_files/jQueryUI.cfm">

<style>
	div.dataTable {
		margin: 1%;
		width: 98%;
	}
	div.upload {
		position: relative;
		top: -5px;
	}
	.file {
	  position: absolute;
	  clip: rect(0px, 0px, 0px, 0px);
	  display: block;
	}
	div.actions {
		position: relative;
		top: -2px;
	}
	a.download {
		margin-right: 20px;
	}
	a.browse, a.upload, a.return {
		margin-left: 40px;
	}
	.clicked {
		background-color:#E5E5E5 !important;
	}
</style>

<cfoutput>
	<form name="documents" method="post" enctype="multipart/form-data">
		<input type=hidden name=action>
		<input type=hidden name=doc_id>

		<cfsavecontent variable="upload"><input name='upload_file' type='file' onchange='handleFiles(this.files)' id='upload_file' class='file'> <a class=browse>#application.util.string.linkFormat( 'browse file to upload' )#</a><a class=return>#application.util.string.linkFormat('return to events list')#</a></cfsavecontent>

		<div class="dataTable">
			<table class="dataTable row-border order-column hover document">
				<thead>
					<th class="dt-head-left">Uploaded Date</th>
					<th class="dt-head-left">Uploaded By</th>
					<th class="dt-head-left">File Name</th>
					<th class="dt-head-center">File Size</th>
					<th class="dt-head-center">Action</th>
				</thead>
				<tbody></tbody>
			</table>			
		</div>
	</form>
</cfoutput>

<cfset data_set = []>
<cfoutput query="qDocuments">
	<cfset arrayAppend(data_set, [	application.util.dateTime.DateTimeFormat( qDocuments.Uploaded_date, "mmm d, yyyy" ),
									qDocuments.Uploader,
									qDocuments.Doc_File_Name & "." & qDocuments.Doc_Family,
									numberFormat( qDocuments.Doc_Size, ",9" ),
									qDocuments.Doc_ID
									])>
</cfoutput>

<script>
	function handleFiles( files ) {
	  if ( files.length ) {
	  	show_loader();
	  	$("input[name=action]").val( "upload" );
		$("form[name=documents]").submit();
	  }
	}

	$("table.document").DataTable({
		columns: [
					{},
					{},
					{ render: function( cell ) {
						return "<a class=download title='click to view the document.' file='" + cell + "'>" + cell + "</a>"; 
					  } },
					{ className:"dt-body-right" },
					{ orderable:false, className:"dt-body-center actions", width:"20%", 
						render: function( cell ) {
							return <cfoutput> "<div class=actions>"
								+ "<a class=delete doc_id=" + cell + ">#application.util.string.linkFormat('delete')#</a></div>" </cfoutput>; 
						} }
					],
		data: <cfoutput>#serializeJSON( data_set )#</cfoutput>,
		dom    : 'f<"upload">ti',
		language: { search: "Search Document:", emptyTable: "There is no document yet.", info:"Showing _START_ to _END_ of _TOTAL_ documents"  },
		order  : [ ],
		scrollY: "50vh",
		paging : false
	});
	$("div.upload").html( <cfoutput>"#upload#"</cfoutput> );

	$("a.download").click(function(){
		popupInCenter( "/getDocument.cfm?FilePath=/common_documents/data_files/uploaded/documents/uploaded_doc/" + $(this).attr("file"), "Download Document", 450, 300 );
	});

	$("a.delete").click(function(){
		var doc_id        = ( $( this ).attr("doc_id") )
		    ,selected_row = $( this ).parents( "tr" );
		selected_row.addClass( "clicked" );

		dhtmlx.confirm({
		    type:"confirm",
		    text: "Are you sure you want to delete?",
		    ok: "DELETE",
		    callback: function( ok_to_delete ){
		        if ( !ok_to_delete ) {
					selected_row.removeClass( "clicked" );
		        }
		        else {
		        	show_loader();
		        	$("input[name=doc_id]").val( doc_id );
		        	$("input[name=action]").val( "delete" );
		        	$("form[name=documents]").submit();
		        };
		    }
		});
	});

	$("a.browse").click(function() {
	    $("#upload_file").trigger( 'click' );
	  });	

	$("a.return").click(function(){
		window.location = "list.cfm";
	});
</script>

</cf_layout_planner_event>