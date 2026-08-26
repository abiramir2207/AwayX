<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/delete_requested_pages.cfm
CREATED: 		08/23/2010 - Milan [Convert to Itext in Java]

FUNCTIONALITY:
- This is used to delete pages requested by the user
--->
</cfsilent>

<!--- Path of the file with the "temp_1" suffix --->
<cfset fullPathToInputTempFile_1 = thisTag.pdf_file_path>

<!--- Path of the file with the "temp_delete_pages" suffix --->
<cfset fullPathToOutputTempFileDeletePages = Replace(thisTag.pdf_file_path, "temp_1.pdf","temp_delete_pages.pdf")>

<!--- For file with the "temp_delete_pages" suffix --->
<cfset outStream = createObject("java", "java.io.FileOutputStream").init(fullPathToOutputTempFileDeletePages)>

<!--- For file with the "temp_1" suffix. We need to read this file to find any empty pages --->
<cfset pdfReader = createObject("java", "com.lowagie.text.pdf.PdfReader").init(fullPathToInputTempFile_1)> 

<!--- We need this to create a new file (In this case a file with the "temp_2" suffix) --->
<cfset pdfCopy = createObject("java", "com.lowagie.text.pdf.PdfCopy").init(document, outStream)> 

<cfset document.open()>

<!--- Get the number of pages --->
<cfset totalPages = pdfReader.getNumberOfPages()>       


	<cfset i = 1>
	
	<!--- Loop through the pages --->
	<cfloop condition="i LTE totalPages">   
		
			<cfif ListFindNoCase(trim(thisTag.cumulative_pages_to_delete_from_letter),i) eq 0>

				<!--- Include the page for the new pdf file (In this case it is with a "temp_2" suffix --->
				<cfset page = pdfCopy.getImportedPage(pdfReader,i)>
				<cfset pdfCopy.addPage(page)>
			</cfif>
	<cfset i = i + 1>

	 </cfloop>

<!--- Close pdfReader --->
<cfif (IsDefined("pdfReader"))>
	<cfset pdfReader.close()>
</cfif>

<!--- Close pdfCopy --->
<cfif (IsDefined("pdfCopy"))>   
	<cfset pdfCopy.close()> 
</cfif>

<!--- Close document --->
<cfset document.close()>

<!--- Give the Java object the path to our temp file number 1 --->
<cfset fileInstance = objFile.init('#fullPathToInputTempFile_1#') />

<!--- Delete the temp file number 1 (with the "temp_1" suffix) --->
<cfset fileInstance.Delete() />

<!--- Give the Java object the path to our temp file which will be created after the requested pages are deleted  (with the "temp_delete_pages" suffix) --->
<cfset fileInstance = objFile.init('#fullPathToOutputTempFileDeletePages#') />
.
<!--- Rename the file with "temp_delete_pages.pdf" suffix to suffix of "temp_1".
"Delete_empty_Pages.cfm", which is the next step uses the file with the "temp_1" suffix.
--->
<cfset fileInstance.renameTo(objFile.init('#fullPathToInputTempFile_1#'))>

	