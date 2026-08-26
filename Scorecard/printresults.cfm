<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><cfoutput>#application.returned_customer_setting.Company_Name#</cfoutput> - Program Search</title>
</head>

<body>
<br>
<cfparam name="url.page" default="">

<!--- <CF_button
						button_name		=	""
						button_caption	=	"Print"
						button_action	=	"window.print()"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Prepare an email contents"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>			 --->
<br>
<cfset printresults =1> 
<cfset URL.SearchIsConductedFromOtherWindow = 1>



<!--- 
<CFINCLUDE TEMPLATE="program_header.cfm">
--->

<cfif url.page IS "programsearch">
 <CFINCLUDE TEMPLATE="program_search_result.cfm"><br><br>
 <CFINCLUDE template="/Common_Files/Printer_Friendly_Script.cfm"> 
</cfif>


</body>
</html>
