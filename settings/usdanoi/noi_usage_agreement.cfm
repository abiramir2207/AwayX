<cfquery name="usageAgreementConfirmation" datasource="#application.datasource#">
	SELECT User_ID
	FROM usdanoi_agreements
	WHERE User_ID = '#request.AccessStructure.user_id#'
</cfquery>
<cfif usageAgreementConfirmation.recordcount NEQ 123>
<br>
<table bgcolor="#808080" align="center" cellspacing="0" cellpadding="1">
<tr>
<td>
	<table width="500" bgcolor="#ffffff" cellpadding="0px;" align="center">
		<tr>
			<td>
				<span style="color: black; font-size: 17px; font-family: 'Century Gothic';">The site you are about to enter is intended for School Foodservice <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> purchasing Lamb Weston products and is designed to help them manage volume commitments within the USDA Commodity Program.  If you have questions regarding product information or the availability of Lamb Weston products from your local <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput>, please contact your local Lamb Weston Sales Representative.</span>
<hr>
<img src="/images/LW__SPPlogo_borderless.jpg" title=""  border="0">
			</td>
		</tr>
	</table>
</td></tr>
<tr>
	<td align="right" bgcolor="#ffffff">
<!--- 		<input type="checkbox" value="1" onclick="saveAgreement()"><span style="color: red; font-size: 13px; font-family: 'Century Gothic';">Please do not show this again</span>
<br> --->
<a style="font-size: 13px; font-family: 'Century Gothic';"  href="search.cfm">Click here to continue</a>
<p>&nbsp; </p>
<p>&nbsp; </p>
<p>&nbsp; </p>


	</td>
</tr>

<tr><td bgcolor="#ffffff" align="Center"><strong><font color="red">[</font> <A HREF="##" onClick="NewWindow('/settings/password_form.cfm?PageTitle=Personal%20Settings:%20change%20password&FromHome=1','name','450','350','Yes', 'Yes')">Change password</a> <font color="red">]</font></strong></td></tr>
</table>

<script>
	function saveAgreement(){
		document.location.href="agreement_action.cfm?user_id=<cfoutput>#request.AccessStructure.user_id#</cfoutput>";
	}
</script>

<cfflush>
<cfabort>

</cfif>

<cflocation url="search.cfm">