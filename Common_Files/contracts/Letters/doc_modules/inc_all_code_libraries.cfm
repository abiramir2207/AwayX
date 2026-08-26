<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/inc_all_code_libraries.cfm
CREATED: 		08/16/2010 - Milan [Convert to Itext in Java]
EDITED:			09/15/2010 - Milan [Delete letters with "temp" prefix]
FUNCTIONALITY:
- This is file which includes the JAVA Itext libraries.
--->
</cfsilent>

	<cfparam name="DoNotIncludeThis" default="0">

	<!--- Create a writer that listens to the document and directs a PDF-stream to a file --->
	<cfset PdfWriter = createObject("java", "com.lowagie.text.pdf.PdfWriter")> 
	<cfset PdfReader = createObject("java", "com.lowagie.text.pdf.PdfReader")>
	<cfset FileOutputStream = createObject("java", "java.io.FileOutputStream")>

	<!--- Java File Library --->
	<cfset objFile = CreateObject("java", "java.io.File")>
 
 <!--- When called from inside a function in a CFC, I have to include this file inside that function, 
			 and do not to reinitialize this code again. Currently, it is being incuded in "ProgramVolume.cfc
 --->
<cfif DoNotIncludeThis eq 0>
	
	<cfset pathToOutputFile = thisTag.pdf_file_path>

	<!--- Get the parent folder of the pdf file path --->
	<cfset folderInstance = objFile.init('#pathToOutputFile#').getParent() />

	<!--- Instantiate the parent path --->
	<cfset folderInstance = objFile.init('#folderInstance#') />

	<!--- Get the list of files in the parent folder --->
	<cfset ListOfFiles = folderInstance.listFiles()>

	<!--- If there are any pdf files with "temp_1" or "temp_2" appended to it, then just delete those files. These are 
				temporary files used in the letter generation process.
	--->
	<cfif IsDefined("ListOfFiles")>
		<cfloop from="1" to="#ArrayLen(ListOfFiles)#" index="i">
				<cfif Find("_temp_1.pdf",ListOfFiles[i]) neq 0 OR Find("_temp_2.pdf",ListOfFiles[i] neq 0)>
					<cfset fileInstance = objFile.init('#ListOfFiles[i].getPath()#') />
					<cfset fileInstance.Delete() />
				</cfif>
		</cfloop>
	</cfif>
		
			<!--- creation of a document-object --->
			<cfset document = createObject("java", "com.lowagie.text.Document").init()>
			<!--- (Start) - This writes an empty pdf file to the hard drive --->
			<cfset outStream = FileOutputStream.init( pathToOutputFile )>
			<!--- (End) - This writes an empty pdf file to the hard drive --->
			<cfset writer = PdfWriter.getInstance(document, outStream)> 
			<cfset document.open()>  
			<!--- Left,Right,Top,Bottom --->
			<cfset document.setMargins(35,35,75,30)>
	</cfif>

	<!--- Font Libraries --->
	<cfset BaseFont = createObject("java", "com.lowagie.text.pdf.BaseFont")>
	<cfset font = createObject("java", "com.lowagie.text.Font")>

	<!--- "Gothic" fonts do not exits on IText. We need to use the ones available in windows --->     
	<cfset Gothic_Normal = BaseFont.createFont("#ExpandPath('\common_files\contracts\Letters\doc_modules\fonts\Gothic.TTF')#",BaseFont.WINANSI, BaseFont.EMBEDDED)>   
	<cfset Gothic_Bold = BaseFont.createFont("#ExpandPath('\common_files\contracts\Letters\doc_modules\fonts\GothicB.TTF')#", BaseFont.IDENTITY_H, BaseFont.EMBEDDED)>

	<!--- Table Libraries --->
	<cfset PdfPTable = createObject("java", "com.lowagie.text.pdf.PdfPTable")> 
	<cfset PdfPCell = createObject("java", "com.lowagie.text.pdf.PdfPCell")>

 	<!--- Writing data Libraries --->
	<cfset chunk = createObject("java", "com.lowagie.text.Chunk")>
	<cfset phrase = createObject("java", "com.lowagie.text.Phrase")>	
	<cfset StringReader = createObject("java", "java.io.StringReader")>
	<cfset HTMLWorker = createObject("java", "com.lowagie.text.html.simpleparser.HTMLWorker")>
	<cfset StyleSheet = createObject("java", "com.lowagie.text.html.simpleparser.StyleSheet")>

	<!--- Miscellaneous Libraries --->			
	<cfset Element = createObject("java", "com.lowagie.text.Element")>
	<cfset anchor = createObject("java", "com.lowagie.text.Anchor")>
	<cfset color = createObject("java", "java.awt.Color")>
	<cfset Image = createobject("java", "com.lowagie.text.Image")> 
	<cfset Rectangle = createObject("java", "com.lowagie.text.Rectangle")>

	<!--- CF Arrays start from 1, but in Java it starts from 0. We need the Array and 
				Integer Library for that purpose 
	--->
	<!--- Array Library --->
	<cfset arrObj = createobject("java", "java.lang.reflect.Array")> 

	<!--- Integer Library --->
	<cfset jClass = createobject("java", "java.lang.Integer").TYPE>

	<!--- Set the different colors --->
	<cfset textColorBlack = color.decode("##000000")>
	<cfset textColorBlue = color.decode("##0000FF")>
	<cfset textColorBrown = color.decode("##990000")> 
	<cfset textColorWhite = color.decode("##ffffff")>
	<cfset textColorLightGray = color.decode("##eeeeee")>

	<!--- Naming convention of the font variables is as follows: 
					--	FontName_"Font"_FontType_FontColor_FontSize	
	--->
	<!--- "Font function" accepts 3 arguments - font type, size and color --->
	<!--- GOTHIC FONT --->
	<cfset GothicNormal_Font_Bold_Black_Eight = font.init(Gothic_Normal, javacast("int",8), font.BOLD, textColorBlack)>

	<!--- GOTHICBOLD FONT --->
	<cfset GothicBold_Font_Normal_Black_Seven = font.init(Gothic_Bold, javacast("int",7), font.NORMAL, textColorBlack)>
	<cfset GothicBold_Font_Normal_Black_Eight = font.init(Gothic_Bold, javacast("int",8), font.NORMAL, textColorBlack)>

	<cfset GothicBold_Font_Italic_Black_Seven = font.init(Gothic_Bold, javacast("int",7), font.ITALIC, textColorBlack)>
	<cfset GothicBold_Font_Italic_Black_Eight = font.init(Gothic_Bold, javacast("int",8), font.ITALIC, textColorBlack)>
	
	<!--- Get the font in bold for GOTHICBOLD FONT. Makes it a lot BOLD. --->
	<cfset GothicBold_Font_Bold_Black_Seven = font.init(Gothic_Bold, javacast("int",7), font.BOLD, textColorBlack)>
	<cfset GothicBold_Font_Bold_Black_Eight = font.init(Gothic_Bold, javacast("int",8), font.BOLD, textColorBlack)>

	<cfset GothicBold_Font_Normal_Blue_Seven = font.init(Gothic_Bold, javacast("int",7), font.NORMAL, textColorBlue)>
	<cfset GothicBold_Font_Normal_Blue_Eight = font.init(Gothic_Bold, javacast("int",8), font.NORMAL, textColorBlue)>

	<cfset GothicBold_Font_Bold_Brown_Seven = font.init(Gothic_Bold, javacast("int",7), font.NORMAL, textColorBrown)>
	<cfset GothicBold_Font_Bold_Brown_Eight = font.init(Gothic_Bold, javacast("int",8), font.NORMAL, textColorBrown)>
	<cfset GothicBold_Font_Bold_Brown_Nine = font.init(Gothic_Bold, javacast("int",9), font.NORMAL, textColorBrown)>

	<!--- Unused Libraries --->
	<!---
	<cfset FontFactory = createObject("java", "com.lowagie.text.FontFactory")>
	<cfset Paragraph = createObject("java", "com.lowagie.text.Paragraph")>
	<cfset PageSize = createObject("java", "com.lowagie.text.PageSize")> 
	<cfset HeaderFooter = createObject("java", "com.lowagie.text.HeaderFooter")>
	<cfset ColumnText = createObject("java", "com.lowagie.text.pdf.ColumnText")>
	<cfset MultiColumnText = createObject("java", "com.lowagie.text.pdf.MultiColumnText")>
	<cfset StringBuffer = createobject("java", "java.lang.StringBuffer")>
	<cfset PdfTextExtractor = createobject("java", "com.lowagie.text.pdf.parser.PdfTextExtractor")>
	<cfset VerticalPositionMark = createObject("java", "com.lowagie.text.pdf.draw.VerticalPositionMark")>
	<cfset Graphic1 = createObject("java", "com.lowagie.text.Graphic")>
	--->