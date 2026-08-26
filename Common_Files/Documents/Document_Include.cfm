<!---
	File Name: Document_Include.cfm
	Created by: Deepa Kunnath
	Created on: 6/8/2010
	Label for creation: D23651 Event 213 - can't open document
	Lowest build available: 6.0
	
	Usage:  <cfinclude template="Common_Files/Documents/Document_Include.cfm" />
	
	Consolidated the function being used by many different files to access uploaded document
	from program, billback, deducton, setting etc.
	
	This file can contain any other common code that can be reused within documents.
	confirmDocServerGet
 --->

<!--- 
			Dev Notes: D24468/Tim Ford/17-Aug-10
			URL on HTTP or HTTPS
--->  

<cfparam name="bDocViewer" default="0" >
<cfset siteURL = application.HTTPVar & CGI.SERVER_NAME />
<cfif bDocViewer eq 0>
	<SCRIPT language="JavaScript">
		var file_name;
		function confirmation(file)
		{
			file_name = file;
				var view_confirm = confirm("Large files may take a long time to open. Do you still wish to continue?");
	
	           if (view_confirm)
	           {
	   			NewWindow('<CFOUTPUT>#siteURL#</CFOUTPUT>/GetDocument.cfm?FilePath=data_files/uploaded/documents/uploaded_doc/' + escape(encodeURI(file_name)), 'docdisplay', '800', '600', 'Yes', 'Yes');
				}
		}
</SCRIPT>
<cfelse>
	<SCRIPT language="JavaScript">
	
		function confirmDocServerGet(file_name,Doc_Uni_Name)
		{
			var view_confirm = confirm("Large files may take a long time to open. Do you still wish to continue?");
	
	           if (view_confirm)
	           {
                   if(Doc_Uni_Name.length){
                       /* Get file from web server root */
                       NewWindow('<CFOUTPUT>#siteURL#</CFOUTPUT>/GetDocument.cfm?FilePath=data_files/uploaded/documents/uploaded_doc/' + escape(encodeURI(Doc_Uni_Name)), 'docdisplay', '800', '600', 'Yes', 'Yes');
                   }
                   else {
                       /* Get file from Pittsburg server */
	           	       NewWindow('<CFOUTPUT>#siteURL#</CFOUTPUT>/common_files/Documents/GetDocumentBBUpload.cfm?getfile=1&txtFileName=' + escape(encodeURI(file_name)), 'docdisplay', '800', '600', 'Yes', 'Yes');
		           }
                   }
		}
	</SCRIPT>
</cfif>