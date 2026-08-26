<!-----------------------------------------------------------------------------

FILE NAME:		Billback_User_Dup_checker.cfm
DESCRIPTION:	This file will receive the Billback_ID and display all the duplicates
				that are in the same user Dupe group that this Billback belongs to.
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	10-Jun-2015	Added 	User Duplicate Check and display page

------------------------------------------------------------------------------> 

 
<cfset labelSettings = Createobject("component", "mvc.Models.SettingsService") />
<cfset stBBLabels = labelSettings.getBBLabels() />

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Billback - User Duplicates Checker</title>
</head>

<body>
<FONT SIZE="+1">User Duplicate Checker:</FONT><br><br>
<!--- <cfset labelSettings = Createobject("component", "components.settings.Labels.Labels") />
<cfset qBBLabels = labelSettings.getBillBackLabels() /> --->
 
		
<cfif (IsDefined("URL.Billback_ID") AND URL.Billback_ID NEQ "")>
	<cfquery name="qGetBillback" datasource="#application.datasource#">
		SELECT	BB_Code, 
				BB_Title, 
				Billback_Status_ID, 
				BB_Start_Date,
				BB_End_Date,
				BB_Amount,
				Created_Date,
				BB_Upload_Dup_Group_ID,
				BB_All_Dup_Group_ID  
		FROM	Billback
		WHERE	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#URL.Billback_ID#">
	</cfquery>
<cfelseif (IsDefined("URL.uploadID") AND URL.uploadID NEQ "" AND IsDefined("URL.bbHeaderID") AND URL.bbHeaderID NEQ "")>
	<cfquery name="qGetBillback" datasource="#application.datasource#">
		SELECT 
			BUPHL.Claim_Num,
			BUPHL.Billback_Title,
			BUPHL.E_Total_Claimed_Amt,
			BUPHL.Period_St_Date, 
			BUPHL.Period_End_Date,
			BUPHL.Vendor_Name,
			BUPHL.Vendor_ID,
			BUPHL.BB_Upload_Dup_Group_ID,
			BUPHL.BB_All_Dup_Group_ID
		FROM    
			Billback_Upload_III_PH_Log BUPHL 
		WHERE 
			BUPHL.Billback_Upload_III_PH_ID	= <cfqueryparam value="#URL.bbHeaderID#" cfsqltype="cf_sql_integer"> AND 
			BUPHL.Upload_ID = <cfqueryparam value="#URL.uploadID#" cfsqltype="cf_sql_integer"> AND 
			BUPHL.Deleted = 0 AND 
			BUPHL.InValid = 1
	</cfquery>
