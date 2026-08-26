<!--- 

AUTHOR:		Robert A. Weimer <robert@info-access.com>
CREATED:	May 05, 1998
REVISED:	

Please note this tag is unsupported.  It is not guaranteed to work - EVER!
Use at your own risk, I am NOT responsible for any damage to your equipment
or mental health.  If you absolutely feel the need to email me for help,
please make sure you have tried EVERYTHING possible before contacting me and
don't be offended if I don't answer your email -- I'm just as busy as you.

DESCRIPTION:
CF_TemplateName is a Cold Fusion custom tag that returns the actual
template's file name of the current web page.  The template's file name is
returned in a variable named 'TemplateName'.

USE:
Place the custom tag within a CF Template -
<CF_TemplateName>

The template's file name will be usable as -
<cfoutput>For Example: #TemplateName#</cfoutput>

Output -
For example: main.cfm

REQUIRED ATTRIBUTES:
None

NON-REQUIRED ATTRIBUTES:					
None
					
--->

<!--- Get the full path and file name for the template --->
<!--- Reverse CF_TEMPLATE_PATH to work with Template's Name more --->
<cfset FindTemplateName = Reverse(CF_TEMPLATE_PATH)>

<!--- Use the Mid() function to to extract FILENAME.EXT --->
<!--- Use FindOneOf() function to locate the backslash (\) --->
<!--- Subtract one to remove the backslash --->
<!--- Reverse the file name again at the end --->
<cfset GotTemplateName =
	Reverse(
			Mid(
				FindTemplateName,
				1,
				FindOneOf(
					      Chr(92),
					      FindTemplateName,
					      1
						  ) - 1
				)
	        )
>

<!--- Return Template's Name as request.TemplateName --->
<cfset Caller.TemplateName = GotTemplateName>
