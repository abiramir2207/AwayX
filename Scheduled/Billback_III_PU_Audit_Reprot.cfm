<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<cfparam name="ACCESSSTRUCTURE.USER_ID" 	default="0000000000">
<CFSET RunDate=now()>
<CFQUERY NAME="Upd_Header_BBCode" datasource="#application.datasource#">
	UPDATE 		Billback_Txt_Upload_Header_Log 
	SET 		BB_Code = Billback.BB_Code,
				Billback_Number = Billback.BB_Reference
	FROM 		Billback_Txt_Upload_Header_Log
	INNER JOIN 	Billback ON Billback.Billback_ID = Billback_Txt_Upload_Header_Log.Billback_ID AND 
				Billback_Txt_Upload_Header_Log.Billback_ID IS NOT NULL AND
				(Billback_Txt_Upload_Header_Log.BB_Code IS NULL OR Billback_Txt_Upload_Header_Log.Billback_Number IS NULL)
</CFQUERY>

<CFQUERY NAME="Upd_Detail_BBCode" datasource="#application.datasource#">
	UPDATE 		Billback_Txt_Upload_Detail_Log 
	SET 		BB_Code = Billback.BB_Code,
				Billback_Number = Billback.BB_Reference
	FROM 		Billback_Txt_Upload_Detail_Log
	INNER JOIN 	Billback ON Billback.Billback_ID = Billback_Txt_Upload_Detail_Log.Billback_ID AND 
				Billback_Txt_Upload_Detail_Log.Billback_ID IS NOT NULL AND
				(Billback_Txt_Upload_Detail_Log.BB_Code IS NULL OR Billback_Txt_Upload_Detail_Log.Billback_Number IS NULL)
</CFQUERY>

<CFQUERY NAME="HeaderInfo" datasource="#application.datasource#">
	SELECT	PH.Billback_Upload_III_PH_ID,CONVERT(Char(10),P.upload_date ,101) U_Created_Date,P.header_file_name as Header_File,P.Detail_File_name as Detail_File,Claim_Num,BB_Code,Claim_Org_ID,Billback_Number,
			TH.Ship_To,E_Total_Claimed_Amt,Total_Amount,'NA' Tot_Cases,CAST(Volume_Qty AS DECIMAL(20,2)) Volume_Qty,InValid,IS_Valid_CN,IS_Date_CD,IS_Date_SD,
			IS_Date_ED,IS_Date_RD,SD_GTE_ED,IS_Numeric_Amt,PH.Distributor_ID,No_Detail_Records,PH.Upload_ID
	FROM	Billback_Upload_III_PH_Log PH
			INNER JOIN BB_upload_Log P ON P.Upload_ID = PH.Upload_ID
			LEFT JOIN Billback_Txt_Upload_Header_Log TH ON TH.Upload_ID = PH.Upload_ID 
			AND TH.bb_header_id = PH.Billback_Upload_III_PH_ID 
	WHERE	PH.Audit_Report_Sent = 0 AND PH.Upload_ID IS NOT NULL
	ORDER BY U_Created_Date,PH.Upload_ID,InValid,BB_Code
</CFQUERY>



<CFQUERY NAME="DetailInfo" datasource="#application.datasource#">
	SELECT	DISTINCT PD.Billback_Upload_III_PH_ID,CONVERT(Char(10),P.upload_date,101) U_Created_Date,P.header_file_name as Header_File,P.Detail_File_name as Detail_File,Claim_Num,BB_Code,Claim_Org_ID,
			Billback_Number,TD.Ship_To,Operator_Org_ID,BSA_Operator.Legacy_ID,
			DC_AC_Name,BSA_Operator.Operator_Name,InValid,PD.Upload_ID, PD.PoP_Reason_Code
	FROM	Billback_Upload_III_PD_Log PD
			INNER JOIN BB_upload_Log P ON P.Upload_ID = PD.Upload_ID
			LEFT JOIN Billback_Txt_Upload_Detail_Log TD ON TD.Upload_ID = PD.Upload_ID
			AND TD.bb_header_id = PD.Billback_Upload_III_PH_ID 
			AND TD.bb_detail_id = PD.Billback_Upload_III_PD_ID
			LEFT JOIN BSA_Operator ON BSA_Operator.BSA_Operator_ID = PD.Operator_ID
	WHERE	PD.Audit_Report_Sent = 0 AND PD.Upload_ID IS NOT NULL
	ORDER BY U_Created_Date,PD.Upload_ID,InValid,BB_Code,TD.Ship_To

