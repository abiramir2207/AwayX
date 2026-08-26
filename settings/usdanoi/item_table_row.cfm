<cfparam name="LinkToProgramBreakout" default="0">
<cfparam name="form.thisReportUOM" default="1">
<cfparam name="url.Operator" default="0">
<cfparam name="form.OperatorID" default="0">
<cfparam name="form.BSA_Operator_ID" default="0">
<cfparam name="form.program_id" default="0">
<cfparam name="url.program_id" default="0">
<cfparam name="url.ReportBBDetail" default="0">


<cfif url.Operator NEQ 0 AND len(trim(url.Operator)) NEQ 0>
	<cfset form.OperatorID = url.Operator>
</cfif>
<cfif form.BSA_Operator_ID NEQ 0 AND len(trim(form.BSA_Operator_ID)) NEQ 0>
	<cfset form.OperatorID = form.BSA_Operator_ID>
</cfif>
<cfif url.program_id NEQ 0 AND len(trim(url.program_id)) NEQ 0>
	<cfset form.program_id = url.program_id>
</cfif>

<!--- since this file is included in a cfoutput with grouping this cfoutputs acts like a loop on the line item level--->
<cfset BB_Volume_Total = 0>
<cfset BB_Volume_Recent = 0>
<cfset TotalItemProgramVolume = 0>

	<cfif LinkToProgramBreakout EQ 0>
		<cfset BreakoutURL = "bbbreakout.cfm?ProgramID=#form.program_id#&ProductID=#getGeoBasedReport.BSA_Foodservice_Items_Master_ID#&OperatorID=#form.OperatorID#">
	<cfelse>
		<cfset BreakoutURL = "program_search.cfm?ProgramID=#form.program_id#&ProductID=&OperatorID=#form.OperatorID#">
		<cfset BreakoutURL = "javascript: doMontlhyItemBBBreakdown()">
	</cfif>


	<!--- get USDA price for this product based on the EPDS rule --->
	<CFSTOREDPROC PROCEDURE="GET_USDANOI_PRICE" DATASOURCE="#application.datasource#">
			<cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="@@BSA_Foodservice_Items_Master_ID" value="#BSA_Foodservice_Items_Master_ID#" null="No">
		<!---<cfprocparam type = "IN" dbVarName = "@@INPUTVAR_Volume" value = "#GetProductVolume.Volume_LB#" CFSQLType="CF_SQL_FLOAT">
		<cfprocparam type = "IN" dbVarName = "@@INPUTVAR_Volume_UOM" value = "pound" CFSQLType="CF_SQL_VARCHAR"> --->
		<cfprocparam type = "OUT" VARIABLE="USDA_FinalPrice_Per_USDA_UOM" dbVarName = "@@USDA_Price" CFSQLType="CF_SQL_FLOAT">
		<cfprocparam type = "OUT" VARIABLE="USDA_UOM" dbVarName = "@@UOM" CFSQLType="CF_SQL_VARCHAR">
		<cfprocparam type = "OUT" VARIABLE="YIELD_OUT" dbVarName = "@@YIELD_OUT" CFSQLType="CF_SQL_INTEGER">
		
		<cfprocparam type = "OUT" VARIABLE="spPTV_LB" dbVarName = "@@PTV_CS" CFSQLType="CF_SQL_FLOAT">
		<cfprocparam type = "OUT" VARIABLE="spPTV_CS" dbVarName = "@@PTV_LB" CFSQLType="CF_SQL_FLOAT">
		<cfprocparam type = "OUT" VARIABLE="spPTV_RM" dbVarName = "@@PTV_RM" CFSQLType="CF_SQL_FLOAT">
		
	</CFSTOREDPROC>

