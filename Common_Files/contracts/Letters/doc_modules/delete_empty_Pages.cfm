<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/delete_empty_pages.cfm
CREATED: 		08/16/2010 - Milan [Convert to Itext in Java]

FUNCTIONALITY:
- This is used to delete any empty pages in the letter (If any).
--->
</cfsilent>

<!---	These two libraries already exist on "inc_all_code_libraries.cfm", but that file gets inclued when appSettings.getlettersavailable() eq 1.
	If not, we need to call it specifically from here as it is required for "delete empty pages" process.	
--->
<cfset objFile = CreateObject("java", "java.io.File")>
<cfset document = createObject("java", "com.lowagie.text.Document").init()>



<!--- Path of the file with the "temp_1" suffix --->
<cfset fullPathToInputTempFile_1 = thisTag.pdf_file_path>

<!--- Path of the file with the "temp_2" suffix --->
<cfset fullPathToOutputTempFile_2 = Replace(thisTag.pdf_file_path, "temp_1.pdf","temp_2.pdf")>

<!--- For file with the "temp_2" suffix --->
<cfset outStream = createObject("java", "java.io.FileOutputStream").init(fullPathToOutputTempFile_2)>

<!--- For file with the "temp_1" suffix. We need to read this file to find any empty pages --->
<cfset pdfReader = createObject("java", "com.lowagie.text.pdf.PdfReader").init(fullPathToInputTempFile_1)> 

<!--- We need this to create a new file (In this case a file with the "temp_2" suffix) --->
<cfset pdfCopy = createObject("java", "com.lowagie.text.pdf.PdfCopy").init(document, outStream)>
<!---
<cfset RandomAccessFileOrArray = createObject("java", "com.lowagie.text.pdf.RandomAccessFileOrArray")>
--->

<!--- Open the file with the "temp_2" suffix (fullPathToInputTempFile_2), which is a blank file --->
<cfset document.open()>

<!--- Get the number of pages --->
<cfset totalPages = pdfReader.getNumberOfPages()>       

<cfset byteArrStream = createObject("java", "java.io.ByteArrayOutputStream")>


	<cfset i = 1>
	
	<!--- Loop through the pages --->
	<cfloop condition="i LTE totalPages">   
	

		<!--- Get content page by page --->
		<cfset pageContent = pdfReader.getPageContent( javacast("int", i) )>
		<cfset byteArrStream_1 = byteArrStream.init()>

		<!--- Write the page content to the output stream --->
		<cfset byteArrStream_1.write(pageContent)>
		
		<!--- If the page is not empty --->
		<cfif byteArrStream_1.size() GT 20>
			
			<!--- Include the page for the new pdf file (In this case it is with a "temp_2" suffix --->
			<cfset page = pdfCopy.getImportedPage(pdfReader,i)>
			<cfset pdfCopy.addPage(page)>			
		</cfif>

		<cfset i = i + 1> 
	  
		<!--- Close byteArrStream --->
		<cfset byteArrStream_1.close()>
		<cfset byteArrStream_1 =  "null">

	 </cfloop>


	<!--- Close pdfreader --->
	<cfif (IsDefined("pdfReader"))>
		<!--- Release memory used by pdfReader --->
		<cfset pdfCopy.freeReader(pdfReader)>
		<cfset pdfReader.close()>
		<cfset pdfReader = "null">
	</cfif>

	<!--- Close pdfCopy --->
	<cfif (IsDefined("pdfCopy"))>   
		<cfset pdfCopy.close()> 
		<cfset pdfCopy = "null">
	</cfif>

	<!--- Close outStream --->
	<cfif (IsDefined("outStream"))>  
		<cfset outStream.close()>
		<cfset outStream = "null">
	</cfif>

	<!--- Close document --->
	<cfset document.close()> 

	<!--- Give the Java object the path to our temp file number 1 --->
	<cfset fileInstance = objFile.init('#fullPathToInputTempFile_1#') />
	
	<!--- Delete the temp file number 1 (with the "temp_1" suffix) --->
	<cfset fileInstance.Delete() />