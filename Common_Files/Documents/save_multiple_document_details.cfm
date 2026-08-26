<cfparam name="URL.BBID" default="">
<cfparam name="URL.BillbackList" default="">
<cfparam name="URL.Program_Qualification_ID" default="">
<cfparam name="URL.ProgramList" default="">
<cfparam name="URL.FlexAppName" default="">

<cfset UserManager = CreateObject("component", "components.user.UserManager").init() />
<cfset appSettings = application.appSettingsGet />
<cfset bDocumentsDisplayUploadForm =  appSettings.getDocumentsDisplayUploadForm()>
<cfset bUploadDocumentPrivacyOff =  appSettings.getUploadDocumentPrivacyOff()>

<!--- Get the user position ID (primary) --->
<cfset PrimaryPositionID = UserManager.getPositionId(userId=request.accessStructure.User_ID,isPrimary=1)>

<!--- Get the TOP 1 document type. --->
<cfset useLakebaseForListDocType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("document_type")>
<cfif useLakebaseForListDocType>
	<cftry>
		<cfset List_Doc_Type = application.oLakebase.toQuery(
			application.oLakebase.selectRows("document_type", { "deleted" = "eq.false", "select" = "doc_type", "limit" = "1" })
		, "Doc_Type")>
		<cfcatch type="any">
			<cfset useLakebaseForListDocType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForListDocType>
	<CFQUERY NAME = "List_Doc_Type" DATASOURCE = "#Application.Datasource#">
		SELECT Top 1 Doc_Type
		FROM Document_Type
		WHERE Deleted = 0
	</CFQUERY>
</cfif>
	
<!--- In the database Table "Document_Details", the column "Public_View" of 1 actually means private rather than public and so
I am reversing the logic below.
--->
<cfif bUploadDocumentPrivacyOff eq 1>
	<cfset bUploadDocumentPrivacyOff = 0>
<cfelse>
	<cfset bUploadDocumentPrivacyOff = 1>
</cfif>

<!--- Upload document in the "temp_Uploaded_doc" folder (This folder holds files temporarily). This file is called once for every file upload. This is used for multiple file uploads in one action.
<cffile action = "uploadAll" destination = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_doc\" nameConflict = "MakeUnique">
--->

<cffile action="uploadall" destination="#Application.Doc_Path#\Data_Files\Uploaded\Documents\Uploaded_Doc\" nameconflict="makeunique">

<cfset arUploadDetails = ArrayNew(1)>
<cfif isDefined("CFFILE.serverFile")><!--- CF 9 --->
	<cfset arUploadDetails[1] = CFFILE />	
<cfelseif  isDefined("CFFILE.UPLOADALL_RESULTS")><!--- CF 11 --->
	<cfset arUploadDetails = CFFILE.UPLOADALL_RESULTS />
<cfelseif  isDefined("CFFILE.UPLOADALLRESULTS")><!--- CF 2016 --->
	<cfset arUploadDetails = CFFILE.UPLOADALLRESULTS />
</cfif>

<cfset arLen = ArrayLen(arUploadDetails) />

