<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\Common_Files\Documents\upload_mass_documents.cfm
      Date:     Jul 25 2018
      Author:   Sharon Harris
	  Purpose:  Upload one or more files and process to store them.
				Process depends on "FormName", or BBID.  "FormName" currently this only supports "Programs"
				  	Can add more options here when needed
				ProgramList is the list (1 or more) of Program IDs to save the documents to
				BBID is the Billback Id to store the documents to
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="URL.FormName" default="">	<!--- based on this, decide how to process the upload --->
<cfparam name="URL.ProgramList" default="">
<cfparam name="URL.BBID" default="">


<style>
	#upl18 { font-size: 14px; }
</style>

<!--- Dropzone.js open source library is used for the file upload --->
<cf_include files=#arrayToList( [ "/common_files/dropzone.cfm", "/styles/ba_upload.css" ] )#>
<cfinclude template="/Common_Files/dhx_message.cfm" />

<!--- Setup the Upload processing - depends on where we came from --->
<cfif url.FormName eq "Programs">   
	<cfset url_path_vars = "/common_files/contracts/ajax/contract_attachments.cfm?Program_ID=#URL.ProgramList#&url.user=#request.AccessStructure.user_id#">
<cfelseif (URL.BBID neq "")>
	<cfset url_path_vars = "/billbacks/2020/ajax/BB_Attachments_Form.cfm?BBID=#URL.BBID#">
</cfif>


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


<!--- <br> --->
<!--- <button type="button" onClick="window.close();" class="button alt" style="display:block; margin:0 auto;">close window</button> --->

<!------------- Dropzone setup ------------->
<script>
	setupDropzone(
		"<cfoutput>#url_path_vars#</cfoutput>",  //upload url
		window.close,	//callback after acknowledging completion
		20,			// max files
		25);		// max size MiB

		
</script>



