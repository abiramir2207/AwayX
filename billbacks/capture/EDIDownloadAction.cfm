<!-----------------------------------------------------------------------------

FILE NAME:		EDIDownloadAction.cfm
DESCRIPTION:	Based on the Type, this page downloads the EDI file.
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	03-Apr-2015
------------------------------------------------------------------------------>

<cfset BillbackID = FORM.BillbackID />
<cfsilent>
	<cfset PAGETITLE = "EDI Download">
	<cfinclude template="/settings/settings_title.cfm">
</cfsilent>
<cfset sFilePath= "#Application.Doc_Path#\Data_Files\Settings\Billback_Upload_Files" />
<cfset uploadUtility = CreateObject("component","components.billback.billbackuploadutility") />

<cfset uploadFilePath = uploadUtility.getUploadPath() />
<cfset BBUploadDetails = uploadUtility.getUploadDetailsOnBillbackID(billbackID = BillbackID) />

<cfif (FORM.Type EQ 2)>

	<cfif (FORM.FileTypeToGet EQ "Detail")>
		<cfset sFileName = FORM.DtlFileNameToGet />
	<cfelse>
		<cfset sFileName = FORM.HdrFileNameToGet />
	</cfif>

	<cfset PathWithFile = "#sFilePath#\#sFileName#" />
	<cfif FileExists(PathWithFile)>
		<cfheader name="Content-Disposition" value="attachment;filename=""#sFileName#"""  />
		<cfcontent file="#PathWithFile#" deletefile="no"  />
	<cfelse> 
		<div align="center"><h2><font color="##FF0000">File Not found!!</font></h2> 
		<div align="center">
		<input type="button" value="Back to Download" name="Back to Download" onclick="javascript:history.back();">
		<input type="button" value="Close Window" name="Close Window" onclick="javascript:window.close();"></div>
		<cfabort>
	</cfif>
