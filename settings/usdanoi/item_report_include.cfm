<cfsilent>
<cfquery name="TheSecondQuery" dbtype="query">
	SELECT distinct * FROM TheQuery ORDER BY Item, Operator_Name,BB_Date_Month_Number,BB_Date
</cfquery>

			<cfset thisCurrentrow = 0>
			<cfset TotalItemTotalStructName = "TotalItemTotalStructName">
			<cfset #TotalItemTotalStructName# = initTotalStructPrototype("TotalItemTotalStructName")>
</cfsilent>
			<!--- Begin - ITEM Output --->
			<cfoutput query="TheSecondQuery" group="Item">
			<cfsilent>
				<cfswitch expression="#lcase(url.ReportUOM)#">
					<cfcase value="1"><!--- cs --->
						<cfset uom_PTV 		= TheSecondQuery.PTV_CS>
						<cfset uom_PTV 		= trim(NumberFormat(uom_PTV, '______.____'))>
						<cfset uom_str 		= "&nbsp;cs">
					</cfcase>
					<cfcase value="2"><!--- lb --->
						<cfset uom_PTV 		= TheSecondQuery.PTV_LB>
						<cfset uom_PTV		= trim(NumberFormat(uom_PTV, '______.____'))>
						<cfset uom_str 		= "&nbsp;lbs">
						<cfset uom_cs		= "&nbsp;cs">
						<cfset uom_cases	= TheSecondQuery.LastBBClaim_CS> <!--- Dev Note: KAL; 8161 --->
					</cfcase>
					<cfcase value="rm"><!--- rm --->
						<cfset uom_PTV 		= TheSecondQuery.PTV_RM>
						<cfset uom_PTV		= trim(NumberFormat(uom_PTV, '______.____'))>
						<cfset uom_str 		= "&nbsp;lbs">
						<cfset uom_cs		= "&nbsp;cs">
						<cfset uom_cases	= TheSecondQuery.LastBBClaim_CS> <!--- Dev Note: KAL; 8161 --->
					</cfcase>
				</cfswitch>

				<CFSET ItemTotalStructName = "ItemTotalStructName_#TheSecondQuery.BSA_Foodservice_Items_Master_ID#">
				<cfset #ItemTotalStructName# = initTotalStructPrototype("ItemTotalStructName_#TheSecondQuery.BSA_Foodservice_Items_Master_ID#")>

				<cfif url.ReportBBDetail EQ 0>
					<cfset thisCurrentrow = thisCurrentrow + 1>
				</cfif>
				</cfsilent>
				<tr bgcolor="<cfif url.ReportBBDetail EQ 0><CFIF thisCurrentrow mod 2>##CCFFCC<CFELSE>WhiteSmoke</CFIF><cfelse>##ffffcc</cfif>"><b style="font-size: 11px;">
					<td  nowrap><cfif url.ReportBBDetail EQ 0><FONT size="1">&nbsp;</FONT></cfif></td>
					<td  nowrap><cfif url.ReportBBDetail EQ 1><b><font size="2">#TheSecondQuery.Item#</font></b><cfelse>#TheSecondQuery.Item#</cfif></td>
					<td colspan="<cfif url.ReportBBDetail EQ 1>99%<cfelse>1</cfif>" nowrap><cfif url.ReportBBDetail EQ 1><b><font size="2">#TheSecondQuery.Description#</font></b><cfelse>#TheSecondQuery.Description#</cfif></td>
					<cfif url.ReportBBDetail EQ 0><td align="right"><b>#trim(numberformat(uom_PTV, '___,___,___.____'))##uom_str#</b></td></cfif>
				<cfif url.ReportBBDetail EQ 1></tr></cfif>
				
				<!--- Begin - Operator --->
				<cfoutput group="BSA_Operator_ID">
					
					<CFSET OpItemTotalStructName = "OpItemTotalStructName_#replace(TheSecondQuery.BSA_Foodservice_Items_Master_ID, '-','_','ALL')#">
					<cfset #OpItemTotalStructName# = initTotalStructPrototype("OpItemTotalStructName_#replace(TheSecondQuery.BSA_Foodservice_Items_Master_ID, '-','_','ALL')#")>
					
					<cfif url.ReportBBDetail EQ 1>
						<tr><td colspan="100%">&nbsp;&nbsp;<b><font size="2">#TheSecondQuery.Operator_Name#-#TheSecondQuery.Legacy_ID#</font></b></td></tr>
					</cfif>

					<cfset uom_TotalClaimAmount = 0>
					
					<!--- Begin - Billback --->							
					<cfoutput group="Billback_ID">
						<cfsilent>
								<cfquery name="getRowCount" dbtype="query">
									SELECT count(*) AS TotalRows
									FROM RunQuery
								</cfquery>
								
								<CFSET TotalRowCount = getRowCount.TotalRows>
								
								<cfif len(trim(TotalRowCount)) EQ 0>
									<CFSET TotalRowCount = 0>
								</cfif>
								<CFSET NextTotalRowCount = TotalRowCount + 1>
								
								<CFIF TotalRowCount GT 0>
									<cfquery name="checkRunQuery" dbtype="query">
										SELECT * 
										FROM RunQuery
										WHERE 
										OPID = '#TheSecondQuery.BSA_Operator_ID#'
			 							AND
										PID = '#toString(TheSecondQuery.BSA_Foodservice_Items_Master_ID)#'
									</cfquery>
								<cfelse>
									<CFSET checkRunQuery.recordcount = 0>
								</CFIF>
								
								<cfif checkRunQuery.recordcount EQ 0>
									<!--- <cfdump var="#RunQuery#"> --->
									<cfset uom_LastBBClaim	 = 0>
									
									<cfswitch expression="#lcase(url.ReportUOM)#">
										<cfcase value="1"><cfset uom_BegBal = TheSecondQuery.TotalProductProgramVolume_CS></cfcase>
										<cfcase value="2"><cfset uom_BegBal = TheSecondQuery.TotalProductProgramVolume_LB></cfcase>
										<cfcase value="rm"><cfset uom_BegBal = TheSecondQuery.TotalProductProgramVolume_RM></cfcase>
									</cfswitch>
									


									<cfset temp = queryaddrow(RunQuery)>
									<cfset temp = QuerySetCell(RunQuery, "RC", NextTotalRowCount)>
									<cfset temp = QuerySetCell(RunQuery, "OPID", toString(trim(TheSecondQuery.BSA_Operator_ID)))>
									<cfset temp = QuerySetCell(RunQuery, "PID", toString(trim(TheSecondQuery.BSA_Foodservice_Items_Master_ID)))>
									<cfset temp = QuerySetCell(RunQuery, "CURRBAL", uom_BegBal)>
									<!--- <cfdump var="#RunQuery#"> --->
								<cfelse>
									<cfswitch expression="#lcase(url.ReportUOM)#">
										<cfcase value="1"><cfset uom_LastBBClaim = TheSecondQuery.LastBBClaim_CS></cfcase>
										<cfcase value="2"><cfset uom_LastBBClaim = TheSecondQuery.LastBBClaim_LB></cfcase>
										<cfcase value="rm"><cfset uom_LastBBClaim = TheSecondQuery.LastBBClaim_RM></cfcase>
									</cfswitch>							
									
									<cfset uom_BegBal 		= checkRunQuery.CURRBAL - uom_LastBBClaim>
									<cfset temp 			= QuerySetCell(RunQuery, "CURRBAL", uom_BegBal, checkRunQuery.RC)>
								</cfif> 
						
					
								<cfswitch expression="#lcase(url.ReportUOM)#">
									<cfcase value="1"><!--- cs --->
										<cfset uom_PTV 							= TheSecondQuery.PTV_CS>
										<cfset uom_PTV 							= trim(NumberFormat(uom_PTV, '______.____'))>
										<cfset uom_TotalProductProgramVolume 	= TheSecondQuery.TotalProductProgramVolume_CS>
										<cfset uom_LastBBClaim	 				= TheSecondQuery.LastBBClaim_CS>
										<cfset uom_str 							= "&nbsp;cs">
									</cfcase>
									<cfcase value="2"><!--- lb --->
										<cfset uom_PTV 							= TheSecondQuery.PTV_LB>
										<cfset uom_PTV 							= trim(NumberFormat(uom_PTV, '______.____'))>
										<cfset uom_TotalProductProgramVolume 	= TheSecondQuery.TotalProductProgramVolume_LB>
										<cfset uom_LastBBClaim	 				= TheSecondQuery.LastBBClaim_LB>
										<cfset uom_str 							= "&nbsp;lbs">
										<cfset uom_cs							= "&nbsp;cs">
										<cfset uom_cases						= TheSecondQuery.LastBBClaim_CS> <!--- Dev Note: KAL; 8161 --->
									</cfcase>
									<cfcase value="rm"><!--- rm --->
										<cfset uom_PTV 							= TheSecondQuery.PTV_RM>
										<cfset uom_PTV 							= trim(NumberFormat(uom_PTV, '______.____'))>
										<cfset uom_TotalProductProgramVolume 	= TheSecondQuery.LastBBClaim_LB/ RM_Conversion_Value>
										<cfset uom_LastBBClaim	 				= TheSecondQuery.LastBBClaim_LB / RM_Conversion_Value>
										<cfset uom_str 							= "&nbsp;lbs">
										<cfset uom_cs							= "&nbsp;cs">
										<cfset uom_cases						= TheSecondQuery.LastBBClaim_CS> <!--- Dev Note: KAL; 8161 --->									
									</cfcase>
								</cfswitch>
			
								<cfset uom_TotalClaimAmount 			= uom_TotalClaimAmount + uom_LastBBClaim>
								<cfset uom_EndingBalance				= uom_BegBal-uom_TotalClaimAmount>
								<cfset uom_ValueAvailable				= uom_PTV*uom_EndingBalance>
								<cfset uom_ValueUsed					= uom_PTV*uom_LastBBClaim>
								
								<cfset temp = addToTotal(OpItemTotalStructName, "BEGBAL", uom_BegBal)>
								<cfset temp = addToTotal(OpItemTotalStructName, "BBCURRENT", uom_LastBBClaim)>
								<cfset temp = addToTotal(OpItemTotalStructName, "VALUEUSED", uom_ValueUsed)>
								<cfset temp = addToTotal(OpItemTotalStructName, "BBCUME", uom_LastBBClaim)>
								<cfset temp = addToTotal(OpItemTotalStructName, "ENDBAL", uom_EndingBalance)>
								<cfset temp = addToTotal(OpItemTotalStructName, "VALUEAVAIL", uom_ValueAvailable)>
								<cfset temp = addToTotal(OpItemTotalStructName, "CASES", uom_Cases)>
							</cfsilent>
							<cfif url.ReportBBDetail EQ 1>
								<cfset thisCurrentrow = thisCurrentrow + 1>
								<tr bgcolor="<CFIF thisCurrentrow mod 2>##CCFFCC<CFELSE>WhiteSmoke</CFIF>">
									<td  nowrap><FONT size="1">#DateFormat(TheSecondQuery.BB_Date, 'mm-dd-yyyy')#</FONT></td>
									<td colspan="2" align="right">&nbsp;&nbsp;&nbsp;&nbsp;
										#TheSecondQuery.BB_Title# - #TheSecondQuery.BB_Reference#
									</td>
									<td align="right">#trim(numberformat(uom_PTV, '___,___,___.____'))#</td>
									<cfif lcase(url.ReportType) NEQ "item" AND  lcase(url.ReportType) NEQ "operator-item" AND  lcase(url.ReportType) NEQ "operator-month-item">
										<td align="right">#trim(NumberFormat(uom_BegBal, '___,___,___,___,___'))#</td><!--- Beggining Volume --->
										<td align="right">#trim(NumberFormat(0, '___,___,___,___,___'))#</td>
										<td align="right">#trim(NumberFormat(uom_BegBal, '___,___,___,___,___'))#</td>
									</cfif>
									<td align="right">#trim(NumberFormat(uom_LastBBClaim, '-___,___,___,___,___'))##uom_str#</td>
									<td align="right">#trim(NumberFormat(uom_Cases, '-___,___,___,___,___'))##uom_cs#</td>
									<td align="right">#trim(NumberFormat(uom_ValueUsed, '-$___,___,___,___,___.__'))#</td>
									<td align="right">#trim(NumberFormat(uom_TotalClaimAmount, '-___,___,___,___,___'))##uom_str#</td> 
									 <td align="right">#trim(NumberFormat(uom_TotalClaimAmount, '-___,___,___,___,___'))##uom_str#</td>
									<td align="right">&nbsp; </td>
								</tr>
							</cfif>
							
						</cfoutput> <!--- end Billback --->
						<cfsilent>
						<cfset temp = addToTotal(ItemTotalStructName, "BEGBAL", OpItemTotalStructName.BEGBAL)>
						<cfset temp = addToTotal(ItemTotalStructName, "BBCURRENT", OpItemTotalStructName.BBCURRENT)>
						<cfset temp = addToTotal(ItemTotalStructName, "VALUEUSED", OpItemTotalStructName.ValueUsed)>
						<cfset temp = addToTotal(ItemTotalStructName, "BBCUME", OpItemTotalStructName.BBCURRENT)>
						<cfset temp = addToTotal(ItemTotalStructName, "ENDBAL", OpItemTotalStructName.ENDBAL)>
						<cfset temp = addToTotal(ItemTotalStructName, "VALUEAVAIL", OpItemTotalStructName.VALUEAVAIL)>
						<cfset temp = addToTotal(ItemTotalStructName, "CASES", OpItemTotalStructName.CASES)>	</cfsilent>
					</cfoutput> <!--- end Operator --->
				
						<!--- Item Sums --->
						<cfif url.ReportBBDetail EQ 0>
								<cfset tempuom_str = uom_str>
								<cfset uom_str = "">
								
								<td align="right"><b>#trim(NumberFormat(ItemTotalStructName.BBCurrent, '-___,___,___,___,___'))##uom_str#</b></td>
								<td align="right">#trim(NumberFormat(ItemTotalStructName.Cases, '-___,___,___,___,___'))##uom_cs#</td>
								<td align="right"><b>#trim(NumberFormat(ItemTotalStructName.ValueUsed, '-$___,___,___,___,___.__'))#</b></td>								
								<td align="right"><b>#trim(NumberFormat(ItemTotalStructName.BBCume, '-___,___,___,___,___'))##uom_str#</b></td>
								<td align="right"><b>#trim(NumberFormat(ItemTotalStructName.BBCume, '-___,___,___,___,___'))##uom_str#</b></td>
								<td align="right"><b>&nbsp; </b></td>
							</tr>
		
							<cfset uom_str = tempuom_str>
						<cfelse>
						<cfset thisStrLen1 = len(TheSecondQuery.Operator_Name)>
						<cfset thisStrLen2 = len(TheSecondQuery.Item)>
						<cfset maxStrLen = 20>
							<tr bgcolor="##6a5acd">	
								<td colspan="4" align="CENTER" title="#TheSecondQuery.Operator_Name#" style="color: white;" nowrap>
									<b>#MID(TheSecondQuery.Operator_Name, 1, maxStrLen)#<cfif thisStrLen1 GT maxStrLen>...</cfif>&nbsp;#MID(TheSecondQuery.Item, 1, maxStrLen)#<cfif thisStrLen2 GT maxStrLen>...</cfif> Total:</b>
								</td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(ItemTotalStructName.BBCurrent, '-___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(ItemTotalStructName.Cases, '-___,___,___,___,___'))##uom_cs#</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(ItemTotalStructName.ValueUsed, '-$___,___,___,___,___.__'))#</b></td>								
								<td align="right" style="color: white;"><b>#trim(NumberFormat(ItemTotalStructName.BBCume, '-___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(ItemTotalStructName.BBCume, '-___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;">&nbsp; </td>
							</tr>
							<tr>
								<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
							</tr>
						</cfif>
							<cfsilent>
							<cfset temp = addToTotal(TotalItemTotalStructName, "BEGBAL", ItemTotalStructName.BEGBAL)>
							<cfset temp = addToTotal(TotalItemTotalStructName, "BBCURRENT", ItemTotalStructName.BBCURRENT)>
							<cfset temp = addToTotal(TotalItemTotalStructName, "VALUEUSED", ItemTotalStructName.ValueUsed)>
							<cfset temp = addToTotal(TotalItemTotalStructName, "BBCUME", ItemTotalStructName.BBCUME)>
							<cfset temp = addToTotal(TotalItemTotalStructName, "ENDBAL", ItemTotalStructName.ENDBAL)>
							<cfset temp = addToTotal(TotalItemTotalStructName, "VALUEAVAIL", ItemTotalStructName.VALUEAVAIL)>
							<cfset temp = addToTotal(TotalItemTotalStructName, "CASES", ItemTotalStructName.CASES)>
	</cfsilent> <!--- Dev Note: KAL; 8161 --->
				</cfoutput> <!--- end ITEM Output --->
				
				<cfoutput>
				<tr>	
					<td colspan="4" align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>Report Total:</b></td>
					
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalItemTotalStructName.BBCurrent, '-___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalItemTotalStructName.Cases, '-___,___,___,___,___'))##uom_cs#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalItemTotalStructName.ValueUsed, '-$___,___,___,___,___.__'))#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalItemTotalStructName.BBCume, '-___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalItemTotalStructName.BBCume, '-___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>&nbsp; </td>

				</tr>
				<tr>
					<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
				</tr>
				</cfoutput>		