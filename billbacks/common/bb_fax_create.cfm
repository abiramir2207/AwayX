<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Fax Billback</TITLE>
	<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
		<script>

var ErrorCount = 0;
function confirmCompletion()
{

	var ErrorCount = 0;

		if(document.all.SenderAddress.value.length == 0)	
		{ 
			ErrorCount++;
			queueMessage("You must enter your email address", document.all.error_SenderAddress);
		}
		else
		{			
			clearQueue(document.all.error_SenderAddress);
		}		
			
		
		 if(document.all.SenderSubject.value.length == 0)
		{			
			ErrorCount++;
			queueMessage("You must enter a subject", document.all.error_SenderSubject);
		}
		else
		{			
			clearQueue(document.all.error_SenderSubject);
		}	
		if(document.all.Form_Fax_Numbers.value.length == 0)
		{
			ErrorCount++;
			queueMessage("You must enter at least one fax number", document.all.error_Fax_Numbers);
		}
		else
		{
			clearQueue(document.all.error_Form_Fax_Numbers);
		}
		
<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0) 
	{
		Fax.submit()
		
	}
	else 
	{
		showMessageWindow()
	}	
}
</script>
<CF_MessageWindow>	
	
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<STYLE>
	textarea
		{
			font-size:	12px;
			width:		500px;
		}
</STYLE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is the email create page  																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFPARAM NAME="URL.BBID"								DEFAULT="">
<CFSET Billback_ID=URL.BBID>
<CFSET Display_None_Attachments = 1>
<CFINCLUDE TEMPLATE="Billback_Summary_Save.cfm">

<CFPARAM NAME="Billback_Billback_Title" 	DEFAULT="Trade Balance">

<BR>
<BLOCKQUOTE>
<FORM ACTION="bb_fax_send.cfm" METHOD="post" NAME="Fax" ID="MyForm">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Message Details:</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150"><B>Date:&nbsp;&nbsp;</B></TD>
	<TD><INPUT TYPE="text" NAME="SenderDate" SIZE="30" VALUE="#dateformat(now(), 'mmmmm d, yyyy')#" STYLE="width: 250px;" READONLY></TD>
	<!--- <TD ROWSPAN="100%"><IMG SRC="/images/email.gif"></TD> --->
</TR>
<TR>
	<TD ALIGN="right"><B>From:&nbsp;&nbsp;</B><span id="error_SenderAddress"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderAddress" SIZE="30" VALUE="#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last# (#request.AccessStructure.User_Email#)" STYLE="width: 250px;" READONLY></TD>
</TR>
<TR>
	<TD ALIGN="right"><B>Subject:&nbsp;&nbsp;</B><span id="error_SenderSubject"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderSubject" SIZE="30" VALUE="Billback #Billback_Payable_Number# - #Billback_Billback_Title#" STYLE="width: 500px;"></TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="TOP"><B>Message Body:&nbsp;&nbsp;</B></TD>
	<TD><TEXTAREA NAME="Message_Body" COLS="75" ROWS="5"></TEXTAREA></TD>
</TR>
</TABLE>
</CFOUTPUT>

<BR><BR>

<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />

<CFINCLUDE TEMPLATE="/Common_Files/Documents/User_Positions_Under_this_User.cfm">
<CFSET Access_Position_List = GP_Position_List_From_My_Position_Down>

