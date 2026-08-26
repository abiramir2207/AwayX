
<CFOUTPUT>
<CFIF SavedAlready NEQ 1>
<CFQUERY NAME="DeletePre" DATASOURCE="#Application.Datasource#">
	UPDATE 	Gl_Code_Allocation
	SET 	Deleted = 1
	WHERE 	Billback_ID = '#Billback_ID#' AND
			Allocation_Method = 2 AND
			Deleted = 0	
</CFQUERY>
</CFIF>
<CFQUERY NAME="GetARDetails2" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT 	Billback_Program.A_R,
							Billback_Program.AR_From_Fiscal_Year
										
	FROM 		Billback_Program 
	<!--- 
	INNER JOIN 	Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
	INNER JOIN 	Program_Latest_Template_ID ON Program_Latest_Template_ID.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
	INNER JOIN 	Program_Control_Panel_Options aaa ON aaa.ProgramControl_Panel_Options_ID = Program_Latest_Template_ID.Latest
	 --->
	WHERE 		Billback_ID = '#Billback_ID#' AND Billback_Program.Deleted = 0 AND
				Billback_Program.Allocation_Method = 2
	ORDER BY 	Billback_Program.AR_From_Fiscal_Year,Billback_Program.A_R
</CFQUERY>
<CFSAVECONTENT VARIABLE="FixedContent">
<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center" CLASS="UNDERLINED" WIDTH="800">
	<tr bgcolor="EE9393">
		<TD COLSPAN="100%"><B><FONT SIZE="2" COLOR="Navy">FIXED ALLOCATION:</FONT></B></TD>
	</TR>
	<CFLOOP QUERY="GetARDetails2">
		<CFQUERY NAME="GetProgramForEachAR2" DATASOURCE="#Application.Datasource#">
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
			AND 		Billback_Program.Allocation_Method = 2 
			AND			Billback_Program.Deleted = 0
		</CFQUERY>
		<CFSET Program_List = VALUELIST(GetProgramForEachAR2.Program_ID)>
		<CFIF SavedAlready NEQ 1>
		<CFQUERY NAME="DeletePre" DATASOURCE="#Application.Datasource#">
			UPDATE 	GL_Code_Fixed_Allocation_MakeUp
			SET 	Deleted = 1
			WHERE 	Billback_ID = '#Billback_ID#' AND
					Program_ID_List = '#Program_List#' AND
					Allocation_Method = 2 AND
					Deleted = 0
		</CFQUERY>
		</CFIF>
		
	<CFQUERY NAME="DistinctARFY" DATASOURCE="#Application.Datasource#">
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
					Allocation_Method = 2 AND
					GL_Code_Fixed_Fund_Allocation_Cal.Deleted = 0
		ORDER BY 	GL_Code_Fixed_Fund_Allocation_Cal.Fiscal_Year,GL_Code_Fixed_Fund_Allocation_Cal.A_R
	</CFQUERY>

	<CFLOOP QUERY="DistinctARFY">
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
		
		<CFQUERY NAME="GetPrograms" DATASOURCE="#Application.Datasource#">
			SELECT 	DISTINCT Program_ID
			FROM	GL_Code_Fixed_Fund_Allocation_Cal
			WHERE 	Billback_ID = '#Billback_ID#' AND 
					Program_ID IN (#Program_List#) AND 
					Allocation_Method = 2 AND
					A_R = '#A_R#' AND
					Fiscal_Year = '#Fiscal_Year#' AND
					Deleted = 0
		</CFQUERY>
		
		<CFSET SameARProgs = VALUELIST(GetPrograms.Program_ID)>
		<CFSET DistAR = A_R>
		<CFSET DISTFY = Fiscal_Year>		
		<CFSET TotBBAmount = 0>
		
		<CFQUERY NAME="ProgramDetailsForFixed" DATASOURCE="#Application.Datasource#">
			SELECT 		DISTINCT Contract_Title,Contract_Number
			FROM 		Contract_Main 
			WHERE		Contract_Main_ID IN (#SameARProgs#)
		</CFQUERY>
		
		<CFLOOP QUERY="GetPrograms">
			<CFQUERY NAME="GetBBAmount" DATASOURCE="#Application.Datasource#">
				SELECT 	Top 1 * 
				FROM 	GL_Code_Fixed_Fund_Allocation_Cal
				WHERE 	Billback_ID = '#Billback_ID#' AND 
						Program_ID = #Program_ID# AND 
						Allocation_Method = 2 AND
						A_R = '#DistAR#' AND
						Fiscal_Year = '#DISTFY#' AND
						Deleted = 0
			</CFQUERY>
					
			<CFSET TotBBAmount = TotBBAmount + GetBBAmount.Approved_Amount>
		</CFLOOP>
		<CFIF SavedAlready NEQ 1>
		<CFQUERY NAME="UpdateAmount" DATASOURCE="#Application.Datasource#">
			UPDATE 	GL_Code_Fixed_Fund_Allocation_Cal
			
			SET 	Progs_Sum_Amt = #TotBBAmount#
					
			WHERE 	Billback_ID = '#Billback_ID#' AND 
					Program_ID IN (#SameARProgs#) AND 
					Allocation_Method = 2 AND
					A_R = '#DistAR#' AND
					Fiscal_Year = '#DISTFY#' AND
					Deleted = 0
		</CFQUERY>
		</CFIF>
		<TR>
			<TD COLSPAN="100%" STYLE="border-bottom: none">
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">					
					<TR BGCOLOR="FFE083">
						<TD><B>Program ##</B></TD>
						<TD><B>Program Title</B></TD>						
					</TR>
					<CFLOOP QUERY="ProgramDetailsForFixed">
					<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
						<TD><B>#Contract_Number#</B></TD>
						<TD>#Contract_Title#</TD>						
					</TR>
					</CFLOOP>
					<TR>
						<TD COLSPAN="100%" ALIGN="Right" STYLE="border-bottom: none"><B><FONT COLOR="Red" SIZE="2">Total Amount to be Fixed Allocated: #DollarFormat(TotBBAmount)#</FONT></B></TD>
					</TR>
				</TABLE>
			</TD>
		</TR>
		<CFQUERY NAME="DistinctFund" DATASOURCE="#Application.Datasource#">
			SELECT 	DISTINCT Fund_Number
			FROM 	GL_Code_Fixed_Fund_Allocation_Cal
			WHERE 	Billback_ID = '#Billback_ID#' AND 
					Program_ID IN (#SameARProgs#) AND 
					Allocation_Method = 2 AND
					A_R = '#DistAR#' AND
					Fiscal_Year = '#DISTFY#' AND
					Deleted = 0
		</CFQUERY>
		
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- Insert Distinct Fund into this table for further calculation --->
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<CFIF SavedAlready NEQ 1>
		<CFLOOP QUERY="DistinctFund">			
			<CFQUERY NAME="Insertdata" DATASOURCE="#Application.Datasource#">
				INSERT INTO 
				GL_Code_Fixed_Allocation_MakeUp (	Billback_ID,
													Program_ID_List,
													Fund_Number,
													Allocation,														
													Progs_Sum_Amt,
													Fiscal_Year,
													A_R,
													Allocation_Method,
													Surrogate_Item				)
													
				SELECT 								Top 1 Billback_ID,
													'#SameARProgs#',
													Fund_Number,
													Allocation,															
													Progs_Sum_Amt,
													Fiscal_Year,
													A_R,
													2,
													Surrogate_Item
													
				FROM 								GL_Code_Fixed_Fund_Allocation_Cal
				WHERE 								Billback_ID = '#Billback_ID#' AND 
													Program_ID IN (#SameARProgs#) AND 
													Fund_Number = '#Fund_Number#' AND
													Allocation_Method = 2 AND
													A_R = '#DistAR#' AND
													Fiscal_Year = '#DISTFY#' AND
													Deleted = 0
			</CFQUERY>				
		</CFLOOP>	
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		
		<CFQUERY NAME="CalAmount" DATASOURCE="#Application.Datasource#">
			UPDATE 	GL_Code_Fixed_Allocation_MakeUp
		
			SET 	Calculated_Amount = Progs_Sum_Amt * Allocation
					
			WHERE 	Billback_ID = '#Billback_ID#' AND 
					Program_ID_List = '#SameARProgs#' AND 					
					A_R = '#DistAR#' AND
					Fiscal_Year = '#DISTFY#' AND
					Allocation_Method = 2 AND
					Deleted = 0
		</CFQUERY>
		</CFIF>
		<CFQUERY NAME="GetAllocationSum" DATASOURCE="#Application.Datasource#">
			SELECT 	SUM(Allocation) CheckTotAllocation
			FROM 	GL_Code_Fixed_Allocation_MakeUp
					
			WHERE 	Billback_ID = '#Billback_ID#' AND 
					Program_ID_List = '#SameARProgs#' AND 					
					A_R = '#DistAR#' AND
					Fiscal_Year = '#DISTFY#' AND
					Allocation_Method = 2 AND
					Deleted = 0
		</CFQUERY>
		<CFSET ValidAllocation = 1>	
		<CFIF TRIM(GetAllocationSum.CheckTotAllocation) EQ 1>
			<CFIF SavedAlready NEQ 1>
			<CFQUERY NAME="RoundAmount" DATASOURCE="#Application.Datasource#">
				UPDATE 	GL_Code_Fixed_Allocation_MakeUp
				SET 	Calculated_Amount = ROUND(Calculated_Amount,2)
				WHERE 	Billback_ID = '#Billback_ID#' AND 
						Program_ID_List = '#SameARProgs#' AND 						
						A_R = '#DistAR#' AND
						Fiscal_Year = '#DISTFY#' AND
						Allocation_Method = 2 AND
						Deleted = 0
			</CFQUERY>
			</CFIF>
			<CFQUERY NAME="SumCalculateAmount" DATASOURCE="#Application.Datasource#">
				SELECT 	SUM(Calculated_Amount) CheckTotAmount
				FROM 	GL_Code_Fixed_Allocation_MakeUp
						
				WHERE 	Billback_ID = '#Billback_ID#' AND 
						Program_ID_List = '#SameARProgs#' AND 
						A_R = '#DistAR#' AND
						Fiscal_Year = '#DISTFY#' AND
						Allocation_Method = 2 AND
						Deleted = 0
			</CFQUERY>
			
			<CFSET TotFixedAmtDiff = TotBBAmount - SumCalculateAmount.CheckTotAmount>
			<CFIF TotFixedAmtDiff NEQ 0>								
				<CFQUERY NAME="UpdateAmt" DATASOURCE="#Application.Datasource#">
					UPDATE GL_Code_Fixed_Allocation_MakeUp
					SET Calculated_Amount = Calculated_Amount + #TotFixedAmtDiff#
					WHERE GL_Code_Fixed_Allocation_MakeUp_ID = (	
															SELECT 	Top 1 GL_Code_Fixed_Allocation_MakeUp_ID 
															FROM 	GL_Code_Fixed_Allocation_MakeUp
															WHERE 	Billback_ID = '#Billback_ID#' AND
																	Program_ID_List = '#SameARProgs#' AND 
																	A_R = '#DistAR#' AND
																	Fiscal_Year = '#DISTFY#' AND
																	Allocation_Method = 2 AND
																	Calculated_Amount IN (	
																							SELECT 	MAX(Calculated_Amount)
																							FROM 	GL_Code_Fixed_Allocation_MakeUp
																							WHERE 	Billback_ID = '#Billback_ID#' AND
																									Program_ID_List = '#SameARProgs#' AND 
																									A_R = '#DistAR#' AND
																									Fiscal_Year = '#DISTFY#' AND
																									Allocation_Method = 2 AND
																									Deleted = 0	
																						) AND
																	Deleted = 0
														)
				</CFQUERY>
			</CFIF>
		<CFELSE>
			<CFSET ValidAllocation = 0>	
		</CFIF>
		<CFIF ValidAllocation EQ 1>
			<CFQUERY NAME="GetAllFund" DATASOURCE="#Application.Datasource#">
				SELECT 	*
				FROM 	GL_Code_Fixed_Allocation_MakeUp
				WHERE	Billback_ID = '#Billback_ID#' AND 
						Program_ID_List = '#SameARProgs#' AND 						
						A_R = '#DistAR#' AND
						Fiscal_Year = '#DISTFY#' AND
						Allocation_Method = 2 AND	
						Calculated_Amount > 0 AND					
						Deleted = 0
			</CFQUERY>
			
			<TR BGCOLOR="FFE083">	
				<TD><B>Fund</B></TD>
				<TD><B>Fund Description</B></TD>		
				<TD><B>SCOA</B></TD>				
				<TD><B>% Allocation</B></TD>
				<TD><B>$ Amount</B></TD>
			</TR>
			<CFSET Tot_Allocated_Persent = 0>
			<CFSET CheckPercentTot = 0>
			<CFLOOP QUERY = "GetAllFund">
				<CFQUERY NAME="GetARPercent" DATASOURCE="#Application.Datasource#">
					SELECT 		*
											
					FROM 		GL_Code_Activation
								
					WHERE 		A_R = '#DistAR#' AND
								Fiscal_Year = '#DISTFY#' AND
								Fund_Number = '#Fund_Number#' AND
								Current_Active_Data = 1 AND								
								deleted = 0
				</CFQUERY>

				<CFSET SOCA_Fixed = "#GetARPercent.COMPANY#-#GetARPercent.LOCATION#-#GetARPercent.COST_CENTER#-#GetARPercent.NATURAL_ACCT#-#GetARPercent.CHANNEL#-#GetARPercent.PRODUCT_GROUP#-#GetARPercent.FUND_NUMBER#">				
				<CFSET CheckPercentTot = CheckPercentTot + Calculated_Amount>
				<CFSET Allocation_100 = Allocation * 100>
				<CFSET Tot_Allocated_Persent = Tot_Allocated_Persent + Allocation_100>
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">				
					<TD>#Fund_Number#</TD>
					<TD>#GetARPercent.DESCRIPTION#</TD>
					<TD>#SOCA_Fixed#</TD>					
					<TD>#Allocation_100# %</TD>
					<TD>#DOLLARFORMAT(Calculated_Amount)#</TD>
				</TR>	
				<CFIF SavedAlready NEQ 1>
				<CFQUERY NAME="InsertAllocation" DATASOURCE="#Application.Datasource#">
					INSERT INTO
					Gl_Code_Allocation	(	Billback_ID,
											Allocation_Method,
											Tot_Allocation_Amount,
											Allocated_Amount,
											Allocation_Percent,											
											Fund_Number,
											Fund_Description,
											SCOA,
											A_R,
											Fiscal_Year,
											Program_ID_List,
											Surrogate_Item			)
											
					VALUES				(	'#Billback_ID#',
											2,
											#TotBBAmount#,
											#Calculated_Amount#,
											#Allocation#,
											'#Fund_Number#',
											'#GetARPercent.DESCRIPTION#',
											'#SOCA_Fixed#',
											'#DistAR#',
											'#DISTFY#',
											'#SameARProgs#',
											'#Surrogate_Item#'			)
				</CFQUERY>
				</CFIF>
			</CFLOOP>
			<TR>
				<TD COLSPAN="3" ALIGN="Right" STYLE="border-bottom: none"><B>Total:</B></TD>
				<TD STYLE="border-bottom: none"><B>#Tot_Allocated_Persent# %</B></TD>
				<TD STYLE="border-bottom: none"><B>#DOLLARFORMAT(CheckPercentTot)#</B></TD>
			</TR>
			<TR>
				<TD COLSPAN="100%"><HR COLOR="Navy"></TD>
			</TR>
		<CFELSE>
			<CFSET InvalidAllocationTot = GetAllocationSum.CheckTotAllocation * 100>
			<CFIF SavedAlready NEQ 1>
			<CFQUERY NAME="InsertFailureInAllocation" DATASOURCE="#Application.Datasource#">
				INSERT INTO 
				Gl_Code_Allocation	(	Billback_ID,
										Allocation_Method,										
										Reason_ID,
										Program_ID_List,
										Pending_Status			)
										
				VALUES				(	'#Billback_ID#',
										2,
										'3',
										'#SameARProgs#',
										1				)
			</CFQUERY>
			</CFIF>
			<TR>
				<TD COLSPAN="100%" STYLE="border-bottom: none">
					<FONT COLOR="Red" SIZE="2"><B>The allocation total for this AR is #InvalidAllocationTot# %. Allocation total must be 100%. The status of this billback will be changed as "Pending Fund Update".</B></FONT>
				</TD>
			</TR>
		</CFIF>
			
		
	</CFLOOP>
	</CFLOOP>
</TABLE>
</CFSAVECONTENT>
</CFOUTPUT>


