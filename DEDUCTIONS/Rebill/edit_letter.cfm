<cfsilent>

<cfparam name="form.DD_Rebill_ID"	default=0>
<cfparam name="Address" 			default=1>
<cfparam name="DD_Date" 			default=0>
<cfparam name="DD_Amount" 			default=0>
<cfparam name="DD_Customer_RefNo" 	default=0>
<cfparam name="DD_Reference" 		default=0>
<cfparam name="DD_Check_Number" 	default=0>
<cfparam name="Transferred_Reason" 	default=0>
<cfparam name="User_Position" 		default=0> --->

<!---Gets data about deduction--->
<cfinclude template="/deductions/sql_Deduction_Info.cfm">

<!---Get Address --->
<!---1 = ship to address, 2 = bill to address, 3 = broker address --->
<cfif Address IS 1>
	<cfset useLakebaseForGetAddress = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
	<cfif useLakebaseForGetAddress>
		<cftry>
			<cfset GetAddress = application.oLakebase.toQuery(
				application.oLakebase.selectRows("bsa_foodservice_customers", {
					"select" = "name,address_1,address_2,city,state,zipcode",
					"bsa_foodservice_customers_id" = "eq.#Deduction_Info.Distributor_ID#"
				}),
				"name,address_1,address_2,city,state,zipcode"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForGetAddress = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetAddress>
	<cfquery name="GetAddress" datasource="#application.datasource#">
	SELECT Name, Address_1, Address_2, City, State, ZipCode
	FROM BSA_Foodservice_Customers
	WHERE BSA_Foodservice_Customers_ID = '#Deduction_Info.Distributor_ID#'
	</cfquery>
	</cfif>
<cfelseif Address IS 2>	
	<cfquery name="GetAddress" dbtype="query">
	SELECT Name, Address AS Address_1, Address2 AS Address_2, City, State, Zip AS ZipCode
	FROM Deduction_Info
	</cfquery>
<cfelseif Address IS 3>
	<cfquery name="GetAddress" dbtype="query">
	SELECT Broker_Name AS Name, Address AS Address_1, Address_2, Broker_City AS City, Broker_State AS State, Zip as ZipCode 
	FROM Deduction_Info
	</cfquery>
</cfif>

<!---Get Clauses --->
<cfif len(trim(DD_Rebill_ID)) GT 0>
	<cfquery name="GetClauses" datasource="#application.datasource#">
	SELECT DD_Rebill_ID, DD_Rebill_Text, Is_Editable 
	FROM DD_Rebill 
	WHERE DD_Rebill_ID IN (#DD_Rebill_ID#)
	AND Deleted = 0
	ORDER BY Clause_Order, Created_Date
	</cfquery>
</cfif>

<!---Get User Position --->
<cfif User_Position IS 1>
	<cfquery name="GetUserPosition" datasource="#application.datasource#">
	SELECT TOP 1 Position_Label
		FROM User_Positions
		INNER JOIN User_Position_Holders
		ON User_Position_Holders.User_ID = '#request.AccessStructure.User_ID#'
		AND User_Position_Holders.User_Positions_ID = User_Positions.User_Positions_ID
		AND User_Position_Holders.User_Position_Type = 'P'
		AND User_Position_Holders.Deleted = 0
	</cfquery>
</cfif>

<!---Get Deduction Reason --->
<Cfif Transferred_Reason IS 1>
	<cfset useLakebaseForGetDeductionReason = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_rebill_status")>
	<cfif useLakebaseForGetDeductionReason>
		<cftry>
			<cfset GetDeductionReason = application.oLakebase.toQuery(
				application.oLakebase.selectRows("dd_rebill_status", {
					"select" = "transferred_reason",
					"deduction_id" = "eq.#Deduction_ID#",
					"order" = "created_date.desc",
					"limit" = "1"
				}),
				"transferred_reason"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForGetDeductionReason = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetDeductionReason>
	<cfquery name="GetDeductionReason" datasource="#application.datasource#">
	SELECT TOP 1 Transferred_Reason FROM DD_Rebill_Status
	WHERE Deduction_ID = '#Deduction_ID#'
	ORDER BY Created_Date DESC
	</cfquery>
	</cfif>
</CFIF>

</cfsilent>

<cfoutput>
<form action="save_letter.cfm" method="post" name="Rebill_Letter"  ENCTYPE="application/x-www-form-urlencoded">

<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">

<table border="0" width="600" cellpadding="1" cellspacing="0">
<tr>
	<td width="200">
<textarea name="AddressField" rows="4" cols="50">
#trim(GetAddress.Name)#
#trim(GetAddress.Address_1)#<cfif len(trim(GetAddress.Address_2))>
#trim(GetAddress.Address_2)#</cfif>
#trim(GetAddress.City)#, #trim(GetAddress.State)#&nbsp; &nbsp; #trim(GetAddress.ZipCode)#
</textarea>
	</td>
	<td width="200">&nbsp; </td>
	<td width="100" valign="top" align="right">#dateformat(now(), 'MMM DD, YYYY')#</td>
</tr>

<tr><td colspan="3">Dear #GetAddress.Name#, <p></p></td></tr>

<cfloop query="GetClauses">
	<cfif is_Editable IS 0>
		<tr><td colspan="3">#DD_Rebill_Text#<p></td></tr>
	<cfelse>
	<tr><td colspan="3">
    <!--- 
  				Dev Notes: D24468/Anand Rao/17-Aug-10
  				URL on email notifications
  	--->  
    <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
  
	<cfset siteURL = application.HTTPVar & CGI.SERVER_NAME />
	
		<CF_ACTIVEDIT 
	NAME="ID_#GetClauses.DD_Rebill_ID#"
	TOOLBAR="cut,copy,paste,|,undo,redo,|,font,bold,italic,underline,|,outdent,indent,|,justifyleft,justifycenter,justifyright,bullets,numbers"
	IMAGEPATH="#APPLICATIONPATH#/images/"
	IMAGEURL="/images/"
	BASEURL="#siteURL#/"
	INC="/Customtags/ActiveEdit/activedit/inc/"
	DEFAULTFONT="10pt Arial"
	QUICKSTYLES="title,header"
	TABVIEW="0"
	ACTIVSCAN="0"
	ALLOWEDITSOURCE="no"
	HEIGHT=200
	WIDTH=600>
	#DD_Rebill_Text#
	</cf_activedit>
	</td></tr>
	</cfif>
	
</cfloop>

<tr><td colspan="2"><strong>Deduction Information:</strong></td></tr>


	<cfif DD_Date IS 1>
	<tr><td>Deduction Date:</td><td>#Dateformat(Deduction_Info.DD_Date, 'MM/DD/YYYY')#</td><td></td></tr>
	</cfif>
	<cfif DD_Amount IS 1>
	<tr><td>Deduction Amount:</td><td>#LSCurrencyFormat(DD_Amount)#</td><td></td></tr>
	</cfif>
	<cfif DD_Customer_RefNo IS 1>
	<tr><td>Customer Reference Number:</td><td>#Deduction_Info.DD_Customer_RefNo#</td><td></td></tr>
	</cfif>
	<cfif DD_Reference IS 1>
	<tr><td>Deduction Reference Number:</td><td>#Deduction_Info.DD_Reference#</td><td></td></tr>
	</cfif>
	<cfif DD_Check_Number IS 1>
	<tr><td>Check Number:</td><td>#Deduction_Info.DD_Check_Number#</td><td></td></tr>
	</cfif>
	<cfif Transferred_Reason IS 1>
	<tr><td>Deduction Reason:</td><td>#GetDeductionReason.Transferred_Reason#</td><td></td></tr>
	</cfif>

<tr><td colspan="3"><p></p><p></p></td></td></tr>
	
<tr><td colspan="3">Sincerely,<p></p><p></p><p></p><p></p></td></tr>

<tr><td colspan="3">#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#</td></tr>
<cfif User_Position IS 1><tr><td colspan="3">#GetUserPosition.Position_Label#</td></tr></cfif>

<tr><td>&nbsp; </td><td colspan="2">
<input type="Submit" value="Save this letter"></td></tr>

<input type="hidden" name="AddressName"			value="#GetAddress.Name#">
<input type="hidden" name="DD_Date" 			value="#DD_Date#">
<input type="hidden" name="DD_Amount" 			value="#DD_Amount#">
<input type="hidden" name="DD_Customer_RefNo" 	value="#DD_Customer_RefNo#">
<input type="hidden" name="DD_Reference" 		value="#DD_Reference#">
<input type="hidden" name="DD_Check_Number" 	value="#DD_Check_Number#">
<cfif Transferred_Reason IS 1><input type="hidden" name="Transferred_Reason" 	value="#Transferred_Reason#"></cfif>
<input type="hidden" name="User_Position" 		value="#User_Position#">
<input type="hidden" name="DD_Rebill_ID" 		value="#form.DD_Rebill_ID#">
<cfif User_Position IS 1><input type="hidden" name="UserPosition"		value="#GetUserPosition.Position_Label#"></cfif>


</table>
</form>
</cfoutput>
