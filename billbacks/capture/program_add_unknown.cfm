<CFSET PAGE_TITLE="create unknown program">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<cfif isdefined("url.FormName")>
	<cfset Formname = url.FormName>
<cfelse>
	<cfset Formname = KnownProgramForm>
</cfif>

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT>
		function CheckForErrors(){
			ErrorCount = 0;

			error_text 		= "Please supply a program number";
			error_oSpan 	= document.all.error_pnum;
			
			if(document.all.Unknown_Program_Number.value.length == 0) {
				ErrorCount++;
				queueMessage(error_text, error_oSpan);
			}
			else
			{
				clearQueue(error_oSpan);
			}	

			error_text 		= "Please supply a program title";
			error_oSpan 	= document.all.error_title;
			if(document.all.Unknown_Program_Title.value.length == 0) {
				ErrorCount++;
				queueMessage(error_text, error_oSpan);
			}
			else
			{
				clearQueue(error_oSpan);
			}

			error_text 		= "Please add notes concerning the program";
			error_oSpan 	= document.all.error_notes;
			if(document.all.Unknown_Program_Notes.value.length == 0) {
				ErrorCount++;
				queueMessage(error_text, error_oSpan);
			}
			else
			{
				clearQueue(error_oSpan);
			}							
			<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
			if(ErrorCount == 0) {
				if(confirm("Press OK if all information is correct")){
					transerDataToParent();
				}
			}
			else {
				showMessageWindow()
			}		
		}
		
		
		function transerDataToParent() {
			window.opener.<cfoutput>#Formname#</cfoutput>.Unknown_Program_Number.value 	= Unknown_Program_Number.value;
			window.opener.<cfoutput>#Formname#</cfoutput>.Unknown_Program_Title.value 		= Unknown_Program_Title.value;
			window.opener.<cfoutput>#Formname#</cfoutput>.Unknown_Program_Notes.value 		= Unknown_Program_Notes.value;
			window.opener.<cfoutput>#Formname#</cfoutput>.submit();
			this.close();
		}
	</SCRIPT>
	
	<CF_MessageWindow>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="10">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js">

<STYLE>
	.DataTitleCell {
		text-align : right;
		font-weight : bold;
		vertical-align : top;
	}
</STYLE>
<div align="center" style="font-weight: bold; font-size: 15px">
<font color="navy"><strong>
	Unknown Program Information
	</strong></font>
</div>
<BR>
<table align="center">
	<TR>
		<TD class="DataTitleCell">Program Number:&nbsp;<span id="error_pnum"></SPAN></TD>
		<TD rowspan="99%"></TD>
		<TD><input type="text" name="Unknown_Program_Number" id="Unknown_Program_Number" size="64" maxlength="50"></TD>				
	</TR>
	<TR>
		<TD class="DataTitleCell">Program Title:&nbsp;<span id="error_title"></SPAN></TD>
		<TD><input type="text" name="Unknown_Program_Title" id="Unknown_Program_Title" size="64" maxlength="50"></TD>				
	</TR>
	<TR>
		<TD class="DataTitleCell">Notes:&nbsp;<span id="error_notes"></SPAN></TD>
		<TD>
			<textarea cols="66" rows="8" name="Unknown_Program_Notes" onPaste="javaScript: return textareaChecklength('4000', this);"  onkeyPress="javaScript: return textareaChecklength('4000', this);"></textarea>
		</TD>				
	</TR>
	<TR>
		<TD colspan="100%" align="center">
			<BR>
			<CF_button
				button_name		=	""
				button_caption	=	"save"
				button_action	=	"CheckForErrors();"
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
</table>

</BODY>
</HTML>
