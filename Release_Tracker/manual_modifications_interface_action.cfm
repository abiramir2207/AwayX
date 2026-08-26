		<!---
		***********************************************************************
		Author: Milan Mushran
		Filename: manual_modifications_interface_action.cfm
		Purpose: Enters details of manual file changes to the DB.
		Date Created: 10/04/2006
		Modification: Now the users can add multiple file paths.
		Modified By: Milan Mushran
		Modified Date: 10/20/2006
		Modification: Add web services functionality
		Modified By: Milan Mushran
		Modified Date: 9/26/2007
		Modification:
		Modified By:
		Modified Date:
		***********************************************************************
		--->
		
<cfset Installed_Date = "#Start_Month#/#Start_Day#/#Start_Year# #Start_Hour#:#Start_Minute#:00 #AM_PM#">
	
<cfparam name="selClientList" default="">

<cfset Comments = Trim(Comments)>
<cfset File_Path = Trim(File_Path)>
<cfset Label_Number = Trim(Label_Number)>

<cfif Label_Number eq "">
	<cfset Label_Number = 'N/A'>
</cfif>

<!--- Insert the record in the appropriate client's instance using web service. The request is made from 
	   the developer's local machine --->
<cfif selClientList neq "">
	<cfset Web_Service_WSDL = "#selClientList#/components/webservices/RemoteReleaseTracker.cfc?wsdl">
	<cfset createObject("java", "coldfusion.server.ServiceFactory").XmlRpcService.refreshWebService("#Web_Service_WSDL#")>

<cfinvoke
		webservice="#Web_Service_WSDL#"
		method="InsertManualModifications"
		returnvariable="string">

	<cfinvokeargument name="File_Path_List" value="#file_path#">
	<cfinvokeargument name="Name" value="#Name#">
	<cfinvokeargument name="Installed_Date" value="#Installed_Date#">
	<cfinvokeargument name="Release_version" value="#Release_version#">
	<cfinvokeargument name="Label_Number" value="#Label_Number#">
	<cfinvokeargument name="Comments" value="#TRIM(form.comments)#">

</cfinvoke>

<cfelse>

<!--- If the user is using the client web site, no need for the web service --->
<cfinvoke
		component="components.webservices.ReleaseTracker"
		method="InsertManualModifications"
		returnvariable="string">

	<cfinvokeargument name="File_Path_List" value="#file_path#">
	<cfinvokeargument name="Name" value="#Name#">
	<cfinvokeargument name="Installed_Date" value="#Installed_Date#">
	<cfinvokeargument name="Release_version" value="#Release_version#">
	<cfinvokeargument name="Label_Number" value="#Label_Number#">
	<cfinvokeargument name="Comments" value="#TRIM(form.comments)#">
</cfinvoke>
</cfif>


<cflocation url="manual_modifications_interface.cfm?Success=1">