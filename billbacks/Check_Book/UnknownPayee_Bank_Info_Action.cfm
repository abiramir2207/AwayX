<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<CFIF isdefined("form.trans_type")>
	<CFIF form.trans_type EQ 0>

		 <CFIF 	
			trim(FORM.Payee_name) EQ "" OR trim(FORM.Payee_name) EQ 0 OR		
			trim(FORM.Address1) EQ "" OR trim(FORM.Address1) EQ 0 OR
			trim(Form.Customer_Account_No) EQ "" OR trim(Form.Customer_Account_No) EQ 0 OR		
			trim(Form.Customer_Transit_Routing_No) EQ "" OR trim(Form.Customer_Transit_Routing_No) EQ 0 OR
			trim(Form.Customer_Bank_Name) EQ "" OR trim(Form.Customer_Bank_Name) EQ 0 OR
			trim(Form.Customer_Bank_Address) EQ "" OR trim(Form.Customer_Bank_Address) EQ 0		
			>
			<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 0000);</SCRIPT> 
			<CFABORT>		
		</CFIF>
		<CFIF trim(form.Customer_Bank_Location) EQ 1>

		  	<CFIF 
			  trim(Form.Customer_Bank_City) EQ "" OR trim(Form.Customer_Bank_City) EQ 0 OR		
			  trim(Form.Customer_Bank_Statecode) EQ "" OR trim(Form.Customer_Bank_Statecode) EQ 0 OR
			  trim(Form.Customer_Bank_Zipcode) EQ "" OR trim(Form.Customer_Bank_Zipcode) EQ 0 >
			   
				  <SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 0000);</SCRIPT> 
				  <CFABORT>					 		
			</CFIF>
				
		  </CFIF>
	<CFELSE>
		 <CFIF 	
			trim(FORM.Payee_name) EQ "" OR trim(FORM.Payee_name) EQ 0 OR		
			trim(FORM.Address1) EQ "" OR trim(FORM.Address1) EQ 0 OR
			 trim(Form.City) EQ "" OR trim(Form.City) EQ 0 OR		
			  trim(Form.State_code) EQ "" OR trim(Form.State_code) EQ 0 OR
			  trim(Form.Zipcode) EQ "" OR trim(Form.Zipcode) EQ 0 
			 
			>
			<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 0000);</SCRIPT> 
			<CFABORT>		
		</CFIF>

	</CFIF>
</CFIF>
<!--- <CFIF isdefined("form.trans_type")>
	<CFIF form.trans_type EQ 0>
		 <CFIF 	
			trim(Form.Customer_Account_No) EQ "" OR trim(Form.Customer_Account_No) EQ 0 OR		
			trim(Form.Customer_Transit_Routing_No) EQ "" OR trim(Form.Customer_Transit_Routing_No) EQ 0 OR
			trim(Form.Customer_Bank_Name) EQ "" OR trim(Form.Customer_Bank_Name) EQ 0 OR
			trim(Form.Customer_Bank_Address) EQ "" OR trim(Form.Customer_Bank_Address) EQ 0		
			>
		
			<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 0000);</SCRIPT> 
			<CFABORT>		
		</CFIF>
		
	
	</CFIF>
</CFIF>
 --->

<CFOUTPUT>
<CFQUERY name = "temp_unknown" datasource = "#Application.datasource#">
	INSERT INTO UnknownPayee_Bank_Info_Temp
			(	Payee_name, 
				Address1,
				Address2,
				city,
				state_code,
				zipcode,
				Customer_Account_No,
				Customer_Transit_routing_no,
				Customer_Bank_Name,
				<CFIF isdefined("form.customer_bank_city")>
				Customer_Bank_City,
				Customer_Bank_Statecode,
				Customer_Bank_Zipcode,
				</CFIF>
				Customer_Bank_Country_Code,
				Customer_Bank_Address,
				Customer_bank_Location	)
	VALUES
			(	'#FORM.Payee_name#',
				'#FORM.Address1#',
				'#FORM.Address2#',
				'#FORM.city#',
				'#FORM.state_code#',
				'#FORM.zipcode#',
				'#FORM.Customer_Account_No#',
				'#FORM.Customer_Transit_routing_no#',
				'#FORM.Customer_Bank_Name#',
				<CFIF isdefined("form.customer_bank_city")>
				'#FORM.Customer_Bank_City#',
				'#FORM.Customer_Bank_Statecode#',
				'#FORM.Customer_Bank_Zipcode#',
				</CFIF>
				'#Form.Customer_Bank_Country_Code#',
				'#FORM.Customer_Bank_Address#',
				'#FORM.Customer_Bank_Location#'
										 )

</CFQUERY>

<CFQUERY name = "select_id" datasource = "#Application.datasource#">
	SELECT max(Unknown_Bank_ID) Bank_Info_ID from Unknownpayee_Bank_Info_Temp
</CFQUERY>

<CFLOCATION URL = "bank_tran/Payment_Transaction_data_entry.cfm?category=#form.category#&bank_info_id=#Select_id.Bank_Info_ID#&new_bb_check=#form.new_bb_check#&trans_type=#form.trans_type#&RID=#LRID#" ADDTOKEN="No">
</CFOUTPUT>
</body>
</html>
