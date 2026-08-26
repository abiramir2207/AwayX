<cfset application.returned_customer_setting.PayBy_awayX = 0 /><!--- D8914 Payby_awayX  Get rid of the switch  --->
<CFDUMP var="#URL#">


<!--- 
	The save process first retrieves the las transaction
	and collects the balance as of that transaction.
	To calculate the balance as of this transaction,
	adds the collected balance to the amount being entered
 --->
<!--- Delete the previous entry if is not paid  --->
<CFQUERY name = "check_previous" datasource = "#Application.datasource#">
	SELECT Ledger_ID,Amount,Paid FROM Ledger_Table where Ledger_ID = (SELECT max(Ledger_ID) FROM Ledger_Table)
</CFQUERY>
<CFOUTPUT>
<CFIF check_previous.recordcount GT 0>
<CFIF check_previous.paid NEQ 1 and check_previous.Amount LT 0>
	<CFQUERY name = "delete_unpaid" datasource = "#Application.datasource#">
		DELETE from Ledger_Table where Ledger_ID = #check_previous.ledger_ID# 
	</CFQUERY>
</CFIF>
</CFIF>
</CFOUTPUT> 


<CFTRANSACTION ACTION="BEGIN">

<CFIF (isdefined("URL.BBID") OR IsDefined("URL.Pay_Multi_Billbacks_ID")) AND application.returned_customer_setting.PayBy_awayX EQ 0>
<CFOUTPUT>
	<CFIF IsDefined("URL.BBID")>
		<!--- 
			D49105: Can't mark claim as Paid - Element BB_REFERENCE is undefined in URL/Anand Rao/31-Mar-2015 
		--->		
		<cfif NOT isDefined("URL.BB_Reference")>
			<cfquery name = "BBInfo" datasource = "#Application.datasource#">
				SELECT TOP 1 BB_Reference FROM Billback WHERE Billback_ID = '#URL.BBID#'
			</cfquery>
			<cfset URL.BB_Reference = BBInfo.BB_Reference />
		</cfif>		

		<CFSET Memo_Field="Billback (Billback Number:#URL.BB_Reference#) to be paid to #trim(URL.name)#, #trim(URL.city)#, #trim(URL.state)# for the period #dateformat(URL.st_date,"m/d/yyyy")# to #dateformat(URL.end_dt,"m/d/yyy")#">
	</CFIF>
	<CFSET Signed_Amount = URL.Amount>

	<CFQUERY NAME="Save_Data" DATASOURCE="#application.datasource#">
		Insert into Ledger_Table
			(	Billback_ID,
				Memo_Field,
				Pay_Multi_Billbacks_ID,
				Amount,				
				Date_Time,
				User_ID,				
				curr_symbol
						)
		Values
			(	<CFIF IsDefined("URL.BBID")>
				'#URL.BBID#',
				'#Memo_Field#',
				NULL,
				<CFELSE>
				NULL,
				NULL,
				'#URL.Pay_Multi_Billbacks_ID#',
				</CFIF>
				#Signed_Amount#,				
				#now()#,
				'#request.AccessStructure.User_ID#',				
				'US'
						)
	</CFQUERY>
</CFOUTPUT>

