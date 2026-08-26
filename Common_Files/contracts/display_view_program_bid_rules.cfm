	<cfset BidProducts  = ViewProgramManager.BidProducts(CSLGetContractInfo.Contract_Main_ID, displayGroupType)>
	
	
 	<CFIF BidProducts.Recordcount GT 0>
	
		<cfset GetValidProductsWithVolume  = ViewProgramManager.GetValidProductsWithVolume(CSLGetContractInfo.Contract_Main_ID)>
	
		<cfset listGetValidProductsWithVolume = valuelist(GetValidProductsWithVolume.BSA_Foodservice_Items_Master_ID)>
		

	<cfoutput><TR>
		<TD COLSPAN="100%">
			<BR>
			<B><FONT SIZE="2" COLOR="Navy">Bid Pricing</FONT></B><HR COLOR="Navy">

			<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0" BORDER="0">
				<!--- TABLE HEADERS --->
				<TR BGCOLOR="##FFCE84" VALIGN="bottom">
					<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD ID="header" WIDTH="75"><B>#application.returned_customer_setting.upc_label#</B></TD></cfif></cfif>
					<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
						<TD ID="header"><B>#application.returned_customer_setting.item_label#</B></TD>
					</cfif>
					<TD ID="header"><B>DESCRIPTION</B></TD>
					<cfif displayGroupType>
					<TD ID="Header"><B><cfoutput>#displayGroupTypeDesc#</cfoutput></B></TD>
					</cfif>
					<TD ID="header" ALIGN="RIGHT"><B>Rate/Pound</B></TD>
					<TD ID="header" ALIGN="RIGHT"><B>Rate/Case</B></TD>
				</TR>		</cfoutput>	
			<cfoutput QUERY="BidProducts">
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top" ONMOUSEOVER="menuID=6;URLstring='';an_ID='#BidProducts.BSA_Foodservice_Items_Master_ID#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;">
				<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD STYLE="border-bottom:solid ##93BEE2 1px; font-size : 10px;">#BidProducts.UPC#</td></cfif></cfif>
				<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
					<TD STYLE="border-bottom:solid ##93BEE2 1px; font-size : 10px;">#BidProducts.Item#</TD>
				</cfif>
				<TD STYLE="border-bottom:solid ##93BEE2 1px; font-size : 10px;">#BidProducts.Description#</TD>
				<cfif displayGroupType>
				<TD STYLE="border-bottom:solid ##93BEE2 1px; font-size : 10px;">#DisplayGroupName#</TD>
				</cfif>
				<CFIF listfindnocase(listGetValidProductsWithVolume, BidProducts.BSA_Foodservice_Items_Master_ID) EQ 0>
					<TD STYLE="border-bottom:solid ##93BEE2 1px; font-size : 10px; color: red; font-weight: bold;" ALIGN="CENTER" NOWRAP COLSPAN="2">You must first assign a volume to this product</TD>
				<cfelse>
					<TD STYLE="border-bottom:solid ##93BEE2 1px; font-size : 10px;" ALIGN="RIGHT" NOWRAP ><cfif not summaryView>#trim(numberformat(BidProducts.Rate_LB, ViewProgramManager.getRateFormatMask()))#<cfelse>&nbsp;</cfif></TD>
					<TD STYLE="border-bottom:solid ##93BEE2 1px; font-size : 10px;" ALIGN="RIGHT" NOWRAP ><cfif not summaryView>#trim(numberformat(BidProducts.Rate_CS, ViewProgramManager.getRateFormatMask()))#<cfelse>&nbsp;</cfif></TD>
				</CFIF>
			</TR>
			</cfoutput>
			</table>
		
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="100%" HEIGHT="20">
			
		</TD>
	</TR>	
	</CFIF>

	<!------ Start Clause Code ----->
	<cfset getProgramClause = clauseProgramManager.getProgramClause(CSLGetContractInfo.Contract_Main_ID, 2, 5)>
	<cfif getProgramClause.recordCount>
<cfoutput>	<TR>
		<TD COLSPAN="100%">
		<BR>
		<!------ Formula Pricing Clauses ----->
		<cfinclude template="/Clause_Library/clause_program_display.cfm">		
		</TD>
	</TR></cfoutput>
	</cfif>
	<!------ End  Clause Code ----->