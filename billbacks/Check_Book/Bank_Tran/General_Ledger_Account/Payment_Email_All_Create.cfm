



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
