<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>WDDX Form Wizard: Example 2 (Page 2)</TITLE>
	<STYLE>
	<!--
		p,td,th,div,blockquote { font-family: Arial, Helvetica, sans-serif; font-size: 10pt}
		h3 { font-family: Arial, Helvetica, sans-serif; background-color: #FFFFFF; border-bottom: thin solid #a3a3a3; color: #000000; font-size: 12pt; text-align: left;}
		input,option,textarea { font-family: Arial, Helvetica, sans-serif; font-size: 8pt;}
	-->
	</STYLE>
</HEAD>


<BODY BGCOLOR="#ffffff">

<FORM ACTION="example2_3.cfm" METHOD="POST" NAME="wddxFormWizard">

<H3>Example 2</H3>

<P>This example illustrates a multi-part form. The last page uses the CF_DumpStruct tag written
by Al Manning to show the structure that has been created.</P>

<P><B>Newsletters:</B><BR>
<INPUT TYPE="Checkbox" NAME="Newsletters" VALUE="1">
TechNews<BR>
<INPUT TYPE="Checkbox" NAME="Newsletters" VALUE="2">
WebNews<BR>
<INPUT TYPE="Checkbox" NAME="Newsletters" VALUE="3">
Jobs</P>

<P><B>Receive Mailing List?:</B><BR>
Yes <INPUT TYPE="Radio" NAME="MailingList" VALUE="YES" CHECKED>
No <INPUT TYPE="Radio" NAME="MailingList" VALUE="NO">
Maybe <INPUT TYPE="Radio" NAME="MailingList" VALUE="MAYBE">
</P>

<P><B>Newsletter Format:</B><BR>
<SELECT NAME="Format">
	<OPTION VALUE="">-----------------</OPTION>
	<OPTION VALUE="ASCII">ASCII</OPTION>
	<OPTION VALUE="HTML">HTML</OPTION>
	<OPTION VALUE="WORD">MS Word</OPTION>
</SELECT>
</P>

<CF_FormWizard
	SHOWBUTTONS="BACK,RESET,NEXT"
	SHOWNAVIGATION="YES">

<!--------------------------------------------------------------------------
the above uses the default values, which would look like this written out: 
	<CF_FormWizard
		FORMNAME="document.wddxFormWizard"
		JS_WDDX="/cfide/scripts/wddx.js"
		JS_WDDXFORMWIZARD="wddxFormWizard.js"
		SHOWBUTTONS="BACK,RESET,NEXT"
		BTN_NEXT="Next &gt;"
		BTN_BACK="&lt; Back"
		BTN_RESET="Reset"
		SAVEONBACK="YES"
		SHOWNAVIGATION="YES"
		SHOWDEBUG="YES">

the "SHOWBUTTONS" attribute excepts three valid options, "BACK", "NEXT" 
and "RESET". the buttons are displayed in the order they appear in the
list
-------------------------------------------------------------------------->

</FORM>

<P><A HREF="index.cfm">Back to Introduction</A></P>

</BODY>
</HTML>
