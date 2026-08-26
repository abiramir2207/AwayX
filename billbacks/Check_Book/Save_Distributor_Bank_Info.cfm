<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<CFIF 	trim(Form.Customer_ID) EQ "" OR trim(Form.Customer_ID) EQ 0 OR 
		trim(Form.Customer_Account_No) EQ "" OR trim(Form.Customer_Account_No) EQ 0 OR		
		trim(Form.Customer_Transit_Routing_No) EQ "" OR trim(Form.Customer_Transit_Routing_No) EQ 0 OR
		trim(Form.Customer_Bank_Name) EQ "" OR trim(Form.Customer_Bank_Name) EQ 0 OR
		trim(Form.Customer_Bank_Address) EQ "" OR trim(Form.Customer_Bank_Address) EQ 0	OR	
		trim(Form.Customer_Bank_City) EQ "" OR trim(Form.Customer_Bank_City) EQ 0 OR		
		trim(Form.Customer_Bank_Statecode) EQ "" OR trim(Form.Customer_Bank_Statecode) EQ 0	OR	
		trim(Form.Customer_Bank_Zipcode) EQ "" OR trim(Form.Customer_Bank_Zipcode) EQ 0	>
		
	<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 0000);</SCRIPT> 
	<CFABORT>
</CFIF>



<CFOUTPUT>
Bank_Info_ID: #Form.Bank_Info_ID#
Customer_ID: #Form.Customer_ID#
Customer_Transit_Routing_No: #Form.Customer_Transit_Routing_No#
Customer_Bank_Name: #Form.Customer_Bank_Name#
Customer_Bank_Address: #Form.Customer_Bank_Address#
Customer_Bank_City: #Form.Customer_Bank_City#
Customer_Bank_Statecode: #Form.Customer_Bank_Statecode#
Customer_Bank_Zipcode: #Form.Customer_Bank_Zipcode#
Customer_Account_No: #Form.Customer_Account_No#
Category: #Form.Category#
Bank_Info_Deleted: #Form.Bank_Info_Deleted#
</CFOUTPUT>


</body>
</html>
