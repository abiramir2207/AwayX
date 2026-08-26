<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/inc_signatures_html.cfm
CREATED: 		11/1/2011 - Milan 
               (The HTML content existed on the "inc_dis_signature.cfm" and was originally coded by Brad)
EDITED:			

FUNCTIONALITY:
- This included template generates the "Signature" module
--->
</cfsilent>

<!--- This duplicate css file must be here. --->
<cfinclude template="css/inc_all_style.cfm">

<!--- "SIGN OFF:" header --->
<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
		<td class="blackBG"></td>
	</tr>
	<tr>
		<td colspan="100%" height="3"></td>
	</tr>
    <tr>
        <td class="header_text blackBG whiteText" valign="middle" height="20"><b>SIGN OFF<b></td>
    </tr>
	<tr>
		<td colspan="100%" height="3"></td>
	</tr>
	<tr>
		<td class="blackBG"></td>
	</tr>
	<tr>
        <td height="1">&nbsp;</td>
    </tr>
</table>

<!--- "SIGN OFF:" content --->
<table name="outer_table" width="100%" cellpadding="0" cellspacing="0" class="top noBorderNoPadNoMargin">
  <tr>
      <td align="center" valign="top">
          <table name="inner_table" width="90%" cellpadding="0" cellspacing="0" class="top noBorderNoPadNoMargin">
              
              <!--- 6.) Signatures [begin] --->
              <cfoutput>
                  <tr name="row_9">
                      <td colspan="6" align="center">
                          <table name="nested_table" border="0" cellpadding="5" cellspacing="0" width="100%" class="top noBorderNoPadNoMargin">
			     <tr>
				  <td valign="top" width="10%">Accepted By:</td>
				  <td valign="top" colspan="2" class="thinBottomBorder" width="40%">
				  	#attributes.qGetTemplateSettings.letters_accepted_by#
				  <!--- D36100  :: MOVE 'Letters Accepted By text' SETTING TO BE AT THE TEMPLATE LEVEL
				      #thisTag.oAppSettings.getLettersAcceptedBy()#  
				  --->
				  </td>
				  <td valign="top" width="10%">Accepted By:</td>

				  <td valign="top" colspan="2" class="thinBottomBorder" width="40%">
				  <cfif thisTag.abbreviation eq "opr">    
				  #listSort(replace(thisTag.lsOperatorNames,"##","","all"),"Text","ASC",",")#
				  <cfelse>
				   #listSort(replace(thisTag.lsDistributorNames,"##","","all"),"Text","ASC",",")#
				   </cfif>
				  </td>
			      <tr>
			       <tr>
				  <td valign="top">Name:</td>
				  <td valign="top" colspan="2" class="thinBottomBorder">
				      <!--- #thisTag.qGetProgramDetails.name_first# #thisTag.qGetProgramDetails.name_last# --->&nbsp;
				  </td>
				  <td valign="top">Name:</td>
				  <td valign="top" colspan="2" class="thinBottomBorder">&nbsp;
				      
				  </td>
			      <tr>
			      <tr>
				  <td valign="top">Signature:</td>
				  <td valign="top" colspan="2" class="thinBottomBorder">&nbsp;
				      
				  </td>
				  <td valign="top">Signature:</td>
				  <td valign="top" colspan="2" class="thinBottomBorder">&nbsp;
				      
				  </td>
			      <tr>
			      <tr>
				  <td valign="top">Date:</td>
				  <td valign="top" colspan="2" class="thinBottomBorder">
				      #dateFormat(now(),"mmmm dd, yyyy")#
				  </td>
				  <td valign="top">Date:</td>
				  <td valign="top" colspan="2" class="thinBottomBorder">
				      #dateFormat(now(),"mmmm dd, yyyy")#
				  </td>
			      <tr>
			</table>
		     </td>
		 </tr>
		 </cfoutput>
	 </table>
      </td>
   </tr>
   <tr>
        <td height="1">&nbsp;</td>
   </tr>
</table>