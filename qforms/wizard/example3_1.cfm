<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>WDDX Form Wizard: Example 3 (Page 1)</TITLE>
	<STYLE>
	<!--
		p,td,th,div,blockquote { font-family: Arial, Helvetica, sans-serif; font-size: 10pt}
		h3 { font-family: Arial, Helvetica, sans-serif; background-color: #FFFFFF; border-bottom: thin solid #a3a3a3; color: #000000; font-size: 12pt; text-align: left;}
		input,option,textarea { font-family: Arial, Helvetica, sans-serif; font-size: 8pt;}
	-->
	</STYLE>
</HEAD>


<BODY BGCOLOR="#ffffff">

<H3>Example 3</H3>

<P>This example illustrates how the wddxFormWizard library's changeForm() and getPacketArray() functions
can be used to build a page to edit existing packet information. This page reads in a WDDX packet saved
as an ASCII file. It then displays the different forms stored in the packet and allows you to edit
them. This also shows an example of how custom keys can be used for the forms. After the form has been
edited, and you click "Finish" the new packet will be saved in place of the old packet. When you
reload this page, the new example should appear.</P>


<SCRIPT><!--//
var aryPackets = getPacketArray();

document.write("<FORM ACTION=\"example3_1.cfm\" METHOD=\"POST\">");
document.write("<SELECT NAME=\"GetPacket\" onChange=\"saveFields();changeForm(this[this.selectedIndex].value);\">");
document.write("<OPTION VALUE=''>Select a packet to edit</OPTION>");
document.write("<OPTION VALUE=''>-----------------------</OPTION>");
for(i=0; i < aryPackets.length; i++){
	document.write("<OPTION VALUE='" + aryPackets[i].key + "'>" + aryPackets[i].title + "</OPTION>");
}
document.write("</SELECT></FORM>");
//--></SCRIPT>


<FORM ACTION="example3_2.cfm" METHOD="POST" NAME="wddxFormWizard">
<P>
<B>Name:</B><BR>
<INPUT TYPE="Text" NAME="Name" VALUE="" STYLE="width: 400px;"><BR>

<B>E-mail:</B><BR>
<INPUT TYPE="Text" NAME="Email" VALUE="" STYLE="width: 400px;"><BR>


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

<P><B>Occupation:</B><BR>
<SELECT NAME="Occupation" MULTIPLE SIZE="3">
	<OPTION VALUE="1">Web Developer</OPTION>
	<OPTION VALUE="2">Network Engineer</OPTION>
	<OPTION VALUE="3">Sales</OPTION>
</SELECT>
</P>

<CFFILE ACTION="READ" FILE="#GetDirectoryFromPath(GetTemplatePath())#example3.wddx" VARIABLE="wddxPacket">

<CF_FormWizard
	WDDXPACKET="#wddxPacket#"
	FINISH_URL="example3_2.cfm"
	SHOWBUTTONS="RESET,FINISH"
	SHOWNAVIGATION="NO"
	SHOWDEBUG="NO">

<!--------------------------------------------------------------------------
the above uses the default values, which would look like this written out: 
	<CF_FormWizard
		FORMNAME="document.wddxFormWizard"
		JS_WDDX="/cfide/scripts/wddx.js"
		JS_WDDXFORMWIZARD="wddxFormWizard.js"
		SHOWBUTTONS="RESET,FINISH"
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
