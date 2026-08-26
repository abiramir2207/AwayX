

<CFQUERY NAME="GetARDetails3" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT 	Billback_Program.A_R,
							Billback_Program.AR_From_Fiscal_Year
										
	FROM 		Billback_Program 
	<!--- 
	INNER JOIN 	Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
	INNER JOIN 	Program_Latest_Template_ID ON Program_Latest_Template_ID.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
	INNER JOIN 	Program_Control_Panel_Options aaa ON aaa.ProgramControl_Panel_Options_ID = Program_Latest_Template_ID.Latest
	 --->
	WHERE 		Billback_ID = '#Billback_ID#' AND Billback_Program.Deleted = 0  AND
				(Billback_Program.Allocation_Method = 3 OR ISNULL(Billback_Program.LumpSum_Amt,0) <> 0)
	ORDER BY 	Billback_Program.AR_From_Fiscal_Year,Billback_Program.A_R
</CFQUERY>

<CFSET ActualAllocationMethod = FinalAllocationDisplay>
<CFSET BBsJustLumpAmt = LumpSum_Amt>
<CFSET BBJustLumpSumOnly = LumpSum_Only>
<CFOUTPUT>
<CFSAVECONTENT VARIABLE="FundContent">
<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center" CLASS="UNDERLINED" WIDTH="800" ID="ForToolTip">
	<TR BGCOLOR="FFE083">
		<TD COLSPAN="3"><B><FONT SIZE="2" COLOR="Navy">FUND ALLOCATION:</FONT></B></TD>
		<TD ALIGN="Right"><CFIF Not IsDefined("FinalAllocationDisp")><B><FONT SIZE="2" COLOR="Red">[ </FONT><CFIF IsDefined("Deduction_ID")><A HREF="Display_Fund_Allocation.cfm?Billback_ID=#Billback_ID#&Deduction_ID=#Deduction_ID#">Edit</A><CFELSE><A HREF="Display_Fund_Allocation.cfm?Billback_ID=#Billback_ID#">Edit</A></CFIF><FONT SIZE="2" COLOR="Red"> ]</FONT></B></CFIF>&nbsp;&nbsp;</TD>
	</TR>
	<CFSET ThisRecordCount = 0>
	<CFLOOP QUERY="GetARDetails3">
		<CFSET ThisRecordCount = ThisRecordCount + 1>
		<CFQUERY NAME="GetProgramForEachAR3" DATASOURCE="#Application.Datasource#">
			SELECT 		Billback_Program.Program_ID
			FROM 		Billback_Program 
			<!--- 
			INNER JOIN 	Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
			INNER JOIN 	Program_Latest_Template_ID ON Program_Latest_Template_ID.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
			INNER JOIN 	Program_Control_Panel_Options aaa ON aaa.ProgramControl_Panel_Options_ID = Program_Latest_Template_ID.Latest 
			 --->
			WHERE 		Billback_ID = '#Billback_ID#' 
			AND 		Billback_Program.A_R <cfif Len(A_R) EQ 0>IS NULL<cfelse>= <cfqueryparam value="#A_R#" cfsqltype="CF_SQL_VARCHAR"></cfif>
			AND 		Billback_Program.AR_From_Fiscal_Year <cfif Len(AR_From_Fiscal_Year) EQ 0>IS NULL<cfelse>= <cfqueryparam value="#AR_From_Fiscal_Year#" cfsqltype="CF_SQL_VARCHAR"></cfif>
			AND 		(Billback_Program.Allocation_Method = 3  OR ISNULL(Billback_Program.LumpSum_Amt,0) <> 0) 
			AND			Billback_Program.Deleted = 0
		</CFQUERY>
		<CFSET Program_List = VALUELIST(GetProgramForEachAR3.Program_ID)>
		
		<CFQUERY NAME="DistinctARFYFund" DATASOURCE="#Application.Datasource#">
			SELECT 		DISTINCT	GL_Code_Fixed_Fund_Allocation_Cal.A_R,
									GL_Code_Fixed_Fund_Allocation_Cal.Fiscal_Year,
									GL_Code_Activation.A_R_DESCRIPTION
									
			FROM 		GL_Code_Fixed_Fund_Allocation_Cal 
			
			INNER JOIN 	GL_Code_Activation ON GL_Code_Activation.A_R = GL_Code_Fixed_Fund_Allocation_Cal.A_R AND
						GL_Code_Activation.Fiscal_Year = GL_Code_Fixed_Fund_Allocation_Cal.Fiscal_year AND
						GL_Code_Activation.Current_Active_Data = 1 AND
						GL_Code_Activation.Deleted = 0
						
			WHERE 		Billback_ID = '#Billback_ID#' AND 
						Program_ID IN (#Program_List#) AND 
						Allocation_Method = 3 AND
						GL_Code_Fixed_Fund_Allocation_Cal.Deleted = 0
			ORDER BY 	GL_Code_Fixed_Fund_Allocation_Cal.Fiscal_Year,GL_Code_Fixed_Fund_Allocation_Cal.A_R
		</CFQUERY>

		
		<CFLOOP QUERY="DistinctARFYFund">				
			<CFIF BBJustLumpSumOnly EQ 1 OR ActualAllocationMethod EQ 3>
			<TR>
				<TD COLSPAN="100%" STYLE="border-bottom: none">
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
						<TR>
							<TD STYLE="border-bottom: none">
								<B>A_R:</B><BR>
								<B>Fiscal_Year:</B>&nbsp;&nbsp;
							</TD>		
							<TD STYLE="border-bottom: none">
								#A_R# - #A_R_DESCRIPTION#<BR>
								#Fiscal_Year#
							</TD>				
						</TR>				
					</TABLE>
				</TD>
			</TR>
			</CFIF>
			<CFQUERY NAME="GetProgramsFund" DATASOURCE="#Application.Datasource#">
				SELECT 	DISTINCT Program_ID
				FROM	GL_Code_Fixed_Fund_Allocation_Cal
				WHERE 	Billback_ID = '#Billback_ID#' AND 
						Program_ID IN (#Program_List#) AND 
						Allocation_Method = 3 AND
						A_R = '#A_R#' AND
						Fiscal_Year = '#Fiscal_Year#' AND
						Deleted = 0
			</CFQUERY>
			
			<CFSET SameARProgs = VALUELIST(GetProgramsFund.Program_ID)>
			<CFSET AppendVar = VALUELIST(GetProgramsFund.Program_ID,"_")>
			<CFIF Not IsDefined("AppendVar_List")>
				<CFSET AppendVar_List = TRIM(AppendVar)>
			<CFELSE>
				<CFSET AppendVar_List = "#AppendVar_List#,#TRIM(AppendVar)#">
			</CFIF>		
			<CFSET DistAR = A_R>
			<CFSET DISTFY = Fiscal_Year>		
			<CFSET TotBBAmountFund = 0>
			
			<CFQUERY NAME="ProgramDetailsForFund" DATASOURCE="#Application.Datasource#">
				SELECT 		DISTINCT Contract_Title,Contract_Number
				FROM 		Contract_Main 
				WHERE		Contract_Main_ID IN (#SameARProgs#)
			</CFQUERY>
			
			<CFLOOP QUERY="GetProgramsFund">
				<cfset useLakebaseForGetBBAmountFund = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_fixed_fund_allocation_cal")>
<cfif useLakebaseForGetBBAmountFund>
	<cftry>
		<cfset GetBBAmountFund = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code_fixed_fund_allocation_cal", {
				"billback_id" = "eq.#Billback_ID#",
				"program_id" = "eq.#Program_ID#",
				"allocation_method" = "eq.3",
				"a_r" = "eq.#DistAR#",
				"fiscal_year" = "eq.#DISTFY#",
				"deleted" = "eq.0",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBBAmountFund = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBBAmountFund>
<CFQUERY NAME="GetBBAmountFund" DATASOURCE="#Application.Datasource#">
					SELECT 	Top 1 * 
					FROM 	GL_Code_Fixed_Fund_Allocation_Cal
					WHERE 	Billback_ID = '#Billback_ID#' AND 
							Program_ID = #Program_ID# AND 
							Allocation_Method = 3 AND
							A_R = '#DistAR#' AND
							Fiscal_Year = '#DISTFY#' AND
							Deleted = 0
				</CFQUERY>
</cfif>
				
				<CFSET TotBBAmountFund = TotBBAmountFund + GetBBAmountFund.Approved_Amount>
			</CFLOOP>
			<TR>
				<TD COLSPAN="100%" STYLE="border-bottom: none">
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">		
						<CFIF BBJustLumpSumOnly EQ 1 OR ActualAllocationMethod EQ 3>			
						<TR BGCOLOR="FFE083">
							<TD><B>Program ##</B></TD>
							<TD><B>Program Title</B></TD>						
						</TR>
						<CFLOOP QUERY="ProgramDetailsForFund">
						<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
							<TD><B>#Contract_Number#</B></TD>
							<TD>#Contract_Title#</TD>						
						</TR>
						</CFLOOP>
						</CFIF>
						<TR >
							<TD STYLE="border-bottom: none" <CFOUTPUT>ID="TotalStatus_#AppendVar#</CFOUTPUT>"></TD>
							<TD ALIGN="Right" STYLE="border-bottom: none"><B><FONT COLOR="Red" SIZE="2">Total Amount to be Fund Allocated: #DollarFormat(TotBBAmountFund)#</FONT></B></TD>
						</TR>
					</TABLE>
				</TD>
			</TR>
			
			<TR BGCOLOR="FFE083">	
				<TD><B>Fund</B></TD>
				<TD><B>Fund Description</B></TD>		
				<TD><B>SCOA</B></TD>				
				<TD><B>$ Amount</B></TD>
			</TR>
			<cfset useLakebaseForFundDistinctFund = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_allocation")>
<cfif useLakebaseForFundDistinctFund>
	<cftry>
		<cfset FundDistinctFund = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code_allocation", {
				"billback_id" = "eq.#Billback_ID#",
				"allocation_method" = "eq.3",
				"a_r" = "eq.#DistAR#",
				"fiscal_year" = "eq.#DISTFY#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForFundDistinctFund = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForFundDistinctFund>
<CFQUERY NAME="FundDistinctFund" DATASOURCE="#Application.Datasource#">
				SELECT 	*
				FROM 	Gl_Code_Allocation
				WHERE 	Billback_ID = '#Billback_ID#' AND 
						Allocation_Method = 3 AND
						A_R = '#DistAR#' AND
						Fiscal_Year = '#DISTFY#' AND
						Deleted = 0
			</CFQUERY>
</cfif>
			<CFSET FundNumber_List = VALUELIST(FundDistinctFund.Fund_Number)>
			<CFSET ThisTotal = 0>
			<CFSET CheckPercentTot = 0>
			<CFLOOP QUERY="FundDistinctFund">
				<CFSET ThisTotal = ThisTotal + Allocated_Amount>
				<!--- #CurrentRow# TotBBAmountFund - #TotBBAmountFund#; SOCA_Fund - #SOCA_Fund#; Fund_Number - #Fund_Number#; A_R - #DistAR#; FIscal_Year - #DISTFY# <BR><BR> --->			
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">				
					<TD>#Fund_Number#</TD> <!--- ONMOUSEOVER="Javascript: ToolTip(#CurrentRow#,'#AppendVar#','#ThisRecordCount#')" --->
					<TD>#Fund_Description#</TD>
					<TD>#SCOA#</TD><!--- ONMOUSEOVER="Javascript: ToolTip(#CurrentRow#,'#AppendVar#','#ThisRecordCount#')" --->					
					<TD>#DOLLARFORMAT(Allocated_Amount)#</TD> <!--- ONMOUSEOVER="Javascript: ToolTip(#CurrentRow#,'#AppendVar#','#ThisRecordCount#')" --->
				</TR>
			</CFLOOP>		
			<TR>
				<TD COLSPAN="2" STYLE="border-bottom: none"></TD>
				<TD ALIGN="Right" STYLE="border-bottom: none"><B>Total:</B></TD>
				<TD STYLE="border-bottom: none"><B>#DOLLARFORMAT(ThisTotal)#</B></TD>
			</TR>
		</CFLOOP>
		<TR>
			<TD COLSPAN="100%" STYLE="border-bottom: none"><HR COLOR="Navy"></TD>
		</TR>
	</CFLOOP>
</TABLE>
</CFSAVECONTENT>
</CFOUTPUT>
