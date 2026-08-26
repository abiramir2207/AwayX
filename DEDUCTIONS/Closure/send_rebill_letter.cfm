<!---Distributor information editable--->

<cfquery name="GetDistInfo" datasource="#application.datasource#">
SELECT Deductions.*, DateDiff(d, Deductions.DD_Date, GetDate()) AS DD_Age,
Distributor_Bill_To.Name, Distributor_Bill_To.Address1, Distributor_Bill_To.Address2, Distributor_Bill_To.City, Distributor_Bill_To.State, Distributor_Bill_To.Zip, Distributor_Bill_To.Phone
FROM Deductions
	LEFT JOIN Distributor_Bill_To
	ON Distributor_Bill_To.Distributor_Bill_To_ID = Deductions.Distributor_Bill_To_ID
WHERE Deductions.Deduction_ID = '#Deduction_ID#'
</cfquery>

<cfset useLakebaseForGetLetter = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_rebill")>
<cfif useLakebaseForGetLetter>
	<cftry>
		<cfset GetLetter = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_rebill", { "select" = "dd_rebill_text" })
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetLetter = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetLetter>
	<cfquery name="GetLetter" datasource="#application.datasource#">
	SELECT DD_Rebill_Text
	FROM DD_Rebill
	</cfquery>
</cfif>

<cfoutput query="GetDistInfo">
<div align="center">
<form name="RebillInfo" method="post" action="/deductions/closure/send_rebill_letter_action.cfm">
<table width="802" cellpadding="0" cellspacing="0" border="0">

<tr>
	<th colspan="2" align="center">
	<font color="navy">#Name#</font>
	</th>
</tr>
<tr><td colspan="2"><hr width="100%" color="navy"></td></tr>
<tr>
	<td width="50%" valign="top">
	<strong>#application.returned_customer_setting.billto_label#:</strong><br>
	<input type="text" name="RB_Name" size="30" value="#Name#"><br>
		<input type="text" name="RB_Address_1" size="30" value="#Address1#"><br>
		<cfif len(trim(Address2)) GT 0>
		<input type="text" name="RB_Address_2" size="30" value="#Address2#"><br>
		<cfelse>
		<input type="hidden" name="RB_Address_2" value="">
		</cfif>
		<input type="text" name="RB_City" size="30" value="#City#">, <input type="text" name="RB_State" size="2" value="#State#"> <input type="text" name="RB_ZipCode" size="10" value="#Zip#"> <br>
		(<input type="text" size="3" name="RB_Phone1" value="#left(Phone, 3)#">) <input type="text" size="3" name="RB_Phone2" value="#left(right(Phone, 7), 3)#">-<input type="text" size="4" name="RB_Phone3" value="#right(Phone, 4)#">

	</td>
	<td width="50%" valign="top">
	<strong>Deduction Information:<br></strong>
	Deduction Amount: #LSCurrencyFormat(DD_Amount)#<input type="hidden" name="RB_DD_Amount" value="#DD_Amount#"><Br>
	Deposit Date: #DateFormat(DD_Date, 'MM/DD/YYYY')#<input type="hidden" name="RB_DD_Date" value="#DD_Date#"><br>
	Reference: #DD_Reference#<input type="hidden" name="RB_DD_Reference" value="#DD_Reference#"><Br>
	Check Number: #DD_Check_Number#<input type="hidden" name="RB_DD_Check_Number" value="#DD_Check_Number#"><Br>
		
	</td>
</tr>

<tr>
	<td valign="top">

	</td>
</tr>

<tr>
	<td colspan="2">
  <!--- 
				Dev Notes: D24468/Anand Rao/17-Aug-10
				URL on email notifications
	--->  
  <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

	<cfset siteURL = application.HTTPVar & CGI.SERVER_NAME />

	<CF_ACTIVEDIT 
			NAME="RB_DD_Rebill_Text"
	TOOLBAR="cut,copy,paste,|,undo,redo,|,font,bold,italic,underline,|,outdent,indent,|,justifyleft,justifycenter,justifyright,bullets,numbers,|,table,image,showdetails,specialchars,hr,hyperlink,help"
	IMAGEPATH="c:/inetpub/wwwroot/images/"
	IMAGEURL="#applicationpath#/images/"
	BASEURL="#siteURL#/"
	INC="/Customtags/ActiveEdit/activedit/inc/"
	DEFAULTFONT="12pt Times New Roman"
	QUICKSTYLES="title,header"
	TABVIEW="0"
	ACTIVSCAN="0"
	HEIGHT=300
	WIDTH="80%">
		<cfoutput>#GetLetter.DD_Rebill_Text#</cfoutput>
</CF_ACTIVEDIT>
	
	</td>
</tr>

<tr>
	<td colspan="2" align="center">
	<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
	<input type="hidden" name="ReasonCode" value="#ReasonCode#">
	<input type="submit" value="Email" name="Submit_Method"> &nbsp;  <input type="submit" value="Fax" name="Submit_Method"> &nbsp;  <input type="submit" value="Print" name="Submit_Method">
	</td>
</tr>

</table>
</div>
</form>
</cfoutput>