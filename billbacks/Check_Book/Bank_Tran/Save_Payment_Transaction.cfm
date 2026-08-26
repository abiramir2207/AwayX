<cfset application.returned_customer_setting.PayBy_awayX = 0 /><!--- D8914 Payby_awayX  Get rid of the switch  --->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<CFPARAM NAME="FORM.Pay_Multi_Billbacks_ID" DEFAULT="">

	<CFIF form.trans_type EQ 0>
		 <CFIF 
		 	trim(form.Payee_Name) EQ "" OR trim(form.Payee_Name) EQ 0 OR
			trim(form.Payee_Address1) EQ "" OR trim(form.Payee_Address1) EQ 0 OR
			trim(form.Payee_Account_No) EQ "" OR trim(form.Payee_Account_No) EQ 0 OR		
			trim(form.Transit_Routing_no) EQ "" OR trim(form.Transit_Routing_no) EQ 0 OR
			trim(form.Payee_Bank_Name) EQ "" OR trim(form.Payee_Bank_Name) EQ 0 OR
			trim(form.Payee_Bank_Address) EQ "" OR trim(form.Payee_Bank_Address) EQ 0		
			>
		
			<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 0000);</SCRIPT> 
			<CFABORT>		
		</CFIF>	
	<!--- <CFELSE>
		<CFIF 	
		 	trim(form.Payee_Name) EQ "" OR trim(form.Payee_Name) EQ 0 
			>
		
			<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 0000);</SCRIPT> 
			<CFABORT>		
		</CFIF>	 --->
	</CFIF>
	
	<CFIF FORM.Pay_Multi_Billbacks_ID NEQ "">
		<cfset useLakebaseForGetMultiID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pay_multi_billbacks_list")>
<cfif useLakebaseForGetMultiID>
	<cftry>
		<cfset GetMultiID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pay_multi_billbacks_list", {
				"pay_multi_billbacks_id" = "eq.#FORM.Pay_Multi_Billbacks_ID#",
				"deleted" = "eq.0",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetMultiID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetMultiID>
<CFQUERY NAME="GetMultiID" DATASOURCE="#Application.Datasource#">
			SELECT 	Top 1 * 
			FROM 	Pay_Multi_Billbacks_List
			WHERE 	Pay_Multi_Billbacks_ID = '#FORM.Pay_Multi_Billbacks_ID#' AND 
					Deleted = 0
		</CFQUERY>
</cfif>
	</CFIF>
	
