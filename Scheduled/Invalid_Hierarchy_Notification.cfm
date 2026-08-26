<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<cfparam name="ACCESSSTRUCTURE.USER_ID" 	default="0000000000">
 <cfquery name="getEmail" datasource="#application.datasource#">
	Select send_Program_Error_Ack_emailaddress
	from _application_settings
 </cfquery>
<!--- 
 <CFQUERY NAME="Partial_Ack" DATASOURCE="#Application.Datasource#">
	SELECT 		Contract_main_ID,Contract_Number,Revision_version,
				CASE WHEN (Discount_Identifier.Discount_Identifier_Number = 'ZDis' OR Discount_Identifier.Discount_Identifier_Number = 'ZNet') THEN
					'Price_Condition'
				ELSE
					'ZDeal' END Program_Type,
				REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(Char(24),Approval_Date,121),'-',''),' ',''),':',''),'.','') Approval_Date 
	FROM 		Contract_main 
	INNER JOIN 	Program_Control_Panel_Options ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
	INNER JOIN 	Discount_Identifier ON Discount_Identifier.Discount_Identifier_ID = Program_Control_Panel_Options.Discount_Identifier_ID --AND
				--Discount_Identifier.Discount_Identifier_Number IN ('ZDis','ZNet')
	WHERE 		External_Client_Error_Ack_Date IS NOT NULL AND Contract_main.Deleted = 0 AND Manual_Cancel = 0
	ORDER BY 	Program_Type,Contract_number 
 </CFQUERY>

 <CFQUERY NAME="Sent_Not_Acked" DATASOURCE="#Application.Datasource#">
	SELECT 		Contract_main_ID,Contract_Number,Revision_version,
				CASE WHEN (Discount_Identifier.Discount_Identifier_Number = 'ZDis' OR Discount_Identifier.Discount_Identifier_Number = 'ZNet') THEN
					'Price_Condition'
				ELSE
					'ZDeal' END Program_Type,
				REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(Char(24),Approval_Date,121),'-',''),' ',''),':',''),'.','') Approval_Date 
	FROM 		Contract_main 
	INNER JOIN 	Program_Control_Panel_Options ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
	INNER JOIN 	Discount_Identifier ON Discount_Identifier.Discount_Identifier_ID = Program_Control_Panel_Options.Discount_Identifier_ID --AND
				--Discount_Identifier.Discount_Identifier_Number IN ('ZDis','ZNet')
	WHERE 		Sending_To_External_Client = 1 AND Contract_main.Deleted = 0 AND Manual_Cancel = 0
	ORDER BY 	Program_Type,Contract_number 
 </CFQUERY>
 --->
 <!---TSF - Label 15303: Moved Acknowledgement queries into a Stored Procedure--->
 <cfstoredproc procedure="USP_GET_ACK_STATUS" datasource="#application.datasource#">
	
	<cfprocresult name="Partial_Ack">
	<cfprocresult name="Sent_Not_Acked" resultset="2">
	
</cfstoredproc>

<cfquery name="qInvalidHierarchy" datasource="#application.datasource#">
	Select Distinct Contract_Number 
	From  Log_Program_DONOTInterface_Prodhierarchy
	Where deleted = 0
	Group By Contract_Number,Created_Date
	Order By Contract_Number
 </cfquery>

<STYLE>
TABLE.Maintable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 12px;
}
</STYLE>
<!--- Dev Notes: Ana - 13048 - Sent the notification after an hour from the extract time --->
<cfset Any_Data_To_Email = 0 />
<cfset Send_Not_Acked = 0 />
<cfset Send_Partially_Acked = 0 />
<cfset Send_Invalid_Hierarchy = 0 />

