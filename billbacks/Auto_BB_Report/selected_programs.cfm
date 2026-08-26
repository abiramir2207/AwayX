<cfset oPrgManager = CreateObject("component","components.programs.ProgramManager") />
<cfset oBBAutoReportGet = CreateObject("component","components.Billback.BBAutoReportGet") />

<!--- Get basic program information for the programs --->
<cfsetting showdebugoutput="false">
<cfquery name="GetBasicProgramInfo" datasource="#application.datasource#">
SELECT 	CM.Contract_Number, 
		CM.Contract_Title, 
		CM.Contract_Main_ID
FROM 	Contract_Main CM
WHERE 	CM.Contract_Main_ID IN (<cfqueryparam value="#Form.ProgramList#" cfsqltype="CF_SQL_VARCHAR" list="Yes">)
ORDER BY CM.Contract_Number ASC
</cfquery>

<table width="600" cellpadding="2" cellspacing="2">
	<tr>
	<cfoutput query="GetBasicProgramInfo">

		<cfif Form.CreateException eq 1>

			<!---<cfset PrgEffDatesList = oPrgManager.getProgramVersionsWithinEffectiveDates(GetBasicProgramInfo.contract_main_id,Form.Start_Date,Form.End_Date)>--->
			<cfset qryIncludeExceptionReportFeatures = oBBAutoReportGet.getIncludeExceptionReportFeatures(GetBasicProgramInfo.Contract_Number,Form.Start_Date,Form.End_Date)>
			<cfset qryDistList = oBBAutoReportGet.getReportDistributors(Auto_Pay_Contract_ID = GetBasicProgramInfo.Contract_Main_ID, BBAutoReportID = form.ReportID, showSelectedOnly = 1)>
			<cfset qryInvList = oBBAutoReportGet.getReportInvoices(Auto_Pay_Contract_ID = GetBasicProgramInfo.Contract_Main_ID, BBAutoReportID = form.ReportID, showSelectedOnly = 1)>

			<!--- To copy distributors when a user copies the report, we need to get distributors from the existing report --->
			<cfset distributorList = "">
			<cfif qryDistList.recordcount neq 0>
				<cfloop query="qryDistList">
					<cfset distributorList = ListAppend(distributorList,Selected_Distributor_ID)>
				</cfloop>
			</cfif>

			<!--- To copy distributors when a user copies the report, we need to get distributors from the existing report --->
			<cfset invoiceList = "">
			<cfif qryInvList.recordTotal neq 0>
				<cfloop query="qryInvList.resultsQueryName">
					<cfset invoiceList = ListAppend(invoiceList,Selected_Invoice_Header_ID)>
				</cfloop>
			</cfif>

		</cfif>

		<CF_CRYP type="en" key="#request.key#" string="#GetBasicProgramInfo.contract_main_id#" />
		<CFSET CID = cryp.value />
			<td CLASS="dataStyle" WIDTH="33%" VALIGN="top" BGCOLOR="F2F2F2">
				<A onClick="javaScript: NewWindow(this.href , 'Preview_Program' , 800 , 600 , 'yes' , 'yes'); return false;" target="_blank" HREF="/scorecard/program_display.cfm?display_program=1&CID=#CID#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #GetBasicProgramInfo.Contract_Number#"><font color="660033"><b>#Contract_Number# #left(Contract_Title, 50)#</b></font></A>
		<!--- If the user wants to create an expection report AND based on discount type on the program, creating exception report is allowed. --->
		<cfif Form.CreateException eq 1 AND qryIncludeExceptionReportFeatures eq 1>	
				<br />
				<A onclick="javaScript: NewWindow(this.href , 'distributor_List' , 1050, 650, 'yes', 'yes'); return false;" target="distList" HREF="/common_files/contracts/select_distributors_grid.cfm?ContractMainID=#GetBasicProgramInfo.Contract_Main_ID#&Contract_Number=#Contract_Number#&Start_Date=#Form.Start_Date#&End_Date=#Form.End_Date#&Report_ID=#form.ReportID#" TITLE="Filter #lcase(application.returned_customer_setting.distributor_label_plural)# for program  #GetBasicProgramInfo.Contract_Number#">#application.util.string.actionLinkFormat2("filter by " & lcase(application.returned_customer_setting.distributor_label_plural) & " and/or invoices")# </A>				
				&nbsp;&nbsp;&nbsp;
				<span id="distCount_#GetBasicProgramInfo.Contract_Main_ID#" style="color:red;font-weight:bold">#qryDistList.recordcount#</span> <span style="color:red;font-weight:bold">#lcase(application.returned_customer_setting.distributor_label_plural)# included</span>
			<cfif distributorList neq "">
				<input type="hidden" name="FilterDistributors_#GetBasicProgramInfo.Contract_Main_ID#" id="FilterDistributors_#GetBasicProgramInfo.Contract_Main_ID#" value="#distributorList#" />
				<input type="hidden" name="Temp_FilterDistributors_#GetBasicProgramInfo.Contract_Main_ID#" id="Temp_FilterDistributors_#GetBasicProgramInfo.Contract_Main_ID#" value="#distributorList#" />
			<cfelse>
				<input type="hidden" name="FilterDistributors_#GetBasicProgramInfo.Contract_Main_ID#" id="FilterDistributors_#GetBasicProgramInfo.Contract_Main_ID#" value="-1" />
				<input type="hidden" name="Temp_FilterDistributors_#GetBasicProgramInfo.Contract_Main_ID#" id="Temp_FilterDistributors_#GetBasicProgramInfo.Contract_Main_ID#" value="-1" />
			</cfif>

			<br />
			<A onclick="javaScript: NewWindow(this.href , 'invoice_List' , 1050, 650, 'yes', 'yes'); return false;" target="invoiceList" HREF="/search_screens/invoice/select_invoices_grid.cfm?ContractMainID=#GetBasicProgramInfo.Contract_Main_ID#&Contract_Number=#Contract_Number#&Start_Date=#Form.Start_Date#&End_Date=#Form.End_Date#&Report_ID=#form.ReportID#" TITLE="Filter #lcase(application.returned_customer_setting.distributor_label_plural)# for program  #GetBasicProgramInfo.Contract_Number#">#application.util.string.actionLinkFormat2("filter by invoices only")#</A>	
			&nbsp;&nbsp;&nbsp;
				<span id="invCount_#GetBasicProgramInfo.Contract_Main_ID#" style="color:red;font-weight:bold">#qryInvList.recordTotal#</span> <span style="color:red;font-weight:bold">invoices included</span>
			<cfif invoiceList neq "">
				<input type="hidden" name="FilterInvoices_#GetBasicProgramInfo.Contract_Main_ID#" id="FilterInvoices_#GetBasicProgramInfo.Contract_Main_ID#" value="#invoiceList#" />
				<input type="hidden" name="Temp_FilterInvoices_#GetBasicProgramInfo.Contract_Main_ID#" id="Temp_FilterInvoices_#GetBasicProgramInfo.Contract_Main_ID#" value="#invoiceList#" />
			<cfelse>
				<input type="hidden" name="FilterInvoices_#GetBasicProgramInfo.Contract_Main_ID#" id="FilterInvoices_#GetBasicProgramInfo.Contract_Main_ID#" value="-1" />
				<input type="hidden" name="Temp_FilterInvoices_#GetBasicProgramInfo.Contract_Main_ID#" id="Temp_FilterInvoices_#GetBasicProgramInfo.Contract_Main_ID#" value="-1" />
			</cfif>
		</cfif>
			</td>
			<CFIF NOT GetBasicProgramInfo.CURRENTROW MOD 3> </tr> <tr> </CFIF>
	</cfoutput>
	 </tr>

</table>
</cfsetting>