<cfcomponent name="programuploadmanager" hint="handles the function calls for Unified Program Upload">

	<!--- init --->
	<cffunction name="init" output="false" returntype="mvc.models.program.upload.programuploadmanager">
		<cfreturn this />
	</cffunction>

	<!--- insert the contents into db --->
	<cffunction name="fnDataInsert" access="remote" returntype="any" output="false" >
		<cfargument name="templateId" type="numeric" required="true" />
		<cfargument name="filePath" type="string" required="true" />
		<cfargument name="busSegment" type="string" required="true" />
		<cfargument name="creatorId" type="string" required="true" />

		<cfset var local.qInsert = "" />
		<cfset var local.nextBatchId = 0 />
		<cfset var local.read_failure = false />

		<cftry>
			<!--- column names & column order are important:  do not change them --->
			<cfspreadsheet action             = "read"
											src               = "#arguments.filepath#"
											query             = "qExcelEntries"
											headerrow         = "1"
											excludeHeaderRow  = "true" >

			<cfcatch type="any">
				<cfset local.read_failure = true>
				<cfset qExcelEntries = queryNew( qExcelEntries.columnList )>
			</cfcatch>
		</cftry>

		<cfif (!local.read_failure) >
			<cfquery name="qGetBatchId" datasource="#application.datasource#">
				Select (isnull(max(Batch_ID), 0)+1) as next_batch_id from Y_DEAL_UI_Upload
			</cfquery>
			<cfset local.nextBatchId = qGetBatchId.next_batch_id />

			<cfloop query="qExcelEntries">
				<cfquery name="local.qInsert" datasource="#application.datasource#">
					INSERT INTO Y_DEAL_UI_UPLOAD
					(
						Template,
						Batch_ID,
						Record_Type,
						Header_Action,
						External_Program,
						FORGE_Program,
						Title,
						Start,
						[End],
						RSP_ID,
						Position_ID,
						Segment,
						Sold_To,
						Operator_ID,
						Material,
						Rate,
						UOM,
						Discount_Type,
						Component,
						Pays_To,
						Frequency,
						Claim_Mechanic,
						Currency,
						Volume,
						Volume_UOM,
						Creator_ID,
						Upload_File_Name
						<cfif qExcelEntries.KeyExists("Group_ID")>
						,Group_ID
						</cfif>
						
					)
					VALUES
					(
						'#arguments.templateId#',
						'#local.nextBatchId#',
						'#qExcelEntries["Record Type"][currentrow]#',
						'#qExcelEntries["Header Action"][currentrow]#',
						'#qExcelEntries["External Program"][currentrow]#',
						'#qExcelEntries["FORGE Program"][currentrow]#',
						'#qExcelEntries["Title"][currentrow]#',
						'#qExcelEntries["Start"][currentrow]#',
						'#qExcelEntries["End"][currentrow]#',
						'#qExcelEntries["RSP ID"][currentrow]#',
						'#qExcelEntries["Position ID"][currentrow]#',
						'#arguments.busSegment#',
						'#qExcelEntries["Sold To"][currentrow]#',
						'#qExcelEntries["Operator ID"][currentrow]#',
						'#qExcelEntries["Material"][currentrow]#',
						'#qExcelEntries["Rate"][currentrow]#',
						'#qExcelEntries["UOM"][currentrow]#',
						'#qExcelEntries["Discount Type"][currentrow]#',
						'#qExcelEntries["Component"][currentrow]#',
						'#qExcelEntries["Pays To"][currentrow]#',
						'#qExcelEntries["Frequency"][currentrow]#',
						'#qExcelEntries["Claim Mechanic"][currentrow]#',
						'#qExcelEntries["Currency"][currentrow]#',
						'#qExcelEntries["Volume"][currentrow]#',
						'#qExcelEntries["VOLUME UOM"][currentrow]#',
						'#arguments.creatorId#',
						'#ListLast(arguments.filePath, "/")#'
						<cfif qExcelEntries.KeyExists("Group_ID")>
						,'#qExcelEntries["Group_ID"][currentrow]#'
						</cfif>
					)
				</cfquery>
			</cfloop>
		</cfif>
		<cfreturn local.nextBatchId />
	</cffunction>

	<!--- validate upload --->
	<cffunction name="validateUpload" access="remote" returntype="any">

		<cfargument name="batchId" type="numeric" required="true" />
		<cftry>
			<cfstoredproc procedure="USP_Unified_Program_Upload_Validate" datasource="#application.datasource#">
				<cfprocparam type="In" cfsqltype="CF_SQL_INTEGER" value="#arguments.batchId#" null="no" />
				<cfprocparam type="Out" cfsqltype="CF_SQL_INTEGER" variable="bIsValid" />
			</cfstoredproc>
			<cfcatch type="any">
				<cfreturn cfcatch.message />
			</cfcatch>
		</cftry>

		<cfreturn bIsValid />

	</cffunction>

	<!--- validate upload : error report --->
	<cffunction name="getValidateReport" access="remote" returntype="any">

		<cfargument name="batchId" type="numeric" required="true" />

		<cfset r = "" />

		<cfquery name="qGetReport" datasource="#application.datasource#">
			SELECT	Batch_ID,
					Record_Type,
					Header_Action,
					External_Program,
					FORGE_Program,
					Title,
					Start,
					[End],
					RSP_ID,
					Position_ID,
					Sold_To,
					Operator_ID,
					Material,
					Rate,
					UOM,
					Discount_Type,
					Component,
					Pays_To,
					Frequency,
					Claim_Mechanic,
					Currency,
					Volume,
					Volume_UOM,
					Error_Info,
					Upload_File_Name
			FROM	Y_DEAL_UI_Upload
			WHERE	Batch_ID = '#arguments.batchId#'
		</cfquery>

		<cfif qGetReport.RecordCount>
			<cfscript>
				r = writeReport(qGetReport, arguments.batchId);
			</cfscript>
		</cfif>

		<cfreturn r />

	</cffunction>

	<!--- create/process upload --->
	<cffunction name="exceuteUpload" access="remote" returntype="any">

		<cfargument name="batchId" type="numeric" required="true" />

		<cfstoredproc procedure="USP_Unified_Program_Upload_Create" datasource="#application.datasource#">
			<cfprocparam type="In" cfsqltype="CF_SQL_INTEGER" value="#arguments.batchId#" null="no" />
		</cfstoredproc>

		<cfset  r =  getExecuteReport(arguments.batchId) />

		<cfreturn r />

	</cffunction>

	<!--- create/process upload : post process report --->
	<cffunction name="getExecuteReport" access="remote" returntype="any">

		<cfargument name="batchId" type="numeric" required="true" />

		<cfset r = "" />

		<cfquery name="qGetExecuteReport" datasource="#application.datasource#">

			SELECT 	*
			FROM 	LOG_Y_DEAL_Program_Upload
			WHERE	Batch_ID = '#arguments.batchId#'
			AND		Upload_Ratio NOT IN ('R','D')

		</cfquery>

		<cfif qGetExecuteReport.RecordCount>
			<cfscript>
				r = writeReport(qGetExecuteReport, arguments.batchId);
			</cfscript>
		</cfif>

		<cfreturn r />

	</cffunction>


	<!--- write report file --->
	<cffunction name="writeReport" access="remote" returntype="any">

		<cfargument name="qReport" type="query" required="true" />
		<cfargument name="batchId" type="string" required="false" default="0" />

		<cfscript>

			output_file  = "program-upload-" & lCase(dateformat(now(), "mmm-d-yyyy")) & '-' & arguments.batchId;

			// pass true in the 2nd parameter to use the new XML format on XLSX file
			xlsx = spreadSheetNew(output_file, true);

			spreadSheetAddRow(xlsx, arrayToList(arguments.qReport.getColumnNames()));
			spreadSheetFormatRow(xlsx, {bold=TRUE, fgcolor="black", color="white"}, 1);

			// add rows in query
			spreadSheetAddRows(xlsx, arguments.qReport);


			// center UOM columns
			//spreadsheetFormatColumns(xlsx, {alignment="center"}, "4,6");
			output_fullpath = (application.doc_path & "\temp_files\" & output_file & ".xlsx");

			rFilePath = "temp_files/" & output_file & ".xlsx";
		</cfscript>

		<cfspreadsheet action="write" name = "xlsx" filename = #output_fullpath# overwrite = "true">

		<cfreturn rFilePath />

	</cffunction>


	<!--- email the error/success report to user --->
	<cffunction name="emailReport" access="remote" returntype="any">

		<cfargument name="filePath" type="string" 	required="true" />
		<cfargument name="userEmail" type="string" 	required="true" />
		<cfargument name="emailMessage" type="string" 	required="true" />

			<cfset output_fullpath = application.doc_path & "\" & arguments.filePath />

		<!--- Email Functionality Begins Here --->
		<CF_EMAILWRAPPER
			from=""
			to="#arguments.userEmail#"
			subject="Program Upload Report"
			type="html"
			messagetype="1"
			generatedby="1"
			apparea="1"
			logMessage="1">

				<cfoutput>#arguments.emailMessage#</cfoutput>
				<cf_emailwrapperparam file = "#output_fullpath#">


		</CF_EMAILWRAPPER>
		<!--- Email Functionality Ends Here --->

	</cffunction>

</cfcomponent>
