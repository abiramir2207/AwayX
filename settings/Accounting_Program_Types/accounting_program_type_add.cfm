<FIELDSET STYLE="padding:10px; width: 600px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Program Labels</LEGEND>
	<table>
		<TR>
			<TD ALIGN="right"><B>Name:</B></TD>
			<TD><INPUT NAME="compName" TYPE="text" SIZE="25" MAXLENGTH="50"></TD>
		</TR>		
		<TR>
			<TD ALIGN="right"><B>Reference:</B></TD>
			<TD><INPUT NAME="compDesc" TYPE="text" SIZE="25" MAXLENGTH="50"></TD>
		</TR>	
		<TR>
			<TD ALIGN="right"><B>Use for TPA:</B></TD>
			<TD>
				<input type="radio" name="compFlag" value="0" checked>No
				<br>
				<input type="radio" name="compFlag" value="1">Yes
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>Allow Billbacks:</B></TD>
			<TD>
				<input type="radio" name="compBillback" value="0">No
				<br>
				<input type="radio" name="compBillback" value="1" checked>Yes
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