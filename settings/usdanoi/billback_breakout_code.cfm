<cfoutput>
		<cfquery name="getPayee" datasource="#application.datasource#">
			<cfswitch expression="#GetBBs.Billback_Payee_Type_ID#">
				<cfcase value="1"><!--- Dstributor --->
SELECT     dbo.BSA_Foodservice_Customers.Name AS Payee_Name
FROM         dbo.Billback_Distributor INNER JOIN
                      dbo.BSA_Foodservice_Customers ON 
                      dbo.Billback_Distributor.Distributor_ID = dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
WHERE dbo.Billback_Distributor.Billback_ID = '#GetBBs.Billback_ID#' AND dbo.Billback_Distributor.Deleted = 0
				</cfcase>
				<cfcase value="2"><!--- Operator --->
SELECT     dbo.BSA_Operator.Operator_Name AS Payee_Name
FROM         dbo.Billback_Operator INNER JOIN
                      dbo.BSA_Operator ON dbo.Billback_Operator.Operator_ID = dbo.BSA_Operator.BSA_Operator_ID
WHERE     (dbo.Billback_Operator.Billback_ID = '#GetBBs.Billback_ID#') AND (dbo.Billback_Operator.Deleted = 0)				
				</cfcase>
				<cfcase value="3"><!--- Broker --->
SELECT     dbo.BSA_Foodservice_Brokers.Broker_Name AS Payee_Name
FROM         dbo.BSA_Foodservice_Brokers INNER JOIN
                      dbo.Billback_Broker ON dbo.BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = dbo.Billback_Broker.Broker_ID
WHERE     (dbo.Billback_Broker.Billback_ID = '#GetBBs.Billback_ID#') AND (dbo.Billback_Broker.Deleted = 0)				
				</cfcase>
				
				<cfdefaultcase><!--- unknown --->
SELECT     BB_UP_Name AS Payee_Name
FROM         dbo.Billback_Unidentified_Payee
WHERE     (Deleted = 0) AND (Billback_ID = '#GetBBs.Billback_ID#')
				</cfdefaultcase>
			</cfswitch>
		</cfquery>
		<cfset FinalPayeeName = getPayee.Payee_Name>
		<cfif len(trim(FinalPayeeName)) EQ 0>
			<cfset FinalPayeeName = "Unidentified Payee">
		</cfif>
<cfset THISCURRENTROW = 1>
<cfset d = USDA_FinalPrice_Per_USDA_UOM>
<cfif getGeoBasedReport.ProgramDateSpanInDays GT 0>
<cfset TotalVolume = (getGeoBasedReport.Volume_CS * getGeoBasedReport.ProgramDateSpanInDays) / 7>
<cfset TotalVolume = trim(numberformat(TotalVolume, '_________._'))>
	<cfif USDA_UOM EQ 2>
	<!--- Pound --->
	<cfset d = getGeoBasedReport.net_weight * d>
	</cfif>
<cfelse>

<CFSET TotalVolume = getGeoBasedReport.Volume_CS>
	
