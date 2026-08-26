<!---
	Name: 			claim_form_print.cfm
	Copyright:		(c) 2012 Blacksmith Applications, Inc.
	Created Date:	02/06/2012
	Created By:		Kal     
	Description:	This file is responsible for printing the One Page Claim Form
--->
			<cfset variables.initUser = createObject('component','components.Billback.requestScopeAccess').init() />
			<cfset userid = variables.initUser.getUserId()>
<cfoutput>

	<!--- convert the data to pdf --->
	<cfdocument format="PDF" overwrite="yes" >

		<cfinclude template="\common_documents\Temp_Files\EmailFaxPrint\#request.AccessStructure.User_ID#.html" />

		<cfdocumentitem type="footer" evalatprint="true" > 
		    <table width="100%" border="0" cellpadding="0" cellspacing="0"> 
		        <tr>
		        	<td align="right" style="font-family:Arial; font-size:8pt; font-weight:500; color:Black;">
		        		#cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
		        	</td>
		        </tr> 
		    </table> 
		</cfdocumentitem>
	</cfdocument>


</cfoutput>