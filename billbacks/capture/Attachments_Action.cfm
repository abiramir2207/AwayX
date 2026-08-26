<cfparam name="form.BillbackList" default="">
<cfparam name="form.BBID" default="">
<cfparam name="URL.BillbackList" default="">
<cfparam name="URL.BBID" default="">
<cfparam name="URL.AttachDoc" default="0">
<cfparam name="form.FlexAppName" default="">
<cfparam name="form.BBMassUpload" default="0">

<CFIF Form.update_state EQ 1>

	<!--- Delete all Attached Documents that belong to this billback --->
	<!---	If the request is for single billbacks OR the request is not for save and attach billback in one action (in this case, the user just uploads the document and does not visit this page from the document list page),
		then do not delete the existing records. The user can only add new documents for (multiple billbacks OR when the request is for save and attach billback in one action) at a time, not delete those.
	--->
	<cfif form.BillbackList eq "" AND URL.BillbackList eq "" AND URL.AttachDoc eq 0>
		<CFQUERY NAME="Delete_Attachments" datasource="#application.datasource#">
			DELETE FROM Contract_Attachments
			<cfif Form.BBID neq "">
			WHERE 	Billback_ID = '#Form.BBID#'
			<cfelseif URL.BBID neq "">
			WHERE 	Billback_ID = '#URL.BBID#'
			</cfif>
		</CFQUERY>
	</cfif>

	<!--- Save the Attached Documents --->
	<CFIF isdefined("FORM.Doc_ID")>

		<!--- Loop over the documents --->
		<CFLOOP INDEX="item" LIST="#Form.Doc_ID#" DELIMITERS=",">
			<cfif form.BillbackList eq "">
				<cfset useLakebaseForSave_Attachments = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
<cfif useLakebaseForSave_Attachments>
	<cftry>
		<cfset application.oLakebase.insertRow("contract_attachments", {
			"billback_id" = "#Form.BBID#",
			"doc_id" = "#item#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Attachments = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Attachments>
<CFQUERY NAME="Save_Attachments" datasource="#application.datasource#">
					INSERT	INTO Contract_Attachments
						(
							Billback_ID,
							Doc_ID
						)
					VALUES
						(
							'#Form.BBID#',
							'#item#'
						)
				</CFQUERY>
</cfif>
			<cfelse>
				<!--- If the request is to add for multiple billbacks, then loop through the billbacks. --->
				<CFLOOP INDEX="bb_id" LIST="#form.BillbackList#" DELIMITERS=",">
					<CFQUERY NAME="Save_Attachments" datasource="#application.datasource#">
						INSERT	INTO Contract_Attachments
						(
							Billback_ID,
							Doc_ID
						)
						VALUES
						(
							'#bb_id#',
							'#item#'
						)
					</CFQUERY>
				</CFLOOP>
			</cfif>
		</CFLOOP>
</CFIF>

<CFELSE>
	<!--- Save Attached Documents --->
	<!--- Loop over the documents --->
	<CFLOOP INDEX="item" LIST="#Form.Attachment_List#" DELIMITERS=",">
		<cfif form.BillbackList eq "">
			<cfset useLakebaseForAttachment_details = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
<cfif useLakebaseForAttachment_details>
	<cftry>
		<cfset application.oLakebase.insertRow("contract_attachments", {
			"billback_id" = "#FORM.BBID#",
			"doc_id" = "#item#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForAttachment_details = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAttachment_details>
<CFQUERY NAME="Attachment_details" datasource="#application.datasource#">
				INSERT	INTO Contract_Attachments
					(
						Billback_ID,
						Doc_ID
					)
				VALUES
					(
						'#FORM.BBID#',
						'#item#'
					)
			</CFQUERY>
</cfif>
		<cfelse>
			<!--- If the request is to add for multiple billbacks, then loop through the billbacks. --->
			<CFLOOP INDEX="bb_id" LIST="#form.BillbackList#" DELIMITERS=",">
				<CFQUERY NAME="Attachment_details" datasource="#application.datasource#">
					INSERT	INTO Contract_Attachments
						(
							Billback_ID,
							Doc_ID
						)
					VALUES
						(
							'#bb_id#',
							'#item#'
						)
				</CFQUERY>
			</CFLOOP>
		</cfif>
	</CFLOOP>


</CFIF>

<cfif form.BBMassUpload EQ 0>
<!--- If it is a non-flex request --->
<cfif form.FlexAppName eq "">

	<CFLOCATION URL="Billback_Summary.cfm?BBID=#FORM.BBID#" ADDTOKEN="NO">

<cfelse>

	<!---	If the action taken by the user is just attaching OR deleting attachments, then send the list of billback_id_int back to flex and close the popup page.
		The same action (sending a list of billback_id_int back to flex and close the popup page) is on "common_files\documents\create_multiple_document_details.cfm"
		after the upload and attaching uploaded documents is completed.
	--->
	<cfif URL.AttachDoc eq 0>
		<CFQUERY NAME="getBBIDInt" datasource="#application.datasource#">
			SELECT Billback_ID_Int
			FROM Billback
			<cfif form.BillbackList neq "">
			WHERE Billback_ID IN (#ListQualify(form.BillbackList,"'")#)
			<cfelse>
			WHERE Billback_ID = '#Form.BBID#'
			</cfif>
		</CFQUERY>

	<!--- If the request is from flex, then send a list of billback_id_int to flex. It could be one or many. --->
	<cfoutput>
		<!--- implement call to externalinterface --->
		<script language="javascript">
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
			  getFlexApp('#form.FlexAppName#').saveDocs('#valueList(getBBIDInt.Billback_ID_Int)#');
			}
			saveDocs();
			window.close();
		</script>
	</cfoutput>

	</cfif>
</cfif>
</cfif>