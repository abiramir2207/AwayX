<FIELDSET STYLE="padding:10px; width: 600px; border: 1px solid Blue;margin-top:10px;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">CURRENCY</LEGEND>
	<table>
		<TR>
			<TD ALIGN="right"><B>Currency Type Name:</B></TD>
			<TD><INPUT NAME="currencyName" TYPE="text" SIZE="25" MAXLENGTH="25"></TD>
		</TR>	
		<TR>
			<TD ALIGN="right"><B>Currency Code:</B></TD>
			<TD><INPUT NAME="currencyCode" TYPE="text" SIZE="3" MAXLENGTH="3"></TD>
		</TR>
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Add"
					button_action	=	"return addCurrency();"
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