</cfif> <!--- END: <cfif IsDefined("URL.Billback_ID") AND URL.Billback_ID NEQ ""> --->	

	<cfif isDefined("qGetBillback") AND qGetBillback.BB_All_Dup_Group_ID NEQ "">
		<cfquery name="qGetBBDuplicate" datasource="#application.datasource#">
				SELECT	BB.BB_Code, 
						BB.BB_Title, 
						BB.Billback_Status_ID, 
						BB.BB_Start_Date,
						BB.BB_End_Date,
						BB.BB_Amount,
						BB.Created_Date,
						BB.BB_Reference,
						BB.BB_Upload_Dup_Group_ID,
						BB.BB_All_Dup_Group_ID,
						BBS.Billback_Status_ID,
						BBS.BB_Status_description
				FROM	Billback BB
				INNER JOIN Billback_status BBS ON BBS.Billback_Status_ID = BB.Billback_Status_ID
				WHERE	BB.BB_All_Dup_Group_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetBillback.BB_All_Dup_Group_ID#">
				<cfif (IsDefined("URL.Billback_ID") AND URL.Billback_ID NEQ "")>
					AND BB.Billback_ID != <cfqueryparam cfsqltype="cf_sql_varchar" value="#URL.Billback_ID#">
				</cfif>
				AND BB.Deleted = 0
				ORDER BY BB.BB_Code
		</cfquery>
		<cfquery name="qGetUploadDup" datasource="#application.datasource#">
			SELECT 
				BUPHL.Claim_Num,
				BUPHL.Billback_Title,
				BUPHL.E_Total_Claimed_Amt,
				BUPHL.Period_St_Date, 
				BUPHL.Period_End_Date,
				BUPHL.Vendor_Name,
				BUPHL.Vendor_ID ,
				BUPHL.Upload_ID,
				BUPHL.Billback_Upload_III_PH_ID
			FROM    
				Billback_Upload_III_PH_Log BUPHL 
			WHERE 
				BUPHL.BB_All_Dup_Group_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetBillback.BB_All_Dup_Group_ID#"> AND 
				BUPHL.Deleted = 0 AND 
				BUPHL.InValid = 1 
				<cfif (IsDefined("URL.uploadID") AND URL.uploadID NEQ "" AND IsDefined("URL.bbHeaderID") AND URL.bbHeaderID NEQ "")>
					AND ( (BUPHL.Upload_ID != <cfqueryparam value="#URL.uploadID#" cfsqltype="cf_sql_integer"> ) OR (BUPHL.Upload_ID = <cfqueryparam value="#URL.uploadID#" cfsqltype="cf_sql_integer">  AND BUPHL.Billback_Upload_III_PH_ID != <cfqueryparam value="#URL.bbHeaderID#" cfsqltype="cf_sql_integer">)) 
				</cfif>
		</cfquery>
		
		
		 <cfif isDefined("qGetBBDuplicate") AND qGetBBDuplicate.RecordCount GTE 1> 
		<strong> The List of <cfoutput>#stBBLabels.Billback#s</cfoutput> that have been created are:</strong>
		 	<table width="800" border="1" cellpadding="5" cellspacing="0" bordercolor="336633">
				<cfoutput>
				<tr bgcolor="FFCE84">
					<td>
						<strong>#stBBLabels.Billback#</strong>
					</td>
					<td>
						<strong>#stBBLabels.Billback# Title</strong>
					</td>
					<td>
						<strong>$ Amount</strong>
					</td>
					<td>
						<strong>#stBBLabels.Reference_Number#</strong>
					</td>
					<td>
						<strong>Start Date</strong>
					</td>
					<td>
						<strong>End Date</strong>
					</td>
					<td>
						<strong>Status</strong>
					</td>
				</tr>
				</cfoutput>
				<cfoutput query="qGetBBDuplicate">
					
					<tr>
						<td>
							#qGetBBDuplicate.BB_Code#
						</td>
						<td>
							#qGetBBDuplicate.BB_Title#
						</td>
						<td>
							#qGetBBDuplicate.BB_Amount#
						</td>
						<td>
							#qGetBBDuplicate.BB_Reference#
						</td>
						<td>
							#DateFormat(qGetBBDuplicate.BB_Start_Date,"mm/dd/yyyy")#
						</td>
						<td>
							#DateFormat(qGetBBDuplicate.BB_End_Date,"mm/dd/yyyy")#
						</td>
						<td>
							#qGetBBDuplicate.BB_Status_description#
						</td>										
					</tr>
				</cfoutput>
			</table>
		<cfelse>
		  	<br>
			<br>
			<font color="red"><strong>No Duplicates found in <cfoutput>#stBBLabels.Billback#</cfoutput>!</strong></font><br>
		</cfif> <!--- END: <cfif (isDefined("qGetBBDuplicate") AND qGetBBDuplicate.RecordCount GTE 1)> --->
		  
		<cfif isDefined("qGetUploadDup") AND qGetUploadDup.RecordCount GTE 1> 
		<br>
		<br>
		<strong>The List of Uploads that are in the corrections are:</strong>
			<table width="800" border="1" cellpadding="5" cellspacing="0" bordercolor="336633">
				<cfoutput>
					<tr bgcolor="FFCE84">
						<td>
							<strong>Upload ID</strong>
						</td>
						<td>
							<strong>Hdr. ID</strong>
						</td>
						<td>
							<strong>#stBBLabels.Billback#</strong>
						</td>
						<td>
							<strong>#stBBLabels.Billback# Title</strong>
						</td>
						<td>
							<strong>$ Amount</strong>
						</td>
						<td>
							<strong>Start Date</strong>
						</td>
						<td>
							<strong>End Date</strong>
						</td>
						<td>
							<strong>#stBBLabels.Payee#</strong>
						</td>
					</tr>
				</cfoutput>
				<cfoutput query="qGetUploadDup">
					
					<tr>
						<td>	
							#qGetUploadDup.Upload_ID#
						</td>
						<td>
							#qGetUploadDup.Billback_Upload_III_PH_ID#
						</td>
						<td>
							#qGetUploadDup.Claim_Num#
						</td>
						<td>
							#qGetUploadDup.Billback_Title#&nbsp;
						</td>
						<td>
							#qGetUploadDup.E_Total_Claimed_Amt#
						</td>
						<td>
							#DateFormat(qGetUploadDup.Period_St_Date,"mm/dd/yyyy")#
						</td>
						<td>
							#DateFormat(qGetUploadDup.Period_End_Date,"mm/dd/yyyy")#
						</td>
						<td>
							#qGetUploadDup.Vendor_Name#(#qGetUploadDup.Vendor_ID#)
						</td>										
					</tr>
				</cfoutput>
			</table>	
		  <cfelse>
		  	<br>
			<br>
			<font color="red"><strong>No Duplicates found in Upload!</strong></font><br>
		  </cfif> <!--- END:  <cfif (isDefined("qGetUploadDup") AND qGetUploadDup.RecordCount GTE 1)> --->
	<cfelse>
			<br>
			<font color="red"><strong>No Duplicates found in <cfoutput>#stBBLabels.Payee#</cfoutput>/Uploads!!</strong></font><br>	  
	</cfif> <!--- END:  <cfif (isDefined("qGetBillback") AND qGetBillback.BB_All_Dup_Group_ID NEQ "")> --->
<br>
<br>

<div align="center">
<input type="button" value="Close" onclick="window.close();" align="center">
</div>
 
 
	
	
	
	
	
	
	
