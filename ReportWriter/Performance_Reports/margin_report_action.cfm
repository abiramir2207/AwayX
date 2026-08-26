<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Margin Report</title>
<cfparam name="url.Contract_Number" default="">


</head>
<body>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset displayGroupType = genSettingsManager.getDisplayGroupType(appSettings.getViewProgramProductGroupType()) />
<cfset displayGroupTypeDesc = genSettingsManager.settings.getViewProgramProductGroupTypeDesc() />



<cfif trim(ReportType) EQ "h">
		<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
		 <br><br><br>
		 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
		 <br><br><br>
		</SPAN>
		<!--- <CFFLUSH> --->
		<SCRIPT>
		document.all.PleaseWaitMessage.style.display='none';
		</SCRIPT>
<cfelse>
<cfcontent type="application/msexcel">
 		<cfheader name="Content-Disposition" value="attachment;filename=Marginreport.xls">
</cfif>

<cfset ApprovalProgramManager = CreateObject("component","components.programs.Approval.layered_program_approval") />

<cfif report_type_id EQ 1 or report_type_id EQ 2>
	<cfset getmargins = ApprovalProgramManager.getagreedproductMargins(report_type_id,form.start_date,form.end_date)>
<cfelse>

	<cfset getgroupmargins = ApprovalProgramManager.getagreedTypecodeMargins(form.start_date,form.end_date)>

	<cfquery name="getmargins" dbtype="query">
	select *, (approved_margin - target_margin) as variance from
	getgroupmargins
	<cfif report_type_id EQ 4>
		where approved_margin < target_margin
	</cfif>
	</cfquery>

</cfif>

<cfsavecontent variable="margin_content">

<table width="90%" border="0" align="center">
	<tr>
		<td style="font-size:14px; font-weight:bold;" width="60%"><b>MARGINS EXCEPTION REPORT</b></td>
		<td style="font-size:11px;" align="right" width="30%">RUN DATE: <cfoutput>#DateFormat(now(),'mm/dd/yyyy')#</cfoutput></td>
	</tr>
	</table>
	
<table width="90%" border="0" align="center">
	<tr>
		<td style="font-size:14px; font-weight:bold;" width="60%"><b><cfif report_type_id EQ 1>All Items<cfelseif report_type_id EQ 2>Items Margin < Approval Margin<cfelseif report_type_id EQ 3>All <cfoutput>#displayGroupTypeDesc#</cfoutput><cfelseif report_type_id EQ 4><cfoutput>#displayGroupTypeDesc#</cfoutput> Margin < Approval Margin</cfif> </b></td></tr>
	<tr><td style="font-size:11px;" align="left" width="30%">Approval Dates: <cfoutput>#DateFormat(form.start_date,'mm/dd/yyyy')# to #DateFormat(form.end_date,'mm/dd/yyyy')#</cfoutput></td>
	</tr>
	</table>

<TABLE CLASS="Maintable" CELLPADDING="4" CELLSPACING="0" WIDTH="90%" align="center">
<TR BGCOLOR="FFCE84" VALIGN="top"> 
<!---   check if they can see the base view --->
    	<TD ID="header" VALIGN="top" align="left"><B><cfif report_type_id EQ 3 or report_type_id EQ 4><cfoutput>#displayGroupTypeDesc#</cfoutput></cfif> Description</B>
		<cfif report_type_id EQ 1 or report_type_id EQ 2><br><B>ITEM</b></cfif></TD>

    	 <TD ID="header" valign="top" NOWRAP align="center">
		<B>Volume</B></TD>
 
    	<TD ID="header" valign="top"><B><cfoutput>#Application.RebateLabel#</cfoutput></B></TD>
			
   		<TD ID="header" valign="top"><B>Fixed Price</B></TD>
			
    	<TD ID="header" valign="top" ><B>Target Margin %</B></TD>
		<TD ID="header" valign="top" ><B>Approved Margin %</B></TD>
		<TD ID="header" valign="top" ><B>Variance</B></TD>
		<TD ID="header" valign="top" ><B>Approved Date</B></TD>
		<TD ID="header" valign="top" ><B>Approved By</B></TD>