<CFOUTPUT>
<!--- Sent Not Acked --->
<CFSAVECONTENT VARIABLE="Sent_Not_Acked_Disp">
<STYLE>
TABLE.Maintable TD 
{
	border-bottom:solid 93BEE2 1px; font-size : 12px;
}
</STYLE>
<TABLE CLASS= "Maintable" cellpadding="1" cellspacing="0" border="0" align="center">
 	<TR>
		<TD COLSPAN="100%" ALIGN="Center" STYLE="font-size : 14px"><B>Sent Not Acknowledged</B></TD>
	</TR>
 	<TR BGCOLOR="FFE083">
		<TD><B>Program Number</B>&nbsp;&nbsp;</TD>
		<TD><B>Revision</B>&nbsp;&nbsp;</TD>
		<TD><B>Program Type</B>&nbsp;&nbsp;</TD>
		<TD><B>Approved Date</B>&nbsp;&nbsp;</TD>
		<TD><B>File Name</B></TD>
	</TR>
	<CFLOOP QUERY = "Sent_Not_Acked">
	<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
		<TD>#Contract_Number#&nbsp;&nbsp;</TD>
		<TD>#Revision_version#&nbsp;&nbsp;</TD>
		<TD>#Program_Type#&nbsp;&nbsp;</TD>
		<TD>#Approval_Date#&nbsp;&nbsp;</TD>
		<!---
		<CFIF Program_Type EQ "Price_Condition">
			<CFQUERY NAME="Extract_File_Name" DATASOURCE="#Application.Datasource#">
				SELECT 	'Price_Condition_'+Program_Number+'_'+CAST(Forge_ERP_OffInvoice_Log_ID AS Varchar)+'_'+REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(Char(24),Created_Date,121),'-',''),' ',''),':',''),'.','')+'.txt' AS File_name
				FROM 	Forge_ERP_OffInvoice_Log 
				WHERE 	Program_ID = #Contract_Main_ID# AND Sent_On IS NOT NULL AND Mode <> 'N' AND 
						Mode IS NOT NULL AND DATEDIFF(hh,Sent_On,getdate()) > 1
			</CFQUERY>
		<CFELSE>
			<CFQUERY NAME="Extract_File_Name" DATASOURCE="#Application.Datasource#">
				SELECT 	CASE WHEN Mode <> 'I' THEN Deal_Change_File_Name ELSE Deal_Create_File_Name END File_Name
				FROM 	Program_ZDeal_Header 
				WHERE 	Contract_main_ID = #Contract_Main_ID# AND Mode <> 'N' AND Mode IS NOT NULL AND 
						(Deal_Change_File_Name IS NOT NULL OR Deal_Create_File_Name IS NOT NULL) AND
						DATEDIFF(hh,Created_Date,getdate()) > 1
			</CFQUERY>
		</CFIF>
		--->
		<!---TSF - Label 15303: Moved Extract File Name queries into a Stored Procedure--->
		<cfstoredproc procedure="USP_GET_EXTRACT_FILENAME" datasource="#application.datasource#">
	
			<cfprocparam type="In" cfsqltype="CF_SQL_INTEGER" variable="@@PROGRAM_ID" value="#Contract_Main_ID#" null="no" />
			<cfprocresult name="Extract_File_Name" />
	
		</cfstoredproc>
		
		<CFIF Extract_File_Name.RecordCount GT 0 AND Any_Data_To_Email EQ 0>
			<cfset Any_Data_To_Email = 1 />
			<cfset Send_Not_Acked = 1 />
		</CFIF>
		<TD>
		<CFLOOP QUERY="Extract_File_Name">#File_Name#<CFIF CurrentRow NEQ RecordCount><BR></CFIF></CFLOOP>&nbsp;&nbsp;
		</TD>
	</TR>
	</CFLOOP>
</TABLE>
</CFSAVECONTENT>
 <!--- Partially Acked --->
 <CFSAVECONTENT VARIABLE="Partially_Acked">
 <STYLE>
