<!------ contract_lumpsum_balance_info.cfm ----->
<cfparam name="displayLumpsumBalanceHeader" 	default="1">
<cfoutput>
<cfif isNumeric(latestTemplateLumpSumCap) AND latestTemplateLumpSumCap NEQ 0 and latestTemplateLumpSumCap NEQ "">	
<cfif displayLumpsumBalanceHeader>
<BR>
<DIV STYLE="font-size: 15px; font-weight:bold; color: Navy;">#Application.LumpsumLabel# Balance Information</DIV>
<HR COLOR="orange">
</cfif>
<TABLE BORDER="0">
	<TR>
		<TD STYLE="font-size: 12px; color: NAVY;" ALIGN="right"><B>#Application.LumpsumLabel# Cap:</B></TD>
		<TD STYLE="font-size: 12px;" ALIGN="right">#DollarFormat(latestTemplateLumpSumCap)#</TD>
	</TR>
	<TR>
		<TD STYLE="font-size: 12px; color: NAVY;" ALIGN="right"><B>#Application.LumpsumLabel# spent in other programs:</B></TD>
		<TD STYLE="font-size: 12px;" ALIGN="right">#DollarFormat(currentLumpSumCapAllocation)#</TD>
	</TR>
	<TR>
		<TD STYLE="font-size: 12px; color: NAVY;" ALIGN="right"><B>#Application.LumpsumLabel# balance available:</B></TD>
		<TD STYLE="font-size: 12px;" ALIGN="right">#DollarFormat(lumpSumAvailableBalance)#</TD>
	</TR>
	<TR>
		<TD STYLE="font-size: 12px; color: NAVY;" ALIGN="right"><B>#Application.LumpsumLabel# in this program:</B></TD>
		<TD STYLE="font-size: 12px;" ALIGN="right">#DollarFormat(programLumpSum)#</TD>
	</TR>
</TABLE>
<BR>
</cfif>
</cfoutput>