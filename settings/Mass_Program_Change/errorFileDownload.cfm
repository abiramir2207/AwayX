<!--- 
	Writing query to a XLS file. 
	User might have fixed some of the data in the grid; 
	Get latest data from the table and write to the same file 
--->

<!--- Initiate the CFC --->
<cfset MPCUManager = createObject("component","mvc.Models.Program.Upload.MassProgramChange") />

<!--- query the data for file --->
<cfset fileData = MPCUManager.getDataForFile() />

<!--- loop through directory to get the list of files, for download link --->
<cfdirectory name="recentUpload" action="list" type="file" 
			directory="#Application.Doc_Path#\Data_Files\Uploaded\programs" 
			listinfo="name" sort="datelastmodified DESC" filter="*.xls?">

<!--- get the most recent filename --->
<cfset recentFileName = recentUpload.name />


<cfif recentFileName neq "">

	<!--- path and file name of the file to write the data to --->
	<cfset pathFileName = "#Application.Doc_Path#\Data_Files\Uploaded\programs\" & recentFileName />

	<!--- Write the string buffer to the file, convert to String ---->
	<cfspreadsheet action="write" filename="#pathFileName#" query="fileData" overwrite="true">

	<!--- download link --->
	<cfheader name="Content-Disposition" value="attachment;filename=#recentFileName#"  />
	<cfcontent type="application/vnd.ms-excel" file="#pathFileName#" deletefile="no"  />

<cfelse>
<div style="color:red;font-weight:bold;text-align:center;">
There is not file to download. Please upload a file first. If there is an error, then a file can be downloaded with the errors listed.

<p><a href="index.cfm">Go Back</a></p>
</div>
</cfif>