</TR>

<cfoutput query= "getmargins" group="contract_main_id">
<TR bgcolor="f4f4f4">
<td colspan="100%">
	
	<span STYLE="font-size:12px;font-weight:bold">Template Type:</span> <span STYLE="font-size:12px;">#created_type#</span><br>
	<span STYLE="font-size:12px;font-weight:bold">Contract Title:</span><span STYLE="font-size:12px;"> #contract_title#</span><br>
	<span STYLE="font-size:12px;font-weight:bold">Contract Number:</span><span STYLE="font-size:12px;"> #contract_number#</span>
</td>
</TR>
<cfset rowcount = 1>
<cfoutput>
	<TR BGCOLOR="#IIf(rowcount Mod 2, DE('ffffff'), DE('CCFFCC'))#">
    	<TD VALIGN="top" align="left">#Description#
		<cfif report_type_id EQ 1 or report_type_id EQ 2>
			<br>#ITEM_NUMBER#
		</cfif>
		</TD>
    	 <TD valign="top" NOWRAP align="center">	#trim(numberformat(Round(Volume),'_-___,___,___,___,___'))#</TD>
    	<TD valign="top" align="center">$#trim(numberformat(RER_CS,'_-___,___,___,___,___.__'))#</TD>
   		<TD valign="top" align="center">$#trim(numberformat(FPR_CS,'_-___,___,___,___,___.__'))#</TD>
    	<TD valign="top" align="center">#trim(numberformat(Round(Target_Margin),'_-___,___,___,___,___._'))#%</TD>
		<TD valign="top" align="center">#trim(numberformat(Round(Approved_Margin),'_-___,___,___,___,___._'))#%</B></TD>
		<TD valign="top" align="center">#trim(numberformat(Round(Variance),'_-___,___,___,___,___._'))#%</TD>
	<TD valign="top" align="center">#dateformat(approved_date,"mm/dd/yyyy")#</TD>
		<TD valign="top" align="center">#User_Name#</TD>
	</TR>
<cfset rowcount = rowcount + 1>
</cfoutput>
</cfoutput>
</TABLE>
</cfsavecontent>

<cfoutput>#margin_content#</cfoutput>

<cfif trim(ReportType) EQ "h">
<CFSET Unique_ID = createUUID()>
<CFSET File_Name = "#Replace(Unique_ID,"-","_","all")#.html">

<CFFILE ACTION	=	"WRITE"
		FILE	=  	"#Application.Doc_Path#\Temp_Files\MarginReport\#File_Name#"
		OUTPUT	=	"#margin_content#">

		<br>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" width="400" align="center">
			<TR>								
				<TD align="center">
					<CF_button
						button_name		=	""
						button_caption	=	"print"
						button_action	=	"NewWindow('/ReportWriter/Performance_Reports/report_print.cfm?Include_File_path=/Temp_Files/MarginReport/#File_Name#&contract_number=#url.Contract_Number#','name','800','600','Yes', 'No')"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Prepare an email contents"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>				
				</TD>
				<TD align="center">
					<CF_button
						button_name		=	""
						button_caption	=	"email"
						button_action	=	"window.location.href='/ReportWriter/Performance_Reports/report_email_create.cfm?FAX_EMAIL=EMAIL&Include_File_path=/Temp_Files/MarginReport/#File_Name#&contract_number=#url.Contract_Number#'"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Prepare an email contents"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>				
				</TD>
			<!--- DEV NOTE: DAA; D15409    REMOVE FAX LINK
				<TD align="center">
					<CF_button
						button_name		=	""
						button_caption	=	"fax"
						button_action	=	"window.location.href='/ReportWriter/Performance_Reports/report_email_create.cfm?FAX_EMAIL=FAX&Include_File_path=/Temp_Files/MarginReport/#File_Name#&contract_number=#url.Contract_Number#'"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Prepare the contents of a fax to be sent"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
			 --->				 	
			</TR>
</TABLE>
</cfif>
</body>