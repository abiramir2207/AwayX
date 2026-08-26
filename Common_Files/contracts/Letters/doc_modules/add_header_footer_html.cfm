<cfsilent>
<!---
FILE:
FILENAME: 	doc_modules/add_header_footer_html.cfm
CREATED: 	1/17/2012 - Milan [Convert to Itext in Java]

FUNCTIONALITY:
- This is used to add header and footer to the HTML letters (PDF letters based on HTML code).
--->
</cfsilent>

<cfset Image = createobject("java", "com.lowagie.text.Image")>
<cfset color = createObject("java", "java.awt.Color")>
<cfset BaseFont = createObject("java", "com.lowagie.text.pdf.BaseFont")>
<cfset font = createObject("java", "com.lowagie.text.Font")>
<cfset FontFactory = createObject("java", "com.lowagie.text.FontFactory")>

<!--- Get the "Times New Roman" Font. --->
<cfset TimesNewRoman_Normal = BaseFont.createFont("c:\windows\fonts\times.ttf",BaseFont.WINANSI, BaseFont.EMBEDDED)>
<cfset TimesNewRoman_Bold = BaseFont.createFont("c:\windows\fonts\timesbd.ttf", BaseFont.IDENTITY_H, BaseFont.EMBEDDED)>

<!--- Set the different colors --->
<cfset textColorBlack = color.decode("##000000")>
<cfset textColorBrown = color.decode("##990000")>

<!--- Initialize default variables for display of LEFT SIDE HEADER DATA --->
<cfset LeftSideDataLabel_1 ="">
<cfset LeftSideData_1 ="">
<cfset LeftSideDataLabel_2 ="">
<cfset LeftSideData_2 ="">
<cfset LeftSideDataLabel_3 ="">
<cfset LeftSideData_3 ="">

<!--- Initialize default variables for display of RIGHT SIDE HEADER DATA --->
<cfset RightSideDataLabel_1 ="">
<cfset RightSideData_1 ="">
<cfset RightSideDataLabel_2 ="">
<cfset RightSideData_2 ="">
<cfset RightSideDataLabel_3 ="">
<cfset RightSideData_3 ="">


<!--- Get the template settings which set many variables for the display of the header --->
<cfinclude template = "template_settings.cfm">

<!---	Initially, the file gets created with "temp_1" suffix and has no header and footer. Next step is to call "delete_empty_pages.cfm", which deletes the empty pages
	and creates a new file with "temp_2" suffix and deletes the file with "temp_1" suffix. The file with "temp_2" suffix does not have a header and a footer because we
	need to check for an blank page to delete that page. Here we add header and footer to the file with "temp_2" suffix and create a new file wuth no additional suffix.
	Then the file with "temp_2" suffix gets deleted.
--->

<!--- Path of the file with the "temp_2" suffix --->
<cfset fullPathToInputTempFile_2 = fullPathToOutputTempFile_2>

<!--- Path of the file which will be saved permanently (no additional suffixes) --->
<cfset fullPathToOutputFile = Replace(fullPathToInputTempFile_2,"_temp_2.pdf",".pdf")>

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
<cfset ImgLogo.setAbsolutePosition(Image_Position_Left,755)>


<cfset i = 0>

<!--- Loop through the pages --->
<cfloop condition="i LT totalPages">