TABLE.Maintable TD 
{
	border-bottom:solid 93BEE2 1px; font-size : 12px;
}
</STYLE>
<TABLE CLASS= "Maintable" cellpadding="1" cellspacing="0" border="0" align="center">
 	<TR>
		<TD COLSPAN="100%" ALIGN="Center" STYLE="font-size : 14px"><B>Partically Acknowledged</B></TD>
	</TR>
 	<TR BGCOLOR="FFE083">
		<TD><B>Program Number</B>&nbsp;&nbsp;</TD>
		<TD><B>Revision</B>&nbsp;&nbsp;</TD>
		<TD><B>Program Type</B>&nbsp;&nbsp;</TD>
		<TD><B>Approved Date</B>&nbsp;&nbsp;</TD>
		<TD><B>File Name (Deal ID)</B></TD>
	</TR>
	<CFLOOP QUERY = "Partial_Ack">
	<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
		<TD>#Contract_Number#&nbsp;&nbsp;</TD>
		<TD>#Revision_version#&nbsp;&nbsp;</TD>
		<TD>#Program_Type#&nbsp;&nbsp;</TD>
		<TD>#Approval_Date#&nbsp;&nbsp;</TD>
		<!---
		<CFIF Program_Type EQ "Price_Condition">
			<CFQUERY NAME="Extract_File_Name" DATASOURCE="#Application.Datasource#">
				SELECT 	'Price_Condition_'+Program_Number+'_'+CAST(Forge_ERP_OffInvoice_Log_ID AS Varchar)+'_'+REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(Char(24),Created_Date,121),'-',''),' ',''),':',''),'.','')+'.txt' AS File_name,
						External_Client_ID
				FROM 	Forge_ERP_OffInvoice_Log 
				WHERE 	Program_ID = #Contract_Main_ID# AND Sent_On IS NOT NULL AND Mode <> 'N' AND 
						Mode IS NOT NULL AND DATEDIFF(hh,Sent_On,getdate()) > 1
			</CFQUERY>
		<CFELSE>
			<CFQUERY NAME="Extract_File_Name" DATASOURCE="#Application.Datasource#">
				SELECT 	CASE WHEN Mode <> 'I' THEN Deal_Change_File_Name ELSE Deal_Create_File_Name END File_Name,
						External_Deal_ID External_Client_ID
				FROM 	Program_ZDeal_Header WHERE Contract_main_ID = #Contract_Main_ID# AND Mode <> 'N' AND Mode IS NOT NULL AND 
						(Deal_Change_File_Name IS NOT NULL OR Deal_Create_File_Name IS NOT NULL) AND
						DATEDIFF(hh,Created_Date,getdate()) > 1
			</CFQUERY>
		</CFIF>
		--->
		<!---TSF - Label 15303: Moved Extract File Name queries into a Stored Procedure--->
		<cfstoredproc procedure="USP_GET_EXTRACT_FILENAME" datasource="#application.datasource#">
	
			<cfprocparam type="In" cfsqltype="CF_SQL_INTEGER" variable="@@PROGRAM_ID" value="#Contract_Main_ID#" null="no" />
			<cfprocresult name="Extract_File_Name" />
	
		</cfstoredproc>
		
		<CFIF Extract_File_Name.RecordCount GT 0 AND Any_Data_To_Email EQ 0>
			<cfset Any_Data_To_Email = 1 />
			<cfset Send_Partially_Acked = 1>
		</CFIF>
		<TD>
		<CFLOOP QUERY="Extract_File_Name">#File_Name# (#External_Client_ID#)<CFIF CurrentRow NEQ RecordCount><BR></CFIF></CFLOOP>&nbsp;&nbsp;
		</TD>
		
	</TR>
	</CFLOOP>
</TABLE>
</CFSAVECONTENT>

