<cfoutput>					<cfquery name="getReportStats" dbtype="query">
						SELECT 
							AVG(PTV) AS AvgPTV,
							SUM(BegBal) AS TotalBegBal,
							SUM(LastBBClaim) AS TotalLastBBClaim,
							SUM(TotalBBClaim) AS TotalBBClaim,
							SUM(EndBal) AS TotalEndBal,
							SUM(ValueAvail) AS TotalValueAvail
						FROM getProgramItemsInGeography
						WHERE BSA_Foodservice_Items_Master_ID = '#thisItem_ID#' AND Program_ID IN(#programList#)
					</cfquery>
								<CFSET PTV = getReportStats.AvgPTV>
								<CFSET ProgramProductVolume = getReportStats.TotalBegBal>					
								<CFSET Cumemulative_1 = 0>
								<CFSET LastClaimAmount = getReportStats.TotalLastBBClaim>
								<CFSET TotalClaimAmount = getReportStats.TotalBBClaim>
								<CFSET EndingBalance = getReportStats.TotalEndBal>
								<CFSET ValueAvailable = getReportStats.TotalValueAvail>
														
								<Td align="right">#trim(numberformat(PTV, '___,___,___.____'))#</TD>
								<td align="right">
								<!--- Beggining Volume --->
								<cfset tempA = ProgramProductVolume>
								#trim(NumberFormat(ProgramProductVolume, '___,___,___,___,___'))#
								</td>

								<Td align="right">#trim(NumberFormat(Cumemulative_1, '___,___,___,___,___'))#</TD>
								<td align="right">#trim(NumberFormat(tempA, '___,___,___,___,___'))#</td>
								<td align="right">
									<CFSET tempA = LastClaimAmount>
									#trim(NumberFormat(tempA, '___,___,___,___,___'))#						
								</td>
								<td align="right">
									<CFSET tempA = TotalClaimAmount>
									#trim(NumberFormat(tempA, '___,___,___,___,___'))#								
								</td>
								<td align="right">
									<CFSET tempA = EndingBalance>
									#trim(NumberFormat(tempA, '___,___,___,___,___'))#
								</td>
								<td align="right">#trim(NumberFormat(ValueAvailable, '___,___,___,___,___.__'))#</td> 	</cfoutput>