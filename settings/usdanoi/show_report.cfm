<cfinclude template="#url.file#">

<cfset url.file=replace(url.file, "\", "/", "ALL")>
<cfset url.filePrinter=ListToArray(url.file, "/")>

<cfset tempFileName = ListToArray(url.filePrinter[arraylen(url.filePrinter)], ".")>

<cfset tempURL = "">
<cfset aLen = arraylen(filePrinter)>
<cfloop index="x" from="1" to="#aLen#">
	
	<cfif x EQ aLen>
		<cfset filePrinter[x] = tempFileName[1] & "_printer_friendly.tmp">
	</cfif>
	<cfset tempURL = tempURL & "/" & #filePrinter[x]#>
</cfloop>
<cfset url.filePrinter = tempURL>

<table align="center">
	<tr>
		<TD align="center">
			<CF_button
				button_name		=	""
				button_caption	=	"print"
				button_action	=	"NewWindow('printer_friendly.cfm?file=#url.filePrinter#','name','800','600','Yes', 'No')"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	"Prepare an email contents"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>				
		</TD>	
		<TD align="center">
			<CF_button
				button_name		=	""
				button_caption	=	"email"
				button_action	=	"window.location.href='create_email.cfm?file=#url.filePrinter#'"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	"Prepare an email contents"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>				
		</TD>
	<!--- DEV NOTE: DAA; D15409    REMOVE FAX LINK
		<TD align="center">
			<CF_button
				button_name		=	""
				button_caption	=	"fax"
				button_action	=	"window.location.href='contract_fax_create.cfm?file=#url.filePrinter#'"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	"Prepare the contents of a fax to be sent"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>				
		</TD>
	 --->		
	</tr>
</table>

