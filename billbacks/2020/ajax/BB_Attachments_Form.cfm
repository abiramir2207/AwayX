<!---------------------------------------------------------------------------------------------------------------------
      Template: \billbacks\2020\ajax\BB_Attachments_Form.cfm
      Date:     2020 April
      Purpose:  Upload document(s) to Billback

      Parameter: URL.BBID =

----------------------------------------------------------------------------------------------------------------------->
<cftry>
<cfset filePath = '#Application.Doc_Path#/Data_Files/Uploaded/Documents/Uploaded_Doc/'>
<cffile action="uploadall" destination='#filePath#' nameconflict="makeunique" result="variables.upload"> 

<cfloop from="1" to="#arrayLen(variables.upload)#" index="variables.index">

	<cfset fileName = '#variables.upload[ variables.index ].serverFile#'>

		<cfset newfileName = REReplace(fileName,"[^0-9A-Za-z. ]","","ALL")>
		<!--- Make sure the cleaned-up filename is unique --->
		<cfset newfileName = createUniqueFilename(folder="#filePath#", nameToTest="#newfileName#") />

		<cffile action = "rename" source = "#filePath##fileName#" destination = "#filePath##newfileName#" >

	<cfset variables.upload[ variables.index ].serverFile = newfileName>
</cfloop>

<cfquery name="variables.qMisc" datasource="#application.datasource#">
  SELECT a.User_Positions_ID
         , ( SELECT Upload_Document_Privacy_Off FROM _application_settings ) AS Upload_Document_Privacy_Off
    FROM User_Position_Holders a
   WHERE a.User_ID = '#request.AccessStructure.user_id#' AND a.User_Position_Type = 'P' AND	a.Deleted = 0
</CFQUERY>


<cfquery name="variables.save_data" datasource="#application.datasource#">
	DECLARE @newDocID UNIQUEIDENTIFIER

	<cfloop from="1" to="#arrayLen(variables.upload)#" index="variables.index">
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
								LastUpdated_UserId,
								User_Position_ID,
								Public_View
							)
			VALUES	(	@newDocID,
						'#variables.upload[ variables.index ].serverFile#',
								'#variables.upload[ variables.index ].clientFileName#',
								'#variables.upload[ variables.index ].clientFileName#',
								#now()#,
								'#request.AccessStructure.user_id#',
								'#variables.upload[ variables.index ].clientFileName#',
								'#variables.upload[ variables.index ].fileSize#',
								'#variables.upload[ variables.index ].serverFileExt#',
								'#request.AccessStructure.user_id#',
								#variables.qMisc.User_Positions_ID#,
								#variables.qMisc.Upload_Document_Privacy_Off#
							)
		<cfif url.BBID neq 0>
			<cfloop list="#url.BBID#" index="variables.Billback_ID">
				INSERT INTO Contract_Attachments
								(	Billback_ID,	Doc_ID )
				VALUES	( '#variables.Billback_ID#',	@newDocID	)
			</cfloop>
		</cfif>
	</cfloop>
</cfquery>

<!---send success status back--->
<cfoutput>#serializeJSON({STATUS=200, MESSAGE="Done"})#</cfoutput>
<cfcatch type="any" >
  <cfset RaiseException( cfcatch.detail )>
</cfcatch>
</cftry>

	
<!--- Check that a filename is unique in it's folder.  
	If not, create a unique name by appending a space then a number_ on the end
	Return the unique name (either the original or the newly created name) 
--->
<cffunction name="createUniqueFilename" returnType="string" hint="I create a unique file name">
	<cfargument name="folder" type="string" required="false" default="" />
	<cfargument name="nameToTest" type="string" required="true" default="" />

	<cfset uniqueFileName = nameToTest>

	<!---  Look for files w/ same name. If found, append space #, going up forever  --->
	<cfif fileExists("#folder##nameToTest#")>
		<cfset var keepGoing = true>
		<cfset var counter = 1>
		<cfloop condition="keepGoing">

			<cfset uniqueFileName = Left(nameToTest, nameToTest.lastIndexOf('.')) & " " & counter & '.' & ListLast(nameToTest,'.')>

			<cfif fileExists("#folder##uniqueFileName#")>
				<cfset counter++>
			<cfelse>
				<cfset keepGoing = false>
			</cfif>
		</cfloop>
	</cfif>
	<cfreturn uniqueFileName>	
</cffunction>


<cffunction name="RaiseException" output="true" hint="I handle exceptions.">
  <cfargument name="detail_message" type="string" default="Unexpected errors have occurred.">
  <cfoutput>#serializeJSON({STATUS=500, MESSAGE=JSStringFormat(arguments.detail_message)})#</cfoutput>
  <cfabort>
</cffunction>
