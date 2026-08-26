<!--- <cfsavecontent variable="Page_Content">
<cfsavecontent variable="PRINTER_FRIENDLY_PAGE_BUFFER_1">
		<table align="center" border="0" cellpadding="3" cellspacing="1" style="width: 90%" id="table1" bgcolor="#C0C0C0">
		<cfinclude template="selReportUOM_tblrow.cfm">
		
		<!--- report by month report only --->
		<cfoutput query="getBillbacks" group="Month_Number">
			<tr>
				<td colspan="100%" bgcolor="whitesmoke"><span style="color: Navy; Font-Weight: Bold; font-size: 15px;">#Month_String#</span></td>
			</tr>
			
			<cfinclude template="table_header.cfm">
			
			<!--- loop through this months billbacks and make a list of them--->
			<cfset Temp_List_Of_Billbacks = "">
			<cfoutput>
				<cfset Temp_List_Of_Billbacks = listappend(Temp_List_Of_Billbacks,getBillbacks.Billback_ID)>
			</cfoutput>
			<cfquery name="getBillbackProducts" dbtype="query">
				SELECT * FROM getBillbackItems
				WHERE Billback_ID IN(#ListQualify(Temp_List_Of_Billbacks, "'")#)
			</cfquery>
			
			<cfloop query="getBillbackProducts">
				<cfswitch expression="#getBillbackProducts.PRODUCT_TYPE_ID#">
					<cfcase value="1">
						<tr>
							<td>#getBillbackProducts.PRODUCT_ID#<BR><BR></td>
						</tr>
					</cfcase>
				</cfswitch>
			</cfloop>
		
		</cfoutput>
		</table>
</cfsavecontent>

<cfoutput>#PRINTER_FRIENDLY_PAGE_BUFFER_1#</cfoutput>

<cfsavecontent variable="PRINTER_FRIENDLY_PAGE_BUFFER_2">
</cfsavecontent>	

		<table align="center">
			<tr bgcolor="#FFFFFF">
				<td align="right" style="cursor: hand;" onclick="window.location.href = '/settings/usdanoi/search.cfm'"><b><font color="#FF0000">[</font> 
				<font color="#0000FF">change report criteria</font>
				<font color="#FF0000">]</font></b></td>
				<td>&nbsp;</td>
				<td align="right">&nbsp;</td>
				<td>&nbsp;</td>
				<cfif url.showcontinuelink EQ 1>
<td align="right" style="cursor: hand;" onclick="document.all.SecondaryReport.submit();"><b><font color="#FF0000">[</font> 
				<font color="#0000FF">
					<cfif url.showoperatorsummary EQ 1>
						display ungrouped results
					</cfif>
					<cfif url.showstatesummary EQ 1>
						display results grouped by operator
					</cfif>
					</font>
				<font color="#FF0000">]</font></b></td>				
				</cfif>
			</tr>		
		</table>

</cfsavecontent> --->

<!--- <cfset orderby = "ORDER BY dbo.Operator_ZipCode_Map.State, dbo.Operator_ZipCode_Map.County, dbo.USDANOI_Program_Product_Detail.Item">
<cfset show_summary_by = "state">
<cfset LinkToProgramBreakout = 0>
<cfset whereclause = "">

<!--- show summary by state --->
<cfif url.state NEQ 0 and url.county EQ 0 and url.operator EQ 0 AND url.secondary_report EQ 0>
	<cfset orderby = "ORDER BY Operator_Name, dbo.USDANOI_Program_Product_Detail.Item">
	<cfset whereclause = "AND Operator_ZipCode_Map.stateFIPS = '#url.state#'">
	<cfset show_summary_by = "state_operator">
	<cfset LinkToProgramBreakout = 1>
	<cfset url.showcontinuelink = 1>
	<cfif url.secondary_report EQ 0>
		<cfset url.showoperatorsummary = 1>
	</cfif>
</cfif>

<cfif url.state NEQ 0 and url.county EQ 0 and url.operator EQ 0 AND url.secondary_report EQ 1>
	<cfset orderby = "ORDER BY dbo.USDANOI_Program_Product_Detail.Item">
	<cfset whereclause = "AND Operator_ZipCode_Map.stateFIPS = '#url.state#'">
	<cfset show_summary_by = "state">
	<cfset LinkToProgramBreakout = 1>
	<cfset url.showcontinuelink = 1>
	<cfif url.secondary_report EQ 1>
		<cfset url.showstatesummary = 1>
	</cfif>	
</cfif>

<!--- show summary by county --->
<cfif url.state NEQ 0 and url.county NEQ 0 and url.operator EQ 0 AND url.secondary_report EQ 0>
	<cfset orderby = "ORDER BY dbo.Operator_ZipCode_Map.State, dbo.Operator_ZipCode_Map.County, Operator_Name, dbo.USDANOI_Program_Product_Detail.Item">
	<cfset whereclause = "AND Operator_ZipCode_Map.stateFIPS = '#url.state#' AND Operator_ZipCode_Map.CountyFIPS = '#url.county#'">
	<cfset show_summary_by = "state_operator">
	<cfset LinkToProgramBreakout = 1>
</cfif>

<!--- show summary by county --->
<cfif url.state NEQ 0 and url.county NEQ 0 and url.operator EQ 0 AND url.secondary_report EQ 1>
	<cfset orderby = "ORDER BY dbo.Operator_ZipCode_Map.State, dbo.Operator_ZipCode_Map.County, dbo.USDANOI_Program_Product_Detail.Item">
	<cfset whereclause = "AND Operator_ZipCode_Map.stateFIPS = '#url.state#' AND Operator_ZipCode_Map.CountyFIPS = '#url.county#'">
	<cfset show_summary_by = "county">
	<cfset LinkToProgramBreakout = 1>
</cfif>
<!--- show summary by operator --->
<cfif url.operator NEQ 0>
	<cfset orderby = "ORDER BY dbo.Operator_ZipCode_Map.State, dbo.Operator_ZipCode_Map.County, dbo.Operator_ZipCode_Map.Operator_Name, dbo.USDANOI_Program_Product_Detail.Item">
	<cfset whereclause = "AND Operator_ZipCode_Map.stateFIPS = '#url.state#' AND Operator_ZipCode_Map.CountyFIPS = '#url.county#' AND Operator_ZipCode_Map.BSA_Operator_ID = '#url.operator#'">
	<cfset show_summary_by = "operator">
	<cfset LinkToProgramBreakout = 0>
</cfif>

<!--- show summary by operator --->
<cfif url.operatorid NEQ 0 and url.productid NEQ 0 and url.programid NEQ 0>
	<cfset show_summary_by = "operator">
	<cfset url.operator = url.operatorid>
	<cfset LinkToProgramBreakout = 0>
</cfif>

<cfinclude template="getBeoBasedReportQuery.cfm">



<cfsavecontent variable="Page_Content">
<cfswitch expression="#show_summary_by#">
	<cfcase value="state">
		<cfsavecontent variable="Printer_Friendly_Page_Buffer_1">
		<cfoutput>
		<p><b><font size="4">#application.companyname#</font></b> <br>
		#getGeoBasedReport.State# <br>
		Commodity NOI Performance Report <br>
		</cfoutput>	
		<BR>	
		
		<table align="center" border="0" cellpadding="3" cellspacing="1" style="width: 90%" id="table1" bgcolor="#C0C0C0">		
		</cfsavecontent>
		<cfoutput>#Printer_Friendly_Page_Buffer_1#</cfoutput>

		<cfinclude template="selReportUOM_tblrow.cfm">

		<cfsavecontent variable="Printer_Friendly_Page_Buffer_2">
			<tr>
				<td bgcolor="#FFFFFF" colspan="100%"><cfoutput><b><span style="font-weight:bold; font-size: 17px;">#getGeoBasedReport.State#</span></b></cfoutput></td>
			</tr>
			<cfinclude template="table_header.cfm">
			<CFSET thisCurrentrow = 1>

			<cfinclude template="ProductVolumeStruct.cfm">
			
			<!--- Column Total Defaults --->
			<cfset form.Final_total_BeginningVolume = 0>
			<cfset form.Final_total_Current_1 		= 0>
			<cfset form.Final_total_Current_2 		= 0>
			<cfset form.Final_total_Cumulative_2 	= 0>
			<cfset form.Final_total_Ending_Balance 	= 0>
			<cfset form.Final_total_Value_Available	= 0>	
			
			<cfoutput query="getGeoBasedReport" group="item">
				<!--- Column Total temp variables --->			
				<cfset form.currentItem_total_BeginningVolume 	= 0>
				<cfset form.currentItem_total_Current_1 		= 0>
				<cfset form.currentItem_total_Current_2 		= 0>
				<cfset form.currentItem_total_Cumulative_2 		= 0>
				<cfset form.currentItem_total_Ending_Balance 	= 0>
				<cfset form.currentItem_total_Value_Available	= 0>
			
				<cfinclude template="item_table_row.cfm">
			</cfoutput>
		<cfinclude template="Column_Totals.cfm">
		</table>
		</cfsavecontent>
		<cfoutput>#Printer_Friendly_Page_Buffer_2#</cfoutput>
	</cfcase>
	
	
	<cfcase value="county">
		<cfsavecontent variable="Printer_Friendly_Page_Buffer_1">
		<cfoutput>
		<p><b><font size="4">#application.companyname#</font></b> <br>
		#getGeoBasedReport.County# - #getGeoBasedReport.State# <br>
		Commodity NOI Performance Report <br>
		</cfoutput><BR>
	
		<table align="center" border="0" cellpadding="3" cellspacing="1" style="width: 90%" id="table1" bgcolor="#C0C0C0">
		</cfsavecontent>
		<cfoutput>#Printer_Friendly_Page_Buffer_1#</cfoutput>
		
		<cfinclude template="selReportUOM_tblrow.cfm">
		
		<cfsavecontent variable="Printer_Friendly_Page_Buffer_2">
		
		<CFSET thisCurrentrow = 1>
		<cfoutput query="getGeoBasedReport" group="state">
			<cfoutput group="county">
				<tr>
					<td bgcolor="##FFFFFF" colspan="100%"><span style="font-weight:bold; font-size: 15px;">#getGeoBasedReport.State# - #getGeoBasedReport.County#</span></td>
				</tr>				
				<cfinclude template="table_header.cfm">
	
				<cfinclude template="ProductVolumeStruct.cfm">
				<!--- Column Total Defaults --->
				<cfset form.Final_total_BeginningVolume = 0>
				<cfset form.Final_total_Current_1 		= 0>
				<cfset form.Final_total_Current_2 		= 0>
				<cfset form.Final_total_Cumulative_2 	= 0>
				<cfset form.Final_total_Ending_Balance 	= 0>
				<cfset form.Final_total_Value_Available	= 0>				

				<!--- output item rows --->
				<cfoutput group="item">
					<cfset totals_BeginningVolume = 0>
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
		<cfinclude template="Column_Totals.cfm">
		</table>
		</cfsavecontent>
		<cfoutput>#Printer_Friendly_Page_Buffer_2#</cfoutput>
	</cfcase>
	
	<cfcase value="operator">
		<cfsavecontent variable="Printer_Friendly_Page_Buffer_1">
		<cfoutput>
		<p><b><font size="4">#application.companyname#</font></b> <br>
		#getGeoBasedReport.County# - #getGeoBasedReport.State# <br>
		Commodity NOI Performance Report <br>
		</cfoutput>	<BR>
	
		<table align="center" border="0" cellpadding="3" cellspacing="1" style="width: 90%" id="table1" bgcolor="#C0C0C0">		
		</cfsavecontent>
		<cfoutput>#Printer_Friendly_Page_Buffer_1#</cfoutput>

		<cfinclude template="selReportUOM_tblrow.cfm">

		<cfsavecontent variable="Printer_Friendly_Page_Buffer_2">

		<CFSET thisCurrentrow = 1>
		<cfoutput query="getGeoBasedReport" group="state">
			<cfoutput group="county">
				<cfoutput group="Operator_Name">
					<tr>
						<td bgcolor="##FFFFFF" colspan="100%"><span style="font-weight:bold; font-size: 15px;">#getGeoBasedReport.State# - #getGeoBasedReport.County# - #getGeoBasedReport.Operator_Name#</span></td>
					</tr>
					<cfinclude template="table_header.cfm">
		
					<cfinclude template="ProductVolumeStruct.cfm">
					<!--- Column Total Defaults --->
					<cfset form.Final_total_BeginningVolume = 0>
					<cfset form.Final_total_Current_1 		= 0>
					<cfset form.Final_total_Current_2 		= 0>
					<cfset form.Final_total_Cumulative_2 	= 0>
					<cfset form.Final_total_Ending_Balance 	= 0>
					<cfset form.Final_total_Value_Available	= 0>				
					<!--- output item rows --->
					<cfoutput group="item">
						<cfset totals_BeginningVolume = 0>
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
		</cfoutput>
		<cfinclude template="Column_Totals.cfm">

		</table>
		</cfsavecontent>
		<cfoutput>#Printer_Friendly_Page_Buffer_2#</cfoutput>
	</cfcase>
	
	<cfcase value="state_operator">
		<cfsavecontent variable="Printer_Friendly_Page_Buffer_1">
		<cfoutput>
		<p><b><font size="4">#application.companyname#</font></b> <br>
		#getGeoBasedReport.State# <br>
		Commodity NOI Performance Report <br>
		</cfoutput>	
		<BR>	
		
		<table align="center" border="0" cellpadding="3" cellspacing="1" style="width: 90%" id="table1" bgcolor="#C0C0C0">		
		</cfsavecontent>
		<cfoutput>#Printer_Friendly_Page_Buffer_1#</cfoutput>

		<cfinclude template="selReportUOM_tblrow.cfm">

		<cfsavecontent variable="Printer_Friendly_Page_Buffer_2">
			<tr>
				<td bgcolor="#FFFFFF" colspan="100%"><cfoutput><b><span style="font-weight:bold; font-size: 17px;">#getGeoBasedReport.State#</span></b></cfoutput></td>
			</tr>
			<cfinclude template="table_header.cfm">
			<CFSET thisCurrentrow = 1>

			<cfoutput query="getGeoBasedReport" group="state">

				<cfoutput group="Operator_Name">
					<tr>
						<td colspan="100%" align="left" bgcolor="White"><b style="color: Navy; font-size: 15px;">#Operator_Name#</b></td>
					</tr>
					<cfoutput group="item">
					<cfinclude template="ProductVolumeStruct.cfm">
		 			<!--- Column Total Defaults --->
					<cfset form.Final_total_BeginningVolume = 0>
					<cfset form.Final_total_Current_1 		= 0>
					<cfset form.Final_total_Current_2 		= 0>
					<cfset form.Final_total_Cumulative_2 	= 0>
					<cfset form.Final_total_Ending_Balance 	= 0>
					<cfset form.Final_total_Value_Available	= 0>	
					<!--- Column Total temp variables --->			
					<cfset form.currentItem_total_BeginningVolume 	= 0>
					<cfset form.currentItem_total_Current_1 		= 0>
					<cfset form.currentItem_total_Current_2 		= 0>
					<cfset form.currentItem_total_Cumulative_2 		= 0>
					<cfset form.currentItem_total_Ending_Balance 	= 0>
					<cfset form.currentItem_total_Value_Available	= 0>	

					<cfinclude template="item_table_row.cfm">
						
					</cfoutput>
					<cfinclude template="Column_Totals.cfm">
				</cfoutput>
	
			</cfoutput>
		</table>
		</cfsavecontent>
		
		<cfoutput>#Printer_Friendly_Page_Buffer_2#</cfoutput>
	</cfcase>
	
	<cfcase value="state_county_operator">
	</cfcase>
	
	<cfdefaultcase>
		<cfabort>
	</cfdefaultcase>
</cfswitch>
</cfsavecontent>
<!--- display page --->
<cfoutput>
	#Page_Content#
</cfoutput>

		<br>
		<table align="center">
			<tr bgcolor="#FFFFFF">
				<td align="right" style="cursor: hand;" onclick="window.location.href = '/settings/usdanoi/search.cfm'"><b><font color="#FF0000">[</font> 
				<font color="#0000FF">change report criteria</font>
				<font color="#FF0000">]</font></b></td>
				<td>&nbsp;</td>
				<td align="right">&nbsp;</td>
				<td>&nbsp;</td>
				<cfif url.showcontinuelink EQ 1>
<td align="right" style="cursor: hand;" onclick="document.all.SecondaryReport.submit();"><b><font color="#FF0000">[</font> 
				<font color="#0000FF">
					<cfif url.showoperatorsummary EQ 1>
						display ungrouped results
					</cfif>
					<cfif url.showstatesummary EQ 1>
						display results grouped by operator
					</cfif>
					</font>
				<font color="#FF0000">]</font></b></td>				
				</cfif>
			</tr>		
		</table>

		<cfoutput>
		<form action="generate_report.cfm" method="get" name="SecondaryReport" id="SecondaryReport">
			<input type="Hidden" name="state" value="#url.state#">
			<input type="Hidden" name="county" value="#url.county#">
			<input type="Hidden" name="operator" value="#url.operator#">
			<input type="Hidden" name="report_filename" value="#url.report_filename#">
			<input type="Hidden" name="final_destination" value="#url.final_destination#">
			<input type="Hidden" name="report_number" value="#url.report_number#">
			<cfif url.showoperatorsummary EQ 1>
				<input type="Hidden" name="secondary_report" value="1">
			<cfelse>
				<input type="Hidden" name="secondary_report" value="0">
			</cfif>
			
		</form>
		</cfoutput>
	
		</body>
		</html> --->
		