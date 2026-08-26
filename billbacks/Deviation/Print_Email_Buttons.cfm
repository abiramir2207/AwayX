<!-----------------------------------------------------------------------
Print Email Fax Button
------------------------------------------------------------------------>
<CFPARAM NAME="MAX_LEVEL" 	DEFAULT=0>
<CFPARAM NAME="THIS_STEP_LEVEL_IN_LIST" 	DEFAULT="">

<CFOUTPUT>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="1%" ALIGN="CENTER">
		<TR>
<cfif isDefined("showCountNoCount")>
	<cfset extraQryString = "&showCountNoCount=" & showCountNoCount >
<cfelse>
	<cfset extraQryString = "" >
</cfif>
<CFIF Print_Button_Show EQ 1>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"print"
			button_action	=	"NewWindow('../common/bb_printer_friendly.cfm?BBID=#Billback_ID#&Referrer=Deviation#extraQryString#','name','1000','600','No', 'No')"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Prepare an email contents"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
</CFIF>

<CFIF Email_Button_Show EQ 1>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"email"
			button_action	=	"window.location.href='../common/bb_email_create.cfm?BBID=#Billback_ID#&Referrer=Deviation#extraQryString#'"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Prepare email contents"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
</CFIF>
<!--- DEV NOTE: DAA; D15409    REMOVE FAX LINK
<CFIF Fax_Button_Show EQ 1>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"fax"
			button_action	=	"window.location.href='../common/bb_fax_create.cfm?BBID=#Billback_ID#&Referrer=Deviation#extraQryString#'"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Prepare the contents of a fax to be sent"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
</CFIF>
--->
</TABLE>
</CFOUTPUT>