<cfelseif (FORM.Type EQ 3)>

	<cfset DownloadFileName = "Raw_Data_" & DateFormat(now(), "mm_dd_yyyy") & ".csv" />
	<cfif (isDefined("FORM.rdoDownloadData") AND FORM.rdoDownloadData EQ 1)>
		<cfstoredproc procedure="BB_Download_III_Party" datasource="#application.datasource#">
			<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR"  dbVarName = "@Billback_ID" value="" null="yes">
			<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR"  dbVarName = "@BB_Reference" value="#FORM.BB_Reference#">
			<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR"  dbVarName = "@DL_Type" value="1">
			<cfprocresult name = qryResult>
		</cfstoredProc>
		<cfset DownloadFileName = "Raw_Data_" & DateFormat(now(), "mm_dd_yyyy") & "#BillbackID#_All.csv" />
	<cfelseif (isDefined("FORM.rdoDownloadData") AND FORM.rdoDownloadData EQ 2)>
		<cfstoredproc procedure="BB_Download_III_Party" datasource="#application.datasource#">
			<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR"  dbVarName = "@Billback_ID" value="#BillbackID#">
			<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR"  dbVarName = "@BB_Reference" value="" null="yes">
			<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR"  dbVarName = "@DL_Type" value="2">
			<cfprocresult name = qryResult>
		</cfstoredProc>
		<cfset DownloadFileName = "Raw_Data_" & DateFormat(now(), "mm_dd_yyyy") & "#BillbackID#_One.csv" />
	<cfelseif (isDefined("FORM.rdoDownloadData") AND FORM.rdoDownloadData EQ 3)>
		<cfstoredproc procedure="BB_Download_III_Party" datasource="#application.datasource#">
			<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR"  dbVarName = "@Billback_ID" value="" null="yes">
			<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR"  dbVarName = "@BB_Reference" value="#FORM.BB_Reference#">
			<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR"  dbVarName = "@DL_Type" value="3">
			<cfprocresult name = qryResult>
		</cfstoredProc>
		<cfset DownloadFileName = "Discrepancey_Report_" & DateFormat(now(), "mm_dd_yyyy") & ".csv" />
	</cfif>

	<cfset pathFileName = "#sFilePath#\" & DownloadFileName  />

	<!--- Create a STRING BUFFER to hold the output --->
	<cfset fileOutput= CreateObject("java","java.lang.StringBuffer").Init() >

	<cfif (isDefined("FORM.rdoDownloadData") AND (FORM.rdoDownloadData EQ 1 OR FORM.rdoDownloadData EQ 2))>
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
			<cfset fileOutput.append(Replace(Alias_Associated_Distributor_ID,',',' ','ALL') & ",")>
			<cfset fileOutput.append(Replace(Alias_Associated_Distributor_Name,',',' ','ALL') & ",")>
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
			<cfset fileOutput.append(Award_Amt & ",")>
			<cfset fileOutput.append(Replace(DC_Product_Desc,',',' - ','ALL') & ",")>
			<cfset fileOutput.append(Chr(13) & Chr(10))>
		</cfloop>

	<cfelseif (isDefined("FORM.rdoDownloadData") AND (FORM.rdoDownloadData EQ 3))>
		<cfset fileOutput.append("Billback_Number" & ",")>
		<cfset fileOutput.append("Billback_Date" & ",")>
		<cfset fileOutput.append("Start_Date" & ",")>
		<cfset fileOutput.append("End_Date" & ",")>
		<cfset fileOutput.append("Alias_Distributor_ID" & ",")>
		<cfset fileOutput.append("Alias_Distributor_Name" & ",")>
		<cfset fileOutput.append("Alias_Program_ID" & ",")>
		<cfset fileOutput.append("Alias_Program_Name" & ",")>
		<cfset fileOutput.append("Alias_Master_Program_Name" & ",")>
		<cfset fileOutput.append("Alias_Associated_Distributor_ID" & ",")>
		<cfset fileOutput.append("Alias_Associated_Distributor_Name" & ",")>
		<cfset fileOutput.append("EDI_Distributor_Item_ID" & ",")>
		<cfset fileOutput.append("Alias_Item_ID" & ",")>
		<cfset fileOutput.append("Alias_Item_Desc" & ",")>
		<cfset fileOutput.append("CS_QTY" & ",")>
		<cfset fileOutput.append("Amount" & ",")>
		<cfset fileOutput.append("Brand" & ",")>
		<cfset fileOutput.append("UPC_Code" & ",")>
		<cfset fileOutput.append("Package_Desc" & ",")>
		<cfset fileOutput.append("BB_Item" & ",")>
		<cfset fileOutput.append("Claimed_Cases" & ",")>
		<cfset fileOutput.append("Claimed_Rate" & ",")>
		<cfset fileOutput.append("Claimed_Amount" & ",")>
		<cfset fileOutput.append("Expected_Cases" & ",")>
		<cfset fileOutput.append("Expected_Rate" & ",")>
		<cfset fileOutput.append("Expected_Amount" & ",")>
	 	<cfset fileOutput.append(Chr(13) & Chr(10))>

		<cfloop query="qryResult">
			<cfset fileOutput.append(Billback_Number & ",")>
			<cfset fileOutput.append("=" & '"#Billback_Date#"' & ",")>
			<cfset fileOutput.append("=" & '"#Start_Date#"' & ",")>
			<cfset fileOutput.append("=" & '"#End_Date#"' & ",")>
			<cfset fileOutput.append(Alias_Distributor_ID & ",")>
			<cfset fileOutput.append(Replace(Alias_Distributor_Name,',',' ','ALL') & ",")>
			<cfset fileOutput.append(Alias_Program_ID & ",")>
			<cfset fileOutput.append(Replace(Alias_Program_Name,',',' ','ALL') & ",")>
			<cfset fileOutput.append(Replace(Alias_Master_Program_Name,',',' ','ALL') & ",")>
			<cfset fileOutput.append(Replace(Alias_Associated_Distributor_ID,',',' ','ALL') & ",")>
			<cfset fileOutput.append(Replace(Alias_Associated_Distributor_Name,',',' ','ALL') & ",")>
			<cfset fileOutput.append(Replace(EDI_Distributor_Item_ID,',',' ','ALL') & ",")>
			<cfset fileOutput.append(Replace(Alias_Item_ID,',',' ','ALL') & ",")>
			<cfset fileOutput.append(Replace(Alias_Item_Desc,',',' ','ALL') & ",")>
			<cfset fileOutput.append(Replace(CS_QTY,',',' ','ALL') & ",")>
			<cfset fileOutput.append(Replace("$#Amount#",',',' ','ALL') & ",")>
			<cfset fileOutput.append(Replace(Brand,',',' ','ALL') & ",")>
			<cfset fileOutput.append(Replace(UPC_Code,',',' ','ALL') & ",")>
			<cfset fileOutput.append(Replace(Package_Desc,',',' ','ALL') & ",")>
			<cfset fileOutput.append("=" & '"#BB_Item#"' & ",")>
			<cfset fileOutput.append(Replace(Claimed_Cases,',',' ','ALL') & ",")>
			<cfset fileOutput.append(Replace(Claimed_Rate,',',' ','ALL') & ",")>
			<cfset fileOutput.append(Replace(Claimed_Amount,',',' ','ALL') & ",")>
			<cfset fileOutput.append(Replace(Expected_Cases,',',' ','ALL') & ",")>
			<cfset fileOutput.append(Replace(Expected_Rate,',',' ','ALL') & ",")>
			<cfset fileOutput.append(Replace(Expected_Amount,',',' ','ALL') & ",")>
			<cfset fileOutput.append(Chr(13) & Chr(10))>
		</cfloop>
	</cfif>

	<cffile action="write" file="#pathFileName#" output="#fileOutput.ToString()#" >
	<cfheader name="Content-Disposition" value="attachment;filename=#DownloadFileName#"  />
	<cfcontent type="application/csv" file="#pathFileName#" deletefile="no"  />
</cfif>


