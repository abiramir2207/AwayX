<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>wddxFormLibrary</TITLE>
	<STYLE>
	<!--
		p,td,th,div,blockquote,li { font-family: Arial, Helvetica, sans-serif; font-size: 13px}
		h3 { font-family: Arial, Helvetica, sans-serif; background-color: #FFFFFF; border-bottom: thin solid #a3a3a3; color: #000000; font-size: 16px; text-align: left;}
		input,option,textarea { font-family: Arial, Helvetica, sans-serif; font-size: 10px;}
		.Heading { font-family: Arial, Helvetica, sans-serif; font-size: 20px}
	-->
	</STYLE>
</HEAD>


<BODY BGCOLOR="#ffffff">

<P ALIGN="Center"><FONT SIZE="4" CLASS="Heading"><B>The wddxFormLibrary Library w/CF_FormWizard</B></FONT><BR>
<B>Version 1.1</B></P>

<H3>Introduction</H3>

<P>The wddxFormLibrary is a JavaScript-based library that will simplify the process of converting the 
contents of a form into a WDDX packet. The library will automatically parse through all of the elements 
in a form and convert the information into a structure which is stored within a centralized structure that 
can contain a number of different forms.</P>

<P>The wddxFormLibrary will also handle <B>repopulating</B> the form from an existing WDDX packet (created
with the wddxFormLibrary function calls.) This means you can easily take snapshots of a form's content
and repopulate the page without any additional server-side coding.</P>

<P>Because of the unique nature in which the wddxFormLibrary works, you can do a number of things very
quickly, easily and most important efficiently. In a nutshell, wddxFormLibrary takes a virtual "snapshot"
of the way the current form is laid out. This means that you can use it on existing forms, store the WDDX
packet in the database and any time someone needs to re-edit that information, simply grab the packet
back from the database and pass it back to the form. Once the user's browser loads the page, the form
will automatically be returned to the way the user last left it.</P>

<P>The wddxFormLibrary also simplifies your server-based coding. How many times have you created a multi-part
form where you have to first check for existing information, code the page, check to see if the form fields
should be populated with saved information; then after the page has been submitted, you have to write all the
information back to the database? This is a very time consuming process&#151;not only in terms of coding, 
but in terms of the CPU processing. With wddxFormLibrary this method is a thing of the past. All you
need to do is point each form's "ACTION" attribute to the next page you want data collected from, then once 
all the information is collected, you can store all of the information in just one step. (Note, for added 
precaution you could store the WDDX packet between each page and check the database just for that packet. 
This would protect users from losing information if their machine crashed or they close their browser on 
accident.)</P>

<P>To see the wddxFormLibrary in action, check out the examples below:</P>

<P><TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0">
<TR>
	<TD ALIGN="LEFT" VALIGN="TOP"><nobr><B><A HREF="example1.cfm">Example 1</A></B></nobr></TD>
	<TD WIDTH="20"></TD>
	<TD ALIGN="LEFT" VALIGN="TOP">
		Shows how wddxFormLibrary can be used on a single page to take a snapshot of the
		content, or how it can be used to collect the same information multiple times.
	</TD>
</TR>
<TR>
	<TD ALIGN="LEFT" VALIGN="TOP"><nobr><B><A HREF="example2_1.cfm">Example 2</A></B></nobr></TD>
	<TD WIDTH="20"></TD>
	<TD ALIGN="LEFT" VALIGN="TOP">
		Shows how wddxFormLibrary can be used on a multi-part form. Uses &lt;CF_FormWizardTools ACTION="Flatten"&gt;
		to convert the final packet into an easier to use format.
	</TD>
</TR>
<TR>
	<TD ALIGN="LEFT" VALIGN="TOP"><nobr><B><A HREF="example3_1.cfm">Example 3</A></B></nobr></TD>
	<TD WIDTH="20"></TD>
	<TD ALIGN="LEFT" VALIGN="TOP">
		Shows how you can use the changeForm() and getPacketArray() functions to build custom forms that
		allow you to edit multiple records without reloading.
	</TD>
</TR>
<TR>
	<TD ALIGN="LEFT" VALIGN="TOP"><nobr><B><A HREF="example4_1.cfm">Example 4</A></B></nobr></TD>
	<TD WIDTH="20"></TD>
	<TD ALIGN="LEFT" VALIGN="TOP">
		Shows you how to use the &lt;CF_FormWizardTools ACTION="Create"&gt; function to create default
		values for your forms by building a simple structure. (NOTE: The source code also includes
		an example of how you could retrieve a stored packet as well.)
	</TD>
</TR>
</TABLE></P>

<H3>Download</H3>
<P>Filneame: <A HREF="./CF_FormWizardv11b.zip">CF_FormWizardv11b.zip</A></P>

<BLOCKQUOTE><FONT COLOR="#cc0000"><B>Important!</B></FONT> If you're upgrading from v1.0 to
v1.0a (or higher), I've made a minor change to fix the problem with the hidden form name being 
passed with the wddxPacket. To correct the problem I had to make a minor change to the
format of the JavaScript that was generated in the CF_FormWizard. If you're not using
the CF_FormWizard tag, then you must change the instance of your first "myField" variable
to "myPacketName". If you're using the CF_FormWizard tag to generate your code, you
shouldn't have any problems.</BLOCKQUOTE>

<H3>New Features</H3>
<UL>
	<LI><B>CF_FormWizard v1.1b</B> (Released: 3/27/2000)
		<UL>
			<LI>Fixed bug that prevented hidden form fields from being repopulated.
		</UL>
	<LI><B>CF_FormWizard v1.1a</B> (Released: 3/27/2000)
		<UL>
			<LI>Fixed bug that caused deserialize the form's WDDX packet to throw an error.
		</UL>
	<LI><B>CF_FormWizard v1.1</B> (Released: 3/23/2000)
		<UL>
			<LI>You can now pass an empty string to the attribute WDDXPACKET. If an empty string is found, it
			will create a new packet. If the string begins with "&lt;wddxpacket " it'll assume it's a valid
			packet and use those contents instead.
			<LI>Added the "EXCLUDE" attribute to &lt;CF_FormWizard&gt; tag. This attribute let's you specify
			a list of form fields that should not appear in the wddxPacket. This is useful for fields
			like "Confirm Password" text input box.
			<LI>Added the "WDDXFIELDNAME" attribute to &lt;CF_FormWizard&gt; tag. This attribute let's you specify
			the hidden field to store your WDDX packet in. The default value is "wddxPacket". (NOTE: If you
			change the default field name, you must continue to specify the WDDXFIELDNAME attribute anytime
			you use the &lt;CF_FormWizard&gt; tag.
			<LI>Added the "EXCLUDE" attribute to &lt;CF_FormWizardTools&gt; tag. This attribute let's you specify
			a list of columns or keys that should not appear in the wddxPacket when creating a new packet from
			either a query or structure object
		</UL>
	<LI><B>CF_FormWizard v1.0b1</B> (Released: 3/18/2000)
		<UL>
			<LI>Added new examples and changed existing examples to show off the new CF_FormWizardTools tag.

			<LI>Added the "CREATE" action to the CF_FormWizardTools tag. This action 
			will allow you to create a correctly formatted wddxPacket from either
			a single structure (containing only simple values) or from a query object.
			
			<P>The CREATE action will allow you to quickly create default values for
			single page forms or forms where you'll be editing the same data on every
			page. (Remember, you can also manually create a default packet by simply
			create a correct formatted structure and serializing it to WDDX.)</P>
			
			<P>The required values for this attribute are: ACTION, INPUT.
			The <B>INPUT</B> field requires an fully <I>evaluate</I> structure or query object.
			The attributes KEY, TITLE and URL are option and vary in function depending on whether you're 
			passing a structure or query object.</P>
			
			<P>When passing a <I>structure</I> object, you'll want to pass the <U>string</U> values to each
			optional attribute that you want appear in the WDDX packet. By default, the KEY and URL
			attribute will return the URL of the calling template and TITLE attribute will be blank.</P>
			
			<P>If passing a <I>query</I> object, you'll want to pass the <U>column name</U> that each
			optional attribute should use to retrieve it's value from. By default the value from each
			attribute will be gathered from the first column return by the CF's ColumnList variable.
			(<B>NOTE:</B> If you'd like prefix you're URL keys with a default string, use the option 
			<B>DefaultURL</B> attribute. This is useful if you're using a primary/foreign key column 
			for the value and would like to have the value prefixed with the page's URL. 
			(i.e. DefaultURL="index.cfm?id=" would added the string "index.cfm?id=" before each URL 
			key in the structure.)</P>
			
		</UL>
	<LI><B>CF_FormWizard v1.0a</B> (Released: 3/17/2000)
		<UL>
			<LI>Added the CF_FormWizardTools tag. This tag requires 2 attributes: ACTION 
			and WDDXPACKET. Valid "<B>ACTION</B>" statements are "Flatten" or "Serialize".
			
			<P>The "Serialize" action will convert the WDDX packet into a valid ColdFusion
			structure. To specify the output name, use the OUTPUT attribute. (Default
			is "stcFormWizard".)</P>
			
			<P>The "Flatten" action will flatten the structure into a structure only one
			level deep. This is great for using the library in a true wizard-like style. (See
			"Example 2.")</P>
			
			<LI>Rewrote some of the copy in the examples. This should help clear up some
			of the confusing points as well as give some new insight for using the tag.
			
			<LI>I also added my CF_ObjDump tag to display the contents of the structures
			at the end of each example.
			
		</UL>
</UL>

<H3>Changes & Bug Fixes</H3>
<UL>
	<LI><B>v1.1b</B>
		<UL>
			<LI>Fixed bug that prevented hidden form fields from being repopulated.
		</UL>
	<LI><B>v1.1a</B>
		<UL>
			<LI>Fixed bug that caused deserialize the form's WDDX packet to throw an error.
		</UL>
	<LI><B>v1.1</B>
		<UL>
			<LI>Fixed bug with "Password" field which prevent the value in a "Password" box from being filled in.
			<LI>Changed window.onload check to automatically populate the value w/the initWDDX() function.
			(NOTE: If need to run more functions on the page load, then make sure to call the function
			"initWDDX();" from inside your custom function.)
		</UL>
	<LI><B>v1.0b2</B>
		<UL>
			<LI>Fixed bug in &lt;CF_FormWizardTools&gt; which failed to append the CGI.QUERY_STRING
			to the default Attributes_URL value when a new packet is being created from a structure.
		</UL>
	<LI><B>v1.0b1</B>
		<UL>
			<LI>Removed the KEY,URL,TITLE attributes from being required. This allowed
			me to automatically defined the KEY & URL attributes when the object
			is a structure.
			<LI>Fixed bug in &lt;CF_FormWizardTools ACTION="Create"&gt; tag which was
			causing the wrong value to be returned.
			<LI>Added carriage return between outputing of each button generated by 
			the &lt;CF_FormWizard&gt; tag. This will add a space between each button.
		</UL>
	<LI><B>v1.0a</B>
		<UL>
			<LI>Fixed bug which caused the name of the WDDX packet you were using
			to be a key inside the form's "FORM" structure.
		</UL>
	<LI><B>v.99a (BETA)</B>
		<UL>
			<LI>Fixed bug in changeForm() function that was causing Netscape 
			to not properly show repopulated fields in Example 3.
		</UL>
</UL>

</BODY>
</HTML>
