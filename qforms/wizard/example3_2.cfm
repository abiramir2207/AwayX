<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>WDDX Form Wizard: Example 3 (Page 2)</TITLE>
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

<P>This example illustrates how the wddxFormWizard library can be used to either take a snapshot of single
form, or how it can be used to capture the same information multiple times. The wddxFormWizard is able to 
keep track of each pages content by capturing and storing the current browser location. When ever a page
using the wddxFormLibrary is loaded and an existing WDDX packet is found, the initWDDX() function will
check for existing information for this location and populate the form with what it found. Because the
wddxFormLibrary relies on unique URLs for locating and storing the current page's info, when collecting
multiple forms from the same URL, you must append the query string with something that will identify the
page as unique. In this example, I'm using a simple page counter that tracks the page I'm on. Clicking
finish will display all the form information collected.</P>

<P>This page uses the &lt;CF_FormWizardTools&gt; tag to serialize the WDDX packet and the
custom tag &lt;CF_ObjDump&gt; to display the contents to the screen.</P>


<CF_FormWizardTools ACTION="Serialize" WDDXPACKET="#FORM.wddxPacket#" OUTPUT="wddxPacket">
<CF_ObjDump OBJECT="wddxPacket">

<CFFILE ACTION="WRITE" FILE="#GetDirectoryFromPath(GetTemplatePath())#example3.wddx" OUTPUT="#FORM.wddxPacket#" ADDNEWLINE="Yes">

<P><A HREF="index.cfm">Back to Introduction</A></P>

</BODY>
</HTML>
