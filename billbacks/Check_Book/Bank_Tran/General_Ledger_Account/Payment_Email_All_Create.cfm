



<cfset useLakebaseForGet_All = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_data_export_1")>
<cfif useLakebaseForGet_All>
	<cftry>
		<cfset Get_All = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payment_data_export_1", {
				"paid" = "eq.0",
				"deleted" = "eq.0",
				"saved" = "eq.1",
				"order" = "pay_multi_billbacks_id.asc",
				"select" = "payment_data_export_1_id,billback_id,payment_trans_id,pay_multi_billbacks_id paymultibillbacksid"
			}), "payment_data_export_1_id,billback_id,payment_trans_id,pay_multi_billbacks_id paymultibillbacksid"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_All = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_All>
<CFQUERY NAME="Get_All" DATASOURCE="#Application.Datasource#">
	SELECT 		Payment_Data_Export_1_ID,
				Billback_ID,
				Payment_Trans_ID,
				Pay_Multi_Billbacks_ID PayMultiBillbacksID

	FROM 		Payment_Data_Export_1	

	WHERE 		Paid = 0 AND 
				Deleted=0 AND 
				Saved=1
	ORDER BY	Pay_Multi_Billbacks_ID
</CFQUERY>
</cfif>

<CFSET 	Email_All_File_Name = "">
<CFSET Count = 0>
<CFOUTPUT QUERY="Get_All">

	<CFSET URL.BBID = Billback_ID>
	<CFSET URL.Payment_Trans_ID = Payment_Trans_ID>
	<CFSET URL.Payment_Data_Export_1_ID = Payment_Data_Export_1_ID>
	<CFIF PayMultiBillbacksID NEQ "">
		<CFSET URL.Pay_Multi_Billbacks_ID = PayMultiBillbacksID>
	</CFIF>
	<CFINCLUDE TEMPLATE = "View_Edit_Approve_Content.cfm">
</CFOUTPUT>
<CFSET Num_Payment_req = Count>
<CFSET File_Name = Email_All_File_Name>
<CFINCLUDE TEMPLATE="Payment_Email_Create.cfm">
<!--- <CFOUTPUT>#Email_All_File_Name#</CFOUTPUT>	 --->
