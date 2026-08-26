<cfsilent>
<!--- 
FILE: 		
FILENAME: 		doc_modules/inc_distributor_html.cfm
CREATED: 		11/1/2011 - Milan
EDITED:	

FUNCTIONALITY:
- This file is utilized to show the distributor group members.
--->
</cfsilent>

<!--- This duplicate css file must be here. --->
<cfinclude template="css/inc_all_style.cfm">

<!--- If there are DISTRIBUTORS at the GROUP level --->
<cfif thisTag.qDistDetails.recordcount AND thisTag.qDistDetails.Is_group eq 1>
	<cfoutput>
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td class="blackBG"></td>
		</tr>
		<tr>
			<td colspan="100%" height="3"></td>
		</tr>
	    <tr>
	        <td class="header_text blackBG whiteText" valign="middle" height="20"><b>APPENDIX #distAppendixAlphabet# - #UCASE(application.returned_customer_setting.distributor_label_plural)#<b></td>
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
</cfif>
	
<!--- Loop through the DISTRIBUTORS at the GROUP level --->
<cfloop query="thisTag.qDistDetails">
	
	<cfif thisTag.qDistDetails.Is_Group eq 1>
	
		<cfoutput>
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
		      <tr>
		        <td class="darkGrayBG header_text whiteText" valign="middle" height="20"><b>ELIGIBLE #UCASE(application.returned_customer_setting.distributor_label_singular)# GROUP:&nbsp;#Group_Desc#<b></td>
		      </tr>
			  <tr>
				<td colspan="100%" height="7"></td>
		      </tr>	
		</table>
		
		<table width="100%" cellspacing="0" cellpadding="0">
		  <tr>
			<td width="20%" valign="middle" height="20" class="header_text darkGrayBG whiteText"><b>ID</b></td>
			<td width="25%" valign="middle" height="20" class="header_text darkGrayBG whiteText"><b>#application.returned_customer_setting.distributor_label_singular#<b></td>
			<td width="30%" valign="middle" height="20" class="header_text darkGrayBG whiteText"><b>Address</b></td>
			<td width="12%" valign="middle" height="20" class="header_text darkGrayBG whiteText"><b>City</b></td>
			<td width="5%" valign="middle" height="20" class="header_text darkGrayBG whiteText"><b>State</b></td>
			<td width="8%" valign="middle" height="20" class="header_text darkGrayBG whiteText"><b>Zip</b></td>
		  </tr>
		</table>
		</cfoutput>
		
		<!--- Get the members of the distributor group --->
		<cfquery name="thisTag.qDistGroupMemberDetails" datasource="#application.datasource#">
		    SELECT shr_ship_to,name,address_1,city,state,zipcode
		    FROM ##TMP_qProgramAllDistributorInfo
		    WHERE Is_Group = 0
		    AND Captured_From_Group = 1
		    AND Distributor_Group_ID = '#thisTag.qDistDetails.BSA_Foodservice_Customers_ID#'
		    ORDER BY Name
		</cfquery>
		
		<!--- Display the members of the distributor group --->
		<table width="100%" cellspacing="0" cellpadding="0">
		<cfoutput query="thisTag.qDistGroupMemberDetails">
		  <tr bgcolor="#iIf(thisTag.qDistGroupMemberDetails.currentRow MOD 2, DE('ffffff'), DE('eeeeee'))#">
		     <td width="20%" valign="middle" height="20" >#shr_ship_to#</td>
		     <td width="25%" valign="middle" height="20">#name#</td>
		     <td width="30%" valign="middle" height="20">#address_1#</td>
		     <td width="12%" valign="middle" height="20">#city#</td>
		     <td width="5%" valign="middle" height="20">#state#</td>
		     <td width="8%" valign="middle" height="20">#zipcode#</td>
		  </tr>
		  </cfoutput>
		</table>
	</cfif>

</cfloop>
