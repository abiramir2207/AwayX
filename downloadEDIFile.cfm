<!-----------------------------------------------------------------------------

FILE NAME:		downloadEDIFile.cfm
DESCRIPTION:	This page downloads the EDI file based on the BB Number passed to it.
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	14-Apr-2015	

------------------------------------------------------------------------------>  

<html>
<head>
	<title>EDI File Download</title>
</head>

<body>
<cfif isDefined("URL.BBNumber") AND URL.BBNumber NEQ "">
	<cfset sFilePath= "#Application.Doc_Path#\Data_Files\Settings\Billback_Upload_Files" />
	<cfset DownloadFileName = "Raw_Data_" & DateFormat(now(), "mm_dd_yyyy") & ".csv" />	
 
	<cfstoredproc procedure="BB_Download_III_Party" datasource="#application.datasource#">
		<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR"  dbVarName = "@Billback_ID" value="" null="yes">
		<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR"  dbVarName = "@BB_Reference" value="#URL.BBNumber#">
		<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR"  dbVarName = "@DL_Type" value="1">
		<cfprocresult name = qryResult>
	</cfstoredProc>
	<cfset DownloadFileName = "Raw_Data_" & DateFormat(now(), "mm_dd_yyyy") & "#URL.BBNumber#_All.csv" />	

	
	<cfset pathFileName = "#sFilePath#\" & DownloadFileName  />

	<!--- Create a STRING BUFFER to hold the output --->
	<cfset fileOutput= CreateObject("java","java.lang.StringBuffer").Init() >

	
	<cfset fileOutput.append("Billback_Number" & ",")>
	<cfset fileOutput.append("Billback_Date" & ",")>
	<cfset fileOutput.append("Start_Date" & ",")>
	<cfset fileOutput.append("End_Date" & ",")>
	<cfset fileOutput.append("Alias_Program_ID" & ",")>
	<cfset fileOutput.append("Alias_Program_Name" & ",")>
	<cfset fileOutput.append("Alias_Associated_Distributor_ID" & ",")>
	<cfset fileOutput.append("Alias_Associated_Distributor_Name" & ",")>
	<cfset fileOutput.append("Alias_Distributor_ID" & ",")>
	<cfset fileOutput.append("Alias_Distributor_Name" & ",")>
	<cfset fileOutput.append("Shipto_Location_Name" & ",")>
	<cfset fileOutput.append("Shipto_Location_ID" & ",")>
	<cfset fileOutput.append("Shipto_Location_Address" & ",")>
	<cfset fileOutput.append("Shipto_Location_City" & ",")>
	<cfset fileOutput.append("Shipto_Location_State" & ",")>
	<cfset fileOutput.append("Shipto_Location_Zip" & ",")>
	<cfset fileOutput.append("Qty_Sold" & ",")>
	<cfset fileOutput.append("UPC_CODE" & ",")>
	<cfset fileOutput.append("Manufacture_Item_ID" & ",")>
	<cfset fileOutput.append("DC_Product_Num" & ",")>
	<cfset fileOutput.append("Award_Amt" & ",")>
	<cfset fileOutput.append("DC_Product_Desc" & ",")>
 	<cfset fileOutput.append(Chr(13) & Chr(10))>
	
	<cfloop query="qryResult">
		<cfset fileOutput.append(Billback_Number & ",")>
		<cfset fileOutput.append(Billback_Date & ",")>
		<cfset fileOutput.append(Start_Date & ",")>
		<cfset fileOutput.append(End_Date & ",")>
		<cfset fileOutput.append(Alias_Program_ID & ",")>
		<cfset fileOutput.append(Replace(Alias_Program_Name,',',' ','ALL') & ",")>
		<cfset fileOutput.append(Alias_Associated_Distributor_ID & ",")>
		<cfset fileOutput.append(Alias_Associated_Distributor_Name & ",")>
		<cfset fileOutput.append(Alias_Distributor_ID & ",")>
		<cfset fileOutput.append(Replace(Alias_Distributor_Name,',',' ','ALL') & ",")>
		<cfset fileOutput.append(Replace(Shipto_Location_Name,',',' - ','ALL') & ",")>
		<cfset fileOutput.append(Shipto_Location_ID & ",")>
		<cfset fileOutput.append(Replace(Shipto_Location_Address,',',' - ','ALL') & ",")>
		<cfset fileOutput.append(Shipto_Location_City & ",")>
		<cfset fileOutput.append(Shipto_Location_State & ",")>
		<cfset fileOutput.append(Shipto_Location_Zip & ",")>
		<cfset fileOutput.append(Qty_Sold & ",")>
		<cfset fileOutput.append(UPC_CODE & ",")>
		<cfset fileOutput.append(Manufacture_Item_ID & ",")>
		<cfset fileOutput.append(Replace(DC_Product_Num,',',' - ','ALL') & ",")>
		<cfset fileOutput.append("$#Award_Amt#" & ",")>
		<cfset fileOutput.append(Replace(DC_Product_Desc,',',' - ','ALL') & ",")>
		<cfset fileOutput.append(Chr(13) & Chr(10))>
	</cfloop>
	
	<cffile action="write" file="#pathFileName#" output="#fileOutput.ToString()#" >
	<cfheader name="Content-Disposition" value="attachment;filename=#DownloadFileName#"  />
	<cfcontent type="application/csv" file="#pathFileName#" deletefile="no"  />
<cfelse>
	<div align="center"><strong><font color="red">Error! Invalid parameters passed.</font></strong></div>
</cfif>	
 </body>
</html>
