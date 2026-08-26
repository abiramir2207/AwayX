<cfif isDefined("stError") and stError.bNameExists>
	<script>
		alert("Component name already exists.");
	</script>
</cfif>

<FIELDSET STYLE="padding:10px; width: 600px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Component Information</LEGEND>
	<table>
		<!------ external id ----->
		<cfif application.returned_customer_setting.external_id_on EQ 1>
		<TR>
			<TD ALIGN="right"><B>ID:</B></TD>
			<TD><INPUT NAME="compExternalID" TYPE="text" VALUE="<cfoutput>#qGetCompRebates.External_ID#</cfoutput>" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<cfelse><INPUT NAME="compExternalID" TYPE="hidden" VALUE="<cfoutput>#qGetCompRebates.External_ID#</cfoutput>">
		</cfif>
		<TR>
			<TD ALIGN="right"><B>Component Name:</B></TD>
			<TD><INPUT NAME="compName" TYPE="text" VALUE="<cfoutput>#qGetCompRebates.Program_Rebates_Component_Name#</cfoutput>" SIZE="30" MAXLENGTH="25"></TD>
		</TR>
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Update"
					button_action	=	"return upadateComp(#qGetCompRebates.Program_Rebates_Component_Name_ID#);"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</TD>
		</TR>
	</table>
	</FIELDSET>