<CFTRANSACTION ACTION="BEGIN">
	 <CFOUTPUT>
	 	<CFIF FORM.Billback_ID NEQ "">
		<CFQUERY NAME="Delete_redundent" DATASOURCE="#Application.Datasource#">
			DELETE FROM payment_transaction WHERE Billback_ID = '#FORM.Billback_ID#' 
			<!--- UPDATE payment_transaction SET Deleted=1 WHERE Billback_ID ='#FORM.Billback_ID#' --->
		</CFQUERY>	
		<CFELSEIF FORM.Pay_Multi_Billbacks_ID NEQ "">
			<CFQUERY NAME="Delete_redundent" DATASOURCE="#Application.Datasource#">
				DELETE FROM payment_transaction WHERE Pay_Multi_Billbacks_ID = '#FORM.Pay_Multi_Billbacks_ID#'
			</CFQUERY>
		</CFIF>
		
		 <CFQUERY name = "insert_payment_transaction" datasource="#application.datasource#"> 
			INSERT into payment_transaction
			(	Billback_ID,				
				Pay_Multi_Billbacks_ID,
				Trans_date,
				Currency,
				Amount,
				Trans_Type,
				<CFIF "#form.trans_type#" EQ 0>
				Payee_Account_No,
				</CFIF>
				Payee_Name, 
				Payee_Address1,
				PAyee_Address2,
				Payee_City,
				Payee_State,
				Payee_Zipcode,
				Payee_country_code,
	
	<!--- 		Payee_Bank_Name,
				Payee_Bank_Address,
				Payee_Bank_City,
				Payee_Bank_State,
				Payee_Bank_Zipcode,
	 --->
				Pay_By_Order_Of,
				Debit_Account_No,
				<CFIF "#form.trans_type#" EQ 0>
				Payee_Bank_Name,
				Payee_Bank_Address,
				<CFIF isdefined("form.Payee_Bank_City")>
				Payee_Bank_City,
				Payee_Bank_State,
				Payee_Bank_Zipcode,
				Payee_Bank_country_code,
				</CFIF>
				Transit_Routing_no,
				</CFIF>
				note	)
			
			VALUES
			
			(
				<CFIF form.Billback_ID NEQ "">
				'#form.Billback_ID#',
				<CFELSEIF FORM.Pay_Multi_Billbacks_ID NEQ "">
				'#GetMultiID.Billback_ID#',
				<CFELSE>
				<cfqueryparam value="" null="yes">,
				</CFIF>
				'#FORM.Pay_Multi_Billbacks_ID#',	
				 getdate(),
				'#form.Currency#',
				<CFIF "#form.Amount#" NEQ "">
				'#form.Amount#',
				<CFELSE>
				'#form.foreign_amount#',
				</CFIF>
				'#form.trans_type#',
				<CFIF "#form.trans_type#" EQ 0>
				'#form.Payee_Account_No#',
				</CFIF>
				'#form.Payee_Name#', 
				'#trim(left(form.Payee_Address1, 50))#',
				'#form.Payee_Address2#',
				'#form.Payee_City#',
				'#form.Payee_State#',
				'#form.Payee_Zipcode#',
				'#form.Payee_country_code#',
				'#form.Pay_By_Order_Of#',
				'#form.Debit_Account_No#',
				<CFIF "#form.trans_type#" EQ 0>
				'#form.Payee_Bank_Name#',
				'#form.Payee_Bank_Address#',
				<CFIF isdefined("form.Payee_Bank_City")>
				'#form.Payee_Bank_City#',
				'#form.Payee_Bank_State#',
				'#form.Payee_Bank_Zipcode#',
				'#form.Payee_Bank_country_code#',
				</CFIF>
				'#form.Transit_Routing_no#',
				</CFIF>
				'#form.note#'	)			
		 </CFQUERY> 
	</CFOUTPUT>
	<CFIF form.Billback_ID NEQ "">
		<CFQUERY name = "data_ret" datasource="#application.datasource#">
			SELECT * from payment_transaction where Billback_ID=<CFOUTPUT>'#FORM.Billback_ID#'</CFOUTPUT>
		</CFQUERY>
	<CFELSEIF FORM.Pay_Multi_Billbacks_ID NEQ "">
		<CFQUERY name = "data_ret" datasource="#application.datasource#">
			SELECT * from payment_transaction where Pay_Multi_Billbacks_ID = '#FORM.Pay_Multi_Billbacks_ID#'
		</CFQUERY>
	<CFELSE>
		<CFQUERY name = "data_ret" datasource="#application.datasource#">
			SELECT * from payment_transaction where payment_trans_ID = (select max(payment_trans_ID) from payment_transaction)
		</CFQUERY>
	</CFIF>

<CFTRANSACTION action = "commit">
</CFTRANSACTION>


<CFOUTPUT>
<CFIF FORM.Category EQ "UnknownPayee">
	<cfset useLakebaseFordelete_record = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("unknownpayee_bank_info_temp")>
<cfif useLakebaseFordelete_record>
	<cftry>
		<cfset application.oLakebase.deleteRows("unknownpayee_bank_info_temp", {})>
		<cfcatch type="any">
			<cfset useLakebaseFordelete_record = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordelete_record>
<CFQUERY name = "delete_record" datasource = "#application.datasource#">
		DELETE FROM unknownpayee_bank_info_temp
	</CFQUERY>
</cfif>
</CFIF>
<CFPARAM NAME= "Billback_title" DEFAULT="">
<CFIF FORM.Billback_ID NEQ "">
	<CFSET Billback_title = 1>
