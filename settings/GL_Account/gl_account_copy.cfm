<cfif isDefined("stError") and stError.bNameExists>
	<script>
		alert("<cfoutput>#Application.GLAccountLabel#</cfoutput> already exists.");
	</script>
</cfif>
<cfif not isDefined("glUsedInProgram")>
	<cfset glUsedInProgram = 0 />
</cfif>

<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput>#Application.GLAccountLabel#</cfoutput>s</LEGEND>
	<cfoutput>
		<table width="90%" border="0" cellpadding="3" cellspacing="0">
			<TR>
				<TD ALIGN="right" class="Orangline">
					<B>Copy of #Application.GLAccountLabel# :</B>
				</TD>
				<TD>
					#qGetCompRebates.GL_Account_Desc# (#qGetCompRebates.GL_Account#)
				</TD>
			</TR>
			<TR>
				<TD ALIGN="right" class="Orangline">
					<B>#Application.GLAccountLabel#:</B>
				</TD>
				<TD>
					<INPUT NAME="GL_Account" TYPE="text" SIZE="25" MAXLENGTH="50" value="">
				</TD>
			</TR>		
			<TR>
				<TD ALIGN="right" class="Orangline">
					<B>Description:</B>
				</TD>
				<TD>
					<INPUT NAME="GL_Account_Desc" TYPE="text" SIZE="25" MAXLENGTH="50" value="">
				</TD>
			</TR>	
			<TR>
				<TD ALIGN="right" class="Orangline"><B>Start Date:</B></TD>
				<TD>
					<CF_EASYDATE FORMNAME="DataForm" FIELDNAME="Start_Date" FORMAT="mm/dd/yyyy" default="#now()#">
				</TD>
			</TR>
			<TR>
				<TD ALIGN="right" class="Orangline"><B>End Date:</B></TD>
				<TD>
					<CF_EASYDATE FORMNAME="DataForm" FIELDNAME="End_Date" FORMAT="mm/dd/yyyy" default="#now()#">
				</TD>
			</TR>
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
	</cfoutput>
</FIELDSET>