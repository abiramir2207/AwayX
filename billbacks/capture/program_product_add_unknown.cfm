<CFSET PAGE_TITLE="add unknown product">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT>
		function CheckForErrors(){
			ErrorCount = 0;

			error_text 		= "Please supply an item number";
			error_oSpan 	= document.all.error_inum;
			
			if(document.all.Unknown_Item_number.value.length == 0) {
				ErrorCount++;
				queueMessage(error_text, error_oSpan);
			}
			else
			{
				clearQueue(error_oSpan);
			}	

			error_text 		= "Please supply a product description";
			error_oSpan 	= document.all.error_desc;
			if(document.all.Unknown_Description.value.length == 0) {
				ErrorCount++;
				queueMessage(error_text, error_oSpan);
			}
			else
			{
				clearQueue(error_oSpan);
			}

			error_text 		= "Please add notes concerning the product";
			error_oSpan 	= document.all.error_notes;
			if(document.all.Unknown_Notes.value.length == 0) {
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
			window.opener.KnownProgramForm.Unknown_Item_Number.value 	= Unknown_Item_number.value;
			window.opener.KnownProgramForm.Unknown_Description.value 	= Unknown_Description.value;
			window.opener.KnownProgramForm.Unknown_Notes.value 			= Unknown_Notes.value;
			window.opener.KnownProgramForm.submit();
			this.close();
		}
	</SCRIPT>
	
	<CF_MessageWindow>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="10">

<STYLE>
	.DataTitleCell {
		text-align : right;
		font-weight : bold;
		vertical-align : top;
	}
</STYLE>
<div align="center" style="font-weight: bold; font-size: 15px">
<font color="navy"><strong>
	Unknown Product Information
	</strong></font>
</div>
<BR>
<table align="center">
	<TR>
		<TD class="DataTitleCell"><cfoutput>#application.returned_customer_setting.item_label#</cfoutput> Number:&nbsp;<span id="error_inum"></SPAN></TD>
		<TD rowspan="99%"></TD>
		<TD><input type="text" name="Unknown_Item_number" id="Unknown_Item_number" size="64" maxlength="64"></TD>				
	</TR>
	<TR>
		<TD class="DataTitleCell">Description:&nbsp;<span id="error_desc"></SPAN></TD>
		<TD><input type="text" name="Unknown_Description" id="Unknown_Description" size="64" maxlength="64"></TD>				
	</TR>
	<TR>
		<TD class="DataTitleCell">Notes:&nbsp;<span id="error_notes"></SPAN></TD>
		<TD>
			<textarea cols="66" rows="8" name="Unknown_Notes"></textarea>
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
