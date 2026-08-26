<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<CFOUTPUT>#application.returned_customer_setting.Show_BB_Payment_GLCode#----</CFOUTPUT>
<CFDUMP VAR="#URL#">

<CFIF IsDefined("URL.Pay_Multi_Billbacks_ID")>
	<CFQUERY NAME="Delete_Old_Entry" DATASOURCE="#Application.Datasource#">
		UPDATE Payment_Data_Export_1 SET Deleted=1 WHERE Pay_Multi_Billbacks_ID = <CFOUTPUT>'#URL.Pay_Multi_Billbacks_ID#'</CFOUTPUT> AND Deleted=0	
	</CFQUERY>
<CFELSE>
	<CFQUERY NAME="Delete_Old_Entry" DATASOURCE="#Application.Datasource#">
		UPDATE Payment_Data_Export_1 SET Deleted=1 WHERE Billback_ID = <CFOUTPUT>'#URL.BBID#'</CFOUTPUT> AND Deleted=0	
	</CFQUERY>
</CFIF>	


<CFIF IsDefined("URL.Pay_Multi_Billbacks_ID")>
	<cfset useLakebaseForGetAllMultiPRBB = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pay_multi_billbacks_list")>
<cfif useLakebaseForGetAllMultiPRBB>
	<cftry>
		<cfset GetAllMultiPRBB = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pay_multi_billbacks_list", {
				"pay_multi_billbacks_id" = "eq.#URL.Pay_Multi_Billbacks_ID#",
				"deleted" = "eq.0",
				"select" = "billback_id"
			}), "billback_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetAllMultiPRBB = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetAllMultiPRBB>
<CFQUERY NAME="GetAllMultiPRBB" DATASOURCE="#Application.Datasource#">
		SELECT 	Billback_ID 
		
		FROM 	Pay_Multi_Billbacks_List 
		
		WHERE 	Pay_Multi_Billbacks_ID = '#URL.Pay_Multi_Billbacks_ID#' AND 
				Deleted = 0
	</CFQUERY>
</cfif>
	
	<CFSET BBList = VALUELIST(GetAllMultiPRBB.Billback_ID)>	
<CFELSE>
	<CFSET BBList = URL.BBID>	
</CFIF>
<CFSET LoopCount = 0>

<CFLOOP LIST="#BBList#" INDEX="ListBBID">
	<CFSET LoopCount = LoopCount + 1>
	
	<CFIF LoopCount EQ 1>
		<CFQUERY NAME="GetBBDetails" DATASOURCE="#Application.Datasource#">
			SELECT 			BB_Reference 	BB_reference,
							Paid_Amount 	Paid_Amount,
							BB_Date 		BB_Date,
							BB_Code
			
			FROM 			Billback 
			
			INNER JOIN 		BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
			
			WHERE 			Billback.Billback_ID = '#ListBBID#' AND Deleted = 0
		</CFQUERY>
		<cfset useLakebaseForGetPayeeInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_transaction")>
<cfif useLakebaseForGetPayeeInfo>
	<cftry>
		<cfset GetPayeeInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payment_transaction", {
				"payment_trans_id" = "eq.#URL.RID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetPayeeInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetPayeeInfo>
<CFQUERY NAME="GetPayeeInfo" DATASOURCE="#Application.Datasource#">
			SELECT * FROM Payment_Transaction WHERE Payment_Trans_ID = '#URL.RID#'
		</CFQUERY>
</cfif>
		
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- Insert Data in Payment_Data_Export_1--->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		
		<CFQUERY NAME="Insert_Data" DATASOURCE="#Application.Datasource#">
			INSERT INTO Payment_Data_Export_1 	(	<CFIF Not IsDefined("Pay_Multi_Billbacks_ID")>
													Billback_ID,
													BB_Reference,
													BB_Date,	
													BB_Code,
													Tot_Amount,
													<CFELSE>
													Billback_ID,
													Tot_Amount,
													Pay_Multi_Billbacks_ID,
													</CFIF>																								
													Payment_Trans_ID,
													Customer_Name,
													Address1,
													Address2,
													City,
													State,
													Zipcode	)
		
			VALUES								(	<CFIF Not IsDefined("Pay_Multi_Billbacks_ID")>
													'#ListBBID#',	
													'#GetBBDetails.BB_reference#',
													'#GetBBDetails.BB_Date#',	
													'#GetBBDetails.BB_Code#',
													#GetBBDetails.Paid_Amount#,
													<CFELSE>
													'#ListBBID#',
													'#GetPayeeInfo.Amount#',
													'#URL.Pay_Multi_Billbacks_ID#',
													</CFIF>
													#URL.RID#,
													'#GetPayeeInfo.Payee_Name#',
													'#GetPayeeInfo.Payee_Address1#',
													'#GetPayeeInfo.Payee_Address2#',
													'#GetPayeeInfo.Payee_City#',
													'#GetPayeeInfo.Payee_State#',
													'#GetPayeeInfo.Payee_Zipcode#'		)
		</CFQUERY>
				
		<CFQUERY NAME="Get_GUID_to_Insert" DATASOURCE="#Application.Datasource#">
			SELECT 	Payment_Data_Export_1_ID	
			FROM 	PAyment_Data_Export_1 
			WHERE 	<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
						Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND			
					<CFELSE>
						Billback_ID = <CFOUTPUT>'#URL.BBID#'</CFOUTPUT> AND
					</CFIF>
					Deleted=0
		</CFQUERY>
	</CFIF>
	
	
	<CFQUERY NAME="Insert_Data" DATASOURCE="#Application.Datasource#">
		INSERT INTO Payment_Data_Export_2 		(	Payment_Data_Export_1_ID,													
													Billback_ID						)
	
		VALUES									(	'#Get_GUID_to_Insert.Payment_Data_Export_1_ID#',
													'#ListBBID#'					)	
	</CFQUERY>
	
</CFLOOP>

<CFIF IsDefined("URL.Pay_Multi_Billbacks_ID")>
	<CFLOCATION URL="View_Edit_Approve.cfm?Pay_Multi_Billbacks_ID=#Pay_Multi_Billbacks_ID#&BBID=#URL.BBID#&Payment_Data_Export_1_ID=#Get_GUID_to_Insert.Payment_Data_Export_1_ID#&GetPaymentInfo=1" ADDTOKEN="No">
<CFELSE>
	<CFOUTPUT>
	<CFLOCATION URL="View_Edit_Approve.cfm?BBID=#URL.BBID#&Payment_Data_Export_1_ID=#Get_GUID_to_Insert.Payment_Data_Export_1_ID#&GetPaymentInfo=1" ADDTOKEN="No">
	</CFOUTPUT>
</CFIF>

</body>
</html>
