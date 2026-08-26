<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<cfparam name="currObj" 			default="" >
<cfparam name="url.textareadata"	default="">
<cfparam name="url.productGroupLevelTypes" default="">
<cfparam name="url.programID" default = "">
<cfparam name="url.CID" default = "">               <!--- french translation --->
<cfparam name="url.labelSetDefault" default="">
<cfparam name="varProductGroupLevelTypes" default="">
<cfparam name="varprogramID" default="">


<cfif isDefined("url.productGroupLevelTypes") AND url.productGroupLevelTypes NEQ "">
	<cfset varProductGroupLevelTypes = url.productGroupLevelTypes />
</cfif>
<cfif isDefined("url.programID") AND url.programID NEQ "">
	<cfset varprogramID = url.programID />
</cfif>

<cfif isDefined("url.passObj") and url.passObj NEQ "">
	<cfset currObj = trim(url.passObj) >
</cfif>

<CFSET objHandle = CreateObject("component", "components.general.Create_List")>

<html>
<head>
	<title><cfoutput>#objHandle.getListTitle(currObj)#</cfoutput></title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<script>
	/* Dev Note: (71334) - The issue is that when "Modal window" is used in a frameset, IE 11 ignores the
	width and the height of the modal window. Below function is used to fix thst issue.
	*/
		(function () {
			var _b = document.createElement('body');
			var _doc = document.documentElement;
			_doc.insertBefore(_b, _doc.firstChild );
			_doc.removeChild(_b);
		})();
	</script>
</head>
<cfset divHeight = 375 >
<cfset divWidth = 400 >
<!--- use session variable holding the passing objects (used by createListForm)--->
<!--- <cfset session.passObj = url.passObj >
<cfset session.passForm = url.passForm >
<cfset session.textareadata = url.textareadata > --->
<!--- new method to pass to the new form --->
<cfoutput>
<frameset rows="100%,0%">
	<frame src="createListForm.cfm?textareadata=#url.textareadata#&passForm=#url.passForm#&passObj=#url.passObj#&productGroupLevelTypes=#varProductGroupLevelTypes#&CID=#url.CID#&programID=#url.programID#" name="ifmCreateList" id="ifmCreateList">
	<!--- <frame src="createListForm.cfm" name="frameCreateList1" id="frameCreateList1">  --->
</frameset>
<noframes></noframes>
</cfoutput>
</html>




