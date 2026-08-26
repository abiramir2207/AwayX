<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/inc_all_intro_html.cfm
CREATED: 	11/1/2011 - Milan
EDITED:	
--->
</cfsilent>

<!--- This duplicate css file must be here. --->
<cfinclude template="css/inc_all_style.cfm">

<cfset IncludeNotes = 0>
<!--- If it is an "distributor" letter, check whether "Notes" is ON at the letter tab of the template --->
<cfif thisTag.abbreviation eq "dis" and attributes.stPDFBodyInfo.bDistributorNotes
OR
<!--- If it is an "operator" letter, check whether "Notes" is ON at the letter tab of the template --->
	  thisTag.abbreviation eq "opr" and attributes.stPDFBodyInfo.bOperatorNotes>
	<cfset IncludeNotes = 1>
</cfif>

<!--- PROGRAM NOTES --->
<cfif thisTag.stPDFIntroInfo.program_notes neq "" AND IncludeNotes eq 1>
	<table width="100%" cellspacing="0" cellpadding="0" valign="top"  border="0">
      <cfoutput>
      <tr>
      	<td width="5"></td>
        <td class="darkGrayBG header_text whiteText" valign="middle" height="20" colspan="3"><b>NOTES<b></td>
      </tr>
	  <tr>
        <td colspan="100%" height="1"></td>
      </tr>
      </cfoutput>
     </table>
    
	<table width="100%" cellspacing="0" cellpadding="0" valign="top"  border="0">
	  <tr>
        <td colspan="100%" height="2"></td>
      </tr>
	  <tr>
	  	<td width="1%"></td>
	  	<td><cfoutput>#thisTag.stPDFIntroInfo.program_notes#</cfoutput></td>
	  </tr> 
	  <tr>
        <td colspan="100%" height="1"></td>
      </tr>  
	</table>
</cfif>


<!--- OPERATORS --->	
<cfif thisTag.qOperatorDetails.recordcount>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" valign="top">
	  <cfoutput>
	  <tr>
	  	<td width="5"></td>
	    <td class="darkGrayBG header_text whiteText" valign="middle" height="20"><b>ELIGIBLE #UCASE(application.returned_customer_setting.operator_label_plural)#<b></td>
	  </tr>
	  <tr>
        <td colspan="100%" height="1"></td>
      </tr>
	  </cfoutput>
	</table>
	  
	<table width="100%" cellspacing="0" cellpadding="0" border="0">
	  <tr>
        <td colspan="100%" height="2"></td>
      </tr>
      <tr bgcolor="ffffff">
      	<td width="1%"></td>
	<cfoutput query="thisTag.qOperatorDetails">
	   <!--- Show three operators on a row (max).This code will execute for rows 4,7,10 etc --->
	   <cfif thisTag.qOperatorDetails.currentrow neq 1 AND thisTag.qOperatorDetails.recordcount NEQ 1 AND thisTag.qOperatorDetails.currentrow MOD 3 EQ 1>  
	   <tr bgcolor="#iIf(thisTag.qOperatorDetails.currentRow MOD 2, DE('ffffff'), DE('eeeeee'))#">
	   	<td width="1%"></td>
	    </cfif>
		<td align="left" width="33%" valign="top">#Operator_Name#&nbsp;<cfif thisTag.qOperatorDetails.Legacy_ID neq "">(#legacy_id#)<cfelse>(#operator_id#)</cfif>
		<br />#operator_city#<cfif operator_state neq "">,</cfif>&nbsp;#operator_state#</td> 

	   <!--- If it's not the last record. This code will execute for rows 3,6,9 etc --->
	   <cfif thisTag.qOperatorDetails.currentrow neq thisTag.qOperatorDetails.recordcount AND thisTag.qOperatorDetails.currentrow MOD 3 EQ 0>
	   </tr>
	   </cfif>
	</cfoutput>
	
	<!--- If the data display is only for the first cell in the last row of the data, add two more cells --->
    <cfif thisTag.qOperatorDetails.recordcount MOD 3 eq 1>
   	   	<td align="left" width="33%"></td>
	   	<td align="left" width="33%"></td>
		
    <!--- If the data display is only for the the first two cells in the last row of the data, add one more cell --->
    <cfelseif thisTag.qOperatorDetails.recordcount MOD 3 eq 2>
	   	<td align="left" width="33%"></td>
	</cfif>
	
      </tr>
      <tr>
        <td colspan="100%">&nbsp;</td>
      </tr>
   </table>
</cfif>

 <!--- DISTRIBUTORS --->
 <cfif thisTag.qDistDetails.recordcount>
	 <table width="100%" cellspacing="0" cellpadding="0" valign="top"  border="0">
      <cfoutput>
      <tr>
      	<td width="5"></td>
        <td class="darkGrayBG header_text whiteText" valign="middle" height="20" colspan="3"><b>ELIGIBLE #UCASE(application.returned_customer_setting.distributor_label_plural)#<b></td>
      </tr>
	  <tr>
        <td colspan="100%" height="1"></td>
      </tr>
      </cfoutput>
     </table>
    

	<table width="100%" cellspacing="0" cellpadding="0" border="0">
	  <tr>
        <td colspan="100%" height="2"></td>
      </tr>
      <tr bgcolor="ffffff">
      	<td width="1%"></td>
		
	<cfoutput query="thisTag.qDistDetails">
	   <!--- Show three distributors on a row (max). This code will execute for rows 4,7,10 etc --->
	   <cfif thisTag.qDistDetails.currentrow neq 1 AND thisTag.qDistDetails.recordcount NEQ 1 AND thisTag.qDistDetails.currentrow MOD 3 EQ 1>  
	   <tr bgcolor="#iIf(thisTag.qDistDetails.currentRow MOD 2, DE('ffffff'), DE('eeeeee'))#">
	   	<td width="1%"></td>
	    </cfif>
		<td align="left" height="20" width="33%" valign="top"><cfif Is_Group eq 1>#Group_Desc#<cfelse>#name# (#shr_Ship_to#)</cfif><br />#city#<cfif state neq "">,</cfif>&nbsp;#state#</td> 

	   <!--- If it's not the last record. This code will execute for rows 3,6,9 etc --->
	   <cfif thisTag.qDistDetails.currentrow neq thisTag.qDistDetails.recordcount AND thisTag.qDistDetails.currentrow MOD 3 EQ 0>
	   </tr>
	   </cfif>
	</cfoutput>
	
   	<!--- If the data display is only for the first cell in the last row of the data, add two more cells --->
   	<cfif thisTag.qDistDetails.recordcount MOD 3 eq 1>
   	   <td align="left" height="20" width="33%"></td>
	   <td align="left" height="20" width="33%"></td>
	   
   	<!--- If the data display is only for the the first two cells in the last row of the data, add one more cell --->
   	<cfelseif thisTag.qDistDetails.recordcount MOD 3 eq 2>
	   	   <td align="left" height="20" width="33%"></td>
   	</cfif>
   	
      </tr>
	  <tr>
        <td colspan="100%">&nbsp;</td>
      </tr>
   </table>
</cfif>
