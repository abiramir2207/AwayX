<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/inc_all_clauses.cfm
CREATED: 	12/19/2007 - RBL
EDITED:		08/18/2008 - RBL [<cfif NOT findNoCase("doc_modules_edit_form",cgi.script_name,1)>]
EDITED:		08/16/2010 - Milan [Convert to Itext in Java]
EDITED:		09/15/2010 - Milan [Add template setting to show/hide info on the letter]
EDITED:		10/1/2010 - Milan [Change the regular expression for Clauses]

FUNCTIONALITY:
- This include template generates the "Clause" module for all versionS of the Deal Letters v2...
--->

<!--- These parameters are required for this template to process correctly --->
<!--- na --->
</cfsilent>

<cfparam name="ShowHTML" default="0">

<!--- Show Itext output --->
<cfif ShowHTML eq 0>

	<cfif thisTag.qProgramClause.recordCount>

	<!--- If template setting "BA Pre-defined page breaks" is ON, Go to a new page for fixed price --->
	<cfif thisTag.stPDFBodyInfo.bPreDefinedPageBreaks>				
		<cfset document.newPage()>	
	<cfelse>
		<cfset document.add(chunk.init(chr(13) & chr(10)))>
	</cfif>

	<cfset document.add(phrase.init("Terms and Conditions", GothicBold_Font_Bold_Brown_Nine))>

		<cfoutput query="thisTag.qProgramClause">
				<!--- Initialize the style sheet. I tried a few techinques to use the style sheet for font size,
							font face etc, but it did not work.
				--->
				<cfset style_sheet = StyleSheet.init()>

				<!--- (START) Let's clean it up before we dish it up to the user. This is the same clean up code Brad used
				for the first phase of the letters project using CFDOCUMENT - Check the condition (ShowHTML = 1)
				--->
				<!---
				<cfset thisTag.current_clause = replaceNoCase(thisTag.qProgramClause.Clause_Library_Body,"<B>", "ABC1" , "ALL" )>
				<cfset thisTag.current_clause = replaceNoCase(thisTag.current_clause,"</B>", "ABC2" , "ALL" )>
				<cfset thisTag.current_clause = replaceNoCase(thisTag.current_clause,"</p>", "XYZ" , "ALL" )>
				--->
				
				<!--- remove ALL wickets... [begin] --->
				<!--- This was the original regex. I have commented it as it was not displaying HTML correctly. Whatever the expected 
				HTML format, the output was just display all the data line by line.
				---> 
				<!---<cfset thisTag.current_clause = ReReplaceNoCase(thisTag.current_clause,"<[^>]*(>|$)", "" , "ALL" )>--->
				<cfset thisTag.current_clause = ReReplaceNoCase(thisTag.qProgramClause.Clause_Library_Body,"</?(a|A).*?>", "" , "ALL" )>
				<!--- Remove the div tag. It was causing an extra line. It also had wierd HTML code inside it. --->
				<cfset thisTag.current_clause = ReReplaceNoCase(thisTag.current_clause,"</?(DIV|div).*?>", "" , "ALL" )>
				<!--- Remove the span tag. It had wierd HTML code inside it. --->
				<cfset thisTag.current_clause = ReReplaceNoCase(thisTag.current_clause,"</?(SPAN|span).*?>", "" , "ALL" )>
				<!--- Dev Note: Milan - 25338: "LINE-HEIGHT: normal" was an attribute inside the <LI> tag and was causing the characters to be on top of 
				each other making it a very dark line(s),the characters of which were incomprehensible. Notice that the replace function is not a regular 
				expression statement.
				--->
				<cfset thisTag.current_clause = ReplaceNoCase(thisTag.current_clause,"LINE-HEIGHT: normal", "" , "ALL" )>
				<!---remove ALL wickets... [end]--->
				<!---
				<cfset thisTag.current_clause = replaceNoCase(thisTag.current_clause,"ABC1", "<b>" , "ALL" )>
				<cfset thisTag.current_clause = replaceNoCase(thisTag.current_clause,"ABC2", "</b>" , "ALL" )>
				<cfset thisTag.current_clause = replaceNoCase(thisTag.current_clause,"XYZ", "<br>" , "ALL" )> 
				--->
				
				<!--- (END) Let's clean it up before we dish it up to the user. This is the same clean up code Brad used
				for the first phase of the letters project using CFDOCUMENT - Check the condition (ShowHTML = 1)
				--->

				<!--- Milan (24393) - Since the style sheet did not work, I am using straight HTML for <font>. "HTMLWorker" seems 
				to understand it.Leave a space before <html>. While I was testing this functionality, a space was needed.
				--->		
				<cfset thisTag.current_clause = StringReader.init(" <html><head></head><body><font size='1' face='Gothic_Bold'>" & thisTag.current_clause & "</font></body></html>")>

				<!--- "parseToList" function requires a "style sheet", even if just a blank one --->
				<CFSET HTMLElementArray = HTMLWorker.parseToList(thisTag.current_clause,style_sheet)>

				<!--- "HTMLElementArray" is of datatype Arraylist in java. Loop over the HTML element array. 
							 Note: Java has arrays starting from 0.
				--->
				<cfloop from="1" to="#HTMLElementArray.size()-1#" index="i">
							<cfset document.add(HTMLElementArray.get(i))>
				</cfloop>
		</cfoutput>
	</cfif>