</CFQUERY>

<CFSET TotCount = 0>
<CFSET Successful = 0>
<CFSET TotAmount = 0>
<CFSET TotBAAmount = 0>
<CFSET TotCases = 0>
<CFSET Current_UploadID = 0>
<CFSET Previous_UploadID = 0>

<CFSET ClaimCount = 0>
<CFSET Current_ClaimNum = "">
<CFSET Previous_ClaimNum = "">
<CFSET Claim_TotAmt = 0>
<CFSET Claim_TotCS = 0>
<CFOUTPUT>

<CFSAVECONTENT VARIABLE="Header">
<STYLE>
TABLE.Maintable TD 
{
	border-bottom:solid 93BEE2 1px; font-size : 12px;
}
</STYLE>
<BR>
<!--- Header Report --->
<TABLE CLASS= "Maintable" border="0" ALIGN="center" CELLPADDING="1" CELLSPACING="0">
<TR>
	<TD COLSPAN="100%" ALIGN="Center" STYLE="font-size : 14px"><B>Claims Audit Report - Header</B><BR><BR>&nbsp;</TD>
</TR>
<CFLOOP QUERY = "HeaderInfo">

	<CFSET Current_UploadID = Upload_ID>
	<CFIF (Previous_UploadID NEQ 0 AND Current_UploadID NEQ Previous_UploadID)>
		<TR >
			<TD></TD>
			<TD></TD>
			<TD></TD>
			<TD></TD>
			<TD></TD>
			<TD STYLE="border-bottom:none"><B>#DollarFormat(TotAmount)#</B></TD>
			<TD STYLE="border-bottom:none"><B>#DollarFormat(TotBAAmount)#</B></TD>
			<TD></TD>
			<TD STYLE="border-bottom:none"><B>#NumberFormat(TotCases,'___,___,___,___.__')#</B></TD>
		</TR>
		<TR>
			<TD COLSPAN="100%" STYLE="border-bottom:none">
				<B>
				Total Count: #TotCount#<BR>
				Successful: #Successful#<BR>
				<CFSET Failed = TotCount - Successful>
				Failed: #Failed#
				</B>
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="100%"><BR><BR></TD>
		</TR>
	</CFIF>
	<CFIF CurrentRow EQ 1 OR (Previous_UploadID NEQ 0 AND Current_UploadID NEQ Previous_UploadID)>
		<CFSET TotCount = 0>
		<CFSET Successful = 0>
		<CFSET TotAmount = 0>
		<CFSET TotBAAmount = 0>
		<CFSET TotCases = 0>
	<TR>	
		<TD COLSPAN="6" BGCOLOR="LightsteelBlue">			
			<B>Header File:</B> #Header_File#<BR>
			<B>Detail File:</B> #Detail_File#<BR>
		</TD>	
		<TD COLSPAN="3" ALIGN="Right" BGCOLOR="LightsteelBlue">
			<B>Report Run Date:</B> #DATEFORMAT(RunDate,"mm/dd/yyyy")#<BR>
			<B>Claims Uploaded Date:</B> #U_Created_Date#<BR>
		</TD>
	</TR>
	<TR BGCOLOR="FFE083">
		<TD><B>BA Payable Num</B>&nbsp;&nbsp;</TD>
		<TD><B>Claim Num</B>&nbsp;&nbsp;</TD>	
		<TD><B>BA Billback Num</B>&nbsp;&nbsp;</TD>	
		<TD><B>Claim Org ID</B>&nbsp;&nbsp;</TD>		
		<TD><B>BA Payee ID</B>&nbsp;&nbsp;</TD>
		<TD><B>Expected Tot Claim $</B>&nbsp;&nbsp;</TD>
		<TD><B>BA $ Amount</B>&nbsp;&nbsp;</TD>
		<TD><B>Tot Cases</B>&nbsp;&nbsp;</TD>
		<TD><B>BA Cases</B>&nbsp;&nbsp;</TD>
	</TR>
	</CFIF>	
	<CFSET Current_ClaimNum = Claim_Num>
	<CFIF Previous_ClaimNum NEQ "" AND Current_ClaimNum NEQ Previous_ClaimNum>
	<TR>
		<TD></TD>
		<TD></TD>
		<TD></TD>
		<TD></TD>		
		<TD></TD>
		<TD></TD>
		<TD STYLE="border-bottom:none"><CFIF ClaimCount GT 1><B>#DollarFormat(Claim_TotAmt)#</B></CFIF>&nbsp;&nbsp;</TD>
		<TD></TD>
		<TD STYLE="border-bottom:none"><CFIF ClaimCount GT 1><B>#NumberFormat(Claim_TotCS,'___,___,___,___.__')#</B></CFIF>&nbsp;&nbsp;</TD>
	</TR>
	</CFIF>
	<CFIF BB_Code NEQ "">
		<CFSET Successful = Successful + 1>
		<CFSET TotBAAmount = TotBAAmount + VAL(Total_Amount)>
		<CFSET TotCases = TotCases + VAL(Volume_Qty)>
		<CFIF Previous_ClaimNum NEQ "" AND Current_ClaimNum NEQ Previous_ClaimNum>
			<CFSET Claim_TotAmt = 0>
			<CFSET Claim_TotCS = 0>
			<CFSET ClaimCount = 0>
		</CFIF>
		<CFSET ClaimCount = ClaimCount + 1>
		<CFSET Claim_TotAmt = Claim_TotAmt + VAL(Total_Amount)>
		<CFSET Claim_TotCS = Claim_TotCS + VAL(Volume_Qty)>
	</CFIF>

	<CFSET TotCount = TotCount + 1>
	<CFSET TotAmount = TotAmount + VAL(E_Total_Claimed_Amt)>
	
	<!---Check to see if there are any dups--->
	<cfquery name="qCheckForDup" dbtype="query">
		SELECT	* 
		FROM 	DetailInfo
		WHERE	Upload_ID = #HeaderInfo.Upload_ID#
		AND 	Billback_Upload_III_PH_ID = #HeaderInfo.Billback_Upload_III_PH_ID#
		AND		PoP_Reason_Code = 'DUP'
	</cfquery>
	
	<cfset variables.hasDups = 0 />
	
	<cfif qCheckForDup.RecordCount>
		<cfset variables.hasDups = 1 />
	</cfif>
	
	<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" <CFIF InValid EQ 1 OR BB_Code EQ "" OR variables.hasDups>STYLE = "color: Red"</CFIF>>
		<TD>#BB_Code#&nbsp;&nbsp;</TD>
		<TD>#Claim_Num#&nbsp;&nbsp;</TD>
		<TD>#Billback_Number#&nbsp;&nbsp;</TD>
		<TD>#Claim_Org_ID#&nbsp;&nbsp;</TD>		
		<TD>#Ship_To#&nbsp;&nbsp;</TD>
		<TD><cfif isNumeric(E_Total_Claimed_Amt)>#DollarFormat(E_Total_Claimed_Amt)#<cfelse>#E_Total_Claimed_Amt#</cfif>&nbsp;&nbsp;</TD>
		<TD><cfif isNumeric(Total_Amount)>#DollarFormat(Total_Amount)#<cfelse>#Total_Amount#</cfif>&nbsp;&nbsp;</TD>
		<TD>#Tot_Cases#&nbsp;&nbsp;</TD>
		<TD>#Volume_Qty#&nbsp;&nbsp;</TD>
	</TR>
	<CFSET Previous_ClaimNum = Claim_Num>
	<CFIF CurrentRow EQ RecordCount>
		<CFIF Previous_ClaimNum NEQ "" AND Current_ClaimNum EQ Previous_ClaimNum>
		<TR>
			<TD></TD>
			<TD></TD>
			<TD></TD>
			<TD></TD>		
			<TD></TD>
			<TD></TD>
			<TD STYLE="border-bottom:none"><CFIF ClaimCount GT 1><B>#DollarFormat(Claim_TotAmt)#</B></CFIF>&nbsp;&nbsp;</TD>
			<TD></TD>
			<TD STYLE="border-bottom:none"><CFIF ClaimCount GT 1><B>#NumberFormat(Claim_TotCS,'___,___,___,___.__')#</B></CFIF>&nbsp;&nbsp;</TD>
		</TR>
		</CFIF>
	<TR>
		<TD></TD>
		<TD></TD>
		<TD></TD>
		<TD></TD>
		<TD></TD>
		<TD STYLE="border-bottom:none"><B>#DollarFormat(TotAmount)#</B></TD>
		<TD STYLE="border-bottom:none"><B>#DollarFormat(TotBAAmount)#</B></TD>
		<TD></TD>
		<TD STYLE="border-bottom:none"><B>#NumberFormat(TotCases,'___,___,___,___.__')#</B></TD>
	</TR>
		<TR>
			<TD COLSPAN="100%" STYLE="border-bottom:none">
				<B>
				Total Count: #TotCount#<BR>
				Successful: #Successful#<BR>
				<CFSET Failed = TotCount - Successful>
				Failed: #Failed#
				</B>
			</TD>
		</TR>
