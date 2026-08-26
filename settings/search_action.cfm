
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>USDA NOI</title>
</head>

<body>

<cfquery name="GetOperatorInfo" datasource="#application.datasource#">
	SELECT Operator_Name
	FROM BSA_Operator
	WHERE BSA_Operator_ID = '#url.operator#'
</cfquery>


<CFSET OpProgramList = url.programid>
<!--- consolidate both queries into one later --->
<cfquery name="getNOIProducts" datasource="#application.datasource#">
	SELECT *
	FROM USDANOI_Program_Product_Detail
	WHERE BSA_Operator_ID = '#url.operator#' and program_id = '#url.programid#'
</cfquery>

<cfset orderby = "ORDER BY dbo.Operator_ZipCode_Map.State, dbo.Operator_ZipCode_Map.County, dbo.USDANOI_Program_Product_Detail.Item">
<cfset whereclause = "AND dbo.USDANOI_Programs_Approved.Program_ID = '#url.programid#' AND dbo.Contract_Operators.BSA_Operator_ID = '#url.operator#'">
<cfinclude template="getBeoBasedReportQuery.cfm">
	
<cfoutput>
<p><b><font size="4">#application.companyname#</font></b> <br>
#GetOperatorInfo.Operator_Name# <br>
Commodity NOI Performance Report <br>
</p>
</cfoutput>


<table align="center" border="0" cellpadding="3" cellspacing="1" style="width: 90%" id="table1" bgcolor="#C0C0C0">
<cfinclude template="selReportUOM_tblrow.cfm">
		
<CFSET thisCurrentrow = 1>
<cfoutput query="GETGEOBASEDREPORT" group="state">
	<cfoutput group="county">
		<cfinclude template="table_header.cfm">
		<!--- Column Total Defaults --->
		<cfset form.Final_total_BeginningVolume = 0>
		<cfset form.Final_total_Current_1 		= 0>
		<cfset form.Final_total_Current_2 		= 0>
		<cfset form.Final_total_Cumulative_2 	= 0>
		<cfset form.Final_total_Ending_Balance 	= 0>
		<cfset form.Final_total_Value_Available	= 0>		
		<!--- output item rows --->
		<cfoutput group="item">
			<!--- Column Total temp variables --->			
			<cfset form.currentItem_total_BeginningVolume 	= 0>
			<cfset form.currentItem_total_Current_1 		= 0>
			<cfset form.currentItem_total_Current_2 		= 0>
			<cfset form.currentItem_total_Cumulative_2 		= 0>
			<cfset form.currentItem_total_Ending_Balance 	= 0>
			<cfset form.currentItem_total_Value_Available	= 0>		
			<cfinclude template="item_table_row.cfm">
		</cfoutput>
	</cfoutput>
</cfoutput>
</table>



<br>
<table align="center">
	<tr bgcolor="#ffffff">
		<!--- <td align="right" style="cursor: pointer;" onclick="window.location.href = 'program_search.cfm?operator=<cfoutput>#operator#</cfoutput>'"><b><font color="#FF0000">[</font>  --->
		<td align="right" style="cursor: pointer;" onclick="window.location.href = '/settings/usdanoi/search.cfm'"><b><font color="#FF0000">[</font> 
		
		<font color="#0000FF">search again</font>
		<font color="#FF0000">]</font></b></td>
		<td>&nbsp;</td>
		<td align="right">&nbsp;</td>
		<td>&nbsp;</td>
	</tr>		
</table>
		<cfparam name="url.state" default="">
		<cfparam name="url.county" default="">
		<cfparam name="url.operator" default="">
		<cfoutput>
		<form action="agree_save.cfm" method="post" name="agreeForm" id="agreeForm">
			<input type="Hidden" name="agree_state" value="#url.state#">
			<input type="Hidden" name="agree_county" value="#url.county#">
			<input type="Hidden" name="agree_operator" value="#url.operator#">
			<input type="Hidden" name="file" value="#url.file#">
			<input type="Hidden" name="report_number" value="#url.report_number#">
			<input type="Hidden" name="final_destination" value="/settings/usdanoi/show_report.cfm">
			<cfif isdefined("url.programid")>
				<cfif url.programid NEQ 0>
				<input type="Hidden" name="programid" value="#url.programid#">
				</cfif>
			</cfif>
			
		</form>
		</cfoutput>

</body>
</html>