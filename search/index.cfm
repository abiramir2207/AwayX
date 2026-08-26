<!---
Filename:		index.cfm
Description:	This file is the parent include of the general search tool
Author:			Eduardo Vazquez
Date Created:	12/3/2001
--->

<!--- The purpose of this file is to act as a framework for easily creating search tools --->

<!--- GST: a scope for this page only --->

<!--- VARIABLES --->
<!--- 
	GST.DESTINATION_PAGE 		: location of the file to submit the results of the search selection if any, otherwise the location of the next page a process
	GST.ID						: a variable to hold an ID for any use later on in the process, maybe on the destination page
	GST_SELECTION_OPTION 		: tells the code to put select boxes,radio buttons or nothing next to each returned result
								OPTIONS:
									"CHECK" = checkbox
									"RADIO" = radio button 
									"NONE" = nothing
 	GST.RESULT_CODE_LOCATION	: the location of the code that returns the search reults
	GST.POPUP_CODE_LOCATION 	: this variable holds the name of the code within in the popup that is the search form,
								  it is has to be the name of the filename from "GST.RESULT_CODE_LOCATION" with popup appended to it
 --->
 

<!--- "initialize" variables --->
<CFSET gst = StructNew()>
<CFPARAM NAME="gst.destination_page" 		DEFAULT="">
<CFPARAM NAME="gst.id" 						DEFAULT="">
<CFPARAM NAME="GST_SELECTION_OPTION " 		DEFAULT="">
<CFPARAM NAME="gst.result_code_location" 	DEFAULT="">
<CFPARAM NAME="gst.popup_code_location" 	DEFAULT="">


<!--- convert all the supplied variables to lowercase --->
<CFLOOP INDEX="VariableName" LIST="#structkeylist(gst)#" DELIMITERS=",">
	<CFSET temp = StructUpdate(gst, VariableName, lcase(evaluate("gst.#VariableName#")))>
	<CFOUTPUT>#VariableName#</CFOUTPUT><BR>
	
</CFLOOP>

	<CFOUTPUT>#gst.destination_page#</CFOUTPUT>

