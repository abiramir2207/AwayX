<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\settings\Upload_Billback_Utility\downloadReport.cfm
      Date:     22-Jan-2019
      Author:   Anand Rao
      Purpose:  Download files for the Error Report

      Notes:

----------------------------------------------------------------------------------------------------------------------->

<cfparam name="url.upload_id" default="-2">

<!--- Initiate the CFC --->
	<cfset uploadUtility = CreateObject("component","components.billback.billbackuploadutility") />
	<cfset getReportData = uploadUtility.getUploadHeaderDtlDownloadLog(url.upload_id) />
	<cfset DownloadFileName = "Download_Errors_" & DateFormat(now(), "mm_dd_yyyy") & ".csv" />	
	<cfset pathFileName = "#Application.Doc_Path#\Data_Files\Created\settings\HOLDING_PEN\Download\" & DownloadFileName  />

 <!--- Create a STRING BUFFER to hold the output --->
	<cfset fileOutput= CreateObject("java","java.lang.StringBuffer").Init() >
		
	<cfset fileOutput.append("BB_Header_id" & ",")>	
	<cfset fileOutput.append("BB_Detail_id" & ",")>
	<cfset fileOutput.append("Vendor" & ",")>
	<cfset fileOutput.append("Customer_Reference" & ",")>
	<cfset fileOutput.append("Total_Amount" & ",")>
	<cfset fileOutput.append("Volume_Qty" & ",")>
	<cfset fileOutput.append("Payee_Type" & ",")>
	<cfset fileOutput.append("Distributor_ID" & ",")>
	<cfset fileOutput.append("Operator_ID" & ",")>
	<cfset fileOutput.append("Billback_Title" & ",")>
	<cfset fileOutput.append("Closing_Method" & ",")>
	<cfset fileOutput.append("Billback_Date" & ",")>
	<cfset fileOutput.append("Receipt_Date" & ",")>
	<cfset fileOutput.append("BB_Start_Date" & ",")>
	<cfset fileOutput.append("BB_End_Date" & ",")>
	<cfset fileOutput.append("Postmark_Date" & ",")>
	<cfset fileOutput.append("Reference_Num" & ",")>
	<cfset fileOutput.append("Header_Err_Msg" & ",")>
	<cfset fileOutput.append("Vendor" & ",")>
	<cfset fileOutput.append("Customer_Reference" & ",")>
	<cfset fileOutput.append("Item_Number" & ",")>
	<cfset fileOutput.append("Program_Number" & ",")>
	<cfset fileOutput.append("Item_Vol_Qty" & ",")>
	<cfset fileOutput.append("Item_Amount" & ",")>
	<cfset fileOutput.append("Discount_Type" & ",")>
	<cfset fileOutput.append("Component_Name" & ",")>
	<cfset fileOutput.append("Distributor_ID" & ",")>
	<cfset fileOutput.append("Operator_Legacy_ID" & ",")>
	<cfset fileOutput.append("Detail_Err_Msg")>
 	<cfset fileOutput.append(Chr(13) & Chr(10))>

	<!--- detail row: loop through the query, and append the records to the buffer	--->
	<cfloop query="getReportData">
		<cfset fileOutput.append(BB_Header_id & ",")>	
		<cfset fileOutput.append(BB_Detail_id & ",")>	
		<cfset fileOutput.append(Vendor & ",")>	
		<cfset fileOutput.append(Customer_Reference & ",")>	
		<cfset fileOutput.append(Total_Amount & ",")>	
		<cfset fileOutput.append(Volume_Qty & ",")>	
		<cfset fileOutput.append(Payee_Type & ",")>	
		<cfset fileOutput.append(Distributor_ID & ",")>	
		<cfset fileOutput.append(Operator_ID & ",")>	
		<cfset fileOutput.append(Billback_Title & ",")>	
		<cfset fileOutput.append(Closing_Method & ",")>	
		<cfset fileOutput.append("=" & '"#Billback_Date#"' & ",")>	
		<cfset fileOutput.append("=" & '"#Receipt_Date#"' & ",")>	
		<cfset fileOutput.append("=" & '"#BB_Start_Date#"' & ",")>	
		<cfset fileOutput.append("=" & '"#BB_End_Date#"' & ",")>	
		<cfset fileOutput.append("=" & '"#Postmark_Date#"' & ",")>	
		<cfset fileOutput.append(Reference_Num & ",")>	
		<cfset fileOutput.append(Replace(Header_Err_Msg,',','','ALL') & ",")>	
		<cfset fileOutput.append(Vendor & ",")>	
		<cfset fileOutput.append(Customer_Reference & ",")>	
		<cfset fileOutput.append(Item_Number & ",")>	
		<cfset fileOutput.append(Program_Number & ",")>	
		<cfset fileOutput.append(Item_Vol_Qty & ",")>	
		<cfset fileOutput.append(Item_Amount & ",")>	
		<cfset fileOutput.append(Discount_Type & ",")>	
		<cfset fileOutput.append(Component_Name & ",")>	
		<cfset fileOutput.append(Distributor_ID & ",")>	
		<cfset fileOutput.append(Operator_Legacy_ID & ",")>	
		<cfset fileOutput.append(Replace(Detail_Err_Msg,',','','ALL') & ",")>
		<cfset fileOutput.append(Chr(13) & Chr(10))>
	</cfloop>

	
	<cffile action="write" file="#pathFileName#" output="#fileOutput.ToString()#" >
	<cflocation URL="/getDocument.cfm?filePath=#pathFileName#" />
