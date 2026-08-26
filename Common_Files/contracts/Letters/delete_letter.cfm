<cfsilent>
<!--- 
FILE: 		
FILENAME: 	Common_Files/contracts/Letters/delete_letter.cfm
CREATED: 	09/05/2008 - RBL
EDITED:		10/29/2008 - RBL [D17386]

FUNCTIONALITY:
- This action page facilitates requests from user to 1 letter...
--->

<!--- These parameters are required for this template to process correctly --->
<cfparam name="url.bAll"		type="boolean"	default="0">
<cfparam name="url.CID" 		type="string" 	default="">
<cfparam name="url.LID" 		type="numeric" 	default="0">

</cfsilent>

<!--- MVC V11 Edit [begin] --->
<cfscript>
 application.oController.getObject("mvc.Models.LetterManager");
</cfscript>
<!--- MVC V11 Edit [end] --->

<cfinclude template="include_display_letters.cfm">

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::> DELETE LETTER(s) [begin] <:::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cfif url.bAll>
	<cfscript>
		application.oLetterManager.deleteAllProgramPDFLettersInDBandFile(url.CID);
	</cfscript>
    <cfoutput>
    	<!--- will be redirected... --->
        <div align="center" onClick="javascript:ColdFusion.Window.hide('pdfDeletion')" style="background-color:##eeeeee;height:100%;width:100%;">
        <font size="1" color="Black"><b>All Deleted!</b></font>&nbsp;<font size="1" color="Red">[</font> &nbsp;<font size="1" color="Blue"><a href="#includeLettersFilename#?CID=#url.CID#">Create New Program Letters</a></font>&nbsp;<font size="1" color="Red">]</font>
        </div>
    </cfoutput>
<cfelse>
	<cfscript>
		application.oLetterManager.deletePDFLetterInDBandFile(url.LID);
	</cfscript>
    <cfoutput>
        <div align="center" onClick="javascript:ColdFusion.Window.hide('pdfDeletion')" style="background-color:##eeeeee;height:100%;width:100%;">
        <font size="1" color="Black"><b>Deleted!</b></font>&nbsp;<font size="1" color="Red">[</font> &nbsp;<font size="1" color="Blue"><a href="#includeLettersFilename#?CID=#url.CID#">View Remaining <!--- #url.CMID# --->Program Letters</a></font>&nbsp;<font size="1" color="Red">]</font>
        </div>
    </cfoutput>
</cfif>
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::> DELETE LETTER(s) [end] <:::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->