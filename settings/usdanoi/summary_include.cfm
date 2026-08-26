<!---Variables reused --->
<cfparam name="VolumeBalance" 	default="0">
<cfparam name="DollarBalance" 	default="0">
<cfparam name="PercentBalance" 	default="0">
<cfparam name="Yield" 			default="0">
<cfparam name="Raw_Price" 		default="0">

<!---Gets raw materials pass through value -- will need to be re-written for multiple items with different PTV --->
<cfquery name="GetPTV" datasource="#application.datasource#">
SELECT TOP 1 Yield, Raw_Price FROM USDA_NOI_EPDS
</cfquery>

<cfset Yield = GetPTV.Yield>
<cfset Raw_Price = GetPTV.Raw_Price>

<!---Header --->
<cfoutput>
	<tr >
		<td bgcolor="##FFFFFF" >
		<p align="center"><b>Measured in <cfswitch expression="#form.thisReportUOM#">
											<!--- case --->
											<cfcase value="1">Cases</cfcase>
											<cfcase value="2">Net Pounds</cfcase>
											<cfcase value="rm">Raw Materials</cfcase>
		</cfswitch></b></td>
		<td bgcolor="##FFFFFF" >&nbsp;</td>
	</tr>
	
	<tr align="right">
		<td bgcolor="##FFFFFF"><strong>Recipient Agency</strong></td>
		<td bgcolor="##FFFFFF"><strong>Allocation</strong></td>
		<td bgcolor="##FFFFFF"><strong>Commodity Used</strong></td>
		<td bgcolor="##FFFFFF"><strong>Remaining Balance</strong></td>
		 <td bgcolor="##FFFFFF"><strong>Balance in $</strong></td>
		<td bgcolor="##FFFFFF"><strong>% Used</strong></td>
	</tr>
	
	</cfoutput>
<!---End header --->

			<cfset thisCurrentrow = 0>
	<cfsilent>	
			<cfquery name="SummaryQuery"  datasource="#application.datasource#">
				SELECT Operator_Name, BSA_Operator_ID,
						case 
							when '#form.thisReportUOM#' = '1' then SUM(LastBBClaim_CS)
						 	when '#form.thisReportUOM#' = '2' then SUM(LastBBClaim_LB)
							else SUM(LastBBClaim_RM) 
						end	AS Sum_Billback_Volume
				FROM USDANOI_Output
				#where_clause#
				<cfif url.Distributor NEQ 0>
				and Distributor_ID = '#url.Distributor#'
				</cfif>
				GROUP BY Operator_Name, BSA_Operator_ID
				ORDER BY Operator_Name
			</cfquery>
	</cfsilent>
			<cfoutput query="SummaryQuery" group="Operator_Name" >
				<cfquery name="GetProgramAllocation" datasource="#application.datasource#">
					SELECT Contract_Quantity
					FROM Contract_Main
					WHERE deleted = 0
					and contract_main_ID in 
					(SELECT max(contract_main_ID)FROM Contract_Main 
						inner join USDANOI_Output on Contract_Main.Contract_Main_ID =  USDANOI_Output.Program_ID 
						WHERE USDANOI_Output.BSA_Operator_ID = #SummaryQuery.BSA_Operator_ID#)					
				</cfquery>

				<cfset TotalProgramAllocation = 0 />
				<cfswitch expression="#lcase(form.thisReportUOM)#">
					<cfcase value="1"><cfset TotalProgramAllocation = GetProgramAllocation.Contract_Quantity><cfset uom_str = "&nbsp;cs"></cfcase>
					<cfcase value="2"><cfset TotalProgramAllocation = GetProgramAllocation.Contract_Quantity><cfset uom_str = "&nbsp;lbs"></cfcase>
					<cfcase value="rm"><cfset TotalProgramAllocation = (GetProgramAllocation.Contract_Quantity / #RM_Conversion_Value#)><cfset uom_str = "&nbsp;lbs"></cfcase>
				</cfswitch>			
			<cfsilent>		
				<cfset thisCurrentrow = thisCurrentrow + 1>
				<cfset VolumeBalance = TotalProgramAllocation - SummaryQuery.Sum_Billback_Volume>
			
				<cfif form.thisReportUOM EQ "rm">
					<cfset ValueAvailable = VolumeBalance * 0.0602>
				<cfelse>
					<cfset ValueAvailable = VolumeBalance * 0.10945>
				</cfif>
				<cfif TotalProgramAllocation NEQ 0 and TotalProgramAllocation NEQ "">
				<cfset PercentBalance = #numberFormat((SummaryQuery.Sum_Billback_Volume/TotalProgramAllocation)*100, '999.999')# >		
				<cfelse>
				<cfset PercentBalance = 0>
				</cfif>	
			</cfsilent>
				<tr align="right" bgcolor="<CFIF thisCurrentrow mod 2>##CCFFCC<CFELSE>##FFFFCC</cfif>">
					<td>#SummaryQuery.Operator_Name#</td>
					<td>#numberformat(TotalProgramAllocation, '___,___')#</td>
					<td>#numberformat(SummaryQuery.Sum_Billback_Volume, '___,___')#</td>
					<td>#numberformat(VolumeBalance, '___,___')#</td>
					<td>#numberformat(ValueAvailable, '___,_____')#</td>
					<td>#numberformat(PercentBalance, '___,___')# %</td>
				</tr>
			</cfoutput><!--- end operator_name --->
			
			
			<!--- SHOW REPORT TOTAL --->
			<cfoutput>
			<tr>
				<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp; </td>
			</tr>		
			</cfoutput>
