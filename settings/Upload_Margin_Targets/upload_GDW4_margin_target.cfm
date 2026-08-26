<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
<br><br>
<cfparam name="defaulttarget" default="">

<cfset qgetdefaultGDW4settings = uploadmargintargetManager.getdefaultGDW4settings()>

<cfset defaulttarget = qgetdefaultGDW4settings.default_GDW4_margin_target>
<cfparam name="form.sheet_name" default="sheet1">

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
	<TR>
		<TD><B><FONT SIZE="2" COLOR="Navy">UPLOAD <cfoutput>#UCASE(application.returned_customer_setting.type_code_label_singular)#</cfoutput> MARGIN TARGETS FILE. </FONT></B></TD>
	</TR>
</TABLE>

<FORM ACTION="Upload_marginfile_Action.cfm" METHOD="post" NAME="MyForm" ENCTYPE="multipart/form-data">
					<TABLE CELLSPACING="2" CELLPADDING="0">
						
						<TR>
							<TD VALIGN="top" NOWRAP><SPAN ID="ERR_FILE"></SPAN>&nbsp;<B>Select Upload File </B></TD>
							<TD VALIGN="top"><INPUT SIZE="45" TYPE="file" NAME="File_Path"></TD>						
						</TR>	
						<TR>
						<TD>
						&nbsp;
						</TD>
						</TR>	
						
<TR>
							<TD VALIGN="top" NOWRAP><SPAN ID="ERR_FILE"></SPAN>&nbsp;<B>Worksheet Name </B></TD>
							<TD VALIGN="top"><INPUT type="text" name="sheet_name" value="" size="15"> (default is sheet1)</TD>						
						</TR>	
						<TR>
						<TD>
						&nbsp;
						</TD>
						</TR>	
<TR>
	<TD>
		<SPAN ID="ERR_DefaultTarget"></SPAN><B>Default target for new items:</B>
	</TD>
	<TD>
		<INPUT type="text" name="defaulttarget" value="<cfoutput>#defaulttarget#</cfoutput>" size="15" ONKEYUP="clenseText(this,'0123456789.')">
	</TD>
	<TD>
	&nbsp;
	</TD>
</TR>
<TR>
<TD>&nbsp;</TD>
</TR>
<TR>
<TD align="center">					
<CF_button
	button_name		=	""
	button_caption	=	"save"
	button_action	=	"verifyData();"
	button_type		=	"javascript_link"
	button_width	=	"100"
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold"
>		
</TD>
</TR>	
</TABLE>		
<Input type="hidden" name="filetype" value="1">	
</FORM>		

<script>
function verifyData()
{
if (document.all.File_Path.value =="")
			{
				alert("Please select a GDW4 Spread Sheet to upload.")
			}
else if (document.all.defaulttarget.value =="")
			{
			alert("You must enter a valid default margin target to complete your upload.")
			}
else
{ 
		var filePath = document.all.File_Path.value;
				var strLength = filePath.length;
				var periodPostion = filePath.lastIndexOf(".");
				var periodPostion = periodPostion + 1;
				var fileExtension = filePath.substr(periodPostion,strLength);
				var lower = fileExtension.toLowerCase()
				if (lower != "xls")
				{
					alert("Please upload GDW4 spread sheet(.xls).")
				}
				else
				{
					if (confirm("This upload will replace the existing data, Are you sure to upload this file?"))
						{
							document.MyForm.submit()
						}
					else
						{
  							return;
						}		
				}
}
}

</script>					