</CFIF>
<CFIF application.returned_customer_setting.Customer_Keyword NEQ "conagra">
<CFIF application.returned_customer_setting.Show_BB_Payment_GLCode EQ 1>
	<CFIF application.returned_customer_setting.PayBy_awayX EQ 0 AND (FORM.Billback_ID NEQ "" OR FORM.Pay_Multi_Billbacks_ID NEQ "") AND application.returned_customer_setting.Customer_Keyword EQ "conagra">
		<CFIF FORM.Billback_ID NEQ "">
			<CFLOCATION URL="General_Ledger_Account/GL_Type_Selection.cfm?BBID=#FORM.Billback_ID#&RID=#data_ret.payment_trans_ID#&LRID=#FORM.RID#" ADDTOKEN="No">
			<!--- <CFLOCATION URL="Not_PayBy_AwayX.cfm?RID=#data_ret.payment_trans_ID#&LRID=#FORM.RID#&Billback_title=#Billback_title#" ADDTOKEN="No"> --->
		<CFELSEIF FORM.Pay_Multi_Billbacks_ID NEQ "">
			<CFLOCATION URL="General_Ledger_Account/GL_Type_Selection.cfm?BBID=#FORM.Billback_ID#&RID=#data_ret.payment_trans_ID#&Pay_Multi_Billbacks_ID=#FORM.Pay_Multi_Billbacks_ID#&LRID=#FORM.RID#" ADDTOKEN="No">
		</CFIF>
		<CFABORT>
	</CFIF>
<CFELSE>
	<CFIF application.returned_customer_setting.PayBy_awayX EQ 0 AND FORM.Billback_ID NEQ "">
		<CFLOCATION URL="General_Ledger_Account/Escape_GL_Code.cfm?BBID=#FORM.Billback_ID#&RID=#data_ret.payment_trans_ID#&LRID=#FORM.RID#" ADDTOKEN="No">		
	<CFELSEIF FORM.Pay_Multi_Billbacks_ID NEQ "">
		<CFLOCATION URL="General_Ledger_Account/Escape_GL_Code.cfm?BBID=#FORM.Billback_ID#&RID=#data_ret.payment_trans_ID#&Pay_Multi_Billbacks_ID=#FORM.Pay_Multi_Billbacks_ID#&LRID=#FORM.RID#" ADDTOKEN="No">
	</CFIF>
</CFIF>
</CFIF>
<CFLOCATION URL="Not_PayBy_AwayX.cfm?RID=#data_ret.payment_trans_ID#&LRID=#FORM.RID#&Billback_title=#Billback_title#" ADDTOKEN="No"> 
<CFABORT>
<!--- <CFIF application.returned_customer_setting.PayBy_awayX EQ 0>
	<CFLOCATION URL="Not_PayBy_AwayX.cfm?RID=#data_ret.payment_trans_ID#&LRID=#FORM.RID#&Billback_title=#Billback_title#" ADDTOKEN="No"> 
<CFELSE>
	<CFIF "#data_ret.trans_type#" EQ 1>
		 <!--- <CFSET GobackToPage = "check_transfer.cfm?RID=#data_ret.payment_trans_ID#&LRID=#FORM.RID#"> --->
	
		<CFLOCATION URL="check_transfer.cfm?RID=#data_ret.payment_trans_ID#&LRID=#FORM.RID#" ADDTOKEN="No">
		
	<CFELSEIF "#data_ret.trans_type#" EQ 0>
		<!--- <CFSET GobackToPage = "wire_transfer.cfm?RID=#data_ret.payment_trans_ID#&LRID=#FORM.RID#"> --->
		
		<CFLOCATION URL="wire_transfer.cfm?RID=#data_ret.payment_trans_ID#&LRID=#FORM.RID#" ADDTOKEN="No">
		
	</CFIF>
</CFIF> --->
</CFOUTPUT>
<!--- <CFOUTPUT>
<TABLE ALIGN="CENTER">
	<TR></TR>
	<TR></TR>
	<TR></TR>
	<TR></TR>
	<TR></TR><br>
	
	<TR>
		<TD>Payment Request fax has been sent <CFIF "#data_ret.trans_type#" EQ 0> to Bank:  <b>#FORM.Payee_Bank_Name#</b> </CFIF>
			for Amount:	<b><CFIF "#form.Amount#" NEQ "">
							#form.Amount#
						<CFELSE>
							#form.foreign_amount#
						</CFIF> 
						<CFIF FORM.currency EQ "BP">
							BRP
						<CFELSEIF FORM.Currency EQ "CD">
							CAN 
						<CFELSEIF FORM.Currency EQ "EC">
							EUR
						<CFELSE>
							USD
						</CFIF></b>in favour of Payee: <b>#FORM.Payee_Name#</b>  </TD>
	</TR>
	
</TABLE>
</CFOUTPUT>
<SCRIPT LANGUAGE="JavaScript">
function goBackToOtherPage()
{
	window.location.href = "#GobackToPage#";
}
window.setTimeout('goBackToOtherPage()', 5000);
</SCRIPT>


</CFOUTPUT> 
 ---></body>
</html>