</cfif>
<cfset form.Final_BB_total_BeginningVolume 	= 0>
<cfset form.Final_BB_total_Current_1 		= 0>
<cfset form.Final_BB_total_Current_2 		= 0>
<cfset form.Final_BB_total_Cumulative_2 	= 0>
<cfset form.Final_BB_total_Ending_Balance 	= 0>
<cfset form.Final_BB_total_Value_Available	= 0>
<cfloop query="GetBBs">
	<!--- Column Total temp variables --->			
	<cfset form.currentItem_BB_total_BeginningVolume 	= 0>
	<cfset form.currentItem_BB_total_Current_1 			= 0>
	<cfset form.currentItem_BB_total_Current_2 			= 0>
	<cfset form.currentItem_BB_total_Cumulative_2 		= 0>
	<cfset form.currentItem_BB_total_Ending_Balance 	= 0>
	<cfset form.currentItem_BB_total_Value_Available	= 0>

	<tr bgcolor="<CFIF thisCurrentrow mod 2>##CCFFCC<CFELSE>White</CFIF>">
		<td nowrap>
		<a href="/billbacks/capture/INDEX.CFM?bbid=#GetBBs.Billback_ID#">#GetBBs.BB_Title#</a></td>
		<td colspan="2">
		<a href="/billbacks/capture/INDEX.CFM?bbid=#GetBBs.Billback_ID#">#GetBBs.BB_Reference# (#FinalPayeeName#)</a></td>
		
		<cfset tempA = TotalVolume>
		<td align="right" x:num="5000">
		<cfswitch expression="#form.thisReportUOM#">
			<!--- case --->
			<cfcase value="1">
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
			<!--- poound --->
			<cfcase value="2">
				<cfset tempA = tempA * getGeoBasedReport.Net_Weight>
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
			<!--- raw materials --->
			<cfcase value="rm">
				<cfset pYield = YIELD_OUT/100>
				<cfset tempA = tempA * getGeoBasedReport.net_weight>
				<cfset tempA = tempA / pYield>
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
		</cfswitch>
		</td>
		<cfset form.currentItem_BB_total_BeginningVolume = tempA>
		<cfset form.Final_BB_total_BeginningVolume = form.Final_BB_total_BeginningVolume + trim(numberformat(form.currentItem_BB_total_BeginningVolume, '_______________.____'))>

		
		<cfset c = trim(numberformat(TotalVolume, '_________'))>
		<td align="right" x:num="0">0</td>

		<cfset tempA = TotalVolume>
		<td align="right" x:num="5000" x:fmla="=E4+C5+D5">
		<cfswitch expression="#form.thisReportUOM#">
			<!--- case --->
			<cfcase value="1">
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
			<!--- poound --->
			<cfcase value="2">
				<cfset tempA = tempA * getGeoBasedReport.Net_Weight>
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
			<!--- raw materials --->
			<cfcase value="rm">
				<cfset pYield = YIELD_OUT/100>
				<cfset tempA = tempA * getGeoBasedReport.net_weight>
				<cfset tempA = tempA / pYield>
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
		</cfswitch></td>
		
		<cfset tempA = GetBBs.Item_Volume_Paid_CS>
		<td align="right" x:num="500">
		<cfswitch expression="#form.thisReportUOM#">
			<!--- case --->
			<cfcase value="1">
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
			<!--- poound --->
			<cfcase value="2">
				<cfset tempA = tempA * getGeoBasedReport.Net_Weight>
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
			<!--- raw materials --->
			<cfcase value="rm">
				<cfset pYield = YIELD_OUT/100>
				<cfset tempA = tempA * getGeoBasedReport.net_weight>
				<cfset tempA = tempA / pYield>
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
		</cfswitch>
		</td>
		<cfset form.currentItem_BB_total_Current_2 = tempA>
		<cfset form.Final_BB_total_Current_2 = form.Final_BB_total_Current_2 + trim(numberformat(form.currentItem_BB_total_Current_2, '_______________.____'))>		
		
		<cfset e = trim(numberformat(GetBBs.RunningBBTotal, '_________'))>
		<cfset tempA = e>
		<td align="right" x:num="500" x:fmla="=F5">
		<cfswitch expression="#form.thisReportUOM#">
			<!--- case --->
			<cfcase value="1">
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
			<!--- poound --->
			<cfcase value="2">
				<cfset tempA = tempA * getGeoBasedReport.Net_Weight>
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
			<!--- raw materials --->
			<cfcase value="rm">
				<cfset pYield = YIELD_OUT/100>
				<cfset tempA = tempA * getGeoBasedReport.net_weight>
				<cfset tempA = tempA / pYield>
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
		</cfswitch></td>
		<cfset form.currentItem_BB_total_Cumulative_2 = tempA>
		<cfset form.Final_BB_total_Cumulative_2 = form.Final_BB_total_Cumulative_2 + trim(numberformat(form.currentItem_BB_total_Cumulative_2, '_______________.____'))>				

		<CFSET f = c-e>
		<cfset tempA = f>
		<td align="right" x:num="4500" x:fmla="=E5-G5">
		<cfswitch expression="#form.thisReportUOM#">
			<!--- case --->
			<cfcase value="1">
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
			<!--- poound --->
			<cfcase value="2">
				<cfset tempA = tempA * getGeoBasedReport.Net_Weight>
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
			<!--- raw materials --->
			<cfcase value="rm">
				<cfset pYield = YIELD_OUT/100>
				<cfset tempA = tempA * getGeoBasedReport.net_weight>
				<cfset tempA = tempA / pYield>
				#trim(numberformat(tempA, '___,___,___'))#
			</cfcase>
		</cfswitch>		
		</td>
		<cfset form.currentItem_BB_total_Ending_Balance = tempA>
		<cfset form.Final_BB_total_Ending_Balance = form.Final_BB_total_Ending_Balance + trim(numberformat(form.currentItem_BB_total_Ending_Balance, '_______________.____'))>				
		
		<cfset g = f * d>
		<cfset tempA = g>
		<td align="right" x:num="22860">$#trim(numberformat(g, '___,___,___.__'))# </td>
		<cfset form.currentItem_BB_total_Value_Available = tempA>
		<cfset form.Final_BB_total_Value_Available = form.Final_BB_total_Value_Available + trim(numberformat(form.currentItem_BB_total_Value_Available, '_______________.____'))>			
	
	</tr>
	<cfset THISCURRENTROW  = THISCURRENTROW + 1>
</cfloop></cfoutput>