<cfset i = i + 1>

	<!--- "getUnderContent" starts from the bottom of the page --->
	<cfset under = pdfStamper.getUnderContent( javacast("int", i) )>

	<cfset under.beginText()>

	<cfset under.setTextMatrix( javacast("float", 30), javacast("float", 30) )>

	<cfset under.setFontAndSize(TimesNewRoman_Normal, javacast("float", 12))>
	<cfset under.setColorFill(textColorBlack)>

	<!--- [begin] header --->
	<!--- x position, y position, angle. The values of x and y are counted from the bottom of the page --->

	<!--- LEFT SIDE DISPLAY - Entry 1 --->
	<cfset under.showTextAligned(under.ALIGN_LEFT, thisTag.stPDFHeaderInfo.contract_number, javacast("float", LeftSideData_X),  javacast("float", Data_Row1_Y),   javacast("float", 0) )>

	<cfset under.setColorFill(textColorBrown)>
	<cfset under.showTextAligned(under.ALIGN_RIGHT, 'Program ID:'& ' ', javacast("float", LeftSideData_X),  javacast("float", Data_Row1_Y),   javacast("float", 0) )>

	<!--- RIGHT SIDE DISPLAY - Entry 1 --->
	<cfset under.setColorFill(textColorBlack)>
	<cfset under.showTextAligned(under.ALIGN_LEFT, dateFormat(thisTag.stPDFIntroInfo.contract_start_date, "m/d/yy") & "-" & dateFormat(thisTag.stPDFIntroInfo.contract_end_date, "m/d/yy"), javacast("float", RightSideData_X),  javacast("float", Data_Row1_Y),   javacast("float", 0) )>

	<cfset under.setColorFill(textColorBrown)>
	<cfset under.showTextAligned(under.ALIGN_RIGHT, 'Delivery Period:'& ' ', javacast("float", RightSideData_X),  javacast("float", Data_Row1_Y),   javacast("float", 0) )>

	<!--- LEFT SIDE DISPLAY - Entry 2 --->
	<cfset under.setColorFill(textColorBlack)>
	<cfset under.showTextAligned(under.ALIGN_LEFT, programTitlePart1, javacast("float", LeftSideData_X),  javacast("float", Data_Row2_Y),   javacast("float", 0) )>

	<!--- When program length is greater than X characters, then a part of it needs to go to the next line. This means the remaining entries on the left side go to the next line too --->
	<cfif Len(programTitlePart2) GT 0>
		<cfset under.showTextAligned(under.ALIGN_LEFT, programTitlePart2, javacast("float", LeftSideData_X),  javacast("float", Data_Row3_Y),   javacast("float", 0) )>
	</cfif>
	<cfif Len(programTitlePart3)>  <!---32417--->
		<cfset under.showTextAligned(under.ALIGN_LEFT, programTitlePart3, javacast("float", LeftSideData_X),  javacast("float", Data_Row4_Y),   javacast("float", 0) )>
	</cfif>

	<cfset under.setColorFill(textColorBrown)>
	<cfset under.showTextAligned(under.ALIGN_RIGHT, 'Program Description:'& ' ', javacast("float", LeftSideData_X),  javacast("float", Data_Row2_Y),   javacast("float", 0) )>

	<!--- RIGHT SIDE DISPLAY - Entry 2 --->
	<cfset under.setColorFill(textColorBlack)>
	<cfset under.showTextAligned(under.ALIGN_LEFT, templateNamePart1, javacast("float", RightSideData_X),  javacast("float", Data_Row2_Y),   javacast("float", 0) )>

	<cfif Len(templateNamePart2) GT 0>
		<cfset under.showTextAligned(under.ALIGN_LEFT, templateNamePart2, javacast("float", RightSideData_X),  javacast("float", Data_Row3_Y),   javacast("float", 0) )>
	</cfif>
	<cfif Len(templateNamePart3)>  <!---32417--->
		<cfset under.showTextAligned(under.ALIGN_LEFT, templateNamePart3, javacast("float", RightSideData_X),  javacast("float", Data_Row4_Y),   javacast("float", 0) )>
	</cfif>

	<cfset under.setColorFill(textColorBrown)>
	<cfset under.showTextAligned(under.ALIGN_RIGHT, 'Program Type:'& ' ', javacast("float", RightSideData_X),  javacast("float", Data_Row2_Y),   javacast("float", 0) )>

	<!---32417 - determine rows for legacy ID, LeftSideData* based on program title length--->
	<cfscript>
		if ( Len(programTitlePart3) or len(thisTag.stPDFIntroInfo.legacy_deal_id) gt 35 ) {              // program title requires 3 lines
			rows.legacyID       = Data_Row5_Y;
			rows.LeftSideData_1 = Data_Row6_Y;
			rows.LeftSideData_2 = Data_Row7_Y;
			rows.LeftSideData_3 = Data_Row8_Y;
		}
	  else if ( Len(programTitlePart2) ) {               // program title requires 2 lines
			rows.legacyID       = Data_Row4_Y;
			rows.LeftSideData_1 = Data_Row5_Y;
			rows.LeftSideData_2 = Data_Row6_Y;
			rows.LeftSideData_3 = Data_Row7_Y;
		}
	  else {                                             // program title requires 1 line
			rows.legacyID       = Data_Row3_Y;
			rows.LeftSideData_1 = Data_Row4_Y;
			rows.LeftSideData_2 = Data_Row5_Y;
			rows.LeftSideData_3 = Data_Row6_Y;
	  }

	 /* 37669 - determine rows for Today's date, RightSideData* based on template name length */

	  if ( Len(templateNamePart3) ) {                    // template name requires 3 lines
			rows.TodaysDate      = Data_Row5_Y;
			rows.RightSideData_1 = Data_Row6_Y;
			rows.RightSideData_2 = Data_Row7_Y;
			rows.RightSideData_3 = Data_Row8_Y;
		}
	  else if ( Len(templateNamePart2) ) {               // template name requires 2 lines
			rows.TodaysDate      = Data_Row4_Y;
			rows.RightSideData_1 = Data_Row5_Y;
			rows.RightSideData_2 = Data_Row6_Y;
			rows.RightSideData_3 = Data_Row7_Y;
		}
	  else {                                             // template name requires 1 line
			rows.TodaysDate      = Data_Row3_Y;
			rows.RightSideData_1 = Data_Row4_Y;
			rows.RightSideData_2 = Data_Row5_Y;
			rows.RightSideData_3 = Data_Row6_Y;
	  }
	</cfscript>

	<!--- LEFT SIDE DISPLAY - Entry 3 --->
	<cfset under.setColorFill(textColorBlack)>
	<cfset under.showTextAligned(under.ALIGN_LEFT, thisTag.stPDFIntroInfo.legacy_deal_id, javacast("float", LeftSideData_X),  javacast("float", rows.legacyID),   javacast("float", 0) )>
	<cfset under.setColorFill(textColorBrown)>
	<cfset under.showTextAligned(under.ALIGN_RIGHT, thisTag.stPDFIntroInfo.legacyIDLabel & ':' & ' ', javacast("float", LeftSideData_X),  javacast("float", rows.legacyID),   javacast("float", 0) )>

	<!--- RIGHT SIDE DISPLAY - Entry 3 --->
	<cfset under.setColorFill(textColorBlack)>
	<cfset under.showTextAligned(under.ALIGN_LEFT, DateFormat(now(),"MM/DD/YYYY"), javacast("float", RightSideData_X),  javacast("float", rows.TodaysDate),   javacast("float", 0) )>

	<cfset under.setColorFill(textColorBrown)>
	<cfset under.showTextAligned(under.ALIGN_RIGHT, 'Today''s Date:' & ' ', javacast("float", RightSideData_X),  javacast("float", rows.TodaysDate),   javacast("float", 0) )>

	<!--- LEFT SIDE DISPLAY - OTHER ENTRIES WHICH SHOW OR HIDE BASED ON TEMPLATE SETTING --->
	<cfif LeftSideDataInclude eq 1 OR LeftSideDataInclude eq 2 OR LeftSideDataInclude eq 3 OR LeftSideDataInclude eq 4 OR LeftSideDataInclude eq 5
		OR LeftSideDataInclude eq 6 OR LeftSideDataInclude eq 7>

		<cfset under.setColorFill(textColorBlack)>
		<cfset under.showTextAligned(under.ALIGN_LEFT, LeftSideData_1, javacast("float", LeftSideData_X),  javacast("float", rows.LeftSideData_1),   javacast("float", 0) )>

		<cfset under.setColorFill(textColorBrown)>
		<cfset under.showTextAligned(under.ALIGN_RIGHT, LeftSideDataLabel_1, javacast("float", LeftSideData_X),  javacast("float", rows.LeftSideData_1),   javacast("float", 0) )>

		<!--- When at least two entries need to be shown --->
		<cfif  LeftSideDataInclude eq 1 OR LeftSideDataInclude eq 2 OR LeftSideDataInclude eq 3 OR LeftSideDataInclude eq 4>

			<cfset under.setColorFill(textColorBlack)>
			<cfset under.showTextAligned(under.ALIGN_LEFT, LeftSideData_2, javacast("float", LeftSideData_X),  javacast("float", rows.LeftSideData_2),   javacast("float", 0) )>

			<cfset under.setColorFill(textColorBrown)>
			<cfset under.showTextAligned(under.ALIGN_RIGHT, LeftSideDataLabel_2, javacast("float", LeftSideData_X),  javacast("float", rows.LeftSideData_2),   javacast("float", 0) )>
		</cfif>

		<!--- When all the three entries need to be shown --->
		<cfif LeftSideDataInclude eq 1>
			<cfset under.setColorFill(textColorBlack)>
			<cfset under.showTextAligned(under.ALIGN_LEFT, LeftSideData_3, javacast("float", LeftSideData_X),  javacast("float", rows.LeftSideData_3),   javacast("float", 0) )>

			<cfset under.setColorFill(textColorBrown)>
			<cfset under.showTextAligned(under.ALIGN_RIGHT, LeftSideDataLabel_3, javacast("float", LeftSideData_X),  javacast("float", rows.LeftSideData_3),   javacast("float", 0) )>
		</cfif>

	</cfif>

	<!--- RIGHT SIDE DISPLAY - OTHER ENTRIES WHICH SHOW OR HIDE BASED ON TEMPLATE SETTING --->
	<cfif RightSideDataInclude eq 1 OR RightSideDataInclude eq 2 OR RightSideDataInclude eq 3 OR RightSideDataInclude eq 4 OR RightSideDataInclude eq 5
		OR RightSideDataInclude eq 6 OR RightSideDataInclude eq 7>

		<cfset under.setColorFill(textColorBlack)>
		<cfset under.showTextAligned(under.ALIGN_LEFT, RightSideData_1, javacast("float", RightSideData_X),  javacast("float", rows.RightSideData_1),   javacast("float", 0) )>

		<cfset under.setColorFill(textColorBrown)>
		<cfset under.showTextAligned(under.ALIGN_RIGHT, RightSideDataLabel_1, javacast("float", RightSideData_X),  javacast("float", rows.RightSideData_1),   javacast("float", 0) )>

		<!--- When at least two entries need to be shown --->
		<cfif RightSideDataInclude eq 1 OR RightSideDataInclude eq 2 OR RightSideDataInclude eq 3 OR RightSideDataInclude eq 4>
			<cfset under.setColorFill(textColorBlack)>
			<cfset under.showTextAligned(under.ALIGN_LEFT, RightSideData_2, javacast("float", RightSideData_X),  javacast("float", rows.RightSideData_2),   javacast("float", 0) )>

			<cfset under.setColorFill(textColorBrown)>
			<cfset under.showTextAligned(under.ALIGN_RIGHT, RightSideDataLabel_2, javacast("float", RightSideData_X),  javacast("float", rows.RightSideData_2),   javacast("float", 0) )>
		</cfif>

		<!--- When all the three entries need to be shown --->
		<cfif RightSideDataInclude eq 1>
			<cfset under.setColorFill(textColorBlack)>
			<cfset under.showTextAligned(under.ALIGN_LEFT, RightSideData_3, javacast("float", RightSideData_X),  javacast("float", rows.RightSideData_3),   javacast("float", 0) )>

			<cfset under.setColorFill(textColorBrown)>
			<cfset under.showTextAligned(under.ALIGN_RIGHT, RightSideDataLabel_3, javacast("float", RightSideData_X),  javacast("float", rows.RightSideData_3),   javacast("float", 0) )>
		</cfif>
	</cfif>

	<!--- FOOTER (shows the page number under a horozontal line) --->
	<cfset under.setColorFill(textColorBlack)>

	<!--- There is no easy way to add a "Horizontal line" to the footer.--->
	<cfset under.showTextAligned(under.ALIGN_LEFT, "_______________________________________________________________________________________________________________________________________________________", javacast("float", 40),  javacast("float", 22),   javacast("float", 0) )>
	<!--- Page Number --->
	<cfset under.showTextAligned(under.ALIGN_CENTER, i & " of " & totalPages, javacast("float", 550),  javacast("float", 10),   javacast("float", 0) )>

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
