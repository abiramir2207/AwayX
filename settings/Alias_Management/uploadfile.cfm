<form name="frmAliasUpload" id="frmAliasUpload" method="post" action="uploadfile_action.cfm" ENCTYPE="multipart/form-data">
	<INPUT SIZE="45" TYPE="file" NAME="File_Path" ID="File_Path">
	<button type="button" onClick="frmAliasUpload.submit();" class="button recommended">
	upload file
	</button>
	<cfoutput>
	<input type="hidden" name="entity_type" id="entity_type" value="#url.entity_type#" />
	<input type="hidden" name="source_type" id="source_type" value="#url.source_type#" />
	<input type="hidden" name="source_id" id="source_id" value="#url.source_id#" />
	</cfoutput>
</form>