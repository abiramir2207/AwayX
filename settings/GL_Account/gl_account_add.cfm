
<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput>#Application.GLAccountLabel#</cfoutput>s</LEGEND><!---D42774 --->
	<table width="90%" border="0" cellpadding="3" cellspacing="0">
		<TR>
			<TD ALIGN="right" class="Orangline"><B><cfoutput>#Application.GLAccountLabel#</cfoutput>:</B></TD><!---D42774 --->
			<TD><INPUT NAME="GL_Account" TYPE="text" SIZE="25" MAXLENGTH="50"></TD>
		</TR>		
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Description:</B></TD>
			<TD><INPUT NAME="GL_Account_Desc" TYPE="text" SIZE="25" MAXLENGTH="50"></TD>
		</TR>	
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Start Date:</B></TD>
			<TD>
				<CF_EASYDATE FORMNAME="DataForm" FIELDNAME="Start_Date" FORMAT="mm/dd/yyyy" DEFAULT="#now()#">
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>End Date:</B></TD>
			<TD>
				<CF_EASYDATE FORMNAME="DataForm" FIELDNAME="End_Date" FORMAT="mm/dd/yyyy" DEFAULT="#now()#">
			</TD>
		</TR>

		<!--- Dev Note: Kal; Component selection on GL Page --->					
		<!--- component selection  --->
		<TR>
			<TD COLSPAN="100%">
				<cfinclude template="/settings/GL_Account/select_components.cfm" /><br/>
			</TD>
		</TR>		
			
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