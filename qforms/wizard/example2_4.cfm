<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>WDDX Form Wizard: Example 2 (Page 4)</TITLE>
	<STYLE>
	<!--
		p,td,th,div,blockquote { font-family: Arial, Helvetica, sans-serif; font-size: 10pt}
		h3 { font-family: Arial, Helvetica, sans-serif; background-color: #FFFFFF; border-bottom: thin solid #a3a3a3; color: #000000; font-size: 12pt; text-align: left;}
		input,option,textarea { font-family: Arial, Helvetica, sans-serif; font-size: 8pt;}
	-->
	</STYLE>
</HEAD>


<BODY BGCOLOR="#ffffff">

<H3>Example 2</H3>

<P>Since we're to the final step of the wizard, this is where you'd insert
you code to store the information into the database. I also recommend storing
the WDDX packet into your database as well. That way, when a user comes back
to the page, you can simply pass the store packet back to the first page
and all their value from before will automatically be populated!</P>

<P>This page uses the &lt;CF_FormWizardTools&gt; tag to serialize and then "flatten"
the WDDX packet and the custom tag &lt;CF_ObjDump&gt; to display the contents to 
the screen. Notice how by "Flattening" the packet, I know have a single easy
to use structure that I can easily use to store my data in. (<B>NOTE:</B> A flatten
structure is unusable to the wddxFormLibrary, but is much easier to work with.)</P>



<CF_FormWizardTools ACTION="Flatten" WDDXPACKET="#FORM.wddxPacket#" OUTPUT="wddxPacket">
<CF_ObjDump OBJECT="wddxPacket">

<P><A HREF="index.cfm">Back to Introduction</A></P>

</BODY>
</HTML>
