<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/add_header_footer.cfm
CREATED: 		08/16/2010 - Milan [Convert to Itext in Java]

FUNCTIONALITY:
- This is used to add header and footer to the letters.
--->
</cfsilent>

<!--- Path of the file with the "temp_2" suffix --->
<cfset fullPathToInputTempFile_2 = fullPathToOutputTempFile_2>

<!--- Path of the file which will be saved permanently. --->
<cfset fullPathToOutputFile = Replace(fullPathToInputTempFile_2,"_temp_2.pdf",".pdf")>

<cfset document.open()>

<!--- For file with the "temp_2" suffix. Header and Footer will be added to this file --->
<cfset pdfReader = createObject("java", "com.lowagie.text.pdf.PdfReader").init(fullPathToInputTempFile_2)>   

<!--- Get the total number of pages --->
<cfset totalPages = pdfReader.getNumberOfPages()>

<!--- For file which will be saved permanently. --->
<cfset outStream = createObject("java", "java.io.FileOutputStream").init(fullPathToOutputFile)>

<!--- we create a stamper that will copy the document to a new file --->     
<cfset pdfStamper = createObject("java", "com.lowagie.text.pdf.PdfStamper").init(pdfReader, outStream)>

<!--- Use "file:///" for https --->
<cfset variables.logoPath = 'file:///' & ExpandPath(thisTag.stPDFHeaderInfo.company_logo_path)>

<!--- [begin] Add header and footer --->

<!--- Get the path of the logo --->
<cfset ImgLogo = Image.getInstance('#variables.logoPath#')>

<!--- Resize it --->
<cfset ImgLogo.scalePercent(40)>

<!--- Dev Note: 25073 (Milan). The objective is to place the image at the top right corner of the letter. Based on the width of the image,
the horizontal position from the left needs to change.
--->
<cfif ImgLogo.Width GT 225>
  <cfset Image_Position_Left = 475>
<cfelse>
  <cfset Image_Position_Left = 500>
</cfif>

<!--- Left, Top. It seems that we we use absolute positioning, it overrides "document.setMargins" for margins set in the
"inc_all_code_libraries.cfm". This is exactly what is needed to place the header/footer in it's positions. In this case,
we are positioning the client logo on the pdf document 
--->
<!--- Dev Note: 55908 (Milan). The objective is to place the image at the top right corner of the letter. Based on the height of the image,
the vertical position from the top needs to change.
--->
<cfif ImgLogo.Height GT 140>
  <cfset Image_Position_Top = 765>
<cfelse>
  <cfset Image_Position_Top = 795>
</cfif>

<cfset ImgLogo.setAbsolutePosition(Image_Position_Left,Image_Position_Top)>

<cfset i = 0>  

<!--- Loop through the pages --->
<cfloop condition="i LT totalPages">
    
<cfset i = i + 1>

	<!--- "getUnderContent" starts from the bottom of the page --->
	<cfset under = pdfStamper.getUnderContent( javacast("int", i) )>  

	<cfset under.beginText()>

	<cfset under.setTextMatrix( javacast("float", 30), javacast("float", 30) )> 

	<!--- x position, y position, angle. The values of x and y are counted from the bottom of the page --->
	<cfset under.setFontAndSize(Gothic_Bold, javacast("float", 9))>
	<cfset under.setColorFill(textColorBrown)>
	
	<!--- [begin] header --->
	<cfset under.showTextAligned(under.ALIGN_LEFT,thisTag.stPDFHeaderInfo.contract_number, javacast("float", 37),  javacast("float", 800),   javacast("float", 0) )>

	<cfset under.setFontAndSize(Gothic_Bold, javacast("float", 7))>
	<cfset under.setColorFill(textColorBlack)>
	
	<!--- Dev Note:30856 (Commented this code)
	<cfif thisTag.stPDFHeaderInfo.program_bid_request_status neq ''>
		<cfset under.showTextAligned(under.ALIGN_LEFT,thisTag.stPDFHeaderInfo.program_bid_request_status, javacast("float", 110),  javacast("float", 825),   javacast("float", 0) )>
	</cfif>--->

	<cfset under.showTextAligned(under.ALIGN_LEFT,thisTag.stPDFHeaderInfo.program_title & ' ' &  dateFormat(thisTag.stPDFIntroInfo.contract_start_date, "m/d/yy") & "-" & dateFormat(thisTag.stPDFIntroInfo.contract_end_date, "m/d/yy") & '  ' & trim(thisTag.stPDFHeaderInfo.company_address), javacast("float", 37),  javacast("float", 785),   javacast("float", 0) )>
	<!--- [end] header --->

	<!--- [begin] Footer --->
	<cfset under.showTextAligned(under.ALIGN_LEFT,"Issued: "  & dateFormat(now(), 'dddd mmmm dd, yyyy'), javacast("float", 37),  javacast("float", 10),   javacast("float", 0) )>
	<cfset under.showTextAligned(under.ALIGN_CENTER, "Page " & i & " of " & totalPages, javacast("float", 300),  javacast("float", 10),   javacast("float", 0) )>
	<cfset under.endText()>
	<!--- [end] Footer --->

	<!--- Add the client logo --->
	<cfset under.addImage(ImgLogo)> 

	<!--- [end] Add header and footer --->
</cfloop>

 <!--- Closing PdfStamper will generate the new PDF file --->
 <cfif (IsDefined("pdfStamper"))>    
	<cfset pdfStamper.close()> 
	<cfset pdfStamper = "null">
</cfif>

<!--- Close pdfReader --->
<cfif (IsDefined("pdfReader"))>    
	<cfset pdfReader.close()> 
	<cfset pdfReader = "null">
</cfif>

<!--- Close outStream --->
 <cfif (IsDefined("outStream"))>  
	<cfset outStream.close()>
	<cfset outStream = "null">
</cfif>

<!--- Close document --->
<cfset document.close()>


<!--- Give the Java object the path to our temp file number 2 --->
<cfset fileInstance = objFile.init('#fullPathToInputTempFile_2#') />

<!--- Delete it. --->
<cfset fileInstance.Delete() />

<!--- Since now we have the file we want, reassign the filename. "thisTag.pdf_file_path" was 
			the original input parameter to "generate_program_pdf.cfm", where "temp_1" was added to 
			the value of "thisTag.pdf_file_path". Now we want to reassign the value without "temp",
			so that any further processing on "generate_program_pdf.cfm" looks at the correct file and
			not any temp files. As it is, we delete the temp file already (see code on this page - above)
--->
<cfset thisTag.pdf_file_path = fullPathToOutputFile>