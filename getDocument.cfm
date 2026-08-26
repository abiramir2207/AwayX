<!------ 
getDocument.cfm
This file also gets included from /scheduled/getDocument.cfm in some cases when we need to get document without logging into the application.
So when too make modifications to this file, please take that into consideration.
 ----->

<cfparam name="filePath" default="">
<cfparam name="FindDelimitingURLChar1" default="0">
<cfparam name="FindDelimitingURLChar2" default="0">
<cfparam name="FileName" default="">
<!--- scripting and directory traversal defense --->
<cfset filePath = HTMLEditFormat(filePath) />
<cfset filePath = URLDecode(filePath) />
<!--- <cfset filePath = replace(filePath,'..','','all' ) /> --->
<cfset filePath = ReReplace(filePath, "&amp;", "&", "ALL") />
<cfset filePath = Replace(filePath,"charE1a","á","ALL") />
<cfset filePath = Replace(filePath,"charE9e","é","ALL") />
<cfset filePath = Replace(filePath,"charEDi","í","ALL") />
<cfset filePath = Replace(filePath,"charF3o","ó","ALL") />
<cfset filePath = Replace(filePath,"charFAu","ú","ALL") />
<!--- <cfset filePath = Replace(filePath,",","%2C","ALL") /> --->

<cfset FindDelimitingURLChar1 = Find("/", Reverse(filePath))>
<cfset FindDelimitingURLChar2 = Find("\", Reverse(filePath))>

<cfif FindDelimitingURLChar1 neq 0>

	<cfset FileName = Right(filePath,FindDelimitingURLChar1-1)>

<cfelseif FindDelimitingURLChar2 neq 0>

	<cfset FileName = Right(filePath,FindDelimitingURLChar2-1)>
	
<cfelseif FileName EQ '' >
	
	<cfset FileName = filePath />
	
</cfif> 
<!--- HTML files --->
<cfif Right(FileName, 5) eq ".html" OR Right(FileName, 4) eq ".htm">
	<cfset Content_Type = "text/html">
<!--- PDF files --->
<cfelseif Right(FileName,4) eq ".pdf">
 	<cfset Content_Type = "application/pdf">
<!--- MSEXCEL files --->
<cfelseif ((Right(FileName,4) eq ".xls") OR (Right(FileName,5) eq ".xlsx"))>
 	<cfset Content_Type = "application/vnd.ms-excel">
<!--- MSWORD files --->
<cfelseif Right(FileName,4) eq ".doc" OR Right(FileName,4) eq ".dot">
	<cfset Content_Type = "application/msword">
<!--- POWERPOINT files --->
<cfelseif Right(FileName,4) eq ".ppt">
	<cfset Content_Type = "application/vnd.ms-powerpoint">
<!--- CSV files --->
<cfelseif Right(FileName,4) eq ".csv">
	<cfset Content_Type = "application/csv">
<!--- TXT files --->	
<cfelseif Right(FileName,4) eq ".txt">
	<cfset Content_Type = "text/plain">
<cfelse>
	<cfset Content_Type = "Application/Unknown">
</cfif>

<cfif FileExists("#Application.Doc_Path#\#filePath#") >
<!--- For opening non-CF files --->

	<cfif Right(FileName, 4) neq ".cfm" AND Right(FileName, 10) neq "margin.htm">
		<cfif Left(Application.Doc_Path, 2) eq "\\">
			<!--- If common_documents is in a different location(eg: \\someserver\somewhere), we cannot do cflocation --->
			<cfheader name="Content-Disposition" value="inline; filename=#FileName#">
			<cfcontent type="#Content_Type#"  file="#Application.Doc_Path#\#filePath#">
		<cfelseif FileName neq "">
			<cfheader name="Content-Disposition" value="attachment; filename=""#FileName#""">
			<cfcontent type="#Content_Type#"  file="#Application.Doc_Path#\#filePath#">
		<cfelse>
			<cflocation url="#Application.Doc_Mapping#/#filePath#" />
		</cfif>
		
	<cfelse>
	<!--- For including mainly CF files (html files are included too) --->
		<cfinclude template ="#Application.Doc_Mapping#/#filePath#">
	</cfif>

<cfelse>

<!--- To open files which already exist as part of build. These files are not written to a location through the application. --->
<cfinvoke component="components.general.General_Functions" method="Get_Application_Path" returnVariable="AppPath">
	<cfif FileExists("#AppPath#\#filePath#") AND Right(FileName, 4) neq ".cfm" >
		<cfheader name="Content-Disposition" value="inline; filename=#FileName#">
		<cfcontent type="#Content_Type#"  file="#AppPath#\#filePath#">
	<cfelseif FileExists("#URL.filePath#")	AND Right(FileName, 4) neq ".cfm" >
		<cfheader name="Content-Disposition" value="attachment; filename=#FileName#">
		<cfcontent type="#Content_Type#"  file="#URL.filePath#">
	<cfelse>
		<p align="center">
		<span style="FONT-SIZE: 12pt; FONT-FAMILY: 'Century Gothic'; font-weight:bold">
			File not found.<!--- [<cfoutput>#filePath#</cfoutput>]--->
		</span>
		</p>
	</cfif>
</cfif>


 
	

