<cfsilent>
<cfquery name="TheQuery2" dbtype="query">
	SELECT DISTINCT * FROM TheQuery ORDER BY  Operator_Name,  bsa_operator_id,BB_Date_Month_Number,BB_Date, Item, BB_Title
</cfquery>


			<CFSET QueryTotalStructName = "QueryTotalStructName_1">
			<cfset #QueryTotalStructName# = initTotalStructPrototype("QueryTotalStructName_1")>
			
			<cfset uom_cs = "&nbsp;cs"><!--- Dev Note: KAL; 8161 --->
			<cfset thisCurrentrow = 0>
			<cfset TotalAllowanceForAll = 0>
</cfsilent>
			<!--- operator output --->		
			<cfoutput query="TheQuery2" group="BSA_Operator_ID">
			<cfsilent>
			<!--- Begin: Getting total program --->
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
			<!--- End: Getting total program --->
			
			<cfset OPTotalStructName = "OPTotalStructName_#TheQuery2.BSA_Operator_ID#">
			<cfset #OPTotalStructName# = initTotalStructPrototype("BBTotalStruct_#TheQuery2.BSA_Operator_ID#")>

			<cfset uom_EndingBalance = 	TotalProgramAllocation - OPTotalStructName.BBCUME>
			<cfset uom_ValueAvailable =  uom_EndingBalance * uom_PTV>
				
				<cfif url.ReportBBDetail EQ 0>
					<cfset thisCurrentrow = thisCurrentrow + 1>
				</cfif>
		</cfsilent>
				<tr bgcolor="<cfif url.ReportBBDetail EQ 0><CFIF thisCurrentrow mod 2>##CCFFCC<CFELSE>WhiteSmoke</CFIF><cfelse>##ffffcc</cfif>"><b style="font-size: 11px;">
					<td colspan="<cfif url.ReportBBDetail EQ 1>100%<cfelse>1</cfif>" nowrap><cfif url.ReportBBDetail EQ 1><b><font size="2">#TheQuery2.Operator_Name#-#TheQuery2.Legacy_ID#</font></b><cfelse>#TheQuery2.Operator_Name#-#TheQuery2.Legacy_ID#</cfif></td></b> 
				<cfif url.ReportBBDetail EQ 1></tr></cfif>
				
				<!--- Billback --->
				<cfset uom_TotalClaimAmount = 0>
				<cfoutput group="Billback_ID">
				
					<cfset tempBBID = replace(TheQuery2.Billback_ID, "-", "_", "ALL")>
					<CFSET thisTotalStructName = "BBTotalStruct_#tempBBID#">
					<cfset #thisTotalStructName# = initTotalStructPrototype("BBTotalStruct_#tempBBID#")>
				
				<cfif url.ReportBBDetail EQ 1>
				<tr>
					<td colspan="100%" bgcolor="##f0fff0">&nbsp;&nbsp;#TheQuery2.BB_Title# - #TheQuery2.BB_Reference#</td>
				</tr>
				</cfif>
	
				<!--- Item Output--->
				<cfoutput group="Item">
			<cfsilent>
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
							<cfset uom_str							= "&nbsp;lbs">
							<cfset uom_cs							= "&nbsp;cs">
							<cfset uom_cases						= TheQuery2.LastBBClaim_CS> <!--- Dev Note: KAL; 8161 --->
						</cfcase>
					</cfswitch>
					
					<!--- 	<tr bgcolor="pink"><td colspan="100%">#uom_LastBBClaim# = #TheQuery2.LastBBClaim_LB# / #RM_Conversion_Value#</td></tr> --->
					
						<cfset uom_TotalClaimAmount 			= uom_TotalClaimAmount + uom_LastBBClaim>
						<cfset uom_EndingBalance				= uom_BegBal-uom_LastBBClaim>
						<!--- <cfset uom_EndingBalance			= uom_BegBal-uom_TotalClaimAmount> --->
						<cfset uom_BegBal						= uom_EndingBalance> <!--- Development Note: KAL - Added this line --->
						<cfset uom_ValueUsed					= uom_PTV*uom_LastBBClaim>
						<cfset uom_ValueAvailable				= uom_PTV*uom_EndingBalance>
	
					
					<cfset temp = EndTotal(thisTotalStructName, "BEGBAL", uom_BegBal)>
					<!--- <tr bgcolor="green"><td colspan="100%">#thisTotalStructName.BBCURRENT#</td></tr> --->
					<cfset temp = addToTotal(thisTotalStructName, "BBCURRENT", uom_LastBBClaim)>
					<cfset temp = addToTotal(thisTotalStructName, "VALUEUSED", uom_ValueUsed)>
					<cfset temp = addToTotal(thisTotalStructName, "BBCUME", uom_TotalClaimAmount)>
					<cfset temp = EndTotal(thisTotalStructName, "ENDBAL", uom_EndingBalance)>
					<cfset temp = EndTotal(thisTotalStructName, "VALUEAVAIL", uom_ValueAvailable)>
					<cfset temp = addToTotal(thisTotalStructName, "CASES", uom_cases)>
					</cfsilent>
					<cfif url.ReportBBDetail EQ 1>
						<cfset thisCurrentrow = thisCurrentrow + 1>
						<tr bgcolor="<CFIF thisCurrentrow mod 2>##CCFFCC<CFELSE>WhiteSmoke</CFIF>">
							<td align="right" colspan="2">#DateFormat(TheQuery2.BB_Date, 'mm-dd-yyyy')#</td>
							<td align="right">&nbsp;&nbsp;&nbsp;&nbsp;#TheQuery2.Item#</td>
							<td align="right">#trim(numberformat(uom_PTV, '___,___,___.____'))#</td>
							<td align="right">#trim(NumberFormat(uom_LastBBClaim, '-___,___,___,___,___'))##uom_str#</td>
							<td align="right">#trim(NumberFormat(uom_cases, '-___,___,___,___,___'))##uom_cs#</td>
							<td align="right">#trim(NumberFormat(uom_ValueUsed, '-$___,___,___,___,___.__'))#</td>		
							<td align="right">#trim(NumberFormat(uom_TotalClaimAmount, '-___,___,___,___,___'))##uom_str#</td> 
							<td align="right">#trim(NumberFormat(uom_EndingBalance, '-___,___,___,___,___'))##uom_str#</td>
							<td align="right">#trim(NumberFormat(uom_ValueAvailable, '-$___,___,___,___,___.__'))#</td> 																					
						</tr>
					</cfif>
				</cfoutput><!---  end item --->
			<cfsilent>
					<cfset temp = EndTotal(OPTotalStructName, "BEGBAL", thisTotalStructName.BEGBAL)>
					<cfset temp = addToTotal(OPTotalStructName, "BBCURRENT", thisTotalStructName.BBCURRENT)>
					<cfset temp = addToTotal(OPTotalStructName, "BBCUME", thisTotalStructName.BBCURRENT)>
					<cfset temp = EndTotal(OPTotalStructName, "ENDBAL", thisTotalStructName.ENDBAL)>
					<cfset temp = EndTotal(OPTotalStructName, "VALUEAVAIL", thisTotalStructName.VALUEAVAIL)>
					<cfset temp = addToTotal(OPTotalStructName, "VALUEUSED", thisTotalStructName.VALUEUSED)>
					<cfset temp = addToTotal(OPTotalStructName, "CASES", thisTotalStructName.CASES)>
			</cfsilent>
				</cfoutput><!--- end billback --->						
					<cfset Get99NOIValue.Recordcount = 1>
					<cfset EndingBalance = 	TotalProgramAllocation - OPTotalStructName.BBCUME>
					<cfset ValueAvailable =  EndingBalance * uom_PTV>

					<cfif url.ReportBBDetail EQ 0>
							<cfset tempuom_str = uom_str>
							<cfset uom_str = "">
							<!--- <td align="right" colspan="2">&nbsp;  </td> ---> <!--- Dev Note: KAL; 8453 --->
							<td align="right">&nbsp;  #trim(NumberFormat(TotalProgramAllocation, '-___,___,___,___,___'))##uom_str#</td>
							<td align="right">&nbsp;  #trim(NumberFormat(OPTotalStructName.BBCurrent, '-___,___,___,___,___'))##uom_str#</td>
							<td align="right">&nbsp;  #trim(NumberFormat(OPTotalStructName.Cases, '-___,___,___,___,___'))##uom_cs#</td>
							<td align="right">&nbsp;  #trim(NumberFormat(OPTotalStructName.VALUEUSED, '-$___,___,___,___,___.__'))#</td>
							<td align="right">&nbsp;  #trim(NumberFormat(OPTotalStructName.BBCUME, '___,___,___,___,___'))##uom_str#</td>
							<td align="right">&nbsp;  #trim(NumberFormat(EndingBalance, '___,___,___,___,___'))##uom_str#</td>
							<td align="right">&nbsp;  #trim(NumberFormat(ValueAvailable, '-$___,___,___,___,___.__'))#</td> 							
							<cfset uom_str = tempuom_str>
						</tr> 
					<cfelse>
						<tr bgcolor="##6a5acd">	
							<cfset thisStrLen = len(TheQuery2.Operator_Name)>
							<cfset maxStrLen = 40>
							<td colspan="3" align="right" title="#TheQuery2.Operator_Name#" nowrap style="color: white;">
								<b>#MID(TheQuery2.Operator_Name, 1, maxStrLen)#<cfif thisStrLen GT maxStrLen>...</cfif> Total:</b>
							</td>
							<td align="right" style="color: white;"><b>
								<cfif Get99NOIValue.Recordcount GT 0>#trim(NumberFormat(TotalProgramAllocation, '-___,___,___,___,___'))#
								<cfelse>#trim(NumberFormat(OPTotalStructName.BegBal, '-___,___,___,___,___'))#
								</cfif>#uom_str#</b>
							</td>
							<td align="right" style="color: white;"><b>#trim(NumberFormat(OPTotalStructName.BBCurrent, '-___,___,___,___,___'))##uom_str#</b></td>
							<td align="right" style="color: white;"><b>#trim(NumberFormat(OPTotalStructName.Cases, '-___,___,___,___,___'))##uom_cs#</b></td>
							<td align="right" style="color: white;"><b>#trim(NumberFormat(OPTotalStructName.VALUEUSED, '-$___,___,___,___,___.__'))#</b></td>
							<td align="right" style="color: white;"><b>#trim(NumberFormat(OPTotalStructName.BBCUME, '___,___,___,___,___'))##uom_str#</b></td>
							<td align="right" style="color: white;"><b>
								<cfif Get99NOIValue.Recordcount GT 0>
									#trim(NumberFormat(EndingBalance, '___,___,___,___,___'))#
								<cfelse>
									#trim(NumberFormat(OPTotalStructName.EndBal, '___,___,___,___,___'))#
									</cfif> #uom_str#</b>
							</td>
							<td align="right" style="color: white;"><b>
								<cfif Get99NOIValue.Recordcount GT 0>
									#trim(NumberFormat(ValueAvailable, '-$___,___,___,___,___.__'))#
								<cfelse>
									#trim(NumberFormat(OPTotalStructName.ValueAvail, '-$___,___,___,___,___.__'))#
								</cfif></b>
							</td>
	
						</tr>
						<tr><td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td></tr>
					</cfif>

					<!--- Dev Note: KAL - D7658--->
					<cfsilent>
					<cfset temp = addToTotal(QueryTotalStructName, "BEGBAL", OPTotalStructName.BEGBAL)>
					<cfset temp = addToTotal(QueryTotalStructName, "BBCURRENT", OPTotalStructName.BBCURRENT)>
					<cfset temp = addToTotal(QueryTotalStructName, "BBCUME", OPTotalStructName.BBCUME)>
					<cfset temp = addToTotal(QueryTotalStructName, "ENDBAL", OPTotalStructName.ENDBAL)>
					<cfset temp = addToTotal(QueryTotalStructName, "VALUEAVAIL", OPTotalStructName.VALUEAVAIL)>		
					<cfset temp = addToTotal(QueryTotalStructName, "VALUEUSED", OPTotalStructName.VALUEUSED)>		
					<cfset temp = addToTotal(QueryTotalStructName, "CASES", OPTotalStructName.CASES)>
					</cfsilent>
			</cfoutput><!--- end operator --->
	
				<cfset EndingBalance = 	TotalAllowanceForAll - QueryTotalStructName.BBCUME>
				<cfset ValueAvailable =  EndingBalance * uom_PTV>
					
			
			<!--- SHOW REPORT TOTAL --->
			<cfoutput>
			<tr><td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td></tr>
			<tr>	
				<td colspan="<cfif url.ReportBBDetail EQ 1>3<cfelse>1</cfif>" align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>Report Total:</b></td>
				
				<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>
					<cfif Get99NOIValue.Recordcount GT 0>
						#trim(NumberFormat(TotalAllowanceForAll, '-___,___,___,___,___'))#
					<cfelse>
						#trim(NumberFormat(QueryTotalStructName.BegBal, '___,___,___,___,___'))#
					</cfif> 	#uom_str#</b>
				</td>
				
				<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(QueryTotalStructName.BBCurrent, '-___,___,___,___,___'))##uom_str#</b></td>
				<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(QueryTotalStructName.Cases, '-___,___,___,___,___'))##uom_cs#</b></td>
				<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(QueryTotalStructName.ValueUsed, '-$___,___,___,___,___.__'))#</b></td>
				<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(QueryTotalStructName.BBCume, '-___,___,___,___,___'))##uom_str#</b></td>
				
				<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>
					<cfif Get99NOIValue.Recordcount GT 0>
						#trim(NumberFormat(EndingBalance, '-___,___,___,___,___'))#
					<cfelse>
						#trim(NumberFormat(QueryTotalStructName.EndBal, '-___,___,___,___,___'))#
					</cfif> #uom_str#</b>
				</td>
				<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>
					<cfif Get99NOIValue.Recordcount GT 0>
						#trim(NumberFormat(ValueAvailable, '-$___,___,___,___,___.__'))#
					<cfelse>
						#trim(NumberFormat(QueryTotalStructName.ValueAvail, '-$___,___,___,___,___.__'))#
					</cfif></b>
				</td>
			</tr>

			</cfoutput>