<BR><BR>
	<!--- Ana D16058 - Error Reason Code --->
	<CFQUERY NAME="Err_Rep_Header" datasource="#application.datasource#">
		SELECT  Claim_Org_ID,
				Claim_Num,
				CASE WHEN PK_Violation <> 0 THEN 'PK' ELSE NULL END PK,
				CASE WHEN IS_Valid_CN = 0 THEN 'H2' ELSE NULL END H2,
				CASE WHEN IS_Date_CD = 0 THEN 'H11' ELSE NULL END H11,
				CASE WHEN IS_Date_SD = 0 THEN 'H13' ELSE NULL END H13,
				CASE WHEN IS_Date_ED = 0 THEN 'H14' ELSE NULL END H14,
				CASE WHEN IS_Date_RD = 0 THEN 'H15' ELSE NULL END H15,
				CASE WHEN IS_Numeric_Amt = 0 THEN 'H3' ELSE NULL END H3,
				CASE WHEN (No_Detail_Records = 1 OR InValid_Detail_Records = 1) THEN 'H16' ELSE NULL END H16,
				CASE WHEN Distributor_ID IS NULL THEN 'H7' ELSE NULL END H7,
				CASE WHEN SD_GTE_ED = 0 THEN 'H19' ELSE NULL END H19,
				Billback_Upload_III_PH_ID
		FROM 	Billback_Upload_III_PH_Log 
		WHERE 	--Upload_ID = #Current_UploadID# AND 
				Audit_Report_Sent = 0 AND Upload_ID IS NOT NULL AND Invalid = 1
		ORDER BY Upload_ID,Claim_Org_ID,Claim_Num,InValid	
	</CFQUERY>
	<CFIF Err_Rep_Header.RecordCount GT 0>
	
	<TR>
		<TD COLSPAN="100%" STYLE="border-bottom:none" STYLE="font-size : 14px" BGCOLOR="LightsteelBlue">
			<B>Invalid Records - Header</B>
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="100%" STYLE="border-bottom:none">
			<TABLE border="0" CELLPADDING="1" CELLSPACING="0">
				<TR BGCOLOR="FFE083">
					<TD><B>Claim Num</B>&nbsp;&nbsp;</TD>	
					<TD><B>Claim Org ID</B>&nbsp;&nbsp;</TD>	
					<TD><B>Error Code</B></TD>
				</TR>
				<CFLOOP QUERY = "Err_Rep_Header">
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
					<TD>#Claim_Num#&nbsp;&nbsp;</TD>	
					<TD>#Claim_Org_ID#&nbsp;&nbsp;</TD>	
					<TD>
						<CFIF PK NEQ "">#PK#<BR></CFIF>
						<CFIF H2 NEQ "">#H2#<BR></CFIF>
						<CFIF H11 NEQ "">#H11#<BR></CFIF>
						<CFIF H13 NEQ "">#H13#<BR></CFIF>
						<CFIF H14 NEQ "">#H14#<BR></CFIF>
						<CFIF H15 NEQ "">#H15#<BR></CFIF>
						<CFIF H3 NEQ "">#H3#<BR></CFIF>
						<CFIF H16 NEQ "">#H16#<BR></CFIF>
						<CFIF H7 NEQ "">#H7#<BR></CFIF>
						<CFIF H19 NEQ "">#H19#<BR></CFIF>
					</TD>
				</TR>
				</CFLOOP>
			</TABLE>
		</TD>
	</TR>
	</CFIF>
	<!--- Ana D16058 - Error Reason Code --->
	
	<CFQUERY NAME="Err_Rep_Detail" datasource="#application.datasource#">	
	SELECT Claim_Org_ID,Claim_Num,Product_Num,
		CASE WHEN IS_Valid_CN = 0 THEN 'D2' ELSE NULL END D2,
		CASE WHEN IS_Valid_CQ = 0 THEN 'D6' ELSE NULL END D6,
		CASE WHEN IS_Valid_AA = 0 THEN 'D3' ELSE NULL END D3,
		CASE WHEN Distributor_ID IS NULL THEN 'D13' ELSE NULL END D13,
		CASE WHEN Product_ID IS NULL THEN 'D4' ELSE NULL END D4
	FROM Billback_Upload_III_PD_Log 
	WHERE --Upload_ID = #Current_UploadID# AND 
			Audit_Report_Sent = 0 AND Upload_ID IS NOT NULL AND Invalid = 1
	ORDER BY Upload_ID,Claim_Org_ID,Claim_Num,InValid		
	</CFQUERY>

	<CFIF Err_Rep_Detail.RecordCount GT 0>
	
	<TR>
		<TD COLSPAN="100%" STYLE="border-bottom:none" STYLE="font-size : 14px" BGCOLOR="LightsteelBlue">
			<B>Invalid Records - Detail</B>
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="100%" STYLE="border-bottom:none" >
			<TABLE border="0" CELLPADDING="1" CELLSPACING="0">
				<TR BGCOLOR="FFE083">
					<TD><B>Claim Num</B>&nbsp;&nbsp;</TD>	
					<TD><B>Claim Org ID</B>&nbsp;&nbsp;</TD>	
					<TD><B>Error Code</B></TD>
				</TR>
				<CFLOOP QUERY = "Err_Rep_Detail">
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
					<TD>#Claim_Num#&nbsp;&nbsp;</TD>	
					<TD>#Claim_Org_ID#&nbsp;&nbsp;</TD>	
					<TD>
						<CFIF D2 NEQ "">#D2#<BR></CFIF>
						<CFIF D6 NEQ "">#D6#<BR></CFIF>
						<CFIF D3 NEQ "">#D3#<BR></CFIF>
						<CFIF D13 NEQ "">#D13# (Distributor ##: #Claim_Org_ID#)<BR></CFIF>
						<CFIF D4 NEQ "">#D4# (item ##: #Product_Num#)<BR></CFIF>						
					</TD>
				</TR>
				</CFLOOP>
			</TABLE>
		</TD>
	</TR>
	</CFIF>
	
	<CFQUERY NAME="Err_Code" datasource="#application.datasource#">
		SELECT 	Error_Code,Error_Desc,
				CASE Error_Code
					WHEN 'D2' THEN
						1
					WHEN 'D3' THEN
						2
					WHEN 'D4' THEN
						3
					WHEN 'D6' THEN
						4
					WHEN 'D13' THEN
						5
					WHEN 'H2' THEN
						6
					WHEN 'H3' THEN
						7
					WHEN 'H7' THEN
						8
					WHEN 'H11' THEN
						9
					WHEN 'H13' THEN
						10
					WHEN 'H14' THEN
						11
					WHEN 'H15' THEN
						12
					WHEN 'H16' THEN
						13
					WHEN 'H19' THEN
						14
					WHEN 'PK' THEN
						15
					ELSE
						16
					END AS tmpSort
		FROM 	BB_Upload_Error_Codes 
		WHERE	Error_Code IN ('PK','H2','H11','H13','H14','H15','H3','H16','H7','D2','D6','D3','D13','D4','H19')
		ORDER 	BY tmpSort ASC
	</CFQUERY>

	<CFIF Err_Rep_Detail.RecordCount GT 0 OR Err_Rep_Header.RecordCount GT 0>
	
	<TR>
		<TD COLSPAN="100%" STYLE="border-bottom:none" STYLE="font-size : 14px" BGCOLOR="LightsteelBlue">
			<B>Error Code and Description</B>
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="100%" STYLE="border-bottom:none">
			<TABLE border="0" CELLPADDING="1" CELLSPACING="0">
				<TR BGCOLOR="FFE083">
					<TD><B>Error Code</B></TD>
					<TD><B>Description</B></TD>
				</TR>
				<CFLOOP QUERY = "Err_Code">
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
					<TD>#Error_Code#</TD>
					<TD>#Error_Desc#</TD>
				</TR>
				</CFLOOP>
			</TABLE>
		</TD>
	</TR>
	</CFIF>
	<!--- END Ana D16058 - Error Reason Code --->		
	
	
	</CFIF>
	<CFSET Previous_UploadID = Upload_ID>