<CFSAVECONTENT VARIABLE="Invalid_Hierarchy">
<STYLE>
TABLE.Maintable TD 
{
	border-bottom:solid 93BEE2 1px; font-size : 12px;
}
</STYLE>
<table class="Maintable" cellpadding="3" cellspacing="3" border="0" align="center">
 	<tr>
		<td colspan="100%" align="Center" style="font-size : 14px;font-weight:bold">Incorrect Hierarchy Order</td>
	</tr>
	<TR BGCOLOR="FFE083">
		<TD><B>Program Number</B>&nbsp;&nbsp;</TD>
		<TD><B>Error</B>&nbsp;&nbsp;</TD>
	</TR>
     <cfif qInvalidHierarchy.RecordCount gt 0 and Any_Data_To_Email EQ 0>
	   <cfset Any_Data_To_Email = 1 />
	   <cfset Send_Invalid_Hierarchy = 1 />
	 </cfif>
	<CFLOOP QUERY = "qInvalidHierarchy">
	<tr bgcolor="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">		
		<td>#Contract_Number#</td>
		<td>Program Not Interfaced. User created program with product groups in the incorrect hierarchy order.</td>
	</tr>
	</CFLOOP>
	
</TABLE>
</CFSAVECONTENT>


<CFSET DateTimpStamp = "#DATEFORMAT(now(),"mm/dd/yyyy")##TIMEFORMAT(now(),"HH:mm:ss")#">
<CFSET DateTimpStamp = REPLACE(DateTimpStamp,"/","","ALL")>
<CFSET DateTimpStamp = REPLACE(DateTimpStamp,":","","ALL")>
<cfif Send_Not_Acked eq 1>
<CF_Writing_Email_Attachment
Naming_Format="Sent_Not_Acked_#DateTimpStamp#"
File_Extension="html"
Relative_Path="\Temp_Files\Program\"
Output_Content="#Sent_Not_Acked_Disp#"
addNewLine="No"
Return_File_Name="fName1">
</cfif>
<cfif Send_Partially_Acked eq 1>
<CF_Writing_Email_Attachment
Naming_Format="Partially_Acked_#DateTimpStamp#"
File_Extension="html"
Relative_Path="\Temp_Files\Program\"
Output_Content="#Partially_Acked#"
addNewLine="No"
Return_File_Name="fName2">
</cfif>
<cfif Send_Invalid_Hierarchy eq 1>
<CF_Writing_Email_Attachment
Naming_Format="Invalid_Hierarchy_#DateTimpStamp#"
File_Extension="html"
Relative_Path="\Temp_Files\Program\"
Output_Content="#Invalid_Hierarchy#"
addNewLine="No"
Return_File_Name="fName3">
</cfif>

<CFIF Any_Data_To_Email GT 0>
<cf_EmailWrapper 
		TO = "#getEmail.send_Program_Error_Ack_emailaddress#"<!--- pwietecha@bigredflame.com --->
		FROM = "support@bigredflame.com"
        SUBJECT = "Sent and Acked Report - Dated #DATEFORMAT(now(),"mm/dd/yyyy")# #TIMEFORMAT(now(),"HH:mm:ss")#"
		TYPE = "html"
		MESSAGETYPE = "1"
		generatedBy="1"
		appArea="1" >
				
		<TABLE WIDTH="100%">
		<TR VALIGN="top">
		<TD>
		Sent and Acked Report - Dated #DATEFORMAT(now(),"mm/dd/yyyy")# #TIMEFORMAT(now(),"HH:mm:ss")#
		</TD>
		</TR>
		</TABLE>
	<!--- The cfmailparam IS the file being attached --->
	<cfif Send_Not_Acked eq 1>
	 <cf_EmailWrapperParam file="#fName1#" store="yes"/>
	</cfif>
	<cfif Send_Partially_Acked eq 1>
	 <cf_EmailWrapperParam file="#fName2#" store="yes"/>
	</cfif>
	<cfif Send_Invalid_Hierarchy eq 1>
     <cf_EmailWrapperParam file="#fName3#" store="yes"/>
	</cfif>
</cf_EmailWrapper>
</CFIF>
</CFOUTPUT>
</body>
</html>
