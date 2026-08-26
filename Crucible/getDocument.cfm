<!------ 
getDocument.cfm
This file also gets included from /scheduled/getDocument.cfm in some cases when we need to get document without logging into the application.
So when too make modifications to this file, please take that into consideration.
 ----->
 
<cfparam name="filePath" default="">
<cfparam name="FindDelimitingURLChar1" default="0">
<cfparam name="FindDelimitingURLChar2" default="0">
<cfparam name="FileName" default="">

<cfset FindDelimitingURLChar1 = Find("/", Reverse(filePath))>
<cfset FindDelimitingURLChar2 = Find("\", Reverse(filePath))>

<cfif FindDelimitingURLChar1 neq 0>

	<cfset FileName = Right(filePath,FindDelimitingURLChar1-1)>

<cfelseif FindDelimitingURLChar2 neq 0>

	<cfset FileName = Right(filePath,FindDelimitingURLChar2-1)>

</cfif> 


<cfif FileExists("#APPLICATIONPATH#\#filePath#")>

		<cfheader name="Content-Disposition" value="inline; filename=#FileName#">
		<cfcontent type="application/unknown"  file="#APPLICATIONPATH#\#filePath#"> 

</cfif>


 
	

