<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\settings\Upload_Billback_Utility\downloadBBlist.cfm
      Date:     08-Oct-2019
      Author:   Anand Rao
      Purpose:  Download files with Billback List

      Notes:

----------------------------------------------------------------------------------------------------------------------->

<cfparam name="url.upload_id" default="0">
<cfparam name="url.uploadTypeId" default="0"> 


<!--- Initiate the CFC --->
 	<cfset uploadUtility = CreateObject("component","components.billback.billbackuploadutility") />
	<cfset getRelatedBBData = uploadUtility.getRelatedBB(URL.upload_id,URL.uploadTypeId) />
	<cfset DownloadFileName = "Download_BBList_"& URL.upload_id & "_" & DateFormat(now(), "mm_dd_yyyy") & ".csv" />	
	<cfset pathFileName = "#Application.Doc_Path#\Data_Files\Created\settings\HOLDING_PEN\Download\" & DownloadFileName  />

 <!--- Create a STRING BUFFER to hold the output --->
	<cfset fileOutput= CreateObject("java","java.lang.StringBuffer").Init() >
 		
	<cfset fileOutput.append("Deleted" & ",")>		
	<cfset fileOutput.append("Billback" & ",")>	
<!--- 	<cfset fileOutput.append("Billback_ID" & ",")> --->
	<cfset fileOutput.append("Title" & ",")>
	<cfset fileOutput.append("Billback_Number" & ",")>
	<cfset fileOutput.append("Claim_Cases" & ",")>
	<cfset fileOutput.append("BB_Amount" & ",")>	
	<cfset fileOutput.append("BB_Date" & ",")>
	<cfset fileOutput.append("Vendor_ID")>

 	<cfset fileOutput.append(Chr(13) & Chr(10))>

	<!--- 
		<cfset fileOutput.append("Deleted_By" & ",")>
		<cfset fileOutput.append("Deleted_Date")>
		<cfset fileOutput.append("BB_Start_Date" & ",")> 
	--->	
	<!--- detail row: loop through the query, and append the records to the buffer	--->
	<cfloop query="getRelatedBBData">
	
	<cfif Deleted EQ "1">
		<cfset strDeleted = "Yes" />
	<cfelse>
		<cfset strDeleted = "No" />
	</cfif>
	
		<cfset fileOutput.append(strDeleted & ",")>	
		<cfset fileOutput.append(BB_Code & ",")>	
<!--- 		<cfset fileOutput.append(Billback_ID & ",")>	 --->
		<cfset fileOutput.append(BB_Title & ",")>	
		<cfset fileOutput.append("=" & '"#BB_Reference#"' & ",")>	
		<cfset fileOutput.append(Claim_Cases & ",")>	
		<cfset fileOutput.append(BB_Amount & ",")>	
		<cfset fileOutput.append("=" & '"#BB_Date#"' & ",")>			
		<cfset fileOutput.append("=" & '"#Vendor_ID#"')>	
			
		<cfset fileOutput.append(Chr(13) & Chr(10))>
		<!--- 
				<cfset fileOutput.append(DeletedByFullName & ",")>	
		<cfset fileOutput.append("=" & '"#Deleted_Date#"')>
		<cfset fileOutput.append("=" & '"#BB_Start_Date#"' & ",")> --->
	</cfloop>
 
	<cffile action="write" file="#pathFileName#" output="#fileOutput.ToString()#" >
	<cflocation URL="/getDocument.cfm?filePath=#pathFileName#" />
