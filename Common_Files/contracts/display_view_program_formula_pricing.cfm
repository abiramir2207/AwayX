	<CFIF GetSettings.Discount_Formula_Pricing EQ 1>
	<cfset getRules  = ViewProgramManager.getRules(CSLGetContractInfo.Contract_Main_ID, displayGroupType)>
	<cfif getRules.recordcount GT 0>
		<CFSET getInfoForProgramID 	= CSLGetContractInfo.Contract_Main_ID>
		<CFSET getInfoForPeriod 	= "any">
		<CFINCLUDE TEMPLATE="program_pricing_period_information.cfm"> 
	<cfoutput><TR>
		<TD COLSPAN="100%">
			<BR>
			<B><FONT SIZE="2" COLOR="Navy">Formula Pricing</FONT></B>&nbsp;&nbsp;&nbsp;&nbsp;
				<CFIF periods.Requested_Period_Info.ValidData EQ 1>
					<SPAN STYLE="font-weight:bold; font-size: 12px;">Prices For Period:</SPAN>
					<SPAN STYLE="font-weight:bold; font-size: 12px; color: red;">#DateFormat(periods.Requested_Period_Info.Start_Date,'m/d/yyyy')# - #DateFormat(periods.Requested_Period_Info.End_Date,'m/d/yyyy')#</SPAN>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<SPAN STYLE="font-weight:bold; font-size: 12px;">Release Date:</SPAN>
					<SPAN STYLE="font-weight:bold; font-size: 12px; color: red;">#DateFormat(periods.Requested_Period_Info.Release_Date,'m/d/yyyy')#</SPAN>
					<CFSET PPID=periods.Requested_Period_Info.Program_Formula_Pricing_Period_ID>
				<CFELSE>
					<SPAN STYLE="font-weight:bold; font-size: 12px; color: red;">NO DATE SUPPLIED</SPAN>
					<CFSET PPID="">
				</CFIF>						
					
			<HR COLOR="Navy">
			
			<span><font SIZE="1" COLOR="red">*The Prices Below Are <CFIF CSLGetContractInfo.Formula_Price_Rebate_Type EQ 1>Net Delivered<CFELSE>FOB</CFIF><cfif trim(CSLGetContractInfo.Generic_Type) EQ "Operator-Deviated Pricing"> for the #application.returned_customer_setting.distributor_label_singular# and do not include their mark-up</cfif></font></span>
			<cfif appSettings.getPaymentCycleAtDiscountType()>
			<B><br>Payment Cycle</B>:
			<cf_payment_cycle_selection
				Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
				Program_ID = "#CSLGetContractInfo.Contract_Main_ID#"
				discount_Type_ID = "5"
				Selected_Payment_Cycle_ID = ""
				Action = "display"
				>
			</cfif>
		</TD>
	</TR>
	</CFOUTPUT>


		<TD COLSPAN="100%">	
			<TABLE CELLSPACING="0" CELLPADDING="3" WIDTH="100%" BORDER="0">
			<cfif summaryView><cfset productCount = 0 ><TR BGCOLOR="F2F2F2"></cfif> 			
			<CFIF getRules.recordcount GT 0>				
				<CFOUTPUT QUERY="getRules" GROUP="Program_Formula_Pricing_Rule_Mapped_ID">
					<TR <!--- BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" --->>
						<TD VALIGN="top" COLSPAN="100%" STYLE="font-size: 15px;">						
						<CFIF Formula_Pricing_Rule_ID EQ "">
						<FONT COLOR="red"><B>Rule is Inactive</B></FONT>
						<CFELSE>
						<B><U>#Rule_Name#</U></B>
						</CFIF>
						</TD>
					</TR>
					<TR>
						<TD WIDTH="50" COLSPAN="100%">&nbsp;</TD>
					</TR>
					<TR BGCOLOR="##FFCE84" VALIGN="bottom">
						<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
						<TD ID="header" WIDTH="75" STYLE="border-bottom:solid ##93BEE2 1px;"><B>#application.returned_customer_setting.upc_label#</B></TD></cfif></cfif>
						<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
						<TD ID="header" STYLE="border-bottom:solid ##93BEE2 1px;"><B>#application.returned_customer_setting.item_label#</B></TD>
						</cfif>
						<TD ID="header" WIDTH="300" STYLE="border-bottom:solid ##93BEE2 1px;"><B>DESCRIPTION</B></TD>
						<cfif summaryView>
							<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
							<TD ID="header" WIDTH="75" STYLE="border-bottom:solid ##93BEE2 1px;"><B>#application.returned_customer_setting.upc_label#</B></TD></cfif></cfif>
							<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
							<TD ID="header" STYLE="border-bottom:solid ##93BEE2 1px;"><B>#application.returned_customer_setting.item_label#</B></TD>
							</cfif>
							<TD ID="header" WIDTH="300" STYLE="border-bottom:solid ##93BEE2 1px;"><B>DESCRIPTION</B></TD>					
						</cfif>
						<cfif not summaryView>
							<cfif displayGroupType>
							<TD ID="header" WIDTH="110" STYLE="border-bottom:solid ##93BEE2 1px;"><B>#displayGroupTypeDesc#</B></TD>
							</cfif>
							<TD ID="header" WIDTH="140" STYLE="border-bottom:solid ##93BEE2 1px;" ALIGN="RIGHT"><B>PRICE</B></TD>
						</cfif>
					</TR>
					<cfif summaryView><CFSET ProductCount = 0><TR BGCOLOR="F2F2F2"></cfif> 
					<CFOUTPUT>
						<CFSET CurrentRowColor = IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))>
						<Cfset ThisProductsID = BSA_Foodservice_Items_Master_ID>
						<cfif not summaryView>
							<TR BGCOLOR="#CurrentRowColor#" VALIGN="top" ONMOUSEOVER="menuID=6;URLstring='';an_ID='#ThisProductsID#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;">
								<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
								<TD STYLE="border-bottom:solid ##93BEE2 1px; font-size : 10px;">#UPC#</TD></cfif></cfif>
								<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
									<TD STYLE="border-bottom:solid ##93BEE2 1px; font-size : 10px;">#ITEM#</TD>
								</cfif>
								<TD STYLE="border-bottom:solid ##93BEE2 1px; font-size : 10px;">#DESCRIPTION#</TD>
								<cfif displayGroupType>
								<TD STYLE="border-bottom:solid ##93BEE2 1px; font-size : 10px;">#DisplayGroupName#</TD>
								</cfif>
								<TD STYLE="border-bottom:solid ##93BEE2 1px; font-size : 10px;" ALIGN="RIGHT" NOWRAP><CFIF PPID NEQ ""><A STYLE="cursor:pointer;" ONCLICK="javaScript: showRateCalculation(#CSLGetContractInfo.Contract_Main_ID#,'#ThisProductsID#','#PPID#');"></CFIF><cfif not summaryView>#trim(NumberFormat(Price, ViewProgramManager.getRateFormatMask()))# per Lb<cfelse>&nbsp;</cfif><CFIF PPID NEQ ""></A></TD></TR></CFIF>
							
						<cfelse>
							<cfif productCount Mod 2 EQ 0>
								</tr>
								<TR BGCOLOR="F2F2F2" VALIGN="top" ONMOUSEOVER="menuID=6;URLstring='';an_ID='#ThisProductsID#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;">
							</cfif>
							<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
								<TD STYLE="border-bottom:solid ##93BEE2 1px; font-size : 10px;">#UPC#</TD></cfif></cfif>
								<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
								<TD STYLE="border-bottom:solid ##93BEE2 1px; font-size : 10px;">#ITEM#</TD>
								</cfif>
								<TD STYLE="border-bottom:solid ##93BEE2 1px; font-size : 10px;">#DESCRIPTION#</TD>
							<cfset productCount = productCount + 1 >
						</cfif>
					</CFOUTPUT>
					
				<TR>
					<TD COLSPAN="100%" HEIGHT="20">
						
					</TD>
				</TR>
				</CFOUTPUT>
			</tr>
			</CFIF>
			</TABLE>
		</TD>
	</TR>
	</CFIF>
</cfif>