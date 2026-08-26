<CFSET PAGE_TITLE="Contact us...">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/header.cfm">




<BR>

<FORM ACTION="contact_us_send_mail.cfm" METHOD="post">
<CENTER>
<FIELDSET STYLE="padding:8px; width: 1%; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Give us your feedback...</LEGEND>
			<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0">
				<TR>
					<TD VALIGN="top"><B>From:</B></TD>
					<TD VALIGN="top"><INPUT TYPE="text" NAME="From" SIZE="75"></TD>
				</TR>
				<TR>
					<TD VALIGN="top"><B>Subject:</B></TD>
					<TD VALIGN="top"><INPUT TYPE="text" NAME="Subject" SIZE="75"></TD>
				</TR>
				<TR>
					<TD VALIGN="top"><BR><B>Message:</B>
						<P>&nbsp;</TD>
					<TD VALIGN="top">
					
						<CF_SCALABLETEXTAREA 
							NAME="Message" 
							ID="Message" 
							COLS="77" 
							ROWS="8" 
							INCREMENTLABEL="<IMG SRC=""/images/bigger.gif"" BORDER=""0"" TITLE=""Bigger"">" 
							decrementLabel="<IMG SRC=""/IMAGES/SMALLER.GIF"" BORDER=""0"" TITLE=""SMALLER"">">
							
						</CF_SCALABLETEXTAREA>						
					
					</TD>
				</TR>
				<TR>
					<TD VALIGN="top">&nbsp;</TD>
					<TD VALIGN="top"><INPUT TYPE="submit" VALUE="Send Message" NAME="Button"></TD>
				</TR>
			</TABLE>
</FIELDSET>
</CENTER>
</FORM>


<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>
