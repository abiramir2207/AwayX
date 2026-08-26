<!--- 
	This is the directory to use for uploaded language files.  The function below looks in this 
	directory and grabs the latest file to read.  It then proceeds to check to see if each item
	exists before it tries to add the record.  If it does not exist, it adds the record.  If it
	already exists then it will not add a duplicate.
	
	AwayX\common_documents\Data_Files\Uploaded\settings\LanguageFiles 
	
 --->

<!--- INSTANTIATE THE OBJECT --->
<cfif not isDefined("request.qLabels")>
	<cfset request.qLabels = createObject("component", "components.settings.Labels.Labels").init()>
</cfif>

<!--- RUN THE READ FILE FUNCTION TO READ THE LATEST FILE --->
<cfset request.qLabels.ReadLangFile()>