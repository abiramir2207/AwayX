<cfoutput>			
			
					<cfswitch expression="#lcase(form.thisReportUOM)#">
						<cfcase value="1">
							<cfset uomStr = "&nbsp;cs">
						</cfcase>
						<cfcase value="2">
							<cfset uomStr = "&nbsp;lbs">
						</cfcase>
						<cfcase value="rm">
							<cfset uomStr = "&nbsp;lbs">
						</cfcase>
						<cfdefaultcase>
							<cfset uomStr = "">
						</cfdefaultcase>
					
					</cfswitch>
					<cfset ReportQuery=Duplicate(evaluate(ReportQueryName))>
					<cfquery name="getReportStats" dbtype="query">
						SELECT 
							AVG(PTV) AS PTV,
							SUM(BegBal) AS TotalBegBal,
							SUM(LatestBBClaimToDate) AS TotalLatestBBClaimToDate,
							SUM(TotalBBClaimToDate) AS TotalBBClaimToDate,
							0 AS TotalEndBal,
							0 AS TotalValueAvail
						FROM #ReportQueryName#
					</cfquery>
					
					<CFSET PTV = getReportStats.PTV>
					<CFSET ProgramProductVolume = getReportStats.TotalBegBal>					
					<CFSET Cumemulative_1 = 0>
					<CFSET LastClaimAmount = getReportStats.TotalLatestBBClaimToDate>
					<CFSET TotalClaimAmount = getReportStats.TotalBBClaimToDate>
					<CFSET EndingBalance = getReportStats.TotalEndBal>
					<CFSET ValueAvailable = getReportStats.TotalValueAvail>
					<TR bgcolor="##f0f8ff">

					<td colspan="2" align="right"  style="border-top: 1 solid Black;"><b>TOTAL:</b></td>
					<td align="right" style="border-top: 1 solid Black;"><b>#trim(numberformat(PTV, '___,___,___.____'))#</b></TD>
					<td align="right" style="border-top: 1 solid Black;">
					<!--- Beggining Volume --->
					<cfset tempA = ProgramProductVolume>
					<b>#trim(NumberFormat(ProgramProductVolume, '___,___,___,___,___'))##uomStr#</b>
					</td>

					<td align="right" style="border-top: 1 solid Black;"><b>#trim(NumberFormat(Cumemulative_1, '___,___,___,___,___'))##uomStr#</b></TD>
					<td align="right" style="border-top: 1 solid Black;"><b>#trim(NumberFormat(tempA, '___,___,___,___,___'))##uomStr#</b></td>
					<td align="right" style="border-top: 1 solid Black;">
						<CFSET tempA = LastClaimAmount>
						<b>#trim(NumberFormat(tempA, '___,___,___,___,___'))##uomStr#</b>						
					</td>
					<td align="right" style="border-top: 1 solid Black;">
						<CFSET tempA = TotalClaimAmount>
						<b>#trim(NumberFormat(tempA, '___,___,___,___,___'))##uomStr#</b>								
					</td>
					<td align="right" style="border-top: 1 solid Black;">
						<CFSET tempA = EndingBalance>
						<b>#trim(NumberFormat(tempA, '___,___,___,___,___'))##uomStr#</b>
					</td>
					<td align="right" style="border-top: 1 solid Black;"><b>$#trim(NumberFormat(ValueAvailable, '___,___,___,___,___.__'))#</b></td>			
					</TR></cfoutput>