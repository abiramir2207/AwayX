<!-----------------------------------------------------------------------------

FILE NAME:		createList.cfm
DESCRIPTION:	Used for create list functionality inside the Add group functionality 
				in Planning groups
CREATED BY:		???
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	20-Nov-2014	

------------------------------------------------------------------------------> 

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<cfparam name="currObj" 			default="" >
<cfparam name="url.textareadata"	default="">
<cfparam name="url.GroupLevelID" default="">
<cfparam name="url.programID" default = "">
<cfparam name="varGroupLevelID" default="">
<cfparam name="varprogramID" default="">

<cfif isDefined("url.GroupLevelID") AND url.GroupLevelID NEQ "">
	<cfset varGroupLevelID = url.GroupLevelID />
</cfif>

<cfif isDefined("url.passObj") and url.passObj NEQ "">
	<cfset currObj = trim(url.passObj) >
</cfif>

<CFSET objHandle = CreateObject("component", "components.general.Create_List")>

<html>
<head>
	<title><cfoutput>#objHandle.getListTitle(currObj)#</cfoutput></title>
	<meta http-equiv="x-ua-compatible" content="IE=6">
</head>
<cfset divHeight = 375 >
<cfset divWidth = 400 >
 
<!--- new method to pass to the new form --->
<cfoutput>
<frameset rows="100%,0%">
	<frame src="createListForm.cfm?textareadata=#url.textareadata#&passForm=#url.passForm#&passObj=#url.passObj#&GroupLevelID=#varGroupLevelID#" name="ifmCreateList" id="ifmCreateList"> 
</frameset><noframes></noframes>
</cfoutput>
</html>