</CFLOOP>
</TABLE>
</CFSAVECONTENT>
</CFOUTPUT>


<CFSAVECONTENT VARIABLE="Detail">
<STYLE>
TABLE.Maintable TD 
{
	border-bottom:solid 93BEE2 1px; font-size : 12px;
}
</STYLE>
<BR>
<TABLE CLASS= "Maintable" border="0" ALIGN="center" CELLPADDING="1" CELLSPACING="0">
<TR>
	<TD COLSPAN="100%" ALIGN="Center" STYLE="font-size : 14px"><B>Claims Audit Report - Detail</B><BR><BR>&nbsp;</TD>
</TR>
	<CFOUTPUT QUERY = "DetailInfo" GROUP = "U_Created_Date">
	<!--- <CFIF CurrentRow EQ 1 OR (Previous_UploadID NEQ 0 AND Current_UploadID NEQ Previous_UploadID)> --->
		<CFSET TotCount = 0>
		<CFSET Successful = 0>
		<CFSET TotAmount = 0>
		<CFSET TotBAAmount = 0>
		<CFSET TotCases = 0>
		<TR>	
			<TD COLSPAN="6" BGCOLOR="LightsteelBlue">			
				<B>Header File:</B> #Header_File#<BR>
				<B>Detail File:</B> #Detail_File#<BR>
			</TD>	
			<TD COLSPAN="3" ALIGN="Right" BGCOLOR="LightsteelBlue">
				<B>Report Run Date:</B> #DATEFORMAT(RunDate,"mm/dd/yyyy")#<BR>
				<B>Claims Uploaded Date:</B> #U_Created_Date#<BR>
			</TD>
		</TR>
		<TR BGCOLOR="FFE083">
			<TD><B>BA Payable Num</B>&nbsp;&nbsp;</TD>
			<TD><B>Claim Num</B>&nbsp;&nbsp;</TD>	
			<TD><B>BA Billback Num</B>&nbsp;&nbsp;</TD>	
			<TD><B>Claim Org ID</B>&nbsp;&nbsp;</TD>		
			<TD><B>BA Payee ID</B>&nbsp;&nbsp;</TD>
			<TD><B>Operator Org ID</B>&nbsp;&nbsp;</TD>
			<TD><B>BA Legacy ID</B>&nbsp;&nbsp;</TD>
			<TD><B>DC Account Name</B>&nbsp;&nbsp;</TD>
			<TD><B>BA Operator Name</B>&nbsp;&nbsp;</TD>
		</TR>