<cfelse>
<!--- Show HTML Output--->

<!--- This duplicate css file must be here. --->
<cfinclude template="css/inc_all_style.cfm">
<table name="outer_table" width="100%" cellpadding="0" cellspacing="0">
  <tr>
      <td align="center" valign="top">
          <table name="inner_table" width="90%" cellpadding="0" cellspacing="0">
          <!--- page break [end] --->
              
              <!--- 5.) Conditions [begin] --->
              <tr name="row_8">
                  <td colspan="6">
                      <table name="nested_table" border="0" cellpadding="5" cellspacing="0" width="100%" class="thinTopBorder thinBottomBorder">
                      		<tr>
                            <td valign="middle" align="left" width="100%" colspan="3">
                              <br /><font></font><br />
                              <!--- leave header whether or not we have content... --->
                              <h3 class="redText">Terms and Conditions</h3>
                            </td>
                          </tr>

                          <cfif thisTag.qProgramClause.recordCount>
                          
                          	<!--- TESTING <cfdump var="#thisTag.qProgramClause.Clause_Library_Body[2]#" label="thisTag.qProgramClause[2]">
                            <cfdump var="#ReReplaceNoCase(thisTag.qProgramClause.Clause_Library_Body[2],"<[^>]*(>|$)", "" , "ALL" )#"  label="reReplace()[2]">
							<cfabort> --->
                          
                            <cfoutput query="thisTag.qProgramClause">
                            	<!--- bgcolor="#iIf(thisTag.qProgramClause.currentRow MOD 2, DE('ffffff'), DE('eeeeee'))#" --->
                              <tr>
                                <td valign="middle" align="left">
																	<!--- let's clean it up before we dish it up to the user...
                                  	by removing ALL HTML tags [wickets and attributes] with this cool RegEx... Then apply our own CSS class here --->
                                    <cfset thisTag.current_clause = replaceNoCase(thisTag.qProgramClause.Clause_Library_Body,"<B>", "ABC1" , "ALL" )>
																		<cfset thisTag.current_clause = replaceNoCase(thisTag.current_clause,"</B>", "ABC2" , "ALL" )>
                                    <cfset thisTag.current_clause = replaceNoCase(thisTag.current_clause,"</p>", "XYZ" , "ALL" )>
                                    
                                    <!--- remove ALL wickets... [begin] --->
                                    <cfset thisTag.current_clause = ReReplaceNoCase(thisTag.current_clause,"<[^>]*(>|$)", "" , "ALL" )>
                                    <!--- remove ALL wickets... [end] --->
                                    
                                    <cfset thisTag.current_clause = replaceNoCase(thisTag.current_clause,"ABC1", "<b>" , "ALL" )>
                                    <cfset thisTag.current_clause = replaceNoCase(thisTag.current_clause,"ABC2", "</b>" , "ALL" )>
                                    <cfset thisTag.current_clause = replaceNoCase(thisTag.current_clause,"XYZ", "<br /><font></font><br />" , "ALL" )>

                                    <p align="justify" <cfif NOT findNoCase("doc_modules_edit_form",cgi.script_name,1)>class="clause_text"</cfif>>#thisTag.current_clause#</p>
                                </td>
                              </tr>
                            </cfoutput>
                          </cfif>
                      </table>
                   </td>
              </tr>
              <!--- 5.) Conditions [end] --->

          </table>
      </td>
  </tr>
</table>
</cfif>