<!--- Loop over each uploaded file --->
<cfloop from="1" to="#arLen#" index="LoopCount">

	<!--- This is the name of the uploaded file --->
	<CFSET Temp_File_name = arUploadDetails[LoopCount].serverFile />
	
	<!--- Set the document title to be the filename. --->
	<cfset DocumentTitle =  Temp_File_name>
	
	<!--- If there are more than 125 characters in the document title, do not show the remaining characters (show it till character 123. Remaining 2 characters are dots) --->
	<cfif Len(DocumentTitle) GT 125>
		<cfset DocumentTitle = LEFT(DocumentTitle,123)>
		<cfset DocumentTitle = DocumentTitle & "..">
	</cfif>
	
	<!--- Get the file extension --->
	<CFSET family = ListLast(Temp_File_name, ".")>
	
	<!--- Generate unique id. This will always be unique 
	<CFSET Unique_ID = createUUID()>
	--->
	<!--- This will be the unique filename for the uploaded file 
	<CFSET Actual_File_Name = "#Replace(Unique_ID,'-','_','all')#.#family#">
	--->
	<!--- Rename the file uploaded to the "Temp_Uploaded_doc" to the unique file name 
	<CFFILE ACTION = "rename"
			SOURCE = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_doc\#temp_file_name#"
			DESTINATION = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_Doc\#Actual_file_name#">
	--->
	<!--- Since the uploaded file has a unique name now, copy that file to "Uploaded_Doc" folder. This is the place from where it will be read. 		
	<CFFILE ACTION = "copy"
			SOURCE = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_doc\#Actual_file_name#"
			DESTINATION = "#Application.Doc_Path#\Data_Files\Uploaded\Documents\Uploaded_Doc\#Actual_file_name#">  
	--->

	<!---	Flex needs "document title" to show attached documents for a billback, but description is not shown in flex. When the "DocumentsDisplayUploadForm" app setting is ON and the user
		is suppposed to fill up the document related form, the user could close the popup page and not fill up the form and since the document upload and attachment happens before the user
		fills up the document related info, we could have documents attached to a billback, but not show up in a billback. Even though default information for document title, type and public view
		is filled up, document description is purposely kept blank so that we know that we need to show the document related form to the user to fill up (modify). If all the default information
		is filled up, then we do not know which form needs to be filled up by the user.
	 --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		SET NOCOUNT ON
		INSERT INTO	Document_Details
				(	Doc_Uni_Name,
					Uploaded_Date,
					Uploaded_By,
					Doc_Family,
					Deleted,
					Doc_File_Name,
					Doc_Size,
					LastUpdated_UserId,
					User_Position_ID
					
					<!--- We fill up default information for document title, type and public view --->
					,Doc_Title
					,Doc_Type
					,Public_View
	
					<!---- When the "DocumentsDisplayUploadForm" app setting is OFF, we fill up default information for description --->
					<cfif bDocumentsDisplayUploadForm eq 0>			
					,Doc_Description
					</cfif>
				)
						
		VALUES		(	'#Temp_File_name#',
					getDate(),
					'#request.accessStructure.User_ID#',							
					'#family#',
					0,
					'#form.filename#',
					#arUploadDetails[LoopCount].FileSize#,
					'#request.accessStructure.User_ID#',
					#PrimaryPositionID#
					
					<!--- We fill up default information for document title, type and public view --->
					,'#DocumentTitle#'
					,'#List_Doc_Type.Doc_Type#'
					,#bUploadDocumentPrivacyOff#
	
					<!---- When the "DocumentsDisplayUploadForm" app setting is OFF, we fill up default information for description --->
					<cfif bDocumentsDisplayUploadForm eq 0>				
					,'#form.filename#'
					</cfif>
				)
	
		SELECT Doc_ID = @@IDENTITY
		SET NOCOUNT OFF	
	</CFQUERY>
	
	<!--- These variables are required for "/billbacks/capture/Attachments_Action.cfm" --->
	<cfset URL.AttachDoc = 1>
	<cfset Form.Doc_ID = Save_Data.Doc_ID>
	<cfset Form.BBID = URL.BBID>
	<cfset Form.BillbackList = URL.BillbackList>
	<cfset Form.ProgramList = URL.ProgramList>
	<cfset Form.Program_Qualification_ID = URL.Program_Qualification_ID>
	<cfset Form.FlexAppName = URL.FlexAppName>
	<cfset Form.update_state = 1>
	
	
	<!--- Attach the document to a billback --->
	<cfif Form.BBID neq "" OR Form.BillbackList neq "">
		<cfinclude template="/billbacks/capture/Attachments_Action.cfm">
	<cfelseif Form.Program_Qualification_ID neq "">
		<cfinclude template="/common_files/contracts/qualifications_action.cfm">
	<cfelseif Form.ProgramList neq "">
		<cfinclude template="/common_files/contracts/contract_attachments_Action.cfm">
	</cfif>


</cfloop>