<CFQUERY NAME="mail_Documents" DATASOURCE = "#Application.Datasource#">
	SELECT 		contract_Attachments.doc_id,
				Doc_Uni_Name,
				doc_title,
				Doc_Description,
				Uploaded_Date,
				Uploaded_By,
				Doc_Type,
				Doc_File_Name,
				Doc_Size 

	FROM 		contract_Attachments
	LEFT JOIN 	Document_Details 
	ON 			contract_Attachments.Doc_ID = Document_Details.Doc_ID 
	WHERE 		contract_Attachments.Billback_ID = '#URL.BBID#' 
	AND			contract_Attachments.deleted=0
				AND (	(	Public_View = 1
							AND User_Position_ID IN (#preserveSingleQuotes(Access_Position_List)#)
						) 						
							OR Public_View = 0	
					)
</CFQUERY>
<CFIF mail_Documents.recordcount GT 0>
<BR><BR>
<SPAN CLASS="title2">Attachments</SPAN>
<HR COLOR="Orange">
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="75%">	
	<TR >
		<TD WIDTH="100">&nbsp;</TD>
		<TD BGCOLOR="#ffce84">&nbsp;</TD>
		<TD WIDTH="125" ID="headed" STYLE="font-size: 11px; font-weight: bold;" BGCOLOR="#ffce84">Date / Name</TD>
		<TD ID="header" STYLE="font-size: 11px; font-weight: bold;" BGCOLOR="#ffce84">File</TD>
		<TD STYLE="font-size: 11px; font-weight: bold;" BGCOLOR="#ffce84">Title / Description</TD>
		<TD STYLE="font-size: 11px; font-weight: bold;" BGCOLOR="#ffce84">Type</TD>
	</TR>
		<CFOUTPUT QUERY="Mail_Documents"> 
		<CFQUERY NAME="get_userName" DATASOURCE="#Application.Datasource#">
			SELECT 		Name_First,
						Name_Last
			FROM		_users
			WHERE 		User_ID = '#Uploaded_By#'
		</CFQUERY>
	<TR>		
		<TD WIDTH="100">&nbsp;</TD>		
		 <TD ALIGN="right"  VALIGN="TOP" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#"><INPUT TYPE="Checkbox" NAME="Doc_ID" VALUE="#Doc_ID#">&nbsp;&nbsp;</TD> 
		 <TD WIDTH="125" VALIGN="TOP" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">#dateFormat(Uploaded_Date,"mm/dd/yyyy")#<BR>#get_userName.Name_First# #get_userName.Name_Last#</TD>
		<CFSET SIZEinKB = #Doc_Size#/1024>
		<TD VALIGN="TOP" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#"><A href="javascript: confirmation('#Doc_Uni_Name#');" TITLE="Click here to view '#Doc_File_Name#'">
		<CFSET Display_Name=Left(Doc_File_Name,10)>
			<CFIF len(trim(Doc_File_Name)) GT 10>
				#LCASE(Display_Name)#...
			<CFELSEIF len(trim(Doc_File_Name)) EQ 0>
				&nbsp;
			<CFELSE>
				#LCASE(Display_Name)#	
			</CFIF>		</A>&nbsp;&nbsp;<br>#numberFormat(SIZEinKB,"_.___")# KB</TD>
		<TD VALIGN="TOP" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#"><FONT COLOR="red">#Doc_Title#</FONT>&nbsp;&nbsp;<br>Description: #Doc_Description#</TD>
		<TD NOWRAP VALIGN="TOP" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">#Doc_Type#</TD>
	</TR>
	</CFOUTPUT>		
	</TABLE>	
<BR><BR>

</CFIF>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Recipients' Fax Numbers</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150" VALIGN="TOP"><B>Recipients:&nbsp;&nbsp;</B><span id="error_Fax_Numbers"></span></TD>
	<TD>
		<TEXTAREA NAME="Form_Fax_Numbers" COLS="75" ROWS="5" onKeyUp="clenseText(this, '0123456789;')"><CFOUTPUT>#Billback_Fax_Numbers#</CFOUTPUT></TEXTAREA><BR>
		<FONT COLOR="Red"><B><I>
YOU MUST PRECEED THE AREA CODE WITH A "1"<BR>
To add more recipients, add the fax numbers separating them with a semi- colon ( ;)<BR>
			Please make sure that there are no spaces, dashes in the FAX number.
		</I></B></FONT>
	</TD>
</TR>
</TABLE>


<INPUT NAME="HTML_File_Path" TYPE="hidden" VALUE="<CFOUTPUT>#Billback_HTML_File_Path#</CFOUTPUT>">
<INPUT NAME="Billback_ID" TYPE="hidden" VALUE="<CFOUTPUT>#Billback_ID#</CFOUTPUT>">
<INPUT NAME="Payable_No" TYPE="hidden" VALUE="<CFOUTPUT>#Billback_Payable_Number#</CFOUTPUT>">


<BR CLEAR="ALL">
<BR>



<TABLE ALIGN="center">
	<TR>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"send fax"
				button_action	=	"confirmCompletion();"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"Click here to send..."
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold">
		</TD>
	</TR>
</TABLE>
 
</FORM>


<BR><BR>






<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Billback Details</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFINCLUDE TEMPLATE="#Application.Doc_Mapping##Billback_HTML_File_Path#">
	<script>
	// Calls function to make iFrame same height as Browser Window
	// Needs to load the included template first before it can determine the size
	try { window.parent.dyniframesize(); } catch (err) { };
	</script>
</BLOCKQUOTE>
</BODY>
</HTML>

 