<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>

<cfparam name="defaulttarget_fob" default=""><br>
<cfparam name="defaulttarget_del" default="">
<cfparam name="defaultFOBPrice" default="">
<cfparam name="defaultDelPrice" default="">
<cfparam name="defaultFOBCashDiscount" default="">
<cfparam name="defaultDelCashDiscount" default="">
<cfparam name="defaulttype" default="F">
<cfparam name="form.sheet_name" default="sheet1">

<cfset qgetdefaultitemsettings = uploadmargintargetManager.getdefaultitemsettings()>

<cfset defaulttarget_fob = qgetdefaultitemsettings.default_item_margin_target_fob>
<cfset defaulttarget_del = qgetdefaultitemsettings.default_item_margin_target_del>
<cfset defaultFOBPrice = qgetdefaultitemsettings.default_FOB_Price>
<cfset defaultDelPrice = qgetdefaultitemsettings.default_Del_Price>
<cfset defaultFOBCashDiscount = qgetdefaultitemsettings.default_FOB_Cash_Discount>
<cfset defaultDelCashDiscount =qgetdefaultitemsettings.default_Del_Cash_Discount>
<cfset defaulttype = qgetdefaultitemsettings.default_item_delivery_type>

<br><br>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
	<TR>
		<TD><B><FONT SIZE="2" COLOR="Navy">UPLOAD ITEM MARGIN TARGETS FILE. </FONT></B></TD>
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
		<SPAN ID="ERR_DefaultTarget_fob"></SPAN><B>Default FOB target for new items:</B>
	</TD>
	<TD>
		<INPUT type="text" name="defaulttarget_fob" value="<cfoutput>#defaulttarget_fob#</cfoutput>" size="15" ONKEYUP="clenseText(this,'0123456789.')">
	</TD>
	<TD>
	&nbsp;
	</TD>
</TR>
<TR>
	<TD>
		<SPAN ID="ERR_DefaultTarget_del"></SPAN><B>Default DEL target for new items:</B>
	</TD>
	<TD>
		<INPUT type="text" name="defaulttarget_Del" value="<cfoutput>#defaulttarget_del#</cfoutput>" size="15" ONKEYUP="clenseText(this,'0123456789.')">
	</TD>
	<TD>
	&nbsp;
	</TD>
</TR>
<TR>
	<TD>
		<SPAN ID="ERR_DefaultFOB"></SPAN><B>Default FOB Base Price:</B>
	</TD>
	<TD>
		<INPUT type="text" name="defaultFOBPrice" value="<cfoutput>#defaultFOBPrice#</cfoutput>" size="15" ONKEYUP="clenseText(this,'0123456789.')">
	</TD>
	<TD>
	&nbsp;
	</TD>
</TR>
<TR>
	<TD>
		<SPAN ID="ERR_DefaultDelivered"></SPAN><B>Default Delivered Base Price:</B>
	</TD>
	<TD>
		<INPUT type="text" name="defaultDelPrice" value="<cfoutput>#defaultDelPrice#</cfoutput>" size="15" ONKEYUP="clenseText(this,'0123456789.')">
	</TD>
	<TD>
	&nbsp;
	</TD>
</TR>
<TR>
	<TD>
		<SPAN ID="ERR_DefaultFOBCash"></SPAN><B>Default FOB Cash Discount:</B>
	</TD>
	<TD>
		<INPUT type="text" name="defaultFOBCashDiscount" value="<cfoutput>#defaultFOBCashDiscount#</cfoutput>" size="15" ONKEYUP="clenseText(this,'0123456789.')">
	</TD>
	<TD>
	&nbsp;
	</TD>
</TR>
<TR>
	<TD>
		<SPAN ID="ERR_DefaultDelCash"></SPAN><B>Default Delivered Cash Discount:</B>
	</TD>
	<TD>
		<INPUT type="text" name="defaultDelCashDiscount" value="<cfoutput>#defaultDelCashDiscount#</cfoutput>" size="15" ONKEYUP="clenseText(this,'0123456789.')">
	</TD>
	<TD>
	&nbsp;
	</TD>
</TR>
<TR>
	<TD>
		<SPAN ID="ERR_DefaultType"></SPAN><B>Default Type for new items:</B>
	</TD>
	<TD>
		<INPUT type="radio" name="defaulttype" value="F" <cfif trim(defaulttype) EQ "F" >checked</cfif>>FOB &nbsp;&nbsp;<INPUT type="radio" name="defaulttype" value="D" <cfif trim(defaulttype) EQ "D" >checked</cfif>>Delivered
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
	
<Input type="hidden" name="filetype" value="2">	
</FORM>		
<CF_MessageWindow>
<script>
function verifyData()
{
ErrorCount = 0
if (document.all.File_Path.value =="")
			{
				ErrorCount++;
				queueMessage("You must select an Item Spread Sheet to upload.", document.all.ERR_FILE);
			}
if (document.all.defaulttarget_fob.value == "")
			{
				ErrorCount++;
				queueMessage("You must enter a valid default FOB margin target to complete your upload.",document.all.ERR_DefaultTarget_fob);
			}
if (document.all.defaulttarget_Del.value == "")
			{
				ErrorCount++;
				queueMessage("You must enter a valid default DEL margin target to complete your upload.",document.all.ERR_DefaultTarget_del);
			}
if (document.all.defaultFOBPrice.value == "" && document.all.defaultDelPrice.value == "")
			{
				ErrorCount++;
				queueMessage("You must enter a valid FOB price to complete your upload.",document.all.ERR_DefaultFOB);
			}
if (document.all.defaultDelPrice.value == "")
			{
				ErrorCount++;
				queueMessage("You must enter a valid Delivered price to complete your upload.",document.all.ERR_DefaultDelivered);
			}
if (document.all.defaultFOBCashDiscount.value == "")
			{
				ErrorCount++;
				queueMessage("You must enter a valid FOB Cash Discount to complete your upload.",document.all.ERR_DefaultFOBCash);
			}
if (document.all.defaultDelCashDiscount.value == "")
			{
				ErrorCount++;
				queueMessage("You must enter a valid Delivered Cash Discount to complete your upload.",document.all.ERR_DefaultDelCash);
			}
if (document.all.File_Path.value !="")
{ 
		var filePath = document.all.File_Path.value;
				var strLength = filePath.length;
				var periodPostion = filePath.lastIndexOf(".");
				var periodPostion = periodPostion + 1;
				var fileExtension = filePath.substr(periodPostion,strLength);
				var lower = fileExtension.toLowerCase()
				if (lower != "xls")
				{
				ErrorCount++;
				queueMessage("You must upload an item spread sheet(.xls).",document.all.ERR_FILE);
				}			
}
if(ErrorCount == 0) {
		if(confirm("Please convert the entire worksheet to TEXT prior to uploading and confirm that the worksheet name coincides with the name in the worksheet textbox.  These steps will insure that all of the data is handled correctly."))
		{
				if(confirm("This upload will replace the existing data, Are you sure to upload this file?")){
					MyForm.submit()
				}
		}
			}
			else {
				showMessageWindow()
			}	
}

</script>					
