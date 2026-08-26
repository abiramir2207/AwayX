<!----- Get_Payment_Next_Page.cfm ---->
<CFSET ActionPage = "/Billbacks/Check_Book/trans_create1.cfm">
<CFIF application.returned_customer_setting.Show_Fund_Settings EQ 1 AND application.returned_customer_setting.Upload_GL_Code EQ 1>		
	<CFIF IsDefined("Deduction_ID")>
		<CFSET ActionPage = "/GL_Code/Gl_Code_In_Billback/Allocation.cfm?Deduction_ID=#Deduction_ID#">
	<CFELSE>
		<CFSET ActionPage = "/GL_Code/Gl_Code_In_Billback/Allocation.cfm">
	</CFIF>		
<CFELSEIF appSettings.getSettlement_SAP_Business()>
	<CFSET ActionPage = "SAP_Settlement_PayReq.cfm">
<CFELSEIF appSettings.getVendor_Selection_Pay_Req() EQ 1>
	<CFSET ActionPage = "/GL_Code/Gl_Code_In_Billback/Payment_Request/Allocation_Completed.cfm">
<CFELSEIF appSettings.getBillback_Payment_Request_Without_Vendor_Selection() EQ 1>
	<CFSET ActionPage = "Payment_Processing_No_Vendor.cfm">
</CFIF>
