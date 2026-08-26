<cfcomponent hint="Release Tracker">
	<cffunction name="InsertManualModifications" output="true" returntype="string">

		<cfargument name="File_Path_List" type="string" required="true" access="private">
		<cfargument name="Name" type="string" required="true" access="private">
		<cfargument name="Installed_Date" type="string" required="true" access="private">
		<cfargument name="Release_version" type="string" required="true" access="private">
		<cfargument name="Label_Number" type="string" required="true" access="private">
		<cfargument name="Comments" type="string" required="true" access="private">

	<cftransaction>
		<!--- Add the file information in the db (loop over a list of file path info). --->
		<cfloop list ="#arguments.file_path_list#" index="file_path"  delimiters="#chr(13)&chr(10)#">

			<!--- Derive the file name based on the file path and remove the slash at the beginning of the file path --->
			<cfset File_Name = Right(File_Path, Find("#chr(92)#", Reverse(File_Path)))>
			<cfset File_Name = Right(File_Name, Len(File_Name)-1)>
			<cfset File_Type = Right(File_Path, Find(".", Reverse(File_Path))-1)>

			<cfif Lcase(File_Type) eq "sql">
				<cfset file_path = Right(file_path, FindnoCase(Reverse("Awayx_sql"), Reverse(file_path))-2)>
			<cfelse>
				<cfset file_path = Right(file_path, FindnoCase(Reverse("Awayx"), Reverse(file_path))-2)>
			</cfif>

			<cfset file_path = "\" & file_path>

			<cfif lcase(right(file_path,3)) eq "sql">
				<cfset CF_Installation = 0>
			<cfelse>
				<cfset CF_Installation = 1>
			</cfif>

			<cfset DBObjects = "Jobs,Index,Reports,Stored_Procedure,Table,Trigger,UDF,View">
		
		<!--- If the sql file is not stored in the root folder. Example of a file stored in the 
			  root folder - "C:\SQL Files\AwayX_SQL\xyz.sql" --->
		<cfif Len(File_Path)- Find('\',Reverse(File_Path)) neq 0>
		 <cfif Lcase(File_Type) eq "sql"  AND Find('\', Left(File_Path,Len(File_Path)- Find('\',Reverse(File_Path)))) neq 0>
				<!--- Here the file_type could be any of the db objects listed in the comma-delimited list --->
				<cfset File_Type = Right(Left(File_Path,Len(File_Path)-Find('\',Reverse(File_Path))),Find('\',Reverse(Left(File_Path,Len(File_Path)-Find('\',Reverse(File_Path)))))-1)>
				<!--- If the file_type does not exist in the db objects listed in the comma-delimited list --->
				<cfif ListFindNoCase(DBObjects, File_Type) eq 0>
					<cfset File_Type = "sql">
				</cfif>
		 </cfif>
		</cfif>
		
			<CFQUERY NAME="qryInsertManualModifications" datasource="#application.datasource#">
			<!--- Object_type means a "sp/view/index/udf/cfm/css/js" etc --->
				SET NOCOUNT ON

				INSERT INTO Application_Installation(Name,Installed_Date,File_Path,CF_Installation,Patch_Number,Release_version,Label_Number,File_name,Object_Type)
				VALUES('#arguments.Name#','#arguments.Installed_Date#','#File_Path#',#CF_Installation#,'N/A','#arguments.Release_version#','#arguments.Label_Number#','#File_Name#','#File_Type#')
				
				SELECT Application_Installation_ID = @@IDENTITY
				SET NOCOUNT OFF		
			</CFQUERY> 

		<cfif arguments.comments neq "">
			<CFQUERY NAME="qryInsertManualModificationsComments" datasource="#application.datasource#">	
				INSERT INTO Application_Installation_Aux_Data(Application_Installation_ID,Comments)
				VALUES('#qryInsertManualModifications.Application_Installation_ID#','#arguments.comments#')
			</CFQUERY>
		</cfif>

		</cfloop>
		
		<!--- When the user does not select any file (We need this because the query above is inside a loop and the list has no members
			  to loop through, when the user has not selected any file.) --->
		<cfif arguments.File_Path_List eq "" AND arguments.comments neq "">
		<CFQUERY NAME="qryInsertManualModifications" datasource="#application.datasource#">
		<!--- Object_type means a "sp/view/index/udf/cfm/css/js" etc --->
		SET NOCOUNT ON

		INSERT INTO Application_Installation(Name,Installed_Date,Patch_Number,Release_version,Label_Number,Object_Type,File_name)
		VALUES('#arguments.Name#','#arguments.Installed_Date#','N/A','#arguments.Release_version#','#arguments.Label_Number#','N/A','N/A')
									
		SELECT Application_Installation_ID = @@IDENTITY
		SET NOCOUNT OFF	
		</CFQUERY>

		<CFQUERY NAME="qryInsertManualModificationsComments" datasource="#application.datasource#">
			INSERT INTO Application_Installation_Aux_Data(Application_Installation_ID,Comments)
			VALUES('#qryInsertManualModifications.Application_Installation_ID#','#arguments.comments#')
		</CFQUERY>
		</cfif>
	</cftransaction>

		<cfreturn 1>
	</cffunction>
</cfcomponent>