<!--- 	</CFIF>	 --->
		<CFSET BB_Code_Count = 0>
		<CFOUTPUT GROUP = "Claim_Num">
			<CFSET BB_Code_Count = BB_Code_Count+ 1>
			<TR BGCOLOR="#IIf(BB_Code_Count Mod 2, DE('ffffff'), DE('C6FFC6'))#" <CFIF InValid EQ 1 OR BB_Code EQ "" OR trim(PoP_Reason_Code) eq 'DUP'>STYLE = "color: Red"</CFIF>>
				<TD>#BB_Code#&nbsp;&nbsp;</TD>
				<TD>#Claim_Num#&nbsp;&nbsp;</TD>
				<TD>#Billback_Number#&nbsp;&nbsp;</TD>
				<!--- <TD>#Claim_Org_ID#&nbsp;&nbsp;</TD>		
				<TD>#Ship_To#&nbsp;&nbsp;</TD>
				<TD>#Operator_Org_ID#&nbsp;&nbsp;</TD>
				<TD>#Legacy_ID#&nbsp;&nbsp;</TD>
				<TD>#DC_AC_Name#&nbsp;&nbsp;</TD>
				<TD>#Operator_Name#&nbsp;&nbsp;</TD> --->
			<!--- </TR> --->
			<CFSET Ship_to_Loop = 0>
			<CFOUTPUT GROUP = "Ship_To">
				<CFSET Ship_to_Loop = Ship_to_Loop + 1>
				
				<CFIF Ship_to_Loop GT 1>
				<TR BGCOLOR="#IIf(BB_Code_Count Mod 2, DE('ffffff'), DE('C6FFC6'))#" <CFIF InValid EQ 1 OR BB_Code EQ "" OR trim(PoP_Reason_Code) eq 'DUP'>STYLE = "color: Red"</CFIF>>
					<TD COLSPAN="3"></TD>
				</CFIF>	
					<TD>#Claim_Org_ID#&nbsp;&nbsp;</TD>		
					<TD>#Ship_To#&nbsp;&nbsp;</TD>
					<!--- <TD>#Operator_Org_ID#&nbsp;&nbsp;</TD>
					<TD>#Legacy_ID#&nbsp;&nbsp;</TD>
					<TD>#DC_AC_Name#&nbsp;&nbsp;</TD>
					<TD>#Operator_Name#&nbsp;&nbsp;</TD> --->
				<CFIF Ship_to_Loop GT 1>
				</TR></CFIF>
				<CFSET Operator_Loop = 0>
				<CFOUTPUT>
					<CFSET Operator_Loop = Operator_Loop + 1>
					<CFIF Operator_Loop GT 1>
					<TR BGCOLOR="#IIf(BB_Code_Count Mod 2, DE('ffffff'), DE('C6FFC6'))#" <CFIF InValid EQ 1 OR BB_Code EQ "" OR trim(PoP_Reason_Code) eq 'DUP'>STYLE = "color: Red"</CFIF>>
						<TD COLSPAN="5"></TD>
					</CFIF>
						<!--- <TD>#Claim_Org_ID#&nbsp;&nbsp;</TD>		
						<TD>#Ship_To#&nbsp;&nbsp;</TD> --->
						<TD>#Operator_Org_ID#&nbsp;&nbsp;</TD>
						<TD>#Legacy_ID#&nbsp;&nbsp;</TD>
						<TD>#DC_AC_Name#&nbsp;&nbsp;</TD>
						<TD>#Operator_Name#&nbsp;&nbsp;</TD>
					<CFIF Operator_Loop GT 1>	
					</TR>
					</CFIF>
				</CFOUTPUT>
			</CFOUTPUT>
		</CFOUTPUT>
	</CFOUTPUT>
