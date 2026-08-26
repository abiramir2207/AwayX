<cfcomponent hint="Document Manager" extends="components.base">

	<cffunction name="init" output="false" returntype="components.document.DocumentManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getDocumentsFromList" output="true" returntype="query">
	
		<cfargument name="idList" type="string" required="false" default="" />
		<cfargument name="sort_by" type="string" required="false" default="" />
		<cfargument name="sort_order" type="string" required="false" default="" />
		
		<cfset sql_Sort_By = this.getSortString(arguments.sort_by, arguments.sort_order) />
		
		<cfquery name="qGetRequestDocuments" datasource="#application.datasource#">
		
			SELECT	Document_Details.Doc_ID, Document_Details.Doc_File_Name, Document_Details.Uploaded_Date,
					(Document_Details.Doc_size/1024) AS Doc_size_KB, 
					Document_Details.Doc_Uni_Name,
					Document_Details.Doc_Title, Document_Details.Doc_Description, Document_Details.Doc_Type,
					_Users.Name_First + ' ' + _Users.Name_Last AS UploadedByName
			FROM	Document_Details
					LEFT JOIN _Users
					ON
					_Users.Deleted = 0
					AND
					Document_Details.Uploaded_By = _Users.User_ID
			WHERE
					Document_Details.Deleted = 0
					AND
					<cfif Len(arguments.idList) GT 0>
					Document_Details.Doc_ID IN (<cfqueryparam value="#arguments.idList#" cfsqltype="CF_SQL_VARCHAR" list="Yes">)
					<cfelse>
					1=2
					</cfif>
			ORDER BY #sql_Sort_By#
		</cfquery>
		
		<cfreturn qGetRequestDocuments />
	
	</cffunction>
	
	<cffunction name="getSortString" output="false" returntype="string">
	
		<cfargument name="sort_by" type="string" required="false" default="" />
		<cfargument name="sort_order" type="string" required="false" default="" />
		
		<cfset sql_Sort_By="Document_Details.Doc_Title">
		<cfswitch expression="#arguments.sort_by#">
			<cfcase value="Title">
				<cfset sql_Sort_By="Document_Details.Doc_Title">
			</cfcase>
			<cfcase value="Date">
				<cfset sql_Sort_By="Document_Details.Uploaded_Date">
			</cfcase>
			<cfcase value="Name">
				<cfset sql_Sort_By="_Users.Name_First">
			</cfcase>
			<cfcase value="File">
				<cfset sql_Sort_By="Document_Details.Doc_File_Name">
			</cfcase>
			<cfcase value="Description">
				<cfset sql_Sort_By="Document_Details.Doc_Description">
			</cfcase>
			<cfcase value="Type">
				<cfset sql_Sort_By="Document_Details.Doc_Type">
			</cfcase>
		</cfswitch>
		
		<cfif arguments.sort_order EQ "desc">
			<cfset sql_Sort_By="#sql_Sort_By# DESC">
		<cfelse>
			<cfset sql_Sort_By="#sql_Sort_By# ASC">
		</cfif>
		
		<cfreturn sql_Sort_By />
		
	</cffunction>
	
</cfcomponent>
