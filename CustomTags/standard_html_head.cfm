<!---
Id: /CustomTags/standard_html_head.cfm, v1.0.7 9/7/00 11:48:45 AM dbabbitt
Description: This outputs a standard html head container 
             including the title.
Example: 

         <CF_standard_html_head Title="Step 1 of 2">
		
         place your meta tags, etc. in here...		
		
         </CF_standard_html_head>
--->

<CFPARAM NAME="Attributes.Title" TYPE="string" DEFAULT="">
<!--- Figure out how to link to the root where all my standard files are --->
<CFSET Variables.RelativeRootPath="#REReplace(CGI.SCRIPT_NAME, '[^\/]+', '..', 'ALL')#">
<CFSET Variables.RelativeRootPath="#Mid(Variables.RelativeRootPath, 2, Len(Variables.RelativeRootPath) - 3)#">

<CFOUTPUT><CFSWITCH EXPRESSION="#ThisTag.ExecutionMode#">
	<CFCASE VALUE="start"><HEAD>
		<TITLE>#Attributes.Title#</TITLE>
		<LINK REL="STYLESHEET" TYPE="text/css" HREF="#Variables.RelativeRootPath#standard.css">
		<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript" SRC="#Variables.RelativeRootPath#standard.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript" SRC="/IR_Fusebox/scripts/fusebox.js"></SCRIPT>
</CFCASE><CFCASE VALUE="end"></HEAD></CFCASE></CFSWITCH></CFOUTPUT>

<!---
	Log: /CustomTags/standard_html_head.cfm
	
	Revision 1.1 12/7/2000 6:37:47 PM jheath
	Added reference to fusebox.js - shared fusebox
	javascripts
	
	Revision 1.0 9/7/00 11:25:13 AM dbabbitt
	This outputs a standard head container 
	including the title.
	--->