</TABLE>
</CFSAVECONTENT>
<CFIF DetailInfo.RecordCount GT 0 OR HeaderInfo.RecordCount GT 0>
<CFOUTPUT>
<CFSET DateTimpStamp = "#DATEFORMAT(now(),"mm/dd/yyyy")##TIMEFORMAT(now(),"hh:mm:ss")#">
<CFSET DateTimpStamp = REPLACE(DateTimpStamp,"/","","ALL")>
<CFSET DateTimpStamp = REPLACE(DateTimpStamp,":","","ALL")>

<!--- Tim Ford - 05/06/2015: WR 49790 - 3rd Party Claims Upload - Audit Report sending to Ana Shankar and Karen Ehrlich:
	Setting variables.emailToAddress to empty string instead of hard coded email addresses --->
<cfset variables.emailToAddress = "" />

<cfquery name="qGetToAddress" datasource="#application.datasource#">
	SELECT	Send_Billback_Upload_Audit_Report_Email
	FROM	General_Settings
</cfquery>

<cfif qGetToAddress.RecordCount and len(trim(qGetToAddress.Send_Billback_Upload_Audit_Report_Email))>
	<cfset variables.emailToAddress = "#trim(qGetToAddress.Send_Billback_Upload_Audit_Report_Email)#" />
