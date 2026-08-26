<!--- <cfset ProgramNumber = "'529','531','1023','530','532','909'">
<cfset DistributorNumber = "e95e32f4-1402-46a5-98f2-1a053b6c503f">
<cfset StartDate = "01-Apr-03">
<cfset EndDate = "06-Apr-03"> --->

<CFIF IsDefined("ProgramNumber")>
	<Cfset ContractMainList = ProgramNumber>
</CFIF>

<cfquery name="GetInvoices" datasource="#application.datasource#">
SELECT isnull(SUM(cast(Invoice_Detail.Pounds_Invoiced as float)), 0) AS Total_Pounds, isnull(SUM(cast(Invoice_Detail.Cases_Invoiced as float)), 0) AS Total_Cases 
FROM Invoice_Header
	INNER JOIN Invoice_Detail ON 
		Invoice_Header.Invoice_Header_ID = Invoice_Detail.Invoice_Header_ID
WHERE Invoice_Detail.BSA_Foodservice_Items_Master_ID IN 
	(
		SELECT DISTINCT Contract_Products.BSA_Foodservice_Items_Master_ID
		FROM  Contract_Products
		WHERE Contract_Products.Contract_Main_ID  IN (#preservesinglequotes(ContractMainList)#)
		AND Contract_Products.Deleted = 0
	)
AND Invoice_Header.BSA_Foodservice_Customers_ID = '#DistributorNumber#' 
AND 

(	Invoice_Header.Invoice_Date >= '#dateformat(StartDate)#'
	AND
	Invoice_Header.Invoice_Date <= '#dateformat(EndDate)#'
)

AND Invoice_Header.Deleted = 0
AND Invoice_Detail.Deleted = 0
<!--- AND Invoice_Header.Order_Status = 'I' --->
</cfquery>

<cfoutput>
<cfif GetProgramNumber.Contract_Quantity GT 0>
	<cfif UOM IS 1>
		<cfset PercentVolumeCompleted = (GetInvoices.Total_Cases / GetProgramNumber.Contract_Quantity) * 100>
	<cfelse>
		<cfset PercentVolumeCompleted = (GetInvoices.Total_Pounds / GetProgramNumber.Contract_Quantity) * 100>
	</cfif>
<cfelse>
	<cfset PercentVolumeCompleted = 100>
</cfif>
		
</cfoutput>