<!---
***********************************************************************
Author: Milan Mushran
Filename: file_upload.cfm
Purpose: Unzips the file to the root directory.The file details 
				(file name/file path etc) of any web file (cfm/js/css/gif etc) 
				are entered in the sql script and this patch system updates those 
				entries with the name of the Installer and the date of Installation.
Date Created: 10/04/2006
Modification: Account for modification of Read-only files
Modified By: Milan Mushran
Modified Date: 10/20/2006
Modification:
Modified By:
Modified Date:
***********************************************************************
--->

<!--- If a file other than a zip, is being uploaded --->
<cfif LCase(Right(Form.UploadFrom, 3)) neq 'zip'>
	<cflocation url="file_upload.cfm?error=filetype">
</cfif>

<cfset CFScriptFunctions = CreateObject("component", "components.general.CFScript_Functions") />

	<CFQUERY NAME="getBuildInfo" datasource="#application.datasource#">
		SELECT TOP 1 * 
		FROM Application_Installation
		WHERE Installed_Date IS NULL
	</CFQUERY>

	<CFQUERY NAME="getName" datasource="#application.datasource#">
		SELECT Name_First + ' ' + Name_Last As Name
		FROM _Users
		WHERE User_ID = '#request.AccessStructure.user_id#'
	</CFQUERY>

	<cfset Name = getName.Name>

	<cfif getBuildInfo.Recordcount eq 0>
			<cflocation url="file_upload.cfm?error=nodata">
	</cfif>

<CFFILE ACTION="Upload" 
   FILEFIELD="FileName" 
   DESTINATION="#FileSavePath#"
   NAMECONFLICT="Overwrite">

<cfscript>
/**
 * Unzips a file to the specified directory.
 * @param zipFilePath 	 Path to the zip file (Required)
 * @param outputPath 	 Path where the unzipped file(s) should go (Required)
**/
function unzipFile(zipFilePath, outputPath) {
	var zipFile = ""; // ZipFile
	var entries = ""; // Enumeration of ZipEntry
	var entry = ""; // ZipEntry
	var fil = ""; //File
	var inStream = "";
	var filOutStream = "";
	var bufOutStream = "";
	var nm = "";
	var pth = "";
	var lenPth = "";
	var buffer = "";
	var l = 0;
	var count = 0;
  var LastPercent = 0;
	var PercentDone = 0;
	var Block ="";  
	var x=1;
	var filepth = "";
	var File_Exist = 0;

	zipFile = createObject("java", "java.util.zip.ZipFile");
	zipFile.init(zipFilePath);
	
	entries = zipFile.entries();

	if(ZipFile.Size() gte 10){
	WriteOutput("<TABLE BORDER=1 BORDERCOLOR=00000000 CELLPADDING=0 CELLSPACING=0 align='CENTER'><TR><TD><TABLE WIDTH=100 CELLPADDING=1 CELLSPACING=1 BORDER=0><TR><TD><B>Progress:</B></TD>");
	while(x LTE 10)
	{
	WriteOutput("<TD><IMG SRC='' NAME='Block#X#' WIDTH=10 HEIGHT=15 TITLE='Progress Bar'></TD>");	
		x = x + 1;
	}
	WriteOutput("</TR></TABLE></TD></TR></TABLE><P>");
	CFScriptFunctions.flush();

	WriteOutput(#RepeatString(" ",125)#);

	CFScriptFunctions.flush();
	}
	while(entries.hasMoreElements()) {
		entry = entries.nextElement();
			count = count + 1;

			if(NOT entry.isDirectory()) 
			{
					nm = entry.getName(); 
					
					lenPth = len(nm) - len(getFileFromPath(nm));
					
					if (lenPth) {
					pth = outputPath & left(nm, lenPth);
					} else {
					pth = outputPath;
					}

					if (NOT directoryExists(pth)) {
					fil = createObject("java", "java.io.File");
					fil.init(pth);
					fil.mkdirs();
					}
					filOutStream = createObject(
					"java", 
					"java.io.FileOutputStream");
					/*  Get the absolute file path */
					filepth = outputPath & "/" & nm;

					File_Exist = CFScriptFunctions.DoesFileExist("#filepth#");

					/*  If the file exists and the file is read-only, then rename it to the same name, 
							and change the property of the file to 'normal' */
					if(File_Exist eq 1 AND not FileCanWrite(filepth))
					{
							CFScriptFunctions.fileRename(filepth,filepth, 'Normal');
					}

					filOutStream.init(outputPath & nm);
				
				bufOutStream = createObject(
					"java", 
					"java.io.BufferedOutputStream");
				
				bufOutStream.init(filOutStream);
				
				inStream = zipFile.getInputStream(entry);
				buffer = repeatString(" ",1024).getBytes(); 
				
				l = inStream.read(buffer);
				while(l GTE 0) {
					bufOutStream.write(buffer, 0, l);
					l = inStream.read(buffer);
				}
				inStream.close();
				bufOutStream.close();
		}
		
	PercentDone = Int(Ceiling(Count/Zipfile.Size() * 100)/10);
		/* Do not remove the line below. It could be used for debugging purpose */
		/* WriteOutput("<script>alert(#Zipfile.Size()#)</script>"); */
		if(LastPercent neq PercentDone and Zipfile.Size() gte 10) // Show the Image only for Zip files having at least 10 files
		{
			Block = "Block" & PercentDone;
			WriteOutput("<script>document.#Block#.src = '/images/xm_1.gif';</script>");
			CFScriptFunctions.flush();
			LastPercent = PercentDone;	
		}

	}
		zipFile.close();
		/* Successful upload. Go back to the upload page */
		WriteOutput("<script>window.location = 'file_upload.cfm?error=success'</script>");
}

function FileCanWrite(filename){
	_File = createObject('java', 'java.io.File');
	_File.init(JavaCast('string', filename));
		return _File.canWrite();
}

</cfscript>
<!--- The upload path (FileSavePath) should have a trailing slash. It should be uploaded from a zip file
	  uploaded to the root folder. The zip file is deleted from the root folder after the unzip operation --->
<cfset UploadFileName = Right(UploadFrom, Find("\", Reverse(UploadFrom)))>
<cfset Unzip = unzipFile("#FileSavePath##UploadFileName#","#FileSavePath#")>


<cffile action = "delete" file="#FileSavePath##UploadFileName#">

<CFQUERY NAME="SaveUserInfo" datasource="#application.datasource#">
	UPDATE Application_Installation 
	SET Name = '#Name#',
	Installed_Date = getdate(), 
	CF_Installation = 1
	WHERE Installed_Date IS NULL
</CFQUERY>