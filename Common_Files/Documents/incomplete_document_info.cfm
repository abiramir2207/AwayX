<cfparam name="URL.BBID" default="">
<cfparam name="URL.BillbackList" default="">
<cfparam name="URL.FlexAppName" default="">

<!---	Flex needs "document title" to show attached documents for a billback, but description is not shown in flex. When the "DocumentsDisplayUploadForm" app setting is ON and the user
	is suppposed to fill up the document related form, the user could close the popup page and not fill up the form and since the document upload and attachment happens before the user
	fills up the document related info, we could have documents attached to a billback, but not show up in a billback. Even though default information for document title, type and public view
	is filled up, document description is purposely kept blank so that we know that we need to show the document related form to the user to fill up (modify). If all the default information
	is filled up, then we do not know which form needs to be filled up by the user.
--->
<!--- Document dscription is the only field which is kept blank when "DocumentsDisplayUploadForm" app setting is ON --->
<cfset useLakebaseForGetIncompleteDocumentInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("document_details")>
<cfif useLakebaseForGetIncompleteDocumentInfo>
	<cftry>
		<cfset GetIncompleteDocumentInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("document_details", { "doc_description" = "is.null", "uploaded_by" = "eq.#request.accessStructure.User_ID#" })
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetIncompleteDocumentInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetIncompleteDocumentInfo>
	<CFQUERY NAME="GetIncompleteDocumentInfo" DATASOURCE="#Application.Datasource#">
		SELECT *
		FROM 	Document_Details
		WHERE Doc_Description IS NULL
		AND Uploaded_By = '#request.accessStructure.User_ID#'
	</CFQUERY>
</cfif>

<!--- If we have any document loaded by the user accessing the application which has incomplete information, then let the user fill up forms for individual documents --->
<cfif GetIncompleteDocumentInfo.recordcount GT 0>
	<cflocation url="create_Document_Details.cfm?RID=#GetIncompleteDocumentInfo.Doc_ID#&IncompleteDocumentInfo=1&FlexAppName=#URL.FlexAppName#&BBID=#URL.BBID#&BillbackList=#URL.BillbackList#" ADDTOKEN="No">
<cfelse>
<!--- Redirect the user to the "multiple upload" page, where the page will close and the user will be send back to flex. --->
	<cflocation url="create_multiple_document_details.cfm?IncompleteDocumentInfo=0&FlexAppName=#URL.FlexAppName#&BBID=#URL.BBID#&BillbackList=#URL.BillbackList#" ADDTOKEN="No">
</cfif>