<cfif isDefined("stError") and stError.bNameExists EQ 2>
	<script>
		alert("Component name already exists with a different ID.");
	</script>
</cfif>

<cfparam name="form.compExternalID" 	default="">
<cfparam name="form.compName" 	default="">
<cfparam name="form.compType" 	default="1">

<FIELDSET STYLE="padding:10px; width: 600px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Component Information</LEGEND>
	<table>
		<cfoutput>
		<TR>
			<TD ALIGN="right"><B>Component Name:</B></TD>
			<TD><INPUT NAME="compName" TYPE="text" SIZE="30" MAXLENGTH="25" value="#form.compName#"></TD>
		</TR>	
		<TR>
			<TD ALIGN="right"><B>Component Type:</B></TD>
			<TD><INPUT NAME="compType" TYPE="radio" value="1" <cfif #form.compType# EQ 1>checked</cfif>>Delivered &nbsp;&nbsp;<INPUT NAME="compType" TYPE="radio" value="2" <cfif #form.compType# EQ 2>checked</cfif>>FOB</TD>
		</TR>	
		</cfoutput>	
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Add"
					button_action	=	"return addComp();"
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