</cfif>

<cfif variables.emailToAddress neq "">
	
	<CF_Writing_Email_Attachment
	Naming_Format="Audit_Report_Header_#DateTimpStamp#"
	File_Extension="html"
	Relative_Path="\Temp_Files\Billback\"
	Output_Content="#Header#"
	addNewLine="No"
	Return_File_Name="fName1"
	Compress = "1"><!--- D33718:3rd Party Claims Upload - Audit Report  --->
	
	<CF_Writing_Email_Attachment
	Naming_Format="Audit_Report_Detail_#DateTimpStamp#"
	File_Extension="html"
	Relative_Path="\Temp_Files\Billback\"
	Output_Content="#Detail#"
	addNewLine="No"
	Return_File_Name="fName2"
	Compress= "1"><!--- D33718:3rd Party Claims Upload - Audit Report  --->
	
	<cf_EmailWrapper 
			TO = "#variables.emailToAddress#" <!--- pwietecha@bigredflame.com --->
			FROM = "support@bigreflame.com"
			SUBJECT = "3rd Party Claims Upload - Audit Report - Dated #DATEFORMAT(now(),"mm/dd/yyyy")# #TIMEFORMAT(now(),"hh:mm:ss")#"
			TYPE = "html"
			MESSAGETYPE = "1"
			generatedBy="1"
			appArea="1">
					
			<TABLE WIDTH="100%">
			<TR VALIGN="top">
			<TD>
			3rd Party Claims Upload - Audit Report - Dated #DATEFORMAT(now(),"mm/dd/yyyy")# #TIMEFORMAT(now(),"hh:mm:ss")#
			</TD>
			</TR>
			</TABLE>
		<!--- The cfmailparam IS the file being attached --->
	<!--- 	<cfmailparam file = "#TP_FN#"> --->
		<cf_EmailWrapperParam file="#fName1#" store="yes"/>
		<cf_EmailWrapperParam file="#fName2#" store="yes"/>
		
	<!--- </CFMAIL> --->
	</cf_EmailWrapper>
	
	<CFQUERY NAME="UPD_AR_Sent" datasource="#application.datasource#">
		UPDATE Billback_Upload_III_PH_Log SET Audit_report_Sent = 1, Report_FileName = 'Audit_Report_Header_#DateTimpStamp#.html'  WHERE Audit_report_Sent = 0
		UPDATE Billback_Upload_III_PD_Log SET Audit_report_Sent = 1, Report_FileName = 'Audit_Report_Detail_#DateTimpStamp#.html' WHERE Audit_report_Sent = 0
	</CFQUERY>
	
</cfif>
</CFOUTPUT>
</CFIF>

<!--- WR 50657 - Prod Event 2491 - Variable DATETIMPSTAMP is undefined: Moved this code inside the above if statement.
<cfoutput>
	<CFQUERY NAME="UPD_AR_Sent" datasource="#application.datasource#">
		UPDATE Billback_Upload_III_PH_Log SET Audit_report_Sent = 1, Report_FileName = 'Audit_Report_Header_#DateTimpStamp#.html'  WHERE Audit_report_Sent = 0
		UPDATE Billback_Upload_III_PD_Log SET Audit_report_Sent = 1, Report_FileName = 'Audit_Report_Detail_#DateTimpStamp#.html' WHERE Audit_report_Sent = 0
	</CFQUERY>
</cfoutput>
--->
</body>
</html>
