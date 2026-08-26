
<!--- Kill extra output. --->
<cfsilent>

	<!---
		Set the directory that we are going to be viewing.
		This is the ROOT directory. We will be able to view
		files that are in sub-directories of this one. Access
		above this directory will be highly restricted.
	--->
	<cfset REQUEST.RootDirectory = ExpandPath( "/" ) />
	<!--- <cfset REQUEST.RootDirectory = ExpandPath( "/customTags/" ) /> --->

	<!---
		Set the list of valid file extensions. This way, you
		can limit the viewable files. This list is composed of
		space delimited values. If you don't want to restrict
		the file types, just put in * for entire string.
	--->
	<cfset REQUEST.FileTypes = "*" />

	<!---
		Param the URL file variable. This will be the root
		relevant path to the target file (does NOT start with a
		leading slash). If you want to start out with a default
		file, then put in a default attribute value.
	--->
	<cfparam
		name="URL.file"
		type="string"
		default=""
		/>

	<cfset request.include_folders = [
		"billbacks",
		"budget",
		"clause_library",
		"common_files",
		"components",
		"customtags",
		"deductions",
		"direct_pricing",
		"includes",
		"libraries",
		"mvc",
		"planners",
		"reportwriter",
		"scheduled",
		"scorecard",
		"script",
		"search",
		"search_screens",
		"settings",
		"templates",
		"utils",
		"views"
		]>

	<cfset request.exclude_folders = [ "cvs", "common_documents", "temp_files", "flexdev", "flex" ]>

	<!--- ------------------------------------------------- --->
	<!--- ----- Do not edit the code past this point. ----- --->
	<!--- ------------------------------------------------- --->


	<!--- Include helper functions. --->
	<cfinclude template="_functions.cfm" />


	<!---
		Make sure that our root directory is a driectory only
		and does not contain any file information.
	--->
	<cfset REQUEST.RootDirectory = GetDirectoryFromPath(
		REQUEST.RootDirectory
		) />

	<!---
		Get the proper slash for this server environment.
		We will use the expanded path of the root directory
		to find the first file system slash.
	--->
	<cfset REQUEST.Slash = Left(
		REQUEST.RootDirectory.ReplaceFirst(
			JavaCast( "string", "^[^\\/]+" ),
			JavaCast( "string", "" )
			),
		1
		) />


	<!---
		Param the URL variable for file transfer. If this is
		not true, then the page will display the XHTML. If this
		is True, then it will return the binary output data.
	--->
	<cftry>
		<cfparam
			name="URL.getdata"
			type="boolean"
			default="0"
			/>

		<cfcatch>
			<cfset URL.getdata = 0 />
		</cfcatch>
	</cftry>


	<!---
		Now, we are going to clean the file value that was
		passed in. We need to make sure there are no security
		issues here or anything that might cause the system
		to break.
	--->

	<!---
		Remove any sneaky navigation hacks such as root
		directives or "up one" directives. This way, we
		will be able to stop people from navigating out of
		the root directory.
	--->
	<cfset URL.file = URL.file.ReplaceAll(
		JavaCast( "string", "(^[\\\/]+)|(\.\.[\\/]{1})|([\\/]{2,})|:" ),
		JavaCast( "string", "" )
		) />

	<!--- Put in the proper slashes. --->
	<cfset URL.file = URL.file.ReplaceAll(
		JavaCast( "string", "[\\\/]{1}" ),
		JavaCast( "string", "\#REQUEST.Slash#" )
		) />

	<!--- Decode the URL. --->
	<cfset URL.file = UrlDecode( URL.file ) />


	<!---
		ASSERT: At this point, our URL.file variable
		should contain a clean, root-relevent path.
	--->


	<!---
		Set a default target file. The target file is the
		full path (expanded path) for the file sent through
		URL.file. By default, it will be empty.
	--->
	<cfset REQUEST.TargetFile = "" />


	<!---
		Check to see if any file is being requested / selected.
		We don't yet care about returning it to the browser -
		we only want to make sure that it is a valid path.
	--->
	<cfif Len( URL.file )>

		<!---
			Check to make sure the file has a file extension.
			Currently, we can only work with files that have
			extensions.
		--->
		<cfif (
			Len( URL.file ) AND
			(NOT ListLen( GetFileFromPath( URL.file ), "." ))
			)>

			<!---
				There was no file extension so we are to
				consider this not a valid file name. Clear
				the file value.
			--->
			<cfset URL.file = "" />

		</cfif>


		<!---
			Get the target file by adding the root-relevant
			path to the root directory path. We are going to
			assume at this point that the root path always
			has a trailing slash.
		--->
		<cfset REQUEST.TargetFile = (
			REQUEST.RootDirectory &
			URL.file
			) />

		<!--- Check to see if the file exists. --->
		<cfif NOT FileExists( REQUEST.TargetFile )>

			<!--- Reset target file. --->
			<cfset REQUEST.TargetFile = "" />

		</cfif>

	</cfif>


	<!---
		ASSERT: At this point, we have cleaned the URL.file
		value and determined whether or not the file exists
		within the root directory (If it does not exist, then
		its value was cleared).
	--->


	<!---
		Check to see if we need to return any file data. The
		first call to this page should *never* do this. This
		will only be done on subsequent calls to the page that
		need to access and display file data.
	--->
	<cfif URL.getdata>

		<!---
			Check to see if the file exists and that it is a
			valid file type. We don't want people to open up
			just any old file type.
		--->
		<cfif (
			Len( REQUEST.TargetFile ) AND
			(
				(REQUEST.FileTypes EQ "*") OR
				ListFindNoCase(
					REQUEST.FileTypes,
					ListLast( REQUEST.TargetFile, "." ),
					" "
					)
			))>

			<!--- Read in the file data. --->
			<cffile
				action="READ"
				file="#REQUEST.TargetFile#"
				variable="REQUEST.FileData"
				/>

			<!--- Stream the file content to the browser. --->
			<cfcontent
				type="text/plain"
				variable="#ToBinary( ToBase64( REQUEST.FileData ) )#"
				/>

		<!---
			If the file was requested but it cannot be shown,
			then it was just not the proper type of file.
			Viewing it was restricted.
		--->
		<cfelseif Len( REQUEST.TargetFile )>

			<!--- Send back error message. --->
			<cfcontent
				type="text/plain"
				variable="#ToBinary( ToBase64( 'The requested file [ #URL.file# ] is not a readable text document.' ) )#"
				/>

		<!---
			If we have gotten this far then the file simply
			couldn't be found at the given path.
		--->
		<cfelse>

			<!--- Send back error message. --->
			<cfcontent
				type="text/plain"
				variable="#ToBinary( ToBase64( 'The requested file [ #URL.file# ] could not be found.' ) )#"
				/>

		</cfif>

	</cfif>



	<!---
		ASSERT: If we have made it this far, then we are going
		to be rendering the XHTML page (no file was returned).
	--->


	<!--- Get the files from the root directory. --->
	<cfdirectory
		action="list"
		directory="#REQUEST.RootDirectory#"
		sort="directory ASC"
		name="REQUEST.FileQuery"
		recurse="true"
		/>
