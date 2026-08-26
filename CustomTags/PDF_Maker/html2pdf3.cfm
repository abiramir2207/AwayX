<CFPROCESSINGDIRECTIVE SUPPRESSWHITESPACE="Yes">
<!---
CF_HTML2PDF3 is a wrapper for the HTMLDoc.exe program by EasySW.com!

Credits:
	HTMLDOC.exe is a freeware utility written by EasySW.com
	Originally written as a wrapper for CFX_HTML2PDF, a custom tag created by Dave DeVol!
History:
	CF_HTML2PDF2 was written as a wrapper for the CFX_HTML2PDF custom tag created by Dave DeVol!
	Apparantly, a recent Microsoft patch disabled the functionality of the DLL in that tag rendering 
	it non-functional. CF_HTML2PDF3 bypasses the DLL and uses CFExecute to access HTMLDoc.exe directly.

Miscellaneous:
	HTMLDoc.exe provides an excellent way to create PDF files on the fly from static HTML pages. 
	CF_HTML2PDF3 allows you to create PDF files from any dynamic CFM page simply by encasing 
	whatever portion of the page you wish to display inside the opening and closing CF_HTML2PDF3 tags. 

Copyright:
	CF_HTML2PDF3 is copyright 2001 by Michael Shreiber
		LICENSE: 
			This code is distributed as "Cool-Ware"! In other words, be cool to someone today!
		SOURCE CODE:
			The source code is available for a measley $5 via PayPal at this URL: 
			Https://secure.paypal.com/cgi-bin/webscr?cmd=_xclick&business=mshreib@fred.net&return=http://www.letsjam.com&undefined_quantity=1&item_name=CF_HTML2PDF2%20Custom%20Cold%20Fusion%20Tag%20Source%20Code&item_number=CF_HTML2PDF2&amount=5.00

	HTMLDoc.exe program is copyright by EasySW.com

USAGE:
CF_HTML2PDF3 grabs the contents of the dynamic page and writes it to a static file for 
processing by HTMLDoc.exe while simultaneously displaying the dynamic page to the user. 
HTML2PDF3 requires only the myHTMLDOC attribute (The path to HTMLDOC.exe) to work. In fact, 
the defaults should work well for most situations.