<CFELSE>
	<!--- Get the balance as of the last transaction ---> 
	<CFQUERY NAME="Get_Balance" DATASOURCE="#application.datasource#">
		Select		Balance
		From		Ledger_Table
		Where		Ledger_ID = (Select max(Ledger_ID) from Ledger_Table)
	</CFQUERY> 
	<CFSET form.amount = form.amount*1000>
	<CFSET form.amount = Round(form.amount)>
	<CFSET form.amount = form.amount / 1000>
	
	<!--- Get the exchange rate --->
	<CFIF form.currency NEQ "US">
		<CFQUERY NAME="Ex_Rate" DATASOURCE="#application.datasource#">
			SELECT round(avg(comm_last),3) Rate1 FROM commodities WHERE 
			comm_symbol = '#form.currency#' AND comm_datetime = (select max(comm_datetime) from commodities)
		</CFQUERY>
	
		<CFSET rate = Ex_rate.rate1 * form.amount>
		
		<CFSET rounded =rate*1000>
		<CFSET rounded = Round(rounded)>
		<CFSET rounded = rounded / 1000>
		
		<!--- <CFOUTPUT>#Ex_Rate.rate#</CFOUTPUT> --->
		<CFIF form.trans_type EQ "check">
		
			<CFSET signed_amount = - rounded>
		<CFELSE>
			<CFSET signed_amount = rounded>
		</CFIF>
		<!--- <cfoutput>#SIGNED_AMOUNT#</cfoutput> --->
	<CFELSE>
		<CFIF form.trans_type EQ "check">
		
			<CFSET signed_amount = - form.amount>
		<CFELSE>
			<CFSET signed_amount = form.amount>
		</CFIF>
	
	</CFIF>
	
	<CFIF Get_Balance.Balance EQ "">
	<CFSET newbalance = signed_amount>
	<CFELSE>
	<CFSET newbalance = Get_Balance.Balance + signed_amount>
	</CFIF> 
	
	
	
	<!--- Calculate the new balance --->
	<!--- <CFSET newbalance = Get_Balance.Balance + signed_amount> --->
	
	<CFIF form.new_bb_check EQ 1>
	<!--- Insert values if it is from BB_approved--->
	<CFQUERY NAME="Save_Data" DATASOURCE="#application.datasource#">
		Insert into Ledger_Table
			(	Billback_ID,
				Amount,
				Memo_Field,
				Balance,
				Date_Time,
				User_ID,
				<CFIF "#form.amt_deviation_reason#" NEQ "">
				Amt_Deviation_reason,
				App_Amount,
				</CFIF>
				curr_symbol
						)
		Values
			(	'#form.billback_id#',
				#signed_amount#,
				'#Memo_Field#',
				#newbalance#,
				#now()#,
				'#User_ID#',
				<CFIF "#form.amt_deviation_reason#" NEQ "">
				'#form.amt_deviation_reason#',
				'#form.App_Amount#',
				</CFIF>
				'#form.currency#'
						)
	</CFQUERY>
	<CFELSE>
	<CFQUERY NAME = "Curr_Name" DATASOURCE="#application.datasource#">
		SELECT Symbol_Description FROM commodities_symbol WHERE symbol='#form.currency#'
	</CFQUERY>
	
	<!--- Insert values if it is not from BB_Approved --->
	 	<CFQUERY NAME = "sava_data1" DATASOURCE="#application.datasource#">
			INSERT into Ledger_Table 
			(
				Amount,
				Memo_Field,
				Balance,
				Date_Time,
				User_ID,
				<CFIF "#form.currency#" NEQ "US">
				foreign_curr_amount,
				Ex_Rate,
				</CFIF>
				curr_symbol
							)
			values 
			(	#signed_amount#,
				'#Memo_Field# <CFIF "#form.currency#" NEQ "US">(Currency : #trim(Curr_Name.Symbol_Description)#, Amount : #trim(form.amount)#, Exchange_Rate : #trim(Ex_rate.rate1)#)</CFIF>',
				#newbalance#,
				#now()#,
				'#User_ID#',
				<CFIF "#form.currency#" NEQ "US">
				'#form.amount#',
				#Ex_rate.rate1#,
				</CFIF>
				'#form.currency#'
				)
		</CFQUERY>
	
	</CFIF>
	<CFIF #form.Trans_Type# EQ "deposit">
	<CFLOCATION URL="index.cfm" addtoken="no"> 
	</CFIF>

</CFIF>




<!--- select the latest RID and relocate --->
<CFIF (isdefined("URL.BBID") OR IsDefined("URL.Pay_Multi_Billbacks_ID")) AND application.returned_customer_setting.PayBy_awayX EQ 0>
	<CFIF isdefined("URL.BBID")>
		<CFQUERY name = "select_rid" datasource = "#application.datasource#">
			select MAX(ledger_ID) RID from ledger_table WHERE Billback_ID=<CFOUTPUT>'#URL.BBID#'</CFOUTPUT>
		</CFQUERY>	
	<CFELSE>
		<CFQUERY name = "select_rid" datasource = "#application.datasource#">
			select MAX(ledger_ID) RID from ledger_table WHERE Pay_Multi_Billbacks_ID=<CFOUTPUT>'#URL.Pay_Multi_Billbacks_ID#'</CFOUTPUT>
		</CFQUERY>	
	</CFIF>
<CFELSE>
	<CFQUERY name = "select_rid" datasource = "#application.datasource#">
		select max(ledger_ID) RID from ledger_table
	</CFQUERY>
</CFIF>

<CFTRANSACTION action = "commit">
</CFTRANSACTION>

<!--- <CFOUTPUT>
#form.Trans_Mode#
#form.Trans_Type#
</CFOUTPUT> --->
 <CFOUTPUT>

<CFIF (isdefined("URL.BBID") OR IsDefined("URL.Pay_Multi_Billbacks_ID")) AND application.returned_customer_setting.PayBy_awayX EQ 0>
		<CFLOCATION URL="Bank_Tran/Payment_Transaction_data_entry.cfm?new_bb_check=1&Trans_type=1&RID=#select_rid.RID#" ADDTOKEN="No">	
<CFELSE>
	<CFIF #form.Trans_Mode# EQ "1" and #form.Trans_Type# EQ "check"> 
	<CFLOCATION URL="Bank_Tran/Payment_Transaction_data_entry.cfm?new_bb_check=#form.new_bb_check#&Trans_type=1&RID=#select_rid.RID#" ADDTOKEN="No">
	<CFELSEIF #form.Trans_Mode# EQ "0" and #form.Trans_Type# EQ "check">
	<CFLOCATION URL="Bank_Tran/Payment_Transaction_data_entry.cfm?new_bb_check=#form.new_bb_check#&Trans_type=0&RID=#select_rid.RID#" ADDTOKEN="No">
	</CFIF>
</CFIF>
</CFOUTPUT>

 