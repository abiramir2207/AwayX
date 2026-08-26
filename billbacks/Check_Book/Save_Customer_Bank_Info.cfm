<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<CFIF Form.Bank_Info_ID EQ "">
<CFOUTPUT>
	<cfset useLakebaseForCheck_repetition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("customer_bank_info")>
<cfif useLakebaseForCheck_repetition>
	<cftry>
		<cfset Check_repetition = application.oLakebase.toQuery(
			application.oLakebase.selectRows("customer_bank_info", {
				"customer_id" = "eq.#Customer_ID#",
				"bank_info_deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheck_repetition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheck_repetition>
<CFQUERY NAME="Check_repetition" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Customer_Bank_Info WHERE Customer_ID = '#Customer_ID#' AND Bank_Info_Deleted = 0 
	</CFQUERY>
</cfif>
	<CFIF Check_repetition.recordcount GT 0>
		<CFSET urlstring = "RID=#Check_repetition.Bank_Info_ID#">		
		<CFIF isdefined("FORM.New_BB_Check")>
			<CFSET urlstring="#urlstring#&New_BB_Check=#FORM.New_BB_Check#&trans_type=#FORM.Trans_Type#&LRID=#FORM.LRID#">
		</CFIF>
		<CFIF isdefined("FORM.Payee_ID")>
			<CFSET urlstring="#urlstring#&Payee_ID=#FORM.Payee_ID#&Payee_Name=#FORM.Payee_Name#">
		</CFIF>
		<BR><BR><BR><BR><BR><BR>
		<TABLE ALIGN="Center">
			<TR>
				<TD>There is an active data exist for this customer. Please, Make it inactive and try again.</TD>
			</TR>
		</TABLE>

		
		<SCRIPT LANGUAGE="JavaScript">		
			var pass = "<cfoutput>#form.category#</cfoutput>";
			
			function goBackToFormPage()
			{
				if (pass == "Distributor")
				{
					window.location.href = "Distributor_Bank_Info.Cfm?<cfoutput>#urlstring#</cfoutput>";
				}
				else if (pass == "Broker")
				{
					window.location.href = "Broker_Bank_Info.cfm?<cfoutput>#urlstring#</cfoutput>";
				}
				else if (pass == "Operator")
				{
					window.location.href = "Operator_Bank_Info.cfm?<cfoutput>#urlstring#</cfoutput>";
				}
			}
			window.setTimeout('goBackToFormPage()', 2000);
		</SCRIPT>	
		<CFABORT>	
	</CFIF>
</CFOUTPUT>
</CFIF> 

<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<cfset useLakebaseFordelete_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("customer_bank_info")>
<cfif useLakebaseFordelete_Data>
	<cftry>
		<cfset application.oLakebase.deleteRows("customer_bank_info", {
			"bank_info_id" = "eq.#Form.Bank_Info_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordelete_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordelete_Data>
<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
		DELETE FROM Customer_Bank_Info  
		WHERE		Bank_Info_Id			=	'#Form.Bank_Info_ID#'
	</CFQUERY>
</cfif>
	<CFIF form.category EQ	'Distributor'>
		<CFLOCATION URL="Distributor_Bank_Info.cfm" ADDTOKEN="No">
	<CFELSEIF form.category EQ	'Operator'>
		<CFLOCATION URL="Operator_Bank_Info.cfm" ADDTOKEN="No">
	<CFELSEIF form.category EQ	'Broker'>
		<CFLOCATION URL="Broker_Bank_Info.cfm" ADDTOKEN="No">
	</CFIF> 
	<CFABORT>
</CFIF>


<CFIF isdefined("form.trans_type")>

	<CFIF form.trans_type EQ 0>

		 <CFIF 	
		 	trim(Form.Customer_Name) EQ "" OR trim(Form.Customer_Name) EQ 0 OR
			trim(Form.Customer_Account_No) EQ "" OR trim(Form.Customer_Account_No) EQ 0 OR		
			trim(Form.Customer_Transit_Routing_No) EQ "" OR trim(Form.Customer_Transit_Routing_No) EQ 0 OR
			trim(Form.Customer_Bank_Name) EQ "" OR trim(Form.Customer_Bank_Name) EQ 0 OR
			trim(Form.Customer_Bank_Address) EQ "" OR trim(Form.Customer_Bank_Address) EQ 0		
			>
			<BR><BR><BR><BR><BR><BR>
			<TABLE ALIGN="CENTER">
				<TR>
					<TD>Please Enter Value for <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>,Account No,Transit Rounting No, Bank Name and Bank Address and Try again.</TD>
				</TR>
			</TABLE>
		  			<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 3000);</SCRIPT> 
					<CFABORT>		
		</CFIF>
		<CFIF trim(form.Customer_Bank_Location) EQ 1>
		  	<CFIF 		  	  
			  trim(Form.Customer_Bank_City) EQ "" OR trim(Form.Customer_Bank_City) EQ 0 OR		
			  trim(Form.Customer_Bank_Statecode) EQ "" OR trim(Form.Customer_Bank_Statecode) EQ 0 OR
			  trim(Form.Customer_Bank_Zipcode) EQ "" OR trim(Form.Customer_Bank_Zipcode) EQ 0 >
					<BR><BR><BR><BR><BR><BR>
					<TABLE ALIGN="Center">
						<TR>
							<TD>Please Enter Value for City/State/Zipcode and Try again</TD>
						</TR>
					</TABLE>

				  <SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 3000);</SCRIPT> 
				  <CFABORT>		
			</CFIF>
				
		  </CFIF>
	<CFELSEIF trim(Form.Customer_Name) EQ "" OR trim(Form.Customer_Name) EQ 0>
			<BR><BR><BR><BR><BR><BR>
			<TABLE ALIGN="CENTER">
				<TR>
					<TD>Please Enter value for atleast <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> and try again.</TD>
				</TR>
			</TABLE>
			 <SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 3000);</SCRIPT> 
			<CFABORT>		
	 
	</CFIF>
<CFELSEIF trim(Form.Customer_Name) EQ "" OR trim(Form.Customer_Name) EQ 0>
	<BR><BR><BR><BR><BR><BR>
	<TABLE ALIGN="CENTER">
		<TR>
			<TD>Please Enter value for atleast <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> and try again.</TD>
		</TR>
	</TABLE>
	 <SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 3000);</SCRIPT> 
	<CFABORT>		
	
</CFIF>


<!--- <CFOUTPUT>

#Form.Customer_ID#
#Form.Customer_Transit_Routing_No#
#Form.Customer_Bank_Name#
#Form.Customer_Bank_Address#
#Form.Customer_Bank_City#
#Form.Customer_Bank_Statecode#
#Form.Customer_Bank_Zipcode#
#Form.Customer_Account_No#
#Form.Bank_Info_Deleted#

</CFOUTPUT>


 --->

  <CFIF Form.Bank_Info_ID EQ "">
<!--- Insert the record --->
	 <CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		Customer_Bank_Info
						(
							Customer_ID,
							Customer_Transit_Routing_No,
							Customer_Bank_Name,
							Customer_Bank_Address,
							Customer_Bank_Country_Code,
							<CFIF isdefined("FORM.Customer_Bank_City")>
							Customer_Bank_City,
							Customer_Bank_Statecode,
							Customer_Bank_Zipcode,
							</CFIF>
							Customer_Account_No,
							Category,
							Bank_Info_Deleted,
							Customer_Bank_Location
						)
		Values			(
							'#Form.Customer_ID#',
							'#Form.Customer_Transit_Routing_No#',
							'#Form.Customer_Bank_Name#',
							'#Form.Customer_Bank_Address#',
							'#Form.Customer_Bank_Country_Code#',
							<CFIF isdefined("FORM.Customer_Bank_City")>							
							'#Form.Customer_Bank_City#',
							'#Form.Customer_Bank_Statecode#',
							'#Form.Customer_Bank_Zipcode#',
							</CFIF>
							'#Form.Customer_Account_No#',
							'#Form.Category#',
							'#Form.Bank_Info_Deleted#',
							'#Form.Customer_Bank_Location#'
						)
	</CFQUERY>
	

 	<CFOUTPUT>

	<CFIF isdefined("form.LRID")>	
	<CFQUERY NAME = "new_bank_id" DATASOURCE = "#application.datasource#">
			SELECT max(bank_info_id) bank_info_id FROM customer_bank_info
	</CFQUERY>
	<CFSET form.bank_info_id = new_bank_id.bank_info_id>
<!---   Bank_Info_Id :#form.Bank_Info_Id#
  #form.new_bb_check#<br>
  #form.trans_type#<br>
  #form.LRID#
<cfabort>
 --->	

		<CFLOCATION URL="bank_tran/payment_transaction_data_entry.cfm?category=#form.category#&bank_info_id=#form.bank_info_id#&new_bb_check=#form.new_bb_check#&trans_type=#form.trans_type#&RID=#LRID#" ADDTOKEN="No">

	</CFIF>
	</CFOUTPUT>
	<CFIF form.category EQ	'Distributor'>
		<CFLOCATION URL="Distributor_Bank_Info.cfm" ADDTOKEN="No">
	<CFELSEIF form.category EQ	'Operator'>
		<CFLOCATION URL="Operator_Bank_Info.cfm" ADDTOKEN="No">
	<CFELSEIF form.category EQ	'Broker'>
		<CFLOCATION URL="Broker_Bank_Info.cfm" ADDTOKEN="No">
	</CFIF> 
	<CFABORT>
<CFELSE>
	<CFIF FORM.Customer_Bank_Location EQ 0>
	
	
	<cfset useLakebaseFordelete_c_s_z = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("customer_bank_info")>
<cfif useLakebaseFordelete_c_s_z>
	<cftry>
		<cfset application.oLakebase.updateRows("customer_bank_info",
			{
				"bank_info_id" = "eq.#Form.Bank_Info_ID#"
			},
			{
				"customer_bank_city" = "",
				"customer_bank_statecode" = "",
				"customer_bank_zipcode" = ""
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordelete_c_s_z = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordelete_c_s_z>
<CFQUERY name = "delete_c_s_z" datasource = "#Application.datasource#">
		UPDATE Customer_Bank_Info
		SET				Customer_Bank_City				=	'',
						Customer_Bank_Statecode			=	'',
						Customer_Bank_Zipcode			=	''
		WHERE		Bank_Info_Id			=	'#Form.Bank_Info_ID#'							
	</CFQUERY>
</cfif>
	</CFIF>
<!--- Update the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		Customer_Bank_Info
		SET					Customer_ID						=	'#Form.Customer_ID#',
							Customer_Transit_Routing_No		=	'#Form.Customer_Transit_Routing_No#',
							Customer_Bank_Name				=	'#Form.Customer_Bank_Name#',
							Customer_Bank_Address			=	'#Form.Customer_Bank_Address#',
							Customer_Bank_Country_Code		=	'#Form.Customer_Bank_Country_Code#',
							<CFIF FORM.Customer_Bank_Location NEQ 0<!--- isdefined("FORM.Customer_Bank_City") --->>
							Customer_Bank_City				=	'#Form.Customer_Bank_City#',
							Customer_Bank_Statecode			=	'#Form.Customer_Bank_Statecode#',
							Customer_Bank_Zipcode			=	'#Form.Customer_Bank_Zipcode#',
							</CFIF>
							Customer_Account_No				=	'#Form.Customer_Account_No#',
							Category						=	'#Form.Category#',
							Bank_Info_Deleted				=	'#Form.Bank_Info_Deleted#',
							Customer_Bank_Location			=	'#Form.Customer_Bank_Location#'
		WHERE		Bank_Info_Id			=	'#Form.Bank_Info_ID#'

	</CFQUERY>
	<CFOUTPUT>
	<CFIF isdefined("form.LRID")>
		<CFLOCATION URL="bank_tran/payment_transaction_data_entry.cfm?category=#form.category#&bank_info_id=#form.bank_info_id#&new_bb_check=#form.new_bb_check#&trans_type=#form.trans_type#&RID=#LRID#" ADDTOKEN="No">
	</CFIF>
	</CFOUTPUT>

	<CFIF form.category EQ	'Distributor'>
		<CFLOCATION URL="Distributor_Bank_Info.cfm" ADDTOKEN="No">
	<CFELSEIF form.category EQ	'Operator'>
		<CFLOCATION URL="Operator_Bank_Info.cfm" ADDTOKEN="No">
	<CFELSEIF form.category EQ	'Broker'>
		<CFLOCATION URL="Broker_Bank_Info.cfm" ADDTOKEN="No">
	</CFIF>

	<CFABORT>
</CFIF>



</body>
</html>



