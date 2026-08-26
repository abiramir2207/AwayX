<!---operator_category_create_edit.cfm--->

<cfoutput>

<script language="JavaScript"><!--

	function validateCategory(doAction, id) 
	{
		//error handle for empty values
		if (trim(document.#formName#.categoryName.value) == "")
		{
			alert("Please enter value for Category Name.");
			return false;
		}
		
		submitForm(doAction, id);
	}
//--></script>

<!---set defaults--->
<cfparam name="form.categoryName" default="" />
Enter or modify the category name.
<p>
<FIELDSET STYLE="padding:10px; width: 600px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Category</LEGEND>
	<table>
		<TR>
			<TD ALIGN="right"><B>Category Name:</B></TD>
			<TD><INPUT NAME="categoryName" TYPE="text" value="#form.categoryName#" SIZE="25" MAXLENGTH="95"></TD>
		</TR>		
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Save"
					button_action	=	"return validateCategory('saveCategory', #form.id#);"
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