<!---
		filter="*.cfm|*.cfc|*.js|*.css|*."
	<cfdump var="#request.filequery#" abort=true format="text">
 --->

		<!--- filter="*.cfm|*.cfc|*.js|*.css" --->

	<!--- Set page content type and clear buffer. --->
	<cfcontent
		type="text/html"
		reset="true"
		/>

</cfsilent>

<!DOCTYPE html>
<html>
<head>
	<title>File Explorer | Developer Tools</title>

	<!-- Linked files. -->
	<link href="https://fonts.googleapis.com/css?family=Inconsolata" rel="stylesheet">
	<link rel="stylesheet" type="text/css" href="./style.css"></link>
	<script type="text/javascript" src="jquery.pack.js"></script>
	<script type="text/javascript" src="scripts.js"></script>
</head>
<body>

	<cfoutput>

		<!-- BEGIN: Header. -->
		<!--- <div id="header">

			<h1>
				File Explorer
			</h1>

		</div> --->
		<!-- END: Header. -->


		<!-- BEGIN: File Frame. -->
		<div id="fileframe">

			<!-- BEGIN: File Tree. -->
			<div id="filetree">

				<!---
					Output the file tree list. This will create an
					unordered list of unordered lists.
				--->
				#OutputDirectory(
					REQUEST.FileQuery,
					REQUEST.RootDirectory,
					REQUEST.TargetFile,
					REQUEST.RootDirectory,
					REQUEST.Slash
					)#

			</div>
			<!-- END: File Tree. -->

		</div>
		<!-- END: File Frame. -->


		<!-- BEGIN: Content Frame. -->
		<div id="contentframe">

			<!-- BEGIN: Content. -->
			<div id="content">

				<h2>
					File: <span id="filename"></span>
				</h2>

				<!--- Output file data. --->
				<pre id="fileoutput"></pre>

			</div>
			<!-- END: Content. -->

		</div>
		<!-- END: Content Frame. -->


		<!-- Clear floats. -->
		<div class="clear">
			<br clear="all" />
		</div>


		<!-- BEGIN: Footer. -->
		<!--- <div id="footer">
		</div> --->
		<!-- END: Footer. -->

	</cfoutput>

</body>
</html>
