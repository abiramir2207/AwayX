<!---operator_priority_create_edit.cfm--->
<cfoutput>

<script language="JavaScript"><!--

	function validatePriority(doAction, id) 
	{
		//error handle for empty values
		if (trim(document.#formName#.priorityName.value) == "")
		{
			alert("Please enter value for Priority Name.");
			return false;
		}
		
		submitForm(doAction, id);
	}
//--></script>

<!---set defaults--->
<cfparam name="form.priorityName" default="" />
Enter or modify the priority name.
<p>
<FIELDSET STYLE="padding:10px; width: 600px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Priority</LEGEND>
	<table>
		<TR>
			<TD ALIGN="right"><B>Priority Name:</B></TD>
			<TD><INPUT NAME="priorityName" TYPE="text" value="#form.priorityName#" SIZE="25" MAXLENGTH="95"></TD>
		</TR>		
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Save"
					button_action	=	"return validatePriority('savePriority', #form.id#);"
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
</cfoutput>