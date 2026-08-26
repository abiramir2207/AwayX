<cfsilent>
<!--- 
FILE: 		
FILENAME: 		doc_modules/inc_operators_html.cfm
CREATED: 		11/30/2011 - Milan
EDITED:	

FUNCTIONALITY:
- This file is utilized to show the operator members.
--->
</cfsilent>

<!--- This duplicate css file must be here. --->
<cfinclude template="css/inc_all_style.cfm">

<!--- If there are OPERATOR members --->
<cfif thisTag.qOperatorSecondaryDetails.recordcount>
	<cfoutput>
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td class="blackBG"></td>
		</tr>
		<tr>
			<td colspan="100%" height="3"></td>
		</tr>
	    <tr>
	        <td class="header_text blackBG whiteText" valign="middle" height="20"><b>APPENDIX #oprAppendixAlphabet# - #UCASE(application.returned_customer_setting.operator_label_plural)#<b></td>
	    </tr>
	    <tr>
			<td colspan="100%" height="3"></td>
		</tr>
		<tr>
			<td class="blackBG"></td>
		</tr>
		<tr>
		    <td colspan="100%">&nbsp;</td>
		</tr>
	</table>
	</cfoutput>


<!--- Loop through the operator members (secondary operators) --->
<cfloop query="thisTag.qOperatorDetails">
	
		<!--- Get the members of the operator --->
		<cfquery name="thisTag.qOprMemberDetails" datasource="#application.datasource#">
		    SELECT *
		    FROM ##TMP_qProgramOperatorSecondaryInfo
		    WHERE BSA_Operator_ID = '#thisTag.qOperatorDetails.Operator_ID#'
		    ORDER BY Secondary_Operator_Name
		</cfquery>
		
		<cfif thisTag.qOprMemberDetails.recordcount GT 0>
	
		<cfoutput>
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
		      <tr>
		        <td class="darkGrayBG header_text whiteText" valign="middle" height="20"><b>ELIGIBLE #UCASE(application.returned_customer_setting.operator_label_singular)# GROUP:&nbsp;#thisTag.qOperatorDetails.Operator_Name#<b></td>
		      </tr>
			  <tr>
				<td colspan="100%" height="7"></td>
		      </tr>	
		</table>
		
		<table width="100%" cellspacing="0" cellpadding="0">
		  <tr>
			<td width="20%" valign="middle" height="20" class="header_text darkGrayBG whiteText"><b>ID</b></td>
			<td width="25%" valign="middle" height="20" class="header_text darkGrayBG whiteText"><b>#application.returned_customer_setting.operator_label_singular#<b></td>
			<td width="30%" valign="middle" height="20" class="header_text darkGrayBG whiteText"><b>Address</b></td>
			<td width="12%" valign="middle" height="20" class="header_text darkGrayBG whiteText"><b>City</b></td>
			<td width="5%" valign="middle" height="20" class="header_text darkGrayBG whiteText"><b>State</b></td>
			<td width="8%" valign="middle" height="20" class="header_text darkGrayBG whiteText"><b>Zip</b></td>
		  </tr>
		</table>
		</cfoutput>
		
		<!--- Display the operator members --->
		<table width="100%" cellspacing="0" cellpadding="0">
		<cfoutput query="thisTag.qOprMemberDetails">
		  <tr bgcolor="#iIf(thisTag.qOprMemberDetails.currentRow MOD 2, DE('ffffff'), DE('eeeeee'))#">
		     <td width="20%" valign="middle" height="20">#thisTag.qOprMemberDetails.secondary_operator_id#</td>
		     <td width="25%" valign="middle" height="20">#thisTag.qOprMemberDetails.secondary_operator_name#</td>
		     <td width="30%" valign="middle" height="20">#thisTag.qOprMemberDetails.secondary_operator_address_1#</td>
		     <td width="12%" valign="middle" height="20">#thisTag.qOprMemberDetails.secondary_operator_city#</td>
		     <td width="5%" valign="middle" height="20">#thisTag.qOprMemberDetails.secondary_operator_state#</td>
		     <td width="8%" valign="middle" height="20">#thisTag.qOprMemberDetails.secondary_operator_zipcode#</td>
		  </tr>
		</cfoutput>
		</table>
		
		</cfif>

</cfloop>

</cfif>

