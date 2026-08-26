<!--- 

USE:
Place the custom tag within a CF Template -

<CF_TemplateName>
The template's file name will be usable as -
<cfoutput>For Example: #TemplateName#</cfoutput>

REQUIRED ATTRIBUTES:
None

NON-REQUIRED ATTRIBUTES:					
None
					
--->

<!--- Get the full path and file name for the template --->
<!--- Reverse CF_TEMPLATE_PATH to work with Template's Name more --->
<cfset FindTemplateName = Reverse(CF_TEMPLATE_PATH)>
<cfset GotTemplateName = "">
<!--- Use the Mid() function to to extract FILENAME.EXT --->
<!--- Use FindOneOf() function to locate the backslash (\) --->
<!--- Subtract one to remove the backslash --->
<!--- Reverse the file name again at the end --->
<cfif Len(FindTemplateName) GT 0>
	<cfset GotTemplateName = Reverse(Mid(FindTemplateName, 1, FindOneOf(Chr(92),FindTemplateName,1)- 1))>
</cfif>
<!--- Return Template's Name as request.TemplateName --->
<cfset Caller.TemplateName = GotTemplateName>
