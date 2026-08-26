<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/inc_all_clauses_html.cfm
            (The HTML content existed on the "inc_all_clauses.cfm" and was originally coded by Brad)
CREATED: 	11/1/2011 - Milan
EDITED:	

FUNCTIONALITY:
- This include template generates the "Clause" module...
--->
</cfsilent>

<!--- This duplicate css file must be here. --->
<cfinclude template="css/inc_all_style.cfm">

<!--- Clauses header --->
<table width="100%" cellpadding="0" cellspacing="0" border="0">
 	<tr>
		<td class="blackBG"></td>
	</tr>
	<tr>
		<td colspan="100%" height="3"></td>
	</tr>     
	<tr>
        <td class="header_text blackBG whiteText" valign="middle" height="20"><b>APPENDIX <cfoutput>#clauseAppendixAlphabet#</cfoutput> - TERMS & CONDITIONS<b></td>
    </tr>
	<tr>
		<td colspan="100%" height="3"></td>
	</tr>
	<tr>
		<td class="blackBG"></td>
	</tr>
</table>

<!--- Clauses content --->
<table name="outer_table" width="100%" cellpadding="0" cellspacing="0" border="0">
  <tr>
      <td align="center" valign="top">
          <table name="inner_table" width="90%" cellpadding="0" cellspacing="0">
              
              <!--- 5.) Clauses [begin] --->
              <tr name="row_8">
                  <td colspan="6">
                      <table name="nested_table" border="0" cellpadding="5" cellspacing="0" width="100%">

                          <cfif thisTag.qProgramClause.recordCount>
                          
                          	<!--- TESTING <cfdump var="#thisTag.qProgramClause.Clause_Library_Body[2]#" label="thisTag.qProgramClause[2]">
                            <cfdump var="#ReReplaceNoCase(thisTag.qProgramClause.Clause_Library_Body[2],"<[^>]*(>|$)", "" , "ALL" )#"  label="reReplace()[2]">
							<cfabort> --->
                          
                            <cfoutput query="thisTag.qProgramClause">
                            	<!--- bgcolor="#iIf(thisTag.qProgramClause.currentRow MOD 2, DE('ffffff'), DE('eeeeee'))#" --->
                              <tr>
                                <td valign="middle" align="left">				
				<!---
				WE WILL NOT NEED THIS CLEAN UP CODE BELOW AS NOW WE ARE USING A NEW HTML EDITOR FOR CLAUSES WHICH CREATES MUCH CLEANER HTML CODE.
				IN FACT ADDING THIS CLEAN UP CODE DOES NOT CREATE CORRECTLY FORMATTED LETTERS. 
				--->
				<!--- let's clean it up before we dish it up to the user...
                                  by removing ALL HTML tags [wickets and attributes] with this cool RegEx... Then apply our own CSS class here 
                                --->
				<!---
                                    <cfset thisTag.current_clause = replaceNoCase(thisTag.qProgramClause.Clause_Library_Body,"<B>", "ABC1" , "ALL" )>
				    <cfset thisTag.current_clause = replaceNoCase(thisTag.current_clause,"</B>", "ABC2" , "ALL" )>
                                    <cfset thisTag.current_clause = replaceNoCase(thisTag.current_clause,"</p>", "XYZ" , "ALL" )>
                                    
                                    <cfset thisTag.current_clause = ReReplaceNoCase(thisTag.current_clause,"<[^>]*(>|$)", "" , "ALL" )>
                                     
                                    <cfset thisTag.current_clause = replaceNoCase(thisTag.current_clause,"ABC1", "<b>" , "ALL" )>
                                    <cfset thisTag.current_clause = replaceNoCase(thisTag.current_clause,"ABC2", "</b>" , "ALL" )>
                                    <cfset thisTag.current_clause = replaceNoCase(thisTag.current_clause,"XYZ", "<br /><font></font><br />" , "ALL" )>
				
                                    <p align="justify" <cfif NOT findNoCase("doc_modules_edit_form",cgi.script_name,1)>class="clause_text"</cfif>>#thisTag.current_clause#</p>
				 --->
				<!---
				STEPS TO DO FOR A CLIENT TO AVOID FORMATTING/FONT FAMILY/FONT SIZE ISSUES FOR CLAUSES:

				1) THE CLAUSES ARE FORMATTED USING THE HTML EDITOR ON THE SETTINGS SECTION. WE USED TO USE AN OLD VERSION OF HTML EDITOR WHICH USED TO GENERATE
				HTML CODE NOT VERY SUITABLE FOR LETTERS AS THE HTML CODE WAS NOT VERY CLEAN. WE HAD TO USE THE CLEAN UP CODE CODE ABOVE TO AVOID THE ISSUES.
				WHEN WE MOVED TO WINDOWS 7, THE HTML EDITOR DID NOT WORK AND SO WE HAD TO REMOVE THE OLD EDITOR AND ADD A NEW HTML EDITOR FOR CLAUSES ON THE SETTINGS SECTION. 
				2) THE NEW EDITOR GENERATES MUCH CLEANER HTML CODE BUT EVEN WITH THE NEW HTML CODE WE CANNOT SPECIFY FONT SIZE/FAMILY USING A STYLE SHEET FROM HERE AS IT DOES NOT
				WORK CORRECTLY CONSISTENTLY FOR ALL CLAUSES.

				SOLUTION:
				1) ANY CLIENT MOVING TO A VERSION WHERE WE USE THE NEW EDITOR NEEDS TO HAVE NEW HTML CODE GENERATED FROM THE NEW HTML EDITOR. FOR THAT TO HAPPEN ONE NEEDS TO REMOVE
				THE OLD CLAUSES ENTIRELY AND RE-ADD THOSE CLAUSES ON THE CLAUSES SECTION.
				2) THESE LETTERS ARE GENERATED USING "TIMES NEW ROMAN" FONT AND SO THE CLIENT NEEDS TO ADD THE CLAUSES ON THE CLAUSES USING THIS FONT AND WHATEVER SIZE THEY DESIRE.
				THE CONTENT ON THE LETTER SHOULD LOOK EXACTLY LIKE ON THE CLAUSES SECTION.
				--->
				 <p align="justify">#thisTag.qProgramClause.Clause_Library_Body#</p>
                                </td>
                              </tr>
                            </cfoutput>
                          </cfif>
                      </table>
                   </td>
              </tr>
              <!--- 5.) Clauses [end] --->

          </table>
      </td>
  </tr>
</table>
