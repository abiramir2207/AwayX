<!------Formula_Componded_Independent_Dispay.cfm----->
<CFOUTPUT>
<CFSET Compounded_Calc_Result = Compounded_Calc_Add_To>
<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="100%">
	<TR>
		<TD COLSPAN="2" STYLE="border:none;">&nbsp;</TD>
		<TD ALIGN="right" STYLE="border:none;">$#numberformat(Compounded_Calc_Result, '_,___.____')#</TD>				
	</TR>		
<CFLOOP QUERY="QRY_Overage_Data">				
	<TR>
		<TD STYLE="border:none;" WIDTH="50%">#Description#: </TD>
		<TD VALIGN="bottom" ALIGN="RIGHT" STYLE="border:none;">+</TD>
		<CFIF This_Overage_Data.UOM EQ "%">
			<CFIF Independent_Compounded_Calc_Type EQ 1><!---- independent --->
				<CFSET Operation_Against = Compounded_Calc_Against>
			<CFELSE><!---- componded ---->
				<CFSET Operation_Against = Compounded_Calc_Result>				
			</CFIF>			
			<CFSET thisAvearage = (Operation_Against * This_Overage_Data.Amount)/100>
			<TD COLSPAN="1" ALIGN="RIGHT" STYLE="border:none;">#numberformat(This_Overage_Data.Amount, '_,___.____')#%</TD>
			<TD ALIGN="CENTER" STYLE="border:none;">*</TD>
			<TD ALIGN="RIGHT" STYLE="border:none;">#numberformat(Operation_Against, '_,___.____')#</TD>
		<CFELSEIF  This_Overage_Data.UOM EQ "$">
			<CFSET thisAvearage = This_Overage_Data.Amount>
			<TD COLSPAN="1" ALIGN="RIGHT" STYLE="border:none;">$#numberformat(thisAvearage, '_,___.____')#</TD>
			<TD COLSPAN="2" ALIGN="RIGHT" STYLE="border:none;">&nbsp;</TD>
		</CFIF>	
		<TD ALIGN="center" STYLE="border:none;">=</TD>
		<CFSET Compounded_Calc_Result = Compounded_Calc_Result + thisAvearage>
		<TD VALIGN="bottom" ALIGN="RIGHT" STYLE="border:none;">$#numberformat(Compounded_Calc_Result, '_,___.____')#</TD>
	</TR>
	</CFLOOP>	
</TABLE>
</CFOUTPUT>
