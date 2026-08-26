	<cfparam name="URL.BBID" default="">
	<cfparam name="FORM.BillbackList" default="">
	<cfparam name="URL.Program_Qualification_ID" default="">
	<cfparam name="URL.ProgramList" default="">
	<cfparam name="URL.FlexAppName" default="">
	<cfparam name="URL.FormName" default="">
	<cfparam name="URL.IncompleteDocumentInfo" default="1">
	<cfparam name="URL.BBMassUpload" default="0">

	<cfset appSettings = application.appSettingsGet />

	<!--- BILLBACK --->
	<cfif URL.BBID neq "" OR FORM.BillbackList neq "">
		<cfset useLakebaseForGetBBIDInt = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
		<cfif useLakebaseForGetBBIDInt>
			<cftry>
				<cfset getBBIDIntFilter = { "select" = "billback_id_int" }>
				<cfif FORM.BillbackList neq "">
					<cfset getBBIDIntFilter["billback_id"] = "in.(#FORM.BillbackList#)">
				<cfelseif URL.BBID neq "">
					<cfset getBBIDIntFilter["billback_id"] = "eq.#URL.BBID#">
				</cfif>
				<cfset getBBIDInt = application.oLakebase.toQuery(
					application.oLakebase.selectRows("billback", getBBIDIntFilter)
				, "Billback_ID_Int")>
				<cfcatch type="any">
					<cfset useLakebaseForGetBBIDInt = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForGetBBIDInt>
			<CFQUERY NAME="getBBIDInt" datasource="#application.datasource#">
				SELECT Billback_ID_Int
				FROM Billback
				<cfif FORM.BillbackList neq "">
					WHERE Billback_ID IN (#ListQualify(FORM.BillbackList,"'")#)
				<cfelse>
					<cfif URL.BBID neq "">
					WHERE Billback_ID = '#URL.BBID#'
					</cfif>
				</cfif>
			</CFQUERY>
		</cfif>
	</cfif>

	<cfset bDocumentsDisplayUploadForm =  appSettings.getDocumentsDisplayUploadForm()>

	<style>
		#upl18 { font-size: 14px; }
	</style>

	<!--- Dropzone.js open source library is used for the file upload --->
	<cf_include files=#arrayToList( [ "/common_files/dropzone.cfm", "/styles/ba_upload.css" ] )#>

	<script language="javascript">
		function uploadComplete(){
			/* redirect to "incomplete_document_info.cfm", so that the document related information (form) can be filled up. */
			<cfoutput>
				<cfif URL.BBID neq "" OR FORM.BillbackList neq "">
					location.href='incomplete_document_info.cfm?FlexAppName=#URL.FlexAppName#&BBID=#URL.BBID#&BillbackList=#FORM.BillbackList#';
				<cfelseif URL.ProgramList neq "">
					location.href='incomplete_document_info.cfm?FlexAppName=#URL.FlexAppName#&ProgramList=#URL.ProgramList#';
					<!---The request is not from inside the flex application. --->
				<cfelseif URL.Program_Qualification_ID neq "">
					document.qualifications.NumberOfDocs.value++;
				</cfif>
			</cfoutput>
		}

		<!--- implement call to externalinterface --->
		// This function returns the appropriate reference,
		// depending on the browser.
		function getFlexApp(appName)
		{
			if (navigator.appName.indexOf ("Microsoft") !=-1)
			{
			return opener.window[appName];
			}
			else
			{
			return opener.document[appName];
			}
		}

		function saveDocs()
		{
		<cfif URL.FlexAppName neq "">
			<cfif bDocumentsDisplayUploadForm eq 0 OR URL.IncompleteDocumentInfo eq 0>
			<cfoutput>
				<cfif URL.BBID neq "" OR FORM.BillbackList neq "">
				getFlexApp('#URL.FlexAppName#').saveDocs('#valueList(getBBIDInt.Billback_ID_Int)#');
				<cfelseif URL.ProgramList neq "">
				getFlexApp('#URL.FlexAppName#').saveDocs();
				</cfif>
			</cfoutput>
				/* The upload and document form filling (if necessary) is complete. Close the window. */
				window.close();
			<cfelse>
				uploadComplete();
			</cfif>
		<cfelse>
			<!---The request is not from inside the flex application. --->
			<cfif URL.Program_Qualification_ID neq "">
					uploadComplete();
			</cfif>
		</cfif>
		}

		<cfif URL.FlexAppName neq "">
			/* When the information for all the uploaded documents is completed, Call "saveDocs", to send the user back to flex. */
			<cfif URL.IncompleteDocumentInfo eq 0>
				saveDocs();
			</cfif>
		</cfif>
	</script>

	<!--- There are 3 events available with this tag.
		onComplete - This action takes place after each upload. (This is not currently being used with this tag).
		onUploadComplete - This action takes place after all the uploads are completed. (This is being used with this tag).
		onError - This action takes place on error.  (This is not currently being used with this tag).
	--->
	<cfset Is_From_BB = false>
	<cfif url.FormName eq "Flex">   <!--- 44383 --->
		<cfset url_path_vars = "/common_files/contracts/ajax/contract_attachments.cfm?Program_ID=#URL.ProgramList#">
	<!--- BILLBACK --->
	<cfelseif (URL.BBID neq "" OR FORM.BillbackList neq "") AND URL.BBMassUpload EQ 0>
		<cfset url_path_vars = "save_multiple_document_details.cfm?FlexAppName=#URL.FlexAppName#&BBID=#URL.BBID#&BillbackList=#FORM.BillbackList#">
		<cfset Is_From_BB = true>
	<!--- BILLBACK MASSUPLOAD --->
	<cfelseif (URL.BBID neq "" OR FORM.BillbackList neq "") AND URL.BBMassUpload>
		<cfset url_path_vars = "/common_files/documents/ajax/save_multiple_document_details.cfm?BBMassUpload=#url.BBMassUpload#&BillbackList=#listfirst(FORM.BillbackList)#">
	<!--- PROGRAM --->
	<cfelseif URL.ProgramList neq "">
		<cfset url_path_vars = "save_multiple_document_details.cfm?FlexAppName=#URL.FlexAppName#&ProgramList=#URL.ProgramList#">
	<!--- PROGRAM QUALIFICATION--->
	<!---The request is not from inside the flex application. --->
	<cfelseif URL.Program_Qualification_ID neq "">
		<cfset url_path_vars = "/common_files/documents/ajax/save_multiple_document_details.cfm?Program_Qualification_ID=#URL.Program_Qualification_ID#">
	</cfif>

	<cfinclude template="/Common_Files/dhx_message.cfm" />

<!---  Use flag to choose old Flash upload vs new dropzone upload --->
<!---  WR 95957 SAH: Also, GM will still use the old Flash for thier initial 8.1 Billbacks so keep the old Flash upload for that for now --->
<cfif ( application.util.query.get_setting("upload_documents_method", false) EQ "flash" ) OR
		( application.util.query.get_setting("GM_BB_upload_documents_method", false) EQ "flash") AND (Is_From_BB EQ true)>

	<!--- CFFILEUPLOAD HERE --->
	<div style="margin:10px;">
	<cffileupload
		name = "uploadDemo"
		url="#url_path_vars#"
		progressbar="true"
		addButtonLabel = "Select File(s)"
		clearButtonLabel = "Clear"
		align="center"
		width="500"
		height="250"
		title="Select multiple files for upload"
		maxUploadSize="20" <!---(in MB)--->
		maxFileSelect="10"
		uploadButtonLabel = "Upload"
		onUploadComplete="saveDocs"
		>
	</cffileupload>
		<cfif url.FormName eq "Flex">  <!--- 44383 --->
			<br>
			<cfoutput><a href="##" onclick="window.close();">#application.util.string.actionLinkFormat2( "close window" )#</a></cfoutput>
		</cfif>
	</div>
		<!--- Unused attributes for "cffileupload" tag. There are more unused attributes available for this tag) --->
		<!---
		extensionfilter="*.txt,*.jpg,*.png,*.doc" (If we know what document types the user will upload)
		--->

<cfelse>
	<!--- Replace the Flash upload with a javaScript one based on the dropzone.js library --->
	<br>
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
	</div> <!-- #upl18 -->

	<!------------- Dropzone setup ------------->
	<script>
		 setupDropzone(
			"<cfoutput>#url_path_vars#</cfoutput>",  //upload url
			saveDocs,	//callback after acknowledging completion
			20, 		// max files
			19);		// max size MiB

	// pass a dynamic selected entries to the ajax process
	    myDropzone.on( "sending", function( file, xhr, formData ) {
             formData.append( "BillbackList", "<cfoutput>#form.BillbackList#</cfoutput>" );
            });        

	</script>
</cfif> <!--- end of Dropzone upload --->