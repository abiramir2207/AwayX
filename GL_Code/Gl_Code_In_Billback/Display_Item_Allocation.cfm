


<STYLE>
TABLE.UNDERLINED TD 
{
	border-bottom:solid 93BEE2 1px; 
}
</STYLE>


<CFOUTPUT>
<CFSAVECONTENT VARIABLE="ItemContent"> 
<CFIF SavedAlready NEQ 1>
<cfset useLakebaseForUpdateDetele = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_allocation")>
<cfif useLakebaseForUpdateDetele>
	<cftry>
		<cfset application.oLakebase.updateRows("gl_code_allocation",
			{
				"billback_id" = "eq.#Billback_ID#",
				"allocation_method" = "eq.1",
				"deleted" = "eq.0"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateDetele = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateDetele>
<CFQUERY NAME="UpdateDetele" DATASOURCE="#Application.Datasource#">
	UPDATE Gl_Code_Allocation 
	SET Deleted = 1
	WHERE Billback_ID = '#Billback_ID#' AND
			Allocation_Method = 1 AND
			Deleted = 0
</CFQUERY>
</cfif>
</CFIF>

<CFQUERY NAME="GetARDetails1" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT 	Fiscal_Year,
							A_R 
	FROM 		GL_Code_Item_Allocation_Cal 
	WHERE 		Billback_ID = '#Billback_ID#' AND 
				Deleted = 0
	ORDER BY 	Fiscal_Year,A_R
</CFQUERY>

<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center" CLASS="UNDERLINED" WIDTH="800">
	<tr bgcolor="79A6BB">
		<TD COLSPAN="100%"><B><FONT SIZE="2" COLOR="Navy">ITEM ALLOCATION:</FONT></B></TD>
	</TR>
<CFLOOP QUERY="GetARDetails1">
	<CFQUERY NAME="GetProgramForEachAR1" DATASOURCE="#Application.Datasource#">
		SELECT 		DISTINCT Billback_Program.Program_ID
		FROM 		Billback_Program 
		INNER JOIN	GL_Code_Item_Allocation_Cal ON GL_Code_Item_Allocation_Cal.Billback_ID = Billback_Program.Billback_ID AND
					GL_Code_Item_Allocation_Cal.Program_ID = Billback_Program.Program_ID AND
					GL_Code_Item_Allocation_Cal.Deleted = 0
		WHERE 		Billback_Program.Billback_ID = '#Billback_ID#' AND 
					GL_Code_Item_Allocation_Cal.A_R = '#A_R#' AND 
					GL_Code_Item_Allocation_Cal.Fiscal_Year = '#Fiscal_Year#' AND 					
					Billback_Program.Deleted = 0
	</CFQUERY>
	
	<CFSET Program_List = VALUELIST(GetProgramForEachAR1.Program_ID)>

	<CFQUERY NAME="GetTotOnSub" DATASOURCE="#Application.Datasource#">
		SELECT 	Progs_Sum_Amt 

		FROM 	GL_Code_Item_Allocation_Cal 
		
		WHERE 	Billback_ID = '#Billback_ID#' AND
				Program_ID IN (#Program_List#) AND					
				Deleted = 0
	</CFQUERY>
	<CFSET Item_Allocation_Tot = GetTotOnSub.Progs_Sum_Amt>
			
	<CFQUERY NAME="ProgramDetails" DATASOURCE="#Application.Datasource#">
		SELECT 		DISTINCT 	Contract_Title,
								Contract_Number,
								GL_Code_Item_Allocation_Cal.A_R,
								GL_Code_Item_Allocation_Cal.Fiscal_Year,
								GL_Code_Activation.A_R_DESCRIPTION 
								
		FROM 		Contract_Main 
		INNER JOIN 	GL_Code_Item_Allocation_Cal ON GL_Code_Item_Allocation_Cal.Program_ID = Contract_main.Contract_Main_ID AND
					GL_Code_Item_Allocation_Cal.Billback_ID = '#Billback_ID#' AND
					GL_Code_Item_Allocation_Cal.Deleted = 0 
		INNER JOIN 	GL_Code_Activation ON GL_Code_Activation.A_R = GL_Code_Item_Allocation_Cal.A_R AND
					GL_Code_Activation.Fiscal_Year = GL_Code_Item_Allocation_Cal.Fiscal_year AND
					GL_Code_Activation.Current_Active_Data = 1 AND
					GL_Code_Activation.Deleted = 0
					
		WHERE		Contract_Main_ID IN (#Program_List#)
	</CFQUERY>
	
	<CFQUERY NAME="GetItemAllocationTot" DATASOURCE="#Application.Datasource#">
		SELECT 	SUM(Approved_Amount) TotAllocationAmount
		FROM 	GL_Code_Item_Allocation_Cal
		WHERE 	Billback_ID = '#Billback_ID#' AND
				Program_ID IN (#Program_List#) AND
				Deleted = 0
	</CFQUERY>
	
		<TR>
			<TD COLSPAN="100%" STYLE="border-bottom: none">
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
					<TR BGCOLOR="FFE083">
						<TD><B>Program ##</B></TD>
						<TD><B>Program Title</B></TD>
						<TD><B>A_R</B></TD>
						<TD><B>Fiscal Year</B></TD>
					</TR>
					<CFLOOP QUERY="ProgramDetails">
					<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
						<TD><B>#Contract_Number#</B></TD>
						<TD>#Contract_Title#</TD>
						<TD>#A_R# - #A_R_DESCRIPTION#</TD>
						<TD>#Fiscal_Year#</TD>
					</TR>
					</CFLOOP>
					<TR>
						<TD COLSPAN="100%" ALIGN="Right" STYLE="border-bottom: none"><B><FONT COLOR="Red" SIZE="2">Total Amount to be Item Allocated: #DollarFormat(GetItemAllocationTot.TotAllocationAmount)#</FONT></B></TD>
					</TR>
				</TABLE>
			</TD>
		</TR>
		
		<CFQUERY NAME="DistItem" DATASOURCE="#Application.Datasource#">
			SELECT 		DISTINCT 	Product_ID,
									Fund_Number,
									A_R,
									Fiscal_Year,
									Item,
									UPC,
									Description,
									Pref_Prod_Grp,
									b.Prod_Grp
			
			FROM 		GL_Code_Item_Allocation_Cal
			LEFT JOIN 	BSA_Foodservice_Items_Master b ON b.BSA_Foodservice_Items_Master_ID = GL_Code_Item_Allocation_Cal.Product_ID
			WHERE 		Billback_ID = '#Billback_ID#' AND 
						Program_ID IN (#Program_List#) AND 
						Approved_Amount <> 0 AND
						GL_Code_Item_Allocation_Cal.Deleted = 0
						
			ORDER BY 	Fiscal_Year,A_R
		</CFQUERY>
		<CFSET ValidProdGroup = 1>
		<CFSET ValidFundNumber = 1>
		<CFSET ValidPref_Prod_Grp = 1>

		<CFSET ProductIDWithoutProd_Grp = "">
		<CFSET Prod_GrpWithout_Pref_Prod_Grp = "">
		<CFSET Pref_Prod_GrpWithOutMatch_List = "">
		<CFLOOP QUERY="DistItem">			
			<CFIF Pref_Prod_Grp NEQ "">
				<cfset useLakebaseForCheckProd_Grp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForCheckProd_Grp>
	<cftry>
		<cfset CheckProd_Grp = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"bsa_foodservice_items_master_id" = "eq.#Product_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckProd_Grp = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckProd_Grp>
<CFQUERY NAME="CheckProd_Grp" DATASOURCE="#Application.Datasource#">
					SELECT * FROM BSA_Foodservice_Items_Master 
					WHERE BSA_Foodservice_Items_Master_ID = '#Product_ID#'
				</CFQUERY>
</cfif>
				<CFIF TRIM(CheckProd_Grp.Prod_Grp) EQ "">
					<CFSET ValidProdGroup = 0>				
					<CFSET ProductIDWithoutProd_Grp = "#ProductIDWithoutProd_Grp##Product_ID#,">				
				</CFIF>
				<cfset useLakebaseForCheckFundExist = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_activation")>
<cfif useLakebaseForCheckFundExist>
	<cftry>
		<cfset CheckFundExist = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code_activation", {
				"fiscal_year" = "eq.#Fiscal_Year#",
				"a_r" = "eq.#A_R#",
				"fund_number" = "eq.#Fund_Number#",
				"product_group" = "eq.#Pref_Prod_Grp#",
				"current_active_data" = "eq.1",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckFundExist = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckFundExist>
<CFQUERY NAME="CheckFundExist" DATASOURCE="#Application.Datasource#">
					SELECT 	* 
					FROM 	GL_Code_Activation 
					WHERE 	Fiscal_Year = '#Fiscal_Year#' AND
							A_R = '#A_R#' AND
							Fund_Number = '#Fund_Number#' AND
							PRODUCT_GROUP = '#Pref_Prod_Grp#' AND
							Current_Active_Data = 1 AND				
							Deleted = 0
				</CFQUERY>
</cfif>
				<CFIF CheckFundExist.RecordCount EQ 0>
					<CFSET ValidFundNumber = 0>	
					<CFSET Pref_Prod_GrpWithOutMatch_List = "#Pref_Prod_GrpWithOutMatch_List##Pref_Prod_Grp#,">				
				</CFIF>
			<CFELSE>			
				<CFSET ValidPref_Prod_Grp = 0>					
				<CFSET Prod_GrpWithout_Pref_Prod_Grp = "#Prod_GrpWithout_Pref_Prod_Grp##Prod_Grp#,">
			</CFIF>
		</CFLOOP>
		
		<CFIF ValidProdGroup EQ 1 AND ValidFundNumber EQ 1 AND ValidPref_Prod_Grp EQ 1>
			<TR BGCOLOR="FFE083">
				<TD><B>#application.returned_customer_setting.item_label# ##</B></TD>
				<TD><B>Description</B></TD>
				<TD><B>Fund</B></TD>
				<TD><B>Fund Description</B></TD>
				<TD><B>SCOA</B></TD>				
				<TD><B>$ Amount</B></TD>
			</TR>
			<CFSET SumItemTot = 0>
			<CFLOOP QUERY="DistItem">
				<CFQUERY NAME="ItemsAmount" DATASOURCE="#Application.Datasource#">
					SELECT 	SUM(ISNULL(Approved_Amount,0)) TotAmount
					FROM 	GL_Code_Item_Allocation_Cal
				
					WHERE 	Billback_ID = '#Billback_ID#' AND 
							Product_ID = '#DistItem.Product_ID#' AND
							Program_ID IN (#Program_List#) AND 
							Deleted = 0
				</CFQUERY>

				<cfset useLakebaseForGetSCOA = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_activation")>
<cfif useLakebaseForGetSCOA>
	<cftry>
		<cfset GetSCOA = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code_activation", {
				"fiscal_year" = "eq.#Fiscal_Year#",
				"a_r" = "eq.#A_R#",
				"fund_number" = "eq.#Fund_Number#",
				"product_group" = "eq.#Pref_Prod_Grp#",
				"current_active_data" = "eq.1",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetSCOA = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetSCOA>
<CFQUERY NAME="GetSCOA" DATASOURCE="#Application.Datasource#">
					SELECT 	* 
					FROM 	GL_Code_Activation 
					WHERE 	Fiscal_Year = '#Fiscal_Year#' AND
							A_R = '#A_R#' AND
							Fund_Number = '#Fund_Number#' AND
							PRODUCT_GROUP = '#Pref_Prod_Grp#' AND
							Current_Active_Data = 1 AND				
							Deleted = 0
				</CFQUERY>
</cfif>
				 
				<CFSET SCOA_String = "#GetSCOA.COMPANY#-#GetSCOA.LOCATION#-#GetSCOA.COST_CENTER#-#GetSCOA.NATURAL_ACCT#-#GetSCOA.CHANNEL#-#GetSCOA.PRODUCT_GROUP#-#GetSCOA.FUND_NUMBER#">
				<CFIF SavedAlready NEQ 1>
				<CFQUERY NAME="LogAllocation" DATASOURCE="#Application.Datasource#">
					INSERT INTO 
					Gl_Code_Allocation	(	Billback_ID,
											Allocation_Method,
											Tot_Allocation_Amount,
											Allocated_Amount,
											SCOA,
											Fund_Number,
											Fund_Description,
											A_R,
											Fiscal_Year,
											Product_ID,
											Pref_Prod_Grp,
											Program_ID_List			)
											
					VALUES				(	'#Billback_ID#',
											1,
											#Item_Allocation_Tot#,
											<CFIF Isnumeric(ItemsAmount.TotAmount)>#ItemsAmount.TotAmount#<CFELSE>NULL</CFIF>,
											'#SCOA_String#',
											'#Fund_Number#',	
											'#GetSCOA.DESCRIPTION#',						
											'#A_R#',
											'#Fiscal_Year#',
											'#Product_ID#',
											'#Pref_Prod_Grp#',
											'#Program_List#'			)
				</CFQUERY>
				</CFIF>
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
					<TD><B>#Item#</B></TD>
					<TD>#Description#</TD>
					<TD>#Fund_Number#</TD>
					<TD>#GetSCOA.DESCRIPTION#</TD>
					<TD>#SCOA_String#</TD>					
					<TD>#DOLLARFORMAT(ItemsAmount.TotAmount)#</TD>
				</TR>	
				<CFIF NOT Isnumeric(ItemsAmount.TotAmount)>
					<CFSET ItemsAmount.TotAmount = 0>
				</CFIF>
				<CFSET SumItemTot = SumItemTot + ItemsAmount.TotAmount>
				<!--- Item - #Item#; UPC - #UPC#; Description - #Description#; SCOA - #SCOA_String#; Fund Number - #Fund_Number#; Amount - #ItemsAmount.TotAmount#; <BR><BR>	 --->
			</CFLOOP>
			<TR>
				<TD COLSPAN="5" ALIGN="Right" STYLE="border-bottom: none"><B>Total:</B></TD>
				<TD STYLE="border-bottom: none"><B>#DOLLARFORMAT(SumItemTot)#</B></TD>
			</TR>
		<CFELSE>
			<CFIF ProductIDWithoutProd_Grp NEQ "">
								
					<CFQUERY NAME="GetItemDesc" DATASOURCE="#Application.Datasource#">
						SELECT * 
						FROM BSA_Foodservice_Items_Master
						WHERE BSA_Foodservice_Items_Master_ID IN (#LISTQUALIFY(ProductIDWithoutProd_Grp,"'",",","All")#)
					</CFQUERY>
				<TR>	
					<TD COLSPAN="100%" STYLE="border-bottom: none">
						<FONT COLOR="Navy" SIZE="2"><B>Product(s) without "Natural product group":</B></FONT>						
					</TD>										
				</TR>		
				<TR>
					<TD COLSPAN="100%" STYLE="border-bottom: none">
						<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0">
							<TR>
								<TD><B>Item ##</B></TD>
								<TD><B>UPC</B></TD>
								<TD><B>Description</B></TD>
							</TR>
							<CFLOOP QUERY="GetItemDesc">
								<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
									<TD>#Item#</TD>
									<TD>#UPC#</TD>
									<TD>#Description#</TD>
								</TR>
							</CFLOOP>			
						</TABLE><BR><BR>
					</TD>
				</TR>								
			</CFIF>
			<CFIF Pref_Prod_GrpWithOutMatch_List NEQ "">
				<CFQUERY NAME="GetProdGrp" DATASOURCE="#Application.Datasource#">
					SELECT 	* 
					FROM 	GL_Code_Pro_Group_Mapping 
					WHERE 	Pref_Prod_Grp IN (#LISTQUALIFY(Pref_Prod_GrpWithOutMatch_List,"'",",","All")#) AND
							Fiscal_Year = '#A_R#' AND
							Active_Data = 1 AND
							Deleted = 0
				</CFQUERY>
				<TR>	
					<TD COLSPAN="100%" STYLE="border-bottom: none">
						<FONT COLOR="Navy" SIZE="2"><B>Preferred Product Group without matching fund number:</B></FONT>						
					</TD>					
				</TR>	
				<TR>
					<TD COLSPAN="100%" STYLE="border-bottom: none">
						<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0">
							<TR>
								<TD STYLE="border-bottom: none"><B>Preferred Prod Grp</B></TD>
								<CFIF GetProdGrp.RecordCount GT 0>
								<TD STYLE="border-bottom: none"><B>Description</B></TD>
								</CFIF>
							</TR>
							<CFIF GetProdGrp.RecordCount GT 0>
							<CFLOOP QUERY="GetProdGrp">
								<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
									<TD STYLE="border-bottom: none">#Pref_Prod_Grp#</TD>									
									<TD STYLE="border-bottom: none">#Prod_Grp_Desc#</TD>
								</TR>
							</CFLOOP>
							<CFELSE>
								<TR>
									<TD STYLE="border-bottom: none">
										<CFLOOP LIST="#Pref_Prod_GrpWithOutMatch_List#" INDEX="ThisItem">
											#ThisItem#<BR>
										</CFLOOP>
									</TD>
								</TR>			
							</CFIF>
						</TABLE>
					</TD>
				</TR>		
			</CFIF>
			<CFIF trim(replace(Prod_GrpWithout_Pref_Prod_Grp,",","","All")) NEQ "">

				<CFQUERY NAME="GetItemDesc" DATASOURCE="#Application.Datasource#">
						SELECT * 
						FROM BSA_Foodservice_Items_Master
						WHERE Prod_Grp IN (#LISTQUALIFY(Prod_GrpWithout_Pref_Prod_Grp,"'",",","All")#) AND
								BSA_Foodservice_Items_Master_ID IN	(	SELECT 		DISTINCT 	Product_ID
			
																		FROM 		GL_Code_Item_Allocation_Cal			
																		WHERE 		Billback_ID = '#Billback_ID#' AND 
																					Program_ID IN (#Program_List#) AND 
																					Approved_Amount <> 0 AND
																					GL_Code_Item_Allocation_Cal.Deleted = 0	)
					</CFQUERY>
				<TR>	
					<TD COLSPAN="100%" STYLE="border-bottom: none">
						<FONT COLOR="Navy" SIZE="2"><B>"Natural product group" without "Preferred Product Group":</B></FONT>						
					</TD>										
				</TR>		
				<TR>
					<TD COLSPAN="100%" STYLE="border-bottom: none">
						<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0">
							<TR>
								<TD><B>Item ##</B></TD>
								<TD><B>UPC</B></TD>
								<TD><B>Description</B></TD>
								<TD><B>Natural Product Group</B></TD>
							</TR>
							<CFLOOP QUERY="GetItemDesc">
								<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
									<TD>#Item#</TD>
									<TD>#UPC#</TD>
									<TD>#Description#</TD>
									<TD>#Prod_Grp#</TD>
								</TR>
							</CFLOOP>			
						</TABLE><BR><BR>
					</TD>
				</TR>		
				
			</CFIF>
			<CFIF ProductIDWithoutProd_Grp NEQ "">
				<CFSET InvalidReason = 1>
			</CFIF>
			<CFIF Pref_Prod_GrpWithOutMatch_List NEQ "">
				<CFIF ProductIDWithoutProd_Grp NEQ "">
					<CFSET InvalidReason = "1,2">
				<CFELSE>
					<CFSET InvalidReason = 2>			
				</CFIF>
			</CFIF>
			<CFIF Prod_GrpWithout_Pref_Prod_Grp NEQ "">
				<CFIF IsDefined("InvalidReason") AND InvalidReason NEQ "">
					<CFSET InvalidReason = "#InvalidReason#,3">
				<CFELSE>
					<CFSET InvalidReason = 3>
				</CFIF>				
			</CFIF>
			<CFIF SavedAlready NEQ 1>
			<cfset useLakebaseForInsertFailureInAllocation = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_allocation")>
<cfif useLakebaseForInsertFailureInAllocation>
	<cftry>
		<cfset application.oLakebase.insertRow("gl_code_allocation", {
			"billback_id" = "#Billback_ID#",
			"allocation_method" = "1",
			"nomatching_record" = "1",
			"reason_id" = "#InvalidReason#",
			"program_id_list" = "#Program_List#",
			"pending_status" = "1"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertFailureInAllocation = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertFailureInAllocation>
<CFQUERY NAME="InsertFailureInAllocation" DATASOURCE="#Application.Datasource#">
				INSERT INTO 
				Gl_Code_Allocation	(	Billback_ID,
										Allocation_Method,
										NoMatching_Record,
										Reason_ID,
										Program_ID_List,
										Pending_Status			)
										
				VALUES				(	'#Billback_ID#',
										1,
										1,
										'#InvalidReason#',
										'#Program_List#',
										1				)
			</CFQUERY>
</cfif>
			</CFIF>
			<TR>
				<TD COLSPAN="100%" STYLE="border-bottom: none">
					<FONT COLOR="Red" SIZE="2"><B>The Status of this billback will be changed as "Pending Fund Update".</B></FONT>
				</TD>
			</TR>
		</CFIF>
		
		<TR>
			<TD COLSPAN="100%" STYLE="border-bottom: none"><HR COLOR="Navy"></TD>
		</TR>
	</CFLOOP>
</TABLE>
</CFSAVECONTENT>
</CFOUTPUT>
