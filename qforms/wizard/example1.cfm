<CFSETTING ENABLECFOUTPUTONLY="YES">

<CFPARAM NAME="URL.page" DEFAULT="0">

<CFIF URL.page EQ 0>
	<CFLOCATION URL="example1.cfm?page=1">
</CFIF>

<CFSETTING ENABLECFOUTPUTONLY="NO">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>WDDX Form Wizard: Example 1 (Page <CFOUTPUT>#URL.Page#</CFOUTPUT>)</TITLE>
	<STYLE>
	<!--
		p,td,th,div,blockquote { font-family: Arial, Helvetica, sans-serif; font-size: 10pt}
		h3 { font-family: Arial, Helvetica, sans-serif; background-color: #FFFFFF; border-bottom: thin solid #a3a3a3; color: #000000; font-size: 12pt; text-align: left;}
		input,option,textarea { font-family: Arial, Helvetica, sans-serif; font-size: 8pt;}
	-->
	</STYLE>
</HEAD>


<BODY BGCOLOR="#ffffff">

<FORM ACTION="example1.cfm?page=<CFOUTPUT>#Evaluate(Val(URL.page) + 1)#</CFOUTPUT>" METHOD="POST" NAME="wddxFormWizard">

<H3>Example 1</H3>

<P>This example illustrates how the wddxFormWizard library can be used to either take a snapshot of single
form, or how it can be used to capture the same information multiple times. The wddxFormWizard is able to 
keep track of each pages content by capturing and storing the current browser location. When ever a page
using the wddxFormLibrary is loaded and an existing WDDX packet is found, the initWDDX() function will
checl for existing information for this location and populate the form with what it found. Because the
wddxFormLibrary relies on unique URLs for locating and storing the current page's info, when collecting
page as unique. In this example, I'm using a simple page counter that tracks the page I'm on. Cliking
finish will display all the form information collected.</P>

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

<CFSET lstButtons = "BACK,RESET,NEXT,FINISH">
<CFIF URL.Page EQ 1>
	<CFSET lstButtons = "RESET,NEXT,FINISH">
</CFIF>

<CF_FormWizard
	FINISH_URL="example1_done.cfm"
	SHOWBUTTONS="#lstButtons#"
	SHOWNAVIGATION="YES"
	SHOWDEBUG="YES">

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
