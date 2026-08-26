<!-----------------------------------------------------------------------------

FILE NAME:		AliasFixerMain.cfm
DESCRIPTION:	This is the landing screen for the user when they encounter an 
				issue with the uploaded file and need to fix the Aliases which 
				calls the AliasFixer.cfm file from the frames inside.
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	08-Jul-2014	Added check number and 
							 

------------------------------------------------------------------------------> 

<CFSET objHandle = CreateObject("component", "components.general.Create_List")>
<cfparam name="URL.UploadID" default="0">
<cfset Upload_ID = URL.UploadID />
<html>
<head>
	<title><cfoutput>Alias Fixer</cfoutput></title>
	<meta http-equiv="x-ua-compatible" content="IE=6">
</head>
<cfset divHeight = 375 >
<cfset divWidth = 400 >
<!--- new method to pass to the new form --->
<cfoutput>
 
<frameset rows="100%,0%">
	<frame src="AliasFixer.cfm?UploadID=#Upload_ID#" name="ifmCreateList" id="ifmCreateList"> 
	<!--- <frame src="createListForm.cfm" name="frameCreateList1" id="frameCreateList1">  --->
</frameset><noframes></noframes>
 
</cfoutput>
</html>