<cfset get_latest_billback_numbers_Program_ID_List = form.program_id>
<!--- if volume is from somewhere else --->
<cfif isdefined("ProdVolumeStruct")>
	<cfset ArrayIndex = replace(getGeoBasedReport.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")>
	<cfset ArrayIndex ="A_" & ArrayIndex>
	
	<cfif isdefined("ProdVolumeStruct.#ArrayIndex#")>
		<cfset tempStruct = evaluate("ProdVolumeStruct.#ArrayIndex#")>
		<cfif listlen(tempStruct.Program_List) GT 0>
			<cfset get_latest_billback_numbers_Program_ID_List = tempStruct.Program_List>
		</cfif>
	</cfif>
</cfif>

<cfif url.showoperatorsummary EQ 1>
	<cfquery name="getOperatorPrograms" datasource="#application.datasource#">
		SELECT Program_ID
		FROM USDANOI_Program_Product_Detail
		WHERE BSA_Operator_ID = '#getGeoBasedReport.BSA_Operator_ID#' AND BSA_Foodservice_Items_Master_ID = '#getGeoBasedReport.BSA_Foodservice_Items_Master_ID#'

	</cfquery>
	<cfset get_latest_billback_numbers_Program_ID_List = valuelist(getOperatorPrograms.Program_ID)>
	<cfif listlen(get_latest_billback_numbers_Program_ID_List) EQ 0>
		<cfset get_latest_billback_numbers_Program_ID_List = 0>
	</cfif>
</cfif>

	<!--- get sumary of billbacks --->
	<CFSTOREDPROC PROCEDURE="GET_Product_Bid_Recent_And_Total" DATASOURCE="#application.datasource#">
		<cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="@Supplied_Program_ID" value="#get_latest_billback_numbers_Program_ID_List#" null="No">
		<cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="@Supplied_Product_ID" value="#BSA_Foodservice_Items_Master_ID#" null="No">
	
		<cfprocparam type="Out" cfsqltype="CF_SQL_FLOAT" variable="procBB_Volume_Recent" dbvarname="@BB_Volume_Recent" null="No">
		<cfprocparam type="Out" cfsqltype="CF_SQL_FLOAT" variable="procBB_Volume_Total" dbvarname="@BB_Volume_Total" null="No">
	</CFSTOREDPROC>
	<cfif len(trim(procBB_Volume_Recent)) EQ 0><cfset procBB_Volume_Recent = 0></cfif>
	<cfset BB_Volume_Recent = BB_Volume_Recent + procBB_Volume_Recent>
	
	<cfif len(trim(procBB_Volume_Total)) EQ 0><cfset procBB_Volume_Total = 0></cfif>
	<cfset BB_Volume_Total = BB_Volume_Total + procBB_Volume_Total>	


<CFSTOREDPROC PROCEDURE="get_latest_billback_numbers" DATASOURCE="#application.datasource#">
	<cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="@@Product_ID" value="#BSA_Foodservice_Items_Master_ID#" null="No">
	<cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="@@Program_ID_List" value="#get_latest_billback_numbers_Program_ID_List#" null="No">

	<cfprocparam type="Out" cfsqltype="CF_SQL_FLOAT" variable="BBItem_Volume_Paid_CS" dbvarname="@@Item_Volume_Paid_CS" null="No">
	<cfprocparam type="Out" cfsqltype="CF_SQL_FLOAT" variable="BBVolume_CS" dbvarname="@@Volume_CS" null="No">
	<cfprocparam type="Out" cfsqltype="CF_SQL_FLOAT" variable="BBRunningBBTotal" dbvarname="@@RunningBBTotal" null="No">
	<cfprocparam type="Out" cfsqltype="CF_SQL_FLOAT" variable="BBBalance" dbvarname="@@Balance" null="No">
		
</CFSTOREDPROC>

<cfset BeginningVolume = 0>
<cfif ProgramDateSpanInDays GT 0>
	<cfset BeginningVolume = (getGeoBasedReport.Volume_CS * ProgramDateSpanInDays) / 7>
</cfif>

<!--- if volume is from somewhere else --->
<cfif isdefined("ProdVolumeStruct")>
	<cfset ArrayIndex = replace(getGeoBasedReport.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")>
	<cfset ArrayIndex ="A_" & ArrayIndex>
	
	<cfif isdefined("ProdVolumeStruct.#ArrayIndex#")>
		<cfset BeginningVolume = evaluate("ProdVolumeStruct.#ArrayIndex#.Volume")>
	</cfif>
</cfif>

<cfset BeginningVolume = trim(numberformat(BeginningVolume, '_________'))>

<CFSET f = BeginningVolume - BBRunningBBTotal>

<cfset g = 0>
<!--- if the rule uom is the same as the report UOM --->
<cfif USDA_UOM EQ 2 AND form.thisReportUOM EQ 2>
	<cfset g = f * USDA_FinalPrice_Per_USDA_UOM>
<!--- PTV = LB, REPORT = CS --->
<cfelseif USDA_UOM EQ 2 AND form.thisReportUOM EQ 1>
	<cfset g = f * USDA_FinalPrice_Per_USDA_UOM>
<cfelseif USDA_UOM EQ 2 AND form.thisReportUOM EQ "rm">
	<cfset g = f * USDA_FinalPrice_Per_USDA_UOM>
</cfif>


<cfoutput>

	<tr bgcolor="<cfif url.ReportBBDetail EQ 0><CFIF thisCurrentrow mod 2>##ffffcc<CFELSE>WhiteSmoke</CFIF><cfelse>##ffffcc</cfif>">
		<td>
		<a href="#BreakoutURL#">#Item#</a></td>
		#Item#</td>
		<td nowrap>
		#Description#</td>
		
		<td align="right">
		<cfset unFormatedPTV = 0>
		<cfset FormatedPTV = 0>
		<cfswitch expression="#lcase(form.thisReportUOM)#">
			<cfcase value="1"><!--- LB --->
				<cfset unFormatedPTV = spPTV_LB>
				<cfset FormatedPTVuom = 1>
			</cfcase>

			<cfcase value="2"><!--- CS --->
				<cfset unFormatedPTV = spPTV_CS>
				<cfset FormatedPTVuom = 2>
			</cfcase>

			<cfcase value="rm"><!--- RM --->
				<cfset unFormatedPTV = spPTV_RM>
				<cfset FormatedPTVuom = "rm">
			</cfcase>
		</cfswitch>
		<cfset FormatedPTV = trim(numberformat(unFormatedPTV, '___,___,___.____'))>
		#FormatedPTV#&nbsp;<cfif FormatedPTVuom EQ 1>CS<cfelseif FormatedPTVuom EQ 2 OR FormatedPTVuom EQ "rm">LB</cfif></td>
		
		<td align="right" x:num="2000">
		
		<!--- Beggining Volume --->
		<cfset tempA = BeginningVolume>
		<cfswitch expression="#form.thisReportUOM#">
			<!--- case --->
			<cfcase value="1">
				#trim(numberformat(BeginningVolume, '___,___,___'))#
			</cfcase>
			<!--- poound --->
			<cfcase value="2">
				<cfset tempA = BeginningVolume>
				<cfset tempA = tempA * Net_Weight>
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
			<!--- raw materials --->
			<cfcase value="rm">
				<cfset tempA = BeginningVolume>
				<cfset pYield = YIELD_OUT/100>
				<cfset tempA = tempA * Net_Weight>
				<cfset tempA = tempA / pYield>
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
		</cfswitch>

		<cfset form.currentItem_total_BeginningVolume = tempA>
		<cfset form.Final_total_BeginningVolume = form.Final_total_BeginningVolume + trim(numberformat(form.currentItem_total_BeginningVolume, '_______________.____'))>

		</td>
 		<td align="right" x:num="400">
		<cfset tempA = 0>
		0
		<cfset form.currentItem_total_Current_1 = tempA>
		<cfset form.Final_total_Current_1 = form.Final_total_Current_1 + trim(numberformat(form.currentItem_total_Current_1, '_______________.____'))>		
		</td>
		<td align="right" x:num="3200">
		
		<cfif len(trim(BeginningVolume)) EQ 0><cfset BeginningVolume=0></cfif>
		<!------------------------------------------------------------------>
		<cfswitch expression="#form.thisReportUOM#">
			<!--- case --->
			<cfcase value="1">
				#trim(numberformat(BeginningVolume, '___,___,___'))#
			</cfcase>
			<!--- poound --->
			<cfcase value="2">
				<cfset tempA = BeginningVolume>
				<cfset tempA = tempA * Net_Weight>
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
			<!--- raw materials --->
			<cfcase value="rm">
				<cfset tempA = BeginningVolume>
				<cfset pYield = YIELD_OUT/100>
				<cfset tempA = tempA * Net_Weight>
				<cfset tempA = tempA / pYield>
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
		</cfswitch>


		<!------------------------------------------------------------------>
		
		</td>	
		<td align="right" x:num="320">
		<CFSET b = trim(NumberFormat(BB_Volume_Recent, '___,___,___,___'))>
		<cfif len(trim(b)) EQ 0><cfset BB_Volume_Recent=0></cfif>
		<cfset tempA = b>
		<!------------------------------------------------------------------>
		<cfswitch expression="#form.thisReportUOM#">
			<!--- case --->
			<cfcase value="1">
				#b#
			</cfcase>
			<!--- poound --->
			<cfcase value="2">
				<cfset tempA = b>
				<cfset tempA = tempA * Net_Weight>
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
			<!--- raw materials --->
			<cfcase value="rm">
				<cfset tempA = b>
				<cfset pYield = YIELD_OUT/100>
				<cfset tempA = tempA * Net_Weight>
				<cfset tempA = tempA / pYield>
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
		</cfswitch>
		<cfset form.currentItem_total_Current_2 = tempA>
		<cfset form.Final_total_Current_2 = form.Final_total_Current_2 + trim(numberformat(form.currentItem_total_Current_2, '_______________.____'))>	
		<!------------------------------------------------------------------>
		
		</td>
		<td align="right" x:num="2600">
		<cfset BB_Volume_Total = trim(numberformat(BB_Volume_Total, '___,___,___'))>
		<cfset currentItem_total_Cumulative_2 = BB_Volume_Total>
		<cfset tempA = BB_Volume_Total>
		<!------------------------------------------------------------------>
		<cfswitch expression="#form.thisReportUOM#">
			<!--- case --->
			<cfcase value="1">
				#BB_Volume_Total#
			</cfcase>
			<!--- poound --->
			<cfcase value="2">
				<cfset tempA = BB_Volume_Total>
				<cfset tempA = tempA * Net_Weight>
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
			<!--- raw materials --->
			<cfcase value="rm">
				<cfset tempA = BB_Volume_Total>
				<cfset pYield = YIELD_OUT/100>
				<cfset tempA = tempA * Net_Weight>
				<cfset tempA = tempA / pYield>
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
		</cfswitch>
		<cfset form.currentItem_total_Cumulative_2 = tempA>
		<cfset form.Final_total_Cumulative_2 = form.Final_total_Cumulative_2 + trim(numberformat(form.currentItem_total_Cumulative_2, '_______________.____'))>	
		<!------------------------------------------------------------------>		
		
		</td>
		<td align="right" x:num="600" x:fmla="=E6-G6" nowrap>
		<cfset BeginningVolume = BeginningVolume-BB_Volume_Total>
		<cfset tempA = BeginningVolume>
		<!------------------------------------------------------------------>
		<cfswitch expression="#form.thisReportUOM#">
			<!--- case --->
			<cfcase value="1">
				#trim(numberformat(BeginningVolume, '___,___,___'))#
			</cfcase>
			<!--- poound --->
			<cfcase value="2">
				<cfset tempA = BeginningVolume>
				<cfset tempA = tempA * Net_Weight>
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
			<!--- raw materials --->
			<cfcase value="rm">
				<cfset tempA = BeginningVolume>
				<cfset pYield = YIELD_OUT/100>
				<cfset tempA = tempA * Net_Weight>
				<cfset tempA = tempA / pYield>
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
		</cfswitch>
		<cfset form.currentItem_total_Ending_Balance = tempA>
		<cfset form.Final_total_Ending_Balance = form.Final_total_Ending_Balance + trim(numberformat(form.currentItem_total_Ending_Balance, '_______________.____'))>			
		<!------------------------------------------------------------------>				
		
		</td>
		
		<td align="right" x:num="3048" x:fmla="=H6*D$1">
		<cfset Value_Available = form.currentItem_total_Ending_Balance>

		<cfswitch expression="#lcase(form.thisReportUOM)#">
			<cfcase value="1"><!--- LB --->
				<cfset Value_Available = Value_Available * spPTV_LB>
			</cfcase>

			<cfcase value="2"><!--- CS --->
				<cfset Value_Available = Value_Available * spPTV_CS>
			</cfcase>

			<cfcase value="rm"><!--- RM --->
				<cfset Value_Available = Value_Available * spPTV_RM>
			</cfcase>
		</cfswitch>		
		$#trim(numberformat(Value_Available, '___,___,___'))#</td>
		<cfset form.currentItem_total_Value_Available = Value_Available>
		<cfset form.Final_total_Value_Available = form.Final_total_Value_Available + trim(numberformat(form.currentItem_total_Value_Available, '_______________.____'))>	
	</tr>		
	<CFSET thisCurrentrow = thisCurrentrow + 1>
	
	
	
	<cfif url.ReportBBDetail NEQ 0>
		<cfquery name="GetALLBBs" datasource="#application.datasource#">
		SELECT     dbo.BB_Item_Final.Item_Volume_Paid_CS, dbo.BB_Approved.Date_Approved, dbo.Billback.Billback_ID, dbo.Billback.BB_Title, 
		                      dbo.Billback.BB_Reference, ISNULL(dbo.Program_Product_Volume.Volume_CS,0) AS Volume_CS, DATEPART(mm, dbo.Billback.BB_Date) 
		                      AS Month_Number, DATENAME(mm, dbo.Billback.BB_Date) AS Month_Name
		, dbo.BSA_Foodservice_Customers.Name AS Distributor_Name, dbo.Billback.Billback_Payee_Type_ID,
			(
			SELECT ISNULL(SUM(Item_Volume_Paid_CS),0)
			FROM         dbo.Billback INNER JOIN
		                      dbo.Billback_Program  ON dbo.Billback.Billback_ID = dbo.Billback_Program.Billback_ID INNER JOIN
		                      dbo.Billback_Product ON dbo.Billback.Billback_ID = dbo.Billback_Product.Billback_ID INNER JOIN
		                      dbo.BB_Item_Final ON dbo.Billback_Product.Billback_Product_ID = dbo.BB_Item_Final.Billback_Product_ID INNER JOIN
		                      dbo.BB_Approved D ON dbo.Billback.Billback_ID = D.Billback_ID
			WHERE   
					(dbo.Billback.Billback_Status_ID >= 3) AND (dbo.Billback_Program.Program_ID IN(#get_latest_billback_numbers_Program_ID_List#)) 
		AND (dbo.Billback_Product.Product_ID =  '#BSA_Foodservice_Items_Master_ID#')
					AND D.Date_Approved <= dbo.BB_Approved.Date_Approved 
		
		
			) AS RunningBBTotal,
		
		(SELECT ISNULL(dbo.Program_Product_Volume.Volume_CS,0) - (
			SELECT ISNULL(SUM(Item_Volume_Paid_CS),0)
			FROM         dbo.Billback INNER JOIN
		                      dbo.Billback_Program  ON dbo.Billback.Billback_ID = dbo.Billback_Program.Billback_ID INNER JOIN
		                      dbo.Billback_Product ON dbo.Billback.Billback_ID = dbo.Billback_Product.Billback_ID INNER JOIN
		                      dbo.BB_Item_Final ON dbo.Billback_Product.Billback_Product_ID = dbo.BB_Item_Final.Billback_Product_ID INNER JOIN
		                      dbo.BB_Approved F ON dbo.Billback.Billback_ID = F.Billback_ID
			WHERE   
					(dbo.Billback.Billback_Status_ID >= 3) AND (dbo.Billback_Program.Program_ID IN(#get_latest_billback_numbers_Program_ID_List#)) 
		AND (dbo.Billback_Product.Product_ID =  '#BSA_Foodservice_Items_Master_ID#')
					AND F.Date_Approved <= dbo.BB_Approved.Date_Approved 
		
		
			)) AS Balance
							  
		FROM         dbo.Billback INNER JOIN
		                      dbo.Billback_Program ON dbo.Billback.Billback_ID = dbo.Billback_Program.Billback_ID INNER JOIN
		                      dbo.Billback_Product ON dbo.Billback.Billback_ID = dbo.Billback_Product.Billback_ID INNER JOIN
		                      dbo.BB_Item_Final ON dbo.Billback_Product.Billback_Product_ID = dbo.BB_Item_Final.Billback_Product_ID INNER JOIN
		                      dbo.BB_Approved ON dbo.Billback.Billback_ID = dbo.BB_Approved.Billback_ID INNER JOIN
		                      dbo.Program_Product_Volume ON dbo.Billback_Product.Product_ID = dbo.Program_Product_Volume.BSA_Foodservice_Items_Master_ID AND 
		                      dbo.Billback_Program.Program_ID = dbo.Program_Product_Volume.Program_ID INNER JOIN
                      dbo.Billback_Distributor ON dbo.Billback.Billback_ID = dbo.Billback_Distributor.Billback_ID INNER JOIN
                      dbo.BSA_Foodservice_Customers ON 
                      dbo.Billback_Distributor.Distributor_ID = dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
		WHERE     (dbo.Billback.Billback_Status_ID >= 3) AND (dbo.Billback_Program.Program_ID IN(#get_latest_billback_numbers_Program_ID_List#)) AND 
		                      (dbo.Billback_Product.Product_ID = '#BSA_Foodservice_Items_Master_ID#') AND dbo.Program_Product_Volume.deleted = 0
		ORDER BY dbo.Billback.BB_Date
		</cfquery>		
	</cfif>
	
	
	<!--- show monthly bilback break out --->
	<cfif url.ReportBBDetail EQ 1>
		<cfif GetALLBBs.recordcount GT 0>
				<cfquery name="getDistinctMonths" dbtype="query">
					SELECT Distinct Month_Number, Month_Name FROM GetALLBBs
				</cfquery>
				<cfloop query="getDistinctMonths">

				<cfset thisMonthNumber 	= getDistinctMonths.Month_Number>
				<cfset thisMonthName	= getDistinctMonths.Month_Name>
								
				<cfquery name="GetBBs" dbtype="query">
					SELECT * FROM GetALLBBs
					WHERE Month_Number = #thisMonthNumber#
				</cfquery>
				
				<tr>
					<td colspan="100%" bgcolor="white" height="10px">&nbsp;</td>
				</tr>
				<tr>

						<td colspan="3" bgcolor="##FFFFFF" >
						<p align="center" ><span style="font-size: 12px; color:Red; font-weight:bold;">#UCASE(thisMonthName)# #application.returned_customer_setting.distributor_label_singular# Deliveries (#GetBBs.Distributor_Name#)</span><!--- <b>Transaction Detail</b> --->&nbsp;</td>
						<td colspan="3" bgcolor="##FFFFFF" >
						<p align="center" ><b>Allocation of Commodity</b></td>
						<td colspan="2" bgcolor="##FFFFFF" >
						<p align="center" ><b>Use of Commodity</b></td>
						<td bgcolor="##FFFFFF" >
						<b>Ending</b></td>
						<td bgcolor="##FFFFFF" >
					<b>Value</b></td>
				</tr>
				<tr>
					<td bgcolor="##FFFFFF" >
					<b>Date</b></td>
					<td bgcolor="##FFFFFF" colspan="2" >
					<b>Ref. ##</b></td>
					<td bgcolor="##FFFFFF" colspan="100%">&nbsp;</td>
				</tr>

				<cfinclude template="billback_breakout_code.cfm">
				<cfinclude template="BB_Column_Totals.cfm">

				</cfloop>
		<tr>
			<td colspan="100%" bgcolor="white" height="15px">&nbsp;</td>
		</tr>				

			</td>
		</tr>
		<cfelse>
			<tr>
				<td colspan="100%" align="center" bgcolor="white"><b style="color: red; font-weight:bold;">No #application.returned_customer_setting.distributor_label_singular# Deliveries Available</b></td>
			</tr>
		
		</cfif>
		<tr>
			<td colspan="100%" bgcolor="white" height="15px">&nbsp;</td>
		</tr>
	</cfif>

	<cfif url.ReportBBDetail EQ "2">
		<cfquery name="GetBBs" dbtype="query">
			SELECT * FROM GetALLBBs
		</cfquery>
			<cfif GetALLBBs.recordcount GT 0>
			<tr>
					<td colspan="3" bgcolor="##FFFFFF" >
					<p align="center" ><span style="font-size: 12px; color:Red; font-weight:bold;">Billbacks</span><!--- <b>Transaction Detail</b> --->&nbsp;</td>
					<td colspan="3" bgcolor="##FFFFFF" >
					<p align="center" ><b>Allocation of Commodity</b></td>
					<td colspan="2" bgcolor="##FFFFFF" >
					<p align="center" ><b>Use of Commodity</b></td>
					<td bgcolor="##FFFFFF" >
					<b>Ending</b></td>
					<td bgcolor="##FFFFFF" >
				<b>Value</b></td>
			</tr>
			<cfinclude template="billback_breakout_code.cfm">
			<cfinclude template="BB_Column_Totals.cfm">
		<tr>
			<td colspan="100%" bgcolor="white" height="15px">&nbsp;</td>
		</tr>				

		<cfelse>
			<tr>
				<td colspan="100%" align="center" bgcolor="white"><b style="color: red; font-weight:bold;">No Billbacks Available</b></td>
			</tr>		
		</cfif>	
	</cfif>
</cfoutput>
