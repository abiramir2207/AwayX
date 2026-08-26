<cfsilent>
<cfquery name="TheQuery2" dbtype="query">
SELECT DISTINCT * FROM TheQuery ORDER BY  Operator_Name, BB_Date_Year, BB_Date_Month_Number, Item,BB_Date, BB_Title
</cfquery>

			<cfset uom_cs = "&nbsp;cs"> <!--- Dev Note: KAL; 8161 --->			
			<cfset thisCurrentrow = 0>
			<cfset TotalAllowanceForAll = 0>

			<!--- Init Variable to tally up Report Total --->
			<CFSET TotalStructName = "TotalStructName">
			<cfset #TotalStructName# = initTotalStructPrototype("TotalStructName")>
</cfsilent>
			<!--- Begin Report Output --->
			<cfoutput query="TheQuery2" group="BSA_Operator_ID">
			<cfsilent>
			<!--- Begin: New way with program volume --->
			<cfquery name="GetProgramAllocation" datasource="#application.datasource#">
				SELECT Contract_Quantity FROM Contract_Main
				where contract_main_Id in (
				select max(Contract_Main_ID) from contract_main WHERE Contract_number in 
					(SELECT distinct contract_number FROM Contract_Main WHERE Contract_Main_ID = '#TheQuery2.Program_ID#')
				and deleted = 0 and contract_status_type_IDX > 2)
			</cfquery>

			<cfswitch expression="#lcase(url.ReportUOM)#">
				<cfcase value="1"><cfset TotalProgramAllocation = GetProgramAllocation.Contract_Quantity><cfset uom_str = "&nbsp;cs"><cfset uom_PTV = TheQuery2.PTV_CS></cfcase>
				<cfcase value="2"><cfset TotalProgramAllocation = GetProgramAllocation.Contract_Quantity><cfset uom_str = "&nbsp;lbs"><cfset uom_PTV = TheQuery2.PTV_LB></cfcase>
				<cfcase value="rm"><cfset TotalProgramAllocation = (GetProgramAllocation.Contract_Quantity / #RM_Conversion_Value#)><cfset uom_str = "&nbsp;lbs"><cfset uom_PTV = TheQuery2.PTV_RM></cfcase>
			</cfswitch>
			
			<cfset uom_BegBal = TotalProgramAllocation>
			<cfset TotalAllowanceForAll = TotalAllowanceForAll + TotalProgramAllocation>
			<!--- End: New way with program volume --->

				<!--- Init Variable to tally up OPERATOR Total --->
				<CFSET OPTotalStructName = "OPTotalStructName_#TheQuery2.BSA_Operator_ID#">
				<cfset #OPTotalStructName# = initTotalStructPrototype("OPTotalStructName_#TheQuery2.BSA_Operator_ID#")>
				<cfset uom_EndingBalance = 	TotalProgramAllocation - OPTotalStructName.BBCUME>
				<cfset uom_ValueAvailable =  uom_EndingBalance * uom_PTV>
			</cfsilent>
					<!--- Operator Row --->
					<tr>
						<td colspan="100%" nowrap align="left"><FONT FACE="Arial" size="3"><b>#TheQuery2.Operator_Name#-#TheQuery2.Legacy_ID#</b></FONT><hr color="Navy" width="100%"></td>
					</tr>
					<!--- Development Note: KAL --->
					<tr bgcolor="lightsteelblue" border="1">
						<td align="center" colspan="3">&nbsp;  Total Allocation</td>
						<td align="right">&nbsp;  #trim(NumberFormat(TotalProgramAllocation, '-___,___,___,___,___'))##uom_str#</td>
						<td align="right">&nbsp;  #trim(NumberFormat(OPTotalStructName.BBCurrent, '-___,___,___,___,___'))##uom_str#</td>
						<td align="right">&nbsp;  #trim(NumberFormat(OPTotalStructName.CASES, '-___,___,___,___,___'))##uom_cs#</td> <!--- Dev Note: KAL; 8161 --->						
						<td align="right">&nbsp;  #trim(NumberFormat(OPTotalStructName.VALUEUSED, '-$___,___,___,___,___.__'))#</td>
						<td align="right">&nbsp;  #trim(NumberFormat(OPTotalStructName.BBCUME, '-___,___,___,___,___'))##uom_str#</td>
						<td align="right">&nbsp;  #trim(NumberFormat(uom_EndingBalance, '-___,___,___,___,___'))##uom_str#</td>
						<td align="right">&nbsp;  #trim(NumberFormat(uom_ValueAvailable, '-$___,___,___,___,___.__'))#</td>
					</tr>
					<tr>
						<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
					</tr>
				
					<!--- Begin Year and Month Output --->
					<cfoutput group="BB_Date_Year">
					<cfoutput group="BB_Date_Month_Number">
					
					<!--- Init Variable to tally up OPERATOR/MONTH Total --->
					<CFSET OPMonthTotalStructName = "OPMonthTotalStructName_#BSA_operator_id##BB_Date_Month_String#">
					<cfset #OPMonthTotalStructName# = initTotalStructPrototype("OPMonthTotalStructName_#BSA_operator_id##BB_Date_Month_String#")>

						<!--- Month Row --->
						<cfif url.ReportBBDetail EQ 1>
						<tr>
							<td colspan="100%" nowrap><FONT FACE="Arial" size="2"><b>#TheQuery2.BB_Date_Month_String#, #BB_Date_Year#</b></td>
						</tr>
						</cfif>
					<!--- Begin Item Output --->
					
					<cfoutput group="Item">
					<!--- Init Variable to tally up OPERATOR/MONTH/Item Total --->
					<cfset OpMonthItemTotalStructName = "">
					<cfset OpMonthItemTotalStructName = initTotalStructPrototype("OpMonthItemTotalStructName_#createuuid()#")>

					<cfif url.ReportBBDetail EQ 0>
						<cfset thisCurrentrow = thisCurrentrow + 1>
					</cfif>
					
					<tr bgcolor="<cfif url.ReportBBDetail EQ 0><CFIF thisCurrentrow mod 2>##CCFFCC<CFELSE>WhiteSmoke</CFIF><cfelse>##f0fff0</cfif>"><b style="font-size: 11px;">
						<td  nowrap><cfif url.ReportBBDetail EQ 0>#TheQuery2.BB_Date_Month_String#, #BB_Date_Year#</cfif>&nbsp;</td>
						<td  nowrap>#TheQuery2.Item#</td></b>
						<td  colspan="<cfif url.ReportBBDetail EQ 1>100%<cfelse>1</cfif>" nowrap>#TheQuery2.Description#</td>
						<cfif url.ReportBBDetail EQ 1></tr></cfif>
						
						<cfset UOM_TOTALCLAIMAMOUNT = 0>
						
						<cfoutput group="Billback_ID">
					<cfsilent>
							<!--- END: Dev Note: KAL - 06/2005;  Added/Modified below lines: --->
					
								
								<cfswitch expression="#lcase(url.ReportUOM)#">
									<cfcase value="1"><!--- cs --->
										<cfset uom_PTV 							= TheQuery2.PTV_CS>
										<cfset uom_PTV 							= trim(NumberFormat(uom_PTV, '______.____'))>
										<cfset uom_TotalProductProgramVolume 	= TheQuery2.TotalProductProgramVolume_CS>
										<cfset uom_LastBBClaim	 				= TheQuery2.LastBBClaim_CS>
										<cfset uom_str 							= "&nbsp;cs">
									</cfcase>
									
									<cfcase value="2"><!--- lb --->
										<cfset uom_PTV 							= TheQuery2.PTV_LB>
										<cfset uom_PTV 							= trim(NumberFormat(uom_PTV, '______.____'))>
										<cfset uom_TotalProductProgramVolume 	= TheQuery2.TotalProductProgramVolume_LB>
										<cfset uom_LastBBClaim	 				= TheQuery2.LastBBClaim_LB>
										<cfset uom_str 							= "&nbsp;lbs">	
										<cfset uom_cs							= "&nbsp;cs">
										<cfset uom_cases						= TheQuery2.LastBBClaim_CS> <!--- Dev Note: KAL; 8161 --->
									</cfcase>
									
									<cfcase value="rm"><!--- rm --->
										<cfset uom_PTV 							= TheQuery2.PTV_RM>
										<cfset uom_PTV 							= trim(NumberFormat(uom_PTV, '______.____'))>
										<cfset uom_TotalProductProgramVolume 	= TheQuery2.LastBBClaim_LB/ RM_Conversion_Value>
										<cfset uom_LastBBClaim	 				= TheQuery2.LastBBClaim_LB / RM_Conversion_Value>
										<cfset uom_str 							= "&nbsp;lbs">
										<cfset uom_cs							= "&nbsp;cs">
										<cfset uom_cases						= TheQuery2.LastBBClaim_CS> <!--- Dev Note: KAL; 8161 --->
									</cfcase>
								</cfswitch>
								
										<cfset uom_TotalClaimAmount				= uom_TotalClaimAmount + uom_LastBBClaim>
										<cfset uom_EndingBalance				= uom_BegBal-uom_LastBBClaim>
										<cfset uom_ValueAvailable				= uom_PTV*uom_EndingBalance>
										<cfset uom_BegBal						= uom_EndingBalance> <!--- Development Note: KAL - Added this line --->
										<cfset uom_ValueUsed					= uom_PTV*uom_LastBBClaim>
											</cfsilent>
							<cfif url.ReportBBDetail EQ 1>
								<cfset thisCurrentrow = thisCurrentrow + 1>
								<tr bgcolor="<CFIF thisCurrentrow mod 2>##CCFFCC<CFELSE>WhiteSmoke</CFIF>">
									<td  nowrap>#DateFormat(TheQuery2.BB_Date, 'mm-dd-yyyy')#</td>
									<td colspan="2" align="right">&nbsp;&nbsp;&nbsp;&nbsp;#TheQuery2.BB_Title# - #TheQuery2.BB_Reference#</td>
									<td align="right">#trim(numberformat(uom_PTV, '___,___,___.____'))#</td>
									<td align="right">#trim(NumberFormat(uom_LastBBClaim, '-___,___,___,___,___'))##uom_str#</td>
									<td align="right">#trim(NumberFormat(uom_cases, '-___,___,___,___,___'))##uom_cs#</td>									
									<td align="right">#trim(NumberFormat(uom_ValueUsed, '-$___,___,___,___,___.__'))#</td>
									<td align="right">#trim(NumberFormat(uom_TotalClaimAmount, '-___,___,___,___,___'))##uom_str#</td> 
									<td align="right">#trim(NumberFormat(uom_EndingBalance, '-___,___,___,___,___'))##uom_str#</td>
									<td align="right">#trim(NumberFormat(uom_ValueAvailable, '-$___,___,___,___,___.__'))#</td> 							
								</tr>
							</cfif>	

							<!--- add to item total ---><!--- Development Note: KAL - changed the function --->
							<cfset temp = EndTotal(OpMonthItemTotalStructName, "BEGBAL", uom_BegBal)>  
							<cfset temp = addToTotal(OpMonthItemTotalStructName, "BBCURRENT", uom_LastBBClaim)>
							<cfset temp = addToTotal(OpMonthItemTotalStructName, "BBCUME", uom_LastBBClaim)>
							<cfset temp = EndTotal(OpMonthItemTotalStructName, "ENDBAL", uom_EndingBalance)>
							<cfset temp = EndTotal(OpMonthItemTotalStructName, "VALUEAVAIL", uom_ValueAvailable)>
							<cfset temp = addToTotal(OpMonthItemTotalStructName, "VALUEUSED", uom_ValueUsed)>
							<cfset temp = addToTotal(OpMonthItemTotalStructName, "CASES", uom_Cases)> <!--- Dev Note: KAL; 8161 --->

						</cfoutput><!--- end bb --->
						
						<cfset thisStrLen1 = len(TheQuery2.Operator_Name)>
						<cfset thisStrLen2 = len(TheQuery2.Item)>
						<cfset maxStrLen = 40>
						
						<!--- Item Total --->
						<cfif url.ReportBBDetail EQ 0>
								<cfset tempuom_str = uom_str>
								<cfset uom_str = "">
								<td align="right">#trim(numberformat(uom_PTV, '___,___,___.____'))#</td>
								<td align="right">#trim(NumberFormat(OpMonthItemTotalStructName.BBCurrent, '-___,___,___,___,___'))##uom_str#</td>
								<td align="right">#trim(NumberFormat(OpMonthItemTotalStructName.Cases, '-___,___,___,___,___'))#</td> <!--- Dev Note: KAL; 8161 --->
								<td align="right">#trim(NumberFormat(OpMonthItemTotalStructName.ValueUsed, '-$___,___,___,___,___.__'))#</td>
								<td align="right">#trim(NumberFormat(OpMonthItemTotalStructName.BBCume, '-___,___,___,___,___'))##uom_str#</td>
								<td align="right">#trim(NumberFormat(OpMonthItemTotalStructName.EndBal, '-___,___,___,___,___'))##uom_str#</td>
								<td align="right">#trim(NumberFormat(OpMonthItemTotalStructName.ValueAvail, '-$___,___,___,___,___.__'))#</td>
							</tr>
							<cfset uom_str = tempuom_str>
						<cfelse>
							<tr bgcolor="##4169e1">	
								<cfset thisStrLen = len(TheQuery2.Operator_Name)>
								<cfset maxStrLen = 40>
								<td colspan="4" align="right" title="#TheQuery2.Operator_Name# #TheQuery2.BB_Date_Month_String# Results" style="color: white;" nowrap>
									<b>#TheQuery2.BB_Date_Month_String# #MID(TheQuery2.Item, 1, maxStrLen)#<cfif thisStrLen GT maxStrLen>...</cfif> Total:</b>
								</td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(OpMonthItemTotalStructName.BBCurrent, '-___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(OpMonthItemTotalStructName.Cases, '-___,___,___,___,___'))##uom_cs#</b></td> <!--- Dev Note: KAL; 8161 --->
								<td align="right" style="color: white;"><b>#trim(NumberFormat(OpMonthItemTotalStructName.ValueUsed, '-$___,___,___,___,___.__'))#</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(OpMonthItemTotalStructName.BBCume, '-___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(OpMonthItemTotalStructName.EndBal, '-___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(OpMonthItemTotalStructName.ValueAvail, '-$___,___,___,___,___.__'))#</b></td>
							</tr>
							<tr>
								<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
							</tr>
						</cfif>
							<!--- Development Note: KAL - changed the function --->
							<cfset temp = EndTotal(OPMonthTotalStructName, "BEGBAL", OpMonthItemTotalStructName.BEGBAL)>
							<cfset temp = addToTotal(OPMonthTotalStructName, "BBCURRENT", OpMonthItemTotalStructName.BBCURRENT)>
							<cfset temp = addToTotal(OPMonthTotalStructName, "BBCUME", OpMonthItemTotalStructName.BBCURRENT)>
							<cfset temp = EndTotal(OPMonthTotalStructName, "ENDBAL", OpMonthItemTotalStructName.ENDBAL)>
							<cfset temp = EndTotal(OPMonthTotalStructName, "VALUEAVAIL", OpMonthItemTotalStructName.VALUEAVAIL)>
							<cfset temp = addToTotal(OpMonthTotalStructName, "VALUEUSED", OpMonthItemTotalStructName.VALUEUSED)>
							<cfset temp = addToTotal(OpMonthTotalStructName, "CASES", OpMonthItemTotalStructName.CASES)> <!--- Dev Note: KAL; 8161 --->
						</cfoutput><!--- end item --->
						
				<!---Operator Month summary--->
					<cfif url.ReportBBDetail EQ 1>
						<tr bgcolor="##6a5acd">	
							<cfset thisStrLen = len(TheQuery2.Operator_Name)>
							<cfset maxStrLen = 40>
							<td colspan="4" align="right" title="#TheQuery2.Operator_Name#" style="color: white;" nowrap><b>#TheQuery2.BB_Date_Month_String# - #MID(TheQuery2.Operator_Name, 1, maxStrLen)#<cfif thisStrLen GT maxStrLen>...</cfif> Total:</b></td>
							
							<td align="right" style="color: white;"><b>#trim(NumberFormat(OPMonthTotalStructName.BBCurrent, '-___,___,___,___,___'))##uom_str#</b></td>
							<td align="right" style="color: white;"><b>#trim(NumberFormat(OPMonthTotalStructName.Cases, '-___,___,___,___,___'))##uom_cs#</b></td>  <!--- Dev Note: KAL; 8161 --->
							<td align="right" style="color: white;"><b>#trim(NumberFormat(OPMonthTotalStructName.ValueUsed, '-$___,___,___,___,___.__'))#</b></td>
							<td align="right" style="color: white;"><b>#trim(NumberFormat(OPMonthTotalStructName.BBCume, '-___,___,___,___,___'))##uom_str#</b></td>
							<td align="right" style="color: white;"><b>#trim(NumberFormat(OPMonthTotalStructName.EndBal, '-___,___,___,___,___'))##uom_str#</b></td>
							<td align="right" style="color: white;"><b>#trim(NumberFormat(OpMonthTotalStructName.ValueAvail, '-$___,___,___,___,___.__'))#</b></td>
						</tr>
						<tr>
							<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
						</tr>						
					</cfif>
					<cfsilent>
					<cfset temp = EndTotal(OPTotalStructName, "BEGBAL", OPMonthTotalStructName.BEGBAL)>
					<cfset temp = addToTotal(OPTotalStructName, "BBCURRENT", OPMonthTotalStructName.BBCURRENT)>
					<cfset temp = addToTotal(OPTotalStructName, "BBCUME", OPMonthTotalStructName.BBCUME)>
					<cfset temp = EndTotal(OPTotalStructName, "ENDBAL", OPMonthTotalStructName.ENDBAL)>
					<cfset temp = EndTotal(OPTotalStructName, "VALUEAVAIL", OPMonthTotalStructName.VALUEAVAIL)>
					<cfset temp = addToTotal(OPTotalStructName, "VALUEUSED", OPMonthTotalStructName.VALUEUSED)>
					<cfset temp = addToTotal(OPTotalStructName, "CASES", OPMonthTotalStructName.CASES)> <!--- Dev Note: KAL; 8161 --->
					</cfsilent>
					</cfoutput><!--- end month --->					
					</cfoutput><!--- end year --->
					
					<cfset Get99NOIValue.Recordcount = 1>
					<cfset EndingBalance = 	TotalProgramAllocation - OPTotalStructName.BBCUME>
					<cfset ValueAvailable =  EndingBalance * uom_PTV>
												
					<tr bgcolor="lightsteelblue" border="1">
						<td align="center" colspan="3"><b>&nbsp;  Total Allocation</b></td>
						<td align="right"><b>&nbsp;  #trim(NumberFormat(TotalProgramAllocation, '-___,___,___,___,___'))##uom_str#</b></td>
						<td align="right"><b>&nbsp;  #trim(NumberFormat(OPTotalStructName.BBCurrent, '-___,___,___,___,___'))##uom_str#</b></td>
						<td align="right"><b>&nbsp;  #trim(NumberFormat(OPTotalStructName.CASES, '-___,___,___,___,___'))##uom_cs#</b></td> <!--- Dev Note: KAL; 8161 --->
						<td align="right"><b>&nbsp;  #trim(NumberFormat(OPTotalStructName.VALUEUSED, '-$___,___,___,___,___.__'))#</b></td>
						<td align="right"><b>&nbsp;  #trim(NumberFormat(OPTotalStructName.BBCUME, '___,___,___,___,___'))##uom_str#</b></td>
						<td align="right"><b>&nbsp;  #trim(NumberFormat(EndingBalance, '___,___,___,___,___'))##uom_str#</b></td>
						<td align="right"><b>&nbsp;  #trim(NumberFormat(ValueAvailable, '-$___,___,___,___,___.__'))#</b></td> 							
					</tr>
					<tr>
						<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
					</tr>
				<!--- </cfif> --->
				
				<!----Operator summary--->	
				<!--- <cfif url.ReportBBDetail EQ 1> --->
				<cfset thisStrLen1 = len(TheQuery2.Operator_Name)>
				<cfset thisStrLen2 = len(TheQuery2.Item)>
				<cfset maxStrLen = 40>
				<tr bgcolor="##000080">
						<td colspan="3" align="center" style="border-top: 1 solid Black; color: white;"><b>Operator</b></td>
						<td colspan="2" align="right" style="border-top: 1 solid Black; color: white;"><b>Total Allocation ($ Value)</b></td>
						<td colspan="3" align="right" style="border-top: 1 solid Black; color: white;"><b>Used ($ Value)&nbsp;&nbsp;Cases</b></td>
						<td colspan="2" align="right" style="border-top: 1 solid Black; color: white;"><b>Available ($ Value)</b></td>
				</tr>
 				<tr bgcolor="##999999">
					<td colspan="3" align="center" title="#TheQuery2.Operator_Name#" style="border-top: 1 solid Black; color: white;" nowrap><b>#MID(TheQuery2.Operator_Name, 1, maxStrLen)#<cfif thisStrLen1 GT maxStrLen>...</cfif></b></td>
					<td align="right" colspan="2" style="border-top: 1 solid Black; color: white;"><b>&nbsp;  #trim(NumberFormat(TotalProgramAllocation, '___,___,___,___,___'))##uom_str#
						&nbsp;(#trim(NumberFormat(TotalProgramAllocation*uom_PTV, '-$___,___,___,___,___.__'))#) </b></td>
					<td align="right" colspan="3" style="border-top: 1 solid Black; color: white;"><b>&nbsp;  #trim(NumberFormat(OPTotalStructName.BBCume, '___,___,___,___,___'))##uom_str#
						&nbsp;(#trim(NumberFormat(OPTotalStructName.VALUEUSED, '-$___,___,___,___,___.__'))#) &nbsp;
						&nbsp; #trim(NumberFormat(OPTotalStructName.CASES, '___,___,___,___,___'))##uom_cs#	</b></td>
					<td align="right" colspan="2" style="border-top: 1 solid Black; color: white;"><b>
						<cfif Get99NOIValue.Recordcount GT 0>
								#trim(NumberFormat(EndingBalance, '-___,___,___,___,___'))##uom_str#
								&nbsp;(#trim(NumberFormat(ValueAvailable, '-$___,___,___,___,___.__'))#)
						<cfelse>
							#trim(NumberFormat(OPTotalStructName.EndBal, '-___,___,___,___,___'))##uom_str#
							&nbsp;(#trim(NumberFormat(OPTotalStructName.VALUEAVAIL, '-$___,___,___,___,___.__'))#)
						</cfif> 
					</b></td>
				</tr>
								
				<tr>
					<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
				</tr>
					<!--- Dev Note: KAL - D7658--->
					<cfset temp = EndTotal(TotalStructName, "BEGBAL", OPTotalStructName.BEGBAL)>
					<cfset temp = addToTotal(TotalStructName, "BBCURRENT", OPTotalStructName.BBCURRENT)>
					<cfset temp = addToTotal(TotalStructName, "BBCUME", OPTotalStructName.BBCUME)>
					<cfset temp = addToTotal(TotalStructName, "ENDBAL", OPTotalStructName.ENDBAL)>
					<cfset temp = EndTotal(TotalStructName, "VALUEAVAIL", OPTotalStructName.VALUEAVAIL)>		
					<cfset temp = addToTotal(TotalStructName, "VALUEUSED", OPTotalStructName.VALUEUSED)>
					<cfset temp = addToTotal(TotalStructName, "CASES", OPTotalStructName.CASES)> <!--- Dev Note: KAL; 8161 --->
				</cfoutput> <!--- end Operator --->


				<cfset EndingBalance = 	TotalAllowanceForAll - TotalStructName.BBCUME>
				<cfset ValueAvailable =  EndingBalance * uom_PTV>
					
				<cfoutput>
				<tr>	
					<td colspan="3" align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>Report Total:</b></td>
					
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>
						<cfif Get99NOIValue.Recordcount GT 0>
							#trim(NumberFormat(TotalAllowanceForAll, '-___,___,___,___,___'))#
						<cfelse>
							#trim(NumberFormat(TotalStructName.BegBal, '___,___,___,___,___'))#
						</cfif>	#uom_str#</b>
					</td>
					
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalStructName.BBCurrent, '-___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalStructName.Cases, '-___,___,___,___,___'))##uom_cs#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalStructName.ValueUsed, '-$___,___,___,___,___.__'))#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalStructName.BBCume, '-___,___,___,___,___'))##uom_str#</b></td>
					
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>
						<cfif Get99NOIValue.Recordcount GT 0>
							#trim(NumberFormat(EndingBalance, '-___,___,___,___,___'))#
						<cfelse>
							#trim(NumberFormat(TotalStructName.EndBal, '-___,___,___,___,___'))#
						</cfif> #uom_str#</b>
					</td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>
						<cfif Get99NOIValue.Recordcount GT 0>
							#trim(NumberFormat(ValueAvailable, '-$___,___,___,___,___.__'))#
						<cfelse>
							#trim(NumberFormat(TotalStructName.ValueAvail, '-$___,___,___,___,___.__'))#
						</cfif></b>
					</td>
				</tr>
				<tr>
					<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
				</tr>
				</cfoutput>