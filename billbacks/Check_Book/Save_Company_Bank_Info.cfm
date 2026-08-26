<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
		DELETE FROM Company_Bank_Info  
		WHERE		Bank_Info_ID		=	#Form.Bank_Info_ID#
	</CFQUERY>
	<CFLOCATION URL="Company_Bank_Info_Form.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>



<CFIF trim(Form.Bank_Name) EQ "" OR trim(Form.Bank_Name) EQ 0 OR trim(Form.Debit_Account_No) EQ "" OR trim(Form.Debit_Account_No) EQ 0 >
	<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 0000);</SCRIPT> 
	<CFABORT>
</CFIF>

<CFIF FORM.Bank_Info_Deleted EQ 0>
	<CFQUERY NAME="update_All" DATASOURCE="#Application.Datasource#">
		UPDATE Company_Bank_Info
		SET Bank_Info_Deleted = 1
	</CFQUERY>
</CFIF>

<cfset p_key= hash("abcdefgh")>
<cf_cryp type="en" key="#p_key#" string="#form.Debit_Account_No#">
<CFSET form.Debit_Account_No = cryp.value>



<CFIF Form.Bank_Info_ID EQ "">
<!--- Insert the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		Company_Bank_Info
						(
							Bank_Name,
							Debit_Account_No,
							Bank_Info_Deleted
						)
		Values			(
							'#Form.Bank_Name#',
							'#Form.Debit_Account_No#',
							 #Form.Bank_Info_Deleted#
						)
	</CFQUERY>
	<CFIF isdefined("FORM.FromPayment")>
		<CFLOCATION URL = "Bank_Tran/Payment_Transaction_data_entry.cfm?new_bb_check=#form.new_bb_check#&Trans_type=#FORM.Trans_type#&RID=#FORM.CRID#" ADDTOKEN="No">
		<CFABORT>
	</CFIF>
	<CFLOCATION URL="Company_Bank_Info_Form.cfm" ADDTOKEN="No">
	<CFABORT>
<CFELSE>
<!--- Alow Update only to the Bank_info_deleted field --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		Company_Bank_Info
		SET 		
					
					Bank_Info_Deleted 	=	'#Form.Bank_Info_Deleted#'

		WHERE		Bank_Info_ID		=	#Form.Bank_Info_ID#
	</CFQUERY>
	<CFLOCATION URL="Company_Bank_Info_form.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>
 



</body>
</html>
