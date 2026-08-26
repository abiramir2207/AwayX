<cfcomponent hint="Futures Pricing Document Manager" extends="components.document.DocumentManager">
	
	<cffunction name="init" output="false" returntype="components.futures_pricing.DocumentManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getRequestDocuments" output="false" returntype="query">
	
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="sort_by" type="string" required="false" default="" />
		<cfargument name="sort_order" type="string" required="false" default="" />
		
		<cfset sql_Sort_By = this.getSortString(arguments.sort_by, arguments.sort_order) />
		
		<cfquery name="qGetRequestDocuments" datasource="#application.datasource#">
		
			SELECT	Document_Details.Doc_ID, Document_Details.Doc_File_Name, Document_Details.Uploaded_Date,
					(Document_Details.Doc_size/1024) AS Doc_size_KB, 
					Document_Details.Doc_Uni_Name,
					Document_Details.Doc_Title, Document_Details.Doc_Description, Document_Details.Doc_Type,
					_Users.Name_First + ' ' + _Users.Name_Last AS UploadedByName
			FROM	FP_Document
					INNER JOIN Document_Details
					ON
					Document_Details.Deleted = 0
					AND
					FP_Document.Doc_ID = Document_Details.Doc_ID
					LEFT JOIN _Users
					ON
					_Users.Deleted = 0
					AND
					Document_Details.Uploaded_By = _Users.User_ID
			WHERE
					FP_Document.Deleted = 0
					AND
					FP_Request_Master_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">		
			ORDER BY #sql_Sort_By#
		</cfquery>
		
		<cfreturn qGetRequestDocuments />
	
	</cffunction>
	
	<cffunction name="saveRequestDocuments" output="false">
	
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="docIdList" type="string" required="true" />
		
		<!------ delete existing documents ----->
		<cfquery name="qDeleteRequestDocuments" datasource="#application.datasource#">
	
			UPDATE	FP_Document
			SET		Deleted = 1
			WHERE
					Deleted = 0
					AND
					FP_Request_Master_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
		<!------ loop thru documents ids ----->
		<cfloop list="#arguments.docIdList#" index="docId">
		
			<!------ insert document ----->
			<cfquery name="qInsertDocument" datasource="#application.datasource#">

				INSERT INTO FP_Document
					(
						Doc_ID,
						FP_Request_Master_ID
					)
				VALUES
					(
						<cfqueryparam value="#docId#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
					)				
			</cfquery>
		
		</cfloop>
		
	</cffunction>
	
</cfcomponent>
