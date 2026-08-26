<!--- Make sure that the ranking is set --->
<cfinclude template="initial_check.cfm">

<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;cursor;none;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Upload File Product Alias Management</LEGEND>
<table border="0" align="center">
<TR>
	<TD ALIGN="right" NOWRAP>&nbsp;<B>SELECT UPLOAD FILE</B></TD>
	<TD><INPUT SIZE="45" TYPE="file" NAME="File_Path"></TD>
	<TD>
	<!--- Do not change the button_name. It needs to be "save" for disabling purpose. --->
	<CF_button
		button_name	=	"save"
		button_caption	=	"Upload"
		button_action	=	"UploadAliasCompletion('Upload_File', 'save_table');"
		button_type	=	"javascript_link"
		button_width	=	"175"
		button_color	=	"Navy"
		button_tip	=	""
		font_color	=	"White"
		font_size	=	"12"
		font_weight	=	"bold"
	>
	</TD>
</TR>
<TR>
 <TD colspan="100%" align="center" ID="Updating" style="display:none;color:red">
  <b>UPDATING...</b>
 </TD>
</TR>
</table>
</FIELDSET>
