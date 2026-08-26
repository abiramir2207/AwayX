
<cffunction
	name="OutputDirectory"
	access="public"
	returntype="string"
	output="true"
	hint="Builds the directory structure.">

	<!--- Define arguments. --->
	<cfargument
		name="FileQuery"
		type="query"
		required="true"
		hint="The recursive CFDirectory query of the root directory."
		/>

	<cfargument
		name="Directory"
		type="string"
		required="false"
		default=""
		hint="The directory that we are going to be recursing through on the given iteration."
		/>

	<cfargument
		name="TargetFile"
		type="string"
		required="false"
		default=""
		hint="The file that we are selecting in the tree structure (contains full path value)."
		/>

	<cfargument
		name="RootDirectory"
		type="string"
		required="true"
		hint="The root directory for this application."
		/>

	<cfargument
		name="Slash"
		type="string"
		required="true"
		hint="The system slash that we need for creating paths."
		/>

	<!--- Define the local scope. --->
	<cfset var LOCAL = StructNew() />


	<!--- Remove any trailing slashes on path. --->
	<cfset ARGUMENTS.Directory = ARGUMENTS.Directory.ReplaceFirst(
		JavaCast( "string", "[\\\/]+$" ),
		JavaCast( "string", "" )
		) />

	<!--- Query for sub directories. --->
	<cfquery name="LOCAL.Directory" dbtype="query">
		SELECT
			directory,
			name
		FROM
			ARGUMENTS.FileQuery
		WHERE
			type = 'Dir'
		AND
			directory = <cfqueryparam value="#ARGUMENTS.Directory#" cfsqltype="cf_sql_varchar" />
		AND
			(
				1 = 1
			<cfloop from="1" to="#arrayLen(request.exclude_folders)#" index="local.folder_index">
				and lower(name) <> '#request.exclude_folders[local.folder_index]#'
			</cfloop>
			)
		ORDER BY
			name ASC
	</cfquery>


	<!--- Query for files. --->
	<cfquery name="LOCAL.File" dbtype="query">
		SELECT
			directory,
			name
		FROM
			ARGUMENTS.FileQuery
		WHERE
			type = 'File'
		AND
			directory = <cfqueryparam value="#ARGUMENTS.Directory#" cfsqltype="cf_sql_varchar" />
			and ( name like '%.cfm' or name like '%.cfc' or name like '%.css' or name like '%.js' )
		ORDER BY
			name ASC
	</cfquery>


	<!--- Output the tree structure. --->
	<cfsavecontent variable="LOCAL.Output">

		<!---
			Check for file of directories. We will only need
			to output the data list if we have one or the other.
		--->
		<cfif (
			LOCAL.Directory.RecordCount OR
			LOCAL.File.RecordCount
			)>

			<ul>
				<!--- Check to see if there are any directories. --->
				<cfif LOCAL.Directory.RecordCount>

					<cfloop query="LOCAL.Directory">

						<li>
							<a class="dir">#LOCAL.Directory.name#</a>

							<!---
								Since we are in a directory, we might need
								to output sub files and directories. Call this
								method recursively with the new base.
							--->
							#OutputDirectory(
								ARGUMENTS.FileQuery,
								(ARGUMENTS.Directory & ARGUMENTS.Slash & LOCAL.Directory.name),
								ARGUMENTS.TargetFile,
								ARGUMENTS.RootDirectory,
								ARGUMENTS.Slash
								)#
						</li>

					</cfloop>

				</cfif>


				<!--- Check to see if there are any files. --->
				<cfif LOCAL.File.RecordCount>

					<cfloop query="LOCAL.File">

						<!--- Get full, expanded path of the current file. --->
						<cfset LOCAL.FilePath = (LOCAL.File.directory & ARGUMENTS.Slash & LOCAL.File.name) />

						<!---
							Get relative file path. To do this, we are
							going to subtract the root directory from the
							full file path.
						--->
						<cfset LOCAL.RelativeFilePath = ReplaceNoCase(
							LOCAL.FilePath,
							ARGUMENTS.RootDirectory,
							"",
							"one"
							) />

						<li>
							<a
								id="#LOCAL.RelativeFilePath#"
								class="file<cfif (ARGUMENTS.TargetFile EQ LOCAL.FilePath)> selected</cfif>"
								>#LOCAL.File.name#</a>
						</li>
					</cfloop>

				</cfif>
			</ul>

		</cfif>

	</cfsavecontent>


	<!--- Clean the output. --->
	<cfset LOCAL.Output = LOCAL.Output.ReplaceAll(
		JavaCast( "string", "(?m)^\s+|\s+$|(?<=>)\s+|\s+(?=<)" ),
		JavaCast( "string", "" )
		) />

	<!--- Return the file tree sub-output. --->
	<cfreturn Trim( LOCAL.Output ) />
</cffunction>
