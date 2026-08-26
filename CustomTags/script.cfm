<!---------------------------------------------------------------------------------------------------------------------
	  Template: \CustomTags\script.cfm
	  Date:     2017 January
	  Author:   Chris Nguyen
	  Purpose:  a. Fix JS caching issues by appending JS file modification timestamp
	  			b. Keep track of JS files, avoid loading duplicate JS files multiple times

		Old:  <script src="/common_files/scripts/demenu.js"></script>
		New:  <cf_script src="/common_files/scripts/demenu.js"></cf_script>
---------------------------------------------------------------------------------------------------------------------->
<cfif thisTag.executionMode is "start">
	<cfset variables.files = attributes.src>

	<!--- create an array to save included files --->
	<cfif not structKeyExists(request, "included_files")>
		<cfset request.included_files = []>
	</cfif>

	<cfoutput>
	<!--- parse the list of files to include & include it --->
	<cfloop list="#variables.files#" index="variables.single_file">
		<cfset variables.single_file    = trim(variables.single_file)>
		<cfset variables.file_extension = listLast(variables.single_file, ".")>

		<!--- carray out the include action when file has not been included previoulsy --->
		<cfif arrayFindNoCase(request.included_files, variables.single_file) eq 0>
			<!--- save the included file into a request variable --->
			<cfset arrayAppend(request.included_files, variables.single_file)>

			<cfswitch expression="#variables.file_extension#">
				<!--- JavaScript  --->
				<cfcase value="js">
					<script src="#variables.single_file#?v=#application.util.dateTime.fileVersion( variables.single_file )#" <cfif variables.single_file contains "jquery.mark.">charset="UTF-8"</cfif>></script>
				</cfcase>

				<!--- CSS --->
				<cfcase value="css">
				  <link rel="stylesheet" type="text/css" href="#variables.single_file#?v=#application.util.dateTime.fileVersion( variables.single_file )#">
				</cfcase>
			</cfswitch>
		</cfif>
	</cfloop>
	</cfoutput>
</cfif>     <!--- if thisTag.executionMode is "start" --->