Attribute list:
myHTMLDOC= (REQUIRED) The full path to  HTMLDOC.exe with NO trailing slash (path only, do not include filename.). (ie. C:\cfusion\htmldoc )
mySTATPATH= The path to where you want your static HTML file created with no trailing slash. (ie. c:\ )
mySTATFILE= The file name you wish to use for your static HTML file. Can be dynamic. (ie. mySTATFILE.html  or  #QueryResult#.html  )
myDelSTATFILE= Yes/No Delete the static html file after creating pdf. Default is Yes. You're on your own to delete the PDF file.
myOUTPUT= Yes/No Displays the dynamic HTML results in the browser. Otherwise it just creates the pdf file. Default is Yes.
myPDFPath= The path to where you want your PDF file created with no trailing slash. (ie. c:\ )
		Default is the directory where the calling template is located.
myPDF= The file name you wish to use for your PDF file. Can be dynamic. (ie. myPDFFILE.pdf  or  #QueryResult#.pdf  )
		Default is a client specific filename of CFID_CFToken.pdf to prevent multiple users from overwriting the same pdf file.
		The generated pdf file, called #Client.CFID#_#Client.CFToken#.pdf can be accessed in the calling 
		template by using <A HREF="#Client.CFID#_#Client.CFToken#.pdf">Your PDF File</A>
myOPTIONS= All the options available in Chapter 8 of the HTMLDOC documentation, seperated by a space.
		(ie. myOPTIONS="--landscape --fontsize 7pt --browserwidth 640") NOTE: The --webpage -f options are not necessary

EXAMPLE:

//--- do your query ---//
<cfquery name="myQuery">
Select * from myTable
</cfquery>

//--- HTML2PDF3 opening tag to capture the dynamic data ---//
<CF_HTML2PDF3 myHTMLDOC="c:\cfusion\htmldoc.exe" myOPTIONS="--landscape --fontsize 10pt">

	<TABLE>
	//--- Output the results of your query ---//
	<CFOUTPUT QUERY="myQuery">
	<TR><TD>#myData#</TD></TR>
	</CFOUTPUT>
	</TABLE>

//--- Close the HTML2PDF3 tag ---//
</CF_HTML2PDF3>

RETURN LINKS:
	This will output a client specific file called #Client.CFID#_#Client.CFToken#.pdf 
	which can be accessed in the calling template by using either:

	<A HREF="#Client.CFID#_#Client.CFToken#.pdf">Default PDF File</A> OR
	<A HREF="#Request.myPDF#">Your PDF File</A>

	You must have ClientManagement turned on in your application.cfm template.
	
--->

<!--- When no Ending-Tag is used throw an Exception --->
<cfif ThisTag.HasEndTag EQ false>
	<CFTHROW message="CF_HTML2PDF3 needs an ending tag! Please ensure that this tag has a closing tag.">
	<CFEXIT>
</cfif>

<!--- Set incoming parameter defaults --->
<cfif IsDefined("Attributes.myHTMLDOC") IS "No">
	<cfset Attributes.myHTMLDOC = "C:\cfusion\htmldoc\htmldoc.exe">
</cfif>
<cfif IsDefined("Attributes.mySTATPATH") IS "No">
	<cfset Attributes.mySTATPATH = "#GetDirectoryFromPath(GetTemplatePath())#">
</cfif>
<cfif IsDefined("Attributes.mySTATFILE") IS "No">
	<cfset Attributes.mySTATFILE = "Generated_#DateFormat(Now(), 'm-d-yyyy')#_#TimeFormat(Now(), 'h-m-s-t')#.cfm">
</cfif>
<cfif IsDefined("Attributes.myDelSTATFILE") IS "No">
	<cfset Attributes.myDelSTATFILE = "Yes">
</cfif>
<cfif IsDefined("Attributes.myOUTPUT") IS "No">
	<cfset Attributes.myOUTPUT = "Yes">
</cfif>
<cfif IsDefined("Attributes.myPDFPATH") IS "No">
	<cfset Attributes.myPDFPATH = "#GetDirectoryFromPath(GetTemplatePath())#">
</cfif>
<cfif IsDefined("Attributes.myPDF") IS "No">
	<cfset Attributes.myPDF = "#Client.CFID#_#Client.CFToken#.pdf">
<cfelse>
	<cfif RIGHT(Attributes.myPDF,4) Is NOT ".pdf">
		<cfset Attributes.myPDF = "#Attributes.myPDF#.pdf">
	</cfif>
</cfif>
<cfif IsDefined("Attributes.myOPTIONS") IS "No">
	<cfset Attributes.myOPTIONS = "">
<cfelse>
	<CFSET Attributes.myOPTIONS = "#TRIM(Replace(Attributes.myOPTIONS, ", ", " ", "ALL"))#">
</cfif>

<!--- Begin Processing --->
<CFIF #thistag.generatedcontent# Is NOT "">
<CFOUTPUT>

<!--- Show the Output --->
<CFIF #Attributes.myOUTPUT# Is "Yes" OR #Attributes.myOUTPUT# Is "Y">
#thistag.generatedcontent#
</CFIF>

<!--- Write the file --->
<CFLOCK name="#createuuid()#" timeout="10">
<CFFILE ACTION="Write"
FILE="#Attributes.mySTATPATH#\#Attributes.mySTATFILE#"
OUTPUT="#thistag.generatedcontent#">
</CFLOCK>

<!--- Create the PDF --->
<CFLOCK name="#createuuid()#" timeout="10">
<cfEXECUTE NAME="#Attributes.myHTMLDOC#"
TIMEOUT="5"
ARGUMENTS="#Attributes.myOPTIONS# --webpage -f #Attributes.myPDFPATH#\#Attributes.myPDF# #Attributes.mySTATPATH#\#Attributes.mySTATFILE#">
</CFEXECUTE>
</CFLOCK>

<!--- Set the filename to pass back for linking --->
<CFSET Request.myPDF="#Attributes.myPDF#">

<!--- Delete the file --->
<CFIF Attributes.myDelSTATFILE Is "Yes">
	<CFLOCK name="#createuuid()#" timeout="10">
	<CFFILE ACTION="Delete"	FILE="#Attributes.mySTATPATH#\#Attributes.mySTATFILE#">
	</CFLOCK>
</CFIF>

</CFOUTPUT>
</CFIF>

<!--- Clear the content to prevent redisplay --->
<CFSET thistag.generatedcontent="">

</CFPROCESSINGDIRECTIVE>