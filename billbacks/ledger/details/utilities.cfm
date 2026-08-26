<cfset LinkProgramNumber = replace(ProgramNumber, "'", "\'", "all")>

<div align="centeR">
<table border="0" width="600">
<tr><td>&nbsp; </td>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"print"
			button_action	=	"NewWindow('/billbacks/ledger/utilities/printer_friendly.cfm?PageName=#PageName#&DistributorNumber=#DistributorNumber#&ProgramNumber=#LinkProgramNumber#&ContractID=#ContractID#&ShowDetails=1','name','800','600','Yes', 'Yes')"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Print this information"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>

	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"email"
			button_action	=	"window.location.href='/billbacks/ledger/utilities/email_create.cfm?PageName=#PageName#&DistributorNumber=#DistributorNumber#&ProgramNumber=#LinkProgramNumber#&ContractID=#ContractID#&ShowDetails=1'"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Email this information"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
 <!--- DEV NOTE: DAA; D15409    REMOVE FAX LINK
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"fax"
			button_action	=	"window.location.href='/billbacks/ledger/utilities/fax_create.cfm?PageName=#PageName#&DistributorNumber=#DistributorNumber#&ProgramNumber=#LinkProgramNumber#&ContractID=#ContractID#&ShowDetails=1'"
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
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"close"
			button_action	=	"window.close()"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Close this window"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
</td><td>&nbsp; </td></tr> 

</table>
</div>